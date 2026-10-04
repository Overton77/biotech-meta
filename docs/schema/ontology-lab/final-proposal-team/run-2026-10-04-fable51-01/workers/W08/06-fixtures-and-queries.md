# W08 fixtures and queries

All files are in `fixtures/` and were **run** on an embedded Neo4j **5.26.31 Community** instance (in-process harness `validation/harness/EmbeddedNeo4j.java`, fresh store, cleared by `checks/run-all.sh`), using the run's `run-cypher.mjs` (each statement in its own transaction; no variable crosses `;`). Raw outputs: `checks/results/*.json`. The fixtures are generated deterministically by `checks/gen_fixtures.py`; regenerate rather than hand-edit.

| File | Content | Statements | Result |
|---|---|---|---|
| `w08-platform-vs-instrument.cypher` | Illumina Infinium platform vs iScan / NextSeq 550 instrument models; same kit 20087706 on two instruments (synthetic Lab C); EMBODIES_MODEL; RUNS_ON_PLATFORM | 67 | run, 67 ok |
| `w08-device-firmware-assay.cypher` | WHOOP 4.0: one Device, four FirmwareVersions (3 core, 1 Bluetooth), two HR AssayVersions differing only in softwareVersion, release-note assertions, extraction correction, unversioned July 2026 accuracy claim | 96 | run, 96 ok |
| `w08-clearance-and-performance-claim.cypher` | K243236 clearance of the software Product "WHOOP ECG (electrocardiogram) Feature" RUNS_ON_DEVICE WHOOP MG; applicant performance assertions; BPI enforcement-discretion closeout | 84 | run, 84 ok |
| `w08-negatives.cypher` | N1-N11 negative cases (load after the three positives) | 23 | run, 23 ok |
| `w08-validation.cypher` | V-W08-01 … V-W08-11 | 11 | run |
| `w08-queries.cypher` | Q-W08-01 … Q-W08-10 | 10 | run |

Node labels: every node carries its primary label and its archetype label (`Device:Entity`, `FirmwareVersion:VersionedState`, `SourceLocator:InformationArtifact`, `Assertion`). uids use the registered tokens where they exist (`org`, `product`, `instrument`, `assay-version`, `metric`, `method`, `source`, `snapshot`, `locator`, `assertion`, `rel`, `reg-*`, `agent`) and the **requested** tokens `device`, `technology-platform`, `sensor`, `modality`, `firmware-version` (W08-SR-06; INV-106 flags them until registered). Snapshots of real pages use `contentHashBasis: 'STORED_EXCERPT_TEXT'` over the excerpt files in `fixtures/excerpts/` (`captureCompleteness` PARTIAL_EXCERPT, COMPLETE for the 510(k) record table); the synthetic Lab C page uses `SYNTHETIC_FIXTURE`. Assertions are `status: 'EXTRACTED'` (no capture-fidelity adjudication is claimed), each with an NFC-WS1 quote-hashed locator.

## Mandatory cases (brief) → where they are

| Mandatory case | Fixture | Expected and observed |
|---|---|---|
| Device identity vs assay configuration vs firmware version: same device, two firmware versions, one `AssayVersion.softwareVersion` change | fixture 2 | Q-W08-03: 2 rows (41.15.3.0, 41.16.1.0), same Device, different AssayVersion; Q-W08-05: `sameDevice=true, sameAssayVersion=false, trendDecision=SEPARATE_SERIES`. **Observed as expected.** |
| Device performance claim as a manufacturer assertion, not a Device property | fixture 3 (+ July 2026 claim in fixture 2) | Q-W08-07: 3 rows, `assertedBy='WHOOP, Inc.'`, `basis='STUDY_RESULT'`, `sourceKind='REGULATORY_RECORD'`, `pdfPage=9`; V-W08-02 zero rows on positives; negative N2 caught. **Observed.** |
| 510(k) clearance that must not read as approval | fixture 3 + N3, N4 | Q-W08-06: `statusKind='CLEARANCE'`, `isApproval=false`, `productCode='QDA'`, `pcccAuthorized=false`, `submission='K243236'`, `response='SUBSTANTIALLY_EQUIVALENT'`, `validFrom=2025-04-04`, `recordedFrom=2026-10-04T02:00Z`, `statusesOnDeviceItself=0`. N4 → V-320a, V-336, V-333; N3 → V-W08-03. **Observed.** |
| Platform class vs instrument model minimal pair | fixture 1 + N1 | Q-W08-01: 2 rows, instrumentKind `ToolOrInstrument`, models iScan / NextSeq 550, both platform `Illumina Infinium BeadChip array`; Q-W08-02: `sameKit=true, samePlatform=true, sameInstrument=false, comparabilityVerdict=null, trendDecision=SEPARATE_SERIES`; N1 → V-W08-01. **Observed.** |
| Temporal correction / late arrival | fixture 2 (SUPERSEDES EXTRACTION_FIX), fixture 3 (valid 2025-04-04, recorded 2026-10-04) | Q-W08-04 excludes the superseded misattribution (41.16.1.0 shows only "Improved heart rate estimation algorithm"; 41.11.7.0 carries the sleep note); baseline V-109 zero rows. **Observed.** |
| Identity collision | N10 | V-W08-10 (informational): 1 row `Device / 'whoop' / [w08-neg-whoop-name-a, w08-neg-whoop-name-b]`; no merge. **Observed.** |
| Missing facts | fixture 2 | Q-W08-09: WHOOP 4.0 `firmwareVersions=4, firmwareWithReleaseDate=0, assayEpisodesWithUnknownStart=2`; July 2026 claim on an AssayVersion with `softwareVersionStatus='NOT_REPORTED'`. **Observed.** |
| Access leakage | N8 | baseline V-113: 1 row (`Device whoop-4-0 -HAS_UNIT-> hu:private-device-unit:…`); V-W08-09: 2 rows (whoop-4-0 linked to a private record; a Device with `serialNumber`). **Observed.** |

## Validators: expected vs observed

| Id | Rule | Positive fixtures (expected = observed) | With negatives (expected = observed) |
|---|---|---|---|
| V-W08-01 | RUNS_ON_INSTRUMENT target is ToolOrInstrument or Device | 0 | 1: N1 `w08-neg-platform-as-instrument → TechnologyPlatform` |
| V-W08-02 | no regulatory/performance property on W08 nodes | 0 | 1: N2 keys `clearanceNumber, accuracyPercent, fdaCleared, medicalGrade` |
| V-W08-03 | no status/submission/designation/approval attached to W08 nodes | 0 | 1: N3 `STATUS_OF → hu:device:whoop-mg` |
| V-W08-04 | asserted W08 edges are projections of one matching Assertion | 0 | 1: N7 `USES_PLATFORM whoop-inc → infinium` `NO_ASSERTION_UID` |
| V-W08-05 | softwareVersion = declared FirmwareVersion label, same device | 0 | 1: N5 `41.16.2.0` vs `41.16.1.0` |
| V-W08-06 | one FIRMWARE_VERSION_OF; ≤1 RUNS_FIRMWARE_VERSION | 0 | 1: N6 `w08-neg-two-devices`, n=2 |
| V-W08-07 | (informational) undeclared matching firmware | 0 | 0 |
| V-W08-08 | retired live edges (Sensor MEASURES_METRIC, LabTest USES_PLATFORM, Organization USES, IMPLEMENTS, CLASSIFIED_AS) | 0 | 1: N9 `Sensor MEASURES_METRIC` |
| V-W08-09 | model-level, no unit identifiers, no private link | 0 | 2: N8 (whoop-4-0 ↔ private unit; device with serialNumber) |
| V-W08-10 | (informational) name shared by equipment uids | 0 | 1: N10 |
| V-W08-11 | performance-claim subject/asserter/basis | 0 | 1: N11 `REPORTS_ACCURACY` on Device, no asserter |

## Baseline 0.2.0 suite (`docs/schema/neo4j/validation.cypher`, 174 statements, run with `validation/validation-params.json`)

- **Positive fixtures only**: zero failing rows. Informational rows only: V-118 (uid backfill counts, all `missingUid: 0`), V-401b (`0`), V-514b (`0`).
- First pass (before fixing) found three real issues in the W08 fixtures, all fixed in the generator: V-003 (an assertion with an object plus a valueString note; performance assertions with valueNumber plus valueString), V-210 (basisKind DIRECT_MEASUREMENT on non-mechanism assertions; removed: basisKind is for MECHANISM predicates), V-522 (privacyClass missing; now `PUBLIC` on every node).
- **With negatives**: V-101 1 row (N9 Sensor MEASURES_METRIC without assertion; `MEASURES_METRIC` is in `$assertedTypes`), V-113 1 row (N8), V-301b 2 rows (N1 and N5 assay versions have no operator; collateral of the negatives), V-320a 1 row (N4), V-336 1 row (N4), V-333 1 row (N4 has no subject). All expected; no other rule fires.

## Queries: expected rows (observed identical, `checks/results/queries-positive.json`)

| Id | CQ | Expected rows |
|---|---|---|
| Q-W08-01 | CQ-DX-01, CQ-DX-C03 | 2: (`…epic-v2-iscan`, kit 20087706, methylation array, ToolOrInstrument, "Illumina iScan System", [Infinium]); (`…epic-v2-nextseq550`, …, "Illumina NextSeq 550 System", [Infinium]) |
| Q-W08-02 | CQ-DX-03 | 1: sameKit true, samePlatform true, sameInstrument false, verdict null, SEPARATE_SERIES |
| Q-W08-03 | CQ-DX-09 | 2: WHOOP 4.0 / Heart rate / 41.15.3.0 / core firmware / validFrom null / UNKNOWN; same for 41.16.1.0 |
| Q-W08-04 | CQ-DX-C01 | 4: Bluetooth 17.2.2.0 (no notes); core 41.11.7.0 ["Improved HR estimation during sleep"]; 41.15.3.0 ["Improved strap stability and issue reporting; Bug fixes"]; 41.16.1.0 ["Improved heart rate estimation algorithm"]; all releasedFrom null; asserter WHOOP, Inc. |
| Q-W08-05 | CQ-DX-03 | 1: sameDevice true, 41.15.3.0 → 41.16.1.0, sameAssayVersion false, SEPARATE_SERIES |
| Q-W08-06 | CQ-MF-02, CQ-DX-C02 | 1: WHOOP MG, RUNS_ON_DEVICE, "WHOOP ECG (electrocardiogram) Feature", CLEARANCE, isApproval false, QDA, pcccAuthorized false, K243236, SUBSTANTIALLY_EQUIVALENT, validFrom 2025-04-04, recordedFrom 2026-10-04T02:00Z, statusesOnDeviceItself 0 |
| Q-W08-07 | CQ-MF-03 | 3: REPORTS_INCONCLUSIVE_RATE 11 %, REPORTS_SENSITIVITY 96.2 %, REPORTS_SPECIFICITY 99.4 %; assertedBy WHOOP, Inc.; basis STUDY_RESULT; REGULATORY_RECORD; page 9 |
| Q-W08-08 | CQ-DX-02 | 1: WHOOP 4.0, Heart rate, vendorAssertion `hu:assertion:whoop-4-0-measures-heart-rate`, assayVersionsOnRecord 2 |
| Q-W08-09 | CQ-PR-03 | 2: WHOOP 4.0 (4, 0, 2, 2); WHOOP MG (0, 0, 0, 0) |
| Q-W08-10 | CQ-MF-04 | 2: Synthetic Lab C USES_EQUIPMENT NextSeq 550 (isPrimary false) and iScan (isPrimary true); assertedBy Synthetic Lab C; hasCapabilityState false |

## GraphQL build and round trip (`checks/build-and-roundtrip.mjs`, result `checks/results/graphql-roundtrip.json`)

`@neo4j/graphql` 7.6.3 / `graphql` 16.14.2 / `neo4j-driver` 6.2.0, stub `checks/build-stub.graphql` (minimal copies of W00/W01/W04/W07/W11 shapes) + `sdl-fragment.graphql`: parse ok, `Neo4jGraphQL.getSchema()` ok (1008 generated types without a vector provider). Root query and create mutation exist for all six W08 node types and `searchTechnologyPlatforms`. A `createDevices` mutation with a nested `implementsPlatforms.create` wrote `UsageEdgeProperties` (relationshipUid, assertionUid, usageContext, isPrimary, bases, recordedFrom) and stored labels `Device:Entity` / `TechnologyPlatform:Entity`; the union field `Product.embodiesModels` resolved `__typename: ToolOrInstrument`; `Device.firmwareVersions{declaredByAssayVersions}` and `compatibleSoftwareProducts` resolved against fixture data (the run had the negatives loaded, so N5/N6 also appear there). DateTime fields were not read back through GraphQL (the generated Cypher formats DateTime with APOC, absent from the harness, as W23 noted).

## Not run / limits

- No Enterprise edition; no existence or type constraints exercised (07-operations.md).
- The merged all-worker schema was not built (other fragments have unresolved references at this time); W08's fragment has zero duplicate definitions and zero unresolved references of its own in `merge-fragments.mjs` over all current fragments.
