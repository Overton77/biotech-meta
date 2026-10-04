# W20 01 Domain recommendation: documents, text versions and chunks

Worker W20 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 (`8fb50ff0…84f0`), live schema `86b5e0b5…f112`. Canonical modules: `claims_and_documents` (Document, Segmentation, Chunk, DocumentType, DocumentDomain, RESOLVES_TO_CHUNK, SUPPORTED_BY_CHUNK) and `provenance` (DocumentTextVersion, canonical there; W20 writes its SDL; T-003: no transfer proposed).

## 1. Boundary in one paragraph

W20 owns the text lineage between a capture and retrieval: the document endpoint (a `Document`, which is a `Source`), the text renderings of a capture (`DocumentTextVersion`), chunking runs (`Segmentation`) and their retrieval units (`Chunk`), plus the derived shortcuts that connect retrieval units to evidence without becoming evidence. W00 owns everything that makes a citation reproducible (`Source`, `SourceSnapshot`, `SourceLocator`, `REANCHORS`, `Activity`). W21 owns works and utterances (`Episode`, `ClaimOccurrence`), W09 owns scholarly works (`Publication`), W19 owns source authority and discovery, W22 owns media assets and region annotations.

The rule that shapes everything else: **a citation is a locator in a snapshot; offsets count only in a text version bound to exactly one snapshot; a chunk is a regenerable view of a text version and is never cited.** Chunking never changes the cited proposition, because the proposition is attached to an Assertion that is `SUPPORTED_BY` a locator, and re-chunking touches neither.

## 2. Subdomains and the identity / state / artifact / occurrence split

| Subdomain | Element | Archetype | Identity basis | What it is not |
|---|---|---|---|---|
| Endpoint | `Document` `["Document","Source","Entity"]` | Entity | one `canonicalUri` (W00 uniqueness) plus `uid` | not the work (`Publication`, `Episode`), not a capture, not a text |
| Capture (W00) | `SourceSnapshot` | InformationArtifact | `uid`; immutable bytes or stored text with `contentHash` and named basis | not a text rendering |
| Text rendering | `DocumentTextVersion` | InformationArtifact | `uid`; content by `textVersionHash`; exactly one `TEXT_OF_SNAPSHOT` | not the capture (two extractors give two text versions), not a locator |
| Chunking run | `Segmentation` | InformationArtifact (operational) | (text version, `segmentationHash`); hash over configuration only | not evidence |
| Retrieval unit | `Chunk` | InformationArtifact (derived) | (text version, `segmentationHash`, `index`); span `[charStart, charEnd)` | never a locator (INV-404), never support |
| Production run (W00) | `Activity` kinds `CAPTURE`, `TEXT_EXTRACTION`, `TRANSCRIPTION`, `SEGMENTATION`, `REANCHORING` | Occurrence | `uid` | not an Agent |

No occurrence or versioned state is introduced. A corrected page is a new snapshot and a new text version; a new chunking is a new Segmentation; nothing is edited in place.

## 3. Disposition of every live and catalog element in scope

Vocabulary: keep, refine, merge, split, seam, derive, retire, defer. The full field-level list is `migration-map.yaml`.

| Element (live line or catalog) | Disposition | Final form | Reason (failing case) |
|---|---|---|---|
| `Document` (live 2665) | keep; refine | `["Document","Source","Entity"]`, archetype Entity; carries Source fields `canonicalUri`, `sourceKind`, `publisherUid` | D-005; one endpoint, many captures (fixture 01: two snapshots of one page) |
| `Document.id @alias(documentId)`, `name @alias(title)`, `documentType @alias(type)`, `sourceUrl @alias(url)` | keep (frozen aliases, B2) | unchanged; `name` nullable (D-013) | fixture 02 N13: a node written with GraphQL names (`documentType`, no `documentId`) fails a GraphQL read with `Cannot return null for non-nullable field Document.id` (run) |
| `Document.sourceUrl` vs `Source.canonicalUri` | seam | both stored, equal; W20-V05 | a `:Document:Source` node read through W00's `Source` type needs `canonicalUri`; fixture 02 N14 (`utm_source` drift) |
| `Document.documentKey: String!` | refine | `String` (nullable), legacy natural key, never identity | Cypher-ingested kernel records must stay readable (D-013 reasoning) |
| `Document.documentType` vs `sourceKind` | keep both; seam | genre for display vs provenance genre for authority; mapping table in `04-model-cards.md` | `SCIENTIFIC_ARTICLE` covers peer-reviewed and preprint renderings; authority differs |
| `Document.isPrimarySource` | refine (advisory deprecate) | read-only legacy (`@settable(onCreate:false,onUpdate:false)`) | primary versus retelling is per assertion (no outgoing `RETELLS`; CQ-PV-05) |
| `Document.publishedAt` | keep; refine | materialized first stated publication time; per-capture `SourceSnapshot.publishedAt` is authoritative | a page's stated date can change between captures |
| `Document.isPeerReviewed`, `isRegulatorySource`, `isFinancialDisclosure`, `publisher`, `publicationVenue`, `fileFormat`, `languageCode`, `documentDomain` | keep | unchanged | venue/genre facts and facets |
| `Document.hasTextVersions` (`HAS_TEXT_VERSION`) | keep | structural, W00 relationship | |
| `Document.hasChunks` (`HAS_CHUNK`, OrderingMetadata) | derive | read-only, `DerivedEdgeProperties` | chunk parentage is `FROM_TEXT_VERSION`; this is a shortcut |
| `Document.about` (`ABOUT`, ExtractionMetadata) | derive | `RetrievalEdgeProperties` (salience, aboutness as ranking features) | aboutness is not evidence (round 0006 D9) |
| `Document.authoredBy` (`AUTHORED_BY`, RoleMetadata) | refine | asserted, `AssertedEdgeProperties`; range `DocumentAuthorTarget` | a byline is a statement in a snapshot; authorship is not attribution of quoted speech |
| `Document.sourceForEpisodes` (`SOURCE_OF`) | retire | `RENDITION_OF` (W00) via `renditionOfEpisodes`, plus `renditionOfPublications` | direction and meaning: the page renders the work |
| `DocumentTextVersion` (live 2697) | keep; refine | archetype InformationArtifact; `TEXT_OF_SNAPSHOT` exactly one; `WAS_GENERATED_BY` Activity | fixture 04: one article, three text versions, three offset sets (514/524/538) |
| `DocumentTextVersion.source: String!` | seam | nullable display label; lineage is `WAS_GENERATED_BY` with `methodVersion` | the string names a method without a version |
| `DocumentTextVersion.textVersionHash`, `text`, `versionLabel` | keep | `textVersionHash` over stored text; `contentHash` mirrors it (W20-V09) | |
| (new fields) `normalizationVersion`, `languageCode` | add (catalog `normalizationVersion`; `languageCode` for caption tracks) | | YouTube serves caption tracks per language; a translation is another text version |
| `DocumentTextVersion.hasSegmentations` (`HAS_SEGMENTATION`, OrderingMetadata) | keep | structural, no properties | ordering carried no meaning |
| `Segmentation` (live 2711) | keep (operational) | archetype InformationArtifact; `segmentationHash` over configuration; `methodVersion` added | without the size unit and tokenizer, `chunkSize 512` is ambiguous |
| `Segmentation.segmentationStrategy @alias(strategy)` | keep | frozen alias | |
| `Chunk` (live 2723) | keep as derived | archetype InformationArtifact; `charStart`, `charEnd` added (catalog) | span needed to compute `RESOLVES_TO_CHUNK` and W20-V06 |
| `Chunk.id @alias(chunkId)`, `name @alias(chunkKey)`, `chunkIndex @alias(index)` | keep (frozen aliases) | | |
| `Chunk.segmentationHash` | keep; refine | required for new writes (service), nullable for legacy | |
| `Chunk.fromTextVersions` (`FROM_TEXT_VERSION`, RoleMetadata) | keep; refine | structural exactly one, no properties | RoleMetadata carried no meaning here |
| `Chunk.nextChunks` (`NEXT_CHUNK`) | keep | structural | |
| `Chunk.previousChunks` (`PREV_CHUNK`) | retire relationship type | field kept as `NEXT_CHUNK` direction IN | a stored inverse can disagree with `NEXT_CHUNK` |
| `Chunk.mentions` (`MENTIONS`), `Chunk.about` (`ABOUT`) | derive | `RetrievalEdgeProperties` | mention is not endorsement; not identity |
| `Chunk.assertsClaims` (`ASSERTS`) | retire relationship type for chunks | field kept as read-only inverse of `Claim -[:SUPPORTED_BY_CHUNK]->` | one fact stored twice (`Claim.supportedBy` and `Chunk.assertsClaims`) drifts; a chunk asserts nothing |
| `Chunk.inEpisodeSegments` (`OCCURS_IN_SEGMENT`) | derive | read-only, `DerivedEdgeProperties` | segment timing is rendition-specific |
| `Episode.hasTranscriptVersions` (`HAS_TRANSCRIPT`) | retire (W21 field) | transcript = text version `TEXT_OF_SNAPSHOT` a snapshot of a rendition Source `RENDITION_OF` the Episode | fixture 04: the page transcript and the YouTube cues differ in wording and only one has a timeline |
| `SUPPORTED_BY_CHUNK` on 13 live types; `SUPPORTED_BY -> Chunk` on 18 live types (+ `ProtocolResult.supportedBy` via union `ProvenanceSource`) | derive; rename the latter | one relationship type `SUPPORTED_BY_CHUNK` with `DerivedSupportProperties` (`locatorUid!`, `derivedFromAssertionUids!`) | KCR-4.5; fixture 02 N1 to N4 (V-407 sees only N1) |
| `SUPPORTED_BY_DOCUMENT` on 11 live types | derive | `DerivedSupportProperties` with `locatorUid!`; locator must hang from one of the document's snapshots | a document-level support edge says nothing about which capture or span (fixture 02 N11) |
| `ExtractionMetadata` (live 189) | split | `quoteSpan` to `SourceLocator.exact`; method/version/time to `Activity`; `supportType` to relationship type; salience/aboutness to `RetrievalEdgeProperties`; new `locatorUid`, `activityUid` | round 0006 D9 |
| `OrderingMetadata` on chunk edges | retire for W20 edges | no properties (order is `Chunk.index`) | |
| `DocumentType` enum | keep; extend | + CORRECTION_NOTICE, RETRACTION_NOTICE, EXPRESSION_OF_CONCERN, REINSTATEMENT_NOTICE, TRANSCRIPT_PAGE, VIDEO_PAGE, AUDIO_FEED_ITEM, NEWSLETTER_ISSUE | round 0006; "retracted" is never a document type |
| `DocumentDomain` enum | keep | unchanged; used as retrieval partition facet | |
| live union `DocumentAuthor` | rename | `DocumentAuthorTarget` (B6 naming) | |
| live union `ExtractionSource` (Document, Episode, Chunk) | retire (W21 field `ExperienceReport.extractedFrom`) | `SUPPORTED_BY` a locator | Chunk is not a source |
| `@fulltext DocumentSearch`, `ChunkSearch` | keep (D-015) | index created on stored names `title`, `url`, `searchText` / `text`, `searchText` | run: a GraphQL-named index returns 0 hits silently; `assertIndexesAndConstraints()` reports it |
| `@vector DocumentSearchEmbedding`, `ChunkSearchEmbedding` | keep for Fable's merge (D-014) | no `provider`; justification in `07-operations.md` | run: Community 5.26.31 creates and queries a 4-dimension vector index |

## 4. Alternatives considered

| Question | Alternative | Rejected because |
|---|---|---|
| Is the chunk the locator? | Chunk with quote span as the citation | re-segmentation changes chunk text (round 0006 D1; fixture 01: L1 resolves to `g1-c1` then to `g2-c0` and `g2-c1`, while L1 itself is unchanged) |
| Text version = snapshot? | Offsets on the snapshot | fixture 04: one PMC article yields text versions where the same sentence starts at 514, 524 and 538 |
| Keep live `SUPPORTED_BY -> Chunk` type name | same type for structural locator support and derived chunk support | one relationship type, one meaning (CL-014 precedent); a label-less traversal `(a)-[:SUPPORTED_BY]->(x)` counts chunks as support (forbidden CHUNK_MATCH -> SOURCE_SUPPORT) |
| Retire `SUPPORTED_BY_DOCUMENT` outright | force every live consumer to locators | live types on 11 domains read it; a derived shortcut that must name its locator costs nothing and keeps the API |
| Keep `HAS_TRANSCRIPT` as authoritative | Episode owns its transcripts | a transcript belongs to one rendition capture; the YouTube cue text and the publisher page text differ (fixture 04, Q04-c) |
| Separate `TRANSCRIPT` node type | new type for transcripts | a transcript is a `DocumentTextVersion` with `WAS_GENERATED_BY` a TRANSCRIPTION or TEXT_EXTRACTION Activity; no failing case for a new type |
| NFKC for quote hashing | absorbs PDF ligatures (`ﬁ` to `fi`) | run on Neo4j and Python: NFKC turns `10⁶` into `106` and `µ` into `μ`; it corrupts quantities |
| Segmentation hash over text + config | idempotent per text | then the same configuration on a corrected text gets a different hash and "same configuration" is unanswerable (Q01-f) |
| Stored cross-rendition span alignment edge | `REANCHORS` across renditions | V-409 limits `REANCHORS` to one Source; quoteHash equality answers the exact case (Q04-a); fuzzy case left candidate (CQ-PV-C03) |

## 5. Smallest recommended model

Four node types (all live), two enums (live, one extended), one union (renamed live union), three relationship-property types (two registered, one requested), and these relationship types: structural `FROM_TEXT_VERSION`, `HAS_SEGMENTATION`, `NEXT_CHUNK`; derived `HAS_CHUNK`, `RESOLVES_TO_CHUNK`, `SUPPORTED_BY_CHUNK`, `SUPPORTED_BY_DOCUMENT`, `ABOUT`, `MENTIONS` (chunk), `OCCURS_IN_SEGMENT` (chunk); asserted `AUTHORED_BY`. Retired: `PREV_CHUNK`, `HAS_TRANSCRIPT`, `SOURCE_OF` (Document), `ASSERTS` from Chunk, the `SUPPORTED_BY -> Chunk` type name. No new node type, no new enum value beyond round 0006, no new activity kind (OCR is a `TEXT_EXTRACTION` method named in `methodVersion`).

## 6. Text production rules (OCR, PDF, HTML, XML, transcripts)

1. A text version is the producer's output as emitted (`normalizationVersion` null) or after a registered normalization the producer applied. Offsets count Unicode code points in the stored `text`, start inclusive, end exclusive (Web Annotation 4.2.5 and its code-point rule; run: Neo4j 5.26.31 `size('a😀b') = 3`, JavaScript `length = 4`). Writers in UTF-16 languages must convert.
2. `SourceLocator.normalizationVersion` (NFC-WS1) governs only the quote hash. The fixture-04 pair shows why: PDF line wraps disappear under NFC-WS1 (PDF and PMC HTML quote hashes are equal, `sha256:52bb34c1…`), but PDF word fusion ("toNR aloneinPAD"), dropped inline markup in the connector's JATS-derived text ("+∞,= 0.08", "(Tableand Fig.)") and the PDF affiliation footer inserted mid-sentence do not. Those need FUZZY re-anchoring or a second locator.
3. OCR is `TEXT_EXTRACTION` with the engine and language model in `Activity.methodVersion`; OCR output gets `languageCode` and no claim of exactness.
4. `TRANSCRIPTION` is used only when BellLabs or a named agent converts audio to text. Captured caption tracks and publisher transcript pages are snapshots whose text versions are `TEXT_EXTRACTION`; the upstream origin of a caption track (automatic or uploaded) is recorded as unknown unless the platform states it. YouTube's help page states that automatic captions "might misrepresent the spoken content", that creators can edit or remove them, that live-stream captions are regenerated for the VOD and "may be different", and that a setting masks words as "[ __ ]". So a caption text version is a capture of one track at one time, it can change silently, and it is never an audio verification.
5. Media time belongs to a rendition snapshot's timeline (`MEDIA_TIME` locator, W00). A text version without cue timing (the publisher page) never acquires offsets in seconds (Q04-c).
6. Re-running the same extractor and configuration on the same snapshot is idempotent: same `textVersionHash`, same text version (MERGE by uid derived from snapshot uid, method and hash; W20-SR-09).
