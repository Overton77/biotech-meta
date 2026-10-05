// W13 fixture 4 (candidate RegulatoryInspection; CQ-MF-C01, CQ-MF-06). Load AFTER w13-regulatory-kinds.cypher.
// Real: FDA warning letter CMS #723021 (Nutratech, LLC, Phoenix NY; inspection 2025-09-22..2025-10-15; Form FDA 483 issued
// 2025-10-15; letter 2026-06-04) and CMS #698661 (Anti L'Age, Riverside CA) whose text states both 'through October 4,
// 2024' and 'through October 7, 2024'. Classification (NAI/VAI/OAI) not captured (FDA Data Dashboard API needs
// credentials). Uid token regulatory-inspection pending W13-SR-04; candidate predicates INSPECTION_PERIOD,
// INSPECTION_FOUND_VIOLATION pending W13-SR-07. Expected: V-W13-11 zero rows; the CQ-MF-C01 query returns one resolved
// inspection and one CONFLICTING end date; the failing-case section (commented) shows the status collapse firing V-333.
MERGE (n:Source:Entity {uid: 'hu:source:fda-wl-nutratech-723021'})
SET n += {id: 'fda-wl-nutratech-723021', entityType: 'SOURCE', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/nutratech-llc-723021-06042026', sourceKind: 'REGULATORY_RECORD', name: 'Warning letter Nutratech, LLC CMS #723021', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-wl-nutratech-723021-2026-10-04'})
SET n += {id: 'fda-wl-nutratech-723021-2026-10-04', artifactType: 'SOURCE_SNAPSHOT', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/nutratech-llc-723021-06042026', retrievedAt: datetime('2026-10-04T01:00:00Z'), observedAt: datetime('2026-10-04T01:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:b571bfcd403d686a3b7a7acecf63a0e8e7c2f2486d50cee079397a47b57fe21f', publishedAt: datetime('2026-06-04T00:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:fda-wl-nutratech-723021'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-wl-nutratech-723021-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MERGE (n:Source:Entity {uid: 'hu:source:fda-wl-anti-lage-698661'})
SET n += {id: 'fda-wl-anti-lage-698661', entityType: 'SOURCE', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/anti-lage-698661-04172025', sourceKind: 'REGULATORY_RECORD', name: 'Warning letter Anti L\'Age CMS #698661', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-wl-anti-lage-698661-2026-10-04'})
SET n += {id: 'fda-wl-anti-lage-698661-2026-10-04', artifactType: 'SOURCE_SNAPSHOT', canonicalUri: 'https://www.fda.gov/inspections-compliance-enforcement-and-criminal-investigations/warning-letters/anti-lage-698661-04172025', retrievedAt: datetime('2026-10-04T01:00:00Z'), observedAt: datetime('2026-10-04T01:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:e11111330f8b62d8510ba0aeed752760b8fab2a62ec9b075f2c86198adb74edb', publishedAt: datetime('2025-04-17T00:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:fda-wl-anti-lage-698661'}), (b:SourceSnapshot {uid: 'hu:snapshot:fda-wl-anti-lage-698661-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-723021-inspection-period'})
SET n += {id: 'wl-723021-inspection-period', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'conducted an inspection of your facility located at 67 County Route 59, Phoenix, NY on September 22 through October 15, 2025.', quoteHash: 'sha256:de40c351124e182124b077450333f49c49b977d340b55946860fb7dfb8b639d0', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-nutratech-723021-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-inspection-period'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-723021-form-483'})
SET n += {id: 'wl-723021-form-483', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'At the conclusion of the inspection on October 15, 2025, our investigator provided you with a Form FDA 483, Inspectional Observations (FDA 483).', quoteHash: 'sha256:3fb3e939e8176099f50d12cab97625ba5e7fd9163a10da5437d413277eb54852', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-nutratech-723021-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-form-483'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-723021-cgmp-violation-4'})
SET n += {id: 'wl-723021-cgmp-violation-4', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'You failed to establish product specifications for the identity, purity, strength, and composition of the finished batch of the dietary supplement to ensure the quality of the dietary supplement, as required by 21 CFR 111.70(e).', quoteHash: 'sha256:e765c5cf151f4705ab4de50a0a8be3d7e925dd7b528b8067fc814331bbc41a59', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-nutratech-723021-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-cgmp-violation-4'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-698661-period-intro'})
SET n += {id: 'wl-698661-period-intro', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'from September 17, 2024, through October 4, 2024', quoteHash: 'sha256:cfd49bdca3c49d9f7067e20222c5463cda53fee848e52b9e1861d20e21209846', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-anti-lage-698661-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-period-intro'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-698661-period-adulterated'})
SET n += {id: 'wl-698661-period-adulterated', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'The inspection of your facility from September 17, 2024, through October 7, 2024, identified serious violations', quoteHash: 'sha256:c2d5c3f8cd3de013ae2df11f185c5bbb0e4a9b66b67f39293196312b8e802deb', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-anti-lage-698661-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-period-adulterated'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wl-698661-form-483'})
SET n += {id: 'wl-698661-form-483', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'At the conclusion of the inspection on October 4, 2024, our investigator provided you with a Form FDA 483', quoteHash: 'sha256:3860203b7bc1d53822e8e681d0f11756c472d4d64f19e4468a712ef965725ac8', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fda-wl-anti-lage-698661-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-form-483'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:Facility:Entity {uid: 'hu:facility:nutratech-phoenix-ny'})
SET n += {id: 'nutratech-phoenix-ny', entityType: 'FACILITY', name: 'Nutratech, LLC facility, 67 County Route 59, Phoenix, NY', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Facility:Entity {uid: 'hu:facility:anti-lage-riverside-ca'})
SET n += {id: 'anti-lage-riverside-ca', entityType: 'FACILITY', name: 'Anti L\'Age facility, 6086 Brockton Ave, Riverside, CA', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:RegulatoryInspection:Occurrence {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'})
SET n += {id: 'us-fda-nutratech-2025-09', occurrenceType: 'REGULATORY_INSPECTION', jurisdiction: 'US', startedAt: datetime('2025-09-22T00:00:00Z'), endedAt: datetime('2025-10-15T00:00:00Z'), inspectionScopeText: 'CGMP in Manufacturing, Packaging, Labeling, or Holding Operations for Dietary Supplements (21 CFR Part 111)', form483Issued: true, form483IssuedAt: datetime('2025-10-15T00:00:00Z'), maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:CONDUCTED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:inspected-nutratech-2025'})
SET n += {id: 'inspected-nutratech-2025', predicate: 'INSPECTED_FACILITY', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2025-09-22T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-10-16T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', contentHash: 'sha256:726851ac5966775b088d46f6cc69b5c34b3cf4e865dd2de22b6925a1630240ce', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:inspected-nutratech-2025'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-nutratech-2025'}), (b:Facility {uid: 'hu:facility:nutratech-phoenix-ny'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-nutratech-2025'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-inspection-period'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-nutratech-2025'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'}), (b:Facility {uid: 'hu:facility:nutratech-phoenix-ny'})
MERGE (a)-[r:INSPECTED_FACILITY {relationshipUid: 'hu:rel:inspected-nutratech-2025'}]->(b)
SET r += {assertionUid: 'hu:assertion:inspected-nutratech-2025', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', validFrom: datetime('2025-09-22T00:00:00Z'), validFromPrecision: 'DAY', validTo: datetime('2025-10-16T00:00:00Z'), validToPrecision: 'DAY'};
MERGE (n:Assertion {uid: 'hu:assertion:nutratech-inspection-period'})
SET n += {id: 'nutratech-inspection-period', predicate: 'INSPECTION_PERIOD', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'September 22 through October 15, 2025', validFrom: datetime('2025-09-22T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-10-16T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', contentHash: 'sha256:0efb31ecab75ebe406638f6790a5002bfc7e9470339c0aa44c5cd5e0e79e3232', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-inspection-period'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-inspection-period'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-inspection-period'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-inspection-period'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:nutratech-violation-111-70e'})
SET n += {id: 'nutratech-violation-111-70e', predicate: 'INSPECTION_FOUND_VIOLATION', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: '21 CFR 111.70(e)', contentHash: 'sha256:05b8d00689268f08f24ea365dfa446c8dd7a8aa93441fa69d0bd7d93e3a31f27', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-violation-111-70e'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-nutratech-2025-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-violation-111-70e'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-cgmp-violation-4'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-violation-111-70e'}), (b:SourceLocator {uid: 'hu:locator:wl-723021-form-483'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:nutratech-violation-111-70e'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MERGE (n:RegulatoryInspection:Occurrence {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'})
SET n += {id: 'us-fda-anti-lage-2024-09', occurrenceType: 'REGULATORY_INSPECTION', jurisdiction: 'US', startedAt: datetime('2024-09-17T00:00:00Z'), endedAt: null, form483Issued: true, form483IssuedAt: datetime('2024-10-04T00:00:00Z'), maturity: 'CANDIDATE', inspectionScopeText: 'CGMP for dietary supplements (21 CFR Part 111)', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:CONDUCTED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:inspected-anti-lage-2024'})
SET n += {id: 'inspected-anti-lage-2024', predicate: 'INSPECTED_FACILITY', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2024-09-17T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:0c7981be85f2a04f8e3360fcfbe3d5fd1434465ed5542be455ab343f6e1b2cae', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:inspected-anti-lage-2024'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-anti-lage-2024'}), (b:Facility {uid: 'hu:facility:anti-lage-riverside-ca'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-anti-lage-2024'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-period-intro'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:inspected-anti-lage-2024'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'}), (b:Facility {uid: 'hu:facility:anti-lage-riverside-ca'})
MERGE (a)-[r:INSPECTED_FACILITY {relationshipUid: 'hu:rel:inspected-anti-lage-2024'}]->(b)
SET r += {assertionUid: 'hu:assertion:inspected-anti-lage-2024', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2024-09-17T00:00:00Z'), validFromPrecision: 'DAY'};
MERGE (n:Assertion {uid: 'hu:assertion:anti-lage-period-oct-4'})
SET n += {id: 'anti-lage-period-oct-4', predicate: 'INSPECTION_PERIOD', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'September 17, 2024, through October 4, 2024', validFrom: datetime('2024-09-17T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2024-10-05T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', contentHash: 'sha256:b18e4fb7f63fd20a5aeb4bdeb48a0d4b061b8899b82d5b8764184b31f2d35f7a', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-4'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-4'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-period-intro'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-4'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-form-483'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-4'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:anti-lage-period-oct-7'})
SET n += {id: 'anti-lage-period-oct-7', predicate: 'INSPECTION_PERIOD', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'September 17, 2024, through October 7, 2024', validFrom: datetime('2024-09-17T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2024-10-08T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', contentHash: 'sha256:4d4f0f3e508ccbe1fc58c00684b24a588b41b2d4f07f3cf70e40c5fed3447758', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-7'}), (b:RegulatoryInspection {uid: 'hu:regulatory-inspection:us-fda-anti-lage-2024-09'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-7'}), (b:SourceLocator {uid: 'hu:locator:wl-698661-period-adulterated'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:anti-lage-period-oct-7'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);

// FAILING CASE without the candidate (load only in a scratch database): the inspection collapsed into a status.
// Uncomment to see V-333 (statusKind outside the enum) and V-W13-01 (non-registration status on a Facility) fire.
// MERGE (s:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-inspection-as-status'})
// SET s += {statusKind: 'INSPECTED_OAI', jurisdiction: 'US', stateType: 'REGULATORY_STATUS', payloadHash: 'sha256:00'};
// MATCH (s:RegulatoryStatus {uid: 'hu:regulatory-status:neg-inspection-as-status'}), (f:Facility {uid: 'hu:facility:nutratech-phoenix-ny'})
// MERGE (s)-[:STATUS_OF {relationshipUid: 'hu:rel:neg-inspection-as-status', assertionUid: 'hu:assertion:none', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(f);
