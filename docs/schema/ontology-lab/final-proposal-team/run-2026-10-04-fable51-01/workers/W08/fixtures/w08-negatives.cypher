// W08 fixture 4: negative cases (load AFTER fixtures 1-3; each block is expected to fail a named validator)
// Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.
// All uids contain 'w08-neg-' so they can be removed with one DETACH DELETE. Expected rows are in 06-fixtures-and-queries.md.
// N1 platform used as instrument (V-W08-01); N2 regulatory/performance property on a Device (V-W08-02); N3 status
// attached to a Device (V-W08-03); N4 510(k) response read as approval (V-320a); N5 softwareVersion disagrees with
// declared FirmwareVersion (V-W08-05); N6 firmware version of two devices (V-W08-06); N7 asserted W08 edge without
// assertion (V-W08-04); N8 private device unit leaked into the shared graph (V-113, V-W08-09); N9 retired Sensor
// MEASURES_METRIC (V-W08-08); N10 name collision: two device models named 'WHOOP' (informational V-W08-10, no merge).

// N1
MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:w08-neg-platform-as-instrument'})
SET n += {id: 'w08-neg-platform-as-instrument', name: 'bad: runs on a platform', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:676b8bb84ce7267dd520deca4811c8f10a53e636352f06987f42fe425acedd80', softwareVersionStatus: 'NOT_REPORTED'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:w08-neg-platform-as-instrument'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);

// N2
MERGE (n:Device:Entity {uid: 'hu:device:w08-neg-device-with-status-props'})
SET n += {id: 'w08-neg-device-with-status-props', name: 'bad device', entityType: 'DEVICE', fdaCleared: true, clearanceNumber: 'K243236', accuracyPercent: 96.2, medicalGrade: true}, n.createdAt = coalesce(n.createdAt, datetime());

// N3
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:w08-neg-clearance-on-device'})
SET n += {id: 'w08-neg-clearance-on-device', statusKind: 'CLEARANCE', jurisdiction: 'US', stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:8721d664ef60096aa559e1aa6c72caf1facf5ce08b03aa6921ed9af5645d5466'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (s:RegulatoryStatus {uid: 'hu:reg-status:w08-neg-clearance-on-device'}), (d:Device {uid: 'hu:device:whoop-mg'})
MERGE (s)-[r:STATUS_OF]->(d)
SET r.relationshipUid = 'hu:rel:w08-neg-clearance-on-device', r.assertionUid = 'hu:assertion:w08-neg-missing', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// N4
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:w08-neg-510k-read-as-approval'})
SET n += {id: 'w08-neg-510k-read-as-approval', statusKind: 'APPROVAL', jurisdiction: 'US', stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:88450b082ec4df2fdccd3a626c6e489b31ef8cbf151bd543acf6e8890ffa1f49'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:w08-neg-510k-read-as-approval'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-k243236'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);

// N5
MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:w08-neg-firmware-mismatch'})
SET n += {id: 'w08-neg-firmware-mismatch', name: 'bad: label disagrees', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:4a8456f10e37689778cef532ab6a73742a152d4481190ab31de5d6f3f32f329c', softwareVersion: '41.16.2.0', softwareVersionStatus: 'REPORTED'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:w08-neg-firmware-mismatch'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:w08-neg-firmware-mismatch'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'})
MERGE (a)-[r:RUNS_FIRMWARE_VERSION]->(b);

// N6
MERGE (n:FirmwareVersion:VersionedState {uid: 'hu:firmware-version:w08-neg-two-devices'})
SET n += {id: 'w08-neg-two-devices', versionLabel: '1.0', stateType: 'FIRMWARE_VERSION', payloadHash: 'sha256:2d8e452e1634cae42e17cc9ec974afed94029e20e98fde4444706e3efac1bf77'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:w08-neg-two-devices'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:w08-neg-two-devices'}), (b:Device {uid: 'hu:device:whoop-mg'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

// N7
MATCH (o:Organization {uid: 'hu:org:whoop-inc'}), (p:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (o)-[r:USES_PLATFORM]->(p)
SET r.relationshipUid = 'hu:rel:w08-neg-unbacked-uses-platform', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// N8 (fixture device: :PrivateRecord marks a private-store record that must never be in the shared graph)
MERGE (u:PrivateRecord:Entity {uid: 'hu:private-device-unit:w08-neg-unit-0001'})
SET u.serialNumber = 'SYNTHETIC-SERIAL-0001', u.privacyClass = 'private-personal', u.entityType = 'DEVICE_UNIT', u.createdAt = datetime();

MATCH (d:Device {uid: 'hu:device:whoop-4-0'}), (u:PrivateRecord {uid: 'hu:private-device-unit:w08-neg-unit-0001'})
MERGE (d)-[:HAS_UNIT]->(u);

MERGE (n:Device:Entity {uid: 'hu:device:w08-neg-device-with-serial'})
SET n += {id: 'w08-neg-device-with-serial', name: 'bad: unit-level device', entityType: 'DEVICE', serialNumber: 'SYNTHETIC-SERIAL-0002'}, n.createdAt = coalesce(n.createdAt, datetime());

// N9
MERGE (n:Sensor:Entity {uid: 'hu:sensor:w08-neg-sensor-measures'})
SET n += {id: 'w08-neg-sensor-measures', name: 'bad sensor', sensorType: 'PPG', entityType: 'SENSOR'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Sensor {uid: 'hu:sensor:w08-neg-sensor-measures'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:MEASURES_METRIC]->(b);

// N10
MERGE (n:Device:Entity {uid: 'hu:device:w08-neg-whoop-name-a'})
SET n += {id: 'w08-neg-whoop-name-a', name: 'WHOOP', entityType: 'DEVICE', deviceFamily: 'WHOOP'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Device:Entity {uid: 'hu:device:w08-neg-whoop-name-b'})
SET n += {id: 'w08-neg-whoop-name-b', name: 'WHOOP', entityType: 'DEVICE', deviceFamily: 'WHOOP'}, n.createdAt = coalesce(n.createdAt, datetime());
