# ADR 0002: Assertion-Centered Temporal Knowledge Graph

Date: 2026-07-13
Status: Accepted for provisional schema v0.1

## Context

Consumer-supplement research produces conflicting manufacturer pages, changing labels, historical formulations, trial interventions, publications, regulatory records, commerce observations, and agent-generated identity hypotheses. A direct-edge graph such as `Product-[:CONTAINS]->Compound` cannot preserve who asserted a relationship, what source supported it, when it was true, whether it is disputed, or how evidence transfers to a current product.

The system is operated and extended by LLM agents. Those agents will make extraction and entity-resolution mistakes, and the ontology itself will evolve as retrieval and evaluation expose missing distinctions.

## Decision

Use a stable six-archetype semantic kernel: Entity, Versioned State, Occurrence, Information Artifact, Assertion, and Evidence Assessment.

Source-derived semantic facts are represented as first-class Assertions with a subject, predicate, object or typed literal, status, temporal fields, and exact Source Locators. Human Upgrade conclusions are separate Adjudications. Direct domain relationships are classified as structural, asserted projections, or derived shortcuts; derived relationships must be regenerable.

Neo4j is the first native graph projection. The semantic catalog remains storage-independent and versioned separately from database migrations.

## Alternatives considered

### Property-rich direct relationships only

This is compact and traversable, but relationships are awkward to discuss, review, contradict, version, or attach multiple pieces of reasoning to. It also encourages source metadata to become inconsistent across edge types.

### RDF/OWL as the canonical representation

This offers mature semantic-web standards and named-graph/provenance patterns, but would impose a larger formalism before the product's retrieval and reasoning needs are known. Compatibility can be added later through mappings.

### Fixed relational schema first

This provides strong constraints but encourages premature table boundaries and makes competing assertions and evolving relationship semantics cumbersome. Relational projections remain possible.

### Store extracted documents and let RAG infer all relationships

This avoids ontology work but cannot reliably support identity continuity, temporal composition, evidence inheritance, validation, or auditable recommendations.

## Consequences

- Ingestion is more verbose but preserves disagreement and correction history.
- Agents must distinguish extraction, resolution, adjudication, and projection.
- Common traversals may require derived edges and indexes.
- Application code must never treat a source assertion as an adjudicated fact solely because it exists.
- Schema concepts can evolve without deleting source history.
- Neo4j constraints alone are insufficient; validation queries and ingestion policy are part of the contract.
