# W00 fixtures and queries

All fixtures and queries below were **run** on 2026-10-04 against an embedded **Neo4j 5.26.31 Community** instance (`org.neo4j.test:neo4j-harness:5.26.31`, OpenJDK 21, heap capped at 1.5 GB) with **APOC Core 5.26.31** (`apoc-core` + `apoc-common` from Maven Central, sha256 `12dee8c1…7dcf` and `d1c7f0de…8b4f`), `neo4j-driver` 6.2.0, `@neo4j/graphql` 7.6.3, `graphql` 16.14.2, Node 22.22.0. W00 used its own instance (never the shared one). Raw outputs: `fixtures/results/` (`suite.log`, `graphql-T1..T5.txt`, `F*.queries.json`, `F11.guards.txt`, `build.txt`, `operations-run.txt`). Tags: **run** = executed with recorded result; **parser-only** = parsed only; **not-run** = not executed.

Rules followed by every `.cypher` fixture: statements separated by `;`; every statement binds its own nodes by uid (no variable crosses `;`); every node carries its primary label and exactly one archetype label (except the deliberate negative in F06); uids use registered tokens except `mention` and `media-annotation` (requested, W00-SR-09); every snapshot uses `contentHashBasis: 'SYNTHETIC_FIXTURE'` (no bytes were stored); `quoteHash` values are real sha256 over NFC-WS1(`exact`); node writes use `MERGE … ON CREATE SET`; nodes written by Cypher carry `id`, `uid`, `createdAt`, `updatedAt` and their archetype discriminator so the GraphQL layer can read them. Assertion `contentHash` values in fixtures are placeholders (`sha256:synthetic-content-<id>`), not hashes.

## 1. Operations and validation suite

| Artifact | Result | Tag |
|---|---|---|
| `operations.cypher` on fresh 5.26.31 Community | 53 statements, 53 ok | run |
| `operations-enterprise.cypher` on Community | 34 statements, 0 ok, 34 rejected ("Unable to create Constraint …") — expected; Enterprise behaviour unverified | run |
| `docs/schema/neo4j/constraints.cypher` after `operations.cypher` | 57 statements, 45 ok, 12 rejected (the same 12 Enterprise-only statements as the baseline replay); no name conflict | run |
| `fixtures/validation-w00.cypher` (38 statements: catalog V-000a…V-512 kernel subset with inlined parameters, plus V-W00-01…12) | executed after every fixture on a cleared graph | run |

## 2. Fixture index and validation outcome

| File | Kind | CQs / rules | Expected validation rows | Actual |
|---|---|---|---|---|
| `01-correction-vs-validity-bounded.cypher` | positive, minimal pair 8 | CQ-TM-07, CQ-TM-01, CQ-EV-05, CQ-TM-06; TM-R1–R3 | none | none |
| `02-late-arriving-fact.cypher` | positive, late fact | CQ-TM-02, CQ-TM-03, CQ-TM-04; TM-R4, TM-R6 | none | none |
| `03-year-precision.cypher` | positive, YEAR bounds (inherited real quote) | CQ-TM-01 "possibly", CQ-TM-04, CQ-EV-01 | none | none |
| `00-common-base.cypher` + `04-two-asserters-must-fail.cypher` | negative + positive control | INV-003, KCR-4.3 | V-W00-01 ×1 (`w00-two-asserters-merged`, asserters 2) | as expected |
| base + `05-claim-occurrence-without-container-must-fail.cypher` | negative + positive control | INV-402, V-410 | V-410 ×1 (`w00-no-container`, containers 0, asserters 1) | as expected |
| base + `06-two-archetype-labels-must-fail.cypher` | negative | INV-001, D-001 | V-000b ×1 (archetypeCount 2); V-W00-08 ×1 (missing entityType) | as expected |
| base + `07-derived-edge-forbidden-premise-must-fail.cypher` | negative + positive control (e1) | INV-004, V-112, V-007 | V-112 ×3 (e2 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS; e3 CITED_PREDICATE_DIFFERS + FORBIDDEN_IMPLICATION_USED_AS_PREMISE; e4 same two); V-W00-11 ×1 (e4) | as expected |
| `08-identifier-across-issuers.cypher` | positive + negative statement | CQ-ID-04, CQ-AX-14; [SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY] | statement F08-dup rejected by `identifier_scheme_issuer_value`; V-W00-04 informational ×1 | as expected (error: "Node(…) already exists with label `Identifier` and properties `scheme`…") |
| `09-retraction-and-provenance-states.cypher` | positive; real PubMed records (NEW_RETRIEVAL) + synthetic history | CQ-PV-01, CQ-PV-03, CQ-PV-06, CQ-EV-02, CQ-EV-05, CQ-TM-06 | none | none |
| base + `10-locator-kinds.cypher` | positive + negatives | CL-011, CQ-PV-02, V-401, V-403, V-409 | V-401 ×1, V-403 ×1, V-W00-03 ×1 | as expected |
| base + `11-write-guards.cypher` via `11-write-guard-harness.mjs` | transactional guards | INV-003, INV-502, INV-505, INV-501 | G0, G1 COMMIT; G2 ASSERTER_COUNT, G3 LITERAL_XOR_OBJECT, G4 EXCLUSIVE_DEFINITE_OVERLAP, G5 BACKDATED_RECORDED_AT, G6 IMMUTABLE_CONTENT_CONFLICT → ROLLBACK; afterwards only G1's assertion and formulation persist; validation zero rows | as expected |
| base + `12-legacy-shapes-graphql-readability.cypher` | negative (ingestion contract) | D-W00-12, D-W00-16, W00-SR-01/03/13 | V-W00-08 ×3 (missing id/updatedAt/artifactType), V-W00-09 ×3 (privacyClass 'public'/'internal', status 'FINAL', quantityBasis 'UNSPECIFIED') | as expected |

## 3. Queries and expected rows (all run)

### 3.1 Fixture 01 (`01-queries.cypher`) — minimal pair 8

| Query | Viewpoint | Expected (round 0007 §7 table) | Actual |
|---|---|---|---|
| Q01-a | V=2026-04-01, R=2026-05-01 | A → fv1-200mg (a1); B → b-fv1-3g (b1) | same |
| Q01-b | V=2026-04-01, R=2026-07-01 | A → fv1c-120mg (correction; FV1 has no current attachment); B → b-fv1-3g via b1-bounded, validTo 2026-06-10 | same |
| Q01-c | V=2026-07-01, R=2026-07-01 | A → fv1c-120mg; B → b-fv2-2g | same |
| Q01-d (CQ-TM-07) | — | A: SOURCE_CORRECTION, revision event named, old state not attached → CORRECTED_RECORD_NEVER_HELD; B: VALIDITY_BOUNDED, old state attached → FACT_ENDED_STATE_KEPT_FOR_BOUNDED_INTERVAL | same |
| Q01-e (CQ-TM-01 status replay) | R=2026-04-10 / 2026-07-01 | cache SUPERSEDED both; as-of status ACCEPTED then SUPERSEDED | same |
| Q01-f (CQ-TM-06) | — | ERRATUM, issued 2026-06-14, learned 2026-06-15T08:05; a1 superseded by a2-corrected (SOURCE_CORRECTION) | same |

### 3.2 Fixture 02 (`02-queries.cypher`) — late fact

| Query | Expected | Actual |
|---|---|---|
| Q02-a | V=2021-06-01: R=2026-04-10 → `[]` (not recorded then); R=now → `[late-fv-2019]` | same |
| Q02-b | validFrom 2019-01-01 YEAR STATED; validTo 2025-11-01 INFERRED (`successor_state_start`); archive observedAt 2019-05-10; retrieved and recorded in 2026; episode recordedFrom = assertion recordedAt; recordedAt ≥ retrievedAt | same (all true) |
| Q02-c (QS-2c) | between 2026-04-10 and now: late-fv-2019 BELIEF_ADDED; nothing closed | same |
| Q02-d (QS-W00-P) | 2018-06-01 KNOWN_NOT_VALID; 2019-06-01 POSSIBLE_START_UNCERTAIN; 2021-06-01 KNOWN_WITHIN; 2025-11-15 POSSIBLE_END_UNCERTAIN; 2025-12-15 KNOWN_NOT_VALID | same |

### 3.3 Fixture 03 (`03-queries.cypher`) — YEAR precision ("possibly")

Q03-a, precision-aware (QS-W00-P) vs precision-blind (QS-2a) classes:

| V | BOARD_MEMBER_OF (2011–2017, YEAR) aware / blind | ADVISES_ORGANIZATION (2011–, YEAR) aware / blind |
|---|---|---|
| 2010-06-01 | KNOWN_NOT_VALID / EXCLUDED | KNOWN_NOT_VALID / EXCLUDED |
| 2011-06-15 | **POSSIBLE_START_UNCERTAIN / KNOWN_WITHIN (overstated)** | POSSIBLE_START_UNCERTAIN / OPEN_END |
| 2014-06-01 | KNOWN_WITHIN / KNOWN_WITHIN | OPEN_END_SUPPORTED / OPEN_END |
| 2017-06-01 | **POSSIBLE_END_UNCERTAIN / EXCLUDED (understated)** | OPEN_END_SUPPORTED / OPEN_END |
| 2018-02-01 | KNOWN_NOT_VALID / EXCLUDED | OPEN_END_SUPPORTED / OPEN_END |
| 2021-12-27 (episode 52 published) | KNOWN_NOT_VALID / EXCLUDED | OPEN_END_SUPPORTED (last observed 2026-10-03) / OPEN_END |

Q03-b returns states 1–2: predicate BOARD_MEMBER_OF, roleCode "B", asserted by the person, TEXT_QUOTE with the verbatim quote and its quoteHash, snapshot PARTIAL_EXCERPT with SYNTHETIC_FIXTURE basis, source SELF_DISCLOSURE_PAGE, captureStatus ACCEPTED. All as actual.

### 3.4 Fixture 08 (`08-queries.cypher`)

| Query | Expected | Actual |
|---|---|---|
| Q08-a identity-preserving join (scheme, issuer, value) | 0 rows | 0 |
| Q08-b naive join (scheme, value) | 1 row (supplier A vs B material) flagged FORBIDDEN_IMPLICATION_IF_MERGED | 1 |
| Q08-c fulltext `mention_surface_form` "NR-100" → hypotheses | 2 candidates, outcome UNRESOLVED, record PROPOSED, issuers A and B, lexical score only (0.26) | same |
| Q08-d | 2 Identifier nodes (duplicate write refused) | 2 |

### 3.5 Fixture 09 (`09-queries.cypher`)

| Query | Expected | Actual |
|---|---|---|
| Q09-a CQ-PV-01 five states | state1 status ACCEPTED, asserters [] (multi-author statement, no asserter chosen); state2 abstract locator on the 2009 snapshot; state3 current SUPPORT adjudication INSUFFICIENT; state4 ANSWER_COMPOSITION by the composer agent; state5 policy v0 SUMMARIZE_IN_ANSWER | same |
| Q09-b CQ-TM-06 | RETRACTION issued 2010-02-06, learned 2026-10-04T01:05; affected assertion still ACCEPTED; adjudications CF SUPPORTED, SUPPORT 2009 PARTIALLY_SUPPORTED superseded by SUPPORT 2026 INSUFFICIENT | same |
| Q09-c status ≠ verdict | R=2026-01-01 → PARTIALLY_SUPPORTED; R=2026-10-05 → INSUFFICIENT; capture status ACCEPTED both | same |
| Q09-d CL-003 works vs renditions | two works, each with its PubMed-record Source | same |

## 4. GraphQL execution over Cypher-ingested fixtures (run)

Schema: `sdl-fragment.graphql` + generated stubs for the 154 referenced foreign types (`@node(labels: ["<Name>"]) { id uid name }`, never part of the packet). Build: parse OK; `new Neo4jGraphQL().getSchema()` OK, 10,131 generated types, 347 queries, 481 mutations (`results/build.txt`). Harness: `fixtures/graphql-read-test.mjs`; operations: `fixtures/graphql-ops-T*.json`.

| Test | Data | Result |
|---|---|---|
| T1 | F01 | `assertions` returns the five HAS_FORMULATION_VERSION assertions with enum, DateTime, union (`subject`→ProductVariant, `object`→FormulationVersion), relationship-property (`supersedesConnection.properties.supersessionKind`) and nested provenance fields; `sourceRevisionEvents` returns the erratum with prior/resulting/announced snapshots |
| T2 | F09 | `sources` → locators → `supports` union returns Assertion and Adjudication members; `activities.authorizedByConnection` returns `useKind: SUMMARIZE_IN_ANSWER`; adjudication `supersedesConnection` returns SOURCE_REVISION with the event uid; `assertedBy` union returns Organization |
| T3 | F05 | the generic `Assertion` type reads both ClaimOccurrence nodes (labels ClaimOccurrence, Assertion) through kernel fields |
| T4 | F12 | field errors, as predicted: `Cannot return null for non-nullable field Assertion.id` (T4a), `Enum "AssessmentStatus" cannot represent value: "FINAL"` (T4b), `… SourceLocator.id` (T4c), `… Source.id` on a Document node storing only `documentId` (T4d) |
| T5a | base | `createAssertions` without `id`: id autogenerated (UUID), `recordedAt`/`createdAt` server-assigned; uid client-supplied → V-117 row afterwards (W00-SR-02) |
| T5b | | `update: {predicate: …}` rejected: `Field "predicate" is not defined by type "AssertionUpdateInput"` |
| T5c | | `recordedTo` update accepted by the API without any SUPERSEDES → V-506 STATUS_PROJECTION_MISMATCH afterwards (the once-only/with-supersession rule is service-enforced) |
| T5d | | `deleteAssertions` does not exist |

Probe **P-1** (`results/probe-P1-union-specialization.graphql`, run before the fragment): a union `Source | Document | Person` returns one Document-labelled node twice (`__typename` Source and Document); a union `Source | Person` returns it once as Source. Basis of D-W00-05.

Runtime findings: (1) without APOC every DateTime read fails (`Unknown function 'apoc.date.convertFormat'`) — W00-SR-14; (2) the T1 query touching `subject` and `object` (147-member unions) took 10.5 s on first execution (query planning) and 0.16 s when repeated; a first attempt with an unbounded JVM heap on a memory-loaded host was killed by the OS. 

## 5. Essential CQ queries (one per Essential CQ covered)

| CQ | Query |
|---|---|
| CQ-EV-01 | Q03-b; T1 `supportedBy` chain |
| CQ-EV-02 | Q09-c, T2 (record kinds via `__typename`); QS-4a/V-112 on F07 |
| CQ-TM-01 | Q01-a/b/c, Q01-e, Q03-a |
| CQ-TM-02 | Q02-a, Q02-b |
| CQ-TM-07 | Q01-d |
| CQ-PV-01 | Q09-a |
| CQ-PV-04 | F04/F05/F12 `massBasis`/`quantityBasis` cases; W00-SR-01 |
| CQ-AX-07 | V-111/V-401 on F10 (accepted assertion on non-reproducible locators) |
| CQ-AX-14 | Q08-c |

## 6. Not run

- `operations-enterprise.cypher` on Enterprise (no Enterprise instance).
- Concurrent writers against the write-guard pattern (F11 runs bundles sequentially; the subject-lock argument rests on the Neo4j MERGE/locking documentation, S-07).
- QS-1a and QS-2a verbatim from `query-shapes.md` were not re-run; their W00 variants above were.

## 7. Reproduce

```
# harness (validation/harness in the run directory): npm i @neo4j/graphql@7.6.3 graphql@16 neo4j-driver@6
# Neo4j: neo4j-harness 5.26.31 + apoc-core-5.26.31.jar + apoc-common-5.26.31.jar on the classpath and in plugin_dir,
#        dbms.security.procedures.unrestricted=apoc.*, -Xmx1500m
node run-cypher.mjs <bolt> workers/W00/operations.cypher
node run-cypher.mjs <bolt> workers/W00/fixtures/<fixture>.cypher          # 00-common-base first where stated
node run-cypher.mjs <bolt> workers/W00/fixtures/validation-w00.cypher
node workers/W00/fixtures/11-write-guard-harness.mjs <bolt-uri-file> workers/W00/fixtures/11-write-guards.cypher
node workers/W00/fixtures/graphql-read-test.mjs <bolt-uri-file> <fragment+stubs.graphql> workers/W00/fixtures/graphql-ops-T1.json
```

## Reconciliation pass additions (2026-10-04, Wave 4)

| Fixture / test | Exercises | Observed (embedded 5.26.31 + APOC) |
|---|---|---|
| `fixtures/13-reconciliation-rulings.cypher` (load after 00) | W00-R-01, -02, -03, -06, -08, -11, -13, -16, -17, -19, -20 | 24/24 statements ok. Revised validators: V-003r 1 (N2), V-432r 1 (N1), V-W00-13 1 (N1), V-503r 1 (N3), V-505r 1 (N5 QUALIFIER_DIFFERS:isPrimary), V-W00-15 3 (N4), V-W00-17 1 (N6), V-W00-16 1 (N7), V-W00-19 1 (N8), V-521r 1 (N9); valid P1-P6 records report nothing |
| `fixtures/13-queries.cypher` Q13-a | held uid hu:org:w00-acme-b as of 2026-04-10 -> itself; as of 2026-10-04 -> hu:org:w00-acme-a via hu:assessment:w00-merge-acme | as expected (`results/F13.queries.json`) |
| `fixtures/13-queries.cypher` Q13-b | statedAsOf ladder: 2024-08-20 KNOWN_AT_WITNESS, 2024-09-01 POSSIBLE_START_UNKNOWN, record without precision NOT_EVALUABLE | as expected |
| `fixtures/graphql-ops-T6.json` | Source.name via stored title, sourceKindNote, redirect fields, QUANTITY object + literal, statedAsOf, uid on EvidenceAssessmentArchetype | no GraphQL errors (`results/graphql-T6.txt`) |
| T1-T5 rerun on the reconciled fragment | regression | same data as the first pass except list order, generated ids/timestamps and "did you mean" suggestions |
| fixture 10 | normalizationVersion now IMG-PX1 (W00-R-24) | unchanged rows |

Original-vs-revised validator runs over W00 and worker fixtures: `results/validation-corrections-runs.md`.
