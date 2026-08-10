## Problem Statement

Accepted Workflow Runs need durable execution semantics that are expressive enough for application-owned dependency graphs, quality-directed cycles, iterative goal work, and composed linked runs without becoming a generic agent-authored workflow engine. Temporal can provide durable timers, waits, retries, cancellation, child execution, and replay, but it must not invent BellLabs topology, completion, dependency, authority, or result-admission semantics.

The service must distinguish infrastructure retries from new semantic attempts, stage cycles, workflow cycles, and goal iterations. It must also preserve the standalone contract of every linked Workflow Run. A parent cannot inline a child Workflow Type, precompile the child from the parent snapshot, automatically propagate credentials, infer waiting from child status, or treat child completion as automatic admission into the parent.

## Solution

Implement a deterministic blueprint orchestrator with exactly two top-level families: StageGraph and GoalDirected. Each accepted Workflow Run binds one immutable blueprint revision and one Effective Run Configuration. Temporal workflow code interprets that frozen application-owned blueprint, tracks compact deterministic execution state, schedules idempotent activities or child workflows, waits for accepted domain decisions, and uses Continue-As-New only as a history-management boundary.

StageGraph orchestration computes runnable work from an acyclic dependency graph, explicit dependency classes, branch/join policy, concurrency and fairness rules, typed completion, and optional bounded semantic cycle policies. Whole-workflow evaluation may invalidate and rerun only the minimal affected subgraph while preserving unaffected immutable outputs by reference.

GoalDirected orchestration advances a fixed objective envelope through bounded, independently verified iterations. Goal evolution creates immutable Goal Revisions inside the launch-bound objective, acceptance, authority, admitted inputs, budget, and prohibited-work envelope. An agent’s completion or goal-change claim is only a proposal.

Crossing a Workflow Type boundary always creates a typed linked Run Request, a distinct transactionally admitted Workflow Run, and a durable Run Composition Link. The child independently compiles its own Effective Run Configuration under the intersection of its contract and frozen parent constraints. Parent waiting, cancellation, degradation, and exact result admission follow the declared Run Dependency Class and immutable decisions.

## User Stories

1. As a workflow author, I want a run to bind exactly one StageGraph or GoalDirected blueprint revision, so that execution topology cannot change implicitly.
2. As a Temporal worker, I want deterministic orchestration inputs, so that replay never queries mutable databases or external services.
3. As an operator, I want Temporal workflow code separated from activities, so that all nondeterministic I/O occurs behind idempotent adapters.
4. As a StageGraph author, I want dependency edges validated as acyclic, so that semantic cycles cannot be hidden as graph back-edges.
5. As a StageGraph author, I want required, degradable, optional, and advisory stage dependencies, so that completion behavior is declared rather than inferred.
6. As a StageGraph author, I want explicit branch and join semantics, so that parallel work has deterministic readiness and completion behavior.
7. As an operator, I want readiness ordering and fairness rules compiled, so that runnable work selection is reproducible.
8. As a budget owner, I want stage and operation concurrency constrained by all applicable ceilings, so that orchestration cannot oversubscribe resources or reservations.
9. As a stage owner, I want timeout and retry policy distinct from semantic cycle policy, so that operational recovery does not masquerade as new work.
10. As an auditor, I want `temporal_activity_attempt`, `operation_attempt`, `stage_cycle`, `workflow_cycle`, `goal_iteration`, and `goal_revision` recorded separately, so that execution history is interpretable.
11. As an activity implementer, I want a retry of the same side effect to reuse semantic identity and idempotency keys, so that Temporal redelivery is safe.
12. As an evaluator, I want a failed stage gate to create a new stage cycle only when the blueprint permits it, so that repeated semantic work is bounded.
13. As a stage-cycle participant, I want each cycle to receive a typed objective, budget reservation, workspace namespace, bindings, artifacts, handoff, and evaluation, so that cycles are independently auditable.
14. As an evaluator, I want to recommend stop, repair, continue, degrade, fork, or escalate through a typed decision, so that free-text output does not control orchestration.
15. As a workflow evaluator, I want failed obligations, evidence, affected stages, invalidation frontier, next objective, control needs, and required budget recorded, so that whole-workflow reruns are justified.
16. As an operator, I want unaffected immutable outputs reused by reference during a workflow cycle, so that valid work is not repeated.
17. As an auditor, I want workflow cycles distinct from Continue-As-New epochs, so that business semantics are not conflated with history compaction.
18. As a GoalDirected author, I want a fixed objective envelope and acceptance contract, so that iterative agents cannot expand the run’s purpose.
19. As a GoalDirected author, I want an independent verifier, so that an executing agent’s completion claim is never sufficient.
20. As a GoalDirected author, I want continuing-session and fresh-from-handoff policies, so that context persistence is deliberate.
21. As an operator, I want iteration, no-progress, repeated-blocker, budget, and snapshot limits, so that goal work cannot loop indefinitely.
22. As an agent, I want to propose a Goal Revision that refines tactics, subgoals, ordering, or coverage emphasis, so that the next iteration can adapt.
23. As a security operator, I want Goal Revisions constrained by objective, acceptance, invariants, admitted inputs, authority, budget, and prohibited work, so that goal text cannot grant expansion.
24. As an operator, I want broader goal changes to require an allowed Run Control Revision, fork, linked run, or new run, so that scope expansion remains governed.
25. As a parent Workflow Run, I want to request substantial work through a declared linked-run slot, so that first-class workflow boundaries remain visible.
26. As a parent Workflow Run, I want one parent-scoped Linked Run Request Identity, so that retries and replay do not create duplicate child runs.
27. As a parent Workflow Run, I want a conflicting payload under an existing linked identity rejected, so that material changes require a new revision or identity.
28. As a child Workflow Type owner, I want the child to pass its own Input Admission Contract, so that parent acceptance cannot bypass the child contract.
29. As a child operator, I want the child to compile its own Effective Run Configuration, so that parent configuration does not overwrite standalone semantics.
30. As a security operator, I want child authority to be the intersection of child contract, parent ceiling, caller authority, data policy, Permission Assessments, approved overlays, and environment policy, so that no governing ceiling is bypassed.
31. As a budget owner, I want a distinct Linked Run Budget Reservation, so that child consumption is tracked and rolled up without shared unaccounted spend.
32. As a parent Workflow Type author, I want every link assigned `required_blocking`, `degradable_blocking`, `degradable_nonblocking`, or `detached_advisory`, so that wait and completion behavior is explicit.
33. As a parent run, I want required blocking work to prevent affected completion until an acceptable child result is admitted, so that required obligations cannot be bypassed.
34. As a parent run, I want degradable blocking work to resolve through explicit timeout/failure degradation behavior, so that child failure is not implicit success.
35. As a parent run, I want nonblocking or detached work to continue under declared policy, so that the parent may complete without retroactive mutation.
36. As an operator, I want changing a dependency class to require an immutable authorized Run Dependency Revision, so that link semantics are never edited in place.
37. As an operator, I want cancellation propagation determined by parent policy and dependency class, so that cancellation is neither universal nor improvised.
38. As a child run, I want parent cancellation to arrive as a governed request, so that the child lifecycle reducer remains authoritative.
39. As a parent run, I want child failure, cancellation, or timeout resolved through dependency semantics rather than automatic reverse-cancellation, so that the parent contract remains intact.
40. As a parent output owner, I want every exact child output to receive a Linked Run Result Admission Decision, so that child completion never silently mutates parent state.
41. As a reviewer, I want result admission to evaluate exact versions, intended obligation, compatibility, readiness, provenance, permissions, and evaluation evidence, so that reuse is purpose-bound.
42. As an operator, I want late linked results preserved without changing a terminal parent, so that terminality and lineage remain immutable.
43. As a downstream producer, I want late results incorporated only through a new run with explicit input admission, so that successor output lineage is clear.
44. As an operator, I want linked runs represented through application records even if Temporal uses a Child Workflow, so that Temporal hierarchy does not become the domain model.
45. As an operator, I want Continue-As-New to preserve logical run identity, counters, pending waits, accepted revisions, links, and budget state, so that history compaction does not lose semantics.

## Implementation Decisions

- Implement one application-owned blueprint interpretation layer with two discriminated top-level families: `StageGraph` and `GoalDirected`. Do not create a general-purpose runtime-authored workflow DSL.
- Temporal workflow code receives stable run identity, immutable Run Input Manifest reference, Effective Run Configuration reference and digest, selected blueprint binding, and compact accepted state. It verifies bindings before substantive work.
- Temporal workflow code performs only deterministic readiness calculation, state transitions derived from already accepted domain decisions, timers, waits, child/activity scheduling, cancellation coordination, queries, and Continue-As-New.
- Database, object-store, Neo4j, secret, sandbox, model, MCP, artifact, evaluation, and lifecycle writes occur in activities through project-owned services. Temporal workflow code never queries those systems directly.
- StageGraph dependency edges are acyclic. Stages carry explicit dependency and join semantics, completion/skip behavior, fairness, concurrency, timeout, retry, operation boundaries, linked-run slots, and optional stage/whole-workflow semantic-cycle policies.
- A stage cycle is new semantic work after evaluation, not an activity retry. It receives a new cycle objective, operation attempt and binding identities, budget reservation, workspace namespace, candidate artifacts, evaluation, and handoff state.
- A whole-workflow cycle starts only from an accepted typed evaluator decision. The orchestrator computes the minimal affected descendant subgraph from the invalidation frontier and references unaffected immutable outputs. It does not overwrite prior cycle results.
- `temporal_activity_attempt`, `operation_attempt`, `stage_cycle`, `workflow_cycle`, `goal_iteration`, `goal_revision`, and Temporal execution epoch remain distinct counters and identities.
- An activity retry normally reuses the operation binding and deterministic side-effect idempotency key. A changed semantic objective, inputs, accepted configuration, or repair creates a new operation attempt and binding.
- GoalDirected blueprints declare the initial goal, fixed objective envelope, acceptance contract, independent verifier, allowed operation classes and linked-run slots, handoff/session policy, iteration and convergence limits, budget, snapshot policy, and goal-evolution policy.
- GoalDirected stop evaluation gives precedence to invariant or authority breach, hard budget exhaustion, independently verified completion, irrecoverable failure, no-progress/repeated-blocker limits, iteration limit, and then authorized soft-budget continuation. Exact workflow-specific reactions remain declared by the blueprint.
- Every Goal Revision is immutable and records parent revision, evidence, unmet obligations, author, deciding authority, and applicability. It may refine execution only inside the launch-bound envelope. Broader changes cannot be accepted as a Goal Revision.
- A Temporal Child Workflow is appropriate for a linked Workflow Run or another unit with independent waits, cancellation, cycles, history, or Continue-As-New needs. Bounded model, tool, agent, or delegation execution remains an activity even when internally multi-turn.
- Crossing a Workflow Type boundary always submits a linked Run Request to the specification 2 admission service and creates a distinct Workflow Run and Run Composition Link. Temporal child execution is an implementation mapping after domain admission, not the act of admission.
- Linked Run Request Identity is parent-scoped and combines parent run, declared request slot or obligation intent, immutable request revision, target Workflow Type/revision policy, and a fingerprint of proposed inputs, controls, dependency class, budget reservation, and authority request.
- Exact redelivery returns the existing request or child. A conflicting fingerprint under the same identity is rejected. Similar content in another parent, slot, mission, or standalone request is not deduplicated.
- The parent Effective Run Configuration freezes the allowed slot and constraints but does not include a full child configuration. Each accepted child independently invokes specification 1 compilation using exact child definitions plus the frozen parent constraints.
- Run Composition Links, parent-side dependency decisions, dependency revisions, result-admission decisions, cancellation policy application, and linked budget reservations are PostgreSQL authority. Child workflow-shaped outputs remain in MongoDB or object storage according to their record family.
- Every link has exactly one parent-defined Run Dependency Class: `required_blocking`, `degradable_blocking`, `degradable_nonblocking`, or `detached_advisory`. The class does not alter child admission, lifecycle, outcome, evaluation, or output contracts.
- A dependency-class change requires an immutable Run Dependency Revision authorized by the parent contract. It must assess invalidation or reevaluation of affected obligations, artifacts, outputs, readiness, and evaluation; it cannot merely bypass a blocked required obligation.
- Parent cancellation requests cancellation of blocking children by default. Nonblocking and detached children follow their declared continuation policy. Child termination never automatically reverse-cancels the parent.
- Every exact child output requires an immutable parent-side Linked Run Result Admission Decision with outcome `admit`, `conditionally_admit`, `reject`, or `defer`. Only admitted outputs may satisfy parent obligations or be materialized for parent work.
- A late result cannot alter a terminal parent or create a new parent output version. Reuse requires a new applicable Workflow Run whose Run Input Manifest admits exact prior parent and child outputs.
- Continue-As-New is triggered by deterministic history-management policy and carries all compact domain-relevant execution state. It does not create a new Workflow Run, reset budgets, or imply a semantic cycle.
- Orchestration reports commands and observed facts to the specification 2 reducer and waits for accepted results where authority is required. It never writes lifecycle projections or budget ledgers directly.
- Object storage owns large artifacts and handoff payloads. MongoDB owns detailed blueprint execution documents and workflow-specific outputs. PostgreSQL owns lifecycle, links, dependency decisions, and budgets. Neo4j is only accessed by governed activities under an admitted workflow contract.
- Dependency note: this specification depends on specifications 1 and 2. Specification 4 supplies the operation, delegation, workspace, snapshot, and promotion activities scheduled by these orchestrators.

## Testing Decisions

- Test orchestration primarily through Temporal’s time-skipping test environment with the real blueprint interpreter and public activity contracts, while using fake external adapters only at the nondeterministic boundary. Observe run commands, emitted records, activity requests, and final public projections rather than internal workflow fields.
- Provide one published StageGraph fixture and one GoalDirected fixture compiled through specification 1 and admitted through specification 2. The fixtures prove common mechanics without asserting unsettled workflow-specific product stages.
- Prove a valid StageGraph schedules only runnable stages, honors declared joins and concurrency, and produces deterministic scheduling decisions under replay.
- Prove cycles or missing dependencies are rejected before execution and cannot be introduced by a Run Control Revision.
- Prove a local wait does not block unrelated runnable stages and aggregate phase follows the specification 2 derivation rules.
- Prove activity retry reuses semantic operation identity and does not duplicate operation attempts, budget charges, promoted artifacts, or lifecycle facts.
- Prove an accepted stage evaluation creates a new stage cycle with a new objective, reservation, workspace namespace, binding, and artifact lineage.
- Prove a whole-workflow evaluator decision reruns only the affected subgraph and preserves unaffected outputs by immutable reference.
- Prove Continue-As-New can occur independently of a semantic cycle and preserves logical run identity, all semantic counters, pending waits, links, accepted revisions, and budget balances.
- Prove GoalDirected completion claims do not terminate the run until the independent verifier accepts the completion contract.
- Prove no-progress, repeated-blocker, iteration, and hard-budget limits trigger the exact authored decision path.
- Prove a valid Goal Revision changes only allowed tactical fields and that objective, acceptance, input, authority, budget, or prohibited-work expansion is rejected or routed to the declared control/fork/linked-run path.
- Redeliver the same linked request from Temporal retry, coordinator retry, and event replay and prove only one child request, run, budget reservation, and link exist.
- Reuse a linked request identity with a changed fingerprint and prove it is rejected.
- Prove child admission runs independently and a parent cannot bypass a child Input Admission Contract or supply authority above the governing intersection.
- Prove two children from the same slot can compile different exact configurations only when the slot revision policy permits distinct request revisions.
- Exercise all four dependency classes and prove their wait, timeout, parent-completion, and degradation behavior from public state.
- Prove dependency revision preserves prior decisions, requires authority, and triggers declared invalidation/reevaluation rather than silently changing completion.
- Prove parent cancellation requests blocking-child cancellation and follows declared continuation for nonblocking/detached children; prove child failure never automatically reverse-cancels the parent.
- Prove child completion alone does not satisfy a parent obligation or copy artifacts. Only an accepted exact Linked Run Result Admission Decision changes parent admissibility.
- Deliver a result after parent terminality and prove the parent projection and outputs are unchanged while the link and child output remain queryable.
- Simulate workflow replay and worker restart and prove no database query occurs in workflow code and all side effects remain idempotent.
- Avoid assertions about Temporal event-history shape, private interpreter methods, activity scheduling implementation, or child-workflow identifiers unless they are part of the public correlation contract.

## Out of Scope

- Definition publication and Effective Run Configuration compilation internals, which are owned by specification 1.
- PostgreSQL admission transaction, generic lifecycle reducer internals, outbox relay, and base budget ledger mechanics, which are owned by specification 2.
- Concrete OpenAI Agents SDK mapping, handoff and task-subagent execution, Operation Execution Bindings, workspace providers, snapshot clone/restore, and artifact promotion, which are owned by specification 4.
- Workflow-specific topology, obligation matrices, gates, evaluators, stopping thresholds, timeouts, and numeric budgets.
- Mission Plan compilation and Knowledge Production Mission scheduling above linked Workflow Runs.
- Durable event-broker selection, Temporal deployment topology, task-queue tuning, worker slot tuning, and autoscaling.
- Dashboard and realtime UI behavior.
- Neo4j mutation, ingestion transaction semantics, or workflow-specific graph query behavior.

## Further Notes

- Dependency order is strict: a run must be transactionally admitted with a frozen configuration before Temporal performs substantive orchestration. A linked child must pass the same sequence independently.
- Authority, admission, dependency, cancellation, result-admission, and completion semantics are settled and cannot be delegated to prompts, agent judgment, Temporal defaults, or implementation convenience.
- Deferred tuning choices include Continue-As-New thresholds, fairness algorithms among equally runnable stages, default retry intervals, exact Temporal child/activity granularity for workflow-specific units, and workflow-specific convergence thresholds.
- StageGraph and GoalDirected are the only first-architecture top-level families. Adding another family requires a new accepted architecture decision and versioned compiler/orchestrator support; it is not a namespaced runtime extension.
- PostgreSQL remains authoritative for links, lifecycle, dependency decisions, and budgets; MongoDB remains authoritative for immutable blueprint/configuration and detailed workflow documents; Temporal owns durable execution mechanics; object storage owns large immutable payloads; Neo4j owns approved canonical knowledge.
