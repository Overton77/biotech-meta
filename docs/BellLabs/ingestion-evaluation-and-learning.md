# Ingestion, Evaluation, And Learning

BellLabs will only become defensible if its knowledge base improves continuously and measurably. Research outputs cannot merely become markdown reports. They must become documents, chunks, claims, entities, relationships, evidence bundles, eval cases, and future workflow seeds.

## Context-Aware Ingestion

The current biotech Neo4j GraphQL schema is intentionally broad. It includes organizations, products, treatments, compounds, lab tests, biomarkers, mechanisms, studies, protocols, claims, documents, experience reports, episodes, listings, safety signals, manufacturing processes, regulatory entities, and many more concepts.

That breadth creates a problem: no agent can reliably hold the entire schema, the full report, the current database state, and all storage rules in one context window. Ingestion must become a workflow.

## Ingestion Workflow

Recommended stages:

1. Document registration.
2. Text extraction, segmentation, and chunking.
3. Source classification and trust assessment.
4. Compact schema selection.
5. Relevant full-schema retrieval.
6. Candidate entity and relationship extraction.
7. Database lookup for existing matches.
8. Entity resolution and merge planning.
9. Create, update, replace, disconnect, or ignore decisions.
10. Human or agent review for high-impact changes.
11. Storage operation generation.
12. Write execution.
13. Post-write validation.
14. Eval case generation.

## Schema Selection Strategy

Use a two-step schema exposure process.

First pass:

- Provide the report or report section.
- Provide a compact schema map: node names, relationship names, short descriptions, and key unique fields.
- Ask the agent to select relevant schema areas and explain why.

Second pass:

- Retrieve only the full schema for selected nodes and relationships.
- Include relationship properties, required fields, indexes, constraints, and examples.
- Ask the agent to produce structured extraction candidates.

This keeps context focused and makes extraction auditable.

## Storage Decision Model

Ingestion should not blindly create nodes.

For every candidate entity or relationship, the system should decide:

- Create: no equivalent exists.
- Update: the same entity exists and new fields or evidence should be added.
- Merge: multiple existing entities appear to represent the same thing.
- Replace: a prior value should be superseded, with temporal metadata preserved when appropriate.
- Disconnect: a relationship is no longer supported or was incorrectly inferred.
- Ignore: candidate is too weak, irrelevant, duplicate, unsupported, or out of scope.
- Defer: decision requires human review or additional evidence.

Every decision should include confidence, evidence, matching logic, and rollback information.

## Entity Resolution

Entity resolution must be first-class because biotech names are messy.

Signals:

- Canonical name and aliases.
- Company legal names, tickers, websites, subsidiaries, and acquisitions.
- Product names, SKUs, regulatory identifiers, and listing URLs.
- Compound identifiers such as CAS, PubChem, synonyms, and forms.
- Study identifiers such as NCT IDs, DOI, PubMed ID, sponsors, and dates.
- Biomarker names, units, specimen types, methods, and panels.
- Source provenance and extraction confidence.

The system should preserve uncertainty rather than forcing premature merges.

## Claim-Centric Ingestion

Claims should be central. A source rarely just "contains information"; it asserts things.

For each claim:

- What is being claimed?
- Who or what made the claim?
- Which entities are involved?
- What source supports the occurrence of the claim?
- Is the claim mechanistic, clinical, commercial, anecdotal, regulatory, safety-related, or testimonial?
- Is the claim supported, contradicted, or unverified by other sources?
- What is the evidence strength?

This enables BellLabs to compare vendor marketing, practitioner protocols, user reports, and scientific literature without flattening them into one truth layer.

## User Report Ingestion

Personal health reports require a separate privacy and safety path.

For lab reports:

- Register document and consent scope.
- Extract lab company, panel, specimen, collection date, report date, methods, biomarkers, units, values, flags, and reference ranges.
- Normalize units where safe.
- Preserve original values and report pages.
- Link biomarkers to shared KG concepts without exposing private data publicly.
- Detect urgent or clinically concerning values and route to appropriate disclaimers or clinician prompts.
- Create measurement events in the personal graph.
- Update dashboards and protocol reviews.

Personal ingestion should never write private measurements into the public KG.

## Graph RAG Evaluation

The research system should generate evals as it grows. After every research mission or ingestion run, it should produce candidate queries and scenarios.

Eval categories:

- Entity retrieval: can the system find the right company, product, biomarker, study, or protocol?
- Relationship retrieval: can it find the correct connections and avoid hallucinated ones?
- Claim grounding: does the answer cite the correct claim occurrence and source?
- Cross-domain coverage: can a TruDiagnostic mission surface related concepts like epigenetic clocks, biological age, methylation, microbiome sequencing, Viome, and competing panel providers when relevant?
- Safety retrieval: does it find contraindications, adverse effects, and regulatory warnings?
- Personalization correctness: does it use user context only when permitted and cite it correctly?
- Refusal and boundary behavior: does it avoid diagnosis or prescription?
- Citation fidelity: do citations support the answer?
- Freshness: does it prefer newer evidence when appropriate without discarding older foundational work?

## Research Workflow Evaluation

Research workflows should be evaluated beyond final answer quality.

Measure:

- Source diversity and source quality.
- Evidence coverage.
- Citation accuracy.
- Novel entity discovery.
- KG gap discovery.
- Cost and latency.
- Number of dead-end loops.
- Human intervention frequency.
- Safety issues detected and missed.
- User usefulness.
- Downstream ingestion yield.

Each workflow mode should have its own eval set.

## Fine-Tuning And Distillation

Fine-tuning should be earned, not assumed. Start with retrieval, prompts, structured outputs, and evals. Fine-tune only after there are enough high-quality traces and labels.

Potential datasets:

- Entity extraction examples.
- Claim extraction examples.
- Schema selection examples.
- Entity resolution decisions.
- Graph mutation planning.
- Safety classification.
- Source quality classification.
- User question to workflow plan mapping.
- Report synthesis with faithful citations.

Data governance is critical. Personal health data must not enter training sets without explicit consent and strong de-identification.

## Learning Loop

Every serious BellLabs run should have an afterlife.

Outputs can become:

- New KG entities and relationships.
- New documents and chunks.
- New claims and claim occurrences.
- New evidence bundles.
- New product decision examples.
- New protocol templates.
- New eval cases.
- New workflow planner examples.
- New red-team tests.
- New user dashboard components.

This is how the platform compounds.
