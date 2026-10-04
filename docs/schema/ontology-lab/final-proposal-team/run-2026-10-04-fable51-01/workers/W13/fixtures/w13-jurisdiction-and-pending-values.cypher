// W13 fixture 3: jurisdiction partition (US / EU / GB) for nicotinamide riboside chloride and the NDI 1062 filing
// acknowledgment. Load AFTER w13-regulatory-kinds.cypher. Uses PROPOSED enum values (W13-SR-03: PathwayKind
// NOVEL_FOOD_AUTHORISATION, RegulatoryResponseKind NOVEL_FOOD_AUTHORISED; W13-SR-06: NDI_FILING_ACKNOWLEDGED).
// Expected until those seam requests are ruled: V-W13-02 rows for each proposed value; V-336 rows for the two
// APPROVAL statuses (their response kind is not in the approving set). After ruling (approving set extended to
// NOVEL_FOOD_AUTHORISED): zero rows. Jurisdiction code GB-GBN (Great Britain) is requested from W00 in W13-SR-01.
MERGE (n:Source:Entity {uid: 'hu:source:eurlex-2020-16'})
SET n += {id: 'eurlex-2020-16', entityType: 'SOURCE', canonicalUri: 'https://eur-lex.europa.eu/eli/reg_impl/2020/16/oj/eng', sourceKind: 'REGULATORY_RECORD', name: 'Commission Implementing Regulation (EU) 2020/16', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:eurlex-2020-16-2026-10-04'})
SET n += {id: 'eurlex-2020-16-2026-10-04', artifactType: 'SOURCE_SNAPSHOT', canonicalUri: 'https://eur-lex.europa.eu/eli/reg_impl/2020/16/oj/eng', retrievedAt: datetime('2026-10-04T01:00:00Z'), observedAt: datetime('2026-10-04T01:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:51e81e3d93fa30faa7a786a1510c60ef92868847afebbd8234246a0fff0d2942', publishedAt: datetime('2020-01-10T00:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:eurlex-2020-16'}), (b:SourceSnapshot {uid: 'hu:snapshot:eurlex-2020-16-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:eurlex-2020-16-union-list-entry'})
SET n += {id: 'eurlex-2020-16-union-list-entry', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'Food Supplements as defined in Directive 2002/46/EC 300 mg/day for the general adult population, excluding pregnant and lactating women', quoteHash: 'sha256:4d0af46d3d2c3c5b9a9bf9f90d8d0a248da081a7c69285a1a1c199f38fe07f0d', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:eurlex-2020-16-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-union-list-entry'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:eurlex-2020-16-authorised-on'})
SET n += {id: 'eurlex-2020-16-authorised-on', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'Authorised on 20 February 2020.', quoteHash: 'sha256:f4ccfc3e5a2bb8a7cef3f4004cbd0a463433ffcbc8e64b4e8e30821363e6a441', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:eurlex-2020-16-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-authorised-on'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:Source:Entity {uid: 'hu:source:fsa-gb-novel-96'})
SET n += {id: 'fsa-gb-novel-96', entityType: 'SOURCE', canonicalUri: 'https://data.food.gov.uk/regulated-products/novel_authorisations/novel-96', sourceKind: 'REGULATORY_RECORD', name: 'FSA register: Nicotinamide riboside chloride NOVEL-96', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fsa-gb-novel-96-2026-10-04'})
SET n += {id: 'fsa-gb-novel-96-2026-10-04', artifactType: 'SOURCE_SNAPSHOT', canonicalUri: 'https://data.food.gov.uk/regulated-products/novel_authorisations/novel-96', retrievedAt: datetime('2026-10-04T01:00:00Z'), observedAt: datetime('2026-10-04T01:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:e35b21e495776dd15564ae5ef7361f920891b09bb214bb092bd912f11cac7452', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:fsa-gb-novel-96'}), (b:SourceSnapshot {uid: 'hu:snapshot:fsa-gb-novel-96-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fsa-novel-96-status'})
SET n += {id: 'fsa-novel-96-status', artifactType: 'SOURCE_LOCATOR', selectorKind: 'SECTION', section: 'Authorised novel ID NOVEL-96; Status: Authorised; Applies in: England, Scotland, Wales; Links: Assimilated EU Regulations 2017/2470, 2020/16', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fsa-gb-novel-96-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:fsa-novel-96-status'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:RegulatoryPathway:Entity {uid: 'hu:reg-pathway:eu-novel-food'})
SET n += {id: 'eu-novel-food', entityType: 'REGULATORY_PATHWAY', name: 'EU novel food authorisation (Regulation (EU) 2015/2283)', pathwayKind: 'NOVEL_FOOD_AUTHORISATION', jurisdiction: 'EU', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatoryAgency {uid: 'hu:org:european-commission'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:eu-novel-food'})
MERGE (a)-[r:OVERSEES]->(b)
SET r += {orderIndex: null};
MERGE (n:RegulatoryPathway:Entity {uid: 'hu:reg-pathway:gb-novel-food'})
SET n += {id: 'gb-novel-food', entityType: 'REGULATORY_PATHWAY', name: 'GB novel food authorisation (assimilated Regulation (EU) 2015/2283)', pathwayKind: 'NOVEL_FOOD_AUTHORISATION', jurisdiction: 'GB-GBN', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatoryAgency {uid: 'hu:org:uk-food-standards-agency'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:gb-novel-food'})
MERGE (a)-[r:OVERSEES]->(b)
SET r += {orderIndex: null};
MERGE (n:RegulatorySubmission:InformationArtifact {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'})
SET n += {id: 'eu-novel-food-nrc-chromadex', artifactType: 'REGULATORY_SUBMISSION', submissionKind: 'NOVEL_FOOD_AUTHORISATION', jurisdiction: 'EU', conditionsOfUseText: 'food supplements', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:eu-novel-food'})
MERGE (a)-[r:UNDER_PATHWAY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex'})
SET n += {id: 'submitted-by-eu-novel-food-nrc-chromadex', predicate: 'SUBMITTED_BY', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', contentHash: 'sha256:e75447ef4b92bba22d59153633001ac04960aab040a576c19e740c276544fa81', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex'}), (b:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-union-list-entry'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex'}), (b:RegulatoryAgency {uid: 'hu:org:european-commission'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:SUBMITTED_BY {relationshipUid: 'hu:rel:submitted-by-eu-novel-food-nrc-chromadex'}]->(b)
SET r += {assertionUid: 'hu:assertion:submitted-by-eu-novel-food-nrc-chromadex', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
MERGE (n:Assertion {uid: 'hu:assertion:about-eu-novel-food-nrc-chromadex'})
SET n += {id: 'about-eu-novel-food-nrc-chromadex', predicate: 'SUBMISSION_ABOUT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', contentHash: 'sha256:95e54219eabe703e535f04e6e0f78dc2afd60b6cc32454469c699b53190e7e69', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:about-eu-novel-food-nrc-chromadex'}), (b:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-eu-novel-food-nrc-chromadex'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-eu-novel-food-nrc-chromadex'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-union-list-entry'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-eu-novel-food-nrc-chromadex'}), (b:RegulatoryAgency {uid: 'hu:org:european-commission'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:SUBMISSION_ABOUT {relationshipUid: 'hu:rel:about-eu-novel-food-nrc-chromadex'}]->(b)
SET r += {assertionUid: 'hu:assertion:about-eu-novel-food-nrc-chromadex', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
MERGE (n:RegulatoryResponse:InformationArtifact {uid: 'hu:reg-response:eu-2020-16-nrc'})
SET n += {id: 'eu-2020-16-nrc', artifactType: 'REGULATORY_RESPONSE', responseKind: 'NOVEL_FOOD_AUTHORISED', decisionTextVerbatim: 'Commission Implementing Regulation (EU) 2020/16', issuedAt: datetime('2020-01-10T00:00:00Z'), jurisdiction: 'EU', conditionsOfUseText: 'Food Supplements as defined in Directive 2002/46/EC 300 mg/day for the general adult population, excluding pregnant and lactating women; 230 mg/day for pregnant and lactating women', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:eu-novel-food-nrc-chromadex'}), (b:RegulatoryResponse {uid: 'hu:reg-response:eu-2020-16-nrc'})
MERGE (a)-[r:SUBMISSION_HAS_RESPONSE]->(b);
MATCH (a:RegulatoryResponse {uid: 'hu:reg-response:eu-2020-16-nrc'}), (b:RegulatoryAgency {uid: 'hu:org:european-commission'})
MERGE (a)-[r:ISSUED_BY]->(b);
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:eu-nrc-novel-food'})
SET n += {id: 'eu-nrc-novel-food', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'EU', scopeText: 'Union list entry \'Nicotinamide riboside chloride\'; food supplements 300 mg/day adults (230 mg/day pregnant and lactating women); data protection to ChromaDex until 20 February 2025', legalBasisCitation: 'Regulation (EU) 2015/2283; Commission Implementing Regulation (EU) 2020/16', payloadHash: 'sha256:ad3f0c60358bf7023b2bfd9f885f7aff9b30d8652f94c5ac2a168a5e3f92fa74', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'})
SET n += {id: 'status-of-eu-nrc-novel-food', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFrom: datetime('2020-02-20T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', contentHash: 'sha256:d9b72e4ba295819f6ef5779e7504f5e556f28f713c7820d05ceee16db7639c52', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:eu-nrc-novel-food'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-union-list-entry'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'}), (b:SourceLocator {uid: 'hu:locator:eurlex-2020-16-authorised-on'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-eu-nrc-novel-food'}), (b:RegulatoryAgency {uid: 'hu:org:european-commission'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:eu-nrc-novel-food'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-eu-nrc-novel-food'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-eu-nrc-novel-food', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', validFrom: datetime('2020-02-20T00:00:00Z'), validFromPrecision: 'DAY'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:eu-nrc-novel-food'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:eu-novel-food'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:eu-nrc-novel-food'}), (b:RegulatoryResponse {uid: 'hu:reg-response:eu-2020-16-nrc'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:eu-nrc-novel-food'}), (b:RegulatoryAgency {uid: 'hu:org:european-commission'})
MERGE (a)-[r:ISSUED_BY]->(b);
MERGE (n:RegulatoryStatus:VersionedState {uid: 'hu:regulatory-status:gb-nrc-novel-food'})
SET n += {id: 'gb-nrc-novel-food', stateType: 'REGULATORY_STATUS', statusKind: 'APPROVAL', jurisdiction: 'GB-GBN', scopeText: 'NOVEL-96 Authorised; applies in England, Scotland, Wales (Northern Ireland not covered by this register entry; NI position not captured)', legalBasisCitation: 'Assimilated Regulation (EU) 2020/16', payloadHash: 'sha256:d15ba0ad6b5ba8fbc0cd3563e52a44136b690cdf5207c3900a6ed3f36b7325fc', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:status-of-gb-nrc-novel-food'})
SET n += {id: 'status-of-gb-nrc-novel-food', predicate: 'STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:d42913408881edcc275c12f9d7be795d9ddd4b5508642b8079c7318c6616f082', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:status-of-gb-nrc-novel-food'}), (b:RegulatoryStatus {uid: 'hu:regulatory-status:gb-nrc-novel-food'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-gb-nrc-novel-food'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-gb-nrc-novel-food'}), (b:SourceLocator {uid: 'hu:locator:fsa-novel-96-status'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:status-of-gb-nrc-novel-food'}), (b:RegulatoryAgency {uid: 'hu:org:uk-food-standards-agency'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:gb-nrc-novel-food'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:STATUS_OF {relationshipUid: 'hu:rel:status-of-gb-nrc-novel-food'}]->(b)
SET r += {assertionUid: 'hu:assertion:status-of-gb-nrc-novel-food', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:gb-nrc-novel-food'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:gb-novel-food'})
MERGE (a)-[r:UNDER_LEGAL_BASIS]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:gb-nrc-novel-food'}), (b:RegulatoryResponse {uid: 'hu:reg-response:eu-2020-16-nrc'})
MERGE (a)-[r:RESULTS_FROM_RESPONSE]->(b);
MATCH (a:RegulatoryStatus {uid: 'hu:regulatory-status:gb-nrc-novel-food'}), (b:RegulatoryAgency {uid: 'hu:org:uk-food-standards-agency'})
MERGE (a)-[r:ISSUED_BY]->(b);

// NDI 1062: submitted 2017-12-27, amended 2018-02-05 and 2018-03-06; FDA filing letter dated 2018-03-07 says acceptance
// for filing 'is a procedural matter' and 'does not constitute a finding by FDA that the new dietary ingredient ... is safe'.
// The company lists 'FDA NDIN no objection ... March 07, 2018 ... NDI 1062'. The 2018 response letter was not captured.
MERGE (n:Source:Entity {uid: 'hu:source:regulations-gov-fda-2018-s-0023-0032'})
SET n += {id: 'regulations-gov-fda-2018-s-0023-0032', entityType: 'SOURCE', canonicalUri: 'https://downloads.regulations.gov/FDA-2018-S-0023-0032/attachment_1.pdf', sourceKind: 'REGULATORY_RECORD', name: 'FDA filing letter NDI 1062 (regulations.gov FDA-2018-S-0023-0032)', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:regulations-gov-fda-2018-s-0023-0032-2026-10-04'})
SET n += {id: 'regulations-gov-fda-2018-s-0023-0032-2026-10-04', artifactType: 'SOURCE_SNAPSHOT', canonicalUri: 'https://downloads.regulations.gov/FDA-2018-S-0023-0032/attachment_1.pdf', retrievedAt: datetime('2026-10-04T01:00:00Z'), observedAt: datetime('2026-10-04T01:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:5edcb07f23376d4cdc754f6bcd59ad55fc7dd779b63ab0469c1d0625fb9e08bf', publishedAt: datetime('2018-03-07T00:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:regulations-gov-fda-2018-s-0023-0032'}), (b:SourceSnapshot {uid: 'hu:snapshot:regulations-gov-fda-2018-s-0023-0032-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:ndi-1062-filing-letter-procedural'})
SET n += {id: 'ndi-1062-filing-letter-procedural', artifactType: 'SOURCE_LOCATOR', selectorKind: 'TEXT_QUOTE', exact: 'Please note that acceptance of this notification for filing is a procedural matter, and thus, does not constitute a finding by FDA that the new dietary ingredient or supplement that contains the new dietary ingredient is safe or is not adulterated under 21 U .S.C. § 342.', quoteHash: 'sha256:afa3be9f6ef2646ba4a261763aa48dde8a24fb072a422a16a0f87752096f5476', normalizationVersion: 'NFC-WS1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:regulations-gov-fda-2018-s-0023-0032-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:ndi-1062-filing-letter-procedural'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:RegulatorySubmission:InformationArtifact {uid: 'hu:reg-submission:us-fda-ndi-1062'})
SET n += {id: 'us-fda-ndi-1062', artifactType: 'REGULATORY_SUBMISSION', submissionKind: 'NDI_NOTIFICATION', identifier: 'NDI 1062', jurisdiction: 'US', submittedAt: datetime('2017-12-27T00:00:00Z'), conditionsOfUseText: 'take 2 capsules, each containing 125mg NIAGEN®, for a daily serving of 250 mg NIAGEN® ... no more than 300 mg NIAGEN® a day', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'}), (b:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-ndi-notification'})
MERGE (a)-[r:UNDER_PATHWAY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:submitted-by-us-fda-ndi-1062'})
SET n += {id: 'submitted-by-us-fda-ndi-1062', predicate: 'SUBMITTED_BY', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', contentHash: 'sha256:9f68b3cb0f591f1388d56774fc8c22119ee4b779c38ec330fab81ee4f06a174c', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-us-fda-ndi-1062'}), (b:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-us-fda-ndi-1062'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-us-fda-ndi-1062'}), (b:SourceLocator {uid: 'hu:locator:ndi-1062-filing-letter-procedural'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:submitted-by-us-fda-ndi-1062'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:SUBMITTED_BY {relationshipUid: 'hu:rel:submitted-by-us-fda-ndi-1062'}]->(b)
SET r += {assertionUid: 'hu:assertion:submitted-by-us-fda-ndi-1062', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
MERGE (n:Assertion {uid: 'hu:assertion:about-us-fda-ndi-1062'})
SET n += {id: 'about-us-fda-ndi-1062', predicate: 'SUBMISSION_ABOUT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', contentHash: 'sha256:d8d27bf0cd6cfe548e03c93dc707c02cc139628beb797502c7aa53c5aee91a24', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:about-us-fda-ndi-1062'}), (b:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-us-fda-ndi-1062'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-us-fda-ndi-1062'}), (b:SourceLocator {uid: 'hu:locator:ndi-1062-filing-letter-procedural'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:about-us-fda-ndi-1062'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'}), (b:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
MERGE (a)-[r:SUBMISSION_ABOUT {relationshipUid: 'hu:rel:about-us-fda-ndi-1062'}]->(b)
SET r += {assertionUid: 'hu:assertion:about-us-fda-ndi-1062', recordedFrom: datetime('2026-10-04T02:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
MERGE (n:RegulatoryResponse:InformationArtifact {uid: 'hu:reg-response:us-fda-ndi-1062-filing-ack'})
SET n += {id: 'us-fda-ndi-1062-filing-ack', artifactType: 'REGULATORY_RESPONSE', responseKind: 'NDI_FILING_ACKNOWLEDGED', issuedAt: datetime('2018-03-07T00:00:00Z'), jurisdiction: 'US', agencyDisclaimerText: 'acceptance of this notification for filing is a procedural matter, and thus, does not constitute a finding by FDA that the new dietary ingredient or supplement that contains the new dietary ingredient is safe or is not adulterated', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-ndi-1062'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-ndi-1062-filing-ack'})
MERGE (a)-[r:SUBMISSION_HAS_RESPONSE]->(b);
MATCH (a:RegulatoryResponse {uid: 'hu:reg-response:us-fda-ndi-1062-filing-ack'}), (b:RegulatoryAgency {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ISSUED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-characterizes-ndi-1062'})
SET n += {id: 'truniagen-characterizes-ndi-1062', predicate: 'CHARACTERIZES_REGULATORY_RESPONSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T02:00:00Z'), predicateClass: 'REGULATORY', valueString: 'FDA NDIN no objection for Niagen (nicotinamide riboside chloride) on March 07, 2018; Dose: 300 mg/day; NDI 1062', assertionBasis: 'MANUFACTURER_CLAIM', contentHash: 'sha256:ae1121db9d057e9f8b1523d30a5c7c3c65c7f49ddb71fc3acad450d5fac2723c', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-characterizes-ndi-1062'}), (b:RegulatoryResponse {uid: 'hu:reg-response:us-fda-ndi-1062-filing-ack'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-characterizes-ndi-1062'}), (b:SourceLocator {uid: 'hu:locator:truniagen-gras-line-2026-10-04'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-characterizes-ndi-1062'}), (b:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-ndi-1062-characterization'})
SET n += {id: 'truniagen-ndi-1062-characterization', assessmentType: 'ADJUDICATION', adjudicationKind: 'SUPPORT', verdict: 'INSUFFICIENT', status: 'ACCEPTED', methodVersion: 'w13-regulatory-characterization-v1', reviewerType: 'AGENT', humanReviewPending: true, recordedAt: datetime('2026-10-04T02:00:00Z'), rationale: 'The FDA letter dated March 7, 2018 is a filing acknowledgment (procedural; no finding of safety). \'No objection\' is not established by the captured agency record; a later response letter was not captured, so the claim is not contradicted.', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-ndi-1062-characterization'}), (b:Assertion {uid: 'hu:assertion:truniagen-characterizes-ndi-1062'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-ndi-1062-characterization'}), (b:SourceLocator {uid: 'hu:locator:ndi-1062-filing-letter-procedural'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
