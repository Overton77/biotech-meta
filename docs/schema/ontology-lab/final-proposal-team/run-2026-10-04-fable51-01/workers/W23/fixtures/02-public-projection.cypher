// W23 fixture 02: tier closure on data (QUERIES ONLY; load 00-shared-base.cypher first).
// CQ-AX-12, CQ-AX-13, CQ-PC-08. A compiler emits these from a projection request (QS-5a/QS-5b); the label allow-list
// comes from the tier closure table in 04-model-cards.md and the instance test is an ALLOW-list on privacyClass
// (a node is admitted only when privacyClass = 'PUBLIC'), never a deny-list (fixture 13 shows the fail-open variant).

// Q-PP-1 (PUBLIC_ANSWER): every path of 1 to 3 hops, in either direction, from assertion A1 through admitted nodes only.
// Expected: one row; reachesPolicyLayer false, reachesLineage false, reachesAnswerRecord false; reachedLabels contain only
// PUBLIC allow-list labels. The path A1 <-USED- Activity -AUTHORIZED_BY-> PolicyVersion is cut at the INTERNAL Activity.
WITH ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion',
      'Adjudication', 'EvidenceApplicability', 'ApplicabilityDimension', 'Agent'] AS allowed
MATCH (root {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
WHERE root.privacyClass = 'PUBLIC' AND NOT root.uid STARTS WITH 'hu:private-' AND any(l IN labels(root) WHERE l IN allowed)
MATCH p = (root)((x)-[rel]-(n) WHERE n.privacyClass = 'PUBLIC' AND NOT n.uid STARTS WITH 'hu:private-'
                                 AND any(l IN labels(n) WHERE l IN allowed)){1,3}
UNWIND nodes(p) AS m
WITH collect(DISTINCT m) AS reached
UNWIND reached AS m
UNWIND labels(m) AS lbl
WITH reached, collect(DISTINCT lbl) AS reachedLabels
RETURN size(reached) AS reachedNodes, reachedLabels,
       any(m IN reached WHERE m:PolicyVersion OR m:DecisionCriterion) AS reachesPolicyLayer,
       any(m IN reached WHERE m:Activity) AS reachesLineage,
       any(m IN reached WHERE m:AnswerRecord) AS reachesAnswerRecord,
       [m IN reached WHERE m.privacyClass <> 'PUBLIC' | m.uid] AS nonPublicReached;

// Q-PP-2 (OPERATOR_AUDIT): same traversal with the operator closure (INTERNAL lineage and policy admitted; private
// records never). Expected: one row; reachesPolicyLayer true (the use-authorization policy v1, two hops from A1 through the
// composing Activity), reachesLineage true, reachesAnswerRecord true; no hu:private- uid.
WITH ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion',
      'Adjudication', 'EvidenceApplicability', 'ApplicabilityDimension', 'Agent', 'Activity', 'PolicyVersion',
      'DecisionCriterion', 'AnswerRecord'] AS allowed
MATCH (root {uid: 'hu:assertion:w23-a1-variant-fv-a1'})
MATCH p = (root)((x)-[rel]-(n) WHERE n.privacyClass IN ['PUBLIC', 'INTERNAL'] AND NOT n.uid STARTS WITH 'hu:private-'
                                 AND any(l IN labels(n) WHERE l IN allowed)){1,3}
UNWIND nodes(p) AS m
WITH collect(DISTINCT m) AS reached
RETURN size(reached) AS reachedNodes,
       any(m IN reached WHERE m:PolicyVersion OR m:DecisionCriterion) AS reachesPolicyLayer,
       any(m IN reached WHERE m:Activity) AS reachesLineage,
       any(m IN reached WHERE m:AnswerRecord) AS reachesAnswerRecord,
       [m IN reached WHERE m:PolicyVersion | m.uid] AS policyVersionsReached,
       [m IN reached WHERE m.uid STARTS WITH 'hu:private-' | m.uid] AS privateReached;

// Q-PP-3 (PUBLIC_ANSWER, field closure): which INTERNAL fields the compiler must strip from admitted PUBLIC nodes before
// they leave the graph (mongoResearchRunId, privacyClass, derived search fields, agentRunUid, humanReviewPending).
// Expected on the base: one row; every admitted PUBLIC node carries privacyClass (a filter key, stripped from output);
// no admitted node carries mongoResearchRunId; projectedKeysLeakingInternal = 0.
WITH ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion',
      'Adjudication', 'EvidenceApplicability', 'ApplicabilityDimension', 'Agent'] AS allowed,
     ['mongoResearchRunId', 'privacyClass', 'searchText', 'searchFields', 'searchEmbedding', 'embeddingModel',
      'embeddingDimensions', 'agentRunUid', 'humanReviewPending'] AS internalFields
MATCH (n)
WHERE n.privacyClass = 'PUBLIC' AND any(l IN labels(n) WHERE l IN allowed)
WITH n, [k IN keys(n) WHERE k IN internalFields] AS strip, [k IN keys(n) WHERE NOT k IN internalFields] AS projectedKeys, internalFields
UNWIND (CASE WHEN size(strip) = 0 THEN [null] ELSE strip END) AS stripKey
WITH count(DISTINCT n) AS admittedPublicNodes, collect(DISTINCT stripKey) AS fieldsStripped,
     sum(size([k IN projectedKeys WHERE k IN internalFields])) AS projectedKeysLeakingInternal,
     count(DISTINCT CASE WHEN n.mongoResearchRunId IS NOT NULL THEN n END) AS admittedWithRunId
RETURN admittedPublicNodes, fieldsStripped, admittedWithRunId, projectedKeysLeakingInternal;
