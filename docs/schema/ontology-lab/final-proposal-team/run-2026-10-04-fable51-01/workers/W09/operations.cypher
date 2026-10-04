// W09 operations: Community-runnable baseline for studies_and_evidence (Neo4j 5.26.31 Community; also valid on Enterprise).
// Run: run-2026-10-04-fable51-01, worker W09. Recommendation for Fable's final_biotech_schema_operations.cypher; not a
// deployment script. Idempotent (IF NOT EXISTS). Names reused verbatim from docs/schema/neo4j/constraints.cypher where the
// definition is identical (trial_registration_identity, publication_doi, study_result_analysis).
// Executed 2026-10-04 on the W09 embedded 5.26.31 Community instance with fixtures 01-07 and 90 loaded: 42/42 applied.
// Enterprise-only statements: operations-enterprise.cypher (not run; no Enterprise available).

// A. Primary-label uid and live id uniqueness (archetype-label uid constraints are W00's).
CREATE CONSTRAINT study_uid IF NOT EXISTS FOR (n:Study) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_id IF NOT EXISTS FOR (n:Study) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT trial_registration_uid IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT trial_registration_id IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT registration_version_uid IF NOT EXISTS FOR (n:RegistrationVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT registration_version_id IF NOT EXISTS FOR (n:RegistrationVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_version_uid IF NOT EXISTS FOR (n:ProtocolVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_version_id IF NOT EXISTS FOR (n:ProtocolVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT study_arm_uid IF NOT EXISTS FOR (n:StudyArm) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_arm_id IF NOT EXISTS FOR (n:StudyArm) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT study_intervention_uid IF NOT EXISTS FOR (n:StudyIntervention) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_intervention_id IF NOT EXISTS FOR (n:StudyIntervention) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT intervention_component_uid IF NOT EXISTS FOR (n:InterventionComponent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT intervention_component_id IF NOT EXISTS FOR (n:InterventionComponent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT study_population_uid IF NOT EXISTS FOR (n:StudyPopulation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_population_id IF NOT EXISTS FOR (n:StudyPopulation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT outcome_definition_uid IF NOT EXISTS FOR (n:OutcomeDefinition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT outcome_definition_id IF NOT EXISTS FOR (n:OutcomeDefinition) REQUIRE n.id IS UNIQUE;
// StudyResult covers AdverseEventResult (shared label); AE-specific constraints would duplicate the index.
CREATE CONSTRAINT study_result_uid IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_result_id IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT publication_uid IF NOT EXISTS FOR (n:Publication) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT publication_id IF NOT EXISTS FOR (n:Publication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT dataset_uid IF NOT EXISTS FOR (n:Dataset) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT dataset_id IF NOT EXISTS FOR (n:Dataset) REQUIRE n.id IS UNIQUE;

// B. Natural keys (materialized lookup keys; the Identifier records stay authoritative).
CREATE CONSTRAINT trial_registration_identity IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE (n.registry, n.registrationId) IS UNIQUE;
CREATE CONSTRAINT publication_doi IF NOT EXISTS FOR (n:Publication) REQUIRE n.doi IS UNIQUE;
CREATE CONSTRAINT publication_pmid IF NOT EXISTS FOR (n:Publication) REQUIRE n.pmid IS UNIQUE;

// C. Range indexes justified by named query shapes.
// QS-W09-01 / V-211r / CQ-ST-08: versions by observation time and status.
CREATE INDEX registration_version_observed_at IF NOT EXISTS FOR (n:RegistrationVersion) ON (n.observedAt);
CREATE INDEX registration_version_status IF NOT EXISTS FOR (n:RegistrationVersion) ON (n.overallStatus, n.resultsPosted);
// V-215/V-215r/QS-W09-03 (reused name and definition from constraints.cypher).
CREATE INDEX study_result_analysis IF NOT EXISTS FOR (r:StudyResult) ON (r.analysisKind, r.statisticalConclusion);
// QS-W09-05 / V-217r / V-217i: AE rows by seriousness and collection method.
CREATE INDEX ae_result_seriousness_method IF NOT EXISTS FOR (n:AdverseEventResult) ON (n.seriousness, n.collectionMethod);
// V-221r: arm type filter.
CREATE INDEX study_arm_type IF NOT EXISTS FOR (n:StudyArm) ON (n.armType);
// QS-W09-06 / V-212: publications by kind.
CREATE INDEX publication_kind IF NOT EXISTS FOR (n:Publication) ON (n.publicationKind);
// CQ-ST-03 filters by measure kind.
CREATE INDEX outcome_definition_measure_kind IF NOT EXISTS FOR (n:OutcomeDefinition) ON (n.measureKind);
// CQ-EV-03 grouping.
CREATE INDEX study_kind IF NOT EXISTS FOR (n:Study) ON (n.studyKind);
// Relationship-property lookups by authorizing assertion (INV-503 audits, assertion -> edge navigation).
CREATE INDEX registered_as_assertion IF NOT EXISTS FOR ()-[r:REGISTERED_AS]-() ON (r.assertionUid);
CREATE INDEX uses_intervention_material_assertion IF NOT EXISTS FOR ()-[r:USES_INTERVENTION_MATERIAL]-() ON (r.assertionUid);
CREATE INDEX reports_on_assertion IF NOT EXISTS FOR ()-[r:REPORTS_ON]-() ON (r.assertionUid);
CREATE INDEX corrects_revision_event IF NOT EXISTS FOR ()-[r:CORRECTS]-() ON (r.sourceRevisionEventUid);
CREATE INDEX retracts_revision_event IF NOT EXISTS FOR ()-[r:RETRACTS]-() ON (r.sourceRevisionEventUid);
CREATE INDEX has_registration_version_recorded IF NOT EXISTS FOR ()-[r:HAS_REGISTRATION_VERSION]-() ON (r.recordedFrom, r.recordedTo);

// D. Full-text index retained from the live schema (D-015), created with stored property names.
CREATE FULLTEXT INDEX StudySearch IF NOT EXISTS FOR (n:Study) ON EACH [n.name, n.description, n.searchText];
