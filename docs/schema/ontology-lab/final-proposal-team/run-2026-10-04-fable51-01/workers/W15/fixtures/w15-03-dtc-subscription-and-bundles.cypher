// W15 fixture 03 -- DTC Shopify store truniagen.com: selling plans, JSON vs rendered subscription price, bundles (CQ-CM-02, CQ-CM-03).
// PUBLIC records, NEW_RETRIEVAL 2026-10-04: /products/tru-niagen-300mg.js (01:18:33Z, complete JSON, not hashed: SYNTHETIC_FIXTURE),
// /products.json?limit=50 (01:18:22Z, sha256 over the extracted JSON text, NORMALIZED_TEXT), rendered PDP (01:18:46Z, PARTIAL_EXCERPT).
// JSON: variants 30 ($49.00, SKU CTNUS3006030010, barcode 850015311857), 90 ($127.00), 180 ($244.00, SKU CTNUS3006090010-KIT);
// selling_plan_group "Subscribe and Save" (app_id ordergroove-subscribe-and-save) with plans 1316552773/1341685829/1341718597/1341751365
// (every month / 2 / 3 / 6 months), price_adjustments [] and per_delivery_price 4900 for the 30-count.
// Rendered PDP: "Subscribe & Save: 1 month supply Save 20% $39.20 $1.31/count"; "3 months supply Save 30% $101.60"; "6 months supply
// Save 33% $195.20"; "Save 20% on recurring orders."; "Pause, skip, or cancel anytime."; "One-Time Purchase: 1 month supply $49.00".
// The JSON plan carries no price adjustment while the page shows 20% off: TWO SUBSCRIPTION observations (49.00 RAW_STRUCTURED_DATA,
// 39.20 LLM_DIRECT_QUOTE) are kept, never merged or averaged. "Save 30%" for the 90-count is relative to three 30-counts ($147),
// "Save 20%" relative to $127: the percentages have different references and are kept only as conditionText.
// Listing granularity: one MerchantListing per Shopify variant (the purchasable entry); the product page is the parent (parentListingRef).
// Shopify is the platform (commercePlatform), not a host. The DTC merchant of record is not displayed: SELLER_OF_RECORD_FOR stays PROPOSED
// and no SELLS_PRODUCT is derived.
// Binding rule: every statement MATCHes or MERGEs its nodes by uid; no variable crosses a ";". Load after w15-00-common.cypher.

MERGE (n:Source:Entity {uid: 'hu:source:truniagen-300mg-js'})
ON CREATE SET n.id = 'truniagen-300mg-js', n.canonicalUri = 'https://www.truniagen.com/products/tru-niagen-300mg.js', n.title = 'Shopify product JSON tru-niagen-300mg', n.sourceKind = 'MARKETING_PAGE', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'})
ON CREATE SET n.id = 'truniagen-300mg-js-2026-10-04t0118', n.retrievedAt = datetime('2026-10-04T01:18:33Z'), n.observedAt = datetime('2026-10-04T01:18:33Z'), n.contentHash = 'sha256:8ce5a82e63157683b46f8c88638cbcad3d996331fc98e2aceeb53e40e10949cf', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:truniagen-300mg-js'}), (b:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:Source:Entity {uid: 'hu:source:truniagen-products-json'})
ON CREATE SET n.id = 'truniagen-products-json', n.canonicalUri = 'https://www.truniagen.com/products.json?limit=50', n.title = 'Shopify products.json truniagen.com', n.sourceKind = 'MARKETING_PAGE', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:truniagen-products-json-2026-10-04t0118'})
ON CREATE SET n.id = 'truniagen-products-json-2026-10-04t0118', n.retrievedAt = datetime('2026-10-04T01:18:22Z'), n.observedAt = datetime('2026-10-04T01:18:22Z'), n.contentHash = 'sha256:17271356b2bdfa7d672a2511faef0f0877aae38fcbbe5192309d03aa09375b56', n.contentHashBasis = 'NORMALIZED_TEXT', n.captureCompleteness = 'COMPLETE', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:truniagen-products-json'}), (b:SourceSnapshot {uid: 'hu:snapshot:truniagen-products-json-2026-10-04t0118'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:truniagen-products-json-2026-10-04t0118'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:Source:Entity {uid: 'hu:source:truniagen-300mg-pdp'})
ON CREATE SET n.id = 'truniagen-300mg-pdp', n.canonicalUri = 'https://www.truniagen.com/products/tru-niagen-300mg', n.title = 'Tru Niagen 300mg product page', n.sourceKind = 'MARKETING_PAGE', n.entityType = 'Source', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-2026-10-04t0118', n.retrievedAt = datetime('2026-10-04T01:18:46Z'), n.observedAt = datetime('2026-10-04T01:18:46Z'), n.contentHash = 'sha256:12db9a968c30ed78c4a0b2ffbb0800c47a11f9d6352c8aa2f6d67bcf4a9d0a42', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.artifactType = 'SourceSnapshot', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Source {uid: 'hu:source:truniagen-300mg-pdp'}), (b:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'})<-[:HAS_SNAPSHOT]-(src:Source) SET s.canonicalUri = src.canonicalUri;
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
ON CREATE SET n.id = 'truniagen-300mg-js-variant-30', n.selectorKind = 'SECTION', n.section = 'variants[0]', n.normalizationVersion = 'NFC-WS1', n.exact = 'id 41905353850949 title 30 sku CTNUS3006030010 price 4900 barcode 850015311857 requires_selling_plan false', n.quoteHash = 'sha256:5c6a533713d9b6561717305cb5a18b343cfa2d7ef768ae32f50730291f380e91', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
ON CREATE SET n.id = 'truniagen-300mg-js-variant-90', n.selectorKind = 'SECTION', n.section = 'variants[1]', n.normalizationVersion = 'NFC-WS1', n.exact = 'id 41905353883717 title 90 sku CTNUS3006090010 price 12700 barcode 850015311895', n.quoteHash = 'sha256:d9fc88f36352b08b5dfacc8c352f3899a38b286a01051eb22504a45d472efd94', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
ON CREATE SET n.id = 'truniagen-300mg-js-variant-180', n.selectorKind = 'SECTION', n.section = 'variants[2]', n.normalizationVersion = 'NFC-WS1', n.exact = 'id 41905353916485 title 180 sku CTNUS3006090010-KIT price 24400 barcode 850064273106', n.quoteHash = 'sha256:dd387add4ac72325a45a221c33c9beafdfb7fa0ac1ca3719a3c4070299bbcb87', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-js-alloc-30-monthly'})
ON CREATE SET n.id = 'truniagen-300mg-js-alloc-30-monthly', n.selectorKind = 'SECTION', n.section = 'variants[0].selling_plan_allocations[0]', n.normalizationVersion = 'NFC-WS1', n.exact = 'price_adjustments [] price 4900 per_delivery_price 4900 selling_plan_id 1316552773', n.quoteHash = 'sha256:2fb1ab4c34154aa13b099eebd7da2b72fbaf5b3a6c8ff728bc5c2ddcf80ac2c3', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-alloc-30-monthly'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
ON CREATE SET n.id = 'truniagen-300mg-js-plan-group', n.selectorKind = 'SECTION', n.section = 'selling_plan_groups[0]', n.normalizationVersion = 'NFC-WS1', n.exact = 'name Subscribe and Save; app_id ordergroove-subscribe-and-save; plans 1316552773 Delivered every month, 1341685829 Delivered every 2 months, 1341718597 Delivered every 3 months, 1341751365 Delivered every 6 months; price_adjustments []', n.quoteHash = 'sha256:4944f046a65a3f2bc82ecb8287ec06efc0ded4d2ea7fd5c5c78a1092cc03f127', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-js-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-products-json-immune-bundle'})
ON CREATE SET n.id = 'truniagen-products-json-immune-bundle', n.selectorKind = 'SECTION', n.section = 'products[handle=tru-niagen-300mg-30ct-immune-bundle].variants[0]', n.normalizationVersion = 'NFC-WS1', n.exact = 'id 44628427604037 title 30/30 price 85.00 sku CTNUSCK00000004-KIT', n.quoteHash = 'sha256:d759c70241113f6a5d36cc448b2702c5a18eedb93cf2671a5321042daa4c07d7', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-products-json-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-products-json-immune-bundle'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-sns-30'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-sns-30', n.selectorKind = 'TEXT_QUOTE', n.exact = '1 month supplySave 20% $39.20$1.31/count', n.quoteHash = 'sha256:f54797cb4d24e0f228700734eaa5c5aba7e25548ee45e0cc117c32f212127924', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-sns-30'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-sns-90'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-sns-90', n.selectorKind = 'TEXT_QUOTE', n.exact = '3 months supplySave 30% $101.60$1.13/count', n.quoteHash = 'sha256:4ffb0258814cf6fb5eca6e61eb7f8e7c00ecd65c90d9c59e4fb393423d74f43f', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-sns-90'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-sns-180'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-sns-180', n.selectorKind = 'TEXT_QUOTE', n.exact = '6 months supplySave 33% $195.20$1.08/count', n.quoteHash = 'sha256:8837adbb4c37c34b3910c033e4fc8c8c0cfa7a2d5595c391cda5047cdc080e24', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-sns-180'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-sns-terms'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-sns-terms', n.selectorKind = 'TEXT_QUOTE', n.exact = 'Save 20% on recurring orders.Free U.S. shipping on every order, always.Pause, skip, or cancel anytime.', n.quoteHash = 'sha256:035bf2dd70400467d29f23599734cd5705e7755565e766c4cd064f352e4cd856', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-sns-terms'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-one-time-30'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-one-time-30', n.selectorKind = 'TEXT_QUOTE', n.exact = 'One-Time Purchase: 1 month supply $49.00$1.63/count', n.quoteHash = 'sha256:58290cfe33e6f98072bc3b25976586f5b7254cc17cacd5fcf2df8acf3a81b50b', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-one-time-30'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-pdp-bundle-each'})
ON CREATE SET n.id = 'truniagen-300mg-pdp-bundle-each', n.selectorKind = 'TEXT_QUOTE', n.exact = '30-day supply each: 300mg and Immune.', n.quoteHash = 'sha256:06b28adb2662a056d2e2c06a01672193ea4e04ce1c57530c1a4b8bd81699fdf0', n.normalizationVersion = 'NFC-WS1', n.artifactType = 'SourceLocator', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-pdp-2026-10-04t0118'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-bundle-each'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SubscriptionPlan:VersionedState {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
ON CREATE SET n.id = 'truniagen-shopify-1316552773', n.sellingPlanId = '1316552773', n.planGroupName = 'Subscribe and Save', n.planName = 'Delivered every month', n.interval = 'MONTH', n.intervalCount = 1, n.planProvider = 'ordergroove-subscribe-and-save', n.priceAdjustmentText = 'price_adjustments: []', n.termsText = 'Pause, skip, or cancel anytime.', n.minimumCommitmentStatus = 'NOT_REPORTED', n.payloadHash = 'sha256:8ee246da0aaa998270670cf7495a15fc08c48a4ff9d3e967e63d09544a45576f', n.stateType = 'SubscriptionPlan', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SubscriptionPlan:VersionedState {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
ON CREATE SET n.id = 'truniagen-shopify-1341685829', n.sellingPlanId = '1341685829', n.planGroupName = 'Subscribe and Save', n.planName = 'Delivered every 2 months', n.interval = 'MONTH', n.intervalCount = 2, n.planProvider = 'ordergroove-subscribe-and-save', n.priceAdjustmentText = 'price_adjustments: []', n.termsText = 'Pause, skip, or cancel anytime.', n.minimumCommitmentStatus = 'NOT_REPORTED', n.payloadHash = 'sha256:525bfedb93e8b528f797249e1eeed7e86c307830554990d2872ee27ed27d52af', n.stateType = 'SubscriptionPlan', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SubscriptionPlan:VersionedState {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
ON CREATE SET n.id = 'truniagen-shopify-1341718597', n.sellingPlanId = '1341718597', n.planGroupName = 'Subscribe and Save', n.planName = 'Delivered every 3 months', n.interval = 'MONTH', n.intervalCount = 3, n.planProvider = 'ordergroove-subscribe-and-save', n.priceAdjustmentText = 'price_adjustments: []', n.termsText = 'Pause, skip, or cancel anytime.', n.minimumCommitmentStatus = 'NOT_REPORTED', n.payloadHash = 'sha256:cba965716e091620070e5d6d9736282f16cbf158f5b272f8ac0cbd2e7f6ccc57', n.stateType = 'SubscriptionPlan', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:SubscriptionPlan:VersionedState {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
ON CREATE SET n.id = 'truniagen-shopify-1341751365', n.sellingPlanId = '1341751365', n.planGroupName = 'Subscribe and Save', n.planName = 'Delivered every 6 months', n.interval = 'MONTH', n.intervalCount = 6, n.planProvider = 'ordergroove-subscribe-and-save', n.priceAdjustmentText = 'price_adjustments: []', n.termsText = 'Pause, skip, or cancel anytime.', n.minimumCommitmentStatus = 'NOT_REPORTED', n.payloadHash = 'sha256:acd56a4927d6b8362bfe442448134dbefe6a06401fd67dc8d439013781a68cad', n.stateType = 'SubscriptionPlan', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');

MERGE (n:Bundle:Entity {uid: 'hu:bundle:tru-niagen-300mg-180-kit'})
ON CREATE SET n.id = 'tru-niagen-300mg-180-kit', n.name = 'Tru Niagen 300mg "180" (kit SKU CTNUS3006090010-KIT)', n.bundleKind = 'MULTI_PACK_SAME_ITEM', n.entityType = 'Bundle', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:BundleComponent:VersionedState {uid: 'hu:bundle-component:tru-niagen-300mg-180-kit-90ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-180-kit-90ct', n.quantityStatus = 'NOT_REPORTED', n.componentRole = 'PRIMARY', n.payloadHash = 'sha256:449da531cd377a58fd66abd8f8a16e1a313799e464b05fc1eba3804b85f2b8b1', n.stateType = 'BundleComponent', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Bundle {uid: 'hu:bundle:tru-niagen-300mg-180-kit'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-180-kit-90ct'})
MERGE (a)-[r:HAS_BUNDLE_COMPONENT]->(b)
ON CREATE SET r.orderIndex = 0;
// Component identity inferred from the kit SKU (CTNUS3006090010 + "-KIT"): PROPOSED, basisKind HYPOTHESIS; count NOT_REPORTED (180/90 = 2 is not stated).
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-180-kit-component-is-90ct'})
ON CREATE SET n.id = 'truniagen-180-kit-component-is-90ct', n.predicate = 'COMPONENT_PRODUCT', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.basisKind = 'HYPOTHESIS', n.contentHash = 'sha256:9ac5e8a0c5fe9b97c6dba1ef644f42c05c2b61ae71a852abbdffc1ad6b4df016', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-180-kit-component-is-90ct'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-180-kit-90ct'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-180-kit-component-is-90ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-180-kit-component-is-90ct'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-180-kit-90ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:COMPONENT_PRODUCT {relationshipUid: 'hu:rel:truniagen-180-kit-component-is-90ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-180-kit-component-is-90ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:truniagen-shopify-41905353850949'})
ON CREATE SET n.id = 'truniagen-shopify-41905353850949', n.merchantListingId = '41905353850949', n.marketplace = 'truniagen.com', n.parentListingRef = '7387359477829', n.commercePlatform = 'SHOPIFY', n.marketplaceRegion = 'US', n.title = 'Tru Niagen® 300mg - 30', n.canonicalUrl = 'https://www.truniagen.com/products/tru-niagen-300mg?variant=41905353850949', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:truniagen-shopify-variant-41905353850949'})
ON CREATE SET n.id = 'truniagen-shopify-variant-41905353850949', n.scheme = 'SHOPIFY_VARIANT_ID', n.issuer = 'truniagen.com', n.value = '41905353850949', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-identified-by-variant-id'})
ON CREATE SET n.id = 'truniagen-41905353850949-identified-by-variant-id', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:c3da4a8c53398fef0552bda7e1e5189c8c5110c281f4143a1cde7b3f17ca545d', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-identified-by-variant-id'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-identified-by-variant-id'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353850949'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-identified-by-variant-id'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-identified-by-variant-id-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-identified-by-variant-id-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-identified-by-variant-id-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-identified-by-variant-id'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353850949'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:truniagen-41905353850949-identified-by-variant-id'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-identified-by-variant-id', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-listing-for'})
ON CREATE SET n.id = 'truniagen-41905353850949-listing-for', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:6a7e090e65df21e6c39e5de5684eb4a9190180027eb884c4a3a8a5a1ea3f8708', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-listing-for'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-listing-for'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-listing-for'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-listing-for-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-listing-for-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-listing-for-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-listing-for'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:truniagen-41905353850949-listing-for'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-listing-for', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:truniagen-shopify-41905353850949'})
ON CREATE SET n.id = 'truniagen-shopify-41905353850949', n.offerKind = 'PURCHASE', n.currency = 'USD', n.sellerOfferRef = '41905353850949', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.payloadHash = 'sha256:5da4fa12a3d3b0ef4b71fd5b7b2c2e7b96a031402d1710d85fd0bdbc8cd421f3', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353850949'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353850949', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:f9144c3a1f8cfeec35c2179682d12cdab2ffab85b8846c1d9ad4431b95833821', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353850949'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353850949'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353850949'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-store-hosts-41905353850949-cf'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353850949-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-store-hosts-41905353850949-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353850949'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:truniagen-store-hosts-41905353850949'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-hosts-41905353850949', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353850949'})
ON CREATE SET n.id = 'truniagen-store-seller-of-record-41905353850949', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.assertionBasis = 'UNSTATED', n.contentHash = 'sha256:4e10f1c66b5d98330785e81e6eb39ddc52ff385ac44125f07bc2c8ac356d3b81', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353850949'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353850949'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353850949'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:truniagen-store-seller-of-record-41905353850949'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-seller-of-record-41905353850949', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1316552773', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:1dc47f30843aabb93dab3bb034f3a1a199b5f5ba7734876c35af3c4cf6988d94', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1316552773-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1316552773-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1316552773-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353850949-uses-plan-1316552773'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-uses-plan-1316552773', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341685829', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:acf6d2f03293f0100355d32432ea4923515ff40ab5be388f2f02d2bfba3ce4eb', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341685829-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341685829-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341685829-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353850949-uses-plan-1341685829'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-uses-plan-1341685829', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341718597', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e9da0198f6af98ca8091b5e6b41c56852664791e288836f1d4e56758646152ba', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341718597-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341718597-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341718597-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353850949-uses-plan-1341718597'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-uses-plan-1341718597', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341751365', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:d539bc80fde3b7f6096ceacd3412b77b8a295c3320d8169368a2d4b5549778cb', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341751365-cf'})
ON CREATE SET n.id = 'truniagen-41905353850949-uses-plan-1341751365-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353850949-uses-plan-1341751365-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353850949-uses-plan-1341751365'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353850949-uses-plan-1341751365', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-one-time-json'})
ON CREATE SET n.id = 'truniagen-41905353850949-2026-10-04t0118-one-time-json', n.amount = 49.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.startedAt = datetime('2026-10-04T01:18:33Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-js-variant-30', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = 'price 4900', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-one-time-json'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:truniagen-shopify-41905353883717'})
ON CREATE SET n.id = 'truniagen-shopify-41905353883717', n.merchantListingId = '41905353883717', n.marketplace = 'truniagen.com', n.parentListingRef = '7387359477829', n.commercePlatform = 'SHOPIFY', n.marketplaceRegion = 'US', n.title = 'Tru Niagen® 300mg - 90', n.canonicalUrl = 'https://www.truniagen.com/products/tru-niagen-300mg?variant=41905353883717', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:truniagen-shopify-variant-41905353883717'})
ON CREATE SET n.id = 'truniagen-shopify-variant-41905353883717', n.scheme = 'SHOPIFY_VARIANT_ID', n.issuer = 'truniagen.com', n.value = '41905353883717', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-identified-by-variant-id'})
ON CREATE SET n.id = 'truniagen-41905353883717-identified-by-variant-id', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e9171a07f556e5f5a45c3c33db59cf74e703f607a757b902c69faf6926fc6f28', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-identified-by-variant-id'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-identified-by-variant-id'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353883717'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-identified-by-variant-id'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-identified-by-variant-id-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-identified-by-variant-id-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-identified-by-variant-id-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-identified-by-variant-id'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353883717'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:truniagen-41905353883717-identified-by-variant-id'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-identified-by-variant-id', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-listing-for'})
ON CREATE SET n.id = 'truniagen-41905353883717-listing-for', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:38962be7558df6aa48ebba60991a7e333c269b25dcb42b58d39fed7bd651a75b', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-listing-for'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-listing-for'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-listing-for'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-listing-for-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-listing-for-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-listing-for-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-listing-for'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:truniagen-41905353883717-listing-for'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-listing-for', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:truniagen-shopify-41905353883717'})
ON CREATE SET n.id = 'truniagen-shopify-41905353883717', n.offerKind = 'PURCHASE', n.currency = 'USD', n.sellerOfferRef = '41905353883717', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.payloadHash = 'sha256:da430294a735c575cde5fe9886e58b6480794b491e48c771d0b429c447497e0a', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353883717'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353883717', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:26832afc24b6f60ab0c26112dcfe917e9e934fd581334ad0fc821afd2c297b7b', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353883717'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353883717'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353883717'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-store-hosts-41905353883717-cf'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353883717-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-store-hosts-41905353883717-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353883717'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:truniagen-store-hosts-41905353883717'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-hosts-41905353883717', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353883717'})
ON CREATE SET n.id = 'truniagen-store-seller-of-record-41905353883717', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.assertionBasis = 'UNSTATED', n.contentHash = 'sha256:8f23fe19572452400e56b73503694221b6aedd3f62ebe9898a0cad2416ae7c39', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353883717'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353883717'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353883717'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:truniagen-store-seller-of-record-41905353883717'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-seller-of-record-41905353883717', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1316552773', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:e4f1a15013c98b8bcdc92ccac8d0c469fc834472c26f18348cba5fa8ec3c9577', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1316552773-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1316552773-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1316552773-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353883717-uses-plan-1316552773'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-uses-plan-1316552773', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341685829', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:d5c6a7aa031557cd3906ae0e85afd77e06ed85ee20c5766a543a2f4d161c5843', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341685829-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341685829-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341685829-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353883717-uses-plan-1341685829'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-uses-plan-1341685829', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341718597', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:8ce9cd963215c6f9ad437304e1467436ab38e30e15209fcb0aef70f90cdc1b41', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341718597-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341718597-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341718597-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353883717-uses-plan-1341718597'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-uses-plan-1341718597', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341751365', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:a90a1e6133c2602e40431c6e460a622d7ba49a548b448db8375941d8c4b588a8', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341751365-cf'})
ON CREATE SET n.id = 'truniagen-41905353883717-uses-plan-1341751365-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353883717-uses-plan-1341751365-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353883717-uses-plan-1341751365'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353883717-uses-plan-1341751365', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353883717-2026-10-04t0118-one-time-json'})
ON CREATE SET n.id = 'truniagen-41905353883717-2026-10-04t0118-one-time-json', n.amount = 127.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.startedAt = datetime('2026-10-04T01:18:33Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-js-variant-90', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = 'price 12700', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353883717-2026-10-04t0118-one-time-json'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:truniagen-shopify-41905353916485'})
ON CREATE SET n.id = 'truniagen-shopify-41905353916485', n.merchantListingId = '41905353916485', n.marketplace = 'truniagen.com', n.parentListingRef = '7387359477829', n.commercePlatform = 'SHOPIFY', n.marketplaceRegion = 'US', n.title = 'Tru Niagen® 300mg - 180', n.canonicalUrl = 'https://www.truniagen.com/products/tru-niagen-300mg?variant=41905353916485', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:truniagen-shopify-variant-41905353916485'})
ON CREATE SET n.id = 'truniagen-shopify-variant-41905353916485', n.scheme = 'SHOPIFY_VARIANT_ID', n.issuer = 'truniagen.com', n.value = '41905353916485', n.entityType = 'TradeItemIdentifier', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-identified-by-variant-id'})
ON CREATE SET n.id = 'truniagen-41905353916485-identified-by-variant-id', n.predicate = 'IDENTIFIED_BY', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:90042468e691ede4d303a39162e6943ee38ece4d3fd1a3f6130f2e64a2b81915', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-identified-by-variant-id'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-identified-by-variant-id'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353916485'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-identified-by-variant-id'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-identified-by-variant-id-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-identified-by-variant-id-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-identified-by-variant-id-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-identified-by-variant-id'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'}), (b:TradeItemIdentifier {uid: 'hu:trade-id:truniagen-shopify-variant-41905353916485'})
MERGE (a)-[r:IDENTIFIED_BY {relationshipUid: 'hu:rel:truniagen-41905353916485-identified-by-variant-id'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-identified-by-variant-id', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.isPrimary = true;
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-listing-for'})
ON CREATE SET n.id = 'truniagen-41905353916485-listing-for', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:d0ec9ad9b376c7948ff69dbe8601d37eee6aa7508891cba7ea5cdb1f50941e3a', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-listing-for'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-listing-for'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-180-kit'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-listing-for'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-listing-for-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-listing-for-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-listing-for-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-listing-for'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-180-kit'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:truniagen-41905353916485-listing-for'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-listing-for', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:truniagen-shopify-41905353916485'})
ON CREATE SET n.id = 'truniagen-shopify-41905353916485', n.offerKind = 'PURCHASE', n.currency = 'USD', n.sellerOfferRef = '41905353916485', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.payloadHash = 'sha256:8c6cfeb3d54b2d1bf39826753181c7d8b363a3a02185e443c058138b3a4ed0be', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353916485'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353916485', n.predicate = 'HOSTS_LISTING', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:3b57e65bd745d92e7a069b67693d90a00fa9ec6a7252bb4969eefbd60517f084', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353916485'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353916485'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353916485'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-store-hosts-41905353916485-cf'})
ON CREATE SET n.id = 'truniagen-store-hosts-41905353916485-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-store-hosts-41905353916485-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-store-hosts-41905353916485'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HOSTS_LISTING {relationshipUid: 'hu:rel:truniagen-store-hosts-41905353916485'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-hosts-41905353916485', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353916485'})
ON CREATE SET n.id = 'truniagen-store-seller-of-record-41905353916485', n.predicate = 'SELLER_OF_RECORD_FOR', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'ROLE', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.assertionBasis = 'UNSTATED', n.contentHash = 'sha256:e9a8e2cff149ae28536fbf7c87f0c6f4bcfeab923f3fd633ac770e8bf6c3fef7', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353916485'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353916485'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-store-seller-of-record-41905353916485'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Organization {uid: 'hu:org:truniagen-com-store-operator'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:truniagen-store-seller-of-record-41905353916485'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-store-seller-of-record-41905353916485', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1316552773', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:f53effbbf3c0176a17a8bb68da58261ebbd7edabc84e6dc677854bc670c6da0f', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1316552773-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1316552773-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1316552773-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1316552773'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353916485-uses-plan-1316552773'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-uses-plan-1316552773', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341685829', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:005637c11d750f2f2a91103ebe0ec358eb393cbe5a85e8d47f379897232034b9', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341685829-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341685829-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341685829-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341685829'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353916485-uses-plan-1341685829'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-uses-plan-1341685829', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341718597', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:3bec08a49b78c78aa8ab3757a3f3db35520b5dd68322b0c1f4da343e080e172e', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341718597-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341718597-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341718597-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341718597'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353916485-uses-plan-1341718597'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-uses-plan-1341718597', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341751365', n.predicate = 'USES_SUBSCRIPTION_PLAN', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'COMMERCIAL', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:9a0051a2729dbb54ede34fb9a59ccb253c02830c48c0d47799d33012e15fc420', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-plan-group'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341751365-cf'})
ON CREATE SET n.id = 'truniagen-41905353916485-uses-plan-1341751365-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-41905353916485-uses-plan-1341751365-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:SubscriptionPlan {uid: 'hu:subscription-plan:truniagen-shopify-1341751365'})
MERGE (a)-[r:USES_SUBSCRIPTION_PLAN {relationshipUid: 'hu:rel:truniagen-41905353916485-uses-plan-1341751365'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-41905353916485-uses-plan-1341751365', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353916485-2026-10-04t0118-one-time-json'})
ON CREATE SET n.id = 'truniagen-41905353916485-2026-10-04t0118-one-time-json', n.amount = 244.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.startedAt = datetime('2026-10-04T01:18:33Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-js-variant-180', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = 'price 24400', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353916485-2026-10-04t0118-one-time-json'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// Identity licence for the DTC entries: the variant barcode in the brand's own JSON equals the package GTIN (W04 IDENTIFIED_BY) -> ACCEPTED SAME_ITEM;
// the "180" kit composition is not stated -> PROPOSED / UNRESOLVED (its LISTING_FOR to the Bundle stays asserted-only).
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:truniagen-shopify-41905353850949-to-item'})
ON CREATE SET n.id = 'truniagen-shopify-41905353850949-to-item', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'SAME_ITEM', n.rationale = 'Brand JSON variant barcode 850015311857 equals the 30-count package GTIN.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353850949-to-item'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353850949'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353850949-to-item'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353850949-to-item'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-30'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:truniagen-shopify-41905353883717-to-item'})
ON CREATE SET n.id = 'truniagen-shopify-41905353883717-to-item', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'SAME_ITEM', n.rationale = 'Brand JSON variant barcode 850015311895 equals the 90-count package GTIN.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353883717-to-item'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353883717'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353883717-to-item'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-90ct'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353883717-to-item'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-90'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:CommerceMatch:EvidenceAssessment {uid: 'hu:commerce-match:truniagen-shopify-41905353916485-to-item'})
ON CREATE SET n.id = 'truniagen-shopify-41905353916485-to-item', n.assessmentType = 'CommerceMatch', n.methodVersion = 'w15-gtin-title-match/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.matchKind = 'LISTING_TO_ITEM', n.matchOutcome = 'UNRESOLVED', n.rationale = 'Kit SKU CTNUS3006090010-KIT and barcode 850064273106; component count not stated, so the bundle composition is unresolved.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353916485-to-item'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-41905353916485'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353916485-to-item'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-180-kit'})
MERGE (a)-[r:MATCHES_COMMERCE_ITEM]->(b);
MATCH (a:CommerceMatch {uid: 'hu:commerce-match:truniagen-shopify-41905353916485-to-item'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-js-variant-180'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-json'})
ON CREATE SET n.id = 'truniagen-41905353850949-2026-10-04t0118-subscription-json', n.amount = 49.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:33Z'), n.startedAt = datetime('2026-10-04T01:18:33Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-js-alloc-30-monthly', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = 'per_delivery_price 4900 (price_adjustments [])', n.observationRegion = 'US', n.subscriptionPlanUid = 'hu:subscription-plan:truniagen-shopify-1316552773', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-json'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-pdp'})
ON CREATE SET n.id = 'truniagen-41905353850949-2026-10-04t0118-subscription-pdp', n.amount = 39.2, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:46Z'), n.startedAt = datetime('2026-10-04T01:18:46Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-pdp-sns-30', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = '1 month supply Save 20% $39.20', n.conditionText = 'Save 20% on recurring orders.', n.observationRegion = 'US', n.subscriptionPlanUid = 'hu:subscription-plan:truniagen-shopify-1316552773', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-pdp'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-per-count-pdp'})
ON CREATE SET n.id = 'truniagen-41905353850949-2026-10-04t0118-subscription-per-count-pdp', n.amount = 1.31, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:46Z'), n.startedAt = datetime('2026-10-04T01:18:46Z'), n.priceKind = 'PER_UNIT', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-pdp-sns-30', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = '$1.31/count', n.conditionText = 'Subscribe & Save, 1 month supply', n.observationRegion = 'US', n.unitQuantity = 1.0, n.unitCode = '{count}', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-subscription-per-count-pdp'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-one-time-pdp'})
ON CREATE SET n.id = 'truniagen-41905353850949-2026-10-04t0118-one-time-pdp', n.amount = 49.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:46Z'), n.startedAt = datetime('2026-10-04T01:18:46Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-pdp-one-time-30', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = 'One-Time Purchase: 1 month supply $49.00', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353850949'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353850949-2026-10-04t0118-one-time-pdp'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353883717-2026-10-04t0118-subscription-pdp'})
ON CREATE SET n.id = 'truniagen-41905353883717-2026-10-04t0118-subscription-pdp', n.amount = 101.6, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:46Z'), n.startedAt = datetime('2026-10-04T01:18:46Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-pdp-sns-90', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = '3 months supply Save 30% $101.60', n.conditionText = 'Save 30% (displayed; reference not stated); Save 20% on recurring orders.', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353883717'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353883717-2026-10-04t0118-subscription-pdp'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-41905353916485-2026-10-04t0118-subscription-pdp'})
ON CREATE SET n.id = 'truniagen-41905353916485-2026-10-04t0118-subscription-pdp', n.amount = 195.2, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:46Z'), n.startedAt = datetime('2026-10-04T01:18:46Z'), n.priceKind = 'SUBSCRIPTION', n.availabilityObserved = 'NOT_DISPLAYED', n.sourceLocatorUid = 'hu:locator:truniagen-300mg-pdp-sns-180', n.captureMethod = 'LLM_DIRECT_QUOTE', n.priceTextVerbatim = '6 months supply Save 33% $195.20', n.conditionText = 'Save 33% (displayed; reference not stated)', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-41905353916485'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-41905353916485-2026-10-04t0118-subscription-pdp'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// Mixed kit: "Tru Niagen 300mg 30ct + Immune Bundle" (products.json variant 44628427604037, SKU CTNUSCK00000004-KIT, $85.00).
MERGE (n:Bundle:Entity {uid: 'hu:bundle:tru-niagen-300mg-30ct-immune-kit'})
ON CREATE SET n.id = 'tru-niagen-300mg-30ct-immune-kit', n.name = 'Tru Niagen 300mg 30ct + Immune Bundle (CTNUSCK00000004-KIT)', n.bundleKind = 'MIXED_KIT', n.entityType = 'Bundle', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:BundleComponent:VersionedState {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-300mg-30ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-immune-kit-300mg-30ct', n.quantity = 1, n.quantityStatus = 'REPORTED', n.componentRole = 'PRIMARY', n.payloadHash = 'sha256:cc49a7314c0e5826b2182787234875914a8f71f610572f3695ce3c1ae8c49a96', n.stateType = 'BundleComponent', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Bundle {uid: 'hu:bundle:tru-niagen-300mg-30ct-immune-kit'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-300mg-30ct'})
MERGE (a)-[r:HAS_BUNDLE_COMPONENT]->(b)
ON CREATE SET r.orderIndex = 0;
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'})
ON CREATE SET n.id = 'truniagen-immune-kit-component-300mg-30ct', n.predicate = 'COMPONENT_PRODUCT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:318bd468681177ee68fe338cd0f021623e062623e04e2e4e6af03078b10f457b', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-300mg-30ct'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'}), (b:SourceLocator {uid: 'hu:locator:truniagen-products-json-immune-bundle'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-bundle-each'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-immune-kit-component-300mg-30ct-cf'})
ON CREATE SET n.id = 'truniagen-immune-kit-component-300mg-30ct-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-immune-kit-component-300mg-30ct-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-300mg-30ct'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-300mg-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (a)-[r:COMPONENT_PRODUCT {relationshipUid: 'hu:rel:truniagen-immune-kit-component-300mg-30ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-immune-kit-component-300mg-30ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:BundleComponent:VersionedState {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-immune-30ct'})
ON CREATE SET n.id = 'tru-niagen-300mg-immune-kit-immune-30ct', n.quantity = 1, n.quantityStatus = 'REPORTED', n.componentRole = 'PRIMARY', n.payloadHash = 'sha256:069471e1c57c4df319385bfe3af8389e4f945aca6a86c533f3f42e55c74aa235', n.stateType = 'BundleComponent', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Bundle {uid: 'hu:bundle:tru-niagen-300mg-30ct-immune-kit'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-immune-30ct'})
MERGE (a)-[r:HAS_BUNDLE_COMPONENT]->(b)
ON CREATE SET r.orderIndex = 1;
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'})
ON CREATE SET n.id = 'truniagen-immune-kit-component-immune-30ct', n.predicate = 'COMPONENT_PRODUCT', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:08779928d584d30f4e300e9873951fc7b6643d0d174d88a14473029e96540630', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'}), (b:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-immune-30ct'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-immune-30ct'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'}), (b:SourceLocator {uid: 'hu:locator:truniagen-products-json-immune-bundle'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'}), (b:SourceLocator {uid: 'hu:locator:truniagen-300mg-pdp-bundle-each'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-immune-kit-component-immune-30ct-cf'})
ON CREATE SET n.id = 'truniagen-immune-kit-component-immune-30ct-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-immune-kit-component-immune-30ct-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-immune-kit-component-immune-30ct'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:BundleComponent {uid: 'hu:bundle-component:tru-niagen-300mg-immune-kit-immune-30ct'}), (b:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-immune-30ct'})
MERGE (a)-[r:COMPONENT_PRODUCT {relationshipUid: 'hu:rel:truniagen-immune-kit-component-immune-30ct'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-immune-kit-component-immune-30ct', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:MerchantListing:Entity {uid: 'hu:listing:truniagen-shopify-44628427604037'})
ON CREATE SET n.id = 'truniagen-shopify-44628427604037', n.merchantListingId = '44628427604037', n.marketplace = 'truniagen.com', n.parentListingRef = '7953098997829', n.commercePlatform = 'SHOPIFY', n.marketplaceRegion = 'US', n.title = 'Tru Niagen® 300mg 30ct + Immune Bundle - 30/30', n.canonicalUrl = 'https://www.truniagen.com/products/tru-niagen-300mg-30ct-immune-bundle?variant=44628427604037', n.entityType = 'MerchantListing', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:truniagen-44628427604037-listing-for'})
ON CREATE SET n.id = 'truniagen-44628427604037-listing-for', n.predicate = 'LISTING_FOR', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.polarity = 'POSITIVE', n.predicateClass = 'IDENTITY', n.speechAct = 'STATES', n.validFromBasis = 'OBSERVATION_ONLY', n.validToBasis = 'UNKNOWN', n.contentHash = 'sha256:75d730bf166683e15d74f57e662139b736464a2dd2384b1a13b2249c5f6871ef', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-44628427604037-listing-for'}), (b:MerchantListing {uid: 'hu:listing:truniagen-shopify-44628427604037'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-44628427604037-listing-for'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-30ct-immune-kit'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:truniagen-44628427604037-listing-for'}), (b:SourceLocator {uid: 'hu:locator:truniagen-products-json-immune-bundle'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:truniagen-44628427604037-listing-for-cf'})
ON CREATE SET n.id = 'truniagen-44628427604037-listing-for-cf', n.assessmentType = 'Adjudication', n.methodVersion = 'w15-capture-review/v0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.adjudicationKind = 'CAPTURE_FIDELITY', n.verdict = 'SUPPORTED', n.reviewerType = 'HUMAN', n.reviewedAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Adjudication {uid: 'hu:adjudication:truniagen-44628427604037-listing-for-cf'}), (b:Assertion {uid: 'hu:assertion:truniagen-44628427604037-listing-for'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-44628427604037'}), (b:Bundle {uid: 'hu:bundle:tru-niagen-300mg-30ct-immune-kit'})
MERGE (a)-[r:LISTING_FOR {relationshipUid: 'hu:rel:truniagen-44628427604037-listing-for'}]->(b)
ON CREATE SET r.assertionUid = 'hu:assertion:truniagen-44628427604037-listing-for', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
MERGE (n:Offer:VersionedState {uid: 'hu:offer:truniagen-shopify-44628427604037'})
ON CREATE SET n.id = 'truniagen-shopify-44628427604037', n.offerKind = 'PURCHASE', n.currency = 'USD', n.sellerOfferRef = '44628427604037', n.observedAt = datetime('2026-10-04T01:18:22Z'), n.payloadHash = 'sha256:d20693f4c9cc3a2f6dfab6793a976f634eaf4b0fd201b36f72d88c60265651a0', n.stateType = 'Offer', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:MerchantListing {uid: 'hu:listing:truniagen-shopify-44628427604037'}), (b:Offer {uid: 'hu:offer:truniagen-shopify-44628427604037'})
MERGE (a)-[r:HAS_OFFER]->(b);
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:truniagen-44628427604037-2026-10-04t0118-one-time-json'})
ON CREATE SET n.id = 'truniagen-44628427604037-2026-10-04t0118-one-time-json', n.amount = 85.0, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:18:22Z'), n.startedAt = datetime('2026-10-04T01:18:22Z'), n.priceKind = 'ONE_TIME', n.availabilityObserved = 'IN_STOCK', n.sourceLocatorUid = 'hu:locator:truniagen-products-json-immune-bundle', n.captureMethod = 'RAW_STRUCTURED_DATA', n.priceTextVerbatim = 'price 85.00', n.observationRegion = 'US', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:truniagen-shopify-44628427604037'}), (b:PriceObservation {uid: 'hu:price-obs:truniagen-44628427604037-2026-10-04t0118-one-time-json'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// Store operator -> brand owner: ResolutionHypothesis only (site terms naming the merchant of record were not captured).
MERGE (n:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:truniagen-com-store-operated-by-chromadex'})
ON CREATE SET n.id = 'truniagen-com-store-operated-by-chromadex', n.assessmentType = 'ResolutionHypothesis', n.methodVersion = 'w15-seller-account-resolution/v0', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.resolutionType = 'STORE_OPERATED_BY_LEGAL_ENTITY', n.score = 0.7, n.resolutionStatus = 'UNRESOLVED', n.rationale = 'Brand DTC domain; vendor "Tru Niagen" in product JSON is the brand, not a legal seller; terms of sale not captured.', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:truniagen-com-store-operated-by-chromadex'}), (b:Organization {uid: 'hu:org:truniagen-com-store-operator'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
MATCH (a:ResolutionHypothesis {uid: 'hu:resolution:truniagen-com-store-operated-by-chromadex'}), (b:Organization {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:PROPOSES_MATCH]->(b);
