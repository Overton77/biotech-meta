# W22 completion report

- **Worker:** W22 Media assets, depictions and rights, run as **Opus 5.5** (`claude-opus-5-5`) for coordinator Fable 5.1, run `run-2026-10-04-fable51-01`. PRIORITY package.
- **Start:** 2026-10-04T00:48:09Z (first retrieval). **End:** 2026-10-04T01:41Z (digests computed).
- **Scope written:** only `workers/W22/`. No authority file, other worker directory or run-numbered file was edited. Scratch work (templates, the render script, the embedded databases) stayed in the session scratchpad under `w22/`. One shared-scratchpad side effect: at 00:59Z the run-harness scripts (`validation/harness/*`) were copied into the shared scratchpad `harness/` folder, overwriting same-named files there. Whether those earlier copies differed was not checked. All W22 executions used the 00:59Z harness version. Fable later updated `validation/harness/EmbeddedNeo4j.java` (01:36Z, plugin-directory option), so W22's runs used the earlier in-process builder without plugins. Nothing else in that folder was touched.

## 1. Tools used and availability

| Tool | Use | Result |
|---|---|---|
| Firecrawl `firecrawl_scrape` (markdown / JSON / includeTags) | Commons API, Reactome licence and content service, PMC article headers and figure legends, PMC copyright notice, BioStudies API, Elysium pages, W3C ODRL | worked; one `query`-format call failed ("Query generation failed after all models"); the ODRL definitions came from a freeform extraction (marked SEARCH_EXTRACT) |
| Firecrawl `firecrawl_search` | BioImage Archive discovery | worked (excerpts only) |
| Tavily `tavily_extract` | PMC article and Elysium product page | worked; returned body text only, no images or notices |
| PubMed MCP `get_copyright_status` | copyright metadata for 4 PMIDs | worked; one PMID `source: not_available` |
| WebFetch | Commons API, PMC | **EGRESS_BLOCKED** (both hosts) |
| direct HTTPS (curl) | image bytes (upload.wikimedia.org), reactome.org, ebi.ac.uk, ncbi | **BLOCKED** by egress proxy (CONNECT 403) |
| `@neo4j/graphql` 7.6.3 + graphql 16.14.2 (run harness `build-schema.mjs`) | fragment build with generated stubs for 90 external types | **OK**: 5,714 generated types; derived edges are read-only in create inputs |
| `merge-fragments.mjs` over all worker fragments present at 01:35Z | duplicate and undefined check | no duplicate involving W22. Found W00 still lists retired `MediaSource` (W22-SR-13) |
| Neo4j 5.26.31 Community, embedded (`neo4j-harness`), `run-cypher.mjs`, neo4j-driver 6.2.0 | fixtures, media validators, kernel suite, operations DDL, idempotence | all executed (section 3). The first instance was OOM-killed (21 concurrent worker JVMs); restarted with a 768 MB heap |
| ClinicalTrials.gov, bioRxiv, ICD-10, NPI | not needed for media questions | not used |
| Exa, bigdata.com, Figma | failed to connect at session start | not used |

## 2. Research gaps

1. **No raw image bytes were hashed.** Every image `contentHash` is `SYNTHETIC_FIXTURE`. The modelled byte-identity rules (V-602, MEDIA-EV-1) are exercised only on synthetic equal hashes (U-08).
2. BioImage Archive S-BIAD807: study-level metadata only. File names and per-file checksums were not retrieved, so the image Source is a placeholder URN.
3. Whether Elysium carousel image 5 is a photograph or rendered artwork, and whether it matches the physical label, is unknown. Its declaration content is assumed, not read.
4. Commons GFDL: only the category name was seen. The version and its validity as a current offer are unknown.
5. Reactome: whether diagram exports are "Pathway Illustrations" (CC BY 4.0) or "data-derived files" (CC0) is a curator interpretation; the stricter reading was recorded.
6. ODRL 2.2: only term definitions were read (extraction). No adoption review was done (OPEN-QUESTIONS P2-1 remains open).
7. No legal conclusion (fair use, copyrightability of pathway data, effect of crawler prohibitions) is made or encoded.

## 3. Execution evidence (all RUN on 2026-10-04)

| Item | Result |
|---|---|
| Fixtures MP1-MP6 (combined) | 373 statements, 0 errors; 226 nodes / 424 relationships |
| Media validators V-601…V-615 (combined and solo MP3/MP5/MP6) | 16/16 ran; rows only for the intentional negative members (06 table) |
| Kernel suite `docs/schema/neo4j/validation.cypher` on the combined load | 174/174 ran; only informational V-401b (5) and V-514b (33) non-zero. The first pass found V-003, V-101, V-110, V-231, V-232, V-504 and V-522 violations, all fixed in the fixtures |
| `operations.cypher` after baseline `constraints.cypher` (fresh store) | baseline 45/57 applied (12 edition rejections, as in 00-baseline); W22 Section A **27/27 applied**; Section B 12/12 rejected on Community (expected); MP1-MP6 then loaded under all constraints with 0 errors |
| Idempotence (two passes in one store) | no duplicate relationships; +2 `EVIDENCES` from re-running the global MEDIA-EV-1 job after MP5 inputs existed (expected; 07) |
| SDL fragment | graphql-js parse OK; Neo4jGraphQL 7.6.3 build OK with stubs (no vector provider) |

## 4. Unresolved seams (see 05 and seam-requests.yaml; 13 requests)

W00: uid tokens (SR-01); useKind DISPLAY_MEDIA (SR-02); PROV ranges for media (SR-03); activityKind MEDIA_GENERATION / MEDIA_TRANSFORMATION / MEDIA_ASSESSMENT (SR-04); IMG-PX1 normalization (SR-05); sourceKind MEDIA_FILE / MEDIA_REPOSITORY_RECORD / DATA_REPOSITORY_RECORD (SR-06); validator admission and forbidden implications (SR-08); AssertionSubjectTarget drops MediaSource and adds MediaRightsRecord (SR-13). W04: label seam and REGION_HAS_DECLARATION (SR-07). W07: Metric.mediaUrl/mediaType (SR-09). W23: PolicyVersion media content, duties, crawler-terms policy (SR-10; user input on rights vocabulary). W21: rendition/asset boundary (SR-11). W03: Association, Pathway token, mechanism-assertion shape (SR-12). Fable: whether operator photos may use structural DEPICTS (U-03).

## 5. Confidence per dimension

| Dimension | Confidence | Why |
|---|---|---|
| Asset vs source vs rendition boundary | high | grounded in real CDN renditions (S09), Commons stated SHA-1 (S01), executed V-602/V-606 |
| Depiction / explanation / evidence separation | high | derived-only EVIDENCES executed; negative members caught by V-604/V-605 |
| Rights model (stated terms vs permission) | medium-high | four real failing cases. The `rightsStatus` vocabulary and the policy allow-list await W23 and user input |
| Suitability assessment | medium | the structure is sound; the criteria and scores are synthetic (no real quality method exists yet) |
| Union membership | medium | depends on other owners' final type names (Fable prunes) |
| Operations and overhead | medium | executed on Community only; Enterprise Section B unverified |
| Byte-level reproducibility | low (evidence) / high (design) | no bytes captured in this session |

## 6. Artifacts (SHA-256; this report itself excluded)

```
fd35f331961fcba6a00d85601b63a66a077880a8b3de08b6e461a53980f6815c  01-domain-recommendation.md
f8be4844284f10ea9588feb083378ac311059ec08d629539d66276c63976739a  02-cq-coverage.md
d94a8d6bf96781e887c5783a9f529fa20dcf301ba88d586105111a5980b43238  03-source-manifest.md
4e36ba888da4290f4503de6f385fbdf9f192690f5f3115aa75255c403d6b00a1  04-model-cards.md
a1aa431553e7f110c7a32856fed5c302a8c4c815298cb1eba4f5448f674dd512  05-decision-seam-ledger.md
1ec0060e0618c7d2e4d3ea874276f5138d0a4b4a382d48748b35e4b14d31473e  06-fixtures-and-queries.md
2c9adfa529b5c734fb1b7b9c403bdb7d3222866f1d3ed32c9184878f89a42efb  07-operations.md
fefd0f2e78742a60912f8395ecb5e2fda1bc0d473c6ebf11f4246d10ec40afef  operations.cypher
fa9c0599c9a0eaf7673fa7010907c1ad3608126bccc4aa5f90e0fba3ea68a03d  sdl-fragment.graphql
765b39935cd912de81352e8057ba7423393f07595fc9308a8353a88435aae0d7  migration-map.yaml
2f2ffd415664724b13d2c070ebcbc3b30d5b0852887c8fa6345ac314e790f4a8  seam-requests.yaml
b8d366d606b3b05ebd0a29057fd90faefc13aba54fe7b467da1743e086773fd6  fixtures/mp1-product-asset-selection.cypher
4c5b54f23748ed2576eccfcdc4d6a753ab3e02852ff687e300083cae1e8a2889  fixtures/mp2-concept-asset-selection.cypher
5541eefc716e81f5554e23335e1da203a2effdb22b24f376783405050de114a0  fixtures/mp3-illustration-vs-microscopy-evidence.cypher
0b146e30036b9eae71cbfa46c0ae71b7b3ffbf67430274341be391034f964789  fixtures/mp4-rights-excellent-vs-licensed.cypher
0d6c72412926c0b2c3e85a89d607398ebadce642055acf084e44730346a4128e  fixtures/mp5-label-crop-region-provenance.cypher
a2dbdf1faecd237fe23b86f7f7a97582b8818afbc5dade97b4e6ffea29acf274  fixtures/mp6-edited-figure-vs-original-capture.cypher
a727d0922ecb67f1aff2cf018586a14724bc199627ab673eddb2dc32d6aa6e23  fixtures/v-media-validation.cypher
724ea8c86712114af2a578b17131b2a0ac9f62ce758206b10aa8d3c0610bd3d9  fixtures/execution-results.json
```

## 7. Review status and what remains qualified

- **Review status:** self-reviewed (Challenger pass in 05 §2). Executed against the kernel suite. No adversarial review by another worker yet (Wave 5).
- **Qualified:** synthetic hashes, scores and coordinates; the policy allow-list is an assumption; new enums, uid tokens and validator ids are proposals; the union members depend on other owners; the Reactome licence-class reading is an interpretation; image content (Elysium label, BIA file, publisher figures) was not inspected; no legal conclusions.
