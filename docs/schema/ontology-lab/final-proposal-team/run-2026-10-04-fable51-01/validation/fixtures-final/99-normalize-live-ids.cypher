// Migration backfill M-01 (final proposal): nodes written by Cypher must carry the live projection identity and timestamps
// the GraphQL layer treats as non-null (id: ID! and createdAt/updatedAt), per contract B2 and INV-106 (id = opaque uid segment).
// Stored-id aliases: Document.documentId, DocumentTextVersion.documentTextVersionId, Segmentation.segmentationId, Chunk.chunkId.
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND NOT n:Document AND NOT n:DocumentTextVersion AND NOT n:Segmentation AND NOT n:Chunk AND n.id IS NULL
SET n.id = last(split(n.uid, ':'));
MATCH (n:Document) WHERE n.uid IS NOT NULL AND n.documentId IS NULL SET n.documentId = last(split(n.uid, ':'));
MATCH (n:DocumentTextVersion) WHERE n.uid IS NOT NULL AND n.documentTextVersionId IS NULL SET n.documentTextVersionId = last(split(n.uid, ':'));
MATCH (n:Segmentation) WHERE n.uid IS NOT NULL AND n.segmentationId IS NULL SET n.segmentationId = last(split(n.uid, ':'));
MATCH (n:Chunk) WHERE n.uid IS NOT NULL AND n.chunkId IS NULL SET n.chunkId = last(split(n.uid, ':'));
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND n.createdAt IS NULL SET n.createdAt = datetime('2026-10-04T00:00:00Z');
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND n.updatedAt IS NULL SET n.updatedAt = n.createdAt;
// MR-10: privacyClass stored exactly as the GraphQL enum
MATCH (n) WHERE n.privacyClass IN ['public','internal'] SET n.privacyClass = toUpper(n.privacyClass);
