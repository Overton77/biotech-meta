// W04 fixture 01 -- round-0007 minimal pair on HAS_FORMULATION_VERSION: "source corrected" vs "fact ceased".
// SYNTHETIC_FIXTURE: invented products, materials and labels (no real company). Run run-2026-10-04-fable51-01, worker W04.
// Every statement binds its own nodes by uid; nodes carry the primary label and the archetype label.
// payloadHash/contentHash values are sha256 over the canonical payload text shown in the @@ template (render.py);
// snapshot hashes are SYNTHETIC_FIXTURE.
// Variant A (correction): label stated 200 mg; on 2026-06-14 the brand issues an erratum: it was always 120 mg.
// Variant B (fact ending): label stated 200 mg; brand reformulates to 150 mg effective 2026-06-10; BellLabs learns 2026-06-20.

// ---- shared identities ----
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:w04-syn-ingredient-x'})
SET m.name = 'Ingredient X (synthetic material)', m.entityType = 'IngredientMaterial', m.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-03-02T09:00:00Z');

MERGE (o:Organization:Entity {uid: 'hu:org:w04-syn-brand-owner'})
SET o.name = 'Synthetic Brand Owner LLC', o.entityType = 'Organization', o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-03-02T09:00:00Z');

MERGE (sd:ServingDefinition:VersionedState {uid: 'hu:serving-definition:w04-syn-1-capsule'})
SET sd.stateType = 'ServingDefinition', sd.servingCount = 1.0, sd.unitDescription = 'Capsule', sd.servingsPerContainer = null,
    sd.payloadHash = 'sha256:820c8d41b721c894a1c9ca26a9f0a1099e39126d055badcf06b65c4772f3b68f', sd.privacyClass = 'PUBLIC', sd.createdAt = datetime('2026-03-02T09:00:00Z');

// ---- products and variants ----
UNWIND [
  {p: 'hu:product:w04-syn-pair-a', pn: 'Synthetic Pair A', v: 'hu:product-variant:w04-syn-pair-a-us-capsule', vn: 'Synthetic Pair A - US capsule'},
  {p: 'hu:product:w04-syn-pair-b', pn: 'Synthetic Pair B', v: 'hu:product-variant:w04-syn-pair-b-us-capsule', vn: 'Synthetic Pair B - US capsule'}
] AS r
MERGE (p:Product:Entity {uid: r.p})
SET p.name = r.pn, p.entityType = 'Product', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-03-02T09:00:00Z')
MERGE (v:ProductVariant:Entity {uid: r.v})
SET v.name = r.vn, v.entityType = 'ProductVariant', v.dosageForm = 'CAPSULE', v.jurisdiction = 'US', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T09:00:00Z');

// ---- formulation versions (immutable payloads) ----
UNWIND [
  {fv: 'hu:formulation:w04-syn-a-200', name: 'Pair A as first recorded (200 mg)', c: 'hu:component:w04-syn-a-200-x', q: 200.0, cph: 'sha256:dc6ac0b544a24ea38d32c5f0bb32f4b6dc4a0d1e255bbcfd30c1154e7011c267', ph: 'sha256:b908906370a5a00a813e2addf6cf2a8b794a5f0600e89d432016c00d217cbbac', created: '2026-03-02T09:00:00Z'},
  {fv: 'hu:formulation:w04-syn-a-120-corrected', name: 'Pair A corrected (120 mg)', c: 'hu:component:w04-syn-a-120-x', q: 120.0, cph: 'sha256:d922450c0ab462b54d5db5ad5716216bfddff91190b2fc43edbca7a142cecb2c', ph: 'sha256:06c490627778de94b3006468081a3b8d982697d13c6636f3b2117333392450a8', created: '2026-06-15T10:00:00Z'},
  {fv: 'hu:formulation:w04-syn-b-200', name: 'Pair B original (200 mg)', c: 'hu:component:w04-syn-b-200-x', q: 200.0, cph: 'sha256:dc6ac0b544a24ea38d32c5f0bb32f4b6dc4a0d1e255bbcfd30c1154e7011c267', ph: 'sha256:b908906370a5a00a813e2addf6cf2a8b794a5f0600e89d432016c00d217cbbac', created: '2026-03-02T09:00:00Z'},
  {fv: 'hu:formulation:w04-syn-b-150-reformulated', name: 'Pair B reformulated (150 mg)', c: 'hu:component:w04-syn-b-150-x', q: 150.0, cph: 'sha256:9e0962e5bdf6d3d1e1b5d17d2b22f1e04fb22cbc4fa79478bc6eb3188e9e5dfc', ph: 'sha256:0155dd849f73fdacfc50b919992f7c88a2f1abea9d0a8255dc5b2bb72467110c', created: '2026-06-20T10:00:00Z'}
] AS r
MERGE (fv:FormulationVersion:VersionedState {uid: r.fv})
SET fv.stateType = 'FormulationVersion', fv.versionName = r.name, fv.jurisdiction = 'US', fv.payloadHash = r.ph, fv.privacyClass = 'PUBLIC', fv.createdAt = datetime(r.created)
MERGE (c:IngredientComponent:VersionedState {uid: r.c})
SET c.stateType = 'IngredientComponent', c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = r.q, c.unitCode = 'mg',
    c.quantityBasis = 'PER_SERVING', c.massBasis = 'MATERIAL_AS_IS', c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', c.declaredAs = 'Ingredient X',
    c.isDietaryIngredient = true, c.payloadHash = r.cph, c.privacyClass = 'PUBLIC', c.createdAt = datetime(r.created);

UNWIND [
  {fv: 'hu:formulation:w04-syn-a-200', c: 'hu:component:w04-syn-a-200-x'},
  {fv: 'hu:formulation:w04-syn-a-120-corrected', c: 'hu:component:w04-syn-a-120-x'},
  {fv: 'hu:formulation:w04-syn-b-200', c: 'hu:component:w04-syn-b-200-x'},
  {fv: 'hu:formulation:w04-syn-b-150-reformulated', c: 'hu:component:w04-syn-b-150-x'}
] AS r
MATCH (fv:FormulationVersion {uid: r.fv}), (c:IngredientComponent {uid: r.c}), (sd:ServingDefinition {uid: 'hu:serving-definition:w04-syn-1-capsule'})
MERGE (fv)-[hc:HAS_INGREDIENT_COMPONENT]->(c) SET hc.orderIndex = 1
MERGE (fv)-[us:USES_SERVING_DEFINITION]->(sd) SET us.orderIndex = 1;

// ---- sources, label snapshots, locators ----
UNWIND [
  {src: 'hu:source:w04-syn-pair-a-label', uri: 'https://example.invalid/w04/pair-a/label'},
  {src: 'hu:source:w04-syn-pair-b-label', uri: 'https://example.invalid/w04/pair-b/label'}
] AS r
MERGE (s:Source:Entity {uid: r.src})
SET s.canonicalUri = r.uri, s.title = 'Synthetic label page', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.entityType = 'Source', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T09:00:00Z');

UNWIND [
  {src: 'hu:source:w04-syn-pair-a-label', sn: 'hu:snapshot:w04-syn-pair-a-label-2026-03-02', at: '2026-03-02T09:00:00Z', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-03-02', exact: 'Ingredient X 200 mg', v: 'hu:product-variant:w04-syn-pair-a-us-capsule'},
  {src: 'hu:source:w04-syn-pair-a-label', sn: 'hu:snapshot:w04-syn-pair-a-label-2026-06-15', at: '2026-06-15T10:00:00Z', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-06-15', exact: 'Ingredient X 120 mg', v: 'hu:product-variant:w04-syn-pair-a-us-capsule'},
  {src: 'hu:source:w04-syn-pair-b-label', sn: 'hu:snapshot:w04-syn-pair-b-label-2026-03-02', at: '2026-03-02T09:00:00Z', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-03-02', exact: 'Ingredient X 200 mg', v: 'hu:product-variant:w04-syn-pair-b-us-capsule'},
  {src: 'hu:source:w04-syn-pair-b-label', sn: 'hu:snapshot:w04-syn-pair-b-label-2026-06-20', at: '2026-06-20T10:00:00Z', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-06-20', exact: 'Ingredient X 150 mg. New formula effective June 10, 2026.', v: 'hu:product-variant:w04-syn-pair-b-us-capsule'}
] AS r
MATCH (s:Source {uid: r.src})
MERGE (sn:LabelSnapshot:SourceSnapshot:InformationArtifact {uid: r.sn})
SET sn.artifactType = 'LabelSnapshot', sn.canonicalUri = s.canonicalUri, sn.observedAt = datetime(r.at), sn.retrievedAt = datetime(r.at),
    sn.contentHash = 'synthetic:' + r.sn, sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE', sn.jurisdiction = 'US', sn.language = 'en',
    sn.privacyClass = 'PUBLIC', sn.createdAt = datetime(r.at)
MERGE (l:SourceLocator:InformationArtifact {uid: r.loc})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = r.exact, l.quoteHash = 'synthetic:' + r.loc,
    l.normalizationVersion = 'NFC-WS1', l.section = 'Supplement Facts', l.privacyClass = 'PUBLIC', l.createdAt = datetime(r.at)
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// Delta A: the publisher's erratum is a SourceRevisionEvent (ERRATUM); delta B has none (the source was not wrong).
MATCH (s:Source {uid: 'hu:source:w04-syn-pair-a-label'}), (s1:SourceSnapshot {uid: 'hu:snapshot:w04-syn-pair-a-label-2026-03-02'}), (s2:SourceSnapshot {uid: 'hu:snapshot:w04-syn-pair-a-label-2026-06-15'})
MERGE (ev:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:w04-syn-pair-a-erratum-2026-06-14'})
SET ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'ERRATUM', ev.occurredAt = datetime('2026-06-14T00:00:00Z'), ev.occurredAtPrecision = 'DAY',
    ev.recordedAt = datetime('2026-06-15T10:00:00Z'), ev.privacyClass = 'PUBLIC', ev.createdAt = datetime('2026-06-15T10:00:00Z')
MERGE (ev)-[:REVISES_SOURCE]->(s)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(s1)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(s2);

// ---- HAS_FORMULATION_VERSION assertions (authority) ----
// A1 / B1: shared starting state (recorded 2026-03-02). A1 later SOURCE_CORRECTED, B1 later VALIDITY_BOUNDED.
UNWIND [
  {a: 'hu:assertion:w04-syn-a1-fv', v: 'hu:product-variant:w04-syn-pair-a-us-capsule', fv: 'hu:formulation:w04-syn-a-200', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-03-02',
   rec: '2026-03-02T10:00:00Z', recTo: '2026-06-15T10:00:00Z', status: 'SUPERSEDED', vf: '2025-11-01T00:00:00Z', vfp: 'MONTH', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-a2-fv-corrected', v: 'hu:product-variant:w04-syn-pair-a-us-capsule', fv: 'hu:formulation:w04-syn-a-120-corrected', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-06-15',
   rec: '2026-06-15T10:00:00Z', recTo: null, status: 'ACCEPTED', vf: '2025-11-01T00:00:00Z', vfp: 'MONTH', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-b1-fv', v: 'hu:product-variant:w04-syn-pair-b-us-capsule', fv: 'hu:formulation:w04-syn-b-200', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-03-02',
   rec: '2026-03-02T10:00:00Z', recTo: '2026-06-20T10:00:00Z', status: 'SUPERSEDED', vf: '2025-11-01T00:00:00Z', vfp: 'MONTH', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-b1b-fv-bounded', v: 'hu:product-variant:w04-syn-pair-b-us-capsule', fv: 'hu:formulation:w04-syn-b-200', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-06-20',
   rec: '2026-06-20T10:00:00Z', recTo: null, status: 'ACCEPTED', vf: '2025-11-01T00:00:00Z', vfp: 'MONTH', vt: '2026-06-10T00:00:00Z', vtp: 'DAY', vtb: 'STATED_BY_SOURCE'},
  {a: 'hu:assertion:w04-syn-b3-fv-new', v: 'hu:product-variant:w04-syn-pair-b-us-capsule', fv: 'hu:formulation:w04-syn-b-150-reformulated', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-06-20',
   rec: '2026-06-20T10:00:00Z', recTo: null, status: 'ACCEPTED', vf: '2026-06-10T00:00:00Z', vfp: 'DAY', vt: null, vtp: null, vtb: 'UNKNOWN'}
] AS r
MATCH (v:ProductVariant {uid: r.v}), (fv:FormulationVersion {uid: r.fv}), (loc:SourceLocator {uid: r.loc}), (o:Organization {uid: 'hu:org:w04-syn-brand-owner'})
MERGE (a:Assertion {uid: r.a})
SET a.predicate = 'HAS_FORMULATION_VERSION', a.status = r.status, a.polarity = 'POSITIVE', a.recordedAt = datetime(r.rec),
    a.recordedTo = CASE WHEN r.recTo IS NULL THEN null ELSE datetime(r.recTo) END,
    a.validFrom = datetime(r.vf), a.validFromPrecision = r.vfp, a.validFromBasis = 'STATED_BY_SOURCE',
    a.validTo = CASE WHEN r.vt IS NULL THEN null ELSE datetime(r.vt) END, a.validToPrecision = r.vtp, a.validToBasis = r.vtb,
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.speechAct = 'STATES', a.jurisdiction = 'US',
    a.contentHash = 'synthetic:' + r.a, a.privacyClass = 'PUBLIC', a.createdAt = datetime(r.rec)
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(fv)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (a)-[:ASSERTED_BY]->(o);

MATCH (a2:Assertion {uid: 'hu:assertion:w04-syn-a2-fv-corrected'}), (a1:Assertion {uid: 'hu:assertion:w04-syn-a1-fv'})
MERGE (a2)-[s:SUPERSEDES]->(a1)
SET s.supersessionKind = 'SOURCE_CORRECTION', s.recordedAt = datetime('2026-06-15T10:00:00Z'), s.sourceRevisionEventUid = 'hu:source-revision:w04-syn-pair-a-erratum-2026-06-14';

MATCH (b1b:Assertion {uid: 'hu:assertion:w04-syn-b1b-fv-bounded'}), (b1:Assertion {uid: 'hu:assertion:w04-syn-b1-fv'})
MERGE (b1b)-[s:SUPERSEDES]->(b1)
SET s.supersessionKind = 'VALIDITY_BOUNDED', s.recordedAt = datetime('2026-06-20T10:00:00Z');

// ---- projected HAS_FORMULATION_VERSION episodes (FormulationEdgeProperties); bounds copy the assertion (V-505) ----
UNWIND [
  {ru: 'hu:rel:w04-syn-e1a', a: 'hu:assertion:w04-syn-a1-fv'},
  {ru: 'hu:rel:w04-syn-e2a', a: 'hu:assertion:w04-syn-a2-fv-corrected'},
  {ru: 'hu:rel:w04-syn-e1b', a: 'hu:assertion:w04-syn-b1-fv'},
  {ru: 'hu:rel:w04-syn-e1b-bounded', a: 'hu:assertion:w04-syn-b1b-fv-bounded'},
  {ru: 'hu:rel:w04-syn-e3b', a: 'hu:assertion:w04-syn-b3-fv-new'}
] AS r
MATCH (a:Assertion {uid: r.a})-[:HAS_SUBJECT]->(v:ProductVariant), (a)-[:HAS_OBJECT]->(fv:FormulationVersion)
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: r.ru}]->(fv)
SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validTo = a.validTo, h.validFromPrecision = a.validFromPrecision, h.validToPrecision = a.validToPrecision,
    h.validFromBasis = a.validFromBasis, h.validToBasis = a.validToBasis, h.recordedFrom = a.recordedAt, h.recordedTo = a.recordedTo, h.jurisdiction = 'US';

// ---- USES_MATERIAL (asserted) for every component ----
UNWIND [
  {c: 'hu:component:w04-syn-a-200-x', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-03-02', rec: '2026-03-02T10:00:00Z'},
  {c: 'hu:component:w04-syn-a-120-x', loc: 'hu:locator:w04-syn-pair-a-x-line-2026-06-15', rec: '2026-06-15T10:00:00Z'},
  {c: 'hu:component:w04-syn-b-200-x', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-03-02', rec: '2026-03-02T10:00:00Z'},
  {c: 'hu:component:w04-syn-b-150-x', loc: 'hu:locator:w04-syn-pair-b-x-line-2026-06-20', rec: '2026-06-20T10:00:00Z'}
] AS r
MATCH (c:IngredientComponent {uid: r.c}), (m:IngredientMaterial {uid: 'hu:material:w04-syn-ingredient-x'}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: 'hu:assertion:' + split(r.c, ':')[2] + '-uses-material'})
SET a.predicate = 'USES_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime(r.rec), a.contentHash = 'synthetic:uses-material:' + r.c,
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime(r.rec)
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:HAS_OBJECT]->(m)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (c)-[u:USES_MATERIAL {relationshipUid: 'hu:rel:' + split(r.c, ':')[2] + '-uses-material'}]->(m)
SET u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN';

// ---- capture-fidelity adjudication (INV-103): records are accurate captures; says nothing about truth ----
MATCH (a:Assertion)
WHERE a.uid STARTS WITH 'hu:assertion:w04-syn-' AND a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
WITH collect(a) AS as
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w04-01-capture-fidelity-policy'})
SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY',
    j.methodVersion = 'fixture-capture-policy-1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T00:00:00Z'),
    j.recordedAt = datetime('2026-10-04T00:00:00Z'), j.createdAt = datetime('2026-10-04T00:00:00Z'), j.privacyClass = 'INTERNAL'
WITH j, as
UNWIND as AS a
MERGE (j)-[:EVALUATES]->(a);
