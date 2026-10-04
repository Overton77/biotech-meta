# W00 completion report

- Worker: **W00 Kernel, identity, time and Evidence Provenance**, model **Opus 5.5** (claude-opus-5-5), run `run-2026-10-04-fable51-01`, synthesizer Fable 5.1.
- Start: 2026-10-04T00:47Z (first read of the run directory). End: 2026-10-04T01:44Z.
- Inputs admitted against: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112`, frozen contract `01-shared-contract.md` (not modified).
- Wrote only inside `workers/W00/` (plus scratch files in the session scratchpad, outside the repository).

## 1. Deliverables

| # | File | Status |
|---|---|---|
| 1 | `01-domain-recommendation.md` | complete: boundaries, archetypes, disposition of every live and catalog element in scope, alternatives, smallest model |
| 2 | `02-cq-coverage.md` | complete: 22 existing CQs + 1 candidate (CQ-AX-C01); every SDL element mapped |
| 3 | `03-source-manifest.md` | complete: 9 NEW_RETRIEVAL, 4 INHERITED, fixtures marked SYNTHETIC |
| 4 | `04-model-cards.md` + `sdl-fragment.graphql` | complete: 10 interfaces, 8 relationship-property types, 37 enums (36 contract B5 kernel enums except AccessTier/TraceDepth, + candidate RenditionCoverage), 13 node types, 3 unions (147 / 5 / 16 members) |
| — | `migration-map.yaml` | complete: 46 rows |
| 5 | `05-decision-seam-ledger.md` + `seam-requests.yaml` | complete: CL-003, CL-009, CL-011, CL-012 ruled/confirmed; 19 decisions; 16 requests (6 KCR, 2 validator fixes, 8 seams) |
| 6 | `06-fixtures-and-queries.md` + `fixtures/` | complete: 12 fixture files + common base, 5 query files, 38-statement validation suite, transactional guard harness, GraphQL test harness; all **run** |
| 7 | `07-operations.md` + `operations.cypher` + `operations-enterprise.cypher` | complete; Community file 53/53 applied; Enterprise file 0/34 on Community (by design) |
| 8 | this report | complete |

## 2. Tools actually used and availability

| Tool | Used for | Result |
|---|---|---|
| Firecrawl MCP (`firecrawl_scrape`, `firecrawl_search`) | Neo4j GraphQL 7 autogeneration, Cypher 5 MERGE/temporal/constraints pages, Crossref display guideline, APOC requirement snippet | available; all fetches succeeded |
| PubMed MCP (`get_article_metadata`) | PMID 9500320, 20137807 (F09) | available |
| curl → Maven Central | apoc-core / apoc-common 5.26.31 | available |
| Embedded Neo4j 5.26.31 Community (own instance; neo4j-harness jars from the run scratchpad), APOC Core 5.26.31 | all fixtures, validators, operations, GraphQL execution | available; first unbounded-heap instance was OS-killed under host memory pressure, rerun with -Xmx1500m |
| Node 22 + @neo4j/graphql 7.6.3 + graphql 16.14.2 + neo4j-driver 6.2.0 (run harness `node_modules`) | parse, schema build, query/mutation execution | available |
| ClinicalTrials.gov, Tavily, bioRxiv, ICD-10, NPI, WebFetch | not needed for the kernel questions | not used |
| Exa, bigdata.com, Figma, GitKraken | — | failed to connect (session notice); not needed |

## 3. Key findings for Fable

1. The fragment parses and **builds** under @neo4j/graphql 7.6.3 (with stubs for 154 foreign types) and **reads every Cypher-ingested fixture** (T1–T3), including union endpoints, relationship properties and DateTime/enums.
2. **APOC Core is required** for any DateTime read (W00-SR-14).
3. **`@id` cannot coexist with the uid rule on API creates** (T5a → V-117 row; W00-SR-02).
4. **Unions must not list a type and its label-superset specialization** (probe P-1 duplicates; W00-SR-11).
5. **Repository fixture shapes are unreadable by the final API** (no `id`/`updatedAt`, lowercase privacyClass, status 'FINAL', quantityBasis 'UNSPECIFIED', Document read as Source) — ingestion contract + migration rows (W00-SR-13, W00-SR-03).
6. **Precision-blind as-of classes mislead** at YEAR precision (F03); the precision-aware shape QS-W00-P is proposed.
7. The **transactional write guard** (subject lock + MERGE ON CREATE + in-transaction audit + rollback) works for asserter count, literal-xor-object, exclusive definite overlap, backdating and immutable content (F11).
8. Contract A2's merge redirect has **no EquivalenceKind value** (W00-SR-05; merges should not run until ruled).
9. Validator defects: V-432 (COMPARES vs COMPARES_IDENTITIES), V-112 (hypothesisUid), V-409/V-512 ordering clock (W19-SR-09 accepted).

## 4. Research gaps and unresolved seams

- Enterprise constraint behaviour unverified (no instance).
- Concurrent-writer test of the guard not run (sequential only).
- W22 MediaAnnotation geometry and the asset-to-snapshot path are not yet available; V-W00-03 checks only the edge and uid.
- Open: W00-SR-02 (API create path), W00-SR-04 (ResolutionStatus), W00-SR-05 (merge redirect), W00-SR-07/08 (relationship-name merges), W00-SR-09/10 (tokens, normalization id), W19-SR-01/03 forwarded frozen-enum values.
- Union planning cost (10.5 s cold for a two-union query) must be re-timed after Fable prunes the 147-member union.

## 5. Confidence (per dimension)

| Dimension | Confidence | Basis |
|---|---|---|
| SDL executability (7.6.3) | high | built and executed queries/mutations |
| Contract fidelity (A, B3–B5, B7) | high | interfaces/property types/enums copied from the contract; departures only via requests |
| Temporal semantics | high | minimal pair 8, late fact, YEAR precision run with expected rows |
| Write-guard pattern | medium-high | sequential execution; concurrency argued from documentation |
| Union membership | medium | candidate list from the registry; final membership depends on other packets |
| Operational performance | medium | single-instance timings on a loaded host |
| Enterprise companion | low (unverified) | no Enterprise instance |

## 6. Review status

Self-checked against the brief's fixture rules (per-statement uid binding, primary + archetype labels, registered tokens except the two requested, SYNTHETIC_FIXTURE hashes, real quoteHashes). Not yet reviewed by another worker. Fable may prune union members, adopt or reject candidate fields (`Source.renditionCoverage`, `PredicateClass`), and rule the KCRs.

## 7. What remains qualified

The 2009 prior PubMed snapshot and all pre-2026 BellLabs records in F09 are synthetic; F03 relies on a round 0006 capture W00 did not re-fetch; assertion `contentHash` values in fixtures are placeholders; Enterprise statements are untested.

## 8. Artifact digests (SHA-256, at completion; this report excluded)

```
    a97a6bc89978497773a1cbec1d26cc54c923ccd847e4341e512ed33257ff0e6e  ./01-domain-recommendation.md
    1ed3ba16b8c6d6ef91cae41155b023578860285401713443f2ce568709f4b2d7  ./02-cq-coverage.md
    18b7b4b8412d802958eb6a91eb2fc5cb5ac5b245590879bc423a81d2b38011ad  ./03-source-manifest.md
    0a619cd63aa8f5f87c6545572aa09b3afe3682e3fc9a81ec22dbebbbe5b5dfc0  ./04-model-cards.md
    9b9b3200b1af16fbc0ab6d52fe0bf0216d0609fa1c9b51044ce3a4a9ac94c525  ./05-decision-seam-ledger.md
    41facb02b2a04bc4eed125560bb83d95fc2af5f3f2dc3968405ab7156fb16e67  ./06-fixtures-and-queries.md
    8adde0fffad9d54be4fe1538c38c3081a61a098a74fcfd0e9567d7cd11561fa7  ./07-operations.md
    91349a618c527013d53bfc219c471b406c373b0a89e33c483a6da2c523d15141  ./fixtures/00-common-base.cypher
    0819f3430c66945c6e9dbc9a5985ede486b1f44b786a3ab0c3c5d5311acf576f  ./fixtures/01-correction-vs-validity-bounded.cypher
    0294697c63ecc2857acd51d0b79d4badb068d36968929c00fa84b7d193fb0e2f  ./fixtures/01-queries.cypher
    09514295e03d0511a5eb916477cd3e65768a2b2eccfa01041f57b6c30e445b31  ./fixtures/02-late-arriving-fact.cypher
    a0b7c59b75fc6a36e68d49afc6e09958a9074a337366b3f940ad576404e5ab6d  ./fixtures/02-queries.cypher
    85203a9c2f4d6a17b6c110f4299b87b31b6e2740dfc07fc3d0a3638e7d9c88e6  ./fixtures/03-queries.cypher
    3b058915879b49655063c332b7407a66f936fdc8a551b2d807f761d32b142fe6  ./fixtures/03-year-precision.cypher
    6919e4d370cef3d26ef7f99108e9d3d853cf7706383796f04ca8e7c65cb0a701  ./fixtures/04-two-asserters-must-fail.cypher
    2a857ceb84ffa4691ec8ee52045f19bc911a4d83696dddb6fb2f9bc2c5aca70a  ./fixtures/05-claim-occurrence-without-container-must-fail.cypher
    92e8ff18df4cc249974c3e271630a71e6d967d7e9b84fdf595b9798fc01ea3de  ./fixtures/06-two-archetype-labels-must-fail.cypher
    af318c6fc8d7bdeaec2d1efa2aa2c0f58cddd47acdeeaa104e08d550a4783726  ./fixtures/07-derived-edge-forbidden-premise-must-fail.cypher
    b839ef94d35040c7a0113bab99fe1744ba39ad3f32b3228fc762d37ede16bb9b  ./fixtures/08-identifier-across-issuers.cypher
    29970a43e425312d3a64ef55e085cbb15ab4f8353ac8a8a48b54d66deb9df82f  ./fixtures/08-queries.cypher
    f9c53a0fbf9ee3c86120ac0ae23a30d3493d74b656827ee44028dfbc6d19bf7a  ./fixtures/09-queries.cypher
    df6f96fd1c0e1485b2e2f2be5ce6d7e89f2f5b5b8c560b03a1f688cc72a90e47  ./fixtures/09-retraction-and-provenance-states.cypher
    e5fc7cdbfce77ae9017cfc10f5e5f4536064c88d91655329ffdeeb2a906a2e4a  ./fixtures/10-locator-kinds.cypher
    9c359b97543613372b928375860ab1c46703b1da777029a3e27fe3a237d77943  ./fixtures/11-write-guard-harness.mjs
    cf7d237da8fbbf17de59b21c19ec7c9d74eba3839d6c0cc30c3d76c04f9ea18e  ./fixtures/11-write-guards.cypher
    d61b8035d7e756b05719e4737fb03884a41d6fd5c1a13cabb3556e22f3fb502b  ./fixtures/12-legacy-shapes-graphql-readability.cypher
    d99a51074a72de225d292120ee55147ec0afa0059832488395a0021a4a8cdee3  ./fixtures/graphql-ops-T1.json
    26b4a688f4f3f51c5e1f49eadaff4b3f66097ccb5b113d9f4d377cf60bb68a4a  ./fixtures/graphql-ops-T2.json
    4acfa911efc4899dd7d5c0bfb9eb41e04d0f0ee5acf0681947c7afbf612677c2  ./fixtures/graphql-ops-T3.json
    86fe1a257ad924fca6ec1de6298513699098b0083b384d6561d7d1c0f985c8fc  ./fixtures/graphql-ops-T4.json
    7e32650f7dac3044b2be240eef45c6c14d73d670d9d1a3e9b056868f16052c68  ./fixtures/graphql-ops-T5.json
    b3f5a1501298e4e3e8de0001b6cf06a6d3eade768db5b8ccaf17f42b658d5220  ./fixtures/graphql-read-test.mjs
    56412a3306af1ec21fc6eb0116bc1bcb097fe80569b9dd1cf956fd2427536780  ./fixtures/results/F01.queries.json
    c746567da474696f8e5ac8f049a13656f1a4f42d3bb3aa7e3455e2b2cd655045  ./fixtures/results/F02.queries.json
    f0ff856ad1a489dfc550c31a612deee39ee75033671a60fecb84e024c329e9ff  ./fixtures/results/F03.queries.json
    4b56e1b2c12ca362e1d976fb5416d56e973e547e6a880e2b05abd7a21732d588  ./fixtures/results/F08.queries.json
    d7c02b595affef522f82a64f4cf8fcf8d983db37a9816ae7ffe7a4c567a9ffee  ./fixtures/results/F09.queries.json
    1849845887b48f03ff1a2faeff19afd376dcf61ee04b4d99a4b6e4c0094abeeb  ./fixtures/results/F11.guards.txt
    c7948b08d01db0f3382e381f770b9fb5096081b357a6f750fe0e4e9cb787b9b2  ./fixtures/results/build.txt
    c515f0a78e5f84a0cdf4fd4b5f638577af9b96037e2f9e013f7b7044b5946bfb  ./fixtures/results/graphql-T1.txt
    58ac11b72537c8d4ecd66e08868a45008e912ada1bedf9f0bcb67cd053741310  ./fixtures/results/graphql-T2.txt
    0507c538210edb62c6dc42d77233f6d8b1a169000810950ae0246166b53276b4  ./fixtures/results/graphql-T3.txt
    7cdfe9c46458b54276b00d6d742b904a63b38656592d432923c01e35bc842d97  ./fixtures/results/graphql-T4.txt
    3f31f9b7ef0bb98925acb6b4233fb65b5f681743ff61fe32e448557a1f81437f  ./fixtures/results/graphql-T5.txt
    234ac040c9986982a7e1c78d9a75d5f66aaaf444275e4134a089190473f1f4b8  ./fixtures/results/operations-run.txt
    1ce9a78692eb6bda7efb00975e64f2f8eca6d9de0bf58294766f299434fff0be  ./fixtures/results/probe-P1-union-specialization.graphql
    0e073d7faa6b20ab589d10d2ebc4431d47499b583d459e546d34b73adf44c6af  ./fixtures/results/suite.log
    c0ca7e090e4c00bc8c8db2f962d84dcff0889ba1cf9cb120e41f99f4768897f7  ./fixtures/validation-w00.cypher
    e1746827035a8294bdfe45b6c1b5417c95b4eb67607a3235570abbab304b927f  ./migration-map.yaml
    c9050ad5251fed98ee6229d22a4ab7ed92e19b60e0e1bd9dbf4f0f73e64023a2  ./operations-enterprise.cypher
    540ca11408ef27647a39813cb0945f8b4d2dc6429c324c36f8d669dd15db56da  ./operations.cypher
    6bec8976eee8ed26653626d1aee74fd262ac210a03ed040fdd6fbe85317b823a  ./sdl-fragment.graphql
    f8783f4038fa051874631393bab2b930584c546175e6dfe9a310bf74c899f8c1  ./seam-requests.yaml
```
