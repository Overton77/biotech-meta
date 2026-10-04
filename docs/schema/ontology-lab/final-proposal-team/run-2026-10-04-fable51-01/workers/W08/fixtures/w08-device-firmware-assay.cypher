// W08 fixture 2: device identity vs firmware version vs assay configuration (WHOOP 4.0)
// Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.
// Public sources: WHOOP 4.0 Firmware Release Notes (support.whoop.com, last published 2025-05-23, retrieved 2026-10-04)
// and the WHOOP Locker heart-rate page (dated 2026-07-21, retrieved 2026-10-04). Excerpts in excerpts/.
// Same Device (WHOOP 4.0), two core FirmwareVersions (41.15.3.0, 41.16.1.0) plus one Bluetooth firmware version,
// two heart-rate AssayVersions that differ ONLY in softwareVersion (= firmware label). Release-note statements are
// Assertions whose subject is the FirmwareVersion (failing case F-1 for softwareVersion-only). No release date is
// stated by the page, so every validFrom is null with basis UNKNOWN (missing fact kept missing). Includes an
// extraction correction (SUPERSEDES {EXTRACTION_FIX}) and an unversioned July 2026 accuracy claim (marketing).

MERGE (n:Organization:Entity {uid: 'hu:org:whoop-inc'})
SET n += {id: 'whoop-inc', name: 'WHOOP, Inc.', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Organization:Entity {uid: 'hu:org:illumina-inc'})
SET n += {id: 'illumina-inc', name: 'Illumina, Inc.', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatoryAgency:Organization:Entity {uid: 'hu:org:us-fda'})
SET n += {id: 'us-fda', name: 'U.S. Food and Drug Administration', agencyCode: 'FDA', jurisdiction: 'US', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w08-curation'})
SET n += {id: 'belllabs-w08-curation', name: 'BellLabs W08 curation (fixture)', agentKind: 'MANUAL_AGENT', entityType: 'AGENT'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Source:Entity {uid: 'hu:source:whoop-4-0-firmware-release-notes'})
SET n += {id: 'whoop-4-0-firmware-release-notes', canonicalUri: 'https://support.whoop.com/s/article/WHOOP-4-0-Firmware-Release-Notes', title: 'WHOOP 4.0 Firmware Release Notes', sourceKind: 'ORGANIZATION_WEBPAGE', entityType: 'SOURCE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'})
SET n += {id: 'whoop-4-0-firmware-release-notes-2026-10-04', canonicalUri: 'https://support.whoop.com/s/article/WHOOP-4-0-Firmware-Release-Notes', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-04T00:00:00Z'), publishedAt: datetime('2025-05-23T20:15:00Z'), contentHash: 'sha256:b3a580ffbcea0915a56c0da674fb2d9f2c8911811b931953c32f52fce3dcb1df', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'PARTIAL_EXCERPT', excerptFile: 'whoop-4-0-firmware-release-notes-2026-10-04.txt'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:whoop-4-0-firmware-release-notes'}), (b:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-4-0-fw-41-16-1-0-row'})
SET n += {id: 'whoop-4-0-fw-41-16-1-0-row', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'Firmware version 41.16.1.0 - Improved heart rate estimation algorithm', quoteHash: 'sha256:96dddf3babc1b05e89837c405528ea459ac84a7a7c3a599e70428202f2fea60a', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-16-1-0-row'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-4-0-fw-41-15-3-0-row'})
SET n += {id: 'whoop-4-0-fw-41-15-3-0-row', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'Firmware version 41.15.3.0 - Improved strap stability and issue reporting - Bug fixes', quoteHash: 'sha256:6a09ec1ff733711a49e7e9bdc1a6a1dba9f83fb658c522d9741ed3d14c2b9aa4', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-15-3-0-row'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-4-0-fw-41-11-7-0-row'})
SET n += {id: 'whoop-4-0-fw-41-11-7-0-row', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'Firmware version 41.11.7.0 - Improved HR estimation during sleep - Bug fixes and improvements', quoteHash: 'sha256:d02cccf43576326557bdc018743a4704786cb3816c9b6281bc10552a6ef81e87', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-11-7-0-row'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-4-0-fw-components'})
SET n += {id: 'whoop-4-0-fw-components', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'Release notes for the device\'s core firmware and Bluetooth firmware are listed below.', quoteHash: 'sha256:0ca076ab27cf1f6931800068d2569a116ca460652b09d76825e4e29a1074359c', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-components'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-4-0-fw-phased-rollout'})
SET n += {id: 'whoop-4-0-fw-phased-rollout', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'It may take 1-2 weeks before all of our members receive the update.', quoteHash: 'sha256:e3f586a6d7e9386381a74be59066033c5237aa9fafab39abe7c8ec59e8acd9d7', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-4-0-firmware-release-notes-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-phased-rollout'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Source:Entity {uid: 'hu:source:whoop-locker-heart-rate'})
SET n += {id: 'whoop-locker-heart-rate', canonicalUri: 'https://www.whoop.com/us/en/thelocker/a-look-behind-the-data-how-whoop-measures-heart-rate/', title: 'A Look Behind The Data: How WHOOP Measures Heart Rate', sourceKind: 'MARKETING_PAGE', entityType: 'SOURCE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:whoop-locker-heart-rate-2026-10-04'})
SET n += {id: 'whoop-locker-heart-rate-2026-10-04', canonicalUri: 'https://www.whoop.com/us/en/thelocker/a-look-behind-the-data-how-whoop-measures-heart-rate/', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-03T17:50:48Z'), publishedAt: datetime('2026-07-21T00:00:00Z'), contentHash: 'sha256:518ec912ffef67e7844f6350f99837cebf17be3db90bb545e7e19301fb0372b7', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'PARTIAL_EXCERPT', excerptFile: 'whoop-locker-heart-rate-2026-10-04.txt'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:whoop-locker-heart-rate'}), (b:SourceSnapshot {uid: 'hu:snapshot:whoop-locker-heart-rate-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-locker-hr-july-2026-claim'})
SET n += {id: 'whoop-locker-hr-july-2026-claim', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'WHOOP just delivered another across-the-board improvement to heart rate accuracy.', quoteHash: 'sha256:f8c7ad491e1a1ab84289c839ee66c15c51822320e0c5fc29818fc301db3885dc', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-locker-heart-rate-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-locker-hr-july-2026-claim'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:whoop-locker-updates-through-firmware'})
SET n += {id: 'whoop-locker-updates-through-firmware', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'Updates are delivered through firmware, meaning you benefit automatically without purchasing new hardware.', quoteHash: 'sha256:a105fdd20240c7bcfac913ec4e831b36b234b6c18585db6c8848f49fe71f5b0e', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:whoop-locker-heart-rate-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:whoop-locker-updates-through-firmware'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Device:Entity {uid: 'hu:device:whoop-4-0'})
SET n += {id: 'whoop-4-0', name: 'WHOOP 4.0', deviceClass: 'wrist-worn wearable', deviceFamily: 'WHOOP', entityType: 'DEVICE', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Metric:Entity {uid: 'hu:metric:heart-rate-bpm'})
SET n += {id: 'heart-rate-bpm', name: 'Heart rate', canonicalUnitCode: '/min', entityType: 'METRIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:MeasurementMethod:Entity {uid: 'hu:method:ppg-heart-rate-estimation'})
SET n += {id: 'ppg-heart-rate-estimation', name: 'Photoplethysmography heart-rate estimation', methodPrinciple: 'PPG', entityType: 'MEASUREMENT_METHOD'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Modality:Entity {uid: 'hu:modality:photoplethysmography'})
SET n += {id: 'photoplethysmography', name: 'Photoplethysmography (PPG)', modalityClass: 'optical', modalityFamily: 'sensing', entityType: 'MODALITY'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:FirmwareVersion:VersionedState {uid: 'hu:firmware-version:whoop-4-0-core-41-15-3-0'})
SET n += {id: 'whoop-4-0-core-41-15-3-0', name: 'WHOOP 4.0 core firmware 41.15.3.0', stateType: 'FIRMWARE_VERSION', payloadHash: 'sha256:75605b66ab1186ea0dd2ac97ab6cea09ce4db4dddab346d104e28c99e37f039e', versionLabel: '41.15.3.0', versionBasis: 'VENDOR_VERSION_STRING', componentLabel: 'core firmware', maturity: 'CANDIDATE'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-15-3-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

MERGE (n:FirmwareVersion:VersionedState {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'})
SET n += {id: 'whoop-4-0-core-41-16-1-0', name: 'WHOOP 4.0 core firmware 41.16.1.0', stateType: 'FIRMWARE_VERSION', payloadHash: 'sha256:101322ad68eff2a652f08f6e990974def7af88b2e8973a4374bd52d3e4e14bc1', versionLabel: '41.16.1.0', versionBasis: 'VENDOR_VERSION_STRING', componentLabel: 'core firmware', maturity: 'CANDIDATE'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

MERGE (n:FirmwareVersion:VersionedState {uid: 'hu:firmware-version:whoop-4-0-core-41-11-7-0'})
SET n += {id: 'whoop-4-0-core-41-11-7-0', name: 'WHOOP 4.0 core firmware 41.11.7.0', stateType: 'FIRMWARE_VERSION', payloadHash: 'sha256:1f0aac78c1124b4f26da270eaa5416eda89f1f32008cfa4957bef3860195592e', versionLabel: '41.11.7.0', versionBasis: 'VENDOR_VERSION_STRING', componentLabel: 'core firmware', maturity: 'CANDIDATE'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-11-7-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

MERGE (n:FirmwareVersion:VersionedState {uid: 'hu:firmware-version:whoop-4-0-bluetooth-17-2-2-0'})
SET n += {id: 'whoop-4-0-bluetooth-17-2-2-0', name: 'WHOOP 4.0 Bluetooth firmware 17.2.2.0', stateType: 'FIRMWARE_VERSION', payloadHash: 'sha256:357155fd28acdf64cd4a59337fb2d623b53afc7c624d4e63fa2a884f6853d849', versionLabel: '17.2.2.0', versionBasis: 'VENDOR_VERSION_STRING', componentLabel: 'Bluetooth firmware', maturity: 'CANDIDATE'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-bluetooth-17-2-2-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:FIRMWARE_VERSION_OF]->(b);

// Release-note assertions: subject is the firmware release, asserter is WHOOP (manufacturer claim).
MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-16-1-0-release-note'})
SET n += {id: 'whoop-4-0-fw-41-16-1-0-release-note', predicate: 'RELEASE_NOTE_STATES', valueString: 'Improved heart rate estimation algorithm', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'CLAIM', polarity: 'POSITIVE', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:1eabc5aef6127082db671cd3310514601bec42f73f955525e82fb58c255b0013'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-16-1-0-release-note'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-16-1-0-release-note'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-16-1-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-16-1-0-release-note'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-15-3-0-release-note'})
SET n += {id: 'whoop-4-0-fw-41-15-3-0-release-note', predicate: 'RELEASE_NOTE_STATES', valueString: 'Improved strap stability and issue reporting; Bug fixes', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'CLAIM', polarity: 'POSITIVE', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:f3edf2ae41e539096d9216c70f99b61da56d5c4e1181b7d66c1d5026f4178f3b'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-15-3-0-release-note'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-15-3-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-15-3-0-release-note'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-15-3-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-41-15-3-0-release-note'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

// Temporal correction: an extraction mistakenly attached the 'HR estimation during sleep' note to 41.16.1.0;
// the corrected assertion attaches it to 41.11.7.0. Valid time unchanged; old assertion closed by recordedTo.
MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'})
SET n += {id: 'whoop-4-0-fw-sleep-hr-note-misattributed', predicate: 'RELEASE_NOTE_STATES', valueString: 'Improved HR estimation during sleep', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'CLAIM', status: 'SUPERSEDED', recordedAt: datetime('2026-10-04T02:00:00Z'), recordedTo: datetime('2026-10-04T03:00:00Z'), contentHash: 'sha256:e1bf2e7842f437f122b5090c4bbd298d2e6c61a7dd4b26cbc9c9e3c13b138e10'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-11-7-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'})
SET n += {id: 'whoop-4-0-fw-sleep-hr-note', predicate: 'RELEASE_NOTE_STATES', valueString: 'Improved HR estimation during sleep', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'CLAIM', recordedAt: datetime('2026-10-04T03:00:00Z'), status: 'EXTRACTED', contentHash: 'sha256:d1bfba4bf9eff4cc54488d270ffd08daf15ffce7642c815d1abea972a4c17bc3'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-11-7-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-11-7-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (new:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note'}), (old:Assertion {uid: 'hu:assertion:whoop-4-0-fw-sleep-hr-note-misattributed'})
MERGE (new)-[s:SUPERSEDES]->(old)
SET s.supersessionKind = 'EXTRACTION_FIX', s.recordedAt = datetime('2026-10-04T03:00:00Z');

// Two heart-rate AssayVersions: identical operator, method, device and metric; only softwareVersion differs.
MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'})
SET n += {id: 'whoop-4-0-heart-rate-fw-41-15-3-0', name: 'WHOOP 4.0 heart rate, firmware 41.15.3.0', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:8c561e96a5537c3ca0c2018f53da8afc3a6cab6999640dde6eab4de2296998a0', softwareVersion: '41.15.3.0', softwareVersionStatus: 'REPORTED', reportedUnitCode: '/min'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSAY_OPERATED_BY]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (b:MeasurementMethod {uid: 'hu:method:ppg-heart-rate-estimation'})
MERGE (a)-[r:USES_METHOD]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-15-3-0'})
MERGE (a)-[r:RUNS_FIRMWARE_VERSION]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:ASSAY_FOR_METRIC]->(b);

// Which assay version the device's HR feature ran with: BellLabs curation from the release note; dates not stated.
MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0'})
SET n += {id: 'whoop-4-0-hr-performed-with-fw-41-15-3-0', predicate: 'PERFORMED_WITH_ASSAY_VERSION', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:7711615ce1d0686c6bbec3229fccb73e2205cd0db8666be12506c84eb57819d4'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0'}), (b:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-15-3-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0'}), (b:Agent {uid: 'hu:agent:belllabs-w08-curation'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-4-0'}), (b:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'})
MERGE (a)-[r:PERFORMED_WITH_ASSAY_VERSION]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-4-0-hr-performed-with-fw-41-15-3-0', assertionUid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-15-3-0', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'})
SET n += {id: 'whoop-4-0-heart-rate-fw-41-16-1-0', name: 'WHOOP 4.0 heart rate, firmware 41.16.1.0', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:98122cb4ebc8d7c3651efb4afa183b90e07ddf2c14325e6c77bc7e3a4382b1e0', softwareVersion: '41.16.1.0', softwareVersionStatus: 'REPORTED', reportedUnitCode: '/min'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSAY_OPERATED_BY]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'}), (b:MeasurementMethod {uid: 'hu:method:ppg-heart-rate-estimation'})
MERGE (a)-[r:USES_METHOD]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'}), (b:FirmwareVersion {uid: 'hu:firmware-version:whoop-4-0-core-41-16-1-0'})
MERGE (a)-[r:RUNS_FIRMWARE_VERSION]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:ASSAY_FOR_METRIC]->(b);

// Which assay version the device's HR feature ran with: BellLabs curation from the release note; dates not stated.
MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0'})
SET n += {id: 'whoop-4-0-hr-performed-with-fw-41-16-1-0', predicate: 'PERFORMED_WITH_ASSAY_VERSION', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:ef32352634e08afb48520d72fa40d3563c97d7e2d447e1b966fbe5a9f9f53f3d'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0'}), (b:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0'}), (b:SourceLocator {uid: 'hu:locator:whoop-4-0-fw-41-16-1-0-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0'}), (b:Agent {uid: 'hu:agent:belllabs-w08-curation'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-4-0'}), (b:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'})
MERGE (a)-[r:PERFORMED_WITH_ASSAY_VERSION]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-4-0-hr-performed-with-fw-41-16-1-0', assertionUid: 'hu:assertion:whoop-4-0-hr-performed-with-fw-41-16-1-0', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

// Vendor states the device reports heart rate (asserted MEASURES_METRIC; never implies MEASURED resultKind).
MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-measures-heart-rate'})
SET n += {id: 'whoop-4-0-measures-heart-rate', predicate: 'MEASURES_METRIC', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:f6489cddde80bfdeb8999e84c92d8578634c9ad961e93df2f242c2299b0da05e'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-measures-heart-rate'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-measures-heart-rate'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-measures-heart-rate'}), (b:SourceLocator {uid: 'hu:locator:whoop-locker-updates-through-firmware'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-measures-heart-rate'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-4-0'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:MEASURES_METRIC]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-4-0-measures-heart-rate', assertionUid: 'hu:assertion:whoop-4-0-measures-heart-rate', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

MERGE (n:Assertion {uid: 'hu:assertion:whoop-4-0-uses-ppg'})
SET n += {id: 'whoop-4-0-uses-ppg', predicate: 'USES_MODALITY', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', valueString: 'page names \'WHOOP\' generically; device-model resolution to WHOOP 4.0 is a curation choice (ResolutionHypothesis pending)', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:1c522ce9a49b546ca1679182496b1ff24e9f134deccdabd1d89200b3610078cb'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-uses-ppg'}), (b:Device {uid: 'hu:device:whoop-4-0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-uses-ppg'}), (b:Modality {uid: 'hu:modality:photoplethysmography'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-uses-ppg'}), (b:SourceLocator {uid: 'hu:locator:whoop-locker-updates-through-firmware'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-4-0-uses-ppg'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-4-0'}), (b:Modality {uid: 'hu:modality:photoplethysmography'})
MERGE (a)-[r:USES_MODALITY]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-4-0-uses-ppg', assertionUid: 'hu:assertion:whoop-4-0-uses-ppg', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: 'optical heart-rate sensing', isPrimary: true};

// July 2026 accuracy claim: no firmware version, no device model, no number. Kept as a marketing assertion whose
// subject is an unresolved assay version; nothing is written onto Device or FirmwareVersion.
MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:whoop-heart-rate-2026-07-update-unresolved'})
SET n += {id: 'whoop-heart-rate-2026-07-update-unresolved', name: 'WHOOP heart rate after the July 2026 update (device and firmware unresolved)', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:2a605f2e007bbb1d5144d5e750c794728c4e78c6525659ef9902961888f8080b', softwareVersionStatus: 'NOT_REPORTED'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-heart-rate-2026-07-update-unresolved'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSAY_OPERATED_BY]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:whoop-heart-rate-2026-07-update-unresolved'}), (b:Metric {uid: 'hu:metric:heart-rate-bpm'})
MERGE (a)-[r:ASSAY_FOR_METRIC]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:whoop-locker-july-2026-hr-accuracy-claim'})
SET n += {id: 'whoop-locker-july-2026-hr-accuracy-claim', predicate: 'CLAIMS_ACCURACY_IMPROVEMENT', valueString: 'across-the-board improvement to heart rate accuracy (no figure, no firmware version stated)', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'CLAIM', polarity: 'POSITIVE', validFrom: datetime('2026-07-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:344d0d8c86efee5217d2ff16030319ebe185593ba6201769b8879fcbfe4511ba'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-locker-july-2026-hr-accuracy-claim'}), (b:AssayVersion {uid: 'hu:assay-version:whoop-heart-rate-2026-07-update-unresolved'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-locker-july-2026-hr-accuracy-claim'}), (b:SourceLocator {uid: 'hu:locator:whoop-locker-hr-july-2026-claim'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-locker-july-2026-hr-accuracy-claim'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
