# System Workflow Execution and Control-Plane Synthesis

Date: 2026-07-18
OWNER: This folder BellLabs contains high-level vision but the architectural specifications for the system have been superseded.

Status: Accepted pre-specification synthesis

Related:

- [Starter Content Refinement synthesis](./2026-07-18-starter-content-refinement-workflow-synthesis.md)
- [Knowledge Preflight synthesis](./2026-07-18-knowledge-preflight-workflow-synthesis.md)
- [System control-plane proposal](../system-control-plane-and-workflow-execution-configuration.md)
- [Pre-research architecture checkpoint](../checkpoints/system-level/2026-07-18-pre-research-architecture-synthesis-and-grill-entry-checkpoint.md)
- [Workflow, agent, sandbox, and system-state checkpoint](../checkpoints/system-level/2026-07-15-workflow-catalog-agent-sandbox-and-system-state-special-checkpoint.md)
- [Schema workspace checkpoint](../checkpoints/schema_schema_workspaces_efficient_db_interaction/2026-07-16-large-schema-workspaces-selection-and-report-splitting-special-checkpoint.md)
- [Durable agentic catalogs proposal](../research/2026-07-18-prompt-skill-mcp-durable-catalogs-proposal.md)

## 1. Purpose and authority

This document closes the system-level architecture needed to specify and implement the server and workflow foundations beneath `StarterContentRefinementWorkflow` and `KnowledgePreflightWorkflow`.

It deliberately does not specify the dashboard. It defines the command, query, event, conversation, and realtime contracts that a later dashboard may consume.

Where this synthesis conflicts with the earlier control-plane proposal, this synthesis governs for the next specification phase. In particular, it resolves:

- two top-level workflow blueprint families rather than a flat list of unrelated modes
- governed goal evolution
- canonical Conversations and Conversation Threads
- immutable clone-on-restore Sandbox Snapshots
- reusable Schema Catalog builds and composable Schema Workspace materialization
- PostgreSQL versus MongoDB authority
- the FastAPI process boundary and Socket.IO contract
- OpenAI Agents SDK handoff, task-subagent, sandbox, streaming, hook, and Temporal-integration boundaries
- separate prompt, Agent Skill, MCP server, and plugin/package catalogs
- governed cross-thread workflow memory with useful retrieval, consolidation, and injection
- dynamic Agent Skill and MCP discovery without runtime supply-chain authority
- independent linked-run configuration compilation

## 2. Architectural rule

The system separates authored definitions, compiled execution configuration, durable orchestration, side effects, and domain authority:

```text
versioned definitions + authorized overlays
-> pure configuration compilation
-> immutable Effective Run Configuration
-> accepted Run Request and Workflow Run
-> Temporal orchestration
-> idempotent activities and runtime adapters
-> typed domain decisions, artifacts, events, and projections
```

No prompt, Agent Skill, MCP server, MCP tool, plugin, agent, memory item, retrieved context, Temporal history, SDK session, sandbox filesystem, or socket connection becomes domain authority by existing.

## 3. Core composition model

### 3.1 Workflow Type and blueprint

A `WorkflowTypeRevision` owns:

- purpose and non-goals
- Input Admission Contract
- Workflow Invariants
- obligation vocabulary and output contracts
- allowed application-owned execution blueprint revisions
- operation and linked-workflow boundaries
- authority and evaluation requirements
- workspace and artifact-promotion contract

A `WorkflowExecutionBlueprintRevision` owns one top-level blueprint family and its application-defined topology. A Workflow Type may publish more than one allowed blueprint revision, but a Workflow Run binds exactly one at launch.

A control profile may select only a blueprint revision already allowed by the Workflow Type revision. It cannot invent topology or switch a running Workflow Run between blueprint families.

### 3.2 Configuration layers

The configuration compiler resolves:

1. `WorkflowTypeRevision`
2. selected `WorkflowExecutionBlueprintRevision`
3. `WorkflowControlProfileRevision`
4. workflow-specific typed configuration
5. `WorkspaceTemplateRevision` and Workflow Workspace Contract
6. `RuntimeProfileRevision`
7. `EvaluationProfileRevision`
8. `MemoryPolicyRevision`
9. Agent Profiles, `CapabilitySelectionPolicyRevision`, and exact agentic assets
10. caller authority, permissions, environment availability, and parent delegation ceilings
11. immutable Run Input Manifest
12. validated run overlay
13. linked-run slots and their dependency, authority, budget, and result-admission policies

The output is an immutable `EffectiveRunConfiguration` with canonical serialization, digest, compiler version, source revision references, accepted and rejected overlay decisions, and all exact runtime bindings needed without rereading mutable aliases.

### 3.3 Linked-run configuration

The parent Effective Run Configuration freezes:

- allowed linked Workflow Types and request slots
- request identity and revision rules
- dependency classes
- parent-side wait, timeout, cancellation, and result-admission behavior
- delegated authority ceiling
- budget reservation ceiling
- allowed child profile or revision policies

It does not embed the full effective configuration of every possible child.

Each accepted child Run Request independently compiles its own Effective Run Configuration from exact child definitions while applying the frozen parent constraints. The resulting child snapshot records the parent Run Composition Link and all governing intersections.

## 4. Workflow execution blueprint families

The system supports exactly two top-level blueprint families in the first architecture.

### 4.1 StageGraph blueprint

`StageGraphBlueprint` represents an application-owned directed acyclic dependency graph.

It declares:

- stages and dependency edges
- required, degradable, optional, and advisory dependencies
- branch and join semantics
- readiness ordering and fairness
- stage and operation concurrency
- typed completion and skip behavior
- per-stage retry and timeout policy
- optional per-stage semantic cycle policies
- optional whole-workflow cycle policy
- linked-run request slots

Dependency edges remain acyclic. Semantic cycles wrap a stage or the completed graph; they are never represented by a graph edge back to an ancestor.

#### Stage cycles

A stage cycle is new semantic work:

```text
hydrate admitted inputs
-> execute operations
-> promote candidate artifacts
-> evaluate obligations and gates
-> stop | repair | continue with a new cycle objective
```

Each cycle receives its own objective, operation bindings, workspace namespace, artifacts, evaluation, budget reservation, and handoff state.

#### Whole-workflow cycles

A whole-workflow evaluator emits a typed decision containing:

- failed obligations and evidence
- affected stages and artifacts
- invalidation frontier
- next-cycle objective
- proposed control or obligation revision
- required budget
- continue, degrade, stop, fork, or escalate recommendation

The orchestrator reruns the minimal affected subgraph and reuses unaffected immutable outputs by reference. A workflow cycle is distinct from Temporal Continue-As-New, although the two may align for history management.

### 4.2 GoalDirected blueprint

`GoalDirectedBlueprint` represents iterative agentic work whose useful next step cannot be fully expressed as a predetermined stage graph.

It declares:

- initial goal and fixed objective envelope
- acceptance contract and independent verifier
- allowed operation classes and linked-run slots
- iteration state and handoff policy
- continuing-session or fresh-from-handoff behavior
- iteration, no-progress, and repeated-blocker limits
- multidimensional budget
- snapshot and rollback policy
- goal-evolution policy

An agent completion claim is only a proposal to the verifier.

### 4.3 Governed goal evolution

Goal evolution creates an immutable `GoalRevision`.

A revision may refine tactics, subgoals, ordering, coverage emphasis, or the next iteration target only inside the launch-bound:

- objective
- acceptance contract
- Workflow Invariants
- admitted inputs
- capability and delegation authority
- budget and operation envelope
- prohibited work

Each revision records parent goal revision, evidence, unmet obligations, author, deciding authority, and applicability.

A revision that broadens the objective, changes admitted inputs, weakens acceptance, adds undeclared work, or exceeds authority requires an allowed Run Control Revision, a fork, or a linked/new Workflow Run. Agents cannot authorize that expansion through goal text.

### 4.4 Counters that must remain distinct

The runtime records at least:

- `temporal_activity_attempt`: infrastructure retry of the same side effect
- `operation_attempt`: new semantic attempt with a new binding
- `stage_cycle`: new work after stage evaluation
- `workflow_cycle`: affected-subgraph work after whole-workflow evaluation
- `goal_iteration`: one GoalDirected iteration
- `goal_revision`: accepted change to the active bounded goal

Retries reuse semantic identity and idempotency keys where appropriate. New semantic work does not masquerade as a retry.

## 5. Agentic configuration and runtime

### 5.1 Separate versioned asset families

The system maintains separate versioned families for:

- `PromptDefinitionRevision`
- `AgentSkillDefinitionRevision`
- `MCPServerDefinitionRevision`
- `AgentProfileRevision`
- `PluginPackageRevision`
- `PluginInstallation`

An Agent Skill is a folder with `SKILL.md` and optional scripts, references, and assets. An MCP server is a separately governed connection and tool-exposure definition. A plugin/package may distribute skills, MCP definitions, hooks, apps/connectors, executables, and assets, but package inclusion grants no component authority.

Workflows, stages, and operations may bind managed assets directly or obtain them from an exact plugin package. In both cases, the compiler resolves exact versions, content digests, availability, compatibility, and independent capability grants.

An authored Workflow Type, blueprint stage, operation, Agent Profile, or authorized overlay may declare a `CapabilityRequirement` as:

- an exact internal asset and revision
- a stable logical name or alias to resolve from the internal catalog
- a governed search query with asset kind, source hints, required capabilities, compatibility, and trust constraints
- `required`, `degradable`, `optional`, or `advisory`
- an attachment target, such as agent instructions, sandbox Skill mount, MCP connection, or allowed MCP tool set
- explicit missing, ambiguity, substitution, and fallback behavior

An explicit requirement has precedence over model-proposed discovery. It remains subject to Workflow Type authority, capability policy, permissions, and promotion state; naming a public asset cannot grant or install it.

### 5.2 Agent Profile

An Agent Profile covers:

- role and instruction references
- dynamic-instruction policy
- model, effort, fallback, and context policy
- tools and tool-choice policy
- MCP servers and tool filters
- Agent Skills and load policy
- memory read, write-proposal, retrieval, injection, and materialization policy
- governed dynamic capability-selection policy
- handoff and task-subagent policy
- guardrails
- hooks and middleware
- structured output contract
- session/history policy
- tracing and sensitive-data policy
- workspace requirements

An `OperationExecutionBinding` records what was actually used, including exact prompt, skill, MCP, plugin, model, tool, workspace, authority, and effective-configuration revisions.

### 5.3 Delegation modes

The domain exposes two operation-local `AgentDelegation` modes:

- `handoff`: transfer active turn ownership to another validated agent
- `task_subagent`: run a bounded specialist task and return its result to the delegating agent

Both:

- remain inside the governing operation
- receive child workspace namespaces
- inherit only explicit read mounts
- are capped by the Delegation Ceiling, operation budget, and concurrency policy
- preserve exact Dynamic Agent Definition or Agent Profile bindings
- emit typed delegation events and results

Work with an independent lifecycle, reusable output, different authority, substantial budget, or a recognized Workflow Type boundary uses `request_workflow_run`, not hidden SDK delegation.

### 5.4 OpenAI Agents SDK adapter

`OpenAIAgentsRuntimeAdapter` maps resolved domain configuration to current SDK primitives:

- Agent definitions and dynamic instructions
- handoffs and agents-as-tools
- sessions and input-history shaping
- `Runner` execution and streaming
- run and agent lifecycle hooks
- tool approvals and serializable run state
- sandbox-agent/workspace APIs where selected
- sandbox memory and compaction capabilities where selected
- MCP connections and filters
- structured outputs, guardrails, and tracing

SDK events are translated into project event envelopes. SDK sessions are runtime context projections, not canonical Conversations or Workflow Run state. SDK hooks observe or request typed application actions; they do not mutate domain stores directly.

The SDK's Temporal durable-execution integration and Temporal sandbox-agent extension may be used inside the adapter for an operation that benefits from resumable agent-loop mechanics. They do not replace the application-owned Workflow Type blueprint, lifecycle reducer, Run Composition Links, domain events, or top-level Temporal orchestration. The adapter must make this boundary explicit and reject nested durable scheduling that would create a hidden workflow engine.

### 5.5 Dynamic capability discovery and selection

Public registries are discovery sources, not runtime authorities. The system may ingest from the official MCP Registry, Smithery, approved Git repositories, and operator-driven tools such as `npx skills find`, but production operations select only from the governed internal catalog.

Ingestion follows:

```text
source adapter
-> immutable raw snapshot and provenance
-> normalization
-> quarantine and static inspection
-> isolated MCP handshake/tools-list or Skill bundle evaluation
-> evaluation and policy decision
-> human or authorized CI promotion
-> searchable active internal catalog
```

MCP tool inventory comes from an isolated protocol probe, not registry description alone. Each `MCPToolDefinitionRevision` belongs to an exact `MCPServerDefinitionRevision` and records tool name, description, input and output schemas, annotations, schema digest, observation time, and probe binding. Skill revisions record the complete file manifest, Git commit or source revision, content-addressed bundle digest, declared requirements, and inspection results.

Search combines exact and keyword matching, PostgreSQL full-text search, vector similarity, and structured filters. Selection applies hard gates before ranking:

- Workflow Type and operation allowlists
- caller and Delegation Ceiling authority
- approved source and promotion status
- exact immutable revision and content digest
- compatibility, license, freshness, health, and evaluation thresholds
- network, secret, filesystem, data-classification, and approval requirements

Only the surviving bounded set may be presented to a model. A selection creates an immutable `CapabilitySelectionDecision`; actual use is frozen in the `OperationExecutionBinding`. External discovery never installs or connects a capability inside a production operation.

Resolution is intentionally easy for workflow authors while remaining strict at execution:

```text
explicit capability requirement
-> exact internal lookup and alias resolution
-> internal full-text/vector/keyword search
-> optional registry, `npx skills`, or direct-source lookup through source adapters
-> ingestion, snapshot, inspection, evaluation, and promotion when not already managed
-> exact revision resolution
-> Skill materialization and/or MCP connection with tool filters
-> Effective Run Configuration and Operation Execution Binding
```

Registry lookup may occur during authoring, publication, deployment preparation, or an explicitly allowed preflight—not as an unreviewed production-operation side effect. Publication validates every required requirement to exactly one usable revision. Run admission fails, degrades, or omits the capability according to the authored requirement class; it never silently substitutes a similarly named asset.

## 6. Conversations, memory, and sandboxed agents

### 6.1 Canonical model

A `Conversation` is a durable container for related human, coordinator, and sandbox-agent interaction.

A `ConversationThread` is a forkable ordered sequence within a Conversation. It may bind:

- participants
- coordinator or sandboxed agent identities
- optional Workflow Run, stage, cycle, operation, or sandbox scope
- parent thread and fork point
- context-selection policy

Messages, tool interactions, stream summaries, approvals, and references are preserved. A message is context and audit evidence, not execution authority.

### 6.2 Promotion into executable meaning

Conversation content affects execution only after project application services promote it into a typed record, such as:

- Intake Brief revision
- Run Request
- Workflow Lifecycle Command
- approval or rejection decision
- Run Control Revision
- Goal Revision
- Continuation Proposal decision
- linked-run request

The promoted record references exact supporting turns.

### 6.3 SDK session relationship

An OpenAI Agents SDK session contains a selected, model-facing projection of thread history. It may be compacted, filtered, or restarted without rewriting the canonical thread.

One thread may produce several SDK sessions across handoffs, fresh iterations, restored sandboxes, or model changes. One SDK session does not silently join unrelated threads.

### 6.4 Durable workflow and mission memory

SDK session history and compaction provide bounded thread continuity. Durable cross-thread memory is a separate application-owned subsystem whose purpose is to make later work more effective without creating an unreviewed source of truth.

Memory uses three kinds and two orthogonal planes:

- `episodic`: prior work, decisions, outcomes, failures, evaluations, and their run/artifact references
- `semantic`: reusable claims and concepts with evidence, confidence, temporal validity, and contradiction state
- `procedural`: learned methods and preferences; stable high-impact procedures are promoted into reviewed Prompts, Agent Skills, `AGENTS.md`, or policy revisions
- `operational`: execution, reliability, tooling, process, and control-plane knowledge
- `domain`: scientific and product knowledge, which remains subordinate to approved artifacts and canonical Neo4j knowledge

Every `MemoryItem` belongs to a tenant and typed `MemorySpace` with a hierarchical scope such as system, product, Workflow Type, mission, Workflow Run, stage, thread, organization, or user. It records kind, plane, namespace, content, keywords, provenance and derivation links, producer bindings, confidence, review state, sensitivity, retention class, valid time, system time, supersession, and tombstone state. Operational observations cannot become domain claims without a governed consolidation and review decision.

#### Memory Policy

A versioned `MemoryPolicyRevision` declares:

- readable and writable scopes, namespaces, kinds, and planes
- inheritance and precedence across thread, mission, Workflow Type, tenant, and global procedure scopes
- consistency mode: run snapshot, stage snapshot, or latest-at-operation
- structured filters, hybrid-retrieval weights, reranking, deduplication, token budget, and maximum items
- write-proposal, consolidation, contradiction, review, sensitivity, retention, and deletion rules
- mission-memory-pack and workspace materialization rules
- evaluation thresholds for retrieval usefulness, provenance, isolation, staleness, and downstream task improvement

The Effective Run Configuration freezes the policy and permitted memory envelope. Each retrieval stores the query, policy revision, candidate IDs and scores, selected item revisions, exclusions, and exact injected representation so execution remains auditable even when the corpus later changes.

#### Memory manager processes

Application-owned memory manager processes perform retrieval, utility filtering, consolidation, and write review through typed services. Agent instructions may guide those processes, but instructions cannot bypass policy.

The manager:

1. filters by tenant, authorization, scope, namespace, validity, sensitivity, and policy before ranking
2. retrieves lexical, exact-identifier, and vector candidates and fuses them
3. rejects stale, redundant, contradictory, weakly sourced, or low-utility candidates
4. injects only the smallest provenance-bearing set expected to improve the current operation
5. accepts agent output only as a `MemoryWriteProposal`
6. preserves source episodes while deriving candidate semantic claims or procedural lessons
7. requires review for procedural changes and high-impact domain claims

Memory effectiveness is evaluated, not inferred from volume. Required measures include exact-identifier and relevant-memory retrieval, provenance correctness, unauthorized cross-scope leakage, stale-memory resistance, write/consolidation precision, context cost, and downstream workflow success. Unused or harmful memory is suppressed, revised, expired, or tombstoned according to policy.

#### Mission memory materialization

At operation preparation, the system may create an immutable, read-only `MissionMemoryPackRevision` containing a generated `AGENTS.md`, selected memory files, and a machine-readable manifest of item revisions, sources, scopes, and digests. `AGENTS.md` contains bounded operating guidance and navigation, not a writable memory database. Agents submit write proposals; a later reviewed materialization produces a new pack revision. Snapshot restore rebinds the exact pack or an explicitly authorized successor.

## 7. Sandbox workspaces and snapshots

### 7.1 Workspace isolation

A Run Workspace Namespace may contain multiple Sandbox Workspaces for stages, artifact branches, goal iterations, evaluators, agents, and subagents.

Shared inputs are read-only. Every writable location has one declared owner. Cross-branch exchange uses promoted artifacts or typed messages, not uncontrolled shared paths.

The Workspace Materialization Manifest maps governed paths to durable inputs, generated candidates, promoted artifacts, schema resources, and lineage.

When configured, it also maps an exact read-only `MissionMemoryPackRevision`. Writable agent notes remain workspace-local candidates until explicitly proposed and accepted as memory or promoted as artifacts.

### 7.2 Snapshot semantics

A `SandboxSnapshot` is immutable resumable execution state with:

- parent workspace and optional parent snapshot
- provider and snapshot identity
- filesystem/content manifest and digest
- runtime, image, package, and environment digests
- creation reason and producer binding
- captured capability shape without secret values
- retention and deletion policy

Restoring a snapshot always creates a new Sandbox Workspace instance with explicit parent lineage. It never mutates or resumes the old workspace in place.

Secrets, expiring credentials, live MCP connections, sockets, and external leases are not restored as authority. They are re-resolved and revalidated for the new operation.

A snapshot is not a domain artifact, Starter Package, Workflow Run record, SDK session, or graph version. Outputs become durable only through artifact promotion.

## 8. Composable Schema Workspace materialization

`SchemaWorkspaceMaterialization` is a shared system operation available at Workflow Run or stage scope.

It:

1. accepts an exact `SchemaCatalogBuildRef`
2. validates source Schema Definition version and content hash
3. validates a `SchemaDeploymentManifest` when live graph access is requested
4. selects the required catalog modules, indexes, cards, navigation skill, and operation projections
5. materializes them read-only into a declared workspace slot
6. writes a Workspace Materialization Manifest section
7. emits a `SchemaWorkspaceBinding`

The operation is idempotent for the same catalog digest, materialization policy, and workspace slot identity.

Schema Catalog generation is a reusable deterministic build, not repeated by every workflow run. Workflow-specific selection and expanded slices remain separately versioned inputs or outputs.

For the current Neo4j deployment, strict compatibility is required: a graph-reading workflow must bind a `SchemaDeploymentManifest` whose deployed SDL hash equals the Schema Definition hash behind the selected catalog. Neo4j introspection cannot prove directive-SDL equality and is diagnostic only. A missing or mismatched manifest fails admission before graph work.

## 9. Persistence and authority

The system uses a deliberate polyglot split. No record family has two authoritative writers.

### 9.1 PostgreSQL

PostgreSQL is the transactional application authority for:

- Workflow Run current lifecycle projection and optimistic version
- lifecycle transition records
- command idempotency and accepted command results
- Run Composition Links and parent-side dependency decisions
- authoritative budget accounts, reservations, and ledger entries
- Run Control Revision acceptance and current effective-config pointer
- Conversations, Threads, Messages, participants, and turn ordering
- Memory Spaces, Memory Policy revisions, Memory Items, provenance, links, write proposals, retrievals, injections, consolidation decisions, and Mission Memory Pack metadata
- Agent Profile, Prompt, Agent Skill, MCP server, MCP tool, plugin/package, label, availability, evaluation, and capability-selection catalogs
- immutable catalog source snapshots, sync cursors, promotion decisions, and searchable catalog projections
- approvals and operator interventions
- transactional outbox and consumer inbox/cursors
- API and realtime subscription read models

PostgreSQL enables `pgvector`, generated `tsvector` columns with GIN indexes, exact/trigram identifier indexes where required, and HNSW vector indexes using the operator class matching the selected distance metric. Hybrid retrieval fuses separately ranked lexical and semantic candidates, while tenant, authorization, namespace, validity, status, and sensitivity filters execute inside the query. Row-level security is mandatory defense in depth.

Memory uses constrained relational families equivalent to `memory_spaces`, `memory_policy_revisions`, `memory_items`, `memory_item_sources`, `memory_links`, `memory_embeddings`, `memory_write_proposals`, `memory_retrievals`, `memory_injections`, `memory_consolidation_runs`, and `mission_memory_pack_revisions`.

Agentic catalog storage uses constrained families equivalent to `catalog_sources`, `catalog_sync_runs`, `agentic_assets`, `agent_skill_revisions`, `agent_skill_files`, `mcp_server_revisions`, `mcp_tool_revisions`, `asset_embeddings`, `asset_evaluations`, and `capability_selection_decisions`. Exact names remain a specification concern; the authority split and relationships do not.

State transition, current projection, command result, and outbox event commit in one transaction.

### 9.2 MongoDB through Beanie

MongoDB/Beanie is authoritative for versioned and document-shaped records whose lifecycle does not require the PostgreSQL run-transition transaction:

- Workflow Type, blueprint, control-profile, runtime-profile, workspace-template, and evaluation-profile revisions
- their mutable authoring heads and immutable published revisions
- immutable Effective Run Configuration payloads and compiler decisions
- Operation Execution Bindings and detailed agent/delegation execution records
- workflow-specific briefs, plans, findings, query plans, result envelopes, evaluations, and immutable output metadata
- schema catalog/build metadata, selections, expanded slices, operation projections, and workspace bindings
- sandbox snapshot metadata

Beanie models use explicit collection families rather than deep inheritance for unrelated lifecycles. Immutable revisions use stable logical identity plus revision and digest. Beanie optimistic revision support is reserved for mutable heads and projections, not used as immutable identity.

Cross-store operations use stable IDs, deterministic idempotency keys, PostgreSQL outbox events, and Temporal sagas. A Mongo write never independently advances Workflow Run lifecycle.

### 9.3 Temporal

Temporal owns durable execution history, timers, waits, retries, child execution boundaries, Signals, Updates, Queries, cancellation, and Continue-As-New epochs.

Temporal history is not the inter-service domain event log and is not queried as the application database.

### 9.4 Object storage and Neo4j

Object storage owns large immutable payloads, documents, media, reports, content-addressed Skill bundles, raw catalog snapshots, Mission Memory Pack files, schema build bundles, sandbox snapshots, and promoted files. Where regulatory immutability requires WORM behavior, the selected object-store retention mode must provide it.

Neo4j owns approved canonical graph knowledge. Only governed ingestion planning and execution may mutate it.

## 10. Temporal execution architecture

### 10.1 Start path

1. FastAPI receives a typed Run Request.
2. PostgreSQL application services validate caller authority and request idempotency.
3. Configuration services load exact Mongo workflow-definition revisions and PostgreSQL memory-policy and agentic-catalog revisions.
4. The pure compiler emits and stores the immutable Effective Run Configuration and digest.
5. PostgreSQL transaction creates the Workflow Run projection, command result, and outbox event.
6. A relay starts Temporal using stable Workflow ID, run ID, input-manifest reference, effective-config reference, and digest.
7. Temporal verifies the binding before substantive work.

### 10.2 Workflow code

Temporal Workflow code performs deterministic orchestration:

- dependency and runnable-work calculation
- stage/cycle/iteration state
- waits, timers, child workflows, and activities
- application of already accepted control revisions
- compact query state
- Continue-As-New

It does not query MongoDB, PostgreSQL, Neo4j, secret stores, or external services directly.

### 10.3 Activities and child workflows

Activities perform nondeterministic work through adapters:

- database and object-store I/O
- sandbox provisioning and snapshots
- schema workspace materialization
- prompt and skill materialization
- mission memory retrieval, utility filtering, pack materialization, write proposals, and consolidation
- catalog synchronization, quarantined inspection, isolated capability probing, promotion, and selection
- MCP connection and health checks
- OpenAI Agents SDK runs
- evaluation
- artifact promotion
- projection/event persistence

A Temporal Child Workflow is appropriate for a linked Workflow Run or a unit with independent waits, cancellation, cycles, history, or Continue-As-New needs. A bounded model/tool/agent invocation remains an Activity even if the SDK internally performs several turns.

## 11. FastAPI and Socket.IO server

### 11.1 Process boundary

FastAPI is a gateway and application-service process. Its lifespan owns initialization and clean shutdown of:

- PostgreSQL pool and repositories
- Mongo client and Beanie models
- Temporal client, not Temporal workers
- object-storage client
- authentication and authorization services
- configuration compiler dependencies
- Socket.IO ASGI integration
- health and readiness checks

Temporal workers, outbox relays, event projectors, sandbox/agent executors, and broker consumers run as separately deployable processes. Development composition may start them together, but they remain separate process roles.

### 11.2 Command and query APIs

HTTP APIs expose:

- typed commands with idempotency keys and expected aggregate versions
- queries over durable application projections
- conversation and thread creation/forking
- accepted message submission
- run request, approval, revision, cancellation, pause, and resume commands
- artifact and configuration reads under authorization
- authorized memory search, proposal, review, retrieval-audit, and pack reads
- catalog search, evaluation, promotion, and exact-revision resolution

Agents receive these capabilities through project-owned function tools or MCP tools that call the same application services.

### 11.3 Realtime contract

Socket.IO provides authorized channels for:

- Workflow Run and stage projection changes
- conversation/thread messages
- agent, handoff, and task-subagent activity
- tool/MCP progress
- memory retrieval, proposal, consolidation, and materialization state
- catalog ingestion, evaluation, and promotion state
- sandbox/workspace state
- approvals and interventions
- budget and continuation state
- artifact and evaluation availability

Every envelope carries event type/version, channel/subject, correlation, aggregate version or durable cursor, occurrence time, and an authorization-filtered payload or durable reference.

Accepted conversation messages and final agent/tool outputs are durable before acknowledgement. Token deltas and fine-grained progress may be ephemeral.

Socket delivery is never the correctness mechanism. Reconnecting clients query current projections and resume from durable cursors. Socket.IO acknowledgements confirm transport/application acceptance but do not replace domain command results.

## 12. Events, lifecycle, and consistency

The application-owned lifecycle reducer validates commands against:

- current PostgreSQL run version
- bound blueprint and invariants
- actor authority
- accepted configuration revision
- dependency and budget state

Accepted transitions append a lifecycle record and outbox event atomically.

Domain events are versioned, at-least-once, and idempotently consumed. Ordering is guaranteed only within the declared aggregate/version relationship. The event envelope remains transport-neutral so a durable broker may be added without changing domain contracts.

## 13. Security invariants

1. Prompt text, conversation content, retrieved memory, skill files, MCP descriptions, registry metadata, and plugin manifests cannot grant capability.
2. A handoff or task subagent cannot exceed the parent Delegation Ceiling.
3. A linked run receives the intersection of child contract, parent ceiling, caller authority, permissions, and approved overlays.
4. Secrets are references in configuration and are resolved just in time.
5. Untrusted starter or graph content cannot redefine topology, authority, budgets, or completion.
6. Every writer has an exclusive declared workspace slot.
7. Published definitions, effective configurations, bindings, snapshots, outputs, and accepted decisions are immutable.
8. Live revisions affect only declared future or invalidated work.
9. SDK, sandbox, MCP, and plugin capabilities remain behind project adapters.
10. Graph mutation occurs only through governed ingestion workflows.
11. External registry results remain quarantined until snapshotted, inspected, evaluated, and promoted.
12. Models may choose only from a policy-bounded candidate set and cannot install arbitrary Skills or connect arbitrary MCP servers.
13. Memory retrieval and writes enforce tenant and scope isolation through application authorization and PostgreSQL row-level security.
14. Memory is context, not authority; semantic and procedural promotion requires provenance and the configured review decision.
15. MCP probes and Skill evaluation execute in disposable, least-privilege sandboxes with SSRF-resistant egress and synthetic or scoped credentials.

## 14. Required model families

The specification phase should define strict, versioned Pydantic contracts with PostgreSQL or Beanie persistence according to Section 9 for:

- Workflow Type and Workflow Execution Blueprint revisions
- StageGraph and GoalDirected discriminated configuration
- stage cycle, workflow cycle, goal iteration, and Goal Revision policies
- Workflow Control, Runtime, Workspace Template, and Evaluation profiles
- agentic asset catalogs and exact asset bindings
- MCP Tool revisions, catalog source snapshots, evaluations, and Capability Selection Decisions
- Capability Requirements, aliases, resolution results, attachment plans, and failure decisions
- Memory Policy revisions, Memory Spaces and Items, provenance, write proposals, retrievals, injections, consolidation decisions, and Mission Memory Pack revisions
- Agent Delegation and Dynamic Agent Definition
- Effective Run Configuration and compiler decisions
- Operation Execution Binding and execution detail
- Schema Catalog Build, Deployment Manifest, Workspace Binding, and compatibility result
- sandbox snapshot metadata
- workflow-specific document records named in the companion syntheses

Executable configuration forbids unvalidated `dict[str, Any]`. Extensions require a namespaced discriminator and registered validator.

## 15. First implementation slice

The first server/workflow tracer bullet should prove:

1. separate FastAPI gateway and Temporal worker processes
2. PostgreSQL command/lifecycle/outbox transaction
3. Mongo/Beanie workflow definitions and Effective Run Configuration plus PostgreSQL memory and agentic-catalog revisions
4. pure compilation for one StageGraph blueprint and one GoalDirected blueprint fixture
5. one OpenAI Agents runtime adapter operation
6. one sandbox materialization, snapshot, clone restore, and artifact promotion path
7. schema catalog reference plus reusable Schema Workspace materialization
8. one Conversation Thread bound to a sandbox agent with durable messages and ephemeral token streaming
9. one mission-scoped hybrid memory retrieval, audited injection, write proposal, and read-only memory-pack materialization
10. one quarantined Skill and MCP source import, isolated tool probe, promotion, hybrid catalog search, and exact capability-selection binding
11. Socket.IO projection hints with durable reconnect
12. one linked child run with independently compiled configuration

The dashboard UI is explicitly excluded.

## 16. Decisions deferred to workflow specifications or implementation planning

The following do not reopen this architecture:

- exact PostgreSQL table and Mongo collection names, subject to the authoritative record families in Section 9
- exact event payload schemas and retention periods
- durable broker selection
- sandbox provider selection and default retention duration
- exact model choices and agent prompts
- exact MCP tool schemas
- embedding models, dimensions, hybrid-search weights, and index tuning
- workflow-specific memory namespaces, retention durations, review thresholds, and token budgets
- deployment topology and worker scaling
- workflow-specific stages, obligations, gates, budgets, and evaluation thresholds
- which published definitions agents may draft versus humans must publish

Specifications must not defer any behavior that would let an implementation agent invent workflow authority, completion, admission, mutation, or output semantics.
