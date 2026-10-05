// W23 validation queries V-W23-01 ... V-W23-10 (proposed; ids are W23-local until Fable numbers them).
// Zero rows = valid unless marked informational. Each statement binds its own variables; nothing crosses ';'.
// Literal lists are generated from sdl-fragment.graphql (AnswerRecord fields) and from private-store-interface.md
// section 9 (private-store label and private-only property name registry); the runner may pass them as parameters.
// Status: executed on embedded Neo4j 5.26.31 Community, 2026-10-04 (results in 06-fixtures-and-queries.md).

// V-W23-01a: a shared AnswerRecord is never an owner-private answer, never computed with private context, and is INTERNAL.
// INV-506, projection-contract invariant 1, CQ-AX-03, CQ-PC-08.
MATCH (r:AnswerRecord)
WHERE r.accessTier IS NULL OR NOT r.accessTier IN ['PUBLIC_ANSWER', 'OPERATOR_AUDIT', 'AGENT_PROJECTION']
   OR coalesce(r.privateContext, '-') <> 'EXCLUDED'
   OR coalesce(r.privacyClass, '-') <> 'INTERNAL'
RETURN 'ANSWER_RECORD_TIER_OR_CLASS' AS violation, r.uid AS answerRecordUid, r.accessTier AS accessTier,
       r.privateContext AS privateContext, r.privacyClass AS privacyClass;

// V-W23-01b: an AnswerRecord carries only allow-listed properties (successor of V-121's three named keys: any key that
// could identify an asker, session or question is rejected even when it is not userUid, ownerUid or questionText).
MATCH (r:AnswerRecord)
WITH r, [k IN keys(r) WHERE NOT k IN ['id', 'uid', 'name', 'description', 'mongoResearchRunId', 'createdAt', 'updatedAt',
  'privacyClass', 'maturity', 'schemaVersion', 'occurrenceType', 'startedAt', 'endedAt', 'recordedAsOf', 'validAt',
  'intervalStart', 'intervalEnd', 'schemaDigest', 'queryShapeId', 'queryShapeVersion', 'accessTier', 'privateContext',
  'traceDepth', 'publishedAt']] AS extraKeys
WHERE size(extraKeys) > 0
RETURN 'ANSWER_RECORD_PROPERTY_NOT_ALLOWED' AS violation, r.uid AS answerRecordUid, extraKeys;

// V-W23-02: citations are visible at the answer's own viewpoint, and the viewpoint is well formed (CQ-AX-03 replay).
MATCH (r:AnswerRecord)-[:CITES_ASSERTION|CITES_ASSESSMENT]->(x)
WHERE x.recordedAt IS NULL OR x.recordedAt > r.recordedAsOf
RETURN 'CITATION_RECORDED_AFTER_VIEWPOINT' AS violation, r.uid AS answerRecordUid, x.uid AS citedUid
UNION
MATCH (r:AnswerRecord)-[:CITES_ASSERTION]->(a:Assertion)
WHERE EXISTS { MATCH (:Assertion)-[s:SUPERSEDES]->(a) WHERE s.recordedAt <= r.recordedAsOf }
RETURN 'CITATION_ALREADY_SUPERSEDED_AT_VIEWPOINT' AS violation, r.uid AS answerRecordUid, a.uid AS citedUid
UNION
MATCH (r:AnswerRecord)
WHERE r.recordedAsOf IS NULL OR r.recordedAsOf > r.createdAt
   OR (r.publishedAt IS NOT NULL AND r.recordedAsOf > r.publishedAt)
   OR (r.validAt IS NOT NULL AND (r.intervalStart IS NOT NULL OR r.intervalEnd IS NOT NULL))
   OR (r.intervalStart IS NOT NULL AND r.intervalEnd IS NOT NULL AND r.intervalStart >= r.intervalEnd)
RETURN 'VIEWPOINT_MALFORMED' AS violation, r.uid AS answerRecordUid, null AS citedUid;

// V-W23-03: citation endpoints and trace presence. CITES_ASSERTION ends on :Assertion, CITES_ASSESSMENT on
// :EvidenceAssessment; an answer with traceDepth other than NONE cites at least one assertion.
MATCH (r:AnswerRecord)-[c:CITES_ASSERTION]->(x)
WHERE NOT x:Assertion
RETURN 'CITES_ASSERTION_WRONG_ENDPOINT' AS violation, r.uid AS answerRecordUid, x.uid AS targetUid
UNION
MATCH (r:AnswerRecord)-[c:CITES_ASSESSMENT]->(x)
WHERE NOT x:EvidenceAssessment
RETURN 'CITES_ASSESSMENT_WRONG_ENDPOINT' AS violation, r.uid AS answerRecordUid, x.uid AS targetUid
UNION
MATCH (r:AnswerRecord)
WHERE coalesce(r.traceDepth, 'LOCATOR') <> 'NONE' AND NOT EXISTS { (r)-[:CITES_ASSERTION]->(:Assertion) }
RETURN 'TRACED_ANSWER_WITHOUT_CITATION' AS violation, r.uid AS answerRecordUid, null AS targetUid;

// V-W23-03b (informational until seam W23-SR-02 is ruled): published answers without their ANSWER_COMPOSITION Activity.
MATCH (r:AnswerRecord)
WHERE NOT EXISTS { (r)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'ANSWER_COMPOSITION'}) }
RETURN r.uid AS answerRecordWithoutCompositionActivity;

// V-W23-04: no shared index (range, text, point, lookup, fulltext or vector) covers a private-store label or a
// private-only property name (INV-105 "no shared search index covers private data"; complements V-115, which can
// only see private NODES and therefore misses an index created before any private node exists).
SHOW INDEXES YIELD name, type, labelsOrTypes, properties
WHERE any(l IN coalesce(labelsOrTypes, []) WHERE l IN ['PrivateRecord', 'UserContext', 'UserContextVersion', 'UserGoal',
        'UserGoalVersion', 'PersonalMeasurement', 'PersonalLabReport', 'ProtocolInUse', 'ProtocolAdoptionVersion',
        'ProtocolDeviation', 'SharingGrant', 'DisclosureEvent', 'PendingItem', 'PurchaseEvent',
        'PersonalApplicabilityAssessment', 'ErasureTombstone', 'RecommendationRequest', 'RecommendationSnapshot',
        'RecommendationOption', 'DecisionCriterionValue', 'UserDecision'])
   OR any(p IN coalesce(properties, []) WHERE p IN ['goalVersionUids', 'measurementUids', 'declaredConditionUids',
        'declaredIntakeUids', 'preferenceKeys', 'goalStatement', 'personalValueNumber', 'personalUnitCode', 'granteeKind',
        'granteeRef', 'dataCategories', 'permittedActions', 'grantUid', 'subjectKeyHash', 'userContextVersionUid',
        'evidenceRecordedAt', 'evidenceValidAt', 'decisionOutcome', 'rationaleSummary', 'decisionConfidence',
        'decisionConfidenceMethod', 'missingFactKeys', 'snapshotHash', 'rejectionReason', 'blockingConstraintUids',
        'adoptedEditionUid', 'deviationKind', 'provenanceKind', 'reportedReferenceRangeText', 'labReportUid',
        'issuingLabName', 'fileObjectRef', 'optionUid', 'pendingKind', 'blocksUid', 'resolvedByUid',
        'sharedApplicabilityUid', 'erasedAt', 'propagationStatus', 'requestUid', 'substituteSubjectUid', 'criterionUid',
        'offerObservationUids'])
RETURN 'INDEX_COVERS_PRIVATE_LABEL_OR_PROPERTY' AS violation, name AS indexName, type AS indexType, labelsOrTypes, properties;

// V-W23-05: public-person-only rule (CL-018, CL-008). RECORDS (Person->Observation) and POSTS_RESULT (Person->ProtocolResult),
// kept by W16, and the legacy REPORTS (CohortParticipant->ExperienceReport) and AUTHORS->ExperienceReport edges still present
// until W21's migration, exist only as projections of a source-attributed Assertion (same predicate, subject and object, at
// least one SUPPORTED_BY locator in a SourceSnapshot) between two PUBLIC records. HAS_PARTICIPANT_TOKEN (Person->CohortParticipant)
// is retired (W01; a person-to-token link is re-identification): every instance is a violation. A BellLabs user is never a
// Person and private data never becomes an Observation, ProtocolResult or ExperienceReport this way.
MATCH (x)-[e:RECORDS|POSTS_RESULT|HAS_PARTICIPANT_TOKEN|REPORTS|AUTHORS]->(y)
WHERE type(e) <> 'AUTHORS' OR y:ExperienceReport
OPTIONAL MATCH (a:Assertion {uid: e.assertionUid})
WITH x, e, y, a,
     [v IN [
        CASE WHEN type(e) = 'HAS_PARTICIPANT_TOKEN' THEN 'RETIRED_REIDENTIFICATION_EDGE' END,
        CASE WHEN e.assertionUid IS NULL OR e.recordedFrom IS NULL THEN 'NOT_ASSERTION_BACKED' END,
        CASE WHEN e.assertionUid IS NOT NULL AND a IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN a IS NOT NULL AND (a.predicate <> type(e)
                  OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(y) }) THEN 'ASSERTION_DOES_NOT_MATCH_EDGE' END,
        CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot) } THEN 'NOT_SOURCE_ATTRIBUTED' END,
        CASE WHEN coalesce(x.privacyClass, '-') <> 'PUBLIC' OR coalesce(y.privacyClass, '-') <> 'PUBLIC' THEN 'ENDPOINT_NOT_PUBLIC' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN type(e) AS relType, x.uid AS fromUid, y.uid AS toUid, violations;

// V-W23-06: CohortParticipant token hygiene. participantToken is the label a public source printed (for example
// 'Participant 12'); it is never a BellLabs uid, a private-store reference or a hash-like linkage token, and a participant
// exists only through a source-attributed record: an asserted HAS_IDENTIFIER to an Identifier of scheme PARTICIPANT_TOKEN
// (W01 final form), the asserter of a ClaimOccurrence (W21 final form), or a legacy assertion-backed REPORTS edge.
MATCH (cp:CohortParticipant)
WITH cp,
     [v IN [
        CASE WHEN cp.participantToken IS NOT NULL AND (cp.participantToken STARTS WITH 'hu:' OR toLower(cp.participantToken) STARTS WITH 'pcs'
                  OR cp.participantToken =~ '(?i)^(sha256:)?[0-9a-f]{32,}$') THEN 'TOKEN_LOOKS_LIKE_INTERNAL_IDENTIFIER' END,
        CASE WHEN NOT EXISTS { MATCH (cp)-[e:REPORTS]->() WHERE e.assertionUid IS NOT NULL }
              AND NOT EXISTS { MATCH (cp)-[e:HAS_IDENTIFIER]->(i:Identifier) WHERE e.assertionUid IS NOT NULL AND i.scheme = 'PARTICIPANT_TOKEN' }
              AND NOT EXISTS { MATCH (:ClaimOccurrence)-[:ASSERTED_BY]->(cp) } THEN 'PARTICIPANT_WITHOUT_SOURCED_RECORD' END,
        CASE WHEN coalesce(cp.privacyClass, '-') <> 'PUBLIC' THEN 'PARTICIPANT_NOT_PUBLIC' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN cp.uid AS cohortParticipantUid, cp.participantToken AS participantToken, violations;

// V-W23-07: a use authorization names a USE_AUTHORIZATION policy version that permits that use kind, was recorded
// before the activity, and was in effect when the activity started (provenance state 5; extends V-429, which checks
// only that some PolicyVersion with some useKind exists). Unknown rights are not permission: null effectiveFrom fails.
MATCH (act:Activity)-[u:AUTHORIZED_BY]->(pv:PolicyVersion)
WITH act, u, pv,
     [v IN [
        CASE WHEN coalesce(pv.policyKind, '-') <> 'USE_AUTHORIZATION' THEN 'POLICY_KIND_NOT_USE_AUTHORIZATION' END,
        CASE WHEN u.useKind IS NULL OR NOT u.useKind IN coalesce(pv.permittedUseKinds, []) THEN 'USE_KIND_NOT_PERMITTED' END,
        CASE WHEN act.startedAt IS NULL OR pv.effectiveFrom IS NULL OR act.startedAt < pv.effectiveFrom
                  OR (pv.effectiveTo IS NOT NULL AND act.startedAt >= pv.effectiveTo) THEN 'OUTSIDE_EFFECTIVE_PERIOD' END,
        CASE WHEN pv.createdAt IS NULL OR act.startedAt IS NULL OR pv.createdAt > act.startedAt THEN 'POLICY_RECORDED_AFTER_USE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN act.uid AS activityUid, u.useKind AS useKind, pv.uid AS policyVersionUid, violations;

// V-W23-08: INTERNAL policy layer hygiene. PolicyVersion and DecisionCriterion are INTERNAL; versions of one policyKey do
// not possibly overlap in stated effect (a null bound is a possible overlap); DECLARES_CRITERION starts at a ranking policy.
MATCH (n)
WHERE (n:PolicyVersion OR n:DecisionCriterion) AND coalesce(n.privacyClass, '-') <> 'INTERNAL'
RETURN 'POLICY_LAYER_NOT_INTERNAL' AS violation, n.uid AS item, n.privacyClass AS detail
UNION
MATCH (pv:PolicyVersion)
WHERE pv.policyKey IS NULL OR pv.versionLabel IS NULL OR pv.policyKind IS NULL OR pv.payloadHash IS NULL OR NOT pv.payloadHash STARTS WITH 'sha256:'
   OR (pv.effectiveFrom IS NOT NULL AND pv.effectiveTo IS NOT NULL AND pv.effectiveFrom >= pv.effectiveTo)
RETURN 'POLICY_VERSION_MALFORMED' AS violation, pv.uid AS item, pv.policyKey AS detail
UNION
MATCH (p1:PolicyVersion), (p2:PolicyVersion)
WHERE p1.policyKey = p2.policyKey AND elementId(p1) < elementId(p2)
  AND (p1.effectiveTo IS NULL OR p2.effectiveFrom IS NULL OR p2.effectiveFrom < p1.effectiveTo)
  AND (p2.effectiveTo IS NULL OR p1.effectiveFrom IS NULL OR p1.effectiveFrom < p2.effectiveTo)
RETURN 'POLICY_VERSIONS_POSSIBLY_OVERLAP' AS violation, p1.uid + ' / ' + p2.uid AS item, p1.policyKey AS detail
UNION
MATCH (pv:PolicyVersion)-[:DECLARES_CRITERION]->(dc)
WHERE coalesce(pv.policyKind, '-') <> 'RECOMMENDATION_RANKING' OR NOT dc:DecisionCriterion
RETURN 'DECLARES_CRITERION_MISUSED' AS violation, pv.uid AS item, dc.uid AS detail;

// V-W23-09: stored privacy classes use the final vocabulary only ('PUBLIC', 'INTERNAL'). Catches 'private-personal',
// 'PRIVATE_PERSONAL', any misspelling and legacy lower-case values that V-521 (exact 'private-personal') and V-313
// (lower-case list) read differently. Fixture-only :PrivateRecord nodes are excluded as in V-520/V-521.
MATCH (n)
WHERE NOT n:PrivateRecord AND n.privacyClass IS NOT NULL AND NOT n.privacyClass IN ['PUBLIC', 'INTERNAL']
RETURN 'NODE' AS kind, n.uid AS item, n.privacyClass AS privacyClass
UNION
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord AND r.privacyClass IS NOT NULL AND NOT r.privacyClass IN ['PUBLIC', 'INTERNAL']
RETURN 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item, r.privacyClass AS privacyClass;

// V-W23-10: private uid values inside LIST properties of relationships (V-521's relationship branch tests STRING values only).
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
  AND any(k IN keys(r) WHERE r[k] IS :: LIST<STRING> AND any(v IN r[k] WHERE v STARTS WITH 'hu:private-'))
RETURN type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS item, x.uid AS fromUid, y.uid AS toUid;
