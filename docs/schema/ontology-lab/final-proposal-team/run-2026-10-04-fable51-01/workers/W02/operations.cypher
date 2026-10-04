// W02 Substances and materials - operations proposal (run-2026-10-04-fable51-01, Opus 5.5).
// Section A: indexes and constraints Neo4j 5.26 Community can create (all uniqueness and range/fulltext indexes are
// available in Community; nothing here needs Enterprise). Stored property names only.
// Section B: validation queries V-W02-01 .. V-W02-13, zero rows = valid (informational ones say so).
// status: executed on embedded Neo4j 5.26.31 Community against the W02 fixtures (see 06-fixtures-and-queries.md).

// ---------------------------------------------------------------------------------------------------------------
// Section A. Indexes (uid uniqueness comes from the archetype constraints entity_uid etc. in constraints.cypher)
// ---------------------------------------------------------------------------------------------------------------

// D-015: live fulltext index names and query names retained; fields use stored property names.
// CompoundSearch (live Compound) now covers ChemicalSubstance; casNumber is a materialized lookup key only.
CREATE FULLTEXT INDEX CompoundSearch IF NOT EXISTS
FOR (n:ChemicalSubstance) ON EACH [n.name, n.preferredName, n.description, n.commonName, n.casNumber, n.searchText];

// IngredientSearch (live Ingredient) now covers IngredientMaterial and every specialization (they carry the label).
CREATE FULLTEXT INDEX IngredientSearch IF NOT EXISTS
FOR (n:IngredientMaterial) ON EACH [n.name, n.description, n.searchText];

// Lookup keys: candidates only (an identifier hit is a candidate, never identity; CQ-ID-04).
CREATE INDEX chemical_substance_inchikey IF NOT EXISTS FOR (n:ChemicalSubstance) ON (n.inchikey);
CREATE INDEX chemical_substance_pubchem_cid IF NOT EXISTS FOR (n:ChemicalSubstance) ON (n.pubchemCid);
CREATE INDEX chemical_substance_cas_legacy IF NOT EXISTS FOR (n:ChemicalSubstance) ON (n.casNumber);
CREATE INDEX ingredient_material_kind IF NOT EXISTS FOR (n:IngredientMaterial) ON (n.materialKind);
CREATE INDEX branded_material_brand IF NOT EXISTS FOR (n:BrandedIngredientMaterial) ON (n.brandName);
CREATE INDEX botanical_taxon_taxonomy_id IF NOT EXISTS FOR (n:BotanicalTaxon) ON (n.taxonomyId);
CREATE INDEX microbial_taxon_taxonomy_id IF NOT EXISTS FOR (n:MicrobialTaxon) ON (n.taxonomyId);
CREATE INDEX microbial_strain_deposit IF NOT EXISTS FOR (n:MicrobialStrain) ON (n.depositIdentifier);
// Relationship-property index for as-of retrieval of specification attachments and content statements.
CREATE INDEX governed_by_spec_recorded IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() ON (r.recordedFrom);
CREATE INDEX quantitatively_contains_assertion IF NOT EXISTS FOR ()-[r:QUANTITATIVELY_CONTAINS]-() ON (r.assertionUid);

// Not proposed as uniqueness constraints (deliberate): inchikey, pubchemCid, casNumber, depositIdentifier,
// taxonomyId. A merge keeps the old uid resolvable (contract A2), so two nodes may legitimately share a key until
// the redirect is published; duplicates are reported by V-W02-13 instead.

// ---------------------------------------------------------------------------------------------------------------
// Section B. Validation queries (zero rows = valid unless marked informational)
// ---------------------------------------------------------------------------------------------------------------

// V-W02-01 (forbidden implication [PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]; QS-4a specialization):
// every QUANTITATIVELY_CONTAINS edge cites a live QUANTITATIVELY_CONTAINS assertion with the same subject and object.
// status: executed
MATCH (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH x, y, r, a, s, o
WHERE a IS NULL OR a.predicate <> 'QUANTITATIVELY_CONTAINS' OR s <> x OR o IS NULL OR o <> y
RETURN 'V-W02-01' AS rule, x.uid AS material, y.uid AS target, r.assertionUid AS citedAssertion, a.predicate AS citedPredicate;

// V-W02-02: specialization label and materialKind agree; specializations carry the IngredientMaterial label.
// status: executed
MATCH (m)
WHERE (m:BrandedIngredientMaterial OR m:BotanicalPreparation OR m:MicrobialPreparation OR m:MaterialMixture OR m:IngredientMaterial)
WITH m,
  CASE WHEN m:BotanicalPreparation THEN 'BOTANICAL_PREPARATION'
       WHEN m:MicrobialPreparation THEN 'MICROBIAL_PREPARATION'
       WHEN m:MaterialMixture THEN 'MATERIAL_MIXTURE' ELSE null END AS impliedKind
WHERE NOT m:IngredientMaterial
   OR (impliedKind IS NOT NULL AND m.materialKind IS NOT NULL AND m.materialKind <> impliedKind)
   OR (impliedKind IS NULL AND m.materialKind IN ['BOTANICAL_PREPARATION', 'MICROBIAL_PREPARATION', 'MATERIAL_MIXTURE'])
RETURN 'V-W02-02' AS rule, m.uid AS material, labels(m) AS labels, m.materialKind AS materialKind, impliedKind;

// V-W02-03 (CL-001): a ChemicalSubstance above CANDIDATE maturity is anchored to a defined structure: inchikey,
// pubchemCid or molecularFormula, or an Identifier in a chemical scheme. A combination name ('NRPT') has none.
// status: executed
MATCH (s:ChemicalSubstance)
WHERE coalesce(s.maturity, 'PROVISIONAL') <> 'CANDIDATE'
  AND s.inchikey IS NULL AND s.pubchemCid IS NULL AND s.molecularFormula IS NULL
  AND NOT EXISTS { MATCH (s)-[:HAS_IDENTIFIER]->(i:Identifier) WHERE i.scheme IN ['UNII', 'CAS', 'PUBCHEM_CID', 'CHEBI', 'INCHIKEY'] }
RETURN 'V-W02-03' AS rule, s.uid AS unanchoredSubstance, s.name AS name;

// V-W02-04 (CL-001): a ChemicalSubstance never has two distinct active moieties other than itself and is never a
// mixture component container; a combination is a StudyIntervention, a FormulationVersion or a MaterialMixture.
// Informational for genuine multi-moiety salts (reviewer confirms with the authority record).
// status: executed
MATCH (s:ChemicalSubstance)-[:HAS_ACTIVE_MOIETY]->(m:ChemicalSubstance)
WHERE m <> s
WITH s, count(DISTINCT m) AS moieties
WHERE moieties > 1
RETURN 'V-W02-04' AS rule, s.uid AS substanceWithSeveralMoieties, moieties;

// V-W02-05 (D-06, OPEN-QUESTIONS P1-2): one BrandedIngredientMaterial per brand and owner; a specification change is a
// new SpecificationVersion, not a new material. Informational: rows need a ResolutionHypothesis or a merge.
// status: executed
MATCH (a:BrandedIngredientMaterial), (b:BrandedIngredientMaterial)
WHERE a.uid < b.uid AND toLower(a.brandName) = toLower(b.brandName)
  AND coalesce(a.specificationOwnerUid, '') = coalesce(b.specificationOwnerUid, '')
  AND NOT EXISTS { MATCH (h)-[:PROPOSES_MATCH]->(a) WHERE (h)-[:PROPOSES_MATCH]->(b) }
  AND NOT EXISTS { MATCH (e:EquivalenceAssessment)-[:COMPARES_IDENTITIES]->(a) WHERE (e)-[:COMPARES_IDENTITIES]->(b) }
RETURN 'V-W02-05' AS rule, a.uid AS material, b.uid AS duplicateCandidate, a.brandName AS brand;

// V-W02-06 (CL-002): chemical identity keys never sit on MolecularEntity, and a MolecularEntity never shares a chemical
// identifier with a ChemicalSubstance (NAD+ minted twice).
// status: executed
MATCH (e:MolecularEntity)
WHERE e.inchikey IS NOT NULL OR e.pubchemCid IS NOT NULL
   OR EXISTS { MATCH (e)-[:HAS_IDENTIFIER]->(i:Identifier) WHERE i.scheme IN ['UNII', 'CAS', 'PUBCHEM_CID', 'CHEBI', 'INCHIKEY'] }
OPTIONAL MATCH (s:ChemicalSubstance) WHERE s.inchikey IS NOT NULL AND s.inchikey = e.inchikey
RETURN 'V-W02-06' AS rule, e.uid AS molecularEntityWithChemicalKey, s.uid AS sameKeySubstance;

// V-W02-07: HAS_ACTIVE_MOIETY targets a terminal moiety (one that has only a self-edge or no outgoing edge).
// status: executed
MATCH (a:ChemicalSubstance)-[:HAS_ACTIVE_MOIETY]->(b:ChemicalSubstance)-[:HAS_ACTIVE_MOIETY]->(c:ChemicalSubstance)
WHERE a <> b AND b <> c
RETURN 'V-W02-07' AS rule, a.uid AS substance, b.uid AS nonTerminalMoiety, c.uid AS furtherMoiety;

// V-W02-08 (INV-307, KCR-L3-001; kernel rule proposed for W00 generally): a CALCULATED quantity assertion has a
// derivationRule and at least one DERIVED_FROM_ASSERTION input, no SUPPORTED_BY locator of its own, and is never the
// subject or object of a label declaration.
// status: executed
MATCH (a:Assertion {basisKind: 'CALCULATED'})
WHERE a.predicateClass = 'QUANTITY' OR a.predicate = 'QUANTITATIVELY_CONTAINS'
WITH a,
     a.derivationRule IS NOT NULL AS hasRule,
     EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION]->(:Assertion) } AS hasInputs,
     EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator) } AS hasOwnLocator,
     EXISTS { MATCH (a)-[:HAS_SUBJECT|HAS_OBJECT]->(d) WHERE d:LabelDeclaration OR d:QuantityDeclaration } AS onDeclaration
WHERE NOT hasRule OR NOT hasInputs OR hasOwnLocator OR onDeclaration
RETURN 'V-W02-08' AS rule, a.uid AS calculatedAssertion, hasRule, hasInputs, hasOwnLocator, onDeclaration;

// V-W02-09 (W02-SR-05 STRAIN_OF exclusivity): at most one current projected STRAIN_OF edge per strain whose valid
// intervals can overlap (null bounds count as possible overlap).
// status: executed
MATCH (s:MicrobialStrain)-[r1:STRAIN_OF]->(t1), (s)-[r2:STRAIN_OF]->(t2)
WHERE elementId(r1) < elementId(r2) AND t1 <> t2 AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
  AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
RETURN 'V-W02-09' AS rule, s.uid AS strain, t1.uid AS taxonA, t2.uid AS taxonB;

// V-W02-10 (proposed V-006r, W02-SR-02): QUANTITATIVELY_CONTAINS quantity shape agrees with its comparator.
// Point comparators need quantity; BETWEEN needs quantityLow < quantityHigh and no quantity; unit, basis and
// contentStatementKind are always required.
// status: executed
MATCH (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
WHERE r.unitCode IS NULL OR r.basis IS NULL OR r.contentStatementKind IS NULL OR r.comparator IS NULL
   OR (r.comparator IN ['EQ', 'APPROX', 'GE', 'GT', 'LE', 'LT'] AND r.quantity IS NULL)
   OR (r.comparator = 'BETWEEN' AND (r.quantityLow IS NULL OR r.quantityHigh IS NULL OR r.quantityLow >= r.quantityHigh OR r.quantity IS NOT NULL))
RETURN 'V-W02-10' AS rule, x.uid AS material, y.uid AS target, r.comparator AS comparator, r.quantity AS quantity, r.basis AS basis;

// V-W02-11: domain and range of W02 relationship types (catalog substances_and_materials).
// status: executed
MATCH (x)-[r:REALIZES_SUBSTANCE|HAS_CHEMICAL_FORM|FORM_OF_SUBSTANCE|HAS_ACTIVE_MOIETY|DERIVED_FROM_TAXON|HAS_STRAIN|STRAIN_OF|HAS_MIXTURE_COMPONENT|PROVIDES_CONSTITUENT|QUANTITATIVELY_CONTAINS]->(y)
WITH x, r, y, type(r) AS t
WHERE (t = 'REALIZES_SUBSTANCE' AND NOT (x:IngredientMaterial AND y:ChemicalSubstance))
   OR (t = 'HAS_CHEMICAL_FORM' AND NOT (x:IngredientMaterial AND y:ChemicalForm))
   OR (t = 'FORM_OF_SUBSTANCE' AND NOT (x:ChemicalForm AND y:ChemicalSubstance))
   OR (t = 'HAS_ACTIVE_MOIETY' AND NOT (x:ChemicalSubstance AND y:ChemicalSubstance))
   OR (t = 'DERIVED_FROM_TAXON' AND NOT (x:BotanicalPreparation AND y:BotanicalTaxon))
   OR (t = 'HAS_STRAIN' AND NOT (x:MicrobialPreparation AND y:MicrobialStrain))
   OR (t = 'STRAIN_OF' AND NOT (x:MicrobialStrain AND y:MicrobialTaxon))
   OR (t = 'HAS_MIXTURE_COMPONENT' AND NOT (x:MaterialMixture AND y:IngredientMaterial AND x <> y))
   OR (t IN ['PROVIDES_CONSTITUENT', 'QUANTITATIVELY_CONTAINS'] AND NOT (x:IngredientMaterial AND (y:Constituent OR y:Nutrient OR y:ChemicalSubstance)))
RETURN 'V-W02-11' AS rule, t AS relType, x.uid AS fromUid, labels(x) AS fromLabels, y.uid AS toUid, labels(y) AS toLabels;

// V-W02-12 (migration progress, informational): legacy labels still present after the D-002/D-008 migration.
// status: executed
MATCH (n)
WHERE n:Compound OR n:CompoundForm OR n:Ingredient OR n:Material
RETURN 'V-W02-12' AS rule, [l IN labels(n) WHERE l IN ['Compound', 'CompoundForm', 'Ingredient', 'Material']] AS legacyLabels,
       count(n) AS remaining;

// V-W02-13 (informational): two ChemicalSubstance nodes share an InChIKey without a published redirect.
// status: executed
MATCH (a:ChemicalSubstance), (b:ChemicalSubstance)
WHERE a.uid < b.uid AND a.inchikey IS NOT NULL AND a.inchikey = b.inchikey
  AND NOT EXISTS { MATCH (e:EquivalenceAssessment)-[:COMPARES_IDENTITIES]->(a) WHERE (e)-[:COMPARES_IDENTITIES]->(b) }
RETURN 'V-W02-13' AS rule, a.uid AS substance, b.uid AS sameInchikey, a.inchikey AS inchikey;
