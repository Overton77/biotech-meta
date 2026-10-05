// W23 fixture 00: shared-graph base (POSITIVE). Run W23, worker W23 (Opus 5.5), 2026-10-04.
// SYNTHETIC_FIXTURE: every product, label text, policy and answer here is synthetic; example.invalid URIs only.
// Shared graph only: no private-personal node, property, relationship or hu:private- value (contract A9).
// Stored privacyClass values are the final-schema enum names 'PUBLIC' and 'INTERNAL' (D-W23-06).
// Hash convention (SYNTHETIC_FIXTURE): contentHash and payloadHash values are 'sha256:' + sha256(uid of the node) except
// policy payload hashes (sha256 of 'policy:<key>-<version>') and quoteHash (sha256 of the NFC-WS1-normalized exact text).
// No value is a hash of real bytes.
// Every statement binds its own nodes by uid; variables never cross ';'. Each node carries its primary label and
// its archetype label. Expected: zero failing rows from docs/schema/neo4j/validation.cypher (with
// ../../../validation/validation-params.json) and from validation-w23.cypher (see 06-fixtures-and-queries.md).
//
// Timeline (UTC)
//   2025-12-15  use-authorization policy v1 recorded (effective 2026-01-01 to 2027-01-01)
//   2026-03-02  SleepWell label snapshot S1 (200 mg); assertions AV (variant) and A1 (formulation fv-a1) recorded
//   2026-03-20  ranking policy v3 recorded, declares two criteria
//   2026-04-10  answer viewpoint R (and, in fixture 03, the private decision viewpoint)
//   2026-04-12  answer AR-1 composed and published (QS-2a, cites A1 and its capture adjudication)
//   2026-06-15  erratum: snapshot S2 (120 mg); A2 SUPERSEDES A1 (SOURCE_CORRECTION)
//   2026-06-20  answer AR-2 composed and published (cites A2)

// ---- identities and states ----
MERGE (p:Product:Entity {uid: 'hu:product:w23-sleepwell'})
SET p.id = 'w23-sleepwell', p.entityType = 'PRODUCT', p.name = 'SleepWell Magnesium (synthetic)', p.privacyClass = 'PUBLIC',
    p.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})
SET v.id = 'w23-sleepwell-us-capsule', v.entityType = 'PRODUCT_VARIANT', v.name = 'SleepWell US capsules (synthetic)', v.jurisdiction = 'US',
    v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:w23-sleepwell-fv-a1'})
SET f.id = 'w23-sleepwell-fv-a1', f.stateType = 'FORMULATION_VERSION', f.jurisdiction = 'US', f.versionName = 'Label as first recorded (200 mg elemental Mg declared)',
    f.payloadHash = 'sha256:7150265479d4be5c8928b441b1fd02b84924eb0d220854b556620859de4ff0f9', f.privacyClass = 'PUBLIC', f.createdAt = datetime('2026-03-02T10:10:00Z');

MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:w23-sleepwell-fv-a1c'})
SET f.id = 'w23-sleepwell-fv-a1c', f.stateType = 'FORMULATION_VERSION', f.jurisdiction = 'US', f.versionName = 'Label as corrected (120 mg elemental Mg declared)',
    f.payloadHash = 'sha256:b05c2d41f028a0ffc210d5fc6b4665030a9f0ae77991ee46fe82cff5d244bb27', f.privacyClass = 'PUBLIC', f.createdAt = datetime('2026-06-15T08:10:00Z');

// ---- provenance: source, immutable snapshots, reproducible TEXT_QUOTE locators ----
MERGE (s:Source:Entity {uid: 'hu:source:w23-sleepwell-label-page'})
SET s.id = 'w23-sleepwell-label-page', s.entityType = 'SOURCE', s.canonicalUri = 'https://example.invalid/w23/sleepwell/label',
    s.title = 'SleepWell label page (synthetic)', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w23-sleepwell-label-2026-03-02'})
SET sn.id = 'w23-sleepwell-label-2026-03-02', sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = 'https://example.invalid/w23/sleepwell/label',
    sn.observedAt = datetime('2026-03-02T10:00:00Z'), sn.retrievedAt = datetime('2026-03-02T10:00:00Z'),
    sn.contentHash = 'sha256:fe449dd3422d911999ca028180cdcd386961645e7b5e65266534a817ea20c48a', sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w23-sleepwell-label-2026-06-15'})
SET sn.id = 'w23-sleepwell-label-2026-06-15', sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = 'https://example.invalid/w23/sleepwell/label',
    sn.observedAt = datetime('2026-06-15T08:00:00Z'), sn.retrievedAt = datetime('2026-06-15T08:00:00Z'),
    sn.contentHash = 'sha256:1fb1dfa8e56c4207aa5162bce52a43ecc6a48a4245e2112502c606f4b28ca9c6', sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-06-15T08:00:00Z');

MATCH (s:Source {uid: 'hu:source:w23-sleepwell-label-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w23-sleepwell-label-2026-03-02'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
SET l.id = 'w23-sleepwell-facts-2026-03-02', l.artifactType = 'SOURCE_LOCATOR', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Magnesium (as magnesium glycinate) 200 mg', l.quoteHash = 'sha256:f74d19b518daaeefcbe64247655324f15c0aa88f41f7c3bf180f8466fbc998de',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-03-02T10:00:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (s:Source {uid: 'hu:source:w23-sleepwell-label-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w23-sleepwell-label-2026-06-15'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w23-sleepwell-facts-2026-06-15'})
SET l.id = 'w23-sleepwell-facts-2026-06-15', l.artifactType = 'SOURCE_LOCATOR', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Magnesium (as magnesium glycinate) 120 mg', l.quoteHash = 'sha256:3be5594d060c667deff3670e89d403f6333afa0aeacc189e464f9b9d12da4eb6',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-06-15T08:00:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---- assertions (content immutable; recordedTo written once on supersession) ----
MATCH (p:Product {uid: 'hu:product:w23-sleepwell'}), (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}),
      (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
MERGE (a:Assertion {uid: 'hu:assertion:w23-sleepwell-has-us-capsule'})
SET a.id = 'w23-sleepwell-has-us-capsule', a.predicate = 'HAS_VARIANT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-03-02T10:10:00Z'),
    a.contentHash = 'sha256:70a243f5f111f7ed099ae79371b1efd0e33f34e7b80e7451475edc96d82d18f9', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(v)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[hv:HAS_VARIANT {relationshipUid: 'hu:rel:w23-sleepwell-has-us-capsule'}]->(v)
SET hv.assertionUid = a.uid, hv.validFromBasis = 'UNKNOWN', hv.validToBasis = 'UNKNOWN', hv.recordedFrom = a.recordedAt;

MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}), (f:FormulationVersion {uid: 'hu:formulation:w23-sleepwell-fv-a1'}),
      (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
MERGE (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
SET a.id = 'w23-a1-variant-fv-a1', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'SUPERSEDED', a.polarity = 'POSITIVE',
    a.validFrom = datetime('2025-11-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-03-02T10:10:00Z'), a.recordedTo = datetime('2026-06-15T08:10:00Z'),
    a.contentHash = 'sha256:ea71450db75d62c9e5e2aded497149c9479b4f194e8146d784fc38770c535336', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}), (f:FormulationVersion {uid: 'hu:formulation:w23-sleepwell-fv-a1c'}),
      (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-06-15'})
MERGE (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
SET a.id = 'w23-a2-variant-fv-a1c', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.validFrom = datetime('2025-11-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-06-15T08:10:00Z'),
    a.contentHash = 'sha256:6eacb4d34cd4c638c55cbb7995d83b695ebbbe8bca86bac766b278b5157477f0', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (newer:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'}), (older:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MERGE (newer)-[r:SUPERSEDES]->(older)
SET r.supersessionKind = 'SOURCE_CORRECTION', r.recordedAt = datetime('2026-06-15T08:10:00Z');

// asserted attachment episodes (asserted_edge profile; one relationship per recorded-time episode)
MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}), (f:FormulationVersion {uid: 'hu:formulation:w23-sleepwell-fv-a1'}),
      (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w23-ep-fv-a1'}]->(f)
SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
    h.validToBasis = a.validToBasis, h.recordedFrom = a.recordedAt, h.recordedTo = a.recordedTo;

MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}), (f:FormulationVersion {uid: 'hu:formulation:w23-sleepwell-fv-a1c'}),
      (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w23-ep-fv-a1c'}]->(f)
SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
    h.validToBasis = a.validToBasis, h.recordedFrom = a.recordedAt;

// ---- capture-fidelity adjudications (immutable; PUBLIC: verdict, kind and reviewedAt enter the public trace) ----
UNWIND [
  {uid: 'hu:adjudication:w23-cf-av', id: 'w23-cf-av', a: 'hu:assertion:w23-sleepwell-has-us-capsule', at: datetime('2026-03-02T10:20:00Z'), loc: 'hu:locator:w23-sleepwell-facts-2026-03-02'},
  {uid: 'hu:adjudication:w23-cf-a1', id: 'w23-cf-a1', a: 'hu:assertion:w23-a1-variant-fv-a1', at: datetime('2026-03-02T10:20:00Z'), loc: 'hu:locator:w23-sleepwell-facts-2026-03-02'},
  {uid: 'hu:adjudication:w23-cf-a2', id: 'w23-cf-a2', a: 'hu:assertion:w23-a2-variant-fv-a1c', at: datetime('2026-06-15T08:20:00Z'), loc: 'hu:locator:w23-sleepwell-facts-2026-06-15'}
] AS row
MATCH (a:Assertion {uid: row.a}), (l:SourceLocator {uid: row.loc})
MERGE (j:Adjudication:EvidenceAssessment {uid: row.uid})
SET j.id = row.id, j.assessmentType = 'ADJUDICATION', j.methodVersion = 'label-capture-policy-1', j.status = 'ACCEPTED',
    j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY',
    j.reviewedAt = row.at, j.recordedAt = row.at, j.privacyClass = 'PUBLIC', j.createdAt = row.at
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// ---- INTERNAL policy layer (shared graph, excluded from PUBLIC_ANSWER) ----
MERGE (pv:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-use-quote-summarize-v1'})
SET pv.id = 'w23-use-quote-summarize-v1', pv.stateType = 'POLICY_VERSION', pv.policyKey = 'answer-use-authorization', pv.versionLabel = 'v1',
    pv.policyKind = 'USE_AUTHORIZATION', pv.permittedUseKinds = ['QUOTE_IN_ANSWER', 'SUMMARIZE_IN_ANSWER'],
    pv.effectiveFrom = datetime('2026-01-01T00:00:00Z'), pv.effectiveTo = datetime('2027-01-01T00:00:00Z'),
    pv.name = 'Answer use authorization v1 (synthetic)',
    pv.payloadHash = 'sha256:e483349052b3448ada93e53107b6c4719f4b4c1fed9ad2dca9d357f877741995', pv.privacyClass = 'INTERNAL',
    pv.createdAt = datetime('2025-12-15T00:00:00Z');

MERGE (pv:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-sleep-support-ranking-v3'})
SET pv.id = 'w23-sleep-support-ranking-v3', pv.stateType = 'POLICY_VERSION', pv.policyKey = 'sleep-support-ranking', pv.versionLabel = 'v3',
    pv.policyKind = 'RECOMMENDATION_RANKING', pv.requiredFactKeys = ['BASELINE_SERUM_MAGNESIUM', 'CURRENT_INTAKE_DECLARED', 'PREGNANCY_STATUS_DECLARED'],
    pv.effectiveFrom = datetime('2026-03-20T00:00:00Z'), pv.name = 'Sleep support ranking and safety policy v3 (synthetic)',
    pv.payloadHash = 'sha256:0c84db663c120839f2c56107184599fc3a5c1695250bb465a0aecda4488948be', pv.privacyClass = 'INTERNAL',
    pv.createdAt = datetime('2026-03-20T00:00:00Z');

UNWIND [
  {uid: 'hu:decision-criterion:w23-weakest-applicability-dimension', id: 'w23-weakest-applicability-dimension', key: 'WEAKEST_APPLICABILITY_DIMENSION', kind: 'APPLICABILITY', m: 'applicability-0.3', o: 0},
  {uid: 'hu:decision-criterion:w23-safety-block', id: 'w23-safety-block', key: 'SAFETY_BLOCK', kind: 'SAFETY_BLOCK', m: 'safety-block-0.1', o: 1}
] AS row
MATCH (pv:PolicyVersion {uid: 'hu:policy-version:w23-sleep-support-ranking-v3'})
MERGE (dc:DecisionCriterion:Entity {uid: row.uid})
SET dc.id = row.id, dc.entityType = 'DECISION_CRITERION', dc.criterionKey = row.key, dc.criterionKind = row.kind, dc.methodVersion = row.m,
    dc.privacyClass = 'INTERNAL', dc.createdAt = datetime('2026-03-20T00:00:00Z')
MERGE (pv)-[d:DECLARES_CRITERION]->(dc)
SET d.orderIndex = row.o;

// ---- answer composition lineage (provenance states 4 and 5) ----
MERGE (g:Agent:Entity {uid: 'hu:agent:w23-answer-composer'})
SET g.id = 'w23-answer-composer', g.entityType = 'AGENT', g.name = 'BellLabs answer composer (synthetic)', g.agentKind = 'AUTOMATED_AGENT',
    g.privacyClass = 'PUBLIC', g.createdAt = datetime('2026-01-10T00:00:00Z');

UNWIND [
  {uid: 'hu:activity:w23-compose-ar1', id: 'w23-compose-ar1', st: datetime('2026-04-12T09:00:00Z'), en: datetime('2026-04-12T09:04:00Z'), run: 'run-w23-0001',
   used: ['hu:assertion:w23-a1-variant-fv-a1', 'hu:locator:w23-sleepwell-facts-2026-03-02'], use: 'QUOTE_IN_ANSWER'},
  {uid: 'hu:activity:w23-compose-ar2', id: 'w23-compose-ar2', st: datetime('2026-06-20T10:00:00Z'), en: datetime('2026-06-20T10:03:00Z'), run: 'run-w23-0002',
   used: ['hu:assertion:w23-a2-variant-fv-a1c', 'hu:locator:w23-sleepwell-facts-2026-06-15'], use: 'SUMMARIZE_IN_ANSWER'}
] AS row
MATCH (g:Agent {uid: 'hu:agent:w23-answer-composer'}), (pv:PolicyVersion {uid: 'hu:policy-version:w23-use-quote-summarize-v1'})
MERGE (act:Activity:Occurrence {uid: row.uid})
SET act.id = row.id, act.occurrenceType = 'ACTIVITY', act.activityKind = 'ANSWER_COMPOSITION', act.startedAt = row.st, act.endedAt = row.en,
    act.methodVersion = 'answer-composer-0.1', act.externalRunSystem = 'mongo-research', act.externalRunId = row.run,
    act.privacyClass = 'INTERNAL', act.createdAt = row.en
MERGE (act)-[:WAS_ASSOCIATED_WITH]->(g)
MERGE (act)-[ab:AUTHORIZED_BY]->(pv)
SET ab.useKind = row.use
WITH act, row
UNWIND row.used AS usedUid
MATCH (x {uid: usedUid})
MERGE (act)-[:USED]->(x);

// ---- published answers (INTERNAL nodes; PUBLIC_ANSWER exposes the reproducibility allow-list only) ----
MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar1'}), (a:Assertion {uid: 'hu:assertion:w23-a1-variant-fv-a1'}),
      (j:Adjudication {uid: 'hu:adjudication:w23-cf-a1'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-ar1'})
SET r.id = 'w23-ar1', r.occurrenceType = 'ANSWER_PUBLICATION', r.startedAt = act.startedAt, r.endedAt = act.endedAt,
    r.recordedAsOf = datetime('2026-04-10T09:00:00Z'), r.validAt = datetime('2026-04-10T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0',
    r.queryShapeId = 'QS-2a', r.queryShapeVersion = '0.2.0', r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED',
    r.traceDepth = 'ADJUDICATION', r.publishedAt = datetime('2026-04-12T09:05:00Z'), r.mongoResearchRunId = 'run-w23-0001',
    r.privacyClass = 'INTERNAL', r.createdAt = datetime('2026-04-12T09:05:00Z'), r.updatedAt = datetime('2026-04-12T09:05:00Z')
MERGE (r)-[c1:CITES_ASSERTION]->(a)
SET c1.orderIndex = 0
MERGE (r)-[c2:CITES_ASSESSMENT]->(j)
SET c2.orderIndex = 0
MERGE (r)-[:WAS_GENERATED_BY]->(act);

MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar2'}), (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'}),
      (j:Adjudication {uid: 'hu:adjudication:w23-cf-a2'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-ar2'})
SET r.id = 'w23-ar2', r.occurrenceType = 'ANSWER_PUBLICATION', r.startedAt = act.startedAt, r.endedAt = act.endedAt,
    r.recordedAsOf = datetime('2026-06-20T09:30:00Z'), r.validAt = datetime('2026-06-20T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0',
    r.queryShapeId = 'QS-2a', r.queryShapeVersion = '0.2.0', r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED',
    r.traceDepth = 'ADJUDICATION', r.publishedAt = datetime('2026-06-20T10:05:00Z'), r.mongoResearchRunId = 'run-w23-0002',
    r.privacyClass = 'INTERNAL', r.createdAt = datetime('2026-06-20T10:05:00Z'), r.updatedAt = datetime('2026-06-20T10:05:00Z')
MERGE (r)-[c1:CITES_ASSERTION]->(a)
SET c1.orderIndex = 0
MERGE (r)-[c2:CITES_ASSESSMENT]->(j)
SET c2.orderIndex = 0
MERGE (r)-[:WAS_GENERATED_BY]->(act);
