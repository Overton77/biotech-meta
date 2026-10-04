# W10 01 Domain recommendation: evidence assessment, applicability and synthesis

Worker W10 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical module `studies_and_evidence` (catalog 0.2.0, digest `8fb50ff0…84f0`). Archetype contract `baseArchetypes.EvidenceAssessment` (required `uid, assessmentType, methodVersion, status, createdAt, recordedAt`; immutable; re-assessment = new node `SUPERSEDES`; a composite needs `methodVersion` and every required dimension).

## 1. Boundary

W10 owns BellLabs' **judgements about evidence**, never the evidence itself and never a truth value on a source record:

| Subdomain | W10 types | What it judges | What it is not |
|---|---|---|---|
| Applicability | `EvidenceApplicability`, `ApplicabilityDimension`, `UseContextProfile` (Entity) | whether one study intervention or one mechanism assertion transfers to one commercial or non-personal use target, dimension by dimension | formulation continuity (W04), material identity resolution (W00 `ResolutionHypothesis`, W02), personal applicability (private store, W23) |
| Endpoint role | `EndpointClassification` | the role an outcome or biomarker plays in an inference in a stated context of use (BEST category, surrogate level, FDA context columns) | what was measured (`OutcomeDefinition.measureKind`, W09), outcome priority (`DECLARES_OUTCOME_PRIORITY` assertions, W09), the analyte (`Biomarker`, W07) |
| Result reading | `ResultInterpretation` | effect detected / inconclusive / no meaningful effect, and meaningfulness against a sourced threshold | the observed `statisticalConclusion` (W09), the authors' "clinically meaningful" (Assertion) |
| Synthesis | `EvidenceSynthesis` | a versioned claim-level verdict with input roles and the triggers that changed it | `Claim` (W21, carries no truth), `Adjudication` of one assertion (W00) |
| Strength | `EvidenceStrengthAssessment` | a graded level under a named scheme with criteria | `confidence`, `Study.evidenceLevel`, live `EvidenceStrength` values (hints only) |

Dependencies (by name only): W00 kernel (`EvidenceAssessmentArchetype`, `AssessmentStatus`, `AdjudicationVerdict`, `QuantityBasis`, `MassBasis`, `SupersessionProperties`, `SourceLocator`, `Assertion`, `ResolutionHypothesis`, `Activity`, `Agent`, kernel relationships `SUPPORTED_BY`, `SUPERSEDES`, `WAS_GENERATED_BY`, `ASSESSED_BY`, `CONSIDERS_ASSESSMENT`); W09 study records; W02 `IngredientMaterial`; W04 `Product`, `ProductVariant`, `FormulationVersion`; W12 `ProductLot`; W07 `Biomarker`; W21 `Claim`; W01 `Person`.

Identity vs state vs artifact vs occurrence: every W10 node except `UseContextProfile` is an **EvidenceAssessment** (a judgement with method, status and recorded time). `UseContextProfile` is an **Entity** (catalog: "non-personal use target"): a described use, not a judgement. Nothing W10 owns is VersionedState, Occurrence or InformationArtifact; versions of a judgement are separate immutable nodes linked `SUPERSEDES`.

## 2. Disposition of every element in scope

Live schema (`current_biotech_schema.graphql` 86b5e0b5…f112) and catalog/delta elements; full rows in `migration-map.yaml`.

| Element | Origin | Disposition | Final home |
|---|---|---|---|
| `EvidenceApplicability` (flat `identityMatch`, `doseMatch`, … ; `overallScore`; `summary`) | catalog + delta | **keep/refine**: dimension nodes are authoritative; flat fields kept as derived read-only `ApplicabilityVerdict` projections; `overallScore` null until a calibrated composite method exists | `EvidenceApplicability` |
| `ApplicabilityDimension` | catalog + delta | **keep** (all 16 catalog properties); typed enums; one node per dimension, one parent | `ApplicabilityDimension` |
| `UseContextProfile` | catalog (Entity) | **keep + refine**: add CANDIDATE `servingsPerDay`, `intendedDurationIso` (CQ-EV-C01, fixture 01/02) | `UseContextProfile` |
| `ASSESSES_APPLICABILITY_TO` → `UserContext` | live/0.1.0 | **retire** (round 0008); `PersonalApplicabilityAssessment` in the private store | union `ApplicabilityUseTarget` without UserContext |
| `EndpointClassification` | catalog + delta (`biomarkerCategory`, `contextMatch` were String) | **keep/refine**: `BiomarkerCategory` and CANDIDATE `ContextOfUseMatch` enums; `surrogateValidationLevel` nullable for clinical outcomes | `EndpointClassification` |
| `ResultInterpretation` | catalog | **keep**; CANDIDATE `MeaningfulnessVerdict` enum | `ResultInterpretation` |
| `EvidenceSynthesis` (`verdict: String`) | catalog + delta | **keep/refine**: `verdict: AdjudicationVerdict!` (kernel enum reused); typed `TRIGGERED_BY` / `INCLUDES_RESULT` properties | `EvidenceSynthesis` |
| `EvidenceStrengthAssessment` | catalog | **keep** | `EvidenceStrengthAssessment` |
| `EvidenceChangeMetadata`, `SynthesisInputMetadata` (delta, String fields) | delta | **rename + type**: `EvidenceChangeProperties {criterionCode, effectOnVerdict: EvidenceChangeEffect!, evidencePublishedAt}`, `SynthesisInputProperties {inputRole: SynthesisInputRole!}` | W10 relationship-property types |
| `enum EvidenceStrength {LOW MODERATE HIGH}` | live | **keep as legacy hint enum** (INV-209): only other owners' hint fields use it; migrated values become `EvidenceStrengthAssessment {scheme: LEGACY_UNSPECIFIED, status: PROPOSED}` | W10 enum |
| `Study.evidenceLevel` | live | **move** (W09 retires the field) → `EvidenceStrengthAssessment` | W10 |
| `OutcomeResult.isClinicallyMeaningful` | live | **split**: author `Assertion` `RESULT_CLINICALLY_MEANINGFUL` + `ResultInterpretation.meaningfulnessVerdict` | W09/W10 |
| `Claim.evidenceStrength`, `AssociationMetadata.evidenceStrength`, `SafetyMetadata.evidenceStrength`, `TreatmentTargetMetadata.evidenceStrength`, `SafetySignal.evidenceStrength` | live | **derive/hint**: kept by their owners only as hints typed `EvidenceStrength`; assessment is W10 (or W21 `ClaimEvidenceAssessment` for Claim) | owners W21/W03/W17/W06 |
| `Biomarker.clinicalSignificance`, `biomarkerType` | live | **move** (W07 keeps display) → `EndpointClassification` | W10 |
| `Study.evaluates` / `EVALUATES` | live | **retire** for current products (INV-201); W09 keeps read-only legacy | `EvidenceApplicability` path |
| `ASSESSES_CLAIM` on delta `ClaimEvidenceAssessment` | delta | **rename** at W21 to `ASSESSES_CLAIM_EVIDENCE` (catalog); `ASSESSES_CLAIM` = `EvidenceSynthesis` only (seam W10-SR-02) | W21 / W10 |
| Enums `ApplicabilityVerdict`, `ApplicabilityDimensionKind`, `DimensionClass`, `MaterialIdentityLevel`, `EndpointClass`, `BiomarkerCategory`, `SurrogateValidationLevel`, `ResultInterpretationKind`, `SynthesisInputRole`, `EvidenceChangeEffect` | catalog conventions | **keep** at catalog values (BEST and FDA confirmed, `03-source-manifest.md`) | W10 |
| `EvidenceSynthesisVerdict` (candidate in brief) | new | **not created**: `AdjudicationVerdict` already holds SUPPORTED … INSUFFICIENT; a second verdict enum would split one meaning | — |
| Unions `ApplicabilityUseTarget`, `EvidenceTargetTarget`, `SynthesisInputTarget` | new (B6) | **create** | W10 |
| Relationships `HAS_EVIDENCE_TARGET`, `ASSESSES_APPLICABILITY_TO`, `FOR_USE_CONTEXT`, `BASED_ON_EVIDENCE`, `HAS_DIMENSION`, `CONSIDERS`, `CLASSIFIES_OUTCOME`, `CLASSIFIES_BIOMARKER`, `COMPARED_WITH_CONTEXT`, `INTERPRETS_RESULT_OF`, `USES_THRESHOLD_SOURCE`, `ASSESSES_CLAIM`, `INCLUDES_RESULT`, `TRIGGERED_BY`, `ASSESSES_STRENGTH_OF` | catalog | **keep** (all structural); multi-range relationships are written as typed fields per range (no unregistered union) | W10 |

## 3. Smallest recommended model

The catalog model, typed, plus three small refinements that fixtures showed are needed:

1. **Use-profile normalization (CANDIDATE `UseContextProfile.servingsPerDay`)**. A label states mg per serving; a trial states mg per day. Without a stated servings-per-day the target quantity basis stays PER_SERVING and the ratio is null forever. The Basis label's directions ("Take two (2) capsules every morning", 1 serving) and Tru Niagen's ("one capsule 1-3 times daily") are real cases (fixtures 01, 02).
2. **`ContextOfUseMatch` enum** for `EndpointClassification.contextMatch` (property card values FULL/PARTIAL/NONE), so surrogate non-transfer is checkable (W10-V08).
3. **`CONSIDERS_ASSESSMENT` from `ApplicabilityDimension`** (kernel domain change requested, W10-SR-04): STUDY_DESIGN_AND_QUALITY must cite the EvidenceStrengthAssessment it copies, OUTCOME_RELEVANCE the EndpointClassification it uses, MATERIAL_IDENTITY the ResolutionHypothesis records it weighs (round 0002 R4 "copied level, never recomputed").

Everything else is the catalog: one evidence target, one use target, one dimension node per required dimension with NOT_ASSESSED explicit; ratios only when quantity basis, mass basis and unit match (UNSPECIFIED never matches); explanation-only dimensions NOT_SCORED; surrogate status only on EndpointClassification with a context of use; INV-206 input roles; versioned syntheses with `TRIGGERED_BY {criterionCode, effectOnVerdict, evidencePublishedAt}`.

## 4. Alternatives considered (and rejected)

| Alternative | Failing case | Why rejected |
|---|---|---|
| Flat dimension fields only (live/delta shape) | Basis DOSE must cite the paper's Methods and the label and list the unspecified salt (fixture 01 Q02) | a property cannot cite or list missing facts (round 0002 C2-02) |
| Ratio bands now (e.g. "within ±20 % = MATCH") | N20 (ratio 0.8 marked MATCH) | no calibration set exists (OPEN-QUESTIONS P1-2, DEFERRED); an invented band is a silent method; W10-V04 forbids non-identity MATCH until a method is calibrated |
| Composite score with available dimensions | N03, N04 | averaging hides the weakest dimension (INV-008, INV-204); W10-V05 |
| Surrogate level on `Biomarker` | N09; FDA lists serum LDL-C in two different contexts (hypercholesterolemia/lipid-lowering; LAL deficiency/enzyme) | context of use is part of the fact (FDA: "should not be assumed to be appropriate for use in a different program") |
| Synthesis-specific verdict enum | — | duplicates `AdjudicationVerdict` |
| `UseContextProfile` as EvidenceAssessment | — | it is a described use with no method or verdict; catalog says Entity |
| Union for `TRIGGERED_BY` / `BASED_ON_EVIDENCE` / `ASSESSES_CLAIM` / `ASSESSES_STRENGTH_OF` ranges | — | unions not in the registry; typed fields per range (as W21 does for `CLAIM_EVIDENCE_BASED_ON`) build under 7.6.3 and keep the relationship type single |
| `ASSESSES_STRENGTH_OF → Assertion` (W06-SR-10) | W06 N3 | grade the EvidenceSynthesis that `ASSESSES_CLAIM` the assertion instead; keeps one place for strength |
| `Exposure` reference edge from a dimension (W05-SR-18) | SUBRANUT per-nut selenium | the per-unit amount is a CALCULATED Assertion (INV-307) and enters through `CONSIDERS`; no new edge |

## 5. What the research settled

- BEST categories (7) and surrogate levels (validated, reasonably likely, candidate) match the catalog enums exactly; `NOT_ESTABLISHED` is a BellLabs value and is documented as such.
- FDA surrogate table columns = `contextDiseaseOrUse`, `contextPopulation`, `surrogate endpoint`, `contextApprovalType` (Traditional/Accelerated), `contextInterventionMechanism`; LDL-C appears in two contexts.
- NIAGEN vs Basis dose basis: Conze et al. Methods state capsules of "NR chloride" (SALT_FORM); the Basis trial paper says "125 mg of NR" per capsule with no salt (UNSPECIFIED); both labels declare the chloride. So the Basis DOSE ratio is blocked by mass basis and the NIAGEN→Tru Niagen ratio is computable (1.0) once a one-capsule-daily profile fixes the per-day amount.
- Biomarker primary with clinical secondary: NADPARK NCT03816020 (primary FDG-PET PDRP; secondary MDS-UPDRS).
- Versioned systematic review: vitamin D / ARI meta-analysis 2017 (OR 0.88) → 2021 (0.92) → 2025 (0.94, CI includes 1) — the third version flipped statistical significance after new trials, a real `TRIGGERED_BY … WEAKENED`.
