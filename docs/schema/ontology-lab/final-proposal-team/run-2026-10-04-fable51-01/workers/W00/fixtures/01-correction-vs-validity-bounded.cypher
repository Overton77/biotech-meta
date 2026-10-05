// W00 fixture 01 — minimal pair 8 (competency-questions.md §8.1): "the source was corrected in June" versus
// "the underlying fact ceased to be true in June" (round 0007 §7; CQ-TM-07, CQ-TM-01, CQ-EV-05, CQ-TM-06).
// SYNTHETIC_FIXTURE: products, labels and quotes are synthetic (.invalid domains); hashes of snapshots are
// sha256 over the snapshot uid (contentHashBasis SYNTHETIC_FIXTURE); quoteHash is sha256 over NFC-WS1(exact).
// Every statement binds its own nodes by uid; nodes carry primary label + archetype label; ids = uid opaque segment.
// Expected: zero rows from fixtures/validation-w00.cypher; as-of answers in 06-fixtures-and-queries.md §3.1.

// ---- lineage: agent and activities ----
MERGE (n:Agent:Entity {uid: 'hu:agent:w00-fixture-curator'})
ON CREATE SET n.id = 'w00-fixture-curator', n.entityType = 'Agent', n.name = 'W00 fixture curator', n.agentKind = 'MANUAL_AGENT',
  n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-03-02T09:00:00Z'), n.updatedAt = datetime('2026-03-02T09:00:00Z');

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w00-pair8-capture'})
ON CREATE SET n.id = 'w00-pair8-capture', n.occurrenceType = 'Activity', n.activityKind = 'CAPTURE', n.methodVersion = 'synthetic-capture-v1',
  n.startedAt = datetime('2026-03-02T10:00:00Z'), n.privacyClass = 'INTERNAL',
  n.createdAt = datetime('2026-03-02T10:00:00Z'), n.updatedAt = datetime('2026-03-02T10:00:00Z');

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w00-pair8-extraction'})
ON CREATE SET n.id = 'w00-pair8-extraction', n.occurrenceType = 'Activity', n.activityKind = 'EXTRACTION', n.methodVersion = 'w00-manual-curation-v1',
  n.startedAt = datetime('2026-03-02T10:05:00Z'), n.privacyClass = 'INTERNAL',
  n.createdAt = datetime('2026-03-02T10:05:00Z'), n.updatedAt = datetime('2026-03-02T10:05:00Z');

MATCH (act:Activity {uid: 'hu:activity:w00-pair8-extraction'}), (ag:Agent {uid: 'hu:agent:w00-fixture-curator'})
MERGE (act)-[:WAS_ASSOCIATED_WITH]->(ag);

// ---- product identities and immutable states (W04 labels, referenced by name) ----
MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:w00-pair8-a-us-capsule'})
ON CREATE SET n.id = 'w00-pair8-a-us-capsule', n.entityType = 'ProductVariant', n.name = 'Synthetic Product A, US capsule',
  n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-03-02T10:10:00Z'), n.updatedAt = datetime('2026-03-02T10:10:00Z');

MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:w00-pair8-b-us-powder'})
ON CREATE SET n.id = 'w00-pair8-b-us-powder', n.entityType = 'ProductVariant', n.name = 'Synthetic Product B, US powder',
  n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-03-02T10:10:00Z'), n.updatedAt = datetime('2026-03-02T10:10:00Z');

UNWIND [
  {uid: 'hu:formulation:w00-pair8-a-fv1-200mg', id: 'w00-pair8-a-fv1-200mg', name: 'A FV1 (Mg 200 mg, as first read)', t: datetime('2026-03-02T10:10:00Z')},
  {uid: 'hu:formulation:w00-pair8-a-fv1c-120mg', id: 'w00-pair8-a-fv1c-120mg', name: 'A FV1c (Mg 120 mg, corrected)', t: datetime('2026-06-15T08:10:00Z')},
  {uid: 'hu:formulation:w00-pair8-b-fv1-3g', id: 'w00-pair8-b-fv1-3g', name: 'B FV1 (glycine 3 g)', t: datetime('2026-03-02T10:10:00Z')},
  {uid: 'hu:formulation:w00-pair8-b-fv2-2g', id: 'w00-pair8-b-fv2-2g', name: 'B FV2 (glycine 2 g)', t: datetime('2026-06-20T09:10:00Z')}
] AS row
MERGE (n:FormulationVersion:VersionedState {uid: row.uid})
ON CREATE SET n.id = row.id, n.stateType = 'FormulationVersion', n.name = row.name, n.jurisdiction = 'US',
  n.payloadHash = 'sha256:synthetic-payload-' + row.id, n.privacyClass = 'PUBLIC', n.createdAt = row.t, n.updatedAt = row.t;

// ---- sources, snapshots, locators ----
MERGE (n:Source:Entity {uid: 'hu:source:w00-pair8-a-label-page'})
ON CREATE SET n.id = 'w00-pair8-a-label-page', n.entityType = 'Source', n.canonicalUri = 'https://product-a.example.invalid/supplement-facts',
  n.title = 'Synthetic Product A supplement facts', n.sourceKind = 'MANUFACTURER_LABEL_PAGE', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-03-02T10:00:00Z'), n.updatedAt = datetime('2026-03-02T10:00:00Z');

MERGE (n:Source:Entity {uid: 'hu:source:w00-pair8-b-label-page'})
ON CREATE SET n.id = 'w00-pair8-b-label-page', n.entityType = 'Source', n.canonicalUri = 'https://product-b.example.invalid/supplement-facts',
  n.title = 'Synthetic Product B supplement facts', n.sourceKind = 'MANUFACTURER_LABEL_PAGE', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-03-02T10:00:00Z'), n.updatedAt = datetime('2026-03-02T10:00:00Z');

UNWIND [
  {src: 'hu:source:w00-pair8-a-label-page', uid: 'hu:snapshot:w00-pair8-a-2026-03-02', id: 'w00-pair8-a-2026-03-02', t: datetime('2026-03-02T10:00:00Z'),
   h: 'sha256:0fe328cd7fe84e6891fb1f36aa7085709ad69c3e831319f42b6738f464bd7379'},
  {src: 'hu:source:w00-pair8-a-label-page', uid: 'hu:snapshot:w00-pair8-a-2026-06-15', id: 'w00-pair8-a-2026-06-15', t: datetime('2026-06-15T08:00:00Z'),
   h: 'sha256:7d0886f7e1b9fdd99ca2b325bf7adade7a57b1f9aaa273cdfcbd547d2f994db9'},
  {src: 'hu:source:w00-pair8-b-label-page', uid: 'hu:snapshot:w00-pair8-b-2026-03-02', id: 'w00-pair8-b-2026-03-02', t: datetime('2026-03-02T10:00:00Z'),
   h: 'sha256:92feb184ef91315bdc219ce709478f64a81defb4c4aa46c38260244aaed11e54'},
  {src: 'hu:source:w00-pair8-b-label-page', uid: 'hu:snapshot:w00-pair8-b-2026-06-20', id: 'w00-pair8-b-2026-06-20', t: datetime('2026-06-20T09:00:00Z'),
   h: 'sha256:04ae331d7f64fe4eb8b69fdc72f9b5eea529aa38c17b105af168f2390eaad863'}
] AS row
MATCH (src:Source {uid: row.src}), (act:Activity {uid: 'hu:activity:w00-pair8-capture'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: row.uid})
ON CREATE SET s.id = row.id, s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = row.t, s.observedAt = row.t,
  s.contentHash = row.h, s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.mimeType = 'text/html',
  s.privacyClass = 'PUBLIC', s.createdAt = row.t, s.updatedAt = row.t
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

UNWIND [
  {snap: 'hu:snapshot:w00-pair8-a-2026-03-02', uid: 'hu:locator:w00-pair8-a-200mg', id: 'w00-pair8-a-200mg', exact: 'Magnesium (as magnesium glycinate) 200 mg',
   qh: 'sha256:f74d19b518daaeefcbe64247655324f15c0aa88f41f7c3bf180f8466fbc998de'},
  {snap: 'hu:snapshot:w00-pair8-a-2026-06-15', uid: 'hu:locator:w00-pair8-a-120mg', id: 'w00-pair8-a-120mg', exact: 'Magnesium (as magnesium glycinate) 120 mg',
   qh: 'sha256:3be5594d060c667deff3670e89d403f6333afa0aeacc189e464f9b9d12da4eb6'},
  {snap: 'hu:snapshot:w00-pair8-b-2026-03-02', uid: 'hu:locator:w00-pair8-b-3g', id: 'w00-pair8-b-3g', exact: 'Glycine 3 g',
   qh: 'sha256:4c2fb29a58aa30ceffd1a5c1db557711a14790197cf8bc1d03149dde6ba709e2'},
  {snap: 'hu:snapshot:w00-pair8-b-2026-06-20', uid: 'hu:locator:w00-pair8-b-reformulated', id: 'w00-pair8-b-reformulated',
   exact: 'Reformulated: effective June 10, 2026, each serving provides 2 g glycine.',
   qh: 'sha256:bde3a11d7c38553cabe42b56a536f751b83e4484c33423226804ac88fbae9356'},
  {snap: 'hu:snapshot:w00-pair8-b-2026-06-20', uid: 'hu:locator:w00-pair8-b-2g', id: 'w00-pair8-b-2g', exact: 'Glycine 2 g',
   qh: 'sha256:2b6015786b44d230d5d5c6e30c89b0b0878899a91a316f53f10172873b1611e6'}
] AS row
MATCH (s:SourceSnapshot {uid: row.snap})
MERGE (l:SourceLocator:InformationArtifact {uid: row.uid})
ON CREATE SET l.id = row.id, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact,
  l.quoteHash = row.qh, l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = s.createdAt, l.updatedAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---- Delta A: the publisher corrects a printing error (ERRATUM) ----
MERGE (ev:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:w00-pair8-a-erratum-2026-06'})
ON CREATE SET ev.id = 'w00-pair8-a-erratum-2026-06', ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'ERRATUM',
  ev.occurredAt = datetime('2026-06-14T00:00:00Z'), ev.occurredAtPrecision = 'DAY', ev.recordedAt = datetime('2026-06-15T08:05:00Z'),
  ev.privacyClass = 'PUBLIC', ev.createdAt = datetime('2026-06-15T08:05:00Z'), ev.updatedAt = datetime('2026-06-15T08:05:00Z');

MATCH (ev:SourceRevisionEvent {uid: 'hu:source-revision:w00-pair8-a-erratum-2026-06'}), (src:Source {uid: 'hu:source:w00-pair8-a-label-page'}),
      (prior:SourceSnapshot {uid: 'hu:snapshot:w00-pair8-a-2026-03-02'}), (res:SourceSnapshot {uid: 'hu:snapshot:w00-pair8-a-2026-06-15'})
MERGE (ev)-[:REVISES_SOURCE]->(src)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(prior)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(res)
MERGE (ev)-[:ANNOUNCED_IN]->(res);

// ---- assertions (content immutable; recordedTo written once) ----
UNWIND [
  {uid: 'hu:assertion:w00-pair8-a1', id: 'w00-pair8-a1', subj: 'hu:product-variant:w00-pair8-a-us-capsule', obj: 'hu:formulation:w00-pair8-a-fv1-200mg',
   loc: 'hu:locator:w00-pair8-a-200mg', status: 'SUPERSEDED', vf: datetime('2025-11-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE',
   vt: null, vtp: null, vtb: 'UNKNOWN', rat: datetime('2026-03-02T10:10:00Z'), rto: datetime('2026-06-15T08:10:00Z')},
  {uid: 'hu:assertion:w00-pair8-a2-corrected', id: 'w00-pair8-a2-corrected', subj: 'hu:product-variant:w00-pair8-a-us-capsule', obj: 'hu:formulation:w00-pair8-a-fv1c-120mg',
   loc: 'hu:locator:w00-pair8-a-120mg', status: 'ACCEPTED', vf: datetime('2025-11-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE',
   vt: null, vtp: null, vtb: 'UNKNOWN', rat: datetime('2026-06-15T08:10:00Z'), rto: null},
  {uid: 'hu:assertion:w00-pair8-b1', id: 'w00-pair8-b1', subj: 'hu:product-variant:w00-pair8-b-us-powder', obj: 'hu:formulation:w00-pair8-b-fv1-3g',
   loc: 'hu:locator:w00-pair8-b-3g', status: 'SUPERSEDED', vf: datetime('2025-01-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE',
   vt: null, vtp: null, vtb: 'UNKNOWN', rat: datetime('2026-03-02T10:10:00Z'), rto: datetime('2026-06-20T09:10:00Z')},
  {uid: 'hu:assertion:w00-pair8-b1-bounded', id: 'w00-pair8-b1-bounded', subj: 'hu:product-variant:w00-pair8-b-us-powder', obj: 'hu:formulation:w00-pair8-b-fv1-3g',
   loc: 'hu:locator:w00-pair8-b-reformulated', status: 'ACCEPTED', vf: datetime('2025-01-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE',
   vt: datetime('2026-06-10T00:00:00Z'), vtp: 'DAY', vtb: 'STATED_BY_SOURCE', rat: datetime('2026-06-20T09:10:00Z'), rto: null},
  {uid: 'hu:assertion:w00-pair8-b2', id: 'w00-pair8-b2', subj: 'hu:product-variant:w00-pair8-b-us-powder', obj: 'hu:formulation:w00-pair8-b-fv2-2g',
   loc: 'hu:locator:w00-pair8-b-2g', status: 'ACCEPTED', vf: datetime('2026-06-10T00:00:00Z'), vfp: 'DAY', vfb: 'STATED_BY_SOURCE',
   vt: null, vtp: null, vtb: 'UNKNOWN', rat: datetime('2026-06-20T09:10:00Z'), rto: null}
] AS row
MATCH (subj {uid: row.subj}), (obj {uid: row.obj}), (l:SourceLocator {uid: row.loc}), (act:Activity {uid: 'hu:activity:w00-pair8-extraction'})
MERGE (a:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = 'HAS_FORMULATION_VERSION', a.predicateClass = 'COMMERCIAL', a.polarity = 'POSITIVE', a.status = row.status,
  a.validFrom = row.vf, a.validFromPrecision = row.vfp, a.validFromBasis = row.vfb, a.validTo = row.vt, a.validToPrecision = row.vtp, a.validToBasis = row.vtb,
  a.jurisdiction = 'US', a.recordedAt = row.rat, a.recordedTo = row.rto, a.contentHash = 'sha256:synthetic-content-' + row.id,
  a.extractionConfidence = 1.0, a.privacyClass = 'PUBLIC', a.createdAt = row.rat, a.updatedAt = coalesce(row.rto, row.rat)
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:HAS_OBJECT]->(obj)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (newer:Assertion {uid: 'hu:assertion:w00-pair8-a2-corrected'}), (older:Assertion {uid: 'hu:assertion:w00-pair8-a1'})
MERGE (newer)-[r:SUPERSEDES]->(older)
ON CREATE SET r.supersessionKind = 'SOURCE_CORRECTION', r.recordedAt = datetime('2026-06-15T08:10:00Z'),
  r.sourceRevisionEventUid = 'hu:source-revision:w00-pair8-a-erratum-2026-06';

MATCH (newer:Assertion {uid: 'hu:assertion:w00-pair8-b1-bounded'}), (older:Assertion {uid: 'hu:assertion:w00-pair8-b1'})
MERGE (newer)-[r:SUPERSEDES]->(older)
ON CREATE SET r.supersessionKind = 'VALIDITY_BOUNDED', r.recordedAt = datetime('2026-06-20T09:10:00Z');

// ---- capture-fidelity adjudications (POLICY); status projection is backed by these (V-110) ----
UNWIND [
  {uid: 'hu:adjudication:w00-pair8-a1-cf', id: 'w00-pair8-a1-cf', a: 'hu:assertion:w00-pair8-a1', loc: 'hu:locator:w00-pair8-a-200mg', t: datetime('2026-03-02T10:20:00Z')},
  {uid: 'hu:adjudication:w00-pair8-a2-cf', id: 'w00-pair8-a2-cf', a: 'hu:assertion:w00-pair8-a2-corrected', loc: 'hu:locator:w00-pair8-a-120mg', t: datetime('2026-06-15T08:20:00Z')},
  {uid: 'hu:adjudication:w00-pair8-b1-cf', id: 'w00-pair8-b1-cf', a: 'hu:assertion:w00-pair8-b1', loc: 'hu:locator:w00-pair8-b-3g', t: datetime('2026-03-02T10:20:00Z')},
  {uid: 'hu:adjudication:w00-pair8-b1b-cf', id: 'w00-pair8-b1b-cf', a: 'hu:assertion:w00-pair8-b1-bounded', loc: 'hu:locator:w00-pair8-b-reformulated', t: datetime('2026-06-20T09:20:00Z')},
  {uid: 'hu:adjudication:w00-pair8-b2-cf', id: 'w00-pair8-b2-cf', a: 'hu:assertion:w00-pair8-b2', loc: 'hu:locator:w00-pair8-b-2g', t: datetime('2026-06-20T09:20:00Z')}
] AS row
MATCH (a:Assertion {uid: row.a}), (l:SourceLocator {uid: row.loc})
MERGE (j:Adjudication:EvidenceAssessment {uid: row.uid})
ON CREATE SET j.id = row.id, j.assessmentType = 'Adjudication', j.methodVersion = 'label-capture-policy-1', j.status = 'ACCEPTED',
  j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.reviewedAt = row.t, j.recordedAt = row.t,
  j.privacyClass = 'INTERNAL', j.createdAt = row.t, j.updatedAt = row.t
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// ---- attachment episodes (one relationship per recorded-time episode; StateEpisodeProperties) ----
UNWIND [
  {ru: 'hu:rel:w00-pair8-eA1', v: 'hu:product-variant:w00-pair8-a-us-capsule', fv: 'hu:formulation:w00-pair8-a-fv1-200mg', a: 'hu:assertion:w00-pair8-a1'},
  {ru: 'hu:rel:w00-pair8-eA2', v: 'hu:product-variant:w00-pair8-a-us-capsule', fv: 'hu:formulation:w00-pair8-a-fv1c-120mg', a: 'hu:assertion:w00-pair8-a2-corrected'},
  {ru: 'hu:rel:w00-pair8-eB1', v: 'hu:product-variant:w00-pair8-b-us-powder', fv: 'hu:formulation:w00-pair8-b-fv1-3g', a: 'hu:assertion:w00-pair8-b1'},
  {ru: 'hu:rel:w00-pair8-eB1b', v: 'hu:product-variant:w00-pair8-b-us-powder', fv: 'hu:formulation:w00-pair8-b-fv1-3g', a: 'hu:assertion:w00-pair8-b1-bounded'},
  {ru: 'hu:rel:w00-pair8-eB2', v: 'hu:product-variant:w00-pair8-b-us-powder', fv: 'hu:formulation:w00-pair8-b-fv2-2g', a: 'hu:assertion:w00-pair8-b2'}
] AS row
MATCH (v:ProductVariant {uid: row.v}), (fv:FormulationVersion {uid: row.fv}), (a:Assertion {uid: row.a})
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: row.ru}]->(fv)
ON CREATE SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
  h.validTo = a.validTo, h.validToPrecision = a.validToPrecision, h.validToBasis = a.validToBasis,
  h.recordedFrom = a.recordedAt, h.recordedTo = a.recordedTo;
