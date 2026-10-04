// W14 fixture 2/4: synthetic minimal pairs (SYNTHETIC_FIXTURE; no real organization is involved). Run after w14-ip-core.cypher.
// MP-1 family-level license (stated) vs named-member license (core L2014); MP-2 sublicense licensor != assignee;
// MP-3 field of use NOT_REPORTED (redacted) vs null/null unknown (core L2012); MP-4 lapsed trademark as bounded state
// (VALIDITY_BOUNDED); MP-5 temporal correction of an expiry bound (EXTRACTION_FIX) visible in recorded time; MP-6 two jurisdictions,
// one grant, bounded license episode that ended.

MERGE (n:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
SET n:Occurrence, n += {occurrenceType: 'Activity', activityKind: 'EXTRACTION', startedAt: datetime('2026-10-04T00:57:00Z'), endedAt: datetime('2026-10-04T01:30:00Z'), methodVersion: 'w14-manual-curation/v1', externalRunSystem: 'claude-code', externalRunId: 'run-2026-10-04-fable51-01/W14', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Agent {uid: 'hu:agent:w14-opus-5-5'})
SET n:Entity, n += {entityType: 'Agent', name: 'W14 worker (Opus 5.5)', agentKind: 'MANUAL_VALIDATION_OF_AUTOMATED_AGENT', model: 'claude-opus-5-5', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Activity {uid: 'hu:activity:w14-curation-2026-10-04'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:WAS_ASSOCIATED_WITH]->(b);
MERGE (n:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'})
SET n:EvidenceAssessment, n += {assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', reviewedAt: datetime('2026-10-04T02:00:00Z'), recordedAt: datetime('2026-10-04T02:00:00Z'), methodVersion: 'w14-capture-check/v1', status: 'ACCEPTED', createdAt: datetime('2026-10-04T02:00:00Z'), rationale: 'Each evaluated assertion was compared with the stored excerpt of its locator.', privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:syn-university'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Synthetic University', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:syn-licensee-a'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Synthetic Licensee A', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:syn-sublicensee-b'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Synthetic Sublicensee B', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:syn-mark-owner'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Synthetic Mark Owner LLC', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Organization {uid: 'hu:org:syn-registry-office'})
SET n:Entity, n += {entityType: 'Organization', name: 'Synthetic Patent Office', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Source {uid: 'hu:source:syn-ip-dossier-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://example.invalid/w14/syn-ip-dossier', title: 'Synthetic IP dossier (fixture)', sourceKind: 'LEGAL_RECORD', name: 'synthetic', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:syn-ip-dossier-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://example.invalid/w14/syn-ip-dossier', retrievedAt: datetime('2026-10-04T00:00:00Z'), observedAt: datetime('2026-10-04T00:00:00Z'), contentHash: 'sha256:33369c066d29993af914521872fa6392ab8215e949bd3c4024df7427d5767e5c', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:syn-ip-dossier-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:syn-ip-dossier-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:syn-ip-dossier-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'WHOLE_SNAPSHOT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:syn-ip-dossier-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
SET n:Entity, n += {entityType: 'PatentFamily', familyDefinition: 'DOCDB_SIMPLE', familyIdentifier: 'SYN-000001', title: 'Synthetic composition family A', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:PatentApplication {uid: 'hu:patent-application:syn-us-a'})
SET n:InformationArtifact, n += {artifactType: 'PatentApplication', applicationNumber: 'SYN/000,001', jurisdiction: 'US', officeKey: 'US:SYN000001', filingDate: date('2015-03-02'), applicationKind: 'NATIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:PatentApplication {uid: 'hu:patent-application:syn-ep-a'})
SET n:InformationArtifact, n += {artifactType: 'PatentApplication', applicationNumber: 'EPSYN000001', jurisdiction: 'EP', officeKey: 'EP:SYN000001', filingDate: date('2016-03-01'), applicationKind: 'REGIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
SET n:InformationArtifact, n += {artifactType: 'GrantedPatent', patentNumber: 'SYN-9,000,001', kindCode: 'B1', jurisdiction: 'US', officeKey: 'US:SYN9000001', grantDate: date('2018-05-01'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:PatentClaim {uid: 'hu:patent-claim:syn-us-a-c1'})
SET n:InformationArtifact, n += {artifactType: 'PatentClaim', claimNumber: 1, claimKind: 'INDEPENDENT', dependsOnClaimNumbers: [], claimText: 'A synthetic oral composition comprising compound Q and a carrier.', claimTextHash: 'sha256:53b316536351c6075a7c61f9709f1a0a9f9b64a4a2fa8661a7e5741012c25ef4', claimTextNormalization: 'NFC-WS1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:PatentFamily {uid: 'hu:patent-family:syn-fam-a'}), (b:PatentApplication {uid: 'hu:patent-application:syn-us-a'})
MERGE (a)-[r:FAMILY_HAS_APPLICATION]->(b)
SET r += {orderIndex: 1};
MATCH (a:PatentFamily {uid: 'hu:patent-family:syn-fam-a'}), (b:PatentApplication {uid: 'hu:patent-application:syn-ep-a'})
MERGE (a)-[r:FAMILY_HAS_APPLICATION]->(b)
SET r += {orderIndex: 2};
MATCH (a:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'}), (b:PatentClaim {uid: 'hu:patent-claim:syn-us-a-c1'})
MERGE (a)-[r:HAS_PATENT_CLAIM]->(b)
SET r += {orderIndex: 1};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'})
SET n += {predicate: 'APPLICATION_GRANTED_AS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:0abfc788c46e04e2045b6673040a2f2754b082e7ed1202d2cfebd02ac0e76164', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2018-05-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'}), (b:PatentApplication {uid: 'hu:patent-application:syn-us-a'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-us-a-granted'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentApplication {uid: 'hu:patent-application:syn-us-a'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
MERGE (a)-[r:APPLICATION_GRANTED_AS {relationshipUid: 'hu:rel:w14-syn-us-a-granted'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-us-a-granted', validFrom: datetime('2018-05-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'})
SET n += {predicate: 'ASSIGNED_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:e55ba1b8c6fd84af180ca708851b5b543d644f79d855d63e3ad6f1c3eb3883f8', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'}), (b:LegalEntity {uid: 'hu:org:syn-university'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-fam-a-assigned-univ'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-university'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:ASSIGNED_PATENT {relationshipUid: 'hu:rel:w14-syn-fam-a-assigned-univ'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-fam-a-assigned-univ', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:syn-us-a-in-force'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:12db45ad385feddd63ef22334f8de1c39ae8ad11787a99b2ae91e53bf9c24470', statusKind: 'GRANTED_IN_FORCE', jurisdiction: 'US', effectiveFrom: datetime('2018-05-01T00:00:00Z'), effectiveTo: datetime('2035-03-02T00:00:00Z'), privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:048f4460b153a41b781b843ae8b8571cead10332c9b5609d557e693bac6b725a', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2018-05-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2035-03-02T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-us-a-in-force'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-us-a-in-force'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-us-a-in-force'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-us-a-in-force'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-us-a-in-force', validFrom: datetime('2018-05-01T00:00:00Z'), validTo: datetime('2035-03-02T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// MP-1 / MP-6: family-level coverage is stated by the source; field and territory bounded; the license episode ended 2025-01-01.
MERGE (n:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
SET n:VersionedState, n += {stateType: 'PatentLicense', payloadHash: 'sha256:4665c50f1e252bcf21e27911cae3e772e2b5aba10a5789503f7f1f02689a16c9', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), agreementTitle: 'Synthetic family license', effectiveFrom: datetime('2020-01-01T00:00:00Z'), effectiveTo: datetime('2025-01-01T00:00:00Z'), exclusive: false, exclusivityReportedStatus: 'REPORTED', fieldOfUse: 'dietary supplements', fieldOfUseReportedStatus: 'REPORTED', territory: 'United States', territoryJurisdictions: ['US'], territoryReportedStatus: 'REPORTED', sublicensable: true, coverageRuleText: 'all patents and applications in family SYN-000001'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'})
SET n += {predicate: 'LICENSES_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:5112231e96b526405b3f046544ab58fd47b068f2eb0faa1ee5be5bee449aa017', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2020-01-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-01-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'}), (b:LegalEntity {uid: 'hu:org:syn-licensee-a'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'}), (b:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'}), (b:LegalEntity {uid: 'hu:org:syn-university'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lf-licensee'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-licensee-a'}), (b:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
MERGE (a)-[r:LICENSES_PATENT {relationshipUid: 'hu:rel:w14-syn-lf-licensee'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lf-licensee', validFrom: datetime('2020-01-01T00:00:00Z'), validTo: datetime('2025-01-01T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'})
SET n += {predicate: 'GRANTS_PATENT_LICENSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:7821703a7ada9adf534528d98f695df8d1bae3dfccc37c31a43306de77c8344e', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2020-01-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-01-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'}), (b:LegalEntity {uid: 'hu:org:syn-university'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'}), (b:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'}), (b:LegalEntity {uid: 'hu:org:syn-university'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lf-licensor'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-university'}), (b:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
MERGE (a)-[r:GRANTS_PATENT_LICENSE {relationshipUid: 'hu:rel:w14-syn-lf-licensor'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lf-licensor', validFrom: datetime('2020-01-01T00:00:00Z'), validTo: datetime('2025-01-01T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'})
SET n += {predicate: 'LICENSE_COVERS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:3b9377a53fcf0a09e876765e1feb6b62e4c408f3ba0df7f73ff8630c336f3665', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2020-01-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-01-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'}), (b:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'}), (b:LegalEntity {uid: 'hu:org:syn-university'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lf-covers-family'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentLicense {uid: 'hu:patent-license:syn-univ-licensee-a-2020'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-syn-lf-covers-family'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lf-covers-family', validFrom: datetime('2020-01-01T00:00:00Z'), validTo: datetime('2025-01-01T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// MP-2 / MP-3: sublicense granted by the licensee (licensor != assignee); territory redacted in the source -> NOT_REPORTED.
MERGE (n:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
SET n:VersionedState, n += {stateType: 'PatentLicense', payloadHash: 'sha256:cdf489e8790dcaa5274b3e2dcca6fbc82a04f76f9f66cedbeb2abe5e3e268acd', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), agreementTitle: 'Synthetic sublicense', effectiveFrom: datetime('2021-03-01T00:00:00Z'), exclusive: false, exclusivityReportedStatus: 'REPORTED', fieldOfUse: 'dietary supplements', fieldOfUseReportedStatus: 'REPORTED', territoryReportedStatus: 'NOT_REPORTED', sublicensable: false, coverageRuleText: '[***] (redacted in source)'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'})
SET n += {predicate: 'LICENSES_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:edc89a4107e0d81646e5913132a08658e4d3aabc2ff8cc7afa5c255f7ec526bc', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'}), (b:LegalEntity {uid: 'hu:org:syn-sublicensee-b'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'}), (b:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'}), (b:LegalEntity {uid: 'hu:org:syn-licensee-a'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensee'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-sublicensee-b'}), (b:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
MERGE (a)-[r:LICENSES_PATENT {relationshipUid: 'hu:rel:w14-syn-lsub-licensee'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lsub-licensee', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'})
SET n += {predicate: 'GRANTS_PATENT_LICENSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:2719b3f32dcad46403da04105206b6af08c45fbb6442aa0038acda92e299aabf', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'}), (b:LegalEntity {uid: 'hu:org:syn-licensee-a'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'}), (b:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'}), (b:LegalEntity {uid: 'hu:org:syn-licensee-a'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lsub-licensor'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-licensee-a'}), (b:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
MERGE (a)-[r:GRANTS_PATENT_LICENSE {relationshipUid: 'hu:rel:w14-syn-lsub-licensor'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lsub-licensor', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'})
SET n += {predicate: 'LICENSE_COVERS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:2f37a083b54e6b56a236bf12c3a31ba624e1dcc2a17d12f89d7f110da3ff400c', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'}), (b:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'}), (b:LegalEntity {uid: 'hu:org:syn-licensee-a'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-lsub-covers-family'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentLicense {uid: 'hu:patent-license:syn-licensee-a-sublicensee-b-2021'}), (b:PatentFamily {uid: 'hu:patent-family:syn-fam-a'})
MERGE (a)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-syn-lsub-covers-family'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-lsub-covers-family', validFrom: datetime('2021-03-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// MP-4: lapsed trademark as bounded state; the REGISTERED episode is closed by VALIDITY_BOUNDED, CANCELLED follows.
MERGE (n:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
SET n:Entity, n += {entityType: 'Trademark', markText: 'EXAMPLEMARK', jurisdiction: 'US', applicationSerialNumber: 'SYN90000001', registrationNumber: 'SYN5000001', officeKey: 'US:SYN90000001', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'})
SET n += {predicate: 'OWNS_TRADEMARK', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:9f97e2b19ebad9aa28b56897bf61f466533728d8cc6e7ed69297b72a47975d4f', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2015-01-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'}), (b:LegalEntity {uid: 'hu:org:syn-mark-owner'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-tm-owner'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:syn-mark-owner'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:OWNS_TRADEMARK {relationshipUid: 'hu:rel:w14-syn-tm-owner'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-tm-owner', validFrom: datetime('2015-01-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-registered'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:7e91224474dd81f1d8d0da062006ad12b733c7592c7e731a18d21a3926bf44b7', statusKind: 'REGISTERED', jurisdiction: 'US', effectiveFrom: datetime('2015-01-06T00:00:00Z'), niceClasses: [5], privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-cancelled'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:eaf0fc31d7f0e456f2b416b3d8092f71a5b871d186ef069515847b129fbc2e2e', statusKind: 'CANCELLED', jurisdiction: 'US', effectiveFrom: datetime('2021-07-06T00:00:00Z'), statusTextVerbatim: 'Registration cancelled: Section 8 declaration not filed', niceClasses: [5], privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
// A1 (recorded 01:20, open end) is bounded by A2 (recorded 01:30, same object and start, end 2021-07-06): TM-R3, V-507b.
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'})
SET n += {predicate: 'IP_STATUS_OF', status: 'SUPERSEDED', recordedAt: datetime('2026-10-04T01:20:00Z'), recordedTo: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:041da8269c98254d88b3fd9acc06014fbeb4018652a8ead4c6d8684cbf474cfe', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2015-01-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:20:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-registered'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-registered'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-tm-registered-open'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-tm-registered-open', validFrom: datetime('2015-01-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:20:00Z'), recordedTo: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:05a52e045e6f30b57b2a8d70ea0d0342bdd35b4e5922de261d3e88a0acf60967', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2015-01-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2021-07-06T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-registered'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-registered'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-tm-registered'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-tm-registered', validFrom: datetime('2015-01-06T00:00:00Z'), validTo: datetime('2021-07-06T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MATCH (n:Assertion {uid: 'hu:assertion:w14-syn-tm-registered'}), (o:Assertion {uid: 'hu:assertion:w14-syn-tm-registered-open'})
MERGE (n)-[r:SUPERSEDES]->(o) SET r.supersessionKind = 'VALIDITY_BOUNDED', r.recordedAt = datetime('2026-10-04T01:30:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:a3e5f445a32ae824e16ffca1d94871a73e30bd9e512b2d6fe866a4880ee10cd1', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2021-07-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-cancelled'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-tm-cancelled'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-examplemark-cancelled'}), (b:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-tm-cancelled'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-tm-cancelled', validFrom: datetime('2021-07-06T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// MP-5: correction in recorded time. v0 (recorded 01:20) bounded the in-force episode at a naive 20-year term 2035-03-02 -> wrong;
// the corrected assertion (recorded 01:30) carries the stated adjusted expiry 2035-09-30. v0 is SUPERSEDED (EXTRACTION_FIX).
MERGE (n:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
SET n:InformationArtifact, n += {artifactType: 'GrantedPatent', patentNumber: 'SYN-9,000,002', jurisdiction: 'US', officeKey: 'US:SYN9000002', grantDate: date('2017-01-10'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v0'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:3e24f924e628930b0074abb924c5e00bd0d612911c39b9fc4286f91892ced836', statusKind: 'GRANTED_IN_FORCE', jurisdiction: 'US', effectiveFrom: datetime('2017-01-10T00:00:00Z'), effectiveTo: datetime('2035-03-02T00:00:00Z'), privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v1'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:d265a63e843ebb34ffa204f76bcf3485b94ebad8d6d5db166f18379f963c54db', statusKind: 'GRANTED_IN_FORCE', jurisdiction: 'US', effectiveFrom: datetime('2017-01-10T00:00:00Z'), effectiveTo: datetime('2035-09-30T00:00:00Z'), statusTextVerbatim: 'Adjusted expiration 2035-09-30', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'})
SET n += {predicate: 'IP_STATUS_OF', status: 'SUPERSEDED', recordedAt: datetime('2026-10-04T01:20:00Z'), recordedTo: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:5d43583a6034cd2100288b750404ec568ba9b08d61361f63a5dae56ed0d4ce66', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2017-01-10T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2035-03-02T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'INFERRED', jurisdiction: 'US', derivationRule: 'WRONG: naive 20-year term from filing 2015-03-02, ignores patent term adjustment', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:20:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v0'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v0'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-us-b-in-force-v0'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-us-b-in-force-v0', validFrom: datetime('2017-01-10T00:00:00Z'), validTo: datetime('2035-03-02T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'INFERRED', recordedFrom: datetime('2026-10-04T01:20:00Z'), recordedTo: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:21c226c4c845965535e7056c6520acac9819d5aeda29d023234fda624249a1fb', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2017-01-10T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2035-09-30T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (b:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v1'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (b:Organization {uid: 'hu:org:syn-registry-office'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (b:SourceLocator {uid: 'hu:locator:syn-ip-dossier-whole'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:syn-us-b-in-force-v1'}), (b:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-syn-us-b-in-force-v1'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-syn-us-b-in-force-v1', validFrom: datetime('2017-01-10T00:00:00Z'), validTo: datetime('2035-09-30T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MATCH (n:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v1'}), (o:Assertion {uid: 'hu:assertion:w14-syn-us-b-in-force-v0'})
MERGE (n)-[r:SUPERSEDES]->(o) SET r.supersessionKind = 'EXTRACTION_FIX', r.recordedAt = datetime('2026-10-04T01:30:00Z');
// Supersession is recorded between the authorizing assertions only; states are never linked by SUPERSEDES (V-507).
