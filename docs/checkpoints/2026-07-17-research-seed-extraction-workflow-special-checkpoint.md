# Research Seed Extraction Workflow Special Checkpoint

Date: 2026-07-17

Status: Accepted architecture checkpoint

## Purpose

This checkpoint records the accepted pre-research architecture for extracting provisional research-starting signals from artifacts and other governed subjects.

It supersedes the narrower `EntitySeedExtractionWorkflow` name and resolves its inline-versus-standalone execution boundary. It does not define implementation schemas, storage technology, Temporal topology, agent SDK wiring, API routes, or UI event contracts.

## Accepted Renaming and Scope

The canonical first-class Workflow Type is now:

- `ResearchSeedExtractionWorkflow`

The prior name `EntitySeedExtractionWorkflow` is too narrow because extraction must preserve multiple kinds of signals that can initiate entity-centered and evidence-centered research.

The accepted seed families are:

1. `Entity Seed`
2. `Assertion Seed`
3. `Evidence Question Seed`
4. `Source Lead`

Mechanisms, interventions, outcomes, products, formulations, biomarkers, trials, publications, organizations, and media are not automatically separate top-level seed families. They are expressed through the accepted families and their subtypes or relationships.

## Accepted Dual Execution Boundary

Research-seed extraction has two execution forms:

### Research Seed Extraction Operation

Bounded extraction may remain a semantic operation inside a consuming Workflow Run, including Starter Content Refinement.

It:

- runs under declared limits
- has no independent workflow lifecycle
- preserves its actual execution bindings and lineage
- emits the same typed seed-output semantics as the standalone workflow

It must not be called an inline `ResearchSeedExtractionWorkflow`, because crossing a Workflow Type boundary always creates a distinct Workflow Run.

### Research Seed Extraction Workflow

Substantial, reusable, independently requested, cross-artifact, multimodal, long-running, or review-heavy extraction uses the independently runnable Workflow Type.

Invoking it:

- creates a distinct Workflow Run
- preserves a Run Composition Link when requested by another run
- receives independent controls, budgets, evaluation, review, provenance, and reporting
- may be executed standalone when its Input Admission Contract permits

### Threshold direction

The exact promotion thresholds remain to be specified in later control-contract work.

Relevant dimensions include:

- artifact count and size
- cross-artifact grouping
- multimodality
- ambiguity and expected seed density
- requested ontology breadth
- independent reuse
- specialized models or agents
- review obligations
- duration and budget
- separate evaluation requirements

Promotion must be policy-controlled rather than left to an agent to hide first-class extraction inside an unrelated operation.

## Accepted Agentic Configuration Foundation

Every agentic Workflow Type may declare an attachable execution environment and instruction surface through a three-level configuration hierarchy.

### Workflow Agentic Configuration Contract

The Workflow Type declares permitted and default:

- Agent Profiles
- execution capabilities
- workspace requirements
- models
- MCP servers
- tools
- skills
- prompt and dynamic-instruction policies

### Effective Run Configuration

Each Workflow Run binds the fully resolved result of:

- the Workflow Type contract
- selected configuration versions
- authorized coordinator or UI overlays
- applicable policy and delegated authority

An authorized Run Control Revision creates a successor configuration for affected future work. It does not rewrite prior execution.

### Operation Execution Binding

Each semantic operation records the actual:

- Effective Run Configuration version
- prompts and Dynamic Instructions
- model
- skills
- tools and MCP connections
- workspace
- capability authority

The exact meaning and boundary of an Operation remains workflow-specific. Generic “workflow part” is not accepted vocabulary; use Stage, Branch, or Operation according to the actual semantics.

Prompts, skills, attached materials, MCP tools, and sandbox state do not grant authority or override Workflow Invariants.

## Accepted Input Contract

The standalone workflow uses one polymorphic but strongly typed input structure.

### Research Seed Extraction Brief

The brief defines:

- purpose
- requested seed families
- scope
- ontology hints
- coverage expectations
- exclusions
- contextual references

### Extraction Subject Manifest

The manifest binds exact immutable references to admitted extraction subjects, which may include:

- Starter Artifacts
- Starter Packages
- Source Snapshots
- Derived Representations
- Source Corpus slices
- prior Extracted Seeds
- operator-provided seed sets

Each selected subject preserves:

- input role
- exact selected version
- provenance
- locator basis
- permission context

Optional context may reference an Intake Brief, Mission Specification, schema context, prior workflow outputs, or other governed material.

Mutable collections, live URLs, and unbound workspace contents are not canonical run inputs. They require an immutable selection or governed acquisition path.

Prompts, skills, UI instructions, and dynamic instructions remain execution configuration unless deliberately admitted as referenced extraction subjects.

Admission requires:

- at least one usable extraction subject
- applicable permissions
- sufficient provenance and locator support
- supported or explicitly degradable modalities
- a valid Research Seed Extraction Brief

## Accepted Seed Semantics

### Seed Mention

A Seed Mention is an immutable occurrence-level observation preserving:

- exact subject identity
- exact locator
- observed text or media region
- extraction actor and method
- method version

### Extracted Seed

An Extracted Seed is an immutable provisional grouping hypothesis over exact Seed Mentions.

It:

- belongs to one accepted seed family
- preserves preferred and alternative interpretations
- has a structured confidence basis
- may receive linked successors
- is not accepted research instruction
- is not evidence merely because it was extracted
- is not authoritative graph knowledge

### Seed lineage

Changed grouping or typing creates new Extracted Seeds and explicit Seed Lineage Links.

Accepted lineage semantics include:

- `revises`
- `splits_from`
- `merges_from`

Prior hypotheses remain preserved for reproducibility, comparison, and evaluation.

Grouping means that mentions likely express the same research-starting signal. It does not resolve entity identity or establish adjudicated equivalence.

## Accepted Seed Families

### Entity Seed

A provisional seed for a potentially graph-identifiable referent. It preserves:

- preferred candidate type
- optional alternative types
- labels and aliases
- exact mention references
- unresolved identity

An Entity Seed is not an authoritative Entity.

### Assertion Seed

A provisional source-attributed proposition that may warrant:

- investigation
- normalization
- support search
- contradiction search
- applicability analysis

It is not an accepted fact or adjudicated Assertion.

### Evidence Question Seed

A provisional question about:

- support
- opposition
- applicability
- uncertainty
- missing evidence

It may inform later mission specification or research but is not accepted execution instruction.

### Source Lead

A provisional pointer to a potentially useful source referent that still requires discovery or source-identity work.

It is not yet:

- a registered Source Candidate
- a selected research source
- a captured source
- a corpus member

Sources actually discovered through bounded lookup are registered through the Source Candidate contract rather than remaining untracked Source Leads.

## Accepted Confidence Model

There is no single canonical seed-confidence score.

Each Seed Confidence Profile keeps separate:

1. detection confidence
2. family and subtype confidence
3. grouping confidence
4. normalized interpretation confidence

It also preserves:

- alternatives
- rationale
- supporting observations
- extraction method and method version
- calibration context where numeric values are used

Numeric values are comparable only where recorded calibration permits.

Per-seed confidence does not substitute for workflow-level extraction coverage.

## Accepted Coverage and Completion Model

Completion is obligation-based rather than seed-count-based.

A workflow may complete successfully with zero seeds when it satisfies the extraction obligations in the brief.

Every result includes an immutable Seed Extraction Coverage Assessment describing:

- subjects and regions examined
- modalities examined
- requested seed families examined
- exhaustive, bounded, or sampled treatment
- unsupported or inaccessible material
- low-fidelity regions
- failed or skipped methods
- unresolved work
- consequences for negative findings

The system distinguishes:

- no relevant seed observed under sufficient coverage
- no relevant seed observed under bounded or sampled coverage
- material not examined
- material that could not be examined

Unknown or unexamined content cannot be reported as negative evidence.

## Accepted Supporting Source Lookup Boundary

`ResearchSeedExtractionWorkflow` may perform Supporting Source Lookup for bounded clarification.

The lookup must have:

- declared questions
- enforced search, page, time, and cost limits
- registered discovered sources
- preserved query and provider context

Examples include determining whether an unfamiliar name denotes a product, ingredient, organization, or publication.

When the purpose becomes systematic procurement, coverage expansion, broad ranking, or corpus preparation, the workflow requests a linked `SourceDiscoveryWorkflow`.

A sandbox, browser, MCP search tool, or agent prompt does not expand this authority boundary.

## Accepted Graph-Lookup Boundary

Graph matching is optional and cannot be required for extraction completion.

A bounded Supporting Graph Lookup may:

- perform exact-name, identifier, or alias checks
- preserve query context
- preserve the observed graph version
- attach zero or more Graph Match Candidates to Entity Seeds

It may not:

- claim broad Knowledge Preflight coverage
- silently merge or retype seeds
- resolve entity identity
- mutate the graph

Broad graph search, prior-work comparison, contradiction analysis, and gap assessment belong to `KnowledgePreflightWorkflow`.

No observed match means only that no match was observed under the recorded lookup. It does not prove that an entity is absent.

## Accepted Output Contract

The immutable `Research Seed Extraction Result` binds:

- Research Seed Extraction Brief
- Extraction Subject Manifest
- Seed Mentions
- typed Extracted Seeds
- Seed Lineage Links
- Seed Confidence Profiles
- optional Graph Match Candidates
- registered sources from actual lookup
- Seed Extraction Coverage Assessment
- unresolved regions and ambiguities
- Decision Report

Successful workflow completion does not convert provisional seeds into accepted identity, evidence, research instruction, or graph knowledge.

## Accepted Review and Readiness Model

There is no universal human-review gate before any downstream use.

A purpose-bound Seed Use Readiness Assessment determines whether a result may be used for a particular downstream purpose and which review conditions apply.

Provisional seeds may guide:

- exploratory research
- Source Discovery
- Official Source Mapping
- further Knowledge Preflight

Consumers must preserve:

- provisional status
- confidence dimensions
- alternatives
- unresolved identity
- coverage gaps
- lineage

Human or independent review may be required by the brief or policy for:

- consequential ambiguity
- poor or uncertain coverage
- high-impact mission scoping
- identity-affecting decisions
- proposed ingestion or graph mutation
- other risk-sensitive downstream actions

Workflow completion, output validity, and readiness for a particular downstream use remain distinct.

## Accepted Evaluation Model

There is no single aggregate extraction-quality score.

The method-versioned Research Seed Extraction Evaluation Profile keeps separate:

- provenance and locator validity
- mention detection precision and recall where benchmark truth exists
- seed-family and subtype accuracy
- grouping quality
- split, merge, and retyping quality
- confidence calibration
- coverage-assessment accuracy
- preservation of unresolved ambiguity
- downstream usefulness

Evaluation evidence types remain distinguishable:

- deterministic contract checks
- labeled benchmark evaluation
- sampled independent review
- downstream outcome evaluation

Unsafe premature resolution does not count as extraction success.

The Decision Report summarizes decisions, alternatives, uncertainty, failures, tool usage, coverage, and evaluation references. It does not replace structured outputs or evaluation records.

## Explicit Non-Authority Rules

`ResearchSeedExtractionWorkflow` does not:

- accept a seed as authoritative identity
- adjudicate an Assertion as fact
- approve a source for research or ingestion merely because it was mentioned
- establish systematic source coverage through bounded lookup
- claim broad graph coverage through bounded matching
- write canonical graph knowledge
- grant itself capability through prompts or attached material
- treat sandbox files as canonical domain state

## Deferred Details

The following remain intentionally open:

- exact promotion thresholds between operation and standalone workflow
- exact subtype taxonomies within each seed family
- exact confidence scales and calibration methods
- exact coverage-profile variants
- exact review policies by downstream use
- exact operation and stage decomposition
- exact schemas and event contracts
- exact persistence model
- exact Temporal workflow and activity topology
- exact agent and subagent topology
- exact SDK, MCP, FastAPI, WebSocket, and UI bindings

## Relationship to the Reference Lifecycle

The reference composition now uses:

```text
Starter Content and Discussion
-> Starter Content Refinement
-> Knowledge Preflight
-> Mission Specification
-> Research Seed Extraction
-> Official Source Mapping
-> Source Discovery
-> Source Corpus Build
-> Mode-Specific Deep Research
```

This remains a reference composition rather than a mandatory linear pipeline. `ResearchSeedExtractionWorkflow` is independently runnable whenever its Input Admission Contract permits.

## Next Interview Boundary

The next architecture interview should begin detailed `OfficialSourceMappingWorkflow` modeling:

1. exact input variants and admission
2. mapping-target identity
3. verification evidence
4. confidence and competing candidates
5. claim-class scope
6. temporal validity
7. outputs and unresolved mappings
8. review and authority
9. mutation and ingestion boundaries
10. relationship to Source Discovery and Source Identity Resolution

