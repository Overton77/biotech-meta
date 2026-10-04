# W19 operations recommendation

Target declared by the run: Neo4j 5.26.31 Community (tested), `@neo4j/graphql` 7.6.3 (no `@unique`; uniqueness only through Cypher constraints). Enterprise property-existence/type constraints are unverified. No runtime implementation here. The Community-runnable statements are in `operations.cypher`; on a fresh 5.26.31 Community instance they ran 8/8 ok, a second run was idempotent (8/8 ok, `IF NOT EXISTS`), fixtures 01–05 then loaded 128/128 ok under the constraints, and a duplicate `SourceDiscoveryRecord.uid` was rejected ("already exists with label `SourceDiscoveryRecord` and property `uid`"). The fixture runs in `06` used no constraints.

## 1. Constraints and indexes (stored property names)

| Purpose | Statement (Community-runnable unless marked) | Notes |
|---|---|---|
| uid uniqueness, W19 labels | `CREATE CONSTRAINT source_authority_uid IF NOT EXISTS FOR (n:SourceAuthorityAssessment) REQUIRE n.uid IS UNIQUE` (same for `SourceCoverageRequirement`, `SourceDiscoveryRecord`) | V-000a still needed for cross-label uniqueness |
| one current version per requirement | application-enforced: unique (`requirementKey`, `versionLabel`) via `CREATE CONSTRAINT coverage_req_version IF NOT EXISTS FOR (n:SourceCoverageRequirement) REQUIRE (n.requirementKey, n.versionLabel) IS UNIQUE` | Community supports composite uniqueness; "one with recordedTo null per key" is application-enforced |
| canonicalUri lookup (W00 owns) | `CREATE CONSTRAINT source_canonical_uri IF NOT EXISTS FOR (n:Source) REQUIRE n.canonicalUri IS UNIQUE` | depends on the canonicalUri rule (SR-10); `Document` stores it as `url` today (alias), so the live Document index uses `url` until W20 aligns |
| discovery by subject | `CREATE INDEX discovery_subject IF NOT EXISTS FOR (n:SourceDiscoveryRecord) ON (n.subjectUid, n.startedAt)` | Q-13, Q-17 |
| discovery by outcome | `CREATE INDEX discovery_outcome IF NOT EXISTS FOR (n:SourceDiscoveryRecord) ON (n.discoveryOutcome)` | blocked-retrieval queues |
| requirement by label | `CREATE INDEX coverage_subject_label IF NOT EXISTS FOR (n:SourceCoverageRequirement) ON (n.subjectLabel)` | Q-13 |
| current authority per Source | range index `FOR (n:SourceAuthorityAssessment) ON (n.recordedTo)` | Q-15 filters `recordedTo IS NULL` |
| snapshot freshness (W00) | range index `FOR (n:SourceSnapshot) ON (n.observedAt)` | Q-13 max(observedAt) |
| existence of `discoveryOutcome`, `authorityScopes`, `requiredSourceKinds` | **Enterprise only** (`REQUIRE n.x IS NOT NULL`); on Community: application validation + audit query | do not count Community rejection as a pass |

No fulltext or vector index: W19 records are operational and never retrieved by text similarity.

## 2. Application validation (transactional, at write time)

1. `SourceAuthorityAssessment`: exactly one `ASSESSES_SOURCE_AUTHORITY`; every `ASSESSED_ON_SNAPSHOT` target is a snapshot of that Source; `authorityScopes` values in the enum; `overallScore` and `confidence` null; no outgoing edge except the four declared (guard Q-14a); re-assessment = new node + `SUPERSEDES` + set `recordedTo` once on the old node in the same transaction.
2. `SourceCoverageRequirement`: immutable after commit except a single `recordedTo` write; at most one version per `requirementKey` with `recordedTo` null (check inside the write transaction with a lock on the key, e.g. `MERGE (:RequirementKeyLock {key})` pattern or application mutex).
3. `SourceDiscoveryRecord`: `activityKind = 'DISCOVERY'`; `discoveryOutcome` required; BLOCKED/PARTIAL/ERROR require `blockEvidence`; `DISCOVERED_SOURCE` only for FOUND/PARTIAL; `subjectUid` must resolve to a shared uid (never `hu:private-`); immutable after `endedAt`.
4. Status separation: no writer may change `Assertion.status` or create an `Adjudication` from a coverage, discovery or authority result (N9 → V-110 catches status writes without adjudication; Q-14a catches edges).
5. Error-page detection at capture: a 2xx response whose title/body matches a denial pattern (e.g. "403 Forbidden", "Access Denied", login wall) is recorded as BLOCKED and produces no snapshot.
6. Cached captures: when the capture service reports a cache hit, `observedAt` = cache time (SR-15).

Concurrency: discovery records and assessments are insert-only; idempotence by deterministic uid (`hu:source-discovery:<sha256(attemptedUri|startedAt|agent)>` once the token is registered) so a retried job does not duplicate a record.

## 3. Retrieval patterns

- Coverage dashboard: Q-13a parameterized by R; cost ~ (requirements × subjects of label); paginate by `subjectLabel`.
- Authority review queue: Q-15 restricted to assertions recorded since the last run.
- Blocked-source queue: `MATCH (d:SourceDiscoveryRecord {discoveryOutcome:'BLOCKED'}) WHERE d.startedAt > $since RETURN d.attemptedUri, count(*)`.
- Answer qualification (W23): an answer citing a registry fact reads Q-17's `cannotEstablish` and `historyRetrieval` and states them; it never exposes the records themselves.

## 4. Lifecycle, migration, compatibility

- Additive: no live type changes from W19. Registry migration: one `SourceAuthorityAssessment` per registry entry (`registryEntryId`), scopes from `registry-authority-mapping.yaml`, method `w19-authority-scope-v0.1`, status PROPOSED until reviewed.
- 15 registry entries with doi.org URLs need a captured landing page Source before an assessment can attach; until then the assessment waits (NOT_ASSESSED is the honest state).
- `Document.isPrimarySource` stays readable (advisory deprecation) until W20 retires it.
- Ingestion overhead: one discovery record per attempt (small, INTERNAL); one authority assessment per Source (rarely re-assessed); requirements are a handful of nodes.
- Edition conditions: everything in sections 1–3 except existence/type constraints runs on Community 5.26; the `duration.inDays` and `EXISTS {}` forms used in Q-13 are 5.x syntax (run on 5.26.31).
