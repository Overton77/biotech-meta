// W19 operations recommendation (candidate types only; Community 5.26 runnable). Fable merges into the final operations file.
CREATE CONSTRAINT source_authority_assessment_uid IF NOT EXISTS FOR (n:SourceAuthorityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_coverage_requirement_uid IF NOT EXISTS FOR (n:SourceCoverageRequirement) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_discovery_record_uid IF NOT EXISTS FOR (n:SourceDiscoveryRecord) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_coverage_requirement_key_version IF NOT EXISTS FOR (n:SourceCoverageRequirement) REQUIRE (n.requirementKey, n.versionLabel) IS UNIQUE;
CREATE INDEX source_discovery_subject IF NOT EXISTS FOR (n:SourceDiscoveryRecord) ON (n.subjectUid, n.startedAt);
CREATE INDEX source_discovery_outcome IF NOT EXISTS FOR (n:SourceDiscoveryRecord) ON (n.discoveryOutcome);
CREATE INDEX source_coverage_subject_label IF NOT EXISTS FOR (n:SourceCoverageRequirement) ON (n.subjectLabel);
CREATE INDEX source_authority_recorded_to IF NOT EXISTS FOR (n:SourceAuthorityAssessment) ON (n.recordedTo);
// Enterprise-only companion (NOT run on Community; expected to be rejected there):
// CREATE CONSTRAINT source_discovery_outcome_exists IF NOT EXISTS FOR (n:SourceDiscoveryRecord) REQUIRE n.discoveryOutcome IS NOT NULL;
// CREATE CONSTRAINT source_authority_scopes_exists IF NOT EXISTS FOR (n:SourceAuthorityAssessment) REQUIRE n.authorityScopes IS NOT NULL;
