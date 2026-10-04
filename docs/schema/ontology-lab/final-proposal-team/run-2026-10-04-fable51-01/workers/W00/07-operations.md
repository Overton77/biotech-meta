# W00 operations recommendation

Target: Neo4j **5.26.31 Community** (tested, embedded) with **APOC Core 5.26.31**; `@neo4j/graphql` **7.6.3**. Enterprise behaviour is unverified (no instance). Runnable statements: `operations.cypher` (Community, 53 statements, all applied); Enterprise-only companion: `operations-enterprise.cypher` (34 statements, all rejected on Community, by design). This is a recommendation for Fable's `final_biotech_schema_operations.cypher`, not a runtime implementation.

## 1. Edition matrix

| Rule | Community 5.26 | Enterprise 5.26 | Service-enforced (both) |
|---|---|---|---|
| uid unique per archetype label (INV-001 part) | uniqueness constraint ✔ | ✔ | — |
| uid globally unique across archetypes | ✘ (constraints are per label) | ✘ | token-prefixed opaque UUID/ULID + V-000a audit |
| uid/id present | ✘ | `IS NOT NULL` ✔ | write guard + V-W00-08 |
| exactly one archetype label (INV-001) | ✘ | ✘ | write guard + V-000b |
| Source.canonicalUri unique | ✔ | NODE KEY ✔ | normalization rule (CL-003 R2) |
| Identifier (scheme, issuer, value) unique | ✔ | NODE KEY ✔ | normalizationRule per scheme |
| Activity (externalRunSystem, externalRunId) unique | ✔ | ✔ | — |
| relationshipUid unique per asserted/bitemporal type | ✔ (relationship uniqueness, 5.7+; accepted on 5.26.31) | RELATIONSHIP KEY ✔ | — |
| recordedAt / recordedFrom present and ZONED DATETIME | ✘ | existence + type ✔ (5.9+) | `datetime.transaction()` at commit; V-514, V-101 |
| exactly one subject; literal xor object; ≤1 asserter; ClaimOccurrence container | ✘ | ✘ | write guard (§3) + V-002, V-003, V-W00-01, V-410 |
| valid-time / content immutability; recordedTo written once | ✘ | ✘ | API: `@settable`/`@mutation` (D-W00-02); Cypher: guard G6 + V-W00-06, V-506 |
| no backdating (recordedAt ≥ snapshot retrievedAt) | ✘ | ✘ | guard G5 + V-504 |
| exclusive definite overlap (TM-R5) | ✘ | ✘ | guard G4 with subject lock + V-508; possible overlaps → V-509 queue |
| asserted-edge fidelity, derived-edge citation (INV-004, D-011) | ✘ | ✘ | V-W00-11, V-W00-02, V-112 |
| typed-selector completeness (V-401), IMAGE_REGION edge (CL-011) | ✘ (`selectorKind` existence is Enterprise-only and legacy locators have none) | partial | V-401, V-403, V-W00-03 |
| enum spellings readable by GraphQL | ✘ | type constraints cannot restrict values | ingestion contract (§6) + V-W00-09 |
| private-store boundary | ✘ | ✘ | V-113…V-116, V-520, V-521 (W23) |

## 2. Uniqueness constraints (Cypher, stored property names)

Per **archetype label** (names reused from `constraints.cypher`): `entity_uid`, `versioned_state_uid`, `occurrence_uid`, `information_artifact_uid`, `assertion_uid`, `evidence_assessment_uid` — `FOR (n:<Archetype>) REQUIRE n.uid IS UNIQUE`.

Per **W00 primary label** (uid and live id; the planner only uses an index whose label appears in the pattern, and GraphQL lookups filter on `id`):

```cypher
CREATE CONSTRAINT source_uid IF NOT EXISTS FOR (n:Source) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_id IF NOT EXISTS FOR (n:Source) REQUIRE n.id IS UNIQUE;
// same pair for SourceSnapshot, SourceLocator, SourceRevisionEvent, Adjudication, ResolutionHypothesis,
// EquivalenceAssessment, Agent, Activity, Identifier, Mention; assertion_id for Assertion (uid covered by assertion_uid)
CREATE CONSTRAINT source_canonical_uri IF NOT EXISTS FOR (n:Source) REQUIRE n.canonicalUri IS UNIQUE;
CREATE CONSTRAINT identifier_scheme_issuer_value IF NOT EXISTS FOR (n:Identifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE;
CREATE CONSTRAINT trade_item_identifier_identity IF NOT EXISTS FOR (n:TradeItemIdentifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE;
CREATE CONSTRAINT activity_external_run_unique IF NOT EXISTS FOR (n:Activity) REQUIRE (n.externalRunSystem, n.externalRunId) IS UNIQUE;
CREATE CONSTRAINT has_state_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_STATE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT has_identifier_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_IDENTIFIER]-() REQUIRE r.relationshipUid IS UNIQUE;
```

**Pattern for every domain owner** (instantiate for each primary label and each asserted/bitemporal relationship type):

```cypher
CREATE CONSTRAINT <label>_uid IF NOT EXISTS FOR (n:<Label>) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT <label>_id  IF NOT EXISTS FOR (n:<Label>) REQUIRE n.<storedIdProperty> IS UNIQUE;   // documentId, chunkId … per B2 aliases
CREATE CONSTRAINT <type>_relationship_uid IF NOT EXISTS FOR ()-[r:<TYPE>]-() REQUIRE r.relationshipUid IS UNIQUE;
```

Specialization labels (Document under Source, TradeItemIdentifier under Identifier, ClaimOccurrence under Assertion) inherit the parent constraints because they carry the parent label; a specialization constraint is added only when it has its own key (Document.documentId).

## 3. Indexes required by the query shapes

| Index (Community) | Shape / check | Why |
|---|---|---|
| `assertion_recorded_at` (Assertion.recordedAt), `assertion_recorded_to` | QS-2a, Q01-e, V-506 | recorded-time slice |
| `assertion_predicate_recorded` (predicate, recordedAt) | QS-2a, QS-7, QS-4b | equality on predicate + range on recordedAt |
| `assertion_status` | V-110, V-401 audits | status-scoped audits |
| `adjudication_recorded_at`, `adjudication_reviewed_at` | QS-1a, CQ-TM-01 replay, V-110/V-511 | adjudications as of R (recordedAt is the recorded clock; QS-1a still reads reviewedAt) |
| `snapshot_retrieved_at`, `snapshot_observed_at`, `source_snapshot_content_hash` | QS-1a/QS-2a lastObservedAt, V-111, V-504, re-capture dedup | |
| `source_locator_quote_hash` | echo detection, re-anchoring | same quote across sources |
| `source_revision_event_recorded_at` | CQ-TM-06 (revisions learned in a window) | |
| `identifier_value` | QS-8 / CQ-ID-04 cross-issuer lookup | composite key leads with scheme, issuer |
| `has_state_recorded_from`, `has_identifier_recorded_from` + template `<t>_recorded_from` for every asserted type | QS-2b, QS-2c | edge-level as-of (range indexes do not index nulls, so the current view `recordedTo IS NULL` is not index-served; materialize a current flag only as a derived projection if profiling demands) |
| `has_state_assertion_uid`, `has_identifier_assertion_uid` + template `<t>_assertion_uid`; `<d>_projection_of` for derived types | regeneration on supersession, V-W00-11, QS-4a | find edges projecting an assertion |
| `supersedes_recorded_at` | V-506/V-507, CQ-RC-07 triage | |
| fulltext `mention_surface_form` | QS-8 (Q08-c) | lexical candidates only, never identity |

## 4. Atomic write checks (transactional pattern; executed in F11)

One ingestion unit (an assertion bundle: assertion + its locator links + its projected edge/episode + optional supersession) is **one explicit transaction**:

1. **Lock the subject** when the bundle writes an EXCLUSIVE attachment: `MATCH (v {uid: $subjectUid}) SET v.lockToken = randomUUID() REMOVE v.lockToken` — a property write takes the node's exclusive lock until commit, serializing concurrent attachment writers so the overlap check cannot race.
2. **Idempotent creates**: `MERGE (a:Assertion {uid: $uid}) ON CREATE SET a += $content, a.recordedAt = datetime.transaction(), …`; never `ON MATCH SET` content. Uniqueness constraints make MERGE safe under concurrency (Cypher manual, S-07: constraints "protect against duplicate creation under concurrent loads, where MERGE alone only guarantees the existence of the pattern"). Edges: `MERGE (s)-[r:T {relationshipUid: $ru}]->(o) ON CREATE SET …`.
3. **Pre-commit audit in the same transaction** (template in `fixtures/11-write-guards.cypher` AUDIT blocks) returning one row per violation: ARCHETYPE_COUNT, SUBJECT_COUNT, ASSERTER_COUNT (>1, or ≠1 for ClaimOccurrence), LITERAL_XOR_OBJECT, CLAIM_OCCURRENCE_CONTAINER, BACKDATED_RECORDED_AT (recordedAt < any supporting snapshot's retrievedAt, or client-supplied time not equal to the transaction clock), EXCLUSIVE_DEFINITE_OVERLAP (same subject, type, partition; both currently recorded; precision-shrunk definite overlap), IMMUTABLE_CONTENT_CONFLICT (stored `contentHash` ≠ proposed hash on a MERGE that matched).
4. **Commit iff the audit returns zero rows**, otherwise roll back and report the rows. POSSIBLE overlaps commit and enqueue a review item (V-509 is the queue).
5. **Supersession** is its own bundle: create the newer record, `SUPERSEDES {supersessionKind, recordedAt: datetime.transaction()}`, then `MATCH (old {uid}) WHERE old.recordedTo IS NULL SET old.recordedTo = datetime.transaction()` and the same on the old edge/episode; zero rows updated ⇒ roll back (the "written once" rule); status projection job sets `status` afterwards from adjudications (V-506 checks agreement).

Result of F11 (run): G1 commit; G2–G6 rolled back with the named violation; nothing of G2–G6 persisted; post-run validation zero rows.

## 5. Identity, ids and timestamps for direct Cypher ingestion

GraphQL autogeneration is API-only: `@id` generates a UUID and removes `id` from mutation inputs; `@timestamp` fields are set "at the GraphQL API layer. Events happening in your database through other routes do not trigger updates" (S-01). Therefore Cypher (and any non-API) ingestion must:

| Property | Requirement |
|---|---|
| `id` | opaque, globally unique (UUID or ULID) generated by the ingestion service (or `randomUUID()` in Cypher); never derived from a name (conventions.liveIdProjection). Document: write both `documentId` and `id` (W00-SR-03). |
| `uid` | `'hu:' + <registered token for the primary label> + ':' + id` (INV-106, V-117); immutable (`@settable(onUpdate: false)` on the API). API-created kernel records cannot satisfy this rule (T5a, W00-SR-02): route kernel creates through the service. |
| `createdAt`, `updatedAt` | `datetime.transaction()` on create (`updatedAt = createdAt`); `updatedAt` refreshed on the single `recordedTo` write. |
| `recordedAt` (assertions, assessments, revision events), `recordedFrom` (episodes) | `datetime.transaction()` of the committing transaction ("the same for each invocation within the same transaction", S-08); never client-supplied; never earlier than the supporting snapshot's `retrievedAt` (V-504). |
| archetype label + discriminator | exactly one archetype label; `entityType`/`stateType`/`occurrenceType`/`artifactType`/`assessmentType` set (non-null in SDL). |
| enum-typed properties | exact SCREAMING_SNAKE contract values: `privacyClass` PUBLIC/INTERNAL (never 'public'); AssessmentStatus never 'FINAL'; `quantityBasis` only catalog per-basis values (spoken "a gram" → `massBasis: UNSPECIFIED`). Wrong spellings break GraphQL reads (T4b). |
| episode properties | `relationshipUid`, `assertionUid`, `recordedFrom`, `validFromBasis`/`validToBasis` (UNKNOWN when the bound is null and unstated) — non-null in the B4 types. |
| DateTime values | zoned DATETIME (`datetime(...)`), not strings or `date()`; UTC first instant of the precision period. |

## 6. Ingestion rules (no schema change)

- Snapshots: `retrievedAt` = fetch time; `observedAt` = when the content was displayed (archive capture time; for a cached capture service, the cache time — W19-SR-15); `contentHashBasis` and `captureCompleteness` required for new captures; synthetic fixtures use SYNTHETIC_FIXTURE.
- Locators: `quoteHash` = sha256 over NFC-WS1(`exact`); IMAGE_REGION writes `mediaAnnotationUid` and the `LOCATES_REGION` edge in the same transaction.
- `canonicalUri`: post-redirect content endpoint; identifier resolvers (doi.org) never become Sources (CL-003 R2).
- QS-7 "not declared in a covering source" requires a COMPLETE capture of a FULL rendition (W19-SR-13); otherwise NOT_FOUND_IN_PARTIAL_CAPTURE.
- Year/month bounds: first UTC instant of the period with its precision; a stated inclusive end year Y is `validTo = Y-01-01` YEAR (D-W00-10).

## 7. Lifecycle, idempotence, migration, overhead

- **Idempotence**: re-running a bundle with the same uids and content is a no-op (MERGE ON CREATE); different content under the same uid is refused (G6). Re-anchoring, re-adjudication and corrections create new nodes linked by REANCHORS/SUPERSEDES.
- **No deletes** of assertions, assessments, snapshots, locators or revision events (API exposes none, T5d); retirement is supersession.
- **Migration order**: (1) backfill `id`/`uid`/timestamps/discriminators and enum spellings (migration-map.yaml), (2) run `operations.cypher`, (3) run V-W00-08/09 to zero, (4) only then add the Enterprise companion.
- **Overhead**: one in-transaction audit query per bundle (a handful of indexed lookups); one subject lock per exclusive attachment; the status projection job writes `status` after adjudications. Adjudication-per-transition volume (round 0007 O-05) is accepted.
- **Runtime prerequisites**: APOC Core for DateTime reads (W00-SR-14). Queries that select the 147-member `AssertionSubjectTarget` unions plan slowly on first execution (10.5 s for T1, 0.16 s warm, 1.5 GB heap): warm the Cypher plan cache with the published query shapes at start-up, size the heap explicitly, and re-time after Fable prunes the union.
