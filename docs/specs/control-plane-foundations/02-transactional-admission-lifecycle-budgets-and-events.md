---
id: SPEC-CP-RUN-CONTROL
title: Transactional admission, lifecycle, budgets, effects, and events
status: canonical
version: 2
governed_by: [ADR-0001, ADR-0003]
amendments:
  - id: AMD-RRM-001
    recorded_at: 2026-10-01
    base_revision: c48867a
    status: proposed_for_acceptance  # RRM-001 independent review pending; not yet accepted
    summary: requested-versus-applied lifecycle axes, in_doubt effect disposition, async-child usage settlement, scoped inspection reads and freshness
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
  - REQ-CP-RUN-011
  - REQ-CP-RUN-012
contracts:
  - CON-CP-RUN-REQUEST-V1
  - CON-CP-LIFECYCLE-V1
  - CON-CP-BUDGET-LEDGER-V1
  - CON-CP-DOMAIN-EVENT-V1
  - CON-CP-INSPECTION-READ-V1
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

**AMD-RRM-001 (clarified):** Requested and applied are separate axes.

- **Pause, resume, and wait release.** An accepted command is recorded as a pending command with its receipt (REQ-CP-EXEC-006). The phase, scoped-wait, and scoped-pause axes change only when the target boundary's `applied` fact is accepted. A projection MUST NOT report `paused`, or a released wait, while the family is still executing past that boundary.
- **Cancellation.** Accepted cancellation intent moves the run to `cancelling` immediately (REQ-CP-EXEC-008). Terminality still follows REQ-CP-RUN-005.
- **Projection content.** The projection exposes pending commands, with their receipt states, beside the phase.
- **Verification.** An accepted but undelivered pause leaves the phase `active`. A delivered pause that has not been applied shows as pending. Application moves the phase to `paused`.

### REQ-CP-RUN-005 — Terminality follows accepted evidence

Only the reducer MAY assign one terminal outcome after validating the current blueprint/control/obligation revisions, accepted evidence, pending dependencies, cancellations, and budget/effect settlement.

**Verification:** stale or incomplete terminalization proposals do not mutate lifecycle.

### REQ-CP-RUN-006 — Hierarchical multidimensional budgets

The budget service MUST reserve, adjust, consume, release, and settle independent dimensions for money, tokens, time, turns, tools/MCP, cycles/iterations, attempts, subagents, concurrency, and declared external quotas with parent-child rollup.

**Verification:** concurrent reserve-before-dispatch prevents oversubscription and dimensions do not borrow silently.

### REQ-CP-RUN-007 — Consequential effects are claimed and reconciled

Every consequential external effect MUST use a stable claim/idempotency identity, preserve ambiguous/pending disposition, and reach exactly one BellLabs settlement even when provider execution is at least once.

**Verification:** retry, timeout, callback duplication, cancellation, and ambiguous completion scenarios.

**AMD-RRM-001 (clarified):**

- **`in_doubt` disposition.** The `in_doubt` result disposition is the effect-level form of "ambiguous". A provider or runtime exception raised after dispatch, whose outcome is not proven, MUST be settled `in_doubt` with a reconciliation incident. It MUST NOT be settled as an authoritative `failed`.
- **Operator resolution.** An `in_doubt` unit or effect is resolved only by a typed, audited operator reconciliation command (REQ-CP-RUN-011). It is never resolved by speculative re-execution.
- **Checkpoint durability.** Checkpoint durability of a Deep Agent is not an effect settlement. A settlement references the result checkpoint (REQ-CP-DA-017) but derives its authority from this requirement.

### REQ-CP-RUN-008 — Product events are transactionally durable

Every accepted change MUST emit versioned outbox envelopes with stable identity, aggregate version, actor, correlation, causation, typed payload/reference, and at-least-once consumer rules.

**Verification:** redelivery, gap detection, per-aggregate ordering, and durable cursor recovery.

### REQ-CP-RUN-009 — Async-subagent authority remains parent-controlled

Async-subagent reservations, accepted lifecycle facts, parent dependency decisions, result admissions, cancellation decisions, and final settlement MUST pass through the parent operation's application authority rather than provider state or model judgment.

**Verification:** child completion alone cannot satisfy or mutate the parent.

**AMD-RRM-001 (clarified):** A child's reservation is carved from the parent run's budget accounts. The child's observed usage settles exactly once against those accounts, with parent rollup (REQ-CP-RUN-006). Usage the provider cannot attribute stays pending or ambiguous and blocks the parent's final settlement until it is reconciled. It is never dropped. The parent may terminalize only when every child has a recorded result decision and settlement, or a policy-declared orphan or quarantine disposition.

### REQ-CP-RUN-010 — Finalization is bounded

Any terminal partial-output assembly MUST operate from a frozen eligible evidence frontier, dedicated reservation, side-effect allowlist, timeout, and typed omission reasons, and MUST NOT start new research or linked work.

**Verification:** invalid evidence, timeout, insufficient budget, and prohibited-operation cases.

### REQ-CP-RUN-011 — Scoped inspection reads never mutate

The application facade MUST expose authorized, request-scope-bound reads: a run list, run detail, unit detail, and a unit's checkpoint history with a selected historical checkpoint summary. These reads are served from PostgreSQL authority, immutable detail documents, and explicitly qualified runtime sources only (Temporal Visibility under REQ-CP-EXEC-015, and the checkpointer under REQ-CP-DA-016). They MUST use opaque cursors bound to scope and filter. They MUST NOT, as a side effect, mutate lifecycle, settle, reconcile, claim, create incidents, or write observations.

Operator reconciliation of `in_doubt` units is a separate privileged, typed command that passes REQ-CP-RUN-003. A schema-export route is not an inspection read.

**Amendment:** AMD-RRM-001, new (API detail).

**Content.** A unit read exposes:

- the structured runtime-unit identity and `unit_key`;
- Temporal workflow and run IDs and Activity attempts;
- the exact binding ID and digest;
- the cognitive session namespace;
- source and result qualified checkpoint keys and their ancestry;
- result manifest and artifact refs;
- budget and effect status;
- receipts of commands targeting the unit;
- the reconciliation state;
- async children: BellLabs child ID, provider thread and run, binding digest, lifecycle, and result decision;
- fork lineage: parent run, snapshot, and seed checkpoint.

**Historical reads.** A historical checkpoint read MUST validate, in order:

1. scope, run, unit, and namespace ownership;
2. that the checkpoint lies on the unit's recorded lineage;
3. that the stamped binding and state-schema digests are compatible with the unit's binding.

An incompatible checkpoint returns a typed error and is never coerced.

**Verification:** cross-scope denial; bad or expired cursor; incompatible checkpoint; active and terminal runs; reads leave every table and the outbox unchanged.

### REQ-CP-RUN-012 — Reads declare freshness, ambiguity, and redaction

Every inspection response MUST follow `CON-CP-INSPECTION-READ-V1`. For each section the response states its source and observation time, and whether that section is current, stale, or unavailable. It MUST expose `in_doubt` and operator-required reconciliation states honestly. It MUST apply a redaction policy that, by default, excludes checkpoint bodies, message and tool-argument content, transcripts, and secret values. A redacted checkpoint state summary requires a separate permission. Diagnostic Temporal Query output may appear only in a labelled diagnostic section, never as authority.

**Amendment:** AMD-RRM-001, new (API and contract detail).

**Verification:** a missing live provider, or Temporal being unavailable, yields `unavailable` sections and a successful persisted read; redaction fixtures prove excluded content; a summary request without permission is denied.

## Contracts

`CON-CP-RUN-REQUEST-V1` binds exact request identity, caller/authority, Workflow Type, ERC, input manifest, sponsorship, approvals, correlation, and optional parent context. `CON-CP-LIFECYCLE-V1` defines commands, facts, transitions, phases, outcomes, and terminalization proposals. `CON-CP-BUDGET-LEDGER-V1` defines accounts, reservations, usage, liability, and settlement. `CON-CP-DOMAIN-EVENT-V1` defines the transport-neutral event envelope.

**AMD-RRM-001.** `CON-CP-LIFECYCLE-V1` (clarified) adds pending-command and receipt fields to the run projection, and the operator reconciliation command `reconcile_unit`. `reconcile_unit` targets a `unit_key` and generation with one decision: `accept_descendant`, `abandon_unit`, or `start_new_generation`. It also carries the evidence refs and expected versions.

`CON-CP-INSPECTION-READ-V1` (new, schema `belllabs.inspection-read.v1`) is the response envelope. It carries `data` and a `sections` map. Each section records:

- `source`: `postgres_authority`, `temporal_visibility`, `checkpointer`, `mongo_detail`, or `diagnostic_query`;
- `observed_at`;
- `projection_version`, where applicable;
- `freshness`: `current`, `stale`, or `unavailable`;
- `reconciliation_state`: `none`, `pending`, `in_doubt`, or `operator_required`;
- `redaction`, with `policy_ref` and the count of withheld fields.

The redacted checkpoint summary allowlist is, at minimum: channel names, message count, `artifact_index` metadata, todo count, presence of a structured response, pending task names, and the stamped digests.

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

## Amendment record

| Amendment | Recorded | Status | Scope |
|---|---|---|---|
| AMD-RRM-001 | 2026-10-01 | proposed for acceptance (RRM-001 review pending) | Clarified: REQ-CP-RUN-004, 007, and 009; `CON-CP-LIFECYCLE-V1`. New: REQ-CP-RUN-011 and 012; `CON-CP-INSPECTION-READ-V1`. |

The notation follows `SPEC-CP-DURABLE-EXECUTION` § Amendment record.
