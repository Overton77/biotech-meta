# BellLabs Ontology Confidence Lab

Status: `provisional-v0.1`

The lab is the collaboration protocol for evolving the BellLabs biotech ontology. It turns a domain question into a versioned semantic decision, an executable schema projection, and evidence that the decision works for ingestion and retrieval.

The lab does not manufacture certainty by consensus. It manufactures bounded confidence by preserving disagreement, testing counterexamples, and keeping semantic, extraction, retrieval, and decision confidence separate.

## Roles

Each round alternates roles. Either participant may occupy either role.

- **Builder** proposes the smallest model that answers named competency questions.
- **Challenger** tries to break it with counterexamples, temporal ambiguity, identity collisions, linguistic ambiguity, provenance gaps, and retrieval failures.
- **Recorder** is deterministic tooling: it validates artifacts, records lineage, runs fixtures, and refuses invalid promotion.

The Challenger must offer a concrete failing case, not merely dislike a name. The Builder must show the retrieval or ingestion consequence of accepting or rejecting an objection.

## Round protocol

```text
case packet
  -> mention and term inventory
  -> identity candidates and clusters
  -> competency questions
  -> minimal module proposal
  -> adversarial challenge matrix
  -> temporal and provenance normalization
  -> schema projection
  -> extraction + retrieval fixtures
  -> validation and evaluation
  -> accept, revise, split, defer, or reject
```

### 1. Frame a case packet

A case packet contains source snapshots, exact locators, the user or system decision to support, temporal scope, and explicit non-goals. Marketing pages, labels, trial registrations, publications, case reports, and product listings remain distinct source kinds.

### 2. Identify and cluster

Extract mentions before creating entities. Cluster separately for:

- lexical equivalence: spelling, alias, abbreviation;
- referential identity: two mentions denote the same enduring thing;
- ontological kind: product, variant, formulation, material, substance, study, assertion;
- evidence applicability: evidence about one thing may or may not transfer to another.

Clusters are hypotheses with evidence, candidate identifiers, score components, and a review status. Similar names never establish identity.

### 3. Write competency questions

Every proposed class, property, and relationship must help answer a named query, validation rule, ingestion decision, or interoperability need. Unused distinctions remain candidates rather than entering the accepted kernel.

### 4. Apply four challenge lenses

| Lens | Challenger asks |
|---|---|
| Ontological | What kind of thing is this, what persists, and what changes? |
| Linguistic | What does the source actually assert, negate, qualify, presuppose, or leave ambiguous? |
| Epistemic | Who claims it, what supports it, and has BellLabs adjudicated it? |
| Operational | Can extraction produce it, can validation constrain it, and can retrieval answer the competency question? |

Time is evaluated under every lens rather than treated as a fifth optional concern.

### 5. Produce a purpose-bound projection

Agents never receive the whole ontology by default. A projection request identifies the intent, competency questions, selected modules, temporal viewpoint, and budgets. Deterministic closure adds required identities, endpoints, relationship-property types, enums, validation rules, and external references. The result is bound to the source schema digest.

### 6. Qualify with fixtures

A proposal cannot become accepted solely because its diagram looks coherent. It must pass:

- positive examples that should validate;
- negative examples that must fail;
- minimal pairs that differ by one important semantic feature;
- temporal corrections and late-arriving knowledge;
- identity collision and alias tests;
- extraction agreement and calibration tests;
- retrieval competency tests;
- recommendation safety and explanation tests when applicable.

## Confidence vector

Never store a single universal `confidence` as if it meant truth. Keep these dimensions distinct:

| Dimension | Meaning |
|---|---|
| `extractionConfidence` | The text span was parsed into the proposed statement correctly. |
| `resolutionConfidence` | The mention was linked to the correct canonical identity. |
| `sourceReliabilityAssessment` | The source is suitable for this claim type and context. |
| `evidenceStrengthAssessment` | The supporting evidence has the relevant design and quality. |
| `applicabilityAssessment` | The evidence transfers to the target formulation, dose, population, and outcome. |
| `adjudicationStatus` | BellLabs review state: unresolved, supported, contradicted, and so on. |
| `decisionConfidence` | A particular recommendation decision is robust under its policy and user context. |

Scores require a method identifier and method version. Missing dimensions remain unknown; they are not silently averaged. A composite score, if exposed, is a reproducible decision-layer projection rather than an ontology fact.

## Promotion gates

A candidate schema change advances only when:

1. scope and owning module are explicit;
2. identity and state boundaries are stated;
3. time semantics and unknown-time behavior are stated;
4. source assertions are separated from BellLabs adjudications;
5. properties have one stable meaning and value type;
6. relationship domain, range, direction, class, and temporal behavior are defined;
7. a purpose-bound projection can be generated deterministically;
8. positive, negative, temporal, and retrieval fixtures pass;
9. migration and compatibility effects are recorded;
10. unresolved objections are preserved in the decision record.

## Artifacts per round

Each round produces or updates:

- a case packet and source manifest;
- mention inventory and resolution clusters;
- competency-question set;
- module proposal or patch;
- term cards and relationship cards;
- decision record and objection ledger;
- temporal normalization ledger;
- extraction contract and examples;
- schema projection request and immutable projection result;
- graph-delta proposal;
- validation report;
- retrieval evaluation report;
- migration note and changelog entry if accepted.

See [the starter competency questions](./competency-questions.md), [module manifest](./modules.yaml), [starter property model](./starter-property-model.md), [projection contract](./projection-contract.yaml), and [round record template](./round-template.md).

The live dialogue begins with [Round 0001: Product Continuity and Evidence Transfer](./round-0001-product-continuity.md).
