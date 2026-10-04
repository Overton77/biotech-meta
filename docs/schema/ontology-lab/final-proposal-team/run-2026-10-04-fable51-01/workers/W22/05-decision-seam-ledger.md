# W22 decision, objection and seam ledger

Status words: **ACCEPTED-FOR-PROPOSAL** (W22 decides inside its own scope; Fable may overrule), **REQUESTED** (needs another owner; see `seam-requests.yaml`), **UNRESOLVED** (open, with closure criteria). No consensus is claimed for any item another owner has not answered.

## 1. Decisions

| Id | Decision | Alternatives rejected (evidence) | Status |
|---|---|---|---|
| W22-D01 | **MediaSource is retired.** No projection type is kept. Each field maps to W00 Source/SourceSnapshot/SourceLocator or FigurePanel, and the asset links with `DERIVED_FROM_SOURCE {captureRelation}` to a SourceLocator. `MediaSourceType` survives as the edge's `sourceType`. | Keep as a read-only projection: it would be a second locator type with its own drift (alignment line 436 "a locator in all but name"; A8; W19 "no alternative snapshot/locator"). | ACCEPTED-FOR-PROPOSAL |
| W22-D02 | **Asset vs source:** MediaAsset is an InformationArtifact work-object. It shares bytes with a SourceSnapshot only through equal raw-byte `contentHash` (`SAME_BYTES_AS_SNAPSHOT`). | MediaAsset as a Source subtype: a BellLabs crop or overlay would become "a source"; mp6 shows an ANNOTATED rendition must never back a locator. | ACCEPTED-FOR-PROPOSAL |
| W22-D03 | **Byte facts live on renditions.** Exactly one ORIGINAL rendition exists. `HAS_ANNOTATION` moves from MediaAsset to MediaVariant. | Asset-level width/height/hash: Elysium serves each image at width 1946 and 416 (S09); pixel regions differ by the factor 1946/416. | ACCEPTED-FOR-PROPOSAL |
| W22-D04 | **CL-014:** media `HAS_VARIANT` → `HAS_MEDIA_VARIANT`. | — | RULED (ledger), implemented |
| W22-D05 | **CL-011 / D-010:** IMAGE_REGION locator → `mediaAnnotationUid` + W00 `LOCATES_REGION`. W22 defines only the inverse field `MediaAnnotation.locatedBy`. Additional media rules: the annotated rendition's bytes equal the locator's snapshot bytes (V-602), and support uses only ORIGINAL renditions (V-606). | Annotation as locator (no locator node): it would lose the snapshot binding and REANCHORS. | ACCEPTED-FOR-PROPOSAL. Crop fixture supplied (mp5) as CL-011 asked. W00 must confirm V-602/V-606 |
| W22-D06 | **DEPICTS, EXPLAINS, VISUALIZES, ANNOTATES_SUBJECT and HAS_RIGHTS_RECORD are asserted** (one Assertion per edge episode, `MediaLinkProperties` / `AssertedEdgeProperties`). | Structural with Activity lineage only: it cannot carry a capture-fidelity verdict when alt text names the wrong product or a marketplace shows another variant. The cost (one Assertion per link) is accepted; see 07-operations. | ACCEPTED-FOR-PROPOSAL |
| W22-D07 | **EVIDENCES is derived only** (MEDIA-EV-1), read-only in GraphQL. Its target is propositions (`MediaVisualizableRelationshipTarget`). | Keep the free-written EVIDENCES to entities: "depiction/explanation is not causal proof", and the media/protocol review requires "an actual evidence/locator path". mp3 negative n2 shows a hand-written edge caught by V-604/V-605. | ACCEPTED-FOR-PROPOSAL |
| W22-D08 | **SUPPORTS_CLAIM, SUPPORTS_CLAIM_OCCURRENCE, SUPPORTED_BY_CHUNK (media), ProductLabelRegion.MENTIONS/ASSERTS retired.** | Keep as derived shortcuts: they duplicate EVIDENCES and kernel SUPPORTED_BY, and MENTIONS would be a third meaning of the name. | ACCEPTED-FOR-PROPOSAL |
| W22-D09 | **MediaSuitabilityAssessment promoted** (EvidenceAssessment, one dimension per node, per role). Live `qualityScore`/`authenticityScore` migrate as `legacy-unsourced` and are ignored by selection. | Keep the scores: Q-MP1-2 reproduces the failure (0.97 unsourced wins). One composite score: the catalog forbids averaging missing dimensions, and suitability is role-specific (Q-MP2-2). | ACCEPTED-FOR-PROPOSAL |
| W22-D10 | **MediaRightsRecord promoted** (VersionedState, one record per stated offer, terms version or scope). The attachment is asserted and supported by a locator on the captured terms. Absence of a record = not checked. | Strings on the asset fail S01 (dual offer), S02 (content-class split), S04 (not_available vs not checked) and S04-S06 (free to read ≠ licensed). Adopting ODRL policies is a W23/user decision, and ODRL review is open (S12 read for alignment only). | ACCEPTED-FOR-PROPOSAL; permission semantics REQUESTED (W22-SR-10) |
| W22-D11 | **Permission is not modelled in W22.** Display permission is `Activity -AUTHORIZED_BY {useKind: DISPLAY_MEDIA}-> PolicyVersion`. The allow-list used in fixtures is an assumption pending W23. | A `displayAllowed` Boolean on the asset or rights record: that would encode a legal or policy conclusion as a source fact. | ACCEPTED-FOR-PROPOSAL; useKind REQUESTED (W22-SR-02) |
| W22-D12 | **RenderingMetadata, BiologicalModelMetadata, MolecularRenderingMetadata and AnnotationMetadata retired.** The registry names their successors (`RenderingProperties`, ...) as W22-owned, but they are not defined. | Keep as edge properties: no live relationship used them (verified by grep), and render parameters belong to the generating Activity (one run, N assets). | ACCEPTED-FOR-PROPOSAL |
| W22-D13 | **MediaSubjectTarget** keeps concept coverage (Mechanism, Pathway, Biomarker, Metric, Condition, Outcome, Protocol, …). It removes CohortParticipant and AnonymousActor (privacy; nothing to depict), snapshots, retrieval units, propositions and media self-members, and adds Trademark, CertificationProgram, ProductVariant, PackageConfiguration and others. | Keep live membership verbatim: it includes retired names and a private-data risk (CL-018). | ACCEPTED-FOR-PROPOSAL; membership confirmation REQUESTED (W22-SR-12) |
| W22-D14 | **ProductLabelMentionTarget retired.** It is replaced by `REGION_HAS_DECLARATION` → W04 `LabelDeclaration`. | Keep a derived region→material shortcut: no CQ needs it; the W04 path suffices. | ACCEPTED-FOR-PROPOSAL; W04 confirmation REQUESTED (W22-SR-07) |
| W22-D15 | **No @vector in the fragment** (D-014). The retrieval justification for MediaAsset/GraphView vectors is written in 07-operations R-3, and Fable decides. | — | ACCEPTED-FOR-PROPOSAL |
| W22-D16 | **`statedChecksum` and `perceptualHash(+Algorithm)` are kept separate from `contentHash`.** | Store the Commons SHA-1 in `checksumSha256`/`contentHash`: wrong algorithm, and it claims we hashed the bytes. | ACCEPTED-FOR-PROPOSAL |

## 2. Objections raised against my own model (Challenger pass)

| Objection | Answer | Residual |
|---|---|---|
| "An Assertion per DEPICTS link explodes ingestion volume." | Real, and bounded by asset count × subjects (typically 1-3). Ingestion can write Assertions in batch with status EXTRACTED and one Activity, and one capture-fidelity adjudication per batch review. | Cost estimate in 07; Fable may downgrade DEPICTS to structural for operator-captured photos only (see UNRESOLVED U-03). |
| "Rights records are legal interpretation." | The record holds what a source **states**, verbatim, with scope. Classification into `rightsStatus` is a curator act with Activity lineage and can be corrected (SOURCE_CORRECTION). No legal conclusion (fair use, copyrightability of data) is stored. | The Reactome illustration-vs-data reading is an interpretation, recorded in `description`. |
| "IMAGE_REGION byte equality fails for pages where the image is embedded in HTML." | The image is its own Source (its file URL) with its own snapshot. The page snapshot is a different Source. mp1/mp5 model the CDN file as a Source. | Requires capturing image bytes. This session could not (proxy), so every fixture hash is synthetic. |
| "Generated illustrations of our own assertions could be useful evidence summaries." | They are derived from our assertions (mp3: the generating Activity USED the assertion). Citing them would be circular. They can EXPLAIN and be displayed with a generated label. | none |

## 3. Unresolved items (with closure criteria)

| Id | Item | Owner | Closure criterion |
|---|---|---|---|
| U-01 | useKind DISPLAY_MEDIA / DERIVE_MEDIA | W00 + W23 | enum value frozen; V-608 updated to the final value |
| U-02 | PolicyVersion media allow-list and duties; capture from sites whose terms prohibit crawlers (Elysium S11) | W23 (user input: rights/use policy vocabulary, handoff section 8) | W23 publishes policy content; fixtures' inline allow-list replaced by a parameter sourced from it |
| U-03 | Whether operator-captured photos may use structural DEPICTS (no Assertion) | Fable | ruling in 03-conflict-ledger; if accepted, V-612 exempts `generatedBy` → Activity with an operator Agent |
| U-04 | IMG-PX1 normalization and EXIF orientation rule | W00 | registered in conventions.normalizationVersions |
| U-05 | uid tokens | W00 | registered |
| U-06 | Activity/USED/WAS_GENERATED_BY ranges for media | W00 | catalog relationship ranges extended |
| U-07 | Union membership pruning (Association, LegalEntity, Facility vs PhysicalLocation CL-015) | W03, W01, Fable | merged schema builds with MediaSubjectTarget members present |
| U-08 | Real RAW_BYTES capture of at least one image (Commons original, BIA file) to replace synthetic hashes | W19 / operator with egress | one fixture rerun with a real `sha256:` over bytes and `contentHashBasis: RAW_BYTES` |
| U-09 | ODRL 2.2 alignment or adoption for rights and policy | W23, user | review recorded; MediaRightsRecord kept as the stated-terms layer either way |
| U-10 | GraphView INCLUDES_SUBJECT derivation (GRAPHVIEW-INCLUDE-1) has no fixture | W22 follow-up | a GraphView fixture with a viewpoint and a correction |
| U-11 | W00 AssertionSubjectTarget still lists retired MediaSource and lacks MediaRightsRecord (found by running merge-fragments.mjs over all worker fragments on 2026-10-04) | W00 (W22-SR-13) | merged schema has no undefined union member; HAS_RIGHTS_RECORD assertion objects typed |

## 4. Kernel-change requests

None change kernel semantics. W22-SR-02/03/04/05/06 request **vocabulary and range additions** to W00-owned enums and relationship ranges. Each has a failing case in the fixtures and a primary-source basis: S11 for capture terms, S09 for renditions, S01 for the stated checksum.
