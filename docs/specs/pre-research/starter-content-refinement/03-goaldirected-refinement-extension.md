# GoalDirected Refinement Extension

## Problem Statement

Some Starter Content is too heterogeneous, ambiguous, or poorly structured for a useful complete branch plan at launch. Repeatedly rebuilding a fixed StageGraph would hide semantic replanning inside retries and encourage an agent coordinator to expand scope, weaken obligations, or self-declare completion.

The system needs a bounded iterative refinement variant that can choose useful next work dynamically while retaining the same admission, permissions, invariants, package, readiness, and report contracts. Completion must be decided by an independent verifier, goal evolution must be immutable and authority-bounded, no-progress must converge to a governed stop, and expensive iteration state must be reproducible through clone-on-restore snapshots.

## Solution

Extend the refinement Workflow Type with the `GoalDirectedRefinement` blueprint. Launch compiles an immutable bounded goal from the Refinement Directive, Run Input Manifest, Refinement Obligation Matrix, output contracts, authority ceiling, operation envelope, and multidimensional budget.

Each iteration receives an exact Goal Revision and handoff state, performs validated bounded operations, promotes candidates, and submits a completion or continuation proposal. A separately bound verifier evaluates obligation satisfaction, unresolved cells, stale descendants, progress, repair needs, linked work, degradation, and stopping conditions. Accepted Goal Revisions may refine tactics, subgoals, order, or coverage emphasis only inside the launch envelope. Iteration, no-progress, repeated-blocker, budget, and snapshot policies guarantee convergence without converting agent persistence into unbounded work.

## User Stories

1. As an operator, I want to choose GoalDirected refinement only from an allowed published blueprint revision, so that runtime controls cannot invent a new topology.
2. As an operator, I want GoalDirected refinement to accept the same immutable input and permission contracts as StageGraph refinement, so that blueprint choice does not change domain truth.
3. As a workflow owner, I want launch to create an exact initial goal from the directive, manifest, obligations, outputs, authority, and budget, so that the coordinator has a fixed objective envelope.
4. As an operator, I want the initial goal to identify required completion evidence and prohibited work, so that success and boundaries are inspectable before execution.
5. As a coordinator, I want each iteration to inspect unaddressed subjects and obligation cells, so that effort follows current gaps.
6. As a coordinator, I want to select from allowed integrity, clarification, transformation, repair-proposal, extraction, and linked-work operation classes, so that useful next actions can adapt.
7. As a coordinator, I want to author bounded Dynamic Agent Definitions, handoffs, or task subagents within an operation, so that specialist work need not be pre-enumerated.
8. As a security reviewer, I want every dynamic agent validated against the Delegation Ceiling, permissions, workspace ownership, capability policy, and budget, so that dynamic authorship cannot escalate authority.
9. As an operator, I want each iteration to preserve its exact goal, inputs, handoff state, operation bindings, promoted candidates, findings, costs, and outcome, so that work is reproducible.
10. As an operator, I want an agent completion claim treated as a proposal, so that the actor doing the work cannot self-verify success.
11. As a verifier, I want to assess newly satisfied obligations, unresolved or failed cells, stale descendants, and progress since the prior iteration, so that continuation is evidence-based.
12. As a verifier, I want to distinguish valid completion, another iteration, repair, degradation, linked work, human review, fork, and stop, so that different outcomes remain explicit.
13. As a verifier, I want deterministic structural checks combined with independently bound semantic evaluation, so that neither schema validity nor model judgment is sufficient alone.
14. As an operator, I want verifier independence recorded through a distinct Operation Execution Binding and context policy, so that evaluation does not merely repeat the coordinator's claim.
15. As a coordinator, I want to propose a Goal Revision that refines tactics, subgoals, ordering, or coverage emphasis, so that learning from one iteration can guide the next.
16. As an operator, I want each accepted Goal Revision to preserve its parent, evidence, unmet obligations, author, deciding authority, and applicability, so that goal history is immutable.
17. As a workflow owner, I want revisions that broaden the objective, add inputs, weaken acceptance, add undeclared work, or exceed authority rejected, so that goal text cannot grant scope.
18. As an operator, I want material expansion routed to an allowed Run Control Revision, linked run, fork, or new run, so that scope changes receive proper authority.
19. As an operator, I want iteration count, operation attempts, Temporal Activity attempts, and goal revisions counted separately, so that retry and semantic progress are not conflated.
20. As an operator, I want a multidimensional iteration budget covering spend, tokens, elapsed time, tools, pages, external services, cycles, and concurrency, so that bounded execution is enforceable.
21. As an operator, I want soft limits to produce a Continuation Proposal, so that additional work, reduced effort, skipped degradable work, or termination receives an explicit decision.
22. As an operator, I want hard caps to prevent further affected work automatically, so that an agent cannot continue because it believes another step is useful.
23. As a verifier, I want progress measured across obligation coverage, uncertainty reduction, new nonduplicate evidence, resolved blockers, and usable promoted outputs, so that verbosity or tool count is not mistaken for progress.
24. As a verifier, I want repeated equivalent outputs and unchanged blocker sets detected, so that loops terminate.
25. As an operator, I want configurable consecutive no-progress and repeated-blocker limits, so that convergence policy is visible and testable.
26. As an operator, I want a no-progress stop to preserve unresolved required and degradable cells and their consequences, so that stopping does not imply success.
27. As an operator, I want required unsatisfied obligations after bounded stopping to yield failure, so that budget exhaustion cannot manufacture completion.
28. As an operator, I want degradable unresolved work after required completion to yield partial completion, so that useful bounded results survive.
29. As an operator, I want repair proposals and Repair Decisions to use the same authority and staleness rules as StageGraph refinement, so that iterative execution cannot bypass the shared core.
30. As a parent workflow, I want linked Workflow Runs requested only through declared slots and explicit dependency classes, so that task subagents cannot become hidden durable workflows.
31. As a parent workflow, I want every linked output admitted explicitly before influencing the next goal or package, so that child completion is not automatic authority.
32. As an operator, I want workspace snapshots after configured expensive or long iterations, so that debugging, resume, or fork can reuse exact execution state.
33. As a security reviewer, I want snapshot restore to create a new workspace clone and revalidate secrets, credentials, capabilities, connections, and leases, so that saved state cannot restore authority.
34. As an auditor, I want snapshots distinguished from domain artifacts and promoted outputs, so that filesystem state is not mistaken for a package.
35. As an operator, I want rollback to a prior snapshot to create a new iteration lineage rather than erase later attempts, so that history remains complete.
36. As an operator, I want cancellation, pause, resume, and Continue-As-New to preserve active goal, iteration, waits, budgets, and snapshot references, so that durable control is reliable.
37. As a downstream workflow, I want final package, readiness, and Decision Report contracts identical to StageGraph outputs, so that consumers do not depend on blueprint family.
38. As an auditor, I want the Decision Report to explain goal evolution, verifier decisions, convergence, no-progress, snapshots, linked work, failures, and alternatives, so that dynamic execution remains understandable.
39. As an evaluator, I want benchmark scenarios for productive adaptation, premature completion, scope expansion, oscillation, repeated blockers, and budget exhaustion, so that GoalDirected behavior is measurable.
40. As a developer, I want GoalDirected orchestration built on the existing command, persistence, event, query, realtime, adapter, and Temporal foundations, so that the extension does not create a second control plane.

## Implementation Decisions

- This extension depends on specifications 1 and 2. It reuses all domain contracts, application authority, persistence ownership, API command protocol, event envelope, durable cursor, runtime adapters, workspace adapter, and output assembly.
- The blueprint introduces GoalDirected-specific records for bounded initial goal, immutable Goal Revision, goal iteration, handoff state, verifier result, progress assessment, continuation proposal, convergence state, and iteration snapshot binding.
- The initial goal is compiled deterministically from the exact Refinement Directive, Run Input Manifest, baseline Refinement Obligation Matrix, fixed package/readiness/report contracts, allowed operation classes, linked-run slots, permissions, Delegation Ceiling, and Budget Envelope.
- The objective envelope is immutable for the run. Accepted Goal Revisions may alter tactics, subgoals, ordering, coverage emphasis, and next-iteration targets only within that envelope.
- A Goal Revision proposal records parent revision, proposed changes, evidence, unmet obligations, expected benefit, budget effect, invalidation effect, author, and required deciding authority.
- Deterministic validation rejects revisions that add unadmitted inputs, broaden purpose, weaken required obligations or output validation, introduce undeclared operations or linked slots, increase authority, bypass permissions, or exceed hard budgets.
- Revisions requiring a permitted control change are not active until the authoritative Run Control Revision is accepted. Structural or input changes require a fork or new run.
- Each iteration has a stable semantic identity distinct from Temporal Activity attempts and operation attempts. It binds one active Goal Revision, exact handoff state, allowed capability set, workspace, budget reservation, and verifier policy.
- The coordinator may choose only operations that survive application validation. Dynamic Agent Definitions remain operation-local and may use handoff or task-subagent delegation, but reusable independent work crosses a Workflow Type boundary.
- Iteration candidates become domain-visible only through normal artifact promotion and proposal validation. Local workspace content has no authority.
- The verifier is a separate role with an independent Operation Execution Binding, no authority to rewrite coordinator output, and no ability to relax invariants. It receives the minimum evidence needed to evaluate the iteration plus access to exact prior assessments.
- Deterministic verification always checks manifest integrity, obligation status, permission compliance, current-versus-stale dependencies, budget facts, package constraints, and required evidence references.
- Semantic verification evaluates progress, ambiguity preservation, coverage adequacy, repair need, candidate quality, and whether the coordinator's completion claim is supported. Its structured proposal is application-validated.
- Verifier outcomes are `complete`, `continue`, `repair`, `degrade`, `request_linked_work`, `require_review`, `stop_failed`, `stop_cancelled`, `propose_fork`, and `propose_control_revision`. Outcome applicability is constrained by obligation status and authority.
- Completion requires all required obligation cells to have accepted completion evidence, no unresolved invariant violation, structurally valid current outputs, and no required pending decision.
- Progress is multidimensional: newly completed obligation cells, increased assessed coverage, resolved or narrowed ambiguity, new nonduplicate supported findings or seeds, resolved blockers, accepted repair effects, and useful admitted linked results. Tool calls, token use, prose volume, and raw candidate count are not progress.
- The default convergence policy supports maximum iterations, maximum consecutive no-progress iterations, maximum repeated equivalent blocker assessments, per-operation attempt limits, soft budget thresholds, and hard caps. Exact values are configuration revisions, never prompt-only instructions.
- Progress equivalence uses deterministic normalized obligation and blocker state plus evaluator-declared semantic equivalence evidence. A model alone cannot reset no-progress counters by rewording output.
- At a soft threshold, execution creates a Continuation Proposal for unchanged continuation, added reservation, policy-allowed reallocation, reduced effort, skipped degradable work, or termination. At a hard cap, affected work stops pending the configured domain consequence.
- Required unresolved cells at bounded stop yield `failed`. Required completion with unresolved or failed degradable cells yields `partially_completed`. Authorized cancellation yields `cancelled` regardless of valid partial outputs.
- Snapshot policy can require snapshots before a high-risk repair activation, after expensive iterations, on blocked or failed high-cost work, or at configured intervals. Snapshot creation is a nondeterministic activity.
- A Sandbox Snapshot records immutable filesystem/content digest, runtime/image/package digests, provider identity, parent workspace and snapshot, creation reason, capability shape without secret values, producer binding, and retention policy.
- Restore always creates a new Sandbox Workspace with explicit parent lineage. Credentials, MCP sessions, sockets, leases, and secrets are resolved and validated anew.
- Rollback is represented as a new iteration from an admitted snapshot and handoff state. It does not delete or rewrite intervening Goal Revisions, iterations, promoted outputs, or evaluations.
- The top-level Temporal Workflow orchestrates iterations and verifier decisions. Agent execution, databases, object storage, snapshots, MCP, tools, and evaluation run in activities.
- Continue-As-New carries compact references for active Goal Revision, next iteration, convergence counters, pending waits, accepted decisions, budget state, snapshot lineage, current obligation digest, and durable event position.
- GoalDirected API/query extensions expose current goal, complete revision chain, iteration summaries, operation and verifier bindings, progress dimensions, convergence counters, snapshots, continuation proposals, and handoff state under authorization.
- Realtime events expose durable iteration starts/completions, accepted Goal Revisions, verifier outcomes, continuation decisions, snapshot availability, and convergence state. Fine-grained model tokens remain ephemeral.
- Final package assembly, readiness, Decision Report validation, and terminal lifecycle authority remain the deterministic shared services from specifications 1 and 2.
- Dependency: specification 4 may execute inside a GoalDirected iteration but cannot alter convergence, objective-envelope, or verifier rules.

## Testing Decisions

- Tests assert GoalDirected behavior through the public start/command/query/realtime seams and Temporal observable state, not coordinator prompt wording or private scheduler methods.
- A productive-adaptation fixture requires the second iteration to choose a different allowed operation after the first reveals an unsupported region; the verifier must record real new coverage before continuation.
- A premature-completion fixture has the coordinator claim success with an unsatisfied required cell; deterministic and independent verification must reject completion.
- A scope-expansion fixture proposes an unadmitted source and a new operation class; the Goal Revision must be rejected and the active goal remain unchanged.
- An allowed-revision fixture changes tactics and coverage order within the objective envelope, preserves the parent revision, and becomes active only after the proper decision.
- An oscillation fixture alternates semantically equivalent plans and outputs; normalized progress detection must reach the no-progress limit despite wording changes.
- A repeated-blocker fixture proves the configured blocker limit produces the correct continuation, review, degradation, or failure decision.
- Budget tests cover independent hard dimensions, soft-threshold Continuation Proposals, authorized added reservation, forbidden cross-dimension borrowing, reduced-effort continuation, and hard-cap stop.
- Verifier-independence tests prove separate bindings and ensure coordinator-supplied instructions cannot change verifier authority, acceptance contract, or evidence requirements.
- Delegation tests prove dynamic agents stay within operation scope, inherit only explicit mounts and capabilities, and cannot hide a linked Workflow Type as a task subagent.
- Linked-work tests prove declared slots, idempotent request identity, independent child configuration, explicit result admission, and no effect from rejected or late results.
- Snapshot tests prove immutable metadata, clone-on-restore, credential and capability revalidation, parent lineage, rollback as a new iteration, and no automatic promotion of workspace files.
- Worker-restart and Continue-As-New tests prove active goal, iteration counter, convergence counters, waits, budgets, and snapshot references survive.
- Outcome tests cover successful completion, partial completion after degradable stop, failure after required no-progress, and cancellation with valid partial artifacts.
- Output compatibility tests run equivalent StageGraph and GoalDirected fixtures and assert the same external package, readiness, report, findings, seeds, repair, and lineage contract shapes.
- Evaluation benchmarks score obligation-completion correctness, no-progress detection, invalid scope-revision rejection, verifier false acceptance, useful adaptation, snapshot lineage, and bounded cost.
- Prior art is the StageGraph public API/Temporal acceptance harness from specification 2, extended with iteration and verifier drivers rather than a new test seam.

## Out of Scope

- A generic autonomous research loop or deep-research workflow.
- Agent-authored workflow topology, new stages, undeclared linked-run slots, or mutable acceptance criteria.
- Raw artifact capture, systematic Source Discovery, canonical identity resolution, scientific adjudication, or Neo4j mutation.
- In-place snapshot resume, restoration of live credentials or connections, or treating snapshots as domain artifacts.
- Self-verification by the coordinator.
- Model-specific prompt tuning, fine-tuning, or universal convergence thresholds.
- Guest Business Affiliation Summary details, which are specified separately.

## Further Notes

- Dependency order: specifications 1 and 2 must be implemented first. This extension should reuse their services instead of introducing alternate stores, APIs, event streams, or lifecycle authority.
- GoalDirected is selected because the next useful action is not fully knowable at launch, not because it permits broader scope or weaker contracts.
- The decisive safety property is that dynamic tactics remain inside an immutable objective and authority envelope while completion remains independently verified.
