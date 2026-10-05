// Executes 11-write-guards.cypher bundle by bundle, each bundle in ONE explicit transaction; the trailing "// AUDIT" statement
// decides commit (0 rows) or rollback (>=1 row). Usage: node 11-write-guard-harness.mjs <bolt-uri-file> <11-write-guards.cypher>
// Requires neo4j-driver 6 and the statement splitter of the run harness (validation/harness/run-cypher.mjs).
import { readFileSync } from "node:fs";
import neo4j from "neo4j-driver";
const [uriFile, file] = process.argv.slice(2);
const uri = readFileSync(uriFile, "utf8").trim();
function split(text) { // same rules as run-cypher.mjs: split on ';' outside quotes and comments
  const out = []; let cur = ""; let inS = null, inLine = false;
  for (let i = 0; i < text.length; i++) { const c = text[i], n = text[i+1];
    if (inLine) { cur += c; if (c === "\n") inLine = false; continue; }
    if (inS) { cur += c; if (c === "\\") { cur += n; i++; continue; } if (c === inS) inS = null; continue; }
    if (c === "/" && n === "/") { inLine = true; cur += c; continue; }
    if (c === "'" || c === '"' || c === "`") { inS = c; cur += c; continue; }
    if (c === ";") { out.push(cur); cur = ""; continue; } cur += c; }
  if (cur.trim()) out.push(cur); return out; }
const text = readFileSync(file, "utf8");
const bundles = text.split(/\n(?=\/\/ BUNDLE )/).filter(b => b.startsWith("// BUNDLE "));
const driver = neo4j.driver(uri, neo4j.auth.none(), { disableLosslessIntegers: true });
const session = driver.session();
for (const b of bundles) {
  const name = b.split("\n")[0].replace("// BUNDLE ", "").split(" ")[0];
  const [writes, audit] = b.split("// AUDIT");
  const stmts = split(writes).map(s => s.split("\n").filter(l => !l.trim().startsWith("//")).join("\n").trim()).filter(Boolean);
  const tx = session.beginTransaction();
  try {
    for (const s of stmts) await tx.run(s);
    const r = await tx.run(audit.split("\n").filter(l => !l.trim().startsWith("//")).join("\n").trim().replace(/;\s*$/, ""));
    const rows = r.records.map(x => x.toObject());
    if (rows.length > 0) { await tx.rollback(); console.log(`${name}: ROLLBACK ${JSON.stringify(rows)}`); }
    else { await tx.commit(); console.log(`${name}: COMMIT`); }
  } catch (e) { try { await tx.rollback(); } catch {} console.log(`${name}: ERROR->ROLLBACK ${String(e.message).split("\n")[0]}`); }
}
const after = await session.run("MATCH (a:Assertion) WHERE a.uid STARTS WITH 'hu:assertion:w00-guard-' RETURN a.uid AS uid, a.contentHash AS contentHash, toString(a.validFrom) AS validFrom ORDER BY uid");
console.log("persisted guard assertions:", JSON.stringify(after.records.map(x => x.toObject())));
const fv = await session.run("MATCH (fv:FormulationVersion) WHERE fv.uid STARTS WITH 'hu:formulation:w00-guard-' RETURN collect(fv.uid) AS fvs");
console.log("persisted guard formulations:", JSON.stringify(fv.records[0].get("fvs")));
await session.close(); await driver.close();
