// W22 fixture MP1: quality asset selection for a PRODUCT (Elysium Basis) - method-versioned suitability plus explicit
// rights versus an unsourced legacy qualityScore. CQ-MD-C01, CQ-MD-C03, CQ-PV-06.
// Real records: Elysium product page image list and alt text, terms of service (retrieved 2026-10-04 via Firecrawl,
// see 03-source-manifest.md S09, S11). Image BYTES were not retrieved (direct fetch blocked); every image snapshot and
// variant hash is SYNTHETIC_FIXTURE: sha256 over the snapshot uid, repeated on the variant that has the same bytes.
// The BellLabs jar photo (A3) and the legacy marketplace image (A4) are SYNTHETIC members of the pair.
// Every statement binds its own nodes by uid; variables never cross ';'.
// uid tokens media-asset, media-variant, media-assessment, media-rights are PROPOSED (W22-SR-01).
// sourceKind MEDIA_FILE and activityKind MEDIA_ASSESSMENT are PROPOSED values (W22-SR-04, W22-SR-06).

MERGE (n:Organization:Entity {uid: 'hu:org:elysium-health-inc'})
SET n.privacyClass = 'PUBLIC', n.name = 'Elysium Health', n.entityType = 'ORGANIZATION';

MERGE (n:Product:Entity {uid: 'hu:product:elysium-basis'})
SET n.privacyClass = 'PUBLIC', n.name = 'Basis', n.entityType = 'PRODUCT', n.productKind = 'DIETARY_SUPPLEMENT';

MERGE (n:Agent:Entity {uid: 'hu:agent:firecrawl-scrape'})
SET n.privacyClass = 'PUBLIC', n.name = 'Firecrawl scrape (MCP connector)', n.entityType = 'AGENT', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w22-curator'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs W22 media curator', n.entityType = 'AGENT', n.agentKind = 'MANUAL_AGENT';

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-media-quality-v1'})
SET n.privacyClass = 'PUBLIC', n.name = 'BellLabs media display-quality checker', n.entityType = 'AGENT', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'bl-media-display-quality-v1';

MERGE (n:Agent:Entity {uid: 'hu:agent:legacy-mongo-research'})
SET n.privacyClass = 'PUBLIC', n.name = 'Legacy mongo research pipeline (pre-migration)', n.entityType = 'AGENT', n.agentKind = 'AUTOMATED_AGENT';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-capture-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'CAPTURE', n.startedAt = datetime('2026-10-04T00:48:00Z'), n.endedAt = datetime('2026-10-04T01:10:00Z'), n.methodVersion = 'w22-firecrawl-scrape-2026-10-04';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-curation-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.startedAt = datetime('2026-10-04T01:10:00Z'), n.endedAt = datetime('2026-10-04T02:00:00Z'), n.methodVersion = 'w22-manual-media-curation-v0.1';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'MEDIA_ASSESSMENT', n.startedAt = datetime('2026-10-04T02:00:00Z'), n.endedAt = datetime('2026-10-04T02:05:00Z'), n.methodVersion = 'bl-media-display-quality-v1';

MATCH (a:Activity {uid: 'hu:activity:w22-capture-2026-10-04'}), (g:Agent {uid: 'hu:agent:firecrawl-scrape'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (a:Activity {uid: 'hu:activity:w22-curation-2026-10-04'}), (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (a:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'}), (g:Agent {uid: 'hu:agent:belllabs-media-quality-v1'})
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- Sources and snapshots: product page (real retrieval, hash not computed over bytes -> SYNTHETIC), terms page,
// ---- and the CDN image files (bytes not retrieved -> synthetic snapshots).
MERGE (n:Source:Entity {uid: 'hu:source:elysium-basis-product-page'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://www.elysiumhealth.com/products/basis', n.title = 'Basis NAD+ Supplement | Clinically Proven to Raise NAD+ | Elysium', n.sourceKind = 'MARKETING_PAGE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-basis-product-page-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://www.elysiumhealth.com/products/basis', n.retrievedAt = datetime('2026-10-04T00:53:00Z'), n.observedAt = datetime('2026-10-04T00:53:00Z'),
    n.contentHash = 'sha256:61cf4ab5e18ea5daa50dc584e9dba009e1a05899f5189d1e81db084aab2c3fce', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'PARTIAL_EXCERPT', n.mimeType = 'text/html';

MERGE (n:Source:Entity {uid: 'hu:source:elysium-terms-of-service'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://www.elysiumhealth.com/policies/terms-of-service', n.title = 'Terms of service', n.sourceKind = 'ORGANIZATION_WEBPAGE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-terms-of-service-2026-10-04'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://www.elysiumhealth.com/policies/terms-of-service', n.retrievedAt = datetime('2026-10-04T00:54:00Z'), n.observedAt = datetime('2026-10-04T00:54:00Z'),
    n.publishedAt = datetime('2022-11-17T00:00:00Z'), n.publishedAtPrecision = 'DAY',
    n.contentHash = 'sha256:9be9b913ba9d27a12452d8c0727194843a6ccbf9279ed0b1bf33fc377fab2a99', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'text/html';

MERGE (n:Source:Entity {uid: 'hu:source:elysium-cdn-basis-hero-w1946'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://www.elysiumhealth.com/cdn/shop/files/1_Basis_Carousel_Hero_SEP26_1_1_f5988a5d-c8f8-460a-b971-bd1e6e631d9c.jpg?v=1790519922&width=1946', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-cdn-basis-hero-w1946-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://www.elysiumhealth.com/cdn/shop/files/1_Basis_Carousel_Hero_SEP26_1_1_f5988a5d-c8f8-460a-b971-bd1e6e631d9c.jpg?v=1790519922&width=1946', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:2e16be37d1131dadbef9d068a6c685b0de68a71db67d9036bdf4c19eeb433a06', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/jpeg';

MERGE (n:Source:Entity {uid: 'hu:source:belllabs-media-store-basis-jar-photo'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'urn:belllabs:media-store:basis-jar-photo-2026-10-04', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:belllabs-basis-jar-photo-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'urn:belllabs:media-store:basis-jar-photo-2026-10-04', n.retrievedAt = datetime('2026-10-04T01:31:00Z'),
    n.contentHash = 'sha256:2f0dc50e6d5e263d9190dad88be811a1b7a60f5124f0b46b94d56511020e6a1a', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'COMPLETE', n.mimeType = 'image/jpeg';

MATCH (s:Source {uid: 'hu:source:elysium-basis-product-page'}), (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-basis-product-page-2026-10-04'}), (a:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:WAS_GENERATED_BY]->(a);

MATCH (s:Source {uid: 'hu:source:elysium-terms-of-service'}), (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-terms-of-service-2026-10-04'}), (a:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:WAS_GENERATED_BY]->(a);

MATCH (s:Source {uid: 'hu:source:elysium-cdn-basis-hero-w1946'}), (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-cdn-basis-hero-w1946-synthetic'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss);

MATCH (s:Source {uid: 'hu:source:belllabs-media-store-basis-jar-photo'}), (ss:SourceSnapshot {uid: 'hu:snapshot:belllabs-basis-jar-photo-synthetic'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss);

// ---- Locators
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-product-page-hero-alt-text'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.uri = 'https://www.elysiumhealth.com/products/basis', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = 'A white cylindrical supplement jar labeled \'Basis\' on a light beige background, with two capsules in front and certification logos in the top right corner.',
    n.quoteHash = 'sha256:67dac55e97d700dba2df488f800d7b4a5833ea07215f655c5f8cc9d1e21c3a60';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-terms-content-license'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.uri = 'https://www.elysiumhealth.com/policies/terms-of-service', n.selectorKind = 'TEXT_QUOTE', n.normalizationVersion = 'NFC-WS1',
    n.exact = 'Elysium Health grants you a limited, non-exclusive, non-transferable, non-sublicensable license to view, display and print the Content solely in connection with your permitted use of the Services and solely for your personal and non-commercial purposes.',
    n.quoteHash = 'sha256:c47d51452185c3d1b44894f1fe934a13b8d63ad53e1c5c4a22bcb8b2055a9832';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-cdn-basis-hero-w1946-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:belllabs-basis-jar-photo-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-basis-product-page-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:elysium-product-page-hero-alt-text'})
MERGE (ss)-[:HAS_LOCATOR]->(l);

MATCH (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-terms-of-service-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:elysium-terms-content-license'})
MERGE (ss)-[:HAS_LOCATOR]->(l);

MATCH (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-cdn-basis-hero-w1946-synthetic'}), (l:SourceLocator {uid: 'hu:locator:elysium-cdn-basis-hero-w1946-whole'})
MERGE (ss)-[:HAS_LOCATOR]->(l);

MATCH (ss:SourceSnapshot {uid: 'hu:snapshot:belllabs-basis-jar-photo-synthetic'}), (l:SourceLocator {uid: 'hu:locator:belllabs-basis-jar-photo-whole'})
MERGE (ss)-[:HAS_LOCATOR]->(l);

// ---- A1: Elysium hero image (real URL and alt text; bytes synthetic). Two publisher renditions (width 1946 and 416).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:elysium-basis-carousel-hero'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Basis carousel hero image (Elysium product page)', m.assetType = 'IMAGE', m.mediaPurpose = 'PRODUCT_PHOTO', m.generationMode = 'UNKNOWN',
    m.altText = 'A white cylindrical supplement jar labeled \'Basis\' on a light beige background, with two capsules in front and certification logos in the top right corner.',
    m.canonicalUrl = 'https://www.elysiumhealth.com/products/basis', m.observedAt = datetime('2026-10-04T00:53:00Z'),
    m.contentHash = 'sha256:2e16be37d1131dadbef9d068a6c685b0de68a71db67d9036bdf4c19eeb433a06', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:elysium-basis-carousel-hero-w1946'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 1946,
    v.url = 'https://www.elysiumhealth.com/cdn/shop/files/1_Basis_Carousel_Hero_SEP26_1_1_f5988a5d-c8f8-460a-b971-bd1e6e631d9c.jpg?v=1790519922&width=1946',
    v.contentHash = 'sha256:2e16be37d1131dadbef9d068a6c685b0de68a71db67d9036bdf4c19eeb433a06', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:elysium-basis-carousel-hero-w416'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'RESIZED', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 416,
    v.url = 'https://www.elysiumhealth.com/cdn/shop/files/1_Basis_Carousel_Hero_SEP26_1_1_f5988a5d-c8f8-460a-b971-bd1e6e631d9c.jpg?v=1790519922&width=416',
    v.contentHash = 'sha256:5a5ee56bfc138283521b21c7ffa4a2992403cfea34e395d52463825dede13712', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-hero'}), (v1:MediaVariant {uid: 'hu:media-variant:elysium-basis-carousel-hero-w1946'}), (v2:MediaVariant {uid: 'hu:media-variant:elysium-basis-carousel-hero-w416'}),
      (l:SourceLocator {uid: 'hu:locator:elysium-cdn-basis-hero-w1946-whole'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v1)
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v2)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'PRODUCT_PAGE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'og:image and carousel slide 1 of 5'}]->(l)
MERGE (v1)-[:WAS_GENERATED_BY]->(cap)
MERGE (v2)-[:WAS_GENERATED_BY]->(cap)
MERGE (m)-[:WAS_GENERATED_BY]->(cap);

// ---- A2: Elysium Supplement Facts carousel image (real URL and alt text; bytes synthetic). Also used by MP5.
MERGE (n:Source:Entity {uid: 'hu:source:elysium-cdn-basis-supplement-facts-w1946'})
SET n.privacyClass = 'PUBLIC', n.entityType = 'SOURCE', n.canonicalUri = 'https://www.elysiumhealth.com/cdn/shop/files/5_Basis_Carousel_SupplementFacts_SEP26_1_1_33f99ab8-54b6-4178-b1fd-12c206b8064f.jpg?v=1790519922&width=1946', n.sourceKind = 'MEDIA_FILE';

MERGE (n:SourceSnapshot:InformationArtifact:LabelSnapshot {uid: 'hu:snapshot:elysium-cdn-basis-supplement-facts-w1946-synthetic'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_SNAPSHOT', n.canonicalUri = 'https://www.elysiumhealth.com/cdn/shop/files/5_Basis_Carousel_SupplementFacts_SEP26_1_1_33f99ab8-54b6-4178-b1fd-12c206b8064f.jpg?v=1790519922&width=1946', n.retrievedAt = datetime('2026-10-04T01:05:00Z'),
    n.contentHash = 'sha256:dc65afc729347a6161f42190a9f665338ac2f44bec7b7c368fc29cdcb415e592', n.contentHashBasis = 'SYNTHETIC_FIXTURE', n.captureCompleteness = 'UNKNOWN', n.mimeType = 'image/jpeg', n.jurisdiction = 'US';

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-cdn-basis-supplement-facts-w1946-whole'})
SET n.privacyClass = 'PUBLIC', n.artifactType = 'SOURCE_LOCATOR', n.selectorKind = 'WHOLE_SNAPSHOT';

MATCH (s:Source {uid: 'hu:source:elysium-cdn-basis-supplement-facts-w1946'}), (ss:SourceSnapshot {uid: 'hu:snapshot:elysium-cdn-basis-supplement-facts-w1946-synthetic'}), (l:SourceLocator {uid: 'hu:locator:elysium-cdn-basis-supplement-facts-w1946-whole'})
MERGE (s)-[:HAS_SNAPSHOT]->(ss) MERGE (ss)-[:HAS_LOCATOR]->(l);

MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:elysium-basis-carousel-supplement-facts'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'Basis carousel Supplement Facts image (Elysium product page)', m.assetType = 'IMAGE', m.mediaPurpose = 'LABEL_IMAGE', m.generationMode = 'UNKNOWN',
    m.altText = 'Supplement label with Elysium NR and PT content on a white background', m.canonicalUrl = 'https://www.elysiumhealth.com/products/basis', m.observedAt = datetime('2026-10-04T00:53:00Z'),
    m.contentHash = 'sha256:dc65afc729347a6161f42190a9f665338ac2f44bec7b7c368fc29cdcb415e592', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:elysium-basis-supplement-facts-w1946'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 1946,
    v.url = 'https://www.elysiumhealth.com/cdn/shop/files/5_Basis_Carousel_SupplementFacts_SEP26_1_1_33f99ab8-54b6-4178-b1fd-12c206b8064f.jpg?v=1790519922&width=1946',
    v.contentHash = 'sha256:dc65afc729347a6161f42190a9f665338ac2f44bec7b7c368fc29cdcb415e592', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:elysium-basis-supplement-facts-w416'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'RESIZED', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 416,
    v.url = 'https://www.elysiumhealth.com/cdn/shop/files/5_Basis_Carousel_SupplementFacts_SEP26_1_1_33f99ab8-54b6-4178-b1fd-12c206b8064f.jpg?v=1790519922&width=416',
    v.contentHash = 'sha256:425835749ee3773e041d1900338a4cd0260ff70d4542fcb7949c71a872787a97', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-supplement-facts'}), (v1:MediaVariant {uid: 'hu:media-variant:elysium-basis-supplement-facts-w1946'}), (v2:MediaVariant {uid: 'hu:media-variant:elysium-basis-supplement-facts-w416'}),
      (l:SourceLocator {uid: 'hu:locator:elysium-cdn-basis-supplement-facts-w1946-whole'}), (cap:Activity {uid: 'hu:activity:w22-capture-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v1)
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v2)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'PRODUCT_PAGE', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'carousel slide 5 of 5'}]->(l)
MERGE (v1)-[:WAS_GENERATED_BY]->(cap)
MERGE (v2)-[:WAS_GENERATED_BY]->(cap)
MERGE (m)-[:WAS_GENERATED_BY]->(cap);

// ---- A3: SYNTHETIC BellLabs-captured photo of a purchased Basis jar (operator-held rights).
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'})
SET m.privacyClass = 'PUBLIC', m.artifactType = 'MEDIA_ASSET', m.name = 'BellLabs photo of a purchased Basis jar (synthetic fixture)', m.assetType = 'IMAGE', m.mediaPurpose = 'PRODUCT_PHOTO', m.generationMode = 'CAPTURED',
    m.isSynthetic = false, m.isEdited = false, m.capturedAt = datetime('2026-10-04T01:30:00Z'), m.capturedAtPrecision = 'INSTANT',
    m.contentHash = 'sha256:2f0dc50e6d5e263d9190dad88be811a1b7a60f5124f0b46b94d56511020e6a1a', m.contentHashBasis = 'SYNTHETIC_FIXTURE', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (v:MediaVariant:InformationArtifact {uid: 'hu:media-variant:belllabs-photo-basis-jar-original'})
SET v.privacyClass = 'PUBLIC', v.artifactType = 'MEDIA_VARIANT', v.variantKind = 'ORIGINAL', v.mediaFormat = 'JPEG', v.mimeType = 'image/jpeg', v.widthPx = 3024, v.heightPx = 3024,
    v.storageUri = 'urn:belllabs:media-store:basis-jar-photo-2026-10-04', v.contentHash = 'sha256:2f0dc50e6d5e263d9190dad88be811a1b7a60f5124f0b46b94d56511020e6a1a', v.contentHashBasis = 'SYNTHETIC_FIXTURE';

MATCH (m:MediaAsset {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-photo-basis-jar-original'}), (l:SourceLocator {uid: 'hu:locator:belllabs-basis-jar-photo-whole'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (m)-[:HAS_MEDIA_VARIANT]->(v)
MERGE (m)-[:DERIVED_FROM_SOURCE {sourceType: 'USER_UPLOAD', captureRelation: 'SAME_BYTES_AS_SNAPSHOT', contextText: 'operator capture'}]->(l)
MERGE (v)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[:WAS_GENERATED_BY]->(cur);

// ---- A4: SYNTHETIC legacy marketplace image with an UNSOURCED qualityScore 0.97 (pre-migration live property) and its
// ---- migrated legacy assessment (methodVersion 'legacy-unsourced', no Activity). No rights record: rights NOT CHECKED.
MERGE (m:MediaAsset:InformationArtifact {uid: 'hu:media-asset:legacy-basis-marketplace-image-synthetic'})
SET m.artifactType = 'MEDIA_ASSET', m.name = 'Legacy marketplace image of Basis (synthetic fixture)', m.assetType = 'IMAGE', m.mediaPurpose = 'PRODUCT_PHOTO',
    m.qualityScore = 0.97, m.authenticityScore = 0.99, m.mongoResearchRunId = 'legacy-run-0001', m.privacyClass = 'PUBLIC', m.maturity = 'CANDIDATE';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:legacy-basis-marketplace-quality'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'legacy-unsourced', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T02:10:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'UNKNOWN', a.overallScore = 0.97, a.scoreScale = 'unknown (live qualityScore, no method recorded)', a.intendedRole = 'PRIMARY_IMAGE', a.mongoResearchRunId = 'legacy-run-0001';

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:legacy-basis-marketplace-quality'}), (m:MediaAsset {uid: 'hu:media-asset:legacy-basis-marketplace-image-synthetic'})
MERGE (a)-[:ASSESSES_MEDIA]->(m);

// ---- Depiction assertions and their asserted DEPICTS edges (one Assertion per edge episode).
MERGE (x:Assertion {uid: 'hu:assertion:w22-a1-depicts-basis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'DEPICTS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:20:00Z'), x.polarity = 'POSITIVE', x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a1-depicts-basis'}), (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-hero'}), (p:Product {uid: 'hu:product:elysium-basis'}),
      (o:Organization {uid: 'hu:org:elysium-health-inc'}), (l:SourceLocator {uid: 'hu:locator:elysium-product-page-hero-alt-text'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(p) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[d:DEPICTS {relationshipUid: 'hu:rel:w22-a1-depicts-basis'}]->(p)
SET d.assertionUid = x.uid, d.role = 'PRODUCT_PHOTO', d.isPrimary = true, d.sourceText = m.altText, d.validFromBasis = 'UNKNOWN', d.validToBasis = 'UNKNOWN', d.recordedFrom = datetime('2026-10-04T01:20:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-a2-depicts-basis-label'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'DEPICTS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:21:00Z'), x.polarity = 'POSITIVE', x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a2-depicts-basis-label'}), (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-supplement-facts'}), (p:Product {uid: 'hu:product:elysium-basis'}),
      (o:Organization {uid: 'hu:org:elysium-health-inc'}), (l:SourceLocator {uid: 'hu:locator:elysium-cdn-basis-supplement-facts-w1946-whole'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(p) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[d:DEPICTS {relationshipUid: 'hu:rel:w22-a2-depicts-basis-label'}]->(p)
SET d.assertionUid = x.uid, d.role = 'SUPPLEMENT_FACTS_LABEL', d.isPrimary = false, d.sourceText = m.altText, d.validFromBasis = 'UNKNOWN', d.validToBasis = 'UNKNOWN', d.recordedFrom = datetime('2026-10-04T01:21:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-a3-depicts-basis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'DEPICTS', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:35:00Z'), x.polarity = 'POSITIVE', x.predicateClass = 'OTHER', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a3-depicts-basis'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'}), (p:Product {uid: 'hu:product:elysium-basis'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (l:SourceLocator {uid: 'hu:locator:belllabs-basis-jar-photo-whole'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(p) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[d:DEPICTS {relationshipUid: 'hu:rel:w22-a3-depicts-basis'}]->(p)
SET d.assertionUid = x.uid, d.role = 'PRODUCT_PHOTO', d.isPrimary = false, d.validFromBasis = 'UNKNOWN', d.validToBasis = 'UNKNOWN', d.recordedFrom = datetime('2026-10-04T01:35:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-a4-legacy-depicts-basis'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'DEPICTS', x.status = 'EXTRACTED', x.recordedAt = datetime('2026-10-04T02:10:00Z'), x.polarity = 'POSITIVE', x.predicateClass = 'OTHER', x.mongoResearchRunId = 'legacy-run-0001';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a4-legacy-depicts-basis'}), (m:MediaAsset {uid: 'hu:media-asset:legacy-basis-marketplace-image-synthetic'}), (p:Product {uid: 'hu:product:elysium-basis'}), (g:Agent {uid: 'hu:agent:legacy-mongo-research'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(p) MERGE (x)-[:ASSERTED_BY]->(g)
MERGE (m)-[d:DEPICTS {relationshipUid: 'hu:rel:w22-a4-legacy-depicts-basis'}]->(p)
SET d.assertionUid = x.uid, d.role = 'PRODUCT_PHOTO', d.validFromBasis = 'UNKNOWN', d.validToBasis = 'UNKNOWN', d.recordedFrom = datetime('2026-10-04T02:10:00Z'), d.mongoResearchRunId = 'legacy-run-0001';

MERGE (n:Activity:Occurrence {uid: 'hu:activity:legacy-run-0001'})
SET n.privacyClass = 'PUBLIC', n.occurrenceType = 'ACTIVITY', n.activityKind = 'EXTRACTION', n.externalRunSystem = 'mongo-research', n.externalRunId = 'legacy-run-0001', n.methodVersion = 'unknown';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a4-legacy-depicts-basis'}), (a:Activity {uid: 'hu:activity:legacy-run-0001'})
MERGE (x)-[:WAS_GENERATED_BY]->(a);

// ---- Rights records. Elysium site terms (RESTRICTED_TERMS, ENTIRE_SITE) apply to A1 and A2; operator record to A3.
MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:elysium-site-terms-2022-11-17'})
SET r.privacyClass = 'PUBLIC', r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:23cc0c4158361ce7c0c4eb6d2357ceb772d7bac1833aa335c8229476075de165', r.effectiveFrom = datetime('2022-11-17T00:00:00Z'),
    r.rightsStatus = 'RESTRICTED_TERMS', r.statementKind = 'SITE_TERMS', r.statementScope = 'ENTIRE_SITE', r.rightsHolderText = 'Elysium Health and its licensors',
    r.commercialUseAllowed = false, r.restrictionsText = 'limited, non-exclusive, non-transferable, non-sublicensable license to view, display and print the Content solely in connection with your permitted use of the Services and solely for your personal and non-commercial purposes',
    r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (r:MediaRightsRecord:VersionedState {uid: 'hu:media-rights:belllabs-operator-basis-jar-photo'})
SET r.privacyClass = 'PUBLIC', r.stateType = 'MEDIA_RIGHTS', r.payloadHash = 'sha256:d9220b44483fa78d37ad7f1ba0eada71ca651f07a86d368099eb9f1cf74509fc', r.effectiveFrom = datetime('2026-10-04T01:30:00Z'),
    r.rightsStatus = 'HELD_BY_OPERATOR', r.statementKind = 'OPERATOR_RECORD', r.statementScope = 'THIS_ASSET', r.rightsHolderText = 'BellLabs (synthetic fixture)',
    r.restrictionsText = 'Product packaging shows third-party trademarks; trademark use is not assessed here (synthetic fixture).', r.privacyClass = 'PUBLIC', r.maturity = 'CANDIDATE';

MERGE (x:Assertion {uid: 'hu:assertion:w22-a1-rights-elysium-terms'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:25:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2022-11-17T00:00:00Z'), x.validFromPrecision = 'DAY', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a1-rights-elysium-terms'}), (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-hero'}), (r:MediaRightsRecord {uid: 'hu:media-rights:elysium-site-terms-2022-11-17'}),
      (o:Organization {uid: 'hu:org:elysium-health-inc'}), (l:SourceLocator {uid: 'hu:locator:elysium-terms-content-license'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-a1-rights-elysium-terms'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2022-11-17T00:00:00Z'), e.validFromPrecision = 'DAY', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:25:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-a2-rights-elysium-terms'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:26:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2022-11-17T00:00:00Z'), x.validFromPrecision = 'DAY', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a2-rights-elysium-terms'}), (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-supplement-facts'}), (r:MediaRightsRecord {uid: 'hu:media-rights:elysium-site-terms-2022-11-17'}),
      (o:Organization {uid: 'hu:org:elysium-health-inc'}), (l:SourceLocator {uid: 'hu:locator:elysium-terms-content-license'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(o) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-a2-rights-elysium-terms'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2022-11-17T00:00:00Z'), e.validFromPrecision = 'DAY', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:26:00Z');

MERGE (x:Assertion {uid: 'hu:assertion:w22-a3-rights-operator'})
SET x.privacyClass = 'PUBLIC', x.predicate = 'HAS_RIGHTS_RECORD', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-04T01:36:00Z'), x.predicateClass = 'OTHER', x.validFrom = datetime('2026-10-04T01:30:00Z'), x.validFromPrecision = 'INSTANT', x.validFromBasis = 'STATED_BY_SOURCE', x.validToBasis = 'UNKNOWN';

MATCH (x:Assertion {uid: 'hu:assertion:w22-a3-rights-operator'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'}), (r:MediaRightsRecord {uid: 'hu:media-rights:belllabs-operator-basis-jar-photo'}),
      (g:Agent {uid: 'hu:agent:belllabs-w22-curator'}), (l:SourceLocator {uid: 'hu:locator:belllabs-basis-jar-photo-whole'}), (cur:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (x)-[:HAS_SUBJECT]->(m) MERGE (x)-[:HAS_OBJECT]->(r) MERGE (x)-[:ASSERTED_BY]->(g) MERGE (x)-[:SUPPORTED_BY]->(l) MERGE (x)-[:WAS_GENERATED_BY]->(cur)
MERGE (m)-[e:HAS_RIGHTS_RECORD {relationshipUid: 'hu:rel:w22-a3-rights-operator'}]->(r)
SET e.assertionUid = x.uid, e.validFrom = datetime('2026-10-04T01:30:00Z'), e.validFromPrecision = 'INSTANT', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2026-10-04T01:36:00Z');

// ---- Method-versioned suitability assessments (one dimension per node).
MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:a1-display-quality-primary'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.93, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PRIMARY_IMAGE',
    a.criteriaSummary = 'short edge >= 800 px on inspected rendition; subject fills >= 30% of frame; no watermark (synthetic criteria)';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:a3-display-quality-primary'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-display-quality-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'),
    a.dimension = 'DISPLAY_QUALITY', a.verdict = 'SUITABLE', a.overallScore = 0.82, a.scoreScale = '0..1 higher-better', a.intendedRole = 'PRIMARY_IMAGE',
    a.criteriaSummary = 'short edge >= 800 px on inspected rendition; subject fills >= 30% of frame; no watermark (synthetic criteria)';

MERGE (a:MediaSuitabilityAssessment:EvidenceAssessment {uid: 'hu:media-assessment:a3-depiction-accuracy'})
SET a.privacyClass = 'PUBLIC', a.assessmentType = 'MEDIA_SUITABILITY', a.methodVersion = 'bl-media-depiction-review-v1', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:05:00Z'),
    a.dimension = 'DEPICTION_ACCURACY', a.verdict = 'SUITABLE', a.intendedRole = 'PRIMARY_IMAGE',
    a.summary = 'Jar label reads Basis; variant and formulation version not resolvable from the photo, so DEPICTS targets the Product, not a ProductVariant.';

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:a1-display-quality-primary'}), (m:MediaAsset {uid: 'hu:media-asset:elysium-basis-carousel-hero'}), (v:MediaVariant {uid: 'hu:media-variant:elysium-basis-carousel-hero-w1946'}),
      (p:Product {uid: 'hu:product:elysium-basis'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSED_ON_VARIANT]->(v) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(p) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:a3-display-quality-primary'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'}), (v:MediaVariant {uid: 'hu:media-variant:belllabs-photo-basis-jar-original'}),
      (p:Product {uid: 'hu:product:elysium-basis'}), (act:Activity {uid: 'hu:activity:w22-quality-assessment-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSED_ON_VARIANT]->(v) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(p) MERGE (a)-[:WAS_GENERATED_BY]->(act);

MATCH (a:MediaSuitabilityAssessment {uid: 'hu:media-assessment:a3-depiction-accuracy'}), (m:MediaAsset {uid: 'hu:media-asset:belllabs-photo-basis-jar-synthetic'}),
      (p:Product {uid: 'hu:product:elysium-basis'}), (act:Activity {uid: 'hu:activity:w22-curation-2026-10-04'})
MERGE (a)-[:ASSESSES_MEDIA]->(m) MERGE (a)-[:ASSESSES_SUITABILITY_FOR]->(p) MERGE (a)-[:WAS_GENERATED_BY]->(act);

// ---- Capture-fidelity adjudications for this fixture's ACCEPTED assertions (kernel V-110; synthetic review record:
// ---- 'the record accurately captures what the asserter stated in the cited span', never a truth verdict).
MATCH (g:Agent {uid: 'hu:agent:belllabs-w22-curator'})
UNWIND ['hu:assertion:w22-a1-depicts-basis', 'hu:assertion:w22-a2-depicts-basis-label', 'hu:assertion:w22-a3-depicts-basis', 'hu:assertion:w22-a1-rights-elysium-terms', 'hu:assertion:w22-a2-rights-elysium-terms', 'hu:assertion:w22-a3-rights-operator'] AS u
MATCH (a:Assertion {uid: u})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w22-cf-' + substring(u, 13)})
SET j.assessmentType = 'ADJUDICATION', j.methodVersion = 'w22-capture-fidelity-review-v0', j.status = 'ACCEPTED', j.adjudicationKind = 'CAPTURE_FIDELITY',
    j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = a.recordedAt + duration('PT1M'), j.recordedAt = a.recordedAt + duration('PT1M'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a) MERGE (j)-[:ASSESSED_BY]->(g);

// ==== Queries (expected rows in 06-fixtures-and-queries.md) ====

// Q-MP1-1 (CQ-MD-C01): primary-image selection for Product Basis. Allowed rights statuses are the contents of
// PolicyVersion hu:policy-version:media-display-v0 (W23; inlined here as a literal list). An asset is ELIGIBLE only if
// it has at least one current rights record, ALL current records are in the allowed list, and a current, non-legacy,
// Activity-backed DISPLAY_QUALITY assessment for the role says SUITABLE; no DEPICTION_ACCURACY says UNSUITABLE.
MATCH (p:Product {uid: 'hu:product:elysium-basis'})<-[d:DEPICTS]-(m:MediaAsset)
WHERE d.recordedTo IS NULL
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord) WHERE hr.recordedTo IS NULL AND hr.validTo IS NULL
WITH p, m, d, collect(r.rightsStatus) AS rights
OPTIONAL MATCH (q:MediaSuitabilityAssessment {dimension: 'DISPLAY_QUALITY', status: 'ACCEPTED', intendedRole: 'PRIMARY_IMAGE'})-[:ASSESSES_MEDIA]->(m)
WHERE q.methodVersion <> 'legacy-unsourced' AND EXISTS { MATCH (q)-[:WAS_GENERATED_BY]->(:Activity) } AND NOT EXISTS { MATCH (:MediaSuitabilityAssessment)-[:SUPERSEDES]->(q) }
WITH p, m, d, rights, q ORDER BY q.overallScore DESC
WITH p, m, d, rights, collect(q)[0] AS best
OPTIONAL MATCH (bad:MediaSuitabilityAssessment {dimension: 'DEPICTION_ACCURACY', verdict: 'UNSUITABLE', status: 'ACCEPTED'})-[:ASSESSES_MEDIA]->(m)
WITH m, d, rights, best, count(bad) AS depictionRejections,
     ['OPEN_LICENSE', 'PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'HELD_BY_OPERATOR'] AS allowed
RETURN m.uid AS asset, d.role AS role, rights, best.verdict AS displayVerdict, best.overallScore AS displayScore, best.methodVersion AS method,
  CASE WHEN size(rights) = 0 THEN 'EXCLUDED_RIGHTS_NOT_CHECKED'
       WHEN NOT all(x IN rights WHERE x IN allowed) THEN 'EXCLUDED_RIGHTS_NOT_PERMITTED'
       WHEN best IS NULL THEN 'EXCLUDED_NO_METHOD_VERSIONED_ASSESSMENT'
       WHEN best.verdict <> 'SUITABLE' OR depictionRejections > 0 THEN 'EXCLUDED_NOT_SUITABLE'
       ELSE 'ELIGIBLE' END AS decision
ORDER BY decision, displayScore DESC, asset;

// Q-MP1-2 (failing case reproduced, negative): the live-style query that ranks by the unsourced qualityScore picks the
// legacy image. Expected 1 row: hu:media-asset:legacy-basis-marketplace-image-synthetic, 0.97.
MATCH (p:Product {uid: 'hu:product:elysium-basis'})<-[:DEPICTS]-(m:MediaAsset)
WHERE m.qualityScore IS NOT NULL
RETURN m.uid AS naivePick, m.qualityScore AS unsourcedScore
ORDER BY m.qualityScore DESC LIMIT 1;

// Q-MP1-3 (CQ-MD-C03): rights explanation for every image of Basis, with the statement, its scope and the captured span.
MATCH (p:Product {uid: 'hu:product:elysium-basis'})<-[:DEPICTS]-(m:MediaAsset)
OPTIONAL MATCH (m)-[hr:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
OPTIONAL MATCH (x:Assertion {uid: hr.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(ss:SourceSnapshot)
RETURN m.uid AS asset, r.rightsStatus AS status, r.statementKind AS kind, r.statementScope AS scope, l.exact AS statedTerms, ss.retrievedAt AS capturedAt
ORDER BY asset;
