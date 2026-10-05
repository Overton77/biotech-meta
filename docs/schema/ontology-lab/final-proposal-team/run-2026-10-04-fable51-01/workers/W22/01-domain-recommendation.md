# W22 Media assets, depictions and rights: domain recommendation

Worker W22 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical catalog module: `media` (catalog 0.2.0 maturity `future`; this packet proposes `provisional`). Baseline: live schema lines 300-394 and 2199-2569 (digest `86b5e0b5…f112`), catalog `8fb50ff0…84f0`. Contract sections A8, D-010, D-014, D-016 and ledger records CL-011 and CL-014 are applied as frozen.

## 1. Boundary

The media plane holds **media work-objects that BellLabs holds or references for display, explanation and citation**: images, video, audio, figures, charts, diagrams, 3D and molecular renderings, plus their byte renditions, region and time selections, panels, label regions, graph views, suitability assessments and stated rights. It links them to the identities **and concepts** they depict or explain. The live `MediaSubject` union (line 2375) already reaches Mechanism, Pathway, Biomarker, Metric, Condition, Outcome, Protocol and about 80 other types. This packet keeps that concept coverage under the final names. The unmet need was never "media cannot point at concepts". The unmet need was reliable semantics for:

1. **Asset versus source.** A `MediaAsset` is a curated display object. A `Source`/`SourceSnapshot` (W00) is an evidence capture. They share bytes only when a rendition's raw-byte `contentHash` equals a snapshot's `contentHash`. `DERIVED_FROM_SOURCE {captureRelation: SAME_BYTES_AS_SNAPSHOT}` records that case, and it never makes the asset a Source.
2. **Depiction, explanation, visualization and evidence are four different links.** `DEPICTS`, `EXPLAINS` and `VISUALIZES` are asserted: each is the projection of one Assertion, because a depiction can be wrong (the wrong product variant, the wrong pathway). `EVIDENCES` is derived only. It exists only when an Assertion is `SUPPORTED_BY` a W00 `SourceLocator{IMAGE_REGION}` whose annotation sits on an ORIGINAL captured rendition (rule MEDIA-EV-1). A depiction or explanation is never causal proof and never source support.
3. **Rights and permission are different things.** A `MediaRightsRecord` holds what a named source states: licence offer, copyright notice, site terms, content-class licence or permission grant. Each statement has its own scope and time. Permission for a BellLabs use is a W23 `PolicyVersion` decision recorded through W00's `Activity -AUTHORIZED_BY {useKind}-> PolicyVersion`. Public availability, absence of a record, `NO_STATEMENT_FOUND` and `AMBIGUOUS` never permit.
4. **Quality is not truth.** `MediaSuitabilityAssessment` is a method-versioned EvidenceAssessment of one dimension. The dimensions are display quality, depiction accuracy, authenticity and extraction accuracy, and each is judged for one display role. It replaces the unsourced live `qualityScore`/`authenticityScore`. It never feeds a SUPPORT verdict.
5. **Creation and extraction lineage goes through Activity.** Capture, generation, crop, overlay, OCR and assessment are Activities (W00) with `methodVersion`. Rendering parameters are Activity facts, not edge properties.
6. **Byte hash and perceptual hash are different things.** `contentHash` is `sha256:<hex>` over raw bytes (basis RAW_BYTES; D-016) on every rendition. `perceptualHash` (with its algorithm) is a near-duplicate feature. A publisher-stated checksum, such as the Commons SHA-1, is recorded verbatim in `statedChecksum`.

Out of scope, owned elsewhere: published works and renditions of narratives (W21 `Episode`, W20 `Document`, W09 `Publication`); locator and snapshot semantics (W00); OCR text versions (W20 `DocumentTextVersion`); label declarations and quantities (W04); policy contents and the useKind vocabulary (W23/W00); instruments that captured a microscopy image (W08); biological context of an image (W03 `MechanismEvidenceContext`).

## 2. Subdomains

| Subdomain | Elements | Archetype |
|---|---|---|
| Work-object and renditions | `MediaAsset`, `MediaVariant` | InformationArtifact, InformationArtifact |
| Selections | `MediaAnnotation`, `FigurePanel`, `ProductLabelRegion` | InformationArtifact ×3 |
| Views | `GraphView` (saved traversal spec plus viewpoint; renderings are MediaAssets) | InformationArtifact |
| Judgements | `MediaSuitabilityAssessment` (candidate promoted) | EvidenceAssessment |
| Stated rights | `MediaRightsRecord` (candidate promoted) | VersionedState |
| Links | `DEPICTS`, `EXPLAINS`, `VISUALIZES`, `ANNOTATES_SUBJECT`, `HAS_RIGHTS_RECORD` (asserted); `EVIDENCES`, `INCLUDES_SUBJECT`, `ABOUT_PRODUCT` (derived, read-only); `HAS_MEDIA_VARIANT`, `HAS_ANNOTATION`, `DERIVED_FROM_SOURCE`, `PART_OF_MEDIA`, `FROM_ANNOTATION`, `VISUALIZES_TRAVERSAL`, `REGION_HAS_DECLARATION`, `ASSESSES_MEDIA`, `ASSESSED_ON_VARIANT`, `ASSESSES_SUITABILITY_FOR` (structural); `LOCATES_REGION` (W00 edge, inverse field here) | — |

Identity versus state versus artifact versus occurrence:
- Every media node except the rights record is an **artifact**: an immutable selection or a stored representation. No media node is an Entity. A media file has no identity apart from its bytes and its curation. When two assets carry the same work, that is an `EquivalenceAssessment` (W00), not a merged uid.
- `MediaRightsRecord` is a **state**: terms valid over an interval, superseded when the terms change. Elysium's terms carry "Last updated: November 17, 2022", and Reactome "reserves the right to modify this Agreement at any time".
- `MediaSuitabilityAssessment` is an **assessment**: immutable, re-assessed via `SUPERSEDES`.
- Creating, cropping, generating, displaying and assessing are **occurrences** (W00 Activity).

## 3. Disposition of every live and catalog element in scope

Legend: keep, refine, merge, split, seam, retire, defer. The field-level mapping is in `migration-map.yaml`.

| Element (live line) | Disposition | Final | Reason (failing case or CQ) |
|---|---|---|---|
| `MediaAsset` (2381) | refine | `MediaAsset` `["MediaAsset","InformationArtifact"]` | Byte facts move to renditions (`MediaVariant`). Rights move to `MediaRightsRecord`, scores to `MediaSuitabilityAssessment`, `isPrimarySource` to lineage. `checksumSha256` becomes `contentHash` (`sha256:`, RAW_BYTES). `@vector` is left for Fable (D-014). |
| `MediaAsset.checksumSha256` | rename | `contentHash` + `contentHashBasis` | D-016, live-schema-alignment line 433 |
| `MediaAsset.mediaFormat, mimeType, fileSizeBytes, widthPx, heightPx, durationSeconds, frameRate, colorSpace, storageUri, perceptualHash, thumbnailUrl, previewUrl` | move | `MediaVariant` (ORIGINAL / THUMBNAIL / PREVIEW) | Failing case: the Elysium Supplement Facts image is served at `width=1946` and `width=416` (S09). One width on the asset cannot describe both, and a region in pixels is defined only on one raster. |
| `MediaAsset.resolutionText` | retire | derived from width/height | duplicate |
| `MediaAsset.sourceUrl` | retire | `DERIVED_FROM_SOURCE` → SourceLocator ← Snapshot ← Source.canonicalUri | a URL is not a capture (A8) |
| `MediaAsset.license, attributionText, copyrightHolder, usageRestrictions` | move | `MediaRightsRecord` | Failing case: Commons `File:MTOR_signal_pathway.jpg` is CC BY-SA 3.0 and also in category GFDL (two offers, S01). Reactome licenses illustrations CC BY 4.0 but data CC0 (S02). "Not checked" and "checked, nothing found" are both null in one string. |
| `MediaAsset.qualityScore, authenticityScore` | move | `MediaSuitabilityAssessment` (methodVersion `legacy-unsourced`, ignored by selection) | Failing case MP1/MP2: an unsourced 0.97 outranks a method-versioned SUITABLE 0.82 (Q-MP1-2 reproduces it). |
| `MediaAsset.isSynthetic, isEdited` | keep (null = unknown) + `editDisclosureText` | `MediaAsset` | CC BY 4.0 and Reactome require changes to be indicated (S02). Mills 2016 Fig. 6A is a "Representative" composite (S05). |
| `MediaAsset.isPrimarySource` | retire | `generationMode` + `DERIVED_FROM_SOURCE.captureRelation`; CQ-PV-05 per assertion | document-level primary flag rejected in round 0006 |
| `MediaAsset.capturedAt` | keep + `capturedAtPrecision` | | Commons `DateTimeOriginal` is "2012-09-25" (day precision) |
| `MediaAsset.extractedAt, generatedAt` | move | `Activity.endedAt` | lineage through Activity |
| `MediaAsset.sourcePublishedAt` | rename | `publishedAt` (+ precision) | archetype field |
| `MediaAsset.title, altText, caption, transcriptText, ocrText, canonicalUrl, assetType, mediaPurpose, generationMode` | keep | | presentation and search; fulltext index retained (D-015) |
| `MediaAsset.variants` (`HAS_VARIANT`) | rename | `HAS_MEDIA_VARIANT` | CL-014 RULED |
| `MediaAsset.annotations` (`HAS_ANNOTATION`) | move | `MediaVariant -HAS_ANNOTATION->` | coordinates are defined on one rendition (V-602) |
| `MediaAsset.sources` (`DERIVED_FROM_SOURCE` → MediaSource) | refine | `DERIVED_FROM_SOURCE` → W00 `SourceLocator`, `MediaSourceProperties` | MediaSource retired |
| `MediaAsset.figurePanels` (`PART_OF_MEDIA`, OrderingMetadata) | keep | `StructuralEdgeProperties.orderIndex` | |
| `MediaAsset.depicts / explains` | refine | asserted, `MediaLinkProperties` | round 0006 V-420 spirit: a link is a proposition |
| `MediaAsset.evidences` | refine to derived | `EVIDENCES` (MEDIA-EV-1), target `MediaVisualizableRelationshipTarget`, read-only | live `EVIDENCES` to an entity cannot be migrated (see migration map); evidence is for propositions |
| `MediaAsset.supportsClaims`, `supportsClaimOccurrences` (`SUPPORTS_CLAIM*`) | retire | kernel `SUPPORTED_BY` → `SourceLocator{IMAGE_REGION}` + derived `EVIDENCES` | live-schema-alignment line 434 |
| `MediaAsset.visualizesRelationships` (`VISUALIZES`) | refine | asserted; target `MediaVisualizableRelationshipTarget` (adds Assertion, ClaimOccurrence, Claim, StudyResult) | Mills 2016 Fig. 1A plots measured NAD+ levels, which is a result, not an entity (S05) |
| `MediaAsset.visualizesTraversal` | keep | structural | |
| `MediaVariant` (2445) | refine | InformationArtifact; gains `contentHash`, `contentHashBasis`, `perceptualHash(+Algorithm)`, `statedChecksum(+Algorithm)`, `widthPx`... | Commons states a SHA-1 (S01) |
| `MediaVariant.derivedFrom` | rename | `asset` (inverse `HAS_MEDIA_VARIANT`) | CL-014 |
| `MediaAnnotation` (2465) | refine | bound to one `MediaVariant`; `normalizationVersion` (IMG-PX1, W22-SR-05); `confidence` retired; `locatedBy` inverse of W00 `LOCATES_REGION` | D-010, CL-011 |
| `MediaAnnotation.supportedByChunks` (`SUPPORTED_BY_CHUNK`) | retire | | a chunk is never a locator (V-406) |
| `MediaAnnotation.annotatesSubjects` | refine | asserted `ANNOTATES_SUBJECT` | |
| `MediaSource` (2493) | **retire** (no projection type kept) | `DERIVED_FROM_SOURCE` edge + W00 Source/Snapshot/Locator; `MediaSourceType` enum kept as the edge's `sourceType` | It is "a locator in all but name" (alignment line 436). A second locator type is forbidden (W19 note, A8). `sourcePageNumber` maps to PDF_PAGE.page, `sourceTimestampSeconds` to MEDIA_TIME, `sourceFigureLabel` to `FigurePanel.figureNumber`/SECTION, `sourceAccessedAt` to `SourceSnapshot.retrievedAt`. |
| `SOURCE_DOCUMENT`, `SOURCE_EPISODE`, `SOURCE_LISTING`, `SOURCE_CHUNK` | retire | Source(`Document`) ← snapshot ← locator; Source `RENDITION_OF` Episode (W00/W21); listing page Source (W15); chunk retired | |
| `GraphView` (2512) | refine | InformationArtifact; `contentHash` = spec hash; `viewpointRecordedAt`, `viewpointValidAt` added; `INCLUDES_SUBJECT` derived read-only; `supportedByChunks` retired | a view rendered before a correction shows superseded edges. Without its viewpoint the image cannot be reproduced (QS-2). |
| `FigurePanel` (2541) | refine | `region` (FROM_ANNOTATION, no properties), `depicts`/`visualizes` asserted, `evidences` derived; `supportsClaims` retired | Mills Fig. 6A legend (S05) |
| `ProductLabelRegion` (2555) | refine / seam W04 | `region` exactly one; new `REGION_HAS_DECLARATION` → W04 `LabelDeclaration`; `ABOUT_PRODUCT` derived from W04 `LABEL_FOR`; `MENTIONS`, `ASSERTS`, `confidence` retired | `MENTIONS` would be a third meaning of that name (W00, W20). A label's marketing claim is a W21 ClaimOccurrence `SUPPORTED_BY` the region locator. |
| `MediaLinkMetadata` (329) | refine | `MediaLinkProperties` = AssertedEdgeProperties + `role`, `isPrimary`, `salience`, `salienceMethodVersion`, `sourceText` | `confidence`, `isCanonical`, `isRepresentative`, `notes` retired (contract A4) |
| `MediaSourceMetadata` (341) | refine | `MediaSourceProperties` (`sourceType`, `captureRelation`, `contextText`) | lineage fields go to Activity |
| `AnnotationMetadata` (351) | retire | FROM_ANNOTATION carries no properties | exactly one region per panel or label region; role redundant |
| `RenderingMetadata`, `BiologicalModelMetadata`, `MolecularRenderingMetadata` (361-394) | retire | Activity (`methodVersion`, Agent `toolVersion`) for renderer and parameters; `DERIVED_FROM_SOURCE` to the PDB or model record Source for `pdbId`/`structureSource`/`sourceDatabase`/`externalId`; `DEPICTS` Species/AnatomicalContext/MolecularEntity for `species`/`anatomicalContext` | **No live relationship uses them** (grep of the live schema: no `properties: "RenderingMetadata"` and similar). Render parameters on an edge cannot be shared by the N assets of one render run, and they cannot name the tool version. |
| `MediaRelationRole`, `MediaAssetType`, `MediaFormat`, `MediaPurpose`, `MediaGenerationMode`, `MediaVariantKind`, `AnnotationType`, `MediaSourceType`, `GraphViewType`, `LabelRegionType` | keep (values unchanged) | | new values would be ledger requests; none needed |
| `MediaSubject` union (2375) | rename + refine | `MediaSubjectTarget` | final names, concept coverage preserved. Removed: snapshot states, CohortParticipant and AnonymousActor (privacy; nothing to depict), retrieval units, media self-members, propositions (moved). Added: ProductVariant, PackageConfiguration, Trademark, CertificationProgram (logos on the Elysium hero image, S09), ConsumerBrand, LegalEntity, Facility, Publication, ProtocolEdition, BrandedIngredientMaterial, botanical and microbial identities. |
| `MediaVisualizableRelationship` union (2377) | rename + refine | `MediaVisualizableRelationshipTarget` | |
| `ProductLabelMention` union (2379) | retire | `REGION_HAS_DECLARATION` → `LabelDeclaration` → W04 `DECLARATION_IDENTIFIES_MATERIAL` | no remaining member use |
| `Metric.mediaUrl`, `mediaType` (1291) | seam (W07 owner) | W22 asks W07 to retire them in favour of `EXPLAINS`/`DEPICTS` to Metric (W22-SR-09) | alignment line 233 deferred this to the media module |
| `RelationshipAssertion.visualizedBy` | keep (W21 field) | `VISUALIZES` inverse | |
| catalog `media` module `owns` list | keep + add | adds MediaSuitabilityAssessment and MediaRightsRecord; removes MediaSource | |

## 4. Alternatives considered

| Question | Alternatives | Chosen | Why |
|---|---|---|---|
| Media versus source | (a) MediaAsset as a `Source` subtype; (b) separate artifact plus byte-hash link | (b) | An asset can be edited, cropped, regenerated and rights-gated. A snapshot is immutable evidence. Under (a), a BellLabs crop would become "a source". |
| MediaSource | (a) keep as a projection node; (b) retire into locator plus edge | (b) | Each of its fields has a kernel home. A projection node would be a second locator type with its own drift. |
| Depiction link class | (a) structural with Activity lineage; (b) asserted (one Assertion per link) | (b) | Depiction identity can be wrong and contested: a marketplace photo of another variant, or alt text that names the wrong product. Capture-fidelity adjudication applies. Cost: one Assertion per link (07-operations.md). |
| Rights | (a) strings on MediaAsset; (b) MediaRightsRecord state; (c) adopt ODRL policies | (b), with ODRL Offer/Set/Agreement noted only as alignment | (a) fails the dual-licence, content-class and "not checked" cases. (c) would be a legal-policy vocabulary decision that OPEN-QUESTIONS P2 item 1 leaves to W23 and the user; only the ODRL 2.2 term definitions were read (S12). |
| Quality | (a) keep scores; (b) one assessment per dimension | (b) | "a generic qualityScore/authenticityScore cannot be an evidence verdict" (brief); per-role verdicts differ for one asset (Q-MP2-2) |
| Annotation anchor | (a) asset; (b) rendition | (b) | pixel coordinates differ by a factor of 1946/416 between publisher renditions (S09) |
| Crop lineage | (a) new `DERIVED_FROM_VARIANT` edge; (b) Activity USED parent + annotation | (b) | kernel path, no new edge; validated by V-607/V-614 |
| Label region contents | (a) keep `MENTIONS` → ingredient; (b) `REGION_HAS_DECLARATION` → W04 declaration | (b) | declarations are W04's evidence-bearing units; removes the MENTIONS name collision |

## 5. Smallest recommended model

Seven node types: five refined live types plus two promoted candidates, each promoted with a named candidate CQ and a failing fixture. MediaSource is retired. Two relationship-property types, two unions, 16 enums (10 live unchanged, 6 new and owned by W22). Asserted: 5 relationships. Derived: 3, read-only. Structural: 10, plus 4 W00 relationship types used as fields (`WAS_GENERATED_BY`, `SUPERSEDES`, `LOCATES_REGION` inverse; `USED`/`AUTHORIZED_BY` only in fixtures). New relationship names are `REGION_HAS_DECLARATION`, `ASSESSES_MEDIA`, `ASSESSED_ON_VARIANT`, `ASSESSES_SUITABILITY_FOR`, `HAS_RIGHTS_RECORD` and `HAS_MEDIA_VARIANT` (rename). The model needs from W00 one new `useKind`, three `activityKind` values, two `sourceKind` values, uid tokens and one image-coordinate normalization version (05/seam-requests).

## 6. Forbidden implications (media module, proposed)

| Premise | Not implied | Enforced by |
|---|---|---|
| `DEPICTS`, `EXPLAINS`, `VISUALIZES` | `SUPPORTED_BY` / evidential support | V-615, V-604; Q-MP2-4 |
| `MediaPurpose.EVIDENCE` | `EVIDENCES` | V-604 (derivation only) |
| GENERATED asset | source support | V-605; Q-MP3-1 |
| high `DISPLAY_QUALITY` | proposition true | no path from suitability to Adjudication; V-609 |
| publicly accessible (snapshot retrievable, PMC "free to read") | reuse permitted | Q-MP4-2, V-608b |
| no rights record / `NO_STATEMENT_FOUND` / `AMBIGUOUS` | permission | Q-MP1-1, Q-MP4-1, V-608b |
| open licence on an article page | open licence for every embedded image (PMC notice, S06) | `statementScope` CONTAINING_WORK vs THIS_ASSET |
| perceptual-hash match | same bytes / same asset / same rights | V-603 (separate fields); 07-operations |
| edited/derived rendition | captured evidence | V-606, V-602 |
