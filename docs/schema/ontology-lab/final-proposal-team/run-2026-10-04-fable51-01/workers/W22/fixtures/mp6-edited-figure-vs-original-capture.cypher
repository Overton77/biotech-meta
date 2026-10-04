// W22 fixture MP6: an edited scientific figure versus the original capture.
// (a) BellLabs-edited rendition (ANNOTATED variant with callouts) of the S-BIAD807 confocal capture: lineage through a
//     MEDIA_TRANSFORMATION Activity that USED the ORIGINAL; it may be displayed (CC0) but never backs an evidence locator.
// (b) A publisher figure that is itself an edited composite: Mills et al. 2016 Figure 6 (panel 6A 'Representative fundus
//     biomicroscopy photos'), isEdited true from the legend; the raw captures are not public, so its lineage Activity is
//     unknown and evidence citations bind to the PUBLISHED figure bytes, labelled as a composite, never as a raw capture.
// CQ-MD-C04, CQ-MD-C05, CQ-PV-03.
// Real records: S-BIAD807 study record (S07); PMC5668137 figure legends (S05: Figure 6 title and panel A legend);
// PubMed copyright metadata for PMID 28068222 (S04: 'Copyright (c) 2016 Elsevier Inc. All rights reserved.').
// Image bytes NOT retrieved: hashes SYNTHETIC_FIXTURE. The callout edit and the negative locator are SYNTHETIC.
// MERGEs the MP3 capture nodes it needs, so it runs alone or after MP3.

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w22-curator'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs W22 media curator', n.entityType = 'AGENT', n.agentKind = 'MANUAL_AGENT';

MERGE (n:Organization:Entity {uid: 'hu:org:elsevier'})
SET n.privacyClass = 'PUBLIC', n.name = 'Elsevier', n.entityType = 'ORGANIZATION';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-capture-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-04T00:48:00Z'), n.endedAt = datetime('2026-10-04T01:10:00Z'), n.methodVersion = 'w22-firecrawl-scrape-2026-10-04';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-curation-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-04T01:10:00Z'), n.endedAt = datetime('2026-10-04T02:00:00Z'), n.methodVersion = 'w22-manual-media-curation-v0.1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-annotate-s-biad807-callouts-synthetic'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_TRANSFORMATION', n.startedAt = datetime('2026-10-04T03:20:00Z'), n.endedAt = datetime('2026-10-04T03:25:00Z'), n.methodVersion = 'bl-callout-overlay-v1';

MATCH (a:Activity {uid: 'hu:activity:w22-annotate-s-biad807-callouts-synthetic'}), (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- (a) original capture (same nodes as MP3) and the BellLabs-edited rendition.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.assetType = 'MICROSCOPY_IMAGE', m.generationMode = 'CAPTURED', m.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', m.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:bia-s-biad807-confocal-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.widthPx = 512, v.heightPx = 512, v.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (n:Source:Entity {uid: 'hu:source:bia-s-biad807-confocal-file-placeholder'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'urn:w22-fixture:s-biad807-confocal-file-name-not-retrieved', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:bia-s-biad807-confocal-file-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.retrievedAt = datetime('2026-10-04T01:05:00Z'), n.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'}), (v:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-original'}),
      (s:Source {uid: 'hu:source:bia-s-biad807-confocal-file-placeholder'}), (ss:SourceSnapshot {uid: 'hu:snapshot:bia-s-biad807-confocal-file-synthetic'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v) MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (v)-[:WAS_GENERATED_BY]->(cap);

MERGE (e:MediaVariant:InformationArtifact {uid: 'hu:media-variant:bia-s-biad807-confocal-callouts-synthetic'})
SET e.privacyClass = 'PUBLIC', e.artifactType = 'MEDIA_VARIANT', e.variantKind = 'ANNOTATED', e.mediaFormat = 'PNG', e.mimeType = 'image/png', e.widthPx = 1024, e.heightPx = 1024,
    e.storageUri = 'urn:belllabs:media-store:s-biad807-callouts', e.contentHash = 'sha256:faac0422e3dd456c9cd56bb560fd2a7ca2ff9ca3d857a01e47c393918a08a4a2', e.contentHashBasis = 'SYNTHETIC_FIXTURE',
    e.description = 'Upscaled 2x, arrows and labels added; modifications disclosed in the caption shown with it.';

MATCH (m:MediaAsset {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'}), (e:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-callouts-synthetic'}),
      (v:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-original'}), (act:Activity {uid: 'hu:activity:w22-annotate-s-biad807-callouts-synthetic'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(e) MERGE (e)-[:WAS_GENERATED_BY]->(act) MERGE (act)-[:USED]->(v);

// NEGATIVE (n1): an IMAGE_REGION locator drawn on the EDITED rendition and used as support (V-606; also V-602 because the
// edited bytes are not the captured bytes).
MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:bad-region-on-edited-callouts'})
SET ann.privacyClass = 'PUBLIC', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 240.0, ann.y = 176.0, ann.width = 320.0, ann.height = 280.0;

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bad-region-on-edited-callouts'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'IMAGE_REGION', n.mediaAnnotationUid = 'hu:media-annotation:bad-region-on-edited-callouts', n.normalizationVersion = 'IMG-PX1';

MATCH (e:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-callouts-synthetic'}), (ann:MediaAnnotation {uid: 'hu:media-annotation:bad-region-on-edited-callouts'}),
      (ss:SourceSnapshot {uid: 'hu:snapshot:bia-s-biad807-confocal-file-synthetic'}), (l:SourceLocator {uid: 'hu:locator:bad-region-on-edited-callouts'})
MERGE (e)-[:HAS_ANNOTATION]->(ann) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (l)-[:LOCATES_REGION]->(ann);

MERGE (x:Assertion {uid: 'hu:assertion:bad-claim-cited-on-edited-rendition'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T03:30:00Z'), x.predicateClass = 'MECHANISM', x.basisKind = 'DIRECT_MEASUREMENT';

MERGE (k:Mechanism:Entity {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'})
SET k.privacyClass = 'PUBLIC', k.entityType = 'MECHANISM';

MERGE (s:ChemicalSubstance:Entity {uid: 'hu:substance:lipopolysaccharide'})
SET s.privacyClass = 'PUBLIC', s.entityType = 'CHEMICAL_SUBSTANCE';

MERGE (c:MechanismEvidenceContext:Occurrence {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
SET c.privacyClass = 'PUBLIC', c.occurrenceType = 'MECHANISM_EVIDENCE_CONTEXT', c.setting = 'IN_VITRO_CELL', c.exposureStatus = 'NOT_EXTRACTED';

MERGE (sp:Species:Entity {uid: 'hu:species:homo-sapiens'})
SET sp.privacyClass = 'PUBLIC', sp.entityType = 'SPECIES', sp.scientificName = 'Homo sapiens';

MATCH (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}), (sp:Species {uid: 'hu:species:homo-sapiens'})
MERGE (c)-[:IN_SPECIES]->(sp);

MATCH (x:Assertion {uid: 'hu:assertion:bad-claim-cited-on-edited-rendition'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}), (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}),
      (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}), (l:SourceLocator {uid: 'hu:locator:bad-region-on-edited-callouts'})
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l);

// ---- (b) the publisher's composite figure (Mills et al. 2016, Figure 6), panel 6A.
MERGE (n:Source:Entity {uid: 'hu:source:pmc-pmc5668137'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5668137/', n.title = 'Long-term administration of nicotinamide mononucleotide mitigates age-associated physiological decline in mice - PMC', n.sourceKind = 'PEER_REVIEWED_PUBLICATION';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc-pmc5668137-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5668137/', n.retrievedAt = datetime('2026-10-04T00:57:00Z'), n.observedAt = datetime('2026-10-04T00:57:00Z'),
    n.contentHash = 'sha256:6a2da437300fbcac7dedbb96a7d7d704da64dd97595446810b99daafde6a11d4', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.mimeType = 'text/html';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc5668137-figure-6a-legend'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = '(A) Representative fundus biomicroscopy photos from control, 100 and 300 mg/kg/day NMN-administered mice (n=5 per group).',
    n.quoteHash = 'sha256:c22d1fccb6e1e3726be45929c9674345a2436e35edb76d99d12b2257e2ae5ada';

MERGE (n:Source:Entity {uid: 'hu:source:pmc-cdn-pmc5668137-f6-jpg'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/6eef/5668137/8c99b511b015/nihms914373f6.jpg', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc-cdn-pmc5668137-f6-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/6eef/5668137/8c99b511b015/nihms914373f6.jpg', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:140a595f048051cc0b729f238affec2242907fdbc308d99a0985473cc28026a5', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/jpeg';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc-cdn-pmc5668137-f6-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (s:Source {uid: 'hu:source:pmc-pmc5668137'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pmc-pmc5668137-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pmc5668137-figure-6a-legend'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:pmc-cdn-pmc5668137-f6-jpg'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pmc-cdn-pmc5668137-f6-synthetic'}), (l:SourceLocator {uid: 'hu:locator:pmc-cdn-pmc5668137-f6-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:mills-2016-figure-6'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Mills et al. 2016, Figure 6 (PMC author manuscript)', m.assetType = 'DOCUMENT_FIGURE', m.mediaPurpose = 'SCIENTIFIC_FIGURE', m.generationMode = 'EXTRACTED',
    m.title = 'Figure 6. Long-term NMN administration significantly improves eye function, tear production, and bone mineral density in aged C57BL/6N mice.',
    m.isEdited = true, m.editDisclosureText = '(A) Representative fundus biomicroscopy photos from control, 100 and 300 mg/kg/day NMN-administered mice (n=5 per group).',
    m.publishedAt = datetime('2016-10-27T00:00:00Z'), m.publishedAtPrecision = 'DAY', m.canonicalUrl = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5668137/figure/F6/',
    m.contentHash = 'sha256:140a595f048051cc0b729f238affec2242907fdbc308d99a0985473cc28026a5', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:mills-2016-figure-6-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.url = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/6eef/5668137/8c99b511b015/nihms914373f6.jpg',
    v.contentHash = 'sha256:140a595f048051cc0b729f238affec2242907fdbc308d99a0985473cc28026a5', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (fp:FigurePanel:InformationArtifact {uid: 'hu:figure-panel:mills-2016-figure-6a'})
SET fp.privacyClass = 'PUBLIC', fp.artifactType = 'FIGURE_PANEL', fp.figureNumber = '6', fp.panelLabel = 'A', fp.captionText = '(A) Representative fundus biomicroscopy photos from control, 100 and 300 mg/kg/day NMN-administered mice (n=5 per group).';

MATCH (m:MediaAsset {uid: 'hu:media-asset:mills-2016-figure-6'}), (v:MediaVariant {uid: 'hu:media-variant:mills-2016-figure-6-original'}), (fp:FigurePanel {uid: 'hu:figure-panel:mills-2016-figure-6a'}),
      (lw:SourceLocator {uid: 'hu:locator:pmc-cdn-pmc5668137-f6-whole'}), (lt:SourceLocator {uid: 'hu:locator:pmc5668137-figure-6a-legend'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (fp)-[:PART_OF_MEDIA {orderIndex: 1}]->(m)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'STUDY_FIGURE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'PMC figure blob for Figure 6'}]->(lw)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'DOCUMENT_FIGURE', captureRelation: 'EXTRACTED_FROM_REGION', contextText: 'Figure 6 legend, panel A'}]->(lt)
MERGE (v)-[:WAS_GENERATED_BY]->(cap) MERGE (m)-[:WAS_GENERATED_BY]->(cap);

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:elsevier-2016-all-rights-reserved-28068222'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:2fb6a4635cd6724e2d1d1effe0d3425c23151d57181293363db612763d8d411b', r.rightsStatus = 'ALL_RIGHTS_RESERVED', r.statementKind = 'COPYRIGHT_NOTICE', r.statementScope = 'CONTAINING_WORK',
    r.rightsHolderText = 'Elsevier Inc', r.restrictionsText = 'Copyright © 2016 Elsevier Inc. All rights reserved.', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (n:Source:Entity {uid: 'hu:source:pubmed-28068222'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/28068222/', n.sourceKind = 'PEER_REVIEWED_PUBLICATION';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-28068222-copyright-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/28068222/', n.retrievedAt = datetime('2026-10-04T00:56:00Z'), n.observedAt = datetime('2026-10-04T00:56:00Z'),
    n.contentHash = 'sha256:3a3fd6b9cc2e73bee48b86b2808937d964c6ca03610e4a74fd71cff7126edaf5', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pubmed-28068222-copyright-statement'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.exact = 'Copyright © 2016 Elsevier Inc. All rights reserved.', n.quoteHash = 'sha256:5abccf1716453c4899448880f990a4c087132c330ab7684e081ef298336b3a76';

MATCH (s:Source {uid: 'hu:source:pubmed-28068222'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pubmed-28068222-copyright-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pubmed-28068222-copyright-statement'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MERGE (x:Assertion {uid: 'hu:assertion:w22-mills-f6-rights-elsevier'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:58:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2016-01-01T00:00:00Z'), x.validFromPrecision = 'YEAR', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-mills-f6-rights-elsevier'}), (m:MediaAsset {uid: 'hu:media-asset:mills-2016-figure-6'}), (r:MediaRightsRecord {uid: 'hu:media-rights:elsevier-2016-all-rights-reserved-28068222'}),
      (o:Organization {uid: 'hu:org:elsevier'}), (l:SourceLocator {uid: 'hu:locator:pubmed-28068222-copyright-statement'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-mills-f6-rights-elsevier'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2016-01-01T00:00:00Z'), e.validFromPrecision = 'YEAR', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:58:00Z');

// ---- Capture-fidelity adjudications for this fixture's ACCEPTED assertions (kernel V-110; synthetic review record:
// ---- 'the record accurately captures what the asserter stated in the cited span', never a truth verdict).
MATCH (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
UNWIND ['hu:assertion:w22-mills-f6-rights-elsevier'] AS u
MATCH (a:Assertion {uid: u})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w22-cf-' + substring(u, 13)})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'w22-capture-fidelity-review-v0', j.status = 'ACCEPTED', j.adjudicationKind = 'CAPTURE_FIDELITY',
    j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = a.recordedAt + duration('PT1M'), j.recordedAt = a.recordedAt + duration('PT1M'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a) MERGE (j)-[:ASSESSED_BY]->(g);

// =====================================================================================================================
// Queries
// =====================================================================================================================

// Q-MP6-1 (CQ-MD-C04, CQ-PV-03): lineage of the edited rendition back to the original capture. Expected 1 row.
MATCH (e:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-callouts-synthetic'})-[:WAS_GENERATED_BY]->(act:Activity)-[:USED]->(o:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
OPTIONAL MATCH (ss:SourceSnapshot {contentHash: o.contentHash})
RETURN e.uid AS edited, e.variantKind AS kind, act.activityKind AS activityKind, act.methodVersion AS method, o.uid AS original, m.generationMode AS originalMode, ss.uid AS captureWithSameBytes;

// Q-MP6-2 (CQ-MD-C05): which renditions may back an evidence locator, per asset. Expected: S-BIAD807 ORIGINAL ->
// RAW_CAPTURE_OK; S-BIAD807 ANNOTATED -> NOT_FOR_EVIDENCE_EDITED_RENDITION; Mills Figure 6 ORIGINAL ->
// PUBLISHED_COMPOSITE_CITE_AS_FIGURE (isEdited true; raw captures unavailable).
MATCH (m:MediaAsset)-[:HAS_MEDIA_VARIANT]->(v:MediaVariant)
WHERE m.uid IN ['hu:media-asset:bia-s-biad807-confocal-image-synthetic-file', 'hu:media-asset:mills-2016-figure-6']
OPTIONAL MATCH (ss:SourceSnapshot {contentHash: v.contentHash})
RETURN m.uid AS asset, v.uid AS rendition, v.variantKind AS kind, ss IS NOT NULL AS bytesEqualACapture, m.isEdited AS assetIsEdited,
  CASE WHEN v.variantKind <> 'ORIGINAL' THEN 'NOT_FOR_EVIDENCE_EDITED_RENDITION'
       WHEN ss IS NULL THEN 'NOT_FOR_EVIDENCE_NO_CAPTURE'
       WHEN m.isEdited THEN 'PUBLISHED_COMPOSITE_CITE_AS_FIGURE'
       ELSE 'RAW_CAPTURE_OK' END AS evidenceUse
ORDER BY asset, kind;

// Q-MP6-3 (CQ-MD-C04): edited assets with neither a lineage Activity nor a disclosure. Expected 0 rows in this fixture
// (Mills Figure 6 carries its legend as disclosure; the callout variant has its Activity).
MATCH (m:MediaAsset {isEdited: true})
WHERE m.editDisclosureText IS NULL AND NOT EXISTS { MATCH (m)-[:WAS_GENERATED_BY]->(:Activity) }
RETURN m.uid AS editedWithoutLineageOrDisclosure;
