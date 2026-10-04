// W13 fixture 2 (negative): each section writes one forbidden shape with its own uids. Load AFTER
// w13-regulatory-kinds.cypher. Expected violations per section are listed in 06-fixtures-and-queries.md (N-01..N-14).

// N-01 (V-336, INV-304): APPROVAL status for Tru Niagen with no approving response (company says 'FDA approved')
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-tru-niagen-approval-no-response'})
SET n += {id: 'neg-tru-niagen-approval-no-response', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'US', scopeText: 'NEGATIVE: approval asserted from nothing', payloadHash: 'sha256:c345727221b0359818c9e9b93648560f68ec6110fd4a000a9e551da69a53eae1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response'})
SET n += {id: 'status-of-neg-tru-niagen-approval-no-response', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:18c6f6bd31c711e8d936ead7f16f53f2d948dd3e26906eb582d2f06eebd79295', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:neg-tru-niagen-approval-no-response'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response'}), (b:Product {uid: 'hu:product:tru-niagen-300-capsules'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response'}), (b:SourceLocator {uid: 'hu:locator:grn-000635-conclusion'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-tru-niagen-approval-no-response'}), (b:Product {uid: 'hu:product:tru-niagen-300-capsules'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-tru-niagen-approval-no-response'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-tru-niagen-approval-no-response', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-tru-niagen-approval-no-response'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-nda'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-tru-niagen-approval-no-response'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-02 (V-323, INV-304): establishment registration attached to a Product ('made in an FDA-registered facility')
MERGE (n:Assertion {uid: 'hu:assertion:neg-ffr-status-of-product'})
SET n += {id: 'neg-ffr-status-of-product', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2024-11-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:83118a8055c31c6e176f6eccdea4ed48bd4fd26f5528f1641a76983b77e52638', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-ffr-status-of-product'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:us-synthetic-plant-ffr'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:neg-ffr-status-of-product'}), (b:Product {uid: 'hu:product:tru-niagen-300-capsules'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:neg-ffr-status-of-product'}), (b:SourceLocator {uid: 'hu:locator:synthetic-ffr-confirmation-w13'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:neg-ffr-status-of-product'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:us-synthetic-plant-ffr'}), (b:Product {uid: 'hu:product:tru-niagen-300-capsules'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:neg-ffr-status-of-product'}]->(b)
SET r += {assertionUid: 'hu:assertion:neg-ffr-status-of-product', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2024-11-01T00:00:00Z'), validFromPrecision: 'DAY'};

// N-03 (V-320a, V-320b, V-336): GRAS 'no questions' projected as approval of NRC
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-nrc-gras-approval'})
SET n += {id: 'neg-nrc-gras-approval', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'US', scopeText: 'NEGATIVE: GRAS no questions read as approval', payloadHash: 'sha256:93a42766ecfe4fc5d274ed907c05607fe69bebeecd6c97eaa7acecc3acc2aa17', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-nrc-gras-approval'})
SET n += {id: 'status-of-neg-nrc-gras-approval', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:4c57e01afbd3c98381601ec209f4a046c611d20a191992d5b0fe7cd91ab65d3f', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-nrc-gras-approval'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:neg-nrc-gras-approval'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-nrc-gras-approval'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-nrc-gras-approval'}), (b:SourceLocator {uid: 'hu:locator:grn-000635-conclusion'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-nrc-gras-approval'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-nrc-gras-approval'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-nrc-gras-approval', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-nrc-gras-approval'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-nrc-gras-approval'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-nrc-gras-approval'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-04 (V-320a, V-321): orphan designation response projected as a DrugApproval
MERGE (n:DrugApproval:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'})
SET n += {id: 'neg-orphan-as-drug-approval', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'US', scopeText: 'NEGATIVE: designation read as approval', payloadHash: 'sha256:003d0c22ee9263da2cd0abc3849f330b8491c53ceb0c0aecd4bdb8112d3c2417', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-orphan-as-drug-approval'})
SET n += {id: 'status-of-neg-orphan-as-drug-approval', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2018-03-19T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:2ca3fbc266655e6229eea17dcb6f01c8d2e9602132bc669260a72d587cb07861', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-orphan-as-drug-approval'}), (b:DrugApproval {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-orphan-as-drug-approval'}), (b:MaterialMixture {uid: 'hu:mixture:nr-and-pterostilbene-oopd-628218'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-orphan-as-drug-approval'}), (b:SourceLocator {uid: 'hu:locator:oopd-628218-record'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:DrugApproval {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'}), (b:MaterialMixture {uid: 'hu:mixture:nr-and-pterostilbene-oopd-628218'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-orphan-as-drug-approval'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-orphan-as-drug-approval', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2018-03-19T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:DrugApproval {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-nda'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:DrugApproval {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-orphan-nr-pterostilbene-als-granted'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);
MATCH (a:DrugApproval {uid: 'hu:regulatory-status:neg-orphan-as-drug-approval'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-05 (V-320a, V-336): 510(k) clearance projected as approval
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-stelo-approval'})
SET n += {id: 'neg-stelo-approval', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'US', scopeText: 'NEGATIVE: clearance read as approval', payloadHash: 'sha256:0a8bd72328d8bcbe9980c648ee9f67dfc1bb3593998013d0ea2e7f71fe680d06', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-stelo-approval'})
SET n += {id: 'status-of-neg-stelo-approval', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2024-03-05T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:f677914a04eaa25eb201bc3e169b732f8ad7e63bf0920b90cd590097121f2fc4', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-stelo-approval'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:neg-stelo-approval'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-stelo-approval'}), (b:Product {uid: 'hu:product:dexcom-stelo'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-stelo-approval'}), (b:SourceLocator {uid: 'hu:locator:k234070-record'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-stelo-approval'}), (b:Product {uid: 'hu:product:dexcom-stelo'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-stelo-approval'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-stelo-approval', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2024-03-05T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-stelo-approval'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-510k'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-stelo-approval'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-510k-k234070-sese'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-stelo-approval'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-06 (V-320a, V-W13-12): De Novo grant read as PMA approval (BellLabs inferred assertion derived from the status)
MERGE (n:Assertion {uid: 'hu:assertion:neg-paige-pma-approval-inferred'})
SET n += {id: 'neg-paige-pma-approval-inferred', predicate: 'PMA_APPROVAL', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'PMA approved', basisKind: 'CALCULATED', derivationRule: 'NEGATIVE: De Novo grant read as PMA approval', contentHash: 'sha256:aaf036202c237e12306e6c11a3ed00342d544e695db7db23051313aaf7dbd15d', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-paige-pma-approval-inferred'}), (b:Product {uid: 'hu:product:paige-prostate'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (c:Assertion {uid: 'hu:assertion:neg-paige-pma-approval-inferred'}), (i:Assertion {uid: 'hu:assertion:status-of-us-paige-prostate-den200080'})
MERGE (c)-[:DERIVED_FROM_ASSERTION]->(i);

// N-07 (V-322): live Product.status = APPROVED for a marketed supplement with no APPROVAL status
MATCH (p:Product {uid: 'hu:product:tru-niagen-300-capsules'})
SET p.status = 'APPROVED';

// N-08 (V-334r): a status under the 2024 LDT rule whose episode outlives the vacatur
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'})
SET n += {id: 'neg-ldt-outlives-vacatur', stateType: 'REGULATORY_STATUS', statusKind: 'ENFORCEMENT_DISCRETION', jurisdiction: 'US', scopeText: 'NEGATIVE: status continues past vacatur', payloadHash: 'sha256:446cadaf5102488820cbd220c6fbf3d421c1f192d370d2c53488bd9a29f1a258', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-ldt-outlives-vacatur'})
SET n += {id: 'status-of-neg-ldt-outlives-vacatur', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2024-07-05T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2025-09-19T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', contentHash: 'sha256:2dac0705559fbb2b158f6599da652aa838a434dcc6cab4a7713fe1becb250433', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-ldt-outlives-vacatur'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-ldt-outlives-vacatur'}), (b:AssayVersion {uid: 'hu:assay-version:synthetic-ldt-nad-panel-v1'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-ldt-outlives-vacatur'}), (b:SourceLocator {uid: 'hu:locator:grn-000635-conclusion'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'}), (b:AssayVersion {uid: 'hu:assay-version:synthetic-ldt-nad-panel-v1'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-ldt-outlives-vacatur'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-ldt-outlives-vacatur', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', validFrom: datetime('2024-07-05T00:00:00Z'), validFromPrecision: 'DAY', validTo: datetime('2025-09-19T00:00:00Z'), validToPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-ldt-oversight'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'}), (b:RegulatoryPathwayVersion {uid: 'hu:reg-pathway-version:us-fda-ldt-rule-2024'})
MERGE (a)-[r:UNDER_LEGAL_BASIS_VERSION]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-ldt-outlives-vacatur'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-09 (V-335): accepted company characterization with no SUPPORT adjudication
MERGE (n:Assertion {uid: 'hu:assertion:neg-unadjudicated-characterization'})
SET n += {id: 'neg-unadjudicated-characterization', predicate: 'CHARACTERIZES_REGULATORY_RESPONSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'FDA approved Niagen as safe', contentHash: 'sha256:be6280ab9f720e05332add11ff9c6db45b07d2b32b4f5b39acc9af972e2e4b9b', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-unadjudicated-characterization'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-grn-000635'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:neg-unadjudicated-characterization'}), (b:SourceLocator {uid: 'hu:locator:grn-000635-conclusion'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:neg-unadjudicated-characterization'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);

// N-10 (V-W13-03): response kind outside the submission's pathway (GRAS submission answered with SUBSTANTIALLY_EQUIVALENT)
MERGE (n:RegulatorySubmission:InformationArtifact {uid: 'hu:reg-submission:neg-gras-notice-se-response'})
SET n += {id: 'neg-gras-notice-se-response', artifactType: 'REGULATORY_SUBMISSION', submissionKind: 'GRAS_NOTICE', jurisdiction: 'US', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:neg-gras-notice-se-response'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'})
MERGE (a)-[r:UNDER_PATHWAY]->(b);
MERGE (n:RegulatoryResponse:InformationArtifact {uid: 'hu:reg-response:neg-gras-notice-se-response'})
SET n += {id: 'neg-gras-notice-se-response', artifactType: 'REGULATORY_RESPONSE', responseKind: 'SUBSTANTIALLY_EQUIVALENT', jurisdiction: 'US', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:neg-gras-notice-se-response'}), (b:RegulatoryResponse {uid: 'hu:reg-response:neg-gras-notice-se-response'})
MERGE (a)-[r:SUBMISSION_HAS_RESPONSE]->(b);
MATCH (a:RegulatoryResponse {uid: 'hu:reg-response:neg-gras-notice-se-response'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-11 (V-W13-04, V-W13-05): submissionKind differs from its pathway; status legal-basis version from another pathway
MERGE (n:RegulatorySubmission:InformationArtifact {uid: 'hu:reg-submission:neg-kind-mismatch'})
SET n += {id: 'neg-kind-mismatch', artifactType: 'REGULATORY_SUBMISSION', submissionKind: 'NDI_NOTIFICATION', jurisdiction: 'US', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:neg-kind-mismatch'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-510k'})
MERGE (a)-[r:UNDER_PATHWAY]->(b);
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:neg-version-from-other-pathway'})
SET n += {id: 'neg-version-from-other-pathway', stateType: 'REGULATORY_STATUS', statusKind: 'NOTIFICATION_ON_FILE', jurisdiction: 'US', scopeText: 'NEGATIVE: GRAS status under an LDT version', payloadHash: 'sha256:b7bbd63b1bb6e167914a3221d1901d9a9cc90deb31f70edd365d94fce200ae46', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-neg-version-from-other-pathway'})
SET n += {id: 'status-of-neg-version-from-other-pathway', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:3db387cce9bee61c1cfd70be87875980134cdcee3d7aa00c1c5b627160de7092', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-version-from-other-pathway'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:neg-version-from-other-pathway'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-version-from-other-pathway'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-neg-version-from-other-pathway'}), (b:SourceLocator {uid: 'hu:locator:grn-000635-conclusion'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-version-from-other-pathway'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-neg-version-from-other-pathway'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-neg-version-from-other-pathway', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2016-08-03T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-version-from-other-pathway'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-version-from-other-pathway'}), (b:RegulatoryPathwayVersion {uid: 'hu:reg-pathway-version:us-fda-ldt-rule-2024'})
MERGE (a)-[r:UNDER_LEGAL_BASIS_VERSION]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:neg-version-from-other-pathway'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);

// N-12 (V-W13-08): legacy HAS_REGULATORY_STATUS written for a Facility registration status onto a Product, citing a non-STATUS_OF input
MATCH (a:Product {uid: 'hu:product:tru-niagen-300-capsules'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:us-synthetic-plant-ffr'})
MERGE (a)-[r:HAS_REGULATORY_STATUS]->(b)
SET r += {derivationRule: 'W13-DR-01', derivedFromAssertionUids: ['hu:assertion:synthetic-plant-claims-cgmp'], derivedAt: datetime('2026-10-04T02:00:00Z')};

// N-13 (V-W13-12): cGMP compliance inferred from registration and from the company's cGMP claim; GRAS determination
// inferred from 'no questions'; authorization inferred from enforcement discretion
MERGE (n:Assertion {uid: 'hu:assertion:neg-cgmp-from-registration'})
SET n += {id: 'neg-cgmp-from-registration', predicate: 'CGMP_COMPLIANT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'NEGATIVE inference', basisKind: 'CALCULATED', derivationRule: 'NEGATIVE neg-cgmp-from-registration', contentHash: 'sha256:ba9f22e5f9161b8e98dc0584ecbe7794dfce18cb4934d7b81acf68ec5342cb26', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-cgmp-from-registration'}), (b:Facility {uid: 'hu:facility:synthetic-supplement-plant'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (c:Assertion {uid: 'hu:assertion:neg-cgmp-from-registration'}), (i:Assertion {uid: 'hu:assertion:status-of-us-synthetic-plant-ffr'})
MERGE (c)-[:DERIVED_FROM_ASSERTION]->(i);
MERGE (n:Assertion {uid: 'hu:assertion:neg-cgmp-from-claim'})
SET n += {id: 'neg-cgmp-from-claim', predicate: 'CGMP_COMPLIANT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'NEGATIVE inference', basisKind: 'CALCULATED', derivationRule: 'NEGATIVE neg-cgmp-from-claim', contentHash: 'sha256:cbdcf96ca2909ebbda5e1ee1ef106951140f207e5d90b9b74afeeeaf8174699e', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-cgmp-from-claim'}), (b:Facility {uid: 'hu:facility:synthetic-supplement-plant'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (c:Assertion {uid: 'hu:assertion:neg-cgmp-from-claim'}), (i:Assertion {uid: 'hu:assertion:synthetic-plant-claims-cgmp'})
MERGE (c)-[:DERIVED_FROM_ASSERTION]->(i);
MERGE (n:Assertion {uid: 'hu:assertion:neg-gras-determination'})
SET n += {id: 'neg-gras-determination', predicate: 'FDA_GRAS_DETERMINATION', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'NEGATIVE inference', basisKind: 'CALCULATED', derivationRule: 'NEGATIVE neg-gras-determination', contentHash: 'sha256:a65f91ac9e84c461144a40039fccf5295bf58e6d0fd96dd353860f925123ae3b', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-gras-determination'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (c:Assertion {uid: 'hu:assertion:neg-gras-determination'}), (i:Assertion {uid: 'hu:assertion:status-of-us-nrc-grn-000635-on-file'})
MERGE (c)-[:DERIVED_FROM_ASSERTION]->(i);
MERGE (n:Assertion {uid: 'hu:assertion:neg-ldt-authorized'})
SET n += {id: 'neg-ldt-authorized', predicate: 'AUTHORIZATION', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'NEGATIVE inference', basisKind: 'CALCULATED', derivationRule: 'NEGATIVE neg-ldt-authorized', contentHash: 'sha256:2022ac87ccbe1048dd29b1f5167debbf967f225df193d7de90df771a34beadfa', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:neg-ldt-authorized'}), (b:AssayVersion {uid: 'hu:assay-version:synthetic-ldt-nad-panel-v1'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (c:Assertion {uid: 'hu:assertion:neg-ldt-authorized'}), (i:Assertion {uid: 'hu:assertion:status-of-us-synthetic-ldt-ed-v3'})
MERGE (c)-[:DERIVED_FROM_ASSERTION]->(i);

// N-14 (V-W13-06): two current HAS_PATHWAY_VERSION episodes of one pathway overlapping in valid time
MATCH (a:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-gras-notice'}), (b:RegulatoryPathwayVersion {uid: 'hu:reg-pathway-version:us-fda-gras-subpart-e'})
MERGE (a)-[r:HAS_PATHWAY_VERSION {relationshipUid: 'hu:rel:neg-gras-v2-overlap'}]->(b)
SET r += {assertionUid: 'hu:assertion:gras-pathway-v2-in-force', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFrom: datetime('2010-01-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'INFERRED', validToBasis: 'UNKNOWN'};
