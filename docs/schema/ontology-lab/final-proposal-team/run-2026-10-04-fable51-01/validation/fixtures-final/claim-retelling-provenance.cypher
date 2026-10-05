// =====================================================================
// Fixture: claim-retelling-provenance.cypher   (Round 0006, Lane 4)
// Neo4j 5.x Cypher. Illustrative fixture, not a production import.
//
// What it encodes
//   1. A real, public podcast episode (Huberman Lab #52, guest David A.
//      Sinclair) as a work (Episode) with two renditions (the publisher
//      transcript page and the YouTube video), each a Source with a
//      SourceSnapshot captured 2026-10-03 and reproducible SourceLocators
//      (W3C Web Annotation style TextQuote / MediaTime selector fields).
//   2. A ClaimOccurrence (Assertion) by the named speaker with
//      assertionBasis PERSONAL_EXPERIENCE and speechAct REPORTS_PRACTICE,
//      plus the speaker's own qualification as a separate occurrence
//      linked by QUALIFIED_BY.
//   3. A SYNTHETIC later retelling (fictional newsletter, fictional author)
//      that drops the qualification and turns a practice report into a
//      recommendation. It is a distinct Assertion linked by RETELLS and
//      flagged by a RetellingFidelityAssessment.
//   4. Time-bounded financial roles: the host-read sponsorship of the
//      episode (InsideTracker, valid from publication) and the speaker's
//      self-disclosed InsideTracker roles (board 2011-2017; investor,
//      advisor, IP 2011-open), plus EdenRoc/MetroBiotech ties relevant to
//      an NAD-booster claim, with ConflictRelevanceAssessments that say
//      which relationship is relevant to which occurrence.
//   5. Intentionally absent edges (see section 9).
//   6. Trailing validation queries that return rows if a retelling is
//      merged into the original, if an assertion lacks a reproducible
//      locator, or if a forbidden implication is reintroduced.
//
// Source facts used (see sources/source-registry.yaml, Round 0006):
//   SRC-HUBERMANLAB-52-TRANSCRIPT, SRC-YOUTUBE-HL52, SRC-APPLE-PODCASTS-HL52,
//   SRC-SINCLAIR-AFFILIATIONS. Quotes are verbatim from text captured via a
//   third-party extractor on 2026-10-03; the capture is a PARTIAL_EXCERPT,
//   so contentHash is computed over the stored excerpt text, not raw bytes.
//   The retelling, its outlet, and its author are SYNTHETIC test data and
//   are not attributed to any real publication.
//
// Rule for every statement: nodes referenced by a relationship are first
// MATCHed by uid in the same statement. No variable crosses a ';'.
// Timestamps are fixed literals so the fixture is deterministic.
//
// Write statements: // status: statically-checked (syntax-linted with the
// Neo4j Cypher language-support parser and read for per-statement variable
// binding). Nothing here was executed against a database.
// =====================================================================
// Executed 2026-10-03 on an embedded Neo4j 5.26 Community instance (authoring scratchpad): every statement ran, and the full
// 0.2.0 validation suite (../neo4j/validation.cypher) returned zero failing rows with this fixture loaded alone and with all six
// fixtures loaded together. Expected informational rows are listed in ../ontology-lab/proposal-index.md section 9.

// ---------------------------------------------------------------------
// 1. Identities (nodes only)
// ---------------------------------------------------------------------

MERGE (n:Entity:Person {uid: 'hu:person:david-a-sinclair'})
SET n.entityType = 'Person', n.name = 'David A. Sinclair', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Person {uid: 'hu:person:andrew-d-huberman'})
SET n.entityType = 'Person', n.name = 'Andrew D. Huberman', n.createdAt = datetime('2026-10-03T12:00:00Z');

// SYNTHETIC author of the synthetic retelling.
MERGE (n:Entity:Person {uid: 'hu:person:synthetic-digest-author'})
SET n.entityType = 'Person', n.name = 'Synthetic Digest Author (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-03T12:00:00Z');

// Brand and legal entity stay separate identities; see section 6 (OWNS_BRAND is only PROPOSED).
MERGE (n:Entity:ConsumerBrand {uid: 'hu:brand:insidetracker'})
SET n.entityType = 'ConsumerBrand', n.name = 'InsideTracker', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Organization:LegalEntity {uid: 'hu:org:segterra'})
SET n.entityType = 'LegalEntity', n.name = 'Segterra', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Organization {uid: 'hu:org:edenroc-sciences'})
SET n.entityType = 'Organization', n.name = 'EdenRoc Sciences', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Organization {uid: 'hu:org:metrobiotech-international'})
SET n.entityType = 'Organization', n.name = 'MetroBiotech International', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Organization {uid: 'hu:org:scicomm-media'})
SET n.entityType = 'Organization', n.name = 'Scicomm Media', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Channel {uid: 'hu:channel:huberman-lab'})
SET n.entityType = 'Channel', n.name = 'Huberman Lab', n.createdAt = datetime('2026-10-03T12:00:00Z');

// The episode is the work. publishedAt from Apple Podcasts (27 Dec 2021 09:00 UTC).
MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET n.entityType = 'Episode', n.name = 'Dr. David Sinclair: The Biology of Slowing & Reversing Aging',
    n.episodeNumber = 52, n.publishedAt = datetime('2021-12-27T09:00:00Z'), n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})
SET n.entityType = 'ChemicalSubstance', n.preferredName = 'Nicotinamide mononucleotide', n.createdAt = datetime('2026-10-03T12:00:00Z');

// Proposition identities (live Claim). No evidenceStrength on Claim: that is an assessment.
MERGE (n:Entity:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
SET n.entityType = 'Claim', n.claimText = 'David A. Sinclair reports taking about 1 g of NMN per day.',
    n.claimType = 'DOSING_CLAIM', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
SET n.entityType = 'Claim', n.claimText = 'Taking 1 g of NMN daily slows aging.',
    n.claimType = 'EFFICACY_CLAIM', n.isCausal = true, n.createdAt = datetime('2026-10-03T12:00:00Z');

// Agents and activities (state 4: an agent used the source).
MERGE (n:Entity:Agent {uid: 'hu:agent:tavily-extract'})
SET n.entityType = 'Agent', n.name = 'Tavily extract API', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Agent {uid: 'hu:agent:belllabs-lane4-curator'})
SET n.entityType = 'Agent', n.name = 'BellLabs Lane 4 fixture curator', n.agentKind = 'MANUAL_AGENT', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Occurrence:Activity {uid: 'hu:activity:capture-2026-10-03-lane4'})
SET n.occurrenceType = 'Activity', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-03T00:00:00Z'),
    n.endedAt = NULL, n.externalRunSystem = NULL, n.externalRunId = NULL, n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Occurrence:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
SET n.occurrenceType = 'Activity', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-03T00:00:00Z'),
    n.methodVersion = 'lane4-manual-curation-v0.1', n.createdAt = datetime('2026-10-03T12:00:00Z');

// ---------------------------------------------------------------------
// 2. Sources (renditions), snapshots, text version
// ---------------------------------------------------------------------

MERGE (n:Entity:Source:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET n.entityType = 'Source', n.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging',
    n.title = 'Dr. David Sinclair: The Biology of Slowing & Reversing Aging (transcript page)', n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE',
    n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-03T12:00:00Z'), n.documentId = 'hubermanlab-com-episode-52', n.url = n.canonicalUri;

MERGE (n:Entity:Source {uid: 'hu:source:youtube-n9IxomBusuw'})
SET n.entityType = 'Source', n.canonicalUri = 'https://www.youtube.com/watch?v=n9IxomBusuw',
    n.title = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair (YouTube)', n.sourceKind = 'VIDEO_RENDITION', n.createdAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Entity:Source:Document {uid: 'hu:source:sinclair-lab-affiliations'})
SET n.entityType = 'Source', n.canonicalUri = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations',
    n.title = 'David A. Sinclair’s Affiliations | The Sinclair Lab', n.sourceKind = 'SELF_DISCLOSURE_PAGE', n.type = 'WEBPAGE',
    n.isFinancialDisclosure = true, n.createdAt = datetime('2026-10-03T12:00:00Z'), n.documentId = 'sinclair-lab-affiliations', n.url = n.canonicalUri;

// SYNTHETIC retelling outlet. The .invalid TLD guarantees it resolves nowhere.
MERGE (n:Entity:Source:Document {uid: 'hu:source:synthetic-longevity-digest-issue-1'})
SET n.entityType = 'Source', n.canonicalUri = 'https://longevity-digest.example.invalid/issue-1',
    n.title = 'Synthetic Longevity Digest, issue 1 (fixture only)', n.sourceKind = 'NEWSLETTER', n.type = 'BLOG_POST',
    n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-03T12:00:00Z'), n.documentId = 'synthetic-longevity-digest-issue-1', n.url = n.canonicalUri;

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (src)-[:RENDITION_OF]->(ep);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (src)-[:RENDITION_OF]->(ep);

MATCH (ch:Channel {uid: 'hu:channel:huberman-lab'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (ch)-[:HAS_EPISODE]->(ep);

// Appearance roles (live APPEARS_IN with RoleMetadata; HOST/GUEST are proposed RoleType values).
// Each appearance is an asserted role backed by an assertion on the transcript page (statement placed after the locators exist).
MATCH (p:Person {uid: 'hu:person:andrew-d-huberman'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (p)-[r:APPEARS_IN]->(ep)
SET r.roleType = 'HOST', r.assertionUid = 'hu:assertion:hl52-huberman-appears-as-host', r.recordedFrom = datetime('2026-10-03T12:00:00Z'), r.relationshipUid = 'hu:rel:hl52-huberman-appears-as-host';

MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (p)-[r:APPEARS_IN]->(ep)
SET r.roleType = 'GUEST', r.assertionUid = 'hu:assertion:hl52-sinclair-appears-as-guest', r.recordedFrom = datetime('2026-10-03T12:00:00Z'), r.relationshipUid = 'hu:rel:hl52-sinclair-appears-as-guest';

// Snapshot of a mutable page. The page itself says its transcript is under
// human review, so a later reviewed version is expected to differ.
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (act:Activity {uid: 'hu:activity:capture-2026-10-03-lane4'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:9cadaee8e0720295eb1809e6dcc05e88574884b74b1f892840b4ce300a83229d',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'blob:sha256:9cadaee8e0720295eb1809e6dcc05e88574884b74b1f892840b4ce300a83229d',
    s.archiveUri = NULL, s.publisherRevisionNotice = 'This transcript is currently under human review and may contain errors.',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (act:Activity {uid: 'hu:activity:capture-2026-10-03-lane4'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-transcript-2026-10-03'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:9eeb74d7bc16efd292be3f9771e74572826d8f71c68b143dc8ba0471d95bae54',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'blob:sha256:9eeb74d7bc16efd292be3f9771e74572826d8f71c68b143dc8ba0471d95bae54',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:sinclair-lab-affiliations'}), (act:Activity {uid: 'hu:activity:capture-2026-10-03-lane4'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:7f5c60d19e3501b26762db0d5a86b7013deb28e92dba6980a4b9f51a330097bf',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'blob:sha256:7f5c60d19e3501b26762db0d5a86b7013deb28e92dba6980a4b9f51a330097bf',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:synthetic-longevity-digest-issue-1'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-digest-issue-1-2026-10-03'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:c1cd687f504b3172a8b0e76ddca1208eec9b3cb2b6d9d949c7191efb918ed099',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'COMPLETE',
    s.fixtureProvenance = 'SYNTHETIC', s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// Text version derived from exactly one snapshot (live DocumentTextVersion kept).
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}),
      (act:Activity {uid: 'hu:activity:capture-2026-10-03-lane4'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
SET tv.artifactType = 'DocumentTextVersion', tv.textVersionHash = s.contentHash, tv.source = 'third-party-extract',
    tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

// ---------------------------------------------------------------------
// 3. Reproducible locators (P0-5). quoteHash = sha256 of the exact text
//    after normalization NFC-WS1 (Unicode NFC, whitespace runs -> one
//    space, trimmed). No TextPosition offsets: the capture is partial.
// ---------------------------------------------------------------------

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82 -year-old father, we take a gram of NMN every day.',
    l.prefix = 'I\'m always happy to tell you what I do and what my father does. ',
    l.suffix = ' Andrew Huberman: So it\'s a gram of resveratrol and a gram of NMN.',
    l.quoteHash = 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-page-not-same-as-everybody'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Now another important point, which is I\'m not the same as everybody else. I have different microbiome, age, sex.',
    l.prefix = 'Andrew Huberman: Okay. A thousand milligrams. David Sinclair: ',
    l.suffix = ' Andrew Huberman: Sure.',
    l.quoteHash = 'sha256:3b3b6b061f0b29b0d46c261494eddb3f9d52b6aaeda77d013713c7d09be86656',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-page-insidetracker-board-disclosure'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'I was one of the first people in InsideTracker as a board member and I\'m still their scientific lead guy.',
    l.prefix = 'hundreds of thousands of people\'s metabolism and their blood biomarkers. ',
    l.suffix = '',
    l.quoteHash = 'sha256:a301a624bb4a10b4386ebca3d99013a87a57bb554311d405ade3f18247878928',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-03-excerpt'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-page-insidetracker-one-of-them'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'InsideTracker is one of them and you just do it a couple of times a year at a minimum.',
    l.prefix = 'there are increasing numbers of companies that offer these tests. ',
    l.suffix = ' And then you can share that with your doctor.',
    l.quoteHash = 'sha256:8e8d3bf891773bcbecac9735489b93a742794d26296fbaa503bcdf457efd9bb7',
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// Media-time locator: valid only on this rendition's timeline (the audio feed
// uses dynamic ad insertion, so its offsets can differ). Quote is the anchor.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-transcript-2026-10-03'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:hl52-youtube-insidetracker-sponsor-read'})
SET l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=287s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 287.0, l.mediaEndSeconds = 295.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = 'Today\'s episode is also brought to us by InsideTracker.',
    l.quoteHash = 'sha256:c68c127ba0e0d1b94a8a8135d2dfd87dd3d383c46d1bc9da2ab43f9598518659',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'ACTIVE ENGAGEMENTS',
    l.exact = 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)',
    l.quoteHash = 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:sinclair-affiliations-edenroc-line'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'ACTIVE ENGAGEMENTS',
    l.exact = 'EdenRoc Sciences companies F,I,E,A,B, IP',
    l.quoteHash = 'sha256:6cb5d847cc2c776ecd1280de1fbeff78d149d9ad3dd25e26d318518f815f93e6',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:sinclair-affiliations-metrobiotech-line'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'ACTIVE ENGAGEMENTS',
    l.exact = 'MetroBiotech International, an EdenRoc Sciences company, NAD boosters (2015-present)',
    l.quoteHash = 'sha256:2c91cd2ea77c1b5419254c81bc8edabe3b1d06044d2e37ef33d0d341faeca6fe',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-digest-issue-1-2026-10-03'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-digest-retelling'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Harvard geneticist David Sinclair recommends taking a gram of NMN every morning to slow aging.',
    l.quoteHash = 'sha256:c1cd687f504b3172a8b0e76ddca1208eec9b3cb2b6d9d949c7191efb918ed099',
    l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---------------------------------------------------------------------
// 4. Claim occurrences in the episode (state 1: someone said it;
//    state 2: a located span supports that they said it).
//    status ACCEPTED = accepted as an accurate record of what was said.
//    It is NOT a verdict that the proposition is true (that is Adjudication).
// ---------------------------------------------------------------------

// A1: personal-experience practice report by the named guest.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}),
      (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})
SET a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE',
    a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'UNSPECIFIED',
    a.utteranceText = l.exact, a.validFrom = NULL, a.validTo = NULL,
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionConfidence = 0.95, a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'manual-curation-v0.1';

// A2: the speaker's own qualification, a separate utterance two turns later.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (l:SourceLocator {uid: 'hu:locator:hl52-page-not-same-as-everybody'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-individual-variation'})
SET a.predicate = 'STATES_INDIVIDUAL_DIFFERENCE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'CAUTIONS', a.valueString = 'different microbiome, age, sex',
    a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionConfidence = 0.95, a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a1:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}), (a2:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-individual-variation'})
MERGE (a1)-[q:QUALIFIED_BY]->(a2)
SET q.qualificationKind = 'INDIVIDUAL_VARIATION', q.relationshipUid = 'hu:rel:qualified-by-hl52-nmn-individual-variation';

// A3/A4: on-air self-disclosure, one span, two role assertions (past board role; present role with verbatim title).
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-insidetracker-board-disclosure'}),
      (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-says-past-board-member-insidetracker'})
SET a.predicate = 'BOARD_MEMBER_OF', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'STATES', a.roleTitleVerbatim = 'board member',
    a.statedTense = 'PAST', a.validFrom = NULL, a.validTo = NULL, a.utteranceText = l.exact,
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-insidetracker-board-disclosure'}),
      (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-says-scientific-lead-insidetracker'})
SET a.predicate = 'AFFILIATED_WITH', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'STATES', a.roleTitleVerbatim = 'scientific lead guy',
    a.statedTense = 'PRESENT', a.utteranceText = l.exact,
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// A5: the editorial mention of the sponsor's service by the guest (not an endorsement edge).
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-insidetracker-one-of-them'}),
      (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-insidetracker-offers-tests'})
SET a.predicate = 'OFFERS_SERVICE_KIND', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'STATES', a.valueString = 'blood biomarker testing',
    a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// A6: the host's sponsor read. Time-bounded sponsorship role: valid from the
// episode's publication (publication proxy), open end, scoped to this content
// item as rendered on YouTube.
MATCH (host:Person {uid: 'hu:person:andrew-d-huberman'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (l:SourceLocator {uid: 'hu:locator:hl52-youtube-insidetracker-sponsor-read'}),
      (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-host-read-insidetracker-sponsors-episode'})
SET a.predicate = 'SPONSORS_CONTENT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'STATES', a.segmentKind = 'SPONSOR_READ',
    a.validFrom = datetime('2021-12-27T09:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY', a.validTo = NULL, a.validToBasis = 'UNKNOWN',
    a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(br)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// ---------------------------------------------------------------------
// 5. Self-disclosure page: role assertions with year-precision bounds.
//    Precision rule used here (to be ratified by Lane 5): with
//    validFromPrecision YEAR, validFrom is the first instant of the start
//    year and validTo is the first instant after the end year, i.e. the
//    widest half-open interval consistent with the source. 'present' on a
//    page observed 2026-10-03 is validTo NULL, not a claim about later dates.
//    The page codes I (Investor) and E (Equity) separately, so INVESTED_IN
//    and HOLDS_EQUITY_IN are separate predicates.
// ---------------------------------------------------------------------

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.predicate = 'BOARD_MEMBER_OF', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'B', a.validFrom = datetime('2011-01-01T00:00:00Z'), a.validTo = datetime('2018-01-01T00:00:00Z'),
    a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToPrecision = 'YEAR', a.validToBasis = 'STATED_BY_SOURCE', a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET a.predicate = 'INVESTED_IN', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'I', a.validFrom = datetime('2011-01-01T00:00:00Z'), a.validTo = NULL,
    a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-advisor-insidetracker-2011-open'})
SET a.predicate = 'ADVISES_ORGANIZATION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'A', a.validFrom = datetime('2011-01-01T00:00:00Z'), a.validTo = NULL,
    a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-ip-interest-insidetracker-2011-open'})
SET a.predicate = 'HAS_IP_INTEREST_IN', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'IP', a.validFrom = datetime('2011-01-01T00:00:00Z'), a.validTo = NULL,
    a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// Group line: the codes are printed once for 'EdenRoc Sciences companies'.
// Whether each code applies to each listed company is a scope ambiguity, so
// the equity assertion targets the group, not MetroBiotech.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (er:Organization {uid: 'hu:org:edenroc-sciences'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-edenroc-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-equity-edenroc'})
SET a.predicate = 'HOLDS_EQUITY_IN', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'E', a.validFrom = NULL, a.validTo = NULL, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(er)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (mb:Organization {uid: 'hu:org:metrobiotech-international'}), (er:Organization {uid: 'hu:org:edenroc-sciences'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-metrobiotech-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-metrobiotech-edenroc-company'})
SET a.predicate = 'AFFILIATED_WITH', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.roleTitleVerbatim = 'an EdenRoc Sciences company',
    a.validFrom = datetime('2015-01-01T00:00:00Z'), a.validTo = NULL, a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(mb)
MERGE (a)-[:HAS_OBJECT]->(er)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (mb:Organization {uid: 'hu:org:metrobiotech-international'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-metrobiotech-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-metrobiotech-works-on-nad-boosters'})
SET a.predicate = 'DEVELOPS_PRODUCT_CLASS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueString = 'NAD boosters',
    a.validFrom = datetime('2015-01-01T00:00:00Z'), a.validTo = NULL, a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(mb)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// 'InsideTracker (Segterra)' only juxtaposes two names. Kept PROPOSED; the
// brand and the legal entity are NOT merged (CQ-EC-02).
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (sg:LegalEntity {uid: 'hu:org:segterra'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
MERGE (a:Assertion {uid: 'hu:assertion:affiliations-segterra-owns-insidetracker-brand'})
SET a.predicate = 'OWNS_BRAND', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
    a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sg)
MERGE (a)-[:HAS_OBJECT]->(br)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// Appearance assertions (the transcript page names host and guest).
UNWIND [
  {a: 'hu:assertion:hl52-huberman-appears-as-host', p: 'hu:person:andrew-d-huberman', role: 'HOST'},
  {a: 'hu:assertion:hl52-sinclair-appears-as-guest', p: 'hu:person:david-a-sinclair', role: 'GUEST'}
] AS row
MATCH (p:Person {uid: row.p}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'})
MERGE (a:Assertion {uid: row.a})
SET a.predicate = 'APPEARS_IN', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.roleType = row.role, a.recordedAt = datetime('2026-10-03T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l);

// Projected asserted edges (derived from accepted role assertions; each names its assertion).
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'})
MERGE (sp)-[r:BOARD_MEMBER_OF {assertionUid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'}]->(br)
SET r.relationshipUid = 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017',
    r.validFrom = datetime('2011-01-01T00:00:00Z'), r.validFromPrecision = 'YEAR', r.validFromBasis = 'STATED_BY_SOURCE', r.validTo = datetime('2018-01-01T00:00:00Z'), r.validToPrecision = 'YEAR', r.validToBasis = 'STATED_BY_SOURCE',
    r.recordedFrom = datetime('2026-10-03T12:00:00Z'), r.recordedTo = NULL;

MATCH (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (br)-[r:SPONSORS_CONTENT {assertionUid: 'hu:claim-occurrence:hl52-host-read-insidetracker-sponsors-episode'}]->(ep)
SET r.relationshipUid = 'hu:rel:sponsors-content-insidetracker-hl52',
    r.validFrom = datetime('2021-12-27T09:00:00Z'), r.validFromPrecision = 'DAY', r.validFromBasis = 'PUBLICATION_PROXY', r.validTo = NULL, r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-03T12:00:00Z'), r.recordedTo = NULL;

// ---------------------------------------------------------------------
// 6. SYNTHETIC retelling: a distinct assertion by a different asserter in a
//    different container. It reports a RECOMMENDATION and adds a purpose
//    ('to slow aging'); it omits the speaker's qualification.
// ---------------------------------------------------------------------

MATCH (au:Person {uid: 'hu:person:synthetic-digest-author'}), (sp:Person {uid: 'hu:person:david-a-sinclair'}),
      (doc:Source {uid: 'hu:source:synthetic-longevity-digest-issue-1'}), (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-digest-retelling'}), (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'}),
      (c:Claim {uid: 'hu:claim:1g-nmn-daily-slows-aging'})
MERGE (r:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'})
SET r.predicate = 'RECOMMENDS_DAILY_INTAKE', r.status = 'ACCEPTED', r.polarity = 'POSITIVE',
    r.assertionBasis = 'EXPERT_OPINION', r.speechAct = 'STATES', r.reportedSpeechAct = 'RECOMMENDS',
    r.valueNumber = 1.0, r.unitCode = 'g', r.quantityBasis = 'UNSPECIFIED', r.utteranceText = l.exact,
    r.fixtureProvenance = 'SYNTHETIC', r.recordedAt = datetime('2026-10-03T12:00:00Z'), r.extractionMethod = 'manual'
MERGE (r)-[:HAS_SUBJECT]->(nmn)
MERGE (r)-[:ASSERTED_BY]->(au)
MERGE (r)-[:ATTRIBUTES_TO]->(sp)
MERGE (r)-[:OCCURS_IN]->(doc)
MERGE (r)-[:SUPPORTED_BY]->(l)
MERGE (r)-[:WAS_GENERATED_BY]->(act)
MERGE (r)-[i:INSTANCE_OF]->(c)
SET i.derivationRule = 'manual-curation-v0.1';

// The retelling cites no episode, so the link is a BellLabs match backed by a hypothesis.
MATCH (r:Assertion {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'})
MERGE (h:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:retelling-source-synthetic-digest-to-hl52-nmn'})
SET h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'RETELLING_SOURCE', h.resolutionStatus = 'PROPOSED',
    h.rationale = 'Same speaker, substance, amount and daily schedule; retelling cites no source.',
    h.methodVersion = 'lane4-manual-curation-v0.1', h.status = 'PROPOSED', h.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(o)
MERGE (h)-[:PROPOSES_MATCH]->(r)
MERGE (r)-[x:RETELLS]->(o)
SET x.retellingMode = 'PARAPHRASE', x.linkBasis = 'BELLLABS_MATCH', x.hypothesisUid = h.uid,
    x.relationshipUid = 'hu:rel:retells-synthetic-digest-hl52-nmn';

// Qualification-loss flag lives on an assessment, not on either assertion.
MATCH (r:Assertion {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'}), (o:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}),
      (q:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-individual-variation'}), (cur:Agent {uid: 'hu:agent:belllabs-lane4-curator'})
MERGE (f:EvidenceAssessment:RetellingFidelityAssessment {uid: 'hu:assessment:retelling-fidelity-synthetic-digest-vs-hl52-nmn'})
SET f.assessmentType = 'RetellingFidelityAssessment', f.methodVersion = 'retelling-fidelity-v0.1', f.status = 'PROPOSED',
    f.qualificationLost = true, f.lostQualificationKinds = ['INDIVIDUAL_VARIATION'],
    f.speechActChanged = true, f.speechActFrom = 'REPORTS_PRACTICE', f.speechActTo = 'RECOMMENDS',
    f.scopeBroadened = true, f.addedPurposeText = 'to slow aging', f.quantityChanged = false, f.attributionChanged = false,
    f.correctionIgnored = false, f.assessedAt = datetime('2026-10-03T12:00:00Z'), f.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (f)-[:ASSESSES_RETELLING]->(r)
MERGE (f)-[:AGAINST_ORIGINAL]->(o)
MERGE (f)-[:IDENTIFIES_LOST_QUALIFICATION]->(q)
MERGE (f)-[:ASSESSED_BY]->(cur);

// ---------------------------------------------------------------------
// 7. Which financial relationship is relevant to which occurrence.
//    disclosureFinding distinguishes 'not found in a partial capture' from
//    'not disclosed'. Relevance never changes a truth verdict.
// ---------------------------------------------------------------------

MATCH (occ:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-insidetracker-offers-tests'}),
      (r1:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'}),
      (r2:Assertion {uid: 'hu:assertion:affiliations-sinclair-advisor-insidetracker-2011-open'}),
      (r3:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-says-scientific-lead-insidetracker'}),
      (r4:Assertion {uid: 'hu:claim-occurrence:hl52-host-read-insidetracker-sponsors-episode'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:conflict-relevance-hl52-insidetracker-mention'})
SET c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'DIRECT', c.relevanceBasis = 'SAME_ORGANIZATION', c.temporalOverlap = 'OVERLAPS',
    c.disclosureFinding = 'DISCLOSED_IN_CONTAINER', c.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(occ)
MERGE (c)-[:ASSESSES_INTEREST]->(r1)
MERGE (c)-[:ASSESSES_INTEREST]->(r2)
MERGE (c)-[:ASSESSES_INTEREST]->(r3)
MERGE (c)-[:ASSESSES_INTEREST]->(r4);

MATCH (occ:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}),
      (r1:Assertion {uid: 'hu:assertion:affiliations-sinclair-equity-edenroc'}),
      (r2:Assertion {uid: 'hu:assertion:affiliations-metrobiotech-edenroc-company'}),
      (r3:Assertion {uid: 'hu:assertion:affiliations-metrobiotech-works-on-nad-boosters'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:conflict-relevance-hl52-nmn-edenroc-metrobiotech'})
SET c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'INDIRECT', c.relevanceBasis = 'SAME_SUBSTANCE_CLASS_VIA_GROUP', c.temporalOverlap = 'UNKNOWN',
    c.scopeAmbiguity = 'Group-level role codes; per-company applicability not stated.',
    c.disclosureFinding = 'NOT_FOUND_IN_PARTIAL_CAPTURE', c.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(occ)
MERGE (c)-[:ASSESSES_INTEREST]->(r1)
MERGE (c)-[:ASSESSES_INTEREST]->(r2)
MERGE (c)-[:ASSESSES_INTEREST]->(r3);

MATCH (occ:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}),
      (r1:Assertion {uid: 'hu:claim-occurrence:hl52-host-read-insidetracker-sponsors-episode'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:conflict-relevance-hl52-nmn-insidetracker-sponsorship'})
SET c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'NOT_RELEVANT', c.relevanceBasis = 'NO_PATH_FOUND', c.temporalOverlap = 'OVERLAPS',
    c.disclosureFinding = 'DISCLOSED_IN_CONTAINER', c.createdAt = datetime('2026-10-03T12:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(occ)
MERGE (c)-[:ASSESSES_INTEREST]->(r1);

// ---------------------------------------------------------------------
// 8. State 5 seam: an answer-composition activity that used a locator must
//    name the policy version that allowed quoting it. PolicyVersion is owned
//    by recommendation_decisions (Lane 5); referenced here by uid only.
// ---------------------------------------------------------------------

MERGE (pv:VersionedState:PolicyVersion {uid: 'hu:policy-version:answer-quoting-policy-v0'})
SET pv.stateType = 'PolicyVersion', pv.policyKey = 'answer-quoting', pv.versionLabel = 'v0', pv.policyKind = 'USE_AUTHORIZATION', pv.privacyClass = 'INTERNAL', pv.payloadHash = 'sha256:fixture-answer-quoting-v0', pv.name = 'Answer quoting policy v0 (fixture placeholder)', pv.createdAt = datetime('2026-10-03T12:00:00Z');

MATCH (l:SourceLocator {uid: 'hu:locator:hl52-page-nmn-gram-daily'}), (a:Assertion {uid: 'hu:claim-occurrence:hl52-sinclair-self-reported-nmn-1g-daily'}),
      (cur:Agent {uid: 'hu:agent:belllabs-lane4-curator'}), (pv:PolicyVersion {uid: 'hu:policy-version:answer-quoting-policy-v0'})
MERGE (ans:Occurrence:Activity {uid: 'hu:activity:answer-composition-fixture-1'})
SET ans.occurrenceType = 'Activity', ans.activityKind = 'ANSWER_COMPOSITION', ans.startedAt = datetime('2026-10-03T12:30:00Z'),
    ans.createdAt = datetime('2026-10-03T12:30:00Z')
MERGE (ans)-[:USED]->(l)
MERGE (ans)-[:USED]->(a)
MERGE (ans)-[:WAS_ASSOCIATED_WITH]->(cur)
MERGE (ans)-[u:AUTHORIZED_BY]->(pv)
SET u.useKind = 'QUOTE_IN_ANSWER';

// ---------------------------------------------------------------------
// 9. Intentionally absent (must never be written by inference):
//
//   (sinclair)-[:ENDORSES_PRODUCT]->(insidetracker)
//      An editorial mention by a person with a financial tie, inside an
//      episode the brand sponsors, is not an endorsement assertion.
//   (sinclair)-[:RECOMMENDS]->(nmn)
//      A REPORTS_PRACTICE occurrence does not project to a recommendation.
//      The only RECOMMENDS-type content is the synthetic retelling's
//      reportedSpeechAct, which is an attribution by another asserter.
//   (:Adjudication {verdict: 'CONTRADICTED'})-[:EVALUATES]->(A1 or A5)
//      based on the sponsorship or the equity tie. A disclosed financial
//      relationship does not make a claim false; a missing disclosure does
//      not make it true.
//   (retelling) merged into (A1), or A1 gaining a second ASSERTED_BY or a
//      second OCCURS_IN.
//   (:ConsumerBrand:LegalEntity) for InsideTracker/Segterra.
//   (sinclair)-[:BOARD_MEMBER_OF]->(insidetracker) with validTo NULL.
//   (sinclair)-[:HOLDS_EQUITY_IN]->(metrobiotech) inferred from the group line.
// ---------------------------------------------------------------------

// =====================================================================
// 10. Validation queries for this fixture. Each returns zero rows on the
//     fixture as written and returns rows if the named defect is
//     reintroduced. All marked status: statically-checked unless noted.
// =====================================================================

// F-401 (retelling merge, asserter/container unity). status: statically-checked
MATCH (a:ClaimOccurrence)
OPTIONAL MATCH (a)-[:OCCURS_IN]->(c)
WITH a, count(DISTINCT c) AS containers
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(s)
WITH a, containers, count(DISTINCT s) AS asserters
WHERE containers <> 1 OR asserters <> 1
RETURN a.uid AS mergedOrUnattributedOccurrence, containers, asserters;

// F-402 (retelling merge, locator outside the occurrence's container). status: statically-checked
MATCH (a:ClaimOccurrence)-[:OCCURS_IN]->(c)
MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
WHERE NOT EXISTS {
  MATCH (l)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
  WHERE src = c OR (src)-[:RENDITION_OF]->(c)
}
RETURN a.uid AS occurrence, l.uid AS foreignLocator, c.uid AS container;

// F-403 (retelling collapsed: self-loop, cycle, or shared span). status: statically-checked
MATCH (r:Assertion)-[:RETELLS]->(o:Assertion)
WHERE r = o
   OR EXISTS { MATCH (o)-[:RETELLS*1..10]->(r) }
   OR EXISTS { MATCH (r)-[:SUPPORTED_BY]->(:SourceLocator)<-[:SUPPORTED_BY]-(o) }
RETURN r.uid AS retelling, o.uid AS original;

// F-404 (qualification loss recorded on an assertion instead of an assessment). status: statically-checked
MATCH (a:Assertion)
WHERE a.qualificationLost IS NOT NULL OR a.lostQualificationKinds IS NOT NULL
RETURN a.uid AS assertionCarryingAssessmentField;

// F-405 (accepted assertion without a reproducible locator). status: statically-checked
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT EXISTS {
  MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
  WHERE s.contentHash IS NOT NULL AND s.retrievedAt IS NOT NULL AND l.normalizationVersion IS NOT NULL
    AND (
      (l.selectorKind = 'TEXT_QUOTE' AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'MEDIA_TIME' AND l.mediaStartSeconds IS NOT NULL AND l.mediaEndSeconds IS NOT NULL
          AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'TEXT_POSITION' AND l.startOffset IS NOT NULL AND l.endOffset IS NOT NULL
          AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL
          AND EXISTS { MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(:DocumentTextVersion) })
      OR (l.selectorKind = 'PDF_PAGE' AND l.page IS NOT NULL AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'IMAGE_REGION' AND l.mediaAnnotationUid IS NOT NULL)
    )
}
RETURN a.uid AS assertionWithoutReproducibleLocator;

// F-406 (endorsement inferred from sponsorship, mention, or advising). status: statically-checked
MATCH (p)-[e:ENDORSES_PRODUCT]->(x)
WHERE e.assertionUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion {uid: e.assertionUid}) WHERE a.predicate = 'ENDORSES_PRODUCT' AND a.status = 'ACCEPTED' }
RETURN p.uid AS endorser, x.uid AS endorsed;

// F-407 (practice report projected as a recommendation). status: statically-checked
MATCH (p:Person)-[rec:RECOMMENDS]->(x)
WHERE rec.assertionUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion {uid: rec.assertionUid}) WHERE a.speechAct = 'RECOMMENDS' }
RETURN p.uid AS recommender, x.uid AS recommended;

// F-408 (financial relationship used as a truth verdict). status: statically-checked
MATCH (adj:Adjudication)-[:EVALUATES]->(a:Assertion)
WHERE adj.verdict IN ['CONTRADICTED', 'SUPPORTED']
  AND EXISTS { MATCH (adj)-[:CONSIDERS_ASSESSMENT]->(:ConflictRelevanceAssessment) }
  AND NOT EXISTS {
    MATCH (adj)-[:SUPPORTED_BY|CONTRADICTED_BY]->(l:SourceLocator)<-[:SUPPORTED_BY]-(ev:Assertion)
    WHERE NOT ev.predicate IN ['SPONSORS_CONTENT', 'INVESTED_IN', 'HOLDS_EQUITY_IN', 'BOARD_MEMBER_OF', 'ADVISES_ORGANIZATION',
                               'HAS_IP_INTEREST_IN', 'RECEIVES_COMPENSATION_FROM', 'AFFILIATE_FOR_OFFER', 'FOUNDED_ORGANIZATION', 'EMPLOYED_BY']
  }
RETURN adj.uid AS verdictFromFinancialTieOnly, a.uid AS assertionUid, adj.verdict AS verdict;

// F-409 ('not disclosed' concluded from a partial capture). status: statically-checked
MATCH (c:ConflictRelevanceAssessment {disclosureFinding: 'NOT_DISCLOSED'})-[:FOR_OCCURRENCE]->(o:Assertion)-[:OCCURS_IN]->(container)
WHERE EXISTS {
  MATCH (container)<-[:RENDITION_OF*0..1]-(:Source)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)
  WHERE s.captureCompleteness <> 'COMPLETE'
}
RETURN c.uid AS undisclosedFromPartialCapture;

// F-410 (brand and legal entity collapsed into one identity). status: statically-checked
MATCH (n:ConsumerBrand:LegalEntity)
RETURN n.uid AS collapsedBrandAndLegalEntity;

// F-411 (closed role edge without its source bounds, or role edge without assertion). status: statically-checked
MATCH (s)-[r:SPONSORS_CONTENT|INVESTED_IN|HOLDS_EQUITY_IN|BOARD_MEMBER_OF|ADVISES_ORGANIZATION|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|FOUNDED_ORGANIZATION]->(o)
WHERE r.assertionUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) }
   OR (r.validFrom IS NOT NULL AND r.validTo IS NOT NULL AND r.validTo <= r.validFrom)
   OR EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) WHERE a.validTo IS NOT NULL AND r.validTo IS NULL }
RETURN s.uid AS fromUid, type(r) AS relType, o.uid AS toUid;

// F-412 (group-level equity silently pushed down to a member company). status: statically-checked
MATCH (p:Person)-[r:HOLDS_EQUITY_IN]->(o:Organization)
WHERE NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid})-[:HAS_OBJECT]->(o) }
RETURN p.uid AS holder, o.uid AS organizationWithoutDirectAssertion;

// ---------------------------------------------------------------------------
// Capture-fidelity acceptance (catalog 0.2.0, INV-103). Every ACCEPTED, REJECTED or DISPUTED status is a projection of a
// CAPTURE_FIDELITY adjudication. This fixture records one policy adjudication (reviewerType POLICY) covering the captured
// assertions it created; it says nothing about whether any proposition is true (that is a SUPPORT adjudication).
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:claim-retelling-provenance-capture-fidelity-policy-2026-10-04'})
ON CREATE SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1', j.status = 'FINAL',
    j.rationale = 'Fixture capture policy: the recorded propositions match the cited spans as read by the authoring lane.',
    j.reviewedAt = datetime('2026-10-04T00:00:00Z'), j.recordedAt = datetime('2026-10-04T00:00:00Z'), j.createdAt = datetime('2026-10-04T00:00:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
