// W05 constraint probe: run after operations.cypher and fixtures 01-06. Each write below must FAIL with a constraint error.
// P1 duplicate characterization (same tuple hash as E1, different uid) -> exposure_characterization_hash.
MERGE (e:Exposure:Entity {uid: 'hu:exposure:probe-duplicate-e1'})
SET e.id = 'probe-duplicate-e1', e.entityType = 'Exposure', e.characterizationHash = 'sha256:synthetic-exposure-tuple-e1';
// P2 duplicate uid on a second node -> lifestyle_uid.
CREATE (l:Lifestyle:Entity {uid: 'hu:lifestyle:sauna-bathing', entityType: 'Lifestyle'});
// P3 a FoodItem reusing a material uid with a second node -> material_uid.
CREATE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut', entityType: 'FoodItem'});
// P4 missing hash is NOT rejected on Community (uniqueness does not require presence): must SUCCEED; V-W05 audit / service catches it.
MERGE (e:Exposure:Entity {uid: 'hu:exposure:probe-no-hash'})
SET e.id = 'probe-no-hash', e.entityType = 'Exposure', e.route = 'ORAL';
