// Queries over fixture 02 (late-arriving fact). "now" = datetime() at query time (after the fixture committed).
// Expected results: 06-fixtures-and-queries.md §3.2.

// Q02-a CQ-TM-02: the same V asked on two recorded dates. At R = 2026-04-10 the 2019 formulation is invisible
// (BellLabs did not know it); at R = now it is visible. Valid time was never moved.
UNWIND [['R=2026-04-10', datetime('2026-04-10T00:00:00Z')], ['R=now', datetime()]] AS vp
CALL {
  WITH vp
  OPTIONAL MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-late-us-capsule'})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
  WHERE r.recordedFrom <= vp[1] AND (r.recordedTo IS NULL OR vp[1] < r.recordedTo)
    AND (r.validFrom IS NULL OR r.validFrom <= datetime('2021-06-01T00:00:00Z'))
    AND (r.validTo IS NULL OR datetime('2021-06-01T00:00:00Z') < r.validTo)
  RETURN collect(f.uid) AS formulationsValidAt2021
}
RETURN 'Q02-a' AS q, vp[0] AS viewpoint, formulationsValidAt2021;

// Q02-b CQ-TM-03: the clocks of the late fact stay distinct; recordedAt is the commit, never the archive time.
MATCH (a:Assertion {uid: 'hu:assertion:w00-late-2019'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
MATCH (:ProductVariant)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w00-late-e-2019'}]->()
RETURN 'Q02-b' AS q, toString(a.validFrom) AS validFrom, a.validFromPrecision AS vfPrecision, a.validFromBasis AS vfBasis,
       toString(a.validTo) AS validTo, a.validToBasis AS vtBasis, a.derivationRule AS rule,
       toString(s.observedAt) AS archiveObservedAt, s.retrievedAt.year AS retrievedYear, a.recordedAt.year AS recordedYear,
       h.recordedFrom = a.recordedAt AS episodeRecordedFromEqualsAssertionRecordedAt,
       a.recordedAt >= s.retrievedAt AS notBeforeRetrieval;

// Q02-c QS-2c: what was learned between R1 = 2026-04-10 and R2 = now (BELIEF_ADDED rows; nothing closed).
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-late-us-capsule'})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WITH f, r, datetime('2026-04-10T00:00:00Z') AS R1, datetime() AS R2
WITH f, r, (r.recordedFrom > R1 AND r.recordedFrom <= R2) AS added,
     (r.recordedTo IS NOT NULL AND r.recordedTo > R1 AND r.recordedTo <= R2) AS closed
WHERE added OR closed
RETURN 'Q02-c' AS q, f.uid AS formulation, toString(r.validFrom) AS validFrom, toString(r.validTo) AS validTo, added, closed
ORDER BY formulation;

// Q02-d QS-W00-P precision-aware class at V for the late fact (start bound is YEAR 2019): inside 2019 POSSIBLE,
// after the start year and before the inferred end KNOWN_WITHIN, inside the end month POSSIBLE_END.
UNWIND [datetime('2018-06-01T00:00:00Z'), datetime('2019-06-01T00:00:00Z'), datetime('2021-06-01T00:00:00Z'),
        datetime('2025-11-15T00:00:00Z'), datetime('2025-12-15T00:00:00Z')] AS V
MATCH (a:Assertion {uid: 'hu:assertion:w00-late-2019'})
WITH V, a,
  CASE a.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS fromLen,
  CASE a.validToPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS toLen
RETURN 'Q02-d' AS q, toString(V) AS validAt,
  CASE WHEN a.validFrom IS NOT NULL AND V < a.validFrom THEN 'KNOWN_NOT_VALID'
       WHEN a.validTo IS NOT NULL AND V >= a.validTo + toLen THEN 'KNOWN_NOT_VALID'
       WHEN a.validFrom IS NULL OR V < a.validFrom + fromLen THEN 'POSSIBLE_START_UNCERTAIN'
       WHEN a.validTo IS NOT NULL AND V >= a.validTo THEN 'POSSIBLE_END_UNCERTAIN'
       WHEN a.validTo IS NULL THEN 'OPEN_END'
       ELSE 'KNOWN_WITHIN' END AS validityClass
ORDER BY validAt;
