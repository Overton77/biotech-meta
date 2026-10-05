# W09 model cards

## Conventions used in every card

- **Common node fields.** Every node has `id` (the opaque segment of `uid`), `uid`, `name`, `description`, `mongoResearchRunId` (INTERNAL tier), `createdAt`/`updatedAt` (operational), `privacyClass` (PUBLIC unless stated), `maturity`, `schemaVersion`, and the fields of its archetype interface. These are not repeated per card.
- **Privacy.** Every W09 element is PUBLIC. No W09 type holds personal data: StudyPopulation describes cohorts, never persons.
- **Property kinds.** O = observed (stated by a source), D = derived/calculated, Op = operational.
- **Temporal behaviour.**
  - A VersionedState payload is immutable. A source correction creates a new state node, linked through a superseding assertion and a new attachment.
  - InformationArtifacts are immutable captures.
  - Entity identity fields are immutable; a merge publishes a redirect through W00 EquivalenceAssessment.
- **Maturity.** PROVISIONAL unless marked CANDIDATE.
- **Sources.** Catalog `studies_and_evidence`, round 0002, the property cards and the manifest S-xx rows.

## A. Node types

### Study (Entity) — uid token `study`
- **Meaning:** The identity of one investigation. It is not its registration, registry version, protocol, publication, dataset, arm, intervention or result (V-012).
- **Labels:** `["Study","Entity"]`
- **Identity:** uid. No natural key: registry ids identify registrations, not studies. Live `Study.id` is kept as the opaque segment.

| Property | Type | Null | Kind | Notes |
|---|---|---|---|---|
| `name` | String | null = untitled | O/Op | Catalog `title` maps here (D-013). |
| `studyKind` | `StudyKind` | null = not classified | D (ingestion classification) | CQ-EV-03 |
| `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` | — | — | D | Never evidence (INV-107) |
| `overallStatus`, `enrollmentCount`, `projectionOfRegistrationVersionUid` | String / Int / String | — | D, read-only cache | Allowed only with the uid; V-210, V-W09-02 |

| Edge | Class | Cardinality |
|---|---|---|
| `REGISTERED_AS` → TrialRegistration | asserted | many |
| `HAS_PROTOCOL_VERSION` | structural | many |
| `HAS_ARM` | structural | many |
| `HAS_ELIGIBLE_POPULATION`, `HAS_ENROLLED_COHORT` | structural | many |
| `DEFINES_OUTCOME` | structural | many |
| `PRODUCED_DATASET` | asserted | many |
| `INVESTIGATES` → Condition | asserted | many |
| `STUDIED_IN` → Species | asserted | many |
| `SPONSORED_BY`, `OPERATED_BY`, `INVESTIGATED_BY` | derived, read-only | many |
| `EVALUATES` → LegacyEvaluatedIntervention | legacy, read-only | many |
| `REPORTS_ON` | inverse field | — |

- **Indexes:** `@fulltext StudySearch(name, description, searchText)`. Fable may add `@vector StudySearchEmbedding`; the retrieval justification is free-text study lookup by agents (live query `searchStudiesBySemanticText`).

### TrialRegistration (Entity) — `trial-registration`
- **Meaning:** One registry entry (ClinicalTrials.gov NCT…, ANZCTR ACTRN… (S-22), ISRCTN…).
- **Identity key:** (`registry`, `registrationId`), plus an `Identifier` (scheme NCT/ACTRN/ISRCTN, issuer = the registry).
- **Properties:** `registry` String! (O, normalized registry name), `registrationId` String! (O, materialized key).
- **Edges:**
  - `REGISTERED_AS` (inverse, one_or_more).
  - `HAS_REGISTRATION_VERSION` → RegistrationVersion (structural, bitemporal_attachment, **EXCLUSIVE** per registration; one edge per recorded-time episode; `StateEpisodeProperties`).
  - `HAS_IDENTIFIER` (asserted, `IdentifierLinkProperties`).

### RegistrationVersion (InformationArtifact) — `registration-version`
- **Meaning:** One observed version of a registry entry.

| Property | Type | Null means | Kind |
|---|---|---|---|
| `observedAt` | DateTime! | invalid (V-211) | Op |
| `versionDate` | Date | history not obtained | O |
| `registryVersionNumber` | Int | not obtained | O |
| `lastUpdatePostedDate` | Date | not obtained | O |
| `briefTitle`, `officialTitle`, `acronym` | String | not captured | O |
| `overallStatus` | String | not captured | O (registry vocabulary, multi-registry so not an enum) |
| `enrollmentCount` | Int | not captured | O |
| `enrollmentCountType` | `EnrollmentCountType` | not reported, never defaulted | O |
| `resultsPosted` | Boolean | not observed; `false` ≠ unpublished | O |
| `resultsFirstPostedDate` | Date | — | O |
| `startDate`, `primaryCompletionDate`, `completionDate` | Date + `*Precision` (TimePrecision) + `*Type` (RegistryDateType) | Date null = not stated; type null = not stated | O |
| `studyType`, `allocation`, `interventionModel`, `masking`, `primaryPurpose` | String | — | O |
| `phase` | [String!] | — | O |
| `siteCountries` | [String!] (ISO 3166-1 alpha-2) | — | O |
| `fdaRegulatedDrug`, `fdaRegulatedDevice` | Boolean | — | O |
| `conditionsVerbatim`, `interventionNamesVerbatim`, `collaboratorNamesVerbatim` | [String!] | — | O |
| `sponsorNameVerbatim` | String | — | O |

- **Edges:**
  - `HAS_REGISTRATION_VERSION` (inverse, exactly_one owner: V-211r).
  - `SUPPORTED_BY` → SourceLocator (WHOLE_SNAPSHOT allowed; W09-SR-03).
  - `DEFINED_IN` (inverse from OutcomeDefinition).
- **Temporal:** The attachment episode carries valid time. With history unavailable, `validFromBasis` is OBSERVATION_ONLY and the bound is null. A later version bounds the earlier one by a VALIDITY_BOUNDED re-attachment, never by editing it (fixture 01, statement 6).

### ProtocolVersion (InformationArtifact) — token requested `protocol-version`
- **Meaning:** One version of the study's own protocol or SAP. It is not a W16 ProtocolEdition (CL-007).
- **Properties:** `versionName` (O), `versionDate` Date (O; null = not stated).
- **Edges:** `HAS_PROTOCOL_VERSION` (inverse, exactly_one); `SUPPORTED_BY`; `DEFINED_IN` (inverse).
- **Maturity:** PROVISIONAL. No fixture instance: no protocol PDF was retrieved.

### StudyArm (VersionedState) — `arm`
- **Properties:** `name` (O; live `armLabel`), `description` (O; live `armDescription`), `armType` (`ArmType`, O; null = not captured; V-221r treats null as non-placebo), `comparatorType` (O, verbatim), `plannedSize` Int (O).
- **Edges:** `HAS_ARM` (inverse, exactly_one study); `ASSIGNS_INTERVENTION` → StudyIntervention (asserted, one_or_more; none for NO_INTERVENTION); `RESULT_FOR_ARM` (inverse).
- **Crossover trials:** an arm is one treatment condition as registered (NCT00938340 lists four).

### StudyIntervention (VersionedState) — `intervention`
- **Meaning:** What one arm was assigned, as reported. It is the W10 evidence target. It is never the current product.
- **Properties:** `route`, `dosageForm` (String pending a shared enum, W09-SR-06), `schedule` (verbatim), `dosesPerDay` Int, `durationIso` (ISO 8601), `registryInterventionType` (O). Null = not reported.
- **Edges:** `ASSIGNS_INTERVENTION` (inverse); `HAS_INTERVENTION_COMPONENT` (structural, one_or_more, or zero for a definition-only intervention); `FOLLOWS_INTERVENTION_DEFINITION` → `InterventionDefinitionTarget` (asserted, **CANDIDATE**).
- **Assertions about it:** `PROVIDES_INVESTIGATIONAL_PRODUCT` (W01 predicate; Organization subject); `ADMINISTERED_AS_COMMERCIAL_PRODUCT` (literal, or a ProductVariant object only through the Assertion's `HAS_OBJECT`, never an edge).

### InterventionComponent (VersionedState) — `intervention-component`

| Property | Type | Kind | Notes |
|---|---|---|---|
| `quantity` | Float | O | — |
| `unitCode` | UCUM String | O | — |
| `quantityBasis` | QuantityBasis (W00) | O | Required when the amount is REPORTED |
| `massBasis` | MassBasis (W00) | O | UNSPECIFIED when the source does not say; null only when not applicable |
| `quantityStatus` | ReportedStatus (W00) | O | REPORTED / NOT_REPORTED / NOT_APPLICABLE |
| `verbatimDoseText` | String | O | — |

- **Edges (all asserted, `InterventionMaterialProperties`; exactly one target overall, V-W09-03):**
  - `USES_INTERVENTION_MATERIAL` → IngredientMaterial.
  - `USES_INTERVENTION_MATERIAL` → ProductVariant (asReportedName required, V-202).
  - `USES_INTERVENTION_MATERIAL` → ProductLot.
  - `USES_INTERVENTION_DEVICE` → Device (**CANDIDATE**).
- **Deviation from the 0.2.0 property card:** `massBasis` is nullable in SDL (the card says non-null). The device case NCT02582593 has no mass. The requirement is conditional and enforced by V-221r.

### StudyPopulation (VersionedState) — token requested `study-population`
- **Properties:** `populationKind` (`StudyPopulationKind`!), `analysisSet` (`AnalysisSetKind`, when ANALYZED), `size` Int, `sizeText`, `sexEligibility`, `minAge`, `maxAge` (verbatim, e.g. "60 Years"), `healthyVolunteers` Boolean. All O.
- **Edges:** `HAS_ELIGIBLE_POPULATION` / `HAS_ENROLLED_COHORT` (inverse); `HAS_ANALYZED_COHORT` (inverse from StudyResult).
- **Example:** NCT00938340 ENROLLED 20 (registry) vs ANALYZED 15 (abstract).

### OutcomeDefinition (VersionedState) — token `outcome` (alias; `outcome-definition` requested)
- **Properties:** `measureKind` (`MeasureKind`!, O), `timepoint` (O, verbatim), `priority` (`OutcomePriority`, **D**, read-only), `priorityAssertionUid` (D).
- **Derivation rule for `priority`:** the valueString of the `DECLARES_OUTCOME_PRIORITY` assertion supported by the earliest RegistrationVersion of the study's registration. Null if none. Regenerated when an earlier version arrives (V-W09-07).
- **Edges (structural):** `DEFINES_OUTCOME` (inverse); `DEFINED_IN` → RegistrationVersion / ProtocolVersion / Publication; `MEASURES_BIOMARKER` → Biomarker (zero_or_one); `MEASURED_BY_METRIC` → Metric; `REFERS_TO_OUTCOME` → Outcome; `RESULT_FOR` (inverse).
- **Registry quirk kept, not merged:** NCT02678611 lists "Blood pressure" as PRIMARY and "Blood Pressure" as SECONDARY in one version (S-01). These are two registered measures, so two OutcomeDefinitions. An equivalence, if ever asserted, is a W00 EquivalenceAssessment.

### StudyResult (InformationArtifact) — `study-result`

| Property | Type | Null means | Kind |
|---|---|---|---|
| `resultKind` | StudyResultKind | — | O |
| `estimate` | Float | — | O |
| `estimateQualifier` | EstimateQualifier | — | O |
| `unitCode` | UCUM | — | O |
| `pValue` | Float | not an exact number | O |
| `pValueText` | String | — | O |
| `ciLower`, `ciUpper`, `ciLevel` | Float | — | O |
| `confidenceIntervalText` | String | — | O |
| `analysisPopulation` | AnalysisSetKind | — | O |
| `analysisKind` | AnalysisKind! | invalid | O, reconciled with registered priority |
| `comparisonKind` | ComparisonKind! | invalid | O |
| `statisticalConclusion` | StatisticalConclusion! | invalid; NOT_REPORTED explicit | O |
| `multiplicityAdjusted` | Boolean | not reported | O |
| `isStatisticallySignificant` | Boolean, read-only | — | D (rule below, V-W09-01) |
| `direction` | OutcomeDirection (reported) | — | O |
| `baselineValue`, `followupValue`, `absoluteChange`, `relativeChangePercent` | Float | — | O |
| `sampleSize` | Int | — | O |
| `timepoint`, `resultText` | String | — | O |

- **Rule for `isStatisticallySignificant`:** SIGNIFICANT_* → true; NOT_SIGNIFICANT → false; otherwise null.
- **Edges (structural):** `RESULT_FOR` → OutcomeDefinition (exactly_one); `RESULT_FOR_ARM` → StudyArm {`armRole`} (one INTERVENTION and zero or more COMPARATOR); `HAS_ANALYZED_COHORT`; `SUPPORTED_BY` → SourceLocator (W09-SR-03).
- **Never stored here:** clinical meaningfulness. It is an Assertion or a W10 ResultInterpretation (V-213).
- **Populating the fields (the ATLAS case):**
  - `analysisKind` comes from the registered priority (primary outcome → PRIMARY_PRESPECIFIED). The paper is checked for agreement.
  - `comparisonKind` comes from the comparison named in the sentence ("compared with placebo" → BETWEEN_ARM; "within-group" → WITHIN_ARM_CHANGE).
  - `statisticalConclusion` comes from the reported test ("do not notice a significant improvement" → NOT_SIGNIFICANT; "p = 0.027 compared with placebo" → SIGNIFICANT_FAVORABLE).
  - `multiplicityAdjusted` comes from the methods statement ("No correction for multiplicity testing was applied" → false).
  - A magnitude stated for an arm with a between-arm p-value becomes **two** results: WITHIN_ARM_CHANGE (estimate +12%, conclusion NOT_REPORTED) and BETWEEN_ARM (p = 0.027, estimate null).

### AdverseEventResult (InformationArtifact, parent StudyResult) — `study-result` (`adverse-event-result` requested)
- **Labels:** `["AdverseEventResult","StudyResult","InformationArtifact"]`. GraphQL `studyResults` queries also return AE nodes, through the shared label.
- **Properties:** `resultKind` (ADVERSE_EVENT_COUNT), `analysisKind`! (SAFETY), `comparisonKind`! (ARM_DESCRIPTIVE), `statisticalConclusion`! (NOT_TESTED for descriptive counts), `eventTerm`!, `eventTermCode`, `eventTermVocabulary`, `seriousness` (`AeSeriousness`!), `participantsAffected` Int, `participantsAtRisk` Int (null = not extracted), `eventCount` Int, `collectionMethod` (`AeCollectionMethod`!), `collectionMethodText`, `relatednessAssessor`, `timeFrameText`. All O.
- **Edges:** `RESULT_FOR_ARM` (exactly one INTERVENTION arm, V-W09-08); `RESULT_FOR` → safety OutcomeDefinition (zero_or_one); `HAS_ANALYZED_COHORT`; `SUPPORTED_BY`.
- **Invariant INV-207:** a zero carries `collectionMethod`. A source without an AE section yields no node.
- **Basis case:** the per-arm zero is deduced from the study-level sentence ("no serious AEs reported during this clinical study"). The derivation is recorded in fixture 05.

### Publication (InformationArtifact) — `publication`
- **Meaning:** The work-level scholarly identity (D-005).
- **Properties:** `name` (title), `publishedAt` + `publishedAtPrecision`, `publicationKind`! (journal designation; S-05 shows PubMed PT "Published Erratum" for a journal "Author Correction", recorded as AUTHOR_CORRECTION with revisionKind ERRATUM on the event), `doi`/`pmid`/`pmcid` (normalized materialized keys, warning V-W09-09 when the Identifier is missing), `venueName`, `citationText`.
- **Edges:** `REPORTS_ON` → Study (asserted); `ANALYZES_DATASET` → Dataset (asserted, `DatasetAnalysisProperties`); `CORRECTS`/`RETRACTS` → Publication (asserted, `PublicationRevisionProperties`); `RENDITION_OF` (inverse, from W00 Source); `HAS_IDENTIFIER`.
- **Indexes:** none proposed (lookup is by DOI/PMID key; see operations).

### Dataset (Entity) — `dataset`
- **Properties:** `datasetKind` (O, verbatim), `accessLevel` (`DatasetAccessLevel`, O), `dataFormat` (O), `sourceUrl` (presentation).
- **Edges:** `PRODUCED_DATASET` (inverse), `ANALYZES_DATASET` (inverse), `HAS_IDENTIFIER`.
- **Live mapping:** `registrationId` → Identifier; `isPrimaryResults` → `analysisRole`.

## B. Relationship types (W09 sole writer)

| Type | Domain → range | Class | Cardinality | Properties | Notes |
|---|---|---|---|---|---|
| REGISTERED_AS | Study → TrialRegistration | asserted | many | AssertedEdgeProperties | |
| HAS_REGISTRATION_VERSION | TrialRegistration → RegistrationVersion | structural, bitemporal_attachment, EXCLUSIVE | episode per recorded interval | StateEpisodeProperties | V-211r, W00 V-508/V-509 |
| HAS_PROTOCOL_VERSION | Study → ProtocolVersion | structural | many | StructuralEdgeProperties | |
| HAS_ARM | Study → StudyArm | structural | many | StructuralEdgeProperties | |
| ASSIGNS_INTERVENTION | StudyArm → StudyIntervention | asserted | one_or_more | AssertedEdgeProperties | |
| HAS_INTERVENTION_COMPONENT | StudyIntervention → InterventionComponent | structural | one_or_more | StructuralEdgeProperties | |
| USES_INTERVENTION_MATERIAL | InterventionComponent → IngredientMaterial \| ProductVariant \| ProductLot | asserted | exactly one target overall | InterventionMaterialProperties | FI USES_INTERVENTION_MATERIAL → EVALUATES_PRODUCT |
| USES_INTERVENTION_DEVICE (CANDIDATE) | InterventionComponent → Device | asserted | zero_or_one | InterventionMaterialProperties | CQ-ST-C01 |
| FOLLOWS_INTERVENTION_DEFINITION (CANDIDATE; W06 asks promotion) | StudyIntervention → InterventionDefinitionTarget | asserted | zero_or_more | AssertedEdgeProperties | CQ-ST-C02 |
| HAS_ELIGIBLE_POPULATION, HAS_ENROLLED_COHORT | Study → StudyPopulation | structural | many | StructuralEdgeProperties | |
| HAS_ANALYZED_COHORT | StudyResult → StudyPopulation | structural | zero_or_one | StructuralEdgeProperties | |
| DEFINES_OUTCOME | Study → OutcomeDefinition | structural | many | StructuralEdgeProperties | |
| DEFINED_IN | OutcomeDefinition → RegistrationVersion \| ProtocolVersion \| Publication | structural | one_or_more | StructuralEdgeProperties | |
| MEASURES_BIOMARKER | OutcomeDefinition → Biomarker | structural | zero_or_one | StructuralEdgeProperties | |
| MEASURED_BY_METRIC (live) | OutcomeDefinition → Metric | structural | many | StructuralEdgeProperties | live MeasurementMetadata dropped (no time fields) |
| REFERS_TO_OUTCOME (live) | OutcomeDefinition → Outcome | structural | many | StructuralEdgeProperties | live AssociationMetadata dropped |
| RESULT_FOR | StudyResult → OutcomeDefinition | structural | exactly_one | StructuralEdgeProperties | |
| RESULT_FOR_ARM | StudyResult → StudyArm | structural | one_or_more | ResultArmProperties | |
| REPORTS_ON | Publication → Study | asserted | many | AssertedEdgeProperties | |
| PRODUCED_DATASET | Study → Dataset | asserted | many | AssertedEdgeProperties | |
| ANALYZES_DATASET | Publication → Dataset | asserted | many | DatasetAnalysisProperties | analysisRole required |
| CORRECTS | Publication → Publication | asserted | many | PublicationRevisionProperties | event kind ERRATUM / CORRECTED_AND_REPUBLISHED (V-W09-04) |
| RETRACTS | Publication → Publication | asserted | many | PublicationRevisionProperties | event kind RETRACTION |
| INVESTIGATES (live) | Study → Condition | asserted | many | AssertedEdgeProperties | live RoleMetadata dropped |
| STUDIED_IN (live) | Study → Species | asserted | many | AssertedEdgeProperties | |
| SPONSORED_BY (live) | Study → Organization | derived, read-only | many | DerivedEdgeProperties | `derivationRule 'inverse-of:SPONSORS_STUDY@1'` + `derivedFromAssertionUids` |
| OPERATED_BY (live) | Study → Organization | derived, read-only | many | DerivedEdgeProperties | `inverse-of:SERVES_AS_CRO_FOR@1`; never from a registry "collaborator" |
| INVESTIGATED_BY (live) | Study → Person | derived, read-only | many | DerivedEdgeProperties | from the W01 investigator predicate (W09-SR-05) |
| EVALUATES (legacy) | Study → LegacyEvaluatedIntervention | legacy, read-only | many | LegacyInterventionArmProperties | type-name collision with W00 `EVALUATES` (W09-SR-13) |

**Why the derived role edges carry `derivationRule` and not `projectionOfAssertionUid`.** The catalog's `projectionOfAssertionUid` form requires the cited predicate to equal the edge type. `SPONSORED_BY` ≠ `SPONSORS_STUDY`. D-011 forbids `assertionUid` on derived edges. So the inverse projection uses the `[derivationRule, derivedFromAssertionUids]` form (V-W09-11).

## C. Relationship-property types

| Type | Fields | Specializes |
|---|---|---|
| InterventionMaterialProperties | all AssertedEdgeProperties fields + `asReportedName` | AssertedEdgeProperties |
| ResultArmProperties | `orderIndex`, `notes`, `mongoResearchRunId` + `armRole: ArmRole!` | StructuralEdgeProperties |
| DatasetAnalysisProperties | all AssertedEdgeProperties fields + `analysisRole: DatasetAnalysisRole!` | AssertedEdgeProperties |
| PublicationRevisionProperties | all AssertedEdgeProperties fields + `sourceRevisionEventUid: String!` | AssertedEdgeProperties (registration W09-SR-02) |
| LegacyInterventionArmProperties | live InterventionArmMetadata stored names (`armLabel`, `interventionRole`, `doseText`, `doseAmount`, `doseUnit`, `route`, `frequency`, `confidence`, `notes`, `mongoResearchRunId`) | none; read-only legacy (W09-SR-02) |

**Qualifier carriage (open, W09-SR-12).** `analysisRole`, `asReportedName` and `armRole` live on the edge. The authorizing Assertion cannot also carry them as `valueString`, because V-003 (literal-xor-object) would fail; this was observed in the first run of fixture 03. W00 must say where an asserted edge's qualifiers live on its Assertion.

## D. Enums (W09 sole writer)

| Enum | Values | Origin | Used by |
|---|---|---|---|
| MeasureKind | BIOMARKER, PERFORMANCE_OUTCOME, PATIENT_REPORTED_OUTCOME, CLINICIAN_REPORTED_OUTCOME, OBSERVER_REPORTED_OUTCOME, CLINICAL_EVENT | catalog | OutcomeDefinition |
| OutcomePriority | PRIMARY, SECONDARY, OTHER_PRESPECIFIED, POST_HOC, SAFETY | catalog | OutcomeDefinition.priority; DECLARES_OUTCOME_PRIORITY literal |
| AnalysisKind | PRIMARY_PRESPECIFIED, SECONDARY_PRESPECIFIED, SUBGROUP_PRESPECIFIED, SUBGROUP_POST_HOC, EXPLORATORY, SAFETY | catalog | StudyResult |
| ComparisonKind | BETWEEN_ARM, WITHIN_ARM_CHANGE, ARM_DESCRIPTIVE | catalog | StudyResult |
| StatisticalConclusion | SIGNIFICANT_FAVORABLE, SIGNIFICANT_UNFAVORABLE, NOT_SIGNIFICANT, NOT_TESTED, NOT_REPORTED | catalog | StudyResult |
| AeCollectionMethod | SYSTEMATIC, SPONTANEOUS, NOT_DESCRIBED | catalog | AdverseEventResult |
| DatasetAnalysisRole | PRIMARY_REPORT, SECONDARY_ANALYSIS, POOLED_ANALYSIS, REANALYSIS | catalog | ANALYZES_DATASET |
| PublicationKind | ARTICLE, AUTHOR_CORRECTION, ERRATUM, RETRACTION_NOTICE, EXPRESSION_OF_CONCERN, PREPRINT, CONFERENCE_ABSTRACT | catalog | Publication |
| RegistryDateType | ACTUAL, ANTICIPATED | catalog | RegistrationVersion |
| EnrollmentCountType | ACTUAL, ESTIMATED | catalog | RegistrationVersion |
| OutcomeDirection | IMPROVED, WORSENED, NO_CHANGE, MIXED, INCONCLUSIVE, UNKNOWN | live | StudyResult.direction (reported only) |
| ArmType | EXPERIMENTAL, ACTIVE_COMPARATOR, PLACEBO_COMPARATOR, SHAM_COMPARATOR, NO_INTERVENTION, OTHER | CT.gov glossary (S-20); W09-SR-01 | StudyArm |
| ArmRole | INTERVENTION, COMPARATOR | property card; W09-SR-01 | RESULT_FOR_ARM |
| AeSeriousness | ANY, SERIOUS, NON_SERIOUS | property card; W09-SR-01 | AdverseEventResult |
| RelatednessAssessor | INVESTIGATOR, SPONSOR, PARTICIPANT, INDEPENDENT_COMMITTEE, NOT_REPORTED | W09-SR-01 | AdverseEventResult |
| DatasetAccessLevel | PUBLIC, CONTROLLED, ON_REQUEST, UNAVAILABLE, UNKNOWN | property card; W09-SR-01 | Dataset |
| StudyPopulationKind | ELIGIBLE, ENROLLED, RANDOMIZED, ANALYZED | W09-SR-01 | StudyPopulation |
| AnalysisSetKind | INTENTION_TO_TREAT, MODIFIED_INTENTION_TO_TREAT, PER_PROTOCOL, SAFETY_SET, COMPLETERS, OTHER, NOT_REPORTED | 0.2.0 fixture values; W09-SR-01 | StudyPopulation, StudyResult |
| StudyResultKind | MEAN, MEDIAN, MEAN_DIFFERENCE, PERCENT_CHANGE, RATIO, ODDS_RATIO, HAZARD_RATIO, RISK_DIFFERENCE, AREA_UNDER_CURVE, PROPORTION, ADVERSE_EVENT_COUNT, OTHER | W09-SR-01 | StudyResult |
| EstimateQualifier | AS_REPORTED, APPROXIMATE, READ_FROM_FIGURE, CALCULATED_BY_BELLLABS | W09-SR-01 | StudyResult |
| StudyKind | INTERVENTIONAL_RANDOMIZED, INTERVENTIONAL_NONRANDOMIZED, INTERVENTIONAL_SINGLE_GROUP, OBSERVATIONAL_COHORT, OBSERVATIONAL_CASE_CONTROL, CROSS_SECTIONAL, CASE_REPORT, CASE_SERIES, PRECLINICAL, SYSTEMATIC_REVIEW, META_ANALYSIS, OTHER | W09-SR-01 | Study |

**0.2.0 fixture value replaced.** The fixture value `INTERVENTIONAL_RCT` maps to INTERVENTIONAL_RANDOMIZED.

**Imported enums (W00 kernel):** QuantityBasis, MassBasis, ReportedStatus, TimePrecision, ValidTimeBasis, PrivacyClass, NodeMaturity.

## E. Unions

| Union | Members | Status |
|---|---|---|
| LegacyEvaluatedIntervention | Product, ChemicalSubstance, ChemicalForm, IngredientMaterial, Protocol, Treatment, Device, Procedure, Lifestyle | Read-only legacy (W02-SR-20, W05-SR-06 accepted). Specializations carrying a member's label (FoodItem, MaterialMixture, MicrobialPreparation → IngredientMaterial) are not listed (duplicate rows under 7.6.3). FoodProduct retired into Product (W05). |
| InterventionDefinitionTarget | Procedure, Treatment, ProtocolEdition, Protocol, Lifestyle | CANDIDATE (CQ-ST-C02); Protocol added for a named regimen without edition content (W05-SR-06); promotion supported by W06-SR-03 |

## F. Asserted predicates (Assertion-only, no edge)

| Predicate | Subject → object or literal | Notes |
|---|---|---|
| `DECLARES_OUTCOME_PRIORITY` | OutcomeDefinition → literal OutcomePriority | — |
| `RESULT_CLINICALLY_MEANINGFUL` | StudyResult → boolean | author claim |
| `STUDY_CONDUCTED_DURING` | Study → literal interval text + valid bounds | — |
| `ADMINISTERED_AS_COMMERCIAL_PRODUCT` | StudyIntervention → literal, or ProductVariant through HAS_OBJECT | — |
| `PROVIDES_INVESTIGATIONAL_PRODUCT` | — | W01 predicate |

Candidate predicates (registration requested in W09-SR-16):

| Predicate | Use |
|---|---|
| `CITES_AS_REFERENCE` | Used in fixture 06 to show SOURCE_CORRECTION |
| `EVALUATES_RISK_FACTOR` | Migration target |
| `RESULTS_UNPUBLISHED` | Only in a negative fixture; forbidden as a registry-only inference |
