---
id: SPEC-BP-STAGEGRAPH
title: StageGraph blueprint semantics
status: canonical
version: 3
governed_by: [ADR-0003]
amendments:
  - id: AMD-RRM-001
    recorded_at: 2026-10-01
    base_revision: c48867a
    status: proposed_for_acceptance  # RRM-001 independent review pending; not yet accepted
    summary: governed declared-wait release and wait continuity
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-RUN-CONTROL, SPEC-CP-DURABLE-EXECUTION, SPEC-CP-DEEP-AGENT-RUNTIME]
sources:
  - path: ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
    sections: [StageGraph user stories, implementation decisions, testing decisions]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [7.2, 13, 21 Phase 3, 22]
supersedes:
  - StageGraph portions of ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
requirements:
  - REQ-BP-SG-001
  - REQ-BP-SG-002
  - REQ-BP-SG-003
  - REQ-BP-SG-004
  - REQ-BP-SG-005
  - REQ-BP-SG-006
  - REQ-BP-SG-007
  - REQ-BP-SG-008
  - REQ-BP-SG-009
  - REQ-BP-SG-010
contracts:
  - CON-BP-STAGEGRAPH-V2
  - CON-BP-STAGE-DECISION-V1
qualification_obligations:
  - QUAL-BP-STAGEGRAPH-SEMANTICS-RECOVERY
---

# StageGraph blueprint semantics

## Purpose

Define a deterministic, application-owned dependency-graph workflow family that can release downstream work promptly, preserve independent durability, perform bounded semantic repair, and complete only from accepted obligation evidence.

## Boundary and explicit non-ownership

This specification owns graph structure, dependency semantics, readiness, joins, fairness, semantic cycles, invalidation, reuse, skip/degradation, and completion proposals. Temporal owns durable execution; operation adapters own cognition; PostgreSQL/application services own authority and terminality.

## Authority and persistence

`StageGraphInterpreter` is the sole semantic authority for pure readiness and transition calculation from a frozen blueprint plus accepted projection. MongoDB/Beanie owns immutable blueprint and detailed stage/cycle documents. PostgreSQL owns accepted stage decisions, reservations, lifecycle, effects, settlement, and obligation evidence. Temporal caches compact deterministic state and schedules work.

## Vocabulary and identities

- **Stage:** immutable logical unit with declared inputs, outputs, obligations, dependencies, operation variants, and policies.
- **Dependency:** typed edge whose satisfaction is based on accepted facts/results, never raw provider status.
- **Join:** `all`, `any`, or `minimum(k)` rule over declared dependencies.
- **Admitted frontier:** fair deterministic set of runnable stage operations after authority, reservation, and concurrency gates.
- **Stage cycle:** new semantic work after an accepted evaluation, distinct from technical retry.
- **Workflow cycle:** accepted whole-graph repair/revision pass over a minimal invalidated subgraph.
- **Invalidation frontier:** exact stages/results made inapplicable by a new accepted decision.

## Invariants

1. The structural dependency graph is acyclic; semantic repetition uses explicit bounded cycle policies.
2. Readiness is derived only from the frozen blueprint and accepted authoritative facts.
3. `any` and `minimum(k)` release downstream work as soon as satisfied; slow siblings do not create an implicit barrier.
4. Every semantic cycle has new identity, objective, reservation, workspace, binding, and evidence lineage.
5. Unaffected immutable results are reused by exact reference and never overwritten.
6. Stage/whole-workflow cycles, operation attempts, activity attempts, and Continue-As-New segments remain distinct.
7. The interpreter proposes completion; the lifecycle reducer assigns terminality.

## State and lifecycle

A stage may be structurally unavailable, blocked by dependencies, ready, reserved, running, waiting, paused, completed, degraded, failed, cancelled, skipped, or invalidated. These are stage projections and do not replace the shared Workflow Run phase. The family loop hydrates accepted state, computes the admitted frontier, starts `OperationWorkflow` children, incrementally reconciles deterministic completion sets, applies accepted results, and repeats until wait, intervention, repair, or a terminalization proposal.

## Requirements

### REQ-BP-SG-001 — Validated acyclic structure

A StageGraph blueprint MUST declare unique stages and acyclic structural dependencies, exact input/output/obligation slots, allowed operation variants, and typed failure/skip/degradation behavior before publication.

**Verification:** reject cycles, missing identities, duplicate slots, and undeclared variants.

### REQ-BP-SG-002 — Explicit dependency classes and joins

Every dependency MUST declare `required`, `degradable`, `optional`, or `advisory` semantics and every multi-input gate MUST declare `all`, `any`, or `minimum(k)` with valid cardinality. Readiness and impossibility MUST use the complete accepted-disposition table and join rules in `CON-BP-STAGEGRAPH-V2`; implementations MUST NOT infer satisfaction from provider or child status.

**Verification:** truth-table and property tests for all classes and joins.

### REQ-BP-SG-003 — Pure deterministic readiness

`StageGraphInterpreter` MUST compute readiness and semantic transition proposals as a pure deterministic function of the exact blueprint, accepted projection, reservations/capacity facts, and policy inputs.

**Verification:** byte-equivalent decisions across replay and randomized input ordering.

### REQ-BP-SG-004 — Prompt incremental release

The Temporal family workflow MUST start newly admitted downstream work after an `any` or `minimum(k)` join becomes satisfied without awaiting unrelated slow siblings. Every unresolved sibling MUST remain governed by the frozen typed slow-sibling policy and durable-liability rules in `CON-BP-STAGEGRAPH-V2`, while simultaneously accepted results are applied in deterministic semantic-identity order.

**Verification:** controlled slow-sibling vertical proves downstream start time precedes sibling completion.

### REQ-BP-SG-005 — Hierarchical capacity and fairness

Frontier admission MUST intersect run, stage, operation, worker, model, tool, MCP, subagent, provider, budget, and resumption ceilings and apply the authored, validated weighted-round-robin algorithm in `CON-BP-STAGEGRAPH-V2`. Neither the group-ring cursor nor a per-group candidate cursor may advance unless the selected candidate is authoritatively admitted with its reservations.

**Verification:** saturation tests prevent starvation, oversubscription, and provider-selected queues.

### REQ-BP-SG-006 — Technical retries do not create semantic cycles

Activity or workflow retry MUST preserve the semantic operation/cycle identity and idempotency keys; a stage cycle MUST begin only from an accepted typed evaluation decision permitted by the blueprint.

**Verification:** retry, evaluator repair, and attempt lineage scenarios.

### REQ-BP-SG-007 — Bounded stage cycles

Each stage-cycle decision MUST bind unmet obligations, accepted evidence, new objective, allowed inputs, reservation, workspace namespace, exact binding, stopping limits, and prior-cycle lineage.

**Verification:** cycle limit, no-progress, budget, invalid objective, and successful repair.

### REQ-BP-SG-008 — Minimal whole-workflow invalidation

An accepted workflow-cycle decision MUST declare an invalidation frontier; the interpreter MUST recompute the minimal affected descendant subgraph, reuse compatible unaffected outputs by reference, and preserve every prior result.

**Verification:** repair one branch and prove unrelated artifacts/bindings are unchanged and reused.

### REQ-BP-SG-009 — Wait, cancellation, and late work follow policy

Local waits MUST leave unrelated runnable stages active, cancellation MUST follow the shared reconciliation saga, and slow/late sibling results MUST receive exactly one frozen-policy `admit`, `reject`, or `quarantine` decision with the projection, liability, settlement, and completion effects defined by `CON-BP-STAGEGRAPH-V2`. No late decision may retroactively mutate terminal state or the frozen inputs of already admitted work.

**Verification:** mixed wait, pause, cancel, late result, and Continue-As-New cases.

**AMD-RRM-001 (clarified):** A declared wait MUST be released only by one of the following:

- an accepted run-control `satisfy_wait` command, delivered to the StageGraph family and applied at the wait boundary, with the receipts of REQ-CP-EXEC-006;
- a declared timer or dependency fact accepted by authority.

The `applied` receipt is recorded when the wait is consumed. A raw Temporal signal is not a public release path (REQ-CP-EXEC-007). While running, a held wait is inspectable through REQ-CP-RUN-011, with its scope, condition, and pending commands. Satisfied and pending wait state is carried across Continue-As-New (REQ-CP-EXEC-011). A release whose target wait identity is not active is rejected `not_applicable`, and a release with a stale run version is rejected `stale_version`. A stage-scoped wait never blocks unrelated admissible stages (REQ-CP-RUN-004). The safe fork boundaries for this family are defined by REQ-CP-EXEC-016.

### REQ-BP-SG-010 — Completion is obligation-based

The interpreter MUST propose completion only when the exact required obligation matrix is satisfied by accepted non-stale evidence and every pending required dependency, reservation, effect, and cancellation condition has a declared disposition.

**Verification:** stale evidence, degradable failure, required failure, pending async child, and valid completion.

## Contracts

### CON-BP-STAGEGRAPH-V2

`CON-BP-STAGEGRAPH-V2` is the active contract for newly published StageGraph blueprints. It defines stage identities, edges, joins, operation slots, cycles, concurrency/fairness, waits, linked-run slots, the obligation matrix, completion policy, and the executable rules below.

#### Pre-publication normalization and canonical ordering

Normalization is a pure compiler phase between authoring validation and immutable publication. It MUST complete before canonical serialization, digest calculation, and publication, in this order:

1. Validate closed enums, scalar types, identifier constraints, references, join cardinalities, policy coverage, and numeric ranges.
2. Materialize only authored-definition defaults explicitly declared by V2, including the `default` fairness group case below and typed values for absent optional authored fields.
3. Convert every set-like collection to its contract-defined order, while preserving arrays whose order is explicitly semantic, such as late-policy rule precedence.
4. Serialize and digest the normalized payload using the canonical serialization decision in `SPEC-CP-DEFINITIONS`, then publish that exact payload and digest.

Normalization never reads environment state, aliases, clocks, provider state, or mutable defaults. A published blueprint is never normalized, defaulted, reordered, or mutated again; execution consumes its exact normalized bytes or a digest-verified immutable reference. If loaded content is not byte-consistent with the published digest, execution fails closed rather than repairing it.

Unless a field declares numeric ordering, every V2 identifier and ordering string is compared lexicographically by its canonical UTF-8 bytes, treating each byte as unsigned. Locale collation, case folding, natural-number ordering, platform collation, and runtime Unicode normalization are forbidden. Identifiers MUST already be Unicode NFC at authoring validation; a non-NFC identifier is rejected rather than silently rewritten. Numeric fields compare by their declared integer value. Tuple fields compare left-to-right and stop at the first unequal field.

Every collection in a published V2 blueprint MUST be classified by schema as either **set-like** or an **authored semantic array**. Unclassified collections are publication errors. Set-like collections are sorted during normalization by the following complete key registry:

| Set-like collection | Canonical ascending ordering key |
|---|---|
| `stages` | `(stage_id)` |
| `stage_mappings` | `(stage_id, mapping_id)` |
| `joins` | `(consumer_stage_id, join_id)` |
| `dependencies` / edges | `(consumer_stage_id, join_id, producer_stage_id, producer_output_slot_id, dependency_id)` |
| stage input slots | `(stage_id, input_slot_id)` |
| stage output slots | `(stage_id, output_slot_id)` |
| stage obligation slots | `(stage_id, obligation_slot_id)` |
| workflow obligation slots | `(obligation_slot_id)` |
| operation slots | `(stage_id, operation_slot_id)` |
| allowed operation variants | `(stage_id, operation_slot_id, operation_variant_id)` |
| linked-run slots | `(owner_stage_presence, owner_stage_id, linked_run_slot_id)` |
| obligation-matrix rows | `(obligation_scope, owner_stage_presence, owner_stage_id, obligation_slot_id, evidence_slot_id)` |
| fairness groups | `(group_id)` |
| policy definitions | `(policy_kind, scope_kind, scope_id, policy_id)` |
| waits | `(scope_kind, scope_id, wait_id)` |
| cycle limits / stopping conditions | `(scope_kind, scope_id, condition_kind, condition_id)` |
| invalidation and reuse declarations | `(scope_kind, scope_id, declaration_kind, declaration_id)` |
| concurrency, budget, and capacity ceilings | `(scope_kind, scope_id, dimension_kind, dimension_id)` |
| linked-run dependency declarations | `(linked_run_slot_id, dependency_id)` |
| completion-obligation references | `(obligation_scope, owner_stage_presence, owner_stage_id, obligation_slot_id)` |

Every textual component in these keys uses the canonical UTF-8 bytewise comparison above. Every numeric component uses unsigned integer order. Presence fields use `0` for absent and `1` for present; an absent associated identifier is the typed non-user value `NO_OWNER_STAGE`, which sorts before every present identifier. Enum-valued key fields (`obligation_scope`, `policy_kind`, `scope_kind`, `condition_kind`, `declaration_kind`, and `dimension_kind`) are compared by their canonical lowercase schema token as UTF-8 bytes, not implementation enum ordinals.

The listed final identity field is the explicit tie-breaker after all preceding scope fields. A complete-key collision is a duplicate-identity publication error; authoring order, database insertion order, object ID, hash-map iteration, and storage-generated IDs MUST NOT break ties. If a V2 extension adds another set-like collection, its accepted schema revision MUST add a total key to this registry before publication; a generic runtime fallback sort is forbidden.

The following arrays have semantic order and MUST preserve their authored element order exactly through normalization and digesting rather than be sorted:

- `slow_sibling_policy.triggers`, whose first matching trigger wins;
- `late_result_policy.rules`, whose first matching non-veto rule wins;
- any explicitly declared operation fallback/selection sequence;
- any explicitly declared evaluation, repair, or stopping-rule precedence sequence; and
- any explicitly declared sequential input-binding or output-assembly sequence.

Every semantic-array element MUST carry a unique `rule_id`, `step_id`, or other schema-declared identity suitable for evidence and diagnostics, but that identity does not reorder the array. Collections that merely express membership—including stages, dependencies, slots, obligations, groups, allowed variants, declarations, and policy definitions—are set-like even when authored in JSON/YAML array syntax. Behavioral order MUST be represented either by one of the semantic arrays above or by an explicit numeric rank/ordinal field whose containing set-like collection still uses its registered canonical key.

#### Authored fairness groups and weighted round-robin

Every published V2 blueprint contains a non-empty `fairness_groups` collection. Each entry has a unique non-empty `group_id` and an integer `weight` in `[1, 65535]`. An explicitly empty collection and boolean, fractional, zero, negative, out-of-range, duplicate, or unknown-group values are publication errors.

Each stage names one fairness group. An omitted stage group means the exact group ID `default`. If the author omits the entire fairness block and no stage names a group, compilation materializes `[{group_id: "default", weight: 1}]` into the immutable published blueprint. In every other case, every referenced group, including `default` when implied by an omitted stage group, MUST have an authored weight; the compiler and interpreter MUST NOT invent a missing weight.

The interpreter constructs the immutable weighted group ring as follows:

1. Sort groups by canonical UTF-8 bytewise `group_id` ascending.
2. For round `r = 1..max(weight)`, append each sorted group whose weight is at least `r`.
3. Initialize the group-ring cursor to index `0`. Initialize every per-group candidate cursor to the typed `BEFORE_FIRST` cursor state, which compares before every candidate key and is not a user-representable identity.

A ready candidate has the total typed identity:

`(stage_id, mapped_instance_presence, mapped_instance_id, workflow_cycle_ordinal, stage_cycle_ordinal, operation_slot_id)`

`mapped_instance_presence` is the integer tag `0` when mapping is absent and `1` when present. When absent, `mapped_instance_id` is the typed sentinel `NO_MAPPED_INSTANCE`, which is not a valid authored ID and sorts before every present mapped ID. Cycle ordinals are unsigned integers. `operation_slot_id` identifies the exact declared operation within the stage/cycle; a semantic operation-attempt ID is created only after admission and therefore MUST NOT participate in pre-admission ordering. The candidate ordering key is `(priority, candidate_identity)`, where lower integer priority sorts first and identity fields follow the canonical tuple rules above. This identity distinguishes stages, mapped expansions, semantic cycles, and multiple operation slots without relying on a runtime-generated attempt ID.

For each frontier selection, ready candidates in a group are sorted by the total candidate ordering key. Scanning from `BEFORE_FIRST` starts at the first candidate. Otherwise it starts at the first key strictly greater than the stored key and wraps once; if the stored candidate is no longer ready, its key remains the exclusive lower bound before wrap. Group slots are scanned from the group-ring cursor and wrap once. A candidate is selectable only if all compiled authority, capacity, reservation, concurrency, budget, resumption, and policy gates accept it atomically.

On successful authoritative admission, and in the same transaction as its reservations, the group-ring cursor advances to `(selected_ring_index + 1) mod ring_length` and that group's candidate cursor becomes the admitted candidate's complete ordering key. A candidate that cannot be admitted is skipped for that scan and advances neither cursor. If a complete ring scan yields no admission, selection stops without cursor movement. After each success the next selection starts from the newly accepted cursors and current accepted capacity facts. This produces the authored long-run weight ratio whenever groups remain continuously admissible, while a blocked group cannot consume turns or prevent another group from being scanned. Simultaneously accepted results are applied by their total semantic identity using the same typed UTF-8/numeric tuple rules before this algorithm is run again.

#### Dependency dispositions and joins

An edge has exactly one accepted upstream disposition from this closed set: `unresolved`, `fulfilled`, `degraded`, `omitted`, `failed`, `cancelled`, or `invalid`. `fulfilled` requires accepted current evidence for the edge's declared output. `degraded`, `omitted`, and `invalid` are explicit authoritative decisions, never inferences from provider status, failure, or timeout.

When previously accepted evidence is found stale, malformed, digest-invalid, outside the current invalidation frontier, or otherwise inadmissible, authority replaces that edge generation's disposition with `invalid`; it never silently returns the same generation to `unresolved`. If frozen repair policy permits replacement evidence, the accepted repair/invalidation decision creates a new dependency generation with disposition `unresolved` and lineage to the `invalid` generation.

The satisfaction truth table is:

| Dependency class | `fulfilled` | `degraded` | `omitted` | `failed` | `cancelled` | `invalid` | `unresolved` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `required` | satisfies | does not satisfy | does not satisfy | does not satisfy | does not satisfy | does not satisfy | pending |
| `degradable` | satisfies | satisfies | does not satisfy | does not satisfy | does not satisfy | does not satisfy | pending |
| `optional` | satisfies | satisfies | satisfies | satisfies | satisfies | satisfies | pending |
| `advisory` | non-gating | non-gating | non-gating | non-gating | non-gating | non-gating | non-gating |

An accepted upstream failure satisfies a degradable edge only after authority emits the separate accepted `degraded` disposition required by that edge's frozen degradation policy. An optional edge waits while unresolved but, once settled, its presence or typed absence satisfies the gate. Advisory edges are recorded and may inform later evaluations, but are excluded from join cardinality and can neither satisfy nor make a join impossible.

For a join, let `N` be its non-advisory edge count, `S` the count that satisfies the table, and `U` the count that is unresolved and can still reach a satisfying disposition. All remaining non-advisory edges are terminally non-satisfying.

- `all` is satisfied exactly when `S = N`, impossible exactly when `S + U < N`, and pending otherwise.
- `any` is satisfied exactly when `S >= 1`, impossible exactly when `S = 0` and `U = 0`, and pending otherwise.
- `minimum(k)` is satisfied exactly when `S >= k`, impossible exactly when `S + U < k`, and pending otherwise.

Publication rejects `any` with `N = 0` and rejects `minimum(k)` unless `N > 0` and `1 <= k <= N`. `all` with `N = 0` is vacuously satisfied. Once a join is satisfied, later sibling settlement does not revoke work already admitted from that accepted projection; using newly admitted or changed evidence requires the frozen invalidation/cycle policy and a new accepted decision.

For linked or otherwise separately admitted results, parent result decisions map deterministically: `admit` emits the evidence-backed `fulfilled` or `degraded` disposition declared by the result; `conditionally_admit` remains `unresolved` until every recorded condition is accepted; `reject` emits `failed` for required/degradable edges, `omitted` for optional edges, and only an advisory observation for advisory edges; `defer` remains `unresolved`. Provider completion alone emits none of these dispositions.

#### Slow siblings, late results, and durable liabilities

A **slow sibling** is an unresolved producer whose sibling join has already become satisfied and released at least one consumer. Each join MUST freeze a `slow_sibling_policy` containing:

- one or more triggers from `join_released`, `deadline_reached`, `accepted_budget_pressure`, or `cancellation_requested`;
- trigger precedence in authored list order;
- an execution action of `continue` or `request_cancel`; and
- an arrival route of `evaluate_late_result` or `quarantine`.

Triggers are evaluated only from accepted projection facts. `join_released` fires in the transition that first admits a consumer from that join; `deadline_reached` uses the frozen deadline and accepted time fact; `accepted_budget_pressure` requires an authoritative capacity/budget fact; and `cancellation_requested` requires an accepted cancellation command. `continue` leaves the producer eligible to finish. `request_cancel` enters the shared cancellation reconciliation saga; it does not imply that work stopped or that charges/effects settled.

A result is **late** when it arrives after any frozen late trigger is true. The closed trigger set is `consumer_already_admitted`, `dependency_terminally_disposed`, `producer_invalidated`, `generation_superseded`, `evidence_invalid`, `run_cancelling`, `terminalization_started`, or `run_terminal`.

Late-result decision composition has absolute precedence:

1. Evaluate absolute vetoes in this fixed order before any slow-sibling route or authored late-policy rule: `run_terminal` or `terminalization_started` yields `quarantine`; `generation_superseded`, `producer_invalidated`, or `evidence_invalid` yields `quarantine`; `run_cancelling` yields `quarantine`; `dependency_terminally_disposed` yields `reject`. The first matching veto wins and no authored rule may override it. `evidence_invalid` is true exactly when authority has classified the arriving evidence as stale, malformed, digest-invalid, or outside the current invalidation frontier.
2. If no absolute veto matched and the applicable slow-sibling policy's arrival route is `quarantine`, the decision is `quarantine`.
3. If the route is `evaluate_late_result`, evaluate the authored `late_result_policy` in list order and use the first matching `admit`, `reject`, or `quarantine` decision.
4. If no late trigger is true, use ordinary result-admission rules rather than the late-result policy.

The authored late-result policy covers every reachable non-veto late case, including `consumer_already_admitted`; publication rejects uncovered cases. An arrival that matches more than one absolute veto uses the fixed order above. An arrival that matches multiple authored predicates uses authored list order. Thus absolute safety state dominates slow-sibling routing, and a slow-sibling quarantine route dominates discretionary late admission.

The decisions have these exact effects:

- `admit` records current accepted evidence and its dependency disposition, then includes it only in subsequent interpreter calculations. It never changes terminal state or inputs already frozen for admitted work. If consuming it would change such work, the blueprint must authorize a new stage/workflow cycle and invalidation frontier.
- `reject` records the immutable rejection and reason and contributes no evidence. If the edge is still unresolved, it projects `failed` for a required/degradable edge, `omitted` for an optional edge, or a non-gating observation for an advisory edge; an existing terminal disposition is unchanged.
- `quarantine` durably stores the result content and reason outside accepted evidence and obligation projections. If the edge is still unresolved, it applies the same class-specific terminal disposition as `reject`, while preserving the quarantined payload for audit or authorized review. Review cannot reopen a terminal run; before terminalization, later use requires a new authorized admission decision and any required cycle/invalidation decision.

Admission, rejection, or quarantine of a result settles only the result-disposition portion of its producer liability. Every admitted producer has a durable liability covering child quiescence/closure, reservations and observed usage, effect claims, cancellation, and result disposition. Early join release never deletes or transfers that liability. The liability closes only when the child is terminal or authoritatively quiesced, every reservation and charge is settled, every effect claim has an accepted settlement (including an explicitly permitted ambiguous settlement), cancellation is reconciled, and the result has exactly one decision.

The interpreter may propose StageGraph completion only when `REQ-BP-SG-010` is satisfied and every producer liability is closed. Therefore a continued or cancelling slow sibling may coexist with downstream execution but cannot outlive terminalization. A quarantined or rejected result permits completion only after its remaining liability fields settle. Terminalization freezes all StageGraph projections; later arrivals are retained under the frozen reject/quarantine rule and cannot alter outcome, obligations, reuse, or completion evidence.

### CON-BP-STAGE-DECISION-V1

`CON-BP-STAGE-DECISION-V1` defines readiness, frontier admission, stage/workflow evaluation, invalidation, reuse, skip/degrade, late-result, and completion proposals. Under a V2 blueprint its proposals carry the exact fairness cursors, dependency disposition, matched policy trigger/rule, result decision, and liability-settlement references required above.

## Failure, retry, cancellation, and recovery

Operational retry policy and semantic-cycle policy are separate. Family recovery rehydrates accepted stage projections and reconnects operation children. Continue-As-New preserves semantic counters and active bindings. The interpreter never infers success from Temporal child closure alone.

## Security, tenancy, redaction, and secrets

Stages receive only declared input/context/artifact refs and exact capabilities. Graph topology, prompt content, or model output cannot grant tools, data, authority, budget, or linked-run permission.

## Dependencies and compatible implementations

The initial implementation uses Temporal `StageGraphWorkflow` and `StageGraphInterpreter`, with generic `OperationWorkflow` children. Operations may be native or exact Deep Agent assemblies.

## Qualification and evidence

`QUAL-BP-STAGEGRAPH-SEMANTICS-RECOVERY` must prove pre-publication normalization and digest stability, every registered set-like collection key and semantic-array order, canonical bytewise ordering, duplicate-key rejection, initial and resumed WRR cursors, all joins/dispositions, early release, deterministic simultaneous settlement, fairness, cycles, invalidation/reuse, late-result veto precedence, waits, cancellation, replay, worker loss, and obligation completion against canonical fixtures. It does not require legacy runtime or schema parity.

## Open decisions

- Workflow-specific topology, numeric cycle limits, and evaluation thresholds.

## Non-goals

- Runtime-authored arbitrary graph topology.
- Using LangGraph graph state as StageGraph authority.
- Defining a particular domain Workflow Type.

## Source lineage and supersession

This specification extracts and supersedes all StageGraph semantic material from the old combined foundation 03 and the frozen Stage 4 package family.

## Amendment record

| Amendment | Recorded | Status | Scope |
|---|---|---|---|
| AMD-RRM-001 | 2026-10-01 | proposed for acceptance (RRM-001 review pending) | Clarified: REQ-BP-SG-009 (governed wait release, receipts, Continue-As-New continuity). No new requirement IDs. |

The notation follows `SPEC-CP-DURABLE-EXECUTION` § Amendment record.
