// Usage: node gen-operations.mjs <final.graphql> <out-baseline.cypher> <out-enterprise.cypher> <out-matrix.json>
// Generates executable operations from the final SDL: uid/id uniqueness per primary label and per archetype,
// relationshipUid uniqueness + recordedFrom range index for every relationship type that uses an asserted/episode
// property type, fulltext and vector indexes from directives using STORED property names (alias-aware).
// Enterprise companion: existence constraints for archetype-required properties and required edge properties.
import { readFileSync, writeFileSync } from "node:fs";
import { parse, Kind } from "graphql";
const [inp, outBase, outEnt, outMatrix] = process.argv.slice(2);
const doc = parse(readFileSync(inp, "utf8"));
const ARCH = ["Entity","VersionedState","Occurrence","InformationArtifact","Assertion","EvidenceAssessment"];
const nodes = []; const relProps = new Map(); const relUses = new Map(); const fulltext = []; const vector = [];
const arg = (dir, name) => (dir.arguments||[]).find(a => a.name.value === name);
for (const d of doc.definitions) {
  if (d.kind === Kind.OBJECT_TYPE_DEFINITION) {
    const nd = (d.directives||[]).find(x => x.name.value === "node");
    const rp = (d.directives||[]).find(x => x.name.value === "relationshipProperties");
    if (rp) { relProps.set(d.name.value, (d.fields||[]).filter(f => f.type.kind === Kind.NON_NULL_TYPE).map(f => f.name.value)); continue; }
    if (!nd) continue;
    const la = arg(nd, "labels"); const labels = la && la.value.kind === Kind.LIST ? la.value.values.map(v => v.value) : [d.name.value];
    const aliases = {}; const requiredScalars = [];
    for (const f of d.fields||[]) {
      const al = (f.directives||[]).find(x => x.name.value === "alias"); if (al) aliases[f.name.value] = arg(al, "property").value.value;
      const rel = (f.directives||[]).find(x => x.name.value === "relationship");
      if (rel) { const t = arg(rel, "type").value.value; const p = arg(rel, "properties"); relUses.set(t, p ? p.value.value : (relUses.get(t)||null)); }
      else if (f.type.kind === Kind.NON_NULL_TYPE && !(f.directives||[]).some(x => ["id","timestamp"].includes(x.name.value))) requiredScalars.push(aliases[f.name.value] || f.name.value);
    }
    nodes.push({ type: d.name.value, labels, aliases, requiredScalars });
    for (const x of (d.directives||[])) {
      if (x.name.value === "fulltext") for (const ix of arg(x, "indexes").value.values) { const o = Object.fromEntries(ix.fields.map(f => [f.name.value, f.value.kind === Kind.LIST ? f.value.values.map(v => v.value) : f.value.value])); fulltext.push({ label: labels[0], indexName: o.indexName, fields: o.fields.map(f => aliases[f] || f) }); }
      if (x.name.value === "vector") for (const ix of arg(x, "indexes").value.values) { const o = Object.fromEntries(ix.fields.map(f => [f.name.value, f.value.value])); vector.push({ label: labels[0], indexName: o.indexName, property: o.embeddingProperty }); }
    }
  }
}
const snake = s => s.replace(/([a-z0-9])([A-Z])/g, "$1_$2").toLowerCase();
let base = `// Baseline executable operations for the final BellLabs schema proposal.\n// Target: Neo4j 5.26 Community or Enterprise (statements below run on Community 5.26.31). Idempotent (IF NOT EXISTS).\n// Generated from the final SDL by gen-operations.mjs; hand-written sections follow the generated ones.\n\n// ---- 1. uid uniqueness per archetype label (catalog INV-001) ----\n`;
for (const a of ARCH) base += `CREATE CONSTRAINT ${snake(a)}_uid_unique IF NOT EXISTS FOR (n:${a}) REQUIRE n.uid IS UNIQUE;\n`;
base += `\n// ---- 2. uid and stored-id uniqueness per primary label (lookup indexes; INV-106) ----\n`;
for (const n of nodes) { const idProp = n.aliases.id || "id"; base += `CREATE CONSTRAINT ${snake(n.labels[0])}_uid_unique IF NOT EXISTS FOR (n:${n.labels[0]}) REQUIRE n.uid IS UNIQUE;\nCREATE CONSTRAINT ${snake(n.labels[0])}_${snake(idProp)}_unique IF NOT EXISTS FOR (n:${n.labels[0]}) REQUIRE n.${idProp} IS UNIQUE;\n`; }
base += `\n// ---- 3. one relationshipUid per episode and recordedFrom range index on asserted/episode edges (INV-101; Neo4j 5.7+ relationship uniqueness) ----\n`;
const episodeTypes = [...relUses.entries()].filter(([t, p]) => p && relProps.has(p) && relProps.get(p).includes("recordedFrom")).map(([t]) => t).sort();
for (const t of episodeTypes) base += `CREATE CONSTRAINT rel_${t.toLowerCase()}_relationship_uid IF NOT EXISTS FOR ()-[r:${t}]-() REQUIRE r.relationshipUid IS UNIQUE;\nCREATE INDEX rel_${t.toLowerCase()}_recorded_from IF NOT EXISTS FOR ()-[r:${t}]-() ON (r.recordedFrom);\n`;
base += `\n// ---- 4. fulltext indexes declared by @fulltext, created with STORED property names (D-015; the library does not create them) ----\n`;
for (const f of fulltext) base += `CREATE FULLTEXT INDEX ${f.indexName} IF NOT EXISTS FOR (n:${f.label}) ON EACH [${f.fields.map(x => `n.${x}`).join(", ")}];\n`;
base += `\n// ---- 5. vector indexes declared by @vector (D-014); dimensions and similarity are deployment parameters: edit before running ----\n`;
for (const v of vector) base += `CREATE VECTOR INDEX ${v.indexName} IF NOT EXISTS FOR (n:${v.label}) ON (n.${v.property}) OPTIONS {indexConfig: {\`vector.dimensions\`: 1536, \`vector.similarity_function\`: 'cosine'}};\n`;
let ent = `// Enterprise-only companion (property existence constraints). Rejected by Community edition; run only on Enterprise/Aura tiers that support them.\n// Semantics are otherwise service-enforced (see final validation report).\n\n`;
for (const n of nodes) for (const p of ["uid", ...n.requiredScalars.filter(p => p !== "uid")]) ent += `CREATE CONSTRAINT ${snake(n.labels[0])}_${snake(p)}_exists IF NOT EXISTS FOR (n:${n.labels[0]}) REQUIRE n.${p} IS NOT NULL;\n`;
for (const t of episodeTypes) for (const p of relProps.get(relUses.get(t))) ent += `CREATE CONSTRAINT rel_${t.toLowerCase()}_${snake(p)}_exists IF NOT EXISTS FOR ()-[r:${t}]-() REQUIRE r.${p} IS NOT NULL;\n`;
const dedupe = txt => { const seen = new Set(); return txt.split("\n").filter(l => { const m = l.match(/^CREATE (?:CONSTRAINT|INDEX|FULLTEXT INDEX|VECTOR INDEX) (\S+) IF NOT EXISTS/); if (!m) return true; if (seen.has(m[1])) return false; seen.add(m[1]); return true; }).join("\n"); };
base = dedupe(base); ent = dedupe(ent);
writeFileSync(outBase, base); writeFileSync(outEnt, ent);
writeFileSync(outMatrix, JSON.stringify({ nodeTypes: nodes.length, archetypeConstraints: ARCH.length, perLabelConstraints: nodes.length*2, episodeRelationshipTypes: episodeTypes, fulltext, vector, enterpriseStatements: ent.split("\n").filter(l => l.startsWith("CREATE")).length }, null, 1));
console.log(`nodes ${nodes.length}; episode rel types ${episodeTypes.length}; fulltext ${fulltext.length}; vector ${vector.length}; baseline statements ${base.split("\n").filter(l=>l.startsWith("CREATE")).length}; enterprise statements ${ent.split("\n").filter(l=>l.startsWith("CREATE")).length}`);
