# W05 model cards

Conventions: privacy class PUBLIC unless stated; "kind" = asserted / observed / calculated / inferred / operational; null means not recorded unless a card says otherwise. Maturity is the proposed `NodeMaturity`. Module: candidate `food_lifestyle_exposure`.

## Node: FoodItem

| Aspect | Value |
|---|---|
| Meaning | Reference food concept at the preparation its defining source names (FDC 170569 "Nuts, brazilnuts, dried, unblanched"), or a base food whose preparation is unresolved ("Brazil nut"). |
| Archetype / labels | Entity / `["FoodItem","IngredientMaterial","Entity"]` (specialization of W02 `IngredientMaterial`, like `BotanicalPreparation`) |
| uid token | `material` (parent token; one identity). `entityType = 'FoodItem'`; W02's `materialKind = 'FOOD'` (W05-SR-02). |
| Identity keys | `uid`. Identity criteria: same defining description and preparation within one reference system, or explicit curation. Aliases: FDC ID, NDB number, FNDDS food code, FoodOn IRI as `Identifier` records (issuer-scoped). Two FDC IDs may resolve to one FoodItem through an `EquivalenceAssessment`; a name match never merges. A GTIN never attaches to a FoodItem (V-W05-12). |
| Not | marketed product, dietary pattern, meal, exposure, taxonomy node |
| Maturity | PROVISIONAL |

| Property | Type | Null | Meaning / value state | Kind | Temporal |
|---|---|---|---|---|---|
| `descriptionVerbatim` | String | yes | source description; identity text | asserted (via the identifying assertion) | immutable |
| `foodGroup` | String | yes | category in one named system | asserted | immutable per source; a different system is a different value set |
| `foodGroupSystem` | String | required when `foodGroup` set | SR_FOOD_CATEGORY, WWEIA_FOOD_CATEGORY, GS1_GPC, or source-stated | operational | immutable |
| `processingMethods` | [String!] | yes | stated descriptors; empty list = none stated; null = not recorded | asserted | immutable |
| `preparationNotes` | String | yes | verbatim sentence | asserted | immutable |
| `productionType` | String | yes | stated production system | asserted | immutable |
| `scientificNameVerbatim` | String | yes | as written; taxon link is W02 `DERIVED_FROM_TAXON` (W05-SR-03) | asserted | immutable |
| inherited kernel fields | per contract B2 | | | | |

| Edge (field) | Type | Direction / range | Class | Cardinality | Properties |
|---|---|---|---|---|---|
| `variantOf` / `hasVariants` | `VARIANT_OF` | FoodItem → FoodItem | asserted | variant: zero_or_one base per recorded episode; base: many | `FoodVariantProperties` |
| `quantifiedSubstances` / `quantifiedNutrients` | `QUANTITATIVELY_CONTAINS` (W02) | FoodItem → ChemicalSubstance / Nutrient | asserted | many (one per source assertion; NONEXCLUSIVE) | W02 `QuantitativeContentProperties` (`basis AMOUNT_PER_MASS_OF_MATERIAL`, unit `ug/hg`, `contentStatementKind TYPICAL_COMPOSITION_REPORTED`) + W05-SR-04 qualifiers |
| `identifiers` | `HAS_IDENTIFIER` (W00) | → Identifier | asserted | many | `IdentifierLinkProperties` |
| `hasSafetySignals` | `HAS_SAFETY_SIGNAL` (W17) | → SafetySignal | asserted | many | `SafetyEdgeProperties` |
| `characterizedExposures` | `HAS_EXPOSURE_AGENT` (inverse) | ← Exposure | structural | many | `StructuralEdgeProperties` |
| (reached by, no field here) | W09 `USES_INTERVENTION_MATERIAL`, W04 `USES_MATERIAL`, W04 derived `CONTAINS`, W16 `USES` | ← InterventionComponent / IngredientComponent / ProductVariant / ProtocolStep | per owner | | |

## Node: Exposure

| Aspect | Value |
|---|---|
| Meaning | Reusable, source-stated characterization of contact with agents: route, duration class and duration, intensity (value, UCUM unit, basis), setting, medium, frequency. |
| Archetype / labels | Entity / `["Exposure","Entity"]` |
| uid token | `exposure` (new; W05-SR-01) |
| Identity keys | `characterizationHash` = `sha256:` over canonical JSON of {sorted agent uids, route, durationCategory, durationIso, intensityValue, intensityUnitCode, intensityBasis, setting, mediumText} (rule `exposure-tuple/v1`, 07-operations.md). Same hash = same Exposure (idempotent MERGE). |
| Not | an occurrence (no person, cohort member, participant, start/end of contact: V-W05-06), a protocol step (V-W05-10), a study intervention, a reference value, a W03 MechanismEvidenceContext |
| Maturity | PROVISIONAL |

| Property | Type | Null | Meaning / value state | Kind |
|---|---|---|---|---|
| `characterizationHash` | String | no in production (service-enforced) | identity hash | calculated |
| `setting` | ExposureSetting | yes | DIETARY, ENVIRONMENTAL, OCCUPATIONAL, BEHAVIORAL_PRACTICE, NOT_STATED | asserted |
| `route` | ExposureRoute | yes (NOT_STATED when source silent) | ORAL, INHALATION, DERMAL, OCULAR, PARENTERAL, EXTERNAL_PHYSICAL, MULTIPLE, NOT_STATED | asserted |
| `mediumText` | String | yes | vehicle/medium verbatim | asserted |
| `durationCategory` | ExposureDurationCategory | yes | ACUTE, SHORT_TERM, SUBCHRONIC, CHRONIC, LIFETIME, NOT_STATED | asserted |
| `durationText` | String | yes | verbatim | asserted |
| `durationIso` | String (ISO 8601 duration) | yes | numeric duration when stated | asserted |
| `intensityValue` | Float | yes; never 0 for unknown | value as stated or calculated by source | asserted / calculated |
| `intensityUnitCode` | String (UCUM) | required with value (V-W05-03) | | |
| `intensityBasis` | ExposureBasis (W03) | required with value | PER_KG_BODY_WEIGHT_PER_DAY, ABSOLUTE_PER_DAY, SINGLE_DOSE, MEDIUM_CONCENTRATION, DIET_CONCENTRATION | |
| `intensityText` | String | yes | verbatim, including assumptions (55 kg body weight) | asserted |
| `frequencyText` | String | yes | verbatim; recurrence structure belongs to W16 | asserted |
| `notReportedFields` | [String!] | yes | fields the source explicitly does not report (distinct from null) | asserted |

| Edge | Type | Range | Class | Cardinality | Properties |
|---|---|---|---|---|---|
| `agents` | `HAS_EXPOSURE_AGENT` | `ExposureAgentTarget` | structural (part of the tuple) | one_or_more | `StructuralEdgeProperties` (`orderIndex`) |
| (incoming) | `HAS_SUBJECT` from Assertions (W00) | Assertion → Exposure | structural | many | statements such as `HAS_REFERENCE_DOSE` (candidate predicate, W17) |

## Node: Lifestyle

| Aspect | Value |
|---|---|
| Meaning | Practice concept (sauna bathing, time-restricted eating, a dietary pattern as a generic idea). |
| Archetype / labels | Entity / `["Lifestyle","Entity"]`; uid token `lifestyle` (new; W05-SR-01) |
| Identity keys | `uid`; names are presentation. Merges through `EquivalenceAssessment`. |
| Not | a defined regimen (W16 `Protocol`), an exposure (an `Exposure` may name it as agent), a person's habit, a recommendation |
| Maturity | PROVISIONAL |

| Property | Type | Meaning | Kind |
|---|---|---|---|
| `lifestyleClass`, `lifestyleDomain` | String | display facets (live), not a taxonomy | operational |

| Edge | Type | Range | Class | Note |
|---|---|---|---|---|
| `characterizedExposures` | `HAS_EXPOSURE_AGENT` (inverse) | Exposure | structural | |
| `affectsMechanisms`, `associatedWithConditions`, `associatedWithOutcomes` | W03 `AFFECTS_MECHANISM`, `ASSOCIATED_WITH_CONDITION`, `ASSOCIATED_WITH_OUTCOME` | Mechanism / Condition / Outcome | derived, read-only | `AssociationProjectionProperties`; domain extension W05-SR-05 |
| `hasSafetySignals` | W17 | SafetySignal | asserted | |
| `supportedByDocuments`, `supportedByChunks` | W20 | Document / Chunk | derived, read-only | `DerivedSupportProperties` |
| (incoming) | W21 `RECOMMENDS` (derived from a RECOMMENDS speech act only), W16 step practice target (W05-SR-08), W09 `FOLLOWS_INTERVENTION_DEFINITION` (already ranges over Lifestyle) | | | |

## Relationship: VARIANT_OF

FoodItem (variant) → FoodItem (base). Class asserted (profile asserted_edge; BellLabs curation or a source is the asserter; FDC does not state it). Cardinality: a variant has at most one believed base per recorded episode; acyclic (V-W05-08). Properties `FoodVariantProperties`. Live: `FoodItem.hasVariants` with `RoleMetadata` (role/title/confidence discarded; `notes` → assertion). Maturity PROVISIONAL.

## Relationship: HAS_EXPOSURE_AGENT

Exposure → `ExposureAgentTarget`. Class structural (defines the characterization). Cardinality one_or_more. Properties `StructuralEdgeProperties`. Renamed from the Exposure use of live `INVOLVES` (RoleMetadata), which W18 keeps for events. Maturity PROVISIONAL.

## Relationship-property type: FoodVariantProperties

All fields of the frozen `AssertedEdgeProperties` (`relationshipUid!`, `assertionUid!`, `validFrom`, `validTo`, precisions, `validFromBasis!`, `validToBasis!`, `recordedFrom!`, `recordedTo`, `mongoResearchRunId`) plus `variantKind: FoodVariantKind` (null = not recorded). Owner W05.

## Union: ExposureAgentTarget

`IngredientMaterial | ChemicalSubstance | Nutrient | Product | ProductVariant | Lifestyle`. FoodItem nodes resolve through `IngredientMaterial`. Rule (tested 2026-10-04, `@neo4j/graphql` 7.6.3 + Neo4j 5.26.31): a union must not list a specialization type beside its parent; with both members, one node returned twice. Owner W05.

## Enums (owner W05)

| Enum | Values | Source grounding |
|---|---|---|
| `ExposureRoute` | ORAL, INHALATION, DERMAL, OCULAR, PARENTERAL, EXTERNAL_PHYSICAL, MULTIPLE, NOT_STATED | IRIS route families (oral RfD, inhalation RfC "not assessed"); fixture 05 practice exposure. W03's candidate route strings (GAVAGE, DIET, IP, IV, IN_MEDIUM, TOPICAL) map to ORAL/PARENTERAL/DERMAL + medium (W05-SR-05). |
| `ExposureDurationCategory` | ACUTE, SHORT_TERM, SUBCHRONIC, CHRONIC, LIFETIME, NOT_STATED | IRIS "Chronic Oral Exposure", "based on lifetime exposure" |
| `ExposureSetting` | DIETARY, ENVIRONMENTAL, OCCUPATIONAL, BEHAVIORAL_PRACTICE, NOT_STATED | IRIS (dietary intake in a high-environmental-Se area); fixture 05 |
| `FoodVariantKind` | PREPARATION, PROCESSING, CULTIVAR_OR_BREED, PRODUCTION_SYSTEM, PLANT_OR_ANIMAL_PART, OTHER | FDC description and FoodOn name encode preparation and part |

Enums reused, not owned: `ExposureBasis` (W03), `QuantityBasis`, `MassBasis`, `TimePrecision`, `ValidTimeBasis`, `PrivacyClass`, `NodeMaturity` (W00).

## Derived inputs and rules referenced

| Rule | Inputs | Output | Owner |
|---|---|---|---|
| `exposure-tuple/v1` | Exposure tuple fields + sorted agent uids | `characterizationHash` | W05 (operations) |
| `fdc-portion-v1` (`N = V*W/100`, FDC documentation) | composition assertion (per 100 g) + portion gram weight assertion | CALCULATED per-portion amount assertion (W02/W10 consumer); never a measurement | W02 assertion with `derivationRule` |
| `contains-v1` | formulation + component assertions | W04 derived `CONTAINS` ProductVariant → FoodItem | W04 |
| `recommends-projection-v1` | Assertion with `speechAct RECOMMENDS` | W21 `RECOMMENDS` edge with `assertionUid` | W21 |

## CANDIDATE elements (not in the fragment)

| Candidate | Why it is not admitted | Admission criterion |
|---|---|---|
| `FoodCompositionProperties` (W05-owned property type for food rows of `QUANTITATIVELY_CONTAINS`: all W02 fields + `portionBasis`, `valueDerivation`, `sourceDerivationCode`, `dataPoints`, `minValue`, `maxValue`) | Two property types on one relationship type split one fact | Only if W02 refuses W05-SR-04 |
| `PhysicalAgent` (UV radiation, noise, heat as agents) | No retrieved source in this run; `Lifestyle` covers practice-based physical exposures | CQ-FL-C05 with a fetched record and a failing fixture |
| Source-defined food group concept (IARC "processed meat") | IARC not retrieved; risk of inventing a taxonomy | CQ-FL-C05 with the IARC record |
| Composite-practice edge (`Lifestyle` → components) | Diet definitions are source-specific; W16 `Protocol` carries them | A practice concept whose component list is stated identically across sources |
