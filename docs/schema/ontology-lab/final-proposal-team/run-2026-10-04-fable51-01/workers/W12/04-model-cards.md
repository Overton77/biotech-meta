# W12 model cards

Conventions for every node card (not repeated): kernel fields `id` (opaque segment of `uid`), `uid` (`hu:<token>:<opaque>`), `name` (presentation only), `description`, `mongoResearchRunId` (internal lineage), `createdAt`/`updatedAt` (operational `@timestamp`; Cypher ingestion must write both, see 07-operations.md), `privacyClass` (PUBLIC for every W12 type; no W12 element is INTERNAL or private), `maturity`, `schemaVersion`, plus the archetype interface fields. Kind codes: **A** asserted (from a source through an Assertion), **O** observed (copied verbatim from a captured artifact), **C** calculated, **I** inferred, **Op** operational. Temporal codes: **imm** immutable after commit; **st** source-stated date with precision; **ep** carried by a bitemporal episode edge. Maturity: everything in the fragment is PROVISIONAL (catalog module provisional); items marked CANDIDATE are excluded from the fragment.

The relationship-property types used (`AssertedEdgeProperties`, `StateEpisodeProperties`, `DerivedEdgeProperties`, `StructuralEdgeProperties`) are W00's frozen types (contract B4); W12 defines no relationship-property type.

## Node cards

### ProductLot (Entity; labels `["ProductLot","Entity"]`; token `lot`, proposed W12-SR-01)
Meaning: a production lot of one product variant as identified by its issuer. Not a package, unit, inventory item or certification; "expired" and "recalled" are not properties.
| Property | Type | Null | Units / value-state | Kind | Temporal |
|---|---|---|---|---|---|
| entityType | String! | no | "PRODUCT_LOT" | Op | imm |
| lotCode | String! | no | printed code, case and punctuation preserved | O | imm |
| manufactureDate / manufactureDatePrecision | DateTime / TimePrecision | yes | first instant of period; null = not stated | O | st |
| expiryDate / expiryDatePrecision | DateTime / TimePrecision | yes | "Exp. 12/2027" → 2027-12-01, MONTH; null = not stated | O | st |
| dateTextVerbatim | String | yes | verbatim date text | O | imm |
Edges: `LOT_OF` → ProductVariant (A, exactly_one); `MANUFACTURED_UNDER` → FormulationVersion / SpecificationVersion (A, zero_or_one each); inverse `SAMPLE_FROM`; `CERTIFIED_UNDER` → CertificationListing (derived, read-only). Identity keys: (`LOT_OF` variant, issuer, lotCode); materialized `lotCode` is indexed but **not unique** (07-operations.md). Aliases: none; an `Identifier{scheme: LOT_CODE, issuer: brand}` record may be attached through W00 `HAS_IDENTIFIER`. Sources: S1, S3, S4–S6. CQs: CQ-PF-03, CQ-AX-19, CQ-QA-C02, CQ-QA-C04.

### TestSample (Entity; `["TestSample","Entity"]`; token `test-sample`)
Meaning: the physical sample tested. Not the lot, unit or test.
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| sampleCode | String | yes | lab registration number (WHO 19.1(a)) | O |
| sampledAt / sampledAtPrecision | DateTime / TimePrecision | yes | st | O |
| samplingMethod | String | yes | verbatim acquisition text | O |
Edges: `SAMPLE_FROM` → ProductLot \| IndividualUnit \| IngredientMaterial (A, exactly_one across the three fields; V-W12-08). CQs: CQ-AX-19, CQ-QA-C02.

### TestExecution (Occurrence; `["TestExecution","Occurrence"]`; token `test-execution`)
Meaning: one performance of one test row on one sample. Not the method, result, COA or certification.
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| occurrenceType, startedAt, endedAt | archetype | | startedAt/endedAt usually unknown | Op/O |
| executedAt / executedAtPrecision | DateTime / TimePrecision | yes | completion date when stated; a report date is NOT an execution date | O |
| testNameVerbatim | String | yes | "Potency", "Microbial*" | O |
| status | TestExecutionStatus | yes | INVALIDATED results never feed interpretations | A |
| testPurpose | TestPurpose | yes | RELEASE / STABILITY / … / NOT_STATED | O/I |
| accreditationScopeStatus | AccreditationScopeStatus | yes | from "†" marks | O |
| subcontracted | Boolean | yes | from "*" marks; null = not stated | O |
| performerStatementVerbatim | String | yes | when no lab identity is given | O |
Edges: `TESTED_SAMPLE` → TestSample (structural, exactly_one); `USED_METHOD` → TestMethod (A, zero_or_one); `PERFORMED_BY_LAB` → TestingLaboratory (A, zero_or_one; absent = not stated); `PRODUCED_RESULT` → MeasuredResult (structural, many). CQs: CQ-QA-C01, CQ-QA-C03, CQ-AX-19.

### TestMethod (Entity; `["TestMethod","Entity"]`; token `test-method`)
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| methodIdentifier | String | yes | "USP <2022>", "NSF 306", lab method id | O |
| methodVersion | String | yes | edition / revision | O |
| techniqueVerbatim | String | yes | "HPLC", "ICP-MS" | O |
Identity: methodIdentifier + methodVersion when present; a technique-only method is a weak identity (one node per source phrase). Not W07 `AssayVersion`, not W08 instrument. CQs: CQ-QA-C01, pair 11.

### TestingLaboratory (Entity; `["TestingLaboratory","Organization","Entity"]`; token `org` (registered))
Meaning: an Organization that performs or reports tests (W01 owns the Organization identity and roles). `accreditation` (String, O) = verbatim self-statement, never verification. Edges (inverse views): `PERFORMED_BY_LAB`, `COA_ISSUED_BY`; covered by `COVERS` from a LABORATORY programme scope. Independence = absence of W01 affiliation assertions to the brand owner as of a date; never a stored flag. CQs: CQ-AX-19, CQ-QA-C01.

### MeasuredResult (InformationArtifact; `["MeasuredResult","InformationArtifact"]`; token `measured-result`)
Meaning: one reported analytical outcome for one analyte from one execution, bound to its source locator. Never a declaration, verdict or value invented from a verdict.
| Property | Type | Null | Units / value-state | Kind |
|---|---|---|---|---|
| analyte | String! | no | as named by source | O |
| analyteUid | String | yes | pointer to substance/constituent/taxon uid; null = unresolved | A (resolution) |
| value | Float | yes | non-null iff qualifier NUMERIC | O |
| valueTextVerbatim | String | yes | "☑ 555 mg/capsule", "ND" | O |
| unitCode | String | yes | UCUM with annotations (mg/{capsule}, mg/{serving}, [ppm], [CFU]/g) | O |
| uncertainty / uncertaintyKind / coverageFactor | Float / UncertaintyKind / Float | yes | null = not reported (never 0) | O |
| limitOfDetection / limitOfQuantitation / reportingLimit | Float | yes | in unitCode | O |
| reportingLimitText | String | yes | relative limits ("1% or less of label claim") | O |
| qualifier | ResultQualifier! (shared, W07) | no | INV-007 state; never NOT_MEASURED | O |
| sampleQuantity / sampleQuantityUnitCode | Float / String | yes | for qualitative tests | O |
| quantityBasis / massBasis / amountReferent | W00 enums | yes | per-serving, salt vs moiety, referent; needed for label comparison | O |
| artifactType, publishedAt, observedAt, contentHash | archetype | | publishedAt = report date | O |
Edges: inverse `PRODUCED_RESULT` (exactly_one, V-W12-03); `EVALUATED_AGAINST` → SpecificationCriterion (A, zero_or_one); `SUPPORTED_BY` → SourceLocator (structural, one_or_more; W12-SR-02). Temporal: immutable; a corrected report yields a new MeasuredResult on the revised snapshot; "current" = supporting snapshot not a PRIOR_SNAPSHOT of a recorded SourceRevisionEvent. CQs: CQ-AX-19, CQ-QA-C02, CQ-QA-C03, CQ-AX-04.

### SpecificationCriterion (VersionedState; `["SpecificationCriterion","VersionedState"]`; token `spec-criterion`)
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| stateType, payloadHash (sha256 over the criterion payload), effectiveFrom, effectiveTo | archetype | | | Op/O |
| analyte / analyteUid | String! / String | | | O / A |
| comparator | SpecComparator! | no | | O |
| threshold / upperThreshold / unitCode | Float / Float / String | yes | | O |
| targetValue | Float | yes | stated nominal; not a label claim | O |
| criterionText | String! | no | verbatim | O |
| criterionPurpose | CriterionPurpose! | no | NOT_STATED explicit | O |
| criterionBasis | CriterionBasis! | no | NOT_STATED explicit | O |
| sampleQuantity(+UnitCode), quantityBasis, massBasis, amountReferent | | yes | | O |
Edges: `CRITERION_OF_SPECIFICATION` → SpecificationVersion (structural, exactly_one; W11 type). Temporal: replaced, never edited (a new SpecificationVersion carries the new criterion). CQ-QA-C03; OQ P2-2.

### PassFailInterpretation (EvidenceAssessment; `["PassFailInterpretation","EvidenceAssessment"]`; token `pass-fail`)
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| assessmentType, methodVersion, status, recordedAt, recordedTo, summary, overallScore | archetype | | methodVersion: `w12-source-stated-verdict-capture/1` or `w12-pass-fail-evaluator/1[;rule]` | Op |
| confidence | Float | yes | deprecated kernel field; never written | — |
| verdict | PassFailVerdict! | no | | A (SOURCE_STATED) / C (EVALUATED) |
| verdictBasis | VerdictBasis! | no | | Op |
| verdictTextVerbatim | String | yes | | O |
| resultValueReported | ReportedStatus (W00) | yes | NOT_REPORTED = pass without value | O |
| decisionRule | String | required for EVALUATED | SIMPLE_ACCEPTANCE, GUARD_BAND_EXPANDED_U | Op |
| basisAssertionUid | String | required for SOURCE_STATED | uid of CONFORMS_TO_SPECIFICATION assertion | Op |
| rationale | String | yes | | C |
Edges: `INTERPRETS_RESULT` → MeasuredResult (structural; exactly one for EVALUATED, zero for SOURCE_STATED + NOT_REPORTED); `APPLIES_CRITERION` → SpecificationCriterion (structural, exactly_one; proposed); `INTERPRETS_TESTING_OF` → ProductLot \| TestExecution (structural, exactly_one; proposed); `SUPPORTED_BY` → SourceLocator (kernel; required for SOURCE_STATED). Temporal: immutable; corrections via kernel `SUPERSEDES {SOURCE_CORRECTION, sourceRevisionEventUid}`. Validators V-W12-05, -09, -11. CQs: CQ-QA-C02, CQ-QA-C03, pair 18.

### LotTestSummary (InformationArtifact; `["LotTestSummary","InformationArtifact"]`; token `lot-test-summary`)
Properties: `title` (O), `lotCodeVerbatim` (O), `attributionStatementVerbatim` (O), archetype fields (`observedAt` = capture). Edges: `SUMMARIZES_TESTING` → ProductLot / TestExecution (A); `SUPPORTED_BY` (W12-SR-02). Never relabeled as COA (V-W12-02). CQ-QA-C01, CQ-PF-03.

### CertificateOfAnalysis (InformationArtifact; `["CertificateOfAnalysis","InformationArtifact"]`; token `coa`)
| Property | Type | Null | Notes | Kind |
|---|---|---|---|---|
| certificateNumber | String | yes | one of number/date required (V-W12-01) | O |
| revisionNumber | String | yes | one node per revision | O |
| reportDate / reportDatePrecision | DateTime / TimePrecision | yes | | O st |
| documentTitleVerbatim | String | yes | never sufficient | O |
| signatureEvidence | SignatureEvidence! | no | NOT_CAPTURED ≠ unsigned | O |
| signer / signedAt | String / DateTime | yes | role or name as printed | O |
Edges: `CERTIFIES_RESULTS_FOR` → ProductLot / TestExecution (A); `COA_ISSUED_BY` → TestingLaboratory / Organization (A, exactly_one; proposed); `SUPPORTED_BY`. Validators V-008, V-W12-01, V-W12-09. CQ-QA-C01, CQ-AX-19.

### CertificationProgram (Entity; `["CertificationProgram","Entity"]`; token `cert-program`)
Properties: `standard` (O), `certifiedObjectKind` (CertifiedObjectKind!, O from certifier explainer). Edges: `PROGRAM_HAS_LISTING` → CertificationListing (structural). Operator: W01 `OPERATES_CERTIFICATION_PROGRAM` assertion. CQ-PF-03, CQ-MF-06.

### CertificationListing (VersionedState; `["CertificationListing","VersionedState"]`; token `cert-listing`)
Properties: `listingId` (O; certifier record id, e.g. "1786167"), `status` (CertificationListingStatus!, O), `effectiveFrom`/`effectiveTo` (O st; null = not stated), `listingCurrentAsOf` (O: certifier's currency instant), `listedOrganizationText` (O). Edges: `HAS_CERTIFICATION_SCOPE` → CertificationScope (structural, StateEpisodeProperties; ep); inverse `PROGRAM_HAS_LISTING` (exactly_one); inverse `CERTIFIED_UNDER`. V-009, V-W12-10. CQ-PF-03, CQ-QA-C04.

### CertificationScope (VersionedState; `["CertificationScope","VersionedState"]`; token `cert-scope`)
Properties: `scopeText` (String!, O), `coveredIdentifierValues` ([String!], O, source order), `facilityQualifierText` (O), `productFormText`, `servingSizeText`, `countryOfSaleText` (O). Edges: `COVERS` → CertificationCoverageTarget (A; one per resolved item); inverse `HAS_CERTIFICATION_SCOPE`. V-332, V-W12-06, V-W12-13. CQ-PF-03, CQ-QA-C04.

## Relationship cards

| Type | Domain → range | Direction | Class | Cardinality | Edge properties | Notes / validators |
|---|---|---|---|---|---|---|
| LOT_OF | ProductLot → ProductVariant | OUT | asserted | exactly_one | AssertedEdgeProperties | V-101 |
| MANUFACTURED_UNDER | ProductLot → FormulationVersion \| SpecificationVersion | OUT | asserted | zero_or_one per kind | AssertedEdgeProperties | a lab report asserting it is PROPOSED (not the spec owner) |
| SAMPLE_FROM | TestSample → ProductLot \| IndividualUnit \| IngredientMaterial | OUT | asserted | exactly_one overall | AssertedEdgeProperties | V-W12-08 |
| TESTED_SAMPLE | TestExecution → TestSample | OUT | structural | exactly_one | StructuralEdgeProperties | V-W12-08 |
| USED_METHOD | TestExecution → TestMethod | OUT | asserted | zero_or_one | AssertedEdgeProperties | V-W12-01 needs it for COA executions |
| PERFORMED_BY_LAB | TestExecution → TestingLaboratory | OUT | asserted | zero_or_one | AssertedEdgeProperties | absent = not stated; inferred in-house → PROPOSED |
| PRODUCED_RESULT | TestExecution → MeasuredResult | OUT | structural | result side exactly_one | StructuralEdgeProperties | V-W12-03 |
| EVALUATED_AGAINST | MeasuredResult → SpecificationCriterion | OUT | asserted | zero_or_one | AssertedEdgeProperties | criterion printed with the result |
| INTERPRETS_RESULT | PassFailInterpretation → MeasuredResult | OUT | structural | 0 or 1 by basis | StructuralEdgeProperties | V-W12-05 |
| APPLIES_CRITERION (proposed) | PassFailInterpretation → SpecificationCriterion | OUT | structural | exactly_one | StructuralEdgeProperties | V-W12-05 |
| INTERPRETS_TESTING_OF (proposed) | PassFailInterpretation → ProductLot \| TestExecution | OUT | structural | exactly_one | StructuralEdgeProperties | V-W12-05, V-W12-09 |
| CRITERION_OF_SPECIFICATION (proposed) | SpecificationCriterion → SpecificationVersion | OUT | structural | exactly_one | StructuralEdgeProperties | D-009 / CL-010 |
| SUMMARIZES_TESTING | LotTestSummary → ProductLot \| TestExecution | OUT | asserted | one_or_more | AssertedEdgeProperties | |
| CERTIFIES_RESULTS_FOR | CertificateOfAnalysis → ProductLot \| TestExecution | OUT | asserted | one_or_more | AssertedEdgeProperties | V-008, V-W12-01, V-W12-09 |
| COA_ISSUED_BY (proposed) | CertificateOfAnalysis → TestingLaboratory \| Organization | OUT | asserted | exactly_one | AssertedEdgeProperties | V-W12-01; add to `$assertedTypes` |
| PROGRAM_HAS_LISTING | CertificationProgram → CertificationListing | OUT | structural | listing side exactly_one | StructuralEdgeProperties | |
| HAS_CERTIFICATION_SCOPE | CertificationListing → CertificationScope | OUT | structural (bitemporal attachment) | one_or_more per episode | StateEpisodeProperties | V-W12-10; recordedTo written once |
| COVERS | CertificationScope → CertificationCoverageTarget | OUT | asserted | one_or_more | AssertedEdgeProperties | V-332, V-W12-06 |
| CERTIFIED_UNDER | Product \| ProductVariant \| ProductLot → CertificationListing | OUT | derived (`w12-certified-under/v1:DIRECT_SCOPE_COVERAGE`, inputs = COVERS assertion uids) | many | DerivedEdgeProperties | read-only; V-332, V-W12-07, V-112 |
| SUPPORTED_BY (W00) | MeasuredResult \| LotTestSummary \| CertificateOfAnalysis \| PassFailInterpretation → SourceLocator | OUT | structural | one_or_more | StructuralEdgeProperties | W12-SR-02 for the three artifacts |

Derived rule `w12-certified-under/v1`: for each ACCEPTED `COVERS` assertion whose subject is a CertificationScope attached to listing L by a currently recorded `HAS_CERTIFICATION_SCOPE` episode, and whose object X is a Product, ProductVariant or ProductLot, write `(X)-[:CERTIFIED_UNDER {derivationRule, derivedFromAssertionUids: [that assertion], derivedAt}]->(L)`; never from a FACILITY or LABORATORY programme; never from a covered lot to its variant or product, nor from a variant to its lots. Regenerable from assertions alone.

Forbidden implications proposed for the `quality` module (catalog lists none; W12-SR-07): `[FACILITY_GMP_CERTIFIED, CERTIFIED_UNDER]`, `[LOT_COVERED, PRODUCT_CERTIFIED]`, `[CONFORMS_TO_SPECIFICATION, MEASURED_VALUE]`, `[LOT_TEST_SUMMARY, CERTIFICATE_OF_ANALYSIS]`, `[CLAIMS_THIRD_PARTY_TESTING, INDEPENDENT_LABORATORY]`, `[LISTING_ABSENT_IN_LATER_CAPTURE, LISTING_WITHDRAWN]`, `[SIMILAR_LOT_CODE, SAME_LOT]` (instance of the identity rule). Each has a negative fixture (06-fixtures-and-queries.md).

## Union card

`CertificationCoverageTarget = Product | ProductVariant | ProductLot | Facility | TradeItemIdentifier | TestingLaboratory | AssayVersion` (owner W12). Members from W04 (Product, ProductVariant), W01 (Facility), W00 (TradeItemIdentifier), W07 (AssayVersion, accepted from W07-SR-16 with NGSP S15), W12. CANDIDATE member: IngredientMaterial (NSF 173DI, S13). An NGSP-certified laboratory is covered as a TestingLaboratory (W07 asked for 'the performing Organization'; a bare Organization member is refused because it would let any organization-level badge read as certification). Coverage of one member never implies another.

## Enum cards (all PROPOSED, owner W12; fixture use per value)

| Enum | Values (fixture use) |
|---|---|
| ResultQualifier (shared catalog enum, **not owned by W12**; writer W07 per W07-SR-03) | NUMERIC (555 mg; 263/236 mg; 258 mg; 261 mg); BELOW_DETECTION (70579 E. coli < 10 CFU/g); ABOVE_QUANTIFICATION, INVALID_SPECIMEN (allowed, no fixture); NOT_MEASURED (forbidden on a MeasuredResult, N19 → V-W12-04). Requested additions W12-SR-12: QUALITATIVE_ABSENT (P098-01 E. coli in 10 g), QUALITATIVE_PRESENT (symmetry), BELOW_REPORTING_LIMIT (S9 "BRL", distinct from ND) |
| UncertaintyKind | EXPANDED (Lab Z, k = 2); STANDARD (no fixture) |
| SpecComparator | NOT_LESS_THAN (NLT 500, ≥ 250), NOT_MORE_THAN (NMT 0.5 ppm), ABSENT_IN (Absent/10g), CONFORMS_TO_DESCRIPTION (NSF 306 "Pass"), REFERENCE_ONLY ("ICH/USP guidelines"), RANGE ("828 mg/capsule ±10%" in S1, not modeled as a node) |
| CriterionPurpose | RELEASE, SHELF_LIFE (synthetic stability spec), RELEASE_AND_SHELF_LIFE (Lab Z), NOT_STATED (real COA and Elysium); IN_PROCESS (adopted from W11-SR-03; no W12 fixture) |
| CriterionBasis | INTERNAL (Elysium), PHARMACOPEIAL (Lab Z E. coli), CERTIFICATION_PROGRAM (NSF 306 row), NOT_STATED (real COA); REGULATORY (no fixture) |
| PassFailVerdict | CONFORMS, DOES_NOT_CONFORM (rev 01), INDETERMINATE (guard band); NOT_EVALUABLE (documented in V-W12-11; no fixture node) |
| VerdictBasis | SOURCE_STATED, EVALUATED_FROM_RESULT |
| TestPurpose | NOT_STATED (real COA), SURVEILLANCE (Lab Z, survey), STABILITY (70064 m18); RELEASE, CERTIFICATION, INVESTIGATION (no fixture) |
| TestExecutionStatus | COMPLETED; INVALIDATED, NOT_STATED (no fixture; FDA OOS guidance motivates INVALIDATED) |
| AccreditationScopeStatus | OUTSIDE_SCOPE (NSF 306 row "†"), WITHIN_SCOPE (Lab Z), NOT_STATED (subcontracted rows) |
| SignatureEvidence | NOT_CAPTURED (real COA), SIGNATURE_PRESENT (Lab Z), ELECTRONIC_APPROVAL_STATEMENT (Lab Z 0415), NONE_IN_COMPLETE_CAPTURE (negative N06) |
| CertificationListingStatus | LISTED; SUSPENDED, WITHDRAWN, EXPIRED (certifier-stated states; no fixture) |
| CertifiedObjectKind | LOT (NSF 306), FACILITY (455-2), LABORATORY (17025); PRODUCT (NSF 173), INGREDIENT_MATERIAL (173DI) from S13 (no fixture listing); ASSAY_VERSION (NGSP, W07-SR-16; fixture in W07's packet) |

Values without a fixture node are kept because the source vocabulary names them and removing them would force a later enum change; Fable may trim them to fixture-backed values only (decision D-W12-09).

## CANDIDATE elements (not in the fragment)

| Candidate | Why not now |
|---|---|
| `LOT_PRODUCED_AT` ProductLot → Facility (asserted) | NSF facility groupings state where lots were made; no CQ yet needs a traversal (kept as `facilityQualifierText`). |
| Inspection Occurrence (`RegulatoryInspection`, W13) | CQ-MF-06 marks inspections expansion. |
| `COVERS IngredientMaterial` | no fixture (S13). |
| `LabelConformityAssessment` (measured vs declared as a stored assessment) | CQ-AX-19 is answered by query; storing the comparison needs W10 method ownership. |
| Material lot (`IngredientMaterialLot`) for live `Material.traceabilityCode` | no CQ; W02/W11 seam. |
