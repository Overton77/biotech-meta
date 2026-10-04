// W04 fixture 04 -- Basis label history (current vs historical formulation, QS-2b), dated re-capture and selector choice, and a trial that
// names the brand without a recoverable historical label (CQ-ID-01, CQ-ID-02 qualified answer, CQ-ID-05).
// Public records (NEW_RETRIEVAL 2026-10-04 through Firecrawl; direct fetch of elysiumhealth.com was BLOCKED by the egress proxy):
//   Wayback CDX for https://www.elysiumhealth.com/pages/basis-supplement-facts lists 22 distinct captures, first 2021-12-08 12:03:25Z.
//   Captures read: 2021-12-08, 2023-03-16, 2025-09-10 ("NR-E (Pa[n]tent-Pending Crystalline Nicotinamide Riboside) 250 mg"),
//   2026-03-05, 2026-07-17 ("Elysium NR (Nicotinamide Riboside Chloride) 250 mg"); PT (Pterostilbene) 50mg and "Serving Size: 2 Vegetarian
//   Capsules, Servings: 30" unchanged in all five. 2021 capture misspells "Pantent"; 2023 reads "Patent" (silent change, not an erratum).
//   Archived brand page http://www.elysiumhealth.com/basis captured 2016-03-20 09:18:08Z names NR and pterostilbene without amounts.
//   ClinicalTrials.gov NCT02678611 (MCP, 2026-10-04): interventions "Basis 250", "Basis 500", "Placebo"; start 2016-01; primary completion 2016-07.
// Snapshot hashes are STORED_EXCERPT_TEXT over the Supplement Facts row excerpt (03-source-manifest.md), not raw archive bytes.
// Shares uids with ../../../../../../examples/elysium-basis.cypher (product, variant, label Source, current FV and its components) and with
// study-vs-product-mismatch.cypher (study, study intervention); only properties absent there are SET, so either load order works.

MERGE (basis:Product:Entity {uid: 'hu:product:elysium-basis'})
ON CREATE SET basis.name = 'Basis', basis.productKind = 'DIETARY_SUPPLEMENT', basis.createdAt = datetime('2026-10-04T01:10:00Z')
SET basis.entityType = 'Product', basis.privacyClass = 'PUBLIC';

MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:basis-us-capsule-standard'})
ON CREATE SET v.name = 'Basis — US capsules', v.jurisdiction = 'US', v.dosageForm = 'CAPSULE', v.createdAt = datetime('2026-10-04T01:10:00Z')
SET v.entityType = 'ProductVariant', v.privacyClass = 'PUBLIC';

MERGE (nrE:IngredientMaterial:Entity {uid: 'hu:material:elysium-nr-e'})
ON CREATE SET nrE.name = 'Elysium NR-E', nrE.brandName = 'NR-E', nrE.createdAt = datetime('2026-10-04T01:10:00Z')
SET nrE.entityType = 'IngredientMaterial', nrE.privacyClass = 'PUBLIC';

MERGE (pt:IngredientMaterial:Entity {uid: 'hu:material:pterostilbene-unspecified-current-basis'})
ON CREATE SET pt.name = 'PT (Pterostilbene) — current Basis material unresolved', pt.createdAt = datetime('2026-10-04T01:10:00Z')
SET pt.entityType = 'IngredientMaterial', pt.privacyClass = 'PUBLIC';

MERGE (sd:ServingDefinition:VersionedState {uid: 'hu:serving-definition:basis-2-vegetarian-capsules'})
SET sd.stateType = 'ServingDefinition', sd.servingCount = 2.0, sd.unitDescription = 'Vegetarian Capsules', sd.servingsPerContainer = null,
    sd.payloadHash = 'sha256:612499a01e47afaf7b9eca9c257411dd070902de6c589c58abf4448a61f37a34', sd.privacyClass = 'PUBLIC', sd.createdAt = datetime('2026-10-04T01:10:00Z');

MERGE (sdl:ServingDefinition:VersionedState {uid: 'hu:serving-definition:basis-label-2-capsules-30-servings'})
SET sdl.stateType = 'ServingDefinition', sdl.servingCount = 2.0, sdl.unitDescription = 'Vegetarian Capsules', sdl.servingsPerContainer = 30.0,
    sdl.servingStatementVerbatim = 'Serving Size: 2 Vegetarian Capsules, Servings: 30',
    sdl.payloadHash = 'sha256:3d9b403be3e1a0328d4fb3b0ccb958b19c15036a080bb90bf278f77ef0142789', sdl.privacyClass = 'PUBLIC', sdl.createdAt = datetime('2026-10-04T01:10:00Z');

MERGE (pc:PackageConfiguration:VersionedState {uid: 'hu:package-configuration:basis-60-capsule-bottle'})
SET pc.stateType = 'PackageConfiguration', pc.packageForm = 'BOTTLE', pc.unitCount = 60, pc.unitDescription = 'vegetarian capsules (derived: 2 per serving x 30 servings)',
    pc.payloadHash = 'sha256:d493759165713e4acfc8e54ad69f6f2337b1b0f0cdbf0c4d097b3cd02ee86081', pc.privacyClass = 'PUBLIC', pc.createdAt = datetime('2026-10-04T01:10:00Z');

// ---- two "as declared" formulation versions for the same variant ----
// FV-a (2021-12-08 .. 2025-09-10 captures): material named "NR-E (Patent-Pending Crystalline Nicotinamide Riboside)"; salt not stated -> MATERIAL_AS_IS.
// FV-b (2026-03-05 .. 2026-07-17 captures): "Elysium NR (Nicotinamide Riboside Chloride)" -> SALT_FORM. Reuses elysium-basis.cypher's current FV uid.
MERGE (fa:FormulationVersion:VersionedState {uid: 'hu:formulation:basis-us-declared-nr-e-crystalline'})
SET fa.stateType = 'FormulationVersion', fa.versionName = 'Basis US as declared 2021-12-08 to 2025-09-10 captures (NR-E crystalline NR)', fa.jurisdiction = 'US',
    fa.payloadHash = 'sha256:1f8cbf2c7dba8915ea2dfd5c4311d3d2cc4fe7d2b8beb5a9444b21b583a6d749',
    fa.privacyClass = 'PUBLIC', fa.createdAt = datetime('2026-10-04T01:10:00Z');

MERGE (fb:FormulationVersion:VersionedState {uid: 'hu:formulation:basis-us-current-2026-07-10'})
ON CREATE SET fb.versionName = 'Basis current US label observed 2026-07-10', fb.jurisdiction = 'US', fb.createdAt = datetime('2026-10-04T01:10:00Z')
SET fb.stateType = 'FormulationVersion', fb.privacyClass = 'PUBLIC',
    fb.payloadHash = 'sha256:dfeaa66c9d70d9f855fd48c91a0faa27bc397667a8a54436bb836fe72e16c0f1';

UNWIND [
  {c: 'hu:component:basis-2021-nr-e', fv: 'hu:formulation:basis-us-declared-nr-e-crystalline', o: 1, q: 250.0, mb: 'MATERIAL_AS_IS', d: 'NR-E (Patent-Pending Crystalline Nicotinamide Riboside)', m: 'hu:material:elysium-nr-e', cph: 'sha256:1ee1f897eef84fd7f5e643702bf7357e6c187c2df982e83c1007f18645413d65'},
  {c: 'hu:component:basis-2021-pt', fv: 'hu:formulation:basis-us-declared-nr-e-crystalline', o: 2, q: 50.0, mb: 'MATERIAL_AS_IS', d: 'PT (Pterostilbene)', m: 'hu:material:pterostilbene-unspecified-current-basis', cph: 'sha256:89a75a6a776b3e52d296dcf7c365866240d8760ae9fe8d6250ac5db3ffce4dde'},
  {c: 'hu:component:basis-current-nr-e', fv: 'hu:formulation:basis-us-current-2026-07-10', o: 1, q: 250.0, mb: 'SALT_FORM', d: 'Elysium NR (Nicotinamide Riboside Chloride)', m: 'hu:material:elysium-nr-e', cph: 'sha256:42dcd8e1fb3e8ae3d289eb157191842689f79477e0fcd2bef585226b33382d14'},
  {c: 'hu:component:basis-current-pt', fv: 'hu:formulation:basis-us-current-2026-07-10', o: 2, q: 50.0, mb: 'MATERIAL_AS_IS', d: 'PT (Pterostilbene)', m: 'hu:material:pterostilbene-unspecified-current-basis', cph: 'sha256:89a75a6a776b3e52d296dcf7c365866240d8760ae9fe8d6250ac5db3ffce4dde'}
] AS r
MATCH (fv:FormulationVersion {uid: r.fv}), (sd:ServingDefinition {uid: 'hu:serving-definition:basis-2-vegetarian-capsules'})
MERGE (c:IngredientComponent:VersionedState {uid: r.c})
ON CREATE SET c.role = 'DIETARY_INGREDIENT', c.labelOrder = r.o, c.quantity = r.q, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING', c.declaredAs = r.d, c.createdAt = datetime('2026-10-04T01:10:00Z')
SET c.stateType = 'IngredientComponent', c.massBasis = r.mb, c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', c.isDietaryIngredient = true,
    c.payloadHash = r.cph, c.privacyClass = 'PUBLIC'
MERGE (fv)-[hc:HAS_INGREDIENT_COMPONENT]->(c) SET hc.orderIndex = r.o
MERGE (fv)-[us:USES_SERVING_DEFINITION]->(sd) SET us.orderIndex = 1;

// ---- label Source and five archived LabelSnapshots ----
MERGE (s:Source:Entity {uid: 'hu:source:elysium-basis-supplement-facts'})
ON CREATE SET s.canonicalUri = 'https://www.elysiumhealth.com/pages/basis-supplement-facts', s.title = 'Basis Supplement Facts', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.createdAt = datetime('2026-10-04T01:10:00Z')
SET s.entityType = 'Source', s.privacyClass = 'PUBLIC';

UNWIND [
  {sn: 'hu:snapshot:elysium-basis-sf-wayback-20211208120325', obs: '2021-12-08T12:03:25Z', ret: '2026-10-04T00:49:00Z', ts: '20211208120325',
   nr: 'NR-E (Pantent-Pending Crystalline Nicotinamide Riboside) 250 mg', qh: 'sha256:8738d3c2146488bb9fe1df55973250bed74ad2e0095f6619435fa67980d9ff46', h: 'sha256:595ee543625f380ab86f7be1fcd55429dc55b73a6d22bfa2cc1b1d52dc2e3dc8'},
  {sn: 'hu:snapshot:elysium-basis-sf-wayback-20230316043858', obs: '2023-03-16T04:38:58Z', ret: '2026-10-04T00:51:00Z', ts: '20230316043858',
   nr: 'NR-E (Patent-Pending Crystalline Nicotinamide Riboside) 250 mg', qh: 'sha256:b80d4edd6d9421146c61e328a12a087b7b02b0810ad37a6362a631a587cbf605', h: 'sha256:d512b0c2c2868adec7dfe677764df5ffa19550af5d452f9b9de4861050f8aa0a'},
  {sn: 'hu:snapshot:elysium-basis-sf-wayback-20250910231157', obs: '2025-09-10T23:11:57Z', ret: '2026-10-04T00:52:00Z', ts: '20250910231157',
   nr: 'NR-E (Patent-Pending Crystalline Nicotinamide Riboside) 250 mg', qh: 'sha256:b80d4edd6d9421146c61e328a12a087b7b02b0810ad37a6362a631a587cbf605', h: 'sha256:d512b0c2c2868adec7dfe677764df5ffa19550af5d452f9b9de4861050f8aa0a'},
  {sn: 'hu:snapshot:elysium-basis-sf-wayback-20260305072454', obs: '2026-03-05T07:24:54Z', ret: '2026-10-04T00:52:30Z', ts: '20260305072454',
   nr: 'Elysium NR (Nicotinamide Riboside Chloride) 250 mg', qh: 'sha256:d8db7bad0231d525caa1b25cdceb12d80262ec95021a0d2baf0e8aa29ff43e8e', h: 'sha256:208cf6a869f45b54cd5e13c524b57bccf99f6d3a8828ac4441ba6e57eb24657d'},
  {sn: 'hu:snapshot:elysium-basis-sf-wayback-20260717140606', obs: '2026-07-17T14:06:06Z', ret: '2026-10-04T00:50:00Z', ts: '20260717140606',
   nr: 'Elysium NR (Nicotinamide Riboside Chloride) 250 mg', qh: 'sha256:d8db7bad0231d525caa1b25cdceb12d80262ec95021a0d2baf0e8aa29ff43e8e', h: 'sha256:208cf6a869f45b54cd5e13c524b57bccf99f6d3a8828ac4441ba6e57eb24657d'}
] AS r
MATCH (s:Source {uid: 'hu:source:elysium-basis-supplement-facts'})
MERGE (sn:LabelSnapshot:SourceSnapshot:InformationArtifact {uid: r.sn})
SET sn.artifactType = 'LabelSnapshot', sn.canonicalUri = s.canonicalUri, sn.observedAt = datetime(r.obs), sn.retrievedAt = datetime(r.ret),
    sn.archiveUri = 'https://web.archive.org/web/' + r.ts + '/https://www.elysiumhealth.com/pages/basis-supplement-facts',
    sn.contentHash = r.h, sn.contentHashBasis = 'STORED_EXCERPT_TEXT', sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.jurisdiction = 'US', sn.language = 'en',
    sn.privacyClass = 'PUBLIC', sn.createdAt = datetime(r.ret)
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (lnr:SourceLocator:InformationArtifact {uid: 'hu:locator:basis-sf-nr-line-' + r.ts})
SET lnr.artifactType = 'SourceLocator', lnr.uri = s.canonicalUri, lnr.selectorKind = 'TEXT_QUOTE', lnr.exact = r.nr, lnr.prefix = 'Amount Per Serving: ', lnr.suffix = ' (**% DV), PT (Pterostilbene)',
    lnr.quoteHash = r.qh, lnr.normalizationVersion = 'NFC-WS1', lnr.section = 'Supplement Facts', lnr.privacyClass = 'PUBLIC', lnr.createdAt = datetime(r.ret)
MERGE (lpt:SourceLocator:InformationArtifact {uid: 'hu:locator:basis-sf-pt-line-' + r.ts})
SET lpt.artifactType = 'SourceLocator', lpt.uri = s.canonicalUri, lpt.selectorKind = 'TEXT_QUOTE', lpt.exact = 'PT (Pterostilbene) 50mg', lpt.suffix = ' (**%), ** Daily Value (DV) Not Established',
    lpt.quoteHash = 'sha256:114a02592751efdde7dd11388468a8efc273d5436368b538a35c3ec87b06dd68', lpt.normalizationVersion = 'NFC-WS1', lpt.section = 'Supplement Facts', lpt.privacyClass = 'PUBLIC', lpt.createdAt = datetime(r.ret)
MERGE (lsv:SourceLocator:InformationArtifact {uid: 'hu:locator:basis-sf-serving-' + r.ts})
SET lsv.artifactType = 'SourceLocator', lsv.uri = s.canonicalUri, lsv.selectorKind = 'TEXT_QUOTE', lsv.exact = 'Serving Size: 2 Vegetarian Capsules, Servings: 30',
    lsv.quoteHash = 'sha256:5a4864b0cdf2a7bba63383ce127a0eb61e9bd900532360a304ebd7bbd16a3b8e', lsv.normalizationVersion = 'NFC-WS1', lsv.section = 'Supplement Facts', lsv.privacyClass = 'PUBLIC', lsv.createdAt = datetime(r.ret)
MERGE (sn)-[:HAS_LOCATOR]->(lnr)
MERGE (sn)-[:HAS_LOCATOR]->(lpt)
MERGE (sn)-[:HAS_LOCATOR]->(lsv);

// Re-anchoring (newer -> older) records which selector survived each layout change. PT and serving quotes: EXACT across all five captures
// (2024 theme change, "Side Effects" row added, 2026 label image replaced by a no-image placeholder). NR quote: FUZZY across the typo fix,
// EXACT 2023->2025, NO re-anchor 2025-09 -> 2026-03 (the declaration changed), EXACT 2026-03 -> 2026-07.
UNWIND [
  {n: '20230316043858', o: '20211208120325', nr: 'FUZZY'}, {n: '20250910231157', o: '20230316043858', nr: 'EXACT'},
  {n: '20260305072454', o: '20250910231157', nr: null}, {n: '20260717140606', o: '20260305072454', nr: 'EXACT'}
] AS r
MATCH (pn:SourceLocator {uid: 'hu:locator:basis-sf-pt-line-' + r.n}), (po:SourceLocator {uid: 'hu:locator:basis-sf-pt-line-' + r.o}),
      (sn:SourceLocator {uid: 'hu:locator:basis-sf-serving-' + r.n}), (so:SourceLocator {uid: 'hu:locator:basis-sf-serving-' + r.o}),
      (nn:SourceLocator {uid: 'hu:locator:basis-sf-nr-line-' + r.n}), (no:SourceLocator {uid: 'hu:locator:basis-sf-nr-line-' + r.o})
MERGE (pn)-[a1:REANCHORS]->(po) SET a1.anchorMatch = 'EXACT', a1.activityUid = 'hu:activity:w04-basis-reanchoring-2026-10-04'
MERGE (sn)-[a2:REANCHORS]->(so) SET a2.anchorMatch = 'EXACT', a2.activityUid = 'hu:activity:w04-basis-reanchoring-2026-10-04'
FOREACH (_ IN CASE WHEN r.nr IS NULL THEN [] ELSE [1] END |
  MERGE (nn)-[a3:REANCHORS]->(no) SET a3.anchorMatch = r.nr, a3.activityUid = 'hu:activity:w04-basis-reanchoring-2026-10-04');

MERGE (act:Activity:Occurrence {uid: 'hu:activity:w04-basis-reanchoring-2026-10-04'})
SET act.activityKind = 'REANCHORING', act.occurrenceType = 'Activity', act.startedAt = datetime('2026-10-04T00:55:00Z'), act.methodVersion = 'quote-reanchor-NFC-WS1-v1', act.privacyClass = 'INTERNAL', act.createdAt = datetime('2026-10-04T01:10:00Z');

// Two silent content changes (no publisher statement that an error was corrected): observed between captures; occurredAt unknown.
UNWIND [
  {ev: 'hu:source-revision:basis-sf-typo-pantent-to-patent', p: 'hu:snapshot:elysium-basis-sf-wayback-20211208120325', r: 'hu:snapshot:elysium-basis-sf-wayback-20230316043858'},
  {ev: 'hu:source-revision:basis-sf-nr-declaration-and-directions', p: 'hu:snapshot:elysium-basis-sf-wayback-20250910231157', r: 'hu:snapshot:elysium-basis-sf-wayback-20260305072454'}
] AS x
MATCH (s:Source {uid: 'hu:source:elysium-basis-supplement-facts'}), (p:SourceSnapshot {uid: x.p}), (rr:SourceSnapshot {uid: x.r})
MERGE (ev:SourceRevisionEvent:Occurrence {uid: x.ev})
SET ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'SILENT_CONTENT_CHANGE', ev.occurredAt = null, ev.recordedAt = datetime('2026-10-04T01:10:00Z'), ev.privacyClass = 'PUBLIC', ev.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ev)-[:REVISES_SOURCE]->(s)
MERGE (ev)-[:PRIOR_SNAPSHOT]->(p)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(rr);

// Label declarations (verbatim, typo preserved) on the first, last-old and first-new captures.
UNWIND [
  {d: 'hu:label-declaration:basis-sf-20211208-nr', sn: 'hu:snapshot:elysium-basis-sf-wayback-20211208120325', t: 'NR-E (Pantent-Pending Crystalline Nicotinamide Riboside) 250 mg (**% DV)', q: 'hu:quantity-declaration:basis-sf-20211208-nr', obs: '2021-12-08T12:03:25Z'},
  {d: 'hu:label-declaration:basis-sf-20250910-nr', sn: 'hu:snapshot:elysium-basis-sf-wayback-20250910231157', t: 'NR-E (Patent-Pending Crystalline Nicotinamide Riboside) 250 mg (**% DV)', q: 'hu:quantity-declaration:basis-sf-20250910-nr', obs: '2025-09-10T23:11:57Z'},
  {d: 'hu:label-declaration:basis-sf-20260305-nr', sn: 'hu:snapshot:elysium-basis-sf-wayback-20260305072454', t: 'Elysium NR (Nicotinamide Riboside Chloride) 250 mg (**% DV)', q: 'hu:quantity-declaration:basis-sf-20260305-nr', obs: '2026-03-05T07:24:54Z'}
] AS r
MATCH (sn:LabelSnapshot {uid: r.sn})
MERGE (d:LabelDeclaration:InformationArtifact {uid: r.d})
SET d.artifactType = 'LabelDeclaration', d.verbatimText = r.t, d.declarationKind = 'OTHER_DIETARY_INGREDIENT', d.panelOrder = 1, d.observedAt = datetime(r.obs), d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (q:QuantityDeclaration:InformationArtifact {uid: r.q})
SET q.artifactType = 'QuantityDeclaration', q.value = 250.0, q.unitCode = 'mg', q.quantityBasis = 'PER_SERVING', q.dailyValueStatus = 'NOT_APPLICABLE',
    q.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', q.amountReferentUid = null, q.observedAt = datetime(r.obs), q.privacyClass = 'PUBLIC', q.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (sn)-[h:HAS_DECLARATION]->(d) SET h.orderIndex = 1
MERGE (d)-[:HAS_QUANTITY_DECLARATION]->(q);

MATCH (sn:LabelSnapshot) WHERE sn.uid STARTS WITH 'hu:snapshot:elysium-basis-sf-wayback-'
MATCH (sdl:ServingDefinition {uid: 'hu:serving-definition:basis-label-2-capsules-30-servings'})
MERGE (sn)-[u:USES_SERVING_DEFINITION]->(sdl) SET u.orderIndex = 1;

// ---- assertions: variant, package, formulation episodes (no stated start or end: OBSERVATION_ONLY / UNKNOWN, bounds null) ----
UNWIND [
  {a: 'hu:assertion:basis-has-variant-us-capsule', p: 'HAS_VARIANT', s: 'hu:product:elysium-basis', o: 'hu:product-variant:basis-us-capsule-standard',
   locs: ['hu:locator:basis-sf-serving-20211208120325', 'hu:locator:basis-sf-serving-20260717140606']},
  {a: 'hu:assertion:basis-variant-has-fv-declared-nr-e', p: 'HAS_FORMULATION_VERSION', s: 'hu:product-variant:basis-us-capsule-standard', o: 'hu:formulation:basis-us-declared-nr-e-crystalline',
   locs: ['hu:locator:basis-sf-nr-line-20211208120325', 'hu:locator:basis-sf-nr-line-20230316043858', 'hu:locator:basis-sf-nr-line-20250910231157']},
  {a: 'hu:assertion:basis-variant-has-fv-declared-nr-chloride', p: 'HAS_FORMULATION_VERSION', s: 'hu:product-variant:basis-us-capsule-standard', o: 'hu:formulation:basis-us-current-2026-07-10',
   locs: ['hu:locator:basis-sf-nr-line-20260305072454', 'hu:locator:basis-sf-nr-line-20260717140606']},
  {a: 'hu:assertion:basis-variant-has-pkg-60', p: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:basis-us-capsule-standard', o: 'hu:package-configuration:basis-60-capsule-bottle',
   locs: ['hu:locator:basis-sf-serving-20211208120325', 'hu:locator:basis-sf-serving-20260717140606']}
] AS r
MATCH (s {uid: r.s}), (o {uid: r.o})
MERGE (a:Assertion {uid: r.a})
SET a.predicate = r.p, a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:12:00Z'), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.speechAct = 'STATES', a.jurisdiction = 'US', a.contentHash = 'synthetic:' + r.a, a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:12:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
WITH a, r
UNWIND r.locs AS lu
MATCH (l:SourceLocator {uid: lu})
MERGE (a)-[:SUPPORTED_BY]->(l);

// Each archived label states "Servings: 30" of a 2-capsule serving: it is the label of the package configuration (LABEL_FOR -> package).
MATCH (pc:PackageConfiguration {uid: 'hu:package-configuration:basis-60-capsule-bottle'}), (sn:LabelSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
WHERE sn.uid STARTS WITH 'hu:snapshot:elysium-basis-sf-wayback-' AND l.uid STARTS WITH 'hu:locator:basis-sf-serving-'
MERGE (a:Assertion {uid: 'hu:assertion:' + split(sn.uid, ':')[2] + '-label-for-pkg-60'})
SET a.predicate = 'LABEL_FOR', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:12:00Z'), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN',
    a.contentHash = 'synthetic:' + sn.uid + ':label-for', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:12:00Z')
MERGE (a)-[:HAS_SUBJECT]->(sn)
MERGE (a)-[:HAS_OBJECT]->(pc)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (sn)-[e:LABEL_FOR {relationshipUid: 'hu:rel:' + split(sn.uid, ':')[2] + '-label-for-pkg-60'}]->(pc)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN';

MATCH (a:Assertion {uid: 'hu:assertion:basis-has-variant-us-capsule'})-[:HAS_SUBJECT]->(s:Product), (a)-[:HAS_OBJECT]->(o:ProductVariant)
MERGE (s)-[e:HAS_VARIANT {relationshipUid: 'hu:rel:basis-has-variant-us-capsule'}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {predicate: 'HAS_FORMULATION_VERSION'})-[:HAS_SUBJECT]->(s:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}), (a)-[:HAS_OBJECT]->(o:FormulationVersion)
WHERE a.uid STARTS WITH 'hu:assertion:basis-variant-has-fv-declared-'
MERGE (s)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis, e.jurisdiction = 'US';

MATCH (a:Assertion {uid: 'hu:assertion:basis-variant-has-pkg-60'})-[:HAS_SUBJECT]->(s:ProductVariant), (a)-[:HAS_OBJECT]->(o:PackageConfiguration)
MERGE (s)-[e:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:basis-variant-has-pkg-60'}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

// USES_MATERIAL on the historical components (the current components' USES_MATERIAL edges come from elysium-basis.cypher when loaded;
// they are re-created here only if absent so this file also loads alone).
UNWIND [
  {c: 'hu:component:basis-2021-nr-e', m: 'hu:material:elysium-nr-e', a: 'hu:assertion:basis-2021-nr-component-uses-nr-e', loc: 'hu:locator:basis-sf-nr-line-20211208120325', st: 'ACCEPTED'},
  {c: 'hu:component:basis-2021-pt', m: 'hu:material:pterostilbene-unspecified-current-basis', a: 'hu:assertion:basis-2021-pt-component-uses-pt', loc: 'hu:locator:basis-sf-pt-line-20211208120325', st: 'PROPOSED'},
  {c: 'hu:component:basis-current-nr-e', m: 'hu:material:elysium-nr-e', a: 'hu:assertion:basis-current-nr-component-uses-nr-e', loc: 'hu:locator:basis-sf-nr-line-20260717140606', st: 'PROPOSED'},
  {c: 'hu:component:basis-current-pt', m: 'hu:material:pterostilbene-unspecified-current-basis', a: 'hu:assertion:basis-current-pt-component-uses-pt', loc: 'hu:locator:basis-sf-pt-line-20260717140606', st: 'PROPOSED'}
] AS r
MATCH (c:IngredientComponent {uid: r.c}), (m:IngredientMaterial {uid: r.m}), (l:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
ON CREATE SET a.predicate = 'USES_MATERIAL', a.status = r.st, a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:12:00Z'), a.contentHash = 'synthetic:' + r.a,
    a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:12:00Z')
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:HAS_OBJECT]->(m)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (c)-[u:USES_MATERIAL]->(m)
ON CREATE SET u.relationshipUid = 'hu:rel:' + split(r.a, ':')[2], u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN';

// "Elysium NR" (2026 label) vs "NR-E" (2021-2025 label): one material or two? Recorded as an open hypothesis, never as a merge.
MATCH (nrE:IngredientMaterial {uid: 'hu:material:elysium-nr-e'}), (d1:LabelDeclaration {uid: 'hu:label-declaration:basis-sf-20250910-nr'}), (d2:LabelDeclaration {uid: 'hu:label-declaration:basis-sf-20260305-nr'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:basis-elysium-nr-2026-is-nr-e'})
SET h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'MATERIAL_IDENTITY', h.resolutionStatus = 'UNRESOLVED', h.methodVersion = 'resolution-v0.1', h.status = 'PROPOSED',
    h.rationale = 'Same amount (250 mg) and serving; the 2026 label names "Elysium NR (Nicotinamide Riboside Chloride)", the 2021-2025 label "NR-E (Patent-Pending Crystalline Nicotinamide Riboside)". No source says whether the material changed.',
    h.recordedAt = datetime('2026-10-04T01:12:00Z'), h.privacyClass = 'PUBLIC', h.createdAt = datetime('2026-10-04T01:12:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(d1)
MERGE (h)-[:PROPOSES_MATCH]->(d2)
MERGE (h)-[:PROPOSES_MATCH]->(nrE);

// ---- the trial that names the brand (CQ-ID-01 / CQ-ID-02) ----
MERGE (st:Study:Entity {uid: 'hu:study:nct02678611-basis-nrpt'})
ON CREATE SET st.title = 'A Study to Evaluate Safety and Health Benefits of Basis Among Elderly Subjects', st.createdAt = datetime('2026-10-04T01:13:00Z')
SET st.entityType = 'Study', st.privacyClass = 'PUBLIC';

MERGE (si:StudyIntervention:VersionedState {uid: 'hu:study-intervention:nct02678611-nrpt-1x'})
ON CREATE SET si.name = 'Basis 250 (registry intervention label)', si.createdAt = datetime('2026-10-04T01:13:00Z')
SET si.stateType = 'StudyIntervention', si.payloadHash = coalesce(si.payloadHash, 'sha256:7ecd9cc4d2d280335fad07dcc3e8854f1e6e672172efc229cfdd277be4d52952'), si.privacyClass = 'PUBLIC';

MERGE (src:Source:Entity {uid: 'hu:source:ctgov-nct02678611'})
ON CREATE SET src.canonicalUri = 'https://clinicaltrials.gov/study/NCT02678611', src.title = 'ClinicalTrials.gov NCT02678611', src.sourceKind = 'REGULATORY_RECORD', src.createdAt = datetime('2026-10-04T01:13:00Z')
SET src.entityType = 'Source', src.privacyClass = 'PUBLIC';

MATCH (src:Source {uid: 'hu:source:ctgov-nct02678611'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct02678611-mcp-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = src.canonicalUri, sn.observedAt = datetime('2026-10-04T01:01:00Z'), sn.retrievedAt = datetime('2026-10-04T01:01:00Z'),
    sn.contentHash = 'sha256:0cdc484d0c84c1048ff2be7d16b2cbd089b1739218325c52f1479c192ab0f763', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T01:01:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct02678611-mcp-dates-interventions'})
SET l.artifactType = 'SourceLocator', l.uri = src.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = 'interventions: Basis 250; Basis 500; Placebo | start_date 2016-01 | primary_completion_date 2016-07',
    l.quoteHash = 'sha256:0cdc484d0c84c1048ff2be7d16b2cbd089b1739218325c52f1479c192ab0f763', l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T01:01:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (si:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-1x'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-mcp-dates-interventions'})
MERGE (a1:Assertion {uid: 'hu:assertion:nct02678611-conducted-2016-01-to-2016-07'})
SET a1.predicate = 'STUDY_CONDUCTED_DURING', a1.status = 'ACCEPTED', a1.polarity = 'POSITIVE', a1.valueString = 'START_TO_PRIMARY_COMPLETION',
    a1.validFrom = datetime('2016-01-01T00:00:00Z'), a1.validFromPrecision = 'MONTH', a1.validFromBasis = 'STATED_BY_SOURCE',
    a1.validTo = datetime('2016-07-01T00:00:00Z'), a1.validToPrecision = 'MONTH', a1.validToBasis = 'STATED_BY_SOURCE',
    a1.recordedAt = datetime('2026-10-04T01:13:00Z'), a1.contentHash = 'synthetic:' + 'nct02678611-conducted', a1.privacyClass = 'PUBLIC', a1.createdAt = datetime('2026-10-04T01:13:00Z')
MERGE (a1)-[:HAS_SUBJECT]->(st)
MERGE (a1)-[:SUPPORTED_BY]->(l)
MERGE (a2:Assertion {uid: 'hu:assertion:nct02678611-intervention-labelled-basis-250'})
SET a2.predicate = 'ADMINISTERED_AS_COMMERCIAL_PRODUCT', a2.status = 'ACCEPTED', a2.polarity = 'POSITIVE', a2.valueString = 'Basis 250',
    a2.recordedAt = datetime('2026-10-04T01:13:00Z'), a2.contentHash = 'synthetic:nct02678611-basis-250', a2.privacyClass = 'PUBLIC', a2.createdAt = datetime('2026-10-04T01:13:00Z')
MERGE (a2)-[:HAS_SUBJECT]->(si)
MERGE (a2)-[:SUPPORTED_BY]->(l);

// The brand page captured DURING administration names the actives but no amount, form or serving: not a label.
MERGE (bp:Source:Entity {uid: 'hu:source:elysium-basis-brand-page'})
SET bp.canonicalUri = 'http://www.elysiumhealth.com/basis', bp.title = 'Elysium Health | Basis (brand page)', bp.sourceKind = 'MARKETING_PAGE', bp.entityType = 'Source', bp.privacyClass = 'PUBLIC', bp.createdAt = datetime('2026-10-04T00:56:00Z');

MATCH (bp:Source {uid: 'hu:source:elysium-basis-brand-page'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-basis-brand-page-wayback-20160320091808'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = bp.canonicalUri, sn.observedAt = datetime('2016-03-20T09:18:08Z'), sn.retrievedAt = datetime('2026-10-04T00:56:00Z'),
    sn.archiveUri = 'https://web.archive.org/web/20160320091808/http://www.elysiumhealth.com:80/basis',
    sn.contentHash = 'sha256:c3024dc553e8fcf6fcbf824f77b07bb2561b101b04661f4ab3bbc598ca14ec60',
    sn.contentHashBasis = 'STORED_EXCERPT_TEXT', sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T00:56:00Z')
MERGE (bp)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-basis-brand-page-2016-composition-sentence'})
SET l.artifactType = 'SourceLocator', l.uri = bp.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Basis is composed of two novel compounds found in nature: nicotinamide riboside (NR), the most direct precursor to NAD+, and pterostilbene',
    l.quoteHash = 'sha256:ce703783c9db8f008adf8a4bac2b3f510a57b4ac1529cae57a1889ac494787d8',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T00:56:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// Name-level match of the registry label "Basis 250" to the enduring Product is a hypothesis about identity, not a formulation link (INV-201).
MATCH (si:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-1x'}), (p:Product {uid: 'hu:product:elysium-basis'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-mcp-dates-interventions'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:nct02678611-basis-250-is-product-basis'})
SET h.assessmentType = 'ResolutionHypothesis', h.resolutionType = 'PRODUCT_IDENTITY', h.resolutionStatus = 'PROPOSED', h.methodVersion = 'resolution-v0.1', h.status = 'PROPOSED',
    h.rationale = 'Registry intervention label "Basis 250" and sponsor Elysium match the enduring Product name; variant and formulation at administration are not established (no label capture before 2021-12-08).',
    h.recordedAt = datetime('2026-10-04T01:13:00Z'), h.privacyClass = 'PUBLIC', h.createdAt = datetime('2026-10-04T01:13:00Z')
MERGE (h)-[:PROPOSES_MATCH]->(si)
MERGE (h)-[:PROPOSES_MATCH]->(p)
MERGE (h)-[:SUPPORTED_BY]->(l);

MATCH (a:Assertion)
WHERE (a.uid STARTS WITH 'hu:assertion:basis-' OR a.uid STARTS WITH 'hu:assertion:nct02678611-' OR a.uid STARTS WITH 'hu:assertion:elysium-basis-sf-wayback-') AND a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
WITH collect(a) AS as
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w04-04-capture-fidelity-policy'})
SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1',
    j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T02:00:00Z'), j.recordedAt = datetime('2026-10-04T02:00:00Z'), j.createdAt = datetime('2026-10-04T02:00:00Z'), j.privacyClass = 'INTERNAL'
WITH j, as UNWIND as AS a MERGE (j)-[:EVALUATES]->(a);
