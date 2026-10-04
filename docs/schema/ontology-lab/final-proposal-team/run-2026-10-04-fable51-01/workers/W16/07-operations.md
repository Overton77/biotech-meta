# W16 operations recommendation

Target: Neo4j **5.26.31 Community** (tested), `@neo4j/graphql` 7.6.3. Enterprise behaviour is not verified. Companion file: `operations.cypher` (30 Community statements executed OK on the embedded instance on 2026-10-04; 10 Enterprise-only statements commented, not executed).

## 1. Uniqueness and indexes (stored property names)

| Need | Statement(s) | Edition | Why |
|---|---|---|---|
| uid and live id unique per W16 label (10 labels × 2) | `REQUIRE n.uid IS UNIQUE`, `REQUIRE n.id IS UNIQUE` | Community | INV-001, INV-106; MERGE-by-uid idempotence |
| one episode per relationshipUid | `FOR ()-[r:HAS_PROTOCOL_EDITION]-() REQUIRE r.relationshipUid IS UNIQUE` | Community (relationship uniqueness, 5.7+) | asserted_edge profile |
| step lineage and payload lookup | range indexes `ProtocolStep(stepKey)`, `ProtocolStep(payloadHash)`, `ProtocolEdition(payloadHash)`, `ProtocolStep(requirementLevel)` | Community | CQ-PR-01 diff, edition dedupe, CQ-PR-02 filters |
| episode and dependency filters | relationship range indexes `HAS_PROTOCOL_EDITION(recordedTo)`, `(assertionUid)`, `DEPENDS_ON(dependencyKind)`, `HAS_CONSTRAINT(constraintRole)` | Community | as-of reads (QS-2b), V-528p/531p, V-525p |
| live fulltext retained | `CREATE FULLTEXT INDEX ProtocolSearch … ON EACH [n.name, n.description, n.searchText]` (query name `searchProtocols` from SDL) | Community | D-015 |
| existence/type of required fields (`stepKey`, `payloadHash`, `changeProvenance`, `dependencyKind`, `constraintRole`, `assertionUid`, `recordedFrom`, integer ranges) | property existence/type constraints | **Enterprise only** (Community rejects; same as the 12 baseline rejections) | on Community these are application validation (below) plus V-5xx detectors |

Vector retrieval: `Protocol.searchEmbedding` only if Fable keeps `@vector` (D-014): justification = semantic lookup of protocols by description for agent queries; dimensions recorded per index in the final operations file; no provider in SDL. No vector index on steps or observations (no CQ).

## 2. Retrieval patterns

| Pattern | Shape | Cost note |
|---|---|---|
| Current steps of a protocol | `Protocol.currentSteps` (derived edge) or QS-2b on HAS_PROTOCOL_EDITION then HAS_PROTOCOL_STEP | derived edge avoids as-of evaluation for live readers |
| Edition diff (CQ-PR-01) | Q-W16-01 (two editions, step maps by stepKey; capture completeness from authorizing assertion's snapshot) | O(steps); indexed by uid |
| Labelled change history | Q-W16-02c (editions + non-edition assertions about the protocol; asserter vs author) | needs AUTHORED_PROTOCOL assertion |
| Conditional evaluation | Q-W16-04b shape run **in the private store** against shared constraint uids | shared graph only serves the CNF structure (Q-W16-04a/e) |
| Due windows | Q-W16-10b | pure date arithmetic on plan ranges |
| Subprotocol/material binding | Q-W16-13 / Q-W16-08a (as-of over HAS_PROTOCOL_EDITION / HAS_FORMULATION_VERSION) | as-of instant = edition snapshot observedAt unless the caller supplies V |
| Leak defence in depth | QS-6a from any protocol node | public API never queries the private store |

## 3. Application validation (service-enforced; Community has no existence constraints)

1. **Edition creation transaction** (one write transaction): canonicalize payload (W16-CANON-1), compute step hashes and edition `payloadHash`; if an edition with the same (protocol, payloadHash, canonicalization version) exists, reuse it (idempotent) and only add a new observation locator; otherwise create edition + new step nodes (reusing unchanged step nodes only when their dependency closure is unchanged) + HAS_PROTOCOL_STEP edges + the authorizing Assertion + the HAS_PROTOCOL_EDITION episode (copying valid bounds, `recordedFrom` = commit time) + close the previous episode's `recordedTo` only for corrections (round 0007), + regenerate `HAS_CURRENT_PROTOCOL_STEP`.
2. **Concurrency**: serialize writers per Protocol uid (take a write lock on the Protocol node, e.g. `SET p._lock = null` pattern or a service mutex) so two captures of the same page cannot create overlapping EXCLUSIVE episodes; DEFINITE overlaps are refused (V-508), POSSIBLE overlaps go to review (V-509; expected for SNAPSHOT_DIFF editions with unknown change instants).
3. **Immutability**: no update of edition or step properties after attachment except `recordedTo` on episodes; GraphQL mutations on W16 payload types are restricted to the ingestion service (Fable may use `@mutation(operations: [])` on payload types at merge).
4. **Field rules**: `requirementLevel`, `requirementBasis`, `stepKey`, `payloadHash`, `changeProvenance` non-null (SDL `!`); `dependencyKind`, `constraintRole` required; ranges ordered (V-529p); unit with every value (V-529p, V-537p, V-541p); `quantityBasis` with every quantity; `policyVersionUid` iff BELLLABS_SAFETY_POLICY (V-533p); THIRD_PARTY_REPORTED never on editions (V-530p); ordering kinds acyclic (V-528p); dependencies stay inside the edition (V-527p).
5. **Privacy**: reject writes of any `hu:private-` value or private label (V-113, V-520, V-521, V-524); reject execution keys/edges on protocol records (V-534p); Observations need attribution (V-532p).
6. **Normalization overhead**: schedule normalizer (text → ranges + units, always keeping verbatim), UCUM unit normalizer, stepKey aligner (W16-STEPKEY-1, human review for ambiguous alignments), constraint splitter (one Constraint per atomic condition, OR groups). Expect per-edition human review for SNAPSHOT_DIFF pages until the aligner is calibrated (OPEN-QUESTIONS P2 item 4).

## 4. Lifecycle, idempotence, migration

- **Idempotence**: all writes MERGE by `uid`; edition reuse by payload hash; re-running a capture adds a SourceSnapshot/locator, not an edition.
- **Lifecycle**: editions are never deleted; a withdrawn page ends the current episode with `validTo` only when the source states it (else `OPEN_END_STALE` at read time). Steps/constraints are never edited.
- **Migration** (live → final, see `migration-map.yaml`): per live Protocol create one ProtocolEdition from its current fields (SNAPSHOT_DIFF unless `versionLabel` set), relabel `HAS_STEP` (Protocol→Step) to `HAS_PROTOCOL_STEP` (Edition→Step), backfill `stepKey` (slug of name) and `payloadHash`, set `requirementLevel` from `isOptional` (false → NOT_STATED), set `dependencyKind` default with EDITORIAL_INFERENCE, and create MIGRATION assertions for every edge that becomes asserted (HAS_PROTOCOL_EDITION, HAS_FUNCTIONAL_GOAL, FOR_PROTOCOL, CLAIMS_OUTCOME, ABOUT_CONDITION, RECORDS, POSTS_RESULT). Observations lacking public attribution are quarantined, not migrated (CL-018). Compatibility: `Protocol.hasSteps` readers switch to `currentSteps`; enum names unchanged; union renames are breaking for clients that name the union types in fragments.
- **Capability conditions**: relationship property indexes and relationship uniqueness require 5.7+ (present in 5.26); quantified path patterns used by QS-6a/Q-W16-07a require 5.9+; the `IS :: STRING` type predicate in V-521 requires 5.x; property existence/type constraints and node keys require Enterprise.
