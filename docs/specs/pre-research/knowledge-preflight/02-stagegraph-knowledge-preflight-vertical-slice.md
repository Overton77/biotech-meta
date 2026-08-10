## Problem Statement

The deterministic Knowledge Preflight contracts are not useful until callers can start and observe a real run that safely traverses the application API, durable control plane, Temporal orchestration, read-only data adapters, snapshot persistence, and result query surface. The current implementation target is an infrastructure bootstrap: it can initialize FastAPI, Socket.IO, Temporal, MongoDB, PostgreSQL, Neo4j, object storage, and an Agents SDK sandbox probe, but it has no Knowledge Preflight application behavior.

The first executable slice must prove the highest-risk boundaries together. In particular, schema-deployment drift must reject a request before graph access, retrieval must be provably read-only, native ranking evidence must survive normalization, contextual differences must not become false contradictions, and a true missing fixture cell must be reported only as bounded non-discovery after declared tactics complete.

## Solution

Implement one production-shaped `StageGraphPreflight` vertical slice behind typed FastAPI command and query APIs. It consumes the shared immutable compiler, Run Request admission, lifecycle/outbox, budget, orchestration, operation-runtime, workspace, conversation/realtime, and schema-materialization contracts rather than reimplementing them. The slice supplies the Knowledge Preflight Workflow Type, StageGraph blueprint, domain services, read-only adapters, workflow-specific activities, projections, snapshot, and Decision Report.

The initial stage graph is:

`Admission -> Schema Workspace Materialization -> Subject and Intent Normalization -> Coverage Matrix and Query Planning -> Parallel Retrieval Branches -> Result Normalization and Candidate Aggregation -> Contradiction, Gap, and Coverage Evaluation -> Snapshot Assembly -> Decision Report`

The optional linked-work and whole-workflow cycle slots remain declared but disabled in this slice. The architecture must preserve their future seam without pretending to implement them.

The shared Schema Catalog and Schema Workspace Materialization remain upstream companion capabilities. This slice invokes their contract through an adapter and consumes an exact Schema Workspace Binding; it does not rebuild catalog or workspace logic.

## User Stories

1. As an authenticated operator, I want to submit a typed Knowledge Preflight Run Request, so that execution begins through the governed control plane.
2. As an API client, I want to provide an idempotency key, so that retries return the same accepted command and run.
3. As an API client, I want conflicting reuse of an idempotency key rejected, so that a prior request is not silently repurposed.
4. As an operator, I want admission errors returned before a Workflow Run is created, so that rejected requests do not look like failed executions.
5. As a graph owner, I want a mismatched deployment hash rejected before Neo4j is contacted, so that schema drift cannot expose misleading results.
6. As an operator, I want the accepted Brief, manifest, blueprint, and Effective Run Configuration digests returned, so that I can identify exactly what will execute.
7. As a workflow operator, I want the API and Temporal execution to use the same stable Workflow Run identity, so that retries and reconciliation do not create duplicate runs.
8. As an auditor, I want the StageGraph blueprint revision frozen at launch, so that a running topology cannot change silently.
9. As a schema consumer, I want one exact read-only Schema Workspace Binding materialized before query planning, so that graph queries use compatible schema context.
10. As a caller with an unresolved alias, I want subject normalization to preserve the original referent and alternatives, so that normalization does not resolve identity.
11. As a planner, I want a deterministic baseline coverage matrix and bounded query plan, so that every retrieval has a declared purpose and stopping condition.
12. As an operator, I want exact-identifier, name/alias, graph-neighborhood, and prior-work branches to run independently, so that one modality failure need not discard all observations.
13. As an infrastructure owner, I want branch concurrency bounded, so that parallel retrieval respects graph and worker capacity.
14. As a graph owner, I want the Neo4j adapter to use read access mode, a read-only principal, transaction timeout, row limit, traversal-depth limit, and procedure allowlist, so that defense in depth matches the no-write invariant.
15. As a graph owner, I want write and administrative Cypher rejected before execution, so that agent or planner mistakes cannot reach the graph.
16. As a prior-work owner, I want prior Workflow Run and output retrieval to use typed read-only queries, so that preflight cannot alter control-plane records.
17. As a retrieval evaluator, I want every call, including zero-result, timeout, truncation, and rejected-query calls, persisted as an observation, so that coverage reflects actual effort.
18. As a retrieval evaluator, I want full-text and vector native ranks and scores preserved, so that later reranking remains independently inspectable.
19. As an identity reviewer, I want known exact matches and aliases emitted as separate Graph Match Candidates, so that candidate evidence remains explicit.
20. As an identity reviewer, I want multiple candidates retained for an ambiguous alias, so that preflight does not choose a canonical winner.
21. As an evidence reviewer, I want Assertions with different time, jurisdiction, population, dose, or formulation treated as contextual non-contradictions when their scopes do not overlap, so that false conflict is controlled.
22. As a research planner, I want an intentionally missing fixture cell searched through its declared bounded tactics, so that non-discovery is supported by evidence.
23. As a research planner, I want the missing fixture reported as bounded non-discovery rather than universal absence, so that the result does not exceed assessed scope.
24. As a workflow consumer, I want prior-run records included in existing-knowledge findings, so that previous work is discoverable alongside graph knowledge.
25. As an operator, I want branch failures classified as required or degradable, so that the terminal outcome follows declared obligations.
26. As an operator, I want a durable snapshot even when degradable work fails, so that valid observations remain usable.
27. As an operator, I want the Decision Report to explain query tactics, results, native-versus-normalized ranking, candidates, non-contradictions, gaps, and stopping, so that I can audit the run.
28. As an API client, I want to query run, stage, branch, coverage, observation, candidate, snapshot, and report projections, so that I do not inspect Temporal or databases directly.
29. As an API client, I want stable pagination and authorization-filtered summaries, so that large result sets are safe to consume.
30. As a realtime client, I want durable projection-change hints with aggregate versions or cursors, so that reconnect can recover through queries.
31. As a platform operator, I want transient activity failures retried idempotently without creating new semantic observations, so that infrastructure retries do not masquerade as new search effort.
32. As a platform operator, I want a new query tactic recorded as a semantic operation attempt, so that it remains distinct from an infrastructure retry.
33. As an operator, I want cancellation to produce a `cancelled` run with an explicit partial snapshot when assembly is safe, so that completed work is retained without claiming completion.
34. As a platform owner, I want Temporal Workflow code to remain deterministic and free of direct database or network I/O, so that replay is safe.
35. As a security reviewer, I want every data operation bound to caller authority, permission, configuration, and operation execution records, so that access is explainable.
36. As a graph governance owner, I want an end-to-end assertion that no Neo4j writes occur, so that the vertical slice proves its defining mutation boundary.

## Implementation Decisions

### API and application-service boundary

- The command API accepts a typed Knowledge Preflight Run Request containing the exact Brief revision or payload, admitted input references, requested StageGraph blueprint revision, control-profile revision, permitted overlay, caller context, and idempotency key.
- Request validation calls the deterministic admission service from the first specification before creating a Workflow Run. A rejected request returns a typed rejection with reason codes and creates no run, no Temporal execution, and no graph-adapter access.
- For an accepted request, the shared control-plane service performs its existing PostgreSQL admission transaction and start relay. This slice contributes the published StageGraph fixture, preflight-specific admission checks, exact adapter requirements, obligation defaults, and workflow projections.
- The shared compiler freezes exact revisions, accepted and rejected overlay decisions, capability bindings, limits, Schema Workspace requirement, adapter allowlist, and digest. This slice neither defines a second compiler nor resolves mutable aliases at admission.
- Query APIs read authorized application projections rather than Temporal history. Initial resources cover run summary, stage/branch state, coverage matrix, query plan, observations, candidates/findings, snapshot, freshness assessment, and Decision Report.
- API resources include schema version, aggregate version, correlation identity, and durable references. Collections use deterministic ordering and cursor pagination.
- Socket.IO emits only authorization-filtered projection-change hints after durable state changes. Reconnect correctness comes from query APIs and durable cursors.

### StageGraph topology and stage semantics

- The StageGraph topology is application-owned, versioned, acyclic, and immutable for the run. Dependencies distinguish required and degradable branches; no agent can add stages or edges.
- Admission completes in the application service before run creation and is verified by Temporal before substantive work.
- Schema Workspace Materialization invokes the upstream shared operation idempotently and persists the returned exact binding. Planning cannot begin without a compatible accepted binding.
- Subject and Intent Normalization produces normalized search forms while preserving original targets, aliases, ambiguity, exclusions, and unresolved identity.
- Coverage Matrix and Query Planning builds the baseline matrix and one initial bounded plan. Deterministic validators accept or reject proposed queries before branch scheduling.
- The initial graph retrieval branches are exact identifier/property lookup, full-text alias/name search, bounded neighborhood/relationship inspection, and schema-aware read-only Cypher where needed.
- The initial prior-work branch retrieves exact Workflow Run, snapshot, package, report, evaluation, and ingestion-record references from application projections or governed document repositories through typed read adapters.
- Parallel branches have exclusive semantic state and workspace ownership. Cross-branch consolidation occurs only through immutable observations and a single-writer aggregation activity.
- Result Normalization and Candidate Aggregation preserves native evidence, creates normalized findings and Graph Match Candidates, and never selects a canonical identity.
- Contradiction, Gap, and Coverage Evaluation applies deterministic context comparisons first, accepts bounded analytical proposals only against exact observations, computes coverage state, and emits a typed Terminalization Proposal. It never assigns the Workflow Run outcome.
- Snapshot Assembly and Decision Report are separate idempotent activities. Snapshot assembly succeeds from immutable references and does not depend on rendering the human report.
- Declared stage-cycle, whole-workflow-cycle, and linked-run slots are present in the blueprint contract but disabled by zero allowance for the first slice. Attempts to activate them are rejected, not ignored.

### Temporal mapping

- One top-level Temporal Workflow represents one Knowledge Preflight Workflow Run.
- Workflow code owns dependency readiness, compact stage and branch state, timers, retries, cancellation coordination, accepted control references, and terminal orchestration.
- Database access, schema materialization, query validation requiring current capabilities, adapter calls, agent/model calls, persistence, object storage, evaluation, projection updates, and event publication occur in activities.
- Each activity receives stable semantic operation identity and deterministic idempotency key. Temporal activity retries reuse that identity; a new query-plan operation creates a new semantic identity.
- Retrieval branches remain activities in the first slice because their work is bounded and has no independent waits or cycles. The contract allows promotion to child workflows later without changing observations.
- Activity heartbeats report coarse progress and support cancellation. Cancellation stops unscheduled work, requests cancellation of in-flight activities, then asks the shared reducer to accept a blueprint-declared Finalization Plan. That plan may use only the frozen valid observation frontier, dedicated finalization reservation, snapshot/report assembly and validation effects, and a finite timeout; it may not issue new retrieval calls. Failure to assemble records a typed output-omission reason.
- Temporal verifies the persisted Effective Run Configuration digest and Run Input Manifest reference before the first substantive stage. Mismatch fails safely.
- Continue-As-New is not needed for the bounded StageGraph fixture; history limits and counters are still measured so the GoalDirected extension can add it without changing domain records.

### Read-only adapter contracts

- Every adapter is project-owned, typed, independently versioned, and selected by the Effective Run Configuration. Agents never receive raw database clients.
- The Neo4j adapter supports only declared exact lookup, full-text search, vector search when an admitted index exists, bounded neighborhood traversal, and validated schema-aware Cypher.
- Neo4j access uses a read-only principal, driver read session and transaction mode, explicit database, timeout, maximum rows, maximum path depth, parameter-size limits, and an allowlist of read procedures and indexes.
- Cypher validation rejects write, schema, administrative, import, periodic, trigger, dynamic-procedure, and unrestricted procedure calls. It rejects unbounded variable-length traversal, missing result limits, multiple statements, and unsupported query shapes.
- Runtime summary counters are inspected when available; any reported update or schema-write count is a Workflow Invariant violation and fails the run while preserving evidence.
- The prior-work adapter exposes typed searches and exact record retrieval over read projections. It cannot issue lifecycle commands or mutate documents.
- Adapter responses use the common Knowledge Retrieval Observation envelope. Provider-native rank, score, score semantics, index identity/version, request, filters, timing, truncation, and error state are mandatory where available.
- Read-only adapter instrumentation emits an auditable call ledger. The deployment-hash rejection path must leave this ledger empty for graph calls.

### Fixture and result behavior

- The first vertical slice ships with a deterministic acceptance fixture accessible through the same adapter interfaces as production.
- The fixture contains at least one exact stable-identifier match, one alias match, one deliberately ambiguous alias with multiple candidates, and one no-match referent.
- The fixture contains Assertions that appear lexically conflicting but differ in a material temporal, jurisdictional, population, dose, or formulation dimension and therefore form a contextual non-contradiction.
- The fixture contains one separate overlapping proposition pair eligible to remain a contradiction candidate, proving that false-positive control does not suppress real candidates.
- The fixture contains one required coverage cell whose expected record is intentionally absent across all admitted and executed tactics. The output is a true fixture-level missing cell represented as `bounded_non_discovery`, with no universal absence claim.
- The fixture contains prior Workflow Run records and outputs relevant to one target.
- Full-text and vector results carry distinct native rank and score semantics. Snapshot and API responses must preserve them exactly while storing BellLabs reranking separately.
- The fixture records every adapter invocation and rejects writes, allowing the highest-seam tests to assert both expected reads and zero writes.

### Persistence and events

- Shared Workflow Run lifecycle, command idempotency, outbox, budget, and projection records use PostgreSQL authority. Knowledge Preflight documents use the document authority defined by the first specification. Large immutable payloads and rendered reports use object storage.
- A domain document write cannot independently advance Workflow Run lifecycle. Activities return typed facts or commands to the application lifecycle reducer.
- The lifecycle reducer validates the exact Terminalization Proposal, matrix revision, evidence digests, pending links/waits, and output references before assigning outcome. A stale or incomplete proposal causes reevaluation or rejection, never direct Temporal terminalization.
- Durable events cover accepted run, execution started, stage/branch state changed, observation recorded, coverage revised, candidate summary changed, snapshot available, report available, cancellation requested, and run terminal.
- Events are versioned, delivered at least once, and consumed idempotently. Aggregate ordering is enforced by aggregate version; no global order is assumed.
- Sensitive raw query payloads and records are stored by reference or redacted according to policy. Public projections expose only authorized summaries.

## Testing Decisions

- The highest practical seam is an HTTP-level black-box acceptance test that submits the fixture Run Request to FastAPI, allows the real Temporal worker and persistence services to execute against instrumented read-only fixture adapters, waits through the public run query, and asserts the final public snapshot/report projections plus adapter call ledger.
- The principal happy-path acceptance test must prove, in one run, known stable-identifier matches, alias matches, preserved ambiguity, prior-run discovery, contextual non-contradictions, a contradiction candidate, the intentionally missing required fixture cell classified as bounded non-discovery, exact native-score preservation, completed coverage, and zero writes.
- A separate highest-seam rejection test submits a deliberately mismatched Schema Deployment Manifest and asserts request rejection, no Workflow Run, no Temporal execution, no credential resolution, and zero graph-adapter calls.
- A no-write acceptance test supplies read-only fixture adapters that fail immediately on any mutation request and records query modes; it asserts only allowed reads across the complete run.
- API idempotency tests repeat the same request and observe one run, then reuse the key with a changed payload and observe conflict.
- Temporal replay tests execute recorded histories or the framework replay facility to prove deterministic Workflow behavior.
- Activity retry tests inject a transient failure after a side effect and prove idempotent recovery with one semantic observation and no duplicate snapshot.
- Branch degradation tests fail a degradable modality and assert `partially_completed`, explicit degradation, preserved successful observations, and a valid partial snapshot.
- Required-branch tests fail a required coverage path and assert `failed`, explicit unmet cells, and no false completed result.
- Cancellation tests cancel during retrieval and assert durable cancellation, no newly scheduled work, bounded finalization, and any partial snapshot labeled with omissions.
- Query-safety contract tests submit representative write, schema, admin, multi-statement, unrestricted procedure, and unbounded traversal queries and assert rejection before adapter execution.
- Native-evidence tests use differing lexical and vector score scales and prove byte-for-byte preservation of score values and semantics through observation, snapshot, and API serialization.
- Contextual-contradiction tests vary one context dimension at a time and assert non-contradiction explanations; overlapping contexts remain eligible contradiction candidates.
- Bounded-gap tests remove one tactic or stopping record and assert that no gap is accepted, then restore complete bounded evidence and assert `bounded_non_discovery`.
- Authorization tests prove that callers cannot request ungranted modalities or read another tenant's run projections, observations, raw evidence, or report.
- Socket tests treat realtime as hints: disconnect, execute changes, reconnect, resume from a durable cursor, and verify query projections recover all state.
- Contract tests verify stable error codes, resource schema versions, pagination, aggregate versions, and backward-compatible serialization.
- Existing simple health tests remain smoke tests only; they do not count as acceptance of Knowledge Preflight behavior.

## Out of Scope

- GoalDirectedPreflight, adaptive iteration selection, Goal Revisions, independent convergence verification, affected-subgraph reruns, sandbox snapshots, and Continue-As-New.
- Enabled StageGraph semantic cycles, whole-workflow cycles, linked Workflow Runs, linked-result admission, or operator budget-extension decisions.
- Production dashboard, rich Socket.IO progress UI, and token streaming.
- General implementation of the shared Workflow Type/control-profile/configuration catalogs beyond the exact published fixture needed by this slice.
- Shared Schema Catalog generation, schema-selection workflow, deterministic schema expansion, Schema Workspace physical materialization internals, and production of Schema Deployment Manifests.
- Graph identity resolution, graph repair, ingestion planning, ingestion execution, Assertion adjudication, or any Neo4j write.
- Production retrieval quality tuning, broad graph-wide scans, arbitrary agent-authored Cypher, and unrestricted prior-work search.
- Permanent event-broker selection; the accepted transport-neutral outbox boundary is sufficient for this slice.

## Further Notes

- Dependency order: this specification depends on the deterministic-core specification; all four control-plane foundation specifications; Schema Catalog/Deployment Manifest/Workspace Materialization; and the canonical conversation/durable-realtime capability used by its public observation seam.
- The GoalDirected extension is the next dependent specification and must reuse these API, adapter, observation, snapshot, persistence, and Temporal boundaries.
- The implementation target's current clients and process bootstrap should be evolved into explicit gateway, worker, relay, and adapter roles. The existing sandbox probe is a feasibility check, not the workflow topology.
- Prior graph implementation demonstrates deterministic schema expansion, schema-card navigation, typed searches, and guarded read-only Cypher. It is prior art only; Knowledge Preflight must remove ingestion writes, strengthen query validation, bind deployment hashes, preserve native evidence, and persist application-owned domain records.
