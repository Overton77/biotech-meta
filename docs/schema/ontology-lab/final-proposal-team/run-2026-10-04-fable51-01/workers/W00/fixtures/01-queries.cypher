// Queries over fixture 01 (minimal pair 8). Each statement is self-contained; viewpoints are literals.
// Expected results: 06-fixtures-and-queries.md §3.1.

// Q01-a CQ-TM-01 / QS-2b edge-level as-of for both variants at V = 2026-04-01, R = 2026-05-01 (before both changes).
UNWIND ['hu:product-variant:w00-pair8-a-us-capsule', 'hu:product-variant:w00-pair8-b-us-powder'] AS vu
MATCH (v:ProductVariant {uid: vu})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WITH v, r, f, datetime('2026-05-01T00:00:00Z') AS R, datetime('2026-04-01T00:00:00Z') AS V
WHERE r.recordedFrom <= R AND (r.recordedTo IS NULL OR R < r.recordedTo)
  AND (r.validFrom IS NULL OR r.validFrom <= V) AND (r.validTo IS NULL OR V < r.validTo)
RETURN 'Q01-a' AS q, v.uid AS variant, f.uid AS formulation, r.assertionUid AS authorizedBy ORDER BY variant;

// Q01-b same V = 2026-04-01, R = 2026-07-01 (after the erratum and after the reformulation were recorded).
UNWIND ['hu:product-variant:w00-pair8-a-us-capsule', 'hu:product-variant:w00-pair8-b-us-powder'] AS vu
MATCH (v:ProductVariant {uid: vu})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WITH v, r, f, datetime('2026-07-01T00:00:00Z') AS R, datetime('2026-04-01T00:00:00Z') AS V
WHERE r.recordedFrom <= R AND (r.recordedTo IS NULL OR R < r.recordedTo)
  AND (r.validFrom IS NULL OR r.validFrom <= V) AND (r.validTo IS NULL OR V < r.validTo)
RETURN 'Q01-b' AS q, v.uid AS variant, f.uid AS formulation, r.assertionUid AS authorizedBy, r.validTo AS validTo ORDER BY variant;

// Q01-c V = 2026-07-01, R = 2026-07-01.
UNWIND ['hu:product-variant:w00-pair8-a-us-capsule', 'hu:product-variant:w00-pair8-b-us-powder'] AS vu
MATCH (v:ProductVariant {uid: vu})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WITH v, r, f, datetime('2026-07-01T00:00:00Z') AS R, datetime('2026-07-01T00:00:00Z') AS V
WHERE r.recordedFrom <= R AND (r.recordedTo IS NULL OR R < r.recordedTo)
  AND (r.validFrom IS NULL OR r.validFrom <= V) AND (r.validTo IS NULL OR V < r.validTo)
RETURN 'Q01-c' AS q, v.uid AS variant, f.uid AS formulation ORDER BY variant;

// Q01-d CQ-TM-07: was it a correction or a fact ending? For every superseded assertion, the supersession kind
// and whether the OLD state still has a currently recorded attachment (fact ending) or none (correction).
MATCH (newer:Assertion)-[s:SUPERSEDES]->(older:Assertion)-[:HAS_SUBJECT]->(subj)
MATCH (older)-[:HAS_OBJECT]->(oldState)
OPTIONAL MATCH (subj)-[cur]->(oldState)
WHERE type(cur) = older.predicate AND cur.recordedTo IS NULL
WITH s, older, newer, subj, oldState, collect(cur) AS currentEpisodes
RETURN 'Q01-d' AS q, subj.uid AS subject, s.supersessionKind AS kind, s.sourceRevisionEventUid AS revisionEvent,
       oldState.uid AS oldState, size(currentEpisodes) > 0 AS oldStateStillAttached,
       CASE WHEN s.supersessionKind = 'SOURCE_CORRECTION' AND size(currentEpisodes) = 0 THEN 'CORRECTED_RECORD_NEVER_HELD'
            WHEN s.supersessionKind = 'VALIDITY_BOUNDED' AND size(currentEpisodes) > 0 THEN 'FACT_ENDED_STATE_KEPT_FOR_BOUNDED_INTERVAL'
            ELSE 'INCONSISTENT' END AS reading
ORDER BY subject;

// Q01-e CQ-EV-05 / CQ-TM-01 historical status at R from records (status is a cache): assertion A1 at R = 2026-04-10
// was the accepted belief; at R = 2026-07-01 it is superseded. Both remain in the graph.
UNWIND [datetime('2026-04-10T00:00:00Z'), datetime('2026-07-01T00:00:00Z')] AS R
MATCH (a:Assertion {uid: 'hu:assertion:w00-pair8-a1'})
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a)
WHERE j.recordedAt <= R
WITH R, a, j ORDER BY j.recordedAt DESC
WITH R, a, collect(j)[0] AS latest
RETURN 'Q01-e' AS q, toString(R) AS recordedAsOf, a.status AS currentStatusCache,
       CASE WHEN a.recordedTo IS NOT NULL AND a.recordedTo <= R THEN 'SUPERSEDED'
            WHEN latest IS NULL THEN 'EXTRACTED'
            WHEN latest.verdict = 'SUPPORTED' THEN 'ACCEPTED'
            WHEN latest.verdict = 'CONTRADICTED' THEN 'REJECTED' ELSE 'UNRESOLVED' END AS statusAsOfR
ORDER BY recordedAsOf;

// Q01-f CQ-TM-06: which assertions relied on the prior snapshot of a revised source, and what superseded them.
MATCH (ev:SourceRevisionEvent {uid: 'hu:source-revision:w00-pair8-a-erratum-2026-06'})-[:PRIOR_SNAPSHOT]->(sn:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
OPTIONAL MATCH (newer:Assertion)-[s:SUPERSEDES]->(a)
RETURN 'Q01-f' AS q, ev.revisionKind AS revisionKind, toString(ev.occurredAt) AS publisherTime, toString(ev.recordedAt) AS learnedAt,
       a.uid AS affectedAssertion, newer.uid AS supersededBy, s.supersessionKind AS supersessionKind;
