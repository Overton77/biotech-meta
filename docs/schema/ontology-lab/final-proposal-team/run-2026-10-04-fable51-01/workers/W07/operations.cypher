// W07 diagnostics operations proposal (run-2026-10-04-fable51-01). Stored property names only.
// Section A runs on Neo4j 5.26 Community; section B needs Enterprise (property existence / type constraints) and is
// expected to be rejected on Community. Uniqueness of uid across archetypes stays W00's (entity_uid, versioned_state_uid,
// information_artifact_uid, evidence_assessment_uid in neo4j/constraints.cypher); the per-label constraints below make
// label-scoped lookups index-backed. Run once per database; every statement is idempotent (IF NOT EXISTS).

// ---------------------------------------------------------------------------------------------------------------------
// A. Community-compatible
// ---------------------------------------------------------------------------------------------------------------------

// A1 uid per W07 primary label (lookup by uid in fixtures, ingestion MERGE and API).
CREATE CONSTRAINT w07_biomarker_uid IF NOT EXISTS FOR (n:Biomarker) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_metric_uid IF NOT EXISTS FOR (n:Metric) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_lab_test_uid IF NOT EXISTS FOR (n:LabTest) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_panel_definition_uid IF NOT EXISTS FOR (n:PanelDefinition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_measurement_method_uid IF NOT EXISTS FOR (n:MeasurementMethod) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_specimen_uid IF NOT EXISTS FOR (n:Specimen) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_reference_system_uid IF NOT EXISTS FOR (n:ReferenceSystem) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_assay_version_uid IF NOT EXISTS FOR (n:AssayVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_algorithm_uid IF NOT EXISTS FOR (n:Algorithm) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_algorithm_version_uid IF NOT EXISTS FOR (n:AlgorithmVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_ri_version_uid IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_comparability_uid IF NOT EXISTS FOR (n:ComparabilityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w07_reference_range_uid IF NOT EXISTS FOR (n:ReferenceRange) REQUIRE n.uid IS UNIQUE;

// A2 live id per label (the @id field; equals the uid opaque segment).
CREATE CONSTRAINT w07_biomarker_id IF NOT EXISTS FOR (n:Biomarker) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w07_metric_id IF NOT EXISTS FOR (n:Metric) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w07_lab_test_id IF NOT EXISTS FOR (n:LabTest) REQUIRE n.id IS UNIQUE;

// A3 domain identity keys (same names as neo4j/constraints.cypher; repeated so the W07 set is self-contained).
CREATE CONSTRAINT metric_loinc_code IF NOT EXISTS FOR (n:Metric) REQUIRE n.loincCode IS UNIQUE;
CREATE CONSTRAINT lab_test_local_code IF NOT EXISTS FOR (n:LabTest) REQUIRE (n.issuerUid, n.localTestCode) IS UNIQUE;

// A4 content-addressed state identity: one node per payload (prevents duplicate versions on re-ingestion).
CREATE CONSTRAINT w07_assay_version_payload IF NOT EXISTS FOR (n:AssayVersion) REQUIRE n.payloadHash IS UNIQUE;
CREATE CONSTRAINT w07_algorithm_version_payload IF NOT EXISTS FOR (n:AlgorithmVersion) REQUIRE n.payloadHash IS UNIQUE;
CREATE CONSTRAINT w07_ri_version_payload IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.payloadHash IS UNIQUE;
CREATE CONSTRAINT w07_panel_definition_payload IF NOT EXISTS FOR (n:PanelDefinition) REQUIRE n.payloadHash IS UNIQUE;

// A5 asserted-edge episode identity (relationship uniqueness constraint).
CREATE CONSTRAINT w07_performed_with_rel_uid IF NOT EXISTS FOR ()-[r:PERFORMED_WITH_ASSAY_VERSION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w07_measures_metric_rel_uid IF NOT EXISTS FOR ()-[r:MEASURES_METRIC]-() REQUIRE r.relationshipUid IS UNIQUE;

// A6 retrieval indexes.
CREATE INDEX algorithm_version_basis IF NOT EXISTS FOR (n:AlgorithmVersion) ON (n.versionBasis);
CREATE INDEX w07_ri_version_kind IF NOT EXISTS FOR (n:ReferenceIntervalVersion) ON (n.intervalKind);
CREATE INDEX w07_comparability_verdict IF NOT EXISTS FOR (n:ComparabilityAssessment) ON (n.verdict);
CREATE INDEX w07_metric_system IF NOT EXISTS FOR (n:Metric) ON (n.systemKind);
CREATE INDEX w07_performed_with_recorded_to IF NOT EXISTS FOR ()-[r:PERFORMED_WITH_ASSAY_VERSION]-() ON (r.recordedTo);

// A7 fulltext indexes retained from the live @fulltext directives (D-015; stored property names).
CREATE FULLTEXT INDEX BiomarkerSearch IF NOT EXISTS FOR (n:Biomarker) ON EACH [n.name, n.description, n.searchText];
CREATE FULLTEXT INDEX MetricSearch IF NOT EXISTS FOR (n:Metric) ON EACH [n.name, n.description, n.searchText];
CREATE FULLTEXT INDEX LabTestSearch IF NOT EXISTS FOR (n:LabTest) ON EACH [n.name, n.description, n.searchText];

// ---------------------------------------------------------------------------------------------------------------------
// B. Enterprise only (expected to be rejected on Community; V-303, V-308, V-311, V-313r detect the same faults)
// ---------------------------------------------------------------------------------------------------------------------
CREATE CONSTRAINT diagnostic_result_kind_exists IF NOT EXISTS FOR (n:DiagnosticResult) REQUIRE n.resultKind IS NOT NULL;
CREATE CONSTRAINT w07_algorithm_version_basis_exists IF NOT EXISTS FOR (n:AlgorithmVersion) REQUIRE n.versionBasis IS NOT NULL;
CREATE CONSTRAINT w07_assay_software_status_exists IF NOT EXISTS FOR (n:AssayVersion) REQUIRE n.softwareVersionStatus IS NOT NULL;
CREATE CONSTRAINT w07_ri_kind_exists IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.intervalKind IS NOT NULL;
CREATE CONSTRAINT w07_ri_derivation_exists IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.derivationKind IS NOT NULL;
CREATE CONSTRAINT w07_comparability_verdict_exists IF NOT EXISTS FOR (n:ComparabilityAssessment) REQUIRE n.verdict IS NOT NULL;
CREATE CONSTRAINT w07_ri_lower_bound_type IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.lowerBound IS :: FLOAT;
CREATE CONSTRAINT w07_ri_upper_bound_type IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.upperBound IS :: FLOAT;
CREATE CONSTRAINT w07_performed_with_assertion_exists IF NOT EXISTS FOR ()-[r:PERFORMED_WITH_ASSAY_VERSION]-() REQUIRE r.assertionUid IS NOT NULL;
