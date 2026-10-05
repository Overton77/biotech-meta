# W15 Operations

No runtime implementation is proposed here; this is what the operations file, the ingestion service and the projection job must do for commerce. Statements: `operations.cypher` (applied on 5.26.31 Community on 2026-10-04: 32/32 statements OK; Enterprise block not run).

## 1. Uniqueness and indexes (stored property names; W15 introduces no `@alias`)

| Purpose | Statement (operations.cypher) | Edition | Verified |
|---|---|---|---|
| uid unique per W15 primary label (10 labels) | `w15_*_uid` | Community | applied |
| live `id` unique (MerchantListing, Offer, PriceObservation) | `w15_*_id` | Community | applied |
| one listing per merchant key | `REQUIRE (n.marketplace, n.merchantListingId) IS UNIQUE` | Community (composite property uniqueness) | applied; duplicate rejected |
| one inventory record per merchant key | `REQUIRE (n.merchantOrganizationUid, n.merchantInventoryId) IS UNIQUE` | Community | applied |
| page join, parent grouping | `w15_listing_canonical_url`, `w15_listing_parent_ref` | Community | applied |
| freshness and price scans | `w15_price_observed_at`, `w15_price_kind`, `w15_offer_last_observed` | Community | applied |
| provenance joins | `w15_price_locator`, `w15_affiliate_locator` (string uid references, W15-SR-09) | Community | applied |
| plans, affiliate tags, matches, printed lot codes | `w15_plan_selling_plan_id`, `w15_affiliate_tracking`, `w15_commerce_match_kind`, `w15_unit_lot_code` | Community | applied |
| episode lookup | relationship indexes on `relationshipUid` / `assertionUid` for SELLER_OF_RECORD_FOR, LISTING_FOR, HOSTS_LISTING, FULFILLS_OFFER | Community | applied |
| fulltext `ListingSearch` / query `searchListings` (D-015 names kept) | fields name, description, searchText, title, listingType, status, canonicalUrl, availabilityStatus, commercialTermsSummary | Community | applied |
| existence/type constraints (amount, currency, observedAt, priceKind, payloadHash, matchKind; SoR/LISTING_FOR assertionUid, recordedFrom; relationship key) | commented block | **Enterprise only** | not run; Community relies on the service plus V-328, V-W15-02, V-W00-08 |

Note: fulltext over `availabilityStatus` and `commercialTermsSummary` indexes projections; a fulltext hit on them is a retrieval candidate, never an availability answer (live-schema-alignment row on indexed commercial state).

## 2. Retrieval patterns

| Pattern | Path | Cost note |
|---|---|---|
| Roles on a listing (CQ-CM-01) | uid → `HAS_OFFER` → offer ← role edges (filter `recordedTo IS NULL` or R-window) | bounded fan-out (offers per listing small; B000QSNYGI = 4) |
| Price history of an offer (CQ-CM-03) | offer → `HAS_PRICE_OBSERVATION` → observations ordered by `observedAt` | grows with crawl frequency: see section 4 retention |
| Offers for a variant (CQ-CM-02) | variant → (`HAS_PACKAGE_CONFIGURATION`)? → item ← `LISTING_FOR` ← listing (+ CommerceMatch check) | the CALL/UNION shape in Q-W15-04 also returns unresolved candidates |
| Offer validity at (V, R) (CQ-CM-05) | observations with `createdAt <= R`, role edges in R-window | Q-W15-05; never infer an end from absence |
| Who sells product P | `SELLS_PRODUCT` (derived; regenerate) — or the authoritative path SoR → offer → listing → LISTING_FOR + CommerceMatch | the derived edge is a cache; answers cite the SoR assertion |
| Affiliate links in a source (CQ-CM-04) | Source → snapshot → locator ← `AffiliateLink.sourceLocatorUid` → `LINKS_TO` | index `w15_affiliate_locator` |
| Candidates for recall / unauthorized channel | `CommerceMatch {matchKind}` → items, `SUPPORTED_BY` locators | index `w15_commerce_match_kind` |

## 3. Application validation, transactions, concurrency

1. **Write order per capture** (one transaction per listing capture): Source (MERGE by canonicalUri) → SourceSnapshot (CREATE, immutable) → SourceLocators → MerchantListing (MERGE by `(marketplace, merchantListingId)`) → Offer per seller (MERGE by `(listing uid, seller org uid, itemCondition, offerKind)` — the service computes the uid deterministically from these, the payload hash from the payload) → role Assertions + adjudication policy → asserted edges (MERGE by `relationshipUid`) → PriceObservations (CREATE; never MERGE on amount) → projections.
2. **Service-enforced rules** (Community cannot): closed enums PriceKind/OfferKind/ObservedAvailability (V-328, V-W00-09 detect); at most one open SELLER_OF_RECORD_FOR per offer (V-327) — a new seller on the same proposition closes the old episode (`VALIDITY_BOUNDED` only if the page states the change; otherwise the old episode stays open and a new Offer is created because the seller is part of offer identity); `SELLS_PRODUCT` written only by the projection job (V-326a/c, V-W15-01); no recall/gray/counterfeit property (V-W15-07); `QuantityDeclaration` only under a `LabelSnapshot` (V-W15-04); PriceObservation requires `sourceLocatorUid` (V-W15-08).
3. **Projection job** (idempotent, re-runnable): for each Offer, `availabilityStatus/first/lastObservedAt/projectedFromPriceObservationUid` from its observations recorded so far; for each MerchantListing, the latest ONE_TIME observation (else latest of any kind, with `priceKindProjected` set) → `priceAmount/currency/availabilityStatus/capturedAt/lastObservedAt/currentAsOf`. `SELLS_PRODUCT`: delete all edges with `derivationRule = 'w15-sells-product-from-seller-of-record/v1'` for the affected organization and regenerate from the rule in 04-model-cards.md. Concurrency: the job takes the listing's uid as a lock key (optimistic retry on `TransientError`); projections are never written by GraphQL (`@settable(false,false)`).
4. **Conflicting captures**: never resolve by recency alone; V-W15-11 enqueues a review; a CAPTURE_FIDELITY review of an LLM-extracted price creates no supersession of the occurrence (occurrences are immutable) — it is recorded as an Adjudication on any Assertion that cites the price, and the bad observation can be excluded by `captureMethod` filters.
5. **Idempotence**: re-running a capture with the same snapshot hash creates no new snapshot, locators, assertions or observations (MERGE keys: snapshot uid from source + retrievedAt; observation uid from offer + observedAt + priceKind + plan).

## 4. Lifecycle, retention, ingestion overhead

- Per capture of one listing: 1 snapshot, ~5–15 locators, 1 listing, n offers, ~3n role assertions + adjudications + edges, 1–5 price observations per offer. B0FS82B35K: 111 statements; B000QSNYGI (4 offers): 118. A daily crawl of 10,000 listings at ~2 offers each ≈ 50,000 PriceObservations/day.
- **Retention proposal** (no decision taken here; W23 policy): keep every observation whose amount, kind, availability or condition differs from the previous observation of the same offer and kind; for unchanged values keep the first and the latest of a run and record the run length on the latest (`description`) — this preserves OPEN_END answers (the latest observation) and change points (CQ-CM-03) while bounding growth. Needs a ruling because it trades raw observation density for size.
- Offers are never deleted when not observed (CQ-CM-05); an offer ends only by a source-stated bound on its role edges.
- AffiliateLink, PriceObservation, SourceSnapshot are immutable (`@mutation(CREATE)` on the first two in SDL).

## 5. Migration and compatibility (statements exercised by fixture 08)

| Step | Statement (shape) | Notes |
|---|---|---|
| M-01 | `MATCH (l:Listing) WHERE l.uid IS NULL SET l.uid = 'hu:listing:' + l.id, l:MerchantListing:Entity, l.entityType = 'MerchantListing', l.canonicalUrl = coalesce(l.canonicalUrl, l.url)` | then re-create `ListingSearch` on canonicalUrl; remove `Listing` label after clients move |
| M-02 | relabel/uid for Organization, Product endpoints | owned by W01/W04 migrations; shown in fixture for self-containment |
| M-03 | each `ListingSnapshot` → `Source` (MERGE per URL) + `SourceSnapshot` (`observedAt = capturedAt`, `retrievedAt = createdAt`, `contentHashBasis SYNTHETIC_FIXTURE`, `captureCompleteness UNKNOWN`) | no bytes were ever kept; the snapshot is a placeholder for provenance, not a reproducible capture |
| M-04 | each `LISTS {listRole}` → Offer per (listing, org) + PROPOSED role assertion + edge; snapshot prices → PriceObservation (`captureMethod LEGACY_MIGRATION`) | no ACCEPTED status without a capture; no locator (V-W15-08 reports informational) |
| M-05 | listing projections name the backing observation | V-329 / V-W15-03 pass afterwards |
| M-06 | `ListingSnapshot` → label `LegacyListingSnapshot`, `HAS_SNAPSHOT` deleted | audit trail kept outside the API |
| M-07 (deployment only) | `MATCH ()-[r:LISTS_PRODUCT]->() RETURN DISTINCT keys(r) AS storedKeys, count(*)` | answers OPEN-QUESTIONS live-stack 5; whatever the result, the final API reads LISTS_PRODUCT without properties; successor LISTING_FOR is created only by review (CommerceMatch) |

Compatibility: GraphQL type `Listing` disappears (D-007); clients query `merchantListings`; `searchListings` keeps its name. Live fields `priceAmount`, `currency`, `availabilityStatus`, `capturedAt`, `currentAsOf`, `commercialTermsSummary` keep names but become read-only. `Listing.offeredBy` → `MerchantListing.legacyListedBy` (read-only); `Listing.listsProducts` → `legacyListsProducts` (read-only, no edge properties); `Listing.snapshots` removed. Mutation inputs for MerchantListing no longer accept the projection fields (non-additive change; flagged to Fable).

## 6. Capability and edition conditions

- **Community 5.26.31 (verified)**: all node/relationship uniqueness, composite uniqueness, range and fulltext indexes in `operations.cypher`; all validation queries (including `CALL { WITH n … }` subqueries, `EXISTS {}` with outer variables, `duration.inSeconds`).
- **Enterprise (unverified)**: property existence/type constraints and relationship keys listed in the commented block.
- **APOC**: required by `@neo4j/graphql` 7.6.3 to read any `DateTime` field (`apoc.date.convertFormat` in generated Cypher; observed failure without APOC) → W15-SR-16. Reads without DateTime fields, including union relationship fields with properties, worked.
- **@vector**: none proposed by W15 (no retrieval justification beyond fulltext; listing embeddings would mirror product embeddings owned by W04).
