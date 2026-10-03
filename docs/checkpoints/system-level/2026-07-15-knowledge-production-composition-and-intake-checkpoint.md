# Knowledge Production Composition and Intake Checkpoint

Date: 2026-07-15

Status: Accepted domain direction; detailed schemas and runtime mappings remain open

## Purpose

This checkpoint records the accepted intake, conversation, mission, and workflow-composition semantics established after the OpenAI Agents SDK and Temporal architecture checkpoint. It supersedes `Research Mission` as the name of the end-to-end composition while preserving the accepted decision to use first-class composable Workflow Runs.

## North Star

The reference lifecycle may span:

```text
Starter Content and Discussion
-> Starter Package with Pre-Research and Database Preflight
-> Optional Source Discovery
-> Mode-Specific Deep Research
-> Schema Workspace and Schema Selection
-> Report-Grounded Database Lookup
-> Ingestion Planning
-> Ingestion
-> Agent and Information-Retrieval Evaluation
-> Curated Content and Media
-> MCP UI and Generative UI Components
```

This is a reference composition, not a rigid pipeline. A Knowledge Production Mission may enter and exit at any admissible workflow boundary. A Workflow Run may also execute independently without a mission.

## Accepted Intake Model

- A **Starter Collection** is a durable, operator-owned mutable collection that may exist before any Workflow Run.
- A **Starter Artifact** is immutable and version-addressed.
- Replacing an artifact creates a new version and may change the active Starter Collection selection; prior bytes and versions remain preserved.
- A **Repair Artifact** may supersede an original as the active selection but does not destroy it.
- Every Workflow Run binds an immutable **Run Input Manifest** containing exact input references and versions.
- Changes to a Starter Collection after launch do not silently affect an active run. They require an intervention, fork, or new run.

## Starter Package Boundary

- A **Starter Package** is a versioned output of Starter Content Refinement.
- It is not a universal envelope or prerequisite for every Workflow Type.
- A completed report may be supplied directly to an ingestion-planning run when that Workflow Type's input contract permits it.
- A Starter Package may preserve useful partial refinement output even when issues remain.
- Its **Starter Readiness Assessment** records blockers, warnings, and possible next-workflow eligibility.
- A package's existence does not imply unrestricted readiness.

## Admission, Permissions, and Launch

- Every Workflow Type has an **Input Admission Contract** evaluated by deterministic application logic.
- Agent recommendations are advisory and cannot authorize inadmissible inputs.
- A **Workflow Invariant** cannot be bypassed by trust, permission, or human approval.
- A gate explicitly designated as overridable may receive an audited **Policy Gate Override**.
- Humans, services, dashboard actions, and agents all propose execution through a typed **Run Request**.
- The control plane validates identity, delegated authority, admission, policy, budget, and capabilities before execution state is created.
- An orchestrator agent does not directly create execution state or write to domain stores.

## Workflow Composition

- Crossing a Workflow Type boundary always creates a distinct first-class Workflow Run.
- The requesting and requested runs are connected by a durable **Run Composition Link**.
- Internal stages do not become Workflow Runs solely for observability.
- A Workflow Run's mission-owned or standalone execution scope is fixed at creation.
- A later mission may reference a prior standalone run or its outputs but does not retroactively re-parent it.
- The end-to-end composition is not a mega Workflow Run.

## Knowledge Production Mission

- **Knowledge Production Mission** replaces `Research Mission` as the top-level name because the composition may span ingestion, evaluation, content, media, and interactive experiences in addition to research.
- A Knowledge Production Mission is a bounded objective that coordinates linked Workflow Runs.
- It may enter and exit at any admissible boundary while preserving which prior outputs satisfied skipped dependencies.
- Every mission requires an accepted, versioned **Mission Specification**.
- Standalone Workflow Runs do not require a Mission Specification.
- A versioned **Mission Plan** describes proposed Workflow Runs, dependencies, entry inputs, intended outcomes, and gates.
- Mission Plans may be revised explicitly. Accepted revisions preserve prior versions and rationale; they do not silently rewrite active or completed runs.

## Conversation and Command Boundary

- A **Conversation Thread** preserves the full interaction among participants and a coordinator agent, including messages, tool interactions, results, and approvals.
- The conversation is context and audit evidence, not canonical workflow state or an execution-ready instruction by itself.
- An **Intake Brief** is a versioned statement of accepted objective, scope, constraints, context, unresolved questions, and operator decisions distilled from the thread.
- A run binds an exact Intake Brief version and retains references to the supporting conversation turns.
- A **Mission Specification** is distinct from the Intake Brief. It is the execution-ready objective and success contract for a Knowledge Production Mission.

The intended command path is:

```text
Conversation Turn
-> Coordinator Tool Call
-> Typed Command Proposal
-> Control-Plane Validation and Approval
-> Accepted Domain Command
-> Temporal Execution
-> Durable Application Events
-> Dashboard WebSocket and Coordinator Context
```

Coordinator tools may be exposed as local function tools or through MCP, but they call project-owned application services. Agent reasoning does not directly mutate Temporal, Neo4j, PostgreSQL, MongoDB, object storage, or other state planes.

## OpenAI Agents SDK and Temporal Mapping

The current domain decisions map provisionally as follows:

- Agents SDK Sessions retain coordinator conversation history in PostgreSQL but are not canonical mission or workflow records.
- Typed function tools or MCP tools carry query and command schemas.
- SDK tool approval interruptions and serializable `RunState` may implement conversational pauses, while domain approval records remain authoritative.
- SDK streaming events are translated into versioned application events rather than exposed directly.
- Temporal owns accepted long-running execution and durable coordination after the control plane validates a command.

This mapping is intentionally subordinate to the domain contracts and must be verified again during implementation.

## Next Interview Target

Continue with the exact boundary among:

- Intake Brief
- Starter Content Refinement inputs
- Starter Package contents
- pre-research and graph/database preflight
- optional source discovery
- Mission Specification creation

The next decisions should establish which findings belong in the Starter Package, which are reusable source or graph intelligence, and which become authoritative mission instructions.
