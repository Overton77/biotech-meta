// =====================================================================================================================
// W09 fixture 05: adverse-event results; reported zero vs not reported; collection method (INV-207, V-217, CQ-ST-06).
// Real: Dellinger 2017 (PMID 29184669; PMC5701244 directQuote extract, Firecrawl 2026-10-04): "A total of 66 adverse events
//   (AEs) were reported by 45 participants ... 18 AEs were reported by 13 participants in the placebo group, 25 reported by 15
//   participants in the NRPT 1X group, and 23 reported by 17 participants in the NRPT 2X group ... there were no serious AEs
//   reported during this clinical study"; Methods: "Safety parameters measured included ... self-reported AEs"; ITT 40/38/40.
//   The paper does not say how AEs were elicited: collectionMethod NOT_DESCRIBED (the 0.2.0 fixture's SYSTEMATIC is not
//   supported by the text; W09-D07). Liu 2022 ENERGIZE (PMID 35050355; PMC8777576 extract): "AEs were recorded and coded
//   according to the Medical Dictionary for Regulatory Activities" ... "No serious AEs were reported." -> NOT_DESCRIBED.
// SYNTHETIC: one SYSTEMATIC zero (illustrative) so the positive V-217 path is exercised.
// Not reported: NCT00938340 (Berryman 2013 abstract has no AE statement) gets NO AdverseEventResult.
// Expected (frozen V-217): rows for every zero with NOT_DESCRIBED (3 Basis SAE + 2 ENERGIZE SAE = 5) -> W09-CR-01 proposes V-217
//   (hard: collectionMethod null) + V-217i (informational: zero with NOT_DESCRIBED). Synthetic SYSTEMATIC zero: no row.
// =====================================================================================================================

// 1. Locators for the Basis AE section, Basis methods (collection wording), ENERGIZE AE section.
UNWIND [
  {src: 'hu:source:pmc5701244', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', snap: 'hu:snapshot:pmc5701244-2026-10-04', loc: 'hu:locator:pmc5701244-results-adverse-events',
   section: 'Results: Adverse events', exact: 'All participants reporting AEs recovered and there were no serious AEs reported during this clinical study.'},
  {src: 'hu:source:pmc5701244', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', snap: 'hu:snapshot:pmc5701244-2026-10-04', loc: 'hu:locator:pmc5701244-results-ae-counts',
   section: 'Results: Adverse events', exact: 'Of these, 18 AEs were reported by 13 participants in the placebo group, 25 reported by 15 participants in the NRPT 1X group, and 23 reported by 17 participants in the NRPT 2X group.'},
  {src: 'hu:source:pmc5701244', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', snap: 'hu:snapshot:pmc5701244-2026-10-04', loc: 'hu:locator:pmc5701244-methods-safety-parameters',
   section: 'Methods: Clinical trial', exact: 'Safety parameters measured included a standard clinical checkup, self-reported AEs'},
  {src: 'hu:source:pmc5701244', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', snap: 'hu:snapshot:pmc5701244-2026-10-04', loc: 'hu:locator:pmc5701244-results-itt',
   section: 'Results', exact: 'All participants were analyzed in the Intention-to-Treat Population (ITT), with 40 participants in the NRPT 1X group, 38 in the NRPT 2X group, and 40 in the placebo group.'},
  {src: 'hu:source:pmc8777576', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC8777576/', snap: 'hu:snapshot:pmc8777576-2026-10-04', loc: 'hu:locator:pmc8777576-adverse-events',
   section: 'Results: Adverse events', exact: 'No serious AEs were reported.'},
  {src: 'hu:source:pmc8777576', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC8777576/', snap: 'hu:snapshot:pmc8777576-2026-10-04', loc: 'hu:locator:pmc8777576-methods-ae-recording',
   section: 'Methods: Adverse Events, Compliance, and Plasma Collection', exact: 'Adverse events (AEs) were recorded and coded according to the Medical Dictionary for Regulatory Activities.'}
] AS r
MERGE (src:Source:Entity {uid: r.src})
  ON CREATE SET src.id = split(r.src, ':')[2], src.entityType = 'Source', src.canonicalUri = r.uri, src.sourceKind = 'PEER_REVIEWED_PUBLICATION', src.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (snap:SourceSnapshot:InformationArtifact {uid: r.snap})
  ON CREATE SET snap.id = split(r.snap, ':')[2], snap.artifactType = 'SourceSnapshot', snap.canonicalUri = r.uri, snap.retrievedAt = datetime('2026-10-04T01:00:00Z'),
                snap.observedAt = datetime('2026-10-04T01:00:00Z'), snap.contentHash = 'synthetic:' + r.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE',
                snap.captureCompleteness = 'PARTIAL_EXCERPT', snap.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (loc:SourceLocator:InformationArtifact {uid: r.loc})
  ON CREATE SET loc.id = split(r.loc, ':')[2], loc.artifactType = 'SourceLocator', loc.uri = r.uri, loc.selectorKind = 'TEXT_QUOTE', loc.section = r.section, loc.exact = r.exact,
                loc.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// 2. Basis arms (names per paper) and analyzed (ITT) cohorts.
UNWIND [
  {k: 'placebo', name: 'Placebo', type: 'PLACEBO_COMPARATOR', itt: 40},
  {k: 'nrpt-1x', name: 'NRPT 1X', type: 'EXPERIMENTAL', itt: 40},
  {k: 'nrpt-2x', name: 'NRPT 2X', type: 'EXPERIMENTAL', itt: 38}
] AS r
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:nct02678611-' + r.k})
  ON CREATE SET arm.id = 'nct02678611-' + r.k, arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-nct02678611-' + r.k, arm.name = r.name, arm.armType = r.type,
                arm.plannedSize = 40, arm.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (pop:StudyPopulation:VersionedState {uid: 'hu:study-population:nct02678611-itt-' + r.k})
  ON CREATE SET pop.id = 'nct02678611-itt-' + r.k, pop.stateType = 'StudyPopulation', pop.payloadHash = 'sha256:synthetic-pop-nct02678611-itt-' + r.k,
                pop.populationKind = 'ANALYZED', pop.analysisSet = 'INTENTION_TO_TREAT', pop.size = r.itt, pop.name = 'ITT ' + r.name, pop.createdAt = datetime('2026-10-04T01:10:00Z');

// 3. Basis AE rows: any-AE counts per arm, and the serious-AE zeros (per-arm zero deduced from the study-level statement).
UNWIND [
  {k: 'placebo', term: 'Any adverse event', ser: 'ANY', aff: 13, ev: 18, loc: 'hu:locator:pmc5701244-results-ae-counts'},
  {k: 'nrpt-1x', term: 'Any adverse event', ser: 'ANY', aff: 15, ev: 25, loc: 'hu:locator:pmc5701244-results-ae-counts'},
  {k: 'nrpt-2x', term: 'Any adverse event', ser: 'ANY', aff: 17, ev: 23, loc: 'hu:locator:pmc5701244-results-ae-counts'},
  {k: 'placebo', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0, loc: 'hu:locator:pmc5701244-results-adverse-events'},
  {k: 'nrpt-1x', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0, loc: 'hu:locator:pmc5701244-results-adverse-events'},
  {k: 'nrpt-2x', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0, loc: 'hu:locator:pmc5701244-results-adverse-events'}
] AS r
MATCH (arm:StudyArm {uid: 'hu:arm:nct02678611-' + r.k}), (pop:StudyPopulation {uid: 'hu:study-population:nct02678611-itt-' + r.k}),
      (loc:SourceLocator {uid: r.loc}), (mloc:SourceLocator {uid: 'hu:locator:pmc5701244-methods-safety-parameters'}), (iloc:SourceLocator {uid: 'hu:locator:pmc5701244-results-itt'})
MERGE (ae:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct02678611-ae-' + toLower(r.ser) + '-' + r.k})
  ON CREATE SET ae.id = 'nct02678611-ae-' + toLower(r.ser) + '-' + r.k, ae.artifactType = 'AdverseEventResult', ae.resultKind = 'ADVERSE_EVENT_COUNT',
                ae.analysisKind = 'SAFETY', ae.comparisonKind = 'ARM_DESCRIPTIVE', ae.statisticalConclusion = 'NOT_TESTED',
                ae.eventTerm = r.term, ae.eventTermCode = null, ae.seriousness = r.ser, ae.participantsAffected = r.aff, ae.eventCount = r.ev,
                ae.participantsAtRisk = pop.size, ae.collectionMethod = 'NOT_DESCRIBED', ae.collectionMethodText = 'self-reported AEs',
                ae.relatednessAssessor = 'NOT_REPORTED', ae.timeFrameText = '8 weeks', ae.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ae)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(arm)
MERGE (ae)-[:HAS_ANALYZED_COHORT]->(pop)
MERGE (ae)-[:SUPPORTED_BY]->(loc)
MERGE (ae)-[:SUPPORTED_BY]->(mloc)
MERGE (ae)-[:SUPPORTED_BY]->(iloc);

// 4. ENERGIZE serious-AE zeros (arm names per registry intervention labels; arm sizes not extracted -> participantsAtRisk null).
UNWIND [{k: 'ua', name: 'Mitopure', type: 'EXPERIMENTAL'}, {k: 'placebo', name: 'Placebo', type: 'PLACEBO_COMPARATOR'}] AS r
MATCH (st:Study {uid: 'hu:study:nct03283462-energize'}), (loc:SourceLocator {uid: 'hu:locator:pmc8777576-adverse-events'}), (mloc:SourceLocator {uid: 'hu:locator:pmc8777576-methods-ae-recording'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:nct03283462-' + r.k})
  ON CREATE SET arm.id = 'nct03283462-' + r.k, arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-nct03283462-' + r.k, arm.name = r.name, arm.armType = r.type,
                arm.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (ae:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:nct03283462-ae-serious-' + r.k})
  ON CREATE SET ae.id = 'nct03283462-ae-serious-' + r.k, ae.artifactType = 'AdverseEventResult', ae.resultKind = 'ADVERSE_EVENT_COUNT', ae.analysisKind = 'SAFETY',
                ae.comparisonKind = 'ARM_DESCRIPTIVE', ae.statisticalConclusion = 'NOT_TESTED', ae.eventTerm = 'Serious adverse event', ae.eventTermVocabulary = 'MedDRA',
                ae.seriousness = 'SERIOUS', ae.participantsAffected = 0, ae.eventCount = 0, ae.participantsAtRisk = null, ae.collectionMethod = 'NOT_DESCRIBED',
                ae.collectionMethodText = 'recorded and coded according to the Medical Dictionary for Regulatory Activities', ae.relatednessAssessor = 'NOT_REPORTED',
                ae.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ae)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(arm)
MERGE (ae)-[:SUPPORTED_BY]->(loc)
MERGE (ae)-[:SUPPORTED_BY]->(mloc);

// 5. SYNTHETIC systematically collected zero (illustrative only; not from any source).
MERGE (st:Study:Entity {uid: 'hu:study:synthetic-ae-systematic-demo'})
  ON CREATE SET st.id = 'synthetic-ae-systematic-demo', st.entityType = 'Study', st.name = 'SYNTHETIC: systematic AE checklist demo', st.studyKind = 'INTERVENTIONAL_RANDOMIZED',
                st.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:synthetic-ae-systematic-demo-active'})
  ON CREATE SET arm.id = 'synthetic-ae-systematic-demo-active', arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-ae-demo', arm.name = 'Active',
                arm.armType = 'EXPERIMENTAL', arm.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (ae:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:synthetic-ae-systematic-demo-serious-active'})
  ON CREATE SET ae.id = 'synthetic-ae-systematic-demo-serious-active', ae.artifactType = 'AdverseEventResult', ae.resultKind = 'ADVERSE_EVENT_COUNT', ae.analysisKind = 'SAFETY',
                ae.comparisonKind = 'ARM_DESCRIPTIVE', ae.statisticalConclusion = 'NOT_TESTED', ae.eventTerm = 'Serious adverse event', ae.seriousness = 'SERIOUS',
                ae.participantsAffected = 0, ae.eventCount = 0, ae.participantsAtRisk = 25, ae.collectionMethod = 'SYSTEMATIC',
                ae.collectionMethodText = 'SYNTHETIC: structured AE checklist administered at every scheduled visit', ae.relatednessAssessor = 'INVESTIGATOR',
                ae.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ae)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(arm);
