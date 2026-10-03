# AI-native system architecture perspectives

Date: 2026-08-11  
Status: brainstorm checkpoint — not yet authoritative  
Purpose: Codify the perspectives through which BellLabs should architect, document, and implement the research/ingestion evaluation system and its surrounding agentic tooling. Use this to design folder models, Linear projects/issues, specs, and implementation work packages without pretending the system has only one clean taxonomy. Keep the compounding knowledge-base north star in view so layer work does not become an end in itself.

Related:

- `biotech-meta/docs/BellLabs/index.md` — product north star and document index
- `biotech-meta/docs/BellLabs/roadmap.md` — phased path from graph/research → compounding knowledge → products
- `belllabs-agentic-frontier/` — synthesis lab for cutting-edge agentic talks/tools → BellLabs implications (often AI Engineer channel)
- `biotech-meta/docs/tech_stack_and_operational_authority.md`
- `biotech-meta/docs/CONTEXT.md`
- `biotech-meta/docs/adr/0003-temporal-deepagents-control-plane-runtime.md`
- `biotech-meta/docs/decision-packets/2026-08-09-control-plane-foundations.md`
- `biotech-meta/docs/checkpoints/agent-capability-layers/2026-07-19-biotech-research-agent-capability-layers.md`
- Linear project: [biotech-research-ingestion-evaluation-system](https://linear.app/overtonbell/project/biotech-research-ingestion-evaluation-system-eb39b5900064)

---

## North star: compounding knowledge → agentic products

**Do not get narrow-minded inside Runtime, Harness, Temporal, or any single bucket.**

The point of the biotech research and ingestion evaluation system is not to perfect orchestration for its own sake. It is to **build a powerful knowledge base** — optimized for **agentic retrieval and reasoning** — and then **derive product surfaces from that knowledge base** (the knowledge graph plus its retrieval mechanisms).

### What we are compounding

```text
Starter content / questions / missions
        ↓ research + evidence
Research artifacts, claims, provenance
        ↓ governed ingestion + evaluation
Knowledge graph + retrieval (Graph RAG, indexes, schemas, tools)
        ↓ derive / publish
APIs · MCP servers · Agent Skills · Web apps · Mobile apps
```

Roadmap language for the same idea: Phase 2 turns BellLabs from a research assistant into a **compounding knowledge system**; later phases (cart, personal graph, protocol studio, marketplace, ME2) only stay coherent if the graph and retrieval layer keep getting stronger ([roadmap](../../BellLabs/roadmap.md), [index](../../BellLabs/index.md)).

### Why this informs every layer


| Layer / perspective              | Must still serve                                                                               |
| -------------------------------- | ---------------------------------------------------------------------------------------------- |
| Business logic                   | Knowledge that is scientifically meaningful, reviewable, and product-useful                    |
| Harness                          | Agents that can *find, use, and propose* knowledge without inventing authority                 |
| Runtime / control plane          | Long-running research → ingestion → admission loops that leave durable KG improvements         |
| Sandboxes / tools / integrations | Source procurement and computation that feed evidence, not orphan scratch files                |
| Context / memory                 | Working sets and memories that improve retrieval and reasoning over the KB                     |
| Evals                            | Measure knowledge quality, citation fidelity, retrieval usefulness — not only agent cleverness |
| UX / operator control plane      | Humans supervising missions and ingestion so the graph compounds safely                        |
| Auth / safety                    | Least privilege around what may be written into shared knowledge                               |
| SDLC agents / Linear             | Delivery machinery for the above — not a substitute product                                    |


### Anti-narrow-mindedness rules

1. **Ask the KB question on every decision:** Does this make the knowledge base more correct, more complete, more provenance-rich, or more usable for agentic retrieval and reasoning — or does it only make an internal subsystem prettier?
2. **Orchestration is means, not end.** Temporal, Deep Agents, blueprints, and dashboards earn their keep by producing admitted knowledge and trustworthy derived surfaces.
3. **Derived surfaces are not a later afterthought.** APIs, MCP servers, Agent Skills, and web/mobile apps should be designed as *projections and action channels over the same knowledge + retrieval core*, not as separate products with private truth.
4. **Retrieval is part of the knowledge base.** Schema maps, Graph RAG, vector indexes, competency questions, and tool/MCP access patterns are first-class KB concerns — not “just UX” or “just infra.”
5. **Research without ingestion is incomplete; ingestion without eval is unsafe.** The loop closes when missions improve the graph and the graph improves the next mission.
6. **When deep in a bucket, re-zoom.** If a discussion has spent many turns on retries, prompts, or folder taxonomy with no link back to KB compounding or derived surfaces, pause and reconnect.

### Derived surfaces (explicit product outputs)

From the knowledge graph and its retrieval mechanisms, BellLabs intends to derive:

- **APIs** — programmatic access to entities, claims, evidence, missions, and personal/public graph projections
- **MCP servers** — agent-consumable tools over the same governed knowledge and control paths
- **Agent Skills** — packaged procedures that encode how to research, retrieve, ingest, and explain using the KB
- **Web and mobile apps** — human surfaces for exploration, decisions, protocols, and personal tracking

These surfaces should share authority with the graph and ledgers. A chat UI or MCP tool must not become a second source of truth.

### Decision filter (use in interviews, specs, and Linear issues)

Before accepting a substantial design or WP, answer briefly:

1. What knowledge (entities, claims, evidence, retrieval affordances) does this improve or protect?
2. Which derived surface(s) will eventually consume that improvement (API / MCP / Skill / web / mobile / operator tools)?
3. What would make this change a local optimization that does *not* compound the KB?
4. In this fast-moving LLM-agent ecosystem, are we learning from pre-eminent orgs and practitioners — and have we checked for cutting-edge libraries, tools, talks, or production examples that already solve (or partially solve) the problem in front of us?

If (1) and (2) are empty, the work may still be necessary scaffolding — but label it as scaffolding and keep it thin.

On (4): do not invent in a vacuum when the frontier already has signal. Prefer deliberate adopt / adapt / reject over accidental NIH. Capture the trail in `belllabs-agentic-frontier/` (or link an existing reasoning doc) when the external idea is material.

### External signal loop (dump / working idea)

The agent ecosystem is young and moves faster than mainstream docs. BellLabs should systematically pull from top practitioners and companies — especially **before** patterns become default Stack Overflow wisdom.

**AI Engineer channel** (and peers): talks from leading AI companies and engineers on production agentic systems, evals, harnesses, verifiability, tooling, etc. High-leverage source for strategies and libraries that are cutting-edge but not yet “standard.”

`**belllabs-agentic-frontier/`** (workspace synthesis lab — may later fold tighter into meta/docs or product process):

- Absorb talks/papers/production systems (transcript → summary → entities → BellLabs reasoning)
- Stress-test ideas against our domain (research, ingestion, KG, governed workflows)
- Decide what to adopt, adapt, or reject — with implications pointed at specs/WPs/Linear
- Not implementation code; a radar + digestion layer so Runtime/Harness/KB work stays connected to the frontier

Working habit ideas (not yet process law):

- When stuck on a bucket problem (evals, memory, sandboxes, retrieval, …), search frontier talks/reasoning before freezing a homemade pattern
- Link Linear issues / WPs back to a frontier reasoning doc when an external pattern influenced the design
- Harrison Chase / managed Deep Agents–style talks are exactly the kind of input this loop should catch and translate — without letting vendor framing overwrite BellLabs authority
- Eventually: thin “adopted patterns” index from frontier → `biotech-meta` ADRs/specs so the signal compounds instead of rotting in talk folders

---

## 1. How to use this document

These are **perspectives / lenses**, not exclusive folders and not ownership silos.

- Read the **North star** section first; return to it when a thread gets deep in one bucket.
- Every real feature will touch multiple buckets.
- Overlap and synthesis are expected; the goal is to know *which lens you are speaking in* at any moment.
- Documentation, Linear issues, and code ownership may each use different cuts of the same taxonomy.
- Prefer: “this issue is primarily Runtime / Cancellation, grounded in SPEC-CP-DURABLE-EXECUTION, in service of reliable ingestion admission into the KG” over forcing every concern into one tree or forgetting why the runtime exists.

Working rule for process design:


| Artifact class                    | Lives where                                                          | Answers                   |
| --------------------------------- | -------------------------------------------------------------------- | ------------------------- |
| Interviews, checkpoints, ideas    | `biotech-meta/docs` (exploratory)                                    | What are we thinking?     |
| Official architecture / decisions | Timestamped ADRs, decision packets, accepted checkpoints             | What did we decide?       |
| Specifications                    | `biotech-meta/docs/specs`                                            | What must be true?        |
| Executable work                   | Linear issues → PRs in app repos                                     | What are we building now? |
| As-built code truth               | `biotech-research-ingestion-evaluation-system/app` (+ related repos) | What exists?              |


---

## 2. Production agentic stack (Harrison Chase framing, BellLabs-adapted)

Harrison Chase’s “managed deep agents” talk surfaces a useful three-layer production stack. BellLabs should adopt the framing and then **own the boundaries**.

### 2.1 Business logic

**BellLabs-owned.** Domain meaning, product behavior, scientific/research workflow semantics, and operator-facing product features.

Includes:

- Biotech / longevity / biohacking research reasoning and product roadmap features
- Workflow families (StageGraph, GoalDirected) and their semantic interpreters
- Domain contracts: admission, budgets, settlement, linked runs, evidence, knowledge admission
- Product rules: what a run is allowed to do, what counts as success, what requires human approval

Supported and synthesized with best practices from biotech, software engineering, and AI — but **authority stays BellLabs**. Frameworks do not become the business.

### 2.2 Harness (agent scratchpad / cognitive envelope)

The agent’s bounded working environment: what it can think with, write to, call, and temporarily hold.

Candidate contents (expand / combine as we refine):

- Deep Agents / LangGraph bounded cognition inside an operation
- Prompts, dynamic instructions, system/developer messages
- Tools and MCP servers (bound, versioned, least-privilege)
- Agent Skills
- Filesystem / workspace / artifact scratch surfaces
- Short-lived thread/checkpointed execution state
- Subagents (sync and async) as harness-local delegation, not macro workflows
- Context packing, summarization, and working-set management during a turn/operation

**Harness is not infrastructure and not business authority.**  
Checkpoints, traces, tool availability, and skill presence never become domain truth by existing.

### 2.3 Infrastructure

The durable substrate that hosts, schedules, stores, and observes.

Includes (non-exhaustive):

- Temporal (sole production macro-workflow runtime)
- AWS (or equivalent cloud)
- FastAPI / API surfaces
- Sandboxes / isolation hosts
- PostgreSQL (transactional lifecycle, commands, budgets, effects, settlement, product events)
- MongoDB (declared document-shaped definitions, configs, manifests)
- Neo4j (accepted knowledge-graph state)
- S3 (large immutable artifacts)
- LangSmith (tracing, evals, sandboxes, selected remote graph placement)
- Queues, workers, networking, secrets, observability backends  
-   Frontier Model APIs (We will need to hit them directly for things like the openai batch api for pricing and processing needs) 

---

## 3. Reconciling two meanings of “Business Logic”

This confusion is real and should be named explicitly.

### 3.1 Product / company business logic

BellLabs biotech reasoning, research product roadmap, operator workflows, feature intent, market/product constraints.

Examples:

- “Operators refine starter content into a package before knowledge preflight”
- “Accepted KG assertions require provenance”
- Roadmap: dashboard control plane, coordinator, ingestion evaluation loops

Home: product docs, interviews, decision packets, roadmap notes — eventually linked from Linear epics.

### 3.2 In-software domain / application business logic

The coded semantic core of the backend: interpreters, contracts, reducers, admission rules, settlement, workflow type policies.

Examples:

- StageGraphInterpreter readiness/joins/cycles
- GoalDirected goal revision / verification transitions
- Run control budgets and family admission
- Operation boundary escalation policy

Home: `app/domain` (+ application orchestration), governed by `SPEC-`* / `ADR-*`.

### 3.3 Recommended reconciliation

Treat them as **two altitudes of the same BellLabs ownership**, not two competing centers:

1. **Product business logic** decides *what capabilities and outcomes the product must offer*.
2. **Software domain logic** encodes *exact machine-enforceable meaning* of those outcomes.
3. Specs are the bridge: product intent → requirements → domain contracts → implementation WPs → Linear issues.

Do **not** put product roadmap prose inside interpreters.  
Do **not** let framework defaults silently invent product policy.

---

## 4. Core architecture perspectives (primary buckets)

These are the main lenses for an AI-native BellLabs backend. Each bucket will later spawn subfolders, specs, and Linear labels/milestones.

### 4.1 Runtime

Durable execution and controlled progress of work over time.

Already named:

- Durable execution
- Fault tolerance
- Streaming
- Queueing
- Run cancellation
- Fallbacks

Add / expand:

- Admission and lifecycle state machines
- Retries, timeouts, deadlines, Continue-As-New / history management
- Idempotency and exactly-once / at-least-once effect handling
- Compensation / rollback semantics where applicable
- Heartbeats, liveness, stuck-run detection
- Pause / resume / human interrupt / operator intervention hooks
- Budget exhaustion and degradation policies
- Linked runs, forks, epochs, and result admission
- Operation vs workflow vs async-subagent lifecycle boundaries
- Deterministic interpreters vs non-deterministic cognition placement
- Backpressure, concurrency limits, fairness
- Replay, redrive, and forensic reconstruction of a run
- Provider placement (`local_in_worker` vs remote LangSmith deployment) without silent fallback

Authority reminder: Temporal owns macro durability; BellLabs owns semantic terminality and meaning.

### 4.2 Sandboxes

Running untrusted or least-trusted code and tools safely.

- Isolation boundaries (process, container, VM, provider sandbox)
- Network / filesystem / secret egress policy
- Tool allowlists and executable catalogs
- Artifact import/export across the sandbox boundary
- Reproducibility of sandbox images / environment pins
- Cost and lifetime controls
- Relationship to LangSmith sandboxes vs BellLabs-owned sandbox profiles
- “Agent-authored code” promotion path (proposal → review → catalog → authority)

### 4.3 Context management

What the agent needs to know, where it lives, and who controls it.

- Working set vs durable stores
- Prompt assembly and instruction layering
- Schema grounding / ontology / CONTEXT language injection
- Conversation thread vs Intake Brief vs Run Input Manifest
- Artifact indexes and workspace materialization
- Context budgets, compaction, summarization, citation retention
- What may influence the next decision vs what is merely audit evidence
- Explicit non-authority: LangGraph checkpoints / sessions are continuity, not policy

Related but distinct from Memory (below): context is the *current cognitive envelope*; memory is *governed reusable knowledge across time*.

### 4.4 AuthN / AuthZ

Authentication and authorization across humans, agents, tools, and services.

- Operator identity and roles
- Service-to-service auth
- MCP / tool invocation authority
- Capability-based authorization (Execution Capability Profiles, Delegation Ceilings)
- Secrets and credential brokerage into harness/sandboxes
- Audit: who/what authorized an escalation, revision, or admission
- “Presence of a tool” ≠ “permission to use it for this run”

### 4.5 UX / Operator control plane

Exposing research and ingestion agents to BellLabs operators.

- Dashboard for run monitoring
- Intervention: pause, cancel, revise controls, approve escalations, admit/reject results
- Conversation / intake surfaces
- Artifact inspection and provenance browsing
- Eval and quality review UIs
- Realtime projections vs authoritative ledgers
- Human-in-the-loop as a first-class runtime peer, not a bolted-on chat window

### 4.6 Memory

Governed long-term reusable context. Distinct from checkpointed execution state.

- Semantic memory (facts / knowledge)
- Episodic memory (what happened in prior runs/missions)
- Procedural memory (how to do classes of work; skills/playbooks)
- Memory manager: write policies, retention, retrieval, conflict, provenance
- Mission / workflow memory vs personal operator memory vs organization memory
- Promotion into KG / catalogs only through governed admission

### 4.7 Evals

How we know the system is getting better and not quietly wrong.

- Offline eval suites (fixtures, golden traces, competency questions)
- Online / production evals and sampling
- Source fidelity, citation integrity, schema grounding scores
- Workflow composition evals (did the blueprint do the right thing?)
- Agent trajectory evals vs final-artifact evals
- Regression gates for prompts, skills, models, and interpreters
- LangSmith (and other) eval harnesses as infrastructure under BellLabs criteria
- Human review loops and label stores

---

## 5. Additional perspectives we should name

These were not in the initial list but are first-class for BellLabs.

### 5.1 Control plane / catalogs

Governed selection and binding of agentic assets before execution.

- Workflow Type definitions and Effective Run Configuration
- DeepAgentProfile → DeepAgentExecutionBinding
- Prompt / Skill / MCP / sandbox / model catalogs
- Compatibility, drift detection, version pins
- “Compile exact capabilities; do not improvise authority at runtime”

### 5.2 Blueprints / workflow semantics

BellLabs-owned orchestration meaning.

- StageGraph family
- GoalDirected family
- Future blueprint families
- Pure interpreters vs Temporal family workflows
- Linked composition and escalation across workflow types

### 5.3 Knowledge base / evidence / provenance / retrieval

**Primary product asset of the research and ingestion system** — not a side database.

Scientific trust, graph state, and agentic retrieval as one compounding core:

- Assertion-centered temporal KG (accepted Neo4j state)
- Source intelligence and document fidelity
- Evidence graphs from claim → tool binding → artifact
- Retraction / conflict / supersession handling
- Ingestion candidates, review, admission, rollback metadata
- Schema maps and compact schema selection for agents
- Graph RAG, chunk/vector indexes, and retrieval evals
- Competency questions and ontology-lab feedback into schema/retrieval quality
- Ingestion evaluation criteria and post-mission eval case generation

If a design improves the workflow engine but leaves the KB harder to retrieve, ground, or trust, it is incomplete.

### 5.3a Derived product surfaces

How the knowledge base becomes BellLabs products (see North star).

- Public/internal **APIs** over graph, evidence, missions, and personal projections
- **MCP servers** exposing governed retrieve / research / ingest / control tools
- **Agent Skills** that operationalize KB-native procedures for coordinators and coding agents
- **Web and mobile apps** for exploration, cart/decision ledger, protocols, dashboards
- Operator tools as a specialized surface — still projections over the same authorities

Treat “how will this be exposed?” as a design question during KB and control-plane work, not only during app sprints.

### 5.4 Observability & forensicability

Not just “logging.”

- Traces, structured product events, command/message ledgers
- Correlation across Temporal, agent traces, DB events, artifacts
- Why a run did what it did — reconstructable after the fact
- Operator-facing timeline projections

### 5.5 Data plane & storage authorities

Who owns which shape of truth.

- PostgreSQL transactional authority
- MongoDB document authorities
- Neo4j accepted graph state
- S3 immutable bundles
- What is projection vs source of truth

### 5.6 Integration & capability plane

External and internal tools the agent may use (see capability-layers checkpoint).

- Web, literature, trials, normalization, documents, storage adapters
- Provider adapters behind stable ports
- Rate limits, caching, provider failover under BellLabs policy

### 5.7 Safety, compliance, and trust boundaries

Especially for biotech-adjacent systems.

- Untrusted content handling
- PHI / secrets / credential hygiene (never commit; minimize exposure)
- Research ≠ medical advice product constraints
- Model/tool misuse and prompt-injection defenses
- Human approval gates for high-impact side effects

### 5.8 Cost, budgets, and capacity

- Token / tool / sandbox / wall-clock budgets
- Per-run and per-tenant quotas
- Degradation and stop policies
- FinOps visibility for agentic workloads

### 5.9 Developer / agentic engineering experience (AI-native SDLC)

How humans and coding agents build the system.

- Cursor Cloud Agents + `environment.json` / repo rules
- Claude Code, Codex, and other AI-native editors
- Agent Skills and MCP servers for *building* BellLabs (not only for research agents)
- Linear as remote issue authority for delivery
- Code documentation that is agent-consumable
- Work-package protocols, parallel worktrees, acceptance evidence

This is a **meta-system**: the factory that builds the product. It deserves its own docs and Linear hygiene, but must not overwrite product runtime authority.

### 5.10 Coordinator plane

A coordinator agent interacting with research/ingestion through MCP servers and Agent Skills.

- Coordinator as product operator/agent, not a second macro scheduler
- Capability retrieval and workflow trigger patterns
- Separation: coordinator conversation vs admitted Workflow Run
- Skills/MCP that expose governed control APIs rather than raw DB access

---

## 6. Agent + runtime component inventory (brainstorm list)

Use this as a checklist when scoping specs and issues. Many items span buckets.

**Identity & binding**

- Workflow Run, Operation, Async Subagent identities
- DeepAgentProfile / ExecutionBinding
- Model / prompt / skill / tool / MCP exact pins
- Workspace and artifact bindings

**Cognitive loop**

- Planner / todo list / progress scratch
- Tool calling loop
- Reflection / verification steps (especially GoalDirected)
- Context compaction and rehydration
- Subagent spawn / wait / reconcile / late-result policy

**Control & policy**

- Admission
- Budgets
- Escalation policy
- Approval gates
- Cancellation propagation
- Fallback graphs (declared, not improvised)

**Surfaces**

- FastAPI
- MCP control/data tools
- CLI / notebooks / labs
- Operator dashboard
- Coding-agent interfaces (Cursor, Claude Code, Codex)

**Evidence**

- Traces
- Journals / ledgers
- Artifacts
- Eval records
- Decision packets / ADRs for human decisions

---

## 7. Suggested layering map (stack × perspectives)

A compact way to remember where concerns land:

```text
North star                 → compounding KB (graph + retrieval) → derived surfaces
Product business logic     → roadmap, operator outcomes, research product intent
Software domain logic      → interpreters, contracts, policies (BellLabs-owned)
Harness                    → Deep Agents, prompts, tools/MCP/skills, FS, working context
Runtime control            → Temporal + BellLabs run/operation lifecycle
Infrastructure             → cloud, DB, sandboxes, queues, observability backends
Meta / SDLC agents         → Cursor/Claude/Codex + Linear + docs/skills for building
```

Cross-cutting: Auth, Evals, Memory, Provenance, Cost, Safety, UX.  
Derived surfaces (API / MCP / Skills / web / mobile) sit on the KB + retrieval core, not beside a private truth store.

---

## 8. Implications for documentation and implementation process

### 8.1 Document classes (proposed)


| Class                  | Intent                                    | Cadence                            |
| ---------------------- | ----------------------------------------- | ---------------------------------- |
| Interview / idea notes | Capture raw thinking                      | Frequent, low ceremony             |
| Checkpoints            | Synthesize perspectives; grill candidates | Periodic                           |
| Decision packets       | Record confirmed choices                  | When interviewing decisions        |
| ADRs                   | Normative architecture decisions          | When freezing a boundary           |
| Specs (`SPEC-*`)       | Requirements-grade truth                  | Before / with implementation waves |
| Work packages (`WP-*`) | Implementation slices                     | Derived from specs                 |
| Linear issues          | Remote executable tracking                | Derived from WPs / checkpoints     |
| As-built guides        | Code truth for agents/humans              | Updated with merges                |


### 8.2 Perspective tags (proposed for Linear + docs frontmatter)

Start simple; expand only when useful:

`runtime` · `sandbox` · `context` · `auth` · `ux` · `memory` · `evals` · `control-plane` · `blueprint` · `knowledge-base` · `retrieval` · `derived-surfaces` · `observability` · `data-plane` · `integrations` · `safety` · `cost` · `sdlc-agents` · `coordinator` · `business-logic-product` · `business-logic-domain`

Every Linear issue should declare:

1. Primary perspective
2. Grounding doc ids (`ADR-*` / `SPEC-*` / checkpoint path)
3. Target code area (`app/domain`, `app/temporal`, …) when known
4. Brief KB / derived-surface impact (or explicit “scaffolding only”)

### 8.3 Folder intuition (not final)

Possible future `biotech-meta/docs` organization (discussion starter):

```text
docs/
  interviews/                 # raw / lightly edited
  checkpoints/                # dated synthesis (this file lives here)
  decision-packets/           # confirmed interview ledgers
  adr/                        # normative decisions
  specs/                      # authoritative requirements
  research/                   # deeper investigations
  organization/               # meta: how we document & ship (future)
  CONTEXT.md                  # language authority
```

Official timestamped architecture summaries should graduate from checkpoints → decision packets / ADRs, not stay forever as brainstorm notes.

### 8.4 Codebase coincidence

- Perspectives guide **docs and issues**; `app/` layering guides **code ownership**.
- Do not create one top-level package per perspective if that fractures domain authority.
- Prefer: domain contracts stay coherent; perspectives label the *why* of a change.

---

## 9. Open questions for the next interview / grill

1. Is **Harness** the right name, or should we split **Cognitive Runtime** (Deep Agents loop) from **Capability Envelope** (tools/skills/MCP/FS)?
2. Should **Memory** be a control-plane capability family with catalogs, or a separate product subsystem?
3. Where does the **operator dashboard** get its authority — projections only, or can it issue governed run-control commands directly?
4. How formal should **perspective tags** be in Linear before they become noise?
5. Do we keep one Linear project for the evaluation system and use labels/milestones for perspectives, or eventually split projects (runtime vs coordinator vs SDLC)?
6. What is the promotion path from “idea note” → checkpoint → ADR/spec → Linear issue, and who accepts each hop?
7. How do we document **product business logic** without drowning `biotech-meta` in roadmap prose that is not yet implementable?
8. For coding agents (Cursor / Claude Code / Codex): which docs are mandatory context vs on-demand retrieval via skills/MCP?
9. What is the **minimum viable derived surface** from the KG for each wave (API vs MCP vs Skill vs thin web), so research/ingestion work always has an external consumer in mind?
10. How do we keep **Graph RAG / schema maps / retrieval evals** on the same critical path as Temporal and blueprint work, instead of deferring them indefinitely behind control-plane depth?

---

## 10. Immediate next uses of this checkpoint

1. Brainstorm missing perspectives and rename buckets until the vocabulary feels stable.
2. Decide a minimal official folder pattern for interviews / architecture / specs.
3. Define Linear label set + issue template linking to grounding docs **and** KB / derived-surface impact.
4. Map existing ADRs/SPECs/WPs onto these perspectives to find coverage gaps (especially Knowledge/retrieval, Derived surfaces, UX, Memory, Auth, SDLC-agents).
5. Produce a short “how we document BellLabs” note once this taxonomy settles.
6. Keep a visible link from implementation waves back to [BellLabs roadmap](../../BellLabs/roadmap.md) phases so control-plane depth does not displace compounding-knowledge outcomes.

---

## 11. Working definitions (draft)

**Perspective** — A lens for reasoning, documentation, and delivery prioritization. Not a deployment unit.

**North star (this system)** — Build a compounding knowledge base optimized for agentic retrieval and reasoning, then derive APIs, MCP servers, Agent Skills, and web/mobile apps from that base.

**Knowledge base** — The governed graph, evidence, schemas, indexes, and retrieval mechanisms that agents and products use to reason — not merely stored documents.

**Derived surface** — An API, MCP server, Agent Skill, web app, mobile app, or operator tool that projects or acts on the knowledge base without inventing a parallel authority.

**Harness** — The bounded cognitive and tool envelope of an agent inside an authorized operation.

**Runtime** — The durability, lifecycle, and intervention machinery that keeps work correct over time.

**Control plane** — The governed compile/bind path from definitions and catalogs to exact execution bindings.

**Coordinator** — An agentic operator-facing agent that triggers and inspects research/ingestion work through governed interfaces; not a competing macro workflow engine.

**SDLC agent surface** — Cursor, Claude Code, Codex, skills, MCP, and Linear used to *build* the system.

**Authority** — The right to decide meaning, lifecycle, or admission. Frameworks and scratch state do not acquire authority by existing.

**Scaffolding** — Necessary platform work that does not directly enrich the KB yet; valid when thin, explicit, and aimed at enabling compounding knowledge soon after.
)