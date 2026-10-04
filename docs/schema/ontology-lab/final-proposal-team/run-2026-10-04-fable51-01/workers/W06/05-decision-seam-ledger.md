# W06 decision, objection and seam ledger

The status of each decision means:

- **ACCEPTED-FOR-PROPOSAL**: in the fragment, backed by a fixture.
- **PROPOSED**: needs another owner or Fable.
- **UNRESOLVED**: open, with a closure criterion.
- **DEFERRED**: a scope candidate.

These are W06's decisions only; no other owner has agreed to any of them.

## Decisions

| Id | Decision | Evidence | Alternatives rejected | Status |
|---|---|---|---|---|
| D-W06-01 | `Treatment` is an Entity **concept**, distinct from W09 `StudyIntervention` and W04 `Product`. One drug name gives three uids. | S1, S2, S6; fixture 01, Q-01 | A1 (Treatment = Product), A3 (drop Treatment) | ACCEPTED-FOR-PROPOSAL |
| D-W06-02 | `Procedure` is a **definition**. Performances are not modeled, and there is no shared patient or care-record graph. A reported session count is a literal assertion. | architecture §15; S10; fixture 03 | A4 (`ProcedurePerformance`) | ACCEPTED-FOR-PROPOSAL |
| D-W06-03 | Modality is a list (`modalities`). `modality` is a read-only legacy projection. COMBINATION is narrowed and needs at least two components. | S2 ("…gene therapy" and "a cellular gene therapy"); fixture 01/02, Q-06, V-W06-05 | A5 | ACCEPTED-FOR-PROPOSAL |
| D-W06-04 | Registry InterventionType is a W09 field and is never mapped onto modality. | S6 (BIOLOGICAL), S7 (GENETIC); Q-06 | A9 | PROPOSED (W06-SR-03) |
| D-W06-05 | `TARGETS_CONDITION` is source-stated **intent**, with `intentKind` and `intentBasis`. It is never a result or an approved indication. | S2 vs S3 (label restatement vs OOPD approved indication) | Using the edge as an indication record | ACCEPTED-FOR-PROPOSAL |
| D-W06-06 | `developmentStage` and `orphanDrugDesignation` are read-only display projections that name their sources. Approval wording must be backed by an ACCEPTED W13 APPROVAL reachable through `ADMINISTERED_PRODUCT` (V-W06-01, the V-322 pattern). | S3, S4, S5; fixtures 04/05; V-W06-01..03 | A2 (stage as concept state); dropping the fields (breaks the live API) | ACCEPTED-FOR-PROPOSAL |
| D-W06-07 | A concept reaches regulatory states **only through Products**. Treatment is not in the W13 subject ranges. | S4 + S5 (two sponsors, one generic concept) | A7 | PROPOSED (W06-SR-05a) |
| D-W06-08 | `USES_COMPONENT{ADMINISTERED_PRODUCT}` is navigation only. With W09's `FOLLOWS_INTERVENTION_DEFINITION` it never licenses evidence applicability to the product (INV-201). | Q-08; negative N3 is caught by V-W06-04 and baseline V-201 | Deriving study-to-product edges through the concept | ACCEPTED-FOR-PROPOSAL; FI registration PROPOSED (W06-SR-10) |
| D-W06-09 | A concept component needs an authoritative concept-level source. A trial's co-intervention stays on the `StudyIntervention`. | S2 (apheresis on the label) vs S7 (HORIZON plasmapheresis); V-W06-06 | A10 | ACCEPTED-FOR-PROPOSAL |
| D-W06-10 | Classification codes are `Identifier` records on `Procedure` and never establish identity. | S11 (Pheresis of Plasma, Single/Multiple); Q-07; V-W06-07 | Keying Procedure on ICD-10-PCS | ACCEPTED-FOR-PROPOSAL |
| D-W06-11 | `DEVELOPS_TREATMENT`, `OFFERS_TREATMENT` and `OFFERS_PROCEDURE` stay W06 relationship types with `AssertedEdgeProperties`. W01 registers the predicates. | Q-05 (developer NOT_RECORDED although sponsor and manufacturer roles exist) | W01 owning the types; `RoleEdgeProperties` (corporate fields do not apply) | PROPOSED (W06-SR-06) |
| D-W06-12 | The study-side concept link reuses W09's candidate `FOLLOWS_INTERVENTION_DEFINITION`. W06 withdrew its own earlier proposal of separate relationship types for treatments and procedures. W06 declares inverse views on Treatment and Procedure. | fixtures 01/02; Q-02, Q-04; W09 fragment (`StudyIntervention.definitions`, `InterventionDefinitionTarget`) | Keeping only the legacy `Study.evaluates`; two W06-owned relationship types (duplicate meaning, rejected) | PROPOSED (W06-SR-03, W09 candidate CQ-ST-C02) |
| D-W06-13 | An offerer's benefit wording never creates `TARGETS_CONDITION`, and the range stays Condition-only. | S9 | A8 | ACCEPTED-FOR-PROPOSAL |
| D-W06-14 | Modality-specific properties are not added: cell source, vector, editing technology. | Expressible through components (S2); no failing CQ | A6 | DEFERRED (SC-W06-01, SC-W06-02) |
| D-W06-15 | `legacyEvidenceStrengthHint` stays on `TreatmentTargetProperties` as a migration-only hint. | live 256; INV-209 | Dropping it (loses migration data); keeping it as an assessment (violates INV-209) | PROPOSED (W06-SR-10) |
| D-W06-16 | Proposed home module: `interventions` (candidate), closing T-005 for Treatment and Procedure. | handoff §2 row; registry T-005 | Placing them in `studies_and_evidence` (practice offerings are not study facts) | PROPOSED (Fable) |

## Forbidden implications proposed by W06

Each is written as premise → conclusion that must not be drawn.

| Id | Premise → conclusion | Guard |
|---|---|---|
| FI-W06-01 | `TARGETS_CONDITION` → EFFECTIVE_FOR | Documentation and query discipline. Results are W09/W10. |
| FI-W06-02 | `TARGETS_CONDITION` (incl. REGULATORY_LABEL_RESTATEMENT) → APPROVED_FOR_INDICATION | Q-03 reads W13 only |
| FI-W06-03 | DEVELOPMENT_STAGE_TEXT → REGULATORY_STATUS | V-W06-01, V-W06-02 |
| FI-W06-04 | DESIGNATION_SCOPE → APPROVED_INDICATION (and the catalog's HAS_ORPHAN_DESIGNATION → IS_APPROVED) | V-W06-03, Q-03, Q-09 |
| FI-W06-05 | HOSTS_LISTING / LISTS_PROCEDURE → OFFERS_PROCEDURE (and → OFFERS_TREATMENT) | QS-4a/W06 (N9) |
| FI-W06-06 | OFFERS_PROCEDURE → PERFORMS_PROCEDURE | QS-4a/W06 |
| FI-W06-07 | OFFERS_TREATMENT / OFFERS_PROCEDURE → RECOMMENDS, APPROVED or EFFECTIVE | QS-4a/W06 (RECOMMENDS pair) |
| FI-W06-08 | SPONSORS_STUDY → DEVELOPS_TREATMENT | QS-4a/W06; Q-05 |
| FI-W06-09 | FOLLOWS_INTERVENTION_DEFINITION ∘ USES_COMPONENT{ADMINISTERED_PRODUCT} → EVIDENCE_APPLIES_TO_PRODUCT | V-W06-04, baseline V-201 |
| FI-W06-10 | MANUFACTURES_PRODUCT → DEVELOPS_TREATMENT | QS-4a/W06 |
| FI-W06-11 | designation SUBMITTED_BY → DEVELOPS_TREATMENT | QS-4a/W06 |
| FI-W06-12 | SHARED_CLASSIFICATION_CODE → SAME_PROCEDURE | V-W06-07 |
| FI-W06-13 | REGISTRY_INTERVENTION_TYPE → TREATMENT_MODALITY | Q-06 (reports both side by side) |
| FI-W06-14 | TRIAL_CO_INTERVENTION → CONCEPT_COMPONENT | V-W06-06 |
| FI-W06-15 | OFFERER_BENEFIT_CLAIM → TARGETS_CONDITION / RECOMMENDS | review discipline. No automatic guard: a claim and an intent edge cannot be told apart syntactically. Flagged in 08 as qualified. |

## Kernel-change requests

None. The W06 model fits the frozen kernel. W06-SR-02 (uid tokens) and W06-SR-12 (predicate registration) are registrations, not kernel changes.

## Unresolved items and closure criteria

| Item | Owner | Closure criterion |
|---|---|---|
| Registry additions (W06-SR-01) | Fable | Registry row W06 lists the three enums, and `TreatmentTargetProperties`, or Fable reassigns them. |
| uid tokens (W06-SR-02) | W00 | `treatment` and `procedure` appear in `uidTypeTokens`. |
| Concept link (W06-SR-03) | W09 | W09 promotes `FOLLOWS_INTERVENTION_DEFINITION` from candidate, with Treatment and Procedure in `InterventionDefinitionTarget`; `registryInterventionType` is already in the W09 fragment. |
| EMPLOYS → Procedure (W06-SR-04) | W16 | `StepInstrumentTarget` includes Procedure. Otherwise the fixture 03 step edge is outside the schema. |
| Ended designation without kind or date (W06-SR-05b) | W13 | A statusKind value or a documented null convention exists, and baseline V-333 accepts it. |
| FoodProduct re-pointing (W06-SR-07) | W05 | W05 confirms that the migration re-points FoodProduct component edges to the W04 Product it creates. |
| RADICAVA approval capture | W13 / future capture | Open NDA 209176 action letter or Drugs@FDA and record a reproducible locator. V-W06-01 then stops reporting `hu:treatment:edaravone-als`. |
| Which STN each OOPD approval belongs to | W13 | Open the Jan 16 2024 and Jul 1 2026 approval letters. |
