// W20 operations recommendation (Documents, text versions, chunks). Run: run-2026-10-04-fable51-01.
// Target: Neo4j 5.26.x. Part A runs on Community (executed on 5.26.31 Community, see 06-fixtures-and-queries.md).
// Part B lists Enterprise-only statements as comments. Part C holds W20 candidate validators (zero rows = valid).
// Stored property names only (D-015): Document.title/url/type/documentId, Chunk.chunkId/chunkKey/index,
// Segmentation.segmentationId/strategy, DocumentTextVersion.documentTextVersionId.

// ===================== A. Community-compatible constraints and indexes =====================
CREATE CONSTRAINT w20_document_uid IF NOT EXISTS FOR (n:Document) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w20_document_live_id IF NOT EXISTS FOR (n:Document) REQUIRE n.documentId IS UNIQUE;
CREATE CONSTRAINT w20_text_version_uid IF NOT EXISTS FOR (n:DocumentTextVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w20_text_version_live_id IF NOT EXISTS FOR (n:DocumentTextVersion) REQUIRE n.documentTextVersionId IS UNIQUE;
CREATE CONSTRAINT w20_segmentation_uid IF NOT EXISTS FOR (n:Segmentation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w20_segmentation_live_id IF NOT EXISTS FOR (n:Segmentation) REQUIRE n.segmentationId IS UNIQUE;
CREATE CONSTRAINT w20_chunk_uid IF NOT EXISTS FOR (n:Chunk) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w20_chunk_live_id IF NOT EXISTS FOR (n:Chunk) REQUIRE n.chunkId IS UNIQUE;
// Source.canonicalUri uniqueness is W00's constraint; it covers Document nodes because they carry the Source label.

// Retrieval and derivation lookups (range indexes)
CREATE INDEX w20_chunk_segmentation_hash IF NOT EXISTS FOR (n:Chunk) ON (n.segmentationHash);
CREATE INDEX w20_segmentation_hash IF NOT EXISTS FOR (n:Segmentation) ON (n.segmentationHash);
CREATE INDEX w20_text_version_hash IF NOT EXISTS FOR (n:DocumentTextVersion) ON (n.textVersionHash);
CREATE INDEX w20_document_type IF NOT EXISTS FOR (n:Document) ON (n.type);
// Requested from W00 (W20-SR-07): cross-rendition span alignment joins on quoteHash.
CREATE INDEX w20_locator_quote_hash IF NOT EXISTS FOR (n:SourceLocator) ON (n.quoteHash);

// Fulltext indexes required by the retained live @fulltext directives (names and queries unchanged; stored names).
// @neo4j/graphql 7.6.3 assertIndexesAndConstraints() resolves each directive field to its stored (alias) name and
// requires that name in the index: DocumentSearch must contain title and url, not name and sourceUrl.
CREATE FULLTEXT INDEX DocumentSearch IF NOT EXISTS FOR (n:Document) ON EACH [n.title, n.url, n.searchText];
CREATE FULLTEXT INDEX ChunkSearch IF NOT EXISTS FOR (n:Chunk) ON EACH [n.text, n.searchText];

// ===================== B. Enterprise-only (unverified here; Community rejects them) =====================
// CREATE CONSTRAINT w20_chunk_text_exists IF NOT EXISTS FOR (n:Chunk) REQUIRE n.text IS NOT NULL;
// CREATE CONSTRAINT w20_tv_hash_exists IF NOT EXISTS FOR (n:DocumentTextVersion) REQUIRE n.textVersionHash IS NOT NULL;
// CREATE CONSTRAINT w20_tv_hash_type IF NOT EXISTS FOR (n:DocumentTextVersion) REQUIRE n.textVersionHash IS :: STRING;
// CREATE CONSTRAINT w20_resolves_seg_exists IF NOT EXISTS FOR ()-[r:RESOLVES_TO_CHUNK]-() REQUIRE r.segmentationHash IS NOT NULL;
// CREATE CONSTRAINT w20_support_chunk_locator_exists IF NOT EXISTS FOR ()-[r:SUPPORTED_BY_CHUNK]-() REQUIRE r.locatorUid IS NOT NULL;
// CREATE CONSTRAINT w20_support_doc_locator_exists IF NOT EXISTS FOR ()-[r:SUPPORTED_BY_DOCUMENT]-() REQUIRE r.locatorUid IS NOT NULL;

// Vector index template (Fable adds @vector at merge, D-014). Dimensions are a deployment fact, recorded per index;
// the literal below is the fixture's test value, not a recommendation.
// CREATE VECTOR INDEX ChunkSearchEmbedding IF NOT EXISTS FOR (n:Chunk) ON (n.searchEmbedding)
//   OPTIONS {indexConfig: {`vector.dimensions`: 4, `vector.similarity_function`: 'cosine'}};

// ===================== C. W20 candidate validators (zero rows = valid) =====================

// W20-V01 (extends V-407 to every start label and to SUPPORTED_BY_CHUNK; INV-404, forbidden CHUNK_MATCH -> SOURCE_SUPPORT):
// a chunk support shortcut must name a locator that an input assertion is SUPPORTED_BY and that RESOLVES_TO_CHUNK this
// chunk under the same segmentationHash. The legacy relationship type SUPPORTED_BY -> Chunk is reported until migrated.
MATCH (x)-[r:SUPPORTED_BY|SUPPORTED_BY_CHUNK]->(c:Chunk)
OPTIONAL MATCH (l:SourceLocator {uid: r.locatorUid})
WITH x, r, c, l,
     [v IN [
        CASE WHEN type(r) = 'SUPPORTED_BY' THEN 'LEGACY_SUPPORTED_BY_TO_CHUNK' END,
        CASE WHEN r.locatorUid IS NULL THEN 'NO_LOCATOR_UID' END,
        CASE WHEN r.locatorUid IS NOT NULL AND l IS NULL THEN 'LOCATOR_MISSING' END,
        CASE WHEN r.derivationRule IS NULL THEN 'NO_DERIVATION_RULE' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (l)-[rr:RESOLVES_TO_CHUNK]->(c) WHERE rr.segmentationHash = r.segmentationHash }
             THEN 'LOCATOR_DOES_NOT_RESOLVE_TO_CHUNK' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (sa:Assertion)-[:SUPPORTED_BY]->(l) WHERE sa.uid IN coalesce(r.derivedFromAssertionUids, []) }
             THEN 'NO_INPUT_ASSERTION_SUPPORTED_BY_LOCATOR' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'W20-V01' AS check, type(r) AS relType, x.uid AS startUid, labels(x)[0] AS startLabel, c.uid AS chunkUid, violations
ORDER BY startUid, chunkUid;

// W20-V02: a document support shortcut names a locator inside one of that document's snapshots and an input assertion.
MATCH (x)-[r:SUPPORTED_BY_DOCUMENT]->(d:Document)
OPTIONAL MATCH (l:SourceLocator {uid: r.locatorUid})
WITH x, r, d, l,
     [v IN [
        CASE WHEN r.locatorUid IS NULL THEN 'NO_LOCATOR_UID' END,
        CASE WHEN r.locatorUid IS NOT NULL AND l IS NULL THEN 'LOCATOR_MISSING' END,
        CASE WHEN r.derivationRule IS NULL THEN 'NO_DERIVATION_RULE' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS { MATCH (d)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l) }
             THEN 'LOCATOR_NOT_IN_DOCUMENT_SNAPSHOT' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (sa:Assertion)-[:SUPPORTED_BY]->(l) WHERE sa.uid IN coalesce(r.derivedFromAssertionUids, []) }
             THEN 'NO_INPUT_ASSERTION_SUPPORTED_BY_LOCATOR' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'W20-V02' AS check, x.uid AS startUid, labels(x)[0] AS startLabel, d.uid AS documentUid, violations
ORDER BY startUid;

// W20-V03: TEXT_POSITION offsets reproduce exact in the bound text version (Cypher counts Unicode code points, the
// same unit as the contract; a UTF-16 writer drifts by one per astral character).
MATCH (l:SourceLocator)-[:LOCATOR_IN_TEXT_VERSION]->(tv:DocumentTextVersion)
WHERE l.startOffset IS NOT NULL AND l.endOffset IS NOT NULL AND tv.text IS NOT NULL
  AND (l.startOffset < 0 OR l.endOffset > size(tv.text) OR l.endOffset < l.startOffset
       OR substring(tv.text, l.startOffset, l.endOffset - l.startOffset) <> l.exact)
RETURN 'W20-V03' AS check, l.uid AS locatorUid, tv.uid AS textVersionUid, l.startOffset AS startOffset, l.endOffset AS endOffset
ORDER BY locatorUid;

// W20-V04: alias drift. Properties written under GraphQL field names are invisible to the API and to the indexes;
// missing stored id/alias properties break reads of non-null fields.
MATCH (n)
WHERE n:Document OR n:Chunk OR n:Segmentation OR n:DocumentTextVersion
WITH n, [f IN [
   CASE WHEN n:Document AND n.documentType IS NOT NULL THEN 'Document.documentType_stored_literally(use type)' END,
   CASE WHEN n:Document AND n.sourceUrl IS NOT NULL THEN 'Document.sourceUrl_stored_literally(use url)' END,
   CASE WHEN n:Document AND n.name IS NOT NULL THEN 'Document.name_stored_literally(use title)' END,
   CASE WHEN n:Document AND n.documentId IS NULL THEN 'Document.documentId_missing' END,
   CASE WHEN n:Document AND n.type IS NULL THEN 'Document.type_missing(non-null documentType)' END,
   CASE WHEN n:Chunk AND n.chunkIndex IS NOT NULL THEN 'Chunk.chunkIndex_stored_literally(use index)' END,
   CASE WHEN n:Chunk AND (n.chunkId IS NULL OR n.index IS NULL) THEN 'Chunk.chunkId_or_index_missing' END,
   CASE WHEN n:Segmentation AND n.segmentationStrategy IS NOT NULL THEN 'Segmentation.segmentationStrategy_stored_literally(use strategy)' END,
   CASE WHEN n:Segmentation AND (n.segmentationId IS NULL OR n.strategy IS NULL) THEN 'Segmentation.segmentationId_or_strategy_missing' END,
   CASE WHEN n:DocumentTextVersion AND n.documentTextVersionId IS NULL THEN 'DocumentTextVersion.documentTextVersionId_missing' END
 ] WHERE f IS NOT NULL] AS findings
WHERE size(findings) > 0
RETURN 'W20-V04' AS check, n.uid AS uid, labels(n) AS labels, findings
ORDER BY uid;

// W20-V05: a Document (a Source) keeps url equal to canonicalUri.
MATCH (d:Document)
WHERE (d.url IS NOT NULL OR d.canonicalUri IS NOT NULL) AND coalesce(d.url, '') <> coalesce(d.canonicalUri, '')
RETURN 'W20-V05' AS check, d.uid AS documentUid, d.url AS url, d.canonicalUri AS canonicalUri;

// W20-V06: a chunk's text is exactly its span of the text version.
MATCH (c:Chunk)-[:FROM_TEXT_VERSION]->(tv:DocumentTextVersion)
WHERE c.charStart IS NOT NULL AND c.charEnd IS NOT NULL
  AND (c.charEnd > size(tv.text) OR substring(tv.text, c.charStart, c.charEnd - c.charStart) <> c.text)
RETURN 'W20-V06' AS check, c.uid AS chunkUid, tv.uid AS textVersionUid;

// W20-V07: chunk lineage: exactly one text version, a segmentationHash, and a Segmentation of that text version with it.
MATCH (c:Chunk)
OPTIONAL MATCH (c)-[:FROM_TEXT_VERSION]->(tv:DocumentTextVersion)
WITH c, collect(tv) AS tvs
WHERE size(tvs) <> 1 OR c.segmentationHash IS NULL
   OR NOT EXISTS { MATCH (c)-[:FROM_TEXT_VERSION]->(:DocumentTextVersion)-[:HAS_SEGMENTATION]->(g:Segmentation) WHERE g.segmentationHash = c.segmentationHash }
RETURN 'W20-V07' AS check, c.uid AS chunkUid, size(tvs) AS textVersions, c.segmentationHash AS segmentationHash;

// W20-V08 (migration progress, informational): retired live relationship types still present.
MATCH ()-[r]->()
WHERE type(r) IN ['PREV_CHUNK', 'HAS_TRANSCRIPT', 'SOURCE_OF', 'SUPPORTED_BY_CLAIM']
   OR (type(r) = 'ASSERTS' AND startNode(r):Chunk)
RETURN 'W20-V08' AS check, type(r) AS retiredRelType, count(r) AS remaining;

// W20-V09: a text version's archetype contentHash equals its textVersionHash.
MATCH (tv:DocumentTextVersion)
WHERE tv.contentHash IS NOT NULL AND tv.contentHash <> tv.textVersionHash
RETURN 'W20-V09' AS check, tv.uid AS textVersionUid;

// W20-V10: RESOLVES_TO_CHUNK is consistent: same text version, same segmentation, overlapping spans.
MATCH (l:SourceLocator)-[r:RESOLVES_TO_CHUNK]->(c:Chunk)
OPTIONAL MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(ltv:DocumentTextVersion)
OPTIONAL MATCH (c)-[:FROM_TEXT_VERSION]->(ctv:DocumentTextVersion)
WITH l, r, c, ltv, ctv,
     [v IN [
        CASE WHEN coalesce(r.segmentationHash, '') <> coalesce(c.segmentationHash, '') THEN 'SEGMENTATION_HASH_MISMATCH' END,
        CASE WHEN ltv IS NOT NULL AND ctv IS NOT NULL AND ltv <> ctv THEN 'TEXT_VERSION_MISMATCH' END,
        CASE WHEN l.startOffset IS NOT NULL AND c.charStart IS NOT NULL
                  AND NOT (l.startOffset < c.charEnd AND c.charStart < l.endOffset) THEN 'NO_SPAN_OVERLAP' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'W20-V10' AS check, l.uid AS locatorUid, c.uid AS chunkUid, violations
ORDER BY locatorUid, chunkUid;
