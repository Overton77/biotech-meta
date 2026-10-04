# W10 02 CQ coverage

Columns: CQ (priority, answerability in the CQ catalog) → example answer (from the executed fixtures) → distinction → evidence requirement → W10 element(s) → query → prevented failure. Query ids refer to `fixtures/w10-80-queries.cypher` (all **run**, results in `fixtures/run-results-2026-10-04.json`).

## Existing CQs

| CQ | Example answer (executed) | Distinction | Evidence | W10 elements | Query | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-EV-04 (Essential, Q) | "NRPT 1X → current Basis: weakest MATERIAL_IDENTITY UNKNOWN and STUDY_DESIGN_AND_QUALITY NOT_ASSESSED; DOSE PARTIAL (salt vs cation unstated); SCHEDULE MATCH; 13 dimension nodes" | dimension by dimension; UNKNOWN ≠ NOT_ASSESSED ≠ MISSING | paper Methods, label snapshot, resolution hypotheses | `EvidenceApplicability`, `ApplicabilityDimension`, `HAS_EVIDENCE_TARGET`, `ASSESSES_APPLICABILITY_TO`, `HAS_DIMENSION`, `FOR_USE_CONTEXT`, `BASED_ON_EVIDENCE`, enums `ApplicabilityVerdict`, `ApplicabilityDimensionKind`, `DimensionClass`, `MaterialIdentityLevel` | Q01 (QS-3a verbatim), Q04, Q15 | one score hiding the weakest dimension; Study→Product shortcut (V-201) |
| CQ-EV-06 (Essential, A) | DOSE: 'mass basis of "125 mg of NR" per capsule … not stated'; MATERIAL_IDENTITY: three supplier/spec facts | missing fact vs disputed fact | dimension `missingFacts` | `ApplicabilityDimension.missingFacts`, V-209 | Q02 | "more data needed" |
| CQ-RC-03 (Essential, Q) | MI weighs two UNRESOLVED hypotheses and a contested SUPPLIES_INGREDIENT_MATERIAL assertion; DOSE lists the salt fact | missing vs disputed vs not assessed | dims + `CONSIDERS` + `CONSIDERS_ASSESSMENT` | `CONSIDERS`, `CONSIDERS_ASSESSMENT` (W10-SR-04) | Q03 | a ranking presented as settled |
| CQ-EV-02 (Essential, A) | v3 verdict is an `EvidenceAssessment`; its inputs are `Assertion`s quoting the review | assertion vs assessment vs derived | archetype labels | all W10 nodes carry `EvidenceAssessment`; flat applicability fields are derived read-only | Q13 | a BellLabs verdict read as a source claim |
| CQ-ST-03 (Essential, Q) | NRPT LDL-C: BIOMARKER_NOT_SURROGATE / SAFETY / NOT_ESTABLISHED, contextMatch PARTIAL vs FDA hypercholesterolemia (VALIDATED, lipid-lowering); LDL-C also VALIDATED for LAL deficiency (enzyme); NADPARK PDRP primary = BIOMARKER_NOT_SURROGATE / PHARMACODYNAMIC_RESPONSE, MDS-UPDRS secondary = CLINICAL_OUTCOME | measured kind vs endpoint role vs context of use | FDA table row spans, BEST categories, registry outcomes | `EndpointClassification`, `CLASSIFIES_OUTCOME`, `CLASSIFIES_BIOMARKER`, `COMPARED_WITH_CONTEXT`, enums `EndpointClass`, `BiomarkerCategory`, `SurrogateValidationLevel`, `ContextOfUseMatch` | Q05, Q06 | surrogate status transferring across contexts (W10-V08, V-214b) |
| CQ-ST-05 (Essential, A) | ATLAS: primary power output NOT_SIGNIFICANT → CONFIRMATORY input, INCONCLUSIVE; hamstring between-arm secondary SUPPORTIVE; post hoc subgroup HYPOTHESIS_GENERATING; within-arm +12 % not an input | analysisKind, comparisonKind, not significant ≠ no effect | results with roles | `INCLUDES_RESULT {SynthesisInputProperties.inputRole}`, `ResultInterpretation`, enums `SynthesisInputRole`, `ResultInterpretationKind` | Q07 | a secondary or subgroup finding used as confirmatory (V-215, W10-V11, W10-V11b) |
| CQ-ST-09 (Essential, A) | published 2021-03-30 (WEAKENED, label SUPPORTED) and 2025-02-21 (WEAKENED, SUPPORTED → INSUFFICIENT, criterion POOLED_ESTIMATE_CI_INCLUDES_NULL); BellLabs recorded both on 2026-10-04 | publication date vs recorded date; verdict change vs strength change | triggering publications with locators | `EvidenceSynthesis`, `SUPERSEDES`, `TRIGGERED_BY {EvidenceChangeProperties}`, `EvidenceChangeEffect` | Q09 (domain clock), Q10 (system clock), Q12 (as-of R) | overwritten assessments; late evidence read as old knowledge |
| CQ-ST-10 (Expansion, Q) | authors: clinically meaningful (Assertion true, ACCEPTED capture); BellLabs: UNDETERMINED (no threshold source) | author claim vs BellLabs criterion vs neither | MCID/margin locator | `ResultInterpretation.meaningfulnessVerdict`, `thresholdValue`, `thresholdUnit`, `USES_THRESHOLD_SOURCE`, enum `MeaningfulnessVerdict` | Q08 | significance read as meaningfulness (W10-V09) |
| CQ-AX-24 (Essential, A) | current v3: INSUFFICIENT; strength GRADE "moderate" copied from the review, criterion "publication bias suspected", method grade-as-reported-by-review-v0 | hint vs assessment with criteria | strength statement locator | `EvidenceStrengthAssessment`, `ASSESSES_STRENGTH_OF`, legacy enum `EvidenceStrength` (hint only) | Q11 | "well-supported" as a node attribute (V-213b, W10-V15) |
| CQ-EV-03 (Foundational, Q) | inputs grouped by role: CONFIRMATORY / SUPPORTIVE / HYPOTHESIS_GENERATING / CONTRADICTING / SAFETY | support vs contradiction vs non-comparable | per-input role | `INCLUDES_RESULT`, `SynthesisInputTarget` | Q07, Q13 | every edge counted as support |
| CQ-EV-05 (Foundational, Q) | inherited and W10 re-assessments: v1 `recordedTo` = v2 `recordedAt`; synthesis criterion `CORRECTION_OR_RETRACTION` available | correction vs new evidence vs re-review | SUPERSEDES with kind | `SUPERSEDES {RE_REVIEW}` on W10 types, `TRIGGERED_BY` → `Publication` (corrections, retraction notices) | Q12, Q15 (superseded flag) | silent edits of assessments |
| CQ-AX-05 (Foundational, Q) | two INDEPENDENT_REPLICATION inputs sharing a study/dataset are rejected | replication vs reuse | dataset links (W09) | `SynthesisInputRole.INDEPENDENT_REPLICATION`, V-218 | V-218 (run, 0 rows) | "five studies agree" when they are one |
| CQ-AX-20 (Research frontier, X) / CQ-MX-04 (Essential, Q) | Elhassan muscle NAAD → Basis: EXPOSURE UNKNOWN, ratio null, no human exposure result linked | ingredient mechanism vs product exposure | human exposure StudyResult | `ApplicabilityDimension{EXPOSURE}`, `BASED_ON_EVIDENCE → StudyResult`, V-237 | Q14 | mechanism transferred to product without exposure (FI-303) |
| CQ-ST-02 (Essential, A; W09 owner) | NIAGEN 300 arm → Tru Niagen: SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED (same material node both sides) | path type | component paths | `identityLevel`, V-208 | Q01 row 3; V-208 0 rows | substance-level match reported as product evidence |

## Candidate CQs

| Id | Question | Rationale and failing case | Elements | Query |
|---|---|---|---|---|
| CQ-EV-C01 (candidate) | Under which stated use (servings per day, duration) is a per-serving label amount compared with a per-day trial dose, and is the dose ratio computable? | Labels state per serving; trials per day. Without a stated use the target basis stays PER_SERVING and every DOSE ratio is null (fixture 02; inherited v1 rows). Tru Niagen's label allows 1-3 capsules/day: the ratio is 1.0 only under the one-capsule profile. | `UseContextProfile.servingsPerDay`, `intendedDurationIso`, `FOR_USE_CONTEXT` | Q04 |
| CQ-EV-C02 (candidate) | For a study outcome, which regulatory contexts of use list its analyte as a surrogate, and does the study's context match any of them? | LDL-C has two FDA contexts; NRPT is neither (fixture 03); N08 shows a transferred VALIDATED level | `ContextOfUseMatch`, `COMPARED_WITH_CONTEXT`, W10-V08 | Q05 |

## Invariant / ingestion-failure mapping for SDL elements not tied to one CQ

| Element | Invariant / failure |
|---|---|
| `EvidenceApplicability.overallScore` | INV-204; V-207b, W10-V05 (N03, N04) |
| `ApplicabilityDimension.ratio`, `*QuantityBasis`, `*MassBasis`, `unitCode` | INV-203; V-206, W10-V03, W10-V04 (N05, N06, N19, N20) |
| `ApplicabilityDimension.dimensionClass` | OPEN-QUESTIONS P1-1; V-207, W10-V02 (N07, N18) |
| `ApplicabilityUseTarget` (no UserContext) | INV-506; V-113, V-520, V-521, V-524 (N01, N02) |
| `UseContextProfile` keys | INV-506; W10-V14 (N21) |
| `EvidenceTargetTarget` | INV-202, INV-212; V-203, V-204, V-237 (N14, N16) |
| `supersedes` / `recordedTo` on all W10 types | KCR-2a; V-219, W10-V07, W10-V13 |
| `recordedAt` service-assigned | INV-502; W10-V16b (N22; inherited synthesis v2) |
| `generatedBy`, `assessedByAgent`, `assessedByPerson`, `methodVersion` | INV-407 (every confidence-like judgement names its activity and method) |
| `confidence` (inherited from the interface) | deprecated, `@settable(false,false)` |
| `EvidenceStrength` enum | INV-209 hint only; V-213b |
