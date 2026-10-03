# Knowledge Preflight Workflow Synthesis

Date: 2026-07-18

Status: Accepted pre-specification synthesis

Related:

- [System workflow execution and control-plane synthesis](./2026-07-18-system-workflow-execution-and-control-plane-synthesis.md)
- [Starter Content Refinement synthesis](./2026-07-18-starter-content-refinement-workflow-synthesis.md)
- [Schema workspace checkpoint](../checkpoints/schema_schema_workspaces_efficient_db_interaction/2026-07-16-large-schema-workspaces-selection-and-report-splitting-special-checkpoint.md)
- [Pre-research architecture checkpoint](../checkpoints/system-level/2026-07-18-pre-research-architecture-synthesis-and-grill-entry-checkpoint.md)

## 1. Purpose

`KnowledgePreflightWorkflow` performs broad, observational discovery of existing entities, graph knowledge, prior work, coverage, contradictions, unresolved identities, and gaps before mission specification, deep research, or another consuming workflow.

It is independently runnable and composable as a linked Workflow Run.

Its primary output is an immutable Knowledge Preflight Snapshot that makes a bounded historical observation reproducible and purpose-aware.

## 2. Non-goals

Knowledge Preflight does not:

- mutate the canonical Neo4j graph
- resolve entity identity
- adjudicate Assertions as accepted truth
- repair graph records
- silently start ingestion or graph maintenance
- treat one database query as broad preflight coverage
- copy the live graph into an output snapshot
- make current graph state a substitute for a versioned observation
- turn retrieval rank or similarity into confidence in truth
- use live Neo4j introspection as the authoritative Schema Definition

Any proposed graph repair, enrichment, identity resolution, ingestion, or maintenance proceeds through a separate linked Workflow Run and its own authority contract.

## 3. Actors and launch paths

Allowed callers include:

- operator through FastAPI
- coordinator through a typed backend tool
- Starter Content Refinement through a declared linked-run slot
- Mission Specification or another Workflow Run through a declared linked-run slot
- service account under accepted policy

The workflow may be standalone or mission-owned. Its contract and output do not change based on caller.

## 4. Inputs

The workflow accepts a typed `KnowledgePreflightBrief` containing:

- purpose and intended downstream use
- target subjects, concepts, assertions, questions, or artifact/package references
- graph and prior-work questions
- temporal, jurisdictional, population, evidence, provenance, or other scope dimensions
- requested retrieval modalities
- coverage obligations
- freshness requirements
- exclusions
- output detail and result limits
- permission and data-access context
- optional prior Knowledge Preflight Snapshot references

The Run Input Manifest freezes:

- exact brief revision
- admitted Starter Packages, Extracted Seeds, canonical entity references, artifacts, reports, prior snapshots, or operator-provided referents
- exact Schema Definition and Schema Catalog Build references
- required Schema Deployment Manifest
- access and Permission Assessment references
- selected blueprint and Effective Run Configuration

Unresolved referents are valid inputs when their uncertainty is explicit. They do not become canonical identities through admission.

## 5. Admission contract

Admission must establish:

- a valid purpose and at least one target or declared graph-wide coverage question
- an exact versioned Schema Definition
- an exact deterministic Schema Catalog Build derived from that definition
- a Schema Deployment Manifest whose deployed SDL hash exactly matches the bound Schema Definition hash
- authorized read access for every requested data surface
- permitted retrieval modalities and limits
- a valid blueprint revision and Effective Run Configuration
- budget sufficient for required coverage obligations

Strict schema compatibility is a precondition, not a warning. If the deployment manifest is missing or its SDL hash differs, the run is rejected before graph work starts.

Neo4j introspection may provide diagnostics, index availability, and operational health information, but cannot establish directive-SDL hash equality.

## 6. Workflow invariants

1. Every graph observation binds an exact Schema Definition, Schema Catalog Build, Schema Deployment Manifest, and observation time.
2. Preflight is observational; no operation may mutate Neo4j or canonical knowledge.
3. Retrieval observations preserve provider/index/query context and native ranking evidence.
4. BellLabs reranking, classification, confidence, and selection remain separate from native retrieval evidence.
5. Graph Match Candidates remain provisional and may coexist.
6. No match means only that no match was found within the assessed scope.
7. Contradictions and gaps are hypotheses until later workflows evaluate them.
8. Coverage is assessed against explicit obligations, not inferred from result count.
9. Identity resolution and graph repair cross a Workflow Type boundary.
10. Large payloads are referenced immutably rather than embedded without limit.
11. The Schema Workspace is read-only run materialization, never canonical schema state.
12. Every selected result and conclusion remains traceable to exact retrieval observations and queries.

## 7. Mandatory Schema Workspace setup

### 7.1 Authoritative source

The current Schema Definition is:

```text
biotech-kg/src/schema/neo4jbiotechschema.graphql
```

This checked-in Neo4j GraphQL directive SDL is the versioned source from which agent-oriented resources are generated.

The modular TypeScript schema path is not a second authority. The specification must require a build or verification chain that prevents drift between modular definitions and the monolithic authoritative SDL.

### 7.2 Reusable Schema Catalog build

Schema Catalog generation occurs once per Schema Definition content hash and generator version.

The build records:

- Schema Definition path, version, and SHA-256 content hash
- parser and generator versions
- catalog schema version
- generated module, card, drill-down, operation-projection, and index manifests
- bundle content hash and object-storage reference
- deterministic build validation

Repeated requests for the same source and generator identity return the same accepted build or fail if deterministic output differs.

### 7.3 Composable materialization operation

Every Knowledge Preflight run composes the shared `SchemaWorkspaceMaterialization` operation before query planning.

The operation may be attached at run scope or to the first stage needing schema access. It materializes a read-only workspace containing the exact catalog resources allowed by the workspace contract, including:

```text
schema/
  manifest.json
  global/
  modules/
  cards/
  drilldown/
  indexes/
  projections/
  selections/
  skills/schema-navigation/
```

The exact physical layout remains provider-specific. Logical slots and manifest semantics are project-owned.

The resulting `SchemaWorkspaceBinding` records:

- catalog build reference and digest
- Schema Definition version/hash
- Schema Deployment Manifest and exact-hash result
- selected modules and operation projections
- navigation Agent Skill version
- read-only MCP schema-server binding when enabled
- workspace and materialization-manifest references
- materializer version and time

The same operation is composable into other workflows and stages. Knowledge Preflight requires it but does not own its implementation.

### 7.4 Selection and expansion

A preflight may:

- use obvious bounded inline Schema Context Selection
- consume an admitted prior selection
- request a linked `SchemaContextSelectionWorkflow` for broad, ambiguous, expensive, reusable, or review-heavy selection

Agent-produced semantic selection receives deterministic name/topology validation and independent semantic coverage review.

Expansion into complete properties, endpoints, directives, enums, unions, and operation projections is deterministic. It cannot add semantic membership.

## 8. Coverage and query planning

The run binds a `KnowledgePreflightCoverageMatrix`.

Coverage cells may combine:

- target subject or unresolved referent
- question or intended downstream use
- schema module or selected type surface
- retrieval modality
- temporal or jurisdictional scope
- prior-work, graph-knowledge, contradiction, gap, or unresolved-identity objective
- required/degradable/optional/prohibited status

The `KnowledgePreflightQueryPlan` maps each applicable cell to:

- normalized query intent
- selected schema context and operation projection
- retrieval adapter and index/tool
- query text or structured request
- filters and traversal bounds
- result, time, token, and cost limits
- deduplication and aggregation policy
- stopping and continuation evidence

Agents may propose or revise query tactics. Application validation ensures that every executable query is authorized, schema-valid, bounded, and connected to declared coverage.

## 9. Retrieval modalities

The workflow may use governed adapters for:

- exact identifier and property lookup
- full-text search
- vector search
- hybrid lexical/vector search
- bounded graph traversal
- schema-aware Cypher read queries
- relationship and neighborhood inspection
- prior Workflow Run and output search
- Starter Package, artifact, report, and Decision Report retrieval
- configuration/evaluation records when relevant to prior-work discovery

The exact available modalities depend on the Effective Run Configuration, schema operation projection, deployed indexes, permissions, and budget.

Graph access should use a read-only Neo4j principal and adapter-enforced query validation, timeout, row, path-depth, and cost limits.

MongoDB, PostgreSQL, object-store, and retrieval-index queries are also read-only and pass through typed application adapters. Agents do not receive unrestricted database clients.

## 10. Common retrieval observation envelope

Every retrieval call emits an immutable `KnowledgeRetrievalObservation` containing:

- observation identity and time
- coverage cell and query-plan revision
- adapter, provider, database, index, or tool identity and version
- exact structured request or redacted digest
- schema definition/deployment and graph-version context
- native result identity, rank, score, and score semantics
- raw evidence or payload references
- latency, usage, truncation, timeout, and error state
- permission and capability binding
- operation execution binding

Normalization creates separate candidate records. It never overwrites provider-native evidence.

## 11. Allowed blueprint variants

The Workflow Type declares two application-owned blueprint variants. A run binds one immutably at launch.

Both variants must produce the same coverage, observation, snapshot, freshness, evaluation, and mutation-boundary contracts.

### 11.1 `StageGraphPreflight`

The baseline graph is:

```text
Admission
-> Schema Workspace Materialization
-> Subject and Intent Normalization
-> Coverage Matrix and Query Planning
-> Parallel Retrieval Modality Branches
-> Result Normalization and Candidate Aggregation
-> Contradiction, Gap, and Coverage Evaluation
-> Optional Linked Work or Affected-Subgraph Cycle
-> Snapshot Assembly
-> Decision Report
```

#### Retrieval branches

Branches receive exclusive writable work areas and may run in parallel subject to graph/index/resource limits.

A branch may use bounded semantic cycles for:

- query reformulation
- alternative retrieval modality
- topology expansion
- unresolved alias exploration
- evidence needed to classify a possible contradiction

Each cycle records the gap that justified more work and its progress.

#### Whole-workflow cycle

Coverage evaluation may request an affected-subgraph workflow cycle when new graph matches, contradictions, or schema-relevant concepts reveal unassessed required cells.

The cycle decision identifies the exact invalidation frontier and new objective. It does not blindly rerun all retrieval.

### 11.2 `GoalDirectedPreflight`

This variant is for exploratory contradiction and gap pursuit where the useful next query depends heavily on prior observations.

The launch goal is derived from:

- KnowledgePreflightBrief
- coverage matrix
- schema workspace binding
- fixed observation and snapshot contracts

Each iteration may:

- choose the highest-value unsatisfied coverage cells
- formulate bounded schema-valid queries
- use handoffs or task subagents for retrieval and interpretation
- compare new results with prior observations
- propose candidate aggregation
- identify contradictions, gaps, and unresolved identities
- request declared linked work
- propose a bounded Goal Revision

The independent evaluator measures progress through newly assessed cells, new nonduplicate evidence, reduced unresolved scope, and improved contradiction/gap characterization.

Goal evolution may refine the next search target or coverage emphasis. It cannot add unadmitted data surfaces, change intended downstream use, weaken coverage obligations, broaden graph authority, or permit mutation.

## 12. Candidate and assessment model

### 12.1 Graph Match Candidate

A Graph Match Candidate links a provisional input referent or Entity Seed to a possible canonical graph record while preserving:

- match category
- candidate identity
- supporting and opposing observations
- query and graph/schema context
- confidence dimensions and method
- alternatives
- unresolved identity state

Preflight does not select a canonical identity winner.

### 12.2 Existing-knowledge observations

Preflight may identify:

- potentially relevant entities and relationships
- existing Assertions and Adjudications
- prior reports, packages, runs, evaluations, or ingestion records
- source and provenance coverage
- temporal or scope mismatches

These remain exact observed records plus preflight interpretations. Preflight does not rewrite them.

### 12.3 Contradiction candidates

A contradiction candidate preserves:

- exact propositions or graph structures that appear inconsistent
- temporal, jurisdictional, population, dose, formulation, identity, and source context
- evidence for apparent conflict
- reasons the conflict may be only contextual or representational
- confidence and unresolved alternatives
- recommended follow-up workflow

It is not an Adjudication.

### 12.4 Gap hypotheses

A gap hypothesis records:

- expected or requested knowledge surface
- assessed coverage cells and queries
- what was not found or remained inaccessible
- whether the claim is absence, non-discovery, unsupported modality, or unresolved scope
- potential downstream consequence
- proposed next work

Empty result sets alone do not prove a gap.

## 13. Linked work

Knowledge Preflight may request declared linked runs for:

- broad Schema Context Selection
- Source Discovery
- Source Identity Resolution
- Research Seed Extraction
- ingestion planning or graph maintenance proposal

Graph-changing work always crosses into a separate governed ingestion or maintenance Workflow Run. Human approval is the default for mutation requests unless a later policy explicitly defines a narrow safe autonomous class.

Linked output is admitted through a Linked Run Result Admission Decision. A late nonblocking result cannot mutate a terminal preflight snapshot.

## 14. Outputs

### 14.1 Knowledge Preflight Snapshot

The immutable snapshot records:

- snapshot identity, purpose, and observation interval
- exact Run Input Manifest and KnowledgePreflightBrief
- Workflow Run and Effective Run Configuration
- Schema Definition, Catalog Build, Deployment Manifest, and Workspace Binding
- graph and relevant data-source version context
- Coverage Matrix and accepted revisions
- Query Plan and accepted revisions
- retrieval modalities and observations
- selected result identities and ranking evidence
- Graph Match Candidates
- existing-knowledge and prior-work findings
- contradiction candidates
- gap hypotheses
- unresolved identities and unassessed cells
- failures, truncation, degradation, and stopping rationale
- large result artifact references
- evaluation and Decision Report references

The snapshot references live graph records and captured result evidence; it is not a graph copy.

### 14.2 Freshness assessment

A separate purpose-bound Preflight Freshness Assessment evaluates whether a snapshot is current enough for a proposed downstream use.

It considers:

- observation age
- relevant graph data revision
- Schema Definition and deployment revision
- changed target scope or intended use
- newly available indexes or modalities
- downstream risk

An outdated snapshot remains valid historical evidence.

### 14.3 Decision Report

The Decision Report explains:

- query strategy and alternatives
- modality coverage
- selection and reranking decisions
- contradictions and gaps
- unresolved identities
- failures and inaccessible surfaces
- linked-work proposals
- stopping rationale
- quality limitations and Improvement Candidates

## 15. Completion and partial outcomes

The shared run outcomes apply:

- `completed`: required coverage obligations were sufficiently assessed
- `partially_completed`: required obligations were satisfied while degradable modalities or cells failed/stopped
- `failed`: at least one required obligation was not sufficiently assessed
- `cancelled`: authorized cancellation terminated the run

A structurally valid snapshot may exist for partial, failed, or cancelled execution when its scope, omissions, and stopping state are explicit.

Zero-match and zero-contradiction outputs are valid only when the applicable coverage and stopping requirements were sufficiently assessed.

## 16. Agent, MCP, and skill configuration

Likely Agent Profiles include:

- subject/intent normalizer
- schema-context selector
- query planner
- graph retrieval specialist
- prior-work retrieval specialist
- candidate aggregator
- contradiction analyst
- gap/coverage evaluator
- GoalDirected coordinator
- Decision Report author

The Schema Workspace supplies a versioned schema-navigation Agent Skill. A read-only schema MCP server may expose catalog search, cards, topology, expansion, and validation. It serves the same generated Schema Catalog and never invents a competing representation.

Graph and prior-work MCP servers are independently versioned, filtered, budgeted, and read-only. Operation bindings record exact tool exposure and schema snapshots.

## 17. Workspace and sandbox contract

Logical slots should support:

```text
inputs/
schema/
planning/
retrieval/<modality>/<branch>/cycles/<cycle>/
observations/
candidates/
coverage/
linked-results/
snapshot/
reports/
```

Schema and admitted inputs are read-only. Retrieval branches write only to exclusive locations. Shared candidate state is updated through typed persistence activities or single-writer consolidation.

Recommended snapshots:

- after Schema Workspace materialization for expensive catalog bundles when provider caching does not suffice
- on failed/blocked retrieval branches where reproduction is valuable
- each GoalDirected iteration when the search is expensive or long-running
- before risky local transformation of large result artifacts

Restores always clone and revalidate graph credentials, MCP connections, and leases.

## 18. Temporal mapping

Recommended first mapping:

- one top-level preflight Temporal Workflow per Workflow Run
- Schema Workspace setup as an idempotent activity
- substantial retrieval branches as child workflows when they require independent cycles/waits/cancellation
- bounded queries and agent runs as activities
- GoalDirected iterations orchestrated by the top-level workflow
- linked Workflow Runs represented by application Run Composition Links and child execution coordination
- Continue-As-New for long query/cycle/iteration history

Temporal workflow code receives compact references and deterministic state. Database queries, SDK execution, MCP calls, schema materialization, and snapshot persistence occur in activities.

## 19. Persistence ownership

PostgreSQL owns:

- run lifecycle, commands, links, budgets, transitions, and outbox events
- operator approvals and any Conversation/Thread bindings
- API/realtime projections

MongoDB/Beanie owns document-shaped preflight records:

- KnowledgePreflightBrief revisions
- Preflight Control Profile revisions
- Coverage Matrix and Query Plan revisions
- retrieval observation metadata
- normalized candidates and assessments
- Graph Match Candidates
- contradiction and gap records
- Knowledge Preflight Snapshot metadata
- freshness assessments
- evaluation and Decision Report metadata

Large raw result sets, captured query evidence, reports, schema catalog bundles, snapshots, and promoted files live in object storage.

Neo4j is read-only to this workflow.

## 20. API, commands, queries, and realtime events

Required commands include:

- start preflight
- revise allowed controls or coverage matrix
- approve continuation or additional budget
- pause/resume/cancel
- request or decide linked work
- admit/reject/defer linked results
- fork from a prior snapshot

Required queries include:

- run, stage, branch, cycle, and goal-iteration state
- schema compatibility and workspace binding
- coverage and query-plan state
- retrieval observations and candidate summaries
- contradictions, gaps, and unresolved identities
- linked-run and budget state
- snapshot, freshness, evaluation, and report versions

Socket.IO publishes authorized projection changes with durable cursors. Raw token and progress deltas may be ephemeral; observations, decisions, and final outputs are durable.

## 21. Evaluation seams

Evaluation must separately cover:

- strict schema definition/deployment matching
- workspace reproducibility and manifest correctness
- query schema validity and safety
- retrieval precision, recall proxies, and native-score preservation
- candidate aggregation and ambiguity preservation
- contradiction false-positive control
- gap and zero-result claim validity
- coverage-matrix accuracy
- stopping and convergence behavior
- snapshot completeness and lineage
- freshness assessment calibration

The highest practical test seam is a fixture containing known matches, aliases, contextual non-contradictions, a true missing coverage cell, prior-run records, and a deliberately mismatched Schema Deployment Manifest.

## 22. Remaining specification decisions

The workflow specification must still define:

- exact Pydantic/Beanie field schemas and indexes
- match-category, contradiction, gap, and coverage vocabularies
- graph-version marker and deployment-manifest production protocol
- exact retrieval adapters, index contracts, and query limits
- StageGraph cycle and GoalDirected iteration defaults
- candidate aggregation and reranking policies
- result-size thresholds and object-store promotion rules
- linked graph-maintenance Workflow Type mapping
- event payloads, retention, and evaluation thresholds

These decisions may tune retrieval behavior. They may not relax strict schema compatibility, permit hidden graph mutation, collapse identity uncertainty, or allow result counts to substitute for coverage.
