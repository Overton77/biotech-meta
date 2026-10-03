# Ecosystem Mapping Cycle

The first major BellLabs research cycle should be ecosystem mapping. Before running hundreds of knowledge-graph-specific entity research jobs, the system needs a ranked map of the biotech, biohacking, longevity, diagnostics, wellness technology, and consumer health landscape.

This is a coverage problem first. BellLabs needs to know which domains matter, which entities dominate or connect those domains, which products and services users can actually act on, and where the knowledge graph is thin.

## Purpose

Ecosystem mapping creates the origin surface for future research and ingestion.

It should produce:

- Biotech industry and ecosystem divisions.
- Top corporate entities within each division.
- Important products, services, tests, devices, platforms, and protocols.
- Prominent people, practitioners, researchers, executives, investors, creators, and communities.
- Key compounds, biomarkers, mechanisms, procedures, manufacturing processes, and technologies.
- High-signal documents, videos, studies, trials, podcasts, reports, case studies, and regulatory sources.
- Coverage gaps in the current knowledge graph schema and data.
- A ranked backlog of entity research targets.

This is not yet evidence adjudication. The goal is to represent the world faithfully and identify what deserves deeper research.

## Core Principle

Entity research creates the map. Investigative research uses the map.

Ecosystem mapping should stay close to truth-tracking:

- What exists?
- Who makes it?
- Who uses it?
- What category does it belong to?
- What claims are made about it?
- What evidence or source types are attached to it?
- What products, services, people, mechanisms, and use cases does it connect to?
- How prominent, actionable, risky, or under-covered is it?

The intelligence layer can later retrieve this map to compare, recommend, investigate, warn, or personalize.

## Iterative Mapping Process

### Pass 1: Division Taxonomy

Start by producing a broad category map of the biotech and longevity ecosystem.

Initial divisions:

- Consumer diagnostics and lab testing.
- Biological age and epigenetic clocks.
- Microbiome testing and therapeutics.
- Wearables and continuous monitoring.
- Supplements and nutraceuticals.
- Longevity clinics and concierge medicine.
- Regenerative medicine and cell therapies.
- Gene therapy and gene editing.
- Senolytics and cellular aging.
- Mitochondrial health.
- Metabolic health and GLP-1 adjacent ecosystems.
- Peptides and hormone optimization.
- Sleep, recovery, HRV, and nervous system regulation.
- Light, sound, oxygen, heat, cold, and other modality devices.
- Women's health, fertility, menopause, and ovarian aging.
- Bone, muscle, and physical performance.
- Neurotechnology and cognitive enhancement.
- Psychedelic medicine and neuroplasticity.
- Cancer screening and early detection.
- Cardiovascular prevention and lipid management.
- Immune health and inflammation.
- Biomarker analytics and lab interpretation platforms.
- Clinical trial platforms and patient recruitment.
- Biomanufacturing and supply chain.
- Research tools, assays, and instrumentation.
- Biotech data platforms, AI biology, and computational biology.
- Public biohacking figures, protocol creators, and communities.

The output should be a living taxonomy, not a fixed ontology. New divisions can be added when agents discover recurring clusters.

### Pass 2: Division Profiles

For each division, create a profile:

- Definition and scope.
- User-facing relevance.
- Commercial maturity.
- Safety and regulatory sensitivity.
- Important source types.
- Top companies.
- Top products or services.
- Key people and institutions.
- Key mechanisms, biomarkers, or technologies.
- Open questions.
- KG schema implications.

This pass gives future agents enough context to research a division without starting cold.

### Pass 3: Top Entity Discovery

Within each division, identify candidate entities.

Sources:

- Web search.
- Firecrawl crawls and extracted pages.
- Tavily-style search results.
- Company websites.
- Product listing pages.
- PubMed.
- ClinicalTrials.gov.
- FDA, EMA, FTC, SEC, and other regulatory sources.
- Crunchbase-like company databases if available.
- Investor portfolios.
- Conference agendas and exhibitor lists.
- YouTube interviews and podcast transcripts.
- Practitioner protocols.
- Community forums and testimonial spaces.
- Scientific reviews and industry reports.

Agents should record discovered entities with source provenance, not just names.

### Pass 4: Ranking And Prioritization

Every candidate entity should receive a research priority score.

Suggested scoring dimensions:

- User decision relevance: does this entity influence purchases, protocols, tests, treatments, or dashboards?
- Graph centrality: does it connect to many other important entities?
- Market prominence: is it widely known, purchased, discussed, funded, cited, or followed?
- Evidence importance: is it connected to major studies, mechanisms, biomarkers, or safety claims?
- Freshness volatility: does it change frequently, such as startups, product lines, pricing, regulation, or trials?
- Commercial actionability: can a user buy, use, test, integrate, track, or compare it?
- Coverage gap: is BellLabs missing it or representing it weakly?
- Trust and risk sensitivity: would misinformation about this entity be harmful?
- Platform storytelling value: does it help demonstrate the BellLabs product vision?
- Schema pressure: does it reveal missing entity types, relationships, or properties?

The result should be a ranked research coverage surface.

### Pass 5: Expansion Edges

Every high-value entity should generate expansion edges.

Corporate entities may lead to:

- Products.
- Services.
- Listings.
- Executives and founders.
- Scientific advisors.
- Investors.
- Manufacturing partners.
- Suppliers.
- Regulatory filings.
- Clinical studies.
- Patents.
- Claims.
- Competitors.
- Distribution channels.
- Practitioner use.
- User testimonials.

Products may lead to:

- Ingredients.
- Compounds.
- Mechanisms.
- Biomarkers.
- Contraindications.
- Protocol steps.
- Devices.
- Lab methods.
- Manufacturing processes.
- Evidence bundles.

People may lead to:

- Protocols.
- Companies.
- Publications.
- Podcasts.
- Communities.
- Investment activity.
- Public claims.
- Product recommendations.

This is how the map fans out from divisions into an explorable graph.

### Pass 6: Schema Feedback

Ecosystem mapping should pressure-test the knowledge graph schema.

Agents should flag:

- Entity types that do not fit cleanly.
- Relationships that are missing.
- Relationship properties needed for provenance, confidence, time, dose, listing state, or safety.
- Important source types not represented.
- Commerce concepts not represented.
- Personal graph concepts that should remain separate.
- Regulatory or manufacturing details that need better modeling.

Schema feedback should be reviewed separately from ingestion. Discovery should not automatically mutate the production schema.

### Pass 7: Coverage Evaluation

After each mapping batch, run coverage evals:

- Are the most obvious entities in each division present?
- Are top entities connected to products, people, claims, and sources?
- Are categories balanced or overfocused on familiar brands?
- Are regulated and high-risk domains marked clearly?
- Are source types diverse enough?
- Are there stale or unsupported claims?
- Are important non-US entities missing?
- Are there duplicates or ambiguous entity identities?

Coverage quality should be visible in the control plane.

## Agent Workflow Design

A half-day ecosystem mapping run can be done with parallel Cursor SDK agents if the workflow is carefully staged.

### Stage A: Taxonomy Builders

Run several agents in parallel to propose ecosystem divisions from different perspectives:

- Consumer health and biohacking.
- Clinical biotech and therapeutics.
- Diagnostics and lab testing.
- Devices and wearables.
- AI biology and computational platforms.
- Longevity practitioners and communities.
- Biomanufacturing, supply chain, and regulatory infrastructure.

The merge agent reconciles overlapping categories into the first taxonomy.

### Stage B: Division Scouts

Assign one or more agents per division. Each scout returns:

- Category definition.
- Top 25-100 entities.
- Source list.
- Prominence notes.
- Actionability notes.
- Risk notes.
- Expansion edges.
- Schema pressure notes.

### Stage C: Source Procurement Agents

Specialized agents gather source surfaces:

- Search result pages.
- Company sites.
- Product pages.
- PubMed review articles.
- ClinicalTrials.gov queries.
- FDA and regulatory pages.
- YouTube and podcast candidates.
- Conference and investor portfolio pages.

These agents should produce registered sources, not conclusions.

### Stage D: Entity Rankers

Rankers normalize candidates across divisions and score them with the prioritization rubric.

They should identify:

- Top global entities.
- Top entities per division.
- Under-covered but high-value entities.
- High-risk entities.
- High-commerce entities.
- High-schema-pressure entities.

### Stage E: Deduplication And Identity Resolution

Before the ranked surface becomes a backlog, run identity resolution:

- Merge aliases.
- Separate similarly named companies or products.
- Attach known identifiers.
- Record uncertainty.
- Preserve source provenance.

### Stage F: Coverage Surface Compiler

The compiler produces:

- Division taxonomy.
- Division profiles.
- Ranked entity backlog.
- Source registry.
- Expansion graph outline.
- Schema feedback report.
- Recommended first entity research batches.

## Tooling

Recommended tool stack:

- Cursor SDK for launching, tracking, and resuming long-running agents.
- Cursor Cloud Agents for parallel division scouts and source procurement.
- Local cron-like schedules for recurring small refreshes.
- Cursor cloud schedules for larger recurring mapping and maintenance jobs.
- Firecrawl for search, scrape, crawl, and source extraction.
- Tavily or equivalent for broad search discovery.
- Browser control for pages that require interaction or visual inspection.
- PubMed and ClinicalTrials.gov tools for biomedical source grounding.
- YouTube and transcript tools for practitioner, testimonial, and podcast surfaces.
- Neo4j queries for existing KG coverage checks.
- MongoDB for run state, candidate entities, scoring, and source registry.
- S3 or equivalent for large source artifacts.

## Keeping Local And Cloud Schedules In Sync

BellLabs should maintain one schedule registry rather than scattered cron jobs.

Each scheduled job should define:

- Name.
- Owner.
- Trigger.
- Local or cloud runtime.
- Prompt or workflow config.
- Tool profile.
- Data permissions.
- Expected artifacts.
- Budget.
- Frequency.
- Last successful run.
- Failure policy.
- Related project goals.

Local cron-like schedules can handle cheap checks, local indexing, and development tasks. Cursor cloud schedules can run longer research and mapping jobs. Both should write back to the same run registry and coverage dashboard.

## Outputs

The ecosystem mapping cycle should produce a durable document and machine-readable artifacts.

Human-readable outputs:

- Ecosystem taxonomy.
- Division profiles.
- Top entity lists.
- Schema feedback notes.
- Coverage gap report.
- Recommended research batches.

Machine-readable outputs:

- Candidate entity records.
- Source registry records.
- Ranking scores.
- Entity alias sets.
- Expansion edges.
- Workflow traces.
- Eval cases.

## First Half-Day Run

A realistic first run:

1. Build an initial taxonomy with 6-8 taxonomy agents.
2. Select 12-20 highest-priority divisions.
3. Run division scouts in parallel.
4. Gather source registries for each division.
5. Rank candidates globally and per division.
6. Deduplicate obvious aliases.
7. Compile a top 250 entity backlog.
8. Identify the top 50 entity research runs.
9. Produce schema feedback.
10. Create coverage eval questions.

The goal is not perfection. The goal is a high-quality origin map that makes the next hundred research runs intentional.

## First Entity Research Batches

Recommended initial batches:

- Consumer diagnostics and lab testing companies.
- Biological age and epigenetic clock providers.
- Microbiome testing and intervention companies.
- High-profile supplement and nutraceutical brands.
- Wearables and continuous monitoring platforms.
- Public longevity practitioners and protocol creators.
- Light, oxygen, cold, heat, and recovery devices.
- Key compounds and intervention categories.
- Longevity clinics and concierge health platforms.
- AI biology and biotech data infrastructure companies.

These batches are broad enough to validate the schema and product vision, but concrete enough to produce useful graph coverage quickly.
