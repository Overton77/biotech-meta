// W00 common base for the negative fixtures 04-07, 10-12 (loaded first by each of them; SYNTHETIC_FIXTURE).
// One capture: source -> snapshot -> TEXT_QUOTE locator, one extraction activity. All valid on its own.
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w00-neg-extraction'})
ON CREATE SET n.id = 'w00-neg-extraction', n.occurrenceType = 'Activity', n.activityKind = 'EXTRACTION', n.methodVersion = 'w00-manual-curation-v1',
  n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

MERGE (n:Source:Entity {uid: 'hu:source:w00-neg-page'})
ON CREATE SET n.id = 'w00-neg-page', n.entityType = 'Source', n.canonicalUri = 'https://w00-negative.example.invalid/page',
  n.title = 'Synthetic negative-case page', n.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

MATCH (src:Source {uid: 'hu:source:w00-neg-page'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-neg-2026-01-01'})
ON CREATE SET s.id = 'w00-neg-2026-01-01', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-01-01T00:00:00Z'), s.observedAt = datetime('2026-01-01T00:00:00Z'),
  s.contentHash = 'sha256:3aaeb1ef07a96b95c2375ab583be6d1279a8db3226a35eb95ddaae0008531906', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'COMPLETE', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-01-01T00:00:00Z'), s.updatedAt = datetime('2026-01-01T00:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-neg-2026-01-01'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-neg-quote'})
ON CREATE SET l.id = 'w00-neg-quote', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
  l.exact = 'We both take a gram of NMN every morning.', l.quoteHash = 'sha256:synthetic-quote-w00-neg-quote', l.normalizationVersion = 'NFC-WS1',
  l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-01-01T00:00:00Z'), l.updatedAt = datetime('2026-01-01T00:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

UNWIND [
  {uid: 'hu:person:w00-cohost-1', id: 'w00-cohost-1', name: 'Synthetic co-host one'},
  {uid: 'hu:person:w00-cohost-2', id: 'w00-cohost-2', name: 'Synthetic co-host two'}
] AS row
MERGE (n:Person:Entity {uid: row.uid})
ON CREATE SET n.id = row.id, n.entityType = 'Person', n.name = row.name, n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:w00-nmn'})
ON CREATE SET n.id = 'w00-nmn', n.entityType = 'ChemicalSubstance', n.name = 'nicotinamide mononucleotide', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-01-01T00:00:00Z'), n.updatedAt = datetime('2026-01-01T00:00:00Z');
