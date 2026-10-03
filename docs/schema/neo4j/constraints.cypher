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
