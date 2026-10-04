// W22 fixture MP4: visually excellent image with insufficient usage permission versus licensed usable rendition, for
// one concept (Mechanism 'NAD+ biosynthesis: de novo and salvage pathways'; Pathway Reactome R-HSA-196807).
// CQ-MD-C03, CQ-PV-06, CQ-PV-01 (state 5). Rights explicit; unknown or absent rights never permit.
// Real records (03-source-manifest.md): Reactome licence page (S02: 'Pathway Illustrations ... CC BY 4.0'; data CC0);
// Reactome content record R-HSA-196807 (S03: stIdVersion R-HSA-196807.8, hasDiagram true, DOI 10.3180/R-HSA-196807.7,
// literature reference PMID 32595066); PubMed copyright metadata for PMID 32595066 (S04: 'Copyright (c) 2020 Elsevier Ltd.
// All rights reserved.') and PMC7502477 page (S05b: 'Author manuscript; available in PMC: 2021 Oct 1.'; 'Figure I.
// Chemical Structure and Biosynthesis of NAD+.'); PubMed copyright metadata for PMID 33353981 (S04: source
// 'not_available'); PMC copyright notice (S06). Image BYTES were not retrieved: all image hashes are SYNTHETIC_FIXTURE.
// Suitability scores, the 'not checked' asset P4, the PolicyVersion contents and the display activities are SYNTHETIC.
// uid token 'pathway' is PROPOSED (W22-SR-01; owner W03). useKind DISPLAY_MEDIA is PROPOSED (W22-SR-02).

MERGE (n:Mechanism:Entity {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'})
SET n.privacyClass = 'PUBLIC', n.name = 'NAD+ biosynthesis: de novo and salvage pathways', n.entityType = 'MECHANISM';

MERGE (n:Pathway:Entity {uid: 'hu:pathway:reactome-r-hsa-196807'})
SET n.privacyClass = 'PUBLIC', n.name = 'Nicotinate metabolism (Reactome R-HSA-196807)', n.entityType = 'PATHWAY';

MERGE (n:Organization:Entity {uid: 'hu:org:reactome'})
SET n.privacyClass = 'PUBLIC', n.name = 'Reactome', n.entityType = 'ORGANIZATION';

MERGE (n:Organization:Entity {uid: 'hu:org:elsevier'})
SET n.privacyClass = 'PUBLIC', n.name = 'Elsevier', n.entityType = 'ORGANIZATION';

MERGE (n:Organization:Entity {uid: 'hu:org:nlm-pubmed'})
SET n.privacyClass = 'PUBLIC', n.name = 'National Library of Medicine (PubMed/PMC)', n.entityType = 'ORGANIZATION';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w22-curator'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs W22 media curator', n.entityType = 'AGENT', n.agentKind = 'MANUAL_AGENT';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-answer-composer-synthetic'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs answer composer (synthetic fixture)', n.entityType = 'AGENT', n.agentKind = 'AUTOMATED_AGENT';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-capture-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-04T00:48:00Z'), n.endedAt = datetime('2026-10-04T01:10:00Z'), n.methodVersion = 'w22-firecrawl-scrape-2026-10-04';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-curation-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-04T01:10:00Z'), n.endedAt = datetime('2026-10-04T02:00:00Z'), n.methodVersion = 'w22-manual-media-curation-v0.1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_ASSESSMENT', n.startedAt = datetime('2026-10-04T02:00:00Z'), n.endedAt = datetime('2026-10-04T02:05:00Z'), n.methodVersion = 'bl-media-display-quality-v1';

MERGE (n:PolicyVersion:VersionedState {uid: 'hu:policy-version:media-display-v0'})
SET n.name = 'Media display policy v0 (synthetic; contents owned by W23)', n.stateType = 'POLICY_VERSION', n.payloadHash = 'sha256:1d6b15ec3867b972070be87ec009354c3b74175baa83bb73f4357b4e14c7387e', n.privacyClass = 'INTERNAL',
    n.description = 'Display allowed when every current rights record of the asset is OPEN_LICENSE, PUBLIC_DOMAIN, PERMISSION_GRANTED or HELD_BY_OPERATOR, with attribution and modification-indication duties honoured; anything else requires a recorded legal or policy decision.';

// ---- Sources and snapshots (real retrievals except the image files).
MERGE (n:Source:Entity {uid: 'hu:source:reactome-license'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://reactome.org/license', n.title = 'License Agreement - Reactome Pathway Database', n.sourceKind = 'ORGANIZATION_WEBPAGE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:reactome-license-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://reactome.org/license', n.retrievedAt = datetime('2026-10-04T00:50:00Z'), n.observedAt = datetime('2026-10-04T00:50:00Z'),
    n.contentHash = 'sha256:94fa289a919509b1bc0aa5a624a89919d699d1f4f39ef308a3a92eb5920c93ba', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'text/html';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:reactome-license-illustrations-cc-by'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = 'Pathway Illustrations, Icon Library, Art, and Branding Materials. This Reactome content is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).',
    n.quoteHash = 'sha256:fa1c81626ca1676efd385de89f15a01513f4f240198ac000f6cf8a9e8264626f';

MERGE (n:Source:Entity {uid: 'hu:source:reactome-content-r-hsa-196807'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://reactome.org/ContentService/data/query/R-HSA-196807', n.title = 'Nicotinate metabolism (R-HSA-196807)', n.sourceKind = 'DATA_REPOSITORY_RECORD';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:reactome-content-r-hsa-196807-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://reactome.org/ContentService/data/query/R-HSA-196807', n.retrievedAt = datetime('2026-10-04T00:51:00Z'), n.observedAt = datetime('2026-10-04T00:51:00Z'),
    n.contentHash = 'sha256:4bb58ee239494382f3d47377d95fd612cb4fd5e4debb31c070b2006866e24eff', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'application/json';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:reactome-r-hsa-196807-stid-version'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.prefix = '"stIdVersion":"', n.exact = 'R-HSA-196807.8', n.quoteHash = 'sha256:1748a341397f0d21b717cb0e1d2e96f90d0a38819fd83a7f4ccdd73886e670b5';

MERGE (n:Source:Entity {uid: 'hu:source:reactome-exporter-r-hsa-196807-png'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://reactome.org/ContentService/exporter/diagram/R-HSA-196807.png', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:reactome-exporter-r-hsa-196807-png-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://reactome.org/ContentService/exporter/diagram/R-HSA-196807.png', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:675a77cb94e7e8165260ee43eb2c2c840dd0ed22e071b76954f0a75165d26b09', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/png';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:reactome-exporter-r-hsa-196807-png-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MERGE (n:Source:Entity {uid: 'hu:source:pubmed-32595066'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/32595066/', n.title = 'Location, Location, Location: Compartmentalization of NAD+ Synthesis and Functions in Mammalian Cells', n.sourceKind = 'PEER_REVIEWED_PUBLICATION';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-32595066-copyright-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/32595066/', n.retrievedAt = datetime('2026-10-04T00:58:00Z'), n.observedAt = datetime('2026-10-04T00:58:00Z'),
    n.contentHash = 'sha256:3e9498d4de3a36bf970f5b8180942812e260135b5cf583fde257dd3aa3bac49f', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pubmed-32595066-copyright-statement'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.exact = 'Copyright © 2020 Elsevier Ltd. All rights reserved.', n.quoteHash = 'sha256:b11a9eb4b5cf0e0f3f4aec4457384a4f43d7333b4ed0f1afe6cc4f36f945cf39';

MERGE (n:Source:Entity {uid: 'hu:source:pmc-pmc7502477'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7502477/', n.title = 'Location, Location, Location: Compartmentalization of NAD+ Synthesis and Functions in Mammalian Cells - PMC', n.sourceKind = 'PEER_REVIEWED_PUBLICATION';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc-pmc7502477-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7502477/', n.retrievedAt = datetime('2026-10-04T01:02:00Z'), n.observedAt = datetime('2026-10-04T01:02:00Z'),
    n.contentHash = 'sha256:970597f99c39d7f467ac626f4cd1e37226b885a1243bc70b2abb55c30d991d02', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.mimeType = 'text/html';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc7502477-figure-i-title'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1', n.exact = 'Figure I. Chemical Structure and Biosynthesis of NAD+.', n.quoteHash = 'sha256:d8c0b8525274c836f937afd1dc1fdbec85dda8eb4a1fd75e35c325e2f48d2cba';

MERGE (n:Source:Entity {uid: 'hu:source:pmc-cdn-pmc7502477-f0003-jpg'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/3fdb/7502477/e9f79f1f77fa/nihms-1607383-f0003.jpg', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc-cdn-pmc7502477-f0003-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/3fdb/7502477/e9f79f1f77fa/nihms-1607383-f0003.jpg', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:3a1421d8b91cc3d7e761b2dc45e53204cba72eaa733a3e32b6da91f344cf6f87', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/jpeg';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc-cdn-pmc7502477-f0003-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MERGE (n:Source:Entity {uid: 'hu:source:pubmed-33353981'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/33353981/', n.title = 'NAD+ metabolism and its roles in cellular processes during ageing', n.sourceKind = 'PEER_REVIEWED_PUBLICATION';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-33353981-copyright-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/33353981/', n.retrievedAt = datetime('2026-10-04T00:58:00Z'), n.observedAt = datetime('2026-10-04T00:58:00Z'),
    n.contentHash = 'sha256:a2aae15eaeac73ceccc8d131f5da542757f46b9b5645583d1405b6ab4d5495e4', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pubmed-33353981-copyright-source-not-available'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (s:Source {uid: 'hu:source:reactome-license'}), (ss:SourceSnapshot {uid: 'hu:snapshot:reactome-license-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:reactome-license-illustrations-cc-by'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:reactome-content-r-hsa-196807'}), (ss:SourceSnapshot {uid: 'hu:snapshot:reactome-content-r-hsa-196807-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:reactome-r-hsa-196807-stid-version'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:reactome-exporter-r-hsa-196807-png'}), (ss:SourceSnapshot {uid: 'hu:snapshot:reactome-exporter-r-hsa-196807-png-synthetic'}), (l:SourceLocator {uid: 'hu:locator:reactome-exporter-r-hsa-196807-png-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MATCH (s:Source {uid: 'hu:source:pubmed-32595066'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pubmed-32595066-copyright-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pubmed-32595066-copyright-statement'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:pmc-pmc7502477'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pmc-pmc7502477-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pmc7502477-figure-i-title'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

MATCH (s:Source {uid: 'hu:source:pmc-cdn-pmc7502477-f0003-jpg'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pmc-cdn-pmc7502477-f0003-synthetic'}), (l:SourceLocator {uid: 'hu:locator:pmc-cdn-pmc7502477-f0003-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MATCH (s:Source {uid: 'hu:source:pubmed-33353981'}), (ss:SourceSnapshot {uid: 'hu:snapshot:pubmed-33353981-copyright-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pubmed-33353981-copyright-source-not-available'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l) MERGE (ss)-[:WAS_GENERATED_BY]->(cap);

// ---- P1: Reactome diagram export (RENDERED by Reactome from release data; licensed CC BY 4.0 as a pathway illustration).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:reactome-r-hsa-196807-diagram'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Reactome diagram: Nicotinate metabolism (R-HSA-196807.8)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM', m.generationMode = 'RENDERED',
    m.canonicalUrl = 'https://reactome.org/PathwayBrowser/#/R-HSA-196807', m.contentHash = 'sha256:675a77cb94e7e8165260ee43eb2c2c840dd0ed22e071b76954f0a75165d26b09', m.contentHashBasis = 'SYNTHETIC_FIXTURE',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:reactome-r-hsa-196807-diagram-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'PNG', v.mimeType = 'image/png', v.url = 'https://reactome.org/ContentService/exporter/diagram/R-HSA-196807.png',
    v.contentHash = 'sha256:675a77cb94e7e8165260ee43eb2c2c840dd0ed22e071b76954f0a75165d26b09', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:reactome-r-hsa-196807-diagram'}), (v:MediaVariant {uid: 'hu:media-variant:reactome-r-hsa-196807-diagram-original'}),
      (lw:SourceLocator {uid: 'hu:locator:reactome-exporter-r-hsa-196807-png-whole'}), (lr:SourceLocator {uid: 'hu:locator:reactome-r-hsa-196807-stid-version'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'RENDER_PIPELINE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'Reactome ContentService diagram exporter'}]->(lw)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'RENDER_PIPELINE', captureRelation: 'RENDERED_FROM_SOURCE_DATA', contextText: 'rendered by Reactome from pathway release R-HSA-196807.8'}]->(lr)
MERGE (v)-[:WAS_GENERATED_BY]->(cap) MERGE (m)-[:WAS_GENERATED_BY]->(cap);

// ---- P2: Elsevier review Box Figure I (visually excellent; all rights reserved; freely readable in PMC).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:cambronne-kraus-2020-figure-i'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Cambronne and Kraus 2020, Figure I (PMC author manuscript)', m.title = 'Figure I. Chemical Structure and Biosynthesis of NAD+.', m.assetType = 'DOCUMENT_FIGURE',
    m.mediaPurpose = 'SCIENTIFIC_FIGURE', m.generationMode = 'EXTRACTED', m.publishedAt = datetime('2020-06-25T00:00:00Z'), m.publishedAtPrecision = 'DAY', m.canonicalUrl = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7502477/figure/F3/',
    m.contentHash = 'sha256:3a1421d8b91cc3d7e761b2dc45e53204cba72eaa733a3e32b6da91f344cf6f87', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:cambronne-kraus-2020-figure-i-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.url = 'https://cdn.ncbi.nlm.nih.gov/pmc/blobs/3fdb/7502477/e9f79f1f77fa/nihms-1607383-f0003.jpg',
    v.contentHash = 'sha256:3a1421d8b91cc3d7e761b2dc45e53204cba72eaa733a3e32b6da91f344cf6f87', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:cambronne-kraus-2020-figure-i'}), (v:MediaVariant {uid: 'hu:media-variant:cambronne-kraus-2020-figure-i-original'}),
      (lw:SourceLocator {uid: 'hu:locator:pmc-cdn-pmc7502477-f0003-whole'}), (lt:SourceLocator {uid: 'hu:locator:pmc7502477-figure-i-title'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'STUDY_FIGURE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'PMC figure blob for Figure I'}]->(lw)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'DOCUMENT_FIGURE', captureRelation: 'EXTRACTED_FROM_REGION', contextText: 'Figure I. Chemical Structure and Biosynthesis of NAD+.'}]->(lt)
MERGE (v)-[:WAS_GENERATED_BY]->(cap) MERGE (m)-[:WAS_GENERATED_BY]->(cap);

// ---- P3: placeholder for a figure of PMID 33353981 (figure NOT retrieved; only the copyright-metadata check is real).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:covarrubias-2021-figure-placeholder'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'Covarrubias et al. 2021 figure (placeholder; figure not retrieved)', m.assetType = 'DOCUMENT_FIGURE', m.mediaPurpose = 'SCIENTIFIC_FIGURE', m.generationMode = 'EXTRACTED',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

// ---- P4: SYNTHETIC diagram never rights-checked.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:unchecked-nad-diagram-synthetic'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'NAD+ diagram found on a blog, rights never checked (synthetic fixture)', m.assetType = 'DIAGRAM', m.mediaPurpose = 'PATHWAY_DIAGRAM', m.generationMode = 'UNKNOWN',
    m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

// ---- EXPLAINS / DEPICTS assertions.
MERGE (x:Assertion {uid: 'hu:assertion:w22-p1-explains-nad-biosynthesis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'EXPLAINS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:50:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p1-explains-nad-biosynthesis'}), (m:MediaAsset {uid: 'hu:media-asset:reactome-r-hsa-196807-diagram'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}),
      (o:Organization {uid: 'hu:org:reactome'}), (l:SourceLocator {uid: 'hu:locator:reactome-r-hsa-196807-stid-version'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-p1-explains-nad-biosynthesis'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:50:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p1-depicts-reactome-pathway'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'DEPICTS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:50:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p1-depicts-reactome-pathway'}), (m:MediaAsset {uid: 'hu:media-asset:reactome-r-hsa-196807-diagram'}), (k:Pathway {uid: 'hu:pathway:reactome-r-hsa-196807'}),
      (o:Organization {uid: 'hu:org:reactome'}), (l:SourceLocator {uid: 'hu:locator:reactome-r-hsa-196807-stid-version'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:DEPICTS {relationshipUid: 'hu:rel:w22-p1-depicts-reactome-pathway'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.isPrimary = true, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:50:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p2-explains-nad-biosynthesis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'EXPLAINS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:51:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p2-explains-nad-biosynthesis'}), (m:MediaAsset {uid: 'hu:media-asset:cambronne-kraus-2020-figure-i'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}),
      (o:Organization {uid: 'hu:org:elsevier'}), (l:SourceLocator {uid: 'hu:locator:pmc7502477-figure-i-title'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-p2-explains-nad-biosynthesis'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.sourceText = 'Figure I. Chemical Structure and Biosynthesis of NAD+.', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:51:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p3-explains-nad-biosynthesis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T01:52:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p3-explains-nad-biosynthesis'}), (m:MediaAsset {uid: 'hu:media-asset:covarrubias-2021-figure-placeholder'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-p3-explains-nad-biosynthesis'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:52:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p4-explains-nad-biosynthesis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'EXPLAINS', x.status = 'PROPOSED', x.recordedAt = datetime('2026-10-04T01:53:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p4-explains-nad-biosynthesis'}), (m:MediaAsset {uid: 'hu:media-asset:unchecked-nad-diagram-synthetic'}), (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(k) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:EXPLAINS {relationshipUid: 'hu:rel:w22-p4-explains-nad-biosynthesis'}]->(k)
SET e.assertionUid = x.uid, e.role = 'PATHWAY_DIAGRAM', e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:53:00Z');

// ---- Rights records: CC BY 4.0 (content class), All rights reserved (containing work), no statement found.
MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:reactome-illustrations-cc-by-4'})
SET r.privacyClass = 'PUBLIC', r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:4ccd4d87bf8df42d98ac79d3de91448eb2ba60ad1a645fec1b578f60a5fc61a4', r.rightsStatus = 'OPEN_LICENSE', r.statementKind = 'LICENSE_OFFER', r.statementScope = 'CONTENT_CLASS_ON_SITE',
    r.licenseName = 'CC BY 4.0', r.licenseUri = 'https://creativecommons.org/licenses/by/4.0/', r.rightsHolderText = 'Reactome', r.attributionText = 'Reactome, Nicotinate metabolism (R-HSA-196807.8), CC BY 4.0',
    r.attributionRequired = true, r.modificationIndicationRequired = true,
    r.description = 'Curator interpretation: a diagram export is a Pathway Illustration (CC BY 4.0), not Data (CC0); the stricter reading is recorded.', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:elsevier-2020-all-rights-reserved-32595066'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:d22a1821d47256530b211fb5f17d88c072a80075b24cf1e99a39b3e1fad6f959', r.rightsStatus = 'ALL_RIGHTS_RESERVED', r.statementKind = 'COPYRIGHT_NOTICE', r.statementScope = 'CONTAINING_WORK',
    r.rightsHolderText = 'Elsevier Ltd', r.restrictionsText = 'Copyright © 2020 Elsevier Ltd. All rights reserved.', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:pubmed-33353981-no-statement'})
SET r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:036fb0f6bd8473a469a9aea910908c9298807cca318e72c85cfcc16793c6a0f1', r.rightsStatus = 'NO_STATEMENT_FOUND', r.statementKind = 'REPOSITORY_METADATA', r.statementScope = 'CONTAINING_WORK',
    r.description = 'PubMed/PMC copyright metadata check returned source not_available; the publisher page was not checked.', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (x:Assertion {uid: 'hu:assertion:w22-p1-rights-cc-by'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:55:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'OBSERVATION_ONLY', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p1-rights-cc-by'}), (m:MediaAsset {uid: 'hu:media-asset:reactome-r-hsa-196807-diagram'}), (r:MediaRightsRecord {uid: 'hu:media-rights:reactome-illustrations-cc-by-4'}),
      (o:Organization {uid: 'hu:org:reactome'}), (l:SourceLocator {uid: 'hu:locator:reactome-license-illustrations-cc-by'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-p1-rights-cc-by'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2026-10-04T00:50:00Z'), e.validFromPrecision = 'INSTANT', e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:55:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p2-rights-elsevier'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:56:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2020-01-01T00:00:00Z'), x.validFromPrecision = 'YEAR', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p2-rights-elsevier'}), (m:MediaAsset {uid: 'hu:media-asset:cambronne-kraus-2020-figure-i'}), (r:MediaRightsRecord {uid: 'hu:media-rights:elsevier-2020-all-rights-reserved-32595066'}),
      (o:Organization {uid: 'hu:org:elsevier'}), (l:SourceLocator {uid: 'hu:locator:pubmed-32595066-copyright-statement'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-p2-rights-elsevier'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2020-01-01T00:00:00Z'), e.validFromPrecision = 'YEAR', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:56:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-p3-rights-no-statement'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:57:00Z'), x.predicateClass = 'OTHER', x.validFromBasis = 'OBSERVATION_ONLY', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-p3-rights-no-statement'}), (m:MediaAsset {uid: 'hu:media-asset:covarrubias-2021-figure-placeholder'}), (r:MediaRightsRecord {uid: 'hu:media-rights:pubmed-33353981-no-statement'}),
      (o:Organization {uid: 'hu:org:nlm-pubmed'}), (l:SourceLocator {uid: 'hu:locator:pubmed-33353981-copyright-source-not-available'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-p3-rights-no-statement'}]->(r)
SET e.assertionUid = x.uid, e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:57:00Z');

// ---- Display-quality assessments (SYNTHETIC scores): the Elsevier figure is the best-looking candidate.
MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:p1-display-quality'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'), a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.78, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PATHWAY_DIAGRAM';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:p2-display-quality'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'), a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.96, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PATHWAY_DIAGRAM';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:p3-display-quality'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'), a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.90, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PATHWAY_DIAGRAM';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:p4-display-quality'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'), a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.92, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PATHWAY_DIAGRAM';

MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
UNWIND [['hu:media-assessment:p1-display-quality', 'hu:media-asset:reactome-r-hsa-196807-diagram'], ['hu:media-assessment:p2-display-quality', 'hu:media-asset:cambronne-kraus-2020-figure-i'],
        ['hu:media-assessment:p3-display-quality', 'hu:media-asset:covarrubias-2021-figure-placeholder'], ['hu:media-assessment:p4-display-quality', 'hu:media-asset:unchecked-nad-diagram-synthetic']] AS pair
MATCH (a:MediaSuitabilityAssessment {uid: pair[0]}), (m:MediaAsset {uid: pair[1]})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(k) MERGE (a)-[:WAS_GENERATED_BY]->(act);

// ---- Display activities (state 5). OK: Reactome rendition displayed under policy v0 with useKind DISPLAY_MEDIA.
// ---- BAD-1: Elsevier figure displayed without any AUTHORIZED_BY (V-608). BAD-2: Elsevier figure displayed with an
// ---- AUTHORIZED_BY although no permitting rights record exists (V-608b, informational: needs a recorded legal/policy decision).
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-display-nad-answer-ok-synthetic'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'ANSWER_COMPOSITION', n.startedAt = datetime('2026-10-04T03:10:00Z'), n.endedAt = datetime('2026-10-04T03:10:01Z'), n.methodVersion = 'answer-composer-v0';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-display-nad-answer-bad-unauthorized-synthetic'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'ANSWER_COMPOSITION', n.startedAt = datetime('2026-10-04T03:11:00Z'), n.endedAt = datetime('2026-10-04T03:11:01Z'), n.methodVersion = 'answer-composer-v0';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-display-nad-answer-bad-rights-synthetic'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'ANSWER_COMPOSITION', n.startedAt = datetime('2026-10-04T03:12:00Z'), n.endedAt = datetime('2026-10-04T03:12:01Z'), n.methodVersion = 'answer-composer-v0';

MATCH (a:Activity {uid: 'hu:activity:w22-display-nad-answer-ok-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:reactome-r-hsa-196807-diagram-original'}), (p:PolicyVersion {uid: 'hu:policy-version:media-display-v0'}), (g:Agent {uid: 'hu:agent:belllabs-answer-composer-synthetic'})
MERGE (a)-[:USED]->(v) MERGE (a)-[:AUTHORIZED_BY {useKind: 'DISPLAY_MEDIA'}]->(p) MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (a:Activity {uid: 'hu:activity:w22-display-nad-answer-bad-unauthorized-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:cambronne-kraus-2020-figure-i-original'}), (g:Agent {uid: 'hu:agent:belllabs-answer-composer-synthetic'})
MERGE (a)-[:USED]->(v) MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (a:Activity {uid: 'hu:activity:w22-display-nad-answer-bad-rights-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:cambronne-kraus-2020-figure-i-original'}), (p:PolicyVersion {uid: 'hu:policy-version:media-display-v0'}), (g:Agent {uid: 'hu:agent:belllabs-answer-composer-synthetic'})
MERGE (a)-[:USED]->(v) MERGE (a)-[:AUTHORIZED_BY {useKind: 'DISPLAY_MEDIA'}]->(p) MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Capture-fidelity adjudications for this fixture's ACCEPTED assertions (kernel V-110; synthetic review record:
// ---- 'the record accurately captures what the asserter stated in the cited span', never a truth verdict).
MATCH (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
UNWIND ['hu:assertion:w22-p1-explains-nad-biosynthesis', 'hu:assertion:w22-p1-depicts-reactome-pathway', 'hu:assertion:w22-p2-explains-nad-biosynthesis', 'hu:assertion:w22-p1-rights-cc-by', 'hu:assertion:w22-p2-rights-elsevier', 'hu:assertion:w22-p3-rights-no-statement'] AS u
MATCH (a:Assertion {uid: u})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w22-cf-' + substring(u, 13)})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'w22-capture-fidelity-review-v0', j.status = 'ACCEPTED', j.adjudicationKind = 'CAPTURE_FIDELITY',
    j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = a.recordedAt + duration('PT1M'), j.recordedAt = a.recordedAt + duration('PT1M'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a) MERGE (j)-[:ASSESSED_BY]->(g);

// =====================================================================================================================
// Queries
// =====================================================================================================================

// Q-MP4-1 (CQ-MD-C03 with CQ-MD-C02): rights-gated selection for the mechanism. The best-looking candidate (0.96) is
// excluded because its rights are reserved; NO_STATEMENT_FOUND and 'never checked' are excluded too.
MATCH (k:Mechanism {uid: 'hu:mechanism:nad-biosynthesis-de-novo-and-salvage'})<-[:EXPLAINS]-(m:MediaAsset)
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL AND hr.validTo IS NULL
WITH m, collect(r) AS recs
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED', intendedRole: 'PATHWAY_DIAGRAM'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) }
WITH m, recs, [x IN recs | x.rightsStatus] AS rights, q, ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS allowed
RETURN m.uid AS asset, q.overallScore AS displayScore, rights,
       [x IN recs WHERE x.attributionRequired | x.attributionText] AS requiredAttribution,
       any(x IN recs WHERE x.modificationIndicationRequired) AS mustIndicateChanges,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED'
       WHEN NOT all(x IN rights WHERE x IN allowed) THEN 'EXCLUDED_RIGHTS_NOT_PERMITTED'
       WHEN q IS NULL OR q.verdict <> 'SUITABLE' THEN 'EXCLUDED_NOT_SUITABLE'
       ELSE 'ELIGIBLE' END AS decision
ORDER BY decision, displayScore DESC;

// Q-MP4-2 (forbidden implication PUBLICLY_ACCESSIBLE -> REUSE_PERMITTED): the Elsevier figure's article is freely
// readable (a PMC snapshot exists) yet its rights record reserves all rights. Expected 1 row, displayPermittedByRights false.
MATCH (m:MediaAsset {uid: 'hu:media-asset:cambronne-kraus-2020-figure-i'})-[:DERIVED_FROM_SOURCE]->(l:SourceLocator)<-[:HAS_LOCATOR]-(ss:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source)
WHERE s.canonicalUri STARTS WITH 'https://pmc.ncbi.nlm.nih.gov/'
MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
RETURN m.uid AS asset, s.canonicalUri AS freelyReadableAt, ss.retrievedAt AS retrievedAt, r.rightsStatus AS rightsStatus,
       r.rightsStatus IN ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS displayPermittedByRights;

// Q-MP4-3 (CQ-PV-01 state 5, CQ-PV-06): every display activity with its authorization and the rights of what it showed.
MATCH (a:Activity {activityKind: 'ANSWER_COMPOSITION'})-[:USED]->(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
OPTIONAL MATCH (a)-[u:AUTHORIZED_BY]->(p:PolicyVersion)
OPTIONAL MATCH (m)-[:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
WITH a, m, u, p, collect(r.rightsStatus) AS rights
RETURN a.uid AS activity, m.uid AS asset, u.useKind AS useKind, p.uid AS policy, rights,
  CASE WHEN u IS NULL THEN 'UNAUTHORIZED_USE'
       WHEN size(rights) = 0 OR NOT all(x IN rights WHERE x IN ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR']) THEN 'AUTHORIZED_WITHOUT_PERMITTING_RIGHTS_RECORD'
       ELSE 'OK' END AS state5
ORDER BY activity;
