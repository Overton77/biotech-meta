// Queries over fixture 08. Expected: 06-fixtures-and-queries.md §3.8.

// Q08-a CQ-ID-04: identity-preserving join — two materials share an identifier only if (scheme, issuer, value) match. Expect 0 rows.
MATCH (m1:IngredientMaterial)-[:HAS_IDENTIFIER]->(i1:Identifier), (m2:IngredientMaterial)-[:HAS_IDENTIFIER]->(i2:Identifier)
WHERE elementId(m1) < elementId(m2) AND i1.scheme = i2.scheme AND i1.issuer = i2.issuer AND i1.value = i2.value
RETURN 'Q08-a' AS q, m1.uid AS material1, m2.uid AS material2;

// Q08-b the forbidden join (scheme, value only) — returns the pair that a naive merge would collapse. Expect 1 row.
MATCH (m1:IngredientMaterial)-[:HAS_IDENTIFIER]->(i1:Identifier), (m2:IngredientMaterial)-[:HAS_IDENTIFIER]->(i2:Identifier)
WHERE elementId(m1) < elementId(m2) AND i1.scheme = i2.scheme AND i1.value = i2.value
RETURN 'Q08-b' AS q, m1.uid AS material1, m2.uid AS material2, i1.issuer AS issuer1, i2.issuer AS issuer2, 'FORBIDDEN_IMPLICATION_IF_MERGED' AS note;

// Q08-c QS-8 analogue (CQ-AX-14): free text "NR-100" -> mention -> candidate identities, kept as hypotheses.
CALL db.index.fulltext.queryNodes('mention_surface_form', 'NR\\-100') YIELD node, score
MATCH (node)<-[:RESOLVES_MENTION]-(h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(cand)
OPTIONAL MATCH (cand)-[:HAS_IDENTIFIER]->(i:Identifier)
RETURN 'Q08-c' AS q, node.surfaceForm AS surfaceForm, cand.uid AS candidate, h.resolutionStatus AS hypothesisOutcome, h.status AS recordStatus,
       i.issuer AS identifierIssuer, score AS lexicalScoreOnly
ORDER BY candidate;

// Q08-d count of Identifier nodes for the shared value (the duplicate write was refused): expect 2.
MATCH (i:Identifier {scheme: 'SUPPLIER_CATALOG_NUMBER', value: 'NR-100'})
RETURN 'Q08-d' AS q, count(i) AS identifierNodes, collect(i.issuer) AS issuers;
