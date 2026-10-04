# W20 06 Fixtures and queries

## Execution environment and order (all **run**)

- Neo4j **5.26.31 Community**, in-process (the run harness `EmbeddedNeo4j` class and jars), started by W20 on a **separate** data directory (Fable's instance untouched); `@neo4j/graphql` 7.6.3, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22.22.0; statements run with `validation/harness/run-cypher.mjs` (one transaction per statement, no variable crosses a `;`).
- Order: `operations.cypher` (25 statements, 25 ok) → `fixtures/w20-01-resegmentation-vs-correction.cypher` (54/54 ok) → validators (zero rows) → `w20-03-alias-roundtrip.cypher` (6/6) → `w20-04-text-version-pairs.cypher` (42/42) → `w20-queries.cypher` (14/14) → GraphQL round trip → `w20-02-negative-chunk-support.cypher` (17/17) → validators (expected rows).
- Validators: 15 baseline statements copied verbatim from `docs/schema/neo4j/validation.cypher` (V-110, V-111, V-111b, V-117, V-119, V-401, V-401b, V-402 … V-409) and the 10 W20 candidates (`operations.cypher` part C). V-112 was **not run** (needs parameter lists).
- Generators: `fixtures/gen01.py`, `fixtures/gen04.py` compute offsets, chunk spans and hashes (Python 3, code-point strings, NFC-WS1 as in the catalog). Every node carries its primary label and archetype label; `Document` nodes carry `Document:Source:Entity`.

## Fixture 01: re-segmentation of an unchanged capture vs a corrected capture (positive + minimal pair)

Synthetic transcript page (`https://transcripts.example.invalid/episode-52`) modelled on the round-0006 Huberman Lab case. Text version tv1 (snapshot 2026-10-03) contains "My 82 -year-old father, we take a gram of NMN every day." at code points [86, 142). Assertion A1 (`SELF_REPORTED_DAILY_INTAKE`, ACCEPTED, CAPTURE_FIDELITY adjudication) is `SUPPORTED_BY` L1 (TEXT_POSITION + quote anchor, quoteHash `sha256:96fe6eb5…`, identical to the repository fixture's hash for the same quote).

| Step | Graph delta | Expected | Result |
|---|---|---|---|
| Segmentation G1 (80/0, hash `sha256:aeb865ec…`) | 5 chunks; L1 `RESOLVES_TO_CHUNK` g1-c1 (covers whole span); A1 `SUPPORTED_BY_CHUNK` g1-c1 | — | loaded |
| Re-segmentation G2 (160/20, hash `sha256:ef2138d9…`) of the **unchanged** tv1, then G1 deleted | 3 new chunks; L1 resolves to g2-c0 (whole span) and g2-c1 (straddles, `coversWholeSpan:false`); A1 shortcuts regenerated | Q01-a 2 rows (g2-c0 true, g2-c1 false), Q01-b 2 rows naming `hu:locator:w20f01-l1-nmn-gram` and hash `ef2138d9…`, Q01-c `offsetsReproduceQuote = true` with unchanged quoteHash, Q01-d `g1ChunksRemaining = 0` | **as expected** |
| **Corrected** capture 2026-11-02 | new snapshot, new text version tv2 ("82-year-old"), L2 [86,141) `REANCHORS {anchorMatch: FUZZY}` L1; G3 = same configuration on tv2 (same hash `ef2138d9…`, different chunk text) | Q01-e one row: A1 via L2→L1, `sameQuoteHash = false`, `chunkShortcutsIntoCorrectedText = 0`; Q01-f two rows with equal segmentationHash and different chunk0 hashes (`2f17ba13…` vs `07f6347c…`) | **as expected** |
| Trace | QS-1a core (Q01-g) | `traceGaps = []`, 1 locator, adjudication `hu:adjudication:w20f01-cf-a1` | **as expected** |
| Lineage (CQ-PV-03) | Q01-h | capture `w20f01-capture-1`, extraction `w20f01-extract-1` (`html-text-extract-v2`), segmentation `[w20f01-segment-g2]` | **as expected** |
| Validators on fixture 01 alone | V-110…V-409, W20-V01…V10 | zero rows (V-401b returns its single informational count row = 0) | **zero rows** |

## Fixture 02: negatives (load after 01; each must be reported by the named check)

| Case | Defect | Expected check | Result (run) |
|---|---|---|---|
| N1 | Assertion `-[:SUPPORTED_BY]->` Chunk, legacy type, **no locatorUid** | V-407 and W20-V01 (`LEGACY_SUPPORTED_BY_TO_CHUNK`, `NO_LOCATOR_UID`, `NO_DERIVATION_RULE`) | V-407: 1 row (`w20f02-n1…`, `g2-c0`); W20-V01: row with those three violations |
| N2 | `SUPPORTED_BY_CHUNK` without locatorUid (rule `vector-similarity-top1`) | W20-V01 `NO_LOCATOR_UID`; **V-407 misses it** (type differs) | W20-V01 row; V-407 no row |
| N3 | Mechanism (Entity) `-[:SUPPORTED_BY]->` Chunk without locator | W20-V01; **V-407 misses it** (start is not an Assertion) | W20-V01 row |
| N4 | CHUNK_MATCH as SOURCE_SUPPORT: A1 `SUPPORTED_BY_CHUNK` g2-c2 naming L1, but L1 does not resolve to g2-c2 | W20-V01 `LOCATOR_DOES_NOT_RESOLVE_TO_CHUNK` | row |
| N5 | Chunk also labelled SourceLocator | V-406 (and V-402: locator without snapshot) | V-406 1 row; V-402 1 row |
| N6 | Locator on snapshot 2026-10-03 with offsets in tv2 (text of snapshot 2026-11-02) | V-404 | 1 row (`w20f02-n6…`, `w20f01-tv2`) |
| N7 | `RESOLVES_TO_CHUNK` without segmentationHash (L1→g2-c2) | V-408; W20-V10 (`SEGMENTATION_HASH_MISMATCH`, `NO_SPAN_OVERLAP`) | V-408 1 row; W20-V10 1 row |
| N8 | Text version `TEXT_OF_SNAPSHOT` two snapshots | V-405 | 1 row (`snapshots: 2`) |
| N9 | TEXT_POSITION offsets without a text version | V-403 | 1 row |
| N10 | Offsets 87–143 (a UTF-16-style off-by-one) for an exact quote at 86–142 | W20-V03 | 1 row |
| N11 | StudyArm `-[:SUPPORTED_BY_DOCUMENT]->` Document without locatorUid | W20-V02 (`NO_LOCATOR_UID`, `NO_DERIVATION_RULE`) | 1 row |
| N12 | Chunk text not equal to its span | W20-V06 | 1 row |
| N13 | Document written with GraphQL names (`documentType`, `sourceUrl`, `name`; no `documentId`, no `type`) — the shape in `examples/claim-retelling-provenance.cypher` | W20-V04 (5 findings), W20-V05 (url null) | rows as expected |
| N14 | `url` ≠ `canonicalUri` (`?utm_source=x`) | W20-V05 | row |

The task's mandatory negative "a `SUPPORTED_BY` → Chunk edge without locatorUid must fail V-404/V-407" is N1: it fails **V-407** (and W20-V01). V-404 does not test chunk edges; it tests locator/text-version/snapshot agreement and is exercised by N6.

## Fixture 03: alias round trip

Cypher writes stored names (`documentId`, `title`, `url`, `type`, `documentTextVersionId`, `segmentationId`, `strategy`, `chunkId`, `chunkKey`, `index`).

- **Q-ALIAS-CYPHER / Q03-a (run)**: one row, all stored names non-null; `d.name` and `d.documentType` (GraphQL names) are null on the stored node, as they must be.
- **Q-ALIAS-GQL (run here against the W20 fragment + test stubs; NOT run against Fable's merged schema)**: `fixtures/w20-gql-roundtrip.mjs` builds `Neo4jGraphQL` from `sdl-fragment.graphql` + `fixtures/w20-test-stubs.graphql` and runs

```graphql
query($uid: String!) { documents(where: { uid: { eq: $uid } }) {
  id uid name documentType sourceUrl canonicalUri isPrimarySource entityType
  hasTextVersions { id textVersionHash hasSegmentations { id segmentationStrategy segmentationHash } chunks { id name chunkIndex charStart charEnd } }
  hasChunks { id name chunkIndex } } }
```

  Result: `id "0f6c1e2a-…"`, `name "Alias round-trip fixture"`, `documentType WEBPAGE`, `sourceUrl "https://alias.example.invalid/doc"`, text version id `9e8d7c6b-…`, `segmentationStrategy "fixed-window"`, chunk `id "7a6b5c4d-…"`, `name "alias#0"`, `chunkIndex 0`; `searchDocuments(phrase: "Alias")` returns the node (score 1.017); `assertIndexesAndConstraints()` → OK. **Fable action**: rerun the same query against the merged schema (not-run there).
- **Negative GraphQL read (run)**: the same query for N13 returns `Cannot return null for non-nullable field Document.id.`
- **Index alias check (run)**: with `DocumentSearch` recreated on `[name, sourceUrl, searchText]`, a fulltext query for "Alias" returns **0 hits** without error, and `assertIndexesAndConstraints()` fails with "`@fulltext index 'DocumentSearch' on Node 'Document' is missing field 'name' aliased to field 'title'`" and the same for `sourceUrl`/`url`. Index restored afterwards.

## Fixture 04: real text-version pairs (NEW_RETRIEVAL stored excerpts)

| Query | Expected | Result (run) |
|---|---|---|
| Q04-a cross-rendition alignment by quoteHash | 2 groups: `52bb34c1…` = PDF + PMC HTML; `1b2ef40c…` = connector text | as expected (start offsets 538/524 vs 514) |
| Q04-b offsets per text version | PDF 538–737 (199), connector 514–704 (190, `keepsPValueSymbol = false`), PMC HTML 524–723 (199) | as expected |
| Q04-c episode renditions | TRANSCRIPT_PAGE: TEXT_POSITION, no media time, quoteHash `96fe6eb5…`; VIDEO_PAGE: MEDIA_TIME 3765 s, quoteHash `c00f9f5c…` ("my 82-year-old …") | as expected; no automatic alignment; no audio verification claimed |
| Q-AX-14 `DocumentSearch` "NICE" | 3 Document candidates, display names via `coalesce(name, title, chunkKey)`, lexical scores only | 3 rows (0.341, 0.330, 0.299) |
| Q-AX-14b `ChunkSearch` "NMN", active segmentation partition, public, latest capture first | chunks of tv2 (2026-11-02) before tv1 (2026-10-03), all with hash `ef2138d9…` | 4 rows as expected |

Vector index check (run, Community 5.26.31): `CREATE VECTOR INDEX ChunkSearchEmbedding … vector.dimensions 4, cosine` → ONLINE; `db.index.vector.queryNodes('ChunkSearchEmbedding', 5, [1,0,0,0])` returned g2-c0 (0.997) and g3-c0 (0.985). Two chunks of two captures of one sentence are both near neighbours: retrieval must deduplicate by locator/Source, never count them as two supports.

## Mandatory coverage map

| Required | Where |
|---|---|
| Re-segmentation of an unchanged capture vs corrected capture | fixture 01 (Q01-a…f) |
| SUPPORTED_BY → Chunk without locatorUid fails V-407 | fixture 02 N1 (also N2–N4 for the gaps) |
| Alias check, Cypher-created Document read through GraphQL names | fixture 03 (Q-ALIAS-CYPHER run; Q-ALIAS-GQL run on fragment + stubs; merged-schema round trip not-run, for Fable) |
| Temporal correction / late arrival | fixture 01 corrected capture (new snapshot, REANCHORS; old citation preserved) |
| Identity collision | fixture 04: three Document endpoints match "NICE" and are three renditions of one Publication, not three works; N14 URL variants |
| Missing facts | YouTube caption origin unknown (no field invented); connector endpoint unknown (W20-SR-21); `normalizationVersion` null for producer output |
| Access leakage | Q-AX-14b filters `privacyClass = PUBLIC`; no private nodes in W20 fixtures; search text built only from public fields (V-119 zero rows) |
| Forbidden implication CHUNK_MATCH → SOURCE_SUPPORT | N2, N4 (W20-V01) |
| Essential CQs covered: CQ-AX-07 (V-110/V-111/V-401/W20-V01), CQ-AX-14 (Q-AX-14), CQ-PV-04 (Q04-b), CQ-EV-01 (Q01-b), CQ-CL-08 (Q04-c) | above |

## Reproduce

```
node validation/harness/run-cypher.mjs <bolt> workers/W20/operations.cypher
node validation/harness/run-cypher.mjs <bolt> workers/W20/fixtures/w20-01-resegmentation-vs-correction.cypher
# run docs/schema/neo4j/validation.cypher ids V-110..V-409 and operations.cypher part C: expect zero rows
node validation/harness/run-cypher.mjs <bolt> workers/W20/fixtures/w20-03-alias-roundtrip.cypher
node validation/harness/run-cypher.mjs <bolt> workers/W20/fixtures/w20-04-text-version-pairs.cypher
node validation/harness/run-cypher.mjs <bolt> workers/W20/fixtures/w20-queries.cypher
node workers/W20/fixtures/w20-gql-roundtrip.mjs [documentUid]   # from a directory with @neo4j/graphql 7.6.3; edit the schema path and bolt URI
node validation/harness/run-cypher.mjs <bolt> workers/W20/fixtures/w20-02-negative-chunk-support.cypher
# rerun validators: expect the rows listed for N1..N14
```
