// Usage: node compile-suite.mjs <validation.cypher> <out.cypher> <corrections.cypher> [more.cypher ...]
// Final validation suite = 0.2.0 statements whose id is not replaced by a correction (header "// V-xxxr -- replaces V-xxx") and
// not retired (V-423, CL-016), followed by every correction/extension file verbatim. Ids are kept so reports can cite them.
import { readFileSync, writeFileSync } from "node:fs";
const [base, out, ...extras] = process.argv.slice(2);
const split = txt => { const o = []; let c = []; for (const l of txt.split("\n")) { c.push(l); if (/;\s*$/.test(l.replace(/\/\/.*$/, ""))) { o.push(c.join("\n")); c = []; } } if (c.join("").trim()) o.push(c.join("\n")); return o; };
const idOf = s => { const m = s.match(/^\s*\/\/\s*(V-[A-Za-z0-9-]+)/m); return m ? m[1] : null; };
const replaced = new Set(["V-423"]);
for (const f of extras) for (const m of readFileSync(f, "utf8").matchAll(/replaces (V-[A-Za-z0-9-]+)/g)) replaced.add(m[1]);
const kept = [], dropped = [];
for (const s of split(readFileSync(base, "utf8"))) { const id = idOf(s); if (id && replaced.has(id)) dropped.push(id); else kept.push(s); }
let txt = `// Final validation suite compiled by compile-suite.mjs (Wave 6). Base: docs/schema/neo4j/validation.cypher (0.2.0, unchanged on disk)\n// minus ${dropped.length} statements replaced by corrections (${dropped.join(", ")}) and the retired V-423 (CL-016),\n// plus ${extras.length} correction/extension files appended verbatim. Params: validation/validation-params.json (+ fable-w5-params.json).\n\n` + kept.join("\n") + "\n";
const retireInExtras = (i) => { const later = new Set(); for (const g of extras.slice(i + 1)) for (const m of readFileSync(g, "utf8").matchAll(/replaces (V-[A-Za-z0-9-]+)/g)) later.add(m[1]); return later; };
for (const [i, f] of extras.entries()) { const later = retireInExtras(i); const parts = split(readFileSync(f, "utf8")); const keepx = parts.filter(s => { const id = idOf(s); if (id && later.has(id)) { dropped.push(id + "(" + f.split("/").pop() + ")"); return false; } return true; }); txt += `\n// ======== ${f.split("/").slice(-2).join("/")} ========\n` + keepx.join("\n") + "\n"; }
writeFileSync(out, txt); console.log(`kept ${kept.length}, dropped ${dropped.length} (${dropped.join(",")}), extras ${extras.length}`);
