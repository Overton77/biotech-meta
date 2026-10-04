// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-06-cohort-participant-identity (SYNTHETIC): two public datasets each publish a participant token 'P03'.
// Same scheme and value across two issuers does not establish identity (identity_resolution forbidden implication
// [SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY]); no Person is linked to either participant.


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};
MERGE (n:Source:Entity {uid: 'hu:source:w01-synthetic-public-dataset-a'})
SET n += {id: 'w01-synthetic-public-dataset-a', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'urn:synthetic:w01:public-dataset-a', sourceKind: 'PEER_REVIEWED_PUBLICATION', title: 'Synthetic public dataset A'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-synthetic-public-dataset-a'})
SET n += {id: 'w01-synthetic-public-dataset-a', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), captureCompleteness: 'COMPLETE', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:1bf3b56719bae928d8bfdfa061a573fe56258f83ef29a4e390d5f09315380763', fixtureProvenance: 'SYNTHETIC'};
MATCH (s:Source {uid: 'hu:source:w01-synthetic-public-dataset-a'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-public-dataset-a'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-dataset-a-p03'})
SET n += {id: 'w01-synthetic-dataset-a-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Participant P03 (dataset A) reported improved sleep latency.', quoteHash: 'sha256:f977ad3a052b68755aae225b4c07f7bfcd108a04339866b230c6986d8ef7cd24', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-public-dataset-a'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-dataset-a-p03'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:CohortParticipant:PseudonymousActor:Entity {uid: 'hu:cohort-participant:w01-synthetic-dataset-a-p03'})
SET n += {id: 'w01-synthetic-dataset-a-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'CohortParticipant', name: 'Participant P03 of dataset A', participantToken: 'P03', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Identifier:Entity {uid: 'hu:identifier:w01-participant-token-dataset-a-p03'})
SET n += {id: 'w01-participant-token-dataset-a-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Identifier', scheme: 'PARTICIPANT_TOKEN', issuer: 'hu:source:w01-synthetic-public-dataset-a', value: 'P03'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-dataset-a-p03-token'})
SET a += {id: 'w01-dataset-a-p03-token', predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'IDENTITY', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:8f012f7943124514ccb6f9d88eba6aaddad9fee933b8d83cee7a2024b71421cf'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-dataset-a-p03-token'}), (s {uid: 'hu:cohort-participant:w01-synthetic-dataset-a-p03'}), (o {uid: 'hu:identifier:w01-participant-token-dataset-a-p03'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-dataset-a-p03'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-dataset-a-p03-token-capture'})
SET n += {id: 'w01-dataset-a-p03-token-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-dataset-a-p03-token-capture'}), (a:Assertion {uid: 'hu:assertion:w01-dataset-a-p03-token'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-a-p03'}), (y:Identifier {uid: 'hu:identifier:w01-participant-token-dataset-a-p03'})
MERGE (x)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w01-dataset-a-p03-token'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-dataset-a-p03-token', assertionUid: 'hu:assertion:w01-dataset-a-p03-token', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), isPrimary: true};
MERGE (n:Source:Entity {uid: 'hu:source:w01-synthetic-public-dataset-b'})
SET n += {id: 'w01-synthetic-public-dataset-b', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'urn:synthetic:w01:public-dataset-b', sourceKind: 'PEER_REVIEWED_PUBLICATION', title: 'Synthetic public dataset B'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-synthetic-public-dataset-b'})
SET n += {id: 'w01-synthetic-public-dataset-b', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), captureCompleteness: 'COMPLETE', contentHashBasis: 'SYNTHETIC_FIXTURE', contentHash: 'sha256:bb2874fc8120e322bb344adbba213a984ab6bde8ea031d713963b54cbf3c37f5', fixtureProvenance: 'SYNTHETIC'};
MATCH (s:Source {uid: 'hu:source:w01-synthetic-public-dataset-b'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-public-dataset-b'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:w01-synthetic-dataset-b-p03'})
SET n += {id: 'w01-synthetic-dataset-b-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Participant P03 (dataset B) reported improved sleep latency.', quoteHash: 'sha256:27385bd0d2e49ff10b4c450e9256304ad29766e2324644e562b6915b014400c3', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-synthetic-public-dataset-b'}), (l:SourceLocator {uid: 'hu:locator:w01-synthetic-dataset-b-p03'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:CohortParticipant:PseudonymousActor:Entity {uid: 'hu:cohort-participant:w01-synthetic-dataset-b-p03'})
SET n += {id: 'w01-synthetic-dataset-b-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'CohortParticipant', name: 'Participant P03 of dataset B', participantToken: 'P03', fixtureProvenance: 'SYNTHETIC'};
MERGE (n:Identifier:Entity {uid: 'hu:identifier:w01-participant-token-dataset-b-p03'})
SET n += {id: 'w01-participant-token-dataset-b-p03', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Identifier', scheme: 'PARTICIPANT_TOKEN', issuer: 'hu:source:w01-synthetic-public-dataset-b', value: 'P03'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-dataset-b-p03-token'})
SET a += {id: 'w01-dataset-b-p03-token', predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'IDENTITY', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), fixtureProvenance: 'SYNTHETIC', contentHash: 'sha256:561ed95cee756aa8e28a99967f6d04f12b89927814ce22a25f2a2ea68dba4cad'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-dataset-b-p03-token'}), (s {uid: 'hu:cohort-participant:w01-synthetic-dataset-b-p03'}), (o {uid: 'hu:identifier:w01-participant-token-dataset-b-p03'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:w01-synthetic-dataset-b-p03'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-dataset-b-p03-token-capture'})
SET n += {id: 'w01-dataset-b-p03-token-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-dataset-b-p03-token-capture'}), (a:Assertion {uid: 'hu:assertion:w01-dataset-b-p03-token'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:CohortParticipant {uid: 'hu:cohort-participant:w01-synthetic-dataset-b-p03'}), (y:Identifier {uid: 'hu:identifier:w01-participant-token-dataset-b-p03'})
MERGE (x)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w01-dataset-b-p03-token'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-dataset-b-p03-token', assertionUid: 'hu:assertion:w01-dataset-b-p03-token', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), isPrimary: true};
