// Usage: node verify-seam-closure.mjs <final.graphql> <field-injections.json> [union-additions.json] [enum-additions.json]
// Checks that every injected field landed in the named type (not in a comment or another block), that its target and
// relationship-properties types exist, that each injected relationship field agrees in properties type with the declarations of
// the same relationship type on the opposite endpoint, and that requested union members / enum values are present.
import { readFileSync, existsSync } from "node:fs";
import { parse, Kind, print } from "graphql";
const [finalPath, injPath, unionPath, enumPath] = process.argv.slice(2);
const doc = parse(readFileSync(finalPath, "utf8"));
const defs = new Map(); for (const d of doc.definitions) if (d.name) defs.set(d.name.value, d);
const named = t => { while (t.kind !== Kind.NAMED_TYPE) t = t.type; return t.name.value; };
const relOf = f => { const r = (f.directives || []).find(x => x.name.value === "relationship"); if (!r) return null; const o = {}; for (const a of r.arguments) o[a.name.value] = a.value.value; return o; };
const members = n => { const d = defs.get(n); if (!d) return []; if (d.kind === Kind.UNION_TYPE_DEFINITION) return d.types.map(t => t.name.value); return [n]; };
// index all relationship declarations
const decl = []; for (const d of doc.definitions) if (d.kind === Kind.OBJECT_TYPE_DEFINITION) for (const f of d.fields || []) { const r = relOf(f); if (r) decl.push({ on: d.name.value, field: f.name.value, type: r.type, dir: r.direction, props: r.properties || null, target: named(f.type) }); }
let errors = 0, warnings = 0, checked = 0;
const INJ = JSON.parse(readFileSync(injPath, "utf8"));
for (const inj of INJ) {
  const d = defs.get(inj.type);
  if (!d || d.kind !== Kind.OBJECT_TYPE_DEFINITION) { console.log(`ERROR type ${inj.type} not an object type`); errors++; continue; }
  for (const ftext of inj.fields) {
    const fname = (ftext.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:/m) || [])[1];
    const f = (d.fields || []).find(x => x.name.value === fname); checked++;
    if (!f) { console.log(`ERROR ${inj.type}.${fname} missing in final file`); errors++; continue; }
    const r = relOf(f); if (!r) continue;
    const tgt = named(f.type);
    if (!defs.has(tgt)) { console.log(`ERROR ${inj.type}.${fname}: target ${tgt} undefined`); errors++; }
    if (r.properties && !defs.has(r.properties)) { console.log(`ERROR ${inj.type}.${fname}: properties ${r.properties} undefined`); errors++; }
    // opposite-endpoint consistency: declarations of the same type whose owner type is a member of our target and whose target covers us
    const opp = r.direction === "OUT" ? "IN" : "OUT";
    const others = decl.filter(x => x.type === r.type && !(x.on === inj.type && x.field === fname));
    const sameDirOnUs = others.filter(x => x.on === inj.type && x.dir === r.direction);
    for (const x of sameDirOnUs.filter(y => y.target === tgt)) { console.log(`WARN ${inj.type}.${fname}: ${r.type} ${r.direction} to the same target also declared on ${inj.type}.${x.field}`); warnings++; }
    const opposite = others.filter(x => x.dir === opp && members(tgt).includes(x.on) && members(x.target).some(m => m === inj.type || (defs.get(inj.type) && false)));
    for (const x of opposite) if ((x.props || null) !== (r.properties || null)) { console.log(`WARN ${inj.type}.${fname} props ${r.properties} vs ${x.on}.${x.field} props ${x.props}`); warnings++; }
    if (!others.length) console.log(`INFO ${inj.type}.${fname}: ${r.type} is declared only by this injected field`);
  }
}
if (unionPath && existsSync(unionPath)) for (const a of JSON.parse(readFileSync(unionPath, "utf8"))) for (const m of a.add) { const ms = members(a.union); if (!ms.includes(m)) { console.log(`ERROR union ${a.union} lacks ${m} (${a.request})`); errors++; } }
if (enumPath && existsSync(enumPath)) for (const a of JSON.parse(readFileSync(enumPath, "utf8"))) { const d = defs.get(a.enum); for (const v of a.add) if (!d || !(d.values || []).some(x => x.name.value === v)) { console.log(`ERROR enum ${a.enum} lacks ${v} (${a.request})`); errors++; } }
console.log(`verify: ${checked} injected fields checked; errors ${errors}; warnings ${warnings}; definitions ${defs.size}`);
process.exitCode = errors ? 1 : 0;
