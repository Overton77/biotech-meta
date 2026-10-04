// W05 operations recommendation (Community-runnable part). Stored property names. Idempotent (IF NOT EXISTS).
// Enterprise-only existence constraints are listed at the end as comments; they are rejected by Community.
CREATE CONSTRAINT material_uid IF NOT EXISTS FOR (n:IngredientMaterial) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT exposure_uid IF NOT EXISTS FOR (n:Exposure) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT exposure_characterization_hash IF NOT EXISTS FOR (n:Exposure) REQUIRE n.characterizationHash IS UNIQUE;
CREATE CONSTRAINT lifestyle_uid IF NOT EXISTS FOR (n:Lifestyle) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT exposure_live_id IF NOT EXISTS FOR (n:Exposure) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT lifestyle_live_id IF NOT EXISTS FOR (n:Lifestyle) REQUIRE n.id IS UNIQUE;
CREATE FULLTEXT INDEX FoodItemSearch IF NOT EXISTS FOR (n:FoodItem) ON EACH [n.name, n.description, n.searchText, n.foodGroup];
CREATE FULLTEXT INDEX LifestyleSearch IF NOT EXISTS FOR (n:Lifestyle) ON EACH [n.name, n.description, n.searchText, n.lifestyleClass];
CREATE INDEX exposure_route_duration IF NOT EXISTS FOR (n:Exposure) ON (n.route, n.durationCategory);
CREATE INDEX qc_relationship_uid IF NOT EXISTS FOR ()-[r:QUANTITATIVELY_CONTAINS]-() ON (r.relationshipUid);
CREATE INDEX variant_of_relationship_uid IF NOT EXISTS FOR ()-[r:VARIANT_OF]-() ON (r.relationshipUid);
// Enterprise companion (not run here):
// CREATE CONSTRAINT exposure_hash_exists IF NOT EXISTS FOR (n:Exposure) REQUIRE n.characterizationHash IS NOT NULL;
// CREATE CONSTRAINT exposure_entity_type_exists IF NOT EXISTS FOR (n:Exposure) REQUIRE n.entityType IS NOT NULL;
// CREATE CONSTRAINT lifestyle_entity_type_exists IF NOT EXISTS FOR (n:Lifestyle) REQUIRE n.entityType IS NOT NULL;
