# Special Checkpoint: Source Intelligence, Source Workflows, and Provenance Profiles

Date: 2026-07-17

Status: Source-domain decisions accepted where labeled; standalone workflow candidates and corpus-version semantics remain open

## Purpose

This checkpoint records the continuation of the BellLabs pre-research workflow and domain-modeling interview after:

- [Source Intelligence and the Provenance Spine](2026-07-16-source-intelligence-and-provenance-spine-special-checkpoint.md)
- [Pre-Research Workflow Grill Handoff](handoffs/2026-07-16-pre-research-workflow-grill-handoff.md)
- [Large Schema Workspaces, Selection, and Report Splitting](2026-07-16-large-schema-workspaces-selection-and-report-splitting-special-checkpoint.md)

The session clarified:

- how standalone Workflow Types relate to missions and internal operations
- how Provenance Completeness and Requirement Profiles work
- what Source Intelligence contains
- how Source Collections differ from Source Corpora
- the primary output boundary of `SourceDiscoveryWorkflow`
- the admission boundary of `SourceCorpusBuildWorkflow`
- which standalone source and provenance workflows should exist or remain candidates
- how research and ingestion carry provenance obligations without owning the entire Source lifecycle

Detailed storage schemas, Temporal mappings, OpenAI Agents SDK interfaces, FastAPI contracts, and implementation remain deferred.

## Confirmed Workflow Composition Frame

Every Workflow Type is a standalone entrypoint when its Input Admission Contract permits execution.

The same Workflow Type contract applies whether a Workflow Run is:

- started independently through an API, dashboard, service, or human request
- requested by a coordinator
- linked into a Knowledge Production Mission
- requested by another Workflow Run

A Workflow Type may contain:

- deterministic application operations
- agentic semantic operations
- bounded subagent delegation
- governed tool and MCP use
- approval waits
- degradable and required Processing Obligations

Internal operations do not become Workflow Runs merely because they are agentic or observable. Crossing an accepted Workflow Type boundary creates a distinct linked Workflow Run through a Run Composition Link.

Workflow configuration may resolve controls, capabilities, budgets, models, and obligations. It does not silently rewrite Workflow Invariants or grant authority through prompts.

## Accepted Provenance Measurement Model

### Reject one scalar Provenance Density score

The system rejects one scalar provenance score as the canonical measurement model.

The accepted concept is **Provenance Completeness Profile**.

A profile keeps separate dimensions such as:

- lineage depth
- identity and locator resolution
- claim or binding coverage
- confidence in provenance relationships
- transformation fidelity
- verification readiness

Strength in one dimension does not universally compensate for weakness in another.

Example:

A manufacturer page may have:

- excellent capture integrity
- precise locators
- high transformation fidelity
- poor independent-evidence coverage

One aggregate score would conceal the difference.

### Provenance Requirement Profile

A **Provenance Requirement Profile** declares the provenance conditions required for a purpose at one or more workflow boundaries.

Potential boundaries include:

- input admission
- operation completion
- workflow completion
- artifact promotion
- ingestion proposal
- publication
- component display or action

The accepted configuration model has three layers:

1. shared, versioned requirement-profile definitions
2. Workflow Type bindings to admission, completion, or promotion boundaries
3. mission and run overlays that may select allowed variants or strengthen requirements

Mission and run overlays cannot weaken provenance-related Workflow Invariants.

No source or artifact receives one universal `complete` status. Sufficiency is evaluated by a consuming Workflow Type for its declared purpose.

### Immutable assessment identity

Each Provenance Completeness Profile is:

- immutable
- method-versioned
- purpose-bound
- tied to the exact subject being assessed
- tied to the considered provenance evidence
- tied to the applicable Provenance Requirement Profile version
- tied to an assessment time

Changed evidence, requirements, or methods produce a new linked assessment rather than mutating history.

This preserves why a prior Workflow Run admitted, rejected, qualified, or promoted an output.

### Provenance Profile Composition

Completeness profiles may compose across meaningful provenance-bearing boundaries:

```text
Source capture and derivation
-> Assertion support
-> Adjudication
-> Report or Curated Content
-> Component data binding
```

A higher-level profile references lower-level profiles and evaluates declared coverage obligations.

Material gaps remain explicit. They are not averaged away.

Example:

If nine report claims have exact locators and one material safety claim does not, the report-level profile must preserve the missing safety provenance rather than emit a misleading high average.

## Source Intelligence

Source Intelligence is the durable operational understanding of sources across their lifecycle.

It includes:

- source identities, aliases, and competing identity hypotheses
- official and ownership relationships
- Source Origins, works, versions, representations, and snapshots
- discovery queries and provider results
- provider-native ranking and BellLabs reranking
- acquisition attempts and capture history
- inclusion, exclusion, and unresolved decisions
- transformations and fidelity findings
- source reliability and claim-class authority assessments
- information credibility, evidence quality, and applicability assessments
- freshness and monitoring history
- permission and access conditions
- prior research, ingestion, citation, publication, and display uses
- downstream impact when sources change

Source Intelligence may know about a source that:

- has never been captured
- was deliberately excluded
- failed acquisition
- remains identity-unresolved
- was used in one purpose but rejected for another
- is not a member of any Source Corpus

Source Intelligence is not equivalent to:

- a Source Corpus
- a document store
- a search-result cache
- the approved knowledge graph
- one source-authority score

Whether Source Intelligence is a bounded context, application-service group, persistence model, or combined architecture remains open.

The existing term `Source Intelligence Cache` may be too narrow. Whether it remains an operational projection, is renamed, or is deprecated remains open.

## Source Intelligence, Source Corpus, and Knowledge

The conceptual relationship is:

```text
Source Intelligence
  knows source identities, history, decisions, assessments, and uses

Source Collections
  preserve purpose-bound candidates and membership decisions

Source Corpus
  contains admitted captures and processed retrieval material

Knowledge Graph
  contains Assertions, Adjudications, and approved knowledge projections
```

These layers reference one another but do not collapse.

## Accepted Source Collection Model

### Source Collection

A Source Collection is:

- durable
- purpose-bound
- mutable
- able to contain resolved source referents and Source Candidates
- able to preserve included, excluded, and unresolved members
- independent of source capture or corpus admission

A collection is not a Source Corpus.

### Source Collection Snapshot

A Source Collection Snapshot is an immutable view of:

- exact membership
- membership decisions
- declared purpose
- governing requirements
- observation or emission time

Workflow Runs bind or emit snapshots rather than treating a changing live collection as historical input.

### Source Collection Membership Decision

Membership is represented by immutable, purpose-bound decisions rather than a global mutable source status.

A decision may:

- include
- exclude
- leave unresolved

It preserves:

- collection and purpose
- rationale
- evidence
- deciding actor or method
- confidence
- reconsideration conditions
- supersession lineage

The same source may be:

- included in an official product-claims collection
- excluded from a controlled human-efficacy collection
- unresolved in a formulation-history collection

This does not make the source globally good, bad, included, or excluded.

## Accepted Source Discovery Output Boundary

`SourceDiscoveryWorkflow` is the independently runnable Workflow Type for systematic source procurement.

Its primary durable domain output is an immutable Source Collection Snapshot with:

- Source Candidates
- source referent resolutions and unresolved identities
- membership decisions
- provider-native retrieval evidence
- BellLabs reranking evidence
- coverage assessment
- diversity findings
- unresolved gaps
- failed acquisition leads
- stopping rationale
- separate Decision Report

`SourceDiscoveryWorkflow` does not emit a Source Corpus merely because it visited, downloaded, or inspected material.

Captures needed to substantiate discovery decisions remain provenance-linked artifacts. Formal corpus admission belongs to `SourceCorpusBuildWorkflow`.

This preserves standalone value: discovery may complete, be reviewed, and be reused even when no corpus is built.

## Accepted Corpus Admission Boundary

Source Collection inclusion, successful capture, and Source Corpus membership are distinct states.

Every proposed corpus member requires an immutable **Corpus Admission Decision**.

A decision may:

- admit
- conditionally admit
- reject
- remain pending

It evaluates:

- source-collection selection
- source and acquisition identity
- permissions
- capture integrity
- representation fitness
- transformation fidelity
- target corpus purpose and contract

Examples:

- a selected paper cannot be acquired
- publisher HTML is admitted while an unverified mirror PDF is rejected
- captured video is excluded because transcription rights are insufficient
- a PDF is admitted while a faulty OCR derivation is rejected

A Source Corpus may therefore be a valid partial output while preserving failed acquisition, processing, and admission outcomes.

## What a Source Corpus Contains

A Source Corpus is a purpose-bound body of admitted, captured, and processed material prepared for governed retrieval or downstream work.

It contains or references:

- Corpus Admission Decisions
- Source Snapshots
- source-provided representations
- Derived Representations
- Document Artifacts
- Media Artifacts
- exact Source Locators
- canonical Chunk Artifacts
- segmentation and transformation lineage
- extracted text, tables, figures, transcripts, or structured data
- embedding and index artifacts
- permission conditions
- capture and transformation fidelity findings
- failed or incomplete processing records
- governing configuration and build lineage

A Source Corpus is not:

- a list of URLs
- a Source Collection
- an ungoverned folder of Markdown
- every source returned by search
- proof of scientific authority
- automatic Research Source Selection
- automatic Ingestion Source Selection

### Representation example

```text
Source Work
└── Source Work Version
    ├── Publisher HTML Representation
    │   └── immutable HTML Source Snapshot
    │       └── normalized Markdown Derived Representation
    ├── Publisher PDF Representation
    │   └── immutable PDF Source Snapshot
    │       ├── extracted text
    │       ├── page images
    │       └── extracted tables
    └── canonical corpus chunks with exact source anchors
```

Markdown, OCR, transcripts, extracted tables, and chunks are derived material. They do not become the original source.

### Corpus versioning remains open

The interview proposed:

- a durable logical Source Corpus identity
- immutable Source Corpus Versions
- exact version binding by Workflow Runs
- successor and multi-parent merge lineage

The operator explicitly skipped this decision to first deepen the Source Corpus and Source Intelligence model.

No corpus-version model is accepted by this checkpoint.

## Tavily-to-Report Provenance Example

A research agent queries Tavily and receives URLs, snippets, ranks, and scores.

The accepted interpretation is:

```text
Tavily result
-> Source Candidate
-> identity resolution or unresolved referent
-> Source Collection Membership Decision
-> acquisition and immutable Source Snapshot
-> Derived Representation such as Markdown
-> Corpus Admission Decision
-> Source Corpus material
-> retrieval result and Chunk Artifact
-> exact Source Locator
-> source Assertion
-> Evidence Assessment and Adjudication
-> report claim
```

Important distinctions:

- a Tavily score is provider retrieval relevance, not evidence quality
- a URL is not a Source Snapshot
- Markdown is a Derived Representation, not the source
- a retrieved chunk is not automatically credible evidence
- consulting material is not the same as using it to support a claim
- report attribution should bind material claims to exact Assertions and Source Locators
- BellLabs conclusions are Adjudications, not silent restatements of source claims

For every material report claim, the system should support traversal through:

```text
Report passage
-> Adjudication or synthesized finding
-> supporting and contradicting Assertions
-> exact Source Locators
-> Chunk Artifacts or Derived Representations
-> Source Snapshots
-> Source Representations
-> Source Work Versions and Works
-> Source Origins
```

The Provenance Spine also records the agent, model, prompt, tools, transformations, and decisions involved. Tool-use lineage alone does not prove that consulted material supports the resulting claim.

## Core Standalone Source Workflows

The following Workflow Types remain accepted members of the active catalog.

### 1. `OfficialSourceMappingWorkflow`

Purpose:

Find and verify purpose-bound official relationships among domain entities and Source Origins, works, records, and representations.

Responsibilities include:

- official identity verification
- claim-class-specific official status
- verification evidence
- source identity proposals
- Source Candidates
- unresolved and conflicting mappings

Official status may establish authority for identity or self-claims. It does not establish universal scientific truth.

### 2. `SourceDiscoveryWorkflow`

Purpose:

Conduct systematic, purpose-bound source procurement against declared requirements, coverage obligations, and stopping rules.

Its accepted output boundary is the Source Collection Snapshot rather than the Source Corpus.

### 3. `SourceCorpusBuildWorkflow`

Purpose:

Acquire selected source material and produce admitted, provenance-preserving retrieval material.

Responsibilities include:

- acquisition and capture
- Source Snapshot creation
- permission validation
- conversion and extraction
- transformation-fidelity assessment
- exact Source Locator creation
- canonical segmentation and chunking
- embeddings and indexes
- Corpus Admission Decisions
- corpus build outputs and failures

It does not own the complete Source lifecycle.

## Candidate Standalone Source and Provenance Workflows

The following candidates are recommended but not accepted by this checkpoint.

### `SourceIdentityResolutionWorkflow`

Candidate purpose:

Resolve difficult relationships among Source Origins, works, versions, representations, snapshots, mirrors, aliases, and duplicates.

Leading hypothesis:

- obvious bounded identity resolution remains an operation inside another Workflow Type
- ambiguous, expensive, reusable, independently requested, or review-heavy resolution becomes a standalone Workflow Run

### `SourceMonitoringWorkflow`

Candidate purpose:

Monitor mutable sources and identify:

- changed pages
- new versions
- corrections and retractions
- changed labels
- changed regulatory status
- changed access or permission conditions
- newly relevant evidence

It should emit observations, impact assessments, and proposed work rather than silently rebuilding corpora or rewriting knowledge.

### `ProvenanceValidationWorkflow`

Candidate purpose:

Observationally evaluate reports, corpora, graph knowledge, content, or component bindings against Provenance Requirement Profiles.

It may be a specialized member of the eventual Evaluation Workflow family rather than a completely independent workflow category.

### `ProvenanceRepairWorkflow`

Candidate purpose:

Create governed revised lineage for missing, broken, stale, or incorrect provenance while preserving historical state and decisions.

Repair does not pretend corrected provenance existed during a prior run.

### Deferred candidates

The earlier source checkpoint also listed:

- `SourceCollectionMaintenanceWorkflow`
- other substantial provenance or source-impact workflows

These remain deferred until core source, evidence, ingestion, evaluation, and monitoring contracts reveal real reuse and authority boundaries.

## Capabilities That Should Initially Remain Operations

The current recommendation is not to create standalone Workflow Types for:

- one ordinary URL capture
- ordinary HTML-to-Markdown conversion
- OCR or table extraction within a corpus build
- source ranking
- ordinary research source selection
- ordinary ingestion source selection
- simple collection edits
- citation formatting

These begin as typed deterministic or agentic operations inside governing Workflow Types.

They may later receive a dual execution model when work becomes:

- substantial
- expensive
- independently requested
- reusable
- long-running
- review-heavy
- separately permissioned
- independently evaluated

## Provenance Obligations During Research

`ResearchExecutionWorkflow` carries provenance behavior directly.

Its obligations include:

- query internal Source Corpora and Source Intelligence
- preserve external query and provider context
- register Source Candidates
- distinguish bounded lookup from systematic Source Discovery
- preserve provider-native rank and BellLabs reranking separately
- capture or request capture when durable use requires it
- inspect Derived Representations and original Source Snapshots
- attach exact Source Locators
- emit Assertions rather than unlabeled facts
- preserve contradictions and uncertainty
- distinguish consulted, selected, supporting, contradicting, and rejected source uses
- preserve coverage gaps
- bind research outputs to exact source and reasoning lineage

Research may request linked runs when it needs:

- systematic discovery
- substantial corpus construction
- difficult identity resolution
- substantial provenance validation or repair

Research does not outsource responsibility for its own source-use and report provenance merely because it consumes a previously built corpus.

## Provenance Obligations During Ingestion

Ingestion planning and execution have stricter promotion obligations.

They must preserve:

- admitted Source Snapshots
- exact Derived Representations
- exact Source Locators
- source-attributed Assertions
- identity-resolution evidence
- Evidence Assessments and applicability
- permission capabilities
- schema-selection and schema-mapping lineage
- Graph Candidate and Ingestion Plan lineage
- approval and graph-write provenance

Research may reason provisionally from unresolved material when policy permits. Ingestion must not silently promote unresolved identity or evidence into authoritative graph knowledge.

Ingestion may request linked source or provenance runs, but it remains responsible for validating the exact evidence and provenance attached to proposed knowledge.

## Cross-Cutting Enforcement

Relevant Workflow Types should eventually declare:

- Provenance Requirement Profile bindings
- required and degradable Provenance Obligations
- allowed source-use classes
- admission and promotion gates
- required Source Locators
- required capture and derivation lineage
- required permission capabilities
- provenance evaluation obligations
- provenance event and Decision Report expectations

Agents receive typed tools and purpose-bound provenance context. Agent reasoning does not directly establish canonical provenance, approve restricted source identity, or bypass invariant requirements.

## Accepted Decisions In This Checkpoint

1. Provenance Completeness is multidimensional rather than one scalar score.
2. Provenance Requirement Profiles use shared definitions, Workflow Type bindings, and mission/run overlays.
3. Mission and run overlays may strengthen but cannot weaken provenance-related Workflow Invariants.
4. Provenance Completeness Profiles are immutable, method-versioned, purpose-bound assessments.
5. Changed evidence or requirements create linked assessment revisions.
6. Higher-level profiles compose lower-level profiles while preserving material gaps.
7. Source Collections, Source Collection Snapshots, and Source Corpora are distinct.
8. Source Collection membership uses immutable, purpose-bound decisions.
9. The same source may receive different membership decisions for different collection purposes.
10. `SourceDiscoveryWorkflow` primarily emits a Source Collection Snapshot, coverage assessment, gaps, and stopping rationale.
11. Source Discovery does not implicitly create a Source Corpus.
12. Collection inclusion, successful capture, and corpus membership are distinct.
13. Source Corpus membership requires a separate immutable Corpus Admission Decision.
14. Source Intelligence remains broader than a source cache, corpus, or document store.
15. Official Source Mapping, Source Discovery, and Source Corpus Build remain the accepted core standalone source workflows.
16. Research and ingestion carry their own source and provenance obligations.
17. No single workflow owns the complete Source lifecycle or Provenance Spine.

## Recommendations Not Yet Accepted

- dual inline/standalone `SourceIdentityResolutionWorkflow`
- standalone `SourceMonitoringWorkflow`
- `ProvenanceValidationWorkflow`, possibly within the Evaluation Workflow family
- standalone `ProvenanceRepairWorkflow`
- a required Run Provenance Manifest for every relevant Workflow Run
- exact Source Corpus and Source Corpus Version identity semantics
- exact common query-result envelope for internal and external retrieval
- exact Source Intelligence bounded-context and persistence ownership

## Still-Open Questions

1. Does `SourceIdentityResolutionWorkflow` use a dual inline/standalone execution model?
2. Which source identity decisions are deterministic, agent-proposed, independently reviewed, or human-approved?
3. What is the exact `OfficialSourceMappingWorkflow` input, verification, output, and mutation contract?
4. What is the exact Source Discovery requirements and coverage model?
5. What constitutes sufficient discovery stopping evidence?
6. What is the common result envelope for internal corpus retrieval and external search providers?
7. What is the exact Source Corpus build and corpus-version contract?
8. Which transformations and chunks are canonical within a corpus?
9. What thresholds move capture, transformation, segmentation, or identity resolution into linked Workflow Runs?
10. Is Source Monitoring one workflow or monitoring plus separately requested refresh workflows?
11. Is provenance validation a specialized Evaluation Workflow or its own top-level type?
12. What source and provenance events trigger re-research, re-adjudication, re-ingestion, content correction, and component warnings?
13. Is a Run Provenance Manifest mandatory for every relevant Workflow Run?
14. What storage model supports Source Intelligence without creating an accidental second knowledge graph?

## Recommended Next Interview Position

Continue one decision at a time.

Recommended next question:

> Should `SourceIdentityResolutionWorkflow` use a dual execution model in which obvious, bounded identity resolution remains an operation inside another Workflow Type, while ambiguous, expensive, reusable, independently requested, or review-heavy identity resolution creates a standalone linked Workflow Run?

Recommended answer:

> Yes. The same output contract can support both forms, while the control plane enforces thresholds and prevents substantial identity adjudication from being hidden inside an unrelated agent operation.

After identity resolution, continue through:

1. exact `OfficialSourceMappingWorkflow` contract
2. exact `SourceDiscoveryWorkflow` requirements, coverage, ranking, and stopping contract
3. exact `SourceCorpusBuildWorkflow` acquisition, transformation, chunk, admission, and version contract
4. return to canonical segmentation authority
5. evaluate Source Monitoring, Provenance Validation, and Provenance Repair as standalone Workflow Types

Mode-specific deep research remains deferred until the pre-research source workflows are sufficiently complete.

