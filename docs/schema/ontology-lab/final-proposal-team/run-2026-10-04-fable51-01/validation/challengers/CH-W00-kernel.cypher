// =====================================================================================================================
// CH-W00-kernel.cypher -- Wave 5 Challenger W00 (kernel: time, provenance, identity), run-2026-10-04-fable51-01.
// Counterexamples as Cypher mutations against the loaded final fixtures (final operations file + six translated 0.2.0
// fixtures + 99-normalize-live-ids backfill), Neo4j 5.26.31 Community embedded + APOC core.
//
// Layout: every case is a block
//   // CH-K-nn[x] MUTATION   -> the statements that create the failing case
//   // CH-K-nn[x] UNDO       -> the statements that restore the loaded fixtures exactly
// The driver ran, for each case: MUTATION, then docs/schema/neo4j/validation.cypher (validation-params.json),
// workers/W00/validation-corrections.cypher (validation-params-w00.json) and, for reference only, the W00 packet
// workers/W00/fixtures/validation-w00.cypher; then UNDO, then the three suites again to confirm the baseline.
// Observed results are recorded in CH-W00-kernel.md (objection table). Statements share no variables across ';'.
// Fixture anchors used below:
//   snapshot  hu:snapshot:sinclair-affiliations-2026-10-03 (retrievedAt 2026-10-03T00:00Z)
//   locator   hu:locator:sinclair-affiliations-insidetracker-line
//   A_BOARD   hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017 (recordedAt 2026-10-03T12:00Z, ACCEPTED)
//   REL_BOARD hu:rel:board-member-of-sinclair-insidetracker-2011-2017 (its BOARD_MEMBER_OF projection)
//   I_INV     hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open (no edge projection; validTo null)
// =====================================================================================================================

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-01a  Backdating an asserted edge: recordedFrom moved before the supporting snapshot's retrievedAt (INV-502, asserted_edge rule
// recordedFrom >= assertion.recordedAt). The suite's V-504 only looks at five episode types, so BOARD_MEMBER_OF is outside it.
// CH-K-01a MUTATION
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.recordedFrom = datetime('2026-10-02T00:00:00Z');
// CH-K-01a UNDO
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.recordedFrom = datetime('2026-10-03T12:00:00Z');

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-01b  Consistent backdating of assertion AND edge before retrieval (control: V-504 ASSERTION_BEFORE_RETRIEVAL must fire).
// CH-K-01b MUTATION
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.recordedAt = datetime('2026-10-02T00:00:00Z');
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.recordedFrom = datetime('2026-10-02T00:00:00Z');
// CH-K-01b UNDO
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.recordedAt = datetime('2026-10-03T12:00:00Z');
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.recordedFrom = datetime('2026-10-03T12:00:00Z');

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-02a  Backdated EvidenceAssessment: an ApplicabilityDimension recorded 2026-01-01 cites locators on snapshots retrieved
// 2026-07-10 and 2026-10-03 (INV-502 generic; V-504 is Assertion-only, V-511 is Adjudication-only).
// CH-K-02a MUTATION
MATCH (d:ApplicabilityDimension {uid: 'hu:applicability:nct02678611-1x-to-basis-current-material_identity'})
SET d.recordedAt = datetime('2026-01-01T00:00:00Z');
// CH-K-02a UNDO
MATCH (d:ApplicabilityDimension {uid: 'hu:applicability:nct02678611-1x-to-basis-current-material_identity'})
REMOVE d.recordedAt;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-02b  Assertions recorded before the Activity that generated them started (PROV-O: wasGeneratedBy implies generation within
// the activity; recordedAt is service-assigned at commit). Every assertion of curation-2026-10-03-lane4 (recordedAt 2026-10-03T12:00Z)
// now predates its activity.
// CH-K-02b MUTATION
MATCH (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
SET act.startedAt = datetime('2026-10-04T06:00:00Z');
// CH-K-02b UNDO
MATCH (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
SET act.startedAt = datetime('2026-10-03T00:00:00Z');

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-03a  A fact ENDING recorded as SUPERSEDES {SOURCE_CORRECTION} (contract A.6: correction = SOURCE_CORRECTION, ending =
// VALIDITY_BOUNDED). Same subject, object and validFrom; the newer one only closes the open validTo; no source revision event.
// The audit reading "the 2011-open investor record was an error" is now asserted silently.
// CH-K-03a MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})-[:HAS_SUBJECT]->(s)
MATCH (i)-[:HAS_OBJECT]->(o)
CREATE (b:Assertion {uid: 'hu:assertion:chk-03a-investor-ended-2026', id: 'chk-03a-investor-ended-2026',
  predicate: 'INVESTED_IN', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:00:00Z'),
  validFrom: i.validFrom, validFromPrecision: i.validFromPrecision, validFromBasis: i.validFromBasis,
  validTo: datetime('2026-06-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE',
  polarity: 'POSITIVE', assertionBasis: i.assertionBasis, contentHash: 'sha256:0000000000000000000000000000000000000000000000000000000000000003',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC'})
CREATE (b)-[:HAS_SUBJECT]->(s)
CREATE (b)-[:HAS_OBJECT]->(o)
CREATE (b)-[:SUPERSEDES {supersessionKind: 'SOURCE_CORRECTION', recordedAt: datetime('2026-10-04T01:00:00Z')}]->(i)
SET i.recordedTo = datetime('2026-10-04T01:00:00Z'), i.status = 'SUPERSEDED';
// CH-K-03a UNDO
MATCH (b:Assertion {uid: 'hu:assertion:chk-03a-investor-ended-2026'}) DETACH DELETE b;
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.status = 'ACCEPTED' REMOVE i.recordedTo;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-03b  Control: a CORRECTION (start year changed 2011 -> 2012) recorded as VALIDITY_BOUNDED. V-507b must fire.
// CH-K-03b MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})-[:HAS_SUBJECT]->(s)
MATCH (i)-[:HAS_OBJECT]->(o)
CREATE (b:Assertion {uid: 'hu:assertion:chk-03b-investor-start-corrected', id: 'chk-03b-investor-start-corrected',
  predicate: 'INVESTED_IN', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:00:00Z'),
  validFrom: datetime('2012-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE',
  validTo: datetime('2026-06-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE',
  polarity: 'POSITIVE', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC'})
CREATE (b)-[:HAS_SUBJECT]->(s)
CREATE (b)-[:HAS_OBJECT]->(o)
CREATE (b)-[:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED', recordedAt: datetime('2026-10-04T01:00:00Z')}]->(i)
SET i.recordedTo = datetime('2026-10-04T01:00:00Z'), i.status = 'SUPERSEDED';
// CH-K-03b UNDO
MATCH (b:Assertion {uid: 'hu:assertion:chk-03b-investor-start-corrected'}) DETACH DELETE b;
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.status = 'ACCEPTED' REMOVE i.recordedTo;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-04  Correction applied IN PLACE: valid time edited on the assertion and on its edge together (INV-501 valid time immutable;
// INV-504 analogue for assertions). V-505r compares edge with assertion, so a consistent edit is invisible. updatedAt is bumped
// as the GraphQL @timestamp would do on an update.
// CH-K-04 MUTATION
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.validTo = datetime('2017-01-01T00:00:00Z'), a.updatedAt = datetime('2026-10-04T03:00:00Z');
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.validTo = datetime('2017-01-01T00:00:00Z');
// CH-K-04 UNDO
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.validTo = datetime('2018-01-01T00:00:00Z'), a.updatedAt = datetime('2026-10-04T00:00:00Z');
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->()
SET r.validTo = datetime('2018-01-01T00:00:00Z');

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-05a  Sentinel 9999-12-31 as an assertion's open end (control: V-502 must fire).
// CH-K-05a MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validTo = datetime('9999-12-31T00:00:00Z'), i.validToPrecision = 'DAY', i.validToBasis = 'STATED_BY_SOURCE';
// CH-K-05a UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validToBasis = 'UNKNOWN' REMOVE i.validTo, i.validToPrecision;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-05b  Sentinel 9000-12-31 on an assertion (INV-102 "never a sentinel date"). V-502 tests year >= 9999 on assertions;
// V-104 tests year >= 9000 on edges only.
// CH-K-05b MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validTo = datetime('9000-12-31T00:00:00Z'), i.validToPrecision = 'DAY', i.validToBasis = 'STATED_BY_SOURCE';
// CH-K-05b UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validToBasis = 'UNKNOWN' REMOVE i.validTo, i.validToPrecision;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-05c  Sentinel minimum 0001-01-01 as an assertion's "unknown start" (INV-102). V-104's year <= 1 test is edge-only.
// CH-K-05c MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validFrom = datetime('0001-01-01T00:00:00Z'), i.validFromPrecision = 'INSTANT';
// CH-K-05c UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validFrom = datetime('2011-01-01T00:00:00Z'), i.validFromPrecision = 'YEAR';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-05d  Epoch sentinel 1970-01-01T00:00Z as an unknown start (the value ops section 7 itself writes into createdAt).
// CH-K-05d MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validFrom = datetime('1970-01-01T00:00:00Z'), i.validFromPrecision = 'INSTANT';
// CH-K-05d UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validFrom = datetime('2011-01-01T00:00:00Z'), i.validFromPrecision = 'YEAR';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-05e  Sentinel 9999-12-31 outside Assertion: an EvidenceAssessment's recordedTo and a VersionedState's effectiveTo.
// CH-K-05e MUTATION
MATCH (e:EvidenceApplicability {uid: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'})
SET e.recordedTo = datetime('9999-12-31T00:00:00Z');
MATCH (v:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'})
SET v.effectiveFrom = datetime('2025-06-01T00:00:00Z'), v.effectiveTo = datetime('9999-12-31T00:00:00Z');
// CH-K-05e UNDO
MATCH (e:EvidenceApplicability {uid: 'hu:applicability:synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1'})
REMOVE e.recordedTo;
MATCH (v:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'})
REMOVE v.effectiveFrom, v.effectiveTo;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-06  Two asserters on a generic Assertion (INV-003 "at most one asserter"; contract A.3). V-410 is ClaimOccurrence-only.
// CH-K-06 MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'}), (h:Person {uid: 'hu:person:andrew-d-huberman'})
CREATE (i)-[:ASSERTED_BY]->(h);
// CH-K-06 UNDO
MATCH (:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})-[r:ASSERTED_BY]->(:Person {uid: 'hu:person:andrew-d-huberman'})
DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-07a  SourceLocator with no HAS_LOCATOR snapshot (control: V-402 must fire).
// CH-K-07a MUTATION
CREATE (:SourceLocator:InformationArtifact {uid: 'hu:locator:chk-07a-floating', id: 'chk-07a-floating', selectorKind: 'WHOLE_SNAPSHOT',
  artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-07a UNDO
MATCH (l:SourceLocator {uid: 'hu:locator:chk-07a-floating'}) DETACH DELETE l;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-07b  Locator WITH a snapshot, but the snapshot belongs to no Source (no HAS_SNAPSHOT, so no canonicalUri to re-retrieve),
// and it becomes the ONLY support of an ACCEPTED assertion (contract A.8 Source -> SourceSnapshot -> SourceLocator; INV-002
// "reproducible"). The original SUPPORTED_BY (no properties) is removed for the duration of the case.
// CH-K-07b MUTATION
CREATE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chk-07b-orphan', id: 'chk-07b-orphan', artifactType: 'SourceSnapshot',
  contentHash: 'sha256:00000000000000000000000000000000000000000000000000000000000007b0', contentHashBasis: 'SYNTHETIC_FIXTURE',
  captureCompleteness: 'COMPLETE', retrievedAt: datetime('2026-10-01T00:00:00Z'),
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')})
CREATE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chk-07b-orphan-line', id: 'chk-07b-orphan-line', artifactType: 'SourceLocator',
  selectorKind: 'TEXT_QUOTE', exact: 'investor in InsideTracker', quoteHash: 'sha256:00000000000000000000000000000000000000000000000000000000000007b1',
  normalizationVersion: 'nfc-ws-v1', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')})
CREATE (sn)-[:HAS_LOCATOR]->(l);
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})-[r:SUPPORTED_BY]->(:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'})
DELETE r;
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'}), (l:SourceLocator {uid: 'hu:locator:chk-07b-orphan-line'})
CREATE (i)-[:SUPPORTED_BY]->(l);
// CH-K-07b UNDO
MATCH (n) WHERE n.uid IN ['hu:snapshot:chk-07b-orphan', 'hu:locator:chk-07b-orphan-line'] DETACH DELETE n;
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-insidetracker-line'})
CREATE (i)-[:SUPPORTED_BY]->(l);

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-07c  One snapshot claimed by two Sources (a capture of one retrieval endpoint; contract A.8 "Source (one canonicalUri)").
// CH-K-07c MUTATION
MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (sn:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
CREATE (src)-[:HAS_SNAPSHOT]->(sn);
// CH-K-07c UNDO
MATCH (:Source {uid: 'hu:source:youtube-n9IxomBusuw'})-[r:HAS_SNAPSHOT]->(:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-08a  Derived edge with neither projectionOfAssertionUid nor derivationRule/derivedFrom* (INV-004, INV-104, contract A.5).
// SPONSORED_BY is declared "class: derived" in the final SDL (Study.sponsoredBy, DerivedEdgeProperties) but is absent from
// $derivedTypes and from the implication targets, so V-112 / V-112r never look at it. Sponsorship is a forbidden-implication area.
// CH-K-08a MUTATION
MATCH (st:Study {uid: 'hu:study:nct02712593-niagen'}), (o:Organization {uid: 'hu:org:metrobiotech-international'})
CREATE (st)-[:SPONSORED_BY {derivedAt: datetime('2026-10-04T01:00:00Z')}]->(o);
// CH-K-08a UNDO
MATCH (:Study {uid: 'hu:study:nct02712593-niagen'})-[r:SPONSORED_BY]->(:Organization {uid: 'hu:org:metrobiotech-international'}) DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-08b  Control: the same uncited shape on a type that IS in $derivedTypes (CONTAINS). V-004 and V-112 must fire.
// CH-K-08b MUTATION
MATCH (p:Product {uid: 'hu:product:tru-niagen-beauty'}), (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
CREATE (p)-[:CONTAINS {derivedAt: datetime('2026-10-04T01:00:00Z')}]->(m);
// CH-K-08b UNDO
MATCH (:Product {uid: 'hu:product:tru-niagen-beauty'})-[r:CONTAINS]->(:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
WHERE r.derivedAt = datetime('2026-10-04T01:00:00Z') DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-09  Asserted edge with no assertionUid, no recordedFrom, no relationshipUid (INV-101, contract A.5 "asserted edges are
// projections of exactly one Assertion"). AFFILIATED_WITH is "class: asserted" in the SDL (RoleEdgeProperties) but not in
// $assertedTypes (47 SDL-asserted types are missing from the list), so V-101 is blind and V-505r only reads edges WITH assertionUid.
// CH-K-09 MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (o:Organization {uid: 'hu:org:metrobiotech-international'})
CREATE (p)-[:AFFILIATED_WITH {roleTitleVerbatim: 'co-founder'}]->(o);
// CH-K-09 UNDO
MATCH (:Person {uid: 'hu:person:david-a-sinclair'})-[r:AFFILIATED_WITH]->(:Organization {uid: 'hu:org:metrobiotech-international'})
WHERE r.assertionUid IS NULL DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-10a  Two archetype labels on one node (control: V-000b must fire).
// CH-K-10a MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) SET p:InformationArtifact;
// CH-K-10a UNDO
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) REMOVE p:InformationArtifact;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-10b  ZERO archetype labels: a shadow LegalEntity that carries an existing Organization's uid, without :Organization and
// :Entity. entity_uid_unique and organization_uid_unique do not apply (labels absent); legal_entity_uid_unique sees no other
// LegalEntity; V-000a/V-000b only scan archetype-labelled nodes; V-W00-16 accepts 'org' (registered for LegalEntity, rule T2).
// INV-001: one globally stable uid per node -> two nodes now answer to hu:org:edenroc-sciences.
// CH-K-10b MUTATION
CREATE (:LegalEntity {uid: 'hu:org:edenroc-sciences', id: 'edenroc-sciences', name: 'Edenroc Sciences (shadow)',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-10b UNDO
MATCH (n:LegalEntity {uid: 'hu:org:edenroc-sciences'}) WHERE NOT n:Entity DETACH DELETE n;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-11a  uid/id drift on an ordinary type (control: V-117 must fire).
// CH-K-11a MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) SET p.id = 'sinclair-drifted';
// CH-K-11a UNDO
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) SET p.id = 'david-a-sinclair';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-11b  uid/id drift on a Document, whose live id is the stored alias documentId (contract B2). A stray `id` equal to the
// opaque segment (exactly what operations section 7 writes on every :Entity, Documents included) masks a drifted documentId,
// because V-117 reads coalesce(n.id, n.documentId, ...).
// CH-K-11b MUTATION
MATCH (d:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET d.id = 'hubermanlab-com-episode-52', d.documentId = 'drifted-document-id';
// CH-K-11b UNDO
MATCH (d:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET d.documentId = 'hubermanlab-com-episode-52' REMOVE d.id;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-11c  Missing live id on an Assertion (GraphQL `id: ID!`). V-117 skips nodes whose live id is null. Before the backfill
// (99-normalize) the loaded instance had 533 of 536 uid-bearing nodes with no live id and the suite returned zero violation rows.
// CH-K-11c MUTATION
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'}) REMOVE a.id;
// CH-K-11c UNDO
MATCH (a:Assertion {uid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017'})
SET a.id = 'affiliations-sinclair-board-insidetracker-2011-2017';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-12a  uid token not in the registry (control: V-W00-16 TOKEN_NOT_REGISTERED_FOR_LABEL must fire).
// CH-K-12a MUTATION
CREATE (:Person:Entity {uid: 'hu:widget:chk-12a', id: 'chk-12a', entityType: 'Person', name: 'Token test',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-12a UNDO
MATCH (n {uid: 'hu:widget:chk-12a'}) DETACH DELETE n;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-12b  A ClaimOccurrence minted with the generic 'assertion' token (registry T1 one token per primary label; T3
// ClaimOccurrence is a creation-time kind with token claim-occurrence). V-W00-16 accepts any token of ANY label the node carries.
// The occurrence is otherwise well formed (one container, one asserter, subject, object) so no other validator interferes.
// CH-K-12b MUTATION
MATCH (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (s:Person {uid: 'hu:person:david-a-sinclair'}), (o {uid: 'hu:brand:insidetracker'})
CREATE (c:ClaimOccurrence:Assertion {uid: 'hu:assertion:chk-12b-claim-occurrence', id: 'chk-12b-claim-occurrence',
  predicate: 'AFFILIATED_WITH', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:00:00Z'), polarity: 'POSITIVE',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC'})
CREATE (c)-[:OCCURS_IN]->(ep)
CREATE (c)-[:ASSERTED_BY]->(s)
CREATE (c)-[:HAS_SUBJECT]->(s)
CREATE (c)-[:HAS_OBJECT]->(o);
// CH-K-12b UNDO
MATCH (c {uid: 'hu:assertion:chk-12b-claim-occurrence'}) DETACH DELETE c;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-12c  A production Person minted with a 0.2.0 fixture alias token belonging to another type ('offer'). V-W00-16 classifies
// any alias token as FIXTURE_ALIAS_TOKEN (a migration item) BEFORE checking the node's labels, so a wrong-type token is downgraded.
// CH-K-12c MUTATION
CREATE (:Person:Entity {uid: 'hu:offer:chk-12c', id: 'chk-12c', entityType: 'Person', name: 'Alias token test',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-12c UNDO
MATCH (n {uid: 'hu:offer:chk-12c'}) DETACH DELETE n;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-13  Union overlap at data level: one node carries two primary domain labels that are both members of the same unions
// (AsserterTarget, RoleHolderTarget, AssertionSubjectTarget: Person | Organization). Both are Entity archetype, so V-000b passes.
// The SDL's own header (section 6) records that a node matched by two members is returned twice.
// CH-K-13 MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) SET p:Organization;
// CH-K-13 UNDO
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}) REMOVE p:Organization;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-14a  Empty half-open valid interval on an assertion, validFrom == validTo (control: V-103 must fire).
// CH-K-14a MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validTo = datetime('2011-01-01T00:00:00Z'), i.validToPrecision = 'YEAR', i.validToBasis = 'STATED_BY_SOURCE';
// CH-K-14a UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.validToBasis = 'UNKNOWN' REMOVE i.validTo, i.validToPrecision;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-14b  Empty RECORDED interval: an assertion superseded at the very instant it was recorded (recordedAt == recordedTo),
// via a well-formed VALIDITY_BOUNDED ending. V-506 (equality), V-507 (strict <) and V-109 (strict <) all accept equality.
// CH-K-14b MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})-[:HAS_SUBJECT]->(s)
MATCH (i)-[:HAS_OBJECT]->(o)
CREATE (b:Assertion {uid: 'hu:assertion:chk-14b-same-instant-ending', id: 'chk-14b-same-instant-ending',
  predicate: 'INVESTED_IN', status: 'PROPOSED', recordedAt: i.recordedAt,
  validFrom: i.validFrom, validFromPrecision: i.validFromPrecision, validFromBasis: i.validFromBasis,
  validTo: datetime('2026-06-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', polarity: 'POSITIVE',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC'})
CREATE (b)-[:HAS_SUBJECT]->(s)
CREATE (b)-[:HAS_OBJECT]->(o)
CREATE (b)-[:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED', recordedAt: i.recordedAt}]->(i)
SET i.recordedTo = i.recordedAt, i.status = 'SUPERSEDED';
// CH-K-14b UNDO
MATCH (b:Assertion {uid: 'hu:assertion:chk-14b-same-instant-ending'}) DETACH DELETE b;
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.status = 'ACCEPTED' REMOVE i.recordedTo;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-14c  Empty / inverted intervals outside Assertion and edges: VersionedState effectiveFrom == effectiveTo; Activity
// endedAt before startedAt (half-open rule, contract A.6).
// CH-K-14c MUTATION
MATCH (v:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'})
SET v.effectiveFrom = datetime('2025-06-01T00:00:00Z'), v.effectiveTo = datetime('2025-06-01T00:00:00Z');
MATCH (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'})
SET act.endedAt = datetime('2026-10-02T00:00:00Z');
// CH-K-14c UNDO
MATCH (v:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}) REMOVE v.effectiveFrom, v.effectiveTo;
MATCH (act:Activity {uid: 'hu:activity:curation-2026-10-03-lane4'}) REMOVE act.endedAt;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-15  Assertion predicate not registered (contract A.3: controlled string registered in the catalog; predicate-registry.yaml).
// CH-K-15 MUTATION
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.predicate = 'ENDORSES_EVERYTHING_IT_FUNDS';
// CH-K-15 UNDO
MATCH (i:Assertion {uid: 'hu:assertion:affiliations-sinclair-investor-insidetracker-2011-open'})
SET i.predicate = 'INVESTED_IN';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-16a  Two Sources with one canonicalUri (contract A.8 "Source (one canonicalUri)"; W00 operations.cypher had
// source_canonical_uri IS UNIQUE, which the final operations file dropped).
// CH-K-16a MUTATION
CREATE (:Source:Entity {uid: 'hu:source:chk-16a-duplicate-endpoint', id: 'chk-16a-duplicate-endpoint', entityType: 'Source',
  sourceKind: 'VIDEO_RENDITION', canonicalUri: 'https://www.youtube.com/watch?v=n9IxomBusuw',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-16a UNDO
MATCH (n {uid: 'hu:source:chk-16a-duplicate-endpoint'}) DETACH DELETE n;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-16b  Two Identifier records with the same (scheme, issuer, value) (contract A.2 Identifier records; W00 operations.cypher
// identifier_scheme_issuer_value IS UNIQUE, dropped from the final operations file; W00 fixture 08 depends on it).
// CH-K-16b MUTATION
CREATE (:Identifier:Entity {uid: 'hu:identifier:chk-16b-loinc-4548-4-dup', id: 'chk-16b-loinc-4548-4-dup', entityType: 'Identifier',
  scheme: 'LOINC', issuer: 'Regenstrief Institute', value: '4548-4',
  createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z')});
// CH-K-16b UNDO
MATCH (n {uid: 'hu:identifier:chk-16b-loinc-4548-4-dup'}) DETACH DELETE n;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-17a  Operations: a second episode that REUSES the relationshipUid of the first (must be rejected by
// rel_board_member_of_relationship_uid; expected constraint error, nothing to undo when it is rejected).
// CH-K-17a MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (b {uid: 'hu:brand:insidetracker'})
CREATE (p)-[:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017',
  assertionUid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017', recordedFrom: datetime('2026-10-04T01:00:00Z'),
  validFrom: datetime('2011-01-01T00:00:00Z'), validTo: datetime('2018-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validToPrecision: 'YEAR',
  validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE'}]->(b);
// CH-K-17a UNDO
MATCH ()-[r:BOARD_MEMBER_OF]->() WHERE r.recordedFrom = datetime('2026-10-04T01:00:00Z') DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-17b  Operations: a legitimate second recorded-time episode with a fresh relationshipUid (must be accepted).
// CH-K-17b MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (b {uid: 'hu:brand:insidetracker'})
CREATE (p)-[:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:chk-17b-board-episode-2',
  assertionUid: 'hu:assertion:affiliations-sinclair-board-insidetracker-2011-2017', recordedFrom: datetime('2026-10-04T01:00:00Z'),
  validFrom: datetime('2011-01-01T00:00:00Z'), validTo: datetime('2018-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validToPrecision: 'YEAR',
  validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE'}]->(b);
// CH-K-17b UNDO
MATCH ()-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:chk-17b-board-episode-2'}]->() DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-17c  Operations: the audit id hu:rel:<opaque> reused across relationship TYPES (the constraints are per type), and a
// duplicate relationshipUid on MEASURES_METRIC, an asserted type with no relationshipUid constraint at all (mixed class in SDL).
// CH-K-17c MUTATION
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (b {uid: 'hu:brand:insidetracker'})
CREATE (p)-[:ADVISES_ORGANIZATION {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017',
  assertionUid: 'hu:assertion:affiliations-sinclair-advisor-insidetracker-2011-open', recordedFrom: datetime('2026-10-03T12:00:00Z'),
  validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN'}]->(b);
MATCH (t:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
CREATE (t)-[:MEASURES_METRIC {relationshipUid: 'hu:rel:measures-metric-synthetic-lab-a-hba1c-hba1c-mfr-bld',
  assertionUid: 'hu:assertion:measures-metric-synthetic-lab-a-hba1c-hba1c-mfr-bld', recordedFrom: datetime('2026-10-04T01:00:00Z'),
  validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(m);
// CH-K-17c UNDO
MATCH ()-[r:ADVISES_ORGANIZATION {relationshipUid: 'hu:rel:board-member-of-sinclair-insidetracker-2011-2017'}]->() DELETE r;
MATCH ()-[r:MEASURES_METRIC]->() WHERE r.recordedFrom = datetime('2026-10-04T01:00:00Z') DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-18a  Operations section 6a, statement "UTTERED_BY -> ASSERTED_BY", run verbatim on a ClaimOccurrence that already has
// ASSERTED_BY (a live node that carries both edges): the migration manufactures a second asserter (INV-402) instead of
// routing the conflict to review.
// CH-K-18a MUTATION
MATCH (c:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-individual-variation'}), (h:Person {uid: 'hu:person:andrew-d-huberman'})
CREATE (c)-[:UTTERED_BY]->(h);
MATCH (a:ClaimOccurrence)-[r:UTTERED_BY]->(b) CREATE (a)-[n:ASSERTED_BY]->(b) SET n = properties(r) DELETE r;
// CH-K-18a UNDO
MATCH (:ClaimOccurrence {uid: 'hu:claim-occurrence:hl52-sinclair-individual-variation'})-[r:ASSERTED_BY]->(:Person {uid: 'hu:person:andrew-d-huberman'}) DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-18b  Operations section 6a, statement "HAS_STEP -> HAS_PROTOCOL_STEP", run verbatim: it writes Protocol -> ProtocolStep,
// but D-004 and the SDL (ProtocolEdition.steps / ProtocolStep.editions) put HAS_PROTOCOL_STEP on ProtocolEdition -> ProtocolStep.
// CH-K-18b MUTATION
MATCH (p:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'}), (s:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-screen-free-hour'})
CREATE (p)-[:HAS_STEP {position: 9}]->(s);
MATCH (a:Protocol)-[r:HAS_STEP]->(b:ProtocolStep) WHERE NOT EXISTS { (a)-[:HAS_PROTOCOL_STEP]->(b) }
CREATE (a)-[n:HAS_PROTOCOL_STEP]->(b) SET n = properties(r), n.orderIndex = coalesce(r.orderIndex, r.position, r.order) DELETE r;
// CH-K-18b UNDO
MATCH (:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'})-[r:HAS_PROTOCOL_STEP]->(:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-screen-free-hour'}) DELETE r;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-18c  Operations section 7, run verbatim after a Cypher write of an Entity and an Assertion without live id/timestamps:
// createdAt becomes the epoch sentinel 1970-01-01 (contract A.6 "no sentinel dates"), and the Assertion gets NO id because the id
// backfill is restricted to :Entity (99-normalize-live-ids covers every uid-bearing node; section 7 does not).
// CH-K-18c MUTATION
CREATE (:Organization:Entity {uid: 'hu:org:chk-18c-legacy', entityType: 'Organization', name: 'Legacy org without timestamps'});
CREATE (:Assertion {uid: 'hu:assertion:chk-18c-legacy', predicate: 'AFFILIATED_WITH', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:00:00Z')});
MATCH (o:Organization {uid: 'hu:org:chk-18c-legacy'}), (s:Person {uid: 'hu:person:david-a-sinclair'}), (a:Assertion {uid: 'hu:assertion:chk-18c-legacy'})
CREATE (a)-[:HAS_SUBJECT]->(s) CREATE (a)-[:HAS_OBJECT]->(o);
MATCH (n:Entity) WHERE n.id IS NULL AND n.uid IS NOT NULL SET n.id = split(n.uid, ':')[-1];
MATCH (n:Entity) WHERE n.createdAt IS NULL SET n.createdAt = coalesce(n.updatedAt, datetime({epochMillis: 0}));
MATCH (n:Entity) WHERE n.updatedAt IS NULL SET n.updatedAt = n.createdAt;
// CH-K-18c UNDO
MATCH (n) WHERE n.uid IN ['hu:org:chk-18c-legacy', 'hu:assertion:chk-18c-legacy'] DETACH DELETE n;
// Note: section 7's id backfill also wrote `id` onto Documents (they carry :Entity); the loaded Documents had id null before.
MATCH (d:Document) WHERE d.id IS NOT NULL AND d.id = d.documentId REMOVE d.id;

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-18d  The section 6a HAS_STEP statement matches (a:Protocol), but the 0.2.0 shape loaded by the translated fixture
// recommendation-snapshot is ProtocolEdition -[:HAS_STEP]-> ProtocolStep (6 edges). Run verbatim it converts nothing; the
// corrected V-525r/V-526r read HAS_PROTOCOL_STEP only, so a duplicate stepKey inside edition e1 is caught by the frozen V-525
// and missed by its replacement V-525r (the replacement makes protocol-step validation vacuous on the final fixture set).
// CH-K-18d MUTATION
MATCH (a:Protocol)-[r:HAS_STEP]->(b:ProtocolStep) WHERE NOT EXISTS { (a)-[:HAS_PROTOCOL_STEP]->(b) }
CREATE (a)-[n:HAS_PROTOCOL_STEP]->(b) SET n = properties(r), n.orderIndex = coalesce(r.orderIndex, r.position, r.order) DELETE r;
MATCH (s:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-screen-free-hour'}) SET s.stepKey = 'fixed-bedtime';
// CH-K-18d UNDO
MATCH (s:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-screen-free-hour'}) SET s.stepKey = 'screen-free-hour';

// ---------------------------------------------------------------------------------------------------------------------
// CH-K-19 PROBE (no mutation): kernel records ALREADY in the loaded final fixtures that the frozen GraphQL contract (B3/B4) cannot
// read and that no validator of the compiled suite flags. Observed counts after 99-normalize-live-ids: 3 asserted edges without
// relationshipUid (SUPPLIES_INGREDIENT_MATERIAL, FULFILLS_OFFER, SELLER_OF_RECORD_FOR); 54 EvidenceAssessments without recordedAt
// (42 ApplicabilityDimension, 7 ResolutionHypothesis, 3 ConflictRelevanceAssessment, 1 RetellingFidelityAssessment,
// 1 ComparabilityAssessment); 46 VersionedStates without payloadHash; EvidenceApplicability.status 'FINAL' (not an AssessmentStatus).
// GraphQL reads through the final SDL (@neo4j/graphql 7.6.3) fail with "Cannot return null for non-nullable field ..." /
// 'Enum "AssessmentStatus" cannot represent value: "FINAL"' (operations in CH-W00-kernel.md, section C).
MATCH ()-[r]->() WHERE r.assertionUid IS NOT NULL AND r.relationshipUid IS NULL
RETURN 'ASSERTED_EDGE_WITHOUT_RELATIONSHIP_UID' AS gap, type(r) AS item, count(*) AS n
UNION ALL
MATCH (e:EvidenceAssessment) WHERE e.recordedAt IS NULL OR e.methodVersion IS NULL OR e.assessmentType IS NULL
   OR NOT e.status IN ['PROPOSED','ACCEPTED','SUPERSEDED','WITHDRAWN']
RETURN 'EVIDENCE_ASSESSMENT_ARCHETYPE_FIELDS' AS gap, [l IN labels(e) WHERE l <> 'EvidenceAssessment'][0] AS item, count(*) AS n
UNION ALL
MATCH (v:VersionedState) WHERE v.payloadHash IS NULL OR v.stateType IS NULL
RETURN 'VERSIONED_STATE_ARCHETYPE_FIELDS' AS gap, [l IN labels(v) WHERE l <> 'VersionedState'][0] AS item, count(*) AS n;
