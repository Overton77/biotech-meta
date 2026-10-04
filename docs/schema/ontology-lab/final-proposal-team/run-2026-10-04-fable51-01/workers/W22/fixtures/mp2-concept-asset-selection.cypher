// W22 fixture MP2: quality asset selection for CONCEPTS (Mechanism 'mTOR signaling' and Metric 'tissue NAD+
// concentration') - method-versioned suitability versus an unsourced legacy score; explanation is not evidence.
// CQ-MD-C02, CQ-MD-C03, CQ-MD-C05.
// Real record: Wikimedia Commons File:MTOR_signal_pathway.jpg imageinfo + extmetadata (retrieved 2026-10-04 via the
// Commons API through Firecrawl; S01). Width 433, height 594, size 55293 bytes, SHA-1 232dfb2e...5840 as STATED by
// Commons (kept in statedChecksum, never in contentHash), LicenseShortName 'CC BY-SA 3.0', Artist 'Lybbar12',
// categories include 'GFDL' and 'License migration redundant' (dual licence). The image bytes were NOT retrieved
// (upload.wikimedia.org blocked by the egress proxy): contentHash values are SYNTHETIC_FIXTURE.
// Generated explainers (C2, C4) and the legacy asset (C3) are SYNTHETIC.

MERGE (n:Mechanism:Entity {uid: 'hu:mechanism:mtor-signaling'})
SET n.name = 'mTOR signaling', n.entityType = 'MECHANISM';

MERGE (n:Metric:Entity {uid: 'hu:metric:tissue-nad-concentration'})
SET n.name = 'Tissue NAD+ concentration', n.entityType = 'METRIC';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w22-curator'})
SET n.name = 'BellLabs W22 media curator', n.entityType = 'AGENT', n.agentKind = 'MANUAL_AGENT';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-image-generator-synthetic'})
SET n.name = 'BellLabs illustration generator (synthetic fixture)', n.entityType = 'AGENT', n.agentKind = 'COMPUTATIONAL_MODEL', n.model = 'unspecified-image-model', n.promptVersion = 'explainer-prompt-v0';

MERGE (n:Agent:Entity {uid: 'hu:agent:legacy-mongo-research'})
SET n.name = 'Legacy mongo research pipeline (pre-migration)', n.entityType = 'AGENT', n.agentKind = 'AUTOMATED_AGENT';

MERGE (n:PseudonymousActor:Entity {uid: 'hu:pseudonymous-actor:commons-user-lybbar12'})
SET n.name = 'Lybbar12 (Wikimedia Commons user)', n.entityType = 'PSEUDONYMOUS_ACTOR';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-capture-2026-10-04'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-04T00:48:00Z'), n.endedAt = datetime('2026-10-04T01:10:00Z'), n.methodVersion = 'w22-firecrawl-scrape-2026-10-04';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-curation-2026-10-04'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-04T01:10:00Z'), n.endedAt = datetime('2026-10-04T02:00:00Z'), n.methodVersion = 'w22-manual-media-curation-v0.1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_ASSESSMENT', n.startedAt = datetime('2026-10-04T02:00:00Z'), n.endedAt = datetime('2026-10-04T02:05:00Z'), n.methodVersion = 'bl-media-display-quality-v1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-generate-mtor-explainer-synthetic'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_GENERATION', n.startedAt = datetime('2026-10-04T02:20:00Z'), n.endedAt = datetime('2026-10-04T02:21:00Z'), n.methodVersion = 'explainer-prompt-v0';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-generate-nad-metric-explainer-synthetic'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_GENERATION', n.startedAt = datetime('2026-10-04T02:22:00Z'), n.endedAt = datetime('2026-10-04T02:23:00Z'), n.methodVersion = 'explainer-prompt-v0';

MATCH (a:Activity {uid: 'hu:activity:w22-generate-mtor-explainer-synthetic'}), (g:Agent {uid: 'hu:agent:belllabs-image-generator-synthetic'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (a:Activity {uid: 'hu:activity:w22-generate-nad-metric-explainer-synthetic'}), (g:Agent {uid: 'hu:agent:belllabs-image-generator-synthetic'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Commons file page record (real retrieval) and the file bytes (not retrieved -> synthetic snapshot).
MERGE (n:Source:Entity {uid: 'hu:source:commons-file-mtor-signal-pathway'})
SET n.entityType = 'SOURCE', n.canonicalUri = 'https://commons.wikimedia.org/wiki/File:MTOR_signal_pathway.jpg', n.title = 'File:MTOR signal pathway.jpg', n.sourceKind = 'MEDIA_REPOSITORY_RECORD';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:commons-api-mtor-imageinfo-2026-10-04'})
SET n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://commons.wikimedia.org/w/api.php?action=query&titles=File:MTOR%20signal%20pathway.jpg&prop=imageinfo&iiprop=url|size|sha1|mime|timestamp|user|extmetadata&format=json',
    n.retrievedAt = datetime('2026-10-04T00:49:00Z'), n.observedAt = datetime('2026-10-04T00:49:00Z'), n.contentHash = 'sha256:3d336c9b79e63f221498cec2390d66ea6ce192a8ac3c851559118ca591c35dcf', n.contentHashBasis = 'SYNTHETIC_FIXTURE',
    n.captureCompleteness = 'COMPLETE', n.mimeType = 'application/json';

MERGE (n:Source:Entity {uid: 'hu:source:commons-upload-mtor-signal-pathway-jpg'})
SET n.entityType = 'SOURCE', n.canonicalUri = 'https://upload.wikimedia.org/wikipedia/commons/3/3d/MTOR_signal_pathway.jpg', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:commons-upload-mtor-jpg-synthetic'})
SET n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://upload.wikimedia.org/wikipedia/commons/3/3d/MTOR_signal_pathway.jpg', n.retrievedAt = datetime('2026-10-04T02:00:00Z'),
    n.contentHash = 'sha256:121c33df0bbcbe69a26ebe3b7e16fd8b10adade02afc027f7b2ebf289276748d', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/jpeg';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:commons-mtor-license-short-name'})
SET n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.prefix = '"LicenseShortName":{"value":"', n.exact = 'CC BY-SA 3.0', n.quoteHash = 'sha256:5975213b61b0c2db14643c803368d253a9f2bf6d138f6ff5b9305f703a162576';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:commons-mtor-categories-gfdl'})
SET n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.prefix = '"Categories":{"value":"', n.exact = 'GFDL|Human proteins|Signal transduction|License migration redundant', n.quoteHash = 'sha256:b9f0d10ec3fd7bee319f725bd021c96c7cdd3b6457d4df3d6c874932bd48bb7f';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:commons-mtor-image-description'})
SET n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.prefix = '"ImageDescription":{"value":"', n.exact = 'mTOR signal pathway', n.quoteHash = 'sha256:4ba3129244686b7df9cf1d8adb45a0243c17945ba344addca4800ef2a980c281';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:commons-upload-mtor-jpg-whole'})
SET n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (s:Source {uid: 'hu:source:commons-file-mtor-signal-pathway'}), (ss:SourceSnapshot {uid: 'hu:snapshot:commons-api-mtor-imageinfo-2026-10-04'}),
      (l1:SourceLocator {uid: 'hu:locator:commons-mtor-license-short-name'}), (l2:SourceLocator {uid: 'hu:locator:commons-mtor-categories-gfdl'}), (l3:SourceLocator {uid: 'hu:locator:commons-mtor-image-description'}),
      (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l1) MERGE (ss)-[:HAS_LOCATOR]->(l2) MERGE (ss)-[:HAS_LOCATOR]->(l3) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:commons-upload-mtor-signal-pathway-jpg'}), (ss:SourceSnapshot {uid: 'hu:snapshot:commons-upload-mtor-jpg-synthetic'}), (l:SourceLocator {uid: 'hu:locator:commons-upload-mtor-jpg-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

// ---- C1: Commons mTOR diagram (real metadata, synthetic bytes).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:commons-mtor-signal-pathway'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'MTOR signal pathway.jpg (Wikimedia Commons)', m.title = 'MTOR signal pathway', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM',
    m.generationMode = 'UNKNOWN', m.capturedAt = datetime('2012-09-25T00:00:00Z'), m.capturedAtPrecision = 'DAY', m.publishedAt = datetime('2012-09-25T11:06:13Z'), m.publishedAtPrecision = 'INSTANT',
    m.canonicalUrl = 'https://commons.wikimedia.org/wiki/File:MTOR_signal_pathway.jpg', m.caption = 'mTOR signal pathway',
    m.contentHash = 'sha256:121c33df0bbcbe69a26ebe3b7e16fd8b10adade02afc027f7b2ebf289276748d', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:commons-mtor-original'})
SET v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 433, v.heightPx = 594, v.fileSizeBytes = 55293,
    v.url = 'https://upload.wikimedia.org/wikipedia/commons/3/3d/MTOR_signal_pathway.jpg', v.statedChecksum = '232dfb2e0276842448a20a019c2b187d68215840', v.statedChecksumAlgorithm = 'SHA-1',
    v.contentHash = 'sha256:121c33df0bbcbe69a26ebe3b7e16fd8b10adade02afc027f7b2ebf289276748d', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (v:MediaVariant {uid: 'hu:media-variant:commons-mtor-original'}), (l:SourceLocator {uid: 'hu:locator:commons-upload-mtor-jpg-whole'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'USER_UPLOAD', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'Commons original file URL from imageinfo.url'}]->(l)
MERGE (v)-[:WAS_GENERATED_BY]->(cap) MERGE (m)-[:WAS_GENERATED_BY]->(cap);

// Two rights records for one file: the extmetadata licence offer and the GFDL category (dual licence).
MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:commons-mtor-cc-by-sa-3'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:7068dcc6474584dc10d93a73747fda5e488d4fdb13e210d4ad9b8924bb154a9c', r.rightsStatus = 'OPEN_LICENSE', r.statementKind = 'LICENSE_OFFER', r.statementScope = 'THIS_ASSET',
    r.licenseName = 'CC BY-SA 3.0', r.licenseUri = 'https://creativecommons.org/licenses/by-sa/3.0', r.attributionText = 'Lybbar12', r.rightsHolderText = 'Lybbar12',
    r.attributionRequired = true, r.shareAlikeRequired = true, r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:commons-mtor-gfdl'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:8f6b1259867ec4a18b8f0936d68dce154cfe41f604fce017ae9329267830b85e', r.rightsStatus = 'OPEN_LICENSE', r.statementKind = 'REPOSITORY_METADATA', r.statementScope = 'THIS_ASSET',
    r.licenseName = 'GFDL (version not stated in the retrieved metadata)', r.rightsHolderText = 'Lybbar12', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (x:Assertion {uid: 'hu:assertion:w22-c1-rights-cc-by-sa'})
SET x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:30:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2012-09-25T11:06:13Z'), x.validFromPrecision = 'INSTANT', x.validFromBasis = 'PUBLICATION_PROXY', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c1-rights-cc-by-sa'}), (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (r:MediaRightsRecord {uid: 'hu:media-rights:commons-mtor-cc-by-sa-3'}),
      (u:PseudonymousActor {uid: 'hu:pseudonymous-actor:commons-user-lybbar12'}), (l:SourceLocator {uid: 'hu:locator:commons-mtor-license-short-name'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(u) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-c1-rights-cc-by-sa'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2012-09-25T11:06:13Z'), e.validFromPrecision = 'INSTANT', e.validFromBasis = 'PUBLICATION_PROXY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:30:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-c1-rights-gfdl'})
SET x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:31:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2012-09-25T11:06:13Z'), x.validFromPrecision = 'INSTANT', x.validFromBasis = 'PUBLICATION_PROXY', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c1-rights-gfdl'}), (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (r:MediaRightsRecord {uid: 'hu:media-rights:commons-mtor-gfdl'}),
      (u:PseudonymousActor {uid: 'hu:pseudonymous-actor:commons-user-lybbar12'}), (l:SourceLocator {uid: 'hu:locator:commons-mtor-categories-gfdl'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(u) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-c1-rights-gfdl'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2012-09-25T11:06:13Z'), e.validFromPrecision = 'INSTANT', e.validFromBasis = 'PUBLICATION_PROXY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:31:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-c1-explains-mtor'})
SET x.predicate = 'EXPLAINS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:32:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c1-explains-mtor'}), (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}),
      (u:PseudonymousActor {uid: 'hu:pseudonymous-actor:commons-user-lybbar12'}), (l:SourceLocator {uid: 'hu:locator:commons-mtor-image-description'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(u) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-c1-explains-mtor'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.isPrimary = false, e.sourceText = 'mTOR signal pathway', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:32:00Z');

// ---- C2: SYNTHETIC BellLabs-generated mTOR explainer (operator record; generation disclosed).
MERGE (n:Source:Entity {uid: 'hu:source:belllabs-media-store-mtor-explainer'})
SET n.entityType = 'SOURCE', n.canonicalUri = 'urn:belllabs:media-store:mtor-explainer-v0', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:belllabs-mtor-explainer-synthetic'})
SET n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'urn:belllabs:media-store:mtor-explainer-v0', n.retrievedAt = datetime('2026-10-04T02:21:00Z'),
    n.contentHash = 'sha256:0be2c99c56e34b73cacd00fb103ae80a5d9cc53e4ee2e3ce5754486135cf58e3', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'image/png';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:belllabs-mtor-explainer-whole'})
SET n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (s:Source {uid: 'hu:source:belllabs-media-store-mtor-explainer'}), (ss:SourceSnapshot {uid: 'hu:snapshot:belllabs-mtor-explainer-synthetic'}), (l:SourceLocator {uid: 'hu:locator:belllabs-mtor-explainer-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'Generated mTOR signaling explainer (synthetic fixture)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'EDUCATIONAL', m.generationMode = 'GENERATED',
    m.isSynthetic = true, m.editDisclosureText = 'AI-generated illustration; simplified; not a source of evidence.', m.contentHash = 'sha256:0be2c99c56e34b73cacd00fb103ae80a5d9cc53e4ee2e3ce5754486135cf58e3', m.contentHashBasis = 'SYNTHETIC_FIXTURE',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:belllabs-generated-mtor-explainer-original'})
SET v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'PNG', v.mimeType = 'image/png', v.widthPx = 1600, v.heightPx = 1200,
    v.storageUri = 'urn:belllabs:media-store:mtor-explainer-v0', v.contentHash = 'sha256:0be2c99c56e34b73cacd00fb103ae80a5d9cc53e4ee2e3ce5754486135cf58e3', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-generated-mtor-explainer-original'}),
      (l:SourceLocator {uid: 'hu:locator:belllabs-mtor-explainer-whole'}), (gen:Activity {uid: 'hu:activity:w22-generate-mtor-explainer-synthetic'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'GENERATED_OUTPUT', captureRelation: 'SAME_BYTES_AS_SNAPSHOT'}]->(l)
MERGE (v)-[:WAS_GENERATED_BY]->(gen) MERGE (m)-[:WAS_GENERATED_BY]->(gen);

// ---- C4: SYNTHETIC generated explainer for the Metric.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:belllabs-generated-nad-metric-explainer-synthetic'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'Generated explainer: what tissue NAD+ concentration measures (synthetic fixture)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'EDUCATIONAL',
    m.generationMode = 'GENERATED', m.isSynthetic = true, m.editDisclosureText = 'AI-generated illustration; not a source of evidence.', m.contentHash = 'sha256:352c6ee92681400b435ee47eef138307d4918478575c0d96c7a59fb4bed7c3cb', m.contentHashBasis = 'SYNTHETIC_FIXTURE',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:belllabs-generated-nad-metric-explainer-original'})
SET v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'PNG', v.mimeType = 'image/png', v.widthPx = 1600, v.heightPx = 900,
    v.contentHash = 'sha256:352c6ee92681400b435ee47eef138307d4918478575c0d96c7a59fb4bed7c3cb', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-nad-metric-explainer-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-generated-nad-metric-explainer-original'}), (gen:Activity {uid: 'hu:activity:w22-generate-nad-metric-explainer-synthetic'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v) MERGE (v)-[:WAS_GENERATED_BY]->(gen) MERGE (m)-[:WAS_GENERATED_BY]->(gen);

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:belllabs-operator-generated-explainers'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:d9c368c2cefe3c823d362390bad5d29dacbef97716122277abb623b53fa51313', r.rightsStatus = 'HELD_BY_OPERATOR', r.statementKind = 'OPERATOR_RECORD', r.statementScope = 'THIS_ASSET',
    r.rightsHolderText = 'BellLabs (synthetic fixture)', r.restrictionsText = 'Generator service terms not reviewed in this fixture; operator record only.', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (x:Assertion {uid: 'hu:assertion:w22-c2-rights-operator'})
SET x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T02:25:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c2-rights-operator'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}), (r:MediaRightsRecord {uid: 'hu:media-rights:belllabs-operator-generated-explainers'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (l:SourceLocator {uid: 'hu:locator:belllabs-mtor-explainer-whole'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-c2-rights-operator'}]->(r)
SET e.assertionUid = x.uid, e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:25:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-c4-rights-operator'})
SET x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T02:25:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c4-rights-operator'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-nad-metric-explainer-synthetic'}), (r:MediaRightsRecord {uid: 'hu:media-rights:belllabs-operator-generated-explainers'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-c4-rights-operator'}]->(r)
SET e.assertionUid = x.uid, e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:25:00Z');

// EXPLAINS by BellLabs: the generator was prompted to explain the concept (asserted by the curator, PROPOSED).
MERGE (x:Assertion {uid: 'hu:assertion:w22-c2-explains-mtor'})
SET x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T02:26:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c2-explains-mtor'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}), (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-c2-explains-mtor'}]->(k)
SET e.assertionUid = x.uid, e.role = 'GENERATED_EXPLAINER', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:26:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-c4-explains-nad-metric'})
SET x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T02:26:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c4-explains-nad-metric'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-nad-metric-explainer-synthetic'}), (k:Metric {uid: 'hu:metric:tissue-nad-concentration'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-c4-explains-nad-metric'}]->(k)
SET e.assertionUid = x.uid, e.role = 'GENERATED_EXPLAINER', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:26:00Z');

// ---- C3: SYNTHETIC legacy asset with unsourced qualityScore 0.95, explaining both concepts; no rights record.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:legacy-concept-diagram-unsourced-synthetic'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'Legacy concept diagram with unsourced score (synthetic fixture)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM',
    m.qualityScore = 0.95, m.mongoResearchRunId = 'legacy-run-0002', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:legacy-concept-diagram-quality'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'legacy-unsourced', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T02:10:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'UNKNOWN', a.overallScore = 0.95, a.scoreScale = 'unknown (live qualityScore, no method recorded)', a.mongoResearchRunId = 'legacy-run-0002';

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:legacy-concept-diagram-quality'}), (m:MediaAsset {uid: 'hu:media-asset:legacy-concept-diagram-unsourced-synthetic'})
MERGE (a)-[:ASSESSES_MEDIA]->(m);

MERGE (n:Activity:Occurrence {uid: 'hu:activity:legacy-run-0002'})
SET n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.externalRunSystem = 'mongo-research', n.externalRunId = 'legacy-run-0002', n.methodVersion = 'unknown';

MERGE (x:Assertion {uid: 'hu:assertion:w22-c3-legacy-explains-mtor'})
SET x.predicate = 'EXPLAINS', x.status = 'EXTRACTED', x.recordedAt = datetime('2026-10-04T02:10:00Z'), x.predicateClass = 'OTHER', x.mongoResearchRunId = 'legacy-run-0002';

MERGE (x:Assertion {uid: 'hu:assertion:w22-c3-legacy-explains-nad-metric'})
SET x.predicate = 'EXPLAINS', x.status = 'EXTRACTED', x.recordedAt = datetime('2026-10-04T02:10:00Z'), x.predicateClass = 'OTHER', x.mongoResearchRunId = 'legacy-run-0002';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c3-legacy-explains-mtor'}), (m:MediaAsset {uid: 'hu:media-asset:legacy-concept-diagram-unsourced-synthetic'}), (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}),
      (g:Agent {uid: 'hu:agent:legacy-mongo-research'}), (act:Activity {uid: 'hu:activity:legacy-run-0002'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(act)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-c3-legacy-explains-mtor'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:10:00Z'), e.mongoResearchRunId = 'legacy-run-0002';

MATCH (x:Assertion {uid: 'hu:assertion:w22-c3-legacy-explains-nad-metric'}), (m:MediaAsset {uid: 'hu:media-asset:legacy-concept-diagram-unsourced-synthetic'}), (k:Metric {uid: 'hu:metric:tissue-nad-concentration'}),
      (g:Agent {uid: 'hu:agent:legacy-mongo-research'}), (act:Activity {uid: 'hu:activity:legacy-run-0002'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(act)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-c3-legacy-explains-nad-metric'}]->(k)
SET e.assertionUid = x.uid, e.role = 'GENERATED_EXPLAINER', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T02:10:00Z'), e.mongoResearchRunId = 'legacy-run-0002';

// ---- Method-versioned assessments. The Commons diagram is MARGINAL for a mechanism diagram slot (433 x 594 px) but
// ---- SUITABLE as a thumbnail: suitability is per role, not a property of the asset.
MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c1-display-quality-mechanism-diagram'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'MARGINAL', a.overallScore = 0.55, a.scoreScale = '0..1 higher-better', a.intendedRole = 'MECHANISM_DIAGRAM',
    a.criteriaSummary = 'short edge >= 800 px for diagram slots; labels legible at display width (433 x 594 px original fails the size criterion)';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c1-display-quality-thumbnail'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.80, a.scoreScale = '0..1 higher-better', a.intendedRole = 'THUMBNAIL',
    a.criteriaSummary = 'short edge >= 300 px for thumbnails';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c2-display-quality-mechanism-diagram'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:30:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.88, a.scoreScale = '0..1 higher-better', a.intendedRole = 'MECHANISM_DIAGRAM',
    a.criteriaSummary = 'short edge >= 800 px for diagram slots; labels legible at display width';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c2-depiction-accuracy'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-depiction-review-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:31:00Z'),
    a.dimension = 'DEPICTION_ACCURACY', a.verdict = 'SUITABLE', a.intendedRole = 'MECHANISM_DIAGRAM', a.summary = 'Expert review: components and arrows match the curated mechanism assertions (synthetic).';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c2-authenticity'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-authenticity-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:31:00Z'),
    a.dimension = 'AUTHENTICITY', a.verdict = 'SUITABLE', a.summary = 'Generation disclosed (isSynthetic true, disclosure text present); not presented as a capture.';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:c4-display-quality-explainer'})
SET a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:30:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.84, a.scoreScale = '0..1 higher-better', a.intendedRole = 'GENERATED_EXPLAINER';

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c1-display-quality-mechanism-diagram'}), (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (v:MediaVariant {uid: 'hu:media-variant:commons-mtor-original'}),
      (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSED_ON_VARIANT]->(v) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c1-display-quality-thumbnail'}), (m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'}), (v:MediaVariant {uid: 'hu:media-variant:commons-mtor-original'}),
      (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSED_ON_VARIANT]->(v) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c2-display-quality-mechanism-diagram'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}),
      (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c2-depiction-accuracy'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}),
      (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'}), (act:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c2-authenticity'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-mtor-explainer-synthetic'}), (act:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:c4-display-quality-explainer'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-generated-nad-metric-explainer-synthetic'}),
      (k:Metric {uid: 'hu:metric:tissue-nad-concentration'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

// =====================================================================================================================
// Queries
// =====================================================================================================================

// Q-MP2-1 (CQ-MD-C02): explanatory-asset selection for Mechanism mTOR signaling in a MECHANISM_DIAGRAM slot.
MATCH (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'})<-[d:EXPLAINS|DEPICTS]-(m:MediaAsset)
WHERE d.recordedTo IS NULL
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL AND hr.validTo IS NULL
WITH m, collect(DISTINCT r.rightsStatus) AS rights, collect(DISTINCT r.attributionText) AS attributions, collect(DISTINCT r.licenseName) AS licences
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED', intendedRole: 'MECHANISM_DIAGRAM'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) }
WITH m, rights, attributions, licences, q ORDER BY q.overallScore DESC
WITH m, rights, attributions, licences, collect(q)[0] AS best, ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS allowed
RETURN m.uid AS asset, m.generationMode AS generationMode, coalesce(m.isSynthetic, false) AS mustLabelAsGenerated, rights, licences, attributions,
       best.verdict AS displayVerdict, best.overallScore AS displayScore,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED'
       WHEN NOT all(x IN rights WHERE x IN allowed) THEN 'EXCLUDED_RIGHTS_NOT_PERMITTED'
       WHEN best IS NULL THEN 'EXCLUDED_NO_METHOD_VERSIONED_ASSESSMENT'
       WHEN best.verdict <> 'SUITABLE' THEN 'EXCLUDED_NOT_SUITABLE'
       ELSE 'ELIGIBLE' END AS decision
ORDER BY decision, displayScore DESC, asset;

// Q-MP2-2 (CQ-MD-C02): the same Commons diagram is ELIGIBLE in a THUMBNAIL slot (role-specific suitability).
MATCH (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'})<-[:EXPLAINS]-(m:MediaAsset {uid: 'hu:media-asset:commons-mtor-signal-pathway'})
MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced'
MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
RETURN q.intendedRole AS role, q.verdict AS verdict, q.overallScore AS score, collect(r.licenseName) AS licences, collect(DISTINCT r.attributionText) AS attribution
ORDER BY role;

// Q-MP2-3 (CQ-MD-C02, Metric): explanatory-asset selection for the Metric; legacy 0.95 asset excluded.
MATCH (k:Metric {uid: 'hu:metric:tissue-nad-concentration'})<-[d:EXPLAINS]-(m:MediaAsset)
OPTIONAL MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
WITH m, collect(r.rightsStatus) AS rights
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) }
RETURN m.uid AS asset, rights, q.verdict AS verdict, m.qualityScore AS legacyUnsourcedScore,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED' WHEN q IS NULL THEN 'EXCLUDED_NO_METHOD_VERSIONED_ASSESSMENT' WHEN q.verdict = 'SUITABLE' THEN 'ELIGIBLE' ELSE 'EXCLUDED_NOT_SUITABLE' END AS decision
ORDER BY decision, asset;

// Q-MP2-4 (CQ-MD-C05, negative): no explanatory asset of mTOR is evidence. Expected 0 rows.
MATCH (k:Mechanism {uid: 'hu:mechanism:mtor-signaling'})<-[:EXPLAINS]-(m:MediaAsset)-[:EVIDENCES]->(x)
RETURN m.uid AS explanatoryAssetUsedAsEvidence, x.uid AS evidenced;
