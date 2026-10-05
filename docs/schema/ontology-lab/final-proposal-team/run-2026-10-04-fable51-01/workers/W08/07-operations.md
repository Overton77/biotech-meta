# W08 operations recommendation

Target: Neo4j **5.26.31 Community** (tested) and `@neo4j/graphql` **7.6.3** (tested). Enterprise behaviour is not verified. No runtime implementation is proposed here; `operations.cypher` is the DDL proposal, executed on the test instance (27/27 statements applied; `checks/results/operations.json`).

## 1. Uniqueness and indexes (stored property names)

| Need | Statement (in `operations.cypher`) | Edition | Verified |
|---|---|---|---|
| one node per `uid` for each W08 label | `technology_platform_uid`, `tool_or_instrument_uid`, `device_uid`, `sensor_uid`, `modality_uid`, `firmware_version_uid` | Community | yes; duplicate `CREATE (:Device {uid:'hu:device:whoop-4-0'})` rejected |
| live GraphQL `id` unique per label | `*_id` constraints | Community | yes |
| FirmwareVersion state identity | `firmware_version_payload_hash` (`payloadHash` over device uid + component + label) | Community | yes |
| one asserted edge per recorded-time episode | relationship uniqueness on `relationshipUid` for the eight asserted W08 relationship types | Community (5.7+) | yes; duplicate `USES_PLATFORM {relationshipUid}` rejected; `SHOW CONSTRAINTS` type `RELATIONSHIP_UNIQUENESS` |
| assertion → edge join (V-W08-04, QS-4a "which edges does this assertion authorize") | relationship range indexes on `assertionUid` for USES_PLATFORM, USES_EQUIPMENT, IMPLEMENTS_PLATFORM, RUNS_ON_DEVICE | Community | applied |
| release-note upsert by vendor label | `firmware_version_label` range index on `versionLabel` | Community | applied |
| live fulltext search | `TechnologyPlatformSearch` on `name`, `description`, `searchText`; query name `searchTechnologyPlatforms` kept (D-015) | Community | applied; GraphQL query generated |
| existence/type constraints (`uid`, `entityType`, `versionLabel`, edge `assertionUid`) | commented ENTERPRISE block | Enterprise only | Community rejects (`requires Enterprise Edition`), consistent with baseline fact 3; enforced by the write service and V-W08-04 instead |

No `@unique` directive is used (absent in 7.6.3). No vector index is declared; `TechnologyPlatform.searchEmbedding` stays a plain property until Fable adds `@vector` without `provider:` with a retrieval justification (D-014). Embedding dimensions: none recorded because none are declared.

## 2. Retrieval patterns

| Pattern | Anchor | Notes |
|---|---|---|
| assay version → instrument model → platform (Q-W08-01) | `AssayVersion.uid` (W07 constraint) | 2 hops; platform is optional |
| device → assay episodes as of T (Q-W08-03) | `Device.uid` | filter `e.recordedTo IS NULL` (or `recordedFrom <= V < recordedTo` for as-of-recorded), valid-time overlap with null bounds read as unknown, never open |
| device → products that run on/embody it → statuses (Q-W08-06) | `Device.uid` | must also return `COUNT{(:RegulatoryStatus)-[:STATUS_OF]->(d)}` = 0 to show the device carries no status itself |
| firmware lineage (Q-W08-04) | `Device.uid` then `FIRMWARE_VERSION_OF` IN | order by componentLabel then versionLabel string; **no numeric ordering** of vendor strings and no ordering from page row order (S1 repeats rows) |
| platform → implementers → assay versions (CQ-DX-C03) | `TechnologyPlatform.uid` or fulltext | fan-out bounded by instruments per platform |

## 3. Application validation (write service)

1. Reject writes that violate V-W08-01 (instrument target), V-W08-02 (forbidden property names on W08 labels), V-W08-03 (status on W08 labels), V-W08-05/06 (firmware consistency), V-W08-09 (unit-level or private data) and V-W08-11 (performance claim shape) **before commit**; run them again as audits.
2. Asserted W08 edges are written in the same transaction as their Assertion (subject, object, `SUPPORTED_BY` locator, optional `ASSERTED_BY`) and copy its valid bounds, precisions and bases (asserted_edge profile). `recordedFrom` is the commit time assigned by the service, never backdated; `recordedTo` is written once.
3. `AssayVersion.softwareVersion` on a device-run assay version is written from the vendor string exactly; when a FirmwareVersion with that label exists for the device, the service also writes `RUNS_FIRMWARE_VERSION` (V-W08-07 lists misses).
4. A firmware release note never sets `PERFORMED_WITH_ASSAY_VERSION.validFrom` (phased rollout); validFrom is written only from a source-stated date, else null with basis UNKNOWN.
5. Performance-claim text: numbers go to `valueNumber`/`unitCode` (UCUM `%`), scope to `QUALIFIED_BY` (when W21 allows) or `description`; never to equipment nodes.
6. Device units, serial numbers, pairing and ownership are written only to the private store, referencing `Device.uid`.

## 4. Transactions and concurrency

- Node upserts are `MERGE` on `uid` under the uniqueness constraints; concurrent ingestion of the same vendor page converges (second writer gets a constraint violation and retries as a read).
- One recorded-time episode per asserted edge: closing an episode (`SET r.recordedTo`) and opening its successor happen in one transaction.
- Corrections are new Assertions plus `SUPERSEDES {EXTRACTION_FIX | SOURCE_CORRECTION}`; the old Assertion gets `status: SUPERSEDED` and `recordedTo` in the same transaction (fixture 2 pattern; V-109 zero rows).

## 5. Idempotence, lifecycle, migration, compatibility

- Fixtures and DDL are idempotent (`MERGE`, `IF NOT EXISTS`); reloading the three positive fixtures on a populated database applied cleanly.
- Migration order (see `migration-map.yaml`): (1) assign `uid` to live TechnologyPlatform/ToolOrInstrument/Device/Sensor/Modality nodes (tokens after W00 registration); (2) backfill an Assertion for every live usage/implementation/sensor/modality edge (`status EXTRACTED`, `assertionBasis UNSTATED`, bases UNKNOWN) or drop it; (3) relabel `Organization USES → USES_EQUIPMENT`, `Product IMPLEMENTS → IMPLEMENTS_PLATFORM`, `Product CLASSIFIED_AS → EMBODIES_MODEL` (after W04 adds the field); (4) retire `Sensor MEASURES_METRIC` and `LabTest USES_PLATFORM` (V-W08-08 must reach zero); (5) create the constraints.
- GraphQL compatibility: type and field names of the five live types are unchanged; `name` becomes nullable (D-013); `Sensor.measuresMetrics` disappears; new fields are additive. `ProductClassification` clients move to `EquipmentModelTarget`.
- Lifecycle: equipment-model nodes are never deleted for being discontinued (EPIC v1.0 discontinuation is an Assertion); FirmwareVersion nodes are immutable states.

## 6. Ingestion and normalization overhead

- One FirmwareVersion per (device, component, label): WHOOP 4.0 alone lists about 20 core builds; the cost is small and bounded by vendor publication.
- Device-run AssayVersions multiply by firmware builds × metrics if every firmware bump creates a new AssayVersion (W07 rule "any change in software version creates a new AssayVersion"). For WHOOP 4.0 that is ~20 × the number of reported metrics. W08 does not relax the rule; W07 may decide that a build whose vendor note names no metric change still creates a new state (current rule) or that the device maker's statement suffices to keep the previous state (would need a CQ and a failing case).
- Release-note pages without dates or stable row order (S1) require a capture per observation and a locator per row; ingestion must not infer dates from capture time (validFromBasis OBSERVATION_ONLY requires a null bound).
- Search-provider stores (Tavily) may serve a page when the live site returns 503 (S3); the snapshot must record that path (`captureCompleteness`, observedAt proxy) rather than claim a live fetch.
