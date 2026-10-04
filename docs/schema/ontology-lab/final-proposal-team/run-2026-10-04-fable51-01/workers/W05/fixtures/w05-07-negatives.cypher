// =====================================================================================================================
// W05 fixture 07: deliberate violations. Load after 01-06 into a scratch database. Each block names the validation
// id it must trip (w05-validation.cypher). None of these shapes is allowed in production.
// =====================================================================================================================

// N1 -> V-W05-01: a second identity for a marketed food (FoodProduct label kept beside Product).
MERGE (n:FoodProduct:Product:Entity {uid: 'hu:product:neg-w05-duplicate-food-product'})
SET n.entityType = 'Product', n.name = 'Synthetic Grove Brazil Nuts 16 oz (duplicate)', n.createdAt = datetime('2026-10-04T03:00:00Z');

// N2 -> V-W05-06: an Exposure used as a person's exposure occurrence.
MATCH (p:Person {uid: 'hu:person:synthetic-guest-w05'})
MERGE (x:Exposure:Entity {uid: 'hu:exposure:neg-w05-guest-sauna-history'})
SET x.id = 'neg-w05-guest-sauna-history', x.entityType = 'Exposure', x.route = 'EXTERNAL_PHYSICAL', x.startedAt = datetime('2026-01-01T00:00:00Z'), x.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (x)-[:EXPOSED_PERSON]->(p);

// N3 -> V-W05-03: intensity without unit or basis.  N4 -> V-W05-04: no agent.
MERGE (x:Exposure:Entity {uid: 'hu:exposure:neg-w05-intensity-no-unit'})
SET x.id = 'neg-w05-intensity-no-unit', x.entityType = 'Exposure', x.route = 'ORAL', x.intensityValue = 2.0, x.createdAt = datetime('2026-10-04T03:00:00Z');

// N5 -> V-423 and V-W05-09: a practice report projected as a recommendation.
MATCH (p:Person {uid: 'hu:person:synthetic-guest-w05'}), (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'})
MERGE (p)-[r:RECOMMENDS]->(lf)
SET r.assertionUid = 'hu:claim-occurrence:synthetic-w05-guest-reports-sauna', r.derivationRule = 'bad-projection';

// N6 -> V-W05-07: an underived zero projected as a composition edge.
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (d:ChemicalSubstance {uid: 'hu:substance:docosahexaenoic-acid'})
MERGE (f)-[r:QUANTITATIVELY_CONTAINS]->(d)
SET r.relationshipUid = 'hu:rel:neg-w05-dha', r.assertionUid = 'hu:assertion:fdc-170569-dha-zero-underived', r.quantity = 0.0, r.unitCode = 'g', r.basis = 'PER_100_G';

// N7 -> V-W05-10: a protocol step turned into a characterized exposure.
MATCH (st:ProtocolStep {uid: 'hu:protocol-step:synthetic-brazil-nut-daily-eat-two'}), (e:Exposure {uid: 'hu:exposure:selenium-oral-chronic-dietary'})
MERGE (st)-[:CHARACTERIZED_AS_EXPOSURE]->(e);

// N8 -> V-W05-11: legacy INVOLVES left on an Exposure.
MATCH (e:Exposure {uid: 'hu:exposure:selenium-dietary-high-se-area-adult-male-1438ugd'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (e)-[:INVOLVES]->(f);

// N9 -> V-W05-12: product identity collapsed into the food (GTIN on a FoodItem).
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (t:TradeItemIdentifier:Entity {uid: 'hu:trade-id:neg-w05-gtin'})
SET t.entityType = 'TradeItemIdentifier', t.scheme = 'GTIN', t.value = '00000000000000', t.createdAt = datetime('2026-10-04T03:00:00Z')
MERGE (f)-[:IDENTIFIED_BY]->(t);

// N10 -> V-W05-05: food group without its category system.  N11 -> V-W05-08: unasserted VARIANT_OF.  N12 -> V-W05-02: FoodItem without the IngredientMaterial label.
MERGE (f:FoodItem:Entity {uid: 'hu:food:neg-w05-roasted-peanut'})
SET f.id = 'neg-w05-roasted-peanut', f.entityType = 'FoodItem', f.foodGroup = 'Legumes and Legume Products', f.createdAt = datetime('2026-10-04T03:00:00Z');

MATCH (v:FoodItem {uid: 'hu:food:neg-w05-roasted-peanut'}), (b:FoodItem {uid: 'hu:material:food-peanut'})
MERGE (v)-[r:VARIANT_OF]->(b)
SET r.variantKind = 'PREPARATION';
