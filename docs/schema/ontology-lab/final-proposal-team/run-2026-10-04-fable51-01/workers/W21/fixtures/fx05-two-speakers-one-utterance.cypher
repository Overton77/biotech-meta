// =====================================================================================================
// W21 fixture fx05: two speakers inside one caption cue / one exchange are two ClaimOccurrences (CL-004; KCR-4.3;
// round 0006 O-14). Real exchange, episode 52:
//   publisher page:  "Andrew Huberman: So it's a gram of resveratrol and a gram of NMN.  David Sinclair: Right."
//   YouTube cue [1:02:53]: "- So it's a gram resveratrol and a gram of NMN. - Right. - Okay a thousand milligrams."
// H2 (host): a confirmation question (speechAct QUESTIONS) that restates the guest's practice; it ATTRIBUTES_TO the
// guest and is NOT an instance of the practice proposition. G2 (guest): assent = his own practice report for
// resveratrol (REPORTS_PRACTICE); its locator spans both turns. The YouTube cue carries no speaker names (turn
// dashes only); attribution there rests on the page's speaker labels.
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

MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:resveratrol'})
SET n.id = 'resveratrol', n.entityType = 'ChemicalSubstance', n.name = 'Resveratrol', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-resveratrol-daily'})
SET n.id = 'sinclair-reports-taking-1g-resveratrol-daily', n.entityType = 'Claim', n.claimText = 'David A. Sinclair reports taking about 1 g of resveratrol per day.',
    n.claimType = 'DOSING_CLAIM', n.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-page-host-gram-resveratrol-question'})
SET l.id = 'w21-hl52-page-host-gram-resveratrol-question', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "So it's a gram of resveratrol and a gram of NMN.", l.quoteHash = "sha256:13c114127bd4e32c82a191a4423c8d34afb670c2d1d9e4a2fe109cec37e58cdd",
    l.prefix = 'we take a gram of NMN every day. Andrew Huberman: ', l.suffix = ' David Sinclair: Right.',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'Andrew Huberman', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-page-guest-assents-resveratrol'})
SET l.id = 'w21-hl52-page-guest-assents-resveratrol', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "Andrew Huberman: So it's a gram of resveratrol and a gram of NMN. David Sinclair: Right.",
    l.quoteHash = "sha256:251b3d5958064f69a2ecdb9e471eb79073cc2bd5aaebbc2482749891e2da3383",
    l.suffix = ' Andrew Huberman: Okay. A thousand milligrams.',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'Andrew Huberman; David Sinclair', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-host-gram-resveratrol-question'})
SET l.id = 'w21-hl52-youtube-host-gram-resveratrol-question', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3773s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3773.0, l.mediaEndSeconds = 3778.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "So it's a gram resveratrol and a gram of NMN.", l.quoteHash = "sha256:3c8ef0d1d57a3dbec9b66d15b3f9f20d8b5ac4e0e43b43db324fcf24b57d2444",
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = NULL, l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-guest-assents-resveratrol'})
SET l.id = 'w21-hl52-youtube-guest-assents-resveratrol', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3773s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3773.0, l.mediaEndSeconds = 3778.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "- So it's a gram resveratrol and a gram of NMN. - Right.", l.quoteHash = "sha256:585266659ae0c3489b3fa123db18065936357ee492848e4d4040c5e7107d4ca0",
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = NULL, l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// H2: the host's confirmation question.
MATCH (host:Person {uid: 'hu:person:andrew-d-huberman'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (res:ChemicalSubstance {uid: 'hu:substance:resveratrol'}), (l1:SourceLocator {uid: 'hu:locator:w21-hl52-page-host-gram-resveratrol-question'}),
      (l2:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-host-gram-resveratrol-question'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-asks-gram-resveratrol'})
SET a.id = 'w21-hl52-host-asks-gram-resveratrol', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'QUESTIONS', a.reportedSpeechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l1.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(res)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:ATTRIBUTES_TO]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// G2: the guest's assent, his own practice report.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (res:ChemicalSubstance {uid: 'hu:substance:resveratrol'}),
      (l1:SourceLocator {uid: 'hu:locator:w21-hl52-page-guest-assents-resveratrol'}), (l2:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-guest-assents-resveratrol'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-resveratrol-daily'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-guest-assents-gram-resveratrol'})
SET a.id = 'w21-hl52-guest-assents-gram-resveratrol', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = 'Right.', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(res)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

MATCH (a:Assertion) WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx05-capture-fidelity-policy'})
ON CREATE SET j.id = 'w21-fx05-capture-fidelity-policy', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T01:30:00Z'),
    j.recordedAt = datetime('2026-10-04T01:30:00Z'), j.createdAt = datetime('2026-10-04T01:30:00Z'), j.privacyClass = 'internal'
MERGE (j)-[:EVALUATES]->(a);
