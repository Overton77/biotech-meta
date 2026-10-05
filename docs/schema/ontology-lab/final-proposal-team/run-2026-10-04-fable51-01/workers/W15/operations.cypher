// W15 commerce operations (proposal; Fable merges into docs/schema/neo4j/final_biotech_schema_operations.cypher).
// Target: Neo4j 5.26.x. Statements marked [COMMUNITY] were applied on the embedded 5.26.31 Community instance on 2026-10-04
// (see 07-operations.md section 1 for the result); [ENTERPRISE] statements are listed for the edition companion and were NOT run.
// Stored property names only (no GraphQL aliases are used by W15). Idempotent (IF NOT EXISTS).

// ---- identity (uid per primary label; INV-106 / V-000a) ------------------------------------------------- [COMMUNITY]
CREATE CONSTRAINT w15_merchant_listing_uid IF NOT EXISTS FOR (n:MerchantListing) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_offer_uid IF NOT EXISTS FOR (n:Offer) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_price_observation_uid IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_subscription_plan_uid IF NOT EXISTS FOR (n:SubscriptionPlan) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_bundle_uid IF NOT EXISTS FOR (n:Bundle) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_bundle_component_uid IF NOT EXISTS FOR (n:BundleComponent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_inventory_item_uid IF NOT EXISTS FOR (n:InventoryItem) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_individual_unit_uid IF NOT EXISTS FOR (n:IndividualUnit) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_affiliate_link_uid IF NOT EXISTS FOR (n:AffiliateLink) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w15_commerce_match_uid IF NOT EXISTS FOR (n:CommerceMatch) REQUIRE n.uid IS UNIQUE;
// live projection identity (id = opaque segment of uid; GraphQL @id)
CREATE CONSTRAINT w15_merchant_listing_id IF NOT EXISTS FOR (n:MerchantListing) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w15_offer_id IF NOT EXISTS FOR (n:Offer) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w15_price_observation_id IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.id IS UNIQUE;

// ---- merchant key: one listing per (marketplace, merchantListingId); composite uniqueness ---------------- [COMMUNITY]
// Nodes missing either property are not constrained (clinic pages without a key).
CREATE CONSTRAINT w15_listing_marketplace_key IF NOT EXISTS FOR (n:MerchantListing) REQUIRE (n.marketplace, n.merchantListingId) IS UNIQUE;
// One inventory record per (merchant, merchant inventory id).
CREATE CONSTRAINT w15_inventory_merchant_key IF NOT EXISTS FOR (n:InventoryItem) REQUIRE (n.merchantOrganizationUid, n.merchantInventoryId) IS UNIQUE;

// ---- retrieval indexes ------------------------------------------------------------------------------------ [COMMUNITY]
// canonicalUrl joins the listing to the W00 Source of its page (Source.canonicalUri is indexed by W00).
CREATE INDEX w15_listing_canonical_url IF NOT EXISTS FOR (n:MerchantListing) ON (n.canonicalUrl);
CREATE INDEX w15_listing_parent_ref IF NOT EXISTS FOR (n:MerchantListing) ON (n.marketplace, n.parentListingRef);
// price history per offer is reached by HAS_PRICE_OBSERVATION; the range index serves "observed since/before" scans and QS-2 freshness.
CREATE INDEX w15_price_observed_at IF NOT EXISTS FOR (n:PriceObservation) ON (n.observedAt);
CREATE INDEX w15_price_kind IF NOT EXISTS FOR (n:PriceObservation) ON (n.priceKind);
CREATE INDEX w15_price_locator IF NOT EXISTS FOR (n:PriceObservation) ON (n.sourceLocatorUid);
CREATE INDEX w15_offer_last_observed IF NOT EXISTS FOR (n:Offer) ON (n.lastObservedAt);
CREATE INDEX w15_plan_selling_plan_id IF NOT EXISTS FOR (n:SubscriptionPlan) ON (n.sellingPlanId);
CREATE INDEX w15_affiliate_tracking IF NOT EXISTS FOR (n:AffiliateLink) ON (n.affiliateProgram, n.trackingValue);
CREATE INDEX w15_affiliate_locator IF NOT EXISTS FOR (n:AffiliateLink) ON (n.sourceLocatorUid);
CREATE INDEX w15_commerce_match_kind IF NOT EXISTS FOR (n:CommerceMatch) ON (n.matchKind, n.status);
CREATE INDEX w15_unit_lot_code IF NOT EXISTS FOR (n:IndividualUnit) ON (n.lotCodeAsPrinted);
// relationship-property indexes for episode lookup by audit id and by authorizing assertion
CREATE INDEX w15_rel_seller_of_record_uid IF NOT EXISTS FOR ()-[r:SELLER_OF_RECORD_FOR]-() ON (r.relationshipUid);
CREATE INDEX w15_rel_seller_of_record_assertion IF NOT EXISTS FOR ()-[r:SELLER_OF_RECORD_FOR]-() ON (r.assertionUid);
CREATE INDEX w15_rel_listing_for_assertion IF NOT EXISTS FOR ()-[r:LISTING_FOR]-() ON (r.assertionUid);
CREATE INDEX w15_rel_hosts_listing_assertion IF NOT EXISTS FOR ()-[r:HOSTS_LISTING]-() ON (r.assertionUid);
CREATE INDEX w15_rel_fulfills_offer_assertion IF NOT EXISTS FOR ()-[r:FULFILLS_OFFER]-() ON (r.assertionUid);

// ---- fulltext (D-015: live index and query names kept; stored property names) ---------------------------- [COMMUNITY]
// The live ListingSearch index covered url; the merged field is canonicalUrl (migration M-01 copies url -> canonicalUrl).
CREATE FULLTEXT INDEX ListingSearch IF NOT EXISTS FOR (n:MerchantListing)
  ON EACH [n.name, n.description, n.searchText, n.title, n.listingType, n.status, n.canonicalUrl, n.availabilityStatus, n.commercialTermsSummary];

// ---- existence and type constraints (catalog required fields) ------------------------------------------- [ENTERPRISE]
// Not executable on Community (rejected like the 12 baseline existence/type constraints). Service-enforced on Community; V-328,
// V-W15-02 and V-W00-08 detect violations after the fact.
// CREATE CONSTRAINT w15_price_amount_exists IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.amount IS NOT NULL;
// CREATE CONSTRAINT w15_price_currency_exists IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.currency IS NOT NULL;
// CREATE CONSTRAINT w15_price_observed_exists IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.observedAt IS NOT NULL;
// CREATE CONSTRAINT w15_price_kind_exists IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.priceKind IS NOT NULL;
// CREATE CONSTRAINT w15_price_amount_type IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.amount IS :: FLOAT;
// CREATE CONSTRAINT w15_price_observed_type IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.observedAt IS :: ZONED DATETIME;
// CREATE CONSTRAINT w15_offer_payload_hash_exists IF NOT EXISTS FOR (n:Offer) REQUIRE n.payloadHash IS NOT NULL;
// CREATE CONSTRAINT w15_commerce_match_kind_exists IF NOT EXISTS FOR (n:CommerceMatch) REQUIRE n.matchKind IS NOT NULL;
// CREATE CONSTRAINT w15_sor_assertion_exists IF NOT EXISTS FOR ()-[r:SELLER_OF_RECORD_FOR]-() REQUIRE r.assertionUid IS NOT NULL;
// CREATE CONSTRAINT w15_sor_recorded_exists IF NOT EXISTS FOR ()-[r:SELLER_OF_RECORD_FOR]-() REQUIRE r.recordedFrom IS NOT NULL;
// CREATE CONSTRAINT w15_listing_for_assertion_exists IF NOT EXISTS FOR ()-[r:LISTING_FOR]-() REQUIRE r.assertionUid IS NOT NULL;
// CREATE CONSTRAINT w15_rel_sor_key IF NOT EXISTS FOR ()-[r:SELLER_OF_RECORD_FOR]-() REQUIRE r.relationshipUid IS RELATIONSHIP KEY;
