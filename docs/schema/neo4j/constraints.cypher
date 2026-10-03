// Human Upgrade Knowledge Graph — Neo4j 5.x baseline projection
// Run once per database. Domain-specific validity is checked by validation.cypher
// and ingestion application logic because Neo4j constraints do not express the
// full cross-label, relationship-cardinality, or provenance contract.

CREATE CONSTRAINT entity_uid IF NOT EXISTS
FOR (n:Entity) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT versioned_state_uid IF NOT EXISTS
FOR (n:VersionedState) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT occurrence_uid IF NOT EXISTS
FOR (n:Occurrence) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT information_artifact_uid IF NOT EXISTS
FOR (n:InformationArtifact) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT assertion_uid IF NOT EXISTS
FOR (n:Assertion) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT evidence_assessment_uid IF NOT EXISTS
FOR (n:EvidenceAssessment) REQUIRE n.uid IS UNIQUE;

CREATE CONSTRAINT source_canonical_uri IF NOT EXISTS
FOR (n:Source) REQUIRE n.canonicalUri IS UNIQUE;

CREATE CONSTRAINT trial_registration_identity IF NOT EXISTS
FOR (n:TrialRegistration) REQUIRE (n.registry, n.registrationId) IS UNIQUE;

CREATE CONSTRAINT trade_item_identifier_identity IF NOT EXISTS
FOR (n:TradeItemIdentifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE;

CREATE CONSTRAINT publication_doi IF NOT EXISTS
FOR (n:Publication) REQUIRE n.doi IS UNIQUE;

CREATE INDEX assertion_predicate IF NOT EXISTS
FOR (n:Assertion) ON (n.predicate);

CREATE INDEX assertion_status IF NOT EXISTS
FOR (n:Assertion) ON (n.status);

CREATE INDEX assertion_recorded_at IF NOT EXISTS
FOR (n:Assertion) ON (n.recordedAt);

CREATE INDEX snapshot_observed_at IF NOT EXISTS
FOR (n:SourceSnapshot) ON (n.observedAt);

CREATE INDEX product_name IF NOT EXISTS
FOR (n:Product) ON (n.name);

CREATE INDEX ingredient_material_name IF NOT EXISTS
FOR (n:IngredientMaterial) ON (n.name);

CREATE FULLTEXT INDEX knowledge_names IF NOT EXISTS
FOR (n:Product|ProductVariant|IngredientMaterial|ChemicalSubstance|Organization|ConsumerBrand|Study|Publication)
ON EACH [n.name, n.title, n.preferredName, n.legalName];


// ---- Lane 1, round 0009: query-shape invariants (V-1xx) ----
// Constraints that Neo4j 5 can enforce. Property-existence and property-type constraints need Enterprise
// (or AuraDB tiers that include them); see the inline notes. Everything else is service-enforced.

// ======================================================================
// Section B. Constraints and indexes Neo4j 5 can enforce (kept apart from the validation queries above).
// None was executed. Property existence and property type constraints are edition-dependent in Neo4j 5
// (Enterprise and Aura per the Neo4j documentation as remembered; not re-verified in this session), so
// each is marked. Uniqueness constraints and range indexes are available in all editions.
// Everything not listed here is service-enforced: interval ordering (V-102, V-103), exclusivity (V-108),
// supersession and adjudication order (V-109, V-110), derived-edge citation (V-112), and the
// public/private boundary (V-113 to V-116) cannot be expressed as Neo4j constraints.
// ======================================================================

// C-101: uid uniqueness on live GraphQL labels that have no archetype label yet (all editions).
// status: statically-checked
CREATE CONSTRAINT live_product_uid IF NOT EXISTS FOR (n:Product) REQUIRE n.uid IS UNIQUE;
// status: statically-checked
CREATE CONSTRAINT live_organization_uid IF NOT EXISTS FOR (n:Organization) REQUIRE n.uid IS UNIQUE;
// status: statically-checked
CREATE CONSTRAINT live_document_uid IF NOT EXISTS FOR (n:Document) REQUIRE n.uid IS UNIQUE;
// status: statically-checked
CREATE CONSTRAINT live_chunk_uid IF NOT EXISTS FOR (n:Chunk) REQUIRE n.uid IS UNIQUE;
// status: statically-checked
CREATE CONSTRAINT live_claim_uid IF NOT EXISTS FOR (n:Claim) REQUIRE n.uid IS UNIQUE;
// status: statically-checked
CREATE CONSTRAINT live_claim_occurrence_uid IF NOT EXISTS FOR (n:ClaimOccurrence) REQUIRE n.uid IS UNIQUE;

// C-102: assertion recordedAt must exist (Enterprise/Aura property existence constraint).
// status: statically-checked (edition-dependent)
CREATE CONSTRAINT assertion_recorded_at_exists IF NOT EXISTS FOR (n:Assertion) REQUIRE n.recordedAt IS NOT NULL;

// C-103: assertion and adjudication time properties are DATETIME (Enterprise/Aura property type constraint).
// status: statically-checked (edition-dependent)
CREATE CONSTRAINT assertion_recorded_at_type IF NOT EXISTS FOR (n:Assertion) REQUIRE n.recordedAt IS :: ZONED DATETIME;
// status: statically-checked (edition-dependent)
CREATE CONSTRAINT adjudication_reviewed_at_type IF NOT EXISTS FOR (n:Adjudication) REQUIRE n.reviewedAt IS :: ZONED DATETIME;

// C-104: range indexes that the query shapes depend on (all editions).
// status: statically-checked
CREATE INDEX assertion_predicate_recorded IF NOT EXISTS FOR (n:Assertion) ON (n.predicate, n.recordedAt);
// status: statically-checked
CREATE INDEX adjudication_reviewed_at IF NOT EXISTS FOR (n:Adjudication) ON (n.reviewedAt);
// status: statically-checked
CREATE INDEX snapshot_retrieved_at IF NOT EXISTS FOR (n:SourceSnapshot) ON (n.retrievedAt);
// status: statically-checked
CREATE INDEX formulation_edge_recorded_from IF NOT EXISTS FOR ()-[r:HAS_FORMULATION_VERSION]-() ON (r.recordedFrom);


// ---- Lane 2, rounds 0002 and 0003: evidence applicability and mechanisms (V-2xx) ----
// Constraints that Neo4j 5 can enforce. Property-existence and property-type constraints need Enterprise
// (or AuraDB tiers that include them); see the inline notes. Everything else is service-enforced.

// Community-edition-compatible indexes for the query patterns above:
// status: statically-checked
CREATE INDEX applicability_dimension_kind IF NOT EXISTS FOR (d:ApplicabilityDimension) ON (d.dimension, d.verdict);
// status: statically-checked
CREATE INDEX assertion_basis_kind IF NOT EXISTS FOR (a:Assertion) ON (a.basisKind);
// status: statically-checked
CREATE INDEX study_result_analysis IF NOT EXISTS FOR (r:StudyResult) ON (r.analysisKind, r.statisticalConclusion);
// status: statically-checked
CREATE INDEX synthesis_recorded_at IF NOT EXISTS FOR (s:EvidenceSynthesis) ON (s.recordedAt);


// ---- Lane 3, rounds 0004 and 0005: diagnostics, regulatory, manufacturing, commerce (V-3xx) ----
// Constraints that Neo4j 5 can enforce. Property-existence and property-type constraints need Enterprise
// (or AuraDB tiers that include them); see the inline notes. Everything else is service-enforced.

// ---------------------------------------------------------------------------
// Constraints Neo4j 5 can enforce (Community edition unless marked)
// ---------------------------------------------------------------------------

// status: statically-checked
CREATE CONSTRAINT metric_loinc_code IF NOT EXISTS
FOR (n:Metric) REQUIRE n.loincCode IS UNIQUE;

// status: statically-checked
CREATE CONSTRAINT regulatory_submission_identity IF NOT EXISTS
FOR (n:RegulatorySubmission) REQUIRE (n.jurisdiction, n.submissionKind, n.identifier) IS UNIQUE;

// status: statically-checked
CREATE CONSTRAINT lab_test_local_code IF NOT EXISTS
FOR (n:LabTest) REQUIRE (n.issuerUid, n.localTestCode) IS UNIQUE;

// status: statically-checked
CREATE INDEX regulatory_status_kind IF NOT EXISTS
FOR (n:RegulatoryStatus) ON (n.statusKind, n.jurisdiction);

// status: statically-checked
CREATE INDEX algorithm_version_basis IF NOT EXISTS
FOR (n:AlgorithmVersion) ON (n.versionBasis);

// status: statically-checked
CREATE INDEX price_observation_time IF NOT EXISTS
FOR (n:PriceObservation) ON (n.observedAt);

// Enterprise edition only (property existence and type constraints):
// status: statically-checked
CREATE CONSTRAINT diagnostic_result_kind_exists IF NOT EXISTS
FOR (n:DiagnosticResult) REQUIRE n.resultKind IS NOT NULL;

// status: statically-checked
CREATE CONSTRAINT regulatory_status_kind_exists IF NOT EXISTS
FOR (n:RegulatoryStatus) REQUIRE n.statusKind IS NOT NULL;

// status: statically-checked
CREATE CONSTRAINT price_observation_amount_type IF NOT EXISTS
FOR (n:PriceObservation) REQUIRE n.amount IS :: FLOAT;


// ---- Lane 4, round 0006: claims, documents, provenance (V-4xx) ----
// Constraints that Neo4j 5 can enforce. Property-existence and property-type constraints need Enterprise
// (or AuraDB tiers that include them); see the inline notes. Everything else is service-enforced.

// =====================================================================
// F. Constraints and indexes Neo4j 5 can enforce (separate from the
//    zero-row queries above). Edition requirements are stated per line.
// =====================================================================

// Community and Enterprise: lookup indexes.
CREATE INDEX source_locator_quote_hash IF NOT EXISTS
FOR (n:SourceLocator) ON (n.quoteHash);

CREATE INDEX source_snapshot_content_hash IF NOT EXISTS
FOR (n:SourceSnapshot) ON (n.contentHash);

CREATE INDEX activity_external_run IF NOT EXISTS
FOR (n:Activity) ON (n.externalRunSystem, n.externalRunId);

CREATE INDEX assertion_basis IF NOT EXISTS
FOR (n:Assertion) ON (n.assertionBasis);

CREATE INDEX assertion_speech_act IF NOT EXISTS
FOR (n:Assertion) ON (n.speechAct);

// Community and Enterprise: one Activity per external research run.
CREATE CONSTRAINT activity_external_run_unique IF NOT EXISTS
FOR (n:Activity) REQUIRE (n.externalRunSystem, n.externalRunId) IS UNIQUE;

// Enterprise Edition only: property existence and type constraints.
CREATE CONSTRAINT source_locator_selector_kind_exists IF NOT EXISTS
FOR (n:SourceLocator) REQUIRE n.selectorKind IS NOT NULL;

CREATE CONSTRAINT source_locator_normalization_exists IF NOT EXISTS
FOR (n:SourceLocator) REQUIRE n.normalizationVersion IS NOT NULL;

CREATE CONSTRAINT source_locator_media_start_type IF NOT EXISTS
FOR (n:SourceLocator) REQUIRE n.mediaStartSeconds IS :: FLOAT;

CREATE CONSTRAINT retells_link_basis_exists IF NOT EXISTS
FOR ()-[r:RETELLS]-() REQUIRE r.linkBasis IS NOT NULL;

CREATE CONSTRAINT retelling_assessment_method_exists IF NOT EXISTS
FOR (n:RetellingFidelityAssessment) REQUIRE n.methodVersion IS NOT NULL;
// ---- Lane 5, rounds 0007 and 0008: time, private context, protocols, recommendations (V-5xx) ----
// Constraints that Neo4j 5 can enforce. Property-existence and property-type constraints need Enterprise
// (or AuraDB tiers that include them); see the inline notes. Everything else is service-enforced.
// =====================================================================================
// Constraints Neo4j 5 can enforce (separate from validation; edition noted)
// =====================================================================================
// Existing archetype uid uniqueness constraints in neo4j/constraints.cypher already cover SourceRevisionEvent
// (Occurrence), ProtocolEdition (VersionedState), ProtocolStep (Entity), UseContextProfile (Entity), PolicyVersion (VersionedState).
// C-501 (Enterprise Edition): assertion recorded time must exist.
// status: statically-checked
// (duplicate constraint assertion_recorded_at_exists from another lane removed at integration; first definition kept)
// C-502 (Enterprise Edition, Neo4j 5.9+ property type constraints): assertion recorded time is a zoned datetime.
// status: statically-checked
// (duplicate constraint assertion_recorded_at_type from another lane removed at integration; first definition kept)

// C-503 (Enterprise Edition): adjudication recorded time must exist (KCR-0007-2).
// status: statically-checked
CREATE CONSTRAINT adjudication_recorded_at_exists IF NOT EXISTS
FOR (a:Adjudication) REQUIRE a.recordedAt IS NOT NULL;

// C-504 (Enterprise Edition): every formulation attachment episode has recordedFrom.
// status: statically-checked
CREATE CONSTRAINT has_formulation_version_recorded_from_exists IF NOT EXISTS
FOR ()-[r:HAS_FORMULATION_VERSION]-() REQUIRE r.recordedFrom IS NOT NULL;

// C-505 (relationship property uniqueness, Neo4j 5.7+; edition availability to be verified for the deployment):
// one relationshipUid per episode.
// status: statically-checked
CREATE CONSTRAINT has_formulation_version_relationship_uid IF NOT EXISTS
FOR ()-[r:HAS_FORMULATION_VERSION]-() REQUIRE r.relationshipUid IS UNIQUE;

// I-501: range index for as-of scans. Range indexes do not index nulls, so "recordedTo IS NULL" current-view
// queries cannot use it; the API may materialize a current-view flag as a derived projection if needed.
// status: statically-checked
CREATE INDEX has_formulation_version_recorded_from IF NOT EXISTS
FOR ()-[r:HAS_FORMULATION_VERSION]-() ON (r.recordedFrom);

// I-502: assertion recordedTo lookups for supersession audits.
// status: statically-checked
CREATE INDEX assertion_recorded_to IF NOT EXISTS
FOR (a:Assertion) ON (a.recordedTo);
