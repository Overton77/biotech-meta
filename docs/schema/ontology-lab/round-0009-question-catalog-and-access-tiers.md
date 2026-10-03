# Round 0009: Question Catalog and Access Tiers

Status: `OPEN` (recommendation by Lane 1; the coordinator sets the final status)

## Header

- Round ID: 0009
- Date: 2026-10-03
- Builder: Lane 1 (questions, product access, query shapes)
- Challenger: Lane 6 (integration and adversarial review), plus the Challenger lines below
- Owning module: provenance and temporal (kernel change requests), plus a candidate `access_and_answers` module
- Candidate schema version: 0.2.0 (candidate)
- Source schema digest: `sha256:4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f` (`catalog/schema.yaml` as read on 2026-10-03)
- Decision status: `OPEN`

## Intent and competency questions

- Decision or workflow supported: the first public decision trail, and the audit and agent access to it.
- In scope: priority classes, question-to-model traces, the canonical query shapes, six kernel-change requests (K-1 to K-4, K-6, K-7 below, with K-5 owned by Lane 5), and the live search surface and shared interfaces as seams.
- Out of scope: private user context placement (Lane 5), domain predicates (Lanes 2 to 4), changing the live schema.
- Competency question IDs: all of them (classification); CQ-AX-01 to CQ-AX-28 (new).

## Case packet

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| `current_biotech_schema.graphql` | live schema | lines 1 to 27, 502, 738, 2660 to 2745 | read 2026-10-03 | What the live GraphQL schema declares. Not what the deployed database contains. |
| Neo4j GraphQL Library documentation | product documentation | directives pages (`@id`, `@alias`, `@fulltext`, `@vector`) | read 2026-10-03 | Library behavior in version 7. |
| Snodgrass; XTDB; Datomic; PostgreSQL wiki | textbook and product documentation | bitemporal slice; valid and system time; as-of filters | read 2026-10-03 (snippet level) | Vocabulary and query form. Not BellLabs semantics. |
| 21 CFR 807.39 and FDA registration notices | regulation and agency pages | registration does not denote approval | read 2026-10-03 | Registration and listing status only. |

## Builder proposal

- Proposed terms: classification scheme (section 1 of the question fragment); six canonical query shapes plus two (QS-7, QS-8); `AnswerRecord` (candidate); `PrivateScope` marker label (Lane 5 to own).
- Kernel-change requests, each with its failing case:
  - **K-1: temporal properties on asserted edges** (`assertionUid`, `recordedFrom`, `recordedTo`; `validTimeBasis`, `validTimePrecision` on assertions and edges). Failing case: formulation attached 2025-06-01 on 2026-01-10 and corrected on 2026-06-20. Without `recordedFrom` and `recordedTo` on the edge, a March as-of query and an August as-of query return the same row. The starter model names these properties and the catalog omits them.
  - **K-2: multi-hop derived edge citation** (`derivationRule` plus `derivedFromAssertionUids`). Failing case: `CONTAINS` rests on three assertions; one `projectionOfAssertionUid` cannot cite them. A second case: an `ENDORSES_PRODUCT` edge cites an `ADVISES_ORGANIZATION` assertion, passes `V-007`, and reintroduces the forbidden implication.
  - **K-3: projection request access fields** (`accessTier`, `privateContext`, `traceDepth`). Failing case: the contract has no way to say a request is a public answer, so nothing stops a request from including a private-owned module.
  - **K-4: supersession as a record and `polarity` in the catalog.** Failing case: an assertion accepted in January and rejected in May has a mutable `status`; a March as-of query reads May's value. `polarity` is required to separate "asserted absent" from "not recorded".
  - **K-6: predicate exclusivity.** Failing case: two current `HAS_FORMULATION_VERSION` edges for one variant and jurisdiction conflict, and two `MARKETS_PRODUCT` edges do not. CQ-TM-05.
  - **K-7: `AnswerRecord`** (candidate). Failing case: a published answer cites assertions that are later superseded and nothing records which answer used which; the answer cannot be replayed (CQ-AX-03).
- Identity rule: unchanged. This lane adds the `uid` to live `id` seam (`live-schema-decisions.md`).
- State/version rule: unchanged.
- Valid-time rule: bounds are half-open; null is unknown; an open end is also null and is read as unverified after the last supporting observation.
- Recorded-time rule: system-assigned; a correction closes `recordedTo` and opens a new edge.
- Unknown-time rule: the as-of shapes keep rows with unknown bounds and name the class.
- Provenance rule: unchanged.
- Projection consequence: contract gains three optional fields; closure is unchanged.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| C-1 | Operational | Queries are only linted, never run. | High | Run the QS-2 fixture on Neo4j 5 and compare with the hand-derived table. | Open. Status stays `statically-checked`. |
| C-2 | Ontological | `OPEN_END_SUPPORTED` assumes continuity between `validFrom` and the last observation. | Medium | A discontinued and relaunched product. | Open (open-questions B.7). |
| C-3 | Epistemic | A single basis for two bounds loses information. | Medium | Count assertions with differing bases in the first fixtures. | Open (B.5). |
| C-4 | Operational | `AnswerRecord` could become a log of what people asked. | High | Property list forbids `userUid`, `ownerUid`, `questionText` (V-121); only published answers are stored. | Resolved in the proposal; retention rule is Lane 5's. |
| C-5 | Linguistic | "Current" in a consumer question can mean last observed, effective now, or available to buy. | Medium | Pairs 6 and 20. | Resolved by returning the observation time and class. |
| C-6 | Ontological | The query shapes dictate catalog design. | Medium | Each shape cites the question that needs it; properties that no shape or question uses were not proposed. | Accepted. |

## Confidence vector

Not applicable to this round: it proposes questions and shapes, not scored assertions. Where the shapes return scores, they return dimensions, not a composite, and no shape stores a single `confidence`.

## Schema projection

- Projection request ID: `req-ax-trail-0001` (example in `query-shapes.md`, QS-5a)
- Selected modules: kernel, provenance, temporal, identity_resolution, products_and_formulations, studies_and_evidence
- Closure additions: the `Identifier` surface (pending coordinator)
- Explicit exclusions: `UserContext`, `RecommendationDecision`, `PrivateScope`
- Budget result: not computed (no projection compiler exists yet)
- Projection ID/digest: not computed

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | QS-2 fixture in `query-shapes.md` | rows as in the hand-derived table | not executed | no |
| Negative fixture | `validation.cypher` V-101 to V-121 | zero rows on valid data | not executed | no |
| Minimal pair | adversarial pairs 9 to 21 | different graph deltas | specified, no graph yet | partial |
| Temporal correction | QS-2c on the fixture | `BELIEF_ADDED` and `BELIEF_CLOSED` rows | not executed | no |
| Identity collision | uid and live id seam (V-117) | zero rows | not executed | no |
| Retrieval evaluation | QS-1 to QS-8 | statically checked | linted, 0 errors | partial |
| Migration compatibility | uid backfill (V-118) | counts fall to zero | not executed | no |

## Decision

- Outcome (recommended): accept the scheme and the shapes now; accept K-1, K-2, K-4 as the minimum for the first trail; hold K-3, K-6, K-7 until Lane 5 reports.
- Rejected alternatives: one `confidence` for questions (no); a numeric priority (classes carry tests instead); storing answer logs per user (private).
- Residual uncertainty: see `open-questions.md` section B.
- Required catalog changes: `catalog-patch.yaml`.
- Required ingestion changes: set `recordedFrom` and `assertionUid` on every asserted edge; write opaque uids and `id`; set `createdAt` and `updatedAt` on Cypher-written nodes.
- Required retrieval/API changes: the compiler passes `temporalView` into the shapes and substitutes depth literals.
- Changelog and migration references: none yet.
