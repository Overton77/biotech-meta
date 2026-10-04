// W17 GraphQL round-trip (run from the harness directory that has @neo4j/graphql 7.6.3 installed):
//   node graphql-roundtrip.mjs <bolt-uri-file> <combined.graphql>   where combined = build-stubs.graphql + ../sdl-fragment.graphql
// Reads fixture data through the generated API: signal subjects/inputs with edge properties, constraint scopes with
// dose bands, interaction assertions resolved to constraints. Read-only.
import { readFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import { graphql } from "graphql";
import neo4j from "neo4j-driver";
const [uriFile, sdlFile] = process.argv.slice(2);
const driver = neo4j.driver(readFileSync(uriFile, "utf8").trim(), neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs: readFileSync(sdlFile, "utf8"), driver }).getSchema();
const q = `{
  safetySignals(where: { uid: { eq: "hu:safety-signal:w17-nrpt-gi-tolerability-v2" } }) {
    uid methodVersion signalStatus severity legacyEvidenceStrengthHint
    subjectsConnection { edges { properties { subjectRole doseText } node { __typename ... on IngredientMaterial { uid name } } } }
    relatesToEffects { uid name affectsOrgans { uid name } }
    basedOnConnection { edges { properties { aeReportedStatus inputRole } node { __typename ... on StudyResult { uid } ... on Study { uid } ... on Assertion { uid } } } }
    supersedes { uid signalStatus }
  }
  useConstraints(where: { uid: { eq: "hu:use-constraint:simvastatin-with-niacin-1g-chinese" } }) {
    uid identityKeyVersion
    constrainsUseOf { __typename ... on ChemicalSubstance { uid } }
    scopeConnection { edges { properties { scopeRole doseComparator doseValue doseUnitCode doseQuantityBasis } node { __typename ... on ChemicalSubstance { uid } ... on UseContextProfile { uid } } } }
    contraindicationAssertions { uid constraintLevel levelVerbatim populationScopeText }
  }
  interactionAssertions(where: { polarity: { eq: UNKNOWN } }) {
    uid polarity basisKind interactionMechanism useConstraint { uid }
    subject { __typename ... on IngredientMaterial { uid } } object { __typename ... on ChemicalSubstance { uid } }
  }
  searchSafetySignals(phrase: "hyperkalemia") { edges { score node { uid signalStatus } } }
}`;
const r = await graphql({ schema, source: q, contextValue: {} });
console.log(JSON.stringify(r, null, 1));
await driver.close();
