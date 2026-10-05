// W20 fixture 02: NEGATIVE cases. Load AFTER w20-01 into the same database. Every case below must be reported by the
// validator named in its header; w20-01 alone must produce zero rows on the same validators.
// SYNTHETIC_FIXTURE throughout. Every statement binds its own nodes by uid; no variable crosses a ';'.

// ---------- N1 (V-407): a legacy-typed SUPPORTED_BY edge from an Assertion to a Chunk WITHOUT locatorUid ----------
// The chunk is a real G2 chunk of fixture 01; the assertion is a second, otherwise valid assertion.
MATCH (sub:ChemicalSubstance {uid: 'hu:substance:w20f01-nmn'})
MERGE (a:Assertion {uid: 'hu:assertion:w20f02-n1-chunk-only-support'})
SET a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-21T00:00:00Z'),
    a.valueNumber = 1.0, a.unitCode = 'g', a.createdAt = datetime('2026-10-21T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(sub);

MATCH (a:Assertion {uid: 'hu:assertion:w20f02-n1-chunk-only-support'}), (c:Chunk {uid: 'hu:chunk:w20f01-g2-c0'})
MERGE (a)-[r:SUPPORTED_BY]->(c)
SET r.supportType = 'SUPPORTS', r.quoteSpan = 'we take a gram of NMN every day', r.extractionMethod = 'llm-extract', r.extractedAt = datetime('2026-10-21T00:00:00Z');

// ---------- N2 (W20-V01; NOT caught by V-407 because the type differs): SUPPORTED_BY_CHUNK without locatorUid ----------
MATCH (a:Assertion {uid: 'hu:assertion:w20f02-n1-chunk-only-support'}), (c:Chunk {uid: 'hu:chunk:w20f01-g2-c0'})
MERGE (a)-[r:SUPPORTED_BY_CHUNK]->(c)
SET r.derivationRule = 'vector-similarity-top1', r.derivedFromAssertionUids = ['hu:assertion:w20f02-n1-chunk-only-support'], r.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6';

// ---------- N3 (W20-V01): a non-assertion live type (Mechanism) -[:SUPPORTED_BY]-> Chunk without locatorUid ----------
MERGE (m:Mechanism:Entity {uid: 'hu:mechanism:w20f02-nad-salvage'})
SET m.entityType = 'Mechanism', m.name = 'NAD+ salvage (fixture stub)', m.createdAt = datetime('2026-10-21T00:00:00Z');

MATCH (m:Mechanism {uid: 'hu:mechanism:w20f02-nad-salvage'}), (c:Chunk {uid: 'hu:chunk:w20f01-g2-c0'})
MERGE (m)-[r:SUPPORTED_BY]->(c)
SET r.salience = 0.71, r.extractionMethod = 'ner-linker';

// ---------- N4 (W20-V01): CHUNK_MATCH used as SOURCE_SUPPORT. locatorUid names a real locator the assertion is
// SUPPORTED_BY, but that locator does not RESOLVE_TO this chunk (the shortcut came from a retrieval hit on g2-c2).
MATCH (a:Assertion {uid: 'hu:assertion:w20f01-a1-nmn-gram-daily'}), (c:Chunk {uid: 'hu:chunk:w20f01-g2-c2'})
MERGE (a)-[r:SUPPORTED_BY_CHUNK]->(c)
SET r.derivationRule = 'bm25-hit-v0', r.derivedFromAssertionUids = ['hu:assertion:w20f01-a1-nmn-gram-daily'],
    r.locatorUid = 'hu:locator:w20f01-l1-nmn-gram', r.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6';

// ---------- N5 (V-406): a chunk that is also labelled SourceLocator ----------
MATCH (tv:DocumentTextVersion {uid: 'hu:text-version:w20f01-tv1'})
MERGE (c:Chunk:InformationArtifact {uid: 'hu:chunk:w20f02-n5-chunk-as-locator'})
SET c:SourceLocator, c.chunkId = 'w20f02-n5-chunk-as-locator', c.artifactType = 'Chunk', c.index = 99, c.text = 'My 82 -year-old father', c.selectorKind = 'TEXT_QUOTE',
    c.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6', c.charStart = 86, c.charEnd = 108
MERGE (c)-[:FROM_TEXT_VERSION]->(tv);

// ---------- N6 (V-404): a locator on the FIRST snapshot whose offsets count in the CORRECTED text version ----------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w20f01-page-2026-10-03'}), (tv2:DocumentTextVersion {uid: 'hu:text-version:w20f01-tv2'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w20f02-n6-wrong-text-version'})
SET l.artifactType = 'SourceLocator', l.selectorKind = 'TEXT_POSITION', l.exact = 'My 82-year-old father, we take a gram of NMN every day.',
    l.quoteHash = 'sha256:050569ee00d1ec26a66248376413b4218a7c30d3f08b947b2e16f8c5ed983e8e', l.normalizationVersion = 'NFC-WS1', l.startOffset = 86, l.endOffset = 141
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv2);

// ---------- N7 (V-408): RESOLVES_TO_CHUNK without segmentationHash ----------
MATCH (l:SourceLocator {uid: 'hu:locator:w20f01-l1-nmn-gram'}), (c:Chunk {uid: 'hu:chunk:w20f01-g2-c2'})
MERGE (l)-[r:RESOLVES_TO_CHUNK]->(c)
SET r.derivationRule = 'offset-overlap-v1';

// ---------- N8 (V-405): a text version claimed for two snapshots ----------
MATCH (s1:SourceSnapshot {uid: 'hu:snapshot:w20f01-page-2026-10-03'}), (s2:SourceSnapshot {uid: 'hu:snapshot:w20f01-page-2026-11-02'})
MERGE (tv:DocumentTextVersion:InformationArtifact {uid: 'hu:text-version:w20f02-n8-two-snapshots'})
SET tv.documentTextVersionId = 'w20f02-n8-two-snapshots', tv.artifactType = 'DocumentTextVersion', tv.text = 'x', tv.textVersionHash = 'sha256:2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881',
    tv.contentHash = 'sha256:2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881'
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s1)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s2);

// ---------- N9 (V-403): offsets with no text version ----------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w20f01-page-2026-11-02'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w20f02-n9-offsets-no-text-version'})
SET l.artifactType = 'SourceLocator', l.selectorKind = 'TEXT_POSITION', l.exact = 'gram of NMN', l.startOffset = 120, l.endOffset = 131,
    l.quoteHash = 'sha256:0000000000000000000000000000000000000000000000000000000000000000', l.normalizationVersion = 'NFC-WS1'
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---------- N10 (W20-V03): TEXT_POSITION offsets that do not reproduce exact (UTF-16 style off-by-one writer) ----------
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w20f01-page-2026-10-03'}), (tv:DocumentTextVersion {uid: 'hu:text-version:w20f01-tv1'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w20f02-n10-offsets-drift'})
SET l.artifactType = 'SourceLocator', l.selectorKind = 'TEXT_POSITION', l.exact = 'My 82 -year-old father, we take a gram of NMN every day.',
    l.quoteHash = 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56', l.normalizationVersion = 'NFC-WS1', l.startOffset = 87, l.endOffset = 143
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// ---------- N11 (W20-V02): SUPPORTED_BY_DOCUMENT without locatorUid (live shape: StudyArm -> Document) ----------
MERGE (sa:StudyArm:VersionedState {uid: 'hu:study-arm:w20f02-n11-arm'})
SET sa.stateType = 'StudyArm', sa.payloadHash = 'sha256:a0d9c355a0ece246837ca01340ffccd7e14fe820159d0f21bde038997d0fccbf', sa.createdAt = datetime('2026-10-21T00:00:00Z');

MATCH (sa:StudyArm {uid: 'hu:study-arm:w20f02-n11-arm'}), (d:Document {uid: 'hu:document:w20f01-transcript-page'})
MERGE (sa)-[r:SUPPORTED_BY_DOCUMENT]->(d)
SET r.quoteSpan = 'arm description', r.extractionMethod = 'llm-extract';

// ---------- N12 (W20-V06): a chunk whose stored text is not the text-version span it claims ----------
MATCH (tv:DocumentTextVersion {uid: 'hu:text-version:w20f01-tv1'})
MERGE (c:Chunk:InformationArtifact {uid: 'hu:chunk:w20f02-n12-span-mismatch'})
SET c.chunkId = 'w20f02-n12-span-mismatch', c.artifactType = 'Chunk', c.index = 0, c.text = 'My 82-year-old father',
    c.segmentationHash = 'sha256:ef2138d97a7bbf3be5d020fb003a6de74a92a71c9319957d170af1c6dbb1eaa6', c.charStart = 86, c.charEnd = 107
MERGE (c)-[:FROM_TEXT_VERSION]->(tv);

// ---------- N13 (W20-V04): a Document written with GraphQL field names instead of stored names (the shape used by
// docs/schema/examples/claim-retelling-provenance.cypher lines 119-136: documentType instead of type, no documentId, no url)
MERGE (d:Document:Source:Entity {uid: 'hu:document:w20f02-n13-graphql-names'})
SET d.entityType = 'Document', d.name = 'Written with GraphQL names', d.sourceUrl = 'https://n13.example.invalid/', d.documentType = 'WEBPAGE',
    d.canonicalUri = 'https://n13.example.invalid/';

// ---------- N14 (W20-V05): Document whose url and canonicalUri disagree ----------
MERGE (d:Document:Source:Entity {uid: 'hu:document:w20f02-n14-url-drift'})
SET d.documentId = 'w20f02-n14-url-drift', d.entityType = 'Document', d.title = 'URL drift', d.type = 'WEBPAGE',
    d.canonicalUri = 'https://n14.example.invalid/a', d.url = 'https://n14.example.invalid/a?utm_source=x';
