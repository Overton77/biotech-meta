// W00 fixture 02 — late-arriving historical fact (TM-R6; CQ-TM-02, CQ-TM-03, CQ-TM-04; round 0007 §8).
// An archived 2019 label (archive capture observedAt 2019-05-10) is fetched NOW. The assertion keeps its past
// validFrom (2019, YEAR, stated) and an INFERRED validTo (successor_state_start); recordedAt and the episode's
// recordedFrom are the commit time, assigned in Cypher with datetime.transaction() (the service clock), never 2019.
// SYNTHETIC_FIXTURE. Statement order matters only for clocks: the snapshot statement commits before the assertion.

MERGE (n:Agent:Entity {uid: 'hu:agent:w00-archive-fetcher'})
ON CREATE SET n.id = 'w00-archive-fetcher', n.entityType = 'Agent', n.name = 'W00 archive fetcher (synthetic)', n.agentKind = 'AUTOMATED_AGENT',
  n.toolVersion = 'unknown', n.privacyClass = 'INTERNAL', n.createdAt = datetime.transaction(), n.updatedAt = datetime.transaction();

MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:w00-late-us-capsule'})
ON CREATE SET n.id = 'w00-late-us-capsule', n.entityType = 'ProductVariant', n.name = 'Synthetic Product L, US capsule',
  n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-03-02T10:10:00Z'), n.updatedAt = datetime('2026-03-02T10:10:00Z');

UNWIND [
  {uid: 'hu:formulation:w00-late-fv-current', id: 'w00-late-fv-current', name: 'L current formulation (glycinate 200 mg)', t: datetime('2026-03-02T10:10:00Z')},
  {uid: 'hu:formulation:w00-late-fv-2019', id: 'w00-late-fv-2019', name: 'L 2019 formulation (oxide 250 mg)', t: datetime.transaction()}
] AS row
MERGE (n:FormulationVersion:VersionedState {uid: row.uid})
ON CREATE SET n.id = row.id, n.stateType = 'FormulationVersion', n.name = row.name, n.jurisdiction = 'US',
  n.payloadHash = 'sha256:synthetic-payload-' + row.id, n.privacyClass = 'PUBLIC', n.createdAt = row.t, n.updatedAt = row.t;

MERGE (n:Source:Entity {uid: 'hu:source:w00-late-label-page'})
ON CREATE SET n.id = 'w00-late-label-page', n.entityType = 'Source', n.canonicalUri = 'https://product-l.example.invalid/label',
  n.title = 'Synthetic Product L label page', n.sourceKind = 'MANUFACTURER_LABEL_PAGE', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-03-02T10:00:00Z'), n.updatedAt = datetime('2026-03-02T10:00:00Z');

// Current label, captured live on 2026-03-02 (observedAt = retrievedAt).
MATCH (src:Source {uid: 'hu:source:w00-late-label-page'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-late-current-2026-03-02'})
ON CREATE SET s.id = 'w00-late-current-2026-03-02', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-03-02T10:00:00Z'), s.observedAt = datetime('2026-03-02T10:00:00Z'),
  s.contentHash = 'sha256:fc2fb93eed88ff55dc49dd22c8d698d3106450c9e9368040dfabb4cbabaeaa15', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T10:00:00Z'), s.updatedAt = datetime('2026-03-02T10:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// Archive capture of the 2019 page: displayed 2019-05-10 (observedAt), fetched NOW (retrievedAt = commit time of this statement).
MATCH (src:Source {uid: 'hu:source:w00-late-label-page'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-late-archive-2019-05-10'})
ON CREATE SET s.id = 'w00-late-archive-2019-05-10', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.observedAt = datetime('2019-05-10T00:00:00Z'), s.retrievedAt = datetime.transaction(), s.publishedAt = null,
  s.archiveUri = 'https://web.archive.example.invalid/20190510000000/https://product-l.example.invalid/label',
  s.contentHash = 'sha256:98113369e5df01f2e35855b28493c308019c449ddf35e4383f2c07273bc4b77a', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.privacyClass = 'PUBLIC', s.createdAt = datetime.transaction(), s.updatedAt = datetime.transaction()
MERGE (src)-[:HAS_SNAPSHOT]->(s);

UNWIND [
  {snap: 'hu:snapshot:w00-late-current-2026-03-02', uid: 'hu:locator:w00-late-current-panel', id: 'w00-late-current-panel', sec: 'Supplement Facts (2026)'},
  {snap: 'hu:snapshot:w00-late-archive-2019-05-10', uid: 'hu:locator:w00-late-2019-panel', id: 'w00-late-2019-panel', sec: 'Supplement Facts (2019 archive)'}
] AS row
MATCH (s:SourceSnapshot {uid: row.snap})
MERGE (l:SourceLocator:InformationArtifact {uid: row.uid})
ON CREATE SET l.id = row.id, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'SECTION', l.section = row.sec,
  l.privacyClass = 'PUBLIC', l.createdAt = s.createdAt, l.updatedAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l);

// Current-formulation assertion and its episode, recorded 2026-03-02 (before the late source existed in the graph).
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-late-us-capsule'}), (fv:FormulationVersion {uid: 'hu:formulation:w00-late-fv-current'}),
      (l:SourceLocator {uid: 'hu:locator:w00-late-current-panel'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-late-current'})
ON CREATE SET a.id = 'w00-late-current', a.predicate = 'HAS_FORMULATION_VERSION', a.predicateClass = 'COMMERCIAL', a.polarity = 'POSITIVE',
  a.status = 'ACCEPTED', a.validFrom = datetime('2025-11-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE',
  a.validToBasis = 'UNKNOWN', a.jurisdiction = 'US', a.recordedAt = datetime('2026-03-02T10:10:00Z'), a.contentHash = 'sha256:synthetic-content-w00-late-current',
  a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-03-02T10:10:00Z'), a.updatedAt = datetime('2026-03-02T10:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(fv)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w00-late-e-current'}]->(fv)
ON CREATE SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
  h.validToBasis = a.validToBasis, h.recordedFrom = a.recordedAt;

MATCH (a:Assertion {uid: 'hu:assertion:w00-late-current'}), (l:SourceLocator {uid: 'hu:locator:w00-late-current-panel'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w00-late-current-cf'})
ON CREATE SET j.id = 'w00-late-current-cf', j.assessmentType = 'Adjudication', j.methodVersion = 'label-capture-policy-1', j.status = 'ACCEPTED',
  j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.reviewedAt = datetime('2026-03-02T10:20:00Z'),
  j.recordedAt = datetime('2026-03-02T10:20:00Z'), j.privacyClass = 'INTERNAL', j.createdAt = datetime('2026-03-02T10:20:00Z'), j.updatedAt = datetime('2026-03-02T10:20:00Z')
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// The LATE assertion and its episode, written in ONE transaction: recordedAt = recordedFrom = datetime.transaction().
MATCH (v:ProductVariant {uid: 'hu:product-variant:w00-late-us-capsule'}), (fv:FormulationVersion {uid: 'hu:formulation:w00-late-fv-2019'}),
      (l:SourceLocator {uid: 'hu:locator:w00-late-2019-panel'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-late-2019'})
ON CREATE SET a.id = 'w00-late-2019', a.predicate = 'HAS_FORMULATION_VERSION', a.predicateClass = 'COMMERCIAL', a.polarity = 'POSITIVE',
  a.status = 'ACCEPTED', a.validFrom = datetime('2019-01-01T00:00:00Z'), a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE',
  a.validTo = datetime('2025-11-01T00:00:00Z'), a.validToPrecision = 'MONTH', a.validToBasis = 'INFERRED', a.derivationRule = 'successor_state_start',
  a.jurisdiction = 'US', a.recordedAt = datetime.transaction(), a.contentHash = 'sha256:synthetic-content-w00-late-2019',
  a.privacyClass = 'PUBLIC', a.createdAt = datetime.transaction(), a.updatedAt = datetime.transaction()
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(fv)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w00-late-e-2019'}]->(fv)
ON CREATE SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
  h.validTo = a.validTo, h.validToPrecision = a.validToPrecision, h.validToBasis = a.validToBasis, h.recordedFrom = a.recordedAt;

MATCH (a:Assertion {uid: 'hu:assertion:w00-late-2019'}), (l:SourceLocator {uid: 'hu:locator:w00-late-2019-panel'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w00-late-2019-cf'})
ON CREATE SET j.id = 'w00-late-2019-cf', j.assessmentType = 'Adjudication', j.methodVersion = 'label-capture-policy-1', j.status = 'ACCEPTED',
  j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.reviewedAt = datetime.transaction(),
  j.recordedAt = datetime.transaction(), j.privacyClass = 'INTERNAL', j.createdAt = datetime.transaction(), j.updatedAt = datetime.transaction()
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);
