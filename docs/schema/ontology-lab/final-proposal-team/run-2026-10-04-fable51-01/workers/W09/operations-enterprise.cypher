// W09 operations: Enterprise-only companion (property existence/type constraints). NOT RUN: Neo4j Enterprise was not
// available (00-baseline.md). Run on 5.26.31 Community 2026-10-04: 17/17 rejected (NODE/RELATIONSHIP PROPERTY EXISTENCE and
// PROPERTY TYPE constraints need Enterprise), as expected. Apply only on Enterprise 5.26+.
// Each mirrors a W09 validator so the database refuses what the validator would otherwise report after the fact.
CREATE CONSTRAINT registration_version_observed IF NOT EXISTS FOR (r:RegistrationVersion) REQUIRE r.observedAt IS NOT NULL;   // V-211 (name from validation.cypher)
CREATE CONSTRAINT trial_registration_registry IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.registry IS NOT NULL;
CREATE CONSTRAINT trial_registration_registration_id IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.registrationId IS NOT NULL;
CREATE CONSTRAINT study_result_analysis_kind IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.analysisKind IS NOT NULL;
CREATE CONSTRAINT study_result_comparison_kind IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.comparisonKind IS NOT NULL;
CREATE CONSTRAINT study_result_statistical_conclusion IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.statisticalConclusion IS NOT NULL;
CREATE CONSTRAINT ae_result_collection_method IF NOT EXISTS FOR (n:AdverseEventResult) REQUIRE n.collectionMethod IS NOT NULL;   // V-217r
CREATE CONSTRAINT ae_result_seriousness IF NOT EXISTS FOR (n:AdverseEventResult) REQUIRE n.seriousness IS NOT NULL;
CREATE CONSTRAINT outcome_definition_measure_kind_exists IF NOT EXISTS FOR (n:OutcomeDefinition) REQUIRE n.measureKind IS NOT NULL;
CREATE CONSTRAINT study_population_kind IF NOT EXISTS FOR (n:StudyPopulation) REQUIRE n.populationKind IS NOT NULL;
CREATE CONSTRAINT publication_kind_exists IF NOT EXISTS FOR (n:Publication) REQUIRE n.publicationKind IS NOT NULL;
CREATE CONSTRAINT analyzes_dataset_role IF NOT EXISTS FOR ()-[r:ANALYZES_DATASET]-() REQUIRE r.analysisRole IS NOT NULL;
CREATE CONSTRAINT corrects_revision_event_exists IF NOT EXISTS FOR ()-[r:CORRECTS]-() REQUIRE r.sourceRevisionEventUid IS NOT NULL;   // V-W09-04 (part)
CREATE CONSTRAINT retracts_revision_event_exists IF NOT EXISTS FOR ()-[r:RETRACTS]-() REQUIRE r.sourceRevisionEventUid IS NOT NULL;
CREATE CONSTRAINT result_for_arm_role IF NOT EXISTS FOR ()-[r:RESULT_FOR_ARM]-() REQUIRE r.armRole IS NOT NULL;
CREATE CONSTRAINT component_quantity_type IF NOT EXISTS FOR (n:InterventionComponent) REQUIRE n.quantity IS :: FLOAT;
CREATE CONSTRAINT ae_event_count_type IF NOT EXISTS FOR (n:AdverseEventResult) REQUIRE n.eventCount IS :: INTEGER;
