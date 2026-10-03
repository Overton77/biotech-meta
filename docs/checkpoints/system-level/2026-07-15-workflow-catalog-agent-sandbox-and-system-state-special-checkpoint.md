# Special Checkpoint: Workflow Catalog, Agent Runtime, Sandboxes, and Current System State

Date: 2026-07-15

Status: Consolidated architecture checkpoint; accepted decisions and unresolved boundaries are labeled explicitly

## Why This Checkpoint Exists

This document pauses the detailed grilling session and explains the whole system as it currently stands.

It consolidates:

- the north-star knowledge-production lifecycle
- every Workflow Type discussed in the active design
- older workflow names that must not be mistaken for current commitments
- the detailed contracts already accepted
- the current OpenAI Agents SDK and Temporal mapping
- system-wide agent configuration and dynamic-agent authorship
- sandbox, workspace, filesystem, and artifact-storage semantics
- the unresolved relationship among subagents, workflow tools, and linked Workflow Runs
- the next architecture decisions

The system is still in specification. No runtime design should be treated as complete merely because a framework can implement part of it.

## Current Position

The architecture has moved beyond the original “research pipeline” framing.

The top-level composition is now a **Knowledge Production Mission**, not a Research Mission. It may coordinate intake, refinement, preflight, source work, deep research, schema selection, ingestion, evaluation, curated content, media, and interactive experiences.

The reference lifecycle is:

```text
Starter Content and Discussion
-> Starter Package with Pre-Research and Knowledge Preflight
-> Optional Source Discovery
-> Mode-Specific Deep Research
-> Schema Workspace and Schema Selection
-> Report-Grounded Knowledge Comparison <BELLLABS OWNER>: Does this mean report-grounded database retrieval ? Or a more general retrieval + comparison. We will definitely need report related stages (verification, source attribution, refinement etc) </BELLALBS OWNER>
-> Ingestion Planning
-> Ingestion
-> Agent and Information-Retrieval Evaluation <BELLLABS OWNER>: Agent here refers to agent configuration and lifecycle but also to workflow optimization. We also want a Fine-Tuning workflow type. I think that is separate from these evaluations  </BELLLABS OWNER>
-> Curated Content and Media
-> MCP UI and Generative UI Components

<BELLLABS OWNER> FINE TUNING DATASET GENERATION , FINE TUNING JOBS </BELLLABS OWNER>
```

This remains a reference composition rather than a rigid pipeline.

- A mission may enter and exit at any admissible workflow boundary.
- A Workflow Run may execute independently without a mission.
- Existing reports, graph data, packages, content, or evaluations may be used directly when the invoked Workflow Type accepts them.
- No universal Starter Package wrapper is required.
- Crossing a Workflow Type boundary creates a distinct first-class Workflow Run.

## Core Composition Model

### Knowledge Production Mission

A Knowledge Production Mission is a bounded objective that coordinates linked Workflow Runs.

Every mission has:

- an accepted, versioned Mission Specification
- a versioned Mission Plan
- entry inputs and intended outcomes
- linked Workflow Runs
- approval and policy gates
- budgets and control revisions
- artifacts, findings, evaluations, and lineage

A mission may reference prior standalone runs or outputs without re-parenting those historical runs.

### Mission Specification

The Mission Specification is the execution-ready objective and success contract. It is distinct from:

- the preserved Conversation Thread
- the accepted Intake Brief
- the advisory Mission Direction Proposal
- the Mission Plan

Specification revisions create new versions and a Specification Impact Assessment. Completed Workflow Runs remain bound to their historical specification version. Active runs may continue, receive an intervention, stop, or fork depending on assessed impact.

### Workflow Type

A Workflow Type defines a reusable contract:

- accepted input variants
- Input Admission Contract
- Workflow Invariants
- control configuration
- execution skeleton and completion rules
- required and degradable Processing Obligations
- workspace contract
- agent and capability policies
- outputs and artifact lineage
- Decision Report expectations
- evaluation obligations
- event and intervention semantics

### Workflow Run

A Workflow Run is one execution of a Workflow Type.

Its standalone or mission-owned execution scope is fixed at creation. It preserves:

- the accepted Run Request
- immutable Run Input Manifest
- selected control-profile version
- validated overrides
- fully resolved effective configuration
- later Run Control Revisions
- bound Mission Specification version when mission-owned
- operation, agent, sandbox, workspace, tool, and model bindings
- events, decisions, outputs, findings, and evaluation

Run outcome is separate from output readiness:

- `completed`
- `partially_completed`
- `failed`

### Run Request and Composition

Humans, dashboard actions, API clients, services, coordinators, and workflow agents do not create execution state directly.

They submit typed Run Requests. The control plane validates:

- caller identity
- delegated authority
- input admission
- invariants
- policy gates
- permission capabilities
- budgets
- execution capabilities
- required approvals

When one Workflow Run requests another Workflow Type, the result is a separate linked Workflow Run connected by a Run Composition Link.

## Conversation-to-Execution Model

The coordinator conversation and workflow execution are separate planes.

```text
Conversation Turn
-> Coordinator Reasoning
-> Typed Query or Command Tool
-> Domain Proposal or Run Request
-> Control-Plane Validation and Approval
-> Accepted Domain Command
-> Temporal Execution
-> Durable Application Events
-> Dashboard WebSocket and Coordinator Context
```

### Conversation Thread

The full Conversation Thread is preserved, including messages, tool calls, results, and approvals.

An OpenAI Agents SDK Session may maintain model-facing conversational history in PostgreSQL, but the SDK session is not canonical mission or workflow state.

### Intake Brief

The Intake Brief is a versioned statement of accepted objective, scope, context, constraints, unresolved questions, and operator decisions distilled from conversation.

A Workflow Run binds an exact Intake Brief version and references the supporting conversation turns. Raw chat history is not treated as an execution-ready instruction.

### Typed backend tools

The coordinator is expected to receive tools such as:

- inspect a Starter Collection
- capture or inspect artifacts
- draft or revise an Intake Brief
- propose a Mission Specification
- propose or revise a Mission Plan
- submit a Run Request
- inspect run state and events
- approve or reject a gate
- request a Run Control Revision
- inspect packages, findings, sources, reports, evaluations, and graph state

These may be local SDK function tools or MCP tools. Both call project-owned application services rather than mutating databases or Temporal directly from model reasoning.

## Active Workflow Catalog

The catalog is divided by specification maturity. “Accepted” means the Workflow Type is part of the current architecture, not that its complete schema and execution contract are finished.

## Workflow Types With Substantial Accepted Detail

### 1. `StarterContentRefinementWorkflow` Owner: Accepted Fully

Purpose:

Transform selected messy Starter Content into an immutable, versioned Starter Package with explicit lineage, findings, provisional seeds, readiness, repair history, preflight context, and mission-direction proposals.

Accepted inputs:

- captured Starter Artifacts
- selections from one or more Starter Collections
- prior Starter Packages
- direct captured reports or other artifacts
- optional Intake Brief
- explicit or default Refinement Directive
- reusable preflight or other accepted artifact references when admitted

A conversation is not required. A standalone API caller may invoke refinement directly.

Default Refinement Baseline:

1. validate input lineage and required permission capabilities
2. inventory and classify Package Artifact References
3. run applicable deterministic integrity checks
4. attempt clarification and seed extraction on processable content
5. preserve findings and zero-result outcomes
6. assemble a valid Starter Package and Starter Readiness Assessment
7. emit a separate Refinement Decision Report

Repair generation, Knowledge Preflight, and Supporting Source Lookup are degradable unless promoted to required Processing Obligations by the Refinement Directive.

Accepted execution shape:

```text
Admission
-> Branch Planning
-> Parallel Artifact Refinement Branches
-> Finding and Seed Consolidation
-> Optional Linked Work and Bounded Supporting Lookups
-> Package Assembly
-> Readiness Assessment
-> Decision Report
```

The application owns topology, dependencies, joins, limits, and completion semantics. Agents emit typed proposals but do not directly author structurally invalid package state.

Artifact branches:

- progress independently
- share read-only materialized inputs
- receive exclusive writable areas
- have branch-specific limits and outcomes
- may use bounded repair/reprocessing loops
- preserve successful work when another branch fails

Accepting a Repair Artifact may make downstream parses, findings, or seeds stale. Only affected dependency descendants rerun. Historical outputs remain preserved.

Package rules:

- the package is immutable and versioned
- it derives from one immutable Run Input Manifest
- it may combine multiple collections, packages, and direct artifacts
- it contains at least one captured artifact reference
- it acts as a manifest rather than embedding every payload
- lineage may have multiple parents through typed Package Derivations
- captured artifacts may all be unreadable while the package remains valid
- artifact-free intent proceeds through Intake Brief or Mission Specification instead

Readiness is workflow-relative. A finding may block one downstream workflow, warn another, trigger an added dependency, or have no consequence.

Open refinement questions:

- exact input and output schemas
- exact deterministic integrity-check catalog
- exact finding-type payload schemas
- role-assignment and seed-proposal acceptance policies
- exact Refinement Control Profile schema
- stage retry, timeout, cancellation, resume, and fork semantics
- Decision Report structure and effort levels
- application event contract
- Temporal workflow/activity/child-workflow mapping
- Agents SDK manager, tool, handoff, and sandbox-agent mapping
- whether `EntitySeedExtractionWorkflow` remains separate or seed extraction becomes solely an operation inside refinement

### 2. `KnowledgePreflightWorkflow` Owner: Accepted fully

Purpose:

Perform broad, observational discovery of existing entities, graph knowledge, prior work, coverage, contradictions, and gaps before mission specification or deep research.

Accepted behavior:

- first-class and independently runnable
- composable from refinement or other workflows
- rich vector, hybrid, full-text, filter, graph-traversal, prior-run, and artifact retrieval
- governed by data access, budget, and capability policy
- observational rather than a hidden mutation path
- may propose linked graph-maintenance or ingestion work

Output:

An immutable Knowledge Preflight Snapshot preserving:

- observation time
- graph and schema version context
- query intents and modalities
- selected result identities and scores
- Graph Match Candidates
- coverage findings
- contradictions
- gap hypotheses
- references to large result artifacts

Freshness:

Preflight freshness is contextual. It considers age, relevant graph/schema revisions, changed scope, risk, and downstream purpose. Historical snapshots do not become invalid merely because they are no longer current enough for a proposed use.

Mutation boundary:

If preflight finds a valuable pre-research graph repair or enrichment, it requests a separate linked Workflow Run. Human approval is the default for such mutation, with policy-controlled autonomy for narrowly safe cases.

Open preflight questions:

- exact input schema and query-plan schema
- match-category vocabulary
- graph-version and relevant-change detection
- retrieval result limits and ranking
- which pre-research mutations use existing ingestion workflows
- whether a dedicated graph-maintenance Workflow Type is needed
- exact event and evaluation contracts

### 3. `MissionSpecificationWorkflow` Owner: Accepted partially. A mission is a bit general. I'm not sure if this can 'specify' workflows other than ResearchExecution. We know there will be d

This replaces `MissionInstructionWorkflow`.

Purpose:

Transform accepted intake intent, Starter Packages, preflight context, existing knowledge, and operator decisions into a validated Mission Specification proposal.

Inputs may include:

- Intake Brief
- Starter Packages
- Knowledge Preflight Snapshots
- existing reports
- existing graph entities or datasets
- operator edits and constraints
- prior Mission Specification version

Output:

- immutable Mission Specification proposal
- validation results
- unresolved questions
- proposed Mission Plan inputs
- Specification Impact Assessment for revisions
- Decision Report

Acceptance:

A Specification Acceptance Policy decides whether a valid proposal:

- activates automatically
- requires human acceptance
- may be accepted by a delegated authority

The authoring agent does not gain self-approval authority merely by generating the proposal.

Open mission-specification questions:

- exact outcome-specific schema sections
- required research/evidence sections versus content/UI sections
- plan-compilation boundary
- revision and intervention event contracts
- default approval policies by risk and trust
- evaluation rubric for specification quality

## Accepted Workflow Types Whose Detailed Contracts Remain To Be Grilled

### 4. `EntitySeedExtractionWorkflow` Owner: Accepted partially. You can imagine a large paper + an instruction and needing to identify and extract entities with a bit of search-enabled validation.

Historical accepted purpose:

Extract early entity, product, material, topic, claim, media, and source hints.

Current model already defines:

- Seed Mention
- Extracted Seed
- preferred and alternative candidate types
- confidence basis
- Graph Match Candidates
- non-authoritative identity semantics

Unresolved boundary:

StarterContentRefinementWorkflow currently has seed extraction in its required baseline. We must decide whether:

- EntitySeedExtractionWorkflow remains a first-class linked Workflow Run
- it becomes an operation profile within refinement
- both exist, with a threshold distinguishing bounded inline extraction from a reusable independent extraction run

This is analogous to the resolved distinction between Supporting Source Lookup and SourceDiscoveryWorkflow, but it has not yet been decided.

### 5. `OfficialSourceMappingWorkflow` Owner: Accepted but this document is from 2026-07-15 we have included a lot more in general 'SourceIntelligence'

Purpose:

Find and verify official sources for people, organizations, products, trials, publications, regulatory records, technologies, and media.

Accepted semantics:

- official sources are authoritative for identity and self-claims
- official sources are not automatically authoritative for scientific truth
- identity resolution is stricter than Starter Content fuzzy matching
- low-risk official entity ingestion may be autonomous when policy permits
- approval gates must remain available

Open questions:

- exact identity-verification evidence
- source ownership and official-status rules
- auto-ingestable entity classes
- relation to KnowledgePreflightWorkflow
- relation to SourceDiscoveryWorkflow
- whether official-source mutation always invokes ingestion workflows

### 6. `SourceDiscoveryWorkflow` Owner: Accepted. This document is missing another Source related workflow

Purpose:

Perform systematic source procurement, coverage expansion, ranking, and discovery beyond bounded Supporting Source Lookup.

Accepted boundary:

A Supporting Source Lookup may answer declared clarification questions within another workflow under search/page/time/cost limits. Once the purpose becomes systematic procurement or corpus coverage, a separate SourceDiscoveryWorkflow Run is required.

Accepted source distinctions:

- Source Candidate
- Research Source Selection
- Ingestion Source Selection
- research-only use
- Source Intelligence Cache
- source registration and usage history

Open questions:

- discovery strategy and stopping criteria
- source-class coverage requirements
- ranking and quality assessment
- freshness policies by source class
- rights/paywall/access behavior
- official versus independent source balance
- dynamic subagent strategy
- source cache write and invalidation rules

### 7. `SourceCorpusBuildWorkflow` Owner: Accepted Partially

Purpose:

Turn selected sources into a durable, usable corpus of documents, media, extracted representations, chunks, embeddings, and connections.

Known requirements:

- documents and media are first-class
- whole-document and chunk-level relationships are both likely required
- Source Snapshots and exact Source Locators preserve reproducibility
- only ingestion-approved material may become durable graph provenance
- permission capabilities govern retention, transformation, indexing, quoting, and reuse

Open questions:

- whole-document versus chunk relationship rules
- parser and conversion policies
- multimodal representation
- embedding/version policy
- corpus versioning
- failed extraction and repair behavior
- S3/object-store manifests
- Neo4j/document-store ownership boundaries

-- CURRENT BOUNDARY. We are going to start implementing up until the Research Execution workflow. There are a lot of system-level things like sandboxes - schema workspaces and infrastructure set up as well as the other workflows that will be complete before we move on to mode-specific research execution --

### 8. `ResearchExecutionWorkflow`

Purpose:

Perform mode-specific deep research under a Mission Specification.

Discussed research modes:

- Stage DAG
- iterative stages
- Ralph-style long-running loop
- debate and adjudication
- red-team safety
- evidence triangulation
- monitoring and surveillance
- protocol sprint
- replication and fork
- corpus build

Known requirements:

- KG/Knowledge Preflight grounding
- adaptive source discovery
- independent research branches
- budgets, checkpoints, convergence, and maximum-work rules
- durable artifacts and cross-stage events
- sandboxed agents with workspace and shell/filesystem access
- manager agents, agents-as-tools, handoffs, and dynamic subagents where appropriate

Open questions:

- whether one Workflow Type supports all modes or modes become separate types
- dependency/cycle scheduler semantics
- stage and branch contracts
- convergence and termination
- research workspace contract
- source registration before final conclusions
- cross-stage coordinator behavior
- Temporal child-workflow/activity granularity
- Agents SDK subagent topology

### 9. `EvidenceAdjudicationWorkflow`

Purpose:

Evaluate Assertions and evidence, preserving support, contradiction, applicability, uncertainty, and method-versioned verdicts.

Known domain concepts:

- Assertion
- Adjudication
- Evidence Assessment
- Evidence Applicability
- Source Snapshot
- Source Locator

Open questions:

- verdict vocabulary
- quality and applicability dimensions
- conflict handling
- human/expert review thresholds
- adjudicator independence
- relationship to research synthesis
- relationship to ingestion Graph Candidates
- re-adjudication after new evidence

### 10. `ReportCreationWorkflow`

Purpose:

Create a durable research report from accepted research outputs, evidence, adjudications, uncertainty, and provenance.

Known requirements:

- reports must be reusable as direct inputs to ingestion planning
- report creation is not the same as research execution
- generated conclusions must preserve source and evidence links
- report versions and human edits require lineage

Open questions:

- report schema and section contracts
- structured findings versus narrative
- audience and channel profiles
- citation and Source Locator rules
- report acceptance and publication
- report-to-ingestion handoff

### 11. `IngestionPlanWorkflow`

Purpose:

Transform completed reports, source/corpus artifacts, graph context, and a target schema into a validated, reviewable Ingestion Plan.

Accepted behavior:

- may run standalone without prior research or Starter Package
- accepts completed reports directly when its admission contract permits
- produces a pre-commit Graph Candidate and ordered writes
- supports dry run, review, repair, approval, and rejection
- must not mutate Neo4j while merely planning

Open questions:

- target-schema selection input
- report-grounded graph comparison
- entity resolution
- normalization
- assertion/evidence/provenance mapping
- idempotency keys
- transaction and batch boundaries
- plan validation and repair
- Mongo/PostgreSQL/S3 working-state ownership

### 12. `IngestionExecutionWorkflow`

Purpose:

Execute an approved Ingestion Plan into authoritative knowledge and corpus stores.

Accepted behavior:

- external effects are idempotent and audited
- only approved Source Refs, Documents, Media, Assertions, entities, relationships, and provenance are promoted
- Graph Commit is distinct from planning
- schema changes are not silently authorized by successful ingestion

Open questions:

- Neo4j transaction strategy
- object/document-store promotion ordering
- partial commit and compensation
- retry and duplicate-write semantics
- approval and mutation risk classes
- graph-version markers
- post-commit validation

### 13. `ContentCreationWorkflow`

Purpose:

Create governed Curated Content from approved knowledge, research artifacts, and provenance.

Discussed outputs:

- articles and explainers
- knowledge cards
- tips and avoidance guidance
- protocols and technique guides
- product, compound, biomarker, organization, and intervention profiles
- comparisons and decision-support content
- images, diagrams, charts, animation, audio, and video

Known requirements:

- knowledge and evidence derivation
- audience, purpose, format, and channel
- prompt/model/skill/config versions
- generated and human-edited versions
- rights and media-generation provenance
- safety, scientific quality, freshness, and publication evaluation
- correction, withdrawal, supersession, and re-evaluation

Open boundary:

`ContentCreationWorkflow` may be too broad. It may need to split into Curated Content, Media Generation, Publication, and Generative UI workflows.

### 14. `EvaluationWorkflow`

Purpose:

Evaluate process and output quality across research, source handling, ingestion, knowledge, content, retrieval, and experiences.

Discussed evaluation targets:

- research quality and coverage
- source quality and freshness
- scientific reasoning
- ingestion correctness
- provenance integrity
- graph integrity
- reproducibility
- content safety and publication quality
- Graph RAG and biotech information retrieval using high-value question datasets
- generative UI schema/binding validity
- accessibility, interaction, latency, interruption, and recovery
- usefulness and user outcomes

Open boundary:

One generic EvaluationWorkflow may be a family or meta-contract rather than one implementation. Evaluation targets, datasets, rubrics, gates, and promotion rules remain to be modeled.

## Candidate Workflow Types Implied by the Current North Star

These capabilities have been discussed, but their names and boundaries are not yet accepted.

### Starter intake and capture

Possible type:

- `StarterArtifactCaptureWorkflow`
- `StarterCollectionIntakeWorkflow`

Need:

Convert raw folders, uploads, URLs, or snapshot-local files into durable Starter Artifacts and Artifact Content before refinement.

Open decision:

Whether capture is a Workflow Type, a synchronous application service, or both depending on scale and processing.

### Schema exploration and selection

Possible type:

- `SchemaSelectionWorkflow`
- `TargetSchemaSelectionWorkflow`

Need:

Provision a schema exploration workspace, inspect the optimized Neo4j schema, select applicable entity/assertion/evidence/media targets, and produce a schema-aware ingestion contract.

Open decision:

Whether schema exploration and schema selection are one workflow or separate workflows.

### Post-research knowledge comparison

Possible type:

- `KnowledgeComparisonWorkflow`
- `ReportGraphComparisonWorkflow`

Need:

Use completed reports as input to search existing graph knowledge, identify overlap, contradictions, missing records, identity candidates, and ingestion deltas before planning writes.

Open decision:

Whether this is part of IngestionPlanWorkflow, a reusable KnowledgePreflight mode, or a distinct Workflow Type.

### Pre-research graph maintenance

Possible type:

- `GraphMaintenanceWorkflow`
- existing IngestionPlanWorkflow plus IngestionExecutionWorkflow

Need:

Execute rare, approved pre-research graph repair or enrichment discovered during Knowledge Preflight.

Open decision:

Whether existing ingestion workflows fully cover this use case.

### Curated media generation

Possible type:

- `MediaCreationWorkflow`
- a mode of ContentCreationWorkflow

Need:

Generate or transform images, diagrams, charts, animations, audio, and video with source, model, rights, and publication lineage.

### Generative UI and MCP UI component creation

Possible types:

- `GenerativeUIComponentWorkflow`
- `ExperienceCompositionWorkflow`
- `MCPUIResourceWorkflow`

Need:

Create governed component definitions and interactive experiences grounded in approved knowledge, tool results, and provenance.

Required future contracts:

- allowed component registry
- component schema and version
- data-binding rules
- action and authorization rules
- client-code restrictions
- streaming and interruption
- accessibility
- cross-surface rendering
- experience evaluation

### Publication and lifecycle management

Possible types:

- `ContentPublicationWorkflow`
- `ContentCorrectionWorkflow`
- `ContentReevaluationWorkflow`

Need:

Separate content creation from approval, publication, correction, withdrawal, supersession, and freshness-triggered re-evaluation.

### Retrieval and Graph RAG evaluation

Possible type:

- `KnowledgeRetrievalEvaluationWorkflow`

Need:

Run valuable biotech question datasets against graph retrieval and answer generation, score evidence coverage and citation fidelity, and produce improvement candidates without silently changing schema or retrieval policy.

## Historical Workflow Names Not Yet Adopted Into The Active Catalog

An older design document also discussed:

- `EpisodeResearchMissionWorkflow`
- `ArtifactIntegrityWorkflow`
- `TranscriptNormalizationWorkflow`
- `EntityResearchWorkflow`
- `EvidenceResearchWorkflow`
- `GraphCandidateWorkflow`
- `GraphCommitWorkflow`
- `CuratedContentWorkflow`

These names are useful design evidence but are not automatically active Workflow Types.

Current likely relationships:

- EpisodeResearchMissionWorkflow is superseded conceptually by Knowledge Production Mission plus composed Workflow Runs.
- ArtifactIntegrityWorkflow may become a standalone type or remain an operation profile inside Starter Content Refinement.
- TranscriptNormalizationWorkflow may become a specialized repair/processing workflow or operation.
- EntityResearchWorkflow and EvidenceResearchWorkflow may become ResearchExecutionWorkflow modes or linked specializations.
- GraphCandidateWorkflow overlaps IngestionPlanWorkflow.
- GraphCommitWorkflow overlaps IngestionExecutionWorkflow.
- CuratedContentWorkflow may become the eventual replacement for the overly broad ContentCreationWorkflow name.

Each requires an explicit decision before implementation.

## System-Wide Agent Configuration

### Agent Profile

A versioned Agent Profile may configure:

- role and base instructions
- dynamic-instruction policy
- model and effort policies
- tools
- MCP servers and tool allowlists
- Agent Skills
- guardrails
- hooks and middleware
- subagent policy
- handoffs and agents-as-tools
- workspace requirements
- execution capabilities
- reporting and tracing hooks

Every operation records the resolved profile and actual runtime bindings.

### Dynamic Instructions

Middleware, hooks, humans, or agents may construct Dynamic Instructions from authorized state and messages.

Dynamic instructions may expose:

- relevant run state
- current findings and unresolved questions
- resolved tools and skills
- workspace paths
- budgets
- active policies
- user interventions

They do not grant authority. Tools, MCP servers, skills, filesystem permissions, models, subagent rights, and data access are granted by validated configuration and policy.

### Actor- and operation-specific capability profiles

The coordinator and workflow agents do not share one universal profile.

The coordinator may have:

- broad governed retrieval
- backend query tools
- typed domain-command tools
- approved MCP servers
- agent-skill access
- dynamic-agent authorship

Workflow operations receive only the capabilities accepted for that operation, even when the overall run has a broader ceiling.

### Operation-specific model policies

Different operation classes may use different model policies:

- classification
- semantic extraction
- repair proposal
- consolidation
- mission-direction proposal
- reporting
- evaluation

Deterministic work uses no model. Every model operation records actual model, prompt, skill, tool, fallback, and effort bindings.

## Dynamic Agent Authorship

The system will support broad runtime authorship of novel agents.

A Dynamic Agent Definition may introduce:

- a novel role
- task-specific instructions
- dynamic prompts
- model policy
- MCP/tool selection
- Agent Skills
- workspace requirements
- filesystem locations
- shell/browser/code capabilities
- subagent structure
- delegation behavior
- budget and completion expectations

The definition is:

- validated before execution
- recorded immutably
- sandboxed according to policy
- bound to operation and run lineage
- constrained by a Delegation Ceiling

Dynamic authorship is not limited to fixed templates.

However:

- deployment availability is not authorization
- a deployed credential is not automatically usable
- a subagent cannot receive authority beyond the governing Workflow Run and delegating agent
- dynamic prompts do not grant capabilities
- domain invariants remain non-overridable
- hard budget limits remain enforced

## Explicitly Unresolved: Dynamic Agents Invoking Workflows

This question is intentionally open.

The uncertain scenario is:

1. an agent is executing inside a Workflow Run
2. it determines that another substantial capability is needed
3. it may author a Dynamic Agent Definition for that capability
4. the capability may also correspond to an existing Workflow Type

Possible models:

### Model A: Workflow invocation is always a typed tool

The parent agent calls a tool such as `submit_run_request`.

The tool:

- accepts a Workflow Type
- accepts proposed inputs and controls
- optionally accepts a Dynamic Agent Definition as an execution proposal
- validates authority and admission
- creates a linked Workflow Run after acceptance

The agent does not “spawn a workflow” directly.

### Model B: Dynamic spawn can compile into a Workflow Run

The parent emits a dynamic child-agent/spawn definition.

Application code classifies the proposed task. If it crosses a Workflow Type boundary, the spawn is compiled into a linked Run Request and Workflow Run.

Risk:

Classification may be ambiguous, agent-controlled, or surprising unless the rules are extremely explicit.

### Model C: Two explicit primitives

The system exposes:

- `delegate_subagent` for bounded internal operation work
- `request_workflow_run` for first-class Workflow Type execution

A Dynamic Agent Definition may be supplied to either primitive, but the caller must choose the semantic boundary explicitly. The control plane validates the choice and may reject an attempt to hide a known Workflow Type inside an internal delegation.

This currently appears to be the strongest candidate, but it is not yet accepted.

Questions still required:

- What exact properties make work a Workflow Run rather than an internal subagent operation?
- May application policy promote an internal delegation proposal into a Run Request?
- Can a Dynamic Agent Definition override the Workflow Type's default Agent Profile?
- Which fields are overlays versus replacements?
- How does a parent wait for, stream, cancel, retry, or detach from a linked run?
- How are parent and child budgets reserved?
- Does a linked run inherit the parent's mission ownership automatically?
- Which agent or application component synthesizes child outputs?
- How are SDK agents-as-tools and handoffs prevented from becoming hidden durable schedulers?
- How are nested Run Requests represented in Temporal?

No implementation should hard-code this boundary until the interview resolves it.

## Sandboxing Policy

Sandboxing is a strong default with narrow exceptions.

Agents should run sandboxed when they:

- read or write workflow files
- use shell or filesystem tools
- browse
- execute code
- install packages
- transform documents or media
- create artifacts
- operate on workflow-specific working directories

Potential non-sandbox exceptions:

- coordinator conversation turns limited to typed backend tools
- narrow read-only query operations
- deterministic application operations that do not invoke an agent

Exceptions are explicit policy decisions.

## Workspace Model

### Workspace Template

The project owns a versioned Workspace Template defining:

- logical directory layout
- mounted inputs
- writable outputs
- Agent Skill bundles
- bootstrap files
- runtimes and packages
- users and permissions
- capability requirements

The domain contract does not expose OpenAI SDK beta classes directly.

### Workflow Workspace Contract

Each Workflow Type declares logical named locations, for example:

```text
inputs/starter
inputs/packages
inputs/preflight
working/artifacts/{branch}
working/schema
working/research
outputs/candidates
outputs/promoted
reports
```

The contract defines:

- purpose
- access mode
- input/output slot semantics
- write ownership
- promotion expectations

The selected Workspace Template and provider resolve logical locations into actual paths.

### Run Workspace Namespace

One Workflow Run does not necessarily equal one sandbox.

A Run Workspace Namespace may contain:

- one coordinator workspace
- multiple artifact-branch sandboxes
- browser or repair sandboxes
- schema-exploration workspaces
- package-assembly workspace
- evaluation workspace

Every workspace and area binds to run and operation lineage.

Shared inputs default to read-only. Parallel branches receive exclusive writable locations. Cross-branch communication uses typed events or promoted artifacts rather than uncontrolled shared-file writes.

### Workspace Materialization Manifest

Every governed workspace path maps explicitly to:

- durable package reference
- durable artifact reference
- object-storage payload
- read-only mounted input
- generated local candidate
- promoted output
- stale or superseded materialization

Unmapped files remain workspace-local and cannot silently become domain artifacts.

If a sandbox starts from a snapshot containing a Starter Package, the package in the filesystem is a materialization of a canonical durable package.

If a sandbox starts from an arbitrary folder that should become a Starter Package:

1. inventory the folder
2. capture content and origins
3. create Artifact Content and Starter Artifact records
4. create the Workspace Materialization Manifest
5. invoke refinement over the resulting durable references

### Sandbox Snapshot

A snapshot captures resumable sandbox execution state. It may support:

- resume
- fork
- debugging
- audit
- reproduction attempts

A snapshot is not automatically:

- a Starter Package
- an artifact store
- a graph version
- a Workflow Run record
- an Agents SDK Session
- proof of complete reproducibility

Workspace-local outputs must be explicitly promoted to durable artifact storage and mapped in the Workspace Materialization Manifest before packages or downstream workflows rely on them.

## OpenAI Agents SDK Mapping

Current best-effort mapping:

- Agent Profile -> SDK `Agent` or `SandboxAgent` definition
- typed backend command -> SDK function tool or MCP tool
- dynamic subagent -> runtime-created SDK Agent definition after validation
- manager-owned specialist -> agent as tool
- specialist becomes active for a turn -> handoff
- conversation history -> SDK Session in PostgreSQL
- approval interruption -> SDK tool approval plus serializable `RunState`, backed by authoritative domain approval state
- Workspace Template -> project compiler targeting SDK `Manifest` and capabilities
- per-operation sandbox binding -> `SandboxRunConfig`
- resumed workspace -> sandbox session state or snapshot
- streamed tokens/tool/items/handoffs -> translated application events

SDK event objects are not exposed directly as the application contract.

The sandbox integration remains behind a project-owned adapter because SDK sandbox APIs have been treated as beta and must not define the domain language.

## Temporal Mapping

Temporal owns:

- durable workflow lifecycle
- retries, timeouts, timers, and long waits
- signals, queries, updates, and cancellation
- worker recovery
- child-workflow lifecycle
- durable waiting for approvals
- durable linked-run coordination
- continue-as-new when history requires it

Temporal workflow code remains deterministic.

Activities own:

- model execution
- Agents SDK Runner calls
- MCP and external API calls
- database reads and writes
- object-storage operations
- sandbox provisioning and provider calls
- artifact capture and promotion

BellLabs application code still owns:

- Workflow Type semantics
- Run Request validation
- scheduling and convergence rules
- idempotency
- budgets
- authorization and policy
- Dynamic Agent Definition validation
- event translation
- persistence projections

## Persistence Boundaries

The accepted direction remains:

- Neo4j: authoritative approved knowledge graph
- PostgreSQL/Supabase: Agents SDK sessions and relational control-plane records
- Temporal persistence: Temporal-owned execution history
- object storage: documents, media, reports, extracted payloads, snapshots, and large artifacts
- MongoDB/Beanie or PostgreSQL/JSONB: still-open research-runtime record decision
- Redis or equivalent: possible low-latency event delivery and ephemeral coordination, not canonical workflow state

No SDK Session, Temporal history, sandbox snapshot, Mongo document, or filesystem folder silently becomes canonical knowledge.

The MongoDB versus PostgreSQL/JSONB decision remains intentionally open until workflow access patterns, transactions, retention, indexing, lineage, and concurrency are specified.

## Dashboard and Event Implications

The future dashboard is a control plane and evaluation playground, not the owner of workflow state.

It will need versioned application events for:

- mission and run lifecycle
- stage and artifact-branch progress
- agent and subagent activity
- tool and MCP calls
- sandbox/workspace provisioning
- file materialization and promotion
- findings and readiness
- repair decisions
- approvals and policy overrides
- budgets and continuation proposals
- control revisions
- linked Run Requests
- artifacts and Decision Reports
- evaluations and improvement candidates

FastAPI should expose command/query APIs. WebSockets should project authorized event streams and support reconnect/recovery from durable cursors rather than relying on one live in-memory stream.

The exact event schema remains open.

## What Is Firmly Settled

- the system is composable rather than one rigid pipeline
- Workflow Type and Workflow Run are first-class
- standalone and mission-owned runs use the same contracts
- the top-level composition is Knowledge Production Mission
- every mission requires an accepted Mission Specification
- Run Input Manifests and emitted packages are immutable
- Starter Collections are mutable operator-owned intake containers
- Starter Packages are manifest-style outputs, not universal wrappers
- Knowledge Preflight is first-class, broad, observational, and independently runnable
- graph mutation discovered during preflight uses a separate linked run
- Supporting Source Lookup is bounded; systematic procurement is SourceDiscoveryWorkflow
- agent judgments enter domain state as typed validated proposals
- run outcome and output readiness are separate
- permission is acquisition-specific and capability-specific
- repair generation and repair acceptance are separate
- inferred missing content without source evidence is a Reconstruction Hypothesis
- agent and operation capability profiles are distinct
- dynamic agents may be authored broadly but cannot exceed their Delegation Ceiling
- sandboxing is the strong default for filesystem/shell/browser/artifact work
- Workspace Templates and Workflow Workspace Contracts are project-owned
- durable storage is canonical; workspace files are explicit materializations or local candidates
- OpenAI Agents SDK owns agent-loop mechanics
- Temporal owns durable execution mechanics
- BellLabs application code owns domain semantics

## What Remains Unresolved

Highest-priority unresolved decisions:

1. Internal dynamic subagent delegation versus linked Workflow Run invocation.
2. EntitySeedExtractionWorkflow boundary relative to refinement operations.
3. Exact StarterContentRefinementWorkflow control and event schemas.
4. Exact Temporal granularity for mission, run, stage, and artifact branches.
5. Exact Agents SDK session, RunState, sandbox-session, and snapshot correlation.
6. SourceDiscoveryWorkflow and ResearchExecutionWorkflow scheduling semantics.
7. Schema exploration/selection workflow boundary.
8. Post-report graph comparison boundary.
9. Ingestion planning and execution contracts.
10. Evaluation workflow family and Graph RAG evaluation datasets.
11. Content, media, publication, and generative UI workflow decomposition.
12. MongoDB versus PostgreSQL/JSONB research-runtime persistence.

## Recommended Next Interview Sequence

1. Resolve internal subagent versus linked Workflow Run semantics.
2. Finish StarterContentRefinementWorkflow controls:

- capability and Agent Profile resolution
- workspace contract
- retry/timeouts
- cancellation/resume/fork
- approvals
- Decision Report schema
- event contract

3. Perform the first detailed OpenAI Agents SDK and Temporal execution mapping for refinement.
4. Decide EntitySeedExtractionWorkflow boundary.
5. Specify SourceDiscoveryWorkflow.
6. Specify ResearchExecutionWorkflow modes and scheduler.
7. Specify schema selection and post-report knowledge comparison.
8. Specify ingestion planning and execution.
9. Specify evaluation, then curated content/media, then generative UI.

## Related Checkpoints

- [OpenAI Agents SDK and Temporal Architecture](2026-07-14-openai-agents-sdk--temporal-research-ingestion-evaluation-checkpoint.md)
- [Knowledge Production Composition and Intake](2026-07-15-knowledge-production-composition-and-intake-checkpoint.md)
- [Starter Preflight and Mission Specification](2026-07-15-starter-preflight-and-mission-specification-checkpoint.md)
- [Starter Package Findings, Permissions, and Repair](2026-07-15-starter-package-findings-permissions-and-repair-checkpoint.md)

The canonical vocabulary remains in [Human Upgrade System Context](../CONTEXT.md).
