// W11 scratch runner: node runner.mjs <bolt> <outJson>
import { readFileSync, writeFileSync } from "node:fs";
import neo4j from "neo4j-driver";
import { splitStatements } from "./run-cypher-lib.mjs";
const [uri, out] = process.argv.slice(2);
const R = "/home/user/biotech-meta/docs/schema";
const W = R + "/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01";
const F = W + "/workers/W11/fixtures/";
const params = JSON.parse(readFileSync(W + "/validation/validation-params.json", "utf8"));
const driver = neo4j.driver(uri, neo4j.auth.none(), { disableLosslessIntegers: true });
const s = driver.session();
const log = { loads: [], baseline: [], w11: [], negatives: [], queries: [] };
async function runFile(path, tag) {
  const st = splitStatements(readFileSync(path, "utf8")); let ok = 0, err = [];
  for (const x of st) { try { await s.run(x.body, params); ok++; } catch (e) { err.push({ header: x.header.slice(0, 120), msg: String(e.message).slice(0, 300) }); } }
  log.loads.push({ tag, statements: st.length, ok, errors: err });
}
async function runSuite(path, only) {
  const res = [];
  for (const x of splitStatements(readFileSync(path, "utf8"))) {
    const lines = x.header.split("\n").filter(l => /^\/\/ V-/.test(l));
    const idm = lines.length ? lines[lines.length - 1].match(/^\/\/ (V-[0-9A-Z]+(?:-[0-9]+)?[a-z]?)/) : null;
    const id = idm ? idm[1] : null;
    if (only && !only.includes(id)) continue;
    try { const r = await s.run(x.body, params); res.push({ id, header: x.header.split("\n").slice(-3).join(" ").slice(0, 160), rows: r.records.length, sample: r.records.slice(0, 3).map(z => z.toObject()) }); }
    catch (e) { res.push({ id, error: String(e.message).slice(0, 300) }); }
  }
  return res;
}
await s.run("MATCH (n) DETACH DELETE n");
if (!process.env.NOINHERIT) await runFile(R + "/examples/filing-vs-capability.cypher", "inherited filing-vs-capability");
for (const f of (process.env.ONLY ? process.env.ONLY.split(",") : ["01-capability-promotion-filing-operating", "02-capacity-basis-nameplate-vs-utilized", "03-specification-versions-and-process-inputs", "04-cgmp-claim-vs-certification-registration-inspection"])) await runFile(F + f + ".cypher", f);
log.baseline = await runSuite(R + "/neo4j/validation.cypher");
log.w11 = await runSuite(F + "w11-validation.cypher");
// negatives
const neg = splitStatements(readFileSync(F + "05-negative-mutations.cypher", "utf8"));
const cleanup = neg.filter(x => /CLEANUP/.test(x.header));
for (const x of (process.env.NONEG ? [] : neg.filter(x => !/CLEANUP/.test(x.header)))) {
  const nid = (x.header.match(/\/\/ (N\d+)/) || [])[1];
  let err = null; try { await s.run(x.body, params); } catch (e) { err = String(e.message).slice(0, 300); }
  const v = (await runSuite(F + "w11-validation.cypher")).filter(z => z.rows > 0 || z.error);
  const base = (await runSuite(R + "/neo4j/validation.cypher", ["V-324", "V-325", "V-112", "V-505", "V-503"])).filter(z => (z.rows > 0 || z.error));
  log.negatives.push({ nid, err, w11: v.map(z => ({ id: z.id, rows: z.rows, sample: z.sample, error: z.error })), baseline: base.map(z => ({ id: z.id, rows: z.rows })) });
  for (const c of cleanup) await s.run(c.body);
}
// CQ queries
const qfile = W + "/workers/W11/fixtures/w11-cq-queries.cypher";
try { for (const x of splitStatements(readFileSync(qfile, "utf8"))) { const id = (x.header.match(/\b(Q-[A-Za-z0-9-]+)\b/) || [])[1]; try { const r = await s.run(x.body, params); log.queries.push({ id, rows: r.records.map(z => z.toObject()) }); } catch (e) { log.queries.push({ id, error: String(e.message).slice(0, 300) }); } } } catch (e) { log.queries.push({ error: "no query file: " + e.message }); }
const comp = await s.run("CALL dbms.components() YIELD name, versions, edition RETURN name, versions, edition");
log.server = comp.records.map(r => r.toObject());
writeFileSync(out, JSON.stringify(log, null, 1));
await s.close(); await driver.close();
console.log("loads", JSON.stringify(log.loads.map(l => [l.tag, l.statements, l.ok, l.errors.length])));
console.log("baseline nonzero", JSON.stringify(log.baseline.filter(z => z.rows > 0 || z.error).map(z => [z.id, z.rows, z.error])));
console.log("w11 nonzero", JSON.stringify(log.w11.filter(z => z.rows > 0 || z.error).map(z => [z.id, z.rows, z.error])));
console.log("negatives", JSON.stringify(log.negatives.map(n => [n.nid, n.err, n.w11.map(z => z.id + ":" + z.rows), n.baseline.map(z => z.id + ":" + z.rows)])));
console.log("queries", log.queries.length);
