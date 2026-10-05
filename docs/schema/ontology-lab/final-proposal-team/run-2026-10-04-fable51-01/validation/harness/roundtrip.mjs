// Usage: node roundtrip.mjs <sdl> <bolt-uri-file> <ops.json>   — executes GraphQL operations from a JSON list against the DB via the built schema
import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import { graphql } from "graphql";
import neo4j from "neo4j-driver";
const [sdl, uriFile, opsFile, outFile] = process.argv.slice(2);
const uri = readFileSync(uriFile, "utf8").trim();
const driver = neo4j.driver(uri, neo4j.auth.none());
const neoSchema = new Neo4jGraphQL({ typeDefs: readFileSync(sdl, "utf8"), driver, features: {} });
const t0 = Date.now(); const schema = await neoSchema.getSchema(); console.log(`schema built in ${Date.now()-t0}ms`);
const ops = JSON.parse(readFileSync(opsFile, "utf8"));
const results = [];
for (const op of ops) {
  const t = Date.now();
  const r = await graphql({ schema, source: op.query, variableValues: op.variables || {}, contextValue: { executionContext: driver } });
  const ok = !r.errors;
  results.push({ name: op.name, ok, ms: Date.now()-t, data: r.data, errors: r.errors ? r.errors.map(e => e.message.slice(0, 300)) : undefined, expect: op.expect });
  console.log(`${ok ? "OK " : "ERR"} ${op.name} (${Date.now()-t}ms)` + (r.errors ? ": " + r.errors[0].message.slice(0, 200) : ""));
}
if (outFile) writeFileSync(outFile, JSON.stringify(results, null, 1));
await driver.close();
