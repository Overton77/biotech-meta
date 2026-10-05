// W19 isolated negative N1a (load after 01-05 in a fresh instance): the slide-deck claim moved into the talk's
// container, with NO rendition edge from the deck. Expected: V-411 reports the deck locator as foreign.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-slides-nmn-250-raises-nad'})-[r:OCCURS_IN]->()
DELETE r;

MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-slides-nmn-250-raises-nad'}), (e:Episode {uid: 'hu:episode:synthetic-nad-conference-talk-2026'})
MERGE (a)-[:OCCURS_IN]->(e);
