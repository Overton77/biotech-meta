// fx01 NEGATIVE injections (load after the positive fixture; each is expected to produce validator rows).

// N01-a: invented video offsets on the transcript-page locator -> V-W21-01 row.
MATCH (l:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'})
SET l.mediaStartSeconds = 3765.0, l.mediaEndSeconds = 3773.0;

// N01-b: the feed sponsor segment delimited by a YouTube locator -> V-W21-05 row (rendition mismatch).
MATCH (g:EpisodeSegment {uid: 'hu:episode-segment:hl52-feed-sponsor-block-observed-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-chapter-sponsors'})
MERGE (g)-[:DELIMITED_BY]->(l);

// N01-c: sponsorship pointed at a rendition Source instead of the work -> V-W21-07 row.
MATCH (b:ConsumerBrand {uid: 'hu:brand:ag1'}), (s:Source {uid: 'hu:source:apple-podcasts-hl52'})
MERGE (b)-[r:SPONSORS_CONTENT {assertionUid: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-ag1'}]->(s)
SET r.relationshipUid = 'hu:rel:w21-neg-sponsor-rendition', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// N01-d: an endorsement edge "derived" from the sponsor read -> V-422 row (and QS-4a FORBIDDEN_IMPLICATION_USED_AS_PREMISE).
MATCH (b:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (p:Person {uid: 'hu:person:andrew-d-huberman'})
MERGE (p)-[e:ENDORSES_PRODUCT {assertionUid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'}]->(b);
