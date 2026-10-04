# W07 operations recommendation

Target: Neo4j 5.26 (tested 5.26.31 Community, embedded) and `@neo4j/graphql` 7.6.3. `operations.cypher` was **run** on a fresh store: 41 statements, **32 applied** (section A: per-label uid and id uniqueness, `metric_loinc_code`, `lab_test_local_code`, payloadHash uniqueness on the four VersionedState types, relationship-uniqueness on `relationshipUid` for `PERFORMED_WITH_ASSAY_VERSION` and `MEASURES_METRIC`, five range indexes including one relationship index, three fulltext indexes), **9 rejected** as expected on Community (section B: property-existence and property-type constraints, including one relationship-existence constraint). All W07 fixtures then loaded under the section-A constraints without error and the W07 validation counts were identical to the unconstrained run (06-fixtures-and-queries.md). Enterprise behaviour is unverified.

## 1. Uniqueness and indexes (stored property names)

| Need | Statement (operations.cypher) | Why |
|---|---|---|
| uid lookup per primary label | `w07_*_uid` (13) | ingestion `MERGE` by uid; W00's archetype-level uid constraints stay authoritative for global uniqueness (V-000a) |
| live `id` | `w07_biomarker_id`, `w07_metric_id`, `w07_lab_test_id` | `@id` fields read by the GraphQL API |
| measurand key | `metric_loinc_code` (unique `loincCode`) | V-310b; normalize to `^[0-9]{1,7}-[0-9]$` before creation (V-310a) |
| orderable-test key | `lab_test_local_code` (`issuerUid`, `localTestCode`) | identity rule; nodes lacking either property are not constrained (Everlywell has no code) |
| state identity | `w07_*_payload` (unique `payloadHash`) | re-ingestion of an unchanged AssayVersion/AlgorithmVersion/RIV/PanelDefinition reuses the node; requires a canonical payload serializer (section 3) |
| episode identity | relationship uniqueness on `relationshipUid` | one edge per recorded-time episode; idempotent re-runs |
| filters | `algorithm_version_basis`, `w07_ri_version_kind`, `w07_comparability_verdict`, `w07_metric_system`, `w07_performed_with_recorded_to` | CQ-DX-04/06/03, CQ-MX-02, current-episode filter in QS-DX-01 |
| search | fulltext `BiomarkerSearch`, `MetricSearch`, `LabTestSearch` on `name`, `description`, `searchText` | D-015 (live names retained) |

No `@vector` is proposed for W07 types (no retrieval justification beyond fulltext; D-014).

## 2. Retrieval patterns

- Trend endpoint (CQ-DX-03): group results by `PRODUCED_BY_ASSAY_VERSION`/`COMPUTED_BY_ALGORITHM_VERSION` target; merge two groups only through a `COMPARED_TO` licensed by a well-formed current `ComparabilityAssessment` (V-302r/V-304r). Without a licence return separate series. Never group by `Metric.loincCode` or `LabTest.name`.
- As-of reads (CQ-DX-01): `PERFORMED_WITH_ASSAY_VERSION` episodes filtered by `recordedFrom <= t < coalesce(recordedTo, +inf)` and valid time.
- Interval at report time (CQ-DX-06): follow `INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION` from the result; never look up the "current" interval of the lab.
- Private-store access (CQ-AX-21): the private store sends only AssayVersion/AlgorithmVersion uids; the shared graph returns the assessment and never reads or stores the values.

## 3. Application validation (service-enforced, detected after the fact by V-*)

| Rule | Enforcement | Detector |
|---|---|---|
| closed enums (resultKind, versionBasis, outputKind, intervalKind, derivationKind, verdict, valueStatus) | GraphQL enum types; Cypher ingestion validates | V-303, V-308 |
| `ASSAY_OPERATED_BY` exactly one; `USES_METHOD`/`RUNS_ON_INSTRUMENT` zero_or_one | write-time check in the ingestion transaction | V-301a/b |
| `FOR_ASSAY_VERSION` exactly one | write-time | V-305b, V-305c |
| `COMPARES` exactly two of one kind | write-time | V-311 |
| `COMPARED_TO` written only by the projection job | API: `@settable(onCreate:false,onUpdate:false)` on W16's field; projection service writes Cypher | V-302r, V-304r, V-312, V-112 |
| MEASURED -> AssayVersion or UNRESOLVED pending; CALCULATED/INFERRED -> AlgorithmVersion or pending | write-time | V-303r, V-316 |
| `retrievedAt` required for SERVICE_ENDPOINT_UNVERSIONED | write-time | V-317 |
| bound value / bound status agreement | write-time | V-318 |
| `unitStatus` required on new Metric writes | write-time (nullable in SDL for legacy reads) | report query (count of null unitStatus) |
| `payloadHash` = `sha256:<hex>` over a canonical, sorted payload (D-016) | ingestion library; one serializer version per state type, recorded on the creating Activity | duplicate-payload uniqueness constraint |
| `privacyClass` PUBLIC/INTERNAL on results; no `hu:private-` uid | write-time + W23 boundary | V-313r, V-113..V-116 |

Transactions: create an AssayVersion with all six payload edges in one transaction (a partial payload is a different identity); create an asserted edge in the same transaction as its Assertion (fixture pattern). Concurrency: two ingestors creating the same AssayVersion converge through the payloadHash constraint (`MERGE` on payloadHash, then set uid on create).

## 4. Lifecycle, idempotence, migration

- States are immutable: a lab's analyzer, kit, software or interval change creates a new node; the old node is never edited. Corrections to when a change happened are new `PERFORMED_WITH_ASSAY_VERSION` episodes (`recordedTo` closes the old one); `ComparabilityAssessment` re-assessment is a new node with `SUPERSEDES`.
- Fixtures and ingestion use `MERGE` on uid and on `relationshipUid`; re-running every W07 fixture is idempotent.
- Migration order (migration-map.yaml): M1 backfill uid/archetype labels/entityType on Biomarker, Metric, LabTest, PanelDefinition, MeasurementMethod, Specimen, ReferenceRange; M2 normalize and de-duplicate `loincCode`, then create constraints; M3 backfill one Assertion per live `MEASURES_METRIC` edge and copy `MeasurementMetadata` into `MeasurementEdgeProperties` (non-null asserted fields would otherwise break GraphQL reads); M4 create AssayVersions from live `LabTest.USES_METHOD/REQUIRES_SPECIMEN/USES_PLATFORM` and delete those LabTest edges; M5 relabel `HAS_REFERENCE_RANGE`, `MEASURES`, `INCLUDES_BIOMARKER` as derived (V-305a lists remaining); M6 retire `Metric -[:MEASURED_IN]-> Organ` after writing review Assertions; M7 W20 relabels `SUPPORTED_BY -> Chunk`.
- Breaking API changes: `LabTest.usesMethods`, `requiresSpecimens`, `usesPlatforms` and `Metric.measuredInOrgans` disappear; `Metric.canonicalUnit`/`ucumUnit` become `canonicalUnitCode`; `MeasurementMethod.methodClass` -> `methodPrinciple`; `Specimen.specimenType` -> `specimenTypeCode`; several Biomarker/Metric display fields become read-only.

## 5. Ingestion overhead and normalization

- Per lab test: one LabTest, one AssayVersion per procedure realization (most fields NOT_REPORTED in public sources: 0/5 records had a software version), one Assertion + edge per `PERFORMED_WITH_ASSAY_VERSION` episode, one RIV per printed interval or limit (Mayo and Labcorp print 3 per HbA1c result).
- LOINC: store `propertyKind/systemKind/scaleKind` verbatim from the LOINC record; loinc.org was readable through Firecrawl in this run; the NLM Clinical Tables mirror was blocked by the egress proxy (403).
- Units: store reported units verbatim on the result; never convert in place; conversion is the assessment's `unitConversionRule`.
- Capability conditions: relationship uniqueness and relationship range indexes worked on 5.26.31 Community; property existence/type constraints need Enterprise (9 statements rejected).
