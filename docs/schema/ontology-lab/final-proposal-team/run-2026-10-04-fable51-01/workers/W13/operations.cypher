// W13 operations recommendation (regulatory_and_ip, regulatory half). Baseline statements target Neo4j 5.26 Community;
// the Enterprise-only block at the end is a separate companion and is expected to be rejected on Community.
// Executed in this session against embedded Neo4j 5.26.31 Community (results in 07-operations.md).
// Stored property names are used (uid, id, statusKind ...). Idempotent: IF NOT EXISTS everywhere.

// ---- Baseline (Community): node identity ------------------------------------------------------------------------
CREATE CONSTRAINT w13_regulatory_agency_uid IF NOT EXISTS FOR (n:RegulatoryAgency) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_pathway_uid IF NOT EXISTS FOR (n:RegulatoryPathway) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_pathway_version_uid IF NOT EXISTS FOR (n:RegulatoryPathwayVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_step_uid IF NOT EXISTS FOR (n:RegulatoryStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_submission_uid IF NOT EXISTS FOR (n:RegulatorySubmission) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_response_uid IF NOT EXISTS FOR (n:RegulatoryResponse) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_status_uid IF NOT EXISTS FOR (n:RegulatoryStatus) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_inspection_uid IF NOT EXISTS FOR (n:RegulatoryInspection) REQUIRE n.uid IS UNIQUE;
// live GraphQL id (opaque segment of uid), unique per primary label
CREATE CONSTRAINT w13_regulatory_agency_id IF NOT EXISTS FOR (n:RegulatoryAgency) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_pathway_id IF NOT EXISTS FOR (n:RegulatoryPathway) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_pathway_version_id IF NOT EXISTS FOR (n:RegulatoryPathwayVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_step_id IF NOT EXISTS FOR (n:RegulatoryStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_submission_id IF NOT EXISTS FOR (n:RegulatorySubmission) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_response_id IF NOT EXISTS FOR (n:RegulatoryResponse) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_status_id IF NOT EXISTS FOR (n:RegulatoryStatus) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w13_regulatory_inspection_id IF NOT EXISTS FOR (n:RegulatoryInspection) REQUIRE n.id IS UNIQUE;

// ---- Baseline (Community): relationship episode identity ------------------------------------------------------------
CREATE CONSTRAINT w13_status_of_reluid IF NOT EXISTS FOR ()-[r:STATUS_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w13_has_pathway_version_reluid IF NOT EXISTS FOR ()-[r:HAS_PATHWAY_VERSION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w13_submission_about_reluid IF NOT EXISTS FOR ()-[r:SUBMISSION_ABOUT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w13_submitted_by_reluid IF NOT EXISTS FOR ()-[r:SUBMITTED_BY]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w13_inspected_facility_reluid IF NOT EXISTS FOR ()-[r:INSPECTED_FACILITY]-() REQUIRE r.relationshipUid IS UNIQUE;

// ---- Baseline (Community): retrieval indexes ---------------------------------------------------------------------
CREATE INDEX w13_status_kind_jurisdiction IF NOT EXISTS FOR (n:RegulatoryStatus) ON (n.statusKind, n.jurisdiction);
CREATE INDEX w13_response_kind IF NOT EXISTS FOR (n:RegulatoryResponse) ON (n.responseKind);
CREATE INDEX w13_submission_identifier IF NOT EXISTS FOR (n:RegulatorySubmission) ON (n.identifier);
CREATE INDEX w13_submission_kind_jurisdiction IF NOT EXISTS FOR (n:RegulatorySubmission) ON (n.submissionKind, n.jurisdiction);
CREATE INDEX w13_pathway_kind_jurisdiction IF NOT EXISTS FOR (n:RegulatoryPathway) ON (n.pathwayKind, n.jurisdiction);
CREATE INDEX w13_status_of_assertion IF NOT EXISTS FOR ()-[r:STATUS_OF]-() ON (r.assertionUid);
CREATE INDEX w13_status_of_recorded IF NOT EXISTS FOR ()-[r:STATUS_OF]-() ON (r.recordedTo, r.validTo);
CREATE INDEX w13_has_pathway_version_recorded IF NOT EXISTS FOR ()-[r:HAS_PATHWAY_VERSION]-() ON (r.recordedTo, r.validTo);
CREATE INDEX w13_inspection_started IF NOT EXISTS FOR (n:RegulatoryInspection) ON (n.startedAt);

// ---- Enterprise companion (expected to be REJECTED on Community; run only on Enterprise 5.26) ----------------------
CREATE CONSTRAINT w13_status_kind_exists IF NOT EXISTS FOR (n:RegulatoryStatus) REQUIRE n.statusKind IS NOT NULL;
CREATE CONSTRAINT w13_status_jurisdiction_exists IF NOT EXISTS FOR (n:RegulatoryStatus) REQUIRE n.jurisdiction IS NOT NULL;
CREATE CONSTRAINT w13_response_kind_exists IF NOT EXISTS FOR (n:RegulatoryResponse) REQUIRE n.responseKind IS NOT NULL;
CREATE CONSTRAINT w13_status_kind_type IF NOT EXISTS FOR (n:RegulatoryStatus) REQUIRE n.statusKind IS :: STRING;
CREATE CONSTRAINT w13_status_of_assertion_exists IF NOT EXISTS FOR ()-[r:STATUS_OF]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT w13_status_of_recorded_from_exists IF NOT EXISTS FOR ()-[r:STATUS_OF]-() REQUIRE r.recordedFrom IS NOT NULL;
