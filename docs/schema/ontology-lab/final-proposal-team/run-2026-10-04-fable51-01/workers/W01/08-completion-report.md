# W01 completion report

- Worker: W01 Actors and institutional ecosystem. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start: 2026-10-04T00:52:03Z. End: 2026-10-04T01:26Z.
- Wrote only inside `workers/W01/`. No authority file, catalog, live schema, other worker directory or numbered run file was edited.

## 1. Tools used and availability

| Tool | Use | Availability |
|---|---|---|
| Tavily search / extract | SEC proxy and 10-K excerpts, press release, Trademarkia, eCFR 21 CFR 101.5, 42 CFR 493.35, Sinclair page | connected; used |
| WebFetch | sec.gov, ecfr.gov | **BLOCKED** by egress proxy (EGRESS_BLOCKED) |
| curl | data.sec.gov / www.sec.gov | **BLOCKED** (CONNECT 403) |
| USPTO TSDR (via Tavily) | trademark record | page shell only (client-rendered): **BLOCKED** for content |
| PubMed, ClinicalTrials.gov, bioRxiv, NPI, ICD-10 | not needed for W01's modeling questions | connected, unused |
| `@neo4j/graphql` 7.6.3 + graphql 16.14.2 (run harness `build-schema.mjs`) | fragment + kernel stubs build | used: parse OK; build OK (1,362 generated types, 40 queries, 36 mutations) |
| Embedded Neo4j 5.26.31 Community (run harness `EmbeddedNeo4j`, `run-cypher.mjs`) | all fixtures, queries, 0.2.0 validation suite, operations | used, private instances, stopped at end |

## 2. Deliverables and SHA-256

| Path (under `workers/W01/`) | SHA-256 |
|---|---|
| `01-domain-recommendation.md` | `720f842180fdc0711fdbc710733af89e0def36eb0751b49c90c95a9bdd94f2ed` |
| `02-cq-coverage.md` | `312a61009c07c81d50d783aff36f0452e3d7960d68a611bfd2665a9441e3c303` |
| `03-source-manifest.md` | `f1e0073731f86a8ea16a56197db4eb2921d717eb82bd74c90c449a7bc933e5d8` |
| `04-model-cards.md` | `ef0d528b5070cd6a6232eedcef81a5347fd223f11539d2bb5d9183acf167b42b` |
| `05-decision-seam-ledger.md` | `563fb3740d7b50029913d0b7df16fa56c55a8b1fef2e06586f23329db80fcf2c` |
| `06-fixtures-and-queries.md` | `2321b2d89076f4dbfafb39f21e5f0f8e5c05cb3176cf583a3c9041e8f0f72577` |
| `07-operations.md` | `052e8f58645982447f3f891719a428b3b1272d7a1844634998e1fe4bdd4df635` |
| `operations.cypher` | `af4e830dc203d926c6c4e0d39123b51f0f22b7c7052d64d070c2ee33072a9981` |
| `sdl-fragment.graphql` | `f8201bb321cc58204e2f5114fc7f98bec1bb9d032319f88027c79b0c9982b114` |
| `migration-map.yaml` (171 entries) | `078fedef1589b70b054621f906351a47522cdd85282a05626969471053b8b583` |
| `seam-requests.yaml` (22 requests) | `95a82e6c94c31b439c895427967f65f18c83046f7bd40b3752842b042907f323` |
| `fixtures/w01-01-role-time-precision.cypher` | `9870e8f247ce92c677f7e35d10cbb03bd6434277a587bd012473fa5941882120` |
| `fixtures/w01-02-advises-not-endorses.cypher` | `18a6c35f9335f755eb70a91233ee2fbba7615844c86534f3087e236cac96e4a8` |
| `fixtures/w01-03-brand-vs-legal-entity.cypher` | `8212baa03a838a939708950e477f24f4b85c28aa5367e370c8f76abc90d12fb0` |
| `fixtures/w01-04-investor-vs-parent.cypher` | `a878066554e0c578c26ee250e60c221abd958eb93549f890d93609110d675440` |
| `fixtures/w01-05-facility-label-roles.cypher` | `584731e900f4badf78733b91caa574ae66bfee4d8725bc99e114ce2b68df269b` |
| `fixtures/w01-06-cohort-participant-identity.cypher` | `821c3249b04fffd9f15ec51af1672467ed3e5b5cbd8e0b534145c395b2f6fed4` |
| `fixtures/w01-90-negative-forbidden-implications.cypher` | `6c07412aabef0b894b89fd3e8d3b5ad5ee3d517d2b4fd5731ef1db50391c283e` |
| `fixtures/w01-91-negative-privacy-leak.cypher` | `006839a519ca20e9b615b4eaba83fce2e3b5395934b39dfec2c8ee2a07fe6bcd` |
| `fixtures/w01-queries.cypher` | `4f420e3b09988fe7735b4251759a8e776286e0b4ce1ae75358d5acf9868f52b3` |
| `fixtures/execution-summary.json` | `d670a2e94cf184ebcfd3eb6c8808582d3d8e22935bfdfefc377cba111c820155` |
| `fixtures/generator/gen_lib.py` | `0b8a039200e675b359aa1c2393fea91956c3037c0a29a081d029edd2e2cf3949` |
| `fixtures/generator/gen_fixtures.py` (paths point at the run scratchpad) | `9e298df4b1cde4a1d4ffe665447434fed03eebba6581e34ffbca905775148af7` |

## 3. Validation status

- SDL: graphql-js parse OK (fragment alone). `@neo4j/graphql` 7.6.3 build OK with kernel stubs written per contract B3/B4 (stub `ActorIdentity.name` nullable); with the live `ActorIdentity.name: String!` the build **fails** (W01-SR-02).
- Fixtures 01–06: 281 statements, 281 OK; 134 nodes, 251 relationships. Combined with the six 0.2.0 examples: all OK.
- 0.2.0 validation suite (174 statements): only informational rows on W01 positives (V-118, V-401b, V-514b); after negatives, every planned violation fired (06 §4). Two gaps in the 0.2.0 suite demonstrated: brand-targeted board edge (N4) and projection from a PROPOSED assertion (N8) are invisible without V-W01-01/07; equity-as-control (N3) needs the candidate pair.
- V-W01-01..12: 0 rows on positives; on the combined load V-W01-01 flags the 0.2.0 example's BOARD_MEMBER_OF → ConsumerBrand edge (W01-SR-05).
- Operations: 43/43 statements OK on Community after constraints.cypher; fixtures load OK under all constraints.
- Review status: self-reviewed only; no independent reviewer.

## 4. Research gaps

- SEC EDGAR could not be fetched directly; proxy and 10-K excerpts are Tavily extracts (PARTIAL_EXCERPT / SEARCH_EXTRACT). Pioneer Step's stated percent of class was not captured.
- USPTO record not obtained (TSDR client-rendered); trademark facts come from an aggregator (Trademarkia) and are marked as such.
- No real product label was captured; the label minimal pair is SYNTHETIC (regulatory rule is real: 21 CFR 101.5).
- No study fixture for CQ-EC-04 (author affiliation vs funding); left to W09/W20.

## 5. Unresolved seams (owner)

W00: tokens (SR-01), ActorIdentity nullability (SR-02), HAS_SNAPSHOT collision (SR-03), precision-aware QS-2 and witness = publishedAt (SR-04, SR-08), stated witness date kernel request (SR-07), n-ary stake qualifier (SR-22), validation params and checks (SR-06). Fable/catalog: example fixture corrections (SR-05), CORPORATE_GROUP (SR-09), candidate forbidden implications, SUBSIDIARY_OF canonicalization, assertion-only predicates (SR-10), CL-015 ruling (merge PhysicalLocation into Facility). W23: CL-018 and personal fields (SR-11). W09 study-role writer (SR-17). W11 (SR-13, SR-14), W12 laboratory granularity (SR-18), W14 brand/trademark (SR-19), W15 availability and seller accounts (SR-15), W21 sponsorship props and relevance (SR-21), W22 union member (SR-16), all owners: field slots on W01 types (SR-20).

## 6. Confidence per dimension

| Dimension | Confidence | Why |
|---|---|---|
| Identity model (org / legal entity / brand / facility / person) | high | real minimal pairs (Niagen rename, ChromaDex homonyms, TRU NIAGEN mark) plus executed checks |
| Role edges and FINANCIAL_INTEREST family | high | catalog-aligned; negatives fire the intended checks |
| Time semantics (precision ladder) | high for the rule, medium for adoption | follows round 0007 §9; QS-2 change pending W00 |
| Facility / PhysicalLocation merge | medium-high | regulatory rules support it; live data shape (REMOTE/VIRTUAL rows) unknown |
| CohortParticipant placement | medium | depends on W23 ruling |
| Migration of live role edges | medium | live data not inspected (no deployed database); counts unknown |
| GraphQL build | high for the fragment with stubs; merged-file behaviour is Fable's |

## 7. What remains qualified

- `MARKETS_PRODUCT`, `SUPPLIES_INGREDIENT_MATERIAL`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM`, `FOUNDED_ORGANIZATION` are in the fragment by catalog membership but not exercised by a W01 fixture (the 0.2.0 examples exercise SUPPLIES_INGREDIENT_MATERIAL, HAS_IP_INTEREST_IN).
- Enterprise existence/type constraints are listed but unverified.
- "Possibly" answers for point-in-time holdings remain until W01-SR-07 is ruled.
