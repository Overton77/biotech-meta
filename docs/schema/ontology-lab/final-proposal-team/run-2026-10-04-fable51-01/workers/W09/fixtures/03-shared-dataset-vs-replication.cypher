// =====================================================================================================================
// W09 fixture 03: shared dataset vs independent replication (CQ-ST-07, CQ-AX-05, V-218).
// Real: NCT00938340 with two publications that both cite it (Berryman 2013 PMID 23616506 = primary report, n = 15
// crossover; Zhang 2011 PMID 21871057 = sera "from subjects in a walnut feeding study", ClinicalTrials.gov NCT00938340,
// published BEFORE the primary report). Independent line: ATLAS (fixture 02) and ENERGIZE NCT03283462 / PMID 35050355.
// ATLAS and ENERGIZE share the sponsor Amazentis (registry), so they are dataset-independent but not sponsor-independent.
// PubMed metadata retrieved 2026-10-04 (MCP); ENERGIZE registry search row (sponsor Amazentis SA, enrollment 66) retrieved 2026-10-04 (MCP).
// Expected on this file (+ fixture 02 loaded): V-218 0 rows; V-215r 0 rows; QS-W09-07 returns 1 dependent pair; QS-W09-08 returns the shared sponsor.
// =====================================================================================================================

// 1. Sources/snapshots/locators for the three PubMed records and the ENERGIZE PMC extract.
UNWIND [
  {src: 'hu:source:pubmed-23616506', uri: 'https://pubmed.ncbi.nlm.nih.gov/23616506/', snap: 'hu:snapshot:pubmed-23616506-2026-10-04', loc: 'hu:locator:pubmed-23616506-abstract', exact: 'A randomized, 4-period, crossover trial was conducted in healthy overweight and obese adults (n = 15) with moderate hypercholesterolemia.'},
  {src: 'hu:source:pubmed-21871057', uri: 'https://pubmed.ncbi.nlm.nih.gov/21871057/', snap: 'hu:snapshot:pubmed-21871057-2026-10-04', loc: 'hu:locator:pubmed-21871057-abstract', exact: 'THP-1 MDFC also were treated with human sera (10%, v:v) taken from subjects in a walnut feeding study.'},
  {src: 'hu:source:ctgov-nct03283462', uri: 'https://clinicaltrials.gov/study/NCT03283462', snap: 'hu:snapshot:ctgov-nct03283462-2026-10-04', loc: 'hu:locator:ctgov-nct03283462-2026-10-04-record', exact: null},
  {src: 'hu:source:pmc8777576', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC8777576/', snap: 'hu:snapshot:pmc8777576-2026-10-04', loc: 'hu:locator:pmc8777576-results-endurance', exact: 'At the 2-month visit, urolithin A supplementation significantly improved endurance in both muscles compared with placebo'}
] AS r
MERGE (src:Source:Entity {uid: r.src})
  ON CREATE SET src.id = split(r.src, ':')[2], src.entityType = 'Source', src.canonicalUri = r.uri, src.sourceKind = CASE WHEN r.exact IS NULL THEN 'REGULATORY_RECORD' ELSE 'PEER_REVIEWED_PUBLICATION' END, src.createdAt = datetime('2026-10-04T01:00:00Z'), src.privacyClass = 'PUBLIC'
MERGE (snap:SourceSnapshot:InformationArtifact {uid: r.snap})
  ON CREATE SET snap.id = split(r.snap, ':')[2], snap.artifactType = 'SourceSnapshot', snap.canonicalUri = r.uri, snap.retrievedAt = datetime('2026-10-04T00:59:00Z'),
                snap.observedAt = datetime('2026-10-04T00:59:00Z'), snap.contentHash = 'synthetic:' + r.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE',
                snap.captureCompleteness = 'PARTIAL_EXCERPT', snap.createdAt = datetime('2026-10-04T01:00:00Z'), snap.privacyClass = 'PUBLIC'
MERGE (loc:SourceLocator:InformationArtifact {uid: r.loc})
  ON CREATE SET loc.id = split(r.loc, ':')[2], loc.artifactType = 'SourceLocator', loc.uri = r.uri, loc.selectorKind = CASE WHEN r.exact IS NULL THEN 'WHOLE_SNAPSHOT' ELSE 'TEXT_QUOTE' END, loc.exact = r.exact,
                loc.createdAt = datetime('2026-10-04T01:00:00Z'), loc.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// 2. Walnut study, its dataset, and the two publications that analyze it.
MERGE (st:Study:Entity {uid: 'hu:study:nct00938340-walnut-components'})
  ON CREATE SET st.id = 'nct00938340-walnut-components', st.entityType = 'Study', st.name = 'Postprandial effects of walnut components vs whole walnuts',
                st.studyKind = 'INTERVENTIONAL_RANDOMIZED', st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (ds:Dataset:Entity {uid: 'hu:dataset:nct00938340-participant-data-and-sera'})
  ON CREATE SET ds.id = 'nct00938340-participant-data-and-sera', ds.entityType = 'Dataset', ds.name = 'NCT00938340 participant data and postprandial sera',
                ds.datasetKind = 'TRIAL_PARTICIPANT_DATA_AND_BIOSPECIMENS', ds.accessLevel = 'UNKNOWN', ds.createdAt = datetime('2026-10-04T01:00:00Z'), ds.privacyClass = 'PUBLIC'
MERGE (p1:Publication:InformationArtifact {uid: 'hu:publication:pmid-23616506'})
  ON CREATE SET p1.id = 'pmid-23616506', p1.artifactType = 'Publication', p1.publicationKind = 'ARTICLE', p1.doi = '10.3945/jn.112.170993', p1.pmid = '23616506',
                p1.pmcid = 'PMC3652880', p1.venueName = 'The Journal of nutrition', p1.publishedAt = datetime('2013-04-24T00:00:00Z'), p1.publishedAtPrecision = 'DAY',
                p1.name = 'Acute consumption of walnuts and walnut components differentially affect postprandial lipemia, endothelial function, oxidative stress, and cholesterol efflux in humans with mild hypercholesterolemia',
                p1.createdAt = datetime('2026-10-04T01:00:00Z'), p1.privacyClass = 'PUBLIC'
MERGE (p2:Publication:InformationArtifact {uid: 'hu:publication:pmid-21871057'})
  ON CREATE SET p2.id = 'pmid-21871057', p2.artifactType = 'Publication', p2.publicationKind = 'ARTICLE', p2.doi = '10.1186/1743-7075-8-61', p2.pmid = '21871057',
                p2.pmcid = 'PMC3180353', p2.venueName = 'Nutrition & metabolism', p2.publishedAt = datetime('2011-08-26T00:00:00Z'), p2.publishedAtPrecision = 'DAY',
                p2.name = 'Walnut oil increases cholesterol efflux through inhibition of stearoyl CoA desaturase 1 in THP-1 macrophage-derived foam cells',
                p2.createdAt = datetime('2026-10-04T01:00:00Z'), p2.privacyClass = 'PUBLIC';

// 3. Asserted edges REPORTS_ON / PRODUCED_DATASET / ANALYZES_DATASET with their assertions.
UNWIND [
  {a: 'hu:assertion:produced-dataset-nct00938340', pred: 'PRODUCED_DATASET', s: 'hu:study:nct00938340-walnut-components', o: 'hu:dataset:nct00938340-participant-data-and-sera', loc: 'hu:locator:pubmed-23616506-abstract', role: null},
  {a: 'hu:assertion:reports-on-23616506-nct00938340', pred: 'REPORTS_ON', s: 'hu:publication:pmid-23616506', o: 'hu:study:nct00938340-walnut-components', loc: 'hu:locator:pubmed-23616506-abstract', role: null},
  {a: 'hu:assertion:reports-on-21871057-nct00938340', pred: 'REPORTS_ON', s: 'hu:publication:pmid-21871057', o: 'hu:study:nct00938340-walnut-components', loc: 'hu:locator:pubmed-21871057-abstract', role: null},
  {a: 'hu:assertion:analyzes-23616506-ds', pred: 'ANALYZES_DATASET', s: 'hu:publication:pmid-23616506', o: 'hu:dataset:nct00938340-participant-data-and-sera', loc: 'hu:locator:pubmed-23616506-abstract', role: 'PRIMARY_REPORT'},
  {a: 'hu:assertion:analyzes-21871057-ds', pred: 'ANALYZES_DATASET', s: 'hu:publication:pmid-21871057', o: 'hu:dataset:nct00938340-participant-data-and-sera', loc: 'hu:locator:pubmed-21871057-abstract', role: 'SECONDARY_ANALYSIS'}
] AS r
MATCH (s {uid: r.s}), (o {uid: r.o}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
  ON CREATE SET a.id = split(r.a, ':')[2], a.predicate = r.pred, a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-' + split(r.a, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(loc)
WITH a, s, o, r
CALL {
  WITH a, s, o, r
  WITH a, s, o, r WHERE r.pred = 'PRODUCED_DATASET'
  MERGE (s)-[e:PRODUCED_DATASET]->(o) ON CREATE SET e.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2], e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
  RETURN count(*) AS c1
}
CALL {
  WITH a, s, o, r
  WITH a, s, o, r WHERE r.pred = 'REPORTS_ON'
  MERGE (s)-[e:REPORTS_ON]->(o) ON CREATE SET e.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2], e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
  RETURN count(*) AS c2
}
CALL {
  WITH a, s, o, r
  WITH a, s, o, r WHERE r.pred = 'ANALYZES_DATASET'
  MERGE (s)-[e:ANALYZES_DATASET]->(o) ON CREATE SET e.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2], e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.analysisRole = r.role
  RETURN count(*) AS c3
}
RETURN count(*) AS edges;

// 4. DOI/PMID as Identifier records (identity_resolution) plus materialized keys on Publication.
UNWIND [
  {pub: 'hu:publication:pmid-23616506', scheme: 'DOI', issuer: 'doi.org', value: '10.3945/jn.112.170993'},
  {pub: 'hu:publication:pmid-23616506', scheme: 'PMID', issuer: 'NLM', value: '23616506'},
  {pub: 'hu:publication:pmid-21871057', scheme: 'DOI', issuer: 'doi.org', value: '10.1186/1743-7075-8-61'},
  {pub: 'hu:publication:pmid-21871057', scheme: 'PMID', issuer: 'NLM', value: '21871057'}
] AS r
MATCH (p:Publication {uid: r.pub}), (loc:SourceLocator) WHERE loc.uid = 'hu:locator:pubmed-' + p.pmid + '-abstract'
MERGE (i:Identifier:Entity {uid: 'hu:identifier:' + toLower(r.scheme) + '-' + replace(replace(r.value, '/', '-'), '.', '-')})
  ON CREATE SET i.id = toLower(r.scheme) + '-' + replace(replace(r.value, '/', '-'), '.', '-'), i.entityType = 'Identifier', i.scheme = r.scheme, i.issuer = r.issuer,
                i.value = r.value, i.createdAt = datetime('2026-10-04T01:00:00Z'), i.privacyClass = 'PUBLIC'
MERGE (a:Assertion {uid: 'hu:assertion:has-identifier-' + i.id})
  ON CREATE SET a.id = 'has-identifier-' + i.id, a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:00:00Z'),
                a.contentHash = 'sha256:synthetic-has-identifier-' + i.id, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(i)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (p)-[e:HAS_IDENTIFIER]->(i)
  ON CREATE SET e.relationshipUid = 'hu:rel:has-identifier-' + i.id, e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN',
                e.isPrimary = (r.scheme = 'DOI');

// 5. One result per walnut publication (both under the same Study).
UNWIND [
  {od: 'hu:outcome:nct00938340-rhi-240min', odName: 'Reactive hyperemia index change at 240 min', mk: 'BIOMARKER',
   res: 'hu:study-result:berryman-2013-skins-rhi-within', ak: 'SECONDARY_PRESPECIFIED', ck: 'WITHIN_ARM_CHANGE', sc: 'SIGNIFICANT_UNFAVORABLE', p: 0.02, loc: 'hu:locator:pubmed-23616506-abstract',
   txt: 'Walnut skins decreased the reactive hyperemia index (RHI) compared with baseline (P = 0.02)'},
  {od: 'hu:outcome:nct00938340-cholesterol-efflux-exvivo', odName: 'Cholesterol efflux in macrophage-derived foam cells treated with postprandial sera (ex vivo)', mk: 'BIOMARKER',
   res: 'hu:study-result:zhang-2011-postprandial-sera-efflux', ak: 'EXPLORATORY', ck: 'WITHIN_ARM_CHANGE', sc: 'SIGNIFICANT_FAVORABLE', p: null, loc: 'hu:locator:pubmed-21871057-abstract',
   txt: 'Postprandial serum treatment also increased cholesterol efflux in MDFC.'}
] AS r
MATCH (st:Study {uid: 'hu:study:nct00938340-walnut-components'}), (loc:SourceLocator {uid: r.loc})
MERGE (od:OutcomeDefinition:VersionedState {uid: r.od})
  ON CREATE SET od.id = split(r.od, ':')[2], od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:synthetic-' + split(r.od, ':')[2], od.name = r.odName,
                od.measureKind = r.mk, od.createdAt = datetime('2026-10-04T01:00:00Z'), od.privacyClass = 'PUBLIC'
MERGE (st)-[:DEFINES_OUTCOME]->(od)
MERGE (res:StudyResult:InformationArtifact {uid: r.res})
  ON CREATE SET res.id = split(r.res, ':')[2], res.artifactType = 'StudyResult', res.analysisKind = r.ak, res.comparisonKind = r.ck, res.statisticalConclusion = r.sc,
                res.pValue = r.p, res.resultText = r.txt, res.isStatisticallySignificant = true, res.createdAt = datetime('2026-10-04T01:00:00Z'), res.privacyClass = 'PUBLIC'
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:SUPPORTED_BY]->(loc);

// 6. ENERGIZE (independent dataset, same sponsor as ATLAS).
MATCH (loc:SourceLocator {uid: 'hu:locator:pmc8777576-results-endurance'})
MERGE (st:Study:Entity {uid: 'hu:study:nct03283462-energize'})
  ON CREATE SET st.id = 'nct03283462-energize', st.entityType = 'Study', st.name = 'ENERGIZE: urolithin A in older adults', st.studyKind = 'INTERVENTIONAL_RANDOMIZED',
                st.createdAt = datetime('2026-10-04T01:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (pub:Publication:InformationArtifact {uid: 'hu:publication:pmid-35050355'})
  ON CREATE SET pub.id = 'pmid-35050355', pub.artifactType = 'Publication', pub.publicationKind = 'ARTICLE', pub.doi = '10.1001/jamanetworkopen.2021.44279',
                pub.pmid = '35050355', pub.pmcid = 'PMC8777576', pub.venueName = 'JAMA Network Open', pub.createdAt = datetime('2026-10-04T01:00:00Z'), pub.privacyClass = 'PUBLIC'
MERGE (od:OutcomeDefinition:VersionedState {uid: 'hu:outcome:energize-fdi-endurance-2m'})
  ON CREATE SET od.id = 'energize-fdi-endurance-2m', od.stateType = 'OutcomeDefinition', od.payloadHash = 'sha256:synthetic-energize-fdi-endurance-2m',
                od.name = 'Hand (FDI) and leg (TA) muscle endurance, repeated contractions to 70% MVC', od.measureKind = 'PERFORMANCE_OUTCOME', od.createdAt = datetime('2026-10-04T01:00:00Z'), od.privacyClass = 'PUBLIC'
MERGE (st)-[:DEFINES_OUTCOME]->(od)
MERGE (res:StudyResult:InformationArtifact {uid: 'hu:study-result:energize-endurance-ua-vs-placebo-2m'})
  ON CREATE SET res.id = 'energize-endurance-ua-vs-placebo-2m', res.artifactType = 'StudyResult', res.analysisKind = 'SECONDARY_PRESPECIFIED', res.comparisonKind = 'BETWEEN_ARM',
                res.statisticalConclusion = 'SIGNIFICANT_FAVORABLE', res.isStatisticallySignificant = true, res.timepoint = '2-month visit',
                res.resultText = 'urolithin A supplementation significantly improved endurance in both muscles compared with placebo', res.createdAt = datetime('2026-10-04T01:00:00Z'), res.privacyClass = 'PUBLIC'
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:SUPPORTED_BY]->(loc)
MERGE (a:Assertion {uid: 'hu:assertion:reports-on-35050355-nct03283462'})
  ON CREATE SET a.id = 'reports-on-35050355-nct03283462', a.predicate = 'REPORTS_ON', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:00:00Z'),
                a.contentHash = 'sha256:synthetic-reports-on-35050355', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(pub)
MERGE (a)-[:HAS_OBJECT]->(st)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (pub)-[e:REPORTS_ON]->(st)
  ON CREATE SET e.relationshipUid = 'hu:rel:reports-on-35050355-nct03283462', e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// 7. Sponsor assertions (W01 predicate SPONSORS_STUDY, registry-stated) and the derived Study.sponsoredBy projection.
UNWIND [
  {st: 'hu:study:nct03464500-atlas', a: 'hu:assertion:amazentis-sponsors-nct03464500', loc: 'hu:locator:ctgov-nct03464500-2026-10-04-outcomes'},
  {st: 'hu:study:nct03283462-energize', a: 'hu:assertion:amazentis-sponsors-nct03283462', loc: 'hu:locator:ctgov-nct03283462-2026-10-04-record'}
] AS r
MATCH (st:Study {uid: r.st}), (loc:SourceLocator {uid: r.loc})
MERGE (org:Organization:Entity {uid: 'hu:org:amazentis-sa'})
  ON CREATE SET org.id = 'amazentis-sa', org.entityType = 'Organization', org.name = 'Amazentis SA', org.createdAt = datetime('2026-10-04T01:00:00Z'), org.privacyClass = 'PUBLIC'
MERGE (a:Assertion {uid: r.a})
  ON CREATE SET a.id = split(r.a, ':')[2], a.predicate = 'SPONSORS_STUDY', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.predicateClass = 'ROLE',
                a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.contentHash = 'sha256:synthetic-' + split(r.a, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(org)
MERGE (a)-[:HAS_OBJECT]->(st)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[d:SPONSORED_BY]->(org)
  ON CREATE SET d.derivationRule = 'inverse-of:SPONSORS_STUDY@1', d.derivedFromAssertionUids = [a.uid], d.derivedAt = datetime('2026-10-04T01:00:00Z');

// 8. W10-owned synthesis (fixture content): two inputs from different studies and datasets. Both are secondary findings of
//    trials whose primary was null (ATLAS here; ENERGIZE per Liu 2022), so INV-206 allows only SUPPORTIVE/HYPOTHESIS_GENERATING;
//    their dataset independence is still countable (QS-W09-08). The two walnut publications share Study and Dataset.
MATCH (r1:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'}), (r2:StudyResult {uid: 'hu:study-result:energize-endurance-ua-vs-placebo-2m'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ua-muscle-performance-replication-v1'})
  ON CREATE SET syn.id = 'ua-muscle-performance-replication-v1', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.claimText = 'Urolithin A improves a muscle performance measure versus placebo in adults', syn.verdict = 'INSUFFICIENT',
                syn.evidenceCutoff = date('2022-05-31'), syn.recordedAt = datetime('2026-10-04T01:00:00Z'), syn.createdAt = datetime('2026-10-04T01:00:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(r1)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(r2);

MATCH (w1:StudyResult {uid: 'hu:study-result:berryman-2013-skins-rhi-within'}), (w2:StudyResult {uid: 'hu:study-result:zhang-2011-postprandial-sera-efflux'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:walnut-components-vascular-v1'})
  ON CREATE SET syn.id = 'walnut-components-vascular-v1', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.claimText = 'Walnut components acutely affect vascular and lipid-efflux markers', syn.verdict = 'INSUFFICIENT', syn.evidenceCutoff = date('2013-12-31'),
                syn.recordedAt = datetime('2026-10-04T01:00:00Z'), syn.createdAt = datetime('2026-10-04T01:00:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(w1)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(w2);

// 9. Capture-fidelity policy adjudication.
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:produced-dataset-nct00938340', 'hu:assertion:reports-on-23616506-nct00938340', 'hu:assertion:reports-on-21871057-nct00938340',
  'hu:assertion:analyzes-23616506-ds', 'hu:assertion:analyzes-21871057-ds', 'hu:assertion:reports-on-35050355-nct03283462',
  'hu:assertion:amazentis-sponsors-nct03464500', 'hu:assertion:amazentis-sponsors-nct03283462'] OR a.uid STARTS WITH 'hu:assertion:has-identifier-'
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-03-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-03-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:00:00Z'), j.recordedAt = datetime('2026-10-04T01:00:00Z'), j.createdAt = datetime('2026-10-04T01:00:00Z'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a);

// Quote hashes: NFC-WS1 normalization (catalog normalizationVersions) over the stored `exact` text, sha256 (computed by W09
// with Python hashlib on 2026-10-04 over the quoted text only; the snapshot bytes were not hashed: SYNTHETIC_FIXTURE).
UNWIND [
  {uid: 'hu:locator:pmc8777576-results-endurance', h: 'sha256:6bf4a45b8705a7bf1191729639384c66e33dd7377f9fc6355d5a458e855df103'},
  {uid: 'hu:locator:pubmed-21871057-abstract', h: 'sha256:907677a5c5f12ab14ad9b63ffbb0914e38324b414362080bee47f323a7f43cd5'},
  {uid: 'hu:locator:pubmed-23616506-abstract', h: 'sha256:b367c601f5011f53d4b108ea8899bce24c9733023ea04cd122bf21497a96b28a'}
] AS r
MATCH (l:SourceLocator {uid: r.uid})
SET l.normalizationVersion = 'NFC-WS1', l.quoteHash = r.h;
