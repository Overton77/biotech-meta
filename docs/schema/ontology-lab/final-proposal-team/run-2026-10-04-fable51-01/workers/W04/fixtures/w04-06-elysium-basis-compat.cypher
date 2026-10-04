// W04 fixture 06 -- compatibility backfill for ../../../../../../examples/elysium-basis.cypher (the 0.1.0 compatibility fixture).
// elysium-basis.cypher stays loadable unchanged. This companion shows the 0.1.0 -> final migration for its W04 nodes: archetype interface
// fields (entityType, stateType, payloadHash, artifactType), amountReferent and massBasis on the two components (label lines name the salt
// for NR and the material as-is for PT), the serving of the current formulation, and the projected HAS_VARIANT / HAS_FORMULATION_VERSION
// episodes that 0.1.0 stored only as assertions. Load AFTER elysium-basis.cypher. Run on 2026-10-04 (see 06-fixtures-and-queries.md).
// The episodes carry recordedFrom = the authorizing assertion's recordedAt (V-504) and OBSERVATION_ONLY / UNKNOWN bases: the 0.1.0
// assertions carry no bounds.

MATCH (p:Product {uid: 'hu:product:elysium-basis'}) SET p.entityType = 'Product', p.privacyClass = coalesce(p.privacyClass, 'PUBLIC');
MATCH (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}) SET v.entityType = 'ProductVariant', v.privacyClass = coalesce(v.privacyClass, 'PUBLIC');
MATCH (ls:LabelSnapshot {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'}) SET ls.artifactType = 'LabelSnapshot', ls.privacyClass = coalesce(ls.privacyClass, 'PUBLIC');
MATCH (d:LabelDeclaration {uid: 'hu:label-declaration:basis-current-nr'})
SET d.artifactType = 'LabelDeclaration', d.declarationKind = 'OTHER_DIETARY_INGREDIENT', d.privacyClass = coalesce(d.privacyClass, 'PUBLIC');
// declarationKind DIETARY_INGREDIENT (0.1.0) -> OTHER_DIETARY_INGREDIENT: NR chloride has no RDI/DRV, so it is a 101.36(b)(3) ingredient.

MATCH (fv:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'})
SET fv.stateType = 'FormulationVersion', fv.privacyClass = coalesce(fv.privacyClass, 'PUBLIC'),
    fv.payloadHash = coalesce(fv.payloadHash, 'sha256:dfeaa66c9d70d9f855fd48c91a0faa27bc397667a8a54436bb836fe72e16c0f1');

UNWIND [
  {c: 'hu:component:basis-current-nr-e', mb: 'SALT_FORM', cph: 'sha256:42dcd8e1fb3e8ae3d289eb157191842689f79477e0fcd2bef585226b33382d14'},
  {c: 'hu:component:basis-current-pt', mb: 'MATERIAL_AS_IS', cph: 'sha256:89a75a6a776b3e52d296dcf7c365866240d8760ae9fe8d6250ac5db3ffce4dde'}
] AS r
MATCH (c:IngredientComponent {uid: r.c})
SET c.stateType = 'IngredientComponent', c.massBasis = coalesce(c.massBasis, r.mb), c.amountReferent = coalesce(c.amountReferent, 'LISTED_INGREDIENT_AS_LISTED'),
    c.isDietaryIngredient = coalesce(c.isDietaryIngredient, true), c.payloadHash = coalesce(c.payloadHash, r.cph),
    c.privacyClass = coalesce(c.privacyClass, 'PUBLIC');

MERGE (sd:ServingDefinition:VersionedState {uid: 'hu:serving-definition:basis-2-vegetarian-capsules'})
ON CREATE SET sd.stateType = 'ServingDefinition', sd.servingCount = 2.0, sd.unitDescription = 'Vegetarian Capsules',
    sd.payloadHash = 'sha256:612499a01e47afaf7b9eca9c257411dd070902de6c589c58abf4448a61f37a34', sd.privacyClass = 'PUBLIC', sd.createdAt = datetime('2026-10-04T01:10:00Z');

MATCH (fv:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}), (sd:ServingDefinition {uid: 'hu:serving-definition:basis-2-vegetarian-capsules'})
MERGE (fv)-[u:USES_SERVING_DEFINITION]->(sd) ON CREATE SET u.orderIndex = 1;

MATCH (a:Assertion {uid: 'hu:assertion:basis-has-us-variant-2026-07-10'})-[:HAS_SUBJECT]->(p:Product), (a)-[:HAS_OBJECT]->(v:ProductVariant)
MERGE (p)-[e:HAS_VARIANT {relationshipUid: 'hu:rel:basis-has-us-variant-2026-07-10'}]->(v)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

MATCH (a:Assertion {uid: 'hu:assertion:basis-variant-current-formulation-2026-07-10'})-[:HAS_SUBJECT]->(v:ProductVariant), (a)-[:HAS_OBJECT]->(fv:FormulationVersion)
MERGE (v)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:basis-variant-current-formulation-2026-07-10'}]->(fv)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.jurisdiction = 'US';

// The 0.1.0 label snapshot had no LABEL_FOR target (V-W04-09). Backfilled as a PROPOSED assertion with its projected edge.
MATCH (ls:LabelSnapshot {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'}), (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}),
      (l:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (a:Assertion {uid: 'hu:assertion:elysium-basis-label-2026-07-10-label-for-variant'})
SET a.predicate = 'LABEL_FOR', a.status = 'PROPOSED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:20:00Z'), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN',
    a.contentHash = 'synthetic:elysium-basis-label-2026-07-10-label-for-variant', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ls)
MERGE (a)-[:HAS_OBJECT]->(v)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (ls)-[e:LABEL_FOR {relationshipUid: 'hu:rel:elysium-basis-label-2026-07-10-label-for-variant'}]->(v)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN';
