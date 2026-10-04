// fx04 queries.

// Q04-1 (CQ-CL-06, CQ-AX-05): per Claim, all instances versus independent first-hand instances (no outgoing RETELLS)
// and distinct first-hand asserters. Retellings never raise independent support.
MATCH (c:Claim)
OPTIONAL MATCH (a:Assertion)-[:INSTANCE_OF]->(c)
WITH c, collect(a) AS inst
UNWIND (CASE WHEN size(inst) = 0 THEN [null] ELSE inst END) AS a
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
WITH c, inst, collect(CASE WHEN a IS NOT NULL AND NOT EXISTS { (a)-[:RETELLS]->() } THEN who.uid END) AS firstHandAsserters
RETURN c.claimText AS claim, size(inst) AS allInstances,
       size([x IN inst WHERE NOT EXISTS { (x)-[:RETELLS]->() }]) AS independentFirstHand,
       size([x IN inst WHERE EXISTS { (x)-[:RETELLS]->() }]) AS retellings,
       size(firstHandAsserters) AS distinctFirstHandAsserters
ORDER BY claim;

// Q04-2 (CQ-CL-03): the qualifications the speaker attached, each with its own span.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})-[q:QUALIFIED_BY]->(b:ClaimOccurrence)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN q.qualificationKind AS kind, l.exact AS qualifierSpan
ORDER BY q.orderIndex;

// Q04-3 (CQ-CL-04): what each retelling changed, read only from the fidelity assessments.
MATCH (f:RetellingFidelityAssessment)-[:ASSESSES_RETELLING]->(r:Assertion)
MATCH (f)-[:AGAINST_ORIGINAL]->(o:Assertion)
OPTIONAL MATCH (f)-[:IDENTIFIES_LOST_QUALIFICATION]->(q:Assertion)
RETURN r.uid AS retelling, f.qualificationLost AS qualificationLost, f.lostQualificationKinds AS lostKinds,
       f.speechActFrom AS speechActFrom, f.speechActTo AS speechActTo, f.scopeBroadened AS scopeBroadened,
       f.addedPurposeText AS addedPurpose, count(q) AS lostQualifierSpans
ORDER BY retelling;

// Q04-4 (CQ-PV-05): primary statement versus retelling, per assertion (replaces live Document.isPrimarySource).
MATCH (a:ClaimOccurrence)-[:OCCURS_IN]->(k)
WHERE a.predicate IN ['SELF_REPORTED_DAILY_INTAKE', 'RECOMMENDS_DAILY_INTAKE']
OPTIONAL MATCH (a)-[x:RETELLS]->(o)
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (a)-[:ATTRIBUTES_TO]->(credited)
RETURN a.uid AS assertion, who.name AS assertedBy, credited.name AS credits, CASE WHEN o IS NULL THEN 'PRIMARY' ELSE 'RETELLING' END AS role,
       x.linkBasis AS linkBasis
ORDER BY role, assertion;

// Q04-5 (CQ-RC-05, pair 22): who recommends NMN by their OWN speech act (expected none) versus who is reported as
// recommending it (expected: Sinclair, reported by the synthetic digest only).
MATCH (n:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})<-[:HAS_SUBJECT]-(a:ClaimOccurrence)
WHERE a.speechAct = 'RECOMMENDS' OR a.reportedSpeechAct = 'RECOMMENDS'
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (a)-[:ATTRIBUTES_TO]->(credited)
RETURN a.uid AS assertion, a.speechAct AS ownAct, a.reportedSpeechAct AS reportedAct, who.name AS asserter, credited.name AS credited;

// Q04-6: no RECOMMENDS projection exists. Expected 0.
MATCH ()-[r:RECOMMENDS]->() RETURN count(r) AS recommendsEdges;
