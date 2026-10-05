# W20 05 Decision and seam ledger

Status words: ACCEPTED-FOR-PROPOSAL (W20 recommends it and the fragment implements it), UNRESOLVED (needs another owner; the fragment states its assumption). Nothing here is a ruling; Fable and W00 rule. Seam requests are in `seam-requests.yaml` (W20-SR-01 … W20-SR-24).

## Decisions

| Id | Decision | Alternatives (and why rejected) | Evidence | Status |
|---|---|---|---|---|
| W20-D01 | `Document` is `["Document","Source","Entity"]`, archetype Entity, and carries the Source fields `canonicalUri`, `sourceKind`, `publisherUid`; `url` mirrors `canonicalUri`. | Document as a separate entity linked to a Source (two identities for one endpoint; CL-003/D-005 forbid) | D-005; round 0006 D1; W20-V05 run (N14) | ACCEPTED-FOR-PROPOSAL; W20-SR-08 for the Source side |
| W20-D02 | Frozen aliases kept; `name`, `documentKey`, DTV `source` relaxed to nullable. | keep `String!` (Cypher-ingested rows unreadable) | run: N13 read fails on non-null `id`; D-013 | ACCEPTED-FOR-PROPOSAL |
| W20-D03 | `DocumentType` = live + 8 round-0006 values; never a revision or truth state; `sourceKind` is the provenance genre; default mapping table in model cards. | merge DocumentType into SourceKind (loses live genre granularity and API); "RETRACTED" type (state, not genre) | round 0006 alignment row; catalog sourceKind | ACCEPTED-FOR-PROPOSAL; W20-SR-10 |
| W20-D04 | `DocumentTextVersion` stays canonical in provenance (T-003: no transfer); W20 writes its SDL; exactly one `TEXT_OF_SNAPSHOT`; `WAS_GENERATED_BY` required for new writes; `contentHash = textVersionHash`. | transfer to claims_and_documents (no failing case: every consumer is provenance-side) | fixture 04 (three text versions of one work) | ACCEPTED-FOR-PROPOSAL |
| W20-D05 | Offsets = Unicode code points in the stored DTV text, start inclusive, end exclusive; DTV `normalizationVersion` = what the producer applied; locator `normalizationVersion` governs the hash only. | count after NFC-WS1 (breaks substring reproduction; shifts 538→536 in fixture 04); UTF-16 units (Web Annotation forbids code units) | S10; S12 run; computed shifts | ACCEPTED-FOR-PROPOSAL; W20-SR-19 |
| W20-D06 | `Segmentation.segmentationHash` hashes configuration only (`strategy`, `chunkSize`, `overlap`, `methodVersion`); identity = (text version, hash); `methodVersion` names the unit and tokenizer. | hash over config + text (Q01-f could not say "same configuration") | fixture 01 Q01-f (run) | ACCEPTED-FOR-PROPOSAL; W20-SR-02, W20-SR-05 |
| W20-D07 | `Chunk` is derived; `charStart/charEnd` added; `PREV_CHUNK` retired (read `NEXT_CHUNK` IN); chunk `ASSERTS` retired (read `SUPPORTED_BY_CHUNK` IN from Claim). | keep stored inverses (drift) | round 0006 D1; INV-404 | ACCEPTED-FOR-PROPOSAL; W20-SR-14 |
| W20-D08 | All chunk support edges use one relationship type `SUPPORTED_BY_CHUNK` with `DerivedSupportProperties` (`locatorUid!`, `derivedFromAssertionUids!`, `derivationRule!`, `segmentationHash`); live `SUPPORTED_BY -> Chunk` is relabelled. | keep `SUPPORTED_BY -> Chunk` (one name with structural and derived meaning; label-free traversals count chunks as support) | KCR-4.5; catalog `SUPPORTED_BY_CHUNK` entry; fixture 02 N1–N4 (run) | ACCEPTED-FOR-PROPOSAL; W20-SR-17, W20-SR-18 |
| W20-D09 | `SUPPORTED_BY_DOCUMENT` kept as a derived shortcut with the same property type; its locator must hang from one of the document's snapshots. | retire (breaks 11 live consumers for no semantic gain) | fixture 02 N11 (run) | ACCEPTED-FOR-PROPOSAL |
| W20-D10 | Entity-type starts (Mechanism, Biomarker, Material, …) keep a chunk/document support shortcut only when an Assertion about them is SUPPORTED_BY the locator; otherwise migrate to retrieval `MENTIONS`. | keep as support (an entity is not a proposition; no locator can support "Mechanism X") | contract A3/A8; fixture 02 N3 | ACCEPTED-FOR-PROPOSAL; W20-SR-17 |
| W20-D11 | `RESOLVES_TO_CHUNK` is rule-only derived (`offset-overlap-v1` or `quote-search-nfcws1-v1`) and regenerated per segmentation; `coversWholeSpan` marks straddling spans. | require an input assertion (there is none) | fixture 01 (L1 resolves to two G2 chunks, one partially) | ACCEPTED-FOR-PROPOSAL; W20-SR-01 |
| W20-D12 | Re-segmentation of an unchanged capture: new Segmentation and chunks, regenerated `RESOLVES_TO_CHUNK` and `SUPPORTED_BY_CHUNK` with the new hash, old chunks deleted; locator, snapshot, text version, assertion untouched. Corrected capture: new snapshot, new text version, new locator `REANCHORS {FUZZY}` the old one; no shortcut from the old assertion into the new text version unless W00's re-anchor rule adds support. | mutate chunk text or locator offsets in place (destroys citation history) | fixture 01 Q01-a…e (run) | ACCEPTED-FOR-PROPOSAL; UNRESOLVED part W20-SR-06 |
| W20-D13 | `ABOUT` (document/chunk) and `MENTIONS` (chunk) are derived retrieval edges with `RetrievalEdgeProperties`; salience and aboutness are ranking features of one rule. | keep `ExtractionMetadata` (mixes evidence content and lineage) | round 0006 D9 | ACCEPTED-FOR-PROPOSAL; UNRESOLVED registry W20-SR-04, name conflicts W20-SR-12, W20-SR-13 |
| W20-D14 | `HAS_TRANSCRIPT` retired: a transcript is a text version of a rendition snapshot. `TRANSCRIPTION` activity only when a named agent transcribed audio; captured caption tracks and transcript pages are `TEXT_EXTRACTION`; caption origin unknown unless stated. | keep Episode→text link (cannot say which rendition) | S7, S8, S9; Q04-c (run) | ACCEPTED-FOR-PROPOSAL; W20-SR-15 |
| W20-D15 | `SOURCE_OF` (Document→Episode) retired to `RENDITION_OF`; `renditionOfPublications` added. | — | D-005 | ACCEPTED-FOR-PROPOSAL |
| W20-D16 | `isPrimarySource` read-only legacy. | delete (breaking read) ; keep writable (keeps a wrong per-document notion alive) | round 0006 alignment row | ACCEPTED-FOR-PROPOSAL; W20-SR-24 |
| W20-D17 | `AUTHORED_BY` is asserted (`AssertedEdgeProperties`), range `DocumentAuthorTarget`; author order is out of scope (W09 Publication authorship). | keep RoleMetadata (undated, no assertion) | contract B4 | ACCEPTED-FOR-PROPOSAL; W20-SR-03 |
| W20-D18 | OCR is a `TEXT_EXTRACTION` method (no new ActivityKind). | ActivityKind OCR (no failing case) | catalog activityKind | ACCEPTED-FOR-PROPOSAL |
| W20-D19 | NFC-WS1 stays the only hash normalization; NFKC rejected; a matching-only normalization is a candidate. | NFKC (corrupts `10⁶`, `µ`) | S12 run | ACCEPTED-FOR-PROPOSAL; W20-SR-20 candidate |
| W20-D20 | Cross-rendition span agreement is a computed `quoteHash` join; no stored alignment edge. | stored `ALIGNS_WITH` edge (no CQ beyond candidate C03) | Q04-a (run) | ACCEPTED-FOR-PROPOSAL; W20-SR-07 |
| W20-D21 | Retrieval partitions are query-time filters (privacy, active segmentation hashes, latest capture first, domain/sourceKind/language facets), not schema fields. | `isActive` flag on Segmentation (mutable state on an immutable artifact) | Q-AX-14b (run) | ACCEPTED-FOR-PROPOSAL |
| W20-D22 | `@fulltext` names and fields unchanged; indexes created on stored names; Fable can verify with the library's `assertIndexesAndConstraints()`. | rename fields in the directive to stored names (the library validates directive fields against GraphQL field names) | S11; run (wrong index: 0 hits, assertion error names the alias) | ACCEPTED-FOR-PROPOSAL |

## Objections recorded (W20 self-challenge)

| Objection | Answer |
|---|---|
| "Deleting old chunks loses history." | Chunks are derived; history lives on locators and snapshots. An index that needs reproducibility of a past retrieval keeps the Segmentation and its chunks; nothing cites them. |
| "Requiring derivedFromAssertionUids on every support shortcut blocks migration of legacy rows." | Legacy rows without a resolvable assertion are not support; they become retrieval `MENTIONS` (entity starts) or are reported (Claim starts) rather than silently promoted. |
| "Keeping both `documentType` and `sourceKind` duplicates." | They answer different questions (display genre vs authority genre); the mapping is deterministic by default and validated by curation. |
| "Content-derived uids leak content." | A sha256 digest of an identity tuple reveals nothing readable and is still opaque; W00 decides (W20-SR-09). |

## Kernel-change requests

None that change the kernel's meaning. W20-SR-01, -02, -05, -09, -19, -20 are catalog-convention clarifications or registrations aimed at W00, each with a failing case above.
