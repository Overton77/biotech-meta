// W14 operations (proposal; Fable merges into final_biotech_schema_operations.cypher). Baseline statements only: every
// statement here runs on Neo4j 5.26 Community (uniqueness constraints, range/fulltext indexes). Existence and
// property-type constraints are Enterprise-only and are listed in 07-operations.md as application-enforced instead.
// Stored property names are used (no GraphQL aliases exist on W14 types).

// --- identity (uid) ---
CREATE CONSTRAINT w14_patent_family_uid IF NOT EXISTS FOR (n:PatentFamily) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_patent_application_uid IF NOT EXISTS FOR (n:PatentApplication) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_granted_patent_uid IF NOT EXISTS FOR (n:GrantedPatent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_patent_claim_uid IF NOT EXISTS FOR (n:PatentClaim) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_patent_license_uid IF NOT EXISTS FOR (n:PatentLicense) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_trademark_uid IF NOT EXISTS FOR (n:Trademark) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w14_ip_right_status_uid IF NOT EXISTS FOR (n:IpRightStatus) REQUIRE n.uid IS UNIQUE;

// --- live projection id (opaque segment of uid; contract A2) ---
CREATE CONSTRAINT w14_patent_family_id IF NOT EXISTS FOR (n:PatentFamily) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_patent_application_id IF NOT EXISTS FOR (n:PatentApplication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_granted_patent_id IF NOT EXISTS FOR (n:GrantedPatent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_patent_claim_id IF NOT EXISTS FOR (n:PatentClaim) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_patent_license_id IF NOT EXISTS FOR (n:PatentLicense) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_trademark_id IF NOT EXISTS FOR (n:Trademark) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w14_ip_right_status_id IF NOT EXISTS FOR (n:IpRightStatus) REQUIRE n.id IS UNIQUE;

// --- materialized office keys (one right per office number) ---
CREATE CONSTRAINT w14_patent_application_office_key IF NOT EXISTS FOR (n:PatentApplication) REQUIRE n.officeKey IS UNIQUE;
CREATE CONSTRAINT w14_granted_patent_office_key IF NOT EXISTS FOR (n:GrantedPatent) REQUIRE n.officeKey IS UNIQUE;
CREATE CONSTRAINT w14_trademark_office_key IF NOT EXISTS FOR (n:Trademark) REQUIRE n.officeKey IS UNIQUE;
// composite uniqueness (familyDefinition, familyIdentifier); null familyIdentifier is not constrained (Neo4j skips nulls)
CREATE CONSTRAINT w14_patent_family_key IF NOT EXISTS FOR (n:PatentFamily) REQUIRE (n.familyDefinition, n.familyIdentifier) IS UNIQUE;

// --- retrieval indexes ---
CREATE INDEX w14_patent_application_jurisdiction IF NOT EXISTS FOR (n:PatentApplication) ON (n.jurisdiction, n.filingDate);
CREATE INDEX w14_granted_patent_jurisdiction IF NOT EXISTS FOR (n:GrantedPatent) ON (n.jurisdiction, n.grantDate);
CREATE INDEX w14_patent_claim_hash IF NOT EXISTS FOR (n:PatentClaim) ON (n.claimTextHash);
CREATE INDEX w14_trademark_mark_text IF NOT EXISTS FOR (n:Trademark) ON (n.markText, n.jurisdiction);
CREATE INDEX w14_ip_right_status_kind IF NOT EXISTS FOR (n:IpRightStatus) ON (n.statusKind, n.jurisdiction);
// relationship property indexes for as-of queries on the hot asserted edges
CREATE INDEX w14_ip_status_of_rel_uid IF NOT EXISTS FOR ()-[r:IP_STATUS_OF]-() ON (r.relationshipUid);
CREATE INDEX w14_license_covers_rel_uid IF NOT EXISTS FOR ()-[r:LICENSE_COVERS]-() ON (r.relationshipUid);
CREATE INDEX w14_licenses_patent_rel_uid IF NOT EXISTS FOR ()-[r:LICENSES_PATENT]-() ON (r.relationshipUid);
CREATE INDEX w14_owns_trademark_rel_uid IF NOT EXISTS FOR ()-[r:OWNS_TRADEMARK]-() ON (r.relationshipUid);
CREATE INDEX w14_ip_status_of_valid IF NOT EXISTS FOR ()-[r:IP_STATUS_OF]-() ON (r.validFrom, r.validTo);

// --- fulltext (SDL @fulltext PatentClaimText; stored property claimText) ---
CREATE FULLTEXT INDEX PatentClaimText IF NOT EXISTS FOR (n:PatentClaim) ON EACH [n.claimText];
