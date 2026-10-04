# W04 fixtures and queries

All files are in `fixtures/`. They were **run** on 2026-10-04 against an embedded Neo4j **5.26.31 Community** instance (in-process harness of this run: `validation/harness`, `EmbeddedNeo4j` with `-Xmx768m`, its own empty store directory, wiped with `MATCH (n) DETACH DELETE n` between scenarios). The runner is `run-cypher.mjs`: each `;`-separated statement runs in its own transaction and variables never cross `;`. Baseline validation is `docs/schema/neo4j/validation.cypher` with the run's `validation-params.json`. Raw query output is in `fixtures/w04-query-results-2026-10-04.jsonl`.

## Files

| File | Content | Real / synthetic | Statements |
|---|---|---|---|
| `w04-01-correction-vs-fact-ending.cypher` | round-0007 minimal pair on HAS_FORMULATION_VERSION: Pair A (publisher ERRATUM, SOURCE_CORRECTION) vs Pair B (reformulation, VALIDITY_BOUNDED + new version) | SYNTHETIC_FIXTURE | 15 |
| `w04-02-package-vs-formulation-change.cypher` | Tru Niagen 300mg: one variant, one formulation, concurrent 30/90 packages with GTINs and SKUs, label for the 90-count package with servings per container; 150mg as a separate variant. Synthetic product: package 30→60 on 2026-04-01 with no formulation change | real (S08, S09) + synthetic | 39 |
| `w04-03-declared-calculated-measured.cypher` | Tru Niagen declaration (LISTED_INGREDIENT_AS_LISTED, %DV NOT_APPLICABLE) vs CALCULATED NR cation 263.42 mg (PubChem MWs) vs synthetic measured lot result 309 mg | real (S08, S12) + synthetic result | 19 (load after 02) |
| `w04-04-basis-history-and-trial.cypher` | Basis: five archived label captures, per-line TEXT_QUOTE locators, REANCHORS (EXACT/FUZZY/none), two silent revision events, two as-declared formulation versions (current vs historical), NCT02678611 "Basis 250" with 2016-01..2016-07 period, archived 2016 brand page, identity hypotheses | real (S02–S07, S13) | 33 |
| `w04-05-negatives.cypher` | 13 negative cases N01–N13 | SYNTHETIC_FIXTURE | 13 |
| `w04-06-elysium-basis-compat.cypher` | backfill companion for `examples/elysium-basis.cypher` (archetype fields, bases, serving, projected episodes, LABEL_FOR) | repository fixture | 11 |
| `w04-validation.cypher` | V-W04-01 … V-W04-12 | — | 12 |
| `w04-queries.cypher` | Q-W04-01 … Q-W04-10 | — | 10 |

Uid tokens: all registered except `package-configuration`, `serving-definition`, `quantity-declaration` (requested, W04-SR-01) and W12's `lot` / `test-execution` (fixture 03, W12 to register).

## Scenarios run and outcomes

| Scenario | Load | Load result | Baseline validation rows (174 statements, 0 errors) | W04 validation rows |
|---|---|---|---|---|
| A canonical | elysium-basis, 01, 02, 03, 04, 06 | all statements ok | V-108 ×2 (Basis possible overlap, see W04-SR-03), V-110 ×3 (elysium time-dependent, W04-SR-12), V-401b (2, elysium SECTION locators, informational), V-409 ×3 (archive ordering, W04-SR-02), V-509 ×2 (POSSIBLE_OVERLAP_REVIEW, expected), V-514b (6, elysium), V-522 (9 elysium nodes) | **0** |
| B0 elysium alone | elysium-basis | ok | V-110 ×3 (fixture by itself after 2026-10-04T00:00Z) + informational | V-W04-05 ×2, V-W04-09 ×1, V-W04-10 ×1, V-W04-12 ×3: the 0.1.0 gaps that fixture 06 backfills |
| B-01 alone | 01 | ok | informational only (V-401b = 0, V-514b = 0) | 0 |
| B-02 alone | 02 | ok | informational only | 0 |
| B-03 alone | 03 | ok | V-005 ×1 (component's USES_MATERIAL lives in 02) | V-W04-09, V-W04-10 (same reason): documented load-order dependency |
| B-04 alone | 04 | ok | V-108, V-409 ×3, V-509 (as in A) | 0 |
| D collision | 04, 02, 03, elysium, study-vs-product-mismatch, 06, 01 | all ok | as A plus study fixture informational (V-212 ×2, V-223 ×1); **no V-000a / V-002 / V-003 rows** (no duplicate identities) | **0** |
| E compatibility | elysium-basis, 06 | all ok | V-110 ×3 (pre-existing, W04-SR-12), V-401b, V-514b, V-522 (informational) | **0** (fixture 06 removes the B0 rows) |
| B5 (first attempt, before fix) | 04, elysium, ... | ok | V-000a/V-002/V-003: `hu:material:elysium-nr-e` duplicated because fixture 04 MERGEd it without the `BrandedIngredientMaterial` label. **Fixed** by aligning label sets; scenario D is the re-test | — |
| C negatives | 05 alone | ok | expected: V-002/V-003 (N02 stub assertion), V-004 (N01), V-005 ×3, V-011 (N04), V-108 + V-508 + V-509 (N08), V-112 NO_CITATION (N01), V-201 (N12), V-231 (N06 claims DIRECT_MEASUREMENT), V-322 (N07), V-330 (N05) | V-W04-01 ×2 (N13), V-W04-02 ×2 (N01, N02), V-W04-03 (N07), V-W04-04 (N06), V-W04-05 (N10), V-W04-06 (N11), V-W04-07 (N09), V-W04-08 (N08 edge CA vs FV US), V-W04-10 ×5 (negative FVs without components), V-W04-11 ×2 (N04, N05 orphans) |

Every forbidden implication in W04's area has a negative case or a validation reference: `[LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]` → Q-W04-10 (parser-run, no listing data) and V-W04-01 (LABEL_FOR endpoint); `[LISTED_INGREDIENT_AMOUNT, ACTIVE_MOIETY_AMOUNT]` → N06/V-W04-04; `[PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]` → W02's fixtures (CQ-ID-03 query lists both predicates); `[MARKER_CONSTITUENT_AMOUNT, TOTAL_CONSTITUENT_AMOUNT]` → V-W04-05 (MARKER_CONSTITUENT is an allowed referent, never ACTIVE_MOIETY), no botanical fixture in this run; `[USES_INTERVENTION_MATERIAL, EVALUATES_PRODUCT]` → N02, N12; INV-005 → N01/N11; INV-006 → N04; INV-201 → N12; V-322 → N07.

## Queries: parameters and observed results (status: **run**)

| Query | CQ | Parameters | Observed result |
|---|---|---|---|
| Q-W04-01 (QS-2b verbatim) | CQ-TM-01, CQ-ID-01 | Pair A, R = 2026-05-01, V = 2026-04-01 | `w04-syn-a-200` OPEN_END_STALE, recordedTo 2026-06-15 (believed then) |
| | | Pair A, R = 2026-07-01, V = 2026-04-01 | `w04-syn-a-120-corrected` OPEN_END_SUPPORTED. **Correction:** the 200 mg version has no current attachment |
| | | Pair B, R = 2026-05-01, V = 2026-04-01 | `w04-syn-b-200` OPEN_END_STALE |
| | | Pair B, R = 2026-07-01, V = 2026-04-01 | `w04-syn-b-200` KNOWN_WITHIN [2025-11-01, 2026-06-10). **Fact ending:** the old version is still believed for its interval |
| | | Pair A, R = V = 2026-07-01 | `w04-syn-a-120-corrected` |
| | | Pair B, R = V = 2026-07-01 | `w04-syn-b-150-reformulated` |
| | | Basis, R = 2026-10-05, V = 2023-06-01 | 3 rows, all UNKNOWN_BOTH_BOUNDS: FV-a (lastObservedAt 2025-09-10), FV-b (2026-07-17) and FV-b via the 0.1.0 assertion (2026-07-10). QS-2b alone cannot say which was current in 2023; Q-W04-02 adds the observation windows |
| Q-W04-02 (QS-2b-W04) | CQ-ID-01, CQ-ID-05 | Basis, R = 2026-10-05, V = 2023-06-01 | FV-a first 2021-12-08 / last 2025-09-10 EARLIER_OBSERVED (NR-E 250 mg MATERIAL_AS_IS); FV-b first 2026-03-05 / last 2026-07-17 MOST_RECENTLY_OBSERVED (Elysium NR 250 mg SALT_FORM); plus the 0.1.0 episode (2026-07-10) |
| | CQ-TM-01 | same, R = 2026-10-04T01:00 (before ingestion at 01:12) | 0 rows: nothing believed yet, which is not "no formulation" |
| Q-W04-03 | CQ-ID-02 | NCT02678611, Basis variant, R = 2026-10-05 | interval [2016-01-01, 2016-08-01) (MONTH precision widened); all candidates START_UNKNOWN_FIRST_OBSERVED_AFTER_INTERVAL (first observed 2021-12-08, 2026-03-05, 2026-07-10); labelsObservedBeforeIntervalEnd = 0; **answer FORMULATION_AT_ADMINISTRATION_UNKNOWN**. Qualified by the 2016-03-20 brand page, which names NR and pterostilbene without amounts |
| Q-W04-04 | CQ-ID-05 | Basis FV-a → FV-b | DECLARED_BASIS_CHANGED_COMPOSITION_NOT_ESTABLISHED (texts differ: "NR-E (Patent-Pending Crystalline Nicotinamide Riboside)" vs "Elysium NR (Nicotinamide Riboside Chloride)") |
| | | Pair B 200 → 150 | COMPOSITION_CHANGED |
| | | Pair A 200 → 120 (corrected) | COMPOSITION_CHANGED. The payloads differ; "correction, not change" is read from `SUPERSEDES{SOURCE_CORRECTION}` (Q-W04-01 row 2), not from the diff |
| Q-W04-05 | CQ-ID-05 | synthetic package product, R = 2026-10-05, V1 = 2026-02-01, V2 = 2026-05-01 | packages [30] → [60], one formulation, **PACKAGE_ONLY_CHANGE** |
| | | same, R = 2026-03-01 | [30] → [30], NO_CHANGE_RECORDED (the change was not yet known) |
| | | Pair B variant | **FORMULATION_CHANGE_SAME_PACKAGE** |
| | | Tru Niagen 300mg | [90, 30] at both times: concurrent packages, NO_CHANGE_RECORDED |
| Q-W04-06 | CQ-PF-01 | Tru Niagen label snapshot | declared "NIAGEN® (nicotinamide riboside chloride) 300mg †", 300 mg PER_SERVING, LISTED_INGREDIENT_AS_LISTED, dailyValueStatus NOT_APPLICABLE, material NIAGEN; calculated 263.42 mg NR cation (rule cites PubChem CIDs 439924 and 90480033); measured [309 mg, MEASURED, synthetic]. Three kinds, three records |
| Q-W04-07 | CQ-AX-25 | NR chloride, ≥ 250 mg, V = 2026-10-01 | Tru Niagen 300mg 300 mg SALT_FORM (realization ACCEPTED); Basis FV-a 250 mg MATERIAL_AS_IS and FV-b 250 mg SALT_FORM, realization **PROPOSED** (one row per authorizing episode). The derived CONTAINS edge was not used |
| Q-W04-08 | CQ-AX-17 | Tru Niagen 300mg | 300 mg per serving, 1 unit per serving, 300 mg per capsule; per day NOT_ESTABLISHED (no directions captured) |
| | | Basis | Elysium NR 250 mg per serving, 2 units, 125 mg per capsule; PT 50 mg, 25 mg per capsule; per day NOT_ESTABLISHED (the label's "Take two (2) capsules every morning" was not captured as a DIRECTIONS declaration in this fixture) |
| Q-W04-09 | OPEN-QUESTIONS P0-5 | Basis label Source | PT and serving quotes EXACT across all five captures; NR quote FUZZY (2021→2023), EXACT (2023→2025), **no re-anchor** (2025-09→2026-03), EXACT (2026-03→2026-07); the 0.1.0 SECTION locator stands alone |
| Q-W04-10 | CQ-PF-02 | Tru Niagen variant | 0 rows (no MerchantListing in W04 fixtures; Neo4j warns that the label is unknown). Status: parser-run only; W15 fixtures exercise it |

## Mandatory-case checklist (task brief)

- Round-0007 correction vs fact-ending minimal pair on HAS_FORMULATION_VERSION: fixture 01, Q-W04-01 rows 1–6, V-505/V-506/V-507b clean.
- Package change without formulation change: fixture 02 part 2 (synthetic temporal) and part 1 (real concurrent packages), Q-W04-05.
- Label declaration vs calculated active moiety vs measured result: fixture 03, Q-W04-06, negatives N04/N05/N06.
- Trial naming a brand without a recoverable historical label (CQ-ID-02 qualified answer): fixture 04, Q-W04-03.
- Current vs historical formulation for the same variant with QS-2b: fixture 04, Q-W04-01 (Basis) and Q-W04-02.
- 0.1.0 compatibility fixture stays loadable: `examples/elysium-basis.cypher` loads 24/24 in scenarios A, B0 and D; fixture 06 removes its W04 validation rows.
