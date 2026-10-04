// fx05 queries.

// Q05-1 (CL-004, V-410): each occurrence in the exchange has exactly one asserter; the speaker labels the sources printed.
MATCH (a:ClaimOccurrence)-[:HAS_SUBJECT]->(:ChemicalSubstance {uid: 'hu:substance:resveratrol'})
MATCH (a)-[:ASSERTED_BY]->(p:Person)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN a.uid AS occurrence, p.name AS asserter, a.speechAct AS speechAct, count(DISTINCT p) AS asserters,
       collect(DISTINCT coalesce(l.speakerLabelInSource, '(no label: caption cue)')) AS speakerLabels
ORDER BY occurrence;

// Q05-2 (CQ-CL-06, CQ-CL-02): first-hand practice reports of resveratrol by the guest. Expected: 1 (the assent);
// the host's question is attributed to the guest but is not his statement and is not an instance of the claim.
MATCH (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-resveratrol-daily'})<-[:INSTANCE_OF]-(a:ClaimOccurrence)-[:ASSERTED_BY]->(p:Person)
WHERE a.speechAct = 'REPORTS_PRACTICE' AND NOT EXISTS { (a)-[:RETELLS]->() }
RETURN count(a) AS firstHandReports, collect(p.name) AS by;
