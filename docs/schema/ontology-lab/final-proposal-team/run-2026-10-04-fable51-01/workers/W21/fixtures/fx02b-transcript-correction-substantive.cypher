// =====================================================================================================
// W21 fixture fx02b: transcript correction that DOES change the captured content (mis-transcription: the reviewed
// page reads "half a gram"). The old occurrence is superseded with SOURCE_CORRECTION (capture was wrong); a new
// occurrence from the reviewed snapshot replaces it; the old locator L1 stays intact and the new locator REANCHORS
// it, so the prior citation remains reproducible. Contrast with a publisher CONTENT correction (Lifespan #4): the
// speech record is kept and the notice is a new publisher assertion (round 0006 D2; not repeated here).
// SYNTHETIC part as in fx02a; "half a gram" is invented test data, not a claim about the real episode.
// =====================================================================================================
// ---- Common part: the 2026-10-03 capture and the original occurrence (inherited case, round 0006) ----------
MERGE (n:Entity:Person {uid: 'hu:person:david-a-sinclair'})
SET n.id = 'david-a-sinclair', n.entityType = 'Person', n.name = 'David A. Sinclair', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})
SET n.id = 'nicotinamide-mononucleotide', n.entityType = 'ChemicalSubstance', n.name = 'Nicotinamide mononucleotide', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET n.id = 'huberman-lab-52-sinclair', n.entityType = 'Episode', n.name = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair',
    n.episodeNumber = 52, n.publishedAt = datetime('2021-12-27T09:00:00Z'), n.publishedAtPrecision = 'INSTANT', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Source:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET n.id = 'hubermanlab-com-episode-52', n.documentId = 'hubermanlab-com-episode-52', n.entityType = 'Source',
    n.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging',
    n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-03T12:00:00Z');

MATCH (s:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

MERGE (g:Entity:Agent {uid: 'hu:agent:hubermanlab-transcription-process'})
SET g.id = 'hubermanlab-transcription-process', g.entityType = 'Agent', g.name = 'Huberman Lab transcript production (method not published)', g.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (g:Entity:Agent {uid: 'hu:agent:w21-curator'})
SET g.id = 'w21-curator', g.entityType = 'Agent', g.name = 'W21 fixture curator (Opus 5.5)', g.agentKind = 'MANUAL_AGENT', g.createdAt = datetime('2026-10-03T12:00:00Z');

MATCH (g:Agent {uid: 'hu:agent:hubermanlab-transcription-process'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
SET a.id = 'hubermanlab-transcription-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.methodVersion = 'publisher transcript; stated "under human review"', a.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
SET a.id = 'w21-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'EXTRACTION', a.methodVersion = 'w21-manual-curation-v0.1', a.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// S1: the inherited 2026-10-03 capture (hash from round 0006; STORED_EXCERPT_TEXT; page under human review).
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'})
SET s.id = 'hubermanlab-52-page-2026-10-03', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:9cadaee8e0720295eb1809e6dcc05e88574884b74b1f892840b4ce300a83229d', s.contentHashBasis = 'STORED_EXCERPT_TEXT',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.publisherRevisionNotice = 'This transcript is currently under human review and may contain errors.',
    s.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}),
      (act:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
SET tv.id = 'hubermanlab-52-page-2026-10-03-excerpt', tv.documentTextVersionId = 'hubermanlab-52-page-2026-10-03-excerpt', tv.artifactType = 'DocumentTextVersion',
    tv.textVersionHash = s.contentHash, tv.source = 'publisher-transcript (excerpt)', tv.versionLabel = 'under human review', tv.normalizationVersion = 'NFC-WS1',
    tv.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

// L1: the prior citation. It is never edited after this statement.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
SET l.id = 'hl52-page-nmn-gram-daily', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82 -year-old father, we take a gram of NMN every day.', l.quoteHash = 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})
SET a.id = 'hl52-sinclair-self-reported-nmn-1g-daily', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-03T12:00:00Z'),
    a.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx02-capture-fidelity-2026-10-03'})
SET j.id = 'w21-fx02-capture-fidelity-2026-10-03', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-03T12:30:00Z'),
    j.recordedAt = datetime('2026-10-03T12:30:00Z'), j.createdAt = datetime('2026-10-03T12:30:00Z'), j.privacyClass = 'internal'
MERGE (j)-[:EVALUATES]->(a);

// ---- SYNTHETIC: the publisher posts the "fully reviewed version" (not yet published as of 2026-10-04) ------------
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-hubermanlab-52-page-reviewed-2026-11-15'})
SET s.id = 'synthetic-hubermanlab-52-page-reviewed-2026-11-15', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-11-15T00:00:00Z'), s.observedAt = datetime('2026-11-15T00:00:00Z'),
    s.contentHash = 'sha256:17b02ca4404b57d4cf0aeccff5931e340e60aac990ed0690669073c1c0426203', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.publisherRevisionNotice = NULL, s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (s1:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}),
      (s2:SourceSnapshot {uid: 'hu:snapshot:synthetic-hubermanlab-52-page-reviewed-2026-11-15'})
MERGE (ev:Occurrence:SourceRevisionEvent {uid: 'hu:source-revision:synthetic-hl52-transcript-reviewed'})
SET ev.id = 'synthetic-hl52-transcript-reviewed', ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'NEW_VERSION', ev.occurredAt = NULL,
    ev.recordedAt = datetime('2026-11-15T12:00:00Z'), ev.fixtureProvenance = 'SYNTHETIC', ev.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (ev)-[:REVISES_SOURCE]->(src)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(s1)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(s2);

// The reviewed text is a new text version, produced by the publisher's (human) review: a TRANSCRIPTION activity.
MATCH (g:Agent {uid: 'hu:agent:hubermanlab-transcription-process'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:synthetic-hubermanlab-human-review-hl52'})
SET a.id = 'synthetic-hubermanlab-human-review-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.methodVersion = 'publisher human review (synthetic)',
    a.fixtureProvenance = 'SYNTHETIC', a.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-hubermanlab-52-page-reviewed-2026-11-15'}),
      (act:Activity {uid: 'hu:activity:synthetic-hubermanlab-human-review-hl52'}), (prev:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:synthetic-hubermanlab-52-page-reviewed'})
SET tv.id = 'synthetic-hubermanlab-52-page-reviewed', tv.documentTextVersionId = 'synthetic-hubermanlab-52-page-reviewed', tv.artifactType = 'DocumentTextVersion',
    tv.textVersionHash = s.contentHash, tv.source = 'publisher-transcript (reviewed)', tv.versionLabel = 'fully reviewed (synthetic)', tv.normalizationVersion = 'NFC-WS1',
    tv.fixtureProvenance = 'SYNTHETIC', tv.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act)
MERGE (act)-[:USED]->(prev);

MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:synthetic-w21-reanchoring-2026-11-15'})
SET a.id = 'synthetic-w21-reanchoring-2026-11-15', a.occurrenceType = 'Activity', a.activityKind = 'REANCHORING', a.methodVersion = 'quote-fuzzy-match-v1 (synthetic)',
    a.fixtureProvenance = 'SYNTHETIC', a.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- fx02b specific: reviewed text changes the amount -------------------------------------------------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-hubermanlab-52-page-reviewed-2026-11-15'}), (tv:DocumentTextVersion {uid: 'hu:text-version:synthetic-hubermanlab-52-page-reviewed'}),
      (old:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}), (act:Activity {uid: 'hu:activity:synthetic-w21-reanchoring-2026-11-15'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-hl52-page-reviewed-nmn-half-gram'})
SET l.id = 'synthetic-hl52-page-reviewed-nmn-half-gram', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82-year-old father, we take half a gram of NMN every day.', l.quoteHash = 'sha256:c1cb365794d4a30ed3caeaceafdb836f29ff3f076870a1114365d3627146135a',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv)
MERGE (l)-[:WAS_GENERATED_BY]->(act)
MERGE (l)-[r:REANCHORS]->(old)
SET r.anchorMatch = 'FUZZY', r.activityUid = act.uid;

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:synthetic-hl52-page-reviewed-nmn-half-gram'}),
      (old:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}),
      (ev:SourceRevisionEvent {uid: 'hu:source-revision:synthetic-hl52-transcript-reviewed'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-hl52-sinclair-nmn-half-gram-daily'})
SET a.id = 'synthetic-hl52-sinclair-nmn-half-gram-daily', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 0.5, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-11-15T12:00:00Z'),
    a.fixtureProvenance = 'SYNTHETIC', a.createdAt = datetime('2026-11-15T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[x:SUPERSEDES]->(old)
SET x.supersessionKind = 'SOURCE_CORRECTION', x.recordedAt = datetime('2026-11-15T12:00:00Z'), x.sourceRevisionEventUid = ev.uid;

// The one permitted write to the old record: recordedTo (from null) and the cached status projection.
MATCH (old:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})
SET old.recordedTo = datetime('2026-11-15T12:00:00Z'), old.status = 'SUPERSEDED';

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-hl52-sinclair-nmn-half-gram-daily'})
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx02b-capture-fidelity-2026-11-15'})
SET j.id = 'w21-fx02b-capture-fidelity-2026-11-15', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-11-15T12:30:00Z'),
    j.recordedAt = datetime('2026-11-15T12:30:00Z'), j.createdAt = datetime('2026-11-15T12:30:00Z'), j.privacyClass = 'internal', j.fixtureProvenance = 'SYNTHETIC'
MERGE (j)-[:EVALUATES]->(a);
