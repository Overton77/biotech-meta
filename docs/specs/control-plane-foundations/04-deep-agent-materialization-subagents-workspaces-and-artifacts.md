---
id: SPEC-CP-DEEP-AGENT-RUNTIME
title: Deep Agent materialization, subagents, workspaces, artifacts, and snapshots
status: canonical
version: 2
governed_by: [ADR-0003]
amendments:
  - id: AMD-RRM-001
    recorded_at: 2026-10-01
    base_revision: c48867a
    status: proposed_for_acceptance  # RRM-001 independent review pending; not yet accepted
    summary: qualified checkpoint identity and namespaces, invocation transition CAS, terminal reconstruction versus resume, async-subagent hosting and settlement touchpoints
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-RUN-CONTROL, SPEC-CP-DURABLE-EXECUTION]
sources:
  - path: ../pre-research/control-plane-foundations/04-operation-runtime-workspaces-artifacts-and-snapshots.md
    sections: [provider-neutral runtime, workspace, artifact, and snapshot decisions]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [8, 9, 10, 15, 17, 18, 20, 21, 22]
supersedes:
  - ../pre-research/control-plane-foundations/04-operation-runtime-workspaces-artifacts-and-snapshots.md
requirements:
  - REQ-CP-DA-001
  - REQ-CP-DA-002
  - REQ-CP-DA-003
  - REQ-CP-DA-004
  - REQ-CP-DA-005
  - REQ-CP-DA-006
  - REQ-CP-DA-007
  - REQ-CP-DA-008
  - REQ-CP-DA-009
  - REQ-CP-DA-010
  - REQ-CP-DA-011
  - REQ-CP-DA-012
  - REQ-CP-DA-013
  - REQ-CP-DA-014
  - REQ-CP-DA-015
  - REQ-CP-DA-016
  - REQ-CP-DA-017
  - REQ-CP-DA-018
  - REQ-CP-DA-019
contracts:
  - CON-CP-DEEP-AGENT-PROFILE-V1
  - CON-CP-DEEP-AGENT-PLACEMENT-V1
  - CON-CP-DEEP-AGENT-BINDING-V1
  - CON-CP-ASYNC-SUBAGENT-V1
  - CON-CP-WORKSPACE-MANIFEST-V1
  - CON-CP-ARTIFACT-PROMOTION-V1
  - CON-CP-SNAPSHOT-V1
  - CON-CP-CHECKPOINT-LINEAGE-V1
qualification_obligations:
  - QUAL-CP-DEEP-AGENT-MATERIALIZATION
  - QUAL-CP-ASYNC-SUBAGENT-LIFECYCLE
---

# Deep Agent materialization, subagents, workspaces, artifacts, and snapshots

## Purpose

Define how a provider-neutral BellLabs operation deterministically becomes a bounded Deep Agent execution with exact models, middleware, tools, MCP servers, Agent Skills, context, memory, filesystems, sandboxes, synchronous subagents, asynchronous subordinate executions, tracing, and durable outputs.

## Boundary and explicit non-ownership

This specification owns the runtime materialization contract and the provider adapter boundary. It defines exact references, binding, workspace ownership, subagent relationships, artifact promotion, and snapshot restore. Cognitive `state_schema` / `context_schema` channel packs and digests are owned by companion `SPEC-CP-COGNITIVE-SCHEMAS`. Capability-specific catalogs own asset intake, validation, promotion, retirement, and discovery. Temporal owns durable macro mechanics; application services own authority and settlement.

## Authority and persistence

MongoDB/Beanie owns immutable `OperationAssemblySpec`, `DeepAgentProfile`, placement profiles, execution bindings, subagent execution/link documents, workspace manifests, artifact metadata, and snapshot metadata. PostgreSQL owns authoritative reservations, commands, parent dependency/result decisions, effects, settlement, and lifecycle. Object storage owns bundles, files, artifacts, and snapshots. LangGraph checkpoints and LangSmith traces remain subordinate runtime evidence.

## Vocabulary and identities

- **DeepAgentProfile:** immutable logical agent definition composed from exact capability revisions.
- **DeepAgentExecutionPlacementProfile:** immutable placement-specific runtime and compatibility contract.
- **DeepAgentExecutionBinding:** fully flattened run/operation-specific record of intended and actual execution.
- **Capability Attachment Plan:** exact mapping of a selected capability to its agent, middleware, tool, filesystem, context, or sandbox attachment surface.
- **Synchronous subagent:** bounded child invoked and joined within the parent agent execution.
- **AsyncSubagentContract:** immutable permitted shape for a background subordinate.
- **AsyncSubagentExecution:** one exact launched child runtime task/thread/checkpoint lineage.
- **ParentAsyncSubagentLink:** authoritative relationship, dependency policy, message/cancellation state, and result-admission history.
- **Run Workspace Namespace:** logical collection of operation/stage/cycle/agent/subagent sandboxes for one run.

Added by AMD-RRM-001:

- **Cognitive session namespace:** the BellLabs-owned name of one cognitive checkpoint lineage. The LangGraph `thread_id` is derived deterministically from it. It is distinct from LangGraph's `checkpoint_ns`, which names graph and subgraph scopes inside a thread.
- **Qualified checkpoint key:** `(checkpointer_ref digest, thread_id, checkpoint_ns, checkpoint_id)` plus the parent `checkpoint_id`. It is the only form in which BellLabs records refer to a LangGraph checkpoint.
- **Invocation:** one adapter call into the graph for one unit generation. It is either a *submission*, which appends the unit's input exactly once, or a *resumption*, which supplies no input.
- **Source checkpoint / result checkpoint:** the namespace head expected before an invocation, and the checkpoint captured after it.
- **Checkpoint transition observation:** the BellLabs record that links one unit generation's source checkpoint, result checkpoint, and result manifest.

## Invariants

1. No agent/runtime side effect occurs before an exact binding and authoritative reservation exist.
2. Authoring composition is flattened before admission; workers resolve no aliases, inheritance, or runtime defaults.
3. Logical profile and execution placement are separate; placement never changes silently.
4. Deep Agents `0.7.5` is the initial exact implementation baseline, not a permanent invariant.
5. Capability availability, prompts, Skills, MCP metadata, middleware, checkpoints, and model output never grant authority.
6. Both synchronous and asynchronous subagents are bounded by the parent operation grant and exact profile.
7. An async child cannot mutate parent state or satisfy parent obligations until its exact result is admitted.
8. Workspace files become durable only through typed artifact promotion.
9. Snapshot restore always clones to a new workspace and reauthorizes live capabilities.

## State and lifecycle

Operation preparation validates the run/config/control revision and reservation, materializes read-only inputs/capabilities and owned writable slots, persists the binding, then invokes the exact placement adapter. Execution emits typed progress/effects/usage and returns a result proposal. Artifact promotion and result settlement are separate authoritative decisions.

An async subordinate follows `proposed -> admitted -> submitted -> running | waiting -> completed | failed | cancelled | orphaned -> result_admitted | result_rejected | result_deferred`. Provider observations cannot skip BellLabs admission, reconciliation, or parent result admission.

## Requirements

### REQ-CP-DA-001 — Provider-neutral operation seam

The application MUST invoke Deep Agents through a provider-neutral `OperationExecutor` contract that receives a typed operation request, exact binding, authoritative resource lease, and cancellation context and returns a typed outcome.

**Verification:** native and Deep Agent adapters pass one outcome/idempotency conformance suite.

### REQ-CP-DA-002 — Immutable Deep Agent profile

Every Deep Agent operation MUST reference an immutable `DeepAgentProfile` declaring exact model, output schema, prompt/context, ordered middleware, backend/store/checkpointer, tools, MCP, Skills, memory, sandbox, synchronous/async subagents, delegation, HITL, limits, tracing, cognitive state/context schema pack refs, and compatibility requirements.

**Verification:** schema rejects unknown fields, incomplete required surfaces, and digest mismatch.

### REQ-CP-DA-003 — Flattened exact execution binding

The compiler/materializer MUST emit one immutable `DeepAgentExecutionBinding` containing all resolved component revisions/digests, attachment order/targets, authority, placement, workspace, reservations, runtime/package versions, cognitive state/context schema digests, subagent schema slices, and accepted degradation decisions; runtime inheritance and mutable lookup are forbidden.

**Verification:** execution succeeds after aliases/heads change and fails on component drift. Cognitive schema rules are owned by `SPEC-CP-COGNITIVE-SCHEMAS`.

### REQ-CP-DA-004 — Placement is separately governed

Each binding MUST select exactly one qualified `local_in_worker` or `remote_langsmith_deployment` placement profile with explicit checkpoint, cancellation, streaming, sandbox, messaging, retry/reconnect, and compatibility behavior; no execution may silently fall back to another placement.

**Verification:** unqualified placement and fallback substitution fail before side effects.

**AMD-RRM-001 (clarified):** For `local_in_worker`, `reconnect_behavior: checkpoint_resume` means the classification-and-recovery protocol of REQ-CP-DA-018. Re-invoking the same input is not a reconnect. `checkpoint_behavior: local_checkpointer` requires a persistent, registered saver in production composition. In-memory savers are test-only and do not qualify recovery.

### REQ-CP-DA-005 — Capability materialization is exact

The materializer MUST attach only exact authorized model, prompt, middleware, tool, MCP server/tool, Agent Skill, context, memory, filesystem, sandbox, and tracing revisions at their declared targets and MUST reject collisions or unsupported mappings unless an authored degradation permits omission.

**Verification:** foundation tracer materializes one MCP server, Skill bundle, and sandbox and rejects digest/filter/mount drift.

### REQ-CP-DA-006 — Capability catalogs and runtime stay separated

The runtime MUST consume exact selected revisions and attachment plans without performing public discovery, installation, alias resolution, promotion, or catalog mutation.

**Verification:** network/catalog access is absent from the execution path except exact runtime endpoints in the binding.

### REQ-CP-DA-007 — Synchronous subagents remain bounded

Synchronous subagent definitions MUST be exact components of the parent profile, inherit only explicitly delegated tools/data/workspace/budget, and return through the parent execution without independent macro lifecycle authority.

**Verification:** delegation ceiling and child-private workspace tests.

### REQ-CP-DA-008 — Async subagents are first-class subordinate executions

An async-subagent spawn MUST create an immutable `AsyncSubagentContract`, exact execution identity/thread/checkpoint binding, reservation, context slice, authority/capability ceiling, parent link, and durable lifecycle record before provider submission.

**Verification:** QUAL-CP-ASYNC-SUBAGENT-LIFECYCLE.

**AMD-RRM-001 (clarified):** The following hold for the reservation, parent link, PostgreSQL authority record, and Mongo detail of an async child:

- **Before submission.** All four MUST exist before any provider submission.
- **Identity.** The provider thread ID is the BellLabs `child_execution_id`.
- **One provider run.** Each child has at most one provider run. Submission is fenced per child, so at most one submitter runs at a time. A submitter first looks up an existing run by its BellLabs spawn key and creates a run only if none exists.
- **Ambiguity.** An ambiguous outcome is classified `in_doubt` and reconciled by observation, never by a second spawn. Ambiguous outcomes are a submission whose result is unknown, more than one provider run carrying the spawn key, or a served graph identity mismatch.
- **`orphaned`.** A child becomes `orphaned` only after reconciliation records that no provider run exists and the link policy says so. A raised submission error alone never makes it `orphaned`.
- **Interrupted submission.** A child left `admitted` without a provider binding after a crash is resumed by the same fenced submission path.
- **Agent Server restart.** After a restart, the parent reconciles from the server's durable thread and run state.
- **Inspection.** Child lineage is exposed through REQ-CP-RUN-011.
- **Forks.** Active children are classified under REQ-CP-EXEC-016.

### REQ-CP-DA-009 — Parent dependency policy is frozen

Every async spawn MUST declare exactly one `required_blocking`, `degradable_blocking`, `nonblocking`, or `advisory` parent dependency class plus timeout, cancellation propagation, late-result, fallback, and result-admission policies selected within the `DeepAgentProfile` ceiling.

**Verification:** exercise all classes and prevent runtime/model weakening.

### REQ-CP-DA-010 — Parent and async child communicate through typed contracts

Parent-to-child and child-to-parent communication MUST use immutable addressed messages/commands with sequence, correlation, receipt, expiry/supersession, and context-authority classification; provider thread content alone is not durable delivery.

**Verification:** ordered delivery, retry, stale target, parent completion, and child waiting cases.

### REQ-CP-DA-011 — Async results require parent admission

An async child MUST return a typed result manifest containing exact output/evidence/usage/checkpoint/effect references and digest; the parent authority MUST admit, reject, or defer it before use, and late results MUST NOT mutate a settled parent.

**Verification:** completion, duplicate callback/poll, rejected evidence, and late result.

**AMD-RRM-001 (clarified):** The manifest's checkpoint reference MUST be the provider's qualified checkpoint key: thread, namespace as reported, checkpoint ID, and served graph identity. A thread-only reference is insufficient. Usage MUST be the provider-attributed amounts. Usage the provider cannot attribute MUST be recorded as pending, never dropped. Child usage and reservations settle against the parent run's budget ledger through the parent operation's authority (REQ-CP-RUN-009). A cancel request reaches the provider run, and the provider's acknowledgement or its ambiguity is recorded under REQ-CP-EXEC-008.

### REQ-CP-DA-012 — Governance boundary triggers escalation

The delegation classifier MUST escalate work to another `OperationWorkflow` or linked `BellLabsRunWorkflow` when its Workflow Type, authority, independent terminality, reusable product output, substantial separate budget, durable cross-operation wait, or settlement needs exceed the async-subagent contract.

**Verification:** boundary fixtures produce the exact escalation decision without launching a hidden child.

### REQ-CP-DA-013 — Workspace ownership is explicit

Every operation, agent, and subagent MUST receive a logical namespace with read-only governed inputs and exact exclusive writable slots; host paths, ambient environment, credentials, network, and tools MUST NOT be inherited implicitly.

**Verification:** parallel ownership, read-only mounts, secret isolation, and unmapped-file cases.

### REQ-CP-DA-014 — Artifact promotion is the durability boundary

Only a typed idempotent promotion decision validating slot, owner, candidate/content digest, producer binding, permissions, checks, output contract, metadata, object payload, and manifest linkage MAY make a workspace file consumable or obligation-satisfying.

**Verification:** exact retry, conflicting content, partial failure, orphan reconciliation, and visibility predicate.

### REQ-CP-DA-015 — Snapshot restore clones and reauthorizes

Every snapshot MUST be immutable and content-addressed; restore MUST create a new workspace identity, verify compatibility/digests, and reacquire current secrets, connections, leases, mounts, tools, and authority without treating snapshot contents as grants.

**Verification:** two restores, tamper, incompatible runtime, stale credential, and post-restore promotion cases.

**AMD-RRM-001 (clarified):** `CON-CP-SNAPSHOT-V1` covers sandbox and workspace state only. It is not the macro `RunSnapshotManifest` of REQ-CP-EXEC-012. A run snapshot may reference sandbox snapshots, and a fork restores them only through this requirement's clone-and-reauthorize semantics.

### REQ-CP-DA-016 — Qualified checkpoint identity and namespaces

Every local Deep Agent invocation MUST address exactly one cognitive session namespace, whose `thread_id` is derived deterministically from it. It MUST run the root graph in LangGraph's root checkpoint namespace (`checkpoint_ns = ""`) with `durability="sync"`. It MUST stamp scalar BellLabs invocation metadata on every checkpoint it writes. Every BellLabs record of a checkpoint MUST use the qualified checkpoint key and its parent ID. A record MUST NOT contain checkpoint bodies, transcripts, or secrets.

**Amendment:** AMD-RRM-001, new (protocol detail).

**Namespaces** (in `CON-CP-CHECKPOINT-LINEAGE-V1`):

- A StageGraph unit owns one namespace per unit generation.
- A GoalDirected executor or verifier role owns one namespace per session generation, shared intentionally by that session's ordered units (REQ-BP-GD-012).
- An async child's namespace is its provider thread.

**Root and subgraph namespaces.** A custom root `checkpoint_ns` is prohibited. The installed LangGraph treats a non-empty namespace as a subgraph path when reading state. Checkpoints written under non-root namespaces of the same thread (subgraphs and synchronous subagents) are recorded as nested evidence only. They never count as root-namespace descendants.

**Schema gate.** A checkpoint whose stamped state-schema digest differs from the reading unit's binding is incompatible under REQ-CP-CS-007.

**Verification:** real persistent saver: one unit's source and result keys are recorded with parentage; stamped metadata is present on every root checkpoint of the invocation; a schema-digest mismatch is rejected; GoalDirected reuse and rollover map to the expected namespaces.

### REQ-CP-DA-017 — Invocation transitions are linked and compare-and-set

For each unit generation, the adapter path MUST:

1. record the expected source checkpoint before dispatch, under REQ-CP-EXEC-014;
2. capture the result checkpoint config from the post-invocation state snapshot;
3. persist one checkpoint transition observation with compare-and-set on the namespace head being the expected source.

The observation links `unit_key`, generation, claim fence, namespace, source key, result key with its ancestry to the source, binding digest, state schema digest, result manifest ref and digest, and a redacted summary digest.

A namespace has at most one in-flight invocation. A conflicting, duplicate-with-different-content, or out-of-order observation MUST fail closed. An exact duplicate MUST be idempotent. The `RuntimeResult`, the operation result, and the settlement MUST reference the result checkpoint key of the transition they settle.

**Amendment:** AMD-RRM-001, new (storage and protocol detail). It completes the checkpoint/runtime lineage obligation of `QUAL-CP-DEEP-AGENT-MATERIALIZATION`.

**Verification:** before/after keys recorded for one operation; duplicate delivery is idempotent; a concurrent second invocation of the namespace is rejected; a stale-fence observation is rejected; the settlement references the result key.

### REQ-CP-DA-018 — Terminal reconstruction versus interrupted resume

On every Activity attempt, before any provider work, the adapter path MUST classify the unit generation from BellLabs records and the checkpointer, and MUST act exactly as `CON-CP-CHECKPOINT-LINEAGE-V1` prescribes. A checkpoint written by the current submission never authorizes appending that input again. Any state other than the unique cases listed MUST create an `in_doubt` reconciliation incident and MUST NOT invoke the model. Ambiguous states include more than one stamped leaf, a head that does not descend from the source, a metadata or digest mismatch, a recorded checkpoint that is missing, or a checkpointer that cannot be classified. Resolution requires a privileged, typed operator reconciliation command (REQ-CP-RUN-011).

**Amendment:** AMD-RRM-001, new (protocol detail). It implements REQ-CP-EXEC-005 and REQ-CP-RUN-007 for local cognition.

**Verification:** crash injection at each window in the contract table, asserting model and tool invocation counts, human-input message counts, ancestry, and the final result digest. It runs against a persistent saver and the application database with a real worker restart.

### REQ-CP-DA-019 — Async subagent hosting is exact and non-scheduling

An Agent Server used for async subagents MUST host only graphs materialized from exact BellLabs async-subagent bindings through the canonical adapter and materializer. Each graph is identified in its `AsyncSubagentContract` by graph ID, graph revision, and binding digest. The parent MUST verify the served identity before the first submission and on every reconnect. Such a server MUST NOT register or execute BellLabs root, family, or operation-workflow semantics. It is never a macro scheduler (ADR-0003).

**Amendment:** AMD-RRM-001, new (deployment and contract detail). The `AsyncSubagentContract` document schema gains `graph_revision`, `graph_binding_digest`, and a deployment credential *reference*, with no secret value.

**Verification:** a served graph mismatch fails before submission; the dedicated server configuration lists only bound async graphs; the root application graph configuration registers no BellLabs macro graphs.

## Contracts

### CON-CP-DEEP-AGENT-PROFILE-V1

Defines logical agent identity/revision/digest, `deepagents` framework family, model and structured output, prompt/context, ordered middleware, backend/store/checkpointer, tools/MCP/Skills, memory, sandbox, sync and async subagent policies, HITL, limits, tracing, and compatible placements.

### CON-CP-DEEP-AGENT-PLACEMENT-V1

Defines `local_in_worker` or `remote_langsmith_deployment`, exact runtime/package/deployment identity, graph/checkpoint compatibility, task queue, cancellation, streaming, message injection, reconnect, sandbox, trace, and qualification refs.

### CON-CP-DEEP-AGENT-BINDING-V1

Defines the flattened exact operation binding and records both intended attachments and actual resolved use. It includes ERC/control/attempt/generation identity, all component digests, cognitive state/context schema digests, subagent schema slices, placement, workspace, reservation, authority, redaction, fallback, and compatibility.

### CON-CP-ASYNC-SUBAGENT-V1

Defines `AsyncSubagentContract`, `AsyncSubagentExecution`, and `ParentAsyncSubagentLink`: parent/child identities, objective and context slice, binding, authority, resources, dependency class, lifecycle, messages, cancellation, effects, result manifest, admission, late-result, and escalation policy.

### CON-CP-WORKSPACE-MANIFEST-V1, CON-CP-ARTIFACT-PROMOTION-V1, CON-CP-SNAPSHOT-V1

Define logical slots and ownership, candidate-to-admitted artifact state, and immutable clone-on-restore lineage respectively.

### CON-CP-CHECKPOINT-LINEAGE-V1 (AMD-RRM-001, new)

**Cognitive session namespaces.** These are local placement rules. Each namespace string is also the LangGraph `thread_id`.

```text
stage_graph unit:      belllabs/stage/{unit_key}/gen/{execution_generation}
goal_directed role:    belllabs/goal/{belllabs_run_id}/epoch/{execution_epoch}/session/{session_generation}/role/{executor|verifier}
async child:           provider thread = child_execution_id   (checkpoint_ns as reported by the provider)
```

The rules for these namespaces are:

- A GoalDirected generation boundary, rollover, or fresh-from-handoff selection starts a new `session_generation`, and therefore a new namespace. An existing thread is never branched.
- A derived (forked) run uses its own run ID, and therefore its own namespaces.
- The binding records the namespace it was bound with. Workers MUST NOT derive a different one.

**Invocation metadata.** The adapter passes the following as scalar config metadata, which LangGraph copies onto every checkpoint the invocation writes:

- `belllabs_unit_key`;
- `belllabs_execution_generation`;
- `belllabs_invocation_id`, which is the SHA-256 of `(unit_key, execution_generation, "submit")` and is therefore stable across Activity attempts;
- `belllabs_binding_digest`;
- `belllabs_state_schema_digest`.

No secret, prompt, or scope value is stamped.

**Transition observation.** Each transition observation records:

- `unit_key`, `execution_generation`, and `claim_fence`;
- `namespace`;
- `source_key`, the qualified key, or none for a new namespace;
- `result_key`, the qualified key with its parent;
- `ancestry_verified`, a boolean;
- `binding_digest` and `state_schema_digest`;
- `classification`, the classification applied;
- `result_manifest_ref` and its digest;
- `redacted_summary_digest`;
- `observed_at`.

The CAS key is `(namespace, expected head)`.

**Classification and action.** Each attempt classifies the unit generation and acts as follows. "Stamped" means the checkpoint carries this unit generation's `belllabs_invocation_id`.

| Classification | Condition | Action |
|---|---|---|
| `settled` | An authoritative settlement exists for the unit generation | Return the stored result; no provider work |
| `observed_unsettled` | A transition observation with a result manifest exists, but no settlement | Settle from the recorded manifest; no invocation |
| `not_submitted` | No stamped root-namespace checkpoint exists, and the namespace head equals the expected source | Submit: invoke once with the unit's input |
| `interrupted` | Exactly one stamped root-namespace lineage descends from the source, and its latest checkpoint has pending tasks | Resume: invoke with no input from that checkpoint; never append the input again |
| `terminal_unobserved` | Exactly one stamped lineage descends from the source, and its latest checkpoint has no pending tasks or interrupts | Reconstruct the result from that checkpoint's state after the metadata and digest checks, record the observation by CAS, then settle; no invocation |
| `in_doubt` | Anything else, including a pending LangGraph interrupt, which remains outside this mission's scope | Create an incident; no invocation; wait for operator reconciliation |

**Crash windows.** Recovery after a crash at each point is as follows.

| Crash point | Next attempt classifies as | Result |
|---|---|---|
| Before any stamped checkpoint | `not_submitted` | Single submission |
| After the input checkpoint or an intermediate checkpoint | `interrupted` | Resume without re-appending input |
| After the terminal checkpoint, before observation | `terminal_unobserved` | Reconstruct, observe, and settle |
| After observation, before settlement | `observed_unsettled` | Settle |
| After settlement | `settled` | Return |

Provider calls made after the last durable checkpoint may repeat after a crash; cognition is at-least-once. Their usage is recorded as pending or ambiguous, never dropped. Graph durability does not make tool side effects transactional. A consequential tool effect MUST use an effect claim (REQ-CP-RUN-007), and an ambiguous one is reconciled through that claim rather than repeated.

**Operator reconciliation decisions.** These are typed and audited:

- `accept_descendant`, with an exact qualified key;
- `abandon_unit`, which settles the unit `failed` with reason `in_doubt_abandoned`;
- `start_new_generation`, which crosses a generation boundary under REQ-CP-EXEC-005.

## Failure, retry, cancellation, and recovery

Preparation failure is persisted against the binding before provider invocation. Technical retry reuses attempt, binding, async task, and effect identities. Start-bind-wait/reconcile handles remote and async tasks through callback or polling convergence. Cancellation is best effort at the provider and authoritative only after BellLabs reconciliation. Orphan and late-old-generation outputs are quarantined.

## Security, tenancy, redaction, and secrets

Secrets are just-in-time references and never enter profiles, ERCs, bindings, prompts, traces, messages, manifests, snapshots, or Temporal payloads. Prompt/context segments and capability metadata are trust-classified. MCP exposure is the exact intersection of server policy, tool filters, operation grant, caller authority, approvals, and revocation state.

## Dependencies and compatible implementations

Deep Agents `0.7.5` local execution is the first required implementation. Remote LangSmith placement remains explicit and capability-gated until its exact contract is qualified. Full capability catalogs immediately follow the foundation and replace immutable fixture provisioning without changing these contracts.

## Qualification and evidence

`QUAL-CP-DEEP-AGENT-MATERIALIZATION` proves profile compilation, exact attachments, local placement, tracing, cancellation, checkpoint/runtime lineage, workspace, artifact, and snapshot behavior. `QUAL-CP-ASYNC-SUBAGENT-LIFECYCLE` proves all dependency classes, messaging, continuation, cancellation, retry/reconcile, result admission, late results, and escalation.

## Open decisions

- Numeric async-child limits, default timeout values, and provider-specific orphan-reconciliation cadence.
- Remote LangSmith placement promotion evidence.
- AMD-RRM-001: the redacted checkpoint-summary allowlist fields, beyond the minimum in REQ-CP-RUN-012, and the exact `belllabs_*` metadata key spellings. These are owned parameters.

These do not weaken the parent/child contract.

## Initial async mechanism decision

Deep Agents `0.7.5` `AsyncSubAgentMiddleware` is the initial provider mechanism. It launches and
manages background Agent Protocol work through start/check/update/cancel/list tools backed by the
LangGraph SDK. BellLabs wraps those tools inside the parent `OperationWorkflow` adapter: the
canonical contract, parent link and reservation are persisted before start; returned thread/run
identities are provider bindings; polling produces observed facts; and provider completion becomes
a typed result manifest requiring parent admission. Middleware agent state is never lifecycle,
message-ledger, settlement, or terminality authority. Callback delivery may be added later as a
reconciliation optimization without changing the contract.

## Non-goals

- Full prompt, MCP, Skill, tool, middleware, memory, sandbox, or LangSmith catalog implementation.
- Allowing runtime discovery or arbitrary package installation.
- Making every async child a Workflow Run.
- Treating framework checkpoints or provider task status as domain authority.

## Source lineage and supersession

This document preserves the provider-neutral runtime, workspace, artifact, and snapshot decisions of pre-research foundation 04, removes the OpenAI Agents SDK target completely, and replaces it with the accepted Deep Agent profile, placement, binding, and async-subagent contracts.

## Amendment record

| Amendment | Recorded | Status | Scope |
|---|---|---|---|
| AMD-RRM-001 | 2026-10-01 | proposed for acceptance (RRM-001 review pending) | Clarified: REQ-CP-DA-004, 008, 011, and 015; `CON-CP-ASYNC-SUBAGENT-V1` (contract schema fields). New: REQ-CP-DA-016, 017, 018, and 019; `CON-CP-CHECKPOINT-LINEAGE-V1`. |

The notation follows `SPEC-CP-DURABLE-EXECUTION` § Amendment record.

Evidence for the root-namespace rule: in the pinned LangGraph `1.2.10`, `Pregel.get_state` treats a non-empty configured `checkpoint_ns` as a subgraph path and raises if no such subgraph exists (`langgraph/pregel/main.py`, state-read path). `get_checkpoint_metadata` copies scalar `config["metadata"]` keys onto every written checkpoint (`langgraph/checkpoint/base/__init__.py`). `durability` accepts `sync`, `async` (the default), and `exit` (`langgraph/types.py`). RRM-003 must re-verify these facts against the persistent Postgres saver.
