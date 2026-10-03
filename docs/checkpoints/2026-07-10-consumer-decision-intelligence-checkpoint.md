# Consumer Decision Intelligence Checkpoint

Date: 2026-07-10

This checkpoint captures the emerging consumer supplement decision-intelligence domain. It extends the research and ingestion system without prematurely fixing schemas or implementation boundaries.

## Product Direction

The supplement capability should be a personal decision-intelligence system for human interventions, not merely a supplement recommender.

Its recurring loop is:

```text
User goal or problem
-> Intervention hypotheses
-> Evidence adjudication
-> Personal fit and safety
-> Product and formulation comparison
-> Decision Cart
-> Purchase or experiment
-> Observed outcomes
-> Re-evaluation
```

Supplements are the first domain because they exercise scientific evidence, commercial claims, branded ingredient identity, safety, personalization, product quality, cost, availability, education, purchasing, and outcome learning.

## User Workspaces

Two distinct concepts are accepted:

- **Decision Cart** holds acquisition decisions under consideration and preserves why an option was selected, rejected, or deferred.
- **Protocol Workspace** organizes interventions across planned, active, paused, and completed states over time.

Both may eventually live within a broader **Intelligence Workspace**. The Intelligence Workspace should evolve organically from proven features rather than being specified as a large module in advance.

## Authority Is Claim-Specific

Organizations should not receive a single global authority rank that is applied to every claim.

A manufacturer is normally authoritative for its own current label, declared formulation, price, instructions, and self-claims. It is not automatically authoritative for efficacy, safety, study applicability, or superiority.

Source authority should instead depend on the question:

| Question | Preferred authority |
|---|---|
| What does the marketed product declare? | Current product label and manufacturer record |
| What material or branded ingredient is used? | Label, supplier, trademark owner, and licensing evidence |
| What is the chemical identity? | Scientific nomenclature and chemical identifier authorities |
| What did a study test? | Publication, trial record, protocol, and study materials |
| Does the study apply to the marketed product? | Formulation, dose, route, population, and material-identity comparison |
| Is it appropriate for a user? | Evidence synthesis plus user-specific safety constraints and professional review where required |
| Can it be purchased? | Merchant, retailer, or commerce platform at a recorded time |

This distinction should become a source-policy input to later research, adjudication, ingestion, and recommendation workflows.

## Recommendation Direction

Recommendations should remain multidimensional rather than collapse immediately into one opaque score. Important dimensions include:

- evidence strength
- user relevance
- safety compatibility
- formulation fidelity
- manufacturing confidence
- value
- preference fit
- availability
- uncertainty

Rankings may be derived from these dimensions, but the user should be able to understand the trade-offs and change priorities.

## Commerce Direction

Commerce integration should be graduated:

```text
Verified outbound link
-> Affiliate or deep link
-> Shopping-list export
-> Official commerce API
-> Agentic commerce protocol
-> User-authorized browser assistance
-> Manual fallback
```

The system must distinguish the recommended product, the retailer-matched product, and the product actually purchased. These are not necessarily identical.

## Supplement Naming Problem

The word **compound** is too narrow to be the umbrella for supplement ingredients. The domain must eventually represent, without conflation:

- a nutrient or declared dietary ingredient, such as zinc
- a chemical form or source ingredient, such as zinc monomethionine
- a botanical organism, plant part, preparation, and extract
- a microorganism and strain
- a chemical constituent or standardized marker
- a branded ingredient material, such as OptiZinc
- a finished formulation
- a marketed product and SKU
- non-dietary ingredients such as excipients, binders, flavors, and capsule materials

Regulatory display names, scientific canonical names, commercial names, and source-verbatim label text should be preserved as different fields or linked identities in the eventual model.

## Naming Authorities Identified

The following source classes have distinct roles:

- FDA regulations and labeling guidance govern United States label presentation, including common or usual names and source-ingredient presentation.
- IUPAC governs systematic chemical nomenclature but does not dictate consumer supplement label wording.
- CAS Registry Numbers identify chemical substances independently of their many names; licensing constraints must be evaluated before public product use.
- PubChem provides open normalized chemical structure records, source substance records, identifiers, and synonyms useful for resolution.
- USP-NF and the Food Chemicals Codex provide compendial names and quality standards when applicable.
- NIH's Dietary Supplement Label Database preserves real-world label text and images; it is evidence of what a label says, not proof that the label is scientifically or legally correct.
- Trademark owners and ingredient suppliers are authoritative for trademark identity and their own specifications, not automatically for efficacy.

## Working Naming Direction

Do not choose one universal display name. Preserve a naming bundle for each resolvable entity:

```text
Canonical domain name
Regulatory/common name
Scientific/systematic name
Source-verbatim name
Brand or trademark name
Synonyms and legacy names
Stable external identifiers
Jurisdiction and effective dates
```

Entity resolution should never infer chemical or material equivalence from a shared marketing name alone.

## Knowledge Graph Modeling Direction

The canonical model is a temporally aware knowledge graph. Postgres, Prisma, Neo4j, Neo4j GraphQL, search indexes, and API schemas are implementation projections rather than the source of the domain model.

The existing Prisma relationship `Product.containsCompounds Compound[]` is useful as an early navigational shortcut but is not expressive enough to become the authoritative composition model. A direct timeless `Product -> CONTAINS -> Compound` edge cannot preserve:

- product and formulation versions
- label-effective dates
- source-verbatim ingredient declarations
- nutrient versus source-material identity
- branded ingredient identity
- amount, unit, serving basis, and label order
- active versus non-dietary ingredient roles
- provenance, confidence, and disagreement
- lot-specific or region-specific variation

The emerging authoritative shape is closer to:

```text
Product
-> has variant
Product Variant
-> has formulation version
Formulation Version
-> declares ingredient component
Ingredient Component
-> identifies material
Ingredient Material
-> supplies or standardizes
Nutrient / Constituent / Strain / Marker
```

A Branded Ingredient Material may identify or constrain an Ingredient Material, but a trademark is not interchangeable with a chemical substance, nutrient, formulation, or finished product.

### Stable identity and changing descriptions

Stable graph identity should be separated from time-varying names, labels, formulations, offers, organizational ownership, and scientific understanding. A changed formulation should not silently rewrite the historical product state.

### Temporal dimensions

At least three times must not be conflated:

- **valid time**: when the modeled relationship or state was true in the world
- **recorded time**: when Human Upgrade learned or committed it
- **source time**: when the supporting label, page, publication, or record was issued or observed

Whether full bitemporal mechanics are required for every entity remains open, but the semantic distinctions must survive every persistence projection.

### Assertions and truth status

The graph must distinguish what a source asserts from what Human Upgrade has adjudicated. Manufacturer declarations, study findings, user observations, regulatory findings, and system conclusions may disagree without one overwriting another.

Relationships that require provenance, temporal bounds, qualification, confidence, or disagreement must be representable as first-class assertions or otherwise carry equivalent semantics. Simple derived relationships may remain direct edges for traversal performance.

### Derived convenience edges

Edges such as `Product -> CONTAINS -> Ingredient` may be materialized for search or traversal, provided they can be regenerated from authoritative formulation and assertion data and are never mistaken for the complete historical record.

## Candidate First Vertical Slice

An OptiZinc-centered user decision remains a strong first slice because it tests:

- nutrient versus chemical form
- trademarked material versus generic substance
- product and formulation verification
- company-referenced versus independent evidence
- user constraints and safety
- product ranking
- Decision Cart evidence
- commerce handoff
- later outcome tracking in a Protocol Workspace

## Open Questions

- What umbrella term should replace `compound` across the knowledge graph: Ingredient, Intervention Material, Bioactive, or a typed combination?
- When are two ingredient materials equivalent enough to inherit evidence?
- How should branded ingredient licenses and formulation changes be versioned?
- Which name is shown to consumers, researchers, and operators in each interface?
- How should label text be preserved when it is incomplete, ambiguous, outdated, or arguably noncompliant?
- Which external identifiers can be stored and redistributed under acceptable licensing terms?
- What evidence is required to assert that a finished product contains the same material used in a study?
- Which relationships require first-class assertion identity, and which can remain property-bearing graph edges?
- What precisely creates a new Product Variant versus a new Formulation Version?
- Is the formulation printed on a label modeled as a declaration, while verified composition is a separate adjudicated assertion?
- Which temporal fields are mandatory on all assertions versus only on time-sensitive relationship types?
