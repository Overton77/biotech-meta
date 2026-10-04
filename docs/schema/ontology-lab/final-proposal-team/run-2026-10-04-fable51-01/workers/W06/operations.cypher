// =====================================================================================================================
// W06 operations recommendation (Neo4j 5.26; Community unless marked). Stored property names only. Idempotent
// (IF NOT EXISTS). Executed on embedded Neo4j 5.26.31 Community on 2026-10-04 (results in 07-operations.md).
// =====================================================================================================================

// ---- node identity (uid canonical; live id kept beside it, INV-106) ----
CREATE CONSTRAINT w06_treatment_uid IF NOT EXISTS FOR (n:Treatment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w06_treatment_id IF NOT EXISTS FOR (n:Treatment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w06_procedure_uid IF NOT EXISTS FOR (n:Procedure) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w06_procedure_id IF NOT EXISTS FOR (n:Procedure) REQUIRE n.id IS UNIQUE;

// ---- one asserted-edge episode per relationshipUid (relationship property uniqueness, Neo4j 5.7+) ----
CREATE CONSTRAINT w06_targets_condition_rel_uid IF NOT EXISTS FOR ()-[r:TARGETS_CONDITION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_uses_component_rel_uid IF NOT EXISTS FOR ()-[r:USES_COMPONENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_develops_treatment_rel_uid IF NOT EXISTS FOR ()-[r:DEVELOPS_TREATMENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_offers_treatment_rel_uid IF NOT EXISTS FOR ()-[r:OFFERS_TREATMENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_offers_procedure_rel_uid IF NOT EXISTS FOR ()-[r:OFFERS_PROCEDURE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_instantiates_treatment_rel_uid IF NOT EXISTS FOR ()-[r:INSTANTIATES_TREATMENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w06_instantiates_procedure_rel_uid IF NOT EXISTS FOR ()-[r:INSTANTIATES_PROCEDURE]-() REQUIRE r.relationshipUid IS UNIQUE;

// ---- retrieval indexes ----
// assertion-to-edge lookups (QS-4a / V-W06-08 join on assertionUid)
CREATE INDEX w06_uses_component_assertion IF NOT EXISTS FOR ()-[r:USES_COMPONENT]-() ON (r.assertionUid);
CREATE INDEX w06_targets_condition_assertion IF NOT EXISTS FOR ()-[r:TARGETS_CONDITION]-() ON (r.assertionUid);
// role-filtered traversal Treatment -> ADMINISTERED_PRODUCT (CQ-AX-23 path, V-W06-01)
CREATE INDEX w06_uses_component_role IF NOT EXISTS FOR ()-[r:USES_COMPONENT]-() ON (r.componentRole);

// ---- full-text (live index and query names retained, D-015) ----
CREATE FULLTEXT INDEX TreatmentSearch IF NOT EXISTS FOR (n:Treatment) ON EACH [n.name, n.description, n.searchText, n.treatmentClass, n.orphanDrugDesignation];
CREATE FULLTEXT INDEX ProcedureSearch IF NOT EXISTS FOR (n:Procedure) ON EACH [n.name, n.description, n.searchText, n.procedureType, n.setting];

// ---- vector (justified for free-text-to-concept lookup, QS-8; dimensions are the deployment's choice) ----
// Example for a 1536-dimension model; Fable records the actual dimension at merge (D-014). Community supports vector indexes in 5.26.
CREATE VECTOR INDEX TreatmentSearchEmbedding IF NOT EXISTS FOR (n:Treatment) ON (n.searchEmbedding)
OPTIONS {indexConfig: {`vector.dimensions`: 1536, `vector.similarity_function`: 'cosine'}};

// ---- Enterprise only (NOT executed on Community; recorded for the edition companion) ----
// CREATE CONSTRAINT w06_treatment_entity_type IF NOT EXISTS FOR (n:Treatment) REQUIRE n.entityType IS NOT NULL;
// CREATE CONSTRAINT w06_uses_component_role_exists IF NOT EXISTS FOR ()-[r:USES_COMPONENT]-() REQUIRE r.componentRole IS NOT NULL;
// CREATE CONSTRAINT w06_targets_condition_assertion_exists IF NOT EXISTS FOR ()-[r:TARGETS_CONDITION]-() REQUIRE r.assertionUid IS NOT NULL;
// CREATE CONSTRAINT w06_treatment_modalities_type IF NOT EXISTS FOR (n:Treatment) REQUIRE n.modalities IS :: LIST<STRING NOT NULL>;
