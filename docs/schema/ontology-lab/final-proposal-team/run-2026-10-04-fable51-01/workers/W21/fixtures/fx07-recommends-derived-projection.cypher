// =====================================================================================================
// W21 fixture fx07 (fully SYNTHETIC): a legitimate derived RECOMMENDS projection (CL-016) written with the frozen
// DerivedEdgeProperties (D-011: derivationRule + derivedFromAssertionUids, no assertionUid). Expected:
// V-W21-06 returns 0 rows; the VERBATIM baseline V-423 returns 1 row because it reads rec.assertionUid only.
// That row is the failing case behind seam request W21-SR-07 (amend V-423 or rule RECOMMENDS asserted-class).
// Synthetic people, episode and outlet use .invalid domains; nothing here is attributed to a real person.
// =====================================================================================================
MERGE (n:Entity:Person {uid: 'hu:person:synthetic-podcast-guest'})
SET n.id = 'synthetic-podcast-guest', n.entityType = 'Person', n.name = 'Synthetic Podcast Guest (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:synthetic-compound-x'})
SET n.id = 'synthetic-compound-x', n.entityType = 'ChemicalSubstance', n.name = 'Compound X (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Episode {uid: 'hu:episode:synthetic-podcast-episode-7'})
SET n.id = 'synthetic-podcast-episode-7', n.entityType = 'Episode', n.name = 'Synthetic Podcast, episode 7 (fixture only)', n.episodeType = 'FULL',
    n.publishedAt = datetime('2026-09-01T00:00:00Z'), n.publishedAtPrecision = 'DAY', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Source {uid: 'hu:source:synthetic-podcast-episode-7-video'})
SET n.id = 'synthetic-podcast-episode-7-video', n.entityType = 'Source', n.canonicalUri = 'https://video.example.invalid/synthetic-podcast-7', n.sourceKind = 'VIDEO_RENDITION',
    n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (s:Source {uid: 'hu:source:synthetic-podcast-episode-7-video'}), (e:Episode {uid: 'hu:episode:synthetic-podcast-episode-7'}) MERGE (s)-[:RENDITION_OF]->(e);
MATCH (src:Source {uid: 'hu:source:synthetic-podcast-episode-7-video'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-podcast-episode-7-video-2026-10-04'})
SET s.id = 'synthetic-podcast-episode-7-video-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:00:00Z'),
    s.observedAt = datetime('2026-10-04T00:00:00Z'), s.contentHash = 'sha256:3b69f2bd44316c4e002e36b7288cacee05c943d0d8b85bb85656893db8f54434', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
    s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-podcast-episode-7-video-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-podcast-7-recommends-compound-x'})
SET l.id = 'synthetic-podcast-7-recommends-compound-x', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'MEDIA_TIME', l.mediaStartSeconds = 1200.0,
    l.mediaEndSeconds = 1206.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE', l.exact = 'If you are over fifty, take Compound X every morning.',
    l.quoteHash = 'sha256:06097447fb32554b6a42d0944e2fee0ba564a0a6f6fe52d99e8726a8a979e58c', l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);
MATCH (sp:Person {uid: 'hu:person:synthetic-podcast-guest'}), (ep:Episode {uid: 'hu:episode:synthetic-podcast-episode-7'}), (x:ChemicalSubstance {uid: 'hu:substance:synthetic-compound-x'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-podcast-7-recommends-compound-x'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-guest-recommends-compound-x'})
SET a.id = 'synthetic-guest-recommends-compound-x', a.predicate = 'RECOMMENDS_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.assertionBasis = 'EXPERT_OPINION',
    a.speechAct = 'RECOMMENDS', a.valueString = 'every morning, if over fifty', a.validFrom = datetime('2026-09-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY',
    a.validToBasis = 'UNKNOWN', a.utteranceText = l.exact, a.fixtureProvenance = 'SYNTHETIC', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(x)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l);
// The derived projection (DerivedEdgeProperties only).
MATCH (sp:Person {uid: 'hu:person:synthetic-podcast-guest'}), (x:ChemicalSubstance {uid: 'hu:substance:synthetic-compound-x'})
MERGE (sp)-[r:RECOMMENDS {derivationRule: 'speech-act-recommends-projection-v1'}]->(x)
SET r.derivedFromAssertionUids = ['hu:claim-occurrence:synthetic-guest-recommends-compound-x'], r.derivedAt = datetime('2026-10-04T01:05:00Z');
