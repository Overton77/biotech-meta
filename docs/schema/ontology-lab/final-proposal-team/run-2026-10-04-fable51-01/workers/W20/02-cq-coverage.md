# W20 02 CQ coverage

Priority and answerability come from `competency-questions.md` (A answerable, Q with qualifications). Query ids refer to `fixtures/w20-queries.cypher` and `operations.cypher`; results are in `06-fixtures-and-queries.md` (all listed queries were **run** on Neo4j 5.26.31 Community unless marked).

## 1. Existing CQs

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Proposed element(s) | Query | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-PV-02 (Foundational, A) Can the cited span be found again after the page, transcript or rendition changed, and which captured version was used? | "A1 cites L1 in snapshot 2026-10-03, text version tv1, offsets 86–142, quote hash `sha256:96fe6eb5…`; still reproduces after re-chunking; the 2026-11-02 capture has L2 that REANCHORS L1 with FUZZY match ('82 -year-old' → '82-year-old')." | locator vs chunk; text version vs snapshot; exact vs fuzzy re-anchor; rendition timeline vs work | snapshot hash with basis; locator quote and normalization; text version bound to one snapshot | `DocumentTextVersion` (`textVersionHash`, `text`, `TEXT_OF_SNAPSHOT`), `Chunk.charStart/charEnd`, `RESOLVES_TO_CHUNK {ChunkResolutionProperties}`, `Segmentation.segmentationHash` | Q01-a, Q01-c, Q01-e, Q04-b; V-401, V-403 to V-405, V-408, W20-V03, W20-V06, W20-V10 | a citation that silently points at different words after re-chunking or after a page correction |
| CQ-PV-03 (Foundational, A) Which capture, transcription, segmentation and extraction activities produced this assertion? | "Captured by `w20f01-capture-1`, text by `w20f01-extract-1` (html-text-extract-v2), current chunks by `w20f01-segment-g2`." | activity vs agent; generator vs last writer | `WAS_GENERATED_BY` from snapshot, text version and segmentation | `DocumentTextVersion.wasGeneratedBy`, `Segmentation.wasGeneratedBy` (W20-SR-05), `Segmentation.methodVersion`, `*.activityUid` on derived edges | Q01-h | a faulty extractor or segmenter whose outputs cannot be found and redone |
| CQ-PV-04 (Essential now, Q) Could a conversion or transcription error change the conclusion? | "The connector's JATS-derived text drops the italic P: '(90% CI: + 1.77, +∞,= 0.08)'; the PDF and PMC HTML keep 'P = 0.08'. It also drops the NCT registration number (PDF: 'registration: NCT03743636'; connector: 'registration:.'). Its BMI formula reads 'weight (kg)/[height (meters)]' with no exponent; whether the source rendering has one was not captured (cannot establish)." | text version vs source content; lossy converter vs source error | per-text-version provenance (`versionLabel`, `WAS_GENERATED_BY` with method), several text versions per capture | `DocumentTextVersion` per extractor; `versionLabel`, `source`, `normalizationVersion` | Q04-b (`keepsPValueSymbol`), Q04-a | reading a converter artifact as what the authors wrote |
| CQ-PV-05 (Foundational, Q) Is this source primary or a retelling? | "Primary for this sentence: no outgoing RETELLS from the occurrence; `Document.isPrimarySource` is a read-only legacy hint." | per-assertion vs per-document primacy | RETELLS (W21) | `Document.isPrimarySource` read-only | none new (W21 RETELLS) | a whole document marked primary while it quotes others |
| CQ-PV-01 (Essential now, Q), state 2 and state 4 | "Supported span: L1 in snapshot S1; used by activities …" | chunk shortcut vs locator support | locator chain | `SUPPORTED_BY_CHUNK`/`SUPPORTED_BY_DOCUMENT` carry `locatorUid` and never replace `SUPPORTED_BY -> SourceLocator` | Q01-g (QS-1a), W20-V01, W20-V02 | presenting a retrieval hit as state 2 |
| CQ-EV-01 (Essential now) Which source supports this fact? | "Supported by L1 (TEXT_POSITION, tv1); chunk shortcuts to g2-c0, g2-c1 name L1." | locator support vs chunk shortcut | locator | `DerivedSupportProperties` (`locatorUid!`, `derivedFromAssertionUids!`, `derivationRule!`) | Q01-b; W20-V01 rows for N1 to N4 | a chunk similarity hit counted as support (forbidden CHUNK_MATCH → SOURCE_SUPPORT) |
| CQ-EV-05 (Essential now) Was a source corrected or retracted? | "A RETRACTION_NOTICE document exists for the article; the article's documentType stays SCIENTIFIC_ARTICLE." | document genre vs revision state | SourceRevisionEvent (W00) | `DocumentType` notice values | not run (W00 SourceRevisionEvent fixture) | "retracted" encoded as a document type and lost on the next capture |
| CQ-AX-07 (Essential now, A) Which accepted assertions lack a locator, a reproducible snapshot or an adjudication? | "0 for the W20 fixture; 1 legacy chunk-only support edge reported by V-407 and W20-V01." | locator vs chunk-only support | the graph | W20-V01 (all start labels), W20-V02 | V-110, V-111, V-401, W20-V01, W20-V02 | accepted state resting on a chunk |
| CQ-AX-14 (Essential now, A) For free text, which candidates match, and is the choice kept as a hypothesis? | "'NICE' hits 3 Document endpoints (lexical scores 0.34/0.33/0.30); they are three renditions of one Publication, not three works." | lexical hit vs identity; endpoint vs work | live fulltext surface on stored names | `@fulltext DocumentSearch` (stored `title`, `url`, `searchText`), `ChunkSearch`; QS-8 name fallback `coalesce(name, title, chunkKey)` | Q-AX-14, Q-AX-14b | an index on GraphQL names returning zero hits silently (run); a hit read as identity |
| CQ-CL-08 (Essential now, A) Was a statement part of a sponsor read, and when? | "The sponsor read has media time only on the YouTube rendition; the transcript page has no timeline." | rendition timeline vs text without timing | MEDIA_TIME on rendition snapshot (W00) | `Chunk.inEpisodeSegments` derived read-only | Q04-c | a transcript-page offset converted into invented seconds |

## 2. Candidate CQs (W20, candidate)

| Id | Question | Rationale and failing case | Elements | Query |
|---|---|---|---|---|
| CQ-PV-C01 | Which text version (producer, method, language, normalization) does this offset count in, and do two text versions of one capture or work agree on this span? | fixture 04: offsets 514 / 524 / 538 for one sentence; a JS writer drifts one per astral character (N10) | `DocumentTextVersion.versionLabel`, `normalizationVersion`, `languageCode`, `wasGeneratedBy` | Q04-b, W20-V03 |
| CQ-PV-C02 | Which segmentation produced the chunks an index serves, and which chunk shortcuts are regenerated when segmentation changes? | fixture 01: G1 → G2 replaces all chunk shortcuts while A1 and L1 are untouched; mixed segmentations in one index return duplicates | `Segmentation.segmentationHash`, `methodVersion`; `Chunk.segmentationHash`; `ChunkResolutionProperties.segmentationHash` | Q01-a, Q01-d, Q01-f, Q-AX-14b |
| CQ-PV-C03 | Does the cited sentence appear in another rendition (PDF, publisher HTML, repository XML) of the same work, exactly or only fuzzily? | fixture 04: PDF and PMC HTML agree after NFC-WS1, connector text does not | none new (computed join on `quoteHash`); stored alignment edge stays out of the fragment | Q04-a |

## 3. Element-to-requirement map (every SDL element)

| SDL element | CQ / invariant / ingestion failure |
|---|---|
| `DocumentType` (incl. 8 round-0006 values) | CQ-EV-05, CQ-AX-14 facet; "retracted is not a type" |
| `DocumentDomain` | retrieval partition facet (CQ-AX-14); live compatibility |
| `DocumentAuthorTarget` | CQ-CL-01 (authorship vs quoted speaker); live union rename |
| `ChunkResolutionProperties` | CQ-PV-02, V-408, W20-V10 |
| `DerivedSupportProperties` | CQ-EV-01, CQ-AX-07, INV-404, V-407, W20-V01/V02 |
| `RetrievalEdgeProperties` | CQ-AX-14, round 0006 D9 (ranking features), INV-107 (derived, never evidence) |
| `Document` fields `id`, `uid`, `name`, `entityType`, timestamps, `privacyClass`, `maturity`, `schemaVersion` | contract B2, INV-001, INV-106, V-117 |
| `Document.searchText/searchFields/embeddingModel/embeddingDimensions/searchEmbedding` | CQ-AX-14, INV-107, V-119 |
| `Document.canonicalUri/sourceKind/publisherUid` | D-005 (Source specialization), W20-V05 |
| `Document.documentKey` | live compatibility (ingestion idempotence key) |
| `Document.documentType/sourceUrl/documentDomain/publisher/publicationVenue/publishedAt/fileFormat/languageCode/isPeerReviewed/isRegulatorySource/isFinancialDisclosure` | live compatibility; CQ-AX-14 facets; CQ-CL-05 (financial disclosure pages) |
| `Document.isPrimarySource` (read-only) | CQ-PV-05 (advisory deprecation) |
| `Document.snapshots/hasTextVersions/renditionOfEpisodes/renditionOfPublications` | CQ-PV-02, D-005 |
| `Document.hasChunks/about/authoredBy` | CQ-AX-14 / CQ-CL-01 |
| `DocumentTextVersion` all fields and edges | CQ-PV-02, CQ-PV-03, CQ-PV-04, CQ-PV-C01, V-403 to V-405, W20-V03, W20-V09 |
| `Segmentation` all fields and edges | CQ-PV-03, CQ-PV-C02, W20-V07 |
| `Chunk` all fields and edges | CQ-AX-14, CQ-PV-02, CQ-PV-C02, CQ-CL-08, INV-404, V-406, W20-V06, W20-V07 |
