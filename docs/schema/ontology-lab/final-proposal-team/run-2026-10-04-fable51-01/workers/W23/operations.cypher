// W23 operations companion (Neo4j 5.26 Community-runnable statements only). Proposal; Fable merges into
// docs/schema/neo4j/final_biotech_schema_operations.cypher. Idempotent (IF NOT EXISTS). Stored property names only.
// uid uniqueness for AnswerRecord (Occurrence), PolicyVersion (VersionedState), DecisionCriterion (Entity) is already
// created by the archetype constraints occurrence_uid, versioned_state_uid, entity_uid (constraints.cypher); not repeated.
// Executed 2026-10-04 on embedded Neo4j 5.26.31 Community: see 07-operations.md (applied/rejected counts).

// O-W23-01: live id uniqueness per W23 label (the id = opaque uid segment; @id generation is API-only, Cypher writers set it)
CREATE CONSTRAINT answer_record_id IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT policy_version_id IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT decision_criterion_id IF NOT EXISTS FOR (n:DecisionCriterion) REQUIRE n.id IS UNIQUE;

// O-W23-02: one version label per policy family; one criterion per key and method version (identity includes method)
CREATE CONSTRAINT policy_version_key_label IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE (n.policyKey, n.versionLabel) IS UNIQUE;
CREATE CONSTRAINT decision_criterion_key_method IF NOT EXISTS FOR (n:DecisionCriterion) REQUIRE (n.criterionKey, n.methodVersion) IS UNIQUE;

// O-W23-03: retrieval indexes. AnswerRecord by viewpoint (CQ-AX-03 replay queues, audit by period) and by query shape
// (re-run every answer of a shape after a shape change); PolicyVersion by family (effective-version lookup).
CREATE INDEX answer_record_recorded_as_of IF NOT EXISTS FOR (n:AnswerRecord) ON (n.recordedAsOf);
CREATE INDEX answer_record_query_shape IF NOT EXISTS FOR (n:AnswerRecord) ON (n.queryShapeId, n.queryShapeVersion);
CREATE INDEX policy_version_policy_key IF NOT EXISTS FOR (n:PolicyVersion) ON (n.policyKey);

// O-W23-04: relationship-property uniqueness for episode/citation identity is NOT needed (CITES_* are structural, no
// relationshipUid). AUTHORIZED_BY.useKind lookups are traversal-bound; no index.
