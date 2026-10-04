// W16 validator set used after every W16 fixture (zero rows = valid).
// Part A: baseline 0.2.0 validators copied verbatim where they apply (V-113, V-508, V-509, V-520, V-521, V-524).
// Part B: W16 PROPOSED validators (suffix p). V-525p/V-526p restate catalog V-525/V-526 on HAS_PROTOCOL_STEP (D-004);
//         V-527p..V-542p are new proposals for Fable (not yet catalog ids; numbering is a request, see seam-requests.yaml).
// Execution: run on embedded Neo4j 5.26.31 Community after each fixture, fresh database per fixture (06-fixtures-and-queries.md).

// ===================== Part A: baseline (verbatim from docs/schema/neo4j/validation.cypher) =====================

// V-113: no shared node points at a private node (public/private boundary).
MATCH (s)-[r]->(p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
RETURN labels(s) AS sharedLabels, s.uid AS sharedUid, type(r) AS relType, p.uid AS privateUid;

// V-508: DEFINITE overlap of mutually exclusive attachments in both valid and recorded time.
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
     r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
     r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// V-509 (informational, review queue): POSSIBLE overlap of exclusive attachments caused by a null or imprecise bound.
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
  AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
  AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
       OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;

// V-520: no private-store labels in the shared graph (production form of fixture F-V6).
MATCH (n)
WHERE NOT n:PrivateRecord AND (n:UserContext OR n:UserContextVersion OR n:UserGoal OR n:UserGoalVersion
   OR n:PersonalMeasurement OR n:PersonalLabReport OR n:ProtocolInUse OR n:ProtocolAdoptionVersion OR n:ProtocolDeviation
   OR n:SharingGrant OR n:DisclosureEvent OR n:PendingItem OR n:PurchaseEvent OR n:PersonalApplicabilityAssessment
   OR n:ErasureTombstone OR n:RecommendationRequest OR n:RecommendationSnapshot OR n:RecommendationOption
   OR n:DecisionCriterionValue OR n:UserDecision)
RETURN labels(n) AS labels, n.uid AS privateNodeInSharedGraph;

// V-521: no private uid values or private-personal class on shared nodes or relationships.
MATCH (n)
WHERE NOT n:PrivateRecord AND (n.privacyClass = 'private-personal'
   OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
   OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
RETURN 'NODE' AS kind, n.uid AS item
UNION
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
  AND (r.privacyClass = 'private-personal'
       OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-'))
RETURN 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item;

// V-524: shared applicability never targets a personal context; private measurements never collapse into Observation.
MATCH (ea:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(u:UserContext)
RETURN 'APPLICABILITY_TO_USER_CONTEXT' AS violation, ea.uid AS item
UNION
MATCH (x:Observation:PersonalMeasurement)
RETURN 'OBSERVATION_PERSONAL_MEASUREMENT_COLLAPSE' AS violation, x.uid AS item;

// ===================== Part B: W16 proposed validators =====================

// V-525p: stepKey present and unique within an edition; CONDITIONAL steps name an APPLIES_WHEN constraint (catalog V-525 on HAS_PROTOCOL_STEP).
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WITH e, s.stepKey AS stepKey, count(*) AS n
WHERE stepKey IS NULL OR n > 1
RETURN 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item, stepKey AS detail
UNION
MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
RETURN 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item, s.stepKey AS detail;

// V-526p (informational): two different step nodes with the same stepKey and payloadHash inside one protocol lineage are duplicates.
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s1:ProtocolStep),
      (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s2:ProtocolStep)
WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
RETURN DISTINCT 'DUPLICATE_STEP_PAYLOAD' AS violation, p.uid AS item, s1.stepKey AS detail;

// V-527p: a dependency never leaves its edition and never points at itself (copy-on-write: a shared step is shared with its dependency closure).
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)-[d:DEPENDS_ON]->(t:ProtocolStep)
WHERE s = t OR NOT (e)-[:HAS_PROTOCOL_STEP]->(t)
RETURN CASE WHEN s = t THEN 'SELF_DEPENDENCY' ELSE 'DEPENDENCY_OUTSIDE_EDITION' END AS violation, e.uid AS item, s.stepKey + ' -> ' + t.stepKey AS detail;

// V-528p: ordering dependencies (REQUIRES_PRIOR_COMPLETION, REQUIRES_RESULT_OF) are acyclic within an edition.
// Repetition is schedule (cadence, totalOccurrences, cycles, repeatUntilText), never a dependency loop.
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
MATCH p = (s)-[:DEPENDS_ON*1..25]->(s)
WHERE all(r IN relationships(p) WHERE r.dependencyKind IN ['REQUIRES_PRIOR_COMPLETION', 'REQUIRES_RESULT_OF'])
  AND all(n IN nodes(p) WHERE (e)-[:HAS_PROTOCOL_STEP]->(n))
RETURN DISTINCT 'ORDERING_CYCLE' AS violation, e.uid AS item, s.stepKey AS detail;

// V-529p: bounded ranges are well formed (min <= max; a unit accompanies a value; active part of a cycle within the cycle; dose range ordered).
MATCH (n)
WHERE n:ProtocolStep OR n:ProtocolEdition OR n:MeasurementPlan OR n:Target
UNWIND [['cadenceIntervalMin','cadenceIntervalMax'], ['occurrencesPerPeriodMin','occurrencesPerPeriodMax'], ['totalOccurrencesMin','totalOccurrencesMax'],
        ['durationMinutesMin','durationMinutesMax'], ['durationDaysMin','durationDaysMax'], ['cycleLengthDaysMin','cycleLengthDaysMax'],
        ['cycleActiveDaysMin','cycleActiveDaysMax'], ['cycleCountMin','cycleCountMax'], ['cadenceMinDays','cadenceMaxDays'], ['lowerBound','upperBound'],
        ['cycleActiveDaysMax','cycleLengthDaysMax']] AS pr
WITH n, pr
WHERE n[pr[0]] IS NOT NULL AND n[pr[1]] IS NOT NULL AND n[pr[0]] > n[pr[1]]
RETURN 'RANGE_INVERTED' AS violation, n.uid AS item, pr[0] + ' > ' + pr[1] AS detail
UNION
MATCH (n)
WHERE (n:ProtocolStep OR n:ProtocolEdition)
  AND ((n.cadenceIntervalMin IS NOT NULL OR n.cadenceIntervalMax IS NOT NULL) AND n.cadenceUnit IS NULL
       OR (n.occurrencesPerPeriodMin IS NOT NULL OR n.occurrencesPerPeriodMax IS NOT NULL) AND n.occurrencePeriodUnit IS NULL)
RETURN 'RANGE_WITHOUT_UNIT' AS violation, n.uid AS item, null AS detail
UNION
MATCH (:ProtocolStep)-[u:USES]->(x)
WHERE u.quantity IS NOT NULL AND u.quantityMax IS NOT NULL AND u.quantity > u.quantityMax
RETURN 'DOSE_RANGE_INVERTED' AS violation, x.uid AS item, u.verbatimDoseText AS detail;

// V-529b (informational): a verbatim range ("3 to 6", "3-6") stored as a single value is a possible midpoint/endpoint collapse.
MATCH (n)
WHERE (n:ProtocolStep OR n:ProtocolEdition) AND n.scheduleText =~ '(?i).*\\b\\d+\\s*(to|-|–)\\s*\\d+\\s*(minutes|hours|days|weeks|months|years).*'
  AND n.cadenceIntervalMin IS NOT NULL AND n.cadenceIntervalMin = n.cadenceIntervalMax
RETURN 'POSSIBLE_RANGE_COLLAPSE' AS finding, n.uid AS item, n.scheduleText AS detail
UNION
MATCH (n:MeasurementPlan)
WHERE n.scheduleText =~ '(?i).*\\b\\d+\\s*(to|-|–)\\s*\\d+\\s*(weeks|months|years).*' AND n.cadenceMinDays = n.cadenceMaxDays
RETURN 'POSSIBLE_RANGE_COLLAPSE' AS finding, n.uid AS item, n.scheduleText AS detail;

// V-530p: an edition is SOURCE_VERSIONED or SNAPSHOT_DIFF, never THIRD_PARTY_REPORTED
// (forbidden implication [THIRD_PARTY_REPORTS_PROTOCOL_CHANGE, PROTOCOL_EDITION_EXISTS]); SOURCE_VERSIONED needs the source's label.
MATCH (e:ProtocolEdition)
WHERE e.changeProvenance IS NULL OR e.changeProvenance = 'THIRD_PARTY_REPORTED'
   OR (e.changeProvenance = 'SOURCE_VERSIONED' AND e.editionLabel IS NULL)
RETURN CASE WHEN e.changeProvenance = 'THIRD_PARTY_REPORTED' THEN 'EDITION_FROM_THIRD_PARTY_REPORT'
            WHEN e.changeProvenance IS NULL THEN 'EDITION_WITHOUT_CHANGE_PROVENANCE'
            ELSE 'SOURCE_VERSIONED_WITHOUT_LABEL' END AS violation, e.uid AS item, null AS detail;

// V-531p: dependency kinds do not contradict (mutually exclusive steps are neither concurrent nor ordered; an exclusive pair is not both ESSENTIAL;
// REQUIRES_RESULT_OF points at a step that produces a result).
MATCH (a:ProtocolStep)-[x:DEPENDS_ON {dependencyKind: 'MUTUALLY_EXCLUSIVE_WITH'}]-(b:ProtocolStep), (a)-[y:DEPENDS_ON]-(b)
WHERE y.dependencyKind <> 'MUTUALLY_EXCLUSIVE_WITH'
RETURN DISTINCT 'EXCLUSIVE_AND_' + y.dependencyKind AS violation, a.uid AS item, b.stepKey AS detail
UNION
MATCH (a:ProtocolStep {requirementLevel: 'ESSENTIAL'})-[:DEPENDS_ON {dependencyKind: 'MUTUALLY_EXCLUSIVE_WITH'}]-(b:ProtocolStep {requirementLevel: 'ESSENTIAL'})
WHERE elementId(a) < elementId(b)
RETURN 'EXCLUSIVE_PAIR_BOTH_ESSENTIAL' AS violation, a.uid AS item, b.stepKey AS detail
UNION
MATCH (a:ProtocolStep)-[:DEPENDS_ON {dependencyKind: 'REQUIRES_RESULT_OF'}]->(b:ProtocolStep)
WHERE NOT b.stepKind IN ['MEASURE', 'TEST', 'SAMPLE', 'OBSERVE', 'MONITOR', 'RECORD', 'REVIEW', 'DECISION']
RETURN 'RESULT_DEPENDENCY_ON_NON_RESULT_STEP' AS violation, a.uid AS item, b.stepKey AS detail;

// V-532p: every public Observation is source-attributed (asserted RECORDS, or inclusion in a ProtocolResult with an asserted FOR_PROTOCOL/POSTS_RESULT).
MATCH (o:Observation)
WHERE NOT EXISTS { MATCH (:Person)-[r:RECORDS]->(o) WHERE r.assertionUid IS NOT NULL }
  AND NOT EXISTS { MATCH (pr:ProtocolResult)-[:INCLUDES_OBSERVATION]->(o)
                   WHERE EXISTS { MATCH (pr)-[f:FOR_PROTOCOL]->() WHERE f.assertionUid IS NOT NULL }
                      OR EXISTS { MATCH (:Person)-[q:POSTS_RESULT]->(pr) WHERE q.assertionUid IS NOT NULL } }
RETURN 'UNATTRIBUTED_OBSERVATION' AS violation, o.uid AS item, null AS detail;

// V-533p: rule basis and privacy agree: BELLLABS_SAFETY_POLICY rules are INTERNAL and name a PolicyVersion; source rules are PUBLIC.
MATCH (r:ProtocolAdjustmentRule)
WHERE (r.ruleBasis = 'BELLLABS_SAFETY_POLICY' AND (r.privacyClass <> 'INTERNAL' OR r.policyVersionUid IS NULL))
   OR (r.ruleBasis = 'STATED_BY_SOURCE' AND r.policyVersionUid IS NOT NULL)
RETURN 'RULE_BASIS_PRIVACY_MISMATCH' AS violation, r.uid AS item, r.ruleBasis AS detail;

// V-534p: no execution, adoption or adherence data on public protocol records (forbidden implication [ADOPTED_PROTOCOL_EDITION, FOLLOWS_ALL_STEPS]).
MATCH (n)
WHERE (n:Protocol OR n:ProtocolEdition OR n:ProtocolStep)
  AND any(k IN keys(n) WHERE k IN ['adherence', 'adherent', 'adoptedBy', 'adoptedAt', 'followedAllSteps', 'followsAllSteps', 'omittedByUser',
                                   'deviationKind', 'deviationStepKeys', 'personalValueNumber', 'completedAt', 'lastDeviationUid'])
RETURN 'EXECUTION_DATA_ON_PUBLIC_PROTOCOL' AS violation, n.uid AS item, [k IN keys(n) WHERE k IN ['adherence', 'adherent', 'adoptedBy', 'adoptedAt', 'followedAllSteps', 'followsAllSteps', 'omittedByUser', 'deviationKind', 'deviationStepKeys', 'personalValueNumber', 'completedAt', 'lastDeviationUid']] AS detail
UNION
MATCH (x)-[r]->(n)
WHERE (n:Protocol OR n:ProtocolEdition OR n:ProtocolStep)
  AND type(r) IN ['FOLLOWS', 'FOLLOWS_PROTOCOL', 'ADOPTED', 'ADOPTED_IN_PRIVATE', 'OMITTED_STEP', 'COMPLETED_STEP', 'ADHERES_TO', 'SKIPPED_STEP']
RETURN 'EXECUTION_EDGE_ON_PUBLIC_PROTOCOL' AS violation, n.uid AS item, type(r) AS detail;

// V-536p: Observation ABOUT_CONDITION is asserted (forbidden implication [OUTSIDE_REFERENCE_RANGE_TRIGGER, CONDITION_PRESENT]):
// it carries an assertionUid of an Assertion with that predicate, never a derivation from a rule or threshold.
MATCH (o:Observation)-[r:ABOUT_CONDITION]->(c)
WHERE r.assertionUid IS NULL OR r.derivationRule IS NOT NULL
   OR NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) WHERE a.predicate = 'ABOUT_CONDITION' }
RETURN 'CONDITION_NOT_ASSERTED' AS violation, o.uid AS item, c.uid AS detail;

// V-537p: a declared step dose with a quantity carries a UCUM unit and a quantity basis.
MATCH (s:ProtocolStep)-[u:USES]->(x)
WHERE u.quantity IS NOT NULL AND (u.unitCode IS NULL OR u.quantityBasis IS NULL)
RETURN 'DOSE_WITHOUT_UNIT_OR_BASIS' AS violation, s.uid AS item, coalesce(u.verbatimDoseText, x.uid) AS detail;

// V-538p: component (step) evidence never becomes protocol-level efficacy by calculation (CQ-PR-06):
// a CALCULATED efficacy assertion about a Protocol/ProtocolEdition whose inputs are all step- or substance-level is a violation.
MATCH (a:Assertion)-[:HAS_SUBJECT]->(x)
WHERE (x:Protocol OR x:ProtocolEdition) AND a.basisKind = 'CALCULATED'
  AND a.predicate IN ['PROTOCOL_EFFECTIVE_FOR', 'IMPROVES_OUTCOME', 'REDUCES_RISK_OF', 'SUPPORTED_BY_EVIDENCE']
  AND EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION]->(:Assertion) }
  AND NOT EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION]->(b:Assertion)-[:HAS_SUBJECT]->(y) WHERE y:Protocol OR y:ProtocolEdition }
RETURN 'COMPONENT_EVIDENCE_TRANSFERRED_TO_PROTOCOL' AS violation, a.uid AS item, x.uid AS detail;

// V-539p: HAS_PROTOCOL_EDITION is a faithful projection of its Assertion (predicate, subject, object, valid time, recordedFrom).
MATCH (p:Protocol)-[h:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition)
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
WITH p, h, e, a
WHERE a IS NULL OR a.predicate <> 'HAS_PROTOCOL_EDITION'
   OR NOT (a)-[:HAS_SUBJECT]->(p) OR NOT (a)-[:HAS_OBJECT]->(e)
   OR coalesce(toString(a.validFrom), '-') <> coalesce(toString(h.validFrom), '-')
   OR coalesce(toString(a.validTo), '-') <> coalesce(toString(h.validTo), '-')
   OR h.recordedFrom < a.recordedAt
RETURN 'EDITION_EPISODE_NOT_A_PROJECTION' AS violation, e.uid AS item, h.relationshipUid AS detail;

// V-540p: an adjustment rule modifies steps of an edition that owns the rule.
MATCH (e:ProtocolEdition)-[:HAS_ADJUSTMENT_RULE]->(r:ProtocolAdjustmentRule)-[:MODIFIES_STEP]->(s:ProtocolStep)
WHERE NOT (e)-[:HAS_PROTOCOL_STEP]->(s)
RETURN 'RULE_MODIFIES_FOREIGN_STEP' AS violation, r.uid AS item, s.stepKey AS detail;

// V-541p: a constraint attached with negated or conditionGroup uses a role; a CONDITION/POPULATION threshold has a unit.
MATCH (c:Constraint)
WHERE c.thresholdValue IS NOT NULL AND (c.comparator IS NULL OR c.thresholdUnitCode IS NULL)
RETURN 'THRESHOLD_WITHOUT_COMPARATOR_OR_UNIT' AS violation, c.uid AS item, c.constraintText AS detail;

// V-542p: the derived currentSteps projection equals the steps of the current edition (recordedTo null, not ended) and cites its rule.
MATCH (p:Protocol)-[c:HAS_CURRENT_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE c.derivationRule IS NULL
   OR NOT EXISTS { MATCH (p)-[h:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s)
                   WHERE h.recordedTo IS NULL AND (h.validTo IS NULL OR h.validTo > datetime()) }
RETURN 'STALE_CURRENT_STEP_PROJECTION' AS violation, p.uid AS item, s.stepKey AS detail;
