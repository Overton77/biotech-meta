# Starter Content Refinement Workflow Synthesis

Date: 2026-07-18

Status: Accepted pre-specification synthesis

Related:

- [System workflow execution and control-plane synthesis](./2026-07-18-system-workflow-execution-and-control-plane-synthesis.md)
- [Knowledge Preflight synthesis](./2026-07-18-knowledge-preflight-workflow-synthesis.md)
- [Pre-research architecture checkpoint](../checkpoints/system-level/2026-07-18-pre-research-architecture-synthesis-and-grill-entry-checkpoint.md)
- [Workflow, agent, sandbox, and system-state checkpoint](../checkpoints/system-level/2026-07-15-workflow-catalog-agent-sandbox-and-system-state-special-checkpoint.md)

## 1. Purpose

`StarterContentRefinementWorkflow` transforms selected messy Starter Content into an immutable, versioned Starter Package with explicit lineage, findings, provisional research seeds, readiness, repair history, and a Decision Report.

It is independently runnable and does not require a Conversation, Conversation Thread, Intake Brief, or Knowledge Production Mission.

It clarifies and preserves uncertain material; it does not convert starter assertions into accepted truth, authoritative graph knowledge, or executable mission instructions.

## 2. Non-goals

The workflow does not:

- perform deep or systematic research
- establish canonical entity identity
- adjudicate scientific claims
- mutate Neo4j
- silently repair or replace source material
- treat package inclusion as a requirement that every processing operation succeed
- make one universal readiness decision for all downstream workflows
- hide a first-class Knowledge Preflight, Source Discovery, or substantial Research Seed Extraction run inside an agent delegation

## 3. Actors and launch paths

Allowed callers include:

- operator through FastAPI
- coordinator through a typed backend tool
- another Workflow Run through a declared linked-run slot
- service account under an accepted Run Request policy

Conversation-assisted launch may distill accepted intent into a Refinement Directive or Intake Brief. Raw thread content is not passed as authoritative workflow instruction.

Standalone launch uses a default Refinement Directive when the caller does not supply one.

## 4. Inputs and immutable manifest

A run may admit:

- captured Starter Artifacts
- immutable selections from one or more Starter Collections
- prior Starter Packages
- direct captured reports, notes, transcripts, images, PDFs, URLs, or other artifacts
- optional Intake Brief version
- explicit or default Refinement Directive
- optional accepted Knowledge Preflight Snapshot or other reusable output references

The Run Input Manifest freezes exact artifact, content, package, collection-snapshot, brief, directive, permission-assessment, and configuration references.

A mutable Starter Collection is never a live run input.

Artifact-free intent is not a valid Starter Package input. It proceeds through an Intake Brief or Mission Specification path.

## 5. Admission contract

Admission must establish:

- at least one captured Starter Artifact or prior Starter Package containing one
- resolvable immutable content or an explicit captured-but-unavailable state
- lineage sufficient to identify acquisition and prior derivation
- applicable Permission Assessments for inspection and planned operations
- no prohibited processing obligation
- a valid Refinement Directive and allowed blueprint revision
- an Effective Run Configuration compatible with required runtimes and workspaces
- budget sufficient for the required baseline or an explicit policy-allowed constrained baseline

Admission does not require every artifact to be readable or processable. Corrupt, unavailable, unsupported, or prohibited content remains representable and may yield findings and a valid package.

## 6. Workflow invariants

1. Every package artifact reference points to an immutable Starter Artifact occurrence.
2. Artifact Content deduplication never merges provenance, permissions, or intake identity.
3. Package inclusion and Processing Obligations remain separate.
4. Required, degradable, optional, and prohibited obligations are explicit.
5. Repair generation and Repair Decision are separate.
6. Original material and historical derived outputs are never overwritten.
7. A replacement invalidates only dependency descendants affected by the changed selection.
8. Findings keep severity, confidence, review state, and downstream consequence separate.
9. Extracted Seeds remain provisional and preserve exact Seed Mention locators.
10. Supporting graph or source lookup is bounded and cannot claim first-class workflow coverage.
11. Graph mutation is prohibited.
12. Package assembly is application-owned and validated; an agent cannot directly declare structurally invalid state valid.

## 7. Obligations

### 7.1 Required refinement baseline

The default required baseline is:

1. validate input lineage and required permission capabilities
2. inventory and classify Package Artifact References
3. determine applicable integrity checks and processing obligations
4. run applicable deterministic integrity checks
5. attempt clarification and provisional seed extraction on processable subjects
6. preserve findings, failures, unsupported regions, and valid zero-result outcomes
7. consolidate accepted current findings and seeds
8. assemble a valid Starter Package
9. produce a Starter Readiness Assessment
10. emit a separate Decision Report

### 7.2 Degradable by default

Unless the Refinement Directive promotes them to required obligations:

- Repair Artifact generation
- Knowledge Preflight
- Supporting Graph Lookup
- Supporting Source Lookup
- expensive multimodal transformation
- substantial research-seed extraction

### 7.3 Obligation matrix

The run binds a `RefinementObligationMatrix` across:

- artifact or package subject
- content modality and region
- operation class
- required/degradable/optional/prohibited status
- coverage expectation
- completion and stopping evidence

Accepted revisions preserve prior cells, deciding authority, rationale, budget effect, and invalidation effect.

## 8. Allowed blueprint variants

The Workflow Type declares two application-owned blueprint variants. A run binds one immutably at launch.

Both variants use the same admission, invariants, obligations, output schemas, readiness semantics, authority boundaries, and evaluation contract.

### 8.1 `StageGraphRefinement`

The baseline stage graph is:

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

#### Admission

Deterministic application services validate the input manifest, permissions, directive, blueprint, and Effective Run Configuration.

#### Branch planning

Planning creates typed artifact branches and their obligation cells. Agents may propose classification, operation ordering, or modality strategy, but application validation owns the executable branch plan.

#### Artifact refinement branches

Branches:

- progress independently
- use read-only shared inputs
- receive exclusive writable workspace areas
- maintain branch-specific budgets and outcomes
- publish candidates through artifact promotion
- may use bounded clarification, repair, transformation, and extraction cycles

A branch cycle is semantic rework after evaluation, not a Temporal Activity retry.

#### Guest business-affiliation starter summary

When an admitted transcript identifies a guest and the Refinement Directive requests guest context, an artifact-refinement branch or GoalDirected iteration may run a bounded `GuestBusinessAffiliationSummaryOperation`. It creates a starter summary of the guest's current and material historical business affiliations for later research; it does not establish canonical identity, infer an affiliation without evidence, or claim deep-research coverage.

The operation preserves:

- the transcript guest mention and locator
- searched identity variants and disambiguation limits
- affiliation name, role, relationship type, and supported time range
- source URL, capture time, quoted or extracted evidence, and retrieval method
- confidence, contradictions, unresolved identity questions, and coverage limitations
- provisional Entity, Assertion, Evidence Question, and Source Lead seeds where applicable

Its Agent Profile declares this required attachment set through system `CapabilityRequirement`s:

- a Firecrawl Agent Skill for web discovery, extraction, and source capture
- a Tavily Agent Skill for complementary search and research retrieval
- a Vercel `agent-browser` Skill for browser-based inspection when navigation or rendered-page interaction is needed

These are logical catalog selectors, not floating executable dependencies. Publication resolves each selector through the internal PostgreSQL catalog or approved registry/direct-source adapters, completes ingestion and promotion when necessary, and freezes exact Skill, MCP server/tool, source, version, and digest bindings. All three capabilities must be attached when this operation is admitted; invocation remains task-directed and every actual call is recorded. Missing or ambiguous required resolution blocks this operation rather than silently selecting a similarly named asset. The workflow may degrade only when its obligation cell explicitly classifies this summary as degradable.

The lookup remains bounded by source-count, time, token, network, and data-egress budgets. Results are untrusted research inputs until represented as cited findings or seeds and admitted by the normal refinement rules.

#### Consolidation

Consolidation:

- resolves current versus stale derived outputs
- preserves disputed or alternative findings
- joins Seed Mentions without inventing identity
- creates immutable Extracted Seed groupings and lineage
- assesses extraction coverage separately from seed count

#### Optional linked work and lookups

The stage may:

- run a bounded Supporting Graph Lookup
- run a bounded Supporting Source Lookup
- request a linked Knowledge Preflight
- request substantial linked Research Seed Extraction
- request other Workflow Types declared in the blueprint

Every linked result receives a parent-side Linked Run Result Admission Decision before it affects package findings or readiness.

#### Package assembly, readiness, and reporting

Package assembly is deterministic over admitted current references and typed decisions. Readiness remains purpose-relative. Decision Report generation may be agentic, but structural validation and required decision coverage are deterministic.

#### Invalidation

Repair acceptance, artifact replacement, role changes, or admitted linked results calculate a dependency frontier. Only affected descendants rerun. Historical attempts and stale outputs remain queryable.

### 8.2 `GoalDirectedRefinement`

This variant is for heterogeneous or poorly structured Starter Content where a fixed branch plan would be premature or would require repeated replanning.

The application still performs deterministic admission and final output validation.

At launch it creates a bounded refinement goal from:

- Refinement Directive
- immutable input manifest
- Refinement Obligation Matrix
- fixed output and readiness contracts

Each goal iteration may:

- inspect unaddressed subjects and coverage cells
- author bounded Dynamic Agent Definitions
- delegate handoffs or task subagents
- perform allowed integrity, clarification, transformation, repair-proposal, and extraction operations
- request declared linked workflows
- promote candidate artifacts and findings
- propose a bounded Goal Revision

An independent evaluator determines:

- newly satisfied obligations
- unresolved or failed cells
- stale descendants
- progress since the prior iteration
- whether repair, another iteration, degradation, linked work, human review, or stop is appropriate

Goal evolution cannot broaden the directive, add unadmitted inputs, weaken invariants, or invent new workflow boundaries. Broader change requires a valid control revision, fork, or linked/new run.

On verified completion or allowed stop, deterministic services assemble the package and validate readiness/report outputs.

## 9. Agent and model roles

Likely operation-specific Agent Profiles include:

- artifact classifier
- integrity and modality inspector
- clarification specialist
- repair proposer
- research-seed extractor
- branch evaluator
- consolidation agent
- readiness assessor
- Decision Report author
- GoalDirected coordinator

These are roles, not mandatory one-agent-per-stage assignments.

Every model operation receives an immutable Operation Execution Binding. Deterministic checks use no model.

Handoffs and task subagents remain bounded within an operation. They cannot create hidden durable schedulers or bypass linked-run promotion rules.

## 10. Workspace and sandbox contract

The Run Workspace Namespace should support logical slots such as:

```text
inputs/starter/
inputs/packages/
inputs/preflight/
branches/<branch_id>/cycles/<cycle>/attempts/<attempt>/
shared/current-findings/
shared/current-seeds/
linked-results/
assembly/
readiness/
reports/
```

Inputs and mounted skills are read-only. Parallel branches never share an uncontrolled writable directory.

The Workspace Materialization Manifest distinguishes local candidates, promoted artifacts, superseded selections, stale outputs, and durable references.

Recommended snapshot policy:

- snapshot on blocked/failed high-cost branches
- snapshot before an approved repair replacement when rollback evidence is valuable
- optionally snapshot each GoalDirected iteration for expensive or long-running work
- destroy ephemeral workspaces only after required artifact promotion and event persistence

Snapshot restore creates a new workspace clone and revalidates credentials and capabilities.

## 11. Schema Workspace and graph access

Refinement does not require a Schema Workspace by default.

A declared stage or goal iteration may compose `SchemaWorkspaceMaterialization` when it needs:

- bounded Supporting Graph Lookup
- graph-aware seed matching
- preparation or result interpretation for a linked Knowledge Preflight

The materialization binds the exact Schema Catalog and requires `SchemaDeploymentManifest.deployed_sdl_hash` to equal the bound `SchemaDefinition.content_hash`. A manifest's own document digest is not evidence of schema equality. Missing or mismatched deployment identity blocks graph-reading operations.

A bounded lookup:

- records exact query intent, operation projection, graph/schema version, limits, and results
- may emit Graph Match Candidates
- cannot resolve identity
- cannot claim broad Knowledge Preflight coverage
- cannot mutate Neo4j

## 12. Linked Knowledge Preflight

Knowledge Preflight is degradable by default and becomes required only when the Refinement Directive or an accepted obligation revision says so.

The parent Run Composition Link declares:

- request slot and identity
- exact input projection from package/artifact subjects
- dependency class
- delegated authority and data scope
- reserved budget
- freshness requirement
- timeout and cancellation behavior
- result-admission policy

The child independently compiles its own Effective Run Configuration. Parent cancellation and completion follow the declared dependency class.

A late nonblocking preflight result cannot mutate a terminal Starter Package. It may become input to a successor refinement or another workflow.

## 13. Outputs

### 13.1 Starter Package

The immutable Starter Package is a manifest-style output containing at least one captured artifact reference and:

- package identity and version
- Run Input Manifest and workflow lineage
- Package Derivations from prior packages/artifacts
- Package Artifact References with roles, rationale, grouping, ordering, and inclusion requirement
- current selection and supersession state
- references to findings, seeds, representations, and repair decisions
- permission and provenance context
- generation and validation metadata

Unreadable artifacts may remain included when lineage and references are valid.

### 13.2 Findings and seeds

Outputs preserve:

- typed Starter Findings
- finding severity, confidence, review state, method, and evidence
- Seed Mentions with exact locators
- Entity Seeds, Assertion Seeds, Evidence Question Seeds, and Source Leads
- Seed Lineage Links
- Seed Confidence Profiles
- Seed Extraction Coverage Assessment
- Graph Match Candidates where bounded lookups were admitted

### 13.3 Readiness and report

`StarterReadinessAssessment` evaluates the exact package for declared downstream Workflow Types or purposes. It lists blockers, warnings, conditions, missing work, stale context, and freshness needs without creating one global package status.

The Decision Report records alternatives, failures, degradation, agent/tool use, repairs, unresolved questions, linked work, quality, and Improvement Candidates.

## 14. Completion and partial outcomes

The four shared terminal Workflow Run outcomes apply:

- `completed`: every required obligation satisfied
- `partially_completed`: required obligations satisfied and valid outputs exist, but declared degradable work failed or stopped
- `failed`: at least one required obligation remains unsatisfied
- `cancelled`: authorized cancellation terminated execution

A valid Starter Package may exist for `partially_completed`, `failed`, or `cancelled` runs if package invariants are satisfied. Output readiness is assessed separately.

A valid zero-seed result requires sufficient extraction coverage. Unexamined or unsupported content is unknown, not evidence of absence.

## 15. Temporal mapping

Recommended first mapping:

- one top-level refinement Temporal Workflow per Workflow Run
- StageGraph artifact branches as child workflows when they have independent cycles, waits, or cancellation; otherwise bounded branch activities
- GoalDirected iterations orchestrated by the top-level workflow with agent execution in activities
- model, MCP, sandbox, database, object-store, transformation, and evaluation work in activities
- approval and Repair Decisions through accepted application commands translated to Temporal Updates or Signals
- Continue-As-New for long branch, workflow-cycle, or goal-iteration history

Temporal does not own package, finding, seed, repair, or readiness semantics.

## 16. Persistence ownership

PostgreSQL owns:

- run lifecycle, command results, transitions, outbox events, links, dependency decisions, and budgets
- any bound Conversation/Thread references and operator approvals
- exclusive acceptance, rejection, and activation authority for Repair Decisions

MongoDB/Beanie owns document-shaped refinement records, including:

- Refinement Directive revisions
- Refinement Control Profile revisions
- Refinement Obligation Matrix revisions
- branch plans and branch execution detail
- Starter Findings and review records
- immutable repair proposal, evidence, and accepted-decision payloads referenced by the authoritative PostgreSQL command result
- Seed Mentions, Extracted Seeds, lineage, confidence, and coverage
- Starter Package metadata/manifests
- Starter Readiness Assessments
- Decision Report metadata

Large content, transformed representations, reports, snapshots, and promoted files live in object storage with immutable references.

No refinement record writes Neo4j.

## 17. API, commands, queries, and realtime events

Required command families include:

- start refinement
- revise allowed run controls
- approve/reject repair
- pause/resume/cancel branch or run
- accept/reject/defer linked result
- respond to continuation proposal
- fork from manifest, package, or snapshot lineage

Required query families include:

- run, branch, cycle, iteration, and obligation state
- current/stale findings and seeds
- package assembly state
- pending approvals
- linked runs and result-admission state
- budget and sandbox state
- output and readiness versions

Socket.IO emits authorized projection changes for these records using durable cursors. Token deltas and detailed agent progress may be ephemeral; accepted decisions and final outputs are durable.

## 18. Evaluation seams

Evaluation must separately cover:

- input/lineage and permission validity
- deterministic integrity-check correctness
- finding schema and evidence quality
- seed locator, typing, grouping, ambiguity, and coverage
- repair fidelity and supersession correctness
- dependency invalidation/staleness correctness
- package manifest and lineage correctness
- readiness calibration for downstream purposes
- GoalDirected progress and no-progress detection
- guest-affiliation identity disambiguation, source diversity, citation support, temporal qualification, and bounded-coverage accuracy
- Decision Report completeness

The highest practical test seam is a Workflow Run fixture with several artifact modalities, one corrupt artifact, one repair decision, one degradable branch failure, and one linked preflight result.

## 19. Remaining specification decisions

The workflow specification must still define:

- exact Pydantic/Beanie field schemas and indexes
- artifact role assignment and review policy
- integrity-check and finding-type catalogs
- exact default obligation matrix by modality
- repair acceptance thresholds and timeout fallbacks
- seed extraction inline-versus-linked thresholds
- StageGraph stage/branch retry and timeout defaults
- GoalDirected iteration, no-progress, verifier, and snapshot defaults
- event payloads and retention
- evaluation thresholds and benchmark fixtures

These choices may tune behavior. They may not weaken the invariants, change the two declared blueprint families, or turn refinement into hidden graph mutation or deep research.
