import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql } from "graphql";
const [sdlFile, uriFile] = process.argv.slice(2);
const typeDefs = readFileSync(sdlFile, "utf8");
const driver = neo4j.driver(readFileSync(uriFile, "utf8").trim());
const schema = await new Neo4jGraphQL({ typeDefs, driver }).getSchema();
const run = async (name, source, variableValues = {}) => {
  const r = await graphql({ schema, source, variableValues, contextValue: {} });
  console.log("### " + name + (r.errors ? " ERRORS " + JSON.stringify(r.errors.map(e => e.message)) : " OK"));
  console.log(JSON.stringify(r.data, null, 0).slice(0, 2500));
};
await run("Q-GQL-1 event clocks + causal edges", `query { events(where: { uid: { eq: "hu:event:mdgl-share-rise-2022-12" } }) {
  uid name occurrenceType startedAt startedAtPrecision startedAtBasis eventStatus
  causedByConnection { edges { properties { assertionUid basisKind speechAct recordedFrom } node { uid name } } } } }`);
await run("Q-GQL-2 approval three clocks + record", `query { events(where: { uid: { eq: "hu:event:rezdiffra-eu-conditional-authorisation" } }) {
  uid startedAt announcedAt effectiveFrom effectiveFromPrecision jurisdiction timeAssertionUid effectiveAssertionUid
  aboutConnection { edges { properties { assertionUid } node { ... on Product { uid name } } } }
  involvesConnection { edges { properties { participantRole roleTitleVerbatim } node { ... on Organization { name } } } } } }`);
await run("Q-GQL-3 conference sessions, speakers, recordings, decks, sponsors", `query { conferences { uid name startDate endDate
  hasEvents { uid name speakersConnection { edges { properties { participantRole roleTitleVerbatim } node { name } } }
    recordingsConnection { edges { properties { recordingCoverage } node { uid } } } presentedDocuments { uid name } }
  hostedByOrganizations { name } sponsoringOrganizationsConnection { edges { properties { assertionUid } node { name } } } exhibitors { name } } }`);
await run("Q-GQL-4 narrative arcs", `query { narrativeArcs { uid status methodVersion recordedAt recordedTo eventsRecordedAsOf overallScore
  includesEventsConnection { edges { properties { orderIndex } node { name } } } supersedes { uid } } }`);
await run("Q-GQL-5 impact assessments", `query { eventImpactAssessments { uid impactLevel impactDomain methodVersion assessesEvent { uid } impactOn { ... on Organization { name } } } }`);
await run("Q-GQL-6 fulltext", `query { searchEvents(phrase: "Rezdiffra") { edges { score node { uid } } } }`);
await driver.close();
