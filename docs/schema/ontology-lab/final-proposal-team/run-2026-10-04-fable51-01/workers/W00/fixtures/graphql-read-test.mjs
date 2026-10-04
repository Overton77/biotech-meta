// W00 GraphQL read/write test: builds the Neo4jGraphQL schema from sdl-fragment.graphql + generated stubs (other owners' types as
// minimal @node types) and runs GraphQL operations against fixture data loaded by Cypher. Usage:
//   node graphql-read-test.mjs <bolt-uri-file> <schema-with-stubs.graphql> <operations.json>
// operations.json: [{"name": "...", "query": "..."}]. Prints data and errors per operation.
import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import { graphql } from "graphql";
import neo4j from "neo4j-driver";
const [uriFile, sdlFile, opsFile] = process.argv.slice(2);
const driver = neo4j.driver(readFileSync(uriFile, "utf8").trim(), neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs: readFileSync(sdlFile, "utf8"), driver }).getSchema();
for (const op of JSON.parse(readFileSync(opsFile, "utf8"))) {
  const r = await graphql({ schema, source: op.query, contextValue: {} });
  console.log(`== ${op.name}`);
  if (r.errors) console.log("errors:", JSON.stringify(r.errors.map(e => ({ message: e.message, path: e.path }))));
  console.log("data:", JSON.stringify(r.data));
}
await driver.close();
