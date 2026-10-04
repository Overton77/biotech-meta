// W00 fixture 13 -- reconciliation-pass rulings exercised (SYNTHETIC_FIXTURE; load 00-common-base.cypher first).
// P1  W00-R-11 merge redirect: hu:org:w00-acme-b merged into hu:org:w00-acme-a on 2026-05-01 (SAME_IDENTITY_MERGED; retired node kept,
//     maturity DEPRECATED). Q13-a resolves the held uid as of 2026-04-10 (itself) and 2026-10-04 (the survivor).
// P2  W00-R-02 QUANTITY assertion with one object and one numeric literal (valid under V-003r, a row under frozen V-003).
// P3  W00-R-13 point-in-time statement with statedAsOf + precision (bounds stay null); Q13-b reads it.
// P5  W00-R-03 asserted HAS_IDENTIFIER edge whose qualifier isPrimary equals the assertion's stored isPrimary.
// P6  W00-R-08 sourceKind OTHER with sourceKindNote.
// Negatives (expected rows): N1 V-432r + V-W00-13 (redirect without retiredUid); N2 V-003r (ROLE assertion with object and literal);
// N3 V-503r (statedAsOf without precision); N4 V-W00-15 x3 (state cache on HAS_SNAPSHOT, retrieval MENTIONS, IDENTIFIED_BY);
// N5 V-505r QUALIFIER_DIFFERS:isPrimary; N6 V-W00-17; N7 V-W00-16 (token 'widget' on a Product); N8 V-W00-19 (doi.org canonicalUri);
// N9 V-521r (privacyClass 'PRIVATE_PERSONAL', missed by frozen V-521).
// Hashes: snapshots use sha256 over the snapshot uid (SYNTHETIC_FIXTURE); quoteHash is NFC-WS1 over `exact`.

UNWIND [
  {uid: 'hu:org:w00-acme-a', id: 'w00-acme-a', name: 'Acme Nutrition Inc. (synthetic)', maturity: 'ACCEPTED', created: '2026-02-01T00:00:00Z'},
  {uid: 'hu:org:w00-acme-b', id: 'w00-acme-b', name: 'Acme Nutrition, Inc. (synthetic duplicate record)', maturity: 'DEPRECATED', created: '2026-03-01T00:00:00Z'}
] AS row
MERGE (n:Organization:Entity {uid: row.uid})
ON CREATE SET n.id = row.id, n.entityType = 'Organization', n.name = row.name, n.maturity = row.maturity, n.privacyClass = 'PUBLIC',
  n.createdAt = datetime(row.created), n.updatedAt = datetime(row.created);

MERGE (src:Source:Entity {uid: 'hu:source:w00-r13-registry'})
ON CREATE SET src.id = 'w00-r13-registry', src.entityType = 'Source', src.canonicalUri = 'https://w00-r13.example.invalid/registry/acme',
  src.title = 'Synthetic company registry entry', src.sourceKind = 'OTHER', src.sourceKindNote = 'business registry extract (synthetic)',
  src.privacyClass = 'PUBLIC', src.createdAt = datetime('2026-02-01T00:00:00Z'), src.updatedAt = datetime('2026-02-01T00:00:00Z');

MATCH (src:Source {uid: 'hu:source:w00-r13-registry'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-r13-registry-2026-04-30'})
ON CREATE SET s.id = 'w00-r13-registry-2026-04-30', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-04-30T00:00:00Z'), s.observedAt = datetime('2026-04-30T00:00:00Z'), s.publishedAt = datetime('2025-04-29T00:00:00Z'),
  s.contentHash = 'sha256:dd5ab868ad9d0261a885fd50d573239ec20d1d30aac7b48497643e3bb73365e4', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-04-30T00:00:00Z'), s.updatedAt = datetime('2026-04-30T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

UNWIND [
  {uid: 'hu:locator:w00-r13-same-company', id: 'w00-r13-same-company', exact: 'Acme Nutrition Inc. and Acme Nutrition, Inc. are the same company.', h: 'sha256:c7ddacb0f21c84ee8e5f18c9f6d9d0d36f7ca299e315dc135eb8cfd7a9408f9a'},
  {uid: 'hu:locator:w00-r13-moiety', id: 'w00-r13-moiety', exact: 'Each capsule provides 263 mg of nicotinamide riboside.', h: 'sha256:bd973392eb7eb544ace20bf1d15fc9b40e9ae097128e895a29d7703b9a500dc6'},
  {uid: 'hu:locator:w00-r13-holding', id: 'w00-r13-holding', exact: 'As of August 20, 2024, the holder beneficially owned 1,000 shares.', h: 'sha256:38ef0e5becebe2d874904812847eb2d44ec9fc8c5f5877963d423c6c5571e5c1'}
] AS row
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-r13-registry-2026-04-30'})
MERGE (l:SourceLocator:InformationArtifact {uid: row.uid})
ON CREATE SET l.id = row.id, l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact,
  l.quoteHash = row.h, l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC',
  l.createdAt = datetime('2026-04-30T00:00:00Z'), l.updatedAt = datetime('2026-04-30T00:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// P1: the merge redirect (W00-R-11).
MATCH (a:Organization {uid: 'hu:org:w00-acme-a'})
MATCH (b:Organization {uid: 'hu:org:w00-acme-b'})
MATCH (l:SourceLocator {uid: 'hu:locator:w00-r13-same-company'})
MERGE (e:EquivalenceAssessment:EvidenceAssessment {uid: 'hu:assessment:w00-merge-acme'})
ON CREATE SET e.id = 'w00-merge-acme', e.assessmentType = 'EquivalenceAssessment', e.methodVersion = 'w00-identity-merge-review-v1', e.status = 'ACCEPTED',
  e.equivalenceKind = 'SAME_IDENTITY_MERGED', e.survivingUid = a.uid, e.retiredUid = b.uid,
  e.rationale = 'Synthetic: the registry entry names both spellings as one company.', e.privacyClass = 'PUBLIC',
  e.recordedAt = datetime('2026-05-01T12:00:00Z'), e.createdAt = datetime('2026-05-01T12:00:00Z'), e.updatedAt = datetime('2026-05-01T12:00:00Z')
MERGE (e)-[:COMPARES_IDENTITIES]->(a)
MERGE (e)-[:COMPARES_IDENTITIES]->(b)
MERGE (e)-[:SUPPORTED_BY]->(l);

// N1: a redirect without retiredUid (V-432r, V-W00-13).
MATCH (a:Organization {uid: 'hu:org:w00-acme-a'})
MATCH (b:Organization {uid: 'hu:org:w00-acme-b'})
MERGE (e:EquivalenceAssessment:EvidenceAssessment {uid: 'hu:assessment:w00-merge-bad'})
ON CREATE SET e.id = 'w00-merge-bad', e.assessmentType = 'EquivalenceAssessment', e.methodVersion = 'w00-identity-merge-review-v1', e.status = 'ACCEPTED',
  e.equivalenceKind = 'SAME_IDENTITY_MERGED', e.survivingUid = a.uid, e.privacyClass = 'PUBLIC',
  e.recordedAt = datetime('2026-05-02T12:00:00Z'), e.createdAt = datetime('2026-05-02T12:00:00Z'), e.updatedAt = datetime('2026-05-02T12:00:00Z')
MERGE (e)-[:COMPARES_IDENTITIES]->(a)
MERGE (e)-[:COMPARES_IDENTITIES]->(b);

// P2: QUANTITY assertion, one object + one numeric literal (W00-R-02).
MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:w00-nr-chloride-300'})
ON CREATE SET c.id = 'w00-nr-chloride-300', c.stateType = 'IngredientComponent', c.name = 'NR chloride 300 mg (synthetic label row)', c.privacyClass = 'PUBLIC',
  c.createdAt = datetime('2026-04-30T00:00:00Z'), c.updatedAt = datetime('2026-04-30T00:00:00Z');

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:w00-nr-cation'})
ON CREATE SET n.id = 'w00-nr-cation', n.entityType = 'ChemicalSubstance', n.name = 'nicotinamide riboside (cation)', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-04-30T00:00:00Z'), n.updatedAt = datetime('2026-04-30T00:00:00Z');

MATCH (c:IngredientComponent {uid: 'hu:component:w00-nr-chloride-300'})
MATCH (m:ChemicalSubstance {uid: 'hu:substance:w00-nr-cation'})
MATCH (l:SourceLocator {uid: 'hu:locator:w00-r13-moiety'})
MATCH (o:Organization {uid: 'hu:org:w00-acme-a'})
MERGE (x:Assertion {uid: 'hu:assertion:w00-moiety-amount'})
ON CREATE SET x.id = 'w00-moiety-amount', x.predicate = 'ACTIVE_MOIETY_AMOUNT', x.predicateClass = 'QUANTITY', x.status = 'PROPOSED',
  x.valueNumber = 263.0, x.unitCode = 'mg', x.quantityBasis = 'PER_DOSE', x.massBasis = 'ACTIVE_MOIETY', x.amountReferent = 'LISTED_INGREDIENT_AS_LISTED',
  x.polarity = 'POSITIVE', x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC',
  x.recordedAt = datetime('2026-04-30T01:00:00Z'), x.createdAt = datetime('2026-04-30T01:00:00Z'), x.updatedAt = datetime('2026-04-30T01:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(c)
MERGE (x)-[:HAS_OBJECT]->(m)
MERGE (x)-[:ASSERTED_BY]->(o)
MERGE (x)-[:SUPPORTED_BY]->(l);

// N2: a ROLE assertion with an object AND a literal (V-003r; INV-003 unchanged outside QUANTITY).
MATCH (p:Person {uid: 'hu:person:w00-cohost-1'})
MATCH (o:Organization {uid: 'hu:org:w00-acme-a'})
MATCH (l:SourceLocator {uid: 'hu:locator:w00-r13-holding'})
MERGE (x:Assertion {uid: 'hu:assertion:w00-role-with-literal'})
ON CREATE SET x.id = 'w00-role-with-literal', x.predicate = 'EMPLOYED_BY', x.predicateClass = 'ROLE', x.status = 'PROPOSED', x.valueString = 'Chief Scientist',
  x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC',
  x.recordedAt = datetime('2026-04-30T01:00:00Z'), x.createdAt = datetime('2026-04-30T01:00:00Z'), x.updatedAt = datetime('2026-04-30T01:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(p)
MERGE (x)-[:HAS_OBJECT]->(o)
MERGE (x)-[:SUPPORTED_BY]->(l);

// P3 / N3: point-in-time holding statements (W00-R-13). Bounds stay null with UNKNOWN basis.
UNWIND [
  {uid: 'hu:assertion:w00-holding-as-of', id: 'w00-holding-as-of', prec: 'DAY'},
  {uid: 'hu:assertion:w00-holding-as-of-no-precision', id: 'w00-holding-as-of-no-precision', prec: null}
] AS row
MATCH (p:Person {uid: 'hu:person:w00-cohost-2'})
MATCH (o:Organization {uid: 'hu:org:w00-acme-a'})
MATCH (l:SourceLocator {uid: 'hu:locator:w00-r13-holding'})
MERGE (x:Assertion {uid: row.uid})
ON CREATE SET x.id = row.id, x.predicate = 'HOLDS_EQUITY_IN', x.predicateClass = 'COMMERCIAL', x.status = 'PROPOSED',
  x.statedAsOf = datetime('2024-08-20T00:00:00Z'), x.statedAsOfPrecision = row.prec, x.roleTitleVerbatim = 'beneficially owned 1,000 shares',
  x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC',
  x.recordedAt = datetime('2026-04-30T01:00:00Z'), x.createdAt = datetime('2026-04-30T01:00:00Z'), x.updatedAt = datetime('2026-04-30T01:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(p)
MERGE (x)-[:HAS_OBJECT]->(o)
MERGE (x)-[:SUPPORTED_BY]->(l);

// P5 / N5: HAS_IDENTIFIER episodes; the assertion stores the qualifier isPrimary (W00-R-03).
MERGE (i:Identifier:Entity {uid: 'hu:identifier:w00-acme-reg-no'})
ON CREATE SET i.id = 'w00-acme-reg-no', i.entityType = 'Identifier', i.scheme = 'SYNTHETIC-REGISTRY', i.issuer = 'w00-synthetic-registry', i.value = 'R-0001',
  i.privacyClass = 'PUBLIC', i.createdAt = datetime('2026-04-30T00:00:00Z'), i.updatedAt = datetime('2026-04-30T00:00:00Z');

UNWIND [
  {a: 'hu:assertion:w00-acme-a-has-reg', aid: 'w00-acme-a-has-reg', org: 'hu:org:w00-acme-a', rel: 'hu:rel:w00-acme-a-has-reg', edgePrimary: true},
  {a: 'hu:assertion:w00-acme-b-has-reg', aid: 'w00-acme-b-has-reg', org: 'hu:org:w00-acme-b', rel: 'hu:rel:w00-acme-b-has-reg', edgePrimary: false}
] AS row
MATCH (o:Organization {uid: row.org})
MATCH (i:Identifier {uid: 'hu:identifier:w00-acme-reg-no'})
MATCH (l:SourceLocator {uid: 'hu:locator:w00-r13-same-company'})
MERGE (x:Assertion {uid: row.a})
ON CREATE SET x.id = row.aid, x.predicate = 'HAS_IDENTIFIER', x.predicateClass = 'IDENTITY', x.status = 'PROPOSED', x.isPrimary = true,
  x.validFromBasis = 'UNKNOWN', x.validToBasis = 'UNKNOWN', x.privacyClass = 'PUBLIC',
  x.recordedAt = datetime('2026-04-30T01:00:00Z'), x.createdAt = datetime('2026-04-30T01:00:00Z'), x.updatedAt = datetime('2026-04-30T01:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(o)
MERGE (x)-[:HAS_OBJECT]->(i)
MERGE (x)-[:SUPPORTED_BY]->(l)
MERGE (o)-[r:HAS_IDENTIFIER {relationshipUid: row.rel}]->(i)
ON CREATE SET r.assertionUid = row.a, r.isPrimary = row.edgePrimary, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
  r.recordedFrom = datetime('2026-04-30T01:00:00Z');

// N4: three legacy shapes that V-W00-15 reports (state cache on HAS_SNAPSHOT; retrieval MENTIONS; IDENTIFIED_BY).
MERGE (os:OrganizationSnapshot:VersionedState {uid: 'hu:org-snapshot:w00-acme-a-2026'})
ON CREATE SET os.id = 'w00-acme-a-2026', os.stateType = 'OrganizationSnapshot', os.legalName = 'Acme Nutrition Inc.', os.privacyClass = 'PUBLIC',
  os.createdAt = datetime('2026-04-30T00:00:00Z'), os.updatedAt = datetime('2026-04-30T00:00:00Z');

MATCH (o:Organization {uid: 'hu:org:w00-acme-a'})
MATCH (os:OrganizationSnapshot {uid: 'hu:org-snapshot:w00-acme-a-2026'})
MERGE (o)-[:HAS_SNAPSHOT]->(os);

MERGE (ch:Chunk:InformationArtifact {uid: 'hu:chunk:w00-r13-chunk-0'})
ON CREATE SET ch.id = 'w00-r13-chunk-0', ch.chunkId = 'w00-r13-chunk-0', ch.artifactType = 'Chunk', ch.text = 'Each capsule provides 263 mg of nicotinamide riboside.', ch.privacyClass = 'PUBLIC',
  ch.createdAt = datetime('2026-04-30T00:00:00Z'), ch.updatedAt = datetime('2026-04-30T00:00:00Z');

MATCH (ch:Chunk {uid: 'hu:chunk:w00-r13-chunk-0'})
MATCH (m:ChemicalSubstance {uid: 'hu:substance:w00-nr-cation'})
MERGE (ch)-[:MENTIONS {derivationRule: 'w00-synthetic-linker-v1'}]->(m);

MERGE (pv:ProductVariant:Entity {uid: 'hu:product-variant:w00-acme-nr-60'})
ON CREATE SET pv.id = 'w00-acme-nr-60', pv.entityType = 'ProductVariant', pv.name = 'Acme NR 60 capsules (synthetic)', pv.privacyClass = 'PUBLIC',
  pv.createdAt = datetime('2026-04-30T00:00:00Z'), pv.updatedAt = datetime('2026-04-30T00:00:00Z');

MERGE (t:TradeItemIdentifier:Identifier:Entity {uid: 'hu:trade-id:w00-gtin-synthetic'})
ON CREATE SET t.id = 'w00-gtin-synthetic', t.entityType = 'TradeItemIdentifier', t.scheme = 'GTIN', t.issuer = 'w00-synthetic-gs1', t.value = '00000000000000',
  t.privacyClass = 'PUBLIC', t.createdAt = datetime('2026-04-30T00:00:00Z'), t.updatedAt = datetime('2026-04-30T00:00:00Z');

MATCH (pv:ProductVariant {uid: 'hu:product-variant:w00-acme-nr-60'})
MATCH (t:TradeItemIdentifier {uid: 'hu:trade-id:w00-gtin-synthetic'})
MERGE (pv)-[:IDENTIFIED_BY]->(t);

// N6, N7, N8, N9: kind note missing, unregistered token, resolver canonicalUri, non-final privacy class spelling.
MERGE (n:Source:Entity {uid: 'hu:source:w00-r13-other-no-note'})
ON CREATE SET n.id = 'w00-r13-other-no-note', n.entityType = 'Source', n.canonicalUri = 'https://w00-r13.example.invalid/other', n.sourceKind = 'OTHER',
  n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-04-30T00:00:00Z'), n.updatedAt = datetime('2026-04-30T00:00:00Z');

MERGE (n:Product:Entity {uid: 'hu:widget:w00-r13-bad-token'})
ON CREATE SET n.id = 'w00-r13-bad-token', n.entityType = 'Product', n.name = 'Synthetic product with an unregistered uid token', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-04-30T00:00:00Z'), n.updatedAt = datetime('2026-04-30T00:00:00Z');

MERGE (n:Source:Entity {uid: 'hu:source:w00-r13-doi-resolver'})
ON CREATE SET n.id = 'w00-r13-doi-resolver', n.entityType = 'Source', n.canonicalUri = 'https://doi.org/10.0000/w00-synthetic', n.sourceKind = 'PEER_REVIEWED_PUBLICATION',
  n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-04-30T00:00:00Z'), n.updatedAt = datetime('2026-04-30T00:00:00Z');

MERGE (n:Person:Entity {uid: 'hu:person:w00-r13-leak-class'})
ON CREATE SET n.id = 'w00-r13-leak-class', n.entityType = 'Person', n.name = 'Synthetic person with a non-final privacy class', n.privacyClass = 'PRIVATE_PERSONAL',
  n.createdAt = datetime('2026-04-30T00:00:00Z'), n.updatedAt = datetime('2026-04-30T00:00:00Z');
