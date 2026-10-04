// =====================================================================================================================
// W09 fixture 04: non-supplement study interventions through StudyIntervention -> InterventionComponent -> target.
//  (a) FOOD: NCT00938340 whole walnuts vs separated skins vs defatted nutmeat vs oil (doses from Berryman 2013 abstract,
//      PMID 23616506): four materials of one food, single test meal, mass as served (MATERIAL_AS_IS, SINGLE_DOSE).
//  (b) DEVICE: NCT02582593 transcranial near-infrared stimulation, MedX 1116 Rehab Console real vs sham (registry via MCP
//      2026-10-04; has_results true). Target is W08 Device through the CANDIDATE edge USES_INTERVENTION_DEVICE.
//  (c) PROCEDURE: SYNTHETIC sauna study; intervention FOLLOWS_INTERVENTION_DEFINITION -> W06 Procedure (CANDIDATE edge).
//  (d) FOOD in a registered, not-completed study: NCT04985630 'Pomegranate Juice' (amount not reported by the registry).
// Expected (RUN 2026-10-04 on Neo4j 5.26.31 with fixtures 01-04 loaded): V-201 0 rows. Frozen V-221 returns 4 rows: device real
//   and sham components (massBasis/quantityBasis null, NOT_APPLICABLE), pomegranate juice (basis null with NOT_REPORTED) and
//   the definition-only sauna intervention (no component). All four are false positives -> W09-CR-02 proposes V-221r (0 rows).
//   The four walnut arms have armType null and silently escape frozen V-221 (null <> 'PLACEBO_COMPARATOR' is null): also W09-CR-02.
// =====================================================================================================================

// 1. Sources (registry records and the Berryman abstract were captured in fixtures 01/03; device record here).
MERGE (src:Source:Entity {uid: 'hu:source:ctgov-nct02582593'})
  ON CREATE SET src.id = 'ctgov-nct02582593', src.entityType = 'Source', src.canonicalUri = 'https://clinicaltrials.gov/study/NCT02582593', src.sourceKind = 'REGULATORY_RECORD',
                src.createdAt = datetime('2026-10-04T01:00:00Z'), src.privacyClass = 'PUBLIC'
MERGE (snap:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct02582593-2026-10-04'})
  ON CREATE SET snap.id = 'ctgov-nct02582593-2026-10-04', snap.artifactType = 'SourceSnapshot', snap.canonicalUri = 'https://clinicaltrials.gov/study/NCT02582593',
                snap.retrievedAt = datetime('2026-10-04T01:02:00Z'), snap.observedAt = datetime('2026-10-04T01:02:00Z'), snap.contentHash = 'synthetic:ctgov-nct02582593-2026-10-04',
                snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'PARTIAL_EXCERPT', snap.createdAt = datetime('2026-10-04T01:05:00Z'), snap.privacyClass = 'PUBLIC'
MERGE (l1:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct02582593-detailed-description-nir'})
  ON CREATE SET l1.id = 'ctgov-nct02582593-detailed-description-nir', l1.artifactType = 'SourceLocator', l1.uri = 'https://clinicaltrials.gov/study/NCT02582593',
                l1.selectorKind = 'TEXT_QUOTE', l1.section = 'Detailed Description',
                l1.exact = 'The intervention will involve six sessions, over a 2-week period in which real or sham stimulation is transcranially applied using a delivery system that has been FDA-approved as a nonsignificant risk since 2003.',
                l1.createdAt = datetime('2026-10-04T01:05:00Z'), l1.privacyClass = 'PUBLIC'
MERGE (l2:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct02582593-detailed-description-wavelength'})
  ON CREATE SET l2.id = 'ctgov-nct02582593-detailed-description-wavelength', l2.artifactType = 'SourceLocator', l2.uri = 'https://clinicaltrials.gov/study/NCT02582593',
                l2.selectorKind = 'TEXT_QUOTE', l2.section = 'Detailed Description', l2.exact = 'transcranial delivery of near-infrared (NIR) wavelengths (808-904nm)',
                l2.createdAt = datetime('2026-10-04T01:05:00Z'), l2.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(l1)
MERGE (snap)-[:HAS_LOCATOR]->(l2);

// 2a. FOOD arms, interventions and components (walnut materials as served). Doses: PubMed abstract PMID 23616506.
UNWIND [
  {k: 'whole', armName: 'Whole walnut', siName: 'Whole walnuts 85 g, single test meal', qty: 85.0, txt: 'whole walnuts (85 g)', mat: 'hu:material:walnut-whole-kernels-nct00938340', matName: 'English walnut kernels, whole, as served in NCT00938340'},
  {k: 'skins', armName: 'Walnut Skins', siName: 'Separated walnut skins 5.6 g, single test meal', qty: 5.6, txt: 'separated nut skins (5.6 g)', mat: 'hu:material:walnut-skins-nct00938340', matName: 'Walnut skins (pellicle), separated, as served in NCT00938340'},
  {k: 'meat', armName: 'Walnut "meat"', siName: 'De-fatted walnut nutmeat 34 g, single test meal', qty: 34.0, txt: 'de-fatted nutmeat (34 g)', mat: 'hu:material:walnut-defatted-nutmeat-nct00938340', matName: 'Walnut nutmeat, de-fatted, as served in NCT00938340'},
  {k: 'oil', armName: 'Walnut Oil', siName: 'Walnut oil 51 g, single test meal', qty: 51.0, txt: 'nut oil (51 g)', mat: 'hu:material:walnut-oil-nct00938340', matName: 'Walnut oil, as served in NCT00938340'}
] AS r
MATCH (st:Study {uid: 'hu:study:nct00938340-walnut-components'}), (loc:SourceLocator {uid: 'hu:locator:pubmed-23616506-abstract'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:nct00938340-' + r.k})
  ON CREATE SET arm.id = 'nct00938340-' + r.k, arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-nct00938340-' + r.k, arm.name = r.armName,
                arm.armType = null, arm.createdAt = datetime('2026-10-04T01:05:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:nct00938340-' + r.k})
  ON CREATE SET si.id = 'nct00938340-' + r.k, si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-si-nct00938340-' + r.k, si.name = r.siName,
                si.route = 'ORAL', si.dosageForm = CASE r.k WHEN 'whole' THEN 'WHOLE_FOOD' ELSE 'FOOD_FRACTION' END, si.schedule = 'single test meal consumed within 15 min after a 12-h fast',
                si.dosesPerDay = null, si.durationIso = null, si.createdAt = datetime('2026-10-04T01:05:00Z'), si.privacyClass = 'PUBLIC'
MERGE (mat:IngredientMaterial:Entity {uid: r.mat})
  ON CREATE SET mat.id = split(r.mat, ':')[2], mat.entityType = 'IngredientMaterial', mat.name = r.matName, mat.createdAt = datetime('2026-10-04T01:05:00Z'), mat.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:nct00938340-' + r.k})
  ON CREATE SET ic.id = 'nct00938340-' + r.k, ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-ic-nct00938340-' + r.k,
                ic.quantity = r.qty, ic.unitCode = 'g', ic.quantityBasis = 'SINGLE_DOSE', ic.massBasis = 'MATERIAL_AS_IS', ic.quantityStatus = 'REPORTED',
                ic.verbatimDoseText = r.txt, ic.createdAt = datetime('2026-10-04T01:05:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (aa:Assertion {uid: 'hu:assertion:assigns-nct00938340-' + r.k})
  ON CREATE SET aa.id = 'assigns-nct00938340-' + r.k, aa.predicate = 'ASSIGNS_INTERVENTION', aa.status = 'ACCEPTED', aa.polarity = 'POSITIVE',
                aa.recordedAt = datetime('2026-10-04T01:05:00Z'), aa.contentHash = 'sha256:synthetic-assigns-nct00938340-' + r.k, aa.validFromBasis = 'UNKNOWN', aa.validToBasis = 'UNKNOWN',
                aa.createdAt = datetime('2026-10-04T01:05:00Z'), aa.privacyClass = 'PUBLIC'
MERGE (aa)-[:HAS_SUBJECT]->(arm)
MERGE (aa)-[:HAS_OBJECT]->(si)
MERGE (aa)-[:SUPPORTED_BY]->(loc)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-nct00938340-' + r.k, e.assertionUid = aa.uid, e.recordedFrom = aa.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
MERGE (am:Assertion {uid: 'hu:assertion:uses-material-nct00938340-' + r.k})
  ON CREATE SET am.id = 'uses-material-nct00938340-' + r.k, am.predicate = 'USES_INTERVENTION_MATERIAL', am.status = 'ACCEPTED', am.polarity = 'POSITIVE',
                am.recordedAt = datetime('2026-10-04T01:05:00Z'), am.contentHash = 'sha256:synthetic-uses-material-nct00938340-' + r.k, am.validFromBasis = 'UNKNOWN', am.validToBasis = 'UNKNOWN',
                am.createdAt = datetime('2026-10-04T01:05:00Z'), am.privacyClass = 'PUBLIC'
MERGE (am)-[:HAS_SUBJECT]->(ic)
MERGE (am)-[:HAS_OBJECT]->(mat)
MERGE (am)-[:SUPPORTED_BY]->(loc)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(mat)
  ON CREATE SET u.relationshipUid = 'hu:rel:uses-material-nct00938340-' + r.k, u.assertionUid = am.uid, u.recordedFrom = am.recordedAt,
                u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN', u.asReportedName = r.armName;

// 2b. Enrolled vs analyzed cohort for NCT00938340 (registry enrollment 20 vs abstract n = 15).
MATCH (st:Study {uid: 'hu:study:nct00938340-walnut-components'})
MERGE (enr:StudyPopulation:VersionedState {uid: 'hu:study-population:nct00938340-enrolled-registry'})
  ON CREATE SET enr.id = 'nct00938340-enrolled-registry', enr.stateType = 'StudyPopulation', enr.payloadHash = 'sha256:synthetic-pop-nct00938340-enrolled',
                enr.populationKind = 'ENROLLED', enr.size = 20, enr.minAge = '21 Years', enr.maxAge = '60 Years', enr.sexEligibility = 'ALL', enr.healthyVolunteers = true,
                enr.createdAt = datetime('2026-10-04T01:05:00Z'), enr.privacyClass = 'PUBLIC'
MERGE (ana:StudyPopulation:VersionedState {uid: 'hu:study-population:nct00938340-analyzed-berryman-2013'})
  ON CREATE SET ana.id = 'nct00938340-analyzed-berryman-2013', ana.stateType = 'StudyPopulation', ana.payloadHash = 'sha256:synthetic-pop-nct00938340-analyzed',
                ana.populationKind = 'ANALYZED', ana.analysisSet = 'NOT_REPORTED', ana.size = 15, ana.sizeText = 'n = 15', ana.createdAt = datetime('2026-10-04T01:05:00Z'), ana.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ENROLLED_COHORT]->(enr)
WITH ana
MATCH (res:StudyResult {uid: 'hu:study-result:berryman-2013-skins-rhi-within'})
MERGE (res)-[:HAS_ANALYZED_COHORT]->(ana);

// 3. DEVICE study: real vs sham arms using the same device model; the sham mode is the arm type, not a device identity.
MATCH (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02582593-detailed-description-nir'})
MERGE (st:Study:Entity {uid: 'hu:study:nct02582593-tnirs-older-adults'})
  ON CREATE SET st.id = 'nct02582593-tnirs-older-adults', st.entityType = 'Study', st.name = 'Revitalize Cognition: transcranial near-infrared stimulation in older adults',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:05:00Z'), st.privacyClass = 'PUBLIC'
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:ctgov-nct02582593'})
  ON CREATE SET reg.id = 'ctgov-nct02582593', reg.entityType = 'TrialRegistration', reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT02582593',
                reg.createdAt = datetime('2026-10-04T01:05:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:nct02582593-observed-2026-10-04'})
  ON CREATE SET rv.id = 'nct02582593-observed-2026-10-04', rv.artifactType = 'RegistrationVersion', rv.observedAt = datetime('2026-10-04T01:02:00Z'),
                rv.contentHash = 'synthetic:nct02582593-observed-2026-10-04', rv.overallStatus = 'COMPLETED', rv.enrollmentCount = 16, rv.resultsPosted = true,
                rv.startDate = date('2015-12-18'), rv.startDatePrecision = 'DAY', rv.primaryCompletionDate = date('2023-11-17'), rv.primaryCompletionDatePrecision = 'DAY',
                rv.completionDate = date('2023-11-17'), rv.completionDatePrecision = 'DAY', rv.phase = ['NA'], rv.studyType = 'INTERVENTIONAL',
                rv.interventionNamesVerbatim = ['MedX 1116 Rehab Console', 'Sham MedX 1116 Rehab Console'], rv.conditionsVerbatim = ['Aging'],
                rv.sponsorNameVerbatim = 'University of Florida', rv.collaboratorNamesVerbatim = ["Ed and Ethel Moore Alzheimer's Disease Research Program"],
                rv.siteCountries = ['US'], rv.createdAt = datetime('2026-10-04T01:05:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (rv)-[:SUPPORTED_BY]->(loc)
MERGE (reg)-[e:HAS_REGISTRATION_VERSION]->(rv)
  ON CREATE SET e.relationshipUid = 'hu:rel:hrv-nct02582593-2026-10-04', e.recordedFrom = datetime('2026-10-04T01:05:00Z'), e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN'
MERGE (dev:Device:Entity {uid: 'hu:device:medx-1116-rehab-console'})
  ON CREATE SET dev.id = 'medx-1116-rehab-console', dev.entityType = 'Device', dev.name = 'MedX 1116 Rehab Console', dev.createdAt = datetime('2026-10-04T01:05:00Z'), dev.privacyClass = 'PUBLIC';

UNWIND [
  {k: 'real', armName: 'Real NIR stimulation', armType: 'EXPERIMENTAL', asReported: 'MedX 1116 Rehab Console'},
  {k: 'sham', armName: 'Sham NIR stimulation', armType: 'SHAM_COMPARATOR', asReported: 'Sham MedX 1116 Rehab Console'}
] AS r
MATCH (st:Study {uid: 'hu:study:nct02582593-tnirs-older-adults'}), (dev:Device {uid: 'hu:device:medx-1116-rehab-console'}),
      (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02582593-detailed-description-nir'}), (wl:SourceLocator {uid: 'hu:locator:ctgov-nct02582593-detailed-description-wavelength'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:nct02582593-' + r.k})
  ON CREATE SET arm.id = 'nct02582593-' + r.k, arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-nct02582593-' + r.k, arm.name = r.armName,
                arm.armType = r.armType, arm.createdAt = datetime('2026-10-04T01:05:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:nct02582593-' + r.k})
  ON CREATE SET si.id = 'nct02582593-' + r.k, si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-si-nct02582593-' + r.k, si.name = r.asReported,
                si.route = 'TRANSCRANIAL', si.dosageForm = 'DEVICE_SESSION', si.schedule = 'six sessions over a 2-week period', si.durationIso = 'P2W',
                si.registryInterventionType = 'DEVICE', si.createdAt = datetime('2026-10-04T01:05:00Z'), si.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:nct02582593-' + r.k})
  ON CREATE SET ic.id = 'nct02582593-' + r.k, ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-ic-nct02582593-' + r.k,
                ic.quantity = null, ic.unitCode = null, ic.quantityBasis = null, ic.massBasis = null, ic.quantityStatus = 'NOT_APPLICABLE',
                ic.verbatimDoseText = CASE r.k WHEN 'real' THEN 'transcranial near-infrared (808-904 nm), six sessions over 2 weeks' ELSE 'sham stimulation, six sessions over 2 weeks' END,
                ic.createdAt = datetime('2026-10-04T01:05:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (aa:Assertion {uid: 'hu:assertion:assigns-nct02582593-' + r.k})
  ON CREATE SET aa.id = 'assigns-nct02582593-' + r.k, aa.predicate = 'ASSIGNS_INTERVENTION', aa.status = 'ACCEPTED', aa.polarity = 'POSITIVE', aa.recordedAt = datetime('2026-10-04T01:05:00Z'),
                aa.contentHash = 'sha256:synthetic-assigns-nct02582593-' + r.k, aa.validFromBasis = 'UNKNOWN', aa.validToBasis = 'UNKNOWN', aa.createdAt = datetime('2026-10-04T01:05:00Z'), aa.privacyClass = 'PUBLIC'
MERGE (aa)-[:HAS_SUBJECT]->(arm)
MERGE (aa)-[:HAS_OBJECT]->(si)
MERGE (aa)-[:SUPPORTED_BY]->(loc)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-nct02582593-' + r.k, e.assertionUid = aa.uid, e.recordedFrom = aa.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
MERGE (ad:Assertion {uid: 'hu:assertion:uses-device-nct02582593-' + r.k})
  ON CREATE SET ad.id = 'uses-device-nct02582593-' + r.k, ad.predicate = 'USES_INTERVENTION_DEVICE', ad.status = 'ACCEPTED', ad.polarity = 'POSITIVE', ad.recordedAt = datetime('2026-10-04T01:05:00Z'),
                ad.contentHash = 'sha256:synthetic-uses-device-nct02582593-' + r.k, ad.validFromBasis = 'UNKNOWN', ad.validToBasis = 'UNKNOWN', ad.createdAt = datetime('2026-10-04T01:05:00Z'), ad.privacyClass = 'PUBLIC'
MERGE (ad)-[:HAS_SUBJECT]->(ic)
MERGE (ad)-[:HAS_OBJECT]->(dev)
MERGE (ad)-[:SUPPORTED_BY]->(loc)
MERGE (ad)-[:SUPPORTED_BY]->(wl)
MERGE (ic)-[u:USES_INTERVENTION_DEVICE]->(dev)
  ON CREATE SET u.relationshipUid = 'hu:rel:uses-device-nct02582593-' + r.k, u.assertionUid = ad.uid, u.recordedFrom = ad.recordedAt,
                u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN', u.asReportedName = r.asReported;

// 3b. The registry's "FDA-approved as a nonsignificant risk" wording is an attributed characterization (W01 predicate
//     CHARACTERIZES_REGULATORY_STATUS), never a W13 approval (an NSR determination is not an approval; INV-010). It stays
//     PROPOSED: V-335 requires a BellLabs adjudication before such a characterization is ACCEPTED.
MATCH (dev:Device {uid: 'hu:device:medx-1116-rehab-console'}), (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02582593-detailed-description-nir'})
MERGE (org:Organization:Entity {uid: 'hu:org:university-of-florida'})
  ON CREATE SET org.id = 'university-of-florida', org.entityType = 'Organization', org.name = 'University of Florida', org.createdAt = datetime('2026-10-04T01:05:00Z'), org.privacyClass = 'PUBLIC'
MERGE (a:Assertion {uid: 'hu:assertion:uf-characterizes-medx-1116-nsr'})
  ON CREATE SET a.id = 'uf-characterizes-medx-1116-nsr', a.predicate = 'CHARACTERIZES_REGULATORY_STATUS', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
                a.valueString = 'FDA-approved as a nonsignificant risk since 2003', a.predicateClass = 'REGULATORY', a.assertionBasis = 'UNSTATED', a.speechAct = 'STATES',
                a.recordedAt = datetime('2026-10-04T01:05:00Z'), a.contentHash = 'sha256:synthetic-uf-characterizes-medx-1116-nsr', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
                a.createdAt = datetime('2026-10-04T01:05:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(dev)
MERGE (a)-[:ASSERTED_BY]->(org)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 4. PROCEDURE (SYNTHETIC): a definition-only intervention; no material or device component.
MERGE (st:Study:Entity {uid: 'hu:study:synthetic-sauna-demo'})
  ON CREATE SET st.id = 'synthetic-sauna-demo', st.entityType = 'Study', st.name = 'SYNTHETIC: repeated Finnish sauna sessions (illustrative only)',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:05:00Z'), st.privacyClass = 'PUBLIC'
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:synthetic-sauna-demo-sauna'})
  ON CREATE SET arm.id = 'synthetic-sauna-demo-sauna', arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-sauna', arm.name = 'Sauna',
                arm.armType = 'EXPERIMENTAL', arm.createdAt = datetime('2026-10-04T01:05:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:synthetic-sauna-demo-sauna'})
  ON CREATE SET si.id = 'synthetic-sauna-demo-sauna', si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-si-sauna', si.name = '20 min Finnish sauna at 80 C, 4 times per week',
                si.route = null, si.dosageForm = null, si.schedule = '4 sessions per week', si.durationIso = 'P8W', si.registryInterventionType = 'PROCEDURE',
                si.createdAt = datetime('2026-10-04T01:05:00Z'), si.privacyClass = 'PUBLIC'
MERGE (proc:Procedure:Entity {uid: 'hu:procedure:synthetic-finnish-sauna-session'})
  ON CREATE SET proc.id = 'synthetic-finnish-sauna-session', proc.entityType = 'Procedure', proc.name = 'Finnish sauna session (SYNTHETIC definition)', proc.createdAt = datetime('2026-10-04T01:05:00Z'), proc.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (aa:Assertion {uid: 'hu:assertion:assigns-synthetic-sauna'})
  ON CREATE SET aa.id = 'assigns-synthetic-sauna', aa.predicate = 'ASSIGNS_INTERVENTION', aa.status = 'PROPOSED', aa.polarity = 'POSITIVE', aa.recordedAt = datetime('2026-10-04T01:05:00Z'),
                aa.contentHash = 'sha256:synthetic-assigns-sauna', aa.validFromBasis = 'UNKNOWN', aa.validToBasis = 'UNKNOWN', aa.createdAt = datetime('2026-10-04T01:05:00Z'), aa.privacyClass = 'PUBLIC'
MERGE (aa)-[:HAS_SUBJECT]->(arm)
MERGE (aa)-[:HAS_OBJECT]->(si)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-synthetic-sauna', e.assertionUid = aa.uid, e.recordedFrom = aa.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
MERGE (af:Assertion {uid: 'hu:assertion:follows-definition-synthetic-sauna'})
  ON CREATE SET af.id = 'follows-definition-synthetic-sauna', af.predicate = 'FOLLOWS_INTERVENTION_DEFINITION', af.status = 'PROPOSED', af.polarity = 'POSITIVE',
                af.recordedAt = datetime('2026-10-04T01:05:00Z'), af.contentHash = 'sha256:synthetic-follows-sauna', af.validFromBasis = 'UNKNOWN', af.validToBasis = 'UNKNOWN',
                af.createdAt = datetime('2026-10-04T01:05:00Z'), af.privacyClass = 'PUBLIC'
MERGE (af)-[:HAS_SUBJECT]->(si)
MERGE (af)-[:HAS_OBJECT]->(proc)
MERGE (si)-[f:FOLLOWS_INTERVENTION_DEFINITION]->(proc)
  ON CREATE SET f.relationshipUid = 'hu:rel:follows-definition-synthetic-sauna', f.assertionUid = af.uid, f.recordedFrom = af.recordedAt, f.validFromBasis = 'UNKNOWN', f.validToBasis = 'UNKNOWN';

// 5. FOOD in a registered-not-completed study (NCT04985630): amount not reported -> quantity null, quantityStatus NOT_REPORTED.
MATCH (st:Study {uid: 'hu:study:nct04985630-mitopure-dbs'}), (loc:SourceLocator {uid: 'hu:locator:ctgov-nct04985630-2026-10-04-record'})
MERGE (arm:StudyArm:VersionedState {uid: 'hu:arm:nct04985630-challenge'})
  ON CREATE SET arm.id = 'nct04985630-challenge', arm.stateType = 'StudyArm', arm.payloadHash = 'sha256:synthetic-arm-nct04985630', arm.name = 'Mitopure Challenge (open label)',
                arm.armType = 'EXPERIMENTAL', arm.createdAt = datetime('2026-10-04T01:05:00Z'), arm.privacyClass = 'PUBLIC'
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:nct04985630-pomegranate-juice'})
  ON CREATE SET si.id = 'nct04985630-pomegranate-juice', si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-si-nct04985630-pj', si.name = 'Pomegranate Juice',
                si.route = 'ORAL', si.dosageForm = 'BEVERAGE', si.createdAt = datetime('2026-10-04T01:05:00Z'), si.privacyClass = 'PUBLIC'
MERGE (mat:IngredientMaterial:Entity {uid: 'hu:material:pomegranate-juice-nct04985630'})
  ON CREATE SET mat.id = 'pomegranate-juice-nct04985630', mat.entityType = 'IngredientMaterial', mat.name = 'Pomegranate juice as provided in NCT04985630 (product unspecified)',
                mat.createdAt = datetime('2026-10-04T01:05:00Z'), mat.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:nct04985630-pomegranate-juice'})
  ON CREATE SET ic.id = 'nct04985630-pomegranate-juice', ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-ic-nct04985630-pj',
                ic.quantity = null, ic.unitCode = null, ic.quantityBasis = null, ic.massBasis = null, ic.quantityStatus = 'NOT_REPORTED', ic.verbatimDoseText = null,
                ic.createdAt = datetime('2026-10-04T01:05:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (st)-[:HAS_ARM]->(arm)
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (aa:Assertion {uid: 'hu:assertion:assigns-nct04985630-pomegranate-juice'})
  ON CREATE SET aa.id = 'assigns-nct04985630-pomegranate-juice', aa.predicate = 'ASSIGNS_INTERVENTION', aa.status = 'ACCEPTED', aa.polarity = 'POSITIVE', aa.recordedAt = datetime('2026-10-04T01:05:00Z'),
                aa.contentHash = 'sha256:synthetic-assigns-nct04985630-pj', aa.validFromBasis = 'UNKNOWN', aa.validToBasis = 'UNKNOWN', aa.createdAt = datetime('2026-10-04T01:05:00Z'), aa.privacyClass = 'PUBLIC'
MERGE (aa)-[:HAS_SUBJECT]->(arm)
MERGE (aa)-[:HAS_OBJECT]->(si)
MERGE (aa)-[:SUPPORTED_BY]->(loc)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-nct04985630-pomegranate-juice', e.assertionUid = aa.uid, e.recordedFrom = aa.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
MERGE (am:Assertion {uid: 'hu:assertion:uses-material-nct04985630-pomegranate-juice'})
  ON CREATE SET am.id = 'uses-material-nct04985630-pomegranate-juice', am.predicate = 'USES_INTERVENTION_MATERIAL', am.status = 'ACCEPTED', am.polarity = 'POSITIVE',
                am.recordedAt = datetime('2026-10-04T01:05:00Z'), am.contentHash = 'sha256:synthetic-uses-material-nct04985630-pj', am.validFromBasis = 'UNKNOWN', am.validToBasis = 'UNKNOWN',
                am.createdAt = datetime('2026-10-04T01:05:00Z'), am.privacyClass = 'PUBLIC'
MERGE (am)-[:HAS_SUBJECT]->(ic)
MERGE (am)-[:HAS_OBJECT]->(mat)
MERGE (am)-[:SUPPORTED_BY]->(loc)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(mat)
  ON CREATE SET u.relationshipUid = 'hu:rel:uses-material-nct04985630-pomegranate-juice', u.assertionUid = am.uid, u.recordedFrom = am.recordedAt,
                u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN', u.asReportedName = 'Pomegranate Juice';

// 6. Capture-fidelity policy adjudication (the synthetic sauna assertions stay PROPOSED and are not adjudicated).
MATCH (a:Assertion) WHERE (a.uid STARTS WITH 'hu:assertion:assigns-nct00938340-' OR a.uid STARTS WITH 'hu:assertion:uses-material-nct00938340-'
   OR a.uid STARTS WITH 'hu:assertion:assigns-nct02582593-' OR a.uid STARTS WITH 'hu:assertion:uses-device-nct02582593-'
   OR a.uid IN ['hu:assertion:assigns-nct04985630-pomegranate-juice', 'hu:assertion:uses-material-nct04985630-pomegranate-juice'])
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-04-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-04-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:05:00Z'), j.recordedAt = datetime('2026-10-04T01:05:00Z'), j.createdAt = datetime('2026-10-04T01:05:00Z'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a);
