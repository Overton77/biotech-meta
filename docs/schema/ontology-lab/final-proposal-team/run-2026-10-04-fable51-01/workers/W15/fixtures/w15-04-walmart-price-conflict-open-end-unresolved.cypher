// W15 fixture 04 -- Walmart item 1038593372: two disagreeing captures, open end, late arrival, unresolved identity (CQ-CM-02/03/05, CQ-AX-06).
// PUBLIC record, NEW_RETRIEVAL 2026-10-04. Capture A 01:20:44Z (Firecrawl LLM directQuote): "current price $19.90", "Sold by Sports-Med",
// "Fulfilled by Walmart". Capture B 01:21:32Z (rendered HTML, sha256 3ea4967d... RAW_BYTES of the capture as returned): __NEXT_DATA__
// product.priceInfo.currentPrice.price 45, availabilityStatus IN_STOCK, sellerDisplayName "Sports-Med", sellerName "BLUE PEAK DISTRIBUTOR INC",
// sellerId E4E44D0D801E45C8A50F187A7AB1A8B0, offerId 6B703781AD47343680CA645C778BE7D6, wfsEnabled true, upc "850015311116", delivery context
// Silver Spring MD 20904, transactableOfferCount 1. The two prices are two observations with different capture methods; neither is averaged
// or discarded. The displayed UPC differs from the brand's current 30-count GTIN 850015311857: NO LISTING_FOR; an UNRESOLVED CommerceMatch.
// SYNTHETIC late arrival: an archive capture of the same page (observedAt 2026-10-02, retrieved 2026-10-12) adds a price recorded on 2026-10-12.
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:walmart-ip-1038593372'})
ON CREATE SET n.id = 'walmart-ip-1038593372', n.canonicalUri = 'https://www.walmart.com/ip/Tru-Niagen-Nicotinamide-Riboside-300-mg-30-Vegetarian-Capsules/1038593372', n.title = 'Walmart item 1038593372', n.sourceKind = 'MARKETPLACE_LISTING', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'})
ON CREATE SET n.id = 'walmart-1038593372-2026-10-04t0120-query', n.retrievedAt = datetime('2026-10-04T01:20:44Z'), n.observedAt = datetime('2026-10-04T01:20:44Z'), n.contentHash = 'sha256:6fd99c331e7b4da568cbcdf6495495fc76696802b14adf0b77e2539ab3649d6c', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:walmart-ip-1038593372'}), (b:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'})
ON CREATE SET n.id = 'walmart-1038593372-2026-10-04t0121-raw', n.retrievedAt = datetime('2026-10-04T01:21:32Z'), n.observedAt = datetime('2026-10-04T01:21:32Z'), n.contentHash = 'sha256:3ea4967d42c1e9bf696a7c2af6ac2e82dc9c937eb29cff12503b6a8e720e3e66', n.contentHashBasis = 'RAW_BYTES', n.captureCompleteness = 'COMPLETE', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:walmart-ip-1038593372'}), (b:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-a-price'})
ON CREATE SET n.id = 'walmart-1038593372-a-price', n.selectorKind = 'TEXT_QUOTE', n.exact = 'current price $19.90', n.quoteHash = 'sha256:c26486e7670fedde6a6f6b07b61e1fe0026e01078cd6636dc33589feafcafde4', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-a-roles'})
ON CREATE SET n.id = 'walmart-1038593372-a-roles', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Sold by Sports-Med Fulfilled by Walmart', n.quoteHash = 'sha256:59c0d28d89301f8ccc0be54b84778b89a2e852eba3711d4d63005821a5398119', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-roles'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-a-title'})
ON CREATE SET n.id = 'walmart-1038593372-a-title', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Tru Niagen Nicotinamide Riboside Chloride 300 mg 30 Vegetarian Capsules for Cellular Health', n.quoteHash = 'sha256:69589b72965627557a982f12a620a785cc4d11b80e1689113dc0e46c4205fe3c', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0120-query'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-title'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-b-price'})
ON CREATE SET n.id = 'walmart-1038593372-b-price', n.selectorKind = 'SECTION', n.section = '__NEXT_DATA__ props.pageProps.initialData.data.product.priceInfo.currentPrice', n.normalizationVersion = 'NFC-WS1', n.exact = 'price 45 priceString $45.00 currencyUnit USD', n.quoteHash = 'sha256:0610c814f6b72c8c052bea0ff135383c51e3b8a6d622441848f313cb3b808fd7', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-b-seller'})
ON CREATE SET n.id = 'walmart-1038593372-b-seller', n.selectorKind = 'SECTION', n.section = '__NEXT_DATA__ props.pageProps.initialData.data.product (seller fields)', n.normalizationVersion = 'NFC-WS1', n.exact = 'sellerId E4E44D0D801E45C8A50F187A7AB1A8B0 sellerName BLUE PEAK DISTRIBUTOR INC sellerDisplayName Sports-Med sellerType EXTERNAL wfsEnabled true catalogSellerId 2924', n.quoteHash = 'sha256:e10e137daf579ec4a62c5bfcbb9fe3ac701577de80f4dcc239a6a363402cd811', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-b-upc'})
ON CREATE SET n.id = 'walmart-1038593372-b-upc', n.selectorKind = 'SECTION', n.section = '__NEXT_DATA__ props.pageProps.initialData.data.product.upc', n.normalizationVersion = 'NFC-WS1', n.exact = 'upc 850015311116', n.quoteHash = 'sha256:d5098730d8137ab880e8330b81fecb702d7f691b412940cabc71290f1216261a', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-upc'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-b-availability'})
ON CREATE SET n.id = 'walmart-1038593372-b-availability', n.selectorKind = 'SECTION', n.section = '__NEXT_DATA__ props.pageProps.initialData.data.product.availabilityStatus', n.normalizationVersion = 'NFC-WS1', n.exact = 'availabilityStatus IN_STOCK', n.quoteHash = 'sha256:01823952ddd9965f7ed257cba6554ac3e29ef714b211e407cdaa657c9b2c34e6', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-availability'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-b-title'})
ON CREATE SET n.id = 'walmart-1038593372-b-title', n.selectorKind = 'SECTION', n.section = '__NEXT_DATA__ props.pageProps.initialData.data.product.name', n.normalizationVersion = 'NFC-WS1', n.exact = 'Tru Niagen Nicotinamide Riboside Chloride, 300 mg, 30 Vegetarian Capsules', n.quoteHash = 'sha256:2c764d9c7e8c8b6d6b2e3208927f2d712beda0c2bd0bde823a32a4e6de45859b', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:walmart-1038593372-2026-10-04t0121-raw'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-title'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:walmart-us-1038593372'})
ON CREATE SET n.id = 'walmart-us-1038593372', n.merchantListingId = '1038593372', n.marketplace = 'walmart.com', n.commercePlatform = 'WALMART_MARKETPLACE', n.marketplaceRegion = 'US', n.title = 'Tru Niagen Nicotinamide Riboside Chloride, 300 mg, 30 Vegetarian Capsules', n.canonicalUrl = 'https://www.walmart.com/ip/Tru-Niagen-Nicotinamide-Riboside-300-mg-30-Vegetarian-Capsules/1038593372', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:walmart-item-1038593372'})
ON CREATE SET n.id = 'walmart-item-1038593372', n.scheme = 'WALMART_ITEM_ID', n.issuer = 'Walmart', n.value = '1038593372', n.jurisdiction = 'US', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372'})
ON CREATE SET n.id = 'walmart-1038593372-identified-by-walmart-item-1038593372', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:250ff0433e77ec83102f2c62197a28c690c3c6ea90ad2590d4357af275cafb4a', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:walmart-item-1038593372'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:walmart-1038593372-identified-by-walmart-item-1038593372-cf'})
ON CREATE SET n.id = 'walmart-1038593372-identified-by-walmart-item-1038593372-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:walmart-1038593372-identified-by-walmart-item-1038593372-cf'}), (b:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:walmart-item-1038593372'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:walmart-1038593372-identified-by-walmart-item-1038593372'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:walmart-1038593372-identified-by-walmart-item-1038593372', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:walmart-displayed-upc-850015311116'})
ON CREATE SET n.id = 'walmart-displayed-upc-850015311116', n.scheme = 'UPC_AS_DISPLAYED_BY_WALMART', n.issuer = 'Walmart', n.value = '850015311116', n.jurisdiction = 'US', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'})
ON CREATE SET n.id = 'walmart-1038593372-identified-by-walmart-displayed-upc-850015311116', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:114a1540224138127a6fdc5be3ac2df18d95793d16f43d00d12a2ca1f75ef971', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:walmart-displayed-upc-850015311116'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-upc'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116-cf'})
ON CREATE SET n.id = 'walmart-1038593372-identified-by-walmart-displayed-upc-850015311116-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116-cf'}), (b:Assertion {uid: 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:walmart-displayed-upc-850015311116'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:walmart-1038593372-identified-by-walmart-displayed-upc-850015311116', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
ON CREATE SET n.id = 'walmart-us-1038593372-sports-med', n.offerKind = 'PURCHASE', n.currency = 'USD', n.itemCondition = 'NEW', n.sellerOfferRef = '6B703781AD47343680CA645C778BE7D6', n.observedAt = datetime('2026-10-04T01:20:44Z'), n.payloadHash = 'sha256:e3d57ee9640879adb61d2c494bd6c2e881831f22cf8c574f658de63b7bb230b0', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'})
ON CREATE SET n.id = 'walmart-hosts-listing-1038593372-2026-10-04', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:38b7ea9dbd0738d71fcc6bc1c31bac3b6c6f5aa0d1b6467749e00cde0ac0bd70', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'}), (b:Organization {uid: 'hu:org:walmart-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:walmart-hosts-listing-1038593372-2026-10-04-cf'})
ON CREATE SET n.id = 'walmart-hosts-listing-1038593372-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:walmart-hosts-listing-1038593372-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:walmart-marketplace-us'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:walmart-hosts-listing-1038593372-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:walmart-hosts-listing-1038593372-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'})
ON CREATE SET n.id = 'sports-med-seller-of-record-1038593372-2026-10-04', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:d20f8f5dd168c0487426c33e845d9225fb808c809cfde6f137cb345d75428569', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'}), (b:Organization {uid: 'hu:org:seller-account-walmart-sports-med'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:sports-med-seller-of-record-1038593372-2026-10-04-cf'})
ON CREATE SET n.id = 'sports-med-seller-of-record-1038593372-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:sports-med-seller-of-record-1038593372-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-walmart-sports-med'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:sports-med-seller-of-record-1038593372-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:walmart-fulfills-1038593372-2026-10-04'})
ON CREATE SET n.id = 'walmart-fulfills-1038593372-2026-10-04', n.predicate = 'FULFILLS_OFFER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:01a89c0a956e362399066bd46f5f51fc48c1bdbf087bddf9a083dab056ed6247', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:walmart-fulfills-1038593372-2026-10-04'}), (b:Organization {uid: 'hu:org:walmart-marketplace-us'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-fulfills-1038593372-2026-10-04'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:walmart-fulfills-1038593372-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-a-roles'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:walmart-fulfills-1038593372-2026-10-04-cf'})
ON CREATE SET n.id = 'walmart-fulfills-1038593372-2026-10-04-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:walmart-fulfills-1038593372-2026-10-04-cf'}), (b:Assertion {uid: 'hu:assertion:walmart-fulfills-1038593372-2026-10-04'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:walmart-marketplace-us'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:FULFILLS_OFFER {relationshipUid: 'hu:rel:walmart-fulfills-1038593372-2026-10-04'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:walmart-fulfills-1038593372-2026-10-04', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:sports-med-has-walmart-seller-id'})
ON CREATE SET n.id = 'sports-med-has-walmart-seller-id', n.predicate = 'HAS_IDENTIFIER', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:025f88daf0df62c90aa18018aa8f712065ffab299061f79d80346545dd79bfd4', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-has-walmart-seller-id'}), (b:Organization {uid: 'hu:org:seller-account-walmart-sports-med'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-has-walmart-seller-id'}), (b:Identifier {uid: 'hu:identifier:walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:sports-med-has-walmart-seller-id'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:sports-med-has-walmart-seller-id-cf'})
ON CREATE SET n.id = 'sports-med-has-walmart-seller-id-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:sports-med-has-walmart-seller-id-cf'}), (b:Assertion {uid: 'hu:assertion:sports-med-has-walmart-seller-id'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:seller-account-walmart-sports-med'}), (b:Identifier {uid: 'hu:identifier:walmart-seller-e4e44d0d801e45c8a50f187a7ab1a8b0'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:sports-med-has-walmart-seller-id'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:sports-med-has-walmart-seller-id', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:walmart-sports-med-is-blue-peak-distributor'})
ON CREATE SET n.id = 'walmart-sports-med-is-blue-peak-distributor', n.assessmentType = 'ResolutionHypothesis', n.methodVersion = 'w15-seller-account-resolution/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.resolutionType = 'SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', n.score = 0.8, n.resolutionStatus = 'PROPOSED', n.rationale = 'Walmart page data pairs sellerDisplayName "Sports-Med" with sellerName "BLUE PEAK DISTRIBUTOR INC" under one sellerId; no registry record captured.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:walmart-sports-med-is-blue-peak-distributor'}), (b:Organization {uid: 'hu:org:seller-account-walmart-sports-med'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:walmart-sports-med-is-blue-peak-distributor'}), (b:Organization {uid: 'hu:org:blue-peak-distributor-inc'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:walmart-sports-med-is-blue-peak-distributor'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
// Two captures, two observations (never averaged). Capture A is an LLM direct quote; capture B is the page's structured data.
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:walmart-1038593372-2026-10-04t0120-one-time-query'})
ON CREATE SET n.id = 'walmart-1038593372-2026-10-04t0120-one-time-query', n.amount = 19.9, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:20:44Z'), n.startedAt = datetime('2026-10-04T01:20:44Z'), n.priceKind = 'ONE_TIME', n.sourceLocatorUid = 'hu:locator:walmart-1038593372-a-price', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = 'current price $19.90', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'}), (b:PriceObservation {uid: 'hu:price-obs:walmart-1038593372-2026-10-04t0120-one-time-query'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:walmart-1038593372-2026-10-04t0121-one-time-raw'})
ON CREATE SET n.id = 'walmart-1038593372-2026-10-04t0121-one-time-raw', n.amount = 45.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:21:32Z'), n.startedAt = datetime('2026-10-04T01:21:32Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:walmart-1038593372-b-price', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = '$45.00', n.observationRegion = 'US-MD', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'}), (b:PriceObservation {uid: 'hu:price-obs:walmart-1038593372-2026-10-04t0121-one-time-raw'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// SYNTHETIC late arrival: archive capture retrieved 2026-10-12 of the page as displayed on 2026-10-02; recorded 2026-10-12, valid-time 2026-10-02.
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w15-syn-walmart-1038593372-archive-2026-10-02'})
ON CREATE SET n.id = 'w15-syn-walmart-1038593372-archive-2026-10-02', n.retrievedAt = datetime('2026-10-12T09:00:00Z'), n.observedAt = datetime('2026-10-02T15:00:00Z'), n.contentHash = 'sha256:a83793b56a49ddd13d3123473f1081927beb409ebbcbc7b88677f0f0d22bb12c', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.archiveUri = 'https://web.archive.org/web/20261002150000/https://www.walmart.com/ip/1038593372 (SYNTHETIC)', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-12T09:00:00Z'), n.updatedAt = datetime('2026-10-12T09:00:00Z');
MATCH (a:Source {uid: 'hu:source:walmart-ip-1038593372'}), (b:SourceSnapshot {uid: 'hu:snapshot:w15-syn-walmart-1038593372-archive-2026-10-02'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w15-syn-walmart-1038593372-archive-2026-10-02'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:walmart-1038593372-c-price'})
ON CREATE SET n.id = 'walmart-1038593372-c-price', n.selectorKind = 'TEXT_QUOTE', n.exact = 'current price $44.00 (SYNTHETIC)', n.quoteHash = 'sha256:fd5600dd3e75653d6672ea520f8cba6fc94b5a2b4982fc7e92b39e57e980bfdc', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-12T09:00:00Z'), n.updatedAt = datetime('2026-10-12T09:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:w15-syn-walmart-1038593372-archive-2026-10-02'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-c-price'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:w15-syn-walmart-1038593372-2026-10-02-archive'})
ON CREATE SET n.id = 'w15-syn-walmart-1038593372-2026-10-02-archive', n.amount = 44.0, n.currency = 'USD', n.observedAt = datetime('2026-10-02T15:00:00Z'), n.startedAt = datetime('2026-10-02T15:00:00Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:walmart-1038593372-c-price', n.captureMethod = 'HTML_SELECTOR', n.priceTextVerbatim = 'current price $44.00 (SYNTHETIC)', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-12T09:00:00Z'), n.updatedAt = datetime('2026-10-12T09:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'}), (b:PriceObservation {uid: 'hu:price-obs:w15-syn-walmart-1038593372-2026-10-02-archive'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// No LISTING_FOR. Unresolved identity is an assessment, kept PROPOSED/UNRESOLVED; CQ-CM-02 answers "identity unknown".
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'})
ON CREATE SET n.id = 'walmart-1038593372-to-tru-niagen-300mg-30ct', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'UNRESOLVED', n.score = 0.5, n.rationale = 'Title and brand fit Tru Niagen 300mg 30 capsules, but the displayed UPC 850015311116 differs from the brand\'s current 30-count GTIN 850015311857 (truniagen.com JSON). Could be an earlier package/label version or a different package; label not captured. Not determinable.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-upc'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-title'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-to-tru-niagen-300mg-30ct'}), (b:Activity {uid: 'hu:activity:w15-commerce-match-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
// Authorized-channel check: NOT_DETERMINABLE (no Tru Niagen authorized-reseller statement captured). A low price from an LLM capture is not a gray-market finding.
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:walmart-1038593372-authorized-channel'})
ON CREATE SET n.id = 'walmart-1038593372-authorized-channel', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-authorized-channel/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'AUTHORIZED_CHANNEL', n.matchOutcome = 'NOT_DETERMINABLE', n.rationale = 'Third-party seller (sellerType EXTERNAL); brand authorized-reseller list not captured; the $19.90 capture is LLM-extracted and contradicted by the structured price $45.00 one minute later.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-authorized-channel'}), (b:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-authorized-channel'}), (b:Organization {uid: 'hu:org:seller-account-walmart-sports-med'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:walmart-1038593372-authorized-channel'}), (b:SourceLocator {uid: 'hu:locator:walmart-1038593372-b-seller'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (o:Offer {uid: 'hu:offer:walmart-us-1038593372-sports-med'}) SET o.availabilityStatus = 'IN_STOCK', o.firstObservedAt = datetime('2026-10-04T01:20:44Z'), o.lastObservedAt = datetime('2026-10-04T01:21:32Z'), o.projectedFromPriceObservationUid = 'hu:price-obs:walmart-1038593372-2026-10-04t0121-one-time-raw';
