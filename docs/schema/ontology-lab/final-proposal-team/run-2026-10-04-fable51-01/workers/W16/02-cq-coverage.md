# W16 CQ coverage matrix

Priority and answerability are copied from `competency-questions.md` (section 2 table and the round 0008/0009 tables). Candidate CQs are labelled `CQ-PR-Cnn` and are **candidates**, not existing ids. Query ids `Q-W16-nn` are in `fixtures/*.cypher`, with executed outcomes in `06-fixtures-and-queries.md`.

## 1. Existing CQs

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Node / property / edge / edge property | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| **CQ-PR-01** (Foundational, Q) What changed between two versions, and is each change source-versioned, a snapshot diff, or third-party reported? | "protocols.io PBMC V.1→V.2 (SOURCE_VERSIONED): `centrifuge-cpt-tube`, `aspirate-plasma-half`, `collect-cells` MODIFIED and reordered; `mix-by-inversion`, `spin-down-collected` ADDED_OR_NOT_CAPTURED (V.1 capture partial). Blueprint (SNAPSHOT_DIFF, observed 2026-01-24 vs 2026-10-04): creatine 2.5→5 g, tadalafil 2.5→5 mg/day, acarbose 200 mg/day → 200 mg twice daily. NAD.com (THIRD_PARTY_REPORTED): rapamycin ended 2024 (YEAR)." | source label vs observed hash change vs third-party assertion; partial capture vs absence; unobserved interval unknown | snapshot per observed state with `captureCompleteness`; owner's version label when present; asserter of third-party claims | `ProtocolEdition.{payloadHash, editionLabel, changeProvenance, sourceVersionDate}`, `HAS_PROTOCOL_EDITION` (AssertedEdgeProperties), `ProtocolStep.{stepKey, payloadHash}`, `HAS_PROTOCOL_STEP.orderIndex`, Assertions with `ASSERTED_BY` | Q-W16-01 (diff), Q-W16-02b (dose by stepKey), Q-W16-02c (labelled history); QS-2b for episodes | inventing transitions between unobserved states; treating a news report as an edition (V-530p); reading reorder as change; reading a missing step in a partial capture as ADDED |
| **CQ-PR-02** (Foundational, A for source-stated) Which steps are essential, conditional (on what), optional or not stated; which depend on others and how? | "`plasma-lithium-after-year1-intensive` CONDITIONAL: applies when ANY of six groups; `…-standard` applies when NONE; the two are MUTUALLY_EXCLUSIVE; both REQUIRE_PRIOR_COMPLETION of `plasma-lithium-year1`. `plasma-lithium-titration-checks` REQUIRES_PRIOR_COMPLETION of `start-lithium` with lag 1..1 WEEK." | stated vs editorial; constraint role; AND vs OR; dependency kind; ordering vs concurrency vs alternative | protocol text with locator | `requirementLevel`, `requirementBasis`, `HAS_CONSTRAINT {constraintRole, conditionGroup, negated}`, `Constraint.{constraintKind, comparator, thresholdValue, thresholdUnitCode}`, `DEPENDS_ON {dependencyKind, lagMin, lagMax, lagUnit, dependencyBasis}` | Q-W16-03, Q-W16-04a, Q-W16-05a, Q-W16-11a, Q-W16-12 | `isOptional:false` read as essential; OR read as AND; repetition encoded as a loop (V-528p); alternatives read as both required (V-531p) |
| **CQ-PR-03** (Expansion, Q) What is missing before a person can evaluate the protocol? | "Gate facts for the NICE year-2 branches: 5 TEXT_ONLY facts (older people, interacting drugs, renal/thyroid risk, symptom control, adherence) and 1 STRUCTURED fact (last plasma lithium ≥ 0.8 mmol/L via Metric). With two facts undeclared both branches are UNKNOWN_MISSING_FACT." | missing fact (UNKNOWN) vs fact false; text-only vs structured condition; `notReportedFields` vs not extracted | edition structure; private facts stay private | `Constraint` + `BASED_ON`; `ProtocolStep.notReportedFields`; `MeasurementPlan.{requiredForEvaluation, maxBaselineAgeDays}` | Q-W16-04b/c/d/e (three-valued CNF), Q-W16-10b | collapsing unknown to false (INV-007); an evaluation that silently drops a condition |
| **CQ-PR-04** (Expansion, A for source triggers) Which observations should trigger review, pausing, stopping or clinician contact? | "Rule `nice-cg185-egfr-falling`: TREND on eGFR → REVIEW, modifies `plasma-lithium-year1` (STATED_BY_SOURCE)." | source rule vs BellLabs policy rule (INTERNAL + PolicyVersion); trigger vs condition present | rule text with locator; PolicyVersion for policy rules | `ProtocolAdjustmentRule.{triggerKind, comparator, thresholdValue, thresholdUnitCode, triggerAction, ruleBasis, ruleText, policyVersionUid}`, `RULE_TRIGGERED_BY`, `MODIFIES_STEP`, `MODIFIES_TARGET`, `HAS_CONSTRAINT` on rules | Q-W16-11b | policy rule presented as the source's (V-533p); OUTSIDE_REFERENCE_RANGE read as a condition (V-536p) |
| **CQ-PR-05** (Foundational, A) Which public edition did a person adopt, with which deviations? | Shared part only: "edition uid `hu:protocol-edition:…` with stepKeys"; the adoption and deviations are answered in the private store | public edition vs private adoption | private store (W23) | shared: `ProtocolEdition.uid`, `ProtocolStep.stepKey` as stable reference keys; nothing private | fixture 07 (leak probe), Q-W16-07b | public protocol node gaining personal edges (V-113, V-534p) |
| **CQ-PR-06** (Research frontier, Q) What evidence supports each step versus the protocol as a whole? | "`fmd-5-day-monthly` cites PMID 28202779 (not yet assessed for applicability); `sauna-weekly` cites nothing; the edition has NO_PROTOCOL_LEVEL_EVIDENCE." | step evidence vs protocol evidence; cited vs assessed | step-level citation Assertions; W10 applicability | Assertion `CITES_EVIDENCE_FOR_STEP` (subject ProtocolStep); `PROTOCOL_EFFECTIVE_FOR` only when not CALCULATED from steps | Q-W16-09a | component evidence transferred to the combined protocol (V-538p) |
| **CQ-PC-08** (Essential, A) Can any public query reach private-personal data? | "Zero private nodes; QS-6a from the edition reaches 8 public nodes and no private node even with probes present." | placement vs access control | validation runs | `Observation` public only; no private type in fragment | fixture 07 + V-113/V-520/V-521/V-524/V-534p | leak through Observation label, private uid on a public step, execution edge into a public edition |
| **CQ-AX-22** (Expansion, Q) Is the public version I follow the one a published result used? | "Public observation `blueprint-hscrp-after-hbot` is ABOUT edition `…2026-10-04` (attributed by RECORDS assertion); the private store compares its adopted edition uid." | edition-level vs protocol-level binding | result/observation bound to an edition | `ProtocolResult.forEditions`, `Observation.aboutEditions` (`FOR_PROTOCOL`/`ABOUT_PROTOCOL` → ProtocolEdition) | Q-W16-07b | matching on protocol name or protocol uid when versions differ |
| **CQ-RC-06** (Foundational, Q) Can constraints block rather than lower a score? | "Sauna steps blocked by any of 3 CONTRAINDICATED_WHEN constraints (one OR group): uids …" | block vs penalty; contraindication stated by protocol vs safety assertion (W17) | protocol text | `HAS_CONSTRAINT {constraintRole: CONTRAINDICATED_WHEN, conditionGroup}` | Q-W16-05c | a contraindicated step ranked rather than blocked (private snapshot keeps `blockingConstraintUids`) |

## 2. Candidate CQs (W16)

| Id | Question | Rationale / failing case | Elements | Fixture |
|---|---|---|---|---|
| CQ-PR-C01 (candidate) | When is a periodic step due, as a window, given a last occurrence? | "Blood draw, every 3 to 6 months" (Blueprint) needs a window, never a midpoint | cadence ranges, `cadenceMin/MaxDays` | 10 |
| CQ-PR-C02 (candidate) | Under which combination of facts does a branch apply, and which facts are missing? | NICE CG185 1.10.20 else-branch; Blueprint MRI disjunction | `conditionGroup`, `negated`, Constraint thresholds | 04 |
| CQ-PR-C03 (candidate) | What does the source recommend to readers versus report doing itself? | Blueprint sauna: practice daily 20 min vs "Aim for 3 to 5 sessions per week" | `ProtocolStep.speechAct` | 05 |
| CQ-PR-C04 (candidate) | Which subprotocol edition is included, pinned or resolved as-of? | live alignment row "needs a rule for which edition of a subprotocol is included" | `INCLUDES_PROTOCOL`, `HAS_SUBPROTOCOL` | 13 |
| CQ-PR-C05 (candidate) | Which material formulation does a step use at the edition's time? | Blueprint "Longevity Mix 1 scoop" floats over formulation versions | `USES` → FormulationVersion vs ProductVariant | 08 |
| CQ-PR-C06 (candidate; no SDL) | Which steps form an "exactly one of" choice? | "Either HBOT (90 min) or IHHT (42 min)" — MUTUALLY_EXCLUSIVE gives at most one; "at least one" is not representable without a choice group | candidate only | 12 (partial) |

## 3. Element index (every SDL element → CQ / invariant / ingestion failure)

| Element | Justification |
|---|---|
| Protocol (`protocolType`, `publicUrl`, search fields, `searchEmbedding`) | CQ-PR-01/05, CQ-AX-22; fulltext retrieval (D-015) |
| `Protocol.editions` / `ProtocolEdition.protocol` (HAS_PROTOCOL_EDITION) | CQ-PR-01; INV-503/505; predicateExclusivity |
| `Protocol.currentSteps` (HAS_CURRENT_PROTOCOL_STEP, derived) | D-004 compatibility for live `hasSteps` readers; V-542p |
| `Protocol.results`, `ProtocolEdition.results`, `ProtocolResult.forProtocols/forEditions` (FOR_PROTOCOL) | CQ-AX-22, CQ-PC-08 |
| ProtocolEdition `editionLabel`, `sourceVersionDate(Text)`, `changeProvenance` | CQ-PR-01; forbidden implication THIRD_PARTY→EDITION |
| `payloadCanonicalizationVersion`, `stepKeyAlignmentVersion` | ingestion failure: raw-byte churn (37 digests); OPEN-QUESTIONS P2 item 4 |
| Edition schedule summary fields, `isContinuous`, `isAsNeeded`, `requiresFasting`, `requiresMonitoring` | migration of live Protocol fields (CQ-PR-01 history in editions) |
| `ProtocolEdition.steps` (HAS_PROTOCOL_STEP, StepOrderProperties incl. `sourceStepLabel`, `sectionLabel`) | CQ-PR-01/02; D-004 |
| `constraints` (HAS_CONSTRAINT, ConstraintRoleProperties) on edition/step/rule | CQ-PR-02/03, CQ-RC-06 |
| `measurementPlans`, `adjustmentRules`, `targets`, `functionalGoals`, `therapeuticTargets` | CQ-PR-03/04; CQ-PC-01 shared references |
| `includedEditions` / `subprotocols` | CQ-PR-C04 |
| ProtocolStep `stepKey`, `payloadHash` | CQ-PR-01; V-525p/526p |
| `stepKind`, `stepKindRaw`, `stepDescription`, `speechAct` | CQ-PR-02, CQ-PR-C03; forbidden "practice report is not a recommendation" |
| `requirementLevel`, `requirementBasis`, `notReportedFields` | CQ-PR-02/03; INV-007 |
| schedule texts and range fields, cycles, `repeatUntilText`, `isAsNeeded`, `timeOfDay`, `daysOfWeek` | CQ-PR-02, CQ-PR-C01; mandatory cases (repetition, cycles, windows) |
| `dependsOn` (DEPENDS_ON, StepDependencyProperties) | CQ-PR-02; V-527p/528p/531p |
| `uses` (USES, StepDoseProperties) | CQ-PR-01 (dose diffs), CQ-PR-C05; contract A11 dose/basis; INV-307 |
| `employs` (EMPLOYS) | mandatory case: device/assay change; INV-301 linkage |
| `targets` (TARGETS) on steps/editions | stated purpose (live), never efficacy |
| Constraint fields, `basedOn` (BASED_ON) | CQ-PR-02/03 |
| MeasurementPlan fields, `tracksMetrics` | CQ-PR-03, CQ-PR-C01 |
| ProtocolAdjustmentRule fields and edges | CQ-PR-04; V-533p, V-540p |
| Target fields, `forMetrics` | CQ-PR-03/04 |
| FunctionalGoal, `operationalizedBy` | CQ-PC-01 (private goals reference by uid) |
| Observation fields (DiagnosticResult contract) and edges | CQ-PC-08, CQ-AX-22; INV-301; V-524, V-532p, V-536p |
| ProtocolResult fields and edges, `mentions` | CQ-PC-08; CQ-PR-06 (as reported) |
| Enums (17) | each used by a field above |
| Unions (5) | ranges of USES, EMPLOYS, TARGETS, BASED_ON, MENTIONS |
