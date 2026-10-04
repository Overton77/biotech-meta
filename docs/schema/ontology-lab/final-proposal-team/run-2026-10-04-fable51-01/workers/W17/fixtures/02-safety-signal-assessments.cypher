// W17 fixture 02: SafetySignal as an EvidenceAssessment. v1 cites two AdverseEventResults (+ a NOT_REPORTED study);
// v2 re-evaluates with a new method version and supersedes v1; two FDA AEMS imports (closed-no-action vs confirmed);
// one migrated live row whose evidenceStrength 'HIGH' stays a hint (NOT_EVALUATED). Run after 00 and 01.

MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'})
  ON CREATE SET n.id = 'w17-nrpt-gi-tolerability-v1', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.assessmentType = 'SafetySignal', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:30:00Z'), n.methodVersion = 'bl-safety-signal/0.1', n.signalStatus = 'POTENTIAL', n.signalType = 'DOSE_RELATED_TOLERABILITY', n.severity = 'MODERATE', n.evidenceCutoff = datetime('2026-10-04T02:25:00Z'), n.name = 'NRPT 2X related GI/tolerability AEs (v1)', n.summary = '5 possibly/probably related AEs in 5/38 NRPT 2X participants vs 1/40 placebo; self-reported, collection method not described; one NR study considered had no AE report (not counted as zero).';
MATCH (a:IngredientMaterial {uid: 'hu:material:nct02678611-nrpt-as-supplied'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:w17-nrpt-gi-tolerability-v1-subject-0', r.subjectRole = 'PRIMARY', r.orderIndex = 0, r.doseText = 'NRPT 2X: 500 mg NR + 100 mg PT daily (4 capsules)', r.route = 'oral', r.frequency = 'daily, 8 weeks', r.populationSubset = 'healthy adults 60-80 years';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'}), (b:AdverseEffect {uid: 'hu:adverse-effect:gastrointestinal-intolerance'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'INDEX_ARM', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-placebo'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'COMPARATOR_ARM', r.orderIndex = 1;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'}), (b:Study {uid: 'hu:study:synthetic-w17-no-ae-report'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'NOT_REPORTED', r.inputRole = 'NOT_REPORTED_STUDY', r.orderIndex = 2;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'}), (b:Activity {uid: 'hu:activity:w17-signal-run-001'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'})
  ON CREATE SET n.id = 'w17-nrpt-gi-tolerability-v2', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.assessmentType = 'SafetySignal', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:40:00Z'), n.methodVersion = 'bl-safety-signal/0.2', n.signalStatus = 'INSUFFICIENT_DATA', n.signalType = 'DOSE_RELATED_TOLERABILITY', n.severity = 'MODERATE', n.evidenceCutoff = datetime('2026-10-04T02:35:00Z'), n.name = 'NRPT related GI/tolerability AEs (v2)', n.summary = 'v0.2 adds the 1X arm and a systematically collected zero from another NR trial; counts are too small and collection differs; INSUFFICIENT_DATA.';
MATCH (a:IngredientMaterial {uid: 'hu:material:nct02678611-nrpt-as-supplied'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:w17-nrpt-gi-tolerability-v2-subject-0', r.subjectRole = 'PRIMARY', r.orderIndex = 0, r.doseText = 'NRPT 1X and 2X: 250-500 mg NR + 50-100 mg PT daily', r.route = 'oral';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:AdverseEffect {uid: 'hu:adverse-effect:gastrointestinal-intolerance'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-2x'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'INDEX_ARM', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-nrpt-1x'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'INDEX_ARM', r.orderIndex = 1;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:StudyResult {uid: 'hu:study-result:nct02678611-ae-related-placebo'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'COMPARATOR_ARM', r.orderIndex = 2;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:StudyResult {uid: 'hu:study-result:synthetic-w17-systematic-gi-zero'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'INDEX_ARM', r.orderIndex = 3;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:Study {uid: 'hu:study:synthetic-w17-no-ae-report'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'NOT_REPORTED', r.inputRole = 'NOT_REPORTED_STUDY', r.orderIndex = 4;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:Activity {uid: 'hu:activity:w17-signal-run-002'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'})
MERGE (a)-[r:SUPERSEDES]->(b)
  ON CREATE SET r.supersessionKind = 'RE_REVIEW', r.recordedAt = datetime('2026-10-04T02:40:00Z');
MATCH (s:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v1'})
SET s.recordedTo = datetime('2026-10-04T02:40:00Z'), s.status = 'SUPERSEDED';
MATCH (a:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-nrpt-gi-tolerability-v2'})
MERGE (a)-[r:REPORTS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.derivationRule = 'ss-study/v1', r.derivedFromAssessmentUids = ['hu:safety-signal:w17-nrpt-gi-tolerability-v2'], r.derivedAt = datetime('2026-10-04T02:41:00Z');
MERGE (n:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'})
  ON CREATE SET n.id = 'w17-fda-aems-2024q3-lenvatinib-tls', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'IDENTIFIES_POTENTIAL_SAFETY_SIGNAL', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:39cffc9c628cfeb6606a038741a7ceea35c4ef0f887f74d7cc1ef0f49aec3f48', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.assertionBasis = 'UNSTATED', n.jurisdiction = 'US', n.validFrom = datetime('2024-07-01T00:00:00Z'), n.validFromPrecision = 'QUARTER', n.validFromBasis = 'STATED_BY_SOURCE', n.validToBasis = 'UNKNOWN', n.description = 'FDA lists a potential signal; FDA states this does not mean it has concluded the drug has the risk';
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'}), (b:ChemicalSubstance {uid: 'hu:substance:lenvatinib'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'}), (b:AdverseEffect {uid: 'hu:adverse-effect:tumor-lysis-syndrome'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-lenvatinib-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'})
  ON CREATE SET n.id = 'w17-fda-aems-2024q3-daptomycin-hyperkalemia', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.predicate = 'IDENTIFIES_POTENTIAL_SAFETY_SIGNAL', n.status = 'EXTRACTED', n.recordedAt = datetime('2026-10-04T02:00:00Z'), n.contentHash = 'sha256:6c680b10d8095e98a8228c64a6d8dcdb62dc64ab88cc3cadc70691fb06f45f59', n.polarity = 'POSITIVE', n.speechAct = 'STATES', n.assertionBasis = 'UNSTATED', n.jurisdiction = 'US', n.validFrom = datetime('2024-07-01T00:00:00Z'), n.validFromPrecision = 'QUARTER', n.validFromBasis = 'STATED_BY_SOURCE', n.validToBasis = 'UNKNOWN', n.description = 'FDA lists a potential signal; FDA states this does not mean it has concluded the drug has the risk';
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'}), (b:ChemicalSubstance {uid: 'hu:substance:daptomycin'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'}), (b:AdverseEffect {uid: 'hu:adverse-effect:hyperkalemia'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'}), (b:Organization {uid: 'hu:org:us-fda'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-daptomycin-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'}), (b:Activity {uid: 'hu:activity:w17-extract-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'})
  ON CREATE SET n.id = 'w17-fda-aems-lenvatinib-tls', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.assessmentType = 'SafetySignal', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:45:00Z'), n.methodVersion = 'agency-signal-import/0.1', n.signalStatus = 'CLOSED_NO_ACTION', n.signalType = 'NEW_EFFECT', n.name = 'Lenvatinib - tumor lysis syndrome (FDA AEMS Jul-Sep 2024)', n.summary = 'FDA: \'no action was necessary at the time based on available information\' (as of 2025-10-24). Not \'no risk\'.';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:lenvatinib'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:w17-fda-aems-lenvatinib-tls-subject-0', r.subjectRole = 'PRIMARY', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'}), (b:AdverseEffect {uid: 'hu:adverse-effect:tumor-lysis-syndrome'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'}), (b:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-lenvatinib-tls'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'AGENCY_LISTING', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-lenvatinib-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-lenvatinib-tls'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-asof'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'})
  ON CREATE SET n.id = 'w17-fda-aems-daptomycin-hyperkalemia', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.assessmentType = 'SafetySignal', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:45:00Z'), n.methodVersion = 'agency-signal-import/0.1', n.signalStatus = 'CONFIRMED_ASSOCIATION', n.signalType = 'NEW_EFFECT', n.name = 'Daptomycin - hyperkalemia (FDA AEMS Jul-Sep 2024)', n.summary = 'FDA: Adverse Reactions labeling updated April and May 2025 to include hyperkalemia (as of 2025-10-24).';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:daptomycin'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:w17-fda-aems-daptomycin-hyperkalemia-subject-0', r.subjectRole = 'PRIMARY', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'}), (b:AdverseEffect {uid: 'hu:adverse-effect:hyperkalemia'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'}), (b:Assertion {uid: 'hu:assertion:w17-fda-aems-2024q3-daptomycin-hyperkalemia'})
MERGE (a)-[r:SIGNAL_BASED_ON]->(b)
  ON CREATE SET r.aeReportedStatus = 'REPORTED', r.inputRole = 'AGENCY_LISTING', r.orderIndex = 0;
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-daptomycin-row'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-fda-aems-daptomycin-hyperkalemia'}), (b:SourceLocator {uid: 'hu:locator:fda-aems-2024q3-asof'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MERGE (n:SafetySignal:EvidenceAssessment {uid: 'hu:safety-signal:w17-legacy-live-row-0001'})
  ON CREATE SET n.id = 'w17-legacy-live-row-0001', n.createdAt = datetime('2026-10-04T02:00:00Z'), n.privacyClass = 'PUBLIC', n.mongoResearchRunId = 'w17-fixture-run-2026-10-04', n.assessmentType = 'SafetySignal', n.status = 'PROPOSED', n.recordedAt = datetime('2026-10-04T02:50:00Z'), n.methodVersion = 'live-migration/0', n.signalStatus = 'NOT_EVALUATED', n.signalType = 'hepatotoxicity', n.legacyEvidenceStrengthHint = 'HIGH', n.name = 'Liver toxicity (migrated live SafetySignal row)', n.interactionSummary = 'may interact with alcohol (legacy free text)', n.summary = 'Migrated from live SafetySignal with SafetyMetadata.evidenceStrength=HIGH and no method or inputs.';
MATCH (a:ChemicalSubstance {uid: 'hu:substance:nicotinic-acid'}), (b:SafetySignal {uid: 'hu:safety-signal:w17-legacy-live-row-0001'})
MERGE (a)-[r:HAS_SAFETY_SIGNAL]->(b)
  ON CREATE SET r.relationshipUid = 'hu:rel:w17-legacy-live-row-0001-subject-0', r.subjectRole = 'PRIMARY', r.orderIndex = 0, r.doseText = 'high dose (legacy text)', r.notes = 'migrated SafetyMetadata; evidenceStrength and confidence dropped to the hint';
MATCH (a:SafetySignal {uid: 'hu:safety-signal:w17-legacy-live-row-0001'}), (b:AdverseEffect {uid: 'hu:adverse-effect:myopathy'})
MERGE (a)-[r:RELATES_TO_EFFECT]->(b);
