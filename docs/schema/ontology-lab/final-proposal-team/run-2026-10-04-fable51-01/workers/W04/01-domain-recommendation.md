# W04 Products, formulations and labels: domain recommendation

Worker W04 (Opus 5.5), run `run-2026-10-04-fable51-01`. Authority: catalog 0.2.0 (`8fb50ff0…84f0`), frozen contract `01-shared-contract.md`, registry row W04. This is a research packet; Fable 5.1 writes the final schema.

## 1. Boundary and subdomains

W04 owns three things that the world keeps apart and the live schema collapses into `Product`:

| Subdomain | Question it answers | Canonical module | Archetype mix |
|---|---|---|---|
| Commercial identity | Which enduring product, which consumer-distinguishable variant, which package (count, net quantity, GTIN)? | `products_and_commerce` (identity part only; offers, listings, prices stay W15) | Entity (Product, ProductVariant), VersionedState (PackageConfiguration) |
| Composition | What did a variant contain during a time interval, per which serving, by which mass basis and referent? | `products_and_formulations` | VersionedState (FormulationVersion, IngredientComponent, ServingDefinition used by a formulation) |
| Declarations | What did a captured label say, verbatim, and what does each stated amount weigh? | `labels` | InformationArtifact (LabelSnapshot, LabelDeclaration, QuantityDeclaration), VersionedState (ServingDefinition used by a label) |

Out of scope, referenced by name only: material and substance identity (W02: `IngredientMaterial`, `ChemicalForm`, `ChemicalSubstance`), specification payloads (W11 `SpecificationVersion`, D-009; reached through `IngredientMaterial -GOVERNED_BY_SPECIFICATION->`), lots and measurements (W12), offers, listings and bundles (W15), regulatory status (W13), study interventions (W09), applicability (W10), label image regions (W22 `ProductLabelRegion`).

## 2. Identity, state, artifact, occurrence

| Element | Archetype | Identity key | What changes create a new node |
|---|---|---|---|
| `Product` | Entity | `uid` (`hu:product:`) | never by name change, reformulation, package change or merchant; only a different marketed concept |
| `ProductVariant` | Entity | `uid` (`hu:product-variant:`) | a consumer-, regulator- or commerce-distinguished dimension: unit strength, dosage form, flavor, jurisdiction (round 0001 Candidate B, adopted below) |
| `PackageConfiguration` | VersionedState | `uid` + `payloadHash` | any change of package form, unit count, net quantity; attached NONEXCLUSIVE (30, 90 counts coexist) |
| `FormulationVersion` | VersionedState | `uid` + `payloadHash` over composition | any change of material, amount, unit, quantity/mass basis, referent or serving; never a package change; never label wording alone |
| `IngredientComponent` | VersionedState | `uid` + `payloadHash` | belongs to exactly one formulation version |
| `ServingDefinition` | VersionedState | `uid` + `payloadHash` | serving count/unit, plus servings per container only when it is a package label's serving |
| `LabelSnapshot` | InformationArtifact, specialization of W00 `SourceSnapshot` (same node, `hu:snapshot:` uid) | snapshot uid + `contentHash` | every capture (immutable) |
| `LabelDeclaration`, `QuantityDeclaration` | InformationArtifact | uid | every declaration line of every snapshot |
| `ProductSnapshot` | VersionedState (live compatibility) | uid + `payloadHash` | one node per recorded episode (round 0007 §12); read-only cache |

No occurrence type is needed in W04. A reformulation, relaunch or package switch is not stored as an event; it is the boundary between two attachment episodes, and its source is the `SourceSnapshot` (and, for publisher corrections, W00's `SourceRevisionEvent`).

## 3. Decisions that settle the open questions (evidence in `03-source-manifest.md`, rationale in `05-decision-seam-ledger.md`)

1. **Variant vs formulation vs package (OPEN-QUESTIONS P0-1, round 0001).** Adopt Candidate B with three tests, each grounded in a captured record:
   - *Package-only:* the Tru Niagen 300mg product record lists sizes 30, 90 and 180 under one product with distinct SKUs and GTINs (850015311857, 850015311895, 850064273106) and one Supplement Facts panel (`NIAGEN® (nicotinamide riboside chloride) 300mg`, 1 capsule per serving). Result: one variant, one formulation version, two `PackageConfiguration`s attached concurrently. The "180" SKU is `CTNUS3006090010-KIT` (a kit of the 90 SKU), so it is a W15 `Bundle` of package configurations, not a third configuration.
   - *Variant:* Tru Niagen 150mg ("Two capsules make a 300mg serving") versus 300mg (1 capsule per serving): the same per-serving amount but a different unit strength and SKU family is a different `ProductVariant`.
   - *Formulation:* a change of material, amount, basis or serving is a new `FormulationVersion` attached by a new `HAS_FORMULATION_VERSION` episode. A change of label wording that leaves material, amount and serving unchanged but alters the declared basis (Basis: "NR-E (Patent-Pending Crystalline Nicotinamide Riboside) 250 mg" through capture 2025-09-10, "Elysium NR (Nicotinamide Riboside Chloride) 250 mg" from capture 2026-03-05) is a new "as declared" version whose difference is classified `DECLARED_BASIS_CHANGED_COMPOSITION_NOT_ESTABLISHED`, with an open material-identity hypothesis. It is never reported as a reformulation.
2. **Servings per container is a package fact.** 21 CFR 101.36(b)(1)(ii) lets it be omitted when stated in the net quantity declaration, and the live Tru Niagen page shows "Servings Per Container: 90" in its text panel while its 30-count label image states 30 servings. A `ServingDefinition` with `servingsPerContainer` belongs only to a label that is `LABEL_FOR` a `PackageConfiguration` (V-W04-07). The formulation's own serving (needed to read `PER_SERVING` amounts) has none.
3. **The formulation carries its serving.** Per-serving amounts mean nothing without the serving (150mg and 300mg Tru Niagen share "300 mg per serving"). `USES_SERVING_DEFINITION` gains `FormulationVersion` as a domain (decision W04-D07). The serving is part of the formulation payload hash.
4. **Amount referent, mass basis, calculated amounts.** `QuantityDeclaration.amountReferent` and `IngredientComponent.amountReferent` keep the catalog enum. `massBasis` is required whenever a component states an amount (`UNSPECIFIED` allowed) (V-W04-05). Active-moiety amounts are CALCULATED literal Assertions on the component (predicate `ACTIVE_MOIETY_AMOUNT`, candidate registration W04-SR-04) with `derivationRule` and `DERIVED_FROM_ASSERTION` inputs `HAS_FORMULATION_VERSION` and `HAS_ACTIVE_MOIETY`. Example: 300 mg NR chloride × 255.25 / 290.70 (PubChem CIDs 439924 and 90480033, retrieved 2026-10-04) = 263.42 mg NR cation per serving. A measured lot result is a W12 `MeasuredResult` and is never merged with either.
5. **"Daily Value not established" is a third state.** `QuantityDeclaration.dailyValueStatus` reuses the kernel `ReportedStatus` (REPORTED / NOT_REPORTED / NOT_APPLICABLE), so the "†" footnote on both real labels does not collapse into a null percentage (INV-007).
6. **Label snapshots are snapshots.** Every 0.2.0 fixture already labels them `:LabelSnapshot:SourceSnapshot:InformationArtifact` with `hu:snapshot:` uids. W04 keeps that: no second artifact for one capture, and a capture can be classified as a label afterwards without a uid change (W04-SR-01 asks W00 to map `LabelSnapshot` to the `snapshot` token).
7. **Selector for commercial pages (OPEN-QUESTIONS P0-5 residual).** Across five Wayback captures of the Basis Supplement Facts page (2021-12-08 to 2026-07-17), the shop theme changed, a "Side Effects" row was added, navigation and footer changed, and the 2026 capture replaced the label image with a no-image placeholder. Per-declaration-line `TEXT_QUOTE` anchors ("PT (Pterostilbene) 50mg"; "Serving Size: 2 Vegetarian Capsules, Servings: 30") re-anchor EXACT across all five. The NR line re-anchors FUZZY across a silent typo fix ("Pantent" → "Patent") and does not re-anchor across the 2025-09 → 2026-03 declaration change, which is the desired signal. `TEXT_POSITION` cannot survive (the prefix content changed), and `IMAGE_REGION` cannot survive either (the image disappeared). Recommendation: one `TEXT_QUOTE` per declaration line, with `section: 'Supplement Facts'` kept as the coarse fallback.
8. **Formulation exclusivity partition.** `FormulationEdgeProperties` = every `AssertedEdgeProperties` field plus `jurisdiction`, the `predicateExclusivity` partition key stored on the episode. It must equal `FormulationVersion.jurisdiction` (V-W04-08). The key lives on the edge so that the exclusivity check reads it from the edge (relationship property indexes cannot cover the target node's property).

## 4. Disposition of every live and catalog element in scope

Live `Product` (lines 735–783) and `ProductSnapshot` (785–822), `ProductStatus` (696–703), `DoseMetadata` (217–226). Full machine-readable mapping: `migration-map.yaml`.

| Element | Disposition | Final form and reason |
|---|---|---|
| `Product.id/name/description/mongoResearchRunId/createdAt/updatedAt` | keep | `name` nullable (D-013) |
| `searchText/searchFields/embeddingModel/embeddingDimensions` | keep | `SearchIndexable` |
| `searchEmbedding` | keep (refine) | regenerable; `@vector` without provider only if Fable keeps the QS-8 justification (D-014) |
| `primaryRegulatoryIdentifier` | refine → derive | read-only display of an `Identifier` record (HAS_IDENTIFIER); a string hit is a candidate, never identity (CQ-ID-04); stays in `ProductSearch` |
| `productType` | merge into `productKind` (+ keep deprecated) | free text → `ProductKind` enum where mappable; kept read/write for the fulltext index and old clients |
| `categories` | keep | display tags, never taxonomy |
| `launchYear` | derive | YEAR-precision display of earliest accepted `MARKETS_PRODUCT` validFrom; not settable. A Shopify `created_at`/`published_at` (Tru Niagen 300mg record: 2024-08-06 / 2024-09-04) is a store-record date, not a launch |
| `status` (`ProductStatus` incl. `APPROVED`) | derive (guarded) | not settable; APPROVED only with an APPROVAL `RegulatoryStatus` named in `regulatoryProjectionStatusUids` (V-322, V-W04-03) |
| `approvedYear` | derive (guarded) | as above |
| `regulatoryAuthorizationId` | derive | Identifier on the projected status/submission (W13) |
| `formulationSummary` | derive (display only) | INV-005; not settable; never parsed |
| `applicationContext`, `targetCustomer`, `deliveryModel`, `productClass`, `indicationSummary`, `modalitySummary` | keep (legacy display) | no CQ depends on them; `indicationSummary` is never an indication record (claims W21, approvals W13) |
| `currentAsOf` | keep | materialization timestamp; answers state `lastObservedAt` |
| new `entityType`, `privacyClass`, `maturity`, `schemaVersion`, `productKind`, `regulatoryProjectionStatusUids` | add | contract B2 / catalog `productKind` / V-322 citation |
| `snapshots` / `HAS_SNAPSHOT` | keep read-only | round 0007 §12 seam; relationship-type meaning overlap with Source→SourceSnapshot flagged (W04-SR-06) |
| `offeredBy` / `OFFERS` | keep read-only legacy, retire after migration | no properties exposed (legacy edges lack the non-null asserted fields); successor `SELLS_PRODUCT` derived from `SELLER_OF_RECORD_FOR` (W15, INV-306) |
| `manufacturedBy` / `MANUFACTURES`, `contractManufacturedBy` / `CONTRACTS_MANUFACTURING` | keep read-only legacy | successor asserted predicate and endpoint (Product vs variant vs lot) are W01/W11's (W04-SR-07) |
| `listedIn` / `LISTS_PRODUCT` | keep read-only legacy | successor `LISTING_FOR` → ProductVariant/PackageConfiguration (W15) |
| `containsCompoundForms` / `CONTAINS_COMPOUND_FORM` (`DoseMetadata`) | refine → derived, read-only | target `ChemicalForm` (D-002), `DerivedEdgeProperties`, rule `contains-form-v1`; dose fields move to `IngredientComponent` |
| `implementsPlatforms` / `IMPLEMENTS` (UsageMetadata) | rename | `IMPLEMENTS_PLATFORM` with `UsageEdgeProperties` (W08) |
| `classifiedAs` / `CLASSIFIED_AS` → union `ProductClassification` | split, read-only legacy | `classifiedAsDevices`, `classifiedAsInstruments` (no union owner exists); a product "classified as" a device is a W08 question (W04-SR-08) |
| `implementsPanels` / `IMPLEMENTS_PANEL` | keep (asserted) | W15 owns the type; `AssertedEdgeProperties` |
| `deliversLabTests` / `DELIVERS_LABTEST` | keep (asserted) | relationship has no registry owner (W04-SR-09) |
| `followsRegulatoryPathways` / `FOLLOWS_PATHWAY` | derive, read-only | from `RegulatorySubmission -UNDER_PATHWAY->` (W13) |
| `hasRegulatoryStatuses` / `HAS_REGULATORY_STATUS` | derive, read-only | projection of `RegulatoryStatus -STATUS_OF->` (W13) |
| `hasSafetySignals` / `HAS_SAFETY_SIGNAL` | keep (asserted) | `SafetyEdgeProperties` (W17) |
| `PhysicalLocation.hostsProducts` / `HOSTS_PRODUCT` (incoming) | retire (recommendation to W01) | ambiguous between manufacture site, storage and retail stock; facility manufacture is W11, stock is W15 `InventoryItem` (W04-SR-07) |
| `Material.partOfProducts` / `PART_OF` (`DoseMetadata`) | retire into composition | `IngredientComponent -USES_MATERIAL->` (INV-005); W02/W11 dispose `Material` (CL-005) |
| `ProductLabelRegion.aboutProduct` / `ABOUT_PRODUCT` | seam (W22) | a label region locates a `LabelDeclaration` through `SourceLocator{IMAGE_REGION}`; its subject should be the variant or package, not the Product (W04-SR-05) |
| `ProductSnapshot` (all fields) | keep as read-only cache | adds `stateType`, `payloadHash`, `assertionUids`; `supportedByDocuments/Chunks` move to W20 `DerivedSupportProperties` |
| `ProductStatus` | keep (values unchanged) | APPROVED guarded |
| `DoseMetadata` | split/retire | `dose`→`quantity`, `doseUnit`→`unitCode`, `role`→`role`, `componentName`→`declaredAs`, `standardizedTo`→ MARKER_CONSTITUENT component (W02 standardization), `quantity` (Int) dropped (meaning undocumented) |
| Live unions containing `Product` (`Producible`, `ContractManufacturingTarget`, `TreatmentComponent`, `SafetySubject`, `Recommendable`, `StudyIntervention`, `StepSubstance`, `ProtocolResultMention`, `EventParticipant`, `EventSubject`, `EvidenceSubject`, `ClaimSubject`, `AssociationParticipant`, `MediaSubject`) | seam to union owners | add `ProductVariant` wherever a dose or composition matters (`StepSubstance`, `TreatmentComponent`); the `StudyIntervention` union is legacy read-only (D-003, INV-201) |
| Catalog `Product`, `ProductVariant`, `PackageConfiguration`, `FormulationVersion`, `IngredientComponent`, `LabelSnapshot`, `LabelDeclaration`, `ServingDefinition`, `QuantityDeclaration` | keep (refine) | as in `sdl-fragment.graphql`; `QuantityDeclaration.basis` renamed `quantityBasis`; `ServingDefinition` gains `servingStatementVerbatim`; `QuantityDeclaration` gains `dailyValueStatus` |
| Catalog relationships `HAS_VARIANT`, `HAS_PACKAGE_CONFIGURATION`, `IDENTIFIED_BY`, `HAS_FORMULATION_VERSION`, `HAS_INGREDIENT_COMPONENT`, `NESTED_COMPONENT`, `USES_MATERIAL`, `CONTAINS`, `CONTAINS_COMPOUND_FORM`, `LABEL_FOR`, `DECLARES_FORMULATION`, `HAS_DECLARATION`, `DECLARATION_IDENTIFIES_MATERIAL`, `HAS_QUANTITY_DECLARATION`, `USES_SERVING_DEFINITION` | keep; `USES_SERVING_DEFINITION` domain extended | union endpoints become two typed fields with one relationship type (no new unions) |
| Catalog `Trademark` (module products_and_formulations) | not W04 | registry T-001: W14 writes it |
| Catalog specification and process types in products_and_formulations | not W04 | W11 (D-009, T-002) |

## 5. Alternatives considered (rejected)

- **Candidate A (always new variant on strength or form change)** and **Candidate C (variant follows SKU continuity)**: A fails on the Basis record (same variant across a declared-basis change) and C fails on Tru Niagen 150mg vs 300mg (the same "Tru Niagen" SKU family, different unit strength).
- **Servings per container on the formulation**: fails on Tru Niagen (one formulation, 30 and 90 servings).
- **Package count as a variant**: fails on concurrency (30 and 90 coexist with one label composition) and on GS1 practice (a new GTIN per count, the same variant).
- **LabelSnapshot as a separate artifact linked to a SourceSnapshot**: duplicates one capture into two immutable nodes and breaks all six existing fixtures.
- **Active-moiety amount as an object assertion (component QUANTITATIVELY_CONTAINS NR cation with valueNumber)**: violates INV-003 / V-003 (object and literal together). The literal-plus-inputs form keeps the moiety identity in the `HAS_ACTIVE_MOIETY` input (W04-SR-04 also asks W00 whether quantity qualifiers next to an object should be allowed for `predicateClass: QUANTITY`).
- **One formulation version for the Basis wording change (retroactively SALT_FORM)**: claims that the 2021–2025 label declared the salt. It did not.

## 6. Smallest recommended model

Ten node types (nine catalog plus the live `ProductSnapshot` cache), three enums (`ProductStatus` unchanged, `ProductKind`, `DeclarationKind`), one relationship-property type (`FormulationEdgeProperties`), fifteen catalog relationship types, and the live Product edges handled as successors or read-only legacy fields. No new node type, no union and no kernel change. Two seam-level catalog refinements: the `USES_SERVING_DEFINITION` domain and the `quantityBasis` rename. One candidate predicate: `ACTIVE_MOIETY_AMOUNT`.
