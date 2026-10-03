# Pre-Research Architecture Synthesis and Grill Entry Checkpoint

Date: 2026-07-18

Status: Working synthesis and interview-entry checkpoint

## Purpose

This checkpoint consolidates the current system-level and Workflow-Type-level architecture before the next `grill-with-docs` session.

It is intended to:

- establish the current accepted baseline without requiring another full reread of the checkpoint corpus
- distinguish accepted architecture from strong directions, open questions, and missing contracts
- normalize the active pre-research and Source Intelligence workflow catalog
- identify the decisions that must close before schema, model, service, event, API, issue, and implementation planning
- define the sequence and evidence standard for the next interview

This checkpoint does not accept new domain architecture by itself. Where it reconciles chronology, the later accepted special checkpoint and `CONTEXT.md` terminology govern over older unresolved catalog entries.

## Readiness Conclusion

The architecture is not yet ready for broad conversion into implementation specifications and tickets.

It is ready for:

- focused decision-closure interviews
- normalization of canonical Workflow Type names and boundaries
- completion of selected Workflow Type domain contracts
- narrow specifications for capabilities that independently pass the Architecture Readiness Gate

The corpus already has a strong backbone for:

- composable Workflow Types and independently valid Workflow Runs
- immutable run inputs, configuration bindings, outputs, and lineage
- application-enforced admission, invariants, policy gates, and authority
- separation of domain, Temporal, agent-session, sandbox, artifact, graph, and evaluation state
- governed provenance, permissions, budgets, workspaces, and graph promotion

It is still incomplete in several implementation-shaping areas:

- the universal run and intervention state model
- operation, dynamic delegation, and linked Workflow Run boundaries
- event, command, query, correlation, and idempotency contracts
- persistence ownership and transaction boundaries
- review and approval actor/state models
- Source Discovery and Source Corpus Build contracts
- Mission Specification scope and Mission Plan compilation
- Research Execution scheduling and convergence
- ingestion planning, commit, compensation, and post-commit validation

Producing broad issues before these close would make implementation agents invent product and policy decisions.

## Canonical System Baseline

### Composition

The system is a governed composition of independently valid Workflow Runs, not one fixed research pipeline and not one mega agent loop.

- A `Workflow Type` defines a reusable domain execution contract.
- A `Workflow Run` is one execution of exactly one Workflow Type.
- A `Knowledge Production Mission` coordinates linked Workflow Runs toward a bounded outcome.
- A mission may enter and exit at any admissible workflow boundary.
- A standalone run remains standalone even if a later mission references it.
- Crossing a Workflow Type boundary creates a distinct linked Workflow Run and `Run Composition Link`.
- A bounded semantic operation inside a run is not an inline Workflow Type.

### Launch and authority

- A human, service, dashboard, coordinator, or agent proposes a typed `Run Request`.
- The application control plane validates the request before durable execution begins.
- An agent recommendation does not satisfy an `Input Admission Contract`.
- A `Workflow Invariant` cannot be overridden by trust, permission, or human authority.
- Only a gate explicitly declared overridable may receive an audited `Policy Gate Override`.
- Dynamic instructions describe resolved authority but cannot grant it.
- Dynamically authored agents execute only after deterministic capability, budget, and delegation validation.

### Immutability and revision

The following are immutable or versioned historical bindings:

- `Run Input Manifest`
- Intake Brief version
- Mission Specification version
- Workflow configuration contract and Effective Run Configuration
- Operation Execution Binding
- accepted and rejected decision records
- workflow domain outputs
- artifact and package lineage
- source captures and derived representations
- graph observations and schema-version context

Material changes require an explicit revision, intervention, fork, or new run. Historical bindings are not rewritten.

### State separation

The architecture distinguishes:

- application domain and control-plane state
- Temporal execution history and durable timers
- OpenAI Agents SDK sessions and run state
- sandbox files and snapshots
- immutable artifact and object-storage state
- Source Intelligence operational records
- Source Corpus retrieval material
- Neo4j approved knowledge
- evaluation and learning records
- dashboard projections

None of these silently becomes another.

Temporal history is not the domain record. Agent-session state is not workflow authority. A sandbox snapshot is not an artifact store. Durable Source Intelligence is not implicit graph promotion. A UI projection is not state ownership.

### Runtime responsibilities

Current direction:

- application services own admission, policy, authority, semantic workflow rules, budgets, idempotency, and persistence projections
- Temporal owns durable lifecycle, retries, timers, signals, updates, cancellation, recovery, and linked execution coordination
- the OpenAI Agents SDK owns agent loops, profiles, tools, sessions, handoffs, streaming, and resumable agent execution
- sandbox providers supply isolated execution environments behind a project-owned adapter
- object storage owns large immutable payloads and promoted artifacts
- Neo4j owns approved graph knowledge
- agents access databases and durable stores through typed application tools rather than direct mutation

Exact framework topology remains downstream of domain-contract closure.

### Workspace model

- A Workflow Run owns a `Run Workspace Namespace`, not necessarily one sandbox.
- Shared inputs default to read-only.
- Parallel branches receive exclusive writable areas.
- Cross-branch exchange uses typed events or promoted artifacts.
- A `Workflow Workspace Contract` defines logical locations, access, ownership, slots, and promotion.
- A `Workspace Materialization Manifest` maps governed paths to durable inputs, local candidates, promoted outputs, or stale materializations.
- Workspace-local files do not become domain artifacts without explicit promotion.
- Sandbox snapshots support resume, debug, audit, and fork, but do not prove artifact or workflow reproducibility by themselves.

### Outcomes and readiness

Workflow execution outcome and output readiness are separate.

The generic run outcomes are:

- `completed`: required obligations completed
- `partially_completed`: valid outputs exist while declared degradable work failed
- `failed`: a required obligation was not completed

A completed output may still be unready for a particular downstream purpose. Consumer-specific admission and readiness policies decide use.

## Active Pre-Research Workflow Catalog

### Accepted and current

1. `StarterContentRefinementWorkflow`
2. `KnowledgePreflightWorkflow`
3. `MissionSpecificationWorkflow`
4. `ResearchSeedExtractionWorkflow`
5. `SchemaContextSelectionWorkflow`
6. `OfficialSourceMappingWorkflow`
7. `SourceDiscoveryWorkflow`
8. `SourceCorpusBuildWorkflow`
9. `SourceIdentityResolutionWorkflow`
10. `SourceMonitoringWorkflow`

These Workflow Types are independently runnable when their Input Admission Contracts permit. Their likely position before Research Execution is a composition tendency, not a fixed sequence.

### Canonical renames and supersessions

- `MissionInstructionWorkflow` is superseded by `MissionSpecificationWorkflow`.
- `EntitySeedExtractionWorkflow` is superseded by `ResearchSeedExtractionWorkflow`.
- `Research Mission` should not name the whole composition; use `Knowledge Production Mission`.
- `Source Intelligence Cache` is obsolete or too narrow; use `Source Intelligence`.
- `SchemaSelectionWorkflow` and `TargetSchemaSelectionWorkflow` should be normalized to `SchemaContextSelectionWorkflow` unless a later decision deliberately creates another boundary.

### Operation-versus-workflow distinctions already accepted

- bounded research-seed extraction is a `Research Seed Extraction Operation`
- broad, reusable, long-running, multimodal, or review-heavy extraction is `ResearchSeedExtractionWorkflow`
- bounded graph matching is `Supporting Graph Lookup`
- broad graph/knowledge coverage work is `KnowledgePreflightWorkflow`
- bounded source clarification is `Supporting Source Lookup`
- systematic procurement and coverage is `SourceDiscoveryWorkflow`
- bounded source identity work is a `Source Identity Resolution Operation`
- substantial reusable reconciliation is `SourceIdentityResolutionWorkflow`
- bounded freshness checks may be operations
- continuous or portfolio-scale change detection is `SourceMonitoringWorkflow`
- bounded obvious schema selection may remain an operation
- broad, ambiguous, expensive, reusable, or independently requested selection is `SchemaContextSelectionWorkflow`

The exact promotion thresholds are not yet fully specified.

## Workflow Baselines

### StarterContentRefinementWorkflow

Accepted purpose:

- clarify and inspect messy Starter Content
- validate lineage and applicable permissions
- classify package artifact references
- perform applicable integrity checks
- attempt clarification and provisional seed extraction
- optionally perform bounded supporting lookups or request linked work
- emit an immutable `Starter Package`, readiness assessment, and Decision Report

Accepted execution skeleton:

`Admission -> Branch Planning -> Artifact Refinement Branches -> Consolidation -> Optional Linked Work -> Package Assembly -> Readiness Assessment -> Reporting`

Accepted boundaries:

- a Starter Collection is mutable, but a run binds an immutable input snapshot
- a Starter Package must contain at least one captured artifact reference
- artifact-free intent proceeds through an Intake Brief or Mission Specification
- package inclusion and processing obligations are separate
- required and degradable obligations are explicit
- repair generation and repair acceptance are separate
- accepted replacement invalidates only affected descendants
- findings separate severity, confidence, review state, and downstream consequence
- provisional seeds are not authoritative graph knowledge or accepted research instruction

Still needed:

- exact admission schemas
- integrity and obligation catalogs
- branch, finding, repair, staleness, and package event contracts
- retry, timeout, cancellation, resume, and fork semantics
- complete Refinement Control Profile schema
- evaluation and Decision Report schema

### KnowledgePreflightWorkflow

Accepted purpose:

- observationally inspect existing entities, knowledge, prior work, graph coverage, contradictions, gaps, and unresolved identities
- emit an immutable `Knowledge Preflight Snapshot`

Accepted boundaries:

- it is broader than a database lookup
- it is not identity resolution
- it cannot mutate the canonical graph
- any proposed graph repair or enrichment creates a separate linked ingestion or maintenance run
- freshness is purpose-specific rather than a global TTL

Still needed:

- admission and query-plan schemas
- retrieval modality and result-envelope contracts
- match and coverage vocabularies
- graph/schema revision relevance
- stage and partial-completion model
- evaluation profile
- exact workspace, controls, and events

### MissionSpecificationWorkflow

Accepted purpose:

- transform accepted intake intent, packages, preflight context, existing knowledge, and operator decisions into a validated Mission Specification proposal

Accepted boundaries:

- a Mission Specification is not raw conversation, an Intake Brief, a Mission Direction Proposal, or a Mission Plan
- proposal authorship and acceptance authority are separate
- every Knowledge Production Mission requires an accepted specification
- standalone Workflow Runs do not require a mission
- revisions create new versions and a `Specification Impact Assessment`
- completed runs retain their historical specification bindings

Still needed:

- whether the specification is outcome-polymorphic across research, ingestion, content, evaluation, and experience work
- exact common and outcome-specific sections
- validation and acceptance state model
- relationship to Mission Plan compilation
- revision/intervention commands and events
- risk-sensitive acceptance defaults
- workflow-specific controls, evaluation, and partial outcomes

### ResearchSeedExtractionWorkflow

Accepted purpose:

- extract provisional research-starting signals from governed subjects

Accepted seed families:

1. Entity Seed
2. Assertion Seed
3. Evidence Question Seed
4. Source Lead

Accepted boundaries:

- the prior entity-only workflow name is superseded
- the workflow does not resolve entity identity
- an Assertion Seed is not an accepted fact
- a Source Lead is not automatically selected, captured, or admitted
- bounded supporting graph and source lookups do not establish broad coverage
- the workflow cannot write the graph
- zero seeds may be valid only when coverage is sufficiently assessed
- completion does not imply universal downstream readiness

Accepted input and output direction:

- `Research Seed Extraction Brief`
- immutable `Extraction Subject Manifest`
- Seed Mentions with exact locators
- typed immutable Extracted Seeds
- seed lineage for revisions, splits, and merges
- multidimensional confidence profiles
- coverage and unresolved-region assessment
- purpose-bound use-readiness assessment
- Decision Report

Still needed:

- exact standalone promotion policy
- internal stage and operation model
- required/degradable modality and coverage rules
- persistence and event schemas
- review and confidence-calibration policy
- retry, resume, partial-completion, and checkpoint behavior

## Source Intelligence Workflow Family

### Canonical ontology

The source and provenance model distinguishes:

`Source Origin -> Source Work -> Source Work Version -> Source Representation -> Source Snapshot -> Derived Representation`

The provenance spine may then connect locators, chunks, Assertions, Adjudications, approved knowledge, Curated Content, component bindings, and rendered experiences.

This is a typed graph, not a mandatory fabricated chain. A mutable official page may be captured without inventing a Source Work or Work Version.

Critical distinctions:

- a URL is a locator or access path, not the whole source identity
- identical bytes acquired from different origins or times remain distinct Source Snapshots
- a Source Candidate is a purpose-bound proposal, not a selected or authoritative source
- a Source Collection is mutable and selection-oriented
- a Source Collection Snapshot is an immutable membership view
- a Source Corpus contains captured and admitted retrieval material
- successful capture does not imply collection inclusion or corpus admission
- corpus admission does not imply research or ingestion selection
- research selection and ingestion selection are separate decisions
- Source Intelligence operational durability does not imply Neo4j promotion

### OfficialSourceMappingWorkflow

This is the most fully specified Source Intelligence workflow.

It:

- accepts provisional or canonical mapping subjects
- finds and verifies purpose-, relationship-, claim-class-, temporal-, geographic-, and jurisdiction-scoped official relationships
- preserves target-layer precision and unresolved identity
- separates candidates, evidence, confidence dimensions, verification decisions, and verified relationships
- uses risk-sensitive independent or human review
- registers discovered Source Candidates without creating a collection or corpus
- does not imply scientific authority or graph mutation

### SourceDiscoveryWorkflow

Accepted purpose:

- systematic source procurement against declared requirements, diversity, coverage, budget, and stopping conditions

Accepted primary output:

- immutable `Source Collection Snapshot`
- membership decisions
- candidates and identity state
- provider and BellLabs ranking evidence
- coverage, diversity, gap, and stopping assessments
- Decision Report

Still needed:

- exact Source Discovery Brief and target schemas
- common internal/external retrieval-result envelope
- source-class, evidence-role, diversity, and freshness requirements
- ranking and reranking contracts
- coverage matrix and valid zero-result rules
- stopping and continuation policy
- acquisition evidence allowed during discovery
- review, evaluation, events, and partial outcomes

### SourceCorpusBuildWorkflow

Accepted purpose direction:

- turn selected source material into captured, transformed, evaluated, admitted, and retrievable corpus material under a purpose-bound corpus contract

Accepted boundary:

- every prospective member receives an immutable `Corpus Admission Decision`
- collection inclusion or successful acquisition does not imply corpus membership

Still needed:

- corpus identity and versioning
- corpus contract schema
- capture and acquisition stages
- canonical transformation and fidelity rules
- locator validation
- canonical segmentation and chunk identity
- embedding and index ownership/versioning
- build repair and partial-completion semantics
- idempotent reprocessing keys
- retention and removal semantics

These unresolved decisions block safe implementation of canonical chunks and retrieval indexes.

### SourceIdentityResolutionWorkflow

Accepted boundary:

- narrow deterministic or bounded identity work remains inside a consuming workflow
- substantial, reusable, independently requested, or cross-workflow reconciliation receives its own Workflow Run

The detailed input, candidate, decision, evidence, review, freshness, and output contracts remain to be designed.

### SourceMonitoringWorkflow

Accepted boundary:

- bounded freshness checks may remain operations
- continuous or portfolio-scale change detection is a first-class Workflow Type
- monitoring observes and proposes follow-up; it does not silently recapture, rebuild, re-adjudicate, re-ingest, or overwrite

The monitored-subject portfolio, trigger/schedule, observation, impact, event, and linked-refresh contracts remain to be designed.

### No additional accepted Source workflow

The following should initially remain operations or scoped decisions unless later evidence justifies another Workflow Type:

- source registration
- ordinary acquisition/capture
- conversion, OCR, and table extraction
- ranking and reranking
- collection edits
- corpus admission
- segmentation and indexing inside Corpus Build
- Research Source Selection
- Ingestion Source Selection
- citation formatting

Candidate future types such as provenance validation, provenance repair, source collection maintenance, acquisition, or processing are not accepted current Workflow Types.

## Schema Context and Workspace Baseline

Accepted pipeline:

`Schema Definition -> Schema Catalog -> Schema Selection Context -> Schema Context Selection -> Schema Selection Review -> Expanded Schema Slice -> Schema Operation Projection -> Schema Workspace`

Accepted decisions:

- the versioned Neo4j GraphQL SDL is the authoritative schema source for generated agent resources
- the generated Schema Catalog preserves the source definition version/hash
- live database introspection is a compatibility check, not the versioned source of truth
- modules are overlapping navigation and retrieval views, not bounded contexts or ownership partitions
- retrieval proposes high-recall candidates; semantic selection remains explicit
- every agent-produced selection receives independent semantic coverage review
- expansion and operation projection are deterministic and cannot add semantic membership
- selections are immutable, versioned, purpose-bound, and tied to one schema version
- obvious bounded selection may remain an operation
- broad, ambiguous, reusable, expensive, or review-heavy selection is a standalone Workflow Type
- Schema Workspace files are run materializations rather than canonical schema state

Still needed:

- the deployed-schema compatibility record and policy
- authoritative schemas for brief, selection, review, expansion, projection, and manifests
- Schema Catalog MCP/API contract and cost limits
- source-of-truth relationship between monolithic SDL and modular TypeScript definitions
- schema exploration versus selection boundary
- post-report graph-comparison ownership
- persisted model and event ownership
- selection evaluation datasets and gates

## Universal Workflow Type Specification Contract

Before a Workflow Type is considered ready for `to-spec`, its checkpoint should define:

1. purpose, non-goals, owner, and canonical terminology
2. actors, callers, authorities, and standalone/mission-owned use
3. accepted input variants and immutable Run Input Manifest
4. Input Admission Contract
5. Workflow Invariants and overridable policy gates
6. required, degradable, optional, and prohibited obligations
7. stages, branches, operations, joins, and completion semantics
8. operation-versus-linked-workflow promotion rules
9. outputs, schemas, lineage, versions, staleness, and readiness
10. provenance and permission requirements
11. deterministic, agentic, independent-review, and human-approval boundaries
12. agentic configuration, effective controls, execution bindings, and delegation ceiling
13. workspace contract, materialization, promotion, and snapshot behavior
14. budget, concurrency, continuation, stopping, and degradation behavior
15. retry, timeout, cancellation, resume, fork, repair, and partial-result behavior
16. commands, queries, events, interventions, correlation, and idempotency
17. evaluation profile, Decision Report, and improvement-candidate lifecycle
18. persistence ownership, external effects, transaction boundaries, and retention
19. API and operator-dashboard visibility
20. highest practical testing seam

Passing this contract does not require framework-specific implementation details. It requires enough domain specificity that framework mapping does not invent behavior.

## Decision Status Ledger

### Settled

- composable Workflow Types and independently valid Workflow Runs
- Knowledge Production Mission rather than a mega-run
- immutable manifests, configuration bindings, outputs, decisions, and lineage
- application-enforced admission and invariants
- separate operation and linked-run concepts
- linked Workflow Run promotion as the default response when an operation exceeds its declared envelope
- parent-Workflow-owned Operation Boundary Escalation Policy, with coordinator choice or human intervention only when explicitly permitted
- separate domain, runtime, session, workspace, artifact, source, corpus, graph, and learning state
- sandbox promotion boundary
- capability-specific permissions
- multidimensional budgets
- provenance spine
- Neo4j mutation only through governed ingestion planning and execution
- Source Collection and Source Corpus separation
- schema catalog, semantic selection, independent review, and deterministic expansion
- current renames for Mission Specification and Research Seed Extraction

### Strong direction but not closed

- two explicit agent composition primitives: bounded delegation and linked Workflow Run request
- FastAPI command/query application services
- durable event projections for dashboard streams
- project-owned sandbox adapter
- PostgreSQL/Supabase for relational control-plane and session concerns
- purpose-bound Source Corpus Build ownership of canonical segmentation, chunks, embeddings, and indexes
- evaluation as a family of workflow-specific contracts

### Open

- universal Workflow Run lifecycle and transition authority
- workflow-specific escalation thresholds and parent-child lifecycle semantics
- event and intervention contracts
- persistence strategy for flexible runtime records
- Source Discovery detailed contract
- Source Corpus Build detailed contract
- Mission Specification outcome scope and Mission Plan compilation
- Research Execution scheduler and convergence
- ingestion identity, transaction, idempotency, compensation, and validation
- schema compatibility protocol
- independent and human review state model

### Missing

- shared error taxonomy
- common correlation and idempotency-key protocol
- concurrency, locking, and lease policy
- event versioning and replay guarantees
- tenancy, ownership, retention, deletion, secret, and audit-access policies
- aggregate and transaction-boundary map
- shared evaluation-result and Decision Report schemas
- exact operator intervention vocabulary

## Next Grill Sequence

The next interview should proceed as decision packets rather than attempting to design all schemas at once.

### Packet A: Catalog and workflow-boundary normalization

Close:

- active Workflow Type inventory
- historical names and aliases
- operation versus dynamic delegation versus linked Workflow Run
- parent/child wait, detach, cancellation, budget, and output-synthesis semantics

### Packet B: Source Discovery and Source Corpus authority

Close:

- discovery requirements, target, ranking, diversity, coverage, and stopping contracts
- valid zero-result discovery
- capture and collection boundaries
- corpus contract, identity, versioning, admission, transformations, canonical chunks, embeddings, and indexes

### Packet C: Universal run control plane

Close:

- Run Request and Workflow Run state machines
- gates, approvals, waits, interventions, revisions, cancellation, resume, and fork
- durable events versus telemetry
- idempotency, concurrency, and reconciliation

### Packet D: Mission Specification and Mission Plan

Close:

- universal versus research-only specification
- common and outcome-specific sections
- validation and acceptance
- compilation into a Mission Plan
- revision impact on planned, active, and completed runs

### Packet E: Research and evidence execution

Close:

- Research Execution modes and branch contract
- source and evidence coverage
- scheduler, cycles, contradiction handling, convergence, and stopping
- adjudication and report boundaries

### Packet F: Ingestion and schema compatibility

Close:

- report-to-graph comparison ownership
- Graph Candidate and Ingestion Plan contracts
- identity-resolution authority
- schema compatibility
- ordered graph/artifact commits, idempotency, compensation, and post-commit checks

### Packet G: Software-interface mapping

Only after the applicable domain packets pass readiness:

- persisted schemas and indexes
- service and module ownership
- Temporal workflow/activity topology
- Agents SDK agent, tool, session, and sandbox mappings
- command/query APIs
- event/WebSocket contracts
- operator-dashboard projections
- tracer-bullet implementation plan

## Accepted Interview Decision: Operation Boundary Escalation

When a bounded semantic operation exceeds its declared envelope:

1. promotion to a distinct linked Workflow Run is the default
2. the parent Workflow Type owns a versioned `Operation Boundary Escalation Policy`
3. that policy may permit an authorized Run Control Revision that enlarges the current operation
4. that policy may delegate a bounded dynamic choice to the coordinator agent
5. that policy may require Human In The Loop intervention
6. absent an explicit permission, the coordinator may propose but may not authorize silent expansion

Every resolution creates an immutable `Operation Boundary Escalation Decision` containing:

- observed threshold conditions
- alternatives allowed by the parent Workflow Type
- selected action
- deciding authority
- rationale
- budget and capability consequences
- resulting Run Control Revision or Run Composition Link
- effects on existing partial outputs and downstream obligations

Prior execution retains its original Operation Execution Bindings. Enlarging an operation affects only future or explicitly invalidated work.

This is a constrained dynamic model. It does not grant unrestricted coordinator discretion through prompts or general agent configuration.

## Accepted Interview Decision: Run Dependency Classes

Every parent request for a linked Workflow Run assigns one explicit `Run Dependency Class`:

1. `required_blocking`: the parent waits and cannot complete its affected obligation without admitting an acceptable child result
2. `degradable_blocking`: the parent waits until the child completes, fails, is cancelled, or reaches a governed timeout, then may continue only through explicit degradation behavior
3. `degradable_nonblocking`: the parent may complete without the child result while preserving the link and any declared later-admission behavior
4. `detached_advisory`: the child may continue independently and its result is outside the parent run's completion contract

The class is declared by the parent Workflow Type's composition contract and selected under its effective configuration when the linked run is requested. It does not alter the child Workflow Type's standalone admission, lifecycle, output, or evaluation contract.

Waiting and completion behavior must not be inferred from child status or improvised by the coordinator.

## Accepted Interview Decision: Run Dependency Revision

An assigned Run Dependency Class may change only through an authorized, immutable `Run Dependency Revision`.

The revision:

- preserves the original and intervening dependency classes
- records the requesting and deciding authority
- follows the parent Workflow Type's declared revision policy
- records why the original dependency no longer expresses the parent obligation
- cannot retroactively change the child Workflow Type's standalone contract
- assesses parent obligations, promoted artifacts, assembled outputs, readiness, and evaluation conclusions
- invalidates, restricts, or reevaluates affected parent results where necessary

A coordinator may propose or authorize the revision only to the extent explicitly delegated by the parent Workflow Type. A revision cannot exist merely to bypass a blocked required obligation.

## Accepted Interview Decision: Dependency-Aware Cancellation

Cancellation follows the parent Workflow Type's versioned `Run Cancellation Propagation Policy`.

Default behavior:

- parent cancellation requests cancellation of `required_blocking` and `degradable_blocking` child runs
- `degradable_nonblocking` and `detached_advisory` child runs follow their declared continuation policy and may outlive the parent
- cancellation is a governed lifecycle request, not an assumed process kill
- child cancellation, failure, or timeout never automatically reverse-cancels the parent
- the parent resolves child termination according to the assigned Run Dependency Class
- a required child termination may cause parent failure, pause, repair, dependency revision, or fork according to the parent contract
- a degradable child termination produces explicit degradation behavior rather than implicit success
- authorized policy or human intervention may override the default where the Workflow Type permits it

The exact Temporal cancellation mapping remains an implementation concern downstream of this domain policy.

## Accepted Interview Decision: Linked Run Result Admission

Every exact child output requires an immutable parent-side `Linked Run Result Admission Decision` before it may satisfy a parent obligation or influence a parent output.

The decision records:

- exact child run and output versions
- declared parent obligation or use
- compatibility with the parent's bound specification, schema, configuration, provenance, and permissions
- child outcome, readiness, and relevant evaluation evidence
- decision outcome: `admit`, `conditionally_admit`, `reject`, or `defer`
- deciding policy or authority
- conditions, restrictions, rationale, and affected parent work

Deterministic policy may automatically issue the decision when the parent Workflow Type declares sufficient conditions. Other cases may be delegated to the coordinator or require independent or human review.

Child completion alone never mutates the parent, satisfies an obligation, or copies an output into the parent workspace.

## Accepted Interview Decision: Late Linked Results

A terminal Workflow Run and its outputs are never mutated by a child result that arrives later.

The late output:

- remains an independently valid child Workflow Run output
- remains connected through its Run Composition Link
- may receive evaluations or readiness assessments under the child contract
- cannot retroactively satisfy the terminal parent's obligations
- cannot create a successor parent output version from the terminal run

Incorporation requires a new reconciliation, refinement, or other applicable Workflow Run whose immutable Run Input Manifest explicitly admits:

- the exact prior parent output
- the exact late child output
- the purpose and authority for producing a successor

The new run preserves derivation lineage to both. This protects terminality and replay while retaining the value of late work.

## Accepted Interview Decision: Linked Run Budget Reservation

Every parent-funded linked Workflow Run receives a distinct Budget Envelope funded through an explicit `Linked Run Budget Reservation` from its parent or governing mission envelope.

The reservation is multidimensional and may independently constrain:

- actual currency spend
- input tokens
- output tokens
- elapsed time
- semantic or agent cycles
- concurrency
- total tool calls
- calls to a particular MCP server
- calls to a particular MCP server tool
- calls or quotas for another external service
- pages, documents, artifacts, or other workflow-specific units

The child:

- records its own consumption and reservations
- rolls consumption up to governing envelopes
- cannot exceed delegated hard ceilings by creating nested work
- cannot silently borrow unused capacity from another dimension
- may use policy-declared conversions or reallocations only through an auditable control decision

Detached work may receive a new explicit sponsor or mission allocation. Sponsorship transfer does not rewrite its original request, lineage, or prior consumption.

## Accepted Interview Decision: Budget Reservation Lifecycle

A linked run cannot automatically borrow unreserved capacity from its parent or mission envelope.

At a soft threshold, it may emit a `Continuation Proposal` requesting:

- unchanged continuation within remaining dimensions
- additional reservation
- reallocation among dimensions where policy permits conversion
- reduced effort
- skipped degradable work
- termination

The proposal requires deterministic policy, delegated authority, or human authorization under the governing Workflow Type. Acceptance creates an auditable budget or control revision.

At a hard cap, the child cannot continue the affected work by itself. Its Workflow Type defines whether exhaustion causes:

- a durable pause awaiting authorized revision
- explicit degradation
- cancellation of affected work
- failure of a required obligation

At terminal settlement, actual consumption remains charged and unused reserved capacity returns to the governing envelope. External charges or in-flight reservations that are not yet final remain explicitly pending rather than being released optimistically.

## Accepted Interview Decision: Linked Run Authority Resolution

A linked Workflow Run's Effective Run Configuration and Execution Capability Profiles are constrained by the intersection of:

- the child Workflow Type's allowed contract
- the parent's delegation ceiling
- the requesting caller's authority
- applicable data-access rules
- Permission Assessments for the exact child uses
- approved mission and run overlays
- credential and environment policy

The intersection is deterministic and recorded.

A capability being supported by the child Workflow Type, model deployment, MCP server, sandbox, or backend does not grant it to the invocation. Missing authority causes explicit escalation, independent approval, reduced-capability execution, or admission denial according to policy.

Parent credentials and capabilities never propagate automatically. A prompt, dynamic instruction, or coordinator choice cannot enlarge authority.

## Accepted Interview Decision: Linked Run Request Identity

Linked-run creation is idempotent through a parent-scoped `Linked Run Request Identity`.

It combines:

- parent Workflow Run identity
- declared composition request slot or obligation intent
- immutable request revision
- target Workflow Type and version
- payload fingerprint covering the proposed Run Input Manifest, controls, dependency class, budget reservation, and authority request

Temporal retries, coordinator retries, message redelivery, and recovery replay reuse the same identity and return the existing request or child run.

A material change creates a new request revision or logical identity according to the parent Workflow Type's composition contract. Reusing an identity with a conflicting payload is rejected rather than silently deduplicated.

Matching content in:

- another parent run
- another obligation slot
- another mission purpose
- an independently requested standalone run

does not establish the same request identity. Reuse of an existing result is a separate input-admission decision, not run-creation deduplication.

## Decision Packet A Status

The foundational composition packet now has accepted direction for:

- operation-boundary escalation
- coordinator and Human In The Loop authority
- four Run Dependency Classes
- dependency revisions
- dependency-aware cancellation
- explicit child-result admission
- late-result handling
- multidimensional child budget reservation and settlement
- linked-run authority intersection
- idempotent linked-run creation

Workflow-specific thresholds, timeout values, event schemas, and framework mappings remain later specification work.

## Accepted Interview Decision: Source Discovery Coverage Matrix

Source Discovery uses a versioned, machine-enforceable `Source Discovery Coverage Matrix`.

The matrix spans applicable combinations of:

- exact Discovery Targets
- evidence roles
- source classification dimensions
- claim classes
- populations
- mechanisms, interventions, and outcomes
- jurisdictions and geographies
- temporal scope and freshness
- required or desired obligation status

Each applicable cell preserves:

- required coverage or stopping condition
- attempted search tactics and provider context
- considered candidates and membership decisions
- positive results
- explicit gaps and valid zero-result findings
- inaccessible, unsupported, failed, excluded, or unresolved work
- effort and budget consumption
- stopping evidence

Aggregate source counts, provider counts, URL counts, or distinct-domain quotas may be diagnostics but cannot establish coverage.

## Accepted Interview Decision: Constrained Workflow Execution Blueprint

The accepted workflow designs repeatedly use:

- application-owned stages
- dependency and join rules
- bounded cycles
- stage or run goals
- required and degradable obligation matrices
- explicit stopping and convergence conditions

These are represented through a shared, versioned, declarative `Workflow Execution Blueprint` meta-model.

The blueprint may encode:

- stages and stage goals
- dependencies and joins
- permitted parallelism
- bounded cycles
- typed obligation references
- stopping and convergence conditions
- escalation slots
- required output slots

Shared `Workflow Obligation Matrix` machinery may apply domain-specific Processing Obligations across relevant subjects, stages, scope dimensions, or coverage cells.

The blueprint does not replace:

- Input Admission Contracts
- Workflow Invariants
- authority and permission decisions
- domain-specific evidence and identity semantics
- typed output construction
- readiness and evaluation contracts

Workflow-Type application code and schemas retain those meanings. Agents may operate within a blueprint but cannot author unvalidated topology during execution.

This is deliberately not a fully generic workflow DSL.

## Accepted Interview Decision: Immutable Workflow Blueprint Binding

Every Workflow Run binds one exact Workflow Execution Blueprint version through an immutable `Workflow Blueprint Binding`.

The binding may select declared variants at launch. During execution, authorized controls may:

- activate or skip branches where the blueprint declares that choice
- select declared obligation variants
- repeat a declared bounded cycle
- trigger a declared escalation slot
- degrade work where the blueprint and obligation policy permit it

Controls may not add or rewire:

- stages
- dependencies or joins
- cycle topology
- output slots
- undeclared escalation paths

A structural change requires a fork or new Workflow Run bound to a new blueprint version. Prior outputs and completed operations remain linked as historical inputs where the new run admits them.

## Accepted Interview Decision: Bounded Discovery Matrix Revision

A Source Discovery run binds an immutable baseline Source Discovery Coverage Matrix.

Newly discovered leads or gaps may create a versioned `Workflow Obligation Matrix Revision` only when:

- the bound Workflow Execution Blueprint declares the expansion rule
- the new cell is within declared target, relationship, depth, scope, and budget ceilings
- the revision preserves the triggering evidence and rationale
- the deciding policy or delegated authority is recorded
- prior matrix versions remain historical

The revision may add or reconsider cells but does not mutate the Source Discovery Brief, Run Input Manifest, or blueprint.

Material expansion beyond declared ceilings requires:

- a Continuation Proposal with authorized scope and budget change where the existing blueprint already permits that class of expansion
- a linked Workflow Run
- a fork
- or a new run

Budget remaining by itself does not authorize the coordinator to expand discovery scope.

## Accepted Interview Decision: Valid Zero-Source Discovery

A zero-source result is valid only as one or more evidence-backed `Zero-Source Discovery Findings` attached to exact coverage cells.

Each finding records:

- exact target and coverage obligation
- search tactics, providers, queries, filters, and relevant ranking context
- source classes and evidence roles examined
- temporal, geographic, jurisdictional, and freshness scope examined
- leads followed and bounded expansion performed
- excluded results and reasons
- inaccessible, permission-restricted, unsupported, or failed search paths
- unresolved leads
- stopping conditions and evidence
- whether the result supports likely absence or only bounded non-discovery

Every applicable required cell must either:

- satisfy its positive coverage condition
- produce a sufficiently supported zero-source finding where zero is valid
- or reach an explicitly allowed unresolved outcome

An unmet required cell causes failure of the affected required obligation. Unresolved degradable cells permit `partially_completed` when valid outputs remain. Budget exhaustion or coordinator confidence alone cannot establish a valid zero-source result.

## Accepted Interview Decision: Discovery Evidence Capture

Source Discovery may perform permission-checked `Discovery Evidence Capture` when an immutable observation is needed to support:

- source identity or layer precision
- classification
- ranking or reranking evidence
- collection inclusion, exclusion, or unresolved decisions
- stopping evidence

The capture creates a normal immutable Source Snapshot with its acquisition path, time, content identity, permissions context, and exact discovery purpose.

It does not imply:

- Source Collection inclusion
- Corpus Admission
- corpus-grade normalization or fidelity acceptance
- canonical chunks, embeddings, or indexes
- Research Source Selection
- Ingestion Source Selection
- graph promotion

Source Corpus Build may later admit and reuse the exact snapshot when its own contract permits, or acquire another representation or capture. It must not treat the existence of a Discovery snapshot as automatic admission.

## Accepted Interview Decision: Dual-Evidence Retrieval Envelope

Every external or internal retrieval result is preserved as a `Source Retrieval Observation`.

The common observation envelope records:

- provider or internal retrieval system
- request, query, filters, and scope
- provider-native identifier
- provider-native rank and score
- engine, index, dataset, or API version where available
- retrieval time
- access path and result locator
- raw metadata or response artifact references
- coverage cells and tactics that produced the observation

BellLabs then attaches separate:

- source-layer and identity hypotheses
- Source Classification Profile
- purpose-bound relevance assessment
- reranking signals and rationale
- confidence
- permission and access assessment
- Source Collection Membership Decision

Provider-native evidence is never overwritten by BellLabs assessment. Scores from heterogeneous systems are not collapsed into one universal source score.

## Accepted Interview Decision: Provisional Candidate Aggregation

Every Source Retrieval Observation remains immutable and independently attributable.

Observations may be associated through explicit, immutable `Source Identity Hypotheses` that propose:

- same or different Source Origin
- same or different Source Work
- same or different Source Work Version
- same or different Source Representation
- same or different Source Snapshot

Each hypothesis preserves:

- exact observations and referents
- proposed source-layer relationships
- supporting and opposing evidence
- alternative hypotheses
- confidence and method context
- unresolved layers

URL equality, redirects, metadata identifiers, reciprocal links, and content hashes may support a hypothesis but do not destructively merge records or settle every layer. Identical bytes preserve distinct acquisition and provenance occurrences.

A Source Candidate may reference the most precise currently supported referent or unresolved locator while preserving all contributing observations and identity uncertainty.

## Accepted Interview Decision: Bounded Discovery Identity Authority

Source Discovery may perform a Source Identity Resolution Operation and issue a bounded identity decision only when:

- the Source Discovery Workflow Type declares the applicable evidence threshold
- the decision is low-risk for the exact collection purpose
- the observations and candidate source layers are sufficiently bounded
- ambiguity does not materially affect classification, membership, provenance, permissions, or expected downstream use
- the decision is not disputed
- the result does not require substantial cross-source or cross-workflow reconciliation

Discovery preserves a Source Identity Hypothesis as unresolved or requests a linked `SourceIdentityResolutionWorkflow` when the work is:

- cross-source or cross-collection
- consequential
- reusable beyond the current purpose
- disputed or evidence-conflicted
- temporally or version-complex
- likely to change permissions or provenance interpretation
- above declared size, cost, duration, review, or confidence thresholds

The linked-run request follows the accepted escalation, dependency, budget, authority, cancellation, admission, and idempotency contracts.

## Accepted Interview Decision: Identity and Membership Are Independent

Source identity state and Source Collection membership are independent dimensions.

A Source Collection Membership Decision may:

- include an exact unresolved referent or Source Candidate with explicit conditions
- exclude a fully resolved source because it is irrelevant, redundant, stale, inaccessible, or unsuitable for the collection purpose
- leave membership unresolved for reasons unrelated to identity

Conditional inclusion preserves:

- the exact referent or locator actually known
- unresolved source layers
- identity hypotheses and alternatives
- restrictions on downstream use
- reconsideration triggers

It does not fabricate Source Origin, Work, Work Version, or Representation identity. Each downstream workflow independently decides whether the unresolved identity is admissible for its purpose.

## Accepted Interview Decision: Collection Membership Plus Decision Ledger

A Source Collection Snapshot freezes:

- exact effective members
- collection purpose
- governing Source Discovery Brief and requirements
- applicable Source Discovery Coverage Matrix version
- snapshot time and source collection revision context

It separately references:

- effective include decisions
- superseded membership decisions where relevant
- excluded candidates and decisions
- unresolved candidates and decisions
- all considered Source Candidates needed to explain coverage
- Source Retrieval Observations and Discovery Evidence Captures supporting decisions
- gaps, zero-source findings, and stopping evidence

Excluded and unresolved candidates are not represented as active members. They remain durable, queryable decision evidence rather than disappearing into workflow logs.

## Accepted Interview Decision: Durable Corpus Identity and Immutable Revisions

A `Source Corpus` is a durable, purpose-bound identity. Repeated Source Corpus Build runs create immutable `Source Corpus Revisions`.

Each revision is an exact manifest of:

- admitted Source Snapshots
- admitted Source Representations and Derived Representations
- Document and Media Artifacts
- canonical chunks and locators
- embedding and index artifacts
- connections
- transformation, segmentation, embedding, and indexing method versions
- Corpus Admission Decisions
- governing corpus-contract version
- build findings, failures, and exclusions

Downstream Workflow Runs bind exact Source Corpus Revisions rather than a mutable live corpus.

## Source Stability, Collection, and Corpus Picture

The architecture has three distinct layers.

### 1. Stable source and provenance records

These describe what the source is and what was observed:

`Source Origin -> Source Work -> Source Work Version -> Source Representation -> Source Snapshot -> Derived Representation`

They are not owned by one Collection or Corpus. They may be reused by many purposes while preserving exact provenance and permissions.

A Source Snapshot is an immutable acquisition occurrence. It is the stable bridge from a source referent to captured bytes or records.

### 2. Source Collection decision layer

A `Source Collection` is a durable, purpose-bound, mutable decision space.

It answers:

> Which source referents or candidates are relevant enough to include, exclude, or keep unresolved for this procurement purpose?

It can contain references to:

- resolved Source Origins, Works, Versions, or Representations
- unresolved source referents
- Source Candidates
- Source Leads admitted by the discovery brief

It does not require every member to be captured or processable.

Every important membership change is an immutable Source Collection Membership Decision. A Source Collection Snapshot freezes the exact effective membership and decision context at one time.

### 3. Source Corpus retrieval layer

A `Source Corpus` is a durable, purpose-bound body of captured and admitted retrieval material.

It answers:

> Which exact captured and processed materials are fit to make available for this retrieval or downstream purpose?

Its members are not live source referents. They are exact Source Snapshots and admitted processed representations with locators, chunks, embeddings, indexes, and transformation lineage.

Each Source Corpus Revision freezes one reproducible retrieval state.

### Connection

The normal connection is:

`Source Discovery Brief`

`-> Source Discovery Workflow`

`-> Source Collection Snapshot`

`-> Source Corpus Build Workflow`

`-> per-snapshot Corpus Admission Decisions`

`-> Source Corpus Revision`

The Source Collection Snapshot proposes the selected source universe. Source Corpus Build then acquires or reuses exact captures, evaluates permissions and fitness, transforms material, and independently decides corpus admission.

Collection inclusion never guarantees corpus admission.

### Cardinality

The relationship is not one-to-one:

- one Source Collection Snapshot may feed several Source Corpora with different purposes or processing contracts
- one Source Corpus Revision may admit material from several Source Collection Snapshots
- a Corpus Build may admit an explicitly provided Source Snapshot when its contract permits, without requiring that every input originate in one Collection
- one Source Snapshot may be admitted into several corpora under different contracts
- one Source Corpus may evolve through many immutable revisions

### Example

Suppose BellLabs is researching a supplement product.

Stable source records:

- Source Origin: FDA website
- Source Work: regulatory label record
- Source Work Version: January 2026 edition
- Source Representation: FDA-hosted PDF
- Source Snapshot: exact PDF captured on 2026-07-18

Collection:

- `Current regulatory evidence for Product X`
- includes the FDA label candidate
- excludes an SEO copy
- leaves an older mirrored label unresolved
- emits Collection Snapshot 4

Corpus:

- `Product X regulatory research corpus`
- Build admits the exact FDA PDF snapshot
- creates a method-bound text extraction and table representation
- creates locators and canonical chunks
- builds embeddings and retrieval indexes
- emits Corpus Revision 7

If FDA later issues a changed label:

- create a new Source Work Version or preserve an unresolved version hypothesis until established
- capture a new Source Snapshot
- issue new Collection membership decisions and Snapshot 5 where applicable
- run Corpus Build again
- emit Corpus Revision 8

Revision 7 remains reproducible and continues to explain historical research. Revision 8 does not rewrite it.

## Source Intelligence Follow-Up Scope

A dedicated Source Intelligence session should still close:

- durable identity and revision rules for Source Collections
- exact Source Corpus contract schema
- admissible direct inputs to Source Corpus Build
- corpus revision derivation, removal, and supersession semantics
- canonical transformation, locator, chunk, embedding, and index identity
- corpus admission requirements and conditional admission
- reuse versus reacquisition of Discovery Evidence Captures
- permissions, retention, deletion, and source withdrawal
- retrieval serving and index activation
- Source Monitoring impact on Collections, Corpora, and downstream outputs
- operational Source Intelligence storage versus Neo4j promotion

## Accepted Interview Decision: Multi-Axis Workflow Run Lifecycle

Workflow Run state is represented through separate domain axes:

1. **Lifecycle phase**: where the run is in its execution lifecycle
2. **Wait or pause reason**: why forward progress is durably suspended, when applicable
3. **Terminal execution outcome**: how the run satisfied or failed its execution contract
4. **Purpose-bound output readiness**: whether exact outputs may be consumed for a declared downstream use

These axes must not be collapsed into one status.

Consequences:

- a waiting run is not necessarily failed or degraded
- a completed run may emit an output that remains unready for a consequential use
- a terminated run may retain independently valid partial outputs
- resolving a wait does not by itself determine an execution outcome
- readiness may be reevaluated later without reopening or mutating the run
- Temporal execution state and history map to the domain lifecycle but do not define domain authority or meaning

## Accepted Interview Decision: Four Terminal Execution Outcomes

Workflow Run Outcome has four values:

1. `completed`: every required obligation reached its accepted completion condition
2. `partially_completed`: valid outputs exist and required obligations completed, but one or more declared degradable obligations did not
3. `failed`: one or more required obligations could not be satisfied
4. `cancelled`: authorized cancellation intentionally terminated the run before ordinary completion

Cancellation cause, timeout, budget exhaustion, supersession, and abandonment are recorded as reasons or related decisions rather than separate generic outcomes.

Valid partial outputs from a cancelled run remain immutable and may receive readiness or admission decisions. They do not change the execution outcome to `partially_completed`.

A rejected Run Request never creates a Workflow Run and therefore has no Workflow Run Outcome. Supersession is lineage between outputs, specifications, plans, or runs rather than an execution outcome.

## Accepted Interview Decision: Minimal Shared Lifecycle Phases

Every Workflow Run uses one of six domain lifecycle phases:

1. `pending`: the validated run exists but has not begun active execution
2. `active`: the run is able to make forward progress through its bound blueprint
3. `waiting`: progress is durably awaiting a declared condition
4. `paused`: progress is explicitly suspended by policy or authorized intervention
5. `cancelling`: authorized cancellation is being applied and effects are settling
6. `terminal`: execution has ended and exactly one Workflow Run Outcome is assigned

Detailed execution conditions such as:

- queued or scheduled
- agent or activity dispatch
- retry backoff
- worker unavailable
- recovery or replay
- compensation activity
- external API throttling

remain durable events, operational projections, or typed wait reasons where appropriate. They are not additional generic lifecycle phases.

## Accepted Interview Decision: Waiting Versus Paused

`waiting` and `paused` have distinct authority semantics.

### Waiting

- caused by one or more typed Workflow Run Wait Conditions declared by the bound blueprint
- may wait on dependencies, linked results, approvals, timers, resources, budget decisions, or external conditions
- records timeout and fallback behavior
- resumes affected work automatically when the condition is verifiably satisfied
- does not require a new authority grant merely to resume

### Paused

- caused by an immutable Workflow Run Pause Decision
- records policy or intervening authority, scope, reason, and reconsideration conditions
- may suspend the entire run or declared affected work
- does not resume merely because the apparent cause disappears
- requires an explicit authorized resume decision

## Accepted Interview Decision: Aggregate Run Phase From Runnable Work

The run-level lifecycle phase is derived from the state of its bound blueprint and currently admissible work.

- the run remains `active` while any stage, branch, or operation can make forward progress
- local Workflow Run Wait Conditions remain visible without forcing the entire run to `waiting`
- local pause decisions remain visible without forcing the entire run to `paused` when unaffected work may continue
- the run enters `waiting` only when no currently admissible work can progress and at least one unresolved wait condition can permit future progress
- the run enters `paused` only when an applicable pause decision prevents all otherwise admissible progress
- terminal, cancelling, and pending phases take precedence according to the lifecycle state machine

This aggregate projection does not hide per-stage, branch, operation, dependency, or obligation state.

## Accepted Interview Decision: Application-Owned Lifecycle Reducer

One application-owned Workflow Run Lifecycle Reducer validates and records domain lifecycle transitions.

Inputs may come from:

- deterministic application rules
- humans
- authorized coordinator agents
- specially authorized workflow agents or agent systems
- Temporal workflow execution
- activities and workers
- linked-run events
- external callbacks
- timers and resource monitors

Every source submits a typed command or observed fact. The reducer validates:

- current run and transition version
- bound Workflow Execution Blueprint
- current lifecycle phase
- Workflow Invariants
- transition preconditions
- policy and gate state
- actor identity and Lifecycle Transition Authority
- applicable budget, permission, and dependency state

Special agents or agent systems may receive named authority to decide or initiate particular transitions. They exercise that authority through the reducer, and the immutable transition record identifies them as the deciding actor.

No actor directly mutates lifecycle persistence, Temporal state, or projections. Temporal implements durable execution after or alongside accepted domain transitions; it is not the source of domain authority.

## Accepted Interview Decision: Optimistic Version and Idempotency

Every Workflow Lifecycle Command carries:

- stable command idempotency identity
- target Workflow Run
- expected run version
- requested transition
- actor and asserted authority context
- reason and evidence references
- command time and correlation context

The Workflow Run Lifecycle Reducer atomically:

1. checks whether the command identity was already accepted
2. returns the prior result for an exact duplicate
3. validates the expected run version
4. rejects or requires reevaluation of a stale conflicting command
5. validates transition and authority rules
6. records the accepted transition and advances the run version

Last-write-wins mutation is prohibited. Temporal serialization is useful within one execution but is not the system-wide concurrency boundary because commands may also originate from humans, services, linked runs, callbacks, and recovery processes.

## Accepted Interview Decision: Lifecycle Ledger Plus Current Projection

Every accepted lifecycle transition creates an append-only Workflow Lifecycle Transition Record.

The transition record preserves:

- Workflow Run and resulting version
- prior and resulting phase
- terminal outcome where applicable
- originating command identity
- actor and authority
- reason and evidence
- wait, pause, cancellation, or dependency references
- correlation and causation identities
- accepted time

The transition record and current Workflow Run projection are committed atomically.

The current projection supports efficient control-plane and dashboard queries. The immutable ledger supports:

- audit
- replay of the lifecycle projection
- conflict diagnosis
- reconciliation with Temporal
- recovery from projection corruption
- operator explanation

This is not a decision to event-source every artifact, output, package, source record, finding, or evaluation from one workflow stream. Those retain their own immutable/versioned domain models and transaction boundaries.

## Accepted Interview Decision: Transactional Outbox Publication

The authoritative transaction commits:

- Workflow Lifecycle Transition Record
- updated Workflow Run current projection
- one or more versioned Workflow Domain Event Envelopes in a transactional outbox

An asynchronous relay publishes pending envelopes to the configured event transport. Temporal coordinators, linked-run handlers, dashboard projectors, notification services, evaluation systems, and other consumers process them independently.

Each envelope preserves:

- globally stable event identity
- event type and schema version
- aggregate type, identity, and version
- occurrence and recording times
- actor
- correlation and causation identities
- typed payload or durable payload reference

The outbox row and event envelope are durable application records. Temporal history and SDK streams may correlate with them but do not replace them.

## Accepted Interview Decision: At-Least-Once Per-Aggregate Delivery

Workflow Domain Event delivery is at least once.

Consumers:

- deduplicate by stable event identity
- record durable consumer progress
- verify aggregate version order
- detect version gaps
- defer out-of-order application where necessary
- replay from durable cursors or authoritative records
- make side effects idempotent

There is no global ordering guarantee across unrelated aggregates or Workflow Runs. Aggregate version, event identity, correlation, and causation carry the required ordering and relationship context.

End-to-end exactly-once processing is not assumed. At-most-once notification is insufficient for control-plane, linked-run, evaluation, or durable projection consumers.

## Technology Decision: PostgreSQL Outbox Accepted, Broker Deferred

Status:

- PostgreSQL transactional authority and outbox: accepted direction
- durable broker requirement and transport-neutral boundary: accepted direction
- NATS JetStream versus Kafka: undecided pending scenario projection

### PostgreSQL application database

Use the application PostgreSQL database, including Supabase-hosted PostgreSQL where appropriate, for:

- Workflow Run current projections
- append-only Workflow Lifecycle Transition Records
- transactional outbox rows
- command idempotency records
- consumer inbox or applied-event records where application-level deduplication is required
- durable dashboard and API read models

The existing backend already has `asyncpg` and separate application PostgreSQL configuration. The authoritative transition, current projection, and outbox envelope should commit in one PostgreSQL transaction.

An outbox relay may claim rows with PostgreSQL row locking and `FOR UPDATE SKIP LOCKED`. `LISTEN/NOTIFY` may wake the relay for lower latency, but polling remains the correctness mechanism; notification delivery is not the durable event contract.

### Durable event broker

The durable event transport must support:

- persisted event streams
- durable consumer progress
- explicit acknowledgement or equivalent processing confirmation
- redelivery
- replay from durable positions
- independent consumer groups
- horizontal consumer scaling
- transport-level message identity
- observable lag and failed delivery

The Workflow Domain Event Envelope remains transport-neutral. Application-level idempotency and aggregate-version checks remain required regardless of broker features.

The choice between NATS JetStream and Kafka is intentionally deferred. Familiarity with Kafka is a material operational advantage and must be considered rather than treating broker selection as a feature checklist.

The decision requires scenario projection across:

- expected event volume and retention
- number and independence of consumer services
- replay and reprocessing patterns
- aggregate-key partitioning and ordering
- consumer lag and backpressure
- multi-region or cluster expectations
- schema governance
- local development and deployment burden
- operator familiarity and incident response
- managed-service versus self-hosted preference
- Python client maturity and observability
- whether the event platform will later carry non-workflow domain streams

### Temporal

Temporal remains the durable workflow-execution runtime.

Relevant event consumers translate accepted domain events into:

- Temporal Signals
- Updates
- workflow starts where an accepted Run Request requires one
- cancellation requests

Temporal history is not the inter-service event log or lifecycle authority.

### Dashboard delivery

Dashboard projectors consume durable events and update query projections.

Socket.IO emits low-latency projection-change hints carrying a durable cursor or aggregate version. A reconnecting dashboard reads the current projection and resumes from a durable cursor rather than relying on missed socket messages.

### Initial tracer-bullet option

The first vertical implementation may use:

- PostgreSQL transactional outbox
- one relay process
- direct in-process or service handlers
- Temporal translation
- dashboard projection plus Socket.IO hints

The event envelope and relay boundary remain transport-neutral so NATS JetStream or Kafka can be inserted without changing domain contracts.

This direct relay is an initial deployment option, not a decision to use PostgreSQL polling as the permanent inter-service broker.

### Technologies not recommended as the primary durable domain bus

- Temporal: execution runtime, not general event transport
- Socket.IO: live client delivery, not durable replay
- Supabase Realtime alone: useful projection notification, not the authoritative transactional event contract
- Redis Pub/Sub: non-durable
- global database polling by every consumer: couples consumers to control-plane storage and weakens service boundaries

## Primary Evidence

- `docs/CONTEXT.md`
- `docs/checkpoints/system-level/2026-07-15-workflow-catalog-agent-sandbox-and-system-state-special-checkpoint.md`
- `docs/checkpoints/system-level/2026-07-15-knowledge-production-composition-and-intake-checkpoint.md`
- `docs/checkpoints/system-level/2026-07-14-openai-agents-sdk--temporal-research-ingestion-evaluation-checkpoint.md`
- `docs/checkpoints/starter_content_refinement_and_packages/2026-07-15-starter-package-findings-permissions-and-repair-checkpoint.md`
- `docs/checkpoints/starter_content_refinement_and_packages/2026-07-15-starter-preflight-and-mission-specification-checkpoint.md`
- `docs/checkpoints/2026-07-17-research-seed-extraction-workflow-special-checkpoint.md`
- `docs/checkpoints/source_intelligence/2026-07-16-source-intelligence-and-provenance-spine-special-checkpoint.md`
- `docs/checkpoints/source_intelligence/2026-07-17-source-intelligence-source-workflows-and-provenance-profiles-special-checkpoint.md`
- `docs/checkpoints/source_intelligence/2026-07-17-official-source-mapping-workflow-special-checkpoint.md`
- `docs/checkpoints/schema_schema_workspaces_efficient_db_interaction/2026-07-16-large-schema-workspaces-selection-and-report-splitting-special-checkpoint.md`
- `docs/checkpoints/internal_implementation_docs/2026-07-16-belllabs-engineering-delivery-playbook-special-checkpoint.md`
