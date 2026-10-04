// =====================================================================================================
// Wave 5 Challenger CH-W21W22-media (Opus 5.5): counterexample mutations against the assembled artifacts.
// Target: Neo4j 5.26.31 Community (embedded, isolated instance c4) loaded with
//   docs/schema/neo4j/final_biotech_schema_operations.cypher, the six translated 0.2.0 fixtures
//   (validation/fixtures-final/) plus backfill, then (group load, one graph) W21 fx01, fx02b, fx03, fx04, fx05,
//   fx06, fx07 and W22 mp1..mp6. fx02a was NOT loaded (it shares uids with fx02b; W21 documents a fresh graph
//   per fixture); CH-M-12 rebuilds the fx02a shape on fresh uids instead.
// Validators run after every APPLY block: docs/schema/neo4j/validation.cypher (validation-params.json),
//   workers/W00/validation-corrections.cypher, workers/W21/fixtures/w21-validation.cypher,
//   workers/W22/fixtures/v-media-validation.cypher. Rows are compared with the post-load baseline.
// Layout: each objection has `// ==== CH-M-nn APPLY`, optional `// ==== CH-M-nn PROBE` (read-only demonstration
//   query) and `// ==== CH-M-nn UNDO` blocks. Run APPLY, validators, PROBE, then UNDO before the next objection.
//   Every statement binds its nodes by uid; no variable crosses ';'. All new uids contain `chm`.
// =====================================================================================================


// ==== CH-M-01 APPLY ====
// CH-M-01 (1/4): an AI-made image whose generationMode arrived as UNKNOWN (isSynthetic true), its file Source,
// a COMPLETE snapshot and an ORIGINAL rendition with the same bytes.
MERGE (s:Source:Entity {uid: 'hu:source:chm01-ai-image-file'})
SET s.id = 'chm01-ai-image-file', s.entityType = 'SOURCE', s.canonicalUri = 'https://cdn.example.invalid/chm01/mtdna-release-render.png', s.sourceKind = 'MEDIA_FILE', s.privacyClass = 'PUBLIC'
MERGE (ss:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chm01-ai-image-file-2026-10-04'})
SET ss.id = 'chm01-ai-image-file-2026-10-04', ss.artifactType = 'SOURCE_SNAPSHOT', ss.canonicalUri = s.canonicalUri, ss.retrievedAt = datetime('2026-10-04T04:00:00Z'),
    ss.contentHash = 'sha256:87805ec407c3efd3645d1b8b03982bad23ce037ac6e983fef3c874a25a39891c', ss.contentHashBasis = 'SYNTHETIC_FIXTURE', ss.captureCompleteness = 'COMPLETE', ss.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(ss)
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:chm01-ai-mtdna-image'})
SET m.id = 'chm01-ai-mtdna-image', m.artifactType = 'MEDIA_ASSET', m.assetType = 'MICROSCOPY_IMAGE', m.mediaPurpose = 'SCIENTIFIC_FIGURE', m.generationMode = 'UNKNOWN', m.isSynthetic = true,
    m.contentHash = 'sha256:87805ec407c3efd3645d1b8b03982bad23ce037ac6e983fef3c874a25a39891c', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC'
MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:chm01-ai-mtdna-image-original'})
SET v.id = 'chm01-ai-mtdna-image-original', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.contentHash = 'sha256:87805ec407c3efd3645d1b8b03982bad23ce037ac6e983fef3c874a25a39891c', v.contentHashBasis = 'SYNTHETIC_FIXTURE', v.privacyClass = 'PUBLIC'
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v);

// CH-M-01 (2/4): region annotation on the ORIGINAL rendition and the IMAGE_REGION locator on the snapshot (D-010 shape).
MATCH (v:MediaVariant {uid: 'hu:media-variant:chm01-ai-mtdna-image-original'}), (ss:SourceSnapshot {uid: 'hu:snapshot:chm01-ai-image-file-2026-10-04'})
MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:chm01-region'})
SET ann.id = 'chm01-region', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 100.0, ann.y = 80.0, ann.width = 200.0, ann.height = 160.0, ann.privacyClass = 'PUBLIC'
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm01-region'})
SET l.id = 'chm01-region', l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'IMAGE_REGION', l.mediaAnnotationUid = ann.uid, l.normalizationVersion = 'IMG-PX1', l.privacyClass = 'PUBLIC'
MERGE (v)-[:HAS_ANNOTATION]->(ann) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (l)-[:LOCATES_REGION]->(ann);

// CH-M-01 (3/4): a DIRECT_MEASUREMENT mechanism assertion supported by that region (same shape as MP3's real capture).
MATCH (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}),
      (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}), (l:SourceLocator {uid: 'hu:locator:chm01-region'})
MERGE (x:Assertion {uid: 'hu:assertion:chm01-mtdna-release-measured'})
SET x.id = 'chm01-mtdna-release-measured', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T04:05:00Z'), x.predicateClass = 'MECHANISM',
    x.basisKind = 'DIRECT_MEASUREMENT', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l);

// CH-M-01 (4/4): the official derivation job MEDIA-EV-1, verbatim from mp3 except for the uid scope filter.
MATCH (x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
WHERE x.uid = 'hu:assertion:chm01-mtdna-release-measured' AND l.mediaAnnotationUid = ann.uid AND v.contentHash = ss.contentHash AND coalesce(m.generationMode, 'UNKNOWN') <> 'GENERATED'
WITH m, x, collect(DISTINCT x.uid) AS fromAssertions
MERGE (m)-[e:EVIDENCES {derivationRule: 'MEDIA-EV-1'}]->(x)
SET e.derivedFromAssertionUids = fromAssertions, e.derivedAt = datetime('2026-10-04T04:10:00Z')
RETURN m.uid AS evidencingAsset, x.uid AS evidencedAssertion;

// ==== CH-M-01 PROBE ====
// CH-M-01 probe: Q-MP3-1 verdict logic on the new path (expected by the attack: EVIDENCE_PATH_OK for a synthetic image).
MATCH (x:Assertion {uid: 'hu:assertion:chm01-mtdna-release-measured'})-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
OPTIONAL MATCH (m)-[e:EVIDENCES]->(x)
RETURN m.uid AS asset, m.generationMode AS generationMode, m.isSynthetic AS isSynthetic, e.derivationRule AS evidencesRule,
       CASE WHEN m.generationMode = 'GENERATED' THEN 'REJECTED_GENERATED_ASSET' WHEN v.variantKind <> 'ORIGINAL' THEN 'REJECTED_DERIVED_RENDITION'
            WHEN v.contentHash <> ss.contentHash THEN 'REJECTED_BYTES_MISMATCH' ELSE 'EVIDENCE_PATH_OK' END AS verdict;

// ==== CH-M-01 UNDO ====
// CH-M-01 undo
MATCH (n) WHERE n.uid IN ['hu:source:chm01-ai-image-file', 'hu:snapshot:chm01-ai-image-file-2026-10-04', 'hu:media-asset:chm01-ai-mtdna-image', 'hu:media-variant:chm01-ai-mtdna-image-original',
                          'hu:media-annotation:chm01-region', 'hu:locator:chm01-region', 'hu:assertion:chm01-mtdna-release-measured']
DETACH DELETE n;


// ==== CH-M-02 APPLY ====
// CH-M-02 (1/3): BellLabs' own callout overlay of the S-BIAD807 capture (bytes of MP6's ANNOTATED variant) registered as a
// separate MediaAsset (generationMode ANNOTATED, isEdited left null) whose only rendition is labelled ORIGINAL, with a
// "snapshot" of BellLabs' own media store. Lineage to the real capture is recorded (WAS_GENERATED_BY the MP6 overlay activity).
MATCH (act:Activity {uid: 'hu:activity:w22-annotate-s-biad807-callouts-synthetic'})
MERGE (s:Source:Entity {uid: 'hu:source:chm02-belllabs-store-callouts'})
SET s.id = 'chm02-belllabs-store-callouts', s.entityType = 'SOURCE', s.canonicalUri = 'urn:belllabs:media-store:s-biad807-callouts', s.sourceKind = 'MEDIA_FILE', s.privacyClass = 'PUBLIC'
MERGE (ss:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chm02-belllabs-store-callouts'})
SET ss.id = 'chm02-belllabs-store-callouts', ss.artifactType = 'SOURCE_SNAPSHOT', ss.canonicalUri = s.canonicalUri, ss.retrievedAt = datetime('2026-10-04T04:20:00Z'),
    ss.contentHash = 'sha256:faac0422e3dd456c9cd56bb560fd2a7ca2ff9ca3d857a01e47c393918a08a4a2', ss.contentHashBasis = 'SYNTHETIC_FIXTURE', ss.captureCompleteness = 'COMPLETE', ss.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(ss)
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:chm02-s-biad807-callouts-as-asset'})
SET m.id = 'chm02-s-biad807-callouts-as-asset', m.artifactType = 'MEDIA_ASSET', m.assetType = 'MICROSCOPY_IMAGE', m.mediaPurpose = 'SCIENTIFIC_FIGURE', m.generationMode = 'ANNOTATED',
    m.contentHash = 'sha256:faac0422e3dd456c9cd56bb560fd2a7ca2ff9ca3d857a01e47c393918a08a4a2', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC'
MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:chm02-callouts-original'})
SET v.id = 'chm02-callouts-original', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.contentHash = m.contentHash, v.contentHashBasis = 'SYNTHETIC_FIXTURE', v.privacyClass = 'PUBLIC'
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v) MERGE (m)-[:WAS_GENERATED_BY]->(act) MERGE (v)-[:WAS_GENERATED_BY]->(act);

// CH-M-02 (2/3): region drawn on the overlay's pixel grid (1024 px upscaled) and an assertion supported by it.
MATCH (v:MediaVariant {uid: 'hu:media-variant:chm02-callouts-original'}), (ss:SourceSnapshot {uid: 'hu:snapshot:chm02-belllabs-store-callouts'}),
      (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}),
      (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:chm02-region-on-overlay'})
SET ann.id = 'chm02-region-on-overlay', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 480.0, ann.y = 352.0, ann.width = 640.0, ann.height = 560.0, ann.privacyClass = 'PUBLIC'
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm02-region-on-overlay'})
SET l.id = 'chm02-region-on-overlay', l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'IMAGE_REGION', l.mediaAnnotationUid = ann.uid, l.normalizationVersion = 'IMG-PX1', l.privacyClass = 'PUBLIC'
MERGE (v)-[:HAS_ANNOTATION]->(ann) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (l)-[:LOCATES_REGION]->(ann)
MERGE (x:Assertion {uid: 'hu:assertion:chm02-claim-cited-on-overlay'})
SET x.id = 'chm02-claim-cited-on-overlay', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T04:25:00Z'), x.predicateClass = 'MECHANISM',
    x.basisKind = 'DIRECT_MEASUREMENT', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l);

// CH-M-02 (3/3): MEDIA-EV-1 verbatim (uid-scoped).
MATCH (x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
WHERE x.uid = 'hu:assertion:chm02-claim-cited-on-overlay' AND l.mediaAnnotationUid = ann.uid AND v.contentHash = ss.contentHash AND coalesce(m.generationMode, 'UNKNOWN') <> 'GENERATED'
WITH m, x, collect(DISTINCT x.uid) AS fromAssertions
MERGE (m)-[e:EVIDENCES {derivationRule: 'MEDIA-EV-1'}]->(x)
SET e.derivedFromAssertionUids = fromAssertions, e.derivedAt = datetime('2026-10-04T04:30:00Z')
RETURN m.uid AS evidencingAsset, x.uid AS evidencedAssertion;

// ==== CH-M-02 PROBE ====
// CH-M-02 probe: Q-MP6-2 evidence-use logic over the laundered asset (attack expects RAW_CAPTURE_OK).
MATCH (m:MediaAsset {uid: 'hu:media-asset:chm02-s-biad807-callouts-as-asset'})-[:HAS_MEDIA_VARIANT]->(v:MediaVariant)
OPTIONAL MATCH (ss:SourceSnapshot {contentHash: v.contentHash})
OPTIONAL MATCH (m)-[e:EVIDENCES]->(x)
RETURN m.uid AS asset, v.variantKind AS kind, m.generationMode AS generationMode, ss.uid AS sameBytesSnapshot, e.derivationRule AS evidencesRule,
  CASE WHEN v.variantKind <> 'ORIGINAL' THEN 'NOT_FOR_EVIDENCE_EDITED_RENDITION' WHEN ss IS NULL THEN 'NOT_FOR_EVIDENCE_NO_CAPTURE'
       WHEN m.isEdited THEN 'PUBLISHED_COMPOSITE_CITE_AS_FIGURE' ELSE 'RAW_CAPTURE_OK' END AS evidenceUse;

// ==== CH-M-02 UNDO ====
// CH-M-02 undo
MATCH (n) WHERE n.uid IN ['hu:source:chm02-belllabs-store-callouts', 'hu:snapshot:chm02-belllabs-store-callouts', 'hu:media-asset:chm02-s-biad807-callouts-as-asset',
                          'hu:media-variant:chm02-callouts-original', 'hu:media-annotation:chm02-region-on-overlay', 'hu:locator:chm02-region-on-overlay', 'hu:assertion:chm02-claim-cited-on-overlay']
DETACH DELETE n;


// ==== CH-M-03 APPLY ====
// CH-M-03 (1/2): a GENERATED illustration whose rendition is attached with the pre-CL-014 edge name HAS_VARIANT (a writer
// that predates the one-shot rename in the operations file), with a same-bytes snapshot and a region locator.
MERGE (s:Source:Entity {uid: 'hu:source:chm03-generated-file'})
SET s.id = 'chm03-generated-file', s.entityType = 'SOURCE', s.canonicalUri = 'https://cdn.example.invalid/chm03/generated-pyroptosis.png', s.sourceKind = 'MEDIA_FILE', s.privacyClass = 'PUBLIC'
MERGE (ss:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chm03-generated-file'})
SET ss.id = 'chm03-generated-file', ss.artifactType = 'SOURCE_SNAPSHOT', ss.canonicalUri = s.canonicalUri, ss.retrievedAt = datetime('2026-10-04T04:40:00Z'),
    ss.contentHash = 'sha256:2a6046cada1b17bd09a11f6546c757deb86f7779691a6e30fadabec5b4af1250', ss.contentHashBasis = 'SYNTHETIC_FIXTURE', ss.captureCompleteness = 'COMPLETE', ss.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(ss)
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:chm03-generated-illustration'})
SET m.id = 'chm03-generated-illustration', m.artifactType = 'MEDIA_ASSET', m.assetType = 'DIAGRAM', m.generationMode = 'GENERATED', m.isSynthetic = true,
    m.contentHash = 'sha256:2a6046cada1b17bd09a11f6546c757deb86f7779691a6e30fadabec5b4af1250', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC'
MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:chm03-generated-original'})
SET v.id = 'chm03-generated-original', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.contentHash = 'sha256:2a6046cada1b17bd09a11f6546c757deb86f7779691a6e30fadabec5b4af1250', v.contentHashBasis = 'SYNTHETIC_FIXTURE', v.privacyClass = 'PUBLIC'
MERGE (m)-[:HAS_VARIANT]->(v);

// CH-M-03 (2/2): region + assertion supported by the generated image's region.
MATCH (v:MediaVariant {uid: 'hu:media-variant:chm03-generated-original'}), (ss:SourceSnapshot {uid: 'hu:snapshot:chm03-generated-file'}),
      (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}),
      (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:chm03-region'})
SET ann.id = 'chm03-region', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 10.0, ann.y = 10.0, ann.width = 50.0, ann.height = 50.0, ann.privacyClass = 'PUBLIC'
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm03-region'})
SET l.id = 'chm03-region', l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'IMAGE_REGION', l.mediaAnnotationUid = ann.uid, l.normalizationVersion = 'IMG-PX1', l.privacyClass = 'PUBLIC'
MERGE (v)-[:HAS_ANNOTATION]->(ann) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (l)-[:LOCATES_REGION]->(ann)
MERGE (x:Assertion {uid: 'hu:assertion:chm03-claim-cited-on-generated'})
SET x.id = 'chm03-claim-cited-on-generated', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T04:45:00Z'), x.predicateClass = 'MECHANISM',
    x.basisKind = 'DIRECT_MEASUREMENT', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l);

// CH-M-03 (3/3): the writer copies the asserted-edge profile onto the legacy edge (relationshipUid, assertionUid, recordedFrom),
// which is all kernel V-101 checks. Run once WITHOUT this statement as well: V-101 then catches the bare edge (observed).
MATCH (:MediaAsset {uid: 'hu:media-asset:chm03-generated-illustration'})-[r:HAS_VARIANT]->(:MediaVariant {uid: 'hu:media-variant:chm03-generated-original'})
SET r.relationshipUid = 'hu:rel:chm03-legacy-has-variant', r.assertionUid = 'hu:assertion:chm03-legacy-has-variant-never-written',
    r.recordedFrom = datetime('2026-10-04T04:46:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// ==== CH-M-03 PROBE ====
// CH-M-03 probe: CQ-PV-01 state-2 path (assertion -> locator -> snapshot -> Source) with the bytes' owner, reachable only via HAS_VARIANT.
MATCH (x:Assertion {uid: 'hu:assertion:chm03-claim-cited-on-generated'})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(ss:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (l)-[:LOCATES_REGION]->(:MediaAnnotation)<-[:HAS_ANNOTATION]-(:MediaVariant)<-[r:HAS_VARIANT|HAS_MEDIA_VARIANT]-(m:MediaAsset)
RETURN x.uid AS assertion, src.uid AS supportingSource, type(r) AS variantEdge, m.generationMode AS generationMode;

// ==== CH-M-03 UNDO ====
// CH-M-03 undo
MATCH (n) WHERE n.uid IN ['hu:source:chm03-generated-file', 'hu:snapshot:chm03-generated-file', 'hu:media-asset:chm03-generated-illustration', 'hu:media-variant:chm03-generated-original',
                          'hu:media-annotation:chm03-region', 'hu:locator:chm03-region', 'hu:assertion:chm03-claim-cited-on-generated']
DETACH DELETE n;


// ==== CH-M-04 APPLY ====
// CH-M-04: asset as evidence without a locator path to a snapshot. An IMAGE_REGION locator that hangs from no SourceSnapshot
// selects a region of the real S-BIAD807 ORIGINAL rendition; an EVIDENCES edge names MEDIA-EV-1 and its input assertion.
MATCH (v:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-original'}), (m:MediaAsset {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'}),
      (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}),
      (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:chm04-region'})
SET ann.id = 'chm04-region', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 20.0, ann.y = 20.0, ann.width = 80.0, ann.height = 80.0, ann.privacyClass = 'PUBLIC'
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm04-orphan-region'})
SET l.id = 'chm04-orphan-region', l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'IMAGE_REGION', l.mediaAnnotationUid = ann.uid, l.normalizationVersion = 'IMG-PX1', l.privacyClass = 'PUBLIC'
MERGE (v)-[:HAS_ANNOTATION]->(ann) MERGE (l)-[:LOCATES_REGION]->(ann)
MERGE (x:Assertion {uid: 'hu:assertion:chm04-claim-on-orphan-region'})
SET x.id = 'chm04-claim-on-orphan-region', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T04:50:00Z'), x.predicateClass = 'MECHANISM',
    x.basisKind = 'DIRECT_MEASUREMENT', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l)
MERGE (m)-[e:EVIDENCES {derivationRule: 'MEDIA-EV-1'}]->(x)
SET e.derivedFromAssertionUids = [x.uid], e.derivedAt = datetime('2026-10-04T04:55:00Z');

// ==== CH-M-04 UNDO ====
// CH-M-04 undo
MATCH (n) WHERE n.uid IN ['hu:media-annotation:chm04-region', 'hu:locator:chm04-orphan-region', 'hu:assertion:chm04-claim-on-orphan-region']
DETACH DELETE n;


// ==== CH-M-05 APPLY ====
// CH-M-05: an assertion cites the image rendition itself (SUPPORTED_BY -> MediaVariant), skipping SourceLocator/Snapshot.
MATCH (v:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-original'}), (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}),
      (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}), (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
MERGE (x:Assertion {uid: 'hu:assertion:chm05-claim-cites-rendition'})
SET x.id = 'chm05-claim-cites-rendition', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T05:00:00Z'), x.predicateClass = 'MECHANISM',
    x.basisKind = 'DIRECT_MEASUREMENT', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(v);

// ==== CH-M-05 UNDO ====
// CH-M-05 undo
MATCH (n {uid: 'hu:assertion:chm05-claim-cites-rendition'}) DETACH DELETE n;


// ==== CH-M-06 APPLY ====
// CH-M-06: rendition A's media time reused on rendition B. The YouTube (VIDEO_RENDITION) cue-derived offset 3765-3773 s
// of Sinclair's NMN statement is copied onto the Apple Podcasts record (PODCAST_DIRECTORY_RECORD) of the same Episode,
// whose dynamically inserted ads shift every offset (fx01: sponsor chapter 210 s on YouTube vs 225 s on Apple).
// No caption track of the Apple rendition exists; the basis string is copied as well.
MATCH (y:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-nmn-gram-daily'}), (ss:SourceSnapshot {uid: 'hu:snapshot:apple-podcasts-hl52-2026-10-04'}),
      (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm06-apple-nmn-offset-copied-from-youtube'})
SET l += apoc.map.removeKeys(properties(y), ['uid', 'id']), l.id = 'chm06-apple-nmn-offset-copied-from-youtube',
    l.uri = ss.canonicalUri, l.privacyClass = 'PUBLIC'
MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (a)-[:SUPPORTED_BY]->(l);

// ==== CH-M-06 PROBE ====
// CH-M-06 probe: Q01-2 (locators of the NMN statement per rendition). Expected by fx01: Apple has none.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})-[:OCCURS_IN]->(e:Episode)<-[:RENDITION_OF]-(src:Source)
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)<-[:SUPPORTED_BY]-(a)
RETURN src.sourceKind AS rendition, l.selectorKind AS selectorKind, l.mediaStartSeconds AS mediaStartSeconds, l.mediaTimeBasis AS basis
ORDER BY rendition;

// ==== CH-M-06 UNDO ====
// CH-M-06 undo
MATCH (n {uid: 'hu:locator:chm06-apple-nmn-offset-copied-from-youtube'}) DETACH DELETE n;


// ==== CH-M-07 APPLY ====
// CH-M-07 (1/2): a blog retelling of Sinclair's practice (own act STATES, reported act REPORTS_PRACTICE, ATTRIBUTES_TO
// Sinclair) whose RETELLS link was not made (original not matched yet). It is INSTANCE_OF the same Claim.
MERGE (o:Organization:Entity {uid: 'hu:org:chm07-longevity-blog'})
SET o.id = 'chm07-longevity-blog', o.entityType = 'Organization', o.name = 'Synthetic longevity blog (challenger fixture)', o.privacyClass = 'PUBLIC'
MERGE (s:Source:Entity {uid: 'hu:source:chm07-blog-post'})
SET s.id = 'chm07-blog-post', s.entityType = 'Source', s.canonicalUri = 'https://blog.example.invalid/sinclair-nmn', s.sourceKind = 'PERSONAL_WEBPAGE', s.privacyClass = 'PUBLIC'
MERGE (ss:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chm07-blog-post-2026-10-04'})
SET ss.id = 'chm07-blog-post-2026-10-04', ss.artifactType = 'SourceSnapshot', ss.canonicalUri = s.canonicalUri, ss.retrievedAt = datetime('2026-10-04T05:00:00Z'),
    ss.contentHash = 'sha256:d1b314392423b59c9c93ba2ad6eca23c292ed8ee7559e602f2b06adda3f0344b', ss.contentHashBasis = 'SYNTHETIC_FIXTURE', ss.captureCompleteness = 'COMPLETE', ss.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(ss)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:chm07-blog-sinclair-takes-1g'})
SET l.id = 'chm07-blog-sinclair-takes-1g', l.artifactType = 'SourceLocator', l.selectorKind = 'TEXT_QUOTE', l.normalizationVersion = 'NFC-WS1',
    l.exact = 'David Sinclair says he takes a gram of NMN every day.', l.privacyClass = 'PUBLIC'
MERGE (ss)-[:HAS_LOCATOR]->(l);

// CH-M-07 (2/2): the occurrence itself.
MATCH (o:Organization {uid: 'hu:org:chm07-longevity-blog'}), (s:Source {uid: 'hu:source:chm07-blog-post'}), (l:SourceLocator {uid: 'hu:locator:chm07-blog-sinclair-takes-1g'}),
      (p:Person {uid: 'hu:person:david-a-sinclair'}), (n:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:chm07-blog-says-sinclair-takes-1g'})
SET a.id = 'chm07-blog-says-sinclair-takes-1g', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.reportedSpeechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY', a.recordedAt = datetime('2026-10-04T05:05:00Z'),
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC'
MERGE (a)-[:ASSERTED_BY]->(o) MERGE (a)-[:OCCURS_IN]->(s) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:HAS_SUBJECT]->(n) MERGE (a)-[:ATTRIBUTES_TO]->(p)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

// ==== CH-M-07 PROBE ====
// CH-M-07 probe: Q04-1 restricted to the claim (fx04 expected independentFirstHand 1 before the group load).
MATCH (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
OPTIONAL MATCH (a:Assertion)-[:INSTANCE_OF]->(c)
WITH c, collect(a) AS inst
RETURN c.uid AS claim, size(inst) AS allInstances, size([x IN inst WHERE NOT EXISTS { (x)-[:RETELLS]->() }]) AS independentFirstHand,
       [x IN inst WHERE NOT EXISTS { (x)-[:RETELLS]->() } | x.uid] AS countedAsFirstHand;

// ==== CH-M-07 UNDO ====
// CH-M-07 undo
MATCH (n) WHERE n.uid IN ['hu:org:chm07-longevity-blog', 'hu:source:chm07-blog-post', 'hu:snapshot:chm07-blog-post-2026-10-04', 'hu:locator:chm07-blog-sinclair-takes-1g',
                          'hu:claim-occurrence:chm07-blog-says-sinclair-takes-1g']
DETACH DELETE n;


// ==== CH-M-08 APPLY ====
// CH-M-08: one utterance, two occurrences. A second extraction run over the YouTube rendition mints its own occurrence
// of Sinclair's NMN statement (same asserter, same Episode container, same YouTube locator, same Claim).
MATCH (orig:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'}), (p:Person {uid: 'hu:person:david-a-sinclair'}),
      (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-nmn-gram-daily'}),
      (n:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:chm08-hl52-sinclair-nmn-youtube-run'})
SET a += apoc.map.removeKeys(properties(orig), ['uid', 'id']), a.id = 'chm08-hl52-sinclair-nmn-youtube-run', a.status = 'PROPOSED',
    a.recordedAt = datetime('2026-10-04T05:10:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:ASSERTED_BY]->(p) MERGE (a)-[:OCCURS_IN]->(e) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:HAS_SUBJECT]->(n)
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'w21-manual-proposition-match-v0.1';

// ==== CH-M-08 PROBE ====
// CH-M-08 probe (a): fx04 Q04-1 verbatim (its distinctFirstHandAsserters collects without DISTINCT).
MATCH (c:Claim)
OPTIONAL MATCH (a:Assertion)-[:INSTANCE_OF]->(c)
WITH c, collect(a) AS inst
UNWIND (CASE WHEN size(inst) = 0 THEN [null] ELSE inst END) AS a
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
WITH c, inst, collect(CASE WHEN a IS NOT NULL AND NOT EXISTS { (a)-[:RETELLS]->() } THEN who.uid END) AS firstHandAsserters
WHERE c.uid = 'hu:claim:sinclair-reports-taking-1g-nmn-daily'
RETURN c.claimText AS claim, size(inst) AS allInstances,
       size([x IN inst WHERE NOT EXISTS { (x)-[:RETELLS]->() }]) AS independentFirstHand,
       size(firstHandAsserters) AS distinctFirstHandAsserters, firstHandAsserters;

// CH-M-08 probe (b): W19 Q-06 (independent primary lines) for the same claim.
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-nmn-daily'})
OPTIONAL MATCH (a)-[:RETELLS*1..10]->(root:Assertion)
WHERE NOT (root)-[:RETELLS]->()
WITH c, a, coalesce(root, a) AS primary
RETURN c.uid AS claimUid, count(DISTINCT a) AS assertions, count(DISTINCT primary) AS independentPrimaryLines, collect(DISTINCT primary.uid) AS primaryUids;

// ==== CH-M-08 UNDO ====
// CH-M-08 undo
MATCH (n {uid: 'hu:claim-occurrence:chm08-hl52-sinclair-nmn-youtube-run'}) DETACH DELETE n;


// ==== CH-M-09 APPLY ====
// CH-M-09: a derived Person-[:RECOMMENDS]-> licensed by a SPONSOR-READ occurrence. The host's paid InsideTracker read
// ("I recommend you get your blood work done with InsideTracker") is captured with speechAct RECOMMENDS, segmentKind
// SPONSOR_READ, inside the YouTube SPONSOR_READ segment; the projection job writes Huberman -> InsideTracker.
MATCH (h:Person {uid: 'hu:person:andrew-d-huberman'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'}), (b:ConsumerBrand {uid: 'hu:brand:insidetracker'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:chm09-host-recommends-insidetracker-in-sponsor-read'})
SET a.id = 'chm09-host-recommends-insidetracker-in-sponsor-read', a.predicate = 'RECOMMENDS', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.speechAct = 'RECOMMENDS',
    a.segmentKind = 'SPONSOR_READ', a.assertionBasis = 'UNSTATED', a.valueString = 'get your blood work done with InsideTracker', a.recordedAt = datetime('2026-10-04T05:15:00Z'), a.validFromBasis = 'PUBLICATION_PROXY', a.validToBasis = 'UNKNOWN',
    a.privacyClass = 'PUBLIC'
MERGE (a)-[:ASSERTED_BY]->(h) MERGE (a)-[:OCCURS_IN]->(e) MERGE (a)-[:OCCURS_IN_SEGMENT]->(g) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:HAS_SUBJECT]->(b)
MERGE (h)-[r:RECOMMENDS {derivationRule: 'speech-act-recommends-projection-v1'}]->(b)
SET r.derivedFromAssertionUids = [a.uid], r.derivedAt = datetime('2026-10-04T05:16:00Z');

// ==== CH-M-09 PROBE ====
// CH-M-09 probe: what the public projection now says.
MATCH (p:Person)-[r:RECOMMENDS]->(x)
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN coalesce(r.derivedFromAssertionUids, [])
RETURN p.name AS recommender, x.name AS recommended, r.derivationRule AS rule, a.segmentKind AS licensingSegmentKind, a.polarity AS licensingPolarity;

// ==== CH-M-09 UNDO ====
// CH-M-09 undo
MATCH (h:Person {uid: 'hu:person:andrew-d-huberman'})-[r:RECOMMENDS]->(:ConsumerBrand {uid: 'hu:brand:insidetracker'}) DELETE r;
// CH-M-09 undo (2)
MATCH (n {uid: 'hu:claim-occurrence:chm09-host-recommends-insidetracker-in-sponsor-read'}) DETACH DELETE n;


// ==== CH-M-10 APPLY ====
// CH-M-10: a derived RECOMMENDS licensed by a NEGATIVE-polarity recommendation ("I would not recommend NMN to anyone").
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-podcast-episode-7-video-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:chm10-podcast-7-does-not-recommend-nmn'})
SET l.id = 'chm10-podcast-7-does-not-recommend-nmn', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'MEDIA_TIME', l.mediaStartSeconds = 1300.0,
    l.mediaEndSeconds = 1304.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE', l.exact = 'I would not recommend NMN to anyone.', l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_LOCATOR]->(l);

// CH-M-10 (2/2)
MATCH (sp:Person {uid: 'hu:person:synthetic-podcast-guest'}), (ep:Episode {uid: 'hu:episode:synthetic-podcast-episode-7'}), (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l:SourceLocator {uid: 'hu:locator:chm10-podcast-7-does-not-recommend-nmn'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:chm10-guest-does-not-recommend-nmn'})
SET a.id = 'chm10-guest-does-not-recommend-nmn', a.predicate = 'RECOMMENDS_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'NEGATIVE', a.assertionBasis = 'EXPERT_OPINION',
    a.speechAct = 'RECOMMENDS', a.valueString = 'NMN, to anyone (negated)', a.recordedAt = datetime('2026-10-04T05:20:00Z'), a.validFromBasis = 'PUBLICATION_PROXY', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(x) MERGE (a)-[:ASSERTED_BY]->(sp) MERGE (a)-[:OCCURS_IN]->(ep) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (sp)-[r:RECOMMENDS {derivationRule: 'speech-act-recommends-projection-v1'}]->(x)
SET r.derivedFromAssertionUids = [a.uid], r.derivedAt = datetime('2026-10-04T05:21:00Z');

// ==== CH-M-10 PROBE ====
// CH-M-10 probe: same projection read as CH-M-09.
MATCH (p:Person)-[r:RECOMMENDS]->(x)
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN coalesce(r.derivedFromAssertionUids, [])
RETURN p.name AS recommender, x.name AS recommended, r.derivationRule AS rule, a.speechAct AS licensingSpeechAct, a.polarity AS licensingPolarity;

// ==== CH-M-10 UNDO ====
// CH-M-10 undo
MATCH (:Person {uid: 'hu:person:synthetic-podcast-guest'})-[r:RECOMMENDS]->(:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}) DELETE r;
// CH-M-10 undo (2)
MATCH (n) WHERE n.uid IN ['hu:claim-occurrence:chm10-guest-does-not-recommend-nmn', 'hu:locator:chm10-podcast-7-does-not-recommend-nmn'] DETACH DELETE n;


// ==== CH-M-11 APPLY ====
// CH-M-11 (1/2): the sponsor-read script presented as the host's own practice. The extractor does not tag the occurrence
// (no segmentKind) and does not link it to the SPONSOR_READ segment; its MEDIA_TIME locator (304 s) still lies inside that
// segment on the same rendition.
MATCH (:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'})-[r:OCCURS_IN_SEGMENT]->(:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'})
DELETE r;
// CH-M-11 (2/2)
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'}) REMOVE a.segmentKind;

// ==== CH-M-11 PROBE ====
// CH-M-11 probe: fx03 Q03-2 verbatim (independent practice reports; expected 1 row, the guest's).
MATCH (a:ClaimOccurrence {speechAct: 'REPORTS_PRACTICE'})-[:OCCURS_IN]->(:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
WHERE coalesce(a.segmentKind, '') <> 'SPONSOR_READ'
  AND NOT EXISTS { MATCH (a)-[:OCCURS_IN_SEGMENT]->(:EpisodeSegment {segmentType: 'SPONSOR_READ'}) }
RETURN a.uid AS independentPracticeReport;

// CH-M-11 probe (b): the signal that was available: the occurrence's media time falls inside a SPONSOR_READ segment's delimiters on the same rendition.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'})-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'MEDIA_TIME'})<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
MATCH (g:EpisodeSegment {segmentType: 'SPONSOR_READ'})-[:DELIMITED_BY]->(d:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src)
RETURN a.uid AS occurrence, l.mediaStartSeconds AS at, g.uid AS segment, collect(d.mediaStartSeconds) AS segmentDelimiterStarts, collect(d.mediaEndSeconds) AS segmentDelimiterEnds;

// ==== CH-M-11 UNDO ====
// CH-M-11 undo
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'}), (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'})
SET a.segmentKind = 'SPONSOR_READ' MERGE (a)-[:OCCURS_IN_SEGMENT]->(g);


// ==== CH-M-12 APPLY ====
// CH-M-12 (1/2): a substantive transcript correction (1 g -> half a gram) recorded with the COSMETIC shape of fx02a: a newer
// snapshot of the transcript page, a re-anchored locator (REANCHORS FUZZY), the original occurrence left ACCEPTED at 1 g,
// no successor and no SUPERSEDES {SOURCE_CORRECTION} (fx02b's required shape).
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:chm12-hubermanlab-52-page-2026-12-01'})
SET s.id = 'chm12-hubermanlab-52-page-2026-12-01', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-12-01T00:00:00Z'),
    s.observedAt = datetime('2026-12-01T00:00:00Z'), s.contentHash = 'sha256:0487b30b566845f639e302714c1661ebfc708b1a6114e08803284c55c29dfdae', s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'PARTIAL_EXCERPT', s.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (act:Occurrence:Activity {uid: 'hu:activity:chm12-reanchoring'})
SET act.id = 'chm12-reanchoring', act.occurrenceType = 'Activity', act.activityKind = 'REANCHORING', act.methodVersion = 'quote-fuzzy-match-v1 (synthetic)', act.privacyClass = 'PUBLIC';

// CH-M-12 (2/2)
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:chm12-hubermanlab-52-page-2026-12-01'}), (old:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'}), (act:Activity {uid: 'hu:activity:chm12-reanchoring'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:chm12-page-nmn-half-gram'})
SET l.id = 'chm12-page-nmn-half-gram', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82-year-old father, we take half a gram of NMN every day.', l.quoteHash = 'sha256:c1cb365794d4a30ed3caeaceafdb836f29ff3f076870a1114365d3627146135a',
    l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_LOCATOR]->(l) MERGE (l)-[:WAS_GENERATED_BY]->(act)
MERGE (l)-[r:REANCHORS]->(old) SET r.anchorMatch = 'FUZZY', r.activityUid = act.uid;

// ==== CH-M-12 PROBE ====
// CH-M-12 probe: the current reading of each ACCEPTED occurrence against the newest re-anchored text of its span.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})-[:SUPPORTED_BY]->(old:SourceLocator)<-[:REANCHORS*1..5]-(cur:SourceLocator)
RETURN a.uid AS occurrence, a.status AS status, a.valueNumber AS recordedValue, a.unitCode AS unit, old.exact AS citedText, cur.exact AS currentText,
       EXISTS { (:Assertion)-[:SUPERSEDES]->(a) } AS superseded;

// ==== CH-M-12 UNDO ====
// CH-M-12 undo
MATCH (n) WHERE n.uid IN ['hu:snapshot:chm12-hubermanlab-52-page-2026-12-01', 'hu:activity:chm12-reanchoring', 'hu:locator:chm12-page-nmn-half-gram'] DETACH DELETE n;


// ==== CH-M-13 APPLY ====
// CH-M-13: the PubMed abstract record (BIBLIOGRAPHIC_RECORD, which the SourceKind doc says is "not a publication
// rendition") declared RENDITION_OF the Publication with renditionCoverage FULL and a COMPLETE capture.
MATCH (p:Publication {uid: 'hu:publication:pmid-29184669'})
MERGE (s:Source:Entity {uid: 'hu:source:chm13-pubmed-29184669'})
SET s.id = 'chm13-pubmed-29184669', s.entityType = 'Source', s.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/', s.title = 'PubMed record 29184669 (abstract page)',
    s.sourceKind = 'BIBLIOGRAPHIC_RECORD', s.renditionCoverage = 'FULL', s.privacyClass = 'PUBLIC'
MERGE (ss:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chm13-pubmed-29184669-2026-10-04'})
SET ss.id = 'chm13-pubmed-29184669-2026-10-04', ss.artifactType = 'SourceSnapshot', ss.canonicalUri = s.canonicalUri, ss.retrievedAt = datetime('2026-10-04T05:30:00Z'),
    ss.contentHash = 'sha256:4cc5a438057cd7699bd39371e99174c4a3dcc0e85f387c1c3062abdd5a9db734', ss.contentHashBasis = 'SYNTHETIC_FIXTURE', ss.captureCompleteness = 'COMPLETE', ss.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (s)-[:RENDITION_OF]->(p);

// ==== CH-M-13 PROBE ====
// CH-M-13 probe: W19 Q-08a not-found reading rule scoped to this rendition (the full text does state who supplied the product).
WITH ['hu:source:chm13-pubmed-29184669'] AS scope, 'PROVIDES_INVESTIGATIONAL_PRODUCT' AS pred
MATCH (src:Source) WHERE src.uid IN scope
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
OPTIONAL MATCH (snap)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion {predicate: pred})
WITH src, collect(DISTINCT snap) AS snaps, collect(DISTINCT a) AS hits
WITH collect({src: src, snaps: snaps, hits: hits}) AS rows
RETURN CASE
  WHEN any(r IN rows WHERE size(r.hits) > 0) THEN 'FOUND'
  WHEN all(r IN rows WHERE size(r.snaps) = 0) THEN 'NOT_CAPTURED'
  WHEN all(r IN rows WHERE r.src.renditionCoverage = 'FULL' AND any(s IN r.snaps WHERE s.captureCompleteness = 'COMPLETE')) THEN 'NOT_FOUND_IN_COMPLETE_CAPTURE'
  ELSE 'NOT_FOUND_IN_PARTIAL_CAPTURE' END AS finding;

// ==== CH-M-13 UNDO ====
// CH-M-13 undo
MATCH (n) WHERE n.uid IN ['hu:source:chm13-pubmed-29184669', 'hu:snapshot:chm13-pubmed-29184669-2026-10-04'] DETACH DELETE n;


// ==== CH-M-14 APPLY ====
// CH-M-14 (1/3): rights UNKNOWN read as permission. A pathway diagram EXPLAINS the NAD mechanism (asserted edge with its
// Assertion), has the best display score (0.97, method-versioned) and one current rights record whose rightsStatus is
// absent (the check ran but the status was never set; Community cannot enforce the Enterprise existence constraint).
MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'}), (qa:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:chm14-nad-diagram-rights-unset'})
SET m.id = 'chm14-nad-diagram-rights-unset', m.artifactType = 'MEDIA_ASSET', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM', m.generationMode = 'UNKNOWN', m.privacyClass = 'PUBLIC'
MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:chm14-status-unset'})
SET r.id = 'chm14-status-unset', r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:554ff4b64b124302412a8854ff079a1b073b90629e041d5605298d34d128dd3a', r.statementKind = 'LICENSE_OFFER', r.statementScope = 'THIS_ASSET', r.privacyClass = 'PUBLIC'
MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:chm14-display-quality'})
SET a.id = 'chm14-display-quality', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T05:40:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.97, a.intendedRole = 'PATHWAY_DIAGRAM', a.privacyClass = 'PUBLIC'
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(qa);

// CH-M-14 (2/3): EXPLAINS as the projection of an Assertion (V-612 shape).
MATCH (m:MediaAsset {uid: 'hu:media-asset:chm14-nad-diagram-rights-unset'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}), (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
MERGE (x:Assertion {uid: 'hu:assertion:chm14-explains-nad'})
SET x.id = 'chm14-explains-nad', x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T05:41:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:chm14-explains-nad'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T05:41:00Z');

// CH-M-14 (3/3): HAS_RIGHTS_RECORD as the projection of an Assertion.
MATCH (m:MediaAsset {uid: 'hu:media-asset:chm14-nad-diagram-rights-unset'}), (r:MediaRightsRecord {uid: 'hu:media-rights:chm14-status-unset'})
MERGE (x:Assertion {uid: 'hu:assertion:chm14-rights'})
SET x.id = 'chm14-rights', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T05:42:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'OBSERVATION_ONLY', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:chm14-rights'}]->(r)
SET e.assertionUid = x.uid, e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T05:42:00Z');

// ==== CH-M-14 PROBE ====
// CH-M-14 probe: W22 Q-MP4-1 verbatim (rights-gated selection for the NAD mechanism).
MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'})<-[:EXPLAINS]-(m:MediaAsset)
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL AND hr.validTo IS NULL
WITH m, collect(r) AS recs
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED', intendedRole: 'PATHWAY_DIAGRAM'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) }
WITH m, recs, [x IN recs | x.rightsStatus] AS rights, q, ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS allowed
RETURN m.uid AS asset, q.overallScore AS displayScore, rights,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED'
       WHEN NOT all(x IN rights WHERE x IN allowed) THEN 'EXCLUDED_RIGHTS_NOT_PERMITTED'
       WHEN q IS NULL OR q.verdict <> 'SUITABLE' THEN 'EXCLUDED_NOT_SUITABLE'
       ELSE 'ELIGIBLE' END AS decision
ORDER BY decision, displayScore DESC;

// ==== CH-M-14 UNDO ====
// CH-M-14 undo
MATCH (n) WHERE n.uid IN ['hu:media-asset:chm14-nad-diagram-rights-unset', 'hu:media-rights:chm14-status-unset', 'hu:media-assessment:chm14-display-quality', 'hu:assertion:chm14-explains-nad', 'hu:assertion:chm14-rights']
DETACH DELETE n;


// ==== CH-M-15 APPLY ====
// CH-M-15 (1/3): an OPEN_LICENSE record that is CC BY-NC-ND 4.0 (commercialUseAllowed false, derivativesAllowed false) on a
// diagram whose RESIZED derivative is displayed in a BellLabs answer under policy media-display-v0 (DISPLAY_MEDIA).
MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}), (qa:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:chm15-nad-diagram-cc-by-nc-nd'})
SET m.id = 'chm15-nad-diagram-cc-by-nc-nd', m.artifactType = 'MEDIA_ASSET', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM', m.generationMode = 'RENDERED',
    m.contentHash = 'sha256:5cf6385f85a353510e417a26a06c1621f4f0451b0d51eef043b9a83231d1c63f', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC'
MERGE (o:MediaVariant:InformationArtifact {uid: 'hu:media-variant:chm15-original'})
SET o.id = 'chm15-original', o.artifactType = 'MEDIA_VARIANT', o.variantKind = 'ORIGINAL', o.contentHash = 'sha256:5cf6385f85a353510e417a26a06c1621f4f0451b0d51eef043b9a83231d1c63f', o.contentHashBasis = 'SYNTHETIC_FIXTURE', o.privacyClass = 'PUBLIC'
MERGE (rz:MediaVariant:InformationArtifact {uid: 'hu:media-variant:chm15-resized'})
SET rz.id = 'chm15-resized', rz.artifactType = 'MEDIA_VARIANT', rz.variantKind = 'RESIZED', rz.contentHash = 'sha256:22e15d6b3aae9142572ede9f695beeb3a1728a99684f8027f2fe53fe0f9f2cf9', rz.contentHashBasis = 'SYNTHETIC_FIXTURE', rz.privacyClass = 'PUBLIC'
MERGE (t:Activity:Occurrence {uid: 'hu:activity:chm15-resize'})
SET t.id = 'chm15-resize', t.occurrenceType = 'ACTIVITY', t.activityKind = 'MEDIA_TRANSFORMATION', t.methodVersion = 'bl-resize-v1', t.privacyClass = 'PUBLIC'
MERGE (m)-[:HAS_MEDIA_VARIANT]->(o) MERGE (m)-[:HAS_MEDIA_VARIANT]->(rz) MERGE (rz)-[:WAS_GENERATED_BY]->(t) MERGE (t)-[:USED]->(o)
MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:chm15-display-quality'})
SET a.id = 'chm15-display-quality', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T05:50:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.99, a.intendedRole = 'PATHWAY_DIAGRAM', a.privacyClass = 'PUBLIC'
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(qa);

// CH-M-15 (2/3): EXPLAINS and HAS_RIGHTS_RECORD with their Assertions; the licence forbids commercial use and derivatives.
MATCH (m:MediaAsset {uid: 'hu:media-asset:chm15-nad-diagram-cc-by-nc-nd'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'})
MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:chm15-cc-by-nc-nd-4'})
SET r.id = 'chm15-cc-by-nc-nd-4', r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:e7d55dc02c624aef269f09a6a216ef7e32d32b37cee3853a87916e1dd0629b89', r.rightsStatus = 'OPEN_LICENSE', r.statementKind = 'LICENSE_OFFER', r.statementScope = 'THIS_ASSET',
    r.licenseName = 'CC BY-NC-ND 4.0', r.licenseUri = 'https://creativecommons.org/licenses/by-nc-nd/4.0/', r.attributionRequired = true, r.commercialUseAllowed = false, r.derivativesAllowed = false,
    r.privacyClass = 'PUBLIC'
MERGE (x:Assertion {uid: 'hu:assertion:chm15-explains-nad'})
SET x.id = 'chm15-explains-nad', x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T05:51:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:chm15-explains-nad'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T05:51:00Z')
MERGE (y:Assertion {uid: 'hu:assertion:chm15-rights'})
SET y.id = 'chm15-rights', y.predicate = 'HAS_RIGHTS_RECORD', y.status = 'PROPOSED', y.recordedAt = datetime('2026-10-04T05:52:00Z'), y.predicateClass = 'OTHER', y.validFromBasis = 'OBSERVATION_ONLY', y.validToBasis = 'UNKNOWN', y.privacyClass = 'PUBLIC'
MERGE (y)-[:HAS_SUBJECT]->(m) MERGE (y)-[:HAS_OBJECT]->(r)
MERGE (m)-[h:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:chm15-rights'}]->(r)
SET h.assertionUid = y.uid, h.validFromBasis = 'OBSERVATION_ONLY', h.validToBasis = 'UNKNOWN', h.recordedFrom = datetime('2026-10-04T05:52:00Z');

// CH-M-15 (3/3): the display of the RESIZED derivative, authorized for DISPLAY_MEDIA.
MATCH (rz:MediaVariant {uid: 'hu:media-variant:chm15-resized'}), (p:PolicyVersion {uid: 'hu:policy-version:media-display-v0'})
MERGE (act:Activity:Occurrence {uid: 'hu:activity:chm15-display-in-answer'})
SET act.id = 'chm15-display-in-answer', act.occurrenceType = 'ACTIVITY', act.activityKind = 'ANSWER_COMPOSITION', act.startedAt = datetime('2026-10-04T05:55:00Z'), act.methodVersion = 'answer-composer-v0', act.privacyClass = 'PUBLIC'
MERGE (act)-[:USED]->(rz) MERGE (act)-[u:AUTHORIZED_BY]->(p) SET u.useKind = 'DISPLAY_MEDIA';

// ==== CH-M-15 PROBE ====
// CH-M-15 probe (a): W22 Q-MP4-1 verbatim (see CH-M-14 probe).
MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'})<-[:EXPLAINS]-(m:MediaAsset)
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL AND hr.validTo IS NULL
WITH m, collect(r) AS recs
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED', intendedRole: 'PATHWAY_DIAGRAM'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) }
WITH m, recs, [x IN recs | x.rightsStatus] AS rights, q, ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS allowed
RETURN m.uid AS asset, q.overallScore AS displayScore, rights,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED'
       WHEN NOT all(x IN rights WHERE x IN allowed) THEN 'EXCLUDED_RIGHTS_NOT_PERMITTED'
       WHEN q IS NULL OR q.verdict <> 'SUITABLE' THEN 'EXCLUDED_NOT_SUITABLE'
       ELSE 'ELIGIBLE' END AS decision
ORDER BY decision, displayScore DESC;

// CH-M-15 probe (b): W22 Q-MP4-3 state-5 classification of the display.
MATCH (a:Activity {activityKind: 'ANSWER_COMPOSITION'})-[:USED]->(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
WHERE a.uid = 'hu:activity:chm15-display-in-answer'
OPTIONAL MATCH (a)-[u:AUTHORIZED_BY]->(p:PolicyVersion)
OPTIONAL MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
WITH a, m, v, u, p, collect(r.rightsStatus) AS rights
RETURN a.uid AS activity, v.variantKind AS displayedRendition, rights,
  CASE WHEN u IS NULL THEN 'UNAUTHORIZED_USE'
       WHEN size(rights) = 0 OR NOT all(x IN rights WHERE x IN ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR']) THEN 'AUTHORIZED_WITHOUT_PERMITTING_RIGHTS_RECORD'
       ELSE 'OK' END AS state5;

// ==== CH-M-15 UNDO ====
// CH-M-15 undo
MATCH (n) WHERE n.uid IN ['hu:media-asset:chm15-nad-diagram-cc-by-nc-nd', 'hu:media-variant:chm15-original', 'hu:media-variant:chm15-resized', 'hu:activity:chm15-resize',
                          'hu:media-assessment:chm15-display-quality', 'hu:media-rights:chm15-cc-by-nc-nd-4', 'hu:assertion:chm15-explains-nad', 'hu:assertion:chm15-rights',
                          'hu:activity:chm15-display-in-answer']
DETACH DELETE n;


// ==== CH-M-16 APPLY ====
// CH-M-16: CL-003 R3 - one Source rendering two works: the YouTube video of episode 52 also declared RENDITION_OF the 2025
// "Essentials" re-edit (the fx01 identity collision).
MATCH (s:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (e:Episode {uid: 'hu:episode:huberman-lab-essentials-sinclair-2025-10-30'})
MERGE (s)-[:RENDITION_OF]->(e);

// ==== CH-M-16 PROBE ====
// CH-M-16 probe: W19 Q-03 verbatim (a query in the W19 packet, not a validator in any suite run here).
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, collect(w) AS works
WHERE size(works) > 1 OR any(w IN works WHERE w:Source OR NOT (w:Episode OR w:Publication))
RETURN s.uid AS badRendition, [w IN works | labels(w)] AS targetLabels;

// ==== CH-M-16 UNDO ====
// CH-M-16 undo
MATCH (:Source {uid: 'hu:source:youtube-n9IxomBusuw'})-[r:RENDITION_OF]->(:Episode {uid: 'hu:episode:huberman-lab-essentials-sinclair-2025-10-30'}) DELETE r;


// ==== CH-M-17 (no mutation) ====
// CH-M-17: observed on the baseline of the group load, no write needed. Kernel V-423 (replaced by V-W21-06 per CL-016) returns the
// valid fx07 projection hu:person:synthetic-podcast-guest -> hu:substance:synthetic-compound-x; W00 V-W00-02r returns the translated
// recommendation-snapshot edge hu:rel:synthetic-host-recommends-nightcue (ASSERTION_UID_ON_DERIVED_EDGE); V-W21-06 returns neither.
