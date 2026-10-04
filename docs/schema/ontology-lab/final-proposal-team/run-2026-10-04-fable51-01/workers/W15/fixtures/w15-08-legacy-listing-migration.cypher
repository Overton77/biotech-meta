// W15 fixture 08 -- live-shaped legacy records (SYNTHETIC) and the migration statements of migration-map.yaml applied to them.
// Part A writes what the live API stores today (label Listing, LISTS with listRole, LISTS_PRODUCT with TemporalMetadata, ListingSnapshot via
// HAS_SNAPSHOT, price fields on the listing). Part B is the migration: relabel, split roles into PROPOSED review assertions (never ACCEPTED
// without a capture), turn the snapshot into a SourceSnapshot + Offer + PriceObservation, keep LISTS/LISTS_PRODUCT read-only (LEGACY_UNDATED).

// Part A (live shape).
MERGE (l:Listing {id: 'w15-legacy-listing-1'})
ON CREATE SET l.name = 'Legacy listing (synthetic)', l.url = 'https://shop.example.invalid/p/1', l.priceAmount = 59.0, l.currency = 'USD', l.availabilityStatus = 'in stock', l.capturedAt = datetime('2025-11-02T10:00:00Z'), l.currentAsOf = datetime('2025-11-02T10:05:00Z'), l.listingType = 'product', l.commercialTermsSummary = 'Subscribe and save 15%', l.createdAt = datetime('2025-11-02T10:05:00Z'), l.updatedAt = datetime('2025-11-02T10:05:00Z');
MERGE (o:Organization {id: 'w15-legacy-shop-org'}) ON CREATE SET o.name = 'Legacy Shop Inc (synthetic)', o.createdAt = datetime('2025-11-02T10:05:00Z'), o.updatedAt = datetime('2025-11-02T10:05:00Z');
MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (o:Organization {id: 'w15-legacy-shop-org'}) MERGE (o)-[r:LISTS]->(l) ON CREATE SET r.listRole = 'seller', r.localPriceAmount = 59.0, r.localCurrency = 'USD';
MERGE (p:Product {id: 'w15-legacy-product-1'}) ON CREATE SET p.name = 'Legacy product (synthetic)', p.createdAt = datetime('2025-11-02T10:05:00Z'), p.updatedAt = datetime('2025-11-02T10:05:00Z');
MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (p:Product {id: 'w15-legacy-product-1'}) MERGE (l)-[r:LISTS_PRODUCT]->(p) ON CREATE SET r.validFrom = datetime('2025-11-02T00:00:00Z'), r.confidence = 0.8;
MERGE (s:ListingSnapshot {id: 'w15-legacy-listing-1-snap-1'}) ON CREATE SET s.name = 'snapshot', s.url = 'https://shop.example.invalid/p/1', s.priceAmount = 59.0, s.currency = 'USD', s.availabilityStatus = 'in stock', s.capturedAt = datetime('2025-11-02T10:00:00Z'), s.validFrom = datetime('2025-11-02T10:00:00Z'), s.createdAt = datetime('2025-11-02T10:05:00Z'), s.updatedAt = datetime('2025-11-02T10:05:00Z');
MATCH (l:Listing {id: 'w15-legacy-listing-1'}), (s:ListingSnapshot {id: 'w15-legacy-listing-1-snap-1'}) MERGE (l)-[:HAS_SNAPSHOT]->(s);
// Part B (migration M-01..M-07, see migration-map.yaml and 07-operations.md section 5).
MATCH (l:Listing) WHERE l.uid IS NULL SET l.uid = 'hu:listing:' + l.id, l:MerchantListing:Entity, l.entityType = 'MerchantListing', l.canonicalUrl = coalesce(l.canonicalUrl, l.url), l.privacyClass = coalesce(l.privacyClass, 'PUBLIC');
MATCH (o:Organization) WHERE o.uid IS NULL AND o.id = 'w15-legacy-shop-org' SET o.uid = 'hu:org:' + o.id, o:Entity, o.entityType = 'Organization', o.privacyClass = 'PUBLIC';
MATCH (p:Product) WHERE p.uid IS NULL AND p.id = 'w15-legacy-product-1' SET p.uid = 'hu:product:' + p.id, p:Entity, p.entityType = 'Product', p.privacyClass = 'PUBLIC';
// M-03: each ListingSnapshot -> Source (once per URL) + SourceSnapshot (observedAt = capturedAt, retrievedAt = createdAt, hash basis SYNTHETIC_FIXTURE because the bytes were never kept, completeness UNKNOWN).
MATCH (l:MerchantListing)-[:HAS_SNAPSHOT]->(ls:ListingSnapshot) WHERE ls.id = 'w15-legacy-listing-1-snap-1'
MERGE (src:Source:Entity {uid: 'hu:source:legacy-' + l.id})
ON CREATE SET src.id = 'legacy-' + l.id, src.entityType = 'Source', src.canonicalUri = coalesce(ls.url, l.canonicalUrl), src.sourceKind = 'MARKETPLACE_LISTING', src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-10-04T03:00:00Z'), src.updatedAt = datetime('2026-10-04T03:00:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:legacy-' + ls.id})
ON CREATE SET sn.id = 'legacy-' + ls.id, sn.artifactType = 'SourceSnapshot', sn.canonicalUri = src.canonicalUri, sn.observedAt = ls.capturedAt, sn.retrievedAt = ls.createdAt, sn.contentHash = 'sha256:' + '0000000000000000000000000000000000000000000000000000000000000000', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T03:00:00Z'), sn.updatedAt = datetime('2026-10-04T03:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(sn);
// M-04: LISTS{listRole: seller} -> Offer (one per listing x seller) + PROPOSED SELLER_OF_RECORD_FOR review assertion (no locator: legacy rows were never captured), PriceObservation per snapshot price.
MATCH (o:Organization)-[r:LISTS]->(l:MerchantListing) WHERE r.listRole = 'seller' AND l.id = 'w15-legacy-listing-1'
MERGE (off:Offer:VersionedState {uid: 'hu:offer:legacy-' + l.id + '-' + o.id})
ON CREATE SET off.id = 'legacy-' + l.id + '-' + o.id, off.stateType = 'Offer', off.offerKind = 'UNKNOWN', off.currency = r.localCurrency, off.termsText = l.commercialTermsSummary, off.payloadHash = 'sha256:legacy-migration-unhashed', off.privacyClass = 'PUBLIC', off.createdAt = datetime('2026-10-04T03:00:00Z'), off.updatedAt = datetime('2026-10-04T03:00:00Z')
MERGE (l)-[:HAS_OFFER]->(off)
MERGE (a:Assertion {uid: 'hu:assertion:legacy-sor-' + l.id + '-' + o.id})
ON CREATE SET a.id = 'legacy-sor-' + l.id + '-' + o.id, a.predicate = 'SELLER_OF_RECORD_FOR', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.predicateClass = 'ROLE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.assertionBasis = 'UNSTATED', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T03:00:00Z'), a.updatedAt = datetime('2026-10-04T03:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:HAS_OBJECT]->(off)
MERGE (o)-[e:SELLER_OF_RECORD_FOR {relationshipUid: 'hu:rel:legacy-sor-' + l.id + '-' + o.id}]->(off)
ON CREATE SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';
MATCH (l:MerchantListing)-[:HAS_SNAPSHOT]->(ls:ListingSnapshot), (l)-[:HAS_OFFER]->(off:Offer) WHERE l.id = 'w15-legacy-listing-1' AND ls.priceAmount IS NOT NULL
MERGE (po:PriceObservation:Occurrence {uid: 'hu:price-obs:legacy-' + ls.id})
ON CREATE SET po.id = 'legacy-' + ls.id, po.occurrenceType = 'PriceObservation', po.amount = ls.priceAmount, po.currency = ls.currency, po.observedAt = ls.capturedAt, po.startedAt = ls.capturedAt, po.priceKind = 'ONE_TIME', po.availabilityObserved = 'UNKNOWN', po.captureMethod = 'LEGACY_MIGRATION', po.sourceLocatorUid = null, po.privacyClass = 'PUBLIC', po.createdAt = datetime('2026-10-04T03:00:00Z'), po.updatedAt = datetime('2026-10-04T03:00:00Z')
MERGE (off)-[:HAS_PRICE_OBSERVATION]->(po);
// M-05: listing projections now name their backing observation; availability free text "in stock" is kept only in the legacy snapshot.
MATCH (l:MerchantListing)-[:HAS_OFFER]->(:Offer)-[:HAS_PRICE_OBSERVATION]->(po:PriceObservation) WHERE l.id = 'w15-legacy-listing-1'
SET l.projectedFromPriceObservationUid = po.uid, l.lastObservedAt = po.observedAt, l.priceKindProjected = po.priceKind, l.availabilityStatus = po.availabilityObserved;
// M-06: ListingSnapshot nodes are relabelled as retired compatibility records (kept for audit; no API type) and detached from HAS_SNAPSHOT.
MATCH (l:MerchantListing)-[h:HAS_SNAPSHOT]->(ls:ListingSnapshot) WHERE l.id = 'w15-legacy-listing-1' SET ls:LegacyListingSnapshot REMOVE ls:ListingSnapshot DELETE h;
