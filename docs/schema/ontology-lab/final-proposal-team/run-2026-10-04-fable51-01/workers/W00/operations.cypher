// W00 kernel operations — Community-runnable baseline (Neo4j 5.26.31 Community; also valid on Enterprise).
// Run: run-2026-10-04-fable51-01, worker W00. Recommendation for Fable's
// docs/schema/neo4j/final_biotech_schema_operations.cypher; not a deployment script.
// Every statement is idempotent (IF NOT EXISTS). Names that already exist in docs/schema/neo4j/constraints.cypher
// with the SAME definition are reused verbatim so the two files compose without conflict.
// Enterprise-only statements are in operations-enterprise.cypher (never mixed in here).
// Executed on 2026-10-04 against an embedded 5.26.31 Community instance: see 06-fixtures-and-queries.md §1.

// ---------------------------------------------------------------------------------------------------
// A. Archetype-label uid uniqueness (unchanged names from constraints.cypher). D-001: every node carries
//    exactly one archetype label, so these six constraints cover every shared node. Global uniqueness
//    ACROSS archetypes is not expressible as a constraint: V-000a audits it; the uid type token plus an
//    opaque UUID/ULID make a cross-archetype collision a service bug, not a data state.
// ---------------------------------------------------------------------------------------------------
CREATE CONSTRAINT entity_uid IF NOT EXISTS FOR (n:Entity) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT versioned_state_uid IF NOT EXISTS FOR (n:VersionedState) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT occurrence_uid IF NOT EXISTS FOR (n:Occurrence) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT information_artifact_uid IF NOT EXISTS FOR (n:InformationArtifact) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT assertion_uid IF NOT EXISTS FOR (n:Assertion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT evidence_assessment_uid IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.uid IS UNIQUE;

// ---------------------------------------------------------------------------------------------------
// B. Primary-label uid and live-id uniqueness for W00 types. A uniqueness constraint is index-backed; the
//    planner uses a label's index only when the pattern names that label, so Cypher that binds
//    (n:SourceLocator {uid: $u}) or GraphQL-generated MATCH (this:SourceLocator:InformationArtifact)
//    WHERE this.id = $id needs a primary-label index. `id` is the opaque segment of uid (INV-106).
//    Domain owners add the same pair for their primary labels (pattern in 07-operations.md §2).
// ---------------------------------------------------------------------------------------------------
CREATE CONSTRAINT source_uid IF NOT EXISTS FOR (n:Source) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_id IF NOT EXISTS FOR (n:Source) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_snapshot_uid IF NOT EXISTS FOR (n:SourceSnapshot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_snapshot_id IF NOT EXISTS FOR (n:SourceSnapshot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_locator_uid IF NOT EXISTS FOR (n:SourceLocator) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_locator_id IF NOT EXISTS FOR (n:SourceLocator) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_revision_event_uid IF NOT EXISTS FOR (n:SourceRevisionEvent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_revision_event_id IF NOT EXISTS FOR (n:SourceRevisionEvent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT assertion_id IF NOT EXISTS FOR (n:Assertion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT adjudication_uid IF NOT EXISTS FOR (n:Adjudication) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT adjudication_id IF NOT EXISTS FOR (n:Adjudication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT resolution_hypothesis_uid IF NOT EXISTS FOR (n:ResolutionHypothesis) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT resolution_hypothesis_id IF NOT EXISTS FOR (n:ResolutionHypothesis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT equivalence_assessment_uid IF NOT EXISTS FOR (n:EquivalenceAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT equivalence_assessment_id IF NOT EXISTS FOR (n:EquivalenceAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT agent_uid IF NOT EXISTS FOR (n:Agent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT agent_id IF NOT EXISTS FOR (n:Agent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT activity_uid IF NOT EXISTS FOR (n:Activity) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT activity_id IF NOT EXISTS FOR (n:Activity) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT identifier_uid IF NOT EXISTS FOR (n:Identifier) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT identifier_id IF NOT EXISTS FOR (n:Identifier) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT mention_uid IF NOT EXISTS FOR (n:Mention) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT mention_id IF NOT EXISTS FOR (n:Mention) REQUIRE n.id IS UNIQUE;

// ---------------------------------------------------------------------------------------------------
// C. Natural keys (Community uniqueness; on Enterprise the Identifier key is also a NODE KEY, see companion).
//    Uniqueness does not require presence: a node missing a key property is not checked (service-enforced
//    presence on Community).
// ---------------------------------------------------------------------------------------------------
CREATE CONSTRAINT source_canonical_uri IF NOT EXISTS FOR (n:Source) REQUIRE n.canonicalUri IS UNIQUE;
// (scheme, issuer, value): the same (scheme, value) from two issuers is two identifiers (forbidden implication
// SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS -> SAME_IDENTITY). Covers TradeItemIdentifier (it carries :Identifier).
CREATE CONSTRAINT identifier_scheme_issuer_value IF NOT EXISTS FOR (n:Identifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE;
CREATE CONSTRAINT trade_item_identifier_identity IF NOT EXISTS FOR (n:TradeItemIdentifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE;
CREATE CONSTRAINT activity_external_run_unique IF NOT EXISTS FOR (n:Activity) REQUIRE (n.externalRunSystem, n.externalRunId) IS UNIQUE;

// ---------------------------------------------------------------------------------------------------
// D. Relationship-episode identity (relationship property uniqueness, Neo4j 5.7+, accepted by 5.26 Community).
//    One relationship per recorded-time episode; relationshipUid is the MERGE key for parallel episodes.
//    Template for EVERY asserted or bitemporal relationship type T (domain owners instantiate it):
//      CREATE CONSTRAINT <t>_relationship_uid IF NOT EXISTS FOR ()-[r:T]-() REQUIRE r.relationshipUid IS UNIQUE;
// ---------------------------------------------------------------------------------------------------
CREATE CONSTRAINT has_state_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_STATE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT has_identifier_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() REQUIRE r.relationshipUid IS UNIQUE;

// ---------------------------------------------------------------------------------------------------
// E. Range indexes required by QS-1 (trace), QS-2 (as-of), QS-4 (guard), V-1xx/V-5xx audits.
// ---------------------------------------------------------------------------------------------------
// QS-2a: recorded-time slice on assertions.
CREATE INDEX assertion_recorded_at IF NOT EXISTS FOR (n:Assertion) ON (n.recordedAt);
CREATE INDEX assertion_recorded_to IF NOT EXISTS FOR (a:Assertion) ON (a.recordedTo);
// QS-2a / QS-7: predicate + recorded time (composite; equality on predicate, range on recordedAt).
CREATE INDEX assertion_predicate_recorded IF NOT EXISTS FOR (n:Assertion) ON (n.predicate, n.recordedAt);
CREATE INDEX assertion_status IF NOT EXISTS FOR (n:Assertion) ON (n.status);
// QS-1a / CQ-TM-01: adjudications as of R (recordedAt is the recorded-time clock; reviewedAt kept for QS-1a text).
CREATE INDEX adjudication_recorded_at IF NOT EXISTS FOR (n:Adjudication) ON (n.recordedAt);
CREATE INDEX adjudication_reviewed_at IF NOT EXISTS FOR (n:Adjudication) ON (n.reviewedAt);
// QS-1a / V-111 / V-504: snapshot clocks and reproducibility lookups.
CREATE INDEX snapshot_retrieved_at IF NOT EXISTS FOR (n:SourceSnapshot) ON (n.retrievedAt);
CREATE INDEX snapshot_observed_at IF NOT EXISTS FOR (n:SourceSnapshot) ON (n.observedAt);
CREATE INDEX source_snapshot_content_hash IF NOT EXISTS FOR (n:SourceSnapshot) ON (n.contentHash);
// Echo detection / re-anchoring: same quote across snapshots and sources.
CREATE INDEX source_locator_quote_hash IF NOT EXISTS FOR (n:SourceLocator) ON (n.quoteHash);
// CQ-TM-06: revisions learned in a window.
CREATE INDEX source_revision_event_recorded_at IF NOT EXISTS FOR (n:SourceRevisionEvent) ON (n.recordedAt);
// QS-8 / CQ-ID-04: cross-issuer lookup by value (the composite uniqueness index leads with scheme, issuer).
CREATE INDEX identifier_value IF NOT EXISTS FOR (n:Identifier) ON (n.value);
// QS-2b on asserted edges: recordedFrom per relationship type, and assertionUid for regeneration on supersession.
// Template for EVERY asserted relationship type T:
//   CREATE INDEX <t>_recorded_from IF NOT EXISTS FOR ()-[r:T]-() ON (r.recordedFrom);
//   CREATE INDEX <t>_assertion_uid IF NOT EXISTS FOR ()-[r:T]-() ON (r.assertionUid);
// and for every derived type D:
//   CREATE INDEX <d>_projection_of IF NOT EXISTS FOR ()-[r:D]-() ON (r.projectionOfAssertionUid);
CREATE INDEX has_state_recorded_from IF NOT EXISTS FOR ()-[r:HAS_STATE]-() ON (r.recordedFrom);
CREATE INDEX has_state_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_STATE]-() ON (r.assertionUid);
CREATE INDEX has_identifier_recorded_from IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() ON (r.recordedFrom);
CREATE INDEX has_identifier_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() ON (r.assertionUid);
// Supersession audits (V-506, V-507) and CQ-RC-07 triage by commit time.
CREATE INDEX supersedes_recorded_at IF NOT EXISTS FOR ()-[r:SUPERSEDES]-() ON (r.recordedAt);
// QS-8 candidates from extracted surface forms (lexical score only; never identity).
CREATE FULLTEXT INDEX mention_surface_form IF NOT EXISTS FOR (n:Mention) ON EACH [n.surfaceForm];
