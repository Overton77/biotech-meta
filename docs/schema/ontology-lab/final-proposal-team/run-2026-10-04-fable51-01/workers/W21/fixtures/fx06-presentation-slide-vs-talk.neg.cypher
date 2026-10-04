// fx06 NEGATIVE injections.
// N06-a: the deck recorded as a rendition of the talk -> V-W21-03 row.
MATCH (d:Document {uid: 'hu:source:merck-jpm-2026-presentation-pdf'}), (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'})
MERGE (d)-[:RENDITION_OF]->(e);
// N06-b: the spoken occurrence cites the slide (synthetic part, where the deck is NOT a rendition) -> V-411 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-conf-talk-3-spoken-claim'}), (l:SourceLocator {uid: 'hu:locator:synthetic-conf-talk-3-slide-7'})
MERGE (a)-[:SUPPORTED_BY]->(l);
// N06-c: an invented media offset on the transcript PDF -> V-W21-01 row.
MATCH (l:SourceLocator {uid: 'hu:locator:w21-merck-transcript-davis-70-billion'}) SET l.mediaStartSeconds = 1500.0;
// N06-d: a qualifier taken from a different container (the talk) attached to the slide statement -> V-416 and V-W21-12 rows.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-merck-deck-slide-11-opportunity'}), (b:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-merck-talk-davis-70-billion'})
MERGE (a)-[q:QUALIFIED_BY]->(b) SET q.qualificationKind = 'TIME_SCOPE', q.relationshipUid = 'hu:rel:w21-neg-cross-container-qualifier';
// N06-e: an unbacked accompaniment edge (no assertion) -> V-112-style audit is not scoped to ACCOMPANIES_TALK in the
// baseline params; W21 records it for the asserted-types list (W21-SR-16).
