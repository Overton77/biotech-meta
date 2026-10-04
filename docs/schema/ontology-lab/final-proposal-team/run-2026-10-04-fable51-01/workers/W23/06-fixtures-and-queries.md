# W23 06 Fixtures and queries

**Execution.** Everything below was **run** on 2026-10-04 on an embedded Neo4j **5.26.31 Community** (the run harness `validation/harness/EmbeddedNeo4j.java`, copied to the W23 scratchpad, JVM `-Xmx1g`), with `docs/schema/neo4j/constraints.cypher` (45 applied / 12 Enterprise-only rejected, as in the baseline) and `operations.cypher` (8/8 applied) loaded first. `checks/run-all.sh` reproduces every scenario; each starts from `fixtures/reset.cypher` (disposable database only). The full repository suite `docs/schema/neo4j/validation.cypher` (174 statements) runs with the run's `validation/validation-params.json` (`params-leak.json` adds the leak index labels for S3/S3a); W23's validators are `fixtures/validation-w23.cypher` (12 statements). Machine results: `fixtures/results/*.json`. All 174 + 12 statements ran without error in every scenario.

Rules followed: statements separated by `;`; every statement binds its own nodes by uid; nodes carry the primary and the archetype label; uids use registered tokens except those requested in W23-SR-01; snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'`; all data synthetic. Informational rows that appear everywhere and are not failures: V-118 (uid backfill counts, 6 rows), V-401b (count 0), V-514b (count 0).

## Fixture files

| File | Kind | Content |
|---|---|---|
| `00-shared-base.cypher` | positive | SleepWell product, variant, two formulation versions; label snapshots 2026-03-02 and 2026-06-15 with TEXT_QUOTE locators; A1 (fv-a1, 200 mg) superseded by A2 (fv-a1c, 120 mg) with SOURCE_CORRECTION; capture adjudications; INTERNAL use policy v1 and ranking policy v3 with two criteria; answer-composer Agent; two ANSWER_COMPOSITION Activities AUTHORIZED_BY the use policy; AnswerRecords AR-1 (viewpoint 2026-04-10, cites A1) and AR-2 (viewpoint 2026-06-20, cites A2) |
| `01-answer-record-replay.cypher` | queries | Q-AR-1 … Q-AR-5 |
| `02-public-projection.cypher` | queries | Q-PP-1 … Q-PP-3 |
| `03-decision-replay-after-correction.cypher` + `replay-params.json` | queries | Q-DR-1 … Q-DR-5 (shared half of a private snapshot replay) |
| `04-uid-redirect.cypher` | data + queries | duplicate variant merged 2026-05-01; Q-RD-1 … Q-RD-3 |
| `10-leak-probe-qs6.cypher` + `10-leak-probe-queries.cypher` + `params-leak.json` | negative + queries | QS-6 leak probe (three leak kinds and variants); Q-L-1 … Q-L-4 |
| `11-public-person-only.cypher` | positive + negative | CL-018: public self-report and case-series participant (pass); BellLabs user as Person, copied lab value, posted outcome, internal tokens, inferred re-identification link (fail) |
| `12-answer-record-negative.cypher` | negative | five defective AnswerRecords |
| `13-use-authorization-negative.cypher` + `13-fail-open-queries.cypher` | negative + queries | four authorization defects, overlapping policy versions, unclassified records; fail-open minimal pair Q-FO-1 … Q-FO-3 |
| `validation-w23.cypher` | validators | V-W23-01a … V-W23-10 |
| `reset.cypher` | utility | empties the disposable database and drops the leak index |

## S1 — positive base (00 loaded alone)

| Check | Expected | Actual (run) |
|---|---|---|
| Load 00 | 23 statements OK | 23/23 OK |
| `validation.cypher` | zero failing rows | zero failing rows (only V-118/V-401b/V-514b informational) |
| `validation-w23.cypher` | zero rows | zero rows (12/12 OK) |

| Query (CQ) | Expected | Actual (run) |
|---|---|---|
| Q-AR-1 replay at AR-1's viewpoint (CQ-AX-03) | 1 row: sentence 0, cited A1, replayed A1, object fv-a1, verdict SUPPORTED (cf-a1), reproduced true | as expected |
| Q-AR-2 replay at R = 2026-10-04 | 1 row: replayed A2, object fv-a1c, verdict SUPPORTED (cf-a2), reproduced false | as expected |
| Q-AR-3 answers depending on A1 (CQ-AX-11) | 1 row: AR-1, supersededBy A2, SOURCE_CORRECTION, learnedAt 2026-06-15T08:10Z, correctedAfterViewpoint true; AR-2 absent | as expected |
| Q-AR-3b correction-reach queue | 1 row (AR-1, A1, A2, SOURCE_CORRECTION) | as expected |
| Q-AR-4 trace (CQ-AX-01) | 1 row: TEXT_QUOTE "Magnesium (as magnesium glycinate) 200 mg" in snapshot 2026-03-02 (sha256:fe44…c48a), one CAPTURE_FIDELITY SUPPORTED adjudication, gaps [] | as expected |
| Q-AR-5 public reproducibility view | 1 row with the allow-listed keys only (no mongoResearchRunId, privacyClass, createdAt, lineage) | as expected |
| Q-PP-1 PUBLIC_ANSWER from A1, 1..3 hops (CQ-AX-12/13) | reachesPolicyLayer false, reachesLineage false, reachesAnswerRecord false, nonPublicReached [] | 15 nodes; labels Assertion, ProductVariant, Product, SourceLocator, FormulationVersion, SourceSnapshot, Source, Adjudication (+ archetype labels); all flags false |
| Q-PP-2 OPERATOR_AUDIT | reachesPolicyLayer true (use policy v1), lineage true, AnswerRecord true, privateReached [] | 21 nodes; policyVersionsReached [hu:policy-version:w23-use-quote-summarize-v1]; as expected |
| Q-PP-3 field closure | every admitted PUBLIC node carries privacyClass (stripped), none carries mongoResearchRunId, projected keys leak nothing | admittedPublicNodes 16, fieldsStripped [privacyClass], admittedWithRunId 0, projectedKeysLeakingInternal 0 |
| Q-DR-1 decision replay at viewpoint (CQ-RC-04) | heldAtViewpoint fv-a1 by A1, reproduced true | as expected |
| Q-DR-2 same V at R = now (CQ-RC-07) | heldNow fv-a1c by A2, matchesSnapshot false | as expected |
| Q-DR-3 evidence superseded after viewpoint | A1 → A2, SOURCE_CORRECTION, 2026-06-15T08:10Z | as expected |
| Q-DR-4 adjudication at viewpoint | cf-a1 CAPTURE_FIDELITY SUPPORTED, visibleAtViewpoint true | as expected |
| Q-DR-5 policy identity (CQ-RC-02/03) | sleep-support-ranking v3, payload sha256:0c84…48be, criteria [WEAKEST_APPLICABILITY_DIMENSION@applicability-0.3, SAFETY_BLOCK@safety-block-0.1], three required fact keys, effectiveAtDecision true, recordedBeforeDecision true | as expected |

## S2 — uid redirect (00 + 04)

| Check | Expected | Actual (run) |
|---|---|---|
| Q-RD-1 resolve held duplicate uid at R = 2026-04-10T09:00Z | resolvedUid = the duplicate itself; redirect null; heldUidResolvable true | as expected |
| Q-RD-2 same uid at R = now | resolvedUid = hu:product-variant:w23-sleepwell-us-capsule via hu:assessment:w23-merge-capsule-dup (2026-05-01T12:00Z); old uid still resolvable | as expected |
| Q-RD-3 malformed redirects | 0 rows | 0 rows |
| `validation.cypher` | one V-432 row, caused by V-432 matching `COMPARES` while the catalog edge is `COMPARES_IDENTITIES` (W23-SR-07) | exactly that row (comparedCount 0); nothing else |
| `validation-w23.cypher` | 0 rows | 0 rows |

## S3a — leaking index created before any private node (00 + index only)

| Detector | Expected | Actual (run) |
|---|---|---|
| V-115 (node-based, `$sharedIndexedLabels` incl. UserGoalVersion) | 0 rows: it cannot see an index without private nodes | 0 rows |
| **V-W23-04** (index metadata) | 1 row: w23_leak_goal_search, FULLTEXT, [UserGoalVersion, Product], [goalStatement, name] | as expected |

## S3 — QS-6 private-leak probe (00 + 10)

| Leak (fixture 10) | Named detector(s) expected | Actual rows (run) |
|---|---|---|
| LEAK-1: shared `EvidenceApplicability` → `hu:private-user-context:w23-leak-0001` (`ASSESSES_APPLICABILITY_TO`) | V-113, V-524 (APPLICABILITY_TO_USER_CONTEXT), V-520, V-521, V-W23-09 | V-113 1 row; V-524 row; V-520 row; V-521 NODE row; V-W23-09 row (`private-personal`); collateral V-203 (the leaked applicability has no evidence target) |
| LEAK-1 bridge: private node `INTERESTED_IN` two shared products | V-114 (`$allowedReferenceTypes` = []) | 2 rows |
| LEAK-1b: `:Observation:PersonalMeasurement` with class `PRIVATE_PERSONAL` | V-524 (collapse), V-520, V-521 (via uid value), V-W23-09 | all present |
| LEAK-2a/2b: private uid in a string / list node property (calmroot product, calmroot variant) | V-521 | 2 NODE rows |
| LEAK-2c: private uid in a string relationship property (`HAS_VARIANT.viewedInSnapshotUid`) | V-521 | 1 RELATIONSHIP row (hu:rel:w23-leak-calmroot-variant) |
| LEAK-2d: private uids in a **list** relationship property (`COMPARED_IN_DECISION.optionUids`) | **V-W23-10** (V-521 tests strings only) | V-521: no row for it; V-W23-10: 1 row |
| LEAK-2e minimal pair: class only, no private uid: `private-personal` vs `PRIVATE_PERSONAL` | lower: V-521 + V-W23-09; upper: **V-W23-09 only** | lower: V-521 row (and V-115, Product is indexed); upper: no V-521 row, V-W23-09 row |
| LEAK-3: fulltext index over `UserGoalVersion.goalStatement` + a private goal version with searchText | V-W23-04, V-115, V-116, V-520, V-521, V-W23-09 | V-W23-04 1; V-115 2 (goal version, class-lower product); V-116 1; V-520 includes it; V-521 includes it; V-W23-09 includes it |

Totals (run): V-113 1, V-114 2, V-115 2, V-116 1, V-520 3, V-521 7, V-524 2, V-203 1 (collateral); V-W23-04 1, V-W23-09 5, V-W23-10 1.

| Query | Expected | Actual (run) |
|---|---|---|
| Q-L-1 naive 1..2-hop expansion from the SleepWell variant | reachesCalmRootProduct true, privateOnPath true (co-interest inferred) | true, true |
| Q-L-2 QS-6a guard | reachesCalmRootProduct false, privateUidsOnPaths [] ; and it still reaches the CalmRoot variant through the leaked **shared** edge `COMPARED_IN_DECISION` (node guards cannot stop a leak encoded on a shared edge; V-W23-10 reports it) | false, [], reachesCalmRootVariantViaLeakedSharedEdge true |
| Q-L-2b allow-list guard (`privacyClass = 'PUBLIC'`) | reachesCalmRootProduct false, reachesPrivate false | false, false |
| Q-L-3 fulltext query "night shifts" on the shared index | returns the private goal version (the leak itself) | 1 row, hu:private-user-goal-version:w23-leak-g1 |
| Q-L-4 index metadata | w23_leak_goal_search [UserGoalVersion, Product] [goalStatement, name] ONLINE | as expected |

## S4 — CL-018 public-person-only (00 + 11)

| Case | Expected | Actual (run) |
|---|---|---|
| P: public person RECORDS public Observation (source-attributed self-report); case-series participant REPORTS ExperienceReport | no V-W23-05/06 row | none |
| N1: BellLabs user as Person RECORDS an Observation copied from the PCS, no private marker | **V-W23-05 only** (NOT_ASSERTION_BACKED); V-521/V-520/V-524 silent | V-W23-05 row; no other detector |
| N2: same with `derivedFromPersonalMeasurementUid` | V-521 + V-W23-05 | V-521 NODE row (hu:observation:w23-user-serum-mg-marked); V-W23-05 row |
| N3: user POSTS_RESULT to an unclassified ProtocolResult | V-W23-05 (NOT_ASSERTION_BACKED, ENDPOINT_NOT_PUBLIC); V-522 informational | as expected |
| N4: participant tokens `pcs-user-7f3a` and a 64-hex linkage-like token, no sourced record | V-W23-06 (TOKEN_LOOKS_LIKE_INTERNAL_IDENTIFIER, PARTICIPANT_WITHOUT_SOURCED_RECORD) ×2 | as expected |
| N5: inferred HAS_PARTICIPANT_TOKEN from the public person to Participant 12 | V-W23-05 (RETIRED_REIDENTIFICATION_EDGE, NOT_ASSERTION_BACKED) | as expected |

Totals (run): V-W23-05 4 rows, V-W23-06 2 rows, V-521 1, V-522 1 (informational).

## S5 — AnswerRecord negatives (00 + 12)

| Record | Expected | Actual (run) |
|---|---|---|
| N1 asker log (`userUid` private uid, `questionText`) | V-121, V-W23-01b, V-521 (private uid value) | all three |
| N2 OWNER_PRIVATE tier, INCLUDED_FOR_OWNER, PUBLIC class | **V-W23-01a only** (V-121 silent) | V-W23-01a row; no V-121 row |
| N3 cites A2 recorded after the viewpoint | V-W23-02 CITATION_RECORDED_AFTER_VIEWPOINT | as expected |
| N4 cites A1 superseded before the viewpoint | V-W23-02 CITATION_ALREADY_SUPERSEDED_AT_VIEWPOINT | as expected |
| N5 traced, no citation, no schemaDigest, `askerSessionId` | V-121 (schemaDigest), V-W23-01b (askerSessionId: V-121 does not name it), V-W23-03 TRACED_ANSWER_WITHOUT_CITATION | all as expected |
| all five | V-W23-03b informational (no composing Activity) | 5 rows |

## S6 — use authorization and fail-open (00 + 13)

| Case | Expected | Actual (run) |
|---|---|---|
| N1 QUOTE_IN_ANSWER under the ranking policy | **V-W23-07** (POLICY_KIND_NOT_USE_AUTHORIZATION, USE_KIND_NOT_PERMITTED); V-429 silent | as expected |
| N2 quote after expiry (2027-02-01 ≥ 2027-01-01) | V-W23-07 OUTSIDE_EFFECTIVE_PERIOD | as expected |
| N3 SHARE_EXTERNALLY not permitted by v1 | V-W23-07 USE_KIND_NOT_PERMITTED | as expected |
| N4 composition used A2 with no authorization | V-429 | 1 row |
| N5 v2 of the same policy key overlaps v1 (open end) | V-W23-08 POLICY_VERSIONS_POSSIBLY_OVERLAP | as expected |
| N6 unclassified draft policy and legacy run (null class) | V-W23-08 POLICY_LAYER_NOT_INTERNAL (policy); V-522 informational ×2 | as expected |
| Q-FO-1 deny-list with null → PUBLIC | leaks both unclassified nodes | leaksUnclassifiedPolicy true, leaksUnclassifiedLineage true (14 nodes) |
| Q-FO-2 Cypher deny-list without coalesce | neither (null comparison drops the node) | false, false (12 nodes) |
| Q-FO-3 allow-list `privacyClass = 'PUBLIC'` | neither | false, false (12 nodes) |

## Build and runtime checks (`checks/`)

| Check | Tag | Result |
|---|---|---|
| `merge-fragments.mjs` over W23 alone | run | 7 definitions; 0 duplicates; 0 extend blocks; 0 forbidden directives; 10 undefined references, all W00 imports |
| `build-and-roundtrip.mjs` with `build-stub.graphql` (contract B3 as frozen) | run | Neo4jGraphQL build OK; `createAnswerRecords` only; create with assertion citations OK; connect assessment by uid fails (interface lacks uid); read via inline fragments OK; DateTime read fails without APOC |
| same with `build-stub-variant-b-uid-on-archetype.graphql` | run | as above, and connect assessment by uid OK |
| `label-overlap-probe.mjs` | run | union and interface targets return the ClaimOccurrence twice; concrete target once |
| `public-subset.mjs` | run | PUBLIC_ANSWER sub-schema builds; no INTERNAL type; no mutation; no privacyClass/mongoResearchRunId |
| `constraint-violation-tests.cypher` | run | T-1 duplicate (policyKey, versionLabel) rejected; T-3 duplicate (criterionKey, methodVersion) rejected; T-4 duplicate AnswerRecord id rejected; T-5 uid reused across Occurrences rejected; T-2 missing versionLabel, T-6 string-typed recordedAsOf, T-7 accessTier 'PUBLIC' **accepted** on Community (service validation and V-W23-01a/08 required) |
| `operations-enterprise.cypher` on Community | run | 12/12 rejected as Enterprise-only (not counted as passing) |
| `pcs-ddl-sketch.sql` | parser-only | PostgreSQL 18.4 grammar: 24 statements OK; 17.7 grammar: error only at `WITHOUT OVERLAPS`; `EXCLUDE` form OK under both. No PostgreSQL server was run (the sandbox does not let the non-root `postgres` user reach the scratchpad; PostgreSQL 16 binaries are present but unusable here) |

## Essential CQs covered by at least one executed query

CQ-AX-01 (Q-AR-4), CQ-AX-02 (V-W23-01a, S5), CQ-AX-12 (Q-L-1/2/2b/3, S3, S3a), CQ-AX-13 (Q-PP-1/2/3), CQ-RC-01/03 (Q-DR-5 shared half), CQ-RC-05 (V-523 in S1, zero rows), CQ-PC-08 (S1 zero rows; S3/S3a/S4 detections). Private-store-only Essential questions (CQ-PC-01, CQ-PC-02, CQ-PC-04) are contract-level (private-store-interface §3, §8.1) and not executable without a PCS.
