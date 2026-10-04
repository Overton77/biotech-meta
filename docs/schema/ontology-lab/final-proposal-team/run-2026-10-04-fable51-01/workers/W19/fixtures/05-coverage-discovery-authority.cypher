// =====================================================================
// W19 fixture 05: candidate operational records kept separate from truth.
//   SourceCoverageRequirement (CQ-PV-C02), SourceDiscoveryRecord (CQ-PV-C03),
//   SourceAuthorityAssessment (CQ-PV-C01). Depends on fixtures 01-04.
//
// Real discovery outcomes (NEW_RETRIEVAL 2026-10-04, this session):
//   D1 FOUND    ClinicalTrials.gov connector (mcp Clinical_Trials get_trial_details NCT02678611): current record,
//               no version number or last-update fields in the connector output.
//   D2 BLOCKED  ClinicalTrials.gov API v2 direct (curl: "CONNECT tunnel failed, response 403"; WebFetch:
//               EGRESS_BLOCKED "Access to clinicaltrials.gov is blocked by the network egress proxy").
//   D3 BLOCKED  Record history tab via Firecrawl: HTTP 200, page title "Error | ClinicalTrials.gov", body "403 Forbidden".
//               Status code alone would have read FOUND.
//   D4 FOUND    PubMed connector metadata for PMID 29184669 (publication type "Journal Article").
//   D5 BLOCKED  NCBI E-utilities efetch direct (curl CONNECT 403).
//   D6 PARTIAL  Huberman Lab RSS feed via Firecrawl ("The page was too long to process in full").
// SYNTHETIC: the securities-filing source and its capability statement (fictional company, .invalid host).
// Candidate uid tokens are not registered; fixtures use registered tokens: assessment (SourceAuthorityAssessment),
// activity (SourceDiscoveryRecord, an Activity specialization), policy (SourceCoverageRequirement). See W19-SR-05.
// =====================================================================

// ---- requirements (INTERNAL operational records) ----
MERGE (q:SourceCoverageRequirement:InformationArtifact {uid: 'hu:policy:w19-coverage-trial-registration-registry-record-v1'})
SET q.artifactType = 'SourceCoverageRequirement', q.requirementKey = 'trial-registration.registry-record', q.versionLabel = 'v1',
    q.subjectLabel = 'TrialRegistration', q.requiredSourceKinds = ['TRIAL_REGISTRY_RECORD'], q.requiredAuthorityScopes = ['TRIAL_REGISTRATION'],
    q.maxSnapshotAgeDays = 90, q.requireCompleteCapture = false, q.revisionHistoryRequired = true,
    q.rationale = 'CQ-ST-08 and CQ-ST-04: registry state as observed, plus record history for outcome switching.',
    q.privacyClass = 'INTERNAL', q.recordedAt = datetime('2026-10-04T12:00:00Z'), q.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (q:SourceCoverageRequirement:InformationArtifact {uid: 'hu:policy:w19-coverage-publication-revision-status-v1'})
SET q.artifactType = 'SourceCoverageRequirement', q.requirementKey = 'publication.revision-status', q.versionLabel = 'v1',
    q.subjectLabel = 'Publication', q.requiredSourceKinds = ['BIBLIOGRAPHIC_RECORD'], q.requiredAuthorityScopes = ['BIBLIOGRAPHIC_STATUS'],
    q.maxSnapshotAgeDays = 30, q.requireCompleteCapture = false, q.revisionHistoryRequired = false,
    q.rationale = 'CQ-EV-05: correction and retraction status must be re-checked before a publication is relied on.',
    q.privacyClass = 'INTERNAL', q.recordedAt = datetime('2026-10-04T12:00:00Z'), q.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- the registry record (W09 TrialRegistration identity, referenced) and its Source ----
MERGE (t:TrialRegistration:Entity {uid: 'hu:trial-registration:nct02678611'})
SET t.entityType = 'TrialRegistration', t.name = 'NCT02678611', t.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:ctgov-nct02678611'})
SET s.entityType = 'Source', s.canonicalUri = 'https://clinicaltrials.gov/study/NCT02678611', s.title = 'ClinicalTrials.gov record NCT02678611',
    s.sourceKind = 'TRIAL_REGISTRY_RECORD', s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (g:Agent:Entity {uid: 'hu:agent:clinical-trials-mcp'})
SET g.entityType = 'Agent', g.name = 'ClinicalTrials.gov MCP connector', g.agentKind = 'AUTOMATED_AGENT', g.toolVersion = 'unknown', g.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (g:Agent:Entity {uid: 'hu:agent:firecrawl-scrape'})
SET g.entityType = 'Agent', g.name = 'Firecrawl scrape', g.agentKind = 'AUTOMATED_AGENT', g.toolVersion = 'unknown', g.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (g:Agent:Entity {uid: 'hu:agent:curl-direct'})
SET g.entityType = 'Agent', g.name = 'curl through the session egress proxy', g.agentKind = 'AUTOMATED_AGENT', g.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (g:Agent:Entity {uid: 'hu:agent:pubmed-mcp'})
SET g.entityType = 'Agent', g.name = 'PubMed MCP connector', g.agentKind = 'AUTOMATED_AGENT', g.toolVersion = 'unknown', g.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- discovery records (SourceDiscoveryRecord = Activity specialization, activityKind DISCOVERY) ----
MATCH (q:SourceCoverageRequirement {uid: 'hu:policy:w19-coverage-trial-registration-registry-record-v1'}), (src:Source {uid: 'hu:source:ctgov-nct02678611'}),
      (g:Agent {uid: 'hu:agent:clinical-trials-mcp'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-ctgov-nct02678611-connector'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'FOUND',
    d.startedAt = datetime('2026-10-04T00:58:00Z'), d.endedAt = datetime('2026-10-04T00:58:05Z'),
    d.attemptedUri = 'https://clinicaltrials.gov/study/NCT02678611', d.queryText = 'get_trial_details nct_id=NCT02678611',
    d.subjectUid = 'hu:trial-registration:nct02678611', d.subjectLabel = 'TrialRegistration', d.resultCount = 1,
    d.methodVersion = 'mcp Clinical_Trials get_trial_details', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:FOR_COVERAGE_REQUIREMENT]->(q)
MERGE (d)-[:DISCOVERED_SOURCE]->(src)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (q:SourceCoverageRequirement {uid: 'hu:policy:w19-coverage-trial-registration-registry-record-v1'}), (g:Agent {uid: 'hu:agent:curl-direct'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-ctgov-api-v2-direct'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'BLOCKED',
    d.startedAt = datetime('2026-10-04T00:59:00Z'), d.endedAt = datetime('2026-10-04T00:59:01Z'),
    d.attemptedUri = 'https://clinicaltrials.gov/api/v2/studies/NCT02678611?fields=protocolSection.statusModule,derivedSection.miscInfoSection',
    d.blockEvidence = 'curl: (56) CONNECT tunnel failed, response 403; WebFetch EGRESS_BLOCKED',
    d.subjectUid = 'hu:trial-registration:nct02678611', d.subjectLabel = 'TrialRegistration', d.resultCount = 0,
    d.methodVersion = 'curl 8.x via agent proxy; WebFetch', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:FOR_COVERAGE_REQUIREMENT]->(q)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (q:SourceCoverageRequirement {uid: 'hu:policy:w19-coverage-trial-registration-registry-record-v1'}), (g:Agent {uid: 'hu:agent:firecrawl-scrape'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-ctgov-history-tab'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'BLOCKED',
    d.startedAt = datetime('2026-10-04T01:00:00Z'), d.endedAt = datetime('2026-10-04T01:00:06Z'),
    d.attemptedUri = 'https://clinicaltrials.gov/study/NCT02678611?tab=history', d.responseStatusCode = 200,
    d.blockEvidence = 'HTTP 200 but page title "Error | ClinicalTrials.gov" and body "403 Forbidden" where the history table belongs',
    d.discoveryTarget = 'RECORD_HISTORY',
    d.subjectUid = 'hu:trial-registration:nct02678611', d.subjectLabel = 'TrialRegistration', d.resultCount = 0,
    d.methodVersion = 'firecrawl scrape markdown waitFor=4000', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:FOR_COVERAGE_REQUIREMENT]->(q)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (q:SourceCoverageRequirement {uid: 'hu:policy:w19-coverage-publication-revision-status-v1'}), (src:Source {uid: 'hu:source:pubmed-29184669'}),
      (g:Agent {uid: 'hu:agent:pubmed-mcp'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-pubmed-29184669-metadata'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'FOUND',
    d.startedAt = datetime('2026-10-04T00:47:00Z'), d.attemptedUri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/',
    d.queryText = 'get_article_metadata pmids=[29184669,30155270]', d.subjectUid = 'hu:publication:pmid-29184669', d.subjectLabel = 'Publication',
    d.resultCount = 2, d.methodVersion = 'mcp PubMed get_article_metadata', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:FOR_COVERAGE_REQUIREMENT]->(q)
MERGE (d)-[:DISCOVERED_SOURCE]->(src)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (q:SourceCoverageRequirement {uid: 'hu:policy:w19-coverage-publication-revision-status-v1'}), (g:Agent {uid: 'hu:agent:curl-direct'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-eutils-efetch-direct'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'BLOCKED',
    d.startedAt = datetime('2026-10-04T00:48:30Z'),
    d.attemptedUri = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=29184669,30155270&retmode=xml',
    d.blockEvidence = 'curl: (56) CONNECT tunnel failed, response 403', d.subjectUid = 'hu:publication:pmid-29184669', d.subjectLabel = 'Publication',
    d.resultCount = 0, d.methodVersion = 'curl via agent proxy', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:FOR_COVERAGE_REQUIREMENT]->(q)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (src:Source {uid: 'hu:source:megaphone-hubermanlab-feed'}), (g:Agent {uid: 'hu:agent:firecrawl-scrape'})
MERGE (d:SourceDiscoveryRecord:Activity:Occurrence {uid: 'hu:activity:w19-discovery-megaphone-feed-hl52-item'})
SET d.occurrenceType = 'SourceDiscoveryRecord', d.activityKind = 'DISCOVERY', d.discoveryOutcome = 'PARTIAL',
    d.startedAt = datetime('2026-10-04T01:02:00Z'), d.attemptedUri = 'https://feeds.megaphone.fm/hubermanlab',
    d.queryText = 'locate <item> for "Dr. David Sinclair: The Biology of Slowing & Reversing Aging"',
    d.blockEvidence = 'tool warning: The page was too long to process in full; the answer was generated from the first part of it.',
    d.subjectUid = 'hu:episode:huberman-lab-52-sinclair', d.subjectLabel = 'Episode', d.resultCount = 0,
    d.methodVersion = 'firecrawl scrape query directQuote', d.privacyClass = 'INTERNAL', d.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:DISCOVERED_SOURCE]->(src)
MERGE (d)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- the registry snapshot generated by the FOUND discovery, and two registry assertions ----
MATCH (src:Source {uid: 'hu:source:ctgov-nct02678611'}), (d:Activity {uid: 'hu:activity:w19-discovery-ctgov-nct02678611-connector'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct02678611-connector-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:58:05Z'), s.observedAt = datetime('2026-10-04T00:58:05Z'),
    s.contentHash = 'sha256:4d1e1c27a5e70de8d4c98aca2606c33c309a2636518fee906010a259ce0b21f0',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/ctgov-NCT02678611-connector-2026-10-04.txt', s.mimeType = 'application/json',
    s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(d);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct02678611-connector-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-enrollment'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = '"enrollment":120',
    l.quoteHash = 'sha256:99ba54af6d4c99eb0816df0a0781948636183e6c93935cb465da1d03697a131f', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct02678611-connector-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-has-results-false'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = '"has_results":false',
    l.quoteHash = 'sha256:ca8be3197513288dcec7be97a0e39ac5fbbfd7f2d18b479458e9e840fcbc546e', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (t:TrialRegistration {uid: 'hu:trial-registration:nct02678611'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-enrollment'}),
      (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-enrollment-120'})
SET a.predicate = 'REGISTERED_ENROLLMENT_COUNT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueNumber = 120.0,
    a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(x);

MATCH (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-enrollment-120'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-enrollment'}),
      (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w19-capture-fidelity-ctgov-enrollment'})
SET j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'AGENT',
    j.methodVersion = 'w19-manual-curation-v0.1', j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T12:30:00Z'),
    j.recordedAt = datetime('2026-10-04T12:30:00Z'), j.rationale = 'Registry field captured as displayed by the connector.',
    j.createdAt = datetime('2026-10-04T12:30:00Z')
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l)
MERGE (j)-[:ASSESSED_BY]->(g);

// Wrong-scope use (CQ-PV-C01 failing case 1): the registry's has_results=false read as "results unpublished".
MATCH (t:TrialRegistration {uid: 'hu:trial-registration:nct02678611'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-has-results-false'}),
      (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-results-published-false'})
SET a.predicate = 'RESULTS_PUBLISHED', a.status = 'EXTRACTED', a.polarity = 'NEGATIVE', a.valueBoolean = false,
    a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'naive-registry-field-mapping'
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(x);

// ---- SYNTHETIC securities filing: non-marketing source kind, but not authoritative for operations ----
MERGE (o:Organization:Entity {uid: 'hu:org:synthetic-nad-ingredients-inc'})
SET o.entityType = 'Organization', o.name = 'Synthetic NAD Ingredients Inc. (fixture only)', o.fixtureProvenance = 'SYNTHETIC', o.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Document:Source:Entity {uid: 'hu:document:synthetic-10k-fy2025'})
SET s.entityType = 'Source', s.documentId = 'synthetic-10k-fy2025', s.canonicalUri = 'https://filings.example.invalid/synthetic-nad-10k-fy2025.htm',
    s.title = 'Synthetic 10-K FY2025 (fixture only)', s.sourceKind = 'SECURITIES_FILING', s.documentType = 'SEC_FILING',
    s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (src:Source {uid: 'hu:document:synthetic-10k-fy2025'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-10k-fy2025-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri, s.retrievedAt = datetime('2026-10-04T10:00:00Z'),
    s.observedAt = datetime('2026-10-04T10:00:00Z'), s.contentHash = 'synthetic:hu:snapshot:synthetic-10k-fy2025-2026-10-04',
    s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-10k-fy2025-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-10k-fy2025-own-facility'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'We operate our own cGMP manufacturing facility at full commercial scale.',
    l.quoteHash = 'sha256:7ed0f07718a056a83341f729a304bcec588133338889f3eb60f61cfc4d0b84b8', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (o:Organization {uid: 'hu:org:synthetic-nad-ingredients-inc'}), (l:SourceLocator {uid: 'hu:locator:synthetic-10k-fy2025-own-facility'})
MERGE (a:Assertion {uid: 'hu:assertion:w19-synthetic-10k-capability-operating'})
SET a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'EXTRACTED', a.polarity = 'POSITIVE', a.valueString = 'OPERATING',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.fixtureProvenance = 'SYNTHETIC', a.recordedAt = datetime('2026-10-04T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// ---- authority assessments (one per Source; claim-scoped, method-versioned; never a truth score) ----
MATCH (src:Source {uid: 'hu:source:ctgov-nct02678611'}), (s:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct02678611-connector-2026-10-04'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x:SourceAuthorityAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-authority-ctgov-nct02678611'})
SET x.assessmentType = 'SourceAuthorityAssessment', x.methodVersion = 'w19-authority-scope-v0.1', x.status = 'PROPOSED',
    x.authorityScopes = ['TRIAL_REGISTRATION'], x.registryEntryId = 'SRC-CTGOV-NCT02678611',
    x.authorityForTags = ['registered_primary_and_secondary_outcomes_as_currently_shown', 'registered_arms_and_intervention_labels', 'sponsor_and_collaborator_as_registered', 'overall_status', 'enrollment_count_as_shown', 'registered_sites', 'results_section_posted_or_not'],
    x.notAuthorityForTags = ['whether_results_were_published', 'outcome_registration_history_without_version_records', 'material_identity_of_Basis_250_or_500', 'current_product_formulation'],
    x.assessedAt = datetime('2026-10-04T12:00:00Z'), x.recordedAt = datetime('2026-10-04T12:00:00Z'), x.privacyClass = 'INTERNAL', x.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (x)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
MERGE (x)-[:ASSESSED_ON_SNAPSHOT]->(s)
MERGE (x)-[:ASSESSED_BY]->(g);

MATCH (src:Source {uid: 'hu:document:synthetic-10k-fy2025'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x:SourceAuthorityAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-authority-synthetic-10k-fy2025'})
SET x.assessmentType = 'SourceAuthorityAssessment', x.methodVersion = 'w19-authority-scope-v0.1', x.status = 'PROPOSED',
    x.authorityScopes = ['SELF_DECLARATION'], x.registryEntryId = 'SRC-SEC-NAGE-10K-FY2025 (pattern only; this source is synthetic)',
    x.notAuthorityForTags = ['agency_position', 'actual_facility_operations', 'capacity'],
    x.assessedAt = datetime('2026-10-04T12:00:00Z'), x.recordedAt = datetime('2026-10-04T12:00:00Z'), x.privacyClass = 'INTERNAL', x.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (x)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
MERGE (x)-[:ASSESSED_BY]->(g);

MATCH (src:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x:SourceAuthorityAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-authority-nature-s41514-017-0016-9-html'})
SET x.assessmentType = 'SourceAuthorityAssessment', x.methodVersion = 'w19-authority-scope-v0.1', x.status = 'PROPOSED',
    x.authorityScopes = ['STUDY_REPORT'], x.registryEntryId = 'SRC-NATURE-BASIS-2017',
    x.authorityForTags = ['reported_study_design_intervention_results_funding_and_conflicts'],
    x.notAuthorityForTags = ['identity_of_later_formulations', 'longevity_outcome_not_measured'],
    x.assessedAt = datetime('2026-10-04T12:00:00Z'), x.recordedAt = datetime('2026-10-04T12:00:00Z'), x.privacyClass = 'INTERNAL', x.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (x)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
MERGE (x)-[:ASSESSED_BY]->(g);

MATCH (src:Source {uid: 'hu:document:pmc-PMC5701244'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x:SourceAuthorityAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-authority-pmc-PMC5701244'})
SET x.assessmentType = 'SourceAuthorityAssessment', x.methodVersion = 'w19-authority-scope-v0.1', x.status = 'PROPOSED',
    x.authorityScopes = ['STUDY_REPORT'], x.notAuthorityForTags = ['version_of_record_equivalence_without_comparison'],
    x.assessedAt = datetime('2026-10-04T12:00:00Z'), x.recordedAt = datetime('2026-10-04T12:00:00Z'), x.privacyClass = 'INTERNAL', x.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (x)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
MERGE (x)-[:ASSESSED_BY]->(g);

MATCH (src:Source {uid: 'hu:source:pubmed-30155270'}), (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (x:SourceAuthorityAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-authority-pubmed-30155270'})
SET x.assessmentType = 'SourceAuthorityAssessment', x.methodVersion = 'w19-authority-scope-v0.1', x.status = 'PROPOSED',
    x.authorityScopes = ['BIBLIOGRAPHIC_STATUS'], x.registryEntryId = 'SRC-PUBMED-30155270',
    x.notAuthorityForTags = ['who_manufactured_or_supplied_the_NR_raw_material', 'change_in_results'],
    x.assessedAt = datetime('2026-10-04T12:00:00Z'), x.recordedAt = datetime('2026-10-04T12:00:00Z'), x.privacyClass = 'INTERNAL', x.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (x)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
MERGE (x)-[:ASSESSED_BY]->(g);
