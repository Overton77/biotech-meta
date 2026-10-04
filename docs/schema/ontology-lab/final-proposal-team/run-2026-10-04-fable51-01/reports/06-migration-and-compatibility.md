# 06 Migration and compatibility report (old → new)

Scope: every live GraphQL element (`current_biotech_schema.graphql`, read-only) and every catalog 0.2.0 element has a disposition recorded by its sole writer in `workers/Wxx/migration-map.yaml` (consolidated in `validation/inventories/migration-map-consolidated.json`, 1,864 rows). This report indexes those rows and states the compatibility rules an implementer needs. Nothing in the live schema was changed; the final proposal is a separate file.

## 1. Dispositions by package

| Package | keep | refine | rename | move | split | merge | derive | retire | rows |
|---|---|---|---|---|---|---|---|---|---|
| W00 | 16 | 0 | 9 | 5 | 8 | 4 | 1 | 3 | 46 |
| W01 | 59 | 0 | 14 | 61 | 4 | 5 | 3 | 25 | 171 |
| W02 | 39 | 0 | 20 | 9 | 5 | 1 | 5 | 3 | 82 |
| W03 | 75 | 0 | 4 | 25 | 2 | 3 | 13 | 16 | 138 |
| W04 | 50 | 0 | 3 | 7 | 4 | 1 | 11 | 6 | 82 |
| W05 | 22 | 0 | 7 | 7 | 2 | 4 | 5 | 3 | 50 |
| W06 | 46 | 0 | 9 | 2 | 2 | 0 | 5 | 5 | 69 |
| W07 | 47 | 0 | 6 | 12 | 5 | 2 | 6 | 2 | 80 |
| W08 | 39 | 0 | 5 | 0 | 0 | 1 | 0 | 4 | 49 |
| W09 | 34 | 0 | 19 | 42 | 4 | 6 | 4 | 7 | 116 |
| W10 | 4 | 0 | 6 | 5 | 1 | 0 | 5 | 2 | 23 |
| W11 | 20 | 0 | 4 | 4 | 3 | 3 | 2 | 9 | 45 |
| W12 | 18 | 0 | 0 | 1 | 1 | 0 | 1 | 1 | 22 |
| W13 | 39 | 0 | 8 | 3 | 5 | 2 | 12 | 0 | 69 |
| W14 | 21 | 0 | 0 | 3 | 2 | 0 | 0 | 0 | 26 |
| W15 | 18 | 0 | 6 | 6 | 5 | 2 | 5 | 4 | 46 |
| W16 | 79 | 0 | 8 | 22 | 8 | 4 | 1 | 11 | 133 |
| W17 | 44 | 0 | 2 | 4 | 2 | 0 | 6 | 2 | 60 |
| W18 | 34 | 0 | 14 | 2 | 2 | 0 | 2 | 6 | 60 |
| W19 | 14 | 4 | 3 | 4 | 4 | 0 | 38 | 1 | 68 |
| W20 | 61 | 0 | 20 | 4 | 4 | 0 | 30 | 10 | 129 |
| W21 | 48 | 0 | 10 | 1 | 11 | 4 | 4 | 13 | 91 |
| W22 | 69 | 0 | 16 | 38 | 1 | 0 | 3 | 25 | 152 |
| W23 | 24 | 0 | 6 | 7 | 1 | 0 | 15 | 4 | 57 |
| **All** | 920 | 4 | 199 | 274 | 86 | 42 | 177 | 162 | 1864 |

## 2. Headline old → new table (the rows an implementer hits first)

| Live element | Final element | Action | Ruling |
|---|---|---|---|
| `Compound` | `ChemicalSubstance` (salts are their own substance, `HAS_ACTIVE_MOIETY` to the parent) | merge | D-002, W02 |
| `CompoundForm` | `ChemicalForm` (physical form) + `IngredientMaterial` + dosage form on `ProductVariant`/`StudyIntervention` | split | D-002, W02 |
| `Ingredient` | `IngredientMaterial` | merge | W02 |
| `Material` | `IngredientMaterial` / `ChemicalSubstance` (no `ProcessMaterial`) | retire | D-008, W11, W02 |
| `FoodProduct` | `Product {productKind: CONVENTIONAL_FOOD}` | retire | W05 |
| `FoodItem` | `FoodItem` as `["FoodItem","IngredientMaterial","Entity"]` | refine | W05 |
| `PhysicalLocation` | `Facility` | merge | W01 (CL-015) |
| `Listing`, `ListingSnapshot`, `LISTS`, `LISTS_PRODUCT`, `OFFERS` | `MerchantListing`, `Offer`, `PriceObservation`, `SourceSnapshot`; `HOSTS_LISTING`/`LISTS_OFFER`/`SELLER_OF_RECORD_FOR`/`FULFILLS_OFFER`/`AFFILIATE_FOR_OFFER`; `LISTING_FOR`; `SELLS_PRODUCT` derived | split / retire | D-007, W15 |
| `Population`, `OutcomeMeasure`, `OutcomeResult`, `StudyOutcome` | `StudyPopulation`, `OutcomeDefinition`, `StudyResult`, assertions | rename / retire | D-007, W09 |
| union `StudyIntervention`, `Study.evaluates` (`EVALUATES`) | `LegacyEvaluatedIntervention`, stored type `LEGACY_EVALUATES`, read-only | rename | D-003, MR-05, W09 |
| `Study` registry fields (`overallStatus`, `enrollmentCount`, dates, `hasResults` …) | `RegistrationVersion` episodes; read-only caches on `Study` | move | W09 |
| `RegulatoryStatus` (mixed) | `RegulatorySubmission` + `RegulatoryResponse` + `RegulatoryStatus{statusKind}`; `RegulatoryPathwayVersion` | split | W13 |
| `Protocol.hasSteps` (`HAS_STEP`) and protocol-level schedule fields | `ProtocolEdition -[:HAS_PROTOCOL_STEP {orderIndex}]-> ProtocolStep`; schedule on the edition; `Protocol.currentSteps` derived | move | D-004, W16 |
| `ClaimOccurrence.utteredBy` (`UTTERED_BY`) | `ASSERTED_BY` | rename | D-006, W21 |
| `ExperienceReport` | `ClaimOccurrence {assertionBasis: PERSONAL_EXPERIENCE}` | retire | W21 |
| `Association` | source rows → `Assertion`; aggregates → assessments | retire | W03 |
| `MediaSource`, `HAS_VARIANT` (media), byte fields on `MediaAsset` | `DERIVED_FROM_SOURCE` → `SourceLocator`; `HAS_MEDIA_VARIANT`; bytes on the ORIGINAL `MediaVariant` | retire / rename / move | W22, CL-014 |
| `Document.hasTranscriptVersions` (`HAS_TRANSCRIPT`), `SOURCE_OF` | text version of a rendition snapshot (`TEXT_OF_SNAPSHOT`); `RENDITION_OF` | retire / rename | W20 |
| `SUPPORTED_BY -> Chunk` on 18 types, `SUPPORTED_BY_DOCUMENT` | `SUPPORTED_BY_CHUNK` / `SUPPORTED_BY_DOCUMENT` derived with `locatorUid` | derive | W20 |
| `Organization/Product -[:HAS_SNAPSHOT]-> *Snapshot` | `HAS_STATE` with `StateEpisodeProperties` | rename | MR-04 |
| `Person.recommends` (`RECOMMENDS`, RecommendationMetadata) | derived projection with `DerivedEdgeProperties`; only from a RECOMMENDS speech-act occurrence | derive | CL-016 → D-011, W21 |
| `Person.linksTo` (`LINKS_TO`), `HAS_PARTICIPANT_TOKEN` | `ResolutionHypothesis.PROPOSES_MATCH`; retired | retire | W01, W23 |
| `Claim.evidenceStrength`, `SafetySignal.evidenceStrength`, edge `evidenceStrength`/`confidence` | `ClaimEvidenceAssessment`, `SafetySignal` as EvidenceAssessment, `EvidenceStrengthAssessment`; legacy values are derived hints | move | W21, W17, W10 |
| Relationship-property types `TemporalMetadata`, `RoleMetadata`, `OwnershipMetadata`, `DoseMetadata`, `ExtractionMetadata`, `OrderingMetadata`, `MeasurementMetadata`, `AssociationMetadata`, `MechanismLinkMetadata`, `MediaLinkMetadata`, … | `AssertedEdgeProperties`, `StateEpisodeProperties`, `DerivedEdgeProperties`, `StructuralEdgeProperties` and owner specializations (`RoleEdgeProperties`, `UsageEdgeProperties`, `StepDoseProperties`, `MediaLinkProperties`, …) | rename | contract B4 |
| `Entity.name: String!` | `name: String` (nullable) | refine | D-013 |
| `privacyClass` lowercase values | `PUBLIC` / `INTERNAL` | refine | MR-10 |
| `@vector(... provider: OPEN_AI ...)` | provider-less `@vector` templates in the operations file; no embedding service presumed | refine | D-014 |

## 3. Compatibility rules

1. **Identity.** `uid` is stored beside the live `id`; `id` equals the opaque uid segment. Nodes written by Cypher must set `id` (or the aliased stored id) and timestamps: backfill statement set `validation/fixtures-final/99-normalize-live-ids.cypher` (M-01). API-created nodes receive an autogenerated `id` that does not satisfy INV-106; kernel-governed creates go through the ingestion service (W00-SR-02, W12-SR-11).
2. **Labels.** Relabel statements for merged live types (`Compound`→`ChemicalSubstance` etc.) and archetype labels on every node precede the uniqueness constraints; the operations file ships them as a commented, ordered migration block.
3. **Edges.** Legacy asserted edges without `assertionUid`/`recordedFrom` are returned only as `LEGACY_UNDATED` (QS-2b) and never participate in as-of answers; new writes use the frozen property types.
4. **Clients.** Query and mutation names generated by `@neo4j/graphql` 7.6.3 from the final file differ from the live API wherever a type was renamed; `name` becomes nullable; the live fulltext query names are preserved.
5. **Runtime.** APOC Core 5.26.x is required for DateTime reads (MR-12); Enterprise existence/type constraints are optional and unverified.
