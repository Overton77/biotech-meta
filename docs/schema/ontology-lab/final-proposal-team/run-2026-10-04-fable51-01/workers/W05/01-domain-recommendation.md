# W05 Food, lifestyle and exposures: domain recommendation

Worker W05 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 digest `8fb50ff0…84f0`, live schema digest `86b5e0b5…f112`. Scope from `02-ownership-registry.md` (W05 row; transfer placeholder T-005): live seams `FoodItem`, `FoodProduct`, `Exposure`, `Lifestyle`; union `ExposureAgent` (successor `ExposureAgentTarget`); relationships `VARIANT_OF`, `INVOLVES` (Exposure use), and the disposition of `CONTAINS_COMPOUND` and `HAS_INGREDIENT`. No catalog module owns these types (`conventions.liveSeamTypes`); round 0005 deferred them ("Out of lane", live-schema-alignment line 313).

## 1. Boundaries and subdomains

| Subdomain | What it is | Canonical home after this packet | What it is not |
|---|---|---|---|
| Reference food | A food concept as a composition or food-ontology source defines it, at a stated preparation (USDA FDC 170569 "Nuts, brazilnuts, dried, unblanched") | `FoodItem`, a specialization of W02 `IngredientMaterial` (labels `FoodItem`, `IngredientMaterial`, `Entity`) | not a marketed product, not a dietary pattern, not a meal someone ate |
| Marketed food | A branded, packaged, sold food | W04 `Product` (`productKind: CONVENTIONAL_FOOD`) → `ProductVariant` → `FormulationVersion` → `IngredientComponent` → `USES_MATERIAL` → `FoodItem` | not a second identity beside `Product` (live `FoodProduct` is retired) |
| Food composition | Amount of a constituent per reference amount of a food, per source record | W02 `QUANTITATIVELY_CONTAINS` (asserted) from the `FoodItem` node, with composition qualifiers requested from W02 (W05-SR-04); `PROVIDES_CONSTITUENT` for non-quantitative statements | not a label declaration (W04), not a measured lot result (W12), not a dose |
| Characterized exposure | A reusable description of contact with agents by route, duration, intensity, setting, medium | `Exposure` (Entity; identity = characterization tuple) | not an occurrence of anyone's exposure, not a protocol step, not a reference value (that is an Assertion about the Exposure) |
| Practice concept | A repeatable behaviour sources describe, report doing or recommend (sauna bathing, time-restricted eating) | `Lifestyle` (Entity) | not a defined regimen with steps/editions (W16 `Protocol`), not a person's adherence (private), not a recommendation |
| Dietary and lifestyle interventions in studies | What an arm was assigned | W09 `StudyIntervention` → `InterventionComponent` → `USES_INTERVENTION_MATERIAL` (foods) or requested `USES_PRACTICE_DEFINITION` (diet prescriptions, W05-SR-06) | not the participants' execution |
| Intervention execution | What a person actually ate, did or was exposed to | outside the shared graph (W23 private-store contract) | never a shared node, edge or `Exposure` |

Intervention **definition** (StudyIntervention, ProtocolStep, Exposure characterization, Lifestyle concept) and **execution** (a person's meals, sessions, exposure history, adherence) are kept explicit: only definitions enter the shared graph. Negative fixture N2 (`w05-07-negatives.cypher`) turns an `Exposure` into a person's history and V-W05-06 rejects it.

## 2. Archetype placement (identity vs state vs artifact vs occurrence)

| Type | Archetype | Reason |
|---|---|---|
| `FoodItem` | Entity (parent label `IngredientMaterial`) | Reference concept; its composition values are assertions per source record, not state of the concept. An FDC ID identifies a dataset record (`Identifier`), not the concept: FDC says its numbers uniquely identify an item "within a particular FDC data type" and SR Legacy "will not be updated", while other data types keep publishing new records (`excerpts/fdc-docs-excerpt.txt`). |
| `Exposure` | Entity | Reusable characterization referenced by evidence (IRIS RfD), protocol comparisons and applicability; immutable tuple, so it has no versioned state; any change is a new `Exposure`. Not Occurrence: it has no participant and no time of contact (contrast W03 `MechanismEvidenceContext`, the Occurrence of one tested exposure group). |
| `Lifestyle` | Entity | Practice concept. |
| Retired `FoodProduct` | (W04 Product, Entity) | Same identity as a product. |

## 3. Disposition of every element in scope

| Element (live or catalog) | Disposition | Final element | Note |
|---|---|---|---|
| `FoodItem` (type) | **refine** | `FoodItem` `["FoodItem","IngredientMaterial","Entity"]`, uid token `material` | One identity with the material it is; reuse of W02 composition edges, W09 intervention material, W04 component path (decision D-W05-01). |
| `FoodItem.foodGroup` | refine | `foodGroup` + new `foodGroupSystem` | FDC: "Each FoodData Central datatype uses its own food categorization system"; a group without its system is ambiguous (V-W05-05). |
| `FoodItem.variantKind` | move | `FoodVariantProperties.variantKind` (enum `FoodVariantKind`) | Variation axis belongs to the edge. |
| `FoodItem.productionType`, `processingMethods`, `preparationNotes` | keep (refined meaning: source-stated, identity-relevant) | same | |
| new `FoodItem.descriptionVerbatim`, `scientificNameVerbatim` | add | same | FDC description and scientific name are the identity text; `name` is presentation. |
| `FoodItem.hasVariants` / `VARIANT_OF` (RoleMetadata) | **refine** | `VARIANT_OF` asserted, `FoodVariantProperties` | Base–variant links are curated assertions (FDC does not state them). |
| `FoodItem.containsCompounds` / `CONTAINS_COMPOUND` (DoseMetadata) | **retire → reuse** | W02 `QUANTITATIVELY_CONTAINS` (asserted) or `PROVIDES_CONSTITUENT` | `DoseMetadata.dose` has no basis; FDC values are per 100 g edible portion with derivation codes. |
| `FoodItem.hasSafetySignals` | keep (reference W17) | `HAS_SAFETY_SIGNAL` with `SafetyEdgeProperties` | W17 owns semantics. |
| `FoodProduct` (type) | **retire (merge)** | W04 `Product` with `productKind: CONVENTIONAL_FOOD` | Decision D-W05-02; migration M-W05-01 relabels in place, uid `hu:product:<live id>`. |
| `FoodProduct.brandName` | move | W01 `ConsumerBrand` via `OWNS_BRAND`; legacy value kept as `legacyBrandName` | |
| `FoodProduct.processingMethods`, `preparationNotes` | move | `ProductVariant.name`/W04 label declarations; food-level preparation on the `FoodItem` the component uses | |
| `FoodProduct.hasIngredients` / `HAS_INGREDIENT` | **retire → reuse** | W04 `HAS_FORMULATION_VERSION` → `HAS_INGREDIENT_COMPONENT` → `USES_MATERIAL` | Live `dose` on this edge is often a package net quantity; it goes to `PackageConfiguration.netQuantity` or `IngredientComponent.quantity` after review (M-W05-03). |
| `FoodProduct.hasSafetySignals` | move | `Product`'s W17 field | |
| `Ingredient` | not mine (W02 disposes) | `IngredientMaterial` | Only referenced here for the union and migration of `HAS_INGREDIENT`. |
| `Exposure` (type) | **refine** | `Exposure` Entity with characterization fields | |
| `Exposure.exposureType`, `exposureContext` | split | `setting` (enum `ExposureSetting`), `mediumText`, `description` | Free text mixed setting and medium. |
| `Exposure.involves` / `INVOLVES` (RoleMetadata) | **rename** | `HAS_EXPOSURE_AGENT` (structural, `StructuralEdgeProperties`) | Live `INVOLVES` is also the W18 Event participant edge; one type, one meaning (CL-014 precedent). |
| union `ExposureAgent` | **replace** | `ExposureAgentTarget = IngredientMaterial \| ChemicalSubstance \| Nutrient \| Product \| ProductVariant \| Lifestyle` | FoodItem resolves through `IngredientMaterial` (tested; see D-W05-11). |
| `Lifestyle` (type) | **refine** | `Lifestyle` Entity | |
| `Lifestyle.lifestyleClass`, `lifestyleDomain` | keep (display facets) | same | Not a taxonomy. |
| `Lifestyle.intensitySummary`, `exposurePattern` | **move** | `Exposure.intensityText`, `frequencyText` | Intensity and pattern characterize an exposure to the practice, not the concept. |
| `Lifestyle.affectsMechanisms`, `associatedWithConditions`, `associatedWithOutcomes` | keep as derived read-only (W03 types) | W03 `AFFECTS_MECHANISM`, `ASSOCIATED_WITH_*` with `AssociationProjectionProperties` | Domain extension requested (W05-SR-05). |
| `Lifestyle.hasSafetySignals`, `supportedByDocuments`, `supportedByChunks` | keep (W17, W20 types; W20 ones derived read-only) | same | |
| Other owners' unions containing my types (`TreatmentComponent`, `SafetySubject`, `Recommendable`, `StudyIntervention` (legacy), `StepSubstance`, `StepInstrument`, `Producible`, `EventSubject`, `EvidenceSubject`, `ClaimSubject`, `AssociationParticipant`, `MediaSubject`, `ProtocolResultMention`) | seam requests | owners W06, W17, W21, W09, W16, W01, W18, W10/W20/W21, W03, W22, W16 | Replace `FoodProduct`→`Product`/`ProductVariant`, `FoodItem`→`IngredientMaterial` when the parent is present, drop `Exposure` from `StepInstrument` (seam-requests.yaml). |
| Food composition edge property type (registry slot) | **not created** | W02 `QuantitativeContentProperties` with the W05-SR-04 qualifiers | `FoodCompositionProperties` is a CANDIDATE fallback in the model cards only; two property types on one relationship type would split one fact. |
| Candidate module `food_lifestyle_exposure` | propose (candidate) | owns `FoodItem` (parent label from substances_and_materials), `Exposure`, `Lifestyle`, `VARIANT_OF`, `HAS_EXPOSURE_AGENT`, the four enums | Dependencies: kernel, provenance, substances_and_materials, products_and_formulations, protocols, mechanisms. |

## 4. Alternatives considered (smallest model chosen)

1. **FoodItem**: (a) standalone Entity linked to an `IngredientMaterial` by a `REFERENCES_MATERIAL` edge, which produces two identities for one food and either a parallel composition edge or a proxy; rejected. (b) Retire `FoodItem` into `IngredientMaterial {materialKind: FOOD}`, which loses `searchFoodItems`, preparation identity text and `VARIANT_OF`, and leaves the food fields without a typed home; rejected narrowly; Fable may choose it if W02 refuses the specialization label, at the cost of moving five fields onto `IngredientMaterial`. (c) **Specialization of IngredientMaterial**: chosen. It is the BotanicalPreparation pattern (`parentLabel: IngredientMaterial`) already in the catalog.
2. **FoodProduct**: (a) specialization label `["FoodProduct","Product","Entity"]` would duplicate every W04 Product field and relationship in a second GraphQL type, and no food-specific field remains once brand, ingredients and processing are disposed; (b) **retire into Product** with `productKind: CONVENTIONAL_FOOD` (already in W04's enum): chosen.
3. **Exposure**: (a) Occurrence (a person's or cohort's exposure event) is forbidden by the brief and the privacy rule; (b) VersionedState is unnecessary because the tuple is immutable; (c) **Entity with an immutable tuple and `characterizationHash`**: chosen; statements such as an RfD are Assertions with the Exposure as subject (fixture 04).
4. **Composite activities** (a diet = prescription + foods): (a) a `Lifestyle -[HAS_COMPONENT]-> Lifestyle|FoodItem` taxonomy edge would invent a universal composition of named diets that every source defines differently; (b) **definitions stay source-specific**: a named diet is a W16 `Protocol` (with editions when content is known), a study arm composes it through `InterventionComponent`s (practice definition plus foods with amounts); chosen.
5. **Food composition**: (a) a W05-owned `FoodCompositionProperties` on `QUANTITATIVELY_CONTAINS` would give one relationship type two property types; (b) a W05-owned `HAS_COMPOSITION_VALUE` edge would be a parallel edge; (c) **W02's edge with requested qualifiers**: chosen.

## 5. Smallest recommended model

Three node types (`FoodItem`, `Exposure`, `Lifestyle`), one relationship-property type (`FoodVariantProperties`), one union (`ExposureAgentTarget`), four small enums (`ExposureRoute`, `ExposureDurationCategory`, `ExposureSetting`, `FoodVariantKind`), two owned relationship types (`VARIANT_OF`, `HAS_EXPOSURE_AGENT`). Everything else reuses W02 composition, W04 product backbone, W09 study interventions, W16 protocols and W21 speech acts. Twelve validation queries (`fixtures/w05-validation.cypher`) and seven fixtures back it; the fragment builds under `@neo4j/graphql` 7.6.3 against stubs and round-trips through GraphQL on Neo4j 5.26.31 Community.

## 6. Decisions referenced above

D-W05-01…12 are recorded with evidence and alternatives in `05-decision-seam-ledger.md`.
