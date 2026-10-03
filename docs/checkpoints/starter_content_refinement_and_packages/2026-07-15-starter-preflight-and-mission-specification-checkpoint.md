# Starter Preflight and Mission Specification Checkpoint

Date: 2026-07-15

Status: Accepted domain direction; detailed schemas and execution rules remain open

## Purpose

This checkpoint continues from [Knowledge Production Composition and Intake](2026-07-15-knowledge-production-composition-and-intake-checkpoint.md). It records the accepted boundaries among supporting source lookup, Knowledge Preflight, Starter Package construction, and Mission Specification creation.

## Search Breadth and Mutation Authority

Search capability and mutation authority are independent controls.

The coordinator and authorized workflow agents may use governed vector, hybrid, full-text, filter, graph-traversal, prior-run, and artifact retrieval. Flexible retrieval does not imply unrestricted raw database access, cross-tenant access, or permission to mutate knowledge.

Knowledge Preflight is observational. If preflight discovers a valuable pre-research graph repair or enrichment, it submits a Run Request for a separate linked ingestion or graph-maintenance Workflow Run. Human approval is the default for such mutations, while policy may permit narrowly safe autonomous cases.

## Knowledge Preflight

**KnowledgePreflightWorkflow** is a first-class, independently runnable Workflow Type.

It performs broad observational search for:

- possible entities and relationships
- existing knowledge and prior work
- graph coverage
- contradictions
- unresolved identities
- knowledge gaps
- potentially relevant source and artifact history

It does not perform authoritative identity resolution or hide graph writes inside search.

Starter Content Refinement may request KnowledgePreflightWorkflow as a linked run. Other workflows and missions may invoke or refresh it independently.

## Knowledge Preflight Snapshot

KnowledgePreflightWorkflow emits an immutable **Knowledge Preflight Snapshot** containing:

- observation time
- graph and schema version context
- query intents and modalities
- selected result identities and scores
- coverage findings
- contradictions
- gap hypotheses
- references to separately stored large result artifacts

A package or run references the snapshot rather than treating live graph state as historical context.

Freshness is contextual rather than a global TTL. **Preflight Freshness Policy** considers:

- snapshot age
- relevant graph or schema revisions
- changed entities or source classes
- changed scope
- mission risk
- intended downstream use

An outdated snapshot remains valid historical evidence even when it is not current enough for a proposed use.

In the default north-star mission template, a missing or insufficiently fresh preflight causes the planner to propose a KnowledgePreflightWorkflow dependency. Policy may permit skipping it; the omission and rationale remain explicit.

## Supporting Source Lookup

A **Supporting Source Lookup** may occur inside another Workflow Type when external lookup is needed solely to clarify, verify, or label that workflow's inputs or decisions.

It must have:

- declared clarification questions
- configured search, page, time, and cost limits
- registration of discovered sources and provenance
- outputs that do not claim systematic procurement or corpus coverage

When the purpose becomes systematic source procurement, coverage expansion, ranking, or corpus preparation, the workflow requests a linked SourceDiscoveryWorkflow.

The boundary depends on both purpose and enforced resource limits, not merely on which tool was called.

## Starter Package Construction

A **Starter Package**:

- is an immutable, versioned output of Starter Content Refinement
- is derived from one immutable Run Input Manifest
- may combine selected artifacts from multiple Starter Collections, direct uploads, prior packages, and reports
- records every origin and exact input version
- acts as a manifest over separately stored immutable artifacts
- may inline compact metadata and findings but does not copy all source bytes into one record
- may exist when preflight is missing, skipped, or failed
- is not a universal prerequisite for other Workflow Types

Corrections produce a new package version or supplemental artifact rather than an in-place edit.

Package lineage is a graph. **Package Derivation** records typed relationships to each reused, superseded, merged, split, or repaired package or artifact. A package may have multiple parents.

## Workflow-Relative Readiness

A **Starter Readiness Assessment** does not assign one universal package status.

It records blockers, warnings, and conditions relative to possible downstream Workflow Types. Each downstream Input Admission Contract and policy decides whether a finding:

- blocks the proposed run
- requires an added dependency
- requires approval or override
- permits execution with a warning
- has no consequence for that workflow

A missing Knowledge Preflight Snapshot therefore does not automatically block every downstream workflow.

## Mission Direction and Mission Specification

Starter Content Refinement emits an advisory **Mission Direction Proposal** with candidate objectives, questions, scope choices, and suggested next workflows tied to package findings.

The proposal is not executable instruction and is not a draft specification that silently becomes active.

`MissionInstructionWorkflow` is renamed **MissionSpecificationWorkflow**.

MissionSpecificationWorkflow combines accepted intake intent, available packages, preflight context, and operator decisions into a validated Mission Specification proposal.

A **Specification Acceptance Policy** decides whether a valid proposal:

- activates automatically
- requires human acceptance
- may be accepted by a delegated authority

The policy may vary with risk and trust. Deterministic invariants always apply, and the authoring agent does not gain self-approval authority merely by producing the proposal.

## Specification Revision

Mission Specifications are immutable versions.

Changing an active mission's objective or constraints creates a new proposal and a **Specification Impact Assessment**. The assessment classifies effects on planned, active, and completed Workflow Runs.

- completed runs remain bound to the specification version under which they were created
- planned runs may bind the newly accepted version
- active runs are classified as unaffected, intervention-capable, must-stop, or must-fork
- no revision retroactively rewrites historical run intent

## Next Interview Target

Define the detailed Starter Content Refinement contracts:

- Starter Package finding and reference schemas
- artifact roles and ordering
- integrity and permission findings
- extracted seed structure and confidence semantics
- repair proposal, execution, and acceptance
- Decision Report relationship
- partial failure and package-emission rules
- input admission and control configuration
