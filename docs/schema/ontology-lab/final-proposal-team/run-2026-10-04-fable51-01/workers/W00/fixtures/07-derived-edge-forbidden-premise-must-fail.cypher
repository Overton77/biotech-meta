// W00 fixture 07 — NEGATIVE: derived and projected edges citing a forbidden premise (INV-004, V-112; catalog forbiddenImplications
// [HOSTS_LISTING, SELLS_PRODUCT], [LISTS_OFFER, SELLS_PRODUCT], [ADVISES_ORGANIZATION, ENDORSES_PRODUCT]; QS-4a).
// Expected: V-112 returns 3 rows (e2 FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS; e3 CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE +
// FORBIDDEN_IMPLICATION_USED_AS_PREMISE; e4 the same two), V-W00-11 returns 1 row (e4 PREDICATE_DIFFERS_FROM_EDGE_TYPE,
// OBJECT_IS_NOT_EDGE_END); V-W00-02 returns no row (each edge carries one citation form). Positive control e1 (SELLS_PRODUCT
// derived from a SELLER_OF_RECORD_FOR assertion) returns no row.
// Load 00-common-base.cypher first. SYNTHETIC_FIXTURE.

UNWIND [
  {uid: 'hu:org:w00-brand-owner', id: 'w00-brand-owner', name: 'Synthetic brand owner'},
  {uid: 'hu:org:w00-marketplace', id: 'w00-marketplace', name: 'Synthetic marketplace'}
] AS row
MERGE (n:Organization:Entity {uid: row.uid})
ON CREATE SET n.id = row.id, n.entityType = 'Organization', n.name = row.name, n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

MERGE (n:ProductVariant:Entity {uid: 'hu:product-variant:w00-derived-variant'})
ON CREATE SET n.id = 'w00-derived-variant', n.entityType = 'ProductVariant', n.name = 'Synthetic variant', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

MERGE (n:Product:Entity {uid: 'hu:product:w00-derived-product'})
ON CREATE SET n.id = 'w00-derived-product', n.entityType = 'Product', n.name = 'Synthetic product', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

UNWIND [
  {uid: 'hu:assertion:w00-sor', id: 'w00-sor', pred: 'SELLER_OF_RECORD_FOR', s: 'hu:org:w00-brand-owner', o: 'hu:product-variant:w00-derived-variant'},
  {uid: 'hu:assertion:w00-hosts', id: 'w00-hosts', pred: 'HOSTS_LISTING', s: 'hu:org:w00-marketplace', o: 'hu:product-variant:w00-derived-variant'},
  {uid: 'hu:assertion:w00-lists-offer', id: 'w00-lists-offer', pred: 'LISTS_OFFER', s: 'hu:org:w00-marketplace', o: 'hu:product-variant:w00-derived-variant'},
  {uid: 'hu:assertion:w00-advises', id: 'w00-advises', pred: 'ADVISES_ORGANIZATION', s: 'hu:person:w00-cohost-1', o: 'hu:org:w00-brand-owner'}
] AS row
MATCH (s {uid: row.s}), (o {uid: row.o}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'})
MERGE (a:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = row.pred, a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-01-01T02:00:00Z'),
  a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-01-01T02:00:00Z'), a.updatedAt = datetime('2026-01-01T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// e1 positive control: rule-derived from the seller-of-record assertion.
MATCH (o:Organization {uid: 'hu:org:w00-brand-owner'}), (v:ProductVariant {uid: 'hu:product-variant:w00-derived-variant'})
MERGE (o)-[r:SELLS_PRODUCT {derivationRule: 'sells-product/v1'}]->(v)
ON CREATE SET r.derivedFromAssertionUids = ['hu:assertion:w00-sor'], r.derivedAt = datetime('2026-01-01T03:00:00Z');

// e2: rule-derived from a hosting assertion (forbidden premise among inputs).
MATCH (o:Organization {uid: 'hu:org:w00-marketplace'}), (v:ProductVariant {uid: 'hu:product-variant:w00-derived-variant'})
MERGE (o)-[r:SELLS_PRODUCT {derivationRule: 'sells-product/v1'}]->(v)
ON CREATE SET r.derivedFromAssertionUids = ['hu:assertion:w00-hosts'], r.derivedAt = datetime('2026-01-01T03:00:00Z');

// e3: 1:1 projection citing a LISTS_OFFER assertion.
MATCH (o:Organization {uid: 'hu:org:w00-marketplace'}), (v:ProductVariant {uid: 'hu:product-variant:w00-derived-variant'})
MERGE (o)-[r:SELLS_PRODUCT {projectionOfAssertionUid: 'hu:assertion:w00-lists-offer'}]->(v)
ON CREATE SET r.derivedAt = datetime('2026-01-01T03:00:00Z');

// e4: an ENDORSES_PRODUCT edge whose authority is an ADVISES_ORGANIZATION assertion (V-007 / V-112).
MATCH (p:Person {uid: 'hu:person:w00-cohost-1'}), (pr:Product {uid: 'hu:product:w00-derived-product'})
MERGE (p)-[r:ENDORSES_PRODUCT {relationshipUid: 'hu:rel:w00-endorses-from-advises'}]->(pr)
ON CREATE SET r.assertionUid = 'hu:assertion:w00-advises', r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN',
  r.recordedFrom = datetime('2026-01-01T03:00:00Z');
