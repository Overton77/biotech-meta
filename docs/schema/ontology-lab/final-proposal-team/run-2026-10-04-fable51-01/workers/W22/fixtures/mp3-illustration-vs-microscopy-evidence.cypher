// W22 fixture MP3: generated mechanism illustration (EXPLAINS) versus measured microscopy capture (EVIDENCES).
// CQ-MD-C05, CQ-PV-01, CQ-PV-02. A generated image cannot supply source support without an actual locator path to an
// original capture and an allowed use.
// Real record: EMBL-EBI BioImage Archive study S-BIAD807 'Images of the confocal microscopy' (BioStudies API, retrieved
// 2026-10-04 via Firecrawl; S07, S08): License CC0; imaging instrument Olympus FV3000; 100x oil objective; 488 nm and
// 561 nm lasers at 5% power; 512 x 512 line scanning; 341 files. Individual FILE NAMES and image BYTES were NOT
// retrieved: the image file Source uses a placeholder URN and every image hash is SYNTHETIC_FIXTURE.
// The assertion below records the study's stated observation CONTEXT (stimulation and imaging of mtDNA and TSG101), not
// a finding; its image-region support is synthetic. The generated illustration and the bad-ingestion members are SYNTHETIC.

MERGE (n:Mechanism:Entity {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'})
SET n.privacyClass = 'PUBLIC', n.name = 'Cytosolic leakage of mitochondrial DNA during pyroptosis', n.entityType = 'MECHANISM';

MERGE (n:MechanismEvidenceContext:Occurrence {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'MECHANISM_EVIDENCE_CONTEXT', n.setting = 'IN_VITRO_CELL', n.modelDescriptor = 'PMA-treated THP-1 cells (WT, Casp1-KO, GsdmD-KO), TSG101-mCherry; LPS 500 ng/ml plus ATP 10 mM', n.exposureStatus = 'NOT_EXTRACTED';

MERGE (n:Species:Entity {uid: 'hu:species:homo-sapiens'})
SET n.privacyClass = 'PUBLIC', n.name = 'Homo sapiens', n.entityType = 'SPECIES', n.scientificName = 'Homo sapiens', n.taxonomyId = '9606';

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:lipopolysaccharide'})
SET n.privacyClass = 'PUBLIC', n.name = 'Lipopolysaccharide', n.entityType = 'CHEMICAL_SUBSTANCE';

MATCH (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}), (sp:Species {uid: 'hu:species:homo-sapiens'}), (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'})
MERGE (c)-[:IN_SPECIES]->(sp) MERGE (c)-[:EXPOSED_TO]->(s);

MERGE (n:Organization:Entity {uid: 'hu:org:embl-ebi'})
SET n.privacyClass = 'PUBLIC', n.name = 'EMBL-EBI (BioImage Archive)', n.entityType = 'ORGANIZATION';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w22-curator'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs W22 media curator', n.entityType = 'AGENT', n.agentKind = 'MANUAL_AGENT';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-image-generator-synthetic'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs illustration generator (synthetic fixture)', n.entityType = 'AGENT', n.agentKind = 'COMPUTATIONAL_MODEL', n.model = 'unspecified-image-model', n.promptVersion = 'explainer-prompt-v0';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-capture-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-04T00:48:00Z'), n.endedAt = datetime('2026-10-04T01:10:00Z'), n.methodVersion = 'w22-firecrawl-scrape-2026-10-04';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-curation-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-04T01:10:00Z'), n.endedAt = datetime('2026-10-04T02:00:00Z'), n.methodVersion = 'w22-manual-media-curation-v0.1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-generate-mtdna-illustration-synthetic'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_GENERATION', n.startedAt = datetime('2026-10-04T02:40:00Z'), n.endedAt = datetime('2026-10-04T02:41:00Z'), n.methodVersion = 'explainer-prompt-v0';

MATCH (a:Activity {uid: 'hu:activity:w22-generate-mtdna-illustration-synthetic'}), (g:Agent {uid: 'hu:agent:belllabs-image-generator-synthetic'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Repository study record (real retrieval) and the image file (placeholder, synthetic bytes).
MERGE (n:Source:Entity {uid: 'hu:source:bia-s-biad807-study-record'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://www.ebi.ac.uk/biostudies/api/v1/studies/S-BIAD807', n.title = 'Images of the confocal microscopy (S-BIAD807)', n.sourceKind = 'DATA_REPOSITORY_RECORD';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:bia-s-biad807-study-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://www.ebi.ac.uk/biostudies/api/v1/studies/S-BIAD807', n.retrievedAt = datetime('2026-10-04T00:52:00Z'), n.observedAt = datetime('2026-10-04T00:52:00Z'),
    n.publishedAt = datetime('2023-08-31T00:00:00Z'), n.publishedAtPrecision = 'DAY', n.contentHash = 'sha256:e17a9d439de32bbbe2bca1fb58a479af2600d54d84d4827c64c10818f9b8e1ee', n.contentHashBasis = 'SYNTHETIC_FIXTURE',
    n.captureCompleteness = 'COMPLETE', n.mimeType = 'application/json';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bia-s-biad807-stimulation-protocol'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = 'To analyze the co-localization of cytosolic leakage of mtDNA and TSG101, cells were stimulated with 500 ng/ml LPS plus 10 mM ATP to induce pyroptosis.',
    n.quoteHash = 'sha256:c837f9b3a9c75a84ce470039587fc7f702d1a8efd67b749201d5b0962bebf665';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bia-s-biad807-acquisition-parameters'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = 'Using a 10x magnification setting on the Olympus FV3000, a 100x oil-objective lens was used. The 488 nm laser was used to image nuclei and mtDNA (PicoGreen), and the 561 nm laser was used to image the ILV formation (Tsg101-mCherry), both at 5% laser power. The images were obtained with line scanning of 512 x 512 pixels.',
    n.quoteHash = 'sha256:bdcf3a6bbcb26b90ade5653c9885a091b8ce710908e322584e4f7bfd953a6586';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bia-s-biad807-license'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.prefix = '"name" : "License", "value" : "', n.exact = 'CC0', n.quoteHash = 'sha256:cd754a95896760f420a2eacb8508e6dfc8f7764c6f280e84365a7076218b3944';

MATCH (s:Source {uid: 'hu:source:bia-s-biad807-study-record'}), (ss:SourceSnapshot {uid: 'hu:snapshot:bia-s-biad807-study-2026-10-04'}),
      (l1:SourceLocator {uid: 'hu:locator:bia-s-biad807-stimulation-protocol'}), (l2:SourceLocator {uid: 'hu:locator:bia-s-biad807-acquisition-parameters'}), (l3:SourceLocator {uid: 'hu:locator:bia-s-biad807-license'}),
      (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l1) MERGE (ss)-[:HAS_LOCATOR]->(l2) MERGE (ss)-[:HAS_LOCATOR]->(l3) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MERGE (n:Source:Entity {uid: 'hu:source:bia-s-biad807-confocal-file-placeholder'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'urn:w22-fixture:s-biad807-confocal-file-name-not-retrieved', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:bia-s-biad807-confocal-file-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'urn:w22-fixture:s-biad807-confocal-file-name-not-retrieved', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'image/tiff';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bia-s-biad807-confocal-file-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bia-s-biad807-confocal-region-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'IMAGE_REGION', n.mediaAnnotationUid = 'hu:media-annotation:bia-s-biad807-confocal-cell-region-synthetic', n.normalizationVersion = 'IMG-PX1';

MATCH (s:Source {uid: 'hu:source:bia-s-biad807-confocal-file-placeholder'}), (ss:SourceSnapshot {uid: 'hu:snapshot:bia-s-biad807-confocal-file-synthetic'}),
      (l1:SourceLocator {uid: 'hu:locator:bia-s-biad807-confocal-file-whole'}), (l2:SourceLocator {uid: 'hu:locator:bia-s-biad807-confocal-region-synthetic'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l1) MERGE (ss)-[:HAS_LOCATOR]->(l2);

// ---- E1: microscopy capture asset (CAPTURED by the study authors' instrument; CC0 per the study record).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'S-BIAD807 confocal image (file not retrieved; synthetic bytes)', m.assetType = 'MICROSCOPY_IMAGE', m.mediaPurpose = 'SCIENTIFIC_FIGURE',
    m.generationMode = 'CAPTURED', m.isSynthetic = false, m.canonicalUrl = 'https://www.ebi.ac.uk/biostudies/BioImages/studies/S-BIAD807', m.publishedAt = datetime('2023-08-31T00:00:00Z'), m.publishedAtPrecision = 'DAY',
    m.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:bia-s-biad807-confocal-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mimeType = 'image/tiff', v.widthPx = 512, v.heightPx = 512,
    v.contentHash = 'sha256:3d718f7f1dfb611eef71b57886f27ae34cf19f0095a772dfe9579719c7796b7b', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:bia-s-biad807-confocal-cell-region-synthetic'})
SET ann.privacyClass = 'PUBLIC', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 120.0, ann.y = 88.0, ann.width = 160.0, ann.height = 140.0,
    ann.label = 'cell with PicoGreen and TSG101-mCherry signal (synthetic region)';

MATCH (m:MediaAsset {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'}), (v:MediaVariant {uid: 'hu:media-variant:bia-s-biad807-confocal-original'}),
      (ann:MediaAnnotation {uid: 'hu:media-annotation:bia-s-biad807-confocal-cell-region-synthetic'}), (lw:SourceLocator {uid: 'hu:locator:bia-s-biad807-confocal-file-whole'}),
      (lr:SourceLocator {uid: 'hu:locator:bia-s-biad807-confocal-region-synthetic'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (v)-[:HAS_ANNOTATION]->(ann)
MERGE (lr)-[:LOCATES_REGION]->(ann)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'MICROSCOPE_CAPTURE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'S-BIAD807 Study Component-4 FileList/Confocal.json (file not retrieved)'}]->(lw)
MERGE (v)-[:WAS_GENERATED_BY]->(cap) MERGE (m)-[:WAS_GENERATED_BY]->(cap) MERGE (ann)-[:WAS_GENERATED_BY]->(cur);

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:bia-s-biad807-cc0'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:942bbd6f9e0a3395fd1bf9023913545b5ec8b6bc3a5d3d1bd1bcb3eecec39004', r.rightsStatus = 'PUBLIC_DOMAIN', r.statementKind = 'REPOSITORY_METADATA', r.statementScope = 'DATASET_RECORD',
    r.licenseName = 'CC0', r.licenseUri = 'https://creativecommons.org/publicdomain/zero/1.0/legalcode', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (x:Assertion {uid: 'hu:assertion:w22-e1-rights-cc0'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:40:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2023-08-31T00:00:00Z'), x.validFromPrecision = 'DAY', x.validFromBasis = 'PUBLICATION_PROXY', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-e1-rights-cc0'}), (m:MediaAsset {uid: 'hu:media-asset:bia-s-biad807-confocal-image-synthetic-file'}), (r:MediaRightsRecord {uid: 'hu:media-rights:bia-s-biad807-cc0'}),
      (o:Organization {uid: 'hu:org:embl-ebi'}), (l:SourceLocator {uid: 'hu:locator:bia-s-biad807-license'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-e1-rights-cc0'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2023-08-31T00:00:00Z'), e.validFromPrecision = 'DAY', e.validFromBasis = 'PUBLICATION_PROXY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:40:00Z');

// ---- The evidence assertion (SYNTHETIC content in kernel shape): LPS (with ATP) INDUCES_PROCESS the mechanism, measured in
// ---- the stated context, supported by the protocol quote AND the image region of the ORIGINAL capture. The retrieved record
// ---- states the design ('to induce pyroptosis'), not a result; status PROPOSED (no capture-fidelity adjudication).
MERGE (x:Assertion {uid: 'hu:assertion:w22-mtdna-release-observed-in-s-biad807-context'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T01:45:00Z'), x.predicateClass = 'MECHANISM', x.basisKind = 'DIRECT_MEASUREMENT', x.polarity = 'POSITIVE',
    x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-mtdna-release-observed-in-s-biad807-context'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}), (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}),
      (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (l1:SourceLocator {uid: 'hu:locator:bia-s-biad807-stimulation-protocol'}), (l2:SourceLocator {uid: 'hu:locator:bia-s-biad807-confocal-region-synthetic'}),
      (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l1) MERGE (x)-[:SUPPORTED_BY]->(l2) MERGE (x)-[:WAS_GENERATED_BY]->(cur);

// ---- G1: SYNTHETIC generated illustration of the mechanism. Lineage: generated FROM our assertion (USED), so it can
// ---- explain but never support it.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:belllabs-generated-mtdna-pyroptosis-illustration-synthetic'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Generated illustration: mtDNA leakage during pyroptosis (synthetic fixture)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'EXPLANATION',
    m.generationMode = 'GENERATED', m.isSynthetic = true, m.editDisclosureText = 'AI-generated illustration; not a microscopy image.', m.contentHash = 'sha256:ba104868674e97ac93a6d0face52e6fedc7b59644fe3256ac28c264cccb898a7', m.contentHashBasis = 'SYNTHETIC_FIXTURE',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:belllabs-generated-mtdna-illustration-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'PNG', v.mimeType = 'image/png', v.widthPx = 2048, v.heightPx = 1536,
    v.contentHash = 'sha256:ba104868674e97ac93a6d0face52e6fedc7b59644fe3256ac28c264cccb898a7', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtdna-pyroptosis-illustration-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-generated-mtdna-illustration-original'}),
      (gen:Activity {uid: 'hu:activity:w22-generate-mtdna-illustration-synthetic'}), (x:Assertion {uid: 'hu:assertion:w22-mtdna-release-observed-in-s-biad807-context'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v) MERGE (v)-[:WAS_GENERATED_BY]->(gen) MERGE (m)-[:WAS_GENERATED_BY]->(gen) MERGE (gen)-[:USED]->(x);

MERGE (x:Assertion {uid: 'hu:assertion:w22-g1-explains-mtdna-release'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T02:42:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-g1-explains-mtdna-release'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtdna-pyroptosis-illustration-synthetic'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-g1-explains-mtdna-release'}]->(k)
SET e.assertionUid = x.uid, e.role = 'MECHANISM_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:42:00Z');

// ---- NEGATIVE members (bad ingestion, expected to be flagged): (n1) the generated illustration stored as if it were a
// ---- source capture and cited through an IMAGE_REGION locator; (n2) a hand-written EVIDENCES edge from the illustration.
MERGE (n:Source:Entity {uid: 'hu:source:bad-generated-illustration-as-source'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'urn:belllabs:media-store:mtdna-illustration-v0', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:bad-generated-illustration-as-source'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'urn:belllabs:media-store:mtdna-illustration-v0', n.retrievedAt = datetime('2026-10-04T02:45:00Z'),
    n.contentHash = 'sha256:ba104868674e97ac93a6d0face52e6fedc7b59644fe3256ac28c264cccb898a7', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE';

MERGE (ann:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:bad-generated-illustration-region'})
SET ann.privacyClass = 'PUBLIC', ann.artifactType = 'MEDIA_ANNOTATION', ann.annotationType = 'BOUNDING_BOX', ann.normalizationVersion = 'IMG-PX1', ann.x = 400.0, ann.y = 300.0, ann.width = 600.0, ann.height = 500.0;

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bad-generated-illustration-region'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'IMAGE_REGION', n.mediaAnnotationUid = 'hu:media-annotation:bad-generated-illustration-region', n.normalizationVersion = 'IMG-PX1';

MATCH (s:Source {uid: 'hu:source:bad-generated-illustration-as-source'}), (ss:SourceSnapshot {uid: 'hu:snapshot:bad-generated-illustration-as-source'}), (l:SourceLocator {uid: 'hu:locator:bad-generated-illustration-region'}),
      (ann:MediaAnnotation {uid: 'hu:media-annotation:bad-generated-illustration-region'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-generated-mtdna-illustration-original'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (v)-[:HAS_ANNOTATION]->(ann) MERGE (l)-[:LOCATES_REGION]->(ann);

MERGE (x:Assertion {uid: 'hu:assertion:bad-mtdna-release-supported-by-generated-image'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'INDUCES_PROCESS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T02:46:00Z'), x.predicateClass = 'MECHANISM', x.basisKind = 'DIRECT_MEASUREMENT';

MATCH (x:Assertion {uid: 'hu:assertion:bad-mtdna-release-supported-by-generated-image'}), (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'}), (c:MechanismEvidenceContext {uid: 'hu:mech-context:s-biad807-thp1-lps-atp-confocal'}),
      (s:ChemicalSubstance {uid: 'hu:substance:lipopolysaccharide'}), (l:SourceLocator {uid: 'hu:locator:bad-generated-illustration-region'})
MERGE (x)-[:HAS_SUBJECT]->(s) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:OBSERVED_IN_CONTEXT]->(c) MERGE (x)-[:SUPPORTED_BY]->(l);

MATCH (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtdna-pyroptosis-illustration-synthetic'}), (x:Assertion {uid: 'hu:assertion:w22-mtdna-release-observed-in-s-biad807-context'})
MERGE (m)-[e:EVIDENCES]->(x)
SET e.notes = 'bad ingestion: hand-written EVIDENCES without derivation rule';

// ---- Derivation job MEDIA-EV-1 (regenerable): EVIDENCES from the asset whose ORIGINAL variant carries the region
// ---- annotation located by an IMAGE_REGION locator that supports an assertion, only when the variant bytes equal the
// ---- locator's snapshot bytes and the asset is not GENERATED. Writes one edge per (asset, assertion).
MATCH (x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
WHERE l.mediaAnnotationUid = ann.uid AND v.contentHash = ss.contentHash AND coalesce(m.generationMode, 'UNKNOWN') <> 'GENERATED'
WITH m, x, collect(DISTINCT x.uid) AS fromAssertions
MERGE (m)-[e:EVIDENCES {derivationRule: 'MEDIA-EV-1'}]->(x)
SET e.derivedFromAssertionUids = fromAssertions, e.derivedAt = datetime('2026-10-04T03:00:00Z')
RETURN m.uid AS evidencingAsset, x.uid AS evidencedAssertion;

// ---- Capture-fidelity adjudications for this fixture's ACCEPTED assertions (kernel V-110; synthetic review record:
// ---- 'the record accurately captures what the asserter stated in the cited span', never a truth verdict).
MATCH (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
UNWIND ['hu:assertion:w22-e1-rights-cc0'] AS u
MATCH (a:Assertion {uid: u})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w22-cf-' + substring(u, 13)})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'w22-capture-fidelity-review-v0', j.status = 'ACCEPTED', j.adjudicationKind = 'CAPTURE_FIDELITY',
    j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = a.recordedAt + duration('PT1M'), j.recordedAt = a.recordedAt + duration('PT1M'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a) MERGE (j)-[:ASSESSED_BY]->(g);

// =====================================================================================================================
// Queries
// =====================================================================================================================

// Q-MP3-1 (CQ-MD-C05, CQ-PV-01): images that EVIDENCE assertions about the mechanism, with the full locator path, the
// capture, the rights and the verdict on the path. The generated illustration appears only as REJECTED.
MATCH (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'})<-[:HAS_OBJECT]-(x:Assertion)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})
MATCH (l)-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
OPTIONAL MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
RETURN x.uid AS assertion, m.uid AS asset, m.generationMode AS generationMode, v.variantKind AS variantKind, ss.uid AS snapshot, v.contentHash = ss.contentHash AS sameBytes,
       collect(r.rightsStatus) AS rights,
       CASE WHEN m.generationMode = 'GENERATED' THEN 'REJECTED_GENERATED_ASSET'
            WHEN v.variantKind <> 'ORIGINAL' THEN 'REJECTED_DERIVED_RENDITION'
            WHEN v.contentHash <> ss.contentHash THEN 'REJECTED_BYTES_MISMATCH'
            ELSE 'EVIDENCE_PATH_OK' END AS verdict
ORDER BY verdict, assertion;

// Q-MP3-2 (CQ-MD-C02): explanatory assets of the mechanism; the microscopy capture is not among them.
MATCH (k:Mechanism {uid: 'hu:mechanism:mtdna-cytosolic-release-in-pyroptosis'})<-[e:EXPLAINS]-(m:MediaAsset)
RETURN m.uid AS explanatoryAsset, m.generationMode AS generationMode, m.isSynthetic AS isSynthetic, e.role AS role;

// Q-MP3-3 (CQ-MD-C05): derived EVIDENCES edges and whether each is properly derived. Expected 2 rows: E1 derived
// (MEDIA-EV-1) and the bad hand-written edge from G1 (derivationRule null) - the latter is a V-604/V-605 violation.
MATCH (m:MediaAsset)-[e:EVIDENCES]->(x)
RETURN m.uid AS asset, x.uid AS evidenced, e.derivationRule AS rule, m.generationMode AS generationMode
ORDER BY asset;
