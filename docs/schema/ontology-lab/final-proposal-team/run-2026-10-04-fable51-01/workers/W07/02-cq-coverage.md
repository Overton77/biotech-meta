# W07 CQ coverage matrix

Answerability codes as in `competency-questions.md` (A answerable, Q qualified, O open). Query ids refer to `fixtures/w07-cq-queries.cypher` (QS-*) and `fixtures/w07-validation.cypher` (V-*); all were run on embedded Neo4j 5.26.31 Community (06-fixtures-and-queries.md).

## 1. Existing CQs

| CQ (priority, ans.) | Example answer (fixture data) | Distinction | Evidence requirement | Proposed element(s) | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-DX-01 (Essential, A) | "Labcorp 001453 measures LOINC 4548-4 (MFr, Bld, Qn) by AssayVersion `labcorp-001453-tina-quant`: kit 'Roche Tina Quant'; method principle and instrument not reported; software NOT_REPORTED; accepts EDTA, lithium heparin and sodium fluoride whole blood." | referent vs measurand vs orderable test vs assay version vs method principle; specimen type vs instance | LOINC part model; lab test-menu page; method notice | `Biomarker`, `Metric.{loincCode, propertyKind, systemKind, scaleKind}`, `LabTest`, `AssayVersion`, `MeasurementMethod`, `Specimen`, `MEASURES_METRIC` (MeasurementEdgeProperties), `PERFORMED_WITH_ASSAY_VERSION` (AssertedEdgeProperties), `USES_METHOD`, `RUNS_ON_INSTRUMENT`, `ACCEPTS_SPECIMEN_TYPE`, `ASSAY_OPERATED_BY` | QS-DX-01, QS-DX-01b (as recorded on a date) | LOINC code read as an assay; local name read as measurand; method guessed from a kit brand |
| CQ-DX-02 (Essential, A) | "52.0 a is INFERRED by GrimAge v1 (PUBLICATION_VERSION) on Lab M EPIC; 5.4 % is MEASURED by Mayo D-100." | measured / calculated / inferred | report structure; algorithm publication | `DiagnosticResult.resultKind`, `PRODUCED_BY_ASSAY_VERSION`, `COMPUTED_BY_ALGORITHM_VERSION`; V-303/V-303r, V-316 | QS-DX-02 | "your biological age was measured at 52" |
| CQ-DX-03 (Essential, Q) | "Lab A 2025-01 (5.4 %) and Lab B 2025-01 (36 mmol/mol): COMPARABLE_WITH_CONVERSION, NGSP(%) = 0.09148 * IFCC + 2.152. Mayo 2025-03 and Labcorp 2025-04 share LOINC 4548-4 but no assessment: SEPARATE_SERIES." | same measurand vs same assay version vs assessed comparability | NGSP equation; lab method notices | `AssayVersion`, `ComparabilityAssessment` (`COMPARES` exactly two), derived `COMPARED_TO`; V-302/V-302r, V-311 | QS-DX-03, QS-AX-21 | false trend from an analyzer change or a lab switch |
| CQ-DX-04 (Essential, A) | "Score: GrimAge2 (label '2', PUBLICATION_VERSION). Vendor 'GrimAge' 50.5: unresolved between v1 and v2. TruDiagnostic DunedinPACE (MSA): version UNKNOWN, PROPOSED derivation from DunedinPACE 0.99.0." | family vs version; vendor implementation vs publication; stated vs presumed | publications; package DESCRIPTION; vendor page | `Algorithm`, `AlgorithmVersion.{versionLabel, versionBasis}`, `VERSION_OF_ALGORITHM`, `DERIVED_FROM_ALGORITHM_VERSION`, `COMPATIBLE_WITH_ASSAY_VERSION`, `REQUIRES_INPUT_METRIC`; V-308 | QS-DX-04 | defaulting to the latest version; equating vendor and publication versions |
| CQ-DX-05 (Foundational, Q) | "Lab M says GrimAge2 decreased (2025-03 49.0 a -> 2025-09 45.0 a); within one AlgorithmVersion; no assessment with a replicateNoiseBasis exists: NOT_ESTABLISHED." | within-version difference vs established change | test-retest study per version (OQ-L3-03) | `ComparabilityAssessment.replicateNoiseBasis`; candidate predicate `CHANGED_BETWEEN`; V-314 | QS-DX-05 | labelling noise as improvement |
| CQ-DX-06 (Foundational, A) | "Lab A 2025-09-10 was reported against 4.1-5.7 % (TRANSFERRED, cobas); the lab's current interval for that assay is 4.0-5.6 % (VERIFIED, from 2026-01-01); the result keeps 4.1-5.7. Labcorp prints REFERENCE_INTERVAL 4.8-5.6, DECISION_LIMIT >=6.5, GUIDELINE_TARGET <7.0." | reference interval vs decision limit vs guideline target; derivation; one-sided vs unknown bound | lab report; CLSI EP28 | `ReferenceIntervalVersion` (+ bound status/inclusivity/text), `FOR_ASSAY_VERSION`, `INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION`; V-305b/c, V-306, V-318 | QS-DX-06, QS-DX-06b | reinterpreting old results with today's interval; "outside range" read as diagnosis (V-309) |
| CQ-DX-07 (Foundational, A) | "Owkin endpoint pinned 2026-10-03 and 2026-10-04: SERVICE_ENDPOINT_UNVERSIONED; density_lymphocytes_in_tumor unit NOT_REPORTED." | versioned vs unversioned endpoint; unit not reported vs unitless | MCP tool outputs | `AlgorithmVersion.{versionBasis, retrievedAt}`, `Metric.unitStatus`; V-312, V-317 | QS-DX-07 | trending an unversioned output; inventing a unit |
| CQ-DX-08 (Foundational, Q) | "Shared-graph results are PUBLIC or INTERNAL only; a `hu:private-` result is a violation." | public source-attributed vs private personal | placement policy (W23) | `DiagnosticResult.privacyClass` (PrivacyClass); V-313r; W23 V-113..V-116 | V-313r, V-114 | public query returning a person's HbA1c |
| CQ-DX-09 (Expansion, O) | "Firmware/app version: recorded as AssayVersion.softwareVersion until W08 opens FirmwareVersion." | device model vs firmware | device notices | `AssayVersion.softwareVersion` (seam) | none (not fixtured) | firmware change hidden inside one device |
| CQ-AX-21 (Expansion, Q) | "Given only two assay-version uids from the private store: Lab A Tosoh vs Lab B IFCC COMPARABLE_WITH_CONVERSION; Mayo vs Labcorp NO_ASSESSMENT_SEPARATE_SERIES." | shared assessment vs private values | assessment only | `ComparabilityAssessment` (PUBLIC), uid-only access | QS-AX-21 (reads no result) | the shared graph receiving the person's values |
| CQ-MX-02 (Essential, seam with W03) | "4548-4: LOINC system Bld; Biomarker HbA1c MEASURED_IN_MATRIX Blood." | compartment of the measurand | LOINC system part; W03 AnatomicalContext | `Biomarker.measuredInMatrix`, `Metric.systemKind` | QS-MX-02 | blood measurand joined to a tissue mechanism step |

## 2. Candidate CQs

| Id | Question | Rationale and failing case | Elements |
|---|---|---|---|
| CQ-DX-C01 (candidate) | Is a printed bound one-sided, unknown, or inclusive/exclusive? | Quest prints `<5.7 %`; Labcorp's 2018 sample report prints `Diabetes: >6.4` and the 2026 menu `>=6.5%`. A null lower bound reads as unknown under the catalog null rule (N14, V-318). | `lowerBoundStatus`, `upperBoundStatus`, `lowerBoundInclusive`, `upperBoundInclusive`, `intervalText` |
| CQ-DX-C02 (candidate) | Which results are measured but cannot yet name their assay version, and why? | Everlywell names no performing laboratory ("Each lab we work with"); catalog V-303 has no pending state for MEASURED (V-303r). | UNRESOLVED `PRODUCED_BY_ASSAY_VERSION` assertion pattern; V-303r |
| CQ-DX-C03 (candidate) | Does a comparability licence come from a well-formed, current assessment? | A three-way assessment (N10) silently licenses an unlicensed trend under V-302 (V-302r, V-304r). | V-302r, V-304r |
| CQ-DX-C04 (candidate) | Does the same orderable-test name hide different metrics? | Labcorp "Hemoglobin A1c" (4548-4, %) vs synthetic Lab C "Hemoglobin A1c" (59261-8, mmol/mol) (N7). | V-315 |

## 3. OQ-L3-01 coding of public records against AssayVersion fields

R = reported, NR = not reported, H = hidden behind a service-area selector (PARTIAL capture).

| Record | Performing lab | Method principle | Instrument | Kit / application | Software version | Traceability claim | Reported unit | Specimen types | Interval and derivation | LOINC |
|---|---|---|---|---|---|---|---|---|---|---|
| Mayo HBA1C test definition PDF | R (Rochester Main Campus) | R (ion-exchange HPLC) | R (Bio-Rad D-100) | R (D-100 HbA1c; IFU LB0002870revA, 2014) | NR ("D-100 software" unversioned) | NR (NGSP mentioned generically, not as this assay's calibration) | R (%) | R (whole blood EDTA) | R 4.0-5.6 % + ADA decision limits; derivation NR (overview says "Mayo-derived, unless otherwise designated", not an EP28 kind) | R 4548-4 |
| Labcorp 001453 test page | NR on page (sample report prints site code 01 and address) | NR ("Roche Tina Quant" is a kit brand) | NR | R (Roche Tina Quant; footnote cites Tina-quant HbA1c Gen.3 insert v1.0 2017-06) | NR | NR | R (%) | R (EDTA, lithium heparin, sodium fluoride) | R 4.8-5.6 % + limits + glycemic target; derivation NR | R 4548-4 (order and result) |
| Labcorp 001453 sample report (2018) | R (site code 01, address, director) | NR | NR | NR | NR | NR | R (%) | NR | R 4.8-5.6 printed; "Diabetes: >6.4"; derivation NR | NR |
| Quest 496 test page | H | R (turbidimetric inhibition immunoassay) | NR | NR | NR | NR | R (%) | R (EDTA; rejects NaF/oxalate and heparin) | R `<5.7 %` (ADA-based); derivation NR | H |
| Everlywell HbA1c product page | NR ("Each lab we work with is CLIA-certified") | NR | NR | NR | NR | NR | NR | R (finger prick) | NR | NR |

Result: 0 of 5 report a software version or an EP28 derivation kind; 1 of 5 names an instrument. The 20-lab/5-vendor sample in OPEN-QUESTIONS remains open; this is a five-record probe.

## 4. Elements covered by invariants or ingestion failures rather than a CQ row

| Element | Covered by |
|---|---|
| `PanelDefinition`, `INCLUDES_LABTEST`, `INCLUDES_BIOMARKER` | CQ-DX-03 (composition at report time); migration of live PanelDefinition; not fixtured (no registered uid token, W07-SR-12) |
| `ReferenceRange` (legacy) | V-305a; live compatibility |
| `MeasurementEdgeProperties` | V-101 (asserted edge carries assertionUid); live `MeasurementMetadata` migration |
| `ReferenceSystem`, `CALIBRATION_TRACEABLE_TO` | CQ-DX-03 traceability dimension; NGSP/IFCC fixture |
| `SAME_TEST_AS` | V-307, V-315 |
| `HAS_REFERENCE_RANGE` | V-305a |
| `ResultQualifier` | contract A7 missingness; INV-007 |
| `Biomarker` legacy association fields | live compatibility; W03 seam |
