// =====================================================================================================================
// W09 fixture 02: null primary, favorable secondary, within-arm vs between-arm, and a favorable subgroup that may enter a
// synthesis only as HYPOTHESIS_GENERATING (INV-206). Real: ATLAS NCT03464500 (registry via MCP 2026-10-04) and Singh et
// al. 2022 PMID 35584623 (PubMed metadata + PMC9133463 directQuote extract via Firecrawl 2026-10-04). The subgroup result
// hu:study-result:atlas-synthetic-subgroup-* is SYNTHETIC (no subgroup was retrieved). EvidenceSynthesis nodes are W10
// types written here only as fixture content to exercise V-215/V-216 (inputRole on W10's INCLUDES_RESULT).
// Expected on this file alone: V-215 0 rows, V-216 0 rows, V-213 0 rows, V-223 0 rows (registry and paper agree on priority).
// =====================================================================================================================

// 1. Sources, snapshots and typed locators.
UNWIND [
  {src: 'hu:source:ctgov-nct03464500', uri: 'https://clinicaltrials.gov/study/NCT03464500', kind: 'REGULATORY_RECORD', snap: 'hu:snapshot:ctgov-nct03464500-2026-10-04',
   loc: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes', sel: 'SECTION', section: 'Outcome Measures (primary and secondary)', exact: null},
  {src: 'hu:source:pmc9133463', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc9133463-2026-10-04',
   loc: 'hu:locator:pmc9133463-abstract-primary-null', sel: 'TEXT_QUOTE', section: 'Summary', exact: 'do not notice a significant improvement on peak power output (primary endpoint)'},
  {src: 'hu:source:pmc9133463', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc9133463-2026-10-04',
   loc: 'hu:locator:pmc9133463-results-hamstring', sel: 'TEXT_QUOTE', section: 'Results: muscle strength',
   exact: 'Average peak torque in the hamstring skeletal muscle was significantly increased in both UA 500 mg (+12%, p = 0.027 compared with placebo)'},
  {src: 'hu:source:pmc9133463', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc9133463-2026-10-04',
   loc: 'hu:locator:pmc9133463-results-placebo-decline', sel: 'TEXT_QUOTE', section: 'Results: muscle strength',
   exact: 'Participants taking the placebo had significant within-group decreases (-9.8% for average torque, p = 0.008'},
  {src: 'hu:source:pmc9133463', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc9133463-2026-10-04',
   loc: 'hu:locator:pmc9133463-methods-multiplicity', sel: 'TEXT_QUOTE', section: 'STAR Methods: statistics', exact: 'No correction for multiplicity testing was applied.'},
  {src: 'hu:source:pmc9133463', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9133463/', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc9133463-2026-10-04',
   loc: 'hu:locator:pmc9133463-abstract-clinically-meaningful', sel: 'TEXT_QUOTE', section: 'Summary',
   exact: 'We observe clinically meaningful improvements with Urolithin A on aerobic endurance (peak oxygen oxygen consumption [VO2]) and physical performance (6 min walk test)'}
] AS r
MERGE (src:Source:Entity {uid: r.src})
  ON CREATE SET src.id = split(r.src, ':')[2], src.entityType = 'Source', src.canonicalUri = r.uri, src.sourceKind = r.kind, src.createdAt = datetime('2026-10-04T01:00:00Z'), src.privacyClass = 'PUBLIC'
MERGE (snap:SourceSnapshot:InformationArtifact {uid: r.snap})
  ON CREATE SET snap.id = split(r.snap, ':')[2], snap.artifactType = 'SourceSnapshot', snap.canonicalUri = r.uri,
                snap.retrievedAt = datetime('2026-10-04T00:58:00Z'), snap.observedAt = datetime('2026-10-04T00:58:00Z'),
                snap.contentHash = 'synthetic:' + r.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'PARTIAL_EXCERPT',
                snap.createdAt = datetime('2026-10-04T01:00:00Z'), snap.privacyClass = 'PUBLIC'
MERGE (loc:SourceLocator:InformationArtifact {uid: r.loc})
  ON CREATE SET loc.id = split(r.loc, ':')[2], loc.artifactType = 'SourceLocator', loc.uri = r.uri, loc.selectorKind = r.sel,
                loc.section = r.section, loc.exact = r.exact, loc.createdAt = datetime('2026-10-04T01:00:00Z'), loc.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// 2. Study, registration version, publication.
MATCH (rloc:SourceLocator {uid: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'})
MERGE (st:Study:Entity {uid: 'hu:study:nct03464500-atlas'})
  ON CREATE SET st.id = 'nct03464500-atlas', st.entityType = 'Study', st.name = 'ATLAS: urolithin A (Mitopure) in middle-aged overweight adults',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:ctgov-nct03464500'})
  ON CREATE SET reg.id = 'ctgov-nct03464500', reg.entityType = 'TrialRegistration', reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT03464500',
                reg.createdAt = datetime('2026-10-04T01:00:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:nct03464500-observed-2026-10-04'})
  ON CREATE SET rv.id = 'nct03464500-observed-2026-10-04', rv.artifactType = 'RegistrationVersion', rv.observedAt = datetime('2026-10-04T00:58:00Z'),
                rv.contentHash = 'synthetic:nct03464500-observed-2026-10-04', rv.acronym = 'ATLAS', rv.overallStatus = 'COMPLETED', rv.enrollmentCount = 90,
                rv.resultsPosted = false, rv.startDate = date('2018-03-06'), rv.startDatePrecision = 'DAY',
                rv.primaryCompletionDate = date('2019-09-30'), rv.primaryCompletionDatePrecision = 'DAY',
                rv.completionDate = date('2019-09-30'), rv.completionDatePrecision = 'DAY',
                rv.phase = ['NA'], rv.studyType = 'INTERVENTIONAL', rv.siteCountries = ['CA'],
                rv.interventionNamesVerbatim = ['Mitopure 500mg', 'Mitopure 1000mg', 'Placebo'], rv.sponsorNameVerbatim = 'Amazentis SA',
                rv.collaboratorNamesVerbatim = ['KGK Science Inc.'], rv.createdAt = datetime('2026-10-04T01:00:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (rv)-[:SUPPORTED_BY]->(rloc)
MERGE (reg)-[e:HAS_REGISTRATION_VERSION]->(rv)
  ON CREATE SET e.relationshipUid = 'hu:rel:hrv-nct03464500-2026-10-04', e.recordedFrom = datetime('2026-10-04T01:00:00Z'),
                e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN'
MERGE (pub:Publication:InformationArtifact {uid: 'hu:publication:pmid-35584623'})
  ON CREATE SET pub.id = 'pmid-35584623', pub.artifactType = 'Publication', pub.publicationKind = 'ARTICLE',
                pub.name = 'Urolithin A improves muscle strength, exercise performance, and biomarkers of mitochondrial health in a randomized trial in middle-aged adults',
                pub.doi = '10.1016/j.xcrm.2022.100633', pub.pmid = '35584623', pub.pmcid = 'PMC9133463', pub.venueName = 'Cell Reports Medicine',
                pub.publishedAt = datetime('2022-05-17T00:00:00Z'), pub.publishedAtPrecision = 'DAY', pub.createdAt = datetime('2026-10-04T01:00:00Z'), pub.privacyClass = 'PUBLIC';

// 2b. REGISTERED_AS (asserted edge with its assertion).
MATCH (st:Study {uid: 'hu:study:nct03464500-atlas'}), (reg:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct03464500'}),
      (loc:SourceLocator {uid: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'})
MERGE (a:Assertion {uid: 'hu:assertion:atlas-registered-as-nct03464500'})
  ON CREATE SET a.id = 'atlas-registered-as-nct03464500', a.predicate = 'REGISTERED_AS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-atlas-registered-as',
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(reg)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[e:REGISTERED_AS]->(reg)
  ON CREATE SET e.relationshipUid = 'hu:rel:atlas-registered-as-nct03464500', e.assertionUid = a.uid, e.recordedFrom = a.recordedAt,
                e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// 3. Arms, interventions, components. Material identity of 'Mitopure' is W02's (branded material); asReportedName kept.
UNWIND [
  {arm: 'hu:arm:atlas-placebo', armName: 'Placebo', armType: 'PLACEBO_COMPARATOR', si: 'hu:intervention:atlas-placebo', siName: '4 placebo softgels daily', ic: null, qty: null, txt: null},
  {arm: 'hu:arm:atlas-ua-500', armName: 'Mitopure 500mg', armType: 'EXPERIMENTAL', si: 'hu:intervention:atlas-ua-500', siName: 'UA 500 mg/day (2 UA + 2 placebo softgels)',
   ic: 'hu:intervention-component:atlas-ua-500', qty: 500.0, txt: 'Mitopure 500mg; 4 soft-gel capsules daily'},
  {arm: 'hu:arm:atlas-ua-1000', armName: 'Mitopure 1000mg', armType: 'EXPERIMENTAL', si: 'hu:intervention:atlas-ua-1000', siName: 'UA 1000 mg/day (4 UA softgels)',
   ic: 'hu:intervention-component:atlas-ua-1000', qty: 1000.0, txt: 'Mitopure 1000mg; 4 soft-gel capsules daily'}
] AS r
MATCH (st:Study {uid: 'hu:study:nct03464500-atlas'})
MERGE (arm:StudyArm:VersionedState {uid: r.arm})
  ON CREATE SET arm.id = split(r.arm, ':')[2], arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-' + split(r.arm, ':')[2],
                arm.name = r.armName, arm.armType = r.armType, arm.plannedSize = 30, arm.createdAt = datetime('2026-10-04T01:00:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (si:StudyIntervention:VersionedState {uid: r.si})
  ON CREATE SET si.id = split(r.si, ':')[2], si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-' + split(r.si, ':')[2],
                si.name = r.siName, si.route = 'ORAL', si.dosageForm = 'SOFTGEL', si.dosesPerDay = null, si.durationIso = 'P4M',
                si.registryInterventionType = null, si.createdAt = datetime('2026-10-04T01:00:00Z'), si.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (a:Assertion {uid: 'hu:assertion:assigns-' + split(r.si, ':')[2]})
  ON CREATE SET a.id = 'assigns-' + split(r.si, ':')[2], a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-assigns-' + split(r.si, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(arm)
MERGE (a)-[:HAS_OBJECT]->(si)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-' + split(r.si, ':')[2], e.assertionUid = a.uid, e.recordedFrom = a.recordedAt,
                e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// 3b. Assignment assertions cite the registry arms section.
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:assigns-atlas-placebo', 'hu:assertion:assigns-atlas-ua-500', 'hu:assertion:assigns-atlas-ua-1000']
MATCH (loc:SourceLocator {uid: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'})
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 3c. Components -> material as administered (asReportedName = registry label).
UNWIND [
  {si: 'hu:intervention:atlas-ua-500', ic: 'hu:intervention-component:atlas-ua-500', qty: 500.0, name: 'Mitopure 500mg'},
  {si: 'hu:intervention:atlas-ua-1000', ic: 'hu:intervention-component:atlas-ua-1000', qty: 1000.0, name: 'Mitopure 1000mg'}
] AS r
MATCH (si:StudyIntervention {uid: r.si}), (loc:SourceLocator {uid: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'})
MERGE (mat:IngredientMaterial:Entity {uid: 'hu:material:amazentis-mitopure-as-administered-atlas'})
  ON CREATE SET mat.id = 'amazentis-mitopure-as-administered-atlas', mat.entityType = 'IngredientMaterial',
                mat.name = 'Mitopure (urolithin A) as administered in ATLAS; specification version unknown', mat.createdAt = datetime('2026-10-04T01:00:00Z'), mat.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: r.ic})
  ON CREATE SET ic.id = split(r.ic, ':')[2], ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-' + split(r.ic, ':')[2],
                ic.quantity = r.qty, ic.unitCode = 'mg/d', ic.quantityBasis = 'PER_DAY', ic.massBasis = 'UNSPECIFIED', ic.quantityStatus = 'REPORTED',
                ic.verbatimDoseText = r.name, ic.createdAt = datetime('2026-10-04T01:00:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:uses-material-' + split(r.ic, ':')[2]})
  ON CREATE SET a.id = 'uses-material-' + split(r.ic, ':')[2], a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-uses-material-' + split(r.ic, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(ic)
MERGE (a)-[:HAS_OBJECT]->(mat)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(mat)
  ON CREATE SET u.relationshipUid = 'hu:rel:uses-material-' + split(r.ic, ':')[2], u.assertionUid = a.uid, u.recordedFrom = a.recordedAt,
                u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN', u.asReportedName = r.name;

// 4. Outcome definitions and per-source priority declarations (registry and paper agree for peak power output).
UNWIND [
  {od: 'hu:outcome:atlas-power-output-d120', name: 'Change in exercise tolerance: power output on cycle ergometer, baseline to day 120', mk: 'PERFORMANCE_OUTCOME', tp: '4 months'},
  {od: 'hu:outcome:atlas-isokinetic-strength-d120', name: 'Change in isokinetic lower body muscle strength (Biodex), baseline to day 120', mk: 'PERFORMANCE_OUTCOME', tp: '4 months'},
  {od: 'hu:outcome:atlas-6mwt-d120', name: 'Change in 6-minute walk distance, baseline to day 120', mk: 'PERFORMANCE_OUTCOME', tp: '4 months'}
] AS r
MATCH (st:Study {uid: 'hu:study:nct03464500-atlas'}), (rv:RegistrationVersion {uid: 'hu:registration-version:nct03464500-observed-2026-10-04'})
MERGE (od:OutcomeDefinition:VersionedState {uid: r.od})
  ON CREATE SET od.id = split(r.od, ':')[2], od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:synthetic-' + split(r.od, ':')[2],
                od.name = r.name, od.measureKind = r.mk, od.timepoint = r.tp, od.createdAt = datetime('2026-10-04T01:00:00Z'), od.privacyClass = 'PUBLIC'
MERGE (st)-[:DEFINES_OUTCOME]->(od)
MERGE (od)-[:DEFINED_IN]->(rv);

UNWIND [
  {a: 'hu:assertion:atlas-power-priority-registry', od: 'hu:outcome:atlas-power-output-d120', v: 'PRIMARY', loc: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'},
  {a: 'hu:assertion:atlas-power-priority-paper', od: 'hu:outcome:atlas-power-output-d120', v: 'PRIMARY', loc: 'hu:locator:pmc9133463-abstract-primary-null'},
  {a: 'hu:assertion:atlas-strength-priority-registry', od: 'hu:outcome:atlas-isokinetic-strength-d120', v: 'SECONDARY', loc: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'},
  {a: 'hu:assertion:atlas-6mwt-priority-registry', od: 'hu:outcome:atlas-6mwt-d120', v: 'SECONDARY', loc: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'}
] AS r
MATCH (od:OutcomeDefinition {uid: r.od}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
  ON CREATE SET a.id = split(r.a, ':')[2], a.predicate = 'DECLARES_OUTCOME_PRIORITY', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueString = r.v,
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-' + split(r.a, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(od)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 4b. Derived registered priority (projection of the registry declaration; earliest observed version = the only one).
MATCH (od:OutcomeDefinition)<-[:HAS_SUBJECT]-(a:Assertion {predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(:Source {uid: 'hu:source:ctgov-nct03464500'})
WHERE od.uid STARTS WITH 'hu:outcome:atlas-'
SET od.priority = a.valueString, od.priorityAssertionUid = a.uid;

// 5. Results. analysisKind from the registered priority; comparisonKind and statisticalConclusion from the quoted sentence.
UNWIND [
  {uid: 'hu:study-result:atlas-power-ua-vs-placebo-d120', od: 'hu:outcome:atlas-power-output-d120', ak: 'PRIMARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'NOT_SIGNIFICANT',
   est: null, rk: null, p: null, ptxt: null, ma: false, loc: 'hu:locator:pmc9133463-abstract-primary-null',
   txt: 'do not notice a significant improvement on peak power output (primary endpoint)', arms: ['hu:arm:atlas-ua-500', 'hu:arm:atlas-ua-1000'], comp: 'hu:arm:atlas-placebo'},
  {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo', od: 'hu:outcome:atlas-isokinetic-strength-d120', ak: 'SECONDARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'SIGNIFICANT_FAVORABLE',
   est: null, rk: null, p: 0.027, ptxt: 'p = 0.027 compared with placebo', ma: false, loc: 'hu:locator:pmc9133463-results-hamstring',
   txt: 'hamstring average peak torque UA 500 mg vs placebo', arms: ['hu:arm:atlas-ua-500'], comp: 'hu:arm:atlas-placebo'},
  {uid: 'hu:study-result:atlas-hamstring-ua500-within-arm', od: 'hu:outcome:atlas-isokinetic-strength-d120', ak: 'SECONDARY_PRESPECIFIED', ck: 'WITHIN_ARM_CHANGE', sc: 'NOT_REPORTED',
   est: 12.0, rk: 'PERCENT_CHANGE', p: null, ptxt: null, ma: false, loc: 'hu:locator:pmc9133463-results-hamstring',
   txt: '+12% (UA 500 mg arm change from baseline; the p-value in the same sentence is the between-arm test)', arms: ['hu:arm:atlas-ua-500'], comp: null},
  {uid: 'hu:study-result:atlas-hamstring-placebo-within-arm', od: 'hu:outcome:atlas-isokinetic-strength-d120', ak: 'SECONDARY_PRESPECIFIED', ck: 'WITHIN_ARM_CHANGE', sc: 'SIGNIFICANT_UNFAVORABLE',
   est: -9.8, rk: 'PERCENT_CHANGE', p: 0.008, ptxt: 'p = 0.008', ma: false, loc: 'hu:locator:pmc9133463-results-placebo-decline',
   txt: 'placebo within-group decrease -9.8% average torque', arms: ['hu:arm:atlas-placebo'], comp: null},
  {uid: 'hu:study-result:atlas-6mwt-ua-vs-placebo', od: 'hu:outcome:atlas-6mwt-d120', ak: 'SECONDARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'NOT_REPORTED',
   est: null, rk: null, p: null, ptxt: null, ma: false, loc: 'hu:locator:pmc9133463-abstract-clinically-meaningful',
   txt: 'clinically meaningful improvements ... physical performance (6 min walk test) [significance not stated in the quoted span]', arms: ['hu:arm:atlas-ua-500', 'hu:arm:atlas-ua-1000'], comp: 'hu:arm:atlas-placebo'}
] AS r
MATCH (od:OutcomeDefinition {uid: r.od}), (loc:SourceLocator {uid: r.loc}), (mloc:SourceLocator {uid: 'hu:locator:pmc9133463-methods-multiplicity'})
MERGE (res:StudyResult:InformationArtifact {uid: r.uid})
  ON CREATE SET res.id = split(r.uid, ':')[2], res.artifactType = 'StudyResult', res.analysisKind = r.ak, res.comparisonKind = r.ck,
                res.statisticalConclusion = r.sc, res.estimate = r.est, res.resultKind = r.rk, res.unitCode = CASE WHEN r.est IS NULL THEN null ELSE '%' END,
                res.pValue = r.p, res.pValueText = r.ptxt, res.multiplicityAdjusted = r.ma, res.resultText = r.txt, res.timepoint = 'day 120',
                res.isStatisticallySignificant = CASE r.sc WHEN 'NOT_SIGNIFICANT' THEN false WHEN 'SIGNIFICANT_FAVORABLE' THEN true WHEN 'SIGNIFICANT_UNFAVORABLE' THEN true ELSE null END,
                res.createdAt = datetime('2026-10-04T01:00:00Z'), res.privacyClass = 'PUBLIC'
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:SUPPORTED_BY]->(loc)
MERGE (res)-[:SUPPORTED_BY]->(mloc)
WITH res, r
UNWIND r.arms AS armUid
MATCH (arm:StudyArm {uid: armUid})
MERGE (res)-[ra:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(arm);

// 5b. Comparator arms (explicit armRole, never inferred).
UNWIND [
  {res: 'hu:study-result:atlas-power-ua-vs-placebo-d120'}, {res: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'}, {res: 'hu:study-result:atlas-6mwt-ua-vs-placebo'}
] AS r
MATCH (res:StudyResult {uid: r.res}), (pl:StudyArm {uid: 'hu:arm:atlas-placebo'})
MERGE (res)-[:RESULT_FOR_ARM {armRole: 'COMPARATOR'}]->(pl);

// 5c. SYNTHETIC favorable subgroup after a null primary (illustrative values; no such subgroup was retrieved).
MATCH (od:OutcomeDefinition {uid: 'hu:outcome:atlas-power-output-d120'}), (a500:StudyArm {uid: 'hu:arm:atlas-ua-500'}), (pl:StudyArm {uid: 'hu:arm:atlas-placebo'})
MERGE (res:StudyResult:InformationArtifact {uid: 'hu:study-result:atlas-synthetic-subgroup-low-vo2max'})
  ON CREATE SET res.id = 'atlas-synthetic-subgroup-low-vo2max', res.artifactType = 'StudyResult', res.name = 'SYNTHETIC subgroup (not from any source)',
                res.analysisKind = 'SUBGROUP_POST_HOC', res.comparisonKind = 'BETWEEN_ARM', res.statisticalConclusion = 'SIGNIFICANT_FAVORABLE',
                res.isStatisticallySignificant = true, res.multiplicityAdjusted = false, res.createdAt = datetime('2026-10-04T01:00:00Z'), res.privacyClass = 'PUBLIC'
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(a500)
MERGE (res)-[:RESULT_FOR_ARM {armRole: 'COMPARATOR'}]->(pl);

// 6. Author claim of clinical meaningfulness: an Assertion, never a StudyResult property (V-213; FI STATISTICALLY_SIGNIFICANT -> CLINICALLY_MEANINGFUL).
MATCH (res:StudyResult {uid: 'hu:study-result:atlas-6mwt-ua-vs-placebo'}), (loc:SourceLocator {uid: 'hu:locator:pmc9133463-abstract-clinically-meaningful'})
MERGE (a:Assertion {uid: 'hu:assertion:atlas-6mwt-clinically-meaningful-authors'})
  ON CREATE SET a.id = 'atlas-6mwt-clinically-meaningful-authors', a.predicate = 'RESULT_CLINICALLY_MEANINGFUL', a.valueBoolean = true, a.status = 'ACCEPTED',
                a.polarity = 'POSITIVE', a.assertionBasis = 'STUDY_RESULT', a.speechAct = 'STATES', a.recordedAt = datetime('2026-10-04T01:00:00Z'),
                a.contentHash = 'sha256:synthetic-atlas-6mwt-cm', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(res)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 7. W10-owned synthesis (fixture content only): the null primary is the CONFIRMATORY input; the favorable secondary is
//    SUPPORTIVE; the favorable subgroup is HYPOTHESIS_GENERATING (INV-206). The within-arm UA change is not an input.
MATCH (p:StudyResult {uid: 'hu:study-result:atlas-power-ua-vs-placebo-d120'}), (s:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'}),
      (g:StudyResult {uid: 'hu:study-result:atlas-synthetic-subgroup-low-vo2max'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ua-improves-muscle-function-middle-aged-v1'})
  ON CREATE SET syn.id = 'ua-improves-muscle-function-middle-aged-v1', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1',
                syn.status = 'PROPOSED', syn.claimText = 'Urolithin A 500-1000 mg/day for 4 months improves muscle function in middle-aged adults',
                syn.verdict = 'INSUFFICIENT', syn.evidenceCutoff = date('2022-05-31'), syn.recordedAt = datetime('2026-10-04T01:00:00Z'), syn.createdAt = datetime('2026-10-04T01:00:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(p)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(s)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'HYPOTHESIS_GENERATING'}]->(g);

// 8. Capture-fidelity policy adjudication for this fixture's assertions.
MATCH (a:Assertion) WHERE a.uid STARTS WITH 'hu:assertion:atlas-' OR a.uid IN ['hu:assertion:assigns-atlas-placebo', 'hu:assertion:assigns-atlas-ua-500', 'hu:assertion:assigns-atlas-ua-1000', 'hu:assertion:uses-material-atlas-ua-500', 'hu:assertion:uses-material-atlas-ua-1000']
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-02-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-02-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:00:00Z'), j.recordedAt = datetime('2026-10-04T01:00:00Z'), j.createdAt = datetime('2026-10-04T01:00:00Z'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a);
