// Fixture: recommendation snapshot, corrections, late facts, and private/public separation
// Rounds: 0007 (bitemporal corrections and late facts), 0008 (private recommendation history)
// Illustrative fixture only, not a production import. Neo4j 5 Cypher.
// All products, brands, protocols, values, and the person are SYNTHETIC. No PHI. No real company
// is described as correcting or reformulating anything. The only real external identifier used is
// LOINC 19123-9 (Magnesium [Mass/volume] in Serum or Plasma), as a Metric identifier.
//
// PLACEMENT NOTE (round 0008): in production, Section 2 records live in the private context store
// (PCS, a transactional database), never in the shared Neo4j graph. They are rendered here as nodes
// Never load this file into a shared (production) database: section 2 would then be a real leak and V-520/V-521 return
// its rows by design. The private nodes carry the label :PrivateRecord only so that the leak checks in Section 3 can be exercised.
// Crossing references (private -> shared) are uid-valued properties, never relationships.
// Relationships appear only private -> private (PCS foreign keys) and shared -> shared.
//
// Every statement is self-contained: nodes used by a relationship are MATCHed by uid in the same
// statement. Timestamps are literals so the fixture is deterministic.
//
// Timeline (all UTC):
//   2026-03-02  labels for Product A and Product B observed; assertions A1, B1 recorded
//   2026-04-09  user context version 1 recorded
//   2026-04-10  RecommendationSnapshot recorded (evidence viewpoint R = 2026-04-10T09:00:00Z)
//   2026-05-22  PersonalMeasurement recorded; user context version 2 recorded (snapshot untouched)
//   2026-06-15  Product A label CORRECTED (erratum): A2 supersedes A1 (SOURCE_CORRECTION)
//   2026-06-20  Product B formulation CEASED effective 2026-06-10: B1b supersedes B1 (VALIDITY_BOUNDED)
//   2026-08-01  LATE-ARRIVING 2019 archived label for Product A recorded (A0)
// Executed 2026-10-03 on an embedded Neo4j 5.26 Community instance (authoring scratchpad): every statement ran, and the full
// 0.2.0 validation suite (../neo4j/validation.cypher) returned zero failing rows with this fixture loaded alone and with all six
// fixtures loaded together. Expected informational rows are listed in ../ontology-lab/proposal-index.md section 9.

// =====================================================================================
// SECTION 1. SHARED GRAPH (privacyClass public or internal)
// =====================================================================================

// 1.1 Goal concept and metric (public)
MERGE (g:Entity:FunctionalGoal {uid: 'hu:functional-goal:shorter-sleep-onset'})
SET g.name = 'Shorter sleep onset', g.privacyClass = 'PUBLIC', g.createdAt = datetime('2026-01-05T00:00:00Z');

MERGE (m:Entity:Metric {uid: 'hu:metric:serum-magnesium-mass-concentration'})
SET m.name = 'Magnesium [Mass/volume] in Serum or Plasma', m.loincCode = '19123-9', m.ucumUnit = 'mg/dL',
    m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-01-05T00:00:00Z');

// 1.2 Synthetic products, variants, materials
MERGE (p:Entity:Product {uid: 'hu:product:synthetic-sleepwell-magnesium'})
SET p.name = 'SleepWell Magnesium (synthetic)', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (p:Entity:Product {uid: 'hu:product:synthetic-calmroot-glycine'})
SET p.name = 'CalmRoot Glycine (synthetic)', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (p:Entity:Product {uid: 'hu:product:synthetic-nightcue-melatonin'})
SET p.name = 'NightCue Melatonin (synthetic)', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (v:Entity:ProductVariant {uid: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule'})
SET v.name = 'SleepWell Magnesium US capsules (synthetic)', v.jurisdiction = 'US', v.dosageForm = 'CAPSULE', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (v:Entity:ProductVariant {uid: 'hu:product-variant:synthetic-calmroot-glycine-us-powder'})
SET v.name = 'CalmRoot Glycine US powder (synthetic)', v.jurisdiction = 'US', v.dosageForm = 'POWDER', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (v:Entity:ProductVariant {uid: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet'})
SET v.name = 'NightCue Melatonin US tablets (synthetic)', v.jurisdiction = 'US', v.dosageForm = 'TABLET', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T00:00:00Z');

MATCH (p:Product {uid: 'hu:product:synthetic-sleepwell-magnesium'}), (v:ProductVariant {uid: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule'})
MERGE (p)-[hv:HAS_VARIANT]->(v)
SET hv.assertionUid = 'hu:assertion:synthetic-sleepwell-magnesium-us-capsule-is-variant', hv.recordedFrom = datetime('2026-03-02T10:10:00Z'), hv.relationshipUid = 'hu:rel:synthetic-sleepwell-magnesium-us-capsule-is-variant';

MATCH (p:Product {uid: 'hu:product:synthetic-calmroot-glycine'}), (v:ProductVariant {uid: 'hu:product-variant:synthetic-calmroot-glycine-us-powder'})
MERGE (p)-[hv:HAS_VARIANT]->(v)
SET hv.assertionUid = 'hu:assertion:synthetic-calmroot-glycine-us-powder-is-variant', hv.recordedFrom = datetime('2026-03-02T10:10:00Z'), hv.relationshipUid = 'hu:rel:synthetic-calmroot-glycine-us-powder-is-variant';

MATCH (p:Product {uid: 'hu:product:synthetic-nightcue-melatonin'}), (v:ProductVariant {uid: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet'})
MERGE (p)-[hv:HAS_VARIANT]->(v)
SET hv.assertionUid = 'hu:assertion:synthetic-nightcue-melatonin-us-tablet-is-variant', hv.recordedFrom = datetime('2026-03-02T10:10:00Z'), hv.relationshipUid = 'hu:rel:synthetic-nightcue-melatonin-us-tablet-is-variant';

MERGE (mat:Entity:IngredientMaterial {uid: 'hu:material:synthetic-magnesium-glycinate'})
SET mat.name = 'Magnesium glycinate (synthetic material record)', mat.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', mat.privacyClass = 'PUBLIC', mat.createdAt = datetime('2026-03-02T00:00:00Z');

// 1.3 Formulation versions (immutable payload states; no time on the node)
MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded'})
SET fv.versionName = 'SleepWell label as observed 2026-03-02 (200 mg elemental Mg declared)', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-a1', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a1-corrected'})
SET fv.versionName = 'SleepWell label as corrected 2026-06-15 (120 mg elemental Mg declared)', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-a1c', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-06-15T00:00:00Z');

MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a0-2019'})
SET fv.versionName = 'SleepWell 2019 label from archived capture', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-a0', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-08-01T00:00:00Z');

MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-calmroot-fv-b1'})
SET fv.versionName = 'CalmRoot formulation 1 (3 g glycine per serving)', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-b1', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-calmroot-fv-b2'})
SET fv.versionName = 'CalmRoot formulation 2 (2 g glycine per serving), effective 2026-06-10', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-b2', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-06-20T00:00:00Z');

MERGE (fv:VersionedState:FormulationVersion {uid: 'hu:formulation:synthetic-nightcue-fv-c1'})
SET fv.versionName = 'NightCue formulation as observed 2026-03-02', fv.jurisdiction = 'US', fv.payloadHash = 'sha256:fixture-fv-c1', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (c:VersionedState:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1-mg'})
SET c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = 200.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING_ELEMENTAL',
    c.declaredAs = 'Magnesium (as magnesium glycinate) 200 mg', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (c:VersionedState:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1c-mg'})
SET c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = 120.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING_ELEMENTAL',
    c.declaredAs = 'Magnesium (as magnesium glycinate) 120 mg', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-06-15T00:00:00Z');

MATCH (fv:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded'}), (c:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1-mg'})
MERGE (fv)-[:HAS_INGREDIENT_COMPONENT]->(c);

MATCH (fv:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a1-corrected'}), (c:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1c-mg'})
MERGE (fv)-[:HAS_INGREDIENT_COMPONENT]->(c);

MATCH (c:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1-mg'}), (mat:IngredientMaterial {uid: 'hu:material:synthetic-magnesium-glycinate'})
MERGE (c)-[u:USES_MATERIAL]->(mat)
SET u.assertionUid = 'hu:assertion:synthetic-sleepwell-fv-a1-mg-uses-material', u.recordedFrom = datetime('2026-03-02T10:10:00Z'), u.relationshipUid = 'hu:rel:synthetic-sleepwell-fv-a1-mg-uses-material';

MATCH (c:IngredientComponent {uid: 'hu:component:synthetic-sleepwell-fv-a1c-mg'}), (mat:IngredientMaterial {uid: 'hu:material:synthetic-magnesium-glycinate'})
MERGE (c)-[u:USES_MATERIAL]->(mat)
SET u.assertionUid = 'hu:assertion:synthetic-sleepwell-fv-a1c-mg-uses-material', u.recordedFrom = datetime('2026-06-15T08:10:00Z'), u.relationshipUid = 'hu:rel:synthetic-sleepwell-fv-a1c-mg-uses-material';

// 1.4 Sources, immutable snapshots, locators
MERGE (s:Entity:Source {uid: 'hu:source:synthetic-sleepwell-label-page'})
SET s.canonicalUri = 'https://example.invalid/sleepwell/label', s.title = 'SleepWell label page (synthetic)', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (s:Entity:Source {uid: 'hu:source:synthetic-calmroot-label-page'})
SET s.canonicalUri = 'https://example.invalid/calmroot/label', s.title = 'CalmRoot label page (synthetic)', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (s:Entity:Source {uid: 'hu:source:synthetic-nightcue-label-page'})
SET s.canonicalUri = 'https://example.invalid/nightcue/label', s.title = 'NightCue label page (synthetic)', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-02T00:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-sleepwell-label-2026-03-02'})
SET sn.canonicalUri = 'https://example.invalid/sleepwell/label', sn.observedAt = datetime('2026-03-02T10:00:00Z'), sn.retrievedAt = datetime('2026-03-02T10:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-a1', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-sleepwell-label-2026-06-15'})
SET sn.canonicalUri = 'https://example.invalid/sleepwell/label', sn.observedAt = datetime('2026-06-15T08:00:00Z'), sn.retrievedAt = datetime('2026-06-15T08:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-a2', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-06-15T08:00:00Z');

// Late-arriving: an archive capture made in 2019, fetched by BellLabs in 2026. observedAt != retrievedAt.
MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-sleepwell-label-archive-2019-05-10'})
SET sn.canonicalUri = 'https://example.invalid/sleepwell/label', sn.observedAt = datetime('2019-05-10T00:00:00Z'), sn.retrievedAt = datetime('2026-08-01T07:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-a0', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-08-01T07:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-calmroot-label-2026-03-02'})
SET sn.canonicalUri = 'https://example.invalid/calmroot/label', sn.observedAt = datetime('2026-03-02T10:00:00Z'), sn.retrievedAt = datetime('2026-03-02T10:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-b1', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-03-02T10:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-calmroot-label-2026-06-20'})
SET sn.canonicalUri = 'https://example.invalid/calmroot/label', sn.observedAt = datetime('2026-06-20T09:00:00Z'), sn.retrievedAt = datetime('2026-06-20T09:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-b3', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-06-20T09:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:synthetic-nightcue-label-2026-03-02'})
SET sn.canonicalUri = 'https://example.invalid/nightcue/label', sn.observedAt = datetime('2026-03-02T10:00:00Z'), sn.retrievedAt = datetime('2026-03-02T10:00:00Z'),
    sn.contentHash = 'sha256:fixture-snap-c1', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-03-02T10:00:00Z');

UNWIND [
  {src: 'hu:source:synthetic-sleepwell-label-page', snap: 'hu:snapshot:synthetic-sleepwell-label-2026-03-02', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02'},
  {src: 'hu:source:synthetic-sleepwell-label-page', snap: 'hu:snapshot:synthetic-sleepwell-label-2026-06-15', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-06-15'},
  {src: 'hu:source:synthetic-sleepwell-label-page', snap: 'hu:snapshot:synthetic-sleepwell-label-archive-2019-05-10', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2019-05-10'},
  {src: 'hu:source:synthetic-calmroot-label-page', snap: 'hu:snapshot:synthetic-calmroot-label-2026-03-02', loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-03-02'},
  {src: 'hu:source:synthetic-calmroot-label-page', snap: 'hu:snapshot:synthetic-calmroot-label-2026-06-20', loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-06-20'},
  {src: 'hu:source:synthetic-nightcue-label-page', snap: 'hu:snapshot:synthetic-nightcue-label-2026-03-02', loc: 'hu:locator:synthetic-nightcue-facts-panel-2026-03-02'}
] AS row
MATCH (s:Source {uid: row.src}), (sn:SourceSnapshot {uid: row.snap})
MERGE (l:InformationArtifact:SourceLocator {uid: row.loc})
SET l.selectorKind = 'SECTION', l.uri = s.canonicalUri, l.section = 'Supplement Facts', l.privacyClass = 'PUBLIC', l.createdAt = sn.createdAt
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// 1.5 Source revision event for the Product A erratum (round 0007, KCR-0007-3)
MERGE (ev:Occurrence:SourceRevisionEvent {uid: 'hu:source-revision:synthetic-sleepwell-label-erratum-2026-06'})
SET ev.revisionKind = 'ERRATUM', ev.occurredAt = datetime('2026-06-14T00:00:00Z'), ev.occurredAtPrecision = 'DAY',
    ev.recordedAt = datetime('2026-06-15T08:05:00Z'), ev.privacyClass = 'PUBLIC', ev.createdAt = datetime('2026-06-15T08:05:00Z');

MATCH (ev:SourceRevisionEvent {uid: 'hu:source-revision:synthetic-sleepwell-label-erratum-2026-06'}),
      (s:Source {uid: 'hu:source:synthetic-sleepwell-label-page'}),
      (prior:SourceSnapshot {uid: 'hu:snapshot:synthetic-sleepwell-label-2026-03-02'}),
      (res:SourceSnapshot {uid: 'hu:snapshot:synthetic-sleepwell-label-2026-06-15'})
MERGE (ev)-[:REVISES_SOURCE]->(s)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(prior)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(res);

// 1.6 Assertions (content immutable; only recordedTo is written once when superseded)
UNWIND [
  {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a1', subj: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', obj: 'hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded',
   loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02', status: 'SUPERSEDED',
   vf: datetime('2025-11-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE', vt: null, vtp: null, vtb: 'UNKNOWN',
   rat: datetime('2026-03-02T10:10:00Z'), rto: datetime('2026-06-15T08:10:00Z')},
  {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a1-corrected', subj: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', obj: 'hu:formulation:synthetic-sleepwell-fv-a1-corrected',
   loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-06-15', status: 'ACCEPTED',
   vf: datetime('2025-11-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE', vt: null, vtp: null, vtb: 'UNKNOWN',
   rat: datetime('2026-06-15T08:10:00Z'), rto: null},
  {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a0-2019', subj: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', obj: 'hu:formulation:synthetic-sleepwell-fv-a0-2019',
   loc: 'hu:locator:synthetic-sleepwell-facts-panel-2019-05-10', status: 'ACCEPTED',
   vf: datetime('2019-01-01T00:00:00Z'), vfp: 'YEAR', vfb: 'STATED_BY_SOURCE', vt: datetime('2025-11-01T00:00:00Z'), vtp: 'MONTH', vtb: 'INFERRED',
   rat: datetime('2026-08-01T07:10:00Z'), rto: null},
  {uid: 'hu:assertion:synthetic-calmroot-variant-fv-b1', subj: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', obj: 'hu:formulation:synthetic-calmroot-fv-b1',
   loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-03-02', status: 'SUPERSEDED',
   vf: datetime('2025-01-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE', vt: null, vtp: null, vtb: 'UNKNOWN',
   rat: datetime('2026-03-02T10:10:00Z'), rto: datetime('2026-06-20T09:10:00Z')},
  {uid: 'hu:assertion:synthetic-calmroot-variant-fv-b1-bounded', subj: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', obj: 'hu:formulation:synthetic-calmroot-fv-b1',
   loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-06-20', status: 'ACCEPTED',
   vf: datetime('2025-01-01T00:00:00Z'), vfp: 'MONTH', vfb: 'STATED_BY_SOURCE', vt: datetime('2026-06-10T00:00:00Z'), vtp: 'DAY', vtb: 'STATED_BY_SOURCE',
   rat: datetime('2026-06-20T09:10:00Z'), rto: null},
  {uid: 'hu:assertion:synthetic-calmroot-variant-fv-b2', subj: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', obj: 'hu:formulation:synthetic-calmroot-fv-b2',
   loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-06-20', status: 'ACCEPTED',
   vf: datetime('2026-06-10T00:00:00Z'), vfp: 'DAY', vfb: 'STATED_BY_SOURCE', vt: null, vtp: null, vtb: 'UNKNOWN',
   rat: datetime('2026-06-20T09:10:00Z'), rto: null},
  {uid: 'hu:assertion:synthetic-nightcue-variant-fv-c1', subj: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet', obj: 'hu:formulation:synthetic-nightcue-fv-c1',
   loc: 'hu:locator:synthetic-nightcue-facts-panel-2026-03-02', status: 'ACCEPTED',
   vf: null, vfp: null, vfb: 'OBSERVATION_ONLY', vt: null, vtp: null, vtb: 'UNKNOWN',
   rat: datetime('2026-03-02T10:10:00Z'), rto: null}
] AS row
MATCH (subj {uid: row.subj}), (obj {uid: row.obj}), (l:SourceLocator {uid: row.loc})
MERGE (a:Assertion {uid: row.uid})
SET a.predicate = 'HAS_FORMULATION_VERSION', a.polarity = 'POSITIVE', a.status = row.status,
    a.validFrom = row.vf, a.validFromPrecision = row.vfp, a.validFromBasis = row.vfb,
    a.validTo = row.vt, a.validToPrecision = row.vtp, a.validToBasis = row.vtb,
    a.recordedAt = row.rat, a.recordedTo = row.rto,
    a.contentHash = 'sha256:fixture-' + row.uid, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:HAS_OBJECT]->(obj)
MERGE (a)-[:SUPPORTED_BY]->(l);

// The late fact's inferred validTo names its rule (round 0007 section 8).
MATCH (a:Assertion {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a0-2019'})
SET a.derivationRule = 'successor_state_start';

// 1.7 Supersession edges: correction versus validity bounded (the minimal pair)
MATCH (newer:Assertion {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a1-corrected'}), (older:Assertion {uid: 'hu:assertion:synthetic-sleepwell-variant-fv-a1'})
MERGE (newer)-[r:SUPERSEDES]->(older)
SET r.supersessionKind = 'SOURCE_CORRECTION', r.recordedAt = datetime('2026-06-15T08:10:00Z'),
    r.sourceRevisionEventUid = 'hu:source-revision:synthetic-sleepwell-label-erratum-2026-06';

MATCH (newer:Assertion {uid: 'hu:assertion:synthetic-calmroot-variant-fv-b1-bounded'}), (older:Assertion {uid: 'hu:assertion:synthetic-calmroot-variant-fv-b1'})
MERGE (newer)-[r:SUPERSEDES]->(older)
SET r.supersessionKind = 'VALIDITY_BOUNDED', r.recordedAt = datetime('2026-06-20T09:10:00Z');

// 1.8 Adjudications (immutable, time-stamped; KCR-0007-2). Policy acceptance is recorded too.
UNWIND [
  {uid: 'hu:adjudication:synthetic-a1-accept', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a1', rat: datetime('2026-03-02T10:20:00Z'), loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02'},
  {uid: 'hu:adjudication:synthetic-a1c-accept', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a1-corrected', rat: datetime('2026-06-15T08:20:00Z'), loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-06-15'},
  {uid: 'hu:adjudication:synthetic-a0-accept', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a0-2019', rat: datetime('2026-08-01T07:20:00Z'), loc: 'hu:locator:synthetic-sleepwell-facts-panel-2019-05-10'},
  {uid: 'hu:adjudication:synthetic-b1-accept', a: 'hu:assertion:synthetic-calmroot-variant-fv-b1', rat: datetime('2026-03-02T10:20:00Z'), loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-03-02'},
  {uid: 'hu:adjudication:synthetic-b1b-accept', a: 'hu:assertion:synthetic-calmroot-variant-fv-b1-bounded', rat: datetime('2026-06-20T09:20:00Z'), loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-06-20'},
  {uid: 'hu:adjudication:synthetic-b2-accept', a: 'hu:assertion:synthetic-calmroot-variant-fv-b2', rat: datetime('2026-06-20T09:20:00Z'), loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-06-20'},
  {uid: 'hu:adjudication:synthetic-c1-accept', a: 'hu:assertion:synthetic-nightcue-variant-fv-c1', rat: datetime('2026-03-02T10:20:00Z'), loc: 'hu:locator:synthetic-nightcue-facts-panel-2026-03-02'}
] AS row
MATCH (a:Assertion {uid: row.a}), (l:SourceLocator {uid: row.loc})
MERGE (adj:EvidenceAssessment:Adjudication {uid: row.uid})
SET adj.assessmentType = 'ADJUDICATION', adj.methodVersion = 'label-policy-1', adj.status = 'FINAL',
    adj.adjudicationKind = 'CAPTURE_FIDELITY', adj.verdict = 'SUPPORTED', adj.reviewerType = 'POLICY', adj.recordedAt = row.rat, adj.reviewedAt = row.rat,
    adj.privacyClass = 'INTERNAL', adj.createdAt = row.rat
MERGE (adj)-[:EVALUATES]->(a)
MERGE (adj)-[:SUPPORTED_BY]->(l);


// 1.8b Assertions behind the variant and composition projections above (each cites the label panel it was read from).
UNWIND [
  {a: 'hu:assertion:synthetic-sleepwell-magnesium-us-capsule-is-variant', pred: 'HAS_VARIANT', s: 'hu:product:synthetic-sleepwell-magnesium', o: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02', rat: datetime('2026-03-02T10:10:00Z')},
  {a: 'hu:assertion:synthetic-calmroot-glycine-us-powder-is-variant', pred: 'HAS_VARIANT', s: 'hu:product:synthetic-calmroot-glycine', o: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-03-02', rat: datetime('2026-03-02T10:10:00Z')},
  {a: 'hu:assertion:synthetic-nightcue-melatonin-us-tablet-is-variant', pred: 'HAS_VARIANT', s: 'hu:product:synthetic-nightcue-melatonin', o: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet', loc: 'hu:locator:synthetic-nightcue-facts-panel-2026-03-02', rat: datetime('2026-03-02T10:10:00Z')},
  {a: 'hu:assertion:synthetic-sleepwell-fv-a1-mg-uses-material', pred: 'USES_MATERIAL', s: 'hu:component:synthetic-sleepwell-fv-a1-mg', o: 'hu:material:synthetic-magnesium-glycinate', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02', rat: datetime('2026-03-02T10:10:00Z')},
  {a: 'hu:assertion:synthetic-sleepwell-fv-a1c-mg-uses-material', pred: 'USES_MATERIAL', s: 'hu:component:synthetic-sleepwell-fv-a1c-mg', o: 'hu:material:synthetic-magnesium-glycinate', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-06-15', rat: datetime('2026-06-15T08:10:00Z')}
] AS row
MATCH (s {uid: row.s}), (o {uid: row.o}), (l:SourceLocator {uid: row.loc})
MERGE (a:Assertion {uid: row.a})
SET a.predicate = row.pred, a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = row.rat, a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:fixture-' + row.a
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// 1.9 Bitemporal attachment episodes (one relationship per recorded-time episode)
UNWIND [
  {ru: 'hu:rel:fixture-eA1', v: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', fv: 'hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a1'},
  {ru: 'hu:rel:fixture-eA2', v: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', fv: 'hu:formulation:synthetic-sleepwell-fv-a1-corrected', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a1-corrected'},
  {ru: 'hu:rel:fixture-eA0', v: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', fv: 'hu:formulation:synthetic-sleepwell-fv-a0-2019', a: 'hu:assertion:synthetic-sleepwell-variant-fv-a0-2019'},
  {ru: 'hu:rel:fixture-eB1', v: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', fv: 'hu:formulation:synthetic-calmroot-fv-b1', a: 'hu:assertion:synthetic-calmroot-variant-fv-b1'},
  {ru: 'hu:rel:fixture-eB1b', v: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', fv: 'hu:formulation:synthetic-calmroot-fv-b1', a: 'hu:assertion:synthetic-calmroot-variant-fv-b1-bounded'},
  {ru: 'hu:rel:fixture-eB2', v: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', fv: 'hu:formulation:synthetic-calmroot-fv-b2', a: 'hu:assertion:synthetic-calmroot-variant-fv-b2'},
  {ru: 'hu:rel:fixture-eC1', v: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet', fv: 'hu:formulation:synthetic-nightcue-fv-c1', a: 'hu:assertion:synthetic-nightcue-variant-fv-c1'}
] AS row
MATCH (v:ProductVariant {uid: row.v}), (fv:FormulationVersion {uid: row.fv}), (a:Assertion {uid: row.a})
MERGE (v)-[h:HAS_FORMULATION_VERSION {relationshipUid: row.ru}]->(fv)
SET h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
    h.validTo = a.validTo, h.validToPrecision = a.validToPrecision, h.validToBasis = a.validToBasis,
    h.recordedFrom = a.recordedAt, h.recordedTo = a.recordedTo,
    h.assertionUid = a.uid;

// 1.10 Shared applicability assessments target a non-personal use profile, never a UserContext.
MERGE (u:Entity:UseContextProfile {uid: 'hu:use-profile:adult-evening-sleep-support-us'})
SET u.name = 'Adults, evening use, sleep onset support, US', u.privacyClass = 'PUBLIC', u.createdAt = datetime('2026-03-05T00:00:00Z');

MERGE (ea:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'})
SET ea.assessmentType = 'EVIDENCE_APPLICABILITY', ea.methodVersion = 'applicability-0.3', ea.status = 'FINAL',
    ea.identityMatch = 'UNKNOWN', ea.doseMatch = 'MATCH', ea.populationMatch = 'PARTIAL',
    ea.privacyClass = 'PUBLIC', ea.createdAt = datetime('2026-03-05T00:00:00Z'), ea.recordedAt = datetime('2026-03-05T00:00:00Z');

MERGE (ea:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:synthetic-glycine-evidence-to-calmroot-fv-b1'})
SET ea.assessmentType = 'EVIDENCE_APPLICABILITY', ea.methodVersion = 'applicability-0.3', ea.status = 'FINAL',
    ea.identityMatch = 'UNKNOWN', ea.doseMatch = 'UNKNOWN', ea.populationMatch = 'PARTIAL',
    ea.privacyClass = 'PUBLIC', ea.createdAt = datetime('2026-03-05T00:00:00Z'), ea.recordedAt = datetime('2026-03-05T00:00:00Z');

MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'}),
      (fv:FormulationVersion {uid: 'hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded'}),
      (u:UseContextProfile {uid: 'hu:use-profile:adult-evening-sleep-support-us'})
MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(fv)
MERGE (ea)-[:FOR_USE_CONTEXT]->(u);

MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:synthetic-glycine-evidence-to-calmroot-fv-b1'}),
      (fv:FormulationVersion {uid: 'hu:formulation:synthetic-calmroot-fv-b1'}),
      (u:UseContextProfile {uid: 'hu:use-profile:adult-evening-sleep-support-us'})
MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(fv)
MERGE (ea)-[:FOR_USE_CONTEXT]->(u);

// 1.10b Evidence targets: synthetic mechanism-level assertions standing for the ingredient evidence these assessments rest on.
UNWIND [
  {ea: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1', a: 'hu:assertion:synthetic-evidence-magnesium-glycinate-sleep-onset', mat: 'hu:material:synthetic-magnesium-glycinate', loc: 'hu:locator:synthetic-sleepwell-facts-panel-2026-03-02'},
  {ea: 'hu:applicability:synthetic-glycine-evidence-to-calmroot-fv-b1', a: 'hu:assertion:synthetic-evidence-glycine-sleep-quality', mat: 'hu:material:synthetic-magnesium-glycinate', loc: 'hu:locator:synthetic-calmroot-facts-panel-2026-03-02'}
] AS row
MATCH (ea:EvidenceApplicability {uid: row.ea}), (mat:IngredientMaterial {uid: row.mat}), (l:SourceLocator {uid: row.loc})
MERGE (a:Assertion {uid: row.a})
SET a.predicate = 'IMPROVES', a.predicateClass = 'MECHANISM', a.basisKind = 'CITED_FROM_PRIOR_WORK', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
    a.valueString = 'synthetic evidence placeholder (fixture)', a.recordedAt = datetime('2026-03-05T00:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(mat)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (ea)-[:HAS_EVIDENCE_TARGET]->(a)
MERGE (ea)-[:BASED_ON_EVIDENCE]->(a);


// 1.10c Applicability dimensions (INV-202, INV-212): one node per required dimension for an assertion-kind evidence target.
// The flat identityMatch/doseMatch fields above are derived projections of these nodes.
UNWIND [
  {ea: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'},
  {ea: 'hu:applicability:synthetic-glycine-evidence-to-calmroot-fv-b1'}
] AS row
MATCH (ea:EvidenceApplicability {uid: row.ea})
UNWIND [
  {dim: 'MATERIAL_IDENTITY', cls: 'CATEGORICAL', verdict: 'UNKNOWN', level: 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED', missing: ['supplier specification of the evidence material']},
  {dim: 'EXPOSURE', cls: 'CONTINUOUS', verdict: 'UNKNOWN', level: null, missing: ['human exposure result for the product material and form']},
  {dim: 'ROUTE', cls: 'CATEGORICAL', verdict: 'MATCH', level: null, missing: []},
  {dim: 'DURATION', cls: 'CONTINUOUS', verdict: 'UNKNOWN', level: null, missing: ['study duration']},
  {dim: 'POPULATION', cls: 'CATEGORICAL', verdict: 'PARTIAL', level: null, missing: ['age range of the evidence population']},
  {dim: 'OUTCOME_RELEVANCE', cls: 'CATEGORICAL', verdict: 'PARTIAL', level: null, missing: []},
  {dim: 'STUDY_DESIGN_AND_QUALITY', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', level: null, missing: [], rationale: 'Design appraisal not performed in this fixture; NOT_ASSESSED is recorded explicitly rather than left absent.'}
] AS d
MERGE (dim:EvidenceAssessment:ApplicabilityDimension {uid: ea.uid + '-' + toLower(replace(d.dim, '_', '-'))})
ON CREATE SET dim.assessmentType = 'APPLICABILITY_DIMENSION', dim.dimension = d.dim, dim.dimensionClass = d.cls, dim.verdict = d.verdict,
              dim.identityLevel = d.level, dim.missingFacts = d.missing, dim.rationale = d.rationale, dim.methodVersion = 'applicability-0.3', dim.status = 'FINAL',
              dim.privacyClass = 'PUBLIC', dim.createdAt = datetime('2026-03-05T00:00:00Z'), dim.recordedAt = datetime('2026-03-05T00:00:00Z')
MERGE (ea)-[:HAS_DIMENSION]->(dim)
WITH ea, dim
MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(ev:Assertion)
MERGE (dim)-[:CONSIDERS]->(ev);

// 1.11 Policy version (shared, internal; contains no personal data)
MERGE (pv:VersionedState:PolicyVersion {uid: 'hu:policy-version:sleep-support-ranking-v3'})
SET pv.name = 'Sleep support ranking and safety policy v3 (synthetic)', pv.payloadHash = 'sha256:fixture-policy-v3',
    pv.privacyClass = 'INTERNAL', pv.createdAt = datetime('2026-03-20T00:00:00Z');

// 1.12 Public protocol with two editions (round 0008 section 6)
MERGE (pr:Entity:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'})
SET pr.name = 'Evening wind-down protocol (synthetic)', pr.protocolType = 'SLEEP_PROTOCOL', pr.privacyClass = 'PUBLIC', pr.createdAt = datetime('2026-03-01T00:00:00Z');

MERGE (e1:VersionedState:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})
SET e1.editionLabel = 'v1', e1.payloadHash = 'sha256:fixture-edition-1', e1.privacyClass = 'PUBLIC', e1.createdAt = datetime('2026-03-01T00:00:00Z');

MERGE (e2:VersionedState:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e2'})
SET e2.editionLabel = null, e2.payloadHash = 'sha256:fixture-edition-2', e2.privacyClass = 'PUBLIC', e2.createdAt = datetime('2026-03-01T00:00:00Z');

UNWIND [
  {uid: 'hu:protocol-step:synthetic-wind-down-screen-free-hour', key: 'screen-free-hour', kind: 'AVOID', lvl: 'OPTIONAL', hash: 'sha256:step-screen-1'},
  {uid: 'hu:protocol-step:synthetic-wind-down-fixed-bedtime', key: 'fixed-bedtime', kind: 'SLEEP', lvl: 'ESSENTIAL', hash: 'sha256:step-bed-1'},
  {uid: 'hu:protocol-step:synthetic-wind-down-magnesium-e1', key: 'magnesium-evening', kind: 'INGEST', lvl: 'ESSENTIAL', hash: 'sha256:step-mg-1'},
  {uid: 'hu:protocol-step:synthetic-wind-down-magnesium-e2', key: 'magnesium-evening', kind: 'INGEST', lvl: 'CONDITIONAL', hash: 'sha256:step-mg-2'},
  {uid: 'hu:protocol-step:synthetic-wind-down-baseline-mg', key: 'baseline-serum-magnesium', kind: 'MEASURE', lvl: 'ESSENTIAL', hash: 'sha256:step-base-2'}
] AS row
MERGE (s:Entity:ProtocolStep {uid: row.uid})
SET s.stepKey = row.key, s.stepKind = row.kind, s.requirementLevel = row.lvl, s.requirementBasis = 'STATED_BY_SOURCE',
    s.payloadHash = row.hash, s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-03-01T00:00:00Z');

MATCH (s:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-magnesium-e1'})
SET s.notReportedFields = ['durationDaysMin', 'durationDaysMax'];

UNWIND [
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e1', s: 'hu:protocol-step:synthetic-wind-down-screen-free-hour', o: 1},
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e1', s: 'hu:protocol-step:synthetic-wind-down-magnesium-e1', o: 2},
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e1', s: 'hu:protocol-step:synthetic-wind-down-fixed-bedtime', o: 3},
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e2', s: 'hu:protocol-step:synthetic-wind-down-baseline-mg', o: 1},
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e2', s: 'hu:protocol-step:synthetic-wind-down-magnesium-e2', o: 2},
  {e: 'hu:protocol-edition:synthetic-evening-wind-down-e2', s: 'hu:protocol-step:synthetic-wind-down-fixed-bedtime', o: 3}
] AS row
MATCH (e:ProtocolEdition {uid: row.e}), (s:ProtocolStep {uid: row.s})
MERGE (e)-[r:HAS_STEP]->(s)
SET r.orderIndex = row.o;

// Edition 2: the magnesium step depends on the result of the baseline measurement and applies only when it is within range.
MATCH (mg:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-magnesium-e2'}), (base:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-baseline-mg'})
MERGE (mg)-[d:DEPENDS_ON]->(base)
SET d.dependencyKind = 'REQUIRES_RESULT_OF';

MERGE (k:Entity:Constraint {uid: 'hu:constraint:synthetic-baseline-mg-within-reference-range'})
SET k.name = 'Baseline serum magnesium within the reporting laboratory reference range', k.constraintKind = 'MEASUREMENT_THRESHOLD',
    k.privacyClass = 'PUBLIC', k.createdAt = datetime('2026-03-01T00:00:00Z');

MATCH (mg:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-magnesium-e2'}), (k:Constraint {uid: 'hu:constraint:synthetic-baseline-mg-within-reference-range'})
MERGE (mg)-[r:HAS_CONSTRAINT]->(k)
SET r.constraintRole = 'APPLIES_WHEN';

MATCH (k:Constraint {uid: 'hu:constraint:synthetic-baseline-mg-within-reference-range'}), (m:Metric {uid: 'hu:metric:serum-magnesium-mass-concentration'})
MERGE (k)-[:BASED_ON]->(m);

MERGE (rule:Entity:ProtocolAdjustmentRule {uid: 'hu:protocol-rule:synthetic-mg-outside-range-review'})
SET rule.name = 'Review if serum magnesium is outside the reporting reference range', rule.triggerKind = 'THRESHOLD_CROSSED',
    rule.comparator = 'OUTSIDE_REFERENCE_RANGE', rule.triggerAction = 'REVIEW', rule.ruleBasis = 'STATED_BY_SOURCE',
    rule.privacyClass = 'PUBLIC', rule.createdAt = datetime('2026-03-01T00:00:00Z');

MATCH (rule:ProtocolAdjustmentRule {uid: 'hu:protocol-rule:synthetic-mg-outside-range-review'}), (m:Metric {uid: 'hu:metric:serum-magnesium-mass-concentration'}),
      (e2:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e2'})
MERGE (rule)-[:TRIGGERED_BY]->(m)
MERGE (e2)-[:HAS_ADJUSTMENT_RULE]->(rule);

MERGE (src:Entity:Source {uid: 'hu:source:synthetic-wind-down-protocol-page'})
SET src.canonicalUri = 'https://example.invalid/wind-down', src.title = 'Evening wind-down protocol page (synthetic)', src.sourceKind = 'PROTOCOL_PAGE',
    src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-03-01T00:00:00Z');

MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-wind-down-page-2026-03-01'})
SET sn.canonicalUri = 'https://example.invalid/wind-down', sn.observedAt = datetime('2026-03-01T12:00:00Z'), sn.retrievedAt = datetime('2026-03-01T12:00:00Z'),
    sn.contentHash = 'sha256:fixture-protocol-page', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-03-01T12:00:00Z');

MATCH (src:Source {uid: 'hu:source:synthetic-wind-down-protocol-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-wind-down-page-2026-03-01'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-wind-down-page-history-section'})
SET l.selectorKind = 'SECTION', l.uri = src.canonicalUri, l.section = 'Version history', l.privacyClass = 'PUBLIC', l.createdAt = sn.createdAt
MERGE (src)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

UNWIND [
  {a: 'hu:assertion:synthetic-wind-down-edition-1', e: 'hu:protocol-edition:synthetic-evening-wind-down-e1', ru: 'hu:rel:fixture-ed1',
   vf: datetime('2025-09-01T00:00:00Z'), vfp: 'MONTH', vt: datetime('2026-02-01T00:00:00Z'), vtp: 'MONTH'},
  {a: 'hu:assertion:synthetic-wind-down-edition-2', e: 'hu:protocol-edition:synthetic-evening-wind-down-e2', ru: 'hu:rel:fixture-ed2',
   vf: datetime('2026-02-01T00:00:00Z'), vfp: 'MONTH', vt: null, vtp: null}
] AS row
MATCH (pr:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'}), (e:ProtocolEdition {uid: row.e}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-wind-down-page-history-section'})
MERGE (a:Assertion {uid: row.a})
SET a.predicate = 'HAS_PROTOCOL_EDITION', a.polarity = 'POSITIVE', a.status = 'ACCEPTED',
    a.validFrom = row.vf, a.validFromPrecision = row.vfp, a.validFromBasis = 'STATED_BY_SOURCE',
    a.validTo = row.vt, a.validToPrecision = row.vtp, a.validToBasis = CASE WHEN row.vt IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END,
    a.recordedAt = datetime('2026-03-01T12:10:00Z'), a.recordedTo = null, a.contentHash = 'sha256:fixture-' + row.a, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(pr)
MERGE (a)-[:HAS_OBJECT]->(e)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (pr)-[h:HAS_PROTOCOL_EDITION {relationshipUid: row.ru}]->(e)
SET h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
    h.validTo = a.validTo, h.validToPrecision = a.validToPrecision, h.validToBasis = a.validToBasis,
    h.recordedFrom = a.recordedAt, h.recordedTo = null, h.assertionUid = a.uid;

// 1.13 A source (not BellLabs) recommends a product: the live Person-[:RECOMMENDS]->Recommendable shape,
// kept as a source-attributed projection. It is NOT a BellLabs recommendation.
MERGE (host:Entity:Person {uid: 'hu:person:synthetic-podcast-host'})
SET host.name = 'Synthetic Podcast Host', host.privacyClass = 'PUBLIC', host.createdAt = datetime('2026-02-01T00:00:00Z');

MERGE (psrc:Entity:Source {uid: 'hu:source:synthetic-sleep-podcast-episode-12'})
SET psrc.canonicalUri = 'https://example.invalid/sleep-podcast/12', psrc.title = 'Synthetic sleep podcast, episode 12', psrc.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', psrc.privacyClass = 'PUBLIC', psrc.createdAt = datetime('2026-02-02T00:00:00Z');

MERGE (psn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-sleep-podcast-12-2026-02-02'})
SET psn.canonicalUri = 'https://example.invalid/sleep-podcast/12', psn.observedAt = datetime('2026-02-02T00:00:00Z'), psn.retrievedAt = datetime('2026-02-02T00:00:00Z'),
    psn.contentHash = 'sha256:1a0d2b7fcd10c7b79d6dcd3b0f4b6a40af186966282fb23c94d238d565027a56', psn.contentHashBasis = 'SYNTHETIC_FIXTURE', psn.captureCompleteness = 'UNKNOWN', psn.privacyClass = 'PUBLIC', psn.createdAt = datetime('2026-02-02T00:00:00Z');

MATCH (psrc:Source {uid: 'hu:source:synthetic-sleep-podcast-episode-12'}), (psn:SourceSnapshot {uid: 'hu:snapshot:synthetic-sleep-podcast-12-2026-02-02'})
MERGE (pl:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-sleep-podcast-12-nightcue-recommendation'})
SET pl.uri = psrc.canonicalUri, pl.selectorKind = 'TEXT_QUOTE', pl.exact = 'I recommend NightCue if you struggle to fall asleep.', pl.quoteHash = 'sha256:8a0442e31327681a96dbb43fcaed0de239533220427337c6402458d89fc24ecb', pl.normalizationVersion = 'NFC-WS1', pl.privacyClass = 'PUBLIC', pl.createdAt = psn.createdAt
MERGE (psrc)-[:HAS_SNAPSHOT]->(psn)
MERGE (psn)-[:HAS_LOCATOR]->(pl);

MATCH (host:Person {uid: 'hu:person:synthetic-podcast-host'}), (p:Product {uid: 'hu:product:synthetic-nightcue-melatonin'}), (pl:SourceLocator {uid: 'hu:locator:synthetic-sleep-podcast-12-nightcue-recommendation'})
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-host-recommends-nightcue'})
SET a.predicate = 'RECOMMENDS', a.speechAct = 'RECOMMENDS', a.assertionBasis = 'PERSONAL_EXPERIENCE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.validFrom = datetime('2026-02-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-02-02T00:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:fixture-host-recommends-nightcue'
MERGE (a)-[:HAS_SUBJECT]->(host)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:SUPPORTED_BY]->(pl);

MATCH (host:Person {uid: 'hu:person:synthetic-podcast-host'}), (p:Product {uid: 'hu:product:synthetic-nightcue-melatonin'})
MERGE (host)-[r:RECOMMENDS]->(p)
SET r.assertionUid = 'hu:assertion:synthetic-host-recommends-nightcue', r.validFrom = datetime('2026-02-01T00:00:00Z'),
    r.validFromPrecision = 'DAY', r.validFromBasis = 'STATED_BY_SOURCE', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-02-02T00:00:00Z'), r.relationshipUid = 'hu:rel:synthetic-host-recommends-nightcue';

// Intentionally absent (shared graph):
//   (:Product)-[:RECOMMENDED_FOR]->(:FunctionalGoal)          a recommendation is a private decision occurrence
//   (:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(:UserContext)
//   any relationship between a shared node and a :PrivateRecord node
//   an in-place edit of validTo on any Assertion or HAS_FORMULATION_VERSION edge

// =====================================================================================
// SECTION 2. PRIVATE CONTEXT STORE (rendered as :PrivateRecord for illustration only)
// =====================================================================================

MERGE (uc:PrivateRecord:Entity:UserContext {uid: 'hu:private-user-context:synthetic-0001'})
SET uc.privacyClass = 'private-personal', uc.createdAt = datetime('2026-04-09T18:00:00Z');

MERGE (gv:PrivateRecord:VersionedState:UserGoalVersion {uid: 'hu:private-user-goal-version:synthetic-0001-g1-v1'})
SET gv.functionalGoalUid = 'hu:functional-goal:shorter-sleep-onset', gv.priority = 1, gv.payloadHash = 'sha256:fixture-goal-v1',
    gv.recordedAt = datetime('2026-04-09T18:00:00Z'), gv.privacyClass = 'private-personal', gv.createdAt = datetime('2026-04-09T18:00:00Z');

MERGE (v1:PrivateRecord:VersionedState:UserContextVersion {uid: 'hu:private-user-context-version:synthetic-0001-v1'})
SET v1.goalVersionUids = ['hu:private-user-goal-version:synthetic-0001-g1-v1'], v1.measurementUids = [],
    v1.declaredConditionUids = [], v1.declaredIntakeUids = [], v1.preferenceKeys = ['NO_HORMONE_PRODUCTS'],
    v1.payloadHash = 'sha256:fixture-ucv1', v1.recordedAt = datetime('2026-04-09T18:00:00Z'),
    v1.privacyClass = 'private-personal', v1.createdAt = datetime('2026-04-09T18:00:00Z');

// Recommendation request and snapshot (insert-only)
MERGE (rq:PrivateRecord:Occurrence:RecommendationRequest {uid: 'hu:private-recommendation-request:synthetic-0001-r1'})
SET rq.occurrenceType = 'RECOMMENDATION_REQUEST', rq.requestedAt = datetime('2026-04-10T08:59:00Z'),
    rq.goalVersionUids = ['hu:private-user-goal-version:synthetic-0001-g1-v1'], rq.intendedUse = 'PURCHASE_DECISION_SUPPORT',
    rq.privacyClass = 'private-personal', rq.createdAt = datetime('2026-04-10T08:59:00Z');

MERGE (rs:PrivateRecord:Occurrence:RecommendationSnapshot {uid: 'hu:private-recommendation-snapshot:synthetic-0001-s1'})
SET rs.occurrenceType = 'RECOMMENDATION_DECISION',
    rs.decidedAt = datetime('2026-04-10T09:00:05Z'), rs.recordedAt = datetime('2026-04-10T09:00:06Z'),
    rs.userContextVersionUid = 'hu:private-user-context-version:synthetic-0001-v1',
    rs.evidenceRecordedAt = datetime('2026-04-10T09:00:00Z'), rs.evidenceValidAt = datetime('2026-04-10T09:00:00Z'),
    rs.policyVersionUid = 'hu:policy-version:sleep-support-ranking-v3', rs.algorithmVersion = 'ranker-2026.04.1',
    rs.catalogVersion = '0.2.0', rs.intendedUse = 'PURCHASE_DECISION_SUPPORT', rs.decisionOutcome = 'RECOMMENDED_ONE',
    rs.rationaleSummary = 'SleepWell selected: material matches studied material and declared dose is within the studied range; CalmRoot dose applicability unknown; NightCue excluded by stated preference.',
    rs.decisionConfidence = 0.55, rs.decisionConfidenceMethod = 'policy-v3-rank-stability-1',
    rs.missingFactKeys = ['BASELINE_SERUM_MAGNESIUM', 'CURRENT_INTAKE_NOT_DECLARED'],
    rs.snapshotHash = 'sha256:fixture-snapshot-s1', rs.privacyClass = 'private-personal', rs.createdAt = datetime('2026-04-10T09:00:06Z');

UNWIND [
  {uid: 'hu:private-recommendation-option:synthetic-0001-s1-a', subj: 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', disp: 'SELECTED', rank: 1, reason: null,
   ev: ['hu:assertion:synthetic-sleepwell-variant-fv-a1'], adj: ['hu:adjudication:synthetic-a1-accept'],
   app: ['hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'], st: ['hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded']},
  {uid: 'hu:private-recommendation-option:synthetic-0001-s1-b', subj: 'hu:product-variant:synthetic-calmroot-glycine-us-powder', disp: 'REJECTED', rank: 2, reason: 'INSUFFICIENT_APPLICABILITY',
   ev: ['hu:assertion:synthetic-calmroot-variant-fv-b1'], adj: ['hu:adjudication:synthetic-b1-accept'],
   app: ['hu:applicability:synthetic-glycine-evidence-to-calmroot-fv-b1'], st: ['hu:formulation:synthetic-calmroot-fv-b1']},
  {uid: 'hu:private-recommendation-option:synthetic-0001-s1-c', subj: 'hu:product-variant:synthetic-nightcue-melatonin-us-tablet', disp: 'REJECTED', rank: 3, reason: 'USER_PREFERENCE',
   ev: ['hu:assertion:synthetic-nightcue-variant-fv-c1'], adj: ['hu:adjudication:synthetic-c1-accept'],
   app: [], st: ['hu:formulation:synthetic-nightcue-fv-c1']}
] AS row
MATCH (rs:RecommendationSnapshot {uid: 'hu:private-recommendation-snapshot:synthetic-0001-s1'})
MERGE (o:PrivateRecord:InformationArtifact:RecommendationOption {uid: row.uid})
SET o.artifactType = 'RECOMMENDATION_OPTION', o.subjectUid = row.subj, o.subjectType = 'ProductVariant',
    o.disposition = row.disp, o.rank = row.rank, o.rejectionReason = row.reason,
    o.evidenceAssertionUids = row.ev, o.adjudicationUids = row.adj, o.applicabilityUids = row.app, o.stateUids = row.st,
    o.privacyClass = 'private-personal', o.createdAt = rs.recordedAt
MERGE (rs)-[:HAS_OPTION]->(o);

MATCH (rs:RecommendationSnapshot {uid: 'hu:private-recommendation-snapshot:synthetic-0001-s1'}),
      (rq:RecommendationRequest {uid: 'hu:private-recommendation-request:synthetic-0001-r1'}),
      (v1:UserContextVersion {uid: 'hu:private-user-context-version:synthetic-0001-v1'})
MERGE (rs)-[:FOR_REQUEST]->(rq)
MERGE (rs)-[:USED_CONTEXT_VERSION]->(v1);

// The person's own choice is a separate occurrence (BellLabs SELECTED != user CHOSE).
MERGE (ud:PrivateRecord:Occurrence:UserDecision {uid: 'hu:private-user-decision:synthetic-0001-d1'})
SET ud.occurrenceType = 'USER_DECISION', ud.decisionKind = 'CHOSE', ud.optionUid = 'hu:private-recommendation-option:synthetic-0001-s1-a',
    ud.decidedAt = datetime('2026-04-10T09:05:00Z'), ud.privacyClass = 'private-personal', ud.createdAt = datetime('2026-04-10T09:05:00Z');

MATCH (ud:UserDecision {uid: 'hu:private-user-decision:synthetic-0001-d1'}), (rs:RecommendationSnapshot {uid: 'hu:private-recommendation-snapshot:synthetic-0001-s1'})
MERGE (ud)-[:RESPONDS_TO]->(rs);

// Purchase lifecycle and what the person is waiting on
UNWIND [
  {uid: 'hu:private-purchase-event:synthetic-0001-p1', kind: 'ORDERED', at: datetime('2026-04-10T09:10:00Z')},
  {uid: 'hu:private-purchase-event:synthetic-0001-p2', kind: 'DELIVERED', at: datetime('2026-04-14T15:00:00Z')}
] AS row
MERGE (pe:PrivateRecord:Occurrence:PurchaseEvent {uid: row.uid})
SET pe.occurrenceType = 'PURCHASE_EVENT', pe.eventKind = row.kind, pe.occurredAt = row.at,
    pe.productVariantUid = 'hu:product-variant:synthetic-sleepwell-magnesium-us-capsule',
    pe.privacyClass = 'private-personal', pe.createdAt = row.at;

UNWIND [
  {uid: 'hu:private-pending-item:synthetic-0001-delivery', kind: 'AWAITING_DELIVERY', blocks: 'hu:private-user-decision:synthetic-0001-d1',
   opened: datetime('2026-04-10T09:10:00Z'), expected: datetime('2026-04-15T00:00:00Z'), resolved: datetime('2026-04-14T15:00:00Z'), by: 'hu:private-purchase-event:synthetic-0001-p2'},
  {uid: 'hu:private-pending-item:synthetic-0001-baseline-lab', kind: 'AWAITING_LAB_RESULT', blocks: 'hu:private-recommendation-snapshot:synthetic-0001-s1',
   opened: datetime('2026-04-10T09:00:06Z'), expected: null, resolved: datetime('2026-05-22T12:00:00Z'), by: 'hu:private-personal-measurement:synthetic-0001-m1'},
  {uid: 'hu:private-pending-item:synthetic-0001-evidence-review', kind: 'EVIDENCE_REVIEW', blocks: 'hu:private-recommendation-snapshot:synthetic-0001-s1',
   opened: datetime('2026-06-15T08:30:00Z'), expected: null, resolved: null, by: null}
] AS row
MERGE (pi:PrivateRecord:Occurrence:PendingItem {uid: row.uid})
SET pi.occurrenceType = 'PENDING_ITEM', pi.pendingKind = row.kind, pi.blocksUid = row.blocks, pi.openedAt = row.opened,
    pi.expectedBy = row.expected, pi.resolvedAt = row.resolved, pi.resolvedByUid = row.by,
    pi.privacyClass = 'private-personal', pi.createdAt = row.opened;

// LATER: a personal measurement arrives. It creates a new context version; the snapshot is not touched.
MERGE (pm:PrivateRecord:InformationArtifact:PersonalMeasurement {uid: 'hu:private-personal-measurement:synthetic-0001-m1'})
SET pm.artifactType = 'PERSONAL_MEASUREMENT', pm.metricUid = 'hu:metric:serum-magnesium-mass-concentration',
    pm.valueNumber = 2.1, pm.unitCode = 'mg/dL', pm.resultQualifier = 'NUMERIC',
    pm.effectiveAt = datetime('2026-05-20T08:00:00Z'), pm.recordedAt = datetime('2026-05-22T12:00:00Z'),
    pm.provenanceKind = 'LAB_REPORT_UPLOAD', pm.privacyClass = 'private-personal', pm.createdAt = datetime('2026-05-22T12:00:00Z');

MERGE (v2:PrivateRecord:VersionedState:UserContextVersion {uid: 'hu:private-user-context-version:synthetic-0001-v2'})
SET v2.goalVersionUids = ['hu:private-user-goal-version:synthetic-0001-g1-v1'], v2.measurementUids = ['hu:private-personal-measurement:synthetic-0001-m1'],
    v2.declaredConditionUids = [], v2.declaredIntakeUids = [], v2.preferenceKeys = ['NO_HORMONE_PRODUCTS'],
    v2.payloadHash = 'sha256:fixture-ucv2', v2.recordedAt = datetime('2026-05-22T12:00:00Z'),
    v2.privacyClass = 'private-personal', v2.createdAt = datetime('2026-05-22T12:00:00Z');

// Context-version episodes follow the round 0007 profile (EXCLUSIVE per UserContext).
UNWIND [
  {ru: 'hu:private-rel:fixture-ctx-v1', v: 'hu:private-user-context-version:synthetic-0001-v1', vf: datetime('2026-04-09T18:00:00Z'), vt: null,
   rf: datetime('2026-04-09T18:00:00Z'), rt: datetime('2026-05-22T12:00:00Z')},
  {ru: 'hu:private-rel:fixture-ctx-v1-bounded', v: 'hu:private-user-context-version:synthetic-0001-v1', vf: datetime('2026-04-09T18:00:00Z'), vt: datetime('2026-05-22T12:00:00Z'),
   rf: datetime('2026-05-22T12:00:00Z'), rt: null},
  {ru: 'hu:private-rel:fixture-ctx-v2', v: 'hu:private-user-context-version:synthetic-0001-v2', vf: datetime('2026-05-22T12:00:00Z'), vt: null,
   rf: datetime('2026-05-22T12:00:00Z'), rt: null}
] AS row
MATCH (uc:UserContext {uid: 'hu:private-user-context:synthetic-0001'}), (cv:UserContextVersion {uid: row.v})
MERGE (uc)-[h:HAS_CONTEXT_VERSION {relationshipUid: row.ru}]->(cv)
SET h.validFrom = row.vf, h.validFromPrecision = 'INSTANT', h.validFromBasis = 'STATED_BY_SOURCE',
    h.validTo = row.vt, h.validToPrecision = CASE WHEN row.vt IS NULL THEN null ELSE 'INSTANT' END,
    h.validToBasis = CASE WHEN row.vt IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END,
    h.recordedFrom = row.rf, h.recordedTo = row.rt;

// Sharing grant: who may see what, for what purpose, for how long (episode validity).
MERGE (sg:PrivateRecord:VersionedState:SharingGrant {uid: 'hu:private-sharing-grant:synthetic-0001-coach'})
SET sg.granteeKind = 'COACH', sg.granteeRef = 'pcs-grantee:synthetic-coach-01',
    sg.dataCategories = ['RECOMMENDATION_SNAPSHOTS', 'PROTOCOL_IN_USE'], sg.purpose = 'COACHING_REVIEW',
    sg.permittedActions = ['VIEW'], sg.decision = 'PERMIT', sg.payloadHash = 'sha256:fixture-grant-1',
    sg.privacyClass = 'private-personal', sg.createdAt = datetime('2026-04-12T10:00:00Z');

MATCH (uc:UserContext {uid: 'hu:private-user-context:synthetic-0001'}), (sg:SharingGrant {uid: 'hu:private-sharing-grant:synthetic-0001-coach'})
MERGE (uc)-[h:HAS_SHARING_GRANT {relationshipUid: 'hu:private-rel:fixture-grant-1'}]->(sg)
SET h.validFrom = datetime('2026-04-12T10:00:00Z'), h.validFromPrecision = 'INSTANT', h.validFromBasis = 'STATED_BY_SOURCE',
    h.validTo = datetime('2026-07-12T10:00:00Z'), h.validToPrecision = 'INSTANT', h.validToBasis = 'STATED_BY_SOURCE',
    h.recordedFrom = datetime('2026-04-12T10:00:00Z'), h.recordedTo = null;

MERGE (de:PrivateRecord:Occurrence:DisclosureEvent {uid: 'hu:private-disclosure:synthetic-0001-coach-1'})
SET de.occurrenceType = 'DISCLOSURE', de.grantUid = 'hu:private-sharing-grant:synthetic-0001-coach', de.occurredAt = datetime('2026-04-20T16:00:00Z'),
    de.dataCategories = ['RECOMMENDATION_SNAPSHOTS'], de.privacyClass = 'private-personal', de.createdAt = datetime('2026-04-20T16:00:00Z');

// Protocol in use: adoption of public edition 2 with one deviation.
MERGE (piu:PrivateRecord:Entity:ProtocolInUse {uid: 'hu:private-protocol-in-use:synthetic-0001-wind-down'})
SET piu.privacyClass = 'private-personal', piu.createdAt = datetime('2026-04-15T20:00:00Z');

MERGE (av:PrivateRecord:VersionedState:ProtocolAdoptionVersion {uid: 'hu:private-protocol-adoption-version:synthetic-0001-wind-down-v1'})
SET av.adoptedEditionUid = 'hu:protocol-edition:synthetic-evening-wind-down-e2',
    av.deviationStepKeys = ['fixed-bedtime'], av.deviationKinds = ['MODIFIED_TIMING'],
    av.payloadHash = 'sha256:fixture-adoption-v1', av.privacyClass = 'private-personal', av.createdAt = datetime('2026-04-15T20:00:00Z');

MATCH (piu:ProtocolInUse {uid: 'hu:private-protocol-in-use:synthetic-0001-wind-down'}), (av:ProtocolAdoptionVersion {uid: 'hu:private-protocol-adoption-version:synthetic-0001-wind-down-v1'})
MERGE (piu)-[h:HAS_ADOPTION_VERSION {relationshipUid: 'hu:private-rel:fixture-adoption-v1'}]->(av)
SET h.validFrom = datetime('2026-04-15T20:00:00Z'), h.validFromPrecision = 'DAY', h.validFromBasis = 'STATED_BY_SOURCE',
    h.validTo = null, h.validToBasis = 'UNKNOWN', h.recordedFrom = datetime('2026-04-15T20:00:00Z'), h.recordedTo = null;

MATCH (uc:UserContext {uid: 'hu:private-user-context:synthetic-0001'}), (piu:ProtocolInUse {uid: 'hu:private-protocol-in-use:synthetic-0001-wind-down'})
MERGE (uc)-[:HAS_PROTOCOL_IN_USE]->(piu);

// Intentionally absent (private side):
//   any edge from a :PrivateRecord node to a shared node (crossings are uid properties)
//   any update of the RecommendationSnapshot or its options after 2026-04-10T09:00:06Z
//   PersonalMeasurement modeled as :Observation

// =====================================================================================
// SECTION 3. QUERIES AND VALIDATION (validation queries return zero rows when the fixture is intact)
// =====================================================================================

// Q-1 (CQ-RC-04, CQ-TM-01): replay the snapshot's evidence as BellLabs held it at the decision viewpoint.
// Expected: the 200 mg first-recorded state for SleepWell (fv-a1) even though it was corrected on 2026-06-15,
// and no 2019 state (recorded only on 2026-08-01).
// status: statically-checked
MATCH (rs:RecommendationSnapshot {uid: 'hu:private-recommendation-snapshot:synthetic-0001-s1'})-[:HAS_OPTION]->(o:RecommendationOption)
MATCH (v:ProductVariant {uid: o.subjectUid})-[h:HAS_FORMULATION_VERSION]->(fv:FormulationVersion)
WHERE h.recordedFrom <= rs.evidenceRecordedAt AND (h.recordedTo IS NULL OR h.recordedTo > rs.evidenceRecordedAt)
  AND (h.validFrom IS NULL OR h.validFrom <= rs.evidenceValidAt)
  AND (h.validTo IS NULL OR h.validTo > rs.evidenceValidAt)
RETURN o.disposition AS disposition, v.uid AS variantUid, fv.uid AS formulationHeldAtDecision, h.assertionUid AS authorizedBy
ORDER BY o.rank;

// Q-2 (CQ-TM-07): same valid instant, current recorded viewpoint. SleepWell returns the corrected state (fv-a1c);
// CalmRoot still returns fv-b1 for 2026-04-10 because its formulation ended later, it was not corrected.
// status: statically-checked
WITH datetime('2026-10-03T00:00:00Z') AS R, datetime('2026-04-10T09:00:00Z') AS V
MATCH (v:ProductVariant)-[h:HAS_FORMULATION_VERSION]->(fv:FormulationVersion)
WHERE v.uid IN ['hu:product-variant:synthetic-sleepwell-magnesium-us-capsule', 'hu:product-variant:synthetic-calmroot-glycine-us-powder']
  AND h.recordedFrom <= R AND (h.recordedTo IS NULL OR h.recordedTo > R)
  AND (h.validFrom IS NULL OR h.validFrom <= V) AND (h.validTo IS NULL OR h.validTo > V)
RETURN v.uid AS variantUid, fv.uid AS formulationHeldNowForV, h.assertionUid AS authorizedBy;

// Q-3 (CQ-RC-07): snapshots whose evidence was superseded after the decision viewpoint (open re-review items).
// status: statically-checked
MATCH (rs:RecommendationSnapshot)-[:HAS_OPTION]->(o:RecommendationOption)
UNWIND o.evidenceAssertionUids AS aUid
MATCH (a:Assertion {uid: aUid})<-[s:SUPERSEDES]-(newer:Assertion)
WHERE s.recordedAt > rs.evidenceRecordedAt
RETURN rs.uid AS snapshotUid, o.disposition AS disposition, aUid AS supersededEvidence, newer.uid AS supersededBy,
       s.supersessionKind AS supersessionKind, s.recordedAt AS learnedAt;

// Q-4 (CQ-PR-01): step differences between protocol editions 1 and 2.
// Expected: added baseline-serum-magnesium; removed screen-free-hour; modified magnesium-evening; unchanged fixed-bedtime.
// status: statically-checked
MATCH (old:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}), (new:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e2'})
OPTIONAL MATCH (old)-[:HAS_STEP]->(os:ProtocolStep)
WITH old, new, collect(os) AS oldSteps
OPTIONAL MATCH (new)-[:HAS_STEP]->(ns:ProtocolStep)
WITH oldSteps, collect(ns) AS newSteps
WITH oldSteps, newSteps, [s IN oldSteps | s.stepKey] AS oldKeys, [s IN newSteps | s.stepKey] AS newKeys
RETURN [s IN newSteps WHERE NOT s.stepKey IN oldKeys | s.stepKey] AS addedSteps,
       [s IN oldSteps WHERE NOT s.stepKey IN newKeys | s.stepKey] AS removedSteps,
       [n IN newSteps WHERE any(o IN oldSteps WHERE o.stepKey = n.stepKey AND o.payloadHash <> n.payloadHash) | n.stepKey] AS modifiedSteps,
       [n IN newSteps WHERE any(o IN oldSteps WHERE o.stepKey = n.stepKey AND o.payloadHash = n.payloadHash) | n.stepKey] AS unchangedSteps;

// F-V1: snapshot mutated. Returns rows if an option was added after commit, if any snapshot input was recorded
// after the snapshot (a later measurement or context version leaked into it), or if evidence newer than the
// viewpoint was attached.
// status: statically-checked
MATCH (rs:RecommendationSnapshot)
OPTIONAL MATCH (rs)-[:HAS_OPTION]->(o:RecommendationOption)
WITH rs, collect(o) AS opts
OPTIONAL MATCH (cv:UserContextVersion {uid: rs.userContextVersionUid})
WITH rs, opts, cv,
     [o IN opts WHERE o.createdAt > rs.recordedAt | o.uid] AS lateOptions
OPTIONAL MATCH (pm:PersonalMeasurement)
WHERE cv IS NOT NULL AND pm.uid IN cv.measurementUids AND pm.recordedAt > rs.recordedAt
WITH rs, opts, cv, lateOptions, collect(pm.uid) AS lateMeasurements
UNWIND (CASE WHEN size(opts) = 0 THEN [null] ELSE opts END) AS o
OPTIONAL MATCH (a:Assertion)
WHERE o IS NOT NULL AND a.uid IN o.evidenceAssertionUids AND a.recordedAt > rs.evidenceRecordedAt
WITH rs, cv, lateOptions, lateMeasurements, collect(a.uid) AS lateEvidence
WHERE cv IS NULL OR cv.recordedAt > rs.recordedAt OR size(lateOptions) > 0 OR size(lateMeasurements) > 0
   OR size(lateEvidence) > 0 OR rs.updatedAt IS NOT NULL
RETURN rs.uid AS mutatedSnapshot, cv.uid AS contextVersion, lateOptions, lateMeasurements, lateEvidence;

// F-V2: replay broken. Returns rows if a state recorded in a snapshot option cannot be reproduced by the
// as-of query at the snapshot's viewpoint (for example because an episode edge was edited or deleted).
// status: statically-checked
MATCH (rs:RecommendationSnapshot)-[:HAS_OPTION]->(o:RecommendationOption)
UNWIND o.stateUids AS stateUid
OPTIONAL MATCH (v {uid: o.subjectUid})-[h:HAS_FORMULATION_VERSION]->(fv:FormulationVersion {uid: stateUid})
WHERE h.recordedFrom <= rs.evidenceRecordedAt AND (h.recordedTo IS NULL OR h.recordedTo > rs.evidenceRecordedAt)
  AND (h.validFrom IS NULL OR h.validFrom <= rs.evidenceValidAt) AND (h.validTo IS NULL OR h.validTo > rs.evidenceValidAt)
WITH rs, o, stateUid, count(h) AS reproducing
WHERE reproducing = 0
RETURN rs.uid AS snapshotUid, o.uid AS optionUid, stateUid AS unreproducibleState;

// F-V3: a correction changed valid time. Returns rows if any attachment edge disagrees with the valid time of the
// assertion that authorizes it (the edges keep the belief as recorded; an in-place edit of either side shows up),
// or if a VALIDITY_BOUNDED supersession changed the start or the object instead of only bounding the end.
// status: statically-checked
MATCH ()-[h:HAS_FORMULATION_VERSION|HAS_PROTOCOL_EDITION]->()
MATCH (a:Assertion {uid: h.assertionUid})
WHERE coalesce(toString(h.validFrom), '-') <> coalesce(toString(a.validFrom), '-')
   OR coalesce(toString(h.validTo), '-') <> coalesce(toString(a.validTo), '-')
   OR coalesce(h.validFromPrecision, '-') <> coalesce(a.validFromPrecision, '-')
   OR coalesce(h.validToPrecision, '-') <> coalesce(a.validToPrecision, '-')
RETURN 'EDGE_ASSERTION_VALID_TIME_MISMATCH' AS violation, h.relationshipUid AS edge, a.uid AS assertionUid
UNION
MATCH (newer:Assertion)-[s:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED'}]->(older:Assertion)
MATCH (newer)-[:HAS_OBJECT]->(newObj), (older)-[:HAS_OBJECT]->(oldObj)
WHERE newObj <> oldObj OR coalesce(toString(newer.validFrom), '-') <> coalesce(toString(older.validFrom), '-')
   OR older.validTo IS NOT NULL OR newer.validTo IS NULL
RETURN 'VALIDITY_BOUNDED_CHANGED_MORE_THAN_END' AS violation, toString(s.recordedAt) AS edge, older.uid AS assertionUid;

// F-V4: superseded assertions must be closed exactly when the superseding assertion was recorded.
// status: statically-checked
MATCH (newer:Assertion)-[s:SUPERSEDES]->(older:Assertion)
WHERE older.recordedTo IS NULL OR older.recordedTo <> s.recordedAt OR newer.recordedAt <> s.recordedAt
   OR newer.recordedAt < older.recordedAt
RETURN older.uid AS supersededAssertion, older.recordedTo, s.recordedAt, newer.recordedAt;

// F-V5: no backdating. Edges cannot be recorded before their assertion; assertions cannot be recorded before the
// snapshot that supports them was retrieved (the 2019 archive capture is recorded in 2026, not 2019).
// status: statically-checked
MATCH ()-[h:HAS_FORMULATION_VERSION|HAS_PROTOCOL_EDITION]->()
MATCH (a:Assertion {uid: h.assertionUid})
WHERE h.recordedFrom < a.recordedAt
RETURN 'EDGE_RECORDED_BEFORE_ASSERTION' AS violation, h.relationshipUid AS item
UNION
MATCH (a:Assertion)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE a.recordedAt < sn.retrievedAt
RETURN 'ASSERTION_RECORDED_BEFORE_RETRIEVAL' AS violation, a.uid AS item;

// F-V6: private node reachable from a public node. Any relationship touching both a :PrivateRecord node and a
// non-private node is a leak; so is any path of up to 4 hops from a shared node into private records.
// status: statically-checked
MATCH (pub)-[r]-(priv:PrivateRecord)
WHERE NOT pub:PrivateRecord
RETURN 'DIRECT_EDGE' AS leak, pub.uid AS sharedNode, type(r) AS relType, priv.uid AS privateNode
UNION
MATCH path = (pub)-[*1..4]-(priv:PrivateRecord)
WHERE NOT pub:PrivateRecord
RETURN 'REACHABLE_PATH' AS leak, pub.uid AS sharedNode, 'PATH' AS relType, priv.uid AS privateNode;

// F-V7: private-class data stored on shared nodes (a uid or privacyClass value that belongs in the PCS).
// status: statically-checked
MATCH (n)
WHERE NOT n:PrivateRecord
  AND (n.privacyClass = 'private-personal'
       OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-'))
RETURN n.uid AS sharedNodeHoldingPrivateData;

// F-V8: intentionally absent shapes.
// status: statically-checked
MATCH (p)-[r:RECOMMENDED_FOR]->(g)
RETURN 'RECOMMENDED_FOR_EDGE' AS forbidden, p.uid AS fromUid, g.uid AS toUid
UNION
MATCH (ea:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(u:UserContext)
RETURN 'APPLICABILITY_TO_USER_CONTEXT' AS forbidden, ea.uid AS fromUid, u.uid AS toUid
UNION
MATCH (x:Observation:PersonalMeasurement)
RETURN 'OBSERVATION_PERSONAL_MEASUREMENT_COLLAPSE' AS forbidden, x.uid AS fromUid, null AS toUid
UNION
MATCH (src:Person)-[r:RECOMMENDS]->(t)
WHERE r.assertionUid IS NULL
RETURN 'SOURCE_RECOMMENDS_WITHOUT_ASSERTION' AS forbidden, src.uid AS fromUid, t.uid AS toUid;

// F-V9: DEFINITE overlap of mutually exclusive attachments (round 0007 section 10), evaluated on
// HAS_FORMULATION_VERSION per variant and jurisdiction, HAS_PROTOCOL_EDITION per protocol, and
// HAS_CONTEXT_VERSION per user context. Bounds are shrunk by their precision before comparison.
// status: statically-checked
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_PROTOCOL_EDITION|HAS_CONTEXT_VERSION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_PROTOCOL_EDITION|HAS_CONTEXT_VERSION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
     r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
     r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN 'DEFINITE_EXCLUSIVE_OVERLAP' AS violation, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// F-V10: disclosures must fall inside a currently recorded grant episode that permits them.
// status: statically-checked
MATCH (de:DisclosureEvent)
OPTIONAL MATCH (:UserContext)-[h:HAS_SHARING_GRANT]->(sg:SharingGrant {uid: de.grantUid})
WHERE h.recordedTo IS NULL AND sg.decision = 'PERMIT'
  AND (h.validFrom IS NULL OR h.validFrom <= de.occurredAt) AND h.validTo IS NOT NULL AND h.validTo > de.occurredAt
  AND all(c IN de.dataCategories WHERE c IN sg.dataCategories)
WITH de, count(h) AS covering
WHERE covering = 0
RETURN de.uid AS disclosureOutsideGrant;

// F-V11: snapshot shape. At most one SELECTED option for RECOMMENDED_ONE; every REJECTED option has a reason;
// every BLOCKED option names a blocking constraint.
// status: statically-checked
MATCH (rs:RecommendationSnapshot)-[:HAS_OPTION]->(o:RecommendationOption)
WITH rs, collect(o) AS opts
WHERE (rs.decisionOutcome = 'RECOMMENDED_ONE' AND size([o IN opts WHERE o.disposition = 'SELECTED']) <> 1)
   OR any(o IN opts WHERE o.disposition = 'REJECTED' AND o.rejectionReason IS NULL)
   OR any(o IN opts WHERE o.disposition = 'BLOCKED' AND coalesce(size(o.blockingConstraintUids), 0) = 0)
RETURN rs.uid AS malformedSnapshot;

// F-V12 (illustrative, requires APOC): content hash check. Returns rows if an assertion's immutable content no
// longer matches the hash written at commit. The fixture stores placeholder hashes, so this query is
// illustrative only and is expected to return rows against this fixture.
// status: illustrative
// Requires APOC (apoc.util.sha256), which the embedded test instance does not ship; kept as a commented illustrative check.
// MATCH (a:Assertion)-[:HAS_SUBJECT]->(s)
// OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
// WITH a, apoc.util.sha256([a.predicate, a.polarity, s.uid, coalesce(o.uid, ''), toString(a.valueNumber), a.valueString,
//                           toString(a.validFrom), a.validFromPrecision, a.validFromBasis,
//                           toString(a.validTo), a.validToPrecision, a.validToBasis]) AS recomputed
// WHERE 'sha256:' + recomputed <> a.contentHash
// RETURN a.uid AS assertionWithChangedContent;

// ---------------------------------------------------------------------------
// Capture-fidelity acceptance (catalog 0.2.0, INV-103). Every ACCEPTED, REJECTED or DISPUTED status is a projection of a
// CAPTURE_FIDELITY adjudication. This fixture records one policy adjudication (reviewerType POLICY) covering the captured
// assertions it created; it says nothing about whether any proposition is true (that is a SUPPORT adjudication).
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:recommendation-snapshot-capture-fidelity-policy-2026-10-04'})
ON CREATE SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1', j.status = 'FINAL',
    j.rationale = 'Fixture capture policy: the recorded propositions match the cited spans as read by the authoring lane.',
    j.reviewedAt = datetime('2026-10-04T00:00:00Z'), j.recordedAt = datetime('2026-10-04T00:00:00Z'), j.createdAt = datetime('2026-10-04T00:00:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
