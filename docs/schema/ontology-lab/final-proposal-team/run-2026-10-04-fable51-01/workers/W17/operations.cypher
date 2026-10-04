// W17 safety_and_constraints operations -- Community-runnable baseline (Neo4j 5.26.31 Community; also valid on Enterprise).
// Run: run-2026-10-04-fable51-01, worker W17. Recommendation for Fable's final operations file; not a deployment script.
// Every statement is idempotent (IF NOT EXISTS). Archetype-label uid constraints (entity_uid, assertion_uid,
// evidence_assessment_uid) are W00's and are assumed present. Executed on an embedded 5.26.31 Community instance on
// 2026-10-04 (06-fixtures-and-queries.md section 1). No Enterprise-only statement is needed by W17 (presence of
// signalStatus, methodVersion, constraintLevel, identityKeyHash is service-enforced on Community; see 07-operations.md).

// A. Primary-label uid and live-id uniqueness (index-backed lookups by primary label; GraphQL MATCH uses the primary label).
CREATE CONSTRAINT adverse_effect_uid IF NOT EXISTS FOR (n:AdverseEffect) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT adverse_effect_id IF NOT EXISTS FOR (n:AdverseEffect) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT safety_signal_uid IF NOT EXISTS FOR (n:SafetySignal) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT safety_signal_id IF NOT EXISTS FOR (n:SafetySignal) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT use_constraint_uid IF NOT EXISTS FOR (n:UseConstraint) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT use_constraint_id IF NOT EXISTS FOR (n:UseConstraint) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT contraindication_assertion_uid IF NOT EXISTS FOR (n:ContraindicationAssertion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT interaction_assertion_uid IF NOT EXISTS FOR (n:InteractionAssertion) REQUIRE n.uid IS UNIQUE;

// B. Natural identity: one UseConstraint per canonical scope tuple (uc-key/v1). Concurrent writers MERGE on this key.
CREATE CONSTRAINT use_constraint_identity_key IF NOT EXISTS FOR (n:UseConstraint) REQUIRE (n.identityKeyHash) IS UNIQUE;

// C. Relationship-episode identity for the structural subject attachment (MERGE key for parallel subjects).
CREATE CONSTRAINT has_safety_signal_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_SAFETY_SIGNAL]-() REQUIRE r.relationshipUid IS UNIQUE;

// D. Range indexes for Q-W17-03/07/08 (signal state and method filters) and Q-W17-04 (directive level).
CREATE INDEX safety_signal_status IF NOT EXISTS FOR (n:SafetySignal) ON (n.signalStatus);
CREATE INDEX safety_signal_method IF NOT EXISTS FOR (n:SafetySignal) ON (n.methodVersion);
CREATE INDEX safety_signal_recorded_at IF NOT EXISTS FOR (n:SafetySignal) ON (n.recordedAt);
CREATE INDEX contraindication_level IF NOT EXISTS FOR (n:ContraindicationAssertion) ON (n.constraintLevel);
CREATE INDEX contraindication_recorded IF NOT EXISTS FOR (n:ContraindicationAssertion) ON (n.recordedAt, n.recordedTo);
CREATE INDEX interaction_polarity IF NOT EXISTS FOR (n:InteractionAssertion) ON (n.polarity);
CREATE INDEX interaction_recorded IF NOT EXISTS FOR (n:InteractionAssertion) ON (n.recordedAt, n.recordedTo);
CREATE INDEX signal_input_status IF NOT EXISTS FOR ()-[r:SIGNAL_BASED_ON]-() ON (r.aeReportedStatus);
CREATE INDEX constraint_scope_role IF NOT EXISTS FOR ()-[r:CONSTRAINT_SCOPE]-() ON (r.scopeRole);

// E. Full-text indexes keeping the live index and query names (D-015), over stored property names.
CREATE FULLTEXT INDEX AdverseEffectSearch IF NOT EXISTS FOR (n:AdverseEffect) ON EACH [n.name, n.description, n.searchText, n.effectCategory];
CREATE FULLTEXT INDEX SafetySignalSearch IF NOT EXISTS FOR (n:SafetySignal) ON EACH [n.name, n.description, n.searchText, n.signalType, n.interactionSummary];
