# BellLabs Biotech Backend Services Context

## Language

**BellLabs Biotech Backend Services**:
The backend services spanning sandbox agents, deep research, API surfaces, ingestion, and the governed definitions in this document—transforming biohacking, longevity, biotech, and avoidance-oriented starter content into research artifacts, graph knowledge, curated content, APIs, MCP servers, and agent skills. The Client Dashboard, MCP servers, and MCP-UI (planned) are part of this surface: ways to run services, inspect outputs, spin up playgrounds, and test features.

**Starter Content**:
Messy initial material used to begin research. It may include transcript folders, notes, prior summaries, PDFs, images, URLs, reports, screenshots, or manually written instructions. Starter Content is not authoritative.

**Starter Collection**:
A durable, operator-owned mutable collection of Starter Artifacts and intake intent that may exist before any Workflow Run. A run selects from it through an immutable input snapshot; the collection itself is not a Sandbox Workspace or workflow output.
_Avoid_: Starter Workspace, Sandbox Workspace, Starter Package

**Conversation**:
A durable container for related interaction among humans, coordinators, and sandboxed agents. It may contain forkable Conversation Threads with distinct participants or workflow scopes; it is not an agent-runtime session or Workflow Run.

**Conversation Thread**:
A forkable ordered sequence within a Conversation that preserves messages, tool interactions, results, approvals, participants, and optional workflow or sandbox scope. It supplies context and audit evidence but is not by itself an authoritative workflow instruction.
_Avoid_: Workflow state, Run Input Manifest, agent-runtime session

**Intake Brief**:
A versioned statement of accepted objective, scope, constraints, context, unresolved questions, and operator decisions distilled from a Conversation Thread. A run binds an exact brief version while retaining references to the supporting conversation turns.
_Avoid_: Raw conversation as instructions, chat summary

**Starter Content Refinement**:
The mini-workflow that clarifies Starter Content, checks integrity, extracts early seeds, may perform bounded supporting graph or source lookups, may request broader linked work, and emits a Starter Package.
_Avoid_: Broad Knowledge Preflight or systematic Source Discovery hidden inside refinement

**Refinement Directive**:
The typed scope and intent for a Starter Content Refinement run, supplied directly or derived from accepted intake context. A default directive permits standalone refinement without requiring a Conversation Thread or Intake Brief.

**Refinement Control Profile**:
A versioned set of refinement defaults for capabilities, models, branch obligations, budgets, concurrency, repairs, approvals, lookups, snapshots, and reporting. Each run preserves the selected version, validated overrides, and fully resolved effective configuration.

**Run Control Revision**:
An explicit, authorized change to a running Workflow Run's effective controls for future or affected work. Prior operations retain their original bindings, while material revisions may require invalidation, re-evaluation, or a fork.
_Avoid_: In-place historical config mutation

**Operation Boundary Escalation Policy**:
A Workflow Type's versioned rules for responding when a semantic operation exceeds its declared envelope. Promotion to a distinct linked Workflow Run is the default; the parent Workflow Type may additionally permit an authorized Run Control Revision, a policy-bounded coordinator decision, or human intervention, with explicit effects on obligations, budgets, authority, cancellation, and output admission.
_Avoid_: Unrestricted coordinator discretion, silent operation expansion

**Operation Boundary Escalation Decision**:
The immutable record of how an exceeded operation envelope was resolved, including the observed threshold conditions, permitted alternatives, selected action, deciding authority, rationale, and resulting control revision or Run Composition Link. An agent proposal is not authorization unless the governing policy explicitly delegates that decision.

**Operation Model Policy**:
A versioned rule for the allowed models, effort, fallback, and escalation of one semantic operation class. Each operation records its actual model, prompt, skill, and tool bindings rather than inheriting an unverifiable workflow-wide label.

**Workflow Agentic Configuration Contract**:
A Workflow Type's versioned declaration of permitted and default Agent Profiles, capabilities, workspace requirements, models, MCP servers, tools, skills, and instruction policies. Coordinator or UI configuration may propose typed overlays but cannot exceed this contract or grant authority through attached material.

**Effective Run Configuration**:
The fully resolved, validated binding of a Workflow Type's configuration contract and authorized run-specific overlays. Each version is preserved exactly; an authorized Run Control Revision creates a successor configuration for affected future work rather than rewriting prior execution.

**Operation Execution Binding**:
The immutable record of the actual Effective Run Configuration version, prompts, dynamic instructions, model, skills, tools, MCP connections, workspace, and capability authority used by one semantic operation. The exact boundaries and kinds of operations remain workflow-specific.

**Checkpointed Execution State**:
The Agent Server or LangGraph thread state, messages, interrupts, and runtime positions retained for execution continuity and resumption. It is a non-authoritative runtime projection rather than governed long-term Agent Memory.
_Avoid_: Agent Memory, lifecycle authority, short-term memory

**Agent Memory**:
Governed long-term reusable context managed through future procedural, episodic, or semantic memory profiles. It is distinct from Checkpointed Execution State and cannot silently become workflow authority or scientific evidence.
_Avoid_: Checkpointed Execution State, ungoverned LangGraph Store memory

**Agent Profile**:
A versioned logical agent configuration covering role, prompts and dynamic-prompt policy, models, MCP servers, tools, skills, guardrails, hooks or middleware, subagent policy, and workspace requirements. Each operation preserves the fully resolved profile and runtime bindings it actually used.

**Agent Delegation**:
A bounded transfer of work inside one semantic operation, either as a handoff that transfers active turn ownership or as a task subagent that returns scoped results. It remains subject to the operation's authority, budget, workspace, and Delegation Ceiling and does not create a Workflow Run.
_Avoid_: Linked Workflow Run, hidden durable scheduler

**Synchronous Subagent**:
An operation-local delegated agent that blocks its parent until it returns a scoped result through a governed result manifest.
_Avoid_: Asynchronous Subagent, Linked Workflow Run

**Asynchronous Subagent**:
An operation-local delegated agent that progresses on its own Agent Server thread and exposes durable launch, status, update, cancellation, reconciliation, and result-admission behavior without becoming a Workflow Run.
_Avoid_: Background task without a durable binding, Linked Workflow Run

**Agent Handoff**:
An Agent Delegation in which active operation ownership transfers to another exactly bound agent under the same operation authority and Delegation Ceiling.
_Avoid_: Synchronous Subagent, Linked Workflow Run

**Interpreter-Orchestrated Delegation**:
Programmatic invocation of configured Synchronous Subagents from a bounded interpreter, with explicit call, fan-out, depth, authority, budget, and result-admission limits.
_Avoid_: Dynamic Agent Definition, Asynchronous Subagent, Linked Workflow Run

**Dynamic Instruction**:
Run- or turn-specific instruction assembled by middleware, hooks, agents, or humans from authorized state and messages. It may describe resolved tools, skills, subagents, permissions, and workspace context but cannot itself grant authority.
_Avoid_: Prompt-granted capability

**Execution Capability Profile**:
The actor- and operation-specific authority to use shell, filesystem, browser, MCP, graph, source-cache, external API, subagent, and other runtime capabilities. Coordinator and workflow agents receive distinct profiles under shared policy.
_Avoid_: One universal agent tool profile

**Dynamic Agent Definition**:
An immutably recorded agent configuration authored at runtime, which may introduce novel roles, prompts, model policies, tool/MCP/skill combinations, workspace requirements, and delegation structures. It executes only after deterministic policy and capability validation.
_Avoid_: Template-only subagent, unrecorded ephemeral agent

**Delegation Ceiling**:
The maximum authority a governing Workflow Run and delegating agent may confer on a dynamically authored subagent. Dynamic authorship cannot use deployment availability to escalate tools, credentials, data access, permissions, or budget.

**Linked Run Authority Resolution**:
The deterministic derivation of a linked Workflow Run's effective authority from the intersection of its Workflow Type contract, the parent's delegation ceiling, caller authority, data and Permission Assessments, and approved run overlays. A capability available to the child type or deployment is not granted to the invocation when any governing ceiling withholds it; additional authority requires separate approval or escalation.
_Avoid_: Automatic parent credential propagation, child type as independent authority grant

**Budget Envelope**:
The hierarchical, multidimensional limits and reservations for a run, its branches, linked work, and operations, including soft thresholds and hard caps. Consumption may include currency, tokens, elapsed time, tool calls, pages, cycles, concurrency, and external-service quotas.
_Avoid_: Dollar-only budget, prompt-only budget

**Linked Run Budget Reservation**:
The explicit multidimensional allocation from a parent or mission Budget Envelope into a distinct linked run's Budget Envelope. Dimensions may constrain spend, input and output tokens, elapsed time, cycles, concurrency, total tool calls, and calls or quotas for particular MCP servers, MCP tools, or external services; unused capacity in one dimension does not silently offset another unless policy declares that conversion.
_Avoid_: Shared untracked parent-child spend, dollar-only child allocation

**Continuation Proposal**:
A typed response to a soft limit or convergence concern, proposing unchanged continuation, reduced effort, skipped degradable work, additional budget, or termination. Policy or delegated authority accepts it; the proposing agent cannot exceed hard limits by itself.

**Refinement Baseline**:
The default required work: validate lineage and permissions, classify references, run applicable integrity checks, attempt clarification and seed extraction, preserve findings, assemble package/readiness outputs, and emit a Decision Report. Repair, preflight, and supporting lookup are degradable unless the Refinement Directive makes them required.

**Artifact Refinement Branch**:
The independently progressing refinement work for one package artifact, with its own applicable operations, limits, findings, and outcome. Package-level consolidation proceeds across branches according to required and degradable policies.

**Refinement Stage Skeleton**:
The application-owned sequence of admission, branch planning, artifact work, consolidation, optional linked work, package assembly, readiness assessment, and reporting. Configuration may enable or degrade declared branches, while agent judgment does not silently invent dependencies or completion rules.
_Avoid_: Agent-invented workflow topology, single opaque agent loop

**Starter Package**:
An immutable, versioned, manifest-style durable output derived from one refinement Run Input Manifest and containing at least one captured artifact reference. Captured artifacts may be unusable, but lineage, references, and readiness must remain valid; artifact-free intent proceeds through an Intake Brief or Mission Specification instead.

**Package Derivation**:
A typed lineage relationship from a Starter Package to each prior package or artifact it reused, superseded, merged, split, or repaired. Package lineage may have multiple parents rather than pretending every refinement is a single chain.
_Avoid_: Single parent package version, untyped package copy

**Package Artifact Reference**:
The contextual intended use of an immutable artifact within a Starter Package, recording roles, rationale, ordering or grouping, and required or optional inclusion. Inclusion does not imply that every attempted parse, transformation, or extraction must succeed.
_Avoid_: Global artifact role, copied package artifact

**Processing Obligation**:
A named artifact- or package-level operation whose required or degradable success is declared by the Refinement Directive. It remains separate from whether an artifact must be included in the package.
_Avoid_: Required artifact

**Derived Output Staleness**:
The explicit condition of findings, seeds, parses, or other outputs whose source selection was superseded or materially changed. Only affected dependency descendants rerun; stale outputs remain historical rather than being treated as current.
_Avoid_: Silent recomputation, full run restart

**Artifact Role Vocabulary**:
The versioned roles used by Package Artifact References, initially `primary_subject`, `supporting_context`, `prior_work`, `evidence_candidate`, `source_lead`, `instruction_reference`, `comparison_reference`, and `output_reference`. Namespaced extensions require explicit workflow support before they may drive behavior.
_Avoid_: Free-form behavioral tags, permanent closed enum

**Starter Finding**:
A structured observation about a starter artifact, package, or intake condition, with distinct severity, confidence, review state, evidence, method provenance, and finding-type-specific details. Its downstream consequence is evaluated separately by the proposed workflow's admission contract and policy.
_Avoid_: Free-text finding, universal package blocker

**Finding Severity**:
The impact classification of a Starter Finding: `informational`, `minor`, `material`, `major`, or `critical`. It does not encode confidence, urgency, review state, or downstream blocking behavior.

**Finding Review State**:
The review lifecycle of a Starter Finding: `unreviewed`, `confirmed`, `disputed`, `resolved`, `dismissed`, or `superseded`. Proceeding despite a valid finding is a separate policy decision rather than a review state.

**Finding Confidence**:
A `low`, `moderate`, or `high` assessment with its basis and method version. Numeric probability is optional and may drive probability-aware behavior only when produced by a calibrated method with recorded calibration context.

**Starter Readiness Assessment**:
A workflow-relative assessment of a Starter Package's blockers, warnings, and conditions for possible next Workflow Types. A missing preflight or other finding does not impose one universal block; each downstream Input Admission Contract and policy determines its consequence.
_Avoid_: Package status, implicit readiness

**Knowledge Preflight**:
A first-class, independently runnable Workflow Type for observational broad search of existing entities, knowledge, prior work, coverage, contradictions, and gaps before mission specification or deep research. It may use multiple governed retrieval modalities; any proposed graph mutation proceeds through a separate linked Workflow Run.
_Avoid_: Database lookup, identity resolution, hidden graph write

**Knowledge Preflight Brief**:
A versioned statement of a Knowledge Preflight run's purpose, intended downstream use, targets, scope, requested retrieval modalities, coverage obligations, freshness requirements, and exclusions.

**Knowledge Preflight Coverage Matrix**:
The versioned set of required, degradable, optional, and prohibited observational obligations across preflight targets, questions, schema surfaces, retrieval modalities, and relevant scope dimensions. Result counts do not substitute for cell-level coverage evidence.

**Knowledge Preflight Query Plan**:
A versioned mapping from Knowledge Preflight coverage cells to bounded query intents, schema context, retrieval modalities, limits, and stopping evidence. Query tactics may change without changing the governing coverage obligations.

**Knowledge Retrieval Observation**:
An immutable record of one Knowledge Preflight retrieval request and its observed results, preserving query, provider or index, native ranks and score semantics, graph and schema context, time, limits, failures, and evidence references. Later normalization or reranking remains separate.

**Knowledge Preflight Snapshot**:
An immutable observation of Knowledge Preflight, recording time, graph and schema version context, query intents and modalities, selected results, coverage findings, contradictions, and gap hypotheses. Packages and runs reference the snapshot rather than treating live graph state as historical context.
_Avoid_: Live lookup context, embedded graph copy

**Supporting Graph Lookup**:
A bounded observational graph query performed inside another Workflow Type for declared matching questions under enforced scope and cost limits. It records query context and graph version and may emit Graph Match Candidates, but cannot claim broad preflight coverage, resolve identity, or mutate the graph.
_Avoid_: Inline Knowledge Preflight, identity resolution, hidden graph write

**Preflight Freshness Policy**:
The contextual rules for deciding whether a Knowledge Preflight Snapshot is current enough for a proposed use, considering age, relevant graph or schema revisions, changed scope, risk, and downstream purpose. An outdated snapshot remains historical evidence rather than becoming invalid data.
_Avoid_: Global preflight TTL, silent expiration

**Schema Definition**:
The versioned Neo4j GraphQL directive `.graphql` source from which agent-oriented schema resources are deterministically generated. Runtime compatibility with the deployed graph remains separately verifiable.
_Avoid_: Agent-generated schema, live database introspection as the versioned source

**Schema Deployment Manifest**:
An immutable attestation from the graph-schema deployment process identifying the exact Schema Definition version and content hash deployed to a graph environment. A strict compatibility check requires its deployed SDL hash to equal the bound Schema Definition content hash; the manifest's own digest is not schema identity. Runtime introspection may diagnose compatibility but cannot replace this attestation.

**Schema Catalog**:
The deterministic, navigable representation generated from a Schema Definition for agent and tool use, including compact indexes, drill-down files, relationship maps, and retrieval metadata.

**Compact Schema Overview**:
The first-stage schema-selection representation containing element names, one-line descriptions, module memberships, aliases, immediate topology, and compact identity or search indicators. Full properties, enums, directives, and SDL remain drill-down material.
_Avoid_: Names-only schema, full schema prompt

**Schema Selection Context**:
The context-budgeted schema view presented for semantic selection: a global module/topology index plus either the complete Compact Schema Overview or a high-recall retrieved candidate set. Retrieval proposes candidates; it does not make the final selection.

**Schema Selection Brief**:
A versioned, high-recall seed signature for report- or task-guided schema selection, preserving concepts, entities, claims, temporal needs, intended operations, coverage obligations, and source locators. Full source material remains available on demand and may be supplied directly when it fits.
_Avoid_: Lossy report replacement, full-report-only prompt

**Schema Module**:
A versioned, potentially overlapping conceptual view of the authoritative schema used for navigation and retrieval, such as commerce or biomechanistic context. Governed definitions control canonical membership; agents may propose revisions but do not redefine modules per run.
_Avoid_: Exclusive schema partition, bounded context

**Schema Module Definition**:
A reviewed declaration of a module's purpose, descriptions, seed elements, inclusion rules, and closure policy. Deterministic generation applies it to a Schema Definition version to produce module files.
_Avoid_: Per-run LLM module

**Schema Workspace**:
A run-specific sandbox materialization of a Schema Catalog, its navigation skill, selected modules or slices, and governed working locations. Reading drill-down files or materializing details does not mutate canonical schema state.

**Schema Workspace Materialization**:
A reusable bounded operation that validates an exact Schema Catalog and applicable Schema Deployment Manifest, places governed read-only schema resources into a run or stage workspace, and emits an immutable binding and path lineage. When graph access requires strict compatibility, a missing or unequal deployed-SDL and Schema Definition content hash blocks graph-reading work. The consuming Workflow Type does not own the shared mechanism.

**Schema Context Selection**:
A semantic, immutable, purpose-bound choice of node and relationship types from one Schema Definition version, with optional non-pruning property-intent hints. It preserves coverage obligations, rationale, exclusions, evidence, and lineage; reuse for another purpose requires admission.
_Avoid_: Full schema prompt dump, mutable schema subset

**Schema Selection Review**:
The required acceptance review for agent-produced Schema Context Selections, combining deterministic name/topology validation with independent semantic coverage review of mapped concepts, explicit exclusions, unresolved mappings, and near-miss candidates.
_Avoid_: Selector self-approval, name validation only

**Expanded Schema Slice**:
The deterministic full-detail and topology-closure artifact derived from one Schema Context Selection and Schema Definition version. It materializes properties, endpoint nodes, enums, unions, relationship-property types, and operation projections without adding agent-selected meaning.
_Avoid_: Schema Context Selection, mutable drill-down state

**Schema Operation Projection**:
A deterministic purpose-specific view of an Expanded Schema Slice, such as read/search/query coverage or ingestion/write/validation coverage. It may reduce presented detail without changing semantic selection membership.

**Schema Context Selection Workflow**:
The independently runnable Workflow Type used when schema selection is broad, ambiguous, expensive, reusable, or independently requested. Obvious bounded selections may remain operations inside a consuming workflow under declared limits.

**Starter Artifact**:
An immutable intake occurrence with origin, capture, declared metadata, permissions context, and lineage, even when its referenced content is corrupt or unreadable. Identical content from different origins remains distinct Starter Artifacts; replacement creates a new version.

**Artifact Content**:
The immutable, content-addressed payload referenced by one or more artifacts. Identical payloads may be deduplicated without merging the distinct provenance, permissions, or intake identity of their artifacts.
_Avoid_: Starter Artifact, duplicated blob

**Permission Assessment**:
A method- and policy-versioned operational decision for each governed use class, with outcomes, conditions, evidence, jurisdiction, and escalation of legal ambiguity. It does not claim legal certainty, and matching content does not transfer permissions between acquisition paths.
_Avoid_: Content-wide best rights, inferred permission

**Permission Capability**:
An atomic, versioned permitted use that Workflow Types compose into their requirements, initially `inspect`, `send_to_external_processor`, `retain`, `transform`, `index`, `use_for_reasoning`, `quote`, `derive_knowledge`, `create_derivative`, `publish_derivative`, `display_or_redistribute_media`, `train_model`, and `include_in_evaluation_dataset`.
_Avoid_: Research allowed flag, free-text permission behavior

**Permission Outcome**:
The decision for one Permission Capability: `allowed`, `allowed_with_conditions`, `requires_review`, `unknown`, or `prohibited`. Unknown does not imply permission; downstream policy decides whether uncertainty is admissible.

**Repair Artifact**:
A generated replacement or companion artifact that corrects, clarifies, or regenerates a problematic Starter Artifact. It may supersede the original as the active selection, but the original version remains preserved.

**Repair Decision**:
The policy-governed decision to activate a candidate Repair Artifact as a superseding selection, retain it as a companion, or reject it. A required pending decision pauses refinement durably unless its configured timeout or fallback policy resolves the wait.

**Reconstruction Hypothesis**:
A labeled proposal for missing or unclear content inferred without sufficient source evidence. It may aid investigation but cannot silently fill the gap or supersede the original as a faithful repair.
_Avoid_: Repair Artifact, recovered content

**Seed Mention**:
An occurrence-level hint with an exact artifact locator, observed text or media region, and extraction method. Seed Mentions preserve provenance even when provisionally grouped.

**Extracted Seed**:
An immutable provisional grouping of exact Seed Mentions into a typed research-starting signal with a confidence basis. Changed grouping or typing creates linked successors rather than mutating the hypothesis; it is not accepted research instruction, evidence, or authoritative graph knowledge.

**Seed Lineage Link**:
The explicit relationship between immutable Extracted Seeds when one revises another or results from a split or merge. Grouping and lineage express extraction hypotheses, not resolved entity identity or adjudicated equivalence.
_Avoid_: In-place seed mutation, identity-resolution decision

**Seed Confidence Profile**:
A structured, method-versioned assessment that keeps detection, family or subtype classification, mention grouping, and normalized interpretation confidence separate while preserving alternatives and rationale. Numeric values are comparable only where their recorded calibration permits, and per-seed confidence does not substitute for extraction coverage.
_Avoid_: Universal seed confidence score, averaged ambiguity

**Seed Extraction Coverage Assessment**:
An immutable assessment of how the Research Seed Extraction Brief was satisfied across admitted subjects, regions, modalities, and requested seed families, distinguishing exhaustive, bounded, sampled, unsupported, inaccessible, failed, and unresolved work. A valid zero-seed result requires sufficient assessed coverage; unexamined material remains unknown rather than negative.
_Avoid_: Seed count as completion, silence as absence

**Entity Seed**:
An Extracted Seed for a potentially graph-identifiable referent, preserving a preferred candidate type, optional alternative types, labels, aliases, and unresolved identity. It is not an authoritative Entity.

**Assertion Seed**:
An Extracted Seed for a provisional source-attributed proposition that may warrant investigation, normalization, or contradiction search. It is not an accepted fact or adjudicated Assertion.
_Avoid_: Claim Seed, extracted fact

**Evidence Question Seed**:
An Extracted Seed for a provisional question about support, opposition, applicability, uncertainty, or missing evidence. It may inform later research specification but is not accepted execution instruction.

**Source Lead**:
An Extracted Seed pointing to a potentially useful source referent that still requires discovery or identity work. It is not yet a registered Source Candidate, selected source, or corpus member.

**Research Seed Extraction Brief**:
The versioned purpose and scope for research-seed extraction, including requested seed families, ontology hints, coverage expectations, exclusions, and relevant contextual references. Prompts and attached capabilities remain execution configuration unless deliberately admitted as extraction subjects.

**Extraction Subject Manifest**:
The immutable record of exact artifacts, packages, Source Snapshots, Derived Representations, corpus slices, prior seeds, or operator-provided seed sets admitted for research-seed extraction. Each subject preserves its role, provenance and locator basis, permission context, and selected version.
_Avoid_: Live URL list, mutable collection contents, unbound workspace files

**Research Seed Extraction Operation**:
Bounded research-seed extraction performed inside a consuming Workflow Run under declared limits. It emits the same typed seed-output contract as Research Seed Extraction Workflow but has no independent workflow lifecycle.
_Avoid_: Inline Research Seed Extraction Workflow, hidden Workflow Run

**Research Seed Extraction Workflow**:
The independently runnable Workflow Type for substantial, reusable, independently requested, cross-artifact, multimodal, long-running, or review-heavy extraction of Entity Seeds, Assertion Seeds, Evidence Question Seeds, and Source Leads. Invoking it creates a distinct linked Workflow Run rather than hiding first-class extraction inside another workflow.
_Avoid_: Entity Seed Extraction Workflow when multiple research-seed families are in scope

**Research Seed Extraction Result**:
The immutable domain output binding its brief and subject manifest to Seed Mentions, typed Extracted Seeds, lineage, confidence profiles, graph-match and registered-source outputs, coverage assessment, unresolved regions, and Decision Report. Its contents remain provisional even when the Workflow Run completes successfully.

**Seed Use Readiness Assessment**:
A purpose-bound assessment of whether a Research Seed Extraction Result may be consumed for a specified downstream use and which review conditions apply. Exploratory use may admit unresolved seeds, while identity, ingestion, or other consequential actions require their own stricter authority and admission decisions.
_Avoid_: Globally approved seed set, workflow completion as universal approval

**Research Seed Extraction Evaluation Profile**:
A method-versioned, multidimensional evaluation of provenance and locator validity, detection, typing, grouping and lineage, confidence calibration, coverage accuracy, ambiguity preservation, and downstream usefulness. Deterministic checks, labeled benchmarks, sampled independent review, and downstream outcome evidence remain distinguishable rather than collapsing into one quality score.
_Avoid_: Aggregate seed quality score, resolution rate as extraction quality

**Graph Match Candidate**:
A provisional link from an Entity Seed to a possible existing graph record, preserving match category, confidence basis, evidence, query context, and observed graph version. Multiple candidates may coexist until a later identity-resolving workflow adjudicates them; no observed match proves only the bounded lookup result.
_Avoid_: Graph Candidate, resolved identity

**Knowledge Production Mission**:
A bounded objective that coordinates linked Workflow Runs to produce governed knowledge, evaluations, curated content, or interactive experiences. It may enter and exit at any admissible workflow boundary while preserving which prior outputs satisfied skipped dependencies.
_Avoid_: Research Mission as the end-to-end composition, mega Workflow Run

**Mission Plan**:
A versioned composition of proposed Workflow Runs, dependencies, entry inputs, intended outcomes, and gates for a Knowledge Production Mission. Accepted revisions preserve prior versions and rationale rather than silently rewriting active or completed runs.
_Avoid_: Hidden orchestrator plan, fixed pipeline

**Mission Specification**:
A required, versioned, execution-ready statement of a Knowledge Production Mission's objective, questions, expected outcomes, exclusions, budgets, evidence requirements, gates, and evaluation obligations. Workflow Runs remain bound to the exact specification version under which they were created.
_Avoid_: Mission Instructions, expanded Intake Brief

**Specification Impact Assessment**:
The classification of how a proposed Mission Specification revision affects planned, active, and completed Workflow Runs. It preserves historical bindings and identifies which active runs are unaffected, can receive an intervention, must stop, or must fork.
_Avoid_: Retroactive mission update

**Mission Direction Proposal**:
An advisory Starter Content Refinement output containing candidate objectives, questions, scope choices, and suggested next workflows tied to package findings. It is not accepted execution instruction and may inform a later Mission Specification.
_Avoid_: Draft Mission Specification, executable mission instructions

**Mission Specification Workflow**:
The Workflow Type that transforms accepted intake intent, available packages, preflight context, and operator decisions into a validated Mission Specification proposal.
_Avoid_: Mission Instruction Workflow

**Specification Acceptance Policy**:
The risk- and trust-sensitive rules that determine whether a validated Mission Specification proposal may activate automatically or requires human or delegated acceptance. Authoring a proposal does not by itself grant authority to accept it.

**Workflow Type**:
A reusable mini-workflow category with defined schema, control configuration, execution rules, outputs, and evaluation expectations.

**Workflow Execution Blueprint**:
A Workflow Type's versioned, application-owned declarative execution shape, including stages, dependencies, joins, bounded cycles, goals, obligation references, stopping conditions, and escalation slots. It supports deterministic orchestration and inspection but does not replace Input Admission Contracts, Workflow Invariants, authority rules, domain semantics, typed output construction, or evaluation contracts.
_Avoid_: Fully generic workflow DSL, agent-authored topology

**StageGraph Blueprint**:
A Workflow Execution Blueprint family whose application-owned stage dependencies form an acyclic graph and may carry bounded per-stage or whole-workflow semantic cycle policies. Cycles wrap stages or graph evaluation rather than becoming dependency back-edges.

**GoalDirected Blueprint**:
A Workflow Execution Blueprint family that advances a bounded objective through evaluated iterations when the useful next work cannot be fully predetermined as a stage graph. Completion claims require independent verification, and optional goal evolution remains inside the launch-bound objective, acceptance, authority, and budget envelope.

**Goal Revision**:
An immutable, evaluated successor to a GoalDirected run's active goal that refines tactics, subgoals, ordering, or coverage emphasis without broadening the accepted objective or authority. Broader change requires an allowed control revision, fork, or linked or new Workflow Run.
_Avoid_: Agent-authored scope expansion, mutable goal text

**Workflow Blueprint Binding**:
The immutable record of the exact Workflow Execution Blueprint version bound to a Workflow Run and the declared variants selected at launch. Runtime controls may activate only branches, obligations, cycles, and escalation paths already permitted by that blueprint; structural topology changes require a fork or new run.
_Avoid_: Mid-run topology rewrite, control revision as workflow redesign

**Workflow Obligation Matrix**:
A Workflow-Type-specific, versioned declaration applying typed Processing Obligations across relevant subjects, stages, scope dimensions, or coverage cells, with required, degradable, optional, and prohibited status plus completion and stopping evidence. Its dimensions and semantics remain domain-specific even when the matrix machinery is shared.
_Avoid_: Flat task checklist, universal domain-neutral obligation schema

**Workflow Obligation Matrix Revision**:
An immutable successor to a run's obligation matrix created only through expansion, degradation, or reconsideration rules declared by its bound Workflow Execution Blueprint. It preserves the baseline and prior revisions, records added or changed cells and authority, and cannot introduce structurally undeclared work; material scope expansion requires a Continuation Proposal, linked run, fork, or new run.
_Avoid_: In-place obligation mutation, budget-only agent scope expansion

**Input Admission Contract**:
The machine-enforced conditions under which a Workflow Type may accept a proposed Run Input Manifest. Agent recommendations may inform the decision but do not authorize inputs that violate the contract.
_Avoid_: Agent readiness judgment, inferred eligibility

**Workflow Invariant**:
A non-overridable rule required to keep a Workflow Run or its proposed effects valid. Trust, permission, and human approval cannot convert an invariant violation into a valid action.

**Policy Gate Override**:
An audited exception to a gate explicitly designated as overridable, recording the authority, reason, and affected action. It does not apply to Workflow Invariants.
_Avoid_: Admin bypass, complete-permission bypass

**Workflow Run**:
One execution of a Workflow Type whose mission-owned or standalone execution scope is fixed at creation. Later missions may reference a standalone run or its outputs but do not retroactively re-parent it.

**Workflow Run Lifecycle Model**:
The domain-level, multi-axis representation of a Workflow Run's current lifecycle phase, any durable wait or pause reason, terminal execution outcome, and purpose-bound output readiness. These axes remain separate, and Temporal execution status or history maps to them without becoming their authoritative domain meaning.
_Avoid_: One overloaded run status, Temporal status as domain state

**Workflow Run Lifecycle Phase**:
The shared minimal phase of a Workflow Run: `pending`, `active`, `waiting`, `paused`, `cancelling`, or `terminal`. Detailed scheduling, worker dispatch, retries, activity recovery, and compensation remain execution events or projections rather than additional domain phases.

**Workflow Run Wait Condition**:
A typed, blueprint-declared condition that durably blocks affected run work until a verifiable dependency, timer, approval, resource, budget, or external result condition is satisfied or its timeout policy resolves. Verified satisfaction authorizes automatic resumption of the affected work without a new authority grant.

**Workflow Run Pause Decision**:
The immutable policy or authorized-intervention decision that explicitly suspends run progress, recording scope, reason, authority, conditions for reconsideration, and affected work. Clearing the underlying cause does not resume paused work until an authorized resume decision is recorded.
_Avoid_: Pause as ordinary dependency wait, implicit resume

**Workflow Run Lifecycle Reducer**:
The application-owned deterministic authority that validates typed lifecycle commands and observed facts against the run's current version, bound blueprint, invariants, policy, and actor authority before recording a domain transition. Agents, agent systems, humans, Temporal workflows, workers, and external callbacks may be authorized command or fact sources, but none bypass the reducer through direct state mutation.

**Lifecycle Transition Authority**:
The versioned policy determining which human, service, agent, agent system, or deterministic rule may decide or request each class of Workflow Run lifecycle transition. Special agents may receive named transition authority through validated configuration, while the application reducer still enforces and records the transition.
_Avoid_: Agent prompt as transition authority, direct lifecycle database update

**Workflow Lifecycle Command**:
A typed, actor-attributed request to apply one domain lifecycle transition, carrying a stable idempotency identity and expected Workflow Run version. The lifecycle reducer atomically returns the prior accepted result for duplicate delivery and rejects or reevaluates stale conflicting commands rather than applying last-write-wins mutation.

**Workflow Lifecycle Transition Record**:
An immutable append-only record of one accepted Workflow Run lifecycle transition, preserving prior and resulting phase, run version, command identity, actor and authority, reason, evidence, correlation, and time. It is transactionally committed with the current run projection, providing audit and reconciliation without requiring every workflow domain object to be fully event-sourced.

**Workflow Domain Event Envelope**:
The versioned publication record for an accepted workflow-domain fact, preserving event identity, event type and schema version, aggregate identity and version, occurrence and recording times, actor, correlation and causation, and typed payload or durable payload reference. It is committed through a transactional outbox with the authoritative change and consumed idempotently through durable cursors.
_Avoid_: Best-effort notification as authoritative event, unversioned event payload

**Workflow Run Outcome**:
The terminal execution-contract result, distinct from output readiness: `completed` when required obligations finished, `partially_completed` when valid outputs exist despite declared degradable work failing, `failed` when a required obligation was unmet, and `cancelled` when authorized cancellation intentionally terminated the run. Valid partial outputs do not change a cancelled run into `partially_completed`; request rejection and output supersession are separate concepts.
_Avoid_: Output quality status, package readiness

**Run Request**:
A proposal by a human, service, dashboard action, or agent to create a Workflow Run from a specified Workflow Type, Run Input Manifest, controls, and delegated authority. The control plane validates it before execution state exists.
_Avoid_: Direct agent launch, implicit workflow start

**Linked Run Request Identity**:
The parent-scoped logical identity used to create one linked Workflow Run idempotently, combining a declared request slot or intent, an immutable request revision, and a payload fingerprint. Retries and replay reuse the same identity, while a material change creates a new revision or identity; matching content in another parent or obligation does not imply the same request.
_Avoid_: Global content-hash deduplication, duplicate child creation on retry

**Run Composition Link**:
The durable relationship created when one Workflow Run requests another Workflow Type. Crossing a Workflow Type boundary always creates a distinct linked Workflow Run that preserves the invoked type's standalone contract.
_Avoid_: Hidden sub-workflow, inlined workflow run

**Run Dependency Class**:
The parent-Workflow-defined completion relationship assigned when it requests a linked Workflow Run: `required_blocking`, `degradable_blocking`, `degradable_nonblocking`, or `detached_advisory`. The class controls waiting, timeout, degradation, completion, and result-admission behavior without changing the child Workflow Type's standalone contract.
_Avoid_: Dependency behavior inferred from child status, coordinator-improvised waiting

**Run Dependency Revision**:
An immutable, authorized change to a Run Composition Link's dependency class or related parent-side waiting and admission behavior. It preserves the prior class and rationale, follows the parent Workflow Type's revision policy, and assesses whether existing parent outputs, obligations, or readiness conclusions must be invalidated, restricted, or reevaluated.
_Avoid_: In-place dependency mutation, changing class only to bypass a blocked obligation

**Run Cancellation Propagation Policy**:
The parent-Workflow-defined rules for how a cancellation request affects linked runs by Run Dependency Class. Parent cancellation requests cancellation of blocking children by default, while non-blocking and detached children follow declared continuation policy; child termination affects parent obligations through dependency semantics and never automatically reverse-cancels the parent.
_Avoid_: Universal cancellation cascade, lifecycle inferred from process hierarchy

**Linked Run Result Admission Decision**:
The immutable parent-side decision to admit, conditionally admit, reject, or defer an exact output of a linked Workflow Run for a declared parent obligation or use. Every child result requires this decision; governing policy may issue it automatically when declared compatibility, readiness, provenance, permission, and evaluation conditions pass, while other cases require delegated or human review.
_Avoid_: Child completion as automatic parent mutation, coordinator copying linked outputs

**Late Linked Result**:
An output that becomes available after its non-blocking or detached parent Workflow Run reached a terminal outcome. It remains independently valid and linked, but cannot mutate the terminal parent or its outputs; incorporating it into successor outputs requires a new Workflow Run with explicit input admission and lineage.
_Avoid_: Post-terminal parent mutation, silently revised completed output

**Run Input Manifest**:
An immutable record of the exact artifact, package, entity, configuration, and other input references selected for a Workflow Run. Changes after launch require an explicit intervention, fork, or new run rather than silently changing the manifest.
_Avoid_: Live workspace contents, mutable run inputs

**Source**:
An umbrella provenance role for something from which information or evidence is obtained. Concrete source identities must distinguish enduring origins, bounded works, immutable captured states, and workflow-relative uses rather than treating Source as one entity type with one global authority score.
_Avoid_: Universal source record, globally authoritative source

**Provenance Spine**:
The system-wide typed lineage graph connecting Source Origins, works, versions, representations, immutable captures, derived material, exact locators, Assertions, Adjudications, approved knowledge, Curated Content, and component data bindings. It permits explicit unresolved layers and purpose-bound paths rather than requiring one fabricated linear chain.
_Avoid_: Citation string, mandatory linear pipeline, one provenance score

**Provenance Completeness Profile**:
An immutable, method-versioned, purpose-bound assessment of an exact subject and considered provenance evidence that keeps lineage depth, locator resolution, coverage, confidence, transformation fidelity, and verification readiness separate. It binds the applicable Provenance Requirement Profile and assessment time; changed evidence or requirements create a linked revision rather than mutating history.
_Avoid_: Provenance Density, single provenance score

**Provenance Requirement Profile**:
A shared, versioned, purpose-specific declaration of provenance dimensions and minimum conditions that a Workflow Type binds at admission, completion, or promotion boundaries. Mission and run overlays may select allowed variants or strengthen requirements, but cannot weaken provenance-related Workflow Invariants.
_Avoid_: Universal provenance completeness, mission-wide provenance score

**Provenance Profile Composition**:
The construction of a higher-level Provenance Completeness Profile from referenced lower-level profiles and declared coverage obligations across sources, Assertions, Adjudications, content, and component bindings. Material gaps and limiting branches remain explicit rather than being averaged away.
_Avoid_: Run-wide provenance average, flattened completeness score

**Source Origin**:
An enduring place, system, channel, or publication authority from which information can be obtained, such as a website, repository, database, journal platform, or API. It may provide many Source Works or changing records and is distinct from both its operator and captured content.
_Avoid_: Source Work, operating organization, captured webpage

**Source Work**:
A bounded intellectual or informational creation whose identity may persist across hosting locations and representations when sameness is established, such as a paper, report, regulatory decision, dataset release, label edition, or video. Each acquired representation and observation remains separately traceable.
_Avoid_: File copy, access URL, Source Snapshot

**Source Work Version**:
A particular issued revision or edition of a Source Work whose materially distinct content must remain independently identifiable. Multiple formats may represent the same version, while changed claims or substantive content require a distinct version.
_Avoid_: File format, mirrored copy, Source Snapshot

**Source Representation**:
A particular format or rendering of a Source Work Version, such as publisher HTML, PDF, XML, audio, or video. Representations may differ in fidelity, extractability, rights, and locator stability without constituting different substantive work versions.
_Avoid_: Source Work Version, immutable capture, derived corpus chunk

**Derived Representation**:
A system-produced transformation of a Source Snapshot or another admitted representation, such as OCR text, normalized HTML, a transcript, extracted tables, or page images. Its identity and lineage preserve the transformation method, method version, configuration, source inputs, and fidelity findings because derived content may differ from what the source provided.
_Avoid_: Source Representation, corrected source truth, untraceable conversion

**Source Candidate**:
A workflow-relative discovery proposal that a source referent may be useful for a declared purpose. It targets the most precise currently known Source Origin, Source Work, Source Work Version, Source Representation, or unresolved locator while preserving uncertainty, discovery context, and ranking signals; it is not automatically selected, captured, part of a Source Corpus, or authoritative graph knowledge.
_Avoid_: Resolved Source Work, automatically selected source, corpus member

**Source Identity Hypothesis**:
An immutable provisional proposal that exact source observations or referents represent the same or different Source Origins, Works, Work Versions, Representations, or captures. It preserves supporting and opposing evidence, alternatives, confidence, and method context; URL or content equality may contribute evidence but cannot silently merge provenance records or settle every source layer.
_Avoid_: URL deduplication as identity resolution, destructive source merge

**Source Classification Profile**:
A multidimensional, purpose-bound classification of a source candidate across official or affiliated relationship, evidence role, material kind, position, origin and independence, and access or provenance qualities. A source may occupy several dimensions simultaneously rather than receiving one exclusive source class.
_Avoid_: Flat source-type enum, official means high-quality evidence

**Source Diversity Requirement**:
A declared coverage obligation specifying which source-classification dimensions must vary and why for a discovery purpose. Domain or URL counts do not demonstrate diversity when sources share the same origin, evidence dependency, position, or material role.
_Avoid_: Distinct-domain quota as diversity, source-count diversity

**Supporting Source Lookup**:
A bounded external lookup performed inside another Workflow Type for declared clarification questions under enforced search, page, time, and cost limits. It registers discovered sources but cannot claim systematic procurement or corpus coverage.
_Avoid_: Inline Source Discovery Workflow, unregistered web lookup

**Discovery Evidence Capture**:
A permission-checked acquisition performed by Source Discovery only to preserve reproducible evidence for source identity, classification, ranking, or collection-membership decisions. It creates an immutable Source Snapshot but does not imply collection inclusion, corpus admission, canonical transformation, indexing, research selection, ingestion selection, or graph promotion.
_Avoid_: Live URL as durable evidence, discovery capture as corpus membership

**Research Source Selection**:
The decision that a Source Candidate may be used provisionally for reasoning during research.

**Ingestion Source Selection**:
The decision that a source may become durable provenance, document, media, or source material attached to graph knowledge.

**Source Intelligence**:
The durable operational understanding of source identity, official and ownership relationships, discovery, ranking, acquisition, snapshots, collection and corpus decisions, transformations, use, exclusions, assessments, monitoring, and downstream impact. Its workflow artifacts may be canonical operational records without being canonical knowledge-graph facts.
_Avoid_: Source Intelligence Cache, URL cache, source score

**Source Intelligence Graph Promotion**:
The explicit proposal to project selected Source Intelligence into canonical knowledge-graph knowledge through Ingestion Plan and Ingestion Execution Workflow Runs. Durable Source Intelligence storage is not itself graph promotion, and no source workflow writes the canonical graph implicitly.
_Avoid_: Source workflow graph write, storage equals ingestion

**Source Ref**:
A durable pointer to captured evidence, document content, media, quote span, URL, or artifact used as provenance for an ingestion-ready assertion.

**Official Source Mapping Workflow**:
The independently runnable Workflow Type that finds and verifies purpose-bound official-source relationships for provisional or canonical mapping subjects, including bounded source-identity work needed for those mappings. Input authority is preserved: mapping an unresolved subject produces provisional mapping outputs and never fabricates canonical identity or mutation authority.

**Official Source Mapping Brief**:
The versioned purpose and scope for official-source mapping, including requested relationship or claim classes, temporal and geographic scope, verification requirements, and exclusions.

**Mapping Subject Manifest**:
The immutable record of exact Entity Seeds, canonical Entities, operator-provided referents, or prior mapping-subject versions admitted to Official Source Mapping Workflow with their authority, identity anchors, provenance, and supporting-context references.
_Avoid_: Resolved-entities-only input, unversioned target list

**Official Source Mapping Target**:
The most precise source referent whose relationship to a mapping subject is supported by verification evidence: a Source Origin, Source Work, Source Work Version, Source Representation, mutable official record or page, or unresolved locator. Later source-identity work may refine it, but the workflow does not fabricate missing source layers to complete a provenance hierarchy.
_Avoid_: Mandatory Source Work target, invented work version

**Source Identity Resolution Operation**:
Bounded source-identity work performed inside a consuming Workflow Run when deterministic or narrowly scoped checks are sufficient for that workflow's purpose. It preserves identity evidence and uncertainty but has no independent workflow lifecycle.
_Avoid_: Inline Source Identity Resolution Workflow, implicit source merge

**Source Identity Resolution Workflow**:
The independently runnable Workflow Type for substantial, reusable, independently requested, or cross-workflow determination of whether source referents represent the same or different Source Origins, Works, Work Versions, Representations, or captures. It serves source reconciliation even when no official-source relationship is being requested.

**Official Source Mapping Candidate**:
An immutable proposal that an exact mapping subject and target may have a particular scoped, temporal official relationship. Multiple candidates may coexist and are competing only where their roles, scopes, and validity intervals are mutually exclusive.
_Avoid_: Best official source, verified relationship

**Official Relationship Verification Evidence**:
A typed, attributable observation supporting or opposing an official-source relationship, such as control evidence, reciprocal links, identifiers, registry or repository metadata, authenticated platform relationships, signatures, or independent-record consistency. It preserves whether the relationship was merely self-claimed, externally supported, or verified by BellLabs under a recorded method.
_Avoid_: Link count, source self-assertion as verification

**Official Relationship Verification Requirement Profile**:
A versioned, purpose- and relationship-specific declaration of acceptable evidence classes and minimum verification conditions. It permits one sufficiently strong control or registry proof while preventing many duplicated weak signals from masquerading as independent verification.
_Avoid_: Universal two-source rule, global officialness threshold

**Official Source Relationship**:
A temporal, purpose- and claim-class-scoped relationship between an exact mapping subject and Official Source Mapping Target, preserving relationship role, jurisdiction, validity or observation interval, claimant, verifier, verification method and status, and supporting or opposing evidence. It establishes bounded official standing rather than making the target globally official or scientifically authoritative.
_Avoid_: `is_official`, timeless authority, official means scientifically true

**Official Source Verification Decision**:
An immutable assessment of one Official Source Mapping Candidate under an exact verification requirement profile and evidence set, with outcome `verified`, `provisionally_supported`, `disputed`, `rejected`, or `unresolved`. Only a sufficiently verified candidate yields an Official Source Relationship; other decisions remain durable evidence rather than disappearing from a winner-only result.

**Official Mapping Confidence Profile**:
A structured assessment that keeps mapping-subject identity, target identity, relationship role, temporal scope, and evidence sufficiency confidence separate. It preserves consequential ambiguity instead of collapsing distinct verification risks into one officialness score.
_Avoid_: Official confidence score, candidate rank as verification

**Official Source Mapping Result**:
The immutable domain output binding its brief and subject manifest to mapping targets, candidates, evidence, confidence profiles, verification decisions, verified relationships, registered Source Candidates, unresolved mappings, coverage assessment, stopping rationale, and Decision Report. It does not implicitly create a Source Collection or promote its contents into graph knowledge.

**Official Source Mapping Coverage Assessment**:
An immutable assessment of mapping and verification obligations across requested subjects, relationship roles, claim classes, jurisdictions, and time scopes, including unresolved and unexamined cells and stopping rationale. A valid zero-mapping result requires sufficient assessed coverage rather than an empty search result.
_Avoid_: URL count as coverage, no mapping means no official source

**Official Mapping Freshness Policy**:
The purpose-sensitive rules for deciding whether an observed Official Source Mapping Result remains current enough for a proposed use, considering age, ownership and control changes, redirects, new evidence, relationship risk, and downstream consequence. An outdated result remains historical evidence rather than becoming invalid data or silently remaining current.
_Avoid_: Permanent verification, global mapping TTL

**Official Mapping Verification Authority Policy**:
The risk- and evidence-sensitive rules determining whether a verification decision may be issued automatically or requires independent or human review. Strong deterministic evidence may qualify for narrow automated verification, while ambiguity, conflict, consequential control, and temporal or ownership complexity may require a reviewer distinct from the proposing actor.
_Avoid_: Universal human gate, unrestricted mapper self-approval

**Official Source Mapping Evaluation Profile**:
A method-versioned, multidimensional evaluation of subject and target identity, source-layer precision, relationship role and scope, evidence sufficiency and independence, candidate discovery, confidence calibration, coverage accuracy, ambiguity preservation, and downstream usefulness. Deterministic checks, benchmarks, sampled review, temporal rechecks, and downstream outcomes remain distinguishable rather than collapsing into one mapping score.
_Avoid_: Officialness score, domain-match accuracy as mapping quality

**Source Monitoring Workflow**:
The independently runnable Workflow Type for continuous or portfolio-scale detection of changes in source availability, identity, ownership, control, redirects, content, official relationships, and downstream impact. Bounded freshness checks may remain operations inside consuming workflows, while changed evidence creates linked observations and decisions rather than overwriting history.

**Source Discovery**:
The independently runnable Workflow Type for systematic source procurement against declared requirements, coverage obligations, and stopping rules. It emits Source Collection Snapshots with membership decisions, coverage findings, gaps, and stopping rationale rather than implicitly creating a Source Corpus.
_Avoid_: Supporting Source Lookup, Source Corpus Build

**Source Discovery Brief**:
The versioned requirements contract for Source Discovery, defining purpose and research questions, discovery targets, required and desired source and evidence classes, scope, freshness, diversity, permission and provenance requirements, coverage obligations, stopping conditions, budget, and exclusions. Search queries are derived, versioned tactics with provider context rather than the requirements themselves.
_Avoid_: Search query as discovery specification, prompt-only requirements

**Source Discovery Coverage Matrix**:
The versioned, machine-enforceable set of applicable discovery obligations across exact targets, evidence or source roles, scope dimensions, and required or desired status. Each cell preserves search effort, results, gaps, failures, exclusions, and stopping evidence; aggregate source or domain counts cannot substitute for cell-level coverage.
_Avoid_: Global source-count target, distinct-domain quota as coverage

**Source Retrieval Observation**:
The common immutable envelope for one result observed through an external provider or internal retrieval system, preserving query or request context, provider-native rank and score, engine or index version, retrieval time, access path, raw evidence references, and scope. BellLabs classification, reranking, confidence, and membership decisions remain separate linked assessments rather than replacing provider-native evidence.
_Avoid_: Universal normalized source score, provider result as Source Candidate truth

**Zero-Source Discovery Finding**:
The evidence-backed conclusion that no admissible source was found for an exact Source Discovery coverage cell after its required search and stopping conditions were sufficiently assessed. It preserves attempted tactics, provider and scope coverage, exclusions, access or permission limits, unresolved leads, and whether absence or only non-discovery can be claimed.
_Avoid_: Empty result list as evidence of absence, budget exhaustion as sufficient stopping proof

**Discovery Target Set**:
The immutable, typed set of Entity Seeds or Entities, Assertion Seeds or Assertions, Evidence Question Seeds, Source Leads, and brief-defined mechanisms, interventions, outcomes, or topics against which Source Discovery obligations are assessed. The Workflow Type is target-polymorphic rather than inherently entity-centered.

**Entity-Centered Source Discovery**:
An invocation profile of Source Discovery whose primary targets are Entity Seeds or canonical Entities. It is one discovery mode rather than a separate Workflow Type or the definition of all Source Discovery.
_Avoid_: Source Discovery is entity research

**Source Collection**:
A durable, purpose-bound, mutable collection of source referents and workflow-relative candidates, preserving inclusion, exclusion, and unresolved-identity decisions without implying capture, processing, or corpus admission.
_Avoid_: Source Corpus, captured-source bundle

**Source Collection Snapshot**:
An immutable view of a Source Collection's exact effective membership, purpose, and governing requirements at a declared time, kept separate from references to the relevant include, exclude, and unresolved decisions, considered candidates, and coverage evidence. Workflow Runs bind or emit snapshots rather than treating later collection changes as historical input.
_Avoid_: Live Source Collection, Source Corpus version

**Source Collection Membership Decision**:
An immutable, purpose-bound decision to include, exclude, or leave unresolved a source referent or Source Candidate within one Source Collection, preserving rationale, evidence, actor or method, confidence, conditions, and reconsideration triggers. Membership and source-identity state are independent: policy may include an exact unresolved referent with explicit restrictions without fabricating missing Source Origin, Work, Version, or Representation identity. The same source may receive different decisions in collections with different purposes.
_Avoid_: Global source status, mutable included flag

**Corpus Admission Decision**:
An immutable decision to admit, reject, conditionally admit, or leave pending a specific Source Snapshot or representation for one Source Corpus purpose. It evaluates collection selection, acquisition identity, permissions, capture integrity, transformation fitness, and the target corpus contract without treating selection or successful capture as automatic corpus membership.
_Avoid_: Collection inclusion, successful download, implicit corpus membership

**Source Corpus**:
A purpose-bound body of admitted Source Snapshots and processed representations, documents, media, chunks, indexes, embeddings, and connections made available for governed retrieval or downstream work. Corpus membership implies capture and admission under a declared corpus contract, not source authority or research selection.
_Avoid_: Source Collection, search-result set

**Source Corpus Revision**:
An immutable manifest of one Source Corpus's exact admitted Source Snapshots, Derived Representations, documents, media, chunks, embeddings, indexes, connections, methods, and governing corpus-contract version. The Source Corpus is the durable purpose-bound identity; repeated builds create linked revisions, and downstream runs bind an exact revision rather than mutable live corpus state.
_Avoid_: In-place corpus mutation, unrelated corpus identity per rebuild

**Document Artifact**:
A processed document-like source such as a PDF, webpage, transcript, report, publication, label, or white paper.

**Media Artifact**:
A processed media-like source such as a photo, image, chart, video, audio file, thumbnail, screenshot, or diagram.

**Chunk Artifact**:
A retrievable portion of a Document Artifact or Media Artifact representation, with source anchors, embeddings, and connections.

**Decision Report**:
A separately versioned, human-readable and machine-minable explanation of workflow decisions, alternatives, uncertainty, tool usage, output quality, failures, and improvement candidates. It is linked to the run and its domain outputs rather than embedded as their substitute.

**Decision Point**:
A meaningful choice made during a workflow, including the selected action, rejected alternatives, rationale, evidence, and confidence.

**Improvement Candidate**:
A proposed future improvement to a prompt, schema, skill, configuration, source policy, workflow rule, or evaluation rule derived from workflow experience.

**Sandbox Workspace**:
An isolated agent execution environment with tools, files, browser state, skills, runtimes, and working artifacts. It may be ephemeral or saved as a snapshot.

**Workspace Template**:
A versioned project-owned declaration of initial directories, mounted inputs, writable outputs, skill bundles, bootstrap files, runtimes, packages, users, permissions, and capability requirements for a Sandbox Workspace. It compiles to provider or SDK sandbox constructs without adopting them as domain contracts.

**Run Workspace Namespace**:
The logical collection of Sandbox Workspaces and branch working areas allocated to one Workflow Run. Cross-run reuse occurs only through promoted artifacts or explicit snapshot/fork lineage, not an untracked shared filesystem.
_Avoid_: One run equals one sandbox, global agent workspace

**Workflow Workspace Contract**:
The Workflow Type's versioned declaration of logical working locations, purposes, access rules, input and output slots, write ownership, and artifact-promotion expectations. Shared inputs default read-only while parallel branches receive exclusive write areas resolved per run.

**Workspace Materialization Manifest**:
The run-specific mapping from governed workspace paths to durable package, artifact, and storage references or to explicitly local generated candidates. Unmapped files do not silently become domain artifacts, and promotion updates both durable state and the manifest.
_Avoid_: Implicit folder sync, sandbox filesystem as canonical store

**Sandbox Requirement Policy**:
The strong default that agents using workflow files, shell, browser, code execution, package installation, or artifact creation run in a Sandbox Workspace. Explicit narrow exceptions may cover coordinator turns and read-only operations limited to typed backend tools.

**Sandbox Snapshot**:
An immutable saved state of a Sandbox Workspace used for reproducibility, debugging, resumption, or audit. Restoring it creates a new workspace instance with explicit parent lineage; live credentials, connections, and authority are re-resolved.
_Avoid_: In-place workspace mutation, canonical domain artifact

**Graph Candidate**:
The adjudicated pre-commit view of entities, relationships, claims, documents, media, source refs, and provenance a workflow proposes for graph ingestion.

**Ingestion Plan**:
A validated, reviewable description of ordered graph and corpus writes. It can be dry-run, approved, committed, rejected, or repaired.

**Graph Commit**:
The approved execution of an Ingestion Plan into the authoritative graph.

**Curated Content**:
User-facing or operator-facing content generated from approved graph knowledge, research artifacts, and source provenance.

**Evaluation**:
The workflow activity that checks research quality, source quality, ingestion correctness, content safety, provenance integrity, retrieval behavior, and improvement opportunities.

**Decision Cart**:
A user-owned collection of potential acquisitions under consideration, preserving the evidence, rationale, alternatives, uncertainty, and personal fit behind each decision.
_Avoid_: Shopping cart, recommendation list

**Protocol Workspace**:
A user workspace for organizing planned, active, paused, and completed interventions and understanding how they relate over time.
_Avoid_: Decision Cart, regimen list

**Intelligence Workspace**:
The broader, evolving user environment in which evidence, personal context, decisions, protocols, observations, and future intelligence features come together.
_Avoid_: Dashboard

**Product**:
An enduring commercial identity under which an organization presents one or more Product Variants over time.
_Avoid_: SKU, offer, formulation

**Product Variant**:
A distinguishable marketed realization of a Product, such as a particular strength, format, flavor, package, jurisdiction, or channel configuration.
_Avoid_: Offer, formulation version

**Formulation Version**:
A time-bounded composition specification for a Product Variant, including its ingredient components, quantities, roles, and delivery form.
_Avoid_: Label, product, lot

**Label Snapshot**:
A captured version of labeling observed from a particular source at a particular time. It records what was declared and is not proof of actual composition.
_Avoid_: Formulation, verified composition

**Ingredient Material**:
A chemically, biologically, or compositionally characterized material used as an ingredient, including defined substances, botanical preparations, microbial strains, and mixtures.
_Avoid_: Nutrient, compound when the material is not a discrete chemical compound

**Branded Ingredient Material**:
An Ingredient Material sold or licensed under a commercial name and normally constrained by an owner, supplier, specification, or manufacturing process.
_Avoid_: Trademark, generic substance

**Product Lot**:
A traceable production quantity of a Product Variant made under shared manufacturing conditions and associated with a lot identifier.
_Avoid_: Product Variant, formulation version

**Study Intervention**:
The precisely administered material, product, procedure, or combination assigned to a study arm, including its dose, route, schedule, duration, and preparation.
_Avoid_: Marketed product unless identity is demonstrated

**Offer**:
A merchant's time-bounded commercial proposition for obtaining a Product Variant, including price, currency, availability, purchase terms, and channel.
_Avoid_: Product, SKU

**Evidence Applicability**:
An adjudicated assessment of how directly a piece of evidence applies to another entity, claim, population, dose, formulation, or use context.
_Avoid_: Citation count, assumed equivalence

**Assertion**:
A proposition attributable to a source or agent, preserved independently from whether Human Upgrade accepts, rejects, disputes, or supersedes it.
_Avoid_: Fact, direct edge when provenance and disagreement matter

**Adjudication**:
A Human Upgrade evaluation of one or more Assertions that records a verdict, rationale, evidence, method, and review state.
_Avoid_: Source assertion, silent correction

**Source Snapshot**:
An immutable capture occurrence of a Source Representation or other content observed from a Source Origin, preserving observation time, acquisition context, and content identity needed to reproduce research despite later source changes. Identical content acquired from different origins or at different times remains distinct snapshots even when Artifact Content is deduplicated; purpose, authority, claim relevance, quality, and ranking remain contextual assessments rather than intrinsic snapshot truth.
_Avoid_: Live URL, Source Representation, contextual authority assessment

**Source Locator**:
A durable pointer to the exact source region supporting or contradicting an Assertion, such as a page, section, table, figure, label panel, or hashed excerpt.
_Avoid_: Citation without location, Source Snapshot

**Ingredient Component**:
A contextual occurrence of an Ingredient Material within a Formulation Version, carrying its role, order, quantity basis, and nesting.
_Avoid_: Ingredient Material, compound

**Evidence Assessment**:
A method-versioned evaluation of evidence quality, identity resolution, applicability, or another reasoning question, with uncertainty kept explicit.
_Avoid_: Assertion, unexplained score
