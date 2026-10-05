// W04 fixture 05 -- NEGATIVE cases (SYNTHETIC_FIXTURE). Load ALONE into an empty database (or after the positives) and run
// fixtures/w04-validation.cypher plus the named baseline V-queries: every case below must produce the violation row named in its comment.
// uids use the prefix hu:<token>:w04-neg- so rows are attributable.

// N01 -> V-004 and V-W04-02: a CONTAINS shortcut with no derivation (masquerades as history).
MERGE (p:Product:Entity {uid: 'hu:product:w04-neg-flat-contains'})
SET p.entityType = 'Product', p.name = 'Negative: flat contains', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:w04-neg-material-z'})
SET m.entityType = 'IngredientMaterial', m.name = 'Material Z', m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (p)-[:CONTAINS]->(m);

// N02 -> V-W04-02: CONTAINS derived from a study's USES_INTERVENTION_MATERIAL assertion (trial material is not current composition).
MERGE (p:Product:Entity {uid: 'hu:product:w04-neg-trial-derived-contains'})
SET p.entityType = 'Product', p.name = 'Negative: contains from trial material', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:w04-neg-trial-material'})
SET m.entityType = 'IngredientMaterial', m.name = 'Trial material as supplied', m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:w04-neg-uses-intervention-material'})
SET a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (p)-[c:CONTAINS]->(m)
SET c.derivationRule = 'contains-v1', c.derivedFromAssertionUids = ['hu:assertion:w04-neg-uses-intervention-material'];

// N03 -> V-005: a component that identifies no material.
MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:w04-neg-no-material'})
SET c.stateType = 'IngredientComponent', c.quantity = 10.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING', c.massBasis = 'UNSPECIFIED', c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED',
    c.payloadHash = 'sha256:5cc3811df4300a5c83f01bd7d170e156fa57f379370deac9487bb59cfe5e1100', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T03:00:00Z');

// N04 -> V-011: a label declaration collapsed with a measured result.
MERGE (n:LabelDeclaration:MeasuredResult:InformationArtifact {uid: 'hu:label-declaration:w04-neg-declaration-as-measurement'})
SET n.artifactType = 'LabelDeclaration', n.verbatimText = 'Ingredient Q 100 mg', n.value = 100.0, n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T03:00:00Z');

// N05 -> V-330: a label quantity declaration carrying a calculated referent.
MERGE (q:QuantityDeclaration:InformationArtifact {uid: 'hu:quantity-declaration:w04-neg-active-moiety-on-label'})
SET q.artifactType = 'QuantityDeclaration', q.value = 219.51, q.unitCode = 'mg', q.amountReferent = 'ACTIVE_MOIETY', q.privacyClass = 'PUBLIC', q.createdAt = datetime('2026-10-04T03:00:00Z');

// N06 -> V-W04-04: an active-moiety amount that is not CALCULATED and has no derivation inputs (listed amount copied as moiety amount).
MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:w04-neg-moiety-copied'})
SET c.stateType = 'IngredientComponent', c.quantity = 250.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING', c.massBasis = 'SALT_FORM', c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED',
    c.payloadHash = 'sha256:bd3b09e395b170e4f95e80a32f64626a6f3f94518e5a24617b21141cf4a4f1e7', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:w04-neg-moiety-copied'})
SET a.predicate = 'ACTIVE_MOIETY_AMOUNT', a.status = 'PROPOSED', a.basisKind = 'DIRECT_MEASUREMENT', a.valueNumber = 250.0, a.unitCode = 'mg', a.recordedAt = datetime('2026-10-04T03:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(c);

// N07 -> V-322 and V-W04-03: marketed product displayed as APPROVED with an approval year and no APPROVAL status.
MERGE (p:Product:Entity {uid: 'hu:product:w04-neg-marketed-as-approved'})
SET p.entityType = 'Product', p.name = 'Negative: marketed is not approved', p.status = 'APPROVED', p.approvedYear = 2024, p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T03:00:00Z');

// N08 -> V-508: two definite, overlapping, currently recorded formulation episodes for one variant and jurisdiction.
MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:w04-neg-overlap'})
SET v.entityType = 'ProductVariant', v.jurisdiction = 'US', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (f1:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-neg-overlap-1'})
SET f1.stateType = 'FormulationVersion', f1.jurisdiction = 'US', f1.payloadHash = 'sha256:4d2bb0f7a2c5f15eeee6311de2af6df4a6c11d213ffa1cc7d5e6e362a11829cc', f1.privacyClass = 'PUBLIC', f1.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (f2:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-neg-overlap-2'})
SET f2.stateType = 'FormulationVersion', f2.jurisdiction = 'US', f2.payloadHash = 'sha256:84fb454caf3f9262b26510de395f87a407fd39a12a9eba1027667ae43406450f', f2.privacyClass = 'PUBLIC', f2.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (v)-[e1:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w04-neg-overlap-1'}]->(f1)
SET e1.assertionUid = 'hu:assertion:w04-neg-overlap-1', e1.recordedFrom = datetime('2026-10-04T03:00:00Z'), e1.validFrom = datetime('2025-01-01T00:00:00Z'), e1.validFromPrecision = 'DAY',
    e1.validFromBasis = 'STATED_BY_SOURCE', e1.validTo = datetime('2026-01-01T00:00:00Z'), e1.validToPrecision = 'DAY', e1.validToBasis = 'STATED_BY_SOURCE', e1.jurisdiction = 'US'
MERGE (v)-[e2:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w04-neg-overlap-2'}]->(f2)
SET e2.assertionUid = 'hu:assertion:w04-neg-overlap-2', e2.recordedFrom = datetime('2026-10-04T03:00:00Z'), e2.validFrom = datetime('2025-06-01T00:00:00Z'), e2.validFromPrecision = 'DAY',
    e2.validFromBasis = 'STATED_BY_SOURCE', e2.validTo = datetime('2026-06-01T00:00:00Z'), e2.validToPrecision = 'DAY', e2.validToBasis = 'STATED_BY_SOURCE', e2.jurisdiction = 'CA';
// e2 also carries jurisdiction CA while its target says US -> V-W04-08.

// N09 -> V-W04-07: a package-scoped serving (servings per container) used as a formulation's serving.
MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-neg-package-serving'})
SET f.stateType = 'FormulationVersion', f.jurisdiction = 'US', f.payloadHash = 'sha256:da718281bf027552eced39982183926586003615325694222a84b992313442ab', f.privacyClass = 'PUBLIC', f.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (s:ServingDefinition:VersionedState {uid: 'hu:serving-definition:w04-neg-30-servings'})
SET s.stateType = 'ServingDefinition', s.servingCount = 1.0, s.servingsPerContainer = 30.0, s.payloadHash = 'sha256:4432df5a140ffc149c74a77535d367fc15ead47541384c74f4829c8c30254add', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (f)-[:USES_SERVING_DEFINITION]->(s);

// N10 -> V-W04-05: a component quantity with no mass basis and no amount referent (salt vs moiety unknowable).
MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:w04-neg-no-basis'})
SET c.stateType = 'IngredientComponent', c.quantity = 300.0, c.unitCode = 'mg', c.payloadHash = 'sha256:f7b36a312dbabc55fde4a98a7d1055c0c9213ca3964d56761882af71de66379c', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T03:00:00Z');

// N11 -> V-W04-06: a package count written onto a formulation version (packaging conflated with composition).
MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-neg-count-on-formulation'})
SET f.stateType = 'FormulationVersion', f.unitCount = 90, f.jurisdiction = 'US', f.payloadHash = 'sha256:ccc6df9f400942e3634df14028af8d32e2e64dc098b3ac0f527d12192107c6a7', f.privacyClass = 'PUBLIC', f.createdAt = datetime('2026-10-04T03:00:00Z');

// N12 -> V-201 (INV-201): a study edge to a current variant.
MERGE (st:Study:Entity {uid: 'hu:study:w04-neg-study'})
SET st.entityType = 'Study', st.privacyClass = 'PUBLIC', st.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:w04-neg-studied-current'})
SET v.entityType = 'ProductVariant', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (st)-[:EVALUATES]->(v);

// N13 -> V-W04-01: a formulation attached to the enduring Product, and a label attached to the Product (wrong endpoints).
MERGE (p:Product:Entity {uid: 'hu:product:w04-neg-endpoint'})
SET p.entityType = 'Product', p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:w04-neg-on-product'})
SET f.stateType = 'FormulationVersion', f.payloadHash = 'sha256:2c1091f801c94c22d728edc9a3d0423156ca311f957f6336748c125a0b168f5e', f.privacyClass = 'PUBLIC', f.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (ls:LabelSnapshot:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w04-neg-label-on-product'})
SET ls.artifactType = 'LabelSnapshot', ls.contentHash = 'synthetic:w04-neg', ls.contentHashBasis = 'SYNTHETIC_FIXTURE', ls.retrievedAt = datetime('2026-10-04T03:00:00Z'), ls.privacyClass = 'PUBLIC', ls.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (p)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w04-neg-on-product'}]->(f)
SET e.assertionUid = 'hu:assertion:w04-neg-on-product', e.recordedFrom = datetime('2026-10-04T03:00:00Z'), e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
MERGE (ls)-[l:LABEL_FOR {relationshipUid: 'hu:rel:w04-neg-label-on-product'}]->(p)
SET l.assertionUid = 'hu:assertion:w04-neg-label-on-product', l.recordedFrom = datetime('2026-10-04T03:00:00Z'), l.validFromBasis = 'UNKNOWN', l.validToBasis = 'UNKNOWN';
