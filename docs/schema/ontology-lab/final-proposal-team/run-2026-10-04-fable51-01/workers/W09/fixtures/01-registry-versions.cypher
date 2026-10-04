// =====================================================================================================================
// W09 fixture 01: registry identity vs registry versions; registered-not-completed vs results-posted.
// Real records: NCT02678611, NCT00938340, NCT04985630, retrieved 2026-10-04 through the ClinicalTrials.gov MCP (current
// version only; history BLOCKED, see 03-source-manifest.md S-01/S-02). One SYNTHETIC registration (hu:...:synthetic-*) shows
// how two observed versions become EXCLUSIVE bitemporal episodes (round 0007 Delta B shape).
// Every statement binds its own nodes by uid; no variable crosses ';'. Snapshot hashes are SYNTHETIC_FIXTURE.
// Expected: V-210, V-211 zero rows; QS-W09-01 rows as documented in 06-fixtures-and-queries.md.
// =====================================================================================================================

// 1. Sources, snapshots, locators for the three registry records (MCP field excerpt => PARTIAL_EXCERPT).
UNWIND [
  {nct: 'NCT02678611', src: 'hu:source:ctgov-nct02678611', snap: 'hu:snapshot:ctgov-nct02678611-2026-10-04', loc: 'hu:locator:ctgov-nct02678611-2026-10-04-record'},
  {nct: 'NCT00938340', src: 'hu:source:ctgov-nct00938340', snap: 'hu:snapshot:ctgov-nct00938340-2026-10-04', loc: 'hu:locator:ctgov-nct00938340-2026-10-04-record'},
  {nct: 'NCT04985630', src: 'hu:source:ctgov-nct04985630', snap: 'hu:snapshot:ctgov-nct04985630-2026-10-04', loc: 'hu:locator:ctgov-nct04985630-2026-10-04-record'}
] AS r
MERGE (src:Source:Entity {uid: r.src})
  ON CREATE SET src.id = split(r.src, ':')[2], src.entityType = 'Source', src.canonicalUri = 'https://clinicaltrials.gov/study/' + r.nct,
                src.title = 'ClinicalTrials.gov ' + r.nct, src.sourceKind = 'REGULATORY_RECORD', src.createdAt = datetime('2026-10-04T01:00:00Z'), src.privacyClass = 'PUBLIC'
MERGE (snap:SourceSnapshot:InformationArtifact {uid: r.snap})
  ON CREATE SET snap.id = split(r.snap, ':')[2], snap.artifactType = 'SourceSnapshot', snap.canonicalUri = 'https://clinicaltrials.gov/study/' + r.nct,
                snap.retrievedAt = datetime('2026-10-04T00:55:00Z'), snap.observedAt = datetime('2026-10-04T00:55:00Z'),
                snap.contentHash = 'synthetic:' + r.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'PARTIAL_EXCERPT',
                snap.createdAt = datetime('2026-10-04T01:00:00Z'), snap.privacyClass = 'PUBLIC'
MERGE (loc:SourceLocator:InformationArtifact {uid: r.loc})
  ON CREATE SET loc.id = split(r.loc, ':')[2], loc.artifactType = 'SourceLocator', loc.uri = 'https://clinicaltrials.gov/study/' + r.nct,
                loc.selectorKind = 'WHOLE_SNAPSHOT', loc.createdAt = datetime('2026-10-04T01:00:00Z'), loc.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// 2. NCT02678611: completed, results NOT posted on the registry (a results paper exists: fixture 07). versionDate unknown.
MATCH (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-record'})
MERGE (st:Study:Entity {uid: 'hu:study:nct02678611-basis-nrpt'})
  ON CREATE SET st.id = 'nct02678611-basis-nrpt', st.entityType = 'Study', st.name = 'Repeat-dose NRPT in healthy adults aged 60 to 80',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:ctgov-nct02678611'})
  ON CREATE SET reg.id = 'ctgov-nct02678611', reg.entityType = 'TrialRegistration', reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT02678611',
                reg.createdAt = datetime('2026-10-04T01:00:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:nct02678611-observed-2026-10-04'})
  ON CREATE SET rv.id = 'nct02678611-observed-2026-10-04', rv.artifactType = 'RegistrationVersion',
                rv.observedAt = datetime('2026-10-04T00:55:00Z'), rv.contentHash = 'synthetic:nct02678611-observed-2026-10-04',
                rv.versionDate = null, rv.registryVersionNumber = null, rv.lastUpdatePostedDate = null,
                rv.briefTitle = 'A Study to Evaluate Safety and Health Benefits of Basis™ Among Elderly Subjects.', rv.acronym = '15BSHE',
                rv.overallStatus = 'COMPLETED', rv.enrollmentCount = 120, rv.enrollmentCountType = null,
                rv.resultsPosted = false,
                rv.startDate = date('2016-01-01'), rv.startDatePrecision = 'MONTH', rv.startDateType = null,
                rv.primaryCompletionDate = date('2016-07-01'), rv.primaryCompletionDatePrecision = 'MONTH', rv.primaryCompletionDateType = null,
                rv.completionDate = null,
                rv.studyType = 'INTERVENTIONAL', rv.phase = ['PHASE1'], rv.siteCountries = ['CA'],
                rv.conditionsVerbatim = ['Safety: Healthy Subjects'], rv.interventionNamesVerbatim = ['Basis 250', 'Basis 500', 'Placebo'],
                rv.sponsorNameVerbatim = 'Elysium Health', rv.collaboratorNamesVerbatim = ['KGK Science Inc.'],
                rv.createdAt = datetime('2026-10-04T01:00:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (rv)-[:SUPPORTED_BY]->(loc)
MERGE (reg)-[e:HAS_REGISTRATION_VERSION]->(rv)
  ON CREATE SET e.relationshipUid = 'hu:rel:hrv-nct02678611-2026-10-04', e.recordedFrom = datetime('2026-10-04T01:00:00Z'),
                e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN';

// 3. REGISTERED_AS for NCT02678611 (asserted edge = projection of one assertion).
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (reg:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct02678611'}),
      (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-record'})
MERGE (a:Assertion {uid: 'hu:assertion:registered-as-nct02678611'})
  ON CREATE SET a.id = 'registered-as-nct02678611', a.predicate = 'REGISTERED_AS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-registered-as-nct02678611',
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(reg)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[e:REGISTERED_AS]->(reg)
  ON CREATE SET e.relationshipUid = 'hu:rel:registered-as-nct02678611', e.assertionUid = a.uid, e.recordedFrom = a.recordedAt,
                e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// 4. NCT00938340: completed, results POSTED (resultsFirstPostedDate not returned by the tool: null, not invented).
MATCH (loc:SourceLocator {uid: 'hu:locator:ctgov-nct00938340-2026-10-04-record'})
MERGE (st:Study:Entity {uid: 'hu:study:nct00938340-walnut-components'})
  ON CREATE SET st.id = 'nct00938340-walnut-components', st.entityType = 'Study', st.name = 'Postprandial effects of walnut components vs whole walnuts',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:ctgov-nct00938340'})
  ON CREATE SET reg.id = 'ctgov-nct00938340', reg.entityType = 'TrialRegistration', reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT00938340',
                reg.createdAt = datetime('2026-10-04T01:00:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:nct00938340-observed-2026-10-04'})
  ON CREATE SET rv.id = 'nct00938340-observed-2026-10-04', rv.artifactType = 'RegistrationVersion', rv.observedAt = datetime('2026-10-04T00:55:00Z'),
                rv.contentHash = 'synthetic:nct00938340-observed-2026-10-04',
                rv.overallStatus = 'COMPLETED', rv.enrollmentCount = 20, rv.enrollmentCountType = null, rv.resultsPosted = true, rv.resultsFirstPostedDate = null,
                rv.startDate = date('2007-08-01'), rv.startDatePrecision = 'MONTH',
                rv.primaryCompletionDate = date('2009-02-01'), rv.primaryCompletionDatePrecision = 'MONTH',
                rv.completionDate = date('2009-05-01'), rv.completionDatePrecision = 'MONTH',
                rv.studyType = 'INTERVENTIONAL', rv.phase = ['NA'], rv.siteCountries = ['US'], rv.conditionsVerbatim = ['Cardiovascular Disease'],
                rv.interventionNamesVerbatim = ['Walnut "meat"', 'Walnut Oil', 'Walnut Skins', 'Whole walnut'],
                rv.sponsorNameVerbatim = 'Penn State University', rv.collaboratorNamesVerbatim = ['California Walnut Commission'],
                rv.createdAt = datetime('2026-10-04T01:00:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (rv)-[:SUPPORTED_BY]->(loc)
MERGE (reg)-[e:HAS_REGISTRATION_VERSION]->(rv)
  ON CREATE SET e.relationshipUid = 'hu:rel:hrv-nct00938340-2026-10-04', e.recordedFrom = datetime('2026-10-04T01:00:00Z'),
                e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN'
MERGE (a:Assertion {uid: 'hu:assertion:registered-as-nct00938340'})
  ON CREATE SET a.id = 'registered-as-nct00938340', a.predicate = 'REGISTERED_AS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-registered-as-nct00938340',
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(reg)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[r2:REGISTERED_AS]->(reg)
  ON CREATE SET r2.relationshipUid = 'hu:rel:registered-as-nct00938340', r2.assertionUid = a.uid, r2.recordedFrom = a.recordedAt,
                r2.validFromBasis = 'UNKNOWN', r2.validToBasis = 'UNKNOWN';

// 5. NCT04985630: registered, NOT completed (RECRUITING on 2026-10-04 although the displayed primary completion date
//    2026-07-31 has passed). The tool does not say whether dates are ACTUAL or ANTICIPATED: date types stay null.
MATCH (loc:SourceLocator {uid: 'hu:locator:ctgov-nct04985630-2026-10-04-record'})
MERGE (st:Study:Entity {uid: 'hu:study:nct04985630-mitopure-dbs'})
  ON CREATE SET st.id = 'nct04985630-mitopure-dbs', st.entityType = 'Study', st.name = 'The Mitopure Challenge: urolithin A in dried blood spots',
                st.studyKind = 'INTERVENTIONAL_SINGLE_GROUP', st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:ctgov-nct04985630'})
  ON CREATE SET reg.id = 'ctgov-nct04985630', reg.entityType = 'TrialRegistration', reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT04985630',
                reg.createdAt = datetime('2026-10-04T01:00:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:nct04985630-observed-2026-10-04'})
  ON CREATE SET rv.id = 'nct04985630-observed-2026-10-04', rv.artifactType = 'RegistrationVersion', rv.observedAt = datetime('2026-10-04T00:55:00Z'),
                rv.contentHash = 'synthetic:nct04985630-observed-2026-10-04',
                rv.overallStatus = 'RECRUITING', rv.enrollmentCount = 250, rv.enrollmentCountType = null, rv.resultsPosted = false,
                rv.startDate = date('2021-08-30'), rv.startDatePrecision = 'DAY', rv.startDateType = null,
                rv.primaryCompletionDate = date('2026-07-31'), rv.primaryCompletionDatePrecision = 'DAY', rv.primaryCompletionDateType = null,
                rv.completionDate = date('2026-08-31'), rv.completionDatePrecision = 'DAY', rv.completionDateType = null,
                rv.studyType = 'INTERVENTIONAL', rv.phase = ['NA'], rv.siteCountries = ['US'],
                rv.conditionsVerbatim = ['Healthy Aging', 'Healthy', 'Healthy Diet'], rv.interventionNamesVerbatim = ['Mitopure', 'Pomegranate Juice'],
                rv.sponsorNameVerbatim = 'Amazentis SA', rv.createdAt = datetime('2026-10-04T01:00:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (rv)-[:SUPPORTED_BY]->(loc)
MERGE (reg)-[e:HAS_REGISTRATION_VERSION]->(rv)
  ON CREATE SET e.relationshipUid = 'hu:rel:hrv-nct04985630-2026-10-04', e.recordedFrom = datetime('2026-10-04T01:00:00Z'),
                e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN'
MERGE (a:Assertion {uid: 'hu:assertion:registered-as-nct04985630'})
  ON CREATE SET a.id = 'registered-as-nct04985630', a.predicate = 'REGISTERED_AS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-registered-as-nct04985630',
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(reg)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[r2:REGISTERED_AS]->(reg)
  ON CREATE SET r2.relationshipUid = 'hu:rel:registered-as-nct04985630', r2.assertionUid = a.uid, r2.recordedFrom = a.recordedAt,
                r2.validFromBasis = 'UNKNOWN', r2.validToBasis = 'UNKNOWN';

// 6. SYNTHETIC registration with two observed versions (EXCLUSIVE episodes). v1 observed 2026-05-01 RECRUITING; v2 observed
//    2026-09-01 COMPLETED with results posted; the registry history (synthetic) dates v2 to 2026-08-15. On 2026-09-01 the
//    v1 episode is closed in recorded time and re-asserted with a stated validTo (VALIDITY_BOUNDED), never rewritten.
MERGE (reg:TrialRegistration:Entity {uid: 'hu:trial-registration:synthetic-demo-001'})
  ON CREATE SET reg.id = 'synthetic-demo-001', reg.entityType = 'TrialRegistration', reg.registry = 'SYNTHETIC', reg.registrationId = 'DEMO-001',
                reg.createdAt = datetime('2026-05-01T00:00:00Z'), reg.privacyClass = 'PUBLIC'
MERGE (v1:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:synthetic-demo-001-v1'})
  ON CREATE SET v1.id = 'synthetic-demo-001-v1', v1.artifactType = 'RegistrationVersion', v1.observedAt = datetime('2026-05-01T00:00:00Z'),
                v1.registryVersionNumber = 1, v1.overallStatus = 'RECRUITING', v1.enrollmentCount = 60, v1.enrollmentCountType = 'ESTIMATED',
                v1.resultsPosted = false, v1.primaryCompletionDate = date('2026-07-01'), v1.primaryCompletionDatePrecision = 'MONTH',
                v1.primaryCompletionDateType = 'ANTICIPATED', v1.contentHash = 'synthetic:synthetic-demo-001-v1', v1.createdAt = datetime('2026-05-01T00:00:00Z'), v1.privacyClass = 'PUBLIC'
MERGE (v2:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:synthetic-demo-001-v2'})
  ON CREATE SET v2.id = 'synthetic-demo-001-v2', v2.artifactType = 'RegistrationVersion', v2.observedAt = datetime('2026-09-01T00:00:00Z'),
                v2.versionDate = date('2026-08-15'), v2.registryVersionNumber = 2, v2.overallStatus = 'COMPLETED', v2.enrollmentCount = 58,
                v2.enrollmentCountType = 'ACTUAL', v2.resultsPosted = true, v2.resultsFirstPostedDate = date('2026-08-15'),
                v2.primaryCompletionDate = date('2026-07-10'), v2.primaryCompletionDatePrecision = 'DAY', v2.primaryCompletionDateType = 'ACTUAL',
                v2.contentHash = 'synthetic:synthetic-demo-001-v2', v2.createdAt = datetime('2026-09-01T00:00:00Z'), v2.privacyClass = 'PUBLIC'
MERGE (reg)-[e1:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:hrv-synthetic-demo-001-v1-e1'}]->(v1)
  ON CREATE SET e1.recordedFrom = datetime('2026-05-01T00:00:00Z'), e1.recordedTo = datetime('2026-09-01T00:00:00Z'),
                e1.validFromBasis = 'OBSERVATION_ONLY', e1.validToBasis = 'UNKNOWN'
MERGE (reg)-[e1b:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:hrv-synthetic-demo-001-v1-e1b'}]->(v1)
  ON CREATE SET e1b.recordedFrom = datetime('2026-09-01T00:00:00Z'), e1b.validFromBasis = 'OBSERVATION_ONLY',
                e1b.validTo = datetime('2026-08-15T00:00:00Z'), e1b.validToPrecision = 'DAY', e1b.validToBasis = 'STATED_BY_SOURCE'
MERGE (reg)-[e2:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:hrv-synthetic-demo-001-v2-e2'}]->(v2)
  ON CREATE SET e2.recordedFrom = datetime('2026-09-01T00:00:00Z'), e2.validFrom = datetime('2026-08-15T00:00:00Z'),
                e2.validFromPrecision = 'DAY', e2.validFromBasis = 'STATED_BY_SOURCE', e2.validToBasis = 'UNKNOWN';

// 7. Derived Study cache (INV-208): allowed only with projectionOfRegistrationVersionUid.
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (rv:RegistrationVersion {uid: 'hu:registration-version:nct02678611-observed-2026-10-04'})
SET st.overallStatus = rv.overallStatus, st.enrollmentCount = rv.enrollmentCount, st.projectionOfRegistrationVersionUid = rv.uid;

// 8. Capture-fidelity policy adjudication for this fixture's assertions (INV-103; says nothing about truth).
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:registered-as-nct02678611', 'hu:assertion:registered-as-nct00938340', 'hu:assertion:registered-as-nct04985630']
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-01-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-01-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:00:00Z'), j.recordedAt = datetime('2026-10-04T01:00:00Z'), j.createdAt = datetime('2026-10-04T01:00:00Z'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a);
