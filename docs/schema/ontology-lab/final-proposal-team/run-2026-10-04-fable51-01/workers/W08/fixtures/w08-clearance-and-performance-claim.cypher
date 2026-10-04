// W08 fixture 3: 510(k) clearance of a software product vs the device model; performance claim as manufacturer assertion
// Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.
// Public sources: FDA 510(k) database record K243236 and the K243236 PDF (FDA letter + applicant-prepared 510(k)
// Summary), FDA closeout letter 709755 (2026-06-17). Excerpts in excerpts/. Regulatory node shapes follow W13
// (RegulatorySubmission/Response/Status, STATUS_OF asserted). W08 contribution: the clearance attaches to the Product
// 'WHOOP ECG (electrocardiogram) Feature', which RUNS_ON_DEVICE the Device 'WHOOP MG'; the Device carries no status
// and no performance property. Late arrival: valid from 2025-04-04 (decision date), recorded 2026-10-04.

MERGE (n:Organization:Entity {uid: 'hu:org:whoop-inc'})
SET n += {id: 'whoop-inc', name: 'WHOOP, Inc.', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Organization:Entity {uid: 'hu:org:illumina-inc'})
SET n += {id: 'illumina-inc', name: 'Illumina, Inc.', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatoryAgency:Organization:Entity {uid: 'hu:org:us-fda'})
SET n += {id: 'us-fda', name: 'U.S. Food and Drug Administration', agencyCode: 'FDA', jurisdiction: 'US', entityType: 'ORGANIZATION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w08-curation'})
SET n += {id: 'belllabs-w08-curation', name: 'BellLabs W08 curation (fixture)', agentKind: 'MANUAL_AGENT', entityType: 'AGENT'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Source:Entity {uid: 'hu:source:fda-510k-k243236-record'})
SET n += {id: 'fda-510k-k243236-record', canonicalUri: 'https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpmn/pmn.cfm?ID=K243236', title: '510(k) Premarket Notification K243236', sourceKind: 'REGULATORY_RECORD', entityType: 'SOURCE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-510k-k243236-record-2026-10-04'})
SET n += {id: 'fda-510k-k243236-record-2026-10-04', canonicalUri: 'https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpmn/pmn.cfm?ID=K243236', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-09-28T00:00:00Z'), contentHash: 'sha256:6459819a708003f003d5b4537dc04905ea17428831579ffe5562c163a4f0277e', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'COMPLETE', excerptFile: 'fda-510k-K243236-record-2026-10-04.txt'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:fda-510k-k243236-record'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-510k-k243236-record-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-k243236-record-whole'})
SET n += {id: 'fda-k243236-record-whole', selectorKind: 'WHOLE_SNAPSHOT', artifactType: 'SOURCE_LOCATOR'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-510k-k243236-record-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-record-whole'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Source:Entity {uid: 'hu:source:fda-k243236-pdf'})
SET n += {id: 'fda-k243236-pdf', canonicalUri: 'https://www.accessdata.fda.gov/cdrh_docs/pdf24/K243236.pdf', title: 'K243236 SE letter, Indications for Use, 510(k) Summary', sourceKind: 'REGULATORY_RECORD', entityType: 'SOURCE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'})
SET n += {id: 'fda-k243236-pdf-2026-10-04', canonicalUri: 'https://www.accessdata.fda.gov/cdrh_docs/pdf24/K243236.pdf', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-04T00:00:00Z'), publishedAt: datetime('2025-04-04T00:00:00Z'), contentHash: 'sha256:fae648ead307b9d2b2474e5103993fa73c1915bfd7c4bd7956df9fdb6afd9836', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'PARTIAL_EXCERPT', excerptFile: 'fda-K243236-pdf-2026-10-04.txt'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:fda-k243236-pdf'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-k243236-summary-performance'})
SET n += {id: 'fda-k243236-summary-performance', selectorKind: 'PDF_PAGE', artifactType: 'SOURCE_LOCATOR', exact: 'The ECG feature demonstrated 96.2% sensitivity in classifying AFib (HR 50-150 bpm) and 99.4% specificity in classifying sinus rhythm (HR 50-150 bpm) in classifiable recordings.', quoteHash: 'sha256:f1055608e4e9e6fc8a20d3c5810d9b47255dc5e6fb620f07a0a2ade9c60c9fbd', normalizationVersion: 'NFC-WS1', page: 9}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-performance'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-k243236-summary-inconclusive'})
SET n += {id: 'fda-k243236-summary-inconclusive', selectorKind: 'PDF_PAGE', artifactType: 'SOURCE_LOCATOR', exact: 'During this study, the WHOOP ECG Feature determined 11% of recordings were inconclusive.', quoteHash: 'sha256:916f7b8326aed6a080c9a7de73aeef0b566bceb0a8dae92acc78ff4444d43e5c', normalizationVersion: 'NFC-WS1', page: 9}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-inconclusive'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-k243236-summary-compatibility'})
SET n += {id: 'fda-k243236-summary-compatibility', selectorKind: 'PDF_PAGE', artifactType: 'SOURCE_LOCATOR', exact: 'WHOOP Strap version - WHOOP MG', quoteHash: 'sha256:38b33e6dfefc64eedabd2fb6ac580fc95d812017dccdbd27b1311a49667a796d', normalizationVersion: 'NFC-WS1', page: 8}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-compatibility'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-k243236-summary-non-device-system'})
SET n += {id: 'fda-k243236-summary-non-device-system', selectorKind: 'PDF_PAGE', artifactType: 'SOURCE_LOCATOR', exact: 'The WHOOP ECG Feature is a software-only medical mobile application integrated into the consumer (non-device) WHOOP System.', quoteHash: 'sha256:87137aeee15b46c5af0d05f2ba20155803cb0d7c85ef95a31d708ffc9d1b9d1d', normalizationVersion: 'NFC-WS1', page: 5}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-k243236-pdf-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-non-device-system'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Source:Entity {uid: 'hu:source:fda-closeout-whoop-709755'})
SET n += {id: 'fda-closeout-whoop-709755', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/whoop-inc-709755-06172026', title: 'WHOOP, Inc. - 709755 - 06/17/2026 (closeout letter)', sourceKind: 'REGULATORY_RECORD', entityType: 'SOURCE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-closeout-whoop-709755-2026-10-04'})
SET n += {id: 'fda-closeout-whoop-709755-2026-10-04', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/whoop-inc-709755-06172026', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-02T01:22:10Z'), publishedAt: datetime('2026-06-23T07:26:00Z'), contentHash: 'sha256:3a4719b2fd975d8ba7c2dc715805f5a958cdb4b69fc368324ee434257e5be95a', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'PARTIAL_EXCERPT', excerptFile: 'fda-whoop-closeout-709755-2026-10-04.txt'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:fda-closeout-whoop-709755'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-closeout-whoop-709755-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fda-closeout-709755-bpi-as-modified'})
SET n += {id: 'fda-closeout-709755-bpi-as-modified', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'FDA does not intend to enforce the device statutory and regulatory requirements for your BPI product as modified.', quoteHash: 'sha256:c8c98fdd1fa6cf18a5544121a2348fda4442266bebc850c35e2a74a043cacb8a', normalizationVersion: 'NFC-WS1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-closeout-whoop-709755-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fda-closeout-709755-bpi-as-modified'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Device:Entity {uid: 'hu:device:whoop-mg'})
SET n += {id: 'whoop-mg', name: 'WHOOP MG', deviceClass: 'wrist-worn wearable', deviceFamily: 'WHOOP', entityType: 'DEVICE', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Sensor:Entity {uid: 'hu:sensor:whoop-mg-ecg-electrodes'})
SET n += {id: 'whoop-mg-ecg-electrodes', name: 'WHOOP MG ECG electrodes (wrist and clasp)', sensorType: 'ECG electrode', entityType: 'SENSOR'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Modality:Entity {uid: 'hu:modality:single-lead-ecg'})
SET n += {id: 'single-lead-ecg', name: 'Single-lead ECG (Lead I-like)', modalityClass: 'electrical', modalityFamily: 'sensing', entityType: 'MODALITY'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Product:Entity {uid: 'hu:product:whoop-ecg-feature'})
SET n += {id: 'whoop-ecg-feature', name: 'WHOOP ECG (electrocardiogram) Feature', entityType: 'PRODUCT'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Product:Entity {uid: 'hu:product:whoop-blood-pressure-insights'})
SET n += {id: 'whoop-blood-pressure-insights', name: 'WHOOP Blood Pressure Insights (BPI)', entityType: 'PRODUCT'}, n.createdAt = coalesce(n.createdAt, datetime());

// Device-side assertions (applicant-prepared 510(k) Summary; asserter WHOOP, Inc., not FDA).
MERGE (n:Assertion {uid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg'})
SET n += {id: 'whoop-ecg-feature-runs-on-whoop-mg', predicate: 'RUNS_ON_DEVICE', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:c3de3ad8a338935f2a402b8bdce0558a30d3d63910bd4e0b8313e87072324ee3'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg'}), (b:Device {uid: 'hu:device:whoop-mg'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-compatibility'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Product {uid: 'hu:product:whoop-ecg-feature'}), (b:Device {uid: 'hu:device:whoop-mg'})
MERGE (a)-[r:RUNS_ON_DEVICE]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-ecg-feature-runs-on-whoop-mg', assertionUid: 'hu:assertion:whoop-ecg-feature-runs-on-whoop-mg', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

MERGE (n:Assertion {uid: 'hu:assertion:whoop-mg-has-ecg-electrodes'})
SET n += {id: 'whoop-mg-has-ecg-electrodes', predicate: 'HAS_SENSOR', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:3083fe02582afc656cc238aec83880135e95955578a0d17dbcb5674556cb7786'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-has-ecg-electrodes'}), (b:Device {uid: 'hu:device:whoop-mg'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-has-ecg-electrodes'}), (b:Sensor {uid: 'hu:sensor:whoop-mg-ecg-electrodes'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-has-ecg-electrodes'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-non-device-system'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-has-ecg-electrodes'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-mg'}), (b:Sensor {uid: 'hu:sensor:whoop-mg-ecg-electrodes'})
MERGE (a)-[r:HAS_SENSOR]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-mg-has-ecg-electrodes', assertionUid: 'hu:assertion:whoop-mg-has-ecg-electrodes', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

MERGE (n:Assertion {uid: 'hu:assertion:whoop-mg-uses-single-lead-ecg'})
SET n += {id: 'whoop-mg-uses-single-lead-ecg', predicate: 'USES_MODALITY', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:3dbd0be263eb43ea8e093f48571bc0d1d8deece8ef04c30f311cfb42d176d043'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-uses-single-lead-ecg'}), (b:Device {uid: 'hu:device:whoop-mg'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-uses-single-lead-ecg'}), (b:Modality {uid: 'hu:modality:single-lead-ecg'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-uses-single-lead-ecg'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-non-device-system'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:whoop-mg-uses-single-lead-ecg'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Device {uid: 'hu:device:whoop-mg'}), (b:Modality {uid: 'hu:modality:single-lead-ecg'})
MERGE (a)-[r:USES_MODALITY]->(b)
SET r += {relationshipUid: 'hu:rel:whoop-mg-uses-single-lead-ecg', assertionUid: 'hu:assertion:whoop-mg-uses-single-lead-ecg', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: '30-second on-demand ECG spot check'};

// Regulatory chain (W13 shapes): submission -> response SUBSTANTIALLY_EQUIVALENT -> status CLEARANCE STATUS_OF the Product.
MERGE (n:RegulatoryPathway:Entity {uid: 'hu:reg-pathway:us-fda-510k'})
SET n += {id: 'us-fda-510k', name: 'FDA premarket notification 510(k)', pathwayKind: 'PREMARKET_NOTIFICATION_510K', jurisdiction: 'US', entityType: 'REGULATORY_PATHWAY'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatorySubmission:InformationArtifact {uid: 'hu:reg-submission:us-fda-k243236'})
SET n += {id: 'us-fda-k243236', submissionKind: 'PREMARKET_NOTIFICATION_510K', identifier: 'K243236', jurisdiction: 'US', submittedAt: datetime('2024-10-10T00:00:00Z'), artifactType: 'REGULATORY_SUBMISSION'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatoryResponse:InformationArtifact {uid: 'hu:reg-response:us-fda-k243236'})
SET n += {id: 'us-fda-k243236', responseKind: 'SUBSTANTIALLY_EQUIVALENT', jurisdiction: 'US', issuedAt: datetime('2025-04-04T00:00:00Z'), conditionsOfUseText: 'OTC; adults 22 years and older; AFib, normal sinus rhythm, low and high heart rate on a classifiable waveform; not recommended for users with other known arrhythmias', agencyDisclaimerText: 'FDA\'s issuance of a substantial equivalence determination does not mean that FDA has made a determination that your device complies with other requirements of the Act', artifactType: 'REGULATORY_RESPONSE'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'})
SET n += {id: 'us-whoop-ecg-feature-k243236-clearance', statusKind: 'CLEARANCE', jurisdiction: 'US', productCode: 'QDA', pcccAuthorized: false, legalBasisCitation: '21 CFR 870.2345', scopeText: 'WHOOP ECG (electrocardiogram) Feature (1.0); compatible WHOOP Strap version WHOOP MG; OTC', effectiveFrom: datetime('2025-04-04T00:00:00Z'), stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:eba2ccceb1505d5aab11f4aa547dd9806f44ffd3c837c132741b3894e7257d98'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-k243236'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-510k'})
MERGE (a)-[r:UNDER_PATHWAY]->(b);

MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-k243236'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-k243236'})
MERGE (a)-[r:SUBMISSION_HAS_RESPONSE]->(b);

MATCH (a:RegulatoryResponse {uid: 'hu:reg-response:us-fda-k243236'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-k243236'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-510k'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature'})
SET n += {id: 'k243236-clearance-status-of-whoop-ecg-feature', predicate: 'STATUS_OF', assertionBasis: 'UNSTATED', speechAct: 'STATES', predicateClass: 'REGULATORY', validFrom: datetime('2025-04-04T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:933979fa1971f00b410edcc3eec87292ba745cbf0f20bee7fcd29ea6b2e6f577'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature'}), (b:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-record-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-ecg-feature-k243236-clearance'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:STATUS_OF]->(b)
SET r += {relationshipUid: 'hu:rel:k243236-clearance-status-of-whoop-ecg-feature', assertionUid: 'hu:assertion:k243236-clearance-status-of-whoop-ecg-feature', validFrom: datetime('2025-04-04T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

// Performance claims: applicant statements in the 510(k) Summary about the software product (not Device properties).
MERGE (n:Assertion {uid: 'hu:assertion:k243236-summary-afib-sensitivity'})
SET n += {id: 'k243236-summary-afib-sensitivity', predicate: 'REPORTS_SENSITIVITY', valueNumber: 96.2, unitCode: '%', valueString: 'AFib classification, HR 50-150 bpm, classifiable recordings only; reference: cardiologist-read 12-lead ECG; approx. 540 subjects (NCT06622265)', assertionBasis: 'STUDY_RESULT', basisKind: 'DIRECT_MEASUREMENT', speechAct: 'STATES', predicateClass: 'QUANTITY', polarity: 'POSITIVE', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:952e7510087a4d8e219b62549834d17091f820bade7e305dde6cde259500a45f'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-afib-sensitivity'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-afib-sensitivity'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-performance'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-afib-sensitivity'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:k243236-summary-sinus-specificity'})
SET n += {id: 'k243236-summary-sinus-specificity', predicate: 'REPORTS_SPECIFICITY', valueNumber: 99.4, unitCode: '%', valueString: 'sinus rhythm classification, HR 50-150 bpm, classifiable recordings only', assertionBasis: 'STUDY_RESULT', basisKind: 'DIRECT_MEASUREMENT', speechAct: 'STATES', predicateClass: 'QUANTITY', polarity: 'POSITIVE', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e7433da6228f3e2a61cc3990bba6b461b7907620d0e2a394b4f49cdb37e47f86'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-sinus-specificity'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-sinus-specificity'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-performance'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-sinus-specificity'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:k243236-summary-inconclusive-rate'})
SET n += {id: 'k243236-summary-inconclusive-rate', predicate: 'REPORTS_INCONCLUSIVE_RATE', valueNumber: 11, unitCode: '%', valueString: 'share of recordings classified inconclusive in the clinical study; excluded from the sensitivity/specificity denominators', assertionBasis: 'STUDY_RESULT', basisKind: 'DIRECT_MEASUREMENT', speechAct: 'STATES', predicateClass: 'QUANTITY', polarity: 'NEGATIVE', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:d1aa966aab22271396f386e5429b4571be74513b999b8b9250d9537e7e2b79d1'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-inconclusive-rate'}), (b:Product {uid: 'hu:product:whoop-ecg-feature'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-inconclusive-rate'}), (b:SourceLocator {uid: 'hu:locator:fda-k243236-summary-inconclusive'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:k243236-summary-inconclusive-rate'}), (b:Organization {uid: 'hu:org:whoop-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

// Enforcement discretion for a modified wellness feature: not an authorization, not a clearance (W13 statusKind).
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion'})
SET n += {id: 'us-whoop-bpi-as-modified-enforcement-discretion', statusKind: 'ENFORCEMENT_DISCRETION', jurisdiction: 'US', scopeText: 'BPI product as modified; letter is specific to that modification and not to any other product, feature or other modifications', effectiveFrom: datetime('2026-06-17T00:00:00Z'), stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:9896794137fa2ecd8188516eb5fd4d44473589069c06259171d7c467cd568166'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

MERGE (n:Assertion {uid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion'})
SET n += {id: 'fda-closeout-709755-bpi-enforcement-discretion', predicate: 'STATUS_OF', assertionBasis: 'UNSTATED', speechAct: 'STATES', predicateClass: 'REGULATORY', validFrom: datetime('2026-06-17T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:303b000baa0085ba603e26485dbe453ed9580f03d4950dad882ff02b0c0af5b8'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion'}), (b:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion'}), (b:Product {uid: 'hu:product:whoop-blood-pressure-insights'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion'}), (b:SourceLocator {uid: 'hu:locator:fda-closeout-709755-bpi-as-modified'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:RegulatoryStatus {uid: 'hu:reg-status:us-whoop-bpi-as-modified-enforcement-discretion'}), (b:Product {uid: 'hu:product:whoop-blood-pressure-insights'})
MERGE (a)-[r:STATUS_OF]->(b)
SET r += {relationshipUid: 'hu:rel:fda-closeout-709755-bpi-enforcement-discretion', assertionUid: 'hu:assertion:fda-closeout-709755-bpi-enforcement-discretion', validFrom: datetime('2026-06-17T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};
