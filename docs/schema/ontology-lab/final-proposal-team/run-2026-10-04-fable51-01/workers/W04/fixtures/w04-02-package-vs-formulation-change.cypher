// W04 fixture 02 -- package-only change versus formulation change (CQ-ID-05), and concurrent packages (NONEXCLUSIVE).
// Part 1 (PUBLIC record, NEW_RETRIEVAL 2026-10-04): Tru Niagen 300mg is offered as 30-, 90- and "180"-capsule sizes of ONE
//   variant and ONE formulation. Shopify product record (Wayback capture 2025-05-20, tru-niagen-300mg.js): variants "30"
//   SKU CTNUS3006030010 barcode 850015311857; "90" SKU CTNUS3006090010 barcode 850015311895; "180" SKU
//   CTNUS3006090010-KIT barcode 850064273106 (a kit of the 90 SKU, i.e. a Bundle -- W15 -- not a PackageConfiguration).
//   Live page 2026-10-04: Supplement Facts text panel "Serving Size: 1 Vegetarian Capsule / Servings Per Container: 90",
//   while the 30-count label image alt text says "30 servings per container": servings per container is package-scoped.
//   Snapshot hashes: STORED_EXCERPT_TEXT over the excerpt files listed in 03-source-manifest.md (not raw bytes).
// Part 2 (SYNTHETIC_FIXTURE): a variant whose package count changes 30 -> 60 on 2026-04-01 with no formulation change,
//   contrasted with fixture 01 Pair B (formulation change, same package).

// ===== Part 1: Tru Niagen 300mg (public) =====
MERGE (o:Organization:Entity {uid: 'hu:org:chromadex-niagen-bioscience'})
SET o.name = 'Niagen Bioscience, Inc. (formerly ChromaDex)', o.entityType = 'Organization', o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (p:Product:Entity {uid: 'hu:product:tru-niagen'})
SET p.name = 'Tru Niagen', p.entityType = 'Product', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T01:00:00Z');

UNWIND [
  {v: 'hu:product-variant:tru-niagen-300mg-us-capsule', n: 'Tru Niagen 300mg, 1 vegetarian capsule per serving', s: '300 mg NIAGEN per capsule'},
  {v: 'hu:product-variant:tru-niagen-150mg-us-capsule', n: 'Tru Niagen 150mg capsule', s: '150 mg per capsule ("Two capsules make a 300mg serving", marketing card)'}
] AS r
MERGE (v:ProductVariant:Entity {uid: r.v})
SET v.name = r.n, v.entityType = 'ProductVariant', v.dosageForm = 'CAPSULE', v.jurisdiction = 'US', v.strengthDescriptor = r.s, v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (niagen:IngredientMaterial:Entity {uid: 'hu:material:chromadex-niagen'})
SET niagen.name = 'NIAGEN (nicotinamide riboside chloride)', niagen.entityType = 'IngredientMaterial', niagen.materialKind = 'BRANDED_CHEMICAL_MATERIAL', niagen.privacyClass = 'PUBLIC', niagen.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (sd:ServingDefinition:VersionedState {uid: 'hu:serving-definition:tru-niagen-300-formulation-1-capsule'})
SET sd.stateType = 'ServingDefinition', sd.servingCount = 1.0, sd.unitDescription = 'Vegetarian Capsule', sd.servingsPerContainer = null,
    sd.payloadHash = 'sha256:9bbc3003551b0acd7a4595cc31f7e7276c5c38b8a6e1011d38bec445bdb52f32', sd.privacyClass = 'PUBLIC', sd.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (sdl:ServingDefinition:VersionedState {uid: 'hu:serving-definition:tru-niagen-300-90ct-label'})
SET sdl.stateType = 'ServingDefinition', sdl.servingCount = 1.0, sdl.unitDescription = 'Vegetarian Capsule', sdl.servingsPerContainer = 90.0,
    sdl.servingStatementVerbatim = 'Serving Size: 1 Vegetarian Capsule Servings Per Container: 90',
    sdl.payloadHash = 'sha256:4351a5ff89f7681403c85e9bab22d76f211e17339ce28847bebbbe89fe506439', sdl.privacyClass = 'PUBLIC', sdl.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'})
SET fv.stateType = 'FormulationVersion', fv.versionName = 'Tru Niagen 300mg label observed 2026-10-03/04', fv.jurisdiction = 'US',
    fv.payloadHash = 'sha256:aac78da63b06ef61895ba020b39dc2d06bf9d4db9cae15013d33f3147efef8d3',
    fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:tru-niagen-300mg-niagen'})
SET c.stateType = 'IngredientComponent', c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = 300.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING',
    c.massBasis = 'SALT_FORM', c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', c.declaredAs = 'NIAGEN® (nicotinamide riboside chloride)', c.isDietaryIngredient = true,
    c.payloadHash = 'sha256:8322d17f88257e752feeefd0b9d3c0ac6c900e2abbf9de04f12c02a354112cab',
    c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (fv:FormulationVersion {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'}), (c:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'}),
      (sd:ServingDefinition {uid: 'hu:serving-definition:tru-niagen-300-formulation-1-capsule'})
MERGE (fv)-[hc:HAS_INGREDIENT_COMPONENT]->(c) SET hc.orderIndex = 1
MERGE (fv)-[us:USES_SERVING_DEFINITION]->(sd) SET us.orderIndex = 1;

UNWIND [
  {pc: 'hu:package-configuration:tru-niagen-300mg-30ct', n: 30, ph: 'sha256:e636b4e0d81718e8b63a150ff74310b76f541cb23967dd9b7a56ae388c5fdf8e',
   tid: 'hu:trade-id:gtin-850015311857', gtin: '850015311857', sku: 'hu:trade-id:truniagen-sku-ctnus3006030010', skuv: 'CTNUS3006030010'},
  {pc: 'hu:package-configuration:tru-niagen-300mg-90ct', n: 90, ph: 'sha256:430f6722c39a674bc908f6f6f69828a7d606abb290180b876282f0875ef45bd1',
   tid: 'hu:trade-id:gtin-850015311895', gtin: '850015311895', sku: 'hu:trade-id:truniagen-sku-ctnus3006090010', skuv: 'CTNUS3006090010'}
] AS r
MERGE (pc:PackageConfiguration:VersionedState {uid: r.pc})
SET pc.stateType = 'PackageConfiguration', pc.packageForm = 'BOTTLE', pc.unitCount = r.n, pc.unitDescription = 'vegetarian capsules', pc.payloadHash = r.ph,
    pc.privacyClass = 'PUBLIC', pc.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (g:TradeItemIdentifier:Identifier:Entity {uid: r.tid})
SET g.entityType = 'TradeItemIdentifier', g.scheme = 'GTIN', g.value = r.gtin, g.issuer = 'GS1 (as published in the merchant product record)', g.privacyClass = 'PUBLIC', g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (k:TradeItemIdentifier:Identifier:Entity {uid: r.sku})
SET k.entityType = 'TradeItemIdentifier', k.scheme = 'MERCHANT_SKU', k.value = r.skuv, k.issuer = 'truniagen.com Shopify store', k.privacyClass = 'PUBLIC', k.createdAt = datetime('2026-10-04T01:00:00Z');

// Sources: the merchant product record (archived JSON) and the live product page Supplement Facts panel.
UNWIND [
  {src: 'hu:source:truniagen-300mg-product-json', uri: 'https://www.truniagen.com/products/tru-niagen-300mg.js', kind: 'MARKETPLACE_LISTING', title: 'Tru Niagen 300mg Shopify product record',
   sn: 'hu:snapshot:truniagen-300mg-json-wayback-2025-05-20', obs: '2025-05-20T17:53:10Z', ret: '2026-10-04T00:58:00Z', hash: 'sha256:f77511b297345eb10888f63ed0af4f8d58c309f089eb09868d014300ca78424e',
   archive: 'https://web.archive.org/web/20250520175310id_/https://www.truniagen.com/products/tru-niagen-300mg.js', label: false},
  {src: 'hu:source:truniagen-300mg-product-page', uri: 'https://www.truniagen.com/products/tru-niagen-300mg', kind: 'MANUFACTURER_LABEL_PAGE', title: 'Tru Niagen 300mg product page',
   sn: 'hu:snapshot:truniagen-300mg-page-2026-10-04', obs: '2026-10-04T00:57:00Z', ret: '2026-10-04T00:57:00Z', hash: 'sha256:116a0bd7e4172613c97145bc3ef62bbac666c4ee3a521d9971226e5c8653a898',
   archive: null, label: true}
] AS r
MERGE (s:Source:Entity {uid: r.src})
SET s.canonicalUri = r.uri, s.title = r.title, s.sourceKind = r.kind, s.entityType = 'Source', s.privacyClass = 'PUBLIC', s.createdAt = datetime(r.ret)
MERGE (sn:SourceSnapshot:InformationArtifact {uid: r.sn})
SET sn.artifactType = CASE WHEN r.label THEN 'LabelSnapshot' ELSE 'SourceSnapshot' END, sn.canonicalUri = r.uri, sn.observedAt = datetime(r.obs), sn.retrievedAt = datetime(r.ret),
    sn.contentHash = r.hash, sn.contentHashBasis = 'STORED_EXCERPT_TEXT', sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.archiveUri = r.archive,
    sn.jurisdiction = 'US', sn.language = 'en', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime(r.ret)
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-page-2026-10-04'}) SET sn:LabelSnapshot;

UNWIND [
  {sn: 'hu:snapshot:truniagen-300mg-json-wayback-2025-05-20', loc: 'hu:locator:truniagen-300mg-json-variant-30', exact: '"title":"30","option1":"30","option2":null,"option3":null,"sku":"CTNUS3006030010"', qh: 'sha256:d2c0ded538dd224a57d1d38a7d028c92788836cb06d31ec11aac87aaf850d0c8', ret: '2026-10-04T00:58:00Z'},
  {sn: 'hu:snapshot:truniagen-300mg-json-wayback-2025-05-20', loc: 'hu:locator:truniagen-300mg-json-variant-90', exact: '"title":"90","option1":"90","option2":null,"option3":null,"sku":"CTNUS3006090010"', qh: 'sha256:f20e202235abf13163c8752c4fa4d8541c7088519454b93c2c823f5d3de11860', ret: '2026-10-04T00:58:00Z'},
  {sn: 'hu:snapshot:truniagen-300mg-page-2026-10-04', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', exact: 'NIAGEN® (nicotinamide riboside chloride) | 300mg', qh: 'sha256:a7e6b185e39c542e3d2447a21cd03e3f89800d4dfdf8fa090ced1f6e6060346a', ret: '2026-10-04T00:57:00Z'},
  {sn: 'hu:snapshot:truniagen-300mg-page-2026-10-04', loc: 'hu:locator:truniagen-300mg-sf-serving', exact: 'Serving Size: 1 Vegetarian Capsule Servings Per Container: 90', qh: 'sha256:4d3572f896afc6c727a6b7fe52d88a338905692c8e4e189a20c525badfe8b21a', ret: '2026-10-04T00:57:00Z'}
] AS r
MATCH (sn:SourceSnapshot {uid: r.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: r.loc})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = r.exact, l.quoteHash = r.qh,
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime(r.ret)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// Asserted structure: HAS_VARIANT, HAS_FORMULATION_VERSION, HAS_PACKAGE_CONFIGURATION x2 (concurrent), IDENTIFIED_BY, LABEL_FOR (90ct package),
// USES_MATERIAL. Valid start of every fact is not stated: validFromBasis OBSERVATION_ONLY, bounds null (round 0007 section 9).
UNWIND [
  {a: 'hu:assertion:tru-niagen-has-variant-300', pred: 'HAS_VARIANT', s: 'hu:product:tru-niagen', o: 'hu:product-variant:tru-niagen-300mg-us-capsule', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tru-niagen-has-variant-300'},
  {a: 'hu:assertion:tru-niagen-300-has-fv', pred: 'HAS_FORMULATION_VERSION', s: 'hu:product-variant:tru-niagen-300mg-us-capsule', o: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tru-niagen-300-has-fv'},
  {a: 'hu:assertion:tru-niagen-300-has-pkg-30', pred: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:tru-niagen-300mg-us-capsule', o: 'hu:package-configuration:tru-niagen-300mg-30ct', loc: 'hu:locator:truniagen-300mg-json-variant-30', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tru-niagen-300-has-pkg-30'},
  {a: 'hu:assertion:tru-niagen-300-has-pkg-90', pred: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:tru-niagen-300mg-us-capsule', o: 'hu:package-configuration:tru-niagen-300mg-90ct', loc: 'hu:locator:truniagen-300mg-json-variant-90', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tru-niagen-300-has-pkg-90'},
  {a: 'hu:assertion:pkg-30-identified-by-gtin', pred: 'IDENTIFIED_BY', s: 'hu:package-configuration:tru-niagen-300mg-30ct', o: 'hu:trade-id:gtin-850015311857', loc: 'hu:locator:truniagen-300mg-json-variant-30', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:pkg-30-identified-by-gtin'},
  {a: 'hu:assertion:pkg-90-identified-by-gtin', pred: 'IDENTIFIED_BY', s: 'hu:package-configuration:tru-niagen-300mg-90ct', o: 'hu:trade-id:gtin-850015311895', loc: 'hu:locator:truniagen-300mg-json-variant-90', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:pkg-90-identified-by-gtin'},
  {a: 'hu:assertion:pkg-30-identified-by-sku', pred: 'IDENTIFIED_BY', s: 'hu:package-configuration:tru-niagen-300mg-30ct', o: 'hu:trade-id:truniagen-sku-ctnus3006030010', loc: 'hu:locator:truniagen-300mg-json-variant-30', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:pkg-30-identified-by-sku'},
  {a: 'hu:assertion:pkg-90-identified-by-sku', pred: 'IDENTIFIED_BY', s: 'hu:package-configuration:tru-niagen-300mg-90ct', o: 'hu:trade-id:truniagen-sku-ctnus3006090010', loc: 'hu:locator:truniagen-300mg-json-variant-90', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:pkg-90-identified-by-sku'},
  {a: 'hu:assertion:tn-page-label-for-90ct', pred: 'LABEL_FOR', s: 'hu:snapshot:truniagen-300mg-page-2026-10-04', o: 'hu:package-configuration:tru-niagen-300mg-90ct', loc: 'hu:locator:truniagen-300mg-sf-serving', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tn-page-label-for-90ct'},
  {a: 'hu:assertion:tn-page-declares-fv', pred: 'DECLARES_FORMULATION', s: 'hu:snapshot:truniagen-300mg-page-2026-10-04', o: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tn-page-declares-fv'},
  {a: 'hu:assertion:tn-300-component-uses-niagen', pred: 'USES_MATERIAL', s: 'hu:component:tru-niagen-300mg-niagen', o: 'hu:material:chromadex-niagen', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', rec: '2026-10-04T01:00:00Z', ru: 'hu:rel:tn-300-component-uses-niagen'}
] AS r
MATCH (s {uid: r.s}), (o {uid: r.o}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
SET a.predicate = r.pred, a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime(r.rec), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.speechAct = 'STATES', a.jurisdiction = 'US', a.contentHash = 'synthetic:' + r.a, a.privacyClass = 'PUBLIC', a.createdAt = datetime(r.rec)
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// Project each assertion to its typed edge (asserted_edge profile). One statement per relationship type (types are static in Cypher).
MATCH (a:Assertion {predicate: 'HAS_VARIANT'})-[:HAS_SUBJECT]->(s:Product {uid: 'hu:product:tru-niagen'}), (a)-[:HAS_OBJECT]->(o:ProductVariant)
MERGE (s)-[e:HAS_VARIANT {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-300-has-fv'})-[:HAS_SUBJECT]->(s:ProductVariant), (a)-[:HAS_OBJECT]->(o:FormulationVersion)
MERGE (s)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis, e.jurisdiction = 'US';

MATCH (a:Assertion {predicate: 'HAS_PACKAGE_CONFIGURATION'})-[:HAS_SUBJECT]->(s:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'}), (a)-[:HAS_OBJECT]->(o:PackageConfiguration)
MERGE (s)-[e:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {predicate: 'IDENTIFIED_BY'})-[:HAS_SUBJECT]->(s:PackageConfiguration), (a)-[:HAS_OBJECT]->(o:TradeItemIdentifier)
WHERE a.uid STARTS WITH 'hu:assertion:pkg-'
MERGE (s)-[e:IDENTIFIED_BY {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis, e.isPrimary = (o.scheme = 'GTIN');

MATCH (a:Assertion {uid: 'hu:assertion:tn-page-label-for-90ct'})-[:HAS_SUBJECT]->(s:LabelSnapshot), (a)-[:HAS_OBJECT]->(o:PackageConfiguration)
MERGE (s)-[e:LABEL_FOR {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {uid: 'hu:assertion:tn-page-declares-fv'})-[:HAS_SUBJECT]->(s:LabelSnapshot), (a)-[:HAS_OBJECT]->(o:FormulationVersion)
MERGE (s)-[e:DECLARES_FORMULATION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {uid: 'hu:assertion:tn-300-component-uses-niagen'})-[:HAS_SUBJECT]->(s:IngredientComponent), (a)-[:HAS_OBJECT]->(o:IngredientMaterial)
MERGE (s)-[e:USES_MATERIAL {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

// The label page's serving statement is attached to the label snapshot (servingsPerContainer = package fact; V-W04-07 satisfied because LABEL_FOR targets the 90ct package).
MATCH (sn:LabelSnapshot {uid: 'hu:snapshot:truniagen-300mg-page-2026-10-04'}), (sdl:ServingDefinition {uid: 'hu:serving-definition:tru-niagen-300-90ct-label'})
MERGE (sn)-[u:USES_SERVING_DEFINITION]->(sdl) SET u.orderIndex = 1;

// ===== Part 2: synthetic package-count change without formulation change =====
MERGE (p:Product:Entity {uid: 'hu:product:w04-syn-pkg'})
SET p.name = 'Synthetic Package-Change Product', p.entityType = 'Product', p.productKind = 'DIETARY_SUPPLEMENT', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-01-15T09:00:00Z');

MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:w04-syn-pkg-us-capsule'})
SET v.name = 'Synthetic Package-Change Product - US capsule', v.entityType = 'ProductVariant', v.dosageForm = 'CAPSULE', v.jurisdiction = 'US', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-01-15T09:00:00Z');

MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:w04-syn-ingredient-y'})
SET m.name = 'Ingredient Y (synthetic material)', m.entityType = 'IngredientMaterial', m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-01-15T09:00:00Z');

MERGE (sd:ServingDefinition:VersionedState {uid: 'hu:serving-definition:w04-syn-1-capsule'})
SET sd.stateType = 'ServingDefinition', sd.servingCount = 1.0, sd.unitDescription = 'Capsule',
    sd.payloadHash = 'sha256:820c8d41b721c894a1c9ca26a9f0a1099e39126d055badcf06b65c4772f3b68f', sd.privacyClass = 'PUBLIC', sd.createdAt = datetime('2026-03-02T09:00:00Z');

MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-syn-pkg-fv1'})
SET fv.stateType = 'FormulationVersion', fv.versionName = 'Synthetic package-change product FV1 (Y 100 mg)', fv.jurisdiction = 'US', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-01-15T09:00:00Z'),
    fv.payloadHash = 'sha256:421014ebda9d7a39d54f92982512d70e6b3dc0506e6d7e9a00d213e6e73c48ba';

MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:w04-syn-pkg-fv1-y'})
SET c.stateType = 'IngredientComponent', c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = 100.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING', c.massBasis = 'MATERIAL_AS_IS',
    c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', c.declaredAs = 'Ingredient Y', c.isDietaryIngredient = true, c.payloadHash = 'sha256:ecad5447679a3e47cf02d44d0699c07b9886bb5b376a4662f8ce9bf6e6a129d7',
    c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-01-15T09:00:00Z');

MATCH (fv:FormulationVersion {uid: 'hu:formulation:w04-syn-pkg-fv1'}), (c:IngredientComponent {uid: 'hu:component:w04-syn-pkg-fv1-y'}), (sd:ServingDefinition {uid: 'hu:serving-definition:w04-syn-1-capsule'})
MERGE (fv)-[hc:HAS_INGREDIENT_COMPONENT]->(c) SET hc.orderIndex = 1
MERGE (fv)-[us:USES_SERVING_DEFINITION]->(sd) SET us.orderIndex = 1;

UNWIND [
  {pc: 'hu:package-configuration:w04-syn-pkg-30ct', n: 30, ph: 'sha256:87870c6b7d68933b44f6616c55104f81074da71317be20662a1a65f9b1f97f64'},
  {pc: 'hu:package-configuration:w04-syn-pkg-60ct', n: 60, ph: 'sha256:099bc11be857d9ff1fa8aaa81831f6f903df02724c62161004adec38c8167a67'}
] AS r
MERGE (pc:PackageConfiguration:VersionedState {uid: r.pc})
SET pc.stateType = 'PackageConfiguration', pc.packageForm = 'BOTTLE', pc.unitCount = r.n, pc.unitDescription = 'capsules', pc.payloadHash = r.ph, pc.privacyClass = 'PUBLIC', pc.createdAt = datetime('2026-01-15T09:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:w04-syn-pkg-page'})
SET s.canonicalUri = 'https://example.invalid/w04/pkg/product', s.title = 'Synthetic product page', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.entityType = 'Source', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-01-15T09:00:00Z');

UNWIND [
  {sn: 'hu:snapshot:w04-syn-pkg-page-2026-01-15', at: '2026-01-15T09:00:00Z', loc: 'hu:locator:w04-syn-pkg-2026-01-15', exact: 'Ingredient Y 100 mg. Bottle of 30 capsules.'},
  {sn: 'hu:snapshot:w04-syn-pkg-page-2026-04-03', at: '2026-04-03T09:00:00Z', loc: 'hu:locator:w04-syn-pkg-2026-04-03', exact: 'Ingredient Y 100 mg. Now in a bottle of 60 capsules (from April 1, 2026); the 30-count bottle is discontinued.'}
] AS r
MATCH (s:Source {uid: 'hu:source:w04-syn-pkg-page'})
MERGE (sn:LabelSnapshot:SourceSnapshot:InformationArtifact {uid: r.sn})
SET sn.artifactType = 'LabelSnapshot', sn.canonicalUri = s.canonicalUri, sn.observedAt = datetime(r.at), sn.retrievedAt = datetime(r.at), sn.contentHash = 'synthetic:' + r.sn,
    sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE', sn.jurisdiction = 'US', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime(r.at)
MERGE (l:SourceLocator:InformationArtifact {uid: r.loc})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = r.exact, l.quoteHash = 'synthetic:' + r.loc, l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime(r.at)
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// FV attached once (no change); package 30ct episode bounded by VALIDITY_BOUNDED on 2026-04-03; 60ct episode opens 2026-04-01.
UNWIND [
  {a: 'hu:assertion:w04-syn-pkg-has-variant', pred: 'HAS_VARIANT', s: 'hu:product:w04-syn-pkg', o: 'hu:product-variant:w04-syn-pkg-us-capsule', loc: 'hu:locator:w04-syn-pkg-2026-01-15', rec: '2026-01-15T10:00:00Z', recTo: null, st: 'ACCEPTED', vf: null, vfp: null, vfb: 'OBSERVATION_ONLY', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-pkg-has-fv1', pred: 'HAS_FORMULATION_VERSION', s: 'hu:product-variant:w04-syn-pkg-us-capsule', o: 'hu:formulation:w04-syn-pkg-fv1', loc: 'hu:locator:w04-syn-pkg-2026-01-15', rec: '2026-01-15T10:00:00Z', recTo: null, st: 'ACCEPTED', vf: null, vfp: null, vfb: 'OBSERVATION_ONLY', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-pkg-30-open', pred: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:w04-syn-pkg-us-capsule', o: 'hu:package-configuration:w04-syn-pkg-30ct', loc: 'hu:locator:w04-syn-pkg-2026-01-15', rec: '2026-01-15T10:00:00Z', recTo: '2026-04-03T10:00:00Z', st: 'SUPERSEDED', vf: null, vfp: null, vfb: 'OBSERVATION_ONLY', vt: null, vtp: null, vtb: 'UNKNOWN'},
  {a: 'hu:assertion:w04-syn-pkg-30-bounded', pred: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:w04-syn-pkg-us-capsule', o: 'hu:package-configuration:w04-syn-pkg-30ct', loc: 'hu:locator:w04-syn-pkg-2026-04-03', rec: '2026-04-03T10:00:00Z', recTo: null, st: 'ACCEPTED', vf: null, vfp: null, vfb: 'OBSERVATION_ONLY', vt: '2026-04-01T00:00:00Z', vtp: 'DAY', vtb: 'STATED_BY_SOURCE'},
  {a: 'hu:assertion:w04-syn-pkg-60-open', pred: 'HAS_PACKAGE_CONFIGURATION', s: 'hu:product-variant:w04-syn-pkg-us-capsule', o: 'hu:package-configuration:w04-syn-pkg-60ct', loc: 'hu:locator:w04-syn-pkg-2026-04-03', rec: '2026-04-03T10:00:00Z', recTo: null, st: 'ACCEPTED', vf: '2026-04-01T00:00:00Z', vfp: 'DAY', vfb: 'STATED_BY_SOURCE', vt: null, vtp: null, vtb: 'UNKNOWN'}
] AS r
MATCH (s {uid: r.s}), (o {uid: r.o}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
SET a.predicate = r.pred, a.status = r.st, a.polarity = 'POSITIVE', a.recordedAt = datetime(r.rec), a.recordedTo = CASE WHEN r.recTo IS NULL THEN null ELSE datetime(r.recTo) END,
    a.validFrom = CASE WHEN r.vf IS NULL THEN null ELSE datetime(r.vf) END, a.validFromPrecision = r.vfp, a.validFromBasis = r.vfb,
    a.validTo = CASE WHEN r.vt IS NULL THEN null ELSE datetime(r.vt) END, a.validToPrecision = r.vtp, a.validToBasis = r.vtb,
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.speechAct = 'STATES', a.jurisdiction = 'US', a.contentHash = 'synthetic:' + r.a, a.privacyClass = 'PUBLIC', a.createdAt = datetime(r.rec)
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(loc);

MATCH (c:IngredientComponent {uid: 'hu:component:w04-syn-pkg-fv1-y'}), (m:IngredientMaterial {uid: 'hu:material:w04-syn-ingredient-y'}), (loc:SourceLocator {uid: 'hu:locator:w04-syn-pkg-2026-01-15'})
MERGE (a:Assertion {uid: 'hu:assertion:w04-syn-pkg-fv1-y-uses-material'})
SET a.predicate = 'USES_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-01-15T10:00:00Z'), a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.contentHash = 'synthetic:w04-syn-pkg-fv1-y-uses-material', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-01-15T10:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:HAS_OBJECT]->(m)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (c)-[u:USES_MATERIAL {relationshipUid: 'hu:rel:w04-syn-pkg-fv1-y-uses-material'}]->(m)
SET u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN';

MATCH (n:Assertion {uid: 'hu:assertion:w04-syn-pkg-30-bounded'}), (o:Assertion {uid: 'hu:assertion:w04-syn-pkg-30-open'})
MERGE (n)-[s:SUPERSEDES]->(o) SET s.supersessionKind = 'VALIDITY_BOUNDED', s.recordedAt = datetime('2026-04-03T10:00:00Z');

MATCH (a:Assertion {uid: 'hu:assertion:w04-syn-pkg-has-variant'})-[:HAS_SUBJECT]->(s:Product), (a)-[:HAS_OBJECT]->(o:ProductVariant)
MERGE (s)-[e:HAS_VARIANT {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion {uid: 'hu:assertion:w04-syn-pkg-has-fv1'})-[:HAS_SUBJECT]->(s:ProductVariant), (a)-[:HAS_OBJECT]->(o:FormulationVersion)
MERGE (s)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis, e.jurisdiction = 'US';

MATCH (a:Assertion {predicate: 'HAS_PACKAGE_CONFIGURATION'})-[:HAS_SUBJECT]->(s:ProductVariant {uid: 'hu:product-variant:w04-syn-pkg-us-capsule'}), (a)-[:HAS_OBJECT]->(o:PackageConfiguration)
MERGE (s)-[e:HAS_PACKAGE_CONFIGURATION {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.recordedTo = a.recordedTo, e.validFrom = a.validFrom, e.validTo = a.validTo,
    e.validFromPrecision = a.validFromPrecision, e.validToPrecision = a.validToPrecision, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

MATCH (a:Assertion)
WHERE (a.uid STARTS WITH 'hu:assertion:w04-syn-pkg' OR a.uid STARTS WITH 'hu:assertion:tru-niagen' OR a.uid STARTS WITH 'hu:assertion:pkg-' OR a.uid STARTS WITH 'hu:assertion:tn-')
  AND a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
WITH collect(a) AS as
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w04-02-capture-fidelity-policy'})
SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1',
    j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T02:00:00Z'), j.recordedAt = datetime('2026-10-04T02:00:00Z'), j.createdAt = datetime('2026-10-04T02:00:00Z'), j.privacyClass = 'INTERNAL'
WITH j, as UNWIND as AS a MERGE (j)-[:EVALUATES]->(a);
