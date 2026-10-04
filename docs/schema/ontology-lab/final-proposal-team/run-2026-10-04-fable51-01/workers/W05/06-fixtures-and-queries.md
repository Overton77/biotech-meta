# W05 fixtures and queries

All fixtures were **run** on an embedded Neo4j **5.26.31 Community** instance (`org.neo4j.test:neo4j-harness`, run harness `validation/harness`, fresh store per run, stopped after the run), on 2026-10-04 with the run's `run-cypher.mjs` (one transaction per statement; variables never cross `;`). Load order for the final run: `operations.cypher`, files 1–7, validation, CQ queries, baseline suite, file 8, validation, baseline suite, file 9. W05-owned nodes (FoodItem, Exposure, Lifestyle) set the live `id` to the opaque uid segment; other owners' nodes in these fixtures do not (their owners' concern). Every statement binds its nodes by uid; nodes carry the primary label and the archetype label; uids use registered tokens except `hu:exposure:*` and `hu:lifestyle:*` (requested, W05-SR-01) and one deliberate negative (`hu:food:*`, N12). Real-source snapshots use `STORED_EXCERPT_TEXT` hashes over `excerpts/*.txt`; synthetic ones use `SYNTHETIC_FIXTURE`.

## 1. Files and load order

| Order | File | Kind | Content | Statements |
|---|---|---|---|---|
| 1 | `fixtures/w05-01-food-study-intervention.cypher` | positive, public facts | SUBRANUT (NCT03111355) arm → `StudyIntervention` → `InterventionComponent {1 {nut}/day, PER_DAY, UNSPECIFIED}` → base `FoodItem` "Brazil nut"; FDC 170569 variant FoodItem with `VARIANT_OF {PREPARATION}`, FDC_ID and NDB identifiers; selenium 1917 µg/100 g (A, n 15, 136–2740), folic acid assumed zero (Z), DHA underived zero (UNRESOLVED, no edge) | 30 |
| 2 | `fixtures/w05-02-diet-arm-composite.cypher` | positive, public facts | DICA-NUTS (NCT03728127) DCB vs DCBN arms; practice-definition components → `Protocol` DicaBr via requested `USES_PRACTICE_DEFINITION`; three 10 g/day food components; `registryInterventionType` verbatim, no Product | 19 |
| 3 | `fixtures/w05-03-food-product-is-product.cypher` | positive + migration, synthetic product | legacy `:FoodProduct` + `:Ingredient` + `HAS_INGREDIENT`; M-W05-01 relabel to `Product` (uid from live id, `productKind CONVENTIONAL_FOOD`); variant → formulation → component → `USES_MATERIAL` → `FoodItem`; derived `CONTAINS`; legacy ingredient kept resolvable through a `ResolutionHypothesis`; legacy edge deleted | 16 |
| 4 | `fixtures/w05-04-exposure-vs-protocol-step.cypher` | positive minimal pair, public facts + synthetic protocol | `Exposure` E1 (selenium, ORAL, CHRONIC, diet; RfD 5E-3 mg/kg/d as an EPA Assertion) and E2 (1438 µg/d, LIFETIME, ABSOLUTE_PER_DAY); synthetic `ProtocolStep` "eat two Brazil nuts" `USES` the base FoodItem; no step–exposure edge | 17 |
| 5 | `fixtures/w05-05-lifestyle-reported-vs-recommended.cypher` | positive minimal pair, synthetic | `Lifestyle` sauna bathing; guest `SELF_REPORTED_PRACTICE` (REPORTS_PRACTICE) vs host `RECOMMENDS` (RECOMMENDS) in one episode; only the host's projects a `RECOMMENDS` edge; practice `Exposure` (EXTERNAL_PHYSICAL, PT20M, 4/week; temperature as text) | 12 |
| 6 | `fixtures/w05-06-temporal-correction-late-arrival.cypher` | temporal | T1 RfD mis-extraction (0.05) superseded by EXTRACTION_FIX; T2 late-arriving 2025 composition record (synthetic, observed 2026-10-05) coexists with SR Legacy | 5 |
| 7 | `fixtures/w05-08-capture-adjudications.cypher` | provenance | one POLICY CAPTURE_FIDELITY adjudication over all W05 ACCEPTED assertions (baseline elysium pattern) | 1 |
| 8 | `fixtures/w05-07-negatives.cypher` | negative (scratch DB only) | N1–N12, each targeting one validation id | 10 |
| 9 | `fixtures/w05-09-constraint-probe.cypher` | constraint probe (after `operations.cypher`) | P1 duplicate `characterizationHash`, P2 duplicate Lifestyle uid, P3 second node with a material uid: must fail; P4 Exposure without hash: succeeds on Community (presence not enforced) | 4 |
| — | `fixtures/w05-validation.cypher` | validation | V-W05-01…12 (rows = violations) | 12 |
| — | `fixtures/w05-cq-queries.cypher` | queries | 9 CQ queries below | 9 |

## 2. Runs and observed results

| Run | Result |
|---|---|
| Positives 1–7 on a fresh store | all statements ok, 0 errors, every statement wrote (no silent MATCH misses; checked per-statement counters) |
| `w05-validation.cypher` after positives | **0 rows** for all 12 checks |
| Baseline `neo4j/validation.cypher` (174 statements, `validation-params.json`) after positives (final run, with `operations.cypher` applied first) | 174 ok, 0 errors. Non-zero rows: V-221 (2: the two practice-definition components; seam W05-SR-06), V-231 (2: composition assertions with DIRECT_MEASUREMENT; seam W05-SR-05c); informational V-118 (uid present on all counted nodes), V-401b (18 assertions with only SECTION locators: registry and FDC field locators), V-514b (0 without contentHash). An earlier pass also showed V-001, V-003, V-110, V-112, V-401, V-411, V-505, V-522 rows; all were fixture defects and are fixed (edition-assertion locator, object-or-literal, capture adjudication, RECOMMENDS assertion shape, quote hashes, rendition link, valid time, privacyClass). |
| `operations.cypher` then probe (file 9) | 11/11 statements ok; P1 rejected (`Node already exists with label Exposure and property characterizationHash`), P2 rejected (Lifestyle uid), P3 rejected (IngredientMaterial uid: a second node for a food cannot exist), P4 accepted (Community does not require presence) |
| Negatives (file 8) then `w05-validation.cypher` | exactly one intended row per check (V-W05-04 has 2: N2 and N3 both lack agents) |
| Baseline suite after negatives | additional rows only where intended: V-10x asserted-edge profile (N6 DHA edge without recordedFrom, N9 IDENTIFIED_BY without assertion), V-112 (N5), V-423 (N5), V-522 (negative nodes without privacyClass) |
| GraphQL round trip (fragment + stubs, `@neo4j/graphql` 7.6.3, driver against the fixture store) | `exposures { agents { __typename } }` returns one typed agent per edge (IngredientMaterial for the food, ChemicalSubstance, Lifestyle); `foodItems { variantOfConnection { edges { properties { variantKind assertionUid } } } quantifiedSubstancesConnection {...} }` and `lifestyles { characterizedExposures }` resolve. With `FoodItem` also in the union, the same food node came back twice: the reason for D-W05-11 |

## 3. Queries with expected results (all **run**; expected = observed on the clean load)

| Id | CQ | Query (in `w05-cq-queries.cypher`) | Expected rows |
|---|---|---|---|
| Q-ST-01-food | CQ-ST-01, CQ-FL-C04 | arms → interventions → components → material or practice definition | 5 rows: DCB: DicaBr (PRACTICE_DEFINITION, no quantity); DCBN: DicaBr; Brazil nut 10 g PER_DAY FOOD; cashew 10 g; peanut 10 g; all `duration P16W`, `registryType DIETARY_SUPPLEMENT` |
| Q-FL-C01 | CQ-FL-C01, CQ-EV-04 | component → base food ← VARIANT_OF variant → QUANTITATIVELY_CONTAINS selenium → locator → snapshot | 2 rows ordered by recordedAt: 1917 ug PER_100_G EDIBLE_PORTION ANALYTICAL min 136 max 2740 n 15 source FDC 170569 published 2019-04-01; 1520 ug n 6 synthetic 2025 source recorded 2026-10-05 |
| Q-FL-C01b | CQ-TM-01 | composition as of recorded time 2026-10-04T12:00Z | 1 row: 1917 (late record not yet known) |
| Q-AX-04-food | CQ-AX-04 | assertion vs projected edge per constituent | DHA: UNRESOLVED, no edge ("NOT_PROJECTED"); folic acid: CALCULATED, 0, ASSUMED_ZERO; selenium: two VALUE rows (1520, 1917) |
| Q-FL-C02 | CQ-FL-C02, CQ-PR-02/06 | exposures with the agent ∪ protocol steps reaching the agent | 3 rows: E2 ORAL LIFETIME 1438 ug/d; E1 ORAL CHRONIC, intensity null, referenceDose 0.005 mg/kg/d; PROTOCOL_STEP 2 `{nut}`, route/duration null |
| Q-TM-food | CQ-TM-01/02 | RfD as of 2026-10-04T01:45Z and 03:00Z | 0.05 then 0.005 mg/kg/d |
| Q-RC-05-practice | CQ-RC-05 | assertions about the practice by person, with projection flag | host: RECOMMENDS, EXPERT_OPINION, projected true; guest: REPORTS_PRACTICE, PERSONAL_EXPERIENCE, projected false |
| Q-FL-C03 | CQ-FL-C03, CQ-ST-02 | food ← component ← formulation ← variant ← product | 1 row: `hu:product:7b2f4c1e-…`, CONVENTIONAL_FOOD, labels [Entity, Product] (no FoodProduct label) |
| Q-FL-C04 | CQ-FL-C04, CQ-PR-03 | practice definitions used by components, editions known | 1 row: DicaBr, 2 components, 0 editions, notReported ['editionContent'] |

Essential CQs covered with at least one query: CQ-ST-01, CQ-ST-02, CQ-EV-04 (input facts; the assessment itself is W10's), CQ-RC-05.

## 4. Negative fixtures and expected violation ids

| Neg | Shape | Must trip | Observed |
|---|---|---|---|
| N1 | `:FoodProduct:Product` duplicate identity | V-W05-01 | 1 row |
| N2 | Exposure with `startedAt` and `EXPOSED_PERSON` → Person | V-W05-06 (+ V-W05-04) | 1 (+1) |
| N3 | Exposure intensity 2.0 without unit/basis | V-W05-03 (+ V-W05-04) | 1 (+1) |
| N5 | guest `RECOMMENDS` citing a practice report | V-W05-09, baseline V-423, V-112 | 1, 1, 1 |
| N6 | DHA underived zero projected as an edge | V-W05-07, baseline V-10x profile | 1, 1 |
| N7 | `ProtocolStep -[:CHARACTERIZED_AS_EXPOSURE]-> Exposure` | V-W05-10 | 1 |
| N8 | legacy `INVOLVES` from an Exposure | V-W05-11 | 1 |
| N9 | GTIN `IDENTIFIED_BY` on a FoodItem | V-W05-12, baseline V-10x profile | 1, 1 |
| N10 | `foodGroup` without `foodGroupSystem` | V-W05-05 | 1 |
| N11 | `VARIANT_OF` without assertion | V-W05-08 | 1 |
| N12 | FoodItem without `IngredientMaterial` label, uid token `food` | V-W05-02 | 1 |

## 5. Minimal pairs required by the brief

| Pair | Where | Distinguishing facts |
|---|---|---|
| Food study intervention ties to `StudyIntervention` through `InterventionComponent` → FoodItem | fixture 01 (SUBRANUT), fixture 02 (DICA-NUTS) | no new W09 range needed for foods (FoodItem is an IngredientMaterial); practice components need W05-SR-06 |
| FoodProduct that is also a Product | fixture 03 | one node, one uid (`hu:product:<live id>`), labels Product/Entity, `legacyLabels ['FoodProduct']`; N1 shows the forbidden two-label/two-identity form |
| Exposure with route and duration vs same agent as a protocol step | fixture 04 (+ N7) | Exposure carries route/duration/intensity and agency statements; the step carries a count and a schedule text; no edge between them |
| Lifestyle practice reported vs recommended | fixture 05 (+ N5) | speechAct REPORTS_PRACTICE vs RECOMMENDS; only RECOMMENDS projects |
| Temporal correction / late arrival | fixture 06 | EXTRACTION_FIX supersession with recordedTo; late composition source coexists |
| Identity collision | fixture 03 (`ResolutionHypothesis` for legacy "Brazil nuts" ingredient vs FoodItem; no name merge); N9 (GTIN on a food) | |
| Missing facts | fixture 01 (DHA unresolved; per-nut selenium absent), 02 (DicaBr content not reported), 04 (step duration/preparation in `notReportedFields`) | |
| Access leakage | N2 (Exposure as a person's history) | V-W05-06; the shared graph holds no person-level exposure |

## 6. Not run

- Constraint statements in `07-operations.md` (no merged schema yet).
- Enterprise-only existence constraints.
- The merged final schema build (Fable's step); the fragment was built only with stubs for other owners' types.
