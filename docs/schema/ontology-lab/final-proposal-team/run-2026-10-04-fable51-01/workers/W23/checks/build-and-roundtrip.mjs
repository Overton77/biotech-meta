// W23 build and round-trip check. Usage (from a directory with @neo4j/graphql 7.6.3, graphql 16.14.2, neo4j-driver 6.2.0):
//   node build-and-roundtrip.mjs <build-stub.graphql> <sdl-fragment.graphql> <bolt.uri file> [out.json]
// 1. parses stub + fragment with graphql-js; 2. builds the actual Neo4jGraphQL schema (directives active);
// 3. lists generated root fields for W23 types (insert-only check); 4. seeds three citation targets with Cypher;
// 5. creates one AnswerRecord through the generated mutation, connecting interface-typed citations with edge
//    properties; 6. reads it back (interface resolution, edge orderIndex); 7. cleans up its own nodes.
import { readFileSync, writeFileSync } from "node:fs";
import { Neo4jGraphQL } from "@neo4j/graphql";
import neo4j from "neo4j-driver";
import { graphql, parse } from "graphql";
const [stubF, fragF, uriF, outF] = process.argv.slice(2);
const typeDefs = readFileSync(stubF, "utf8") + "\n" + readFileSync(fragF, "utf8");
const out = { parse: null, build: null, rootFields: {}, roundTrip: {} };
parse(typeDefs); out.parse = "ok";
const uri = readFileSync(uriF, "utf8").trim();
const driver = neo4j.driver(uri, neo4j.auth.none());
const schema = await new Neo4jGraphQL({ typeDefs, driver }).getSchema();
out.build = "ok";
const q = Object.keys(schema.getQueryType().getFields());
const m = Object.keys(schema.getMutationType().getFields());
for (const t of ["AnswerRecord", "PolicyVersion", "DecisionCriterion"]) {
  const re = new RegExp(t === "DecisionCriterion" ? "decisionCriteri" : t, "i");
  out.rootFields[t] = { queries: q.filter(f => re.test(f)), mutations: m.filter(f => re.test(f)) };
}
const s = driver.session();
await s.run(`MATCH (n) WHERE n.uid STARTS WITH 'hu:' AND n.uid CONTAINS ':w23-rt-' DETACH DELETE n`);
await s.run(`CREATE (:Assertion {id:'w23-rt-a1', uid:'hu:assertion:w23-rt-a1', predicate:'HAS_FORMULATION_VERSION', status:'ACCEPTED', recordedAt: datetime('2026-03-02T10:10:00Z')})`);
await s.run(`CREATE (:ClaimOccurrence:Assertion {id:'w23-rt-co1', uid:'hu:claim-occurrence:w23-rt-co1', predicate:'RECOMMENDS', status:'ACCEPTED', recordedAt: datetime('2026-02-02T00:00:00Z')})`);
await s.run(`CREATE (:Adjudication:EvidenceAssessment {id:'w23-rt-adj1', uid:'hu:adjudication:w23-rt-adj1', assessmentType:'ADJUDICATION', methodVersion:'m1', status:'ACCEPTED', recordedAt: datetime('2026-03-02T10:20:00Z'), verdict:'SUPPORTED'})`);
const create = `mutation {
  createAnswerRecords(input: [{
    uid: "hu:answer-record:w23-rt-ar1", occurrenceType: "ANSWER_PUBLICATION", privacyClass: INTERNAL,
    recordedAsOf: "2026-04-10T09:00:00Z", validAt: "2026-04-10T09:00:00Z",
    schemaDigest: "sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0",
    queryShapeId: "QS-2a", accessTier: PUBLIC_ANSWER, privateContext: EXCLUDED, traceDepth: ADJUDICATION,
    citesAssertions: { connect: [
      { where: { node: { uid: { eq: "hu:assertion:w23-rt-a1" } } }, edge: { orderIndex: 1 } },
      { where: { node: { uid: { eq: "hu:claim-occurrence:w23-rt-co1" } } }, edge: { orderIndex: 2 } } ] },
  }]) { answerRecords { uid accessTier privateContext } }
}`;
const r1 = await graphql({ schema, source: create, contextValue: {} });
out.roundTrip.create = r1.errors ? r1.errors.map(e => e.message) : r1.data;
const connAss = `mutation { createAnswerRecords(input: [{ uid: "hu:answer-record:w23-rt-ar2", occurrenceType: "ANSWER_PUBLICATION",
  recordedAsOf: "2026-04-10T09:00:00Z", schemaDigest: "sha256:x", queryShapeId: "QS-1a", accessTier: PUBLIC_ANSWER, privateContext: EXCLUDED,
  citesAssessments: { connect: [ { where: { node: { uid: { eq: "hu:adjudication:w23-rt-adj1" } } }, edge: { orderIndex: 1 } } ] } }]) { answerRecords { uid } } }`;
const r1b = await graphql({ schema, source: connAss, contextValue: {} });
out.roundTrip.connectAssessmentByUidThroughInterface = r1b.errors ? r1b.errors.map(e => e.message) : r1b.data;
await s.run(`MATCH (r:AnswerRecord {uid:'hu:answer-record:w23-rt-ar1'}), (j:Adjudication {uid:'hu:adjudication:w23-rt-adj1'}) MERGE (r)-[:CITES_ASSESSMENT {orderIndex: 1}]->(j)`);
const read = `query { answerRecords(where: { uid: { eq: "hu:answer-record:w23-rt-ar1" } }) {
  uid accessTier privateContext traceDepth
  citesAssertions { __typename uid predicate }
  citesAssertionsConnection { edges { properties { orderIndex } node { __typename uid } } }
  citesAssessments { __typename assessmentType ... on Adjudication { uid verdict } ... on EvidenceApplicability { uid } }
} }`;
const r2 = await graphql({ schema, source: read, contextValue: {} });
out.roundTrip.read = r2.errors ? r2.errors.map(e => e.message) : r2.data;
// DateTime output: the generated Cypher formats DateTime with apoc.date.convertFormat (APOC required); probe it separately.
const r2b = await graphql({ schema, source: `query { answerRecords(where: { uid: { eq: "hu:answer-record:w23-rt-ar1" } }) { recordedAsOf } }`, contextValue: {} });
out.roundTrip.readDateTime = r2b.errors ? r2b.errors.map(e => e.message.split("\n")[0]) : r2b.data;
const upd = `mutation { updateAnswerRecords(where: { uid: { eq: "hu:answer-record:w23-rt-ar1" } }, update: { queryShapeId: { set: "QS-9" } }) { answerRecords { uid } } }`;
const r3 = await graphql({ schema, source: upd, contextValue: {} });
out.roundTrip.updateAttempt = r3.errors ? r3.errors.map(e => e.message) : r3.data;
const stored = await s.run(`MATCH (r:AnswerRecord {uid:'hu:answer-record:w23-rt-ar1'}) RETURN labels(r) AS labels, r.accessTier AS accessTier, r.privacyClass AS privacyClass, r.privateContext AS privateContext, r.id IS NOT NULL AS hasId, r.createdAt IS NOT NULL AS hasCreatedAt`);
out.roundTrip.storedNode = stored.records.map(x => x.toObject());
await s.run(`MATCH (n) WHERE n.uid CONTAINS ':w23-rt-' DETACH DELETE n`);
await s.close(); await driver.close();
const json = JSON.stringify(out, null, 1);
if (outF) writeFileSync(outF, json);
console.log(json);
