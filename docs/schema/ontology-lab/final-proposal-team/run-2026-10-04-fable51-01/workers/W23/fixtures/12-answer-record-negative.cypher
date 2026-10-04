// W23 fixture 12: AnswerRecord negatives (load 00-shared-base.cypher first). Each record carries a deliberate defect.
// Expected detector rows: 06-fixtures-and-queries.md (V-121, V-W23-01a, V-W23-01b, V-W23-02, V-W23-03).

// N1: an answer log that names the asker and stores the question (the C-4 failure of round 0009).
MATCH (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-bad-asker-log'})
SET r.id = 'w23-bad-asker-log', r.occurrenceType = 'ANSWER_PUBLICATION', r.recordedAsOf = datetime('2026-04-10T09:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a',
    r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'LOCATOR', r.privacyClass = 'INTERNAL',
    r.userUid = 'hu:private-user-context:w23-0007', r.questionText = 'Is SleepWell safe for me during my night shifts?',
    r.createdAt = datetime('2026-04-12T09:05:00Z')
MERGE (r)-[c:CITES_ASSERTION]->(a)
SET c.orderIndex = 0;

// N2: an owner-private answer written into the shared graph, computed with private context, marked PUBLIC.
MATCH (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-bad-owner-private'})
SET r.id = 'w23-bad-owner-private', r.occurrenceType = 'ANSWER_PUBLICATION', r.recordedAsOf = datetime('2026-04-10T09:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a',
    r.accessTier = 'OWNER_PRIVATE', r.privateContext = 'INCLUDED_FOR_OWNER', r.traceDepth = 'LOCATOR', r.privacyClass = 'PUBLIC',
    r.createdAt = datetime('2026-04-12T09:05:00Z')
MERGE (r)-[c:CITES_ASSERTION]->(a)
SET c.orderIndex = 0;

// N3: a citation recorded after the answer's viewpoint (A2 recorded 2026-06-15; viewpoint 2026-04-10): not replayable.
MATCH (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-bad-future-citation'})
SET r.id = 'w23-bad-future-citation', r.occurrenceType = 'ANSWER_PUBLICATION', r.recordedAsOf = datetime('2026-04-10T09:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a',
    r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'LOCATOR', r.privacyClass = 'INTERNAL',
    r.publishedAt = datetime('2026-07-01T00:00:00Z'), r.createdAt = datetime('2026-07-01T00:00:00Z')
MERGE (r)-[c:CITES_ASSERTION]->(a)
SET c.orderIndex = 0;

// N4: a citation already superseded at the viewpoint (A1 superseded 2026-06-15; viewpoint 2026-07-01).
MATCH (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-bad-stale-citation'})
SET r.id = 'w23-bad-stale-citation', r.occurrenceType = 'ANSWER_PUBLICATION', r.recordedAsOf = datetime('2026-07-01T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a',
    r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'LOCATOR', r.privacyClass = 'INTERNAL',
    r.publishedAt = datetime('2026-07-01T00:10:00Z'), r.createdAt = datetime('2026-07-01T00:10:00Z')
MERGE (r)-[c:CITES_ASSERTION]->(a)
SET c.orderIndex = 0;

// N5: a traced answer without citations, without a schema digest, with a session key V-121 does not name (minimal pair to N1).
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-bad-untraced'})
SET r.id = 'w23-bad-untraced', r.occurrenceType = 'ANSWER_PUBLICATION', r.recordedAsOf = datetime('2026-04-10T09:00:00Z'),
    r.queryShapeId = 'QS-3a', r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'ADJUDICATION',
    r.privacyClass = 'INTERNAL', r.askerSessionId = 'sess-7f3a-synthetic', r.createdAt = datetime('2026-04-12T09:05:00Z');
