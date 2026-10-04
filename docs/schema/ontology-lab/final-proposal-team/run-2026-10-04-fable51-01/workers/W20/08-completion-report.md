# W20 08 Completion report

- Worker: W20 Documents, text versions and chunks. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start: 2026-10-04T00:43Z (first read of the run files). End: 2026-10-04T01:15Z.
- Wrote only inside `workers/W20/`. Did not touch the live schema, catalog, rounds, other workers' directories or the run's numbered files. Used a private Neo4j data directory under the session scratchpad; Fable's running instance was not used.

## Tools actually used and availability

| Tool | Use | Availability |
|---|---|---|
| PubMed MCP `convert_article_ids`, `get_full_text_article` | NiCE trial PMCID and JATS-derived full text (S2, S5) | available; first call RATE_LIMIT_EXCEEDED, retry succeeded |
| Tavily `tavily_extract`, `tavily_search` | PMC HTML, Nature HTML, Huberman Lab page, YouTube transcript, YouTube Help, W3C spec (S1, S4, S7–S10) | available |
| Firecrawl `firecrawl_scrape` (pdf parser) | publisher PDF pages 1–3 (S3) | available |
| curl (direct NCBI idconv, direct Nature PDF) | fallback | **BLOCKED** (proxy 403); recorded, not treated as absence |
| Neo4j 5.26.31 Community (run harness jars) + `run-cypher.mjs` | all fixtures, queries, validators, index probes | available (run) |
| `@neo4j/graphql` 7.6.3 (run harness `node_modules`) | fragment build (fragment + stubs: 788 generated types), GraphQL round trip, `assertIndexesAndConstraints()`, library code read | available (run) |
| Python 3 `unicodedata`/`hashlib` | offsets, NFC-WS1 hashes, generators | available |
| Not used | ClinicalTrials.gov, bioRxiv, ICD-10, NPI, WebFetch/WebSearch, Exa (failed to connect) | not needed / unavailable |

## Research questions and gaps

- Settled (03-source-manifest.md): PMC HTML vs connector JATS-derived text offsets (199 vs 190 code points for one sentence; quote hashes differ); PDF vs HTML (line wraps absorbed by NFC-WS1; word fusion, footer interleaving and ligature splits not); publisher transcript vs YouTube transcript (wording, casing, speaker labelling, timing differ).
- Gaps: the PMC XML itself was not retrieved (only the connector's text), so the dropped elements are inferred to be inline-tagged; the connector's endpoint and converter version are undisclosed; raw PDF bytes not hashed (direct fetch blocked); whether the YouTube track is automatic cannot be established; no audio was heard or verified; publisher HTML Primary-outcomes paragraph not returned (PMC HTML used); V-112 not run (parameterised).

## Unresolved seams (see seam-requests.yaml)

W20-SR-01 (RESOLVES_TO_CHUNK ruleOnly), -02 (uid token `segmentation`), -03/-04 (registry: DocumentAuthorTarget, RetrievalEdgeProperties), -05 (WAS_GENERATED_BY on Segmentation), -06 (does a re-anchored locator join an assertion's support?), -08 (Source reads Document's stored names), -09 (content-derived uid segments), -11/-12/-13 (HAS_SNAPSHOT, ABOUT, MENTIONS name collisions), -14/-15 (W21 fields, HAS_TRANSCRIPT removal), -16/-17 (domain owners' support fields), -18 (adopt W20 validators), -19 (offset unit wording), -20 (matching-only normalization), -21 (connector Source identity), -22 (QS-8 name bug), -23 (repair example fixture), -24 (@deprecated).

## Confidence by dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Boundary and dispositions | high | catalog, round 0006, live schema lines read; every live W20 element mapped (129 rows) |
| SDL validity | high for the fragment in isolation | graphql-js parse OK; `@neo4j/graphql` 7.6.3 build OK with stubs; merged-schema build not run (Fable) |
| Alias behaviour | high | Cypher + GraphQL round trip run; library index assertion run, positive and negative |
| Offsets and normalization | high | executed on Neo4j and Python; W3C text retrieved |
| Validators | high on fixtures | run; positive zero rows, every negative caught |
| Real-source claims | medium | partial excerpts via third-party extractors; hashes cover stored excerpts only |
| Transcript/caption semantics | medium | platform help text; track origin unknown |
| Retrieval partitions/vector | medium | small run (4-dim index); no retrieval evaluation |

## Review status

Self-reviewed against the worker brief and contract B; not reviewed by another worker. Qualified items: everything marked not-run (merged-schema GraphQL round trip, V-112, Enterprise constraints), the CANDIDATE `RetrievalEdgeProperties`, and the inferred causes of connector text loss.

## Artifact digests (SHA-256)

This file's own digest is not listed (it would change by being listed).

```
926a8e3a94e1fe0b8e1fd2b5ab3c9545d421479cd8c46d0a21bc6343a946a887  01-domain-recommendation.md
9042ea203e97e895d60bf300af8d1f43f1d00f547ea20e595586ec0bf8667a22  02-cq-coverage.md
aa1e9ec6f080e536947d63548e3fe294753d86a31ad8ecb96a41fc6b989bfef3  03-source-manifest.md
501b64dc886e35e4ee93f149a6b7af0cbda669f908fafd55c8b4366718ae0f41  04-model-cards.md
4e933172d449071349cbd0b6bdaf0b168cfa9a73b41351ab8e1c81ba59e91d2f  05-decision-seam-ledger.md
1d79c62d094686e5738b1441e159bc78b2e1a704ac0770f3f16c1945c25dd04d  06-fixtures-and-queries.md
252eb25f28fa9ec01c8d18de6e6b28701a5b5916a5b9411fa0168b7df6b785d5  07-operations.md
2ef822b0358ebdd73fdb8aacb58db104d24580aec28fef6019b5b29a8f3c568b  sdl-fragment.graphql
b1b45cbc58c358142c1f43846a8c17a69e4d7b66c477d0658cc578a3b20a17fd  migration-map.yaml
07c0b62e9b83d48be9d99251c96a8f98f2bcb47c73c92d67505bf7a828bbcc8f  seam-requests.yaml
5a9bc860d0726b4eb6e8e4bb819de765a1bebe047799076ef2dbaf708fa7f4d1  operations.cypher
52ba41d01b15d0290c5cfe86d6d4203b42c751dc0cc9f6adb8e9c5a0cd8e8946  fixtures/gen01.py
5d1f4aea871c92789ffe8b2abd3d330b31b18bdfddf29f6af5b2758163ed7f56  fixtures/gen04.py
8d65db44d5a3511ce547951871435e00584cf6de142c7d13c44adc5d17cdc04f  fixtures/w20-01-resegmentation-vs-correction.cypher
cd4d048b0c600ade80670fddede48e13e57931d5f317dd637a35e640cdddfa40  fixtures/w20-02-negative-chunk-support.cypher
dd51c0621aca41d9f81cad5a80aa1d6473ea2bb7ccc2e0f4fc3b1f300ff5247e  fixtures/w20-03-alias-roundtrip.cypher
9c0262b756c18e62093bfd5a7aabdf01bede0b611f69ba07da10de0db6d22855  fixtures/w20-04-text-version-pairs.cypher
6bdfeebff3e86b9769d71000c8b516ff735225eea1f31b91e5fe5d109828d7d9  fixtures/w20-gql-roundtrip.mjs
728b344b87364395a21782d7f86636b812c7bc4d410f8cb06149dd20de2353ad  fixtures/w20-queries.cypher
5976b29cf2f1cd7e7f5e86ff3f74a102305f0c1a4f928eb1ab621a10074ad5f9  fixtures/w20-test-stubs.graphql
```
