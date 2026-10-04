import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
const typeDefs = readFileSync(process.argv[2], "utf8");
try { await new Neo4jGraphQL({ typeDefs, features: {} }).getSchema(); console.log("BUILD OK"); }
catch (e) {
  const errs = e.errors || (Array.isArray(e) ? e : [e]);
  console.log("errors:", errs.length);
  const seen = new Map();
  for (const er of errs) { const m = (er.message||String(er)).split("\n")[0]; const loc = er.locations ? er.locations.map(l=>l.line).join(",") : (er.path||""); seen.set(m, (seen.get(m)||[]).concat(loc)); }
  for (const [m, locs] of seen) console.log(`- ${m}  @lines ${locs.slice(0,8).join(" ")}${locs.length>8?" …":""}`);
}
