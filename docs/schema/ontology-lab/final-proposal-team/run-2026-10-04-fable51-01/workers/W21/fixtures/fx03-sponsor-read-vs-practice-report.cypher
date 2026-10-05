// =====================================================================================================
// W21 fixture fx03: sponsor read versus independent practice report (round 0006 pair 23; CQ-CL-02, CQ-CL-05,
// CQ-CL-08). Two practice-shaped statements about blood testing in one episode:
//   H1: the HOST, inside the YouTube sponsor read for InsideTracker: "I've long been a believer in getting regular
//       blood work done ..." (segmentKind SPONSOR_READ);
//   G1: the GUEST, editorial conversation: "And so I've been measuring myself ... measuring 45 different things."
// Both are REPORTS_PRACTICE with PERSONAL_EXPERIENCE basis: the speech act does NOT distinguish them; the segment and
// the ConflictRelevanceAssessment do. Neither becomes an endorsement or a recommendation. G1 is also a real caption
// discrepancy case: the publisher text reads "or I know if", the YouTube caption track reads "or I think I know if"
// (a hedge present in one rendition only); neither is audio-verified.
// Predicate SELF_REPORTED_PRACTICE is a CANDIDATE (registration W21-SR-15): those occurrences are PROPOSED.
// =====================================================================================================
// ---- Base: HL52 identities, two renditions (2026-10-04 captures, PARTIAL_EXCERPT), text versions --------
MERGE (n:Entity:Person {uid: 'hu:person:andrew-d-huberman'})
SET n.id = 'andrew-d-huberman', n.entityType = 'Person', n.name = 'Andrew D. Huberman', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Person {uid: 'hu:person:david-a-sinclair'})
SET n.id = 'david-a-sinclair', n.entityType = 'Person', n.name = 'David A. Sinclair', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:ConsumerBrand {uid: 'hu:brand:insidetracker'})
SET n.id = 'insidetracker', n.entityType = 'ConsumerBrand', n.name = 'InsideTracker', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET n.id = 'huberman-lab-52-sinclair', n.entityType = 'Episode', n.name = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair',
    n.episodeNumber = 52, n.publishedAt = datetime('2021-12-27T09:00:00Z'), n.publishedAtPrecision = 'INSTANT', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Agent {uid: 'hu:agent:w21-curator'})
SET n.id = 'w21-curator', n.entityType = 'Agent', n.name = 'W21 fixture curator (Opus 5.5)', n.agentKind = 'MANUAL_AGENT', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
SET a.id = 'w21-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'EXTRACTION', a.methodVersion = 'w21-manual-curation-v0.1', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);
MERGE (a:Occurrence:Activity {uid: 'hu:activity:youtube-captioning-hl52'})
SET a.id = 'youtube-captioning-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.methodVersion = 'unknown (platform caption track)', a.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (a:Occurrence:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
SET a.id = 'hubermanlab-transcription-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.methodVersion = 'publisher transcript; stated "under human review"', a.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Source:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET n.id = 'hubermanlab-com-episode-52', n.documentId = 'hubermanlab-com-episode-52', n.entityType = 'Source',
    n.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging', n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Source {uid: 'hu:source:youtube-n9IxomBusuw'})
SET n.id = 'youtube-n9IxomBusuw', n.entityType = 'Source', n.canonicalUri = 'https://www.youtube.com/watch?v=n9IxomBusuw', n.sourceKind = 'VIDEO_RENDITION', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (s:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}) MERGE (s)-[:RENDITION_OF]->(e);
MATCH (s:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}) MERGE (s)-[:RENDITION_OF]->(e);

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (act:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
SET s.id = 'hubermanlab-52-page-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:49:30Z'), s.observedAt = datetime('2026-10-04T00:49:30Z'),
    s.contentHash = 'sha256:19e3e32cbaca1a127bebb1404237659509bd64e97066577208b25bc71278511e', s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
SET tv.id = 'hubermanlab-52-page-2026-10-04', tv.documentTextVersionId = 'hubermanlab-52-page-2026-10-04', tv.artifactType = 'DocumentTextVersion', tv.textVersionHash = s.contentHash,
    tv.source = 'publisher-transcript (excerpt)', tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (act:Activity {uid: 'hu:activity:youtube-captioning-hl52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'})
SET s.id = 'youtube-n9IxomBusuw-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:50:00Z'), s.observedAt = datetime('2026-10-04T00:50:00Z'),
    s.contentHash = 'sha256:346af1dd8abcb9f0c2adaeb4a505f5b5ae51d290282cc091c9a68cff3dfcba0f', s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
SET tv.id = 'youtube-n9IxomBusuw-captions-2026-10-04', tv.documentTextVersionId = 'youtube-n9IxomBusuw-captions-2026-10-04', tv.artifactType = 'DocumentTextVersion', tv.textVersionHash = s.contentHash,
    tv.source = 'platform caption track (excerpt)', tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

// ---- Segments ------------------------------------------------------------------------------------------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-chapter-sponsors'})
SET l.id = 'w21-hl52-youtube-chapter-sponsors', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=210s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 210.0, l.mediaEndSeconds = 465.0, l.mediaTimeBasis = 'PUBLISHER_CHAPTER', l.exact = 'ROKA, InsideTracker, Magic Spoon',
    l.quoteHash = 'sha256:c0f7b8098929e42683257d2d5b5fc6f52c0912e0850c98ef421ce22d7e714ad1', l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-chapter-sponsors'})
MERGE (g:InformationArtifact:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'})
SET g.id = 'hl52-youtube-sponsor-block', g.artifactType = 'EpisodeSegment', g.segmentType = 'SPONSOR_READ', g.chapterTitleVerbatim = 'ROKA, InsideTracker, Magic Spoon',
    g.delimitationBasis = 'PUBLISHER_CHAPTER', g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (e)-[:HAS_SEGMENT]->(g)
MERGE (g)-[:IN_RENDITION]->(src)
MERGE (g)-[:DELIMITED_BY]->(l);

MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (g:InformationArtifact:EpisodeSegment {uid: 'hu:episode-segment:hl52-chapter-resveratrol-nad-nmn'})
SET g.id = 'hl52-chapter-resveratrol-nad-nmn', g.artifactType = 'EpisodeSegment', g.segmentType = 'CHAPTER', g.chapterTitleVerbatim = 'Resveratrol, NAD, NMN, NR; Dosage, Timing',
    g.delimitationBasis = 'NOT_DELIMITED', g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (e)-[:HAS_SEGMENT]->(g);

// ---- Locators -------------------------------------------------------------------------------------------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'})
SET l.id = 'w21-hl52-youtube-insidetracker-sponsor-read', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=287s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 287.0, l.mediaEndSeconds = 295.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "Today's episode is also brought to us by InsideTracker.", l.quoteHash = "sha256:c68c127ba0e0d1b94a8a8135d2dfd87dd3d383c46d1bc9da2ab43f9598518659",
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-host-blood-work-believer'})
SET l.id = 'w21-hl52-youtube-host-blood-work-believer', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=304s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 304.0, l.mediaEndSeconds = 314.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "I've long been a believer in getting regular blood work done for the simple reason that many of the factors that impact your immediate and long-term health can only be assessed from a quality blood test.",
    l.quoteHash = "sha256:f05d334cdbed317fd4bfa2075185cf249bf03c3b306742f04f3aaf5a2e06f0da",
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-page-guest-measuring-myself'})
SET l.id = 'w21-hl52-page-guest-measuring-myself', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "And so I've been measuring myself. And so I know if something's, or I know if something's making me better or worse based on measuring 45 different things.",
    l.quoteHash = "sha256:2a87846c4555b6def1cf83a0e14342e136344af6c1156d212958cd4ff7296bc6",
    l.prefix = 'Right. ', l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-guest-measuring-myself'})
SET l.id = 'w21-hl52-youtube-guest-measuring-myself', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3788s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3788.0, l.mediaEndSeconds = 3797.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "And so I've been measuring myself and so I know if something's, or I think I know if something's making me better or worse based on measuring 45 different things.",
    l.quoteHash = "sha256:bc0d19d4339e1bbd7a500b6395e38f7c891c7c1a50992afad8973b66860919af",
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-page-insidetracker-board-disclosure'})
SET l.id = 'w21-hl52-page-insidetracker-board-disclosure', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "I was one of the first people in InsideTracker as a board member and I'm still their scientific lead guy.",
    l.quoteHash = "sha256:a301a624bb4a10b4386ebca3d99013a87a57bb554311d405ade3f18247878928",
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// ---- Occurrences --------------------------------------------------------------------------------------
// A6: the sponsorship statement itself (FINANCIAL_INTEREST member SPONSORS_CONTENT), asserted by the host.
MATCH (host:Person {uid: 'hu:person:andrew-d-huberman'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'}), (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'})
SET a.id = 'w21-hl52-youtube-host-read-insidetracker', a.predicate = 'SPONSORS_CONTENT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'UNSTATED',
    a.speechAct = 'STATES', a.segmentKind = 'SPONSOR_READ', a.validFrom = datetime('2021-12-27T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY',
    a.validToBasis = 'UNKNOWN', a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(br)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(g)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (br)-[r:SPONSORS_CONTENT {assertionUid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'}]->(ep)
SET r.relationshipUid = 'hu:rel:w21-sponsors-content-insidetracker-hl52', r.validFrom = datetime('2021-12-27T00:00:00Z'), r.validFromPrecision = 'DAY',
    r.validFromBasis = 'PUBLICATION_PROXY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:00:00Z');

// H1: host practice-shaped statement inside the sponsor read.
MATCH (host:Person {uid: 'hu:person:andrew-d-huberman'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-host-blood-work-believer'}), (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'})
SET a.id = 'w21-hl52-host-regular-blood-work', a.predicate = 'SELF_REPORTED_PRACTICE', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueString = 'regular blood work', a.segmentKind = 'SPONSOR_READ',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.statedTense = 'PRESENT', a.utteranceText = l.exact,
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(host)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(g)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// G1: guest practice report in editorial conversation, located in two renditions whose wording differs.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (l1:SourceLocator {uid: 'hu:locator:w21-hl52-page-guest-measuring-myself'}), (l2:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-guest-measuring-myself'}),
      (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-chapter-resveratrol-nad-nmn'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-guest-measures-45-things'})
SET a.id = 'w21-hl52-guest-measures-45-things', a.predicate = 'SELF_REPORTED_PRACTICE', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueString = 'self-measurement of 45 different things',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.statedTense = 'PRESENT', a.utteranceText = l1.exact,
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(g)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// D1: the guest's on-air role disclosure (inherited round 0006 span), a FINANCIAL_INTEREST role assertion.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-page-insidetracker-board-disclosure'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-guest-says-past-board-member-insidetracker'})
SET a.id = 'w21-hl52-guest-says-past-board-member-insidetracker', a.predicate = 'BOARD_MEMBER_OF', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'STATES', a.roleTitleVerbatim = 'board member', a.statedTense = 'PAST',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// ---- Conflict relevance: same tie, different relevance; neither sets truth ----------------------------
MATCH (h1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'}), (a6:Assertion {uid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'}), (cur:Agent {uid: 'hu:agent:w21-curator'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:w21-conflict-relevance-hl52-host-blood-work'})
SET c.id = 'w21-conflict-relevance-hl52-host-blood-work', c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'DIRECT', c.relevanceBasis = 'SPONSOR_OF_CONTAINER', c.temporalOverlap = 'OVERLAPS', c.disclosureFinding = 'DISCLOSED_IN_CONTAINER',
    c.summary = 'Statement made inside the paid read for the sponsor whose service it describes.',
    c.recordedAt = datetime('2026-10-04T01:00:00Z'), c.assessedAt = datetime('2026-10-04T01:00:00Z'), c.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(h1)
MERGE (c)-[:ASSESSES_INTEREST]->(a6)
MERGE (c)-[:SUPPORTED_BY]->(l)
MERGE (c)-[:ASSESSED_BY]->(cur);

MATCH (g1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-guest-measures-45-things'}), (a6:Assertion {uid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'}),
      (d1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-guest-says-past-board-member-insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-page-insidetracker-board-disclosure'}), (cur:Agent {uid: 'hu:agent:w21-curator'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:w21-conflict-relevance-hl52-guest-measuring'})
SET c.id = 'w21-conflict-relevance-hl52-guest-measuring', c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'INDIRECT', c.relevanceBasis = 'SPONSOR_OF_CONTAINER', c.temporalOverlap = 'UNKNOWN', c.disclosureFinding = 'DISCLOSED_IN_CONTAINER',
    c.scopeAmbiguity = 'Statement concerns self-measurement generally, not the sponsor brand; enum lacks a same-service-category basis (W21-SR-14). Board role stated in past tense with no dates.',
    c.recordedAt = datetime('2026-10-04T01:00:00Z'), c.assessedAt = datetime('2026-10-04T01:00:00Z'), c.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(g1)
MERGE (c)-[:ASSESSES_INTEREST]->(a6)
MERGE (c)-[:ASSESSES_INTEREST]->(d1)
MERGE (c)-[:SUPPORTED_BY]->(l)
MERGE (c)-[:ASSESSED_BY]->(cur);

MATCH (a:Assertion) WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx03-capture-fidelity-policy'})
ON CREATE SET j.id = 'w21-fx03-capture-fidelity-policy', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T01:30:00Z'),
    j.recordedAt = datetime('2026-10-04T01:30:00Z'), j.createdAt = datetime('2026-10-04T01:30:00Z'), j.privacyClass = 'internal'
MERGE (j)-[:EVALUATES]->(a);
