// =====================================================================
// W19 negative mutations. Load AFTER fixtures 01-05 in a separate scenario (never into a shared graph).
// Each mutation reintroduces one collapse; ../06-fixtures-and-queries.md lists the query that must then
// return rows (expected violation ids). Every statement binds its nodes by uid.
// =====================================================================

// N1 (CL-003 / Q-04, V-411): the slide-deck claim is moved into the talk's container. Without a rendition
// edge, V-411 reports the foreign locator ...
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-slides-nmn-250-raises-nad'})-[r:OCCURS_IN]->()
DELETE r;

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-slides-nmn-250-raises-nad'}), (e:Episode {uid: 'hu:episode:synthetic-nad-conference-talk-2026'})
MERGE (a)-[:OCCURS_IN]->(e);

// N1b ... and if the deck is also declared a rendition of the talk, V-411 goes silent while Q-04 reports it.
MATCH (d:Source {uid: 'hu:document:synthetic-nad-talk-slides'}), (e:Episode {uid: 'hu:episode:synthetic-nad-conference-talk-2026'})
MERGE (d)-[:RENDITION_OF]->(e);

// N2 (Q-02): a DOI resolver URL used as a Source identity.
MERGE (s:Source:Entity {uid: 'hu:source:bad-doi-as-source'})
SET s.entityType = 'Source', s.canonicalUri = 'https://doi.org/10.1038/s41514-017-0016-9', s.sourceKind = 'PEER_REVIEWED_PUBLICATION',
    s.createdAt = datetime('2026-10-04T12:00:00Z');

// N3 (Q-03): a Source declared a rendition of another Source, and of two works.
MATCH (pmc:Source {uid: 'hu:document:pmc-PMC5701244'}), (html:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'})
MERGE (pmc)-[:RENDITION_OF]->(html);

// N4 (Q-09 = V-426): "not disclosed" concluded from a partial capture.
MATCH (o:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'}), (r:Assertion {uid: 'hu:assertion:w19-affiliations-sinclair-equity-edenroc'})
MERGE (c:ConflictRelevanceAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-bad-not-disclosed'})
SET c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'INDIRECT', c.disclosureFinding = 'NOT_DISCLOSED', c.recordedAt = datetime('2026-10-04T12:00:00Z'),
    c.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(o)
MERGE (c)-[:ASSESSES_INTEREST]->(r);

// N5 (V-402, Q-11): the old locator is "moved" to the new snapshot instead of re-anchored (two snapshots now hold it).
MATCH (s1:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-2026-10-04'}), (oldL:SourceLocator {uid: 'hu:locator:nature-html-2018-01-nrpt-2x-bottles'})
MERGE (s1)-[:HAS_LOCATOR]->(oldL);

// N6 (Q-12a/Q-12b = V-409): REANCHORS across two different Sources (PMC to publisher HTML) is not a re-anchor.
MATCH (pmcL:SourceLocator {uid: 'hu:locator:pmc-PMC5701244-2026-10-04-elysium-provided-ip'}), (oldL:SourceLocator {uid: 'hu:locator:nature-html-2018-01-nrpt-2x-bottles'})
MERGE (pmcL)-[r:REANCHORS]->(oldL)
SET r.anchorMatch = 'FUZZY';

// N7 (V-411): the paper's occurrence uses one rendition Document as its container; its PMC locator becomes foreign.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w19-pmid-29184669-elysium-provided-ip'})-[r:OCCURS_IN]->()
DELETE r;

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w19-pmid-29184669-elysium-provided-ip'}), (d:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'})
MERGE (a)-[:OCCURS_IN]->(d);

// N8 (Q-14a): an operational discovery record wired into the truth graph.
MATCH (d:SourceDiscoveryRecord {uid: 'hu:activity:w19-discovery-ctgov-history-tab'}), (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-enrollment-120'})
MERGE (d)-[:INVALIDATES]->(a);

// N9 (V-110, Q-14b): coverage staleness written into capture status without an adjudication.
MATCH (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-results-published-false'})
SET a.status = 'REJECTED';

// N10 (Q-14c): a global source truth score.
MATCH (s:Source {uid: 'hu:source:ctgov-nct02678611'})
SET s.reliabilityScore = 0.9;

// N11 (V-410, Q-05): the retelling merged into the original occurrence (second asserter on the original).
MATCH (o:ClaimOccurrence {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'}), (au:Person {uid: 'hu:person:synthetic-digest-author'})
MERGE (o)-[:ASSERTED_BY]->(au);
