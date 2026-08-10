---
id: SPEC-CP-DEEP-AGENT-RUNTIME
title: Deep Agent materialization, subagents, workspaces, artifacts, and snapshots
status: canonical
version: 1
governed_by: [ADR-0003]
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
contracts:
  - CON-CP-DEEP-AGENT-PROFILE-V1
  - CON-CP-DEEP-AGENT-PLACEMENT-V1
  - CON-CP-DEEP-AGENT-BINDING-V1
  - CON-CP-ASYNC-SUBAGENT-V1
  - CON-CP-WORKSPACE-MANIFEST-V1
  - CON-CP-ARTIFACT-PROMOTION-V1
  - CON-CP-SNAPSHOT-V1
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

### REQ-CP-DA-009 — Parent dependency policy is frozen

Every async spawn MUST declare exactly one `required_blocking`, `degradable_blocking`, `nonblocking`, or `advisory` parent dependency class plus timeout, cancellation propagation, late-result, fallback, and result-admission policies selected within the `DeepAgentProfile` ceiling.

**Verification:** exercise all classes and prevent runtime/model weakening.

### REQ-CP-DA-010 — Parent and async child communicate through typed contracts

Parent-to-child and child-to-parent communication MUST use immutable addressed messages/commands with sequence, correlation, receipt, expiry/supersession, and context-authority classification; provider thread content alone is not durable delivery.

**Verification:** ordered delivery, retry, stale target, parent completion, and child waiting cases.

### REQ-CP-DA-011 — Async results require parent admission

An async child MUST return a typed result manifest containing exact output/evidence/usage/checkpoint/effect references and digest; the parent authority MUST admit, reject, or defer it before use, and late results MUST NOT mutate a settled parent.

**Verification:** completion, duplicate callback/poll, rejected evidence, and late result.

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
