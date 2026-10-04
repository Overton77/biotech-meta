# W22 fixtures and queries

**Execution status: RUN.** Every fixture and query below was executed on 2026-10-04 against **Neo4j 5.26.31 Community** (embedded, `org.neo4j.test:neo4j-harness:5.26.31`, OpenJDK 21) with the run harness (`validation/harness/run-cypher.mjs`, one transaction per statement, no variables shared across `;`, `neo4j-driver` 6.2.0). Two sequences were run:

- **combined:** wipe; MP1 → MP6; `v-media-validation.cypher`; then the repository kernel suite `docs/schema/neo4j/validation.cypher` with the harness `validation-params.json`.
- **solo:** wipe; MP3, MP5 or MP6 alone; `v-media-validation.cypher`.

Per-statement results are in `fixtures/execution-results.json` (row counts and up to six sample rows per query). Totals: 373 fixture statements (MP1 78, MP2 78, MP3 50, MP4 81, MP5 40, MP6 46), 0 errors; 16 media validation statements, 0 errors; kernel suite 174 statements, 0 errors. The combined load holds 226 nodes and 424 relationships.

Fixture conventions: each `.cypher` file binds every node by `uid` in every statement; nodes carry the primary label and the archetype label (`:MediaAsset:InformationArtifact`, `:Source:Entity`, `:Activity:Occurrence`, `:MediaRightsRecord:VersionedState`, `:MediaSuitabilityAssessment:EvidenceAssessment`, `:PolicyVersion:VersionedState`, …). All hashes are `SYNTHETIC_FIXTURE` (`sha256:` over a uid; a rendition that has the same bytes as a snapshot repeats that snapshot's value). `quoteHash` values are real NFC-WS1 sha256 hashes of the quoted text. Media uid tokens are the proposed ones (W22-SR-01). Each fixture ends with a capture-fidelity Adjudication per ACCEPTED assertion; these are synthetic review records, required by kernel V-110. Sources of real content are in `03-source-manifest.md`.

Source files: the rendered fixtures are generated from templates by a small script (`{{H:uid}}` → synthetic sha256, `{{Q:text}}` → NFC-WS1 quote hash, privacyClass and adjudication insertion). The rendered `.cypher` files are self-contained; the templates are not part of the packet.

## Mandatory minimal pairs → files

| Minimal pair (brief / handoff section 6) | File | Positive member | Negative member |
|---|---|---|---|
| Quality asset selection for a **Product**: suitability assessment vs unsourced score | `mp1-product-asset-selection.cypher` | A3 BellLabs jar photo, method-versioned SUITABLE 0.82 + operator rights | A4 legacy image with unsourced `qualityScore` 0.97; A1 Elysium hero SUITABLE 0.93 but RESTRICTED_TERMS |
| Quality asset selection for a **concept** (Mechanism and Metric) | `mp2-concept-asset-selection.cypher` | C2 generated mTOR explainer SUITABLE 0.88 (labelled generated); C1 Commons diagram SUITABLE as THUMBNAIL; C4 Metric explainer | C3 legacy diagram, unsourced 0.95, rights never checked; C1 MARGINAL in the diagram slot |
| Mechanism illustration vs measured microscopy evidence (EXPLAINS vs EVIDENCES) | `mp3-illustration-vs-microscopy-evidence.cypher` | E1 S-BIAD807 confocal capture, IMAGE_REGION locator → ORIGINAL rendition, CC0, derived EVIDENCES | G1 generated illustration: EXPLAINS only; bad ingestion n1 (cited as a source region) and n2 (hand-written EVIDENCES) |
| Visually excellent image with insufficient permission vs licensed usable rendition | `mp4-rights-excellent-vs-licensed.cypher` | P1 Reactome R-HSA-196807 diagram, CC BY 4.0 (attribution + indicate changes) | P2 Elsevier 2020 Figure I (best score 0.96, ALL_RIGHTS_RESERVED, freely readable in PMC); P3 NO_STATEMENT_FOUND; P4 never checked; display activities BAD-1 (no AUTHORIZED_BY) and BAD-2 (authorized without a permitting record) |
| Crop derived from a label photo retaining region and snapshot provenance | `mp5-label-crop-region-provenance.cypher` | CROPPED rendition ← MEDIA_TRANSFORMATION ← ORIGINAL 1946 px rendition + MediaAnnotation ← IMAGE_REGION locator (LOCATES_REGION) ← LabelSnapshot ← CDN Source; ProductLabelRegion → LabelDeclaration | n1 annotation drawn on the crop but cited through the original snapshot; n2 dangling IMAGE_REGION locator |
| Edited scientific figure vs original capture (isEdited, lineage Activity) | `mp6-edited-figure-vs-original-capture.cypher` | S-BIAD807 ORIGINAL capture; ANNOTATED rendition with its MEDIA_TRANSFORMATION lineage; Mills 2016 Fig. 6 as a published composite (`isEdited` true, legend disclosure) | n1 locator on the edited rendition used as support |
| Media validation family | `v-media-validation.cypher` | — | flags exactly the negative members above |

## Expected rows (all observed on execution)

### MP1 (CQ-MD-C01, CQ-MD-C03)
**Q-MP1-1** primary-image selection for `hu:product:elysium-basis` (4 rows, in this order):

| asset | role | rights | displayVerdict / score | decision |
|---|---|---|---|---|
| belllabs-photo-basis-jar-synthetic | PRODUCT_PHOTO | [HELD_BY_OPERATOR] | SUITABLE / 0.82 | **ELIGIBLE** |
| legacy-basis-marketplace-image-synthetic | PRODUCT_PHOTO | [] | null / null | EXCLUDED_RIGHTS_NOT_CHECKED |
| elysium-basis-carousel-supplement-facts | SUPPLEMENT_FACTS_LABEL | [RESTRICTED_TERMS] | null / null | EXCLUDED_RIGHTS_NOT_PERMITTED |
| elysium-basis-carousel-hero | PRODUCT_PHOTO | [RESTRICTED_TERMS] | SUITABLE / 0.93 | EXCLUDED_RIGHTS_NOT_PERMITTED |

(Within equal decisions, the `displayScore DESC` ordering puts nulls first, which is Neo4j's null ordering.)

**Q-MP1-2** (failing case reproduced): 1 row, `legacy-basis-marketplace-image-synthetic`, 0.97. The live-style ranking picks the unsourced image.
**Q-MP1-3** rights explanation: 4 rows. The hero and Supplement Facts images return RESTRICTED_TERMS / SITE_TERMS / ENTIRE_SITE with the verbatim Elysium licence sentence and capture time. The jar photo returns HELD_BY_OPERATOR / OPERATOR_RECORD. The legacy image returns all nulls (not checked).

### MP2 (CQ-MD-C02, CQ-MD-C05)
**Q-MP2-1** mTOR MECHANISM_DIAGRAM slot (3 rows): generated explainer ELIGIBLE (0.88, `mustLabelAsGenerated` true, HELD_BY_OPERATOR); Commons diagram EXCLUDED_NOT_SUITABLE (MARGINAL 0.55; rights [OPEN_LICENSE] from 2 records; licences "GFDL (version not stated …)", "CC BY-SA 3.0"; attribution "Lybbar12"); legacy diagram EXCLUDED_RIGHTS_NOT_CHECKED.
**Q-MP2-2** per-role suitability of the Commons diagram (2 rows): MECHANISM_DIAGRAM MARGINAL 0.55; THUMBNAIL SUITABLE 0.80. Both carry the two licences and attribution "Lybbar12".
**Q-MP2-3** Metric `tissue-nad-concentration` (2 rows): generated explainer ELIGIBLE; legacy (unsourced 0.95) EXCLUDED_RIGHTS_NOT_CHECKED.
**Q-MP2-4** (negative, forbidden implication EXPLAINS ⇏ EVIDENCES): **0 rows**.

### MP3 (CQ-MD-C05, CQ-PV-01, CQ-PV-02)
**Derivation MEDIA-EV-1** (write + return): 1 row, `bia-s-biad807-confocal-image-synthetic-file` EVIDENCES `hu:assertion:w22-mtdna-release-observed-in-s-biad807-context`. The generated illustration is not derived (generationMode GENERATED).
**Q-MP3-1** (2 rows): E1 → `EVIDENCE_PATH_OK` (CAPTURED, ORIGINAL, `sameBytes` true, rights [PUBLIC_DOMAIN]); G1 via bad assertion → `REJECTED_GENERATED_ASSET`.
**Q-MP3-2** (1 row): only the generated illustration EXPLAINS the mechanism (role MECHANISM_DIAGRAM, `isSynthetic` true).
**Q-MP3-3** (2 rows): E1 with rule MEDIA-EV-1; G1 with rule null (the bad hand-written edge). V-604 and V-605 flag it. (If MEDIA-EV-1 is re-run after MP5 is loaded, it also derives `elysium-basis-carousel-supplement-facts` EVIDENCES the MP5 `LABEL_FOR` and `HAS_VARIANT` assertions, 4 EVIDENCES edges in total. This was observed in the idempotence run, see 07-operations.md. The extra edges are correct derivations, not duplicates.)

### MP4 (CQ-MD-C03, CQ-PV-06, CQ-PV-01 state 5)
**Q-MP4-1** (4 rows): Reactome diagram **ELIGIBLE** (0.78, requiredAttribution "Reactome, Nicotinate metabolism (R-HSA-196807.8), CC BY 4.0", `mustIndicateChanges` true); unchecked diagram EXCLUDED_RIGHTS_NOT_CHECKED (0.92); Elsevier Figure I EXCLUDED_RIGHTS_NOT_PERMITTED (0.96, ALL_RIGHTS_RESERVED); Covarrubias placeholder EXCLUDED_RIGHTS_NOT_PERMITTED (0.90, NO_STATEMENT_FOUND).
**Q-MP4-2** (1 row): Figure I, freely readable at `https://pmc.ncbi.nlm.nih.gov/articles/PMC7502477/` (retrieved 2026-10-04T01:02Z), rights ALL_RIGHTS_RESERVED, `displayPermittedByRights` false.
**Q-MP4-3** (3 rows): bad-rights activity → AUTHORIZED_WITHOUT_PERMITTING_RIGHTS_RECORD; bad-unauthorized → UNAUTHORIZED_USE; ok activity → OK (DISPLAY_MEDIA, policy media-display-v0, [OPEN_LICENSE]).

### MP5 (CQ-MD-C04, CQ-PV-02, CQ-PV-03; seam W04)
**Derivation LABEL-REGION-PRODUCT-1**: 1 row, region → `hu:product:elysium-basis`.
**Q-MP5-1** (1 row): crop `basis-supplement-facts-panel-crop`, method bl-crop-v1, from rendition `…-w1946`, `originalEqualsCapture` true, regionPx [310,240,1320,1180], frame IMG-PX1, `cropMatchesRegion` true, locator `basis-supplement-facts-panel-image-region`, snapshot `…-w1946-synthetic` (retrievedAt 01:05Z), source the CDN URL, regionType SUPPLEMENT_FACTS.
**Q-MP5-2** (3 rows): w1946 ORIGINAL `regionDefinedHere` true; crop CROPPED false; w416 RESIZED false.
**Q-MP5-3** (1 row): declaration "Elysium NR (Nicotinamide Riboside Chloride) 250 mg", citeAs the IMAGE_REGION locator, aboutProduct basis, derivedBy LABEL-REGION-PRODUCT-1.

### MP6 (CQ-MD-C04, CQ-MD-C05, CQ-PV-03)
**Q-MP6-1** (1 row): ANNOTATED rendition ← MEDIA_TRANSFORMATION bl-callout-overlay-v1 ← ORIGINAL S-BIAD807 rendition (CAPTURED); `captureWithSameBytes` = the capture snapshot.
**Q-MP6-2** (3 rows): S-BIAD807 ANNOTATED → NOT_FOR_EVIDENCE_EDITED_RENDITION (`bytesEqualACapture` false); S-BIAD807 ORIGINAL → RAW_CAPTURE_OK; Mills Fig. 6 ORIGINAL → PUBLISHED_COMPOSITE_CITE_AS_FIGURE (`assetIsEdited` true).
**Q-MP6-3**: **0 rows** (no edited asset lacks both lineage and disclosure).

### Media validation family (V-601…V-615): expected = observed

| Validator | combined (all six) | solo MP3 | solo MP5 | solo MP6 | Rows (combined) |
|---|---|---|---|---|---|
| V-601 IMAGE_REGION ↔ annotation | 1 | 0 | 1 | 0 | `hu:locator:bad-dangling-image-region` (0 annotations) |
| V-602 annotated bytes = snapshot bytes | 2 | 0 | 1 | 1 | `bad-nr-line-region-on-original-snapshot` (CROPPED); `bad-region-on-edited-callouts` (ANNOTATED) |
| V-603 hash format / stated checksum | 0 | 0 | 0 | 0 | — |
| V-604 EVIDENCES derived only | 1 | 1 | 0 | 0 | generated illustration → assertion (rule null) |
| V-605 generated asset as evidence | 1 | 1 | 0 | 0 | `belllabs-generated-mtdna-pyroptosis-illustration-synthetic` |
| V-606 support only from ORIGINAL | 2 | 0 | 1 | 1 | `bad-claim-cited-on-edited-rendition` (ANNOTATED); `bad-nr-declaration-cited-on-crop-region` (CROPPED) |
| V-607 non-ORIGINAL lineage | 0 | 0 | 0 | 0 | (MP5 solo returned 1 row before the fix that added the publisher rendition's CAPTURE activity, which shows the validator works) |
| V-608 display without AUTHORIZED_BY | 1 | 0 | 0 | 0 | `w22-display-nad-answer-bad-unauthorized-synthetic` |
| V-608b authorized without permitting rights (informational) | 1 | 0 | 0 | 0 | `w22-display-nad-answer-bad-rights-synthetic`, Figure I, [ALL_RIGHTS_RESERVED] |
| V-609 assessment shape | 0 | 0 | 0 | 0 | — |
| V-610 retired legacy properties (informational) | 2 | 0 | 0 | 0 | legacy marketplace image [qualityScore, authenticityScore]; legacy concept diagram [qualityScore] |
| V-611 exactly one ORIGINAL | 0 | 0 | 0 | 0 | — |
| V-612 asserted media edge ↔ Assertion | 0 | 0 | 0 | 0 | — |
| V-613 panel / region cardinality | 0 | 0 | 0 | 0 | — |
| V-614 crop used its region | 0 | 0 | 0 | 0 | — |
| V-615 media node used as SUPPORTED_BY target | 0 | 0 | 0 | 0 | — |

### Kernel suite (`docs/schema/neo4j/validation.cypher`) on the combined load
174/174 statements ran. The only non-zero results are informational: **V-401b** = 5 ACCEPTED assertions rest only on WHOLE_SNAPSHOT locators (operator-photo depiction and rights assertions and image-file depictions; acceptable coarse support for a depiction, flagged for re-anchoring), and **V-514b** = 33 assertions without `contentHash` (fixture records). The first run of the fixtures surfaced real kernel violations, which led to fixes:

- V-110: ACCEPTED assertions lacked capture-fidelity adjudications.
- V-504: an assertion was recorded before its supporting snapshot was retrieved.
- V-231/V-232: a DIRECT_MEASUREMENT mechanism assertion needs `OBSERVED_IN_CONTEXT` to a context with species and exposure status. The mechanism assertion was reshaped to `INDUCES_PROCESS` with that context.
- V-101: an asserted `HAS_VARIANT` edge lacked `assertionUid`.
- V-003: an assertion had no object.
- V-522: nodes lacked `privacyClass`.

These are reported because the same mistakes will occur in production media ingestion.

## Temporal correction, late arrival, identity collision, missing facts, access leakage

| Concern | Where covered | Expected |
|---|---|---|
| Temporal correction / terms change | Rights records carry `effectiveFrom` (Elysium terms "Last updated: November 17, 2022") and asserted attachment episodes with `validFrom`/`recordedFrom`. A terms change is a new record, and the old episode gets `validTo` (VALIDITY_BOUNDED). Not exercised as a two-version fixture (U-10-style follow-up). | not-run (documented rule) |
| Late arrival | Commons upload `publishedAt` 2012 vs capture 2026-10-04. Rights validity starts at the publication proxy (`validFromBasis: PUBLICATION_PROXY`), not at the capture. | run (MP2 data) |
| Identity collision | One file reached by two URLs (CDN `width=1946` vs `width=416`): one asset, two renditions, distinct hashes. Same bytes across two Sources are linked only by hash equality. | run (MP1, MP5 Q-MP5-2) |
| Missing facts | `isSynthetic`/`isEdited` null = unknown; rights Booleans null = statement silent; NO_STATEMENT_FOUND vs no record (not checked); SuitabilityVerdict UNKNOWN vs NOT_ASSESSED. | run (MP1, MP4) |
| Access leakage | No private-personal node, property or uid. CohortParticipant was removed from MediaSubjectTarget. The S-BIAD807 author e-mail is not copied. PolicyVersion is INTERNAL. Kernel V-520/V-521/V-524 returned 0. | run (kernel suite) |

## Essential and existing CQ queries

| CQ | Query |
|---|---|
| CQ-PV-01 (Essential) | Q-MP3-1 (state 2 via IMAGE_REGION), Q-MP4-3 (state 5) |
| CQ-AX-01 (Essential) | V-615 + Q-MP2-4 (an illustration is never a citation) |
| CQ-PV-02 | Q-MP5-1, Q-MP5-2 |
| CQ-PV-03 | Q-MP5-1, Q-MP6-1 |
| CQ-PV-06 | Q-MP4-1, Q-MP4-3 |
| CQ-MD-C01…C06 (candidates) | Q-MP1-1/2/3, Q-MP2-1…4, Q-MP4-1/2, Q-MP5-1, Q-MP3-1/3, Q-MP6-2 |

CQ-CL-08 has no W22 fixture; W21 owns that minimal pair.
