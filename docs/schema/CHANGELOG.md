# Schema Changelog

## 0.2.0 — 2026-10-03

Provisional semantic contract integrating ontology-lab rounds 0002 to 0009. The live Neo4j GraphQL schema is unchanged; its alignment is recorded per type in `ontology-lab/live-schema-alignment.md` and as an additive projection in `neo4j/proposed-delta.graphql`. The integration record is `ontology-lab/proposal-index.md`.

### Breaking meaning changes (see `catalog/schema.yaml` `migration`)

- `Assertion.status` is a current projection of CAPTURE_FIDELITY adjudications and SUPERSEDES records. ACCEPTED means "accepted as an accurate record of what the asserter said"; it is never a truth verdict. Truth and support live on SUPPORT adjudications and EvidenceAssessments (rounds 0006, 0007).
- `Assertion.confidence` is deprecated. New writes use `extractionConfidence` and link `WAS_GENERATED_BY` an `Activity` with a method version. The confidence vector stays on assessments (rounds 0006, 0009).
- The single `validTimeBasis` is replaced by `validFromBasis`, `validToBasis`, `validFromPrecision`, `validToPrecision`. Asserted edges and state attachments follow the `bitemporal_attachment` and `asserted_edge` profiles with `relationshipUid`, `recordedFrom`, `recordedTo`, `assertionUid` (rounds 0007, 0009).
- `ASSESSES_APPLICABILITY_TO` no longer accepts `UserContext`. Shared applicability targets a non-personal `UseContextProfile`; personal applicability is a `PersonalApplicabilityAssessment` in the private store (round 0008).
- `RecommendationDecision` and `RecommendationCandidate` are renamed `RecommendationSnapshot` and `RecommendationOption`, both private-personal and insert-only; `DecisionContext` and `DecisionExplanation` fold into snapshot fields (round 0008).
- `SourceLocator.selector` is split into typed selector fields (`selectorKind`, `exact`, `prefix`, `suffix`, `quoteHash`, `normalizationVersion`, offsets, media times, page, annotation) (round 0006).
- `evidenceStrength`, `evidenceLevel`, `isClinicallyMeaningful` and the `EvidenceStrength` enum on edges become assessments (`EvidenceStrengthAssessment`, `ResultInterpretation`, `ClaimEvidenceAssessment`); attribute values are kept only as derived extraction-time hints (rounds 0002, 0006, 0009).
- `Compound` merges into `ChemicalSubstance` (catalog name wins); `CompoundForm` splits into `ChemicalForm`, `IngredientMaterial` and dosage form; `CONTAINS_COMPOUND_FORM` becomes a derived projection (round 0002).
- `SELLS_PRODUCT` is derived only, from `SELLER_OF_RECORD_FOR` assertions; `HOSTS_LISTING`, `LISTS_OFFER`, `FULFILLS_OFFER` are distinct typed roles (round 0005).
- Live `RegulatoryStatus` is split into `RegulatorySubmission`, `RegulatoryResponse` and `RegulatoryStatus` with a closed `statusKind`; `DrugApproval` and `OrphanDesignation` become specialization labels; only `statusKind: APPROVAL` is approval (round 0005).
- Registry fields (`overallStatus`, `enrollmentCount`, `hasResults`, dates, design) move from `Study` to `RegistrationVersion`; `hasResults` becomes `resultsPosted` (round 0002).

### Added

- Kernel: `Assertion.polarity`, `basisKind` (DIRECT_MEASUREMENT, INFERRED_FROM_MEASUREMENT, CITED_FROM_PRIOR_WORK, HYPOTHESIS, CALCULATED), `assertionBasis`, `speechAct`, `recordedTo`, `contentHash`, `derivationRule`; `EvidenceAssessment.recordedAt`; `Adjudication.adjudicationKind` and `recordedAt`; `SUPERSEDES` with `supersessionKind`; `DERIVED_FROM_ASSERTION`; `Activity` with PROV-O relationships; `SourceRevisionEvent`; typed `SourceLocator` selectors; `SourceSnapshot.contentHashBasis`, `captureCompleteness`, `publishedAt`, `observedAt`.
- Modules: `temporal` (profiles, precision, basis, exclusivity, TM-R1 to TM-R6), `identity_resolution` (`Identifier`, `HAS_IDENTIFIER`, `Mention`, `EquivalenceAssessment`), `mechanisms` (`MechanismEvidenceContext`, mechanism predicates, derived mechanism projections), `diagnostics` promoted to candidate (`AssayVersion`, `Algorithm`, `AlgorithmVersion`, `ReferenceIntervalVersion`, `ComparabilityAssessment`, `DiagnosticResult` contract), `manufacturing_readiness` (`ManufacturingCapability`), `claims_and_documents` (`Claim`, `ClaimOccurrence` as `(:Assertion:ClaimOccurrence)`, `RelationshipAssertion`, `ClaimEvidenceAssessment`, `RetellingFidelityAssessment`, `ConflictRelevanceAssessment`, `RETELLS`, `QUALIFIED_BY`, `ATTRIBUTES_TO`, FINANCIAL_INTEREST predicate family), `protocols` (`ProtocolEdition`, step requirement levels, dependencies, review triggers; `Observation` ownership), `private_context` (`UserContext`, `UserContextVersion`, `UserGoal`, `PersonalMeasurement`, `ProtocolInUse`, `SharingGrant`, `DisclosureEvent`, `PendingItem`, `PurchaseEvent`, `ErasureTombstone`), `access_and_answers` (candidate `AnswerRecord`).
- Studies and evidence: `ApplicabilityDimension` (categorical, continuous, explanation-only), `materialIdentityLevel`, `EndpointClassification` (BEST categories, surrogate validation level, context of use), `AdverseEventResult` with collection method, `analysisKind`, `comparisonKind`, `statisticalConclusion`, versioned `EvidenceSynthesis` with `TRIGGERED_BY`, `Dataset` reuse, `Publication.publicationKind`, `CORRECTS`, `RETRACTS`, `PROVIDES_INVESTIGATIONAL_PRODUCT`.
- Labels and formulation: `amountReferent` on `QuantityDeclaration` and `IngredientComponent`; `massBasis`; `FORM_OF_SUBSTANCE`; `HAS_ACTIVE_MOIETY`.
- Commerce: `PriceObservation.priceKind`, `AffiliateLink`, `SELLER_OF_RECORD_FOR`, `HOSTS_LISTING`.
- Conventions: uid type tokens, live id projection seam, `privacyClass`, private uid prefix, `sourceKind`, predicate exclusivity, validation query families V-1xx to V-5xx (166 numbered queries in total), 42 new constraints and indexes (59 in total; Enterprise-only ones marked).
- Forbidden implications: 65 new (73 in total), each cited to a source and a failing case in its round.
- Fixtures: `study-vs-product-mismatch.cypher`, `diagnostic-comparison.cypher`, `filing-vs-capability.cypher`, `claim-retelling-provenance.cypher`, `recommendation-snapshot.cypher`, each with intentionally absent edges and validation queries that return rows when a collapse is reintroduced.
- Ontology lab: 106 new competency questions with priority classes and traces, 34 new adversarial pairs, `query-shapes.md` (QS-1 to QS-8), `live-schema-alignment.md`, `proposal-index.md`, rounds 0002 to 0009.
- Source registry 0.2.0: 117 claim-scoped entries added (127 total).

### Fixed

- `examples/elysium-basis.cypher` referenced Cypher variables across statement boundaries in eight statements, which would have created blank nodes on a real run; every statement now binds its nodes by uid before MERGE-ing relationships.
- `neo4j/validation.cypher` header notes that V-000a and V-000b pass vacuously if deployed nodes carry no base-archetype label.

### Verification status

All Cypher in `examples/`, `neo4j/` and `ontology-lab/query-shapes.md` passed a syntax check with the Neo4j Cypher language-support parser and a per-statement variable-binding check. The GraphQL delta parses and extends the live schema (directives stripped) without name or field collisions. Nothing was executed against a Neo4j instance; every query is marked statically-checked or illustrative.

### Known provisional boundaries

- Applicability ratio bands and composite scoring calibration (round 0002, DEFERRED).
- Product Variant versus Formulation Version lifecycle criteria (round 0001 stays OPEN).
- Ingredient-material equivalence rules (OPEN-QUESTIONS P1).
- Deployed Neo4j edition and `@neo4j/graphql` behaviour for `extend type` and additional labels (OPEN-QUESTIONS, live stack).
- Media, events and narrative, consumer devices, safety and constraints remain seams or candidates.

## 0.1.0 — 2026-07-13

First provisional schema-production release.

### Added

- Six-archetype semantic kernel.
- First-class Assertion, Adjudication, Source Snapshot, Source Locator, and Evidence Assessment.
- Consumer-supplement modules for organizations, products and commerce, formulations and ingredients, labels, studies and evidence, quality, and regulatory/IP.
- Structural, asserted, and derived relationship classifications.
- Neo4j 5.x constraints, indexes, and validation queries.
- Source-authority registry and source-attributed Elysium/Basis example.
- Explicit forbidden implications and identity-collapse checks.
- Open-question backlog for retrieval- and evaluation-led schema evolution.

### Known provisional boundaries

- Product Variant versus Formulation Version lifecycle criteria.
- Ingredient-material equivalence and evidence inheritance.
- Evidence Applicability dimensions and scoring calibration.
- Canonical versus projected representation of asserted relationships.
- Complete study outcome and population ontology.
