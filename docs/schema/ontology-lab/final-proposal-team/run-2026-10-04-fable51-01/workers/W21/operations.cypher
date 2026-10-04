// =====================================================================================================
// W21 operations recommendation (claims_and_documents narrative scope). Run after the baseline
// docs/schema/neo4j/constraints.cypher (which already creates: archetype-label uid uniqueness for Entity,
// InformationArtifact, Assertion, EvidenceAssessment; live_claim_uid; live_claim_occurrence_uid; assertion_basis;
// assertion_speech_act; assertion_predicate(_recorded); source_locator_quote_hash; retells_link_basis_exists and
// retelling_assessment_method_exists [Enterprise]). Uniqueness uses STORED property names. No @unique directive
// exists in @neo4j/graphql 7.6.3, so every uniqueness rule lives here.
// Tested: Neo4j 5.26.31 Community (embedded) on 2026-10-04 -- see 07-operations.md for per-statement results.
// =====================================================================================================

// ---- Section A: Community-compatible (uniqueness and range/text/fulltext indexes) ----------------------

// A1: label-scoped uid uniqueness for W21 node labels. Redundant with the archetype-label constraints for
// correctness, but gives each primary label its own index-backed MERGE/MATCH on uid (fixtures and ingestion bind
// (:Episode {uid}), not (:Entity {uid})).
CREATE CONSTRAINT w21_platform_uid IF NOT EXISTS FOR (n:Platform) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_channel_uid IF NOT EXISTS FOR (n:Channel) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_series_uid IF NOT EXISTS FOR (n:Series) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_episode_uid IF NOT EXISTS FOR (n:Episode) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_episode_segment_uid IF NOT EXISTS FOR (n:EpisodeSegment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_relationship_assertion_uid IF NOT EXISTS FOR (n:RelationshipAssertion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_claim_evidence_assessment_uid IF NOT EXISTS FOR (n:ClaimEvidenceAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_retelling_fidelity_assessment_uid IF NOT EXISTS FOR (n:RetellingFidelityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w21_conflict_relevance_assessment_uid IF NOT EXISTS FOR (n:ConflictRelevanceAssessment) REQUIRE n.uid IS UNIQUE;

// A2: live GraphQL id (= opaque uid segment, stored as `id` for every W21 type; no alias) unique per primary label,
// because @neo4j/graphql resolves `where: {id: ...}` per label.
CREATE CONSTRAINT w21_platform_id IF NOT EXISTS FOR (n:Platform) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_channel_id IF NOT EXISTS FOR (n:Channel) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_series_id IF NOT EXISTS FOR (n:Series) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_episode_id IF NOT EXISTS FOR (n:Episode) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_episode_segment_id IF NOT EXISTS FOR (n:EpisodeSegment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_claim_id IF NOT EXISTS FOR (n:Claim) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_claim_occurrence_id IF NOT EXISTS FOR (n:ClaimOccurrence) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w21_relationship_assertion_id IF NOT EXISTS FOR (n:RelationshipAssertion) REQUIRE n.id IS UNIQUE;

// A3: retrieval indexes justified by CQs.
// CQ-CL-08 sponsor read versus editorial: filter occurrences by segment kind and segments by type.
CREATE INDEX w21_claim_occurrence_segment_kind IF NOT EXISTS FOR (n:ClaimOccurrence) ON (n.segmentKind);
CREATE INDEX w21_episode_segment_type IF NOT EXISTS FOR (n:EpisodeSegment) ON (n.segmentType);
// CQ-CL-05 / CQ-AX-18: statement date = container publication time (as-of joins to role intervals).
CREATE INDEX w21_episode_published_at IF NOT EXISTS FOR (n:Episode) ON (n.publishedAt);
// CQ-CL-02: claim type facet.
CREATE INDEX w21_claim_type IF NOT EXISTS FOR (n:Claim) ON (n.claimType);
// CQ-CL-05: relevance and disclosure facets.
CREATE INDEX w21_conflict_relevance_level IF NOT EXISTS FOR (n:ConflictRelevanceAssessment) ON (n.relevanceLevel, n.disclosureFinding);
// Relationship-property indexes: idempotent MERGE keys and QS-4 citation lookups.
CREATE INDEX w21_appears_in_role IF NOT EXISTS FOR ()-[r:APPEARS_IN]-() ON (r.roleType);
CREATE INDEX w21_appears_in_assertion IF NOT EXISTS FOR ()-[r:APPEARS_IN]-() ON (r.assertionUid);
CREATE INDEX w21_sponsors_content_assertion IF NOT EXISTS FOR ()-[r:SPONSORS_CONTENT]-() ON (r.assertionUid);
CREATE INDEX w21_retells_relationship_uid IF NOT EXISTS FOR ()-[r:RETELLS]-() ON (r.relationshipUid);
CREATE INDEX w21_qualified_by_relationship_uid IF NOT EXISTS FOR ()-[r:QUALIFIED_BY]-() ON (r.relationshipUid);

// A4: live @fulltext indexes retained by name (D-015), created over STORED property names.
CREATE FULLTEXT INDEX EpisodeSearch IF NOT EXISTS FOR (n:Episode) ON EACH [n.name, n.title, n.summaryText];
CREATE FULLTEXT INDEX ClaimSearch IF NOT EXISTS FOR (n:Claim) ON EACH [n.name, n.description, n.searchText];

// ---- Section B: Enterprise Edition only (property existence / type). Expected to be REJECTED on Community. ----
CREATE CONSTRAINT w21_claim_occurrence_predicate_exists IF NOT EXISTS FOR (n:ClaimOccurrence) REQUIRE n.predicate IS NOT NULL;
CREATE CONSTRAINT w21_episode_segment_type_exists IF NOT EXISTS FOR (n:EpisodeSegment) REQUIRE n.segmentType IS NOT NULL;
CREATE CONSTRAINT w21_conflict_relevance_method_exists IF NOT EXISTS FOR (n:ConflictRelevanceAssessment) REQUIRE n.methodVersion IS NOT NULL;
CREATE CONSTRAINT w21_qualified_by_kind_exists IF NOT EXISTS FOR ()-[r:QUALIFIED_BY]-() REQUIRE r.qualificationKind IS NOT NULL;
CREATE CONSTRAINT w21_retells_mode_exists IF NOT EXISTS FOR ()-[r:RETELLS]-() REQUIRE r.retellingMode IS NOT NULL;
CREATE CONSTRAINT w21_appears_in_role_exists IF NOT EXISTS FOR ()-[r:APPEARS_IN]-() REQUIRE r.roleType IS NOT NULL;
CREATE CONSTRAINT w21_media_end_type IF NOT EXISTS FOR (n:SourceLocator) REQUIRE n.mediaEndSeconds IS :: FLOAT;
