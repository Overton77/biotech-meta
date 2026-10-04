// =====================================================================================================================
// W05 fixture 02: dietary-pattern arm versus diet-plus-food arm (DICA-NUTS, NCT03728127). Composite intervention:
// the StudyIntervention FOLLOWS_INTERVENTION_DEFINITION (W09) the "Brazilian cardioprotective diet prescription" (a W16
// Protocol whose content the registry does not give) and has three material components of 10 g/day each (peanuts,
// cashew nuts, Brazil nuts; no preparation stated, so components target the base FoodItems). The comparator arm follows
// the same definition and has no material component. The registry's intervention type DIETARY_SUPPLEMENT is kept
// verbatim and creates no Product (forbidden implication REGISTRY_INTERVENTION_TYPE -> PRODUCT_KIND).
// Public facts: ClinicalTrials.gov API v2 armsInterventionsModule via Firecrawl, 2026-10-04.
// Every statement binds its own nodes by uid; MERGE of shared nodes repeats full labels so the file runs alone.
// =====================================================================================================================

MERGE (a:Agent:Entity {uid: 'hu:agent:w05-curation'})
SET a.entityType = 'Agent', a.name = 'W05 fixture curation (synthetic)', a.agentKind = 'MANUAL_AGENT', a.createdAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC';

MERGE (act:Activity:Occurrence {uid: 'hu:activity:w05-curation-2026-10-04'})
SET act.occurrenceType = 'Activity', act.activityKind = 'EXTRACTION', act.methodVersion = 'w05-manual-v1', act.createdAt = datetime('2026-10-04T02:00:00Z'), act.privacyClass = 'PUBLIC';

MERGE (s:Source:Entity {uid: 'hu:source:ctgov-api-nct03728127'})
SET s.entityType = 'Source', s.canonicalUri = 'https://clinicaltrials.gov/api/v2/studies/NCT03728127', s.sourceKind = 'REGULATORY_RECORD',
    s.publisher = 'U.S. National Library of Medicine, ClinicalTrials.gov', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:ctgov-api-nct03728127'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct03728127-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T01:02:00Z'),
    sn.observedAt = datetime('2026-10-04T01:02:00Z'), sn.publishedAt = datetime('2023-03-01T00:00:00Z'),
    sn.contentHash = 'sha256:1149997a5ced0290e9711c379c5660bfddce8100c092551a00d722983b016fdf', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.captureNote = 'hash covers excerpts/ctgov-excerpt.txt, which stores both NCT03728127 and NCT03111355 fields',
    sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct03728127-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nct03728127-dcbn-intervention'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'protocolSection.armsInterventionsModule.interventions[1].description',
    l.exact = 'Brazilian cardioprotective diet plus 30g/day of nuts (10g of peanuts, 10g of cashew nuts and 10g of Brazil nuts)', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct03728127-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nct03728127-dcb-intervention'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION',
    l.section = 'protocolSection.armsInterventionsModule.interventions[0].description',
    l.exact = 'Brazilian cardioprotective diet prescription', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---- foods (base concepts; preparation not stated by the registry) ----
MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut'})
SET f.id = 'food-brazil-nut', f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Brazil nut (preparation not specified)', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-peanut'})
SET f.id = 'food-peanut', f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Peanut (preparation not specified)', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-cashew-nut'})
SET f.id = 'food-cashew-nut', f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Cashew nut (preparation not specified)', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

// ---- the diet prescription is a defined regimen (W16 Protocol); its content is not in the registry ----
MERGE (p:Protocol:Entity {uid: 'hu:protocol:dicabr-brazilian-cardioprotective-diet'})
SET p.entityType = 'Protocol', p.name = 'Brazilian Cardioprotective Diet (DicaBr)', p.protocolType = 'DIETARY_PATTERN',
    p.notReportedFields = ['editionContent'], p.createdAt = datetime('2026-10-04T02:00:00Z'), p.privacyClass = 'PUBLIC';

// ---- study and arms ----
MERGE (st:Study:Entity {uid: 'hu:study:dica-nuts-nct03728127'})
SET st.entityType = 'Study', st.name = 'DICA-NUTS', st.createdAt = datetime('2026-10-04T02:00:00Z'), st.privacyClass = 'PUBLIC';

MATCH (st:Study {uid: 'hu:study:dica-nuts-nct03728127'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:dica-nuts-dcbn'})
SET arm.stateType = 'StudyArm', arm.name = 'DicaBr group and nuts (DCBN)', arm.armType = 'EXPERIMENTAL', arm.payloadHash = 'sha256:synthetic-w05-arm-dcbn', arm.createdAt = datetime('2026-10-04T02:00:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm);

MATCH (st:Study {uid: 'hu:study:dica-nuts-nct03728127'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:dica-nuts-dcb'})
SET arm.stateType = 'StudyArm', arm.name = 'DicaBr group (DCB)', arm.armType = 'ACTIVE_COMPARATOR', arm.payloadHash = 'sha256:synthetic-w05-arm-dcb', arm.createdAt = datetime('2026-10-04T02:00:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm);

MATCH (arm:StudyArm {uid: 'hu:arm:dica-nuts-dcbn'})
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:dica-nuts-diet-plus-nuts'})
SET si.stateType = 'StudyIntervention', si.name = 'Brazilian cardioprotective diet plus 30g/day of mixed nuts', si.route = 'ORAL',
    si.schedule = '30 g/day of nuts with the diet prescription', si.durationIso = 'P16W', si.registryInterventionType = 'DIETARY_SUPPLEMENT',
    si.payloadHash = 'sha256:synthetic-w05-si-dcbn', si.createdAt = datetime('2026-10-04T02:00:00Z'), si.privacyClass = 'PUBLIC'
MERGE (arm)-[r:ASSIGNS_INTERVENTION]->(si)
SET r.relationshipUid = 'hu:rel:assigns-dcbn', r.assertionUid = 'hu:assertion:dcbn-assigns', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (arm:StudyArm {uid: 'hu:arm:dica-nuts-dcb'})
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:dica-nuts-diet-only'})
SET si.stateType = 'StudyIntervention', si.name = 'Brazilian cardioprotective diet', si.route = 'ORAL', si.durationIso = 'P16W',
    si.registryInterventionType = 'DIETARY_SUPPLEMENT', si.payloadHash = 'sha256:synthetic-w05-si-dcb', si.createdAt = datetime('2026-10-04T02:00:00Z'), si.privacyClass = 'PUBLIC'
MERGE (arm)-[r:ASSIGNS_INTERVENTION]->(si)
SET r.relationshipUid = 'hu:rel:assigns-dcb', r.assertionUid = 'hu:assertion:dcb-assigns', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (arm:StudyArm {uid: 'hu:arm:dica-nuts-dcbn'}), (si:StudyIntervention {uid: 'hu:intervention:dica-nuts-diet-plus-nuts'}), (l:SourceLocator {uid: 'hu:locator:nct03728127-dcbn-intervention'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:dcbn-assigns'})
SET a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-b01'
MERGE (a)-[:HAS_SUBJECT]->(arm) MERGE (a)-[:HAS_OBJECT]->(si) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (arm:StudyArm {uid: 'hu:arm:dica-nuts-dcb'}), (si:StudyIntervention {uid: 'hu:intervention:dica-nuts-diet-only'}), (l:SourceLocator {uid: 'hu:locator:nct03728127-dcb-intervention'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:dcb-assigns'})
SET a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-b02'
MERGE (a)-[:HAS_SUBJECT]->(arm) MERGE (a)-[:HAS_OBJECT]->(si) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act);

// ---- the diet prescription is followed by both interventions (W09 FOLLOWS_INTERVENTION_DEFINITION, asserted) ----
// W09's InterventionDefinitionTarget lists ProtocolEdition but not Protocol; the registry gives no edition content, so the
// target is the Protocol identity (W05-SR-06 asks W09 to admit Protocol when no edition is known).
UNWIND [['hu:intervention:dica-nuts-diet-plus-nuts', 'hu:locator:nct03728127-dcbn-intervention', 'b03'],
        ['hu:intervention:dica-nuts-diet-only', 'hu:locator:nct03728127-dcb-intervention', 'b04']] AS row
MATCH (si:StudyIntervention {uid: row[0]}), (p:Protocol {uid: 'hu:protocol:dicabr-brazilian-cardioprotective-diet'}),
      (l:SourceLocator {uid: row[1]}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:' + row[2] + '-follows-dicabr'})
SET a.predicate = 'FOLLOWS_INTERVENTION_DEFINITION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-' + row[2] + '-a'
MERGE (a)-[:HAS_SUBJECT]->(si) MERGE (a)-[:HAS_OBJECT]->(p) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (si)-[r:FOLLOWS_INTERVENTION_DEFINITION]->(p)
SET r.relationshipUid = 'hu:rel:follows-definition-' + row[2], r.assertionUid = a.uid,
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- food components (DCBN only): 10 g/day each, preparation unresolved ----
UNWIND [['hu:intervention-component:dcbn-peanut-10g', 'hu:material:food-peanut', 'peanuts', 'b05'],
        ['hu:intervention-component:dcbn-cashew-10g', 'hu:material:food-cashew-nut', 'cashew nuts', 'b06'],
        ['hu:intervention-component:dcbn-brazil-nut-10g', 'hu:material:food-brazil-nut', 'Brazil nuts', 'b07']] AS row
MATCH (si:StudyIntervention {uid: 'hu:intervention:dica-nuts-diet-plus-nuts'}), (f:FoodItem {uid: row[1]}),
      (l:SourceLocator {uid: 'hu:locator:nct03728127-dcbn-intervention'}), (act:Activity {uid: 'hu:activity:w05-curation-2026-10-04'})
MERGE (ic:InterventionComponent:VersionedState {uid: row[0]})
SET ic.stateType = 'InterventionComponent', ic.quantity = 10.0, ic.unitCode = 'g', ic.quantityBasis = 'PER_DAY', ic.massBasis = 'MATERIAL_AS_IS',
    ic.verbatimDoseText = '10g of ' + row[2], ic.payloadHash = 'sha256:synthetic-w05-' + row[3], ic.createdAt = datetime('2026-10-04T02:00:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:' + row[3] + '-uses-material'})
SET a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-' + row[3] + '-a'
MERGE (a)-[:HAS_SUBJECT]->(ic) MERGE (a)-[:HAS_OBJECT]->(f) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (ic)-[r:USES_INTERVENTION_MATERIAL]->(f)
SET r.relationshipUid = 'hu:rel:uses-material-' + row[3], r.assertionUid = a.uid, r.asReportedName = row[2],
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
