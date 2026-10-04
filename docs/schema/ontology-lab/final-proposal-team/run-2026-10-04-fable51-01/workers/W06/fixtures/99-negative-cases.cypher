// =====================================================================================================================
// W06 fixture 99: deliberate violations. Every node here has a uid containing ':neg-' and is EXPECTED to be reported
// by the named validator in fixtures/w06-validation.cypher (06-fixtures-and-queries.md lists the expected rows).
// Requires fixtures 00-05 (references CASGEVY, the HORIZON plasmapheresis intervention, TPE and plasma donation).
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================================================================

// N1 (V-W06-01): developmentStage text says approved; no APPROVAL reachable at all.
MERGE (t:Treatment:Entity {uid: 'hu:treatment:neg-stage-approved-no-status'})
SET t.entityType = 'Treatment', t.name = 'NEG stage text approved without status', t.developmentStage = 'FDA Approved',
    t.privacyClass = 'PUBLIC', t.createdAt = datetime('2026-10-04T03:00:00Z');

// N2 (V-W06-03): orphan designation text plus "approved" stage text; only a DESIGNATION is reachable.
MERGE (t:Treatment:Entity {uid: 'hu:treatment:neg-designation-read-as-approval'})
SET t.entityType = 'Treatment', t.name = 'NEG designation read as approval', t.developmentStage = 'Approved (orphan drug)',
    t.orphanDrugDesignation = 'Orphan designation granted', t.privacyClass = 'PUBLIC', t.createdAt = datetime('2026-10-04T03:00:00Z');

MERGE (p:Product:Entity {uid: 'hu:product:neg-designated-only'})
SET p.entityType = 'Product', p.name = 'NEG designated-only product', p.createdAt = datetime('2026-10-04T03:00:00Z');

MERGE (d:OrphanDesignation:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:neg-designation-only'})
SET d.stateType = 'RegulatoryStatus', d.statusKind = 'DESIGNATION', d.jurisdiction = 'US', d.payloadHash = 'sha256:synthetic-neg', d.createdAt = datetime('2026-10-04T03:00:00Z');

MATCH (d:RegulatoryStatus {uid: 'hu:reg-status:neg-designation-only'}), (p:Product {uid: 'hu:product:neg-designated-only'})
MERGE (d)-[r:DESIGNATION_FOR {relationshipUid: 'hu:rel:neg-designation-only'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-neg-designation-only', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T03:00:00Z');

MATCH (t:Treatment {uid: 'hu:treatment:neg-designation-read-as-approval'}), (p:Product {uid: 'hu:product:neg-designated-only'})
MERGE (t)-[r:USES_COMPONENT {relationshipUid: 'hu:rel:neg-designation-read-as-approval-product'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-neg-designation-read-as-approval-product', r.componentRole = 'ADMINISTERED_PRODUCT',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T03:00:00Z');

MATCH (t:Treatment {uid: 'hu:treatment:neg-designation-read-as-approval'}), (p:Product {uid: 'hu:product:neg-designated-only'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-neg-designation-read-as-approval-product'})
SET a.predicate = 'USES_COMPONENT', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN'
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(p);

// N3 (V-W06-04): a shortcut that carries study evidence to a Product through the treatment concept (INV-201 bypass).
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct03745287-exa-cel'}), (p:Product {uid: 'hu:product:casgevy'})
MERGE (si)-[r:EVIDENCE_APPLIES_TO {derivationRule: 'neg-via-treatment-concept'}]->(p)
SET r.derivedFromAssertionUids = ['hu:assertion:w06-nct03745287-exa-cel-instantiates-treatment', 'hu:assertion:w06-exa-cel-uses-component-casgevy'],
    r.negFixture = 'neg-evidence-shortcut';

// N4 (V-W06-05): COMBINATION with fewer than two components.
MERGE (t:Treatment:Entity {uid: 'hu:treatment:neg-combination-single-component'})
SET t.entityType = 'Treatment', t.name = 'NEG cell plus gene therapy mislabeled COMBINATION', t.modalities = ['COMBINATION'],
    t.privacyClass = 'PUBLIC', t.createdAt = datetime('2026-10-04T03:00:00Z');

// N5 (V-W06-06): a trial-specific co-intervention promoted to a concept component on the trial record alone.
MATCH (t:Treatment {uid: 'hu:treatment:delandistrogene-moxeparvovec'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct06597656-title'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-neg-delandistrogene-uses-tpe'})
SET a.predicate = 'USES_COMPONENT', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN'
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (t)-[r:USES_COMPONENT {relationshipUid: 'hu:rel:neg-delandistrogene-uses-tpe'}]->(p)
SET r.assertionUid = a.uid, r.componentRole = 'PREPARATORY_PROCEDURE', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T03:00:00Z');

// N6 (V-W06-07): two procedure definitions merged as the same thing because they share an ICD-10-PCS code.
MATCH (p1:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}), (p2:Procedure {uid: 'hu:procedure:plasma-donation-plasmapheresis'})
MERGE (e:EquivalenceAssessment:EvidenceAssessment {uid: 'hu:assessment:neg-tpe-same-as-donation'})
SET e.assessmentType = 'EquivalenceAssessment', e.equivalenceKind = 'SAME_WORK_DIFFERENT_NAME', e.basis = 'SHARED_CLASSIFICATION_CODE',
    e.methodVersion = 'neg', e.status = 'PROPOSED', e.recordedAt = datetime('2026-10-04T03:00:00Z'), e.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (e)-[:COMPARES_IDENTITIES]->(p1)
MERGE (e)-[:COMPARES_IDENTITIES]->(p2);

// N7 (V-W06-08): an asserted W06 edge without assertionUid / recordedFrom (INV-101).
MATCH (t:Treatment {uid: 'hu:treatment:neg-stage-approved-no-status'}), (c:Condition {uid: 'hu:condition:beta-thalassemia'})
MERGE (t)-[r:TARGETS_CONDITION {relationshipUid: 'hu:rel:neg-uncited-targets'}]->(c)
SET r.intentKind = 'TREATMENT', r.intentBasis = 'NOT_STATED';

// N8 (V-W06-08b): private-personal content on a shared W06 type (must never exist; INV-506).
MERGE (t:Treatment:Entity {uid: 'hu:private-treatment:neg-my-tpe-course'})
SET t.entityType = 'Treatment', t.name = "NEG a person's own TPE course", t.privacyClass = 'PRIVATE_PERSONAL', t.createdAt = datetime('2026-10-04T03:00:00Z');

// N9 (QS-4a with W06 pairs): an OFFERS_PROCEDURE edge whose cited assertion is a LISTS_PROCEDURE (listing as premise).
MATCH (o:Organization {uid: 'hu:org:geekwire'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'})
MERGE (o)-[r:OFFERS_PROCEDURE {relationshipUid: 'hu:rel:neg-offers-from-listing'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-next-health-listing-lists-tpe', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T03:00:00Z');
