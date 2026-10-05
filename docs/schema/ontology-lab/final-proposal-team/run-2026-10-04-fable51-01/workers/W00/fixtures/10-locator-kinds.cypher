// W00 fixture 10 — locator kinds: IMAGE_REGION backed by a MediaAnnotation (CL-011 / D-010), re-anchoring across snapshots,
// a TEXT_POSITION without its text version, and a migrated untyped 0.1.0 selector (selectorKind null). Load 00-common-base.cypher first.
// Expected rows: V-W00-03 = 1 (hu:locator:w00-region-without-edge), V-403 = 1 (hu:locator:w00-offsets-without-text-version),
// V-401 = 1 (hu:assertion:w00-rests-on-legacy-locators). Everything else zero. SYNTHETIC_FIXTURE.
// Token notes: 'media-annotation' is registered by W00-R-01 (W22-SR-01, W00-SR-09). IMAGE_REGION normalizationVersion:
// 'IMG-PX1' (pixel x,y,w,h on the decoded raster after EXIF orientation; W22-SR-05) is the registered image normalization (W00-R-24;
// the earlier candidate IMG-REL-XYWH-1 of W00-SR-10 is withdrawn).

// Label photo capture and its region annotation.
MERGE (src:Source:Entity {uid: 'hu:source:w00-label-photo'})
ON CREATE SET src.id = 'w00-label-photo', src.entityType = 'Source', src.canonicalUri = 'https://product-p.example.invalid/images/label-front.jpg',
  src.sourceKind = 'MANUFACTURER_LABEL_PAGE', src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-01-01T00:00:00Z'), src.updatedAt = datetime('2026-01-01T00:00:00Z')
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-loc-label-photo-2026-01-01'})
ON CREATE SET s.id = 'w00-loc-label-photo-2026-01-01', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-01-01T00:00:00Z'), s.observedAt = datetime('2026-01-01T00:00:00Z'),
  s.contentHash = 'sha256:dcf8261dedcc6b4904d724087f3d22c47b8719ac422a958feb49ab890074c96e', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.mimeType = 'image/jpeg', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-01-01T00:00:00Z'), s.updatedAt = datetime('2026-01-01T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MERGE (m:MediaAnnotation:InformationArtifact {uid: 'hu:media-annotation:w00-label-front-supplement-facts'})
ON CREATE SET m.id = 'w00-label-front-supplement-facts', m.artifactType = 'MediaAnnotation', m.name = 'Supplement Facts panel crop',
  m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-01-01T00:00:00Z'), m.updatedAt = datetime('2026-01-01T00:00:00Z');

UNWIND [
  {uid: 'hu:locator:w00-region-with-edge', id: 'w00-region-with-edge', edge: true},
  {uid: 'hu:locator:w00-region-without-edge', id: 'w00-region-without-edge', edge: false}
] AS row
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-loc-label-photo-2026-01-01'}), (m:MediaAnnotation {uid: 'hu:media-annotation:w00-label-front-supplement-facts'})
MERGE (l:SourceLocator:InformationArtifact {uid: row.uid})
ON CREATE SET l.id = row.id, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'IMAGE_REGION', l.mediaAnnotationUid = m.uid,
  l.normalizationVersion = 'IMG-PX1', l.privacyClass = 'PUBLIC', l.createdAt = s.createdAt, l.updatedAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l)
FOREACH (_ IN CASE WHEN row.edge THEN [1] ELSE [] END | MERGE (l)-[:LOCATES_REGION]->(m));

// Re-anchoring: the same quote found in a later capture of the base page (newer -> older, EXACT).
MATCH (src:Source {uid: 'hu:source:w00-neg-page'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-loc-page-2026-02-01'})
ON CREATE SET s.id = 'w00-loc-page-2026-02-01', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-02-01T00:00:00Z'), s.observedAt = datetime('2026-02-01T00:00:00Z'),
  s.contentHash = 'sha256:8cfbb1d10db2f60f0fa70029d0da2eedfda8a9a91ba2db789ce5fbf81edf739b', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-02-01T00:00:00Z'), s.updatedAt = datetime('2026-02-01T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-loc-page-2026-02-01'}), (old:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-neg-quote-reanchored-2026-02-01'})
ON CREATE SET l.id = 'w00-neg-quote-reanchored-2026-02-01', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
  l.exact = old.exact, l.quoteHash = old.quoteHash, l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC',
  l.createdAt = datetime('2026-02-01T00:10:00Z'), l.updatedAt = datetime('2026-02-01T00:10:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[x:REANCHORS]->(old)
ON CREATE SET x.anchorMatch = 'EXACT', x.activityUid = 'hu:activity:w00-neg-extraction';

// Two defective locators on the base snapshot: offsets without a text version, and a migrated untyped selector.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-neg-2026-01-01'})
MERGE (l1:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-offsets-without-text-version'})
ON CREATE SET l1.id = 'w00-offsets-without-text-version', l1.artifactType = 'SourceLocator', l1.uri = s.canonicalUri, l1.selectorKind = 'TEXT_POSITION',
  l1.startOffset = 120, l1.endOffset = 161, l1.exact = 'We both take a gram of NMN every morning.',
  l1.quoteHash = 'sha256:c79a0d7437fabe69a92f5753554bad7663fb34eab203c8cbc231529bb8559525', l1.normalizationVersion = 'NFC-WS1',
  l1.privacyClass = 'PUBLIC', l1.createdAt = s.createdAt, l1.updatedAt = s.createdAt
MERGE (l2:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-legacy-untyped'})
ON CREATE SET l2.id = 'w00-legacy-untyped', l2.artifactType = 'SourceLocator', l2.uri = s.canonicalUri, l2.selector = '{"t":"quote+time","q":"a gram","ts":"1:07:37"}',
  l2.privacyClass = 'PUBLIC', l2.createdAt = s.createdAt, l2.updatedAt = s.createdAt
MERGE (s)-[:HAS_LOCATOR]->(l1)
MERGE (s)-[:HAS_LOCATOR]->(l2);

// Assertions: one backed by the annotated image region (valid), one resting only on the two defective locators (V-401).
UNWIND [
  {uid: 'hu:assertion:w00-label-declares-mg', id: 'w00-label-declares-mg', locs: ['hu:locator:w00-region-with-edge']},
  {uid: 'hu:assertion:w00-rests-on-legacy-locators', id: 'w00-rests-on-legacy-locators', locs: ['hu:locator:w00-offsets-without-text-version', 'hu:locator:w00-legacy-untyped']}
] AS row
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (act:Activity {uid: 'hu:activity:w00-neg-extraction'})
MERGE (a:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = 'DECLARES_AMOUNT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueNumber = 250.0, a.unitCode = 'mg',
  a.quantityBasis = 'PER_SERVING', a.massBasis = 'UNSPECIFIED', a.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', a.recordedAt = datetime('2026-02-01T01:00:00Z'),
  a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-02-01T01:00:00Z'), a.updatedAt = datetime('2026-02-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
WITH a, row
UNWIND row.locs AS lu
MATCH (l:SourceLocator {uid: lu})
MERGE (a)-[:SUPPORTED_BY]->(l);

UNWIND ['hu:assertion:w00-label-declares-mg', 'hu:assertion:w00-rests-on-legacy-locators'] AS au
MATCH (a:Assertion {uid: au})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:' + a.id + '-cf'})
ON CREATE SET j.id = a.id + '-cf', j.assessmentType = 'Adjudication', j.methodVersion = 'w00-review-v1', j.status = 'ACCEPTED',
  j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = datetime('2026-02-01T02:00:00Z'),
  j.recordedAt = datetime('2026-02-01T02:00:00Z'), j.privacyClass = 'INTERNAL', j.createdAt = datetime('2026-02-01T02:00:00Z'), j.updatedAt = datetime('2026-02-01T02:00:00Z')
MERGE (j)-[:EVALUATES]->(a);
