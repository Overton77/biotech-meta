// fx03 NEGATIVE injections.
// N03-a: a truth verdict on the guest's practice report resting only on the sponsorship (FINANCIAL_INTEREST) -> V-424 row.
MATCH (g1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-guest-measures-45-things'}), (c:ConflictRelevanceAssessment {uid: 'hu:assessment:w21-conflict-relevance-hl52-guest-measuring'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'})
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-neg-verdict-from-sponsorship'})
SET j.id = 'w21-neg-verdict-from-sponsorship', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'SUPPORT', j.verdict = 'CONTRADICTED', j.reviewerType = 'AGENT',
    j.methodVersion = 'neg', j.status = 'PROPOSED', j.reviewedAt = datetime('2026-10-04T02:00:00Z'), j.recordedAt = datetime('2026-10-04T02:00:00Z'), j.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (j)-[:EVALUATES]->(g1)
MERGE (j)-[:CONSIDERS_ASSESSMENT]->(c)
MERGE (j)-[:CONTRADICTED_BY]->(l);

// N03-b: endorsement inferred from the board role -> V-422 and V-112 rows.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (br:ConsumerBrand {uid: 'hu:brand:insidetracker'})
MERGE (sp)-[e:ENDORSES_PRODUCT {assertionUid: 'hu:claim-occurrence:w21-hl52-guest-says-past-board-member-insidetracker'}]->(br);

// N03-c: "not disclosed" concluded from a partial capture -> V-426 row.
MATCH (g1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-guest-measures-45-things'}), (d1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-guest-says-past-board-member-insidetracker'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:w21-neg-not-disclosed'})
SET c.id = 'w21-neg-not-disclosed', c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'neg', c.status = 'PROPOSED', c.relevanceLevel = 'DIRECT',
    c.relevanceBasis = 'SAME_ORGANIZATION', c.disclosureFinding = 'NOT_DISCLOSED', c.recordedAt = datetime('2026-10-04T02:00:00Z'), c.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(g1)
MERGE (c)-[:ASSESSES_INTEREST]->(d1);

// N03-d: DISCLOSED_IN_CONTAINER without a disclosure span -> V-W21-09 row.
MATCH (h1:Assertion {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'}), (a6:Assertion {uid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'})
MERGE (c:EvidenceAssessment:ConflictRelevanceAssessment {uid: 'hu:assessment:w21-neg-disclosed-without-span'})
SET c.id = 'w21-neg-disclosed-without-span', c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'neg', c.status = 'PROPOSED', c.relevanceLevel = 'DIRECT',
    c.relevanceBasis = 'SPONSOR_OF_CONTAINER', c.disclosureFinding = 'DISCLOSED_IN_CONTAINER', c.recordedAt = datetime('2026-10-04T02:00:00Z'), c.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(h1)
MERGE (c)-[:ASSESSES_INTEREST]->(a6);

// N03-e: the sponsor-read statement stripped of its segment marker -> V-W21-02 row (segment and occurrence disagree).
MATCH (h1:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-regular-blood-work'}) REMOVE h1.segmentKind;
