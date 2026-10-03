---
name: setup-py-deep-modules
description: Wire grimp-based boundary linting into a Python repo so each package is a deep module — implementation hidden in subfolders, reachable only through its entry-point modules. User-invoked.
disable-model-invocation: true
---

# Setup Python Deep Modules

Make every package in this repo a **deep module**: a lot of behaviour behind a small interface. A package's public surface is its **entry points** — the modules at the package root — and everything in its subfolders is hidden. This skill installs [grimp](https://github.com/seddonym/grimp) and a boundary linter that makes entry points the only way in, then proves the rules bite.

For the vocabulary (deep module, interface, seam, depth), run the `/codebase-design` skill — use its language throughout.

## The shape this enforces

```
src/packages/
  <name>/
    __init__.py     ← an entry point (public). Import this from outside.
    client.py       ← another entry point. Packages may expose SEVERAL.
    lib/            ← implementation: hidden from outside, free to import each other.
    tests/          ← co-located tests + fixtures (a subfolder, so private).
```

The public surface is the package's **root modules** — not one designated `__init__.py`. By convention implementation lives in `lib/` and tests in `tests/`, giving every package the same two-folder shape. The rule itself is general, though: *anything* in *any* subfolder is private (detected by filesystem: a subdirectory under the package root is internal; a root-level `.py` file is an entry point), so you never extend the config to add a folder.

Four import rules plus cycle detection, all errors:

1. **Entry-point boundary** — code outside a package (app code or another package) may import only that package's entry points (its root modules), never anything in its subfolders.
2. **Intra-package freedom** — a package's own files import each other freely.
3. **Tests through the entry points** — files under `<pkg>/tests/` may import any package's entry points and their own `tests/` fixtures, but never any package's subfolder internals (not even their own). Integration tests across packages are fine; deep imports are not.
4. **Tests folder is private** — only files under `tests/` may import from `tests/` fixtures; production code may not reach into another package's test helpers.
5. **No cycles** — no dependency cycles.

**Entry points, not a barrel.** Because the public surface is *every* root module, a package can expose several small entry points (`__init__.py`, `client.py`, `server.py`) instead of funnelling everything through one giant `__init__.py`. Barrel re-exports that pull in a whole subtree are discouraged — keep entry points small and hide implementation in subfolders.

Layering (which packages may depend on which) is a *different* concern and is left as a commented stub in the linter for this repo to fill in.

## Steps

### 1. Detect the environment

- **Package manager** — `uv.lock` → uv, `poetry.lock` → poetry, `Pipfile.lock` → pipenv, `pdm.lock` → pdm, else pip. Use it for every command below (`uv run`/`poetry run`/`pdm run`/`pip install`).
- **Packages root** — if `src/` exists use `src/packages`, else `packages`. Confirm the choice with the user if the repo already has a different obvious convention.
- **Root package name** — the dotted import prefix for that folder (e.g. `packages` when imports look like `from packages.example import greet`). Read it from `pyproject.toml` (`[tool.hatch.build.targets.wheel]`, `[tool.setuptools.packages.find]`, or existing imports) or default to the last segment of the packages root path (`packages`).
- **Existing config** — check for `deep_modules.toml` and `scripts/lint_boundaries.py` (or an existing copy elsewhere). If either exists, do **not** overwrite: merge settings and rules in, and tell the user what you added.

**Done when:** package manager, packages root, root package name, and existing-config status are all known.

### 2. Install grimp

Install `grimp` as a dev dependency with the detected package manager.

**Done when:** `grimp` is in dev dependencies (`[project.optional-dependencies] dev`, `[tool.poetry.group.dev.dependencies]`, etc.).

### 3. Write the config and linter

Copy these files from this skill into the repo:

- `[deep_modules.toml](./deep_modules.toml)` → repo root as `deep_modules.toml`. Set `packages_root` and `root_package` from step 1.
- `[lint_boundaries.py](./lint_boundaries.py)` → `scripts/lint_boundaries.py` (create `scripts/` if needed). No edits required unless the repo needs custom cycle scoping.

**Done when:** `deep_modules.toml` exists with the correct paths, `scripts/lint_boundaries.py` exists, and the four forbidden import rules plus cycle detection are present.

### 4. Wire it into the checks

- Add a `lint:boundaries` script (or `lint-boundaries` if the repo uses hyphens): `python scripts/lint_boundaries.py` (prefix with `uv run` / `poetry run` when appropriate).
- Fold it into the repo's umbrella check command — the one that already runs typecheck (e.g. a `check` / `ci` / `validate` / `tox` env). Do **not** touch `pyproject.toml` package discovery or add path hacks unless imports already fail without them.
- If there is no umbrella script, add `lint:boundaries` and tell the user to include it in CI.

**Done when:** `lint:boundaries` exists and runs as part of the same command as typecheck (or mypy/ruff check).

### 5. Scaffold the example package

Create a committed `<packages-root>/example/` as a copy-me template:

- `__init__.py` — an entry point. Export one function that delegates to an internal file (so the package is visibly *deep*, not a pass-through).
- `lib/impl.py` — an internal file in a **subfolder**, imported by `__init__.py`, not reachable from outside.
- `tests/test_example.py` — imports **only** from the package entry point (e.g. `from packages.example import greet`), and asserts against the public function.

Tell the user this is a starter template to copy or delete.

**Done when:** the example package exists, exposes its behaviour through a root entry point, and hides `impl` in a subfolder.

### 6. Prove the rules bite

This is the completion criterion for the whole skill — a linter that doesn't fail on a violation is worthless.

1. Run `lint:boundaries`. It must **pass** on the clean example.
2. Temporarily add a deep import to `tests/test_example.py` (e.g. `from packages.example.lib.impl import _secret`). Run `lint:boundaries` again — it must **fail** with `tests-through-entrypoints`.
3. Revert the deep import. Run once more — it must **pass**.

**Done when:** you have observed a pass, then a fail on the deep import, then a pass again. If step 2 does not fail, the rules are not wired correctly — fix before finishing.

### 7. Document the convention

Write a `README.md` **in the packages folder** (`<packages-root>/README.md`) — next to the packages it governs — covering: the `src/packages/<name>/` layout (entry points at the root, `lib/` for implementation, `tests/` for tests), "import only through a package's entry points (its root modules)", and how to run `lint:boundaries`. **Discourage barrel modules** explicitly — expose several small entry points instead of re-exporting a whole subtree through `__init__.py`. Keep it to the copy-me snippet plus the four rules in one paragraph each.

---

Then add a **context pointer** to it from the repo's agent-instructions file — `CLAUDE.md` if present, else `AGENTS.md` (create `AGENTS.md` if neither exists). One line is enough, e.g. `Packages are deep modules — see [src/packages/README.md](./src/packages/README.md) before adding or importing one.` This is what makes an agent discover the boundary rule instead of tripping over it.

**Done when:** `<packages-root>/README.md` exists and discourages barrels, and the repo's `CLAUDE.md`/`AGENTS.md` links to it.

## Notes

- Public vs private is decided by **filesystem depth**: a package's root `.py` modules (and `__init__.py`) are entry points; anything under a **subdirectory** is private. The conventional subfolders are `lib/` (implementation) and `tests/`, but the linter doesn't hardcode them — any subdirectory is private, so a new folder never needs a config change. Adding an entry point is just adding a root-level `.py` module — no barrel.
- Packages are **flat**: one tier of immediate children under the packages root. A package's internals may nest as deep as you like; a package may not contain another package.
- The linter discovers sibling source trees next to the packages root (e.g. `src/myapp/` alongside `src/packages/`) so app-code violations are caught without listing every app package in config. It also AST-scans every `.py` file under that source root, so pytest-style `tests/` folders work without `__init__.py`.
- If you later want declarative contracts (layers, forbidden siblings), add [import-linter](https://import-linter.readthedocs.io/) on top — it uses the same grimp engine. This skill's linter is the path-depth equivalent of dependency-cruiser for TypeScript.
