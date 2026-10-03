# Special Checkpoint: Large Schema Workspaces, Schema Selection, and Report Splitting

Date: 2026-07-16

Status: Schema-workspace and selection direction accepted; segmentation authority explicitly deferred until Source Corpus Build is modeled

## Purpose

This checkpoint records the agent-first architecture for navigating and selecting from a Neo4j schema that is too large to place efficiently into one model context.

It also records an adjacent unresolved requirement: extremely large reports may need durable splitting or segmentation before schema selection, knowledge comparison, ingestion planning, or other workflows can process them reliably.

The report-splitting boundary is documented here but not decided. Detailed ingestion architecture remains deferred until the pre-research Workflow Types have been specified.

## Scope

The schema system must support:

- a versioned Neo4j schema source
- deterministic generation of agent-oriented schema resources
- sandbox Schema Workspaces
- compact global navigation
- overlapping domain-oriented schema modules
- semantic and topology-aware retrieval
- report- or task-guided Schema Context Selection
- deterministic expansion into complete selected-type details
- purpose-specific query and ingestion projections
- schema-selection review and false-negative safeguards
- filesystem/skill navigation for capable sandbox agents
- a read-only MCP retrieval surface for simpler lookups
- future schema growth beyond one context window

The agent will not use the Neo4j GraphQL API as its primary schema-navigation interface.

Neo4j GraphQL operations may still be used later by the dashboard or user application.

## Current Versioned Schema Source

For the current architecture, the versioned source is:

```text
biotech-kg/src/schema/neo4jbiotechschema.graphql
```

This Neo4j GraphQL directive `.graphql` file is the accepted **Schema Definition** from which agent-oriented resources are deterministically generated.

The deployed Neo4j database remains a separate runtime system. Future implementation must verify compatibility between:

- Schema Definition version/hash
- generated Schema Catalog version
- deployed graph schema/version marker

The versioned file must not silently claim that a drifted deployed database is compatible.

## Existing `biotech-kg` Implementation

The repository already contains a strong prototype of the intended architecture.

### Authoring and schema sources

Important locations:

```text
biotech-kg/src/schema/
biotech-kg/src/schema/neo4jbiotechschema.graphql
biotech-kg/src/schema/reference/schema-index.json
biotech-kg/src/schema/reference/schema-map.json
```

There are currently two related source paths:

- modular TypeScript domain schema files assembled through `buildTypeDefs()`
- the checked-in monolithic `neo4jbiotechschema.graphql`

The ingestion parsers and current schema-card generation use the monolithic `.graphql` file.

This creates a future drift risk if the modular TypeScript definitions and monolithic file are not generated or verified from one source chain.

### Deterministic parsing and generation

Important implementation:

```text
biotech-kg/src/kg-ingestion/schema/parseNeo4jGraphqlSchema.ts
biotech-kg/src/kg-ingestion/schema/buildCompactSchema.ts
biotech-kg/src/kg-ingestion/schema/expandSchemaSelection.ts
biotech-kg/src/kg-ingestion/schema/schemaCards.ts
biotech-kg/src/kg-ingestion/schema/schemaTypes.ts
```

Observed pipeline:

```text
neo4jbiotechschema.graphql
-> ParsedKgSchema
-> CompactKgSchema
-> agent SchemaSelection
-> ExpandedSchemaSlice
-> SchemaCoverage
-> run-scoped schema cards
```

The deterministic parser preserves:

- node types
- properties
- directives
- interfaces
- relationships
- relationship directions
- relationship-property types
- enums
- unions
- identity candidates
- source SDL

### Current compact representation

The current `CompactKgSchema` includes:

- schema source
- generation time
- sorted node names
- relationship triplets

Current scale:

- 91 node types
- approximately 338 relationship triplets
- 36 enums

This is efficient but semantically thin. It lacks short descriptions, aliases, conceptual module membership, and compact identity/search metadata.

### Current selection contract

The current `SchemaSelection` contains:

- optional report path
- optional rationale
- node type names
- relationship type names
- optional notes keyed by selected element

The Cursor SDK workflows already use:

```text
report text + compact schema
-> selecting agent
-> write_schema_selection typed tool
-> deterministic name normalization
-> deterministic expansion
```

A separate `schema-selection-reviewer` agent is already configured in one workflow prototype.

### Current deterministic expansion

`expandSchemaSelection()` currently:

- accepts selected nodes and relationship types
- includes selected relationships touching selected nodes
- adds concrete relationship endpoint nodes
- adds union members where required
- adds referenced enums
- adds relationship-property types
- separates required and optional properties
- preserves identity candidates and source SDL
- creates a combined SDL slice

This confirms the important distinction:

- the agent selects semantic membership
- deterministic code materializes complete details and closure

### Current schema cards

The generated card workspace is located at:

```text
biotech-kg/artifacts/kg/schema-cards/
```

Its declared read order is:

1. `schema-cards.md`
2. `relationship-cards.md`
3. `cypher-patterns.md`
4. `enum-cards.md`
5. `drilldown/` only when compact cards are insufficient

The cards intentionally use progressive disclosure. Compact cards are allowed to be lossy; deterministic validation uses full parsed schema artifacts.

Run-scoped selected card bundles already exist under agentic ingestion run artifacts.

### Existing report-guided example

The TruDiagnostic selection prototype demonstrates:

- report-guided node selection
- report-guided relationship selection
- rationale
- per-element notes tied to report sections
- deterministic expanded schema generation

The Exact Sciences agentic run similarly selected a smaller company/product/regulatory slice from the full schema and generated run-scoped drill-down cards.

## Relevant Research Findings

### Conceptual ontology modules

[Accelerating Knowledge Graph and Ontology Engineering with Large Language Models](https://arxiv.org/html/2411.09601v1) emphasizes conceptual ontology modules as a way to constrain large ontology tasks.

Important transferable finding:

```text
task/rule
-> select relevant conceptual modules
-> provide detailed selected modules
-> perform reasoning
```

The paper reports that module-first prompting can outperform presenting the full ontology. Conceptual consistency and tight module scope help prime the model.

### Retrieval over massive schemas

[RASL: Retrieval Augmented Schema Linking for Massive Database Text-to-SQL](https://arxiv.org/abs/2507.23104) decomposes schema metadata into separately indexed semantic units:

- table names
- aliases
- descriptions
- column names
- column aliases
- column descriptions
- value-format descriptions

It retrieves candidates across these component types, calibrates relevance, predicts a manageable set of tables, then loads complete details for the selected tables.

Transferable principle:

```text
granular semantic retrieval
-> high-recall candidate pool
-> semantic selection
-> complete details for selected structural units
```

### Schema-linking false-negative risk

[RSL-SQL: Robust Schema Linking in Text-to-SQL Generation](https://arxiv.org/html/2411.00073v2) shows that schema pruning is useful but risky.

Relevant safeguards:

- use multiple linking perspectives
- combine forward and backward evidence
- preserve topology
- augment simplified schemas with descriptions
- compare near alternatives
- use execution feedback for correction

For BellLabs, a selected schema slice must not silently omit identity, temporal, evidence, provenance, document, or media structures because their names did not lexically match the report.

### Neo4j schema representation

[The Impact of Schema Representation in the Text2Cypher Task](https://neo4j.com/blog/developer/schema-representation-in-text2cypher/) reports:

- longer enhanced-schema prompts can reduce performance
- dynamically pruned schema performed best in the tested setup
- filtering reduced prompt size substantially
- simple exact-match filtering outperformed some more complex tested strategies

This supports a context-budgeted selection surface rather than a maximal schema prompt.

### Seed signatures and module extraction

Ontology module research uses a **seed signature**: a set of task-relevant concepts and roles from which a module is extracted.

Locality-based module extraction preserves relevant structure around the signature.

The formal OWL entailment guarantees do not transfer directly to a Neo4j property-graph schema. The architectural principle does:

```text
task-derived seeds
-> deterministic structural closure
-> complete detail materialization
```

## Accepted Schema Architecture

## 1. Schema Definition

The versioned Neo4j GraphQL directive `.graphql` source.

It remains authoritative for generated schema resources.

## 2. Schema Catalog

The deterministic agent- and tool-oriented representation generated from one Schema Definition version.

The catalog should eventually include:

- tiny global module/topology index
- Compact Schema Overview
- Schema Module files
- node cards
- relationship cards
- enum and union cards
- per-element drill-down files
- query/Cypher patterns
- identity and search metadata
- full parsed machine artifacts
- lexical indexes
- alias/synonym indexes
- semantic/vector indexes
- topology indexes
- operation metadata

All projections must retain the source Schema Definition version/hash.

## 3. Compact Schema Overview

The first-stage semantic overview contains:

- node and relationship names
- one-line descriptions
- Schema Module memberships
- aliases and synonyms
- immediate topology
- property counts
- compact identity indicators
- compact search/index indicators

It does not include:

- every property
- complete enum values
- full directives
- full SDL
- long examples

Those remain drill-down material.

## 4. Schema Modules

Examples include:

- commerce
- biomechanistic
- organizations and people
- evidence and claims
- studies and trials
- diagnostics
- products and formulations
- protocols
- media and documents
- regulatory context

Schema Modules are:

- conceptual navigation and retrieval views
- versioned
- overlapping
- generated from one authoritative schema
- allowed to share nodes and relationships
- not bounded contexts
- not ownership partitions

Canonical module membership is governed.

A Schema Module Definition declares:

- purpose
- descriptions
- seed elements
- inclusion rules
- closure policy

Deterministic generation produces module files. Agents may propose module revisions, but they do not redefine canonical modules for every run.

## 5. Adaptive Schema Selection Context

Selection context adapts to schema size and configured context budget.

Always provide:

- tiny global module index
- tiny global topology/navigation summary

When it fits:

- provide the complete Compact Schema Overview

When it does not fit:

- retrieve a high-recall candidate set across modules and semantic units

Candidate retrieval may use:

- exact names
- aliases and synonyms
- descriptions
- report keywords
- extracted concepts
- lexical search
- vector search
- module membership
- immediate topology
- property names and descriptions
- identity/search indicators

Retrieval proposes candidates. It does not make the final semantic selection.

## 6. Schema Selection Brief

A large report or task does not have to be placed wholesale into one selection prompt.

The Schema Selection Brief is a versioned, high-recall seed signature containing:

- selection purpose
- intended operations
- entities
- concepts
- claims
- evidence structures
- temporal requirements
- document/media requirements
- provenance requirements
- coverage obligations
- unresolved mappings
- exact report/source locators

The full report remains available through workspace files and tools.

When the report fits the configured context budget, the selector may receive it directly in addition to or instead of a separately generated brief.

The brief is not a lossy substitute that prevents source inspection.

## 7. Schema Context Selection

A Schema Context Selection is:

- semantic
- immutable
- purpose-bound
- tied to one Schema Definition version
- composed primarily of node and relationship type membership

It preserves:

- purpose
- coverage obligations
- selected nodes
- selected relationships
- optional property-intent hints
- rationale
- evidence and source locators
- explicit exclusions
- unresolved mappings
- near-miss candidates considered
- parent selection when revised

Property-intent hints do not prune complete properties from deterministic expansion.

## 8. Schema Selection Review

Every agent-produced selection requires:

### Deterministic validation

- names exist
- selected relationship types exist
- endpoint topology is valid
- selection references the expected Schema Definition version
- required fields and rationales are structurally valid

### Independent semantic coverage review

- report/task concepts are selected, explicitly excluded, or unresolved
- near-miss candidates were considered
- temporal structures were not omitted
- identity structures were not omitted
- evidence and provenance structures were not omitted
- document/media structures were not omitted
- selection is neither unjustifiably narrow nor excessively broad
- context and budget targets remain satisfied

The selecting agent does not approve its own output.

## 9. Expanded Schema Slice

The Expanded Schema Slice is distinct from Schema Context Selection.

It is generated deterministically from:

- one accepted selection
- one Schema Definition version
- one closure policy

It materializes:

- complete selected-node properties
- relationship endpoints
- selected relationship fields
- relationship-property types
- required enums
- required unions and members
- directives
- identity candidates
- complete selected SDL
- external references

Generating full properties or reading drill-down files does not create a new Schema Context Selection version.

Only a semantic membership change creates a revised selection.

## 10. Schema Operation Projections

An Expanded Schema Slice may produce deterministic purpose-specific projections.

Examples:

- read/query coverage
- full-text search coverage
- vector-search coverage
- neighborhood traversal coverage
- identity-resolution coverage
- ingestion/write coverage
- relationship-mutation coverage
- validation coverage

A Schema Context Selection is purpose-bound.

Reuse in another workflow requires admission for the new purpose. A preflight selection is not automatically sufficient for ingestion.

## Dual Execution Model

Schema selection may be performed in two forms while producing the same output contract.

### Bounded inline Schema Context Selection

Use when:

- scope is obvious
- candidate set is small
- selection is inexpensive
- no independently reusable Decision Report is needed
- configured operation limits are sufficient

Example:

A Knowledge Preflight for one known Product and its immediate Organization/ProductSnapshot/RegulatoryStatus context.

### `SchemaContextSelectionWorkflow`

Use when selection is:

- broad
- ambiguous
- expensive
- independently requested
- reusable
- report-guided over substantial material
- subject to important review or approval
- likely to require iterative candidate retrieval

Example:

Selecting the relevant schema surface for a large company-fundamentals report before graph comparison and ingestion planning.

The consuming workflow uses the same admitted Schema Context Selection regardless of which execution form produced it.

## Schema Workspace

A Schema Workspace is a run-specific sandbox materialization.

It may contain:

```text
schema/
  manifest.json
  global/
    module-index.json
    topology-index.json
    compact-schema.json
  modules/
    commerce.json
    biomechanistic.json
    evidence.json
    diagnostics.json
  cards/
    nodes/
    relationships/
    enums/
    unions/
  drilldown/
  selections/
    selection.json
    expanded-slice.json
    operation-projection.json
    selected-cards/
  indexes/
    lexical/
    semantic/
    topology/
  skills/
    schema-navigation/
```

The exact layout remains implementation work.

The Workspace Materialization Manifest maps every governed path to:

- Schema Definition version
- Schema Catalog build
- Schema Module version
- Schema Context Selection
- Expanded Schema Slice
- Schema Operation Projection
- local generated candidate or durable artifact state

The sandbox filesystem is not canonical schema state.

## Agent Skill and MCP Roles

The likely architecture uses both.

### Schema navigation Agent Skill

Best for capable sandbox agents that need:

- prescribed read order
- filesystem navigation
- module selection guidance
- Cypher construction guidance
- validation rules
- examples
- deeper investigation across files

### Read-only schema MCP server

Best for bounded structured lookups such as:

- list modules
- get Compact Schema Overview
- search schema elements
- resolve aliases
- retrieve element cards
- retrieve topology neighborhood
- retrieve properties for selected types
- expand a selection deterministically
- validate a selection
- retrieve purpose-specific operation coverage

The MCP server should expose the generated Schema Catalog, not independently invent a competing schema representation.

The exact MCP tool contract remains open.

## Corrections to Earlier Expansion Language

The prior interview language risked conflating:

- semantic selection
- deterministic expansion
- workspace drill-down

The accepted meanings are now:

### Selection

Agent judgment about which node and relationship types are relevant.

### Deterministic expansion

Materializing complete details and required closure for an accepted selection.

### Drill-down

Reading deeper pre-generated files from the Schema Catalog or selected card bundle.

### Selection revision

Adding or removing semantic node/relationship membership after review.

Only selection revision creates a new Schema Context Selection version.

## Current Repository Gaps

The existing prototype is directionally strong but has known gaps:

1. The current compact schema has names and triplets but insufficient semantic metadata.
2. Current reference-map domain labels are all `neo4jbiotechschema`; useful conceptual modules are not represented.
3. Modular TypeScript SDL and the monolithic `.graphql` create a potential source-drift path.
4. Generated artifacts and current generator behavior show some enum/union drill-down drift.
5. The current selection contract lacks:
   - purpose
   - coverage obligations
   - explicit exclusions
   - unresolved mappings
   - near-miss candidates
   - property-intent hints
   - schema version/hash
   - selection lineage
6. Current validation removes hallucinated names but does not yet establish semantic coverage.
7. The complete parsed schema is too large for ordinary prompt use.
8. There is no unified machine-readable index over all schema cards.
9. Operation coverage is currently ingestion-oriented and must become purpose-specific.
10. Runtime compatibility between generated schema resources and deployed Neo4j remains to be specified.

No implementation change is authorized by this checkpoint. These are inputs to the later schema and runtime design phase.

## Deferred Question: Extremely Large Report Splitting

Accepted 2026-07-16:

- do not accept a standalone report, document, or artifact segmentation Workflow Type yet
- preserve bounded inline segmentation plus standalone segmentation as the leading hypothesis
- first specify `SourceCorpusBuildWorkflow` authority over conversion, canonical segments, chunk identity, whole-document/chunk relationships, and corpus versions
- schema-selection and other pre-corpus workflows may create provisional task views when necessary
- provisional task views must preserve source identity and exact locators and must not become canonical Source Corpus chunks implicitly

This is an explicit deferral, not a rejection of independently runnable segmentation.

The system must support reports too large to:

- place in one model context
- summarize safely in one pass
- map to schema in one selection turn
- ingest as one undifferentiated artifact

Report splitting affects:

- Schema Selection Brief construction
- Schema Context Selection
- report-grounded graph comparison
- identity resolution
- ingestion planning
- evidence and Source Locator preservation
- parallel processing
- consolidation and coverage evaluation

The workflow boundary is unresolved.

## Candidate Model A: Internal operation only

Large-report splitting is an operation inside whichever workflow needs it.

Advantages:

- less Workflow Type proliferation
- workflow-specific segmentation strategy
- simpler orchestration for small cases

Risks:

- duplicated splitting logic
- inconsistent segment identity
- poor reuse across selection, comparison, ingestion, and evaluation
- hidden durable artifacts inside unrelated workflows

## Candidate Model B: First-class `ReportSegmentationWorkflow`

A standalone workflow receives a report and emits a versioned segmentation artifact.

Advantages:

- independently runnable
- reusable across schema selection and ingestion
- durable segment identities and locators
- separate evaluation and repair
- clear parallelization boundary

Risks:

- may be too report-specific
- segmentation may need source-type-specific behavior
- simple reports incur unnecessary Workflow Run overhead

## Candidate Model C: Dual execution model

Use one shared segmentation output contract in two forms:

- bounded inline segmentation for ordinary reports
- first-class workflow for extremely large, complex, reusable, or independently requested segmentation

This mirrors:

- Supporting Source Lookup versus SourceDiscoveryWorkflow
- bounded Schema Context Selection versus SchemaContextSelectionWorkflow

This remains the leading hypothesis, but acceptance is deferred until `SourceCorpusBuildWorkflow` is modeled.

## Possible Broader Boundary

The eventual first-class type may be broader than reports:

- `DocumentSegmentationWorkflow`
- `ArtifactSegmentationWorkflow`
- `CorpusPreparationWorkflow`

A broader type could handle:

- reports
- publications
- transcripts
- PDFs
- web captures
- media-derived text
- structured exports

However, SourceCorpusBuildWorkflow will also perform conversion, splitting, chunking, and indexing.

The system must avoid creating two overlapping segmentation authorities.

## Report Segmentation Output Questions

If segmentation becomes durable, the output likely needs:

- source Artifact Content identity
- segmentation strategy and version
- ordered segment identities
- exact source locators
- section hierarchy
- page/time/character/token anchors
- overlap policy
- tables, figures, captions, and footnotes
- preserved cross-segment references
- semantic labels
- extraction confidence
- missing or unreadable regions
- segment-level hashes
- recomposition validation
- coverage evaluation

These fields are hypotheses, not accepted schema.

## Questions To Resolve Later

1. Is report segmentation a report-specific workflow or part of general artifact/corpus preparation?
2. What thresholds move segmentation from inline operation to standalone Workflow Run?
3. Does SourceCorpusBuildWorkflow own canonical segmentation?
4. Can SchemaContextSelectionWorkflow create provisional segments without becoming the canonical corpus segmenter?
5. Are schema-selection segments temporary views or durable artifacts?
6. How are tables, figures, appendices, footnotes, and references preserved?
7. How is complete report coverage evaluated after parallel selection over segments?
8. Does each segment produce a partial schema selection that must be unioned and reviewed?
9. How are duplicate selections and cross-segment concepts consolidated?
10. How are source locators preserved into later Assertions, Evidence, and ingestion provenance?

## Recommended Temporary Rule

Until the segmentation boundary is resolved:

- small and medium reports may be supplied directly when they fit
- large reports use a versioned Schema Selection Brief with exact locators
- full report content remains accessible on demand
- no workflow may silently discard report sections to fit context
- any provisional splitting must preserve source identity and locators
- no provisional segment model should be treated as the canonical Source Corpus chunk model
- no independently runnable segmentation Workflow Type is accepted yet

## Next Interview Position

Return to the pre-research Workflow Types after this checkpoint.

The segmentation boundary must be revisited after `SourceCorpusBuildWorkflow` defines canonical segmentation authority. Before then, source-domain modeling must distinguish sources, captured source states, source collections, source selection, retrieval, ranking, authority, and corpus membership.

The next focused schema decision may define the Schema Catalog retrieval/MCP contract, but the recommended interview path returns first to Entity Seed Extraction, Official Source Mapping, Source Discovery, and Source Corpus Build.

The detailed database schemas, Temporal mappings, OpenAI Agents SDK interfaces, and FastAPI architecture remain intentionally deferred.

## Related Documents

- [Workflow Catalog, Agent Runtime, Sandboxes, and Current System State](2026-07-15-workflow-catalog-agent-sandbox-and-system-state-special-checkpoint.md)
- [Starter Package Findings, Permissions, and Repair](2026-07-15-starter-package-findings-permissions-and-repair-checkpoint.md)
- [Starter Preflight and Mission Specification](2026-07-15-starter-preflight-and-mission-specification-checkpoint.md)
- [Knowledge Production Composition and Intake](2026-07-15-knowledge-production-composition-and-intake-checkpoint.md)
- [Human Upgrade System Context](../CONTEXT.md)
