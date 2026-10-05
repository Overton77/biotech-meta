# W04 model cards

Conventions on every node (contract B2, not repeated per card): `id` (= opaque uid segment), `uid` (`hu:<token>:<opaque>`), `name` (nullable, presentation), `description`, `mongoResearchRunId` (internal lineage), `createdAt`/`updatedAt` (operational), `privacyClass` (all W04 types PUBLIC; nothing W04 owns is private-personal), `maturity`, `schemaVersion`. Kinds: A = asserted (comes from a source through an Assertion), O = observed (verbatim from a capture), C = calculated, D = derived display projection, Op = operational. "Null" means unknown or not stated unless the card says otherwise (catalog `nullMeans`). Maturity is PROVISIONAL for every element unless stated.

## Nodes

### Product (Entity; labels `Product`, `Entity`; token `product`; module products_and_commerce)
- Meaning: the enduring marketed concept. Identity survives renaming of variants, reformulation, package and merchant changes. It is not a variant, formulation, package, listing, approval, or regulatory class.
- Identity keys: `uid`. Aliases: external `Identifier`s by `HAS_IDENTIFIER` (W00). A name or brand string never establishes identity (CQ-ID-01; `[SIMILAR_NAME, SAME_IDENTITY]`).
- Properties: `entityType: String!` (Op, constant). `productKind: ProductKind` (A, marketer's presentation; temporal: current; null = unknown). Search fields (`searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding`: C, regenerable, never evidence, INV-107). Legacy display (D or legacy A, no CQ): `productType` (deprecated), `applicationContext`, `categories`, `targetCustomer`, `deliveryModel`, `productClass`, `indicationSummary`, `modalitySummary`. Guarded projections, not settable through the API: `status: ProductStatus`, `approvedYear: Int` (YEAR precision), `regulatoryAuthorizationId`, `primaryRegulatoryIdentifier`, `formulationSummary`, `launchYear` (YEAR precision of earliest accepted `MARKETS_PRODUCT.validFrom`), `regulatoryProjectionStatusUids: [String!]` (names the RegulatoryStatus records projected; V-322 / V-W04-03). `currentAsOf: DateTime` (Op).
- Edges: out `HAS_VARIANT` → ProductVariant (asserted, one_or_more, AssertedEdgeProperties); out `CONTAINS` → IngredientMaterial (derived, many, DerivedEdgeProperties, read-only); out `CONTAINS_COMPOUND_FORM` → ChemicalForm (derived, read-only); out `HAS_SNAPSHOT` → ProductSnapshot (legacy structural, read-only); in `OFFERS`, `MANUFACTURES`, `CONTRACTS_MANUFACTURING` from Organization, in `LISTS_PRODUCT` from MerchantListing (legacy read-only, no properties); out `IMPLEMENTS_PLATFORM` (W08, UsageEdgeProperties), `IMPLEMENTS_PANEL` (W15 type, AssertedEdgeProperties), `DELIVERS_LABTEST` (AssertedEdgeProperties, owner pending), `HAS_SAFETY_SIGNAL` (W17, SafetyEdgeProperties); out `FOLLOWS_PATHWAY`, `HAS_REGULATORY_STATUS` (derived, read-only); out `CLASSIFIED_AS` → Device / ToolOrInstrument (legacy read-only).
- Forbidden: Product carries no `HAS_FORMULATION_VERSION`, no `LABEL_FOR` target, no study edge (V-W04-01, INV-201).
- Sources: SRC-ELYSIUM-BASIS-PRODUCT (identity as marketed), S08/S09.

### ProductVariant (Entity; `ProductVariant`, `Entity`; token `product-variant`; products_and_commerce)
- Meaning: a consumer-, regulator- or commerce-distinguishable realization (unit strength, dosage form, flavor, jurisdiction). Candidate B is adopted. Example pair: Tru Niagen 300mg capsule vs 150mg capsule.
- Properties: `entityType` (Op); `strengthDescriptor` (O, verbatim marketing strength); `dosageForm` (A, free text until W02 publishes a controlled list); `flavor` (A); `jurisdiction` (A, ISO 3166-1 alpha-2 or `EU`; null = not recorded).
- Edges: in `HAS_VARIANT` (exactly_one Product, service-enforced); out `HAS_PACKAGE_CONFIGURATION` (asserted, NONEXCLUSIVE, AssertedEdgeProperties); out `HAS_FORMULATION_VERSION` (asserted, EXCLUSIVE per jurisdiction, FormulationEdgeProperties); out `IDENTIFIED_BY` → TradeItemIdentifier (asserted, IdentifierLinkProperties); in `LABEL_FOR` from LabelSnapshot; out `CONTAINS` (derived).
- A study that names a variant reaches it only through `EvidenceApplicability` or a `ResolutionHypothesis` (INV-201, R1/R2).

### PackageConfiguration (VersionedState; `PackageConfiguration`, `VersionedState`; token `package-configuration` requested; products_and_commerce)
- Meaning: an immutable package payload (form, unit count, net quantity), attached to one or more variants by asserted NONEXCLUSIVE `HAS_PACKAGE_CONFIGURATION` episodes. A count change is a new configuration plus a bounded episode, never a new formulation (V-W04-06). A multi-bottle kit is a W15 Bundle.
- Properties: `stateType` (Op), `payloadHash` (C, sha256 over packageForm, unitCount, unitDescription, netQuantity, netQuantityUnit), `effectiveFrom/effectiveTo` (A, source-stated payload bounds only), `packageForm` (O), `unitCount: Int` (O; null = not stated), `unitDescription` (O), `netQuantity: Float` + `netQuantityUnit` (UCUM) (O).
- Edges: in `HAS_PACKAGE_CONFIGURATION`; out `IDENTIFIED_BY` → TradeItemIdentifier (GTIN, merchant SKU; `isPrimary` true for the GTIN); in `LABEL_FOR`.
- Evidence: S09 (30 → GTIN 850015311857, 90 → 850015311895; "180" = 90-count KIT).

### ProductSnapshot (VersionedState; `ProductSnapshot`, `VersionedState`; token `product-snapshot` requested; live seam)
- Meaning: the live `TemporalSnapshot` cache (one node per recorded episode). Read-only for new writes. Its payload is frozen after commit except the single `recordedTo` write (V-513).
- Properties: the live fields unchanged (D display payload), plus `stateType`, `payloadHash`, `assertionUids` (round 0007 §12). `formulationSummary` is display text only (INV-005). `status`/`approvedYear` are YEAR-precision projections.
- Edges: in `HAS_SNAPSHOT` from Product (read-only); out `SUPPORTED_BY_DOCUMENT`/`SUPPORTED_BY_CHUNK` (W20 derived shortcuts, read-only).

### FormulationVersion (VersionedState; `FormulationVersion`, `VersionedState`; token `formulation`; products_and_formulations)
- Meaning: a time-bounded composition of a variant in one jurisdiction, as stated by its authorizing source, together with the serving its per-serving amounts refer to. Authority for composition (INV-005). Not measured composition (INV-006), not a lot, not a study intervention.
- Properties: `stateType`, `payloadHash` (C: jurisdiction, serving uid, and per component material uid, role, quantity, unitCode, quantityBasis, massBasis, amountReferent, nesting; excludes declaredAs and versionName), `effectiveFrom/effectiveTo` (A, e.g. "new formula from lot X"; not the query validity), `versionName` (Op display), `jurisdiction` (A; partition key).
- Edges: in `HAS_FORMULATION_VERSION` (FormulationEdgeProperties); out `HAS_INGREDIENT_COMPONENT` (structural, one_or_more, orderIndex = label order); out `USES_SERVING_DEFINITION` (structural, zero_or_one, required when a component is PER_SERVING, V-W04-10); in `DECLARES_FORMULATION` from LabelSnapshot (asserted).
- Temporal: valid time is on the attachment episode. A correction closes the episode in recorded time and opens one to a replacement version (`SUPERSEDES {SOURCE_CORRECTION}`). A reformulation bounds the episode's valid time (`SUPERSEDES {VALIDITY_BOUNDED}`) and opens a new episode to the new version (fixture 01).
- Specification: reached through `IngredientComponent -USES_MATERIAL-> IngredientMaterial -GOVERNED_BY_SPECIFICATION-> SpecificationVersion` (W11, D-009). A product-level specification edge stays CANDIDATE (no CQ failing case).

### IngredientComponent (VersionedState; `IngredientComponent`, `VersionedState`; token `component`; products_and_formulations)
- Meaning: a contextual component of one formulation version.
- Properties: `stateType`, `payloadHash`; `role` (A, String: DIETARY_INGREDIENT, OTHER_INGREDIENT, PROPRIETARY_BLEND, BLEND_CONSTITUENT, CAPSULE_SHELL; list requested); `labelOrder: Int` (O); `quantity: Float` (A from label; null when not stated); `unitCode` (UCUM); `quantityBasis: QuantityBasis` (PER_SERVING for Supplement Facts); `massBasis: MassBasis` (required when quantity set; UNSPECIFIED allowed; V-W04-05); `amountReferent: AmountReferent` (never ACTIVE_MOIETY, V-330 / V-W04-05); `declaredAs` (O verbatim, display); `isDietaryIngredient: Boolean` (null = not classified).
- Edges: in `HAS_INGREDIENT_COMPONENT` (exactly one FormulationVersion); out/in `NESTED_COMPONENT` (structural); out `USES_MATERIAL` → IngredientMaterial (asserted, exactly_one, V-005).
- Calculated amounts: `ACTIVE_MOIETY_AMOUNT` CALCULATED literal Assertions have the component as subject (V-W04-04).

### LabelSnapshot (InformationArtifact; `LabelSnapshot`, `SourceSnapshot`, `InformationArtifact`; token `snapshot`; labels)
- Meaning: a captured label panel. It is the same node as the W00 `SourceSnapshot` capture and is immutable.
- Properties: `artifactType`; snapshot fields with W00's stored names (`publishedAt`, `observedAt`, `retrievedAt`, `contentHash`, `contentHashBasis`, `captureCompleteness`, `canonicalUri`, `storageUri`, `archiveUri`, `mimeType`, `language`); `jurisdiction` (O); `labelVersionText` (O verbatim revision marker; null = none printed).
- Edges: out `LABEL_FOR` → ProductVariant or PackageConfiguration (asserted; one relationship type, two GraphQL fields; required to a package when the label states servings per container, V-W04-07); out `DECLARES_FORMULATION` (asserted); out `HAS_DECLARATION` (structural, orderIndex = panel order); out `USES_SERVING_DEFINITION` (structural); in `HAS_SNAPSHOT` from Source (W00); out `HAS_LOCATOR` (W00).
- Locator recommendation: one `TEXT_QUOTE` per declaration line, with `section: 'Supplement Facts'` as a fallback (decision W04-D06).

### LabelDeclaration (InformationArtifact; `LabelDeclaration`, `InformationArtifact`; token `label-declaration`; labels)
- Properties: `artifactType`; `verbatimText` (O, exactly as printed, typos kept: "Pantent-Pending"); `declarationKind: DeclarationKind`; `panelOrder: Int`; `contentHash` (C, NFC-WS1 of verbatimText); `observedAt` (copy of the snapshot's).
- Edges: in `HAS_DECLARATION` (exactly one snapshot, V-W04-11); out `DECLARATION_IDENTIFIES_MATERIAL` → IngredientMaterial (asserted, zero_or_one); out `HAS_QUANTITY_DECLARATION` (structural, zero_or_one).
- Never also a MeasuredResult (V-011). Never a listing title (forbidden `[LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]`).

### QuantityDeclaration (InformationArtifact; `QuantityDeclaration`, `InformationArtifact`; token `quantity-declaration` requested; labels)
- Properties: `artifactType`; `value: Float` (O); `unitCode` (O, UCUM); `quantityBasis: QuantityBasis` (catalog `basis`, renamed); `dailyValuePercent: Float` (O; null when not printed); `dailyValueStatus: ReportedStatus` (REPORTED / NOT_APPLICABLE for "Daily Value not established" / NOT_REPORTED); `amountReferent: AmountReferent` (rule-classified from the label line per 21 CFR 101.36); `amountReferentUid` (pointer, null = unresolved).
- Edges: in `HAS_QUANTITY_DECLARATION` (exactly one declaration).

### ServingDefinition (VersionedState; `ServingDefinition`, `VersionedState`; token `serving-definition` requested; labels)
- Properties: `stateType`, `payloadHash`; `servingCount: Float` (O); `unitDescription` (O, the form term required by 101.36(b)(1)(i)); `servingsPerContainer: Float` (O, package-scoped; null on a formulation's serving); `servingStatementVerbatim` (O).
- Edges: in `USES_SERVING_DEFINITION` from LabelSnapshot and from FormulationVersion (domain extension W04-D07). V-W04-07.

## Relationship types (all owned by W04 unless noted)

| Type | Domain → range | Class | Cardinality | Properties | Exclusivity / notes |
|---|---|---|---|---|---|
| HAS_VARIANT | Product → ProductVariant | asserted | variant: exactly_one product | AssertedEdgeProperties | NONEXCLUSIVE; media variants use W22's `HAS_MEDIA_VARIANT` (CL-014) |
| HAS_PACKAGE_CONFIGURATION | ProductVariant → PackageConfiguration | asserted (asserted_edge) | many | AssertedEdgeProperties | NONEXCLUSIVE (catalog) |
| HAS_FORMULATION_VERSION | ProductVariant → FormulationVersion | asserted (asserted_edge) | many episodes; at most one believed per (V, R, jurisdiction) | FormulationEdgeProperties | EXCLUSIVE, partitionBy jurisdiction; V-505, V-508, V-509, V-W04-08 |
| HAS_INGREDIENT_COMPONENT | FormulationVersion → IngredientComponent | structural | one_or_more | StructuralEdgeProperties (orderIndex) | part of payload |
| NESTED_COMPONENT | IngredientComponent → IngredientComponent | structural | many | StructuralEdgeProperties | blend constituents; nested amounts may be unknown (OPEN-QUESTIONS P1-6) |
| USES_MATERIAL | IngredientComponent → IngredientMaterial | asserted | exactly_one | AssertedEdgeProperties | V-005 |
| CONTAINS | Product / ProductVariant → IngredientMaterial | derived | many | DerivedEdgeProperties | rule `contains-v1`: believed `HAS_FORMULATION_VERSION` (recordedTo null) → component → `USES_MATERIAL`; inputs only HAS_VARIANT / HAS_FORMULATION_VERSION / USES_MATERIAL (V-004, V-W04-02) |
| CONTAINS_COMPOUND_FORM | Product → ChemicalForm | derived | many | DerivedEdgeProperties | rule `contains-form-v1` adds `HAS_CHEMICAL_FORM` input; live DoseMetadata moved |
| IDENTIFIED_BY | ProductVariant / PackageConfiguration (/ MerchantListing, field by W15; Metric field by W07 uses the same type for LOINC) → TradeItemIdentifier / Identifier | asserted | many | IdentifierLinkProperties | a shared scheme/value across issuers is not identity |
| LABEL_FOR | LabelSnapshot → ProductVariant / PackageConfiguration | asserted | zero_or_one target per snapshot | AssertedEdgeProperties | two GraphQL fields, one type |
| DECLARES_FORMULATION | LabelSnapshot → FormulationVersion | asserted | zero_or_one | AssertedEdgeProperties | a declaration supports, does not equal, composition |
| HAS_DECLARATION | LabelSnapshot → LabelDeclaration | structural | many | StructuralEdgeProperties | V-W04-11 |
| HAS_QUANTITY_DECLARATION | LabelDeclaration → QuantityDeclaration | structural | zero_or_one | StructuralEdgeProperties | |
| DECLARATION_IDENTIFIES_MATERIAL | LabelDeclaration → IngredientMaterial | asserted | zero_or_one | AssertedEdgeProperties | identification, not containment (CQ-ID-03) |
| USES_SERVING_DEFINITION | LabelSnapshot / FormulationVersion → ServingDefinition | structural | zero_or_one | StructuralEdgeProperties | domain extended (W04-D07) |
| DELIVERS_LABTEST (pending owner) | Product → LabTest | asserted | many | AssertedEdgeProperties | W04-SR-09 |
| Live successors referenced (other owners) | IMPLEMENTS_PLATFORM (W08), IMPLEMENTS_PANEL (W15), HAS_SAFETY_SIGNAL (W17), FOLLOWS_PATHWAY / HAS_REGULATORY_STATUS (W13, derived), SUPPORTED_BY_DOCUMENT / SUPPORTED_BY_CHUNK (W20), SELLS_PRODUCT (W15) | | | | W04 writes only the Product-side fields |
| Legacy read-only (no properties exposed) | OFFERS, MANUFACTURES, CONTRACTS_MANUFACTURING, LISTS_PRODUCT, CLASSIFIED_AS, HAS_SNAPSHOT | legacy | | none | returned as LEGACY_UNDATED by QS-2b-style reads |

## Relationship-property type

### FormulationEdgeProperties (owner W04)
Every field of `AssertedEdgeProperties` (`relationshipUid!`, `assertionUid!`, `validFrom`, `validTo`, `validFromPrecision`, `validToPrecision`, `validFromBasis!`, `validToBasis!`, `recordedFrom!`, `recordedTo`, `mongoResearchRunId`) plus `jurisdiction: String`, the exclusivity partition key. It equals `FormulationVersion.jurisdiction` (V-W04-08) and is null only on legacy edges. Immutable after commit except one `recordedTo` write. Bounds, precisions and bases equal the authorizing Assertion's (V-505).

## Enums (owner W04)

- `ProductStatus` {DISCOVERY, RESEARCH, PRECLINICAL, CLINICAL, APPROVED, DISCONTINUED}: live values unchanged. APPROVED is guarded (V-322, V-W04-03). Development stages are company statements.
- `ProductKind` {DIETARY_SUPPLEMENT, CONVENTIONAL_FOOD, DRUG, BIOLOGIC, MEDICAL_DEVICE, CONSUMER_DEVICE, DIAGNOSTIC_TEST_SERVICE, COSMETIC, OTHER}: how the marketer presents the product, not a regulatory or sector classification. DIETARY_SUPPLEMENT and DIAGNOSTIC_TEST_SERVICE have fixtures or live use (Basis, Tru Niagen; Elysium Index via live IMPLEMENTS_PANEL). The others carry live productType strings forward. A new value is a ledger request.
- `DeclarationKind` {NUTRIENT, OTHER_DIETARY_INGREDIENT, DIETARY_INGREDIENT (0.1.0 compatibility), PROPRIETARY_BLEND, BLEND_CONSTITUENT, SOURCE_INGREDIENT, OTHER_INGREDIENT, DIRECTIONS, WARNING, OTHER_STATEMENT}: grounded in 21 CFR 101.36 (S11).

Kernel enums used, not owned: QuantityBasis, MassBasis, AmountReferent, ReportedStatus, ContentHashBasis, CaptureCompleteness, TimePrecision, ValidTimeBasis, PrivacyClass, NodeMaturity (W00).

## Candidates kept out of the fragment

| Candidate | Why it stays out | What would admit it |
|---|---|---|
| `FormulationVersion -GOVERNED_BY_SPECIFICATION-> SpecificationVersion` (finished-product specification) | no CQ fails without it; material-level specification serves CQ-ID-05 | a source that versions a finished-product specification independently of materials |
| `ProductVariant.identityBasis` enum (why a variant is distinct) | the HAS_VARIANT assertion's locator already carries the basis | an ingestion failure where two variants cannot be told apart |
| `NESTED_DECLARATION` (indented blend lines) | no blend label captured in this run | a proprietary blend fixture (OPEN-QUESTIONS P1-6) |
| Controlled `role` / `dosageForm` enums | vocabulary belongs to W02 | W02 publication (W04-SR-10) |
