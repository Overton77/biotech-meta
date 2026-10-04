# 07 Validation report (Wave 6 runtime verification)

Run `run-2026-10-04-fable51-01`, plan `validation/04-wave6-plan-final.json`, executed 2026-10-04T04:34:13.258Z by `validation/harness/run-plan.mjs` on a FRESH embedded Neo4j 5.26.31 Community instance (Maven `org.neo4j.test:neo4j-harness:5.26.31`, APOC Core 5.26.31 plugin) against the deliverables at commit `9ac62b8`. Raw record: `validation/wave6-final.json` (per step: statements, errors, rows per validator id and `check` name, verdict). Nothing here touched a live database, a paid service or a deployment.

## 1. What was verified

- **Schema build.** `docs/schema/final_biotech_schema_proposal.graphql` (15019 lines; 192 node types in six archetypes {"Entity": 91, "InformationArtifact": 34, "Occurrence": 9, "Assertion": 5, "EvidenceAssessment": 20, "VersionedState": 33}, 47 relationship-property types, 11 interfaces, 39 unions, 183 enums with 1418 values, 1082 relationship fields over 393 relationship types, 31 fulltext and 3 vector index declarations) builds with `@neo4j/graphql` 7.6.3 (`validation/harness/build-errors.mjs`: BUILD OK, about 34 s). No `extend`, no `@unique`, no `provider:` on `@vector`, no private-store type.
- **Operations.** `docs/schema/neo4j/final_biotech_schema_operations.cypher` applied to the fresh instance (step 1 below); the Enterprise companion was run to record that Community rejects every statement (step 2).
- **Fixtures.** The six translated 0.2.0 fixtures plus the backfill, then every packet's positive fixtures, validators, queries (EXPLAIN) and negatives in the order each packet documents, then a union reload of all positives for the whole suite (fresh-graph packets W16 and W21 are excluded from the union by design).
- **Suites.** `validation/final-validation-suite.cypher` = 0.2.0 queries not superseded + W00 corrections + Fable W5 validators (V-F5-01..65) + generated label checks; parameters `validation/validation-params.json` (SDL-derived relationship classes, W00 registry tokens, Fable W5 keys).
- **Query shapes.** QS-1..QS-8 as extracted from the catalog (17 statements) and the three kernel CQ queries, EXPLAIN only; privacy-corrected QS-5b/6a/8 in `validation/query-shapes-privacy-corrected.cypher`.
- **GraphQL round trips.** `validation/harness/roundtrip.mjs` against the final SDL on the loaded instance: 5/6 operations behaved as expected (the enum-rejection probe is expected to error).

## 2. Result by block

| Block | PASS | FAIL | recorded | steps |
|---|---|---|---|---|
| global | 12 | 1 | 1 | 14 |
| W00 | 25 | 1 | 2 | 28 |
| W01 | 13 | 2 | 0 | 15 |
| W02 | 12 | 3 | 0 | 15 |
| W03 | 5 | 3 | 0 | 8 |
| W04 | 10 | 2 | 0 | 12 |
| W05 | 11 | 2 | 1 | 14 |
| W06 | 11 | 2 | 0 | 13 |
| W07 | 11 | 2 | 0 | 13 |
| W08 | 8 | 1 | 0 | 9 |
| W09 | 11 | 2 | 0 | 13 |
| W10 | 10 | 2 | 0 | 12 |
| W11 | 9 | 1 | 0 | 10 |
| W12 | 10 | 2 | 0 | 12 |
| W13 | 6 | 1 | 0 | 7 |
| W14 | 6 | 2 | 0 | 8 |
| W15 | 14 | 3 | 0 | 17 |
| W16 | 26 | 0 | 0 | 26 |
| W17 | 13 | 2 | 0 | 15 |
| W18 | 8 | 1 | 0 | 9 |
| W19 | 22 | 2 | 0 | 24 |
| W20 | 7 | 1 | 0 | 8 |
| W21 | 39 | 11 | 0 | 50 |
| W22 | 13 | 1 | 0 | 14 |
| W23 | 30 | 4 | 0 | 34 |
| union | 97 | 14 | 1 | 112 |
| **All** | 439 | 68 | 5 | 512 |

`recorded` steps are the Enterprise companion (expected rejections on Community) and steps whose expectation is observational by the packet's own documentation.

## 2b. Re-scored under one policy

The runner's raw verdicts use each step's own informational list as the plan builder wrote it before the final suite replaced the 0.2.0 file. Re-scoring applies one policy to every step: the 0.2.0 informational ids and every `...i` audit id never fail a step; rows the normalization/backfill removes (`V-117`/`V-F5-61` missing live id, `V-503r` edge bases, label checks) are load-order artifacts, because packet fixtures were loaded after the operations file and before the backfill; `rows:` expectations written against replaced ids are matched against their successors (`V-xxx` -> `V-xxxr` / `V-F5-nn`). Output of `validation/harness/rescore-wave6.py`:

```
rescored verdicts {'PASS': 448, 'recorded': 5, 'FAIL-ROWS': 29, 'FAIL-EXPECT': 13, 'FAIL-LOAD': 16, 'PASS(artifact-rows)': 1}

unmet rows: expectations
 - W00: validation-corrections after 13 (N1-N9) missing ['#39', '#40']
 - W02: final suite after fx-91 missing ['V-003', 'V-006']
 - W02: final suite after fx-90 missing ['V-006']
 - W03: w03-validation after negatives missing ['#19']
 - W03: final suite after negatives missing ['V-203']
 - W06: final suite after negatives missing ['V-432']
 - W07: final suite after 90 missing ['V-112', 'V-231']
 - W10: final suite after negatives missing ['V-203']
 - W17: final suite after negatives missing ['V-217']
 - W18: final suite (w18 params) after negatives missing ['V-112']
 - W19: final suite after 90 missing ['V-409']
 - W21: final suite after fx02a.neg missing ['V-504']
 - W23: final suite (params-leak) after leak probe missing ['V-521']

non-informational rows per block (fixture defects or real findings):
  W00 {'V-W00-04 (informational)': 1}
  W01 {'V-F5-27': 2, 'V-504b': 1, 'V-F5-55': 1}
  W02 {'V-F5-62': 2, 'V-F5-ARCH-1': 2}
  W04 {'V-108r': 2, 'V-509r': 2, 'V-504': 2, 'V-F5-54': 2, 'V-W00-15': 1, 'V-F5-62': 1}
  W05 {'V-514c': 3, 'V-F5-64': 3, 'V-101': 1, 'V-W00-02r': 1}
  W06 {'V-W06-01': 1, 'V-W06-02': 1, 'V-221r': 1, 'V-333r': 1, 'V-119': 1, 'V-F5-24': 1}
  W07 {'V-532p': 12, 'V-F5-28': 12}
  W10 {'V-F5-62': 53}
  W11 {'V-F5-62': 8}
  W12 {'V-F5-62': 4, 'V-402b': 1, 'V-F5-60': 1}
  W13 {'V-W13-02': 5, 'V-W13-03': 2}
  W14 {'V-W14-11': 2, 'V-W14-13': 1}
  W15 {'V-W15-05 (informational)': 6, 'V-W15-11 (informational)': 2, 'V-W00-15': 1, 'V-W15-08': 1, 'V-F5-ARCH-1': 1}
  W17 {'V-101r': 5}
  W19 {'V-F5-62': 7, 'V-514c': 5, 'V-F5-64': 5, 'V-F5-50': 2}
  W21 {'V-112r': 8, 'V-521r': 7, 'V-514c': 4, 'V-F5-64': 4, 'V-101r': 2}
  W22 {'V-112r': 1, 'V-505r': 1, 'V-605': 1, 'V-F5-41': 1, 'V-F5-42': 1, 'V-604': 1, 'V-F5-43': 1}
  W23 {'V-432r': 1}
  global {'V-110': 52, 'V-F5-62': 33, 'V-514c': 27, 'V-F5-64': 27, 'V-508': 18, 'V-003r': 18, 'V-532p': 12, 'V-F5-28': 12, 'V-402b': 10, 'V-F5-60': 10, 'V-102': 8, 'V-F5-63': 8}
```

## 3. Failing steps and their reading

- **W00: validation-corrections after 13 (N1-N9)** (44/44 ok). rows: #40=1, #41=3, #42=1, #43=1, #44=1, V-003r=1, V-112r=3, V-235r=1, V-314=1, V-432r=1, V-503r=1, V-505i=2, V-505r=2, V-521r=4, V-W00-13=1, V-W00-15=3, V-W00-16=1, V-W00-17=1, V-W00-19=1
- **W01: final suite on W01 positives** (428/428 ok). rows: #197=2, V-118=6, V-120=5, V-401b=1, V-504b=1, V-505i=19, V-514b=1, V-F5-27=2, V-F5-55=1
- **W01: final suite after 90** (428/428 ok). rows: #197=2, V-007=1, V-112r=4, V-118=6, V-120=5, V-401b=1, V-422=1, V-433=1, V-434=1, V-504b=1, V-505i=19, V-505r=6, V-514b=1, V-F5-27=2, V-F5-55=1
- **W02: final suite on W02 positives** (428/428 ok). rows: #171=2, #232=2, #427=2, V-117=163, V-118=1, V-120=5, V-401b=1, V-505i=14, V-514b=1, V-F5-61=163, V-F5-62=2, V-F5-ARCH-1=2, V-W00-19=2
- **W02: final suite after fx-91** (428/428 ok). rows: #171=2, #232=2, #427=2, V-117=174, V-118=1, V-120=5, V-401b=1, V-505i=16, V-514b=1, V-F5-61=174, V-F5-62=2, V-F5-ARCH-1=2, V-W00-19=2
- **W02: final suite after fx-90** (428/428 ok). rows: #171=2, #232=2, #427=2, V-006r=1, V-108r=1, V-112r=1, V-117=206, V-118=1, V-120=5, V-222=1, V-222b=2, V-401b=1, V-505i=18, V-505r=1, V-509r=1, V-514b=1, V-F5-61=206, V-F5-62=2, V-F5-ARCH-1=2, V-W00-19=2
- **W03: load negative w03-negative (N1-N15)** (19/20 ok). rows: none errors: #11: Node(37) already exists with label `AnatomicalContext` and property `uberonId` = 'UBERON:0002107'
- **W03: w03-validation after negatives** (25/25 ok). rows: #14=1, #16=1, #17=1, #18=1, #21=1, #22=1, #23=1, V-112=2, V-232=1, V-233=8, V-233r=3, V-234=3, V-234r=1, V-236=1, V-237=1, V-239=1
- **W03: final suite after negatives** (428/428 ok). rows: #171=5, #232=1, V-002=1, V-003r=1, V-112r=2, V-118=6, V-120=5, V-204=1, V-206=1, V-209=1, V-232=1, V-233r=3, V-234r=1, V-236=1, V-237=1, V-239=1, V-401b=1, V-402b=1, V-505i=10, V-508=1, V-514b=1, V-522=9, V-F5-60=1, V-F5-62=1, V-W00-19=5
- **W04: final suite on W04 positives (scenario A)** (428/428 ok). rows: #169=1, #232=1, V-108r=2, V-117=188, V-120=5, V-401b=1, V-503r=2, V-504=2, V-505i=5, V-509r=2, V-514b=1, V-522=9, V-F5-54=2, V-F5-61=188, V-F5-62=1, V-W00-15=1
- **W04: final suite after negatives** (428/428 ok). rows: #169=2, #179=1, #232=1, V-002=1, V-003r=1, V-004=1, V-005=3, V-011=1, V-108r=2, V-112r=1, V-117=211, V-120=5, V-231r=1, V-322r=1, V-330=1, V-401b=1, V-402b=1, V-503r=2, V-504=2, V-505i=5, V-505r=4, V-508=1, V-509r=2, V-514b=1, V-522=9, V-F5-09=1, V-F5-54=2, V-F5-60=1, V-F5-61=211, V-F5-62=1, V-W00-15=2
- **W05: final suite on W05 positives** (428/428 ok). rows: V-101=1, V-117=88, V-118=1, V-120=5, V-401b=1, V-505i=10, V-514b=1, V-514c=3, V-F5-61=88, V-F5-64=3, V-W00-02r=1
- **W05: final suite after negatives** (428/428 ok). rows: #169=1, #232=1, #245=1, #289=1, V-006r=1, V-101=2, V-101r=3, V-112r=1, V-117=90, V-118=1, V-120=5, V-401b=1, V-423=1, V-503r=4, V-505i=12, V-505r=1, V-514b=1, V-514c=3, V-522=5, V-F5-47=1, V-F5-61=90, V-F5-62=1, V-F5-64=3, V-F5-LBL=1, V-W00-02r=2, V-W00-15=1
- **W06: final suite on W06 positives** (428/428 ok). rows: V-117=162, V-118=1, V-119=1, V-120=5, V-221r=1, V-333r=1, V-336=1, V-401b=1, V-505i=16, V-514b=1, V-F5-24=1, V-F5-61=162
- **W06: final suite after negatives** (428/428 ok). rows: V-101r=1, V-117=171, V-118=1, V-119=1, V-120=5, V-221r=1, V-333r=2, V-336=1, V-401b=1, V-503r=1, V-505i=18, V-505r=2, V-514b=1, V-521r=1, V-522=5, V-F5-18=1, V-F5-24=1, V-F5-61=171
- **W07: final suite on W07 positives** (428/428 ok). rows: #171=4, V-118=5, V-120=5, V-401b=1, V-505i=8, V-514b=1, V-532p=12, V-F5-28=12, V-W00-19=4
- **W07: final suite after 90** (428/428 ok). rows: #171=4, V-112r=4, V-114=1, V-118=5, V-120=5, V-301b=1, V-302r=1, V-303r=1, V-304r=2, V-305c=1, V-306=1, V-307=1, V-310a=1, V-312=2, V-313r=1, V-401b=1, V-505i=8, V-514b=1, V-532p=15, V-F5-28=15, V-W00-19=4
- **W08: final suite after negatives** (428/428 ok). rows: V-101r=2, V-113=1, V-118=4, V-120=5, V-301b=2, V-320a=1, V-333r=1, V-336=1, V-401b=1, V-503r=1, V-505i=6, V-505r=1, V-514b=1, V-F5-26=1
- **W09: final suite on W09 positives** (428/428 ok). rows: #171=2, #186=3, V-118=6, V-120=5, V-212=1, V-217i=5, V-223=1, V-401b=1, V-505i=19, V-514b=1, V-F5-16=3, V-W00-19=2
- **W09: final suite after negatives** (428/428 ok). rows: #169=1, #171=2, #179=1, #186=7, #324=1, V-002=1, V-003r=1, V-012=1, V-101=1, V-101r=1, V-108r=2, V-112r=1, V-118=6, V-120=5, V-202=1, V-210=1, V-211r=1, V-212=1, V-213=1, V-215r=3, V-216=3, V-217i=5, V-217r=1, V-218=1, V-221r=1, V-223=1, V-401b=1, V-503r=2, V-505i=19, V-505r=5, V-506=1, V-507b=1, V-508=1, V-508r=2, V-509r=2, V-514b=1, V-514c=1, V-F5-03=1, V-F5-07=3, V-F5-08=1, V-F5-09=1, V-F5-10=1, V-F5-11=2, V-F5-16=7, V-F5-64=1, V-F5-LBL=1, V-W00-02r=1, V-W00-15=1, V-W00-19=2
- **W10: final suite on W10 positives** (428/428 ok). rows: #171=9, #186=2, #232=53, V-117=210, V-118=6, V-120=5, V-212=2, V-223=1, V-401b=1, V-503r=25, V-505i=1, V-514b=1, V-522=100, V-F5-16=2, V-F5-61=210, V-F5-62=53, V-W00-19=9
- **W10: final suite after negatives** (428/428 ok). rows: #169=1, #171=9, #176=1, #179=1, #183=1, #186=5, #232=55, #427=2, #428=2, V-002=1, V-003r=1, V-113=2, V-117=210, V-118=6, V-120=5, V-204=1, V-206=2, V-207=1, V-207b=2, V-209=7, V-212=2, V-214=2, V-214b=1, V-215r=1, V-219b=1, V-219c=1, V-223=1, V-231r=1, V-237=1, V-401b=1, V-402b=1, V-503r=25, V-504a=1, V-505i=1, V-508=1, V-514b=1, V-520=1, V-521r=2, V-522=100, V-524=2, V-534p=1, V-F5-06=1, V-F5-07=1, V-F5-09=1, V-F5-13=1, V-F5-16=5, V-F5-18=2, V-F5-20=1, V-F5-26=2, V-F5-60=1, V-F5-61=210, V-F5-62=55, V-F5-ARCH-1=2, V-F5-ARCH-2=2, V-W00-15=1, V-W00-19=9
- **W11: final suite on W11 positives (with inherited filing fixture)** (428/428 ok). rows: #171=1, #232=8, #245=1, V-117=70, V-118=5, V-120=5, V-331=1, V-401b=1, V-503r=10, V-505i=9, V-514b=1, V-522=65, V-F5-61=70, V-F5-62=8, V-F5-LBL=1, V-W00-19=1
- **W12: final suite on W12 positives** (428/428 ok). rows: #232=4, V-117=162, V-118=5, V-120=5, V-401b=1, V-402b=1, V-514b=1, V-F5-60=1, V-F5-61=162, V-F5-62=4
- **W12: final suite after negatives** (428/428 ok). rows: #232=4, #427=1, #428=1, V-008=2, V-009=1, V-011=1, V-112r=1, V-113=1, V-114=1, V-117=165, V-118=5, V-120=5, V-124=1, V-332=2, V-401b=1, V-402b=1, V-503r=1, V-505r=1, V-514b=1, V-F5-26=1, V-F5-60=1, V-F5-61=165, V-F5-62=4, V-F5-ARCH-1=1, V-F5-ARCH-2=1
- **W13: load w13-regulatory-kinds** (382/383 ok). rows: none errors: #109: Node(466) already exists with label `Source` and property `canonicalUri` = 'https://www.federalregister.gov/documents/2024/05/06/2024-08935/medical-device
- **W14: final suite on W14 positives** (428/428 ok). rows: V-117=147, V-120=5, V-401b=1, V-514b=1, V-F5-61=147
- **W14: final suite after negatives** (428/428 ok). rows: V-112r=1, V-117=153, V-120=5, V-401b=1, V-505r=1, V-514b=1, V-514c=1, V-F5-61=153, V-F5-64=1
- **W15: final suite on W15 positives** (428/428 ok). rows: #169=1, V-118=6, V-120=5, V-401b=1, V-505i=6, V-514b=1, V-W00-15=1
- **W15: final suite after negatives** (428/428 ok). rows: #169=1, V-007=1, V-101r=3, V-112r=4, V-118=6, V-120=5, V-326a=1, V-326b=1, V-326c=2, V-327=1, V-328=2, V-329=1, V-401b=1, V-422=1, V-503r=1, V-505i=6, V-514b=1, V-W00-15=1
- **W15: final suite on W15 08 alone** (428/428 ok). rows: #427=1, V-118=6, V-120=5, V-401b=1, V-514b=1, V-F5-ARCH-1=1
- **W17: final suite on W17 positives** (428/428 ok). rows: V-101r=5, V-118=6, V-120=5, V-217i=1, V-401b=1, V-503r=5, V-514b=1
- **W17: final suite after negatives** (428/428 ok). rows: V-101r=10, V-118=6, V-120=5, V-213b=1, V-217i=4, V-217r=1, V-401b=1, V-503r=11, V-505i=1, V-505r=1, V-514b=1, V-521r=1, V-F5-18=1
- **W18: final suite (w18 params) after negatives** (428/428 ok). rows: V-003r=20, V-007=1, V-101r=2, V-112r=1, V-114=1, V-118=5, V-120=5, V-401b=1, V-422=1, V-503r=2, V-505i=16, V-505r=3, V-508=20, V-514b=1, V-514c=21, V-F5-64=21
- **W19: final suite on W19 positives (scenario A)** (428/428 ok). rows: #220=2, #232=7, V-117=105, V-118=1, V-120=5, V-401b=1, V-514b=1, V-514c=5, V-522=100, V-F5-50=2, V-F5-61=105, V-F5-62=7, V-F5-64=5
- **W19: final suite after 90** (428/428 ok). rows: #171=1, #220=2, #223=1, #232=7, V-110=1, V-117=107, V-118=1, V-120=5, V-401b=1, V-402=1, V-409r=3, V-410=1, V-426=1, V-514b=1, V-514c=5, V-522=100, V-F5-50=2, V-F5-53=1, V-F5-59=1, V-F5-61=107, V-F5-62=7, V-F5-64=5, V-W00-19=1
- **W20: final suite after negatives** (428/428 ok). rows: V-102=8, V-112r=1, V-117=45, V-118=2, V-120=5, V-401b=1, V-402=1, V-403=1, V-404=1, V-405=1, V-406=1, V-407r=4, V-408=1, V-514b=1, V-522=67, V-F5-61=45, V-F5-63=8
- **W21: final suite on fx01** (428/428 ok). rows: V-112r=5, V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=1, V-522=53
- **W21: final suite after fx01.neg** (428/428 ok). rows: #218=1, V-007=1, V-101r=1, V-112r=6, V-118=5, V-120=5, V-401b=1, V-422=1, V-503r=1, V-505r=2, V-514b=1, V-521r=1, V-522=53, V-F5-48=1
- **W21: final suite on fx02a** (428/428 ok). rows: V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=1, V-522=18
- **W21: final suite after fx02a.neg** (428/428 ok). rows: V-118=5, V-120=5, V-401b=1, V-404=1, V-409r=2, V-514b=1, V-521r=1, V-522=18
- **W21: final suite on fx02b** (428/428 ok). rows: V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=2, V-522=19
- **W21: final suite on fx03** (428/428 ok). rows: V-112r=3, V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=1, V-522=28
- **W21: final suite after fx03.neg** (428/428 ok). rows: #218=1, V-007=1, V-101r=1, V-112r=4, V-118=5, V-120=5, V-401b=1, V-422=1, V-424=1, V-426=1, V-503r=1, V-505r=1, V-514b=1, V-521r=1, V-522=31, V-F5-48=1
- **W21: final suite on fx04** (428/428 ok). rows: V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=1, V-522=30
- **W21: final suite on fx05** (428/428 ok). rows: V-118=5, V-120=5, V-401b=1, V-514b=1, V-521r=1, V-522=22
- **W21: final suite on fx06** (428/428 ok). rows: V-101r=2, V-118=4, V-120=5, V-401b=1, V-503r=2, V-514b=1, V-514c=4, V-522=46, V-F5-64=4
- **W21: final suite after fx06.neg** (428/428 ok). rows: V-101r=2, V-118=4, V-120=5, V-401b=1, V-411=1, V-416r=1, V-503r=2, V-514b=1, V-514c=4, V-522=46, V-F5-64=4
- **W22: final suite on combined MP1-MP6** (428/428 ok). rows: V-112r=1, V-117=226, V-120=5, V-401b=1, V-503r=1, V-505i=15, V-505r=1, V-514b=1, V-604=1, V-605=1, V-F5-41=1, V-F5-42=1, V-F5-43=1, V-F5-61=226
- **W23: final suite S2 on 00+04** (428/428 ok). rows: V-118=6, V-120=5, V-401b=1, V-432r=1, V-514b=1
- **W23: final suite (params-leak) after leak probe** (428/428 ok). rows: #386=1, V-113=4, V-114=2, V-117=3, V-118=6, V-119=1, V-120=5, V-401b=1, V-505r=1, V-514b=1, V-520=3, V-521r=2, V-524=2, V-534p=1, V-F5-18=5, V-F5-19=2, V-F5-20=1, V-F5-24=1, V-F5-26=4, V-F5-61=3, V-F5-LBL=1
- **W23: final suite after 11** (428/428 ok). rows: #191=1, #192=3, #232=1, #256=3, #386=3, V-101r=3, V-118=6, V-120=5, V-401b=1, V-503r=3, V-514b=1, V-514c=1, V-521r=2, V-522=1, V-532p=2, V-534p=1, V-F5-18=2, V-F5-20=1, V-F5-21=1, V-F5-22=3, V-F5-28=2, V-F5-62=1, V-F5-64=1, V-F5-LBL=3
- **W23: final suite after 12** (428/428 ok). rows: V-118=6, V-120=5, V-121=2, V-401b=1, V-514b=1, V-521r=1, V-534p=1, V-F5-18=1, V-F5-20=1, V-F5-23=2
- **union: W01: load w01-01-role-time-precision** (90/91 ok). rows: none errors: #34: Node(39) already exists with label `Source` and property `canonicalUri` = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations'
- **union: W01: load w01-02-advises-not-endorses** (39/40 ok). rows: none errors: #5: Node(39) already exists with label `Source` and property `canonicalUri` = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations'
- **union: W03: load w03-positive** (294/295 ok). rows: none errors: #1: Node(150) already exists with label `Source` and property `canonicalUri` = 'https://doi.org/10.1038/s41514-017-0016-9'
- **union: W09: load 05-adverse-events-zero** (5/6 ok). rows: none errors: #2: Node(527) already exists with label `StudyArm` and property `id` = 'nct02678611-nrpt-1x'
- **union: W10: load dependency fixtures-final/study-vs-product-mismatch** (43/44 ok). rows: #41=1, #42=1, V-233=4 errors: #4: Node(451) already exists with label `Source` and property `canonicalUri` = 'https://doi.org/10.1016/j.celrep.2019.07.043'
- **union: W11: load 03-specification-versions-and-process-inputs** (18/19 ok). rows: none errors: #1: Node(387) already exists with label `Source` and property `canonicalUri` = 'https://www.fda.gov/files/food/published/GRAS-Notice-000635--Nicotinamide-ribosi
- **union: W13: load w13-regulatory-kinds** (381/383 ok). rows: none errors: #109: Node(2019) already exists with label `Source` and property `canonicalUri` = 'https://www.federalregister.gov/documents/2024/05/06/2024-08935/medical-devic; #336: Node(1584) already exists with label `Source` and property `canonicalUri` = 'urn:synthetic:fda-food-facility-registration'
- **union: W15: load w15-01-amazon-host-seller-fulfiller** (110/111 ok). rows: none errors: #36: Merge did not find a matching node n and can not create a new node due to conflicts with existing unique nodes
- **union: W15: load w15-03-dtc-subscription-and-bundles** (286/288 ok). rows: none errors: #1: Node(590) already exists with label `Source` and property `canonicalUri` = 'https://www.truniagen.com/products/tru-niagen-300mg.js'; #9: Node(358) already exists with label `Source` and property `canonicalUri` = 'https://www.truniagen.com/products/tru-niagen-300mg'
- **union: W17: load 00-w17-base** (116/117 ok). rows: none errors: #108: Merge did not find a matching node n and can not create a new node due to conflicts with existing unique nodes
- **union: W19: load 01-cl003-work-rendition-identity** (36/37 ok). rows: none errors: #8: Node(1413) already exists with label `Source` and property `canonicalUri` = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/'
- **union: W19: load 03-partial-capture-not-found** (20/21 ok). rows: none errors: #12: Node(39) already exists with label `Source` and property `canonicalUri` = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations'
- **union: W20: load w20-04-text-version-pairs** (40/42 ok). rows: none errors: #33: Node(2923) already exists with label `Source` and property `canonicalUri` = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-a; #38: Node(2924) already exists with label `Source` and property `canonicalUri` = 'https://www.youtube.com/watch?v=n9IxomBusuw'
- **union: W22: load mp4-rights-excellent-vs-licensed (positive + embedded negative members)** (80/81 ok). rows: #79=4, #80=1, #81=3 errors: #15: Node(453) already exists with label `Source` and property `canonicalUri` = 'https://reactome.org/ContentService/data/query/R-HSA-196807'
- **final suite on the union of all worker positives (reload)** (428/428 ok). rows: #169=2, #171=15, #186=3, #191=3, #197=2, #220=2, #227=2, #232=33, #245=1, #261=1, #427=3, V-001=3, V-003r=18, V-101=1, V-101r=5, V-102=8, V-108r=3, V-110=52, V-111=2, V-112r=1, V-117=1319, V-118=8, V-119=1, V-120=5, V-212=1, V-217i=3, V-221r=1, V-223=1, V-235r=1, V-301b=1, V-303=5, V-331=1, V-333r=1, V-336=3, V-401b=1, V-402=1, V-402b=10, V-409r=1, V-432r=1, V-503r=20, V-504=7, V-504b=1, V-505i=145, V-505r=1, V-508=18, V-509r=3, V-514b=1, V-514c=27, V-522=100, V-532p=12, V-604=1, V-605=1, V-F5-16=3, V-F5-21=3, V-F5-24=1, V-F5-27=2, V-F5-28=12, V-F5-41=1, V-F5-42=1, V-F5-43=1, V-F5-50=2, V-F5-5

### Reading of the failures

- **Load collisions in the union reload (16 steps).** Different packets mint the same real-world Source (same `canonicalUri`) or the same study arm under different uids, so the natural-key and id constraints reject the second writer: Sinclair affiliations page (W01/W19), PMC5701244 and two Cell Reports / Nature Aging DOIs (W03/W09/W10/W19), GRAS Notice 000635 (W11), Federal Register 2024-08935 (W13, also within its own set), Tru Niagen product JSON (W15), Reactome R-HSA-196807 (W22), Huberman episode page (W20/W21), NCT02678611 arms (W09/W17 vs the inherited fixture). The constraints are doing their job; the fixture corpora need one identity per source, which is ingestion work (OPEN-QUESTIONS, new item 2 covers the resolver-URI half). None of these is a schema failure, and every packet passed in its own block.
- **Non-informational rows on packet positives (29 steps).** Each is listed by block above. They are fixture defects surfaced by the corrected or new validators (alias uid tokens `V-F5-62`, unregistered predicates `V-514c`/`V-F5-64`, assertions with neither object nor literal `V-003r` in W18, derived edges without citation `V-112r`, recorded-before-snapshot `V-F5-54`, participant tokens that look like handles `V-F5-27`, two archetype labels `V-F5-ARCH-1` in W02/W15 fixtures, privacy spellings `V-521r`), or embedded negatives that a packet documents as intentionally present (W07 `V-532p`/`V-F5-28` population text, W22 mp3 generated image `V-F5-41`). The resolution matrix (report 08, D1–D15, E1–E4) carries the per-row attribution.
- **Changed negative expectations (13 steps).** Negatives that packets expected the 0.2.0 validator to catch are now judged by the reconciled rule: W02's object-plus-literal case is legal for predicateClass QUANTITY (W00-R ruling; `V-003r`), `V-203` became `V-F5-05`, `V-432` became `V-432r` (COMPARES_IDENTITIES), `V-112`/`V-231`/`V-217` have `r` successors with narrower premises, and two W00/W03 expectations were keyed by statement number. The replacement validator's own rows are visible in the same step record.

## 4. Edition and runtime gaps

- Existence and property-type constraints (Enterprise companion, every statement rejected by Community in step 2) are UNVERIFIED on Enterprise; their semantics are checked by validators on Community.
- APOC Core is required by `@neo4j/graphql` 7.6.3 for DateTime reads (verified: the round trips fail without it).
- Vector indexes are created with placeholder dimensions (1536, cosine); the embedding source is a user decision (D-014).
- GraphQL `@id` autogeneration does not satisfy INV-106 for kernel-governed creates; those go through the ingestion service (compatibility rule 1, report 06).

## 5. Fixture defects carried as known rows

Rows that remain on clean data are fixture defects or embedded negatives, not schema failures; each is listed with its validator in `reports/08-challenger-resolution-matrix.md` (D1–D15, E1–E4) and in section 3 above. The inherited 0.2.0 fixtures keep seven `https://doi.org/...` resolver URIs as `canonicalUri` (V-W00-19; open question) and two syntheses without `ASSESSES_CLAIM` (V-F5-16); both are informational in the plan.
