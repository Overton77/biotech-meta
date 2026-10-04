# W03 fixtures and queries

All files are under `fixtures/`. Execution: **run** on a fresh embedded Neo4j **5.26.31 Community** (in-process `neo4j-harness`, bolt only) with the run harness `validation/harness/run-cypher.mjs` (one transaction per statement, no variable crosses `;`) and `validation/validation-params.json`, on 2026-10-04. Raw per-statement outcomes are summarized in `fixtures/run-results.json`. Enterprise behaviour not tested. The SDL fragment was built (not only parsed) with `@neo4j/graphql` 7.6.3 against scratch stubs for other owners' types (`fixtures/build-stubs.graphql`): parse OK; `Neo4jGraphQL.getSchema()` OK (1,235 generated types, 46 queries, 54 mutations, `VECTOR_PROVIDER=0`); derived fields are absent from `MechanismCreateInput` and `Condition.icd11Code` from `ConditionUpdateInput` (`@settable` false works as intended).

| File | Content | Statements | Status |
|---|---|---|---|
| `w03-positive.cypher` | 11 Sources, 13 SourceSnapshots (SYNTHETIC_FIXTURE hash), 24 SourceLocators (TEXT_QUOTE, NFC-WS1, real quoteHash), 2 Species, 5 compartments (2 Organs), 3 ChemicalSubstances, 4 IngredientMaterials, StudyArm/StudyIntervention stubs, 6 Biomarkers, 2 MolecularEntities, 2 Mechanisms, 2 Pathways, 3 Conditions, 10 Identifiers with asserted HAS_IDENTIFIER (10 assertions), 8 contexts, 14 mechanism assertions, 1 SUPERSEDES correction, 1 CAPTURE_FIDELITY policy adjudication | 295 | run, 295 ok |
| `w03-projection-job.cypher` | rule `mx-proj/v1` (steps 0-5) and one-to-one projections | 7 | run twice: first creates AFFECTS_MECHANISM 2, APPLIES_TO_SPECIES 2, ACTS_IN 2 (MODULATES 0, INFLUENCES_OUTCOME 0, one-to-one 0); second deletes 6 and recreates 6 (idempotent) |
| `w03-validation.cypher` | V-112 (W03 params), V-230..V-239 verbatim, V-233r, V-234r, V-W03-01..12 | 25 | run on positive and on negative |
| `w03-cq-queries.cypher` | CQ-MX-01..05, CQ-ST-03 referent, CQ-MX-C01..C04 | 11 | run on positive |
| `w03-negative.cypher` | N1-N15 collapses | 20 | run on top of positive |
| `build-stubs.graphql` | scratch stand-ins for W00/W02/W07/W09 types, used only for the library build | — | build input |

## 1. Mandatory cases and where they are

| Case | Fixture nodes | Expected / actual |
|---|---|---|
| Measured vs inferred vs hypothesized for the same proposition | proposition (NR substance, INDUCES_PROCESS, `hu:mechanism:nad-plus-biosynthetic-flux`): Liu liver DIRECT POSITIVE, Liu muscle DIRECT NEGATIVE, Trammell heart INFERRED_FROM_MEASUREMENT with premise `trammell-nr-increases-naad-heart`, Basis paper HYPOTHESIS | CQ-MX-01: 4 rows (DIRECT/NEGATIVE muscle Liu; DIRECT/POSITIVE liver Liu; HYPOTHESIS Dellinger; INFERRED Trammell with premise) — actual 4, as listed |
| Blood vs muscle compartment minimal pair | `dellinger-nrpt-1x-increases-nad-whole-blood` (human, whole blood, arm) vs `elhassan-nr-increases-naad-muscle` (human, skeletal muscle, 1000 mg/d P21D); plus mouse liver/heart | CQ-MX-C04: 5 measurands across 2 analytes, each with its own matrix; N5 (whole-blood measurand in a muscle context) → V-239 1 row |
| Mouse NAD+ tissue vs human whole-blood NAD+ (species + compartment) | Trammell liver v2 (mouse, 185 mg/kg SINGLE_DOSE gavage, male C57Bl/6J 12 wk, n=3, derived HED 15.04 mg/kg) vs Dellinger whole blood (human, 60-80 y, exposure on arm NRPT 1X) | CQ-MX-02 rows show different species, matrix, basis; CQ-MX-04 shows no human exposure evidence for any positive mechanism step |
| Mouse-positive / human-null, APPLIES_TO_SPECIES projected correctly | mitochondrial oxidative function: Zhang mouse POSITIVE, Elhassan human NEGATIVE | CQ-MX-03: Homo sapiens NEGATIVE shortcutEdgeExists false; Mus musculus POSITIVE shortcutEdgeExists true. N3 (human edge citing the null) → V-233r NON_POSITIVE_INPUT, V-234r 1 row |
| Proxy-marker vs flux minimal pair | proxy: `trammell-nr-increases-naad-heart` (Biomarker object; NAAD-heart REFLECTS_MECHANISM flux) and `trammell-nr-heart-nad-level-unchanged` (NEGATIVE); flux: `liu-oral-nr-nad-synthesis-liver` (Mechanism object, isotope tracer) | projection creates AFFECTS_MECHANISM only from the Liu flux assertion (CQ-MX-05: inputs `[DIRECT_MEASUREMENT]`); N4 (edge citing the NAAD proxy) → V-W03-03 1 row and V-W03-01 1 row |
| Derived edge missing its assertion citation | N1: AFFECTS_MECHANISM NR → mitochondrial oxidative function with no citation | V-112 `NO_CITATION`; V-233 row; V-233r `NO_CITATION, UNKNOWN_DERIVATION_RULE` |
| Temporal correction | Trammell liver v1 (abstract-only, exposureStatus NOT_EXTRACTED) superseded by v2 (`SUPERSEDES {EXTRACTION_FIX}`, recordedAt 02:00Z; v1 `recordedTo` 02:00Z, status SUPERSEDED) | V-109 0 rows (positive); CQ-MX-02 returns only v2 (recordedTo filter) |
| Late arrival / revision drift | N15: link curated from a SYNTHETIC revision-7 capture of R-HSA-196807 while the current record is revision 8 | V-W03-10 1 informational row (review, not failure) |
| Identity collision | N8 NAD+ as MolecularEntity METABOLITE; N9 liver duplicated as AnatomicalContext; N11 versioned Reactome id | V-W03-05 1 row; V-W03-06 2 rows; V-W03-09 1 row |
| Missing facts | Zhang exposure NOT_EXTRACTED; Liu gavage cohort sex UNKNOWN; sarcopenia without MONDO; Elhassan muscle NAD+ level not asserted | CQ-MX-02 `exposureStatus NOT_EXTRACTED`; CQ-MX-C03 missing-id listing (2 rows, "no MONDO concept recorded"); N7 zero-for-unknown → V-232 |
| Access leakage | not applicable to W03 content (no private records); positive run: V-113..V-116, V-520, V-521 0 rows | — |

## 2. Expected rows per query (actual = expected in the 2026-10-04 run)

### On positive + projection (zero failing rows expected, except the documented validator conflict)

| Query | Rows | Note |
|---|---|---|
| V-112 (W03 params) | 0 | rule-mode edges are V-112-clean |
| V-230, V-231, V-232, V-235, V-236, V-237, V-238, V-239 | 0 each | |
| **V-233 (verbatim)** | **4** | AFFECTS_MECHANISM ×2, APPLIES_TO_SPECIES ×2: valid rule-mode edges have no `projectionOfAssertionUid` (seam W03-SR-01) |
| **V-234 (verbatim)** | **2** | both mouse APPLIES_TO_SPECIES edges (same cause) |
| V-233r, V-234r | 0 | proposed replacements |
| V-W03-01..09, 11, 12 | 0 each | |
| V-W03-10 (informational) | 0 | |
| neo4j/validation.cypher full suite (174 statements, 174 ok) | V-118 9 (informational), V-233 4, V-234 2, V-401b 1 count row (value 0), V-514b 1 count row (24 assertions without contentHash: fixture assertions omit contentHash) | every other query 0 rows |

### CQ queries (positive)

| Query | Rows | Key values |
|---|---|---|
| CQ-MX-01 | 4 | see section 1 |
| CQ-MX-02 | 10 | one row per current DIRECT_MEASUREMENT assertion (v1 excluded); Trammell liver HED 15.04 mg/kg method named; Dellinger row has studyArm "NRPT 1X" and null exposure fields |
| CQ-MX-03 | 2 | human NEGATIVE / no edge; mouse POSITIVE / edge |
| CQ-MX-C04 | 5 | NAD+: whole blood (human, POSITIVE), heart (mouse, NEGATIVE), liver (mouse, POSITIVE); NAAD: skeletal muscle (human, POSITIVE), heart (mouse, POSITIVE) |
| CQ-MX-04 | 2 | both positive mechanism steps murine; `humanExposureEvidence` false; Zhang exposure NOT_EXTRACTED |
| CQ-MX-05 | 6 | each derived edge rests on one DIRECT_MEASUREMENT POSITIVE murine input |
| CQ-ST-03 (referents) | 6 | NAAD in heart has curated readout-of NAD+ biosynthetic flux |
| CQ-MX-C01 | 2 | R-HSA-196807 Homo sapiens, inferred false, rev 8; R-MMU-196807 Mus musculus, inferred true, rev 1 |
| CQ-MX-C02 | 1 | link revision 8 = observed 8, release 97; identifiers REACTOME_STID R-HSA-196807 and DOI 10.3180/R-HSA-196807.7 |
| CQ-MX-C03 (as-of) | 2 | 2022-06-01 → E88.81; 2026-10-04 → E88.819 |
| CQ-MX-C03 (missing MONDO) | 2 | insulin resistance (HPO HP:0000855, ICD10CM E88.81, E88.819); sarcopenia (ICD10CM M62.84) |

### On positive + negative

| Negative | Validator rows (W03 set) | Additional rows in the repository suite |
|---|---|---|
| N1 uncited derived edge | V-112 NO_CITATION; V-233; V-233r | — |
| N2 projection from HYPOTHESIS | V-233; V-233r NON_MEASURED_INPUT + INPUT_WITHOUT_SINGLE_CONTEXT | — |
| N3 species transfer of a null | V-233 (rule mode); V-234 (Homo sapiens); V-233r NON_POSITIVE_INPUT; V-234r | — |
| N4 proxy as flux | V-233 (rule mode); V-W03-01; V-W03-03 | — |
| N5 compartment collapse | V-239 | — |
| N6 HED without method | V-236 | V-522 (no privacyClass on the negative node) |
| N7 zero for unknown | V-232 | V-522 |
| N8 NAD+ as MolecularEntity | V-W03-05 | V-522 |
| N9 duplicate liver | V-W03-06 (2 rows) | V-522 |
| N10 icd10Code on Condition | V-W03-08 | — |
| N11 versioned pathway id | V-W03-09 | V-522 |
| N12 projectionOfAssertionUid encoding | V-112 CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE (V-233/V-233r pass for this edge) | — |
| N13 EXPOSURE MATCH without human exposure | V-237 | V-203, V-204, V-206, V-209 (incomplete assessment, as intended) |
| N14 inference without premise | V-W03-04 | V-002, V-003 (no subject/object), V-522 |
| N15 stale curated revision | V-W03-10 (informational) | — |

Totals (negative state): V-112 2, V-232 1, V-233 8, V-234 3, V-236 1, V-237 1, V-239 1, V-233r 3, V-234r 1, V-W03-01 1, V-W03-03 1, V-W03-04 1, V-W03-05 1, V-W03-06 2, V-W03-08 1, V-W03-09 1, V-W03-10 1.

## 3. Reproduction

```
cd validation/harness   # with node_modules from the run harness
node run-cypher.mjs <bolt> ../../workers/W03/fixtures/w03-positive.cypher --params ../validation-params.json
node run-cypher.mjs <bolt> ../../workers/W03/fixtures/w03-projection-job.cypher
node run-cypher.mjs <bolt> ../../workers/W03/fixtures/w03-validation.cypher
node run-cypher.mjs <bolt> ../../../../../neo4j/validation.cypher --params ../validation-params.json
node run-cypher.mjs <bolt> ../../workers/W03/fixtures/w03-cq-queries.cypher
node run-cypher.mjs <bolt> ../../workers/W03/fixtures/w03-negative.cypher     # disposable database only
```
The positive fixture is generated data: every statement binds its own nodes by uid; nodes carry their primary and archetype labels; uids use registered tokens except `pathway`, `condition` (requested, W03-SR-04) and the fixture-only `hu:rel:` relationship uids.
