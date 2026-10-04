// fx06 NEGATIVE injections.
// N06-a: the deck recorded as a rendition of the talk -> V-W21-03 row.
MATCH (d:Document {uid: 'hu:source:merck-jpm-2026-presentation-pdf'}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'})
MERGE (d)-[:RENDITION_OF]->(e);
// N06-b: the spoken occurrence cites the slide (synthetic part, where the deck is NOT a rendition) -> V-411 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-conf-talk-3-spoken-claim'}), (l:SourceLocator {uid: 'hu:locator:synthetic-conf-talk-3-slide-7'})
MERGE (a)-[:SUPPORTED_BY]->(l);
// N06-c: an invented media offset on the transcript PDF -> V-W21-01 row.
MATCH (l:SourceLocator {uid: 'hu:locator:w21-merck-transcript-davis-70-billion'}) SET l.mediaStartSeconds = 1500.0;
