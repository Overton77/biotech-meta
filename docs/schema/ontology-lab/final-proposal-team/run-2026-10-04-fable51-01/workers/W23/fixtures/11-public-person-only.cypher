// W23 fixture 11: public-person-only rule for RECORDS, POSTS_RESULT, HAS_PARTICIPANT_TOKEN, REPORTS (CL-018, CL-008).
// Load 00-shared-base.cypher first. Part P is POSITIVE (must pass V-W23-05/06). Part N is NEGATIVE (each defect is
// expected to be reported; expected rows in 06-fixtures-and-queries.md). All people, values and pages are synthetic.
// Uid tokens observation, cohort-participant, experience-report, protocol-result are not yet in conventions.uidTypeTokens
// (owners W16, W01, W21; requested in W23-SR-01 for completeness).

// ===== Part P (positive): a public figure's own published self-report, and a published case-series participant =====
MERGE (hp:Person:Entity {uid: 'hu:person:w23-public-biohacker'})
SET hp.id = 'w23-public-biohacker', hp.entityType = 'PERSON', hp.name = 'Synthetic Public Biohacker', hp.privacyClass = 'PUBLIC',
    hp.createdAt = datetime('2026-01-20T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:w23-public-blog-post'})
SET s.id = 'w23-public-blog-post', s.entityType = 'SOURCE', s.canonicalUri = 'https://example.invalid/w23/biohacker/blog/rhr',
    s.title = 'Morning metrics (synthetic public blog post)', s.sourceKind = 'SELF_DISCLOSURE_PAGE', s.privacyClass = 'PUBLIC',
    s.createdAt = datetime('2026-01-20T12:00:00Z');

MATCH (s:Source {uid: 'hu:source:w23-public-blog-post'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w23-public-blog-2026-01-20'})
SET sn.id = 'w23-public-blog-2026-01-20', sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = s.canonicalUri,
    sn.publishedAt = datetime('2026-01-20T07:00:00Z'), sn.observedAt = datetime('2026-01-20T12:00:00Z'), sn.retrievedAt = datetime('2026-01-20T12:00:00Z'),
    sn.contentHash = 'sha256:2e2e19c3dacc6eb72e92e091e534277a053810169ef40a6ea5e76bbe9b4e6f5e', sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-01-20T12:00:00Z')
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w23-public-blog-rhr-quote'})
SET l.id = 'w23-public-blog-rhr-quote', l.artifactType = 'SOURCE_LOCATOR', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My resting heart rate this morning was 48 bpm.', l.quoteHash = 'sha256:2095da16ccfc9bd62d5512c5e37cc5e35a1531c5e5694451664376cfce7c9d0e',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-01-20T12:00:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:w23-public-rhr-2026-01-20'})
SET o.id = 'w23-public-rhr-2026-01-20', o.artifactType = 'OBSERVATION', o.observationType = 'SELF_REPORTED_VITAL_SIGN',
    o.observedAt = datetime('2026-01-20T00:00:00Z'), o.valueNumber = 48.0, o.unitCode = '/min', o.privacyClass = 'PUBLIC',
    o.createdAt = datetime('2026-01-20T12:10:00Z');

MATCH (hp:Person {uid: 'hu:person:w23-public-biohacker'}), (o:Observation {uid: 'hu:observation:w23-public-rhr-2026-01-20'}),
      (l:SourceLocator {uid: 'hu:locator:w23-public-blog-rhr-quote'})
MERGE (a:Assertion {uid: 'hu:assertion:w23-public-person-records-rhr'})
SET a.id = 'w23-public-person-records-rhr', a.predicate = 'RECORDS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'STATES', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-01-20T12:10:00Z'), a.contentHash = 'sha256:70ebe49e91f2af80fd347f9d2e4de44f1320c44ffb81bc11cade2565c3396cee',
    a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(hp)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(hp)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (hp)-[e:RECORDS {relationshipUid: 'hu:rel:w23-public-person-records-rhr'}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

MERGE (cs:Source:Entity {uid: 'hu:source:w23-case-series-page'})
SET cs.id = 'w23-case-series-page', cs.entityType = 'SOURCE', cs.canonicalUri = 'https://example.invalid/w23/case-series/glycine-sleep',
    cs.title = 'Glycine and sleep onset: a case series (synthetic)', cs.sourceKind = 'PEER_REVIEWED_PUBLICATION', cs.privacyClass = 'PUBLIC',
    cs.createdAt = datetime('2025-11-03T09:00:00Z');

MATCH (cs:Source {uid: 'hu:source:w23-case-series-page'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w23-case-series-2025-11-03'})
SET sn.id = 'w23-case-series-2025-11-03', sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = cs.canonicalUri,
    sn.publishedAt = datetime('2025-10-01T00:00:00Z'), sn.observedAt = datetime('2025-11-03T09:00:00Z'), sn.retrievedAt = datetime('2025-11-03T09:00:00Z'),
    sn.contentHash = 'sha256:2afe84a285b6b37297f5116eb490048bd149a434ce9f19c76287d195934e8e60', sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2025-11-03T09:00:00Z')
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w23-case-series-participant-12'})
SET l.id = 'w23-case-series-participant-12', l.artifactType = 'SOURCE_LOCATOR', l.uri = cs.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Participant 12 reported falling asleep faster during weeks 2 to 6.', l.quoteHash = 'sha256:a3f99e02e812fd38065fbbbc3805161543edc82a0a89fb119049411fe79e2d16',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2025-11-03T09:00:00Z')
MERGE (cs)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (cp:CohortParticipant:Entity {uid: 'hu:cohort-participant:w23-case-series-participant-12'})
SET cp.id = 'w23-case-series-participant-12', cp.entityType = 'COHORT_PARTICIPANT', cp.participantToken = 'Participant 12',
    cp.privacyClass = 'PUBLIC', cp.createdAt = datetime('2025-11-03T09:10:00Z');

MERGE (er:ExperienceReport:InformationArtifact {uid: 'hu:experience-report:w23-participant-12-sleep'})
SET er.id = 'w23-participant-12-sleep', er.artifactType = 'EXPERIENCE_REPORT', er.reportText = 'Fell asleep faster during weeks 2 to 6 (as reported in the case series).',
    er.privacyClass = 'PUBLIC', er.createdAt = datetime('2025-11-03T09:10:00Z');

MATCH (cp:CohortParticipant {uid: 'hu:cohort-participant:w23-case-series-participant-12'}), (er:ExperienceReport {uid: 'hu:experience-report:w23-participant-12-sleep'}),
      (l:SourceLocator {uid: 'hu:locator:w23-case-series-participant-12'})
MERGE (a:Assertion {uid: 'hu:assertion:w23-participant-12-reports'})
SET a.id = 'w23-participant-12-reports', a.predicate = 'REPORTS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'THIRD_PARTY_ANECDOTE', a.speechAct = 'REPORTS_PRACTICE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2025-11-03T09:10:00Z'), a.contentHash = 'sha256:f87ebec03459192a4e9b1a85b6cd93db0e64d87496ed2ba1998d61b21ace108a',
    a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(cp)
MERGE (a)-[:HAS_OBJECT]->(er)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (cp)-[e:REPORTS {relationshipUid: 'hu:rel:w23-participant-12-reports'}]->(er)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

UNWIND [
  {uid: 'hu:adjudication:w23-cf-records-rhr', id: 'w23-cf-records-rhr', a: 'hu:assertion:w23-public-person-records-rhr', at: datetime('2026-01-20T12:20:00Z'), loc: 'hu:locator:w23-public-blog-rhr-quote'},
  {uid: 'hu:adjudication:w23-cf-participant-12', id: 'w23-cf-participant-12', a: 'hu:assertion:w23-participant-12-reports', at: datetime('2025-11-03T09:20:00Z'), loc: 'hu:locator:w23-case-series-participant-12'}
] AS row
MATCH (a:Assertion {uid: row.a}), (l:SourceLocator {uid: row.loc})
MERGE (j:Adjudication:EvidenceAssessment {uid: row.uid})
SET j.id = row.id, j.assessmentType = 'ADJUDICATION', j.methodVersion = 'capture-policy-1', j.status = 'ACCEPTED',
    j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.reviewedAt = row.at,
    j.recordedAt = row.at, j.privacyClass = 'PUBLIC', j.createdAt = row.at
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// ===== Part N (negative) =====
// N1, the subtle leak: a BellLabs user modelled as a Person, with a lab value copied from the private store into a public
// Observation. No hu:private- value anywhere and a 'PUBLIC' class, so V-521, V-520 and V-524 see nothing.
MERGE (u:Person:Entity {uid: 'hu:person:w23-bellabs-user-jane'})
SET u.id = 'w23-bellabs-user-jane', u.entityType = 'PERSON', u.name = 'Jane (BellLabs user, synthetic)', u.privacyClass = 'PUBLIC',
    u.createdAt = datetime('2026-05-22T12:00:00Z');

MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:w23-user-serum-mg-copy'})
SET o.id = 'w23-user-serum-mg-copy', o.artifactType = 'OBSERVATION', o.observationType = 'LAB_RESULT', o.valueNumber = 2.1, o.unitCode = 'mg/dL',
    o.observedAt = datetime('2026-05-20T08:00:00Z'), o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-05-22T12:00:00Z');

MATCH (u:Person {uid: 'hu:person:w23-bellabs-user-jane'}), (o:Observation {uid: 'hu:observation:w23-user-serum-mg-copy'})
MERGE (u)-[e:RECORDS {relationshipUid: 'hu:rel:w23-user-records-serum-mg'}]->(o)
SET e.recordedFrom = datetime('2026-05-22T12:00:00Z');

// N2, the marked leak: the same copy keeping its private source uid (V-521 sees this one).
MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:w23-user-serum-mg-marked'})
SET o.id = 'w23-user-serum-mg-marked', o.artifactType = 'OBSERVATION', o.valueNumber = 2.1, o.unitCode = 'mg/dL',
    o.derivedFromPersonalMeasurementUid = 'hu:private-personal-measurement:w23-m1', o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-05-22T12:00:00Z');

MATCH (u:Person {uid: 'hu:person:w23-bellabs-user-jane'}), (o:Observation {uid: 'hu:observation:w23-user-serum-mg-marked'})
MERGE (u)-[e:RECORDS {relationshipUid: 'hu:rel:w23-user-records-serum-mg-marked'}]->(o)
SET e.recordedFrom = datetime('2026-05-22T12:00:00Z');

// N3: a user's private protocol outcome posted as a ProtocolResult with no class and no source.
MERGE (pr:ProtocolResult:InformationArtifact {uid: 'hu:protocol-result:w23-user-outcome'})
SET pr.id = 'w23-user-outcome', pr.artifactType = 'PROTOCOL_RESULT', pr.resultSummary = 'Slept better after four weeks (copied from a private record)',
    pr.createdAt = datetime('2026-06-01T00:00:00Z');

MATCH (u:Person {uid: 'hu:person:w23-bellabs-user-jane'}), (pr:ProtocolResult {uid: 'hu:protocol-result:w23-user-outcome'})
MERGE (u)-[e:POSTS_RESULT {relationshipUid: 'hu:rel:w23-user-posts-outcome'}]->(pr)
SET e.recordedFrom = datetime('2026-06-01T00:00:00Z');

// N4: participant tokens that are internal identifiers, with no sourced edge (a private-store id and a hash-like linkage token;
// the second value is sha256('synthetic-linkage-token'), standing for an HMAC contribution token).
UNWIND [
  {uid: 'hu:cohort-participant:w23-token-pcs', id: 'w23-token-pcs', tok: 'pcs-user-7f3a'},
  {uid: 'hu:cohort-participant:w23-token-hmac', id: 'w23-token-hmac', tok: '13c0a9a23716d669d80ce270bd404d381d5ef10b2b812a115616f629e76e3d44'}
] AS row
MERGE (cp:CohortParticipant:Entity {uid: row.uid})
SET cp.id = row.id, cp.entityType = 'COHORT_PARTICIPANT', cp.participantToken = row.tok, cp.privacyClass = 'PUBLIC',
    cp.createdAt = datetime('2026-06-01T00:00:00Z');

// N5: re-identification by inference: a public person linked to a case-series participant with no source naming both.
MATCH (hp:Person {uid: 'hu:person:w23-public-biohacker'}), (cp:CohortParticipant {uid: 'hu:cohort-participant:w23-case-series-participant-12'})
MERGE (hp)-[e:HAS_PARTICIPANT_TOKEN {relationshipUid: 'hu:rel:w23-inferred-participant-link'}]->(cp)
SET e.recordedFrom = datetime('2026-06-02T00:00:00Z'), e.derivationRule = 'name-and-timing-similarity';
