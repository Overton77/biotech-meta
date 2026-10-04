// =====================================================================
// W19 fixture 01: CL-003 identity rule. Source vs Document vs Publication vs Episode.
// Run run-2026-10-04-fable51-01, worker W19 (Opus 5.5). Neo4j 5.26 Community.
//
// Minimal pairs encoded here:
//   A. One Publication (PMID 29184669), four Sources RENDITION_OF it: publisher HTML landing page,
//      publisher PDF, PMC full text, PubMed record (abstract-only rendition). The DOI is an identifier
//      of the work; https://doi.org/... is never a Source.canonicalUri.
//      The Author Correction (PMID 30155270) is a second Publication with its own rendition Source.
//   B. One Episode (Huberman Lab #52), four Sources RENDITION_OF it: publisher transcript page,
//      YouTube video, RSS audio feed item, Apple Podcasts directory record (partial rendition).
//   C. A recorded talk (Episode, video rendition) and its slide deck PDF (Document). The deck is NOT a
//      rendition of the talk: it is its own Source and its own claim container (SYNTHETIC).
//
// Real identifiers (PMID, DOI, PMCID, URLs) are NEW_RETRIEVAL 2026-10-04 (PubMed connector, Tavily
// extract) or INHERITED from docs/schema/sources/source-registry.yaml; the talk and deck are SYNTHETIC
// on the .invalid TLD. Proposed SourceKind values not yet in the catalog (BIBLIOGRAPHIC_RECORD,
// PRESENTATION_SLIDES) and the proposed Source.renditionCoverage property are seam requests
// W19-SR-01 and W19-SR-02; until W00 rules they are stored strings only.
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================

// ---- publishers and hosts (W01 identities, referenced only) ----
MERGE (n:Organization:Entity {uid: 'hu:org:springer-nature'})
SET n.entityType = 'Organization', n.name = 'Springer Nature (npj Aging and Mechanisms of Disease publisher)', n.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (n:Organization:Entity {uid: 'hu:org:us-national-library-of-medicine'})
SET n.entityType = 'Organization', n.name = 'U.S. National Library of Medicine', n.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (n:Organization:Entity {uid: 'hu:org:scicomm-media'})
SET n.entityType = 'Organization', n.name = 'Scicomm Media', n.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- A. the scholarly work and its correction (W09 Publication, referenced) ----
MERGE (p:Publication:InformationArtifact {uid: 'hu:publication:pmid-29184669'})
SET p.artifactType = 'Publication', p.publicationKind = 'ARTICLE',
    p.title = 'Repeat dose NRPT (nicotinamide riboside and pterostilbene) increases NAD+ levels in humans safely and sustainably: a randomized, double-blind, placebo-controlled study.',
    p.doi = '10.1038/s41514-017-0016-9', p.pmid = '29184669',
    p.publishedAt = datetime('2017-11-24T00:00:00Z'), p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (p:Publication:InformationArtifact {uid: 'hu:publication:pmid-30155270'})
SET p.artifactType = 'Publication', p.publicationKind = 'AUTHOR_CORRECTION',
    p.title = 'Author Correction: Repeat dose NRPT (nicotinamide riboside and pterostilbene) increases NAD+ levels in humans safely and sustainably',
    p.doi = '10.1038/s41514-018-0027-1', p.pmid = '30155270',
    p.publishedAt = datetime('2018-08-20T00:00:00Z'), p.createdAt = datetime('2026-10-04T12:00:00Z');

// ---- A. four renditions of PMID 29184669; one rendition of PMID 30155270 ----
MERGE (s:Document:Source:Entity {uid: 'hu:document:nature-s41514-017-0016-9-html'})
SET s.entityType = 'Source', s.documentId = 'nature-s41514-017-0016-9-html',
    s.canonicalUri = 'https://www.nature.com/articles/s41514-017-0016-9',
    s.title = 'Repeat dose NRPT ... (publisher HTML)', s.sourceKind = 'PEER_REVIEWED_PUBLICATION', s.documentType = 'SCIENTIFIC_ARTICLE',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Document:Source:Entity {uid: 'hu:document:nature-s41514-017-0016-9-pdf'})
SET s.entityType = 'Source', s.documentId = 'nature-s41514-017-0016-9-pdf',
    s.canonicalUri = 'https://www.nature.com/articles/s41514-017-0016-9.pdf',
    s.title = 'Repeat dose NRPT ... (publisher PDF)', s.sourceKind = 'PEER_REVIEWED_PUBLICATION', s.documentType = 'SCIENTIFIC_ARTICLE',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Document:Source:Entity {uid: 'hu:document:pmc-PMC5701244'})
SET s.entityType = 'Source', s.documentId = 'pmc-PMC5701244',
    s.canonicalUri = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/',
    s.title = 'Repeat dose NRPT ... (PubMed Central full text)', s.sourceKind = 'PEER_REVIEWED_PUBLICATION', s.documentType = 'SCIENTIFIC_ARTICLE',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:pubmed-29184669'})
SET s.entityType = 'Source', s.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/',
    s.title = 'PubMed record 29184669', s.sourceKind = 'BIBLIOGRAPHIC_RECORD',
    s.renditionCoverage = 'PARTIAL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:pubmed-30155270'})
SET s.entityType = 'Source', s.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/30155270/',
    s.title = 'PubMed record 30155270 (Author Correction)', s.sourceKind = 'BIBLIOGRAPHIC_RECORD',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (s:Source {uid: 'hu:document:nature-s41514-017-0016-9-html'}), (p:Publication {uid: 'hu:publication:pmid-29184669'})
MERGE (s)-[:RENDITION_OF]->(p);

MATCH (s:Source {uid: 'hu:document:nature-s41514-017-0016-9-pdf'}), (p:Publication {uid: 'hu:publication:pmid-29184669'})
MERGE (s)-[:RENDITION_OF]->(p);

MATCH (s:Source {uid: 'hu:document:pmc-PMC5701244'}), (p:Publication {uid: 'hu:publication:pmid-29184669'})
MERGE (s)-[:RENDITION_OF]->(p);

MATCH (s:Source {uid: 'hu:source:pubmed-29184669'}), (p:Publication {uid: 'hu:publication:pmid-29184669'})
MERGE (s)-[:RENDITION_OF]->(p);

MATCH (s:Source {uid: 'hu:source:pubmed-30155270'}), (p:Publication {uid: 'hu:publication:pmid-30155270'})
MERGE (s)-[:RENDITION_OF]->(p);

// Publication-level correction link (W09 asserted edge CORRECTS; assertion-backed, see fixture 04).

// ---- B. the episode work and four renditions ----
MERGE (e:Episode:Entity {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET e.entityType = 'Episode', e.name = 'Dr. David Sinclair: The Biology of Slowing & Reversing Aging', e.episodeNumber = 52,
    e.publishedAt = datetime('2021-12-27T09:00:00Z'), e.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Document:Source:Entity {uid: 'hu:document:hubermanlab-com-episode-52'})
SET s.entityType = 'Source', s.documentId = 'hubermanlab-com-episode-52',
    s.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging',
    s.title = 'Episode 52 transcript page', s.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', s.documentType = 'WEBPAGE',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:youtube-n9IxomBusuw'})
SET s.entityType = 'Source', s.canonicalUri = 'https://www.youtube.com/watch?v=n9IxomBusuw',
    s.title = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair (YouTube)', s.sourceKind = 'VIDEO_RENDITION',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

// The RSS item is identified by feed + item guid; its enclosure audio is served with dynamic ad insertion,
// so two fetches of the same item can return different bytes (two snapshots, one Source).
MERGE (s:Source:Entity {uid: 'hu:source:megaphone-hubermanlab-item-hl52'})
SET s.entityType = 'Source', s.canonicalUri = 'https://feeds.megaphone.fm/hubermanlab#item-guid-not-captured',
    s.title = 'Huberman Lab RSS item for episode 52 (guid not captured: feed capture was partial)', s.sourceKind = 'AUDIO_FEED_ITEM',
    s.renditionCoverage = 'FULL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:apple-podcasts-hl52'})
SET s.entityType = 'Source',
    s.canonicalUri = 'https://podcasts.apple.com/cm/podcast/the-biology-of-slowing-reversing-aging-dr-david-sinclair/id1545953110?i=1000546195888',
    s.title = 'Apple Podcasts directory record for episode 52', s.sourceKind = 'PODCAST_DIRECTORY_RECORD',
    s.renditionCoverage = 'PARTIAL', s.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (s:Source {uid: 'hu:document:hubermanlab-com-episode-52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

MATCH (s:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

MATCH (s:Source {uid: 'hu:source:megaphone-hubermanlab-item-hl52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

MATCH (s:Source {uid: 'hu:source:apple-podcasts-hl52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

// ---- C. recorded talk (work + one video rendition) versus slide deck (own Source, own container). SYNTHETIC ----
MERGE (e:Episode:Entity {uid: 'hu:episode:synthetic-nad-conference-talk-2026'})
SET e.entityType = 'Episode', e.name = 'Synthetic NAD conference talk (fixture only)', e.fixtureProvenance = 'SYNTHETIC',
    e.publishedAt = datetime('2026-05-14T00:00:00Z'), e.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:synthetic-talk-video'})
SET s.entityType = 'Source', s.canonicalUri = 'https://video.example.invalid/nad-talk-2026',
    s.title = 'Synthetic talk recording (fixture only)', s.sourceKind = 'VIDEO_RENDITION', s.renditionCoverage = 'FULL',
    s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (s:Source {uid: 'hu:source:synthetic-talk-video'}), (e:Episode {uid: 'hu:episode:synthetic-nad-conference-talk-2026'})
MERGE (s)-[:RENDITION_OF]->(e);

MERGE (d:Document:Source:Entity {uid: 'hu:document:synthetic-nad-talk-slides'})
SET d.entityType = 'Source', d.documentId = 'synthetic-nad-talk-slides',
    d.canonicalUri = 'https://conference.example.invalid/slides/nad-talk-2026.pdf',
    d.title = 'Synthetic slide deck for the NAD talk (fixture only)', d.sourceKind = 'PRESENTATION_SLIDES',
    d.documentType = 'CONFERENCE_PRESENTATION', d.fixtureProvenance = 'SYNTHETIC', d.createdAt = datetime('2026-10-04T12:00:00Z');
// Intentionally absent: (deck)-[:RENDITION_OF]->(talk). The link between deck and talk is an assertion by
// the conference page (W21 seam W19-SR-07), not a structural rendition edge.

// ---- C. one claim in the deck and one in the talk: different asserters, different containers ----
// Predicate REPORTS_NAD_CHANGE_AT_DOSE is a fixture-only CANDIDATE predicate (not registered); it exists only to
// carry the container/asserter minimal pair.
MERGE (p:Person:Entity {uid: 'hu:person:synthetic-talk-speaker'})
SET p.entityType = 'Person', p.name = 'Synthetic Speaker (fixture only)', p.fixtureProvenance = 'SYNTHETIC', p.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (o:Organization:Entity {uid: 'hu:org:synthetic-deck-company'})
SET o.entityType = 'Organization', o.name = 'Synthetic NAD Company (fixture only)', o.fixtureProvenance = 'SYNTHETIC', o.createdAt = datetime('2026-10-04T12:00:00Z');

MERGE (c:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide-mononucleotide'})
SET c.entityType = 'ChemicalSubstance', c.name = 'Nicotinamide mononucleotide', c.createdAt = datetime('2026-10-04T12:00:00Z');

MATCH (d:Source {uid: 'hu:document:synthetic-nad-talk-slides'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-nad-talk-slides-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = d.canonicalUri, s.retrievedAt = datetime('2026-10-04T10:00:00Z'),
    s.observedAt = datetime('2026-10-04T10:00:00Z'), s.contentHash = 'synthetic:hu:snapshot:synthetic-nad-talk-slides-2026-10-04',
    s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (d)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-nad-talk-slides-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-slides-p7-nmn-250'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#page=7', l.selectorKind = 'PDF_PAGE', l.page = 7,
    l.exact = 'NMN 250 mg/day raised blood NAD+ in 40 participants.',
    l.quoteHash = 'sha256:5b7dbd32a2c5f00cf8e130f0bd7f22f359956fb61a5ff529b9f7a707c3e51feb', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (v:Source {uid: 'hu:source:synthetic-talk-video'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-talk-video-2026-10-04'})
SET s.artifactType = 'SourceSnapshot', s.canonicalUri = v.canonicalUri, s.retrievedAt = datetime('2026-10-04T10:00:00Z'),
    s.observedAt = datetime('2026-10-04T10:00:00Z'), s.contentHash = 'synthetic:hu:snapshot:synthetic-talk-video-2026-10-04',
    s.contentHashBasis = 'SYNTHETIC_FIXTURE', s.captureCompleteness = 'COMPLETE', s.fixtureProvenance = 'SYNTHETIC', s.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (v)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:synthetic-talk-video-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-talk-video-1210s'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri + '#t=1210,1216', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 1210.0, l.mediaEndSeconds = 1216.0, l.exact = 'we gave a gram a day and NAD doubled',
    l.quoteHash = 'sha256:2854c8a2001acc4258da77a1c85f7ff3d8bd5682fe731a54f285b29d0e2edc1d', l.normalizationVersion = 'NFC-WS1',
    l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (o:Organization {uid: 'hu:org:synthetic-deck-company'}), (d:Source {uid: 'hu:document:synthetic-nad-talk-slides'}),
      (c:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:synthetic-slides-p7-nmn-250'})
MERGE (a:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:synthetic-slides-nmn-250-raises-nad'})
SET a.predicate = 'REPORTS_NAD_CHANGE_AT_DOSE', a.status = 'EXTRACTED', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'STUDY_RESULT', a.valueNumber = 250.0, a.unitCode = 'mg', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l.exact, a.fixtureProvenance = 'SYNTHETIC', a.recordedAt = datetime('2026-10-04T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:OCCURS_IN]->(d)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (p:Person {uid: 'hu:person:synthetic-talk-speaker'}), (e:Episode {uid: 'hu:episode:synthetic-nad-conference-talk-2026'}),
      (c:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}), (l:SourceLocator {uid: 'hu:locator:synthetic-talk-video-1210s'})
MERGE (a:ClaimOccurrence:Assertion {uid: 'hu:claim-occurrence:synthetic-talk-gram-a-day-nad-doubled'})
SET a.predicate = 'REPORTS_NAD_CHANGE_AT_DOSE', a.status = 'EXTRACTED', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'STUDY_RESULT', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l.exact, a.fixtureProvenance = 'SYNTHETIC', a.recordedAt = datetime('2026-10-04T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:OCCURS_IN]->(e)
MERGE (a)-[:SUPPORTED_BY]->(l);
