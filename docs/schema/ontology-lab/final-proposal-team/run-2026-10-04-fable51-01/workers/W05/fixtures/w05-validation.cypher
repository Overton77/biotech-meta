// W05 validation queries. Each returns rows only for violations. Read-only.

// V-W05-01: a marketed food carries the retired FoodProduct label (two identities for one product).
MATCH (n:FoodProduct)
RETURN 'V-W05-01' AS id, n.uid AS uid, labels(n) AS labels;

// V-W05-02: a FoodItem that is not also an IngredientMaterial, or whose uid token is not the IngredientMaterial token.
MATCH (f:FoodItem)
WHERE NOT f:IngredientMaterial OR NOT f.uid STARTS WITH 'hu:material:'
RETURN 'V-W05-02' AS id, f.uid AS uid, labels(f) AS labels;

// V-W05-03: an Exposure intensity without UCUM unit or basis.
MATCH (e:Exposure)
WHERE e.intensityValue IS NOT NULL AND (e.intensityUnitCode IS NULL OR e.intensityBasis IS NULL)
RETURN 'V-W05-03' AS id, e.uid AS uid, e.intensityValue AS value;

// V-W05-04: an Exposure without any agent.
MATCH (e:Exposure)
WHERE NOT (e)-[:HAS_EXPOSURE_AGENT]->()
RETURN 'V-W05-04' AS id, e.uid AS uid;

// V-W05-05: a source-scoped food category without the name of its category system.
MATCH (f:FoodItem)
WHERE f.foodGroup IS NOT NULL AND f.foodGroupSystem IS NULL
RETURN 'V-W05-05' AS id, f.uid AS uid, f.foodGroup AS foodGroup;

// V-W05-06: an Exposure used as an occurrence (occurrence clocks, or any edge to a person or cohort member).
MATCH (e:Exposure)
WHERE e.startedAt IS NOT NULL OR e.endedAt IS NOT NULL OR e.observedAt IS NOT NULL
   OR EXISTS { MATCH (e)--(p) WHERE p:Person OR p:CohortParticipant OR p:PseudonymousActor OR p:AnonymousActor OR p:PrivateRecord }
RETURN 'V-W05-06' AS id, e.uid AS uid;

// V-W05-07: a food composition edge whose zero or value has no stated derivation, or whose per-mass basis lacks its reference amount.
MATCH (f:FoodItem)-[r:QUANTITATIVELY_CONTAINS]->(x)
WHERE r.valueDerivation IS NULL
   OR (r.basis STARTS WITH 'PER_100' AND (r.referenceAmount IS NULL OR r.referenceUnitCode IS NULL))
RETURN 'V-W05-07' AS id, f.uid AS foodUid, x.uid AS targetUid, r.quantity AS quantity, r.relationshipUid AS rel;

// V-W05-08: VARIANT_OF without its authorizing assertion, or a self loop / two-cycle.
MATCH (v:FoodItem)-[r:VARIANT_OF]->(b:FoodItem)
WHERE r.assertionUid IS NULL OR v = b OR EXISTS { MATCH (b)-[:VARIANT_OF]->(v) }
   OR NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) WHERE a.predicate = 'VARIANT_OF' }
RETURN 'V-W05-08' AS id, v.uid AS variantUid, b.uid AS baseUid;

// V-W05-09: a RECOMMENDS edge to a practice, food or exposure whose cited assertion is not a RECOMMENDS speech act by that person (food-scoped V-423).
MATCH (p)-[r:RECOMMENDS]->(x)
WHERE (x:Lifestyle OR x:FoodItem OR x:Exposure)
  AND NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid})-[:ASSERTED_BY]->(p) WHERE a.speechAct = 'RECOMMENDS' }
RETURN 'V-W05-09' AS id, p.uid AS recommenderUid, x.uid AS targetUid, r.assertionUid AS cited;

// V-W05-10: any direct edge between a protocol step and an Exposure (forbidden implication PROTOCOL_STEP_USES_AGENT -> EXPOSURE_CHARACTERIZED).
MATCH (s:ProtocolStep)-[r]-(e:Exposure)
RETURN 'V-W05-10' AS id, s.uid AS stepUid, type(r) AS relType, e.uid AS exposureUid;

// V-W05-11: retired live edges still present in W05 scope.
MATCH (a)-[r]->(b)
WHERE (type(r) = 'INVOLVES' AND a:Exposure) OR type(r) IN ['CONTAINS_COMPOUND', 'HAS_INGREDIENT']
RETURN 'V-W05-11' AS id, labels(a) AS fromLabels, type(r) AS relType, b.uid AS toUid;

// V-W05-12: product identity collapsed into a reference food (trade identifiers or product backbone on a FoodItem).
MATCH (f:FoodItem)
WHERE EXISTS { MATCH (f)-[:IDENTIFIED_BY]->(:TradeItemIdentifier) }
   OR EXISTS { MATCH (f)-[:HAS_VARIANT|HAS_FORMULATION_VERSION|LISTING_FOR]-() }
   OR f:Product OR f:ProductVariant
RETURN 'V-W05-12' AS id, f.uid AS uid;
