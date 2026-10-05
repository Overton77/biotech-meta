// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// NEGATIVE FIXTURE w01-90-negative-forbidden-implications: load ONLY after w01-01..w01-06 into a scratch database.
// Each block writes one violation; the expected violation ids are listed in 06-fixtures-and-queries.md section 4.
// N1 ENDORSES_PRODUCT projected from an ADVISES_ORGANIZATION assertion (V-007, V-112, V-422, V-W01-02).
// N2 HOLDS_EQUITY_IN projected from an INVESTED_IN assertion (V-112 FORBIDDEN_IMPLICATION_USED_AS_PREMISE, V-W01-02).
// N3 PARENT_OF projected from a HOLDS_EQUITY_IN assertion (V-W01-02; V-112 once candidate pair [HOLDS_EQUITY_IN, PARENT_OF] is registered).
// N4 BOARD_MEMBER_OF targeting a ConsumerBrand (V-W01-01; note V-434 does not see it).
// N5 a node labelled ConsumerBrand and LegalEntity (V-433, V-W01-03).
// N6 MANUFACTURES_PRODUCT projected from a DISTRIBUTES_PRODUCT assertion (V-112, V-W01-02).
// N7 a Facility with facilityKind VIRTUAL and an Organization label (V-W01-04).
// N8 a role edge projected from a PROPOSED assertion (V-W01-07).
// N9 a person-level equity edge pushed down to a group member company without an assertion naming it (V-434).

MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (x:Product {uid: 'hu:product:w01-synthetic-blood-test-plan'})
MERGE (p)-[r:ENDORSES_PRODUCT {relationshipUid: 'hu:rel:w01-neg-n1'}]->(x)
SET r += {assertionUid: 'hu:assertion:w01-sinclair-advises-segterra-2011-open', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (o:Organization {uid: 'hu:org:segterra'})
MERGE (p)-[r:HOLDS_EQUITY_IN {relationshipUid: 'hu:rel:w01-neg-n2'}]->(o)
SET r += {assertionUid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MATCH (p:Organization {uid: 'hu:org:pioneer-step-holdings-limited'}), (o:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (p)-[r:PARENT_OF {relationshipUid: 'hu:rel:w01-neg-n3'}]->(o)
SET r += {assertionUid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (b:ConsumerBrand {uid: 'hu:brand:insidetracker'})
MERGE (p)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-neg-n4'}]->(b)
SET r += {assertionUid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2017-01-01T00:00:00Z'), validToPrecision: 'YEAR', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MERGE (n:ConsumerBrand:LegalEntity:Organization:Entity {uid: 'hu:org:w01-neg-insidetracker-merged'})
SET n += {id: 'w01-neg-insidetracker-merged', entityType: 'LegalEntity', name: 'InsideTracker (Segterra) merged', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')};
MATCH (o:Organization {uid: 'hu:org:w01-synthetic-brand-owner-llc'}), (x:Product {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})
MERGE (o)-[r:MANUFACTURES_PRODUCT {relationshipUid: 'hu:rel:w01-neg-n6'}]->(x)
SET r += {assertionUid: 'hu:assertion:w01-synth-bo-distributes-sleepwell', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MERGE (n:Facility:Organization:Entity {uid: 'hu:facility:w01-neg-virtual-office'})
SET n += {id: 'w01-neg-virtual-office', entityType: 'Facility', name: 'Virtual office (negative)', facilityKind: 'VIRTUAL', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')};
MATCH (o:Organization {uid: 'hu:org:segterra'}), (b:ConsumerBrand {uid: 'hu:brand:insidetracker'})
MERGE (o)-[r:OWNS_BRAND {relationshipUid: 'hu:rel:w01-neg-n8'}]->(b)
SET r += {assertionUid: 'hu:assertion:w01-segterra-owns-insidetracker-brand-proposed', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
MERGE (n:Organization:Entity {uid: 'hu:org:w01-neg-group-member-co'})
SET n += {id: 'w01-neg-group-member-co', entityType: 'Organization', name: 'Group member company (negative)', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:10:00Z')};
MATCH (p:Person {uid: 'hu:person:david-a-sinclair'}), (o:Organization {uid: 'hu:org:w01-neg-group-member-co'})
MERGE (p)-[r:HOLDS_EQUITY_IN {relationshipUid: 'hu:rel:w01-neg-n9'}]->(o)
SET r += {assertionUid: 'hu:assertion:w01-sinclair-invested-in-segterra-2011-open', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:10:00Z')};
