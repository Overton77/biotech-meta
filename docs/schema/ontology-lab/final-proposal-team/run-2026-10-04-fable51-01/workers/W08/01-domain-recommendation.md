# W08 Platforms, instruments and devices: domain recommendation

Worker W08, run `run-2026-10-04-fable51-01`, model Opus 5.5 (`claude-opus-5-5`). Coordinator: Fable 5.1. Authority: catalog 0.2.0 (`8fb50ff0…84f0`), live schema (`86b5e0b5…f112`), frozen contract `01-shared-contract.md`.

## 1. Boundary

W08 owns **equipment and technology identity**: what a platform class is, what an instrument model is, what a device model is, which sensors and sensing modalities a device model has, and (candidate) which firmware builds a device model has run. W08 does **not** own:

| Neighbouring concept | Owner | Why it is not W08's |
|---|---|---|
| How a measurement was performed (lab + method + instrument + kit + software version + traceability) | W07 `AssayVersion` | A device model is one input to a procedure, not the procedure. |
| The method principle (HPLC, immunoassay, methylation array, PPG estimation) | W07 `MeasurementMethod` | Shared across instruments and platforms. |
| Algorithms that run in an app or cloud (sleep staging, Recovery, GrimAge) | W07 `Algorithm`/`AlgorithmVersion` | Their versions are not device firmware. |
| The commercial offering (price, listings, subscription, regulatory subject) | W04 `Product`, W15 commerce | The same hardware model can be several products (a Dx product and a research-mode use). |
| Clearance, De Novo grant, approval, enforcement discretion | W13 `RegulatoryStatus` `STATUS_OF` a Product | A 510(k) is a status of a submitted product (often software), never a property of hardware. |
| Manufacturer, developer, user organizations | W01 `Organization` | Reused by name; W08 only defines the edges to equipment. |
| Process steps that use equipment | W11 `ManufacturingStep` | W08 defines the `USES_EQUIPMENT`/`USES_PLATFORM` relationship types and their edge properties. |
| Public device-derived observations | W16 `Observation` (`FROM_DEVICE`) | A public result is a W16/W07 `DiagnosticResult`; a person's own device readings are private (`PersonalMeasurement`, provenanceKind `DEVICE_IMPORT`, W23 contract). |
| A person's own device unit, its serial number, pairing, ownership | private store (W23) | Never in the shared graph (contract A9, D-012). |

## 2. Subdomains and the identity/state/artifact/occurrence split

| Subdomain | Element (baseline name) | Archetype | Kind of thing | Example (sourced) |
|---|---|---|---|---|
| Technology platform class | `TechnologyPlatform` (live, seam) | Entity | identity of a technology family | "Illumina Infinium BeadChip array" (Illumina page: Technology "Microarray", product line Infinium) |
| Instrument / tool model | `ToolOrInstrument` (live, seam; range of W07 `RUNS_ON_INSTRUMENT`) | Entity | identity of an equipment model | "Illumina iScan System", "Illumina NextSeq 550 System", "Tosoh G8" |
| Device model | `Device` (live; = catalog `DeviceModel`) | Entity | identity of a consumer/clinical hardware model | "WHOOP 4.0", "WHOOP MG" |
| Sensor component kind | `Sensor` (live, seam) | Entity | identity of a component kind installed in device models | "WHOOP MG ECG electrodes" |
| Sensing / energy modality | `Modality` (live, seam) | Entity | identity of a physical principle | "photoplethysmography", "single-lead ECG" |
| Firmware build (candidate) | `FirmwareVersion` (catalog `consumer_devices` name; new in SDL as CANDIDATE) | VersionedState | fixed state of one component of one device model | WHOOP 4.0 core firmware "41.16.1.0", Bluetooth firmware "17.2.2.0" |
| Equipment usage and implementation facts | `DEVELOPS_PLATFORM`, `USES_PLATFORM`, `USES_EQUIPMENT`, `IMPLEMENTS_PLATFORM`, `USES_MODALITY`, `HAS_SENSOR`, `EMBODIES_MODEL`, `RUNS_ON_DEVICE` | asserted edges | statements by a source, bitemporal | "The kit is processed on the iScan or NextSeq 550 Systems" |
| Measurement occurrence | none in W08 | — | results are W07/W16 artifacts; device readings of people are private | — |

No W08 element is an Occurrence or an InformationArtifact. Release notes, accuracy figures, "medical grade" wording and "current version" markers are **Assertions** (W00 kernel) with locators, never node properties.

## 3. Disposition of every live and catalog element in scope

| Element | Origin | Disposition | Final element | Note |
|---|---|---|---|---|
| `TechnologyPlatform` | live 1377 | keep + refine | `TechnologyPlatform` `["TechnologyPlatform","Entity"]` | Meaning narrowed: platform class/technology family, not instrument, method or kit. `@fulltext TechnologyPlatformSearch` kept (D-015). `searchEmbedding` kept as a property, no `@vector` (D-014). |
| `TechnologyPlatform.platformClass` | live | keep | same | Display/filter text. |
| `ToolOrInstrument` | live 1392 | keep + refine | `ToolOrInstrument` | Instrument model. Gains `IMPLEMENTS_PLATFORM` (new domain) and read sides of `RUNS_ON_INSTRUMENT`, `USES_EQUIPMENT`, `EMBODIES_MODEL`. |
| `ToolOrInstrument.toolClass` | live | keep | same | Display text. |
| `Device` | live 1457 | keep (seam promoted) | `Device` = catalog `DeviceModel` | Model-level only; no regulatory or performance property; units private. |
| `Device.deviceClass`, `deviceFamily` | live | keep | same | Display text; never a regulatory classification. |
| `Device.usesModalities` (`USES_MODALITY`, UsageMetadata) | live | keep, class asserted | `USES_MODALITY` + `UsageEdgeProperties` | |
| `Device.hasSensors` (`HAS_SENSOR`, RoleMetadata) | live | keep, class asserted | `HAS_SENSOR` + `AssertedEdgeProperties` | RoleMetadata role fields were never meaningful here. |
| `Device.implementsPlatforms` (`IMPLEMENTS_PLATFORM`) | live | keep, class asserted | `IMPLEMENTS_PLATFORM` + `UsageEdgeProperties` | Domain widened to `ToolOrInstrument` and `Product`. |
| `Device.measuresMetrics` (`MEASURES_METRIC`, MeasurementMetadata) | live | keep, class asserted | W07's `MEASURES_METRIC` + W07's `MeasurementEdgeProperties` | Means "a source says the device reports this metric"; never MEASURED, never accuracy. |
| `Sensor` | live 1485 | keep (seam) | `Sensor` | Component kind. |
| `Sensor.measuresMetrics` (`MEASURES_METRIC`) | live | **retire** | none | A sensor emits a signal; metrics come from an AssayVersion/AlgorithmVersion. Migration: re-express as Device `MEASURES_METRIC` only where a source says so (V-W08-08). |
| `Sensor.sensorType` | live | keep | same | |
| `Modality` | live 1475 | keep (seam), meaning narrowed | `Modality` | Device capability descriptor; W07 `MeasurementMethod` is authoritative for what a procedure does. |
| `Modality.modalityClass`, `modalityFamily`, `parameterNames`, `parameterUnits` | live | keep | same | parameterUnits are UCUM, positional. |
| `UsageMetadata` | live 159 | replace | `UsageEdgeProperties` (asserted profile + `usageContext`, `isPrimary`, `notes`) | `confidence` dropped (contract A4). |
| `Organization.developsPlatforms` (`DEVELOPS_PLATFORM`, RoleMetadata) | live 557 | keep, class asserted | `DEVELOPS_PLATFORM` + `AssertedEdgeProperties` | W01 writes the OUT field (W08-SR-07); W08 writes the IN field. |
| `Organization.usesPlatforms` (`USES_PLATFORM`) | live 558 | keep, class asserted | `USES_PLATFORM` + `UsageEdgeProperties` | |
| `Organization.usesTools` (`USES` → ToolOrInstrument) | live 559 | **rename** | `USES_EQUIPMENT` | `USES` collides with W16 `ProtocolStep USES` (substances). |
| `ManufacturingStep.usesPlatforms` (`USES_PLATFORM`) | live 1524 | keep, class asserted | same type | W11 writes the OUT field (already does). |
| `ManufacturingStep.usesEquipment` (`USES_EQUIPMENT`) | live 1525 | keep, class asserted | same type | W11 writes the OUT field (already does). |
| `LabTest.usesPlatforms` (`USES_PLATFORM`, MeasurementMetadata) | live 1432 | **retire as stored edge** | path `LabTest-PERFORMED_WITH_ASSAY_VERSION->AssayVersion-RUNS_ON_INSTRUMENT->x-IMPLEMENTS_PLATFORM->TechnologyPlatform` | One relationship type cannot be asserted for organizations and a "current projection" for tests; the alignment row already made it a seam of AssayVersion (W07 owns the LabTest field). |
| `MeasurementMethod.runsOnPlatforms` (`RUNS_ON_PLATFORM`) | live 1443 | keep, class **structural** | `RUNS_ON_PLATFORM` + `StructuralEdgeProperties` | Accepted from W07's fragment; generic capability, never comparability. |
| `Product.implementsPlatforms` (`IMPLEMENTS`) | live 779 | **rename/merge** | `IMPLEMENTS_PLATFORM` | W04 already did this in its fragment. |
| `Product.classifiedAs` (`CLASSIFIED_AS` → union `ProductClassification`) | live 780, 688 | **replace** (W04 keeps legacy read-only fields) | `EMBODIES_MODEL` (asserted, Product → `EquipmentModelTarget`) | Answers W04-SR-08. "Classified as" would be read as a regulatory classification (510(k) "Device Classification Name"). |
| union `ProductClassification` | live 688 | **rename** | `EquipmentModelTarget = ToolOrInstrument \| Device` | Contract B6 naming; also the range requested for W07 `RUNS_ON_INSTRUMENT`. |
| `Observation.fromDevices` (`FROM_DEVICE`) | live 2007 | consumer (W16) | W16 structural field | W08 adds nothing; comparability needs `PRODUCED_BY_ASSAY_VERSION` (W07). |
| unions `StepInstrument`, `TreatmentComponent`, `StudyIntervention`, `ProtocolResultMention`, `EventParticipant`, `EventSubject`, `EvidenceSubject`, `ClaimSubject`, `AssociationParticipant`, `EpisodeMentionable`, `MediaSubject` | live | consumers | owners W16, W06, W09, W16, W18, W00, W21, W03, W21, W22 | W08 types remain valid members; `FirmwareVersion` must be added to W00 `AssertionSubjectTarget` if admitted (W08-SR-06). |
| catalog `DeviceModel` | catalog consumer_devices | **merge** into live `Device` | `Device` | Alignment: "Live Device is model-level". |
| catalog `FirmwareVersion` | catalog consumer_devices | **add as CANDIDATE** | `FirmwareVersion` (VersionedState) | CQ-DX-C01, failing cases F-1/F-2 (section 5). |
| catalog `DeviceObservation` | catalog consumer_devices | **defer / do not add** | W16 `Observation` (public) and private `PersonalMeasurement` | A third result type would recreate the round-0008 three-result-kinds problem (CL-008). |
| `AssayVersion.softwareVersion` as firmware (catalog note) | catalog diagnostics | keep | W07 field, materialized firmware label | Must equal `FirmwareVersion.versionLabel` when `RUNS_FIRMWARE_VERSION` exists (V-W08-05). |
| `RUNS_ON_INSTRUMENT` | catalog diagnostics | consumer, range widened (request) | `EquipmentModelTarget` | W08-SR-01. |
| `PERFORMED_WITH_ASSAY_VERSION` | catalog diagnostics | consumer, domain widened (request) | `LabTest \| Device` | W08-SR-01. |
| `MEASURES_METRIC` (Device domain) | live / W07 | consumer | W07 type and property type | W08-SR-02. |

## 4. Alternatives considered

| Question | Alternatives | Chosen | Evidence and failing case |
|---|---|---|---|
| Is a platform the same as an instrument? | (a) one type; (b) TechnologyPlatform + ToolOrInstrument | (b) | Illumina's EPIC v2.0 kit "is processed on the iScan or NextSeq 550 Systems": one platform, two instrument models with different instrument classes (array scanner, sequencer). One type cannot say "same platform, different instrument" (fixture 1, Q-W08-02). |
| Where does the kit go? | TechnologyPlatform, ToolOrInstrument, AssayVersion | W07 `AssayVersion.assayKitIdentifier` | Kit 20087706 is a consumable version used inside a procedure; EPIC v1.0 was discontinued and replaced by v2.0 on the same Infinium chemistry, i.e. the kit changes while the platform does not. |
| Device vs DeviceModel | (a) Device = unit + DeviceModel = model; (b) Device = model, units private | (b) | Units carry serial numbers and ownership: private (contract A9). Live Device is model-level (alignment). P-02 `PersonalMeasurement.deviceUid` already references `hu:device:` shared model uids. |
| Should Device and ToolOrInstrument merge? | (a) one `EquipmentModel` type; (b) Device as specialization of ToolOrInstrument; (c) two types + union | (c) | Therapeutic devices (photobiomodulation, PEMF; W06/W09 interventions) are devices that measure nothing, so (b) makes them instruments; (a) breaks live data and the specimen-based instrument semantics W07 relies on. The union keeps both as endpoints of `RUNS_ON_INSTRUMENT` and `EMBODIES_MODEL`. |
| Where does firmware live? | (a) `AssayVersion.softwareVersion` only (catalog seam); (b) `FirmwareVersion` node + materialized `softwareVersion`; (c) firmware as a property of Device | (b), as CANDIDATE | (c) collapses device identity with state. (a) fails F-1: WHOOP's note "Firmware version 41.16.1.0 – Improved heart rate estimation algorithm" and notes such as "Improvements to battery life" have the firmware release as subject; no AssayVersion is that subject. (a) fails F-2: WHOOP versions "core firmware" and "Bluetooth firmware" separately (41.13.2.0 with 17.2.2.0), and the K243236 summary says "The ECG Strap Module firmware is integrated within the WHOOP Strap's firmware". If Fable rejects the candidate, (a) remains workable for CQ-DX-09 alone. |
| Where does a 510(k) live for a wearable? | Device property; RegulatoryStatus `STATUS_OF` Device; `STATUS_OF` Product | `STATUS_OF` Product (W13) + `RUNS_ON_DEVICE` | K243236 clears "WHOOP ECG (electrocardiogram) Feature (1.0)", "a software-only mobile medical application integrated into the consumer (non-device) WHOOP System", compatible with "WHOOP Strap version – WHOOP MG". Attaching the clearance to WHOOP MG would assert something FDA did not clear (fixture 3, Q-W08-06). |
| Where do performance figures live? | Device/edge property (live `MeasurementMetadata.accuracy`); Assertion | Assertion asserted by the maker | The 96.2 % / 99.4 % figures are in the applicant-prepared 510(k) Summary, restricted to classifiable recordings with 11 % inconclusive; WHOOP's July 2026 page claims an "across-the-board improvement to heart rate accuracy" with no figure, no firmware version and no device model. A property would erase asserter, scope and the difference between a study result and marketing. |
| Device measures a metric: derived or asserted? | derived from AssayVersion; asserted | asserted (same class as W07 `LabTest MEASURES_METRIC`) | One relationship type has one class; W07 made `MEASURES_METRIC` asserted. The vendor statement "device reports HRV" exists before any AssayVersion is known. The measured semantics stay on AssayVersion (Q-W08-08 shows both). |

## 5. Smallest recommended model

```text
Organization -[DEVELOPS_PLATFORM | USES_PLATFORM]-> TechnologyPlatform          (asserted)
Organization | ManufacturingStep -[USES_EQUIPMENT]-> ToolOrInstrument             (asserted, UsageEdgeProperties)
Device | ToolOrInstrument | Product -[IMPLEMENTS_PLATFORM]-> TechnologyPlatform    (asserted, UsageEdgeProperties)
MeasurementMethod -[RUNS_ON_PLATFORM]-> TechnologyPlatform                         (structural)
Device -[USES_MODALITY]-> Modality ; Device -[HAS_SENSOR]-> Sensor                 (asserted)
Device -[MEASURES_METRIC]-> Metric                                                  (asserted, W07 type)
Product -[EMBODIES_MODEL]-> ToolOrInstrument | Device                              (asserted, candidate; replaces CLASSIFIED_AS)
Product -[RUNS_ON_DEVICE]-> Device                                                  (asserted, candidate)
AssayVersion -[RUNS_ON_INSTRUMENT]-> ToolOrInstrument | Device                     (structural, W07 type, range widened)
Device -[PERFORMED_WITH_ASSAY_VERSION {valid, recorded}]-> AssayVersion            (asserted, W07 type, domain widened)
FirmwareVersion -[FIRMWARE_VERSION_OF]-> Device                                     (structural, CANDIDATE)
AssayVersion -[RUNS_FIRMWARE_VERSION]-> FirmwareVersion                             (structural, CANDIDATE; softwareVersion = versionLabel)
RegulatoryStatus -[STATUS_OF]-> Product   (W13; never Device/ToolOrInstrument/Platform/Sensor/Modality/FirmwareVersion)
Assertion {REPORTS_SENSITIVITY | REPORTS_SPECIFICITY | REPORTS_ACCURACY | CLAIMS_ACCURACY_IMPROVEMENT | RELEASE_NOTE_STATES}
   -[HAS_SUBJECT]-> Product | AssayVersion | AlgorithmVersion | FirmwareVersion ; -[ASSERTED_BY]-> maker
```

Five live node types kept, one candidate node type, one renamed union, one relationship-property type, no new enum. Four candidate relationship types (`FIRMWARE_VERSION_OF`, `RUNS_FIRMWARE_VERSION`, `EMBODIES_MODEL`, `RUNS_ON_DEVICE`) each carry a CQ and a failing fixture.

## 6. Forbidden implications proposed for `consumer_devices`

| Pair | Prevented failure | Check |
|---|---|---|
| `[SAME_TECHNOLOGY_PLATFORM, COMPARABLE_ASSAY_VERSION]` | EPIC v2.0 on iScan and on NextSeq 550 merged into one trend | Q-W08-02, V-302 (W07) |
| `[SAME_DEVICE_MODEL, SAME_ASSAY_VERSION]` | WHOOP 4.0 HR before/after firmware 41.16.1.0 shown as one series | Q-W08-05, V-302 |
| `[DEVICE_MEASURES_METRIC, MEASURED_RESULT]` | a wearable "measures" sleep stages read as measured | Q-W08-08, V-303 (W07) |
| `[MANUFACTURER_PERFORMANCE_CLAIM, VALIDATED_PERFORMANCE]` | applicant sensitivity or marketing "accuracy" shown as validated | V-W08-11, V-W08-02 |
| `[COMPATIBLE_SOFTWARE_CLEARED, DEVICE_CLEARED]` | "WHOOP MG is FDA cleared" | Q-W08-06, V-W08-03 |
| `[CLEARED_510K, FDA_APPROVED]` (existing) | "WHOOP ECG is FDA approved" | V-320a, V-336 (negative N4) |
| `[ENFORCEMENT_DISCRETION, AUTHORIZATION]` (existing) | BPI closeout read as authorization | fixture 3 status kind; W13 validators |
| `[FIRMWARE_RELEASE_NOTED, FIRMWARE_DEPLOYED_TO_ALL_UNITS]` | release note read as everyone running it (WHOOP: "It may take 1-2 weeks before all of our members receive the update") | `PERFORMED_WITH_ASSAY_VERSION` validFrom stays UNKNOWN unless stated (Q-W08-09) |
| `[USES_PLATFORM \| USES_EQUIPMENT, OPERATING_CAPABILITY]` | "lab uses iScan" read as an operating capability | Q-W08-10, V-324 (W11) |
| `[DEVELOPS_PLATFORM, OWNS_PLATFORM_IP]` | developer read as patent owner | documentation; W14 owns patents |
