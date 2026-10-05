# W17 completion report

- Worker: W17 Safety and use constraints. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator/synthesizer: Fable 5.1.
- Start 2026-10-04T01:31:59Z (first shell timestamp after the mandatory reading began); end 2026-10-04T02:07Z.
- Wrote only inside `workers/W17/`. Scratch files (harness runs, database directories) are in the session scratchpad, not in the repository.

## 1. Deliverables

| File | Content |
|---|---|
| `01-domain-recommendation.md` | boundary, findings from retrieved records, disposition of every live and catalog element, alternatives with failing cases, smallest model |
| `02-cq-coverage.md` | CQ matrix (CQ-ST-06, CQ-RC-06, CQ-RC-07, CQ-AX-02, CQ-AX-04, CQ-AX-24, CQ-PR-03/04; candidates CQ-SF-C01..C05), SDL element coverage, forbidden implications FI-W17-01..09 |
| `03-source-manifest.md` | 7 new retrievals (+ 1 landing-page extract), 1 inherited, 2 synthetic groups; blocked fetches recorded |
| `04-model-cards.md` | cards for 5 node types, 9 relationship types, 3 property types, 5 enums, 3 unions; private-store touch points |
| `sdl-fragment.graphql` | 16 definitions; parses standalone; builds with `@neo4j/graphql` 7.6.3 over stubs |
| `migration-map.yaml` | 60 rows |
| `05-decision-seam-ledger.md`, `seam-requests.yaml` | 12 decisions, 0 kernel-change requests, 13 seam requests, 5 unresolved items |
| `06-fixtures-and-queries.md`, `fixtures/` | 7 fixture files (generated), 13 validators, 10 CQ queries, GraphQL round-trip, build stubs, generator, run results (run 3) |
| `07-operations.md`, `operations.cypher` | 21 Community-runnable statements; validation, concurrency, edition, migration notes |

## 2. Tools actually used and availability

PubMed MCP (`search_articles`, `get_article_metadata`, `get_full_text_article`): available. ClinicalTrials.gov MCP (`get_trial_details`): available; the record has no posted results. Tavily (`search`, `extract`): available. Firecrawl (`search`, `scrape` with directQuote queries): available; one archived FDA URL returned 404. Direct shell HTTPS to fda.gov, dailymed.nlm.nih.gov and clinicaltrials.gov (v2 API): **blocked** by the egress proxy (403); recorded as BLOCKED, not as absence. Exa, bigdata.com, Figma, GitKraken MCP servers failed to connect at session start (not needed). Execution: the run harness (`validation/harness`, embedded Neo4j 5.26.31 Community, `@neo4j/graphql` 7.6.3, graphql 16.14.2, neo4j-driver 6.2.0, Node 22) — three fresh database instances; final results from run 3.

## 3. Research gaps

- How Dellinger 2017 elicited AEs is not stated (collection method NOT_DESCRIBED); the registry has no results module, and the ClinicalTrials.gov API that would show "Systematic/Non-systematic Assessment" for other trials was blocked. No real trial with a SYSTEMATIC zero was captured; that case is synthetic.
- The pre-2021 statin pregnancy contraindication text was not retrieved (synthetic stand-in, clearly named); per-product label change dates unknown.
- The AEMS page was observed once (state as of 2025-10-24); the first-posting row text is unknown.
- No supplement product label warning ("do not use if pregnant") was researched (U-W17-05). No non-US signal process (EMA PRAC) was mapped (U-W17-02). MedDRA codes not retrieved (licensed; U-W17-03).
- Labeler identity of the ZOCOR SPL not captured, so label assertions have no asserter (allowed: at most one).

## 4. Unresolved seams (owners)

W17-SR-01 registry additions (Fable); SR-02 uid tokens, SR-03 predicates / forbidden implications / PredicateClass SAFETY, SR-05 union membership (W00); SR-04 structural class for `hasSafetySignals` (W02, W04, W05, W06, Fable — deviates from the registry note "asserted projection"); SR-06 SafetySignal vs EvidenceSynthesis, UseContextProfile as population scope, FI-W17-09 (W10; W00 for the subtype dispute); SR-07 private-store blocking contract (W23); SR-08 AE term → AdverseEffect link and derived `Study.reportsSafetySignals` (W09); SR-09 adopt V-W17-* and scope V-231 to MECHANISM (Fable, W00); SR-10 AFFECTS_ORGAN ruling (W03); SR-11 SAFETY_COMMUNICATION snapshots (W20); SR-12 ThresholdComparator and protocol-vs-use constraints (W16); SR-13 union owners.

## 5. Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| SafetySignal as EvidenceAssessment | high | two failing cases run; agency wording; INV-209 |
| HAS_SAFETY_SIGNAL structural (vs brief's asserted note) | high on semantics, ruling pending | N4 + QS-4a logic; needs Fable's acceptance |
| Contraindication vs Interaction split, ConstraintLevel values | high for US label and two monograph styles; medium for coverage of other sources | S1, S2, S4, S5 |
| UseConstraint identity and blocking path | medium-high | Q-W17-04 seven cases run; private-side evaluation is W23's; class-level statements unresolved (U-W17-01) |
| AE missingness handling | high | agrees with W09 (identical quote hashes, same NOT_DESCRIBED reading); composition test clean |
| SignalStatus vocabulary | medium | FDA only (U-W17-02) |
| Operations | high on Community 5.26.31 (run); Enterprise unverified |

## 6. Review status

Self-checked only: fragment parsed and built; fixtures, validators, CQ queries and the baseline 174-query suite executed on a fresh Community instance; composition with W09 fixtures 01 and 05 executed. No cross-worker review has happened; every seam above is a request, not an agreement. What remains qualified: synthetic cases (systematic zero, not-reported study, pre-2021 contraindication, BellLabs methods, the illustrative policy v3 rule) are illustrative; the policy mapping from levels to BLOCK/PENALIZE is W23 content, shown only to prove that a shared uid can carry a block.

## 6a. Late check against W10

W10's packet was committed after W17 read the registry. Checked at 02:08Z: W10 defines `EvidenceStrength` as the legacy hint enum and `UseContextProfile` (labels `UseContextProfile, Entity`, `populationDescriptor`, `entityType 'UseContextProfile'`) exactly as W17's fragment and fixtures reference them; W10's `SynthesisInputTarget = StudyResult | Assertion` parallels W17's `SafetySignalInputTarget` (W17 adds `Study` for NOT_REPORTED inputs). No conflict found; W17-SR-06 stands as filed.

## 7. Artifact digests (SHA-256, computed 2026-10-04T02:06Z; this report excluded)

```
b9d067df57addb25280f0d073ae7a1a5dc548aa095cf81b8b41f45f94c894a9d  ./01-domain-recommendation.md
72a00814c7dc3816004206d64ab2a3361ceb462af21dde284acf469a24e15359  ./02-cq-coverage.md
1ba7fd685e7c9d8b6991ec29fc55c62957d67109c263480fe153424f4469b944  ./03-source-manifest.md
32ec7a13f3da2eb0a7908f6d05859ec1855de42b4953e3ed8a991c16107e4fdf  ./04-model-cards.md
5935d2fe0162e2e3e7665cb3cefa35bb0b1da45cf75f289aea44a7b97ac7d311  ./05-decision-seam-ledger.md
c61c0fde97f1c380710bfebec740789605d1b144c443b26c489b86780cc2830b  ./06-fixtures-and-queries.md
8487895ac3beb260c77016aeba12401a274abfec0232efd484f1fffc216eb340  ./07-operations.md
072dec43a73ce6fdd4f611c91c7ece9794e4e97acd1200f2e3f6ba2a1843d0f9  ./fixtures/00-w17-base.cypher
987d6df80169136319a4a7d33eb89d9ff52b0d9e8eb4a2f6cf9b785baff3159b  ./fixtures/01-ae-zero-vs-not-reported.cypher
8745c8377216432d7001f78f7c6345c196f26d307c05d6c52fd6de8c2af6e304  ./fixtures/02-safety-signal-assessments.cypher
b13f93b9e1f1d77cf5a12a813753ad73d7c9d7da5111d208ea0fef3bbb2704ee  ./fixtures/03-constraints-block-vs-lower.cypher
25f8afd448c2d9b2439efc70d78e3ff067adc2b63cda53a8650d258049298a1d  ./fixtures/04-interactions-unknown-blocks.cypher
c52d0a6f7487004b8ae2ffeaaa63bcb3f718af6869126f0559ff5ae1bc348f06  ./fixtures/05-statin-pregnancy-validity-bounded.cypher
92bf5e2e62798182b912dd38974c9826cf10221ceb8e614769954af55fa01939  ./fixtures/90-negative-must-fail.cypher
81e1697fbfe11cde49c9f256d18015cffb61f60a952e2566abd09a6fe72b3a24  ./fixtures/build-stubs.graphql
e4ef22b2fa41f3bcc754ff2e75c1623bbb6a3b1950383a14ef56ce5d079764fa  ./fixtures/generator/gen_w17.py
a3e5ae05f9c1a0f711c0272224ebde705ff6043cb41ea5b6a436ae18d882fc1b  ./fixtures/graphql-roundtrip.mjs
6c75e018d58e8ca031981762c2cb4f3d962841f4af5d240b2ae617cf02ac65ee  ./fixtures/results/baseline-clean.json
c3282f97e8ccd16a78f19fb20833420d3428b6def2699a76149c9d170d312369  ./fixtures/results/baseline-neg.json
232e9a7e79968a6c5424590cac80895ca30e550c7c7a513bf86725c3dc269c8d  ./fixtures/results/compose-w09-01.json
8f0a4187b6e9abfb33adf97c1cc908d9be8f299de3a5e623dc14b51acacb8b53  ./fixtures/results/compose-w09-05.json
a7127b2fa3fe81e6168f568ebd675a75bdc11780d3cac075b03f2b508188146c  ./fixtures/results/cq.json
1918d32208423ef5ff105382c4d6cd452f9f508f72d1aed60ff55c438324282e  ./fixtures/results/graphql-roundtrip.json
8ce220ec0423092b272b16b6e0212fdb0198f0801b93ad32ad9310f854e68f7f  ./fixtures/results/load-00-w17-base.json
eaac807410ed062113aefbc65c06060a31d8a204d75c6339153e791708060392  ./fixtures/results/load-01-ae-zero-vs-not-reported.json
ffe139e3c8dfe1abdd95b927f3c6e169c7ed2b43f0c5bf65c1eb73fa4364a518  ./fixtures/results/load-02-safety-signal-assessments.json
0be528058f6b0196526b41de85a189b941de4f4032c80a16f8fbb2e481633f4e  ./fixtures/results/load-03-constraints-block-vs-lower.json
8a39dd9e71cb2af763a8c8513957fb00385853e2f35df1cf6a3506fee12b8f94  ./fixtures/results/load-04-interactions-unknown-blocks.json
73611431c256b6eb5394a7d319013f39d4d2358de6c0e8403bf092bd21ca75ea  ./fixtures/results/load-05-statin-pregnancy-validity-bounded.json
acf420dac01fbb8d79bd9ab15b4ba541d18f67c150ed8e587e9be0038d575215  ./fixtures/results/load-90.json
b169484c3943007c381ea7a9764ac96a2904ec386a6008aa4afbb39918e7a432  ./fixtures/results/ops-w00.json
75841ea242578d74ec8e9118e29e321b3747363bb47d28650accf2da46de654e  ./fixtures/results/ops-w17.json
46742a5f693b8ecde81024ba6a208ca9fdd4a284cf9bad8c357965b097b5e261  ./fixtures/results/val-clean.json
232ca6a504f1209bce188ae704e2c428b279ff36eca3afe458687ededce4547c  ./fixtures/results/val-composed.json
e23169508bfa3dc08fcd5f983415dd3047b9d94f7f6f9bb6f874f57ddcfc1bc4  ./fixtures/results/val-neg.json
45f32ed41852e01582dacb33270111a078d6d9181d03e3a610d13976a5715d57  ./fixtures/w17-cq-queries.cypher
e2c02883fdd952d4896d2fffbfef6f5d93fdf249c14180593f0ac8d0bb114fd1  ./fixtures/w17-validation.cypher
f0f05cca57213715ef6af5a17fabbf8d76295f2863660638e893460c72f8c139  ./migration-map.yaml
44e1a04d8323cb1472917120d5932a7d87906aa4dbca591b191381e5e88dcf86  ./operations.cypher
ad297691ec42a3ef7cd3b3d31a4cc9f6d3ca01b7068f691748d922c49db8bce7  ./sdl-fragment.graphql
f88369677ce25053a9f5a7c8cfacba341db534842f2f1861e2e38c2a409d1861  ./seam-requests.yaml
```
