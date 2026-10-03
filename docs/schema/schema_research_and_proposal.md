# Agent team brief: finish the BellLabs schema proposal

Status: launch brief
Workspace: `biotech-meta/docs/schema/`
Live schema under audit: `current_biotech_schema.graphql` (read only)

You are an agent team finishing one coherent schema proposal for BellLabs. The proposal must say what the graph helps people know, which distinctions make those answers reliable, and how the current GraphQL schema and the provisional catalog meet.

This is research and design. Do not modify production data, apply migrations, replace `current_biotech_schema.graphql`, or commit secrets or personal health information. Research is not medical advice. Public evidence must not become a personal medical conclusion.

## Governing rule

Informational desires come first. Do not begin by adding nodes.

Work in both directions:

1. Desired knowledge → required distinctions → schema requirements.
2. Real sources → what those sources can and cannot establish → feasible answers.

Every material schema change must name the questions it makes answerable or safer. Every priority question must say whether the proposed model can answer it, can answer it only with qualifications, or needs information outside the graph.

Classify each selected question as:

- **Essential now** — required for the first BellLabs decision trail.
- **Foundational** — model it now, because adding it later would lose history or meaning.
- **Expansion** — valuable later, with a clear extension path.
- **Research frontier** — useful, but limited today by evidence or methods.

Treat “seminal,” “promising,” “well-supported,” and “close to market” as assessments with criteria and provenance, not permanent attributes.

For each selected question, record this trace in the ontology lab:

Informational desire → example answer → necessary distinctions → evidence requirements → nodes, relationships, and properties → query pattern → failure the model must prevent.

## What you are reconciling

Two models already exist. The job is to reconcile them, not to invent a third vocabulary.

| Artifact | Role | Authority |
|---|---|---|
| `current_biotech_schema.graphql` | Live Neo4j GraphQL schema, ~2883 lines | Product graph as implemented. Read it. Do not edit it. |
| `catalog/schema.yaml` | Provisional semantic contract `0.1.0` | Assertion-centered supplement slice. This is what you evolve. |
| `architecture.md` | Kernel, assertion pattern, time, forbidden implications | Accepted reasoning for v0.1. Extend it when a decision changes the kernel. |
| `ontology-lab/` | Questions, modules, rounds, property rules | Where design decisions are argued and recorded. |
| ADR 0002 | Assertion-centered temporal graph | Accepted for provisional v0.1. |

The live schema is broad and edge-centric. The catalog is narrower and assertion-centric. Preserve useful live concepts. In particular, keep `Claim`, `ClaimOccurrence`, `RelationshipAssertion`, `Document`, `DocumentTextVersion`, `Segmentation`, and `Chunk` unless a round shows they must merge with a catalog type, and then say which name wins.

### How the live schema is organized

Read interfaces and the section you own. Do not load the whole file into every specialist.

| Lines | Contents |
|---|---|
| 1–27 | Interfaces: `Entity`, `SearchIndexable`, `TemporalSnapshot`, `ActorIdentity`. Shared fields are `id`, `name`, `description`, `mongoResearchRunId`. Searchable types add `searchText` and embeddings. Snapshots add `validFrom` / `validTo` and `recordedFrom` / `recordedTo`. |
| 29–113 | Shared enums: `EvidenceStrength`, `AssociationPolarity`, `RoleType`, `CorporateRoleType`, `SeniorityLevel`. |
| 114–394 | `@relationshipProperties` types. Qualifiers live on edges: `TemporalMetadata`, `RoleMetadata`, `DoseMetadata`, `SafetyMetadata`, `AssociationMetadata`, `ExtractionMetadata`, `InterventionArmMetadata`, and others. |
| 396–651 | Organizations: `Organization`, `OrganizationSnapshot`, `PhysicalLocation`. Roles are edges such as employment, funding, and corporate relationships, qualified by `RoleMetadata`. |
| 653–686 | `Compound` and `CompoundForm`. Identity is a name plus CAS, formula, and weight. Forms point back with `IS_FORM_OF`. |
| 688–1068 | Commerce and interventions: `Product`, `ProductSnapshot`, `Procedure`, `Treatment`, `Listing`, `ListingSnapshot`, `FoodItem`, `Ingredient`, `FoodProduct`, `Exposure`, `Lifestyle`, `AdverseEffect`, `SafetySignal`. Product composition is `CONTAINS_COMPOUND_FORM` with `DoseMetadata`. Formulation is a `formulationSummary` string, not a versioned composition. |
| 1070–1145 | People: `Person`, `PseudonymousActor`, `AnonymousActor`, `CohortParticipant`. |
| 1147–1375 | Biology: `Mechanism`, `Pathway`, `Organ`, `Condition`, `Outcome`, `Biomarker`, `Metric`, `ReferenceRange`, `MolecularEntity`, `AnatomicalContext`, `Species`, `RiskFactor`. |
| 1377–1595 | Technology and care-adjacent types: `TechnologyPlatform`, `ToolOrInstrument`, `PanelDefinition`, `LabTest`, `MeasurementMethod`, `Specimen`, `Device`, `Modality`, `Sensor`, manufacturing types, regulatory types. |
| 1597–1754 | Studies: `Study` carries registry fields, PMID, DOI, design, and enrollment on the node. Arms, outcome measures, and results are separate types linked by edges. |
| 1756–2040 | Protocols: `Protocol`, `ProtocolStep`, `Constraint`, `MeasurementPlan`, `Target`, `FunctionalGoal`, `Observation`, `ProtocolAdjustmentRule`, `ProtocolResult`. This is a public protocol shape, not a private user record. |
| 2042–2179 | Events and narrative: `Community`, `Conference`, `Event`, `NarrativeArc`. |
| 2181–2379 | Large unions (`EvidenceSubject`, `ClaimSubject`, media subjects) and media enums. |
| 2381–2569 | Media: `MediaAsset`, `MediaVariant`, `MediaAnnotation`, `MediaSource`, `GraphView`, `FigurePanel`, `ProductLabelRegion`. |
| 2571–2883 | Evidence pipeline: `RelationshipAssertion`, `Document` → `DocumentTextVersion` → `Segmentation` → `Chunk`, then `Association`, `Claim`, `ClaimOccurrence`, `ExperienceReport`, `Episode`, `EpisodeSegment`, `Platform`, `Channel`, `Series`. |

Patterns you will see repeatedly in the GraphQL file:

- Almost every node implements `Entity` and uses `id: ID! @id`.
- Facts that should be disputable are often direct relationships with metadata, or strings such as `formulationSummary` and `evidenceLevel`.
- Historical state exists only where a `*Snapshot` type was added (`Organization`, `Product`, `Listing`).
- Evidence attachment is usually `SUPPORTED_BY_DOCUMENT` or `SUPPORTED_BY_CHUNK`, plus `Claim.evidenceStrength`.
- There is no private user graph: no goals-as-user-state, consent, recommendation snapshot, purchase lifecycle, or personal lab report owner.

### What the provisional catalog already decided

Read `architecture.md`, `catalog/schema.yaml`, and `OPEN-QUESTIONS.md` before proposing replacements.

The catalog uses six archetypes: `Entity`, `VersionedState`, `Occurrence`, `InformationArtifact`, `Assertion`, `EvidenceAssessment`. Identity is `uid` of the form `hu:<type>:<opaque-stable-id>`.

Source-derived propositions are `Assertion` nodes with a predicate, status, subject, object or typed literal, valid time, and recorded time. They point at `Source` → `SourceSnapshot` → `SourceLocator`. BellLabs judgments are `Adjudication` nodes, separate from what a source said.

Relationships are `structural`, `asserted`, or `derived`. A derived edge such as `CONTAINS` must name the assertion or rule it projects and must not be the only history.

The supplement backbone is:

```text
Product → ProductVariant → FormulationVersion → IngredientComponent → IngredientMaterial
LabelSnapshot declares a formulation; it is not measured composition
Study → StudyArm → StudyIntervention → InterventionComponent → IngredientMaterial
EvidenceApplicability compares an evidence target with a use target
```

Forbidden implications already in the catalog stay in force until a round overturns one with a source and a failing case:

- advising an organization does not endorse its product
- distributing a product does not mean manufacturing it
- sponsoring a study does not mean executing it
- listing an offer does not mean selling it
- an orphan designation is not an approval
- an NDI notification is not FDA approval
- “provides a constituent” is not a measured quantity

Unknown, unmeasured, not reported, below detection, absent, and false stay distinct. A missing field is not evidence that a fact ended.

The catalog does not yet own protocols, diagnostics, devices, mechanisms, media, narrative, documents-as-ingestion, or private user context. `ontology-lab/modules.yaml` marks diagnostics and consumer devices as future, and safety and recommendation decisions as candidate.

## Where to write

Write the proposal into this workspace. One integration owner keeps the five surfaces consistent. A concept is not done when it exists in only one of them.

| Surface | Write | Do not write |
|---|---|---|
| `ontology-lab/` | Competency questions, module ownership, round records, property decisions | Production GraphQL |
| `catalog/schema.yaml` | The semantic contract: labels, predicates, relationship class, invariants, maturity | A second competing catalog |
| `sources/source-registry.yaml` | Sources that justify a modeling decision, with claim-specific authority | Global truth rankings of organizations |
| `neo4j/` | Constraints and validation queries that project accepted catalog rules | A replacement of the live GraphQL schema |
| `examples/` | Synthetic or public fixtures and the Cypher that shows the distinction | Canonical production data |

Companion updates when a catalog change is accepted:

- `CHANGELOG.md` for the semantic version
- `OPEN-QUESTIONS.md` when a question is answered or a new blocker appears
- `architecture.md` when the kernel, time model, or a forbidden implication changes

Round files use `ontology-lab/round-template.md` and are named `ontology-lab/round-NNNN-<slug>.md`. Round 0001 (`round-0001-product-continuity.md`) is the pattern: product continuity and evidence transfer. Continue from round 0002. Do not reopen 0001 unless a new source breaks it.

Catalog versioning: breaking meaning changes increment `catalog/schema.yaml` `version`, record migration notes, and keep previously committed assertions interpretable.

Proposed GraphQL, if a round needs a parsable projection, goes in `neo4j/proposed-delta.graphql` as a delta against the live schema. It is a proposal. It does not replace `current_biotech_schema.graphql`.

## Team and sequence

Use one integration owner and these specialist lanes. Combine lanes if the team is smaller. The integration owner rejects concatenated reports.

1. Questions, product access, and query shapes.
2. Organisms, compounds, mechanisms, interventions, studies, and evidence applicability.
3. Diagnostics, devices, manufacturing, regulatory status, and commerce.
4. Documents, claims, speakers, attribution, and provenance.
5. Time, private user context, protocols-in-use, and recommendation history.
6. Integration and adversarial review.

Sequence:

1. Parallel read of this brief, `architecture.md`, `catalog/schema.yaml`, `ontology-lab/modules.yaml`, `ontology-lab/competency-questions.md`, `OPEN-QUESTIONS.md`, and the GraphQL sections you own.
2. Agree on the question catalog and on identity rules before writing domain modules.
3. Each lane opens rounds that cite sources and name a failure case.
4. Specialists review one another. The challenger must supply a concrete failing case, not a naming preference.
5. The integration owner merges accepted decisions into the catalog, Neo4j projection, fixtures, and source registry.

Shared concepts have one owner. Other modules reference them. `Assertion`, `Source`, `SourceLocator`, `Adjudication`, and temporal fields are kernel-owned.

## Research tools

Use external sources to test whether a proposed property can be populated and what a source is allowed to establish. Record the source in `sources/source-registry.yaml` with `authorityFor`, `notAuthorityFor`, and `schemaConsequences`. Store locators and the modeling consequence, not scraped page dumps.

| Need | Use |
|---|---|
| Current web, company pages, filings, explainers, comparisons | Tavily search, extract, and research (`user-tavily-remote-mcp`, or the `tavily-*` skills) |
| A known URL, a site map, or a structured page capture | Firecrawl scrape, map, crawl, or extract |
| Biomedical literature | Firecrawl research paper tools, or PubMed / NCBI (PMID, abstract, publication type, retraction or correction status) |
| Trial identity, arms, interventions, outcomes, and status | ClinicalTrials.gov (NCT id, versions, results section when present) |
| Regulatory, patent, and label identity | Primary agency or registry pages already patterned in the source registry (FDA, NSF, patent records) |
| Code and schema behavior in this repo | Local reads of `current_biotech_schema.graphql` and this workspace |

Authority is claim-specific. A manufacturer page can establish what the company currently displays. It cannot establish independent efficacy, historical formulation, or lot composition. A paper can establish what that paper reported about its intervention. It cannot establish that a later commercial product is the same thing. A trial registry can establish registered design and status. It is not a results publication unless results are actually posted.

Do not treat model agreement as domain validation. Cite the source that forces the distinction.

## Seed questions

These are seeds, not the catalog. Expand them through research into distinct desires. Each domain lane adds consumer questions, researcher questions, operator questions, agent questions, misleading-simplification questions, and cross-domain questions. Prefer distinct evidence requirements over a long repetitive list.

**Claims and speakers.** What did a named speaker claim in a specific episode, and which span supports it? Was it a personal experience, a manufacturer claim, a mechanism story, or a study result? Did later retellings drop a qualification? Which financial relationship is relevant to the recommendation?

**Mechanisms.** Which steps were measured, and which were inferred? In which species, tissue, dose, and setting? Does an ingredient effect imply the commercial formulation delivers that exposure?

**Studies.** Which findings from a stated period changed the evidence picture, by which criteria? Which papers share a dataset? Which outcomes are surrogate endpoints? What do null results and adverse events change?

**Diagnostics.** What does the test measure, and what does it infer? Can two similarly named assays be compared over time? Which reference interval applies, and which algorithm version produced a score?

**Products and formulations.** Which chemical form and amount are declared? Is the amount the full compound, an active moiety, or an extract marker? Was the commercial product studied, or only an ingredient? Which claims attach to a version or lot?

**Manufacturing and readiness.** What did a filing actually disclose? Which capabilities are operating, piloting, planned, or only promoted? Which conclusion is a company statement, and which is our inference?

**Protocols.** Which steps are essential, conditional, or dependent? What changed between versions? What is missing before a person can evaluate the protocol? Which observations should trigger review?

**Ecosystem.** Which organizations, people, funders, suppliers, patents, and studies form a neighborhood? Where does similar work use different names?

**Provenance.** For each assertion in an answer: exact passage, speaker, assessment status, captured source version, and whether a conversion or attribution error could change the conclusion. Separate these five states: someone said it; a source supports it; evidence warrants a broader conclusion; an agent used the source; a policy allows a downstream use.

**Time.** What was recorded as believed on date R about what was true on date V? When did the world change, when was it disclosed, and when did the system learn it? A correction is not the same event as a fact ending.

**Private context.** What was the person trying to improve? Which options were recommended, rejected, and selected? Which personal context and evidence versions existed at recommendation time? What are they waiting on? What may be shared, with whom, and for how long? New measurements do not rewrite the earlier decision.

The ontology lab already has starter questions `CQ-ID-*`, `CQ-EV-*`, `CQ-TM-*`, and `CQ-RC-*` in `ontology-lab/competency-questions.md`. Extend that file. Do not start a second question list with different IDs for the same desire.

## Property standard

Properties are a primary deliverable. For each new or changed property on a node or relationship, state: name, definition, type, cardinality, nullability, units or identifier namespace, example, counterexample, meaning of absence, expected source, whether it is asserted, observed, calculated, inferred, or operational, temporal behavior, provenance, query use, and privacy class.

Place the fact where its lifecycle belongs:

- node property, when it is atomic and has no independent dispute history
- relationship property, when it qualifies one edge and shares that edge’s life
- referenced entity, when it has its own identity
- versioned state or snapshot, when the value changes on a bounded interval
- assertion, when a source claims it and the claim can be disputed
- evidence assessment, when BellLabs judges applicability or strength
- derived projection, when it can be regenerated and must not be the historical record

Do not add generic `description`, `status`, `type`, `confidence`, or JSON fields where a query needs a precise filter. Do not create a node for every scalar. Keep one confidence vector with separate dimensions, as in `ontology-lab/README.md`: extraction, resolution, source reliability, evidence strength, applicability, adjudication, and decision confidence. A single `confidence` or `verified: true` is not the authoritative verdict.

## Private data

The shared world model and private user context stay logically separate. Recommend one initial physical placement after comparing: shared Neo4j with enforceable isolation, a separate graph, transactional user storage plus a graph projection, or a hybrid. Name the owner of each category. If another store holds a projection, state how sync and deletion propagate.

Private records reference stable shared identifiers and must not leak into public queries. A recommendation snapshot keeps the personal-context version, evidence versions, options considered, selection, rationale, uncertainty, intended use, and algorithm or policy version.

`Observation` in the live schema is a protocol-linked type. Do not silently reuse it as the person’s private measurement store without an explicit ownership decision.

## Done

The integration owner delivers the package in this workspace when an implementer can tell:

- what each changed type, relationship, and property means
- which live GraphQL concepts are kept, refined, merged, split, or left as seams
- how a representative source is ingested without dropping qualifications
- how priority questions are answered, and which remain qualified or out of scope
- how an answer traces to a source locator and an adjudication
- how a correction and a late-arriving fact are stored
- where private data lives
- which decisions are still open and what evidence would close them

Minimum artifacts:

1. Expanded competency questions in `ontology-lab/competency-questions.md`, with priority and a question-to-model trace for each essential and foundational question.
2. Round records for the decisions that change the catalog, including at least product and formulation continuity, evidence applicability, claim and document provenance against the live evidence pipeline, and private recommendation history.
3. Updated `ontology-lab/modules.yaml` with one owner per shared concept.
4. Updated `catalog/schema.yaml` and `CHANGELOG.md`.
5. Source-registry entries for the sources those decisions rely on.
6. Neo4j validation queries for every new invariant, and constraints only where Neo4j can enforce them. Mark other rules as service-enforced.
7. At least one new example fixture beyond `examples/elysium-basis.cypher` that fails if a forbidden implication or identity collapse is reintroduced. Cover a second situation the Elysium fixture does not: a study-versus-product mismatch, a diagnostic comparison, a filing-versus-capability distinction, or a recommendation snapshot.
8. A short integration note at `ontology-lab/proposal-index.md` that links the rounds, lists keep / refine / merge / defer decisions against the live schema, and states the private-data placement.

Mark every example query as executed, statically checked, or illustrative. Do not imply a query ran if it did not.

Stop when the five write surfaces agree. Do not stop at a brainstorm, a field list, or a diagram.
