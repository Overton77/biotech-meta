// Usage: node gen-migration.mjs <final.graphql> <out.cypher>
// Emits the archetype/parent label backfill derived from every @node(labels: [...]) in the final SDL:
// for each primary label, SET the remaining declared labels. Idempotent; no-op on a fresh database.
import { readFileSync, writeFileSync } from "node:fs";
import { parse, Kind } from "graphql";
const [inp, out] = process.argv.slice(2);
const doc = parse(readFileSync(inp, "utf8"));
const arg = (dir, name) => (dir.arguments||[]).find(a => a.name.value === name);
let txt = "";
let n = 0;
for (const d of doc.definitions) {
  if (d.kind !== Kind.OBJECT_TYPE_DEFINITION) continue;
  const nd = (d.directives||[]).find(x => x.name.value === "node"); if (!nd) continue;
  const la = arg(nd, "labels"); const labels = la && la.value.kind === Kind.LIST ? la.value.values.map(v => v.value) : [d.name.value];
  if (labels.length < 2) continue;
  txt += `MATCH (n:${labels[0]}) WHERE NOT (${labels.slice(1).map(l => `n:${l}`).join(" AND ")}) SET n${labels.slice(1).map(l => `:${l}`).join("")};\n`; n++;
}
writeFileSync(out, txt); console.log(`label backfill statements ${n}`);
