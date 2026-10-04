// =====================================================================================================================
// W06 fixture 01: one drug name, three identities (no collapse).
//   Treatment   hu:treatment:exagamglogene-autotemcel   the therapy CONCEPT (proper name exagamglogene autotemcel,
//               abbreviations exa-cel, development code CTX001)                                          [W06]
//   StudyIntervention hu:intervention:nct03745287-exa-cel  what the NCT03745287 arm received ("Exa-cel", registry
//               InterventionType BIOLOGICAL, "a Single Dose")                                             [W09]
//   Product     hu:product:casgevy                       the marketed product CASGEVY (Vertex; STN 125787/125785) [W04]
// Plus: modality list from the label (CELL_THERAPY + GENE_THERAPY), a procedure component (HSC apheresis) stated by
// the label, and NO developer edge: Vertex appears only as study sponsor (registry) and product manufacturer (CBER
// page), neither of which is a DEVELOPS_TREATMENT assertion (forbidden SPONSORS_STUDY -> DEVELOPS_TREATMENT,
// MANUFACTURES_PRODUCT -> DEVELOPS_TREATMENT).
// Requires fixture 00. uid tokens `treatment` and `procedure` are requested (W06-SR-02).
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================================================================

MERGE (t:Treatment:Entity {uid: 'hu:treatment:exagamglogene-autotemcel'})
SET t.id = 'exagamglogene-autotemcel', t.entityType = 'Treatment', t.name = 'exagamglogene autotemcel (exa-cel)',
    t.description = 'Autologous CD34+ hematopoietic stem cells edited by CRISPR/Cas9 at the erythroid-specific enhancer of BCL11A (therapy concept).',
    t.modalities = ['CELL_THERAPY', 'GENE_THERAPY'], t.modality = null,
    t.treatmentClass = 'autologous CRISPR/Cas9 genome-edited CD34+ hematopoietic stem cell therapy',
    t.routeCategory = 'intravenous infusion', t.privacyClass = 'PUBLIC', t.maturity = 'PROVISIONAL',
    t.searchText = 'exagamglogene autotemcel exa-cel CTX001 CRISPR edited autologous hematopoietic stem cell gene therapy',
    t.searchFields = ['name', 'description', 'treatmentClass', 'identifiers.value'],
    t.createdAt = datetime('2026-10-04T02:00:00Z'), t.updatedAt = datetime('2026-10-04T02:00:00Z');

MERGE (p:Procedure:Entity {uid: 'hu:procedure:hsc-apheresis-collection'})
SET p.id = 'hsc-apheresis-collection', p.entityType = 'Procedure', p.name = 'hematopoietic stem cell collection by apheresis',
    p.procedureType = 'apheresis', p.privacyClass = 'PUBLIC', p.maturity = 'PROVISIONAL',
    p.createdAt = datetime('2026-10-04T02:00:00Z'), p.updatedAt = datetime('2026-10-04T02:00:00Z');

// ---- W09 study-side identities (referenced) ----
MERGE (s:Study:Entity {uid: 'hu:study:nct03745287'})
SET s.entityType = 'Study', s.name = 'CLIMB SCD-121 (NCT03745287)', s.title = 'A Phase 1/2/3 Study to Evaluate the Safety and Efficacy of a Single Dose of Autologous CRISPR-Cas9 Modified CD34+ Human Hematopoietic Stem and Progenitor Cells (CTX001) in Subjects With Severe Sickle Cell Disease',
    s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (a:StudyArm:VersionedState {uid: 'hu:arm:nct03745287-exa-cel'})
SET a.stateType = 'StudyArm', a.name = 'Exa-cel (single arm)', a.payloadHash = 'sha256:' + 'synthetic-hu:arm:nct03745287-exa-cel',
    a.privacyClass = 'PUBLIC', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:nct03745287-exa-cel'})
SET si.stateType = 'StudyIntervention', si.name = 'Exa-cel', si.registryInterventionType = 'BIOLOGICAL',
    si.schedule = 'single dose (registry title: "a Single Dose")', si.route = null, si.dosageForm = null,
    si.payloadHash = 'sha256:' + 'synthetic-hu:intervention:nct03745287-exa-cel', si.privacyClass = 'PUBLIC',
    si.createdAt = datetime('2026-10-04T02:00:00Z');

// The dose was not captured (registry excerpt states none; label dosing sentence not returned): quantity stays null
// and verbatimDoseText null = NOT_REPORTED in the captured sources, never zero.
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:nct03745287-exa-cel-cells'})
SET ic.stateType = 'InterventionComponent', ic.quantity = null, ic.unitCode = null, ic.quantityBasis = null,
    ic.massBasis = null, ic.verbatimDoseText = null, ic.doseReportedStatus = 'NOT_REPORTED',
    ic.payloadHash = 'sha256:' + 'synthetic-hu:intervention-component:nct03745287-exa-cel-cells', ic.privacyClass = 'PUBLIC',
    ic.createdAt = datetime('2026-10-04T02:00:00Z');

MATCH (s:Study {uid: 'hu:study:nct03745287'}), (a:StudyArm {uid: 'hu:arm:nct03745287-exa-cel'})
MERGE (s)-[:HAS_ARM]->(a);

MATCH (si:StudyIntervention {uid: 'hu:intervention:nct03745287-exa-cel'}), (ic:InterventionComponent {uid: 'hu:intervention-component:nct03745287-exa-cel-cells'})
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic);

// ---- Identifiers (W00) ----
UNWIND [
  {uid: 'hu:identifier:fda-proper-name-exagamglogene-autotemcel', scheme: 'FDA_BIOLOGIC_PROPER_NAME', value: 'exagamglogene autotemcel', issuer: 'hu:org:us-fda', loc: 'hu:locator:fda-cber-casgevy-header', asserter: 'hu:org:us-fda'},
  {uid: 'hu:identifier:sponsor-code-ctx001', scheme: 'SPONSOR_DEVELOPMENT_CODE', value: 'CTX001', issuer: null, loc: 'hu:locator:ctgov-nct03745287-interventions', asserter: 'hu:org:vertex-pharmaceuticals'}
] AS i
MERGE (n:Identifier:Entity {uid: i.uid})
SET n.entityType = 'Identifier', n.scheme = i.scheme, n.value = i.value, n.issuerUid = i.issuer,
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {id: 'fda-proper-name-exagamglogene-autotemcel', loc: 'hu:locator:fda-cber-casgevy-header', asserter: 'hu:org:us-fda', primary: true},
  {id: 'sponsor-code-ctx001', loc: 'hu:locator:ctgov-nct03745287-interventions', asserter: 'hu:org:vertex-pharmaceuticals', primary: false}
] AS i
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (n:Identifier {uid: 'hu:identifier:' + i.id}),
      (l:SourceLocator {uid: i.loc}), (who:Organization {uid: i.asserter})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-has-identifier-' + i.id})
SET a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(n)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(who)
MERGE (t)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w06-exa-cel-id-' + i.id}]->(n)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = i.primary;

// ---- Modality classification assertions (literal; the node property is the curated projection) ----
UNWIND [
  {v: 'CELL_THERAPY', loc: 'hu:locator:casgevy-pi-cellular-gene-therapy'},
  {v: 'GENE_THERAPY', loc: 'hu:locator:casgevy-pi-gene-therapy'}
] AS m
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (l:SourceLocator {uid: m.loc}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-modality-' + toLower(m.v)})
SET a.predicate = 'HAS_TREATMENT_MODALITY', a.valueString = m.v, a.status = 'ACCEPTED',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.polarity = 'POSITIVE', a.predicateClass = 'OTHER',
    a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda);

// ---- USES_COMPONENT: ADMINISTERED_PRODUCT (CBER page header ties proper name to tradename) ----
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (p:Product {uid: 'hu:product:casgevy'}),
      (l:SourceLocator {uid: 'hu:locator:fda-cber-casgevy-header'}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-uses-component-casgevy'})
SET a.predicate = 'USES_COMPONENT', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (t)-[r:USES_COMPONENT {relationshipUid: 'hu:rel:w06-exa-cel-uses-casgevy'}]->(p)
SET r.assertionUid = a.uid, r.componentRole = 'ADMINISTERED_PRODUCT',
    r.roleTextVerbatim = 'Proper Name: exagamglogene autotemcel; Tradename: CASGEVY',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- USES_COMPONENT: STARTING_MATERIAL_COLLECTION (label: "obtained via apheresis procedure(s)") ----
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (p:Procedure {uid: 'hu:procedure:hsc-apheresis-collection'}),
      (l:SourceLocator {uid: 'hu:locator:casgevy-pi-apheresis'}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-uses-component-hsc-apheresis'})
SET a.predicate = 'USES_COMPONENT', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (t)-[r:USES_COMPONENT {relationshipUid: 'hu:rel:w06-exa-cel-uses-hsc-apheresis'}]->(p)
SET r.assertionUid = a.uid, r.componentRole = 'STARTING_MATERIAL_COLLECTION',
    r.roleTextVerbatim = "prepared from the patient's own HSCs, which are obtained via apheresis procedure(s)",
    r.orderIndex = 1, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- TARGETS_CONDITION: label restatement (intent), never the approved indication itself ----
UNWIND [
  {c: 'sickle-cell-disease', txt: 'sickle cell disease (SCD) with recurrent vaso-occlusive crises (VOCs)'},
  {c: 'transfusion-dependent-beta-thalassemia', txt: 'transfusion-dependent β-thalassemia (TDT)'}
] AS x
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (c:Condition {uid: 'hu:condition:' + x.c}),
      (l:SourceLocator {uid: 'hu:locator:casgevy-pi-gene-therapy'}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-targets-' + x.c})
SET a.predicate = 'TARGETS_CONDITION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.jurisdiction = 'US', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (t)-[r:TARGETS_CONDITION {relationshipUid: 'hu:rel:w06-exa-cel-targets-' + x.c}]->(c)
SET r.assertionUid = a.uid, r.intentKind = 'TREATMENT', r.intentBasis = 'REGULATORY_LABEL_RESTATEMENT',
    r.indicationTextVerbatim = x.txt, r.patientSubsetText = 'patients aged 2 years and older',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- W09 side: ASSIGNS_INTERVENTION (asserted) and the requested INSTANTIATES_TREATMENT ----
MATCH (arm:StudyArm {uid: 'hu:arm:nct03745287-exa-cel'}), (si:StudyIntervention {uid: 'hu:intervention:nct03745287-exa-cel'}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct03745287-interventions'}), (v:Organization {uid: 'hu:org:vertex-pharmaceuticals'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-nct03745287-assigns-exa-cel'})
SET a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(arm)
MERGE (a)-[:HAS_OBJECT]->(si)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(v)
MERGE (arm)-[r:ASSIGNS_INTERVENTION {relationshipUid: 'hu:rel:w06-nct03745287-assigns-exa-cel'}]->(si)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (si:StudyIntervention {uid: 'hu:intervention:nct03745287-exa-cel'}), (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct03745287-interventions'}), (v:Organization {uid: 'hu:org:vertex-pharmaceuticals'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-nct03745287-exa-cel-instantiates-treatment'})
SET a.predicate = 'INSTANTIATES_TREATMENT', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(si)
MERGE (a)-[:HAS_OBJECT]->(t)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(v)
MERGE (si)-[r:INSTANTIATES_TREATMENT {relationshipUid: 'hu:rel:w06-nct03745287-exa-cel-instantiates'}]->(t)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// ---- Roles that are NOT developer assertions (kept as assertions only, no DEVELOPS_TREATMENT edge) ----
MATCH (v:Organization {uid: 'hu:org:vertex-pharmaceuticals'}), (s:Study {uid: 'hu:study:nct03745287'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct03745287-interventions'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-vertex-sponsors-nct03745287'})
SET a.predicate = 'SPONSORS_STUDY', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'ROLE', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(s)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (v:Organization {uid: 'hu:org:vertex-pharmaceuticals'}), (p:Product {uid: 'hu:product:casgevy'}), (l:SourceLocator {uid: 'hu:locator:fda-cber-casgevy-header'}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-vertex-manufactures-casgevy'})
SET a.predicate = 'MANUFACTURES_PRODUCT', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'ROLE', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda);

// ---- Procedure identifiers: ICD-10-PCS codes classify performances (Single / Multiple); both apply. The FY2027 code
// set (2026-10-01..2027-09-30) is the observed set, not the mapping's valid time, so both bounds stay null/UNKNOWN. ----
UNWIND ['6A550ZV', '6A551ZV'] AS code
MERGE (n:Identifier:Entity {uid: 'hu:identifier:icd10pcs-' + toLower(code)})
SET n.entityType = 'Identifier', n.scheme = 'ICD-10-PCS', n.value = code, n.codeSetVersion = 'FY2027',
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND ['6A550ZV', '6A551ZV'] AS code
MATCH (p:Procedure {uid: 'hu:procedure:hsc-apheresis-collection'}), (n:Identifier {uid: 'hu:identifier:icd10pcs-' + toLower(code)}), (l:SourceLocator {uid: 'hu:locator:icd10pcs-6A55'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-hsc-apheresis-icd10pcs-' + toLower(code)})
SET a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(n)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w06-hsc-apheresis-' + toLower(code)}]->(n)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = false;
