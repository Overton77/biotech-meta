// fx03 queries.

// Q03-1 (CQ-CL-02, CQ-CL-08): practice reports in the episode with who said them and in which kind of segment.
MATCH (a:ClaimOccurrence {speechAct: 'REPORTS_PRACTICE'})-[:OCCURS_IN]->(:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MATCH (a)-[:ASSERTED_BY]->(p:Person)
OPTIONAL MATCH (a)-[:OCCURS_IN_SEGMENT]->(g:EpisodeSegment)
RETURN p.name AS speaker, a.valueString AS practice, coalesce(a.segmentKind, 'EDITORIAL') AS segmentKind, g.segmentType AS segmentType
ORDER BY speaker;

// Q03-2 (CQ-CL-02 filter): independent practice reports only (sponsor reads excluded). Expected: G1 only.
MATCH (a:ClaimOccurrence {speechAct: 'REPORTS_PRACTICE'})-[:OCCURS_IN]->(:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
WHERE coalesce(a.segmentKind, '') <> 'SPONSOR_READ'
  AND NOT EXISTS { MATCH (a)-[:OCCURS_IN_SEGMENT]->(:EpisodeSegment {segmentType: 'SPONSOR_READ'}) }
RETURN a.uid AS independentPracticeReport;

// Q03-3 (CQ-CL-05): relevance of financial ties per statement, with disclosure finding and the ties assessed.
MATCH (c:ConflictRelevanceAssessment)-[:FOR_OCCURRENCE]->(a:Assertion)
MATCH (c)-[:ASSESSES_INTEREST]->(i:Assertion)
RETURN a.uid AS statement, c.relevanceLevel AS relevance, c.relevanceBasis AS basis, c.disclosureFinding AS disclosure,
       collect(i.predicate) AS tiesAssessed
ORDER BY statement;

// Q03-4 (CQ-PV-04, caption discrepancy): occurrences whose locators in different renditions carry different
// wording (quote hashes differ). A capture-review item, never a truth signal.
MATCH (a:ClaimOccurrence)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH a, collect(DISTINCT l.quoteHash) AS hashes, collect(src.sourceKind + ': ' + l.exact) AS renderings
WHERE size(hashes) > 1
RETURN a.uid AS occurrence, renderings;

// Q03-5 (forbidden implications): no endorsement, recommendation or truth verdict derived from the ties. Expected 0, 0.
OPTIONAL MATCH ()-[x:ENDORSES_PRODUCT|RECOMMENDS]->()
WITH count(x) AS edges
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})
RETURN edges AS endorsementOrRecommendationEdges, count(j) AS supportVerdicts;
