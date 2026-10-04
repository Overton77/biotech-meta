// W11 competency-question queries over fixtures 01-04 (+ ../../../../../examples/filing-vs-capability.cypher).
// Each statement is self-contained (no variables cross ';'); parameters are written as literals so the file runs alone.
// Expected rows are documented in ../06-fixtures-and-queries.md; observed rows are in the completion report run log.

// Q-MF04-a (CQ-MF-04): currently recorded capability episodes of a facility, in valid-time order, with source kinds.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'})-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE h.recordedTo IS NULL
OPTIONAL MATCH (c)-[:CAPABILITY_FOR_PROCESS]->(p:ManufacturingProcess)
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source)
RETURN c.stage AS stage, toString(h.validFrom) AS validFrom, h.validFromPrecision AS fromPrecision, toString(h.validTo) AS validTo,
       p.processKind AS processKind, collect(DISTINCT s.sourceKind) AS sourceKinds
ORDER BY h.validFrom;

// Q-MF04-b (CQ-MF-04, bitemporal): stage at valid time 2023-12-01 as currently recorded.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'})-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE h.recordedTo IS NULL
  AND (h.validFrom IS NULL OR h.validFrom <= datetime('2023-12-01T00:00:00Z'))
  AND (h.validTo IS NULL OR datetime('2023-12-01T00:00:00Z') < h.validTo)
RETURN c.stage AS stage, h.relationshipUid AS episode;

// Q-MF04-c (CQ-MF-04, bitemporal): stage at valid time 2023-12-01 as BellLabs had recorded it at 2026-10-04T01:15Z
// (before the FY2024 10-K was ingested): the open-ended PLANNED episode -- a 'possibly still planned' answer, not a fact.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'})-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE h.recordedFrom <= datetime('2026-10-04T01:15:00Z') AND (h.recordedTo IS NULL OR datetime('2026-10-04T01:15:00Z') < h.recordedTo)
  AND (h.validFrom IS NULL OR h.validFrom <= datetime('2023-12-01T00:00:00Z'))
  AND (h.validTo IS NULL OR datetime('2023-12-01T00:00:00Z') < h.validTo)
RETURN c.stage AS stage, h.relationshipUid AS episode, h.validTo IS NULL AS openEnded;

// Q-MF05 (CQ-MF-05): what the issuer disclosed versus what it promoted, side by side, with any SUPPORT adjudication and
// whether the stated capability is attached (relied on).
// status: run
MATCH (a:Assertion {predicate: 'HAS_CAPABILITY_STATE'})-[:ASSERTED_BY]->(:Organization {uid: 'hu:org:natural-alternatives-international-inc'})
MATCH (a)-[:HAS_OBJECT]->(c:ManufacturingCapability)
MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source)
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
WITH a, c, collect(DISTINCT s.sourceKind) AS kinds, collect(DISTINCT j.verdict) AS verdicts
RETURN kinds AS sourceKinds, c.stage AS stage, a.status AS captureStatus, a.statedTense AS tense, verdicts,
       EXISTS { MATCH ()-[h:HAS_CAPABILITY_STATE {assertionUid: a.uid}]->() WHERE h.recordedTo IS NULL } AS attachedNow
ORDER BY attachedNow DESC, stage;

// Q-MF-C01 (candidate CQ-MF-C01): stated capacities with basis and unit, holder, asserter and attachment.
// status: run
MATCH (a:Assertion {predicate: 'HAS_CAPABILITY_STATE'})-[:HAS_OBJECT]->(c:ManufacturingCapability)
MATCH (a)-[:HAS_SUBJECT]->(holder)
MATCH (a)-[:ASSERTED_BY]->(who)
WHERE c.capacityValue IS NOT NULL OR c.capacityVerbatim IS NOT NULL
RETURN holder.uid AS holder, who.uid AS assertedBy, c.stage AS stage, c.capacityValue AS value, c.capacityUnitCode AS unit,
       c.capacityBasis AS basis, toString(a.validFrom) AS validFrom,
       EXISTS { MATCH ()-[h:HAS_CAPABILITY_STATE {assertionUid: a.uid}]->() WHERE h.recordedTo IS NULL } AS attached
ORDER BY holder, basis;

// Q-MF01 (CQ-MF-01): for one material, who supplies it, which process produces it, who performs that process, and who
// owns its specification -- each from its own assertion and asserter.
// status: run
MATCH (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
OPTIONAL MATCH (m)-[pp:PRODUCED_BY_PROCESS]->(p:ManufacturingProcess)
OPTIONAL MATCH (perf)-[:PERFORMS_PROCESS]->(p)
OPTIONAL MATCH (sa:Assertion {predicate: 'SUPPLIES_INGREDIENT_MATERIAL'})-[:HAS_OBJECT]->(m)
OPTIONAL MATCH (sa)-[:HAS_SUBJECT]->(supplier)
OPTIONAL MATCH (m)-[:GOVERNED_BY_SPECIFICATION]->(:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(spec:ManufacturingSpecification)
OPTIONAL MATCH (oa:Assertion {predicate: 'OWNS_SPECIFICATION'})-[:HAS_OBJECT]->(spec)
OPTIONAL MATCH (oa)-[:HAS_SUBJECT]->(owner)
RETURN collect(DISTINCT p.uid) AS producedByProcesses, collect(DISTINCT perf.uid) AS processPerformers,
       collect(DISTINCT supplier.uid) AS suppliers, collect(DISTINCT spec.uid) AS specifications, collect(DISTINCT owner.uid) AS specificationOwners;

// Q-MF06-a (CQ-MF-06): quality signals for the NAI Carlsbad facility and its operator -- registration statuses, certification
// coverage, cGMP claims, certification claims, inspections -- each in its own column; a claim is never counted as either.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (o:Organization {uid: 'hu:org:natural-alternatives-international-inc'})
RETURN
  COUNT { (st:RegulatoryStatus {statusKind: 'ESTABLISHMENT_REGISTRATION'})-[:STATUS_OF]->(f) } AS registrationStatuses,
  COUNT { (:CertificationScope)-[:COVERS]->(f) } AS certificationScopesCoveringFacility,
  [(c:Assertion {predicate: 'CLAIMS_CGMP_COMPLIANCE'})-[:HAS_SUBJECT]->(o) | c.valueString] AS cgmpClaimsByOperator,
  [(c:Assertion {predicate: 'CLAIMS_THIRD_PARTY_CERTIFICATION'})-[:HAS_SUBJECT]->(f) | c.status + ': ' + c.valueString] AS certificationClaimsAboutFacility,
  COUNT { (i:RegulatoryInspection)-[]->(f) } AS inspectionsCaptured;

// Q-MF06-b (CQ-MF-06): the 503B facility -- an agency registration record, no inspection yet, no cGMP claim captured.
// status: run
MATCH (f:Facility {uid: 'hu:facility:navinta-iii-boca-raton-503b'})
OPTIONAL MATCH (st:RegulatoryStatus)-[r:STATUS_OF]->(f)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN st.statusKind AS statusKind, toString(r.validFrom) AS registeredFrom, l.exact AS agencyRecordRow,
       COUNT { (c:Assertion {predicate: 'CLAIMS_CGMP_COMPLIANCE'})-[:HAS_SUBJECT]->(f) } AS cgmpClaims;

// Q-MF-C02 (candidate CQ-MF-C02): which specification versions govern a material, how completely their criteria were
// captured, and the criteria that differ between versions of the same specification.
// status: run
MATCH (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'})-[g:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s:ManufacturingSpecification)
WHERE g.recordedTo IS NULL
OPTIONAL MATCH (c:SpecificationCriterion)-[:CRITERION_OF_SPECIFICATION]->(v)
WITH s, v, c ORDER BY c.analyte
RETURN s.uid AS specification, v.name AS version, v.criteriaCaptureCompleteness AS capture,
       collect(c.analyte + ' ' + c.comparator + ' ' + toString(c.threshold) + coalesce('-' + toString(c.thresholdUpper), '') + ' ' + c.unitCode + ' [' + c.limitStage + ']') AS criteria
ORDER BY version;

// Q-MF-C03 (candidate CQ-MF-C03): did a specification version change create a new material identity? Count material uids
// governed by any version of the Niagen specification (expected 1).
// status: run
MATCH (m:IngredientMaterial)-[:GOVERNED_BY_SPECIFICATION]->(v:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(:ManufacturingSpecification {uid: 'hu:specification:niagen-ingredient-specification'})
RETURN count(DISTINCT m) AS materialIdentities, count(DISTINCT v) AS versions, collect(DISTINCT m.uid) AS materials;

// Q-MF-C04 (candidate CQ-MF-C04): ordered inputs and outputs of a process by step, with role and identity kind.
// status: run
MATCH (p:ManufacturingProcess {uid: 'hu:process:nrc-two-step-synthesis-as-described-grn-000635'})-[hs:HAS_STEP]->(st:ManufacturingStep)-[io:INPUTS|OUTPUTS]->(x)
RETURN hs.orderIndex AS step, type(io) AS direction, io.orderIndex AS ord, io.ioRole AS role, io.asReportedName AS asReported,
       CASE WHEN x:IngredientMaterial THEN 'IngredientMaterial' ELSE 'ChemicalSubstance' END AS identityKind, x.uid AS uid
ORDER BY step, direction, ord;

// Q-MF-C05 (candidate CQ-MF-C05): one material node is both a process input and a formulation component material.
// status: run
MATCH (m:IngredientMaterial {uid: 'hu:material:nicotinamide-usp-grade'})
RETURN COUNT { (:ManufacturingStep)-[:INPUTS]->(m) } AS usedAsProcessInput,
       COUNT { (:IngredientComponent)-[:USES_MATERIAL]->(m) } AS usedAsComponentMaterial,
       COUNT { (n:Material) WHERE n.name = m.name } AS duplicateLiveMaterialNodes;

// Q-PF01-w11 (CQ-PF-01, lineage only): the mass basis a specification's assay states (material as is, wt%), which a
// declared-amount calculation must not silently convert to active moiety.
// status: run
MATCH (c:SpecificationCriterion)-[:CRITERION_OF_SPECIFICATION]->(v:SpecificationVersion)<-[:GOVERNED_BY_SPECIFICATION]-(m:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
WHERE c.unitCode = '%' AND c.analyte STARTS WITH 'nicotinamide riboside chloride'
RETURN v.name AS version, c.analyte AS analyte, c.comparator AS comparator, c.threshold AS threshold, c.limitStage AS limitStage;
