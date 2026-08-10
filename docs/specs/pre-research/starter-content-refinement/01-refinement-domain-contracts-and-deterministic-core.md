# Refinement Domain Contracts and Deterministic Core

## Problem Statement

Starter Content is messy, multimodal, uncertain, and sometimes corrupt, but the current implementation is only an infrastructure bootstrap. It has no authoritative contracts for admitting immutable inputs, applying acquisition-specific permissions, distinguishing package inclusion from processing obligations, preserving findings and provisional seeds, accepting repairs, calculating staleness, or assembling immutable outputs. Without a deterministic core, workflow and agent code would be forced to invent domain authority, silently rewrite history, collapse uncertainty, or confuse successful execution with readiness for downstream use.

This specification establishes the shared domain foundation required by both refinement blueprint variants. It turns selected Starter Content into validated, immutable, versioned domain records without performing raw artifact capture, deep research, canonical identity resolution, scientific adjudication, or graph mutation.

## Solution

Build an application-owned deterministic refinement core around strict versioned contracts. The core admits an immutable Run Input Manifest, evaluates Permission Assessments and a Refinement Obligation Matrix, validates typed findings and provisional seeds, records repair proposals separately from Repair Decisions, computes dependency-scoped staleness, assembles a manifest-style Starter Package, produces purpose-relative Starter Readiness Assessments, and validates a separate Decision Report.

The core is blueprint-independent. StageGraph and GoalDirected execution use the same admission rules, invariants, authorities, output schemas, and completion semantics. Agents may propose classifications, findings, seeds, repair candidates, readiness observations, and report prose, but only deterministic application services may accept those proposals into current domain state or declare package structure valid.

## User Stories

1. As an operator, I want to start refinement from one or more already captured Starter Artifacts, so that messy material can be clarified without first creating a mission.
2. As an operator, I want to refine an exact immutable selection from a mutable Starter Collection, so that later collection edits cannot change a running workflow.
3. As an operator, I want to refine prior Starter Packages together with direct captured artifacts, so that package lineage can represent merges, splits, reuse, and replacement.
4. As a caller, I want artifact-free intent rejected as package input, so that an Intake Brief or Mission Specification path is used instead of emitting an empty package.
5. As a compliance reviewer, I want Permission Assessments evaluated per acquisition path and capability, so that identical bytes never transfer rights between distinct artifact occurrences.
6. As a compliance reviewer, I want unknown, review-required, conditioned, and prohibited permission outcomes preserved distinctly, so that uncertainty is never treated as permission.
7. As a workflow author, I want package inclusion separated from Processing Obligations, so that an unreadable artifact can remain in a valid package without implying every operation succeeded.
8. As a workflow author, I want each obligation cell classified as required, degradable, optional, or prohibited, so that completion and partial completion are mechanically explainable.
9. As an operator, I want obligation revisions to preserve prior cells, authority, rationale, budget effect, and invalidation effect, so that changing future work does not rewrite the accepted baseline.
10. As an artifact reviewer, I want each Package Artifact Reference to carry controlled roles, rationale, grouping, ordering, and inclusion requirement, so that contextual use is explicit.
11. As an artifact reviewer, I want corrupt, unsupported, unavailable, or prohibited regions represented as valid findings, so that difficult inputs are not silently dropped.
12. As a downstream workflow, I want every Starter Finding to separate severity, confidence, review state, evidence, and downstream implications, so that one overloaded status does not dictate all uses.
13. As an evaluator, I want finding confidence to record its method and basis, so that uncalibrated model percentages cannot masquerade as probabilities.
14. As a reviewer, I want proceeding despite a valid finding represented as a policy decision rather than a finding review state, so that evidence state remains honest.
15. As a research planner, I want Seed Mentions to retain exact artifact or media-region locators, so that every provisional signal remains traceable.
16. As a research planner, I want Entity Seeds, Assertion Seeds, Evidence Question Seeds, and Source Leads represented as provisional groupings, so that extraction does not become accepted knowledge or executable instruction.
17. As an evaluator, I want seed detection, typing, grouping, and normalized-interpretation confidence kept separate, so that ambiguity is preserved.
18. As an evaluator, I want extraction coverage assessed independently from seed count, so that zero seeds is valid only after sufficient coverage.
19. As an operator, I want repair generation separated from repair acceptance, so that a candidate cannot silently supersede original material.
20. As an operator, I want a Repair Decision to activate a replacement, retain a companion, or reject a candidate, so that each repair has explicit authority and consequence.
21. As a reviewer, I want inferred missing content without adequate source evidence labeled as a Reconstruction Hypothesis, so that invented material cannot become a faithful repair.
22. As an operator, I want required pending Repair Decisions to create a durable wait with a configured timeout or fallback, so that approval survives process restarts.
23. As an auditor, I want originals, candidates, rejected repairs, accepted repairs, and prior selections preserved immutably, so that historical reasoning remains reconstructable.
24. As a workflow coordinator, I want accepted replacements to calculate a dependency frontier, so that only affected findings, seeds, representations, readiness conclusions, and reports become stale.
25. As an auditor, I want stale derived outputs retained and queryable but excluded from current assembly, so that history is preserved without contaminating current results.
26. As an operator, I want a Starter Package assembled deterministically from admitted current references and typed decisions, so that an agent cannot declare invalid state valid.
27. As a downstream workflow, I want every Starter Package to contain at least one captured Starter Artifact reference and complete lineage, so that package identity remains grounded in actual material.
28. As a downstream workflow, I want unreadable artifacts allowed in a structurally valid package, so that package validity does not imply content usability.
29. As a downstream workflow, I want a purpose-relative Starter Readiness Assessment, so that the same package may block one use, warn another, or require another dependency.
30. As an operator, I want readiness to list blockers, warnings, conditions, missing work, stale context, and freshness needs, so that downstream decisions are inspectable.
31. As an auditor, I want the Decision Report versioned separately from the Starter Package, so that narrative explanation never substitutes for structured output.
32. As an improvement owner, I want the Decision Report to preserve alternatives, failures, degradation, tool use, repairs, uncertainty, quality limits, and Improvement Candidates, so that workflow learning is actionable.
33. As a control-plane service, I want execution outcome separated from output readiness, so that a completed run may still be unready for a specific use and a failed run may retain a valid package.
34. As a control-plane service, I want exactly four terminal outcomes, so that completed, partially completed, failed, and cancelled retain stable meanings.
35. As an API consumer, I want immutable record identities, revisions, digests, and lineage references returned consistently, so that caching, replay, and conflict detection are reliable.
36. As a tenant administrator, I want every domain read and decision scoped by tenant and actor authority, so that cross-scope leakage cannot occur.
37. As a developer, I want the deterministic core callable without Temporal or an agent runtime, so that rules can be tested quickly and reused by both blueprints.
38. As an evaluator, I want invalid free-form extension payloads rejected unless they carry a registered namespaced discriminator, so that executable contracts never depend on unvalidated arbitrary dictionaries.

## Implementation Decisions

- The first delivery is a strict Pydantic domain and application-service layer. It remains independently executable from orchestration and has no dependency on an agent session.
- Stable logical identity, immutable revision, canonical serialization, schema version, content digest, tenant, producer binding, creation time, and lineage are common metadata for immutable records.
- The Run Input Manifest accepts exact references to captured Starter Artifacts, immutable Starter Collection selections, prior Starter Packages, optional Intake Brief revision, explicit or default Refinement Directive, accepted reusable output references, Permission Assessments, and configuration bindings.
- Admission requires at least one captured Starter Artifact directly or through a prior package; resolvable immutable content or an explicit captured-but-unavailable state; sufficient acquisition and derivation lineage; applicable permissions; no prohibited required operation; a valid directive and allowed blueprint; a compatible Effective Run Configuration; and sufficient required-baseline budget or a policy-approved constrained baseline.
- A captured corrupt or unavailable artifact passes artifact-presence admission when identity and lineage are valid. It produces integrity and coverage consequences rather than an automatic run rejection.
- Permission capabilities use the accepted atomic vocabulary. Outcomes are `allowed`, `allowed_with_conditions`, `requires_review`, `unknown`, and `prohibited`. Conditions are machine-addressable and retain evidence, jurisdiction, assessor, method, policy revision, review status, and expiry.
- Artifact Content may be content-address deduplicated, but Starter Artifact occurrence, provenance, permission context, and intake identity remain distinct.
- Package Artifact References use one controlled primary role plus optional controlled secondary roles. The initial role vocabulary is the accepted eight-role set. Namespaced extensions may be preserved but cannot affect behavior until registered for the Workflow Type revision.
- The Refinement Obligation Matrix addresses exact subject, modality or region, operation class, obligation status, coverage expectation, completion evidence, stopping evidence, budget allocation, and current outcome.
- Required obligations determine success. The core emits a Terminalization Proposal over exact obligation, package, readiness, and report revisions; only the shared lifecycle reducer assigns outcome. A failed degradable obligation permits a `partially_completed` proposal when required obligations and output invariants are satisfied. Optional omission does not degrade the run. Prohibited work is rejected before execution.
- Obligation matrix revisions are immutable successors. They cannot introduce an undeclared operation class, broaden admitted inputs, weaken an invariant, or use remaining budget as authority for scope expansion.
- Deterministic integrity checks initially cover reference resolution, content digest consistency, media declaration consistency, basic decodability where supported, locator bounds, lineage referential integrity, duplicate-reference diagnostics, permission preconditions, and package-manifest consistency. Modality-specific semantic quality checks remain typed agent or evaluator proposals.
- Starter Findings use a shared envelope and registered type-specific details. Severity is `informational`, `minor`, `material`, `major`, or `critical`; confidence is `low`, `moderate`, or `high`; review state is `unreviewed`, `confirmed`, `disputed`, `resolved`, `dismissed`, or `superseded`.
- Finding consequence is evaluated by the applicable obligation, readiness purpose, or downstream Input Admission Contract. Severity alone never creates a universal block.
- Seed Mentions are occurrence records with exact locator, observed text or media region, modality, extraction method, and producer binding. Extracted Seeds are immutable provisional groupings with typed lineage for revision, split, and merge.
- Seed extraction coverage uses subject-region-modality-seed-family cells with `exhaustive`, `bounded`, `sampled`, `unsupported`, `inaccessible`, `failed`, or `unresolved` assessment modes. Empty seed output is accepted only when all required coverage cells have valid stopping evidence.
- A Repair Artifact is an immutable candidate with derivation, method, fidelity evidence, permission consequences, and affected dependency declarations. Candidate generation never changes the active package selection.
- Repair Decisions have outcomes `activate_as_superseding_selection`, `retain_as_companion`, and `reject`. The application service validates actor authority and optimistic version before acceptance. Low-risk deterministic repairs may be auto-decided only under an explicit policy revision.
- A Reconstruction Hypothesis can be attached as a finding or companion candidate but cannot receive the faithful-replacement decision class.
- Dependency links connect current selections to derived representations, findings, seed mentions, extracted seeds, consolidation outputs, readiness assessments, and report sections. Replacement or admitted-result changes traverse only descendants of changed dependencies.
- Staleness is immutable state with cause, frontier computation version, affected references, prior-current relationship, and re-evaluation requirement. Stale records remain queryable and are never deleted merely because they are no longer current.
- Package assembly is a pure validated operation over the Run Input Manifest, accepted current artifact selections, Package Derivations, current findings and seeds, Repair Decisions, permission and provenance context, and linked-result admission decisions.
- Starter Package identity and version are immutable. Package derivation supports multiple parents and typed reuse, supersession, merge, split, and repair relationships.
- Starter Readiness Assessment is separately versioned and binds the exact package version, target Workflow Type or declared purpose, relevant policy, findings, missing or stale work, blockers, warnings, conditions, freshness requirements, and rationale.
- Decision Report structured metadata is validated deterministically. Narrative authoring may be agentic, but required sections, referenced decisions, omission coverage, evidence links, output bindings, and improvement-candidate structure are application-validated.
- Failed or cancelling runs assemble a partial package, readiness assessment, or report only through the shared blueprint-declared terminal-finalization contract. The accepted Finalization Plan freezes eligible current references, dedicated budget, timeout, and allowed assembly/reporting effects; it cannot start new refinement, repair, lookup, extraction, or linked work. Ineligible or failed assembly records a typed output-omission reason.
- PostgreSQL is authoritative for run lifecycle, accepted commands, optimistic versions, Repair Decision authority, budgets, linked-run admission decisions, and transactional outbox events. MongoDB/Beanie is authoritative for document-shaped refinement revisions, findings, seeds, repair payloads, package manifests, readiness assessments, and report metadata. Object storage owns large immutable payloads and reports.
- Cross-store writes use stable identifiers, deterministic idempotency keys, outbox events, and orchestration sagas. A document write cannot independently advance the Workflow Run lifecycle.
- No refinement contract grants Neo4j write authority. Any graph observation is provisional context, and any graph-changing proposal crosses to a governed ingestion workflow.
- Raw artifact acquisition and capture are prerequisites. This core accepts only already captured immutable artifacts and never turns an arbitrary live URL, upload stream, or workspace file into a Starter Artifact.
- Dependency: this specification is the foundation for specifications 2, 3, and 4. They may add execution behavior but may not redefine these shared contracts.

## Testing Decisions

- The primary seam is one deterministic application-service scenario that admits a transcript, image, PDF, prior package reference, and corrupt captured artifact; accepts findings, seeds, and one Repair Decision; computes selective staleness; assembles package/readiness/report outputs; and emits a Terminalization Proposal observed through public commands and query projections. Constructors, property tests, serialized contracts, and emitted events provide supplemental coverage rather than peer seams.
- Tests do not assert private helper calls, internal repository layout, or model implementation details.
- Admission tests cover direct artifacts, immutable collection selections, prior packages, mixed inputs, captured-but-unavailable content, artifact-free intent, missing lineage, incompatible blueprint binding, insufficient baseline budget, and each permission outcome.
- Permission tests prove that identical content from two acquisition paths retains independent assessments and that prohibited required work is rejected while a prohibited optional operation is omitted explicitly.
- Obligation tests prove required, degradable, optional, and prohibited behavior; accepted immutable revisions; forbidden scope expansion; and outcome derivation.
- Terminalization tests prove the core cannot assign lifecycle outcome, stale evidence is rejected by the shared reducer, and terminal finalization cannot create new substantive work or omit its explicit omission reason.
- Finding contract tests prove separation of severity, confidence, review state, consequence, evidence, and exact locator, including rejection of unregistered typed details.
- Seed tests prove locator preservation, immutable regrouping lineage, ambiguity retention, and valid versus invalid zero-seed coverage.
- Repair tests prove candidate generation has no selection effect, each Repair Decision outcome, authority enforcement, duplicate-command idempotency, stale expected-version rejection, timeout fallback, and Reconstruction Hypothesis restrictions.
- Staleness tests replace one selected artifact and verify that only dependency descendants become stale while unrelated artifact branches remain current.
- Package assembly tests verify manifest invariants, multi-parent derivation, retention of unreadable artifacts, exclusion of stale current selections, deterministic digest stability, and rejection of dangling references.
- Readiness tests evaluate one package against at least two downstream purposes and prove that blockers and warnings differ without mutating the package.
- Decision Report tests verify required decision coverage and referenced immutable evidence while treating prose wording as non-contractual.
- Persistence contract tests verify exclusive authority boundaries, idempotent cross-store saga behavior, transactional lifecycle/outbox behavior, and recovery after a document write succeeds before lifecycle projection.
- Property-based tests are used for canonical serialization, digest stability, dependency-frontier closure, and package referential integrity.
- Prior art is the existing FastAPI test seam and infrastructure compatibility tests, extended upward to domain application services rather than duplicating checks against persistence internals.

## Out of Scope

- Raw artifact upload, folder inventory, URL acquisition, live-page capture, or creation of Starter Artifact identity.
- Deep or systematic research, Source Discovery, corpus construction, scientific claim adjudication, or canonical entity identity resolution.
- Neo4j mutation, ingestion planning, ingestion execution, or graph repair.
- The StageGraph and GoalDirected orchestration implementations, except for the shared contracts they consume.
- Guest Business Affiliation Summary retrieval behavior and external capability bindings, which are specified separately.
- Dashboard UI, durable broker selection, production deployment topology, model prompt text, and provider-specific sandbox paths.
- Universal downstream admission policy; readiness remains purpose-relative.

## Further Notes

- Dependency order: implement this deterministic core first; then the StageGraph vertical slice; then the GoalDirected extension; then the bounded Guest Business Affiliation Summary operation.
- Later specifications may tighten operation-specific thresholds and budgets but cannot weaken immutability, permission specificity, repair authority, provisional seed semantics, graph-mutation prohibition, or separation of run outcome from readiness.
- The current target is an infrastructure bootstrap with FastAPI, Socket.IO, Temporal, Beanie, PostgreSQL, S3, and an Agents SDK sandbox probe. This specification deliberately introduces domain authority before expanding orchestration.
