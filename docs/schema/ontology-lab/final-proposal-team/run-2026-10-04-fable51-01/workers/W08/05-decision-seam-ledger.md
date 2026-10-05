# W08 decision and seam ledger

Status values: **ACCEPTED-FOR-PROPOSAL** (W08 recommends; in the fragment), **CANDIDATE** (in the fragment as CANDIDATE, needs Fable's admission), **UNRESOLVED** (needs another owner), **ALIGNED** (adopted from another worker's fragment). Nothing here is presented as consensus with other workers unless their fragment shows it.

## Decisions

| Id | Decision | Alternatives (evidence) | Status | Closure criterion |
|---|---|---|---|---|
| D-W08-01 | Live `Device` is the device MODEL (catalog `DeviceModel` merged into it); units stay private. | separate Device(unit)+DeviceModel: rejected, units carry serials/ownership (contract A9); P-02 already uses `hu:device:` model uids (S11). | ACCEPTED-FOR-PROPOSAL | Fable records the alias in the catalog. |
| D-W08-02 | Four distinct records: TechnologyPlatform (class) / ToolOrInstrument (instrument model) / MeasurementMethod (W07 principle) / kit on AssayVersion (W07). | one "platform" type: fails the EPIC v2.0 case (S5: same kit and platform, iScan vs NextSeq 550). | ACCEPTED-FOR-PROPOSAL | Q-W08-01/02 rows as documented. |
| D-W08-03 | Device and ToolOrInstrument stay separate; union `EquipmentModelTarget` (rename of live `ProductClassification`) where either is a legal endpoint. | merge; Device as ToolOrInstrument specialization: rejected (therapeutic devices measure nothing; W07 specimen semantics). | ACCEPTED-FOR-PROPOSAL | Registry entry (W08-SR-08). |
| D-W08-04 | A regulatory status never attaches to an equipment, platform, sensor, modality or firmware node; device-related statuses attach to a W04 Product; `RUNS_ON_DEVICE` (candidate) reaches them from the device. | status on Device (live temptation): rejected by K243236 (S3, S4: cleared object is software; strap system "consumer (non-device)"). | ACCEPTED-FOR-PROPOSAL (V-W08-03); `RUNS_ON_DEVICE` CANDIDATE | W13 confirms subject set (already excludes Device); W04 adds the OUT field. |
| D-W08-05 | Performance figures and accuracy claims are Assertions asserted by their maker about a Product/AssayVersion/AlgorithmVersion, never properties. | edge/node property (live `MeasurementMetadata.accuracy`): rejected; S4 figures are applicant statements scoped to classifiable recordings; S2 claim has no figure. | ACCEPTED-FOR-PROPOSAL (V-W08-02, V-W08-11) | W00 registers the predicates; W21 allows QUALIFIED_BY (W08-SR-10). |
| D-W08-06 | `FirmwareVersion` (VersionedState) admitted as CANDIDATE with `FIRMWARE_VERSION_OF` and `RUNS_FIRMWARE_VERSION`; `AssayVersion.softwareVersion` remains the materialized, identity-defining label. | softwareVersion only (catalog seam): fails F-1 (release-note subject) and F-2 (core vs Bluetooth; embedded cleared ECG module) (S1, S4). | CANDIDATE | Fable admits or rejects; on rejection remove the type and two edges, keep V-W08-01..04, 08..11. |
| D-W08-07 | `RUNS_ON_PLATFORM` is structural. | asserted (W08's first draft): W07's fragment already declares it structural with StructuralEdgeProperties; one class per type; low-stakes reference link. | ALIGNED (with W07) | none. |
| D-W08-08 | Device `MEASURES_METRIC` is asserted with W07's `MeasurementEdgeProperties`; Sensor `MEASURES_METRIC` retired. | derived from AssayVersion: rejected (one type, one class; W07 made LabTest `MEASURES_METRIC` asserted). W07's description still lists Sensor. | ACCEPTED-FOR-PROPOSAL; Sensor removal UNRESOLVED with W07 | W07 updates its description (W08-SR-02). |
| D-W08-09 | `USES_PLATFORM`, `USES_EQUIPMENT` asserted for Organization and ManufacturingStep; live Organization `USES` renamed `USES_EQUIPMENT`; live LabTest `USES_PLATFORM` retired as a stored edge. | keep LabTest edge as projection: rejected (mixed class on one type). | ACCEPTED-FOR-PROPOSAL; W11 ALIGNED (its fragment uses both with UsageEdgeProperties); W01 UNRESOLVED (no fields yet) | W01 adds fields (W08-SR-07); W07 drops LabTest.usesPlatforms. |
| D-W08-10 | `UsageEdgeProperties` = AssertedEdgeProperties + usageContext, isPrimary, notes; confidence dropped. | carry UsageMetadata as-is: forbidden by contract B4. | ACCEPTED-FOR-PROPOSAL; already consumed by W04 and W11 fragments | none. |
| D-W08-11 | No new enum; class fields stay strings; FirmwareVersion reuses W07 `AlgorithmVersionBasis`. | new DeviceClass enum: no CQ filters on it; values uncontrolled. | ACCEPTED-FOR-PROPOSAL | none. |
| D-W08-12 | uid tokens requested: device, technology-platform, sensor, modality, firmware-version. | `platform` for TechnologyPlatform: rejected (W21 media Platform). | UNRESOLVED (W00) | W08-SR-06. |
| D-W08-13 | Catalog `DeviceObservation` not adopted. | a third result type: rejected (CL-008 already split public Observation / private PersonalMeasurement / DiagnosticResult contract). | ACCEPTED-FOR-PROPOSAL | Fable updates catalog consumer_devices.owns. |
| D-W08-14 | Device-run measurement procedures are W07 AssayVersions (`RUNS_ON_INSTRUMENT` → Device, `PERFORMED_WITH_ASSAY_VERSION` from Device, operator = device maker). | DeviceObservation-specific procedure type: rejected (duplicate of AssayVersion). | UNRESOLVED (W07) | W08-SR-01. |
| D-W08-15 | `CLASSIFIED_AS` successor is `EMBODIES_MODEL` (Product → EquipmentModelTarget, asserted, candidate). | keep `CLASSIFIED_AS` name: rejected (reads as regulatory classification). | CANDIDATE; W04 already made CLASSIFIED_AS read-only and asked W08 (W04-SR-08) | W04 adds the field (W08-SR-03). |
| D-W08-16 | An instrument's operating mode (Dx vs Research Mode) is AssayVersion configuration, not a second instrument identity. | two ToolOrInstrument nodes per mode: rejected (same hardware model; S5). | UNRESOLVED (W07, optional) | W08-SR-12. |
| D-W08-17 | Forbidden implications for consumer_devices: `[SAME_TECHNOLOGY_PLATFORM, COMPARABLE_ASSAY_VERSION]`, `[SAME_DEVICE_MODEL, SAME_ASSAY_VERSION]`, `[DEVICE_MEASURES_METRIC, MEASURED_RESULT]`, `[MANUFACTURER_PERFORMANCE_CLAIM, VALIDATED_PERFORMANCE]`, `[COMPATIBLE_SOFTWARE_CLEARED, DEVICE_CLEARED]`, `[FIRMWARE_RELEASE_NOTED, FIRMWARE_DEPLOYED_TO_ALL_UNITS]`, `[USES_PLATFORM, OPERATING_CAPABILITY]`, `[USES_EQUIPMENT, OPERATING_CAPABILITY]`, `[DEVELOPS_PLATFORM, OWNS_PLATFORM_IP]`. | — | ACCEPTED-FOR-PROPOSAL | each has a query or validator (01 section 6). |

## Kernel-change requests

None. W08 needs only registrations (uid tokens, predicates, union membership), which are W00 seam requests (W08-SR-06), not kernel changes. The one-literal rule (V-003) was respected by moving qualifier text to `description`; structured qualifiers are requested from W21, not by changing the kernel.

## Observations about other fragments (no edit made; for Fable)

- W07 `MeasurementEdgeProperties` description names "LabTest, Device, Sensor -> Metric"; W08 retires the Sensor domain (W08-SR-02).
- W07 `AssayVersion.runsOnInstrument` is typed `[ToolOrInstrument!]!`; device-run assay versions need `[EquipmentModelTarget!]!` (W08-SR-01). Until then, a device-run AssayVersion's `RUNS_ON_INSTRUMENT` edge exists in Cypher but is invisible through W07's GraphQL field (it is visible through W08's `Device.usedByAssayVersions`).
- W01's Organization has no `DEVELOPS_PLATFORM` / `USES_PLATFORM` / `USES_EQUIPMENT` fields (W08-SR-07).
- W00 `AssertionSubjectTarget` lists W08's five live types but not `FirmwareVersion` (W08-SR-06).
- W13 `RegulatorySubjectTarget` already excludes W08 types; consistent with D-W08-04.
- W04 already renamed live `IMPLEMENTS` to `IMPLEMENTS_PLATFORM` with `UsageEdgeProperties` and made `CLASSIFIED_AS` read-only pending W08 (W04-SR-08); consistent with D-W08-15.
- W16 `StepInstrumentTarget` includes Device, ToolOrInstrument and AssayVersion; consistent.
- W09 uses `USES_INTERVENTION_DEVICE` StudyIntervention → Device (W09's relationship); consistent with model-level Device.

## Open items (not blocking)

1. Whether a firmware build that carries a cleared software module (ECG Strap Module inside strap firmware) should link to the cleared Product. No source names which strap firmware versions contain ECG Feature 1.0, so no edge is proposed; the question is recorded for a consumer_devices round.
2. Oura (sleep staging OSSA 2.0, a cloud/app algorithm) was not captured; it would exercise W07 AlgorithmVersion rather than FirmwareVersion and does not change the W08 model.
3. Whether WHOOP 5.0 / MG firmware notes exist publicly was not checked; WHOOP 4.0 was sufficient for the failing cases.
