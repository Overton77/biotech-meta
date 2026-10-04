import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql } from "graphql";
const typeDefs = readFileSync(process.argv[2], "utf8");
const uri = readFileSync(process.argv[3], "utf8").trim();
const driver = neo4j.driver(uri, neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs, driver }).getSchema();
const queries = {
  approvalsOnly: `{ regulatoryStatuses(where: {statusKind: {eq: APPROVAL}}) { uid statusKind jurisdiction resultsFromResponse { responseKind } } }`,
  drugApprovals: `{ drugApprovals { uid applicationNumber approvalFor { __typename ... on Product { uid name } } } }`,
  orphan: `{ orphanDesignations { uid statusKind indication designationFor { __typename ... on MaterialMixture { uid } } } }`,
  ldtVersions: `{ regulatoryPathways(where: {uid: {eq: "hu:reg-pathway:us-fda-ldt-oversight"}}) { pathwayKind versionsConnection { edges { properties { validFrom validTo recordedFrom recordedTo } node { versionLabel codifiedTextTo } } } } }`,
  statusOfEpisodes: `{ regulatoryStatuses(where: {uid: {eq: "hu:regulatory-status:us-synthetic-ldt-ed-v2"}}) { uid statusOfConnection { edges { properties { assertionUid validTo recordedFrom recordedTo } node { __typename ... on AssayVersion { uid } } } } } }`,
  inspection: `{ regulatoryInspections { uid startedAt endedAt form483Issued inspectedFacility { uid } } }`,
  legacy: `{ regulatoryStatuses(where: {uid: {eq: "hu:regulatory-status:us-stelo-k234070-clearance"}}) { uid legacyHeldByConnection { edges { properties { derivationRule derivedFromAssertionUids } node { uid } } } } }`
};
for (const [k, q] of Object.entries(queries)) {
  const r = await graphql({ schema, source: q, contextValue: { executionContext: driver } });
  console.log("==", k, r.errors ? "ERRORS " + r.errors.map(e => e.message).join("; ") : JSON.stringify(r.data).slice(0, 700));
}
const m = await graphql({ schema, source: `mutation { createRegulatoryPathways(input: [{ uid: "hu:reg-pathway:probe", entityType: "REGULATORY_PATHWAY", pathwayKind: GRAS_NOTICE, jurisdiction: "US", legalBasisCitation: "x" }]) { regulatoryPathways { uid } } }`, contextValue: { executionContext: driver } });
console.log("== settable-false derived field in create input:", m.errors ? "REJECTED: " + m.errors[0].message.slice(0, 160) : "ACCEPTED (unexpected)");
await driver.close();
