# W09 operations recommendation

Target declared for this run: Neo4j **5.26.31 Community**, `@neo4j/graphql` **7.6.3**. Enterprise behaviour is not verified.

| File | Contents | Run result |
|---|---|---|
| `operations.cypher` | Community-runnable statements | 42/42 applied on 2026-10-04 |
| `operations-enterprise.cypher` | Existence and type constraints | 17/17 rejected by Community, as expected |

## 1. Uniqueness and indexes (stored property names)

| Need | Statement(s) | Why |
|---|---|---|
| uid and live id per primary label (13 labels; AE covered by the `StudyResult` label) | `<label>_uid`, `<label>_id` | GraphQL-generated Cypher binds `(this:Study:Entity) WHERE this.id = $id`; the archetype-label uid constraints (W00) do not serve primary-label lookups. INV-106. |
| Registry entry natural key | `trial_registration_identity (registry, registrationId)` (baseline name reused) | One entry per registry id; a study may have several registrations. |
| Publication keys | `publication_doi` (baseline), `publication_pmid` (new) | Materialized lookup keys. The Identifier records (scheme, issuer, value) stay authoritative. A correction has its own DOI and PMID. |
| Registry versions | `registration_version_observed_at`, `registration_version_status` | QS-W09-01 and the as-of slice; V-212 informational. |
| Results | `study_result_analysis` (baseline) | V-215/V-215r, QS-W09-03 |
| AE rows | `ae_result_seriousness_method` | QS-W09-05, V-217r/V-217i |
| Arms, outcomes, studies | `study_arm_type`, `outcome_definition_measure_kind`, `study_kind` | V-221r, CQ-ST-03, CQ-EV-03 |
| Relationship properties | `registered_as_assertion`, `uses_intervention_material_assertion`, `reports_on_assertion`, `corrects_revision_event`, `retracts_revision_event`, `has_registration_version_recorded` | INV-503 audits (edge ↔ assertion), V-W09-04, QS-W09-01 recorded-time slice |
| Full-text | `StudySearch` on stored `name`, `description`, `searchText` (D-015, live index name kept) | `searchStudies` query retained |
| Vector (Fable, D-014) | `@vector StudySearchEmbedding` on `searchEmbedding`, no provider; dimensions recorded by Fable | Free-text study lookup by agents; embeddings computed outside the API |

**Not indexed on purpose:**
- `RegistrationVersion.versionDate`: mostly null while history is blocked.
- `Dataset.accessLevel`: low cardinality and rarely filtered alone.

**Uniqueness that cannot be a constraint:**
- "Exactly one INTERVENTION arm per AE row" → V-W09-08.
- "Exactly one owning registration per version" → V-211r.
- "At most one target per component" → V-W09-03.
- "EXCLUSIVE `HAS_REGISTRATION_VERSION` episodes never definitely overlap" → W00 service check, plus V-508/V-509 audits.

## 2. Application (service) validation and transactions

**Asserted edges (W09 set).** Each of `REGISTERED_AS`, `ASSIGNS_INTERVENTION`, `USES_INTERVENTION_MATERIAL`, `USES_INTERVENTION_DEVICE`, `FOLLOWS_INTERVENTION_DEFINITION`, `REPORTS_ON`, `PRODUCED_DATASET`, `ANALYZES_DATASET`, `CORRECTS`, `RETRACTS`, `INVESTIGATES` and `STUDIED_IN` is written **in the same transaction** as its authorizing Assertion. The service assigns `relationshipUid`, `recordedFrom = assertion.recordedAt` and copies the assertion's valid bounds (INV-101, INV-503). V-W09-10 audits.

**Registry ingestion** (one transaction per observed version):
1. Create a `SourceSnapshot` for the capture.
2. Create the `RegistrationVersion` (immutable).
3. Add a new `HAS_REGISTRATION_VERSION` episode. If the registry states the new version's date, also close the prior episode's recorded interval and re-attach it with `validTo` (the round 0007 VALIDITY_BOUNDED shape; fixture 01).
4. Run the EXCLUSIVE overlap check; a DEFINITE overlap is refused.
5. Regenerate the derived Study cache and `OutcomeDefinition.priority` in the same transaction.

Concurrent ingestion of two versions of one registration must serialize on the TrialRegistration node. Take a write lock by `SET reg._lock = coalesce(reg._lock, 0)` or use an application mutex.

**Derived fields** are regenerable and are written only by the derivation service, never by GraphQL clients (`@settable` false):
- `Study.overallStatus`/`enrollmentCount`/`projectionOfRegistrationVersionUid`
- `OutcomeDefinition.priority`/`priorityAssertionUid`
- `StudyResult.isStatisticallySignificant`
- `SPONSORED_BY`/`OPERATED_BY`/`INVESTIGATED_BY` (with `derivationRule`, `derivedFromAssertionUids`, `derivedAt`)

**Conditional requirements (V-221r).** When `quantityStatus` is REPORTED (or null with a quantity present), `quantity`, `unitCode`, `quantityBasis` and `massBasis` are required. A device component requires `quantityStatus` NOT_APPLICABLE and a device target.

**AE rows (V-217r).** `collectionMethod` is required. The ingester never creates an AE row for a source without an AE statement.

**Corrections and retractions.** On a PubMed publication-type change or a notice link, in one transaction:
1. Create the notice `Publication`.
2. Create its Source and snapshot.
3. Create the W00 `SourceRevisionEvent` (revises the affected rendition Source).
4. Create the `CORRECTS`/`RETRACTS` assertion and edge with `sourceRevisionEventUid`.
5. For changed content, create the superseding assertions (`SOURCE_CORRECTION`).

Never edit the old assertions except the single `recordedTo` write (INV-501, INV-504).

**Immutability.** InformationArtifacts and VersionedState payloads are immutable. Fable may express this through `@mutation(operations: [CREATE])` on `RegistrationVersion`, `StudyResult`, `AdverseEventResult` and `Publication`. W09 did not add it, because legacy migration may need updates.

## 3. Capability and edition conditions

- **Community:** uniqueness, range, relationship-property range and full-text indexes. All of `operations.cypher` applied on 5.26.31.
- **Enterprise:** existence and type constraints (`operations-enterprise.cypher`). Without them the V-W09 queries and the service are the guard.
- **APOC Core is required by `@neo4j/graphql` 7.6.3.** It renders `DateTime` fields with `apoc.date.convertFormat`. A W09 GraphQL read of `RegistrationVersion.observedAt` against the APOC-less embedded 5.26.31 failed with "Unknown function 'apoc.date.convertFormat'"; the same read without DateTime fields succeeded (W09-SR-17). W09 types expose these DateTime fields: `observedAt`, `publishedAt`, `createdAt`, `updatedAt`, `effectiveFrom`/`effectiveTo`, and the edge `recordedFrom`/`validFrom`.
- **Relationship-type indexes on edge properties** need 5.x (available on 5.26 Community).
- **Memory:** under about 22 concurrent embedded instances on a 16 GB host, an unbounded embedded instance was killed mid-suite. A 384 MB heap was sufficient for W09's 253-node fixture set plus the 174-statement suite.

## 4. Idempotence, lifecycle, migration

- Fixtures and ingestion use `MERGE` on uid with `ON CREATE SET`, so reloading is idempotent. Edge `MERGE` keys include `relationshipUid` wherever several episodes can join the same pair (fixture 01).
- **Migration order** (see `migration-map.yaml`):
  1. Relabel `OutcomeMeasure` → `OutcomeDefinition:VersionedState`, `OutcomeResult` → `StudyResult:InformationArtifact`, `Population` → `StudyPopulation:VersionedState`.
  2. Add archetype labels to `Study`, `StudyArm`, `Dataset`.
  3. Create a `TrialRegistration` plus a `RegistrationVersion` (observedAt = `registrySyncedAt`, else the migration time with basis OBSERVATION_ONLY) from each Study's registry fields; null the moved Study fields; set the derived cache.
  4. Convert `RECEIVES` edges into ASSIGNS_INTERVENTION / StudyIntervention / InterventionComponent records. Product targets become an unresolved material plus an `ADMINISTERED_AS_COMMERCIAL_PRODUCT` assertion.
  5. Rename relationship types (`HAS_OUTCOME_MEASURE` → `DEFINES_OUTCOME`, `FOR_MEASURE` → `RESULT_FOR`, `FROM_ARM` → `RESULT_FOR_ARM`, `STUDIES` → cohort edges, `HAS_DATASET` → `PRODUCED_DATASET`). Each asserted edge gets a migration Assertion with reviewerType MIGRATION.
  6. Leave `EVALUATES` in place, read-only. Rename it to `LEGACY_EVALUATES` if W09-SR-13 is accepted.
  7. Run V-201: every remaining legacy edge to Product is listed as backlog, not deleted.
- **Compatibility:**
  - GraphQL root fields change: `outcomeMeasures` → `outcomeDefinitions`, `outcomeResults` → `studyResults`, `populations` → `studyPopulations`.
  - `Study.hasArms` → `arms` and `hasOutcomeMeasures` → `outcomeDefinitions`.
  - The `Study.hasResults`, `pmid` and `doi` fields disappear.
  - Clients must move to `registeredAs { versions }` and `reportedIn`.

## 5. Ingestion and normalization overhead

| Item | Overhead |
|---|---|
| One registry observation | 1 snapshot + 1–3 locators + 1 version + 1 episode edge + derived cache. Outcome definitions and priority assertions only on first sight of each measure. |
| One paper result sentence | 1–2 StudyResults (within- and between-arm split) + locator with quoteHash (NFC-WS1) + RESULT_FOR_ARM edges with explicit `armRole`. |
| AE section | 1 row per arm × term × seriousness, plus the cohort link for denominators. |
| Cost driver | Every asserted edge carries its own Assertion. W09 fixtures: 253 nodes, about 60 Assertions, 451 relationships for 8 studies. |
