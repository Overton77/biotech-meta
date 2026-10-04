// W17 fixture 05: statin pregnancy contraindication removed by the FDA (DSC 2021-07-20). Correction vs validity-bounded:
// the earlier contraindication was not wrong when stated; it ENDED (SUPERSEDES {VALIDITY_BOUNDED}). Late arrival: W17 ingests
// the 2021 change on 2026-10-04. The pre-2021 assertion is SYNTHETIC (its label capture was not retrieved). Run after 00.

MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
  ON CREATE SET n.id = 'statin-therapy-in-pregnancy', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'statin therapy in pregnant patients', n.identityKeyHash = 'sha256:6d584883ede2fbfa83d3274f2822a27d068cdbc7e29eef22e7a96011301013e7', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'}), (b:UseContextProfile {uid: 'hu:use-profile:pregnant-patients'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'POPULATION', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:statin-therapy-while-breastfeeding'})
  ON CREATE SET n.id = 'statin-therapy-while-breastfeeding', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'statin therapy while breastfeeding', n.identityKeyHash = 'sha256:98643699a2648e6b22a6b8aa4fcff77722b696aefea66c737969d46795c78996', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:statin-therapy-while-breastfeeding'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:statin-therapy-while-breastfeeding'}), (b:UseContextProfile {uid: 'hu:use-profile:breastfeeding-patients'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'POPULATION', r.orderIndex = 0;
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'})
  ON CREATE SET n.id = 'w17-synthetic-statin-pregnancy-contraindicated-2020', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2020-06-01T00:00:00Z'), n.contentHash = 'sha256:142a4ae0a1c15ea7eeee0225e2de7c35cde1e4913b316e2fff68c16dd9ccf93b', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'UNSTATED', n.constraintLevel = 'CONTRAINDICATED', n.levelVerbatim = 'SYNTHETIC: contraindicated in pregnancy', n.populationScopeText = 'all pregnant patients', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN', n.description = 'SYNTHETIC stand-in for the class contraindication the 2021 DSC removes';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:UseContextProfile {uid: 'hu:use-profile:pregnant-patients'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:SourceLocator {uid: 'hu:locator:synthetic-w17-statin-pregnancy-contraindication-2020'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:AdverseEffect {uid: 'hu:adverse-effect:embryofetal-toxicity'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'}), (b:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'})
  ON CREATE SET n.id = 'w17-synthetic-statin-pregnancy-contraindicated-2020-bounded', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:10:00Z'), n.contentHash = 'sha256:e7bd7abb0a9357a7e6f8822f87a90cada1e68bdecd05031da01fbc0e35c3ed32', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'UNSTATED', n.constraintLevel = 'CONTRAINDICATED', n.levelVerbatim = 'SYNTHETIC: contraindicated in pregnancy', n.populationScopeText = 'all pregnant patients', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validTo = datetime('2021-07-20T00:00:00Z'), n.validToPrecision = 'DAY', n.validToBasis = 'STATED_BY_SOURCE', n.description = 'same proposition with its validity bounded by the FDA DSC of 2021-07-20 (late-arriving end)';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:UseContextProfile {uid: 'hu:use-profile:pregnant-patients'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:SourceLocator {uid: 'hu:locator:synthetic-w17-statin-pregnancy-contraindication-2020'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:SourceLocator {uid: 'hu:locator:fda-dsc-2021-remove-contraindication'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:AdverseEffect {uid: 'hu:adverse-effect:embryofetal-toxicity'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'})
MERGE (a)-[r:SUPERSEDES]->(b)
  ON CREATE SET r.supersessionKind = 'VALIDITY_BOUNDED', r.recordedAt = datetime('2026-10-04T02:10:00Z');
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020'})
SET a.recordedTo = datetime('2026-10-04T02:10:00Z'), a.status = 'SUPERSEDED';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'}), (b:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-synthetic-statin-pregnancy-contraindicated-2020-bounded'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'})
  ON CREATE SET n.id = 'w17-fda-dsc-2021-pregnancy-contraindication-removed', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1f0616cbc5ff2b8766229e642f75c512d978a2085bb9480a4ad80a886698fe49', n.polarity = 'NEGATIVE', n.speechAct = 'STATES', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'CONTRAINDICATED', n.levelVerbatim = 'removing the contraindication against using these medicines in all pregnant patients', n.populationScopeText = 'all pregnant patients', n.scopeExceptionText = 'a small group of very high-risk pregnant patients', n.jurisdiction = 'US', n.validFrom = datetime('2021-07-20T00:00:00Z'), n.validFromPrecision = 'DAY', n.validFromBasis = 'STATED_BY_SOURCE', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:UseContextProfile {uid: 'hu:use-profile:pregnant-patients'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:SourceLocator {uid: 'hu:locator:fda-dsc-2021-remove-contraindication'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:SourceLocator {uid: 'hu:locator:fda-dsc-2021-high-risk-exception'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'}), (b:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-fda-dsc-2021-pregnancy-contraindication-removed'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'})
  ON CREATE SET n.id = 'w17-fda-dsc-2021-pregnancy-stop', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:8160178177b9eb4607ac261dc139d4bd87ed46f28b931b171c05e70506f8c389', n.polarity = 'POSITIVE', n.speechAct = 'RECOMMENDS', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'AVOID', n.levelVerbatim = 'most patients should stop statins once they learn they are pregnant', n.populationScopeText = 'most pregnant patients', n.jurisdiction = 'US', n.validFrom = datetime('2021-07-20T00:00:00Z'), n.validFromPrecision = 'DAY', n.validFromBasis = 'STATED_BY_SOURCE', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:UseContextProfile {uid: 'hu:use-profile:pregnant-patients'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:SourceLocator {uid: 'hu:locator:fda-dsc-2021-stop-when-pregnant'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-pregnancy-stop'}), (b:UseConstraint {uid: 'hu:use-constraint:statin-therapy-in-pregnancy'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-fda-dsc-2021-pregnancy-stop'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'})
  ON CREATE SET n.id = 'w17-fda-dsc-2021-breastfeeding-avoid', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:342d08a61ff091d3e500205e17106e014b334d73957c1f4b3684e3be7e5ff5a5', n.polarity = 'POSITIVE', n.speechAct = 'RECOMMENDS', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'AVOID', n.levelVerbatim = 'Patients should not breastfeed when taking a statin', n.jurisdiction = 'US', n.validFrom = datetime('2021-07-20T00:00:00Z'), n.validFromPrecision = 'DAY', n.validFromBasis = 'STATED_BY_SOURCE', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:Treatment {uid: 'hu:treatment:statin-therapy'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:UseContextProfile {uid: 'hu:use-profile:breastfeeding-patients'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:SourceLocator {uid: 'hu:locator:fda-dsc-2021-breastfeeding'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'}), (b:UseConstraint {uid: 'hu:use-constraint:statin-therapy-while-breastfeeding'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-fda-dsc-2021-breastfeeding-avoid'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
