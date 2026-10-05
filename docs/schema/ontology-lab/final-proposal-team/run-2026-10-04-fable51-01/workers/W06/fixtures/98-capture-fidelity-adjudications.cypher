// =====================================================================================================================
// W06 fixture 98: CAPTURE_FIDELITY adjudications backing every ACCEPTED W06 fixture assertion (INV-103). An ACCEPTED
// status means "accurately records what the source said", never truth. Run after fixtures 00-05.
// The statement binds assertions by uid prefix and creates one adjudication per assertion (uid derived from it).
// =====================================================================================================================
MATCH (a:Assertion)
WHERE a.uid STARTS WITH 'hu:assertion:w06-' AND a.status = 'ACCEPTED' AND NOT a.uid STARTS WITH 'hu:assertion:w06-neg-'
MERGE (adj:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:' + substring(a.uid, 13) + '-capture'})
SET adj.assessmentType = 'Adjudication', adj.adjudicationKind = 'CAPTURE_FIDELITY', adj.verdict = 'SUPPORTED',
    adj.reviewerType = 'AGENT', adj.methodVersion = 'w06-fixture-capture-review-v1', adj.status = 'ACCEPTED',
    adj.reviewedAt = datetime('2026-10-04T02:30:00Z'), adj.recordedAt = datetime('2026-10-04T02:30:00Z'),
    adj.rationale = 'Locator text or record field matches the assertion as captured on 2026-10-04 (W06 Opus 5.5).',
    adj.privacyClass = 'PUBLIC', adj.createdAt = datetime('2026-10-04T02:30:00Z')
MERGE (adj)-[:EVALUATES]->(a);
