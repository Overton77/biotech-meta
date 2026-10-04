// node label-overlap-probe.mjs <label-overlap-probe.graphql> <bolt.uri file> [out.json]
import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql } from "graphql";
const [sdlF, uriF, outF] = process.argv.slice(2);
const driver = neo4j.driver(readFileSync(uriF, "utf8").trim(), neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs: readFileSync(sdlF, "utf8"), driver }).getSchema();
const s = driver.session();
await s.run(`MATCH (n) WHERE n.uid STARTS WITH 'probe-' OR n.pid = 'probe-holder' DETACH DELETE n`);
await s.run(`CREATE (h:ProbeHolder {pid:'probe-holder'}), (a:Assertion {uid:'probe-a1'}), (c:ClaimOccurrence:Assertion {uid:'probe-co1'}),
             (h)-[:PROBE_CITES]->(a), (h)-[:PROBE_CITES]->(c)`);
const r = await graphql({ schema, source: `query { probeHolders { pid
  viaUnion { __typename ... on Assertion { uid } ... on ClaimOccurrence { uid } }
  viaInterface { __typename uid }
  viaConcrete { uid } } }`, contextValue: {} });
await s.run(`MATCH (n) WHERE n.uid STARTS WITH 'probe-' OR n.pid = 'probe-holder' DETACH DELETE n`);
await s.close(); await driver.close();
const out = { storedEdges: 2, result: r.errors ? r.errors.map(e => e.message) : r.data };
if (outF) writeFileSync(outF, JSON.stringify(out, null, 1));
console.log(JSON.stringify(out, null, 1));
