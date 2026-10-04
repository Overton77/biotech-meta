// W23 fixture 01: AnswerRecord replay, trace and correction reach (QUERIES ONLY; load 00-shared-base.cypher first).
// CQ-AX-01, CQ-AX-03, CQ-AX-11. Expected rows are in 06-fixtures-and-queries.md. Read-only statements.

// Q-AR-1 (CQ-AX-03): replay answer AR-1 at its stored viewpoint. For each cited assertion, re-run the QS-2a belief test
// (recorded by R, not superseded by R, valid at V) on the same subject and predicate, and read the adjudication
// reviewed by R. Expected: one row, sentence 1, replayed = cited = A1, object fv-a1 (200 mg), verdict SUPPORTED,
// reproduced true, even though A1 was corrected on 2026-06-15.
MATCH (r:AnswerRecord {uid: 'hu:answer-record:w23-ar1'})-[c:CITES_ASSERTION]->(cited:Assertion)-[:HAS_SUBJECT]->(s)
WITH r, c, cited, s, r.recordedAsOf AS R, r.validAt AS V
MATCH (a:Assertion)-[:HAS_SUBJECT]->(s)
WHERE a.predicate = cited.predicate AND a.recordedAt <= R
  AND NOT EXISTS { MATCH (b:Assertion)-[sup:SUPERSEDES]->(a) WHERE sup.recordedAt <= R }
  AND (a.validFrom IS NULL OR a.validFrom <= V) AND (a.validTo IS NULL OR V < a.validTo)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
CALL (a, R) {
  OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
  WHERE j.reviewedAt <= R
  WITH j ORDER BY j.reviewedAt DESC LIMIT 1
  RETURN j.verdict AS verdict, j.uid AS adjudicationUid
}
RETURN c.orderIndex AS sentence, cited.uid AS citedUid, a.uid AS replayedAssertionUid, o.uid AS objectUid,
       verdict, adjudicationUid, a.uid = cited.uid AS reproduced
ORDER BY sentence;

// Q-AR-2 (CQ-AX-03 comparison run, CQ-AX-11): the same replay at R = 2026-10-04 (now). Expected: one row, replayed A2
// (object fv-a1c, 120 mg), verdict SUPPORTED (cf-a2), reproduced false: the published answer would read differently now.
MATCH (r:AnswerRecord {uid: 'hu:answer-record:w23-ar1'})-[c:CITES_ASSERTION]->(cited:Assertion)-[:HAS_SUBJECT]->(s)
WITH r, c, cited, s, datetime('2026-10-04T00:00:00Z') AS R, r.validAt AS V
MATCH (a:Assertion)-[:HAS_SUBJECT]->(s)
WHERE a.predicate = cited.predicate AND a.recordedAt <= R
  AND NOT EXISTS { MATCH (b:Assertion)-[sup:SUPERSEDES]->(a) WHERE sup.recordedAt <= R }
  AND (a.validFrom IS NULL OR a.validFrom <= V) AND (a.validTo IS NULL OR V < a.validTo)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
CALL (a, R) {
  OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
  WHERE j.reviewedAt <= R
  WITH j ORDER BY j.reviewedAt DESC LIMIT 1
  RETURN j.verdict AS verdict, j.uid AS adjudicationUid
}
RETURN c.orderIndex AS sentence, cited.uid AS citedUid, a.uid AS replayedAssertionUid, o.uid AS objectUid,
       verdict, adjudicationUid, a.uid = cited.uid AS reproduced
ORDER BY sentence;

// Q-AR-3 (CQ-AX-11): which published answers depend on assertion A1, and was A1 corrected after their viewpoint?
// Expected: one row, AR-1, superseded by A2 (SOURCE_CORRECTION, learned 2026-06-15T08:10Z), correctedAfterViewpoint true.
// AR-2 (cites A2) is not returned.
MATCH (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})<-[:CITES_ASSERTION]-(r:AnswerRecord)
OPTIONAL MATCH (newer:Assertion)-[s:SUPERSEDES]->(a)
RETURN r.uid AS answerRecordUid, r.recordedAsOf AS recordedAsOf, r.publishedAt AS publishedAt, newer.uid AS supersededBy,
       s.supersessionKind AS supersessionKind, s.recordedAt AS learnedAt, s.recordedAt > r.recordedAsOf AS correctedAfterViewpoint;

// Q-AR-3b (CQ-AX-11, whole graph): every published answer that cites an assertion superseded after the answer's own
// viewpoint (the correction-reach queue). Expected: one row (AR-1, A1, A2, SOURCE_CORRECTION).
MATCH (r:AnswerRecord)-[:CITES_ASSERTION]->(a:Assertion)<-[s:SUPERSEDES]-(newer:Assertion)
WHERE s.recordedAt > r.recordedAsOf
RETURN r.uid AS answerRecordUid, a.uid AS citedAssertionUid, newer.uid AS supersededBy, s.supersessionKind AS supersessionKind
ORDER BY answerRecordUid;

// Q-AR-4 (CQ-AX-01, traceDepth ADJUDICATION): per cited sentence, the locator and snapshot retrieved by R and the
// adjudications reviewed by R, with named gaps. Expected: one row, sentence 1, A1, one TEXT_QUOTE locator
// ('Magnesium (as magnesium glycinate) 200 mg') in snapshot 2026-03-02 with its contentHash, one CAPTURE_FIDELITY
// SUPPORTED adjudication, gaps [].
MATCH (r:AnswerRecord {uid: 'hu:answer-record:w23-ar1'})-[c:CITES_ASSERTION]->(a:Assertion)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE sn.retrievedAt <= r.recordedAsOf
WITH r, c, a, collect(CASE WHEN l IS NULL THEN null ELSE {locator: l.uid, selectorKind: l.selectorKind, exact: l.exact,
     snapshot: sn.uid, contentHash: sn.contentHash, retrievedAt: sn.retrievedAt} END) AS locators
OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
WHERE j.reviewedAt <= r.recordedAsOf
WITH r, c, a, locators, collect(CASE WHEN j IS NULL THEN null ELSE {adjudication: j.uid, kind: j.adjudicationKind,
     verdict: j.verdict, reviewedAt: j.reviewedAt} END) AS adjudications
RETURN c.orderIndex AS sentence, a.uid AS assertionUid, a.predicate AS predicate, locators, adjudications,
       [g IN [CASE WHEN size(locators) = 0 THEN 'NO_LOCATOR_AS_OF_R' END,
              CASE WHEN size(adjudications) = 0 THEN 'NO_ADJUDICATION_AS_OF_R' END] WHERE g IS NOT NULL] AS gaps
ORDER BY sentence;

// Q-AR-5 (PUBLIC_ANSWER closure for an INTERNAL AnswerRecord): the reproducibility allow-list view. Expected: one row with
// exactly the allow-listed keys; no mongoResearchRunId, privacyClass, createdAt or Activity lineage leaves the graph.
MATCH (r:AnswerRecord {uid: 'hu:answer-record:w23-ar1'})
OPTIONAL MATCH (r)-[c:CITES_ASSERTION]->(a:Assertion)
OPTIONAL MATCH (r)-[d:CITES_ASSESSMENT]->(e:EvidenceAssessment)
WITH r, collect(DISTINCT {ordinal: c.orderIndex, assertionUid: a.uid}) AS citedAssertions,
        collect(DISTINCT {ordinal: d.orderIndex, assessmentUid: e.uid}) AS citedAssessments
RETURN r {.uid, .recordedAsOf, .validAt, .intervalStart, .intervalEnd, .schemaDigest, .queryShapeId, .queryShapeVersion,
          .accessTier, .traceDepth, .publishedAt, citedAssertions: citedAssertions, citedAssessments: citedAssessments} AS publicReproducibilityView;
