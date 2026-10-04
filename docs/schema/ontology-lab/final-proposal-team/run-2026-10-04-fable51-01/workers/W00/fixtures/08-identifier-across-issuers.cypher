// W00 fixture 08 — an identifier VALUE shared across issuers must not merge identities
// ([SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY]; CQ-ID-04, CQ-AX-14). SYNTHETIC_FIXTURE.
// Two suppliers each print catalog number "NR-100" for DIFFERENT materials. The Identifier natural key is (scheme, issuer, value),
// so they are two Identifier nodes; each HAS_IDENTIFIER assignment is an asserted edge authorized by its own Assertion.
// A third-party page mentions "NR-100" without naming the supplier: the mention gets two competing ResolutionHypotheses,
// and an EquivalenceAssessment records that the two materials are NOT_EQUIVALENT (it never merges them).
// Statement 'F08-dup' deliberately violates the uniqueness constraint and MUST fail with a constraint error.
// Token note: 'mention' is not yet in conventions.uidTypeTokens (requested in W00-SR-09).

UNWIND [
  {uid: 'hu:material:w00-supplier-a-nr', id: 'w00-supplier-a-nr', name: 'Supplier A nicotinamide riboside chloride, grade X'},
  {uid: 'hu:material:w00-supplier-b-nr', id: 'w00-supplier-b-nr', name: 'Supplier B nicotinamide riboside (unrelated grade)'}
] AS row
MERGE (n:IngredientMaterial:Entity {uid: row.uid})
ON CREATE SET n.id = row.id, n.entityType = 'IngredientMaterial', n.name = row.name, n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-02-01T00:00:00Z'), n.updatedAt = datetime('2026-02-01T00:00:00Z');

UNWIND [
  {src: 'hu:source:w00-supplier-a-catalog', sid: 'w00-supplier-a-catalog', uri: 'https://supplier-a.example.invalid/catalog/nr-100',
   snap: 'hu:snapshot:w00-ids-a', snid: 'w00-ids-a', h: 'sha256:ef02a692eaa146d999c7fba69ed5224a7ba9094420587f02eff281bdbc3a522a',
   loc: 'hu:locator:w00-ids-a-catno', lid: 'w00-ids-a-catno'},
  {src: 'hu:source:w00-supplier-b-catalog', sid: 'w00-supplier-b-catalog', uri: 'https://supplier-b.example.invalid/products/NR-100',
   snap: 'hu:snapshot:w00-ids-b', snid: 'w00-ids-b', h: 'sha256:52df57ce7bb2d6b29279ae607f8dedadcc9f4bae092c84e3a5bef54d9d23b641',
   loc: 'hu:locator:w00-ids-b-catno', lid: 'w00-ids-b-catno'}
] AS row
MERGE (src:Source:Entity {uid: row.src})
ON CREATE SET src.id = row.sid, src.entityType = 'Source', src.canonicalUri = row.uri, src.sourceKind = 'ORGANIZATION_WEBPAGE', src.privacyClass = 'PUBLIC',
  src.createdAt = datetime('2026-02-01T00:00:00Z'), src.updatedAt = datetime('2026-02-01T00:00:00Z')
MERGE (s:SourceSnapshot:InformationArtifact {uid: row.snap})
ON CREATE SET s.id = row.snid, s.artifactType = 'SourceSnapshot', s.canonicalUri = row.uri, s.retrievedAt = datetime('2026-02-01T00:00:00Z'),
  s.observedAt = datetime('2026-02-01T00:00:00Z'), s.contentHash = row.h, s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'PARTIAL_EXCERPT',
  s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-02-01T00:00:00Z'), s.updatedAt = datetime('2026-02-01T00:00:00Z')
MERGE (l:SourceLocator:InformationArtifact {uid: row.loc})
ON CREATE SET l.id = row.lid, l.artifactType = 'SourceLocator', l.uri = row.uri, l.selectorKind = 'TEXT_QUOTE', l.exact = 'Catalog No. NR-100',
  l.quoteHash = 'sha256:4d33eb4e21998538f55aaa5e751ede198224f47e257590ea1dff1d97b09d26a2', l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC',
  l.createdAt = datetime('2026-02-01T00:00:00Z'), l.updatedAt = datetime('2026-02-01T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:HAS_LOCATOR]->(l);

UNWIND [
  {uid: 'hu:identifier:w00-supplier-a-catno-nr-100', id: 'w00-supplier-a-catno-nr-100', issuer: 'Synthetic Supplier A Inc.'},
  {uid: 'hu:identifier:w00-supplier-b-catno-nr-100', id: 'w00-supplier-b-catno-nr-100', issuer: 'Synthetic Supplier B GmbH'}
] AS row
MERGE (i:Identifier:Entity {scheme: 'SUPPLIER_CATALOG_NUMBER', issuer: row.issuer, value: 'NR-100'})
ON CREATE SET i.uid = row.uid, i.id = row.id, i.entityType = 'Identifier', i.normalizationRule = 'uppercase-trim-v1', i.privacyClass = 'PUBLIC',
  i.createdAt = datetime('2026-02-01T00:00:00Z'), i.updatedAt = datetime('2026-02-01T00:00:00Z');

UNWIND [
  {a: 'hu:assertion:w00-a-has-catno', aid: 'w00-a-has-catno', m: 'hu:material:w00-supplier-a-nr', i: 'hu:identifier:w00-supplier-a-catno-nr-100', l: 'hu:locator:w00-ids-a-catno', ru: 'hu:rel:w00-a-has-catno'},
  {a: 'hu:assertion:w00-b-has-catno', aid: 'w00-b-has-catno', m: 'hu:material:w00-supplier-b-nr', i: 'hu:identifier:w00-supplier-b-catno-nr-100', l: 'hu:locator:w00-ids-b-catno', ru: 'hu:rel:w00-b-has-catno'}
] AS row
MATCH (m:IngredientMaterial {uid: row.m}), (i:Identifier {uid: row.i}), (l:SourceLocator {uid: row.l})
MERGE (a:Assertion {uid: row.a})
ON CREATE SET a.id = row.aid, a.predicate = 'HAS_IDENTIFIER', a.predicateClass = 'IDENTITY', a.polarity = 'POSITIVE', a.status = 'PROPOSED',
  a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-02-01T01:00:00Z'), a.privacyClass = 'PUBLIC',
  a.createdAt = datetime('2026-02-01T01:00:00Z'), a.updatedAt = datetime('2026-02-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(m)
MERGE (a)-[:HAS_OBJECT]->(i)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (m)-[r:HAS_IDENTIFIER {relationshipUid: row.ru}]->(i)
ON CREATE SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = a.recordedAt, r.isPrimary = true;

// F08-dup (NEGATIVE, must fail): a second writer creates Supplier A's identifier again under a new uid.
CREATE (:Identifier:Entity {uid: 'hu:identifier:w00-supplier-a-catno-dup', id: 'w00-supplier-a-catno-dup', entityType: 'Identifier',
  scheme: 'SUPPLIER_CATALOG_NUMBER', issuer: 'Synthetic Supplier A Inc.', value: 'NR-100', privacyClass: 'PUBLIC',
  createdAt: datetime('2026-02-01T02:00:00Z'), updatedAt: datetime('2026-02-01T02:00:00Z')});

// A third-party mention of "NR-100" (issuer not printed) and competing hypotheses (CQ-AX-14: candidates, never identity).
MERGE (src:Source:Entity {uid: 'hu:source:w00-forum-post'})
ON CREATE SET src.id = 'w00-forum-post', src.entityType = 'Source', src.canonicalUri = 'https://forum.example.invalid/t/123', src.sourceKind = 'THIRD_PARTY_DIRECTORY',
  src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-02-02T00:00:00Z'), src.updatedAt = datetime('2026-02-02T00:00:00Z')
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-forum-post-2026-02-02'})
ON CREATE SET s.id = 'w00-forum-post-2026-02-02', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-02-02T00:00:00Z'),
  s.observedAt = datetime('2026-02-02T00:00:00Z'), s.contentHash = 'sha256:9a199a3f8551174441dfde22236b04f0350bb011cd08a1225d0ce3a78cab8a63', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'PARTIAL_EXCERPT', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-02-02T00:00:00Z'), s.updatedAt = datetime('2026-02-02T00:00:00Z')
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-forum-nr-100'})
ON CREATE SET l.id = 'w00-forum-nr-100', l.artifactType = 'SourceLocator', l.uri = src.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
  l.exact = 'I switched to NR-100 last month.', l.quoteHash = 'sha256:9797eed9c833661a2f7c96fab443e436b944a708c7907fe75678928b03a7a831', l.normalizationVersion = 'NFC-WS1',
  l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-02-02T00:00:00Z'), l.updatedAt = datetime('2026-02-02T00:00:00Z')
MERGE (m:Mention:InformationArtifact {uid: 'hu:mention:w00-forum-nr-100'})
ON CREATE SET m.id = 'w00-forum-nr-100', m.artifactType = 'Mention', m.surfaceForm = 'NR-100', m.mentionKind = 'PRODUCT_OR_MATERIAL_CODE',
  m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-02-02T00:00:00Z'), m.updatedAt = datetime('2026-02-02T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:MENTIONS]->(m);

UNWIND [
  {uid: 'hu:resolution:w00-nr-100-is-supplier-a', id: 'w00-nr-100-is-supplier-a', target: 'hu:material:w00-supplier-a-nr'},
  {uid: 'hu:resolution:w00-nr-100-is-supplier-b', id: 'w00-nr-100-is-supplier-b', target: 'hu:material:w00-supplier-b-nr'}
] AS row
MATCH (m:Mention {uid: 'hu:mention:w00-forum-nr-100'}), (t:IngredientMaterial {uid: row.target})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: row.uid})
ON CREATE SET h.id = row.id, h.assessmentType = 'ResolutionHypothesis', h.methodVersion = 'w00-manual-resolution-v1', h.status = 'PROPOSED',
  h.resolutionType = 'MATERIAL_IDENTITY_OF_MENTION', h.resolutionStatus = 'UNRESOLVED', h.score = 0.5,
  h.rationale = 'Catalog number matches; the post names no supplier, and the value is issued by two suppliers.',
  h.recordedAt = datetime('2026-02-02T01:00:00Z'), h.privacyClass = 'INTERNAL', h.createdAt = datetime('2026-02-02T01:00:00Z'), h.updatedAt = datetime('2026-02-02T01:00:00Z')
MERGE (h)-[:RESOLVES_MENTION]->(m)
MERGE (h)-[:PROPOSES_MATCH]->(t);

MATCH (h1:ResolutionHypothesis {uid: 'hu:resolution:w00-nr-100-is-supplier-a'}), (h2:ResolutionHypothesis {uid: 'hu:resolution:w00-nr-100-is-supplier-b'})
MERGE (h1)-[:COMPETES_WITH]->(h2);

MATCH (m1:IngredientMaterial {uid: 'hu:material:w00-supplier-a-nr'}), (m2:IngredientMaterial {uid: 'hu:material:w00-supplier-b-nr'}),
      (l1:SourceLocator {uid: 'hu:locator:w00-ids-a-catno'}), (l2:SourceLocator {uid: 'hu:locator:w00-ids-b-catno'})
MERGE (e:EquivalenceAssessment:EvidenceAssessment {uid: 'hu:assessment:w00-supplier-a-vs-b-nr-100'})
ON CREATE SET e.id = 'w00-supplier-a-vs-b-nr-100', e.assessmentType = 'EquivalenceAssessment', e.methodVersion = 'w00-manual-equivalence-v1',
  e.status = 'ACCEPTED', e.equivalenceKind = 'NOT_EQUIVALENT', e.rationale = 'Same catalog-number string from two issuers; different grades and suppliers.',
  e.recordedAt = datetime('2026-02-02T02:00:00Z'), e.privacyClass = 'INTERNAL', e.createdAt = datetime('2026-02-02T02:00:00Z'), e.updatedAt = datetime('2026-02-02T02:00:00Z')
MERGE (e)-[:COMPARES_IDENTITIES]->(m1)
MERGE (e)-[:COMPARES_IDENTITIES]->(m2)
MERGE (e)-[:SUPPORTED_BY]->(l1)
MERGE (e)-[:SUPPORTED_BY]->(l2);
