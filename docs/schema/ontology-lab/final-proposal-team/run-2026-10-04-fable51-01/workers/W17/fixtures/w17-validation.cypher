// W17 candidate validators V-W17-01..V-W17-13 (zero rows = valid). Proposed for Fable's merged validation file (W17-SR-09).
// Each statement is standalone. Expected rows per fixture set are in 06-fixtures-and-queries.md section 3.

// V-W17-01 (CQ-SF-C01, D-W17-01): a SafetySignal has exactly one PRIMARY subject, exactly one effect, and at least one
// input, except a migrated live row (methodVersion live-migration/*, signalStatus NOT_EVALUATED).
MATCH (s:SafetySignal)
OPTIONAL MATCH (:Entity)-[h:HAS_SAFETY_SIGNAL]->(s) WHERE h.subjectRole = 'PRIMARY'
WITH s, count(h) AS primaries
OPTIONAL MATCH (s)-[e:RELATES_TO_EFFECT]->(:AdverseEffect)
WITH s, primaries, count(e) AS effects
OPTIONAL MATCH (s)-[i:SIGNAL_BASED_ON]->()
WITH s, primaries, effects, count(i) AS inputs
WITH s, [v IN [CASE WHEN primaries <> 1 THEN 'PRIMARY_SUBJECTS_' + toString(primaries) END,
               CASE WHEN effects <> 1 THEN 'EFFECTS_' + toString(effects) END,
               CASE WHEN inputs = 0 AND NOT (s.methodVersion STARTS WITH 'live-migration/' AND s.signalStatus = 'NOT_EVALUATED') THEN 'NO_INPUTS' END]
         WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN s.uid AS signal, violations ORDER BY signal;

// V-W17-02 (INV-209, CQ-AX-24, FI LEGACY_HINT -> VERDICT): a legacy evidenceStrength hint or a live-migration method never
// carries an evaluated status; an evaluated status needs a real method and inputs.
MATCH (s:SafetySignal)
OPTIONAL MATCH (s)-[i:SIGNAL_BASED_ON]->()
WITH s, count(i) AS inputs
WHERE ((s.legacyEvidenceStrengthHint IS NOT NULL OR s.methodVersion STARTS WITH 'live-migration/') AND s.signalStatus <> 'NOT_EVALUATED')
   OR (s.signalStatus IN ['CONFIRMED_ASSOCIATION', 'NOT_SUPPORTED', 'CLOSED_NO_ACTION', 'INSUFFICIENT_DATA'] AND (inputs = 0 OR s.methodVersion STARTS WITH 'live-migration/'))
RETURN s.uid AS signal, s.signalStatus AS status, s.methodVersion AS method, s.legacyEvidenceStrengthHint AS hint, inputs ORDER BY signal;

// V-W17-03 (INV-207 with W09 V-217): (a) a zero AE input to a signal states its collection method; (b) a Study used as a
// NOT_REPORTED input has no AdverseEventResult (a fabricated zero or a wrong status); (c) NOT_REPORTED is only for Study inputs.
MATCH (s:SafetySignal)-[i:SIGNAL_BASED_ON]->(ae:AdverseEventResult)
WHERE (ae.participantsAffected = 0 OR ae.eventCount = 0) AND ae.collectionMethod IS NULL
RETURN s.uid AS signal, ae.uid AS record, 'ZERO_WITHOUT_COLLECTION_METHOD' AS violation
UNION
MATCH (s:SafetySignal)-[i:SIGNAL_BASED_ON]->(st:Study)-[:HAS_ARM]->(:StudyArm)<-[:RESULT_FOR_ARM]-(ae:AdverseEventResult)
WHERE i.aeReportedStatus = 'NOT_REPORTED'
RETURN s.uid AS signal, ae.uid AS record, 'AE_ROW_FOR_NOT_REPORTED_STUDY' AS violation
UNION
MATCH (s:SafetySignal)-[i:SIGNAL_BASED_ON]->(x)
WHERE i.aeReportedStatus = 'NOT_REPORTED' AND NOT x:Study
RETURN s.uid AS signal, x.uid AS record, 'NOT_REPORTED_ON_NON_STUDY_INPUT' AS violation;

// V-W17-04 (CQ-RC-06): ContraindicationAssertion shape: registered predicate, level, polarity, object kind, no literal.
MATCH (a:ContraindicationAssertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, collect(o) AS objs
WITH a, [v IN [CASE WHEN NOT a.predicate IN ['USE_CONSTRAINED_IN', 'USE_CONSTRAINED_WITH'] THEN 'UNREGISTERED_PREDICATE' END,
               CASE WHEN a.constraintLevel IS NULL THEN 'NO_LEVEL' END,
               CASE WHEN a.polarity IS NULL THEN 'NO_POLARITY' END,
               CASE WHEN size(objs) <> 1 THEN 'OBJECT_COUNT_' + toString(size(objs)) END,
               CASE WHEN a.predicate = 'USE_CONSTRAINED_IN' AND size(objs) = 1 AND NOT (objs[0]:Condition OR objs[0]:UseContextProfile) THEN 'IN_OBJECT_NOT_CONDITION_OR_POPULATION' END,
               CASE WHEN a.valueString IS NOT NULL OR a.valueNumber IS NOT NULL OR a.valueBoolean IS NOT NULL THEN 'LITERAL_WITH_OBJECT' END]
         WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN a.uid AS assertion, violations ORDER BY assertion;

// V-W17-05 (INV-007, QS-7, FI NO_INTERACTION_RECORD -> NO_INTERACTION): InteractionAssertion shape. NEGATIVE is a studied
// absence: it names the evidence setting and has a measured or cited basis (never HYPOTHESIS or null); a measured or
// inferred basis names its evidence setting; a reported grade names its scheme.
MATCH (a:InteractionAssertion)
WITH a, [v IN [CASE WHEN a.predicate <> 'INTERACTS_WITH' THEN 'UNREGISTERED_PREDICATE' END,
               CASE WHEN a.polarity IS NULL THEN 'NO_POLARITY' END,
               CASE WHEN a.polarity = 'NEGATIVE' AND (a.evidenceSetting IS NULL OR NOT coalesce(a.basisKind, '') IN ['DIRECT_MEASUREMENT', 'CITED_FROM_PRIOR_WORK']) THEN 'NEGATIVE_WITHOUT_STUDIED_ABSENCE' END,
               CASE WHEN a.basisKind IN ['DIRECT_MEASUREMENT', 'INFERRED_FROM_MEASUREMENT'] AND a.evidenceSetting IS NULL THEN 'NO_EVIDENCE_SETTING' END,
               CASE WHEN a.reportedEvidenceGrade IS NOT NULL AND a.reportedEvidenceGradeScheme IS NULL THEN 'GRADE_WITHOUT_SCHEME' END]
         WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN a.uid AS assertion, violations ORDER BY assertion;

// V-W17-06 (CQ-RC-06, FI SHARED_SUBSTANCE_FAMILY -> USE_CONSTRAINT_APPLIES, INV-004): a UseConstraint has exactly one
// constrained subject and at least one scope member; a RESOLVES_TO_CONSTRAINT edge carries its rule and cites its own
// assertion, and the assertion's subject and object are both members of the constraint's identity.
MATCH (u:UseConstraint)
OPTIONAL MATCH (u)-[c:CONSTRAINS_USE_OF]->()
WITH u, count(c) AS subjects
OPTIONAL MATCH (u)-[s:CONSTRAINT_SCOPE]->()
WITH u, subjects, count(s) AS scope
WHERE subjects <> 1 OR scope = 0
RETURN u.uid AS record, 'CONSTRAINT_IDENTITY_INCOMPLETE subjects=' + toString(subjects) + ' scope=' + toString(scope) AS violation
UNION
MATCH (a:Assertion)-[r:RESOLVES_TO_CONSTRAINT]->(u:UseConstraint)
MATCH (a)-[:HAS_SUBJECT]->(sub), (a)-[:HAS_OBJECT]->(obj)
OPTIONAL MATCH (u)-[:CONSTRAINS_USE_OF|CONSTRAINT_SCOPE]->(m)
WITH a, r, u, sub, obj, collect(m.uid) AS members
WHERE r.derivationRule IS NULL OR NOT a.uid IN coalesce(r.derivedFromAssertionUids, [])
   OR NOT sub.uid IN members OR NOT obj.uid IN members
RETURN a.uid AS record, 'RESOLUTION_MISMATCH -> ' + u.uid AS violation;

// V-W17-07 (INV-209, V-213b): no strength or confidence on safety-signal edges (live SafetyMetadata shape).
MATCH ()-[h:HAS_SAFETY_SIGNAL]->(s:SafetySignal)
WHERE h.evidenceStrength IS NOT NULL OR h.confidence IS NOT NULL
RETURN s.uid AS signal, h.relationshipUid AS edge, h.evidenceStrength AS strength, h.confidence AS confidence;

// V-W17-08 (INV-203 style dose bands): dose bands are complete (comparator, value, unit, quantity basis) or absent; a
// DO_NOT_EXCEED_DOSE directive carries its band.
MATCH (x)
WHERE (x:ContraindicationAssertion OR x:UseConstraint)
  AND (x.doseValue IS NOT NULL OR x.doseComparator IS NOT NULL OR x.doseUnitCode IS NOT NULL OR x.doseQuantityBasis IS NOT NULL)
  AND (x.doseValue IS NULL OR x.doseComparator IS NULL OR x.doseUnitCode IS NULL OR x.doseQuantityBasis IS NULL)
RETURN x.uid AS record, 'INCOMPLETE_DOSE_BAND' AS violation
UNION
MATCH (x:ContraindicationAssertion {constraintLevel: 'DO_NOT_EXCEED_DOSE'})
WHERE x.doseValue IS NULL
RETURN x.uid AS record, 'DOSE_LIMIT_WITHOUT_DOSE' AS violation
UNION
MATCH (:UseConstraint)-[r:CONSTRAINT_SCOPE]->(m)
WHERE (r.doseValue IS NOT NULL OR r.doseComparator IS NOT NULL) AND (r.doseValue IS NULL OR r.doseComparator IS NULL OR r.doseUnitCode IS NULL OR r.doseQuantityBasis IS NULL)
RETURN m.uid AS record, 'INCOMPLETE_SCOPE_DOSE_BAND' AS violation;

// V-W17-09 (W03-SR-08 ruling): AFFECTS_ORGAN starts only at AdverseEffect or Condition (curated involvement); a signal's
// organ is read through its effect.
MATCH (x)-[r:AFFECTS_ORGAN]->(:AnatomicalContext)
WHERE NOT (x:AdverseEffect OR x:Condition)
RETURN x.uid AS start, labels(x) AS labels;

// V-W17-10 (severity is not seriousness): SERIOUS severity is legacy only.
MATCH (s:SafetySignal {severity: 'SERIOUS'})
WHERE NOT s.methodVersion STARTS WITH 'live-migration/'
RETURN s.uid AS signal, s.methodVersion AS method;

// V-W17-11 (D-W17-02): HAS_SAFETY_SIGNAL is structural; it never carries the asserted-edge profile (assertionUid,
// recordedFrom) and every edge has relationshipUid and subjectRole.
MATCH ()-[h:HAS_SAFETY_SIGNAL]->(s:SafetySignal)
WHERE h.assertionUid IS NOT NULL OR h.recordedFrom IS NOT NULL OR h.relationshipUid IS NULL OR h.subjectRole IS NULL
RETURN s.uid AS signal, h.relationshipUid AS edge, h.assertionUid AS citedAssertion;

// V-W17-12 (INV-506, V-521 specialization): no private uid value or private-personal class on W17 nodes.
MATCH (n)
WHERE (n:SafetySignal OR n:AdverseEffect OR n:UseConstraint OR n:ContraindicationAssertion OR n:InteractionAssertion)
  AND (any(k IN keys(n) WHERE toString(n[k]) STARTS WITH 'hu:private-') OR NOT coalesce(n.privacyClass, 'PUBLIC') IN ['PUBLIC', 'INTERNAL'])
RETURN n.uid AS node, [k IN keys(n) WHERE toString(n[k]) STARTS WITH 'hu:private-'] AS leakingProperties;

// V-W17-13 (FI SIMILAR_NAME -> SAME_IDENTITY): an AdverseEffect is never also a Condition (two identities, no merge by name).
MATCH (n:AdverseEffect:Condition)
RETURN n.uid AS node, n.name AS name;
