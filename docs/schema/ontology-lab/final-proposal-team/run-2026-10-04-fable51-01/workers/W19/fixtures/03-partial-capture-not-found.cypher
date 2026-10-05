// =====================================================================
// W19 fixture 03: "not found" in a partial capture or a partial rendition reads
// NOT_FOUND_IN_PARTIAL_CAPTURE, never NOT_DISCLOSED / absent (forbidden implication
// [NOT_FOUND_IN_PARTIAL_CAPTURE, NOT_DISCLOSED]; V-426; INV-007; CQ-AX-04 / QS-7).
// Depends on fixtures 01 and 02.
//
// Three cases:
//   P1 (real, NEW_RETRIEVAL 2026-10-04): the statement "The matched placebo pills and the investigational
//      product (NRPT) were provided by Elysium Health (New York, NY)." is located in the publisher HTML and in
//      the PMC full text of PMID 29184669. It is NOT in the PubMed record, which renders only the abstract
//      (renditionCoverage PARTIAL). Restricting the search to the PubMed rendition must read
//      NOT_FOUND_IN_PARTIAL_CAPTURE even for a COMPLETE capture of that record (SYNTHETIC complete snapshot).
//   P2 (real partial capture + inherited role line): whether the guest disclosed EdenRoc/MetroBiotech ties in
//      episode 52 cannot be concluded from query-reranked transcript excerpts: disclosureFinding
//      NOT_FOUND_IN_PARTIAL_CAPTURE.
//   P3 (real, NEW_RETRIEVAL): the Huberman Lab RSS feed capture was truncated by the capture tool
//      ("The page was too long to process in full"); the episode 52 item was not reached. Feed presence of
//      the item reads NOT_FOUND_IN_PARTIAL_CAPTURE.
// =====================================================================

MERGE (o:Organization:Entity {uid: 'hu:org:elysium-health'})
SET o.entityType = 'Organization', o.name = 'Elysium Health', o.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (p:Person:Entity {uid: 'hu:person:ryan-w-dellinger'})
SET p.entityType = 'Person', p.name = 'Ryan W. Dellinger', p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (i:StudyIntervention:VersionedState {uid: 'hu:intervention:nct02678611-nrpt-1x'})
SET i.stateType = 'StudyIntervention', i.name = 'NRPT 1X (125 mg NR + 25 mg pterostilbene per capsule, two capsules daily)',
    i.payloadHash = 'synthetic:hu:intervention:nct02678611-nrpt-1x', i.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- P1 snapshots ----
MATCH (src:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'}), (x:Activity {uid: 'hu:activity:w19-capture-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:52:00Z'), s.observedAt = datetime('2026-10-04T00:52:00Z'),
    s.contentHash = 'sha256:82c02fb886a9999ba03da1e56cd6909be684174a3b40b3e36be04499505bb19a',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/nature-s41514-017-0016-9-2026-10-04.txt',
    s.publisherRevisionNotice = 'This has now been corrected in the PDF and HTML versions of the Article.',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

MERGE (x:Activity:Occurrence {uid: 'hu:activity:w19-pubmed-connector-2026-10-04'})
SET x.occurrenceType = 'Activity', x.activityKind = 'CAPTURE', x.startedAt = datetime('2026-10-04T00:47:00Z'),
    x.methodVersion = 'PubMed MCP get_full_text_article / get_article_metadata (connector version unknown)', x.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (src:Source {uid: 'hu:document:pmc-PMC5701244'}), (x:Activity {uid: 'hu:activity:w19-pubmed-connector-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc-PMC5701244-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:49:00Z'), s.observedAt = datetime('2026-10-04T00:49:00Z'),
    s.contentHash = 'sha256:4d3ead9b11e816ff7699281387a7f278e779ef2af50bce00280dbdc6cb31169d',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/pmc-PMC5701244-intervention-2026-10-04.txt',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

MATCH (src:Source {uid: 'hu:source:pubmed-29184669'}), (x:Activity {uid: 'hu:activity:w19-capture-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-29184669-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:52:00Z'), s.observedAt = datetime('2026-10-04T00:52:00Z'),
    s.contentHash = 'sha256:5b153bcc9f50dd89da81d9044a1116d663a44153e1ba86d84df30491c0c43481',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/pubmed-29184669-2026-10-04.txt',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

// SYNTHETIC: a complete capture of the same PubMed record. Complete capture of a partial rendition is still
// a partial capture of the work.
MATCH (src:Source {uid: 'hu:source:pubmed-29184669'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-29184669-synthetic-complete'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T02:00:00Z'), s.observedAt = datetime('2026-10-04T02:00:00Z'),
    s.contentHash = 'synthetic:hu:snapshot:pubmed-29184669-synthetic-complete', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
    s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nature-html-2026-10-04-elysium-provided-ip'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#Sec', l.selectorKind = 'TEXT_QUOTE', l.section = 'Methods / Intervention',
    l.exact = 'The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health (New York, NY).',
    l.quoteHash = 'sha256:73c514cf1c8c1ef433adacabdd7b110576a8685feabffed0b5e1034c0f1120ff', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:pmc-PMC5701244-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc-PMC5701244-2026-10-04-elysium-provided-ip'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'Methods / Intervention',
    l.exact = 'The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health (New York, NY).',
    l.quoteHash = 'sha256:73c514cf1c8c1ef433adacabdd7b110576a8685feabffed0b5e1034c0f1120ff', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// The occurrence's container is the Publication (work): locators on two different renditions both satisfy
// V-411. Asserter choice for a multi-author paper (first author here) is a W21/W01 seam (W19-SR-08).
MATCH (au:Person {uid: 'hu:person:ryan-w-dellinger'}), (pub:Publication {uid: 'hu:publication:pmid-29184669'}),
      (org:Organization {uid: 'hu:org:elysium-health'}), (iv:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'}),
      (l1:SourceLocator {uid: 'hu:locator:nature-html-2026-10-04-elysium-provided-ip'}), (l2:SourceLocator {uid: 'hu:locator:pmc-PMC5701244-2026-10-04-elysium-provided-ip'}),
      (x:Activity {uid: 'hu:activity:w19-curation-2026-10-04'})
MERGE (a:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:w19-pmid-29184669-elysium-provided-ip'})
SET a.predicate = 'PROVIDES_INVESTIGATIONAL_PRODUCT', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'STUDY_RESULT', a.speechAct = 'STATES', a.utteranceText = l1.exact,
    a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(org)
MERGE (a)-[:HAS_OBJECT]->(iv)
MERGE (a)-[:ASSERTED_BY]->(au)
MERGE (a)-[:OCCURS_IN]->(pub)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(x);

// ---- P2: role line on the self-disclosure page (INHERITED_REPO_CITATION: values copied from
//      docs/schema/examples/claim-retelling-provenance.cypher, captured 2026-10-03) ----
MERGE (s:Document:Source:Entity {uid: 'hu:document:sinclair-lab-affiliations'})
SET s.entityType = 'Source', s.documentId = 'sinclair-lab-affiliations',
    s.canonicalUri = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations', s.sourceKind = 'SELF_DISCLOSURE_PAGE',
    s.documentType = 'WEBPAGE', s.isFinancialDisclosure = true, s.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (src:Source {uid: 'hu:document:sinclair-lab-affiliations'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
    s.contentHash = 'sha256:7f5c60d19e3501b26762db0d5a86b7013deb28e92dba6980a4b9f51a330097bf',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:sinclair-affiliations-2026-10-03'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-edenroc-line'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'ACTIVE ENGAGEMENTS',
    l.exact = 'EdenRoc Sciences companies F,I,E,A,B, IP',
    l.quoteHash = 'sha256:6cb5d847cc2c776ecd1280de1fbeff78d149d9ad3dd25e26d318518f815f93e6', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MERGE (o:Organization:Entity {uid: 'hu:org:edenroc-sciences'})
SET o.entityType = 'Organization', o.name = 'EdenRoc Sciences', o.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (org:Organization {uid: 'hu:org:edenroc-sciences'}),
      (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-edenroc-line'})
MERGE (a:Assertion {uid: 'hu:assertion:w19-affiliations-sinclair-equity-edenroc'})
SET a.predicate = 'HOLDS_EQUITY_IN', a.status = 'EXTRACTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE',
    a.roleTitleVerbatim = 'E', a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(sp)
MERGE (a)-[:HAS_OBJECT]->(org)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (o:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'}), (r:Assertion {uid: 'hu:assertion:w19-affiliations-sinclair-equity-edenroc'}),
      (g:Agent {uid: 'hu:agent:w19-curator'})
MERGE (c:ConflictRelevanceAssessment:EvidenceAssessment {uid: 'hu:assessment:w19-conflict-relevance-hl52-nmn-edenroc'})
SET c.assessmentType = 'ConflictRelevanceAssessment', c.methodVersion = 'conflict-relevance-v0.1', c.status = 'PROPOSED',
    c.relevanceLevel = 'INDIRECT', c.relevanceBasis = 'SAME_SUBSTANCE_CLASS_VIA_GROUP', c.temporalOverlap = 'UNKNOWN',
    c.disclosureFinding = 'NOT_FOUND_IN_PARTIAL_CAPTURE', c.scopeAmbiguity = 'group-level role codes',
    c.recordedAt = datetime('2026-10-04T12:00:00Z'), c.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (c)-[:FOR_OCCURRENCE]->(o)
MERGE (c)-[:ASSESSES_INTEREST]->(r)
MERGE (c)-[:ASSESSED_BY]->(g);

// ---- P3: the RSS feed capture was truncated by the tool; the item for episode 52 was not reached ----
MERGE (f:Source:Entity {uid: 'hu:source:megaphone-hubermanlab-feed'})
SET f.entityType = 'Source', f.canonicalUri = 'https://feeds.megaphone.fm/hubermanlab', f.title = 'Huberman Lab RSS feed',
    f.sourceKind = 'OTHER', f.sourceKindNote = 'podcast RSS feed document (proposed AUDIO_FEED is not requested; see W19-SR-01)',
    f.renditionCoverage = 'UNKNOWN', f.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (x:Activity:Occurrence {uid: 'hu:activity:w19-firecrawl-feed-2026-10-04'})
SET x.occurrenceType = 'Activity', x.activityKind = 'CAPTURE', x.startedAt = datetime('2026-10-04T01:02:00Z'),
    x.methodVersion = 'firecrawl scrape query directQuote (cacheState hit, cachedAt 2026-10-03T06:00:23Z)', x.createdAt = datetime('2026-10-04T12:00:00Z');

// observedAt is the capture service's cache time, not the request time (late, honest observation clock).
MATCH (f:Source {uid: 'hu:source:megaphone-hubermanlab-feed'}), (x:Activity {uid: 'hu:activity:w19-firecrawl-feed-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:megaphone-hubermanlab-feed-2026-10-04-partial'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = f.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T01:02:00Z'), s.observedAt = datetime('2026-10-03T06:00:23Z'),
    s.contentHash = 'sha256:ae9861bd5eda66bfd7001e31294ed349413753b830102ed1f976fea1be0cfae9',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/megaphone-hubermanlab-feed-partial-2026-10-04.txt',
    s.mimeType = 'application/xml', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (f)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:megaphone-hubermanlab-feed-2026-10-04-partial'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:megaphone-feed-adchoices'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Learn more about your ad choices.',
    l.quoteHash = 'sha256:8440ba1d60850d8c9a92609bf8c8473206ba4a4e491c7d9d2047bf826e76a6fe', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);
