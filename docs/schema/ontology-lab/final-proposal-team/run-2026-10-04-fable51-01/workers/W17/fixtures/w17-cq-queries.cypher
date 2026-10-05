// W17 competency-question queries (read-only). Parameters are inlined as literals so each statement runs standalone.
// Expected rows are in 06-fixtures-and-queries.md section 2. Run on fixtures 00-05 (without 90).

// Q-W17-01 (CQ-ST-06): AE rows per arm with collection method and the reading each count supports.
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'})-[:HAS_ARM]->(a:StudyArm)<-[:RESULT_FOR_ARM]-(ae:AdverseEventResult)
RETURN a.name AS arm, ae.eventTerm AS term, ae.seriousness AS seriousness, ae.participantsAffected AS affected, ae.participantsAtRisk AS atRisk,
       ae.collectionMethod AS method, ae.collectionMethodText AS methodWording,
       CASE WHEN ae.participantsAffected = 0 AND ae.collectionMethod = 'SYSTEMATIC' THEN 'ZERO_SYSTEMATICALLY_COLLECTED'
            WHEN ae.participantsAffected = 0 THEN 'ZERO_REPORTED_COLLECTION_NOT_DESCRIBED'
            ELSE 'COUNT_REPORTED' END AS reading
ORDER BY arm, term;

// Q-W17-02 (CQ-ST-06, INV-207): for the current NRPT signal, each considered study and how its AE evidence reads
// (a NOT_REPORTED study is listed, never counted as zero).
MATCH (s:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'})-[i:SIGNAL_BASED_ON]->(x)
OPTIONAL MATCH (x)-[:RESULT_FOR_ARM]->(:StudyArm)<-[:HAS_ARM]-(st1:Study)
WITH i, x, coalesce(st1, CASE WHEN x:Study THEN x END) AS st
RETURN st.uid AS study, i.inputRole AS role, i.aeReportedStatus AS aeReportedStatus,
       CASE WHEN i.aeReportedStatus = 'NOT_REPORTED' THEN 'NOT_REPORTED (no AE data; not zero)'
            WHEN x.participantsAffected = 0 AND x.collectionMethod = 'SYSTEMATIC' THEN 'ZERO_SYSTEMATIC (absent within this study)'
            WHEN x.participantsAffected = 0 THEN 'ZERO_REPORTED_METHOD_NOT_DESCRIBED'
            ELSE 'COUNT ' + toString(x.participantsAffected) + '/' + toString(x.participantsAtRisk) END AS reading
ORDER BY study, role;

// Q-W17-03 (CQ-SF-C01, CQ-AX-24): current signal for subject+effect with method, status, inputs; and its superseded history.
MATCH (subj {uid: 'hu:material:nct02678611-nrpt-as-supplied'})-[h:HAS_SAFETY_SIGNAL {subjectRole: 'PRIMARY'}]->(s:SafetySignal)-[:RELATES_TO_EFFECT]->(e:AdverseEffect)
OPTIONAL MATCH (s)-[i:SIGNAL_BASED_ON]->(x)
WITH s, e, h, count(x) AS inputs, EXISTS { MATCH (:SafetySignal)-[:SUPERSEDES]->(s) } AS superseded
RETURN s.uid AS signal, e.name AS effect, s.methodVersion AS method, s.signalStatus AS signalStatus, s.status AS recordStatus,
       superseded, inputs, h.doseText AS dose, s.recordedAt AS recordedAt
ORDER BY recordedAt;

// Q-W17-04 (CQ-RC-06): constraint state for an option given a declared, non-personal context (public uids only).
// Each case is one option + declared co-exposures (with daily dose in mg) + populations + conditions + option dose.
// Viewpoint R = V = 2026-10-05. `facets` is the shared answer; `illustrativePolicyV3` applies the synthetic W23 policy
// 'sleep-support-ranking v3' rule (policy content, NOT schema): BLOCK if a POSITIVE directive at CONTRAINDICATED,
// DO_NOT_EXCEED_DOSE, AVOID or NOT_RECOMMENDED is live, or if an interaction is UNKNOWN (uncharacterized); PENALIZE if only
// weaker directives or characterized interactions apply; NO_RECORD_BLOCK_BY_MISSING_FACT when no constraint record exists
// for a declared co-exposure (cites the policy DecisionCriterion + missingFactKeys, never a fabricated UseConstraint).
UNWIND [
  {k: 'A kava + warfarin', opt: 'hu:material:kava-preparation-unspecified', optMg: null, co: [{u: 'hu:substance:warfarin', mg: null}], pops: [], conds: []},
  {k: 'B simvastatin 20 mg + verapamil', opt: 'hu:substance:simvastatin', optMg: 20.0, co: [{u: 'hu:substance:verapamil', mg: null}], pops: [], conds: []},
  {k: 'C simvastatin 10 mg + verapamil', opt: 'hu:substance:simvastatin', optMg: 10.0, co: [{u: 'hu:substance:verapamil', mg: null}], pops: [], conds: []},
  {k: 'D simvastatin 20 mg + niacin 1500 mg, Chinese', opt: 'hu:substance:simvastatin', optMg: 20.0, co: [{u: 'hu:substance:nicotinic-acid', mg: 1500.0}], pops: ['hu:use-profile:patients-of-chinese-descent'], conds: []},
  {k: 'E simvastatin 20 mg + niacin 1500 mg, non-Chinese', opt: 'hu:substance:simvastatin', optMg: 20.0, co: [{u: 'hu:substance:nicotinic-acid', mg: 1500.0}], pops: ['hu:use-profile:non-chinese-patients'], conds: []},
  {k: 'F simvastatin 20 mg + niacin 500 mg, Chinese', opt: 'hu:substance:simvastatin', optMg: 20.0, co: [{u: 'hu:substance:nicotinic-acid', mg: 500.0}], pops: ['hu:use-profile:patients-of-chinese-descent'], conds: []},
  {k: 'G nicotinamide riboside + simvastatin', opt: 'hu:substance:nicotinamide-riboside', optMg: 300.0, co: [{u: 'hu:substance:simvastatin', mg: 20.0}], pops: [], conds: []}
] AS c
WITH c, datetime('2026-10-05T00:00:00Z') AS R, datetime('2026-10-05T00:00:00Z') AS V, [x IN c.co | x.u] AS coUids
CALL (c, coUids, R, V) {
  MATCH (u:UseConstraint)-[:CONSTRAINS_USE_OF]->(subj)
  WHERE (subj.uid = c.opt AND EXISTS { (u)-[:CONSTRAINT_SCOPE]->(m) WHERE m.uid IN coUids OR m.uid IN c.pops OR m.uid IN c.conds })
     OR (subj.uid IN coUids AND EXISTS { (u)-[:CONSTRAINT_SCOPE {scopeRole: 'CO_EXPOSURE'}]->({uid: c.opt}) })
  WITH u, subj, [(u)-[r:CONSTRAINT_SCOPE]->(mm) | {uid: mm.uid, role: r.scopeRole, cmp: r.doseComparator, v: r.doseValue, unit: r.doseUnitCode}] AS scope
  WITH u, subj, scope,
       ALL(m IN scope WHERE m.uid = c.opt
         OR (m.role = 'CO_EXPOSURE' AND m.uid IN coUids AND (m.cmp IS NULL OR ANY(x IN c.co WHERE x.u = m.uid AND x.mg IS NOT NULL AND
              CASE m.cmp WHEN 'GTE' THEN x.mg >= m.v * CASE m.unit WHEN 'g' THEN 1000.0 ELSE 1.0 END
                         WHEN 'GT' THEN x.mg > m.v * CASE m.unit WHEN 'g' THEN 1000.0 ELSE 1.0 END
                         WHEN 'LTE' THEN x.mg <= m.v * CASE m.unit WHEN 'g' THEN 1000.0 ELSE 1.0 END
                         WHEN 'LT' THEN x.mg < m.v * CASE m.unit WHEN 'g' THEN 1000.0 ELSE 1.0 END END)))
         OR (m.role = 'POPULATION' AND m.uid IN c.pops)
         OR (m.role = 'CONDITION_PRESENT' AND m.uid IN c.conds)) AS scopeMet,
       (u.doseComparator IS NULL OR subj.uid <> c.opt OR c.optMg IS NULL OR
        CASE u.doseComparator WHEN 'GT' THEN c.optMg > u.doseValue WHEN 'GTE' THEN c.optMg >= u.doseValue WHEN 'LT' THEN c.optMg < u.doseValue WHEN 'LTE' THEN c.optMg <= u.doseValue END) AS doseMet
  OPTIONAL MATCH (a:Assertion)-[:RESOLVES_TO_CONSTRAINT]->(u)
  WHERE a.recordedAt <= R AND (a.recordedTo IS NULL OR a.recordedTo > R)
    AND (a.validFrom IS NULL OR a.validFrom <= V) AND (a.validTo IS NULL OR V < a.validTo)
  WITH u, scopeMet, doseMet, collect(a) AS live
  RETURN collect({uc: u.uid, applies: scopeMet AND doseMet,
                  stated: [x IN live WHERE x:ContraindicationAssertion AND x.polarity = 'POSITIVE' | x.constraintLevel],
                  removed: [x IN live WHERE x:ContraindicationAssertion AND x.polarity = 'NEGATIVE' | x.constraintLevel],
                  interactions: [x IN live WHERE x:InteractionAssertion | x.polarity],
                  evidence: [x IN live | x.uid]}) AS candidates
}
WITH c, candidates, [x IN candidates WHERE x.applies] AS applicable, [x IN candidates WHERE NOT x.applies | x.uc] AS notInScope
WITH c, applicable, notInScope,
     reduce(acc = [], x IN applicable | acc + [l IN x.stated | 'DIRECTIVE:' + l] + [l IN x.removed | 'REMOVED:' + l] + [p IN x.interactions | 'INTERACTION:' + p]) AS facets
RETURN c.k AS case, [x IN applicable | x.uc] AS applicableConstraints, notInScope, facets,
       CASE WHEN size(applicable) = 0 AND size(notInScope) = 0 THEN 'NO_RECORD_BLOCK_BY_MISSING_FACT'
            WHEN any(f IN facets WHERE f IN ['DIRECTIVE:CONTRAINDICATED', 'DIRECTIVE:DO_NOT_EXCEED_DOSE', 'DIRECTIVE:AVOID', 'DIRECTIVE:NOT_RECOMMENDED', 'INTERACTION:UNKNOWN']) THEN 'BLOCK'
            WHEN size(facets) > 0 THEN 'PENALIZE'
            ELSE 'NO_APPLICABLE_CONSTRAINT' END AS illustrativePolicyV3,
       reduce(acc = [], x IN applicable | acc + x.evidence) AS evidenceAssertionUids
ORDER BY case;

// Q-W17-05 (CQ-AX-04 via QS-7, INV-007): interaction state for a pair, with "covering sources" that discuss the object's
// interactions without mentioning the subject. Empty evidence = NOT_RECORDED, never "no interaction".
UNWIND [['hu:material:green-tea-extract-unspecified', 'hu:substance:simvastatin'], ['hu:material:kava-preparation-unspecified', 'hu:substance:warfarin'],
        ['hu:material:american-ginseng-preparation-unspecified', 'hu:substance:indinavir'], ['hu:substance:nicotinamide-riboside', 'hu:substance:simvastatin'], ['hu:substance:nicotinamide-riboside', 'hu:substance:lenvatinib']] AS pair
OPTIONAL MATCH (a:InteractionAssertion)-[:HAS_SUBJECT]->({uid: pair[0]}), (a)-[:HAS_OBJECT]->({uid: pair[1]})
WHERE a.recordedTo IS NULL
WITH pair, collect(a) AS m
OPTIONAL MATCH (snap:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(b:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->({uid: pair[1]})
WHERE (b:InteractionAssertion OR b:ContraindicationAssertion)
  AND NOT EXISTS { MATCH (snap)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(b2:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->({uid: pair[0]}) }
WITH pair, m, collect(DISTINCT snap.uid) AS silentCoveringSnapshots
RETURN pair[0] AS subject, pair[1] AS object,
       CASE WHEN any(x IN m WHERE x.polarity = 'POSITIVE') AND any(x IN m WHERE x.polarity = 'NEGATIVE') THEN 'CONFLICTING'
            WHEN any(x IN m WHERE x.polarity = 'POSITIVE') THEN 'ASSERTED_PRESENT'
            WHEN any(x IN m WHERE x.polarity = 'NEGATIVE') THEN 'ASSERTED_ABSENT'
            WHEN size(m) > 0 THEN 'ASSERTED_UNKNOWN'
            WHEN size(silentCoveringSnapshots) > 0 THEN 'NOT_DECLARED_IN_COVERING_SOURCE'
            ELSE 'NOT_RECORDED' END AS state,
       [x IN m | x.uid] AS assertions, silentCoveringSnapshots
ORDER BY subject;

// Q-W17-06 (CQ-TM-01 style as-of, CQ-RC-07): statin-in-pregnancy constraint at three viewpoints.
UNWIND [{R: datetime('2021-03-01T00:00:00Z'), V: datetime('2021-03-01T00:00:00Z')},
        {R: datetime('2026-10-05T00:00:00Z'), V: datetime('2021-03-01T00:00:00Z')},
        {R: datetime('2026-10-05T00:00:00Z'), V: datetime('2026-10-01T00:00:00Z')}] AS vp
MATCH (u:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
OPTIONAL MATCH (a:ContraindicationAssertion)-[:RESOLVES_TO_CONSTRAINT]->(u)
WHERE a.recordedAt <= vp.R AND (a.recordedTo IS NULL OR a.recordedTo > vp.R)
  AND (a.validFrom IS NULL OR a.validFrom <= vp.V) AND (a.validTo IS NULL OR vp.V < a.validTo)
WITH vp, collect(a) AS live
RETURN toString(vp.R) AS recordedAsOf, toString(vp.V) AS validAt,
       [x IN live | x.polarity + ':' + x.constraintLevel] AS levels, [x IN live | x.uid] AS assertions
ORDER BY recordedAsOf, validAt;

// Q-W17-07 (CQ-AX-24): signals whose only strength is a legacy hint vs evaluated signals (hint never a verdict).
MATCH (s:SafetySignal)
OPTIONAL MATCH (s)-[i:SIGNAL_BASED_ON]->()
WITH s, count(i) AS inputs
RETURN s.uid AS signal, s.methodVersion AS method, s.signalStatus AS signalStatus, s.legacyEvidenceStrengthHint AS legacyHint, inputs,
       CASE WHEN s.signalStatus = 'NOT_EVALUATED' THEN 'NO VERDICT (hint shown as extraction-time hint only)' ELSE s.signalStatus END AS displayedState
ORDER BY signal;

// Q-W17-08 (CQ-SF-C02): agency signal listings are not causal findings; show FDA's own statement and the imported status.
MATCH (s:SafetySignal {methodVersion: 'agency-signal-import/0.1'})-[:SIGNAL_BASED_ON]->(a:Assertion)-[:ASSERTED_BY]->(org)
MATCH (s)-[:RELATES_TO_EFFECT]->(e:AdverseEffect), (subj)-[:HAS_SAFETY_SIGNAL {subjectRole: 'PRIMARY'}]->(s)
RETURN subj.name AS subject, e.name AS effect, org.name AS asserter, a.predicate AS agencyPredicate, s.signalStatus AS signalStatus,
       CASE s.signalStatus WHEN 'CLOSED_NO_ACTION' THEN 'no regulatory action at the time; not a no-risk finding'
                           WHEN 'CONFIRMED_ASSOCIATION' THEN 'agency added the risk to labeling; still not a personal conclusion'
                           ELSE 'under evaluation; not a causal finding' END AS reading
ORDER BY subject;

// Q-W17-09 (CQ-RC-07): UseConstraints whose live assertion set differs between two recorded viewpoints at valid time V
// (private snapshots citing them need review).
WITH datetime('2021-03-01T00:00:00Z') AS R1, datetime('2026-10-05T00:00:00Z') AS R2, datetime('2026-10-01T00:00:00Z') AS V
MATCH (u:UseConstraint)
OPTIONAL MATCH (a:Assertion)-[:RESOLVES_TO_CONSTRAINT]->(u)
WITH u, R1, R2, V, collect(a) AS all
WITH u, [x IN all WHERE x.recordedAt <= R1 AND (x.recordedTo IS NULL OR x.recordedTo > R1) AND (x.validFrom IS NULL OR x.validFrom <= V) AND (x.validTo IS NULL OR V < x.validTo) | x.uid] AS atR1,
        [x IN all WHERE x.recordedAt <= R2 AND (x.recordedTo IS NULL OR x.recordedTo > R2) AND (x.validFrom IS NULL OR x.validFrom <= V) AND (x.validTo IS NULL OR V < x.validTo) | x.uid] AS atR2
WHERE size(atR1) > 0 AND (any(x IN atR1 WHERE NOT x IN atR2) OR any(x IN atR2 WHERE NOT x IN atR1))
RETURN u.uid AS useConstraint, atR1, atR2;

// Q-W17-10 (forbidden implication SHARED_SUBSTANCE_FAMILY -> USE_CONSTRAINT_APPLIES): constraints reachable from
// nicotinamide riboside as the constrained subject or as a co-exposure. Expected: none.
MATCH (nr:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
OPTIONAL MATCH (u:UseConstraint)-[:CONSTRAINS_USE_OF|CONSTRAINT_SCOPE]->(nr)
RETURN nr.name AS substance, count(u) AS constraints;
