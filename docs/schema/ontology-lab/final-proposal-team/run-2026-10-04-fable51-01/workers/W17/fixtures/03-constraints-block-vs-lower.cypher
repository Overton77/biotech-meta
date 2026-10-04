// W17 fixture 03: ZOCOR (simvastatin) label directives and interactions -> UseConstraints. Block vs lower is a
// private-policy outcome; the shared graph keeps levels, scopes and dose bands distinct (CQ-RC-06). Run after 00.

MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-with-gemfibrozil'})
  ON CREATE SET n.id = 'simvastatin-with-gemfibrozil', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin with gemfibrozil', n.identityKeyHash = 'sha256:2f397fd9592cfa4b63e61a1a1b55575415b55c0914dd44ca49c5fa8838fba212', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-gemfibrozil'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-gemfibrozil'}), (b:ChemicalSubstance {uid: 'hu:substance:gemfibrozil'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-in-acute-liver-failure'})
  ON CREATE SET n.id = 'simvastatin-in-acute-liver-failure', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin in acute liver failure', n.identityKeyHash = 'sha256:5b813076fd847ba6450ef6e5e99fae00e9a30ceb263931148360a66d16ac724f', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-in-acute-liver-failure'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-in-acute-liver-failure'}), (b:Condition {uid: 'hu:condition:acute-liver-failure'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CONDITION_PRESENT', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-above-10mg-with-verapamil'})
  ON CREATE SET n.id = 'simvastatin-above-10mg-with-verapamil', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin above 10 mg/day with verapamil', n.identityKeyHash = 'sha256:694f217668607589064641596ecba81f7250cfaa25b80d3149f44ef792c88526', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US', n.doseComparator = 'GT', n.doseValue = 10.0, n.doseUnitCode = 'mg', n.doseQuantityBasis = 'PER_DAY', n.doseMassBasis = 'UNSPECIFIED';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-above-10mg-with-verapamil'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-above-10mg-with-verapamil'}), (b:ChemicalSubstance {uid: 'hu:substance:verapamil'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-with-niacin-1g'})
  ON CREATE SET n.id = 'simvastatin-with-niacin-1g', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin with niacin at >= 1 g/day', n.identityKeyHash = 'sha256:20a4bee8e2695ce2941bc6c1aba5831f1bfa5164357959679181cc8278bde4f3', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0, r.doseComparator = 'GTE', r.doseValue = 1.0, r.doseUnitCode = 'g', r.doseQuantityBasis = 'PER_DAY', r.doseMassBasis = 'UNSPECIFIED';
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-chinese'})
  ON CREATE SET n.id = 'simvastatin-with-niacin-1g-chinese', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin with niacin at >= 1 g/day in patients of Chinese descent', n.identityKeyHash = 'sha256:0354882a06e867fe0b97e7db22bd881a8a57676ef5e313e7afc9b2ef49217361', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0, r.doseComparator = 'GTE', r.doseValue = 1.0, r.doseUnitCode = 'g', r.doseQuantityBasis = 'PER_DAY', r.doseMassBasis = 'UNSPECIFIED';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-chinese'}), (b:UseContextProfile {uid: 'hu:use-profile:patients-of-chinese-descent'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'POPULATION', r.orderIndex = 1;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-non-chinese'})
  ON CREATE SET n.id = 'simvastatin-with-niacin-1g-non-chinese', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin with niacin at >= 1 g/day in non-Chinese patients', n.identityKeyHash = 'sha256:7d329ac82e85a3d0b14ac79dfd75d5c25aad1f4a8b6537ddfcbb675e82018235', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-non-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-non-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0, r.doseComparator = 'GTE', r.doseValue = 1.0, r.doseUnitCode = 'g', r.doseQuantityBasis = 'PER_DAY', r.doseMassBasis = 'UNSPECIFIED';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-non-chinese'}), (b:UseContextProfile {uid: 'hu:use-profile:non-chinese-patients'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'POPULATION', r.orderIndex = 1;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:simvastatin-with-grapefruit-juice'})
  ON CREATE SET n.id = 'simvastatin-with-grapefruit-juice', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'simvastatin with grapefruit juice', n.identityKeyHash = 'sha256:4b5a927445c4a106841ecd97904534c9c67dd6f5ef60dfda254e3f5597a3195f', n.identityKeyVersion = 'uc-key/v1', n.jurisdiction = 'US';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-grapefruit-juice'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-grapefruit-juice'}), (b:IngredientMaterial {uid: 'hu:material:grapefruit-juice'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'})
  ON CREATE SET n.id = 'w17-zocor-ci-gemfibrozil', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:52efb1f336d850a253d7042c1549a8971ba0ed1364f9ecac99a3973d28d552f5', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'CONTRAINDICATED', n.levelVerbatim = 'Concomitant use of cyclosporine, danazol or gemfibrozil (CONTRAINDICATIONS)', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'}), (b:ChemicalSubstance {uid: 'hu:substance:gemfibrozil'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'}), (b:SourceLocator {uid: 'hu:locator:zocor-4-gemfibrozil'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-gemfibrozil'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-gemfibrozil'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-ci-gemfibrozil'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'})
  ON CREATE SET n.id = 'w17-zocor-ci-acute-liver-failure', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_IN', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1505ea91bba6dc4d083ac140c1da993107134ed8d89a8aa9ebf6be522e1df2cc', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'CONTRAINDICATED', n.levelVerbatim = 'Acute liver failure or decompensated cirrhosis (CONTRAINDICATIONS)', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'}), (b:Condition {uid: 'hu:condition:acute-liver-failure'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'}), (b:SourceLocator {uid: 'hu:locator:zocor-4-liver'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-ci-acute-liver-failure'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-in-acute-liver-failure'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-ci-acute-liver-failure'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'})
  ON CREATE SET n.id = 'w17-zocor-dose-verapamil', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:633262be7bb6acfc9106d345c835ba9032305ab732998debfff8128080b801a0', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'DO_NOT_EXCEED_DOSE', n.levelVerbatim = 'Do not exceed ZOCOR 10 mg once daily.', n.doseComparator = 'GT', n.doseValue = 10.0, n.doseUnitCode = 'mg', n.doseQuantityBasis = 'PER_DAY', n.doseMassBasis = 'UNSPECIFIED', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:ChemicalSubstance {uid: 'hu:substance:verapamil'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:SourceLocator {uid: 'hu:locator:zocor-2-5-verapamil'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-ccb-intervention'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-dose-verapamil'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-above-10mg-with-verapamil'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-dose-verapamil'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'})
  ON CREATE SET n.id = 'w17-zocor-niacin-chinese', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:5a300c64b2298baa3c316eaac72ebc425d014343502f53302bad9a537c9cf4f4', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'NOT_RECOMMENDED', n.levelVerbatim = 'is not recommended in Chinese patients', n.populationScopeText = 'Chinese patients', n.coExposureDoseText = 'lipid-modifying dosages of niacin (≥1 gram/day niacin)', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-niacin-intervention'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-chinese'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-chinese'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-niacin-chinese'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'})
  ON CREATE SET n.id = 'w17-zocor-niacin-non-chinese', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1957455fc1ea1076931984b44d738cb6f8be2eeac3ad6e568170ffbbfd5e9bec', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'USE_WITH_CAUTION', n.levelVerbatim = 'consider if the benefit of using lipid-modifying doses of niacin concomitantly with ZOCOR outweighs the increased risk of myopathy and rhabdomyolysis', n.populationScopeText = 'non-Chinese patients', n.coExposureDoseText = 'lipid-modifying doses of niacin', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-niacin-intervention'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-niacin-non-chinese'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g-non-chinese'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-niacin-non-chinese'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'})
  ON CREATE SET n.id = 'w17-zocor-avoid-grapefruit', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1bdacf43a5af2c48052c02dcd15214e42a1188db5f714e388a10013c54271265', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'MANUFACTURER_CLAIM', n.constraintLevel = 'AVOID', n.levelVerbatim = 'Avoid grapefruit juice when taking ZOCOR.', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:IngredientMaterial {uid: 'hu:material:grapefruit-juice'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-grapefruit'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-zocor-avoid-grapefruit'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-grapefruit-juice'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-avoid-grapefruit'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'})
  ON CREATE SET n.id = 'w17-zocor-ia-grapefruit', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:9073fb09fae0057e369a24b515eb55e9514ec42f96b9982cda6bc01d1b8113ee', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.basisKind = 'CITED_FROM_PRIOR_WORK', n.assertionBasis = 'MANUFACTURER_CLAIM', n.interactionMechanism = 'NOT_STATED', n.interactionEffect = 'INCREASES_OBJECT_EXPOSURE', n.exposureChangeText = 'can raise the plasma levels of simvastatin', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:IngredientMaterial {uid: 'hu:material:grapefruit-juice'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-grapefruit'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-grapefruit'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-grapefruit-juice'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-ia-grapefruit'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-zocor-ia-niacin'})
  ON CREATE SET n.id = 'w17-zocor-ia-niacin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:bf8769bbb5a9a2144077ad6cf9344af4cab3a881d5feb15ae9668d60004aaa02', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.basisKind = 'CITED_FROM_PRIOR_WORK', n.assertionBasis = 'MANUFACTURER_CLAIM', n.interactionMechanism = 'PHARMACODYNAMIC_ADDITIVE', n.interactionEffect = 'INCREASES_ADVERSE_EFFECT_RISK', n.subjectDoseText = 'lipid modifying dosages of niacin-containing products (≥1 gram/day niacin)', n.populationScopeText = 'The risk of myopathy is greater in Chinese patients.', n.jurisdiction = 'US', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:SourceLocator {uid: 'hu:locator:zocor-7-niacin-impact'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:AdverseEffect {uid: 'hu:adverse-effect:rhabdomyolysis'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-zocor-ia-niacin'}), (b:UseConstraint {uid: 'hu:use-constraint:simvastatin-with-niacin-1g'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-zocor-ia-niacin'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
