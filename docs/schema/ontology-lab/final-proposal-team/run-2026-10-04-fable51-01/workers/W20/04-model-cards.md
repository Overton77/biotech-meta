# W20 04 Model cards

Conventions: kind = asserted | observed | calculated | inferred | operational. Privacy class is PUBLIC unless stated; `mongoResearchRunId` is INTERNAL (operator tier) everywhere. Temporal behaviour: all W20 nodes are immutable after commit except `updatedAt` and one-time backfills named below; nothing in W20 carries valid time. Maturity proposals: PROVISIONAL for the four node types (live, catalog-aligned), CANDIDATE for `RetrievalEdgeProperties` until registered.

## Node: Document

- **Meaning**: one document endpoint at one canonical URI (web page, PDF, transcript page, registry record page, feed item). Specialization of provenance `Source` (D-005). Not the work, not a capture, not a text.
- **Archetype / labels**: Entity; `@node(labels: ["Document","Source","Entity"])`. uid token `document` (catalog); a node first written as `Source` keeps `hu:source:` (uids never change).
- **Identity keys**: `uid` (unique), `documentId` = opaque segment (unique), `canonicalUri` (unique under the W00 `Source` constraint). Aliases (frozen): `id→documentId`, `name→title`, `documentType→type`, `sourceUrl→url`. `documentKey` is a legacy ingestion key, not identity. Name and URL similarity never establish identity.
- **Properties**

| Field (stored) | Type, null | Meaning, value states | Kind |
|---|---|---|---|
| `entityType` | String! | 'Document' | operational |
| `canonicalUri` | String | Source endpoint URI; equals `url` (W20-V05). Null only on legacy rows. | observed |
| `sourceKind` | SourceKind (W00) | provenance genre used by authority rules; null = not yet classified | asserted by curator rule (operational mapping below) |
| `publisherUid` | String | resolved publisher Organization uid; null = unresolved (never "no publisher") | inferred |
| `documentKey` | String | legacy natural key | operational |
| `documentType` (`type`) | DocumentType! | display genre; UNKNOWN when not classified; never truth or revision state | operational |
| `sourceUrl` (`url`) | String | mirror of canonicalUri | observed |
| `documentDomain` | DocumentDomain | facet; UNKNOWN allowed | operational |
| `publisher`, `publicationVenue` | String | verbatim display | observed |
| `publishedAt` | DateTime | first stated publication time; cache of the earliest snapshot's `publishedAt` | observed (cache) |
| `fileFormat` | String | media type served | observed |
| `languageCode` | String | BCP 47 | observed |
| `isPeerReviewed`, `isRegulatorySource`, `isFinancialDisclosure` | Boolean | venue/genre facts; null = unknown, false = known not | asserted |
| `isPrimarySource` | Boolean, read-only | advisory deprecated legacy | operational (legacy) |
| `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` | | derived search surface (INV-107, V-119) | calculated |

- **Edges**: see relationship cards. **CQs**: CQ-PV-02, CQ-PV-05, CQ-EV-01, CQ-EV-05, CQ-AX-14. **Sources**: round 0006 D1; S7, S8; I2.

### DocumentType → SourceKind default mapping (operational; overridable per document by curation)

| DocumentType | default SourceKind | note |
|---|---|---|
| SCIENTIFIC_ARTICLE, REVIEW_ARTICLE, META_ANALYSIS, SYSTEMATIC_REVIEW, CASE_REPORT | PEER_REVIEWED_PUBLICATION if `isPeerReviewed`, else PREPRINT or null | peer review is a venue fact |
| PREPRINT | PREPRINT | |
| CORRECTION_NOTICE / RETRACTION_NOTICE / EXPRESSION_OF_CONCERN | CORRECTION_NOTICE / RETRACTION_NOTICE / EXPRESSION_OF_CONCERN | |
| REINSTATEMENT_NOTICE | CORRECTION_NOTICE | catalog SourceKind has no reinstatement value; W19/W00 may add one (W20-SR-10) |
| CLINICAL_TRIAL_RECORD, TRIAL_RESULT, REGULATORY_FILING, SAFETY_COMMUNICATION | REGULATORY_RECORD | |
| GUIDELINE, POLICY | REGULATORY_GUIDANCE or STANDARDS_DOCUMENT | by publisher |
| SEC_FILING, ANNUAL_REPORT, QUARTERLY_REPORT | SECURITIES_FILING | |
| PRESS_RELEASE | PRESS_RELEASE | |
| PRODUCT_LABEL, PACKAGE_INSERT, SAFETY_DATA_SHEET | MANUFACTURER_LABEL_PAGE | |
| WEBPAGE, BLOG_POST, WHITE_PAPER, INVESTOR_PRESENTATION | ORGANIZATION_WEBPAGE or MARKETING_PAGE | by publisher and content |
| TRANSCRIPT_PAGE | PODCAST_TRANSCRIPT_PAGE | |
| VIDEO_PAGE | VIDEO_RENDITION | |
| AUDIO_FEED_ITEM | AUDIO_FEED_ITEM | |
| NEWSLETTER_ISSUE, NEWS_ARTICLE | NEWSLETTER (news: null until W19 rules) | |
| PATENT, PATENT_APPLICATION | LEGAL_RECORD | W14 may refine |
| DATASET, DATABASE_RECORD | TERMINOLOGY_RECORD or null | by content |
| others, UNKNOWN | null | |

## Node: DocumentTextVersion

- **Meaning**: text rendering of exactly one SourceSnapshot by one Activity (TEXT_EXTRACTION incl. OCR, or TRANSCRIPTION). Offsets count Unicode code points in `text` as stored. Not the capture, not a locator.
- **Archetype / labels**: InformationArtifact; `["DocumentTextVersion","InformationArtifact"]`; uid token `text-version`. Canonical module provenance (T-003: stays; W20 writes SDL).
- **Identity**: `uid`; `documentTextVersionId` (alias of `id`). Idempotence key (service): (snapshot uid, producer methodVersion, textVersionHash). Recommended deterministic opaque segment: hex sha256 of that triple (W20-SR-09).
- **Properties**

| Field | Type, null | Meaning | Kind |
|---|---|---|---|
| `artifactType` | String! | 'DocumentTextVersion' | operational |
| `textVersionHash` | String! | `sha256:<hex>` over UTF-8 of `text` | calculated |
| `contentHash` | String | equals `textVersionHash` (W20-V09) | calculated |
| `text` | String! | full produced text | observed (by the producer) |
| `versionLabel` | String | human label | operational |
| `source` | String | live display label of the producer; lineage is WAS_GENERATED_BY | operational (legacy) |
| `normalizationVersion` | String | registered normalization already applied to `text`, null = producer output as emitted | operational |
| `languageCode` | String | BCP 47 of `text` (caption track, OCR language, translation) | observed |
| `publishedAt` | DateTime | only for published texts (publisher transcript); null for extractor output | observed |
| `observedAt` | DateTime | copy of snapshot `observedAt` | observed |

- **Rules**: exactly one `TEXT_OF_SNAPSHOT` (V-405); exactly one incoming `HAS_TEXT_VERSION` from the Source that has the snapshot; at least one `WAS_GENERATED_BY` for new writes; a TEXT_POSITION locator bound to it must hang from the same snapshot (V-404) and reproduce `exact` (W20-V03). Never edited: a corrected capture produces a new text version (fixture 01).
- **CQs**: CQ-PV-02, CQ-PV-03, CQ-PV-04, CQ-PV-C01. **Sources**: S1–S3, S7, S8, S10, S12.

## Node: Segmentation

- **Meaning**: configuration and run envelope of one chunking of one text version; operational, never evidence.
- **Archetype / labels**: InformationArtifact; `["Segmentation","InformationArtifact"]`; uid token `segmentation` (registration requested, W20-SR-02).
- **Identity**: (text version, `segmentationHash`); `segmentationId` alias of `id`; `strategy` alias of `segmentationStrategy`.
- **Properties**: `segmentationHash` String! = `sha256:<hex>` over canonical JSON `{"chunkSize","methodVersion","overlap","strategy"}` (sorted keys, no spaces; fixture values `sha256:aeb865ec…` for 80/0 and `sha256:ef2138d9…` for 160/20); `chunkSize` Int!, `overlap` Int! in the unit named by `methodVersion` (e.g. `unit=CODE_POINT` or a tokenizer id); `segmentationStrategy` String!; `methodVersion` String (segmenter + tokenizer + unit; part of the hash input). Kind: operational.
- **Edges**: `HAS_SEGMENTATION` (in, exactly one), `WAS_GENERATED_BY` Activity SEGMENTATION (zero_or_one; W20-SR-05).
- **Lifecycle**: a superseded configuration's chunks and derived edges may be deleted (fixture 01 deletes G1); the Segmentation node may be deleted with them or kept for lineage. Nothing that cites evidence points at it.
- **CQs**: CQ-PV-03, CQ-PV-C02.

## Node: Chunk

- **Meaning**: derived retrieval unit, the span `[charStart, charEnd)` of one text version produced by one segmentation. Never a locator (V-406), never support.
- **Archetype / labels**: InformationArtifact; `["Chunk","InformationArtifact"]`; uid token `chunk`.
- **Identity**: (text version, `segmentationHash`, `index`); `chunkId` alias of `id`; `chunkKey` alias of `name` (presentation and idempotence aid; e.g. `<segmentationId>#<index>`); `index` alias of `chunkIndex`.
- **Properties**: `text` String! (= span, W20-V06); `segmentationHash` String (required for new writes); `charStart`, `charEnd` Int (code points); `contentHash` (sha256 of text); search surface fields as Document. Kind: calculated.
- **Edges**: `FROM_TEXT_VERSION` (exactly one), `NEXT_CHUNK` (structural, within one segmentation), derived `HAS_CHUNK` (in), `MENTIONS`, `ABOUT`, `SUPPORTED_BY_CHUNK` (in, read as `assertsClaims` from Claim), `RESOLVES_TO_CHUNK` (in), `OCCURS_IN_SEGMENT`.
- **CQs**: CQ-AX-14, CQ-PV-02, CQ-PV-C02, CQ-CL-08.

## Relationship cards

| Type | Domain → range | Direction (field) | Class | Cardinality | Properties | Rule / derivation | Owner |
|---|---|---|---|---|---|---|---|
| `HAS_SNAPSHOT` | Document(Source) → SourceSnapshot | OUT `Document.snapshots` | structural | many | none | W00 relationship; live Organization/Product `HAS_SNAPSHOT` to VersionedState snapshots shares the name (W20-SR-11) | W00 |
| `HAS_TEXT_VERSION` | Document(Source) → DocumentTextVersion | OUT `hasTextVersions`; IN `DocumentTextVersion.documents` | structural | many / exactly one in | none | text version's snapshot must be one of the Source's snapshots | W00 |
| `TEXT_OF_SNAPSHOT` | DocumentTextVersion → SourceSnapshot | OUT `textOfSnapshot` | structural | exactly one | none | V-405 | W00 |
| `LOCATOR_IN_TEXT_VERSION` | SourceLocator → DocumentTextVersion | IN `DocumentTextVersion.locators` | structural | zero_or_one per locator | none | V-403, V-404, W20-V03 | W00 |
| `WAS_GENERATED_BY` | DocumentTextVersion, Segmentation → Activity | OUT `wasGeneratedBy` | structural | one_or_more / zero_or_one | none | Segmentation in domain requested (W20-SR-05) | W00 |
| `RENDITION_OF` | Document → Episode \| Publication | OUT `renditionOfEpisodes`, `renditionOfPublications` | structural | many | none | replaces live `SOURCE_OF` | W00 |
| `HAS_SEGMENTATION` | DocumentTextVersion → Segmentation | OUT `hasSegmentations`; IN `Segmentation.textVersion` | structural | many / exactly one in | none (was OrderingMetadata) | one per segmentationHash per text version | W20 |
| `FROM_TEXT_VERSION` | Chunk → DocumentTextVersion | OUT `fromTextVersions`; IN `DocumentTextVersion.chunks` | structural | exactly one | none (was RoleMetadata) | W20-V07 | W20 |
| `NEXT_CHUNK` | Chunk → Chunk | OUT `nextChunks`; IN `previousChunks` | structural | zero_or_one | none (was OrderingMetadata) | same text version and segmentationHash; `index` + 1 | W20 |
| `PREV_CHUNK` | — | — | retired | — | — | read as NEXT_CHUNK IN | W20 |
| `HAS_CHUNK` | Document → Chunk | OUT `hasChunks` (read-only); IN `Chunk.documents` | derived (rule-only) | many | DerivedEdgeProperties (`derivationRule` = 'chunk-of-document-text-version-v1') | chunk FROM_TEXT_VERSION a text version of the Document | W20 |
| `RESOLVES_TO_CHUNK` | SourceLocator → Chunk | IN `Chunk.resolvedFromLocators` (read-only) | derived (rule-only; W20-SR-01) | many (a span may straddle chunks) | ChunkResolutionProperties | spans overlap in the same text version; regenerated per segmentation (V-408, W20-V10) | W20 |
| `SUPPORTED_BY_CHUNK` | Assertion \| Claim \| live domain types → Chunk | OUT on owners' types (`supportedByChunks`); IN `Chunk.assertsClaims` (Claim only, read-only) | derived | many | DerivedSupportProperties | exists iff an input Assertion is SUPPORTED_BY `locatorUid` and that locator RESOLVES_TO_CHUNK the chunk with the same segmentationHash (W20-V01) | W20 |
| `SUPPORTED_BY_DOCUMENT` | Assertion \| live domain types → Document | OUT on owners' types (`supportedByDocuments`) | derived | many | DerivedSupportProperties (`segmentationHash` null) | exists iff an input Assertion is SUPPORTED_BY `locatorUid` and the locator hangs from a snapshot of the Document (W20-V02) | W20 |
| `ABOUT` (document/chunk) | Document, Chunk (and live Claim/ExperienceReport fields, owners' choice) → AssertionSubjectTarget | OUT `about` | derived (retrieval, rule-only) | many | RetrievalEdgeProperties | ranking feature of `derivationRule`; never evidence, never HAS_SUBJECT; W18 event ABOUT conflict (W20-SR-12) | W20 |
| `MENTIONS` (chunk) | Chunk → AssertionSubjectTarget | OUT `mentions` | derived (retrieval, rule-only) | many | RetrievalEdgeProperties | a surface form in the chunk linked by the named rule; not endorsement, not identity (kernel `MENTIONS` Locator→Mention shares the name, W20-SR-13) | W20 |
| `OCCURS_IN_SEGMENT` (chunk) | Chunk → EpisodeSegment | OUT `inEpisodeSegments` (read-only) | derived (rule-only) | many | DerivedEdgeProperties | requires a time-aligned text version of a rendition; never from a page without timing | W20 |
| `AUTHORED_BY` | Document → Person \| Organization | OUT `authoredBy` | asserted | many | AssertedEdgeProperties | projection of a byline assertion on a snapshot locator | W20 |
| `ASSERTS` | ProductLabelRegion → Claim (W22 field) | — | derived | many | DerivedSupportProperties | kept only for W22; retired from Chunk | W20 (semantics), W22 (field) |
| `HAS_TRANSCRIPT` | Episode → DocumentTextVersion | — | retired | — | — | rendition Source → snapshot ← TEXT_OF_SNAPSHOT text version | W20 |
| `SOURCE_OF` (Document) | Document → Episode | — | retired | — | — | RENDITION_OF | W20 |

## Relationship-property types

**ChunkResolutionProperties** (W20; contains every DerivedEdgeProperties field): `projectionOfAssertionUid` (always null), `derivationRule` String! (`offset-overlap-v1` when both spans have offsets; `quote-search-nfcws1-v1` for quote-only locators), `derivedFromAssertionUids`/`derivedFromAssessmentUids` (null), `derivedAt`, `mongoResearchRunId` (INTERNAL), `segmentationHash` String!, `coversWholeSpan` Boolean (true when the locator span lies inside the chunk), `activityUid`. Kind calculated.

**DerivedSupportProperties** (W20; contains every DerivedEdgeProperties field): `projectionOfAssertionUid` (null), `derivationRule` String!, `derivedFromAssertionUids` [String!]! (non-empty), `derivedFromAssessmentUids`, `derivedAt`, `mongoResearchRunId`, `locatorUid` String!, `segmentationHash` (required for Chunk targets), `activityUid`. Replaces `ExtractionMetadata` on support shortcuts. Kind calculated.

**RetrievalEdgeProperties** (W20, CANDIDATE pending registry W20-SR-04; contains every DerivedEdgeProperties field): `derivationRule` String! (extraction model and version), `salience`, `aboutness` Float in [0,1] comparable only within one rule, `segmentationHash` (chunk edges), `activityUid`. Kind calculated. Not confidence (INV-407 does not apply because these are not confidence values; they are never shown as such).

## Enums

**DocumentType** (W20): live 37 values + CORRECTION_NOTICE, RETRACTION_NOTICE, EXPRESSION_OF_CONCERN, REINSTATEMENT_NOTICE, TRANSCRIPT_PAGE, VIDEO_PAGE, AUDIO_FEED_ITEM, NEWSLETTER_ISSUE (round 0006). Never a revision or truth state.
**DocumentDomain** (W20): live values unchanged.

## Union

**DocumentAuthorTarget** = Person | Organization (W20; renames live `DocumentAuthor`; registry request W20-SR-03).
