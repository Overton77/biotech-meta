# Schema Changelog

## Unreleased: final schema proposal run 2026-10-04 (Fable 5.1 synthesis; proposal only, live schema unchanged)

Artifacts: `final_biotech_schema_proposal.graphql` (standalone `@neo4j/graphql` 7.6.3 SDL, builds), `neo4j/final_biotech_schema_operations.cypher` (+ `.enterprise.cypher` companion), run directory `ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/` (24 packets, reports, validation evidence). Each line below is a reasoned change with its ruling id; everything else in the proposal restates 0.2.0.

### Breaking meaning changes (proposal)

- `HAS_SNAPSHOT` means Source → SourceSnapshot only; entity state caches (Organization, Product → *Snapshot) attach with `HAS_STATE` and `StateEpisodeProperties` (MR-04, W00-R-16).
- The live `Study.evaluates` union edge is read-only legacy, stored as `LEGACY_EVALUATES`; `StudyIntervention` is a node type and the live union is `LegacyEvaluatedIntervention` (D-003, MR-05).
- Retrieval mentions are `MENTIONS_ENTITY` with `RetrievalEdgeProperties`; `MENTIONS` is the kernel SourceLocator → Mention edge only (MR-06, W00-R-19). `IDENTIFIED_BY` folds into `HAS_IDENTIFIER` (MR-08). Media variants use `HAS_MEDIA_VARIANT` (CL-014). Protocol steps hang from `ProtocolEdition` via `HAS_PROTOCOL_STEP {orderIndex}`; a live `Protocol -HAS_STEP->` set migrates to one legacy edition (D-004, CL-013, CH-R-13).
- `Person -RECOMMENDS->` is a derived projection (`DerivedEdgeProperties`) licensed only by a RECOMMENDS speech-act occurrence; validator V-423 is retired in favour of V-W21-06 / V-423r (CL-016, D-011).
- `privacyClass` is stored as the GraphQL enum spelling `PUBLIC` / `INTERNAL`; a null class is NOT public: public-tier reads filter `privacyClass = 'PUBLIC'` on every node of the path (MR-10, F-W5-11; the 0.2.0 "default public" convention is withdrawn by this proposal).
- `Entity.name` is nullable (D-013). `Observation` carries the `DiagnosticResult` label and implements the W07 `DiagnosticResult` interface (CL-008, F-W5-10). `SUPPORTED_BY` is property-less everywhere (F-W5-03); `AFFECTS_MECHANISM` / `MODULATES` carry `AssociationProjectionProperties` on both ends (F-W5-04).
- Live types retired or merged: `Compound` → `ChemicalSubstance`, `CompoundForm` split, `Ingredient`/`Material` → `IngredientMaterial`, `FoodProduct` → `Product {productKind: CONVENTIONAL_FOOD}`, `PhysicalLocation` → `Facility`, `Listing`/`ListingSnapshot` → `MerchantListing`/`Offer`/`PriceObservation`, `ExperienceReport` → `ClaimOccurrence`, `Association` → assertions, `MediaSource` → `DERIVED_FROM_SOURCE` (report 06, section 2).

### Added (proposal)

- Six-archetype label kernel on every node (`@node(labels: [primary, parents..., archetype])`), uid beside live id, SDL-derived relationship class lists for the validators (`validation/harness/gen-params.mjs`).
- Interface field `privacyClass` on `Entity`, `ActorIdentity`, `SearchIndexable` (F-W5-11); provider-less `@vector` indexes on `Organization`, `Treatment`, `TechnologyPlatform` (D-014, F-W5-12).
- `HAS_ANALYTE` (Biomarker → ChemicalSubstance | MolecularEntity, candidate, F-W5-01); `DERIVED_FROM_PROTOCOL` (F-W5-14); `MeasurementPlan.cadenceAnchorAt/cadenceAnchorBasis` (F-W5-13); `Observation.comparedTo` (F-W5-07); `RecommendableTarget`; `SELLS_PRODUCT` and `RECOMMENDS` as declared derived types.
- Candidate modules `interventions` and `food_lifestyle_exposure`; `manufacturing_readiness` promoted to provisional with `ManufacturingProcess`/`ManufacturingStep` (T-002, T-005).
- Enum values with failing cases: see decision report sections C and F-W5-05 (e.g. `MaterialKind.FOOD`, `PathwayKind.NOVEL_FOOD_AUTHORISATION`, `RegulatoryStatusKind.DESIGNATION_ENDED_UNSPECIFIED`, `CadenceUnit.YEAR/MINUTE`).
- Validation: W00 corrections (44 statements replacing 33 of the 0.2.0 queries), Fable Wave 5 validators and generated label checks, compiled into `validation/final-validation-suite.cypher` (the 0.2.0 file itself is unchanged).

### Fixed (run evidence)

- `examples/elysium-basis.cypher` writes `recordedAt = datetime()` (a time bomb for V-110); the run's translated copy pins it. Other translated-fixture repairs are listed in decision report section D (uid tokens, `IDENTIFIED_BY`, derived RECOMMENDS properties, PolicyVersion keys, recordedAt after the cited snapshot, `'synthetic'` privacy class).
- Runtime facts verified on the pinned stack (`@neo4j/graphql` 7.6.3, Neo4j 5.26.31 Community embedded, APOC Core 5.26.31): no `@unique` directive; `@vector` with `provider:` needs feature configuration; APOC Core is required for DateTime reads (MR-12); relationship property uniqueness constraints work; existence/type constraints are rejected by Community (companion file, unverified on Enterprise).

## 0.2.0 (2026-10-03)

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
- Conventions: uid type tokens, live id projection seam, `privacyClass`, private uid prefix, `sourceKind`, predicate exclusivity, validation query families V-1xx to V-5xx (174 numbered queries in total, including the review-driven V-111b, V-123, V-124, V-326c, V-336, V-401b, V-514b), 40 new constraints and indexes (57 in total; Enterprise-only ones marked).
- Forbidden implications: 64 new (72 in total), each cited to a source and a failing case in its round.
- Fixtures: `study-vs-product-mismatch.cypher`, `diagnostic-comparison.cypher`, `filing-vs-capability.cypher`, `claim-retelling-provenance.cypher`, `recommendation-snapshot.cypher`, each with intentionally absent edges and validation queries that return rows when a collapse is reintroduced.
- Ontology lab: 106 new competency questions with priority classes and traces, 34 new adversarial pairs, `query-shapes.md` (QS-1 to QS-8), `live-schema-alignment.md`, `proposal-index.md`, rounds 0002 to 0009.
- Source registry 0.2.0: 117 claim-scoped entries added (127 total).

### Fixed

- `examples/elysium-basis.cypher` referenced Cypher variables across statement boundaries in eight statements, which would have created blank nodes on a real run; every statement now binds its nodes by uid before MERGE-ing relationships.
- `neo4j/validation.cypher` header notes that V-000a and V-000b pass vacuously if deployed nodes carry no base-archetype label.
- Adversarial review (Lane 6, 2026-10-03) found that the merged suite failed its own fixtures and that several guards were dead or bypassable. Fixed: the single `validTimeBasis` queries (V-105 to V-107) rewritten per bound; `SUPPORTED_BY` and `CONTRADICTED_BY` reclassed structural so V-101 can hold; V-110 made kind-aware (`adjudicationKind = CAPTURE_FIDELITY`); V-113 to V-116 rewritten on the private uid prefix instead of the removed `PrivateScope` label; V-007 and V-220 keyed on `assertionUid`; V-112 extended to derivation inputs and assessment-licensed derivations; V-326c and V-336 added to close the `SELLS_PRODUCT` derivation bypass and the unbacked `APPROVAL` status; V-123 and V-124 added as detectors for INV-406 and INV-007; V-506 and V-507 corrected; QS-3a rewritten to read `ApplicabilityDimension` nodes (it had reported every dimension NOT_ASSESSED on its own fixture); a conflicting index removed from `constraints.cypher`; `modules.yaml` ownership regenerated from the catalog (one owner per node, no dependency cycle); every fixture repaired (asserted edges now carry `assertionUid` and `recordedFrom`, missing assertions created, adjudication kinds and `recordedAt` added, SUPERSEDES edge for the diagnostic correction, uid formats fixed, synthetic snapshot hashes and selector kinds added, capture-fidelity policy adjudications recorded); property cards merged into `ontology-lab/property-cards.md`; conflicting question classifications aligned; round 0007's verdict-to-status table replaced with the reconciled rule.

### Verification status

All Cypher in `examples/`, `neo4j/` and `ontology-lab/query-shapes.md` passed a syntax check with the Neo4j Cypher language-support parser and a per-statement variable-binding check. The GraphQL delta parses and extends the live schema (directives stripped) without name or field collisions. On 2026-10-03 the constraints, the six fixtures and all 174 validation queries were **executed** on an embedded Neo4j 5.26 Community instance in the authoring scratchpad: every statement ran; the suite returned zero failing rows with each fixture loaded alone and with all six loaded together (informational queries V-111b, V-212, V-223, V-331, V-401b, V-514b and V-522 return rows by design); the 16 query-shape blocks ran under EXPLAIN, and QS-2b and QS-3a were run with results on their fixtures. Four reintroduced collapses (a `SELLS_PRODUCT` derivation from a `HOSTS_LISTING` input, an `APPROVAL` status with no approving response, a shared node linked to a private record, an `ENDORSES_PRODUCT` edge citing an advisory assertion) were each caught by at least one query. Not executed: the twelve Enterprise-only constraints (property existence and type), which the Community edition rejects, and anything against the deployed database.

### Known provisional boundaries

- Applicability ratio bands and composite scoring calibration (round 0002, DEFERRED).
- Product Variant versus Formulation Version lifecycle criteria (round 0001 stays OPEN).
- Ingredient-material equivalence rules (OPEN-QUESTIONS P1).
- Deployed Neo4j edition and `@neo4j/graphql` behaviour for `extend type` and additional labels (OPEN-QUESTIONS, live stack).
- Media, events and narrative, consumer devices, safety and constraints remain seams or candidates.

## 0.1.0 (2026-07-13)

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
