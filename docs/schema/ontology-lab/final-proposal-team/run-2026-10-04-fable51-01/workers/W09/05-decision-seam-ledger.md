# W09 decision and seam ledger

Status values:
- ACCEPTED-FOR-PROPOSAL: W09 is confident; the fragment implements it.
- PROPOSED: needs another owner or Fable.
- UNRESOLVED: open, with closure criteria.

No consensus with other workers is claimed. Seam and conflict requests are in `seam-requests.yaml`.

## Decisions

| Id | Decision | Evidence / failing case | Alternatives rejected | Status |
|---|---|---|---|---|
| W09-D01 | `Study` is identity only. Registry facts live on `RegistrationVersion`. `Study.overallStatus` and `enrollmentCount` survive only as a read-only derived cache naming its version. | INV-208, V-210; S-01 (status, enrollment and results-posted change across versions) | Keep the live fields writable (fails replay) | ACCEPTED-FOR-PROPOSAL |
| W09-D02 | Without retrievable history, a `RegistrationVersion` is keyed by `observedAt` plus whatever version keys the registry shows (`registryVersionNumber`, `lastUpdatePostedDate`); `versionDate` stays null. The attachment uses `validFromBasis OBSERVATION_ONLY`. | S-02/S-03 BLOCKED; CQ-ST-C03 | Use `observedAt` as `versionDate` (round 0002 forbids) | ACCEPTED-FOR-PROPOSAL |
| W09-D03 | GraphQL type `StudyIntervention` (D-003). Live union renamed `LegacyEvaluatedIntervention`, with successor members, reachable only via `Study.evaluates @settable(false)`. | D-003, CL-006, CL-017 | Keep `ArmIntervention` (D-003 forbids) | ACCEPTED-FOR-PROPOSAL; members depend on W09-SR-09 |
| W09-D04 | Catalog range `IngredientMaterial \| ProductVariant \| ProductLot` is written as three typed fields sharing one relationship type, not a union. | Simpler filters; no new union needed | Union `InterventionMaterialTarget` | ACCEPTED-FOR-PROPOSAL |
| W09-D05 | CANDIDATE `USES_INTERVENTION_DEVICE` → W08 `Device`. Sham is the arm's `armType`, not a different device. | NCT02582593 (S-15), fixture 04 | Device as `IngredientMaterial`; device as `ProductVariant` | PROPOSED (W09-SR-08) |
| W09-D06 | CANDIDATE `FOLLOWS_INTERVENTION_DEFINITION` → `Procedure \| Treatment \| ProtocolEdition \| Lifestyle`. | Live union's non-material members lack a successor; synthetic sauna fixture | Keep the live union writable (INV-201 risk); new W09 procedure type (duplicates W06) | PROPOSED (CQ-ST-C02, W09-SR-09) |
| W09-D07 | `InterventionComponent.quantityBasis`/`massBasis` are nullable in SDL. They are required only when `quantityStatus` is REPORTED (V-221r). | Device and NOT_REPORTED cases, fixture 04 | Keep `massBasis: MassBasis!` (0.2.0 delta), which forces a false UNSPECIFIED on devices | PROPOSED (W09-CR-02) |
| W09-D08 | Basis and ENERGIZE AE rows use `collectionMethod NOT_DESCRIBED` with verbatim `collectionMethodText`. The inherited `SYSTEMATIC` is not supported by the retrieved text. | S-07, S-19 | Keep SYSTEMATIC (overclaims); SPONTANEOUS (also a reading the text does not state) | ACCEPTED-FOR-PROPOSAL; validator impact W09-CR-01 |
| W09-D09 | A per-arm SAE zero is deduced from a study-level "no serious AEs" sentence and recorded per arm with denominators from the ITT sentence. Every AE row cites both locators. | S-07 | One study-level row (no arm; breaks RESULT_FOR_ARM exactly-one) | ACCEPTED-FOR-PROPOSAL |
| W09-D10 | A sentence that gives an arm's change magnitude with a between-arm p-value becomes two results: a WITHIN_ARM_CHANGE (estimate) and a BETWEEN_ARM (test). The placebo within-arm decline is recorded too. | S-10 ATLAS: "+12%, p = 0.027 compared with placebo"; placebo −9.8%, p = 0.008 | One BETWEEN_ARM result with estimate 12 (misstates effect size) | ACCEPTED-FOR-PROPOSAL |
| W09-D11 | `analysisKind` comes from the registered priority (earliest observed version); `comparisonKind` from the comparison named in the sentence; `statisticalConclusion` from the reported test; `multiplicityAdjusted` from the methods statement (false for ATLAS). | S-08, S-09, S-10 | Take the paper's headline as primary | ACCEPTED-FOR-PROPOSAL |
| W09-D12 | Priority stays per source (`DECLARES_OUTCOME_PRIORITY`). `OutcomeDefinition.priority` is derived from the registry declaration and names its assertion (`priorityAssertionUid`). | NCT02678611 NAD+ registry SECONDARY vs paper PRIMARY (V-223 row) | Single stored priority | ACCEPTED-FOR-PROPOSAL |
| W09-D13 | The same registered measure name listed twice with different priorities in one registry version ("Blood pressure" PRIMARY and "Blood Pressure" SECONDARY, S-01) gives two OutcomeDefinitions. They are never merged by name. | S-01 | Merge by normalized name (FI SIMILAR_NAME → SAME_IDENTITY) | ACCEPTED-FOR-PROPOSAL |
| W09-D14 | `Publication` is the work. DOI/PMID/PMCID are materialized keys plus Identifier records. `publicationKind` follows the journal's designation; the database publication type maps to the W00 `SourceRevisionEvent.revisionKind`. | S-05: PubMed "Published Erratum" for a journal "Author Correction" | Use PubMed PT as `publicationKind` (loses the journal designation) | ACCEPTED-FOR-PROPOSAL |
| W09-D15 | `CORRECTS`/`RETRACTS` stay asserted and carry `sourceRevisionEventUid` (`PublicationRevisionProperties`). The event revises the specific rendition Source captured (PMC HTML). There is no prior snapshot when none was captured. | S-06 ("corrected in the PDF and HTML versions"); first run raised V-512 REVISION_SNAPSHOT_FOREIGN when the event pointed at the doi Source but the resulting snapshot belonged to PMC | Derive CORRECTS from the event path (loses NLM's own linking statement); invent a prior snapshot | ACCEPTED-FOR-PROPOSAL; registration W09-SR-02 |
| W09-D16 | Content added by a correction (the Elysium provider sentence) is a new assertion with nothing superseded. Content changed by a correction (reference 20) is a new assertion that `SUPERSEDES {SOURCE_CORRECTION, sourceRevisionEventUid}` the old one, which is kept. | S-06; round 0007 table; FI CORRECTS_SOURCE → FACT_CEASED (V-W09-06) | VALIDITY_BOUNDED (negative N17) | ACCEPTED-FOR-PROPOSAL |
| W09-D17 | `SPONSORED_BY`/`OPERATED_BY`/`INVESTIGATED_BY` are kept as read-only derived inverse projections with `derivationRule 'inverse-of:<predicate>@1'` + `derivedFromAssertionUids`. They do not carry `projectionOfAssertionUid` (the edge type differs from the predicate) and do not carry `assertionUid` (D-011). | Catalog derived-edge oneOf; D-011; brief asked "keep-as-derived with assertionUid", read here as "cite the authorizing assertion uid" | Asserted edges with their own assertions (duplicates W01 predicates) | PROPOSED (W00 to confirm the inverse rule form) |
| W09-D18 | A registry "collaborator" is not a CRO. `OPERATED_BY` derives only from `SERVES_AS_CRO_FOR`. | S-20 glossary; KGK Science on NCT02678611/NCT03464500 | Map collaborator to OPERATED_BY (live ingestion habit) | PROPOSED (W09-SR-05) |
| W09-D19 | Food and food fractions administered in a study are `IngredientMaterial` nodes as served (mass MATERIAL_AS_IS, SINGLE_DOSE). | NCT00938340 doses (S-13) | FoodItem as the intervention target | PROPOSED (W09-SR-07) |
| W09-D20 | Live `Study.hasPrimarySources`, `evaluatesRiskFactors`, `reportsSafetySignals`, `hasOutcomeResults`, `hasOutcomes`, `StudyArm.receivesInterventions` and the `supportedBy*` fields on study types are retired with a migration path (see `migration-map.yaml`). | INV-201 (RECEIVES → Product), D-005, D-007 | Keep as read-only legacy (only `evaluates` is mandated read-only) | ACCEPTED-FOR-PROPOSAL |
| W09-D21 | Study conduct period is a `STUDY_CONDUCTED_DURING` Assertion with valid bounds at MONTH precision and a literal interval `valueString` (V-003). No Occurrence type. | First run raised V-003 for an assertion with neither literal nor object | W09 `StudyConduct` Occurrence | ACCEPTED-FOR-PROPOSAL |
| W09-D22 | CQ-ID-02 answers "OVERLAP_START_UNKNOWN" when the only known formulation has an unknown start; never "current" and never "none". | QS-W09-09 rows (fixture 07) | Use the label retrieved today | ACCEPTED-FOR-PROPOSAL |
| W09-D23 | Independence counting (CQ-AX-05) counts dataset/study lines and flags shared sponsors. It reports a lower bound on dependence. | QS-W09-08: ATLAS + ENERGIZE = 2 lines, shared sponsor Amazentis SA | Count publications | ACCEPTED-FOR-PROPOSAL |

## Unresolved items and closure criteria

| Id | Item | Owner | Closure criterion |
|---|---|---|---|
| U-01 | Registry history for NCT02678611 (did registered outcomes change?) | W09 / W19 | A ClinicalTrials.gov history capture (API or archive) recorded as a SourceSnapshot; the derived `priority` then regenerates from the earliest version. |
| U-02 | A real SYSTEMATIC AE zero | W09 | Capture of a ClinicalTrials.gov results module (Adverse Events "Assessment Type") or a paper that states systematic elicitation. Both routes were BLOCKED or absent in this run. |
| U-03 | Qualifier carriage on assertions | W00 | W09-SR-12 ruling. |
| U-04 | EVALUATES type collision | W00 / Fable | W09-SR-13 ruling. |
| U-05 | Frozen validator changes | Fable (contract A10) | Rulings on W09-CR-01..04. Until then the frozen validators return the documented false-positive rows on W09 positives (V-211 1, V-217 5, V-221 4). |
| U-06 | Shared DosageForm/Route enums | W04 | W09-SR-06. |
| U-07 | uid tokens | W00 | W09-SR-04. Until then fixture uids `hu:study-population:`, `hu:device:`, `hu:procedure:` use unregistered tokens. |
| U-08 | Derived inverse rule form for role projections | W00 / W01 | W09-D17 confirmation. |

## Kernel-change requests

None. All kernel-adjacent asks (W09-SR-03, -04, -12, -13, -14, -16 and W09-CR-01..04) are registrations or validator corrections. None changes archetypes, assertion cardinality or time semantics.
