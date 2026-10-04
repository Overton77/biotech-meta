// Usage: node merge-fragments.mjs <workersDir> <out.graphql> [--order W00,W01,...]
// Concatenates worker sdl-fragment.graphql files, reports duplicate definitions, undefined type references,
// extend blocks, forbidden directives; writes merged file. Does not build (use build-schema.mjs on the output).
import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { parse, Kind, visit } from "graphql";
const [dir, out] = process.argv.slice(2);
const oIdx = process.argv.indexOf("--order");
let workers = readdirSync(dir).filter(d => /^W\d\d$/.test(d)).sort();
if (oIdx > -1) workers = process.argv[oIdx+1].split(",");
const BUILTIN = new Set(["ID","String","Int","Float","Boolean","DateTime","Date","Time","LocalTime","LocalDateTime","Duration","BigInt","Point","CartesianPoint"]);
const defs = new Map(); // name -> {worker, kind}
const dupes = []; const refs = new Map(); const extendBlocks = []; const badDirectives = [];
const FORBIDDEN = new Set(["cypher","customResolver","populatedBy","jwt","jwtClaim","authentication","authorization","subscriptionsAuthorization","unique","private","exclude","readonly","writeonly"]);
let merged = "";
for (const w of workers) {
  const f = join(dir, w, "sdl-fragment.graphql");
  if (!existsSync(f)) { console.log(`[skip] ${w}: no sdl-fragment.graphql`); continue; }
  const text = readFileSync(f, "utf8");
  let doc;
  try { doc = parse(text); } catch (e) { console.log(`[parse-error] ${w}: ${e.message.split("\n")[0]}`); continue; }
  for (const d of doc.definitions) {
    if (d.kind.endsWith("Extension")) { extendBlocks.push(`${w}: extend ${d.name.value}`); continue; }
    if (!d.name) continue;
    const name = d.name.value;
    if (defs.has(name)) dupes.push(`${name}: ${defs.get(name).worker} and ${w}`); else defs.set(name, { worker: w, kind: d.kind });
  }
  visit(doc, {
    NamedType(node) { if (!BUILTIN.has(node.name.value)) { if (!refs.has(node.name.value)) refs.set(node.name.value, new Set()); refs.get(node.name.value).add(w); } },
    Directive(node) { if (FORBIDDEN.has(node.name.value)) badDirectives.push(`${w}: @${node.name.value}`); }
  });
  merged += `\n# ===================== fragment ${w} =====================\n` + text + "\n";
}
// union overlap: a union listing a type together with a type whose @node labels include that type's primary label
const labelsOf = new Map(); const unions = [];
for (const w of workers) {
  const f = join(dir, w, "sdl-fragment.graphql"); if (!existsSync(f)) continue;
  let doc; try { doc = parse(readFileSync(f, "utf8")); } catch { continue; }
  for (const d of doc.definitions) {
    if (d.kind === Kind.OBJECT_TYPE_DEFINITION) {
      const nd = (d.directives||[]).find(x => x.name.value === "node");
      const arg = nd && (nd.arguments||[]).find(a => a.name.value === "labels");
      const labels = arg && arg.value.kind === Kind.LIST ? arg.value.values.map(v => v.value) : [d.name.value];
      labelsOf.set(d.name.value, labels);
    }
    if (d.kind === Kind.UNION_TYPE_DEFINITION) unions.push({ w, name: d.name.value, members: (d.types||[]).map(t => t.name.value) });
  }
}
const overlaps = [];
for (const u of unions) for (const a of u.members) for (const b of u.members) {
  if (a === b) continue; const lb = labelsOf.get(b); if (!lb) continue;
  if (lb.slice(1).includes(a) || (labelsOf.get(a)||[])[0] && lb.includes((labelsOf.get(a)||[])[0]) && lb[0] !== a && lb.indexOf(a) > 0) overlaps.push(`${u.w} ${u.name}: ${b} (labels ${lb.join(",")}) overlaps member ${a}`);
}
const undefinedRefs = [...refs.entries()].filter(([n]) => !defs.has(n)).map(([n, ws]) => `${n} <- ${[...ws].join(",")}`);
console.log(`definitions: ${defs.size}; duplicates: ${dupes.length}; undefined refs: ${undefinedRefs.length}; extend blocks: ${extendBlocks.length}; forbidden directives: ${badDirectives.length}`);
for (const x of dupes) console.log("  DUP " + x);
for (const x of undefinedRefs) console.log("  UNDEF " + x);
for (const x of extendBlocks) console.log("  EXTEND " + x);
for (const x of badDirectives) console.log("  BADDIR " + x);
console.log(`union overlaps (type + its specialization in one union): ${overlaps.length}`);
for (const x of [...new Set(overlaps)]) console.log("  OVERLAP " + x);
if (out) { writeFileSync(out, merged); console.log("wrote", out); }
const byKind = {}; for (const [n, d] of defs) byKind[d.kind] = (byKind[d.kind]||0)+1; console.log(JSON.stringify(byKind));
