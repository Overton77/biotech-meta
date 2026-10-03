# Schema Architecture and Reasoning

Status: provisional
Updated: 2026-07-13

## 1. The stable semantic kernel

Domain labels grow over time, but all graph content belongs to one of six high-order archetypes:

| Archetype | Meaning | Examples |
|---|---|---|
| `Entity` | An identity that persists while descriptions change | Product, Organization, Ingredient Material, Study |
| `VersionedState` | A state of an identity valid for a bounded scope or time | Formulation Version, Specification Version, Registration Version |
| `Occurrence` | Something that happened | Test Execution, manufacturing event, study administration |
| `InformationArtifact` | A representation or record of something | Label Snapshot, Publication, Certificate of Analysis |
| `Assertion` | A proposition attributable to a source or agent | “This label declares 250 mg NR” |
| `EvidenceAssessment` | An adjudicated evaluation of evidence or applicability | intervention-to-current-formulation match |

An item may carry several Neo4j labels, for example `(:Entity:Product)` or `(:InformationArtifact:SourceSnapshot:LabelSnapshot)`.

## 2. Assertion-centered truth model

The authoritative ingest pattern is:

```text
(Source)-[:HAS_SNAPSHOT]->(SourceSnapshot)
(SourceSnapshot)-[:HAS_LOCATOR]->(SourceLocator)
(Assertion)-[:HAS_SUBJECT]->(Entity or State or Artifact)
(Assertion)-[:HAS_OBJECT]->(Entity or State or Artifact)   // relational proposition
(Assertion)-[:SUPPORTED_BY]->(SourceLocator)
(Assertion)-[:ASSERTED_BY]->(Agent or Organization or Person)
(Adjudication)-[:EVALUATES]->(Assertion)
(Adjudication)-[:SUPPORTED_BY|CONTRADICTED_BY]->(SourceLocator)
```

Literal assertions use typed fields (`valueString`, `valueNumber`, `valueBoolean`, `unitCode`) instead of an object node. The controlled `predicate` identifies proposition semantics.

This is intentionally more explicit than attaching `sourceUrl` and `confidence` to every domain edge. A first-class Assertion can:

- survive a source correction;
- be supported and contradicted by multiple sources;
- carry valid time, recorded time, jurisdiction, and extraction lineage;
- be reviewed independently;
- retain the source's claim after Human Upgrade rejects it;
- support alternative entity-resolution hypotheses.

## 3. Three relationship classes

Every relationship type is classified in the catalog:

1. `structural`: defines the internal shape of a captured record, such as a Label Snapshot having a Label Declaration.
2. `asserted`: is authoritative only through an Assertion, such as an organization marketing a product or a formulation containing a material.
3. `derived`: is a regenerable traversal shortcut, such as `Product CONTAINS IngredientMaterial`.

A derived relationship must contain `projectionOfAssertionUid` or `derivationRule`, and must never be the only historical record.

## 4. Time

The model preserves distinct clocks:

- `validFrom` / `validTo`: when the assertion or state was true in the modeled world;
- `recordedAt`: when Human Upgrade committed it;
- `observedAt`: when a webpage, offer, label, or price was observed;
- `publishedAt`: when a source artifact was issued;
- `effectiveFrom` / `effectiveTo`: when a versioned state applied.

Unknown temporal bounds remain `null`; they are not replaced with ingestion time. Precision is stored as `timePrecision` when necessary.

## 5. Product and formulation backbone

```text
Product
  -> ProductVariant
    -> PackageConfiguration
    -> FormulationVersion
      -> IngredientComponent
        -> IngredientMaterial
          -> ChemicalSubstance / BotanicalPreparation / MicrobialPreparation / MaterialMixture
```

`Product`, `ProductVariant`, and `FormulationVersion` are intentionally separate:

- Product is the enduring marketed concept.
- Product Variant is a consumer-distinguishable realization (strength, dosage form, flavor, jurisdiction, or other identity-relevant choice).
- Formulation Version is a time-bounded composition for a variant.
- Package Configuration is count, package form, and quantity; it does not automatically create a formulation.
- Offer is a merchant's time-bounded proposition and never establishes product identity by itself.

The precise lifecycle test for variant versus formulation change remains provisional and is tracked in `OPEN-QUESTIONS.md`.

## 6. Ingredient composition is not a flat `CONTAINS` edge

`IngredientComponent` is a contextual component inside one formulation. It carries role, order, quantities, serving basis, and nesting. It points to an `IngredientMaterial`, which represents the actual material identity.

An Ingredient Material can be:

- a chemically defined substance or specified salt/form;
- a branded material governed by a specification;
- a botanical preparation defined by taxon, plant part, extraction, and standardization;
- a microbial preparation defined by organism, strain, and preparation;
- a mixture with nested material components.

`PROVIDES_CONSTITUENT` is not `QUANTITATIVELY_CONTAINS`. A tomato/rosemary extract mixture that says it provides carotenoids does not become synonymous with lycopene and does not establish a measured lycopene amount.

## 7. Evidence and applicability

A Study is not its registration, protocol, publication, arm, intervention, or result. The evidence path is explicit:

```text
Study -> StudyArm -> StudyIntervention -> InterventionComponent -> IngredientMaterial
Study -> OutcomeDefinition -> StudyResult
Publication -> REPORTS_ON -> Study
EvidenceApplicability -> compares evidence target with use target
```

`EvidenceApplicability` is a first-class assessment with dimensions such as:

- product/formulation/material identity;
- dose, route, schedule, and duration;
- population and baseline state;
- comparator;
- outcome relevance;
- study design and quality;
- recency and uncertainty.

It must not collapse to one unexplained score. A derived score may coexist with the dimension assessments and method version.

## 8. Quality chain

```text
ProductLot -> TestSample -> TestExecution -> MeasuredResult
TestExecution -> TestMethod
TestExecution -> TestingLaboratory
MeasuredResult -> SpecificationCriterion -> SpecificationVersion
CertificateOfAnalysis -> REPORTS_ON -> ProductLot/TestExecution
CertificationListing -> HAS_SCOPE -> CertificationScope -> COVERS -> Product/ProductVariant/ProductLot
```

A statement such as “conforms to internal specs” can be represented as a sourced pass/fail assertion. It does not create absent measured values, laboratory identities, methods, uncertainty, or a signed Certificate of Analysis.

## 9. Organizations are role relationships

Legal entity, brand, facility, laboratory, and certification body remain separate identities. Roles such as marketer, distributor, manufacturer, supplier, specification owner, sponsor, funder, CRO, patent licensee, marketplace, and fulfillment provider are time-bounded asserted relationships.

No role implies another unless an explicit, source-backed assertion exists. In particular:

```text
ADVISES_ORGANIZATION != ENDORSES_PRODUCT
SPONSORS_STUDY != EXECUTES_STUDY
DISTRIBUTES_PRODUCT != MANUFACTURES_PRODUCT
LICENSES_PATENT != OWNS_STUDY
MARKETPLACE_LISTS != SELLS
```

## 10. Regulatory and IP semantics

Regulatory events and statuses are jurisdiction-specific artifacts/assertions, not badges on a product. The model separates:

- NDI notification from FDA response and from approval;
- GRAS notice from its response status;
- orphan designation from drug approval;
- patent family, application, grant, and claim;
- assignee, inventor, and licensee;
- trademark from the branded material sold under it.

## 11. Agent-facing uncertainty and evolution

Agents produce `ResolutionHypothesis` and `GraphCandidate` records in the research runtime before authoritative commit. In the committed graph, uncertainty remains visible through Assertion status, Adjudication, Evidence Assessment, and Modeling Issue references.

Required distinctions:

- `unknown`: not currently established;
- `unmeasured`: no measurement was performed or available;
- `notReported`: source did not report it;
- `belowDetection`: a measurement had this outcome;
- `absent`: evidence supports non-presence;
- `false`: an assertion was adjudicated false.

The schema itself uses maturity states. Retrieval telemetry, failed resolution cases, and validation results should determine which provisional concepts are promoted, split, merged, or deprecated.

## 12. What remains outside this first module

This release does not claim comprehensive modeling of genomics, diagnostics, drugs, devices, clinical care, education, user observations, or protocols. It creates seams for them while concentrating on consumer supplements and their immediate evidence/commerce environment.

