// =====================================================================
// W19 fixture 04: a Source whose content changed (SourceRevisionEvent), the old locator untouched,
// and a new locator that REANCHORS it (CQ-EV-05, CQ-PV-02, INV-504; V-402, V-409).
// Depends on fixtures 01-03.
//
// Real facts (NEW_RETRIEVAL 2026-10-04):
//   - PubMed: PMID 30155270 "Erratum: Author Correction: ..." publication types Journal Article + Published
//     Erratum, published 2018-08-20, "[This corrects the article DOI: 10.1038/s41514-017-0016-9.]".
//   - nature.com article page: "... This has now been corrected in the PDF and HTML versions of the Article."
//   - PubMed metadata of PMID 29184669 today shows publication type "Journal Article" only (no revision type).
// Cannot establish: the instant the HTML/PDF bytes changed; what the PMC copy showed before; whether the PubMed
// record of 29184669 changed when the erratum was linked. The pre-correction snapshot S0 is therefore SYNTHETIC
// (an archive capture stand-in) and labelled so.
// =====================================================================

// S0: SYNTHETIC archive capture of the publisher HTML before the correction; retrieved late.
MATCH (src:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-synthetic-2018-01'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.observedAt = datetime('2018-01-15T00:00:00Z'), s.retrievedAt = datetime('2026-10-04T03:00:00Z'),
    s.publishedAt = datetime('2017-11-24T00:00:00Z'),
    s.contentHash = 'synthetic:hu:snapshot:nature-s41514-017-0016-9-html-synthetic-2018-01', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.archiveUri = 'https://archive.example.invalid/2018-01-15/nature-s41514-017-0016-9',
    s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

// L0: the old locator on S0. It is never edited after this statement.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-synthetic-2018-01'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nature-html-2018-01-nrpt-2x-bottles'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'Methods / Intervention',
    l.exact = 'NRPT 2X arm was provided with Bottle A containing NRPT and Bottle B containing NRPT capsules.',
    l.quoteHash = 'sha256:7d0c2523cf41ff8638efdb299f8d6746a2783139ee29ac4e6bdb255ffb93d3bf', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// L1: the same passage re-found on the 2026-10-04 snapshot (real excerpt) by a REANCHORING activity.
MERGE (x:Activity:Occurrence {uid: 'hu:activity:w19-reanchor-2026-10-04'})
SET x.occurrenceType = 'Activity', x.activityKind = 'REANCHORING', x.startedAt = datetime('2026-10-04T03:10:00Z'),
    x.methodVersion = 'quote-anchor-nfc-ws1-exact-v0.1', x.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:nature-html-2026-10-04-nrpt-2x-bottles'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.section = 'Methods / Intervention',
    l.exact = 'NRPT 2X arm was provided with Bottle A containing NRPT and Bottle B containing NRPT capsules.',
    l.quoteHash = 'sha256:7d0c2523cf41ff8638efdb299f8d6746a2783139ee29ac4e6bdb255ffb93d3bf', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (newL:SourceLocator {uid: 'hu:locator:nature-html-2026-10-04-nrpt-2x-bottles'}), (oldL:SourceLocator {uid: 'hu:locator:nature-html-2018-01-nrpt-2x-bottles'}),
      (x:Activity {uid: 'hu:activity:w19-reanchor-2026-10-04'})
MERGE (newL)-[r:REANCHORS]->(oldL)
SET r.anchorMatch = 'EXACT', r.activityUid = x.uid
MERGE (newL)-[:WAS_GENERATED_BY]->(x)
MERGE (x)-[:USED]->(oldL);

// The notice and its record (PMID 30155270), real excerpt.
MATCH (src:Source {uid: 'hu:source:pubmed-30155270'}), (x:Activity {uid: 'hu:activity:w19-pubmed-connector-2026-10-04'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-30155270-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:47:00Z'), s.observedAt = datetime('2026-10-04T00:47:00Z'),
    s.publishedAt = datetime('2018-08-20T00:00:00Z'),
    s.contentHash = 'sha256:7181eb20ab42045ac9bde9b1c29aee7ec6ac3b511fe473e8869956f41287cd52',
    s.contentHashBasis = 'STORED_EXCERPT_TEXT', s.captureCompleteness = 'PARTIAL_EXCERPT',
    s.storageUri = 'repo:workers/W19/fixtures/excerpts/pubmed-30155270-metadata-2026-10-04.txt', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(x);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:pubmed-30155270-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:pubmed-30155270-corrects-doi'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = '[This corrects the article DOI: 10.1038/s41514-017-0016-9.].',
    l.quoteHash = 'sha256:0ae534f54472f261ffb3c8f7185ad457cd2213614ee8c4d95e593f0a2f483202', l.normalizationVersion = 'NFC-WS1',
    l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// One SourceRevisionEvent per affected Source (REVISES_SOURCE is exactly_one).
// HTML: prior and first-observed-after snapshots are known; the event's occurredAt is the notice date (DAY);
// the instant the bytes changed is not established.
MATCH (src:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'}),
      (s0:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-synthetic-2018-01'}),
      (s1:SourceSnapshot {uid: 'hu:snapshot:nature-s41514-017-0016-9-html-2026-10-04'}),
      (n:SourceSnapshot {uid: 'hu:snapshot:pubmed-30155270-2026-10-04'})
MERGE (e:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:nature-s41514-017-0016-9-html-author-correction-2018'})
SET e.occurrenceType = 'SourceRevisionEvent', e.revisionKind = 'ERRATUM',
    e.occurredAt = datetime('2018-08-20T00:00:00Z'), e.occurredAtPrecision = 'DAY',
    e.occurredAtNote = 'notice publication date; the in-place HTML change instant is not established',
    e.recordedAt = datetime('2026-10-04T12:00:00Z'), e.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (e)-[:REVISES_SOURCE]->(src)
MERGE (e)-[:PRIOR_SNAPSHOT]->(s0)
MERGE (e)-[:RESULTING_SNAPSHOT]->(s1)
MERGE (e)-[:ANNOUNCED_IN]->(n);

// PDF: the publisher says the PDF was corrected too; no snapshot of either state was captured.
MATCH (src:Source {uid: 'hu:document:nature-s41514-017-0016-9-pdf'}), (n:SourceSnapshot {uid: 'hu:snapshot:pubmed-30155270-2026-10-04'})
MERGE (e:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:nature-s41514-017-0016-9-pdf-author-correction-2018'})
SET e.occurrenceType = 'SourceRevisionEvent', e.revisionKind = 'ERRATUM',
    e.occurredAt = datetime('2018-08-20T00:00:00Z'), e.occurredAtPrecision = 'DAY',
    e.recordedAt = datetime('2026-10-04T12:00:00Z'), e.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (e)-[:REVISES_SOURCE]->(src)
MERGE (e)-[:ANNOUNCED_IN]->(n);

// Publication-level view (W09 asserted CORRECTS), backed by the NLM linking statement.
MATCH (nlm:Organization {uid: 'hu:org:us-national-library-of-medicine'}), (e:Publication {uid: 'hu:publication:pmid-30155270'}),
      (p:Publication {uid: 'hu:publication:pmid-29184669'}), (l:SourceLocator {uid: 'hu:locator:pubmed-30155270-corrects-doi'})
MERGE (a:Assertion {uid: 'hu:assertion:w19-pmid-30155270-corrects-pmid-29184669'})
SET a.predicate = 'CORRECTS', a.status = 'EXTRACTED', a.polarity = 'POSITIVE',
    a.validFrom = datetime('2018-08-20T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T12:00:00Z'), a.extractionMethod = 'manual'
MERGE (a)-[:HAS_SUBJECT]->(e)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:ASSERTED_BY]->(nlm)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (e)-[r:CORRECTS]->(p)
SET r.relationshipUid = 'hu:rel:w19-pmid-30155270-corrects-pmid-29184669', r.assertionUid = a.uid,
    r.validFrom = a.validFrom, r.validFromPrecision = 'DAY', r.validFromBasis = 'PUBLICATION_PROXY', r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T12:00:00Z');
