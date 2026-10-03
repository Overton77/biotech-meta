# Human Upgrade Knowledge Schema Workspace

Status: `provisional-v0.2`

This workspace turns the evolving Human Upgrade domain model into a source-attributed, agent-usable, Neo4j-oriented schema. It began with consumer supplements and the surrounding organization, commerce, formulation, evidence, quality, regulatory, and intellectual-property domains. Version 0.2.0 adds the diagnostics, mechanisms, claims-and-documents, protocols, time, and private-context modules and records how the live GraphQL schema meets the catalog.

It is deliberately a **schema production system**, not a claim that the ontology is complete. Every concept can mature through `candidate -> provisional -> accepted -> deprecated`, and every source-derived fact can remain disputed or unresolved without being deleted.

## Start here

1. [Proposal index](./ontology-lab/proposal-index.md) is the integration record for 0.2.0: links to the rounds and their decisions, keep / refine / merge / split / seam decisions against the live schema, the private-data placement, how a source is ingested without dropping qualifications, how an answer traces to a locator and an adjudication, how corrections and late facts are stored, and what is still open.
2. [Schema proposal brief](./schema_research_and_proposal.md) is the agent-team mission that produced 0.2.0. `current_biotech_schema.graphql` stays read-only.
3. [Architecture and reasoning](./architecture.md) explains the stable kernel, modules, assertion model, time, and agent lifecycle.
4. [Machine-readable catalog](./catalog/schema.yaml) defines node labels, relationship types, required properties, modeling invariants, kernel-change decisions, and migration notes.
5. [Competency questions](./ontology-lab/competency-questions.md) define what the graph helps people know, with priority classes and question-to-model traces; [query shapes](./ontology-lab/query-shapes.md) are the Cypher patterns every answer must be expressible in.
6. [Neo4j constraints](./neo4j/constraints.cypher) is executable Cypher for Neo4j 5.x; [validation queries](./neo4j/validation.cypher) find identity collapses and unsafe inference patterns; [proposed GraphQL delta](./neo4j/proposed-delta.graphql) is the additive projection against the live schema.
7. [Fixtures](./examples/) demonstrate source-attributed ingestion without asserting more than the sources establish: Elysium Basis (0.1.0), study versus product mismatch, diagnostic comparison, filing versus capability, claim retelling provenance, recommendation snapshot.
8. [Source registry](./sources/source-registry.yaml) records authoritative and illustrative sources by claim type.
9. [Open modeling questions](./OPEN-QUESTIONS.md) is the active schema-research backlog.
10. [Changelog](./CHANGELOG.md) records semantic contract evolution.
11. [ADR 0002](../adr/0002-assertion-centered-temporal-knowledge-graph.md) records the foundational decision.
12. [Ontology Confidence Lab](./ontology-lab/README.md) defines the cooperative-adversarial process; rounds 0001 to 0009 are its record. [Live schema alignment](./ontology-lab/live-schema-alignment.md) is the per-type table.

## Workspace contract

- `CONTEXT.md` remains the implementation-independent ubiquitous-language glossary.
- `schema/catalog/schema.yaml` is the current machine-readable semantic contract.
- `schema/neo4j/*.cypher` is a projection of that contract into Neo4j, not the ontology itself.
- `schema/examples/` contains executable stress cases, never canonical production data.
- `schema/sources/` records source identity and authority scope; it does not globally rank organizations as truthful.
- Private user context is logically separate from the shared world model and, per round 0008, physically separate: a transactional private context store is the system of record, and the shared graph holds no private-personal node.
- Checkpoints and round records preserve the research and reasoning that caused schema changes.

## Verification status

Every Cypher statement in `examples/`, `neo4j/` and `ontology-lab/query-shapes.md` passed a syntax check with the Neo4j Cypher language-support parser and a per-statement variable-binding check (variables do not survive a `;` boundary). The GraphQL delta parses and extends the live schema without name or field collisions. The constraints, the six fixtures and all validation queries were executed on an embedded Neo4j 5.26 Community instance on 2026-10-03: the suite returns zero failing rows for each fixture alone and for all six together, and four reintroduced collapses are caught (details in `ontology-lab/proposal-index.md`, section 9). Enterprise-only constraints and the deployed database were not exercised. The live-stack facts that must be verified before implementation are listed at the end of `OPEN-QUESTIONS.md`.

## Schema evolution loop

```text
Research question
  -> source capture and stable locator
  -> verbatim/normalized assertions
  -> entity-resolution candidates
  -> adjudication and competing hypotheses
  -> graph candidate
  -> validation queries and retrieval tests
  -> accepted schema change or recorded modeling issue
```

LLM agents may propose entities, links, and schema changes. They may not silently convert extraction confidence into truth, overwrite a conflicting assertion, or infer a forbidden relationship such as `ADVISES_ORGANIZATION -> ENDORSES_PRODUCT`.

## Versioning

The workspace version identifies a semantic contract, not a database migration number. Breaking changes require:

- a catalog version increment;
- a changelog entry;
- migration/compatibility notes;
- retrieval and validation fixtures;
- explicit treatment of previously committed assertions.
