## Problem Statement

The StageGraph vertical slice can execute a predetermined bounded search, but exploratory contradiction and gap pursuit often depends on observations that cannot be known at launch. A useful next query may emerge only after an alias reveals another entity, a prior run exposes an unassessed scope, or a contradiction requires a different modality. Treating this work as an unrestricted agent loop would let prompts redefine scope, weaken coverage, exceed authority, self-approve completion, rerun unaffected work, or accumulate unreplayable Temporal history.

GoalDirectedPreflight needs adaptive behavior without changing Knowledge Preflight's fixed purpose, admission, coverage, observation, no-write, schema-compatibility, snapshot, and reporting contracts. It must make goal evolution explicit and bounded, require verification independent of the proposing coordinator, distinguish semantic iteration from retries and history rollover, persist reproducible sandbox state, and invalidate only the affected reasoning/retrieval subgraph.

## Solution

Add an allowed `GoalDirectedPreflight` blueprint variant that reuses the domain core, API, adapters, persistence, and output contracts from the first two specifications. A launch-bound objective envelope produces an initial immutable goal. Each bounded iteration selects high-value unsatisfied coverage cells, executes authorized queries or interpretations, updates an immutable evidence dependency graph, proposes candidate findings and optional Goal Revisions, and submits a completion or continuation proposal to an independent verifier.

The verifier evaluates coverage, novelty, unresolved scope, contradiction/gap characterization, stopping evidence, budgets, repeated blockers, and all Workflow Invariants. It may recommend completion, require bounded continuation inside its delegated scope, accept or reject a bounded Goal Revision under the configured decision policy, request minimal affected-subgraph work, propose degradation of declared obligations, or escalate for an authorized control decision. Completion and lifecycle recommendations become typed proposals to the application reducer; neither coordinator nor verifier assigns run outcome.

Each iteration creates a durable handoff and, when policy requires, an immutable Sandbox Snapshot. Restoring a snapshot clones a new workspace and revalidates credentials and capabilities. Temporal Continue-As-New rolls orchestration history into a successor epoch while preserving the same Workflow Run, active goal revision, counters, references, idempotency identities, and domain lineage.

Shared Schema Catalog and Schema Workspace Materialization remain an upstream companion dependency. Goal revisions may refine selection use within an admitted schema envelope but cannot regenerate or mutate shared schema authority.

## User Stories

1. As an operator, I want to select the GoalDirected blueprint at launch, so that exploratory work is explicit and immutable.
2. As an operator, I want the same Knowledge Preflight Brief and output contract as StageGraph, so that consumers do not need variant-specific semantics.
3. As a policy owner, I want the launch objective, acceptance contract, invariants, admitted inputs, authority, budget, and prohibited work frozen, so that iteration cannot expand the run silently.
4. As a coordinator, I want to choose the highest-value unsatisfied coverage cells each iteration, so that effort responds to observed evidence.
5. As a coordinator, I want to reformulate bounded schema-valid queries, so that failed tactics can be improved without changing obligations.
6. As a coordinator, I want to compare new observations with prior iterations, so that duplicate retrieval does not appear as progress.
7. As a coordinator, I want to propose Graph Match Candidates, contradiction candidates, and gaps, so that adaptive reasoning still produces the shared domain records.
8. As a coordinator, I want to propose a Goal Revision when evidence changes the best next target, so that goal evolution is explicit.
9. As an operator, I want every Goal Revision linked to its parent, evidence, unmet obligations, author, and deciding authority, so that evolution is auditable.
10. As a policy owner, I want goal revisions limited to tactics, subgoals, ordering, coverage emphasis, and next target, so that they cannot broaden purpose or access.
11. As a policy owner, I want revisions that alter admitted inputs, weaken acceptance, add data surfaces, or exceed authority rejected, so that goal text cannot grant capability.
12. As a verifier, I want to evaluate each completion proposal independently, so that the actor doing the work cannot approve itself.
13. As an operator, I want verifier configuration and execution bindings distinct from the coordinator's, so that independence is observable rather than rhetorical.
14. As a verifier, I want exact coverage, novelty, unresolved scope, contradiction/gap quality, stopping evidence, and budget state, so that decisions are evidence-backed.
15. As a verifier, I want to reject repeated or duplicate evidence as progress, so that loops cannot converge by volume.
16. As a verifier, I want to accept completion only when required obligations and stopping rules pass, so that agent confidence is insufficient.
17. As a verifier, I want to require a bounded next iteration when material progress remains possible, so that early completion claims can be corrected.
18. As a verifier, I want repeated blockers and no-progress limits enforced, so that the workflow terminates or escalates predictably.
19. As a budget owner, I want every iteration to reserve bounded resources before execution, so that the loop cannot exceed hard ceilings.
20. As a budget owner, I want additional work beyond a soft threshold proposed through a Continuation Proposal, so that agents cannot self-extend.
21. As a graph owner, I want deployment-hash compatibility rechecked before any newly material graph access after restore or accepted control changes, so that adaptive execution never bypasses the precondition.
22. As a graph owner, I want every adaptive query pass through the same read-only adapter validation, so that GoalDirected remains observational.
23. As a coverage reviewer, I want newly revealed in-scope cells added only through declared matrix-revision rules, so that discovery does not authorize unlimited expansion.
24. As a coverage reviewer, I want the exact invalidation frontier recorded when a new cell, candidate, or context changes prior conclusions, so that unaffected evidence is reused.
25. As an operator, I want only affected query, normalization, candidate, contradiction, gap, coverage, snapshot, and report nodes recomputed, so that iteration avoids full reruns.
26. As an auditor, I want superseded derived records retained with staleness and successor links, so that historical reasoning is not erased.
27. As an identity reviewer, I want a new alias observation to invalidate only dependent candidate conclusions, so that unrelated matches remain stable.
28. As an evidence reviewer, I want a newly discovered temporal context to invalidate a false contradiction without rerunning unrelated retrieval, so that correction is precise.
29. As a research planner, I want new evidence about one gap to update only its dependent coverage and gap assessment, so that other bounded non-discovery findings remain reproducible.
30. As an agent operator, I want each iteration to emit a compact handoff, so that a fresh session can continue without replaying uncontrolled conversation.
31. As an agent operator, I want expensive iterations snapshotted, so that failures and investigation paths can be reproduced.
32. As a security owner, I want snapshot restore to create a new workspace and re-resolve secrets, leases, graph credentials, and MCP connections, so that stale authority is not restored.
33. As an auditor, I want snapshot files distinguished from promoted domain records, so that workspace state does not become canonical evidence implicitly.
34. As a platform owner, I want Continue-As-New before Temporal history becomes unsafe, so that long runs remain durable.
35. As a platform owner, I want Continue-As-New to preserve one Workflow Run and all semantic counters, so that history rollover is not mistaken for a new run or iteration.
36. As an operator, I want run queries to span all Temporal epochs transparently, so that execution history rollover does not fragment the public result.
37. As an operator, I want pause, resume, cancel, and authorized controls to apply at iteration boundaries and safe points, so that adaptive work remains governable.
38. As a workflow consumer, I want the final snapshot to identify the active Goal Revision, every iteration, verifier decision, invalidation frontier, reused output, snapshot, and stopping rationale, so that adaptive lineage is complete.
39. As an evaluation owner, I want GoalDirected outputs directly comparable with StageGraph outputs on the same fixture, so that additional adaptivity must demonstrate value.
40. As a graph governance owner, I want the same no-write guarantee across every iteration, restore, and Temporal epoch, so that longevity cannot erode the invariant.

## Implementation Decisions

### Blueprint and launch envelope

- GoalDirectedPreflight is a distinct allowed blueprint family selected immutably at Run Request acceptance. A running StageGraph run cannot switch into it, and a GoalDirected run cannot switch to StageGraph.
- It consumes the same admitted Knowledge Preflight Brief, Run Input Manifest, Schema Workspace Binding, Coverage Matrix contract, observation envelope, candidates, assessments, snapshot, freshness, outcome, and Decision Report defined by the earlier specifications.
- The GoalDirected launch contract freezes an objective envelope, acceptance contract, Workflow Invariants, admitted targets and data surfaces, coverage baseline, allowed operation classes, linked-run slots, schema envelope, authority and Delegation Ceiling, multidimensional budget, iteration limits, no-progress limits, repeated-blocker limits, snapshot policy, and goal-evolution policy.
- The initial goal is derived deterministically from the Brief, accepted Coverage Matrix, and Schema Workspace Binding. Prompt text is a presentation of this goal, not its authority.
- Default initial limits are finite and configuration-bound. A run cannot interpret absent limits as unlimited; exact production values remain profile decisions.

### Iteration contract

- Every Goal Iteration is an immutable semantic unit with iteration number, active Goal Revision, selected coverage cells, objective, planned operations, resource reservation, input handoff, workspace identity, observations, proposals, dependency-graph changes, coordinator completion or continuation proposal, verifier decision, stopping state, and Operation Execution Bindings.
- `Temporal activity attempt`, `operation attempt`, `goal iteration`, `goal revision`, `workflow cycle`, and `Temporal epoch` remain separate counters.
- The coordinator selects only from authorized, non-prohibited, currently applicable coverage cells and operation classes. Selection records expected information gain, urgency, dependency impact, and cost basis.
- Queries use the same deterministic plan and read-only adapter validators as StageGraph. Adaptive query generation does not create a bypass.
- New observations always use the shared immutable envelope and native-evidence preservation rules. Novelty is computed against exact prior observations and normalized evidence identities.
- Agent handoffs or task subagents remain inside the current operation, inherit only explicit read mounts and authority, and return typed results. Work requiring independent lifecycle, reusable output, different authority, or substantial budget uses a declared linked-run request.

### Goal Revisions

- A Goal Revision is an immutable successor to exactly one parent goal revision and records triggering evidence, unmet obligations, proposed changes, unchanged launch constraints, author, independent verifier decision, deciding authority, applicability frontier, and digest.
- Allowed revisions may refine query tactics, subgoals, ordering, coverage emphasis, or the next target among already admitted targets and in-envelope coverage.
- A revision cannot change intended downstream use, broaden target or scope ceilings, add unadmitted inputs or data surfaces, weaken required obligations or acceptance, grant capabilities, enlarge the Delegation Ceiling, permit mutation, alter the bound blueprint, or bypass hard budget limits.
- Deterministic validation rejects out-of-envelope revisions before verifier semantic review. Rejected revisions remain durable proposals with reason codes.
- Expansion already declared by the baseline matrix's bounded revision policy may add cells only within target, relationship, depth, modality, scope, and budget ceilings. It creates an immutable Coverage Matrix revision and may trigger an affected-subgraph cycle.
- Any material expansion outside the launch envelope requires an authorized Run Control Revision where the blueprint already allows that class, a fork, a declared linked Workflow Run, or a new run.

### Independent verifier and convergence

- Coordinator and verifier are distinct execution roles with separate Agent Profile revisions, prompts, sessions, Operation Execution Bindings, and writable workspace namespaces. The verifier receives read-only access to promoted iteration evidence and cannot rely solely on coordinator summaries.
- The verifier cannot be a task subagent controlled by the coordinator when issuing acceptance, completion, Goal Revision, or convergence decisions. It is invoked by application orchestration under an independently frozen profile.
- Deterministic checks run before semantic verification: schema and deployment compatibility, required coverage states, budget and limit state, query safety, observation integrity, native-evidence preservation, invalidation completeness, snapshot lineage, and prohibited-work absence.
- The verifier emits one typed decision proposal: `propose_completion`, `continue`, `accept_goal_revision_and_continue`, `reject_goal_revision_and_continue`, `rerun_affected_subgraph`, `propose_degrade_and_complete`, `request_control_decision`, or `propose_stop_failed`. Its delegated authority covers only the configured bounded Goal Revision and continuation choices; the lifecycle reducer remains authoritative for obligation revisions, budgets, controls, and terminal outcome.
- `Propose_completion` requires every required coverage cell to satisfy the deterministic cell-state matrix, no unresolved invalidation, no unmet required verifier finding, and sufficient stopping evidence. It produces a Terminalization Proposal for reducer validation.
- `Propose_degrade_and_complete` may map only to `partially_completed`, and only when every required cell is satisfied, at least one declared degradable cell ended degraded, valid outputs meet the workflow contract, and any required obligation-matrix revision was separately authorized. Otherwise the reducer rejects the proposal.
- Progress is multidimensional: newly assessed cells, new nonduplicate evidence, reduced material unresolved scope, improved candidate differentiation, improved contradiction/gap characterization, or closure of a required blocker.
- Cost, result count, token use, coordinator confidence, or another iteration alone are not progress.
- Convergence occurs when completion is proposed and accepted by the reducer, no authorized action is expected to make material progress, no-progress or repeated-blocker limits are reached, hard budgets prevent required work, or an authorized stop decision is accepted.
- No-progress and repeated-blocker counters use normalized reason identities so cosmetic reformulation cannot reset them.
- Verifier disagreement and confidence remain recorded. Where profile policy requires, consequential disagreement escalates to a human or authorized control decision rather than self-resolution.

### Evidence dependency graph and affected-subgraph invalidation

- The run maintains an immutable-versioned evidence dependency graph over coverage cells, query intents, observations, normalized results, Graph Match Candidates, contradiction candidates, gap hypotheses, coverage assessments, snapshot sections, and report conclusions.
- Each derived record lists exact direct dependencies and method version. This graph is application domain lineage, not the Neo4j knowledge graph and not the StageGraph blueprint.
- New or superseding evidence produces a typed impact assessment that identifies changed roots, affected descendants, invalidation frontier, reusable unaffected outputs, next objective, required budget, and verifier decision.
- Invalidation marks affected derived records stale; it never deletes or mutates them. Recalculation creates successor records linked to stale predecessors.
- Whole-workflow semantic cycles rerun only the minimal affected subgraph. Immutable unaffected observations and conclusions are reused by reference after compatibility validation.
- A changed Graph Match Candidate invalidates only dependent identity-sensitive query plans, findings, contradictions, gaps, coverage cells, and report sections.
- A newly discovered context dimension invalidates dependent contradiction/gap classifications and any queries whose scope is now insufficient, not unrelated graph observations.
- A newly added in-envelope coverage cell invalidates aggregate completion, snapshot coverage, and report conclusions plus only the retrieval and analysis needed for that cell.
- Changes to the Schema Definition, deployed SDL hash, admitted inputs, objective envelope, or blueprint are not ordinary subgraph invalidations. They require the applicable control decision, fork, or new run.

### Sandbox snapshots and handoffs

- Every iteration persists a compact typed handoff containing active goal, selected cells, exact accepted records, unresolved questions, blocked operations, budget/counters, dependency-graph frontier, and verifier instructions. It references large evidence rather than embedding it.
- Snapshot policy may require a Sandbox Snapshot after each expensive iteration, before risky local transformation, upon blocked or failed operations, before model/session replacement, and before Continue-As-New.
- A Sandbox Snapshot is immutable provider execution state with filesystem manifest and digest, runtime/image/package/environment digests, parent workspace and snapshot lineage, creation reason, producer binding, capability shape without secret values, and retention policy.
- Restoring a snapshot always clones a new Sandbox Workspace. Credentials, secrets, MCP connections, graph sessions, sockets, and leases are freshly resolved and revalidated against the current accepted configuration.
- Restored local files remain workspace state. Only typed persistence or artifact promotion creates durable domain evidence, observations, snapshots, or reports.
- A restore verifies all mounted immutable inputs, Schema Workspace Binding, Mission Memory Pack when present, and handoff digests. Mismatch stops the iteration and requests a governed decision.

### Continue-As-New

- The top-level Temporal Workflow tracks history-event count, serialized history size where available, iterations since epoch start, and configured safety margins.
- Continue-As-New occurs at a safe iteration boundary, after current activities settle, required domain writes are durable, a compact continuation state is persisted, and an optional policy-required Sandbox Snapshot is complete.
- Continuation state contains only compact references and deterministic counters: Workflow Run identity, Run Input Manifest and configuration digests, active Goal Revision, current Coverage Matrix and Query Plan revisions, iteration/revision/cycle counters, dependency-graph head, budget state reference, pending waits or accepted controls, snapshot/workspace references, and idempotency namespace.
- Continue-As-New creates a new Temporal epoch for the same application Workflow Run. It does not create a new run, Goal Iteration, Goal Revision, workflow cycle, observation, or domain lifecycle transition merely by occurring.
- Signals, Updates, cancellation, pause, resume, and accepted control revisions are drained or carried according to a deterministic handoff protocol so none are lost between epochs.
- Public API projections hide epoch boundaries except in execution diagnostics. Domain queries and final outputs remain continuous.

### API, persistence, and reporting extension

- The existing start API accepts the GoalDirected blueprint and its published profile; no parallel variant-specific launch endpoint is introduced.
- Query APIs add current goal, Goal Revision ledger, iteration summaries, verifier decisions, convergence metrics, dependency-graph impact assessments, stale/successor records, Sandbox Snapshot metadata, and Temporal epoch diagnostics.
- Commands add propose or decide an allowed continuation/control request, pause, resume, cancel, and fork from an exact snapshot. Agents call the same application services under explicit authority.
- Goal Iterations, Goal Revisions, verifier decisions, impact assessments, dependency-graph versions, handoffs, and snapshot metadata use the authoritative stores established by the system architecture. Lifecycle and budget transitions remain under PostgreSQL control-plane authority.
- The final Knowledge Preflight Snapshot references the complete iteration/revision/verifier/invalidation lineage and the exact active records. It does not embed all workspace or Temporal history.
- The Decision Report explains adaptive strategy, rejected alternatives and revisions, verifier disagreements, evidence novelty, reused versus rerun work, convergence, snapshots/restores, Continue-As-New epochs, and remaining limitations.

## Testing Decisions

- The highest practical seam is an HTTP-level black-box run through the real gateway, control-plane transaction, Temporal worker, independent coordinator and verifier runtime adapters, persistence, snapshot provider test double, and instrumented read-only fixture adapters.
- The principal adaptive fixture extends the StageGraph fixture so an initial alias result reveals an admitted alternate target, a prior-run observation reveals a temporal context, and one required gap cell needs a second modality before bounded non-discovery is justified.
- The acceptance test proves at least two Goal Iterations, one accepted bounded Goal Revision, one rejected out-of-envelope Goal Revision, one independent verifier continuation decision, one contextual contradiction correction, one minimal affected-subgraph rerun, native-score preservation, prior-run discovery, bounded non-discovery, final completion, and zero graph writes.
- Verifier-independence tests assert distinct profiles, sessions, execution bindings, and workspace ownership and prove the coordinator cannot directly issue an accepted completion or Goal Revision decision.
- Lifecycle-authority tests prove verifier completion/degradation/failure outputs remain proposals, that only the reducer terminalizes the run, and that `propose_degrade_and_complete` cannot yield `completed` or conceal an unmet required cell.
- Goal-boundary tests attempt to change intended use, add an unadmitted target, weaken a required cell, request a write capability, enlarge budget, and add a data surface; every attempt is rejected while the proposal remains auditable.
- Convergence tests cover acceptance, material progress, duplicate evidence, no progress, repeated blocker, hard budget exhaustion, unresolved required coverage, and authorized degradation.
- Metamorphic tests repeat semantically identical queries with cosmetic changes and prove novelty and blocker counters do not reset.
- Affected-subgraph tests change one alias candidate, one temporal context, and one gap observation independently and assert exact stale descendants, reused unaffected records, and minimal rerun adapter calls.
- Invalidation tests prove stale records remain queryable, successor lineage is complete, and a final snapshot cannot reference stale active conclusions.
- Snapshot tests verify immutable manifests, clone-on-restore, parent lineage, no restored secrets or live connections, credential revalidation, and no implicit promotion of workspace files.
- Restore tests alter a mounted input or Schema Workspace digest and assert the restored iteration stops before graph access.
- Continue-As-New tests force a low history threshold, execute across multiple epochs, and assert one Workflow Run, monotonic semantic counters, no duplicate iteration or observation, preserved signals and cancellation, stable idempotency, and uninterrupted public queries.
- Temporal replay tests cover each epoch and the continuation handoff.
- Activity retry tests distinguish retry of one side effect from a new operation attempt and new Goal Iteration.
- Schema mismatch tests exercise initial launch and post-restore access, asserting rejection before credential resolution or graph-adapter calls in both cases.
- No-write tests aggregate adapter ledgers across all iterations, restores, subgraph reruns, and Temporal epochs and assert zero mutation requests and zero update counters.
- Comparative evaluation runs StageGraph and GoalDirected against the same labeled fixture. GoalDirected is accepted only if it improves required-cell assessment or contradiction/gap characterization without reducing precision, native-evidence fidelity, no-write safety, or reproducibility.
- API contract tests cover iteration pagination, revision lineage, verifier decisions, staleness, snapshot metadata, epoch diagnostics, authorization, and durable reconnect behavior.
- Chaos tests terminate workers around activity completion, snapshot completion, verifier decisions, and Continue-As-New boundaries and assert idempotent recovery with no lost accepted domain records.

## Out of Scope

- Unbounded autonomous research, open-ended graph exploration, self-modifying prompts, agent-authored workflow topology, or agent-granted authority.
- Changing a running Workflow Run between StageGraph and GoalDirected blueprint families.
- General-purpose goal management for every Workflow Type; this specification adds the declared Knowledge Preflight variant using shared blueprint primitives.
- Production model selection, prompt wording, numerical iteration defaults, confidence thresholds, or budget amounts beyond requiring finite published values.
- Hidden nested durable workflow engines inside the Agents SDK, MCP servers, or sandbox agents.
- Shared Schema Catalog generation, Schema Workspace Materialization internals, deployment-manifest production, or canonical schema mutation.
- Identity adjudication, Assertion adjudication, graph repair, ingestion, or any Neo4j mutation.
- Automatic graph-maintenance linked runs, broad Source Discovery, or Source Corpus changes unless later specifications declare and admit those Workflow Runs.
- Dashboard implementation and visualization of dependency graphs.

## Further Notes

- Dependency order: this specification is third. It depends on the domain-contract/deterministic-core specification and the StageGraph vertical slice, plus their upstream shared control-plane and Schema Workspace companion capabilities.
- GoalDirected is an extension, not a replacement. StageGraph remains the baseline for predictable bounded work and the comparison control for evaluation.
- A Workflow cycle, Goal Iteration, Goal Revision, activity retry, sandbox restore, and Temporal Continue-As-New each have different semantics and must never share a counter or identity.
- The implementation target's existing durable sandbox probe demonstrates runtime feasibility but does not yet provide independent verification, application lifecycle authority, snapshot lineage, or safe continuation state; those are explicit deliverables here.
