---
name: canonicalize-biotech-architecture
description: Convert BellLabs Biotech interview syntheses, checkpoints, architecture notes, specifications, and migration plans into a controlled lineage of accepted decisions, canonical specifications, atomic requirements, implementation work packages, GitHub issues or local Markdown plans, and verification evidence. Use for documentation cleanup or reorganization, architecture interviews with grill-me or grill-with-docs, supersession and drift resolution, traceability work, specification synthesis, implementation-plan replacement, or preparing StageGraph, GoalDirected, control-plane, workflow-type, capability, data-platform, API, MCP, memory, sandbox, snapshot, steering, HITL, or deployment work for implementation.
---

# Canonicalize Biotech Architecture

Build the minimum documentation lineage needed to implement safely, then return to code. Preserve the interview-derived corpus as evidence; do not turn documentation cleanup into an indefinite prerequisite.

## Governing outcome

Produce this chain:

```text
source document/interview
  -> accepted decision (ADR)
  -> canonical specification (SPEC)
  -> atomic requirement (REQ) and optional contract (CON)
  -> implementation work package (WP)
  -> GitHub issue or local Markdown issue
  -> code/migration
  -> test or qualification evidence (QUAL/EVD)
```

Treat the directory structure as ownership and the identifiers as lineage. Never use one to replace the other.

## Read before acting

1. Read the workspace and repository `AGENTS.md` files.
2. Read the documents named by the user in full.
3. Read the current authority index, accepted ADRs, active implementation package, declared dependencies, and current handoff or execution ledger for the affected area.
4. Read [priority-scope.md](references/priority-scope.md) when choosing work order or resolving BellLabs runtime boundaries.
5. Read [templates.md](references/templates.md) before creating registry entries, ADRs, specs, requirements, work packages, or issues.
6. When `$grill-me` or `$grill-with-docs` is also requested, inspect those skills and use the interview protocol below.

Do not assume that a document is current because its filename says `canonical`, `accepted`, `plan`, or `spec`. Establish authority from its status, date, supersession chain, governing index, and accepted decisions.

## Choose the operating mode

### Fast implementation path

Use when the user needs code work soon.

1. Canonicalize only the decisions and requirements that gate the next executable vertical.
2. Create Markdown work packages unless the user explicitly authorizes GitHub publication.
3. Stop documentation expansion when the next vertical has:
   - accepted authority and identity decisions;
   - a bounded canonical specification;
   - atomic acceptance requirements;
   - dependency-correct work packages;
   - named verification evidence;
   - no unresolved decision that could invalidate the implementation.
4. Return to implementation. Canonicalize later capability areas immediately before their implementation wave.

For the present program, prefer this path until the Temporal root/operation foundation, StageGraph, GoalDirected, and one first Workflow Type have executable plans.

### Full lineage path

Use when reorganizing a whole document family or preparing a stable long-lived subsystem suite. Complete the registry, extraction, canonicalization, traceability, and archive gates for every source in scope.

### Interview-only path

Use when the user wants alignment before writing. Produce a decision packet, run the focused interview, and record decisions and open questions. Do not fabricate a finished specification when material decisions remain open.

## Workflow

### 1. Establish scope and current pointer

State:

- the immediate implementation outcome;
- source documents and repositories in scope;
- the current normative authority;
- the current implementation/gate pointer;
- the smallest canonical documents needed before implementation;
- whether output will be GitHub issues or local Markdown work packages.

Do not silently broaden a request for one subsystem into a full-corpus rewrite.

### 2. Preserve and inventory sources

Before moving, rewriting, archiving, or deleting documents:

- inspect git status and preserve unrelated changes;
- record path, title, declared status, date, content hash, inbound references, framework assumptions, topics, authority class, and proposed disposition;
- add or update the document registry;
- prefer `git mv` after a tracked baseline exists;
- delete only an exact duplicate after every unique decision, requirement, and provenance reference has been extracted and inbound links have been repaired.

Allowed dispositions are `promote`, `keep_update`, `split`, `merge`, `rewrite`, `supersede_archive`, and `delete_verified_duplicate`.

### 3. Classify statements, not just files

Classify each material statement by:

- authority: accepted, proposed, research evidence, implementation observation, historical;
- layer: domain, control plane, runtime, provider adapter, data platform, API, deployment, implementation;
- time: target invariant, current state, migration-only, historical;
- scope: system, family, Workflow Type, operation, provider;
- stability: invariant, configurable policy, environment setting, open decision.

Separate durable domain semantics from framework mappings. Preserve the former and explicitly supersede obsolete OpenAI Agents SDK or Agent Server macro-runtime mappings.

### 4. Build a decision packet

Before interviewing, write a compact packet containing:

- current understanding;
- durable decisions already supported by sources;
- contradictions and supersession candidates;
- proposed canonical destinations;
- proposed requirements;
- no more than the smallest set of owner questions needed to proceed;
- recommended source dispositions;
- effect of each unresolved question on the next code vertical.

Interview by decision cluster, not mechanically by file. One large checkpoint may require multiple interviews; several related documents may share one interview.

### 5. Run the grill interview

When used with `$grill-me` or `$grill-with-docs`:

1. Give the interviewer the decision packet and exact source paths.
2. Ask about conflicts, authority, invariants, boundaries, rejected alternatives, configurable policies, deferrals, and acceptance evidence.
3. Do not spend interview time restating settled source content.
4. Record answers as proposed decisions during the interview.
5. At the end, present a compact decision ledger for explicit confirmation.
6. Mark unanswered architecture-changing questions as open; do not infer acceptance from silence.

The interview may refine a requirement but cannot make provider availability, prompts, traces, checkpoints, or existing code authoritative.

### 6. Record decisions and canonical specifications

Create one ADR per consequential architectural choice. Create one specification per bounded owner.

Each specification must state:

- purpose, boundary, and explicit non-ownership;
- authority and persistence ownership;
- vocabulary and identities;
- invariants and state transitions;
- atomic requirements;
- referenced versioned contracts;
- failure, retry, cancellation, intervention, and recovery behavior where applicable;
- security, tenancy, redaction, and secret boundaries;
- dependencies and compatible implementations;
- qualification obligations and acceptance evidence;
- open decisions and explicit non-goals;
- source anchors and superseded documents.

Give each requirement exactly one owning specification. Other documents reference the requirement ID instead of restating it.

### 7. Apply the identifier policy

Mandatory:

- `ADR-*`: accepted architectural decision;
- `SPEC-*`: canonical bounded specification;
- `REQ-*`: atomic testable or qualifiable requirement;
- `WP-*`: stable implementation work package.

Optional:

- `CON-*`: concrete versioned schema, envelope, protocol, or state machine;
- `QUAL-*`: significant proof obligation beyond an ordinary test;
- `EVD-*`: accepted evidence package or gate handoff.

Do not create `ISSUE-*` as an internal identity. Map a stable `WP-*` to a GitHub issue number/URL or a local Markdown issue. Reference real test paths instead of inventing `TST-*` IDs unless the project already maintains a test-case registry.

### 8. Produce implementation work packages

Create work packages only after their requirements and governing decisions are stable enough to implement.

Each work package must include:

- requirements implemented;
- governing ADRs and contracts;
- user-visible or operator-visible outcome;
- blockers and dependency edges;
- affected architectural seams;
- migrations and compatibility concerns;
- acceptance criteria and required evidence;
- explicit non-goals;
- documentation and traceability updates;
- drift guards for framework/provider assumptions.

Prefer narrow tracer-bullet verticals that fit one fresh agent context and remain independently verifiable. Use expand-contract packages for wide compatibility migrations.

### 9. Publish locally or to GitHub

- Default to local Markdown when publication authority or issue structure is not explicit.
- Publish GitHub issues only when the user asks or clearly authorizes it.
- Keep the `WP-*` identity in the GitHub issue body.
- Create blockers before blocked issues so links can use real identifiers.
- Never let the issue body become a second architecture specification.

Use `$to-tickets` only after enriching its output with the BellLabs lineage fields in [templates.md](references/templates.md).

### 10. Verify coherence

Before declaring a canonicalization slice complete, verify:

- every source has a disposition and extraction state;
- every accepted decision has one ADR or decision-ledger entry;
- every requirement has one owner;
- every work package implements named requirements;
- every qualification obligation has a planned evidence location;
- archives are not linked as normative authority;
- relative links resolve;
- no active document contradicts the accepted runtime/persistence authority;
- generated traceability views do not contain independently authored requirements;
- the next implementation frontier is explicit.

Report unresolved contradictions and do not mark their downstream packages ready.

## BellLabs non-negotiable runtime boundary

Unless a later accepted ADR supersedes it:

- Temporal is the sole production macro-workflow runtime.
- BellLabs application services and pure interpreters own semantic authority.
- PostgreSQL/application services own admission, lifecycle, commands, budgets, effects, settlement, and terminality.
- LangGraph and Deep Agents perform bounded operation cognition under exact bindings.
- LangSmith supplies tracing, evaluation, sandboxes, development, and selected bounded remote operation deployments.
- Agent Server is not a competing StageGraph or GoalDirected macro scheduler.
- The BellLabs API is the sole governed public facade.
- Checkpoints, traces, prompts, tools, skills, MCP discovery, models, and provider state grant no authority merely by existing.

## Guardrails

- Preserve interview transformations and checkpoints as provenance.
- Never rewrite historical documents to pretend an older decision was never made.
- Never resolve an architectural conflict through terminology replacement alone.
- Never duplicate a requirement across specifications.
- Never let implementation packages silently amend architecture.
- Never let documentation perfection block a vertical whose gating decisions and requirements are already coherent.
- Never claim a document, work package, or stage accepted without its named decision or evidence gate.
- Never commit secrets or PHI; research output is not medical advice.

