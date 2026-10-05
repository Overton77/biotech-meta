// W16 operations proposal (protocols module). Recommendation only; Fable merges into the final operations file.
// Target: Neo4j 5.26.31 Community (tested on the embedded harness 2026-10-04, see 07-operations.md); Enterprise-only statements
// are in the second block, commented, and were not executed (Community rejects them).
// Stored property names are used throughout (no GraphQL aliases exist on W16 types).

// ---------- Community: uniqueness (uid and live id per primary label) ----------
CREATE CONSTRAINT protocol_uid IF NOT EXISTS FOR (n:Protocol) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_id IF NOT EXISTS FOR (n:Protocol) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_edition_uid IF NOT EXISTS FOR (n:ProtocolEdition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_edition_id IF NOT EXISTS FOR (n:ProtocolEdition) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_step_uid IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_step_id IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_constraint_uid IF NOT EXISTS FOR (n:Constraint) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_constraint_id IF NOT EXISTS FOR (n:Constraint) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT measurement_plan_uid IF NOT EXISTS FOR (n:MeasurementPlan) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT measurement_plan_id IF NOT EXISTS FOR (n:MeasurementPlan) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_rule_uid IF NOT EXISTS FOR (n:ProtocolAdjustmentRule) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_rule_id IF NOT EXISTS FOR (n:ProtocolAdjustmentRule) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_target_uid IF NOT EXISTS FOR (n:Target) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_target_id IF NOT EXISTS FOR (n:Target) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT functional_goal_uid IF NOT EXISTS FOR (n:FunctionalGoal) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT functional_goal_id IF NOT EXISTS FOR (n:FunctionalGoal) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT observation_uid IF NOT EXISTS FOR (n:Observation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT observation_id IF NOT EXISTS FOR (n:Observation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_result_uid IF NOT EXISTS FOR (n:ProtocolResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_result_id IF NOT EXISTS FOR (n:ProtocolResult) REQUIRE n.id IS UNIQUE;
// one relationshipUid per attachment episode
CREATE CONSTRAINT has_protocol_edition_rel_uid IF NOT EXISTS FOR ()-[r:HAS_PROTOCOL_EDITION]-() REQUIRE r.relationshipUid IS UNIQUE;

// ---------- Community: retrieval indexes ----------
CREATE INDEX protocol_step_key IF NOT EXISTS FOR (n:ProtocolStep) ON (n.stepKey);
CREATE INDEX protocol_step_payload_hash IF NOT EXISTS FOR (n:ProtocolStep) ON (n.payloadHash);
CREATE INDEX protocol_edition_payload_hash IF NOT EXISTS FOR (n:ProtocolEdition) ON (n.payloadHash);
CREATE INDEX protocol_step_requirement IF NOT EXISTS FOR (n:ProtocolStep) ON (n.requirementLevel);
CREATE INDEX has_protocol_edition_recorded_to IF NOT EXISTS FOR ()-[r:HAS_PROTOCOL_EDITION]-() ON (r.recordedTo);
CREATE INDEX has_protocol_edition_assertion IF NOT EXISTS FOR ()-[r:HAS_PROTOCOL_EDITION]-() ON (r.assertionUid);
CREATE INDEX depends_on_kind IF NOT EXISTS FOR ()-[r:DEPENDS_ON]-() ON (r.dependencyKind);
CREATE INDEX has_constraint_role IF NOT EXISTS FOR ()-[r:HAS_CONSTRAINT]-() ON (r.constraintRole);
// live fulltext index name and query name retained (D-015); stored property names
CREATE FULLTEXT INDEX ProtocolSearch IF NOT EXISTS FOR (n:Protocol) ON EACH [n.name, n.description, n.searchText];

// ---------- Enterprise only (NOT executed on Community; property existence/type) ----------
// CREATE CONSTRAINT protocol_step_key_exists IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.stepKey IS NOT NULL;
// CREATE CONSTRAINT protocol_step_hash_exists IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.payloadHash IS NOT NULL;
// CREATE CONSTRAINT protocol_edition_hash_exists IF NOT EXISTS FOR (n:ProtocolEdition) REQUIRE n.payloadHash IS NOT NULL;
// CREATE CONSTRAINT protocol_edition_prov_exists IF NOT EXISTS FOR (n:ProtocolEdition) REQUIRE n.changeProvenance IS NOT NULL;
// CREATE CONSTRAINT has_protocol_edition_assertion_exists IF NOT EXISTS FOR ()-[r:HAS_PROTOCOL_EDITION]-() REQUIRE r.assertionUid IS NOT NULL;
// CREATE CONSTRAINT has_protocol_edition_recorded_from_exists IF NOT EXISTS FOR ()-[r:HAS_PROTOCOL_EDITION]-() REQUIRE r.recordedFrom IS NOT NULL;
// CREATE CONSTRAINT depends_on_kind_exists IF NOT EXISTS FOR ()-[r:DEPENDS_ON]-() REQUIRE r.dependencyKind IS NOT NULL;
// CREATE CONSTRAINT has_constraint_role_exists IF NOT EXISTS FOR ()-[r:HAS_CONSTRAINT]-() REQUIRE r.constraintRole IS NOT NULL;
// CREATE CONSTRAINT step_lag_min_type IF NOT EXISTS FOR ()-[r:DEPENDS_ON]-() REQUIRE r.lagMin IS :: INTEGER;
// CREATE CONSTRAINT step_cadence_min_type IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.cadenceIntervalMin IS :: INTEGER;
