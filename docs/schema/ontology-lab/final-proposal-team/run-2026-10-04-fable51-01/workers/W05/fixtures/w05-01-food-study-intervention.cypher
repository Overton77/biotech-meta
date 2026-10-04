// =====================================================================================================================
// W05 fixture 01: food study intervention (SUBRANUT, NCT03111355) -> InterventionComponent -> FoodItem, plus USDA FDC
// reference composition (FDC 170569, SR Legacy) for the dried, unblanched variant of the food.
// Public facts: ClinicalTrials.gov API v2 armsInterventionsModule (retrieved through Firecrawl 2026-10-04) and the FDC
// API record 170569 (abridged + full, Firecrawl relay 2026-10-04). Snapshot hashes are sha256 over the stored excerpt
// files in ../excerpts/ (contentHashBasis STORED_EXCERPT_TEXT); the curation agent/activity are SYNTHETIC.
// Pending seams used here (see seam-requests.yaml): W05-SR-01 (token), W05-SR-02 (FoodItem as IngredientMaterial
// specialization, materialKind FOOD), W05-SR-04 (composition qualifiers on QUANTITATIVELY_CONTAINS).
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'. Fixed timestamps.
// =====================================================================================================================

// ---- 1. provenance actors ------------------------------------------------------------------------------------------
MERGE (a:Agent:Entity {uid: 'hu:agent:w05-curation'})
SET a.entityType = 'Agent', a.name = 'W05 fixture curation (synthetic)', a.agentKind = 'MANUAL_AGENT', a.createdAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC';

MATCH (ag:Agent {uid: 'hu:agent:w05-curation'})
MERGE (act:Activity:Occurrence {uid: 'hu:activity:w05-curation-2026-10-04'})
SET act.occurrenceType = 'Activity', act.activityKind = 'EXTRACTION', act.methodVersion = 'w05-manual-v1',
    act.startedAt = datetime('2026-10-04T01:30:00Z'), act.endedAt = datetime('2026-10-04T02:00:00Z'), act.createdAt = datetime('2026-10-04T02:00:00Z'), act.privacyClass = 'PUBLIC'
MERGE (act)-[:WAS_ASSOCIATED_WITH]->(ag);

MERGE (o:Organization:Entity {uid: 'hu:org:usda-ars'})
SET o.entityType = 'Organization', o.name = 'USDA Agricultural Research Service', o.createdAt = datetime('2026-10-04T02:00:00Z'), o.privacyClass = 'PUBLIC';

// ---- 2. sources, snapshots, locators -------------------------------------------------------------------------------
MERGE (s:Source:Entity {uid: 'hu:source:fdc-api-food-170569'})
SET s.entityType = 'Source', s.canonicalUri = 'https://api.nal.usda.gov/fdc/v1/food/170569', s.sourceKind = 'TERMINOLOGY_RECORD',
    s.publisher = 'USDA Agricultural Research Service, FoodData Central', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:fdc-api-food-170569'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fdc-170569-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T01:01:00Z'),
    sn.observedAt = datetime('2026-10-04T01:01:00Z'), sn.publishedAt = datetime('2019-04-01T00:00:00Z'),
    sn.contentHash = 'sha256:86d97e417b00933a34777cc446364844f244d21b16aa9abded7188ea80ebfb8f', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.captureNote = 'full JSON relayed by Firecrawl; stored excerpt of selected fields; direct API call blocked (403)',
    sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:fdc-170569-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:fdc-170569-selenium-row'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'foodNutrients[id=1534106] (nutrient number 317 "Selenium, Se")',
    l.exact = '"amount":1917.00000000,"dataPoints":15,"max":2740.00000000,"min":136.00000000', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:fdc-170569-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:fdc-170569-folic-acid-row'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'foodNutrients[id=1534052] (nutrient number 431 "Folic acid")',
    l.exact = '"code":"Z","description":"Assumed zero (Insignificant amount or not naturally occurring in a food, such as fiber in meat)"', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:fdc-170569-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:fdc-170569-dha-row'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'foodNutrients[id=1534053] (nutrient number 621 "PUFA 22:6 n-3 (DHA)")',
    l.exact = '"id":1534053,"amount":0E-8,"dataPoints":0', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:fdc-170569-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:fdc-170569-description'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION', l.section = 'description',
    l.exact = 'Nuts, brazilnuts, dried, unblanched', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (s:Source:Entity {uid: 'hu:source:ctgov-api-nct03111355'})
SET s.entityType = 'Source', s.canonicalUri = 'https://clinicaltrials.gov/api/v2/studies/NCT03111355', s.sourceKind = 'REGULATORY_RECORD',
    s.publisher = 'U.S. National Library of Medicine, ClinicalTrials.gov', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:ctgov-api-nct03111355'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct03111355-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T01:03:00Z'),
    sn.observedAt = datetime('2026-10-04T01:03:00Z'), sn.publishedAt = datetime('2018-06-01T00:00:00Z'),
    sn.contentHash = 'sha256:1149997a5ced0290e9711c379c5660bfddce8100c092551a00d722983b016fdf', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct03111355-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nct03111355-intervention-description'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'protocolSection.armsInterventionsModule.interventions[0].description',
    l.exact = 'one nut a day for 2 months, no intervention for 2 months', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---- 3. food identities --------------------------------------------------------------------------------------------
// Base food: preparation not resolved (what the trial registry names). Variant: the FDC SR Legacy food.
MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut'})
SET f.id = 'food-brazil-nut', f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Brazil nut (preparation not specified)',
    f.scientificNameVerbatim = 'Bertholletia excelsa', f.processingMethods = NULL, f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut-dried-unblanched'})
SET f.id = 'food-brazil-nut-dried-unblanched', f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Brazil nuts, dried, unblanched',
    f.descriptionVerbatim = 'Nuts, brazilnuts, dried, unblanched', f.foodGroup = 'Nut and Seed Products', f.foodGroupSystem = 'SR_FOOD_CATEGORY',
    f.processingMethods = ['dried', 'unblanched'], f.scientificNameVerbatim = 'Bertholletia excelsa', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'})
MERGE (i:Identifier:Entity {uid: 'hu:identifier:fdc-id-170569'})
SET i.entityType = 'Identifier', i.scheme = 'FDC_ID', i.issuer = 'USDA FoodData Central', i.value = '170569', i.scopeNote = 'SR Legacy record; unique within FDC', i.createdAt = datetime('2026-10-04T02:00:00Z'), i.privacyClass = 'PUBLIC'
MERGE (f)-[r:HAS_IDENTIFIER]->(i)
SET r.relationshipUid = 'hu:rel:has-identifier-fdc-170569', r.assertionUid = 'hu:assertion:fdc-170569-identifies-food',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;

MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'})
MERGE (i:Identifier:Entity {uid: 'hu:identifier:sr-ndb-12078'})
SET i.entityType = 'Identifier', i.scheme = 'NDB_NUMBER', i.issuer = 'USDA ARS Standard Reference', i.value = '12078', i.createdAt = datetime('2026-10-04T02:00:00Z'), i.privacyClass = 'PUBLIC'
MERGE (f)-[r:HAS_IDENTIFIER]->(i)
SET r.relationshipUid = 'hu:rel:has-identifier-ndb-12078', r.assertionUid = 'hu:assertion:fdc-170569-ndb-number',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = false;

MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (l:SourceLocator {uid: 'hu:locator:fdc-170569-description'}),
      (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}), (ag:Agent {uid: 'hu:agent:w05-curation'}), (i:Identifier {uid: 'hu:identifier:fdc-id-170569'})
MERGE (a:Assertion {uid: 'hu:assertion:fdc-170569-identifies-food'})
SET a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.predicateClass = 'IDENTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a01'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(i) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(ag);

// VARIANT_OF: curated, asserted (BellLabs curation is the asserter; FDC does not state the base-variant link).
MATCH (v:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (b:FoodItem {uid: 'hu:material:food-brazil-nut'}),
      (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}), (ag:Agent {uid: 'hu:agent:w05-curation'}), (l:SourceLocator {uid: 'hu:locator:fdc-170569-description'})
MERGE (a:Assertion {uid: 'hu:assertion:brazil-nut-dried-unblanched-variant-of-brazil-nut'})
SET a.predicate = 'VARIANT_OF', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'INFERRED_FROM_MEASUREMENT',
    a.predicateClass = 'IDENTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a02'
MERGE (a)-[:HAS_SUBJECT]->(v) MERGE (a)-[:HAS_OBJECT]->(b) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (v)-[r:VARIANT_OF]->(b)
SET r.relationshipUid = 'hu:rel:variant-of-brazil-nut-dried-unblanched', r.assertionUid = a.uid, r.variantKind = 'PREPARATION',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- 4. composition (W02 relationship types; W05-SR-04 qualifiers) -------------------------------------------------
MERGE (s:ChemicalSubstance:Entity {uid: 'hu:substance:selenium'})
SET s.entityType = 'ChemicalSubstance', s.preferredName = 'selenium', s.name = 'selenium', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MERGE (s:ChemicalSubstance:Entity {uid: 'hu:substance:folic-acid'})
SET s.entityType = 'ChemicalSubstance', s.preferredName = 'folic acid', s.name = 'folic acid', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MERGE (s:ChemicalSubstance:Entity {uid: 'hu:substance:docosahexaenoic-acid'})
SET s.entityType = 'ChemicalSubstance', s.preferredName = 'docosahexaenoic acid', s.name = 'DHA', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

// Analytical value with spread: 1917 ug per 100 g edible portion, n = 15, min 136, max 2740.
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (se:ChemicalSubstance {uid: 'hu:substance:selenium'}),
      (l:SourceLocator {uid: 'hu:locator:fdc-170569-selenium-row'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}),
      (o:Organization {uid: 'hu:org:usda-ars'})
MERGE (a:Assertion {uid: 'hu:assertion:fdc-170569-selenium-per-100g'})
SET a.predicate = 'QUANTITATIVELY_CONTAINS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'DIRECT_MEASUREMENT',
    a.predicateClass = 'QUANTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a03'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(se) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (f)-[r:QUANTITATIVELY_CONTAINS {relationshipUid: 'hu:rel:qc-fdc-170569-selenium'}]->(se)
SET r.assertionUid = a.uid,
    r.quantity = 1917.0, r.unitCode = 'ug', r.basis = 'PER_100_G', r.referenceAmount = 100.0, r.referenceUnitCode = 'g',
    r.portionBasis = 'EDIBLE_PORTION', r.valueDerivation = 'ANALYTICAL', r.sourceDerivationCode = 'A',
    r.dataPoints = 15, r.minValue = 136.0, r.maxValue = 2740.0,
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');


// Assumed zero (FDC derivation Z, dataPoints 0): an asserted CALCULATED value, not a measurement of absence.
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (fa:ChemicalSubstance {uid: 'hu:substance:folic-acid'}),
      (l:SourceLocator {uid: 'hu:locator:fdc-170569-folic-acid-row'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}),
      (o:Organization {uid: 'hu:org:usda-ars'})
MERGE (a:Assertion {uid: 'hu:assertion:fdc-170569-folic-acid-assumed-zero'})
SET a.predicate = 'QUANTITATIVELY_CONTAINS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CALCULATED',
    a.derivationRule = 'fdc-derivation-Z: assumed zero (insignificant amount or not naturally occurring)',
    a.predicateClass = 'QUANTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a04'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(fa) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (f)-[r:QUANTITATIVELY_CONTAINS {relationshipUid: 'hu:rel:qc-fdc-170569-folic-acid'}]->(fa)
SET r.assertionUid = a.uid,
    r.quantity = 0.0, r.unitCode = 'ug', r.basis = 'PER_100_G', r.referenceAmount = 100.0, r.referenceUnitCode = 'g',
    r.portionBasis = 'EDIBLE_PORTION', r.valueDerivation = 'ASSUMED_ZERO', r.sourceDerivationCode = 'Z', r.dataPoints = 0,
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// DHA row: amount 0E-8, dataPoints 0, no derivation element. Captured as an UNRESOLVED assertion; NO edge is projected
// (a zero without derivation is neither measured absence nor assumed zero; V-W05-07 flags any projected edge).
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (d:ChemicalSubstance {uid: 'hu:substance:docosahexaenoic-acid'}),
      (l:SourceLocator {uid: 'hu:locator:fdc-170569-dha-row'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}),
      (o:Organization {uid: 'hu:org:usda-ars'})
MERGE (a:Assertion {uid: 'hu:assertion:fdc-170569-dha-zero-underived'})
SET a.predicate = 'QUANTITATIVELY_CONTAINS', a.status = 'UNRESOLVED', a.polarity = 'UNKNOWN',
    a.predicateClass = 'QUANTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a05',
    a.extractionMethod = 'manual; source row has amount 0 with dataPoints 0 and no derivation code'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(d) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(o);

// ---- 5. study, arm, intervention, component -> FoodItem (W09 types) ------------------------------------------------
MERGE (st:Study:Entity {uid: 'hu:study:subranut-nct03111355'})
SET st.entityType = 'Study', st.title = 'Genetic Variants in Selenoprotein Genes and Gender Influence Biomarkers of Se Status in Response to Brazil Nut Supplementation in Healthy Brazilians',
    st.name = 'SUBRANUT', st.createdAt = datetime('2026-10-04T02:00:00Z'), st.privacyClass = 'PUBLIC';

MATCH (st:Study {uid: 'hu:study:subranut-nct03111355'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:subranut-brazil-nut-supplementation'})
SET arm.stateType = 'StudyArm', arm.name = 'Brazil Nut supplementation', arm.armType = 'EXPERIMENTAL',
    arm.payloadHash = 'sha256:synthetic-w05-arm-subranut', arm.createdAt = datetime('2026-10-04T02:00:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm);

MATCH (arm:StudyArm {uid: 'hu:arm:subranut-brazil-nut-supplementation'})
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:subranut-brazil-nut'})
SET si.stateType = 'StudyIntervention', si.name = 'Brazil nut', si.route = 'ORAL', si.dosageForm = 'WHOLE_FOOD',
    si.schedule = 'one nut a day for 2 months, no intervention for 2 months', si.dosesPerDay = 1, si.durationIso = 'P2M',
    si.registryInterventionType = 'DIETARY_SUPPLEMENT',
    si.payloadHash = 'sha256:synthetic-w05-si-subranut', si.createdAt = datetime('2026-10-04T02:00:00Z'), si.privacyClass = 'PUBLIC'
MERGE (arm)-[r:ASSIGNS_INTERVENTION]->(si)
SET r.relationshipUid = 'hu:rel:assigns-subranut', r.assertionUid = 'hu:assertion:subranut-arm-assigns-brazil-nut',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// Count-based dose: one nut per day. Mass and selenium amount are NOT stated by the registry.
MATCH (si:StudyIntervention {uid: 'hu:intervention:subranut-brazil-nut'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'}),
      (l:SourceLocator {uid: 'hu:locator:nct03111355-intervention-description'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:subranut-brazil-nut-1-per-day'})
SET ic.stateType = 'InterventionComponent', ic.quantity = 1.0, ic.unitCode = '{nut}', ic.quantityBasis = 'PER_DAY', ic.massBasis = 'UNSPECIFIED',
    ic.verbatimDoseText = 'one nut a day for 2 months', ic.payloadHash = 'sha256:synthetic-w05-ic-subranut', ic.createdAt = datetime('2026-10-04T02:00:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:subranut-component-uses-brazil-nut'})
SET a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a06'
MERGE (a)-[:HAS_SUBJECT]->(ic) MERGE (a)-[:HAS_OBJECT]->(f) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (ic)-[r:USES_INTERVENTION_MATERIAL]->(f)
SET r.relationshipUid = 'hu:rel:uses-material-subranut', r.assertionUid = a.uid, r.asReportedName = 'Brazil nut',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- 6. assertions behind the remaining asserted edges --------------------------------------------------------------
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (i:Identifier {uid: 'hu:identifier:sr-ndb-12078'}),
      (l:SourceLocator {uid: 'hu:locator:fdc-170569-description'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'}), (ag:Agent {uid: 'hu:agent:w05-curation'})
MERGE (a:Assertion {uid: 'hu:assertion:fdc-170569-ndb-number'})
SET a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.predicateClass = 'IDENTITY', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a07'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(i) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act) MERGE (a)-[:ASSERTED_BY]->(ag);

MATCH (arm:StudyArm {uid: 'hu:arm:subranut-brazil-nut-supplementation'}), (si:StudyIntervention {uid: 'hu:intervention:subranut-brazil-nut'}),
      (l:SourceLocator {uid: 'hu:locator:nct03111355-intervention-description'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:subranut-arm-assigns-brazil-nut'})
SET a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-a08'
MERGE (a)-[:HAS_SUBJECT]->(arm) MERGE (a)-[:HAS_OBJECT]->(si) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act);
