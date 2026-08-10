## Problem Statement

The research ingestion and evaluation service has connectivity for MongoDB, PostgreSQL, Temporal, object storage, Neo4j, FastAPI, and the OpenAI Agents SDK, but it has no application model for publishing Workflow Types or compiling a reproducible run configuration. Without that foundation, mutable aliases, caller overlays, deployment availability, prompts, or runtime defaults could accidentally determine workflow topology, authority, budgets, or completion behavior after a run has started.

The system needs a strict boundary between authored definitions and executable configuration. Operators and later workflow specifications must be able to publish immutable definitions, select one allowed blueprint revision, resolve all authorized configuration layers once, and obtain a content-addressed Effective Run Configuration that execution can consume without rereading mutable aliases. This boundary must preserve the accepted persistence split: MongoDB/Beanie is authoritative for definition revisions and compiled configuration documents, while PostgreSQL remains authoritative for transactional run admission and lifecycle in the dependent specification.

## Solution

Introduce separately versioned, strict definition families for Workflow Types, Workflow Execution Blueprints, control profiles, runtime profiles, workspace templates, evaluation profiles, and workflow-specific configuration. Publish immutable revisions in MongoDB/Beanie and maintain mutable authoring heads separately from published content.

Build a pure configuration compiler that accepts exact definition revisions, caller and parent authority context, environment availability, an immutable Run Input Manifest reference, and a typed run overlay. The compiler selects exactly one blueprint revision already allowed by the Workflow Type, validates all cross-references and invariants, intersects every applicable ceiling, and emits an immutable Effective Run Configuration with canonical serialization, digest, compiler version, source references, exact runtime bindings, linked-run slot constraints, and accepted and rejected overlay decisions.

The Effective Run Configuration is the only executable configuration for a run. Mutable aliases are resolved before compilation and retained only as resolution evidence. Published revisions, compiled snapshots, and compiler decisions are never edited in place.

## User Stories

1. As a workflow author, I want to create a draft Workflow Type revision, so that I can validate a proposed contract before publication.
2. As a workflow publisher, I want publication to create an immutable revision, so that later edits cannot change previously compiled runs.
3. As a workflow publisher, I want a Workflow Type revision to declare its purpose, non-goals, Input Admission Contract, Workflow Invariants, obligations, output contracts, authority rules, and workspace contract, so that execution cannot infer those semantics.
4. As a workflow publisher, I want a Workflow Type revision to enumerate allowed blueprint revisions, so that a control profile cannot invent topology.
5. As a blueprint author, I want to publish a discriminated StageGraph or GoalDirected blueprint revision, so that the compiler can validate the correct family-specific contract.
6. As a blueprint author, I want structural references to be validated at publication, so that missing stages, duplicate identities, cycles in dependency edges, or undeclared output slots cannot reach execution.
7. As a control-profile author, I want to select only declared variants and defaults, so that runtime controls remain inside the Workflow Type contract.
8. As a workspace author, I want a versioned Workspace Template and Workflow Workspace Contract, so that logical slots, ownership, access, and promotion expectations are fixed before execution.
9. As a runtime operator, I want runtime profiles to declare compatibility requirements rather than host-specific assumptions, so that unsupported bindings fail explicitly.
10. As an evaluation author, I want evaluation profiles pinned by exact revision and digest, so that completion gates cannot change during a run.
11. As an API caller, I want to refer to a stable alias when allowed, so that starting common workflows is convenient.
12. As an auditor, I want every alias resolved to an exact immutable revision before compilation, so that later alias movement has no effect on an accepted run.
13. As a caller, I want to propose a typed run overlay, so that permitted per-run choices can be expressed without editing shared definitions.
14. As a security operator, I want unknown overlay fields rejected, so that misspellings or undeclared extensions cannot silently alter execution.
15. As a security operator, I want overlay authority intersected with caller permissions and parent delegation ceilings, so that configuration cannot grant capabilities.
16. As a workflow author, I want overlayable, fixed, and strengthen-only fields declared explicitly, so that weakening invariants or acceptance rules is impossible.
17. As a caller, I want accepted, rejected, degraded, and omitted overlay decisions explained, so that the effective result is understandable.
18. As an execution worker, I want one complete Effective Run Configuration, so that I do not need mutable catalog reads while orchestrating work.
19. As a Temporal workflow, I want an immutable payload or immutable reference plus digest, so that replay observes the same configuration.
20. As an operator, I want identical canonical inputs compiled by the same compiler version to produce the same digest, so that configuration identity is stable.
21. As an auditor, I want source logical identities, revisions, digests, and compiler decisions preserved, so that the snapshot can be reconstructed and explained.
22. As a workflow-specific implementer, I want namespaced, discriminator-validated extension contracts, so that domain configuration can evolve without unvalidated arbitrary dictionaries.
23. As an operator, I want required environment capabilities checked during compilation, so that an unavailable runtime, sandbox class, or governed asset causes a declared failure or degradation before work starts.
24. As a security operator, I want secrets represented only by references, so that compiled documents and Temporal inputs never contain secret values.
25. As a workflow author, I want linked-run slots frozen as parent-side constraints, so that later child requests cannot invent dependency, authority, budget, wait, cancellation, or result-admission behavior.
26. As a child-run caller, I want each child to compile independently from its own exact definitions, so that the parent snapshot does not embed or override a possible child’s standalone contract.
27. As an operator, I want publishing and compiling to reject ambiguous references, so that selection never depends on database ordering.
28. As an operator, I want retired revisions to remain readable for historical runs, so that retirement blocks future selection without deleting evidence.
29. As an API client, I want generated schemas derived from the same strict models used by the compiler, so that authoring validation and server validation do not drift.
30. As a maintainer, I want the initial infrastructure marker to remain non-domain bootstrap data, so that it is not mistaken for a definition or migration strategy.

## Implementation Decisions

- Use strict, extra-forbidden, versioned Pydantic contracts for every executable definition and compiled record. Use discriminated unions for blueprint families and other variant-bearing policies. Executable extension payloads require a namespace, schema version, discriminator, and registered validator.
- Store immutable published revisions and mutable authoring heads as separate MongoDB/Beanie record families. Published identity is the stable logical identity, monotonically increasing revision, and canonical digest; Beanie optimistic revision support applies only to mutable heads.
- A Workflow Type revision owns domain authority: admission contract, invariants, obligation and output vocabularies, allowed blueprint revisions, operation and linked-workflow boundaries, evaluation requirements, and workspace and promotion contract.
- A Workflow Execution Blueprint revision owns one top-level family. The first architecture permits exactly `StageGraph` and `GoalDirected`. A run binds exactly one exact blueprint revision, and controls may select only variants declared by that revision.
- Keep control, runtime, workspace-template, evaluation, memory-policy, agent-profile, capability-selection, prompt, skill, MCP, and plugin/package assets as distinct versioned families. This specification establishes their reference and compilation boundaries; detailed catalog behavior belongs to its own capability specifications.
- Resolve mutable aliases once, before pure compilation. Compilation inputs contain exact revisions and digests; aliases and head pointers are lineage evidence only.
- The compiler has no database, clock, network, secret-store, or runtime side effects. An application service gathers exact inputs and an explicit compilation time/actor context, calls the compiler, and persists the result.
- Canonical serialization is schema-versioned and deterministic. It normalizes field ordering and semantically ordered collections without reordering collections whose order has domain meaning. The digest covers the complete executable payload and excludes storage-generated identifiers that do not affect meaning.
- The Effective Run Configuration records its schema version, compiler version, digest, compilation identity and time, exact source references, selected blueprint, resolved workflow-specific configuration, resolved workspace and runtime contracts, evaluation bindings, authority and capability intersections, budget and concurrency ceilings, Run Input Manifest reference, linked-run slot constraints, and every overlay decision.
- The compiled snapshot retains enough resolved data for execution not to dereference mutable definitions. Large immutable subpayloads may be stored in object storage only through content-addressed references whose digests are part of the snapshot; MongoDB remains authoritative for the Effective Run Configuration metadata and compiler decision record.
- Caller authority, permissions, environment availability, and parent ceilings constrain configuration but never originate workflow authority. Prompt text, conversation content, deployment availability, and attached assets cannot grant capabilities or alter topology.
- Rejected unknown, ambiguous, unauthorized, incompatible, or invariant-weakening overlays fail compilation unless the authored requirement explicitly classifies the field as degradable or optional and defines the resulting omission or degradation. There is no silent substitution.
- The parent snapshot freezes linked-run slots, request revision rules, allowed child Workflow Types and revision/profile policies, dependency classes, parent-side wait/timeout/cancellation/result-admission behavior, delegation ceilings, and budget-reservation ceilings. It does not precompile child Effective Run Configurations.
- Every accepted child Run Request invokes the same compiler independently against exact child definitions and the frozen parent constraints. The child snapshot records the governing intersection and Run Composition Link reference.
- Publication validation and compilation validation are distinct. Publication proves internal definition integrity and resolvability under declared conditions; compilation proves one concrete invocation is admissible under current exact authority and availability inputs.
- PostgreSQL does not own authored definitions or Effective Run Configuration payloads. It stores only transactional references, digests, admission decisions, and current effective-configuration pointers introduced by later specifications.
- Temporal does not compile configuration and does not query MongoDB. It receives a verified immutable payload or reference and digest after transactional admission.
- Object storage owns large immutable compiled payloads when externalization is required. Neo4j has no role in configuration authority; graph schema compatibility is consumed as an exact attested input where a workflow requests graph access.
- The initial implementation must include one valid StageGraph fixture and one valid GoalDirected fixture, but it must not invent workflow-specific stages, obligations, gates, thresholds, or completion rules that their own specifications have not settled.
- Dependency note: this is specification 1 of 4. Transactional admission in specification 2 consumes compiler results; blueprint orchestration in specification 3 consumes the selected blueprint and linked-slot constraints; runtime binding in specification 4 consumes the resolved operation, workspace, authority, and runtime sections.

## Testing Decisions

- Test external behavior primarily through the configuration application service exposed to the command/API layer: publish revisions, resolve an invocation, compile it, retrieve the immutable snapshot, and compare public results. Unit tests of canonicalization and pure validation supplement this seam only for exhaustive malformed-input cases.
- Use real Pydantic contracts and repository implementations against disposable MongoDB for integration coverage. Do not mock model validation or assert internal helper calls.
- Prove that publishing a revision makes it immutable, moving an alias afterward does not alter a previously compiled snapshot, and retired revisions remain readable but are not selected for new alias-based invocations.
- Prove that identical exact inputs under the same compiler version produce byte-equivalent canonical payloads and the same digest, while a meaningfully changed input produces a different digest.
- Prove that order-insensitive authored collections canonicalize consistently and order-sensitive semantics remain preserved.
- Prove that missing, ambiguous, retired, digest-mismatched, or incompatible references fail with typed public decisions.
- Prove that StageGraph dependency cycles, missing dependencies, and undeclared structural variants are rejected before an Effective Run Configuration is persisted.
- Prove that a control profile cannot choose a blueprint not allowed by the Workflow Type and that a run cannot compile more than one top-level blueprint family.
- Prove that unknown overlay fields, attempts to weaken invariants or acceptance, and attempts to exceed caller or parent authority are rejected.
- Prove declared optional or degradable capability absence produces the exact authored omission or degradation decision and never a similarly named substitution.
- Prove secret values cannot be serialized into a published revision or Effective Run Configuration and only validated secret references are accepted.
- Prove the parent linked-run section freezes constraints without embedding a child snapshot, and that two children with different exact definitions compile independently under the same parent slot.
- Prove a compiled configuration can be loaded and digest-verified without reading mutable aliases or heads.
- Prove object-store externalization, when used, rejects payload or digest mismatch and still returns the same public configuration contract.
- Prove generated JSON Schema rejects the same invalid executable configuration as the server models.
- Avoid assertions about Beanie method calls, collection implementation details, internal compiler phases, or hash-library invocation; tests assert publication, compilation, immutability, decisions, and returned contracts.

## Out of Scope

- Transactional Run Request acceptance, Workflow Run creation, lifecycle phases, commands, outbox publication, and budget ledgers.
- Temporal scheduling, stage readiness, semantic cycles, GoalDirected iteration, linked-child execution, and Continue-As-New behavior.
- OpenAI Agents SDK execution, concrete tool invocation, MCP connection, delegation mechanics, sandbox provisioning, snapshots, and artifact promotion.
- Detailed prompt, Agent Skill, MCP server/tool, plugin/package, memory, and capability-catalog ingestion or promotion behavior.
- Workflow-specific stages, obligations, gates, outputs, evaluation thresholds, and default budget values.
- Dashboard implementation, Socket.IO projection behavior, and durable event-broker selection.
- Neo4j mutation or schema deployment. Configuration may bind exact compatibility attestations but never makes graph changes.
- Migration of any separate legacy research repository beyond using its established behavior as optional fixture evidence.

## Further Notes

- Dependency order is strict: implement this compiler foundation before transactional run admission. Admission must never create a Workflow Run that still depends on unresolved mutable configuration.
- The accepted system synthesis governs over the older control-plane proposal where they conflict. In particular, MongoDB/Beanie owns definitions and compiled configuration; PostgreSQL owns transactional run state and budgets; Temporal owns durable orchestration; object storage owns large immutable payloads; Neo4j owns only approved canonical graph knowledge.
- Deferred tuning choices include exact collection names, canonical serialization library, storage threshold for externalizing large snapshots, revision-retention periods, and publication workflow UX. These choices must not alter immutability, authority intersection, exact revision binding, deterministic compilation, or independent child compilation.
- Exact workflow-specific budget values, stages, gates, and evaluation thresholds remain deferred to the specifications that own those semantics. The compiler must require explicit values or explicit authored defaults; it may not invent them.
