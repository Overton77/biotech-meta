# W16 fixtures and queries

## Execution scope

- **Status: run.** Every fixture file was executed on an embedded **Neo4j 5.26.31 Community** instance (`org.neo4j.test:neo4j-harness:5.26.31`, the run harness `validation/harness/EmbeddedNeo4j.java`, `run-cypher.mjs`) on 2026-10-04: each fixture loaded into an emptied database, then `fixtures/00-w16-validators.cypher`. Totals: 13 fixtures, **594 statements, 594 ok, 0 errors**; validator file 24 statements ok after each fixture. The exact rows returned are in `fixtures/run-summary.txt` (driver sample: at most 5 rows per statement).
- `operations.cypher` was applied first in a separate run and then all 13 fixtures were loaded **together** on top of it (smoke test of uniqueness constraints: 30/30 operations statements ok, all fixtures ok, 176 nodes). The combined load is only a constraint test: fixtures intentionally reuse some uids (for example `hu:protocol-edition:blueprint-observed-2026-10-04`) with fixture-specific partial payloads, so the merged edition is not a meaningful record.
- `sdl-fragment.graphql` with stubs for imported types: graphql-js parse OK; `@neo4j/graphql` 7.6.3 `getSchema()` OK (1,766 generated types, no vector provider); `Protocol.currentSteps` is absent from create and update inputs (read-only confirmed).
- Conventions: every statement binds its own nodes by uid; primary + archetype labels on every node; snapshot hashes `synthetic:<uid>` with `contentHashBasis: SYNTHETIC_FIXTURE`; edition and step `payloadHash` are real sha256 values over the W16-CANON-1 JSON of the fixture payload (generator in `fixtures/generator/`). Negative cases are inside the same file under a `NEGATIVE` comment and use `neg` uids so positive results are unaffected.
- The stored value of `privacyClass` is `PUBLIC`/`INTERNAL` (GraphQL enum names; casing seam W16-SR-04).

## Summary of expected validator outcomes (all observed exactly as expected)

| Fixture | Validator rows (expected = observed) |
|---|---|
| 01 edition diff | none |
| 02 source change, same identity | V-509 1 (POSSIBLE_OVERLAP_REVIEW: both Blueprint edition episodes have unknown bounds — the honest outcome of SNAPSHOT_DIFF without a known change instant); V-530p 1 (EDITION_FROM_THIRD_PARTY_REPORT) |
| 03 repeated step + prerequisite | V-527p 1 (SELF_DEPENDENCY); V-528p 1 (ORDERING_CYCLE) — both from the negative edition |
| 04 conditional branch | V-525p 1 (CONDITIONAL_STEP_WITHOUT_CONDITION `mole-check-annual` negative) |
| 05 parallel steps | V-531p 2 (EXCLUSIVE_AND_CONCURRENT_WITH, both directions of the negative pair) |
| 06 optional step | V-534p 2 (EXECUTION_DATA_ON_PUBLIC_PROTOCOL `adherence`,`omittedByUser`; EXECUTION_EDGE_ON_PUBLIC_PROTOCOL `OMITTED_STEP`) |
| 07 leak probe (**expected to fail**) | V-113 1 (`ADOPTED_IN_PRIVATE` edition → private node); V-520 2 (ProtocolInUse, Observation:PersonalMeasurement); V-521 3 (private uid on public step; two private nodes); V-524 1 (OBSERVATION_PERSONAL_MEASUREMENT_COLLAPSE); V-532p 1 (the collapsed private node has no public attribution); V-534p 1 (`lastDeviationUid` on public step) |
| 08 version changes | V-509 1 (same reason as 02) |
| 09 role/evidence | V-538p 1 (COMPONENT_EVIDENCE_TRANSFERRED_TO_PROTOCOL) |
| 10 cadence range | V-529p 1 (RANGE_INVERTED plan); V-529b 2 (POSSIBLE_RANGE_COLLAPSE step and plan) |
| 11 wait for result | V-531p 1 (RESULT_DEPENDENCY_ON_NON_RESULT_STEP); V-533p 1 (RULE_BASIS_PRIVACY_MISMATCH) |
| 12 mutually exclusive | V-531p 3 (EXCLUSIVE_AND_REQUIRES_PRIOR_COMPLETION ×2 directions, EXCLUSIVE_PAIR_BOTH_ESSENTIAL) |
| 13 subprotocol binding | none |

Validators with zero rows in every fixture: V-508, V-526p, V-536p, V-537p, V-539p, V-540p, V-541p, V-542p (V-536p, V-537p, V-539p, V-540p and V-542p are exercised positively: every ABOUT_CONDITION/USES/HAS_PROTOCOL_EDITION/MODIFIES_STEP edge in the fixtures satisfies them; no fixture writes HAS_CURRENT_PROTOCOL_STEP, so V-542p is untested for rows — recorded gap).

## Fixture details

### 01 `01-edition-diff-by-stepkey.cypher` — edition diff by stepKey (required)
Real source: protocols.io "PBMCs isolation from CPT tube" V.1 (2020-08-06, no DOI, partial capture) and V.2 (2022-07-27). `centrifuge-cpt-tube` changed from "minimum of 00:10:00 at 1500 rpm to 1800 rpm" at room temperature to "1500 rcf … 00:30:00 at 20 °C"; a mixing step was added first.

**Q-W16-01 (CQ-PR-01)** expected = observed (5 rows):

| stepKey | changeKind | oldOrder → newOrder | reordered |
|---|---|---|---|
| aspirate-plasma-half | MODIFIED | 2 → 3 | true |
| centrifuge-cpt-tube | MODIFIED | 1 → 2 | true |
| collect-cells | MODIFIED | 3 → 4 | true |
| mix-by-inversion | ADDED_OR_NOT_CAPTURED | – → 1 | false |
| spin-down-collected | ADDED_OR_NOT_CAPTURED | – → 5 | false |

All rows `changeProvenance = SOURCE_VERSIONED`, labels V.1 → V.2. Minimal pair inside the result: a complete old capture would have produced ADDED; the partial V.1 capture yields ADDED_OR_NOT_CAPTURED (no invented transition).

### 02 `02-source-change-same-identity.cypher` — schedule/dose change without identity change (required)
Real: Blueprint page captured by Wayback 2026-01-24T05:28:36Z and live 2026-10-04; NAD.com 2026-03-24.
- **Q-W16-02a**: 1 row `{protocolUid: hu:protocol:blueprint-bryan-johnson, editions: 2, provenances: [SNAPSHOT_DIFF, SNAPSHOT_DIFF]}` — one enduring identity.
- **Q-W16-02b** (3 rows; candesartan unchanged and shared, so not a diff row): acarbose `200 PER_DAY → 200 PER_DOSE` with 2 per day (verbatim "Acarbose 200 mg (Rx) (twice daily); Acarbose 400 mg daily"); creatine `2.5 → 5 g PER_DOSE`; tadalafil `2.5 → 5 mg PER_DAY`; `sameStepNode = false` for all three (new payload, same stepKey).
- **Q-W16-02c** (4 rows): two editions labelled SNAPSHOT_DIFF with observedAt 2026-01-24T05:28:36Z / 2026-10-04T00:56Z, bounds `PUBLICATION_PROXY 2026-01-23 → UNKNOWN` and `OBSERVATION_ONLY → UNKNOWN`; two NAD.com Assertions labelled THIRD_PARTY_REPORTED (asserter ≠ author), rapamycin `validTo 2024-01-01 (YEAR, STATED_BY_SOURCE)`.
- Negative: edition with `changeProvenance THIRD_PARTY_REPORTED` → V-530p 1 row.

### 03 `03-repeated-step-plus-prerequisite.cypher` — repeated step plus prerequisite (required)
Real: NICE CG185 1.10.14/15/19; Blueprint HBOT.
- **Q-W16-03** (4 rows, in edition order): `baseline-tests-when-starting` ONE_TIME, no prerequisites; `start-lithium` REQUIRES_RESULT_OF baseline (EDITORIAL_INFERENCE); `plasma-lithium-titration-checks` EVENT_DRIVEN 1..1 WEEK, repeatUntil "weekly until the levels are stable", REQUIRES_PRIOR_COMPLETION start-lithium lag "1..1 WEEK"; `plasma-lithium-year1` RECURRING 3..3 MONTH, course 365 days, after start-lithium.
- **Q-W16-03b**: `hbot-course` total 60, 5 per WEEK, 90 min, instrument "HPO Tech hard shell hyperbaric chamber".
- Negative: repetition as self-dependency → V-527p SELF_DEPENDENCY + V-528p ORDERING_CYCLE.

### 04 `04-conditional-branch-missing-condition.cypher` — conditional branch plus missing condition (required)
Real: NICE CG185 1.10.20 (six risk groups; "every 6 months, or every 3 months for people in any of the following groups"); Blueprint "Full body MRI annually (if over 40 or a family history of high risk)".
- **Q-W16-04a**: 14 rows = 6 negated singleton groups on `…-standard`, 6 non-negated members of group `any-risk-group` on `…-intensive`, 2 members of `g1` on `full-body-mri-annual` (POPULATION GT 40 a; CONDITION_PRESENT).
- **Q-W16-04b** (hypothetical fact set: last level ≥ 0.8 true, others false): intensive APPLIES, standard DOES_NOT_APPLY.
- **Q-W16-04c** (older people and poor adherence undeclared, others false): both branches **UNKNOWN_MISSING_FACT**, missing `[poor-adherence, older-people]` — a missing fact is never read as false.
- **Q-W16-04d**: MRI APPLIES with only family history true; age still listed as missing (OR satisfied).
- **Q-W16-04e** (CQ-PR-03): 6 gate facts; 5 TEXT_ONLY_FACT, 1 STRUCTURED_FACT (`last-level-gte-0.8` via `hu:metric:plasma-lithium-substance-concentration`).
- Negative: CONDITIONAL step with no APPLIES_WHEN → V-525p.
- The evaluation queries take literal non-personal fact lists; in production the private store evaluates with the person's facts and writes nothing to the shared graph.

### 05 `05-parallel-steps-concurrent.cypher` — parallel steps (required)
Real: Blueprint "7:30 am Dry sauna … I place an ice pack on the boys"; "Rehydration: 36 oz"; "Tips for you"; "Avoid or skip sauna if you …".
- **Q-W16-05a**: `groin-ice-pack-during-sauna` CONCURRENT_WITH `dry-sauna-daily` → PARALLEL; `rehydrate-after-sauna` REQUIRES_PRIOR_COMPLETION → SEQUENTIAL.
- **Q-W16-05b**: RECOMMENDS 3..5/week, 15..20 min (reader guidance) vs REPORTS_PRACTICE 7/week, 20 min (author practice).
- **Q-W16-05c** (CQ-RC-06 shared part): both sauna steps blocked by any of 3 constraint uids in OR group `avoid-if-any`.
- Negative: a pair both CONCURRENT_WITH and MUTUALLY_EXCLUSIVE_WITH → V-531p 2 rows.

### 06 `06-optional-step-no-nonadherence.cypher` — optional step omitted without non-adherence (required)
Synthetic (inherited wind-down protocol) + synthetic public host report.
- **Q-W16-06a**: `fixed-bedtime` ESSENTIAL → TEMPLATE_REQUIRES; `screen-free-hour` OPTIONAL → OMISSION_CONSISTENT_WITH_TEMPLATE.
- **Q-W16-06b**: adherence `ADHERENCE_NOT_IN_SHARED_GRAPH` for both steps; `screen-free-hour` has 1 public practice-report Assertion (a public person's own statement, polarity NEGATIVE), which is not an adherence verdict.
- Negative: `adherence`/`omittedByUser` on a public step and `(:Person)-[:OMITTED_STEP]->(:ProtocolStep)` → V-534p 2 rows.

### 07 `07-public-vs-private-leak-probe.cypher` — public description vs private execution (required; leak probe expected to FAIL)
Real public part: Blueprint "hsCRP below detectable levels" as a public Observation attributed by an asserted RECORDS edge from the public author.
- Expected and observed failures: V-113, V-520, V-521, V-524, V-532p, V-534p (table above).
- **Q-W16-07a** (QS-6a): `reachableNodes 8, reachesPrivate false` while the probes are present (defence in depth).
- **Q-W16-07b** (CQ-AX-22 shared part): observation bound to `hu:protocol-edition:blueprint-observed-2026-10-04`, attribution `hu:assertion:bj-records-hscrp-observation`.
- Correct pattern (not in the graph): the private store holds `ProtocolAdoptionVersion{adoptedEditionUid, …}` and `ProtocolDeviation{stepKey, deviationKind}` referencing the shared uids (W16-SR-11).

### 08 `08-device-assay-formulation-version-change.cypher` — device/assay/formulation version change (required)
Real step text (Longevity Mix 1 scoop; HPO Tech chamber); formulation versions, assay versions and the chamber model change are SYNTHETIC.
- **Q-W16-08a**: edition 2026-01-24 → ProductVariant, RESOLVED_AS_OF `…-f1`; edition 2026-10-04 → RESOLVED_AS_OF `…-f2`; synthetic pinned edition → FormulationVersion, PINNED `…-f1`.
- **Q-W16-08b**: `hbot-course` MODIFIED (instrument changed, same stepKey); `longevity-mix-pre-workout` and `routine-blood-draw` UNCHANGED (shared nodes).
- **Q-W16-08c**: `sameAssayVersion false, comparabilityAssessed false, comparability NOT_ESTABLISHED` (INV-301).

### 09 `09-assertion-backed-role-evidence.cypher` — assertion-backed role/evidence attribution (required; CQ-PR-06)
Real: NICE authorship and the shared-care prescriber role (1.10.14); PMID 28202779. Synthetic combined stack.
- **Q-W16-09a**: `sauna-weekly` NO_STEP_EVIDENCE_CITED; `fmd-5-day-monthly` cites `hu:publication:pmid-28202779` (STEP_EVIDENCE_CITED_NOT_ASSESSED_FOR_APPLICABILITY); edition NO_PROTOCOL_LEVEL_EVIDENCE.
- **Q-W16-09b**: AUTHORED_PROTOCOL_EDITION (NICE, asserter NICE, locator); REQUIRES_PERFORMER_ROLE `start-lithium` "prescriber with a shared-care arrangement with the person's GP".
- Negative: CALCULATED PROTOCOL_EFFECTIVE_FOR derived only from the step citation → V-538p.

### 10 `10-cadence-range-3-to-6-months.cypher` — 3–6 month cadence range (required)
- **Q-W16-10a**: `routine-blood-draw` 3..6 MONTH; plan 90..183 days; text "Blood draw, every 3 to 6 months".
- **Q-W16-10b**: last draw 2026-01-15 → window opens 2026-04-15, closes 2026-07-17; status on 2026-06-01 WITHIN_WINDOW (never a single due date).
- Negatives: range collapsed to 4..4 with verbatim "3 to 6" (V-529b), plan 135..135 (V-529b), inverted plan 183..90 (V-529p).

### 11 `11-wait-for-lab-result.cypher` — REQUIRES_RESULT_OF (required)
- **Q-W16-11a**: `lithium-dose-adjustment` waits for result of `plasma-lithium-titration-checks` (gating metric plasma lithium); `start-lithium` waits for `baseline-tests-when-starting` (EDITORIAL_INFERENCE).
- **Q-W16-11b**: rule `nice-cg185-egfr-falling` TREND → REVIEW, metric eGFR, modifies `plasma-lithium-year1`, STATED_BY_SOURCE.
- Negatives: REQUIRES_RESULT_OF an INGEST step (V-531p); BellLabs policy rule without INTERNAL/PolicyVersion (V-533p).

### 12 `12-mutually-exclusive-steps.cypher` — mutually exclusive steps (required)
- **Q-W16-12**: (`hbot-session-9am`, `ihht-session-9am`) 90 min vs 42 min; (`nad-precursor-nmn`, `nad-precursor-nr`) 500 mg vs 450 mg.
- Negatives: exclusive + ordered + both ESSENTIAL → V-531p 3 rows. Gap: "exactly one of" is not representable (candidate CQ-PR-C06).

### 13 `13-subprotocol-edition-binding.cypher` — subprotocol edition binding (mandatory case)
- **Q-W16-13**: floating parent at 2021-06-01 → V.1 (RESOLVED_AS_OF, KNOWN_WITHIN); at 2023-06-01 → V.2 (RESOLVED_AS_OF, OPEN_END_UNVERIFIED); pinned parent → V.2 at both instants (PINNED).

## Essential/Foundational CQ query coverage

CQ-PC-08 (Essential): fixture 07 + validators. CQ-PR-01 (Foundational): Q-W16-01, 02b, 02c, 08b. CQ-PR-02 (Foundational): Q-W16-03, 04a, 05a, 11a, 12. CQ-PR-05 (Foundational): shared part Q-W16-07b (private part is W23's). CQ-RC-06 (Foundational): Q-W16-05c.

## Temporal correction / late arrival / identity collision / missing facts / leakage

- Late arrival: the Wayback capture of 2026-01-24 was retrieved on 2026-10-04: snapshot `observedAt` 2026-01-24, `retrievedAt` and `recordedAt` 2026-10-04; the edition keeps its past valid-from (PUBLICATION_PROXY) and the recorded time is never backdated (fixture 02).
- Correction: a later correction of an edition attachment is a new HAS_PROTOCOL_EDITION episode (old `recordedTo` set) per round 0007; not separately exercised here (W00 fixtures own the mechanism; V-539p checks projection fidelity).
- Identity collision: same stepKey, different payload → MODIFIED (01, 02, 08); same text printed in two page sections → one step (model cards §6); NR vs NMN → two keys (12).
- Missing facts: ADDED_OR_NOT_CAPTURED (01), UNKNOWN_MISSING_FACT (04), `notReportedFields` (01 V.1 centrifuge max duration).
- Leakage: fixture 07.
