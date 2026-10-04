# W07 Diagnostics and measurement: domain recommendation

Run `run-2026-10-04-fable51-01`, worker W07 (Opus 5.5). Canonical module: `diagnostics` (catalog 0.2.0, maturity candidate). Inputs read: run files 00 to 04, catalog `diagnostics` module and the conventions enums, architecture section 11, round 0004, OPEN-QUESTIONS Priority 1 diagnostics, CQ-DX-01..09, CQ-AX-21, CQ-MX-02, live-schema-alignment rounds 0004/0005, property cards, `validation.cypher` V-301..V-313, `examples/diagnostic-comparison.cypher`, the lane-3 source-registry entries, the lane-3 types in `proposed-delta.graphql`, and live schema lines 201-215, 1245-1318 and 1402-1455.

## 1. Boundary and subdomains

Diagnostics answers one question family: what was measured, what was computed or inferred, by which concrete procedure or algorithm version, against which interval as printed, and whether two values may share an axis. It has five subdomains:

| Subdomain | Elements (W07 sole writer) | What it is not |
|---|---|---|
| Referent and measurand | `Biomarker` (Entity), `Metric` (Entity, LOINC materialized key) | Not a test, not an assay, not an endpoint role (EndpointClassification, W10) |
| Offered test and composition | `LabTest` (Entity), `PanelDefinition` (VersionedState) | Not identity by name; not a commercial product (W04 `Product` IMPLEMENTS_PANEL) |
| Measurement procedure | `AssayVersion` (VersionedState), `MeasurementMethod`, `Specimen` (type), `ReferenceSystem` (Entities) | Instrument identity is W08 (`ToolOrInstrument`); performing lab identity is W01 (`Organization`); certification is W12 |
| Computation | `Algorithm` (Entity), `AlgorithmVersion` (VersionedState) | Regulatory scope of a software device is W13 |
| Interpretation and comparability | `ReferenceIntervalVersion` (VersionedState), `ComparabilityAssessment` (EvidenceAssessment), legacy `ReferenceRange` (read-only InformationArtifact) | An interval is never a condition (W03) |
| Result contract | interface `DiagnosticResult` | Result storage: public `Observation` is W16's; `PersonalMeasurement` is private (W23 contract) |

Seams: `MEASURED_IN_MATRIX` (W03 meaning, field on W07's Biomarker), `ASSAY_OPERATED_BY` -> W01 `Organization`, `RUNS_ON_INSTRUMENT` -> W08 `ToolOrInstrument`, `CertificationListing` coverage of AssayVersion (W12), `RegulatoryStatus` scoped to AlgorithmVersion (W13), `Observation` implements `DiagnosticResult` (W16, CL-008), `FOR_METRIC` shared with W16 `Target`, chunk support shortcuts (W20).

## 2. Identity, state, artifact, occurrence

- **Identity (Entity):** Biomarker (referent), Metric (measurand; LOINC when one exists), LabTest (issuer + local code), MeasurementMethod (principle), Specimen (type), ReferenceSystem, Algorithm (family; retrieval only).
- **State (VersionedState):** AssayVersion (payload: operator, method, instrument, kit, software version, specimen types, metrics, traceability), AlgorithmVersion (coefficients/inputs/training/output; pinned by versionBasis), ReferenceIntervalVersion (bounds, kind, derivation, partition, one assay version), PanelDefinition (composition version). Any change in a payload field creates a new node; valid time comes from the asserted attachment (`PERFORMED_WITH_ASSAY_VERSION`) or source-stated `effectiveFrom/To`.
- **Artifact (InformationArtifact):** results through the `DiagnosticResult` contract; legacy `ReferenceRange` (captured range text without an assay).
- **Assessment:** ComparabilityAssessment (BellLabs judgment; immutable; SUPERSEDES for re-assessment).
- **Occurrence:** none owned. A specimen draw is a private occurrence and stays outside the shared graph.

## 3. What the 2026-10-04 research settled (03-source-manifest.md)

1. **OQ-L3-01 (how much assay detail is public).** Five records coded against the AssayVersion fields (table in 02-cq-coverage.md section 3). Clinical reference labs publish a method principle (Mayo, Quest) or a kit brand (Labcorp "Roche Tina Quant"); one names the instrument (Mayo: Bio-Rad D-100, plus the IFU revision LB0002870revA); none publishes a software version; none states an EP28 derivation kind; the patient-facing sample report (Labcorp) prints only value, flag, unit, interval and a performing-site code. The consumer vendor (Everlywell) names neither the lab nor the method. Consequence: `softwareVersionStatus` NOT_REPORTED is the common case; same-LOINC results from different labs are SEPARATE_SERIES by default (CQ-DX-03 remains Q); a consumer result often cannot name an AssayVersion at all, which the catalog V-303 cannot express (decision D-W07-07).
2. **OQ-L3-02 (vendor implementation of a published clock).** The DunedinPACE reference implementation carries a software version string (`Version: 0.99.0`) and supports "the Illumina 450K array or the Illumina EPIC array". TruDiagnostic states that its MSA clocks, including DunedinPACE, are "custom algorithms trained directly on our arrays" and publishes no vendor version string on that page. A vendor implementation is therefore a distinct AlgorithmVersion (`versionBasis UNKNOWN`, PROPOSED `DERIVED_FROM_ALGORITHM_VERSION` to 0.99.0), never the publication version. No vendor version string was found in the pages consulted; that is a search result, not proof of absence.
3. **LOINC part model.** 4548-4 = `Hemoglobin A1c/Hemoglobin.total:MFr:Pt:Bld:Qn:` with Method NULL; 59261-8 = `Hemoglobin A1c/Hemoglobin.total^^standardized per IFCC-RMP for CDT:SFr:Pt:Bld:Qn:`. The round-0004 suspicion that "for CDT" was a display artifact is wrong: it is the component adjustment part LP310257-3 in the fully specified name (LOINC 2.83 page). LOINC's own part description says the standardization protocol, not the analytical method, is what distinguishes HbA1c terms, and that instruments after 2011 report both NGSP % and IFCC mmol/mol; hence `ASSAY_FOR_METRIC` is one_or_more.
4. **CLSI EP28-A3c derivation kinds.** The free sample (foreword) names establishment (>= 120 reference individuals per partition), verification by transference using an EP09 method comparison (section 10), and verification with as few as 20 reference individuals (section 11). The catalog enum covers these as ESTABLISHED, TRANSFERRED, VERIFIED; ADOPTED_FROM_MANUFACTURER and a guideline-sourced limit are not EP28 procedures. Real labs print ADA decision limits in the "reference values" field (Mayo, Labcorp) and Quest's printed "reference range" `<5.7 %` is an ADA-based one-sided limit.

## 4. Disposition of every live and catalog element in scope

Decisions: keep, refine, merge, split, seam, defer, retire. Full field-level mapping is in `migration-map.yaml`.

| Element | Origin | Disposition | Final element |
|---|---|---|---|
| `Biomarker` | live + cat | refine | `Biomarker` (Entity); add `uid`, `entityType`, `biomarkerKind`; `specimenMatrix`, `commonUnits`, `measurementDirectness`, `clinicalSignificance`, `agingHallmark`, `biomarkerType` become read-only legacy display |
| `Biomarker.indicatesConditions` (INDICATES) | live | seam (derived, read-only) | AssociationProjectionProperties (W03); never derived from an out-of-interval result |
| `Biomarker.reflectsMechanisms`, `encodedByGenes` | live | keep | MechanismLinkProperties (W03 curated structural) |
| `Biomarker.inPathways`, `expressedInOrgans`, `expressedInContexts` | live | keep read-only pending W03 ruling | MechanismLinkProperties (W07-SR-07) |
| `Biomarker.hasReferenceRanges`, `Metric.hasReferenceRanges` | live | seam (derived, read-only) | DerivedEdgeProperties; V-305a |
| `Biomarker/Metric.supportedBy` (SUPPORTED_BY -> Chunk) | live | move to W20 shortcut | `SUPPORTED_BY_CHUNK` + DerivedSupportProperties, read-only |
| `MEASURED_IN_MATRIX` | cat (W03) | keep; field on Biomarker | `Biomarker.measuredInMatrix` |
| `Metric` | live + cat | refine | add `propertyKind`, `systemKind`, `scaleKind`, `unitStatus`, `definitionText`, `metricKind` (rename of `metricType`) |
| `Metric.loincCode` | live | keep (materialized key) | normalization `^[0-9]{1,7}-[0-9]$`, unique; Identifier via `HAS_IDENTIFIER` |
| `Metric.canonicalUnit`, `ucumUnit` | live | merge | `canonicalUnitCode` (UCUM) |
| `Metric.formulaExpression`, `formulaVariables` | live | seam (read-only) | executable formula = AlgorithmVersion CALCULATED_QUANTITY |
| `Metric.mediaUrl`, `mediaType` | live | defer to W22 (read-only) | media module |
| `Metric.measuredInOrgans` (MEASURED_IN -> Organ) | live | retire | name collides with W03 `MEASURED_IN` (MechanismEvidenceContext); compartment is `systemKind` + `Biomarker.measuredInMatrix` |
| `Metric.quantifiesBiomarkers` (QUANTIFIES) | live + cat | keep; class structural | StructuralEdgeProperties |
| `Metric.reflectsMechanisms` | live | keep | MechanismLinkProperties |
| `LabTest` | live + cat | refine | add `localTestCode`, `issuerUid`, `assayVersions` |
| `LabTest.measuresMetrics` (MEASURES_METRIC) | live + cat | keep; class asserted | MeasurementEdgeProperties |
| `LabTest.measuresBiomarkers` (MEASURES) | live | seam (derived, read-only) | DerivedEdgeProperties |
| `LabTest.usesMethods`, `requiresSpecimens`, `usesPlatforms` | live | move | AssayVersion `USES_METHOD`, `ACCEPTS_SPECIMEN_TYPE`, `RUNS_ON_INSTRUMENT` (Labcorp and Quest disagree on accepted tubes; TruDiagnostic runs DunedinPACE on MSA and EPIC v2) |
| `PanelDefinition` | live + cat | refine (Entity -> VersionedState) | one node per composition version; `INCLUDES_LABTEST` structural; `INCLUDES_BIOMARKER` derived read-only |
| `MeasurementMethod` | live + cat | refine | `methodClass` -> `methodPrinciple`; `RUNS_ON_PLATFORM` kept (W08 type) |
| `Specimen` | live + cat | refine | `specimenType` -> `specimenTypeCode`; type only |
| `ReferenceRange` | live | keep read-only (legacy projection) | archetype InformationArtifact; no new writes |
| `MeasurementMetadata` | live | split | `MeasurementEdgeProperties` (asserted MEASURES_METRIC); payload values move to AssayVersion / ReferenceIntervalVersion |
| `ReferenceSystem`, `AssayVersion`, `Algorithm`, `AlgorithmVersion`, `ReferenceIntervalVersion`, `ComparabilityAssessment` | cat (proposed-delta) | keep; rewritten in full | supersede proposed-delta: payload edges structural (delta wrongly used `AssertedTemporalMetadata`), `OUTPUTS_METRIC` structural per catalog, archetype labels and archetype fields added |
| `DiagnosticResult` | cat (interfaceOnly) | keep as GraphQL interface | `@declareRelationship` on the three structural edges |
| `union ComparableVersion` | proposed-delta | rename | `ComparableVersionTarget` (contract B6) |
| enums `DiagnosticResultKind` ... `ComparabilityVerdict` | cat | keep (frozen values) | `ReportedStatus` moves to W00 (kernel) |
| `ResultQualifier` | cat (private_context enum) | add to shared contract | registry addition requested (W07-SR-03) |
| `COMPARED_TO`, `SAME_TEST_AS`, `HAS_REFERENCE_RANGE` | cat derived | keep | `COMPARED_TO` field lives on W16 `Observation` |
| `Observation.FROM_LAB_TEST`, `Target.comparedToRanges` | live (W16) | seam | not sufficient for comparability; W16 to route through `DiagnosticResult` edges |
| `Product.IMPLEMENTS_PANEL`, `DELIVERS_LABTEST`, `Listing.IMPLEMENTS_PANEL` | live (W04/W15) | keep (other owners) | target types unchanged |

## 5. Alternatives considered

| Alternative | Rejected because |
|---|---|
| One `Test` node keyed by name or LOINC | Fails the real minimal pair: Mayo (HPLC on D-100), Labcorp (Tina Quant), Quest (TINIA) all map to 4548-4 with different intervals (4.0-5.6, 4.8-5.6, `<5.7`). |
| AssayVersion fields on `LabTest` | Lab A's analyzer change and TruDiagnostic's MSA/EPIC split change the procedure while the orderable test stays the same. |
| Reference range on `Biomarker` (live) | Intervals differ by lab and assay for one LOINC code; a lab's interval change must not reinterpret old reports. |
| `DiagnosticResult` as a node type or union | Catalog says interfaceOnly; a union cannot carry the contract fields; a node type would invite private results into the shared graph. |
| `valueStatus: ReportedStatus` (as in the 0.2.0 fixture) | Cannot say BELOW_DETECTION or INVALID_SPECIMEN (contract A7). |
| Nullable bound means "no lower limit" | Catalog `nullMeans: unknown_or_not_applicable` makes `<5.7 %` ambiguous; per-bound `ReportedStatus` resolves it with a kernel enum. |
| AssayVersion operated by the consumer vendor when the lab is unnamed | Misattributes lab identity, certification and interval ownership; a pending UNRESOLVED assertion is used instead (V-303r). |
| Within-version change as a CALCULATED result or as an Assertion with a literal | A CALCULATED assertion needs DERIVED_FROM_ASSERTION inputs (results are not assertions) and an object plus literal violates INV-003; a `CHANGED_BETWEEN` assertion between two results with V-314 is the smallest form. |

## 6. Smallest recommended model

The catalog 0.2.0 diagnostics module, written in full in `sdl-fragment.graphql`, with four refinements, each tied to a failing case in `fixtures/`:

1. `DiagnosticResult` is a GraphQL interface with `@declareRelationship` edges; implementers carry the `DiagnosticResult` label so V-3xx can address them (W07-SR-02).
2. `ReferenceIntervalVersion` gains `lowerBoundStatus`/`upperBoundStatus` (`ReportedStatus`), `lowerBoundInclusive`/`upperBoundInclusive` and `intervalText` (Quest `<5.7 %`; Labcorp `>6.4` in the 2018 sample report versus `>=6.5%` on the 2026 test menu).
3. `valueStatus` uses the catalog `resultQualifier` values (`ResultQualifier`).
4. Validators: V-305c (INV-302 exactly one), V-302r/V-304r (only well-formed assessments license), V-303r (pending MEASURED), V-313r (PrivacyClass values), V-314 to V-318.

Candidate only (cards, not SDL): `Metric.timeAspectKind` (LOINC Time part), `AssayVersion.kitDocumentRevision` (Mayo IFU LB0002870revA, Labcorp insert "Version 1.0: 2017-06"), `ReferenceIntervalDerivation.ADOPTED_FROM_GUIDELINE`, `ResultQualifier.NOT_REPORTED`, a `DiagnosticResult.measuresMetric` contract edge.
