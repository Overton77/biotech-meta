import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import { printSchema, parse } from "graphql";
const file = process.argv[2];
const out = process.argv[3];
const withVector = process.env.VECTOR_PROVIDER !== "0";
const typeDefs = readFileSync(file, "utf8");
const t0 = Date.now();
try {
  parse(typeDefs);
  console.log("graphql-js parse: OK");
  const features = withVector ? { vector: { OpenAI: { token: "sk-placeholder-not-a-real-key", model: "text-embedding-3-small" } } } : {};
  const neoSchema = new Neo4jGraphQL({ typeDefs, features });
  const schema = await neoSchema.getSchema();
  const sdl = printSchema(schema);
  const typeMap = schema.getTypeMap();
  const q = schema.getQueryType().getFields();
  const m = schema.getMutationType().getFields();
  console.log(`Neo4jGraphQL build: OK in ${Date.now()-t0}ms; vectorProviderConfigured=${withVector}; generated types=${Object.keys(typeMap).length}; queries=${Object.keys(q).length}; mutations=${Object.keys(m).length}; printed SDL chars=${sdl.length}`);
  if (out) { writeFileSync(out, sdl); console.log("wrote", out); }
} catch (e) {
  console.log("Neo4jGraphQL build: FAILED");
  const msg = String(e && e.message || e);
  const errs = msg.split("\n\n").filter(Boolean);
  console.log("error blocks:", errs.length);
  console.log(msg.slice(0, 3000));
  process.exit(1);
}
