// =====================================================================================================================
// W06 fixture 04: Treatment.developmentStage display text versus W13 RegulatoryStatus{APPROVAL} (V-322-style guard,
// V-W06-01) and an indication change over valid time (late facts).
//   - exa-cel: developmentStage 'Approved (US)' is a CALCULATED projection of an ACCEPTED APPROVAL reachable through
//     USES_COMPONENT{ADMINISTERED_PRODUCT} -> CASGEVY <- APPROVAL_FOR/STATUS_OF. Two DrugApproval states from the OOPD
//     record: 2024-01-16 TDT aged >= 12; 2026-07-01 TDT aged >= 2. As of 2025-06-01 the US approval for TDT covers
//     patients aged 12+ only; as of 2026-08-01 it covers 2+. The Treatment node does not change.
//   - edaravone (ALS) concept: migrated legacy developmentStage 'Approved' with no assertion. The only approval record
//     (RADICAVA, NDA 209176) is captured from a search extract, so its STATUS_OF assertion is EXTRACTED, not ACCEPTED:
//     V-W06-01 reports the concept until the approval is captured reproducibly.
// W13 nodes are referenced shapes (labels per catalog: DrugApproval / OrphanDesignation are RegulatoryStatus
// specializations, archetype VersionedState). Rule: every statement binds its own nodes by uid.
// =====================================================================================================================

UNWIND [
  {uid: 'hu:reg-status:us-casgevy-tdt-approval-20240116', from: '2024-01-16T00:00:00Z', ind: 'treatment of patients aged 12 years and older with transfusion-dependent beta-thalassemia (TDT)'},
  {uid: 'hu:reg-status:us-casgevy-tdt-approval-20260701', from: '2026-07-01T00:00:00Z', ind: 'treatment of patients aged 2 years and older with transfusion-dependent beta-thalassemia (TDT)'}
] AS x
MERGE (s:DrugApproval:RegulatoryStatus:VersionedState {uid: x.uid})
SET s.stateType = 'RegulatoryStatus', s.statusKind = 'APPROVAL', s.jurisdiction = 'US', s.indication = x.ind,
    s.effectiveFrom = datetime(x.from), s.payloadHash = 'sha256:' + 'synthetic-' + x.uid, s.privacyClass = 'PUBLIC',
    s.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {uid: 'hu:reg-status:us-casgevy-tdt-approval-20240116', from: '2024-01-16T00:00:00Z', to: null},
  {uid: 'hu:reg-status:us-casgevy-tdt-approval-20260701', from: '2026-07-01T00:00:00Z', to: null}
] AS x
MATCH (s:RegulatoryStatus {uid: x.uid}), (p:Product {uid: 'hu:product:casgevy'}), (fda:Organization {uid: 'hu:org:us-fda'}), (l:SourceLocator {uid: 'hu:locator:oopd-714319-record'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-' + substring(x.uid, 14) + '-status-of'})
SET a.predicate = 'STATUS_OF', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'REGULATORY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED', a.jurisdiction = 'US',
    a.validFrom = datetime(x.from), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validTo = CASE WHEN x.to IS NULL THEN null ELSE datetime(x.to) END,
    a.validToPrecision = CASE WHEN x.to IS NULL THEN null ELSE 'DAY' END,
    a.validToBasis = CASE WHEN x.to IS NULL THEN 'UNKNOWN' ELSE 'INFERRED' END,
    a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (s)-[r:STATUS_OF {relationshipUid: 'hu:rel:w06-' + substring(x.uid, 14) + '-status-of'}]->(p)
SET r.assertionUid = a.uid, r.validFrom = a.validFrom, r.validFromPrecision = 'DAY', r.validFromBasis = 'STATED_BY_SOURCE',
    r.validTo = a.validTo, r.validToPrecision = a.validToPrecision, r.validToBasis = a.validToBasis,
    r.recordedFrom = datetime('2026-10-04T02:00:00Z')
MERGE (s)-[:ISSUED_BY]->(fda);

// ---- W13 approving responses (letters listed on the CBER page; OOPD gives the matching marketing approval dates).
// The 2024 approval (aged 12+) is NOT ended by the 2026 approval (aged 2+): the indication was broadened, so both stay
// in force with unknown end. ----
UNWIND [
  {uid: 'hu:reg-response:us-casgevy-approval-letter-20240116', at: '2024-01-16T00:00:00Z', st: 'hu:reg-status:us-casgevy-tdt-approval-20240116', title: 'January 16, 2024 Approval Letter - CASGEVY (STN 125785)'},
  {uid: 'hu:reg-response:us-casgevy-approval-letter-20260701', at: '2026-07-01T00:00:00Z', st: 'hu:reg-status:us-casgevy-tdt-approval-20260701', title: 'July 1, 2026 Approval Letter - CASGEVY (125787)'}
] AS x
MATCH (s:RegulatoryStatus {uid: x.st}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (r:RegulatoryResponse:InformationArtifact {uid: x.uid})
SET r.artifactType = 'RegulatoryResponse', r.responseKind = 'APPROVED', r.issuedAt = datetime(x.at), r.jurisdiction = 'US',
    r.title = x.title, r.privacyClass = 'PUBLIC', r.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (s)-[:RESULTS_FROM_RESPONSE]->(r)
MERGE (r)-[:ISSUED_BY]->(fda);

// ---- exa-cel developmentStage: CALCULATED display assertion naming its input ----
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'}), (inp:Assertion {uid: 'hu:assertion:w06-us-casgevy-tdt-approval-20240116-status-of'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-exa-cel-development-stage-calc'})
SET a.predicate = 'DECLARES_DEVELOPMENT_STAGE', a.valueString = 'Approved (US)', a.status = 'ACCEPTED',
    a.basisKind = 'CALCULATED', a.derivationRule = 'stage-from-reachable-accepted-approval-v1', a.jurisdiction = 'US',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.polarity = 'POSITIVE', a.predicateClass = 'REGULATORY',
    a.validFrom = datetime('2024-01-16T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'INFERRED',
    a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(inp)
WITH t, a
MATCH (l:SourceLocator {uid: 'hu:locator:oopd-714319-record'})
MERGE (a)-[:SUPPORTED_BY]->(l)
SET t.developmentStage = 'Approved (US)', t.developmentStageAssertionUid = a.uid;

// ---- edaravone concept (migrated legacy text, no assertion) ----
MERGE (t:Treatment:Entity {uid: 'hu:treatment:edaravone-als'})
SET t.id = 'edaravone-als', t.entityType = 'Treatment', t.name = 'edaravone for amyotrophic lateral sclerosis',
    t.modalities = ['SMALL_MOLECULE'], t.modality = 'SMALL_MOLECULE',
    t.developmentStage = 'Approved', t.developmentStageAssertionUid = null,
    t.orphanDrugDesignation = 'Orphan designation: Treatment of amyotrophic lateral sclerosis (designated 03/12/2015)',
    t.orphanDesignationStatusUids = null, t.privacyClass = 'PUBLIC', t.maturity = 'PROVISIONAL',
    t.createdAt = datetime('2026-10-04T02:00:00Z'), t.updatedAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {obj: 'hu:substance:edaravone', role: 'ACTIVE_COMPONENT', label: 'ChemicalSubstance', loc: 'hu:locator:oopd-465514-record', rel: 'edaravone-active'},
  {obj: 'hu:product:radicava', role: 'ADMINISTERED_PRODUCT', label: 'Product', loc: 'hu:locator:nda209176-search-description', rel: 'edaravone-radicava'},
  {obj: 'hu:product:treeway-edaravone-investigational', role: 'ADMINISTERED_PRODUCT', label: 'Product', loc: 'hu:locator:oopd-465514-record', rel: 'edaravone-treeway-product'}
] AS x
MATCH (t:Treatment {uid: 'hu:treatment:edaravone-als'}), (o {uid: x.obj}), (l:SourceLocator {uid: x.loc})
MERGE (a:Assertion {uid: 'hu:assertion:w06-uses-component-' + x.rel})
SET a.predicate = 'USES_COMPONENT', a.status = CASE WHEN x.loc = 'hu:locator:nda209176-search-description' THEN 'EXTRACTED' ELSE 'ACCEPTED' END,
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (t)-[r:USES_COMPONENT {relationshipUid: 'hu:rel:w06-' + x.rel}]->(o)
SET r.assertionUid = a.uid, r.componentRole = x.role, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// RADICAVA approval: known only from a search extract (no reproducible locator) -> status EXTRACTED; date not established.
MERGE (s:DrugApproval:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-radicava-nda209176-approval'})
SET s.stateType = 'RegulatoryStatus', s.statusKind = 'APPROVAL', s.jurisdiction = 'US', s.applicationNumber = 'NDA 209176',
    s.indication = 'treatment of Amyotrophic Lateral Sclerosis (ALS) (wording from a search extract)', s.effectiveFrom = null,
    s.payloadHash = 'sha256:' + 'synthetic-hu:reg-status:us-radicava-nda209176-approval', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T02:00:00Z');

MATCH (s:RegulatoryStatus {uid: 'hu:reg-status:us-radicava-nda209176-approval'}), (p:Product {uid: 'hu:product:radicava'}), (l:SourceLocator {uid: 'hu:locator:nda209176-search-description'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-us-radicava-nda209176-approval-status-of'})
SET a.predicate = 'STATUS_OF', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'REGULATORY', a.jurisdiction = 'US',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (s)-[r:STATUS_OF {relationshipUid: 'hu:rel:w06-us-radicava-nda209176-approval-status-of'}]->(p)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
