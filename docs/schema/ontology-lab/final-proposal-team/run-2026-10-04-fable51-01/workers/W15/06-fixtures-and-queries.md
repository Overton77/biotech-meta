# W15 Fixtures and queries

**Execution status: RUN.** All fixtures, the catalog validation suite (`docs/schema/neo4j/validation.cypher` with `validation/validation-params.json`), W00's `validation-w00.cypher`, `fixtures/w15-validation.cypher`, `fixtures/w15-queries.cypher` and `operations.cypher` were executed on an embedded Neo4j **5.26.31 Community** instance (in-process harness of `validation/harness/EmbeddedNeo4j.java`, run directory in the session scratchpad) on 2026-10-04 between 02:10Z and 02:40Z, with the harness's `run-cypher.mjs` (one transaction per statement, no variable shared across `;`). Enterprise behaviour is not verified. The SDL fragment was parsed and built with `@neo4j/graphql` 7.6.3 / graphql 16.14.2 against stubs of the imported types (generated 1,382 types), and a GraphQL read round-trip was run against the loaded data (section 5).

## 1. Files

| File | Content | Records | Real / synthetic |
|---|---|---|---|
| `fixtures/w15-00-common.cypher` | organizations (marketplace operators, seller display accounts, legal entities), one public person, agent/activities, seller identifiers, STUBS of W04 identities (variants, packages, HAS_PACKAGE_CONFIGURATION/HAS_VARIANT stub assertions) and one W12 lot | 59 statements | real names/ids from S1, S4, S8, S9, S11; stubs marked |
| `fixtures/w15-01-amazon-host-seller-fulfiller.cypher` | B0FS82B35K: host, seller of record, fulfiller as separate asserted roles; Subscribe & Save plan; four price observations; ACCEPTED CommerceMatch; SELLS_PRODUCT derived for the seller account only | 111 | real (S1) |
| `fixtures/w15-02-listing-merge-four-offers.cypher` | B000QSNYGI: one listing, four offers, four sellers, three fulfillers; LIST vs ONE_TIME; Amazon SELLS_PRODUCT only from its own retail SoR | 118 | real (S4) |
| `fixtures/w15-03-dtc-subscription-and-bundles.cypher` | truniagen.com Shopify: listings per variant, four selling plans, JSON vs rendered subscription price, "180" kit Bundle with NOT_REPORTED count, "30/30" mixed kit, PROPOSED DTC seller of record (no SELLS_PRODUCT) | 288 | real (S5–S7) |
| `fixtures/w15-04-walmart-price-conflict-open-end-unresolved.cypher` | Walmart 1038593372: two disagreeing captures, OPEN_END classes, SYNTHETIC late archive capture, listing WITHOUT LISTING_FOR + UNRESOLVED CommerceMatch, NOT_DETERMINABLE authorized-channel candidate, seller display vs legal name | 99 | real (S8) + synthetic archive capture |
| `fixtures/w15-05-affiliate-and-title-amounts.cypher` | fastlifehacks affiliate links (tag=partnerid1275-20) to B0CLQZHVHL and the two-bottle B07Y2ZGM48 Bundle; PROPOSED AFFILIATE_FOR_OFFER by the author; placeholder offer with no seller; LISTING_TITLE_AMOUNT literal assertions (1000 mg, 300 mg, 300 mg, "Chloride, 300 mg") — no label declaration | 77 | real (S2, S9, S10) |
| `fixtures/w15-06-recall-and-unauthorized-channel-candidates.cypher` | Rosabella Moringa recall notice (lots, "no authorized resellers on Amazon.com"); SYNTHETIC Amazon listing/offer/inventory/unit; RECALL_SCOPE IN_SCOPE and AUTHORIZED_CHANNEL NO_AUTHORIZATION_FOUND candidates (PROPOSED), UNIT_FROM_LOT PROPOSED | 72 | real notice (S11) + synthetic commerce records |
| `fixtures/w15-07-negatives-must-fail.cypher` | N1–N11 (section 3) | 19 | synthetic |
| `fixtures/w15-08-legacy-listing-migration.cypher` | live-shaped `Listing`/`LISTS`/`LISTS_PRODUCT`/`ListingSnapshot` records and migration M-01..M-06 applied to them | 15 | synthetic |
| `fixtures/w15-validation.cypher` | V-W15-01 … V-W15-11 | 11 queries | — |
| `fixtures/w15-queries.cypher` | Q-W15-01 … Q-W15-11 (+03b) | 12 queries | — |
| `fixtures/gen/gen.py`, `gen/cy.py` | generator that wrote fixtures 00–08 (`python3 gen/gen.py`) | — | — |

Conventions honoured: every node carries its primary label and its archetype label (`MerchantListing:Entity`, `Offer:VersionedState`, `PriceObservation:Occurrence`, `AffiliateLink:InformationArtifact`, `CommerceMatch:EvidenceAssessment`, `Assertion`, …); every statement MERGEs/MATCHes its own nodes by uid; uids use registered tokens or the tokens requested in W15-SR-08; snapshots not hashed over real bytes use `contentHashBasis: 'SYNTHETIC_FIXTURE'`; the two hashed captures use the real sha256 (S5 NORMALIZED_TEXT, S8 RAW_BYTES of the capture). Every ACCEPTED assertion has a CAPTURE_FIDELITY adjudication (V-110) and a locator (V-401); every asserted edge carries `relationshipUid`, `assertionUid`, `recordedFrom` and both bases; observational role edges have `validFrom` null with basis OBSERVATION_ONLY and `validTo` null UNKNOWN (V-105). Load order: 00, then any of 01–06; 07 after 00–06; 08 alone.

## 2. Positive load (00–06): expected and observed validator results — RUN

| Suite | Rows (observed) | Meaning |
|---|---|---|
| catalog `validation.cypher` | 0 violation rows. Informational only: V-118 (11 label counts, all `missingUid 0`), V-401b `acceptedAssertionsWithOnlyCoarseLocators: 26` (JSON SECTION locators), V-514b `assertionsWithoutContentHash: 0` | clean |
| W00 `validation-w00.cypher` | 0 rows | clean (V-003 initially flagged the four title-amount assertions carrying both `valueNumber` and `valueString`; fixed by keeping `valueNumber`+`unitCode` only — literal-xor-object) |
| `w15-validation.cypher` | 0 violation rows. Informational: V-W15-05 ×5 (`SELLER_OF_RECORD_NOT_CAPTURED` for the Immune-kit offer and the B0CLQZHVHL placeholder; `LISTING_IDENTITY_UNRESOLVED` Walmart 1038593372; `LISTING_IDENTITY_NOT_ASSESSED` B0CLQZHVHL, B07TK5K5TQ); V-W15-11 ×2 (truniagen.com 30-count SUBSCRIPTION 49.00 RAW_STRUCTURED_DATA vs 39.20 LLM_DIRECT_QUOTE; Walmart ONE_TIME 19.90 LLM_DIRECT_QUOTE vs 45.00 RAW_STRUCTURED_DATA) | unknowns and conflicts stay visible |

## 3. Negative cases (07, loaded after 00–06): expected = observed — RUN

| Case | What it writes | Expected rows | Observed |
|---|---|---|---|
| N1 [HOSTS_LISTING, SELLS_PRODUCT] | Amazon SELLS_PRODUCT → Tru Niagen Beauty, input = HOSTS_LISTING assertion | V-326c, V-112 `FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS`, V-W15-01 (`INPUT_NOT_ACCEPTED_SELLER_OF_RECORD_OF_THIS_ORGANIZATION`, `TARGET_NOT_REACHED_THROUGH_RESOLVED_LISTING`), V-W15-06 (`HOSTS_LISTING`) | all four ✓ |
| N2 [FULFILLS_OFFER, SELLS_PRODUCT] | Amazon SELLS_PRODUCT → 300mg variant from FULFILLS_OFFER | V-326c, V-112, V-W15-01, V-W15-06 (`FULFILLS_OFFER`) | ✓ |
| N3 uncited SELLS_PRODUCT | Walmart SELLS_PRODUCT, no citation | V-326a, V-112 `NO_CITATION`, V-W15-01 `NO_SELLER_OF_RECORD_INPUT` | ✓ |
| N4 seller of record from fulfilment | unasserted Amazon SELLER_OF_RECORD_FOR on the B0FS82B35K offer | V-326b (`orgHostsTheListing true`, `orgFulfillsTheOffer true`), V-327 (two open sellers), V-101 (catalog and W00), V-W15-02 | ✓ |
| N5 averaged / non-catalog price kind | priceKind null; priceKind 'AVERAGE' | V-328 ×2, V-W15-08 `PRICE_WITHOUT_LOCATOR` ×2 | ✓ |
| N6 unbacked listing price | live-style `Listing` with priceAmount, no observation | V-329, V-W15-03 `PROJECTION_WITHOUT_BACKING_OBSERVATION` (+ V-W15-05 informational) | ✓ |
| N7 [LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT] | LabelDeclaration on the marketplace snapshot + QuantityDeclaration 1000 mg DERIVED_FROM_ASSERTION the title-amount assertion | V-W15-04 ×2 (`QUANTITY_DECLARATION_NOT_FROM_LABEL_SNAPSHOT`, `QUANTITY_DECLARATION_DERIVED_FROM_LISTING_TITLE`) | ✓ |
| N8 risk as property | `Offer.isGrayMarket`, `MerchantListing.recalled` | V-W15-07 ×2 `RISK_STATUS_AS_PROPERTY` | ✓ |
| N9 silent LISTING_FOR | LISTING_FOR without assertion (Walmart → 30-count) | catalog V-101 (params `assertedTypes`), V-W15-02 | ✓ (W00's hard-coded V-101 list misses LISTING_FOR → W15-SR-11b) |
| N10 [AFFILIATE_FOR_OFFER, ENDORSES_PRODUCT] | ENDORSES_PRODUCT derived from the affiliate assertion | V-W15-06; catalog V-007 and V-422; W00 V-101 | ✓ — **V-112 returned no row** (pair not in params → W15-SR-11c) |
| N11 right predicate, unresolved product | Sports-Med SELLS_PRODUCT → 300mg variant from its ACCEPTED SoR on the unresolved Walmart listing | V-W15-01 `TARGET_NOT_REACHED_THROUGH_RESOLVED_LISTING` only (V-326a/c pass) | ✓ |

## 4. Queries (positive load 00–06) — RUN; expected rows = observed

| Query | CQ | Expected / observed rows (abridged) |
|---|---|---|
| Q-W15-01 | CQ-CM-01 | 1 row: B0FS82B35K, offer `…tru-niagen-new`, hostedBy [Amazon], sellerOfRecord [TRU NIAGEN seller account], sellerAssertionStatus [ACCEPTED], fulfilledBy [Amazon], listedBy [] (not displayed), affiliates [], lastObservedAt 2026-10-04T01:19:18Z |
| Q-W15-02 | CQ-CM-01 minimal pair | Amazon: sellsProduct [ON Gold Standard Whey DRC (US)]; roles HOSTS_LISTING @ B0FS82B35K, B000QSNYGI, W15SYNASIN1; FULFILLS_OFFER @ B0FS82B35K, B000QSNYGI; SELLER_OF_RECORD_FOR @ B000QSNYGI. TRU NIAGEN account: sellsProduct [Tru Niagen Beauty (US)]; roles SELLER_OF_RECORD_FOR @ B0FS82B35K |
| Q-W15-03 | CQ-CM-03 | 4 rows: ONE_TIME 49.00 IN_STOCK; PER_UNIT 1.63 `{count}`; SUBSCRIPTION 41.65 (5+ items condition); SUBSCRIPTION 44.10 ("Save 10% now…"); all observedAt 2026-10-04T01:19:18Z, HTML_SELECTOR; no COUPON_ADJUSTED row |
| Q-W15-03b | CQ-CM-03 | 6 rows: truniagen 30-count ONE_TIME 49 (JSON) and 49 (page); SUBSCRIPTION 49 (JSON, plan "Delivered every month", declared adjustment `price_adjustments: []`) and 39.2 (page, "Save 20% on recurring orders."); Walmart ONE_TIME 19.9 (LLM_DIRECT_QUOTE 01:20:44Z) and 45 (RAW_STRUCTURED_DATA 01:21:32Z). The late archive row (created 2026-10-12) is excluded by the recorded-time filter |
| Q-W15-04 | CQ-CM-02 | 5 rows: truniagen 41905353850949 PackageConfiguration RESOLVED; 41905353883717 PackageConfiguration RESOLVED; 41905353916485 Bundle ASSERTED_ONLY (ACCEPTED); 44628427604037 Bundle ASSERTED_ONLY (ACCEPTED); walmart 1038593372 null `UNRESOLVED (candidate only)` (first observed 2026-10-02T15:00Z because this query filters valid time only) |
| Q-W15-05 | CQ-CM-05, CQ-AX-06 | Amazon offer V=2026-10-20 R=2026-10-21: OPEN_END_STALE, last 01:19:18Z. Walmart offer: (V=10-04T00:00, R=10-05) UNKNOWN_START; (V=10-04T01:21, R=10-05) OPEN_END_SUPPORTED; (V=10-04T00:00, R=10-13) OPEN_END_SUPPORTED, first observed 2026-10-02T15:00Z (late arrival visible only from R ≥ 2026-10-12); (V=10-20, R=10-21) OPEN_END_STALE, last 2026-10-04T01:21:32Z |
| Q-W15-06 | CQ-CM-04 | 2 rows: "Tru Niagen Pro" AMAZON_ASSOCIATES tag=partnerid1275-20 → B0CLQZHVHL, listingIsFor null, affiliate John Alexander, PROPOSED; "Tru Niagen" → B07Y2ZGM48, listingIsFor Bundle, affiliate null (offer not captured) |
| Q-W15-07 | CQ-AX-17 | 2 rows: truniagen 30-count $49 (last 01:18:46Z), 90-count $127 (01:18:33Z); listingTitleClaim null (DTC titles carry no amount); labelAmountSource "NO_LABEL_SNAPSHOT_IN_THIS_PACKET (W04 supplies label amounts)". Walmart and B07TK5K5TQ are absent (no resolved LISTING_FOR to the variant) — the query refuses to answer from titles |
| Q-W15-08 | listing merge | 1 row: listings 1, offers 4, distinctSellers 4, distinctFulfillers 3, minOneTime 102.81, maxOneTime 155 |
| Q-W15-09 | CQ-CM-C03 | 3 rows: AUTHORIZED_CHANNEL NOT_DETERMINABLE PROPOSED [Organization, Offer] support MARKETPLACE_LISTING (Walmart); AUTHORIZED_CHANNEL NO_AUTHORIZATION_FOUND PROPOSED [Organization, Offer] support REGULATORY_RECORD (Rosabella); RECALL_SCOPE IN_SCOPE PROPOSED [Offer, ProductLot, IndividualUnit] support AUDIT_REPORT + REGULATORY_RECORD |
| Q-W15-10 | CQ-CM-C01 | 4 rows (plans 1316552773 / 1341685829 / 1341718597 / 1341751365, MONTH ×1/2/3/6, declared `price_adjustments: []`); only the monthly plan has observed prices: ["39.2 (LLM_DIRECT_QUOTE)", "49.0 (RAW_STRUCTURED_DATA)"] |
| Q-W15-11 | CQ-AX-14 | 3 rows: Sports-Med (WALMART_SELLER_ID:E4E44D0D801E45C8A50F187A7AB1A8B0) → BLUE PEAK DISTRIBUTOR INC PROPOSED 0.8; TRU NIAGEN (AMAZON_MERCHANT_ID:A1W0QC6JE0QLDF) → ChromaDex UNRESOLVED 0.6; truniagen.com store operator (no id) → ChromaDex UNRESOLVED 0.7 |

Essential CQs covered by at least one run query: CQ-CM-01 (Q-W15-01/02), CQ-CM-03 (Q-W15-03/03b).

## 5. Other runs

| Run | Result |
|---|---|
| Legacy migration (08 alone) | 15 statements, 0 errors. After migration: catalog suite 0 violations (V-514b informational 1: the migrated review assertion has no contentHash, as a migration record); V-W15-05 `LISTING_IDENTITY_NOT_ASSESSED` (expected: LISTS_PRODUCT is never turned into LISTING_FOR automatically); V-W15-08 `LEGACY_UNLOCATED (informational)` for the migrated price |
| `operations.cypher` | 32 statements applied on Community (15 constraints incl. two composite uniqueness constraints, 16 range indexes, 1 fulltext); a duplicate `(amazon.com, B0FS82B35K)` listing was rejected: "Node(67) already exists with label `MerchantListing` and properties `marketplace` = 'amazon.com', `merchantListingId` = 'B0FS82B35K'" |
| GraphQL build | fragment + stubs of imported types: `graphql-js parse OK`, `Neo4jGraphQL build OK`, 1,382 generated types, 67 queries, 70 mutations |
| GraphQL read round-trip | `merchantListings` (with union `listingFor`, `offers{sellerOfRecord, fulfilledBy, priceObservations}`), `subscriptionPlans`, `commerceMatches{matchesItems}` (9-member union), `bundles{components{componentPackage}}`, `individualUnits`, `affiliateLinks` all resolved over the fixture data. Selecting any `DateTime` field failed: `Unknown function 'apoc.date.convertFormat'` (APOC not in the embedded harness) → W15-SR-16 |
