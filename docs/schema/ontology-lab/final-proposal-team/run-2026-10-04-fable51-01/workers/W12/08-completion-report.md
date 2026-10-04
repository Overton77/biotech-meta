# W12 completion report

- Worker: **W12 Quality testing and certification**, run `run-2026-10-04-fable51-01`, model **Opus 5.5** (`claude-opus-5-5`). Coordinator/synthesizer: Fable 5.1.
- Start: 2026-10-04 ≈00:56Z (mandatory reading). End: 2026-10-04 ≈01:47Z (UTC wall clock).
- Admitted against: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112`, contract `01-shared-contract.md` (frozen), registry row W12, CL-010.
- Wrote only inside `workers/W12/`. No authority file, catalog, round, other worker directory or run file was edited.

## Deliverables

| File | Status |
|---|---|
| `01-domain-recommendation.md` | complete: boundaries, disposition of every catalog quality element and live seam, proposed closures of OPEN-QUESTIONS P2 quality 1 and 2, boundary for item 5, NSF scope finding |
| `02-cq-coverage.md` | complete: CQ-PF-03, CQ-MF-06, CQ-AX-19, CQ-AX-04 (quality), pairs 18 and 11; candidates CQ-QA-C01…C04; element coverage table |
| `03-source-manifest.md` | complete: 12 NEW_RETRIEVAL rows, 3 INHERITED, 7 SYNTHETIC |
| `04-model-cards.md` | complete: 13 node cards, 20 relationship cards, union, 12 owned enums + shared `ResultQualifier`, candidates |
| `sdl-fragment.graphql` | complete; parses with graphql-js 16.14.2; **builds with `@neo4j/graphql` 7.6.3** against stubs of imported types (1,227 generated types); merge check against the 22 fragments present: 0 duplicates, no undefined W12 reference |
| `migration-map.yaml` | complete (8 live seam fields + 14 catalog-only entries) |
| `05-decision-seam-ledger.md`, `seam-requests.yaml` | complete: 16 decisions, 12 seam requests |
| `06-fixtures-and-queries.md`, `fixtures/*` | complete; all fixtures, validators, queries and negatives **run** |
| `07-operations.md`, `operations.cypher` | complete; `operations.cypher` run twice (idempotent) |
| `08-completion-report.md` | this file |

## Tools actually used and availability

| Tool | Use | Result |
|---|---|---|
| Firecrawl `firecrawl_scrape` (markdown, pdf parser, directQuote query) | Elysium lot pages, NSF info listing, nsfsport search and listing details, Tru Niagen quality and transparency pages, sample COA PDF, Niagen survey PDF, WHO TRS 957, ICH Q6A, eCFR 111.70 | all succeeded (live, `maxAge 0` where relevant) |
| Firecrawl `firecrawl_search` | COA examples, ICH Q6A | succeeded |
| Tavily `tavily_search`, `tavily_extract` | NR COA search (found the Niagen survey), NSF programme snippets, WHO §19.1, ICH Q6A EMA rendition | succeeded |
| curl (raw bytes for hashing) | Tru Niagen sample COA PDF | **BLOCKED** (egress proxy: CONNECT 403); recorded, not treated as absence; hashes are over stored excerpts |
| Local runtime | embedded Neo4j 5.26.31 Community (run harness jars in the scratchpad), `run-cypher.mjs`, `build-schema.mjs`, `merge-fragments.mjs`, `@neo4j/graphql` 7.6.3, graphql 16.14.2, neo4j-driver 6.2.0, Node 22.22.0 | used; instance stopped at the end (STOP file); database was disposable |
| PubMed, ClinicalTrials.gov, bioRxiv, ICD-10, NPI | not needed for this package | not used |
| Exa, bigdata.com, Figma, GitKraken | failed to connect at session start | not used |

## Execution record (all run; details in 06 and `fixtures/run-results/w12-run-summary-2026-10-04.json`)

- `operations.cypher`: 28/28 ok, twice.
- Positive fixtures: 428/428 statements ok (263 nodes, 676 relationships).
- Baseline `validation.cypher` (174 queries) on W12 positives: zero failing rows (informational V-118, V-401b, V-514b only).
- W12 validation V-W12-01…13 on positives: zero rows except informational V-W12-13 (1).
- 10 CQ queries: expected rows observed.
- Negatives (20 statements): every intended validator fires (V-008, V-009, V-011, V-112, V-113, V-114, V-124, V-332, V-W12-01…12); V-W12-09 masked by N17 and confirmed after removing it; V-503 does **not** cover episode edges (seam W12-SR-09).
- Combined with the six 0.2.0 examples (873 statements, 791 nodes, 1,637 relationships): baseline suite counts identical to the run's baseline rehearsal except informational V-118.
- GraphQL round trip: reads over Cypher-ingested data work (union and multi-target relationship fields); DateTime selection fails without APOC; API create mints an `id` unrelated to `uid` (W12-SR-11).

## Research gaps

1. No raw-byte hash of any source (proxy blocked curl to the COA host; Firecrawl returns parsed text). Hash basis is STORED_EXCERPT_TEXT over our excerpt files.
2. Signature on the Tru Niagen sample COA: not established (text extraction only). The document is labelled "Sample"; whether lot T25189001 was sold is not established.
3. No real lot-specific measurement **with stated uncertainty** was found; the CQ-AX-19 uncertainty case is synthetic (Lab Z). The real third-party-like value (Niagen survey, 261 mg NR/serving for Basis) has no lot, date, uncertainty or counterion and comes from a competitor.
4. NSF listing effective dates and the date each lot was added are not published on the captured pages; listings 1267670, 1451522, 1172213, 1427670, 1536554 were not opened (1536554 was opened only for its lot list).
5. ICH Q6A section 2.2 is for drug products; no dietary-supplement source states release vs shelf-life practice beyond 21 CFR 111.70(e).
6. Recall and counterfeit records were not researched (W13/W15/W18 scope).

## Unresolved seams (owner)

W12-SR-01 tokens (W00); W12-SR-02 SUPPORTED_BY domain (W00, already drafted by W00); W12-SR-03 LABORATORY_REPORT (W00); W12-SR-04 CONFORMS_TO_SPECIFICATION (W00); W12-SR-05 `certifiedUnder` on Product/ProductVariant (W04); W12-SR-06 recall/counterfeit/expired inventory (W15); W12-SR-07 quality forbidden implications (W00); W12-SR-08 GMP_FACILITY / qualitySystemKind migration (W01, W11); W12-SR-09 V-503/V-505 edge coverage (W00); W12-SR-10 SpecificationVersion and CRITERION_OF_SPECIFICATION (W11, converging with W11-SR-03); W12-SR-11 API identity and APOC (W00); W12-SR-12 three ResultQualifier values (W07). Incoming: W07-SR-16 accepted (AssayVersion coverage); W11-SR-03 answered (D-W12-16).

## Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| COA vs summary rule (OQ P2-1) | high for the two real documents; medium for generality | one real COA, one real summary, WHO §19.1; other brands' COA layouts not sampled |
| NSF scope = lots | high | three NSF surfaces plus the brand's lot list agree; certifier explainer says lots are listed |
| Release / shelf-life / uncertainty model (OQ P2-2) | medium-high | ICH Q6A and WHO text; supplement practice inferred from 21 CFR 111.70(e) only |
| SDL executability | high under the stated pins (built, round-tripped) | Enterprise and APOC-present runtime untested |
| Fixture realism | high for real-source fixtures (verbatim locators); synthetic parts flagged | |
| Missingness states | high | INV-007 states each have a fixture and validator |
| Recall/counterfeit boundary (OQ P2-5) | low (boundary only) | owned elsewhere |

## Review status

Self-reviewed against contract sections A and B, the registry row and CL-010. One defect was caught by W12's own validator and fixed (V-W12-01 on the first run). A merge check exposed a `ResultQualifier` collision with W07 and a contract A7 miss (catalog `resultQualifier` must be reused); the fragment was changed to use the shared enum and everything was re-run. No independent reviewer has examined this packet. What remains qualified: synthetic CQ-AX-19 positive; enum values without fixtures (D-W12-09); requested `ResultQualifier` values (fixtures write QUALITATIVE_ABSENT before it is registered; a GraphQL read of that node fails until it is); proposed uid tokens; fixture recorded-time instants are illustrative.

## Artifact digests (SHA-256, computed 2026-10-04 before this report was written)

```
85b11056f4750dd4fb6464b16de75b6268819c64e077479340e38945c71622ce  01-domain-recommendation.md
05c8ecaa69a5e6106d77a35422adec3ba6beddd659731fc4cad8f9c24e01c438  02-cq-coverage.md
7fe6c21d0b86e1c0b09dc44ad2b462860e173436aee493d84df05ef94a017e1c  03-source-manifest.md
48d9c73b05f9f8f0190a93309a0140866c0468209f0d47293a6f4775149246aa  04-model-cards.md
6ff903ea109d543ebee0c6a39d2fdaf222d216c782b6f4f67a763ec89ad8ced2  05-decision-seam-ledger.md
9e4eadcdbe781780cf56d4691c39dfb5e7f27f5d1f52b3261edb80bf80103507  06-fixtures-and-queries.md
4b49b9e199d7ad4770202db39712726d909736171cc64f4bab6c95b5f630e898  07-operations.md
868d67fc7f3f7c94affa83bc88a052b253e6f4867a60d9a1ea51dcf2ea871795  sdl-fragment.graphql
ed0c616a61edd480f20d8eb16abc1d76919fe2934d6e5304041730d8bb5d04cc  migration-map.yaml
01a0c6e46fe36ca275cfb8e3f5304c3cdead398ff298462667acb9aa9878a0e5  seam-requests.yaml
5d2f3949887edd539fd356107ffa151fd08cb8efa130567f4aa60ea0eebdaff3  operations.cypher
fba0e8d617c527bec3849de9d96f34fbb7687df6518396b32a71a506ed5d03b6  fixtures/w12-00-base.cypher
780719922c03b968b1093ae5eb657d2bdac9c9b3b0532dc3e97065577a790315  fixtures/w12-10-coa-vs-summary.cypher
a355f80489af668c6247db65dda3842746e9afefaad3f9bd6ba2f70d8704473c  fixtures/w12-20-lot-measured-vs-label.cypher
2730379bae78f41f4e252ee9f3d13279b49940d95c8b9718cec1302d6487e6d3  fixtures/w12-30-certification-scope.cypher
de539917c0467b28d6249c56d749ac0fdb298911664b547ba17207b069d3480f  fixtures/w12-40-missingness-and-spec.cypher
23cb1b9f29f92304a8812ea2b582c411d343f86499b00712758093553af46111  fixtures/w12-90-capture-fidelity.cypher
f718ff6bdb7da0b36f80a2ccb3b501ae60a2df86903c51647375ed289338dcbc  fixtures/w12-negatives.cypher
42be3826a837ad2e4065e0c8fc761c51f44fd5d3f36c8171e7b73cd12dd823ae  fixtures/w12-validation.cypher
7d53812ba0b3c6b29642a956b936699da68140194ca55d898d3c8f1462f200d7  fixtures/w12-queries.cypher
f9ba84694969c3d22ed73aafd2da21fdc4f0a852d7652964e38610ce0c72b40d  fixtures/w12-query-params.json
adc9494ce1e354fac51cbdd2637d65049a222a21af0815c77c4a00e62ced899b  fixtures/run-results/w12-run-summary-2026-10-04.json
0e42af23ba6bebe16dc75e9a32bf6f1cd5d4d85a65f0d2537544b7dd2aeb518b  fixtures/excerpts/truniagen-sample-coa-T25189001-2026-10-04.txt
75845543c817d81d68eb7773f14c95934542d8d5ce4adae4ccfddb7eac6f17e3  fixtures/excerpts/elysium-basis-lot-P098-01-2026-10-04.txt
13b615500991c121a0287c86291ef47b64f3081ac03c055a0e8967702a210edb  fixtures/excerpts/nsf-info-listing-C0364723-306-2026-10-04.txt
ce56455817b6ef41181ad25b3de0cc8e1cd9c3b5d400526a12e0a394c3cab6ec  fixtures/excerpts/nsfsport-listing-1786167-2026-10-04.txt
e343cebd8adfe45874e15d6e8a00c96d1ce7fa6e69dd0e37146745ca62a09b88  fixtures/excerpts/nsfsport-listing-1463170-2026-10-04.txt
8194cb11753291678ed1223812c148481842d14e2a3a9f36ba2eeecdc4dcde32  fixtures/excerpts/nsfsport-get-certified-2026-10-04.txt
b53c43ebac936a34ca2370303cafafa081db6a624bf3079b973f0bd1bb4a924e  fixtures/excerpts/chromadex-nr-market-surveillance-2025-06.txt
b4857db4fef60f7fbea816c6b3e60ec7c07541ca8cd504aa8c00bdffd1369e2d  fixtures/excerpts/who-trs957-annex1-s19-2026-10-04.txt
a8a0a6c3a0c50dbad2e1be13f5b6be29445ea82c6dba73a7d678724a471e1e33  fixtures/excerpts/ich-q6a-s2-2-2026-10-04.txt
ad84148482845e5f51341220fa694ec0e8a9633788e8a9c9314e58d9ad615907  fixtures/excerpts/ecfr-21-111-70-e-2026-10-04.txt
```
