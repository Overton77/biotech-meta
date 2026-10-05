// W15 fixture 05 -- affiliate links (Amazon Associates tag) and listing-title amounts that never become label declarations (CQ-CM-01/04, CQ-AX-17).
// PUBLIC records, NEW_RETRIEVAL 2026-10-04T01:22:47Z: fastlifehacks.com "Rhonda Patrick Supplement List" (by John Alexander; published
// 2018-01-27, "Last Updated: September 23, 2026"). Links: anchor "Tru Niagen Pro" -> https://www.amazon.com/dp/B0CLQZHVHL?...&tag=partnerid1275-20...;
// anchor "Tru Niagen" -> https://www.amazon.com/dp/B07Y2ZGM48?...&tag=partnerid1275-20... (a TWO-BOTTLE listing). Text: "The regular Tru Niagen
// product is 300 mg per capsule." and "She has no affiliation with the brands mentioned." Disclosure (search snippet 01:22:42Z): "as an Amazon
// Associate, I earn from qualifying purchases". Titles from the Amazon all-offers capture of B07TK5K5TQ (01:19:48Z, recommendation list).
// The affiliate is the page author (tag holder per the first-person disclosure), NOT the subject of the article; AFFILIATE_FOR_OFFER is PROPOSED
// because the tag-to-person link rests on a search snippet. The featured offer behind the affiliate link was not captured: an Offer placeholder
// with NO seller of record stands for it (seller unknown, never inferred). Titles "1000mg", "300mg", "300 mg" are LISTING_TITLE_AMOUNT
// assertions on listings; no LabelDeclaration or QuantityDeclaration is created from them ([LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]).
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:fastlifehacks-rhonda-patrick-supplements'})
ON CREATE SET n.id = 'fastlifehacks-rhonda-patrick-supplements', n.canonicalUri = 'https://fastlifehacks.com/dr-rhonda-patricks-supplements-list/', n.title = 'Rhonda Patrick Supplement List - with Brands (2026)', n.sourceKind = 'THIRD_PARTY_PROFILE_PAGE', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'})
ON CREATE SET n.id = 'fastlifehacks-rhonda-patrick-2026-10-04t0122', n.retrievedAt = datetime('2026-10-04T01:22:47Z'), n.observedAt = datetime('2026-10-04T01:22:47Z'), n.publishedAt = datetime('2018-01-27T21:34:08Z'), n.contentHash = 'sha256:5bd1b00b9cadd62dceb180ca43cf9e91679fe68ebd7eff00ff813b102d961169', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.publisherRevisionNotice = 'Last Updated: September 23, 2026', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:fastlifehacks-rhonda-patrick-supplements'}), (b:SourceSnapshot {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:Source:Entity {uid: 'hu:source:firecrawl-search-fastlifehacks-disclosure'})
ON CREATE SET n.id = 'firecrawl-search-fastlifehacks-disclosure', n.canonicalUri = 'https://fastlifehacks.com/dr-rhonda-patricks-supplements-list/#search-snippet', n.title = 'Search-result snippet of the fastlifehacks page (Firecrawl search)', n.sourceKind = 'THIRD_PARTY_PROFILE_PAGE', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:firecrawl-search-fastlifehacks-2026-10-04t0122'})
ON CREATE SET n.id = 'firecrawl-search-fastlifehacks-2026-10-04t0122', n.retrievedAt = datetime('2026-10-04T01:22:42Z'), n.observedAt = datetime('2026-10-04T01:22:42Z'), n.contentHash = 'sha256:c3a89fc0ad2385b32a509e6dcc70b1047a432e30c4a76b5f613b0ece9260c890', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:firecrawl-search-fastlifehacks-disclosure'}), (b:SourceSnapshot {uid: 'hu:snapshot:firecrawl-search-fastlifehacks-2026-10-04t0122'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:firecrawl-search-fastlifehacks-2026-10-04t0122'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:Source:Entity {uid: 'hu:source:amazon-b07tk5k5tq-aod'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod', n.canonicalUri = 'https://www.amazon.com/dp/B07TK5K5TQ?aod=1', n.title = 'Amazon all offers B07TK5K5TQ', n.sourceKind = 'MARKETPLACE_LISTING', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod-2026-10-04t0119', n.retrievedAt = datetime('2026-10-04T01:19:48Z'), n.observedAt = datetime('2026-10-04T01:19:48Z'), n.contentHash = 'sha256:4ade1bffca2769de7ce6e8ab62e45ca7d18c1b24065ac219436d6148219e04c0', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:amazon-b07tk5k5tq-aod'}), (b:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fastlifehacks-link-pro'})
ON CREATE SET n.id = 'fastlifehacks-link-pro', n.selectorKind = 'TEXT_QUOTE', n.exact = '[Tru Niagen Pro](https://www.amazon.com/dp/B0CLQZHVHL?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B0CLQZHVHL_1783587143730)', n.quoteHash = 'sha256:57c82dbd7fcab60dcf0386f2b9305bf6a9c2ad0e0b5158305b13c8ce043f6080', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:fastlifehacks-link-pro'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fastlifehacks-link-regular'})
ON CREATE SET n.id = 'fastlifehacks-link-regular', n.selectorKind = 'TEXT_QUOTE', n.exact = 'The regular [Tru Niagen](https://www.amazon.com/dp/B07Y2ZGM48?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B07Y2ZGM48_1783587261301) product is 300 mg per capsule.', n.quoteHash = 'sha256:6f71fb472fe4146995d56c147f5831cd1befc969483557a07b71b52fd6d8cd96', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:fastlifehacks-link-regular'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:fastlifehacks-no-affiliation'})
ON CREATE SET n.id = 'fastlifehacks-no-affiliation', n.selectorKind = 'TEXT_QUOTE', n.exact = 'She has no affiliation with the brands mentioned.', n.quoteHash = 'sha256:223a638081a8d83fcf8c0804cfe78e41102f70d3d51da09b79dbd56e70984a7f', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:fastlifehacks-rhonda-patrick-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:fastlifehacks-no-affiliation'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:firecrawl-search-fastlifehacks-disclosure'})
ON CREATE SET n.id = 'firecrawl-search-fastlifehacks-disclosure', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Please note that where I link to products, some of these links are affiliate links. For example, as an Amazon Associate, I earn from qualifying ...', n.quoteHash = 'sha256:2508267ebb352fa36e1ab9e060b857a6ee23a0af7a06cb1bed325a02a706b951', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:firecrawl-search-fastlifehacks-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:firecrawl-search-fastlifehacks-disclosure'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07tk5k5tq'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod-title-b07tk5k5tq', n.selectorKind = 'TEXT_QUOTE', n.exact = 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 300mg, 30 Daily Servings', n.quoteHash = 'sha256:ae9847f716dd17690f6172b67d86b599bdd7de3ac21d69d54f76dbc957e45d47', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07tk5k5tq'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b0clqzhvhl'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod-title-b0clqzhvhl', n.selectorKind = 'TEXT_QUOTE', n.exact = 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 1000mg, 30 Daily Servings', n.quoteHash = 'sha256:220ea942c89d4f4b8d86121799d051a660b43740b36b154dd1cb81a180f26534', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b0clqzhvhl'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07y2zgm48'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod-title-b07y2zgm48', n.selectorKind = 'TEXT_QUOTE', n.exact = 'TRU NIAGEN NAD+ Supplement, NR 300mg, 60 Daily Servings | Two-bottle supply of patented Niagen NR', n.quoteHash = 'sha256:f02b927c59bc4dff3063aebcf9ec8641445009ced1b42a8ba0daf61a4d15baeb', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07y2zgm48'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b07tk5k5tq-aod-roles-b07tk5k5tq'})
ON CREATE SET n.id = 'amazon-b07tk5k5tq-aod-roles-b07tk5k5tq', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from Amazon.com Sold by TRU NIAGEN', n.quoteHash = 'sha256:9b0a56253c717f10c33dcb81473fb2e4e6b0ea4998736aaf441ce650cf020f58', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-roles-b07tk5k5tq'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:amazon-us-b0clqzhvhl'})
ON CREATE SET n.id = 'amazon-us-b0clqzhvhl', n.merchantListingId = 'B0CLQZHVHL', n.marketplace = 'amazon.com', n.commercePlatform = 'AMAZON', n.marketplaceRegion = 'US', n.title = 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 1000mg, 30 Daily Servings', n.canonicalUrl = 'https://www.amazon.com/dp/B0CLQZHVHL', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:amazon-us-b07y2zgm48'})
ON CREATE SET n.id = 'amazon-us-b07y2zgm48', n.merchantListingId = 'B07Y2ZGM48', n.marketplace = 'amazon.com', n.commercePlatform = 'AMAZON', n.marketplaceRegion = 'US', n.title = 'TRU NIAGEN NAD+ Supplement, NR 300mg, 60 Daily Servings | Two-bottle supply of patented Niagen NR', n.canonicalUrl = 'https://www.amazon.com/dp/B07Y2ZGM48', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:amazon-us-b07tk5k5tq'})
ON CREATE SET n.id = 'amazon-us-b07tk5k5tq', n.merchantListingId = 'B07TK5K5TQ', n.marketplace = 'amazon.com', n.commercePlatform = 'AMAZON', n.marketplaceRegion = 'US', n.title = 'TRU NIAGEN NAD+ Supplement, Nicotinamide Riboside 300mg, 30 Daily Servings', n.canonicalUrl = 'https://www.amazon.com/dp/B07TK5K5TQ', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
// Listing-title amounts: literal assertions on the LISTING (subject MerchantListing), never label declarations.
MERGE (n:Assertion {uid: 'hu:assertion:amazon-us-b0clqzhvhl-title-amount'})
ON CREATE SET n.id = 'amazon-us-b0clqzhvhl-title-amount', n.predicate = 'LISTING_TITLE_AMOUNT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'QUANTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.valueNumber = 1000.0, n.unitCode = 'mg', n.assertionBasis = 'MANUFACTURER_CLAIM', n.contentHash = 'sha256:31b863100c798465a04248ba4199caa33c12a1fc683a646e7563787398cf13d4', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b0clqzhvhl-title-amount'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0clqzhvhl'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b0clqzhvhl-title-amount'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b0clqzhvhl'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-us-b0clqzhvhl-title-amount-cf'})
ON CREATE SET n.id = 'amazon-us-b0clqzhvhl-title-amount-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-us-b0clqzhvhl-title-amount-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-us-b0clqzhvhl-title-amount'})
MERGE (a)-[r:EVALUATES]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:amazon-us-b07tk5k5tq-title-amount'})
ON CREATE SET n.id = 'amazon-us-b07tk5k5tq-title-amount', n.predicate = 'LISTING_TITLE_AMOUNT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'QUANTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.valueNumber = 300.0, n.unitCode = 'mg', n.assertionBasis = 'MANUFACTURER_CLAIM', n.contentHash = 'sha256:04a2056f8fb9808c96da227113ef8bbd582dca7c13b35858aafb7267269f283d', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b07tk5k5tq-title-amount'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b07tk5k5tq'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b07tk5k5tq-title-amount'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07tk5k5tq'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-us-b07tk5k5tq-title-amount-cf'})
ON CREATE SET n.id = 'amazon-us-b07tk5k5tq-title-amount-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-us-b07tk5k5tq-title-amount-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-us-b07tk5k5tq-title-amount'})
MERGE (a)-[r:EVALUATES]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:amazon-us-b07y2zgm48-title-amount'})
ON CREATE SET n.id = 'amazon-us-b07y2zgm48-title-amount', n.predicate = 'LISTING_TITLE_AMOUNT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'QUANTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.valueNumber = 300.0, n.unitCode = 'mg', n.assertionBasis = 'MANUFACTURER_CLAIM', n.contentHash = 'sha256:66d61cfcc8afebf073cc632898d594465f2e04909c964d0153a0c2c890400513', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b07y2zgm48-title-amount'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b07y2zgm48'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-us-b07y2zgm48-title-amount'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07y2zgm48'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-us-b07y2zgm48-title-amount-cf'})
ON CREATE SET n.id = 'amazon-us-b07y2zgm48-title-amount-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-us-b07y2zgm48-title-amount-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-us-b07y2zgm48-title-amount'})
MERGE (a)-[r:EVALUATES]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:walmart-us-1038593372-title-amount'})
ON CREATE SET n.id = 'walmart-us-1038593372-title-amount', n.predicate = 'LISTING_TITLE_AMOUNT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'QUANTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.valueNumber = 300.0, n.unitCode = 'mg', n.assertionBasis = 'MANUFACTURER_CLAIM', n.contentHash = 'sha256:516f35d4546626ec73284b03ca520e85fcc7f755c732a60686b6a0624321a937', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:walmart-us-1038593372-title-amount'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-us-1038593372-title-amount'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:walmart-us-1038593372-title-amount-cf'})
ON CREATE SET n.id = 'walmart-us-1038593372-title-amount-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:walmart-us-1038593372-title-amount-cf'}), (b:Assertion {uid: 'hu:assertion:walmart-us-1038593372-title-amount'})
MERGE (a)-[r:EVALUATES]->(b);
// Two-bottle listing B07Y2ZGM48 is for a Bundle (2 x 30-count), not for the variant the anchor text names.
MERGE (n:Bundle:Entity {uid: 'hu:bundle:tru-niagen-300mg-amazon-two-bottle'})
ON CREATE SET n.id = 'tru-niagen-300mg-amazon-two-bottle', n.name = 'Tru Niagen 300mg two-bottle supply (Amazon B07Y2ZGM48)', n.bundleKind = 'MULTI_PACK_SAME_ITEM', n.entityType = 'Bundle', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:BundleComponent:VersionedState {uid: 'hu:bundle-component:tru-niagen-300mg-amazon-two-bottle-30ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-amazon-two-bottle-30ct', n.quantity = 2, n.quantityStatus = 'REPORTED', n.componentRole = 'PRIMARY', n.payloadHash = 'sha256:52f15516f7dc4731e59fefd9429d2619f84f3465fb4643db968e773ae915c75d', n.stateType = 'BundleComponent', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Bundle {uid: 'hu:bundle:tru-niagen-300mg-amazon-two-bottle'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-amazon-two-bottle-30ct'})
MERGE (a)-[r:HAS_BUNDLE_COMPONENT]->(b)
ON CREATE SET r.orderIndex = 0;
MERGE (n:Assertion {uid: 'hu:assertion:amazon-two-bottle-component-30ct'})
ON CREATE SET n.id = 'amazon-two-bottle-component-30ct', n.predicate = 'COMPONENT_PRODUCT', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.basisKind = 'HYPOTHESIS', n.contentHash = 'sha256:37e81ab264d4a8df987eb66614e5ea63d60f02d94e16b0285ce40037b87d8a53', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-two-bottle-component-30ct'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-amazon-two-bottle-30ct'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-two-bottle-component-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-two-bottle-component-30ct'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07y2zgm48'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-amazon-two-bottle-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:COMPONENT_PRODUCT {relationshipUid: 'hu:rel:amazon-two-bottle-component-30ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-two-bottle-component-30ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle'})
ON CREATE SET n.id = 'amazon-b07y2zgm48-listing-for-two-bottle', n.predicate = 'LISTING_FOR', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:43ace91f1d4644a463c5ddc5afe5f6a02f90d932d5ded834a3afa12ea50add6c', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b07y2zgm48'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-amazon-two-bottle'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle'}), (b:SourceLocator {uid: 'hu:locator:amazon-b07tk5k5tq-aod-title-b07y2zgm48'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b07y2zgm48'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-amazon-two-bottle'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:amazon-b07y2zgm48-listing-for-two-bottle'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-b07y2zgm48-listing-for-two-bottle', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
// Affiliate links (immutable artifacts) -> listings.
MERGE (n:AffiliateLink:InformationArtifact {uid: 'hu:affiliate-link:fastlifehacks-b0clqzhvhl-partnerid1275-20'})
ON CREATE SET n.id = 'fastlifehacks-b0clqzhvhl-partnerid1275-20', n.url = 'https://www.amazon.com/dp/B0CLQZHVHL?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B0CLQZHVHL_1783587143730', n.contentHash = 'sha256:a022b1aad48ebbb4097cfe5a597dc759d4c3a57452052cea24e45889e30bd098', n.trackingParameter = 'tag', n.trackingValue = 'partnerid1275-20', n.affiliateProgram = 'AMAZON_ASSOCIATES', n.anchorText = 'Tru Niagen Pro', n.sourceLocatorUid = 'hu:locator:fastlifehacks-link-pro', n.observedAt = datetime('2026-10-04T01:22:47Z'), n.publishedAt = datetime('2018-01-27T21:34:08Z'), n.artifactType = 'AffiliateLink', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:AffiliateLink {uid: 'hu:affiliate-link:fastlifehacks-b0clqzhvhl-partnerid1275-20'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0clqzhvhl'})
MERGE (a)-[r:LINKS_TO]->(b);
MERGE (n:AffiliateLink:InformationArtifact {uid: 'hu:affiliate-link:fastlifehacks-b07y2zgm48-partnerid1275-20'})
ON CREATE SET n.id = 'fastlifehacks-b07y2zgm48-partnerid1275-20', n.url = 'https://www.amazon.com/dp/B07Y2ZGM48?ref=t_ac_spc_accepted_tile&linkCode=tr1&tag=partnerid1275-20&linkId=B07Y2ZGM48_1783587261301', n.contentHash = 'sha256:f36bf55862b300c783ce0f150feea346a64ac84d269cd09bfa80ff98690642b9', n.trackingParameter = 'tag', n.trackingValue = 'partnerid1275-20', n.affiliateProgram = 'AMAZON_ASSOCIATES', n.anchorText = 'Tru Niagen', n.sourceLocatorUid = 'hu:locator:fastlifehacks-link-regular', n.observedAt = datetime('2026-10-04T01:22:47Z'), n.publishedAt = datetime('2018-01-27T21:34:08Z'), n.artifactType = 'AffiliateLink', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:AffiliateLink {uid: 'hu:affiliate-link:fastlifehacks-b07y2zgm48-partnerid1275-20'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b07y2zgm48'})
MERGE (a)-[r:LINKS_TO]->(b);
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b0clqzhvhl-featured-seller-not-captured'})
ON CREATE SET n.id = 'amazon-us-b0clqzhvhl-featured-seller-not-captured', n.offerKind = 'PURCHASE', n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:48Z'), n.maturity = 'CANDIDATE', n.description = 'Featured offer behind the affiliate link; seller of record not captured (placeholder; merge by EquivalenceAssessment when captured).', n.payloadHash = 'sha256:530213b8d01af482afa93d8df11141a71feb3f1eac436b37c6b2579c2acf1660', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b0clqzhvhl'}), (b:Offer {uid: 'hu:offer:amazon-us-b0clqzhvhl-featured-seller-not-captured'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'})
ON CREATE SET n.id = 'john-alexander-affiliate-for-b0clqzhvhl-offer', n.predicate = 'AFFILIATE_FOR_OFFER', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.assertionBasis = 'UNSTATED', n.contentHash = 'sha256:333279e3318fbe5a60fe160d5f6b70c74191d6bb30d9577821491665cff5df1a', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'}), (b:Person {uid: 'hu:person:john-alexander-fastlifehacks'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'}), (b:Offer {uid: 'hu:offer:amazon-us-b0clqzhvhl-featured-seller-not-captured'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'}), (b:SourceLocator {uid: 'hu:locator:fastlifehacks-link-pro'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'}), (b:SourceLocator {uid: 'hu:locator:firecrawl-search-fastlifehacks-disclosure'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'}), (b:Person {uid: 'hu:person:john-alexander-fastlifehacks'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Person {uid: 'hu:person:john-alexander-fastlifehacks'}), (b:Offer {uid: 'hu:offer:amazon-us-b0clqzhvhl-featured-seller-not-captured'})
MERGE (a)-[r:AFFILIATE_FOR_OFFER {relationshipUid: 'hu:rel:john-alexander-affiliate-for-b0clqzhvhl-offer'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
