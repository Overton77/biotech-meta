## Problem Statement

Compiling an Effective Run Configuration does not itself authorize execution. The service needs one transactional control-plane boundary that decides whether a Run Request becomes a Workflow Run, prevents duplicate or conflicting commands, records every accepted lifecycle transition, publishes durable domain events without dual-write gaps, and enforces hierarchical multidimensional budgets.

Without this boundary, an API caller, agent, Temporal workflow, worker, callback, or dashboard action could create execution state directly, mutate a run with last-write-wins behavior, collapse waiting and pausing into one status, treat Temporal status as domain authority, duplicate side effects during retries, or spend beyond an unreserved budget. The current target implementation has no application PostgreSQL tables and exposes only bootstrap health behavior, so lifecycle and budget authority must be established explicitly rather than inferred from existing code.

## Solution

Create a PostgreSQL-backed Run Request admission service and application-owned Workflow Run Lifecycle Reducer. Admission validates caller identity and authority, request idempotency, the Workflow Type Input Admission Contract and Workflow Invariants, the immutable Run Input Manifest, approvals and permissions, the compiled Effective Run Configuration, baseline Budget Envelope, and any parent constraints before a Workflow Run exists.

An accepted request atomically creates the Workflow Run current projection in `pending`, stores the accepted command/request result, establishes authoritative budget accounts and reservations, and writes versioned outbox events. A rejected request creates no Workflow Run and no run outcome.

All later lifecycle changes arrive as typed Workflow Lifecycle Commands or observed facts. The reducer checks command idempotency, expected aggregate version, transition authority, blueprint and invariant constraints, dependencies, waits, pauses, cancellation state, obligations, and budgets. Each accepted transition atomically appends an immutable transition record, updates the current projection, stores the command result, applies related budget ledger changes, and writes outbox envelopes.

The lifecycle uses separate phase, wait/pause reason, terminal outcome, and purpose-bound output-readiness axes. PostgreSQL is the sole transactional authority for those records and budgets; Temporal executes accepted intent but never becomes the domain state store.

## User Stories

1. As an API caller, I want to submit a typed Run Request with a stable idempotency key, so that retries do not create duplicate runs.
2. As an agent, I want to propose a Run Request through the same application service as a human, so that model execution cannot bypass admission.
3. As a caller, I want a duplicate request with the same identity and payload to return the prior accepted result, so that timeout recovery is safe.
4. As a caller, I want reuse of an idempotency identity with a conflicting payload rejected, so that deduplication cannot hide a changed request.
5. As a security operator, I want caller identity, asserted authority, permissions, and delegation ceilings validated, so that availability is not mistaken for authorization.
6. As a workflow owner, I want the Input Admission Contract enforced before a Workflow Run exists, so that inadmissible inputs never become execution state.
7. As a workflow owner, I want Workflow Invariants enforced without override, so that no human, policy gate, or trusted agent can authorize an invalid run.
8. As an operator, I want explicitly overridable policy gates distinguished from invariants, so that exceptions are narrow and audited.
9. As a caller, I want the exact immutable Run Input Manifest and Effective Run Configuration digest bound at admission, so that accepted execution cannot drift.
10. As an operator, I want rejected Run Requests retained as decisions without creating Workflow Runs, so that rejection is auditable without inventing a run outcome.
11. As a scheduler, I want an accepted run to begin in `pending`, so that durable execution start can occur asynchronously after the admission transaction commits.
12. As a Temporal starter, I want a durable outbox event for an accepted run, so that a transient start failure can be retried without repeating admission.
13. As an operator, I want exactly one logical Workflow Run for one accepted request identity, so that repeated relay delivery is harmless.
14. As a command issuer, I want every Workflow Lifecycle Command to include an expected run version, so that concurrent changes do not use last-write-wins.
15. As a command issuer, I want an exact duplicate accepted command to return its prior result even after the run has advanced, so that retries are stable.
16. As a command issuer, I want a stale conflicting command rejected or explicitly reevaluated, so that its original assumptions are not silently applied.
17. As a workflow owner, I want one reducer to validate all lifecycle mutations, so that humans, agents, workers, callbacks, and Temporal follow the same rules.
18. As an auditor, I want each accepted transition to preserve prior and resulting phase, aggregate versions, actor, authority, reason, evidence, correlation, and causation, so that the history is explainable.
19. As a query client, I want an efficient current projection, so that I do not need to replay the transition ledger for ordinary reads.
20. As a recovery operator, I want the current projection reconstructable from the transition ledger, so that corruption can be diagnosed and repaired.
21. As an operator, I want lifecycle phase separate from wait reason, pause reason, terminal outcome, and output readiness, so that one overloaded status cannot hide meaning.
22. As an operator, I want the shared phases limited to `pending`, `active`, `waiting`, `paused`, `cancelling`, and `terminal`, so that infrastructure details do not become domain phases.
23. As a workflow participant, I want a run to remain `active` while any admissible work can progress, so that a local wait does not freeze unrelated branches.
24. As a workflow participant, I want a run to become `waiting` only when no work can progress and a declared condition may permit future progress, so that waiting is derived consistently.
25. As an operator, I want verified satisfaction of a wait condition to resume affected work automatically, so that no new authority grant is fabricated.
26. As an operator, I want a paused run to require an explicit authorized resume decision, so that clearing an apparent cause does not bypass the pause authority.
27. As a caller, I want cancellation to enter `cancelling` while effects settle, so that cancellation is not mistaken for an instantaneous process kill.
28. As a workflow owner, I want terminal outcome assigned exactly once, so that terminality is immutable.
29. As a downstream consumer, I want outcomes limited to `completed`, `partially_completed`, `failed`, and `cancelled`, so that completion semantics are consistent.
30. As a downstream consumer, I want output readiness evaluated separately, so that a completed run does not imply an output is admissible for every purpose.
31. As an artifact consumer, I want valid partial outputs from failed or cancelled work preserved without changing the run outcome, so that useful evidence is not lost.
32. As an event consumer, I want the transition, projection, command result, and outbox envelopes committed atomically, so that no accepted change lacks a durable publication record.
33. As an event consumer, I want stable event identities and aggregate versions, so that at-least-once delivery can be deduplicated and ordered per aggregate.
34. As an event consumer, I want version gaps detected and replayable from durable cursors, so that missed or out-of-order events do not corrupt projections.
35. As an operator, I want no global ordering promise across unrelated runs, so that the system does not depend on an unavailable total order.
36. As a budget owner, I want a multidimensional Budget Envelope, so that tokens, money, elapsed time, tool use, cycles, concurrency, and external quotas are governed independently.
37. As a budget owner, I want soft thresholds and hard caps represented separately, so that continuation can be proposed before execution must stop.
38. As an operation scheduler, I want budget reserved before work starts, so that concurrent work cannot oversubscribe a shared envelope.
39. As an accountant, I want estimated reservations reconciled to actual usage and unused capacity released, so that ledger balances remain accurate.
40. As a budget owner, I want consumption in one dimension prohibited from silently borrowing another dimension, so that a dollar surplus cannot excuse a token or tool quota breach.
41. As an agent, I want a typed Continuation Proposal at a soft threshold, so that I can request reduced effort, degradation, additional reservation, or termination without self-authorizing it.
42. As a policy owner, I want only deterministic policy, delegated authority, or a human to accept a Continuation Proposal, so that prompts cannot enlarge budgets.
43. As a scheduler, I want hard-cap exhaustion to prevent the next affected operation from starting, so that enforcement reflects what the runtime can actually guarantee.
44. As an auditor, I want pending external charges and in-flight reservations represented explicitly, so that settlement does not release funds optimistically.
45. As a maintainer, I want PostgreSQL to be the only writer of run lifecycle and budget authority, so that MongoDB and Temporal cannot independently advance a run.

## Implementation Decisions

- Implement typed Run Request admission as an application service behind FastAPI command endpoints and project-owned agent tools. No caller writes PostgreSQL, starts Temporal, or creates a Workflow Run directly.
- A Run Request includes stable request identity, caller and authority context, exact Workflow Type and compiled Effective Run Configuration references and digests, immutable Run Input Manifest reference, requested sponsorship, approvals, correlation context, and parent-link context when applicable.
- Admission verifies the Effective Run Configuration against MongoDB or its immutable object-store payload through an application adapter, but the admission transaction persists only exact identifiers, digests, and accepted decision references in PostgreSQL. MongoDB cannot advance lifecycle.
- Request idempotency identity is unique within its declared command scope. Exact duplicates return the stored result; conflicting fingerprints under the same identity are rejected. Rejected requests are decision records, not Workflow Runs.
- An accepted admission transaction creates the run projection at version 1 in `pending`, records the accepted request result, establishes baseline budget accounts/reservations, and inserts the outbox envelopes needed to start execution and update projections.
- The baseline Budget Envelope is hierarchical and multidimensional. The required shared dimensions are estimated and actual currency, input/output/total tokens where applicable, elapsed and active-compute time, model turns, total and per-resource tool calls, MCP server/tool calls, external-service quotas, stage cycles, workflow cycles, goal iterations, operation attempts, subagent spawns, and concurrency slots. Workflow specifications may add typed dimensions.
- This specification fixes budget semantics, not numeric defaults. A Workflow Type or authorized profile must supply explicit hard/soft values or explicit unbounded/not-applicable declarations for applicable dimensions; the admission service does not invent values.
- Authoritative budget accounts, reservations, adjustments, releases, pending settlements, and consumption ledger entries live in PostgreSQL. Every ledger mutation has a stable idempotency identity and preserves parent-child rollup.
- Reserve before dispatch, reconcile after observed usage, and release only settled unused capacity. Hard caps stop new affected work; cancellation of already accepted provider work is best effort when the adapter supports it.
- Every lifecycle mutation is a typed command or typed observed fact handled by one application-owned reducer. Direct updates to the run projection are prohibited outside projection reconstruction under controlled recovery.
- Commands include stable command identity, target run, expected aggregate version, requested transition or fact, actor and authority context, reason, evidence, time, correlation, and causation.
- The reducer validates the current version, selected blueprint and applicable Effective Run Configuration revision, Workflow Invariants, transition preconditions, actor authority, approvals, dependency state, wait/pause scope, obligations, and budget state.
- The shared lifecycle phase vocabulary is exactly `pending`, `active`, `waiting`, `paused`, `cancelling`, and `terminal`. Queueing, dispatch, retry backoff, recovery, compensation, worker availability, and provider throttling are events or typed conditions, not extra phases.
- Aggregate phase is derived from runnable work. Local waits and pauses remain visible while the aggregate stays active if unaffected work can progress.
- Waiting is caused by blueprint-declared verifiable Workflow Run Wait Conditions with timeout and fallback behavior. Verified satisfaction resumes affected work without a new grant. Pausing is caused by an immutable authorized Pause Decision and requires an immutable authorized Resume Decision.
- Orchestration, evaluators, workers, and agents may submit only a typed `TerminalizationProposal`. It binds the exact obligation-matrix revision, accepted obligation evidence and digests, stale-evidence frontier, output references, degradations, cancellation state, proposing execution binding, and idempotency identity. It is not a lifecycle decision.
- The reducer validates a Terminalization Proposal against current run version, blueprint, accepted control and obligation revisions, current evidence references, pending waits/links, budget settlement, and transition authority. Stale or incomplete proposals are rejected or returned for reevaluation. Only the reducer assigns exactly one outcome: `completed`, `partially_completed`, `failed`, or `cancelled`.
- Required obligations must be accepted for both completed outcomes; `partially_completed` additionally records failed declared degradable work and valid outputs. A verifier's `degrade_and_complete` proposal maps to `partially_completed` only when every required obligation is accepted and the declared degradable failures and valid outputs satisfy the Workflow Type contract.
- Cancellation is an authorized lifecycle command followed by a `cancelling` settlement phase. Existing valid partial outputs remain immutable and independently assessable, but they do not turn cancellation into partial completion.
- A blueprint-declared terminal-finalization policy determines whether failed or cancelling work may attempt partial output assembly. An accepted Finalization Plan freezes the eligible immutable evidence frontier, permitted assembly/reporting operations, dedicated budget reservation, side-effect allowlist, timeout, and omission reason contract. Finalization cannot start new research, retrieval, mutation, repair, linked work, or unadmitted inputs. Timeout, invalid evidence, insufficient budget, or failed validation produces an explicit output-omission reason and never delays terminalization indefinitely.
- Output readiness is purpose-bound and stored as separate immutable decisions/projections. A readiness reevaluation never reopens or mutates a terminal run.
- Persist an append-only Workflow Lifecycle Transition Record and a mutable current projection. The transition ledger is sufficient to reconstruct lifecycle projection but does not event-source unrelated workflow documents and artifacts.
- Commit the accepted command result, transition record, current projection, related authoritative budget entries, and versioned outbox envelopes in one PostgreSQL transaction.
- Outbox events use stable identity, event type and schema version, aggregate type/identity/version, occurrence and recording times, actor, correlation and causation, and a typed payload or durable payload reference.
- Delivery is at least once. Consumers maintain durable inbox/applied-event identities or cursors, enforce aggregate-version order, detect gaps, defer out-of-order application when required, and make external effects idempotent.
- The event envelope and relay are transport-neutral. Initial PostgreSQL relay delivery is permitted; choosing Kafka or NATS JetStream is deferred and cannot change domain event or idempotency semantics.
- Temporal receives accepted start, control, and cancellation intent through idempotent relays. Temporal history owns durable execution mechanics but never replaces PostgreSQL lifecycle, command, transition, budget, or outbox authority.
- PostgreSQL row-level security is defense in depth for tenant-scoped application records. Application authorization remains mandatory and is evaluated before reducer execution.
- MongoDB/Beanie continues to own immutable Effective Run Configuration payloads and workflow-specific document records. Object storage owns large payloads. Neo4j is not read or written by admission or lifecycle transactions.
- Dependency note: this specification depends on specification 1 for exact immutable definitions and configuration compilation. Specification 3 depends on these admission, lifecycle, outbox, and budget services. Specification 4 records operation usage against these reservations but cannot mutate accounts independently.

## Testing Decisions

- Use the public command/application-service seam as the primary test boundary, with FastAPI command endpoints as the highest full-stack seam where practical. Run tests against disposable PostgreSQL and the real reducer; do not test repository call sequences.
- Exercise accepted admission from request through committed current projection, command result, budget reservation, and outbox rows, then observe the result through public query contracts.
- Prove exact duplicate Run Requests return the original run and result, while a conflicting payload under the same identity is rejected and creates no second run.
- Prove failed admission creates no Workflow Run, Temporal start request, or budget account, while preserving the rejection decision required by the API contract.
- Prove a run cannot be admitted with a missing, digest-mismatched, unauthorized, or superseded configuration binding.
- Prove invariant violations cannot be overridden and explicitly overridable gates require the recorded authority and rationale.
- Execute concurrent commands against the same expected version and prove only one conflicting transition commits; the loser receives a stale-version result rather than overwriting state.
- Redeliver an accepted command after later transitions and prove it returns the original accepted result without appending another transition or event.
- Prove every accepted transition atomically exposes matching transition, projection version, command result, budget effects, and outbox envelope; inject transaction failure and prove none become visible.
- Prove phase derivation remains active with runnable unaffected work, enters waiting only when all progress is blocked by satisfiable waits, and enters paused only when applicable pauses block all otherwise runnable work.
- Prove satisfying a wait resumes automatically, while clearing a pause cause does not resume without an authorized Resume Decision.
- Prove terminal outcome is assigned once and that invalid terminal combinations are rejected.
- Prove evaluators and Temporal can submit Terminalization Proposals but cannot assign an outcome; stale evidence, stale run versions, unresolved required obligations, or mismatched digests are rejected by the reducer without a lifecycle transition.
- Prove required-obligation failure yields `failed`, degradable-obligation failure with valid outputs yields `partially_completed`, and authorized cancellation yields `cancelled` even when valid partial outputs exist.
- Prove terminal finalization uses only the frozen eligible frontier and dedicated reservation, cannot launch prohibited new work, terminates at its timeout, and records a typed omission reason when no valid partial output can be assembled.
- Prove readiness decisions can change for a new purpose without altering lifecycle phase, outcome, historical transition records, or output versions.
- Prove reserve-before-dispatch under concurrency prevents oversubscription, duplicate usage reports do not double-charge, and settled unused reservations return to the parent account.
- Prove dimensions do not silently offset one another and a hard cap blocks the next affected dispatch.
- Prove soft thresholds create a Continuation Proposal but do not enlarge a reservation until accepted through authorized policy or command.
- Prove pending external charges remain pending through cancellation or terminal settlement until reconciled.
- Redeliver outbox envelopes and prove consumers deduplicate by event identity, enforce per-aggregate versions, detect a gap, and recover from a durable cursor.
- Use Temporal’s test environment only for the relay boundary: prove accepted start/cancel intent is delivered idempotently and that a Temporal status change alone cannot mutate PostgreSQL lifecycle.
- Avoid tests that assert SQL statement order, table names, reducer helper methods, Temporal internal history events, or broker implementation. Assert command results and durable external behavior.

## Out of Scope

- Definition authoring, publication, canonical configuration compilation, and alias resolution, which are owned by specification 1.
- StageGraph scheduling, GoalDirected iteration, semantic cycle execution, linked-run composition behavior, and Continue-As-New, which are owned by specification 3.
- OpenAI Agents runtime mapping, Operation Execution Bindings, delegation execution, workspace materialization, snapshots, and artifact promotion, which are owned by specification 4.
- Numeric workflow-specific budget defaults, conversion policies, evaluation thresholds, timeout durations, and approval thresholds.
- Durable broker selection, deployment topology, worker autoscaling, and dashboard UI.
- Full event payload catalogs for workflow-specific findings, artifacts, evaluations, and outputs.
- Neo4j ingestion, graph mutation, source-domain transactions, and object-storage artifact semantics.
- General event sourcing of every domain record.

## Further Notes

- Dependency order is strict: admission consumes an already compiled immutable configuration from specification 1. Compilation failure or unresolved mutable aliases must never produce a pending run.
- Authority, admission, and completion are not tuning choices. The application reducer and PostgreSQL transaction remain authoritative regardless of later framework, broker, schema-name, or deployment decisions.
- Deferred tuning choices include exact table names, index names, outbox polling cadence, relay batch size, event retention, broker selection, default timeout values, and workflow-specific numeric budget thresholds.
- Exact transition commands and facts beyond start, wait satisfaction, pause, resume, cancellation, and terminalization may be added only as typed, versioned contracts that preserve reducer authority and optimistic concurrency.
- PostgreSQL is authoritative for run lifecycle, transitions, command idempotency, budgets, outbox, and API/realtime projections. MongoDB is authoritative for the immutable configuration and workflow-shaped documents. Temporal owns durable execution history. Object storage owns large immutable payloads. Neo4j owns approved canonical graph knowledge.
