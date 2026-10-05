# W05 CQ coverage matrix

Existing CQ ids are from `competency-questions.md` (digest `e714740…`). New questions are **candidates** `CQ-FL-Cnn` and never reuse existing ids. "Fixture/query" names point to `fixtures/` and `06-fixtures-and-queries.md`.

## 1. Existing CQs touched by W05

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Proposed element(s) | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-ST-01 (Essential now, A) | "SUBRANUT arm: one Brazil nut per day (`{nut}`, PER_DAY, mass basis UNSPECIFIED) for P2M; preparation not stated. DICA-NUTS DCBN: DicaBr prescription + 10 g/day each of peanuts, cashew nuts, Brazil nuts for P16W." | count dose vs mass dose; food material component vs followed definition; registry intervention type vs product kind | CT.gov `armsInterventionsModule` field locators (SECTION) | `FoodItem` as `IngredientMaterial` target of W09 `USES_INTERVENTION_MATERIAL`; W09 `FOLLOWS_INTERVENTION_DEFINITION` to the diet Protocol (Protocol in range requested, W05-SR-06) | Q-ST-01-food (06 doc) | A diet arm with no component, or a food arm whose dose loses its count basis; registry type DIETARY_SUPPLEMENT read as a supplement product (fixture 02 creates no Product) |
| CQ-ST-02 (Essential now, A) | "Synthetic Grove Brazil Nuts uses the same base food (preparation unresolved) as the SUBRANUT arm; identity level is food-concept only." | same food concept vs same preparation vs same lot | intervention material and formulation component, both asserted with locators | `FoodItem` reached by W04 `USES_MATERIAL` and W09 `USES_INTERVENTION_MATERIAL`; `VARIANT_OF` to compare preparations | Q-FL-C03 + CQ-ST-02 pattern (06 doc) | Reporting a shared food name as product evidence (INV-008, [SHARED_INGREDIENT_NAME, EVIDENCE_APPLIES]) |
| CQ-EV-04 (Essential now, Q) | "EXPOSURE dimension UNKNOWN for a Brazil-nut product vs SUBRANUT: per-nut selenium not reported; FDC SR Legacy spread 136–2740 µg/100 g (n = 15); preparation unresolved." | composition reference vs measured lot vs label; per-100 g vs per-unit; UNKNOWN vs NOT_ASSESSED | FDC record locator, portion weight (1 kernel = 5 g), arm dose | composition qualifiers on W02 `QUANTITATIVELY_CONTAINS` (W05-SR-04); `Exposure` as the characterized exposure referent for the EXPOSURE dimension (W10 consumes) | Q-FL-C01, Q-AX-04-food | A single selenium "dose" invented from a food count; a reference average treated as the trial's exposure |
| CQ-PR-02 (Foundational, A) | "Step `eat-brazil-nuts` ESSENTIAL (stated); uses Brazil nut 2 `{nut}`/day; route and duration not reported." | step prescription vs characterized exposure | protocol text | step target via W16 `StepSubstanceTarget` = `IngredientMaterial` (W05-SR-08); no step–exposure edge | Q-FL-C02 | A protocol step promoted to an exposure characterization (V-W05-10) |
| CQ-PR-03 (Expansion, Q) | "DicaBr protocol content not reported (notReportedFields ['editionContent']); step duration and preparation not reported." | not reported vs unknown vs absent | registry / protocol text | `notReportedFields` on Protocol/ProtocolStep (W16) and `Exposure.notReportedFields` | Q-FL-C04 | Treating an unstated diet definition as known |
| CQ-PR-06 (Research frontier, Q) | "Evidence for the step's agent is a composition reference (FDC) and an exposure reference value (IRIS RfD), neither about the step." | evidence about the agent vs about the step | locators | assertions with `Exposure` subject; no step-level support edge | Q-FL-C02 | Agent-level evidence presented as step-level support |
| CQ-RC-05 (Essential now, A) | "The host recommends sauna bathing (RECOMMENDS, projected edge); the guest reports doing it (REPORTS_PRACTICE, no recommendation edge)." | practice report vs source recommendation vs BellLabs recommendation | utterance locators | `Lifestyle` as object/subject of `Assertion`s with `speechAct`; W21 `RECOMMENDS` projection | Q-RC-05-practice; V-423, V-W05-09 | A practice report projected as a recommendation |
| CQ-AX-04 (Foundational, A) | "Folic acid: assumed zero (FDC code Z, not measured). DHA: source row zero without derivation, not projected. Selenium: analytical." | unknown vs not reported vs assumed zero vs measured | FDC derivation fields | `valueDerivation`, `sourceDerivationCode`, `dataPoints` qualifiers (W05-SR-04); UNRESOLVED assertion without edge | Q-AX-04-food; V-W05-07 | Zero read as measured absence |
| CQ-TM-01 / CQ-TM-02 (Essential now) | "As of 2026-10-04T01:45Z the RfD read 0.05; after the EXTRACTION_FIX, 0.005. The 2025 composition record arrived 2026-10-05 and does not supersede SR Legacy." | correction vs world change vs new source | assertion recordedAt/recordedTo, SUPERSEDES | kernel SUPERSEDES; composition edges NONEXCLUSIVE across sources | Q-TM-food, Q-FL-C01b | Silent overwrite of a reference value; late source treated as correction |

## 2. Candidate CQs (new, candidate status)

| Id | Question | Priority / answerability | Rationale and failing case | Elements it justifies |
|---|---|---|---|---|
| CQ-FL-C01 | For a food used in a study or product, what is its composition per stated reference amount and portion basis, at which preparation, from which source record, with what derivation and spread, and is the studied preparation known? | Foundational / A for reference records; Q for studied preparation | FDC 170569 is "dried, unblanched"; SUBRANUT and DICA-NUTS name only "Brazil nut(s)"; FDC selenium 1917 µg/100 g, min 136, max 2740, n = 15; a newer record (synthetic, fixture 06) gives 1520. | `FoodItem.descriptionVerbatim`, `processingMethods`, `VARIANT_OF` + `FoodVariantProperties.variantKind`; W02 composition qualifiers (W05-SR-04) |
| CQ-FL-C02 | For an agent, which characterized exposures exist (route, duration class and duration, intensity with unit and basis, setting, medium), what do sources state about them, and how do they differ from protocol steps or study interventions that use the same agent? | Foundational / A | EPA IRIS selenium: chronic oral RfD 5E-3 mg/kg/day from a lifetime dietary exposure (1438 µg/d males, high-Se area); a protocol step "two Brazil nuts a day" states no route, duration or selenium amount. | `Exposure` and its fields; `ExposureRoute`, `ExposureDurationCategory`, `ExposureSetting`; `HAS_EXPOSURE_AGENT`; `ExposureAgentTarget` |
| CQ-FL-C03 | Which marketed products realize a reference food through their formulation, and which reference food does a marketed food product contain, without making the product a food or the food a product? | Foundational / A | Live `FoodProduct` and `Product` are two types for one marketed thing; live `HAS_INGREDIENT` puts a package net quantity on an ingredient edge. | retirement of `FoodProduct` into W04 `Product`; `FoodItem` as `USES_MATERIAL` target; V-W05-01, V-W05-12 |
| CQ-FL-C04 | For a diet or lifestyle intervention (study arm or public protocol), what does it follow (practice definitions) and which foods with amounts does it add, which component distinguishes the arms, and what does the source leave unstated? | Foundational / A for stated components; Q for definitions | DICA-NUTS: both arms share the DicaBr prescription whose content the registry does not give; only DCBN adds 3 × 10 g/day nuts. | `Lifestyle` (practice concept) vs W16 `Protocol` (defined regimen); W09 `FOLLOWS_INTERVENTION_DEFINITION` (Protocol target and V-221 refinement requested, W05-SR-06) |
| CQ-FL-C05 | Which exposures involve agents with no current owner type (physical agents such as ultraviolet radiation or noise; source-defined food groups such as IARC "processed meat")? | Expansion / not answerable now | No retrieved record in this run; IARC not fetched. Stays a candidate; no element enters the fragment. | none (CANDIDATE `PhysicalAgent`, source-defined food group concept in model cards) |

## 3. Element-to-CQ map (every SDL element)

| SDL element | CQ / invariant / ingestion failure |
|---|---|
| `FoodItem` (type, labels with `IngredientMaterial`) | CQ-ST-01, CQ-ST-02, CQ-FL-C01, CQ-FL-C03; V-W05-02, V-W05-12 |
| `FoodItem.descriptionVerbatim`, `scientificNameVerbatim` | CQ-FL-C01 (identity text from FDC) |
| `FoodItem.foodGroup`, `foodGroupSystem` | CQ-FL-C01; V-W05-05; ingestion failure: category system ambiguity (FDC FAQ) |
| `FoodItem.processingMethods`, `preparationNotes`, `productionType` | CQ-FL-C01 |
| `FoodItem.variantOf` / `hasVariants` (`VARIANT_OF`) | CQ-FL-C01; V-W05-08 |
| `FoodItem.quantifiedSubstances` / `quantifiedNutrients` | CQ-FL-C01, CQ-EV-04, CQ-AX-04; V-006, V-W05-07 |
| `FoodItem.identifiers` | CQ-FL-C01 (FDC ID, NDB number); identity contract A2 |
| `FoodItem.hasSafetySignals`, `Lifestyle.hasSafetySignals` | live compatibility (W17 owns semantics) |
| `FoodItem.characterizedExposures`, `Lifestyle.characterizedExposures` | CQ-FL-C02 |
| `Exposure` and all fields | CQ-FL-C02, CQ-EV-04; V-W05-03, V-W05-04, V-W05-06 |
| `Exposure.agents` (`HAS_EXPOSURE_AGENT`) | CQ-FL-C02; V-W05-04, V-W05-11 |
| `Lifestyle` | CQ-RC-05, CQ-FL-C04; V-423, V-W05-09 |
| `Lifestyle.affectsMechanisms`, `associatedWith*` | live compatibility; derived per W03 (W05-SR-05) |
| `Lifestyle.supportedByDocuments` / `supportedByChunks` | live compatibility; derived per W20 |
| `FoodVariantProperties` | CQ-FL-C01; V-W05-08 |
| `ExposureAgentTarget` | CQ-FL-C02; union rule W05-SR-09 |
| `ExposureRoute`, `ExposureDurationCategory`, `ExposureSetting` | CQ-FL-C02 |
| `FoodVariantKind` | CQ-FL-C01 |

No SDL element is unmapped. Candidates without a failing case in fixtures (`PhysicalAgent`, a source-defined food group concept, `FoodCompositionProperties`) are excluded from the fragment.
