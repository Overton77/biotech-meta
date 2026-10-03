# Special Checkpoint: Source Intelligence and the Provenance Spine

Date: 2026-07-16

Status: System-wide provenance direction accepted; exact contracts, ownership boundaries, density measures, and workflow mappings remain open

## Purpose

This checkpoint establishes Source Intelligence and the **Provenance Spine** as system-wide architecture rather than a feature owned by one research, ingestion, content, or UI workflow.

The accepted proposition is:

> BellLabs must preserve a continuous, typed, queryable lineage from the origin of information through captured and derived representations, exact source regions, assertions, adjudicated knowledge, curated content, and user-visible component bindings.

The spine must influence:

- domain contracts
- Workflow Type obligations
- agent behavior and tools
- source discovery and corpus construction
- research and evidence production
- ingestion planning and execution
- curated content and publication
- generative UI and MCP UI components
- evaluation, correction, and refresh

Detailed database schemas, Temporal mappings, Agents SDK interfaces, and storage projections remain deferred.

## Why This Is System-Wide

Source provenance is used differently across the product:

- research discovers, rejects, selects, and reasons over sources
- corpus construction captures and transforms source material
- ingestion attributes assertions and proposed knowledge
- evaluation checks evidence, provenance, and transformation fidelity
- curated content attributes claims and reacts to changing knowledge
- components expose compact attribution and deeper verification

No one workflow can reconstruct missing upstream provenance reliably after the fact.

Likewise, no one workflow should own the whole Source lifecycle merely because it manipulates documents. Source identity, discovery, capture, transformation, selection, assessment, use, display, and refresh are related but distinct responsibilities.

## Accepted Provenance Spine

The conceptual path is:

```text
Source Origin
-> Source Work
-> Source Work Version
-> Source Representation
-> Source Snapshot
-> Derived Representation
-> Source Locator and/or Chunk Artifact
-> Assertion
-> Adjudication and Approved Knowledge
-> Curated Content or Component Data Binding
-> Rendered Experience
```

This notation is a navigational simplification. The Provenance Spine is a typed graph, not one mandatory linear chain.

Important corrections:

- a Source Locator and a Chunk Artifact are not the same thing
- a Source Locator anchors an exact region in a Source Snapshot or representation
- a Chunk Artifact is a derived retrievable unit and should carry one or more source anchors
- an Assertion is not automatically accepted knowledge
- Adjudication remains distinct from a source's assertion
- Curated Content and component bindings are distinct downstream artifacts even when a component displays content
- not every source has every identity layer resolved
- unresolved or inapplicable layers remain explicit rather than being fabricated to complete the chain

## Spine Layers

## 1. Source Origin

An enduring place, system, channel, or publication authority from which information can be obtained.

Examples:

- an official company website
- ClinicalTrials.gov
- an FDA database
- a journal platform
- a repository
- an API

The Source Origin is distinct from:

- the organization operating it
- a Source Work it provides
- a URL observed during one acquisition
- captured content

## 2. Source Work

A bounded intellectual or informational creation whose identity may survive hosting and representation changes.

Examples:

- a paper
- a report
- a regulatory decision
- a dataset
- a label
- a video
- a case study

Source Work identity must not be inferred solely from matching titles or similar content. Identity confidence and evidence remain explicit.

## 3. Source Work Version

A materially distinct issued revision or edition.

Examples:

- preprint version 1 and version 2
- an accepted manuscript and later corrected version of record
- a revised report
- a new label edition
- a dataset release

Formatting differences alone do not necessarily create a new Source Work Version.

## 4. Source Representation

A format or rendering of a Source Work Version.

Examples:

- publisher HTML
- PDF
- XML
- audio
- video
- a machine-readable export

Representations may differ in:

- locator stability
- extractability
- accessibility
- rights
- embedded metadata
- media fidelity

They may still represent the same substantive Source Work Version.

## 5. Source Snapshot

An immutable capture occurrence observed from a Source Origin at a specific time and acquisition context.

Two captures remain distinct Source Snapshots when:

- they came from different Source Origins
- they occurred at different observation times
- acquisition conditions or permissions differed

This remains true when the captured bytes are identical and Artifact Content is deduplicated.

A live URL is not a Source Snapshot.

## 6. Derived Representation

A system-produced transformation of a Source Snapshot or another admitted representation.

Examples:

- extracted text
- OCR output
- normalized HTML
- transcript
- page images
- extracted tables
- translated text
- parsed structured data

Derived Representations preserve:

- source inputs
- transformation method
- method version
- configuration
- producing actor or agent
- execution lineage
- output content identity
- fidelity findings
- known missing or unreadable regions

A Derived Representation cannot silently replace the source-provided representation as source truth.

## 7. Source Locator and Chunk Artifact

### Source Locator

A durable pointer to an exact source region.

Potential anchors include:

- source-snapshot identity
- page and bounding region
- section hierarchy
- exact text with prefix and suffix
- character offsets
- table, figure, caption, or footnote identity
- audio or video time range
- hashed excerpt

Multiple anchors may be preserved to improve resilience and verification.

### Chunk Artifact

A derived retrievable unit created for search, retrieval, reasoning, or processing.

A Chunk Artifact:

- is not the source itself
- is not interchangeable with a Source Locator
- identifies its parent representation
- preserves transformation and segmentation lineage
- carries source anchors
- may be regenerated under another chunking method or embedding policy

Canonical corpus chunk identity remains deferred until `SourceCorpusBuildWorkflow` is specified.

## 8. Assertion

A proposition attributable to a source or agent.

The Assertion preserves:

- what was asserted
- who or what asserted it
- exact Source Locators
- temporal context
- method and extraction provenance
- uncertainty

Source existence does not make an Assertion accepted fact.

## 9. Adjudication and Approved Knowledge

BellLabs evaluates Assertions through Adjudications and Evidence Assessments.

This layer preserves:

- verdict
- rationale
- supporting and contradicting evidence
- applicability
- method version
- review state
- uncertainty

Approved knowledge remains distinguishable from:

- source claims
- extracted assertions
- generated summaries
- direct structural relationships
- derived graph shortcuts

## 10. Curated Content and Component Data Bindings

Curated Content derives user-facing or operator-facing material from governed knowledge, research artifacts, and provenance.

A component binding connects a component property, display statement, media item, chart value, warning, or action to its governed data and provenance.

Attribution should support progressive disclosure:

1. compact claim-adjacent source and status cues
2. exact locator, excerpt, and captured source context
3. full derivation, assessment, decision, and transformation lineage

The user interface should not receive only flattened citation strings when typed provenance is available.

## The Spine Is A Graph, Not A Required Checklist

Not every valid path traverses every named layer.

### Mutable product page

```text
Official website Origin
-> mutable product-page referent
-> Source Snapshot
-> extracted text Derived Representation
-> Source Locators
-> product-specification Assertions
-> Adjudication or provisional use
-> report claims
```

The product page may not yet qualify as a bounded Source Work. The missing Work identity is explicit rather than invented.

### Case-study documents

```text
Source Origins
-> case-study Source Works and Versions
-> PDF / webpage Representations
-> Source Snapshots
-> extracted text, tables, and images
-> Chunk Artifacts with Source Locators
-> Assertions and Evidence Assessments
-> entity and evidence connections
-> report, content, and component bindings
```

### Reused identical content

```text
Publisher Origin ----\
                      -> identical Artifact Content
Repository Origin ---/
```

The bytes may be deduplicated while the Source Snapshots, acquisition paths, permissions, and authority contexts remain distinct.

### Updated or corrected source

```text
Prior Work Version -> prior Snapshot -> affected Assertions -> affected outputs
New Work Version   -> new Snapshot   -> new or revised Assertions
```

The new version does not erase history. It triggers purpose-aware impact analysis, freshness review, and possible re-research, re-ingestion, correction, or UI warnings.

## Provenance "Bone Density"

The operator introduced the useful metaphor of increasing **bone density** along the Provenance Spine.

The underlying requirement is accepted:

- lightweight use may preserve fewer resolved layers
- higher-risk or reusable outputs require richer source identity, locators, assessments, and downstream bindings
- provenance should become more complete as material is transformed into durable knowledge and user-facing outputs

The canonical measurement model is not accepted.

A single provenance-density score is not recommended because several independent questions exist:

- **Provenance Depth**: how far lineage extends from origin to output
- **Provenance Resolution**: how precisely identities, versions, representations, and locators are resolved
- **Provenance Coverage**: how much of an output's claims or data bindings have complete lineage
- **Provenance Confidence**: how strongly identity and lineage relationships are supported
- **Transformation Fidelity**: how accurately derived material represents its source
- **Verification Readiness**: whether a reviewer can inspect the exact supporting or contradicting material

These names and dimensions remain recommendations pending grilling.

Missing density must not be confused with false provenance. A declared unresolved identity or locator gap is preferable to a fabricated complete chain.

## Judgment Dimensions Must Remain Separate

The following are not one source-authority score:

- retrieval relevance
- Source Origin reliability
- identity confidence
- authenticity
- authority for a particular claim class
- information or Assertion credibility
- evidence quality
- evidence applicability
- freshness
- permission fitness
- acquisition fidelity
- transformation fidelity
- novelty or diversity contribution
- cost and access friction

Examples:

- a manufacturer page may be authoritative for what the manufacturer currently claims but weak evidence for efficacy
- a normally reliable source may publish one poorly supported claim
- a highly relevant result may be legally unusable for retention or publication
- a methodologically strong study may be poorly applicable to a different population or formulation
- an exact duplicate may add little novelty while confirming distribution history

Purpose-bound ranking may combine selected signals, but every component assessment, method version, and rationale remains inspectable.

## Layering Into Agentic Behavior

Agents participate in the Provenance Spine but do not gain authority to create canonical lineage solely through generated text.

## Provenance obligations by operation

Each semantic operation should eventually declare **Provenance Obligations**.

Candidate obligations include:

### Discovery

- preserve query intent and provider
- register Source Candidates
- retain provider-native rank and BellLabs reranking separately
- record exclusions and failed acquisition history
- avoid implying capture, corpus membership, or authority

### Capture

- resolve the most precise known source referent
- preserve Source Origin, observation time, acquisition path, headers or request state when relevant
- create immutable Source Snapshots
- preserve permission context

### Transformation

- bind exact inputs
- record method, model, prompt, tool, skill, configuration, and version
- preserve outputs and fidelity findings
- avoid silently correcting source content

### Segmentation and retrieval preparation

- preserve parent representation
- preserve segmentation method and version
- attach exact source anchors
- distinguish provisional task views from canonical corpus chunks

### Extraction and research

- emit Assertions rather than unlabeled facts
- attach Source Locators
- preserve contradictions and uncertainty
- distinguish source claim, agent inference, and BellLabs Adjudication

### Ingestion

- reference admitted snapshots and exact derived inputs
- preserve assertion, evidence, identity-resolution, and schema-mapping lineage
- prohibit live-URL-only provenance

### Content creation

- bind claims to governed Assertions, Adjudications, and Source Locators
- preserve human and generated edits
- declare freshness dependencies
- respect quotation, media, and publication permissions

### Component composition

- bind component properties and displayed values to governed data
- provide compact and expanded attribution
- expose stale, disputed, provisional, or restricted states appropriately
- preserve authorization for actions

## Agent tools and context

Agents will likely need typed capabilities to:

- inspect source identity and aliases
- register or revise Source Candidates
- request capture
- retrieve Source Snapshots and Derived Representations
- create or validate Source Locators
- query prior source use and exclusions
- inspect authority, quality, applicability, freshness, permission, and fidelity assessments
- materialize a purpose-bound provenance slice
- validate output provenance coverage
- propose correction or refresh work

The full provenance graph should not be placed into every model context. Agents receive purpose-bound **Provenance Contexts** or slices with drill-down access.

`Provenance Context`, `Provenance Obligation`, and `Run Provenance Manifest` are recommended candidate terms, not yet accepted glossary entries.

## Application enforcement

Application code must validate:

- required lineage references exist
- referenced versions and snapshots are immutable
- Source Locators target admitted representations
- generated artifacts identify their derivation
- required provenance coverage is met
- agents do not self-approve restricted identity, authority, or ingestion decisions
- permission capabilities admit the proposed use
- downstream outputs do not silently depend on stale or superseded source material

Agent prompts and Dynamic Instructions may describe Provenance Obligations but cannot grant permission or bypass invariants.

## Layering Into Workflow Types

The Provenance Spine is cross-cutting. Some Workflow Types create or enrich portions of it, but no single workflow owns the complete chain.

### Starter Content Refinement

- captures starter provenance and artifact lineage
- emits provisional seeds and findings
- may register source leads
- does not establish systematic source coverage

### Knowledge Preflight

- queries prior knowledge, corpora, source intelligence, and runs
- emits observational matches and gaps
- records query and graph/schema context
- does not mutate source or knowledge state implicitly

### Official Source Mapping

- verifies purpose-bound official relationships
- distinguishes official identity and self-claims from scientific truth
- may emit Source Candidates and source-identity proposals

### Source Discovery

- translates requirements into systematic procurement
- searches internal and external retrieval planes
- ranks and diversifies Source Candidates
- preserves exclusions, coverage, and stopping decisions

### Source Corpus Build

- acquires and captures selected material
- creates Derived Representations
- evaluates extraction fidelity
- creates retrievable chunks and indexes
- emits versioned Source Corpus outputs

It does not automatically own all Source identity, authority, selection, use, or monitoring semantics.

### Research Execution

- queries existing Source Corpora and external discovery capabilities
- selects sources for purpose-bound reasoning
- creates Assertions, findings, and research artifacts
- may request additional discovery or corpus-building runs

### Evidence Adjudication

- evaluates Assertions, evidence quality, applicability, contradiction, and uncertainty
- does not rewrite source history

### Report Creation

- binds report claims to assertions, adjudications, and exact locators
- preserves report version and edit lineage

### Ingestion Planning and Execution

- transforms admitted source-grounded assertions into reviewable graph candidates and writes
- preserves exact source, transformation, schema, identity-resolution, and approval lineage

### Evaluation

- checks provenance depth, resolution, coverage, confidence, fidelity, and verification readiness as distinct dimensions
- may emit improvement, repair, refresh, or reprocessing proposals

### Curated Content and Media

- carries approved knowledge and source provenance into publication artifacts
- preserves derivation, rights, freshness, and correction dependencies

### Generative UI and MCP UI Components

- bind displayed information and media to typed provenance
- progressively disclose verification information
- expose uncertainty, freshness, and dispute state
- do not execute arbitrary client behavior based on unverified source data

## During and After Research and Ingestion

The operator explicitly requires provenance work during and after both research and ingestion.

### During research

- discover and register candidates
- query internal corpora
- capture sources
- transform and segment material
- attach locators
- extract assertions
- record exclusions and gaps

### After research

- consolidate source use
- validate claim coverage and locators
- adjudicate evidence
- create report lineage
- identify unresolved provenance and follow-up work

### During ingestion

- resolve identity
- map assertions and evidence
- validate permissions
- bind schema mappings
- preserve plan and transformation provenance

### After ingestion

- validate graph and corpus effects
- confirm source links and locators
- record graph-version impact
- monitor source updates
- trigger repair, re-adjudication, re-ingestion, or content reevaluation when needed

This lifecycle argues against positioning Source Corpus Build as one permanently early pipeline stage.

## Composable Workflow Implications

The current direction supports:

- provenance obligations embedded in every relevant Workflow Type
- composable workflows that create or repair substantial provenance sections
- bounded inline provenance operations for small, obvious work
- standalone runs for expensive, reusable, independently requested, or review-heavy work

Possible future Workflow Types include:

- `SourceIdentityResolutionWorkflow`
- `SourceMonitoringWorkflow`
- `ProvenanceValidationWorkflow`
- `ProvenanceRepairWorkflow`
- `SourceCollectionMaintenanceWorkflow`

None is accepted yet. Their boundaries should be decided only after Source Discovery, Source Corpus Build, Evidence Adjudication, ingestion, and evaluation contracts expose the real reuse and authority requirements.

## Candidate Cross-Cutting Artifacts

The following artifacts are recommended for later evaluation:

### Purpose-Bound Provenance Context

A context-budgeted, queryable slice of the Provenance Spine supplied to an agent or workflow operation.

### Run Provenance Manifest

A durable account of source, representation, transformation, locator, assertion, knowledge, and downstream-output lineage used or produced by one Workflow Run.

### Provenance Coverage Assessment

A method-versioned evaluation of whether required claims, fields, data bindings, media, and actions have sufficient provenance for a declared purpose.

### Source Use Record

A durable record that a source referent, snapshot, locator, or derived representation was discovered, rejected, selected, transformed, reasoned over, ingested, cited, published, or displayed for a purpose.

### Provenance Impact Assessment

An evaluation of which assertions, adjudications, graph knowledge, content artifacts, and component bindings are affected by a changed, corrected, retracted, stale, or superseded source.

These names and exact boundaries remain open.

## System-Wide Invariants and Guardrails

1. Identical content does not merge distinct provenance.
2. A live URL is not sufficient durable provenance.
3. A Derived Representation does not become source truth.
4. A Chunk Artifact is not a Source Locator.
5. An Assertion is not automatically approved knowledge.
6. Official status is claim-class- and purpose-relative.
7. Retrieval relevance is not evidence quality or authority.
8. No one global source-authority score controls all use.
9. Unresolved identity and lineage remain explicit.
10. Agent-generated lineage enters canonical state only through typed, validated proposals.
11. Permission is acquisition-path- and use-capability-specific.
12. User-facing outputs preserve inspectable provenance bindings.
13. Source changes do not rewrite historical snapshots or historical run decisions.
14. Provenance repair creates new lineage and decisions rather than mutating history silently.
15. Workspace files, model context, and generated summaries are not canonical provenance stores.

## Source Intelligence Versus Source Intelligence Cache

The existing glossary defines **Source Intelligence Cache** as durable operational memory about visited, extracted, summarized, rejected, selected, or used sources.

That term may now be too narrow.

The new architecture suggests **Source Intelligence** includes:

- source identity and aliases
- official and ownership relationships
- acquisition and snapshot history
- representations and transformations
- query and ranking history
- inclusion and exclusion decisions
- source-use history
- authority, credibility, quality, applicability, freshness, permission, and fidelity assessments
- monitoring and change history
- downstream impact

Whether `Source Intelligence Cache` remains:

- the operational retrieval projection of broader Source Intelligence
- the canonical name for the whole capability
- or a deprecated term

is explicitly open.

## Relationship To The Source Research

This checkpoint incorporates the initial findings in:

- [Source Intelligence and Source-Handling Workflow Research](../research/2026-07-16-source-intelligence-workflow-research.md)

The research drew from:

- W3C PROV
- W3C Web Annotation
- DataCite resource relationships
- FIRST source-reliability and information-credibility guidance
- GRADE evidence-assessment dimensions
- systematic-review and living-review workflows
- Palantir data and workflow lineage
- AlphaSense claim-adjacent citations
- C2PA provenance-aware display guidance

Vendor documentation is evidence of workflow patterns, not proof that vendor quality claims are correct.

## Accepted Decisions

1. Source Intelligence and the Provenance Spine are system-wide concerns.
2. The spine preserves a continuous typed lineage from origin to user-visible experience.
3. The spine is a graph rather than one mandatory linear sequence.
4. Source Locator and Chunk Artifact are distinct.
5. Source Assertions remain separate from Adjudications and approved knowledge.
6. Provenance must reach Curated Content and component data bindings.
7. Retrieval relevance, reliability, authority, credibility, evidence quality, applicability, freshness, permission fitness, and transformation fidelity remain distinct.
8. One global source-authority score is rejected.
9. Agents receive provenance obligations and typed tools but do not directly establish canonical provenance through reasoning alone.
10. Provenance behavior is embedded across relevant Workflow Types and may also be produced or repaired by composable workflows.
11. Provenance work occurs during and after research and during and after ingestion.
12. `SourceCorpusBuildWorkflow` is not assumed to occupy one permanent linear position or own the whole Source lifecycle.

## Open Decisions

1. What canonical term should replace the bone-density metaphor?
2. Which provenance dimensions are required, and how are they measured without collapsing them into one score?
3. Is Source Intelligence a bounded context?
4. Is `Source Intelligence Cache` retained, narrowed, renamed, or deprecated?
5. What are the exact Source Collection and Collection Snapshot contracts?
6. What common query-result envelope joins internal corpus retrieval and external discovery?
7. Which source-identity decisions require deterministic evidence, agent review, or human acceptance?
8. Which Provenance Obligations belong to every Workflow Type?
9. Is a Run Provenance Manifest required for every relevant Workflow Run?
10. Which provenance checks are admission gates, completion obligations, evaluations, or publication gates?
11. Which candidate provenance workflows deserve first-class Workflow Type status?
12. How are source changes propagated into research, graph knowledge, content, and component states?
13. What provenance is displayed by default versus progressively disclosed?
14. What storage and query model supports the spine without creating a competing ungoverned knowledge graph?

## Recommended Next Interview Question

The next decision should sharpen the bone-density metaphor without inventing one misleading scalar.

Recommended question:

> Should the system replace one `Provenance Density` score with a `Provenance Completeness Profile` that keeps depth, resolution, coverage, confidence, transformation fidelity, and verification readiness as separate dimensions?

Recommended answer:

> Yes. Different workflows need different minimum profiles, and a source may be strong on one dimension while weak on another. The profile should preserve individual assessments and purpose-bound requirements rather than synthesize one universal score.
