# W20 07 Operations recommendation

Executable companion: `operations.cypher` (part A run on Neo4j 5.26.31 Community: 15 DDL statements applied; part B Enterprise-only, commented, unverified; part C validators, run). No runtime implementation is proposed.

## 1. Uniqueness and indexes (stored property names)

| Need | Statement (part A) | Edition | Why |
|---|---|---|---|
| uid unique per label | `Document.uid`, `DocumentTextVersion.uid`, `Segmentation.uid`, `Chunk.uid` | Community | INV-001; per-label because archetype-label constraints arrive with D-001 backfill |
| live id unique | `Document.documentId`, `DocumentTextVersion.documentTextVersionId`, `Segmentation.segmentationId`, `Chunk.chunkId` | Community | the `@alias` stored names; a constraint on `id` would cover nothing for these four types |
| endpoint unique | `Source.canonicalUri` (W00) | Community | covers Document because it carries `Source` |
| lookup | range indexes `Chunk.segmentationHash`, `Segmentation.segmentationHash`, `DocumentTextVersion.textVersionHash`, `Document.type`, `SourceLocator.quoteHash` (requested from W00) | Community | regeneration by hash, idempotent MERGE of text versions, facet filter, cross-rendition join (Q04-a) |
| fulltext | `DocumentSearch` on `[title, url, searchText]`; `ChunkSearch` on `[text, searchText]` | Community | D-015; the library never creates them; run evidence: GraphQL-named index returns 0 hits silently |
| existence / type | `Chunk.text`, `DocumentTextVersion.textVersionHash` NOT NULL / `:: STRING`; `RESOLVES_TO_CHUNK.segmentationHash`, `SUPPORTED_BY_CHUNK.locatorUid`, `SUPPORTED_BY_DOCUMENT.locatorUid` NOT NULL | **Enterprise only** (part B) | on Community these are validators W20-V01, W20-V02 and V-408 |

Verification step for Fable: after creating indexes, call `new Neo4jGraphQL({typeDefs, driver}).assertIndexesAndConstraints()`; in 7.6.3 it resolves `@fulltext` fields to stored alias names and fails on `name`/`sourceUrl` (run). It checks indexes **by name only** (not by label), so V-120's label check is still needed.

## 2. Retrieval patterns and partitions

- **Lexical**: `searchDocuments` / `searchChunks` (generated queries kept) or `db.index.fulltext.queryNodes`. A hit is a candidate (QS-8); scores are index-local. Fulltext indexes are eventually consistent: never a read-your-write check.
- **Semantic** (`@vector`, added by Fable without provider): justification: chunk-level semantic recall over long transcripts and articles where lexical match fails (paraphrased claims, e.g. "a gram of NMN" vs "1000 mg NMN"). Embeddings are computed outside the API from public fields named in `searchFields`; `embeddingModel` and `embeddingDimensions` recorded (V-119). Neo4j 5.26 vector search has no in-index property filter: filter after the query and over-fetch (k × partition factor). Run: index creation and query work on Community.
- **Partitions** (query-time filters, no schema field): (1) `privacyClass = PUBLIC` for public tiers, INTERNAL excluded; (2) active segmentation set `$activeSegmentationHashes` (deployment configuration per index) so two segmentations never both answer; (3) capture recency: prefer the text version of the latest snapshot per Source, keep older captures for as-of answers; (4) facets `Document.type`, `sourceKind`, `documentDomain`, `languageCode`.
- **From hit to evidence**: chunk → `RESOLVES_TO_CHUNK` (in) → locator → `SUPPORTED_BY` (in) → assertion; or chunk → `SUPPORTED_BY_CHUNK` (in) and then **re-read the locator by `locatorUid`**. Answers cite the locator and snapshot, never the chunk. Deduplicate near-identical chunks across captures/renditions by Source and quoteHash (vector run: g2-c0 and g3-c0 both score > 0.98).

## 3. Application validation (service-enforced; Community has no property-existence constraints)

1. Text version write: compute `textVersionHash` over the exact stored text; set `contentHash` equal; exactly one `TEXT_OF_SNAPSHOT`; `HAS_TEXT_VERSION` from the Source owning that snapshot; `WAS_GENERATED_BY` an Activity with `methodVersion`.
2. Locator write: offsets in code points of the stored text (convert UTF-16 offsets); verify `substring(text, start, end-start) = exact` (W20-V03); `quoteHash = sha256(NFC-WS1(exact))` computed in the service (Community Cypher has no sha256 function).
3. Segmentation write: compute `segmentationHash` over canonical JSON of the configuration; chunks with `charStart/charEnd`, `text` equal to the span (W20-V06), `segmentationHash`, `FROM_TEXT_VERSION`, `NEXT_CHUNK` chain.
4. Derivation: `RESOLVES_TO_CHUNK` for every locator in the text version whose span overlaps a chunk; then `SUPPORTED_BY_CHUNK` for every assertion `SUPPORTED_BY` such a locator; `SUPPORTED_BY_DOCUMENT` likewise per Document. Never from a retrieval score (forbidden CHUNK_MATCH → SOURCE_SUPPORT).
5. Document write: set `documentId`, `title`, `url` = `canonicalUri`, `type`, `entityType`, `createdAt`, `updatedAt` (Cypher writers do not get `@timestamp` or `@id`).

## 4. Transactions, concurrency, idempotence

- One transaction per (text version, segmentation configuration): create Segmentation + chunks + NEXT_CHUNK + derived edges, then (separately) delete the superseded segmentation's chunks. Create-then-delete keeps retrieval available; readers filter by `$activeSegmentationHashes`, so the brief overlap is invisible.
- Idempotence: MERGE text versions by uid derived from (snapshot uid, methodVersion, textVersionHash), segmentations by (text version uid, segmentationHash), chunks by (text version uid, segmentationHash, index) (W20-SR-09); re-running produces no duplicates. With random UUIDs, a lookup on (`textVersionHash`) and (`segmentationHash`, `index`, text version) must precede every write.
- Snapshots, text versions and locators are insert-only. Concurrent re-anchoring of one locator by two runs: both may create successors; `REANCHORS` from both is acceptable (two successor locators), adjudication picks the one an assertion uses (W20-SR-06).
- Derived edges carry `derivedAt` and `activityUid`; a re-derivation replaces edges of the same type, start, end and segmentationHash.

## 5. Lifecycle and migration

- Migration order (from `migration-map.yaml`): (1) backfill labels (`Source`, `Entity`, `InformationArtifact`) and `uid`; (2) backfill `TEXT_OF_SNAPSHOT` (snapshot `captureCompleteness: UNKNOWN`, `contentHashBasis: NORMALIZED_TEXT` when only stored text exists); (3) create Activities from `DocumentTextVersion.source` and `mongoResearchRunId`; (4) backfill `charStart/charEnd`; (5) convert support edges: create locators from `quoteSpan`, set `locatorUid`/`derivedFromAssertionUids`, relabel `SUPPORTED_BY → Chunk` to `SUPPORTED_BY_CHUNK`; rows without an assertion become `MENTIONS` or are reported; (6) delete `PREV_CHUNK` after verifying `NEXT_CHUNK` coverage; (7) rewrite `HAS_TRANSCRIPT` and `SOURCE_OF`; (8) run W20-V01…V10 and V-401…V-409 until zero rows (W20-V08 tracks progress).
- Compatibility: GraphQL field names on W20 types are unchanged; `name`, `documentKey`, `source` become nullable (non-breaking for writers, noted for strict clients); `isPrimarySource`, `hasChunks`, `assertsClaims`, `resolvedFromLocators`, `inEpisodeSegments`, `documents` are read-only; `sourceForEpisodes` becomes `renditionOfEpisodes`; `Episode.hasTranscriptVersions` disappears (W21).

## 6. Ingestion and normalization overhead

- Storing full `text` on text versions: one copy per extractor per capture (fixture 04: three copies of one article). Large texts can move to `storageUri` later; offsets then require fetching the stored blob (not proposed now).
- Chunk count ≈ text length / (chunkSize − overlap) per active segmentation; each re-segmentation rewrites all chunks and derived edges for that text version, never locators.
- Hashing: sha256 per text version, per chunk, per locator quote; NFC-WS1 per quote only.

## 7. Capability and edition conditions

- Verified on 5.26.31 Community: uniqueness constraints, range/fulltext/vector index creation, vector query, Cypher code-point string semantics (`size`, `substring`), `normalize(…, NFKC)`.
- Unverified: Enterprise existence/type constraints (part B); behaviour on 5.26 minors other than .31; fulltext analyzer choice (default `standard-no-stop-words` assumed, not configured).
