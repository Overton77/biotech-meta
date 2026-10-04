// =====================================================================================================================
// W10 queries (one per Essential CQ covered, plus minimal-pair readers). Run after: inherited study-vs-product-mismatch,
// w10-01 .. w10-05. Uids are literals (no parameters) so the file runs as-is; expected rows are in 06-fixtures-and-queries.md.
// =====================================================================================================================

// Q01 QS-3a (query-shapes.md, verbatim body) over three assessments: the inherited worked example, the W10 re-assessment
// of it, and the Tru Niagen re-assessment. CQ-EV-04, CQ-RC-03.
// status: run
UNWIND ['hu:applicability:nct02678611-1x-to-basis-current', 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2',
        'hu:applicability:w10-nct02712593-300-to-tru-niagen-300-v2'] AS applicabilityUid
MATCH (ea:EvidenceApplicability {uid: applicabilityUid})
OPTIONAL MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(evTarget)
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(target)
OPTIONAL MATCH (ea)-[:BASED_ON_EVIDENCE]->(evidence)
WITH ea, evTarget, collect(DISTINCT target.uid) AS targetUids, collect(DISTINCT evidence.uid) AS evidenceUids,
     CASE WHEN evTarget:Assertion
          THEN ['MATERIAL_IDENTITY', 'EXPOSURE', 'ROUTE', 'DURATION', 'POPULATION', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
          ELSE ['MATERIAL_IDENTITY', 'ACTIVE_COMPOSITION', 'DOSE', 'DOSAGE_FORM', 'ROUTE', 'SCHEDULE', 'DURATION', 'POPULATION', 'COMPARATOR', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
     END AS required
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, evTarget, targetUids, evidenceUids, required, collect(d) AS dims
UNWIND required + [x IN [d IN dims | d.dimension] WHERE NOT x IN required] AS dimName
WITH ea, evTarget, targetUids, evidenceUids, dimName, head([d IN dims WHERE d.dimension = dimName]) AS d
WITH ea, evTarget, targetUids, evidenceUids, dimName, d,
     CASE WHEN d IS NULL THEN 'MISSING_DIMENSION' ELSE coalesce(d.verdict, 'NOT_ASSESSED') END AS state
WITH ea, evTarget, targetUids, evidenceUids, dimName, d, state,
     CASE state WHEN 'MISMATCH' THEN 0 WHEN 'MISSING_DIMENSION' THEN 1 WHEN 'UNKNOWN' THEN 1 WHEN 'NOT_ASSESSED' THEN 1
       WHEN 'PARTIAL' THEN 2 WHEN 'MATCH' THEN 3 ELSE 4 END AS strength
ORDER BY strength ASC, dimName ASC
WITH ea, evTarget, targetUids, evidenceUids,
     collect({dimension: dimName, state: state, strength: strength, dimensionClass: d.dimensionClass,
              identityLevel: d.identityLevel, ratio: d.ratio, missingFacts: coalesce(d.missingFacts, []), rationale: d.rationale}) AS ranked
RETURN ea.uid AS applicabilityUid, ea.methodVersion AS methodVersion, ea.status AS assessmentStatus,
       evTarget.uid AS evidenceTargetUid, targetUids, evidenceUids,
       [x IN ranked WHERE x.strength = ranked[0].strength | x.dimension + ':' + x.state] AS weakestDimensions,
       [x IN ranked WHERE x.state IN ['UNKNOWN', 'NOT_ASSESSED', 'MISSING_DIMENSION'] | x.dimension] AS unresolvedDimensions,
       size(ranked) AS dimensionNodes, ea.overallScore AS derivedScoreIfAny
ORDER BY applicabilityUid;

// Q02 CQ-EV-06: for an applicability assessment, which dimensions are UNKNOWN or PARTIAL and which specific facts
// would resolve each (current, non-superseded version only).
// status: run
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'})-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WHERE d.verdict IN ['UNKNOWN', 'PARTIAL'] AND size(coalesce(d.missingFacts, [])) > 0
  AND NOT EXISTS { MATCH (:EvidenceApplicability)-[:SUPERSEDES]->(ea) }
RETURN d.dimension AS dimension, d.verdict AS verdict, d.missingFacts AS missingFacts
ORDER BY dimension;

// Q03 CQ-RC-03: which missing or disputed facts could change a ranking that uses this assessment: missing facts of
// unresolved dimensions plus the competing hypotheses and contested assertions the MATERIAL_IDENTITY dimension weighed.
// status: run
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'})-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WHERE d.verdict IN ['UNKNOWN', 'PARTIAL', 'NOT_ASSESSED']
OPTIONAL MATCH (d)-[:CONSIDERS_ASSESSMENT]->(h:ResolutionHypothesis)
OPTIONAL MATCH (d)-[:CONSIDERS]->(a:Assertion)
RETURN d.dimension AS dimension, d.verdict AS verdict, coalesce(d.missingFacts, []) AS missingFacts,
       collect(DISTINCT h.uid + ' (' + h.resolutionStatus + ')') AS competingHypotheses, collect(DISTINCT a.predicate) AS consideredPredicates
ORDER BY dimension;

// Q04 DOSE ratio minimal pair (INV-203): bases and ratio side by side.
// status: run
MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d:ApplicabilityDimension {dimension: 'DOSE'})
WHERE ea.uid IN ['hu:applicability:w10-nct02678611-1x-to-basis-current-v2', 'hu:applicability:w10-nct02712593-300-to-tru-niagen-300-v2']
OPTIONAL MATCH (ea)-[:FOR_USE_CONTEXT]->(p:UseContextProfile)
RETURN ea.uid AS assessment, d.evidenceValue AS evidenceValue, d.evidenceQuantityBasis AS evQB, d.evidenceMassBasis AS evMB,
       d.targetValue AS targetValue, d.targetQuantityBasis AS tgQB, d.targetMassBasis AS tgMB, d.unitCode AS unit,
       d.ratio AS ratio, d.verdict AS verdict, p.servingsPerDay AS profileServingsPerDay
ORDER BY assessment;

// Q05 CQ-ST-03: every context of use in which serum LDL-C has a role, and the NRPT trial's own classification.
// status: run
MATCH (bm:Biomarker {uid: 'hu:biomarker:ldl-c-serum'})
OPTIONAL MATCH (ctx:EndpointClassification)-[:CLASSIFIES_BIOMARKER]->(bm)
WHERE NOT EXISTS { MATCH (:EndpointClassification)-[:SUPERSEDES]->(ctx) }
WITH bm, collect({uid: ctx.uid, cls: ctx.endpointClass, level: ctx.surrogateValidationLevel, disease: ctx.contextDiseaseOrUse,
                  mechanism: ctx.contextInterventionMechanism, approval: ctx.contextApprovalType}) AS generalContexts
MATCH (od:OutcomeDefinition)-[:MEASURES_BIOMARKER]->(bm)
MATCH (ec:EndpointClassification)-[:CLASSIFIES_OUTCOME]->(od)
OPTIONAL MATCH (ec)-[:COMPARED_WITH_CONTEXT]->(near)
RETURN od.uid AS outcome, ec.endpointClass AS studyEndpointClass, ec.biomarkerCategory AS studyBiomarkerCategory,
       ec.surrogateValidationLevel AS studySurrogateLevel, ec.contextMatch AS contextMatch, near.uid AS comparedWith, generalContexts;

// Q06 CQ-ST-03 (biomarker primary, clinical secondary): NADPARK outcome roles with registered priority.
// status: run
MATCH (:Study {uid: 'hu:study:nct03816020-nadpark'})-[:DEFINES_OUTCOME]->(od:OutcomeDefinition)
OPTIONAL MATCH (ec:EndpointClassification)-[:CLASSIFIES_OUTCOME]->(od)
OPTIONAL MATCH (a:Assertion {predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:HAS_SUBJECT]->(od)
RETURN od.name AS outcome, od.measureKind AS measureKind, a.valueString AS registeredPriority, ec.endpointClass AS endpointClass,
       ec.biomarkerCategory AS biomarkerCategory, ec.surrogateValidationLevel AS surrogateLevel,
       ec.endpointClass = 'CLINICAL_OUTCOME' AS patientImportantDerived
ORDER BY registeredPriority;

// Q07 CQ-ST-05: when the primary is null, which inputs are secondary/subgroup/within-arm, and does any synthesis use
// them as confirmatory?
// status: run
MATCH (syn:EvidenceSynthesis {uid: 'hu:synthesis:w10-ua-muscle-function-middle-aged-v1'})-[i:INCLUDES_RESULT]->(r:StudyResult)
OPTIONAL MATCH (ri:ResultInterpretation)-[:INTERPRETS_RESULT_OF]->(r)
RETURN r.uid AS result, r.analysisKind AS analysisKind, r.comparisonKind AS comparisonKind, r.statisticalConclusion AS conclusion,
       i.inputRole AS inputRole, ri.interpretation AS bellLabsInterpretation,
       (r.analysisKind <> 'PRIMARY_PRESPECIFIED' AND i.inputRole = 'CONFIRMATORY') AS nonPrimaryUsedAsConfirmatory
ORDER BY analysisKind;

// Q08 CQ-ST-10: clinically meaningful per the authors, per a BellLabs criterion, or neither.
// status: run
MATCH (r:StudyResult {uid: 'hu:study-result:atlas-6mwt-ua-vs-placebo'})
OPTIONAL MATCH (a:Assertion {predicate: 'RESULT_CLINICALLY_MEANINGFUL'})-[:HAS_SUBJECT]->(r)
OPTIONAL MATCH (ri:ResultInterpretation)-[:INTERPRETS_RESULT_OF]->(r)
OPTIONAL MATCH (ri)-[:USES_THRESHOLD_SOURCE]->(t:SourceLocator)
RETURN r.uid AS result, a.valueBoolean AS authorsSayMeaningful, a.status AS captureStatus,
       ri.meaningfulnessVerdict AS bellLabsVerdict, ri.thresholdValue AS threshold, t.uid AS thresholdSource;

// Q09 CQ-ST-09 (domain clock): which findings PUBLISHED in [2021-01-01, 2026-01-01) changed a claim-level synthesis,
// by which criterion, with what effect and provenance.
// status: run
MATCH (v:EvidenceSynthesis)-[t:TRIGGERED_BY]->(x)
WHERE t.evidencePublishedAt >= date('2021-01-01') AND t.evidencePublishedAt < date('2026-01-01')
MATCH (v)-[:SUPERSEDES]->(prev:EvidenceSynthesis)
OPTIONAL MATCH (v)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN v.claimText AS claim, prev.verdict AS fromVerdict, v.verdict AS toVerdict, t.criterionCode AS criterion,
       t.effectOnVerdict AS effect, x.uid AS trigger, t.evidencePublishedAt AS publishedAt, v.recordedAt AS recordedAt,
       collect(l.uid) AS provenance
ORDER BY publishedAt;

// Q10 CQ-ST-09 (system clock): what BellLabs LEARNED in [2026-10-04T02:10:30Z, 2026-10-04T03:00:00Z): versions recorded in
// the period. Differs from Q09 because the evidence arrived late (both triggers were recorded today).
// status: run
MATCH (v:EvidenceSynthesis)-[t:TRIGGERED_BY]->(x)
WHERE v.recordedAt >= datetime('2026-10-04T02:10:30Z') AND v.recordedAt < datetime('2026-10-04T03:00:00Z')
RETURN v.uid AS version, v.recordedAt AS recordedAt, t.evidencePublishedAt AS evidencePublishedAt, t.criterionCode AS criterion, t.effectOnVerdict AS effect
ORDER BY recordedAt;

// Q11 CQ-AX-24: how strong is the evidence for claim C, by what criteria (current synthesis version as of R).
// status: run
WITH datetime('2026-10-04T02:30:00Z') AS R
MATCH (v:EvidenceSynthesis)-[:ASSESSES_CLAIM]->(c:Claim {uid: 'hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection'})
WHERE v.recordedAt <= R AND (v.recordedTo IS NULL OR R < v.recordedTo)
OPTIONAL MATCH (es:EvidenceStrengthAssessment)-[:ASSESSES_STRENGTH_OF]->(v)
RETURN c.claimText AS claim, v.uid AS currentVersion, v.verdict AS verdict, v.methodVersion AS method,
       es.scheme AS scheme, es.level AS level, es.criteria AS criteria, es.methodVersion AS strengthMethod;

// Q12 CQ-ST-09 / CQ-EV-05 as-of replay: the version believed at R = 2026-10-04T02:11:30Z (v2, SUPPORTED) vs now (v3).
// status: run
UNWIND [datetime('2026-10-04T02:11:30Z'), datetime('2026-10-04T03:00:00Z')] AS R
MATCH (v:EvidenceSynthesis)-[:ASSESSES_CLAIM]->(:Claim {uid: 'hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection'})
WHERE v.recordedAt <= R AND (v.recordedTo IS NULL OR R < v.recordedTo)
RETURN R AS asOf, v.uid AS version, v.verdict AS verdict, v.evidenceCutoff AS cutoff
ORDER BY asOf;

// Q13 CQ-EV-02: whose statement is it? Record kind for the pieces of the vitamin D answer.
// status: run
MATCH (v:EvidenceSynthesis {uid: 'hu:synthesis:w10-vitamin-d-ari-prevention-v3'})-[i:INCLUDES_RESULT]->(a:Assertion)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN a.uid AS input, [x IN labels(a) WHERE x IN ['Assertion', 'EvidenceAssessment']][0] AS inputRecordKind,
       a.predicate AS predicate, a.valueNumber AS pooledOR, i.inputRole AS role, l.exact AS sourceSpan,
       [x IN labels(v) WHERE x IN ['Assertion', 'EvidenceAssessment']][0] AS verdictRecordKind
ORDER BY role;

// Q14 CQ-MX-04 / CQ-AX-20: EXPOSURE dimension of mechanism-target applicability (inherited fixture).
// status: run
MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(a:Assertion)
MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension {dimension: 'EXPOSURE'})
OPTIONAL MATCH (ea)-[:BASED_ON_EVIDENCE]->(r:StudyResult)
RETURN ea.uid AS assessment, a.predicate AS mechanismPredicate, a.basisKind AS basisKind, d.verdict AS exposure,
       d.evidenceValue AS evidenceValue, d.targetValue AS targetValue, d.ratio AS ratio, d.missingFacts AS missingFacts,
       count(r) AS humanExposureResultsLinked;

// Q15 INV-201: the only path from the Basis product to study evidence runs through EvidenceApplicability.
// status: run
MATCH (p:Product {uid: 'hu:product:elysium-basis'})-[:HAS_VARIANT]->(:ProductVariant)-[:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
MATCH (ea:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(f)
MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(t)
OPTIONAL MATCH (s:Study)-[direct]->(p)
RETURN ea.uid AS applicability, labels(t)[0] AS evidenceTargetKind, t.uid AS evidenceTarget,
       EXISTS { MATCH (:EvidenceApplicability)-[:SUPERSEDES]->(ea) } AS superseded, count(direct) AS directStudyEdges
ORDER BY applicability;
