// W23 operations companion, ENTERPRISE EDITION ONLY (property existence and property type constraints).
// Expected on Neo4j 5.26 Community: every statement rejected (Enterprise-only). Never counted as passing on Community;
// the write service enforces the same rules there (07-operations.md, application validation table).
CREATE CONSTRAINT answer_record_recorded_as_of_exists IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.recordedAsOf IS NOT NULL;
CREATE CONSTRAINT answer_record_schema_digest_exists IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.schemaDigest IS NOT NULL;
CREATE CONSTRAINT answer_record_query_shape_exists IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.queryShapeId IS NOT NULL;
CREATE CONSTRAINT answer_record_access_tier_exists IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.accessTier IS NOT NULL;
CREATE CONSTRAINT answer_record_private_context_exists IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.privateContext IS NOT NULL;
CREATE CONSTRAINT answer_record_recorded_as_of_type IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.recordedAsOf IS :: ZONED DATETIME;
CREATE CONSTRAINT policy_version_payload_hash_exists IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.payloadHash IS NOT NULL;
CREATE CONSTRAINT policy_version_kind_exists IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.policyKind IS NOT NULL;
CREATE CONSTRAINT policy_version_permitted_use_kinds_type IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.permittedUseKinds IS :: LIST<STRING NOT NULL>;
CREATE CONSTRAINT decision_criterion_method_exists IF NOT EXISTS FOR (n:DecisionCriterion) REQUIRE n.methodVersion IS NOT NULL;
CREATE CONSTRAINT authorized_by_use_kind_exists IF NOT EXISTS FOR ()-[r:AUTHORIZED_BY]-() REQUIRE r.useKind IS NOT NULL;
CREATE CONSTRAINT privacy_class_type_answer_record IF NOT EXISTS FOR (n:AnswerRecord) REQUIRE n.privacyClass IS :: STRING;
