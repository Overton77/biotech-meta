# W15 Completion report

- **Worker**: W15 Commerce and access to products. **Model**: Opus 5.5 (`claude-opus-5-5`). **Coordinator**: Fable 5.1.
- **Start**: 2026-10-04 ≈01:08Z (first read of the run files; session clock). **End**: 2026-10-04 ≈02:01Z.
- **Write scope respected**: only `workers/W15/`. No edits to the live schema, catalog, rounds, CHANGELOG, OPEN-QUESTIONS, other workers' directories or the run's numbered files. Nothing committed.

## Tools actually used

| Tool | Use | Availability |
|---|---|---|
| Read/Bash/grep over the repository | authority files, live lines 114–174 / 496 / 550–562 / 765–785 / 835–845 / 878–928 / 2181–2510, catalog module and conventions, rounds, validation suite, examples, W00/W01/W04/W06/W07/W12/W20/W22 fragments and seam files | available |
| Firecrawl `firecrawl_scrape` (maxAge 0) | S1–S9, S11 (Amazon, Walmart, truniagen.com JSON and page, fastlifehacks, FDA) | available; capture instants decoded from UUIDv7 scrape ids |
| Firecrawl `firecrawl_search` | discovery (S10, S12, S13) | available |
| `curl` through the session proxy | truniagen.com / elysiumhealth.com JSON | **BLOCKED** (`CONNECT tunnel failed, response 403`); recorded, not read as absence |
| Tavily, WebFetch/WebSearch, PubMed, ClinicalTrials.gov, bioRxiv, ICD-10, NPI | not needed for commerce questions | not used |
| Embedded Neo4j 5.26.31 Community (`validation/harness/EmbeddedNeo4j.java`, run dir in scratchpad) + `run-cypher.mjs`, `query.mjs` | fixtures, catalog suite, W00 suite, W15 suite, queries, operations | available; instance stopped at the end |
| `@neo4j/graphql` 7.6.3 / graphql 16.14.2 (`build-schema.mjs`, `merge-fragments.mjs`, a read round-trip script) | parse/build of the fragment with stubs; merge check against all present fragments (no W15 duplicates, no W15 undefined references); GraphQL reads | available; DateTime reads need APOC (W15-SR-16) |

## Deliverables

All eight deliverables exist with the fixed names: `01-domain-recommendation.md`, `02-cq-coverage.md`, `03-source-manifest.md`, `04-model-cards.md`, `sdl-fragment.graphql`, `migration-map.yaml` (46 rows), `05-decision-seam-ledger.md` + `seam-requests.yaml` (15 requests), `06-fixtures-and-queries.md` + `fixtures/*.cypher` (9 fixture files, validation and query files, generator), `07-operations.md` + `operations.cypher`, this report.

Fragment contents: 10 node types (MerchantListing, Offer, PriceObservation, SubscriptionPlan, Bundle, BundleComponent, InventoryItem, IndividualUnit, AffiliateLink, CommerceMatch), 1 relationship-property type (ListingEdgeProperties), 3 enums (PriceKind, OfferKind, ObservedAvailability), 2 unions (ListingTarget, CommerceItemTarget); 19 relationship types realized as fields on W15 types or supplied as field text for W01/W04/W07/W12 types. Banner names worker, module, CQs and digest `8fb50ff0…84f0`.

## Mandatory research items (task brief)

| Item | Result |
|---|---|
| Amazon detail page with "Ships from / Sold by", host ≠ seller ≠ fulfiller | S1 captured first-party (2026-10-04T01:19:18Z): "Ships from: Amazon Sold by: TRU NIAGEN", merchant A1W0QC6JE0QLDF, isAmazonFulfilled=1. Host and fulfiller are the same party in two roles; seller differs. No captured page showed three different parties (S4 shows every two-way split); recorded as unresolved in 05. |
| DTC subscription offer with selling-plan terms | S6 Shopify JSON reached: selling_plan_group "Subscribe and Save", four plans, app `ordergroove-subscribe-and-save`, `price_adjustments: []`; S7 rendered page shows "Save 20%" ($39.20) — modeled as two observations. |
| Marketplace page merging several sellers under one listing | S4 Amazon B000QSNYGI: four offers, four sellers, three fulfillers on one ASIN. |
| Affiliate link with tracking parameter (public blog) | S9 fastlifehacks.com: `tag=partnerid1275-20` links to B0CLQZHVHL and the two-bottle B07Y2ZGM48; disclosure snippet S10. |

Mandatory fixtures: host/fulfiller/seller distinct with SELLS_PRODUCT only from SELLER_OF_RECORD_FOR (fixture 01, 02) and a HOSTS_LISTING-derived SELLS_PRODUCT failing V-326c (N1, observed); listing merge (02); PriceObservation with priceKind and an OPEN_END_STALE answer (01, 04; Q-W15-05); listing-title amount that must not become a label-declared amount (05 + N7, V-W15-04 observed); listing without product identity kept as unresolved CommerceMatch (04; Q-W15-04); recalled/gray-market inventory flagged as candidate (06; Q-W15-09). All run.

## Research gaps

- No three-distinct-party Amazon offer captured; a 3PL-fulfilled offer would complete the set.
- The Walmart $19.90 vs $45.00 discrepancy is unexplained (LLM extraction vs structured data, different sessions).
- Tru Niagen 30-count UPC 850015311116 (Walmart) vs 850015311857 (brand JSON) not resolved (needs a GS1 or label record; W04).
- DTC merchant of record (truniagen.com terms of sale) not captured.
- Brand authorized-reseller lists for Tru Niagen not captured; recall evidence thresholds are policy (W23) and recall records W13's.
- Only two captures hashed over local bytes; other snapshots carry SYNTHETIC_FIXTURE hashes.

## Unresolved seams (see seam-requests.yaml)

W15-SR-01 (W01 field slots + seller-account ruling), -02 (W04 inverse fields), -03 (W12), -04 (W07), -07 (catalog range extensions), -08 (uid tokens), -09 (kernel provenance for occurrences), -10 (enum registration), -11 (LISTING_TITLE_AMOUNT predicate; V-101 and V-112 parameter gaps observed in the run), -12 (W23 private contract), -13 (W13 recall records), -14 (W21), -15 (SourceKind values), -16 (APOC prerequisite for DateTime reads).

## Confidence

| Dimension | Confidence | Basis |
|---|---|---|
| Role split and SELLS_PRODUCT rule | high | first-party captures S1/S4; negative cases observed failing as expected; V-W15-01 closes the gap V-326c leaves |
| Price as observation, kinds, conflicts | high | S1, S6–S8; run queries |
| Listing granularity and bundles | medium-high | S2, S5, S6; W04 boundary text agrees; range extensions need the ledger |
| Offer existence / OPEN_END classes | medium-high | consistent with W00 V-105 and QS-2; recorded-time filter uses PriceObservation.createdAt (service commit time), to be confirmed by W00 |
| Recall / gray-market candidates | medium | representation settled; evidence thresholds open; the marketplace part of the case is synthetic |
| Affiliate attribution | medium | tag-to-person link rests on a search snippet; kept PROPOSED |
| GraphQL viability | high for build and non-DateTime reads; DateTime reads blocked without APOC | build + round-trip run |
| Enterprise constraints | unverified | Community only |

## Review status

Self-checked only (no independent reviewer in this wave). Run evidence: positive load 0 violation rows across the catalog, W00 and W15 suites; negatives N1–N11 produce exactly the expected rows (N10 not caught by V-112, recorded); operations 32/32 on Community; fragment builds with stubs.

## What remains qualified

`InventoryItem` and `IndividualUnit` are CANDIDATE maturity; `OfferKind`, `ObservedAvailability` values and the CommerceMatch vocabularies await ledger registration; `sourceLocatorUid` awaits the kernel ruling; the retention proposal (07 section 4) is not a decision.

## Artifact digests (SHA-256, computed before this report was written)

| Path (relative to `workers/W15/`) | SHA-256 |
|---|---|
| `01-domain-recommendation.md` | `fe415c78fa11a8b40d3fc9f98c185d90a6343d50b0ce0392bff965ae968282d5` |
| `02-cq-coverage.md` | `3cca545c32bcf7f4463e4f6e159e47a0cfde7d7f8cb051b8b5d5cec1f8c036c7` |
| `03-source-manifest.md` | `1fc2dea7ca550543de325a0205ca88e6cedd19b43a27e986506adc0d5134c71f` |
| `04-model-cards.md` | `bd6206afe51a6d4aa535786ce055e53652e475fa71aa1171ff5d253681fde461` |
| `05-decision-seam-ledger.md` | `c2d34b29a15cc436480e4f4b92b578c7fbbb045b3674a769b16a58727f843c90` |
| `06-fixtures-and-queries.md` | `72c53f34ddb944361cb229404e39d9046355d4656a8a5216601a7a523907514b` |
| `07-operations.md` | `968941a6b429187fe9c1f27a22318e139e6adea45759739d978e85013fc80387` |
| `fixtures/gen/cy.py` | `ce16c6a9dd93d21a4da417cf274c0333862b2f6bbe700b6344148e12ae96be87` |
| `fixtures/gen/gen.py` | `ee96259255bb24b08eda0c89cca7621ab64215cb9e39952cb38ef86f6d2e8b9d` |
| `fixtures/w15-00-common.cypher` | `3ea4ef8d4d156dedb9ddb5f3bacf9d3ac6864247e957b8fcc8ea2e36797084d2` |
| `fixtures/w15-01-amazon-host-seller-fulfiller.cypher` | `60ad78b6407630cf4093371eec77fdc0f508c1e09a81c8c696564e092a585c0b` |
| `fixtures/w15-02-listing-merge-four-offers.cypher` | `744b9de23812843505596dec9c54c07b20837d68c962167f8b9ea9e0789f6fdc` |
| `fixtures/w15-03-dtc-subscription-and-bundles.cypher` | `c98c8a3a2886c62c289c4739cbb9305540e64b28b087460c13516ddf09915a19` |
| `fixtures/w15-04-walmart-price-conflict-open-end-unresolved.cypher` | `47b6a786db7df4c8c274f9e8e7acc03e502fbff71ba6621bc0f648835db5a55b` |
| `fixtures/w15-05-affiliate-and-title-amounts.cypher` | `2148165460a638104ca5a1eca065d3c7300c8e3c07857c83c75ae981e4a07c4b` |
| `fixtures/w15-06-recall-and-unauthorized-channel-candidates.cypher` | `373c1b9bbbfd2ce448efa2c5971eac158a7e636931c8b70165dec722239a3c27` |
| `fixtures/w15-07-negatives-must-fail.cypher` | `1d470291f9a99938707555549a840510b91d92278e1f6fb47330d3c19e378ae5` |
| `fixtures/w15-08-legacy-listing-migration.cypher` | `1fdbc1cd70c14c9e6a3ab3d8318da50343cb5211d8c598cabf95ac5bee03b62b` |
| `fixtures/w15-queries.cypher` | `18be6f4a86b7839eed3a9c72372c7dd6c084be25a53d04e2af86660e365f6eec` |
| `fixtures/w15-validation.cypher` | `07fe34a155e4ae8a3ab1e03a5b0e45974f651e8d827bef788dcb0d01fc9936fd` |
| `migration-map.yaml` | `da7b8fb7c88509c1ede55702662f688bb540816d365a74610e1715bdb084723f` |
| `operations.cypher` | `740cd1d6d6eba49bd59905f9cc2666e5a0262a7bc0b71f3bfe0b64dd89a9f561` |
| `sdl-fragment.graphql` | `035f5bc56d665f4903b8255d8ddae1e238b4858136f27688a818f4ae3bd3907c` |
| `seam-requests.yaml` | `7c2b31c5430549b323dbd36b228c78c4d39345f2219ee8174aac6314cd223ec2` |
