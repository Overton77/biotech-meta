# W09 CQ coverage matrix

Answerability tags follow `competency-questions.md`: A = answerable with the model, Q = answerable with stated qualifications, O = open. Query ids `QS-W09-xx` and validators `V-W09-xx` are in `fixtures/80-queries.cypher`. Results come from execution on Neo4j 5.26.31 Community, recorded in `fixtures/run-results-2026-10-04.json`.

## 1. Existing CQs

| CQ (priority, answerability) | Example answer from the fixtures | Distinction kept | Evidence required | Node / property / edge / edge property | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-ST-01 (Essential, A) | "Real NIR arm: MedX 1116 console, transcranial, six sessions over 2 weeks (808–904 nm). Sham arm: the same console, SHAM_COMPARATOR. Walnut arms: 85 g whole / 5.6 g skins / 34 g de-fatted nutmeat / 51 g oil, single test meal, mass as served." | per-capsule vs per-day; dosage form on the intervention, not the material; device mode is the arm type; provider vs supplier | Registry arms, paper Methods, correction text | `StudyArm{armType}` -`ASSIGNS_INTERVENTION`(asserted)-> `StudyIntervention{route, dosageForm, schedule, dosesPerDay, durationIso, registryInterventionType}` -`HAS_INTERVENTION_COMPONENT`-> `InterventionComponent{quantity, unitCode, quantityBasis, massBasis, quantityStatus, verbatimDoseText}` -`USES_INTERVENTION_MATERIAL`/`USES_INTERVENTION_DEVICE` {asReportedName}->; `PROVIDES_INVESTIGATIONAL_PRODUCT` assertion | QS-W09-02 (run: 2 rows) | Dose without basis; live `doseText` as the only dose record; device forced into a material |
| CQ-ST-02 (Essential, A) | "Tru Niagen 300 shares branded material NIAGEN with the NCT02712593 300 mg arm; Basis shares only the substance." (inherited) | path type sets identity level | Intervention material and formulation components, both with locators | `USES_INTERVENTION_MATERIAL` + W02/W04 paths | inherited CQ-ST-02 pattern (illustrative) | Substance-level match reported as product evidence (INV-008) |
| CQ-ST-03 (Essential, Q) | "Whole-blood NAD+ is `measureKind BIOMARKER`. Its endpoint role is a W10 classification." | measured kind vs endpoint role | Registry outcome text | `OutcomeDefinition.measureKind`, `MEASURES_BIOMARKER`; W10 `EndpointClassification` | W10 | Surrogate status as an outcome attribute |
| CQ-ST-04 (Foundational, Q) | "Registry (observed 2026-10-04) lists Blood NAD+ as SECONDARY. The paper's Discussion calls it 'the major efficacy endpoint'. Registry history is BLOCKED, so earlier registered priority is unknown." | registered vs published priority; observed version vs history | Registry version, publication locator | `DECLARES_OUTCOME_PRIORITY` assertions; `OutcomeDefinition.priority` (derived) + `priorityAssertionUid`; `DEFINED_IN` | QS-W09-04 (6 rows), V-223 (1 informational row), V-W09-07 | Single `isPrimary` overwritten by the last source |
| CQ-ST-05 (Essential, A) | "ATLAS primary (peak power output) NOT_SIGNIFICANT. Hamstring strength UA 500 vs placebo is SIGNIFICANT_FAVORABLE (p = 0.027), a SECONDARY_PRESPECIFIED BETWEEN_ARM test with no multiplicity correction. '+12%' is the UA arm's within-arm change. Placebo fell −9.8% (p = 0.008)." | analysisKind; comparisonKind; not-significant ≠ no effect; within ≠ between | Registry priority, paper sentences | `StudyResult{analysisKind, comparisonKind, statisticalConclusion, multiplicityAdjusted, isStatisticallySignificant}`, `RESULT_FOR_ARM{armRole}`; W10 `INCLUDES_RESULT{inputRole}` | QS-W09-03 (3 rows), V-215/V-215r/V-216 | Marketing "up to 12%" treated as the confirmatory effect |
| CQ-ST-06 (Foundational, Q) | "Basis: 0 serious AEs per arm (0/40, 0/38, 0/40). Collection method not described ('self-reported AEs'). ENERGIZE the same (MedDRA-coded). NCT00938340, ATLAS: no AE rows captured, which is not zero." | reported zero vs not reported; seriousness vs severity; collection method | AE section locators | `AdverseEventResult{seriousness, participantsAffected, participantsAtRisk, eventCount, collectionMethod, collectionMethodText}` + `RESULT_FOR_ARM` + `HAS_ANALYZED_COHORT` | QS-W09-05 (8 rows), V-217r, V-217i (5 informational) | "No AEs reported" stored as "no AEs occurred" |
| CQ-ST-07 (Foundational, Q) | "Berryman 2013 (PMID 23616506) and Zhang 2011 (PMID 21871057) both analyse NCT00938340. They share Study and Dataset, so they are not independent. Zhang (secondary analysis) was published before the primary report." | study vs dataset vs publication; declared vs undeclared reuse | Paper abstracts naming the trial | `PRODUCED_DATASET`, `ANALYZES_DATASET{analysisRole}`, `REPORTS_ON` | QS-W09-07 (1 pair), V-218 | Double counting |
| CQ-ST-08 (Foundational, A for observed versions, O for history) | "As observed 2026-10-04: NCT02678611 COMPLETED, enrollment 120 (type not reported), results not posted, one Canadian site. NCT00938340 results posted. NCT04985630 RECRUITING although its displayed primary completion date (2026-07-31) has passed." | observedAt vs versionDate; resultsPosted vs published; estimated vs actual | Registry snapshots | `RegistrationVersion{…}` via `HAS_REGISTRATION_VERSION` (StateEpisodeProperties, EXCLUSIVE) | QS-W09-01, V-211r, V-212 (1 informational) | `hasResults=false` read as unpublished; status overwritten on resync |
| CQ-ST-09 (Essential, A) | W10 synthesis versions cite `StudyResult`/`Publication`/`RegistrationVersion` as triggers | publication date vs recorded date | — | W09 supplies `Publication.publishedAt`, `RegistrationVersion.observedAt` | W10 | — |
| CQ-ST-10 (Expansion, Q) | "Authors call the 6MWT improvement 'clinically meaningful'. Its significance is not stated in that span (NOT_REPORTED)." | author claim vs BellLabs criterion vs significance | Abstract sentence | Assertion `RESULT_CLINICALLY_MEANINGFUL` on `StudyResult`; W10 `ResultInterpretation` | V-213 | Meaningfulness stored as a result attribute |
| CQ-EV-03 (Foundational, Q) | "Three randomized studies behind the loaded results." | evidence type | Design from registry or paper | `Study.studyKind` | QS-W09-12 | Counting any edge as support |
| CQ-EV-04 (Essential, Q) | W10 dimensions read W09 intervention, component, population and outcome fields | studied intervention vs product | — | `StudyIntervention` (evidence target), `InterventionComponent` bases, `StudyPopulation` cohorts | W10 QS-3 | Direct Study→Product (V-201) |
| CQ-EV-05 (Foundational, Q) | "PMID 30155270 (AUTHOR_CORRECTION, notice published 2018-08-20) CORRECTS PMID 29184669 via ERRATUM event. It replaced reference 20 (old assertion SUPERSEDED with SOURCE_CORRECTION, kept) and added that Elysium provided NRPT and placebo (new assertion, nothing superseded)." | correction vs fact ending vs retraction | Notice text, PubMed record | `Publication.publicationKind`, `CORRECTS{sourceRevisionEventUid}`, W00 `SourceRevisionEvent`, `SUPERSEDES` | QS-W09-06 (1 row), V-W09-04, V-W09-06 | Deleting or editing assertions from a corrected source |
| CQ-ID-01 (Essential, Q) | "The paper names the intervention 'commercially known as Basis'. That is a literal assertion. No study-side record links to a Basis product." | mention vs identity | Paper abstract | Assertion `ADMINISTERED_AS_COMMERCIAL_PRODUCT` (literal) | QS-W09-10 (`hasDirectCommercialEdge=false`) | Name match as identity |
| CQ-ID-02 (Essential, Q) | "Administration ran 2016-01..2016-07 (MONTH, registry). The only Basis formulation known was observed 2026-07-10 with an unknown start, so it is OVERLAP_START_UNKNOWN for the trial window, not 'the current one' and not 'none'. Synthetic contrast: a formulation stated to start 2015-06 covers the window if still true." | administration time vs label retrieval time; unknown start vs none | Study dates with locator; label snapshot | `STUDY_CONDUCTED_DURING` assertion (valid time + precision); W04 `HAS_FORMULATION_VERSION` | QS-W09-09 (2 rows) | Today's label used as the 2016 label |
| CQ-AX-05 (Foundational, Q) | "Two results reduce to 2 dataset-independent lines (ATLAS, ENERGIZE) sharing one sponsor (Amazentis SA). That is a lower bound on dependence." | shared dataset vs shared sponsor vs replication | Dataset links, sponsor assertions | `PRODUCED_DATASET`, `ANALYZES_DATASET`, derived `SPONSORED_BY` | QS-W09-08 (1 row) | "Several studies agree" when they are one |
| CQ-AX-24 (Essential, A) | Pointer: strength is a W10 assessment. W09 removes `Study.evidenceLevel`. | hint vs assessment | — | migration only | W10 | Strength as a node attribute |

## 2. Candidate CQs (new, marked candidate)

| Id | Question | Rationale / failing case | Elements it justifies |
|---|---|---|---|
| CQ-ST-C01 | For a device or energy-delivery arm, which device (model) was used, in which mode (real/sham), with what delivery parameters? | NCT02582593 real vs sham MedX 1116. Catalog `USES_INTERVENTION_MATERIAL` range cannot hold a device. | `USES_INTERVENTION_DEVICE`, `InterventionComponent.quantityStatus` NOT_APPLICABLE, `StudyIntervention.registryInterventionType`, `ArmType.SHAM_COMPARATOR` |
| CQ-ST-C02 | When an arm's intervention is a procedure, regimen, public protocol or lifestyle practice, which reusable definition did it instantiate? | The live union's Procedure/Treatment/Protocol/Lifestyle members have no successor. Synthetic sauna arm (fixture 04). | `FOLLOWS_INTERVENTION_DEFINITION`, `InterventionDefinitionTarget` |
| CQ-ST-C03 | Which registry version does a captured registry fact come from, when the registry's history is not retrievable? | NCT02678611 history BLOCKED 2026-10-04. Two observations must be distinguishable by the registry's own version keys. | `RegistrationVersion.registryVersionNumber`, `lastUpdatePostedDate`, `versionDate` (null = unknown) |

## 3. Element-to-justification map (every SDL element)

| SDL element | Mapped to |
|---|---|
| `Study` (all fields) | CQ-ST-01..09, CQ-EV-03, INV-208 (`overallStatus`, `enrollmentCount`, `projectionOfRegistrationVersionUid`), D-015 (`@fulltext`), D-014 (`searchEmbedding`) |
| `TrialRegistration` | CQ-ST-08, CQ-ST-04 |
| `RegistrationVersion` | CQ-ST-08, CQ-ST-04, CQ-ST-C03, V-211, V-212 |
| `ProtocolVersion` | CQ-ST-04/05 (prespecification source), CL-007 |
| `StudyArm` | CQ-ST-01/05/06 |
| `StudyIntervention` | CQ-ST-01/02, CQ-EV-04, CQ-ID-01, D-003 |
| `InterventionComponent` | CQ-ST-01, CQ-EV-04, INV-203, V-221 |
| `StudyPopulation` | CQ-EV-04 (POPULATION dimension), CQ-ST-08 |
| `OutcomeDefinition` | CQ-ST-03/04/05, V-223 |
| `StudyResult` | CQ-ST-05/10, INV-206, INV-209 |
| `AdverseEventResult` | CQ-ST-06, INV-207 |
| `Publication` | CQ-EV-05, CQ-ST-07/08, CQ-AX-05, D-005 |
| `Dataset` | CQ-ST-07, CQ-AX-05, V-218 |
| `LegacyEvaluatedIntervention`, `Study.evaluates`, `LegacyInterventionArmProperties` | INV-201, D-003, CL-017 (migration compatibility) |
| `InterventionDefinitionTarget`, `FOLLOWS_INTERVENTION_DEFINITION` | CQ-ST-C02 (candidate) |
| `USES_INTERVENTION_DEVICE` | CQ-ST-C01 (candidate) |
| `InterventionMaterialProperties` | V-202, CQ-ST-01, D-011 |
| `ResultArmProperties` | CQ-ST-05 |
| `DatasetAnalysisProperties` | CQ-ST-07, V-218 |
| `PublicationRevisionProperties` | CQ-EV-05, V-W09-04 |
| Catalog enums (`MeasureKind` … `EnrollmentCountType`) | catalog conventions; CQ-ST-03..08 |
| `OutcomeDirection` | live compatibility (reported direction), CQ-ST-05 |
| `ArmType`, `ArmRole`, `AeSeriousness`, `RelatednessAssessor`, `DatasetAccessLevel`, `StudyPopulationKind`, `AnalysisSetKind`, `StudyResultKind`, `EstimateQualifier`, `StudyKind` | property-card vocabularies; CQ-ST-01/05/06/07, CQ-EV-03 |
| `Study.sponsoredBy`, `operatedBy`, `investigatedBy` | live compatibility; CQ-AX-05; forbidden implication SPONSORS_STUDY→EXECUTES_STUDY (V-W09-11) |
| `Study.investigatesConditions`, `studiedInSpecies` | live compatibility; CQ-ST-08 |
| `OutcomeDefinition.measuredByMetrics`, `refersToOutcomes` | live compatibility; CQ-ST-03 |
| `*.supportedBy` (SourceLocator) | INV-002/INV-401; W09-SR-03 |
| `*.identifiers` | identity_resolution; CQ-EV-05 (DOI/PMID), CQ-ST-08 (NCT) |

No unmapped element entered the fragment.
