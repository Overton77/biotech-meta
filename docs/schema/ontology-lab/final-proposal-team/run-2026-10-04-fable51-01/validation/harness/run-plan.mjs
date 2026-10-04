// Usage: node run-plan.mjs <plan.json> <out.json>
// plan: { "uriFile": "...", "steps": [ {"name": "...", "file": "x.cypher", "params": "p.json"?, "explain": bool?, "expect": "all-ok" | "errors-ok" | "zero-rows" | "rows:V-1xx=3,..." , "reset": bool? } ] }
// reset: MATCH (n) DETACH DELETE n before the step (constraints kept). Records per-step statement counts, errors, and rows per query id.
import { readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import neo4j from "neo4j-driver";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const HERE = dirname(fileURLToPath(import.meta.url));
const [planFile, outFile] = process.argv.slice(2);
const plan = JSON.parse(readFileSync(planFile, "utf8"));
const uri = readFileSync(plan.uriFile, "utf8").trim();
const driver = neo4j.driver(uri, neo4j.auth.none(), { disableLosslessIntegers: true });
const results = [];
for (const s of plan.steps) {
  if (s.reset) { const ses = driver.session(); await ses.run("MATCH (n) DETACH DELETE n"); await ses.close(); }
  const tmp = join(HERE, `.run-plan-${Date.now()}.json`);
  const args = [join(HERE, "run-cypher.mjs"), uri, s.file, "--json", tmp]; if (s.params) args.push("--params", s.params); if (s.explain) args.push("--explain");
  let stdout = ""; try { stdout = execFileSync("node", args, { encoding: "utf8", maxBuffer: 64*1024*1024 }); } catch (e) { stdout = (e.stdout||"") + (e.stderr||""); }
  let r; try { r = JSON.parse(readFileSync(tmp, "utf8")); } catch { r = { total: 0, ok: 0, failed: 1, results: [], raw: stdout.slice(0, 2000) }; }
  // rows are keyed by the statement id (or #n) AND by the validator's own `check` column when present (robust to renumbering)
  const rowsById = {}; const keysOf = {};
  for (const x of r.results) if (x.status === "ok" && x.rows > 0) { const k = x.id || `#${x.n}`; rowsById[k] = x.rows; const chk = x.sample && x.sample[0] && x.sample[0].check; keysOf[k] = chk ? [k, String(chk)] : [k]; if (chk && !(chk in rowsById)) rowsById[String(chk)] = x.rows; }
  const errors = r.results.filter(x => x.status === "error").map(x => `${x.id || "#"+x.n}: ${x.error}`);
  let verdict = "recorded";
  if (s.expect === "all-ok") verdict = r.failed === 0 ? "PASS" : "FAIL";
  if (s.expect === "zero-rows") { const informational = new Set(s.informational || []); const bad = Object.keys(keysOf).filter(k => !keysOf[k].some(kk => informational.has(kk))); verdict = r.failed === 0 && bad.length === 0 ? "PASS" : "FAIL"; }
  if (s.expect && s.expect.startsWith("rows:")) { const want = Object.fromEntries(s.expect.slice(5).split(",").map(p => p.split("=")).map(([k,v]) => [k, Number(v)])); verdict = Object.entries(want).every(([k,v]) => (rowsById[k]||0) >= v) ? "PASS" : "FAIL"; }
  if (s.expect === "errors-ok") verdict = "recorded";
  results.push({ name: s.name, file: s.file, total: r.total, ok: r.ok, failed: r.failed, rowsById, errors: errors.slice(0, 40), verdict });
  console.log(`${verdict.padEnd(8)} ${s.name}: ${r.ok}/${r.total} ok` + (Object.keys(rowsById).length ? `; rows ${JSON.stringify(rowsById).slice(0, 300)}` : "") + (errors.length ? `; errors ${errors.length}` : ""));
}
await driver.close();
writeFileSync(outFile, JSON.stringify({ plan: planFile, ranAt: new Date().toISOString(), results }, null, 1));
