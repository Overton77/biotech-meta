// W15 fixture 01 -- Amazon B0FS82B35K: marketplace host, seller of record and fulfiller are separate roles (CQ-CM-01, CQ-CM-03).
// PUBLIC record, NEW_RETRIEVAL 2026-10-04T01:19:18Z (Firecrawl scrape, buy-box tags only: PARTIAL_EXCERPT; hash SYNTHETIC_FIXTURE).
// The page states: "Ships from: Amazon  Sold by: TRU NIAGEN"; merchant link seller=A1W0QC6JE0QLDF ... isAmazonFulfilled=1;
// "One-Time Price: $49.00"; "$44.10 with 10 percent savings"; "$41.65 with 15 percent savings"; "$1.63 per count"; "In Stock".
// Host = Amazon, fulfiller = Amazon (same party, two roles), seller of record = the TRU NIAGEN seller account (legal entity unresolved).
// SELLS_PRODUCT is derived for the seller account ONLY, from its SELLER_OF_RECORD_FOR assertion (V-326a/b/c pass). Amazon gets no
// SELLS_PRODUCT here (the must-fail twin is in w15-07-negatives-must-fail.cypher).
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:amazon-b0fs82b35k'})
ON CREATE SET n.id = 'amazon-b0fs82b35k', n.canonicalUri = 'https://www.amazon.com/dp/B0FS82B35K', n.title = 'Amazon detail page B0FS82B35K', n.sourceKind = 'MARKETPLACE_LISTING', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-2026-10-04t0119', n.retrievedAt = datetime('2026-10-04T01:19:18Z'), n.observedAt = datetime('2026-10-04T01:19:18Z'), n.contentHash = 'sha256:a42f4f6e8c71faf64e54f16467740f8679163e7437a8d56e7188bdbc9d489b94', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:amazon-b0fs82b35k'}), (b:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-ships-sold'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-ships-sold', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Ships from: Amazon Sold by: TRU NIAGEN', n.quoteHash = 'sha256:216066923dcb61a1d788095079346f4c138c77e306d8dc79a4eeed7a0ff32717', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-ships-sold'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-merchant-link', n.selectorKind = 'TEXT_QUOTE', n.exact = 'seller=A1W0QC6JE0QLDF&asin=B0FS82B35K&ref_=dp_merchant_link&isAmazonFulfilled=1', n.quoteHash = 'sha256:7f22be23122f919fecbd528c9dc7f324da3d8e8bf8df3b7b4a641247fe44b94b', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-one-time'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-one-time', n.selectorKind = 'TEXT_QUOTE', n.exact = 'One-Time Price: $49.00', n.quoteHash = 'sha256:344dca40d85c3b81065144cce2257a201f6e992276850b1f369f022c57640385', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-one-time'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-per-count'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-per-count', n.selectorKind = 'TEXT_QUOTE', n.exact = '$49.00 $1.63 per count', n.quoteHash = 'sha256:df5edeab8eff908fb920104ee702ca8d2407160f186fbac39d5959fe19b6f523', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-per-count'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-10'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-10', n.selectorKind = 'TEXT_QUOTE', n.exact = '$44.10 with 10 percent savings', n.quoteHash = 'sha256:c051d4e6357b297861f24d9588977001c0daaaf565364bb7874ae9dad6a3e5e8', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-10'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-15'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-15', n.selectorKind = 'TEXT_QUOTE', n.exact = '$41.65 with 15 percent savings', n.quoteHash = 'sha256:e30a515ff363e35bfc5ba40bb44fcfedadee41d0e95ee551ae998f85ab44acfa', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-15'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-terms'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-terms', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Save 10% now and up to 15% on repeat deliveries.', n.quoteHash = 'sha256:f4ea24a48c1285ae2ba38aa377fca028bf1cd62524b173ed6340c361952e42ab', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-terms'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-15-rule'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-15-rule', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Save 15% when you receive 5 or more products in one auto-delivery to one address. Currently, you\'ll save 10% on your Nov 5 delivery.', n.quoteHash = 'sha256:8cb7af403cbfb5b688b09276172c530ec270824c5991c10d34a5afdf83d6b500', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-15-rule'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-frequency'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-frequency', n.selectorKind = 'TEXT_QUOTE', n.exact = 'From once every 2 weeks to once every 6 months', n.quoteHash = 'sha256:8160bafc0dc53aeb5cd34b0450634db7218399e2bf3380e10fd187c8054b685b', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-frequency'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-sns-no-fees'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-sns-no-fees', n.selectorKind = 'TEXT_QUOTE', n.exact = 'No fees. Skip or cancel anytime.', n.quoteHash = 'sha256:e3104b86a3208552d6f3b0e99e07e07564614d14ea4fb997dc3e867e62c30e89', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-no-fees'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-coupon'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-coupon', n.selectorKind = 'TEXT_QUOTE', n.exact = '10% off coupon applied. First Subscribe & Save orders only.', n.quoteHash = 'sha256:e74dcb5b77a0f33ea0a915f0bdedd3d9d35ab9afc6435379ec74e41f7cf825bd', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-coupon'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-returns'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-returns', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Non-returnable due to Food safety reasons', n.quoteHash = 'sha256:9f21e4b558cf51882788feacea76794a5a64a98c2429eb5322db262d1cccf772', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-returns'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-in-stock'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-in-stock', n.selectorKind = 'TEXT_QUOTE', n.exact = 'In Stock', n.quoteHash = 'sha256:64254d0b795cfb28f3813fd8409e1a6cbafb5601c2f3b2253416e323e6d8e873', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-in-stock'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-title'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-title', n.selectorKind = 'TEXT_QUOTE', n.exact = 'TRU NIAGEN Beauty NAD+ Supplement, Hair, Skin & Nails, Biotin, 30-Count', n.quoteHash = 'sha256:03df55930c3facd2d55e1f70ff8d6902e1f9e92128460ebb4230d1abcfcdd86c', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-title'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:amazon-b0fs82b35k-delivery-context'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-delivery-context', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Delivering to Fairfax 22030', n.quoteHash = 'sha256:631d1b045b05938f7b1031e0c1d0762de3d4c6e251383ee60072e7c46a97040c', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b0fs82b35k-2026-10-04t0119'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-delivery-context'})
MERGE (a)-[r:HAS_LOCATOR]->(b);

MERGE (n:MerchantListing:Entity {uid: 'hu:listing:amazon-us-b0fs82b35k'})
ON CREATE SET n.id = 'amazon-us-b0fs82b35k', n.merchantListingId = 'B0FS82B35K', n.marketplace = 'amazon.com', n.commercePlatform = 'AMAZON', n.marketplaceRegion = 'US', n.title = 'TRU NIAGEN Beauty NAD+ Supplement, Hair, Skin & Nails, Biotin, 30-Count', n.canonicalUrl = 'https://www.amazon.com/dp/B0FS82B35K', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:asin-b0fs82b35k'})
ON CREATE SET n.id = 'asin-b0fs82b35k', n.scheme = 'ASIN', n.issuer = 'Amazon', n.value = 'B0FS82B35K', n.jurisdiction = 'US', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-identified-by-asin'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-identified-by-asin', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:ea36879ac5908035be2880c380b00da31fd7a412718bb4ae1cb7859f4a56c356', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-identified-by-asin'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-identified-by-asin'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:asin-b0fs82b35k'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-identified-by-asin'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-b0fs82b35k-identified-by-asin-cf'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-identified-by-asin-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-b0fs82b35k-identified-by-asin-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-identified-by-asin'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:asin-b0fs82b35k'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:amazon-b0fs82b35k-identified-by-asin'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-b0fs82b35k-identified-by-asin', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:Offer:VersionedState {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
ON CREATE SET n.id = 'amazon-us-b0fs82b35k-tru-niagen-new', n.offerKind = 'PURCHASE', n.currency = 'USD', n.termsText = 'Non-returnable due to Food safety reasons', n.sellerOfferRef = 'A1W0QC6JE0QLDF|NEW', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.payloadHash = 'sha256:00a9d2c79181684c50d35b3a4027a74f95b8dbae0dba72f02c178ee3b989f9c4', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:HAS_OFFER]->(b);
// Roles. Every role is its own asserted edge; validFrom null with basis OBSERVATION_ONLY (observed, start unknown), validTo null UNKNOWN.
MERGE (n:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'})
ON CREATE SET n.id = 'amazon-hosts-listing-b0fs82b35k-2026-10-04', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:2fec7ce7bb75e11b69ddba78573081d5552958c07e621000827ed44036282543', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-ships-sold'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-hosts-listing-b0fs82b35k-2026-10-04-cf'})
ON CREATE SET n.id = 'amazon-hosts-listing-b0fs82b35k-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-hosts-listing-b0fs82b35k-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:amazon-hosts-listing-b0fs82b35k-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'})
ON CREATE SET n.id = 'amazon-fulfills-offer-b0fs82b35k-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:35e101c1cc30c8088b140c95442858b4937af5b8f46141241f94ddae60dec886', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'}), (b:Organization {uid: 'hu:org:amazon-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-ships-sold'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-fulfills-offer-b0fs82b35k-2026-10-04-cf'})
ON CREATE SET n.id = 'amazon-fulfills-offer-b0fs82b35k-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-fulfills-offer-b0fs82b35k-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:amazon-fulfills-offer-b0fs82b35k-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'})
ON CREATE SET n.id = 'tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e0a69ee3fa753437b43bdbee955844749e6f790637cb88372600afc12bc7449f', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-ships-sold'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04-cf'})
ON CREATE SET n.id = 'tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
// Seller account merchant id (HAS_IDENTIFIER episode) and the unresolved legal entity (ResolutionHypothesis, not an edge).
MERGE (n:Assertion {uid: 'hu:assertion:tru-niagen-account-has-merchant-id'})
ON CREATE SET n.id = 'tru-niagen-account-has-merchant-id', n.predicate = 'HAS_IDENTIFIER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:a3644f6597b4ec8263a0ff5f5901c14665beda46ed8b4adf8fca8f38dcfad3bf', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-has-merchant-id'}), (b:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-has-merchant-id'}), (b:Identifier {uid: 'hu:identifier:amazon-merchant-a1w0qc6je0qldf'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:tru-niagen-account-has-merchant-id'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-merchant-link'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:tru-niagen-account-has-merchant-id-cf'})
ON CREATE SET n.id = 'tru-niagen-account-has-merchant-id-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:tru-niagen-account-has-merchant-id-cf'}), (b:Assertion {uid: 'hu:assertion:tru-niagen-account-has-merchant-id'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'}), (b:Identifier {uid: 'hu:identifier:amazon-merchant-a1w0qc6je0qldf'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:tru-niagen-account-has-merchant-id'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:tru-niagen-account-has-merchant-id', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex'})
ON CREATE SET n.id = 'amazon-a1w0qc6je0qldf-operated-by-chromadex', n.assessmentType = 'ResolutionHypothesis', n.methodVersion = 'w15-seller-account-resolution/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.resolutionType = 'SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', n.score = 0.6, n.resolutionStatus = 'UNRESOLVED', n.rationale = 'Display name equals the brand; Amazon seller profile (business name, address) not captured. A display name is not a legal entity.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex'}), (b:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:amazon-a1w0qc6je0qldf-operated-by-chromadex'}), (b:Organization {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
// Listing identity: LISTING_FOR to the Beauty variant (merchant title, 30-Count) plus an ACCEPTED CommerceMatch SAME_ITEM.
MERGE (n:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-listing-for-beauty-variant', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:5535951ca02b580c49a31eefded0e78403230b098c1dce5162996d06c193f747', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-b0fs82b35k-listing-for-beauty-variant-cf'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-listing-for-beauty-variant-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-b0fs82b35k-listing-for-beauty-variant-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:amazon-b0fs82b35k-listing-for-beauty-variant'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-b0fs82b35k-listing-for-beauty-variant', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-to-tru-niagen-beauty', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'SAME_ITEM', n.score = 0.9, n.rationale = 'Brand seller account sells under the brand name; title names Tru Niagen Beauty, 30-Count. No GTIN captured on this page: package-level identity not asserted.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'}), (b:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'}), (b:Activity {uid: 'hu:activity:w15-commerce-match-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
// Subscription plan (Amazon Subscribe & Save) as displayed; the plan is not a price.
MERGE (n:SubscriptionPlan:VersionedState {uid: 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04'})
ON CREATE SET n.id = 'amazon-subscribe-and-save-b0fs82b35k-2026-10-04', n.planGroupName = 'Subscribe & Save', n.planName = 'Subscribe & Save', n.planProvider = 'AMAZON_SUBSCRIBE_AND_SAVE', n.intervalOptionsText = 'From once every 2 weeks to once every 6 months', n.termsText = 'No fees. Skip or cancel anytime.', n.minimumCommitmentStatus = 'NOT_REPORTED', n.payloadHash = 'sha256:e1ad5a84c552bf4e7959b7814d2dd745091eaeb065ff16f9e98bee8e6bf1fcf5', n.stateType = 'SubscriptionPlan', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-offer-uses-sns', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:1a19120c6518ca37806c7eb101944f2c1d90556154ad7fe9b7622393103d2cb1', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'}), (b:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-terms'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-frequency'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'}), (b:SourceLocator {uid: 'hu:locator:amazon-b0fs82b35k-sns-no-fees'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:amazon-b0fs82b35k-offer-uses-sns-cf'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-offer-uses-sns-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:amazon-b0fs82b35k-offer-uses-sns-cf'}), (b:Assertion {uid: 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:amazon-b0fs82b35k-offer-uses-sns'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:amazon-b0fs82b35k-offer-uses-sns', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
// Prices: one observation per displayed price and kind; never averaged. $41.65 is the 15% Subscribe & Save tier on this capture;
// round 0005 recorded "$41.65 with coupon" from a brand-store search snippet (COUPON_ADJUSTED) -- see fixture 04 / queries Q-W15-03.
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-one-time'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-2026-10-04t0119-one-time', n.amount = 49.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.startedAt = datetime('2026-10-04T01:19:18Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:amazon-b0fs82b35k-one-time', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = 'One-Time Price: $49.00', n.observationRegion = 'US-VA', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-one-time'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-per-count'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-2026-10-04t0119-per-count', n.amount = 1.63, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.startedAt = datetime('2026-10-04T01:19:18Z'), n.priceKind = 'PER_UNIT', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:amazon-b0fs82b35k-per-count', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$1.63 per count', n.observationRegion = 'US-VA', n.unitQuantity = 1.0, n.unitCode = '{count}', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-per-count'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-sns-10'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-2026-10-04t0119-sns-10', n.amount = 44.1, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.startedAt = datetime('2026-10-04T01:19:18Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:amazon-b0fs82b35k-sns-10', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$44.10 with 10 percent savings', n.conditionText = 'Save 10% now and up to 15% on repeat deliveries.', n.observationRegion = 'US-VA', n.subscriptionPlanUid = 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-sns-10'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-sns-15'})
ON CREATE SET n.id = 'amazon-b0fs82b35k-2026-10-04t0119-sns-15', n.amount = 41.65, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.startedAt = datetime('2026-10-04T01:19:18Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:amazon-b0fs82b35k-sns-15', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = '$41.65 with 15 percent savings', n.conditionText = 'Save 15% when you receive 5 or more products in one auto-delivery to one address.', n.observationRegion = 'US-VA', n.subscriptionPlanUid = 'hu:subscription-plan:amazon-subscribe-and-save-b0fs82b35k-2026-10-04', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-sns-15'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// The coupon ("10% off coupon applied. First Subscribe & Save orders only.") shows no resulting amount: NO COUPON_ADJUSTED observation is invented.
// Derived SELLS_PRODUCT: seller account -> Beauty variant, from the SELLER_OF_RECORD_FOR assertion only; the identity licence is the CommerceMatch.
MATCH (a:Organization {uid: 'hu:org:seller-account-amazon-tru-niagen'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-sells-product-from-seller-of-record/v1', r.derivedFromAssertionUids = ['hu:assertion:tru-niagen-account-seller-of-record-b0fs82b35k-2026-10-04'], r.derivedFromAssessmentUids = ['hu:commerce-match:amazon-b0fs82b35k-to-tru-niagen-beauty'], r.derivedAt = datetime('2026-10-04T02:05:00Z');
// Projections (read-only, projection service): latest ONE_TIME observation; answers cite lastObservedAt.
MATCH (ml:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'}) SET ml.priceAmount = 49.0, ml.currency = 'USD', ml.availabilityStatus = 'IN_STOCK', ml.priceKindProjected = 'ONE_TIME', ml.lastObservedAt = datetime('2026-10-04T01:19:18Z'), ml.capturedAt = datetime('2026-10-04T01:19:18Z'), ml.currentAsOf = datetime('2026-10-04T02:05:00Z'), ml.projectedFromPriceObservationUid = 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-one-time';
MATCH (o:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}) SET o.availabilityStatus = 'IN_STOCK', o.firstObservedAt = datetime('2026-10-04T01:19:18Z'), o.lastObservedAt = datetime('2026-10-04T01:19:18Z'), o.projectedFromPriceObservationUid = 'hu:price-obs:amazon-b0fs82b35k-2026-10-04t0119-one-time';
