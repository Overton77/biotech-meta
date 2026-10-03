# OpenAI Agents SDK and Temporal Architecture Notes

Date: 2026-07-15

Status: Accepted technology direction with open workflow-design decisions

## Decision

BellLabs will use the **OpenAI Agents SDK for Python** as its primary agent harness and **Temporal** as its durable execution engine. OpenAI models through the SDK's native Responses path are the default. **LiteLLM is reserved for workflows that intentionally use non-OpenAI model providers.**

This does not yet select the scheduling algorithm for deep-research stages. The interview-driven specification work must decide how stages with dependencies, cycles, fan-out, convergence criteria, budgets, and human checkpoints are represented and scheduled. Temporal will execute that accepted model durably; it should not silently define the domain semantics for us.

## Documentation Access for Agents

OpenAI operates a public, read-only documentation MCP server at `https://developers.openai.com/mcp`. It provides documentation search and page retrieval; it does not call the OpenAI API.

Recommended Codex setup:

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
```

Equivalent Codex configuration:

```toml
[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

Agents working on OpenAI integrations should query this MCP server before relying on static notes for current API fields, model behavior, or SDK details.

An existing local `openai-agents-sdk` skill was also found at:

```text
C:\Users\Pinda\Proyectos\Biotech\humanupgrade-research-ingestion\.agents\skills\openai-agents-sdk
```

It includes static references for agents, tools, structured output, streaming, handoffs, guardrails, sessions, and common patterns. It is useful as an offline implementation aid, but the live Docs MCP and official SDK documentation take precedence when they differ. Before BellLabs implementation starts, decide whether to promote or refresh that skill into the active project's skill directory rather than maintaining divergent copies.

Official references:

- [OpenAI Agents SDK documentation](https://openai.github.io/openai-agents-python/)
- [Docs MCP setup](https://developers.openai.com/learn/docs-mcp)
- [OpenAI Agents SDK repository and examples](https://github.com/openai/openai-agents-python)
- [Temporal sandbox-agent example](https://github.com/openai/openai-agents-python/tree/main/examples/sandbox/extensions/temporal)

## Runtime Boundary

### OpenAI Agents SDK owns

- agent definitions, instructions, tools, guardrails, and model calls
- the agent loop through `Runner`
- OpenAI Responses integration and model configuration
- SDK sessions and conversational history
- streaming agent, item, tool, and raw response events
- handoffs and manager-style agents-as-tools orchestration
- sandbox-agent definitions, manifests, capabilities, and sandbox run configuration
- run state, approvals, tracing, and agent-level resume behavior

### Temporal owns

- durable workflow execution and event history
- activities, retries, timeouts, timers, and long waits
- signals, queries, updates, cancellation, and operational intervention
- workflow and child-workflow lifecycle
- durable coordination across worker restarts and deployments
- the execution of the BellLabs stage graph or cyclic scheduling model after that model is specified

### BellLabs application code owns

- Research Mission, Workflow Type, Workflow Run, Stage, Artifact, Decision Report, and Evaluation semantics
- the scheduling algorithm and termination rules for dependency-aware or cyclic deep research
- idempotency keys and transactional boundaries around external effects
- authorization, human approval policy, budgets, and safety policy
- projections into PostgreSQL, Neo4j, object storage, and any accepted research-record store
- compilation from domain workflow configuration into Temporal workflows and Agents SDK run configuration

Temporal workflow code must remain deterministic. Network calls, model execution, database writes, sandbox-provider calls, and other nondeterministic effects belong in activities. The detailed activity boundaries, retry policies, and replay-safe identifiers remain specification work.

## Sandboxes

The SDK's `SandboxAgent` is still an `Agent`, so it retains normal instructions, tools, handoffs, MCP servers, model settings, guardrails, and hooks. The sandbox additions divide responsibility among:

- `SandboxAgent`: the agent definition plus defaults such as its manifest and capabilities
- `Manifest`: the desired initial workspace contents for a fresh sandbox
- `SandboxRunConfig`: how a run injects, resumes, or creates a sandbox session
- sandbox client and sandbox session: where commands execute and files change
- `RunState`, serialized session state, and snapshots: different mechanisms for resuming execution or seeding later work

Conversational SDK sessions and sandbox sessions are different concepts. The former retain agent conversation items; the latter represent an isolated execution environment and its workspace.

The documented client progression is local Unix for development, Docker for container isolation or image parity, and hosted providers when managed execution is needed. BellLabs should evaluate the official Temporal sandbox-agent example before selecting a provider. That example demonstrates a long-lived Temporal workflow, multiple sandbox backends, switching, snapshots, and workflow forks.

Sandbox agents are currently documented as **beta**. BellLabs should therefore:

- isolate sandbox integration behind a project-owned adapter
- pin and test SDK versions
- use explicit capability profiles and least privilege
- treat manifests, snapshots, and artifact promotion as governed contracts
- avoid making beta API shapes part of the domain model

## Sessions and Persistence

Agents SDK sessions automatically load prior conversation items before a run and append new run items afterward. A run that pauses for approval should resume with the same logical session and `RunState` so the conversation and interruption remain coherent.

For BellLabs:

- use **Supabase PostgreSQL** as the intended durable Agents SDK session store
- begin with the SDK's `SQLAlchemySession` using an async PostgreSQL engine, unless requirements justify a project-specific `Session` implementation
- use stable, namespaced session identifiers that correlate tenant, Research Mission, Workflow Run, stage, agent role, and optional branch without exposing sensitive data
- define retention, encryption, compaction, deletion, concurrency, and audit behavior before production
- do not treat an SDK session as the canonical Research Mission or Workflow Run record

The SDK documents `SQLAlchemySession` as the production-oriented adapter for SQLAlchemy-supported databases, including async PostgreSQL. It also offers MongoDB and other session implementations, but that does not change the accepted decision to use Supabase PostgreSQL for BellLabs sessions.

The separate choice between PostgreSQL/JSONB and MongoDB with the async PyMongo client and Beanie for research collections remains open. Candidate records include missions, stages, source candidates, artifacts, evaluation details, and heterogeneous research outputs. That decision must follow access patterns and consistency boundaries, not the session adapter chosen by the SDK.

## Streaming

`Runner.run_streamed()` returns a streaming result whose `stream_events()` async iterator must be drained to completion. The SDK exposes three useful levels:

- raw Responses events for token or response deltas
- run-item events for completed messages, tool calls, tool outputs, handoff requests, and MCP events
- agent-updated events when a handoff changes the active agent

BellLabs should translate these into a versioned application event contract rather than expose SDK event objects directly. A streamed run is not complete merely because the last visible token arrived: session persistence, approval bookkeeping, or compaction may still finish before the iterator closes.

Approval interruptions end the current stream. The application must persist the resumable state, collect an approve or reject decision, and resume the run from state. Cancellation semantics must distinguish immediate cancellation from stopping after the current turn. Temporal events and identifiers should correlate with SDK trace, run, session, stage, tool-call, and artifact identifiers.

## Subagents, Agents as Tools, and Handoffs

The SDK supports two primary local orchestration patterns:

- **Agents as tools:** a manager agent retains control, invokes specialists through `Agent.as_tool()`, and synthesizes the final answer. Prefer this when one coordinator owns shared guardrails, output structure, or final synthesis.
- **Handoffs:** the current agent delegates and the specialist becomes the active agent for the rest of the turn. Prefer this for triage and direct specialist ownership.

Handoffs are model-visible tools and can carry descriptions, typed input, callbacks, and input filters. They are not a durable stage scheduler. BellLabs must persist the consequential effects and lineage of delegation in its workflow records even when the SDK trace also captures them.

For independent research branches, deterministic fan-out, dependency tracking, joins, budgets, or repeated cycles, orchestration should normally be expressed in Temporal and application code. The SDK remains responsible for cognition within an activity or stage. LLM-directed delegation is appropriate inside explicitly bounded stages where the model is allowed to choose specialists.

OpenAI also documents an experimental hosted multi-agent path. It is separate from local SDK handoffs and agents-as-tools and should not be adopted as the BellLabs scheduling layer without a later decision and evaluation.

## Temporal Integration

OpenAI's repository includes a first-party Temporal sandbox-agent example. It demonstrates:

- a durable, long-lived `AgentWorkflow`
- one `Runner.run()` per conversational turn
- sandbox backend selection through run configuration
- a session-manager workflow for create, fork, switch, and destroy operations
- user interaction through Temporal signals, updates, and queries
- portable snapshots when switching backends
- child-workflow forks with independent conversation and workspace state
- optional OpenAI tracing and Temporal spans

This is strong evidence that the SDK and Temporal are intended to compose, but it is an example integration rather than BellLabs' finished research runtime. We still need to decide:

- whether a Research Mission, Workflow Run, stage, or long-lived research session maps to a Temporal workflow
- how dependency-aware stages become child workflows, activities, or durable scheduler state
- how cyclic stages terminate, checkpoint, continue-as-new, and respect history limits
- where the Agents SDK `RunState`, SDK session, sandbox state, and Temporal workflow state are stored and correlated
- how model retries differ from activity retries so a nondeterministic model call is not duplicated unsafely
- how approval, cancellation, fork, resume, and artifact promotion behave across all state planes

## Model Provider Policy

Use the native OpenAI Responses model path for OpenAI-family models. Do not put LiteLLM in front of OpenAI by default.

Use the Agents SDK LiteLLM adapter only when a workflow intentionally needs non-OpenAI provider coverage or LiteLLM-managed routing. The adapter is currently documented as best-effort and beta, so each selected provider must be tested for structured output, tool calling, streaming, usage reporting, and any Responses-specific behavior the workflow depends on.

## Interview Decisions Still Required

The upcoming specification interviews should resolve:

1. The stage dependency and cyclic scheduling model, including convergence and maximum-work rules.
2. Temporal workflow granularity, child-workflow policy, task queues, and continue-as-new policy.
3. Activity boundaries and retry/idempotency policy for model calls, tools, databases, and sandboxes.
4. Session identifier, branching, compaction, retention, privacy, and concurrency contracts in Supabase PostgreSQL.
5. PostgreSQL/JSONB versus MongoDB/Beanie for research-domain and artifact metadata collections.
6. Sandbox provider, capability profiles, snapshot policy, and beta-containment strategy.
7. The application streaming/event schema and dashboard recovery behavior.
8. When to use deterministic Temporal fan-out, manager agents, agents-as-tools, handoffs, or bounded LLM-selected delegation.

