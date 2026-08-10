# StageGraph Refinement End-to-End Vertical Slice

## Problem Statement

The target service currently exposes health endpoints, a basic Socket.IO ping path, and one sandbox-backed Temporal probe. It does not prove that an accepted refinement Run Request can cross the FastAPI, application-control, persistence, Temporal, worker, agent, artifact, event, query, and realtime boundaries while preserving domain authority.

The first usable refinement slice must exercise the difficult seam, not a happy-path text-only demo. It must refine multimodal artifacts in parallel, preserve a corrupt artifact, durably wait for a Repair Decision, tolerate one degradable branch failure, admit an exact linked Knowledge Preflight result, assemble immutable outputs, and allow a disconnected client to resume projection updates from a durable cursor.

## Solution

Implement the `StageGraphRefinement` blueprint as the first end-to-end refinement workflow while consuming the shared compiler, transactional admission/lifecycle/outbox, budget, orchestration, operation-runtime, workspace, artifact, conversation/realtime, and linked-run foundations. This slice owns the refinement Workflow Type and StageGraph blueprint, workflow-specific activities and projections, linked Knowledge Preflight policy, and immutable refinement outputs; it does not create parallel control-plane implementations.

The Temporal Workflow deterministically orchestrates admission, branch planning, parallel artifact refinement, consolidation, optional linked work, package assembly, readiness, and reporting. Nondeterministic database, object-storage, agent, sandbox, transformation, linked-run, and evaluation work occurs in activities. API queries read durable projections, and Socket.IO emits authorization-filtered projection hints carrying durable cursors. The acceptance fixture includes text, image, PDF, and corrupt inputs, one accepted repair, one degradable branch failure, and one admitted preflight snapshot.

## User Stories

1. As an API caller, I want to submit a typed StageGraph refinement Run Request with an idempotency key, so that retries cannot create duplicate Workflow Runs.
2. As an API caller, I want an accepted command result to identify the immutable input, blueprint, and effective-configuration bindings, so that execution is reproducible.
3. As an API caller, I want a rejected Run Request to return structured admission reasons without creating a Workflow Run, so that invalid requests do not leave execution debris.
4. As an operator, I want the run to begin without a Conversation or mission, so that refinement is independently usable.
5. As a control-plane service, I want run creation, command acceptance, current lifecycle projection, and outbox publication committed atomically, so that accepted work cannot disappear between systems.
6. As an orchestrator, I want the Temporal execution to verify run identity, input manifest, blueprint, and configuration digests before substantive work, so that stale or mismatched starts fail safely.
7. As an operator, I want branch planning to classify transcript, image, PDF, and corrupt artifact subjects under a validated obligation matrix, so that each modality receives explicit work.
8. As a workflow author, I want branch topology and join behavior owned by the application blueprint, so that an agent cannot invent dependencies.
9. As an operator, I want artifact branches to progress concurrently with read-only shared inputs and exclusive writable workspaces, so that one branch cannot corrupt another.
10. As an operator, I want the transcript branch to perform bounded clarification and seed extraction, so that useful provisional signals are preserved with locators.
11. As an operator, I want the image branch to inspect modality and produce typed findings or seeds, so that non-text Starter Content is first-class.
12. As an operator, I want the PDF branch to validate and inspect the admitted representation, so that page-level findings and locators remain traceable.
13. As an operator, I want a captured corrupt artifact retained in the package with an integrity finding, so that unreadable content is not silently discarded.
14. As an operator, I want repair generation to create an immutable Repair Artifact candidate without changing the active selection, so that proposal and authority remain separate.
15. As an authorized reviewer, I want to approve, retain as companion, or reject a repair through a versioned API command, so that the decision is durable and attributable.
16. As an authorized reviewer, I want repeated delivery of the same Repair Decision command to return the original result, so that UI and network retries are safe.
17. As an operator, I want required affected work to wait durably for the Repair Decision while unrelated branches continue, so that approval does not stall the entire run unnecessarily.
18. As an operator, I want an accepted replacement to rerun only affected descendants, so that successful unrelated multimodal work is reused.
19. As an auditor, I want the original corrupt artifact, repair candidate, accepted decision, replacement selection, stale outputs, and rerun outputs preserved, so that the complete repair history is explainable.
20. As an operator, I want one configured degradable branch operation to fail without failing required obligations, so that the run can finish as partially completed.
21. As an operator, I want degradable failure to preserve error class, attempts, stopping reason, budget use, and affected obligation cell, so that partial completion is evidence-based.
22. As a parent workflow, I want to request Knowledge Preflight through a declared linked-run slot with a parent-scoped request identity, so that retries do not create duplicate child runs.
23. As a parent workflow, I want the linked preflight child to compile its own Effective Run Configuration under the parent's authority and budget ceilings, so that parent capabilities are not copied implicitly.
24. As a parent workflow, I want to receive an immutable Knowledge Preflight Snapshot only after a Linked Run Result Admission Decision, so that child completion cannot mutate parent output automatically.
25. As a parent workflow, I want a rejected or deferred linked result to remain visible without influencing package findings or readiness, so that linkage and admission remain separate.
26. As an operator, I want finding and seed consolidation to exclude stale outputs while preserving disputed alternatives, so that current state does not erase history.
27. As an operator, I want package assembly to run only after required joins and accepted decisions, so that incomplete branches cannot be mistaken for completed work.
28. As a downstream workflow, I want the Starter Package, Starter Readiness Assessment, and Decision Report emitted as separate immutable versions, so that domain output, use readiness, and explanation are not conflated.
29. As an operator, I want a run with completed required obligations and one failed degradable operation to terminate as `partially_completed`, so that the outcome reflects the accepted contract.
30. As an operator, I want a valid package available even when the run is partially completed, so that useful output survives bounded failure.
31. As an API consumer, I want to query run, stage, branch, cycle, obligation, repair, linked-run, budget, package, readiness, and report projections, so that the workflow is inspectable without reading Temporal history.
32. As an API consumer, I want query responses to identify current and stale records, so that historical outputs cannot be mistaken for active ones.
33. As a realtime client, I want authorized projection-change hints containing event version, subject, aggregate version, and durable cursor, so that updates can be correlated.
34. As a reconnecting client, I want to resume after my last durable cursor and then query current projections, so that missed socket events never lose correctness.
35. As an auditor, I want accepted decisions and final outputs durable before acknowledgement, so that transport success does not precede persistence.
36. As an operator, I want pause, resume, cancel, and fork commands to use expected run versions and typed authority, so that lifecycle changes cannot race silently.
37. As an operator, I want cancellation propagation to follow each linked run's dependency class, so that child execution is neither universally killed nor universally detached.
38. As an SRE, I want Temporal Activity retries distinguished from new operation attempts and branch cycles, so that infrastructure recovery does not distort semantic history.
39. As an SRE, I want retryable infrastructure failures retried with stable idempotency identities and bounded backoff, so that external side effects are safe.
40. As an SRE, I want semantic failures and hard budget caps surfaced as domain decisions rather than endlessly retried, so that bounded work stays bounded.
41. As a workflow owner, I want long history to Continue-As-New while retaining compact state and durable references, so that execution can remain healthy without changing domain identity.
42. As a security reviewer, I want agent and sandbox operations limited to exact resolved capabilities and workspace slots, so that prompt content cannot grant authority.
43. As a developer, I want the entire acceptance scenario runnable through the public API and query/realtime seams, so that the implementation is proven at the highest practical boundary.

## Implementation Decisions

- This slice depends on the completed deterministic contracts in specification 1 and implements only the `StageGraphRefinement` blueprint family.
- The application-owned stage graph is Admission, Branch Planning, Parallel Artifact Refinement Branches, Finding and Seed Consolidation, Optional Linked Work and Bounded Supporting Lookups, Package Assembly, Readiness Assessment, and Decision Report.
- Stage dependency edges are acyclic. Semantic rework occurs through a typed branch or stage cycle with a new objective and operation binding, never through a back-edge.
- FastAPI exposes typed command endpoints for start, repair decision, pause, resume, cancel, allowed control revision, linked-result admission, continuation decision, and fork. Every mutating command requires actor context, stable idempotency identity, expected aggregate version where applicable, and correlation metadata.
- FastAPI query endpoints expose the complete durable run projection and bounded subresource projections for branches, obligations, findings, seeds, repairs, linked runs, budgets, package, readiness, report, and event cursor ranges.
- The shared gateway, worker, compiler, admission transaction, start relay, runtime adapter, workspace service, artifact-promotion service, and realtime delivery capabilities are prerequisites. This slice registers refinement-specific contracts and handlers with those boundaries and cannot redefine their authority or persistence semantics.
- The Temporal Workflow receives only stable identifiers, immutable references, and digests. It validates bindings through an activity before execution and never queries a database or external service directly.
- Branch planning is application-validated. Agents may propose modality classification and operation order, but deterministic validation produces executable branches and obligation-cell bindings.
- The acceptance fixture creates four branches: transcript, image, PDF, and corrupt artifact. Each branch has an exclusive workspace, branch budget, operation state, cycle state, promoted candidates, and outcome.
- Transcript, image, and PDF inspection may use bounded agent activities with structured outputs. Deterministic checks and domain validation wrap all proposals.
- The corrupt artifact remains included. Its repair activity emits an immutable candidate and then the affected branch records a Workflow Run Wait Condition for a required Repair Decision.
- Unaffected branches continue while the repair wait is local. The aggregate run enters `waiting` only if no other admissible work can progress.
- A Repair Decision command is accepted by the PostgreSQL lifecycle/application authority, published through the outbox, and translated to a Temporal Update or Signal. Temporal never accepts a repair solely because a signal arrived.
- Activating the repair computes a dependency frontier, marks prior descendants stale, and starts a new semantic branch cycle for only affected work. Temporal Activity retries retain the same operation attempt; the repair cycle receives a new semantic identity.
- One expensive multimodal transformation in the acceptance fixture is configured as degradable and deliberately fails non-retryably after its bounded attempts. The branch retains other valid required outputs.
- Knowledge Preflight is requested through one declared `degradable_blocking` linked slot in the acceptance fixture. Child creation uses a parent-scoped request identity and independently compiled configuration.
- The linked-preflight consequence table is fixed:
  - while the child or a deferred result remains within its configured deadline, the affected parent obligation waits while unrelated work continues;
  - an exact compatible result from a `completed` child satisfies the linked-preflight cell only after parent-side admission;
  - an exact compatible partial result may be conditionally admitted only when its declared omissions are allowed, and then the linked-preflight cell is degraded rather than satisfied;
  - child `failed` or `cancelled`, timeout, unavailable admissible output, or final rejection/defer-at-deadline terminates the linked-preflight cell as degraded and releases the blocking wait;
  - because the fixture cell is degradable, that degradation cannot fail a required parent obligation but contributes to a `partially_completed` proposal when other required obligations pass;
  - parent cancellation requests child cancellation according to the shared dependency policy, and no late result can mutate a terminal package.
- The preflight result enters refinement only after an immutable Linked Run Result Admission Decision verifies exact output version, compatibility, provenance, permissions, freshness, child outcome/readiness, and intended parent obligation.
- A late nonblocking result cannot mutate a terminal package. Incorporation requires a successor refinement run with explicit lineage.
- Branch joins are fair and dependency-aware. Failure in one degradable branch does not discard completed branches, while an unsatisfied required cell prevents successful completion.
- Consolidation is a single-writer application operation over promoted immutable outputs. It resolves current versus stale records, preserves disputes, validates Seed Mention locators, and emits immutable consolidated groupings and coverage.
- Package assembly, readiness validation, and required Decision Report coverage are deterministic activities backed by the shared core. They emit a Terminalization Proposal over exact obligation and output revisions; only the shared lifecycle reducer assigns terminal outcome.
- The three terminal outputs are immutable and separately versioned. Their references are committed to durable projections before final acknowledgement.
- PostgreSQL owns lifecycle, commands, transitions, outbox, links, budgets, Repair Decision authority, cursors, and API/realtime projections. Mongo/Beanie owns detailed branch, operation, finding, seed, package, readiness, and report documents. Object storage owns large artifacts, reports, and snapshots.
- Domain events are versioned and at-least-once. Consumers deduplicate by event identity, verify per-aggregate version, detect gaps, and store durable consumer cursors. There is no global ordering guarantee.
- Socket.IO is a projection-hint transport, not the correctness mechanism. Every durable envelope includes event type and version, subject, correlation, aggregate version or cursor, occurrence time, and an authorization-filtered payload or reference.
- Reconnect accepts a last durable cursor, returns bounded missed projection events when retained, reports cursor expiry explicitly, and always directs the client to refresh the authoritative query projection.
- Token deltas and fine-grained agent progress may be ephemeral. Repair Decisions, linked-result admissions, branch outcomes, findings, seeds, package, readiness, report, and lifecycle transitions are durable.
- Activity retry policies distinguish transient provider, network, lease, and storage faults from non-retryable domain validation, permission, hard-budget, and bounded-model failures.
- Child workflows are used for artifact branches only when they require independent waits, cycles, cancellation, or Continue-As-New. A bounded agent or tool invocation remains an activity.
- Continue-As-New preserves run identity, input and configuration digests, active waits, branch state references, budget state, durable cursor position, and pending linked identities.
- The slice does not add raw capture. The fixture references already captured immutable artifacts.
- Dependency: the refinement deterministic core; all four control-plane foundations; canonical conversations/durable realtime; and the executable StageGraph Knowledge Preflight slice are required. The GoalDirected refinement specification extends this behavior without altering StageGraph semantics. The guest-affiliation specification plugs into a declared artifact-operation slot and additionally requires governed capability catalogs.

## Testing Decisions

- The primary acceptance test enters through the public start API, drives repair and linked-result commands through public APIs, observes durable query projections and Socket.IO hints, and validates final immutable outputs. Internal workflow method calls are not the acceptance seam.
- The fixture includes one transcript, one image, one PDF, and one corrupt captured artifact; valid permissions and lineage; a repair candidate; one configured degradable operation failure; and a linked preflight snapshot requiring admission.
- The acceptance test proves branch parallelism from externally visible branch states without asserting task scheduling internals.
- The repair scenario proves that candidate generation does not change selection, unaffected branches continue, the wait survives worker restart, duplicate decision delivery is idempotent, accepted replacement makes only descendants stale, and affected work resumes.
- The degradable-failure scenario proves required work completes, the failure and stopping evidence remain visible, the package is valid, and the run outcome is `partially_completed`.
- The linked-run scenario proves idempotent child request identity, independent child configuration, explicit parent-side admission, every row of the timeout/failure/result-admission consequence table, rejected-result non-effect, and admitted snapshot influence on current package/readiness.
- Output tests assert package, readiness, and Decision Report immutability, distinct identities, exact version bindings, deterministic digests, and prohibition on post-terminal linked-result mutation.
- Realtime tests disconnect after a known cursor, allow several durable changes, reconnect, resume, detect no gaps, and reconcile against the current query projection. A separate test covers an expired cursor.
- Command tests cover duplicate idempotency keys, conflicting payload reuse, stale expected versions, unauthorized actors, and concurrent repair/cancel races.
- Orchestration tests use Temporal's test environment to verify timers, retries, local waits, cancellation, child completion, Continue-As-New state transfer, and replay determinism through observable workflow/query outcomes.
- Fault-injection tests cover relay redelivery, worker restart during repair wait, activity completion followed by acknowledgement loss, Mongo persistence followed by lifecycle transaction failure, and Socket.IO outage.
- Security tests prove prompts, Starter Content, linked outputs, and socket payloads cannot enlarge capability, cross tenant boundaries, bypass permission checks, or mutate Neo4j.
- API contract tests validate error envelopes, accepted command results, query pagination, cursor behavior, event versions, and authorization filtering.
- Prior art is the current FastAPI test client, Temporal sandbox probe, and Agents SDK compatibility tests, elevated into a complete domain tracer bullet.

## Out of Scope

- GoalDirected coordination, Goal Revisions, convergence verification, and per-iteration snapshots.
- Raw artifact capture, arbitrary folder intake, live URL acquisition, or capture pipelines.
- Deep research, systematic Source Discovery, broad Research Seed Extraction, corpus construction, or graph mutation.
- Production dashboard implementation.
- Permanent selection of Kafka or NATS; the event envelope and relay remain transport-neutral.
- Full catalog ingestion and public-registry promotion flows beyond exact pre-provisioned bindings needed by the slice.
- Every modality or finding type; the slice proves extensible contracts with transcript, image, PDF, and corrupt content.
- Guest Business Affiliation Summary behavior, except for reserving its operation slot.

## Further Notes

- Dependency order follows the cross-suite DAG: refinement deterministic core and shared foundations first, then executable StageGraph Knowledge Preflight, then this StageGraph refinement slice. This specification is required by the GoalDirected refinement and guest-affiliation specifications.
- The seam is intentionally scenario-rich because a text-only happy path would not prove repair authority, degradable failure, linked-result admission, immutable terminal outputs, or durable reconnect.
- The implementation target currently has no refinement domain implementation. Shared migrations, lifecycle/outbox authority, compiler, runtime, workspace, and realtime services come from prerequisite foundation specs; this slice adds only refinement-owned persistence and projections.
