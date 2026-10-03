#!/usr/bin/env python3
"""Deep-module import boundary linter for Python packages.

Mirrors the dependency-cruiser rules used by setup-ts-deep-modules:
  1. entrypoint-boundary-from-app
  2. entrypoint-boundary-across-packages
  3. tests-through-entrypoints
  4. tests-folder-is-private
  5. no-circular
"""

from __future__ import annotations

import argparse
import ast
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

import grimp


@dataclass(frozen=True)
class ModuleLocation:
    package: str
    is_internal: bool
    is_in_tests: bool


@dataclass(frozen=True)
class Violation:
    rule: str
    importer: str
    imported: str
    detail: str


def load_config(config_path: Path) -> tuple[Path, str]:
    data = tomllib.loads(config_path.read_text(encoding="utf-8"))
    packages_root = Path(data["packages_root"])
    root_package = data["root_package"]
    if not packages_root.is_dir():
        raise SystemExit(f"packages_root does not exist: {packages_root}")
    return packages_root, root_package


def locate_module(
    module: str, packages_root: Path, root_package: str
) -> ModuleLocation | None:
    """Map a dotted module name to its package and privacy class."""
    prefix = f"{root_package}."
    if module == root_package:
        return None
    if not module.startswith(prefix):
        return None

    rest = module[len(prefix) :]
    parts = rest.split(".")
    if not parts or not parts[0]:
        return None

    package = parts[0]
    package_dir = packages_root / package
    if not package_dir.is_dir():
        return None

    if len(parts) == 1:
        return ModuleLocation(package=package, is_internal=False, is_in_tests=False)

    current = package_dir
    for index, part in enumerate(parts[1:], start=1):
        child_dir = current / part
        if child_dir.is_dir():
            subpath = parts[1:]
            return ModuleLocation(
                package=package,
                is_internal=True,
                is_in_tests=subpath[0] == "tests",
            )

        module_file = current / f"{part}.py"
        if index == len(parts) - 1 and module_file.is_file():
            return ModuleLocation(
                package=package, is_internal=False, is_in_tests=False
            )

        current = child_dir

    return ModuleLocation(
        package=package,
        is_internal=True,
        is_in_tests=parts[1] == "tests",
    )


def discover_graph_roots(packages_root: Path, root_package: str) -> tuple[str, ...]:
    """Include sibling source trees so app imports are visible to the graph."""
    roots: list[str] = [root_package]
    parent = packages_root.parent
    if not parent.is_dir():
        return tuple(roots)

    for child in sorted(parent.iterdir()):
        if not child.is_dir() or child.resolve() == packages_root.resolve():
            continue
        if child.name.startswith("."):
            continue
        if (child / "__init__.py").is_file() or any(child.glob("*.py")):
            if child.name != root_package:
                roots.append(child.name)
    return tuple(dict.fromkeys(roots))


def discover_source_root(packages_root: Path) -> Path:
    return packages_root.parent if packages_root.parent.is_dir() else packages_root


def path_to_module(path: Path, source_root: Path) -> str:
    relative = path.relative_to(source_root)
    parts = list(relative.parts)
    if parts[-1] == "__init__.py":
        parts = parts[:-1]
    else:
        parts[-1] = Path(parts[-1]).stem
    return ".".join(parts)


def collect_imports(path: Path, importer_module: str) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    imports: list[str] = []

    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            imports.extend(alias.name for alias in node.names)
            continue

        if not isinstance(node, ast.ImportFrom):
            continue

        if node.level == 0:
            if node.module:
                imports.append(node.module)
            continue

        base_parts = importer_module.split(".")
        package_parts = base_parts[: len(base_parts) - node.level]
        if node.module:
            imports.append(".".join([*package_parts, *node.module.split(".")]))
            continue

        for alias in node.names:
            imports.append(".".join([*package_parts, alias.name]))

    return imports


def collect_import_edges(packages_root: Path) -> list[tuple[str, str]]:
    source_root = discover_source_root(packages_root)
    edges: list[tuple[str, str]] = []
    seen: set[tuple[str, str]] = set()

    for path in source_root.rglob("*.py"):
        try:
            importer = path_to_module(path, source_root)
        except ValueError:
            continue

        for imported in collect_imports(path, importer):
            edge = (importer, imported)
            if edge in seen:
                continue
            seen.add(edge)
            edges.append(edge)

    return edges


def check_import(
    importer: str,
    imported: str,
    packages_root: Path,
    root_package: str,
) -> Violation | None:
    imported_loc = locate_module(imported, packages_root, root_package)
    if imported_loc is None or not imported_loc.is_internal:
        return None

    importer_loc = locate_module(importer, packages_root, root_package)

    if importer_loc is None:
        return Violation(
            rule="entrypoint-boundary-from-app",
            importer=importer,
            imported=imported,
            detail=(
                "App/root code may import a package's entry points (its root modules), "
                "but nothing inside its subfolders."
            ),
        )

    if importer_loc.is_in_tests:
        if (
            imported_loc.package == importer_loc.package
            and imported_loc.is_in_tests
        ):
            return None
        return Violation(
            rule="tests-through-entrypoints",
            importer=importer,
            imported=imported,
            detail=(
                "Tests may import any package's entry points and their own tests/ "
                "fixtures, but never any package's internals — not even their own."
            ),
        )

    if (
        imported_loc.is_in_tests
        and not importer_loc.is_in_tests
    ):
        return Violation(
            rule="tests-folder-is-private",
            importer=importer,
            imported=imported,
            detail=(
                "A package's tests/ folder is reachable only from tests — "
                "nothing else may import fixtures."
            ),
        )

    if (
        importer_loc.package != imported_loc.package
        and not importer_loc.is_in_tests
    ):
        return Violation(
            rule="entrypoint-boundary-across-packages",
            importer=importer,
            imported=imported,
            detail=(
                "A package may reach other packages only through their entry points — "
                "never their internals."
            ),
        )

    return None


def find_cycle_violations(graph: grimp.ImportGraph) -> list[Violation]:
    violations: list[Violation] = []
    reported: set[tuple[str, ...]] = set()
    for module in sorted(graph.modules):
        try:
            chain = graph.find_shortest_chain(module, module)
        except ValueError:
            continue
        if not chain or len(chain) < 2:
            continue
        key = tuple(sorted(chain))
        if key in reported:
            continue
        reported.add(key)
        loop = " -> ".join(chain + (chain[0],))
        violations.append(
            Violation(
                rule="no-circular",
                importer=chain[0],
                imported=chain[-1],
                detail=f"Circular import chain: {loop}",
            )
        )
    return violations


def lint_boundaries(config_path: Path) -> list[Violation]:
    packages_root, root_package = load_config(config_path)
    graph_roots = discover_graph_roots(packages_root, root_package)
    graph = grimp.build_graph(*graph_roots)

    violations: list[Violation] = []
    seen: set[tuple[str, str, str]] = set()

    def record(importer: str, imported: str) -> None:
        violation = check_import(importer, imported, packages_root, root_package)
        if violation is None:
            return
        key = (violation.rule, violation.importer, violation.imported)
        if key in seen:
            return
        seen.add(key)
        violations.append(violation)

    for importer, imported in collect_import_edges(packages_root):
        record(importer, imported)

    for importer in graph.modules:
        for imported in graph.find_modules_directly_imported_by(importer):
            record(importer, imported)

    for violation in find_cycle_violations(graph):
        key = (violation.rule, violation.importer, violation.imported)
        if key in seen:
            continue
        seen.add(key)
        violations.append(violation)

    return violations


def main() -> int:
    parser = argparse.ArgumentParser(description="Lint deep-module import boundaries")
    parser.add_argument(
        "--config",
        default="deep_modules.toml",
        help="Path to deep_modules.toml (default: deep_modules.toml)",
    )
    args = parser.parse_args()
    config_path = Path(args.config)

    if not config_path.is_file():
        print(f"Config not found: {config_path}", file=sys.stderr)
        return 2

    violations = lint_boundaries(config_path)
    if not violations:
        print("No boundary violations found.")
        return 0

    for violation in violations:
        print(
            f"[{violation.rule}] {violation.importer} -> {violation.imported}\n"
            f"  {violation.detail}",
            file=sys.stderr,
        )
    print(f"\n{len(violations)} boundary violation(s).", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
