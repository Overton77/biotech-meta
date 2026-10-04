# W22 operations recommendation

Target: Neo4j **5.26** (tested on 5.26.31 Community, embedded), `@neo4j/graphql` 7.6.3. No runtime implementation is proposed. The DDL is in `operations.cypher`, and execution results are in section 6.

## 1. Uniqueness and indexes (stored property names)

- **uid uniqueness** for every W22 node is already enforced by the archetype constraints in `docs/schema/neo4j/constraints.cypher` (`InformationArtifact`, `VersionedState`, `EvidenceAssessment` `uid IS UNIQUE`), because D-001 stores archetype labels. No per-label uid constraint is added.
- **A-1** `id` uniqueness per media label backs GraphQL `where: {id}` lookups. 7.6.3 has no `@unique`, so uniqueness exists only as Cypher constraints.
- **A-2** `contentHash` range indexes on MediaVariant, MediaAsset and SourceSnapshot serve the equality joins in MEDIA-EV-1, V-602, Q-MP5-1, Q-MP6-1 and ingestion dedup. **Not unique**: the same bytes can legitimately be two renditions of two assets, for example a Reactome diagram re-hosted on Commons, until an EquivalenceAssessment merges them.
- **A-3** composite index (`perceptualHashAlgorithm`, `perceptualHash`) supports exact-value candidate lookup only. Hamming-distance near-duplicate search runs outside the database, and a match is a hint, never identity (forbidden implication).
- **A-4/A-5** support selection and validation filters: `variantKind`, `generationMode`, `SourceLocator.mediaAnnotationUid`, assessment (`dimension`, `intendedRole`, `status`), `methodVersion`, `rightsStatus`.
- **A-6** relationship property indexes on `assertionUid` for the five asserted media edges (capture-fidelity review, V-612), plus `DEPICTS.relationshipUid` and `EVIDENCES.derivationRule` (regeneration).
- **A-7** full-text `MediaAssetSearch` and `GraphViewSearch`, with names and fields kept from the live schema (D-015).
- **Section B (Enterprise only):** existence and type constraints for `variantKind`, `assetType`, `annotationType`, assessment `methodVersion`/`dimension`, rights `rightsStatus`/`payloadHash`, `widthPx :: INTEGER`, `x :: FLOAT`, and `assertionUid` existence on DEPICTS, EXPLAINS and HAS_RIGHTS_RECORD. Community rejects them, so the service must validate the same rules on write in every edition.

**R-3 (vector retrieval justification, for Fable per D-014):** a `MediaAssetSearchEmbedding` vector index over embeddings of `caption`/`altText`/`ocrText`/`title` is justified for concept-to-illustration retrieval (CQ-MD-C02: "find candidate explainers for Mechanism K"), where lexical search misses paraphrased captions. The embedding is a candidate generator only: selection still requires EXPLAINS/DEPICTS assertions, rights and assessments. No `provider:` is configured, embeddings are computed outside the API, and the dimension is recorded per index in the operations file when an embedding model is chosen. A vector index on GraphView is **not** justified (views are found by type and subject).

## 2. Retrieval patterns

| Pattern | Anchor | Bounded traversal |
|---|---|---|
| Asset selection for subject S and role R (Q-MP1-1, Q-MP2-1, Q-MP4-1) | S uid | ←DEPICTS/EXPLAINS (current episodes) → rights (current episodes) → assessments (dimension, role, non-legacy, not superseded); O(assets of S) |
| Evidence images for an assertion or mechanism (Q-MP3-1) | assertion / mechanism uid | SUPPORTED_BY → IMAGE_REGION locator → LOCATES_REGION → annotation ← rendition ← asset; snapshot via HAS_LOCATOR; 6 hops, fixed |
| Crop / edit lineage (Q-MP5-1, Q-MP6-1) | rendition uid | WAS_GENERATED_BY → Activity → USED → parent rendition + annotation → locator → snapshot → Source |
| Rights explanation (Q-MP1-3) | asset uid | HAS_RIGHTS_RECORD → record; edge.assertionUid → Assertion → SUPPORTED_BY → locator → snapshot |
| Display audit (Q-MP4-3, V-608) | Activity kind ANSWER_COMPOSITION | USED → rendition → asset; AUTHORIZED_BY |

Selection results are **computed per request**, never stored as a "best image" flag. A cache, if one is used, is keyed by (subject, role, policy version, recorded-as-of) and invalidated when any rights episode, assessment or depiction episode for the subject changes.

## 3. Application validation (service-enforced; Neo4j cannot express these)

1. **On media ingestion:** hash raw bytes (sha256) before anything else. Write `contentHash` on the rendition and on the SourceSnapshot of the file URL, and set `contentHashBasis: RAW_BYTES` only when BellLabs hashed the bytes. A host-stated checksum goes in `statedChecksum`.
2. Exactly one ORIGINAL rendition per asset with bytes, and `asset.contentHash` = ORIGINAL hash (V-611).
3. Every non-ORIGINAL rendition is written in the same transaction as its generating Activity (CAPTURE for publisher renditions; MEDIA_TRANSFORMATION with USED parent and, for crops, USED annotation) (V-607, V-614).
4. A MediaAnnotation is written with exactly one HAS_ANNOTATION parent rendition and a registered `normalizationVersion` when it is meant to back a locator. The IMAGE_REGION SourceLocator is written in the same transaction as `LOCATES_REGION` and `mediaAnnotationUid` (V-601). Byte equality of rendition and snapshot is checked on write (V-602), and the rendition is ORIGINAL (V-606).
5. Asserted media edges (DEPICTS, EXPLAINS, VISUALIZES, ANNOTATES_SUBJECT, HAS_RIGHTS_RECORD) are written only together with their Assertion (predicate = type, subject, object) in one transaction (V-612). A belief change is a new episode, never an edit (TM-R1).
6. EVIDENCES, INCLUDES_SUBJECT and ABOUT_PRODUCT are written only by their derivation jobs. GraphQL exposes them read-only (`@settable(onCreate:false,onUpdate:false)`, verified in the 7.6.3 build: no `evidences` field in `MediaAssetCreateInput`). Regeneration is idempotent with `MERGE` on (start, end, derivationRule) (V-604, V-605).
7. Suitability assessments: one dimension per node, `methodVersion` + Activity required, immutable, re-assessed via SUPERSEDES. `legacy-unsourced` is never ACCEPTED (V-609).
8. Rights: a rights record is immutable. Terms changes create a new record and close the old attachment episode (`validTo`, SUPERSEDES VALIDITY_BOUNDED on its Assertion). Booleans the statement does not mention stay null. No default `OPEN_LICENSE`.
9. Display: any Activity that USED a media node for display carries `AUTHORIZED_BY {useKind: DISPLAY_MEDIA}` (V-608, after W22-SR-02). Displays whose rights records are not permitting need a recorded policy or legal decision (V-608b; W23).
10. Privacy: no private-personal content in media nodes. Images of identifiable private individuals are not ingested into the shared graph (user uploads go to the private store, W23). Personal contact data found in source records (e.g. repository author e-mails) is not copied.

## 4. Transactions and concurrency

- One asset ingestion transaction contains: Source + SourceSnapshot (file), WHOLE_SNAPSHOT locator, MediaAsset, ORIGINAL MediaVariant, DERIVED_FROM_SOURCE, the CAPTURE Activity links, and optionally the DEPICTS Assertion + edge. Rights records and assessments are separate transactions (other activities, other times).
- Concurrent ingestion of the same bytes from two URLs: the contentHash lookup (A-2) runs inside the write transaction. Because the hash index is not unique, the service takes an application lock keyed by `contentHash` (or retries on a dedup check) so it does not create two ORIGINAL renditions with the same hash on the same asset. Different assets with the same bytes are allowed and flagged for EquivalenceAssessment.
- Derivation jobs (MEDIA-EV-1, LABEL-REGION-PRODUCT-1, GRAPHVIEW-INCLUDE-1) run after commit, are idempotent, and re-run when an input assertion is superseded. A derived edge whose input assertion is superseded is deleted and regenerated, never edited.

## 5. Capability, edition, lifecycle, migration, overhead

| Concern | Recommendation |
|---|---|
| Edition | Community: Section A only; Section B rules are service-enforced. Enterprise: Section B too (unverified here; no Enterprise available). |
| 5.26 minor | Relationship property indexes and `IS ::` type constraints are 5.x syntax. The `FULLTEXT ... ON EACH` form and composite range indexes ran on 5.26.31 (section 6). |
| Idempotence | Every fixture statement uses MERGE on `uid` and on relationship identity properties. Verified by loading MP1-MP6 twice into one store: 0 errors; nodes stable at 226; relationships 424 → 426. The +2 are **not duplicates** (no (start, type, end) appears twice). They are two new `EVIDENCES` edges created by the global MEDIA-EV-1 job inside MP3 on the second pass, because MP5's `LABEL_FOR` and `HAS_VARIANT` assertions, supported by the IMAGE_REGION locator on the ORIGINAL Supplement Facts rendition, exist only after pass 1. This is the intended behaviour of a regenerable derivation: production runs derivation jobs after every load, not inside a fixture. |
| Lifecycle | Renditions can be garbage-collected (thumbnail regeneration) only if no MediaAnnotation or locator references them. ORIGINAL renditions referenced by an IMAGE_REGION locator are never deleted (CQ-PV-02). Takedown of an asset for rights reasons removes `storageUri` bytes and keeps the node, hashes, rights record and history. |
| Migration | `migration-map.yaml` (152 rows). Order: (1) relabel archetypes and backfill uids; (2) create ORIGINAL renditions from asset byte fields; (3) re-home annotations to ORIGINAL; (4) convert MediaSource rows into Source/Snapshot/Locator; (5) create Assertions for DEPICTS/EXPLAINS/VISUALIZES/ANNOTATES_SUBJECT edges (status EXTRACTED); (6) move licence strings into rights records (status EXTRACTED, no locator until re-captured); (7) move scores into `legacy-unsourced` assessments; (8) delete retired properties and edges; (9) run V-601…V-615 and the kernel suite. Live `EVIDENCES`/`SUPPORTS_CLAIM*` edges are not migrated as EVIDENCES. They become a curator review queue. |
| Compatibility | GraphQL field changes: `MediaAsset.sources` → `sourceLocators`; `variants` relationship type renamed; byte fields moved to `variants`; rights and score fields removed. Clients must change. `name` becomes nullable (D-013). |
| Ingestion overhead | Per asset with one subject: about 8 nodes (Source, Snapshot, Locator, Asset, ORIGINAL, Assertion, Adjudication on review, Activity link) and about 12 relationships, against 2-3 nodes in the live model. Rights add 1 record + 1 Assertion per stated offer (records are shared across assets with the same site terms: one Elysium terms record served two assets in MP1). Assessments add 1 node per dimension × role actually assessed (no blanket scoring). The fixtures' combined load (6 minimal pairs, 15 assets) is 226 nodes and 424 relationships, kernel records included. |
| Byte capture | Raw-byte hashing requires fetching image files. In this session the egress proxy blocked direct fetches, so every hash is synthetic. Production capture needs an allowed egress path and must respect site terms on automated access, a W23 policy question for Elysium-type terms (S11). |

## 6. Execution of operations.cypher (2026-10-04, 5.26.31 Community, fresh store)

Sequence: `docs/schema/neo4j/constraints.cypher` (baseline), then `operations.cypher`, then MP1-MP6 under the constraints. Results are recorded in `08-completion-report.md` section 3 (Section A statements applied; Section B rejected on Community as expected; fixtures loaded under constraints without uniqueness violations).
