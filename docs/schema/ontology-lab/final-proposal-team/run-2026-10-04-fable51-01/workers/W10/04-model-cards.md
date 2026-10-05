# W10 04 Model cards

Conventions for every W10 node unless stated: privacy class PUBLIC (the type never holds personal data; `privacyClass` may be INTERNAL for unpublished drafts); kernel fields `id`, `uid`, `name`, `description`, `mongoResearchRunId` (INTERNAL lineage), `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion` per contract B2; archetype fields per `EvidenceAssessmentArchetype` (`assessmentType`, `methodVersion` required; `status` = workflow state, never the verdict; `recordedAt` service-assigned, never backdated and never earlier than any cited snapshot's `retrievedAt` (W10-V16b); `recordedTo` written once when superseded; `summary`; `overallScore`; deprecated `confidence` never written). Temporal behaviour: **immutable after commit** except `status` and the single `recordedTo` write; a change of judgement is a new node `SUPERSEDES {supersessionKind, recordedAt}` the old (KCR-2a). Kind: **inferred** (BellLabs judgement) unless a field says otherwise. Every W10 node may carry `WAS_GENERATED_BY → Activity` (method run) and `ASSESSED_BY → Agent | Person` (W00 relationships). Maturity: PROVISIONAL (catalog module maturity) unless marked CANDIDATE.

## Node cards

### EvidenceApplicability (uid token `applicability`; labels `EvidenceApplicability`, `EvidenceAssessment`)

Meaning: method-versioned judgement of whether ONE evidence target transfers to ONE use target. Only path from study evidence to a commercial identity (INV-201).

| Field | Type | Null | Semantics | Kind |
|---|---|---|---|---|
| `identityMatch`, `doseMatch`, `routeMatch`, `scheduleMatch`, `durationMatch`, `populationMatch`, `outcomeMatch` | `ApplicabilityVerdict` | yes | DERIVED projection of the dimension node verdict (rule `flat_projection` in `gen_w10.py`: head of the dimension of that kind); null = no such dimension; read-only in GraphQL | calculated |
| `overallScore` | Float | yes (null now) | composite; only under a calibrated composite method with every required dimension assessed (W10-V05) | calculated |
| `summary` | String | yes | names the weakest dimension | inferred |

| Edge | Direction / range | Class | Cardinality | Properties |
|---|---|---|---|---|
| `HAS_EVIDENCE_TARGET` | → `EvidenceTargetTarget` (StudyIntervention, Assertion) | structural | exactly_one (V-203) | — |
| `ASSESSES_APPLICABILITY_TO` | → `ApplicabilityUseTarget` | structural | exactly_one (V-203); never UserContext (V-524) | — |
| `FOR_USE_CONTEXT` | → `UseContextProfile` | structural | zero_or_one | — |
| `BASED_ON_EVIDENCE` | → Study, StudyResult, Publication, Assertion (four typed fields) | structural | many; ≥1 human exposure StudyResult when EXPOSURE is MATCH/PARTIAL (V-237) | — |
| `HAS_DIMENSION` | → `ApplicabilityDimension` | structural | one per required dimension (V-204, V-205); each dimension has one parent (W10-V01) | — |
| `SUPPORTED_BY` (W00) | → SourceLocator | structural | many | — |
| `SUPERSEDES` (W00) | → EvidenceApplicability (same evidence and use target, W10-V07) | structural | zero_or_one | `SupersessionProperties` |

Identity: uid only; two assessments of the same pair under different methods are distinct nodes. Required dimension sets: StudyIntervention target → MATERIAL_IDENTITY, ACTIVE_COMPOSITION, DOSE, DOSAGE_FORM, ROUTE, SCHEDULE, DURATION, POPULATION, COMPARATOR, OUTCOME_RELEVANCE, STUDY_DESIGN_AND_QUALITY; mechanism Assertion target → MATERIAL_IDENTITY, EXPOSURE, ROUTE, DURATION, POPULATION, OUTCOME_RELEVANCE, STUDY_DESIGN_AND_QUALITY. Sources: round 0002 R2/R4, round 0003 M4, round 0008. Maturity PROVISIONAL.

### ApplicabilityDimension (uid token `applicability-dimension`; labels `ApplicabilityDimension`, `EvidenceAssessment`)

| Field | Type | Null | Units / semantics | Kind |
|---|---|---|---|---|
| `dimension` | `ApplicabilityDimensionKind` | no | which dimension | operational |
| `dimensionClass` | `DimensionClass` | no | fixed by dimension (W10-V02) | operational |
| `verdict` | `ApplicabilityVerdict` | no | NOT_ASSESSED explicit; UNKNOWN needs `missingFacts` (V-209) | inferred |
| `identityLevel` | `MaterialIdentityLevel` | yes | MATERIAL_IDENTITY only; verdict mapping V-208b; same material node required at branded level or higher (V-208) | inferred |
| `evidenceCategory`, `targetCategory` | String | yes | dimension vocabulary (below), method-owned | observed (copied) |
| `evidenceValue`, `targetValue` | Float | yes | copied amounts; targetValue normalized by the FOR_USE_CONTEXT profile (servings/day × per-serving amount) | observed / calculated |
| `unitCode` | String (UCUM) | yes | one unit for both values (`mg/d`, `mg`, `/d`, `d`) | — |
| `evidenceQuantityBasis`, `targetQuantityBasis` | `QuantityBasis` | yes | null = unknown → ratio null | observed |
| `evidenceMassBasis`, `targetMassBasis` | `MassBasis` | yes | DOSE/EXPOSURE; UNSPECIFIED blocks the ratio | observed |
| `ratio` | Float | yes | target/evidence only when both quantity bases equal, both mass bases equal and not UNSPECIFIED (when present), same unit (V-206, W10-V03); otherwise null | calculated |
| `missingFacts` | [String!] | empty allowed | specific facts; non-empty when UNKNOWN | inferred |
| `rationale` | String | required for EXPLANATION_ONLY (V-207) | — | inferred |

Edges: `HAS_DIMENSION` (inverse, exactly one parent); `CONSIDERS` → Assertion (structural, many; e.g. contested supplier assertions, CALCULATED unit conversions per INV-307, W05 per-unit composition assertions); `CONSIDERS_ASSESSMENT` (W00) → EndpointClassification / EvidenceStrengthAssessment / ResolutionHypothesis (W10-V16; kernel domain extension W10-SR-04); `SUPPORTED_BY` → SourceLocator.

**Dimension vocabularies (method `applicability-v0.2-candidate`, kept in `evidenceCategory`/`targetCategory`, not enums because they are method-versioned):** ACTIVE_COMPOSITION `SAME_ACTIVES | EVIDENCE_SUBSET_OF_TARGET | TARGET_SUBSET_OF_EVIDENCE | DIFFERENT_ACTIVES`; DOSAGE_FORM and ROUTE: the W09/W04 dosage-form and route codes (`CAPSULE`, `SOFTGEL`, `ORAL` …); POPULATION `SAME | OVERLAPS | DISJOINT | UNKNOWN` (evidence side) with a target descriptor; COMPARATOR `PLACEBO | ACTIVE | NO_TREATMENT | HISTORICAL | NONE`; OUTCOME_RELEVANCE = the cited `EndpointClassification.endpointClass`; SCHEDULE timing codes (`ONCE_DAILY_WITH_BREAKFAST` …); DURATION target `OPEN_ENDED` when the use has no end.

**Verdict rules (no bands):** categorical as round 0002 R4; continuous: ratio computable and exactly 1.0 → MATCH allowed; ratio computable and ≠ 1.0 → PARTIAL or MISMATCH by rationale, never MATCH until a calibrated method is listed (W10-V04); ratio not computable → at most PARTIAL (INV-203), UNKNOWN when a side's value is missing. EXPOSURE (round 0003 M4, W03-SR-11 mapping): `ExposureBasis.ABSOLUTE_PER_DAY ↔ QuantityBasis.PER_DAY`; `PER_KG_BODY_WEIGHT_PER_DAY ↔ PER_KG_BODY_WEIGHT_PER_DAY`; `SINGLE_DOSE ↔ SINGLE_DOSE` only when both are absolute or both per-kg; `MEDIUM_CONCENTRATION`, `DIET_CONCENTRATION` never ratio against a product amount; a derived HED is never human exposure evidence; MATCH/PARTIAL needs a linked human exposure StudyResult for the target material and form. MATERIAL_IDENTITY inputs (W02-SR-09 adopted): a moiety-only statement on one side gives `SAME_SUBSTANCE_MATERIAL_UNRESOLVED` (UNKNOWN), not `SAME_SUBSTANCE_DIFFERENT_FORM`; `SAME_BRANDED_MATERIAL_SAME_SPEC` needs exactly one governing SpecificationVersion at the evidence date. Maturity PROVISIONAL.

### UseContextProfile (uid token `use-profile`; labels `UseContextProfile`, `Entity`; archetype Entity)

Meaning: a non-personal, assumed use (population, dose, duration) that an applicability assessment normalizes the target to. Fields: `entityType` (always 'UseContextProfile'), `populationDescriptor`, `doseDescriptor`, `durationDescriptor` (catalog, String, nullable), CANDIDATE `servingsPerDay: Float` (null = not stated → ratio stays null), CANDIDATE `intendedDurationIso: String` (ISO 8601; null = open-ended or unknown, the descriptor says which). Kind: asserted-by-BellLabs descriptor (operational), restating label directions when it does (the dimension cites the label locator). Edges: `FOR_USE_CONTEXT` (inverse); also a possible `ASSESSES_APPLICABILITY_TO` target (a use without a product, e.g. "1 g/day NR in adults over 65"). Privacy: no person-level key may be stored (W10-V14 allow-list in `fixtures/w10-params.json`); no private uid values (V-521). Identity: uid; two profiles with equal descriptors are not merged automatically (they may differ by intent). Candidate CQ CQ-EV-C01. Maturity: catalog fields PROVISIONAL, two new fields CANDIDATE.

### EndpointClassification (uid token `endpoint-classification`)

| Field | Type | Null | Semantics |
|---|---|---|---|
| `endpointClass` | `EndpointClass` | no | role in the inference |
| `biomarkerCategory` | `BiomarkerCategory` | yes | BEST category in this use; null when not a biomarker |
| `surrogateValidationLevel` | `SurrogateValidationLevel` | yes | required for SURROGATE_ENDPOINT (V-214) and set to NOT_ESTABLISHED for BIOMARKER_NOT_SURROGATE; null for clinical outcomes (deviation from the card, which said non-null: a level for a clinical outcome is meaningless) |
| `contextDiseaseOrUse`, `contextPopulation`, `contextInterventionMechanism` | String | yes | FDA table columns; required for SURROGATE_ENDPOINT (V-214) |
| `contextApprovalType` | String | yes | controlled `TRADITIONAL` \| `ACCELERATED` (FDA column "Type of Approval Appropriate for"); candidate enum later |
| `contextMatch` | `ContextOfUseMatch` (CANDIDATE) | yes | study-specific classification vs the nearest context |
| `rationale` | String | yes | — |

Edges: `CLASSIFIES_OUTCOME` → OutcomeDefinition (study-specific, zero_or_one); `CLASSIFIES_BIOMARKER` → Biomarker (general context-of-use classification, zero_or_one); `COMPARED_WITH_CONTEXT` → EndpointClassification (many); `SUPPORTED_BY` (≥1 for SURROGATE_ENDPOINT). Rule W10-V08: a study-specific VALIDATED/REASONABLY_LIKELY needs contextMatch FULL and a compared context with the same level. Derived: "patient-important" = CLINICAL_OUTCOME, or INTERMEDIATE_CLINICAL_ENDPOINT measuring feel/function/survival (Q06 computes it; never stored). Sources: S1–S3. Maturity PROVISIONAL.

### ResultInterpretation (uid token `assessment`; `result-interpretation` requested)

Fields: `interpretation: ResultInterpretationKind!`; `meaningfulnessVerdict: MeaningfulnessVerdict` (CANDIDATE enum; null = not assessed; UNDETERMINED when no threshold); `thresholdValue: Float`, `thresholdUnit: String` (UCUM; catalog name kept), `rationale` (names MCID vs NI/equivalence margin). Edges: `INTERPRETS_RESULT_OF` → StudyResult (exactly_one, W10-V10); `USES_THRESHOLD_SOURCE` → SourceLocator (required when a threshold or EVIDENCE_OF_NO_MEANINGFUL_EFFECT is used, W10-V09). Replaces `OutcomeResult.isClinicallyMeaningful` with the author Assertion `RESULT_CLINICALLY_MEANINGFUL`. Maturity PROVISIONAL.

### EvidenceSynthesis (uid token `synthesis`)

Fields: `claimText` (display copy), `verdict: AdjudicationVerdict!` (kernel enum reused), `evidenceCutoff: Date` (latest publication date considered; domain clock), `rationale`. Edges: `ASSESSES_CLAIM` → Assertion | Claim (two typed fields; exactly one target overall); `INCLUDES_RESULT` → `SynthesisInputTarget` with `SynthesisInputProperties.inputRole`; `TRIGGERED_BY` → StudyResult | Publication | RegistrationVersion | Assertion (typed fields) with `EvidenceChangeProperties`; `SUPERSEDES` (same claim, forward in recorded time; V-219, W10-V13); `ASSESSES_STRENGTH_OF` (inverse). Rules: V-215, V-216, V-218, V-219, V-219b, V-219c, W10-V11, W10-V11b, W10-V12.

**Synthesis method `synthesis-v0.1` criterion codes** (the `criterionCode` vocabulary; method-owned, extended only by a new method version): `NEW_RANDOMIZED_PRIMARY_RESULT`, `HUMAN_DIRECT_MEASUREMENT_NULL`, `CORRECTION_OR_RETRACTION`, `REGISTRY_RESULTS_POSTED`, `OUTCOME_PRIORITY_DISCREPANCY` (round 0002), `SYSTEMATIC_REVIEW_UPDATE`, `POOLED_ESTIMATE_CI_INCLUDES_NULL` (W10, fixture 05). Input-role rules: INV-206 (V-215, W10-V11) plus method rule W10-V11b (post hoc/exploratory after a null primary → HYPOTHESIS_GENERATING only); a pooled-review subgroup with a null pooled primary is also HYPOTHESIS_GENERATING (fixture 05, by analogy; no validator yet). Maturity PROVISIONAL.

### EvidenceStrengthAssessment (uid token `assessment`; `strength-assessment` requested)

Fields: `scheme: String!` (GRADE, OCEBM-2011, LEGACY_UNSPECIFIED), `level: String!` (scheme vocabulary), `criteria: [String!]` (required except GRADE-as-reported and LEGACY, W10-V15), `rationale`. Edges: `ASSESSES_STRENGTH_OF` → Study | StudyResult | EvidenceSynthesis (typed fields, exactly one). Migration of live hints: `{scheme: LEGACY_UNSPECIFIED, level: <LOW|MODERATE|HIGH>, methodVersion: legacy-unspecified, status: PROPOSED}`. A level copied from authors (fixture 05) uses a method naming the copy rule (`grade-as-reported-by-review-v0`) and the author's locator. Maturity PROVISIONAL.

## Relationship-property cards

| Type | Fields | Used by | Notes |
|---|---|---|---|
| `SynthesisInputProperties` | `inputRole: SynthesisInputRole!` | `INCLUDES_RESULT` | immutable per version; replaces delta `SynthesisInputMetadata` (String) |
| `EvidenceChangeProperties` | `criterionCode: String!`, `effectOnVerdict: EvidenceChangeEffect!`, `evidencePublishedAt: Date` (null = unknown) | `TRIGGERED_BY` | replaces delta `EvidenceChangeMetadata`; index on `evidencePublishedAt` |

Structural W10 edges carry no properties (structural class; no Assertion). `SUPERSEDES` uses W00 `SupersessionProperties`.

## Enum cards (all W10-owned; values = catalog `conventions` unless CANDIDATE)

| Enum | Values | Source / note |
|---|---|---|
| `ApplicabilityVerdict` | MATCH, PARTIAL, MISMATCH, UNKNOWN, NOT_ASSESSED, NOT_APPLICABLE, NOT_SCORED | catalog |
| `ApplicabilityDimensionKind` | 14 values (catalog `applicabilityDimension`) | catalog; EXPOSURE per round 0003 |
| `DimensionClass` | CATEGORICAL, CONTINUOUS, EXPLANATION_ONLY | catalog |
| `MaterialIdentityLevel` | 10 ordered values | catalog |
| `EndpointClass` | BIOMARKER_NOT_SURROGATE, SURROGATE_ENDPOINT, INTERMEDIATE_CLINICAL_ENDPOINT, CLINICAL_OUTCOME | catalog; BEST terms |
| `BiomarkerCategory` | SUSCEPTIBILITY_RISK, DIAGNOSTIC, MONITORING, PROGNOSTIC, PREDICTIVE, PHARMACODYNAMIC_RESPONSE, SAFETY | catalog; confirmed S2 |
| `SurrogateValidationLevel` | VALIDATED, REASONABLY_LIKELY, CANDIDATE, NOT_ESTABLISHED | catalog; first three = BEST (S3); NOT_ESTABLISHED BellLabs |
| `ContextOfUseMatch` | FULL, PARTIAL, NONE | CANDIDATE (property card); W10-SR-03 |
| `ResultInterpretationKind` | EFFECT_DETECTED, INCONCLUSIVE, EVIDENCE_OF_NO_MEANINGFUL_EFFECT | catalog |
| `MeaningfulnessVerdict` | MEANINGFUL, NOT_MEANINGFUL, UNDETERMINED | CANDIDATE (property card) |
| `SynthesisInputRole` | CONFIRMATORY, SUPPORTIVE, HYPOTHESIS_GENERATING, CONTRADICTING, SAFETY, INDEPENDENT_REPLICATION | catalog |
| `EvidenceChangeEffect` | STRENGTHENED, WEAKENED, REVERSED, NO_CHANGE | catalog |
| `EvidenceStrength` | LOW, MODERATE, HIGH | live; legacy hint only |
| `EvidenceSynthesisVerdict` | — | NOT CREATED (AdjudicationVerdict reused) |

## Union cards

| Union | Members | Rule |
|---|---|---|
| `ApplicabilityUseTarget` | Product, ProductVariant, FormulationVersion, ProductLot, IngredientMaterial, UseContextProfile | never UserContext; IngredientMaterial covers its specializations |
| `EvidenceTargetTarget` | StudyIntervention, Assertion | Assertion must be predicateClass MECHANISM (INV-212) |
| `SynthesisInputTarget` | StudyResult, Assertion | StudyResult covers AdverseEventResult |

## Shared method contract for W21 `ClaimEvidenceAssessment` (D-W10-12)

1. It is an EvidenceAssessment with `methodVersion`, `status`, `recordedAt`; immutable; re-grade = new node `SUPERSEDES {RE_REVIEW}`.
2. Its relationship types are `ASSESSES_CLAIM_EVIDENCE` (→ Claim, exactly one) and `CLAIM_EVIDENCE_BASED_ON` (→ Assertion | Study | StudyResult | Publication); it never uses `ASSESSES_CLAIM`, which belongs to `EvidenceSynthesis` (one relationship type, one meaning).
3. `evidenceStrength` (`EvidenceStrength` enum) is meaningful only with `criteriaVersion` naming the grading criteria; migrated live values use `methodVersion: legacy-unspecified`, `status: PROPOSED` (same rule as W10-V15).
4. When a BellLabs `EvidenceSynthesis` exists for the same Claim, the ClaimEvidenceAssessment cites it (`CLAIM_EVIDENCE_BASED_ON` range extended to EvidenceSynthesis, or W00 `CONSIDERS_ASSESSMENT`), and its inputs obey INV-206 and V-218 exactly as `INCLUDES_RESULT` does; it never re-derives a verdict different from the synthesis without its own rationale.
5. It never sets an Assertion `status` and never writes a truth verdict on the Claim (contract A3/A4).

## Calibration (DEFERRED): what an expert-review set needs

No thresholds or bands are invented. A calibration set for `applicability-v1` must contain, per case: the evidence target and use target uids; the dimension verdicts and missing facts from at least two independent expert reviewers blind to each other (ReviewerType HUMAN, recorded as Adjudications over the dimension nodes); for continuous dimensions, the evidence and target values with both bases and the expert's categorical judgement, so bands can be fitted rather than chosen; agreement statistics per dimension; and coverage of at least the Basis (NRPT → Basis), NIAGEN (Conze → Tru Niagen; Conze → Basis) and Mitopure (ATLAS → Mitopure softgels) cases named in OPEN-QUESTIONS P1-2, plus one mechanism-target (EXPOSURE) case. Only a method listed in `$calibratedRatioMethods` / `$calibratedCompositeMethods` (empty today) may emit a non-identity MATCH or a composite.
