// Illustrative fixture only — not a production import.
// Each statement is self-contained: Cypher variables do not survive a ';' boundary, so every statement
// re-binds the nodes it needs by uid with MATCH before MERGE-ing relationships (fixed 2026-10-03; the
// 0.1.0 version referenced earlier variables and would have created blank nodes).
// status: statically-checked (syntax + per-statement variable binding); not executed, no Neo4j in the authoring environment.
// It demonstrates how the same enduring product can have a historical study
// intervention and a current formulation without collapsing their identities.

MERGE (elysium:Entity:Organization:LegalEntity {uid: 'hu:org:elysium-health-inc'})
SET elysium.name = 'Elysium Health', elysium.legalName = 'Elysium Health, Inc.', elysium.createdAt = datetime();

MERGE (basis:Entity:Product {uid: 'hu:product:elysium-basis'})
SET basis.name = 'Basis', basis.productKind = 'DIETARY_SUPPLEMENT', basis.createdAt = datetime();

MERGE (basisVariant:Entity:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
SET basisVariant.name = 'Basis — US capsules', basisVariant.jurisdiction = 'US', basisVariant.dosageForm = 'CAPSULE', basisVariant.createdAt = datetime();

MERGE (currentForm:VersionedState:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'})
SET currentForm.versionName = 'Basis current US label observed 2026-07-10', currentForm.jurisdiction = 'US', currentForm.createdAt = datetime();

MERGE (nrE:Entity:IngredientMaterial:BrandedIngredientMaterial {uid: 'hu:material:elysium-nr-e'})
SET nrE.name = 'Elysium NR-E', nrE.brandName = 'NR-E', nrE.materialKind = 'BRANDED_CHEMICAL_MATERIAL', nrE.createdAt = datetime();

MERGE (nrc:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
SET nrc.preferredName = 'Nicotinamide riboside chloride', nrc.createdAt = datetime();

MERGE (pt:Entity:IngredientMaterial {uid: 'hu:material:pterostilbene-unspecified-current-basis'})
SET pt.name = 'PT (Pterostilbene) — current Basis material unresolved', pt.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', pt.createdAt = datetime();

MERGE (basisLabelSource:Entity:Source {uid: 'hu:source:elysium-basis-supplement-facts'})
SET basisLabelSource.canonicalUri = 'https://www.elysiumhealth.com/pages/basis-supplement-facts', basisLabelSource.title = 'Basis Supplement Facts', basisLabelSource.sourceKind = 'MANUFACTURER_LABEL_PAGE', basisLabelSource.createdAt = datetime();

MERGE (basisLabelSnapshot:InformationArtifact:SourceSnapshot:LabelSnapshot {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'})
SET basisLabelSnapshot.canonicalUri = 'https://www.elysiumhealth.com/pages/basis-supplement-facts', basisLabelSnapshot.observedAt = datetime('2026-07-10T00:00:00Z'), basisLabelSnapshot.retrievedAt = datetime('2026-07-10T00:00:00Z'), basisLabelSnapshot.jurisdiction = 'US', basisLabelSnapshot.createdAt = datetime();

MERGE (basisLabelLocator:InformationArtifact:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
SET basisLabelLocator.uri = 'https://www.elysiumhealth.com/pages/basis-supplement-facts', basisLabelLocator.section = 'Supplement Facts', basisLabelLocator.createdAt = datetime();

MATCH (basisLabelSource:Source {uid: 'hu:source:elysium-basis-supplement-facts'}),
      (basisLabelSnapshot:SourceSnapshot {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (basisLabelSource)-[:HAS_SNAPSHOT]->(basisLabelSnapshot)
MERGE (basisLabelSnapshot)-[:HAS_LOCATOR]->(basisLabelLocator);

MATCH (basis:Product {uid: 'hu:product:elysium-basis'}),
      (basisVariant:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (aVariant:Assertion {uid: 'hu:assertion:basis-has-us-variant-2026-07-10'})
SET aVariant.predicate = 'HAS_VARIANT', aVariant.status = 'ACCEPTED', aVariant.recordedAt = datetime(), aVariant.confidence = 0.96
MERGE (aVariant)-[:HAS_SUBJECT]->(basis)
MERGE (aVariant)-[:HAS_OBJECT]->(basisVariant)
MERGE (aVariant)-[:SUPPORTED_BY]->(basisLabelLocator);

MATCH (basisVariant:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}),
      (currentForm:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (aForm:Assertion {uid: 'hu:assertion:basis-variant-current-formulation-2026-07-10'})
SET aForm.predicate = 'HAS_FORMULATION_VERSION', aForm.status = 'ACCEPTED', aForm.recordedAt = datetime(), aForm.confidence = 0.92
MERGE (aForm)-[:HAS_SUBJECT]->(basisVariant)
MERGE (aForm)-[:HAS_OBJECT]->(currentForm)
MERGE (aForm)-[:SUPPORTED_BY]->(basisLabelLocator);

MERGE (nrComponent:VersionedState:IngredientComponent {uid: 'hu:component:basis-current-nr-e'})
SET nrComponent.role = 'DIETARY_INGREDIENT', nrComponent.labelOrder = 1, nrComponent.quantity = 250.0, nrComponent.unitCode = 'mg', nrComponent.quantityBasis = 'PER_SERVING', nrComponent.declaredAs = 'Elysium NR (Nicotinamide Riboside Chloride)', nrComponent.createdAt = datetime();

MERGE (ptComponent:VersionedState:IngredientComponent {uid: 'hu:component:basis-current-pt'})
SET ptComponent.role = 'DIETARY_INGREDIENT', ptComponent.labelOrder = 2, ptComponent.quantity = 50.0, ptComponent.unitCode = 'mg', ptComponent.quantityBasis = 'PER_SERVING', ptComponent.declaredAs = 'PT (Pterostilbene)', ptComponent.createdAt = datetime();

MATCH (currentForm:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}),
      (nrComponent:IngredientComponent {uid: 'hu:component:basis-current-nr-e'}),
      (ptComponent:IngredientComponent {uid: 'hu:component:basis-current-pt'})
MERGE (currentForm)-[:HAS_INGREDIENT_COMPONENT]->(nrComponent)
MERGE (currentForm)-[:HAS_INGREDIENT_COMPONENT]->(ptComponent);

MATCH (nrComponent:IngredientComponent {uid: 'hu:component:basis-current-nr-e'}),
      (nrE:IngredientMaterial {uid: 'hu:material:elysium-nr-e'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (aNrMaterial:Assertion {uid: 'hu:assertion:basis-current-nr-component-uses-nr-e'})
SET aNrMaterial.predicate = 'USES_MATERIAL', aNrMaterial.status = 'ACCEPTED', aNrMaterial.recordedAt = datetime(), aNrMaterial.confidence = 0.90
MERGE (aNrMaterial)-[:HAS_SUBJECT]->(nrComponent)
MERGE (aNrMaterial)-[:HAS_OBJECT]->(nrE)
MERGE (aNrMaterial)-[:SUPPORTED_BY]->(basisLabelLocator);

MATCH (nrE:IngredientMaterial {uid: 'hu:material:elysium-nr-e'}),
      (nrc:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (aNrSubstance:Assertion {uid: 'hu:assertion:nr-e-realizes-nrc'})
SET aNrSubstance.predicate = 'REALIZES_SUBSTANCE', aNrSubstance.status = 'PROPOSED', aNrSubstance.recordedAt = datetime(), aNrSubstance.confidence = 0.88
MERGE (aNrSubstance)-[:HAS_SUBJECT]->(nrE)
MERGE (aNrSubstance)-[:HAS_OBJECT]->(nrc)
MERGE (aNrSubstance)-[:SUPPORTED_BY]->(basisLabelLocator);

// The label supports the declaration. It does not create a measured composition.
MATCH (basisLabelSnapshot:SourceSnapshot {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'})
MERGE (labelDeclaration:InformationArtifact:LabelDeclaration {uid: 'hu:label-declaration:basis-current-nr'})
SET labelDeclaration.verbatimText = 'Elysium NR (Nicotinamide Riboside Chloride)', labelDeclaration.declarationKind = 'DIETARY_INGREDIENT', labelDeclaration.panelOrder = 1, labelDeclaration.createdAt = datetime()
MERGE (basisLabelSnapshot)-[:HAS_DECLARATION]->(labelDeclaration);

MATCH (labelDeclaration:LabelDeclaration {uid: 'hu:label-declaration:basis-current-nr'}),
      (nrE:IngredientMaterial {uid: 'hu:material:elysium-nr-e'}),
      (basisLabelLocator:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (aDeclaredMaterial:Assertion {uid: 'hu:assertion:basis-label-declaration-identifies-nr-e'})
SET aDeclaredMaterial.predicate = 'DECLARATION_IDENTIFIES_MATERIAL', aDeclaredMaterial.status = 'PROPOSED', aDeclaredMaterial.recordedAt = datetime(), aDeclaredMaterial.confidence = 0.88
MERGE (aDeclaredMaterial)-[:HAS_SUBJECT]->(labelDeclaration)
MERGE (aDeclaredMaterial)-[:HAS_OBJECT]->(nrE)
MERGE (aDeclaredMaterial)-[:SUPPORTED_BY]->(basisLabelLocator);

// Advisory relationship is attributed separately and creates no endorsement.
MERGE (advisorySource:Entity:Source {uid: 'hu:source:elysium-advisory-board'})
SET advisorySource.canonicalUri = 'https://www.elysiumhealth.com/pages/advisory-board', advisorySource.title = 'Elysium Scientific Advisory Board', advisorySource.sourceKind = 'ORGANIZATION_WEBPAGE', advisorySource.createdAt = datetime();

// Intentionally absent: (:Person)-[:ENDORSES_PRODUCT]->(basis)
