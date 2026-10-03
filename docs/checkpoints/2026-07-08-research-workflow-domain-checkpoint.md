# Research Workflow Domain Checkpoint

Date: 2026-07-08 (1+ week old)

This checkpoint captures the current shared understanding for the Human Upgrade research, ingestion, evaluation, and content creation system. It is intentionally not final. It exists so future design discussion can continue from stable terms and decisions instead of re-litigating vocabulary.

## Current Direction

The system should transform messy starter material into a biotech, longevity, biohacking, and avoidance-oriented knowledge platform.

The common end-to-end shape is:

```text
Starter Content
-> Starter Content Refinement
-> Mission Instructions
-> Source Discovery and Selection
-> Research
-> Ingestion Plan
-> Ingestion
-> Content Creation
-> Evaluation
```

This sequence is not a rigid pipeline. Each major part is also a composable mini-workflow that can be run independently from the dashboard or API.

## Central Unit

The central research unit is the **Research Mission**.

Episodes, folders, transcripts, notes, PDFs, images, prior summaries, and source lists are starter material. They can seed a Research Mission, but they are not the central organizing object.

Research Missions can begin from:

- one episode workspace
- multiple episode workspaces
- a topic
- a product
- a compound
- an organization
- a person
- a claim
- a completed report
- an operator instruction
- a user question
- an existing graph entity

## Composable Workflow Types

The first accepted working set of Workflow Types is:

- `StarterContentRefinementWorkflow`
- `MissionInstructionWorkflow`
- `EntitySeedExtractionWorkflow`
- `OfficialSourceMappingWorkflow`
- `SourceDiscoveryWorkflow`
- `SourceCorpusBuildWorkflow`
- `ResearchExecutionWorkflow`
- `EvidenceAdjudicationWorkflow`
- `ReportCreationWorkflow`
- `IngestionPlanWorkflow`
- `IngestionExecutionWorkflow`
- `ContentCreationWorkflow`
- `EvaluationWorkflow`

Each Workflow Type should define:

- schema
- control configuration
- execution rules
- operational artifacts
- decision reports
- evaluation expectations

Each Workflow Run may execute inside a Research Mission or independently from a dashboard/API action.

## Starter Content Refinement Workflow

The first workflow under detailed design is `StarterContentRefinementWorkflow`.

Purpose:

Transform messy Starter Content into a clarified, integrity-checked, graph-aware Starter Package that is ready for precise Mission Instructions.

Likely stages:

```text
Starter Artifact Discovery
-> Artifact Integrity Check
-> Starter Content Clarification
-> Agentic Seed Extraction
-> Broad/Fuzzy Graph Lookup
-> Early Source Discovery
-> Repair Artifact Generation
-> Starter Package Assembly
-> Refinement Decision Report
```

Accepted behavior:

- The workflow may use web search and browser control if configured.
- The workflow may start from raw Starter Content refs or from an existing Starter Package version.
- The workflow may perform early source discovery.
- The workflow may perform broad and fuzzy graph/database lookup.
- Graph lookup decisions must be labeled carefully.
- The workflow may generate repair artifacts.
- Repairs may be emitted as new versions or may overwrite originals when an explicit overwrite policy allows it.
- It must not silently overwrite original starter artifacts.
- It should emit a human-readable Decision Report.

Starter Package should include:

- package id
- package type
- package version
- parent package version when re-refined
- origin
- operator intent
- starter artifacts
- extracted seeds
- integrity findings
- permissions findings
- graph/database lookup context
- early source candidates
- repair artifacts
- recommended next workflows
- mission instruction draft or mission direction
- version history

## Graph Lookup During Refinement

Graph/database lookup belongs inside Starter Content Refinement as context discovery.

It should be broad and fuzzy by default because non-obvious entities may matter. The agent should infer lookup targets from starter content, not only search obvious names.

Possible lookup targets:

- people
- organizations
- products
- compounds
- biomarkers
- diseases and conditions
- claimed technologies
- devices
- clinical trial ids
- official domains
- sponsor names
- episode URLs and hashes
- aliases
- topic clusters

Lookup results should be labeled, for example:

- `direct_identity_match`
- `probable_identity_match`
- `related_topic_match`
- `related_product_match`
- `possible_duplicate`
- `background_context`
- `weak_match`
- `needs_resolution`

Strict identity resolution belongs later in Official Source Mapping and Ingestion Plan workflows.

## Source Model

Sources are subtle and important. Source discovery may happen through Tavily, Firecrawl, browser control, SERP APIs, direct fetch, internal API search, or future tools.

Two source decisions are distinct:

- **Research Source Selection**: the source may be used provisionally for reasoning.
- **Ingestion Source Selection**: the source may become durable provenance, document, media, or graph-attached material.

Agents may reason from research-only sources that are not ingestible because of rights, paywalls, access, or licensing. Those sources must be labeled `research_only` and cannot become claim provenance unless an ingestible Source Ref is available.

The source status vocabulary should include:

- `candidate`
- `research_selected`
- `research_used`
- `rejected`
- `ingestion_candidate`
- `ingestion_approved`
- `ingested`
- `research_only`

## Media and Documents

Media ingestion is first-class, not an afterthought.

The system must handle:

- high-quality photos
- screenshots
- charts
- diagrams
- videos
- audio
- PDF documents
- web pages
- product labels
- publications
- official media kits

Source Corpus building must decide how to convert, split, embed, and connect media and documents.

The connection model must support both whole-document and chunk-level relationships. The exact rules remain open.

Known design pressure:

- Whole-document connections preserve high-level provenance.
- Chunk-level connections improve retrieval precision and claim grounding.
- Both are likely required.

## Official Source Mapping

Official Source Mapping should usually run early after entity seed extraction.

It finds and verifies official sources for:

- people
- organizations
- products
- trials
- publications
- regulatory records
- media assets
- technologies

Official sources are authoritative for identity and self-claims. They are not automatically authoritative for scientific truth.

Low-risk official entity identification and ingestion may complete without explicit ingestion approval when configuration allows it. The Research Mission model must still support approval gates for this type of ingestion.

## Storage Alignment

Storage should be layered.

### Sandbox Workspace

The Sandbox Workspace is an isolated execution computer for agents. It may contain:

- browser state
- downloads
- working files
- generated reports
- agent skills
- `AGENTS.md` or memory files
- Python and TypeScript runtimes
- workflow-specific workspaces
- temporary artifacts

Sandboxes may be ephemeral or saved as snapshots.

### Mongo

Mongo is the preferred store for flexible research runtime data:

- workflow runs
- starter packages
- source intelligence cache
- extraction attempts
- decision reports
- repair manifests
- source candidates
- flexible artifacts
- source usage history
- sandbox snapshot metadata

### S3

S3 stores large blobs:

- transcript copies
- PDFs
- images
- screenshots
- videos and audio where allowed
- converted text files
- extracted document payloads
- sandbox snapshots
- generated large artifacts

### NEO4J and Authoritative Graph

Neo4j/Graph stores approved graph knowledge:

- canonical entities
- approved documents
- approved media
- approved Source Refs
- claims
- relationships
- embedding/index state
- graph provenance

Only approved Source Ref, Document, Media, and provenance records should be attached to saved entities and relations.

## Source Intelligence Cache

The Source Intelligence Cache should be durable and reusable. It belongs in the research runtime store, likely Mongo.

It records temporal and usage information so source search becomes more efficient over time.

Important fields:

- canonical source identity
- first seen time
- last visited time
- last extracted time
- last used time
- visit count
- extraction attempts
- tool history
- current summary
- detected entities
- detected claims
- quality signals
- official-source status
- paywall/access status
- usage history
- rejection history
- source freshness policy

Source cache records are not graph provenance by themselves. Approved Source Refs, Documents, and Media are promoted through ingestion workflows.

## Sandbox Snapshot Policy

Sandbox snapshots should be optional and policy-driven.

Do not always save full snapshots. Save lightweight run metadata always.

Save snapshots when:

- browser control was used
- files were downloaded
- repair artifacts were generated
- an operator requested reproducibility
- the workflow is high-risk or high-value
- a failure/debug state needs preservation

The lightweight run data should be sufficient to populate a future sandbox with the right starter package, S3 refs, source cache refs, workflow config, tool policy, skill bundle version, model/runtime versions, prior decisions, and run events.

## Decision Reports and Learning Loop

Every Workflow Type should produce a Decision Report.

Decision Reports should have configurable depth or effort because of budget concerns:

- `minimal`
- `standard`
- `audit`

Decision reporting may be more granular than the workflow itself. Important sub-stages and decision points can produce their own reports.

Decision Reports are part of a recursive learning workflow:

```text
Workflow Run
-> Decision Report
-> Evaluation
-> Improvement Candidate
-> Prompt, Skill, Schema, or Config Update
-> Future Workflow Runs
```

The system should not blindly fine-tune from its own reasoning. Decision Reports should feed evaluation and improvement candidates. Promotion into prompts, skills, schemas, configs, or fine-tuning datasets should require review or measured performance gains.

## Control Configuration Themes

Each workflow needs configurable control.

Important controls:

- tool access
- web search access
- browser control
- filesystem read/write
- graph lookup access
- source cache read/write
- source freshness
- repair policy
- overwrite policy
- approval policy
- model choice
- budget
- decision report effort
- sandbox snapshot policy
- trust mode
- ingestion policy
- evaluation gates

The system should be dynamic. Trust can increase over time, and the same Workflow Type should run differently under different configurations.

## Open Questions

These remain unresolved and should guide the next grilling sessions:

- What is the exact schema for `StarterPackage`?
- What is the exact control configuration schema for `StarterContentRefinementWorkflow`?
- How should `DecisionReport` be structured so it is useful for both humans and learning loops?
- What are the rules for whole-document versus chunk-level connections?
- What exactly qualifies a source for research-only use versus ingestion eligibility?
- Which official entity records can be auto-ingested without approval?
- What source freshness windows should be used for official pages, papers, trial records, product pages, and media?
- What should a sandbox workspace template contain for each Workflow Type?
- Which Workflow Runs can be started independently from the dashboard?
- How should evaluation findings become improvement candidates?

## Next Discussion Target

Continue drilling into `StarterContentRefinementWorkflow`, starting with:

- input schema
- output schema
- repair policy
- graph lookup policy
- source cache policy
- decision report schema
- execution rules
