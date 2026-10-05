// W10 GraphQL round trip (run from the run harness directory so @neo4j/graphql 7.6.3 resolves):
//   node w10-gql-roundtrip.mjs <bolt-uri> <fragment+stubs.graphql>
import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import { graphql } from "graphql";
import neo4j from "neo4j-driver";
const [uri, sdl] = process.argv.slice(2);
const driver = neo4j.driver(uri, neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs: readFileSync(sdl, "utf8"), driver }).getSchema();
const run = async (label, source) => {
  const r = await graphql({ schema, source, contextValue: {} });
  console.log("### " + label);
  console.log(JSON.stringify(r, null, 1).slice(0, 2600));
};
await run("R1 applicability v2 with dimensions, union targets and use profile", `{
  evidenceApplicabilities(where: { uid: { eq: "hu:applicability:w10-nct02678611-1x-to-basis-current-v2" } }) {
    uid methodVersion status identityMatch doseMatch scheduleMatch overallScore
    evidenceTarget { __typename ... on StudyIntervention { uid } ... on Assertion { uid } }
    useTarget { __typename ... on FormulationVersion { uid } ... on UseContextProfile { uid } }
    forUseContext { uid servingsPerDay doseDescriptor }
    supersedes { uid }
    dimensions(where: { dimension: { in: [DOSE, SCHEDULE, MATERIAL_IDENTITY] } }) { dimension dimensionClass verdict identityLevel ratio evidenceMassBasis targetMassBasis missingFacts
      considersAssessments { __typename assessmentType methodVersion } }
  } }`);
await run("R2 synthesis versions with trigger and input edge properties", `{
  evidenceSyntheses(where: { uid: { eq: "hu:synthesis:w10-vitamin-d-ari-prevention-v3" } }) {
    uid verdict evidenceCutoff recordedAt
    assessesClaim { uid claimText }
    supersedes { uid verdict }
    triggeredByPublicationsConnection { edges { properties { criterionCode effectOnVerdict evidencePublishedAt } node { uid pmid } } }
    includesConnection { edges { properties { inputRole } node { __typename ... on Assertion { uid valueString } } } }
    strengthAssessments { scheme level methodVersion }
  } }`);
await run("R3 endpoint classifications for NADPARK outcomes", `{
  endpointClassifications(where: { classifiesOutcome: { some: { uid: { in: ["hu:outcome:nadpark-pdrp-fdg-pet", "hu:outcome:nadpark-mds-updrs"] } } } }) {
    uid endpointClass biomarkerCategory surrogateValidationLevel contextMatch } }`);
await run("M1 create applicability WITHOUT methodVersion (must be rejected by the API)", `mutation {
  createEvidenceApplicabilities(input: [{ uid: "hu:applicability:w10-gql-no-method", assessmentType: "EvidenceApplicability", status: PROPOSED, overallScore: 0.7 }]) { evidenceApplicabilities { uid } } }`);
await run("M2 try to update a judgement field (must be rejected: verdict not settable on update)", `mutation {
  updateApplicabilityDimensions(where: { uid: { eq: "hu:applicability-dimension:w10-nct02678611-1x-to-basis-current-v2-dose" } }, update: { verdict: { set: MATCH } }) { applicabilityDimensions { uid verdict } } }`);
await run("M3 try to delete an assessment (must be rejected: no delete mutation)", `mutation { deleteEvidenceApplicabilities(where: { uid: { eq: "x" } }) { nodesDeleted } }`);
await driver.close();
