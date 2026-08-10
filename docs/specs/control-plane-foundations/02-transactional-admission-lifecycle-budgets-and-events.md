---
id: SPEC-CP-RUN-CONTROL
title: Transactional admission, lifecycle, budgets, effects, and events
status: canonical
version: 1
governed_by: [ADR-0001, ADR-0003]
depends_on: [SPEC-CP-DEFINITIONS]
sources:
  - path: ../pre-research/control-plane-foundations/02-transactional-run-admission-lifecycle-and-budgets.md
    sections: [all]
supersedes:
  - ../pre-research/control-plane-foundations/02-transactional-run-admission-lifecycle-and-budgets.md
requirements:
  - REQ-CP-RUN-001
  - REQ-CP-RUN-002
  - REQ-CP-RUN-003
  - REQ-CP-RUN-004
  - REQ-CP-RUN-005
  - REQ-CP-RUN-006
  - REQ-CP-RUN-007
  - REQ-CP-RUN-008
  - REQ-CP-RUN-009
  - REQ-CP-RUN-010
contracts:
  - CON-CP-RUN-REQUEST-V1
  - CON-CP-LIFECYCLE-V1
  - CON-CP-BUDGET-LEDGER-V1
  - CON-CP-DOMAIN-EVENT-V1
qualification_obligations:
  - QUAL-CP-TRANSACTIONAL-AUTHORITY
---

# Transactional admission, lifecycle, budgets, effects, and events

## Purpose

Provide the single transactional authority that decides whether compiled intent becomes a Workflow Run and governs every later lifecycle, budget, effect, settlement, and terminality transition.

## Boundary and explicit non-ownership

This specification owns Run Request admission, command idempotency, the lifecycle reducer, current projections, transition records, budgets, effect claims, settlement, terminalization, and transactional outbox events. It does not compile configuration, perform Temporal scheduling, interpret StageGraph/GoalDirected semantics, or execute agent capabilities.

## Authority and persistence

PostgreSQL/application services are the sole writers of this state. Temporal, Deep Agents, LangGraph, LangSmith, MongoDB, callbacks, and clients may propose commands or observed facts but cannot apply authoritative transitions directly.

## Vocabulary and identities

- **Run Request:** idempotent proposal to create one Workflow Run from exact compiled inputs.
- **Workflow Run:** admitted domain execution identity, distinct from a Temporal Run ID.
- **Lifecycle Command:** versioned requested change with actor, authority, expected version, reason, correlation, and causation.
- **Observed Fact:** typed evidence from execution or an external system; it is not automatically a transition.
- **Terminalization Proposal:** exact proposal binding obligations, evidence, outputs, settlement, and current versions.
- **Budget Reservation:** authoritative capacity held before dispatch in one or more dimensions.
- **Effect Claim:** stable identity and reconciliation record for a consequential external effect.

## Invariants

1. Failed admission creates no Workflow Run and never starts Temporal.
2. Exact duplicate requests/commands return the stored result; conflicting fingerprints under the same identity fail.
3. Every mutation passes one application reducer with optimistic concurrency.
4. Lifecycle phase, wait/pause reason, terminal outcome, and purpose-bound output readiness are separate axes.
5. Budget is reserved before dispatch and settled exactly once from observed usage/effects.
6. Temporal status, provider completion, model output, trace, or checkpoint cannot assign lifecycle or terminal outcome.
7. Accepted transition, projection, command result, budget/effect changes, and outbox envelopes commit atomically.

## State and lifecycle

The shared lifecycle phases are exactly `pending`, `active`, `waiting`, `paused`, `cancelling`, and `terminal`. Aggregate `waiting` means no admissible work can progress and a declared condition may permit future progress. `paused` requires explicit authorized resume. Terminal outcomes are exactly `completed`, `partially_completed`, `failed`, and `cancelled` and are immutable once assigned.

## Requirements

### REQ-CP-RUN-001 — Transactional admission precedes execution

The admission service MUST validate authority, idempotency, exact ERC and input-manifest digests, Workflow Type admission/invariants, approvals, parent constraints, and baseline reservations before creating a Workflow Run.

**Verification:** accepted and rejected full-stack admission cases with no partial state.

### REQ-CP-RUN-002 — Pending run and start outbox are atomic

An accepted Run Request MUST atomically create run version 1 in `pending`, store its result, establish budget accounts/reservations, and enqueue the idempotent execution-start event.

**Verification:** transaction-failure injection and relay redelivery.

### REQ-CP-RUN-003 — One reducer owns mutations

Every human, agent, workflow, worker, callback, and reconciliation mutation MUST enter as a typed command or fact and be decided by the application lifecycle reducer against an expected aggregate version.

**Verification:** concurrent conflicting commands allow exactly one transition.

### REQ-CP-RUN-004 — Lifecycle axes remain distinct

The run projection MUST represent phase, scoped waits, scoped pauses, cancellation settlement, terminal outcome, and purpose-bound output readiness independently.

**Verification:** local waits/pauses do not block unrelated work; readiness changes do not reopen terminal runs.

### REQ-CP-RUN-005 — Terminality follows accepted evidence

Only the reducer MAY assign one terminal outcome after validating the current blueprint/control/obligation revisions, accepted evidence, pending dependencies, cancellations, and budget/effect settlement.

**Verification:** stale or incomplete terminalization proposals do not mutate lifecycle.

### REQ-CP-RUN-006 — Hierarchical multidimensional budgets

The budget service MUST reserve, adjust, consume, release, and settle independent dimensions for money, tokens, time, turns, tools/MCP, cycles/iterations, attempts, subagents, concurrency, and declared external quotas with parent-child rollup.

**Verification:** concurrent reserve-before-dispatch prevents oversubscription and dimensions do not borrow silently.

### REQ-CP-RUN-007 — Consequential effects are claimed and reconciled

Every consequential external effect MUST use a stable claim/idempotency identity, preserve ambiguous/pending disposition, and reach exactly one BellLabs settlement even when provider execution is at least once.

**Verification:** retry, timeout, callback duplication, cancellation, and ambiguous completion scenarios.

### REQ-CP-RUN-008 — Product events are transactionally durable

Every accepted change MUST emit versioned outbox envelopes with stable identity, aggregate version, actor, correlation, causation, typed payload/reference, and at-least-once consumer rules.

**Verification:** redelivery, gap detection, per-aggregate ordering, and durable cursor recovery.

### REQ-CP-RUN-009 — Async-subagent authority remains parent-controlled

Async-subagent reservations, accepted lifecycle facts, parent dependency decisions, result admissions, cancellation decisions, and final settlement MUST pass through the parent operation's application authority rather than provider state or model judgment.

**Verification:** child completion alone cannot satisfy or mutate the parent.

### REQ-CP-RUN-010 — Finalization is bounded

Any terminal partial-output assembly MUST operate from a frozen eligible evidence frontier, dedicated reservation, side-effect allowlist, timeout, and typed omission reasons, and MUST NOT start new research or linked work.

**Verification:** invalid evidence, timeout, insufficient budget, and prohibited-operation cases.

## Contracts

`CON-CP-RUN-REQUEST-V1` binds exact request identity, caller/authority, Workflow Type, ERC, input manifest, sponsorship, approvals, correlation, and optional parent context. `CON-CP-LIFECYCLE-V1` defines commands, facts, transitions, phases, outcomes, and terminalization proposals. `CON-CP-BUDGET-LEDGER-V1` defines accounts, reservations, usage, liability, and settlement. `CON-CP-DOMAIN-EVENT-V1` defines the transport-neutral event envelope.

## Failure, retry, cancellation, and recovery

Infrastructure delivery is at least once. Idempotency and CAS prevent duplicate authority. Cancellation enters `cancelling`, requests subordinate quiescence/cancellation, reconciles effects and charges, and terminalizes only after the bounded settlement policy. Projections are reconstructable from transition records and authoritative ledgers.

## Security, tenancy, redaction, and secrets

Application authorization is mandatory; PostgreSQL RLS is defense in depth. Raw secrets, PHI, and large content never enter control records or outbox payloads. Every actor and parent-child scope is tenant-qualified.

## Dependencies and compatible implementations

Consumes `SPEC-CP-DEFINITIONS`; supplies authority to `SPEC-CP-DURABLE-EXECUTION`, both blueprint specifications, and `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Qualification and evidence

`QUAL-CP-TRANSACTIONAL-AUTHORITY` covers atomic admission, concurrency, outbox delivery, budget oversubscription, effect ambiguity, terminality, async-child result admission, and reconstruction.

## Open decisions

- Exact PostgreSQL table/index names and event relay technology.
- Workflow-specific numeric budgets, timeouts, and approval thresholds.

## Non-goals

- General event sourcing of all documents.
- Provider execution or checkpoint storage.
- Workflow-family readiness or convergence algorithms.

## Source lineage and supersession

This specification extracts and supersedes pre-research foundation 02 while adding explicit async-subagent parent authority and effect settlement requirements.
