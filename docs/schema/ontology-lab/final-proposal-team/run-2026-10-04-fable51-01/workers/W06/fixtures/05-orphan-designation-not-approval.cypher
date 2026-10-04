// =====================================================================================================================
// W06 fixture 05: orphan designation text that must not read as approval.
//   - exa-cel: OOPD "Orphan Designation Status: Designated/Approved" is SPLIT into an OrphanDesignation state
//     (2020-04-28, "Treatment of beta-thalassemia") and the DrugApproval states of fixture 04. The designated condition
//     (beta-thalassemia) is broader than the approved labeled indication (TDT, age-bounded): designation scope never
//     becomes an approved indication.
//   - edaravone / Treeway B.V.: OOPD "Designated/Designation Withdrawn or Revoked" and "Not FDA Approved for Orphan
//     Indication". The designation is the sponsor's product's; the generic-name concept's legacy text
//     ("Orphan designation: Treatment of amyotrophic lateral sclerosis") must not answer "approved". The source does
//     not say whether the designation was withdrawn or revoked, nor when: the end is recorded with an unknown bound and
//     statusKind left null (W13 seam W06-SR-05), never guessed.
// Requires fixtures 00, 01, 04. Rule: every statement binds its own nodes by uid.
// =====================================================================================================================

MERGE (d:OrphanDesignation:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-oopd-714319-exa-cel-beta-thalassemia'})
SET d.stateType = 'RegulatoryStatus', d.statusKind = 'DESIGNATION', d.jurisdiction = 'US', d.indication = 'Treatment of beta-thalassemia',
    d.effectiveFrom = datetime('2020-04-28T00:00:00Z'), d.sourceStatusText = 'Designated/Approved',
    d.payloadHash = 'sha256:' + 'synthetic-hu:reg-status:us-oopd-714319-exa-cel-beta-thalassemia', d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (d:OrphanDesignation:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-oopd-465514-treeway-edaravone-als'})
SET d.stateType = 'RegulatoryStatus', d.statusKind = 'DESIGNATION', d.jurisdiction = 'US', d.indication = 'Treatment of amyotrophic lateral sclerosis',
    d.effectiveFrom = datetime('2015-03-12T00:00:00Z'), d.sourceStatusText = 'Designated/Designation Withdrawn or Revoked; Not FDA Approved for Orphan Indication',
    d.payloadHash = 'sha256:' + 'synthetic-hu:reg-status:us-oopd-465514-treeway-edaravone-als', d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (d:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-oopd-465514-treeway-designation-ended'})
SET d.stateType = 'RegulatoryStatus', d.statusKind = null, d.jurisdiction = 'US',
    d.scopeText = 'Designation Withdrawn or Revoked (source does not distinguish; date not captured)',
    d.payloadHash = 'sha256:' + 'synthetic-hu:reg-status:us-oopd-465514-treeway-designation-ended', d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {s: 'hu:reg-status:us-oopd-714319-exa-cel-beta-thalassemia', p: 'hu:product:casgevy', loc: 'hu:locator:oopd-714319-record', from: '2020-04-28T00:00:00Z', rel: 'exa-cel-designation'},
  {s: 'hu:reg-status:us-oopd-465514-treeway-edaravone-als', p: 'hu:product:treeway-edaravone-investigational', loc: 'hu:locator:oopd-465514-record', from: '2015-03-12T00:00:00Z', rel: 'treeway-designation'},
  {s: 'hu:reg-status:us-oopd-465514-treeway-designation-ended', p: 'hu:product:treeway-edaravone-investigational', loc: 'hu:locator:oopd-465514-record', from: null, rel: 'treeway-designation-ended'}
] AS x
MATCH (s:RegulatoryStatus {uid: x.s}), (p:Product {uid: x.p}), (l:SourceLocator {uid: x.loc}), (fda:Organization {uid: 'hu:org:us-fda'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-' + x.rel + '-status-of'})
SET a.predicate = CASE WHEN s:OrphanDesignation THEN 'DESIGNATION_FOR' ELSE 'STATUS_OF' END, a.status = 'ACCEPTED',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.polarity = 'POSITIVE', a.predicateClass = 'REGULATORY', a.jurisdiction = 'US',
    a.validFrom = CASE WHEN x.from IS NULL THEN null ELSE datetime(x.from) END,
    a.validFromPrecision = CASE WHEN x.from IS NULL THEN null ELSE 'DAY' END,
    a.validFromBasis = CASE WHEN x.from IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END,
    a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(fda)
MERGE (s)-[:ISSUED_BY]->(fda);

MATCH (s:OrphanDesignation {uid: 'hu:reg-status:us-oopd-714319-exa-cel-beta-thalassemia'}), (p:Product {uid: 'hu:product:casgevy'})
MERGE (s)-[r:DESIGNATION_FOR {relationshipUid: 'hu:rel:w06-exa-cel-designation'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-exa-cel-designation-status-of', r.validFrom = datetime('2020-04-28T00:00:00Z'), r.validFromPrecision = 'DAY',
    r.validFromBasis = 'STATED_BY_SOURCE', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (s:OrphanDesignation {uid: 'hu:reg-status:us-oopd-465514-treeway-edaravone-als'}), (p:Product {uid: 'hu:product:treeway-edaravone-investigational'})
MERGE (s)-[r:DESIGNATION_FOR {relationshipUid: 'hu:rel:w06-treeway-designation'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-treeway-designation-status-of', r.validFrom = datetime('2015-03-12T00:00:00Z'), r.validFromPrecision = 'DAY',
    r.validFromBasis = 'STATED_BY_SOURCE', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (s:RegulatoryStatus {uid: 'hu:reg-status:us-oopd-465514-treeway-designation-ended'}), (p:Product {uid: 'hu:product:treeway-edaravone-investigational'})
MERGE (s)-[r:STATUS_OF {relationshipUid: 'hu:rel:w06-treeway-designation-ended'}]->(p)
SET r.assertionUid = 'hu:assertion:w06-treeway-designation-ended-status-of', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (s:RegulatoryStatus {uid: 'hu:reg-status:us-oopd-465514-treeway-edaravone-als'}), (p:Product {uid: 'hu:product:treeway-edaravone-investigational'}), (o:Organization {uid: 'hu:org:treeway-bv'}), (l:SourceLocator {uid: 'hu:locator:oopd-465514-record'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-treeway-designation-sponsor'})
SET a.predicate = 'SUBMITTED_BY', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.polarity = 'POSITIVE',
    a.predicateClass = 'REGULATORY', a.valueString = 'OOPD sponsor of record', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// ---- Treatment display projection of the exa-cel designation (read-only field, written by the projection job) ----
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'})
SET t.orphanDrugDesignation = 'US orphan designation (2020-04-28): Treatment of beta-thalassemia',
    t.orphanDesignationStatusUids = ['hu:reg-status:us-oopd-714319-exa-cel-beta-thalassemia'];
