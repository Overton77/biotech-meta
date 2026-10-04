// W20 expectation queries. Expected rows are documented per query id in 06-fixtures-and-queries.md.
// Each statement binds its own variables. Stored property names only.

// Q01-a (CQ-PV-02): after re-segmentation the unchanged locator resolves only to G2 chunks.
MATCH (l:SourceLocator {uid: 'hu:locator:w20f01-l1-nmn-gram'})-[r:RESOLVES_TO_CHUNK]->(c:Chunk)
RETURN c.uid AS chunkUid, c.index AS chunkIndex, r.segmentationHash AS segmentationHash, r.coversWholeSpan AS coversWholeSpan
ORDER BY chunkIndex;

// Q01-b (INV-404): the chunk support shortcuts were regenerated and name the same locator.
MATCH (a:Assertion {uid: 'hu:assertion:w20f01-a1-nmn-gram-daily'})-[r:SUPPORTED_BY_CHUNK]->(c:Chunk)
RETURN c.uid AS chunkUid, r.locatorUid AS locatorUid, r.segmentationHash AS segmentationHash
ORDER BY chunkUid;

// Q01-c (CQ-PV-02): the locator still reproduces its quote from the text version it counts in; quote and hash unchanged.
MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator {uid: 'hu:locator:w20f01-l1-nmn-gram'})-[:LOCATOR_IN_TEXT_VERSION]->(tv:DocumentTextVersion)-[:TEXT_OF_SNAPSHOT]->(s)
RETURN s.uid AS snapshotUid, tv.uid AS textVersionUid,
       substring(tv.text, l.startOffset, l.endOffset - l.startOffset) = l.exact AS offsetsReproduceQuote,
       l.quoteHash AS quoteHash;

// Q01-d: no chunk of the retired segmentation G1 remains, and nothing points at one.
MATCH (c:Chunk {segmentationHash: 'sha256:aeb865ec0fd9d09f5e55ccbedfb420b12851690c85a089dded28605d6805237c'})
RETURN count(c) AS g1ChunksRemaining;

// Q01-e (CQ-PV-02, minimal pair): from a chunk of the CORRECTED capture back to the assertion: only through the
// re-anchored locator; there is no chunk shortcut from A1 into the corrected text version.
MATCH (c:Chunk {uid: 'hu:chunk:w20f01-g3-c0'})<-[:RESOLVES_TO_CHUNK]-(l2:SourceLocator)-[x:REANCHORS]->(l1:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
OPTIONAL MATCH (a)-[sc:SUPPORTED_BY_CHUNK]->(c)
RETURN a.uid AS assertionUid, l2.uid AS newLocator, l1.uid AS citedLocator, x.anchorMatch AS anchorMatch,
       l2.quoteHash = l1.quoteHash AS sameQuoteHash, count(sc) AS chunkShortcutsIntoCorrectedText;

// Q01-f (CQ-PV-02): same segmentation configuration on two text versions = same segmentationHash, different chunk text.
MATCH (tv:DocumentTextVersion)-[:HAS_SEGMENTATION]->(g:Segmentation)
WHERE tv.uid IN ['hu:text-version:w20f01-tv1', 'hu:text-version:w20f01-tv2']
MATCH (c:Chunk {segmentationHash: g.segmentationHash, index: 0})-[:FROM_TEXT_VERSION]->(tv)
RETURN tv.uid AS textVersionUid, g.uid AS segmentationUid, g.segmentationHash AS segmentationHash, c.contentHash AS chunk0Hash
ORDER BY textVersionUid;

// Q01-g (QS-1a, CQ-AX-07): the repository trace shape over A1 reports no gaps (run with $assertionUids, $recordedAsOf).
MATCH (a:Assertion)
WHERE a.uid IN ['hu:assertion:w20f01-a1-nmn-gram-daily'] AND a.recordedAt <= datetime('2026-12-01T00:00:00Z')
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(loc:SourceLocator)
  OPTIONAL MATCH (snap:SourceSnapshot)-[:HAS_LOCATOR]->(loc)
  RETURN collect(DISTINCT CASE WHEN loc IS NULL THEN NULL ELSE {locatorUid: loc.uid, snapshotUid: snap.uid, contentHash: snap.contentHash, retrievedAt: snap.retrievedAt} END) AS supports
}
CALL {
  WITH a
  OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
  WHERE j.reviewedAt <= datetime('2026-12-01T00:00:00Z')
  RETURN collect(j.uid) AS adjudicationsAsOfR
}
RETURN a.uid AS assertionUid, size(supports) AS locators, adjudicationsAsOfR,
       [gap IN [
         CASE WHEN size(supports) = 0 THEN 'NO_LOCATOR' END,
         CASE WHEN size([x IN supports WHERE x.snapshotUid IS NULL]) > 0 THEN 'LOCATOR_WITHOUT_SNAPSHOT' END,
         CASE WHEN size([x IN supports WHERE x.contentHash IS NULL OR x.retrievedAt IS NULL]) > 0 THEN 'SNAPSHOT_NOT_REPRODUCIBLE' END,
         CASE WHEN size(adjudicationsAsOfR) = 0 THEN 'NO_ADJUDICATION_AS_OF_R' END
       ] WHERE gap IS NOT NULL] AS traceGaps;

// Q01-h (CQ-PV-03): lineage of A1's evidence chain: which activities captured, extracted, segmented, re-anchored.
MATCH (a:Assertion {uid: 'hu:assertion:w20f01-a1-nmn-gram-daily'})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv:DocumentTextVersion)
OPTIONAL MATCH (s)-[:WAS_GENERATED_BY]->(cap:Activity)
OPTIONAL MATCH (tv)-[:WAS_GENERATED_BY]->(ext:Activity)
OPTIONAL MATCH (tv)-[:HAS_SEGMENTATION]->(g:Segmentation)-[:WAS_GENERATED_BY]->(seg:Activity)
RETURN cap.uid AS captureActivity, ext.uid AS extractionActivity, ext.methodVersion AS extractionMethod,
       collect(DISTINCT seg.uid) AS segmentationActivities;

// Q03-a (alias): stored-name read of the alias fixture (see w20-03 last statement; repeated here for the runner).
MATCH (d:Document {uid: 'hu:document:0f6c1e2a-5b7d-4c11-9a43-3b2f8e9d1a70'})
RETURN d.documentId AS id, d.title AS name, d.type AS documentType, d.url AS sourceUrl, d.name AS literalName;

// Q04-a (CQ-PV-02/04): cross-rendition alignment of one sentence of the NiCE article by quoteHash (computed join; no stored edge).
MATCH (p:Publication {uid: 'hu:publication:nice-trial-2024-ncomms'})<-[:RENDITION_OF]-(d:Document)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
RETURN l.quoteHash AS quoteHash, collect(d.uid) AS renditions, collect(l.startOffset) AS startOffsets
ORDER BY size(renditions) DESC;

// Q04-b (CQ-PV-04): same sentence, different offsets per text version: offsets never transfer across text versions.
MATCH (d:Document)-[:HAS_TEXT_VERSION]->(tv:DocumentTextVersion)<-[:LOCATOR_IN_TEXT_VERSION]-(l:SourceLocator)
WHERE d.uid IN ['hu:document:pmc-pmc11176364-html', 'hu:document:pmc-pmc11176364-fulltext-connector', 'hu:document:nature-s41467-024-49092-5-pdf']
RETURN d.uid AS rendition, tv.versionLabel AS textVersion, l.startOffset AS startOffset, l.endOffset AS endOffset,
       l.endOffset - l.startOffset AS spanLength, l.exact CONTAINS 'P = 0.08' AS keepsPValueSymbol
ORDER BY rendition;

// Q04-c (CQ-CL-08, CQ-PV-02): episode renditions: media time exists only on the video rendition; the publisher page has none.
MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})<-[:RENDITION_OF]-(d:Document)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
RETURN d.type AS renditionType, l.selectorKind AS selectorKind, l.mediaStartSeconds AS mediaStartSeconds,
       l.quoteHash AS quoteHash, l.exact AS exact
ORDER BY renditionType;

// Q-AX-14 (QS-8, W20 variant): fulltext hits are candidates; name falls back to stored alias properties.
CALL db.index.fulltext.queryNodes('DocumentSearch', 'NICE') YIELD node, score
RETURN node.uid AS candidateUid, labels(node) AS labels, coalesce(node.name, node.title, node.chunkKey) AS displayName,
       score AS indexScore
ORDER BY indexScore DESC, candidateUid;

// Q-AX-14b: chunk-level fulltext over the active segmentation partition only.
CALL db.index.fulltext.queryNodes('ChunkSearch', 'NMN') YIELD node, score
WITH node, score WHERE node.segmentationHash IN ['sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6']
  AND coalesce(node.privacyClass, 'PUBLIC') = 'PUBLIC'
MATCH (node)-[:FROM_TEXT_VERSION]->(tv:DocumentTextVersion)-[:TEXT_OF_SNAPSHOT]->(s:SourceSnapshot)
RETURN node.uid AS chunkUid, tv.uid AS textVersionUid, s.retrievedAt AS capturedAt, score AS indexScore
ORDER BY capturedAt DESC, chunkUid;
