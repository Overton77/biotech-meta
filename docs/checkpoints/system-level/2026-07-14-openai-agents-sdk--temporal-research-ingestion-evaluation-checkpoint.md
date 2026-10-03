# OpenAI Agents SDK and Temporal Research, Ingestion, and Evaluation Architecture Checkpoint

Date: 2026-07-14

Status: Updated 2026-07-15; accepted runtime direction with intentionally open scheduling and persistence decisions

## Purpose

This document records where the Bell Labs Biotech research, ingestion, and evaluation architecture currently stands and what the next specification sessions are intended to produce.

The immediate objective is not to implement the complete system. The objective is to establish the specifications, ubiquitous language, domain boundaries, execution semantics, artifacts, decision points, persistence rules, and evaluation loops required to implement it coherently with the OpenAI Agents SDK and Temporal.

This checkpoint builds on:

- [ADR 0001: Use Composable Workflow Runs](../adr/0001-composable-workflow-runs.md)
- [Research Workflow Domain Checkpoint](2026-07-08-research-workflow-domain-checkpoint.md)

## Where We Are

The system is being designed as a composable research operating system rather than one rigid pipeline.

The common end-to-end shape remains:

```text
Starter Content
-> Starter Content Refinement
-> Mission Instructions
-> Source Discovery and Selection
-> Research
-> Ingestion Plan
-> Ingestion
-> Content Creation
-> Evaluation
```

The present architecture work will concentrate primarily on the deep research, ingestion, and evaluation portions of that lifecycle. These form the knowledge foundation for two additional first-class capabilities: expertly curated content and agent-generated user experiences. They are not the immediate design center, but their requirements must influence provenance, artifact, evaluation, and API decisions from the beginning.

The accepted domain direction remains:

- A **Research Mission** is the central unit for a coordinated deep-research objective.
- A **Workflow Type** defines a reusable workflow contract, including its inputs, outputs, controls, execution rules, operational artifacts, decision reports, and evaluation expectations.
- A **Workflow Run** is one execution of a Workflow Type.
- Workflow Runs may be composed into a Research Mission or started independently through an API or dashboard action.
- Research, ingestion, and evaluation must remain independently runnable and composable.
- Every important run must remain traceable through its inputs, configuration, sources, artifacts, decisions, outputs, and evaluations.

## Current Orchestration Decision

The **OpenAI Agents SDK for Python** is the primary agent harness. It will provide:

- agent definitions, instructions, tools, guardrails, and the `Runner` agent loop
- native OpenAI Responses integration and built-in tracing
- MCP-backed tools and services
- SDK sessions and conversation history
- raw, run-item, tool, handoff, and agent-update streaming events
- manager-style agents-as-tools and specialist handoffs
- human approval, interruption, and resumable run state
- sandbox agents with manifests, capabilities, resumable sessions, and snapshots

**Temporal** is the durable execution engine. It will own workflow history, long-running execution, retries, timeouts, timers, signals, queries, updates, cancellation, worker recovery, and child-workflow lifecycle. Network calls, model runs, database mutations, and sandbox-provider operations must execute through appropriate activities rather than as nondeterministic workflow code.

The scheduling algorithm for deep-research stages remains intentionally open. The specification interviews must decide how dependencies, fan-out, joins, cycles, convergence, budgets, checkpoints, and termination are represented. Temporal will execute the accepted semantics durably; it will not define those domain semantics by accident.

OpenAI-family models will use the SDK's native OpenAI Responses model path. **LiteLLM will be introduced only when a workflow intentionally uses models outside the OpenAI family.** It is not the default path for OpenAI models.

The architecture specifications should be written in domain language first. After each domain checkpoint is coherent, it will be mapped deliberately to OpenAI Agents SDK and Temporal concepts. The domain model must not become a collection of framework-specific names.

Detailed capability notes, documentation setup, runtime boundaries, and unresolved design questions are recorded in [OpenAI Agents SDK and Temporal Architecture Notes](../BellLabs/openai-agents-sdk-and-temporal.md).

## Working Schema Assumption

While designing the research, ingestion, and evaluation system, we will assume that a sufficiently optimized target knowledge schema is available.

This is a design-enabling assumption, not a claim that the present schema is final.

The assumed schema must be usable to create:

- an agent ingestion workspace
- schema-aware extraction and normalization instructions
- a schema selection workflow
- entity, assertion, evidence, provenance, document, media, and relationship targets
- ingestion validation rules
- evaluation rubrics for completeness, validity, provenance, and consistency

The first complete system run may use a **good-enough schema**. After a successful end-to-end run, its research artifacts, ingestion decisions, failures, ambiguities, graph results, and evaluation findings will be used to improve the schema.

The intended learning cycle is:

```text
Good-enough Schema
-> Research and Evidence Production
-> Schema-Aware Ingestion
-> Knowledge Graph Result
-> Evaluation
-> Schema Improvement Candidates
-> Reviewed Schema Revision
-> Subsequent Runs
```

Schema changes must be proposed and evaluated rather than silently inferred into production. A successful workflow run can identify schema improvements, but it does not automatically authorize them.

## Knowledge-Derived Content and Experiences

The knowledge base is not the final product. The system must transform validated knowledge into useful, expertly curated content and interactive user experiences.

These are distinct but related downstream capabilities:

```text
Research
-> Ingestion
-> Validated Knowledge Base
-> Curated Content and Media
-> Generative UI and MCP UI Experiences
-> User Interaction and Outcome Evaluation
-> Improvement Candidates
```

### Expertly curated content

The system must support the creation, review, publication, and evaluation of knowledge-derived content such as:

- blog posts and long-form explainers
- knowledge cards and concise summaries
- longevity, health, and avoidance-oriented tips
- protocols, technique guides, and process walkthroughs
- product, compound, biomarker, organization, and intervention profiles
- comparisons and decision-support content
- images that demonstrate a technique or explain a mechanism
- diagrams, charts, animations, audio, and video
- future media and content formats not yet defined

This content should be treated as a governed derivation of the knowledge base rather than as disconnected generated copy. Each content artifact should be able to identify:

- the knowledge, assertions, and evidence from which it was derived
- the target audience, purpose, format, and channel
- its authoring and review workflow
- model, prompt, skill, and configuration versions
- generated and human-edited versions
- media sources, generation details, rights, and usage constraints
- safety, scientific-quality, freshness, and publication evaluations
- supersession, correction, withdrawal, and re-evaluation history

Curated content may combine deterministic templates, agent judgment, human editorial work, and generated media. The specifications must define which content requires expert or human approval and which low-risk content may be published under policy.

### Generative UI and MCP UI

The user application must be able to return interactive, knowledge-grounded UI instead of only text. CopilotKit will facilitate the user-facing agent experience, while generative UI and MCP UI capabilities may provide components, resources, and interactions produced by agents or MCP servers.

For example, a user asking about creatine supplements might receive:

- a concise evidence-grounded explanation
- interactive product cards for relevant products
- comparison controls for formulation, dose, price, certifications, and evidence
- warnings or qualification cards based on the user's context
- expandable provenance and source details
- actions that continue the conversation or launch another workflow

The system should eventually support a governed component registry and experience contract for items such as:

- entity and product cards
- source and citation cards
- evidence comparisons
- timelines and relationship views
- charts and knowledge-graph visualizations
- protocol or technique walkthroughs
- generated images, video, and other media
- forms, selectors, calculators, and decision-support tools
- approval, correction, and feedback interfaces
- MCP-provided interactive resources

A UI component must remain traceable to the data, knowledge, tool results, and decisions used to populate it. The agent should select or compose an allowed experience; it should not gain unrestricted authority to execute arbitrary client code.

Generative UI evaluation must cover more than textual answer quality. It should eventually include:

- component and schema validity
- correct binding between UI properties and knowledge records
- provenance and citation correctness
- scientific and product-claim accuracy
- missing, stale, or misleading data
- action safety and authorization
- interaction behavior and state transitions
- rendering across supported web and mobile surfaces
- accessibility
- media quality and rights
- latency, streaming, interruption, and recovery behavior
- usefulness, comprehension, and user outcomes

User interactions with curated content and generated UI may become evaluation evidence, but they must not silently rewrite canonical knowledge, schemas, prompts, or policies.

## OpenAI SDK Documentation and Skills

OpenAI's public, read-only developer-documentation MCP server is the preferred live documentation source:

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
```

Its server URL is `https://developers.openai.com/mcp`. Agents should query it before relying on static notes for current OpenAI API or SDK details.

An existing local `openai-agents-sdk` skill was found at:

```text
C:\Users\Pinda\Proyectos\Biotech\humanupgrade-research-ingestion\.agents\skills\openai-agents-sdk
```

It covers agents, tools, structured output, streaming, handoffs, guardrails, sessions, and common patterns. It is an offline implementation aid; the Docs MCP and official SDK documentation take precedence. Before implementation, decide whether to promote or refresh it into the active BellLabs project rather than create divergent copies.

Previously installed LangChain, LangGraph, and Deep Agents skills may remain for historical comparison or migration analysis, but they no longer describe the selected runtime architecture.

The repository also contains project-specific research, ingestion, source-discovery, parsing, and Neo4j skills. Those can eventually be selected and preloaded into workflow-specific sandbox templates after the workflow contracts and workspace requirements are specified.

## Current Technology Direction

### Application runtime

- **Language:** Python
- **API server:** FastAPI
- **Agent harness:** OpenAI Agents SDK for Python
- **Durable execution engine:** Temporal
- **Default model path:** OpenAI models through the SDK's native Responses integration
- **Non-OpenAI model path:** LiteLLM, only when intentionally required
- **Agent-facing UI:** CopilotKit through the dashboard and user-application control plane
- **Interactive experience transport:** generative UI and MCP UI contracts, to be specified

### Knowledge and persistence

- **Neo4j:** authoritative knowledge graph and graph-oriented knowledge representation
- **Supabase PostgreSQL:** durable Agents SDK sessions plus application control-plane records where relational and transactional access patterns fit
- **Temporal persistence:** owned by the Temporal deployment and correlated with, but not substituted by, application session or domain tables
- **Object storage such as S3:** large source documents, media, converted files, generated reports, sandbox snapshots, and other blob artifacts
- **MongoDB with Beanie:** current candidate for flexible research and ingestion runtime records; not yet accepted as the final choice

### MongoDB and Beanie decision status

MongoDB remains plausible for flexible, evolving research-runtime information such as:

- source intelligence records
- source candidates and extraction attempts
- research packages and working manifests
- decision reports
- repair manifests
- ingestion drafts
- artifact metadata
- sandbox snapshot metadata
- heterogeneous tool outputs

Beanie would provide an asynchronous Python object-document mapping layer that fits the Python and FastAPI environment.

However, MongoDB should not be selected merely because these records are flexible. The storage decision remains open until the specifications expose the real access patterns, transactional boundaries, retention needs, indexing requirements, expected document growth, lineage queries, concurrency behavior, and relationships with PostgreSQL, Neo4j, and object storage.

The alternatives to evaluate include:

- MongoDB with Beanie for a distinct research-runtime document store
- PostgreSQL with JSONB for flexible records close to workflow state and relational control-plane data
- object storage plus PostgreSQL manifests for artifact-heavy workloads
- a deliberately layered combination when the boundaries are clear

No research-runtime database should become an accidental second knowledge graph or an ungoverned source of canonical truth.

## Persistence Boundaries to Preserve

The implementation must distinguish several forms of state:

1. **Domain state** - Research Missions, Workflow Types, Workflow Runs, controls, decisions, status, ownership, lineage, and evaluation outcomes.
2. **Temporal execution state** - workflow history, durable scheduler state, activity and child-workflow progress, timers, signals, updates, queries, and cancellation state.
3. **Agents SDK session and run state** - conversation items, current agent, approvals, interruptions, resumable `RunState`, trace correlation, and context-management metadata.
4. **Sandbox state** - working files, installed packages, browser or shell outputs, generated code, live sandbox session state, and optional snapshots.
5. **Artifact state** - durable documents, media, reports, extracted payloads, manifests, and dataset versions.
6. **Knowledge state** - approved entities, assertions, evidence, provenance, and relationships in Neo4j.
7. **Content and experience state** - curated content, media, component specifications, rendered experiences, interaction records, publication versions, and their knowledge derivations.
8. **Learning state** - evaluation findings and reviewed improvement candidates for prompts, skills, schemas, tools, policies, configurations, content, and UI experiences.

No Temporal history, Agents SDK session, `RunState`, or sandbox snapshot by itself versions Neo4j, external databases, object storage, or the other state planes. The specifications must define how these planes are correlated and how external mutations remain idempotent, auditable, and reproducible.

## Goal of the Specification Sessions

The upcoming interview-driven sessions will create a complete, internally consistent architecture for research, ingestion, and evaluation.

The work should produce:

- a shared ubiquitous language
- bounded contexts and ownership boundaries
- domain entities, value objects, states, and invariants
- Workflow Type and Workflow Run contracts
- stage and checkpoint definitions
- research planning and evidence-handling rules
- source discovery, selection, use, rejection, and freshness rules
- artifact classes and lineage requirements
- ingestion workspace and schema selection behavior
- extraction, normalization, identity resolution, and validation semantics
- Neo4j promotion and mutation rules
- evaluation dimensions, rubrics, gates, and failure classifications
- curated content and generated-media contracts, provenance, review, and publication rules
- generative UI and MCP UI component, data-binding, interaction, and evaluation contracts
- Decision Report contracts
- human approval, interrupt, repair, retry, replay, and cancellation semantics
- sandbox templates, lifecycle, snapshot, and restoration policies
- Agent Skill and MCP server selection rules
- event contracts for the API and dashboard control plane
- persistence and storage ownership decisions
- observability, audit, and reproducibility requirements
- learning-loop rules for proposing and promoting system improvements

Each specification should identify what is deterministic application logic, what is agent judgment, what requires human approval, what may be retried, and what external effects must be idempotent.

## Interview-Driven Design Process

The architecture will be developed across multiple agent sessions. In those sessions, the operator will be interviewed and challenged about how the system should behave.

Each session should:

1. Begin from the latest accepted checkpoint and ADRs.
2. Focus on one bounded workflow, concept, or unresolved decision.
3. Distinguish accepted decisions from hypotheses and open questions.
4. Define examples, counterexamples, failure modes, and edge cases.
5. Update the ubiquitous language when terms are ambiguous or overloaded.
6. Record a new checkpoint or ADR when a decision becomes stable.
7. Defer framework mapping until the domain behavior is sufficiently clear.
8. Then map the accepted behavior to OpenAI Agents SDK, Temporal, FastAPI, persistence, sandbox, and CopilotKit constructs.

The resulting documents should allow a future implementation agent to build the system without inventing missing domain behavior.

## Near-Term Design Sequence

The next architecture work should continue from the existing `StarterContentRefinementWorkflow` checkpoint while progressively defining the larger lifecycle:

1. Complete the Starter Content and Starter Package vocabulary.
2. Specify Mission Instructions and Research Mission controls.
3. Specify source discovery, source intelligence, selection, and evidence adjudication.
4. Specify deep research execution, research workspaces, subagent responsibilities, and research outputs.
5. Specify the ingestion workspace and target schema selection workflow.
6. Specify ingestion planning, extraction, normalization, identity resolution, validation, and Neo4j promotion.
7. Specify evaluation workflows for research quality, source quality, scientific reasoning, ingestion correctness, provenance, graph integrity, and reproducibility.
8. Specify knowledge-derived curated content, media generation, editorial review, publication, and re-evaluation.
9. Specify generative UI and MCP UI component contracts, grounding, actions, security, and experience evaluation.
10. Resolve the flexible research-runtime storage decision using the access patterns uncovered by these specifications.
11. Map the accepted architecture to OpenAI Agents SDK and Temporal execution designs, including the selected dependency-aware and cyclic stage scheduler.
12. Design the FastAPI and CopilotKit control plane around the accepted run, event, artifact, approval, checkpoint, content, and experience contracts.

## Current Outcome

The project has selected its primary orchestration direction and has enough stable domain framing to continue detailed architecture interviews.

The next milestone is not a production implementation. It is a coherent specification set that explains exactly how deep research produces evidence and artifacts, how ingestion transforms approved material into schema-valid knowledge, how evaluation measures both processes and results, how validated knowledge becomes curated content and interactive user experiences, and how the system learns from successful and unsuccessful runs without silently changing its own rules.

The OpenAI Agents SDK and Temporal will implement that architecture. They will not define the BellLabs domain model, stage scheduler, persistence boundaries, or safety policy for us.
