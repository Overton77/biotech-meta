# W16 Protocols and public workflow definitions: domain recommendation

Worker W16 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical module: `protocols` (catalog 0.2.0, digest `8fb50ff0…84f0`). This packet is a recommendation; Fable 5.1 writes the final schema.

## 1. Boundary

The `protocols` module holds **public definitions of what to do**: a protocol's enduring identity, its observed or published versions, the steps of each version with their schedule, dose, conditions, dependencies and requirement level, the measurement plans, targets, goals and review rules the source states, and public, source-attributed observations and results. It never holds what any person did.

| In scope (W16 sole writer) | Out of scope (owner; referenced by name or uid) |
|---|---|
| `Protocol`, `ProtocolEdition`, `ProtocolStep`, `Constraint`, `MeasurementPlan`, `ProtocolAdjustmentRule`, `Target`, `FunctionalGoal`, `Observation` (public), `ProtocolResult` (public) | Study protocol document `ProtocolVersion`, `StudyIntervention`, `StudyResult` (W09) |
| 17 protocol enums, 5 unions, 4 relationship-property types, 30 relationship types (registry row) | Materials, substances (W02); products, variants, formulation versions (W04); food, exposure, lifestyle (W05); treatments, procedures (W06) |
| The derived read-only `Protocol.currentSteps` (D-004) | Metric, LabTest, AssayVersion, ReferenceIntervalVersion, the `DiagnosticResult` interface (W07); devices and instruments (W08) |
| | Authors and roles as Person/Organization (W01) through kernel Assertions (W00); Activity lineage (W00) |
| | Private adoption `ProtocolInUse`, `ProtocolAdoptionVersion`, `ProtocolDeviation`, `PersonalMeasurement`, pending items (W23 private-store contract) |
| | Evidence applicability of a step's evidence to a protocol or person (W10); contraindication assertions of the safety module (W17) |

### Subdomains

1. **Identity and versioning**: `Protocol` (Entity) and `ProtocolEdition` (VersionedState, immutable, `payloadHash`, attached by `HAS_PROTOCOL_EDITION`, asserted, EXCLUSIVE). Three change provenances: `SOURCE_VERSIONED` (protocols.io "V.2"; NICE "Last updated: 02 September 2025"), `SNAPSHOT_DIFF` (Blueprint page changes silently: Tadalafil 2.5 mg became 5 mg between the 2026-01-24 Wayback capture and the 2026-10-04 live capture while the byline stayed "01.23.2026"), `THIRD_PARTY_REPORTED` (NAD.com reports rapamycin "stopped in 2024"): an Assertion, never an edition.
2. **Step structure**: `ProtocolStep` with lineage `stepKey`, immutable payload (`payloadHash`), `requirementLevel`/`requirementBasis`, `notReportedFields`, `speechAct` (practice vs recommendation). Order lives on the `HAS_PROTOCOL_STEP` edge, so an unchanged step can be shared by editions at different positions.
3. **Dependency DAG versus recurrence**: `DEPENDS_ON {dependencyKind, lagMin, lagMax, lagUnit, dependencyBasis}`. Ordering kinds (`REQUIRES_PRIOR_COMPLETION`, `REQUIRES_RESULT_OF`) are acyclic per edition (V-528p); `CONCURRENT_WITH` and `MUTUALLY_EXCLUSIVE_WITH` are symmetric, non-ordering relations. Recurrence is schedule data on the step (cadence range, occurrences per period, total occurrences, cycles, `repeatUntilText`), never a dependency loop.
4. **Schedule**: bounded ranges everywhere (`cadenceIntervalMin/Max`, `occurrencesPerPeriodMin/Max`, `totalOccurrencesMin/Max`, `durationMinutesMin/Max`, `durationDaysMin/Max`, `cycleLength/Active/CountMin/Max`); verbatim `scheduleText`, `frequencyText`, `timingText`, `durationText` always kept.
5. **Conditions**: reusable `Constraint` nodes (kind, verbatim text, optional comparator/threshold/unit, `BASED_ON` the tested fact) attached by `HAS_CONSTRAINT {constraintRole, conditionGroup, negated}` to editions, steps and rules. Conditions combine in conjunctive normal form: this is what "every 6 months, **or** every 3 months for people in **any** of the following groups" and "if over 40 **or** a family history" need.
6. **Dose**: `USES {StepDoseProperties}` = declared dose of a public step: amount or range, UCUM unit, `quantityBasis`, `massBasis`, `amountReferent`, route, verbatim text. "Acarbose 200 mg (Rx) (twice daily)" is 200 mg `PER_DOSE` × 2 per day, not 400 mg `PER_DAY`, although the same page also prints "400 mg daily".
7. **Evaluation and review**: `MeasurementPlan` (timing, required-for-evaluation, max baseline age, cadence days range), `Target` (bounded, per metric), `FunctionalGoal`, `ProtocolAdjustmentRule` (trigger kind, comparator, threshold, action, rule basis; BellLabs policy rules are INTERNAL and name a `PolicyVersion` uid).
8. **Composition**: `INCLUDES_PROTOCOL` (edition → edition, **PINNED**) versus `HAS_SUBPROTOCOL` (edition → protocol, **FLOATING**, resolved as-of and labelled `RESOLVED_AS_OF`). The same rule binds materials: `USES` → `FormulationVersion` is pinned; `USES` → `Product`/`ProductVariant` floats and is resolved through W04's `HAS_FORMULATION_VERSION` at the edition's observation instant.
9. **Public results**: `Observation` (InformationArtifact, implements W07 `DiagnosticResult`, attributed by asserted `RECORDS` or an attributed `ProtocolResult`) and `ProtocolResult` (asserted `FOR_PROTOCOL`, `CLAIMS_OUTCOME`, `POSTS_RESULT`).

### Identity versus state versus artifact versus occurrence

| Element | Archetype | Why |
|---|---|---|
| Protocol | Entity | Survives every content change; the uid that a private adoption and a public result point at. Name and URL are not identity. |
| ProtocolEdition | VersionedState | Immutable payload, new node per `payloadHash` change; validity comes from the asserted attachment episode. |
| ProtocolStep | Entity (catalog), immutable payload | Lineage by `stepKey`, payload by `payloadHash`; kept Entity per catalog to avoid a kernel change; immutability is service-enforced (copy-on-write). |
| Constraint, MeasurementPlan, ProtocolAdjustmentRule, Target, FunctionalGoal | Entity | Reusable definitions; once attached to an edition they are part of its payload and immutable. |
| Observation, ProtocolResult | InformationArtifact | Records of what was reported, with publication/observation times. |
| A person adopting/following a protocol | none in the shared graph | Private store (W23). Adoption never implies adherence (forbidden implication). |

## 2. Disposition of every live and catalog element

`keep` = unchanged meaning; `refine` = same identity with changed fields; `merge`/`split`; `seam` = owner elsewhere; `defer` = candidate outside the fragment; `retire` = removed with migration.

| Element | Origin | Disposition | Note |
|---|---|---|---|
| `Protocol` | live + cat | refine | enduring identity; `versionLabel`, `lastUpdatedAt`, all schedule fields and `authorName` move off (edition payload; authorship Assertion) |
| `Protocol.hasSteps` (`HAS_STEP`) | live | retire → derived | replaced by `ProtocolEdition.steps` (`HAS_PROTOCOL_STEP`) and read-only `Protocol.currentSteps` (`HAS_CURRENT_PROTOCOL_STEP`, derived) per D-004/CL-013 |
| `Protocol.hasConstraints/hasMeasurementPlans/hasTargets/hasFunctionalGoals/hasAdjustmentRules/targets/includesProtocols/hasSubprotocols` | live | move | to `ProtocolEdition` (payload of a version) |
| `Protocol.results` | live | keep | `FOR_PROTOCOL` IN, now asserted |
| `ProtocolEdition` | cat + delta | keep/refine | adds `changeProvenance`, `sourceVersionDate(Text)`, canonicalization and alignment versions, edition-level schedule |
| `ProtocolStep` | live + cat | refine | `stepKey`, `payloadHash`, `requirementLevel/Basis`, `notReportedFields`, `speechAct`, bounded schedule ranges, cycles, `repeatUntilText` |
| `ProtocolStep.isOptional` | live | retire → `requirementLevel` | `true` → OPTIONAL; `false` → NOT_STATED (never ESSENTIAL) |
| `ProtocolStep.isRepeatable` | live | retire | repetition is explicit schedule data |
| `ProtocolStep.cadenceInterval` | live | split | `cadenceIntervalMin` = `cadenceIntervalMax` = old value |
| `Constraint` | live + cat | refine | `constraintKind`, `constraintText`, threshold triple; `constraintType` retired |
| `MeasurementPlan` | live + cat | refine | `planTiming`, `requiredForEvaluation`, `maxBaselineAgeDays`, `cadenceMin/MaxDays`, `scheduleText`; `planType` retired |
| `ProtocolAdjustmentRule` | live + cat | refine | review-trigger fields, `ruleText`, `policyVersionUid`; `TRIGGERED_BY` renamed `RULE_TRIGGERED_BY`; `REQUIRES_CONDITION` → `HAS_CONSTRAINT` |
| `Target` | live + cat | refine | bounds, unit, comparator, text; `COMPARED_TO_REFERENCE` (→ legacy `ReferenceRange`) retired |
| `FunctionalGoal` | live + cat | keep | `OPERATIONALIZED_BY` now structural |
| `Observation` | live + cat | refine | InformationArtifact implementing `DiagnosticResult`; public only (round 0008 §7, CL-008) |
| `ProtocolResult` | live + cat | refine | `supportedBy` (`ProvenanceSource`) retired to Assertion → SourceLocator; edges asserted |
| `StepSubstance` | live union | rename+refine → `StepSubstanceTarget` | Compound/CompoundForm out (D-002); IngredientMaterial, ChemicalSubstance, ChemicalForm, ProductVariant, FormulationVersion in |
| `StepInstrument` | live union | rename+refine → `StepInstrumentTarget` | + AssayVersion, ToolOrInstrument |
| `TherapeuticTarget`, `ConstraintBasis` | live unions | rename → `*Target` | members unchanged |
| `ProtocolResultMention` | live union | rename+refine | Compound → ChemicalSubstance; + IngredientMaterial, ProductVariant |
| `ProvenanceSource` (as used by `ProtocolResult.supportedBy`) | live union | seam (W00/W20) | W16 stops using it |
| Enums `ProtocolType`, `SchedulePattern`, `CadenceUnit`, `TimeOfDay`, `DayOfWeek`, `ProtocolStepType` | live | keep | `CadenceUnit` YEAR and MINUTE requested (W16-SR-07) |
| Enums `RequirementLevel` … `ProtocolChangeProvenance` | cat/delta | keep | catalog values frozen; `REPEAT_UNTIL` role requested (W16-SR-08) |
| `OrderingMetadata` on `HAS_STEP`/`DEPENDS_ON`/`INCLUDES_PROTOCOL`/`HAS_SUBPROTOCOL` | live | split | `StepOrderProperties`, `StepDependencyProperties`, `StructuralEdgeProperties` |
| `RoleMetadata` on protocol edges | live | split | `ConstraintRoleProperties`; `AssertedEdgeProperties` for asserted edges; `StructuralEdgeProperties` elsewhere |
| `DoseMetadata` on `USES` | live | refine → `StepDoseProperties` | dose/doseUnit → quantity/unitCode; adds basis, range, route, verbatim |
| `MeasurementMetadata`, `AssociationMetadata`, `ExtractionMetadata` on protocol edges | live | retire | method/unit facts belong to W07 AssayVersion and Observation fields |
| `Person.recordsObservations` (`RECORDS`), `Person.postsResults` (`POSTS_RESULT`) | live | seam (W01 field), keep restricted | asserted edges; public persons only (CL-018) |
| Catalog forbidden implications (3) | cat | keep | each has a negative fixture (fixtures 02, 06, 07) and a validator (V-530p, V-534p, V-536p) |
| V-525, V-526 | cat | refine | restated on `HAS_PROTOCOL_STEP` (V-525p, V-526p) |

## 3. Alternatives considered

| Question | Alternative | Rejected because (evidence) |
|---|---|---|
| Where is the schedule? | A separate `Schedule` node per step | No CQ needs schedule identity; a node per step doubles ingestion; the bounded-range fields answer CQ-PR-02/03 and the 3–6 month fixture. |
| How to express "if over 40 or family history" | Two APPLIES_WHEN edges read as AND | Wrong for a 35-year-old with a family history (fixture 04, Q-W16-04d). CNF via `conditionGroup` + `negated` on the edge. |
| "every 6 months, or every 3 months for groups" | One step with two cadences | Loses which condition selects which cadence; two CONDITIONAL steps + `MUTUALLY_EXCLUSIVE_WITH` + negated constraints evaluate correctly and report UNKNOWN when a fact is missing (Q-W16-04c). |
| Repetition | Self or cyclic `DEPENDS_ON` | Makes the DAG cyclic; indistinguishable from an authoring error (V-528p catches it; fixture 03 negative). |
| Edition per raw page change | One edition per Wayback digest | The CDX listing shows 37 distinct raw digests for the Blueprint page between 2026-01-24 and 2026-10-02; most are template/product-widget churn. `payloadHash` over the canonicalized protocol payload (`W16-CANON-1`) is the edition trigger. |
| Third-party reported change | Mint an edition | Forbidden implication; NAD.com's "NMN or NR 500 mg (6x/week)" disagrees with the owner page's "NR (450 mg) or NMN (500 mg)" and neither owner capture mentions rapamycin, lithium or NDGA. Kept as Assertions with asserter NAD.com (fixture 02). |
| Step order on the step node | `orderIndex` property on ProtocolStep | protocols.io V.1 step "Centrifuge" is step 1; in V.2 it is step 2 after a new mixing step. Order on the edge keeps steps shareable. |
| Authors as a property (`authorName`) | Keep live string | protocols.io V.2 adds "Asian Immune Diversity Atlas (AIDA)" to the V.1 author list; authorship is per edition and must be attributable: Assertion `AUTHORED_PROTOCOL_EDITION`. |
| Private observations labelled `Observation` | RBAC on a shared label | Rejected in round 0008 (fail-open DENY, Enterprise only); leak probe fixture 07 fails V-113/V-520/V-521/V-524 as required. |
| ProtocolStep as VersionedState | Re-archetype steps | Kernel change without a failing case: Entity + `payloadHash` + copy-on-write validators answer every CQ. Not requested. |

## 4. Smallest recommended model

The SDL fragment adds **no new node type** beyond the catalog's ten; it adds fields that a real source forced (each cited in the CQ matrix): bounded schedule ranges, cycles, `repeatUntilText`, `speechAct`, `changeProvenance`, `sourceVersionDate`, canonicalization/alignment versions, constraint thresholds, `conditionGroup`/`negated`, dependency lags, dose range/basis/route/verbatim text, target bounds, rule text and policy uid, and one derived relationship (`HAS_CURRENT_PROTOCOL_STEP`) that D-004 requires. Candidates kept **out** of the fragment (model cards §5): `StepParameter` (centrifuge speed/temperature), an "exactly one of" choice group, a `MeasurementPlan`→step link, plan/rule lineage keys, and a subprotocol-execution step wrapper.

## 5. Mandatory protocol cases: where each is represented

| Case (handoff §6) | Representation | Fixture |
|---|---|---|
| Definitions and versioned editions | Protocol + ProtocolEdition + HAS_PROTOCOL_EDITION (asserted, EXCLUSIVE) | 01, 02, 13 |
| Component/subprotocol relations with edition binding | INCLUDES_PROTOCOL (PINNED) vs HAS_SUBPROTOCOL (FLOATING, RESOLVED_AS_OF) | 13 |
| Ordered steps, dependency kinds | HAS_PROTOCOL_STEP.orderIndex; DEPENDS_ON.dependencyKind/lag | 01, 03, 11 |
| Parallel vs sequential | CONCURRENT_WITH vs ordering kinds | 05 |
| Repetition/cycles | cadence/occurrence/total/cycle ranges, repeatUntilText | 03, 09 |
| Cadence/time windows with bounded ranges | cadenceIntervalMin/Max, cadenceMin/MaxDays, lagMin/Max | 10, 03 |
| Conditional applicability/branches | HAS_CONSTRAINT CNF (conditionGroup, negated) + MUTUALLY_EXCLUSIVE_WITH branches | 04 |
| Optional vs required | requirementLevel/requirementBasis; speechAct | 06, 05 |
| Dose/duration/route/basis | StepDoseProperties | 02, 12 |
| Measurement plans | MeasurementPlan | 10 |
| Thresholds/triggers/stop/review | ProtocolAdjustmentRule; CONTRAINDICATED_WHEN constraints | 11, 05 |
| Source-stated targets/goals | Target (bounded), FunctionalGoal | 03 |
| Public authors/roles/competencies | Assertions AUTHORED_PROTOCOL(_EDITION), REQUIRES_PERFORMER_ROLE | 09, 02 |
| Devices/instruments, products/materials | EMPLOYS → StepInstrumentTarget; USES → StepSubstanceTarget (pinned/floating) | 08, 01 |
| Activities and evidence links | Assertion CITES_EVIDENCE_FOR_STEP; WAS_GENERATED_BY alignment Activity (stepKeyAlignmentVersion) | 09 |
| Definition ≠ execution; ProtocolEdition ≠ ProtocolVersion; public Observation ≠ PersonalMeasurement | leak probe; seam W16-SR-10 | 07 |
| No adherence from adoption; no private dose change from public trigger | V-534p; rules have no person edges | 06, 11 |
