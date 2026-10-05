// W23 fixture 03: decision replay at the decision's viewpoint after a later correction (QUERIES ONLY).
// Load 00-shared-base.cypher first; run with --params replay-params.json. CQ-RC-02, CQ-RC-04, CQ-RC-07, CQ-PC-08.
// The private RecommendationSnapshot is NOT in the graph: it is the private-store contract (private-store-interface.md
// section 5). Only its shared half arrives as parameters: shared uids plus evidenceRecordedAt and evidenceValidAt.
// The correction A2 SUPERSEDES A1 was recorded on 2026-06-15, after the decision viewpoint 2026-04-10T09:00Z.

// Q-DR-1 (CQ-RC-04): edge-level as-of replay at the stored viewpoint (QS-2b with R = evidenceRecordedAt, V = evidenceValidAt).
// Expected: one row; heldAtViewpoint fv-a1 (200 mg) authorized by A1; reproduced true (the replay returns the old belief).
UNWIND $options AS opt
MATCH (v {uid: opt.subjectUid})-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE h.recordedFrom <= datetime($evidenceRecordedAt) AND (h.recordedTo IS NULL OR datetime($evidenceRecordedAt) < h.recordedTo)
  AND (h.validFrom IS NULL OR h.validFrom <= datetime($evidenceValidAt)) AND (h.validTo IS NULL OR datetime($evidenceValidAt) < h.validTo)
RETURN opt.subjectUid AS subjectUid, f.uid AS heldAtViewpoint, h.assertionUid AS authorizedBy, f.uid IN opt.stateUids AS reproduced;

// Q-DR-2 (CQ-RC-07 comparison): the same valid instant read at the current recorded viewpoint. Expected: one row;
// heldNow fv-a1c (120 mg) authorized by A2; matchesSnapshot false. The snapshot itself is never edited.
UNWIND $options AS opt
MATCH (v {uid: opt.subjectUid})-[h:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE h.recordedFrom <= datetime($nowRecordedAt) AND (h.recordedTo IS NULL OR datetime($nowRecordedAt) < h.recordedTo)
  AND (h.validFrom IS NULL OR h.validFrom <= datetime($evidenceValidAt)) AND (h.validTo IS NULL OR datetime($evidenceValidAt) < h.validTo)
RETURN opt.subjectUid AS subjectUid, f.uid AS heldNow, h.assertionUid AS authorizedBy, f.uid IN opt.stateUids AS matchesSnapshot;

// Q-DR-3 (CQ-RC-07): evidence uids of the snapshot superseded after its viewpoint. Expected: one row; A1 superseded by A2,
// SOURCE_CORRECTION, learnedAt 2026-06-15T08:10Z. The private store opens PendingItem {pendingKind: EVIDENCE_REVIEW}.
UNWIND $options AS opt
UNWIND opt.evidenceAssertionUids AS aUid
MATCH (a:Assertion {uid: aUid})<-[s:SUPERSEDES]-(newer:Assertion)
WHERE s.recordedAt > datetime($evidenceRecordedAt)
RETURN aUid AS supersededEvidence, newer.uid AS supersededBy, s.supersessionKind AS supersessionKind, s.recordedAt AS learnedAt;

// Q-DR-4 (CQ-RC-02): adjudication verdicts as held at the viewpoint. Expected: one row; cf-a1 CAPTURE_FIDELITY SUPPORTED
// reviewed 2026-03-02T10:20Z, visibleAtViewpoint true.
UNWIND $options AS opt
UNWIND opt.adjudicationUids AS jUid
MATCH (j:Adjudication {uid: jUid})
RETURN jUid AS adjudicationUid, j.adjudicationKind AS kind, j.verdict AS verdict, j.reviewedAt AS reviewedAt,
       j.reviewedAt <= datetime($evidenceRecordedAt) AS visibleAtViewpoint;

// Q-DR-5 (CQ-RC-02, CQ-RC-03; OWNER_PRIVATE explanation support): identity fields of the policy version the snapshot
// names, its declared criteria and required fact keys. Read by the private-store service only (INTERNAL); the subset test
// snapshot.missingFactKeys <= requiredFactKeys runs inside the private store. Expected: one row; sleep-support-ranking v3,
// payloadHash sha256:0c84db66..., criteria [WEAKEST_APPLICABILITY_DIMENSION, SAFETY_BLOCK], three required fact keys,
// effectiveAtDecision true.
MATCH (pv:PolicyVersion {uid: $policyVersionUid})
OPTIONAL MATCH (pv)-[d:DECLARES_CRITERION]->(dc:DecisionCriterion)
WITH pv, d, dc ORDER BY d.orderIndex
WITH pv, collect(dc.criterionKey + '@' + dc.methodVersion) AS criteria
RETURN pv.policyKey AS policyKey, pv.versionLabel AS versionLabel, pv.payloadHash AS payloadHash, criteria,
       pv.requiredFactKeys AS requiredFactKeys,
       pv.effectiveFrom <= datetime($evidenceRecordedAt) AND (pv.effectiveTo IS NULL OR datetime($evidenceRecordedAt) < pv.effectiveTo) AS effectiveAtDecision,
       pv.createdAt <= datetime($evidenceRecordedAt) AS recordedBeforeDecision;
