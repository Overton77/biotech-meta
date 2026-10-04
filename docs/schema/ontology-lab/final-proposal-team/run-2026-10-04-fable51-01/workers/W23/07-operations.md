# W23 07 Operations recommendation

Target as declared by the run: `@neo4j/graphql` 7.6.3, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22, Neo4j **5.26.31 Community** (embedded). Enterprise behaviour is unverified except where a statement is expected to be rejected on Community. Companion files: `operations.cypher` (Community-runnable, idempotent, 8 statements, all applied and re-applied without error on 2026-10-04) and `operations-enterprise.cypher` (12 statements, all rejected on Community as expected; never counted as passing).

## 1. Uniqueness and indexes (stored property names)

| Id | Statement | Edition | Purpose | Tested |
|---|---|---|---|---|
| (existing) `occurrence_uid`, `versioned_state_uid`, `entity_uid` | `REQUIRE n.uid IS UNIQUE` per archetype label | Community | uid uniqueness for AnswerRecord, PolicyVersion, DecisionCriterion | T-5 (uid reused across Occurrences) rejected |
| O-W23-01 `answer_record_id`, `policy_version_id`, `decision_criterion_id` | `REQUIRE n.id IS UNIQUE` | Community | live id = opaque uid segment; Cypher writers set it (`@id` is API-only) | T-4 rejected |
| O-W23-02 `policy_version_key_label` | `REQUIRE (n.policyKey, n.versionLabel) IS UNIQUE` | Community | one label per policy family | T-1 rejected; T-2 (missing versionLabel) accepted: uniqueness does not require presence |
| O-W23-02 `decision_criterion_key_method` | `REQUIRE (n.criterionKey, n.methodVersion) IS UNIQUE` | Community | criterion identity includes method | T-3 rejected |
| O-W23-03 `answer_record_recorded_as_of` | range index `(n.recordedAsOf)` | Community | replay queues and audits by viewpoint period (CQ-AX-03) | applied |
| O-W23-03 `answer_record_query_shape` | range index `(n.queryShapeId, n.queryShapeVersion)` | Community | re-run all answers of a shape after a shape change | applied |
| O-W23-03 `policy_version_policy_key` | range index `(n.policyKey)` | Community | effective-version lookup per family | applied |
| Enterprise existence/type | `recordedAsOf`, `schemaDigest`, `queryShapeId`, `accessTier`, `privateContext` existence; `recordedAsOf IS :: ZONED DATETIME`; PolicyVersion `payloadHash`, `policyKind` existence; `permittedUseKinds IS :: LIST<STRING NOT NULL>`; DecisionCriterion `methodVersion`; relationship `AUTHORIZED_BY.useKind` existence; `privacyClass IS :: STRING` | Enterprise only | defence in depth | rejected on Community (12/12) |

No index on `CITES_*`: the CQ-AX-11 reverse lookup is a one-hop traversal from the assertion. No fulltext or vector index on any W23 type: none has a retrieval justification, and **no shared index may cover a private-store label or private-only property** (V-W23-04).

## 2. Retrieval patterns

- Replay (CQ-AX-03): read AnswerRecord by uid → for each `CITES_ASSERTION` run QS-2a at (`recordedAsOf`, `validAt`) (Q-AR-1). Reverse (CQ-AX-11): `MATCH (a {uid})<-[:CITES_ASSERTION]-(r:AnswerRecord)` plus `SUPERSEDES.recordedAt > r.recordedAsOf` (Q-AR-3/3b).
- PUBLIC_ANSWER: compiled QS-5b/QS-6a with the tier label allow-list and the instance allow-list `privacyClass = 'PUBLIC'` on every hop (Q-PP-1, Q-L-2b), or a generated tier sub-schema (checks/public-subset.mjs). Not the operator GraphQL endpoint.
- Private-store replay: the PCS sends shared uids + R/V only (`replay-params.json`); the graph answers Q-DR-1…5.

## 3. Application validation (write path) and transactions

Neo4j cannot express these; the shared-graph write service must reject them before commit (audit queries detect after the fact; detection is not prevention).

| Rule | Where | Audit |
|---|---|---|
| No string or list value starting with `hu:private-` in any node or relationship property; no private-store label; `privacyClass` ∈ {PUBLIC, INTERNAL} and never null on a new write | every shared write | V-520, V-521, V-W23-09, V-W23-10, V-522 |
| No index creation over a private-store label or private-only property name (schema-change review) | DDL review / CI | V-W23-04 |
| AnswerRecord: create only; keys within the allow-list; `accessTier ≠ OWNER_PRIVATE`; `privateContext = EXCLUDED`; `privacyClass = INTERNAL`; `recordedAsOf ≤ commit time`; every cited record `recordedAt ≤ recordedAsOf` and not superseded at R; created in **one transaction** with its CITES edges and its WAS_GENERATED_BY Activity | answer publication | V-121, V-W23-01a/b, V-W23-02, V-W23-03 |
| PolicyVersion / DecisionCriterion: create only; `privacyClass = INTERNAL`; (policyKey, versionLabel) present; no possible effect overlap within a key (serialize writes per `policyKey`: take a lock on the family, e.g. by `MERGE` on a lock node or by a single writer, then check V-W23-08's overlap predicate inside the transaction) | policy administration | V-W23-08 |
| `AUTHORIZED_BY {useKind}` only to a USE_AUTHORIZATION version that permits the kind, recorded before and in effect at `Activity.startedAt` | answer composition | V-429, V-W23-07 |
| RECORDS / POSTS_RESULT only with an Assertion of the same predicate, subject and object, SUPPORTED_BY a locator in a snapshot; both endpoints PUBLIC; HAS_PARTICIPANT_TOKEN never written; participantToken not `hu:`/`pcs`/hash-like | ingestion of public persons and participants | V-W23-05, V-W23-06 |

Concurrency: AnswerRecord and policy writes are append-only, so the only race is the policy-family overlap (serialized per key as above) and uid/id collisions (constraints). Idempotence: ingestion uses `MERGE` on uid for re-runs; a re-run that would change an immutable property is rejected by the service (the API already offers no update mutation for W23 types).

## 4. Capability and edition conditions

| Capability | Community 5.26 | Enterprise 5.x | Consequence |
|---|---|---|---|
| Node and composite property uniqueness | yes (tested) | yes | used |
| Property existence and property type constraints | no (12/12 rejected) | yes | service validation on Community |
| Role-based and property-based access control | no | RBAC yes; PBAC from 5.24 (S-1) | defence in depth only; write GRANT allow-lists on `privacyClass = 'PUBLIC'`; never DENY (fails open on null/misspelled criteria, S-1/S-2); create labels and properties named in privileges before granting (S-2, nonexistent names are not applied) |
| Full-text results under security rules | n/a | filtered conservatively, may return fewer results (S-2) | public search must not rely on RBAC to hide records |
| APOC | not present in the embedded test instance | — | `@neo4j/graphql` 7.6.3 DateTime reads call `apoc.date.convertFormat` (X-3): install APOC where the generated API serves reads, or the reads fail |
| PostgreSQL temporal keys (private store) | `WITHOUT OVERLAPS` from 18 (S-4, S-5); absent in 17 (S-6) | — | two-period `EXCLUDE USING gist` with `btree_gist` works on any supported release; parser-checked (X-5) |

## 5. Lifecycle, migration, compatibility, overhead

- Lifecycle: AnswerRecord, PolicyVersion, DecisionCriterion are insert-only; nothing in W23's shared scope is ever erased for privacy reasons because nothing in it is personal. A policy is retired by publishing a new version with a later effect; an answer is corrected by publishing a new AnswerRecord.
- Migration (`migration-map.yaml`): relabel lower-case `privacyClass` values to `PUBLIC`/`INTERNAL` (recommendation-snapshot.cypher alone: 84 + 9 nodes); backfill `privateContext = EXCLUDED` on AnswerRecords; backfill `policyKey`, `versionLabel`, `policyKind` on legacy PolicyVersions; delete live `HAS_PARTICIPANT_TOKEN` edges with a logged count; report (not delete) legacy RECORDS/POSTS_RESULT edges without assertions.
- Compatibility: proposed-delta's `AnswerRecord.accessTier: String!` becomes an enum; stored values that are enum names are unchanged; other values surface in V-W23-01a.
- Ingestion overhead: one AnswerRecord + n CITES edges + one Activity per published answer; validators V-W23-01…03 are per-record checks; V-W23-04 is metadata-only; V-W23-09/10 scan all properties (run them in batch audits, as V-521 already does).
