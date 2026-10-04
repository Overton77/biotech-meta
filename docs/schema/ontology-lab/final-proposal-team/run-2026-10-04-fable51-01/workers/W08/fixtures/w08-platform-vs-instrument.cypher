// W08 fixture 1: technology platform versus instrument model (Illumina Infinium / iScan / NextSeq 550)
// Run run-2026-10-04-fable51-01, worker W08. Neo4j 5.x Cypher. Every statement binds its own nodes by uid.
// Public source: Illumina Infinium MethylationEPIC v2.0 product page (retrieved 2026-10-04; excerpt in excerpts/).
// Synthetic: 'synthetic-lab-c' and its two assay versions (no lab publishes this pair); the kit number and the
// instrument list are from the Illumina page. Minimal pair: one TechnologyPlatform, two ToolOrInstrument models;
// same kit 20087706 + same method principle on two instruments = two AssayVersions, never one series without a
// ComparabilityAssessment (forbidden implication [SAME_TECHNOLOGY_PLATFORM, COMPARABLE_ASSAY_VERSION]).

MERGE (n:Organization:Entity {uid: 'hu:org:whoop-inc'})
SET n += {id: 'whoop-inc', name: 'WHOOP, Inc.', entityType: 'ORGANIZATION', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Organization:Entity {uid: 'hu:org:illumina-inc'})
SET n += {id: 'illumina-inc', name: 'Illumina, Inc.', entityType: 'ORGANIZATION', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:RegulatoryAgency:Organization:Entity {uid: 'hu:org:us-fda'})
SET n += {id: 'us-fda', name: 'U.S. Food and Drug Administration', agencyCode: 'FDA', jurisdiction: 'US', entityType: 'ORGANIZATION', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w08-curation'})
SET n += {id: 'belllabs-w08-curation', name: 'BellLabs W08 curation (fixture)', agentKind: 'MANUAL_AGENT', entityType: 'AGENT', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Organization:Entity {uid: 'hu:org:synthetic-lab-c'})
SET n += {id: 'synthetic-lab-c', name: 'Synthetic Lab C (methylation service)', entityType: 'ORGANIZATION', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Source:Entity {uid: 'hu:source:illumina-epic-v2-product-page'})
SET n += {id: 'illumina-epic-v2-product-page', canonicalUri: 'https://www.illumina.com/products/by-type/microarray-kits/infinium-methylation-epic.html', title: 'Infinium MethylationEPIC v2.0 Kit | Methylation profiling array', sourceKind: 'MANUFACTURER_LABEL_PAGE', entityType: 'SOURCE', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:illumina-epic-v2-product-page-2026-10-04'})
SET n += {id: 'illumina-epic-v2-product-page-2026-10-04', canonicalUri: 'https://www.illumina.com/products/by-type/microarray-kits/infinium-methylation-epic.html', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-04T00:00:00Z'), contentHash: 'sha256:4eb3ad2196607618fa69f2a20ec590a56ba0b86f29ad457af5f9741719a96a34', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'PARTIAL_EXCERPT', excerptFile: 'illumina-epic-v2-product-page-2026-10-04.txt', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:illumina-epic-v2-product-page'}), (b:SourceSnapshot {uid: 'hu:snapshot:illumina-epic-v2-product-page-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:illumina-epic-v2-processed-on-iscan-or-nextseq550'})
SET n += {id: 'illumina-epic-v2-processed-on-iscan-or-nextseq550', selectorKind: 'TEXT_QUOTE', artifactType: 'SOURCE_LOCATOR', exact: 'The kit is processed on the iScan or NextSeq 550 Systems', quoteHash: 'sha256:829863e6dfc6822e23c18307fe7b427d12e0ac5cc46546d9e8c78de53b495878', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:illumina-epic-v2-product-page-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-processed-on-iscan-or-nextseq550'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:illumina-epic-v2-spec-table'})
SET n += {id: 'illumina-epic-v2-spec-table', selectorKind: 'SECTION', artifactType: 'SOURCE_LOCATOR', section: 'Specifications: Assay type Infinium HD Methylation; Instruments NextSeq 550 System, NextSeq 550Dx in Research Mode, iScan System; Method Methylation array; Technology Microarray', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:illumina-epic-v2-product-page-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-spec-table'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:Source:Entity {uid: 'hu:source:synthetic-lab-c-methods-page'})
SET n += {id: 'synthetic-lab-c-methods-page', canonicalUri: 'urn:synthetic:lab-c-methods', title: 'Synthetic Lab C methylation methods page', sourceKind: 'ORGANIZATION_WEBPAGE', entityType: 'SOURCE', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-lab-c-methods-page-2026-10-04'})
SET n += {id: 'synthetic-lab-c-methods-page-2026-10-04', canonicalUri: 'urn:synthetic:lab-c-methods', artifactType: 'SOURCE_SNAPSHOT', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-04T00:00:00Z'), contentHash: 'sha256:915dc8bec708f44fb698964c287e32f59b6736569b0cae65fe80abf631cc14a9', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Source {uid: 'hu:source:synthetic-lab-c-methods-page'}), (b:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-c-methods-page-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-lab-c-methods-two-instruments'})
SET n += {id: 'synthetic-lab-c-methods-two-instruments', selectorKind: 'SECTION', artifactType: 'SOURCE_LOCATOR', section: 'Arrays are scanned on an iScan System; overflow batches run on a NextSeq 550 System', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-c-methods-page-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:synthetic-lab-c-methods-two-instruments'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:TechnologyPlatform:Entity {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
SET n += {id: 'illumina-infinium-beadchip', name: 'Illumina Infinium BeadChip array', platformClass: 'MICROARRAY', entityType: 'TECHNOLOGY_PLATFORM', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:ToolOrInstrument:Entity {uid: 'hu:instrument:illumina-iscan-system'})
SET n += {id: 'illumina-iscan-system', name: 'Illumina iScan System', toolClass: 'array scanner', entityType: 'TOOL_OR_INSTRUMENT', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:ToolOrInstrument:Entity {uid: 'hu:instrument:illumina-nextseq-550-system'})
SET n += {id: 'illumina-nextseq-550-system', name: 'Illumina NextSeq 550 System', toolClass: 'sequencer (array scanning capable)', entityType: 'TOOL_OR_INSTRUMENT', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:MeasurementMethod:Entity {uid: 'hu:method:methylation-array'})
SET n += {id: 'methylation-array', name: 'Methylation array (bisulfite conversion + array hybridization)', methodPrinciple: 'METHYLATION_ARRAY', entityType: 'MEASUREMENT_METHOD', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MERGE (n:Product:Entity {uid: 'hu:product:illumina-iscan-system'})
SET n += {id: 'illumina-iscan-system', name: 'iScan System (Illumina product)', entityType: 'PRODUCT', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

// Platform-level assertions (Illumina statements on its own product page).
MERGE (n:Assertion {uid: 'hu:assertion:illumina-develops-infinium'})
SET n += {id: 'illumina-develops-infinium', predicate: 'DEVELOPS_PLATFORM', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:fc8d2fe14d9618c01f24e700249db1b17bc5e743724b2a794c1df95b3bf359a9', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:illumina-develops-infinium'}), (b:Organization {uid: 'hu:org:illumina-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:illumina-develops-infinium'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:illumina-develops-infinium'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-spec-table'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:illumina-develops-infinium'}), (b:Organization {uid: 'hu:org:illumina-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Organization {uid: 'hu:org:illumina-inc'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:DEVELOPS_PLATFORM]->(b)
SET r += {relationshipUid: 'hu:rel:illumina-develops-infinium', assertionUid: 'hu:assertion:illumina-develops-infinium', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

MERGE (n:Assertion {uid: 'hu:assertion:iscan-implements-infinium'})
SET n += {id: 'iscan-implements-infinium', predicate: 'IMPLEMENTS_PLATFORM', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:51e8c00f8a36721842e0ce5513910f1f8b1674e72e643e870108c4f55d59b722', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:iscan-implements-infinium'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-implements-infinium'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-implements-infinium'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-processed-on-iscan-or-nextseq550'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-implements-infinium'}), (b:Organization {uid: 'hu:org:illumina-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:IMPLEMENTS_PLATFORM]->(b)
SET r += {relationshipUid: 'hu:rel:iscan-implements-infinium', assertionUid: 'hu:assertion:iscan-implements-infinium', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: 'BeadChip scanning', isPrimary: true};

MERGE (n:Assertion {uid: 'hu:assertion:nextseq550-implements-infinium'})
SET n += {id: 'nextseq550-implements-infinium', predicate: 'IMPLEMENTS_PLATFORM', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e54dd5275e3809126ced43798a4ee7dc06e1f081a66a6eb6f4adc1114c5fce8b', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:nextseq550-implements-infinium'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-nextseq-550-system'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:nextseq550-implements-infinium'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:nextseq550-implements-infinium'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-processed-on-iscan-or-nextseq550'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:nextseq550-implements-infinium'}), (b:Organization {uid: 'hu:org:illumina-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:ToolOrInstrument {uid: 'hu:instrument:illumina-nextseq-550-system'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:IMPLEMENTS_PLATFORM]->(b)
SET r += {relationshipUid: 'hu:rel:nextseq550-implements-infinium', assertionUid: 'hu:assertion:nextseq550-implements-infinium', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: 'BeadChip processing on a sequencer'};

MERGE (n:Assertion {uid: 'hu:assertion:iscan-product-embodies-iscan-model'})
SET n += {id: 'iscan-product-embodies-iscan-model', predicate: 'EMBODIES_MODEL', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:de5df66efbe7233d9f14dfc538e923a236ecd0686463fc87945ea5e88cba3382', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:iscan-product-embodies-iscan-model'}), (b:Product {uid: 'hu:product:illumina-iscan-system'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-product-embodies-iscan-model'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-product-embodies-iscan-model'}), (b:SourceLocator {uid: 'hu:locator:illumina-epic-v2-spec-table'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:iscan-product-embodies-iscan-model'}), (b:Organization {uid: 'hu:org:illumina-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Product {uid: 'hu:product:illumina-iscan-system'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:EMBODIES_MODEL]->(b)
SET r += {relationshipUid: 'hu:rel:iscan-product-embodies-iscan-model', assertionUid: 'hu:assertion:iscan-product-embodies-iscan-model', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z')};

// RUNS_ON_PLATFORM is structural (reference-concept link; accepted from W07): no assertion.
MATCH (a:MeasurementMethod {uid: 'hu:method:methylation-array'}), (b:TechnologyPlatform {uid: 'hu:technology-platform:illumina-infinium-beadchip'})
MERGE (a)-[r:RUNS_ON_PLATFORM]->(b)
SET r += {notes: 'Illumina page: Method \'Methylation array\' on Infinium BeadChips'};

// The lab uses both instruments (synthetic organization page).
MERGE (n:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-iscan'})
SET n += {id: 'synthetic-lab-c-uses-iscan', predicate: 'USES_EQUIPMENT', assertionBasis: 'UNSTATED', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:b6f56110d2d5e3f55cf742c4795783e2306f7f42f644ee9e790e3e931cc53bfc', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-iscan'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-iscan'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-iscan'}), (b:SourceLocator {uid: 'hu:locator:synthetic-lab-c-methods-two-instruments'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-iscan'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Organization {uid: 'hu:org:synthetic-lab-c'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:USES_EQUIPMENT]->(b)
SET r += {relationshipUid: 'hu:rel:synthetic-lab-c-uses-iscan', assertionUid: 'hu:assertion:synthetic-lab-c-uses-iscan', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: 'methylation array scanning', isPrimary: true};

MERGE (n:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-nextseq550'})
SET n += {id: 'synthetic-lab-c-uses-nextseq550', predicate: 'USES_EQUIPMENT', assertionBasis: 'UNSTATED', speechAct: 'STATES', predicateClass: 'OTHER', status: 'EXTRACTED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:da781c16949d7ec0213b5322efd949a5aa6dac5be2e0619cdcbf95abba4a01b9', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-nextseq550'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:HAS_SUBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-nextseq550'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-nextseq-550-system'})
MERGE (a)-[r:HAS_OBJECT]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-nextseq550'}), (b:SourceLocator {uid: 'hu:locator:synthetic-lab-c-methods-two-instruments'})
MERGE (a)-[r:SUPPORTED_BY]->(b);

MATCH (a:Assertion {uid: 'hu:assertion:synthetic-lab-c-uses-nextseq550'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:ASSERTED_BY]->(b);

MATCH (a:Organization {uid: 'hu:org:synthetic-lab-c'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-nextseq-550-system'})
MERGE (a)-[r:USES_EQUIPMENT]->(b)
SET r += {relationshipUid: 'hu:rel:synthetic-lab-c-uses-nextseq550', assertionUid: 'hu:assertion:synthetic-lab-c-uses-nextseq550', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T02:00:00Z'), usageContext: 'methylation array scanning', isPrimary: false};

// Two assay versions: same lab, same kit, same method, different instrument model (W07 AssayVersion shape).
MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-iscan'})
SET n += {id: 'synthetic-lab-c-epic-v2-iscan', name: 'Synthetic Lab C EPIC v2.0 on iscan', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:fd55132a0029994fb2eeb4e4dc0d6c9523919630a6672aed23903cc087c6ee0c', assayKitIdentifier: '20087706', softwareVersionStatus: 'NOT_REPORTED', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-iscan'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:ASSAY_OPERATED_BY]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-iscan'}), (b:MeasurementMethod {uid: 'hu:method:methylation-array'})
MERGE (a)-[r:USES_METHOD]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-iscan'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-iscan-system'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);

MERGE (n:AssayVersion:VersionedState {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-nextseq550'})
SET n += {id: 'synthetic-lab-c-epic-v2-nextseq550', name: 'Synthetic Lab C EPIC v2.0 on nextseq550', stateType: 'ASSAY_VERSION', payloadHash: 'sha256:b7644fdf4c5d0f038f319df9d71e2f8da6ce994138a1e386181d14e2d00a6f82', assayKitIdentifier: '20087706', softwareVersionStatus: 'NOT_REPORTED', privacyClass: 'PUBLIC'}, n.createdAt = coalesce(n.createdAt, datetime());

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-nextseq550'}), (b:Organization {uid: 'hu:org:synthetic-lab-c'})
MERGE (a)-[r:ASSAY_OPERATED_BY]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-nextseq550'}), (b:MeasurementMethod {uid: 'hu:method:methylation-array'})
MERGE (a)-[r:USES_METHOD]->(b);

MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-nextseq550'}), (b:ToolOrInstrument {uid: 'hu:instrument:illumina-nextseq-550-system'})
MERGE (a)-[r:RUNS_ON_INSTRUMENT]->(b);
