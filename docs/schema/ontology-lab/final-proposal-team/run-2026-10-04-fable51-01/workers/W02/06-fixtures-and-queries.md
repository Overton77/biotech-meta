# W02 fixtures and queries

**Execution environment:** everything below was executed, not only parsed. The target was embedded **Neo4j 5.26.31 Community** (`org.neo4j.test:neo4j-harness:5.26.31`, OpenJDK 21), running a private copy of the run harness (`validation/harness`: `run-cypher.mjs`, `EmbeddedNeo4j.java`) in the W02 scratchpad.

**Load order:**
1. `docs/schema/neo4j/constraints.cypher`: 45 applied, 12 rejected. These are the Community-incompatible existence and type constraints, the same as the baseline.
2. W02 fixtures.
3. `docs/schema/neo4j/validation.cypher` (174 queries, params in section 5).
4. `operations.cypher` (V-W02-xx).
5. `fixtures/queries-W02.cypher`.

**Run tags:** run = executed with the rows below; parser-only = not executed.

**SDL check:** `sdl-fragment.graphql` parses with graphql-js 16.14.2. It **builds** with `@neo4j/graphql` 7.6.3, using minimal stubs for other owners' referenced types (`VECTOR_PROVIDER=0`): 1,902 generated types, 45 queries, 54 mutations. The generated API was **executed** against the fixture database (union `providesConstituents`, `quantitativelyContainsConnection` edge properties, `searchCompounds` fulltext): all fields resolved.

## 1. Fixture files

| File | Purpose | Kind | Statements | Result |
|---|---|---|---|---|
| `fx-01-nr-salt-vs-moiety.cypher` | NR chloride vs NR as two substances. Identifiers (UNII, CAS, PubChem, ChEBI). `HAS_ACTIVE_MOIETY` including the self-edge. MW literal assertions. NIAGEN crystal form. Three materials: NIAGEN; trial "NR" stated at moiety level; SYNTHETIC amorphous NRC. CALCULATED 263.4 mg NR cation for the Tru Niagen 300 mg component | positive, minimal pair, identity collision (salt vs moiety) | 97 | run: 97 ok |
| `fx-02-mosaic-provides-not-contains.cypher` | Mosaic PC Complex: `MaterialMixture` of two `BotanicalPreparation`s; `PROVIDES_CONSTITUENT` lycopene, phytoene, phytofluene, tocopherols (label) and beta-carotene (science page), carotenoids (science page), carnosic acid. **No** `QUANTITATIVELY_CONTAINS`. Vitamin A as `Nutrient` from a beta-carotene source material. Blend total 395 mg | positive, missing facts (amount NOT_STATED), source disagreement | 58 | run: 58 ok |
| `fx-03-niagen-two-spec-versions.cypher` | One `BrandedIngredientMaterial` NIAGEN with two W11 `SpecificationVersion`s (GRN 635 2015; EFSA 2019). The 2019 attachment is a BellLabs inference recorded late (REC_LATE) with a past validFrom | positive, temporal late arrival | 21 | run: 21 ok |
| `fx-04-botanical-ginkgo-preparation.cypher` | EMA WEU Ginkgo dry extract: taxon, leaf, DRY_EXTRACT, DER 35–67:1, acetone 60% m/m; the two constituent measurands | positive | 11 | run: 11 ok |
| `fx-05-lgg-strain-deposits.cypher` | LGG strain with five deposit and taxonomy Identifiers; current `STRAIN_OF` L. rhamnosus; patent-era L. acidophilus recorded but not projected; NCT00934453 preparation with viability unknown | positive, identity collision (several deposits; taxon reassignment), missing facts | 49 | run: 49 ok |
| `fx-06-nrpt-not-a-substance.cypher` | Legacy `Compound` "NRPT" disposed by `ResolutionHypothesis` to two `StudyIntervention`s; no `ChemicalSubstance`. Legacy `Compound` "Nicotinamide Riboside" with the chloride CAS resolves to the salt by identifier | positive migration; identity collision (name vs CAS) | 8 | run: 8 ok |
| `fx-07-nad-chemical-vs-molecular-entity.cypher` | NAD+ as one `ChemicalSubstance` (ChEBI 15846); CD38 as `MolecularEntity` | positive (CL-002) | 10 | run: 10 ok |
| `fx-90-negative-violations.cypher` | 14 negative cases N1–N14 (section 3) | negative | 49 | run: 49 ok (rows as expected) |
| `fx-91-kernel-quantity-failing-cases.cypher` | SR-01: two literal-only CALCULATED amounts on one component, plus the object form. SR-02: Ph. Eur. 10.0 Ginkgo ranges as BETWEEN edges | failing cases for kernel requests | 23 | run: 23 ok (rows as expected) |
| `queries-W02.cypher` | Q-01 … Q-10 | queries | 13 | run: 13 ok |

Every statement binds its own nodes by uid, and every node has its primary label and its archetype label. Snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'`. TEXT_QUOTE locators carry `quoteHash` computed as sha256 over the NFC-WS1-normalized `exact`. No private data and no `hu:private-` uids appear anywhere.

**Composition with the repo fixtures:** `elysium-basis.cypher` and `study-vs-product-mismatch.cypher` were loaded first, then fx-01…fx-07. All statements ran. Uids shared with the repo fixtures (NIAGEN, NR chloride, the crystal form, the trial NR material, Tru Niagen component, sources and locators) merge onto the same nodes. Edges reuse the repo's unpropertied edges (`MERGE` without properties plus `coalesce` SETs), so V-222 stays at 0 rows. The composition run surfaced three things:
- **V-110: 3 rows.** These are repo assertions in `elysium-basis.cypher`, which uses `recordedAt = datetime()` after an adjudication at a fixed 2026-10-04T00:00Z. This is clock-dependent and fails on any load after that instant. It is not caused by W02 (SR-17).
- **V-W02-03: 1 row.** The repo's `hu:substance:pterostilbene` has no structure anchor. It is a true finding against the repo fixture; W02's own copy is CANDIDATE.
- **Q-01 `amountReferent` null.** The repo component lacks the field (SR-11).

## 2. Positive expectations (positives only, fresh database): run

| Check | Expected | Observed |
|---|---|---|
| Baseline validation (174 queries) | only informational rows | V-118 (2 legacy `Compound` nodes without uid, by design in fx-06), V-401b (0 accepted), V-514b (0). Every other query returns 0 rows |
| V-W02-01…11, 13 | 0 rows | 0 rows |
| V-W02-12 (informational) | 1 row: `Compound` remaining 2 | 1 row: `{legacyLabels: [Compound], remaining: 2}` |

## 3. Negative and failing-case expectations (fx-91 + fx-90 loaded after positives): run

| Case | Fixture block | Expected violation | Observed |
|---|---|---|---|
| N1 QUANTITATIVELY_CONTAINS lycopene projected from a PROVIDES_CONSTITUENT assertion | fx-90 | V-W02-01 row; V-112 `CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE`, `FORBIDDEN_IMPLICATION_USED_AS_PREMISE` | both rows ✔ |
| N2 content edge without basis | fx-90 | V-006 row; V-W02-10 row | ✔ |
| N3 ChemicalSubstance "NRPT" without anchor | fx-90 | V-W02-03 row | ✔ (plus N6's collapsed node, which also lacks an anchor) |
| N4 substance with two active moieties | fx-90 | V-W02-04 row (moieties 2) | ✔ |
| N5 ChemicalForm of two substances | fx-90 | V-222 row (n = 2) | ✔ |
| N6 node both ChemicalSubstance and IngredientMaterial | fx-90 | V-222b row | ✔ |
| N7 material with dosageForm | fx-90 | V-222b row | ✔ |
| N8 MolecularEntity "NAD+" with InChIKey | fx-90 | V-W02-06 row (`sameKeySubstance hu:substance:nad-plus`) | ✔ |
| N9 MicrobialPreparation with materialKind BOTANICAL_PREPARATION | fx-90 | V-W02-02 row | ✔ |
| N10 NIAGEN re-minted for a new spec | fx-90 | V-W02-05 row | ✔ |
| N11 active-moiety chain | fx-90 | V-W02-07 row | ✔ |
| N12 CALCULATED assertion without lineage | fx-90 | V-W02-08 row (`hasRule false, hasInputs false`) | ✔ |
| N13 two current STRAIN_OF | fx-90 | V-W02-09 row | ✔ |
| N14 DERIVED_FROM_TAXON from a generic material | fx-90 | V-W02-11 row | ✔ |
| SR-01 object + literal calculated assertion | fx-91 | V-003 row (objects 1, literals 1) under the frozen kernel | ✔ |
| SR-02 Ginkgo BETWEEN ranges | fx-91 | V-006: 2 rows (plus N2 = 3); V-W02-10 (V-006r): 0 rows for the Ginkgo edges | ✔ |

## 4. Queries with expected results

| Query | CQ | Expected rows / values | Tag |
|---|---|---|---|
| Q-01 | CQ-PF-01 (Essential) | 1 row: declaredAs "NIAGEN (nicotinamide riboside chloride)", 300 mg, LISTED_INGREDIENT_AS_LISTED, SALT_FORM, realized "Nicotinamide riboside chloride", activeMoiety "Nicotinamide riboside", calculatedAmount **263.4 mg**, rule `w02-active-moiety-mass-v1…`, inputPredicates {USES_MATERIAL, REALIZES_SUBSTANCE, HAS_ACTIVE_MOIETY, HAS_MOLECULAR_WEIGHT ×2} | run ✔ |
| Q-02 | CQ-ID-03 | 5 rows for the tomato extract: Lycopene, Phytoene, Phytofluene (ChemicalSubstance, label), Tocopherols (Constituent, label), beta-Carotene (ChemicalSubstance, science page). Every amount `NOT_STATED` | run ✔ |
| Q-03 | CQ-ID-04 | 7 rows: NR {CAS 1341-23-7, CHEBI:15927, PUBCHEM_CID 439924, UNII 0I8H2M0L7N primary}; NR chloride {CAS 23111-00-4, PUBCHEM_CID 90480033, UNII 8XM2XT8VWI primary}. All capture status PROPOSED, with authority retrievedAt | run ✔ |
| Q-04 | CQ-ID-06, CQ-ST-02 (Essential) | NIAGEN–NIAGEN: SAME_MATERIAL_IDENTITY. NIAGEN–tomato extract: INSUFFICIENT_SUBSTANCE_FACTS. NIAGEN–trial NR: sameMoiety true, bMoietyOnly true → **SAME_SUBSTANCE_MATERIAL_UNRESOLVED**. NIAGEN–Supplier X amorphous: sameExact true, forms differ → **SAME_SUBSTANCE_DIFFERENT_FORM** | run ✔ |
| Q-05a | CQ-ID-05 | valid 2016-06-01, recorded now: 1 row, GRN 635 version, END_UNKNOWN | run ✔ |
| Q-05b | CQ-ID-05 | valid 2020-06-01, recorded now: 2 rows (2015, 2019) → spec unresolved | run ✔ |
| Q-05c | CQ-ID-05 (late arrival) | valid 2020-06-01, recorded as of 2026-10-04T02:30Z: 1 row (2015 only) | run ✔ |
| Q-05d | CQ-ID-05 | positives only: niagenMaterials **1**, specVersions [2015, 2019]; with fx-90 loaded: niagenMaterials **2** (N10 duplicate surfaces; V-W02-05 also reports it) | run ✔ |
| Q-06 | CQ-ID-C03, CQ-ST-01 | strain GG; currentSpecies Lacticaseibacillus rhamnosus (47715); identifiers [568703, ATCC 53103, ATCC BAA-3227, CCUG 34291, LMG 18243]; viability NOT_STATED; allRecordedSpeciesAssignments [L. rhamnosus, L. acidophilus] | run ✔ |
| Q-07 | CL-001 | nrptSubstances **0**; disposition PROPOSED; denotes the two StudyInterventions | run ✔ |
| Q-08 | CL-002 | exactly 1 row: `[Entity, ChemicalSubstance]` hu:substance:nad-plus (positives only); with fx-90 loaded, a second row (the N8 MolecularEntity) shows the duplicate | run ✔ |
| Q-09 | CQ-ID-C02 | Ginkgo biloba L., leaf, DRY_EXTRACT, "DER 35-67:1", 35–67, acetone 60% m/m. Standardization [] (positives only); with fx-91: ["…flavone glycosides 22.0-27.0%", "Terpene lactones … 5.4-6.6%"] | run ✔ |
| Q-10 | SR-01 failing case | 3 rows: nicotinamide molar-equivalent 105.0 mg refersTo null; NR cation 219.5 mg refersTo null (both `AMBIGUOUS_UNDER_FROZEN_INV_003`); object form 219.5 mg refersTo "Nicotinamide riboside" (`DIRECT`) | run ✔ |

## 5. Validation parameters used

The values come from the catalog relationship classes and forbidden implications for the types present in the fixtures:
- `assertedTypes` = the 10 W02 relationship types + HAS_IDENTIFIER, USES_MATERIAL, GOVERNED_BY_SPECIFICATION, HAS_FORMULATION_VERSION, USES_INTERVENTION_MATERIAL, SUPPLIES_INGREDIENT_MATERIAL.
- `derivedTypes` = CONTAINS, CONTAINS_COMPOUND_FORM, MODULATES, AFFECTS_MECHANISM, SELLS_PRODUCT.
- `implicationPairs` includes `[PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]`.
- `catalogV020CutoverAt` = 2026-10-03T00:00:00Z.

## 6. Mandatory cases from the coordinator brief

| Mandated fixture | Where | Outcome |
|---|---|---|
| Same substance, different form (NR chloride vs NR) with the CALCULATED active-moiety assertion pattern | fx-01 (two substances + `HAS_ACTIVE_MOIETY`; trial "NR" moiety-only vs NIAGEN salt; Supplier X amorphous vs NIAGEN crystal), CALCULATED 263.4 mg; fx-91 for the object form | Q-01, Q-04, Q-10 |
| PROVIDES_CONSTITUENT without QUANTITATIVELY_CONTAINS (tomato/rosemary mixture and lycopene) | fx-02; negative N1 | Q-02 `NOT_STATED`; V-W02-01/V-112 catch N1 |
| Branded material under two specification versions | fx-03; negative N10 | Q-05a–d; V-W02-05 |
| Combination product name (NRPT) must not become a ChemicalSubstance | fx-06; negatives N3, N4 | Q-07 = 0; V-W02-03/04 |
