# BellLabs priority scope and sequencing

Use this reference to select the next canonicalization and implementation frontier. Re-check active repository indexes and handoffs; this file is routing guidance, not independent architecture authority.

## Immediate outcome

Reach executable implementation plans for:

1. Temporal root/family/operation workflow foundation.
2. Exact operation assembly and bounded Deep Agents runtime.
3. StageGraph runtime and vertical proof.
4. GoalDirected runtime, token/context rollover, typed handoff, fresh session, independent verification, and convergence.
5. One first production-shaped Workflow Type.

Do not require the entire documentation corpus to be canonical before this vertical begins.

## Short-term specification scope

### Control-plane foundations

- versioned definitions and effective run configuration;
- transactional admission, lifecycle, commands, budgets, effects, settlement, and terminality;
- Temporal hierarchy and Continue-As-New identities;
- StageGraph and GoalDirected semantics;
- linked runs, result admission, cancellation, and lineage;
- operation assembly/executor;
- workspaces, artifacts, sandboxes, and snapshots.

### Control-plane capabilities

- prompts and dynamic context;
- Agent Skills;
- MCP servers and tools;
- custom tools and consequential-effect governance;
- capability catalogs, compatibility, exact bindings, and runtime drift;
- conversations, durable realtime, steering, HITL, interventions, and recovery;
- advanced memory management, LangGraph Store boundaries, and PGVector retrieval;
- LangSmith tracing, evaluation, Agent Server, and remote bounded operations.

### Workflow and knowledge domains

- Starter Content Refinement;
- Knowledge Preflight;
- Schema Context Selection and schema deployment compatibility;
- Source Intelligence and provenance;
- coordinator-agent MCP server and API/control-plane facade.

### Platform required by those capabilities

- MongoDB/Beanie system collections;
- Supabase application PostgreSQL and PGVector;
- separate Temporal persistence;
- S3 artifact/bucket lifecycle;
- Neo4j and Neo4j GraphQL directive-schema/API role;
- FastAPI public control plane;
- custom AWS deployment.

## Recommended waves

### Wave 0: minimum lineage

Create governance policy, status/supersession policy, traceability schema, document registry, and accepted runtime/persistence/document-governance ADRs.

### Wave 1: executable runtime spine

Canonicalize Temporal hierarchy, operation assembly, StageGraph, GoalDirected session handoff, Deep Agents runtime, and the chosen first Workflow Type. Produce implementation work packages immediately.

### Wave 2: control-plane completeness

Canonicalize linked runs, commands/events, steering, HITL, conversations, capability catalogs, prompts, skills, MCP, tools, workspaces, sandboxes, snapshots, and memory.

### Wave 3: domain workflows and coordinator

Canonicalize Knowledge Preflight, Starter Content Refinement, Source Intelligence, Schema Context Selection, and coordinator MCP/API behavior.

### Wave 4: production platform

Canonicalize MongoDB/Beanie, Supabase/PGVector, S3, Neo4j/GraphQL, FastAPI, LangSmith operational boundaries, AWS topology, security, recovery, and cutover.

## First Workflow Type selection gate

Choose the first Workflow Type using existing executable seams and implementation-package dependencies, not documentation completeness. Record the choice and why alternatives follow later. It must exercise the real admission, Temporal, operation, persistence, result, and evidence boundaries claimed by the current implementation stage.

