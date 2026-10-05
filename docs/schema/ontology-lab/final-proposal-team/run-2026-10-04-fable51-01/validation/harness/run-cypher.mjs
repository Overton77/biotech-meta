// Usage: node run-cypher.mjs <bolt-uri-file|uri> <file.cypher> [--db name] [--params file.json] [--explain] [--json out.json]
import { readFileSync, writeFileSync } from "node:fs";
import neo4j from "neo4j-driver";
const args = process.argv.slice(2);
let uri = args[0]; if (!uri.startsWith("bolt")) uri = readFileSync(uri, "utf8").trim();
const file = args[1];
const dbIdx = args.indexOf("--db"); const db = dbIdx > -1 ? args[dbIdx+1] : "neo4j";
const pIdx = args.indexOf("--params"); const params = pIdx > -1 ? JSON.parse(readFileSync(args[pIdx+1], "utf8")) : {};
const explain = args.includes("--explain");
const jIdx = args.indexOf("--json"); const jsonOut = jIdx > -1 ? args[jIdx+1] : null;
export function splitStatements(text) {
  // split on ';' outside of quotes, backticks and comments; keep preceding comment lines as the statement's header
  const out = []; let cur = ""; let i = 0; let inS = null; let inLine = false; let inBlock = false;
  while (i < text.length) {
    const c = text[i], n = text[i+1];
    if (inLine) { cur += c; if (c === "\n") inLine = false; i++; continue; }
    if (inBlock) { cur += c; if (c === "*" && n === "/") { cur += n; i += 2; inBlock = false; continue; } i++; continue; }
    if (inS) { cur += c; if (c === "\\" ) { cur += n; i += 2; continue; } if (c === inS) inS = null; i++; continue; }
    if (c === "/" && n === "/") { inLine = true; cur += c; i++; continue; }
    if (c === "/" && n === "*") { inBlock = true; cur += c; i++; continue; }
    if (c === "'" || c === '"' || c === "`") { inS = c; cur += c; i++; continue; }
    if (c === ";") { out.push(cur); cur = ""; i++; continue; }
    cur += c; i++;
  }
  if (cur.trim()) out.push(cur);
  return out.map(s => {
    const lines = s.split("\n");
    const header = lines.filter(l => l.trim().startsWith("//")).map(l => l.trim()).join("\n");
    const body = lines.filter(l => !l.trim().startsWith("//")).join("\n").trim();
    const idm = header.match(/\b([VCI]-\d{3}[a-z]?|QS-\d[a-z\-]*)\b/);
    return { id: idm ? idm[1] : null, header, body };
  }).filter(s => s.body.length > 0);
}
const driver = neo4j.driver(uri, neo4j.auth.none(), { disableLosslessIntegers: true });
const session = driver.session({ database: db });
const stmts = splitStatements(readFileSync(file, "utf8"));
const results = [];
let ok = 0, failed = 0;
for (const [k, s] of stmts.entries()) {
  const q = explain ? "EXPLAIN " + s.body : s.body;
  const t0 = Date.now();
  try {
    const r = await session.run(q, params);
    const rows = r.records.map(rec => rec.toObject());
    const c = r.summary.counters.updates();
    results.push({ n: k+1, id: s.id, status: "ok", rows: rows.length, counters: c, ms: Date.now()-t0, sample: rows.slice(0, 5), header: s.header.slice(0, 300) });
    ok++;
  } catch (e) {
    results.push({ n: k+1, id: s.id, status: "error", error: String(e.message).split("\n")[0].slice(0, 400), header: s.header.slice(0, 300), bodyHead: s.body.slice(0, 200) });
    failed++;
  }
}
await session.close(); await driver.close();
console.log(`${file}: ${stmts.length} statements, ${ok} ok, ${failed} error`);
for (const r of results) if (r.status === "error") console.log(`  ERR #${r.n} ${r.id||""}: ${r.error}`);
if (jsonOut) writeFileSync(jsonOut, JSON.stringify({ file, uri, db, explain, total: stmts.length, ok, failed, results }, null, 1));
