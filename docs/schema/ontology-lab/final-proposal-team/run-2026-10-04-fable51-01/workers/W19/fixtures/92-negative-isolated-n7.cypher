// W19 isolated negative N7 (load after 01-05 in a fresh instance): the paper's occurrence uses the publisher HTML
// Document as its container instead of the Publication. Expected: V-411 reports the PMC locator as foreign, which is
// the failing case for seam W19-SR-06 (OCCURS_IN must accept Publication).
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w19-pmid-29184669-elysium-provided-ip'})-[r:OCCURS_IN]->()
DELETE r;

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w19-pmid-29184669-elysium-provided-ip'}), (d:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'})
MERGE (a)-[:OCCURS_IN]->(d);
