# Roadmap

BellLabs should be built in phases that compound. The first versions should prove the graph, agentic research, decision provenance, and personal tracking loop before trying to become a full marketplace or ME2 simulator.

## Phase 0: Foundation

Goal: make the current graph and research assets legible and usable.

- Stabilize the Neo4j GraphQL API and schema map.
- Generate compact schema maps for ingestion and agent use.
- Create canonical entity pages for organizations, products, lab tests, biomarkers, mechanisms, studies, protocols, claims, and documents.
- Build basic Graph RAG over the KG, chunks, and vector indexes.
- Create a research run registry in MongoDB.
- Store research artifacts in a consistent directory or object store structure.
- Define evidence bundle, claim, source, and decision ledger schemas.
- Add safety boundary language and initial health-risk categories.

## Phase 1: Research Mission MVP

Goal: let a user start a structured research campaign from a question or KG entity.

- Implement KG preflight for entity resolution and nearby context.
- Support Stage DAG Mode and Iterative Stage Mode.
- Add source procurement and source registration.
- Generate a cited research report.
- Generate ingestion candidates from the report.
- Generate eval cases from the mission.
- Add human checkpoints before high-risk conclusions.
- Add run trace inspection.

Example MVP missions:

- "Map TruDiagnostic and competing biological age testing companies."
- "Investigate Qualia senolytic claims and related mechanisms."
- "Find real-world testimonials and safety concerns for Evenity."

## Phase 2: Context-Aware Ingestion

Goal: turn research outputs into graph improvements with reviewable decisions.

- Build compact-schema selection.
- Retrieve relevant full schema sections.
- Extract entities, relationships, claims, and evidence.
- Query Neo4j for existing matches.
- Produce create, update, merge, replace, disconnect, ignore, or defer decisions.
- Add review UI for ingestion decisions.
- Execute approved writes.
- Validate graph changes.
- Add rollback metadata.

This phase turns BellLabs from a research assistant into a compounding knowledge system.

## Phase 3: Agentic Cart And Decision Ledger

Goal: make product decisions inspectable and durable.

- Create agentic cart item model.
- Link cart items to goals, protocols, evidence bundles, sources, and alternatives.
- Track external checkout state manually at first.
- Add reminders for pending lab tests, reports, device arrival, and protocol starts.
- Add "why this is in my cart" views.
- Add commercial relationship labels.
- Add risk-based purchase friction.

MVP categories:

- Lab tests.
- Supplements.
- Devices.
- Wearables.
- Educational guides.

## Phase 4: Personal Health Graph And Dashboard

Goal: connect user data, reports, and protocols without confusing exploration for diagnosis.

- Build personal graph separate from public KG.
- Upload and parse lab reports.
- Extract biomarkers, units, reference ranges, specimen data, and dates.
- Add user goals, constraints, observations, and protocol states.
- Build dashboards for biomarker panels and protocol timelines.
- Add wearable integration prototypes.
- Link personal measurements to public biomarker and mechanism entities.
- Add clinician-review prompts for high-risk values.

## Phase 5: Protocol Studio

Goal: make biohacking workflows feel like structured sprints.

- Create protocol templates.
- Support forks, versions, changelogs, and retrospectives.
- Add measurement plans.
- Add protocol step scheduling.
- Add adherence and subjective check-ins.
- Add agent reviews at checkpoints.
- Add stop conditions and safety gates.
- Add community sharing with redaction and evidence links.

## Phase 6: Workflow Control Plane

Goal: make research and ingestion workflows observable, interruptible, and composable.

- Adopt Temporal for durable orchestration.
- Wrap agent runtimes as workers.
- Add signals for pause, resume, cancel, message injection, source addition, and goal adjustment.
- Add cross-stage event bus.
- Add human checkpoint UI.
- Add workflow composition.
- Add budget and model routing controls.
- Add scheduled monitoring workflows.

## Phase 7: Evaluation And Learning System

Goal: measure the system surfaces that matter.

- Build Graph RAG eval suites.
- Build ingestion eval suites.
- Build workflow quality evals.
- Build safety and refusal evals.
- Build citation-fidelity checks.
- Build source-quality classifiers.
- Generate evals after every research mission.
- Compare model and prompt variants.
- Begin fine-tuning only after high-quality labeled traces exist.

## Phase 8: Marketplace And Community

Goal: make BellLabs a serious platform for high-quality health systems, guides, protocols, and products.

- Add public and private guides.
- Add protocol publishing.
- Add product and vendor profiles.
- Add structured evidence requirements for marketplace listings.
- Add affiliate and sponsorship transparency.
- Add user reviews and experience reports with evidence labeling.
- Add API integrations with selected vendors.
- Add native marketplace flows where appropriate.

## Phase 9: ME2 Model

Goal: evolve from tracking and research into cautious personal modeling.

- Build a longitudinal personal model from labs, wearables, observations, protocols, and decisions.
- Add scenario analysis for low-risk domains.
- Add algorithm marketplace for validated or clearly labeled analytics.
- Add personal response modeling across protocol sprints.
- Add domain-specific simulations where the science supports them.
- Maintain strong uncertainty, safety, and clinical boundary labels.

## Immediate Next Actions

1. Define the BellLabs data model for evidence bundles, decision ledger entries, research runs, and workflow configs.
2. Build a KG preflight function over the existing Neo4j GraphQL API.
3. Create a first research mission template for TruDiagnostic or Qualia.
4. Build a context-aware ingestion prototype using compact schema selection.
5. Add a basic Graph RAG evaluation harness with generated candidate queries.
6. Create the first SDLC maintenance workflow for docs, tests, evals, and Cursor assets.
