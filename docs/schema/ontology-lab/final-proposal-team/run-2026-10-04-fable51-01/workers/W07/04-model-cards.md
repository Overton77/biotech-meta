# W07 model cards

Conventions: privacy class PUBLIC unless stated (no W07 element is private-personal; INV-506). Kind: A asserted, O observed (of the source), C calculated, I inferred, Op operational. Temporal: "payload" = immutable state payload (a change creates a new node); "episode" = bitemporal edge profile. Maturity: PROVISIONAL = in SDL with fixture; CANDIDATE = card only. Kernel archetype fields (uid, id, entityType/stateType/artifactType/assessmentType, payloadHash, createdAt, updatedAt, privacyClass, maturity, schemaVersion) follow contract B2/B3 and are not repeated per card. uid tokens: registered catalog tokens unless marked "requested".

## Node types

### Biomarker (Entity) — `["Biomarker","Entity"]`, token `biomarker`
Meaning: biological referent (glycated hemoglobin, lymphocyte). Not a measurand, test, assay or endpoint role. Identity: uid; name is display; no external key required (molecular identifiers are W03's MolecularEntity, linked by ENCODES).

| Property | Type | Null | Semantics | Kind | Temporal |
|---|---|---|---|---|---|
| biomarkerKind | String | yes | referent kind, open vocabulary | A | stable |
| moleculeClass | String | yes | display | A | stable |
| biomarkerType, specimenMatrix, commonUnits, measurementDirectness, clinicalSignificance, agingHallmark | String / [String!] | yes | legacy display, read-only (`@settable` false); authoritative homes: EndpointClassification, measuredInMatrix, AssayVersion, Metric.canonicalUnitCode, resultKind, W10/W03 | legacy | frozen |
| searchText, searchFields, embeddingModel, embeddingDimensions, searchEmbedding | | yes | SearchIndexable; `BiomarkerSearch` fulltext kept (D-015) | Op | regenerated |

Edges: measuredInMatrix (MEASURED_IN_MATRIX -> AnatomicalContext, structural, zero_or_one, W03 meaning, no properties to match W03's inverse); quantifiedByMetrics (QUANTIFIES, IN); reflectsMechanisms, encodedByGenes (MechanismLinkProperties, structural curated, W03 meaning); inPathways, expressedInContexts, expressedInOrgans (read-only legacy curated, W07-SR-07); indicatesConditions (INDICATES, derived read-only, AssociationProjectionProperties); hasReferenceRanges (HAS_REFERENCE_RANGE, derived read-only); supportedBy (SUPPORTED_BY_CHUNK, W20 DerivedSupportProperties, read-only). Maturity PROVISIONAL. Sources: round 0004 C10; S1.

### Metric (Entity) — `["Metric","Entity"]`, token `metric`
Meaning: measurand or feature definition. LOINC identifies this level only. Identity: `loincCode` when present (unique; normalized `^[0-9]{1,7}-[0-9]$`; also an `Identifier{scheme: LOINC}` through HAS_IDENTIFIER with release), else uid + definitionText. Aliases: live `metricType` -> `metricKind`; `canonicalUnit`/`ucumUnit` -> `canonicalUnitCode`.

| Property | Type | Null | Semantics | Kind |
|---|---|---|---|---|
| metricKind | String | yes | MEASURAND, ALGORITHM_OUTPUT, MODEL_FEATURE, CALCULATED_QUANTITY | A |
| loincCode | String | yes | null = no LOINC concept or unresolved; never "method unknown" | A (terminology mapping) |
| propertyKind, systemKind, scaleKind | String | yes | LOINC Property/System/Scale parts verbatim (4548-4: MFr/Bld/Qn; 59261-8: SFr/Bld/Qn) | O |
| canonicalUnitCode | String (UCUM) | yes | null with unitStatus NOT_REPORTED is never filled by assumption | A |
| unitStatus | ReportedStatus | yes in SDL; required for new writes | REPORTED / NOT_REPORTED (Owkin) / NOT_APPLICABLE (beta values) | O |
| definitionText | String | yes | verbatim definition | O |
| formulaExpression, formulaVariables, mediaUrl, mediaType | String | yes | legacy read-only (AlgorithmVersion; W22) | legacy |

Edges: quantifiesBiomarkers (QUANTIFIES, structural, one_or_more for MEASURAND); identifiers (HAS_IDENTIFIER, asserted, IdentifierLinkProperties); reflectsMechanisms; hasReferenceRanges (derived read-only); assayVersions (ASSAY_FOR_METRIC, IN); outputOfAlgorithmVersions (OUTPUTS_METRIC, IN); supportedBy. Forbidden: [SIMILAR_TEST_NAME, SAME_METRIC] (V-315). Validators V-310a/b. PROVISIONAL.

### LabTest (Entity) — `["LabTest","Entity"]`, token `lab-test`
Meaning: orderable test as offered. Identity: issuerUid + localTestCode (Labcorp 001453, Mayo HBA1C, Quest 496); name never identity. Properties: localTestCode (String, A), issuerUid (String, A; uid of W01 Organization), testType (display). Edges: measuresMetrics (MEASURES_METRIC, asserted, MeasurementEdgeProperties, one_or_more); assayVersions (PERFORMED_WITH_ASSAY_VERSION, asserted episode, AssertedEdgeProperties, many); measuresBiomarkers (MEASURES, derived read-only); sameTestAs (SAME_TEST_AS, derived read-only, projection of an accepted ResolutionHypothesis, V-307); includedInPanels (INCLUDES_LABTEST, IN). PROVISIONAL.

### PanelDefinition (VersionedState) — `["PanelDefinition","VersionedState"]`, token `panel-definition` (requested, W07-SR-12)
Meaning: one composition version of a panel. Identity: issuer + panel code + versionLabel; payloadHash over the ordered LabTest uids. Properties: panelType (display), versionLabel (String, A), effectiveFrom/effectiveTo (DateTime, A, payload). Edges: includesLabTests (INCLUDES_LABTEST, structural, StructuralEdgeProperties.orderIndex); includesBiomarkers (derived read-only). PROVISIONAL (no fixture: uid token not registered).

### MeasurementMethod (Entity) — token `method`
Method principle (HPLC, IMMUNOASSAY, METHYLATION_ARRAY). Property methodPrinciple (rename of methodClass). Edges: runsOnPlatforms (RUNS_ON_PLATFORM -> W08 TechnologyPlatform, structural, W07-SR-08); usedByAssayVersions (USES_METHOD, IN). Never a comparability path. PROVISIONAL.

### Specimen (Entity) — token `specimen-type`
Specimen type only (instances are private). Properties: specimenTypeCode (rename of specimenType; WHOLE_BLOOD_EDTA, WHOLE_BLOOD_LITHIUM_HEPARIN, WHOLE_BLOOD_SODIUM_FLUORIDE, ...), collectionSetting (text). Edge acceptedByAssayVersions (IN). CANDIDATE refinement: bind to an external specimen-type code system via Identifier. PROVISIONAL.

### ReferenceSystem (Entity) — token `reference-system`
NGSP, IFCC RMP, reference materials. Property referenceSystemKind (STANDARDIZATION_PROGRAM, REFERENCE_MEASUREMENT_PROCEDURE, REFERENCE_MATERIAL). Edge traceableAssayVersions (IN). Not a certification (W12). PROVISIONAL.

### Algorithm (Entity) — token `algorithm`
Family name (GrimAge, DunedinPACE, Owkin cell detection). Edge versions (VERSION_OF_ALGORITHM, IN). Forbidden [SAME_ALGORITHM_FAMILY, SAME_ALGORITHM_VERSION] (V-304/V-304r). PROVISIONAL.

### AssayVersion (VersionedState) — token `assay-version`
Meaning: one lab's measurement procedure realization. Identity: payloadHash over (operator uid, method uid, instrument uid, assayKitIdentifier, softwareVersion, sorted metric/specimen/reference-system uids). Two NOT_REPORTED versions never merge by default.

| Property | Type | Null | Semantics | Kind | Temporal |
|---|---|---|---|---|---|
| assayKitIdentifier | String | yes | kit/application as named ("Roche Tina Quant", "Bio-Rad D-100 HbA1c"); never a lot | A | payload |
| softwareVersion | String | yes | instrument/analysis software ("5.24"); device firmware until W08 FirmwareVersion | A | payload |
| softwareVersionStatus | ReportedStatus! | no | REPORTED / NOT_REPORTED / NOT_APPLICABLE | O | payload |
| reportedUnitCode | String (UCUM) | yes | unit this version reports | A | payload |
| effectiveFrom, effectiveTo | DateTime | yes | source-stated; validity comes from PERFORMED_WITH_ASSAY_VERSION episodes | A | payload |

Edges (payload, structural, StructuralEdgeProperties): operatedBy ASSAY_OPERATED_BY -> Organization exactly_one (V-301b); usesMethod zero_or_one (V-301a); runsOnInstrument -> ToolOrInstrument zero_or_one (V-301a); forMetrics ASSAY_FOR_METRIC one_or_more (LOINC S1: dual-unit reporting); acceptsSpecimenTypes many; traceableTo many. Inverse: usedByLabTests (asserted), referenceIntervalVersions, compatibleAlgorithmVersions. CANDIDATE: kitDocumentRevision (Mayo IFU LB0002870revA; Labcorp insert v1.0 2017-06). PROVISIONAL.

### AlgorithmVersion (VersionedState) — token `algorithm-version`
Meaning: one fixed algorithm realization. Identity: algorithm + versionLabel; else publication; else endpoint + retrievedAt (one node per retrieval pin).

| Property | Type | Null | Semantics | Kind |
|---|---|---|---|---|
| versionLabel | String | yes | as stated ("1", "2", "0.99.0"); null when none | A |
| versionBasis | AlgorithmVersionBasis! | no | INV-303, V-308 | A |
| outputKind | AlgorithmOutputKind! | no | PACE never differenced against AGE_ESTIMATE | A |
| outputUnitCode | String (UCUM) | yes | a; a/a | A |
| trainingPopulationText | String | yes | verbatim | O |
| retrievedAt | DateTime | yes; required for SERVICE_ENDPOINT_UNVERSIONED (V-317) | retrieval pin, not a release date | Op |

Edges: versionOf (VERSION_OF_ALGORITHM, structural, exactly_one); derivedFrom (DERIVED_FROM_ALGORITHM_VERSION, asserted); requiresInputMetrics (REQUIRES_INPUT_METRIC, asserted); compatibleWithAssayVersions (COMPATIBLE_WITH_ASSAY_VERSION, asserted); outputsMetrics (OUTPUTS_METRIC, structural, one_or_more). Vendor reimplementations are distinct versions (S8, S9). PROVISIONAL.

### ReferenceIntervalVersion (VersionedState) — token `ri-version`
Meaning: one interval or limit, for one Metric, one AssayVersion, one partition, with kind and derivation.

| Property | Type | Null | Semantics | Kind |
|---|---|---|---|---|
| lowerBound, upperBound | Float | yes | bound values in unitCode | A |
| lowerBoundStatus, upperBoundStatus | ReportedStatus | yes (null = unknown) | NOT_APPLICABLE = one-sided (Quest `<5.7 %`); V-318 | A (new, CQ-DX-C01) |
| lowerBoundInclusive, upperBoundInclusive | Boolean | yes | comparator as printed (`>=6.5` vs `>6.4`) | A (new) |
| unitCode | String (UCUM) | yes | | A |
| intervalText | String | yes | verbatim printed interval | O (new) |
| intervalKind | ReferenceIntervalKind! | no | | A |
| derivationKind | ReferenceIntervalDerivation! | no | NOT_REPORTED when silent | A |
| sexPartition, ageMinYears, ageMaxYears, fastingStatus, pregnancyStatus, partitionText | String/Float | yes | null = not stated, never "all" | A |
| effectiveFrom, effectiveTo | DateTime | yes | lab-stated validity (payload) | A |

Edges: forAssayVersion (FOR_ASSAY_VERSION, structural, exactly_one: V-305b + V-305c); forMetric (FOR_METRIC, structural, exactly_one; W07-SR-05). Rule: results keep the version printed at report time (V-306; QS-DX-06). PROVISIONAL.

### ComparabilityAssessment (EvidenceAssessment) — token `comparability`
Meaning: BellLabs' judgment that two versions share an axis. Required: assessmentType, methodVersion, status, recordedAt, verdict. Dimensions (String, nullable): measurandMatch, unitConversionRule (required for COMPARABLE_WITH_CONVERSION, service-enforced), traceabilityMatch, interferenceProfileMatch, referenceIntervalMatch, replicateNoiseBasis (null = no within-version licence), rationale. `confidence` deprecated, never written. Edge compares (COMPARES -> ComparableVersionTarget, structural, exactly_two same kind; V-311; only well-formed current assessments license, V-302r/V-304r). Privacy PUBLIC (CQ-AX-21 is a PUBLIC-tier question; property card said internal: D-W07-10). Immutable; SUPERSEDES for re-assessment. PROVISIONAL.

### ReferenceRange (InformationArtifact, legacy) — token `reference-range` (requested, W07-SR-12)
Captured range text without an assay. All live fields read-only; `projectionOfReferenceIntervalVersionUid` names a regenerating RIV. No new writes (V-305a). DEPRECATED-on-arrival (maturity DEPRECATED recommended).

### DiagnosticResult (interface; implementers InformationArtifact)
Contract fields: artifactType!, publishedAt, observedAt (collection time; null when unknown), contentHash, privacyClass (PUBLIC/INTERNAL only, V-313r), resultKind!, valueNumber, valueString, unitCode (as reported), valueStatus (ResultQualifier), reportedAt. Declared relationships (`@declareRelationship`, implementers must annotate with `@relationship`, verified in 7.6.3): producedByAssayVersion (PRODUCED_BY_ASSAY_VERSION, structural; exactly_one for MEASURED, or a pending UNRESOLVED assertion under V-303r); computedByAlgorithmVersion (COMPUTED_BY_ALGORITHM_VERSION, structural; exactly_one for CALCULATED/INFERRED unless UNRESOLVED pending); interpretedWithReferenceIntervalVersion (INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION, structural, many, same AssayVersion, V-306). Implementer labels must include `DiagnosticResult` (W07-SR-02). Forbidden: [INFERRED_RESULT, MEASURED_RESULT] (V-303, V-316); [OUTSIDE_REFERENCE_INTERVAL, INDICATES_CONDITION] (V-309); [WITHIN_VERSION_SCORE_DIFFERENCE, MEASURED_BIOLOGICAL_CHANGE] (V-314). CANDIDATE: a contract edge to Metric (W07-SR-04).

## Relationship types (W07 registry row)

| Type | Domain -> range | Class | Cardinality | Properties | Validator |
|---|---|---|---|---|---|
| QUANTIFIES | Metric -> Biomarker | structural | one_or_more (MEASURAND) | StructuralEdgeProperties | — |
| MEASURES_METRIC | LabTest (and W08 Device/Sensor) -> Metric | asserted | one_or_more | MeasurementEdgeProperties | V-101 |
| PERFORMED_WITH_ASSAY_VERSION | LabTest -> AssayVersion | asserted (episode) | many | AssertedEdgeProperties | V-101, V-102, V-106 |
| ASSAY_FOR_METRIC | AssayVersion -> Metric | structural | one_or_more | Structural | — |
| ASSAY_OPERATED_BY | AssayVersion -> Organization | structural | exactly_one | Structural | V-301b |
| USES_METHOD | AssayVersion -> MeasurementMethod | structural | zero_or_one | Structural | V-301a |
| RUNS_ON_INSTRUMENT | AssayVersion -> ToolOrInstrument | structural | zero_or_one | Structural | V-301a |
| ACCEPTS_SPECIMEN_TYPE | AssayVersion -> Specimen | structural | many | Structural | — |
| CALIBRATION_TRACEABLE_TO | AssayVersion -> ReferenceSystem | structural | many | Structural | — |
| VERSION_OF_ALGORITHM | AlgorithmVersion -> Algorithm | structural | exactly_one | Structural | — |
| DERIVED_FROM_ALGORITHM_VERSION | AlgorithmVersion -> AlgorithmVersion | asserted | many | AssertedEdgeProperties | V-101 |
| REQUIRES_INPUT_METRIC | AlgorithmVersion -> Metric | asserted | many | AssertedEdgeProperties | V-101 |
| COMPATIBLE_WITH_ASSAY_VERSION | AlgorithmVersion -> AssayVersion | asserted | many | AssertedEdgeProperties | V-101 |
| OUTPUTS_METRIC | AlgorithmVersion -> Metric | structural | one_or_more | Structural | — |
| FOR_ASSAY_VERSION | ReferenceIntervalVersion -> AssayVersion | structural | exactly_one | Structural | V-305b, V-305c |
| FOR_METRIC | ReferenceIntervalVersion -> Metric | structural | exactly_one | Structural | — |
| COMPARES | ComparabilityAssessment -> ComparableVersionTarget | structural | exactly_two | Structural | V-311 |
| INCLUDES_LABTEST | PanelDefinition -> LabTest | structural | one_or_more | Structural (orderIndex) | — |
| PRODUCED_BY_ASSAY_VERSION | DiagnosticResult -> AssayVersion | structural | see contract | implementer's choice; recommended Structural | V-303r |
| COMPUTED_BY_ALGORITHM_VERSION | DiagnosticResult -> AlgorithmVersion | structural | see contract | recommended Structural | V-303r, V-316 |
| INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION | DiagnosticResult -> ReferenceIntervalVersion | structural | many | recommended Structural | V-306 |
| COMPARED_TO | DiagnosticResult -> DiagnosticResult | derived (derivationRule + derivedFromAssessmentUids, or rule-only for same version: W07-SR-10) | many | DerivedEdgeProperties (field on W16 Observation) | V-302r, V-304r, V-312, V-112 |
| HAS_REFERENCE_RANGE | Biomarker/Metric -> ReferenceRange | derived | many | DerivedEdgeProperties | V-305a |
| SAME_TEST_AS | LabTest -> LabTest | derived (projectionOfAssertionUid) | many | DerivedEdgeProperties | V-307, V-315 |
| MEASURES (legacy) | LabTest -> Biomarker | derived (rule MEASURES_METRIC + QUANTIFIES) | many | DerivedEdgeProperties | — |
| INCLUDES_BIOMARKER (legacy) | PanelDefinition -> Biomarker | derived | many | DerivedEdgeProperties | — |

## Relationship-property type

**MeasurementEdgeProperties** — specializes AssertedEdgeProperties (all frozen fields, same nullability) + live qualifiers kept as verbatim extraction text (role, method, methodRole, unit, sampleType, referenceRangeText, notes) and device descriptors (signalType, samplingRateHz, rangeMin, rangeMax, accuracy). Qualifiers are never authoritative. Used on MEASURES_METRIC by LabTest and, by name, by W08 Device/Sensor. Successor of live MeasurementMetadata (migration-map.yaml).

## Union

**ComparableVersionTarget** = AssayVersion | AlgorithmVersion | ReferenceIntervalVersion (renames proposed-delta `ComparableVersion`).

## Enums (W07 owner; values frozen at catalog)

| Enum | Values | Catalog key |
|---|---|---|
| DiagnosticResultKind | MEASURED, CALCULATED, INFERRED | resultKind |
| AlgorithmOutputKind | AGE_ESTIMATE, PACE, RISK_SCORE, FEATURE_MEASURE, CLASSIFICATION, CALCULATED_QUANTITY | algorithmOutputKind |
| AlgorithmVersionBasis | VENDOR_VERSION_STRING, PUBLICATION_VERSION, SERVICE_ENDPOINT_UNVERSIONED, UNKNOWN | algorithmVersionBasis |
| ReferenceIntervalKind | REFERENCE_INTERVAL, DECISION_LIMIT, GUIDELINE_TARGET | referenceIntervalKind |
| ReferenceIntervalDerivation | ESTABLISHED, TRANSFERRED, VERIFIED, ADOPTED_FROM_MANUFACTURER, NOT_REPORTED (candidate ADOPTED_FROM_GUIDELINE: W07-SR-06) | referenceIntervalDerivation |
| ComparabilityVerdict | COMPARABLE, COMPARABLE_WITH_CONVERSION, NOT_COMPARABLE, UNKNOWN | comparabilityVerdict |
| ResultQualifier | NUMERIC, BELOW_DETECTION, ABOVE_QUANTIFICATION, NOT_MEASURED, INVALID_SPECIMEN (candidate NOT_REPORTED) | private_context.resultQualifier (ownership requested: W07-SR-03) |

`ReportedStatus` is used here but owned by W00 (kernel, contract B5).

## Candidate predicate (not registered)

`CHANGED_BETWEEN` (predicateClass QUANTITY): subject later DiagnosticResult, object earlier DiagnosticResult, no literal (INV-003). Records a source's statement that a value changed. basisKind DIRECT_MEASUREMENT only when both results are MEASURED and, for a shared AlgorithmVersion, an assessment cites a replicateNoiseBasis (V-314). Registration requested (W07-SR-13).
