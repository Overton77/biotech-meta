// W05 fixture 08: one CAPTURE_FIDELITY adjudication (reviewerType POLICY) over every ACCEPTED/REJECTED/DISPUTED W05 fixture
// assertion, following the baseline elysium-basis pattern. It records capture fidelity only (what each source said),
// never truth. reviewedAt is after the latest W05 recordedAt (the late-arriving record, 2026-10-05T09:00Z). Load last
// among the positive fixtures (after 01-06). SYNTHETIC reviewer policy.
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w05-capture-fidelity-policy-2026-10-05'})
ON CREATE SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w05-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.rationale = 'W05 fixture capture policy: each recorded proposition matches its cited span or field as read by W05.',
    j.reviewedAt = datetime('2026-10-05T10:00:00Z'), j.recordedAt = datetime('2026-10-05T10:00:00Z'), j.createdAt = datetime('2026-10-05T10:00:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
