// =====================================================================================================================
// W10 operations: constraints, indexes and candidate validators for the evidence-assessment package
// Run: run-2026-10-04-fable51-01. Worker W10 (Opus 5.5). Target: Neo4j 5.26.31 Community (Enterprise lines marked).
// Statements are separated by ';' and never share variables. Validators return zero rows on a valid graph.
// Part A is idempotent (IF NOT EXISTS). Part B is read-only. Parameters for Part B:
//   $calibratedRatioMethods      list<string>  methods whose ratio bands are calibrated (EMPTY in this run: DEFERRED)
//   $calibratedCompositeMethods  list<string>  methods with a calibrated composite score (EMPTY in this run)
//   $useProfileAllowedKeys       list<string>  stored keys allowed on UseContextProfile (see 07-operations.md)
// =====================================================================================================================

// ---------------------------------------------------------------------------------------------------------------------
// Part A. Constraints and indexes (stored property names). Archetype-level uid uniqueness already exists in
// docs/schema/neo4j/constraints.cypher (entity_uid, evidence_assessment_uid ...); the per-label constraints below add the
// label-scoped lookup index that `MATCH (x:EvidenceApplicability {uid: $uid})` needs (Community: allowed).
// ---------------------------------------------------------------------------------------------------------------------

// status: run (Community 5.26.31: applied)
CREATE CONSTRAINT w10_evidence_applicability_uid IF NOT EXISTS FOR (n:EvidenceApplicability) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_applicability_dimension_uid IF NOT EXISTS FOR (n:ApplicabilityDimension) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_use_context_profile_uid IF NOT EXISTS FOR (n:UseContextProfile) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_endpoint_classification_uid IF NOT EXISTS FOR (n:EndpointClassification) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_result_interpretation_uid IF NOT EXISTS FOR (n:ResultInterpretation) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_evidence_synthesis_uid IF NOT EXISTS FOR (n:EvidenceSynthesis) REQUIRE n.uid IS UNIQUE;
// status: run
CREATE CONSTRAINT w10_evidence_strength_assessment_uid IF NOT EXISTS FOR (n:EvidenceStrengthAssessment) REQUIRE n.uid IS UNIQUE;

// QS-3a / CQ-EV-04 retrieval: dimensions by kind and verdict (same definition as the baseline index
// applicability_dimension_kind; IF NOT EXISTS makes the repeat a no-op when the baseline file ran first).
// status: run
CREATE INDEX applicability_dimension_kind IF NOT EXISTS FOR (d:ApplicabilityDimension) ON (d.dimension, d.verdict);
// CQ-ST-09 "what BellLabs learned in period P" (baseline index synthesis_recorded_at, repeated for standalone use).
// status: run
CREATE INDEX synthesis_recorded_at IF NOT EXISTS FOR (s:EvidenceSynthesis) ON (s.recordedAt);
// CQ-ST-09 "findings published in period P": relationship property index on TRIGGERED_BY.evidencePublishedAt.
// status: run
CREATE INDEX w10_triggered_by_published_at IF NOT EXISTS FOR ()-[t:TRIGGERED_BY]-() ON (t.evidencePublishedAt);
// CQ-ST-05 / V-215: INCLUDES_RESULT by role.
// status: run
CREATE INDEX w10_includes_result_role IF NOT EXISTS FOR ()-[i:INCLUDES_RESULT]-() ON (i.inputRole);
// CQ-ST-03: classifications by class and surrogate level.
// status: run
CREATE INDEX w10_endpoint_classification_class IF NOT EXISTS FOR (e:EndpointClassification) ON (e.endpointClass, e.surrogateValidationLevel);
// Assessment lookup by method version (re-run / migration batches; W10-V05, W10-V06).
// status: run
CREATE INDEX w10_applicability_method IF NOT EXISTS FOR (e:EvidenceApplicability) ON (e.methodVersion, e.status);

// Enterprise Edition only (rejected on Community 5.26.31; recorded, not applied):
// CREATE CONSTRAINT w10_assessment_method_exists IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.methodVersion IS NOT NULL;
// CREATE CONSTRAINT w10_assessment_recorded_at_exists IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.recordedAt IS NOT NULL;
// CREATE CONSTRAINT w10_assessment_recorded_at_type IF NOT EXISTS FOR (n:EvidenceAssessment) REQUIRE n.recordedAt IS :: ZONED DATETIME;
// CREATE CONSTRAINT w10_dimension_verdict_exists IF NOT EXISTS FOR (n:ApplicabilityDimension) REQUIRE n.verdict IS NOT NULL;
// CREATE CONSTRAINT w10_dimension_ratio_type IF NOT EXISTS FOR (n:ApplicabilityDimension) REQUIRE n.ratio IS :: FLOAT;
// CREATE CONSTRAINT w10_includes_result_role_exists IF NOT EXISTS FOR ()-[i:INCLUDES_RESULT]-() REQUIRE i.inputRole IS NOT NULL;
// CREATE CONSTRAINT w10_triggered_by_criterion_exists IF NOT EXISTS FOR ()-[t:TRIGGERED_BY]-() REQUIRE t.criterionCode IS NOT NULL;

// ---------------------------------------------------------------------------------------------------------------------
// Part B. Candidate validators W10-V01..W10-V16 (zero rows = valid). They complement baseline V-201..V-219c, V-237 and
// V-524, which are reused verbatim and not repeated here.
// ---------------------------------------------------------------------------------------------------------------------

// W10-V01 (INV-202): a dimension node belongs to exactly one EvidenceApplicability.
// status: run
MATCH (d:ApplicabilityDimension)
OPTIONAL MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d)
WITH d, count(ea) AS parents
WHERE parents <> 1
RETURN d.uid AS dimension, parents;

// W10-V02 (OPEN-QUESTIONS P1 applicability 1, CLOSED): dimensionClass is fixed by dimension.
// status: run
MATCH (d:ApplicabilityDimension)
WITH d, CASE
  WHEN d.dimension IN ['DOSE', 'SCHEDULE', 'DURATION', 'EXPOSURE'] THEN 'CONTINUOUS'
  WHEN d.dimension IN ['BACKGROUND_CONTEXT', 'RECENCY_AND_CORRECTIONS'] THEN 'EXPLANATION_ONLY'
  ELSE 'CATEGORICAL' END AS expected
WHERE d.dimensionClass IS NULL OR d.dimensionClass <> expected
RETURN d.uid AS dimension, d.dimension AS kind, d.dimensionClass AS recorded, expected;

// W10-V03 (INV-203, calculated kind): a stored ratio is targetValue / evidenceValue in one unit.
// status: run
MATCH (d:ApplicabilityDimension)
WHERE d.ratio IS NOT NULL
  AND (d.evidenceValue IS NULL OR d.targetValue IS NULL OR d.evidenceValue = 0 OR d.unitCode IS NULL
       OR abs(d.ratio - d.targetValue / d.evidenceValue) > 1.0e-9)
RETURN d.uid AS dimension, d.ratio AS ratio, d.evidenceValue AS evidenceValue, d.targetValue AS targetValue, d.unitCode AS unitCode;

// W10-V04 (calibration DEFERRED): no ratio band may be applied by an uncalibrated method. A continuous dimension may be
// MATCH only at identity ratio 1.0 unless its method is listed in $calibratedRatioMethods.
// status: run
MATCH (d:ApplicabilityDimension)
WHERE d.dimension IN ['DOSE', 'SCHEDULE', 'DURATION', 'EXPOSURE'] AND d.verdict = 'MATCH'
  AND NOT d.methodVersion IN $calibratedRatioMethods
  AND (d.ratio IS NULL OR abs(d.ratio - 1.0) > 1.0e-9)
RETURN d.uid AS dimension, d.dimension AS kind, d.ratio AS ratio, d.methodVersion AS method;

// W10-V05 (INV-204, extends V-207b): a composite score needs a calibrated composite method and every required dimension
// present and assessed (no MISSING, NOT_ASSESSED or UNKNOWN required dimension is ever averaged away).
// status: run
MATCH (ea:EvidenceApplicability)
WHERE ea.overallScore IS NOT NULL
OPTIONAL MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(e)
WITH ea, CASE WHEN e:Assertion
  THEN ['MATERIAL_IDENTITY', 'EXPOSURE', 'ROUTE', 'DURATION', 'POPULATION', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
  ELSE ['MATERIAL_IDENTITY', 'ACTIVE_COMPOSITION', 'DOSE', 'DOSAGE_FORM', 'ROUTE', 'SCHEDULE', 'DURATION', 'POPULATION', 'COMPARATOR', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY'] END AS required
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, required, collect(d) AS dims
WITH ea, [x IN required WHERE NOT x IN [d IN dims | d.dimension]] AS missing,
     [d IN dims WHERE d.dimension IN required AND d.verdict IN ['NOT_ASSESSED', 'UNKNOWN'] | d.dimension] AS unassessed
WHERE ea.methodVersion IS NULL OR NOT ea.methodVersion IN $calibratedCompositeMethods OR size(missing) > 0 OR size(unassessed) > 0
RETURN ea.uid AS compositeWithoutBasis, ea.methodVersion AS method, missing, unassessed;

// W10-V06: a dimension shares the method version (and assessment act) of its parent.
// status: run
MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WHERE d.methodVersion IS NULL OR d.methodVersion <> ea.methodVersion
RETURN ea.uid AS assessment, d.uid AS dimension, ea.methodVersion AS parentMethod, d.methodVersion AS dimensionMethod;

// W10-V07 (KCR-2a, like-to-like supersession): an applicability re-assessment keeps the same evidence target and use
// target, moves forward in recorded time, and closes the older node's recordedTo at the newer recordedAt.
// status: run
MATCH (n:EvidenceApplicability)-[s:SUPERSEDES]->(o:EvidenceApplicability)
OPTIONAL MATCH (n)-[:HAS_EVIDENCE_TARGET]->(ne)
OPTIONAL MATCH (o)-[:HAS_EVIDENCE_TARGET]->(oe)
OPTIONAL MATCH (n)-[:ASSESSES_APPLICABILITY_TO]->(nu)
OPTIONAL MATCH (o)-[:ASSESSES_APPLICABILITY_TO]->(ou)
WITH n, o, s, collect(DISTINCT ne.uid) AS ne, collect(DISTINCT oe.uid) AS oe, collect(DISTINCT nu.uid) AS nu, collect(DISTINCT ou.uid) AS ou
WHERE ne <> oe OR nu <> ou OR n.recordedAt <= o.recordedAt OR o.recordedTo IS NULL OR o.recordedTo <> n.recordedAt
   OR s.supersessionKind IS NULL OR s.recordedAt <> n.recordedAt
RETURN n.uid AS newer, o.uid AS older, ne = oe AS sameEvidenceTarget, nu = ou AS sameUseTarget;

// W10-V08 (INV-205, FI [SURROGATE_IN_CONTEXT, SURROGATE_IN_OTHER_CONTEXT]): a study-specific classification
// (CLASSIFIES_OUTCOME) may carry VALIDATED or REASONABLY_LIKELY only with a FULL context match to a cited context.
// status: run
MATCH (ec:EndpointClassification)-[:CLASSIFIES_OUTCOME]->(od)
WHERE ec.surrogateValidationLevel IN ['VALIDATED', 'REASONABLY_LIKELY']
  AND (coalesce(ec.contextMatch, 'NONE') <> 'FULL'
       OR NOT EXISTS { MATCH (ec)-[:COMPARED_WITH_CONTEXT]->(:EndpointClassification {surrogateValidationLevel: ec.surrogateValidationLevel}) })
RETURN ec.uid AS transferredSurrogateStatus, od.uid AS outcome, ec.contextMatch AS contextMatch;

// W10-V09 (FI [NOT_STATISTICALLY_SIGNIFICANT, NO_EFFECT]; CQ-ST-10): no-meaningful-effect and meaningfulness verdicts
// need a threshold with a source; no threshold means UNDETERMINED (or null = not assessed).
// status: run
MATCH (ri:ResultInterpretation)
WHERE (ri.interpretation = 'EVIDENCE_OF_NO_MEANINGFUL_EFFECT' OR ri.meaningfulnessVerdict IN ['MEANINGFUL', 'NOT_MEANINGFUL'])
  AND (ri.thresholdValue IS NULL OR ri.thresholdUnit IS NULL OR NOT EXISTS { MATCH (ri)-[:USES_THRESHOLD_SOURCE]->(:SourceLocator) })
RETURN ri.uid AS interpretationWithoutThreshold, ri.interpretation AS interpretation, ri.meaningfulnessVerdict AS meaningfulness;

// W10-V10: one interpretation reads exactly one result, and a NOT_SIGNIFICANT result is never EFFECT_DETECTED.
// status: run
MATCH (ri:ResultInterpretation)
OPTIONAL MATCH (ri)-[:INTERPRETS_RESULT_OF]->(r:StudyResult)
WITH ri, collect(r) AS rs
WHERE size(rs) <> 1 OR (ri.interpretation = 'EFFECT_DETECTED' AND rs[0].statisticalConclusion = 'NOT_SIGNIFICANT')
RETURN ri.uid AS interpretation, size(rs) AS results, [x IN rs | x.statisticalConclusion] AS conclusions;

// W10-V11 (INV-206 full text; V-215 checks CONFIRMATORY only): after a NOT_SIGNIFICANT primary prespecified result, the
// same study's secondary, subgroup, exploratory, post hoc or within-arm results enter only as SUPPORTIVE or
// HYPOTHESIS_GENERATING.
// status: run
MATCH (syn:EvidenceSynthesis)-[i:INCLUDES_RESULT]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE (r.analysisKind IN ['SECONDARY_PRESPECIFIED', 'SUBGROUP_PRESPECIFIED', 'SUBGROUP_POST_HOC', 'EXPLORATORY'] OR r.comparisonKind = 'WITHIN_ARM_CHANGE')
  AND NOT i.inputRole IN ['SUPPORTIVE', 'HYPOTHESIS_GENERATING']
  AND EXISTS { MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'}) }
RETURN syn.uid AS synthesis, r.uid AS result, r.analysisKind AS analysisKind, i.inputRole AS role;

// W10-V11b (method rule synthesis-v0.1, stricter than INV-206): post hoc subgroup and exploratory results after a null
// primary enter only as HYPOTHESIS_GENERATING.
// status: run
MATCH (syn:EvidenceSynthesis)-[i:INCLUDES_RESULT]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE r.analysisKind IN ['SUBGROUP_POST_HOC', 'EXPLORATORY'] AND i.inputRole <> 'HYPOTHESIS_GENERATING'
  AND EXISTS { MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'}) }
RETURN syn.uid AS synthesis, r.uid AS posthocResult, i.inputRole AS role;

// W10-V12 (CQ-ST-09 clock consistency): a trigger's evidencePublishedAt is not after the version's evidenceCutoff, and
// equals the Publication's publishedAt date when the trigger is a Publication with a known date.
// status: run
MATCH (syn:EvidenceSynthesis)-[t:TRIGGERED_BY]->(x)
WHERE (t.evidencePublishedAt IS NOT NULL AND syn.evidenceCutoff IS NOT NULL AND t.evidencePublishedAt > syn.evidenceCutoff)
   OR (x:Publication AND x.publishedAt IS NOT NULL AND t.evidencePublishedAt IS NOT NULL AND date(x.publishedAt) <> t.evidencePublishedAt)
RETURN syn.uid AS synthesis, x.uid AS trigger, t.evidencePublishedAt AS evidencePublishedAt, syn.evidenceCutoff AS cutoff;

// W10-V13 (like-to-like): a synthesis version supersedes a version about the same claim.
// status: run
MATCH (n:EvidenceSynthesis)-[:SUPERSEDES]->(o:EvidenceSynthesis)
OPTIONAL MATCH (n)-[:ASSESSES_CLAIM]->(nc)
OPTIONAL MATCH (o)-[:ASSESSES_CLAIM]->(oc)
WITH n, o, collect(DISTINCT nc.uid) AS ncs, collect(DISTINCT oc.uid) AS ocs
WHERE size(ncs) <> 1 OR ncs <> ocs
RETURN n.uid AS newer, o.uid AS older, ncs, ocs;

// W10-V14 (INV-506, round 0008): a UseContextProfile is non-personal: only declared keys, no private uid values.
// status: run
MATCH (p:UseContextProfile)
WITH p, [k IN keys(p) WHERE NOT k IN $useProfileAllowedKeys] AS extraKeys
WHERE size(extraKeys) > 0 OR any(k IN keys(p) WHERE p[k] IS :: STRING AND p[k] STARTS WITH 'hu:private-')
RETURN p.uid AS profile, extraKeys;

// W10-V15 (INV-209): strength grades name a scheme and criteria; a legacy hint migrates only as PROPOSED.
// status: run
MATCH (es:EvidenceStrengthAssessment)
WHERE es.scheme IS NULL OR es.level IS NULL
   OR (es.scheme <> 'LEGACY_UNSPECIFIED' AND es.scheme <> 'GRADE' AND size(coalesce(es.criteria, [])) = 0)
   OR (es.scheme = 'LEGACY_UNSPECIFIED' AND es.status <> 'PROPOSED')
   OR NOT EXISTS { MATCH (es)-[:ASSESSES_STRENGTH_OF]->() }
RETURN es.uid AS strengthAssessment, es.scheme AS scheme, es.level AS level;

// W10-V16 (round 0002 R4 "copied level, never recomputed"): an assessed STUDY_DESIGN_AND_QUALITY dimension cites an
// EvidenceStrengthAssessment; an assessed OUTCOME_RELEVANCE dimension with an endpoint-class category cites an
// EndpointClassification whose endpointClass equals that category.
// status: run
MATCH (d:ApplicabilityDimension)
WHERE (d.dimension = 'STUDY_DESIGN_AND_QUALITY' AND d.verdict IN ['MATCH', 'PARTIAL', 'MISMATCH', 'UNKNOWN']
       AND NOT EXISTS { MATCH (d)-[:CONSIDERS_ASSESSMENT]->(:EvidenceStrengthAssessment) })
   OR (d.dimension = 'OUTCOME_RELEVANCE' AND d.evidenceCategory IN ['BIOMARKER_NOT_SURROGATE', 'SURROGATE_ENDPOINT', 'INTERMEDIATE_CLINICAL_ENDPOINT', 'CLINICAL_OUTCOME']
       AND NOT EXISTS { MATCH (d)-[:CONSIDERS_ASSESSMENT]->(ec:EndpointClassification) WHERE ec.endpointClass = d.evidenceCategory })
RETURN d.uid AS dimensionWithoutCopiedAssessment, d.dimension AS kind, d.verdict AS verdict;

// W10-V16b (INV-502): an assessment is never recorded before a snapshot it cites was retrieved (no backdating).
// status: run
MATCH (x:EvidenceAssessment)-[:SUPPORTED_BY|USES_THRESHOLD_SOURCE]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
WHERE x.recordedAt IS NOT NULL AND s.retrievedAt IS NOT NULL AND x.recordedAt < s.retrievedAt
RETURN x.uid AS backdatedAssessment, labels(x) AS labels, x.recordedAt AS recordedAt, s.uid AS snapshot, s.retrievedAt AS retrievedAt;
