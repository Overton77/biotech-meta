// W00 kernel operations — ENTERPRISE EDITION companion (property existence, property type, key constraints).
// Do NOT run on Community: every statement below is rejected there (executed 2026-10-04 on 5.26.31 Community:
// all statements in this file fail with "Unable to create Constraint ..."; see 06-fixtures-and-queries.md §1).
// Enterprise behaviour is UNVERIFIED in this run (no Enterprise instance available). Property type
// constraints need 5.9+. On Community every rule below is service-enforced and audited by validation-w00.cypher.
// Run AFTER operations.cypher and AFTER the 0.2.0 data migration (existing nodes violating these fail creation).

// Assertion kernel (baseArchetypes.Assertion required fields; C-102/C-501 names reused).
CREATE CONSTRAINT assertion_recorded_at_exists IF NOT EXISTS FOR (n:Assertion) REQUIRE n.recordedAt IS NOT NULL;
CREATE CONSTRAINT assertion_predicate_exists IF NOT EXISTS FOR (n:Assertion) REQUIRE n.predicate IS NOT NULL;
CREATE CONSTRAINT assertion_status_exists IF NOT EXISTS FOR (n:Assertion) REQUIRE n.status IS NOT NULL;
CREATE CONSTRAINT assertion_recorded_at_type IF NOT EXISTS FOR (n:Assertion) REQUIRE n.recordedAt IS :: ZONED DATETIME;
CREATE CONSTRAINT assertion_recorded_to_type IF NOT EXISTS FOR (n:Assertion) REQUIRE n.recordedTo IS :: ZONED DATETIME;
CREATE CONSTRAINT assertion_valid_from_type IF NOT EXISTS FOR (n:Assertion) REQUIRE n.validFrom IS :: ZONED DATETIME;
CREATE CONSTRAINT assertion_valid_to_type IF NOT EXISTS FOR (n:Assertion) REQUIRE n.validTo IS :: ZONED DATETIME;
// Adjudication (KCR-0007-2).
CREATE CONSTRAINT adjudication_recorded_at_exists IF NOT EXISTS FOR (a:Adjudication) REQUIRE a.recordedAt IS NOT NULL;
CREATE CONSTRAINT adjudication_kind_exists IF NOT EXISTS FOR (a:Adjudication) REQUIRE a.adjudicationKind IS NOT NULL;
CREATE CONSTRAINT adjudication_verdict_exists IF NOT EXISTS FOR (a:Adjudication) REQUIRE a.verdict IS NOT NULL;
CREATE CONSTRAINT adjudication_recorded_at_type IF NOT EXISTS FOR (a:Adjudication) REQUIRE a.recordedAt IS :: ZONED DATETIME;
// Every EvidenceAssessment carries a method (INV-407).
CREATE CONSTRAINT evidence_assessment_method_exists IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.methodVersion IS NOT NULL;
CREATE CONSTRAINT evidence_assessment_recorded_at_exists IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.recordedAt IS NOT NULL;
// Snapshot capture clocks.
CREATE CONSTRAINT source_snapshot_retrieved_at_exists IF NOT EXISTS FOR (n:SourceSnapshot) REQUIRE n.retrievedAt IS NOT NULL;
CREATE CONSTRAINT source_snapshot_retrieved_at_type IF NOT EXISTS FOR (n:SourceSnapshot) REQUIRE n.retrievedAt IS :: ZONED DATETIME;
CREATE CONSTRAINT source_revision_event_recorded_at_exists IF NOT EXISTS FOR (n:SourceRevisionEvent) REQUIRE n.recordedAt IS NOT NULL;
CREATE CONSTRAINT source_revision_event_kind_exists IF NOT EXISTS FOR (n:SourceRevisionEvent) REQUIRE n.revisionKind IS NOT NULL;
// Source identity key (canonicalUri present and unique).
CREATE CONSTRAINT source_canonical_uri_key IF NOT EXISTS FOR (n:Source) REQUIRE n.canonicalUri IS NODE KEY;
// Identifier natural key (presence + uniqueness) — replaces the Community uniqueness-only form when available.
CREATE CONSTRAINT identifier_natural_key IF NOT EXISTS FOR (n:Identifier) REQUIRE (n.scheme, n.issuer, n.value) IS NODE KEY;
// Archetype uid presence (uniqueness alone never requires presence).
CREATE CONSTRAINT entity_uid_exists IF NOT EXISTS FOR (n:Entity) REQUIRE n.uid IS NOT NULL;
CREATE CONSTRAINT versioned_state_uid_exists IF NOT EXISTS FOR (n:VersionedState) REQUIRE n.uid IS NOT NULL;
CREATE CONSTRAINT occurrence_uid_exists IF NOT EXISTS FOR (n:Occurrence) REQUIRE n.uid IS NOT NULL;
CREATE CONSTRAINT information_artifact_uid_exists IF NOT EXISTS FOR (n:InformationArtifact) REQUIRE n.uid IS NOT NULL;
CREATE CONSTRAINT assertion_uid_exists IF NOT EXISTS FOR (n:Assertion) REQUIRE n.uid IS NOT NULL;
CREATE CONSTRAINT evidence_assessment_uid_exists IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.uid IS NOT NULL;
// Relationship profiles. Template for every asserted type T:
//   CREATE CONSTRAINT <t>_episode_key IF NOT EXISTS FOR ()-[r:T]-() REQUIRE r.relationshipUid IS RELATIONSHIP KEY;
//   CREATE CONSTRAINT <t>_recorded_from_exists IF NOT EXISTS FOR ()-[r:T]-() REQUIRE r.recordedFrom IS NOT NULL;
//   CREATE CONSTRAINT <t>_assertion_uid_exists IF NOT EXISTS FOR ()-[r:T]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT has_state_episode_key IF NOT EXISTS FOR ()-[r:HAS_STATE]-() REQUIRE r.relationshipUid IS RELATIONSHIP KEY;
CREATE CONSTRAINT has_state_recorded_from_exists IF NOT EXISTS FOR ()-[r:HAS_STATE]-() REQUIRE r.recordedFrom IS NOT NULL;
CREATE CONSTRAINT has_identifier_episode_key IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() REQUIRE r.relationshipUid IS RELATIONSHIP KEY;
CREATE CONSTRAINT has_identifier_recorded_from_exists IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() REQUIRE r.recordedFrom IS NOT NULL;
CREATE CONSTRAINT has_identifier_assertion_uid_exists IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT supersedes_kind_exists IF NOT EXISTS FOR ()-[r:SUPERSEDES]-() REQUIRE r.supersessionKind IS NOT NULL;
CREATE CONSTRAINT supersedes_recorded_at_exists IF NOT EXISTS FOR ()-[r:SUPERSEDES]-() REQUIRE r.recordedAt IS NOT NULL;
CREATE CONSTRAINT authorized_by_use_kind_exists IF NOT EXISTS FOR ()-[r:AUTHORIZED_BY]-() REQUIRE r.useKind IS NOT NULL;
CREATE CONSTRAINT reanchors_anchor_match_exists IF NOT EXISTS FOR ()-[r:REANCHORS]-() REQUIRE r.anchorMatch IS NOT NULL;
