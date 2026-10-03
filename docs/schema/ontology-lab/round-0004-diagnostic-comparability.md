# Round 0004: Diagnostic Comparability

## Header

- Round ID: 0004
- Date: 2026-10-03
- Builder: Lane 3 (diagnostics, devices, manufacturing, regulatory status, commerce)
- Challenger: Lane 3 internal challenger; cross-lane challenge requested from Lane 2 (biomarker and surrogate ontology) and Lane 5 (result placement)
- Owning module: `diagnostics` (proposed promotion `future` -> `candidate`); `consumer_devices` stays `future` with one seam
- Candidate schema version: 0.2.0-candidate (coordinator assigns the final number)
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status (recommendation): `OPEN`, recommend `ACCEPTED` for the module shape after cross-lane review; the coordinator sets the final status.

## Intent and competency questions

- Decision or workflow being supported: before BellLabs shows a person (or an agent) a trend, a comparison between two tests, or an interpretation of a score, the graph must say what was measured, what was inferred, by which assay or algorithm version, against which reference interval version, and whether two values may be placed on the same axis.
- In scope: measurand versus inferred output; orderable test versus assay version versus method principle; LOINC concept versus local test name; unit and traceability; reference interval version and partition; algorithm or model version for scores (epigenetic clocks, AI pathology features); the minimum contract that any result store must satisfy.
- Out of scope: who owns personal results and where they live (Lane 5); clinical decision rules and recommendations (Lane 5 and `recommendation_decisions`); surrogate endpoint ontology (Lane 2, OPEN-QUESTIONS evidence applicability item 5); device firmware lifecycle beyond one seam.
- Competency question IDs: `CQ-DX-01` to `CQ-DX-08` (new), reusing `CQ-TM-03`, `CQ-TM-04`, `CQ-EV-02`, `CQ-RC-03`.

## Case packet

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| LOINC 4548-4 (SRC-LOINC-4548-4) | terminology record | loinc.org/4548-4, Part Model: Component `Hemoglobin A1c/Hemoglobin.total`, Property `MFr`, Time `Pt`, System `Bld`, Scale `Qn`, Method `NULL` | observed 2026-10-03 via Tavily extract (loinc.org is blocked to direct fetch in this environment) | what the LOINC concept denotes; not which assay a lab ran |
| LOINC 17856-6 (SRC-LOINC-17856-6) | terminology record | loinc.org/17856-6, Mapping Guidance: "We do not recommend using this term. All HbA1c tests in US and many other countries are standardized to use LOINC 4548-4." | observed 2026-10-03 | method-specific concept exists but mapping guidance says not to use it |
| LOINC 59261-8 (SRC-LOINC-59261-8) | terminology record | loinc.org/59261-8, title "Hemoglobin A1c/Hemoglobin.total standardized per IFCC-RMP for CDT in Blood" as displayed; language variants render the method as "IFCC protocol"; property SFr | observed 2026-10-03 | a different concept with a different property and unit (mmol/mol) for the same analyte |
| NGSP IFCC/NGSP page (SRC-NGSP-IFCC) | standardization program page | ngsp.org/ifccngsp.asp, Table 2 master equation `NGSP = (0.09148 * IFCC) + 2.152` | observed 2026-10-03 | unit conversion between IFCC (mmol/mol) and NGSP (%) results; traceability chain |
| NGSP certified methods (SRC-NGSP-CERTIFIED) | certification listing | ngsp.org/certified.asp, "Updated 10/01/2026" with PDF lists of certified methods and labs | observed 2026-10-03 | that a method or lab appears on the current certification list; not that a past result was produced while certified |
| NGSP interferences (SRC-NGSP-INTERF) | method-specific interference table | ngsp.org/interf.asp, "Updated June 2026"; rows keyed by instrument and software version, e.g. "Tosoh G8 ver. 5.24, 5.28", "Arkray ADAMS A1c HA-8180V ... ver. EU 1.41" | observed 2026-10-03 | interference from Hb variants and HbF depends on instrument model and software version |
| CLSI EP28-A3c (SRC-CLSI-EP28) | standards body product page | clsi.org/shop/standards/ep28, guideline summary: establishing reference values for a new analyte or a new analytical method, and transfer of reference values between laboratories | observed 2026-10-03 (full text is paywalled; not read) | reference interval establishment, transference, and verification as distinct procedures |
| Ozarda 2016 review (SRC-OZARDA-RI-2016) | peer-reviewed review | PMC4783089, section on transference: RIs may be transferred when methods have similar imprecision, known interferences, comparable calibrators | observed 2026-10-03 | that a transferred interval depends on method comparability |
| Lu 2019 GrimAge (SRC-PMID-30669119) | peer-reviewed publication | PMID 30669119, doi:10.18632/aging.101684, abstract: GrimAge is "a composite biomarker based on the seven DNAm surrogates and a DNAm-based estimator of smoking pack-years", in units of years | published 2019-01-21 | algorithm v1 definition and reported validation |
| Lu 2022 GrimAge2 (SRC-PMID-36516495) | peer-reviewed publication | PMID 36516495, doi:10.18632/aging.204434, abstract: "version 2 of GrimAge (trained on individuals aged between 40 and 92) which leverages two new DNAm based estimators ... logCRP and logA1C" | published 2022-12-14 | a second version with different inputs and training range |
| Levine 2018 PhenoAge (SRC-PMID-29676998) | peer-reviewed publication | PMID 29676998, doi:10.18632/aging.101414 | published 2018-04-18 | PhenoAge definition; trained on whole blood |
| Belsky 2022 DunedinPACE (SRC-PMID-35029144) | peer-reviewed publication | PMID 35029144, doi:10.7554/eLife.73420, abstract: elastic-net on a probe set "restricted to exclude probes with low test-retest reliability" | published 2022-01-14 | output is a pace (years of biological aging per chronological year), not an age |
| Higgins-Chen 2022 PC clocks (SRC-PMID-36277076) | peer-reviewed publication | PMID 36277076, doi:10.1038/s43587-022-00248-2, abstract: "technical noise produces deviations up to 9 years between replicates for six prominent epigenetic clocks"; "retrained principal-component versions" | published 2022-07-15 | that replicate scores from the same algorithm can differ materially; that PC versions are retrained algorithms |
| Owkin Pathology Explorer MCP (SRC-OWKIN-PATHEXPLORER) | model-derived feature service | `pathology_explorer_help`, `list_cohorts`, `list_cell_types`, `features_description(cell_type=lymphocytes)`, `cohort_description(TCGA_BRCA, density_lymphocytes_in_tumor)` | queried 2026-10-03 | which cohorts and feature names the service exposes and their summary statistics |
| arXiv 2508.09926 (SRC-ARXIV-2508-09926) | preprint | arxiv.org/abs/2508.09926, listing shows "arXiv:2508.09926v3" as the current version | observed 2026-10-03 | describes the cell detection model; does not identify which preprint version matches the deployed model |
| FDA De Novo DEN200080 (SRC-FDA-DEN200080) | regulatory record | accessdata.fda.gov De Novo database, DEN200080 "Paige Prostate", product code QPN, regulation 864.3750, decision date 09/21/2021, "granted (DENG)", "Predetermined Change Control Plan Authorized: No" | observed 2026-10-03 | that a specific software device was granted; that no change-control plan was authorized |

## What the sources can and cannot establish

| Source | Can establish | Cannot establish | Schema consequence |
|---|---|---|---|
| LOINC 4548-4 | The measurand concept: HbA1c over total Hb, mass fraction, point in time, blood, quantitative. Method part is `NULL`. | Which instrument, reagent, calibrator, software version, or reference interval a lab used. | A LOINC code identifies a `Metric` (measurand concept), never an `AssayVersion`. Two labs reporting 4548-4 share a measurand, not an assay. |
| LOINC 17856-6 guidance | That a method-specific term exists and that mapping guidance discourages it. | That a lab that reports 4548-4 did not use HPLC. | Method must be recorded on `AssayVersion` independently of the LOINC code; the absence of a method in the LOINC code is not evidence about the method. |
| LOINC 59261-8 | A distinct concept for IFCC-standardized results with a different property and unit. | That values under 59261-8 and 4548-4 are directly comparable. | Different `Metric` nodes; cross-metric comparison requires a `ComparabilityAssessment` carrying the conversion rule. |
| NGSP master equation | A published linear conversion between IFCC and NGSP units. | That a given pair of results was produced by traceable, certified methods. | Conversion is a calculated assertion with a cited rule (`conversionRuleUid`), not an identity between metrics. |
| NGSP certified list | Current listing as of the page update date. | Certification at the time a historical result was produced. | Certification is a time-bounded state on `AssayVersion` (via the existing `CertificationListing`), with valid time, not a boolean. |
| NGSP interferences | Interference profile by instrument model and software version. | Interference for a person (variant carriage is private) or for unlisted versions. | `AssayVersion` must carry `softwareVersion` and instrument model; a software update can change comparability, so it creates a new `AssayVersion`. |
| CLSI EP28 / Ozarda 2016 | That reference intervals are established, transferred, or verified, per partition. | That an interval applies to a different method or population without transfer or verification. | `ReferenceIntervalVersion` attaches to an `AssayVersion` and a partition, with `derivationKind` (ESTABLISHED, TRANSFERRED, VERIFIED, ADOPTED_FROM_MANUFACTURER) and its own validity. |
| GrimAge v1 / GrimAge2 papers | Inputs, training population, output unit for each version. | That a vendor's "GrimAge" report used v1, v2, or a PC variant. | `AlgorithmVersion` is a first-class state; a score without a resolved version stays unresolved, not defaulted to the latest. |
| DunedinPACE paper | Output is a rate, not an age. | Equivalence with any age-type clock. | `AlgorithmVersion.outputKind` separates AGE_ESTIMATE, PACE, RISK_SCORE, FEATURE_MEASURE, CLASSIFICATION. A pace cannot be differenced against an age. |
| Higgins-Chen 2022 | Replicate deviations up to 9 years for prominent clocks; PC versions are retrained. | The noise of any specific vendor pipeline. | A change between two scores of the same `AlgorithmVersion` is still not a measured change without an assessment of technical noise (`ComparabilityAssessment.replicateNoiseBasis`). PC variants are distinct `AlgorithmVersion` nodes linked by `DERIVED_FROM_ALGORITHM_VERSION`. |
| Owkin Pathology Explorer | Cohort names (26 TCGA cohorts), six quantifiable cell types, feature names with text definitions, and summary statistics. Example: `density_lymphocytes_in_tumor` in TCGA_BRCA has count 1038, null_count 85, median 277.1. | Model version string, which preprint version (v1, v2, v3) matches the deployed weights, the unit of area for densities ("per unit area" is stated, the unit is not), the tumor-region segmentation method, slide scanner or stain normalization. | `AlgorithmVersion` needs `versionLabel` nullable plus `versionBasis` (VENDOR_VERSION_STRING, PUBLICATION_VERSION, SERVICE_ENDPOINT_UNVERSIONED, UNKNOWN). Features computed by an unversioned endpoint are recorded with `versionBasis: SERVICE_ENDPOINT_UNVERSIONED` and `retrievedAt`, and cannot enter a longitudinal comparison. Feature unit unknown remains `unitCode: null` with `unitStatus: NOT_REPORTED`, never a guessed unit. |
| FDA DEN200080 | A De Novo grant for a named software device on a date; no PCCP authorized. | Which model build is currently deployed; whether later builds remain within the grant. | `RegulatoryStatus` (Round 0005) scopes to an `AlgorithmVersion` or device version when the source allows; `pcccAuthorized` is a property of the authorization. |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "Hemoglobin A1c" (Lab A local test name) | LabTest (orderable) | `hu:lab-test:synthetic-lab-a-hba1c` | none (local code) | synthetic fixture | local names are not identity |
| "HbA1c" (Lab B local test name) | LabTest (orderable) | `hu:lab-test:synthetic-lab-b-hba1c-ifcc` | none | synthetic fixture | similar name, different metric and assay |
| HbA1c mass fraction in blood | Metric (measurand) | `hu:metric:hba1c-mfr-bld` | LOINC 4548-4 | resolved | LOINC part model |
| HbA1c IFCC substance fraction | Metric (measurand) | `hu:metric:hba1c-ifcc-sfr-bld` | LOINC 59261-8 | resolved | distinct property and unit |
| glycated hemoglobin | Biomarker (biological referent) | `hu:biomarker:hba1c` | none needed | resolved | one biological referent, many metrics |
| "GrimAge" in a vendor report | AlgorithmVersion | unresolved between v1, GrimAge2, PC-GrimAge | PMID 30669119, 36516495, 36277076 | `ResolutionHypothesis` x3 competing | similar names never establish identity |
| "density of lymphocytes in tumor" | Metric (feature definition) + AlgorithmVersion | `hu:metric:owkin-density-lymphocytes-in-tumor`; `hu:algorithm-version:owkin-cell-detection-unversioned` | arXiv 2508.09926 (version not bound) | partially resolved | feature definition known, model version not |

## Builder proposal

Smallest model that answers CQ-DX-01 to CQ-DX-08:

```text
Biomarker (Entity, live, kept)                    biological referent: "glycated hemoglobin", "lymphocyte"
  <-[:QUANTIFIES]- Metric (Entity, live, refined)  measurand or feature definition; LOINC concept via Identifier
LabTest (Entity, live, refined)                   orderable test as offered by a lab or product; local name and code
  -[:MEASURES_METRIC]-> Metric                     (live edge kept)
  -[:PERFORMED_WITH_ASSAY_VERSION {validFrom, validTo, recordedFrom, recordedTo, assertionUid}]-> AssayVersion
AssayVersion (VersionedState, NEW)                one concrete measurement procedure realization
  -[:USES_METHOD]-> MeasurementMethod (Entity, live, kept: method principle, e.g. HPLC, immunoassay, Illumina methylation array)
  -[:RUNS_ON_INSTRUMENT]-> ToolOrInstrument (Entity, live, kept: instrument model)
  -[:ACCEPTS_SPECIMEN_TYPE]-> Specimen (Entity, live, kept: specimen type, not a specimen instance)
  -[:ASSAY_FOR_METRIC]-> Metric
  -[:CALIBRATION_TRACEABLE_TO]-> ReferenceSystem (Entity, NEW, small: NGSP, IFCC RMP, JCTLM-listed methods)
  -[:ASSAY_OPERATED_BY]-> Organization (performing laboratory; exactly one; lab calibration, certification, and intervals are lab-specific)
ReferenceIntervalVersion (VersionedState, NEW, replaces authoritative use of live ReferenceRange)
  -[:FOR_ASSAY_VERSION]-> AssayVersion
  -[:FOR_METRIC]-> Metric
  properties: lowerBound, upperBound, unitCode, partition (sexPartition, ageMinYears, ageMaxYears, fastingStatus, pregnancyStatus, other via PopulationPartition), derivationKind, intervalKind
Algorithm (Entity, NEW)                           named family as sources use it: "GrimAge", "DunedinPACE", "Owkin cell detection"
AlgorithmVersion (VersionedState, NEW)            fixed parameters, inputs, training reference, output kind and unit
  -[:VERSION_OF_ALGORITHM]-> Algorithm
  -[:DERIVED_FROM_ALGORITHM_VERSION]-> AlgorithmVersion (retrained or PC variants)
  -[:REQUIRES_INPUT_METRIC]-> Metric               (e.g., CpG beta values on a named array; HbA1c for eAG)
  -[:COMPATIBLE_WITH_ASSAY_VERSION]-> AssayVersion (asserted, e.g., which methylation arrays are supported)
  -[:OUTPUTS_METRIC]-> Metric                      (e.g., "GrimAge2 age acceleration, years")
ComparabilityAssessment (EvidenceAssessment, NEW)
  -[:COMPARES]-> AssayVersion | AlgorithmVersion | ReferenceIntervalVersion (exactly two subjects)
  properties: verdict, measurandMatch, unitConversionRule, traceabilityMatch, interferenceProfileMatch, referenceIntervalMatch, replicateNoiseBasis, methodVersion
PanelDefinition (live, refined as versioned composition)
```

Result contract (not ownership). Whatever node holds a diagnostic result (live `Observation`, catalog `MeasuredResult`, or the private store Lane 5 chooses) must be able to carry:

- `resultKind`: `MEASURED` | `CALCULATED` | `INFERRED` (an estimated age or a model feature is `INFERRED`; eAG from HbA1c by a fixed formula is `CALCULATED`).
- `PRODUCED_BY_ASSAY_VERSION` -> AssayVersion (required for `MEASURED`).
- `COMPUTED_BY_ALGORITHM_VERSION` -> AlgorithmVersion (required for `CALCULATED` and `INFERRED`).
- `INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION` -> ReferenceIntervalVersion as printed on the report at report time, not the interval current at query time.
- `observedAt` (specimen collection time), `reportedAt`, `valueNumber`, `unitCode` as reported, `valueStatus` keeping `belowDetection`, `notReported`, `unmeasured` distinct (INV-007).

This round labels that contract `DiagnosticResult` in the catalog patch as an interface label, so validation queries can address it without deciding placement. Lane 5 decides whether private results carry it in the shared graph, in a separate graph, or only in a projection.

- Identity rule: a `Metric` is identified by its measurand definition (LOINC concept when one exists, otherwise a BellLabs definition with formula or feature text); a `LabTest` by issuer plus local code; an `AssayVersion` by performing laboratory + method principle + instrument model + reagent/kit identifier + software version + calibration traceability claim (two labs running the same kit on the same analyzer have two AssayVersions, because NGSP certifies labs separately and intervals are lab-specific); an `AlgorithmVersion` by algorithm + version label or, when none, by publication version or service endpoint plus `retrievedAt`. Names never establish identity; similarly named tests are linked only through a `ResolutionHypothesis` or a `ComparabilityAssessment`.
- State/version rule: any change in instrument model, reagent lot family declared by the manufacturer as a new kit version, software version, calibrator traceability, or method principle creates a new `AssayVersion`. A coefficient change, a retrain, a new input, or a training-range change creates a new `AlgorithmVersion`. A new bound, new partition, or new derivation creates a new `ReferenceIntervalVersion`.
- Valid-time rule: `PERFORMED_WITH_ASSAY_VERSION`, `CertificationListing` for NGSP, and `ReferenceIntervalVersion` effective intervals carry `validFrom` / `validTo` from the lab's or program's statement. A lab's announcement of a method change gives `validFrom` for the new edge; unknown change dates stay `null`.
- Recorded-time rule: corrections (for example a lab later says the switch happened a month earlier) create a new recorded-time episode on the edge; the old episode is closed with `recordedTo`.
- Unknown-time rule: a result whose collection date is unknown keeps `observedAt: null`; ingestion time never substitutes.
- Provenance rule: every `PERFORMED_WITH_ASSAY_VERSION`, `COMPATIBLE_WITH_ASSAY_VERSION`, and `OUTPUTS_METRIC` edge is `asserted` and carries `assertionUid`. `ComparabilityAssessment` is BellLabs' judgment and links `SUPPORTED_BY` to locators (NGSP equation, CLSI transfer evidence).
- Projection consequence: agents asked for a trend receive `DiagnosticResult` plus its `AssayVersion` or `AlgorithmVersion` and any `ComparabilityAssessment`; without the assessment the projection must return separate series.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| C1 | Ontological | "Both labs report LOINC 4548-4, so put them on one line." NGSP interference table shows the same measurand behaves differently on different instruments and software versions for Hb variant carriers. | high | Minimal pair: same LOINC, two AssayVersions differing only in software version; a trend query must return two series unless an assessment exists. | Accepted. LOINC binds `Metric` only. V-302 enforces. |
| C2 | Operational | "AssayVersion is too fine; labs rarely publish software versions." | medium | Ingest a lab report with only a method principle. | Accepted with qualification: `AssayVersion` fields are nullable; an `AssayVersion` with unknown software version is a valid node with `softwareVersionStatus: NOT_REPORTED`. It is still distinct from another lab's AssayVersion. Two unknowns never merge by default (V-301). |
| C3 | Ontological | "GrimAge2 is just an update; treat it as the same score." GrimAge2 adds logCRP and logA1C surrogates and changes the training age range (40 to 92). | high | Store two vendor reports, one each version; ask "did biological age improve?" | Accepted. Distinct `AlgorithmVersion`; CQ-DX-05 answer is "not comparable without assessment". V-304 enforces. |
| C4 | Epistemic | "Same algorithm version, same lab: now the change is real." Higgins-Chen reports up to 9 years replicate deviation for prominent clocks. | high | Two results, same AlgorithmVersion and AssayVersion, 4-year difference. | Accepted. A within-version change is a `CALCULATED` difference, not an established biological change. `ComparabilityAssessment.replicateNoiseBasis` must cite a reliability source before a difference is labeled meaningful. The schema blocks the label, not the arithmetic. |
| C5 | Ontological | "Is PC-GrimAge a version of GrimAge or a new algorithm?" | medium | Vendor reports both "GrimAge" and "PCGrimAge". | Resolved: separate `AlgorithmVersion` nodes; `DERIVED_FROM_ALGORITHM_VERSION` to the original; family membership (`VERSION_OF_ALGORITHM`) is an assertion from the source. The family node is a retrieval convenience; comparability never flows through it. |
| C6 | Linguistic | "Reference range 4.0 to 5.6 %" printed on a report versus a guideline diagnostic threshold for HbA1c (value not cited in this round). | high | Two interval nodes with the same unit. | Accepted. `intervalKind` separates `REFERENCE_INTERVAL` (central percentiles of a reference population) from `DECISION_LIMIT` and `GUIDELINE_TARGET`. Being outside a reference interval does not imply a condition (new forbidden implication; V-309). The ADA threshold value itself is not cited in this round (unverified here) and is not encoded in the fixture. |
| C7 | Temporal | "Attach the reference range to the Biomarker, as the live schema does (`Biomarker.HAS_REFERENCE_RANGE`)." A lab changes analyzers; the interval is transferred and verified with about 20 individuals (EP28 transference, per Ozarda 2016). The old interval must still explain old reports. | high | Two `ReferenceIntervalVersion` nodes for one lab, different `FOR_ASSAY_VERSION`, effective intervals adjacent. | Accepted. Live `HAS_REFERENCE_RANGE` from Biomarker/Metric becomes a derived projection only (V-305). Reports keep the interval used at report time. |
| C8 | Operational | "The Owkin service returns a density; we can trend it." No version string, unit of area not stated, tumor-region method not stated. | high | Two retrievals on different dates. | Accepted. `versionBasis: SERVICE_ENDPOINT_UNVERSIONED` blocks longitudinal comparison; `unitStatus: NOT_REPORTED`. The cohort statistics are recorded as a source observation of the service, not as a measured property of TCGA patients. |
| C9 | Epistemic | "A De Novo grant means the current AI model is FDA-authorized." DEN200080 states no PCCP. | medium | Algorithm build updated after grant. | Accepted. `RegulatoryStatus` scopes to the version the record names; if the record does not name a build, the scope stays at the device and the version link is a `ResolutionHypothesis` (Round 0005). |
| C10 | Ontological | "Merge `Metric` and `Biomarker`; they are the same." | medium | HbA1c has two LOINC concepts (4548-4 MFr, 59261-8 SFr) for one biological referent. | Rejected merge. One `Biomarker`, many `Metric`s. |
| C11 | Privacy | "`DiagnosticResult` in the catalog means personal results enter the shared graph." | high | A query over public studies returns a person's HbA1c. | Accepted as a constraint on this round: `DiagnosticResult` is an interface contract with a required `privacyClass`; placement is Lane 5's decision. Fixtures use synthetic results with `privacyClass: 'synthetic'`. |

## Linguistic analysis

- Source wording: "DNAm GrimAge (in units of years)" (PMID 30669119); "version 2 of GrimAge" (PMID 36516495); "Global density of lymphocytes per unit area in the slide" (Owkin `features_description`).
- Normalized proposition: `AlgorithmVersion(GrimAge v1) OUTPUTS_METRIC Metric(GrimAge, unit a)`; `AlgorithmVersion(GrimAge2) DERIVED_FROM_ALGORITHM_VERSION AlgorithmVersion(GrimAge v1)`; `Metric(global_density_lymphocytes) unitStatus NOT_REPORTED`.
- Negation: "We do not recommend using this term" (LOINC 17856-6) is guidance about mapping, not a statement that HPLC results are invalid.
- Modality/hedging: "GrimAge version 2 also applies to younger individuals and to saliva samples" is a reported finding, stored as an Assertion with the paper as source, not as `ACCEPTS_SPECIMEN_TYPE` fact for every vendor pipeline.
- Quantification: "deviations up to 9 years between replicates" is a maximum over reported replicates, not a standard error.
- Scope ambiguity: "Updated 10/01/2026" on the NGSP list scopes certification to now; it does not certify historical results.
- Presuppositions not licensed as facts: a report label "Biological Age" presupposes an algorithm version; unresolved until the vendor names it.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | LOINC parts and NGSP equation extracted verbatim; Owkin outputs copied from tool responses | manual-lane3-2026-10-03 | case packet locators | none yet |
| Resolution | HbA1c metrics resolved by LOINC; vendor "GrimAge" unresolved by design | n/a | competing ResolutionHypothesis | none yet |
| Source reliability | Terminology and standardization bodies authoritative for definitions; papers for their own methods | n/a | source-registry entries | n/a |
| Evidence strength | not assessed in this round | n/a | n/a | n/a |
| Applicability | not assessed (Lane 2) | n/a | n/a | n/a |
| Adjudication | none required for fixtures | n/a | n/a | n/a |
| Decision | none | n/a | n/a | n/a |

## Schema projection

- Projection request ID: `proj-req-0004-diagnostic-trend`
- Selected modules: `kernel`, `provenance`, `temporal`, `identity_resolution`, `diagnostics`
- Closure additions: `CertificationListing` (quality) for NGSP certification; `Identifier` for LOINC; `ResolutionHypothesis`
- Explicit exclusions: private result storage (Lane 5), `recommendation_decisions`, `consumer_devices` beyond `ToolOrInstrument`
- Budget result: not run (no projection compiler in this environment)
- Projection ID/digest: not generated

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/diagnostic-comparison.cypher` (create section) | loads; zero rows from validation section | statically checked only; no Neo4j here | not run |
| Negative fixture | same file, commented "collapse" statements | uncommenting returns rows from V-301b, V-302, V-304, V-305b, V-307 | statically checked only | not run |
| Minimal pair | Lab A vs Lab B HbA1c; GrimAge v1 vs GrimAge2 | different AssayVersion / AlgorithmVersion, no merge | encoded | not run |
| Temporal correction | Lab A analyzer change with corrected `validFrom` | two recorded-time episodes | encoded as two edges | not run |
| Identity collision | similar test names | `ResolutionHypothesis`, no `SAME_TEST_AS` | encoded | not run |
| Extraction evaluation | none | n/a | n/a | n/a |
| Retrieval evaluation | none | n/a | n/a | n/a |
| Migration compatibility | live types kept; additive delta | no live field removed | see live-schema decisions | n/a |

## Decision

- Outcome (recommended): promote `diagnostics` from `future` to `candidate`; accept the measurand / orderable test / assay version / method / algorithm version / reference interval version separation; keep `consumer_devices` at `future` with the seam that a device firmware version is treated as `AssayVersion.softwareVersion` until that module is opened.
- Accepted semantic rule:
  1. A LOINC code identifies a measurand (`Metric`), never an assay or a lab.
  2. Two results may share an axis only if they share `AssayVersion` (measured) or `AlgorithmVersion` (inferred), or a `ComparabilityAssessment` with verdict `COMPARABLE` or `COMPARABLE_WITH_CONVERSION` covers the pair of versions.
  3. A reference interval belongs to an assay version and a population partition and is versioned; a report keeps the interval printed at report time.
  4. Inferred outputs carry the algorithm version that produced them; an unversioned service endpoint is a valid but non-trendable version basis.
  5. Outside a reference interval is not a condition.
- Rejected alternatives: one `Test` node keyed by name (fails C1, C3); reference ranges on `Biomarker` (fails C7); treating `formulaExpression` on `Metric` as the algorithm (fails C3, no version); merging `Metric` and `Biomarker` (fails C10).
- Residual uncertainty: how much assay detail labs and consumer test vendors actually publish (C2); whether a vendor-level `AlgorithmVersion` should be distinct from the published version when the vendor reimplements it (proposed yes: vendor implementation is its own `AlgorithmVersion` with `DERIVED_FROM_ALGORITHM_VERSION` to the publication); the definition of surrogate and intermediate endpoints (Lane 2).
- Required catalog/schema changes: see `lanes/lane3/catalog-patch.yaml` (module `diagnostics`), `live-schema-decisions.md`, and validation V-301 to V-313.
- Required ingestion changes: lab and vendor parsers capture local test code, LOINC (as `Identifier`), method principle, instrument model, software version, printed reference interval, and algorithm version text; unknowns are stored as `NOT_REPORTED`.
- Required retrieval/API/MCP changes: trend endpoints must group by version and return assessments; a "biological age" answer must name the algorithm version or say it is unresolved.
- Changelog and migration references: additive; live `ReferenceRange` and `MeasurementMetadata.referenceRangeText` retained as raw text projections.

### What diagnostics needs from `Observation` (Lane 5 owns the decision)

Live `Observation` is protocol-linked (`PART_OF_PLAN`, `ABOUT_PROTOCOL`) and already has `FROM_LAB_TEST` and `FROM_DEVICE` edges with `MeasurementMetadata`. This round does not claim it for private measurements. Diagnostics needs only that whichever type Lane 5 selects implements the `DiagnosticResult` contract above, and that `FROM_LAB_TEST` is not treated as sufficient for comparability, because a `LabTest` can change `AssayVersion` over time.

### Unverified items

- loinc.org pages were read through Tavily extract because direct fetch is blocked; content was not cross-checked against a LOINC release file. The displayed title of 59261-8 ("standardized per IFCC-RMP for CDT") is recorded as displayed and may be a display artifact.
- CLSI EP28-A3c full text was not read (paywalled); the transference detail relies on the CLSI summary and Ozarda 2016.
- The NGSP certified method PDFs were not opened; no specific certification year is asserted for any instrument.
- The Owkin model's correspondence to arXiv 2508.09926 v1, v2, or v3 is unknown; the service does not expose it.
