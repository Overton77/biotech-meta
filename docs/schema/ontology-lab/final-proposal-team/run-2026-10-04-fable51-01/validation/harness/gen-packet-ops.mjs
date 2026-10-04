// Usage: node gen-packet-ops.mjs <workersDir> <generated-base.cypher> <out-base-extra.cypher> <out-ent-extra.cypher>
// Collects CREATE CONSTRAINT / CREATE ... INDEX statements from every packet's operations.cypher (+ W00 operations-delta.cypher),
// drops those whose name or normalized body already exists in the generated file, routes existence/type constraints to the
// Enterprise companion, and emits the rest grouped by packet. Data statements (MATCH/MERGE) and validator queries are skipped.
import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
const [wdir, genFile, outBase, outEnt] = process.argv.slice(2);
const split = txt => { const out = []; let cur = []; for (const line of txt.split("\n")) { const l = line.replace(/\/\/.*$/, ""); cur.push(line); if (/;\s*$/.test(l)) { out.push(cur.join("\n")); cur = []; } } return out.map(s => s.split("\n").filter(x => !/^\s*\/\//.test(x)).join("\n").trim()).filter(Boolean); };
const norm = s => s.replace(/CONSTRAINT\s+\S+\s+IF NOT EXISTS/i, "CONSTRAINT X IF NOT EXISTS").replace(/INDEX\s+\S+\s+IF NOT EXISTS/i, "INDEX X IF NOT EXISTS").replace(/\s+/g, " ").replace(/\b[nr]\b/g, "v").toLowerCase();
const nameOf = s => (s.match(/(?:CONSTRAINT|INDEX)\s+(\S+)\s+IF NOT EXISTS/i) || [])[1];
const gen = split(readFileSync(genFile, "utf8")).filter(s => /^CREATE/i.test(s));
const names = new Set(gen.map(nameOf).filter(Boolean)); const bodies = new Set(gen.map(norm));
let base = "", ent = "", nb = 0, ne = 0, dup = 0;
const workers = readdirSync(wdir).filter(w => /^W\d\d$/.test(w)).sort();
for (const w of workers) {
  for (const f of ["operations.cypher", "operations-delta.cypher"]) {
    const p = `${wdir}/${w}/${f}`; if (!existsSync(p)) continue;
    let sec = "";
    for (const s of split(readFileSync(p, "utf8"))) {
      if (!/^CREATE\s+(CONSTRAINT|INDEX|FULLTEXT INDEX|VECTOR INDEX|RANGE INDEX|TEXT INDEX|POINT INDEX|LOOKUP INDEX)/i.test(s)) continue;
      const n = nameOf(s); const b = norm(s);
      if ((n && names.has(n)) || bodies.has(b)) { dup++; continue; }
      if (n) names.add(n); bodies.add(b);
      if (/IS NOT NULL|IS ::|IS TYPED|IS NODE KEY|IS RELATIONSHIP KEY|IS KEY/i.test(s)) { ent += `// ${w}/${f}\n${s}\n`; ne++; } else { sec += s + "\n"; nb++; }
    }
    if (sec) base += `// -- ${w} (${f}) --\n${sec}`;
  }
}
writeFileSync(outBase, base); writeFileSync(outEnt, ent);
console.log(`packet ops: baseline ${nb}, enterprise ${ne}, duplicates skipped ${dup}`);
