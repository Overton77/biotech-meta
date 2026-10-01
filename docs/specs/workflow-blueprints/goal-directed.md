---
id: SPEC-BP-GOAL-DIRECTED
title: GoalDirected blueprint semantics
status: canonical
version: 2
governed_by: [ADR-0003]
amendments:
  - id: AMD-RRM-001
    recorded_at: 2026-10-01
    base_revision: c48867a
    status: proposed_for_acceptance  # RRM-001 independent review pending; not yet accepted
    summary: durable pause and resume, shared-session ordering
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-RUN-CONTROL, SPEC-CP-DURABLE-EXECUTION, SPEC-CP-DEEP-AGENT-RUNTIME]
sources:
  - path: ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
    sections: [GoalDirected user stories, implementation decisions, testing decisions]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [7.4, 8, 11, 12, 13, 21 Phase 4, 22]
supersedes:
  - GoalDirected portions of ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
requirements:
  - REQ-BP-GD-001
  - REQ-BP-GD-002
  - REQ-BP-GD-003
  - REQ-BP-GD-004
  - REQ-BP-GD-005
  - REQ-BP-GD-006
  - REQ-BP-GD-007
  - REQ-BP-GD-008
  - REQ-BP-GD-009
  - REQ-BP-GD-010
  - REQ-BP-GD-011
  - REQ-BP-GD-012
contracts:
  - CON-BP-GOAL-DIRECTED-V1
  - CON-BP-GOAL-HANDOFF-V1
  - CON-BP-GOAL-VERIFICATION-V1
qualification_obligations:
  - QUAL-BP-GOAL-DIRECTED-CONVERGENCE
---

# GoalDirected blueprint semantics

## Purpose

Define bounded iterative goal work whose tactics can adapt while its objective, inputs, authority, acceptance, budget, and prohibited-work envelope remain governed and whose completion always requires independent verification.

## Boundary and explicit non-ownership

This specification owns Goal Revisions, iteration transitions, handoffs, session policy, verification, convergence, no-progress/blocker detection, subgoal classification, and stopping proposals. Deep Agents performs bounded cognition but does not own goals or convergence. Temporal durably runs iterations; the lifecycle reducer owns terminality.

## Authority and persistence

`GoalDirectedInterpreter` is the sole pure semantic authority for revision applicability, verifier outcomes, convergence, continuation, and stopping proposals. MongoDB/Beanie owns immutable goal revisions, iteration/handoff/verifier documents, and detailed outputs. PostgreSQL owns reservations, accepted decisions/evidence, lifecycle, effects, settlement, and terminality.

## Vocabulary and identities

- **Objective envelope:** launch-bound purpose, acceptance contract, admitted inputs, authority, budget, prohibited work, and output obligations.
- **Goal Revision:** immutable tactical refinement inside the objective envelope.
- **Goal iteration:** one independently durable semantic attempt to advance one exact revision.
- **Goal handoff checkpoint:** compact typed continuation package for a new Deep Agent session.
- **Independent verifier:** separately bound operation whose accepted decision is required for completion.
- **Convergence decision:** typed continue, revise, repair, accept, degrade, fork, escalate, pause, or stop proposal.
- **No-progress/repeated-blocker observation:** method-versioned evidence evaluated across iterations.

## Invariants

1. Goal text cannot expand the objective, acceptance, inputs, authority, budget, or prohibited-work envelope.
2. An executor's completion claim is never sufficient; a separately bound verifier is mandatory.
3. Each significant iteration is a generic `OperationWorkflow` child with exact identity, binding, reservation, workspace, and evidence.
4. Continuing-session and fresh-from-handoff modes are explicit; rollover never relies on hidden context.
5. Goal revision, goal iteration, operation attempt, execution generation, and Continue-As-New segment are distinct.
6. Async subgoals use the canonical subordinate contract or are escalated by the governance classifier.
7. The interpreter proposes terminality; the lifecycle reducer assigns it.

## State and lifecycle

An admitted run begins with Goal Revision 1. Each iteration claims the revision, reserves capacity, runs a bounded operation, persists result/evidence/usage/handoff refs, and invokes an independent verifier. The interpreter evaluates accepted evidence and selects a typed transition: accept, continue same revision, create a bounded new revision, repair, wait, pause, fork request, escalation, degradation, or stop. A fresh session rehydrates only the typed handoff/context slices and exact bindings.

## Requirements

### REQ-BP-GD-001 — Fixed objective envelope

A GoalDirected blueprint MUST freeze objective, acceptance contract, admitted-input classes, authority/capability ceiling, budget, prohibited work, outputs, linked-run slots, verifier policy, handoff/session policy, and stopping limits.

**Verification:** publication and control tests reject missing or contradictory envelope fields.

### REQ-BP-GD-002 — Immutable bounded Goal Revisions

Every Goal Revision MUST record parent revision, tactical changes, evidence, unmet obligations, author/proposer, deciding authority, applicability, and digest and MUST remain inside the frozen envelope.

**Verification:** accept tactical refinement; reject scope, authority, input, acceptance, and budget expansion.

### REQ-BP-GD-003 — Iterations are independently durable

Every significant goal iteration MUST run as an `OperationWorkflow` with a new semantic iteration identity, exact goal revision, Deep Agent binding, reservation, workspace, cancellation context, and immutable output/evidence/usage refs.

**Verification:** worker loss, activity retry, semantic retry, and iteration lineage.

### REQ-BP-GD-004 — Independent verification is mandatory

Completion MUST require an independently bound verifier whose authority, model/tools/capabilities, inputs, rubric, and output contract are exact and whose result is accepted by application authority.

**Verification:** executor claims cannot terminate; stale, self-produced, or mismatched verifier evidence is rejected.

### REQ-BP-GD-005 — Fresh-session handoff is typed and sufficient

When policy selects a fresh session, the prior iteration MUST emit an immutable handoff containing the exact goal revision, accepted facts/evidence/artifacts, attempts and rejected tactics, unresolved obligations, blockers, effect frontier, budget/limits, context decisions, and source digests needed to resume without hidden chat history.

**Verification:** a new empty Deep Agent session resumes from the handoff and exact context slices only.

### REQ-BP-GD-006 — Context rollover is governed

Token/context thresholds MUST trigger a typed rollover decision that compacts or selects context under declared policy, preserves provenance and protected facts, and never changes semantic iteration, authority, or acceptance silently.

**Verification:** threshold, compaction failure, protected-content, and repeated-rollover cases.

### REQ-BP-GD-007 — Convergence is deterministic over accepted evidence

`GoalDirectedInterpreter` MUST evaluate accepted verifier results, obligation state, progress/blocker evidence, budgets, limits, and controls using a fixed precedence: invariant/authority breach, hard budget, verified completion, irrecoverable failure, no-progress/repeated blocker, iteration limit, then authorized soft-budget continuation.

**Verification:** decision-table and property tests for conflicting stopping signals.

### REQ-BP-GD-008 — Async subgoals use governed delegation

An async subgoal MAY run as a subordinate execution under `CON-CP-ASYNC-SUBAGENT-V1` only when its objective, authority, lifecycle, output, budget, and settlement remain inside the parent iteration contract; otherwise the classifier MUST select another operation or linked run.

**Verification:** local subordinate, operation escalation, and linked-run escalation fixtures.

### REQ-BP-GD-009 — Revision and fork are distinct

A broader change outside the objective envelope MUST NOT become a Goal Revision and MUST be rejected or routed to an allowed Run Control Revision, linked run, fork request, or new run; a model cannot create the fork directly.

**Verification:** protected-field edits and authorized fork-proposal flow.

### REQ-BP-GD-010 — Stopping produces a proposal, not terminality

The interpreter MUST emit a typed terminalization/continuation proposal binding the current goal revision, verifier decision, obligation evidence, outputs, degradations, blockers, budgets/effects, and stale frontier; only the lifecycle reducer MAY terminalize.

**Verification:** valid completion, partial completion, failure, cancellation, iteration exhaustion, and stale proposal.

### REQ-BP-GD-011 — Pause is a durable, resumable state

When convergence policy selects `pause`, or an accepted run-control pause targets the run, the GoalDirected family MUST do the following:

1. quiesce at an iteration boundary, with no executor or verifier unit active;
2. persist a durable paused state that binds the active Goal Revision, next iteration, session generation and mode, handoff ref, effect frontier, and held reservations;
3. record the pause's `applied` receipt;
4. wait without failing, terminating, or raising a workflow error until an accepted resume is delivered.

A resume MUST continue from that exact frontier. It MUST NOT re-run settled iterations, mutate frozen bindings, or change the envelope. A reused session continues from the namespace head recorded before the pause (REQ-BP-GD-012). A policy-selected rollover instead continues fresh from the handoff. A paused run remains cancellable under the shared saga. The paused state survives worker restart and Continue-As-New.

A pause requested while a unit is active is `delivered` immediately and `applied` only at the next boundary. Reservations for iterations not yet started are released on pause and re-reserved on resume. A resume that cannot re-reserve is rejected `insufficient_budget`, and the run stays paused. A policy-selected pause enters run control as a pause proposal bound to the convergence decision.

**Amendment:** AMD-RRM-001. Clarified: `paused` with explicit resume is already mandated by `SPEC-CP-RUN-CONTROL` § State and lifecycle and REQ-CP-RUN-004, and `pause` is already a convergence decision here. The new ID gives the family a testable owner.

**Verification:** policy and command pauses persist across worker restart and forced Continue-As-New; no workflow failure is reported for a pause; resume continues at the recorded next iteration with an unchanged revision and bindings; cancellation while paused completes the saga.

### REQ-BP-GD-012 — Shared-session transitions are ordered

Executor units that share a governed session MUST execute strictly in goal-iteration order, with at most one in-flight invocation per cognitive session namespace. Each unit's expected source checkpoint MUST be the namespace head: the `result_key` of the previous unit's accepted transition in that namespace. Its invocation MUST be pinned to that checkpoint (REQ-CP-DA-017).

Verifier units MUST use a namespace distinct from the executor's. A rollover or fresh-from-handoff mode MUST start a new session generation and namespace rather than branch the existing thread. A generation boundary on a GoalDirected unit keeps its `unit_key`. That generation runs fresh-from-handoff in the namespace `belllabs/goal/{run}/epoch/{epoch}/unit/{unit_key}/gen/{execution_generation}`. The next iteration is admitted into a new `session_generation`. Session reuse is intentional, recorded state. A checkpoint in a shared namespace is attributed to the unit whose stamped invocation wrote it.

**Amendment:** AMD-RRM-001, new (ordering protocol for REQ-BP-GD-005 and 006).

**Verification:** iterations N and N+1 in one session produce a linear stamped lineage; a concurrent second invocation of the session is rejected; rollover produces a new empty namespace; a generation boundary keeps the `unit_key`, runs in the unit-generation namespace, and moves the next iteration to a new session generation; a recovered iteration never re-appends its input into the shared thread.

## Contracts

`CON-BP-GOAL-DIRECTED-V1` defines the objective envelope, revision policy, operation/subgoal classes, session modes, iteration/convergence limits, verifier, snapshots, and stopping policy. `CON-BP-GOAL-HANDOFF-V1` defines the fresh-session handoff and context rollover record. `CON-BP-GOAL-VERIFICATION-V1` defines verifier binding, evidence/rubric, decision, and applicability.

## Failure, retry, cancellation, and recovery

Technical retries preserve iteration/attempt identity. New tactics or repair produce a new Goal Revision and/or iteration as declared. Recovery rehydrates exact accepted revision, handoff, operation/async children, reservations, and effect frontier. Cancellation follows the shared saga and preserves valid partial evidence without implying completion.

## Security, tenancy, redaction, and secrets

The objective and context cannot grant capabilities. Every iteration and subgoal receives exact tenant/data/authority ceilings. Handoffs contain immutable refs and redacted bounded summaries, never secrets, PHI, unrestricted transcripts, or hidden credentials.

## Dependencies and compatible implementations

The initial implementation uses Temporal `GoalDirectedWorkflow`, `GoalDirectedInterpreter`, generic `OperationWorkflow` iterations, and local Deep Agents `0.7.5`. Remote placement is allowed only after its separate qualification.

## Qualification and evidence

`QUAL-BP-GOAL-DIRECTED-CONVERGENCE` must prove independent verification, revision bounds, fresh-session recovery, context rollover, no-progress/repeated blockers, budgets/limits, async subgoal classification, cancellation, Continue-As-New, and deterministic stopping.

## Open decisions

- Exact workflow-specific verifier rubrics, progress measures, and numeric iteration/rollover limits.

## Initial vertical decision

The first production-shaped GoalDirected vertical is the existing schema-grounding supporting-graph
reconciliation use case. WP-CP-050 must express it through the canonical objective envelope,
independent verifier operation, fresh-session handoff, and shared root/operation contracts; it may
reuse domain handlers but not the current direct activity or OpenAI Agents SDK session path.

## Non-goals

- Unbounded autonomous goal expansion.
- Treating a Deep Agent plan or checkpoint as a Goal Revision.
- Creating canonical Workflow Types for each subgoal or iteration.

## Source lineage and supersession

This specification extracts and supersedes all GoalDirected semantic material from the old combined foundation 03 and the frozen Stage 5 package family.

## Amendment record

| Amendment | Recorded | Status | Scope |
|---|---|---|---|
| AMD-RRM-001 | 2026-10-01 | proposed for acceptance (RRM-001 review pending) | New IDs: REQ-BP-GD-011 (clarifies already-mandated pause semantics) and REQ-BP-GD-012 (new ordering protocol). The fork boundary for this family is defined by REQ-CP-EXEC-016. Independent-review fixes (verdict `accept_with_fixes`) were applied on the same date. |

The notation follows `SPEC-CP-DURABLE-EXECUTION` § Amendment record.
