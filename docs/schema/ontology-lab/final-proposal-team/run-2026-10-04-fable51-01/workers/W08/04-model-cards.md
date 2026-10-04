# W08 model cards

Conventions: privacy class of every W08 node and edge is `PUBLIC` (stored enum name, as W23 D-W23-06) unless stated; "kind" is asserted / observed / calculated / inferred / operational; nullable fields mean unknown or not applicable (catalog `nullMeans`), never false or "ongoing". Kernel fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) follow contract B2 and are not repeated per card. uid tokens marked "requested" are pending W00 registration (W08-SR-06).

## Node types

### TechnologyPlatform
- **Meaning**: a technology family or platform class that products, instrument models, device models and method principles implement or run on. Example: "Illumina Infinium BeadChip array" (S5). Counterexamples: "Illumina iScan System" (ToolOrInstrument), "methylation array" (W07 MeasurementMethod), kit 20087706 (W07 AssayVersion.assayKitIdentifier).
- **Archetype / labels**: Entity; `["TechnologyPlatform","Entity"]`; implements `Entity & EntityArchetype & SearchIndexable`.
- **uid token**: `technology-platform` (requested; `platform` avoided because W21's media `Platform` is a different identity).
- **Properties**: `entityType: String!` ('TECHNOLOGY_PLATFORM'; operational). `platformClass: String` (display/filter text, asserted by curation; not identity, not an enum). `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` (operational, live compatibility; no `@vector`).
- **Edges**: IN `DEVELOPS_PLATFORM` (Organization), IN `USES_PLATFORM` (Organization, ManufacturingStep), IN `IMPLEMENTS_PLATFORM` (Device, ToolOrInstrument, Product), IN `RUNS_ON_PLATFORM` (MeasurementMethod).
- **Identity keys**: uid; resolution by developer organization + platform name as the developer uses it, via `Identifier`/`Mention`; vendor-neutral classes (e.g. "DNA methylation microarray") are separate nodes, related only by assertion if needed.
- **Temporal**: identity is timeless; all facts about it are bitemporal asserted edges.
- **Maturity**: PROVISIONAL. **Module**: consumer_devices (future) seam / live seam type. **Sources**: S5.

### ToolOrInstrument
- **Meaning**: an instrument or tool model (analyzer, scanner, sequencer, process equipment model). Examples: "Illumina iScan System", "Illumina NextSeq 550 System", "Tosoh G8" (inherited fixture). Not a unit, not an assay configuration, not the commercial product, not a regulatory status.
- **Archetype / labels**: Entity; `["ToolOrInstrument","Entity"]`. **uid token**: `instrument` (registered).
- **Properties**: `entityType: String!` ('TOOL_OR_INSTRUMENT'), `toolClass: String` (display).
- **Edges**: OUT `IMPLEMENTS_PLATFORM` (asserted, many, UsageEdgeProperties); IN `RUNS_ON_INSTRUMENT` (W07, structural, zero_or_one per AssayVersion, StructuralEdgeProperties); IN `USES_EQUIPMENT` (asserted); IN `EMBODIES_MODEL` (asserted, candidate).
- **Identity keys**: uid; `Identifier` (scheme e.g. `VENDOR_CATALOG_NUMBER`, `GUDID_DI`) with issuer; a model name shared by two vendors never merges.
- **Operating mode**: "NextSeq 550Dx in Research Mode" (S5) is the same hardware model used in a mode; the mode is AssayVersion configuration (W08-SR-12), the Dx regulatory status is on a W04 Product.
- **Maturity**: PROVISIONAL. **Sources**: S5, S10.

### Device
- **Meaning**: a consumer or clinical hardware model (catalog `DeviceModel`). Examples: "WHOOP 4.0" (S1), "WHOOP MG" (S4). Hardware generations or SKUs with different sensors are separate Device nodes; firmware releases are not.
- **Archetype / labels**: Entity; `["Device","Entity"]`. **uid token**: `device` (requested; already used by property card P-02).
- **Properties**: `entityType: String!` ('DEVICE'); `deviceClass: String` (display; never a regulatory class or product code); `deviceFamily: String` (grouping text; never identity).
- **Forbidden properties** (V-W08-02, V-W08-09): any regulatory status or number, product code, PCCP flag, accuracy/sensitivity/specificity, "medical grade", serial number, owner/user reference.
- **Edges**: OUT `USES_MODALITY` (asserted), OUT `HAS_SENSOR` (asserted), OUT `IMPLEMENTS_PLATFORM` (asserted), OUT `MEASURES_METRIC` (W07 type, asserted, MeasurementEdgeProperties), OUT `PERFORMED_WITH_ASSAY_VERSION` (W07 type, asserted, asserted_edge profile; domain widening requested); IN `RUNS_ON_INSTRUMENT` (structural; range widening requested), IN `FIRMWARE_VERSION_OF` (structural, candidate), IN `EMBODIES_MODEL` (asserted, candidate), IN `RUNS_ON_DEVICE` (asserted, candidate).
- **Privacy**: model-level PUBLIC. A person's unit is a private-store record that may reference `Device.uid`; no edge from the shared graph to it (V-113, V-W08-09).
- **Maturity**: PROVISIONAL. **Module**: consumer_devices. **Sources**: S1-S4, S11.

### Sensor
- **Meaning**: a sensor component kind as installed in device models ("WHOOP MG ECG electrodes"). Emits a signal; does not measure a Metric on its own.
- **Archetype / labels**: Entity; `["Sensor","Entity"]`. **uid token**: `sensor` (requested).
- **Properties**: `entityType: String!` ('SENSOR'); `sensorType: String` (display).
- **Edges**: IN `HAS_SENSOR` (asserted). Live OUT `MEASURES_METRIC` retired (V-W08-08).
- **Maturity**: PROVISIONAL (seam; no Essential CQ needs it beyond device composition). **Sources**: S4.

### Modality
- **Meaning**: the physical sensing or energy-delivery principle a device model uses (PPG, single-lead ECG, photobiomodulation). Device-side descriptor; W07 `MeasurementMethod` is authoritative for procedures.
- **Archetype / labels**: Entity; `["Modality","Entity"]`. **uid token**: `modality` (requested).
- **Properties**: `entityType: String!` ('MODALITY'); `modalityClass`, `modalityFamily` (display); `parameterNames: [String!]`, `parameterUnits: [String!]` (parallel lists; units UCUM; a null/missing position = unit not stated).
- **Edges**: IN `USES_MODALITY` (asserted).
- **Maturity**: PROVISIONAL. **Sources**: S2, S4.

### FirmwareVersion (CANDIDATE)
- **Meaning**: one released firmware build of one component of one device model, as the vendor labels it (WHOOP 4.0 core firmware "41.16.1.0"; Bluetooth firmware "17.2.2.0").
- **Archetype / labels**: VersionedState; `["FirmwareVersion","VersionedState"]`; implements `Entity & VersionedStateArchetype`. **uid token**: `firmware-version` (requested).
- **Properties**: `stateType: String!` ('FIRMWARE_VERSION'); `payloadHash: String!` (sha256 over device uid, componentLabel, versionLabel joined by U+001F after NFC-WS1; calculated); `effectiveFrom`, `effectiveTo: DateTime` (source-stated release/withdrawal bounds only; null = not stated); `versionLabel: String!` (verbatim vendor string; not parsed, not ordered); `versionBasis: AlgorithmVersionBasis` (W07 enum; VENDOR_VERSION_STRING / UNKNOWN); `componentLabel: String` (verbatim component name).
- **Edges**: OUT `FIRMWARE_VERSION_OF` → Device (structural, exactly_one; V-W08-06); IN `RUNS_FIRMWARE_VERSION` ← AssayVersion (structural, zero_or_one per AssayVersion; V-W08-05/06).
- **Assertions about it**: `RELEASE_NOTE_STATES` (literal valueString, asserted by the vendor), "current version" markers, release dates; each with a locator. A correction is `SUPERSEDES {EXTRACTION_FIX}` (fixture 2).
- **Identity**: device uid + componentLabel + versionLabel; two devices never share a FirmwareVersion even with the same label.
- **Failing cases**: F-1 release-note subject; F-2 component split and embedded cleared module (01-domain-recommendation.md section 4). **CQ**: CQ-DX-C01, CQ-DX-09.
- **Fallback if not admitted**: `AssayVersion.softwareVersion` alone (catalog seam); release notes become Assertions on Device with literal valueString; V-W08-05/06/07 dropped.

## Union

### EquipmentModelTarget = ToolOrInstrument | Device
- Rename of live `ProductClassification`. Range of `EMBODIES_MODEL` (W04 field) and, on W08-SR-01, of W07 `RUNS_ON_INSTRUMENT`. Members are model-level only. Round-trip verified (`checks/results/graphql-roundtrip.json`, `unionTarget`).

## Relationship-property type

### UsageEdgeProperties
- Every field of W00 `AssertedEdgeProperties` (`relationshipUid!`, `assertionUid!`, `validFrom`, `validTo`, `validFromPrecision`, `validToPrecision`, `validFromBasis!`, `validToBasis!`, `recordedFrom!`, `recordedTo`, `mongoResearchRunId`) plus `usageContext: String` (verbatim; display/filter), `isPrimary: Boolean` (true only when the source names it primary; null = not stated), `notes: String`.
- Used by `USES_PLATFORM`, `USES_EQUIPMENT`, `IMPLEMENTS_PLATFORM`, `USES_MODALITY` (also by W04 `Product.implementsPlatforms` and W11 `ManufacturingStep.usesEquipment/usesPlatforms`).
- Temporal: asserted_edge profile; immutable after commit except one write of `recordedTo`.
- Replaces live `UsageMetadata`; `confidence` not carried.

## Relationship types (owned)

| Type | Domain → range | Class | Cardinality | Edge properties | Meaning / forbidden implication | CQ | Maturity |
|---|---|---|---|---|---|---|---|
| `DEVELOPS_PLATFORM` | Organization → TechnologyPlatform | asserted | many | AssertedEdgeProperties | a source says the organization develops the platform; ≠ IP ownership, ≠ manufacturing | CQ-DX-C03, CQ-EC (W01) | PROVISIONAL |
| `USES_PLATFORM` | Organization \| ManufacturingStep → TechnologyPlatform | asserted | many | UsageEdgeProperties | ≠ operating capability | CQ-MF-04 | PROVISIONAL |
| `USES_EQUIPMENT` | Organization \| ManufacturingStep → ToolOrInstrument | asserted | many | UsageEdgeProperties | renames live Organization `USES`; ≠ operating capability | CQ-MF-04 | PROVISIONAL |
| `IMPLEMENTS_PLATFORM` | Device \| ToolOrInstrument \| Product → TechnologyPlatform | asserted | many | UsageEdgeProperties | realizes or supports the platform; ≠ comparability | CQ-DX-01, CQ-DX-C03 | PROVISIONAL |
| `RUNS_ON_PLATFORM` | MeasurementMethod → TechnologyPlatform | structural | many | StructuralEdgeProperties | generic capability of a method principle; never used for comparability (class accepted from W07) | CQ-DX-01 | PROVISIONAL |
| `USES_MODALITY` | Device → Modality | asserted | many | UsageEdgeProperties | device capability descriptor | CQ-DX-01 | PROVISIONAL |
| `HAS_SENSOR` | Device → Sensor | asserted | many | AssertedEdgeProperties | hardware composition statement | CQ-DX-01 | PROVISIONAL |
| `EMBODIES_MODEL` | Product → EquipmentModelTarget | asserted | many | AssertedEdgeProperties | the commercial product's units are of this model; replaces `CLASSIFIED_AS`; never a regulatory classification | CQ-DX-C02 | CANDIDATE |
| `RUNS_ON_DEVICE` | Product → Device | asserted | many | AssertedEdgeProperties | a software product runs on the device model; its regulatory status is the product's | CQ-DX-C02, CQ-MF-02 | CANDIDATE |
| `FIRMWARE_VERSION_OF` | FirmwareVersion → Device | structural | exactly_one | StructuralEdgeProperties | defines which device the build belongs to | CQ-DX-C01 | CANDIDATE |
| `RUNS_FIRMWARE_VERSION` | AssayVersion → FirmwareVersion | structural | zero_or_one | StructuralEdgeProperties | payload edge of the AssayVersion state (W07 writes OUT) | CQ-DX-09 | CANDIDATE |

## Relationship types used (owned elsewhere)

| Type | Owner | W08 use | Request |
|---|---|---|---|
| `RUNS_ON_INSTRUMENT` | W07 | IN fields on ToolOrInstrument and Device | range `EquipmentModelTarget` (W08-SR-01) |
| `PERFORMED_WITH_ASSAY_VERSION` | W07 | OUT field on Device (AssertedEdgeProperties, as W07) | domain `LabTest \| Device` (W08-SR-01) |
| `MEASURES_METRIC` | W07 | OUT field on Device (MeasurementEdgeProperties, as W07) | confirm Device domain; drop Sensor (W08-SR-02) |
| `STATUS_OF` | W13 | never targets W08 types | V-W08-03 (W08-SR-09) |
| `FROM_DEVICE` | W16 | none | W08-SR-11 |

## Derived inputs and rules

- No W08 edge is derived. The live `LabTest USES_PLATFORM` "current platform" view is a query path (`LabTest -PERFORMED_WITH_ASSAY_VERSION {recordedTo IS NULL, valid at T}-> AssayVersion -RUNS_ON_INSTRUMENT-> x -IMPLEMENTS_PLATFORM-> TechnologyPlatform`), not a stored edge; if Fable wants a stored projection, it is a derived edge `CURRENT_PLATFORM` with `derivationRule: 'LABTEST_PLATFORM_VIA_ASSAY_VERSION'` and `derivedFromAssertionUids` = the PERFORMED_WITH and IMPLEMENTS_PLATFORM assertions (not proposed here).

## Enums

W08 owns no enum. Class texts (`platformClass`, `toolClass`, `deviceClass`, `sensorType`, `modalityClass`) stay strings because no CQ filters on a closed list and the live values are uncontrolled. `FirmwareVersion.versionBasis` reuses W07's `AlgorithmVersionBasis`.

## Candidate Assertion predicates (W00 registration requested)

| Predicate | Subject | Object / literal | predicateClass | Typical assertionBasis |
|---|---|---|---|---|
| `RELEASE_NOTE_STATES` | FirmwareVersion | valueString (verbatim note) | CLAIM | MANUFACTURER_CLAIM |
| `REPORTS_SENSITIVITY`, `REPORTS_SPECIFICITY`, `REPORTS_INCONCLUSIVE_RATE`, `REPORTS_ACCURACY` | Product \| ProductVariant \| AssayVersion \| AlgorithmVersion | valueNumber + unitCode | QUANTITY | STUDY_RESULT or MANUFACTURER_CLAIM |
| `CLAIMS_ACCURACY_IMPROVEMENT` | as above | valueString | CLAIM | MANUFACTURER_CLAIM |
| the eight asserted relationship types above | as the edge | object | OTHER | per source |

Qualifier text (population, heart-rate range, "classifiable recordings only") belongs on `QUALIFIED_BY` (W21 QualificationProperties) once W21 allows it on generic Assertions (W08-SR-10); the fixtures hold it in `Assertion.description` as an interim because V-003 allows one literal only.
