// W02 competency-question queries (run-2026-10-04-fable51-01, Opus 5.5). Literal parameters are inlined so that the
// harness can run each statement as written; production callers bind the same values as $parameters.
// Expected rows are documented in ../06-fixtures-and-queries.md. Load fx-01 .. fx-07 first.

// Q-01 (CQ-PF-01, Essential): what a label amount refers to, and which calculated amounts follow with which rule.
// status: executed
MATCH (c:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'})-[:USES_MATERIAL]->(m:IngredientMaterial)
OPTIONAL MATCH (m)-[:REALIZES_SUBSTANCE]->(s:ChemicalSubstance)
OPTIONAL MATCH (s)-[:HAS_ACTIVE_MOIETY]->(am:ChemicalSubstance)
OPTIONAL MATCH (calc:Assertion {basisKind: 'CALCULATED'})-[:HAS_SUBJECT]->(c)
RETURN c.declaredAs AS declaredAs, c.quantity AS declaredQuantity, c.unitCode AS unit, c.amountReferent AS amountReferent,
       c.massBasis AS massBasis, s.preferredName AS realizedSubstance, am.preferredName AS activeMoiety,
       calc.valueNumber AS calculatedAmount, calc.unitCode AS calculatedUnit, calc.derivationRule AS rule,
       COLLECT { MATCH (calc)-[:DERIVED_FROM_ASSERTION]->(i:Assertion) RETURN i.predicate } AS inputPredicates;

// Q-02 (CQ-ID-03, Foundational): does a material realize a substance, provide a constituent, or contain a stated amount?
// status: executed
MATCH (m:IngredientMaterial {uid: 'hu:material:mosaic-tomato-fruit-extract'})
OPTIONAL MATCH (m)-[p:PROVIDES_CONSTITUENT]->(t)
OPTIONAL MATCH (m)-[q:QUANTITATIVELY_CONTAINS]->(t)
OPTIONAL MATCH (a:Assertion {uid: p.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN t.name AS constituent, [l IN labels(t) WHERE l <> 'Entity'][0] AS targetType, l.uri AS statedBy,
       CASE WHEN q IS NULL THEN 'NOT_STATED' ELSE toString(q.quantity) + ' ' + q.unitCode END AS amount
ORDER BY constituent;

// Q-03 (CQ-ID-04, Foundational): which identifiers support each substance, from which authority snapshot.
// status: executed
MATCH (s:ChemicalSubstance)-[h:HAS_IDENTIFIER]->(i:Identifier)
WHERE s.uid IN ['hu:substance:nicotinamide-riboside-chloride', 'hu:substance:nicotinamide-riboside']
MATCH (a:Assertion {uid: h.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
RETURN s.preferredName AS substance, i.scheme AS scheme, i.value AS value, i.issuer AS issuer, h.isPrimary AS isPrimary,
       sn.retrievedAt AS authorityRetrievedAt, a.status AS captureStatus
ORDER BY substance, scheme;

// Q-04 (CQ-ID-06 and CQ-ST-02, Essential): material identity facts for a pair, with the W02 suggested level for W10
// (method w02-identity-facts-v1; W10 owns the level and the verdict). Run once per pair (pairs inlined below).
// status: executed
UNWIND [['hu:material:chromadex-niagen', 'hu:material:nct02678611-nr-as-supplied'],
        ['hu:material:chromadex-niagen', 'hu:material:synthetic-supplier-x-nrc-amorphous'],
        ['hu:material:chromadex-niagen', 'hu:material:chromadex-niagen'],
        ['hu:material:chromadex-niagen', 'hu:material:mosaic-tomato-fruit-extract']] AS pair
MATCH (a:IngredientMaterial {uid: pair[0]}), (b:IngredientMaterial {uid: pair[1]})
WITH a, b,
  COLLECT { MATCH (a)-[r:REALIZES_SUBSTANCE]->(s) WHERE r.recordedTo IS NULL RETURN s.uid } AS aExact,
  COLLECT { MATCH (b)-[r:REALIZES_SUBSTANCE]->(s) WHERE r.recordedTo IS NULL RETURN s.uid } AS bExact,
  COLLECT { MATCH (a)-[:REALIZES_SUBSTANCE]->(:ChemicalSubstance)-[:HAS_ACTIVE_MOIETY]->(m) RETURN m.uid } AS aMoiety,
  COLLECT { MATCH (b)-[:REALIZES_SUBSTANCE]->(:ChemicalSubstance)-[:HAS_ACTIVE_MOIETY]->(m) RETURN m.uid } AS bMoiety,
  COLLECT { MATCH (a)-[:HAS_CHEMICAL_FORM]->(f) RETURN f.uid } AS aForms,
  COLLECT { MATCH (b)-[:HAS_CHEMICAL_FORM]->(f) RETURN f.uid } AS bForms,
  EXISTS { MATCH (a)-[:REALIZES_SUBSTANCE]->(m:ChemicalSubstance)<-[:HAS_ACTIVE_MOIETY]-(salt:ChemicalSubstance) WHERE salt <> m
           AND NOT EXISTS { MATCH (a)-[:REALIZES_SUBSTANCE]->(salt) } } AS aMoietyOnly,
  EXISTS { MATCH (b)-[:REALIZES_SUBSTANCE]->(m:ChemicalSubstance)<-[:HAS_ACTIVE_MOIETY]-(salt:ChemicalSubstance) WHERE salt <> m
           AND NOT EXISTS { MATCH (b)-[:REALIZES_SUBSTANCE]->(salt) } } AS bMoietyOnly
WITH a, b, aExact, bExact, aMoiety, bMoiety, aForms, bForms, aMoietyOnly, bMoietyOnly,
     size([x IN aExact WHERE x IN bExact]) > 0 AS sameExact,
     size([x IN aMoiety WHERE x IN bMoiety]) > 0 AS sameMoiety,
     size([x IN aForms WHERE x IN bForms]) > 0 AS sameForm
RETURN a.uid AS materialA, b.uid AS materialB, sameExact, sameMoiety, sameForm, aMoietyOnly, bMoietyOnly,
  CASE
    WHEN a = b THEN 'SAME_MATERIAL_IDENTITY (W10 refines to lot/formulation/spec level)'
    WHEN size(aExact) = 0 OR size(bExact) = 0 THEN 'INSUFFICIENT_SUBSTANCE_FACTS'
    WHEN sameExact AND size(aForms) > 0 AND size(bForms) > 0 AND sameForm THEN 'SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL'
    WHEN sameExact AND size(aForms) > 0 AND size(bForms) > 0 THEN 'SAME_SUBSTANCE_DIFFERENT_FORM'
    WHEN sameExact THEN 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED'
    WHEN sameMoiety AND (aMoietyOnly OR bMoietyOnly) THEN 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED'
    WHEN sameMoiety THEN 'SAME_SUBSTANCE_DIFFERENT_FORM'
    ELSE 'DIFFERENT_OR_RELATED (W10 assesses RELATED_SUBSTANCE)'
  END AS suggestedIdentityLevel
ORDER BY materialB;

// Q-05a (CQ-ID-05, Foundational): which specification version governed NIAGEN at valid time V, as recorded now.
// status: executed
WITH datetime('2016-06-01T00:00:00Z') AS validAt, datetime('2026-10-04T23:00:00Z') AS recordedAsOf
MATCH (m:IngredientMaterial {uid: 'hu:material:chromadex-niagen'})-[g:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)
WHERE g.recordedFrom <= recordedAsOf AND (g.recordedTo IS NULL OR g.recordedTo > recordedAsOf)
  AND (g.validFrom IS NULL OR g.validFrom <= validAt) AND (g.validTo IS NULL OR g.validTo > validAt)
RETURN v.uid AS specVersion, g.validFrom AS validFrom, g.validFromBasis AS basis,
       CASE WHEN g.validTo IS NULL THEN 'END_UNKNOWN' ELSE 'BOUNDED' END AS endState
ORDER BY validFrom;

// Q-05b: the same at valid time 2020-06-01 (two candidates -> SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED for W10).
// status: executed
WITH datetime('2020-06-01T00:00:00Z') AS validAt, datetime('2026-10-04T23:00:00Z') AS recordedAsOf
MATCH (m:IngredientMaterial {uid: 'hu:material:chromadex-niagen'})-[g:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)
WHERE g.recordedFrom <= recordedAsOf AND (g.recordedTo IS NULL OR g.recordedTo > recordedAsOf)
  AND (g.validFrom IS NULL OR g.validFrom <= validAt) AND (g.validTo IS NULL OR g.validTo > validAt)
RETURN v.uid AS specVersion, g.validFrom AS validFrom, g.recordedFrom AS recordedFrom
ORDER BY validFrom;

// Q-05c: valid time 2020-06-01 as recorded before the late-arriving 2019 attachment (R = 2026-10-04T02:30Z): one row.
// status: executed
WITH datetime('2020-06-01T00:00:00Z') AS validAt, datetime('2026-10-04T02:30:00Z') AS recordedAsOf
MATCH (m:IngredientMaterial {uid: 'hu:material:chromadex-niagen'})-[g:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)
WHERE g.recordedFrom <= recordedAsOf AND (g.recordedTo IS NULL OR g.recordedTo > recordedAsOf)
  AND (g.validFrom IS NULL OR g.validFrom <= validAt) AND (g.validTo IS NULL OR g.validTo > validAt)
RETURN v.uid AS specVersion, g.validFrom AS validFrom, g.recordedFrom AS recordedFrom;

// Q-05d: exactly one NIAGEN material identity across both specification versions.
// status: executed
MATCH (m:BrandedIngredientMaterial) WHERE toLower(m.brandName) = 'niagen'
OPTIONAL MATCH (m)-[:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)
WITH collect(DISTINCT m.uid) AS materials, collect(DISTINCT v.uid) AS specVersions
RETURN size(materials) AS niagenMaterials, materials, specVersions;

// Q-06 (CQ-ID-C03 candidate; CQ-ST-01 material part): strain, deposits, current species, preparation viability.
// status: executed
MATCH (p:MicrobialPreparation {uid: 'hu:material:nct00934453-lgg-as-administered'})-[:HAS_STRAIN]->(s:MicrobialStrain)
OPTIONAL MATCH (s)-[so:STRAIN_OF]->(t:MicrobialTaxon) WHERE so.recordedTo IS NULL
RETURN s.strainDesignation AS strain, t.scientificName AS currentSpecies, t.taxonomyId AS speciesTaxonomyId,
       COLLECT { MATCH (s)-[:HAS_IDENTIFIER]->(i:Identifier) RETURN i.value ORDER BY i.value } AS identifiers,
       coalesce(p.viabilityState, 'NOT_STATED') AS viability,
       COLLECT { MATCH (a:Assertion {predicate: 'STRAIN_OF'})-[:HAS_SUBJECT]->(s) MATCH (a)-[:HAS_OBJECT]->(x) RETURN x.scientificName ORDER BY x.scientificName } AS allRecordedSpeciesAssignments;

// Q-07 (CL-001): a combination name never becomes a ChemicalSubstance; the legacy Compound has a disposition.
// status: executed
OPTIONAL MATCH (bad:ChemicalSubstance) WHERE toUpper(bad.name) = 'NRPT' OR toUpper(bad.preferredName) = 'NRPT'
WITH count(bad) AS nrptSubstances
MATCH (c:Compound {id: 'legacy-compound-nrpt'})<-[:PROPOSES_MATCH]-(h:ResolutionHypothesis)
RETURN nrptSubstances, h.resolutionStatus AS disposition,
       COLLECT { MATCH (h)-[:PROPOSES_MATCH]->(t) WHERE t <> c RETURN [l IN labels(t) WHERE NOT l IN ['Entity', 'VersionedState']][0] + ' ' + t.uid } AS denotes;

// Q-08 (CL-002): NAD+ resolves to exactly one identity, a ChemicalSubstance, via its chemical key.
// status: executed
MATCH (n) WHERE n.inchikey = 'BAWFJGJZGIEFAR-NNYOXOHSSA-O'
RETURN labels(n) AS labels, n.uid AS uid;

// Q-09 (CQ-ID-C02 candidate): botanical preparation identity facts.
// status: executed
MATCH (p:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'})-[:DERIVED_FROM_TAXON]->(t:BotanicalTaxon)
RETURN t.scientificName AS taxon, p.plantPart AS plantPart, p.preparationType AS preparationType, p.extractRatio AS extractRatio,
       p.extractRatioLow AS derLow, p.extractRatioHigh AS derHigh, p.solvent AS solvent,
       COLLECT { MATCH (p)-[q:QUANTITATIVELY_CONTAINS]->(c) RETURN c.name + ' ' + toString(q.quantityLow) + '-' + toString(q.quantityHigh) + q.unitCode } AS standardization;

// Q-10 (SR-01 failing case, load fx-91): which substance does each calculated amount of one component refer to?
// status: executed
MATCH (a:Assertion {basisKind: 'CALCULATED'})-[:HAS_SUBJECT]->(:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'})
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
RETURN a.uid AS calculatedAssertion, a.valueNumber AS amount, a.unitCode AS unit, o.preferredName AS refersTo,
       CASE WHEN o IS NULL THEN 'AMBIGUOUS_UNDER_FROZEN_INV_003' ELSE 'DIRECT' END AS referentResolution
ORDER BY calculatedAssertion;
