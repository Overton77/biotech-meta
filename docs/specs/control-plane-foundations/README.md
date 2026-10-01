---
id: SPEC-CP-INDEX
title: Control-plane foundations authority index
status: canonical
version: 1
governed_by: [ADR-0001, ADR-0003, ADR-0004]
---

# Control-plane foundations authority index

## Authority

This directory is the canonical specification authority for the BellLabs control-plane foundation. The documents under `../pre-research/control-plane-foundations/` are source material and no longer authorize implementation. The accepted architecture proposal remains provenance; [ADR-0003](../../adr/0003-temporal-deepagents-control-plane-runtime.md), [ADR-0004](../../adr/0004-deep-agent-cognitive-state-and-context-schemas.md) (proposed), and the specifications below govern new work.

## Governing invariant

> Discover broadly, select narrowly, compile exactly, admit authoritatively, execute from frozen bindings, reconcile continuously, and terminalize only from accepted evidence.

## Specification chain

1. [SPEC-CP-DEFINITIONS](01-versioned-definitions-and-effective-run-configuration.md) — immutable Workflow Types, blueprints, profiles, and deterministic Effective Run Configuration.
2. [SPEC-CP-RUN-CONTROL](02-transactional-admission-lifecycle-budgets-and-events.md) — admission, lifecycle, commands, budgets, effects, settlement, terminality, and product events.
3. [SPEC-CP-DURABLE-EXECUTION](03-temporal-run-operation-continuity-and-linked-runs.md) — `BellLabsRunWorkflow`, family and operation hierarchy, messages, cancellation, linked runs, recovery, and Continue-As-New.
4. [SPEC-CP-DEEP-AGENT-RUNTIME](04-deep-agent-materialization-subagents-workspaces-and-artifacts.md) — Deep Agent profiles and exact bindings, execution placement, capabilities, synchronous and asynchronous subagents, workspaces, artifacts, and snapshots.
5. [SPEC-CP-COGNITIVE-SCHEMAS](05-deep-agent-cognitive-state-and-context-schemas.md) — Deep Agents `state_schema` / `context_schema` packs, digests, and materialization (draft; governed by proposed ADR-0004; AMD-RRM-001 recommends narrowed acceptance, review pending).
6. [SPEC-BP-STAGEGRAPH](../workflow-blueprints/stagegraph.md) — StageGraph semantics.
7. [SPEC-BP-GOAL-DIRECTED](../workflow-blueprints/goal-directed.md) — GoalDirected semantics.

## Cohesive execution chain

```text
Workflow Type + exact blueprint and profiles
  -> Effective Run Configuration
  -> transactional Run Request admission and reservation
  -> BellLabsRunWorkflow
  -> StageGraphWorkflow | GoalDirectedWorkflow
  -> OperationWorkflow
  -> OperationAssemblySpec
  -> DeepAgentProfile + exact execution placement
  -> DeepAgentExecutionBinding
       (includes cognitive state/context schema digests)
  -> adapter materializes create_deep_agent(state_schema, context_schema)
  -> materialized MCP + Agent Skills + sandbox + other exact capabilities
  -> typed result, evidence, usage, and artifact references
  -> authoritative settlement and terminalization
```

## Persistence and authority

| Concern | Authority |
|---|---|
| Immutable definitions, compiled configurations, bindings, detailed execution documents | MongoDB/Beanie and content-addressed object payloads |
| Admission, lifecycle, commands, budgets, effects, settlement, links, terminality, product events | PostgreSQL/application services |
| Durable macro execution | Temporal |
| StageGraph readiness and completion | `StageGraphInterpreter` |
| GoalDirected revision, verification, and convergence | `GoalDirectedInterpreter` |
| Bounded cognition | Deep Agents/LangGraph under exact bindings |
| Large immutable artifacts and snapshots | Object storage |
| Tracing and evaluation | LangSmith as non-authoritative evidence |

## Foundation completion gate

The foundation is not complete on document or schema publication alone. Its first tracer vertical must prove the full chain above with:

- one admitted StageGraph fixture and one admitted GoalDirected fixture;
- the Temporal root/family/operation hierarchy;
- one locally executed Deep Agent `0.7.5` binding;
- one exact MCP server and filtered tool surface;
- one exact Agent Skill bundle;
- one exact sandbox profile and workspace materialization;
- one synchronous subagent and one asynchronous subordinate execution;
- authoritative messages, cancellation, usage, results, evidence, and settlement;
- replay/recovery and Continue-As-New continuity without mutable rereads or authority drift.

The detailed governed catalogs and promotion workflows for those capabilities are the immediate next specification wave. Their absence may be bridged only by immutable digest-verified fixtures on the tracer vertical; runtime discovery and aliases are forbidden.

## Pending amendment AMD-RRM-001 (research-runtime lifecycle)

Status: **proposed for acceptance (RRM-001 review pending)**. Recorded 2026-10-01 on branch `spec/research-runtime-lifecycle`, based on `c48867a`. It is not accepted authority until a reviewer records acceptance. Implementation of its new contracts waits for that record.

| Specification | Clarified (already mandated) | New |
|---|---|---|
| [SPEC-CP-RUN-CONTROL](02-transactional-admission-lifecycle-budgets-and-events.md) | REQ-CP-RUN-004, 007, 009; `CON-CP-LIFECYCLE-V1` projection fields | REQ-CP-RUN-011, 012; `CON-CP-INSPECTION-READ-V1`; `reconcile_unit` command and `operator_reconciliation` wait condition |
| [SPEC-CP-DURABLE-EXECUTION](03-temporal-run-operation-continuity-and-linked-runs.md) | REQ-CP-EXEC-005, 006, 007, 008, 011, 012; `CON-CP-TEMPORAL-IDENTITY-V1`, `CON-CP-WORKFLOW-MESSAGE-V1`, `CON-CP-CONTINUATION-V1` | REQ-CP-EXEC-013, 014, 015, 016; `CON-CP-RUNTIME-UNIT-V1` |
| [SPEC-CP-DEEP-AGENT-RUNTIME](04-deep-agent-materialization-subagents-workspaces-and-artifacts.md) | REQ-CP-DA-004, 008, 011, 015 | REQ-CP-DA-016, 017, 018, 019; `CON-CP-CHECKPOINT-LINEAGE-V1`; `CON-CP-ASYNC-SUBAGENT-V1` changes (contract schema fields, the `in_doubt` lifecycle value, and the `adopt_provider_run` / `orphan_child` decisions) |
| [SPEC-CP-COGNITIVE-SCHEMAS](05-deep-agent-cognitive-state-and-context-schemas.md) | Narrowed acceptance recommended: CS-001, 002, 003, 004 (amended), 005, 007 (amended) | REQ-CP-CS-008 (split from CS-004, deferred); CS-006 deferred |
| [SPEC-BP-STAGEGRAPH](../workflow-blueprints/stagegraph.md) | REQ-BP-SG-009 | — |
| [SPEC-BP-GOAL-DIRECTED](../workflow-blueprints/goal-directed.md) | REQ-BP-GD-011 (gives already-mandated pause a family owner) | REQ-BP-GD-012 |
| [ADR-0004](../../adr/0004-deep-agent-cognitive-state-and-context-schemas.md) | Narrowed acceptance recommended; status stays `proposed` | — |

Independent review returned `accept_with_fixes`, and the fixes are applied on this branch. Acceptance is mechanical: the acceptance commit changes only status lines. Spec 05 becomes `canonical`, with `deferred_requirements` kept as non-authority. ADR-0004 becomes `accepted`, with `deferred_decisions` kept proposed. Each amendment status becomes accepted.

Out of scope for AMD-RRM-001: generalized framework extraction, company fixtures, arbitrary mid-invocation cognitive editing, HITL interrupt resumption, and executable forks from intermediate checkpoints.

## AMD-RRM-001 contract disposition

Citations are to the application repository at integration commit `e946742`. **Reuse** means the item keeps its semantics, with only additive fields where noted. **Version** means a new schema or storage version, or a forward-only migration, replaces the item's contract while its accepted mechanism is kept. **Retire** means the item is removed from active mission paths and left inert; physical deletion is a later ticket. Successor requirements are AMD-RRM-001 IDs.

| # | Item | Citation | Disposition | Rationale and successor |
|---|---|---|---|---|
| **Identities** | | | | |
| 1 | `BellLabsRunKey`, `ExecutionEpochKey` | `app/domain/graph_runtime/identities.py:15-28` | reuse | Scope, run, and epoch identity; a fork is a new run at epoch 1 |
| 2 | `GraphIdentity` | `identities.py:31-34` | reuse (out of mission) | Not inert: it is a field of `GraphAssemblyDefinition` (`app/domain/graph_runtime/definitions.py:411`), used by the coordinator `RunPlanV3` launch (`app/application/coordinator/coordinator_launch.py:36, 102`). Retained for coordinator `RunPlanV3`; no mission contract depends on it |
| 3 | `DeploymentIdentity` | `identities.py:37-42` | version | Agent Server deployment identity moves into `AsyncSubagentContract` hosting fields (DA-019); never a macro binding |
| 4 | `AgentThreadKey` | `identities.py:45-58` | retire | Agent Server thread with fork/linked relationships encoded in it; replaced by the cognitive session namespace and qualified key (DA-016), and by the async `child_execution_id` |
| 5 | `AgentRunKey` | `identities.py:61-64` | retire | The provider run ID already lives on `AsyncSubagentExecution` (`app/domain/operation_execution/contracts.py:713`) |
| 6 | `LangGraphCheckpointKey` | `identities.py:67-71` | version | No `checkpoint_ns`, no checkpointer identity, no parent, and a mandatory deployment endpoint; replaced by the qualified checkpoint key (`CON-CP-CHECKPOINT-LINEAGE-V1`) |
| 7 | `GoalHandoffCheckpointKey` | `identities.py:74-76` | reuse | BellLabs handoff identity, not a LangGraph checkpoint |
| 8 | `SemanticOperationAttemptKey` | `identities.py:79-106` | version | Lacks epoch, mapped instance, workflow cycle, slot, revision, role, and session generation; uses a delimiter key; replaced by `CON-CP-RUNTIME-UNIT-V1` (EXEC-013) |
| 9 | `RuntimeTransportAttemptKey` | `identities.py:109-111` | retire | Agent Server submission attempt; replaced by the Activity attempt observation (EXEC-014) |
| 10 | `SubagentProfileKey`, `LinkedBellLabsRunKey` | `identities.py:114-131` | reuse | Unchanged; not on the mission path |
| 11 | `OperationAttemptIdentity` | `app/domain/operation_execution/contracts.py:51-58` | reuse | `semantic_key` stays the basis of the `operation/{id}` wire identity; the runtime unit travels beside it |
| 12 | `StageExecutionIdentity`, `GoalIterationIdentity`, `GoalAgentRunIdentity` | `app/domain/orchestration/contracts.py:261-296, 777-802` | reuse | Sources of the unit location fields |
| **Operation, binding, and result contracts** | | | | |
| 13 | `DeepAgentExecutionBinding` | `operation_execution/contracts.py:898-996` | version | Add the frozen cognitive session namespace and unit identity (DA-016); schema digests reused (CS-001, CS-007) |
| 14 | `DeepAgentExecutionPlacementProfile` | `contracts.py:840-880` | reuse | The meaning of `reconnect_behavior=checkpoint_resume` is fixed by DA-004 and DA-018 |
| 15 | `RuntimeResult`, `OperationSettlement`, `OperationExecutionResult` | `contracts.py:1220-1226, 1266-1290` | version | Add the result checkpoint key and transition ref (DA-017); runtime ambiguity settles `in_doubt` (RUN-007) |
| 16 | `OperationWorkflowRequest` / `Result` | `contracts.py:1293-1367` | version | Additive unit identity and heartbeat/cancel policy fields; no wire renames |
| 17 | `AsyncSubagentContract` | `contracts.py:610-656` | version | Add `graph_revision`, `graph_binding_digest`, and a deployment credential ref (DA-019) |
| 18 | `AsyncSubagentResultManifest` | `contracts.py:659-694` | version | Free-text `checkpoint_ref` (`:669`) becomes the qualified provider key; attributed or pending usage (DA-011) |
| 19 | `AsyncSubagentLifecycle`; `AsyncSubagentExecution`, `ParentAsyncSubagentLink`, `AsyncSubagentMessage` receipts | `contracts.py:598-607`; `contracts.py:697-775` | version (lifecycle) / reuse | `AsyncSubagentLifecycle` gains `in_doubt`, with exits by observation or the operator decisions `adopt_provider_run` / `orphan_child` (DA-008). The deterministic thread identity and parent link are reused; message receipts map to EXEC-006 states |
| 20 | Sandbox snapshot contracts and service | `contracts.py:1676-1810`; `app/application/workspaces/sandbox_snapshots.py` | reuse | `CON-CP-SNAPSHOT-V1` covers workspace and sandbox state only; it is referenced by, and distinct from, `RunSnapshotManifest` (DA-015) |
| 21 | `WorkflowMessage` / `WorkflowMessageReceipt`; root receipts | `orchestration/contracts.py:41-64`; `app/temporal/workflows/belllabs_run.py:31-58` | version | In-memory statuses are a transport cache; authoritative `accepted`/`delivered`/`applied`/`rejected` receipts live in PostgreSQL (EXEC-006) |
| 22 | `RunContinuityState` | `orchestration/contracts.py:67-99` | version | Add satisfied waits, pause state, and the expected source checkpoint per active unit (EXEC-011) |
| **graph_runtime contracts** | | | | |
| 23 | `RuntimeExecutionBinding`, `RuntimeExecutionAttempt`, `RuntimeExecutionProjection` | `app/domain/graph_runtime/contracts.py:116-175` | retire | Per-epoch binding over `legacy_temporal`/`langgraph_agent_server`; replaced by the operation binding, runtime unit, and inspection reads (RUN-011). Rows 23–27 are still exported by the production schema route `/v2/graph-runtime/schemas` (`app/server.py:23, 244`; `app/api/graph_runtime_schemas.py`). Retirement removes them from that export, or labels them non-authoritative there |
| 24 | `InterventionBase`, `SatisfyWait`, `ResumePause`, `CancelRun` interventions | `graph_runtime/contracts.py:178-225` | retire | Replaced by run-control lifecycle actions (`app/domain/run_control/contracts.py:350-377`) plus receipts; their expected-version and expected-checkpoint checks are kept in that path |
| 25 | `AppendInput`, `RespondToInterrupt`, `DurableInterrupt*` | `graph_runtime/contracts.py:198-220, 284-311` | retire | Mid-invocation editing and HITL are out of scope |
| 26 | `ForkFromCheckpointIntervention`, `ForkRequest`, `ForkReceipt` | `graph_runtime/contracts.py:228-239, 334-352` | version | Add snapshot ref, patch digest, and target admission; a qualified seed key replaces `LangGraphCheckpointKey` and `AgentThreadKey` |
| 27 | `PrivilegedOperatorReconcileIntervention`, `InterventionReceipt` | `graph_runtime/contracts.py:241-281` | version | Becomes the `reconcile_unit` command (unit key and generation; DA-018 decisions); receipt states move to EXEC-006 |
| 28 | `RedactedCheckpointSummary` and redaction allowlist | `graph_runtime/contracts.py:355-365, 465-514` | version / reuse | Summary keyed by the qualified key with compatibility checks (RUN-011/012); allowlist mechanism reused |
| 29 | `ProviderNeutralAttemptMetadata` | `graph_runtime/contracts.py:385-399` | reuse | `retry_class` semantics for consequential tools |
| 30 | Lineage kernel (`LineageKind`, `LineageParentEdge`) | `app/domain/graph_runtime/kernel.py:51-104` | reuse | Additive kinds (`langgraph_checkpoint`, `runtime_unit`, `run_snapshot`) and relationships (`derived_from`, `seeded_from`, `reuses`) |
| **Services** | | | | |
| 31 | `decide_recovery_mode` | `app/application/runtime/runtime_recovery.py:45-98` | reuse | Diagnostic replay isolated, fork as a new run, rollback forbidden |
| 32 | `build_cancellation_plan`, `apply_terminal_runtime_observation` | `runtime_recovery.py:101-183` | retire | Bound to the retired binding status machine; the saga is EXEC-008 over run control and units |
| 33 | `RuntimeForkService` saga and fork protocols | `runtime_recovery.py:186-489` | version | Keep reserve, admit, record, copy, receipt, and its reconciliation. Replace the identical-run-plan check (`:390-391`) with snapshot/patch-compiled admission; assert target epoch 1 (`:459-466`); replace provider `copy_checkpoint` (`:226-239`) with an optional local `cognitive_seed` |
| 34 | `InMemoryForkRepository` | `runtime_recovery.py:272-362` | reuse | Test double |
| 35 | `PostgresForkRepository` | `app/application/runtime/postgres_stage3_kernel_repository.py:749-1001` | version | Keep advisory guard, claims, and idempotency; `reserve()` resolves a source runtime binding (`:794-806`) and must resolve a source snapshot |
| 36 | `RuntimeInterventionService` | `app/application/runtime/runtime_interventions.py:203-323` | version | Keep the fail-closed authorization, expected-version, and reserve/reconcile pattern behind run-control delivery |
| 37 | `ExactRuntimeInterventionRouter` | `runtime_interventions.py:138-200` | retire | Requires an Agent Server route (`:160-161`) |
| 38 | Lineage service and `PostgresExecutionLineageRepository` | `app/application/runtime/runtime_lineage.py:20-156`; `postgres_stage3_kernel_repository.py:75-222` | reuse | Immutable lineage journal with parent traversal |
| 39 | Incident catalog and `PostgresRuntimeIncidentRepository` | `app/application/runtime/runtime_reconciliation.py:130-296`; `postgres_stage3_kernel_repository.py:1004-1219` | reuse | Add `checkpoint_in_doubt`, `async_submission_in_doubt`, and `stale_fence_write` types and a unit-key reference |
| 40 | `PrivilegedRuntimeRepairService` | `app/application/runtime/runtime_repairs.py:46-115` | version | Executor for `reconcile_unit` |
| 41 | Decision/HITL services and `PostgresDecisionRepository` | `app/application/runtime/runtime_decisions.py`; `postgres_stage3_kernel_repository.py:225-392` | retire | HITL is out of scope; inert |
| 42 | Resource lease journal | `app/application/runtime/runtime_resources.py`; `postgres_stage3_kernel_repository.py:395-746` | reuse | Unchanged; not on the mission path |
| 43 | Agent Server macro-runtime prior art | `graph_runtime_dispatch.py`, `agent_server_actions.py`, `runtime_bootstrap.py`, `runtime_execution_bindings.py`, and `postgres_runtime_execution_repository.py` (all in `app/application/runtime/`); `app/integrations/langgraph_agent_server.py` | retire | Not composed in production; must never be revived as a scheduler (ADR-0003) |
| 44 | Operation execution and journal services | `app/application/operations/operation_execution.py:360-475`; `journaled_operation_execution.py:91-356`; `operation_journal.py` | version | Keep claim → observe → authority settlement. Add classification (DA-018), claim fence and lease takeover (EXEC-014), and `in_doubt` for post-dispatch ambiguity (`operation_execution.py:441-459`); `technical_attempt` is hard-coded to 1 (`journaled_operation_execution.py:327`) |
| 45 | Async subagent service and adapter | `app/application/async_subagents/service.py:130-444`; `app/integrations/agents/deep_agents/async_subagents.py:23-223` | version | Keep the reservation and link before submit and the deterministic thread. Add a per-child submission fence (`async_subagents.py:76-91`); classify submission errors `in_doubt` rather than `orphaned` (`service.py:201-214`); resume admitted-unsubmitted children (`service.py:191-192`); real usage and checkpoint refs (`async_subagents.py:220-221`) |
| 46 | Deep Agent adapter | `app/integrations/agents/deep_agents/adapter.py:74-122` | version | Explicit namespace, root `checkpoint_ns`, `durability="sync"`, metadata stamps, result-config capture, and classification before submit (DA-016 to DA-018) |
| **Storage (migrations)** | | | | |
| 47 | `runtime_execution_bindings`, `runtime_execution_attempts`, `runtime_checkpoint_observations`, `runtime_intervention_commands`, `runtime_interrupt_*`, `runtime_async_tasks` | `app/migrations/0012_graph_runtime_operation_journal.sql:4-201`; `0014:1-17` | retire (inert) | Agent Server-shaped: `runtime_provider` (`0012:15-17`), one binding per epoch (`:32`), checkpoint key without namespace (`:101-104`); async tasks superseded by `0016`. A new forward-only migration adds unit, attempt, transition, and receipt records |
| 48 | `operation_effect_claims`, `operation_journal_mutations`, `operation_execution_attempts`, `operation_settlements` | `0012:203-317`; `0018` | version | Active production journal; a forward migration adds the claim fence, unit key, and transition/result checkpoint refs |
| 49 | `runtime_lineage_records` / `_edges` | `0014:25-67` | version | Reuse; extend the relationship CHECK (`:53-56`) additively |
| 50 | `runtime_reconciliation_incidents`, `runtime_repair_audit`, `runtime_retention_deletion_audit` | `0014:153-189, 215-245` | reuse | Add a unit-key column. The new migration MUST drop the FK from `runtime_reconciliation_incidents.binding_id` to the retired `runtime_execution_bindings` (`0014:176-177`); the column stays nullable and unused |
| 51 | `runtime_fork_requests` | `0014:191-213` | version | Add source snapshot and patch. The new migration MUST make `source_binding_id` nullable and drop its FK to the retired `runtime_execution_bindings` (`:195, 208-209`) |
| 52 | `runtime_decision_requests` / `_responses` | `0014:110-151` | retire (inert) | HITL is out of scope |
| 53 | `execution_resource_leases` | `0014:69-108` | reuse | Unchanged |
| 54 | `async_subagent_authority`, `_commands`, `_facts`, `_messages` | `app/migrations/0016_async_subagent_parent_child_v1.sql:4-61` | version | Reuse. A forward migration adds the per-child submission fence, the `in_doubt` lifecycle fact, and the `adopt_provider_run` / `orphan_child` decisions. These widen the `command_kind` CHECK (`0016:30`) |
| **Workflows (mechanics)** | | | | |
| 55 | Root `request_cancel`, `deliver_message`, `signal_message` | `app/temporal/workflows/belllabs_run.py:60-73` | version | Become delivery targets of recorded commands; a raw cancel bypasses journaled intent (EXEC-008) |
| 56 | StageGraph `satisfy_wait` / `resume_pause` | `app/temporal/workflows/stagegraph.py:51-61, 456-464` | version | Delivery of recorded commands; waits carried across Continue-As-New; `_resumed_pauses` is never read |
| 57 | GoalDirected `goal_paused` / `goal_cancelling` | `app/temporal/workflows/goal_directed.py:229-234, 402-425` | version | Durable pause (GD-011); cancellation completes the saga (EXEC-008) |
| 58 | `OperationWorkflow` activity call | `app/temporal/workflows/operation.py:74-90` | version | Heartbeat timeout and cancellation delivery (EXEC-008); attempt observation (EXEC-014) |
