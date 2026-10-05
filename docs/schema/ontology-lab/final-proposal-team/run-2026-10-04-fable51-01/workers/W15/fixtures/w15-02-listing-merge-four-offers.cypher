// W15 fixture 02 -- listing merge: one MerchantListing (ASIN B000QSNYGI), four sellers' Offers (CQ-CM-01, CQ-CM-02, CQ-CM-03).
// PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:22:25Z, Amazon all-offers panel (aod=1), PARTIAL_EXCERPT, hash SYNTHETIC_FIXTURE.
// Offers as displayed: Amazon.com ships+sells $102.81 (List Price $114.99); My Nutrition Depot ships+sells $109.99;
// ZK-INC ships+sells $149.00; BE REBELLION USA sold, Ships from Amazon.com, $155.00. One listing, four propositions;
// the listing is not four products and not one seller. Amazon is seller of record ONLY for its own retail offer, so SELLS_PRODUCT
// for Amazon is derived from that one SELLER_OF_RECORD_FOR assertion; Amazon hosting/fulfilling the BE REBELLION offer adds nothing.
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:amazon-b000qsnygi-aod'})
ON CREATE SET n.id = 'amazon-b000qsnygi-aod', n.canonicalUri = 'https://www.amazon.com/dp/B000QSNYGI?aod=1', n.title = 'Amazon all offers B000QSNYGI', n.sourceKind = 'MARKETPLACE_LISTING', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'})
ON CREATE SET n.id = 'amazon-b000qsnygi-aod-2026-10-04t0122', n.retrievedAt = datetime('2026-10-04T01:22:25Z'), n.observedAt = datetime('2026-10-04T01:22:25Z'), n.contentHash = 'sha256:c5ed4244b5e083f849b4f22bee0ea2b7ed54f88d6e34e7e07da031c20b562987', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:amazon-b000qsnygi-aod'}), (b:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-title'})
ON CREATE SET n.id = 'amazon-b000qsnygi-title', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Optimum Nutrition Gold Standard Whey Protein, Double Rich Chocolate, 5 LB', n.quoteHash = 'sha256:1fddbc6ced7b3af33176db985af203a1bb3c1bc1ad0d26a893ccc7ec7f259bf5', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-title'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o1-roles'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o1-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from Amazon.com Sold by Amazon.com', n.quoteHash = 'sha256:7806452fe4a0f0aadf1538199ad5577b314737ab20e23c57297c3038303f1e37', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o1-price'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o1-price', n.selectorKind = 'TEXT_QUOTE', n.exact = '$102.81 with 11 percent savings', n.quoteHash = 'sha256:848551334d29e7e2b0d0c4a7fa7e52960efcb5d7e56b233c5d9f3c2c75dd6e52', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o1-list'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o1-list', n.selectorKind = 'TEXT_QUOTE', n.exact = 'List Price: $114.99', n.quoteHash = 'sha256:178e7edb3cc23c955a48b92fa5602dac646c665431c61fb39abea746107704a0', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-list'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o2-roles'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o2-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from My Nutrition Depot™ Sold by My Nutrition Depot™', n.quoteHash = 'sha256:ee9e293135461182260666853f3a6c153ca6699b5a2055bf4349dacc5d127a64', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o2-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o2-price'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o2-price', n.selectorKind = 'TEXT_QUOTE', n.exact = '$109.99 $1.37 per ounce', n.quoteHash = 'sha256:74c63208a1719547f3d57170b8291d4a7f1305766509af4d6c80f34ebfe7fe62', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o2-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o3-roles'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o3-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from ZK-INC Sold by ZK-INC', n.quoteHash = 'sha256:30470ddc40f6555c038701398305144ff5321570b2235416da431f67985b7f35', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o3-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o3-price'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o3-price', n.selectorKind = 'TEXT_QUOTE', n.exact = '$149.00 $1.86 per ounce', n.quoteHash = 'sha256:8c18241831423184926fd8abc8c8708a040ed5da373b9426924d09cad2c198f7', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o3-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o4-roles'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o4-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from Amazon.com Sold by BE REBELLION USA', n.quoteHash = 'sha256:e81c29e728b8f08c619bc0168594f86e0d2f3d58621023fd9700f15f5e19aa22', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o4-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b000qsnygi-o4-price'})
ON CREATE SET n.id = 'amazon-b000qsnygi-o4-price', n.selectorKind = 'TEXT_QUOTE', n.exact = '$155.00 $1.94 per ounce', n.quoteHash = 'sha256:5e26e935a96ce462f115eea0c2aa3aa40f63d19f63448ddf477c0769c341e3ca', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b000qsnygi-aod-2026-10-04t0122'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o4-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:amazon-us-b000qsnygi'})
ON CREATE SET n.id = 'amazon-us-b000qsnygi', n.merchantListingId = 'B000QSNYGI', n.marketplace = 'amazon.com', n.commercePlatform = 'AMAZON', n.marketplaceRegion = 'US', n.title = 'Optimum Nutrition Gold Standard Whey Protein, Double Rich Chocolate, 5 LB', n.canonicalUrl = 'https://www.amazon.com/dp/B000QSNYGI', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'amazon-hosts-listing-b000qsnygi-2026-10-04', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:6dd7bf96d290e4b413f905ccdd2b55125cc9dc347fbf44868da78fece1687660', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-hosts-listing-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'amazon-hosts-listing-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-hosts-listing-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:amazon-hosts-listing-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-hosts-listing-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb'})
ON CREATE SET n.id = 'amazon-b000qsnygi-listing-for-on-5lb', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e57e009aa466615bf29d4dd798f23f2bcef7ec945aa6484d50c01bfb2b3c548c', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb'}), (b:PackageConfiguration {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-b000qsnygi-listing-for-on-5lb-cf'})
ON CREATE SET n.id = 'amazon-b000qsnygi-listing-for-on-5lb-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-b000qsnygi-listing-for-on-5lb-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}), (b:PackageConfiguration {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:amazon-b000qsnygi-listing-for-on-5lb'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-b000qsnygi-listing-for-on-5lb', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:amazon-b000qsnygi-to-on-5lb'})
ON CREATE SET n.id = 'amazon-b000qsnygi-to-on-5lb', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'SAME_ITEM', n.score = 0.85, n.rationale = 'Brand, line, flavor and net weight in the title match the package; GTIN not captured.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b000qsnygi-to-on-5lb'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b000qsnygi-to-on-5lb'}), (b:PackageConfiguration {uid: 'hu:package-configuration:on-gsw-double-rich-chocolate-5lb'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b000qsnygi-to-on-5lb'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
ON CREATE SET n.id = 'amazon-us-b000qsnygi-amazon-retail', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.sellerOfferRef = 'AMAZON_RETAIL|NEW', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.payloadHash = 'sha256:12146d78bc24410790354038ec2f7b928ca7c0befa2a3063b809a87eb9626b83', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'amazon-retail-seller-of-record-b000qsnygi-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:9a34221b6dc1349e5caa4a1e70592c5366405cc59cfd3faa99c84ca8c7967116', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-retail-seller-of-record-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'amazon-retail-seller-of-record-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-retail-seller-of-record-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:09f2afc2360ecc13c35d2153085ff8cb9f994ee67aed6087ee74b420d7e0acdd', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o1-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-retail-offer-fulfilled-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b000qsnygi-amazon-retail-2026-10-04t0122-one-time'})
ON CREATE SET n.id = 'amazon-b000qsnygi-amazon-retail-2026-10-04t0122-one-time', n.amount = 102.81, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.startedAt = datetime('2026-10-04T01:22:25Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:amazon-b000qsnygi-o1-price', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$102.81 with 11 percent savings', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b000qsnygi-amazon-retail-2026-10-04t0122-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
ON CREATE SET n.id = 'amazon-us-b000qsnygi-my-nutrition-depot', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.sellerOfferRef = 'A2TXQHZ1OKWQ2N|NEW', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.payloadHash = 'sha256:a2edc9e621f5eb089ecc31dbbaa71f72e86ebf91a8814309a9ff0064d68c6d75', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:63b7e3dc874e61bf369a7d61607405d4377f7e77cafbf5ccb96b265eb91ca404', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-my-nutrition-depot'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o2-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-my-nutrition-depot'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:my-nutrition-depot-seller-of-record-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:f73044fc1af128b185d1dd4d71e5a90c7bfacb9e4b2afdcb3b29cff2f018cae2', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-my-nutrition-depot'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o2-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-my-nutrition-depot'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:my-nutrition-depot-offer-fulfilled-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b000qsnygi-my-nutrition-depot-2026-10-04t0122-one-time'})
ON CREATE SET n.id = 'amazon-b000qsnygi-my-nutrition-depot-2026-10-04t0122-one-time', n.amount = 109.99, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.startedAt = datetime('2026-10-04T01:22:25Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:amazon-b000qsnygi-o2-price', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$109.99', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-my-nutrition-depot'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b000qsnygi-my-nutrition-depot-2026-10-04t0122-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
ON CREATE SET n.id = 'amazon-us-b000qsnygi-zk-inc', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.sellerOfferRef = 'A2BHMA3GTYX2GC|NEW', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.payloadHash = 'sha256:b7e5f6b8eb237a1e367116cc906565c71aca0c0b6551b99db0895e1e7e3d4f4f', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'zk-inc-seller-of-record-b000qsnygi-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:8fb1f86d8a4f13ff55e0bd8909469c7f239ce965c613a00f2fcd54ae0ef8fbec', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-zk-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o3-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:zk-inc-seller-of-record-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'zk-inc-seller-of-record-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:zk-inc-seller-of-record-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-zk-inc'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:zk-inc-seller-of-record-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:zk-inc-seller-of-record-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'zk-inc-offer-fulfilled-b000qsnygi-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:ae12fe48c5aa917bf458a406a09b9916d25500e64f3a787deaf7a21752440dbf', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-zk-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o3-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'zk-inc-offer-fulfilled-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-zk-inc'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:zk-inc-offer-fulfilled-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b000qsnygi-zk-inc-2026-10-04t0122-one-time'})
ON CREATE SET n.id = 'amazon-b000qsnygi-zk-inc-2026-10-04t0122-one-time', n.amount = 149.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.startedAt = datetime('2026-10-04T01:22:25Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:amazon-b000qsnygi-o3-price', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$149.00', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b000qsnygi-zk-inc-2026-10-04t0122-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
ON CREATE SET n.id = 'amazon-us-b000qsnygi-be-rebellion-usa', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.sellerOfferRef = 'A3Q3QEX08918FS|NEW', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.payloadHash = 'sha256:692ff1c5ed0b77973628b54b31996782eee19ef20e3633a70402a13074a26e4e', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:64c9f46b3b4dd827c18fa66dfa7bc40a717e051cfeb717631500d02989153344', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-be-rebellion-usa'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o4-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-be-rebellion-usa'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:be-rebellion-usa-seller-of-record-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'})
ON CREATE SET n.id = 'be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:f5aa15b39a30e02cb04ba027537447308af17ef11c008c423bcda3a53fa31f34', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b000qsnygi-o4-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04-cf'})
ON CREATE SET n.id = 'be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:be-rebellion-usa-offer-fulfilled-b000qsnygi-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b000qsnygi-be-rebellion-usa-2026-10-04t0122-one-time'})
ON CREATE SET n.id = 'amazon-b000qsnygi-be-rebellion-usa-2026-10-04t0122-one-time', n.amount = 155.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.startedAt = datetime('2026-10-04T01:22:25Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:amazon-b000qsnygi-o4-price', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$155.00', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-be-rebellion-usa'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b000qsnygi-be-rebellion-usa-2026-10-04t0122-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b000qsnygi-amazon-retail-2026-10-04t0122-list'})
ON CREATE SET n.id = 'amazon-b000qsnygi-amazon-retail-2026-10-04t0122-list', n.amount = 114.99, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:22:25Z'), n.startedAt = datetime('2026-10-04T01:22:25Z'), n.priceKind = 'LIST', n.sourceLocatorUid = 'hu:locator:amazon-b000qsnygi-o1-list', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = 'List Price: $114.99', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-amazon-retail'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b000qsnygi-amazon-retail-2026-10-04t0122-list'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// Amazon SELLS_PRODUCT from its own retail SELLER_OF_RECORD_FOR assertion only (not from hosting, not from fulfilling BE REBELLION).
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:ProductVariant {uid: 'hu:product-variant:on-gsw-double-rich-chocolate-us'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-sells-product-from-seller-of-record/v1', r.derivedFromAssertionUids = ['hu:assertion:amazon-retail-seller-of-record-b000qsnygi-2026-10-04'], r.derivedFromAssessmentUids = ['hu:commerce-match:amazon-b000qsnygi-to-on-5lb'], r.derivedAt = datetime('2026-10-04T02:05:00Z');
