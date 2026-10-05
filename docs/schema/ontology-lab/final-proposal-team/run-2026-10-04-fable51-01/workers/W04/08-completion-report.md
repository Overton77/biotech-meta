# W04 completion report

- Worker: W04 Products, formulations and labels. Model: **Opus 5.5** (claude-opus-5-5). Coordinator/synthesizer: Fable 5.1.
- Run: `run-2026-10-04-fable51-01`. Started about 2026-10-04T00:44Z (first contract read); finished 2026-10-04T01:33Z.
- Writes: only `workers/W04/`. Nothing else in the repository was edited. Scratch work (excerpt files, harness copies, the embedded database store) is in the session scratchpad.

## Tools used and availability

| Tool | Used for | Result |
|---|---|---|
| Bash, graphql-js 16.14.2, @neo4j/graphql 7.6.3 (run harness `build-schema.mjs`) | parse and build the fragment plus stubs for other owners' types | parse OK; Neo4jGraphQL build OK (1,320 types, 64 queries, 75 mutations, no vector provider) |
| Embedded Neo4j 5.26.31 Community (`EmbeddedNeo4j`, own store) | load fixtures, run baseline `validation.cypher` (174 statements) and W04 validators and queries | all statements executed; one OOM kill under host memory pressure (20+ JVMs); rerun with `-Xmx768m` |
| curl / WebFetch | elysiumhealth.com, truniagen.com, web.archive.org, archive.org, pubchem | **BLOCKED** (proxy 403 / EGRESS_BLOCKED) |
| Tavily extract | live Elysium and Tru Niagen pages | OK; Wayback URLs **failed** |
| Firecrawl scrape | Wayback CDX and captures, live Tru Niagen page, eCFR 101.36, PubChem PUG REST | OK |
| ClinicalTrials.gov MCP | NCT02678611 | OK (current version only) |
| PubMed, bioRxiv, ICD-10, NPI | not needed for W04 questions | not used |

## Research gaps and what stays qualified

- No raw-byte capture of any page: hashes are STORED_EXCERPT_TEXT over stored excerpts. Fable or ingestion should re-capture the raw bytes.
- The Tru Niagen 150mg label was not captured. The 150mg-as-variant case rests on the marketing card ("Two capsules make a 300mg serving"), so it is not used to build a formulation.
- Whether Basis changed its material between captures 2025-09-10 and 2026-03-05 is not established. Only the declaration changed. The material identity hypothesis is UNRESOLVED.
- No 2016 Basis label is archived at the label URL (first capture 2021-12-08). The 2016-03-20 brand page has no amounts. CQ-ID-02 for NCT02678611 therefore stays FORMULATION_AT_ADMINISTRATION_UNKNOWN.
- GTINs come from the merchant record. GS1 registry ownership was not verified.
- Round-0001 fixtures not built here: "renamed product with unchanged formulation", "same formula in capsule and powder" (Tru Niagen stick packs exist in the CDX, but their label was not fetched), "same brand and strength, different jurisdictional labels" (the 2021 Basis page links a Canada store, not fetched), and the recommendation-ranking case (W10/W23). OPEN-QUESTIONS P0-1 is closed only for the three tests in W04-D01.
- Non-US label rules, botanical extract and marker declarations, and proprietary blends with nested quantities (OPEN-QUESTIONS P1-4/P1-6) were not researched. The enum values exist (EXTRACT_TOTAL, MARKER_CONSTITUENT, PROPRIETARY_BLEND_TOTAL) but have no W04 fixture.

## Unresolved seams (see seam-requests.yaml)

W04-SR-01 tokens (W00); SR-02 V-409 ordering (W00); SR-03 V-108 vs V-509 and edge partition (W00); SR-04 ACTIVE_MOIETY_AMOUNT predicate (W00); SR-05 ProductLabelRegion target (W22); SR-06 HAS_SNAPSHOT dual meaning (W00); SR-07 manufacturing successors and HOSTS_PRODUCT (W01/W11); SR-08 CLASSIFIED_AS (W08); SR-09 DELIVERS_LABTEST owner (Fable); SR-10 unions and vocabularies (union owners, W02); SR-11 Bundle → PackageConfiguration (W15); SR-12 elysium fixture V-110 time dependence (W00/Fable); SR-13 Neo4j list-predicate defect (Fable).

## Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Product / variant / package boundary | high for the three tested rules; medium overall | two real product families, executed fixtures |
| Formulation episodes (correction vs ending) | high | round 0007 table reproduced by execution |
| Label declarations, referent, %DV state | high for US Supplement Facts | eCFR 101.36 plus two real labels |
| Calculated active moiety | high for the arithmetic; medium for the predicate form (registration pending) | PubChem MWs |
| Selector recommendation | medium | one site, five captures |
| Live-field dispositions | medium | depends on W01/W08/W13/W15/W17/W20/W22 accepting the successors |
| GraphQL executability | high for the fragment with stubs; the merged build is Fable's | build run |

## Review status

Self-reviewed against contract sections A–C and the registry row. Not reviewed by another worker. Baseline validation was run on every scenario. W04 validators are 0 rows on all positive scenarios and fire on every negative case.

## Artifacts (SHA-256)

```
    761b80fd9a55844dad79b5775e2ebb8a63a07d85cbfce34438fd18984aa2af49  sdl-fragment.graphql
    95fdac03322f98363768cc2745772348a0438ba569fe9a9688fc4eceb916956f  migration-map.yaml
    cff84da291951c1d2bdccf2a8d59dcde9538035e38f870510f15dbd010d05d53  seam-requests.yaml
    6ed092ff447a752c9985ae2b804d563f7f70ffc5798f9cfa841bfd5d4a675096  01-domain-recommendation.md
    ab48d02c0260242cc5bb3d58c7eab37ede81a79ce5f29257bede9b41cc8e795e  02-cq-coverage.md
    87bbd44870107aa71c6469f637c7604f816d7ce9327736300e3c281b813192e5  03-source-manifest.md
    1e0a8a4e430bd9f7bdb0cf0f662202f5a5fe81427d1232fff143858e6af4f5ae  04-model-cards.md
    b928855e0c92690e4b962ed5401bc8442bdf0494993fc1cd9ad437d0fb829884  05-decision-seam-ledger.md
    c6054d8026dca638deefd4708e82aa1a87d7d19cbdc5079c7380d430fb1e7e62  06-fixtures-and-queries.md
    cbddcb8b35378b49752baea6917bc3a4f476cdd9186792047fa865aa4265b256  07-operations.md
    4d946127529b60d08d60507d67a08ef533781af64afe0929240d86aaff1254e9  fixtures/w04-01-correction-vs-fact-ending.cypher
    3627b0e238aa0a6ce8301a9c8562495cc2e893e00beecf763d642de3625b1177  fixtures/w04-02-package-vs-formulation-change.cypher
    a1b2ab6ab5e534654b7e62bb2b26c1700a31d5dd9166f982b93bba04c43c4b08  fixtures/w04-03-declared-calculated-measured.cypher
    36e1aef458cd3a46fd5df0d7b3b19dac3bf8544eb47839e3f51d3e66a072e248  fixtures/w04-04-basis-history-and-trial.cypher
    7b0d779efb0eb4f87d059c449c2ec24661b8349add4b5dfbd34517b5bccdf890  fixtures/w04-05-negatives.cypher
    c9037a621543b1523f25321ec7a31a89e05833129d26acb122b3ec7e130bb20c  fixtures/w04-06-elysium-basis-compat.cypher
    741c432830dd865235655fe4a4dbeb773d24f34392645f451687b4794be13ba1  fixtures/w04-queries.cypher
    3c3c3991b92220cee59bf527a26b6aea2b8eae1af82f6150dc16bf3aa8273968  fixtures/w04-query-results-2026-10-04.jsonl
    b9b1e8634967fae418ec3b32a3d8077f9d740572844b413bab793c7b10492ed8  fixtures/w04-validation.cypher
```
(This report's own digest is not included.)
