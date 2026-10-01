---
id: SPEC-CP-DURABLE-EXECUTION
title: Temporal run and operation hierarchy, continuity, messaging, and linked runs
status: canonical
version: 2
governed_by: [ADR-0003]
amendments:
  - id: AMD-RRM-001
    recorded_at: 2026-10-01
    base_revision: c48867a
    status: accepted  # RRM-001 accepted 2026-10-01 after independent review (user pre-authorization)
    summary: runtime-unit identity, Activity attempt fencing, command receipts, cancellation saga detail, Visibility join, safe macro snapshots and forks
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-RUN-CONTROL]
sources:
  - path: ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
    sections: [shared orchestration and linked-run decisions]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [7, 9, 10, 11, 12, 18, 22]
supersedes:
  - shared orchestration portions of ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
requirements:
  - REQ-CP-EXEC-001
  - REQ-CP-EXEC-002
  - REQ-CP-EXEC-003
  - REQ-CP-EXEC-004
  - REQ-CP-EXEC-005
  - REQ-CP-EXEC-006
  - REQ-CP-EXEC-007
  - REQ-CP-EXEC-008
  - REQ-CP-EXEC-009
  - REQ-CP-EXEC-010
  - REQ-CP-EXEC-011
  - REQ-CP-EXEC-012
  - REQ-CP-EXEC-013
  - REQ-CP-EXEC-014
  - REQ-CP-EXEC-015
  - REQ-CP-EXEC-016
contracts:
  - CON-CP-TEMPORAL-IDENTITY-V1
  - CON-CP-WORKFLOW-MESSAGE-V1
  - CON-CP-LINKED-RUN-V1
  - CON-CP-CONTINUATION-V1
  - CON-CP-RUNTIME-UNIT-V1
qualification_obligations:
  - QUAL-CP-TEMPORAL-REPLAY-RECOVERY
  - QUAL-CP-LINKED-RUN-SEMANTICS
---

# Temporal run and operation hierarchy, continuity, messaging, and linked runs

## Purpose

Define the shared durable execution shell beneath every workflow family and above every bounded operation, without allowing Temporal to own BellLabs domain semantics.

## Boundary and explicit non-ownership

This specification owns `BellLabsRunWorkflow`, the family-child boundary, the generic `OperationWorkflow`, workflow/activity separation, identity continuity, durable messaging transport, cancellation/recovery mechanics, linked-run mechanics, and Continue-As-New. StageGraph readiness and GoalDirected convergence belong to their blueprint specifications. Agent configuration/materialization belongs to `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Authority and persistence

Temporal owns durable execution mechanics and compact replay state. PostgreSQL/application services remain authoritative for lifecycle, commands, budgets, effects, settlement, terminality, linked-run decisions, and message ledgers. Workflow code may cache accepted refs and versions but never becomes the only copy of a business decision.

## Vocabulary and identities

- **BellLabs run ID:** stable product/domain run identity.
- **Execution epoch:** product-level execution generation; a fork starts a new run at epoch 1.
- **Technical segment:** Continue-As-New segment within the same run and epoch.
- **Temporal Workflow ID/Run ID:** runtime lineage, not BellLabs identity.
- **Semantic operation attempt:** independently durable unit with stable meaning across technical retries.
- **Execution/intervention generation:** provider/runtime generation within one semantic attempt after disruptive recovery.
- **Linked run:** distinct admitted Workflow Run related through a durable Run Composition Link.

Added by AMD-RRM-001:

- **Runtime unit:** the structured, versioned identity of one semantic operation attempt (`CON-CP-RUNTIME-UNIT-V1`) and its opaque `unit_key`. It is stable across Activity retries, worker loss, and Continue-As-New.
- **Unit generation:** the pair `(unit_key, execution_generation)`. A generation boundary is crossed only by an accepted recovery or intervention decision and fences every earlier generation.
- **Activity attempt:** one Temporal delivery of `operation.execute` for a unit generation (`activity.info().attempt`). It is a technical observation, never part of identity.
- **Claim fence:** the monotonically increasing lease generation of a unit's operation claim. Only the holder of the current fence may write observations, result manifests, or settlements.
- **Command receipt:** the durable, ordered record of one command's progress through `accepted`, `delivered`, `applied`, or `rejected`.
- **Safe snapshot boundary:** a declared family point, or a recorded quiescence, at which every included unit is settled and no claim, effect, command, or child is unresolved.
- **Reuse frontier:** the immutable set of settled, compatible source results that a fork may reference instead of re-executing.

## Invariants

1. One admitted run has one distinct `BellLabsRunWorkflow` root and exactly one selected family child.
2. Temporal workflow code is deterministic and performs no database, network, object-store, model, MCP, sandbox, or secret I/O.
3. Every independently messageable, cancellable, resumable, waiting, reusable, or effect-reconciling semantic operation is durably represented by `OperationWorkflow` or a linked run.
4. Activity retries preserve semantic attempt and effect identities; semantic retries create new immutable attempts.
5. Continue-As-New changes only the technical segment/Temporal Run ID, never the BellLabs run or epoch.
6. A BellLabs fork creates a new run at epoch 1 from an immutable semantic snapshot.
7. Provider, child-workflow, or activity completion is proposed evidence until authoritatively reconciled.

## State and lifecycle

`BellLabsRunWorkflow` starts the selected family child, routes accepted commands/facts, coordinates cancellation and deadlines, reconciles family results, and continues as new. A family workflow repeatedly applies its pure interpreter and schedules `OperationWorkflow` children. An `OperationWorkflow` prepares exact bindings, starts or reconnects to bounded work, manages subordinate waits and async children, persists compact progress refs, reconciles effects/results, and returns a typed outcome manifest.

## Requirements

### REQ-CP-EXEC-001 — One stable Temporal root

Each admitted Workflow Run MUST map to exactly one `BellLabsRunWorkflow` root that owns macro execution mechanics, command routing, selected-family lifecycle, deadlines, cancellation coordination, continuation, and runtime lineage.

**Verification:** duplicate start delivery attaches to the same root and does not create another macro scheduler.

### REQ-CP-EXEC-002 — Family semantics remain delegated

The root MUST delegate readiness, iteration, convergence, and family completion proposals to the exact family workflow and pure interpreter and MUST NOT implement family-specific semantics itself.

**Verification:** shared root tests run both blueprint families without family branching beyond typed dispatch.

### REQ-CP-EXEC-003 — Generic durable operation boundary

`OperationWorkflow` MUST represent one stable semantic operation attempt, support one or more activities and subordinate runtime tasks, and return only a compact typed outcome manifest after authoritative persistence/reconciliation.

**Verification:** native and Deep Agent operations share the contract and survive worker loss.

### REQ-CP-EXEC-004 — Deterministic workflows and idempotent activities

Temporal workflow code MUST use only frozen inputs and accepted compact state; all nondeterministic I/O and application mutations MUST occur through idempotent activities and services.

**Verification:** replay tests fail on workflow-side I/O and prove stable scheduling for captured histories.

### REQ-CP-EXEC-005 — Stable retry and generation identities

Technical workflow/activity retries MUST preserve the semantic operation attempt and effect keys, while policy-authorized new semantic work creates new attempt identity; disruptive restart MUST preserve the attempt and increment its execution/intervention generation.

**Verification:** retry, repair, intervention, and late-old-generation result tests.

**AMD-RRM-001 (clarified; behavior already mandated):** The semantic operation attempt is the runtime unit of REQ-CP-EXEC-013. Activity attempts, worker restarts, and Continue-As-New segments never change `unit_key` or `execution_generation`. A generation boundary is crossed only by an accepted recovery or intervention decision recorded through run control. It fences every earlier generation: their late observations, checkpoints, results, usage, and effects are quarantined under REQ-CP-EXEC-008 and can never settle the unit. A new generation of a Deep Agent unit starts a new cognitive checkpoint lineage (REQ-CP-DA-016), unless the accepted decision names a terminal result checkpoint, seeded under the `cognitive_seed` rules of REQ-CP-EXEC-012. A new generation of a GoalDirected unit keeps its `unit_key` and runs in its own unit-generation namespace (REQ-BP-GD-012). This reinterprets the base text's "disruptive restart": only an accepted recovery or intervention decision is disruptive and advances the generation. An ordinary worker restart, Activity retry, or claim takeover (REQ-CP-EXEC-014) is not disruptive. Added verification: a stale-generation observation is rejected after a boundary, and three Activity attempts of one unit share one `unit_key`.

### REQ-CP-EXEC-006 — Authoritative message ledger

Commands and messages MUST be immutable, target a stable run/operation/subordinate identity, use monotonic target sequencing and durable inbox/ledger/outbox records, and expose receipt states from acceptance through checkpoint-committed application or terminal rejection.

**Verification:** ordered batch claim, lease expiry, redelivery, duplicate IDs, stale targets, and receipt progression.

**AMD-RRM-001 (clarified; states newly named):** Receipts follow the closed state machine in `CON-CP-WORKFLOW-MESSAGE-V1`: `accepted -> delivered -> applied`, with `rejected` reachable from `accepted` or `delivered`. Each transition is a PostgreSQL record written through application services, ordered per target by the command's target sequence. Acceptance by run control is not delivery. Delivery to the root workflow is not delivery to the family. Delivery is not application. Exact duplicates return the stored receipt without a second transition. Receipt state and pending commands survive worker restart and Continue-As-New (REQ-CP-EXEC-011). Receipts held in workflow memory are a transport de-duplication cache only, never the authoritative copy. Commands that target executing cognition (mid-invocation steering) remain deferred until a checkpoint-safe steering contract is accepted; until then they are rejected with `not_applicable`.

### REQ-CP-EXEC-007 — Typed Temporal messaging transport

Signals MUST carry compact deduplicated facts, Updates MUST return command acceptance/rejection, and Queries MUST remain diagnostic; handlers MUST NOT directly mutate lifecycle or settlement authority and MUST quiesce before Continue-As-New.

**Verification:** signal/update replay, concurrent handler serialization, and product-query independence.

**AMD-RRM-001 (clarified):** An Update's return value is evidence of `delivered`, never of `applied`. Every public command enters through the run-control facade and reaches Temporal only as a recorded delivery. A raw Temporal signal sent by a client outside the application services is not a governed command path and MUST NOT release a wait, pause, resume, or cancel a run. Queries MUST NOT be the source of an inspection response, an authorization decision, a snapshot, or a settlement. They may be shown only as labelled diagnostics (REQ-CP-RUN-012).

### REQ-CP-EXEC-008 — Cancellation is a reconciliation saga

Cancellation MUST authorize and journal intent, request subordinate quiescence/cancellation, reconcile effects, budgets, checkpoints, and late outputs, quarantine superseded generations, and only then propose terminal settlement.

**Verification:** cancellation before dispatch, during model/tool work, during async child execution, and after ambiguous effect.

**AMD-RRM-001 (clarified; protocol detail):** The saga runs in this order:

1. Run control authorizes the cancel command and records its `accepted` receipt; the run enters `cancelling`. No Temporal or provider request precedes this record.
2. The command is delivered to the root, the family, and every active `OperationWorkflow`, with `delivered` receipts.
3. Every cognitive `operation.execute` Activity declares a heartbeat timeout and heartbeats compact progress (`unit_key`, generation, Activity attempt, latest qualified checkpoint key, phase; no prompts, transcripts, or secrets). Cancellation reaches an executing Activity through heartbeat. The adapter stops cognition, interrupting the in-flight step if necessary, and records the latest durable checkpoint. A pre-dispatch cancel flag alone is not evidence that cognition stopped.
4. Async children are cancelled according to their link's propagation policy. The provider's acknowledgement, or its absence, is recorded as an observation.
5. Usage, reservations, and effect claims are reconciled. Usage of a provider call that was in flight is recorded as pending. An ambiguous consequential effect creates an `in_doubt` incident for operator reconciliation and is never re-executed speculatively.
6. Late outputs and superseded generations are quarantined.
7. Only when every liability is settled does the family propose terminal `cancelled`, which the reducer decides (REQ-CP-RUN-005). A family workflow MUST complete this saga as workflow logic. Raising a non-retryable workflow failure in place of reconciliation does not satisfy it.

A cancel delivered while a unit is classified `interrupted` (REQ-CP-DA-018) MUST NOT resume cognition. The unit settles `cancelled` with its latest checkpoint as the result checkpoint, preserving partial evidence.

### REQ-CP-EXEC-009 — Linked runs are independently admitted

Crossing a Workflow Type boundary MUST create a typed linked Run Request, independently compiled/admitted child Workflow Run, Run Composition Link, distinct reservation, and explicit parent dependency policy.

**Verification:** child admission cannot be bypassed by the parent or Temporal child creation.

### REQ-CP-EXEC-010 — Linked results require parent admission

Every exact linked-run result MUST receive an immutable parent-side `admit`, `conditionally_admit`, `reject`, or `defer` decision before it can satisfy an obligation or enter parent work; late results MUST NOT mutate a terminal parent.

**Verification:** all dependency classes, result decisions, timeout/failure, and late completion.

### REQ-CP-EXEC-011 — Continue-As-New preserves semantics

Continue-As-New MUST preserve the BellLabs run, epoch, exact configuration, semantic counters, accepted revisions, pending commands/waits, active child identities, links, reservations, and effect frontier while advancing only the technical segment and Temporal Run ID.

**Verification:** forced continuation with active operations, pending messages, and deduplicated replay.

**AMD-RRM-001 (clarified):** The carried state explicitly includes pending commands and their receipt states, satisfied and pending wait identities, durable pause state, the expected source checkpoint of every active unit, and active async child identities. A wait satisfied before Continue-As-New stays satisfied after it.

### REQ-CP-EXEC-012 — Semantic forks are new runs

A product fork or edited-state start MUST use an immutable `RunSnapshotManifest`, validate the patch and reuse frontier, leave active parent children parent-owned, create a new BellLabs run at epoch 1, and independently compile/admit it.

**Verification:** fork lineage, protected-field rejection, no pending-message copying, and compatible-result reuse.

**AMD-RRM-001 (clarified; contract detail in `CON-CP-CONTINUATION-V1`):**

- **Snapshot.** The snapshot is built under REQ-CP-EXEC-016.
- **Patch.** The patch is a typed `RunForkPatch`. It may change only fields that the Workflow Type or blueprint declares patchable. A patch that touches a protected field is rejected. Protected fields are identity, scope, authority and capability grants, budget ceilings, accepted evidence and results, effects, settlements, terminality, and frozen binding digests. A patch that changes effective configuration produces a newly compiled ERC, which is admitted independently (REQ-CP-RUN-001). A fork MUST NOT require the source's run-plan or ERC digest to be unchanged.
- **Reuse frontier.** A source result is reusable only if it meets all four conditions:
  - it has an accepted settlement;
  - it is outside the patch's invalidation frontier;
  - it is not quarantined;
  - its unit's binding digest, cognitive state schema digest, and input digests are unchanged by the patch.

  A candidate matches a derived-run unit whose `CON-CP-RUNTIME-UNIT-V1` identity is equal after substituting `belllabs_run_id` and `execution_epoch`. The fork references a reused result by immutable ref and records each reuse decision. It never re-settles that result in the parent.
- **Admission.** The derived run starts at epoch 1, with its own admission, reservation, unit keys, and cognitive session namespaces.
- **Nothing implicit is copied.** Pending commands, message ledgers, effect claims, reservations, and provider tasks are never copied. A source run's active `OperationWorkflow`s, async children, and linked runs are never transferred, cloned, or re-parented; they remain parent-owned.
- **Cognition in the fork.** By default, cognition in the derived run starts in a fresh namespace or, for GoalDirected, fresh from a typed handoff (REQ-BP-GD-005). The patch may instead declare an explicit `cognitive_seed`. A seed names the terminal result checkpoint of a settled source unit, and the target binding must carry the same cognitive state schema digest. The seeded state is written into the derived run's own new namespace, and the derived run records `seeded_from` lineage. A seed from a non-terminal or intermediate checkpoint is not supported until resume/patch compatibility is separately qualified.
- **Temporal Reset.** Reset is incident recovery, never a product fork.

### REQ-CP-EXEC-013 — Structured runtime-unit identity

Every `OperationWorkflow` request, Deep Agent invocation, operation claim, checkpoint observation, async child, inspection record, and operation Search Attribute MUST carry one `CON-CP-RUNTIME-UNIT-V1` identity or its `unit_key`. The identity MUST distinguish every StageGraph and GoalDirected semantic location. It MUST exclude Temporal workflow, run, and activity IDs, Activity attempts, worker identity, and timestamps.

**Amendment:** AMD-RRM-001, new (identity grammar). It makes REQ-CP-EXEC-005 testable.

**Verification:** units that differ in any location field have different keys; technical retry, worker restart, and Continue-As-New yield byte-identical keys; canonical serialization and digest golden tests.

### REQ-CP-EXEC-014 — Activity attempts are observed and claim-fenced

Before any provider or model dispatch, each `operation.execute` Activity attempt MUST durably record an idempotent attempt observation and MUST hold the unit's operation claim at the current claim fence. The observation contains `unit_key`, generation, Temporal workflow, run, and activity IDs, Activity attempt number, worker identity, and the expected source checkpoint.

A later attempt MAY take over only an expired or released claim, and only by advancing the fence. Every write by an attempt (checkpoint observation, result manifest, settlement) MUST present its fence. A write that presents a superseded fence MUST be rejected and recorded, and MUST never be applied. Concurrent recoveries of one unit serialize on the claim.

**Amendment:** AMD-RRM-001, new (storage and protocol detail). It completes REQ-CP-EXEC-005 and the claim/lease intent of REQ-CP-RUN-007.

**Verification:** two concurrent deliveries of one unit generation dispatch at most once; a crashed holder's claim is taken over after lease expiry without a duplicate prompt; a stale attempt's late write is rejected; attempt numbers are recorded under one `unit_key`.

### REQ-CP-EXEC-015 — Visibility join uses Search Attributes only

Root, family, and `OperationWorkflow` executions MUST be started with the BellLabs Search Attributes declared in `CON-CP-TEMPORAL-IDENTITY-V1`. Inspection MUST join PostgreSQL authority to Temporal executions only through Temporal's Visibility and Workflow APIs. No component may read Temporal's persistence database. Visibility or Temporal unavailability MUST degrade inspection freshness and MUST NOT fail reads served from persisted authority.

The attributes are supplied by a composition-level Search Attribute policy:

- **`required`** — for production and persistent qualification namespaces. Attributes are registered by the administrative step, and every start sets them.
- **`disabled`** — for the time-skipping test server and captured-history replay, where workflows start without attributes. `WorkflowEnvironment.start_local` fixtures may register the attributes with its `search_attributes` argument and use `required`.

A captured history is replayed under the policy it was recorded with, so existing replay fixtures are unaffected. The policy is carried in the root, family and `OperationWorkflow` inputs and through Continue-As-New, and workflow code never reads it from worker configuration. An absent field means `disabled`, which covers existing histories. Production composition rejects `disabled`.

**Amendment:** AMD-RRM-001, new (API and deployment detail).

**Verification:** a real namespace with registered attributes lists a run's root, family, and operations by `BellLabsRunId` and `BellLabsUnitKey`; the persisted read succeeds when Temporal is unreachable; a static check proves no Temporal persistence DSN or table access exists in application code.

### REQ-CP-EXEC-016 — Snapshots only at safe boundaries

A `RunSnapshotManifest` MUST be built only at a declared safe boundary or after a recorded quiescence. At that point:

- no `OperationWorkflow` of the run is active, and every included unit is settled;
- no operation claim or effect claim is unresolved;
- no command targeting the run is `accepted` or `delivered` without being `applied` or `rejected`;
- every async child and linked run has a recorded disposition.

Otherwise the request MUST be rejected `snapshot_not_quiescent`, or it waits for a requested quiescence. It MUST never classify in-flight work as reusable. The snapshot MUST be built from PostgreSQL authority and immutable detail documents only, never from workflow Queries.

**Amendment:** AMD-RRM-001, new (protocol detail for REQ-CP-EXEC-012).

**Declared boundaries:**

- **StageGraph:** after the accepted settlement of a stage operation or stage cycle; at a declared wait.
- **GoalDirected:** after an iteration's verifier decision is settled and before the next iteration is claimed; while durably paused (REQ-BP-GD-011).

**Quiescence:** a scoped pause stops admitting new units. Active units then either settle, or are cancelled under REQ-CP-EXEC-008 with their liabilities settled. A durable quiescence record is written before the snapshot.

An active async child at the boundary makes the snapshot unsafe. Forks are therefore prohibited while a parent-owned child is active. They are permitted only from an earlier or later boundary at which every child has a disposition.

**Verification:** snapshot rejected with an active operation, unresolved effect, pending command, or active async child; accepted after quiescence; manifest digest stable across replay.

## Contracts

`CON-CP-TEMPORAL-IDENTITY-V1` distinguishes BellLabs run, epoch, technical segment, Temporal Workflow/Run, semantic attempt, activity attempt, and execution generation. `CON-CP-WORKFLOW-MESSAGE-V1` defines commands, facts, sequence, immutable IDs, claims, receipts, and payload refs. `CON-CP-LINKED-RUN-V1` defines slots, request identity, dependency classes, reservations, cancellation, and result admission. `CON-CP-CONTINUATION-V1` defines compact Continue-As-New and snapshot/fork manifests.

### AMD-RRM-001 contract detail

**`CON-CP-RUNTIME-UNIT-V1`** (new, identity grammar, schema `belllabs.runtime-unit.v1`):

```text
request_scope, belllabs_run_id, execution_epoch >= 1
family            = stage_graph | goal_directed
unit_kind         = stage_operation | goal_executor | goal_verifier    # closed; extended only by revision
semantic_operation_id, semantic_attempt >= 1
location (exactly one, matching family):
  stage_graph:   stage_id, mapped_instance_id | NO_MAPPED_INSTANCE, workflow_cycle_ordinal,
                 stage_cycle_ordinal, operation_slot_id
  goal_directed: goal_iteration, goal_revision_id, operation_role (executor | verifier),
                 agent_run, session_generation
unit_key = "bl-unit-v1:" + lowercase hex SHA-256 of the canonical serialization (SPEC-CP-DEFINITIONS)
```

`execution_generation` is not part of the unit identity. The fence key is `(unit_key, execution_generation)`. The `OperationWorkflow` ID remains `operation/{semantic_attempt_id}`, because published wire identities are not renamed; the unit identity travels beside it. An operation that is not one of the listed unit kinds requires a contract revision before it may run as a runtime unit. Workflows that are not `OperationWorkflow`, such as the generic artifact workflow submitted through the run-control API, are outside REQ-CP-EXEC-013.

**`CON-CP-TEMPORAL-IDENTITY-V1`** (clarified). It adds the Activity attempt observation and the claim fence of REQ-CP-EXEC-014, and the Search Attributes of REQ-CP-EXEC-015:

| Search Attribute | Type | Set on |
|---|---|---|
| `BellLabsRunId` | Keyword | root, family, operation |
| `BellLabsScopeHash` (SHA-256 of `request_scope`; never the raw scope) | Keyword | root, family, operation |
| `BellLabsWorkflowKind` (`root`, `family`, `operation`) | Keyword | root, family, operation |
| `BellLabsFamily` (`stage_graph`, `goal_directed`) | Keyword | root, family, operation |
| `BellLabsExecutionEpoch` | Int | root, family, operation |
| `BellLabsParentRunId` | Keyword | fork and linked roots |
| `BellLabsUnitKey`, `BellLabsUnitKind` | Keyword | operation |
| `BellLabsExecutionGeneration` | Int | operation |

This set uses 7 Keyword and 2 Int custom attributes per namespace. The repository's Temporal `1.31.0` uses the `postgres12` SQL visibility store, which pre-allocates 3 Int and 10 Keyword custom columns per namespace (`Int01`–`Int03`, `Keyword01`–`Keyword10` in `schema/postgresql/v12/visibility/schema.sql` at tag `v1.31.0`). The semantic attempt is therefore not an attribute; it is read from the unit record in PostgreSQL. Registration MUST fail if the namespace lacks free slots.

Attributes are set deterministically at workflow start, or upserted deterministically when an accepted generation boundary is applied. Checkpoint IDs, prompts, raw scopes, and secrets are never Search Attributes. Registration is an idempotent administrative step that fails on a name/type conflict. Worker readiness verifies the attributes and never mutates namespace configuration.

**`CON-CP-WORKFLOW-MESSAGE-V1`** (clarified receipt states):

| State | Meaning | Recorded by |
|---|---|---|
| `accepted` | Run control authorized the command and recorded it idempotently, bound to scope, target, expected version, and generation | run-control command service |
| `delivered` | The exact target execution (root, then family or operation) acknowledged the command through a Temporal Update | idempotent activity/service write of the Update result |
| `applied` | The target boundary applied the command: a family wait, pause, or resume point, an operation boundary, or a committed cognitive checkpoint for cognition-targeted messages | observed fact accepted by the reducer |
| `rejected` | Terminal, with one typed reason: `stale_target`, `stale_generation`, `stale_version`, `not_applicable`, `terminal_run`, `superseded`, `unauthorized`, or `insufficient_budget` (for example, a resume that cannot re-reserve under REQ-BP-GD-011) | run control |

Two special cases apply:

- A cancel command is `applied` when the reducer records the terminal outcome.
- When run control is itself the target boundary, because no root execution has started, it records `delivered` and `applied` together.

Existing async-child message receipts map as follows: `claimed` and `provider_applied` map to `delivered`; `checkpoint_committed` maps to `applied`; `terminal_rejected` maps to `rejected`.

**`CON-CP-CONTINUATION-V1`** (clarified). It adds `RunSnapshotManifest` (schema `belllabs.run-snapshot.v1`) and `RunForkPatch` (schema `belllabs.run-fork-patch.v1`).

`RunSnapshotManifest` binds:

- snapshot identity and digest;
- source scope, run, epoch, family, and authoritative projection version;
- ERC, blueprint, and control-revision digests;
- boundary kind and ref, and the quiescence record ref if any;
- the family position: the StageGraph accepted projection ref and digest, or the GoalDirected accepted revision, iteration, and handoff refs;
- reuse candidates: `unit_key`, result manifest ref and digest, binding digest, cognitive state schema digest, settlement ref, and the unit's result checkpoint key;
- optional sandbox snapshot refs (`CON-CP-SNAPSHOT-V1`);
- the budget and effect frontier at the boundary, informational only and never copied;
- async child and linked-run dispositions;
- pending commands, listed for audit only and never copied.

`RunForkPatch` binds:

- the source snapshot digest;
- the target admission request ref;
- patchable-field changes;
- the invalidation frontier;
- an optional `cognitive_seed` (`unit_key` and qualified checkpoint key).

Fork lineage records the source run, snapshot, patch, and seed checkpoint. The derived run's own identities are recorded separately.

## Failure, retry, cancellation, and recovery

Unexpected deterministic-code failures remain repairable Workflow Task failures. Business/policy failures use typed outcomes. Long activities heartbeat compact non-sensitive progress and use distinct schedule/start/heartbeat timeouts. Recovery rehydrates authoritative application state, reconnects exact children/jobs, and never infers settlement from Temporal status alone.

## Security, tenancy, redaction, and secrets

Temporal carries identities, digests, compact status, and immutable refs—not secrets, PHI, raw corpora, transcripts, or large outputs. Public commands are authenticated and authorized before Temporal transport. Child identity and tenant scope are explicit.

## Dependencies and compatible implementations

Consumes `SPEC-CP-DEFINITIONS` and `SPEC-CP-RUN-CONTROL`. It hosts both canonical blueprint families and supplies the durable parent to `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Qualification and evidence

`QUAL-CP-TEMPORAL-REPLAY-RECOVERY` covers replay, worker loss, activity retry, messages, intervention generations, active-child continuation, and cancellation. `QUAL-CP-LINKED-RUN-SEMANTICS` covers independent admission, four dependency classes, cancellation, result admission, and late results.

AMD-RRM-001 adds the following to `QUAL-CP-TEMPORAL-REPLAY-RECOVERY`:

- worker-restart recovery against a persistent checkpointer and application database, as opposed to in-memory substitutes;
- receipt progression across worker restart and forced Continue-As-New;
- claim takeover and stale-fence rejection;
- Search Attribute joins on a real namespace;
- snapshot rejection and acceptance at safe boundaries.

## Open decisions

- Exact Continue-As-New history thresholds and message batch limits.
- Worker queue sizing and final deployment topology.
- AMD-RRM-001 owned parameters (they do not change semantics): claim lease and heartbeat timeout values; physical table names for unit, attempt, transition, and receipt records; and the Search Attribute registration tooling.

## Non-goals

- Replacing family interpreters with workflow code.
- Making Temporal Event History a product database.
- Defining capability catalog ingestion/promotion.

## Source lineage and supersession

This document extracts the shared orchestration and linked-run material from pre-research foundation 03. Family-specific content is superseded by the separate StageGraph and GoalDirected specifications.

## Amendment record

| Amendment | Recorded | Status | Scope |
|---|---|---|---|
| AMD-RRM-001 | 2026-10-01 | accepted 2026-10-01 (independent review `accept`; user pre-authorized acceptance after review) | Clarified: REQ-CP-EXEC-005, 006, 007, 008, 011, and 012; `CON-CP-TEMPORAL-IDENTITY-V1`, `CON-CP-WORKFLOW-MESSAGE-V1`, and `CON-CP-CONTINUATION-V1`. New: REQ-CP-EXEC-013, 014, 015, and 016; `CON-CP-RUNTIME-UNIT-V1`. Independent-review fixes (verdict `accept_with_fixes`) were applied on the same date and are recorded in the RRM-001 traceability document. |

Notation: "clarified" means the behavior was already mandated by the cited requirement and the amendment adds exact states, fields, or ordering. "New" means a newly specified storage, API, or protocol detail. Until the amendment is accepted, implementation of the new contracts remains gated, per the RRM-001 ticket. The disposition of existing implementation contracts is recorded in the RRM-001 application traceability document (`docs/migrations_instructions/implementation_work_packages_v2/research-runtime-mission/RRM-001-contract-authority.md` in the application repository) and mirrored in [the control-plane index](README.md#amd-rrm-001-contract-disposition).
