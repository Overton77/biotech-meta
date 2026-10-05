# W15 Model cards

Conventions for every card. Common fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) follow contract B2 and are not repeated. Privacy class of every W15 element: PUBLIC (no private-personal value exists, D-012); CommerceMatch method fields INTERNAL-tier operational. "Kind": asserted (a source said it), observed (displayed at an instant), calculated, inferred, operational (system bookkeeping), projection (read-only materialization). uid tokens: `listing`, `offer`, `price-obs`, `trade-id` are registered (catalog `uidTypeTokens`); `subscription-plan`, `bundle`, `bundle-component`, `inventory-item`, `individual-unit`, `affiliate-link`, `commerce-match` are requested (W15-SR-08). Sources: S-numbers refer to 03-source-manifest.md.

## Node types

### MerchantListing (Entity; maturity PROVISIONAL)
- **Meaning**: one merchant catalog entry for one sellable item at the most specific level the merchant identifies (Amazon ASIN, Walmart item, Shopify variant, clinic procedure/test page). Not product identity, not a seller, not a label, not the page capture.
- **Labels**: `["MerchantListing","Entity"]`; uid `hu:listing:<opaque>`. Live label `Listing` is relabelled by migration M-01.
- **Identity keys**: `(marketplace, merchantListingId)` unique when both present (composite uniqueness, Community-verified); `uid`. Aliases: TradeItemIdentifiers via `IDENTIFIED_BY` (ASIN, Walmart item id, Shopify variant id, displayed UPC). URL and title are never identity.

| Property | Type | Null | Units / values | Kind | Temporal | Note |
|---|---|---|---|---|---|---|
| entityType | String! | no | 'MerchantListing' | operational | — | archetype field |
| merchantListingId | String | yes (no key on page) | merchant key | asserted (materialized copy of the Identifier) | immutable | |
| marketplace | String | yes | registrable domain | asserted | immutable | scope of the key |
| parentListingRef | String | yes | parent ASIN / Shopify product id | asserted | mutable display | grouping only |
| commercePlatform | String | yes | SHOPIFY, AMAZON, WALMART_MARKETPLACE … | observed | mutable | a platform is not a role |
| marketplaceRegion | String | yes | ISO 3166-1 | asserted | mutable | |
| title | String | yes | verbatim | observed (display) | mutable, last observed | title amounts → LISTING_TITLE_AMOUNT assertions |
| canonicalUrl | String | yes | URL | asserted | mutable | = Source.canonicalUri of the page |
| listingType, status | String | yes | free text | legacy display | mutable | |
| priceAmount, currency, availabilityStatus, priceKindProjected, capturedAt, lastObservedAt, currentAsOf, projectedFromPriceObservationUid, commercialTermsSummary | Float / String / PriceKind / DateTime | yes | — | projection (read-only) | rewritten by projection job | never written by API; V-329, V-W15-03 |
| searchText, searchFields, embeddingModel, embeddingDimensions | — | yes | — | operational | — | SearchIndexable; fulltext `ListingSearch` |

- **Edges**: HOSTS_LISTING in (Organization; asserted; zero_or_one believed per episode); LISTING_FOR out (ListingTarget; asserted; zero_or_one ACCEPTED); HAS_OFFER out (Offer; structural; many); IDENTIFIED_BY out (TradeItemIdentifier; asserted; IdentifierLinkProperties); LISTS_PROCEDURE out (Procedure; asserted; ListingEdgeProperties); IMPLEMENTS_PANEL out (PanelDefinition; asserted); AVAILABLE_IN out (Facility; asserted; ListingEdgeProperties); LINKS_TO in (AffiliateLink); MATCHES_COMMERCE_ITEM in (CommerceMatch); legacy read-only LISTS_PRODUCT out (Product), LISTS in (Organization).
- **Derived inputs**: projections from the latest PriceObservation of its offers. **Sources**: S1, S2, S4, S5, S6, S8; round 0005. **CQs**: CQ-CM-01/02/03/04, CQ-AX-06/17.

### Offer (VersionedState; PROVISIONAL)
- **Meaning**: one party's proposition for the item of one listing (seller, terms, condition, purchase mode). Not a price, not a product, not an availability.
- **Labels** `["Offer","VersionedState"]`; uid `hu:offer:<opaque>`; one per (listing, seller of record, itemCondition, offerKind). A seller not captured → placeholder Offer (maturity CANDIDATE) without SELLER_OF_RECORD_FOR.

| Property | Type | Null | Values | Kind | Temporal |
|---|---|---|---|---|---|
| stateType | String! | no | 'Offer' | operational | — |
| payloadHash | String! | no | sha256 over (offerKind, currency, itemCondition, termsText, sellerOfferRef) | calculated | immutable |
| effectiveFrom / effectiveTo | DateTime | yes | source-stated promotion period | asserted | immutable |
| offerKind | OfferKind | yes | PURCHASE … | asserted | immutable |
| currency | String | yes | ISO 4217 | asserted | immutable |
| itemCondition | String | yes | NEW, USED, REFURBISHED, DAMAGED | observed | immutable |
| termsText | String | yes | verbatim | observed | immutable |
| sellerOfferRef | String | yes | merchant offer reference | observed | immutable |
| observedAt | DateTime | yes | capture instant of the payload | observed | immutable |
| availabilityStatus, firstObservedAt, lastObservedAt, projectedFromPriceObservationUid | — | yes | — | projection | rewritten |

- **Edges**: HAS_OFFER in (exactly_one listing); HAS_PRICE_OBSERVATION out (structural); USES_SUBSCRIPTION_PLAN out (asserted); SELLER_OF_RECORD_FOR in (asserted; at most one open per offer, V-327); FULFILLS_OFFER, LISTS_OFFER in (asserted); AFFILIATE_FOR_OFFER in from Organization and Person (asserted; FINANCIAL_INTEREST family); LINKS_TO in; MATCHES_COMMERCE_ITEM in.
- **Temporal behaviour**: existence answered by role-edge valid time + observations (Q-W15-05). **Sources**: S1, S4, S6, S8. **CQs**: CQ-CM-01/02/03/05, CQ-AX-06/17.

### PriceObservation (Occurrence; PROVISIONAL)
- **Meaning**: one displayed price of one kind for one offer at one instant. Immutable (`@mutation(CREATE)`).
- **Labels** `["PriceObservation","Occurrence"]`; uid `hu:price-obs:<opaque>`.

| Property | Type | Null | Units / values | Kind |
|---|---|---|---|---|
| occurrenceType | String! | no | 'PriceObservation' | operational |
| startedAt / endedAt | DateTime | yes | = observedAt / null | observed |
| amount | Float! | no | in `currency` (per unit for PER_UNIT) | observed |
| currency | String! | no | ISO 4217 | observed |
| observedAt | DateTime! | no | display instant | observed |
| priceKind | PriceKind! | no | 5 values | observed (classified by rule from the display) |
| availabilityObserved | ObservedAvailability | yes (null = not captured) | | observed |
| unitQuantity, unitCode | Float, String | yes | UCUM / annotation `{count}` | observed |
| priceTextVerbatim, conditionText | String | yes | verbatim | observed |
| observationRegion | String | yes | ISO 3166-1/2 | observed (delivery context) |
| subscriptionPlanUid | String | yes | uid | asserted link |
| sourceLocatorUid | String | yes (required by V-W15-08 except legacy) | uid | provenance |
| captureMethod | String | yes | RAW_STRUCTURED_DATA, HTML_SELECTOR, LLM_DIRECT_QUOTE, SEARCH_SNIPPET, MANUAL_TRANSCRIPTION, LEGACY_MIGRATION | operational |

- **Edges**: HAS_PRICE_OBSERVATION in (exactly_one offer). **Rule**: never averaged; conflicting captures both kept (V-W15-11). **Sources**: S1, S4, S6, S7, S8. **CQs**: CQ-CM-03/05, CQ-AX-06/17.

### SubscriptionPlan (VersionedState; PROVISIONAL)
- **Meaning**: recurring-delivery plan configuration an offer can be bought under. Not a price; not a person's subscription.
- **Labels** `["SubscriptionPlan","VersionedState"]`; uid `hu:subscription-plan:<opaque>` (token requested).
- **Properties**: stateType!, payloadHash!, effectiveFrom/To, sellingPlanId (platform-scoped), planGroupName, planName, interval (DAY/WEEK/MONTH/YEAR), intervalCount (Int), intervalOptionsText, termsText, planProvider, priceAdjustmentText (the plan's own declared adjustment), minimumCommitmentCount (Int), minimumCommitmentStatus (ReportedStatus). All asserted/observed, immutable.
- **Edges**: USES_SUBSCRIPTION_PLAN in. **Sources**: S6 (`selling_plan_groups`), S7, S1. **CQs**: CQ-CM-02/03.

### Bundle (Entity; PROVISIONAL)
- **Meaning**: sellable combination (multi-pack or kit). Not a PackageConfiguration, not a formulation.
- **Labels** `["Bundle","Entity"]`; uid `hu:bundle:<opaque>`; identifiers via HAS_IDENTIFIER (kit SKU, kit GTIN).
- **Properties**: entityType!, bundleKind (MULTI_PACK_SAME_ITEM, MIXED_KIT, VARIETY_PACK, UNKNOWN; asserted).
- **Edges**: HAS_BUNDLE_COMPONENT out (structural, orderIndex); HAS_IDENTIFIER out (asserted); LISTING_FOR in; INVENTORY_INSTANCE_OF in. **Sources**: S5, S6, S2. **CQs**: CQ-CM-02, CQ-AX-17.

### BundleComponent (VersionedState; PROVISIONAL)
- **Properties**: stateType!, payloadHash!, effectiveFrom/To, quantity (Int; null when not stated), quantityStatus (ReportedStatus: REPORTED / NOT_REPORTED), componentRole (PRIMARY, ADD_ON, FREE_GIFT, SAMPLE, UNKNOWN).
- **Edges**: HAS_BUNDLE_COMPONENT in (exactly_one); COMPONENT_PRODUCT out to Product | ProductVariant | PackageConfiguration (asserted; exactly one across the three fields). **Missingness**: "180 = 2 × 90" is not stated → quantity null + NOT_REPORTED + PROPOSED HYPOTHESIS component (fixture 03).

### InventoryItem (Entity; CANDIDATE — in fragment for fixture 06 and CQ-CM-C03)
- **Properties**: entityType!, merchantInventoryId! (merchant-scoped), merchantOrganizationUid (scope). Composite uniqueness (merchantOrganizationUid, merchantInventoryId).
- **Edges**: INVENTORY_INSTANCE_OF out → ListingTarget (asserted); MATCHES_COMMERCE_ITEM in. **Never** carries recall/gray/counterfeit flags (V-W15-07).

### IndividualUnit (Entity; CANDIDATE — in fragment for fixture 06 and W12 SAMPLE_FROM)
- **Properties**: entityType!, serialNumber, lotCodeAsPrinted, expiryTextAsPrinted, acquiredFromOfferUid, acquisitionContext (PUBLIC_TESTING_PURCHASE, RECALL_NOTICE_EXHIBIT, REGULATORY_SAMPLE, OTHER_PUBLIC). All asserted by the public actor, immutable.
- **Edges**: UNIT_FROM_LOT out → ProductLot (asserted); SAMPLE_FROM in (W12 TestSample); MATCHES_COMMERCE_ITEM in. **Privacy**: a unit bought or used by a private person never enters the graph (V-W15-10).

### AffiliateLink (InformationArtifact; PROVISIONAL)
- **Labels** `["AffiliateLink","InformationArtifact"]`; immutable; uid `hu:affiliate-link:<opaque>`.
- **Properties**: artifactType!, publishedAt (container), observedAt, contentHash (sha256 of URL), url!, trackingParameter (name), trackingValue, affiliateProgram (AMAZON_ASSOCIATES, IMPACT, PARTNERIZE, CJ, SHAREASALE, BRAND_DIRECT, UNKNOWN; inferred from URL pattern), anchorText, sourceLocatorUid.
- **Edges**: LINKS_TO out → MerchantListing or Offer (structural; zero_or_one). Evidence for AFFILIATE_FOR_OFFER, not that assertion. **Sources**: S9, S10. **CQs**: CQ-CM-01 (affiliate leg), CQ-CM-04.

### CommerceMatch (EvidenceAssessment; PROVISIONAL)
- **Labels** `["CommerceMatch","EvidenceAssessment"]`; uid `hu:commerce-match:<opaque>`.
- **Properties**: assessmentType!, methodVersion!, status! (AssessmentStatus), recordedAt!, recordedTo, summary, overallScore, confidence (deprecated, read-only), matchKind! (LISTING_TO_ITEM, INVENTORY_TO_ITEM, RECALL_SCOPE, AUTHORIZED_CHANNEL), matchOutcome (SAME_ITEM, DIFFERENT_ITEM, IN_SCOPE, OUT_OF_SCOPE, NO_AUTHORIZATION_FOUND, AUTHORIZED, NOT_DETERMINABLE, UNRESOLVED), score (method score, never truth), rationale (states what cannot be established).
- **Edges**: MATCHES_COMMERCE_ITEM out → CommerceItemTarget (structural, ≥2 in practice); SUPPORTED_BY out → SourceLocator (required for RECALL_SCOPE / AUTHORIZED_CHANNEL); WAS_GENERATED_BY → Activity; SUPERSEDES → CommerceMatch; ASSESSED_BY → Agent | Person.
- **Rule**: licenses SELLS_PRODUCT derivation (derivedFromAssessmentUids) only when ACCEPTED + SAME_ITEM. **CQs**: CQ-CM-02, CQ-AX-14, CQ-CM-C03.

## Relationship types (all owned by W15; endpoints by name)

| Type | Domain → range | Class | Cardinality | Properties | Forbidden / rule | Catalog |
|---|---|---|---|---|---|---|
| LISTING_FOR | MerchantListing → ProductVariant \| PackageConfiguration \| Bundle | asserted | zero_or_one ACCEPTED per episode | AssertedEdgeProperties | "resolved" needs ACCEPTED SAME_ITEM CommerceMatch | range + Bundle (W15-SR-07) |
| HAS_OFFER | MerchantListing → Offer | structural | many / exactly_one inverse | none | | ✓ |
| HAS_PRICE_OBSERVATION | Offer → PriceObservation | structural | many / exactly_one inverse | none | | ✓ |
| USES_SUBSCRIPTION_PLAN | Offer → SubscriptionPlan | asserted | many | AssertedEdgeProperties | | ✓ |
| HOSTS_LISTING | Organization → MerchantListing | asserted | zero_or_one believed | AssertedEdgeProperties | never → SELLS_PRODUCT | ✓ |
| LISTS_OFFER | Organization → Offer | asserted | many | AssertedEdgeProperties | never → SELLS_PRODUCT | ✓ |
| SELLER_OF_RECORD_FOR | Organization → Offer | asserted (asserted_edge) | ≤1 open per offer (V-327) | AssertedEdgeProperties | sole premise of SELLS_PRODUCT | ✓ |
| FULFILLS_OFFER | Organization → Offer | asserted (asserted_edge) | many | AssertedEdgeProperties | never → SELLS_PRODUCT | ✓ |
| AFFILIATE_FOR_OFFER | Person \| Organization → Offer | asserted (FINANCIAL_INTEREST) | many | AssertedEdgeProperties | never → SELLS_PRODUCT / ENDORSES_PRODUCT | ✓ |
| LINKS_TO | AffiliateLink → MerchantListing \| Offer | structural | zero_or_one | none | | ✓ |
| HAS_BUNDLE_COMPONENT | Bundle → BundleComponent | structural | one_or_more | StructuralEdgeProperties (orderIndex) | | ✓ |
| COMPONENT_PRODUCT | BundleComponent → Product \| ProductVariant \| PackageConfiguration | asserted | exactly_one | AssertedEdgeProperties | | range + PackageConfiguration |
| INVENTORY_INSTANCE_OF | InventoryItem → ProductVariant \| PackageConfiguration \| Bundle | asserted | zero_or_one ACCEPTED | AssertedEdgeProperties | | range + Bundle |
| UNIT_FROM_LOT | IndividualUnit → ProductLot | asserted | zero_or_one ACCEPTED | AssertedEdgeProperties | printed code ≠ lot identity | ✓ |
| MATCHES_COMMERCE_ITEM | CommerceMatch → CommerceItemTarget | structural | one_or_more | none | | range extended |
| SELLS_PRODUCT | Organization → Product \| ProductVariant | derived (mustBeRegenerable) | many | DerivedEdgeProperties: derivationRule `w15-sells-product-from-seller-of-record/v1`, derivedFromAssertionUids = ACCEPTED SoR assertions of the same org, derivedFromAssessmentUids = licensing CommerceMatch | V-326a/b/c, V-W15-01, V-W15-06 | ✓ |
| AVAILABLE_IN | MerchantListing → Facility | asserted | many | ListingEdgeProperties | | live, re-ranged |
| LISTS_PROCEDURE | MerchantListing → Procedure | asserted | many | ListingEdgeProperties | | live |
| IMPLEMENTS_PANEL | MerchantListing → PanelDefinition | asserted | many | AssertedEdgeProperties | | live |
| (legacy) LISTS, LISTS_PRODUCT | Organization → MerchantListing; MerchantListing → Product | legacy read-only | — | none exposed | LEGACY_UNDATED in answers | live |

**SELLS_PRODUCT derivation rule** `w15-sells-product-from-seller-of-record/v1`: for each ACCEPTED assertion `a` with predicate SELLER_OF_RECORD_FOR, subject `o`, object Offer `off`, current (recordedTo null) episode: find `ml` with HAS_OFFER → `off`; for each current LISTING_FOR `ml → t` with an ACCEPTED CommerceMatch {LISTING_TO_ITEM, SAME_ITEM} matching `ml` and `t`: target = `t` if ProductVariant; the variant that HAS_PACKAGE_CONFIGURATION `t` if PackageConfiguration; no edge for Bundle (bundle components are reached by queries, not by SELLS_PRODUCT). Write `(o)-[:SELLS_PRODUCT {derivationRule, derivedFromAssertionUids:[a.uid], derivedFromAssessmentUids:[cm.uid], derivedAt}]->(target)`. Delete and regenerate when any input is superseded. Never from HOSTS_LISTING, LISTS_OFFER, FULFILLS_OFFER, AFFILIATE_FOR_OFFER, LISTING_FOR alone.

## Relationship-property type

### ListingEdgeProperties (W15)
- Specializes `AssertedEdgeProperties`: relationshipUid!, assertionUid!, validFrom, validTo, validFromPrecision, validToPrecision, validFromBasis!, validToBasis!, recordedFrom!, recordedTo, mongoResearchRunId (all frozen semantics) + `appointmentRequiredOverride: Boolean` (live ListingMetadata qualifier; null = not stated; shares the edge's life).
- Used by LISTS_PROCEDURE (W06 inverse already references it) and AVAILABLE_IN. Mapping from live ListingMetadata in migration-map.yaml.

## Enums

| Enum | Values | Owner | Maturity | Note |
|---|---|---|---|---|
| PriceKind | LIST, ONE_TIME, SUBSCRIPTION, COUPON_ADJUSTED, PER_UNIT | W15 | ACCEPTED (catalog conventions, frozen) | LIST = merchant reference price ("List Price: $114.99", S4; "List Price: $59.00", S3) |
| OfferKind | PURCHASE, SUBSCRIPTION_ONLY, PREORDER, SERVICE_BOOKING, UNKNOWN | W15 | CANDIDATE values (W15-SR-10) | SUBSCRIPTION_ONLY grounded on Shopify `requires_selling_plan` (S6) |
| ObservedAvailability | IN_STOCK, LIMITED_STOCK, OUT_OF_STOCK, BACKORDER, PREORDER, CURRENTLY_UNAVAILABLE, DISCONTINUED_AS_DISPLAYED, NOT_DISPLAYED, UNKNOWN | W15 | CANDIDATE (W15-SR-10) | schema.org ItemAvailability alignment; none ends an offer |

## Unions

| Union | Members | Used by |
|---|---|---|
| ListingTarget | ProductVariant \| PackageConfiguration \| Bundle | LISTING_FOR, INVENTORY_INSTANCE_OF |
| CommerceItemTarget | MerchantListing \| Offer \| InventoryItem \| IndividualUnit \| ProductVariant \| PackageConfiguration \| Bundle \| ProductLot \| Organization | MATCHES_COMMERCE_ITEM |

## Candidates kept OUT of the fragment

| Candidate | Why not now | Trigger to add |
|---|---|---|
| `CommerceMatchKind`, `CommerceMatchOutcome` enums | not in the registry row; String with controlled values documented | ledger acceptance of W15-SR-10 |
| `ItemCondition` enum | condition is a schema.org vocabulary String for now | a CQ filtering on condition |
| `shippingTermsText`, `taxText`, `cancellationTermsText` | OPEN-QUESTIONS quality/commerce 4 keeps them as text in `termsText` | a CQ needing a filter |
| `referencePriceObservationUid` on PriceObservation ("Save 30%" relative to what) | S7 shows the need but no CQ asks for discount arithmetic | candidate CQ-CM-C04 accepted |
| `AFFILIATE_FOR_LISTING` | not catalog; LINKS_TO answers CQ-CM-04 | a program paying per listing rather than per purchase |
| `OBSERVED_AT_LOCATOR` relationship for occurrences | kernel domain question (W15-SR-09) | W00 ruling |
| `RecallEvent` / recall status | W13's regulatory record | W13 delivers it; CommerceMatch RECALL_SCOPE then cites it |
