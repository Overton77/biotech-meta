// Queries over fixture 03 (year precision). Expected: 06-fixtures-and-queries.md §3.3.

// Q03-a QS-W00-P (candidate shape): precision-aware validity class at V, R = now, for the board and advisor roles.
// V = 2021-12-27 is the publication date of Huberman Lab episode 52 (round 0006 case packet).
UNWIND [datetime('2010-06-01T00:00:00Z'), datetime('2011-06-15T00:00:00Z'), datetime('2014-06-01T00:00:00Z'),
        datetime('2017-06-01T00:00:00Z'), datetime('2018-02-01T00:00:00Z'), datetime('2021-12-27T00:00:00Z')] AS V
MATCH (a:Assertion)-[:HAS_SUBJECT]->(:Person {uid: 'hu:person:w00-david-a-sinclair'})
WHERE a.predicate IN ['BOARD_MEMBER_OF', 'ADVISES_ORGANIZATION'] AND a.recordedAt <= datetime()
  AND (a.recordedTo IS NULL OR a.recordedTo > datetime())
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
  RETURN max(sn.observedAt) AS lastObservedAt
}
WITH V, a, lastObservedAt,
  CASE a.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS fromLen,
  CASE a.validToPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS toLen
RETURN 'Q03-a' AS q, a.predicate AS predicate, toString(V) AS validAt,
  CASE WHEN a.validFrom IS NOT NULL AND V < a.validFrom THEN 'KNOWN_NOT_VALID'
       WHEN a.validTo IS NOT NULL AND V >= a.validTo + toLen THEN 'KNOWN_NOT_VALID'
       WHEN a.validFrom IS NULL OR V < a.validFrom + fromLen THEN 'POSSIBLE_START_UNCERTAIN'
       WHEN a.validTo IS NOT NULL AND V >= a.validTo THEN 'POSSIBLE_END_UNCERTAIN'
       WHEN a.validTo IS NULL AND lastObservedAt IS NOT NULL AND lastObservedAt >= V THEN 'OPEN_END_SUPPORTED'
       WHEN a.validTo IS NULL THEN 'OPEN_END_STALE'
       ELSE 'KNOWN_WITHIN' END AS precisionAwareClass,
  CASE WHEN a.validFrom IS NOT NULL AND a.validFrom > V THEN 'EXCLUDED'
       WHEN a.validTo IS NOT NULL AND a.validTo <= V THEN 'EXCLUDED'
       WHEN a.validTo IS NOT NULL THEN 'KNOWN_WITHIN'
       ELSE 'OPEN_END' END AS precisionBlindQs2aClass
ORDER BY predicate, validAt;

// Q03-b CQ-EV-01/CQ-PV-01 states 1-2 for the board assertion: who said it, exact span, snapshot reproducibility.
MATCH (a:Assertion {uid: 'hu:assertion:w00-sinclair-board-segterra'})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(by)
RETURN 'Q03-b' AS q, a.predicate AS predicate, a.roleCodeVerbatim AS roleCode, by.uid AS assertedBy, l.selectorKind AS selectorKind,
       l.exact AS exact, l.quoteHash AS quoteHash, s.contentHashBasis AS hashBasis, s.captureCompleteness AS completeness,
       src.canonicalUri AS canonicalUri, src.sourceKind AS sourceKind, a.status AS captureStatus;
