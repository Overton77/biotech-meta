---
id: SPEC-CP-DURABLE-EXECUTION
title: Temporal run and operation hierarchy, continuity, messaging, and linked runs
status: canonical
version: 1
governed_by: [ADR-0003]
depends_on: [SPEC-CP-DEFINITIONS, SPEC-CP-RUN-CONTROL]
sources:
  - path: ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
    sections: [shared orchestration and linked-run decisions]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [7, 9, 10, 11, 12, 18, 22]
supersedes:
  - shared orchestration portions of ../pre-research/control-plane-foundations/03-durable-blueprint-orchestration-and-linked-runs.md
requirements:
  - REQ-CP-EXEC-001
  - REQ-CP-EXEC-002
  - REQ-CP-EXEC-003
  - REQ-CP-EXEC-004
  - REQ-CP-EXEC-005
  - REQ-CP-EXEC-006
  - REQ-CP-EXEC-007
  - REQ-CP-EXEC-008
  - REQ-CP-EXEC-009
  - REQ-CP-EXEC-010
  - REQ-CP-EXEC-011
  - REQ-CP-EXEC-012
contracts:
  - CON-CP-TEMPORAL-IDENTITY-V1
  - CON-CP-WORKFLOW-MESSAGE-V1
  - CON-CP-LINKED-RUN-V1
  - CON-CP-CONTINUATION-V1
qualification_obligations:
  - QUAL-CP-TEMPORAL-REPLAY-RECOVERY
  - QUAL-CP-LINKED-RUN-SEMANTICS
---

# Temporal run and operation hierarchy, continuity, messaging, and linked runs

## Purpose

Define the shared durable execution shell beneath every workflow family and above every bounded operation, without allowing Temporal to own BellLabs domain semantics.

## Boundary and explicit non-ownership

This specification owns `BellLabsRunWorkflow`, the family-child boundary, the generic `OperationWorkflow`, workflow/activity separation, identity continuity, durable messaging transport, cancellation/recovery mechanics, linked-run mechanics, and Continue-As-New. StageGraph readiness and GoalDirected convergence belong to their blueprint specifications. Agent configuration/materialization belongs to `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Authority and persistence

Temporal owns durable execution mechanics and compact replay state. PostgreSQL/application services remain authoritative for lifecycle, commands, budgets, effects, settlement, terminality, linked-run decisions, and message ledgers. Workflow code may cache accepted refs and versions but never becomes the only copy of a business decision.

## Vocabulary and identities

- **BellLabs run ID:** stable product/domain run identity.
- **Execution epoch:** product-level execution generation; a fork starts a new run at epoch 1.
- **Technical segment:** Continue-As-New segment within the same run and epoch.
- **Temporal Workflow ID/Run ID:** runtime lineage, not BellLabs identity.
- **Semantic operation attempt:** independently durable unit with stable meaning across technical retries.
- **Execution/intervention generation:** provider/runtime generation within one semantic attempt after disruptive recovery.
- **Linked run:** distinct admitted Workflow Run related through a durable Run Composition Link.

## Invariants

1. One admitted run has one distinct `BellLabsRunWorkflow` root and exactly one selected family child.
2. Temporal workflow code is deterministic and performs no database, network, object-store, model, MCP, sandbox, or secret I/O.
3. Every independently messageable, cancellable, resumable, waiting, reusable, or effect-reconciling semantic operation is durably represented by `OperationWorkflow` or a linked run.
4. Activity retries preserve semantic attempt and effect identities; semantic retries create new immutable attempts.
5. Continue-As-New changes only the technical segment/Temporal Run ID, never the BellLabs run or epoch.
6. A BellLabs fork creates a new run at epoch 1 from an immutable semantic snapshot.
7. Provider, child-workflow, or activity completion is proposed evidence until authoritatively reconciled.

## State and lifecycle

`BellLabsRunWorkflow` starts the selected family child, routes accepted commands/facts, coordinates cancellation and deadlines, reconciles family results, and continues as new. A family workflow repeatedly applies its pure interpreter and schedules `OperationWorkflow` children. An `OperationWorkflow` prepares exact bindings, starts or reconnects to bounded work, manages subordinate waits and async children, persists compact progress refs, reconciles effects/results, and returns a typed outcome manifest.

## Requirements

### REQ-CP-EXEC-001 — One stable Temporal root

Each admitted Workflow Run MUST map to exactly one `BellLabsRunWorkflow` root that owns macro execution mechanics, command routing, selected-family lifecycle, deadlines, cancellation coordination, continuation, and runtime lineage.

**Verification:** duplicate start delivery attaches to the same root and does not create another macro scheduler.

### REQ-CP-EXEC-002 — Family semantics remain delegated

The root MUST delegate readiness, iteration, convergence, and family completion proposals to the exact family workflow and pure interpreter and MUST NOT implement family-specific semantics itself.

**Verification:** shared root tests run both blueprint families without family branching beyond typed dispatch.

### REQ-CP-EXEC-003 — Generic durable operation boundary

`OperationWorkflow` MUST represent one stable semantic operation attempt, support one or more activities and subordinate runtime tasks, and return only a compact typed outcome manifest after authoritative persistence/reconciliation.

**Verification:** native and Deep Agent operations share the contract and survive worker loss.

### REQ-CP-EXEC-004 — Deterministic workflows and idempotent activities

Temporal workflow code MUST use only frozen inputs and accepted compact state; all nondeterministic I/O and application mutations MUST occur through idempotent activities and services.

**Verification:** replay tests fail on workflow-side I/O and prove stable scheduling for captured histories.

### REQ-CP-EXEC-005 — Stable retry and generation identities

Technical workflow/activity retries MUST preserve the semantic operation attempt and effect keys, while policy-authorized new semantic work creates new attempt identity; disruptive restart MUST preserve the attempt and increment its execution/intervention generation.

**Verification:** retry, repair, intervention, and late-old-generation result tests.

### REQ-CP-EXEC-006 — Authoritative message ledger

Commands and messages MUST be immutable, target a stable run/operation/subordinate identity, use monotonic target sequencing and durable inbox/ledger/outbox records, and expose receipt states from acceptance through checkpoint-committed application or terminal rejection.

**Verification:** ordered batch claim, lease expiry, redelivery, duplicate IDs, stale targets, and receipt progression.

### REQ-CP-EXEC-007 — Typed Temporal messaging transport

Signals MUST carry compact deduplicated facts, Updates MUST return command acceptance/rejection, and Queries MUST remain diagnostic; handlers MUST NOT directly mutate lifecycle or settlement authority and MUST quiesce before Continue-As-New.

**Verification:** signal/update replay, concurrent handler serialization, and product-query independence.

### REQ-CP-EXEC-008 — Cancellation is a reconciliation saga

Cancellation MUST authorize and journal intent, request subordinate quiescence/cancellation, reconcile effects, budgets, checkpoints, and late outputs, quarantine superseded generations, and only then propose terminal settlement.

**Verification:** cancellation before dispatch, during model/tool work, during async child execution, and after ambiguous effect.

### REQ-CP-EXEC-009 — Linked runs are independently admitted

Crossing a Workflow Type boundary MUST create a typed linked Run Request, independently compiled/admitted child Workflow Run, Run Composition Link, distinct reservation, and explicit parent dependency policy.

**Verification:** child admission cannot be bypassed by the parent or Temporal child creation.

### REQ-CP-EXEC-010 — Linked results require parent admission

Every exact linked-run result MUST receive an immutable parent-side `admit`, `conditionally_admit`, `reject`, or `defer` decision before it can satisfy an obligation or enter parent work; late results MUST NOT mutate a terminal parent.

**Verification:** all dependency classes, result decisions, timeout/failure, and late completion.

### REQ-CP-EXEC-011 — Continue-As-New preserves semantics

Continue-As-New MUST preserve the BellLabs run, epoch, exact configuration, semantic counters, accepted revisions, pending commands/waits, active child identities, links, reservations, and effect frontier while advancing only the technical segment and Temporal Run ID.

**Verification:** forced continuation with active operations, pending messages, and deduplicated replay.

### REQ-CP-EXEC-012 — Semantic forks are new runs

A product fork or edited-state start MUST use an immutable `RunSnapshotManifest`, validate the patch and reuse frontier, leave active parent children parent-owned, create a new BellLabs run at epoch 1, and independently compile/admit it.

**Verification:** fork lineage, protected-field rejection, no pending-message copying, and compatible-result reuse.

## Contracts

`CON-CP-TEMPORAL-IDENTITY-V1` distinguishes BellLabs run, epoch, technical segment, Temporal Workflow/Run, semantic attempt, activity attempt, and execution generation. `CON-CP-WORKFLOW-MESSAGE-V1` defines commands, facts, sequence, immutable IDs, claims, receipts, and payload refs. `CON-CP-LINKED-RUN-V1` defines slots, request identity, dependency classes, reservations, cancellation, and result admission. `CON-CP-CONTINUATION-V1` defines compact Continue-As-New and snapshot/fork manifests.

## Failure, retry, cancellation, and recovery

Unexpected deterministic-code failures remain repairable Workflow Task failures. Business/policy failures use typed outcomes. Long activities heartbeat compact non-sensitive progress and use distinct schedule/start/heartbeat timeouts. Recovery rehydrates authoritative application state, reconnects exact children/jobs, and never infers settlement from Temporal status alone.

## Security, tenancy, redaction, and secrets

Temporal carries identities, digests, compact status, and immutable refs—not secrets, PHI, raw corpora, transcripts, or large outputs. Public commands are authenticated and authorized before Temporal transport. Child identity and tenant scope are explicit.

## Dependencies and compatible implementations

Consumes `SPEC-CP-DEFINITIONS` and `SPEC-CP-RUN-CONTROL`. It hosts both canonical blueprint families and supplies the durable parent to `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Qualification and evidence

`QUAL-CP-TEMPORAL-REPLAY-RECOVERY` covers replay, worker loss, activity retry, messages, intervention generations, active-child continuation, and cancellation. `QUAL-CP-LINKED-RUN-SEMANTICS` covers independent admission, four dependency classes, cancellation, result admission, and late results.

## Open decisions

- Exact Continue-As-New history thresholds and message batch limits.
- Worker queue sizing and final deployment topology.

## Non-goals

- Replacing family interpreters with workflow code.
- Making Temporal Event History a product database.
- Defining capability catalog ingestion/promotion.

## Source lineage and supersession

This document extracts the shared orchestration and linked-run material from pre-research foundation 03. Family-specific content is superseded by the separate StageGraph and GoalDirected specifications.
