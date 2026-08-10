## Problem Statement

Knowledge-producing workflows need a reproducible answer to what the system already knows before they specify missions, perform deep research, or propose graph work. A live graph lookup is insufficient: it does not freeze purpose, scope, schema compatibility, prior-work context, query effort, native ranking evidence, ambiguity, failures, or the distinction between likely absence and bounded non-discovery. Without a strict domain core, later workflow implementations would be forced to invent admission, coverage, candidate, contradiction, gap, freshness, and completion semantics.

Knowledge Preflight must remain observational. It must not resolve identity, adjudicate Assertions, mutate canonical knowledge, or claim that an empty result proves a real-world gap. Its durable output must describe a bounded historical observation while preserving exact schema, deployment, graph, query, permission, and configuration context.

This specification is the first dependency in the Knowledge Preflight sequence. It defines framework-independent contracts and deterministic decisions consumed by both execution blueprints.

## Solution

Define a strict, versioned Knowledge Preflight domain model and deterministic core covering the Knowledge Preflight Brief, admission, coverage and query plans, retrieval observations, normalized findings, Graph Match Candidates, contradiction candidates, gap hypotheses, immutable snapshots, purpose-bound freshness assessments, completion, and Decision Reports.

The deterministic core validates immutable inputs, rejects incompatible graph deployments before access, derives stable identities and digests, validates coverage and bounded query plans, preserves provider-native evidence, evaluates completion from cell-level obligations, assembles snapshots by reference, and computes purpose-bound freshness. Agent-produced proposals remain proposals until these deterministic rules accept them.

Shared Schema Catalog generation and Schema Workspace Materialization are an upstream companion capability. Knowledge Preflight consumes their exact references, compatibility result, and read-only binding; it does not duplicate their parser, generator, catalog, selection, expansion, materialization, or deployment-attestation implementation.

## User Stories

1. As an operator, I want to state the preflight purpose and intended downstream use, so that the observation is evaluated against a concrete need.
2. As a caller, I want to target canonical entities, unresolved referents, concepts, Assertions, questions, artifacts, packages, or prior snapshots, so that preflight does not require fabricated identity.
3. As an operator, I want to declare temporal, jurisdictional, population, evidence, provenance, and other scope dimensions, so that contextual differences are not mistaken for contradictions.
4. As an operator, I want to declare exclusions, so that omitted work is intentional and auditable.
5. As a consuming workflow, I want exact brief revisions and admitted references frozen in the Run Input Manifest, so that later mutations cannot rewrite historical meaning.
6. As a policy service, I want admission to require a valid purpose plus at least one target or graph-wide coverage question, so that empty or unbounded requests are rejected.
7. As a graph owner, I want the bound Schema Definition hash to equal the deployed SDL hash, so that queries cannot run against a drifted graph.
8. As an operator, I want schema incompatibility reported before any graph query, so that a failed run causes no graph access.
9. As a security owner, I want every requested data surface and retrieval modality authorized at admission, so that planning cannot expand access.
10. As a budget owner, I want required coverage proven affordable within the admitted Budget Envelope, so that knowingly impossible runs are rejected or revised.
11. As a planner, I want every coverage cell to combine a target, objective, scope, schema surface, modality, and obligation class, so that coverage is explicit.
12. As a planner, I want required, degradable, optional, and prohibited cells distinguished, so that completion and partial completion are deterministic.
13. As a planner, I want every executable query connected to applicable coverage cells, so that exploratory work remains accountable.
14. As a graph administrator, I want query plans bounded by rows, traversal depth, time, tokens, cost, and calls, so that read access cannot become operationally unbounded.
15. As a reviewer, I want query-plan revisions immutable and linked to their predecessors, so that tactical changes do not alter the original obligations.
16. As a retrieval evaluator, I want each retrieval call captured independently, so that later normalization cannot hide individual failures or duplicate evidence.
17. As a retrieval evaluator, I want provider-native identifiers, ranks, scores, and score semantics preserved, so that BellLabs reranking does not overwrite source evidence.
18. As a privacy reviewer, I want sensitive requests represented by a redacted request plus a stable digest when necessary, so that reproducibility does not leak protected data.
19. As a graph researcher, I want exact graph, schema, deployment, provider, index, and observation-time context attached to every observation, so that stale or incompatible evidence is visible.
20. As an identity reviewer, I want multiple Graph Match Candidates to coexist with supporting and opposing evidence, so that preflight does not choose a canonical identity.
21. As a downstream workflow, I want existing entities, relationships, Assertions, Adjudications, reports, packages, runs, and evaluations represented as observations, so that prior knowledge is discoverable without being rewritten.
22. As an evidence reviewer, I want apparent contradictions to preserve proposition, temporal, population, jurisdiction, dose, formulation, identity, and source context, so that contextual non-contradictions remain distinguishable.
23. As a research planner, I want gap hypotheses to distinguish likely absence, bounded non-discovery, unsupported modality, inaccessible data, and unresolved scope, so that missing results are not overstated.
24. As a coverage reviewer, I want zero-match and zero-contradiction findings accepted only when applicable coverage and stopping conditions were assessed, so that silence is not treated as evidence.
25. As a workflow consumer, I want an immutable Knowledge Preflight Snapshot, so that I can reference a historical observation rather than query live state.
26. As a storage owner, I want snapshots to reference graph records and large immutable evidence instead of copying the graph, so that lineage is preserved without uncontrolled duplication.
27. As an operator, I want structurally valid snapshots available for partial, failed, or cancelled runs when possible, so that completed observations are not discarded.
28. As a downstream admission service, I want freshness evaluated against a specific proposed use, so that there is no misleading universal time-to-live.
29. As an auditor, I want an outdated snapshot retained as valid historical evidence, so that freshness decisions never rewrite history.
30. As an operator, I want a Decision Report explaining strategy, alternatives, coverage, unresolved identities, contradictions, gaps, failures, and stopping rationale, so that the result is intelligible.
31. As an evaluation owner, I want Improvement Candidates separated from accepted runtime configuration, so that lessons do not silently alter future authority.
32. As a platform owner, I want deterministic serialization and stable content digests for immutable contracts, so that replay, deduplication, and lineage comparisons are reliable.
33. As a workflow author, I want namespaced extension points validated by registered discriminators, so that arbitrary untyped payloads cannot acquire domain meaning.
34. As a graph governance owner, I want all mutation proposals redirected to a separate linked Workflow Run, so that Knowledge Preflight remains read-only.

## Implementation Decisions

### Contract and revision rules

- All domain contracts are strict, versioned models with forbidden unknown fields. Extensibility uses a registered namespace and discriminator; unrestricted maps are not executable configuration.
- Immutable records carry a stable logical identity, immutable revision identity where revision is meaningful, schema version, creation time, producer or deciding authority, predecessor references where applicable, canonical serialization digest, and correlation lineage.
- A Knowledge Preflight Brief records purpose, intended downstream use, target set, graph and prior-work questions, scope dimensions, requested modalities, coverage obligations, freshness requirements, exclusions, output-detail limits, permissions context, and optional prior snapshot references.
- Brief targets use a discriminated vocabulary for canonical entity references, unresolved referents, Entity Seeds, concepts, Assertion references or propositions, questions, artifact/package/report references, prior-run references, and graph-wide questions. Admission never upgrades an unresolved referent into a canonical identity.
- The Run Input Manifest freezes the exact Brief revision; admitted targets and supporting references; Schema Definition, Schema Catalog Build, Schema Deployment Manifest, Schema Workspace policy, blueprint, Effective Run Configuration, permissions, and any prior snapshots.

### Admission

- Admission is a deterministic decision with `accepted` or `rejected` outcome, reason codes, evaluated evidence, and exact contract revisions. Rejection creates no Workflow Run when it occurs during Run Request validation.
- Admission requires a non-empty purpose and intended use; at least one admitted target or graph-wide question; a published Knowledge Preflight Workflow Type and allowed blueprint revision; a valid Effective Run Configuration; sufficient authority and permissions; supported retrieval modalities; bounded limits; and a budget capable of attempting every required obligation.
- Any requested graph access additionally requires an accepted Schema Catalog Build derived from the bound Schema Definition, an immutable Schema Deployment Manifest, and exact equality between deployed SDL hash and Schema Definition content hash.
- Missing or unequal deployment hashes are hard rejection reasons. The manifest's digest is never compared as if it were schema identity. Live introspection cannot satisfy the equality check.
- Deployment-hash compatibility is evaluated before graph credentials are resolved, a graph adapter is acquired, graph health is probed, or any graph query is issued.
- Admission distinguishes policy gates from Workflow Invariants. No override can permit mutation, schema mismatch, unbounded graph access, hidden identity resolution, or unauthorized data access.

### Coverage and query planning

- A Knowledge Preflight Coverage Matrix has an immutable baseline and optional immutable revisions permitted by the selected blueprint. Each cell has a stable identity derived from normalized target, objective, schema surface, modality, scope dimensions, and obligation class.
- Objective vocabulary initially includes existing graph knowledge, prior work, contradiction search, gap assessment, unresolved identity, provenance/evidence coverage, and declared downstream questions.
- Obligation classes are `required`, `degradable`, `optional`, and `prohibited`. Cell states distinguish `unassessed`, `planned`, `in_progress`, `satisfied`, `supported_zero`, `bounded_non_discovery`, `inaccessible`, `unsupported`, `failed`, `excluded`, and `unresolved`.
- Cell-state consequence is deterministic:
  - `unassessed`, `planned`, and `in_progress` are pending for every non-prohibited obligation and cannot support terminal completion.
  - `satisfied`, `supported_zero`, and `bounded_non_discovery` satisfy required, degradable, or optional cells only when their state-specific evidence and stopping rules validate.
  - `inaccessible`, `unsupported`, `failed`, and `unresolved` leave a required cell unmet, terminate a degradable cell as degraded, and terminate an optional cell as an explicit omission.
  - `excluded` is terminal only when an accepted matrix revision or baseline exclusion makes the cell non-applicable; an unapproved exclusion is invalid.
  - A prohibited cell authorizes no query or operation. Any attempted work against it is a Workflow Invariant violation, not successful coverage.
- Positive result count never determines cell completion. Each terminal assessment cites observations, stopping evidence, limits consumed, and any unresolved or inaccessible paths.
- A Knowledge Preflight Query Plan maps every executable query intent to one or more non-prohibited cells, selected schema context and operation projection, one governed adapter, request and filters, traversal bounds, resource limits, deduplication policy, and stopping or continuation evidence.
- Query-plan revisions preserve the baseline obligations and parent revision. Tactical revisions may reformulate requests or switch among admitted modalities; they cannot broaden targets, data surfaces, authority, or hard limits.
- Deterministic validation rejects unauthorized adapters, unknown schema elements, write-capable operations, unparameterized values where parameterization is required, missing limits, unbounded variable traversals, prohibited cells, and plans disconnected from coverage.

### Retrieval observations and normalized findings

- Every attempted adapter call creates one immutable Knowledge Retrieval Observation, including rejected, failed, timed-out, truncated, and zero-result calls.
- The observation records coverage cells, query-plan revision, exact adapter and provider identity, database or index identity and version when available, structured request or redacted request digest, filters, graph and schema context, observation time, native result identities, native rank, native score and semantics, payload references, latency, usage, truncation, errors, permission binding, and Operation Execution Binding.
- Native ranks and scores remain immutable. Normalized relevance, reranking, confidence, classification, and selection are separate records linked to observations. Heterogeneous scores are never collapsed into a universal score.
- Deduplication associates observations without deleting them. Candidate aggregation preserves every contributing observation, opposing evidence, alternatives, and method version.
- Existing-knowledge findings distinguish observed canonical records, Assertions, Adjudications, relationships, prior artifacts, prior Workflow Runs, evaluations, ingestion records, and configuration records. Their presence does not imply current truth, applicability, readiness, or endorsement.

### Candidates, contradictions, and gaps

- A Graph Match Candidate links one exact provisional referent to one possible canonical graph record. Match categories initially distinguish exact stable identifier, exact normalized label, alias or synonym, contextual or relational, lexical, semantic, hybrid, and unresolved candidate.
- A candidate records match category, canonical candidate reference, supporting and opposing observations, query and schema context, graph-version context, confidence dimensions, method version, alternatives, and unresolved identity state. Preflight has no accepted-winner field.
- A contradiction candidate records the exact propositions or graph structures in apparent conflict; temporal, jurisdictional, population, dose, formulation, identity, and source contexts; supporting and opposing observations; possible contextual or representational explanations; confidence dimensions; unresolved alternatives; and recommended follow-up.
- A contradiction candidate is never an Adjudication. Deterministic context comparison marks clearly disjoint scopes as contextual non-contradictions while retaining the observations and rationale.
- A gap hypothesis binds an expected knowledge surface to exact coverage cells and observations. Its claim class is one of `likely_absence`, `bounded_non_discovery`, `unsupported_modality`, `inaccessible_surface`, or `unresolved_scope`.
- `Likely_absence` requires an explicitly configured high-evidence policy and sufficiently assessed mandatory tactics. The default true-gap outcome for the initial implementation is `bounded_non_discovery`.
- Empty results alone cannot create a gap. A gap requires assessed scope, attempted tactics, limits, exclusions, inaccessible or failed paths, unresolved leads, stopping evidence, downstream consequence, and proposed next work.

### Snapshot, freshness, completion, and reporting

- Snapshot assembly is deterministic from accepted immutable record references. The snapshot freezes purpose and observation interval; Run Input Manifest and Brief; Workflow Run and Effective Run Configuration; schema and deployment bindings; graph/data revision context; matrix and query-plan revisions; observations; normalized findings; selected result identities; candidates; contradictions; gaps; unresolved identities; unassessed cells; failures; degradation; stopping rationale; large-payload references; evaluation; and Decision Report references.
- The snapshot is immutable and content-addressed. Large payloads, raw result sets, captured evidence, and rendered reports are referenced in object storage; the snapshot does not copy live graph state.
- A Preflight Freshness Assessment is a separate immutable decision for one snapshot and one proposed downstream use. It evaluates observation age, relevant graph data revision, Schema Definition and deployment revisions, target/scope/use changes, newly available indexes or modalities, and downstream risk.
- Freshness outcomes are `current`, `current_with_conditions`, `stale`, or `indeterminate`, with reasons and reconsideration triggers. No global TTL silently invalidates a snapshot.
- The deterministic core computes a `TerminalizationProposal` from the exact Coverage Matrix revision and accepted cell evidence. It does not assign Workflow Run lifecycle state. The shared PostgreSQL lifecycle reducer validates the proposal and alone records `completed`, `partially_completed`, `failed`, or `cancelled`.
- `Completed` is proposed when all required cells satisfy the matrix above and no degradable cell ended degraded. `Partially_completed` is proposed when all required cells satisfy it and at least one degradable cell ended degraded. `Failed` is proposed when any required cell is terminal but unmet or cannot be satisfied under the accepted stopping decision. Pending required cells prevent a completion proposal. `Cancelled` follows the authorized cancellation state regardless of valid partial outputs.
- A structurally valid snapshot may be assembled for any outcome when its omissions and stopping state are explicit. Snapshot existence does not change the Workflow Run outcome.
- Failed or cancelling runs attempt a partial snapshot or Decision Report only through the shared blueprint-declared terminal-finalization contract. The Finalization Plan freezes the current valid observation frontier, dedicated budget, timeout, and allowed assembly/reporting effects; it cannot schedule new retrieval. If validation, budget, or timeout prevents assembly, the run records a typed output-omission reason.
- The Decision Report is separately versioned and links each conclusion to domain records. It explains strategy, alternatives, modality and coverage assessment, native-versus-BellLabs ranking, candidates, contextual non-contradictions, contradiction candidates, gaps, unresolved identities, failures, linked-work proposals, stopping rationale, quality limitations, and Improvement Candidates.

### Persistence and authority

- Document-shaped Briefs, matrix and plan revisions, observations, candidates, findings, snapshots, freshness assessments, evaluations, and Decision Report metadata use the system's document authority. Large immutable payloads use object storage.
- Workflow lifecycle, commands, budgets, links, approvals, transactional outbox events, and API projections remain under the shared control-plane authority and are referenced rather than redefined here.
- Neo4j is read-only for this Workflow Type. Read-only database credentials and adapter validation are defense in depth; the domain invariant independently prohibits writes.
- Shared Schema Catalog and Schema Workspace models are consumed as exact upstream companion references. This specification adds no second schema authority or alternate materializer.

## Testing Decisions

- Tests assert externally observable domain behavior through public domain services and serialized contracts, not private helpers, ORM internals, or particular module layout.
- The primary deterministic acceptance suite exercises Brief admission through snapshot, freshness, completion, and Decision Report inputs without requiring live infrastructure.
- Admission contract tests prove that an accepted deployment hash permits planning and that a missing or mismatched deployed SDL hash is rejected before any graph-adapter acquisition callback is observed.
- Coverage tests prove that equal result counts can produce different outcomes when stopping evidence differs, and that a required unassessed cell causes failure.
- Query-plan tests prove rejection of write operations, unbounded traversals, unsupported modalities, unknown schema surfaces, missing limits, unauthorized data surfaces, and disconnected queries.
- Observation tests prove lossless preservation of native identifier, rank, score, score semantics, request context, zero results, failures, timeout, and truncation.
- Candidate tests prove that exact matches, aliases, and competing candidates coexist without an identity winner and retain supporting and opposing observations.
- Contradiction tests prove that temporally, jurisdictionally, population-, dose-, or formulation-disjoint Assertions are reported as contextual non-contradictions rather than contradiction candidates.
- Gap tests prove that one empty query cannot create a gap, while a bounded fixture with all required tactics and stopping evidence creates a `bounded_non_discovery` hypothesis without claiming universal absence.
- Snapshot contract tests prove canonical serialization stability, complete lineage, immutable references, explicit omissions, and no embedded graph copy.
- Freshness tests vary observation age, graph revision, schema revision, scope, newly available modality, and downstream risk independently to prove purpose-bound outcomes.
- Completion tests cover completed, partially completed, failed, and cancelled runs, including structurally valid partial snapshots that do not alter the run outcome.
- Matrix tests cover every cell-state and obligation-class combination, including accepted `bounded_non_discovery` satisfying a required fixture cell, required inaccessible/failed states producing failure, degradable failure producing partial completion, optional omission remaining outcome-neutral, pending states blocking terminalization, and prohibited work causing an invariant violation.
- Terminalization tests prove the domain service emits a proposal and only the shared reducer assigns outcome; stale matrix revisions, stale evidence, and unaccepted exclusions are rejected.
- Property-based tests cover canonical serialization, stable cell identities, digest determinism, revision immutability, and order-independent aggregation where order has no domain meaning.
- Contract compatibility tests reject unknown executable fields and incompatible schema versions while allowing registered namespaced extensions.
- Prior art from the existing graph project informs deterministic schema parsing/expansion and guarded read-query behavior, but its ingestion-oriented write capabilities and thin selection contract are not copied.

## Out of Scope

- StageGraph orchestration, FastAPI endpoints, Temporal workers, read adapters, Socket.IO projections, and the end-to-end vertical slice.
- GoalDirected iterations, independent verification, Goal Revisions, convergence, affected-subgraph invalidation, sandbox snapshots, and Continue-As-New.
- Shared control-plane tables, lifecycle reducer, outbox relay, configuration compiler, agentic catalogs, memory system, and general linked-run machinery.
- Schema Definition parsing, Schema Catalog generation, Schema Context Selection Workflow, deterministic expansion, operation-projection generation, Schema Workspace Materialization, and deployment-manifest production. These belong to the upstream companion specification.
- Canonical identity resolution, Assertion adjudication, graph repair, ingestion planning, ingestion execution, and any Neo4j mutation.
- Production values for retrieval weights, model choices, confidence thresholds, retention periods, or a universal likely-absence policy.
- Dashboard implementation and user-interface design.

## Further Notes

- Dependency order: this specification is first. The StageGraph vertical slice depends on it. The GoalDirected extension depends on both.
- Upstream dependencies are the shared Workflow Run/control-plane contracts and the companion Schema Catalog/Schema Workspace capability.
- The implementation target currently provides infrastructure clients, a minimal FastAPI/Socket.IO shell, and a Temporal sandbox probe but no application domain models. This specification therefore requires adding domain behavior without treating bootstrap infrastructure as accepted domain design.
- The graph repository is prior art only. Its deterministic schema tools and guarded read workbench validate feasibility, while its ingestion focus, local artifact conventions, and write-proposal paths do not define Knowledge Preflight authority.
