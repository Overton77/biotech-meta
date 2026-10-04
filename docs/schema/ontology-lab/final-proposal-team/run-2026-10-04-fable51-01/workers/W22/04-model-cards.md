# W22 model cards

Conventions (contract B): every node carries `id`, `uid`, `name` (nullable, presentation only), `description`, `mongoResearchRunId` (operational, internal), `createdAt`/`updatedAt` (operational timestamps), `privacyClass` (PUBLIC unless stated), `maturity`, `schemaVersion`. These kernel fields are not repeated per card. "Kind" values: asserted (stated by a source), observed (captured by BellLabs), calculated, inferred, operational. Privacy class for every W22 node is PUBLIC, and no field holds private-personal data. Fixtures must not copy personal contact data that appears in source records (the S-BIAD807 author e-mail). Nullability: every domain field is nullable unless marked `!`, and null means unknown or not stated, never false or zero.

Proposed uid tokens (W22-SR-01): `media-asset`, `media-variant`, `media-annotation`, `graph-view`, `figure-panel`, `label-region`, `media-assessment`, `media-rights`; plus `pathway` (Pathway; owner W03) used in MP4.

---

## Node cards

### MediaAsset (refined; maturity PROVISIONAL)
- **Meaning:** a curated media work-object, independent of any byte rendition. It is NOT a Source/SourceSnapshot, NOT a truth claim and NOT a display permission.
- **Archetype / labels / uid:** InformationArtifact; `["MediaAsset","InformationArtifact"]`; `hu:media-asset:<opaque>`.
- **Identity keys:** `uid`. `contentHash` (ORIGINAL rendition bytes) is a deduplication key, not identity: the same bytes from two sources stay one asset only if an EquivalenceAssessment says so. `canonicalUrl`, `title` and file names are never identity. Alias: live `id`.

| Property | Type | Kind | Temporal / value-state semantics | Notes |
|---|---|---|---|---|
| artifactType | String! | operational | constant `MEDIA_ASSET` | archetype |
| publishedAt, publishedAtPrecision | DateTime, TimePrecision | asserted (by publisher) | null = not stated | live `sourcePublishedAt` |
| observedAt | DateTime | observed | instant known displayed | archive date for late captures |
| contentHash, contentHashBasis | String, ContentHashBasis | calculated | `sha256:<hex>` over ORIGINAL raw bytes; equals ORIGINAL rendition hash (V-611) | live `checksumSha256` |
| searchText, searchFields, embeddingModel, embeddingDimensions, searchEmbedding | | calculated | derived; regenerable | SearchIndexable |
| assetType | MediaAssetType! | observed | | |
| mediaPurpose | MediaPurpose | asserted (creator/curator) | never implies a link role | |
| generationMode | MediaGenerationMode | observed / asserted | how ORIGINAL bytes came to exist; UNKNOWN allowed | GENERATED blocks EVIDENCES (V-605) |
| isSynthetic | Boolean | asserted (disclosure) | null = not disclosed, never false | |
| isEdited | Boolean | asserted / observed | null = unknown | Mills Fig. 6 = true |
| editDisclosureText | String | asserted (verbatim) | | CC BY "indicate changes" duty |
| capturedAt, capturedAtPrecision | DateTime, TimePrecision | asserted (creator / EXIF) | not our retrieval | Commons DateTimeOriginal DAY |
| canonicalUrl, title, altText, caption | String | asserted (presentation) | captured text; cite through SourceLocator | |
| transcriptText, ocrText | String | calculated | derived search text, never a locator | |

| Edge (field) | Direction / range | Class | Cardinality | Edge properties |
|---|---|---|---|---|
| variants `HAS_MEDIA_VARIANT` | OUT → MediaVariant | structural | one_or_more when bytes held; exactly one ORIGINAL | none |
| sourceLocators `DERIVED_FROM_SOURCE` | OUT → SourceLocator (W00) | structural | many | MediaSourceProperties |
| figurePanels `PART_OF_MEDIA` | IN ← FigurePanel | structural | many | StructuralEdgeProperties (orderIndex) |
| depicts `DEPICTS` | OUT → MediaSubjectTarget | asserted | many | MediaLinkProperties |
| explains `EXPLAINS` | OUT → MediaSubjectTarget | asserted | many | MediaLinkProperties |
| visualizes `VISUALIZES` | OUT → MediaVisualizableRelationshipTarget | asserted | many | MediaLinkProperties |
| evidences `EVIDENCES` | OUT → MediaVisualizableRelationshipTarget | derived (MEDIA-EV-1), read-only | many | DerivedEdgeProperties |
| visualizesTraversal `VISUALIZES_TRAVERSAL` | OUT → GraphView | structural | zero_or_one | StructuralEdgeProperties |
| rightsRecords `HAS_RIGHTS_RECORD` | OUT → MediaRightsRecord | asserted | many (absence = not checked) | AssertedEdgeProperties |
| suitabilityAssessments `ASSESSES_MEDIA` | IN ← MediaSuitabilityAssessment | structural | many | none |
| generatedBy `WAS_GENERATED_BY` | OUT → Activity (W00) | structural | zero_or_one | none |

- **Derived inputs:** none stored. Selection (CQ-MD-C01/C02) is a query over rights, assessments and links, never a stored "best image" flag.
- **Sources:** live 2381-2443; alignment lines 433-437; S01, S03, S05, S07, S09.

### MediaVariant (refined; PROVISIONAL)
- **Meaning:** one byte rendition (ORIGINAL, publisher rendition, or BellLabs derivative). Archetype InformationArtifact; labels `["MediaVariant","InformationArtifact"]`; uid `hu:media-variant:<opaque>`.
- **Identity:** `uid`; byte identity via `contentHash`. `url` and `storageUri` are locations, not identity.

| Property | Type | Kind | Semantics |
|---|---|---|---|
| artifactType | String! | operational | `MEDIA_VARIANT` |
| contentHash, contentHashBasis | String, ContentHashBasis | calculated | raw-byte sha256 (D-016) |
| variantKind | MediaVariantKind! | observed | ORIGINAL = bytes as obtained |
| mediaFormat, mimeType | | observed | |
| storageUri | String | operational (internal) | BellLabs object store |
| url | String | observed | delivery URL (CDN width variant) |
| fileSizeBytes, widthPx, heightPx (Int), durationSeconds, frameRate (Float, s / s⁻¹), colorSpace | | observed | units: bytes, px, seconds, frames per second |
| perceptualHash, perceptualHashAlgorithm | String | calculated | algorithm required when hash set; similarity only |
| statedChecksum, statedChecksumAlgorithm | String | asserted (host) | verbatim; never contentHash (V-603) |

Edges: `asset` (IN `HAS_MEDIA_VARIANT`, exactly_one); `annotations` (OUT `HAS_ANNOTATION` → MediaAnnotation, many); `generatedBy` (OUT `WAS_GENERATED_BY` → Activity; exactly one for non-ORIGINAL: CAPTURE for publisher renditions, MEDIA_TRANSFORMATION that USED a parent rendition otherwise; V-607).

### MediaAnnotation (refined; PROVISIONAL)
- **Meaning:** an intentional selection on exactly one rendition. It may back an IMAGE_REGION locator (D-010). It is NOT the locator, NOT a chunk, and NOT a claim about content. Archetype InformationArtifact; labels `["MediaAnnotation","InformationArtifact"]`; uid `hu:media-annotation:<opaque>`.

| Property | Type | Kind | Semantics |
|---|---|---|---|
| annotationType | AnnotationType! | observed | |
| label, text | String | observed / calculated | `text` = OCR or manual reading; not a quote anchor |
| normalizationVersion | String | operational | coordinate frame, e.g. `IMG-PX1` (W22-SR-05); required when backing a locator |
| x, y, width, height | Float | observed | units per normalizationVersion (IMG-PX1: pixels, origin top-left, after EXIF orientation) |
| polygonJson, maskUri, volumeRegionJson | String | observed | |
| startTimeSeconds, endTimeSeconds (Float, s), frameStart, frameEnd (Int) | | observed | rendition timeline (never portable across renditions; round 0006 O-4) |
| meshObjectName, vertexGroupName | String | observed | 3D |
| contentHash | String | calculated | optional hash over the canonical selection |

Edges: `variant` (IN `HAS_ANNOTATION`, exactly_one); `annotatesSubjects` (OUT `ANNOTATES_SUBJECT` → MediaSubjectTarget, asserted, MediaLinkProperties); `locatedBy` (IN `LOCATES_REGION` ← SourceLocator; W00 owns the type; structural; many); `generatedBy` (WAS_GENERATED_BY). Live `confidence` and `SUPPORTED_BY_CHUNK` are retired.

### GraphView (refined; PROVISIONAL)
- **Meaning:** a saved traversal or view specification plus its viewpoint. Renderings are MediaAssets. It is never a source. Archetype InformationArtifact; labels `["GraphView","InformationArtifact"]`; uid `hu:graph-view:<opaque>`.
- Properties: `graphViewType`, `queryText`, `cypherQuery`, `graphqlQuery`, `traversalSpecJson`, `layoutSpecJson` (operational), `contentHash` (calculated: spec hash), `viewpointRecordedAt`, `viewpointValidAt` (operational; QS-2), `renderedSvgUri`, `renderedImageUri`, `interactiveViewUri` (operational), SearchIndexable fields.
- Edges: `includesSubjects` (OUT `INCLUDES_SUBJECT` → MediaSubjectTarget; derived rule GRAPHVIEW-INCLUDE-1; read-only; DerivedEdgeProperties); `renderings` (IN `VISUALIZES_TRAVERSAL`). Live `SUPPORTED_BY_CHUNK` is retired.

### FigurePanel (refined; PROVISIONAL)
- **Meaning:** a labelled panel of a figure asset. Archetype InformationArtifact; labels `["FigurePanel","InformationArtifact"]`; uid `hu:figure-panel:<opaque>`.
- Properties: `panelLabel`, `figureNumber`, `captionText` (asserted; captured text).
- Edges: `partOfMedia` (OUT `PART_OF_MEDIA` → MediaAsset, exactly_one, StructuralEdgeProperties orderIndex; V-613); `region` (OUT `FROM_ANNOTATION` → MediaAnnotation, zero_or_one, no properties); `depicts` (asserted); `visualizes` (asserted); `evidences` (derived, read-only). Live `SUPPORTS_CLAIM` is retired.

### ProductLabelRegion (refined; PROVISIONAL; seam W04)
- **Meaning:** a region of a label image (Supplement Facts panel ...) delimited by exactly one annotation. Archetype InformationArtifact; labels `["ProductLabelRegion","InformationArtifact"]`; uid `hu:label-region:<opaque>`.
- Properties: `labelRegionType` (observed), `extractedText` (calculated OCR; never a locator).
- Edges: `region` (OUT `FROM_ANNOTATION`, exactly_one; V-613); `declarations` (OUT `REGION_HAS_DECLARATION` → W04 `LabelDeclaration`, structural, many, StructuralEdgeProperties orderIndex); `aboutProduct` (OUT `ABOUT_PRODUCT` → Product; derived rule LABEL-REGION-PRODUCT-1 from W04 `LABEL_FOR` + `HAS_VARIANT`; read-only). Live `MENTIONS`, `ASSERTS` and `confidence` are retired.

### MediaSuitabilityAssessment (CANDIDATE promoted to PROVISIONAL by MP1/MP2)
- **Meaning:** one method-versioned assessment of one suitability dimension of one asset, for one display role and optional subject. NOT an evidence verdict, NOT rights clearance. Archetype EvidenceAssessment; labels `["MediaSuitabilityAssessment","EvidenceAssessment"]`; uid `hu:media-assessment:<opaque>`.
- **Candidate CQ:** CQ-MD-C01, CQ-MD-C02. **Failing case:** Q-MP1-2 selects the legacy image by an unsourced 0.97 over a method-versioned SUITABLE 0.82 with operator rights.

| Property | Type | Kind | Semantics |
|---|---|---|---|
| assessmentType | String! | operational | `MEDIA_SUITABILITY` |
| methodVersion | String! | operational | `legacy-unsourced` marks migrated live scores (ignored by selection; V-609 forbids ACCEPTED) |
| status | AssessmentStatus! | operational | PROPOSED / ACCEPTED / SUPERSEDED / WITHDRAWN |
| recordedAt!, recordedTo | DateTime | operational | recorded time; immutable; re-assessment via SUPERSEDES |
| dimension | MediaSuitabilityDimension! | — | one per node |
| verdict | SuitabilityVerdict! | calculated / judged | UNKNOWN ≠ NOT_ASSESSED |
| overallScore, scoreScale | Float, String | calculated | score meaningful only with method and scale |
| intendedRole | MediaRelationRole | — | suitability is per role (Q-MP2-2) |
| criteriaSummary, summary | String | — | verbatim criteria |
| confidence | Float | deprecated | not written (A4) |

Edges: `assessesMedia` (OUT `ASSESSES_MEDIA` → MediaAsset, exactly_one); `assessedOnVariant` (OUT `ASSESSED_ON_VARIANT` → MediaVariant, zero_or_one); `forSubject` (OUT `ASSESSES_SUITABILITY_FOR` → MediaSubjectTarget, zero_or_one); `generatedBy` (WAS_GENERATED_BY → Activity, exactly_one for non-legacy); `supersedes` (W00 SUPERSEDES, SupersessionProperties). W00 `ASSESSED_BY` → Agent is used in fixtures for Adjudications only.

### MediaRightsRecord (CANDIDATE promoted to PROVISIONAL by MP4/MP1/MP2)
- **Meaning:** the rights terms a named source states for an asset, as one immutable state. NOT permission, NOT a legal conclusion. Archetype VersionedState; labels `["MediaRightsRecord","VersionedState"]`; uid `hu:media-rights:<opaque>`.
- **Candidate CQ:** CQ-MD-C03, CQ-PV-06. **Failing cases:** (1) Commons file with CC BY-SA 3.0 in extmetadata and GFDL by category (S01): one `license` string loses an offer. (2) Reactome illustrations are CC BY 4.0 while data are CC0 (S02): the scope of a statement matters. (3) "Not checked" vs "checked, none found" (S04 33353981 `not_available`): both are null in a string. (4) Elsevier "All rights reserved" on an article freely readable in PMC (S04/S05/S06): availability ≠ permission.

| Property | Type | Kind | Semantics |
|---|---|---|---|
| stateType | String! | operational | `MEDIA_RIGHTS` |
| payloadHash | String! | calculated | `sha256:` over canonical payload (D-016) |
| effectiveFrom, effectiveTo | DateTime | asserted | the terms' own dates ("Last updated: November 17, 2022"); null = not stated |
| rightsStatus | MediaRightsStatus! | asserted (classified by curator) | |
| statementKind | RightsStatementKind! | — | LICENSE_OFFER ≈ ODRL Offer; PERMISSION_GRANT ≈ Agreement; SITE_TERMS / COPYRIGHT_NOTICE / REPOSITORY_METADATA / OPERATOR_RECORD |
| statementScope | RightsStatementScope! | — | THIS_ASSET / CONTENT_CLASS_ON_SITE / ENTIRE_SITE / CONTAINING_WORK / DATASET_RECORD |
| licenseName, licenseUri | String | asserted | verbatim |
| rightsHolderText, attributionText | String | asserted | verbatim |
| attributionRequired, shareAlikeRequired, modificationIndicationRequired, commercialUseAllowed, derivativesAllowed | Boolean | asserted | null = statement silent; never defaulted |
| restrictionsText | String | asserted (verbatim) | |

Edges: `assets` (IN `HAS_RIGHTS_RECORD` ← MediaAsset; asserted; AssertedEdgeProperties: validFrom/validTo of the attachment, recordedFrom/recordedTo). **Temporal rule:** a terms change is a new record. The old attachment episode gets `validTo` (fact ended: SUPERSEDES VALIDITY_BOUNDED on the assertion); a curator mis-classification gets SOURCE_CORRECTION. Records are never edited.
- **Candidate edge kept out of SDL:** `RIGHTS_HELD_BY` → Organization|Person (no CQ needs holder identity yet; `rightsHolderText` suffices).
- **ODRL alignment (not adoption):** `display` / `reproduce` / `derive` / `attribute` map to W23 useKinds and duties. ODRL review remains open (OPEN-QUESTIONS P2-1).

### MediaSource (RETIRED)
Not defined in the fragment. Field mapping in `migration-map.yaml`. Reason: a second locator type, forbidden by A8 and the W19 note. All fields have kernel homes.

---

## Relationship cards (W22-owned relationship types)

| Type | Domain → Range | Class | Cardinality | Properties | Rules |
|---|---|---|---|---|---|
| HAS_MEDIA_VARIANT | MediaAsset → MediaVariant | structural | asset 1..n; variant exactly 1 asset | — | CL-014 rename of media HAS_VARIANT |
| HAS_ANNOTATION | MediaVariant → MediaAnnotation | structural | annotation exactly 1 variant | — | moved from MediaAsset |
| DERIVED_FROM_SOURCE | MediaAsset → SourceLocator | structural | many | MediaSourceProperties | retargeted from MediaSource |
| PART_OF_MEDIA | FigurePanel → MediaAsset | structural | exactly 1 | StructuralEdgeProperties | |
| FROM_ANNOTATION | FigurePanel / ProductLabelRegion → MediaAnnotation | structural | 0..1 / exactly 1 | — | AnnotationMetadata retired |
| VISUALIZES_TRAVERSAL | MediaAsset → GraphView | structural | 0..1 | StructuralEdgeProperties | render parameters on Activity |
| DEPICTS | MediaAsset / FigurePanel → MediaSubjectTarget | asserted | many | MediaLinkProperties | ⇏ SUPPORTED_BY |
| EXPLAINS | MediaAsset → MediaSubjectTarget | asserted | many | MediaLinkProperties | ⇏ EVIDENCES, ⇏ causal support |
| VISUALIZES | MediaAsset / FigurePanel → MediaVisualizableRelationshipTarget | asserted | many | MediaLinkProperties | |
| ANNOTATES_SUBJECT | MediaAnnotation → MediaSubjectTarget | asserted | many | MediaLinkProperties | |
| HAS_RIGHTS_RECORD | MediaAsset → MediaRightsRecord | asserted | many | AssertedEdgeProperties | absence = not checked |
| EVIDENCES | MediaAsset / FigurePanel → MediaVisualizableRelationshipTarget | derived | many | DerivedEdgeProperties (`derivationRule: MEDIA-EV-1`, `derivedFromAssertionUids`) | regenerable, never the only history (the Assertion and its locator are); V-604/V-605 |
| INCLUDES_SUBJECT | GraphView → MediaSubjectTarget | derived | many | DerivedEdgeProperties (`GRAPHVIEW-INCLUDE-1`) | |
| ABOUT_PRODUCT | ProductLabelRegion → Product | derived | 0..1 | DerivedEdgeProperties (`LABEL-REGION-PRODUCT-1`, input W04 LABEL_FOR assertionUid) | |
| REGION_HAS_DECLARATION | ProductLabelRegion → LabelDeclaration (W04) | structural | many | StructuralEdgeProperties | new; seam W22-SR-07 |
| ASSESSES_MEDIA | MediaSuitabilityAssessment → MediaAsset | structural | exactly 1 | — | new |
| ASSESSED_ON_VARIANT | MediaSuitabilityAssessment → MediaVariant | structural | 0..1 | — | new |
| ASSESSES_SUITABILITY_FOR | MediaSuitabilityAssessment → MediaSubjectTarget | structural | 0..1 | — | new |
| LOCATES_REGION | SourceLocator → MediaAnnotation | structural (**W00 defines**) | locator exactly 1 annotation | — | W22 defines only the inverse field `MediaAnnotation.locatedBy` (D-010) |

Derivation rules:
- **MEDIA-EV-1:** `(x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind:'IMAGE_REGION'})-[:LOCATES_REGION]->(ann)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind:'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m)`, with `(ss)-[:HAS_LOCATOR]->(l)`, `l.mediaAnnotationUid = ann.uid`, `v.contentHash = ss.contentHash` and `m.generationMode <> 'GENERATED'` ⇒ `(m)-[:EVIDENCES {derivationRule, derivedFromAssertionUids:[x.uid]}]->(x)`. The FigurePanel variant replaces the asset hop with `(fp)-[:FROM_ANNOTATION]->(ann)`. Executed in MP3.
- **LABEL-REGION-PRODUCT-1:** `(r)-[:FROM_ANNOTATION]->(ann)<-[:LOCATES_REGION]-(l:IMAGE_REGION)<-[:HAS_LOCATOR]-(ss)-[lf:LABEL_FOR, current]->(pv)<-[:HAS_VARIANT]-(p)` ⇒ `(r)-[:ABOUT_PRODUCT]->(p)`. Executed in MP5.
- **GRAPHVIEW-INCLUDE-1:** evaluate `traversalSpecJson` at (`viewpointRecordedAt`, `viewpointValidAt`); write INCLUDES_SUBJECT with `derivationRule = 'GRAPHVIEW-INCLUDE-1:' + contentHash`. Not executed (no GraphView fixture; operations note).

## Relationship-property type cards

### MediaLinkProperties (successor of MediaLinkMetadata)
Every field of `AssertedEdgeProperties` (relationshipUid!, assertionUid!, validFrom, validTo, validFromPrecision, validToPrecision, validFromBasis!, validToBasis!, recordedFrom!, recordedTo, mongoResearchRunId), plus:
- `role: MediaRelationRole`: the link's role as asserted.
- `isPrimary: Boolean`: the asserting source's own designation (og:image, first carousel position). Not BellLabs' choice.
- `salience: Float`, `salienceMethodVersion: String`: a calculated ranking feature, never a verdict.
- `sourceText: String`: verbatim grounding text (alt text, caption).

Retired: `confidence`, `isCanonical`, `isRepresentative`, `notes`.

### MediaSourceProperties (successor of MediaSourceMetadata)
`sourceType: MediaSourceType`, `captureRelation: MediaCaptureRelation!`, `contextText: String`, `mongoResearchRunId`. Retired: `sourceRole` (→ captureRelation), `sourceConfidence`, `extractionMethod`, `extractedAt` (→ Activity), `notes`.

### Retired property types
`AnnotationMetadata` (FROM_ANNOTATION carries no properties), `RenderingMetadata`, `BiologicalModelMetadata`, `MolecularRenderingMetadata` (no live relationship used them; content moves to Activity/Agent, DERIVED_FROM_SOURCE and DEPICTS). The registry names `AnnotationProperties`, `RenderingProperties`, `BiologicalModelProperties` and `MolecularRenderingProperties` as W22-owned successors. They are **not defined** (retire disposition); they stay CANDIDATE if a future failing case needs per-edge rendering facts.

## Union cards

### MediaSubjectTarget (successor of MediaSubject)
Members (final names; Fable prunes members absent from the merge): Organization, LegalEntity, ConsumerBrand, Facility, Person, PseudonymousActor; Product, ProductVariant, PackageConfiguration, Trademark, CertificationProgram, MerchantListing; ChemicalSubstance, ChemicalForm, IngredientMaterial, BrandedIngredientMaterial, BotanicalTaxon, BotanicalPreparation, MicrobialTaxon, MicrobialStrain; **Mechanism, Pathway, MolecularEntity, Species, AnatomicalContext, Organ, Outcome, Condition, RiskFactor; Biomarker, Metric**, LabTest, PanelDefinition, MeasurementMethod, Specimen; TechnologyPlatform, ToolOrInstrument, Device, Sensor, Modality; FoodItem, FoodProduct, Exposure, Lifestyle, Treatment, Procedure; ManufacturingProcess, ManufacturingStep; RegulatoryAgency, RegulatoryPathway, RegulatoryStep, RegulatoryStatus; Study, StudyArm, StudyPopulation, OutcomeDefinition, StudyResult, Dataset, Publication; **Protocol**, ProtocolEdition, ProtocolStep, Constraint, MeasurementPlan, Target, FunctionalGoal, Observation, ProtocolAdjustmentRule, ProtocolResult; AdverseEffect, SafetySignal; Community, Conference, Event, NarrativeArc; Platform, Channel, Series, Episode, EpisodeSegment, Claim, ExperienceReport; Document.

Rename map from live: PhysicalLocation → Facility (CL-015 open), Listing → MerchantListing, Compound → ChemicalSubstance, CompoundForm → ChemicalForm/IngredientMaterial, Ingredient/Material → IngredientMaterial, StudyOutcome/OutcomeMeasure → OutcomeDefinition, OutcomeResult → StudyResult, Population → StudyPopulation.

Removed: OrganizationSnapshot, ProductSnapshot, ListingSnapshot (states: depict the identity); CohortParticipant (privacy, CL-018); AnonymousActor (no identity to depict); ReferenceRange (legacy projection; depict the Metric); DocumentTextVersion, Segmentation, Chunk (retrieval units); Association, ClaimOccurrence, RelationshipAssertion (propositions → MediaVisualizableRelationshipTarget); MediaAsset, MediaVariant, MediaAnnotation, MediaSource, GraphView, FigurePanel, ProductLabelRegion (media self-reference).

### MediaVisualizableRelationshipTarget
Assertion, ClaimOccurrence, RelationshipAssertion, Claim, StudyResult, Association (only if W03 keeps it).

### ProductLabelMentionTarget (RETIRED)
Live `ProductLabelMention = Compound | Ingredient` has no remaining use once MENTIONS is replaced by REGION_HAS_DECLARATION. Not defined.

## Enum cards (W22 sole owner)

| Enum | Values | Origin | Notes |
|---|---|---|---|
| MediaAssetType | 19 live values | live 2199 | unchanged |
| MediaFormat | 22 live values | live 2221 | unchanged |
| MediaPurpose | 19 live values | live 2246 | unchanged; EVIDENCE ⇏ EVIDENCES |
| MediaGenerationMode | CAPTURED, EXTRACTED, UPLOADED, GENERATED, RENDERED, DERIVED, TRANSCODED, ANNOTATED, UNKNOWN | live 2268 | unchanged |
| MediaVariantKind | 19 live values | live 2280 | unchanged; ORIGINAL semantics fixed |
| AnnotationType | 17 live values | live 2302 | unchanged |
| MediaSourceType | 18 live values | live 2322 | now types DERIVED_FROM_SOURCE.sourceType |
| GraphViewType | 13 live values | live 2343 | unchanged |
| LabelRegionType | 13 live values | live 2359 | unchanged |
| MediaRelationRole | 26 live values | live 300 | unchanged; also types `intendedRole` |
| MediaCaptureRelation | SAME_BYTES_AS_SNAPSHOT, EXTRACTED_FROM_REGION, FRAME_FROM_TIME_RANGE, RENDERED_FROM_SOURCE_DATA, TRANSCODED_FROM_SNAPSHOT | new | successor of free-text sourceRole |
| MediaSuitabilityDimension | DISPLAY_QUALITY, DEPICTION_ACCURACY, AUTHENTICITY, EXTRACTION_ACCURACY | new | evidence strength deliberately absent (W10) |
| SuitabilityVerdict | SUITABLE, MARGINAL, UNSUITABLE, UNKNOWN, NOT_ASSESSED | new | A7 missingness |
| MediaRightsStatus | OPEN_LICENSE, PUBLIC_DOMAIN, ALL_RIGHTS_RESERVED, RESTRICTED_TERMS, PERMISSION_GRANTED, HELD_BY_OPERATOR, NO_STATEMENT_FOUND, AMBIGUOUS | new | absence of a record = not checked |
| RightsStatementKind | LICENSE_OFFER, COPYRIGHT_NOTICE, SITE_TERMS, PERMISSION_GRANT, REPOSITORY_METADATA, OPERATOR_RECORD | new | |
| RightsStatementScope | THIS_ASSET, CONTENT_CLASS_ON_SITE, ENTIRE_SITE, CONTAINING_WORK, DATASET_RECORD | new | |
