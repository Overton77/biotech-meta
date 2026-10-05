// W20 fixture 03: alias round trip. A Document, a DocumentTextVersion, a Segmentation and a Chunk created by Cypher
// with STORED property names must read back through the GraphQL field names (Document.id <- documentId,
// Document.name <- title, Document.documentType <- type, Document.sourceUrl <- url, DocumentTextVersion.id <-
// documentTextVersionId, Segmentation.id <- segmentationId, Segmentation.segmentationStrategy <- strategy,
// Chunk.id <- chunkId, Chunk.name <- chunkKey, Chunk.chunkIndex <- index). The GraphQL query and expected JSON are in
// 06-fixtures-and-queries.md (Q-ALIAS-GQL). SYNTHETIC_FIXTURE. Each statement binds its own nodes by uid.

MERGE (d:Document:Source:Entity {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'})
SET d.documentId = '0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70', d.entityType = 'Document',
    d.title = 'Alias round-trip fixture', d.url = 'https://alias.example.invalid/doc', d.canonicalUri = 'https://alias.example.invalid/doc',
    d.type = 'WEBPAGE', d.sourceKind = 'ORGANIZATION_WEBPAGE', d.documentKey = 'alias-fixture', d.documentDomain = 'TECHNICAL',
    d.privacyClass = 'PUBLIC', d.isPrimarySource = true,
    d.createdAt = datetime('2026-10-04T00:00:00Z'), d.updatedAt = datetime('2026-10-04T00:00:00Z');

MATCH (d:Document {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:6b0a3f4e-0c2d-4a9b-8e71-5d4c3b2a1f09'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = d.canonicalUri, s.retrievedAt = datetime('2026-10-04T00:00:00Z'), s.observedAt = datetime('2026-10-04T00:00:00Z'),
    s.contentHash = 'sha256:9c70a5e2d88dcd163e6df71ce9b77dacc3a876a4a047a212010f7e203e73d7d3', s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE',
    s.createdAt = datetime('2026-10-04T00:00:00Z')
MERGE (d)-[:HAS_SNAPSHOT]->(s);

MATCH (d:Document {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'}), (s:SourceSnapshot {uid: 'hu:snapshot:6b0a3f4e-0c2d-4a9b-8e71-5d4c3b2a1f09'})
MERGE (tv:DocumentTextVersion:InformationArtifact {uid: 'hu:text-version:9e8d7c6b-5a49-4382-a1b0-c9d8e7f6a5b4'})
SET tv.documentTextVersionId = '9e8d7c6b-5a49-4382-a1b0-c9d8e7f6a5b4', tv.artifactType = 'DocumentTextVersion', tv.text = 'Alias text.',
    tv.textVersionHash = 'sha256:f90046431652308be4e2f15b69483bf1f7c985e0429b09ed62995317e6a06014', tv.contentHash = 'sha256:f90046431652308be4e2f15b69483bf1f7c985e0429b09ed62995317e6a06014',
    tv.source = 'html-text-extract', tv.createdAt = datetime('2026-10-04T00:00:00Z'), tv.updatedAt = datetime('2026-10-04T00:00:00Z')
MERGE (d)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s);

MATCH (tv:DocumentTextVersion {uid: 'hu:text-version:9e8d7c6b-5a49-4382-a1b0-c9d8e7f6a5b4'})
MERGE (g:Segmentation:InformationArtifact {uid: 'hu:segmentation:3c2b1a09-8f7e-4d6c-b5a4-938271605f4e'})
SET g.segmentationId = '3c2b1a09-8f7e-4d6c-b5a4-938271605f4e', g.artifactType = 'Segmentation', g.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6',
    g.chunkSize = 160, g.overlap = 20, g.strategy = 'fixed-window', g.methodVersion = 'w20-window-v1;unit=CODE_POINT',
    g.createdAt = datetime('2026-10-04T00:00:00Z'), g.updatedAt = datetime('2026-10-04T00:00:00Z')
MERGE (tv)-[:HAS_SEGMENTATION]->(g);

MATCH (tv:DocumentTextVersion {uid: 'hu:text-version:9e8d7c6b-5a49-4382-a1b0-c9d8e7f6a5b4'}), (d:Document {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'})
MERGE (c:Chunk:InformationArtifact {uid: 'hu:chunk:7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d'})
SET c.chunkId = '7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d', c.chunkKey = 'alias#0', c.artifactType = 'Chunk', c.index = 0, c.text = 'Alias text.',
    c.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6', c.charStart = 0, c.charEnd = 11,
    c.createdAt = datetime('2026-10-04T00:00:00Z'), c.updatedAt = datetime('2026-10-04T00:00:00Z')
MERGE (c)-[:FROM_TEXT_VERSION]->(tv)
MERGE (d)-[r:HAS_CHUNK]->(c) SET r.derivationRule = 'chunk-of-document-text-version-v1';

// Q-ALIAS-CYPHER: read back with stored names (expected: one row, all values non-null)
MATCH (d:Document {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'})-[:HAS_TEXT_VERSION]->(tv:DocumentTextVersion)-[:HAS_SEGMENTATION]->(g:Segmentation)
MATCH (c:Chunk)-[:FROM_TEXT_VERSION]->(tv)
RETURN d.documentId AS id, d.title AS name, d.type AS documentType, d.url AS sourceUrl,
       tv.documentTextVersionId AS tvId, g.segmentationId AS segId, g.strategy AS segmentationStrategy,
       c.chunkId AS chunkId, c.chunkKey AS chunkName, c.index AS chunkIndex,
       d.name AS graphqlNameStoredLiterally, d.documentType AS graphqlDocumentTypeStoredLiterally;
