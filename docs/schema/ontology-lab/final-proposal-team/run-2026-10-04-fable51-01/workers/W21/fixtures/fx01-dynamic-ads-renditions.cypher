// =====================================================================================================
// W21 fixture fx01: same episode, differently timed podcast/video sponsor segments; rendition-bound media time;
// transcript-page locator without invented offsets; caption text version plus transcription Activity;
// platform/channel/series identities; an "Essentials" re-edit as a distinct work (identity collision).
// Run: run-2026-10-04-fable51-01, worker W21 (Opus 5.5). Neo4j 5.26 Community, Cypher 5.
//
// Sources (see ../03-source-manifest.md): SRC-W21-01 publisher transcript page, SRC-W21-02 YouTube rendition,
// SRC-W21-03 Apple Podcasts directory record, SRC-W21-04 Megaphone RSS feed; all NEW_RETRIEVAL 2026-10-04 via
// the Tavily extract API (direct fetch BLOCKED by the egress proxy). Captures are PARTIAL_EXCERPT; contentHash
// and quoteHash are sha256 over NFC-WS1-normalized stored excerpt text (../excerpts/*.txt), basis
// STORED_EXCERPT_TEXT. No audio was captured or verified. The Apple chapter timing is the publisher's stated
// chapter time, not an observed audio offset.
// Rules: every statement binds its own nodes by uid; no variable crosses ';'; nodes carry primary + archetype label.
// uid token `platform` is REQUESTED (W21-SR-01); all other tokens are registered.
// =====================================================================================================

// ---- 1. Identities -----------------------------------------------------------------------------------
MERGE (n:Entity:Person {uid: 'hu:person:andrew-d-huberman'})
SET n.id = 'andrew-d-huberman', n.entityType = 'Person', n.name = 'Andrew D. Huberman', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Person {uid: 'hu:person:david-a-sinclair'})
SET n.id = 'david-a-sinclair', n.entityType = 'Person', n.name = 'David A. Sinclair', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Organization {uid: 'hu:org:scicomm-media'})
SET n.id = 'scicomm-media', n.entityType = 'Organization', n.name = 'Scicomm Media', n.createdAt = datetime('2026-10-04T01:00:00Z');

UNWIND [
  {u: 'hu:brand:insidetracker', i: 'insidetracker', nm: 'InsideTracker'},
  {u: 'hu:brand:ag1', i: 'ag1', nm: 'AG1'},
  {u: 'hu:brand:lmnt', i: 'lmnt', nm: 'LMNT'},
  {u: 'hu:brand:waking-up', i: 'waking-up', nm: 'Waking Up'}
] AS b
MERGE (n:Entity:ConsumerBrand {uid: b.u})
SET n.id = b.i, n.entityType = 'ConsumerBrand', n.name = b.nm, n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})
SET n.id = 'nicotinamide-mononucleotide', n.entityType = 'ChemicalSubstance', n.name = 'Nicotinamide mononucleotide', n.createdAt = datetime('2026-10-04T01:00:00Z');

UNWIND [
  {u: 'hu:platform:youtube', i: 'youtube', nm: 'YouTube', t: 'VIDEO_HOST', url: 'https://www.youtube.com'},
  {u: 'hu:platform:megaphone', i: 'megaphone', nm: 'Megaphone', t: 'AUDIO_FEED_HOST', url: 'https://megaphone.fm'},
  {u: 'hu:platform:apple-podcasts', i: 'apple-podcasts', nm: 'Apple Podcasts', t: 'PODCAST_DIRECTORY', url: 'https://podcasts.apple.com'}
] AS p
MERGE (n:Entity:Platform {uid: p.u})
SET n.id = p.i, n.entityType = 'Platform', n.name = p.nm, n.platformType = p.t, n.url = p.url, n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Channel {uid: 'hu:channel:huberman-lab-youtube'})
SET n.id = 'huberman-lab-youtube', n.entityType = 'Channel', n.name = 'Huberman Lab (YouTube channel)', n.channelType = 'VIDEO_CHANNEL', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'})
SET n.id = 'huberman-lab-megaphone-feed', n.entityType = 'Channel', n.name = 'Huberman Lab (RSS feed feeds.megaphone.fm/hubermanlab)', n.channelType = 'PODCAST_FEED', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Series {uid: 'hu:series:huberman-lab'})
SET n.id = 'huberman-lab', n.entityType = 'Series', n.name = 'Huberman Lab', n.seriesType = 'PODCAST_SERIES', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Series {uid: 'hu:series:huberman-lab-essentials'})
SET n.id = 'huberman-lab-essentials', n.entityType = 'Series', n.name = 'Huberman Lab Essentials', n.seriesType = 'SUB_SERIES', n.createdAt = datetime('2026-10-04T01:00:00Z');

// The work. publishedAt from the RSS feed item pubDate "Mon, 27 Dec 2021 09:00:00 -0000" (SRC-W21-04).
MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
SET n.id = 'huberman-lab-52-sinclair', n.entityType = 'Episode', n.name = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair',
    n.title = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair', n.episodeType = 'FULL', n.episodeNumber = 52,
    n.publishedAt = datetime('2021-12-27T09:00:00Z'), n.publishedAtPrecision = 'INSTANT', n.createdAt = datetime('2026-10-04T01:00:00Z');

// Identity collision: same title stem, same guest, same publisher, different work (re-edited "Essentials" release).
MERGE (n:Entity:Episode {uid: 'hu:episode:huberman-lab-essentials-sinclair-2025-10-30'})
SET n.id = 'huberman-lab-essentials-sinclair-2025-10-30', n.entityType = 'Episode', n.name = 'Essentials: The Biology of Slowing & Reversing Aging | Dr. David Sinclair',
    n.title = 'Essentials: The Biology of Slowing & Reversing Aging | Dr. David Sinclair', n.episodeType = 'FULL', n.episodeNumber = NULL,
    n.publishedAt = datetime('2025-10-30T08:00:00Z'), n.publishedAtPrecision = 'INSTANT', n.createdAt = datetime('2026-10-04T01:00:00Z');

// ---- 2. Structural distribution edges ------------------------------------------------------------------
MATCH (p:Platform {uid: 'hu:platform:youtube'}), (c:Channel {uid: 'hu:channel:huberman-lab-youtube'})
MERGE (p)-[:HOSTS_CHANNEL]->(c);

MATCH (p:Platform {uid: 'hu:platform:megaphone'}), (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'})
MERGE (p)-[:HOSTS_CHANNEL]->(c);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}), (s:Series {uid: 'hu:series:huberman-lab'})
MERGE (c)-[:HAS_SERIES]->(s);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}), (s:Series {uid: 'hu:series:huberman-lab-essentials'})
MERGE (c)-[:HAS_SERIES]->(s);

MATCH (s:Series {uid: 'hu:series:huberman-lab'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[r:HAS_EPISODE]->(e) SET r.orderIndex = 52;

MATCH (s:Series {uid: 'hu:series:huberman-lab-essentials'}), (e:Episode {uid: 'hu:episode:huberman-lab-essentials-sinclair-2025-10-30'})
MERGE (s)-[:HAS_EPISODE]->(e);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-youtube'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (c)-[:HAS_EPISODE]->(e);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (c)-[:HAS_EPISODE]->(e);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}), (e:Episode {uid: 'hu:episode:huberman-lab-essentials-sinclair-2025-10-30'})
MERGE (c)-[:HAS_EPISODE]->(e);

// ---- 3. Agents and activities (capture, transcription, extraction) -----------------------------------
MERGE (n:Entity:Agent {uid: 'hu:agent:tavily-extract'})
SET n.id = 'tavily-extract', n.entityType = 'Agent', n.name = 'Tavily extract API', n.agentKind = 'AUTOMATED_AGENT', n.toolVersion = 'unknown', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Agent {uid: 'hu:agent:w21-curator'})
SET n.id = 'w21-curator', n.entityType = 'Agent', n.name = 'W21 fixture curator (Opus 5.5)', n.agentKind = 'MANUAL_AGENT', n.createdAt = datetime('2026-10-04T01:00:00Z');

// Caption producer: whether the YouTube caption track is auto-generated or uploaded by the channel is NOT established.
MERGE (n:Entity:Agent {uid: 'hu:agent:youtube-caption-track-hl52-producer-unknown'})
SET n.id = 'youtube-caption-track-hl52-producer-unknown', n.entityType = 'Agent', n.name = 'Producer of the YouTube caption track for n9IxomBusuw (auto-generated or uploaded: not established)',
    n.agentKind = NULL, n.createdAt = datetime('2026-10-04T01:00:00Z');

// Publisher transcription process; the page states the text is under human review.
MERGE (n:Entity:Agent {uid: 'hu:agent:hubermanlab-transcription-process'})
SET n.id = 'hubermanlab-transcription-process', n.entityType = 'Agent', n.name = 'Huberman Lab transcript production (method not published)', n.agentKind = NULL, n.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (g:Agent {uid: 'hu:agent:hubermanlab-transcription-process'}), (o:Organization {uid: 'hu:org:scicomm-media'})
MERGE (g)-[:ACTED_ON_BEHALF_OF]->(o);

MATCH (g:Agent {uid: 'hu:agent:tavily-extract'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-capture-2026-10-04'})
SET a.id = 'w21-capture-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'CAPTURE', a.startedAt = datetime('2026-10-04T00:49:00Z'),
    a.endedAt = datetime('2026-10-04T00:52:00Z'), a.methodVersion = 'tavily-extract advanced, query-reranked chunks', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (g:Agent {uid: 'hu:agent:youtube-caption-track-hl52-producer-unknown'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:youtube-captioning-hl52'})
SET a.id = 'youtube-captioning-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.startedAt = NULL, a.endedAt = NULL,
    a.methodVersion = 'unknown (platform caption track)', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (g:Agent {uid: 'hu:agent:hubermanlab-transcription-process'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
SET a.id = 'hubermanlab-transcription-hl52', a.occurrenceType = 'Activity', a.activityKind = 'TRANSCRIPTION', a.startedAt = NULL, a.endedAt = NULL,
    a.methodVersion = 'publisher transcript; stated "under human review"', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

MATCH (g:Agent {uid: 'hu:agent:w21-curator'})
MERGE (a:Occurrence:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
SET a.id = 'w21-extraction-2026-10-04', a.occurrenceType = 'Activity', a.activityKind = 'EXTRACTION', a.startedAt = datetime('2026-10-04T01:00:00Z'),
    a.methodVersion = 'w21-manual-curation-v0.1', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:WAS_ASSOCIATED_WITH]->(g);

// ---- 4. Sources (renditions and the feed), snapshots, text versions ----------------------------------
MERGE (n:Entity:Source:Document {uid: 'hu:source:hubermanlab-com-episode-52'})
SET n.id = 'hubermanlab-com-episode-52', n.documentId = 'hubermanlab-com-episode-52', n.entityType = 'Source',
    n.canonicalUri = 'https://www.hubermanlab.com/episode/dr-david-sinclair-the-biology-of-slowing-and-reversing-aging',
    n.title = 'Dr. David Sinclair: The Biology of Slowing & Reversing Aging (transcript page)', n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE',
    n.type = 'WEBPAGE', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Source {uid: 'hu:source:youtube-n9IxomBusuw'})
SET n.id = 'youtube-n9IxomBusuw', n.entityType = 'Source', n.canonicalUri = 'https://www.youtube.com/watch?v=n9IxomBusuw',
    n.title = 'The Biology of Slowing & Reversing Aging | Dr. David Sinclair', n.sourceKind = 'VIDEO_RENDITION', n.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (n:Entity:Source {uid: 'hu:source:apple-podcasts-hl52'})
SET n.id = 'apple-podcasts-hl52', n.entityType = 'Source', n.canonicalUri = 'https://podcasts.apple.com/us/podcast/the-biology-of-slowing-reversing-aging-dr-david-sinclair/id1545953110?i=1000546195888',
    n.title = 'The Biology of Slowing & Rever… - Huberman Lab - Apple Podcasts', n.sourceKind = 'PODCAST_DIRECTORY_RECORD', n.createdAt = datetime('2026-10-04T01:00:00Z');

// The feed lists many episodes: it is a Source, NOT a rendition of any one episode. sourceKind for a whole feed
// document is not in the catalog list (seam W21-SR-13); left null rather than mislabelled AUDIO_FEED_ITEM.
MERGE (n:Entity:Source {uid: 'hu:source:megaphone-feed-hubermanlab'})
SET n.id = 'megaphone-feed-hubermanlab', n.entityType = 'Source', n.canonicalUri = 'https://feeds.megaphone.fm/hubermanlab',
    n.title = 'Huberman Lab (RSS)', n.sourceKind = NULL, n.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (s:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);
MATCH (s:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);
// A directory record presents the feed item (metadata plus a player for the feed audio): a rendition (W21-D03).
MATCH (s:Source {uid: 'hu:source:apple-podcasts-hl52'}), (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (s)-[:RENDITION_OF]->(e);

MATCH (c:Channel {uid: 'hu:channel:huberman-lab-youtube'}), (s:Source {uid: 'hu:source:youtube-n9IxomBusuw'})
MERGE (c)-[:DISTRIBUTES_RENDITION]->(s);
MATCH (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}), (s:Source {uid: 'hu:source:megaphone-feed-hubermanlab'})
MERGE (c)-[:DISTRIBUTES_RENDITION]->(s);

MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (act:Activity {uid: 'hu:activity:w21-capture-2026-10-04'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'})
SET s.id = 'hubermanlab-52-page-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:49:30Z'), s.observedAt = datetime('2026-10-04T00:49:30Z'), s.publishedAt = NULL,
    s.contentHash = 'sha256:19e3e32cbaca1a127bebb1404237659509bd64e97066577208b25bc71278511e', s.contentHashBasis = 'STORED_EXCERPT_TEXT',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.storageUri = 'repo:workers/W21/excerpts/hl52-page-2026-10-04.txt',
    s.publisherRevisionNotice = 'This transcript is currently under human review and may contain errors. The fully reviewed version will be posted as soon as it is available.',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (act:Activity {uid: 'hu:activity:w21-capture-2026-10-04'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'})
SET s.id = 'youtube-n9IxomBusuw-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:50:00Z'), s.observedAt = datetime('2026-10-04T00:50:00Z'),
    s.contentHash = 'sha256:346af1dd8abcb9f0c2adaeb4a505f5b5ae51d290282cc091c9a68cff3dfcba0f', s.contentHashBasis = 'STORED_EXCERPT_TEXT',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.storageUri = 'repo:workers/W21/excerpts/hl52-youtube-2026-10-04.txt',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:apple-podcasts-hl52'}), (act:Activity {uid: 'hu:activity:w21-capture-2026-10-04'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:apple-podcasts-hl52-2026-10-04'})
SET s.id = 'apple-podcasts-hl52-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:51:00Z'), s.observedAt = datetime('2026-10-04T00:51:00Z'),
    s.contentHash = 'sha256:790743967990d009cd84abab602acf5b21ef86e1fd2f82a54c95a06cff94ccc5', s.contentHashBasis = 'STORED_EXCERPT_TEXT',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.storageUri = 'repo:workers/W21/excerpts/hl52-apple-2026-10-04.txt',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:megaphone-feed-hubermanlab'}), (act:Activity {uid: 'hu:activity:w21-capture-2026-10-04'})
MERGE (s:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:megaphone-feed-hubermanlab-2026-10-04'})
SET s.id = 'megaphone-feed-hubermanlab-2026-10-04', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
    s.retrievedAt = datetime('2026-10-04T00:52:00Z'), s.observedAt = datetime('2026-10-04T00:52:00Z'),
    s.contentHash = 'sha256:11d598ac1fe45a7f60cb7c723a8028dfbcfb18fd0e59f8848474fb392244495d', s.contentHashBasis = 'STORED_EXCERPT_TEXT',
    s.captureCompleteness = 'PARTIAL_EXCERPT', s.storageUri = 'repo:workers/W21/excerpts/hl-feed-2026-10-04.txt',
    s.mimeType = 'text/plain', s.language = 'en', s.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s)
MERGE (s)-[:WAS_GENERATED_BY]->(act);

// Two text versions of two renditions, each generated by its own TRANSCRIPTION activity. Their wording differs
// ("My 82 -year-old father" versus "my 82-year-old father"); neither is audio-verified.
MATCH (src:Source {uid: 'hu:source:hubermanlab-com-episode-52'}), (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}),
      (act:Activity {uid: 'hu:activity:hubermanlab-transcription-hl52'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
SET tv.id = 'hubermanlab-52-page-2026-10-04', tv.documentTextVersionId = 'hubermanlab-52-page-2026-10-04', tv.artifactType = 'DocumentTextVersion',
    tv.textVersionHash = s.contentHash, tv.source = 'publisher-transcript (excerpt)', tv.versionLabel = 'under human review (as stated 2026-10-04)',
    tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

MATCH (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}), (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}),
      (act:Activity {uid: 'hu:activity:youtube-captioning-hl52'})
MERGE (tv:InformationArtifact:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
SET tv.id = 'youtube-n9IxomBusuw-captions-2026-10-04', tv.documentTextVersionId = 'youtube-n9IxomBusuw-captions-2026-10-04', tv.artifactType = 'DocumentTextVersion',
    tv.textVersionHash = s.contentHash, tv.source = 'platform caption track (excerpt)', tv.versionLabel = 'caption cues with rendition timestamps',
    tv.normalizationVersion = 'NFC-WS1', tv.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (src)-[:HAS_TEXT_VERSION]->(tv)
MERGE (tv)-[:TEXT_OF_SNAPSHOT]->(s)
MERGE (tv)-[:WAS_GENERATED_BY]->(act);

// ---- 5. Locators --------------------------------------------------------------------------------------
// Transcript page: TEXT_QUOTE only. The page has no timestamps for this span; no media seconds are invented.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:hubermanlab-52-page-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:hubermanlab-52-page-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'})
SET l.id = 'w21-hl52-page-nmn-gram-daily', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'My 82 -year-old father, we take a gram of NMN every day.',
    l.prefix = "Well, I'm always happy to tell you what I do and what my father does. ", l.suffix = " Andrew Huberman: So it's a gram of resveratrol and a gram of NMN.",
    l.quoteHash = 'sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56', l.normalizationVersion = 'NFC-WS1',
    l.speakerLabelInSource = 'David Sinclair', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// YouTube rendition: the same utterance, its own wording and its own timeline (cue [1:02:45] to next cue [1:02:53]).
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'}), (tv:DocumentTextVersion {uid: 'hu:text-version:youtube-n9IxomBusuw-captions-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-nmn-gram-daily'})
SET l.id = 'w21-hl52-youtube-nmn-gram-daily', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=3765s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 3765.0, l.mediaEndSeconds = 3773.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "Well, I'm always happy to tell you what I do and what my father does, my 82-year-old father, we take a gram of NMN every day.",
    l.quoteHash = "sha256:40f0b8bdaab85d0cb262ad20f77ed23370f9572412a6794ad6c3c2252fa33c48",
    l.normalizationVersion = 'NFC-WS1', l.speakerLabelInSource = NULL, l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l)
MERGE (l)-[:LOCATOR_IN_TEXT_VERSION]->(tv);

// YouTube host-read sponsor message (cue [4:47]..[4:55]).
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'})
SET l.id = 'w21-hl52-youtube-insidetracker-sponsor-read', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=287s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 287.0, l.mediaEndSeconds = 295.0, l.mediaTimeBasis = 'RENDITION_TRANSCRIPT_CUE',
    l.exact = "Today's episode is also brought to us by InsideTracker.", l.quoteHash = "sha256:c68c127ba0e0d1b94a8a8135d2dfd87dd3d383c46d1bc9da2ab43f9598518659",
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// Chapter markers: publisher-stated chapter starts on each rendition's own timeline (basis PUBLISHER_CHAPTER).
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:youtube-n9IxomBusuw-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-chapter-sponsors'})
SET l.id = 'w21-hl52-youtube-chapter-sponsors', l.artifactType = 'SourceLocator', l.uri = 'https://www.youtube.com/watch?v=n9IxomBusuw&t=210s', l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 210.0, l.mediaEndSeconds = 465.0, l.mediaTimeBasis = 'PUBLISHER_CHAPTER',
    l.exact = 'ROKA, InsideTracker, Magic Spoon', l.quoteHash = 'sha256:c0f7b8098929e42683257d2d5b5fc6f52c0912e0850c98ef421ce22d7e714ad1',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// Apple Podcasts record (presents the feed audio): chapter "00:03:45 Sponsors: AG1, LMNT & Waking Up" as observed
// 2026-10-04. The audio was not played or captured; the time is the publisher's stated chapter start.
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:apple-podcasts-hl52-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-hl52-apple-chapter-sponsors'})
SET l.id = 'w21-hl52-apple-chapter-sponsors', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'MEDIA_TIME',
    l.mediaStartSeconds = 225.0, l.mediaEndSeconds = 465.0, l.mediaTimeBasis = 'PUBLISHER_CHAPTER',
    l.exact = '00:03:45 Sponsors: AG1, LMNT & Waking Up', l.quoteHash = 'sha256:1b6714c8decfe4e9994300d80ebcfe36468832f9c8224bb9e031e60e5663032f',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// Feed item lines (publication evidence for the two distinct works).
MATCH (s:SourceSnapshot {uid: 'hu:snapshot:megaphone-feed-hubermanlab-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-feed-item-hl52'})
SET l.id = 'w21-feed-item-hl52', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Mon, 27 Dec 2021 09:00:00 -0000 The Biology of Slowing & Reversing Aging | Dr. David Sinclair full 52 Scicomm Media',
    l.quoteHash = 'sha256:776e0d0834a2a12ed7d4ba96d0769fbf862c728bd294e5e3a841c575d0c90ead',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:megaphone-feed-hubermanlab-2026-10-04'})
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:w21-feed-item-essentials'})
SET l.id = 'w21-feed-item-essentials', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Thu, 30 Oct 2025 08:00:00 -0000 Essentials: The Biology of Slowing & Reversing Aging | Dr. David Sinclair full Scicomm Media',
    l.quoteHash = 'sha256:ca5d8e94f0b346fd73d19967f99289783aa739fbe10bccaa06edec4493555136',
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

// ---- 6. Segments: rendition-specific sponsor segments versus a work-level editorial chapter -----------
MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (src:Source {uid: 'hu:source:youtube-n9IxomBusuw'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-chapter-sponsors'})
MERGE (g:InformationArtifact:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'})
SET g.id = 'hl52-youtube-sponsor-block', g.artifactType = 'EpisodeSegment', g.segmentType = 'SPONSOR_READ',
    g.chapterTitleVerbatim = 'ROKA, InsideTracker, Magic Spoon', g.delimitationBasis = 'PUBLISHER_CHAPTER',
    g.observedAt = datetime('2026-10-04T00:50:00Z'), g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (e)-[r:HAS_SEGMENT]->(g) SET r.orderIndex = 2
MERGE (g)-[:IN_RENDITION]->(src)
MERGE (g)-[:DELIMITED_BY]->(l);

MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (src:Source {uid: 'hu:source:apple-podcasts-hl52'}),
      (l:SourceLocator {uid: 'hu:locator:w21-hl52-apple-chapter-sponsors'})
MERGE (g:InformationArtifact:EpisodeSegment {uid: 'hu:episode-segment:hl52-feed-sponsor-block-observed-2026-10-04'})
SET g.id = 'hl52-feed-sponsor-block-observed-2026-10-04', g.artifactType = 'EpisodeSegment', g.segmentType = 'SPONSOR_READ',
    g.chapterTitleVerbatim = 'Sponsors: AG1, LMNT & Waking Up', g.delimitationBasis = 'PUBLISHER_CHAPTER',
    g.observedAt = datetime('2026-10-04T00:51:00Z'), g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (e)-[r:HAS_SEGMENT]->(g) SET r.orderIndex = 2
MERGE (g)-[:IN_RENDITION]->(src)
MERGE (g)-[:DELIMITED_BY]->(l);

// Work-level editorial chapter (same chapter title at 56:45 in all three listings); not delimited by any captured locator.
MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (g:InformationArtifact:EpisodeSegment {uid: 'hu:episode-segment:hl52-chapter-resveratrol-nad-nmn'})
SET g.id = 'hl52-chapter-resveratrol-nad-nmn', g.artifactType = 'EpisodeSegment', g.segmentType = 'CHAPTER',
    g.chapterTitleVerbatim = 'Resveratrol, NAD, NMN, NR; Dosage, Timing', g.delimitationBasis = 'NOT_DELIMITED',
    g.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (e)-[r:HAS_SEGMENT]->(g) SET r.orderIndex = 14;

// ---- 7. Assertions --------------------------------------------------------------------------------------
// A1: the guest's practice report, one act of asserting, supported by locators in two renditions.
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (nmn:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'}),
      (l1:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'}), (l2:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-nmn-gram-daily'}),
      (seg:EpisodeSegment {uid: 'hu:episode-segment:hl52-chapter-resveratrol-nad-nmn'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})
SET a.id = 'w21-hl52-sinclair-nmn-1g-daily', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE', a.valueNumber = 1.0, a.unitCode = 'g', a.quantityBasis = 'PER_DAY',
    a.utteranceText = l1.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.statedTense = 'PRESENT',
    a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.extractionMethod = 'manual', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(nmn)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(seg)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// A6: host-read sponsor message in the YouTube rendition. Valid time: from publication (PUBLICATION_PROXY).
MATCH (host:Person {uid: 'hu:person:andrew-d-huberman'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-youtube-insidetracker-sponsor-read'}),
      (seg:EpisodeSegment {uid: 'hu:episode-segment:hl52-youtube-sponsor-block'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'})
SET a.id = 'w21-hl52-youtube-host-read-insidetracker', a.predicate = 'SPONSORS_CONTENT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'STATES', a.segmentKind = 'SPONSOR_READ',
    a.validFrom = datetime('2021-12-27T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY', a.validTo = NULL, a.validToBasis = 'UNKNOWN',
    a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.extractionMethod = 'manual', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(br)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:ASSERTED_BY]->(host)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(seg)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// F1..F3: publisher show-notes sponsor statements for the feed-presented audio, observed 2026-10-04. Dynamic ad
// insertion: valid time is OBSERVATION_ONLY (validFrom null), never back-projected to 2021.
UNWIND [
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-ag1', i: 'w21-hl52-feed-shownotes-sponsor-ag1', b: 'hu:brand:ag1'},
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-lmnt', i: 'w21-hl52-feed-shownotes-sponsor-lmnt', b: 'hu:brand:lmnt'},
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-waking-up', i: 'w21-hl52-feed-shownotes-sponsor-waking-up', b: 'hu:brand:waking-up'}
] AS row
MATCH (pub:Organization {uid: 'hu:org:scicomm-media'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}),
      (br:ConsumerBrand {uid: row.b}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-apple-chapter-sponsors'}),
      (seg:EpisodeSegment {uid: 'hu:episode-segment:hl52-feed-sponsor-block-observed-2026-10-04'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion:ClaimOccurrence {uid: row.a})
SET a.id = row.i, a.predicate = 'SPONSORS_CONTENT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.assertionBasis = 'UNSTATED', a.speechAct = 'STATES', a.segmentKind = 'SPONSOR_READ',
    a.validFrom = NULL, a.validFromBasis = 'OBSERVATION_ONLY', a.validTo = NULL, a.validToBasis = 'UNKNOWN',
    a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.extractionMethod = 'manual', a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(br)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:ASSERTED_BY]->(pub)
MERGE (a)-[:OCCURS_IN]->(ep)
MERGE (a)-[:OCCURS_IN_SEGMENT]->(seg)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

// Projected asserted edges (asserted_edge profile; bounds equal the authorizing assertion's).
MATCH (br:ConsumerBrand {uid: 'hu:brand:insidetracker'}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (br)-[r:SPONSORS_CONTENT {assertionUid: 'hu:claim-occurrence:w21-hl52-youtube-host-read-insidetracker'}]->(ep)
SET r.relationshipUid = 'hu:rel:w21-sponsors-content-insidetracker-hl52', r.validFrom = datetime('2021-12-27T00:00:00Z'), r.validFromPrecision = 'DAY',
    r.validFromBasis = 'PUBLICATION_PROXY', r.validTo = NULL, r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:00:00Z'), r.recordedTo = NULL;

UNWIND [
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-ag1', b: 'hu:brand:ag1', r: 'hu:rel:w21-sponsors-content-ag1-hl52'},
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-lmnt', b: 'hu:brand:lmnt', r: 'hu:rel:w21-sponsors-content-lmnt-hl52'},
  {a: 'hu:claim-occurrence:w21-hl52-feed-shownotes-sponsor-waking-up', b: 'hu:brand:waking-up', r: 'hu:rel:w21-sponsors-content-waking-up-hl52'}
] AS row
MATCH (br:ConsumerBrand {uid: row.b}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MERGE (br)-[r:SPONSORS_CONTENT {assertionUid: row.a}]->(ep)
SET r.relationshipUid = row.r, r.validFrom = NULL, r.validFromBasis = 'OBSERVATION_ONLY', r.validTo = NULL, r.validToBasis = 'UNKNOWN',
    r.recordedFrom = datetime('2026-10-04T01:00:00Z'), r.recordedTo = NULL;

// Appearance roles: generic Assertions read from the transcript page speaker labels; projected APPEARS_IN edges.
UNWIND [
  {a: 'hu:assertion:w21-hl52-huberman-appears-host', i: 'w21-hl52-huberman-appears-host', p: 'hu:person:andrew-d-huberman', role: 'HOST', rel: 'hu:rel:w21-appears-in-huberman-hl52'},
  {a: 'hu:assertion:w21-hl52-sinclair-appears-guest', i: 'w21-hl52-sinclair-appears-guest', p: 'hu:person:david-a-sinclair', role: 'GUEST', rel: 'hu:rel:w21-appears-in-sinclair-hl52'}
] AS row
MATCH (p:Person {uid: row.p}), (ep:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'}), (l:SourceLocator {uid: 'hu:locator:w21-hl52-page-nmn-gram-daily'}),
      (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion {uid: row.a})
SET a.id = row.i, a.predicate = 'APPEARS_IN', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.roleType = row.role,
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(ep)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (p)-[r:APPEARS_IN {assertionUid: row.a}]->(ep)
SET r.relationshipUid = row.rel, r.roleType = row.role, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:00:00Z');

// Channel operator (candidate predicate OPERATES_CHANNEL, registration W21-SR-15): PROPOSED until registered.
MATCH (o:Organization {uid: 'hu:org:scicomm-media'}), (c:Channel {uid: 'hu:channel:huberman-lab-megaphone-feed'}),
      (l:SourceLocator {uid: 'hu:locator:w21-feed-item-hl52'}), (act:Activity {uid: 'hu:activity:w21-extraction-2026-10-04'})
MERGE (a:Assertion {uid: 'hu:assertion:w21-scicomm-operates-hubermanlab-feed'})
SET a.id = 'w21-scicomm-operates-hubermanlab-feed', a.predicate = 'OPERATES_CHANNEL', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:00:00Z'), a.createdAt = datetime('2026-10-04T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (o)-[r:OPERATES_CHANNEL {assertionUid: 'hu:assertion:w21-scicomm-operates-hubermanlab-feed'}]->(c)
SET r.relationshipUid = 'hu:rel:w21-operates-channel-scicomm-feed', r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:00:00Z');

// ---- 8. Capture-fidelity policy adjudication (INV-103); says nothing about truth -------------------------
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:w21-fx01-capture-fidelity-policy'})
ON CREATE SET j.id = 'w21-fx01-capture-fidelity-policy', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w21-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.rationale = 'Fixture capture policy: recorded propositions match the cited spans as read by W21; not a truth verdict.',
    j.reviewedAt = datetime('2026-10-04T01:30:00Z'), j.recordedAt = datetime('2026-10-04T01:30:00Z'), j.createdAt = datetime('2026-10-04T01:30:00Z'), j.privacyClass = 'internal'
MERGE (j)-[:EVALUATES]->(a);
