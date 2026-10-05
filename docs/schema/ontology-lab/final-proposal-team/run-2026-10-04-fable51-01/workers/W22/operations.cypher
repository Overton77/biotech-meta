// W22 media operations proposal (run-2026-10-04-fable51-01). Neo4j 5.26 target.
// Section A runs on Community and Enterprise. Section B needs Enterprise (property existence and type constraints);
// Community rejects those statements (baseline replay, 00-baseline.md fact 3).
// uid uniqueness for every W22 node is already enforced by the archetype constraints in docs/schema/neo4j/constraints.cypher
// (InformationArtifact, VersionedState, EvidenceAssessment uid IS UNIQUE), because D-001 stores archetype labels.
// Stored property names are used throughout (no GraphQL aliases exist for media types).

// ---------------- Section A: all editions ----------------

// A-1: live GraphQL id lookups (id is the opaque uid segment; @id generates it on create).
CREATE CONSTRAINT media_asset_id IF NOT EXISTS FOR (n:MediaAsset) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_variant_id IF NOT EXISTS FOR (n:MediaVariant) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_annotation_id IF NOT EXISTS FOR (n:MediaAnnotation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT graph_view_id IF NOT EXISTS FOR (n:GraphView) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT figure_panel_id IF NOT EXISTS FOR (n:FigurePanel) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT product_label_region_id IF NOT EXISTS FOR (n:ProductLabelRegion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_suitability_assessment_id IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_rights_record_id IF NOT EXISTS FOR (n:MediaRightsRecord) REQUIRE n.id IS UNIQUE;

// A-2: byte-identity lookups (dedup at ingestion; rendition <-> snapshot equality joins in MEDIA-EV-1, V-602, Q-MP5-1).
// Not unique: the same bytes may legitimately appear as two renditions of two assets until an EquivalenceAssessment merges them.
CREATE INDEX media_variant_content_hash IF NOT EXISTS FOR (n:MediaVariant) ON (n.contentHash);
CREATE INDEX media_asset_content_hash IF NOT EXISTS FOR (n:MediaAsset) ON (n.contentHash);
CREATE INDEX source_snapshot_content_hash IF NOT EXISTS FOR (n:SourceSnapshot) ON (n.contentHash);

// A-3: near-duplicate candidate lookup (exact match on a perceptual hash value within one algorithm; Hamming-distance
// search is done outside the database).
CREATE INDEX media_variant_perceptual_hash IF NOT EXISTS FOR (n:MediaVariant) ON (n.perceptualHashAlgorithm, n.perceptualHash);

// A-4: rendition and annotation filters used by V-606/V-607 and the evidence derivation.
CREATE INDEX media_variant_kind IF NOT EXISTS FOR (n:MediaVariant) ON (n.variantKind);
CREATE INDEX media_asset_generation_mode IF NOT EXISTS FOR (n:MediaAsset) ON (n.generationMode);
CREATE INDEX source_locator_media_annotation_uid IF NOT EXISTS FOR (n:SourceLocator) ON (n.mediaAnnotationUid);

// A-5: selection queries (CQ-MD-C01/C02): assessment by dimension and role; rights by status.
CREATE INDEX media_assessment_dimension_role IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) ON (n.dimension, n.intendedRole, n.status);
CREATE INDEX media_assessment_method IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) ON (n.methodVersion);
CREATE INDEX media_rights_status IF NOT EXISTS FOR (n:MediaRightsRecord) ON (n.rightsStatus);

// A-6: asserted media edges looked up by their assertion (V-612, capture-fidelity review) and by recorded-time episode.
CREATE INDEX depicts_assertion_uid IF NOT EXISTS FOR ()-[r:DEPICTS]-() ON (r.assertionUid);
CREATE INDEX explains_assertion_uid IF NOT EXISTS FOR ()-[r:EXPLAINS]-() ON (r.assertionUid);
CREATE INDEX visualizes_assertion_uid IF NOT EXISTS FOR ()-[r:VISUALIZES]-() ON (r.assertionUid);
CREATE INDEX annotates_subject_assertion_uid IF NOT EXISTS FOR ()-[r:ANNOTATES_SUBJECT]-() ON (r.assertionUid);
CREATE INDEX has_rights_record_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_RIGHTS_RECORD]-() ON (r.assertionUid);
CREATE INDEX depicts_relationship_uid IF NOT EXISTS FOR ()-[r:DEPICTS]-() ON (r.relationshipUid);
CREATE INDEX evidences_rule IF NOT EXISTS FOR ()-[r:EVIDENCES]-() ON (r.derivationRule);

// A-7: full-text indexes retained from the live schema (D-015), stored property names.
CREATE FULLTEXT INDEX MediaAssetSearch IF NOT EXISTS FOR (n:MediaAsset) ON EACH [n.name, n.description, n.title, n.altText, n.caption, n.transcriptText, n.ocrText, n.searchText];
CREATE FULLTEXT INDEX GraphViewSearch IF NOT EXISTS FOR (n:GraphView) ON EACH [n.name, n.description, n.searchText, n.queryText];

// ---------------- Section B: Enterprise only (property existence / type) ----------------
// status: edition-dependent; rejected on Community. Service-side validation (07-operations.md) is required either way.

CREATE CONSTRAINT media_variant_kind_exists IF NOT EXISTS FOR (n:MediaVariant) REQUIRE n.variantKind IS NOT NULL;
CREATE CONSTRAINT media_asset_type_exists IF NOT EXISTS FOR (n:MediaAsset) REQUIRE n.assetType IS NOT NULL;
CREATE CONSTRAINT media_annotation_type_exists IF NOT EXISTS FOR (n:MediaAnnotation) REQUIRE n.annotationType IS NOT NULL;
CREATE CONSTRAINT media_assessment_method_exists IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) REQUIRE n.methodVersion IS NOT NULL;
CREATE CONSTRAINT media_assessment_dimension_exists IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) REQUIRE n.dimension IS NOT NULL;
CREATE CONSTRAINT media_rights_status_exists IF NOT EXISTS FOR (n:MediaRightsRecord) REQUIRE n.rightsStatus IS NOT NULL;
CREATE CONSTRAINT media_rights_payload_hash_exists IF NOT EXISTS FOR (n:MediaRightsRecord) REQUIRE n.payloadHash IS NOT NULL;
CREATE CONSTRAINT media_variant_width_type IF NOT EXISTS FOR (n:MediaVariant) REQUIRE n.widthPx IS :: INTEGER;
CREATE CONSTRAINT media_annotation_x_type IF NOT EXISTS FOR (n:MediaAnnotation) REQUIRE n.x IS :: FLOAT;
CREATE CONSTRAINT depicts_assertion_uid_exists IF NOT EXISTS FOR ()-[r:DEPICTS]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT explains_assertion_uid_exists IF NOT EXISTS FOR ()-[r:EXPLAINS]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT has_rights_record_assertion_uid_exists IF NOT EXISTS FOR ()-[r:HAS_RIGHTS_RECORD]-() REQUIRE r.assertionUid IS NOT NULL;
