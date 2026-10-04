# W07 fixtures and queries

## Execution record

All files were **run** on an embedded Neo4j **5.26.31 Community** instance (in-process `neo4j-harness`, fresh store, started 2026-10-04 ~01:20Z) with the run harness `run-cypher.mjs` (one transaction per statement, no variables across `;`). The SDL fragment was **built** with `@neo4j/graphql` 7.6.3 / `graphql` 16.14.2 together with test stubs for W00 kernel types and other owners' types (`build OK`, 1500 generated types, 68 queries, 75 mutations); stubs are not deliverables. No uniqueness constraints were applied during the fixture run (operations file proposes them; the duplicate-LOINC negative was therefore not attempted).

Load order: `w07-00-sources` (3 statements) -> `w07-01-measurands-tests-assays` (21) -> `w07-02-reference-intervals` (1) -> `w07-03-algorithms` (4) -> `w07-04-results-and-comparability` (10) -> **check positive** -> `w07-90-negative-overlays` (14) -> **check** -> `w07-91-negative-masking` (1) -> **check**. All 54 load statements succeeded. Validation: `w07-validation.cypher` (26 statements) and the repository suite `neo4j/validation.cypher` (174 statements, `validation/validation-params.json`).

Every node carries its primary label and archetype label; uids use registered tokens (source, snapshot, locator, assertion, adjudication, resolution, identifier, org, instrument, anatomical-context, biomarker, metric, lab-test, method, specimen-type, reference-system, assay-version, algorithm, algorithm-version, ri-version, comparability, result, rel) except the leak fixture's deliberate `hu:private-result:`. Snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'`.

## Cases

| Case (brief requirement) | Fixture | Expected | Observed |
|---|---|---|---|
| Same LOINC code, different AssayVersion; not comparable without assessment | 01 (Mayo D-100, Labcorp Tina Quant, Quest TINIA, Lab A x2 all 4548-4); 04 results; QS-DX-03; N1 | positive: Mayo/Labcorp pair = SEPARATE_SERIES; N1 COMPARED_TO -> V-302 1 row, V-302r 1 row | as expected; QS-DX-03 21 pairs: 1 COMPARABLE_WITH_CONVERSION (Lab A Tosoh vs Lab B IFCC), 1 SAME_ASSAY_VERSION (Lab A cobas 2025-09 vs 2026-02), 19 SEPARATE_SERIES |
| Same test name, different Metric | 01 (Labcorp "Hemoglobin A1c" -> 4548-4; synthetic Lab C "Hemoglobin A1c" -> 59261-8); N7 | positive: no SAME_TEST_AS; N7 -> V-307 1, V-315 1 | as expected |
| Same algorithm family, different AlgorithmVersion, SERVICE_ENDPOINT_UNVERSIONED | 03 (Owkin pins 2026-10-03 and 2026-10-04, same Algorithm); N3 | positive: QS-DX-07 2 rows, unitStatus NOT_REPORTED; N3 -> V-312 2, V-304 1 (+1 from N2) | as expected (V-304 2 rows total = N2 + N3) |
| Within-version score difference must not become a measured change | 04 (GrimAge2 2025-03 49.0 a and 2025-09 45.0 a, same AlgorithmVersion and AssayVersion; COMPARED_TO same-version; vendor `CHANGED_BETWEEN` statement, basisKind INFERRED_FROM_MEASUREMENT); N6 | positive: QS-DX-05 changeStatus NOT_ESTABLISHED; N6 (DIRECT_MEASUREMENT) -> V-314 1 | as expected; repository V-231 also reports N6 (DIRECT_MEASUREMENT without MechanismEvidenceContext) |
| Result keeps the interval printed at report time after the lab changed its interval | 02 (Lab A cobas: a2 4.1-5.7 TRANSFERRED 2025-06-01..2026-01-01; a3 4.0-5.6 VERIFIED from 2026-01-01); 04 | QS-DX-06: 2025-09-10 -> a2 with current a3; 2026-02-10 -> a3 | as expected (3 rows; 2025-01-10 -> a1, current null because a1 is bounded) |
| ReferenceIntervalVersion bound to two AssayVersions | N4 | V-305c 1 row; V-306 1 row (Mayo binding of a Labcorp result) | as expected. **V-302 does not fire for N4**: catalog V-302 tests INV-301 comparisons; INV-302 is checked by V-305b/V-305c/V-306 (D-W07-09) |
| DiagnosticResult implementer missing its AssayVersion | N5 (`Observation:DiagnosticResult:InformationArtifact`, MEASURED, no edge, no pending assertion) | V-303 2 rows (N5 + Everlywell), V-303r 1 row (N5) | as expected |
| Temporal correction (late fact) | 01 Lab A switch 2025-07-01 corrected to 2025-06-01 | QS-DX-01b: as recorded on 2025-08-01 only the 2025-07-01 episode; now the 2025-06-01 episode | as expected |
| Identity collision | 04 vendor "GrimAge" (two UNRESOLVED assertions + competing ResolutionHypotheses); N7 | review queue 2 rows; no SAME_TEST_AS in positive | as expected |
| Missing facts | 01 Labcorp method/instrument absent (edges absent, not guessed); Everlywell lab unnamed; Owkin unit NOT_REPORTED; Quest one-sided bound NOT_APPLICABLE; N14 miscapture | QS-DX-01 method null; V-318 1 row for N14 | as expected |
| Access leakage | N12 `:PrivateRecord` result with `hu:private-result:` uid and PRIVATE_PERSONAL | V-313r 1 row; repository V-114 1 row | as expected |
| Inferred labelled measured | N8 | V-316 1 row | as expected |
| Collapsed assay identity | N9 (Lab A cobas assay also operated by Lab B) | V-301b 1 row | as expected |
| Malformed assessment masking a trend | 91 / N10 (three-way COMPARABLE over Mayo, Labcorp, Quest) | V-311 1 row; V-302 drops 1 -> 0; V-302r stays 1 | as expected |
| Malformed LOINC | N11 `4548-04` | V-310a 1 row | as expected |
| Unpinned unversioned endpoint | N13 | V-317 1 row | as expected |

## W07 validation results (`w07-validation.cypher`)

| Id | Positive (00-04) | After 90 | After 91 | Note |
|---|---|---|---|---|
| V-301a | 0 | 0 | 0 | |
| V-301b | 0 | 1 | 1 | N9 |
| V-302 | 0 | 1 | 0 | N1; masked by N10 |
| V-302r (proposed) | 0 | 1 | 1 | N1 |
| V-303 | 1 | 2 | 2 | Everlywell pending (positive) is a catalog false positive; + N5 |
| V-303r (proposed) | 0 | 1 | 1 | N5 |
| V-304 | 0 | 2 | 2 | N2, N3 |
| V-304r (proposed) | 0 | 2 | 2 | |
| V-305b | 0 | 0 | 0 | |
| V-305c (proposed) | 0 | 1 | 1 | N4 |
| V-306 | 0 | 1 | 1 | N4 |
| V-307 | 0 | 1 | 1 | N7 |
| V-308 | 0 | 0 | 0 | |
| V-312 | 0 | 2 | 2 | N3 |
| V-305a | 0 | 0 | 0 | no legacy ranges in fixtures |
| V-309 | 0 | 0 | 0 | no INDICATES_CONDITION fixture (Condition has no registered uid token); forbidden implication covered by this validation reference |
| V-310a | 0 | 1 | 1 | N11 |
| V-310b | 0 | 0 | 0 | |
| V-311 | 0 | 0 | 1 | N10 |
| V-313r (proposed) | 0 | 1 | 1 | N12 |
| V-314 (proposed) | 0 | 1 | 1 | N6 |
| V-315 (proposed) | 0 | 1 | 1 | N7 |
| V-316 (proposed) | 0 | 1 | 1 | N8 |
| V-317 (proposed) | 0 | 1 | 1 | N13 |
| V-318 (proposed) | 0 | 1 | 1 | N14 |
| review queue (informational) | 2 | 2 | 2 | Everlywell pending lab; vendor GrimAge v1/v2 |

## Repository suite (`neo4j/validation.cypher`, 174 statements, all ran)

Positive state: rows only from V-112 (2: same-version COMPARED_TO is not `ruleOnly`, W07-SR-10), V-303 (1: Everlywell, W07-SR-09), V-313 (15: PrivacyClass upper-case, W07-SR-15), and informational V-118, V-401b (20 accepted assertions rest on SECTION locators only), V-514b (0 assertions without contentHash). After 90+91: additionally V-112 (6), V-114 (1, N12), V-231 (1, N6), V-301b, V-303, V-304, V-306, V-307, V-310a, V-311, V-312 as in the table above, V-313 (19).

## Forbidden implications -> negative coverage

| Forbidden implication | Negative fixture / validation |
|---|---|
| [SHARES_LOINC_CODE, SAME_ASSAY_VERSION] | N1 -> V-302/V-302r |
| [SIMILAR_TEST_NAME, SAME_METRIC] | N7 -> V-307, V-315 |
| [SAME_ALGORITHM_FAMILY, SAME_ALGORITHM_VERSION] | N2, N3 -> V-304/V-304r, V-312 |
| [OUTSIDE_REFERENCE_INTERVAL, INDICATES_CONDITION] | V-309 (validation reference only; no fixture because Condition has no registered uid token) |
| [INFERRED_RESULT, MEASURED_RESULT] | N8 -> V-316; N5 -> V-303/V-303r |
| [WITHIN_VERSION_SCORE_DIFFERENCE, MEASURED_BIOLOGICAL_CHANGE] | N6 -> V-314 |

## CQ queries (`w07-cq-queries.cypher`, all run, positive state)

| Query | CQ | Rows | Key values |
|---|---|---|---|
| QS-DX-01 | CQ-DX-01 (Essential) | 1 | loinc 4548-4, MFr/Bld/Qn, assay `labcorp-001453-tina-quant`, kit "Roche Tina Quant", method null, instrument null, software NOT_REPORTED, specimens EDTA + lithium heparin + sodium fluoride |
| QS-DX-01b | CQ-DX-01 temporal | 3 | Tosoh episode validTo 2025-07-01 believed on 2025-08-01 only; corrected Tosoh validTo 2025-06-01 and cobas validFrom 2025-06-01 believed now |
| QS-DX-02 | CQ-DX-02 (Essential) | 15 | e.g. GrimAge v1 INFERRED by `grimage-v1-lu-2019` (PUBLICATION_VERSION) on `synthetic-lab-m-epic`; Everlywell MEASURED with no assay version |
| QS-DX-03 | CQ-DX-03 (Essential) | 21 | 1 COMPARABLE_WITH_CONVERSION with rule `NGSP(%) = 0.09148 * IFCC(mmol/mol) + 2.152 (NGSP Table 2)`, 1 SAME_ASSAY_VERSION, 19 SEPARATE_SERIES |
| QS-DX-04 | CQ-DX-04 (Essential) | 7 | vendor GrimAge unresolved candidates [v1, v2]; TruDiagnostic DunedinPACE versionBasis UNKNOWN; Owkin SERVICE_ENDPOINT_UNVERSIONED |
| QS-DX-05 | CQ-DX-05 | 1 | asserted by Synthetic Methylation Lab M, basis INFERRED_FROM_MEASUREMENT, changeStatus NOT_ESTABLISHED |
| QS-DX-06 | CQ-DX-06 | 3 | 2025-09-10 printed a2 "4.1 - 5.7 %" TRANSFERRED, current a3 |
| QS-DX-06b | CQ-DX-06 | 6 | Labcorp REFERENCE_INTERVAL 4.8-5.6, DECISION_LIMIT 6.5 (hi NOT_APPLICABLE), GUIDELINE_TARGET <7.0 (lo NOT_APPLICABLE); Mayo REFERENCE_INTERVAL + two DECISION_LIMITs |
| QS-DX-07 | CQ-DX-07 | 2 | two pins, basis SERVICE_ENDPOINT_UNVERSIONED, unitStatus NOT_REPORTED, unit null |
| QS-AX-21 | CQ-AX-21 | 2 | Lab A Tosoh vs Lab B: COMPARABLE_WITH_CONVERSION; Mayo vs Labcorp: NO_ASSESSMENT_SEPARATE_SERIES (no result node read) |
| QS-MX-02 | CQ-MX-02 | 1 | 4548-4, system Bld, HbA1c, matrix Blood |

## Not covered by a fixture

PanelDefinition (no registered uid token, W07-SR-12); legacy ReferenceRange and HAS_REFERENCE_RANGE migration (V-305a only); CQ-DX-09 firmware (W08); duplicate LOINC under the uniqueness constraint (constraint not applied in this run).
