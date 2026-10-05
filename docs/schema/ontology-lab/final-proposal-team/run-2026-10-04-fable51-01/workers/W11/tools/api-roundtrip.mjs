// W11 scratch: @neo4j/graphql 7.6.3 round trip over the fixture data using stubs + sdl-fragment.graphql
import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql } from "graphql";
const [uri, out] = process.argv.slice(2);
const typeDefs = readFileSync("combined.graphql", "utf8");
const driver = neo4j.driver(uri, neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs, driver }).getSchema();
const run = async (source, variableValues = {}) => graphql({ schema, source, variableValues, contextValue: {} });
const res = {};
res.capabilityRead = await run(`query { manufacturingCapabilities(where: { uid: { eq: "hu:capability:nai-carlsbad-powder-operating" } }) {
  uid stage capacityBasis forProcess { uid processKind }
  heldByFacilitiesConnection { edges { properties { relationshipUid assertionUid validFrom validTo validFromPrecision validFromBasis recordedFrom recordedTo } node { uid } } } } }`);
res.specRead = await run(`query { specificationVersions(where: { uid: { eq: "hu:specification-version:niagen-spec-as-proposed-efsa-2019" } }) {
  uid payloadHash criteriaCount criteriaCaptureCompleteness criteriaDigest specification { uid specificationKind }
  governedMaterialsConnection { edges { properties { assertionUid validFromBasis } node { uid } } } } }`);
res.processRead = await run(`query { manufacturingProcesses(where: { uid: { eq: "hu:process:nrc-two-step-synthesis-as-described-grn-000635" } }) {
  uid processKind stepsConnection { edges { properties { orderIndex } node { uid stepKind
    inputSubstancesConnection { edges { properties { ioRole asReportedName orderIndex } node { uid } } }
    inputMaterialsConnection { edges { properties { ioRole } node { uid } } } } } }
  producedMaterials { uid } } }`);
res.createCapability = await run(`mutation { createManufacturingCapabilities(input: [{ uid: "hu:capability:api-roundtrip-probe", stateType: "MANUFACTURING_CAPABILITY",
  payloadHash: "sha256:00", stage: PILOTING, capacityBasis: NOT_REPORTED,
  heldByFacilities: { connect: [{ where: { node: { uid: { eq: "hu:facility:nai-carlsbad-powder-facility" } } },
    edge: { relationshipUid: "hu:rel:api-roundtrip-probe", assertionUid: "hu:assertion:api-roundtrip-probe", validFromBasis: UNKNOWN, validToBasis: UNKNOWN, recordedFrom: "2026-10-04T02:00:00Z" } }] } }]) {
  manufacturingCapabilities { uid stage heldByFacilities { uid } } } }`);
res.badEnum = await run(`mutation { createManufacturingCapabilities(input: [{ uid: "hu:capability:api-bad", stateType: "X", payloadHash: "sha256:00", stage: PROMOTED }]) { manufacturingCapabilities { uid } } }`);
const s = driver.session();
await s.run("MATCH (n {uid: 'hu:capability:api-roundtrip-probe'}) DETACH DELETE n");
const lab = await s.run("MATCH (n {uid: 'hu:capability:nai-carlsbad-powder-operating'}) RETURN labels(n) AS l");
res.labels = lab.records[0].get("l");
await s.close(); await driver.close();
writeFileSync(out, JSON.stringify(res, null, 1));
for (const [k, v] of Object.entries(res)) console.log(k, JSON.stringify(v).slice(0, 400));
