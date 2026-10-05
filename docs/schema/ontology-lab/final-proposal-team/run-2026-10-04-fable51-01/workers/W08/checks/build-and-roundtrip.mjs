// W08 build and round-trip check. Usage (from a directory with @neo4j/graphql 7.6.3, graphql 16.14.2, neo4j-driver 6.2.0):
//   node build-and-roundtrip.mjs <build-stub.graphql> <sdl-fragment.graphql> <bolt.uri file> [out.json]
// 1 parse; 2 build the Neo4jGraphQL schema; 3 list root fields for W08 types; 4 create a Device and a TechnologyPlatform
// and connect IMPLEMENTS_PLATFORM with UsageEdgeProperties through the generated mutation; 5 read the edge back;
// 6 read the fixture's EMBODIES_MODEL union target and the FirmwareVersion lineage; 7 clean up its own nodes.
import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql, parse } from "graphql";
const [stubF, fragF, uriF, outF] = process.argv.slice(2);
const typeDefs = readFileSync(stubF, "utf8") + "\n" + readFileSync(fragF, "utf8");
const out = { parse: null, build: null, rootFields: {}, roundTrip: {} };
parse(typeDefs); out.parse = "ok";
const driver = neo4j.driver(readFileSync(uriF, "utf8").trim(), neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs, driver }).getSchema();
out.build = "ok";
const q = Object.keys(schema.getQueryType().getFields()), m = Object.keys(schema.getMutationType().getFields());
for (const t of ["technologyPlatforms", "toolOrInstruments", "devices", "sensors", "modalities", "firmwareVersions", "searchTechnologyPlatforms"]) {
  out.rootFields[t] = { query: q.includes(t), createMutation: m.some(f => f.toLowerCase() === ("create" + t).toLowerCase()) };
}
const run = async (src) => { const r = await graphql({ schema, source: src, contextValue: {} }); return r.errors ? r.errors.map(e => e.message.split("\n")[0]) : r.data; };
const s = driver.session();
await s.run(`MATCH (n) WHERE n.uid CONTAINS ':w08-rt-' DETACH DELETE n`);
out.roundTrip.create = await run(`mutation { createDevices(input: [{ uid: "hu:device:w08-rt-ring", entityType: "DEVICE", name: "Synthetic ring (round trip)", privacyClass: PUBLIC,
  implementsPlatforms: { create: [{ node: { uid: "hu:technology-platform:w08-rt-ppg", entityType: "TECHNOLOGY_PLATFORM", name: "PPG wearable platform (round trip)" },
    edge: { relationshipUid: "hu:rel:w08-rt-impl", assertionUid: "hu:assertion:w08-rt-impl", validFromBasis: UNKNOWN, validToBasis: UNKNOWN,
            recordedFrom: "2026-10-04T05:00:00Z", usageContext: "optical sensing", isPrimary: true } }] } }]) { devices { uid name } } }`);
out.roundTrip.readEdge = await run(`query { devices(where: { uid: { eq: "hu:device:w08-rt-ring" } }) { uid
  implementsPlatformsConnection { edges { properties { relationshipUid assertionUid usageContext isPrimary validFromBasis } node { uid name } } } } }`);
out.roundTrip.unionTarget = await run(`query { products(where: { uid: { eq: "hu:product:illumina-iscan-system" } }) { uid
  embodiesModels { __typename ... on ToolOrInstrument { uid name toolClass } ... on Device { uid name } } } }`);
out.roundTrip.firmwareLineage = await run(`query { devices(where: { uid: { eq: "hu:device:whoop-4-0" } }) { name
  firmwareVersions { versionLabel componentLabel versionBasis declaredByAssayVersions { uid softwareVersion } } } }`);
out.roundTrip.deviceRunsOnSide = await run(`query { devices(where: { uid: { eq: "hu:device:whoop-mg" } }) { name compatibleSoftwareProducts { uid name } hasSensors { name } usesModalities { name } } }`);
const stored = await s.run(`MATCH (d:Device {uid:'hu:device:w08-rt-ring'})-[r:IMPLEMENTS_PLATFORM]->(p) RETURN labels(d) AS deviceLabels, labels(p) AS platformLabels, keys(r) AS edgeKeys, d.id IS NOT NULL AS hasId`);
out.roundTrip.stored = stored.records.map(x => x.toObject());
await s.run(`MATCH (n) WHERE n.uid CONTAINS ':w08-rt-' DETACH DELETE n`);
await s.close(); await driver.close();
const json = JSON.stringify(out, null, 1);
if (outF) writeFileSync(outF, json);
console.log(json);
