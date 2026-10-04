// W23 constraint violation tests (run after operations.cypher and fixtures/00-shared-base.cypher on a disposable DB).
// Expected outcome per statement is in the comment; "ERROR" means the database must reject the write.

// T-1 duplicate (policyKey, versionLabel): ERROR (policy_version_key_label)
CREATE (:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-test-dup-label', id: 'w23-test-dup-label', stateType: 'POLICY_VERSION',
  policyKey: 'answer-use-authorization', versionLabel: 'v1', policyKind: 'USE_AUTHORIZATION', payloadHash: 'sha256:test', privacyClass: 'INTERNAL', createdAt: datetime()});

// T-2 missing versionLabel: ACCEPTED on Community (uniqueness does not require presence) -> caught by V-W23-08
CREATE (:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-test-missing-label', id: 'w23-test-missing-label', stateType: 'POLICY_VERSION',
  policyKey: 'answer-use-authorization', policyKind: 'USE_AUTHORIZATION', payloadHash: 'sha256:test', privacyClass: 'INTERNAL', createdAt: datetime()});

// T-3 duplicate (criterionKey, methodVersion): ERROR (decision_criterion_key_method)
CREATE (:DecisionCriterion:Entity {uid: 'hu:decision-criterion:w23-test-dup', id: 'w23-test-dup', entityType: 'DECISION_CRITERION',
  criterionKey: 'SAFETY_BLOCK', criterionKind: 'SAFETY_BLOCK', methodVersion: 'safety-block-0.1', privacyClass: 'INTERNAL', createdAt: datetime()});

// T-4 duplicate live id on AnswerRecord: ERROR (answer_record_id)
CREATE (:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-test-other-uid', id: 'w23-ar1', occurrenceType: 'ANSWER_PUBLICATION',
  recordedAsOf: datetime('2026-04-10T09:00:00Z'), schemaDigest: 'sha256:x', queryShapeId: 'QS-1a', accessTier: 'PUBLIC_ANSWER',
  privateContext: 'EXCLUDED', privacyClass: 'INTERNAL', createdAt: datetime()});

// T-5 duplicate uid across archetypes (AnswerRecord uid reused on another Occurrence): ERROR (occurrence_uid)
CREATE (:Activity:Occurrence {uid: 'hu:answer-record:w23-ar1', id: 'w23-ar1-clash', occurrenceType: 'ACTIVITY', createdAt: datetime()});

// T-6 wrong type: recordedAsOf stored as a string: ACCEPTED on Community (type constraints are Enterprise) -> service rejects
CREATE (:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-test-string-time', id: 'w23-test-string-time', occurrenceType: 'ANSWER_PUBLICATION',
  recordedAsOf: '2026-04-10', schemaDigest: 'sha256:x', queryShapeId: 'QS-1a', accessTier: 'PUBLIC_ANSWER', privateContext: 'EXCLUDED',
  privacyClass: 'INTERNAL', createdAt: datetime()});

// T-7 wrong enum value: accessTier 'PUBLIC' (not an AccessTier name): ACCEPTED by the database -> V-W23-01a reports it
CREATE (:AnswerRecord:Occurrence {uid: 'hu:answer-record:w23-test-bad-enum', id: 'w23-test-bad-enum', occurrenceType: 'ANSWER_PUBLICATION',
  recordedAsOf: datetime('2026-04-10T09:00:00Z'), schemaDigest: 'sha256:x', queryShapeId: 'QS-1a', accessTier: 'PUBLIC', privateContext: 'EXCLUDED',
  privacyClass: 'INTERNAL', createdAt: datetime()});

// T-8 cleanup of the accepted test nodes
MATCH (n) WHERE n.uid IN ['hu:policy-version:w23-test-missing-label', 'hu:answer-record:w23-test-string-time', 'hu:answer-record:w23-test-bad-enum'] DETACH DELETE n;
