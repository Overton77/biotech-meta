---
id: ADR-0003
title: Temporal macro execution with Deep Agents bounded cognition
status: accepted
recorded_at: 2026-08-09
supersedes:
  - Agent Server-primary macro-runtime decisions in the frozen Stage 0-8 plan
  - OpenAI Agents SDK as the target BellLabs agent framework
superseded_by: []
source_documents:
  - path: ../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [1, 5, 6, 7, 8, 9, 10, 11, 12, 20, 21, 22, 26]
  - path: ../specs/pre-research/control-plane-foundations/01-versioned-workflow-definitions-and-effective-run-configuration.md
    sections: [Solution, Implementation Decisions]
  - path: ../specs/pre-research/control-plane-foundations/02-transactional-run-admission-lifecycle-and-budgets.md
    sections: [Solution, Implementation Decisions]
  - path: ../specs/pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
    sections: [Solution, Implementation Decisions]
  - path: ../specs/pre-research/control-plane-foundations/04-operation-runtime-workspaces-artifacts-and-snapshots.md
    sections: [Solution, Implementation Decisions]
affects_specs:
  - SPEC-CP-DEFINITIONS
  - SPEC-CP-RUN-CONTROL
  - SPEC-CP-DURABLE-EXECUTION
  - SPEC-CP-DEEP-AGENT-RUNTIME
  - SPEC-CP-COGNITIVE-SCHEMAS
  - SPEC-BP-STAGEGRAPH
  - SPEC-BP-GOAL-DIRECTED
---

# ADR 0003: Temporal macro execution with Deep Agents bounded cognition

## Context

BellLabs workflows must remain correct across hours- or days-long execution, worker loss, external waits, human intervention, independently progressing operations, retries, cancellation, and history continuation. The system also needs agent-native planning, tools, Agent Skills, MCP, filesystems, sandboxes, context management, subagents, and LangSmith observability.

Earlier plans alternated between Temporal, Agent Server, and the OpenAI Agents SDK as execution centers. That produced overlapping schedulers and made provider state appear capable of owning BellLabs lifecycle or semantics. The accepted architecture proposal resolved the macro-runtime boundary, and the 2026-08-09 foundation interview selected Deep Agents as the current primary agent framework.

## Decision

Temporal is the sole production macro-workflow execution runtime. Exactly one `BellLabsRunWorkflow` is the stable Temporal root for each admitted BellLabs run. It owns macro execution mechanics and delegates family semantics to a `StageGraphWorkflow`, `GoalDirectedWorkflow`, or a later explicitly accepted family workflow. Independently durable semantic operations execute through the generic `OperationWorkflow`.

BellLabs application services and pure interpreters own semantic authority. PostgreSQL/application services own admission, lifecycle, commands, budgets, effect claims, settlement, terminality, product events, and authoritative parent-child decisions. MongoDB/Beanie owns immutable document-shaped definitions, compiled configurations, bindings, and detailed execution documents. Object storage owns large immutable payloads. Temporal Event History and LangGraph checkpoints are execution records, not product or domain authority.

Deep Agents is the primary agent framework. LangGraph supplies applicable graph, checkpoint, store, and middleware substrates. Deep Agents and LangGraph perform bounded cognition only inside exact BellLabs operation bindings. They cannot grant capabilities, mutate macro lifecycle, enlarge budgets, accept evidence, or terminalize a run.

The OpenAI Agents SDK is removed from the current target architecture, specifications, requirements, and work packages. The provider-neutral operation seam remains open to a separately proposed and qualified future adapter; no such adapter is currently required.

Every Deep Agent is authored through an immutable `DeepAgentProfile`. Authoring may compose exact component revisions, but compilation produces a fully flattened `DeepAgentExecutionBinding` with no runtime inheritance or mutable resolution. Logical agent definition is separate from execution placement. Local in-worker and remote LangSmith deployment are distinct exact placements with separate compatibility and qualification evidence; fallback between them is never silent.

Both synchronous and asynchronous Deep Agents subagents are supported. An asynchronous subagent is a durable subordinate execution owned by its parent `OperationWorkflow`, not automatically a new Workflow Run. It has an exact parent-child contract, identity, binding, context slice, capability and authority ceilings, reservation, lifecycle, messaging, cancellation, evidence, result manifest, dependency policy, and parent admission decision. Work crossing the declared governance boundary is promoted to another `OperationWorkflow` or an independently admitted linked `BellLabsRunWorkflow`.

Deep Agents `0.7.5` is the initial implementation baseline. It is recorded in exact bindings and compatibility evidence, not made a permanent architectural invariant. The implementation will proceed from official framework documentation and resolve concrete integration errors in the implementation vertical; no separate preliminary compatibility probe gates the work.

LangSmith remains required for tracing, evaluation, sandboxes, graph development, and selected qualified remote bounded operations. Agent Server and deployed graphs are never competing StageGraph or GoalDirected macro schedulers.

## Consequences

- The control plane requires canonical contracts for immutable definitions, compilation, admission, lifecycle, budgets, Temporal hierarchy, continuity, messages, linked runs, operation execution, Deep Agent materialization, workspaces, artifacts, snapshots, and subagent relationships.
- StageGraph and GoalDirected require separate specifications because their semantic state machines are not framework behavior.
- Capability catalogs own publication, promotion, retirement, and selection for prompts, models, middleware, tools, MCP, Skills, memory, context, sandboxes, and LangSmith assets. Foundation contracts own their exact references, intersections, bindings, failure behavior, and runtime drift rules.
- The first executable foundation path must materialize one exact MCP server, one exact Agent Skill bundle, and one exact sandbox profile into a Deep Agent inside a Temporal-managed operation.
- Existing OpenAI Agents SDK documentation and experiments may remain only as inert historical
  evidence. Active imports, dependencies, composition, workers, launch paths, live scripts, and
  required tests are deleted when the Deep Agents replacement lands; no compatibility runtime is
  maintained.
- Existing Stage 0-8 implementation packages are frozen as superseded planning history. New `WP-*` packages derive from canonical requirements.

## Rejected alternatives

### Agent Server or LangGraph as the production macro scheduler

Rejected because it creates dual macro authority, weakens independently durable operation boundaries, and makes provider checkpoint state compete with application and Temporal authority.

### OpenAI Agents SDK as the current primary agent framework

Rejected by the 2026-08-09 owner decision. Its assumptions must be removed from current specifications and packages. A future adapter is possible only through a new qualified decision.

### Temporal workflow code owns BellLabs semantics

Rejected because replayable scheduling mechanics must not replace the application lifecycle reducer or the StageGraph and GoalDirected pure interpreters.

### Framework-native asynchronous subagents without BellLabs contracts

Rejected because background availability does not define parent dependency, budget, authority, messaging, cancellation, result admission, late-result, or terminality semantics.

### Every asynchronous subagent becomes a Workflow Run

Rejected because operation-local asynchronous work can have an independent runtime lifecycle without crossing a Workflow Type boundary. Escalation is determined by an explicit governance classifier.

## Pre-production replacement impact

- Replace OpenAI Agents SDK language and contracts in active foundation documents.
- Introduce `DeepAgentProfile`, `DeepAgentExecutionPlacementProfile`, `DeepAgentExecutionBinding`, `AsyncSubagentContract`, `AsyncSubagentExecution`, and `ParentAsyncSubagentLink` contracts.
- Reuse accepted ideas from `OperationAssemblySpec`, StageGraph, and GoalDirected interpreters only
  behind the canonical contracts. Prototype schemas and persistence may be replaced directly;
  BellLabs has no production executions or data requiring compatibility readers, dual writes,
  backfills, drain workers, or legacy replay.
- Freeze the prior stage package index and publish replacement work packages with `ADR-* -> SPEC-* -> REQ-* -> WP-* -> evidence` lineage.
- Treat current async-subagent models as disposable implementation observations; the canonical
  contract replaces them.

## Revisit triggers

- A proposal to add another primary agent framework or macro-workflow runtime.
- Evidence that the local or remote Deep Agents placement cannot meet an accepted required contract.
- A new Deep Agents version that changes binding, checkpoint, subagent, middleware, or backend compatibility.
- A need for an async subagent to cross a Workflow Type, authority, independent terminality, or reusable-product-output boundary.
