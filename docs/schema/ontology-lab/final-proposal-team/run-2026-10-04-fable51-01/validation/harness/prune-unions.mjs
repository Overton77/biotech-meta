// Usage: node prune-unions.mjs <in.graphql> <out.graphql>
// Rewrites union definitions in place (text spans only): drops members that are not defined object types,
// and drops a member whose @node labels include another member's primary label (specialization overlap).
import { readFileSync, writeFileSync } from "node:fs";
import { parse, Kind } from "graphql";
const [inp, out] = process.argv.slice(2);
const text = readFileSync(inp, "utf8");
const doc = parse(text);
const labelsOf = new Map();
for (const d of doc.definitions) if (d.kind === Kind.OBJECT_TYPE_DEFINITION) {
  const nd = (d.directives||[]).find(x => x.name.value === "node");
  const arg = nd && (nd.arguments||[]).find(a => a.name.value === "labels");
  labelsOf.set(d.name.value, arg && arg.value.kind === Kind.LIST ? arg.value.values.map(v => v.value) : [d.name.value]);
}
const edits = []; const report = [];
for (const d of doc.definitions) if (d.kind === Kind.UNION_TYPE_DEFINITION) {
  const members = (d.types||[]).map(t => t.name.value);
  let kept = members.filter(m => { const ok = labelsOf.has(m); if (!ok) report.push(`${d.name.value}: drop undefined ${m}`); return ok; });
  const primaries = new Set(kept.map(m => labelsOf.get(m)[0]));
  kept = kept.filter(m => { const lb = labelsOf.get(m); const parent = lb.slice(1).find(l => primaries.has(l) && l !== m); if (parent) { report.push(`${d.name.value}: drop ${m} (specialization of member ${parent})`); return false; } return true; });
  kept = [...new Set(kept)];
  if (kept.length !== members.length) {
    const first = d.types[0].loc.start, last = d.types[d.types.length-1].loc.end;
    edits.push({ start: first, end: last, replacement: kept.join(" | ") });
  }
}
edits.sort((a,b) => b.start - a.start);
let outText = text;
for (const e of edits) outText = outText.slice(0, e.start) + e.replacement + outText.slice(e.end);
writeFileSync(out, outText);
console.log(`unions edited: ${edits.length}; member changes: ${report.length}`);
for (const r of report) console.log("  " + r);
