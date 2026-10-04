# W10 08 Completion report

- Worker: W10 Evidence assessment, applicability and synthesis. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start: 2026-10-04T01:15Z (first read of the run files). End: 2026-10-04T02:05Z.
- Wrote only inside `workers/W10/`. Did not touch the live schema, catalog, rounds, other workers' directories, the run's numbered files or the inherited example fixture (it was loaded read-only). Used a private Neo4j data directory in the session scratchpad; Fable's instance was not used.

## Tools actually used and availability

| Tool | Use | Availability |
|---|---|---|
| Firecrawl `firecrawl_scrape` | FDA surrogate endpoint table (S1) | available; NCBI Bookshelf BEST page **BLOCKED** (reCAPTCHA) |
| Firecrawl `firecrawl_research_read_paper` | Conze, Jolliffe 2025, NADPARK full text | available, returned no passages (index lacks full text) |
| Tavily `tavily_extract`, `tavily_search` | FDA biomarker page (S2), BEST search extract (S3), Basis and Tru Niagen labels (S8, S9) | available; NCBI Bookshelf extract and cell.com full text **BLOCKED** |
| PubMed MCP (`search_articles`, `get_article_metadata`, `get_full_text_article`, `convert_article_ids`) | Dellinger, Conze, NADPARK, Martineau 2017, Jolliffe 2021/2025 (S5–S7, S10–S12) | available |
| ClinicalTrials.gov MCP `get_trial_details` | NCT03816020 (S4), NCT01507831 (S13, considered and rejected) | available |
| curl Europe PMC REST | Conze XML | **BLOCKED** (proxy 403) |
| Neo4j 5.26.31 Community + APOC Core 5.26.31 (run harness jars), `run-cypher.mjs`, `query.mjs` | all fixtures, validators, queries | available (run) |
| `@neo4j/graphql` 7.6.3 (run harness `node_modules`), `build-schema.mjs` | fragment build with stubs, GraphQL round trip | available (run) |
| Python 3 (`hashlib`, `unicodedata`, PyYAML) | NFC-WS1 quote hashes, generator, YAML check | available |
| Not used | bioRxiv, ICD-10, NPI, WebFetch/WebSearch; Exa, bigdata.com (failed to connect) | not needed / unavailable |

## Research questions and outcomes

- BEST biomarker categories and surrogate levels: **confirmed** (S2 FDA restatement; S3 Bookshelf search extract — the glossary page itself BLOCKED).
- FDA surrogate table: **confirmed** columns and LDL-C rows; LDL-C listed in two contexts (S1, scraped 2026-10-04, page revision 2026-04-29).
- Biomarker-primary / clinical-secondary trial: **NADPARK NCT03816020** (S4); significance of its primary and prespecification of the responder analysis **not established** (full text blocked).
- NIAGEN vs Basis dose basis: **settled** — Conze Methods state NR chloride capsules (SALT_FORM); the Basis trial paper states "125 mg of NR" with no salt (UNSPECIFIED); both labels declare the chloride; label directions give 1 serving/day (Basis) and 1–3 capsules/day (Tru Niagen).
- Systematic review versioned after new trials: **vitamin D / ARI** 2017 → 2021 → 2025 (CI now includes 1); the identity of the n=15 804 trial is **not established**.

## Deliverables

All eight deliverables plus `sdl-fragment.graphql`, `migration-map.yaml`, `seam-requests.yaml`, `operations.cypher` and `fixtures/` (5 positive fixtures, 1 negative fixture with 22 cases, 15 queries, generator, stubs, GraphQL round trip, run script, run results).

## Execution summary (run)

- Fragment: graphql-js parse OK alone; `Neo4jGraphQL` 7.6.3 build OK with stubs (1278 types); no delete mutation for W10 types; judgement fields not updatable (M1–M3 rejected).
- Positives: 68 statements, all ok, after the inherited fixture (44/44). Baseline validation 174/174 executed: only the baseline's informational rows, all from inherited content. W10 validators: zero rows on W10 nodes; rows on inherited nodes only (W10-V13 1, W10-V16 2, W10-V16b 1 → W10-SR-08).
- Negatives: 22 cases, every case reported by its named check (06-fixtures-and-queries.md table).
- Queries: 15/15 run with the documented rows.

## Unresolved seams

W10-SR-01 (uid tokens), W10-SR-02 (W21 ClaimEvidenceAssessment contract / ASSESSES_CLAIM name), W10-SR-03 (register ContextOfUseMatch, MeaningfulnessVerdict), W10-SR-04 (kernel: CONSIDERS_ASSESSMENT domain), W10-SR-05 (kernel: no-backdating for assessments), W10-SR-06 (REPORTS_POOLED_ESTIMATE; INV-206 for pooled analyses), W10-SR-07 (uid on archetype interface), W10-SR-08 (inherited fixture repair), W10-SR-09 (W04 label directions assertion), W10-SR-10 (W23 personal applicability contract), W10-SR-11 (forbidden implications answering W14-SR-04 and W06-SR-10). Inbound requests answered in the ledger: W02-SR-09 (adopted), W03-SR-11 (adopted), W05-SR-13 (declined), W05-SR-18 (CONSIDERS → CALCULATED Assertion), W06-SR-10 (declined range extension; FI registered via W10-SR-11), W14-SR-04 (answered).

## Confidence by dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Boundary and dispositions | high | catalog module, rounds 0002/0003/0008, live and delta lines mapped (23 migration rows) |
| SDL validity | high in isolation | parse + 7.6.3 build + round trip; merged-schema build not run (Fable) |
| Invariant enforcement (V-2xx + W10-V*) | high on fixtures | every negative caught; positives clean |
| Enum values vs BEST/FDA | high for categories and FDA columns; medium for surrogate level wording | S1, S2 direct; S3 search extract only |
| Dose-basis facts | high | first-party Methods text and labels |
| Calibration | not attempted by design | DEFERRED; requirements stated |
| Real-source excerpts | medium | connector text; partial captures; no byte hashes |

## Review status and qualifications

Self-reviewed against the worker brief and contract B; not reviewed by another worker. Qualified: CANDIDATE elements (`UseContextProfile.servingsPerDay`, `intendedDurationIso`, enums `ContextOfUseMatch`, `MeaningfulnessVerdict`, predicate `REPORTS_POOLED_ESTIMATE`, validators W10-V01…W10-V16b), the method rule W10-V11b, the "identity ratio 1.0 only" rule pending calibration, Enterprise constraints (not run), and the ATLAS subgroup (synthetic, W09's device).

## Artifact digests (SHA-256)

This file's own digest is not listed.

```
3b3fc04cca50e0932f48ed358baaadca2fb7e34b58a50ff82a72ac63c45f8df0  01-domain-recommendation.md
e773a06db0470fb1659218ea5ab09242a2886300bb6a5078f0c45e0872fb1d26  02-cq-coverage.md
cf6e4ebcbc63609ff7dab7d3233a32343bfdfefde4b2ef6fcd6565093fa90c5b  03-source-manifest.md
58adcfb9a7d81d7a0c1075bf87005eaa35b134c4737c2f2c478490d1f0eac37a  04-model-cards.md
a012e537a5715f352dbf613af4c743934b02c5a536d7919e82d5aed266c60f35  05-decision-seam-ledger.md
9f105f671998d6f327d1fbb57323b8f3240904a6f0c24e10a438e7a9e1798c93  06-fixtures-and-queries.md
993ea374af5208ab50a6e6458e06e7ae0db47a7dd46b1df4d156f2bf25398064  07-operations.md
d59039f49c0b8c7a26f1dda0b7e50b0433977848b1c4e068ac4135614b16a7ff  fixtures/gen_w10.py
5357c440c21de06404d68d87de1a2f9b15560f65145e8904529096b42f608641  fixtures/quote_hashes.py
1fa47572e7af581039fe9504e34389f93f38a57ce81865e5c667a8fc5d2b6884  fixtures/run-graphql-2026-10-04.txt
9c356875d27315f7d46f5a48f16495b5f99fe38ae138b26a66e9384d68f95ed1  fixtures/run-results-2026-10-04.json
7731cb91183575fa1961f385ae4a29659787be548ab66509f415392876941e6b  fixtures/run-w10.sh
25a99a4cc6ae5867a11a902edbad01ed2da8c82d6540ce9a1f12349895bcf31c  fixtures/w10-01-applicability-basis-13dim.cypher
594d1b36b8ad5392ec5c4c29d87edbb5a9e833663af98eb548bd4d6fd1391072  fixtures/w10-02-dose-ratio-minimal-pair.cypher
3f6263ac0e720b570963f609ee0529c90254c2579c0ebaaf83d2142f107f609d  fixtures/w10-03-surrogate-context.cypher
edf29049abf0cc87173939dd2c7f45a67092e5280a5e18812dde74e472d04005  fixtures/w10-04-null-primary-synthesis.cypher
a900647b69ebe4df7bf0c15c6a03203bf683ababacff5bdca00835a3738e4159  fixtures/w10-05-synthesis-versioning.cypher
ac40f9386246d86782cd40b000d7d7c7399ffbd22e2b7a98ab26e2c651e37359  fixtures/w10-80-queries.cypher
a65645bc4caba61664219e83d3741765b57dcc093d2c6ea44b892bc07d70483d  fixtures/w10-90-negatives.cypher
5622ceef211c8c25c4093bfd213e1ba089b1d73767dcedf96382672ea16a4733  fixtures/w10-gql-roundtrip.mjs
993c27adeca3b183309a19ca71240f2a4f79b1babd9bb593cb4d65d0d48d59de  fixtures/w10-params.json
35b553e3bfe3c70eb67a48a46fbec2c69b91501a859bf9fc64186a9f5eefdf83  fixtures/w10-test-stubs.graphql
0708acc6d0dca672531cd58c6ffdf7e07b8fa557dac128303bf04542bee6d97a  migration-map.yaml
788eef8924ed27712486c4806e766415f9158e4504dbf66ffd21e9f79bfa5f44  operations.cypher
8b487522325cf2db62f9d3280a9981579e168bc32f0f049ece4ba2d7e7fb52a6  sdl-fragment.graphql
28e29826ebdf35044080faeff7eca834f9586e65a14feea20b4dc2210fe8e8f0  seam-requests.yaml
```
