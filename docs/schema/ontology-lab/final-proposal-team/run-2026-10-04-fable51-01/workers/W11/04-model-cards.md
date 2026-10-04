# W11 Model cards

Conventions: every node carries the B2 skeleton (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) and its archetype fields; these are not repeated per card. Privacy class of every W11 element is PUBLIC (no personal data; business contact strings appear only inside verbatim locator text owned by W00). "Kind" is asserted / observed / calculated / inferred / operational. Cardinality and class are enforced by `07-operations.md` validation, not by SDL.

uid tokens (W11-SR-08 to W00): `specification` (ManufacturingSpecification), `specification-version` (SpecificationVersion), `process` (ManufacturingProcess), `process-step` (ManufacturingStep), `capability` (ManufacturingCapability; already registered as a fixture token).

---

## Node: ManufacturingSpecification

- **Meaning:** enduring identity of one named specification owned by one party (supplier ingredient spec, finished-product spec, customer purchase spec, compendial monograph, in-process spec). Content lives only on versions. Not a material, test, certificate or status.
- **Archetype / labels:** Entity; `["ManufacturingSpecification", "Entity"]`. Module products_and_formulations. Maturity PROVISIONAL.
- **Identity:** `uid` (`hu:specification:<opaque>`). Alias keys: (owner uid from the `OWNS_SPECIFICATION` assertion, `documentIdentifier`) when the document number is public; otherwise none: two captures of one owner's spec are merged only by an `EquivalenceAssessment` (W00). Name is never identity.

| Property | Type | Null | Meaning / value states | Kind | Temporal |
|---|---|---|---|---|---|
| `entityType` | String! | no | `MANUFACTURING_SPECIFICATION` | operational | fixed |
| `specificationKind` | String (candidate enum SpecificationKind) | yes (required for new writes, V-W11-08) | INGREDIENT_SUPPLIER_SPECIFICATION, FINISHED_PRODUCT_SPECIFICATION, CUSTOMER_PURCHASE_SPECIFICATION, COMPENDIAL_MONOGRAPH, IN_PROCESS_SPECIFICATION | asserted | fixed (a kind change is a new identity) |
| `documentIdentifier` | String | yes | owner's document number; null = not public / not captured | observed | fixed |

| Edge (field) | Domain -> range | Dir | Class | Card. | Props |
|---|---|---|---|---|---|
| `versions` VERSION_OF_SPECIFICATION | SpecificationVersion -> ManufacturingSpecification | IN | structural | one_or_more | StructuralEdgeProperties |
| (owner) OWNS_SPECIFICATION | Organization -> ManufacturingSpecification | predicate only (organizations) | asserted (Assertion only) | many | - |

- **Forbidden implications (proposed, W11-SR-02):** `[OWNS_SPECIFICATION, PERFORMS_PROCESS]`; `[SHARES_SPECIFICATION, SAME_MATERIAL_IDENTITY]`.
- **Sources:** W11-S08, S09, S10. CQ: CQ-MF-C02, CQ-MF-C03, CQ-PF-03.

## Node: SpecificationVersion (D-009, the one payload)

- **Meaning:** one immutable version of a specification: label, effective bounds, revision id, criteria set (W12 nodes). Change of any criterion = new version. Not a lot, CoA, result or label.
- **Archetype / labels:** VersionedState; `["SpecificationVersion", "VersionedState"]`. Module products_and_formulations. Maturity PROVISIONAL.
- **Identity:** `uid` (`hu:specification-version:<opaque>`); `payloadHash` decides identity of content (identical hash under one specification = same version; ingestion MERGEs on (specification uid, payloadHash)).
- **payloadHash rule (calculated):** `sha256` over canonical JSON (sorted keys, no whitespace) of `{specificationUid, versionName, revisionIdentifier, effectiveFrom, effectiveTo, criteriaDigest}`; `criteriaDigest` = `sha256` over the newline-joined sorted `payloadHash` values of the version's `SpecificationCriterion` nodes, null when none captured. Written `sha256:<hex>` (D-016).

| Property | Type | Null | Meaning / value states | Kind | Temporal |
|---|---|---|---|---|---|
| `stateType` | String! | no | `SPECIFICATION_VERSION` | operational | fixed |
| `payloadHash` | String! | no | see rule | calculated | immutable |
| `effectiveFrom` / `effectiveFromPrecision` | DateTime / TimePrecision | yes | source-stated start (payload); null = not stated. USP NRCl: 2026-10-01, MONTH | asserted | immutable |
| `effectiveTo` / `effectiveToPrecision` | DateTime / TimePrecision | yes | source-stated end; null = unknown, never "in force" | asserted | immutable |
| `versionName` | String | yes | source-stated label; null = the source states none (both Niagen dossiers) | observed | immutable |
| `revisionIdentifier` | String | yes | owner's revision id ("Rev. 3"); null = not stated | observed | immutable |
| `criteriaCount` | Int | yes | number of criteria captured; null = not counted | calculated | immutable |
| `criteriaCaptureCompleteness` | CaptureCompleteness (W00) | yes | COMPLETE / PARTIAL_EXCERPT / UNKNOWN (UNKNOWN never = "no criteria") | observed | immutable |
| `criteriaDigest` | String | yes | `sha256:` digest; null when no criteria captured | calculated | immutable |

| Edge (field) | Domain -> range | Dir | Class | Card. | Props |
|---|---|---|---|---|---|
| `specification` VERSION_OF_SPECIFICATION | SpecificationVersion -> ManufacturingSpecification | OUT | structural | exactly_one | StructuralEdgeProperties |
| `governedMaterials` GOVERNED_BY_SPECIFICATION | IngredientMaterial -> SpecificationVersion | IN | asserted (asserted_edge; EXCLUSIVE per material + specification) | many | AssertedEdgeProperties |
| (criteria) CRITERION_OF_SPECIFICATION (name requested from W12) | SpecificationCriterion -> SpecificationVersion | IN | structural | many | W12 |
| (lots) MANUFACTURED_UNDER | ProductLot -> SpecificationVersion | IN | asserted (W12) | many | W12 |

- **Temporal:** which version governs a material when = `GOVERNED_BY_SPECIFICATION` episodes; corrections = `SUPERSEDES` on the assertion and a new episode; a criterion fix = a new version (never in place; V-W11-09 detects count drift).
- **Rule (forbidden, proposed):** `[SPECIFICATION_VERSION_CHANGE, MATERIAL_IDENTITY_CHANGE]` (V-W11-11 review queue).
- **Sources:** W11-S08 (2015 dossier, no label), W11-S09 (2019 EFSA table, no label, shelf-life basis), W11-S10 (monograph licensed, UNKNOWN criteria). CQ: CQ-MF-C02, CQ-MF-C03, CQ-PF-03, applicability `SAME_BRANDED_MATERIAL_SAME_SPEC`.

## Node: ManufacturingProcess

- **Meaning:** a described route for making a material or product (identity = route as described). Not a capability, facility, performer, quality claim or production scale.
- **Archetype / labels:** Entity; `["ManufacturingProcess", "Entity"]`. Module manufacturing_readiness (proposed, D-W11-01; baseline products_and_formulations). Maturity PROVISIONAL.
- **Identity:** `uid` (`hu:process:<opaque>`). Two routes are two identities even for the same material (crystalline-form route vs 2015 dossier route). Live `id` = opaque segment of uid.

| Property | Type | Null | Meaning | Kind | Temporal |
|---|---|---|---|---|---|
| `entityType` | String! | no | `MANUFACTURING_PROCESS` | operational | fixed |
| `processKind` | ProcessKind | yes | dominant kind as named; null = not extracted; UNKNOWN = source names none | asserted | fixed |
| `processKindVerbatim` | String | yes | unmapped live `processClass` string (migration residue) | observed | fixed |
| `processTechnologySummary` | String | yes | presentation only | operational | mutable display |

| Edge (field) | Domain -> range | Dir | Class | Card. | Props |
|---|---|---|---|---|---|
| `steps` HAS_STEP | ManufacturingProcess -> ManufacturingStep | OUT | structural | many, ordered | StructuralEdgeProperties (`orderIndex`) |
| `inputMaterials` INPUTS | ManufacturingProcess -> IngredientMaterial | OUT | asserted | many | ProcessIoProperties |
| `inputSubstances` INPUTS | ManufacturingProcess -> ChemicalSubstance | OUT | asserted | many | ProcessIoProperties |
| `producedMaterials` PRODUCED_BY_PROCESS | IngredientMaterial -> ManufacturingProcess | IN | asserted (NONEXCLUSIVE) | many | AssertedEdgeProperties |
| `performedBy` PERFORMS_PROCESS | Organization -> ManufacturingProcess | IN | asserted | many | AssertedEdgeProperties |
| `hostedAt` HOSTS_PROCESS | Facility -> ManufacturingProcess | IN | asserted | many | AssertedEdgeProperties |
| `capabilityStates` CAPABILITY_FOR_PROCESS | ManufacturingCapability -> ManufacturingProcess | IN | structural | many | StructuralEdgeProperties |

- **Retired live fields:** `qualitySystemKind` (-> CLAIMS_CGMP_COMPLIANCE assertion / W12 CertificationListing), `productionScale` (-> ManufacturingCapability capacity fields), `supportedBy` Chunk (-> Assertion provenance), `outputsMaterials` (-> PRODUCED_BY_PROCESS or step OUTPUTS), `producesMaterials`/PRODUCES (-> PRODUCED_BY_PROCESS inverse).
- **Sources:** W11-S08 (route), W11-S01..S05 (NAI powder process), W11-S06 (Cyanotech cultivation). CQ: CQ-MF-01, CQ-MF-04, CQ-MF-C04, CQ-MF-C05.

## Node: ManufacturingStep

- **Meaning:** one ordered step of exactly one process. Not a ProtocolStep (D-004), TestExecution or facility.
- **Archetype / labels:** Entity; `["ManufacturingStep", "Entity"]`. Module manufacturing_readiness (proposed). Maturity PROVISIONAL.
- **Identity:** `uid` (`hu:process-step:<opaque>`); natural key (process uid, orderIndex) inside one process (V-W11-10).

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `entityType` | String! | no | `MANUFACTURING_STEP` | operational |
| `stepKind` | String (candidate StepKind) | yes | REACTION, DEACETYLATION_OR_DEPROTECTION, CRYSTALLIZATION, PRECIPITATION, FILTRATION_OR_CENTRIFUGATION, WASHING, DRYING, MILLING, BLENDING, ENCAPSULATION, TABLETING, CULTIVATION, HARVEST, EXTRACTION, PACKAGING, OTHER | asserted |
| `operationKind` | String | yes | verbatim operation wording (live) | observed |
| `environmentGrade` | String | yes | verbatim cleanroom/hygiene grade; null = not stated | observed |

| Edge (field) | Domain -> range | Dir | Class | Card. | Props |
|---|---|---|---|---|---|
| `process` HAS_STEP | ManufacturingProcess -> ManufacturingStep | IN | structural | exactly_one | StructuralEdgeProperties |
| `inputMaterials` / `inputSubstances` INPUTS | step -> IngredientMaterial / ChemicalSubstance | OUT | asserted | many | ProcessIoProperties |
| `outputMaterials` / `outputSubstances` OUTPUTS | step -> IngredientMaterial / ChemicalSubstance | OUT | asserted | many | ProcessIoProperties |
| `usesEquipment` USES_EQUIPMENT | step -> ToolOrInstrument | OUT | asserted (W08 type) | many | UsageEdgeProperties (W08) |
| `usesPlatforms` USES_PLATFORM | step -> TechnologyPlatform | OUT | asserted (W08 type) | many | UsageEdgeProperties (W08) |

## Node: ManufacturingCapability

- **Meaning:** one immutable stage-and-capacity state of a manufacturing capability of an Organization or Facility. Not a facility, process, certification, status or quality claim.
- **Archetype / labels:** VersionedState; `["ManufacturingCapability", "VersionedState"]`. Module manufacturing_readiness. Maturity CANDIDATE -> PROVISIONAL with D-W11-01.
- **Identity:** `uid` (`hu:capability:<opaque>`); content identity by `payloadHash` over `{stage, capacityValue, capacityUnitCode, capacityBasis, capacityVerbatim, targetOperationalDate, targetOperationalDatePrecision, forProcessUid, forMaterialUid}`. One OPERATING payload can carry several episodes (NAI Carlsbad 2023 and 2024).

| Property | Type | Null | Meaning / value states | Kind | Temporal |
|---|---|---|---|---|---|
| `stateType` | String! | no | `MANUFACTURING_CAPABILITY` | operational | fixed |
| `payloadHash` | String! | no | see identity | calculated | immutable |
| `effectiveFrom/To` | DateTime | yes | rarely source-stated payload; validity is on the episode | asserted | immutable |
| `stage` | CapabilityStage! | no | OPERATING, PILOTING, PLANNED, SUSPENDED, DISCONTINUED; uncertainty lives on assertion status and adjudication, never as a null stage | asserted | immutable |
| `capacityValue` | Float | yes | stated amount; null = not stated (never 0) | asserted | immutable |
| `capacityUnitCode` | String (UCUM) | yes (required with value) | m2, L, kg/a, t/a, '%' (rate, UTILIZED only) | asserted | immutable |
| `capacityBasis` | CapacityBasis | yes | NAMEPLATE, UTILIZED, NOT_REPORTED | asserted | immutable |
| `capacityVerbatim` | String | yes | source wording; required in practice when NOT_REPORTED is paired with qualitative text | observed | immutable |
| `targetOperationalDate` / `...Precision` | DateTime / TimePrecision | yes | PLANNED only; forward-looking; no valid time (V-W11-03) | asserted | immutable |

| Edge (field) | Domain -> range | Dir | Class | Card. | Props |
|---|---|---|---|---|---|
| `forProcess` CAPABILITY_FOR_PROCESS | state -> ManufacturingProcess | OUT | structural | zero_or_one | StructuralEdgeProperties |
| `forMaterial` CAPABILITY_FOR_MATERIAL | state -> IngredientMaterial | OUT | structural | zero_or_one | StructuralEdgeProperties |
| `heldByOrganizations` HAS_CAPABILITY_STATE | Organization -> state | IN | asserted_edge, EXCLUSIVE per holder + (process, material) | zero_or_one holder per state (V-W11-04) | AssertedEdgeProperties |
| `heldByFacilities` HAS_CAPABILITY_STATE | Facility -> state | IN | asserted_edge, same | same | AssertedEdgeProperties |

- **Invariants:** INV-305 (V-324, proposed V-324r allowlist); forbidden `[PROMOTES_CAPABILITY, OPERATES_CAPABILITY]` (fixture 05 N1), `[PLANNED_CAPABILITY, OPERATING_CAPABILITY]` (N2, V-W11-01/03).
- **Derived inputs:** none; utilization ratios are never computed by the schema.
- **Sources:** W11-S01..S07, inherited round 0005. CQ: CQ-MF-04, CQ-MF-05, CQ-MF-C01.

---

## Relationship types (W11 sole writer)

| Type | From -> To | Class | Profile / props | Cardinality | Exclusivity | Notes |
|---|---|---|---|---|---|---|
| GOVERNED_BY_SPECIFICATION | IngredientMaterial -> SpecificationVersion | asserted | asserted_edge / AssertedEdgeProperties | many | EXCLUSIVE per (material, specification) (W11-SR-04) | catalog |
| VERSION_OF_SPECIFICATION | SpecificationVersion -> ManufacturingSpecification | structural | StructuralEdgeProperties | exactly_one | - | catalog |
| PRODUCED_BY_PROCESS | IngredientMaterial -> ManufacturingProcess | asserted | asserted_edge | many | NONEXCLUSIVE | catalog; absorbs live PRODUCES |
| HAS_STEP | ManufacturingProcess -> ManufacturingStep | structural | StructuralEdgeProperties (orderIndex) | many / step exactly_one | - | D-004 manufacturing only |
| HAS_CAPABILITY_STATE | Organization or Facility -> ManufacturingCapability | asserted | asserted_edge | holder per state zero_or_one | EXCLUSIVE per holder + line | catalog |
| CAPABILITY_FOR_PROCESS | ManufacturingCapability -> ManufacturingProcess | structural | StructuralEdgeProperties | zero_or_one | - | catalog |
| CAPABILITY_FOR_MATERIAL | ManufacturingCapability -> IngredientMaterial | structural | StructuralEdgeProperties | zero_or_one | - | catalog |
| PERFORMS_PROCESS | Organization -> ManufacturingProcess | asserted | asserted_edge | many | NONEXCLUSIVE | live, re-classed |
| HOSTS_PROCESS | Facility -> ManufacturingProcess | asserted | asserted_edge | many | NONEXCLUSIVE | live, re-targeted from PhysicalLocation |
| INPUTS | ManufacturingProcess or ManufacturingStep -> IngredientMaterial or ChemicalSubstance | asserted | ProcessIoProperties | many | NONEXCLUSIVE | absorbs live HAS_INPUT |
| OUTPUTS | ManufacturingStep (or Process for by-products) -> IngredientMaterial or ChemicalSubstance | asserted | ProcessIoProperties | many | NONEXCLUSIVE | absorbs live HAS_OUTPUT |

`assertedTypes` additions for the validation runner (W11-SR-12): HAS_CAPABILITY_STATE and GOVERNED_BY_SPECIFICATION and PRODUCED_BY_PROCESS are already present; add PERFORMS_PROCESS, HOSTS_PROCESS, INPUTS, OUTPUTS.

## Relationship-property type: ProcessIoProperties

All AssertedEdgeProperties fields (verbatim) plus:

| Field | Type | Meaning | Value states |
|---|---|---|---|
| `ioRole` | String (candidate enum ProcessIoRole) | STARTING_MATERIAL, REAGENT, SOLVENT, PROCESSING_AID, INTERMEDIATE, PRODUCT, BY_PRODUCT, EXCIPIENT, CULTURE_MEDIUM, PACKAGING_MATERIAL, UNKNOWN | null = not extracted |
| `quantity` | Float | stated amount | null = not stated, never 0 |
| `unitCode` | String (UCUM) | unit of quantity | required with quantity |
| `ioQuantityBasis` | String | PER_BATCH, PER_UNIT_OUTPUT_MASS, PER_UNIT_TIME, NOT_STATED | |
| `gradeText` | String | verbatim grade/concentration | |
| `asReportedName` | String | verbatim input name | |
| `orderIndex` | Int | order of charging within a step | |

Successor mapping: live DoseMetadata on INPUTS/OUTPUTS/PRODUCES/HAS_INPUT/HAS_OUTPUT (`dose`, `doseUnit` -> `quantity`, `unitCode` only when the source states a process amount; `role` -> `ioRole`; `componentName` -> `asReportedName`; `standardizedTo`, `quantity:Int` dropped (intake semantics, no process meaning)).

## Enums (W11 sole writer)

| Enum | Values | Source |
|---|---|---|
| CapabilityStage | OPERATING, PILOTING, PLANNED, SUSPENDED, DISCONTINUED | catalog conventions.capabilityStage (frozen) |
| CapacityBasis | NAMEPLATE, UTILIZED, NOT_REPORTED | catalog conventions.capacityBasis (frozen) |
| ProcessKind | CHEMICAL_SYNTHESIS, FERMENTATION, BIOCATALYSIS, CULTIVATION, EXTRACTION, PURIFICATION, BLENDING, DOSAGE_FORM_MANUFACTURING, PACKAGING, OTHER, UNKNOWN | W11 proposal (W11-SR-01); FERMENTATION/BIOCATALYSIS kept without a captured case because the live processClass strings and NMN/biologic routes need them (flagged) |

## Candidates (not in SDL)

| Candidate | Status | Closure criterion |
|---|---|---|
| ProcessMaterial (`["ProcessMaterial","IngredientMaterial"?]` or own label) | CANDIDATE, not proposed | a process input whose identity matters to a CQ and is neither chemically defined nor an ingredient material, with source and failing query |
| SpecificationKind, StepKind, ProcessIoRole enums | CANDIDATE (controlled strings now) | value list stable across two more real cases each |
| CLAIMS_THIRD_PARTY_CERTIFICATION predicate | CANDIDATE (W11-SR-09) | registered by W00/W01; failing case: NAI FY2025 10-K facility certification statement with no certifier listing captured |
| SPECIFICATION_EFFECTIVE_FROM predicate | CANDIDATE (W11-SR-09) | provenance for a version's announced effective date when no governing assertion exists (USP monograph) |
| RegulatoryInspection occurrence | W13 candidate (W11-SR-10) | "Not yet inspected" vs "6/10/2025, Form 483: Yes" rows in the FDA 503B list |
