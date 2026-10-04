// W17 fixture 01: reported zero with collection method vs no AE report (notReported) vs systematically collected zero
// (measured absence within one study). Basis/NRPT rows reuse W09 uids (MERGE-compatible with W09 fixture 05). Run after 00.

MERGE (n:Study:Entity {uid: 'hu:study:nct02678611-basis-nrpt'})
  ON CREATE SET n.id = 'nct02678611-basis-nrpt', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'Study', n.name = 'NCT02678611 Basis/NRPT safety study', n.studyKind = 'INTERVENTIONAL_RANDOMIZED';
MERGE (n:StudyArm:VersionedState {uid: 'hu:arm:nct02678611-placebo'})
  ON CREATE SET n.id = 'nct02678611-placebo', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.stateType = 'StudyArm', n.payloadHash = 'sha256:fdfa55a353bc2fd99dcc33c28d27b39c3b2656249e11884f38e62e657e9414e2', n.name = 'Placebo', n.armType = 'PLACEBO_COMPARATOR';
MATCH (a:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (b:StudyArm {uid: 'hu:arm:nct02678611-placebo'})
MERGE (a)-[r:HAS_ARM]->(b);
MERGE (n:StudyArm:VersionedState {uid: 'hu:arm:nct02678611-nrpt-1x'})
  ON CREATE SET n.id = 'nct02678611-nrpt-1x', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.stateType = 'StudyArm', n.payloadHash = 'sha256:b3e68bc43219f718652bf0f0b98dfc174ff31a804132e50d2259bd36c4f1c4c5', n.name = 'NRPT 1X', n.armType = 'EXPERIMENTAL';
MATCH (a:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (b:StudyArm {uid: 'hu:arm:nct02678611-nrpt-1x'})
MERGE (a)-[r:HAS_ARM]->(b);
MERGE (n:StudyArm:VersionedState {uid: 'hu:arm:nct02678611-nrpt-2x'})
  ON CREATE SET n.id = 'nct02678611-nrpt-2x', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.stateType = 'StudyArm', n.payloadHash = 'sha256:01b6c6891240089d8d1d4a4c861f8ba74eb042095a1db1deb26082f474aa1b43', n.name = 'NRPT 2X', n.armType = 'EXPERIMENTAL';
MATCH (a:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (b:StudyArm {uid: 'hu:arm:nct02678611-nrpt-2x'})
MERGE (a)-[r:HAS_ARM]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct02678611-ae-serious-nrpt-2x'})
  ON CREATE SET n.id = 'nct02678611-ae-serious-nrpt-2x', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.artifactType = 'AdverseEventResult', n.resultKind = 'ADVERSE_EVENT_COUNT', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Serious adverse event', n.seriousness = 'SERIOUS', n.participantsAffected = 0, n.eventCount = 0, n.participantsAtRisk = 38, n.collectionMethod = 'NOT_DESCRIBED', n.collectionMethodText = 'self-reported AEs', n.relatednessAssessor = 'NOT_REPORTED', n.timeFrameText = '8 weeks';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-serious-nrpt-2x'}), (b:StudyArm {uid: 'hu:arm:nct02678611-nrpt-2x'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-serious-nrpt-2x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-results-adverse-events'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-serious-nrpt-2x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-methods-safety-parameters'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct02678611-ae-related-placebo'})
  ON CREATE SET n.id = 'nct02678611-ae-related-placebo', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.artifactType = 'AdverseEventResult', n.resultKind = 'ADVERSE_EVENT_COUNT', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Adverse event assessed as possibly or probably related to the product', n.seriousness = 'ANY', n.participantsAffected = 1, n.eventCount = 1, n.participantsAtRisk = 40, n.collectionMethod = 'NOT_DESCRIBED', n.collectionMethodText = 'self-reported AEs', n.relatednessAssessor = 'NOT_REPORTED', n.timeFrameText = '8 weeks';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-placebo'}), (b:StudyArm {uid: 'hu:arm:nct02678611-placebo'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-placebo'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-results-related-aes'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-placebo'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-methods-safety-parameters'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct02678611-ae-related-nrpt-1x'})
  ON CREATE SET n.id = 'nct02678611-ae-related-nrpt-1x', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.artifactType = 'AdverseEventResult', n.resultKind = 'ADVERSE_EVENT_COUNT', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Adverse event assessed as possibly or probably related to the product', n.seriousness = 'ANY', n.participantsAffected = 1, n.eventCount = 1, n.participantsAtRisk = 40, n.collectionMethod = 'NOT_DESCRIBED', n.collectionMethodText = 'self-reported AEs', n.relatednessAssessor = 'NOT_REPORTED', n.timeFrameText = '8 weeks';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-1x'}), (b:StudyArm {uid: 'hu:arm:nct02678611-nrpt-1x'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-1x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-results-related-aes'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-1x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-methods-safety-parameters'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'})
  ON CREATE SET n.id = 'nct02678611-ae-related-nrpt-2x', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.artifactType = 'AdverseEventResult', n.resultKind = 'ADVERSE_EVENT_COUNT', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Adverse event assessed as possibly or probably related to the product', n.seriousness = 'ANY', n.participantsAffected = 5, n.eventCount = 5, n.participantsAtRisk = 38, n.collectionMethod = 'NOT_DESCRIBED', n.collectionMethodText = 'self-reported AEs', n.relatednessAssessor = 'NOT_REPORTED', n.timeFrameText = '8 weeks';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'}), (b:StudyArm {uid: 'hu:arm:nct02678611-nrpt-2x'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-results-related-aes'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'}), (b:SourceLocator {uid: 'hu:locator:pmc5701244-methods-safety-parameters'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:Study:Entity {uid: 'hu:study:synthetic-w17-systematic-checklist'})
  ON CREATE SET n.id = 'synthetic-w17-systematic-checklist', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'Study', n.name = 'SYNTHETIC: NR 1 g/day 12-week trial with a structured GI symptom checklist at every visit', n.studyKind = 'INTERVENTIONAL_RANDOMIZED';
MERGE (n:StudyArm:VersionedState {uid: 'hu:arm:synthetic-w17-systematic-active'})
  ON CREATE SET n.id = 'synthetic-w17-systematic-active', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.stateType = 'StudyArm', n.payloadHash = 'sha256:6b7c203a0a691ceee862bff677bef2026898b103bbad2beb7f3fb3a06f68db01', n.name = 'Active', n.armType = 'EXPERIMENTAL';
MATCH (a:Study {uid: 'hu:study:synthetic-w17-systematic-checklist'}), (b:StudyArm {uid: 'hu:arm:synthetic-w17-systematic-active'})
MERGE (a)-[r:HAS_ARM]->(b);
MERGE (n:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:synthetic-w17-systematic-gi-zero'})
  ON CREATE SET n.id = 'synthetic-w17-systematic-gi-zero', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.artifactType = 'AdverseEventResult', n.resultKind = 'ADVERSE_EVENT_COUNT', n.analysisKind = 'SAFETY', n.comparisonKind = 'ARM_DESCRIPTIVE', n.statisticalConclusion = 'NOT_TESTED', n.eventTerm = 'Gastrointestinal adverse event', n.seriousness = 'ANY', n.participantsAffected = 0, n.eventCount = 0, n.participantsAtRisk = 30, n.collectionMethod = 'SYSTEMATIC', n.collectionMethodText = 'SYNTHETIC: structured GI symptom checklist administered at every scheduled visit', n.relatednessAssessor = 'INVESTIGATOR', n.timeFrameText = '8 weeks';
MATCH (a:AdverseEventResult {uid: 'hu:study-result:synthetic-w17-systematic-gi-zero'}), (b:StudyArm {uid: 'hu:arm:synthetic-w17-systematic-active'})
MERGE (a)-[r:RESULT_FOR_ARM]->(b)
  ON CREATE SET r.armRole = 'INTERVENTION';
MERGE (n:Study:Entity {uid: 'hu:study:synthetic-w17-no-ae-report'})
  ON CREATE SET n.id = 'synthetic-w17-no-ae-report', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.entityType = 'Study', n.name = 'SYNTHETIC: NR open-label study whose publication has no adverse-event section', n.studyKind = 'INTERVENTIONAL_SINGLE_ARM';
