# BellLabs Pre-Research Specification Suite

> **Superseded foundation authority (2026-08-09).** The four control-plane foundation documents
> indexed below remain source material, not implementation authority. Their canonical replacements
> are in [`../control-plane-foundations/`](../control-plane-foundations/README.md), with StageGraph
> and GoalDirected owned separately under
> [`../workflow-blueprints/`](../workflow-blueprints/README.md). The remaining pre-research
> capability and Workflow Type documents require later disposition against those foundations.

## Purpose

This suite turns the accepted pre-research syntheses into implementation-sized specifications for the BellLabs research, ingestion, evaluation, and curated-content backend services.

The suite covers:

- shared Workflow Run execution and control-plane foundations
- reusable schema, conversation, realtime, memory, and agentic-capability services
- Starter Content Refinement
- Knowledge Preflight

The dashboard user interface is not specified here. The command, query, authorization, projection, and realtime contracts needed by a later dashboard are included.

These documents are local specifications, not GitHub issues. Ticket publication remains a separate operator-controlled step.

## Governing Sources

The accepted system workflow execution and control-plane synthesis governs shared architecture.

The accepted Starter Content Refinement and Knowledge Preflight syntheses govern their Workflow Type semantics.

The Human Upgrade System Context supplies canonical vocabulary. The composable Workflow Runs and assertion-centered temporal knowledge graph ADRs remain binding where later syntheses have not superseded older names or details.

## Shared Authority Rules

- PostgreSQL is authoritative for Workflow Run lifecycle, commands, transition records, budgets, Run Composition Links, approvals, transactional outbox events, durable cursors, and authorization-facing projections.
- MongoDB/Beanie is authoritative for immutable definitions, Effective Run Configuration payloads, Operation Execution Bindings, workflow-shaped documents, findings, plans, evaluations, and output metadata.
- Temporal owns durable execution mechanics, not domain authority.
- Object storage owns large immutable payloads, promoted artifacts, reports, bundles, and snapshots.
- Neo4j owns approved canonical graph knowledge and is read-only to Knowledge Preflight and Starter Content Refinement.
- Prompts, agents, Agent Skills, MCP servers and tools, plugins, memory, conversations, schema resources, workspaces, and model output are never authority merely because they exist.

## Canonical Dependency DAG

Abbreviations:

- `F`: control-plane foundation
- `C`: shared control-plane capability
- `P`: Knowledge Preflight
- `R`: Starter Content Refinement

```text
F1 Versioned definitions and configuration compiler
  -> F2 Transactional admission, lifecycle, outbox, and budgets
  -> F3 Blueprint orchestration and linked runs
  -> F4 Operation runtime, workspaces, artifacts, and snapshots

F1 + F2 + F3 + F4
  -> C1 Schema catalog, deployment manifest, and workspace materialization

F1 + F2 + F4
  -> C2 Conversations, session projections, and durable realtime
  -> C3 Governed workflow and mission memory

F1 + F2 + F4
  -> C4 Governed agentic capability catalogs and exact bindings

F1 + F2 + C1
  -> P1 Knowledge Preflight deterministic core

P1 + F3 + F4 + C1 + C2
  -> P2 StageGraph Knowledge Preflight
  -> P3 GoalDirected Knowledge Preflight

F1 + F2
  -> R1 Starter Content Refinement deterministic core

R1 + F3 + F4 + C2 + P2
  -> R2 StageGraph Starter Content Refinement
  -> R3 GoalDirected Starter Content Refinement

R1 + F4 + C4 + R2
  -> R4 Guest Business Affiliation Summary
```

`F4` initially uses pre-provisioned exact fixture bindings. `C4` later replaces fixture provisioning with governed catalog selection without changing the runtime binding contract.

`C3` is independently deliverable after its prerequisites. A workflow profile that enables memory depends on it; an explicit no-memory profile does not.

## Specifications

### Control-Plane Foundations

1. [F1 — Versioned Workflow Definitions and Effective Run Configuration](./control-plane-foundations/01-versioned-workflow-definitions-and-effective-run-configuration.md)
2. [F2 — Transactional Run Admission, Lifecycle, and Budgets](./control-plane-foundations/02-transactional-run-admission-lifecycle-and-budgets.md)
3. [F3 — Durable Blueprint Orchestration and Linked Runs](./control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md)
4. [F4 — Operation Runtime, Workspaces, Artifacts, and Snapshots](./control-plane-foundations/04-operation-runtime-workspaces-artifacts-and-snapshots.md)

### Shared Control-Plane Capabilities

1. [C1 — Schema Catalog, Deployment Manifest, and Workspace Materialization](./control-plane-capabilities/01-schema-catalog-deployment-manifest-and-workspace-materialization.md)
2. [C2 — Conversations, Session Projections, and Durable Realtime](./control-plane-capabilities/02-conversations-threads-session-projections-and-durable-realtime.md)
3. [C3 — Governed Workflow and Mission Memory](./control-plane-capabilities/03-governed-workflow-and-mission-memory.md)
4. [C4 — Governed Agentic Capability Catalogs and Exact Bindings](./control-plane-capabilities/04-governed-agentic-capability-catalogs-and-bindings.md)

### Implementation Companions

1. [Durable Task-Subagent Artifacts and Context Engineering](../implementation/2026-07-21-durable-task-subagent-artifacts-and-context-engineering.md)

### Knowledge Preflight

1. [P1 — Domain Contracts and Deterministic Core](./knowledge-preflight/01-knowledge-preflight-domain-contracts-and-deterministic-core.md)
2. [P2 — StageGraph Vertical Slice](./knowledge-preflight/02-stagegraph-knowledge-preflight-vertical-slice.md)
3. [P3 — GoalDirected Extension](./knowledge-preflight/03-goaldirected-preflight-extension.md)

### Starter Content Refinement

1. [R1 — Domain Contracts and Deterministic Core](./starter-content-refinement/01-refinement-domain-contracts-and-deterministic-core.md)
2. [R2 — StageGraph Vertical Slice](./starter-content-refinement/02-stagegraph-refinement-vertical-slice.md)
3. [R3 — GoalDirected Extension](./starter-content-refinement/03-goaldirected-refinement-extension.md)
4. [R4 — Guest Business Affiliation Summary Operation](./starter-content-refinement/04-guest-business-affiliation-summary-operation.md)

## First Executable Path

The first executable path is intentionally narrow but end to end:

1. compile immutable StageGraph and GoalDirected fixtures
2. admit a Run Request transactionally
3. start and orchestrate an admitted blueprint
4. execute one governed sandbox operation with a pre-provisioned exact binding
5. persist and replay authorized conversation/realtime projections
6. attest and materialize the graph schema
7. run StageGraph Knowledge Preflight
8. run StageGraph Starter Content Refinement with a linked preflight result

GoalDirected variants, governed capability intake, the guest-affiliation operation, and governed memory follow as separately verifiable extensions.
