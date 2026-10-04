// =====================================================================
// W19 fixture 02: primary source versus retelling (CQ-PV-05, CQ-AX-05, CQ-PV-04).
// Depends on fixture 01 (Episode hu:episode:huberman-lab-52-sinclair and its rendition Sources).
//
// Real (NEW_RETRIEVAL 2026-10-04, Tavily extract): the publisher transcript page and the YouTube caption
// track both render the same utterances of episode 52, with different words:
//   transcript: "And so I know if something's, or I know if something's making me better or worse ..."
//   captions:   "... and so I know if something's, or I think I know if something's making me better or worse ..."
// Neither text is verified against audio. One ClaimOccurrence, two locators on two renditions.
// SYNTHETIC: the newsletter retelling (fictional outlet) and a second-hand retelling of that retelling.
// Snapshots of real pages hash the stored excerpt files in ./excerpts (basis STORED_EXCERPT_TEXT, NFC-WS1).
// =====================================================================

MERGE (p:Person:Entity {uid: 'hu:person:david-a-sinclair'})
SET p.entityType = 'Person', p.name = 'David A. Sinclair', p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (p:Person:Entity {uid: 'hu:person:synthetic-digest-author'})
SET p.entityType = 'Person', p.name = 'Synthetic Digest Author (fixture only)', p.fixtureProvenance = 'SYNTHETIC', p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (p:Person:Entity {uid: 'hu:person:synthetic-aggregator-editor'})
SET p.entityType = 'Person', p.name = 'Synthetic Aggregator Editor (fixture only)', p.fixtureProvenance = 'SYNTHETIC', p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (a:Agent:Entity {uid: 'hu:agent:tavily-extract'})
SET a.entityType = 'Agent', a.name = 'Tavily extract API', a.agentKind = 'AUTOMATED_AGENT', a.toolVersion = 'unknown', a.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (a:Agent:Entity {uid: 'hu:agent:w19-curator'})
SET a.entityType = 'Agent', a.name = 'W19 Source Intelligence worker (Opus 5.5)', a.agentKind = 'MANUAL_AGENT', a.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (x:Activity:Occurrence {uid: 'hu:activity:w19-capture-2026-10-04'})
SET x.occurrenceType = 'Activity', x.activityKind = 'CAPTURE', x.startedAt = datetime('2026-10-04T00:50:00Z'),
    x.methodVersion = 'tavily-extract basic text query-reranked', x.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (x:Activity:Occurrence {uid: 'hu:activity:w19-curation-2026-10-04'})
SET x.occurrenceType = 'Activity', x.activityKind = 'EXTRACTION', x.startedAt = datetime('2026-10-04T01:00:00Z'),
    x.methodVersion = 'w19-manual-curation-v0.1', x.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (x:Activity {uid: 'hu:activity:w19-capture-2026-10-04'}), (g:Agent {uid: 'hu:agent:tavily-extract'})
MERGE (x)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- snapshots of two renditions of the same episode ----
MATCH (src:Source {uid: 'hu:document:hubermanlab-com-episode-52'}), (x:Activity {uid: 'hu:activity:w19-capture-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:55:00Z'), s.observedAt = datetime('2026-10-04T00:55:00Z'),
    s.contentHash = 'sha256:60c91e93576900fffc60857c79da2b3d184bb647280a5ca20c0e6a224df4d4b7',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/hubermanlab-52-transcript-2026-10-04.txt', s.mimeType = 'text/plain', s.language = 'en',
    s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (x:Activity {uid: 'hu:activity:w19-capture-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:youtube-n9IxomBusuw-captions-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:55:00Z'), s.observedAt = datetime('2026-10-04T00:55:00Z'),
    s.contentHash = 'sha256:3e383fe3f4edfe79e777818db7e5da7bba513be74099dc5fc6ee3cc6b5572380',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/youtube-n9IxomBusuw-captions-2026-10-04.txt', s.mimeType = 'text/plain', s.language = 'en',
    s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

// ---- locators: the same utterance on two renditions; quote text differs ----
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:hl52-page-2026-10-04-nmn-gram-daily'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82 -year-old father, we take a gram of NMN every day.',
    l.quoteHash = 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56', l.normalizationVersion = 'NFC-WS1',
    l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:hl52-youtube-captions-3765s-nmn-gram-daily'})
SET l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3765s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3765.0, l.mediaEndSeconds = 3773.0, l.mediaTimeBasis = 'RENDITION_CAPTION_CUE',
    l.exact = 'my 82-year-old father, we take a gram of NMN every day.',
    l.quoteHash = 'sha256:c00f9f5c27e17d455016fad171042e91aa60bac6993e04764af024e7f4ab9e20', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:hl52-page-2026-10-04-i-know-45-things'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'And so I know if something\'s, or I know if something\'s making me better or worse based on measuring 45 different things.',
    l.quoteHash = 'sha256:fe53d83c9d536bc80c7d5e4f83d0ab537b10b9a7f4048e5be61ae74fcf4daecf', l.normalizationVersion = 'NFC-WS1',
    l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:hl52-youtube-captions-3788s-i-think-i-know'})
SET l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3788s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3788.0, l.mediaEndSeconds = 3797.0, l.mediaTimeBasis = 'RENDITION_CAPTION_CUE',
    l.exact = 'And so I\'ve been measuring myself and so I know if something\'s, or I think I know if something\'s making me better or worse based on measuring 45 different things.',
    l.quoteHash = 'sha256:bc0d19d4339e1bbd7a500b6395e38f7c891c7c1a50992afad8973b66860919af', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---- claims (proposition identities) ----
MERGE (c:Claim:Entity {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
SET c.entityType = 'Claim', c.claimText = 'David A. Sinclair reports taking about 1 g of NMN per day.', c.claimType = 'DOSING_CLAIM', c.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (c:Claim:Entity {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
SET c.entityType = 'Claim', c.claimText = 'Taking 1 g of NMN daily slows aging.', c.claimType = 'EFFICACY_CLAIM', c.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (c:Claim:Entity {uid: 'hu:claim:sinclair-knows-effect-by-self-measurement'})
SET c.entityType = 'Claim', c.claimText = 'David A. Sinclair states he can tell from measuring 45 variables whether something makes him better or worse.', c.claimType = 'METHOD_CLAIM', c.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- the original occurrence: one asserter, one container (the Episode), locators on two renditions ----
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l1:SourceLocator {uid: 'hu:locator:hl52-page-2026-10-04-nmn-gram-daily'}), (l2:SourceLocator {uid: 'hu:locator:hl52-youtube-captions-3765s-nmn-gram-daily'}),
      (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (a:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'})
SET a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g',
    a.utteranceText = l1.exact, a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(x)
MERGE (a)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'w19-manual-curation-v0.1';

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (l1:SourceLocator {uid: 'hu:locator:hl52-page-2026-10-04-i-know-45-things'}), (l2:SourceLocator {uid: 'hu:locator:hl52-youtube-captions-3788s-i-think-i-know'}),
      (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'}), (c:Claim {uid: 'hu:claim:sinclair-knows-effect-by-self-measurement'})
MERGE (a:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-knows-by-measuring'})
SET a.predicate = 'STATES_SELF_MEASUREMENT_PRACTICE', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'STATES', a.valueString = 'measures 45 different things',
    a.utteranceText = l1.exact, a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(x)
MERGE (a)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'w19-manual-curation-v0.1';

// ---- SYNTHETIC retelling 1: newsletter, no citation (BELLLABS_MATCH). The Document carries the live
//      isPrimarySource = true flag to show that a document-level flag is ignored (CQ-PV-05). ----
MERGE (d:Document:Source:Entity {uid: 'hu:document:synthetic-longevity-digest-issue-2'})
SET d.entityType = 'Source', d.documentId = 'synthetic-longevity-digest-issue-2',
    d.canonicalUri = 'https://longevity-digest.example.invalid/issue-2', d.title = 'Synthetic Longevity Digest, issue 2 (fixture only)',
    d.sourceKind = 'NEWSLETTER', d.documentType = 'BLOG_POST', d.isPrimarySource = true, d.fixtureProvenance = 'SYNTHETIC',
    d.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (d:Source {uid: 'hu:document:synthetic-longevity-digest-issue-2'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-digest-issue-2-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = d.canonicalUri, s.retrievedAt = datetime('2026-10-04T10:00:00Z'),
    s.observedAt = datetime('2026-10-04T10:00:00Z'), s.contentHash = 'synthetic:hu:snapshot:synthetic-digest-issue-2-2026-10-04',
    s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-digest-issue-2-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-digest-issue-2-retelling'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Harvard geneticist David Sinclair recommends taking a gram of NMN every morning to slow aging.',
    l.quoteHash = 'sha256:c1cd687f504b3172a8b0e76ddca1208eec9b3cb2b6d9d949c7191efb918ed099', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (au:Person {uid: 'hu:person:synthetic-digest-author'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}),
      (d:Source {uid: 'hu:document:synthetic-longevity-digest-issue-2'}), (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-digest-issue-2-retelling'}), (c:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
MERGE (r:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:w19-synthetic-digest-sinclair-recommends-nmn'})
SET r.predicate = 'RECOMMENDS_DAILY_INTAKE', r.status = 'EXTRACTED', r.polarity = 'POSITIVE',
    r.assertionBasis = 'EXPERT_OPINION', r.speechAct = 'STATES', r.reportedSpeechAct = 'RECOMMENDS',
    r.valueNumber = 1.0, r.unitCode = 'g', r.utteranceText = l.exact, r.fixtureProvenance = 'SYNTHETIC',
    r.recordedAt = datetime('2026-10-04T12:00:00Z'), r.extractionMethod = 'manual'
MERGE (r)-[:HAS_SUBJECT]->(nmn)
MERGE (r)-[:ASSERTED_BY]->(au)
MERGE (r)-[:ATTRIBUTES_TO]->(sp)
MERGE (r)-[:OCCURS_IN]->(d)
MERGE (r)-[:SUPPORTED_BY]->(l)
MERGE (r)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'w19-manual-curation-v0.1';

MATCH (r:Assertion {uid: 'hu:claim-occurrence:w19-synthetic-digest-sinclair-recommends-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:w19-retelling-source-digest-2-to-hl52-nmn'})
SET h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'RETELLING_SOURCE', h.resolutionStatus = 'PROPOSED',
    h.rationale = 'Same speaker, substance, amount, daily schedule; the retelling cites no source.',
    h.methodVersion = 'w19-manual-curation-v0.1', h.status = 'PROPOSED', h.recordedAt = datetime('2026-10-04T12:00:00Z'), h.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(o)
MERGE (h)-[:PROPOSES_MATCH]->(r)
MERGE (r)-[x:RETELLS]->(o)
SET x.retellingMode = 'PARAPHRASE', x.linkBasis = 'BELLLABS_MATCH', x.hypothesisUid = h.uid;

// ---- SYNTHETIC retelling 2: an aggregator quoting the digest with an explicit citation ----
MERGE (d:Document:Source:Entity {uid: 'hu:document:synthetic-aggregator-roundup-7'})
SET d.entityType = 'Source', d.documentId = 'synthetic-aggregator-roundup-7',
    d.canonicalUri = 'https://aggregator.example.invalid/roundup-7', d.title = 'Synthetic aggregator roundup 7 (fixture only)',
    d.sourceKind = 'NEWS_ARTICLE', d.documentType = 'NEWS_ARTICLE', d.fixtureProvenance = 'SYNTHETIC', d.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (d:Source {uid: 'hu:document:synthetic-aggregator-roundup-7'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-aggregator-roundup-7-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = d.canonicalUri, s.retrievedAt = datetime('2026-10-04T10:00:00Z'),
    s.observedAt = datetime('2026-10-04T10:00:00Z'), s.contentHash = 'synthetic:hu:snapshot:synthetic-aggregator-roundup-7-2026-10-04',
    s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-aggregator-roundup-7-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-aggregator-roundup-7-quote'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'As the Longevity Digest reports, Sinclair recommends a gram of NMN every morning to slow aging.',
    l.quoteHash = 'synthetic:hu:locator:synthetic-aggregator-roundup-7-quote', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (ed:Person {uid: 'hu:person:synthetic-aggregator-editor'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}),
      (d:Source {uid: 'hu:document:synthetic-aggregator-roundup-7'}), (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-aggregator-roundup-7-quote'}), (c:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
MERGE (r:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:w19-synthetic-aggregator-quotes-digest'})
SET r.predicate = 'RECOMMENDS_DAILY_INTAKE', r.status = 'EXTRACTED', r.polarity = 'POSITIVE',
    r.assertionBasis = 'EXPERT_OPINION', r.speechAct = 'STATES', r.reportedSpeechAct = 'RECOMMENDS',
    r.valueNumber = 1.0, r.unitCode = 'g', r.utteranceText = l.exact, r.fixtureProvenance = 'SYNTHETIC',
    r.recordedAt = datetime('2026-10-04T12:00:00Z'), r.extractionMethod = 'manual'
MERGE (r)-[:HAS_SUBJECT]->(nmn)
MERGE (r)-[:ASSERTED_BY]->(ed)
MERGE (r)-[:ATTRIBUTES_TO]->(sp)
MERGE (r)-[:OCCURS_IN]->(d)
MERGE (r)-[:SUPPORTED_BY]->(l)
MERGE (r)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'w19-manual-curation-v0.1';

MATCH (r:Assertion {uid: 'hu:claim-occurrence:w19-synthetic-aggregator-quotes-digest'}), (o:Assertion {uid: 'hu:claim-occurrence:w19-synthetic-digest-sinclair-recommends-nmn'}),
      (cl:SourceLocator {uid: 'hu:locator:synthetic-aggregator-roundup-7-quote'})
MERGE (r)-[x:RETELLS]->(o)
SET x.retellingMode = 'PARAPHRASE', x.linkBasis = 'EXPLICIT_CITATION', x.citationLocatorUid = cl.uid;
