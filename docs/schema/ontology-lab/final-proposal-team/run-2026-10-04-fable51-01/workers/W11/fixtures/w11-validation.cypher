// W11 validation queries (proposed). Zero rows = valid unless marked informational. Every statement binds its own
// variables; nothing is shared across ';'. Run on Neo4j 5.26.31 Community (embedded) on 2026-10-04 against
// fixtures 01-04 (see ../06-fixtures-and-queries.md for expected and observed rows). The baseline V-324/V-325 are in
// ../../../../../neo4j/validation.cypher; V-324r below is a proposed revision (W11-SR-11).

// V-324r: an OPERATING capability episode needs an authorizing assertion supported by an allowlisted non-marketing
// source kind, or a current SUPPORT adjudication with verdict SUPPORTED (INV-305). Revision of V-324: the baseline
// denylist ['MARKETING_PAGE','THIRD_PARTY_DIRECTORY','PRESS_RELEASE'] lets ORGANIZATION_WEBPAGE, SELF_DISCLOSURE_PAGE,
// MANUFACTURER_LABEL_PAGE, MARKETPLACE_LISTING, NEWSLETTER or podcast kinds authorize OPERATING; an allowlist does not.
// status: run
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE c.stage = 'OPERATING'
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
WHERE a IS NULL
   OR (NOT any(k IN kinds WHERE k IN ['SECURITIES_FILING', 'REGULATORY_RECORD', 'AUDIT_REPORT', 'CERTIFICATION_LISTING', 'LEGAL_RECORD'])
       AND NOT EXISTS {
         MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
         WHERE j.verdict = 'SUPPORTED' AND j.recordedTo IS NULL
       })
RETURN holder.uid AS holderUid, h.relationshipUid AS episode, c.uid AS capabilityUid, kinds AS supportingSourceKinds;

// V-W11-01: asserted-edge projection fidelity for W11 asserted relationship types. The cited assertion exists, its
// predicate equals the edge type, its subject is the edge start, its object is the edge end, and the episode carries
// the assertion's valid bounds and is not recorded before it (INV-503, INV-502; generalizes V-504/V-505, which list
// only HAS_STATE-family types). Catches "a PLANNED assertion authorizes an OPERATING edge" (PLANNED_CAPABILITY ->
// OPERATING_CAPABILITY) and "a CLAIMS_CGMP_COMPLIANCE assertion authorizes an edge" (CLAIMS_CGMP_COMPLIANCE -> CGMP_COMPLIANT).
// status: run
MATCH (x)-[r:HAS_CAPABILITY_STATE|GOVERNED_BY_SPECIFICATION|PRODUCED_BY_PROCESS|INPUTS|OUTPUTS|PERFORMS_PROCESS|HOSTS_PROCESS]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, r, y, a,
     [v IN [
       CASE WHEN r.assertionUid IS NULL OR r.recordedFrom IS NULL OR r.relationshipUid IS NULL THEN 'MISSING_EPISODE_FIELDS' END,
       CASE WHEN r.assertionUid IS NOT NULL AND a IS NULL THEN 'CITED_ASSERTION_MISSING' END,
       CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } THEN 'SUBJECT_MISMATCH' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) } THEN 'OBJECT_MISMATCH' END,
       CASE WHEN a IS NOT NULL AND (coalesce(toString(r.validFrom), '-') <> coalesce(toString(a.validFrom), '-')
                                    OR coalesce(toString(r.validTo), '-') <> coalesce(toString(a.validTo), '-')) THEN 'VALID_TIME_DIFFERS' END,
       CASE WHEN a IS NOT NULL AND r.recordedFrom < a.recordedAt THEN 'EPISODE_BEFORE_ASSERTION' END
     ] WHERE v IS NOT NULL] AS problems
WHERE size(problems) > 0
RETURN type(r) AS relType, r.relationshipUid AS episode, x.uid AS fromUid, y.uid AS toUid, problems;

// V-W11-02: HAS_CAPABILITY_STATE is EXCLUSIVE per holder and capability line (process, material) (W11-SR-04): two
// different states of one line must not DEFINITELY overlap in valid and recorded time. Null bounds are possible
// overlap only (reported by V-W11-02b).
// status: run
MATCH (x)-[r1:HAS_CAPABILITY_STATE]->(c1:ManufacturingCapability), (x)-[r2:HAS_CAPABILITY_STATE]->(c2:ManufacturingCapability)
WHERE elementId(r1) < elementId(r2) AND c1 <> c2
OPTIONAL MATCH (c1)-[:CAPABILITY_FOR_PROCESS]->(p1)
OPTIONAL MATCH (c2)-[:CAPABILITY_FOR_PROCESS]->(p2)
OPTIONAL MATCH (c1)-[:CAPABILITY_FOR_MATERIAL]->(m1)
OPTIONAL MATCH (c2)-[:CAPABILITY_FOR_MATERIAL]->(m2)
WITH x, r1, r2, c1, c2, p1, p2, m1, m2
WHERE coalesce(p1.uid, '-') = coalesce(p2.uid, '-') AND coalesce(m1.uid, '-') = coalesce(m2.uid, '-')
  AND r1.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validFrom IS NOT NULL AND r2.validTo IS NOT NULL
  AND r1.validFrom < r2.validTo AND r2.validFrom < r1.validTo
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
RETURN x.uid AS holderUid, c1.uid AS state1, c2.uid AS state2, r1.relationshipUid AS episode1, r2.relationshipUid AS episode2;

// V-W11-02b (informational, review queue): POSSIBLE overlap of two states of one capability line caused by a null bound.
// status: run
MATCH (x)-[r1:HAS_CAPABILITY_STATE]->(c1:ManufacturingCapability), (x)-[r2:HAS_CAPABILITY_STATE]->(c2:ManufacturingCapability)
WHERE elementId(r1) < elementId(r2) AND c1 <> c2
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validTo IS NULL)
  AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
  AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
  AND coalesce([(c1)-[:CAPABILITY_FOR_PROCESS]->(p) | p.uid][0], '-') = coalesce([(c2)-[:CAPABILITY_FOR_PROCESS]->(p) | p.uid][0], '-')
  AND coalesce([(c1)-[:CAPABILITY_FOR_MATERIAL]->(m) | m.uid][0], '-') = coalesce([(c2)-[:CAPABILITY_FOR_MATERIAL]->(m) | m.uid][0], '-')
RETURN x.uid AS holderUid, c1.uid AS state1, c2.uid AS state2;

// V-W11-03: targetOperationalDate is PLANNED-only forward-looking payload and carries its precision; an OPERATING (or any
// non-PLANNED) state with a target date is a planned state read as operating.
// status: run
MATCH (c:ManufacturingCapability)
WHERE (c.targetOperationalDate IS NOT NULL AND c.stage <> 'PLANNED')
   OR (c.targetOperationalDate IS NOT NULL AND c.targetOperationalDatePrecision IS NULL)
RETURN c.uid AS capabilityUid, c.stage AS stage, c.targetOperationalDate AS targetOperationalDate;

// V-W11-04: one capability state has at most one holder, and stage is a known CapabilityStage value.
// status: run
MATCH (c:ManufacturingCapability)
OPTIONAL MATCH (h)-[:HAS_CAPABILITY_STATE]->(c)
WITH c, count(DISTINCT h) AS holders
WHERE holders > 1 OR c.stage IS NULL OR NOT c.stage IN ['OPERATING', 'PILOTING', 'PLANNED', 'SUSPENDED', 'DISCONTINUED']
RETURN c.uid AS capabilityUid, c.stage AS stage, holders;

// V-W11-05: capacity coherence. A value needs a UCUM unit and a NAMEPLATE or UTILIZED basis; NOT_REPORTED has no value;
// '%' is a utilization rate (UTILIZED only, 0..100).
// status: run
MATCH (c:ManufacturingCapability)
WHERE (c.capacityValue IS NOT NULL AND (c.capacityUnitCode IS NULL OR NOT coalesce(c.capacityBasis, '-') IN ['NAMEPLATE', 'UTILIZED']))
   OR (c.capacityBasis = 'NOT_REPORTED' AND c.capacityValue IS NOT NULL)
   OR (c.capacityUnitCode = '%' AND (c.capacityBasis <> 'UTILIZED' OR c.capacityValue < 0 OR c.capacityValue > 100))
   OR (c.capacityBasis IS NOT NULL AND NOT c.capacityBasis IN ['NAMEPLATE', 'UTILIZED', 'NOT_REPORTED'])
RETURN c.uid AS capabilityUid, c.capacityValue AS value, c.capacityUnitCode AS unit, c.capacityBasis AS basis;

// V-W11-06: a CLAIMS_CGMP_COMPLIANCE assertion never authorizes or derives any relationship (forbidden implication
// CLAIMS_CGMP_COMPLIANCE -> CGMP_COMPLIANT; a claim is not certification, inspection or registration).
// status: run
MATCH (a:Assertion {predicate: 'CLAIMS_CGMP_COMPLIANCE'})
MATCH ()-[r]->()
WHERE r.assertionUid = a.uid OR r.projectionOfAssertionUid = a.uid OR a.uid IN coalesce(r.derivedFromAssertionUids, [])
RETURN a.uid AS claimUid, type(r) AS relType, r.relationshipUid AS edge;

// V-W11-07: GOVERNED_BY_SPECIFICATION is EXCLUSIVE per material and specification (W11-SR-04): two versions of ONE
// specification never DEFINITELY govern one material at the same valid and recorded time.
// status: run
MATCH (m)-[g1:GOVERNED_BY_SPECIFICATION]->(v1:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s:ManufacturingSpecification),
      (m)-[g2:GOVERNED_BY_SPECIFICATION]->(v2:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s)
WHERE elementId(g1) < elementId(g2) AND v1 <> v2
  AND g1.validFrom IS NOT NULL AND g1.validTo IS NOT NULL AND g2.validFrom IS NOT NULL AND g2.validTo IS NOT NULL
  AND g1.validFrom < g2.validTo AND g2.validFrom < g1.validTo
  AND (g1.recordedTo IS NULL OR g2.recordedFrom < g1.recordedTo)
  AND (g2.recordedTo IS NULL OR g1.recordedFrom < g2.recordedTo)
RETURN m.uid AS materialUid, s.uid AS specificationUid, v1.uid AS version1, v2.uid AS version2;

// V-W11-07b (informational): POSSIBLE overlap of two versions of one specification on one material (null bounds); the
// review task is to find when the earlier version stopped governing, not to delete either.
// status: run
MATCH (m)-[g1:GOVERNED_BY_SPECIFICATION]->(v1:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s:ManufacturingSpecification),
      (m)-[g2:GOVERNED_BY_SPECIFICATION]->(v2:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s)
WHERE elementId(g1) < elementId(g2) AND v1 <> v2 AND g1.recordedTo IS NULL AND g2.recordedTo IS NULL
  AND (g1.validFrom IS NULL OR g1.validTo IS NULL OR g2.validFrom IS NULL OR g2.validTo IS NULL)
  AND (g1.validTo IS NULL OR g2.validFrom IS NULL OR g2.validFrom < g1.validTo)
  AND (g2.validTo IS NULL OR g1.validFrom IS NULL OR g1.validFrom < g2.validTo)
RETURN m.uid AS materialUid, s.uid AS specificationUid, v1.uid AS version1, v2.uid AS version2;

// V-W11-08: specification structure. Every SpecificationVersion has exactly one VERSION_OF_SPECIFICATION, a stateType and a
// 'sha256:' payloadHash (D-016); every ManufacturingSpecification has at least one version and a specificationKind.
// status: run
MATCH (v:SpecificationVersion)
OPTIONAL MATCH (v)-[:VERSION_OF_SPECIFICATION]->(s:ManufacturingSpecification)
WITH v, count(s) AS specs
WHERE specs <> 1 OR v.stateType IS NULL OR v.payloadHash IS NULL OR NOT v.payloadHash STARTS WITH 'sha256:'
RETURN 'VERSION' AS kind, v.uid AS uid, specs AS count
UNION
MATCH (s:ManufacturingSpecification)
WHERE s.specificationKind IS NULL OR NOT EXISTS { MATCH (:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s) }
RETURN 'SPECIFICATION' AS kind, s.uid AS uid, 0 AS count;

// V-W11-09: criteria bookkeeping. criteriaCount equals the attached criteria; COMPLETE capture has a digest; UNKNOWN capture
// has no digest and no count (unknown is never "no criteria"). Criterion edge name per W11-SR-03 (W12).
// status: run
MATCH (v:SpecificationVersion)
OPTIONAL MATCH (c:SpecificationCriterion)-[:CRITERION_OF_SPECIFICATION]->(v)
WITH v, count(c) AS attached
WHERE (v.criteriaCount IS NOT NULL AND v.criteriaCount <> attached)
   OR (v.criteriaCaptureCompleteness = 'COMPLETE' AND v.criteriaDigest IS NULL)
   OR (v.criteriaCaptureCompleteness = 'UNKNOWN' AND (v.criteriaDigest IS NOT NULL OR v.criteriaCount IS NOT NULL))
RETURN v.uid AS versionUid, v.criteriaCount AS stated, attached, v.criteriaCaptureCompleteness AS completeness;

// V-W11-10: HAS_STEP is manufacturing-only (D-004) and each step belongs to exactly one process with a unique orderIndex.
// status: run
MATCH (x)-[r:HAS_STEP]->(y)
WHERE NOT (x:ManufacturingProcess AND y:ManufacturingStep)
RETURN 'HAS_STEP_OUTSIDE_MANUFACTURING' AS violation, x.uid AS fromUid, y.uid AS toUid
UNION
MATCH (s:ManufacturingStep)
OPTIONAL MATCH (p:ManufacturingProcess)-[:HAS_STEP]->(s)
WITH s, count(p) AS processes
WHERE processes <> 1
RETURN 'STEP_PROCESS_COUNT' AS violation, s.uid AS fromUid, toString(processes) AS toUid
UNION
MATCH (p:ManufacturingProcess)-[r1:HAS_STEP]->(s1), (p)-[r2:HAS_STEP]->(s2)
WHERE elementId(r1) < elementId(r2) AND r1.orderIndex IS NOT NULL AND r1.orderIndex = r2.orderIndex
RETURN 'DUPLICATE_ORDER_INDEX' AS violation, p.uid AS fromUid, s1.uid + ' / ' + s2.uid AS toUid;

// V-W11-11 (informational): two different IngredientMaterials governed by versions of the same ManufacturingSpecification.
// Either legitimate (several materials conform to one compendial monograph) or a spurious identity split created when a
// specification version changed (SPECIFICATION_VERSION_CHANGE -> MATERIAL_IDENTITY_CHANGE is forbidden). Review queue.
// status: run
MATCH (m1:IngredientMaterial)-[:GOVERNED_BY_SPECIFICATION]->(:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s:ManufacturingSpecification),
      (m2:IngredientMaterial)-[:GOVERNED_BY_SPECIFICATION]->(:SpecificationVersion)-[:VERSION_OF_SPECIFICATION]->(s)
WHERE m1.uid < m2.uid
RETURN DISTINCT s.uid AS specificationUid, s.specificationKind AS kind, m1.uid AS material1, m2.uid AS material2;

// V-W11-12: process I/O targets are IngredientMaterial or ChemicalSubstance; no retired live Material node remains
// (migration check, CL-005/D-008); INPUTS/OUTPUTS start only at a ManufacturingProcess or ManufacturingStep.
// status: run
MATCH (x)-[r:INPUTS|OUTPUTS]->(y)
WHERE NOT (x:ManufacturingProcess OR x:ManufacturingStep) OR NOT (y:IngredientMaterial OR y:ChemicalSubstance)
RETURN 'IO_ENDPOINT' AS violation, type(r) AS relType, x.uid AS fromUid, y.uid AS toUid
UNION
MATCH (n:Material)
WHERE NOT n:IngredientMaterial
RETURN 'LIVE_MATERIAL_NOT_MIGRATED' AS violation, 'n/a' AS relType, coalesce(n.uid, n.id) AS fromUid, null AS toUid;

// V-W11-13: a specification owner is not thereby a performer (OWNS_SPECIFICATION -> PERFORMS_PROCESS forbidden,
// W11-SR-02): PERFORMS_PROCESS must not be derived from, or cite, an OWNS_SPECIFICATION or SUPPLIES_INGREDIENT_MATERIAL
// assertion (V-W11-01 already reports the asserted form as CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE).
// status: run
MATCH (o)-[r:PERFORMS_PROCESS]->(p)
WHERE any(u IN coalesce(r.derivedFromAssertionUids, []) + [coalesce(r.projectionOfAssertionUid, '-')]
          WHERE EXISTS { MATCH (a:Assertion {uid: u}) WHERE a.predicate IN ['OWNS_SPECIFICATION', 'SUPPLIES_INGREDIENT_MATERIAL'] })
RETURN o.uid AS performerUid, p.uid AS processUid;
