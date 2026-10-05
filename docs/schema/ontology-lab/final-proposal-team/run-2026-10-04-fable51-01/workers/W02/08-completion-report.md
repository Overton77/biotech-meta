# W02 completion report

- **Worker:** W02 Substances and materials.
- **Model:** Opus 5.5 (`claude-opus-5-5`). Coordinator and synthesizer: Fable 5.1.
- **Run:** `run-2026-10-04-fable51-01`.
- **Start:** 2026-10-04T00:47:15Z (recorded after mandatory reading). **End:** 2026-10-04T01:38Z (digests below computed at the end).
- **Inputs read:** 04-worker-brief.md, 01-shared-contract.md (D-002, D-008), 02-ownership-registry.md (W02 row; CL-001, CL-002, CL-005), 03-conflict-ledger.md, 00-baseline.md, and the handoff sections 2–6 (W02 row). Also: the catalog module `substances_and_materials` and the `conventions` enums `materialIdentityLevel`, `massBasis`, `amountReferent`; architecture.md §§5–6; round 0002 §H and the identification table; round 0005 §E and KCR-L3-001; OPEN-QUESTIONS P1 ingredient items; CQ-ID-03/04/05/06, CQ-PF-01, CQ-ST-01/02; live-schema-alignment rows for Compound, CompoundForm, DoseMetadata and Material; property cards (massBasis, amountReferent, derivationRule); validation.cypher V-004/5/6, V-2xx and V-330; examples `elysium-basis.cypher` and `study-vs-product-mismatch.cypher`; source-registry entries in my area; live schema lines 653–690, 951–965, 1531–1544 and 1320–1336, plus every union referencing my live types; both independent reviews (material rows).

## Deliverables

| File | Content |
|---|---|
| `01-domain-recommendation.md` | Boundary; dispositions of all live and catalog elements; alternatives; smallest model |
| `02-cq-coverage.md` | 7 existing CQs, 4 candidates (CQ-ID-C01…C04); every SDL element mapped |
| `03-source-manifest.md` | 35 rows: 28 NEW_RETRIEVAL (incl. 3 BLOCKED or 404 attempts), 5 INHERITED, 2 SYNTHETIC; four settled research questions |
| `04-model-cards.md` | 12 node cards, 10 relationship cards, 1 relationship-property card, 1 union card, 11 enum cards, 5 CANDIDATE cards |
| `sdl-fragment.graphql` | 12 types, 1 union, 1 relationship-property type, 11 enums. Parses (graphql-js 16.14.2) and builds (`@neo4j/graphql` 7.6.3 with stubs for referenced types) |
| `migration-map.yaml` | 82 entries |
| `05-decision-seam-ledger.md` + `seam-requests.yaml` | 21 decisions; 25 seam requests (5 kernel requests to W00) |
| `06-fixtures-and-queries.md` + `fixtures/*.cypher` | 9 fixture files + query file, all executed |
| `07-operations.md` + `operations.cypher` | Indexes; 13 validators, executed |
| `08-completion-report.md` | This file |

## Tools actually used and availability

| Tool | Used for | Availability |
|---|---|---|
| Firecrawl `firecrawl_scrape` | GSRS API (search + two full records), PubChem PUG REST ×3, EFSA opinion, Elysium Mosaic pages ×2, EMA monograph PDF, BacDive, ChEBI | Available. ATCC `/products/53103` returned 404. UniProt REST timed out, then returned 503 |
| Tavily `tavily_search` | GRN 635 PDF / FDA letter / inventory, EFSA/EU Union list, FSANZ, Mosaic label, EMA assessment report, PMC9593214, ATCC BAA-3227, Wikipedia, CT.gov NCT00934453 | Available (search extracts only) |
| `curl` through the agent proxy | GSRS, PubChem, ChEBI | **BLOCKED** (CONNECT 403). The same hosts were reached via Firecrawl |
| PubMed, ClinicalTrials.gov MCP, bioRxiv, WebFetch | not needed | The CT.gov record was taken as a search extract, not through the MCP connector |
| Exa, bigdata.com, Figma, GitKraken | — | Failed to connect (session notice); not needed |
| Embedded Neo4j 5.26.31 Community (private copy of the run harness, Maven cache) | Executed constraints, all fixtures, the baseline 174-query validation suite, `operations.cypher`, `queries-W02.cypher`, idempotence check | Available. One run was killed by host memory pressure from other workers' JVMs and was re-run with `-Xmx700m` |
| `@neo4j/graphql` 7.6.3 / graphql 16.14.2 / neo4j-driver 6.2.0 | Build of the fragment with stubs; GraphQL execution against fixture data | Available (npm) |

## Research gaps

- **Not fetched in full:**
  - US patent 4,839,281 (the GG patent naming; known only through a Wikipedia search extract);
  - the full GRN 635 PDF (Table 2 known through a search extract);
  - the Ph. Eur. and USP monograph texts (secondary citations only);
  - NIAGEN certificates of analysis.
- **Not verified:** the CD38 UniProt accession (UniProt 503); PubChem release version; GSRS NR record lastEdited date (only the salt record's was extracted).
- **Not established:** any US label stating a botanical extract-ratio basis (native vs genuine DER); a probiotic label stating viability alongside the count; the NIAGEN specification in force at the 2016 trials.

## Unresolved seams

| Area | Requests |
|---|---|
| Kernel (W00) | SR-01 (object + quantity), SR-02 (V-006r), SR-03 (tokens), SR-04 (HAS_MOLECULAR_WEIGHT; ActivityKind CALCULATION), SR-05 (STRAIN_OF exclusivity) |
| CL-002 (W03, W07) | SR-07, SR-08 |
| Taxon identity sharing (W03) | SR-06 |
| Identity-level mapping (W10) | SR-09 |
| CL-005 (W11) | SR-10 |
| Union member replacements | W05, W06, W09, W16, W18, W21, W22, W00 (SR-12, 19–25) |
| Safety (W17) | SR-14 |
| Registry entries (W19) | SR-16 |
| Repo fixture issues | SR-17 (elysium-basis clock dependence, V-110); SR-11 (component without amountReferent) |
| Spec criteria (W12) | SR-18 |

## Confidence per dimension

| Dimension | Confidence | Why |
|---|---|---|
| Salt vs moiety substance identity (D-W02-01) | high | Three authorities agree (GSRS, PubChem, CAS) |
| CL-002 rule | high for small molecules; medium for proteins/peptides | The protein boundary is a CANDIDATE |
| Branded material across specification versions | high on identity; medium that the 2019 EFSA table is "the NIAGEN" specification | Inference, kept PROPOSED |
| Botanical model | medium | Ratio basis and label practice not established; standardization edges depend on SR-01/SR-02 |
| Microbial model | medium | One strain case; consortium and spore handling untested |
| SDL fragment | high for parse and build with stubs | Merged-schema build depends on other owners' definitions |
| Fixtures and validators | high | All executed with the expected rows, including composition with the repo fixtures |

## Review status and what remains qualified

- No independent review of this packet has happened. Fable's integration review is pending.
- **Synthetic content:**
  - Supplier X amorphous NR chloride (M-90);
  - every fx-90 negative;
  - the nicotinamide molar-equivalent rule in fx-91, which is not a regulatory niacin-equivalent factor.
- **Retrieval timestamps** in fixtures are representative values within the 00:47–01:30Z retrieval window.
- **Fixture uids reused from the repo** (NIAGEN, NR chloride, the crystal form, the trial NR material, the Tru Niagen component) depend on those fixtures staying stable.

## Artifact digests (SHA-256)

Computed with `sha256sum` at the end of the run. This report's own digest cannot be included in itself.

```
dbc09bfdfbe7fdc3c9a3ac10d7d71781b9f7245e4fa8f126dfe5511726796817  01-domain-recommendation.md
4f3a4766b0c4ebf51ef9fb94c8dd1f95202ff134f44ca8e69f6cb61343140c01  02-cq-coverage.md
a520a6689e49333a3ae5ec8c3dad8d9295a607168bb639f57be1183c13ff9d74  03-source-manifest.md
66de42ba857d164b06d5f8c5bb3f8d424149012700ca7af1a3ce760cf162bbc4  04-model-cards.md
08f955ae251cf2058629ff0e279630352ba87dd0818f8a4c010866979ecb7fe2  05-decision-seam-ledger.md
21a0a471f3a6a6d1d0582817482f0b4a7969d8331e0682d6c7ec705fe2ac79aa  06-fixtures-and-queries.md
d9df19c276a3c380c2f59fb75f27fcecb08d9fc28cde6354fb2fadf21c9a3c8b  07-operations.md
295204a229343a6b3bc4bc048150aec7c8b199d7edc3528bc2761855424209ac  sdl-fragment.graphql
cba3149b14162105cdaab7d8ccbfddeae8204c984cd418ed20bd611828b5e5f6  migration-map.yaml
84d894ae0b8192fac9498f0b57b1130d954f0031529e08bf084e61d9a3f2e974  seam-requests.yaml
5db168ba4cd2cf02be006e38e9cbfc4e4aaa03c6a8e1403f411b32b1ef36ce0a  operations.cypher
79982bd466247a8084fab20ae1622489c5f2ed36c4a12bb8cd0c523d25499b5f  fixtures/fx-01-nr-salt-vs-moiety.cypher
56052820553391a5108e07bc532103e574069f3c53eda85bec9ba5135d15ea85  fixtures/fx-02-mosaic-provides-not-contains.cypher
2e206241214185e782b2eba7b71e726e361cfc2189b40639e82b7c771443ebf8  fixtures/fx-03-niagen-two-spec-versions.cypher
f846336c3665eba053b7c9f430cfadb658cf6ecb13d3112c01998f1ae70f42a3  fixtures/fx-04-botanical-ginkgo-preparation.cypher
d3920de838f1e0734962de3c02a9b727055dcb8af051826b62233c30fbc0374d  fixtures/fx-05-lgg-strain-deposits.cypher
19fa595ef33047c824c7e054f7c580031f450e648004ae57eac182942fe54c7b  fixtures/fx-06-nrpt-not-a-substance.cypher
4526aa375e1c185ec27fea182de68c0fb2c689d2c0126c2e628781bb44420562  fixtures/fx-07-nad-chemical-vs-molecular-entity.cypher
4d23edf485fa025d64929a91e813572977f71c4bc6b8b04fd1308f6c2acd155e  fixtures/fx-90-negative-violations.cypher
02a56ad1d404dcc46e132518c3e348eeb2267c66ed9995b098a4dbeb94db6101  fixtures/fx-91-kernel-quantity-failing-cases.cypher
4f801faa8ca1359c7f3860abd8987a2b1bf38640c266be414548d3983d33765a  fixtures/queries-W02.cypher
```
