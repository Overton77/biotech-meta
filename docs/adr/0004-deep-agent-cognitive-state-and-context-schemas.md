---
id: ADR-0004
title: Exact cognitive state and runtime-context schemas for Deep Agent materialization
status: proposed
recorded_at: 2026-08-09
supersedes: []
superseded_by: []
source_documents:
  - path: ../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/BELLLABS_AGENT_WORKFLOW_CONTRACT_ARCHITECTURE.md
    sections: [5, 6, 12, boundary model]
  - path: ../specs/control-plane-foundations/04-deep-agent-materialization-subagents-workspaces-and-artifacts.md
    sections: [Purpose, Requirements, Contracts]
  - path: https://docs.langchain.com/oss/python/deepagents/customization
    sections: [state_schema, context_schema]
  - path: https://docs.langchain.com/oss/python/deepagents/context-engineering
    sections: [custom state schema, runtime context]
affects_specs:
  - SPEC-CP-DEEP-AGENT-RUNTIME
  - SPEC-CP-COGNITIVE-SCHEMAS
  - SPEC-CP-DEFINITIONS
---

# ADR 0004: Exact cognitive state and runtime-context schemas for Deep Agent materialization

## Context

When a Temporal `OperationWorkflow` materializes a Deep Agent from a Workflow Type / ERC / operation binding, `create_deep_agent` accepts `state_schema` and `context_schema`. Deep Agents already supplies `messages`, `files` (StateBackend), `todos`, and optional `structured_response`. BellLabs still needs a governed rule for:

- which additional graph-state channels are universal versus Workflow Type–specific;
- how those schemas are authored, digested, and frozen on the execution binding;
- how they differ from BellLabs `ContextPolicyDefinition` / `ContextAssemblySpec` (prompt/evidence assembly);
- what sync subagents may inherit versus receive as a projected slice.

Without this rule, adapters invent ad-hoc TypedDicts, checkpoints become incompatible across revisions, and agent state risks absorbing admission, budget, or secret authority.

## Decision

1. **Two cognitive schema kinds, distinct from BellLabs context assembly.**
   - `CognitiveStateSchema` maps to Deep Agents `state_schema` (subclass of `DeepAgentState`): mutable, checkpointed channels for tools and middleware.
   - `CognitiveRuntimeContextSchema` maps to Deep Agents `context_schema`: immutable per-attempt bindings passed at invoke time.
   - Existing `ContextPolicyDefinition` / `ContextAssemblySpec` / `SubagentContextSlice` remain prompt/evidence assembly and child context projection. They are not the Deep Agents `context_schema` type.

2. **Ownership on the control-plane spine.**
   - Workflow Type / WorkflowConfiguration declare **semantic channel packs** (required/forbidden packs and stage overrides) by exact content-addressed refs.
   - Blueprint names stage roles only; it does not embed Python schema types.
   - `DeepAgentProfile` / operation assembly / `DeepAgentExecutionBinding` pin exact `cognitive_state_schema_ref` + digest and `cognitive_context_schema_ref` + digest.
   - The Deep Agents adapter is the sole composition root that resolves digests to Python types for `create_deep_agent`.

3. **Inherit Deep Agents built-ins; do not redeclare them.**
   - Built-in: `messages`, `files`, `todos`, and `structured_response` when `response_format` is set.
   - BellLabs minimum custom **state** channels:
     - `artifact_index` — path/slot metadata (digest, size, owner, access, kind); never file bodies.
     - `context_manifest` — active context-assembly digest and entry identity for reconstruction.
     - `child_result_index` — admitted `SubagentResultManifest` refs/digests for this attempt.
   - Workflow Type packs mount on top of that base. Schema-selection drafts and similar belong in packs, not the universal base.

4. **Placement rule for fields.**
   - Mutable working facts tools/middleware need across turns → state.
   - Attempt identity, grants-as-refs, feature flags, lease handles → runtime context.
   - Secrets and live credentials → context as refs/handles only; never checkpoint payloads.
   - Admission, budgets, terminality, stage readiness, accepted outputs → BellLabs host / Temporal; never agent schemas.

5. **Subagent default is projection, not convenience inherit.**
   - Declarative sync subagents may share the parent state **type** for framework compatibility, but the materializer seeds only an allowlisted `SubagentStateSlice` and a projected runtime-context instance.
   - Compiled / Temporal-delegated children carry their own bound schemas.
   - File content sharing via Deep Agents `files` remains a capability decision; durable truth for BellLabs workspaces is `artifact_index` + promotion.

6. **Compatibility.**
   - Any channel add/rename/type/reducer change produces a new schema digest and a new binding. Checkpoint restore requires digest agreement.

## Consequences

- `SPEC-CP-COGNITIVE-SCHEMAS` owns vocabulary, invariants, requirements, and contracts for cognitive schemas.
- `CON-CP-DEEP-AGENT-BINDING-V1` gains exact cognitive schema digests.
- WP-CP-040 materialization must fail closed when schema digests are missing, collide, or drift from middleware-contributed channels.
- Domain and public contracts stay free of Deep Agents / LangGraph imports.

## Rejected alternatives

### Put Python `state_schema` / `context_schema` types on WorkflowTypeDefinition

Rejected: Workflow Type owns semantic meaning, not framework types. Pack refs and ceilings are enough.

### Duplicate filesystem bodies in custom state alongside Deep Agents `files`

Rejected: StateBackend already owns in-graph file content. BellLabs adds metadata/index and durable promotion, not a second blob store.

### Treat BellLabs ContextAssembly as Deep Agents context_schema

Rejected: different lifetimes and purposes. Assembly selects what enters prompts/evidence; runtime context binds attempt-scoped immutable inputs.

### Full parent state/context inherit for sync subagents

Rejected: violates the accepted isolation invariant (no ambient inherit of messages, secrets, writable FS, skills, MCP, or authority).

## Compatibility and migration impact

Pre-production: extend profile/binding contracts and the Deep Agents adapter; no dual-read or backfill required. Existing skeletal graph assemblies that only record `state_schema_digest` must be completed with cognitive pack composition before production materialization.

## Revisit triggers

- Deep Agents changes built-in state channels or subagent inheritance semantics.
- A Workflow Type needs a universal channel that cannot live in a pack without forcing every operation to carry it.
- Evidence that `artifact_index` should be middleware-private rather than graph-shared.

## RRM-001 disposition recommendation (AMD-RRM-001, 2026-10-01)

Status remains `proposed`. AMD-RRM-001 recommends **acceptance narrowed** to the decisions that the executing system already depends on and that exact checkpoint lineage requires. The status change is recorded only by the reviewer.

| Decision | Recommendation | Reason |
|---|---|---|
| 1. Two cognitive schema kinds | accept | Implemented on the exact binding and materializer; WP-CP-040 evidence |
| 2. Ownership on the spine | accept the binding and adapter pinning; **defer** Workflow Type / WorkflowConfiguration pack declaration | Pinning is implemented; no Workflow Type declares packs and no mission ticket needs it |
| 3. Inherit built-ins plus three base channels | accept | Implemented and inspected |
| 4. Placement rule for fields | accept | Already enforced by reference-only context validation and sensitive-key rejection |
| 5. Subagent default is projection | **defer** | Projected seeding is not implemented; sync subagents stay bounded by REQ-CP-DA-007 |
| 6. Compatibility: digest change makes a new binding; restore requires agreement | accept | Required by exact checkpoint lineage; enforced through the stamped digest (REQ-CP-DA-016, REQ-CP-CS-007) |

Excluding the ADR entirely was rejected: accepted runtime code and evidence (WP-CP-040) already depend on decisions 1, 3, 4, and 6. Accepting it unchanged was also rejected, because decisions 2 (in part) and 5 are unproven and outside the mission. The spec-level mirror is `SPEC-CP-COGNITIVE-SCHEMAS` § Acceptance scope.
