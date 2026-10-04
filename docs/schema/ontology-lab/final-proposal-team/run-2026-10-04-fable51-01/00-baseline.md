# 00 Baseline (immutable)

Recorded by Fable 5.1 at run start, 2026-10-04.

## Repository state

- Branch: `claude/compassionate-shannon-gtvpks`
- HEAD at run start: `530e05cd116cfb9a58d6700dd6e363ae430fe32e` ("Add the domain-discovery handoff that splits the schema research.")
- Discovery checkpoint HEAD named by the handoff: `9737a8359bdd3b61298af65ea13b5178b3ff90ce`. `git diff --stat 9737a83 HEAD` shows only the three handoff/review documents added (445 insertions); no authority file changed between the checkpoint and this run.
- Working tree at run start: clean (`git status --porcelain` empty).

## Digest discrepancy recorded against the handoff

The handoff's section 1 table records SHA-256 values for three inputs. Only one matches the files as they exist at both the checkpoint commit and HEAD:

| Input | Handoff table value | Value at 9737a83 and at HEAD | Match |
|---|---|---|---|
| `docs/schema/current_biotech_schema.graphql` | `86b5e0b5…f112` | `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112` | yes |
| `docs/schema/catalog/schema.yaml` | `3172ecdc…13ad` | `8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0` | **no** |
| `docs/schema/neo4j/proposed-delta.graphql` | `8becc611…3ed` | `565d8a46313a8a3b4fb14355dbac760d4eef0459f32706d0d9a4b5147ca2048a` | **no** |

The two files have not changed since commit `6c6089b` (before the checkpoint), so the handoff values were computed over different bytes (most likely a CRLF or normalized copy) and are not evidence of a later edit. This run admits worker packets against the digests below, not the handoff table.

## Authority input digests (SHA-256, bytes as committed)

```
86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112  docs/schema/current_biotech_schema.graphql
8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0  docs/schema/catalog/schema.yaml
565d8a46313a8a3b4fb14355dbac760d4eef0459f32706d0d9a4b5147ca2048a  docs/schema/neo4j/proposed-delta.graphql
917d24d7accf95758d47f8e471ed11d222984be819ef2476960a9d9a87bd6879  docs/schema/neo4j/constraints.cypher
4cda8ab250f22892948da245c1479de54bcf29c5d0e095392744c128c924d42a  docs/schema/neo4j/validation.cypher
1fad4c3fe423d36a1fa10d683645f0a07d8ebd4196d772659aa95a6153e53bc5  docs/schema/architecture.md
5ba89e888972d31e442c9402cc2fa82293484ca33b1076e6056fb3b0a1791e5e  docs/schema/README.md
302cfa7abb9ef8d8e5e6be0b1d18f79f52c31a8f980a47c6c908c523b74d93bd  docs/schema/OPEN-QUESTIONS.md
b766eb4e455ef1fe3c641e61c89dce8c57a5664bbe9adf17fc0f941563648c82  docs/schema/CHANGELOG.md
f4b9e2266cb544b25977a494133a81b56e8bb4b396a5e3bf7a0a8072a3739fcc  docs/schema/sources/source-registry.yaml
7fff4b84d335c4324e50510ba9de4ad36e1a4fcf74829ec98a9f5daef53d295d  docs/schema/ontology-lab/proposal-index.md
e714740053f8872ffb69c0ecf17954ea07f59b622c81e82dea3d9aa4de715fa3  docs/schema/ontology-lab/competency-questions.md
833c36c1b1712b0ec51a4de41a05bd369f66362c5cb7e0e366adba51bc08652b  docs/schema/ontology-lab/query-shapes.md
d820a0cb30fd6fa9e3064337b05e220828f1f47b2c93f7a7858ab622724b7d7a  docs/schema/ontology-lab/modules.yaml
d26636d1a93bce8cca9d57a57f6d2b525d6e5270daf70729e665287516fc3807  docs/schema/ontology-lab/projection-contract.yaml
9615f9f4ceb0277884f2d6cb8f4bc090fb2cc3ec58276495f0b61ab27b2599bb  docs/schema/ontology-lab/live-schema-alignment.md
188fb0bda562959bba0e72edda84e570b04931b7eadd95422ade656225a8659b  docs/schema/ontology-lab/property-cards.md
ba0fa69750a279c7b595a9a12ddec799f9c99c8a49dd385d3f4b92ebcfa14c66  docs/schema/ontology-lab/domain-discovery-and-cursor-team-handoff.md
83e9828249a25a61ce8207a176c680461aa71edac1f0aae2f3e08fcd6c92a2d3  docs/schema/ontology-lab/domain-discovery-independent-review.md
0b3d4a45fd301a56e91607215a4ece1a19e81ee4ad2c323f27e7ce8ff29cc641  docs/schema/ontology-lab/media-protocol-independent-review.md
c9dd45ff7b0813aa85fd13058cb8a0a17013a6091009f42959ce3b4b5984a9b5  docs/schema/examples/claim-retelling-provenance.cypher
522f8f4179d944be95e5dbeac0bf25a5b9b4fdabffa23f331fc0cdccf1913927  docs/schema/examples/diagnostic-comparison.cypher
89026f11f7386bb33b218d55a5e0432eb735ca8ccdc1832c37e421270657740a  docs/schema/examples/elysium-basis.cypher
6d90fd929f896430d13bc8170a66df9b906fc34a67bccb7c51de1bc609e7f30c  docs/schema/examples/filing-vs-capability.cypher
2f144604179dafa542b3eda01e08a3f465f6047b39f3ee84069cbb6cb82d64b5  docs/schema/examples/recommendation-snapshot.cypher
18b4597be0ad6e11ed2a1cb6245183c15a1975f3423c1b0876b1d6bdf4e8d476  docs/schema/examples/study-vs-product-mismatch.cypher
dbada2d390953d92a023b631de25540024fdc75339f08b75bb78eb9beda5d169  docs/schema/ontology-lab/round-0001-product-continuity.md
6e5fd67f9b72f092ce2a3ec8fa1208c6df0617e4452e3c191f4f0b6b54eff681  docs/schema/ontology-lab/round-0002-study-intervention-versus-commercial-product.md
07fe4fcf9da539d8417fe83f55c961e5458276a024f1f9093fffedbca355f965  docs/schema/ontology-lab/round-0003-mechanism-measured-versus-inferred.md
05c497bc0047eda083789930c36084d266a4a8a8badd4a12bc24f40f98073b99  docs/schema/ontology-lab/round-0004-diagnostic-comparability.md
3835973af381b900dfa459d4a2c5cf40348476dd6b192d00664968ffeee1e37d  docs/schema/ontology-lab/round-0005-filing-versus-capability.md
5da0ae584d567f09e0f4a155a5e0319007e987b44b1197fccad4efb427ec8cc7  docs/schema/ontology-lab/round-0006-claim-and-document-provenance.md
c51f2dca8fd664d71e040beb3dd128e5fb2b44cd80af499f03629f3130699e61  docs/schema/ontology-lab/round-0007-bitemporal-corrections-and-late-facts.md
8c9615480e53b38599309abafa779c275d43a59513e4e42b47b1a35cbb8a4181  docs/schema/ontology-lab/round-0008-private-recommendation-history.md
60a07bf32efcd76b3e6c1f7ec2e26296741b87b0b5c529d2d8eb58b88ff31b10  docs/schema/ontology-lab/round-0009-question-catalog-and-access-tiers.md
```

Known documentation gaps confirmed: `docs/adr/0002-assertion-centered-temporal-knowledge-graph.md` is absent from the checkout (README link dangles); its contents are not invented here. `CONTEXT.md` named by the README workspace contract is also absent at the repository root.

## Runtime inventory and pins

| Component | Value | How established |
|---|---|---|
| Node | v22.22.0 | `node --version` |
| npm / pnpm | 10.9.4 / 10.28.0 | CLI |
| `@neo4j/graphql` | **7.6.3** (npm `latest` on 2026-10-04; `lts` tag is 5.12.15, `previous` 6.6.4) | `npm install` into the run harness; `node_modules/@neo4j/graphql/package.json` |
| `graphql` | 16.14.2 (library peer `^16.0.0`) | installed |
| `neo4j-driver` | 6.2.0 (library peer `^5.8.0 \|\| ^6.0.0`) | installed |
| Neo4j test target | **5.26.31 Community**, in-process via `org.neo4j.test:neo4j-harness:5.26.31` and `org.neo4j:neo4j:5.26.31` from Maven Central, OpenJDK 21.0.11 | `CALL dbms.components()` returned `Neo4j Kernel 5.26.31 community` |
| Neo4j Enterprise | **not available**; existence/type constraints remain unverified on Enterprise | Community rejects them (see replay) |
| Docker | client 29.6.2 present, **no daemon** | `docker info` fails |
| `dist.neo4j.org`, Docker Hub, GHCR | blocked by the egress proxy (403/401) | curl |
| Maven Central, npm registry, PyPI | reachable (Maven returns 429 under burst, retry succeeds) | curl |

`@neo4j/graphql` 7.6.3 directive set present in the installed build: `alias coalesce customResolver cypher declare-relationship default filterable fulltext id index jwt-claim jwt-payload limit mutation node plural populatedBy query relationship-properties relationship relay-id selectable settable sortable subscription timestamp vector`. **There is no `@unique` directive** (removed in v7); uniqueness is created only by Cypher constraints.

## Baseline facts established by execution at run start

1. **Live schema under 7.6.3.** `docs/schema/current_biotech_schema.graphql` parses with graphql-js. `new Neo4jGraphQL({typeDefs}).getSchema()` **fails with 11 errors** `@vector.indexes specifies a provider, but no vector providers configuration exists` (one per type carrying `@vector(... provider: OPEN_AI ...)`) unless a vector-provider feature configuration is passed. With `features.vector.OpenAI = {token, model}` supplied, the live schema builds: 17,307 generated types, 265 queries, 273 mutations, 16.06 MB printed SDL (11.5 s). This is a deployment fact the OPEN-QUESTIONS live-stack list did not have.
2. **Directive probe.** A probe schema using `@node(labels: [...])` with two and three labels (including `["ClaimOccurrence", "Assertion"]` and `["Document", "Source", "Entity"]`), archetype GraphQL interfaces beside the live `Entity` interface, `@alias`, `@timestamp`, `@settable(onCreate: false, onUpdate: false)` on a legacy relationship field, and `@relationshipProperties` with non-null fields builds under 7.6.3 (215 generated types). `@unique` is rejected as an unknown directive.
3. **Baseline constraint replay.** `docs/schema/neo4j/constraints.cypher` on the fresh 5.26.31 Community database: 57 statements, **45 applied, 12 rejected** (all 12 are the annotated property-existence and property-type constraints). This reproduces the 2026-10-03 record in `proposal-index.md` section 9 on a different patch release (5.26.31 versus 5.26). `CREATE DATABASE` is unavailable on Community (single database); isolation between scenarios is achieved by restarting the in-process instance with a fresh directory.

The harness (`validation/`) records the exact scripts: `build-schema.mjs` (library build with and without a vector provider), `run-cypher.mjs` (statement splitter that never shares variables across `;`, per-statement result and error capture), `query.mjs`, and `EmbeddedNeo4j.java`.

## Research tools inventory (for workers)

Connected in this session: PubMed (`mcp__PubMed__*`), ClinicalTrials.gov v2 (`mcp__Clinical_Trials__*`), Firecrawl (`mcp__Firecrawl__firecrawl_search`, `firecrawl_scrape`, research paper tools), Tavily (`mcp__Tavily__tavily_search`, `tavily_extract`, `tavily_crawl`), bioRxiv, ICD-10, NPI Registry, generic `WebFetch`/`WebSearch`. Failed to connect: Exa, bigdata.com, Figma, GitKraken. Egress goes through a proxy that returns 403 for some hosts (observed: `dist.neo4j.org`); a blocked fetch is recorded as blocked, never as absence.

## User-input items carried from the handoff (section 8), unchanged

Fable 5.1 availability is verified for this run. Still open for the user: broad-biotech expansion scope; deployment Neo4j edition/minor and GraphQL pin (this run declares 5.26.31 Community + 7.6.3 as the test target only); worker budget (this run queues 24 packages in waves on Opus 5.5); rights/use policy vocabulary, private-data retention, aggregation thresholds, applicability calibration.

## Additional library facts established after the freeze (same pins)

4. **Interfaces with relationships.** An interface field annotated `@declareRelationship` with implementing types using `@relationship` builds under 7.6.3 (`probe2.graphql`): a `DiagnosticResult` interface declaring `producedByAssayVersion` implemented by an `Observation` type. The contract therefore allows the catalog's `DiagnosticResult` contract to be a GraphQL interface with declared relationships.
5. **Provider-less vector index.** `@vector(indexes: [{indexName, embeddingProperty, queryName}])` **without** `provider:` builds with no feature configuration and generates a `search…ByVector(vector: [Float!])` query (no phrase argument). This is the form D-014 mandates; the live schema's `provider: OPEN_AI` form is the one that fails without a configured token.
6. **Baseline suite rehearsal.** The six 0.2.0 fixtures and the 174-query validation suite run on the embedded 5.26.31 instance and reproduce the recorded informational counts; V-110 now flags three Elysium assertions because that fixture stamps `recordedAt = datetime()` against a fixed adjudication `reviewedAt` of 2026-10-04T00:00Z (details in `validation/01-baseline-rehearsal.md`).
