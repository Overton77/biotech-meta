// =====================================================================================================
// W21 fixture fx06: a presentation's slide locator (PDF_PAGE, deck = its own Document container) versus the talk's
// locators (the talk = an Episode work with renditions). Decision W21-D06: no Presentation/Talk node type.
// Part A (real, NEW_RETRIEVAL 2026-10-04): Merck & Co. company presentation at the 44th Annual J.P. Morgan
//   Healthcare Conference (2026-01-12). Merck's event page lists three links: webcast, transcript PDF, presentation
//   PDF. The webcast page now says "The recording of this session is not available any more." -> the recording
//   rendition is WITHDRAWN (SourceRevisionEvent); no MEDIA_TIME locator can be made and none is invented. The spoken
//   statement is located in the transcript PDF; the slide statement on page 11 of the deck.
//   Captures via Tavily extract (direct fetch BLOCKED); PDF page index of the slide is ASSUMED equal to the printed
//   slide number "11" (not verified from bytes).
// Part B (SYNTHETIC): a talk whose recording IS available: slide PDF_PAGE versus talk MEDIA_TIME, same speaker,
//   where the spoken version drops the species qualifier printed on the slide.
// Predicates FORECASTS_COMMERCIAL_OPPORTUNITY and REPORTS_LIFESPAN_EFFECT are CANDIDATES (W21-SR-15): PROPOSED.
// =====================================================================================================
UNWIND [
  {u: 'hu:org:merck-and-co', i: 'merck-and-co', n: 'Merck & Co., Inc.'},
  {u: 'hu:org:jpmorgan-chase', i: 'jpmorgan-chase', n: 'JPMorgan Chase & Co'}
] AS o
MERGE (n:Entity:Organization {uid: o.u}) SET n.id = o.i, n.entityType = 'Organization', n.name = o.n, n.createdAt = datetime('2026-10-04T01:00:00Z');
UNWIND [
  {u: 'hu:person:robert-davis-merck', i: 'robert-davis-merck', n: 'Robert Davis'},
  {u: 'hu:person:dean-li-merck', i: 'dean-li-merck', n: 'Dean Li'},
  {u: 'hu:person:christopher-schott-jpm', i: 'christopher-schott-jpm', n: 'Christopher Schott'}
] AS p
MERGE (n:Entity:Person {uid: p.u}) SET n.id = p.i, n.entityType = 'Person', n.name = p.n, n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'})
SET n.id = 'merck-jpm-hc-2026-company-presentation', n.entityType = 'Episode', n.episodeType = 'CONFERENCE_TALK',
    n.name = 'Merck & Co., Inc. company presentation, 44th Annual J.P. Morgan Healthcare Conference',
    n.title = 'Merck & Co., Inc. (44th Annual J.P. Morgan Healthcare Conference)', n.publishedAt = NULL,
    n.description = 'Presented January 12, 2026 4:30 pm PST per the Merck event page; first publication time of the recording not established.',
    n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Agent {uid: 'hu:agent:tavily-extract'})
SET n.id = 'tavily-extract', n.entityType = 'Agent', n.name = 'Tavily extract API', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Agent {uid: 'hu:agent:merck-jpm-2026-transcript-producer-unknown'})
SET n.id = 'merck-jpm-2026-transcript-producer-unknown', n.entityType = 'Agent', n.name = 'Producer of the Merck JPM 2026 transcript (vendor not named in the captured excerpt)', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Agent {uid: 'hu:agent:w21-curator'})
SET n.id = 'w21-curator', n.entityType = 'Agent', n.name = 'W21 fixture curator (Opus 5.5)', n.agentKind = 'MANUAL_AGENT', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (g:Agent {uid: 'hu:agent:merck-jpm-2026-transcript-producer-unknown'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:merck-jpm-2026-transcription'})
SET a.id = 'merck-jpm-2026-transcription', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.methodVersion = 'event transcript; method and vendor not stated in capture', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);
MATCH (g:Agent {uid: 'hu:agent:tavily-extract'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-pdf-text-extraction-2026-10-04'})
SET a.id = 'w21-pdf-text-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'TEXT_EXTRACTION', a.methodVersion = 'tavily-extract (PDF, query-reranked chunks)', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);
MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
SET a.id = 'w21-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'EXTRACTION', a.methodVersion = 'w21-manual-curation-v0.1', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Sources ------------------------------------------------------------------------------------------------
MERGE (n:Entity:Source:Document {uid: 'hu:source:merck-event-jpm-hc-2026'})
SET n.id = 'merck-event-jpm-hc-2026', n.documentId = 'merck-event-jpm-hc-2026', n.entityType = 'Source', n.canonicalUri = 'https://www.merck.com/events/44th-annual-j-p-morgan-healthcare-conference',
    n.title = '44th Annual J.P. Morgan Healthcare Conference - Merck.com', n.sourceKind = 'ORGANIZATION_WEBPAGE', n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Source {uid: 'hu:source:jpm-metameetings-merck-webcast-2026'})
SET n.id = 'jpm-metameetings-merck-webcast-2026', n.entityType = 'Source',
    n.canonicalUri = 'https://jpmorgan.metameetings.net/events/healthcare26/sessions/317179-merck-co-inc/webcast', n.sourceKind = 'VIDEO_RENDITION', n.createdAt = datetime('2026-10-04T01:00:00Z');
// Transcript PDF: a rendition of the talk. sourceKind/documentType for an event transcript are pending (W21-SR-13).
MERGE (n:Entity:Source:Document {uid: 'hu:source:merck-jpm-2026-transcript-pdf'})
SET n.id = 'merck-jpm-2026-transcript-pdf', n.documentId = 'merck-jpm-2026-transcript-pdf', n.entityType = 'Source',
    n.canonicalUri = 'https://s21.q4cdn.com/488056881/files/doc_events/2026/Jan/12/MRK-USQ_Transcript_2026-01-12.pdf', n.sourceKind = NULL, n.type = 'UNKNOWN', n.createdAt = datetime('2026-10-04T01:00:00Z');
// Slide deck PDF: its own container (an authored document), NOT a rendition of the talk.
MERGE (n:Entity:Source:Document {uid: 'hu:source:merck-jpm-2026-presentation-pdf'})
SET n.id = 'merck-jpm-2026-presentation-pdf', n.documentId = 'merck-jpm-2026-presentation-pdf', n.entityType = 'Source',
    n.canonicalUri = 'https://s21.q4cdn.com/488056881/files/doc_events/2026/Jan/12/MRK-2026-JP-Morgan-Presentation.pdf', n.sourceKind = NULL, n.type = 'INVESTOR_PRESENTATION', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (s:Source {uid: 'hu:source:jpm-metameetings-merck-webcast-2026'}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'}) MERGE (s)-[:RENDITION_OF]->(e);
MATCH (s:Source {uid: 'hu:source:merck-jpm-2026-transcript-pdf'}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'}) MERGE (s)-[:RENDITION_OF]->(e);
// Authorship of the deck (W20 AUTHORED_BY): author of the container, distinct from the speaker of the talk.
MATCH (d:Document {uid: 'hu:source:merck-jpm-2026-presentation-pdf'}), (o:Organization {uid: 'hu:org:merck-and-co'}) MERGE (d)-[:AUTHORED_BY]->(o);

UNWIND [
  {src: 'hu:source:merck-event-jpm-hc-2026', u: 'hu:snapshot:merck-event-jpm-hc-2026-2026-10-04', i: 'merck-event-jpm-hc-2026-2026-10-04', h: 'sha256:f35f6828b8fd2126803dc6b78168c6290ad5de7b7ee9a0bce592e7508ebe3c27', f: 'merck-event-page-2026-10-04.txt', t: datetime('2026-10-04T00:55:00Z')},
  {src: 'hu:source:jpm-metameetings-merck-webcast-2026', u: 'hu:snapshot:jpm-metameetings-merck-webcast-2026-2026-10-04', i: 'jpm-metameetings-merck-webcast-2026-2026-10-04', h: 'sha256:ccfe4c9e830614c0a02180711c2704ddd59373afec0d3a5b47428365f8313841', f: 'merck-webcast-2026-10-04.txt', t: datetime('2026-10-04T00:57:00Z')},
  {src: 'hu:source:merck-jpm-2026-transcript-pdf', u: 'hu:snapshot:merck-jpm-2026-transcript-pdf-2026-10-04', i: 'merck-jpm-2026-transcript-pdf-2026-10-04', h: 'sha256:46b0bf38e816d2c2054ddc2c4d761df1347d0c56da200cab7b9b6f009348fc63', f: 'merck-transcript-2026-10-04.txt', t: datetime('2026-10-04T00:56:00Z')},
  {src: 'hu:source:merck-jpm-2026-presentation-pdf', u: 'hu:snapshot:merck-jpm-2026-presentation-pdf-2026-10-04', i: 'merck-jpm-2026-presentation-pdf-2026-10-04', h: 'sha256:b9bb280cdac1f12d403bf005e8ec10264547c33fea097446632c964d08497947', f: 'merck-deck-2026-10-04.txt', t: datetime('2026-10-04T00:56:00Z')}
] AS row
MATCH (src:Source {uid: row.src})
MERGE (s:InformationArtifact:SourceSnapshot {uid: row.u})
SET s.id = row.i, s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = row.t, s.observedAt = row.t, s.contentHash = row.h,
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.storageUri = 'repo:workers/W21/excerpts/' + row.f, s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// The recording is withdrawn: a revision of the webcast Source, announced in the captured page; time of withdrawal unknown.
MATCH (src:Source {uid: 'hu:source:jpm-metameetings-merck-webcast-2026'}), (s:SourceSnapshot {uid: 'hu:snapshot:jpm-metameetings-merck-webcast-2026-2026-10-04'})
MERGE (ev:Occurrence:SourceRevisionEvent {uid: 'hu:source-revision:jpm-metameetings-merck-webcast-withdrawn'})
SET ev.id = 'jpm-metameetings-merck-webcast-withdrawn', ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'WITHDRAWAL', ev.occurredAt = NULL,
    ev.recordedAt = datetime('2026-10-04T01:00:00Z'), ev.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (ev)-[:REVISES_SOURCE]->(src)
MERGE (ev)-[:ANNOUNCED_IN]->(s);

MATCH (src:Source {uid: 'hu:source:merck-jpm-2026-transcript-pdf'}), (s:SourceSnapshot {uid: 'hu:snapshot:merck-jpm-2026-transcript-pdf-2026-10-04'}),
      (tr:Activity {uid: 'hu:activity:merck-jpm-2026-transcription'}), (ex:Activity {uid: 'hu:activity:w21-pdf-text-extraction-2026-10-04'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:merck-jpm-2026-transcript-pdf-2026-10-04'})
SET tv.id = 'merck-jpm-2026-transcript-pdf-2026-10-04', tv.documentTextVersionId = 'merck-jpm-2026-transcript-pdf-2026-10-04', tv.artifactType = 'DocumentTextVersion',
    tv.textVersionHash = s.contentHash, tv.source = 'pdf text extraction (excerpt)', tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(ex)
MERGE (ex)-[:USED]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(tr);

// ---- Locators ------------------------------------------------------------------------------------------------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:merck-jpm-2026-presentation-pdf-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-merck-deck-slide-11-more-than-double'})
SET l.id = 'w21-merck-deck-slide-11-more-than-double', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#page=11', l.selectorKind = 'PDF_PAGE', l.page = 11,
    l.exact = 'Commercial opportunity from new growth drivers is more than double consensus 2028 total KEYTRUDA sales',
    l.quoteHash = 'sha256:99c3ca2eb9f7e1e864ffb623304bd97f3dc75ab5d47c2beb75ae08a820f8a7cb',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:merck-jpm-2026-transcript-pdf-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:merck-jpm-2026-transcript-pdf-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-merck-transcript-davis-70-billion'})
SET l.id = 'w21-merck-transcript-davis-70-billion', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "The fact that we now have that $70 billion and that we're going to be able to be in a situation by the time we get to the end of 2027 to have clinically de-risked almost all of that is very important.",
    l.quoteHash = "sha256:9b0be6158f49027187f8683cc05b5d15db67c15ee7aee5014a99721762d5b0d5",
    l.prefix = "Based on what I just showed you, we're highly confident. ", l.normalizationVersion = 'NFC-WS1',
    l.speakerLabelInSource = 'Robert Davis - Merck & Co Inc - Chairman of the Board, President, Chief Executive Officer', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:merck-jpm-2026-transcript-pdf-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:merck-jpm-2026-transcript-pdf-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-merck-transcript-schott-introduces'})
SET l.id = 'w21-merck-transcript-schott-introduces', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = "Christopher Schott - JPMorgan Chase & Co - Analyst Good afternoon, everybody. I'm Chris Schott at JPMorgan. It's my pleasure to be introducing Merck today.",
    l.quoteHash = "sha256:653ce11c2cadec3ee8fd21b94bbf1979703ca21c05ce9c364ef291cc77455f9e",
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = 'Christopher Schott - JPMorgan Chase & Co - Analyst', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:merck-jpm-2026-transcript-pdf-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:merck-jpm-2026-transcript-pdf-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-merck-transcript-participant-dean-li'})
SET l.id = 'w21-merck-transcript-participant-dean-li', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Dean Li Merck & Co Inc - Executive Vice President, President - Merck Research Laboratories',
    l.quoteHash = 'sha256:be7a40a4c5ed5e5699cea76febdeaea8fa4f81d79a9944dd63b78612602832f7',
    l.section = 'CORPORATE PARTICIPANTS', l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// ---- Claim and occurrences: slide (organization, deck container) versus speech (person, talk container) -------
MERGE (c:Entity:Claim {uid: 'hu:claim:merck-mid-2030s-new-growth-driver-opportunity-gt-70b'})
SET c.id = 'merck-mid-2030s-new-growth-driver-opportunity-gt-70b', c.entityType = 'Claim',
    c.claimText = 'Merck expects a mid-2030s non-risk-adjusted commercial opportunity from new growth drivers of more than $70B, more than double consensus 2028 total KEYTRUDA sales.',
    c.claimType = 'COMMERCIAL_CLAIM', c.isQuantitative = true, c.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (o:Organization {uid: 'hu:org:merck-and-co'}), (d:Document {uid: 'hu:source:merck-jpm-2026-presentation-pdf'}), (l:SourceLocator {uid: 'hu:locator:w21-merck-deck-slide-11-more-than-double'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}), (c:Claim {uid: 'hu:claim:merck-mid-2030s-new-growth-driver-opportunity-gt-70b'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-merck-deck-slide-11-opportunity'})
SET a.id = 'w21-merck-deck-slide-11-opportunity', a.predicate = 'FORECASTS_COMMERCIAL_OPPORTUNITY', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.assertionBasis = 'UNSTATED',
    a.speechAct = 'STATES', a.valueString = '>$70B mid-2030s, non-risk-adjusted; >2X consensus 2028 total KEYTRUDA sales', a.utteranceText = l.exact,
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:OCCURS_IN]->(d)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

MATCH (p:Person {uid: 'hu:person:robert-davis-merck'}), (o:Organization {uid: 'hu:org:merck-and-co'}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'}),
      (l:SourceLocator {uid: 'hu:locator:w21-merck-transcript-davis-70-billion'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'}),
      (c:Claim {uid: 'hu:claim:merck-mid-2030s-new-growth-driver-opportunity-gt-70b'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-merck-talk-davis-70-billion'})
SET a.id = 'w21-merck-talk-davis-70-billion', a.predicate = 'FORECASTS_COMMERCIAL_OPPORTUNITY', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.assertionBasis = 'UNSTATED',
    a.speechAct = 'STATES', a.valueString = '$70 billion; clinically de-risked almost all by end of 2027', a.utteranceText = l.exact,
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:OCCURS_IN]->(e)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

// Appearance roles from the transcript participant block (MODERATOR requested in RoleType, W21-SR-09).
UNWIND [
  {a: 'hu:assertion:w21-merck-jpm-schott-moderator', i: 'w21-merck-jpm-schott-moderator', p: 'hu:person:christopher-schott-jpm', role: 'MODERATOR', l: 'hu:locator:w21-merck-transcript-schott-introduces', t: 'Analyst', rel: 'hu:rel:w21-appears-in-schott-merck-jpm'},
  {a: 'hu:assertion:w21-merck-jpm-davis-speaker', i: 'w21-merck-jpm-davis-speaker', p: 'hu:person:robert-davis-merck', role: 'SPEAKER', l: 'hu:locator:w21-merck-transcript-davis-70-billion', t: 'Chairman of the Board, President, Chief Executive Officer', rel: 'hu:rel:w21-appears-in-davis-merck-jpm'},
  {a: 'hu:assertion:w21-merck-jpm-li-speaker', i: 'w21-merck-jpm-li-speaker', p: 'hu:person:dean-li-merck', role: 'SPEAKER', l: 'hu:locator:w21-merck-transcript-participant-dean-li', t: 'Executive Vice President, President - Merck Research Laboratories', rel: 'hu:rel:w21-appears-in-li-merck-jpm'}
] AS row
MATCH (p:Person {uid: row.p}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'}), (l:SourceLocator {uid: row.l}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion {uid: row.a})
SET a.id = row.i, a.predicate = 'APPEARS_IN', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.roleType = row.role, a.roleTitleVerbatim = row.t,
    a.validFrom = datetime('2026-01-12T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(e)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (p)-[r:APPEARS_IN {assertionUid: row.a}]->(e)
SET r.relationshipUid = row.rel, r.roleType = row.role, r.roleTitleVerbatim = row.t, r.validFrom = datetime('2026-01-12T00:00:00Z'), r.validFromPrecision = 'DAY',
    r.validFromBasis = 'STATED_BY_SOURCE', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:00:00Z');

// ---- Part B (SYNTHETIC): slide PDF_PAGE versus talk MEDIA_TIME, same speaker, qualifier dropped in speech ------
MERGE (n:Entity:Person {uid: 'hu:person:synthetic-conference-speaker'})
SET n.id = 'synthetic-conference-speaker', n.entityType = 'Person', n.name = 'Synthetic Conference Speaker (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:synthetic-compound-y'})
SET n.id = 'synthetic-compound-y', n.entityType = 'ChemicalSubstance', n.name = 'Compound Y (fixture only)', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Episode {uid: 'hu:episode:synthetic-example-longevity-conf-2026-talk-3'})
SET n.id = 'synthetic-example-longevity-conf-2026-talk-3', n.entityType = 'Episode', n.episodeType = 'CONFERENCE_TALK', n.name = 'Example Longevity Conference 2026, talk 3 (fixture only)',
    n.publishedAt = datetime('2026-06-02T00:00:00Z'), n.publishedAtPrecision = 'DAY', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Source {uid: 'hu:source:synthetic-conf-talk-3-recording'})
SET n.id = 'synthetic-conf-talk-3-recording', n.entityType = 'Source', n.canonicalUri = 'https://video.example.invalid/example-longevity-conf-2026/talk-3', n.sourceKind = 'VIDEO_RENDITION',
    n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MERGE (n:Entity:Source:Document {uid: 'hu:source:synthetic-conf-talk-3-slides'})
SET n.id = 'synthetic-conf-talk-3-slides', n.documentId = 'synthetic-conf-talk-3-slides', n.entityType = 'Source', n.canonicalUri = 'https://files.example.invalid/example-longevity-conf-2026/talk-3-slides.pdf',
    n.type = 'CONFERENCE_PRESENTATION', n.fixtureProvenance = 'SYNTHETIC', n.createdAt = datetime('2026-10-04T01:00:00Z');
MATCH (s:Source {uid: 'hu:source:synthetic-conf-talk-3-recording'}), (e:Episode {uid: 'hu:episode:synthetic-example-longevity-conf-2026-talk-3'}) MERGE (s)-[:RENDITION_OF]->(e);
MATCH (d:Document {uid: 'hu:source:synthetic-conf-talk-3-slides'}), (p:Person {uid: 'hu:person:synthetic-conference-speaker'}) MERGE (d)-[:AUTHORED_BY]->(p);
UNWIND [
  {src: 'hu:source:synthetic-conf-talk-3-recording', u: 'hu:snapshot:synthetic-conf-talk-3-recording-2026-10-04', i: 'synthetic-conf-talk-3-recording-2026-10-04', h: 'sha256:2039bf6b21edf5114eb6ec231c0cc8f906ad335919f543219aa4fcddf842b0a8'},
  {src: 'hu:source:synthetic-conf-talk-3-slides', u: 'hu:snapshot:synthetic-conf-talk-3-slides-2026-10-04', i: 'synthetic-conf-talk-3-slides-2026-10-04', h: 'sha256:f37c76c324bd12269080b19ce0244992037a43ad12475985238c83da96e6dc74'}
] AS row
MATCH (src:Source {uid: row.src})
MERGE (s:InformationArtifact:SourceSnapshot {uid: row.u})
SET s.id = row.i, s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:00:00Z'), s.observedAt = datetime('2026-10-04T00:00:00Z'),
    s.contentHash = row.h, s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-conf-talk-3-slides-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-conf-talk-3-slide-7'})
SET l.id = 'synthetic-conf-talk-3-slide-7', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#page=7', l.selectorKind = 'PDF_PAGE', l.page = 7,
    l.exact = 'Compound Y: median lifespan +12% (male C57BL/6 mice, n=40)', l.quoteHash = 'sha256:6f163a4336f8b627e55937ea318c98f37aeec929d958b3df7f7954fb5b4a5cff',
    l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-conf-talk-3-recording-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-conf-talk-3-recording-1834s'})
SET l.id = 'synthetic-conf-talk-3-recording-1834s', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#t=1834', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 1834.0, l.mediaEndSeconds = 1841.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = 'Compound Y extended lifespan by about twelve percent.', l.quoteHash = 'sha256:8e4880a9f328f98637b3c9922d251c08bcc828b6f07f770e63f1ae3de92cd343',
    l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);
MERGE (c:Entity:Claim {uid: 'hu:claim:synthetic-compound-y-extends-median-lifespan-12pct'})
SET c.id = 'synthetic-compound-y-extends-median-lifespan-12pct', c.entityType = 'Claim', c.claimText = 'Compound Y extends median lifespan by about 12%.', c.claimType = 'EFFICACY_CLAIM',
    c.fixtureProvenance = 'SYNTHETIC', c.createdAt = datetime('2026-10-04T01:00:00Z');
UNWIND [
  {a: 'hu:claim-occurrence:synthetic-conf-talk-3-slide-claim', i: 'synthetic-conf-talk-3-slide-claim', k: 'hu:source:synthetic-conf-talk-3-slides', l: 'hu:locator:synthetic-conf-talk-3-slide-7', basis: 'STUDY_RESULT'},
  {a: 'hu:claim-occurrence:synthetic-conf-talk-3-spoken-claim', i: 'synthetic-conf-talk-3-spoken-claim', k: 'hu:episode:synthetic-example-longevity-conf-2026-talk-3', l: 'hu:locator:synthetic-conf-talk-3-recording-1834s', basis: 'STUDY_RESULT'}
] AS row
MATCH (p:Person {uid: 'hu:person:synthetic-conference-speaker'}), (y:ChemicalSubstance {uid: 'hu:substance:synthetic-compound-y'}), (k {uid: row.k}), (l:SourceLocator {uid: row.l}),
      (c:Claim {uid: 'hu:claim:synthetic-compound-y-extends-median-lifespan-12pct'})
MERGE (a:Assertion:ClaimOccurrence {uid: row.a})
SET a.id = row.i, a.predicate = 'REPORTS_LIFESPAN_EFFECT', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.assertionBasis = row.basis, a.speechAct = 'STATES',
    a.valueNumber = 12.0, a.unitCode = '%', a.utteranceText = l.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.fixtureProvenance = 'SYNTHETIC',
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(y)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:OCCURS_IN]->(k)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';
