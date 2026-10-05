// W08 operations (proposal; Neo4j 5.26 Community unless marked). Stored property names only. Idempotent (IF NOT EXISTS).
// Executed on embedded Neo4j 5.26.31 Community with the W08 fixtures loaded (results in checks/results/operations.json).

// Node identity: one node per uid per W08 label (Community supports node property uniqueness constraints).
CREATE CONSTRAINT technology_platform_uid IF NOT EXISTS FOR (n:TechnologyPlatform) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT tool_or_instrument_uid IF NOT EXISTS FOR (n:ToolOrInstrument) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT device_uid IF NOT EXISTS FOR (n:Device) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT sensor_uid IF NOT EXISTS FOR (n:Sensor) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT modality_uid IF NOT EXISTS FOR (n:Modality) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT firmware_version_uid IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.uid IS UNIQUE;

// Live GraphQL id (opaque segment of uid) stays unique per label (generated mutations look nodes up by id).
CREATE CONSTRAINT technology_platform_id IF NOT EXISTS FOR (n:TechnologyPlatform) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT tool_or_instrument_id IF NOT EXISTS FOR (n:ToolOrInstrument) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT device_id IF NOT EXISTS FOR (n:Device) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT sensor_id IF NOT EXISTS FOR (n:Sensor) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT modality_id IF NOT EXISTS FOR (n:Modality) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT firmware_version_id IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.id IS UNIQUE;

// FirmwareVersion state identity: payloadHash unique (device uid + component + label).
CREATE CONSTRAINT firmware_version_payload_hash IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.payloadHash IS UNIQUE;

// Asserted W08 edges: one relationshipUid per episode (relationship property uniqueness constraints, Neo4j 5.7+).
CREATE CONSTRAINT rel_develops_platform_uid IF NOT EXISTS FOR ()-[r:DEVELOPS_PLATFORM]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_uses_platform_uid IF NOT EXISTS FOR ()-[r:USES_PLATFORM]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_uses_equipment_uid IF NOT EXISTS FOR ()-[r:USES_EQUIPMENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_implements_platform_uid IF NOT EXISTS FOR ()-[r:IMPLEMENTS_PLATFORM]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_uses_modality_uid IF NOT EXISTS FOR ()-[r:USES_MODALITY]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_has_sensor_uid IF NOT EXISTS FOR ()-[r:HAS_SENSOR]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_embodies_model_uid IF NOT EXISTS FOR ()-[r:EMBODIES_MODEL]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT rel_runs_on_device_uid IF NOT EXISTS FOR ()-[r:RUNS_ON_DEVICE]-() REQUIRE r.relationshipUid IS UNIQUE;

// Retrieval: assertion-to-edge joins (V-W08-04, QS-4a) and as-of filters on recordedTo.
CREATE INDEX rel_uses_platform_assertion IF NOT EXISTS FOR ()-[r:USES_PLATFORM]-() ON (r.assertionUid);
CREATE INDEX rel_uses_equipment_assertion IF NOT EXISTS FOR ()-[r:USES_EQUIPMENT]-() ON (r.assertionUid);
CREATE INDEX rel_implements_platform_assertion IF NOT EXISTS FOR ()-[r:IMPLEMENTS_PLATFORM]-() ON (r.assertionUid);
CREATE INDEX rel_runs_on_device_assertion IF NOT EXISTS FOR ()-[r:RUNS_ON_DEVICE]-() ON (r.assertionUid);

// Lookup by vendor version label (ingestion upsert of release notes; Q-W08-04).
CREATE INDEX firmware_version_label IF NOT EXISTS FOR (n:FirmwareVersion) ON (n.versionLabel);

// Live fulltext index retained with stored property names (D-015).
CREATE FULLTEXT INDEX TechnologyPlatformSearch IF NOT EXISTS FOR (n:TechnologyPlatform) ON EACH [n.name, n.description, n.searchText];

// ENTERPRISE ONLY (not executed on Community; Community rejects existence/type constraints, baseline fact 3):
// CREATE CONSTRAINT device_uid_exists IF NOT EXISTS FOR (n:Device) REQUIRE n.uid IS NOT NULL;
// CREATE CONSTRAINT device_entity_type_exists IF NOT EXISTS FOR (n:Device) REQUIRE n.entityType IS NOT NULL;
// CREATE CONSTRAINT firmware_version_label_exists IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.versionLabel IS NOT NULL;
// CREATE CONSTRAINT firmware_version_label_string IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.versionLabel IS :: STRING;
// CREATE CONSTRAINT rel_uses_platform_assertion_exists IF NOT EXISTS FOR ()-[r:USES_PLATFORM]-() REQUIRE r.assertionUid IS NOT NULL;
