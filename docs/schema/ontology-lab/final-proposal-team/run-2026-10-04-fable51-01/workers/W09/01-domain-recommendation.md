# W09 Studies, interventions and results: domain recommendation

Worker W09 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical module `studies_and_evidence` (catalog 0.2.0, digest `8fb50ff0…84f0`). Live baseline `current_biotech_schema.graphql` (`86b5e0b5…f112`) lines 228–239 and 1597–1754. Contract rulings applied: D-003 (`StudyIntervention` type, `LegacyEvaluatedIntervention` union), D-005 (`Publication` is the work, renditions are `Source`s), D-007 (catalog names win), D-011 (`assertionUid` versus `projectionOfAssertionUid`), CL-006, CL-007, CL-017.

## 1. Boundary

W09 owns the **record of a study as reported**: the study identity, its registry entries and their observed versions, its own protocol document versions, its arms, what each arm was assigned (interventions and their components, down to the material, product, lot or device as administered at study time), its cohorts, its outcome definitions, its reported results (including adverse-event rows), the publications that report on it, and the datasets it produced. Every W09 element is something a registry, a protocol or a paper states. W09 does not hold judgements.

Outside W09 (imported by name):

| Concern | Owner | Seam used by W09 |
|---|---|---|
| Whether a result applies to a product, endpoint role, interpretation, synthesis, evidence strength | W10 | W10 points at `StudyIntervention`, `StudyResult`, `Study`, `Publication`, `RegistrationVersion`; V-215/V-216/V-218 read W09 fields. |
| Sponsor, CRO, funder, investigator roles | W01 | `SPONSORED_BY`, `OPERATED_BY`, `INVESTIGATED_BY` are read-only derived projections of W01 predicates. |
| Materials, substances, forms | W02 | `USES_INTERVENTION_MATERIAL → IngredientMaterial`. |
| Products, variants, formulations | W04 | `USES_INTERVENTION_MATERIAL → ProductVariant` only as reported; never Study→Product (INV-201). |
| Lots | W12 | `USES_INTERVENTION_MATERIAL → ProductLot`. |
| Devices | W08 | candidate `USES_INTERVENTION_DEVICE → Device`. |
| Procedures, treatments, lifestyle, public protocols | W06, W05, W16 | candidate `FOLLOWS_INTERVENTION_DEFINITION → InterventionDefinitionTarget`. |
| Biomarkers, metrics | W07 | `MEASURES_BIOMARKER`, `MEASURED_BY_METRIC`. |
| Outcome concepts, conditions, species | W03 | `REFERS_TO_OUTCOME`, `INVESTIGATES`, `STUDIED_IN`. |
| Sources, snapshots, locators, revision events, assertions, identifiers | W00 | `SUPPORTED_BY`, `RENDITION_OF`, `HAS_IDENTIFIER`, `SourceRevisionEvent` named on `CORRECTS`/`RETRACTS`. |
| Safety signals | W17 | AE rows are W09; signals interpret them. |

## 2. Subdomains and archetypes

| Subdomain | Element | Archetype | Why this archetype |
|---|---|---|---|
| Identity | `Study`, `TrialRegistration`, `Dataset` | Entity | Enduring identities; registry status and design change, so they move off `Study` (INV-208). |
| Registry record | `RegistrationVersion` | InformationArtifact | One observed version of a registry entry. Attached by `HAS_REGISTRATION_VERSION` (bitemporal attachment, EXCLUSIVE per registration). |
| Study documents | `ProtocolVersion`, `Publication` | InformationArtifact | Documents. `Publication` is the work; its URLs are W00 Sources (D-005). |
| Design as reported | `StudyArm`, `StudyIntervention`, `InterventionComponent`, `StudyPopulation`, `OutcomeDefinition` | VersionedState | A source's statement of the design. A correction creates a new state (`payloadHash` replay). |
| Results as reported | `StudyResult`, `AdverseEventResult` | InformationArtifact | Captured statements of an estimate or a count, each with a locator. |
| Occurrence | none | — | Study conduct is a `STUDY_CONDUCTED_DURING` Assertion with valid time. A W09 Occurrence type would duplicate it. |

## 3. Disposition of every live and catalog element in scope

| Element | Origin | Disposition | Final element |
|---|---|---|---|
| `Study` | live + cat | **refine** to identity only. Registry fields move to `RegistrationVersion`. `pmid`/`doi` move to `Publication`. `evidenceLevel` moves to W10. `overallStatus` and `enrollmentCount` stay only as a derived read-only cache with `projectionOfRegistrationVersionUid`. | `Study` |
| `Study.registryNamespace`, `registryId` | live | **move** | `TrialRegistration.registry`, `.registrationId` and an `Identifier` |
| `Study.overallStatus`, `registrySyncedAt`, `enrollmentCount`, dates, design fields, `countries`, `fdaRegulated*`, `studyPhase` | live | **move**, with `*DateType`, precision and `enrollmentCountType` added | `RegistrationVersion` |
| `Study.hasResults` | live | **move + rename** | `RegistrationVersion.resultsPosted` (false ≠ unpublished) |
| `Study.sampleSizeText` | live | **move** | `StudyPopulation.sizeText` |
| `Study.canonicalUrl`, `pmid`, `doi` | live | **merge out** | `Publication` + `REPORTS_ON`; `Identifier` |
| `Study.evidenceLevel` | live | **move** (W10) | `EvidenceStrengthAssessment` |
| `Study.evaluates` / `EVALUATES` | live | **keep read-only** (`@settable` false, D-003, CL-017) | `Study.evaluates: [LegacyEvaluatedIntervention!]!` |
| `Study.sponsoredBy`, `operatedBy`, `investigatedBy` | live | **keep as derived** (`DerivedEdgeProperties`, `derivationRule 'inverse-of:<W01 predicate>@1'`) | same fields, read-only |
| `Study.studiesPopulations` / `STUDIES` | live | **merge** | `HAS_ELIGIBLE_POPULATION`, `HAS_ENROLLED_COHORT` |
| `Study.hasDatasets` / `HAS_DATASET` | live | **refine** to asserted | `PRODUCED_DATASET` |
| `Study.investigatesConditions` / `INVESTIGATES` | live | **keep** as asserted; written only when a Condition resolves | same |
| `Study.studiedInSpecies` / `STUDIED_IN` | live | **keep** as asserted | same |
| `Study.hasArms` / `HAS_ARM` | live | **keep** (structural) | `Study.arms` |
| `Study.hasOutcomeMeasures` / `HAS_OUTCOME_MEASURE` | live | **merge** | `DEFINES_OUTCOME` |
| `Study.hasOutcomeResults` / `HAS_OUTCOME_RESULT` | live | **retire** (derived path) | `Study → DEFINES_OUTCOME → OutcomeDefinition ← RESULT_FOR ← StudyResult` |
| `Study.hasOutcomes` / `HAS_OUTCOME` → `StudyOutcome` | live | **retire** (D-007) | `StudyResult` plus finding Assertions |
| `Study.reportsSafetySignals` | live | **retire** from Study; W17 decides the signal side (W09-SR-10) | `AdverseEventResult` per arm |
| `Study.hasPrimarySources` / `HAS_PRIMARY_SOURCE` | live | **retire**: a paper is `Publication` (`REPORTS_ON`) and its Document is a `Source RENDITION_OF` it; other documents back Assertions through locators | — |
| `Study.evaluatesRiskFactors` / `EVALUATES_RISK_FACTOR` | live | **retire** to Assertions with predicate `EVALUATES_RISK_FACTOR`. No CQ justifies an edge type (candidate predicate, W09-SR-16). | Assertion |
| `Study.searchText` etc., `searchEmbedding`, `@fulltext StudySearch` | live | **keep** (D-014/D-015). Fable adds `@vector` without provider. | same |
| `StudyOutcome` | live | **retire** (D-007) | `StudyResult` / Assertion |
| `StudyArm` | live + cat | **refine**: `armType` becomes an enum, `armDescription` becomes `description`, `plannedEnrollment` becomes `plannedSize`, archetype VersionedState | `StudyArm` |
| `StudyArm.receivesInterventions` / `RECEIVES` | live | **split / retire**: edge metadata cannot hold multi-component doses with bases, and `RECEIVES → Product` violates INV-201 | `ASSIGNS_INTERVENTION → StudyIntervention → InterventionComponent` |
| `InterventionArmMetadata` | live | **split**: fields move to arm, intervention and component. The legacy edge keeps the stored names as `LegacyInterventionArmProperties` (read-only). | see migration map |
| `union StudyIntervention` | live | **rename** (D-003) | `LegacyEvaluatedIntervention` (successor members) |
| `StudyIntervention` (catalog node) | cat | **keep** | `StudyIntervention` (VersionedState) |
| `ArmIntervention` (0.2.0 delta) | delta | **retire** (alias only, D-003) | `StudyIntervention` |
| `InterventionComponent` | cat | **keep and refine**: `quantityStatus` added; bases required only when the amount is reported | same |
| `InterventionMaterialMetadata` (delta) | delta | **replace** (D-011) | `InterventionMaterialProperties` |
| `Population` | live | **merge** (D-007) | `StudyPopulation` |
| `OutcomeMeasure` | live | **merge** (D-007) | `OutcomeDefinition` |
| `OutcomeMeasure.isPrimary` | live | **refine**: per-source `DECLARES_OUTCOME_PRIORITY` Assertions plus derived `priority` | — |
| `OutcomeMeasure.outcomeKind`, `measureType`, `timepointLabel` | live | **refine** | `measureKind`, `timepoint` |
| `OutcomeMeasure.measuredByMetrics`, `refersToOutcomes` | live | **keep** (structural payload) | same names on `OutcomeDefinition` |
| `OutcomeResult` | live | **merge** (D-007) | `StudyResult` |
| `OutcomeResult.isStatisticallySignificant` | live | **refine** | `statisticalConclusion` plus derived `isStatisticallySignificant` |
| `OutcomeResult.isClinicallyMeaningful` | live | **move** | Assertion `RESULT_CLINICALLY_MEANINGFUL` / W10 `ResultInterpretation` |
| `OutcomeResult.forMeasures` / `FOR_MEASURE`, `fromArms` / `FROM_ARM` | live | **merge** | `RESULT_FOR`, `RESULT_FOR_ARM {armRole}` |
| `OutcomeResult` numeric fields, `direction` | live | **keep** (renamed per migration map) | `StudyResult` |
| `*.supportedByDocuments` / `supportedByChunks` on study types | live | **retire** from W09 types: support is `SUPPORTED_BY → SourceLocator` (W09-SR-03). Chunk links are W20-derived. | — |
| `Dataset` | live + cat | **keep**: `registrationId` becomes an Identifier, `isPrimaryResults` becomes `ANALYZES_DATASET.analysisRole` | `Dataset` |
| `TrialRegistration`, `RegistrationVersion`, `ProtocolVersion`, `StudyResult`, `AdverseEventResult`, `Publication` | cat | **keep** | same |
| `CORRECTS`, `RETRACTS` | cat | **keep** as asserted. The edge names the W00 `SourceRevisionEvent`. | `PublicationRevisionProperties` |
| `OutcomeDirection` enum | live | **keep** (reported direction only) | same |
| Assessment types `EvidenceApplicability` … `EvidenceStrengthAssessment` | cat | **reference only** (W10) | — |
| `PROVIDES_INVESTIGATIONAL_PRODUCT`, `ADMINISTERED_AS_COMMERCIAL_PRODUCT`, `DECLARES_OUTCOME_PRIORITY`, `RESULT_CLINICALLY_MEANINGFUL`, `STUDY_CONDUCTED_DURING` | cat predicates | **keep as Assertion predicates**. None becomes an edge. | — |

## 4. Smallest recommended model (what the fragment adds beyond the catalog)

1. **No new node types.** The 13 catalog nodes are written in full. `ArmIntervention` is dropped.
2. **Two candidate relationships**, each with a real failing case:
   - `USES_INTERVENTION_DEVICE` (InterventionComponent → W08 `Device`). Failing case: NCT02582593 compares a real and a sham MedX 1116 console, and no catalog range can hold a device.
   - `FOLLOWS_INTERVENTION_DEFINITION` (StudyIntervention → `Procedure | Treatment | ProtocolEdition | Lifestyle`). Failing case: the live union's non-material members have no successor path. Fixture 04 uses a synthetic sauna arm.
3. **Ten closed vocabularies** already named in property cards or the live schema (registered through W09-SR-01).
4. **Two relationship-property types beyond the registry row:**
   - `PublicationRevisionProperties` (CORRECTS/RETRACTS → event). The catalog's "publication-level view of a SourceRevisionEvent" needs the event reference.
   - `LegacyInterventionArmProperties`, the read-only legacy `EVALUATES` edge.
5. **A handful of properties**, each tied to a failing case:

   | Property | Failing case |
   |---|---|
   | `RegistrationVersion.lastUpdatePostedDate`, `registryVersionNumber` | Version identity when history is BLOCKED (CQ-ST-C03) |
   | `conditionsVerbatim` | "Safety: Healthy Subjects" is not a Condition |
   | `interventionNamesVerbatim` | Registry labels such as "Basis 250" |
   | `sponsorNameVerbatim`, `collaboratorNamesVerbatim` | A collaborator is not a CRO |
   | Date `*Precision` | "2016-01" has month precision |
   | `InterventionComponent.quantityStatus` | NOT_APPLICABLE for devices; NOT_REPORTED for pomegranate juice |
   | `AdverseEventResult.collectionMethodText`, `eventTermVocabulary` | Verbatim "self-reported AEs"; MedDRA coding |
   | `StudyResult.pValueText`, `ciLower`/`ciUpper`/`ciLevel` | Inequality p-values |
   | `StudyIntervention.registryInterventionType` | Registry type DEVICE |
   | `OutcomeDefinition.priorityAssertionUid` | Derived priority must name its input |

## 5. Alternatives considered (short)

| Alternative | Rejected because |
|---|---|
| Keep `Study.evaluates` writable with a match-quality property | Round 0002 C2-01: a 2016 trial would apply to a 2026 label. V-201 must stay zero for new data. |
| One union `InterventionTarget = IngredientMaterial \| ProductVariant \| ProductLot \| Device` on one field | Separate typed fields keep GraphQL filters simple and keep the device edge a candidate that can be dropped without touching the catalog edge. |
| Device as an `IngredientMaterial` | Collapses identity kinds; the sham arm uses the same device in a different mode. |
| Store the ATLAS "+12%" as one between-arm result | The 12% is the UA arm's change from baseline. The significance is the between-arm test. The placebo arm declined significantly (−9.8%, p = 0.008). One record would let "up to 12%" read as an effect size. |
| Keep the inherited `collectionMethod: SYSTEMATIC` for the Basis AEs | The paper says only "self-reported AEs". ENERGIZE says only "recorded and coded according to MedDRA". |
| `isPrimary` boolean or a single stored `priority` | Registry and paper disagree for NCT02678611 whole-blood NAD+ (V-223 row). |
| `Study`-level AE flag "no SAEs" | Loses per-arm denominators and the collection method. Silence would become zero. |
| A W09 Occurrence for study conduct | Duplicates the `STUDY_CONDUCTED_DURING` assertion, which already carries valid time with precision. |

## 6. Findings that change frozen validators (filed as conflict requests, not applied)

All four were found by executing the frozen validators on real cases (Neo4j 5.26.31; `fixtures/run-results-2026-10-04.json`).

| Id | Validator | Problem | Case | Proposed fix |
|---|---|---|---|---|
| W09-CR-01 | V-217 | Flags every honest zero whose source does not describe AE elicitation. | Basis: "self-reported AEs" plus "no serious AEs reported". ENERGIZE: "recorded and coded according to MedDRA" plus "No serious AEs were reported". | V-217r (missing method = violation) and V-217i (informational). |
| W09-CR-02 | V-221 | Flags device components, NOT_REPORTED amounts and definition-only procedure arms. It also skips arms whose `armType` is null. | NCT02582593 device arms; NCT04985630 pomegranate juice; walnut arms with null type. | V-221r. |
| W09-CR-03 | V-211 | `count(r)` counts episodes, so the round 0007 re-bounded episode reports two owners. | Synthetic registration DEMO-001. | `count(DISTINCT r)`. |
| W09-CR-04 | V-215 | Checks only CONFIRMATORY, so a secondary result after a null primary can enter as INDEPENDENT_REPLICATION. This contradicts INV-206. | W09's own first draft of fixture 03 did exactly this. | V-215r. |
