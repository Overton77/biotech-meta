// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// NEGATIVE FIXTURE w01-91-negative-privacy-leak: expected to FAIL. Load only after w01-06 into a scratch database.
// L1 live-style HAS_PARTICIPANT_TOKEN from a named Person to a CohortParticipant (re-identification; V-W01-05).
// L2 a CohortParticipant without privacyClass (V-W01-05, V-522).
// L3 a :PrivateRecord node with a hu:private- uid reached from a shared CohortParticipant (V-113; V-521 on the shared side's property).

MERGE (n:Person:Entity {uid: 'hu:person:w01-synthetic-named-volunteer'})
SET n += {id: 'w01-synthetic-named-volunteer', entityType: 'Person', name: 'Synthetic Named Volunteer (negative)', privacyClass: 'PUBLIC', fixtureProvenance: 'SYNTHETIC', createdAt: datetime('2026-10-04T01:10:00Z')};
MATCH (p:Person {uid: 'hu:person:w01-synthetic-named-volunteer'}), (c:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-a-p03'})
MERGE (p)-[:HAS_PARTICIPANT_TOKEN]->(c);
MERGE (n:CohortParticipant:PseudonymousActor:Entity {uid: 'hu:cohort-participant:w01-neg-unclassified'})
SET n += {id: 'w01-neg-unclassified', entityType: 'CohortParticipant', participantToken: 'X1', createdAt: datetime('2026-10-04T01:10:00Z')};
MERGE (n:PrivateRecord {uid: 'hu:private-measurement:w01-neg-sleep-latency'})
SET n += {privacyClass: 'private-personal', valueNumber: 12.0, unitCode: 'min'};
MATCH (c:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-b-p03'}), (p:PrivateRecord {uid: 'hu:private-measurement:w01-neg-sleep-latency'})
MERGE (c)-[:RECORDS]->(p);
