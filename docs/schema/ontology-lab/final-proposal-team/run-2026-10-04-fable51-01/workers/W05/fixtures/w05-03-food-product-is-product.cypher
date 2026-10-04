// =====================================================================================================================
// W05 fixture 03: a marketed food is a W04 Product (productKind CONVENTIONAL_FOOD), one identity, not a FoodProduct
// beside a Product. Part A writes a live-style legacy node (:FoodProduct) and applies the migration relabel from
// migration-map.yaml (the uid, live id and stored properties survive; the FoodProduct label is removed; legacy
// HAS_INGREDIENT becomes a formulation component). Part B shows the product -> variant -> formulation -> component ->
// FoodItem path that replaces live FoodProduct.hasIngredients and makes W04's derived CONTAINS reach the food.
// SYNTHETIC_FIXTURE: product, brand and label are fictional (no real company). Every statement binds its own nodes.
// =====================================================================================================================

// ---- Part A: legacy live shape (as the live schema stores it), then the migration ----
MERGE (fp:FoodProduct {id: '7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71'})
SET fp.name = 'Synthetic Grove Brazil Nuts 16 oz', fp.brandName = 'Synthetic Grove', fp.processingMethods = ['raw', 'shelled'],
    fp.createdAt = datetime('2026-01-15T00:00:00Z'), fp.privacyClass = 'PUBLIC', fp.updatedAt = datetime('2026-01-15T00:00:00Z');

MERGE (ing:Ingredient {id: 'c41d7f02-6a3b-4f8e-8d20-1b9e7a6c5d43'})
SET ing.name = 'Brazil nuts', ing.ingredientRole = 'primary', ing.createdAt = datetime('2026-01-15T00:00:00Z'), ing.privacyClass = 'PUBLIC';

MATCH (fp:FoodProduct {id: '7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71'}), (ing:Ingredient {id: 'c41d7f02-6a3b-4f8e-8d20-1b9e7a6c5d43'})
MERGE (fp)-[r:HAS_INGREDIENT]->(ing)
SET r.dose = 454.0, r.doseUnit = 'g', r.role = 'primary';

// Migration M-W05-01 (FoodProduct -> Product). uid from the live id; one node; label FoodProduct removed.
MATCH (fp:FoodProduct {id: '7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71'})
SET fp:Product:Entity, fp.uid = 'hu:product:' + fp.id, fp.entityType = 'Product', fp.productKind = 'CONVENTIONAL_FOOD',
    fp.legacyLabels = ['FoodProduct'], fp.legacyBrandName = fp.brandName, fp.schemaVersion = 'final-proposal'
REMOVE fp:FoodProduct;

// Migration M-W05-02 (live Ingredient -> IngredientMaterial is W02's map; shown here only so the edge can be rebuilt).
MATCH (ing:Ingredient {id: 'c41d7f02-6a3b-4f8e-8d20-1b9e7a6c5d43'})
SET ing:IngredientMaterial:Entity, ing.uid = 'hu:material:' + ing.id, ing.entityType = 'IngredientMaterial', ing.materialKind = 'UNRESOLVED_MATERIAL',
    ing.legacyLabels = ['Ingredient']
REMOVE ing:Ingredient;

// ---- Part B: the product backbone (W04 types) ----
MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut'})
SET f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Brazil nut (preparation not specified)', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MATCH (p:Product {uid: 'hu:product:7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71'})
MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:synthetic-grove-brazil-nuts-16oz-us'})
SET v.entityType = 'ProductVariant', v.name = 'Synthetic Grove Brazil Nuts, raw, shelled, 16 oz (US)', v.jurisdiction = 'US', v.createdAt = datetime('2026-10-04T02:00:00Z'), v.privacyClass = 'PUBLIC'
MERGE (p)-[r:HAS_VARIANT]->(v)
SET r.relationshipUid = 'hu:rel:has-variant-synthetic-grove', r.assertionUid = 'hu:assertion:synthetic-grove-has-variant',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (v:ProductVariant {uid: 'hu:product-variant:synthetic-grove-brazil-nuts-16oz-us'})
MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:synthetic-grove-brazil-nuts-v1'})
SET fv.stateType = 'FormulationVersion', fv.versionName = 'label observed 2026-01-15', fv.jurisdiction = 'US',
    fv.payloadHash = 'sha256:synthetic-w05-fv1', fv.createdAt = datetime('2026-10-04T02:00:00Z'), fv.privacyClass = 'PUBLIC'
MERGE (v)-[r:HAS_FORMULATION_VERSION]->(fv)
SET r.relationshipUid = 'hu:rel:hfv-synthetic-grove-v1', r.assertionUid = 'hu:assertion:synthetic-grove-formulation-v1', r.jurisdiction = 'US',
    r.validFrom = datetime('2026-01-01T00:00:00Z'), r.validFromPrecision = 'MONTH', r.validFromBasis = 'PUBLICATION_PROXY', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// Component: the label lists "Brazil nuts" (no preparation beyond 'raw, shelled' marketing text) -> the base FoodItem.
MATCH (fv:FormulationVersion {uid: 'hu:formulation:synthetic-grove-brazil-nuts-v1'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:synthetic-grove-brazil-nuts-only'})
SET c.stateType = 'IngredientComponent', c.role = 'PRIMARY', c.labelOrder = 1, c.declaredAs = 'Brazil nuts',
    c.amountReferent = 'NOT_STATED', c.payloadHash = 'sha256:synthetic-w05-c1', c.createdAt = datetime('2026-10-04T02:00:00Z'), c.privacyClass = 'PUBLIC'
MERGE (fv)-[:HAS_INGREDIENT_COMPONENT]->(c)
MERGE (c)-[r:USES_MATERIAL]->(f)
SET r.relationshipUid = 'hu:rel:uses-material-synthetic-grove', r.assertionUid = 'hu:assertion:synthetic-grove-component-brazil-nut',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// W04 derived CONTAINS (rule contains-v1): variant -> material through the current formulation.
MATCH (v:ProductVariant {uid: 'hu:product-variant:synthetic-grove-brazil-nuts-16oz-us'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (v)-[r:CONTAINS]->(f)
SET r.derivationRule = 'contains-v1', r.derivedFromAssertionUids = ['hu:assertion:synthetic-grove-formulation-v1', 'hu:assertion:synthetic-grove-component-brazil-nut'],
    r.derivedAt = datetime('2026-10-04T02:00:00Z');

// The migrated legacy Ingredient is resolved to the food by an EquivalenceAssessment-style redirect (owner W00/W02):
// shown as a ResolutionHypothesis so the legacy uid stays resolvable and is never silently merged by name.
MATCH (old:IngredientMaterial {uid: 'hu:material:c41d7f02-6a3b-4f8e-8d20-1b9e7a6c5d43'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:legacy-ingredient-brazil-nuts-to-food'})
SET h.assessmentType = 'ResolutionHypothesis', h.methodVersion = 'w05-migration-v1', h.status = 'PROPOSED', h.recordedAt = datetime('2026-10-04T02:00:00Z'),
    h.resolutionStatus = 'CANDIDATE', h.rationale = 'legacy Ingredient "Brazil nuts" on a food product; same name only', h.createdAt = datetime('2026-10-04T02:00:00Z'), h.privacyClass = 'PUBLIC'
MERGE (h)-[:PROPOSES_MATCH]->(old)
MERGE (h)-[:PROPOSES_MATCH]->(f);

// Assertions behind Part B asserted edges (synthetic label source).
MERGE (s:Source:Entity {uid: 'hu:source:synthetic-grove-label-page'})
SET s.entityType = 'Source', s.canonicalUri = 'https://synthetic-grove.example.invalid/brazil-nuts', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:synthetic-grove-label-page'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-grove-label-2026-01-15'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-01-15T00:00:00Z'), sn.observedAt = datetime('2026-01-15T00:00:00Z'),
    sn.contentHash = 'synthetic:hu:snapshot:synthetic-grove-label-2026-01-15', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE',
    sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-grove-ingredients'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = 'Ingredients: Brazil nuts.', l.quoteHash = 'sha256:f73315bd3a33a01041d0dc55fe0b31a21a6e25dce4344cb5fb3d14570aa6d144', l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

UNWIND [['hu:assertion:synthetic-grove-has-variant', 'HAS_VARIANT', 'hu:product:7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71', 'hu:product-variant:synthetic-grove-brazil-nuts-16oz-us'],
        ['hu:assertion:synthetic-grove-formulation-v1', 'HAS_FORMULATION_VERSION', 'hu:product-variant:synthetic-grove-brazil-nuts-16oz-us', 'hu:formulation:synthetic-grove-brazil-nuts-v1'],
        ['hu:assertion:synthetic-grove-component-brazil-nut', 'USES_MATERIAL', 'hu:component:synthetic-grove-brazil-nuts-only', 'hu:material:food-brazil-nut']] AS row
MATCH (subj {uid: row[2]}), (obj {uid: row[3]}), (l:SourceLocator {uid: 'hu:locator:synthetic-grove-ingredients'})
MERGE (a:Assertion {uid: row[0]})
SET a.predicate = row[1], a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK', a.assertionBasis = 'MANUFACTURER_CLAIM',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'synthetic:' + row[0]
MERGE (a)-[:HAS_SUBJECT]->(subj) MERGE (a)-[:HAS_OBJECT]->(obj) MERGE (a)-[:SUPPORTED_BY]->(l);

// Migration M-W05-03: the legacy HAS_INGREDIENT edge is retired once the component path exists (its dose 454 g was
// the package net quantity, not a composition amount; W04 PackageConfiguration.netQuantity receives it).
MATCH (p:Product {uid: 'hu:product:7b2f4c1e-0d9a-4e55-9b61-2f0a8c3d5e71'})-[r:HAS_INGREDIENT]->(:IngredientMaterial {uid: 'hu:material:c41d7f02-6a3b-4f8e-8d20-1b9e7a6c5d43'})
WHERE EXISTS { MATCH (p)-[:HAS_VARIANT]->(:ProductVariant)-[:HAS_FORMULATION_VERSION]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(:IngredientMaterial) }
DELETE r;

// Valid time of the HAS_FORMULATION_VERSION assertion equals its projected episode (V-505).
MATCH (a:Assertion {uid: 'hu:assertion:synthetic-grove-formulation-v1'})
SET a.validFrom = datetime('2026-01-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'PUBLICATION_PROXY', a.validToBasis = 'UNKNOWN', a.jurisdiction = 'US';
