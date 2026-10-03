# Human Upgrade Knowledge Schema Workspace

Status: `provisional-v0.1`

This workspace turns the evolving Human Upgrade domain model into a source-attributed, agent-usable, Neo4j-oriented schema. It begins with consumer supplements and the surrounding organization, commerce, formulation, evidence, quality, regulatory, and intellectual-property domains.

It is deliberately a **schema production system**, not a claim that the ontology is complete. Every concept can mature through `candidate -> provisional -> accepted -> deprecated`, and every source-derived fact can remain disputed or unresolved without being deleted.

## Start here

1. [Schema proposal brief](./schema_research_and_proposal.md) is the agent-team mission. It maps the live GraphQL schema and assigns writes to the ontology lab, catalog, sources, Neo4j projection, and examples. `current_biotech_schema.graphql` stays read-only.
2. [Architecture and reasoning](./architecture.md) explains the stable kernel, modules, assertion model, time, and agent lifecycle.
3. [Machine-readable catalog](./catalog/schema.yaml) defines node labels, relationship types, required properties, and modeling invariants.
4. [Neo4j constraints](./neo4j/constraints.cypher) is executable Cypher for Neo4j 5.x.
5. [Validation queries](./neo4j/validation.cypher) find identity collapses and unsafe inference patterns.
6. [Elysium seed fixture](./examples/elysium-basis.cypher) demonstrates source-attributed ingestion without asserting more than the sources establish.
7. [Source registry](./sources/source-registry.yaml) records the first authoritative and illustrative sources by claim type.
8. [Open modeling questions](./OPEN-QUESTIONS.md) is the active schema-research backlog.
9. [Changelog](./CHANGELOG.md) records semantic contract evolution.
10. [ADR 0002](../adr/0002-assertion-centered-temporal-knowledge-graph.md) records the foundational decision.
11. [Ontology Confidence Lab](./ontology-lab/README.md) defines the cooperative-adversarial process used to challenge, qualify, and evolve the schema.

## Workspace contract

- `CONTEXT.md` remains the implementation-independent ubiquitous-language glossary.
- `schema/catalog/schema.yaml` is the current machine-readable semantic contract.
- `schema/neo4j/*.cypher` is a projection of that contract into Neo4j, not the ontology itself.
- `schema/examples/` contains executable stress cases, never canonical production data.
- `schema/sources/` records source identity and authority scope; it does not globally rank organizations as truthful.
- Checkpoints preserve the research and reasoning that caused schema changes.

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
