# Governed Workflow and Mission Memory

## Problem Statement

SDK session history and sandbox notes can preserve short-lived context, but they cannot safely provide reusable memory across threads, operations, Workflow Runs, or Knowledge Production Missions. Without an application-owned memory subsystem, retrieval may leak across tenants or scopes, stale or contradictory notes may be injected as truth, agents may write directly into a durable corpus, and compaction can erase provenance. Volume alone can look like learning even when memory harms downstream work.

## Solution

Build governed episodic, semantic, and procedural memory across operational and domain planes, partitioned into typed tenant-owned Memory Spaces and controlled by immutable Memory Policy revisions. Retrieve through authorization-first exact, lexical, and vector search with policy-bound fusion, utility filtering, contradiction and staleness handling, and a strict context budget. Record every candidate, exclusion, selected item revision, and exact injected representation. Accept agent output only as Memory Write Proposals; consolidate and promote through reviewed decisions. Materialize immutable, read-only Mission Memory Packs with generated operating guidance and provenance manifests. Memory, retrieved context, pack files, and learned procedures remain advisory and non-authoritative.

## User Stories

1. As a workflow operator, I want durable memory separate from SDK sessions, so that useful knowledge survives session compaction without making sessions canonical.
2. As a tenant administrator, I want every Memory Space and Memory Item tenant-scoped, so that memory cannot leak across organizations.
3. As a mission coordinator, I want a mission Memory Space, so that related Workflow Runs can reuse governed context under one policy.
4. As a workflow author, I want system, product, Workflow Type, mission, Workflow Run, stage, thread, organization, and user scopes, so that inheritance is explicit.
5. As a workflow author, I want episodic memory of prior work, decisions, outcomes, failures, and evaluations, so that later work can avoid repetition.
6. As a researcher, I want semantic memory to preserve claims with evidence, confidence, temporal validity, and contradiction state, so that reusable context does not masquerade as settled fact.
7. As an operator, I want procedural memory to preserve learned methods and preferences, so that recurring execution can improve under review.
8. As a system architect, I want operational and domain memory planes separated, so that tooling observations cannot silently become scientific claims.
9. As an auditor, I want each item to preserve provenance, derivation, producer binding, review state, sensitivity, retention, valid time, system time, supersession, and tombstone state, so that use is explainable.
10. As a workflow author, I want a versioned Memory Policy bound into the Effective Run Configuration, so that retrieval and writing cannot drift during a run.
11. As a workflow author, I want readable and writable scopes, namespaces, kinds, and planes declared independently, so that read access does not imply write access.
12. As an operation, I want run-snapshot, stage-snapshot, or latest-at-operation consistency selected explicitly, so that corpus changes have predictable effects.
13. As an operation, I want exact identifiers, lexical search, and vector search fused under structured filters, so that retrieval balances precision and recall.
14. As a security operator, I want tenant, authorization, scope, namespace, validity, sensitivity, and policy filters applied before ranking, so that forbidden items never enter the candidate set.
15. As an agent, I want retrieved context limited to the smallest useful provenance-bearing set, so that context remains focused and auditable.
16. As an auditor, I want every retrieval to record query, policy, candidate IDs and scores, selected revisions, exclusions, reranking, and corpus position, so that later changes do not erase what happened.
17. As an auditor, I want every injection to record the exact representation, ordering, labels, truncation, and digest, so that model input can be reproduced.
18. As a workflow operator, I want stale, redundant, weakly sourced, contradictory, or low-utility memory suppressed or labeled, so that retrieval quality is policy-driven.
19. As a researcher, I want contradictions preserved rather than overwritten, so that contested domain context remains visible.
20. As an agent, I want to submit a Memory Write Proposal instead of mutating memory directly, so that generated observations receive policy and review.
21. As a reviewer, I want write proposals to identify sources, scope, kind, plane, confidence, sensitivity, and intended retention, so that acceptance is informed.
22. As a reviewer, I want acceptance, rejection, revision, deferral, and duplicate outcomes recorded immutably, so that memory curation is auditable.
23. As a memory manager, I want source episodes preserved when deriving semantic or procedural candidates, so that consolidation never destroys provenance.
24. As a memory manager, I want consolidation to detect duplicates, supersession, contradiction, and temporal change, so that derived memory remains coherent.
25. As a governance owner, I want stable high-impact procedures promoted into reviewed prompts, Agent Skills, operating rules, or policy revisions, so that procedural authority is not hidden in memory.
26. As a governance owner, I want consequential domain claims to require configured independent or human review, so that memory cannot bypass knowledge governance.
27. As a sandbox agent, I want an immutable Mission Memory Pack materialized read-only, so that useful mission context is available through files without granting write authority.
28. As a sandbox agent, I want generated operating guidance and navigation in the pack, so that I can use selected memory efficiently.
29. As an auditor, I want the pack manifest to identify every item revision, source, scope, file digest, policy, and build decision, so that pack contents are reproducible.
30. As a workflow operator, I want snapshot restore to rebind the exact pack or an explicitly authorized successor, so that restored files do not silently change context.
31. As a workflow operator, I want workspace notes to remain local candidates until proposed and accepted, so that sandbox persistence is not durable memory.
32. As an evaluator, I want tests and metrics for retrieval relevance, identifier recall, provenance, leakage, stale resistance, consolidation precision, context cost, and downstream success, so that memory effectiveness is measured.
33. As an evaluator, I want unused or harmful memory suppressible, expirable, revisable, or tombstoned, so that accumulation is not treated as improvement.
34. As a data steward, I want retention, deletion, tombstone, and legal-hold behavior applied without rewriting historical retrieval audits, so that governance and audit can coexist.
35. As a security operator, I want row-level security and application authorization on every memory read and write path, so that prompt instructions cannot bypass isolation.
36. As an implementation agent, I want invalid policy revisions, unauthorized scopes, stale snapshots, digest mismatches, and conflicting proposals to yield typed outcomes, so that edge behavior is not invented.

## Implementation Decisions

- Memory is an application-owned subsystem distinct from canonical Conversations, SDK sessions, Temporal history, sandbox files, Workflow Run state, approved artifacts, and Neo4j knowledge.
- PostgreSQL is authoritative for Memory Spaces, Memory Policy revisions, Memory Items, sources, links, embeddings metadata, write proposals, retrievals, injections, consolidation decisions, pack metadata, review state, and authorization projections.
- Object storage holds large immutable memory payloads and Mission Memory Pack files. PostgreSQL records their content digests, durable references, and governance metadata.
- Memory kinds are episodic, semantic, and procedural. Planes are operational and domain. Kind and plane are orthogonal and mandatory.
- Every Memory Item belongs to one tenant and typed Memory Space. It records namespace, scope, content or durable reference, keywords, provenance and derivation links, producer binding, confidence basis, review state, sensitivity, retention class, valid time, system time, supersession, contradiction links, and tombstone state.
- Operational observations cannot become domain claims merely through consolidation. A governed proposal and configured review decision are required.
- Semantic memory preserves evidence, uncertainty, temporal validity, and contradiction. It is not an Adjudication or approved canonical graph fact.
- Procedural memory is advisory. Stable high-impact procedures move through an explicit proposal into reviewed Prompt, Agent Skill, operating-rule, or policy revisions before they can govern execution.
- Memory Policy revisions are immutable and exact references are frozen into the Effective Run Configuration. A policy declares readable and writable scopes, inheritance and precedence, consistency mode, filters, retrieval strategy, reranking, deduplication, context budget, write review, consolidation, contradiction, sensitivity, retention, deletion, pack materialization, and evaluation thresholds.
- Policy inheritance cannot broaden the run's frozen memory envelope. The effective permission is the intersection of tenant policy, Workflow Type contract, caller authority, Agent Profile, Delegation Ceiling, data classification, and operation binding.
- Consistency mode is explicit: run snapshot freezes a corpus position for the run, stage snapshot freezes one for a stage, and latest-at-operation resolves a fresh authorized position. The chosen position is recorded on retrieval.
- Retrieval applies hard tenant, authorization, scope, namespace, validity, sensitivity, review-state, and policy filters inside the query before ranking.
- Candidate generation combines exact identifier lookup, lexical or full-text search, and vector similarity. Rankings remain separately observable and are fused and reranked under the bound policy; heterogeneous scores are not presented as one universal truth score.
- Retrieval rejects or labels stale, redundant, contradictory, weakly sourced, and low-utility candidates according to policy. Contradictory items are preserved and may be jointly injected when needed.
- The selected set is the smallest provenance-bearing set expected to improve the declared operation under the token and item budgets. Memory volume is never a success criterion.
- Every Memory Retrieval is immutable and records query, policy revision, corpus position, candidate revisions and component scores, hard-filter exclusions, reranking, selected revisions, final order, and decision rationale.
- Every Memory Injection is immutable and records target operation and model input, exact rendered representation, labels marking memory as untrusted context, truncation or compaction, item revision references, ordering, token estimate, and digest.
- Memory retrieval or injected text cannot grant capabilities, authorize commands, broaden goals, change budgets, establish completion, or override workflow invariants.
- Agents and runtime hooks may only create Memory Write Proposals. They cannot insert, revise, supersede, consolidate, or tombstone authoritative Memory Items directly.
- Proposal decisions are immutable and policy-driven. Acceptance creates a new item revision or link; it never rewrites the proposal or source episode.
- Consolidation runs are bounded, idempotent, and fully audited. They preserve source episodes, emit candidate semantic or procedural items, and require the configured review class before activation.
- Mission Memory Pack materialization is a shared application operation. It selects accepted revisions under policy, creates generated operating guidance plus bounded memory files, writes a machine-readable provenance manifest, stores the immutable bundle, updates the Workspace Materialization Manifest, and emits an immutable pack revision and binding.
- Packs are read-only. Generated operating guidance contains bounded navigation and advisory operating context, not a writable memory database or capability declaration.
- Pack idempotency binds mission or operation purpose, memory policy revision, corpus position, selected item revisions, rendering version, and materialization policy. Changed memory or policy creates a new pack revision.
- Snapshot restore reuses the exact pack by default. An authorized successor requires an explicit compatibility and applicability decision recorded on the new workspace binding.
- Tombstoned content is excluded from new retrieval unless an explicitly authorized audit purpose permits it. Historical retrieval and injection records retain item identity and governance-safe evidence even when content access is restricted.
- PostgreSQL full-text, exact or trigram identifiers, pgvector, and correctly matched vector indexes support hybrid retrieval. Row-level security is mandatory defense in depth.
- Retrieval, proposal review, consolidation, embedding, and pack materialization execute through application services and nondeterministic Temporal activities. Temporal Workflow code carries only immutable references and compact decisions.

## Testing Decisions

- The highest practical behavioral seam is one authorized memory application API exercised through an operation-preparation scenario: create governed items, perform hybrid retrieval, record an injection, submit and review a write proposal, consolidate, and materialize a Mission Memory Pack. Tests use a transactional PostgreSQL test database, vector-capable search, object storage test adapter, and temporary read-only workspace.
- Isolation tests seed similar memory in multiple tenants, missions, runs, threads, namespaces, and sensitivity classes and prove unauthorized candidates never appear in retrieval audit candidate sets.
- Retrieval tests cover exact identifiers, lexical matches, vector matches, hybrid fusion, structured filters, reranking, deduplication, contradiction preservation, staleness rejection, token limits, and stable snapshot positions.
- Injection tests verify exact rendered text, item revisions, order, provenance labels, truncation decisions, digest, and target binding. They also prove injected instructions cannot enlarge exposed tools or accepted authority.
- Proposal tests prove agents cannot write directly, duplicate proposals converge idempotently, conflicting reuse fails, review authority is enforced, and accepted proposals preserve source episodes and derivation.
- Consolidation tests cover duplicate merge proposals, temporal successors, contradictions, procedural candidates, domain-claim review requirements, partial failure, retry, and preservation of all source lineage.
- Pack tests verify deterministic contents, immutable revisions, read-only materialization, complete manifest lineage, object digest verification, workspace mapping, exact-pack restore, and explicit successor authorization.
- Retention tests cover expiry, tombstone, sensitivity reclassification, deletion restrictions, legal hold, historical audit reads, and exclusion from future retrieval.
- Evaluation tests use labeled retrieval cases and downstream operation fixtures to measure identifier recall, relevance, provenance correctness, unauthorized leakage, stale resistance, write precision, consolidation precision, context cost, and task improvement separately.
- Adversarial tests place capability requests, workflow commands, false authority claims, and prompt injection inside memory content and prove they remain inert context.
- Prior art is the existing async PostgreSQL, MongoDB, object-storage, Temporal, and sandbox infrastructure. The new tests deliberately exercise their composition at the externally visible memory-operation boundary rather than client wrappers.
- Tests avoid assertions about SQL table names, exact ranking formulas, embedding dimensions, internal manager classes, or pack filesystem layout.

## Out of Scope

- Making memory a canonical scientific knowledge base.
- Direct Neo4j mutation or graph promotion from memory.
- Replacing Conversations or SDK sessions.
- Automatically publishing prompts, Agent Skills, policies, or operating rules from procedural memory.
- Choosing final embedding models, dimensions, fusion weights, or index tuning.
- Workflow-specific memory namespaces, retention durations, token budgets, and review thresholds beyond requiring typed policy.
- General document or Source Corpus retrieval.
- Dashboard implementation.
- Using memory volume as an evaluation target.

## Further Notes

- Dependency order: this spec depends on canonical identity and authorization services and on the Effective Run Configuration and Operation Execution Binding contracts. It should follow the conversation foundation when thread-scoped or coordinator-facing audit is included.
- Mission Memory Pack materialization should use the same workspace ownership and manifest conventions as Schema Workspace Materialization, but it does not require schema resources.
- The capability-catalog spec depends on this spec only when catalog evaluation or selection uses durable memory; its core quarantine and exact-binding path can be implemented independently.
- Memory, retrieved context, generated pack guidance, workspace notes, and consolidation proposals are non-authoritative. Their value is evaluated through provenance-bearing downstream improvement, not presumed.
