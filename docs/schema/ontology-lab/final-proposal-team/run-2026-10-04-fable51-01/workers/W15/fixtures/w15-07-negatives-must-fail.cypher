// W15 fixture 07 -- NEGATIVE cases (must produce the validator rows named per block). Load after 00 and 01 (and 05 for N7).
// SYNTHETIC. Never load into a production database. Every statement binds its own nodes by uid.

// N1 [HOSTS_LISTING, SELLS_PRODUCT]: Amazon "sells" Tru Niagen Beauty because it hosts B0FS82B35K. Expect V-326c, V-112 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS, V-W15-01.
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-beauty-us-30ct'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-neg-sells-from-hosting', r.derivedFromAssertionUids = ['hu:assertion:amazon-hosts-listing-b0fs82b35k-2026-10-04'], r.derivedAt = datetime('2026-10-04T02:00:00Z');
// N2 [FULFILLS_OFFER, SELLS_PRODUCT]: Amazon "sells" because it ships. Different target (variant 300mg) so N1/N2 stay separate edges. Expect V-326c, V-112, V-W15-01.
MATCH (a:Organization {uid: 'hu:org:amazon-marketplace-us'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-neg-sells-from-fulfilment', r.derivedFromAssertionUids = ['hu:assertion:amazon-fulfills-offer-b0fs82b35k-2026-10-04'], r.derivedAt = datetime('2026-10-04T02:00:00Z');
// N3 SELLS_PRODUCT with no citation at all. Expect V-326a, V-112 NO_CITATION, V-W15-01.
MATCH (a:Organization {uid: 'hu:org:walmart-marketplace-us'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivedAt = datetime('2026-10-04T02:00:00Z');
// N4 SELLER_OF_RECORD_FOR written from fulfilment, without an assertion, on the B0FS82B35K offer that already has a seller. Expect V-326b (orgFulfillsTheOffer true, orgHostsTheListing true), V-327, V-101.
MATCH (o:Organization {uid: 'hu:org:amazon-marketplace-us'}), (off:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'})
MERGE (o)-[r:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:w15-neg-amazon-sor-from-fulfilment'}]->(off)
ON CREATE SET r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';
// N5 averaged price without a kind, and a non-catalog kind. Expect V-328 (two rows).
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:w15-neg-averaged'})
ON CREATE SET n.id = 'w15-neg-averaged', n.amount = 45.55, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.priceTextVerbatim = 'average of 49.00 and 41.65 and 44.10 (WRONG)', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MERGE (n:PriceObservation:Occurrence {uid: 'hu:price-obs:w15-neg-kind-average'})
ON CREATE SET n.id = 'w15-neg-kind-average', n.amount = 45.55, n.currency = 'USD', n.observedAt = datetime('2026-10-04T01:19:18Z'), n.priceKind = 'AVERAGE', n.occurrenceType = 'PriceObservation', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:w15-neg-averaged'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
MATCH (a:Offer {uid: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new'}), (b:PriceObservation {uid: 'hu:price-obs:w15-neg-kind-average'})
MERGE (a)-[r:HAS_PRICE_OBSERVATION]->(b);
// N6 live-style Listing price with no PriceObservation behind it (legacy label Listing kept during migration). Expect V-329 and V-W15-03.
MERGE (l:Listing:MerchantListing:Entity {uid: 'hu:listing:w15-neg-unbacked-price'})
ON CREATE SET l.id = 'w15-neg-unbacked-price', l.entityType = 'MerchantListing', l.priceAmount = 39.0, l.currency = 'USD', l.availabilityStatus = 'IN_STOCK', l.currentAsOf = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.updatedAt = datetime('2026-10-04T02:00:00Z');
// N7 [LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]: a "label declaration" built from the B0CLQZHVHL title on the marketplace snapshot. Expect V-W15-04 (two rows).
MERGE (n:LabelDeclaration:InformationArtifact {uid: 'hu:label-declaration:w15-neg-from-title'})
ON CREATE SET n.id = 'w15-neg-from-title', n.verbatimText = 'Nicotinamide Riboside 1000mg', n.declarationKind = 'OTHER_DIETARY_INGREDIENT', n.artifactType = 'LabelDeclaration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:amazon-b07tk5k5tq-aod-2026-10-04t0119'}), (b:LabelDeclaration {uid: 'hu:label-declaration:w15-neg-from-title'})
MERGE (a)-[r:HAS_DECLARATION]->(b);
MERGE (n:QuantityDeclaration:InformationArtifact {uid: 'hu:quantity-declaration:w15-neg-from-title'})
ON CREATE SET n.id = 'w15-neg-from-title', n.value = 1000.0, n.unitCode = 'mg', n.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', n.artifactType = 'QuantityDeclaration', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.updatedAt = datetime('2026-10-04T02:00:00Z');
MATCH (a:LabelDeclaration {uid: 'hu:label-declaration:w15-neg-from-title'}), (b:QuantityDeclaration {uid: 'hu:quantity-declaration:w15-neg-from-title'})
MERGE (a)-[r:HAS_QUANTITY_DECLARATION]->(b);
MATCH (a:QuantityDeclaration {uid: 'hu:quantity-declaration:w15-neg-from-title'}), (b:Assertion {uid: 'hu:assertion:amazon-us-b0clqzhvhl-title-amount'})
MERGE (a)-[r:DERIVED_FROM_ASSERTION]->(b);
// N8 commerce risk written as properties instead of CommerceMatch candidates. Expect V-W15-07 (two rows).
MATCH (o:Offer {uid: 'hu:offer:amazon-us-b000qsnygi-zk-inc'}) SET o.isGrayMarket = true;
MATCH (l:MerchantListing {uid: 'hu:listing:amazon-us-b000qsnygi'}) SET l.recalled = false;
// N9 LISTING_FOR written without an assertion (silent identity). Expect V-101 (catalog list extended by W15), V-W15-02.
MATCH (l:MerchantListing {uid: 'hu:listing:walmart-us-1038593372'}), (p:PackageConfiguration {uid: 'hu:package-configuration:tru-niagen-300mg-30ct'})
MERGE (l)-[r:LISTING_FOR {relationshipUid: 'hu:rel:w15-neg-silent-listing-for'}]->(p)
ON CREATE SET r.recordedFrom = datetime('2026-10-04T02:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';
// N10 [AFFILIATE_FOR_OFFER, ENDORSES_PRODUCT]: endorsement derived from the affiliate link. Expect V-112 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS, V-W15-06.
MATCH (a:Person {uid: 'hu:person:john-alexander-fastlifehacks'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-pro-1000mg-us-capsule'})
MERGE (a)-[r:ENDORSES_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-neg-endorse-from-affiliate', r.derivedFromAssertionUids = ['hu:assertion:john-alexander-affiliate-for-b0clqzhvhl-offer'], r.derivedAt = datetime('2026-10-04T02:00:00Z');
// N11 SELLS_PRODUCT from a seller-of-record assertion whose listing identity is only an UNRESOLVED CommerceMatch (Walmart, no LISTING_FOR). Expect V-W15-01 (V-326c passes: input predicate is right).
MATCH (a:Organization {uid: 'hu:org:seller-account-walmart-sports-med'}), (b:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
MERGE (a)-[r:SELLS_PRODUCT]->(b)
ON CREATE SET r.derivationRule = 'w15-sells-product-from-seller-of-record/v1', r.derivedFromAssertionUids = ['hu:assertion:sports-med-seller-of-record-1038593372-2026-10-04'], r.derivedAt = datetime('2026-10-04T02:00:00Z');
