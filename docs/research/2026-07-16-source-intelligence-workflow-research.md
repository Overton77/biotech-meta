# Source Intelligence and Source-Handling Workflow Research

Date: 2026-07-16

Status: Initial comparative research; findings and architecture implications are hypotheses, not accepted domain decisions

## Research Question

How should BellLabs develop reusable Source Intelligence and carry Source representations coherently through:

- research, for discovery and deliberate exclusion
- ingestion, for transformation and attribution
- curated content, for attribution and freshness
- components, for display and user verification

This research compares intelligence practice, enterprise intelligence platforms, systematic-review workflows, provenance standards, scholarly-resource identity, and provenance-aware user interfaces.

## Initial Findings

### 1. Source handling is a lifecycle, not a document store

The recurring pattern is:

```text
Requirements
-> Collection Planning
-> Discovery
-> Candidate Registration
-> Acquisition and Capture
-> Processing and Derivation
-> Retrieval and Selection
-> Claim/Evidence Assessment
-> Synthesis or Ingestion
-> Dissemination and Display
-> Monitoring and Refresh
```

Intelligence doctrine begins with requirements and collection plans rather than undirected searching. Systematic reviews similarly bind search, screening, extraction, and synthesis to a protocol. Enterprise platforms continuously collect and index material but expose it through contextual search, enrichment, monitoring, and citations.

BellLabs should not let `SourceCorpusBuildWorkflow` absorb the complete source lifecycle merely because it processes files. Source identity, source intelligence, discovery, capture, processing, retrieval, selection, assessment, and downstream use are distinct concerns.

### 2. Retrieval rank, source reliability, information credibility, authority, and evidence quality are different judgments

FIRST's intelligence curriculum preserves the Admiralty/NID distinction between:

- reliability of a source based partly on identity and history
- credibility of particular information in context

Biomedical evidence systems add further dimensions:

- risk of bias
- inconsistency
- indirectness or applicability
- imprecision
- publication bias

For BellLabs, at least these dimensions must remain separable:

- retrieval relevance
- source-origin reliability
- authenticity and identity confidence
- authority for a particular claim class
- information or assertion credibility
- evidence quality
- evidence applicability
- freshneess
- acquisition and processinss
- rights and permission fitng fidelity
- novelty and diversity contribution
- cost and access friction

One global `source_score` would erase these distinctions. Search ranking may combine some dimensions for a declared purpose, but the component assessments and their method versions must remain inspectable.

### 3. Provenance must continue through every transformation and user-facing result

W3C PROV separates:

- Entity: a fixed-aspect thing
- Activity: work performed over time
- Agent: responsibility
- generation, use, derivation, attribution, association, and delegation

Palantir's public lineage model similarly presents continuity from source data through transforms and ontology into applications and workflows.

The BellLabs implication is an unbroken lineage:

```text
Source Origin
-> Source Work
-> Source Work Version
-> Source Representation
-> Source Snapshot
-> Derived Representation
-> Segment or Chunk
-> Assertion / Evidence Assessment
-> Ingested Knowledge
-> Curated Content
-> Component Data Binding
-> Rendered Experience
```

Each arrow needs a typed relationship. The final component cannot cite only a live URL if the research and ingestion decisions depended on an immutable capture and transformed text.

### 4. Exact source location is a reusable platform capability

The W3C Web Annotation model supports:

- a source resource
- a specific resource or state
- time and request state
- fragment, text-position, text-quote, data-position, SVG, XPath, and other selectors
- selector refinement and combinations

This reinforces the existing `Source Locator` direction. A locator should be representation-aware and may preserve multiple anchors, such as:

- page plus bounding region
- section hierarchy
- exact text plus prefix/suffix
- character offsets
- table, figure, caption, or footnote identity
- audio/video time range
- source-snapshot identity

Multiple anchors improve resilience, but a locator remains bound to the captured representation from which it was produced.

### 5. Work identity, version, representation, snapshot, and derivation need separate relationships

DataCite's controlled relationships distinguish:

- `IsVersionOf` / `HasVersion`
- `IsNewVersionOf` / `IsPreviousVersionOf`
- `IsVariantFormOf` / `IsOriginalFormOf`
- `IsDerivedFrom` / `IsSourceOf`
- `IsPartOf` / `HasPart`
- `Cites` / `IsCitedBy`
- `References` / `IsReferencedBy`
- `IsIdenticalTo`

This independently supports the Source model now being developed in `docs/CONTEXT.md`. Identical payloads, alternate representations, substantive versions, derived transformations, parts, and citations must not collapse into one relationship.

### 6. High-trust research products expose claim-adjacent verification

AlphaSense documents deep-linked citations from generated summaries to exact source snippets and original documents. Its platform combines curated external collections and internal enterprise content. The important transferable pattern is not the vendor's claim of trust; it is that generated synthesis remains adjacent to inspectable source material.

BellLabs should preserve at least three layers:

1. compact attribution visible with the claim or component
2. exact supporting or contradicting locator and captured source context
3. deeper provenance, transformation, assessment, and decision lineage

C2PA's provenance-aware UX guidance similarly favors recognizable, layered disclosure rather than forcing all provenance into the primary view.

### 7. Systematic-review workflows preserve exclusions, not only selected evidence

Systematic-review tooling commonly separates:

- protocol and eligibility criteria
- broad search
- deduplication
- title/abstract screening
- full-text screening
- structured extraction
- risk-of-bias assessment
- synthesis
- reporting of inclusion and exclusion flow

Living reviews add periodic surveillance, deduplication against prior searches, re-screening, and update decisions.

For BellLabs, deliberate avoidance is first-class Source Intelligence. Rejected candidates should retain:

- the purpose and query under which they were considered
- exclusion reason
- decision actor and method
- evidence and confidence
- whether exclusion is permanent, purpose-bound, or refreshable
- conditions that should trigger reconsideration

This prevents repeated low-value acquisition and makes coverage claims auditable.

## Four Source-Use Planes

### Research: discover, avoid, and select

Research needs both:

- internal retrieval over admitted Source Corpora and prior Source Intelligence
- external discovery through dedicated search tools, APIs, browsers, and source-specific skills

Both paths should return a common purpose-bound result envelope containing:

- source referent resolution
- candidate identity
- query and retrieval method
- retrieval rank and component signals
- available snapshots or representations
- prior uses and exclusions
- freshness observations
- permission and access conditions
- authority and quality assessments relevant to the declared purpose
- coverage and diversity contribution

External search results should not masquerade as captured or admitted corpus material. Internal corpus hits should not imply current external completeness.

### Ingestion: transform and attribute

Ingestion needs:

- immutable Source Snapshots
- verified Source Work and version relationships
- Derived Representation lineage
- extraction and fidelity findings
- exact Source Locators
- permission capabilities
- assertion-level attribution
- identity-resolution and evidence-applicability decisions
- transformation and agent provenance

An ingestion plan should reference admitted captures and exact derived inputs, not whichever live page happens to exist at commit time.

### Curated Content: attribute and remain refreshable

Curated Content needs:

- claim-to-Assertion and claim-to-Source Locator mappings
- distinction between source assertion and BellLabs Adjudication
- audience-appropriate citation presentation
- freshness dependencies
- correction, withdrawal, and supersession propagation
- rights-aware quotation and media use
- preserved generated and human-edited lineage

The content artifact should be able to answer: which claims would become stale if a Source Work receives a new version, a source retracts a claim, or an Adjudication changes?

### Components: display, verify, and authorize

Components need governed bindings to:

- knowledge entities and assertions
- Source Snapshots and Source Locators
- authority, evidence, and freshness indicators
- media rights and provenance
- component-specific disclosure policies
- safe actions and authorization

A product card, evidence comparison, chart, or protocol component should not receive flattened citation strings. It should receive typed provenance bindings that support compact display and deeper inspection.

## Candidate Source-Intelligence Capabilities

These are capabilities, not yet accepted services or Workflow Types:

### Source registry and resolution

- resolve origins, works, versions, representations, and aliases
- preserve unresolved and competing identity candidates
- record mirrors and identical content without merging provenance

### Collection management

- define purpose-bound source collections
- preserve immutable collection snapshots
- support manually curated, query-defined, workflow-produced, and hybrid membership
- record inclusion and exclusion decisions
- monitor refresh and coverage obligations

### Retrieval federation

- search internal Source Corpora
- query external search providers and source-specific APIs
- normalize results into a common candidate envelope
- preserve provider-native rank and BellLabs reranking separately
- support lexical, semantic, graph, metadata, and temporal retrieval

### Source assessment

- source-origin reliability
- identity and authenticity confidence
- claim-class authority
- information credibility
- evidence quality and applicability
- acquisition and transformation fidelity
- freshness
- rights and permission fitness

### Source-use ledger

- record which run used, rejected, cited, transformed, ingested, displayed, or published each source referent and snapshot
- preserve purpose, decision, locator, and resulting artifacts
- support impact analysis when sources change

### Monitoring and refresh

- watch mutable origins and works
- detect new versions, retractions, corrections, changed access, and changed permissions
- issue purpose-aware staleness and reconsideration events

## Workflow-Catalog Implications

### `OfficialSourceMappingWorkflow`

Likely owns purpose-bound proposals and verification evidence connecting domain entities to official Source Origins, Source Works, or mutable official records. It should not confer universal scientific authority.

### `SourceDiscoveryWorkflow`

Likely owns systematic procurement against declared requirements, source-class coverage, stopping criteria, ranking policy, and registered inclusion/exclusion decisions. It can search both prior Source Intelligence and external systems.

### `SourceCorpusBuildWorkflow`

Likely owns capture admission, representation acquisition, transformation, fidelity evaluation, segmentation or chunking, indexing, and corpus-version outputs. It should consume resolved or provisionally resolved source referents rather than own all source identity and authority semantics.

Its current catalog position should not imply one execution order. A Source Corpus may:

- pre-exist a mission
- be built before research
- be extended during research
- be refreshed after research
- support Knowledge Preflight
- support multiple independent Workflow Runs

The relationship among Source Discovery, Source Corpus Build, and Research Execution is therefore likely iterative rather than linear.

## Initial Architecture Hypothesis

The strongest current hypothesis is a dual retrieval plane:

```text
Internal Plane
Source Intelligence + Source Corpora + prior runs
             \
              -> Common Source Query Result -> purpose-bound selection
             /
External Plane
search providers + official APIs + browsers + source-specific skills
```

The common result must preserve which plane and provider produced each hit. It normalizes enough for ranking and selection without erasing provider-specific evidence, rank, or access conditions.

This does not yet decide whether source intelligence is:

- a bounded context
- a group of application services
- one or more Workflow Types
- a shared persistence model
- an MCP/tool surface

Those boundaries require further grilling.

## Research-Backed Guardrails

- Do not use one global source authority score.
- Do not collapse retrieval relevance into evidence quality.
- Do not collapse source reliability into assertion credibility.
- Do not treat search results as captured sources.
- Do not treat capture as corpus admission.
- Do not treat corpus membership as research or ingestion selection.
- Do not treat official status as universal truth.
- Do not discard excluded candidates or failed acquisition history.
- Do not let transformations break source-to-output lineage.
- Do not bind user-facing attribution only to live URLs.
- Do not let a generated summary replace exact source inspection.

## Open Research Questions

1. Should Source Intelligence be a bounded context with its own ownership boundary?
2. What is the exact model for purpose-bound Source Collections and immutable Collection Snapshots?
3. Which source identity decisions are deterministic, agent-proposed, or human-reviewed?
4. How should mutable webpages and database records fit beside Source Works?
5. What contract unifies internal corpus retrieval and external discovery without flattening their differences?
6. Which ranking signals may be combined for retrieval, and which must remain independent assessments?
7. What thresholds move acquisition and corpus building from bounded operations to standalone Workflow Runs?
8. How do source updates trigger re-research, re-ingestion, content correction, and component warnings?
9. Which provenance data must be displayed by default versus progressively disclosed?
10. How should permission and licensing constraints affect ranking, capture, transformation, quotation, and display?

## Sources Consulted

### Intelligence and enterprise intelligence

- [FIRST: Source Evaluation and Information Reliability](https://www.first.org/global/sigs/cti/curriculum/source-evaluation)
- [Recorded Future: Intelligence Graph](https://www.recordedfuture.com/platform/intelligence-graph)
- [Recorded Future: Enrichment](https://support.recordedfuture.com/hc/en-us/articles/360008123174-Use-Case-Enrichment)
- [AlphaSense: Enterprise Intelligence](https://developer.alpha-sense.com/enterprise)
- [AlphaSense: Smart Summaries and deep-linked citations](https://help.alpha-sense.com/hc/en-us/articles/41669307479443-Get-Instant-Insights-and-Save-Time-with-Smart-Summaries)
- [Palantir Foundry: Data Lineage](https://palantir.com/docs/foundry/data-lineage/overview/)
- [Palantir Foundry: Workflow Lineage](https://palantir.com/docs/foundry/workflow-lineage/overview/)

### Evidence synthesis and assessment

- [Cochrane Handbook, Chapter 1](https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-01)
- [How to update a living systematic review and keep it alive](https://link.springer.com/article/10.1186/s13643-023-02325-y)
- [Guidance to best tools and practices for systematic reviews](https://pmc.ncbi.nlm.nih.gov/articles/PMC10464882/)
- [Web-Based Software Tools for Systematic Literature Review](https://pmc.ncbi.nlm.nih.gov/articles/PMC9112080/)
- [CDC ACIP GRADE Handbook: determining certainty of evidence](https://www.cdc.gov/acip-grade-handbook/hcp/chapter-7-grade-criteria-determining-certainty-of-evidence/index.html)
- [Elicit Systematic Review workflow](https://elicit.com/blog/systematic-review/)

### Provenance, identity, and display

- [W3C PROV Data Model](https://www.w3.org/TR/prov-dm/)
- [W3C Web Annotation Data Model](https://www.w3.org/TR/annotation-model/)
- [DataCite relation types](https://datacite-metadata-schema.readthedocs.io/en/4.6/appendices/appendix-1/relationType/)
- [C2PA Technical Specification 2.4](https://spec.c2pa.org/specifications/specifications/2.4/specs/C2PA_Specification.html)
- [C2PA User Experience Guidance](https://spec.c2pa.org/specifications/specifications/2.2/ux/UX_Recommendations.html)

