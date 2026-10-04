// W04 validation queries (V-W04-xx). Zero rows = valid unless marked informational. Neo4j 5 Cypher; no APOC.
// Each statement is self-contained. These complement (never replace) baseline V-004, V-005, V-011, V-105..V-108, V-201, V-322, V-330,
// V-501..V-509, V-513 in docs/schema/neo4j/validation.cypher. Run status per query is recorded in 06-fixtures-and-queries.md.

// V-W04-01: endpoint shape of W04 relationship types (catalog domain/range; Product never carries formulation or label edges).
MATCH (x)-[r:HAS_VARIANT|HAS_PACKAGE_CONFIGURATION|HAS_FORMULATION_VERSION|HAS_INGREDIENT_COMPONENT|USES_MATERIAL|LABEL_FOR|DECLARES_FORMULATION|HAS_DECLARATION|HAS_QUANTITY_DECLARATION|DECLARATION_IDENTIFIES_MATERIAL|USES_SERVING_DEFINITION|NESTED_COMPONENT]->(y)
WITH x, r, y, type(r) AS t
WHERE NOT (
     (t = 'HAS_VARIANT' AND x:Product AND y:ProductVariant)
  OR (t = 'HAS_PACKAGE_CONFIGURATION' AND x:ProductVariant AND y:PackageConfiguration)
  OR (t = 'HAS_FORMULATION_VERSION' AND x:ProductVariant AND y:FormulationVersion)
  OR (t = 'HAS_INGREDIENT_COMPONENT' AND x:FormulationVersion AND y:IngredientComponent)
  OR (t = 'NESTED_COMPONENT' AND x:IngredientComponent AND y:IngredientComponent)
  OR (t = 'USES_MATERIAL' AND x:IngredientComponent AND y:IngredientMaterial)
  OR (t = 'LABEL_FOR' AND x:LabelSnapshot AND (y:ProductVariant OR y:PackageConfiguration))
  OR (t = 'DECLARES_FORMULATION' AND x:LabelSnapshot AND y:FormulationVersion)
  OR (t = 'HAS_DECLARATION' AND x:LabelSnapshot AND y:LabelDeclaration)
  OR (t = 'HAS_QUANTITY_DECLARATION' AND x:LabelDeclaration AND y:QuantityDeclaration)
  OR (t = 'DECLARATION_IDENTIFIES_MATERIAL' AND x:LabelDeclaration AND y:IngredientMaterial)
  OR (t = 'USES_SERVING_DEFINITION' AND (x:LabelSnapshot OR x:FormulationVersion) AND y:ServingDefinition))
RETURN t AS relType, labels(x) AS fromLabels, x.uid AS fromUid, labels(y) AS toLabels, y.uid AS toUid;

// V-W04-02: CONTAINS / CONTAINS_COMPOUND_FORM are regenerable derivations of formulation facts only: a rule, inputs that exist and are
// formulation-path predicates, and a believed formulation path from the subject to the target (INV-004, INV-005, F-3 of the 0.2.0 fixture).
MATCH (p)-[c:CONTAINS|CONTAINS_COMPOUND_FORM]->(t)
WITH p, c, t, type(c) AS rel, coalesce(c.derivedFromAssertionUids, []) AS inputs
OPTIONAL MATCH (inp:Assertion) WHERE inp.uid IN inputs
WITH p, c, t, rel, inputs, collect(inp) AS found
WITH p, c, t, rel, inputs, found,
     EXISTS {
       MATCH (p)-[:HAS_VARIANT*0..1]->(:ProductVariant)-[h:HAS_FORMULATION_VERSION]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(m:IngredientMaterial)
       WHERE h.recordedTo IS NULL AND (m = t OR EXISTS { (m)-[:HAS_CHEMICAL_FORM]->(t) })
     } AS pathExists
WITH p, t, rel, c, pathExists,
     [v IN [
       CASE WHEN c.derivationRule IS NULL THEN 'NO_RULE' END,
       CASE WHEN size(inputs) = 0 THEN 'NO_INPUT_ASSERTIONS' END,
       CASE WHEN size(found) < size(inputs) THEN 'INPUT_MISSING' END,
       CASE WHEN any(a IN found WHERE NOT a.predicate IN ['HAS_VARIANT', 'HAS_FORMULATION_VERSION', 'USES_MATERIAL', 'HAS_CHEMICAL_FORM']) THEN 'NON_FORMULATION_INPUT' END,
       CASE WHEN NOT pathExists THEN 'NO_BELIEVED_FORMULATION_PATH' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN rel, p.uid AS subjectUid, t.uid AS targetUid, violations;

// V-W04-03: regulatory display fields on Product are projections that name APPROVAL statuses of that product (extends V-322).
MATCH (p:Product)
WHERE p.status = 'APPROVED' OR p.approvedYear IS NOT NULL OR p.regulatoryAuthorizationId IS NOT NULL
WITH p, coalesce(p.regulatoryProjectionStatusUids, []) AS named
WHERE size(named) = 0
   OR any(u IN named WHERE NOT EXISTS { MATCH (s:RegulatoryStatus {uid: u})-[:STATUS_OF]->(p) })
   OR ((p.status = 'APPROVED' OR p.approvedYear IS NOT NULL)
       AND NOT any(u IN named WHERE EXISTS { MATCH (s:RegulatoryStatus {uid: u, statusKind: 'APPROVAL'})-[:STATUS_OF]->(p) }))
RETURN p.uid AS productUid, p.status AS status, p.approvedYear AS approvedYear, named AS regulatoryProjectionStatusUids;

// V-W04-04: active-moiety / nutrient-equivalent amounts are CALCULATED literal assertions on a component, with a rule and inputs that include
// a HAS_ACTIVE_MOIETY (or nutrient-equivalence) assertion and a formulation assertion; never on a label artifact (INV-307, forbidden
// LISTED_INGREDIENT_AMOUNT -> ACTIVE_MOIETY_AMOUNT). The two list predicates use DISTINCT iteration variables on purpose: on Neo4j 5.26.31
// `NOT any(x IN l WHERE x IN [..]) OR NOT any(x IN l WHERE x IN [..])` with a shared variable name returns wrong results (07-operations.md).
MATCH (a:Assertion)
WHERE a.predicate IN ['ACTIVE_MOIETY_AMOUNT', 'NUTRIENT_EQUIVALENT_AMOUNT']
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
OPTIONAL MATCH (a)-[:DERIVED_FROM_ASSERTION]->(i:Assertion)
WITH a, s, collect(i.predicate) AS inputPredicates
WHERE coalesce(a.basisKind, '-') <> 'CALCULATED' OR a.derivationRule IS NULL OR a.valueNumber IS NULL OR a.unitCode IS NULL
   OR s IS NULL OR NOT s:IngredientComponent OR s:LabelDeclaration OR s:QuantityDeclaration
   OR NOT any(moietyInput IN inputPredicates WHERE moietyInput IN ['HAS_ACTIVE_MOIETY', 'NUTRIENT_EQUIVALENT_OF'])
   OR NOT any(formulationInput IN inputPredicates WHERE formulationInput IN ['HAS_FORMULATION_VERSION', 'USES_MATERIAL'])
RETURN a.uid AS assertionUid, a.basisKind AS basisKind, labels(s) AS subjectLabels, inputPredicates;

// V-W04-05: a stated component amount carries unit, quantity basis, mass basis and amount referent; NOT_STATED never carries an amount.
MATCH (c:IngredientComponent)
WHERE (c.quantity IS NOT NULL AND (c.unitCode IS NULL OR c.quantityBasis IS NULL OR c.massBasis IS NULL OR c.amountReferent IS NULL OR c.amountReferent = 'NOT_STATED'))
   OR (c.amountReferent = 'ACTIVE_MOIETY')
   OR (c.amountReferent IS NOT NULL AND NOT c.amountReferent IN ['NUTRIENT_AS_NUTRIENT', 'LISTED_INGREDIENT_AS_LISTED', 'PROPRIETARY_BLEND_TOTAL', 'EXTRACT_TOTAL', 'MARKER_CONSTITUENT', 'NOT_STATED'])
RETURN c.uid AS componentUid, c.quantity AS quantity, c.unitCode AS unitCode, c.quantityBasis AS quantityBasis, c.massBasis AS massBasis, c.amountReferent AS amountReferent;

// V-W04-06: package facts never sit on composition records and composition facts never sit on packages.
MATCH (n)
WHERE ((n:FormulationVersion OR n:IngredientComponent) AND (n.unitCount IS NOT NULL OR n.packageForm IS NOT NULL OR n.servingsPerContainer IS NOT NULL OR n.netQuantity IS NOT NULL))
   OR (n:PackageConfiguration AND (n.quantity IS NOT NULL OR n.massBasis IS NOT NULL OR n.amountReferent IS NOT NULL))
RETURN labels(n) AS labels, n.uid AS uid;

// V-W04-07: servings per container is a package fact (21 CFR 101.36(b)(1)(ii)): such a ServingDefinition is never a formulation's serving and
// every label using it is LABEL_FOR a PackageConfiguration.
MATCH (s:ServingDefinition)
WHERE s.servingsPerContainer IS NOT NULL
  AND (EXISTS { (:FormulationVersion)-[:USES_SERVING_DEFINITION]->(s) }
       OR EXISTS { MATCH (ls:LabelSnapshot)-[:USES_SERVING_DEFINITION]->(s) WHERE NOT (ls)-[:LABEL_FOR]->(:PackageConfiguration) })
RETURN s.uid AS servingDefinitionUid, s.servingsPerContainer AS servingsPerContainer;

// V-W04-08: the exclusivity partition key on a formulation episode agrees with the formulation's jurisdiction.
MATCH (v)-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE h.jurisdiction IS NOT NULL AND f.jurisdiction IS NOT NULL AND h.jurisdiction <> f.jurisdiction
RETURN v.uid AS variantUid, f.uid AS formulationUid, h.jurisdiction AS edgeJurisdiction, f.jurisdiction AS formulationJurisdiction;

// V-W04-09 (informational): label snapshots with declarations but no LABEL_FOR target cannot answer CQ-PF-02 / CQ-ID-02.
MATCH (ls:LabelSnapshot)-[:HAS_DECLARATION]->(:LabelDeclaration)
WHERE NOT (ls)-[:LABEL_FOR]->()
RETURN DISTINCT ls.uid AS labelSnapshotWithoutTarget;

// V-W04-10: a formulation version has components, and a PER_SERVING component needs the version's serving (CQ-AX-17).
MATCH (f:FormulationVersion)
WHERE NOT (f)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)
   OR (EXISTS { MATCH (f)-[:HAS_INGREDIENT_COMPONENT]->(c:IngredientComponent) WHERE c.quantityBasis = 'PER_SERVING' }
       AND NOT (f)-[:USES_SERVING_DEFINITION]->(:ServingDefinition))
RETURN f.uid AS formulationUid,
       EXISTS { (f)-[:HAS_INGREDIENT_COMPONENT]->() } AS hasComponents,
       EXISTS { (f)-[:USES_SERVING_DEFINITION]->() } AS hasServing;

// V-W04-11: label artifacts hang from their parent (a declaration from exactly one snapshot, a quantity from exactly one declaration).
MATCH (n)
WHERE (n:LabelDeclaration AND COUNT { (:LabelSnapshot)-[:HAS_DECLARATION]->(n) } <> 1)
   OR (n:QuantityDeclaration AND COUNT { (:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(n) } <> 1)
RETURN labels(n) AS labels, n.uid AS orphanOrSharedArtifact;

// V-W04-12: VersionedState payloads of this module carry a sha256 payloadHash (D-016) and their stateType.
MATCH (n)
WHERE (n:FormulationVersion OR n:IngredientComponent OR n:PackageConfiguration OR n:ServingDefinition OR n:ProductSnapshot)
  AND (n.payloadHash IS NULL OR NOT n.payloadHash =~ 'sha256:[0-9a-f]{64}' OR n.stateType IS NULL)
RETURN labels(n) AS labels, n.uid AS uid, n.payloadHash AS payloadHash, n.stateType AS stateType;
