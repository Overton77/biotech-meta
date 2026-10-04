# W15 Commerce and access to products: domain recommendation

Worker W15 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical module: `products_and_commerce` (catalog 0.2.0, digest `8fb50ff0…84f0`), commerce half. Product, variant and package identity (the other half of the same module) is W04's; lots W12's; seller identity W01's; private purchases and subscriptions are external-store records (W23).

## 1. Boundary

Commerce answers "who offers what to whom, on which surface, at what price and terms, as observed when". It does not answer what a product is (W04), what is in it (W04/W02), whether it works (W09/W10), whether a lot passed testing (W12), whether it is approved (W13), or what a person bought (W23).

| Subdomain | In W15 | Explicitly outside |
|---|---|---|
| Selling surfaces | `MerchantListing` (one merchant catalog entry: ASIN, Walmart item, Shopify variant, clinic procedure page) | the captured page bytes (W00 `SourceSnapshot` of a `Source` with `sourceKind: MARKETPLACE_LISTING`); the storefront software (a string, `commercePlatform`) |
| Propositions | `Offer` (one seller's proposition on one listing), `SubscriptionPlan`, `Bundle`/`BundleComponent` | product identity, package identity (W04) |
| Observations | `PriceObservation` (one displayed price of one kind at one instant, with displayed availability) | a person's paid price (W23) |
| Commercial roles | `HOSTS_LISTING`, `LISTS_OFFER`, `SELLER_OF_RECORD_FOR`, `FULFILLS_OFFER`, `AFFILIATE_FOR_OFFER`; derived `SELLS_PRODUCT` | the organizations themselves, seller legal identity (W01); manufacturing, distribution, marketing roles (W01/W11) |
| Tracked links | `AffiliateLink` | the container document/episode (W20/W21), the speaker's claim (W21) |
| Physical stock | `InventoryItem` (merchant SKU), `IndividualUnit` (a unit known through a public actor) | lots (W12), recall events (W13), a person's bottle (W23) |
| Identity resolution in commerce | `CommerceMatch` (listing/inventory/unit compared with variant, package, bundle, lot or an authorized-channel statement) | generic `ResolutionHypothesis` / `EquivalenceAssessment` (W00) |

## 2. Baseline names and dispositions (every live and catalog element in scope)

Live = `docs/schema/current_biotech_schema.graphql` (lines 167–174 `ListingMetadata`, 878–928 `Listing`, `ListingSnapshot`, plus the Organization/Product/Procedure fields that touch them). Catalog = `products_and_commerce` (0.2.0) and `conventions.priceKind`. Proposed delta = `neo4j/proposed-delta.graphql` lines 536–543, 748–784, 1326–1334.

| Element | Origin | Disposition | Final element | Archetype / class | Note |
|---|---|---|---|---|---|
| `Listing` | live | **rename/merge** (D-007) | `MerchantListing` | Entity | labels `["MerchantListing","Entity"]`; keeps procedures, panels, in-clinic availability (live breadth) |
| `Listing.url` | live | **merge** | `MerchantListing.canonicalUrl` | — | migration M-01 copies `url`; `ListingSearch` fulltext re-created on stored `canonicalUrl` |
| `Listing.listingType`, `status` | live | **keep** (display) | same | — | free text, never offer end or product status |
| `Listing.priceAmount`, `currency`, `capturedAt` | live | **derive** (read-only projection) | same names, `@settable(false,false)` + `projectedFromPriceObservationUid`, `priceKindProjected`, `lastObservedAt` | projection | V-329 / V-W15-03 list unbacked values |
| `Listing.availabilityStatus` | live | **derive** (read-only projection) | same (String: ObservedAvailability name) | projection | a displayed state, never an end |
| `Listing.currentAsOf` | live | **keep** as operational materialization time, read-only | same | operational | answers cite `lastObservedAt`, not `currentAsOf` |
| `Listing.commercialTermsSummary` | live | **seam → derive** | read-only legacy display; terms in `Offer.termsText`, `SubscriptionPlan.termsText` | — | |
| `Listing.searchText`, `searchFields`, `embedding*` | live | **keep** (`SearchIndexable`) | same | — | `@vector` only by Fable (D-014) |
| `Listing.offeredBy` (`LISTS`, `ListingMetadata.listRole`) | live | **split** + legacy read-only | `HOSTS_LISTING`, `LISTS_OFFER`, `SELLER_OF_RECORD_FOR`, `FULFILLS_OFFER`, `AFFILIATE_FOR_OFFER`; `MerchantListing.legacyListedBy` read-only | asserted | one string role cannot keep host, seller and fulfiller apart over time (round 0005 C9; S1, S4) |
| `Organization.listings` (`LISTS`) | live | **retire** on Organization (W01 reserved no field) | inverse lives on `MerchantListing.legacyListedBy` | legacy | W01 migration-map row "handed to W15" |
| `Listing.listsProducts` / `Product.listedIn` (`LISTS_PRODUCT`, TemporalMetadata vs RoleMetadata) | live | **split**: legacy read-only (no properties) + successor `LISTING_FOR` | `MerchantListing.legacyListsProducts`, `MerchantListing.listingFor` | legacy / asserted | resolves OPEN-QUESTIONS live-stack 5 by not reading the stored properties at all (section 4) |
| `Listing.listsProcedures` (`LISTS_PROCEDURE`, TemporalMetadata) | live | **keep, refine** properties | `MerchantListing.listsProcedures`, `ListingEdgeProperties` | asserted | W06's inverse already declares `ListingEdgeProperties` |
| `Listing.implementsPanels` (`IMPLEMENTS_PANEL`, RoleMetadata) | live | **keep, refine** | `AssertedEdgeProperties` (same as W04 `Product.implementsPanels`) | asserted | |
| `Listing.availableIn` (`AVAILABLE_IN` → PhysicalLocation) | live | **keep, re-range** to `Facility` (W01-SR-15a) | `MerchantListing.availableIn` with `ListingEdgeProperties` | asserted | market-level availability is `marketplaceRegion` / `observationRegion` |
| `Listing.snapshots` (`HAS_SNAPSHOT` → ListingSnapshot) | live | **retire** | — | — | `HAS_SNAPSHOT` keeps its catalog meaning Source → SourceSnapshot (W01-SR-01) |
| `ListingSnapshot` (+ delta extension) | live/delta | **retire** (D-007) into `SourceSnapshot` + `Offer` + `PriceObservation` | migration M-03..M-06 | — | `capturedAt` = `observedAt`; status/availability are observations, not validity ends |
| `ListingMetadata` | live | **split** | `ListingEdgeProperties` (= `AssertedEdgeProperties` + `appointmentRequiredOverride`) | rel-props | `listRole` → role types; `localPriceAmount/Currency` → PriceObservation; `notes` dropped |
| `Product.offeredBy` / `Organization.offersProducts` (`OFFERS`, RoleMetadata) | live | **seam → derive**: legacy read-only (W04 keeps `Product.offeredBy`), successor `SELLS_PRODUCT` derived from `SELLER_OF_RECORD_FOR`; brand-owner "offers" → `MARKETS_PRODUCT` (W01 advice) | — | legacy / derived | "offers" is ambiguous between marketing and selling |
| `MediaSource.sourceListing` (`SOURCE_LISTING`) | live | **keep** (W22 owns the edge; target type renamed) | → `MerchantListing` | structural | |
| `MerchantListing` | cat | **keep, refine** | | Entity | + `marketplace`, `parentListingRef`, `commercePlatform`, `marketplaceRegion` |
| `Offer` (cat; delta `Offer implements Entity`) | cat/delta | **keep, refine** to VersionedState labels and payload; `availability`, `observedAt` split into projection + payload capture time | `Offer` | VersionedState | delta's `onListing`, `sellerOfRecord`, `fulfilledBy`, `listedBy`, `priceObservations` kept with frozen property types |
| `PriceObservation` (cat; delta) | cat/delta | **keep, refine** | `PriceObservation` | Occurrence | + `unitQuantity/unitCode`, `priceTextVerbatim`, `conditionText`, `observationRegion`, `subscriptionPlanUid`, `sourceLocatorUid`, `captureMethod`; immutable (`@mutation(CREATE)`) |
| `SubscriptionPlan` | cat | **keep, refine** | | VersionedState | `interval`, `intervalCount`, `sellingPlanId`, `terms`→`termsText`; + `planGroupName`, `planName`, `intervalOptionsText`, `planProvider`, `priceAdjustmentText`, `minimumCommitment*` |
| `Bundle`, `BundleComponent` | cat | **keep, refine** | | Entity / VersionedState | `quantityStatus` (ReportedStatus) keeps unknown count apart from zero |
| `InventoryItem` | cat | **keep** (fragment; maturity CANDIDATE) | | Entity | + `merchantOrganizationUid` (scope of the key) |
| `IndividualUnit` | cat | **keep** (fragment; maturity CANDIDATE) | | Entity | public-actor units only; + printed lot/expiry text, `acquisitionContext` |
| `AffiliateLink` | cat | **keep, refine** | | InformationArtifact | `trackingParameter` = name; + `trackingValue`, `affiliateProgram`, `anchorText`, `sourceLocatorUid` |
| `CommerceMatch` | cat | **keep, extend use** | | EvidenceAssessment | `matchKind` adds RECALL_SCOPE and AUTHORIZED_CHANNEL (OPEN-QUESTIONS quality/commerce 5) |
| `PriceKind` | cat conventions; delta enum | **keep frozen** | `PriceKind` | enum | five values |
| `offerKind` | cat property | **refine** to enum | `OfferKind` (candidate values) | enum | old fixture value `NEW_ONE_TIME` → `PURCHASE` + `itemCondition NEW` |
| availability strings | cat `availability`, `availabilityObserved` | **refine** to enum | `ObservedAvailability` (candidate) | enum | |
| `LISTING_FOR` | cat | **keep, extend range** to `Bundle` (W15-SR-07) | `ListingTarget` union | asserted | |
| `HAS_OFFER`, `HAS_PRICE_OBSERVATION`, `HAS_BUNDLE_COMPONENT`, `LINKS_TO`, `MATCHES_COMMERCE_ITEM` | cat | **keep** | | structural | `MATCHES_COMMERCE_ITEM` range extended (`CommerceItemTarget`) |
| `HOSTS_LISTING`, `LISTS_OFFER`, `SELLER_OF_RECORD_FOR`, `FULFILLS_OFFER`, `AFFILIATE_FOR_OFFER`, `USES_SUBSCRIPTION_PLAN`, `COMPONENT_PRODUCT`, `INVENTORY_INSTANCE_OF`, `UNIT_FROM_LOT` | cat | **keep** | `AssertedEdgeProperties` | asserted | `COMPONENT_PRODUCT` range + PackageConfiguration; `INVENTORY_INSTANCE_OF` range + Bundle |
| `SELLS_PRODUCT` | cat | **keep** (derived, mustBeRegenerable) | `DerivedEdgeProperties`; field text in W15-SR-01/02 | derived | only from ACCEPTED `SELLER_OF_RECORD_FOR`; identity licence cited in `derivedFromAssessmentUids` |
| `IDENTIFIED_BY` (MerchantListing → TradeItemIdentifier) | cat | **use** (relationship owned by W04) | `MerchantListing.tradeItemIdentifiers` | asserted | |
| forbidden `[HOSTS_LISTING|FULFILLS_OFFER|AFFILIATE_FOR_OFFER|LISTS_OFFER, SELLS_PRODUCT]`, `[LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]`, INV-306 | cat | **keep verbatim** | V-326a/b/c, V-W15-01, V-W15-04, V-W15-06 | — | negative fixtures N1–N4, N7, N10, N11 |
| `AssertedTemporalMetadata` (delta) | delta | **retire** | `AssertedEdgeProperties` (W00) | — | delta type mixed asserted and derived citations |
| `ListingTarget`, `CommerceItemTarget` | registry (new) | **add** | unions | — | |

## 3. Identity, state, artifact, occurrence

| Thing | Archetype | Identity key / payload | Why |
|---|---|---|---|
| MerchantListing | Entity | `(marketplace, merchantListingId)` unique when both present; uid opaque | a catalog entry persists while its title, price and sellers change |
| Offer | VersionedState | payload `(offerKind, currency, itemCondition, termsText, sellerOfferRef)`; one per (listing, seller of record, condition, purchase mode) | a proposition with immutable terms; terms change → new state; price/availability are not payload |
| PriceObservation | Occurrence | instant `observedAt` + `priceKind` + offer + locator | something that was displayed once; never edited |
| SubscriptionPlan | VersionedState | platform plan id + interval + terms | a plan configuration; terms change → new state |
| Bundle | Entity | merchant kit SKU / GTIN via HAS_IDENTIFIER | a sellable combination that outlives any one listing |
| BundleComponent | VersionedState | (component item, quantity, quantityStatus, role) | kit composition can change |
| InventoryItem | Entity | `(merchantOrganizationUid, merchantInventoryId)` | merchant stock record |
| IndividualUnit | Entity | serial number when present, else uid | a physical thing |
| AffiliateLink | InformationArtifact | URL as observed (contentHash) | a published string |
| CommerceMatch | EvidenceAssessment | method + compared records | a BellLabs judgement with method and status |

## 4. Decisions that shape the model (detail and alternatives in 05)

1. **Listing granularity** = the most specific merchant catalog entry (ASIN; Shopify variant; Walmart item). Parent pages are `parentListingRef`. Several sellers on one entry = one listing, several offers (S4).
2. **Roles are separate asserted edges per offer**, one assertion each; the same organization may hold several roles (Amazon hosts and fulfils B0FS82B35K; hosts, sells and fulfils its own B000QSNYGI offer). `SELLS_PRODUCT` is derived only from ACCEPTED `SELLER_OF_RECORD_FOR` and reaches its target only through a current `LISTING_FOR` licensed by an ACCEPTED SAME_ITEM `CommerceMatch` (V-W15-01).
3. **Offer existence in time** is carried by the valid time of its role edges (`validFrom` null with basis OBSERVATION_ONLY, `validTo` null UNKNOWN) and by its observations; answers use KNOWN_ENDED / UNKNOWN_START / OPEN_END_SUPPORTED / OPEN_END_STALE (Q-W15-05). Not observed ≠ ended (CQ-CM-05).
4. **Prices are observations**, one per displayed kind; disagreeing captures (JSON plan vs rendered page; LLM quote vs structured data) are both kept with `captureMethod` (V-W15-11 review queue). A coupon text without an amount yields no `COUPON_ADJUSTED` row.
5. **Listing identity is never silent**: `LISTING_FOR` is asserted; "resolved" additionally needs an ACCEPTED SAME_ITEM `CommerceMatch`; no product identity → no `LISTING_FOR` + an UNRESOLVED `CommerceMatch` (Walmart 1038593372: displayed UPC 850015311116 ≠ brand GTIN 850015311857).
6. **Listing title amounts** are `LISTING_TITLE_AMOUNT` literal assertions on the listing (predicate candidate), never `LabelDeclaration`/`QuantityDeclaration` (V-W15-04).
7. **Seller display accounts are W01 Organizations without the LegalEntity label**, carrying the marketplace merchant id as an `Identifier` and a `ResolutionHypothesis` to a legal entity (rules W01-SR-15b; no commerce-account node).
8. **Recalled / expired / counterfeit / gray-market** are `CommerceMatch` candidates (`RECALL_SCOPE`, `AUTHORIZED_CHANNEL`) with supporting locators, never properties (V-W15-07). Closes the representational half of OPEN-QUESTIONS quality/commerce 5; the evidence thresholds stay open.
9. **Provenance of occurrences**: `PriceObservation`/`AffiliateLink` carry `sourceLocatorUid` (string reference, same pattern as `SourceLocator.mediaAnnotationUid`) because catalog `SUPPORTED_BY` and `WAS_GENERATED_BY` domains exclude them; kernel request W15-SR-09.
10. **LISTS_PRODUCT inconsistency (OPEN-QUESTIONS live-stack 5)**: the live edge is read through property-less, read-only fields on both sides (`MerchantListing.legacyListsProducts`, W04 `Product.listedIn`), so the final API never depends on which property set was stored; the successor is `LISTING_FOR`. The stored property set itself can only be read on the deployed database (`MATCH ()-[r:LISTS_PRODUCT]->() RETURN DISTINCT keys(r)`, 07-operations section 5); fixture 08 shows the migration on a TemporalMetadata-shaped edge.

## 5. Alternatives considered (rejected)

| Alternative | Failing case |
|---|---|
| Keep `Listing` + `LISTS {listRole}` as the role record | B0FS82B35K: one org (Amazon) holds two roles and another holds a third; a string role on one edge cannot carry two roles with separate evidence and time (round 0005 C9). |
| Price, currency, availability as Offer properties | Same offer shows $49.00 one-time, $44.10 and $41.65 subscription and $1.63/count at one instant (S1); a later capture shows something else. Properties would overwrite or average. |
| One listing per product page (Shopify parent product) | The page sells 30/90/180 with different barcodes and one of them is a kit (S6): `LISTING_FOR` would point at three items. |
| Separate `SellerAccount` node type | Adds a type for something W01's Organization already represents (a non-legal organization with an Identifier and a ResolutionHypothesis); W01-SR-15b asked W15 to decide; the smaller model wins. |
| Recall/gray-market flags as booleans | A brand statement of Feb 2026 ("no authorized resellers on Amazon.com") does not establish the status of a September offer; a printed code does not establish the lot. Booleans erase the evidence and the uncertainty. |
| `AFFILIATE_FOR_LISTING` relationship | Not in the catalog; the AffiliateLink → listing structural edge already answers CQ-CM-04; AFFILIATE_FOR_OFFER targets the offer observed behind the link (placeholder offer when the seller was not captured). |
| Derive `SELLS_PRODUCT` from `SELLER_OF_RECORD_FOR` alone (V-326c only) | N11: Sports-Med is seller of record on Walmart 1038593372 but the listing's product identity is unresolved; V-326c passes, V-W15-01 rejects. |

## 6. Smallest recommended model

Ten node types (all catalog), one relationship-property type (`ListingEdgeProperties`), three enums (`PriceKind` frozen, `OfferKind` and `ObservedAvailability` candidate values), two unions, nineteen relationship types (all registry), no new kernel type. Three groups of catalog range extensions (`LISTING_FOR`/`INVENTORY_INSTANCE_OF` → Bundle; `COMPONENT_PRODUCT` → PackageConfiguration; `MATCHES_COMMERCE_ITEM` → Offer, IndividualUnit, PackageConfiguration, Bundle, ProductLot, Organization) and one predicate registration (`LISTING_TITLE_AMOUNT`) go to the ledger (seam-requests.yaml). `InventoryItem` and `IndividualUnit` are in the fragment with maturity CANDIDATE because fixture 06 and W12's `SAMPLE_FROM` need them.
