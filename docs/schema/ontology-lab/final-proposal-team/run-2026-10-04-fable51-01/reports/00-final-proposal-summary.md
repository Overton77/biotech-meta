# 00 Final proposal summary (run-2026-10-04-fable51-01)

Synthesizer: Fable 5.1 (`claude-fable-5-1`, identity verified through the session API: configured and last-served model). Workers and Challengers: Opus 5.5 subagents, 24 research packets W00–W23, five Wave 5 Challengers, one seam-closure integrator, one corrections compiler. Baseline: catalog 0.2.0 at HEAD `530e05c` (digests and the two handoff digest mismatches in `00-baseline.md`). The live schema `docs/schema/current_biotech_schema.graphql` was never modified.

## Deliverables

| Deliverable | Path | State |
|---|---|---|
| Final standalone schema | `docs/schema/final_biotech_schema_proposal.graphql` | 192 node types (Entity 91, VersionedState 33, InformationArtifact 34, Occurrence 9, Assertion 5, EvidenceAssessment 20), 47 relationship-property types, 11 interfaces, 39 unions, 183 enums (1,418 values), 1,082 relationship fields over 393 relationship types, 31 fulltext and 3 vector index declarations; 24 domain banners; builds with `@neo4j/graphql` 7.6.3 (BUILD OK) |
| Executable operations (Community-verified) | `docs/schema/neo4j/final_biotech_schema_operations.cypher` | 1,155 statements: archetype and per-label uid/id uniqueness, relationship-episode identity and recordedFrom indexes, fulltext and vector indexes, packet-specific constraints (5b), live-graph migration (6, 6a, 6b label backfill), normalization (7), capability matrix (8), parameter notes (9); all applied on a fresh Neo4j 5.26.31 Community instance |
| Enterprise companion | `docs/schema/neo4j/final_biotech_schema_operations.enterprise.cypher` | 1,383 existence/type constraints; every statement rejected by Community (recorded), unverified on Enterprise |
| Run record | `docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/` | baseline, shared contract, ownership registry, conflict ledger, worker brief, 24 packets, validation harness and evidence, reports 01–08 |
| Catalog bookkeeping | `docs/schema/CHANGELOG.md` (Unreleased section), `docs/schema/OPEN-QUESTIONS.md` (status section) | reasoned changes only, each with its ruling id |

## Reports (this directory)

1. `01-domain-coverage.md`: 126/126 competency questions owned and executable (123 by packets, 3 kernel queries); 82 candidate questions.
2. `02-ownership-and-seams.md`: all 18 seeded conflicts ruled; 5 transfer placeholders closed; 389 seam requests accounted for.
3. `03-decision-report.md`: D-001..D-016 status, MR-01..MR-12, registry admissions, fixture repairs, Wave 5 rulings F-W5-01..16, Challenger resolutions (section G).
4. `04-seam-closure-ledger.md`: 105 injected fields on 30 types, union/enum additions, dispositions per request.
5. `05-source-manifest-summary.md`: sources by packet and authority class.
6. `06-migration-and-compatibility.md`: 1,864 old→new rows, headline table, five compatibility rules.
7. `07-validation-report.md`: the Wave 6 run (plan, results by block, failing steps and their reading, edition gaps).
8. `08-challenger-resolution-matrix.md`: 112 objections, dispositions, mutation evidence, fixture defects.

## How to read the schema

Every node carries `@node(labels: [primary, parents..., archetype])`; `uid` (`hu:<token>:<opaque>`) sits beside the live `id`. Truth is assertion-centred: asserted edges carry `AssertedEdgeProperties` (assertionUid, relationshipUid, bitemporal half-open intervals with basis and precision), derived edges carry `DerivedEdgeProperties` (projectionOfAssertionUid or derivationRule + inputs), structural edges carry `StructuralEdgeProperties`. `privacyClass` is `PUBLIC`/`INTERNAL`, null is not public, and it is a field of the `Entity`, `ActorIdentity` and `SearchIndexable` interfaces so every interface or union read can be filtered. Legacy live edges are read-only (`@settable(onCreate: false, onUpdate: false)`), stored under their legacy type where renamed (`LEGACY_EVALUATES`).

## Validation evidence in one paragraph

The schema builds (`@neo4j/graphql` 7.6.3, BUILD OK). On a fresh Neo4j 5.26.31 Community instance with APOC Core, the operations file applied in full (1,155 statements, 0 errors) and the Enterprise companion was rejected statement by statement as expected. The six translated 0.2.0 fixtures load, the compiled final suite (428 statements: 0.2.0 minus superseded ids, W00 corrections, V-F5-01..65, generated label checks) returns only informational rows on them, the three kernel competency queries and all 17 query shapes EXPLAIN, and the GraphQL round trips pass. The 512-step plan over all 24 packets ends at 439 PASS / 68 FAIL / 5 recorded as the runner scores it, and 448 PASS / 29 fixture-row steps / 13 changed-expectation steps / 16 union load collisions once one informational policy is applied; every failure is attributed in `07-validation-report.md` section 3 and none is a schema failure. Five Challengers raised 112 objections; 84 are closed by tested validators, the rest by schema, operations, fixture or query-shape changes, 14 parts deferred with reasons (`08-challenger-resolution-matrix.md`).

## Edition gaps and user-input blockers

- **Edition.** Existence and type constraints are Enterprise-only and unverified; Community deployments rely on the validators and the ingestion service (decision needed: deployment edition).
- **Vector indexes.** Dimensions and embedding source for the three provider-less `@vector` indexes.
- **Public tier.** The operator SDL is the full schema; the PUBLIC_ANSWER surface must be a derived sub-schema (W23) built against this file (OPEN-QUESTIONS, new item 1).
- **Unchanged from the handoff.** EU/UK `AUTHORIZATION` status kind, crawler-terms capture policy, k-anonymity threshold, PostgreSQL 18 `WITHOUT OVERLAPS` for the private store.
- **Fixtures.** Seven inherited sources keep `doi.org` resolver URIs as `canonicalUri` (needs network resolution); two inherited syntheses have no claim node.

## Where each kind of question is answered

- "Why is X named/typed this way?" → `03-decision-report.md` (D-, MR-, F-W5- ids) and the owner packet's `05-decision-seam-ledger.md`.
- "What happens to live element Y?" → `06-migration-and-compatibility.md` and `workers/Wxx/migration-map.yaml`.
- "Which source supports Z?" → `workers/Wxx/03-source-manifest.md` and the fixture headers.
- "Was it executed?" → `07-validation-report.md`, `validation/wave6-final.json`, `validation/challengers/`.
