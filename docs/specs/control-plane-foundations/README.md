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
5. [SPEC-CP-COGNITIVE-SCHEMAS](05-deep-agent-cognitive-state-and-context-schemas.md) — Deep Agents `state_schema` / `context_schema` packs, digests, and materialization (draft; governed by proposed ADR-0004).
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
