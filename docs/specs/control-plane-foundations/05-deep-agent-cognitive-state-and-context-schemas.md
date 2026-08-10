---
id: SPEC-CP-COGNITIVE-SCHEMAS
title: Deep Agent cognitive state and runtime-context schemas
status: draft
version: 1
governed_by: [ADR-0003, ADR-0004]
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-DEEP-AGENT-RUNTIME]
sources:
  - path: ../../adr/0004-deep-agent-cognitive-state-and-context-schemas.md
    sections: [Decision]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/BELLLABS_AGENT_WORKFLOW_CONTRACT_ARCHITECTURE.md
    sections: [5.2, 5.4, 6.2, 12]
  - path: https://docs.langchain.com/oss/python/deepagents/context-engineering
    sections: [custom state schema, runtime context]
supersedes: []
requirements:
  - REQ-CP-CS-001
  - REQ-CP-CS-002
  - REQ-CP-CS-003
  - REQ-CP-CS-004
  - REQ-CP-CS-005
  - REQ-CP-CS-006
  - REQ-CP-CS-007
contracts:
  - CON-CP-COGNITIVE-STATE-SCHEMA-V1
  - CON-CP-COGNITIVE-CONTEXT-SCHEMA-V1
  - CON-CP-COGNITIVE-CHANNEL-PACK-V1
qualification_obligations:
  - QUAL-CP-DEEP-AGENT-MATERIALIZATION
---

# Deep Agent cognitive state and runtime-context schemas

## Purpose

Define how BellLabs authors, compiles, and materializes Deep Agents `state_schema` and `context_schema` when an operation is built from a Workflow Type → ERC → operation binding → Temporal activity.

## Boundary and explicit non-ownership

This specification owns cognitive schema vocabulary, channel packs, digests, materialization mapping, and subagent projection rules.

It does **not** own:

- prompt/evidence assembly (`ContextPolicyDefinition` / `ContextAssemblySpec`);
- workspace durability or artifact promotion (`SPEC-CP-DEEP-AGENT-RUNTIME`);
- macro lifecycle, budgets, admission, or terminality;
- Workflow Type domain output contracts;
- Python type modules outside the Deep Agents adapter.

## Authority and persistence

| Concern | Authority |
|---|---|
| Channel-pack and schema definition digests | MongoDB/Beanie + content-addressed payloads |
| Exact digests on `DeepAgentExecutionBinding` | Immutable binding document |
| Checkpointed cognitive state | LangGraph checkpointer under the operation attempt |
| Runtime context instance | Constructed per invoke inside the Temporal activity; not a BellLabs authority record |
| Accepted outputs / evidence | PostgreSQL/application services |

## Vocabulary and identities

- **CognitiveStateSchema:** content-addressed description of graph state channels mapped to `create_deep_agent(state_schema=...)`. Must subclass Deep Agents `DeepAgentState` at the adapter boundary.
- **CognitiveRuntimeContextSchema:** content-addressed description of immutable per-attempt fields mapped to `create_deep_agent(context_schema=...)` and invoke `context=`.
- **CognitiveChannelPack:** named, versioned set of channels with types, reducers, sensitivity, and contributor (`base` | `middleware` | `workflow_type` | `operation_role`).
- **EffectiveCognitiveStateSchema / EffectiveCognitiveContextSchema:** compiler union of packs for one binding, with digests frozen on the binding.
- **SubagentStateSlice / SubagentContextSlice:** allowlisted projections for a child; not full-parent inherit.
- **artifact_index:** state channel of path/slot → `{digest, byte_count, owner, access, kind, promoted?}` metadata only.
- **context_manifest:** state channel holding the active BellLabs context-assembly digest and entry identities.
- **child_result_index:** append-only admitted child result manifest refs/digests.

Naming rule: never call Deep Agents `context_schema` “context assembly,” and never call BellLabs context assembly “context_schema.”

## Invariants

1. Deep Agents built-ins (`messages`, `files`, `todos`, optional `structured_response`) are inherited, not redeclared as BellLabs channels.
2. Custom state holds refs/digests/indexes; not secret material, not admitted products, not budget ledgers.
3. Runtime context is immutable for the attempt and may carry refs/handles only for secrets and live capabilities.
4. Schema digests on the binding are exact; workers resolve no aliases or inheritance at runtime.
5. Middleware-contributed state channels appear in the effective state schema digest or materialization fails closed.
6. Channel name collisions across packs fail closed unless type + reducer digests are identical.
7. Sync subagents receive projected slices by default; compiled and Temporal children use their own bindings.
8. Changing channel set, type, or reducer ⇒ new digest ⇒ new binding; checkpoint restore requires digest match.

## State and lifecycle (materialization)

```text
WorkflowType / WorkflowConfiguration
  declares required/forbidden CognitiveChannelPack refs + stage overrides
    -> DeepAgentProfile / OperationAssembly
         selects base + middleware + role packs
    -> Compiler
         unions packs -> EffectiveCognitive{State,Context}Schema digests
    -> DeepAgentExecutionBinding
         freezes schema refs/digests + subagent slice refs
    -> Temporal OperationWorkflow activity
         adapter loads digests -> Python DeepAgentState subclass + context dataclass
         builds context= from attempt IDs, grants-as-refs, flags
         seeds state with artifact_index / context_manifest / empty child_result_index
         create_deep_agent(state_schema=..., context_schema=...)
         invoke(..., context=...)
    -> typed result proposal + artifact candidates
         host admits; agent state never self-admits
```

### Field placement

| Put in | When |
|---|---|
| `state_schema` | Tools/middleware mutate it across turns; must checkpoint with the attempt |
| `context_schema` | Immutable attempt binding; must not be model-editable graph state |
| Neither (host) | Admission, budgets, terminality, stage graph position, accepted outputs |

### Minimum BellLabs custom state

On every Deep Agent operation unless an authored degradation omits a channel with explicit evidence:

1. `artifact_index`
2. `context_manifest`
3. `child_result_index`

Use Deep Agents `files` for StateBackend scratch content. For sandbox/composite backends, `artifact_index` is the graph-visible filesystem truth; file bodies live in the workspace/object store.

### Workflow-specific packs

Mounted only when the Workflow Type / stage role requires them (examples, not base):

- schema-selection candidate draft channels;
- reviewer finding namespaces;
- other domain scratch that tools must mutate mid-loop.

Prefer `response_format` / `structured_response` for terminal structured candidates when mid-loop mutation is unnecessary.

## Requirements

### REQ-CP-CS-001 — Distinct cognitive schema kinds

Bindings MUST record separate exact `cognitive_state_schema_ref`/`digest` and `cognitive_context_schema_ref`/`digest`, and MUST NOT treat BellLabs `ContextAssemblySpec` as either Deep Agents schema kind.

**Verification:** schema/compiler rejects collapsed or missing digests.

### REQ-CP-CS-002 — Adapter is the sole type composition root

Only the Deep Agents adapter/composition root MAY construct Python `DeepAgentState` subclasses and context dataclasses from frozen digests; domain and public contracts MUST remain free of framework type imports.

**Verification:** import/boundary tests; no `create_deep_agent` outside the adapter.

### REQ-CP-CS-003 — Built-ins plus minimum base channels

Effective state schemas MUST subclass `DeepAgentState`, preserve built-in channels, and include `artifact_index`, `context_manifest`, and `child_result_index` unless a recorded degradation omits one.

**Verification:** binding fixture digest and invoke seed checks.

### REQ-CP-CS-004 — Workflow packs compile exactly

Workflow Type / WorkflowConfiguration pack allowlists and stage overrides MUST be intersected into the effective schemas at compile time; unknown, forbidden, or colliding channels MUST fail closed.

**Verification:** compiler fixtures for allow, forbid, collide, and stage override.

### REQ-CP-CS-005 — Middleware channels are frozen

Every middleware-declared contributed state channel MUST appear in the effective state schema digest with matching reducer identity.

**Verification:** middleware manifest vs schema digest mismatch fails before invoke.

### REQ-CP-CS-006 — Subagent projection default

Synchronous dictionary subagents MUST receive an exact `SubagentStateSlice` and projected runtime-context instance; they MUST NOT receive parent secrets, full message history, or undeclared writable channels by convenience.

**Verification:** child invoke seed contains only allowlisted channels; secret fields absent.

### REQ-CP-CS-007 — Checkpoint compatibility is digest-gated

Resume/restore of cognitive checkpoints MUST require binding `cognitive_state_schema_digest` agreement; mismatch MUST fail closed without silent channel coercion.

**Verification:** digest-mismatch restore rejected.

## Contracts

### CON-CP-COGNITIVE-CHANNEL-PACK-V1

```yaml
kind: cognitive_channel_pack
logical_id: pack.belllabs.cognitive-state-base
revision: 1
contributor: base  # base | middleware | workflow_type | operation_role
channels:
  - name: artifact_index
    value_kind: map
    value_schema_ref: content_ref
    reducer: merge_by_key
    sensitivity: internal
    notes: metadata only; no file bodies
  - name: context_manifest
    value_kind: object
    value_schema_ref: content_ref
    reducer: replace
    sensitivity: internal
  - name: child_result_index
    value_kind: append_list
    value_schema_ref: content_ref
    reducer: append_unique_by_id
    sensitivity: internal
digest: sha256:...
```

### CON-CP-COGNITIVE-STATE-SCHEMA-V1

Exact union of pack refs, channel table, reducer registry digest, framework baseline (`deepagents` version / `DeepAgentState` compatibility), and `schema_digest`. Bound on `DeepAgentExecutionBinding`.

### CON-CP-COGNITIVE-CONTEXT-SCHEMA-V1

Exact field table for attempt-scoped immutable context (run/attempt/generation IDs, ERC/binding digests, capability grant refs, feature flags, workspace mount handles). Forbids secret material plaintext. Bound on `DeepAgentExecutionBinding`. Includes per-subagent projection specs.

## Failure, retry, cancellation, and recovery

- Missing/drifted schema digests fail in preparation before `create_deep_agent`.
- Technical retry of the same attempt reuses the same binding and schema digests.
- Disruptive restart may advance execution generation and create new checkpoint lineage under the same attempt; schema digests remain those of the binding.
- Cancellation does not promote `artifact_index` entries; promotion remains a host decision.

## Security, tenancy, redaction, and secrets

Runtime context and state may store secret **references** only. Checkpoint, trace, and Temporal payloads MUST pass existing sensitive-key rejection rules. Subagent projections strip parent-only grants.

## Dependencies and compatible implementations

Depends on Deep Agents `0.7.5` local materialization under `SPEC-CP-DEEP-AGENT-RUNTIME`. Declarative sync subagents inherit parent state **types** at the framework layer; BellLabs still applies projected seeds. Compiled and async children use separate bindings.

## Qualification and evidence

Covered by `QUAL-CP-DEEP-AGENT-MATERIALIZATION`: compile packs → freeze digests → materialize → seed state/context → tool read/write of `artifact_index` → sync subagent projection → checkpoint resume digest gate.

## Open decisions

- Whether `artifact_index` updates are written by a BellLabs filesystem middleware wrapper, custom tools, or both (must still appear in the frozen schema).
- Exact JSON schemas for the three base channel value types.
- First Workflow Type pack contents for schema-context-selection (deferred to that Workflow Type spec).

## Non-goals

- Replacing Deep Agents `files` / `todos` / `messages`.
- Making agent state authoritative for admission or terminality.
- Embedding workflow domain output contracts into the universal base schema.
- Cross-thread Store as scientific authority.

## Source lineage and supersession

Extracts the cognitive-schema decisions from ADR-0004 and the 2026-08-09 architecture discussion grounded in `BELLLABS_AGENT_WORKFLOW_CONTRACT_ARCHITECTURE.md` and Deep Agents customization/context-engineering docs. Complements, does not replace, `SPEC-CP-DEEP-AGENT-RUNTIME`.
