// W00 fixture 13 queries (read-only; load 00-common-base.cypher and 13-reconciliation-rulings.cypher first).

// Q13-a (W00-R-11, CQ-ID-04): resolve a held uid as of two recorded viewpoints. Expected: 2026-04-10 -> the held uid itself
// (redirect recorded later); 2026-10-04 -> hu:org:w00-acme-a via hu:assessment:w00-merge-acme. The malformed N1 record is ignored
// because it has no retiredUid.
UNWIND [datetime('2026-04-10T09:00:00Z'), datetime('2026-10-04T00:00:00Z')] AS viewpoint
MATCH (old {uid: 'hu:org:w00-acme-b'})
CALL (old, viewpoint) {
  OPTIONAL MATCH (e:EquivalenceAssessment {equivalenceKind: 'SAME_IDENTITY_MERGED', status: 'ACCEPTED'})-[:COMPARES_IDENTITIES]->(old)
  WHERE e.retiredUid = old.uid AND e.recordedAt <= viewpoint
  RETURN e ORDER BY e.recordedAt DESC LIMIT 1
}
RETURN toString(viewpoint) AS viewpoint, old.uid AS heldUid, coalesce(e.survivingUid, old.uid) AS resolvedUid, e.uid AS redirectRecord
ORDER BY viewpoint;

// Q13-b (W00-R-13, CQ-TM-04): did the holder hold Acme stock on V? statedAsOf is a witness instant, never a bound.
// Expected: V = 2024-08-20 -> KNOWN_AT_WITNESS (inside the DAY precision period); V = 2024-09-01 -> POSSIBLE_START_UNKNOWN
// (bounds unknown; the witness does not extend to V); the record without precision -> NOT_EVALUABLE (V-503r row).
UNWIND [datetime('2024-08-20T12:00:00Z'), datetime('2024-09-01T00:00:00Z')] AS v
MATCH (a:Assertion {predicate: 'HOLDS_EQUITY_IN'})-[:HAS_OBJECT]->(:Organization {uid: 'hu:org:w00-acme-a'})
WITH v, a, CASE a.statedAsOfPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                                 WHEN 'YEAR' THEN duration('P1Y') WHEN 'INSTANT' THEN duration('PT0S') ELSE null END AS width
RETURN toString(v) AS v, a.uid AS assertionUid,
  CASE WHEN a.statedAsOf IS NOT NULL AND width IS NULL THEN 'NOT_EVALUABLE'
       WHEN a.statedAsOf <= v AND v < a.statedAsOf + width THEN 'KNOWN_AT_WITNESS'
       WHEN a.validFrom IS NULL THEN 'POSSIBLE_START_UNKNOWN'
       ELSE 'SEE_QS-W00-P' END AS answerClass
ORDER BY v, assertionUid;
