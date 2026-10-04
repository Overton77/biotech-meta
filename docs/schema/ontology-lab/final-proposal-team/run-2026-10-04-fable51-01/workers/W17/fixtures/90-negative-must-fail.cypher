// W17 fixture 90: MUST-FAIL cases. Each block names the validator that must report it (06-fixtures-and-queries.md).
// Load into a database that already holds fixtures 00-05; every uid is prefixed 'neg-'.

MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:neg-w17-n1-hint-as-verdict'})
  ON CREATE SET n.id = 'neg-w17-n1-hint-as-verdict', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.assessmentType = 'SafetySignal', n.methodVersion = 'live-migration/0', n.status = 'ACCEPTED', n.recordedAt = datetime('2026-10-04T03:00:00Z'), n.signalStatus = 'CONFIRMED_ASSOCIATION', n.legacyEvidenceStrengthHint = 'HIGH', n.name = 'N1 legacy hint read as confirmed';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'}), (b:SafetySignal {uid: 'hu:safety-signal:neg-w17-n1-hint-as-verdict'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n1-s', r.subjectRole = 'PRIMARY';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:neg-w17-n1-hint-as-verdict'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:neg-w17-n2-zero-no-method'})
  ON CREATE SET n.id = 'neg-w17-n2-zero-no-method', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.artifactType = 'AdverseEventResult', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Serious adverse event', n.seriousness = 'SERIOUS', n.participantsAffected = 0, n.eventCount = 0;
MATCH (a:AdverseEventResult {uid: 'hu:study-result:neg-w17-n2-zero-no-method'}), (b:StudyArm {uid: 'hu:arm:synthetic-w17-systematic-active'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MERGE (n:StudyArm:VersionedState {uid: 'hu:arm:neg-w17-n3-arm'})
  ON CREATE SET n.id = 'neg-w17-n3-arm', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.stateType = 'StudyArm', n.payloadHash = 'sha256:04a38a0aa9d3e9cf087b96803ca41be9fc226b5f95a15c8baf7c2cb05564d607', n.name = 'N3 arm';
MATCH (a:Study {uid: 'hu:study:synthetic-w17-no-ae-report'}), (b:StudyArm {uid: 'hu:arm:neg-w17-n3-arm'})
MERGE (a)-[r:HAS_ARM]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:neg-w17-n3-fabricated-zero'})
  ON CREATE SET n.id = 'neg-w17-n3-fabricated-zero', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.artifactType = 'AdverseEventResult', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Any adverse event', n.seriousness = 'ANY', n.participantsAffected = 0, n.eventCount = 0, n.collectionMethod = 'NOT_DESCRIBED', n.collectionMethodText = 'no AE section in the publication (fabricated zero)';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:neg-w17-n3-fabricated-zero'}), (b:StudyArm {uid: 'hu:arm:neg-w17-n3-arm'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MATCH (a:IngredientMaterial {uid: 'hu:material:grapefruit-juice'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n4', r.subjectRole = 'CO_EXPOSURE', r.assertionUid = 'hu:assertion:w17-zocor-ia-grapefruit', r.recordedFrom = datetime('2026-10-04T03:00:00Z');
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:neg-w17-n5-nr-with-simvastatin'})
  ON CREATE SET n.id = 'neg-w17-n5-nr-with-simvastatin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.entityType = 'USE_CONSTRAINT', n.name = 'N5 NR with simvastatin (wrong transfer)', n.identityKeyHash = 'sha256:63dcabb3fd9fac6350e8c62fd5af49ed586da0aa319f8ee1f49adc58c1b43154', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:neg-w17-n5-nr-with-simvastatin'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:neg-w17-n5-nr-with-simvastatin'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:UseConstraint {uid: 'hu:use-constraint:neg-w17-n5-nr-with-simvastatin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-ia-niacin'];
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:neg-w17-n6-no-record-as-negative'})
  ON CREATE SET n.id = 'neg-w17-n6-no-record-as-negative', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.predicate = 'INTERACTS_WITH', n.predicateClass = 'OTHER', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:e4a661b57e49f403d7b6299e6ab37daca1921cebaea84f4af9a9f2603a951736', n.polarity = 'NEGATIVE', n.speechAct = 'STATES', n.basisKind = 'HYPOTHESIS', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN', n.description = 'N6: written because no interaction record was found';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:neg-w17-n6-no-record-as-negative'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:neg-w17-n6-no-record-as-negative'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:neg-w17-n7-dose-limit-without-dose'})
  ON CREATE SET n.id = 'neg-w17-n7-dose-limit-without-dose', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.predicate = 'USE_CONSTRAINED_WITH', n.predicateClass = 'OTHER', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:e6fb7b7a03b6190d8e8cac02792aff939612502971ca3c05bef39b447645bda8', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.constraintLevel = 'DO_NOT_EXCEED_DOSE', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN', n.levelVerbatim = 'Do not exceed ZOCOR 20 mg once daily.';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:neg-w17-n7-dose-limit-without-dose'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:neg-w17-n7-dose-limit-without-dose'}), (b:ChemicalSubstance {uid: 'hu:substance:verapamil'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:neg-w17-n7-dose-limit-without-dose'}), (b:SourceLocator {uid: 'hu:locator:zocor-2-5-verapamil'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:neg-w17-n8-two-primaries'})
  ON CREATE SET n.id = 'neg-w17-n8-two-primaries', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.assessmentType = 'SafetySignal', n.methodVersion = 'bl-safety-signal/0.1', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T03:00:00Z'), n.signalStatus = 'POTENTIAL';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:simvastatin'}), (b:SafetySignal {uid: 'hu:safety-signal:neg-w17-n8-two-primaries'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n8-0', r.subjectRole = 'PRIMARY';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:verapamil'}), (b:SafetySignal {uid: 'hu:safety-signal:neg-w17-n8-two-primaries'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n8-1', r.subjectRole = 'PRIMARY';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:neg-w17-n8-two-primaries'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:gemfibrozil'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-legacy-live-row-0001'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n9', r.subjectRole = 'CO_EXPOSURE', r.evidenceStrength = 'HIGH', r.confidence = 0.9;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:neg-w17-n10-personal'})
  ON CREATE SET n.id = 'neg-w17-n10-personal', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.entityType = 'USE_CONSTRAINT', n.identityKeyHash = 'sha256:017778aac3cd2db41f111dfce4ee3cd22a453de26fc01f21c9a6f3b5b459f0d2', n.identityKeyVersion = 'uc-key/v1', n.name = 'N10 constraint created for one person\'s declared medication', n.declaredByContextUid = 'hu:private-user-context-version:neg-0001';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:neg-w17-n10-personal'}), (b:IngredientMaterial {uid: 'hu:material:kava-preparation-unspecified'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:neg-w17-n11-serious-severity'})
  ON CREATE SET n.id = 'neg-w17-n11-serious-severity', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.assessmentType = 'SafetySignal', n.methodVersion = 'bl-safety-signal/0.2', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T03:00:00Z'), n.signalStatus = 'POTENTIAL', n.severity = 'SERIOUS';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:simvastatin'}), (b:SafetySignal {uid: 'hu:safety-signal:neg-w17-n11-serious-severity'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:neg-w17-n11', r.subjectRole = 'PRIMARY';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:neg-w17-n11-serious-severity'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:neg-w17-n11-serious-severity'}), (b:Assertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'NOT_APPLICABLE';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-legacy-live-row-0001'}), (b:Organ {uid: 'hu:anatomical-context:skeletal-muscle'})
MERGE (a)-[r:AFFECTS_ORGAN]->(b);
MERGE (n:AdverseEffect:Condition:Entity {uid: 'hu:adverse-effect:neg-w17-n13-rhabdo-merged'})
  ON CREATE SET n.id = 'neg-w17-n13-rhabdo-merged', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.entityType = 'ADVERSE_EFFECT', n.name = 'rhabdomyolysis';
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:neg-w17-n14-in-substance-no-level'})
  ON CREATE SET n.id = 'neg-w17-n14-in-substance-no-level', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.predicate = 'USE_CONSTRAINED_IN', n.predicateClass = 'OTHER', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:0ec67a9b1acf1d76d9d3ee300e352679cc0d0a02e57c2fdb54881c956184a34c', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:neg-w17-n14-in-substance-no-level'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:neg-w17-n14-in-substance-no-level'}), (b:ChemicalSubstance {uid: 'hu:substance:verapamil'})
MERGE (a)-[r:HAS_OBJECT]->(b);
