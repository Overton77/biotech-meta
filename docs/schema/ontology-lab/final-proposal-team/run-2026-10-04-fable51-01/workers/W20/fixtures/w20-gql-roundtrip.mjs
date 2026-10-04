import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql } from "graphql";
const uri = "bolt://127.0.0.1:43389/";
const driver = neo4j.driver(uri, neo4j.auth.none());
const typeDefs = readFileSync("../w20/merged-test.graphql", "utf8");
const neo = new Neo4jGraphQL({ typeDefs, driver });
const schema = await neo.getSchema();
const out = {};
try { await neo.assertIndexesAndConstraints(); out.assertIndexesAndConstraints = "OK"; } catch (e) { out.assertIndexesAndConstraints = "FAILED: " + e.message; }
const uidArg = process.argv[2] || "hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70";
const q = `query($uid: String!) { documents(where: { uid: { eq: $uid } }) {
  id uid name documentType sourceUrl canonicalUri isPrimarySource entityType
  hasTextVersions { id textVersionHash hasSegmentations { id segmentationStrategy segmentationHash } chunks { id name chunkIndex charStart charEnd } }
  hasChunks { id name chunkIndex }
} }`;
const r = await graphql({ schema, source: q, variableValues: { uid: uidArg }, contextValue: {} });
out.documentsQuery = r;
const s = await graphql({ schema, source: `{ searchDocuments(phrase: "Alias") { edges { score node { uid name sourceUrl } } } }`, contextValue: {} });
out.searchDocuments = s;
console.log(JSON.stringify(out, null, 1));
await driver.close();
