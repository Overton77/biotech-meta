// W00 fixture 09 — a real retraction as a SourceRevisionEvent, and the five provenance states (CQ-EV-02, CQ-EV-05, CQ-TM-06,
// CQ-PV-01, CQ-PV-03, CQ-PV-06). Real records, NEW_RETRIEVAL on 2026-10-04 through the PubMed MCP connector (get_article_metadata):
//   PMID 9500320, DOI 10.1016/s0140-6736(97)11096-0, Lancet 1998;351(9103):637-41, published 1998-02-28,
//     article_types ["Journal Article", "Research Support, Non-U.S. Gov't", "Retracted Publication"];
//   PMID 20137807, DOI 10.1016/S0140-6736(10)60175-4, "Retraction--Ileal-lymphoid-nodular hyperplasia, ...", 2010-02-06, ["Retraction Notice"].
// SYNTHETIC parts (labelled): the 2009 "prior" capture and every BellLabs record dated before 2026-10-04 (a fixture device to exercise
// PRIOR_SNAPSHOT); the policy version; the answer-composition activity. No bytes were stored, so every contentHashBasis is SYNTHETIC_FIXTURE.
// The predicate REPORTS_FINDING is a CANDIDATE predicate (owner W09); it is used only to carry the quoted abstract sentence.
// What this fixture cannot establish: anything about the truth of the 1998 report beyond what the records say; the retraction notice's reasons.

UNWIND [
  {uid: 'hu:agent:w00-pubmed-mcp', id: 'w00-pubmed-mcp', name: 'PubMed MCP connector (get_article_metadata)', kind: 'AUTOMATED_AGENT'},
  {uid: 'hu:agent:w00-answer-composer', id: 'w00-answer-composer', name: 'Synthetic answer composer', kind: 'COMPUTATIONAL_MODEL'}
] AS row
MERGE (n:Agent:Entity {uid: row.uid})
ON CREATE SET n.id = row.id, n.entityType = 'Agent', n.name = row.name, n.agentKind = row.kind, n.toolVersion = 'unknown', n.privacyClass = 'INTERNAL',
  n.createdAt = datetime('2009-06-01T00:00:00Z'), n.updatedAt = datetime('2009-06-01T00:00:00Z');

UNWIND [
  {uid: 'hu:activity:w00-pubmed-capture-2009', id: 'w00-pubmed-capture-2009', kind: 'CAPTURE', t: datetime('2009-06-01T00:00:00Z'), m: 'synthetic-capture-v0'},
  {uid: 'hu:activity:w00-pubmed-capture-2026-10-04', id: 'w00-pubmed-capture-2026-10-04', kind: 'CAPTURE', t: datetime('2026-10-04T01:00:00Z'), m: 'pubmed-mcp-get-article-metadata'},
  {uid: 'hu:activity:w00-pubmed-extraction-2009', id: 'w00-pubmed-extraction-2009', kind: 'EXTRACTION', t: datetime('2009-06-01T00:30:00Z'), m: 'w00-manual-curation-v1'},
  {uid: 'hu:activity:w00-answer-composition-1', id: 'w00-answer-composition-1', kind: 'ANSWER_COMPOSITION', t: datetime('2026-10-04T02:00:00Z'), m: 'synthetic-answer-v0'}
] AS row
MERGE (n:Activity:Occurrence {uid: row.uid})
ON CREATE SET n.id = row.id, n.occurrenceType = 'Activity', n.activityKind = row.kind, n.methodVersion = row.m, n.startedAt = row.t,
  n.privacyClass = 'INTERNAL', n.createdAt = row.t, n.updatedAt = row.t;

MATCH (a1:Activity {uid: 'hu:activity:w00-pubmed-capture-2026-10-04'}), (g1:Agent {uid: 'hu:agent:w00-pubmed-mcp'}),
      (a2:Activity {uid: 'hu:activity:w00-answer-composition-1'}), (g2:Agent {uid: 'hu:agent:w00-answer-composer'})
MERGE (a1)-[:WAS_ASSOCIATED_WITH]->(g1)
MERGE (a2)-[:WAS_ASSOCIATED_WITH]->(g2);

MERGE (n:Organization:Entity {uid: 'hu:org:w00-the-lancet'})
ON CREATE SET n.id = 'w00-the-lancet', n.entityType = 'Organization', n.name = 'The Lancet (Elsevier)', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-10-04T01:00:00Z'), n.updatedAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:PolicyVersion:VersionedState {uid: 'hu:policy-version:w00-synthetic-policy-v0'})
ON CREATE SET n.id = 'w00-synthetic-policy-v0', n.stateType = 'PolicyVersion', n.name = 'Synthetic use policy v0', n.payloadHash = 'sha256:synthetic-policy-v0',
  n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-10-01T00:00:00Z'), n.updatedAt = datetime('2026-10-01T00:00:00Z');

// Works (W09 Publication) and their PubMed-record renditions (Sources). DOI belongs to the work (CL-003 ruling).
UNWIND [
  {pub: 'hu:publication:w00-pmid-9500320', pid: 'w00-pmid-9500320', title: 'Ileal-lymphoid-nodular hyperplasia, non-specific colitis, and pervasive developmental disorder in children.',
   src: 'hu:source:w00-pubmed-9500320', sid: 'w00-pubmed-9500320', uri: 'https://pubmed.ncbi.nlm.nih.gov/9500320/', kind: 'PEER_REVIEWED_PUBLICATION', pubAt: datetime('1998-02-28T00:00:00Z')},
  {pub: 'hu:publication:w00-pmid-20137807', pid: 'w00-pmid-20137807', title: 'Retraction--Ileal-lymphoid-nodular hyperplasia, non-specific colitis, and pervasive developmental disorder in children.',
   src: 'hu:source:w00-pubmed-20137807', sid: 'w00-pubmed-20137807', uri: 'https://pubmed.ncbi.nlm.nih.gov/20137807/', kind: 'RETRACTION_NOTICE', pubAt: datetime('2010-02-06T00:00:00Z')}
] AS row
MERGE (p:Publication:InformationArtifact {uid: row.pub})
ON CREATE SET p.id = row.pid, p.artifactType = 'Publication', p.name = row.title, p.publishedAt = row.pubAt, p.privacyClass = 'PUBLIC',
  p.createdAt = datetime('2009-06-01T00:00:00Z'), p.updatedAt = datetime('2009-06-01T00:00:00Z')
MERGE (s:Source:Entity {uid: row.src})
ON CREATE SET s.id = row.sid, s.entityType = 'Source', s.canonicalUri = row.uri, s.title = row.title, s.sourceKind = row.kind, s.privacyClass = 'PUBLIC',
  s.createdAt = datetime('2009-06-01T00:00:00Z'), s.updatedAt = datetime('2009-06-01T00:00:00Z')
MERGE (s)-[:RENDITION_OF]->(p);

UNWIND [
  {src: 'hu:source:w00-pubmed-9500320', uid: 'hu:snapshot:w00-pubmed-9500320-synthetic-2009', id: 'w00-pubmed-9500320-synthetic-2009', t: datetime('2009-06-01T00:00:00Z'),
   h: 'sha256:5e5a2c27348a3e712db8967d59d7b5a9118ba3f5b1b02d006e24a0a88ef2607d', act: 'hu:activity:w00-pubmed-capture-2009'},
  {src: 'hu:source:w00-pubmed-9500320', uid: 'hu:snapshot:w00-pubmed-9500320-2026-10-04', id: 'w00-pubmed-9500320-2026-10-04', t: datetime('2026-10-04T01:00:00Z'),
   h: 'sha256:fda387226ec73b99ec60af8c2b17079b04798cba7dd702a1c0eddc3d8d0f4c67', act: 'hu:activity:w00-pubmed-capture-2026-10-04'},
  {src: 'hu:source:w00-pubmed-20137807', uid: 'hu:snapshot:w00-pubmed-20137807-2026-10-04', id: 'w00-pubmed-20137807-2026-10-04', t: datetime('2026-10-04T01:00:00Z'),
   h: 'sha256:e28bde6c4dc3020a63aa80d4611d8b31a28eeeaf738f6de322d21e36797958a6', act: 'hu:activity:w00-pubmed-capture-2026-10-04'}
] AS row
MATCH (src:Source {uid: row.src}), (act:Activity {uid: row.act})
MERGE (s:SourceSnapshot:InformationArtifact {uid: row.uid})
ON CREATE SET s.id = row.id, s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = row.t, s.observedAt = row.t,
  s.contentHash = row.h, s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'PARTIAL_EXCERPT', s.mimeType = 'application/json',
  s.privacyClass = 'PUBLIC', s.createdAt = row.t, s.updatedAt = row.t
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

UNWIND [
  {snap: 'hu:snapshot:w00-pubmed-9500320-synthetic-2009', uid: 'hu:locator:w00-9500320-abstract-onset', id: 'w00-9500320-abstract-onset', sec: 'AbstractText',
   exact: 'Onset of behavioural symptoms was associated, by the parents, with measles, mumps, and rubella vaccination in eight of the 12 children, with measles infection in one child, and otitis media in another.',
   qh: 'sha256:31d6d50a8a6a971f9a0c240f246acd85946a9be29a1792c81de08a040e91e480'},
  {snap: 'hu:snapshot:w00-pubmed-9500320-2026-10-04', uid: 'hu:locator:w00-9500320-pt-retracted', id: 'w00-9500320-pt-retracted', sec: 'PublicationTypeList',
   exact: 'Retracted Publication', qh: 'sha256:a95e852b2b072c8df3bd768bd515b8fbd3d79a2156cf4a4fcd1a39a47adb25c1'},
  {snap: 'hu:snapshot:w00-pubmed-20137807-2026-10-04', uid: 'hu:locator:w00-20137807-title', id: 'w00-20137807-title', sec: 'ArticleTitle',
   exact: 'Retraction--Ileal-lymphoid-nodular hyperplasia, non-specific colitis, and pervasive developmental disorder in children.',
   qh: 'sha256:6f376f817ea5b0af794aaa789f7327b185f9d287a37b30d9be5661a79862faa6'}
] AS row
MATCH (s:SourceSnapshot {uid: row.snap})
MERGE (l:SourceLocator:InformationArtifact {uid: row.uid})
ON CREATE SET l.id = row.id, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = row.sec,
  l.exact = row.exact, l.quoteHash = row.qh, l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = s.createdAt, l.updatedAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l);

// State 1+2 (synthetic 2009 record): what the article reported, with its span. Status = capture fidelity.
MATCH (pub:Publication {uid: 'hu:publication:w00-pmid-9500320'}), (l:SourceLocator {uid: 'hu:locator:w00-9500320-abstract-onset'}),
      (act:Activity {uid: 'hu:activity:w00-pubmed-extraction-2009'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-9500320-reports-parental-association'})
ON CREATE SET a.id = 'w00-9500320-reports-parental-association', a.predicate = 'REPORTS_FINDING', a.predicateClass = 'CLAIM', a.polarity = 'POSITIVE',
  a.status = 'ACCEPTED', a.speechAct = 'STATES', a.assertionBasis = 'STUDY_RESULT', a.valueString = l.exact,
  a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2009-06-01T01:00:00Z'),
  a.contentHash = 'sha256:synthetic-content-w00-9500320-reports', a.extractionConfidence = 1.0, a.privacyClass = 'PUBLIC',
  a.createdAt = datetime('2009-06-01T01:00:00Z'), a.updatedAt = datetime('2009-06-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(pub)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// The publisher's retraction, as an assertion asserted by the publisher (RETRACTS_SOURCE, catalog provenance.assertedPredicates).
MATCH (notice:Source {uid: 'hu:source:w00-pubmed-20137807'}), (art:Source {uid: 'hu:source:w00-pubmed-9500320'}),
      (pubOrg:Organization {uid: 'hu:org:w00-the-lancet'}), (l:SourceLocator {uid: 'hu:locator:w00-20137807-title'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-20137807-retracts-9500320'})
ON CREATE SET a.id = 'w00-20137807-retracts-9500320', a.predicate = 'RETRACTS_SOURCE', a.predicateClass = 'OTHER', a.polarity = 'POSITIVE',
  a.status = 'ACCEPTED', a.speechAct = 'STATES', a.validFrom = datetime('2010-02-06T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY',
  a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:10:00Z'), a.contentHash = 'sha256:synthetic-content-w00-retracts',
  a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:10:00Z'), a.updatedAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(notice)
MERGE (a)-[:HAS_OBJECT]->(art)
MERGE (a)-[:ASSERTED_BY]->(pubOrg)
MERGE (a)-[:SUPPORTED_BY]->(l);

// The revision event: learned 2026-10-04 (recordedAt), issued 2010-02-06 (occurredAt).
MERGE (ev:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:w00-pmid-9500320-retraction'})
ON CREATE SET ev.id = 'w00-pmid-9500320-retraction', ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'RETRACTION',
  ev.occurredAt = datetime('2010-02-06T00:00:00Z'), ev.occurredAtPrecision = 'DAY', ev.recordedAt = datetime('2026-10-04T01:05:00Z'),
  ev.privacyClass = 'PUBLIC', ev.createdAt = datetime('2026-10-04T01:05:00Z'), ev.updatedAt = datetime('2026-10-04T01:05:00Z');

MATCH (ev:SourceRevisionEvent {uid: 'hu:source-revision:w00-pmid-9500320-retraction'}), (art:Source {uid: 'hu:source:w00-pubmed-9500320'}),
      (prior:SourceSnapshot {uid: 'hu:snapshot:w00-pubmed-9500320-synthetic-2009'}), (res:SourceSnapshot {uid: 'hu:snapshot:w00-pubmed-9500320-2026-10-04'}),
      (ann:SourceSnapshot {uid: 'hu:snapshot:w00-pubmed-20137807-2026-10-04'})
MERGE (ev)-[:REVISES_SOURCE]->(art)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(prior)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(res)
MERGE (ev)-[:ANNOUNCED_IN]->(ann);

// Adjudications: capture fidelity (feeds status) and support (never feeds status); the 2026 SUPPORT re-review supersedes the 2009 one.
UNWIND [
  {uid: 'hu:adjudication:w00-9500320-cf', id: 'w00-9500320-cf', a: 'hu:assertion:w00-9500320-reports-parental-association', kind: 'CAPTURE_FIDELITY',
   verdict: 'SUPPORTED', rt: 'POLICY', t: datetime('2009-06-01T02:00:00Z'), loc: 'hu:locator:w00-9500320-abstract-onset', rat: null},
  {uid: 'hu:adjudication:w00-9500320-support-2009', id: 'w00-9500320-support-2009', a: 'hu:assertion:w00-9500320-reports-parental-association', kind: 'SUPPORT',
   verdict: 'PARTIALLY_SUPPORTED', rt: 'HUMAN', t: datetime('2009-06-01T03:00:00Z'), loc: 'hu:locator:w00-9500320-abstract-onset',
   rat: 'Uncontrolled case series of 12; association is parental report (synthetic 2009 review).'},
  {uid: 'hu:adjudication:w00-9500320-support-2026', id: 'w00-9500320-support-2026', a: 'hu:assertion:w00-9500320-reports-parental-association', kind: 'SUPPORT',
   verdict: 'INSUFFICIENT', rt: 'HUMAN', t: datetime('2026-10-04T01:20:00Z'), loc: 'hu:locator:w00-20137807-title',
   rat: 'Source retracted (PMID 20137807). The record of what the article said stays ACCEPTED; BellLabs no longer relies on it. A retraction does not establish the opposite.'},
  {uid: 'hu:adjudication:w00-retracts-cf', id: 'w00-retracts-cf', a: 'hu:assertion:w00-20137807-retracts-9500320', kind: 'CAPTURE_FIDELITY',
   verdict: 'SUPPORTED', rt: 'POLICY', t: datetime('2026-10-04T01:15:00Z'), loc: 'hu:locator:w00-20137807-title', rat: null}
] AS row
MATCH (a:Assertion {uid: row.a}), (l:SourceLocator {uid: row.loc})
MERGE (j:Adjudication:EvidenceAssessment {uid: row.uid})
ON CREATE SET j.id = row.id, j.assessmentType = 'Adjudication', j.methodVersion = 'w00-review-v1', j.status = 'ACCEPTED',
  j.adjudicationKind = row.kind, j.verdict = row.verdict, j.reviewerType = row.rt, j.reviewedAt = row.t, j.recordedAt = row.t, j.rationale = row.rat,
  j.privacyClass = 'INTERNAL', j.createdAt = row.t, j.updatedAt = row.t
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

MATCH (newer:Adjudication {uid: 'hu:adjudication:w00-9500320-support-2026'}), (older:Adjudication {uid: 'hu:adjudication:w00-9500320-support-2009'})
MERGE (newer)-[s:SUPERSEDES]->(older)
ON CREATE SET s.supersessionKind = 'SOURCE_REVISION', s.recordedAt = datetime('2026-10-04T01:20:00Z'),
  s.sourceRevisionEventUid = 'hu:source-revision:w00-pmid-9500320-retraction';

// State 4+5: an answer-composition activity used the assertion and its locator under a policy-allowed use.
MATCH (act:Activity {uid: 'hu:activity:w00-answer-composition-1'}), (a:Assertion {uid: 'hu:assertion:w00-9500320-reports-parental-association'}),
      (l:SourceLocator {uid: 'hu:locator:w00-9500320-abstract-onset'}), (pv:PolicyVersion {uid: 'hu:policy-version:w00-synthetic-policy-v0'})
MERGE (act)-[:USED]->(a)
MERGE (act)-[:USED]->(l)
MERGE (act)-[u:AUTHORIZED_BY]->(pv)
ON CREATE SET u.useKind = 'SUMMARIZE_IN_ANSWER';
