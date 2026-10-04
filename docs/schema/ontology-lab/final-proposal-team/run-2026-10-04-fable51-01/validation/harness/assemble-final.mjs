// Usage: node assemble-final.mjs <workersDir> <out.graphql> <rulings.json>
// Assembles the final standalone schema from worker fragments in domain order, strips per-fragment banners,
// applies textual merge rulings (field renames inside named types, type-text substitutions), prunes unions,
// and prepends the file header. Fragments themselves are never modified.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { parse, Kind } from "graphql";
const [dir, out, rulingsPath] = process.argv.slice(2);
const R = JSON.parse(readFileSync(rulingsPath, "utf8"));
let body = "";
for (const sec of R.sections) {
  body += `\n# ${"=".repeat(96)}\n# ${sec.title}\n# ${sec.purpose}\n# Competency questions: ${sec.cqs}\n# Canonical module(s): ${sec.modules}\n# ${"=".repeat(96)}\n`;
  for (const w of sec.workers) {
    const f = join(dir, w, "sdl-fragment.graphql");
    if (!existsSync(f)) { console.log("MISSING fragment", w); continue; }
    let t = readFileSync(f, "utf8");
    // drop leading comment banner lines of the fragment (keep descriptions and definitions)
    t = t.replace(/^(#[^\n]*\n|\s*\n)+/, "");
    body += `\n# ---- fragment ${w} ----\n` + t.trimEnd() + "\n";
  }
}
// textual rulings: rename fields inside a named type block
for (const r of R.fieldRenames || []) {
  const start = body.indexOf(`type ${r.type} `); if (start < 0) { console.log("rename: type not found", r.type); continue; }
  const end = body.indexOf("\n}\n", start);
  let blk = body.slice(start, end);
  const before = blk;
  blk = blk.replace(new RegExp(`(\\n\\s+)${r.from}:`), `$1${r.to}:`);
  if (blk === before) console.log("rename: field not found", r.type, r.from);
  body = body.slice(0, start) + blk + body.slice(end);
}
for (const r of R.fieldTypeFixes || []) {
  const start = body.indexOf(`type ${r.type} `); const end = body.indexOf("\n}\n", start);
  let blk = body.slice(start, end); const before = blk;
  blk = blk.replace(new RegExp(`(\\n\\s+${r.field}:\\s*)${r.from.replace(/[!\[\]]/g, m => "\\" + m)}(?=\\s|$|\\n)`, "m"), `$1${r.to}`);
  if (blk === before) console.log("typefix: no change", r.type, r.field);
  body = body.slice(0, start) + blk + body.slice(end);
}
for (const r of R.textReplacements || []) { const before = body; body = body.split(r.from).join(r.to); if (before === body) console.log("text replacement: no match", r.from.slice(0, 60)); }
// prune unions
const doc = parse(body);
const labelsOf = new Map();
for (const d of doc.definitions) if (d.kind === Kind.OBJECT_TYPE_DEFINITION) {
  const nd = (d.directives||[]).find(x => x.name.value === "node");
  const arg = nd && (nd.arguments||[]).find(a => a.name.value === "labels");
  labelsOf.set(d.name.value, arg && arg.value.kind === Kind.LIST ? arg.value.values.map(v => v.value) : [d.name.value]);
}
const edits = []; const report = [];
for (const d of doc.definitions) if (d.kind === Kind.UNION_TYPE_DEFINITION) {
  const members = (d.types||[]).map(t => t.name.value);
  let kept = members.filter(m => { const ok = labelsOf.has(m); if (!ok) report.push(`${d.name.value}: dropped undefined ${m}`); return ok; });
  const primaries = new Set(kept.map(m => labelsOf.get(m)[0]));
  kept = kept.filter(m => { const lb = labelsOf.get(m); const parent = lb.slice(1).find(l => primaries.has(l) && l !== m); if (parent) { report.push(`${d.name.value}: dropped ${m} (specialization of ${parent})`); return false; } return true; });
  kept = [...new Set(kept)];
  if (kept.length !== members.length) edits.push({ start: d.types[0].loc.start, end: d.types[d.types.length-1].loc.end, replacement: kept.join(" | ") });
}
edits.sort((a,b) => b.start - a.start);
for (const e of edits) body = body.slice(0, e.start) + e.replacement + body.slice(e.end);
const header = R.header.join("\n") + "\n";
writeFileSync(out, header + body);
console.log(`assembled ${out}: ${body.split("\n").length} lines; union edits ${edits.length}`);
for (const x of report) console.log("  " + x);
