# W17 model cards

Module `safety_and_constraints` (candidate). Privacy: every W17 element is PUBLIC shared-graph content; nothing personal is modeled (INV-506). Kind codes: A asserted (source content), O observed, C calculated, I inferred, Op operational, D derived. "Maturity" is the proposed `NodeMaturity`. Uid tokens are requested in W17-SR-02 (`adverse-effect`, `safety-signal`, `use-constraint`; the two Assertion specializations use the registered `assertion` token as `RelationshipAssertion` does).

## 1. Node types

### AdverseEffect — Entity, labels `AdverseEffect, Entity`, uid `hu:adverse-effect:<opaque>`, maturity PROVISIONAL
Meaning: reference concept for a kind of harm (myopathy, nausea, tumor lysis syndrome, LDL-C increased). Not an event, not a signal, not a severity, not a W03 `Condition` with the same name (two nodes; V-W17-13).
| Property | Type / null | Semantics, value states | Kind | Temporal |
|---|---|---|---|---|
| `entityType` | String! | constant `ADVERSE_EFFECT` | Op | immutable |
| `name`, `description` | String | display; never identity | A/Op | editable display |
| `effectCategory` | String | controlled string: SYMPTOM, LAB_ABNORMALITY, DIAGNOSIS, INJURY, MEDICATION_ERROR, OTHER; null = not classified | Op | editable |
| `organSystem` | String | display grouping text (e.g. a SOC name); not a link | Op | editable |
| `severitySummary` | String (read-only) | DEPRECATED live text; severity is per assessment | legacy | frozen |
| `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions` | SearchIndexable | derived retrieval fields (INV-107) | D | regenerable |
Edges: out `HAS_IDENTIFIER` → Identifier (structural, many, IdentifierLinkProperties; MedDRA PT/LLT with issuer and version); out `AFFECTS_ORGAN` → Organ (structural curated, many, W03 MechanismLinkProperties); out `ASSOCIATED_WITH_CONDITION` → Condition (W03 derived one-to-one, read-only); in `RELATES_TO_EFFECT` from SafetySignal / ContraindicationAssertion / InteractionAssertion; out `SUPPORTED_BY_DOCUMENT`/`SUPPORTED_BY_CHUNK` (W20 derived, read-only). Identity keys: uid; terminology codes via Identifier (scheme, issuer, value). Sources: live line 1021; S1, S3. Fulltext `AdverseEffectSearch` / `searchAdverseEffects` kept (D-015).

### SafetySignal — EvidenceAssessment, labels `SafetySignal, EvidenceAssessment`, uid `hu:safety-signal:<opaque>`, maturity PROVISIONAL
Meaning: one immutable, method-versioned BellLabs evaluation that a subject–effect pair (optionally with a co-exposure) shows a pattern warranting attention, with lifecycle state, exact inputs and scope. Re-evaluation = new node `SUPERSEDES {RE_REVIEW}` (KCR-2a); `recordedTo` closes the old one. Not a causal fact, not an event, not an agency statement, not a use constraint.
| Property | Type / null | Semantics, value states | Kind | Temporal |
|---|---|---|---|---|
| `assessmentType` | String! | constant `SafetySignal` | Op | immutable |
| `methodVersion` | String! | `bl-safety-signal/0.x` (BellLabs method), `agency-signal-import/0.1` (mirrors an agency-stated status from a cited listing), `live-migration/0` (migrated live row, no method) | Op | immutable |
| `status` | AssessmentStatus! | record workflow (PROPOSED, ACCEPTED, SUPERSEDED, WITHDRAWN); never the signal state | Op | projection |
| `recordedAt` / `recordedTo` | DateTime! / DateTime | service-assigned commit / written once when superseded | Op | bitemporal (recorded) |
| `signalStatus` | SignalStatus! | lifecycle; NOT_EVALUATED only with live-migration (V-W17-02) | C | immutable per assessment |
| `signalType` | String | controlled string (NEW_EFFECT, INCREASED_FREQUENCY, DOSE_RELATED_TOLERABILITY, LAB_ABNORMALITY, INTERACTION) | C | immutable |
| `severity` | SafetySeverity | assessed intensity; null = not assessed; UNKNOWN = assessed, undeterminable; SERIOUS legacy-only (V-W17-10) | C | immutable |
| `evidenceCutoff` | DateTime | inputs recorded after it were not considered | Op | immutable |
| `summary`, `frequencyText`, `latencyText`, `reversibility`, `mechanismSummary`, `populationSummary` | String | assessment's display content | C | immutable |
| `interactionSummary` | String | legacy display; never parsed for blocking | legacy | immutable |
| `legacyEvidenceStrengthHint` | EvidenceStrength (W10) | live `evidenceStrength` kept as an extraction-time hint; never a verdict | legacy hint | immutable |
| `overallScore` | Float | must stay null (no composite defined; INV-204) | — | — |
| `confidence` | Float (not settable) | deprecated (INV-407) | — | — |
Edges: in `HAS_SAFETY_SIGNAL` from SafetySubjectTarget (structural, one_or_more, exactly one PRIMARY; SafetyEdgeProperties); out `RELATES_TO_EFFECT` → AdverseEffect (structural, exactly_one); out `RELATES_TO_CONDITION` → Condition (structural, many: risk-modifying pre-existing condition); out `SIGNAL_BASED_ON` → StudyResult | Study | Assertion (structural, one_or_more except migrated rows; SignalInputProperties); in `REPORTS_SAFETY_SIGNAL` from Study (derived, read-only); out/in `SUPERSEDES` (SupersessionProperties); out `SUPPORTED_BY` → SourceLocator (for agency imports); out `WAS_GENERATED_BY` → Activity. Derived rule `ss-study/v1`: Study −REPORTS_SAFETY_SIGNAL→ SafetySignal iff the signal is current and has an input AdverseEventResult `RESULT_FOR_ARM` an arm of that Study or a Study input with `aeReportedStatus` REPORTED; `derivedFromAssessmentUids = [signal uid]`. Sources: live line 1041; S3, S3a, S6; round 0002 OQ-L2-10. Fulltext `SafetySignalSearch` / `searchSafetySignals` kept (D-015).

### ContraindicationAssertion — Assertion, labels `ContraindicationAssertion, Assertion`, uid `hu:assertion:<opaque>`, maturity CANDIDATE (in fragment: CQ-RC-06, CQ-SF-C03; fixtures 03-05)
Meaning: one source's directive restricting the use of its subject in a condition/population (`USE_CONSTRAINED_IN`) or with a co-exposure (`USE_CONSTRAINED_WITH`), at a stated level. Full kernel Assertion contract (W00 AssertionArchetype; status = capture fidelity; bitemporal; `SUPERSEDES`).
| Property | Type / null | Semantics | Kind |
|---|---|---|---|
| `predicate` | String! | `USE_CONSTRAINED_IN` (object Condition or UseContextProfile) / `USE_CONSTRAINED_WITH` (object the co-exposure) | A |
| `polarity` | Polarity (required by V-W17-04) | POSITIVE stated; NEGATIVE stated not to apply / removed; UNKNOWN source cannot tell | A |
| `speechAct` | SpeechAct | normally CAUTIONS (label directive) or RECOMMENDS (review advice) or STATES (agency removal) | A |
| `constraintLevel` | ConstraintLevel! | source directive strength (mapped) | A |
| `levelVerbatim` | String | the source's words | A |
| `doseComparator`, `doseValue`, `doseUnitCode` (UCUM), `doseQuantityBasis`, `doseMassBasis` | ThresholdComparator, Float, String, QuantityBasis, MassBasis | band of the **constrained subject**; all-or-none (V-W17-08); DO_NOT_EXCEED_DOSE requires it ("Do not exceed ZOCOR 10 mg once daily" → GT 10 mg PER_DAY is restricted; mass basis UNSPECIFIED: the label does not say salt vs moiety) | A |
| `coExposureDoseText` | String | verbatim co-exposure dose ("≥1 gram/day niacin"); normalized on CONSTRAINT_SCOPE | A |
| `route`, `jurisdiction` | String | as stated; a US label constraint is US-scoped | A |
| `populationScopeText`, `scopeExceptionText` | String | verbatim population and exception ("a small group of very high-risk pregnant patients") | A |
| literal value fields | not settable | object XOR literal: the object is a node | — |
Edges: kernel `HAS_SUBJECT`, `HAS_OBJECT` (exactly one each), `ASSERTED_BY` (at most one; a label's labeler when captured — not captured for S1), `SUPPORTED_BY`, `SUPERSEDES`, `WAS_GENERATED_BY`; out `RELATES_TO_EFFECT` → AdverseEffect (structural, many: the harm named as reason); out `RESOLVES_TO_CONSTRAINT` → UseConstraint (derived ruleOnly `uc-match/v1`, zero_or_one; read-only).

### InteractionAssertion — Assertion, labels `InteractionAssertion, Assertion`, uid `hu:assertion:<opaque>`, maturity CANDIDATE (in fragment: CQ-RC-06, CQ-SF-C04; fixtures 03, 04)
Meaning: one source's statement that co-exposure to its subject (perpetrator) changes exposure to or effect of its object; predicate `INTERACTS_WITH`. Polarity is required; NEGATIVE is a studied absence (V-W17-05); UNKNOWN still resolves to a UseConstraint.
| Property | Type / null | Semantics | Kind |
|---|---|---|---|
| `polarity` | Polarity | POSITIVE / NEGATIVE (studied, not found) / UNKNOWN (predicted, possible, in vitro only) / MIXED | A |
| `basisKind` | BasisKind | DIRECT_MEASUREMENT (primary PK/clinical report), INFERRED_FROM_MEASUREMENT, CITED_FROM_PRIOR_WORK (review), HYPOTHESIS | A |
| `evidenceSetting` | MechanismSetting (W03) | required with DIRECT_MEASUREMENT / INFERRED_FROM_MEASUREMENT and with NEGATIVE; null = not stated | A |
| `interactionMechanism`, `interactionEffect` | String | controlled strings (see fragment); NOT_STATED explicit | A |
| `exposureChangeText`, `subjectDoseText`, `objectDoseText`, `populationScopeText` | String | verbatim | A |
| `reportedEvidenceGrade`, `reportedEvidenceGradeScheme` | String | the source's own grade and scheme ("C", "SORT (AFP)…"); never a BellLabs strength | A |
Edges: as ContraindicationAssertion (`RELATES_TO_EFFECT`, `RESOLVES_TO_CONSTRAINT`, kernel edges).

### UseConstraint — Entity, labels `UseConstraint, Entity`, uid `hu:use-constraint:<opaque>`, maturity CANDIDATE (in fragment: CQ-RC-06, CQ-RC-07, CQ-SF-C03; fixtures 03-05)
Meaning: the shared identity of one scoped use concern; the uid a private `RecommendationOption.blockingConstraintUids` names; carries no truth, level or in-force flag (computed from live assertions, Q-W17-04/06).
| Property | Type / null | Semantics | Kind |
|---|---|---|---|
| `entityType` | String! | constant `USE_CONSTRAINT` | Op |
| `identityKeyHash` | String! (unique) | `sha256:` over canonical JSON {subject uid, subject dose band, route, jurisdiction, sorted [(member uid, scopeRole, member dose band)]} | C |
| `identityKeyVersion` | String! | `uc-key/v1` | Op |
| dose band (`doseComparator`, `doseValue`, `doseUnitCode`, `doseQuantityBasis`, `doseMassBasis`) | as above | band of the constrained subject; part of identity | A (copied from the resolved statement) |
| `route`, `jurisdiction` | String | part of identity; null = not route- or jurisdiction-specific | A |
Edges: out `CONSTRAINS_USE_OF` → SafetySubjectTarget (structural identity, exactly_one, StructuralEdgeProperties); out `CONSTRAINT_SCOPE` → UseConstraintScopeTarget (structural identity, one_or_more, ConstraintScopeProperties); in `RESOLVES_TO_CONSTRAINT` (derived). Lifecycle: created once per identity key (MERGE on `identityKeyHash`); never edited; a different scope is a different UseConstraint; a merge of duplicates publishes an `EquivalenceAssessment` redirect (contract A2) so private records keep resolving. Never created from private context (V-W17-12).

## 2. Relationship types

| Type | Domain → range | Class | Cardinality | Properties | Notes |
|---|---|---|---|---|---|
| `HAS_SAFETY_SIGNAL` | SafetySubjectTarget → SafetySignal | structural (assessment target; live direction kept) | per signal: one_or_more, exactly one PRIMARY | SafetyEdgeProperties | written in the signal's commit; immutable; never carries assertionUid (V-W17-11) |
| `RELATES_TO_EFFECT` | SafetySignal \| ContraindicationAssertion \| InteractionAssertion → AdverseEffect | structural | signal: exactly_one; assertions: many | StructuralEdgeProperties | "the harm this record concerns" |
| `RELATES_TO_CONDITION` | SafetySignal → Condition | structural | many | StructuralEdgeProperties | risk-modifying pre-existing condition; the effect is never put here |
| `AFFECTS_ORGAN` | AdverseEffect \| Condition → Organ | structural (curated reference) | many | MechanismLinkProperties (W03) | one meaning shared with W03 (W03-SR-08); V-W17-09 |
| `REPORTS_SAFETY_SIGNAL` | Study → SafetySignal | derived (rule `ss-study/v1`) | many | DerivedEdgeProperties (`derivationRule`, `derivedFromAssessmentUids`) | read-only; never the only history |
| `SIGNAL_BASED_ON` (new) | SafetySignal → StudyResult \| Study \| Assertion | structural | one_or_more | SignalInputProperties | NOT_REPORTED only on Study inputs (V-W17-03) |
| `CONSTRAINS_USE_OF` (new) | UseConstraint → SafetySubjectTarget | structural (identity) | exactly_one | StructuralEdgeProperties | V-W17-06 |
| `CONSTRAINT_SCOPE` (new) | UseConstraint → UseConstraintScopeTarget | structural (identity) | one_or_more | ConstraintScopeProperties | V-W17-06, V-W17-08 |
| `RESOLVES_TO_CONSTRAINT` (new) | ContraindicationAssertion \| InteractionAssertion → UseConstraint | derived (ruleOnly `uc-match/v1`) | zero_or_one per assertion | DerivedEdgeProperties (`derivationRule`, `derivedFromAssertionUids = [assertion uid]`) | rule: the assertion's subject and object uids are both members of {constrained subject} ∪ scope members, and its dose band / population text maps to the UseConstraint's bands and POPULATION members; INTERACTS_WITH resolves to the UseConstraint whose constrained subject is the affected object and whose CO_EXPOSURE member is the perpetrator, or the reverse when only that one exists. V-W17-06 |

Asserted predicates registered by the module (candidates, W17-SR-03): `USE_CONSTRAINED_IN`, `USE_CONSTRAINED_WITH`, `INTERACTS_WITH`, `IDENTIFIES_POTENTIAL_SAFETY_SIGNAL` (agency listing; subject the listed product/substance, object AdverseEffect; generic `Assertion`). No asserted relationship type projects them in this proposal (no live shortcut needs one).

## 3. Relationship-property types

| Type | Specializes | Added fields | Notes |
|---|---|---|---|
| `SafetyEdgeProperties` | StructuralEdgeProperties (orderIndex, notes, mongoResearchRunId) | relationshipUid!, subjectRole!, exposureContext, doseText, route, frequency, populationSubset | successor of live SafetyMetadata minus evidenceStrength/confidence; unique relationshipUid (operations C) |
| `SignalInputProperties` | StructuralEdgeProperties | aeReportedStatus! (ReportedStatus), inputRole (controlled string INDEX_ARM, COMPARATOR_ARM, AGENCY_LISTING, MEASURED_LAB, NOT_REPORTED_STUDY) | INV-207 |
| `ConstraintScopeProperties` | StructuralEdgeProperties | scopeRole! (ConstraintScopeRole), doseComparator (ThresholdComparator, W16), doseValue, doseUnitCode, doseQuantityBasis, doseMassBasis | co-exposure dose band |

## 4. Enums and unions (W17 sole writer)

| Name | Values | Owner note |
|---|---|---|
| `SafetySeverity` | MILD, MODERATE, SEVERE, SERIOUS (legacy), LIFE_THREATENING, UNKNOWN | live values kept |
| `SignalStatus` | POTENTIAL, UNDER_EVALUATION, CONFIRMED_ASSOCIATION, CLOSED_NO_ACTION, NOT_SUPPORTED, INSUFFICIENT_DATA, NOT_EVALUATED | new; grounded in S3/S3a wording |
| `ConstraintLevel` | CONTRAINDICATED, DO_NOT_EXCEED_DOSE, AVOID, NOT_RECOMMENDED, USE_WITH_CAUTION, MONITOR, MAINTAIN_CONSISTENT_INTAKE, CONSULT_CLINICIAN | new; each value grounded in S1, S2, S4 or S5 |
| `ConstraintScopeRole` | CONDITION_PRESENT, POPULATION, CO_EXPOSURE | new; parallels W16 `ConstraintKind` subset without importing step semantics |
| `SafetySubjectRole` | PRIMARY, CO_EXPOSURE | new |
| `SafetySubjectTarget` | ChemicalSubstance, IngredientMaterial, Product, ProductVariant, Treatment, Procedure, Lifestyle, Exposure | live successor |
| `SafetySignalInputTarget` | StudyResult, Study, Assertion | new |
| `UseConstraintScopeTarget` | Condition, UseContextProfile, ChemicalSubstance, IngredientMaterial, Product, ProductVariant, Treatment, Procedure, Lifestyle, Exposure | new |

Imported (not redefined): `ThresholdComparator` (W16), `EvidenceStrength` (W10 legacy hint enum), `MechanismSetting` (W03), `ReportedStatus`, `QuantityBasis`, `MassBasis`, `Polarity`, `BasisKind` (W00).

## 5. Private-store contract touch points (no SDL; W23 owns the store)

`RecommendationOption.blockingConstraintUids` holds `hu:use-constraint:` uids (and, for protocol-sourced blocks, W16 `hu:constraint:` uids); `evidenceAssertionUids` holds the Contraindication/InteractionAssertion uids read at `evidenceRecordedAt`; a block caused by absent interaction data holds the policy's `hu:decision-criterion:` uid (SAFETY_BLOCK) and `missingFactKeys` such as `INTERACTION_DATA:<option uid>:<co-exposure uid>` (W17-SR-07). The private store maps a person's declared intake and population to public uids; the shared graph is queried with those public uids only (Q-W17-04 parameters).
