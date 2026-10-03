# Special Checkpoint: BellLabs Engineering Delivery Playbook

Date: 2026-07-16

Status: Accepted working process for architecture-to-implementation; implementation has not started

## Purpose

This document records how BellLabs will move from the current multi-session architecture interview into specifications, GitHub tickets, implementation, testing, and review.

The playbook adapts Matt Pocock's composable engineering skills:

```text
grill-with-docs + domain-modeling
-> optional wayfinder when the route is still foggy
-> to-spec
-> to-tickets
-> implement
   -> tdd at pre-agreed seams
   -> code-review
   -> commit and pull request
```

The process is deliberately staged. An implementation framework, database, SDK, or UI library must not fill unresolved domain behavior by accident.

## Current Position

BellLabs is still in the architecture-interview phase.

The current work is:

```text
grill-with-docs
+ domain-modeling
+ targeted research
+ checkpoints
+ handoffs between agent sessions
```

The system has substantial accepted architecture for:

- Knowledge Production Missions and composable Workflow Runs
- Starter Content Refinement
- Knowledge Preflight
- Mission Specification
- workspace, sandbox, capability, and agent concepts
- large-schema navigation and Schema Context Selection
- Source identity foundations
- Source Intelligence and the Provenance Spine

The remaining domain architecture is too important and too incomplete to send directly to implementation.

## Intended Architecture Sequence

The interview will continue across additional agent sessions through:

1. completion of the pre-research Workflow Types
2. Source Intelligence, source collections, source querying, ranking, authority, capture, transformation, and corpus architecture
3. mode-specific deep-research architecture
4. evidence handling, adjudication, reporting, and post-research provenance
5. schema-aware ingestion planning and execution
6. evaluation across research, retrieval, provenance, ingestion, content, agents, and experiences
7. Curated Content creation, including multimodal content
8. publication, correction, freshness, and reevaluation
9. generative UI, MCP UI, and advanced component architecture

This remains a reference decision sequence, not a rigid runtime pipeline.

Only after those domain contracts are coherent will the interview pivot to software-interface architecture:

- OpenAI Agents SDK for Python
- Temporal workflows, child workflows, activities, signals, updates, retries, cancellation, and durable waits
- MongoDB versus PostgreSQL/JSONB runtime-state boundaries
- PostgreSQL control-plane and Agents SDK session records
- Neo4j and schema-version compatibility
- object storage and artifact manifests
- FastAPI command and query APIs
- WebSocket application-event streaming and reconnect semantics
- Next.js dashboard and user-facing experience architecture
- CopilotKit, MCP, generative UI, and component transport
- sandbox providers, workspace materialization, snapshots, and restoration
- observability, evaluation, security, permissions, and deployment

The software-interface interview will still use `grill-with-docs` and `domain-modeling`. Framework mapping is another architecture phase, not an immediate coding phase.

## The Main Flow

## Phase 1: Grill With Docs and Domain Modeling

Purpose:

- remove ambiguity before code
- establish ubiquitous language
- define Workflow Types, invariants, inputs, outputs, states, decisions, and failure behavior
- preserve accepted decisions and open hypotheses

Required behavior:

- ask one question at a time
- recommend one answer with reasoning
- stress-test decisions with concrete scenarios
- inspect code when code can answer the question
- update `docs/CONTEXT.md` immediately when terminology becomes accepted
- create ADRs only for hard-to-reverse, surprising trade-offs
- create checkpoints at coherent decision boundaries
- create handoffs before context degrades

Architecture checkpoints are not implementation specifications. They preserve understanding, including open questions and alternatives.

## Phase 2: Optional Wayfinder

`wayfinder` is optional, but its correct position is **upstream of `to-spec`**, not after implementation.

Use it when:

- the destination spans more than one agent session
- the route is still obscured by unresolved decisions
- questions can be stated as decision tickets
- research, prototypes, or further grilling block downstream decisions
- multiple sessions or agents need a shared visible frontier

Do not use it merely because implementation will be large. If the architecture is already clear enough to specify, proceed to `to-spec`.

A Wayfinder map:

- is one issue labelled `wayfinder:map`
- defines a destination
- indexes decisions already made
- preserves not-yet-specifiable fog
- owns child decision tickets
- uses blocking edges to expose the frontier
- plans rather than implements

Wayfinder tickets are decisions or investigations, not tracer-bullet build tickets.

Likely BellLabs uses:

- mode-specific deep research as a possible Wayfinder effort if scheduler, agent topology, convergence, and research modes remain too foggy for linear interviewing
- software-interface architecture as another possible Wayfinder effort if framework and persistence decisions branch beyond one interview sequence

Wayfinder is not required for already-clear architecture areas.

## Phase 3: To Spec

When a bounded capability is understood, `to-spec` synthesizes the conversation and repository knowledge into a specification.

It does not restart the requirements interview.

Its one intended human confirmation is the proposed testing seam:

- prefer an existing seam
- test at the highest practical boundary
- introduce as few new seams as possible
- test externally observable behavior rather than implementation details

The spec records:

- Problem Statement
- Solution
- extensive User Stories
- Implementation Decisions
- Testing Decisions
- Out of Scope
- Further Notes

For BellLabs, `to-spec` must consume:

- canonical vocabulary from `docs/CONTEXT.md`
- applicable ADRs
- consolidated checkpoints
- the target repository's current code and tests
- resolved framework contracts
- explicit remaining non-goals

### Do not create one mega-spec

The complete Human Upgrade System is too large for one useful specification.

The recommended model is:

- system-wide checkpoints and ADRs preserve cross-cutting architecture
- an optional Wayfinder map preserves program-level decision structure
- each cohesive implementation capability receives its own bounded spec
- each spec links the upstream architecture documents it implements

Candidate future specs may cover:

- workflow control-plane foundations
- Starter Content capture and refinement
- Knowledge Preflight and schema-aware retrieval
- Source Intelligence registry and query contracts
- Source Corpus capture and transformation
- one mode-specific deep-research vertical slice
- ingestion planning and graph commit
- provenance validation and impact analysis
- Curated Content derivation
- one governed generative-UI component family

These are examples, not an accepted decomposition.

## Phase 4: To Tickets

`to-tickets` converts an approved spec, plan, or conversation into tracer-bullet tickets.

Each ticket must:

- deliver a narrow but complete path through required layers
- be independently demonstrable or verifiable
- fit one fresh agent context window
- declare its real blockers
- remain green when completed
- use canonical domain language
- avoid stale file-path-level micromanagement

A normal ticket is vertical:

```text
domain behavior
-> persistence or integration
-> application API
-> agent/tool contract when applicable
-> UI or observable output when applicable
-> automated tests
```

Horizontal implementation tickets such as "build all database models" or "write all API routes" are discouraged unless they are unavoidable mechanical refactors.

Wide refactors use expand-contract:

1. add the new form beside the old
2. migrate callers in green batches
3. remove the old form only after every migration completes

### Blocking edges

Tickets explicitly declare which tickets block them.

The implementation frontier is:

> every open ticket whose blockers are complete

Tickets produced by `to-tickets` are already agent-ready and should not pass through raw-request triage.

## Phase 5: Implement

Each implementation ticket starts in a fresh context with:

- the governing spec
- the single ticket
- relevant domain context and ADRs
- applicable checkpoint links

The agent should not load every architecture document eagerly. It should start from the spec and ticket, then follow context pointers as needed.

Implementation behavior:

1. confirm the ticket and its blockers
2. inspect the current code and existing test seams
3. use `tdd` where possible at the pre-agreed seam
4. build one vertical slice
5. run focused tests and typechecking repeatedly
6. run the full relevant suite at completion
7. run `code-review`
8. resolve review findings within scope
9. commit to the current branch
10. open or update the pull request according to repository policy

Implementation agents must not reopen accepted architecture casually. If a ticket exposes a real contradiction or missing decision, stop and route it back to:

- the governing spec
- a focused grilling session
- or a Wayfinder decision ticket when the uncertainty is program-level

## Phase 6: Review, Integration, and Learning

Review checks two independent axes:

- **Standards**: correctness, security, maintainability, performance, repository conventions, and code smells
- **Spec fidelity**: whether the implementation actually satisfies the accepted spec and ticket

After merge:

- evaluations may emit Improvement Candidates
- implementation discoveries may propose glossary, ADR, checkpoint, skill, schema, or workflow revisions
- no successful run silently changes canonical architecture or policy
- accepted learning returns through the same documented decision process

## Artifact Authority

Different artifacts serve different purposes.

### `docs/CONTEXT.md`

Canonical ubiquitous language only.

It must not become a specification, implementation plan, or framework notebook.

### ADR

A hard-to-reverse, surprising decision resulting from a real trade-off.

### Checkpoint

A coherent architecture boundary containing accepted decisions, recommendations, hypotheses, scenarios, and open questions.

### Handoff

A session bridge preserving exact current state, latest accepted decision, and next unresolved question.

### Research artifact

Cited evidence from primary or high-trust sources. Research findings inform decisions but do not become accepted architecture automatically.

### Wayfinder map and decision ticket

A shared issue-tracker map for unresolved architecture fog. A ticket resolves one decision or investigation.

### Spec

The approved contract for one bounded capability to build.

### Implementation ticket

One tracer-bullet vertical slice of an approved spec, with explicit blocking edges and acceptance criteria.

### Code, tests, and pull request

The executable implementation and its verification evidence.

No artifact silently substitutes for another.

## GitHub Operating Model

The user has selected GitHub for specifications and tickets.

The current architecture repository is:

```text
https://github.com/Overton77/biotech-meta
```

Recommended ownership:

- `biotech-meta` remains the canonical home of cross-system vocabulary, checkpoints, ADRs, research, handoffs, and program-level Wayfinder maps
- a cross-system spec may be published to `biotech-meta`
- implementation specs and tickets should normally live in the GitHub repository that owns the affected code
- cross-repository blockers should use explicit issue links and named dependencies
- one issue should not pretend to have native ownership over changes spread across unrelated repositories

This is a recommendation. The exact cross-repository issue topology must be confirmed before the first `to-spec`.

## Required Skills Setup Before To Spec

The repository has not yet completed the current `setup-matt-pocock-skills` configuration.

Observed local state after the 2026-07-17 skills update:

- `npx skills` installed the current Matt Pocock skill set into `.agents/skills`
- `to-spec`, `to-tickets`, `implement`, `wayfinder`, `code-review`, `research`, `tdd`, `grill-with-docs`, and `domain-modeling` are present
- stale untracked `to-prd` and `to-issues` skill files were removed to avoid ambiguous invocation
- `skills-lock.json` now records the installed project skills and upstream hashes
- the existing LangChain skills were refreshed; the CLI reported that it could not check the upstream LangChain repository for deleted skills, but the installed skill updates completed successfully
- no `docs/agents/*.md` tracker/domain configuration exists yet
- the repository has a GitHub remote
- an `AGENTS.md` exists under `.cursor/`, not at the repository root expected by the setup workflow

Current upstream research:

- the latest GitHub release is `v1.1.0`, published 2026-07-08
- upstream `main` uses `to-spec` and `to-tickets`
- upstream Wayfinder explicitly sits before `to-spec`
- upstream setup configures tracker, domain-doc rules, and optional triage labels

Before the first specification is published:

1. run `setup-matt-pocock-skills` in the target repository
2. select GitHub as the issue tracker
3. confirm the domain-doc layout
4. confirm or create required labels
5. ensure Wayfinder operations and native blocking conventions are documented
6. decide whether the root agent-guidance file should be `AGENTS.md` or `CLAUDE.md`
7. dry-run the flow on one small noncritical specification before launching the largest build

Skills installation is complete. Tracker setup remains deliberately separate.

## Context Hygiene Across Sessions

Matt Pocock's current guidance prefers carrying grilling through `to-tickets` in one smart context window when possible.

BellLabs is larger than one context window, so it uses durable bridges:

- checkpoint each coherent architecture boundary
- update `docs/CONTEXT.md` immediately
- create a handoff before a session becomes degraded
- begin the next session from the handoff, canonical glossary, referenced checkpoints, and ADRs
- do not ask the new session to reread every historical document
- distinguish accepted decisions from recommendations and open hypotheses

For implementation:

- one fresh session per implementation ticket
- do not reuse a context polluted by unrelated tickets
- do not rely on chat memory when the spec, ticket, and domain documents should carry the contract

## Architecture Readiness Gate

A capability is ready for `to-spec` only when:

- its purpose and actors are clear
- canonical terms are accepted
- inputs and outputs are understood
- invariants and authority boundaries are explicit
- important states and transitions are defined
- required and degradable obligations are distinguished
- failure, retry, cancellation, and partial-result behavior are understood at the domain level
- provenance and permission obligations are explicit
- agent judgment, deterministic logic, and human approval boundaries are distinguished
- evaluation obligations are known
- framework mapping no longer requires inventing domain behavior
- major open questions are either resolved or explicitly out of scope
- the target repository and highest practical testing seam are identifiable

Passing this gate does not require every future feature to be designed. It requires the bounded capability being specified to be implementable without hidden product decisions.

## Software-Interface Readiness Gate

The architecture may pivot from domain modeling into framework mapping when:

- Workflow Type contracts are sufficiently stable
- cross-cutting Source Intelligence and Provenance Spine obligations are understood
- event and intervention semantics have a domain-level shape
- state ownership is distinguishable across domain, execution, agent session, sandbox, artifacts, knowledge, content, and learning
- expected access patterns can inform persistence choices
- security, permission, and authority boundaries are explicit

Only then should the interview decide exact:

- Temporal granularity
- Agents SDK agent, tool, handoff, session, RunState, and sandbox mappings
- database schemas and transaction boundaries
- API and WebSocket contracts
- dashboard state and rendering architecture

## First Implementation Strategy

The first implementation should be a tracer bullet, not a horizontal platform build.

Recommended characteristics:

- one bounded Workflow Type or narrow composition
- real control-plane command
- one durable Temporal execution path
- one agent or deterministic operation
- one governed artifact
- one provenance path
- one application-event stream
- one dashboard view
- one high-level automated test seam

It should prove the architecture's integration points without pretending to implement the entire system.

The exact first tracer bullet remains open until the domain and software-interface interviews finish.

## Anti-Patterns

- generating code directly from architecture checkpoints without a bounded spec
- one giant Human Upgrade System spec
- horizontal tickets divided only by database, backend, agent, and frontend layers
- using Wayfinder as an implementation backlog
- invoking Wayfinder after the route is already clear
- treating `to-spec` as another requirements interview
- publishing tickets before testing seams and blockers are reviewed
- implementing multiple unrelated tickets in one agent context
- letting implementation agents silently resolve product decisions
- treating issue text as a replacement for canonical domain vocabulary
- using local older skill names while assuming current upstream behavior
- setting up GitHub labels and topology differently in every repository
- considering code complete before focused tests, full verification, and code review

## Canonical BellLabs Flow

```text
MULTI-SESSION DOMAIN ARCHITECTURE

grill-with-docs + domain-modeling
-> research / prototype when a decision needs evidence
-> CONTEXT.md + ADRs + checkpoints
-> handoff
-> next grilling session
-> repeat through research, source, ingestion, evaluation,
   multimodal content, and generative UI architecture

OPTIONAL PROGRAM WAYFINDING

if destination is large and route remains foggy:
wayfinder map
-> research / prototype / grilling decision tickets
-> decisions clear

SOFTWARE-INTERFACE ARCHITECTURE

grill-with-docs + domain-modeling
-> OpenAI Agents SDK + Temporal + persistence + API + events + UI
-> consolidated framework-mapping checkpoints

DELIVERY

setup-matt-pocock-skills
-> to-spec for one bounded capability
-> confirm testing seam
-> approve spec
-> to-tickets
-> approve tracer bullets and blocking edges
-> fresh context per frontier ticket
-> implement
   -> tdd
   -> focused checks
   -> full relevant suite
   -> code-review
   -> commit
   -> pull request
-> evaluation and documented learning
```

## Research Sources

- [Matt Pocock Skills repository](https://github.com/mattpocock/skills)
- [Current `grill-with-docs` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md)
- [Current `domain-modeling` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md)
- [Current `to-spec` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-spec/SKILL.md)
- [Current `to-tickets` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md)
- [Current `implement` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement/SKILL.md)
- [Current `wayfinder` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md)
- [Current `setup-matt-pocock-skills` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md)
- [Wayfinder engineering guide](https://github.com/mattpocock/skills/blob/main/docs/engineering/wayfinder.md)
- [Release v1.1.0](https://github.com/mattpocock/skills/releases/tag/v1.1.0)

## Exact End-of-Night State

The project remains in `grill-with-docs + domain-modeling`.

The latest architecture boundary is:

- Source Intelligence and the Provenance Spine are system-wide
- one global source-authority score is rejected
- the canonical model for increasing provenance richness remains open

The next unresolved interview question is:

> Should BellLabs use a Provenance Completeness Profile that keeps depth, resolution, coverage, confidence, transformation fidelity, and verification readiness separate rather than producing one provenance-density score?

No `to-spec`, `to-tickets`, Wayfinder map, GitHub setup, or implementation work has been authorized yet.
