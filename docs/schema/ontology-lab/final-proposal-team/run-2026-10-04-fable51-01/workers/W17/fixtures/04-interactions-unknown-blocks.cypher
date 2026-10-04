// W17 fixture 04: supplement-drug interactions with evidence levels; UNKNOWN interaction that must still block;
// measured absence (NEGATIVE) vs no record (QS-7). Sources: AFP 2017 review (Asher et al.), NIH ODS vitamin K. Run after 00.

MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:kava-with-warfarin'})
  ON CREATE SET n.id = 'kava-with-warfarin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'kava preparation with warfarin', n.identityKeyHash = 'sha256:dbc3380cc7fe93397a7b56f5459a9c8fe3505d7103247e9587d4a5c4877f26ca', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:kava-with-warfarin'}), (b:IngredientMaterial {uid: 'hu:material:kava-preparation-unspecified'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:kava-with-warfarin'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:green-tea-extract-with-simvastatin'})
  ON CREATE SET n.id = 'green-tea-extract-with-simvastatin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'green tea extract with simvastatin', n.identityKeyHash = 'sha256:11ed706c3f7ee5b8f35a6daa30d96b7fd6583273cb7f6a7ad7558e14562b87da', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:green-tea-extract-with-simvastatin'}), (b:IngredientMaterial {uid: 'hu:material:green-tea-extract-unspecified'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:green-tea-extract-with-simvastatin'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:st-johns-wort-with-warfarin'})
  ON CREATE SET n.id = 'st-johns-wort-with-warfarin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'St. John\'s wort with warfarin', n.identityKeyHash = 'sha256:f5f93cd55c30558f7602ad3973e744cb76206f7907be58930dc5a6c5474db0e3', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:st-johns-wort-with-warfarin'}), (b:IngredientMaterial {uid: 'hu:material:st-johns-wort-preparation-unspecified'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:st-johns-wort-with-warfarin'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:american-ginseng-with-indinavir'})
  ON CREATE SET n.id = 'american-ginseng-with-indinavir', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'American ginseng with indinavir', n.identityKeyHash = 'sha256:8a7f26684d3152c83d73d7add00b6414b34f8e4f61353cc2a4b187e19d199434', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:american-ginseng-with-indinavir'}), (b:IngredientMaterial {uid: 'hu:material:american-ginseng-preparation-unspecified'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:american-ginseng-with-indinavir'}), (b:ChemicalSubstance {uid: 'hu:substance:indinavir'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:UseConstraint:Entity {uid: 'hu:use-constraint:vitamin-k-with-warfarin'})
  ON CREATE SET n.id = 'vitamin-k-with-warfarin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'USE_CONSTRAINT', n.name = 'vitamin K intake with warfarin', n.identityKeyHash = 'sha256:2e41bf47fcd228e2e97251e404e322259c6c468d0f7d87d7197cbdfcf5353529', n.identityKeyVersion = 'uc-key/v1';
MATCH (a:UseConstraint {uid: 'hu:use-constraint:vitamin-k-with-warfarin'}), (b:ChemicalSubstance {uid: 'hu:substance:vitamin-k'})
MERGE (a)-[r:CONSTRAINS_USE_OF]->(b);
MATCH (a:UseConstraint {uid: 'hu:use-constraint:vitamin-k-with-warfarin'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:CONSTRAINT_SCOPE]->(b)
  ON CREATE SET r.scopeRole = 'CO_EXPOSURE', r.orderIndex = 0;
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'})
  ON CREATE SET n.id = 'w17-afp-kava-warfarin-interaction', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:fee88c844af807d0ad1b90fbd8e2f68a90901d5b0aafc043b247adef75c99ffe', n.polarity = 'UNKNOWN', n.speechAct = 'STATES', n.basisKind = 'CITED_FROM_PRIOR_WORK', n.assertionBasis = 'STUDY_RESULT', n.interactionMechanism = 'CYP2C9_INHIBITION', n.interactionEffect = 'NOT_STATED', n.description = 'two in vitro studies suggest the potential to inhibit CYP2C9 (in vitro setting not specified; not confirmed in humans); warfarin is named in the source\'s list of CYP2C9 substrates', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:IngredientMaterial {uid: 'hu:material:kava-preparation-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-kava'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:AdverseEffect {uid: 'hu:adverse-effect:anticoagulant-effect-altered'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-interaction'}), (b:UseConstraint {uid: 'hu:use-constraint:kava-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-kava-warfarin-interaction'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'})
  ON CREATE SET n.id = 'w17-afp-kava-warfarin-monitor', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:0c1565ef82accfb6c5d07d0ea0067a8a5e61de29efe7db67862970e4771e245e', n.polarity = 'POSITIVE', n.speechAct = 'CAUTIONS', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'MONITOR', n.levelVerbatim = 'should be closely monitored for clinical adverse effects and laboratory abnormalities (e.g., glucose level, A1C level, INR) or instructed not to use kava-containing supplements', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:IngredientMaterial {uid: 'hu:material:kava-preparation-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-kava'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:AdverseEffect {uid: 'hu:adverse-effect:anticoagulant-effect-altered'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-kava-warfarin-monitor'}), (b:UseConstraint {uid: 'hu:use-constraint:kava-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-kava-warfarin-monitor'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'})
  ON CREATE SET n.id = 'w17-afp-green-tea-simvastatin', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:ea74db17e4844abf9ec2810a5e537e2b802d721d341922d33c7c68f035fa712f', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.basisKind = 'CITED_FROM_PRIOR_WORK', n.assertionBasis = 'STUDY_RESULT', n.interactionMechanism = 'NOT_STATED', n.interactionEffect = 'INCREASES_OBJECT_EXPOSURE', n.exposureChangeText = 'has been shown to increase simvastatin (Zocor) concentrations', n.description = 'mechanism hedged by the source (\'may be due to P-gp inhibition\')', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:IngredientMaterial {uid: 'hu:material:green-tea-extract-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:ChemicalSubstance {uid: 'hu:substance:simvastatin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-green-tea'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-green-tea-simvastatin'}), (b:UseConstraint {uid: 'hu:use-constraint:green-tea-extract-with-simvastatin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-green-tea-simvastatin'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'})
  ON CREATE SET n.id = 'w17-afp-sjw-warfarin-interaction', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:942f2d5b51f937e3f88b45c9e226145acd62ea3dd509a9c472373db43eb675f5', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.basisKind = 'DIRECT_MEASUREMENT', n.assertionBasis = 'STUDY_RESULT', n.evidenceSetting = 'HUMAN_INTERVENTIONAL', n.interactionMechanism = 'CYP3A4_INDUCTION', n.interactionEffect = 'DECREASES_OBJECT_EXPOSURE', n.exposureChangeText = 'Clinical studies have shown reductions in ... warfarin', n.reportedEvidenceGrade = 'C', n.reportedEvidenceGradeScheme = 'SORT (AFP): C = consensus, disease-oriented evidence, usual practice, expert opinion, or case series', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:IngredientMaterial {uid: 'hu:material:st-johns-wort-preparation-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-st-johns-wort'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-sort-goldenseal-sjw'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:AdverseEffect {uid: 'hu:adverse-effect:anticoagulant-effect-altered'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-interaction'}), (b:UseConstraint {uid: 'hu:use-constraint:st-johns-wort-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-sjw-warfarin-interaction'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'})
  ON CREATE SET n.id = 'w17-afp-sjw-warfarin-avoid', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1d5b3056ac8ddb19bf01aa73b067d88d2eb393c1315e33a56f34f8cec5feab62', n.polarity = 'POSITIVE', n.speechAct = 'RECOMMENDS', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'AVOID', n.levelVerbatim = 'It is strongly recommended to avoid concurrent use of St. John\'s wort with over-the-counter and prescription medications.', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:IngredientMaterial {uid: 'hu:material:st-johns-wort-preparation-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-st-johns-wort'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-afp-sjw-warfarin-avoid'}), (b:UseConstraint {uid: 'hu:use-constraint:st-johns-wort-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-sjw-warfarin-avoid'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'})
  ON CREATE SET n.id = 'w17-afp-american-ginseng-indinavir', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:a71bd895d12664b6ca3af5798ed7158410a61fe5a3eb5a00990d55119c6ce4a5', n.polarity = 'NEGATIVE', n.speechAct = 'STATES', n.basisKind = 'DIRECT_MEASUREMENT', n.assertionBasis = 'STUDY_RESULT', n.evidenceSetting = 'HUMAN_INTERVENTIONAL', n.interactionMechanism = 'NOT_STATED', n.interactionEffect = 'NOT_STATED', n.description = 'Two human trials demonstrated no effect (a measured absence within those trials)', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:IngredientMaterial {uid: 'hu:material:american-ginseng-preparation-unspecified'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:ChemicalSubstance {uid: 'hu:substance:indinavir'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:Person {uid: 'hu:person:gary-n-asher'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:SourceLocator {uid: 'hu:locator:afp-2017-american-ginseng'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-afp-american-ginseng-indinavir'}), (b:UseConstraint {uid: 'hu:use-constraint:american-ginseng-with-indinavir'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-afp-american-ginseng-indinavir'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:InteractionAssertion:Assertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'})
  ON CREATE SET n.id = 'w17-ods-vitk-warfarin-interaction', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'INTERACTS_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:ea3a93eff7432616e2fbca67ac94191768032b2052ca5c76f7cfca4da4cf885a', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.basisKind = 'CITED_FROM_PRIOR_WORK', n.assertionBasis = 'EXPERT_OPINION', n.interactionMechanism = 'VITAMIN_K_ANTAGONISM', n.interactionEffect = 'ALTERS_OBJECT_EFFECT', n.exposureChangeText = 'sudden changes in vitamin K intakes can increase or decrease the anticoagulant effect', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:ChemicalSubstance {uid: 'hu:substance:vitamin-k'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:Organization {uid: 'hu:org:nih-ods'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:SourceLocator {uid: 'hu:locator:ods-vitk-warfarin'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:AdverseEffect {uid: 'hu:adverse-effect:anticoagulant-effect-altered'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:InteractionAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-interaction'}), (b:UseConstraint {uid: 'hu:use-constraint:vitamin-k-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-ods-vitk-warfarin-interaction'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
MERGE (n:ContraindicationAssertion:Assertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'})
  ON CREATE SET n.id = 'w17-ods-vitk-warfarin-consistent', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'USE_CONSTRAINED_WITH', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:1695eb7e6c3b24af91186415329682970fb93bec984035a7d0c790e3187e9e35', n.polarity = 'POSITIVE', n.speechAct = 'RECOMMENDS', n.assertionBasis = 'EXPERT_OPINION', n.constraintLevel = 'MAINTAIN_CONSISTENT_INTAKE', n.levelVerbatim = 'need to maintain a consistent intake of vitamin K from food and supplements', n.validFromBasis = 'UNKNOWN', n.validToBasis = 'UNKNOWN';
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:ChemicalSubstance {uid: 'hu:substance:vitamin-k'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:ChemicalSubstance {uid: 'hu:substance:warfarin'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:Organization {uid: 'hu:org:nih-ods'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:SourceLocator {uid: 'hu:locator:ods-vitk-warfarin'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:ContraindicationAssertion {uid: 'hu:assertion:w17-ods-vitk-warfarin-consistent'}), (b:UseConstraint {uid: 'hu:use-constraint:vitamin-k-with-warfarin'})
MERGE (a)-[r:RESOLVES_TO_CONSTRAINT]->(b)
  ON CREATE SET r.derivationRule = 'uc-match/v1', r.derivedFromAssertionUids = ['hu:assertion:w17-ods-vitk-warfarin-consistent'], r.derivedAt = datetime('2026-10-04T02:20:00Z');
