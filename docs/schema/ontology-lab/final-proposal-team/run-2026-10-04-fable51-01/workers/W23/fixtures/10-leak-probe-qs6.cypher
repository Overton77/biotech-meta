// W23 fixture 10: QS-6 private-leak probe (NEGATIVE; load 00-shared-base.cypher first; disposable test database only).
// Every statement below writes a DEFECT on purpose. Nodes here deliberately do NOT carry the fixture-only :PrivateRecord
// label: they simulate private-store records that reached the shared graph in production, which is exactly what
// V-113 ... V-116, V-520, V-521, V-524 and V-W23-04/09/10 must detect. Expected detector rows: 06-fixtures-and-queries.md.
// CQ-AX-12, CQ-PC-08, INV-105, INV-506. All values synthetic.

// ---- LEAK-1: a shared node wrongly linked to a hu:private- record (and a private bridge between two shared products) ----
MERGE (uc:UserContext:Entity {uid: 'hu:private-user-context:w23-leak-0001'})
SET uc.entityType = 'USER_CONTEXT', uc.privacyClass = 'private-personal', uc.createdAt = datetime('2026-04-09T18:00:00Z');

MERGE (p:Product:Entity {uid: 'hu:product:w23-calmroot'})
SET p.id = 'w23-calmroot', p.entityType = 'PRODUCT', p.name = 'CalmRoot Glycine (synthetic)', p.privacyClass = 'PUBLIC',
    p.createdAt = datetime('2026-03-02T10:00:00Z');

MATCH (uc:UserContext {uid: 'hu:private-user-context:w23-leak-0001'})
MERGE (ea:EvidenceApplicability:EvidenceAssessment {uid: 'hu:applicability:w23-leak-personal-applicability'})
SET ea.id = 'w23-leak-personal-applicability', ea.assessmentType = 'EVIDENCE_APPLICABILITY', ea.methodVersion = 'applicability-0.3',
    ea.status = 'ACCEPTED', ea.privacyClass = 'PUBLIC', ea.recordedAt = datetime('2026-04-10T09:00:00Z'), ea.createdAt = datetime('2026-04-10T09:00:00Z')
MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(uc);

// the bridge: two incoming edges from a private node onto two shared products (co-interest leak through a path)
MATCH (uc:UserContext {uid: 'hu:private-user-context:w23-leak-0001'}), (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}),
      (p:Product {uid: 'hu:product:w23-calmroot'})
MERGE (uc)-[:INTERESTED_IN]->(v)
MERGE (uc)-[:INTERESTED_IN]->(p);

// LEAK-1b: a private measurement collapsed into a public Observation, with an upper-case private class spelling
MERGE (m:Observation:PersonalMeasurement:InformationArtifact {uid: 'hu:private-personal-measurement:w23-leak-m1'})
SET m.artifactType = 'PERSONAL_MEASUREMENT', m.valueNumber = 2.1, m.unitCode = 'mg/dL', m.privacyClass = 'PRIVATE_PERSONAL',
    m.createdAt = datetime('2026-05-22T12:00:00Z');

// ---- LEAK-2: private uid values stored in shared properties ----
// 2a string node property; 2b list node property
MATCH (p:Product {uid: 'hu:product:w23-calmroot'})
SET p.lastSelectedInSnapshotUid = 'hu:private-recommendation-snapshot:w23-s9';

MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:w23-calmroot-us-powder'})
SET v.id = 'w23-calmroot-us-powder', v.entityType = 'PRODUCT_VARIANT', v.name = 'CalmRoot US powder (synthetic)', v.jurisdiction = 'US',
    v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-03-02T10:00:00Z'),
    v.chosenByContextUids = ['hu:private-user-context:w23-leak-0002'];

// 2c string relationship property and 2d LIST relationship property on two shared edges
MATCH (p:Product {uid: 'hu:product:w23-calmroot'}), (v:ProductVariant {uid: 'hu:product-variant:w23-calmroot-us-powder'})
MERGE (p)-[r:HAS_VARIANT {relationshipUid: 'hu:rel:w23-leak-calmroot-variant'}]->(v)
SET r.recordedFrom = datetime('2026-03-02T10:10:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.assertionUid = 'hu:assertion:w23-leak-calmroot-variant', r.viewedInSnapshotUid = 'hu:private-recommendation-snapshot:w23-s9';

MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-calmroot-us-powder'}), (p:Product {uid: 'hu:product:w23-sleepwell'})
MERGE (v)-[r:COMPARED_IN_DECISION {relationshipUid: 'hu:rel:w23-leak-compared-in-decision'}]->(p)
SET r.derivationRule = 'leaked-private-comparison', r.optionUids = ['hu:private-recommendation-option:w23-s9-a', 'hu:private-recommendation-option:w23-s9-b'];

// 2e privacy class only (no private uid anywhere): lower-case catalog spelling versus upper-case spelling (minimal pair)
MERGE (x:Product:Entity {uid: 'hu:product:w23-leak-class-lower'})
SET x.id = 'w23-leak-class-lower', x.entityType = 'PRODUCT', x.privacyClass = 'private-personal', x.createdAt = datetime('2026-04-01T00:00:00Z');

MERGE (x:Product:Entity {uid: 'hu:product:w23-leak-class-upper'})
SET x.id = 'w23-leak-class-upper', x.entityType = 'PRODUCT', x.privacyClass = 'PRIVATE_PERSONAL', x.createdAt = datetime('2026-04-01T00:00:00Z');

// ---- LEAK-3: a search index covering a private property ----
// The index is created BEFORE any private node exists: V-115 and V-116 (node-based) cannot see it yet; V-W23-04 (index metadata) can.
CREATE FULLTEXT INDEX w23_leak_goal_search IF NOT EXISTS FOR (n:UserGoalVersion|Product) ON EACH [n.goalStatement, n.name];

MERGE (g:UserGoalVersion:VersionedState {uid: 'hu:private-user-goal-version:w23-leak-g1'})
SET g.stateType = 'USER_GOAL_VERSION', g.payloadHash = 'sha256:2105cc5bd103f03d256fde6cec86903cd8cef4511fce608aca5d7e12f766d081',
    g.goalStatement = 'Fall asleep faster before my night shifts', g.searchText = 'fall asleep faster night shifts', g.searchFields = ['goalStatement'],
    g.privacyClass = 'private-personal', g.createdAt = datetime('2026-04-09T18:00:00Z');

CALL db.awaitIndexes(60);
