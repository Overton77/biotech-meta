# W16 model cards

Common to every W16 node (contract B2): `id: ID! @id` (opaque segment of uid), `uid: String!` (`hu:<token>:<opaque>`), `name` (nullable, display only, D-013), `description`, `mongoResearchRunId` (internal operational lineage), `createdAt`/`updatedAt` (`@timestamp`), `privacyClass` (PUBLIC default; INTERNAL for BellLabs policy rules; no private value exists), `maturity`, `schemaVersion`, plus the archetype type field (`entityType`, `stateType` or `artifactType`). Kind legend: **A** asserted by a source (through the edition's authorizing Assertion), **O** observed (capture), **C** calculated, **I** inferred/editorial, **Op** operational. "Edition payload" means immutable after the node is attached to an edition (service-enforced copy-on-write; a change makes a new node). Maturity is PROVISIONAL for catalog types (module `protocols` is provisional) unless noted.

## 1. Node cards

### Protocol — Entity — labels `["Protocol","Entity"]` — token `protocol` (registered)
Enduring identity of a public protocol/workflow definition. Not a version, not a study protocol document, not anyone's use. Identity key: `uid` only; `publicUrl`/`name` are aliases for resolution (W00 `Identifier` for DOIs such as protocols.io lineage DOIs).

| Property | Type / null | Meaning; value states | Privacy | Temporal | Kind |
|---|---|---|---|---|---|
| protocolType | ProtocolType / null | classification; null = not classified | public | mutable classification (Op) | I |
| publicUrl | String / null | display URL; never identity | public | mutable | O |
| searchText, searchFields, embeddingModel, embeddingDimensions, searchEmbedding | derived | regenerable search projection (INV-107) | public | regenerated | C |

Edges: `editions` OUT HAS_PROTOCOL_EDITION (asserted, EXCLUSIVE, one_or_more over time); `currentSteps` OUT HAS_CURRENT_PROTOCOL_STEP (derived, read-only, rule `protocol-current-steps-v1`: steps of the edition whose episode has `recordedTo` null and `validTo` null or in the future; regenerated on each attachment; V-542p); `results` IN FOR_PROTOCOL (asserted). Removed live fields: see migration-map.yaml.

### ProtocolEdition — VersionedState — `["ProtocolEdition","VersionedState"]` — token `protocol-edition` (registered)
Immutable structured content of one observed or published state. New node iff canonical `payloadHash` changes. Identity key: `uid`; dedupe key (protocol uid, payloadHash, payloadCanonicalizationVersion).

| Property | Type / null | Meaning; value states | Kind |
|---|---|---|---|
| stateType | String! | "ProtocolEdition" | Op |
| payloadHash | String! | `sha256:<hex>` over W16-CANON-1 JSON (steps by stepKey+payloadHash, constraints, plans, rules, targets, goals, inclusions; excludes order-free display text, createdAt, capture metadata) | C |
| effectiveFrom/effectiveTo | DateTime / null | source-stated applicability of the content (rare); null = not stated | A |
| editionLabel | String / null | source's own label ("V.2", "Last updated: 02 September 2025"); null = source shows none (never invented) | O |
| sourceVersionDate / sourceVersionDateText | Date / String, null | printed version/update date; a byline that does not change with content is recorded in text only | O |
| changeProvenance | ProtocolChangeProvenance! | SOURCE_VERSIONED or SNAPSHOT_DIFF (V-530p) | Op |
| payloadCanonicalizationVersion, stepKeyAlignmentVersion | String / null | method versions of hashing and stepKey alignment (Activity methodVersion) | Op |
| scheduleText … requiresMonitoring | as SDL | edition-level schedule summary (live Protocol fields moved here); ranges; null = not stated | A |

Edges (all OUT unless noted): `protocol` IN HAS_PROTOCOL_EDITION; `steps` HAS_PROTOCOL_STEP (structural, StepOrderProperties); `constraints` HAS_CONSTRAINT; `measurementPlans` HAS_MEASUREMENT_PLAN; `adjustmentRules` HAS_ADJUSTMENT_RULE; `functionalGoals` HAS_FUNCTIONAL_GOAL (asserted); `targets` HAS_TARGET; `therapeuticTargets` TARGETS; `includedEditions` INCLUDES_PROTOCOL (PINNED); `subprotocols` HAS_SUBPROTOCOL (FLOATING); `results` IN FOR_PROTOCOL. Temporal: validity lives on the HAS_PROTOCOL_EDITION episode (asserted_edge profile; valid bounds equal the Assertion's, INV-503); `recordedFrom` is commit time.

### ProtocolStep — Entity (catalog), immutable payload — `["ProtocolStep","Entity"]` — token `protocol-step` (registered)
One step of an edition. Lineage key `stepKey` (per protocol); payload key `payloadHash`. A step node is shared by consecutive editions only together with its dependency closure (V-527p).

| Property | Type / null | Meaning; value states | Kind |
|---|---|---|---|
| stepKey | String! | per-protocol slug assigned by the alignment Activity (W16-STEPKEY-1, §6); stable across dose/timing/wording changes; new when the action or the primary material/instrument changes | Op (reviewed) |
| payloadHash | String! | sha256 over properties + outgoing USES/EMPLOYS/HAS_CONSTRAINT/DEPENDS_ON (targets by stepKey); excludes orderIndex | C |
| stepKind, stepKindRaw, stepDescription | enum/String | action kind; raw label preserved | A |
| speechAct | SpeechAct (W00) / null | STATES, REPORTS_PRACTICE, RECOMMENDS, CAUTIONS…; null = not classified | I (classification of source text) |
| requirementLevel | RequirementLevel! | NOT_STATED instead of null | A |
| requirementBasis | RequirementBasis! | STATED_BY_SOURCE / EDITORIAL_INFERENCE / NOT_STATED | Op |
| notReportedFields | [String!] / null | fields the source explicitly leaves unstated (≠ not extracted) | O |
| scheduleText, frequencyText, timingText, durationText | String / null | verbatim; always kept when normalization is incomplete | O |
| schedulePattern, cadenceUnit, cadenceIntervalMin/Max | enum / Int | bounded interval; both bounds when the source gives a range | A |
| occurrencesPerPeriodMin/Max + occurrencePeriodUnit | Int / enum | "3 to 5 per WEEK" | A |
| totalOccurrencesMin/Max | Int | "60 sessions" | A |
| timeOfDay, daysOfWeek | enum | anchors; clock times stay in timingText | A |
| durationMinutesMin/Max | Int | per occurrence (minutes) | A |
| durationDaysMin/Max | Int | whole course (days); "at least 4 weeks" = 28..null | A |
| cycleLengthDaysMin/Max, cycleActiveDaysMin/Max, cycleCountMin/Max | Int | explicit cycles | A |
| repeatUntilText | String / null | verbatim termination ("weekly until the levels are stable") | A |
| isAsNeeded | Boolean / null | PRN; null = not stated | A |

Units: day/minute counts are integers named by unit; months→days conversion only on MeasurementPlan (W16-CADENCE-1: min = 30×months, max = ceil(30.4375×months)). Edges: `editions` IN HAS_PROTOCOL_STEP; `dependsOn` DEPENDS_ON; `constraints` HAS_CONSTRAINT; `uses` USES (StepDoseProperties); `employs` EMPLOYS; `targets` TARGETS. Privacy: public.

### Constraint — Entity — `["Constraint","Entity"]` — token `constraint` (registered)
Reusable public condition stated by a protocol. Properties: `constraintKind` (ConstraintKind, nullable only for unclassified migrated rows), `constraintText` (verbatim span), `comparator` + `thresholdValue` + `thresholdUnitCode` (UCUM; V-541p requires comparator and unit with a value). Edge `basedOn` BASED_ON → ConstraintBasisTarget (structural). Role, combination and negation live on HAS_CONSTRAINT. Kind A. Not a person's condition; not a W17 contraindication assertion.

### MeasurementPlan — Entity — `["MeasurementPlan","Entity"]` — token `measurement-plan` (**requested**, W16-SR-01)
`planTiming` (BASELINE/DURING/FOLLOW_UP/PERIODIC), `requiredForEvaluation` (Boolean; null = not stated), `maxBaselineAgeDays` (Int; source or BellLabs default, Op), `cadenceMinDays`/`cadenceMaxDays` (Int range; W16-CADENCE-1), `scheduleText` (verbatim). Edge `tracksMetrics` TRACKS_METRIC → Metric. Edition payload.

### ProtocolAdjustmentRule — Entity — `["ProtocolAdjustmentRule","Entity"]` — token `protocol-rule` (registered fixture token; W16-SR-01 asks to bind it to this label)
`triggerKind`, `comparator`, `thresholdValue`, `thresholdUnitCode`, `triggerAction`, `ruleBasis`, `ruleText` (verbatim), `policyVersionUid` (String; required iff BELLLABS_SAFETY_POLICY; then privacyClass INTERNAL; V-533p). Edges: `triggeredByMetrics` RULE_TRIGGERED_BY → Metric; `modifiesSteps` MODIFIES_STEP → ProtocolStep (same edition, V-540p); `modifiesTargets` MODIFIES_TARGET → Target; `constraints` HAS_CONSTRAINT (replaces live REQUIRES_CONDITION). Kind A (source) or Op (policy). Never a decision about a person.

### Target — Entity — `["Target","Entity"]` — token `target` (**requested**)
`targetType` (String), `targetText` (verbatim), `lowerBound`/`upperBound` (Float, range), `unitCode` (UCUM), `comparator` (one-sided). Edge `forMetrics` FOR_METRIC → Metric. Kind A. Not a reference interval.

### FunctionalGoal — Entity — `["FunctionalGoal","Entity"]` — token `functional-goal` (registered)
`goalType` (String). Edge `operationalizedBy` OPERATIONALIZED_BY → Target (structural). Public concept referenced by private goals by uid.

### Observation — InformationArtifact, implements `DiagnosticResult` (W07) — `["Observation","InformationArtifact"]` — token `observation` (**requested**)

| Property | Type / null | Meaning | Kind |
|---|---|---|---|
| artifactType | String! | "Observation" | Op |
| publishedAt, observedAt, reportedAt | DateTime / null | publication; when the observed state held; when reported (DiagnosticResult) | O |
| contentHash | String / null | over the captured value record | C |
| observationType | String / null | PUBLISHED_SELF_REPORT, PROTOCOL_RESULT_AGGREGATE… (vocabulary candidate) | Op |
| observedPopulation | String / null | public person/population scope as stated; never a private user | A |
| resultKind | DiagnosticResultKind | MEASURED / CALCULATED / INFERRED | A |
| valueNumber, valueString, unitCode, valueText | Float/String | value as published; `valueText` verbatim ("hsCRP below detectable levels") | A |
| valueStatus | ReportedStatus (assumed W07 type) | REPORTED / NOT_REPORTED / NOT_APPLICABLE | A |

Edges: MEASURES_METRIC, PART_OF_PLAN, FROM_LAB_TEST, FROM_DEVICE, PRODUCED_BY_ASSAY_VERSION, COMPUTED_BY_ALGORITHM_VERSION, INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION (structural), ABOUT_CONDITION (asserted), ABOUT_PROTOCOL (→ Protocol or ProtocolEdition), `recordedBy` IN RECORDS (asserted), `includedInResults` IN INCLUDES_OBSERVATION. Attribution required (V-532p). Never co-labelled PersonalMeasurement (V-524).

### ProtocolResult — InformationArtifact — `["ProtocolResult","InformationArtifact"]` — token `protocol-result` (**requested**)
`resultSummary` + archetype fields. Edges: `forProtocols`/`forEditions` FOR_PROTOCOL (asserted); `includesObservations` INCLUDES_OBSERVATION; `claimsOutcomes` CLAIMS_OUTCOME (asserted; a claim, W10 assesses); `mentions` MENTIONS (structural extraction aid); `postedBy` IN POSTS_RESULT (asserted). Never evidence of efficacy; never a private outcome.

## 2. Relationship cards

Class per catalog `relationshipClasses`. Cardinality is enforced by validation/operations, not SDL.

| Type | Domain → Range | Dir | Card. | Class | Properties | Notes |
|---|---|---|---|---|---|---|
| HAS_PROTOCOL_EDITION | Protocol → ProtocolEdition | OUT | 1..n over time; EXCLUSIVE per subject | asserted | AssertedEdgeProperties | V-508/509/539p; one edge per recorded episode |
| HAS_CURRENT_PROTOCOL_STEP | Protocol → ProtocolStep | OUT | many | derived (ruleOnly requested) | DerivedEdgeProperties | D-004 projection; read-only in API |
| HAS_PROTOCOL_STEP | ProtocolEdition → ProtocolStep | OUT | many | structural | StepOrderProperties | D-004 |
| DEPENDS_ON | ProtocolStep → ProtocolStep | OUT | many | structural | StepDependencyProperties | V-527p/528p/531p |
| HAS_CONSTRAINT | ProtocolEdition \| ProtocolStep \| ProtocolAdjustmentRule → Constraint | OUT | many | structural | ConstraintRoleProperties | domain extended to rules (decision W16-D07) |
| BASED_ON | Constraint → ConstraintBasisTarget | OUT | 0..1 typical | structural | StructuralEdgeProperties | catalog range |
| HAS_MEASUREMENT_PLAN | ProtocolEdition → MeasurementPlan | OUT | many | structural | StructuralEdgeProperties | |
| TRACKS_METRIC | MeasurementPlan → Metric | OUT | many | structural | StructuralEdgeProperties | |
| HAS_ADJUSTMENT_RULE | ProtocolEdition → ProtocolAdjustmentRule | OUT | many | structural | StructuralEdgeProperties | |
| RULE_TRIGGERED_BY | ProtocolAdjustmentRule → Metric | OUT | many | structural | StructuralEdgeProperties | live TRIGGERED_BY renamed (W10 keeps TRIGGERED_BY) |
| MODIFIES_STEP | ProtocolAdjustmentRule → ProtocolStep | OUT | many | structural | StructuralEdgeProperties | V-540p |
| MODIFIES_TARGET | ProtocolAdjustmentRule → Target | OUT | many | structural | StructuralEdgeProperties | |
| HAS_FUNCTIONAL_GOAL | ProtocolEdition → FunctionalGoal | OUT | many | asserted | AssertedEdgeProperties | catalog asserted |
| HAS_TARGET | ProtocolEdition → Target | OUT | many | structural | StructuralEdgeProperties | was Protocol → Target |
| TARGETS | ProtocolEdition \| ProtocolStep → TherapeuticTargetTarget | OUT | many | structural | StructuralEdgeProperties | stated purpose; never efficacy |
| INCLUDES_PROTOCOL | ProtocolEdition → ProtocolEdition | OUT | many | structural | StructuralEdgeProperties | PINNED binding |
| HAS_SUBPROTOCOL | ProtocolEdition → Protocol | OUT | many | structural | StructuralEdgeProperties | FLOATING; resolved as-of (Q-W16-13) |
| USES | ProtocolStep → StepSubstanceTarget | OUT | many | structural | StepDoseProperties | declared dose; FormulationVersion target = pinned |
| EMPLOYS | ProtocolStep → StepInstrumentTarget | OUT | many | structural | StructuralEdgeProperties | |
| FOR_METRIC | Target → Metric | OUT | 0..1 | structural | StructuralEdgeProperties | type name shared with W07 (ReferenceIntervalVersion → Metric), same meaning "is about metric" |
| OPERATIONALIZED_BY | FunctionalGoal → Target | OUT | many | structural | StructuralEdgeProperties | |
| PART_OF_PLAN | Observation → MeasurementPlan | OUT | many | structural | StructuralEdgeProperties | |
| FROM_LAB_TEST | Observation → LabTest | OUT | 0..1 | structural | StructuralEdgeProperties | |
| FROM_DEVICE | Observation → Device | OUT | 0..1 | structural | StructuralEdgeProperties | |
| MEASURES_METRIC, PRODUCED_BY_ASSAY_VERSION, COMPUTED_BY_ALGORITHM_VERSION, INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION | Observation → W07 types | OUT | 0..1 | structural | StructuralEdgeProperties | W07-owned semantics (DiagnosticResult contract) |
| ABOUT_CONDITION | Observation → Condition | OUT | many | asserted | AssertedEdgeProperties | V-536p |
| ABOUT_PROTOCOL | Observation → Protocol \| ProtocolEdition | OUT | many | structural | StructuralEdgeProperties | two GraphQL fields, one type |
| RECORDS | Person → Observation | OUT (from Person) | 0..1 | asserted | AssertedEdgeProperties | public persons only (CL-018) |
| INCLUDES_OBSERVATION | ProtocolResult → Observation | OUT | many | structural | StructuralEdgeProperties | |
| FOR_PROTOCOL | ProtocolResult → Protocol \| ProtocolEdition | OUT | 1 | asserted | AssertedEdgeProperties | |
| CLAIMS_OUTCOME | ProtocolResult → Outcome | OUT | many | asserted | AssertedEdgeProperties | |
| MENTIONS | ProtocolResult → ProtocolResultMentionTarget | OUT | many | structural | StructuralEdgeProperties | type semantics W00/W20 (seam W16-SR-18) |
| POSTS_RESULT | Person → ProtocolResult | OUT (from Person) | 0..1 | asserted | AssertedEdgeProperties | public persons only |

Retired live relationship types: `HAS_STEP` (from Protocol), `TRIGGERED_BY` (from rule), `REQUIRES_CONDITION`, `COMPARED_TO_REFERENCE`, `SUPPORTED_BY` (ProtocolResult → ProvenanceSource).

## 3. Relationship-property types (W16)

| Type | Specializes | Added fields | Notes |
|---|---|---|---|
| StepOrderProperties | StructuralEdgeProperties | sourceStepLabel, sectionLabel | order lives on the edge |
| StepDependencyProperties | StructuralEdgeProperties | dependencyKind!, lagMin, lagMax, lagUnit, dependencyBasis | lag range null = not stated |
| ConstraintRoleProperties | StructuralEdgeProperties | constraintRole!, conditionGroup, negated | CNF; null group = singleton; null negated = false |
| StepDoseProperties | StructuralEdgeProperties | quantity, quantityMax, unitCode, quantityBasis, massBasis, amountReferent, route, verbatimDoseText, standardizedToText | declared dose; V-529p/V-537p; never intake |

## 4. Enums and unions (owner W16)

| Enum | Values | Origin |
|---|---|---|
| ProtocolType, SchedulePattern, CadenceUnit, TimeOfDay, DayOfWeek, ProtocolStepType | live values unchanged | live |
| RequirementLevel, RequirementBasis, StepDependencyKind, ConstraintRole, ConstraintKind, MeasurementPlanTiming, ReviewTriggerKind, ThresholdComparator, ReviewTriggerAction, ReviewRuleBasis, ProtocolChangeProvenance | catalog `protocols.enums` values unchanged | catalog/delta |

Requested values (ledger, not in fragment): CadenceUnit YEAR, MINUTE (W16-SR-07); ConstraintRole REPEAT_UNTIL (W16-SR-08).

| Union | Members | Change from live |
|---|---|---|
| StepSubstanceTarget | IngredientMaterial, ChemicalSubstance, ChemicalForm, Product, ProductVariant, FormulationVersion, FoodItem, FoodProduct | renamed; Compound/CompoundForm out (D-002) |
| StepInstrumentTarget | Device, LabTest, AssayVersion, ToolOrInstrument, Exposure | + AssayVersion, ToolOrInstrument |
| TherapeuticTargetTarget | Condition, Outcome, Mechanism | renamed |
| ConstraintBasisTarget | Condition, Biomarker, LabTest, Metric | renamed |
| ProtocolResultMentionTarget | ChemicalSubstance, IngredientMaterial, Product, ProductVariant, Device, Condition, Treatment, Procedure, Lifestyle, SafetySignal, AdverseEffect | renamed; Compound → ChemicalSubstance |

## 5. Candidates (not in the fragment)

| Candidate | Need | Why not now |
|---|---|---|
| StepParameter (named numeric parameters: rcf 1500, 20 °C, 1500–1800 rpm) | protocols.io V.1 → V.2 parameter changes | only lab SOPs need it; no existing CQ; kept in `stepDescription`; candidate CQ-PR-C07 if lab protocols enter scope |
| Choice group "exactly one of" | "Either HBOT or IHHT" | CQ-PR-C06 candidate; MUTUALLY_EXCLUSIVE_WITH covers "at most one" |
| MeasurementPlan → ProtocolStep link (REALIZED_BY_STEP) | blood-draw step vs blood-draw plan | no CQ requires the join; both carry the cadence |
| planKey / ruleKey lineage keys | diffing plans/rules across editions | CQ-PR-01 asks for steps; edition payloadHash covers plans/rules |
| Subprotocol execution wrapper step | "repeat the sleep protocol nightly" | no public source found requiring it |
| Device/firmware versions | instrument model change | W08 owns DeviceModel/FirmwareVersion candidates |

## 6. stepKey assignment rule (W16-STEPKEY-1; answers OPEN-QUESTIONS P2 item 4 provisionally)

1. Key = slug of (action kind, primary material/instrument/metric identity, distinguishing qualifier), e.g. `tadalafil-daily`, `plasma-lithium-year1`, `centrifuge-cpt-tube`. Never the step number, never display text.
2. Keep the key when dose, timing, wording, order, instrument model or requirement level change (fixtures 01, 02, 08 → MODIFIED).
3. New key when the action or the primary material changes (NR vs NMN are two keys and alternatives), when a step splits/merges (old keys REMOVED, new ADDED), or when a reviewer cannot align (prefer ADDED+REMOVED to a false MODIFIED).
4. The same step printed in two sections of one page (Blueprint "My Rx stack" and "Rx / Prescriptions") is one step with several locators; conflicting values ("200 mg (twice daily)" vs "400 mg daily") are reconciled with explicit basis or kept as separate Assertions.
5. Alignment runs as an Activity (ActivityKind EXTRACTION or RESOLUTION) whose method version is stored on the edition (`stepKeyAlignmentVersion`); manual review is an Adjudication.
