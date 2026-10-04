// W05 CQ queries (read-only). Parameters are inlined as literals so the file runs as-is.

// Q-ST-01-food: what did each arm take (material components and practice-definition components)?
MATCH (:Study {uid: 'hu:study:dica-nuts-nct03728127'})-[:HAS_ARM]->(arm)-[:ASSIGNS_INTERVENTION]->(si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
OPTIONAL MATCH (ic)-[um:USES_INTERVENTION_MATERIAL]->(m:IngredientMaterial)
OPTIONAL MATCH (ic)-[up:USES_PRACTICE_DEFINITION]->(pd)
RETURN arm.name AS arm, si.durationIso AS duration, si.registryInterventionType AS registryType,
       ic.quantity AS qty, ic.unitCode AS unit, ic.quantityBasis AS qBasis,
       coalesce(m.name, pd.name) AS component, CASE WHEN m:FoodItem THEN 'FOOD' WHEN pd IS NOT NULL THEN 'PRACTICE_DEFINITION' ELSE 'OTHER' END AS componentKind
ORDER BY arm, component;

// Q-FL-C01: composition of the food a study used, by preparation variant, with source, derivation and spread.
MATCH (:InterventionComponent {uid: 'hu:intervention-component:subranut-brazil-nut-1-per-day'})-[:USES_INTERVENTION_MATERIAL]->(base:FoodItem)
MATCH (v:FoodItem)-[vo:VARIANT_OF]->(base)
MATCH (v)-[q:QUANTITATIVELY_CONTAINS]->(x {uid: 'hu:substance:selenium'})
MATCH (a:Assertion {uid: q.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
RETURN base.name AS studiedFood, v.descriptionVerbatim AS variant, vo.variantKind AS variantKind, q.quantity AS amount, q.unitCode AS unit,
       q.basis AS basis, q.portionBasis AS portion, q.valueDerivation AS derivation, q.minValue AS min, q.maxValue AS max, q.dataPoints AS n,
       sn.canonicalUri AS source, sn.publishedAt AS publishedAt, a.recordedAt AS recordedAt
ORDER BY recordedAt;

// Q-FL-C01b: as-of recorded time 2026-10-04T12:00Z (before the late-arriving record).
MATCH (v:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'})-[q:QUANTITATIVELY_CONTAINS]->(x {uid: 'hu:substance:selenium'})
WHERE q.recordedFrom <= datetime('2026-10-04T12:00:00Z') AND (q.recordedTo IS NULL OR q.recordedTo > datetime('2026-10-04T12:00:00Z'))
RETURN q.quantity AS amount, q.relationshipUid AS rel;

// Q-AX-04-food: unknown versus assumed zero versus underived zero for a food.
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'})<-[:HAS_SUBJECT]-(a:Assertion {predicate: 'QUANTITATIVELY_CONTAINS'})-[:HAS_OBJECT]->(x)
OPTIONAL MATCH (f)-[q:QUANTITATIVELY_CONTAINS {assertionUid: a.uid}]->(x)
RETURN x.name AS component, a.status AS status, a.basisKind AS basisKind, q.quantity AS amount, q.valueDerivation AS derivation,
       CASE WHEN q IS NULL THEN 'NOT_PROJECTED (unresolved source row)' WHEN q.valueDerivation = 'ASSUMED_ZERO' THEN 'ASSUMED_ZERO (not a measurement)' ELSE 'VALUE' END AS reading
ORDER BY component;

// Q-FL-C02: same agent, characterized exposure versus protocol step (minimal pair).
MATCH (se:ChemicalSubstance {uid: 'hu:substance:selenium'})
OPTIONAL MATCH (e:Exposure)-[:HAS_EXPOSURE_AGENT]->(se)
OPTIONAL MATCH (rfd:Assertion {predicate: 'HAS_REFERENCE_DOSE'})-[:HAS_SUBJECT]->(e) WHERE rfd.recordedTo IS NULL
RETURN 'EXPOSURE' AS kind, e.uid AS uid, e.route AS route, e.durationCategory AS duration, e.intensityValue AS intensity, e.intensityUnitCode AS unit,
       rfd.valueNumber AS referenceDose, rfd.unitCode AS rfdUnit
UNION
MATCH (st:ProtocolStep)-[u:USES]->(f:FoodItem)<-[:VARIANT_OF*0..1]-(v:FoodItem)-[:QUANTITATIVELY_CONTAINS]->(:ChemicalSubstance {uid: 'hu:substance:selenium'})
RETURN DISTINCT 'PROTOCOL_STEP' AS kind, st.uid AS uid, NULL AS route, NULL AS duration, u.dose AS intensity, u.doseUnitCode AS unit,
       NULL AS referenceDose, NULL AS rfdUnit;

// Q-TM-food: as-of RfD before and after the extraction fix.
UNWIND [datetime('2026-10-04T01:45:00Z'), datetime('2026-10-04T03:00:00Z')] AS asOf
MATCH (a:Assertion {predicate: 'HAS_REFERENCE_DOSE'})-[:HAS_SUBJECT]->(:Exposure {uid: 'hu:exposure:selenium-oral-chronic-dietary'})
WHERE a.recordedAt <= asOf AND (a.recordedTo IS NULL OR a.recordedTo > asOf)
RETURN asOf, a.valueNumber AS rfd, a.unitCode AS unit;

// Q-RC-05-practice: who reports doing versus who recommends a practice.
MATCH (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'})<-[:HAS_SUBJECT|HAS_OBJECT]-(a:Assertion)-[:ASSERTED_BY]->(p:Person)
OPTIONAL MATCH (p)-[r:RECOMMENDS {assertionUid: a.uid}]->(lf)
RETURN p.name AS speaker, a.speechAct AS speechAct, a.assertionBasis AS basis, a.predicate AS predicate, r IS NOT NULL AS projectedRecommendation
ORDER BY speechAct;

// Q-FL-C03: products whose current formulation uses a food (food -> product path, one product identity).
MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut'})<-[:USES_MATERIAL]-(:IngredientComponent)<-[:HAS_INGREDIENT_COMPONENT]-(fv:FormulationVersion)<-[:HAS_FORMULATION_VERSION]-(v:ProductVariant)<-[:HAS_VARIANT]-(p:Product)
RETURN p.uid AS productUid, p.productKind AS kind, labels(p) AS labels, v.name AS variant, fv.uid AS formulation;

// Q-FL-C04: practice definitions behind diet arms, and what the registry leaves unstated.
MATCH (ic:InterventionComponent)-[r:USES_PRACTICE_DEFINITION]->(pd:Protocol)
OPTIONAL MATCH (pd)-[:HAS_PROTOCOL_EDITION]->(ed)
RETURN pd.name AS practiceDefinition, count(DISTINCT ic) AS components, count(ed) AS knownEditions, pd.notReportedFields AS notReported;
