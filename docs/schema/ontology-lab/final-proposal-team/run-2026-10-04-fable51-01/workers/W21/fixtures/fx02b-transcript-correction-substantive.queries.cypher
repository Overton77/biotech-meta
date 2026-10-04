// fx02 queries (identical for fx02a and fx02b; expected rows differ and are documented in ../06-fixtures-and-queries.md).

// Q02-1 (CQ-PV-02): the prior citation is intact: same exact text, same quote hash, same snapshot and snapshot hash,
// still cited by the original occurrence.
MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
OPTIONAL MATCH (a:ClaimOccurrence)-[:SUPPORTED_BY]->(l)
RETURN l.exact AS exact, l.quoteHash AS quoteHash, s.uid AS snapshotUid, s.contentHash AS snapshotHash, collect(a.uid + ' [' + a.status + ']') AS citedBy;

// Q02-2 (CQ-PV-02): re-finding the passage in the newest capture through REANCHORS.
MATCH (old:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
OPTIONAL MATCH (n:SourceLocator)-[r:REANCHORS]->(old)
OPTIONAL MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(n)
RETURN n.exact AS reanchoredExact, r.anchorMatch AS anchorMatch, s.retrievedAt AS newSnapshotRetrievedAt, s.contentHashBasis AS newHashBasis;

// Q02-3 (CQ-TM-02 viewpoint, CQ-PV-04): what BellLabs recorded the speaker as saying, as recorded at two dates.
UNWIND [datetime('2026-10-10T00:00:00Z'), datetime('2026-11-20T00:00:00Z')] AS R
MATCH (a:ClaimOccurrence {predicate: 'SELF_REPORTED_DAILY_INTAKE'})-[:OCCURS_IN]->(:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
WHERE a.recordedAt <= R AND (a.recordedTo IS NULL OR a.recordedTo > R)
RETURN R AS recordedAsOf, a.uid AS occurrence, a.valueNumber AS grams
ORDER BY recordedAsOf;

// Q02-4 (CQ-PV-03): text versions of the transcript page and the activity that produced each.
MATCH (:Source {uid: 'hu:source:hubermanlab-com-episode-52'})-[:HAS_TEXT_VERSION]->(tv:DocumentTextVersion)-[:TEXT_OF_SNAPSHOT]->(s:SourceSnapshot)
MATCH (tv)-[:WAS_GENERATED_BY]->(act:Activity)
RETURN tv.versionLabel AS textVersion, s.retrievedAt AS snapshotRetrievedAt, act.activityKind AS activityKind, act.methodVersion AS method
ORDER BY snapshotRetrievedAt;

// Q02-5 (QS-1a fragment): the superseded or unsuperseded original still traces to a reproducible locator.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (n:ClaimOccurrence)-[x:SUPERSEDES]->(a)
RETURN a.status AS currentStatus, l.uid AS locator, s.contentHash AS snapshotHash, src.canonicalUri AS source,
       x.supersessionKind AS supersededWith, n.valueNumber AS successorGrams;
