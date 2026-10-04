// W00 fixture 06 — NEGATIVE: a node carrying two archetype labels (INV-001, D-001). A locator ingested by a generic writer that
// adds :Entity to "everything with a uid" becomes both InformationArtifact and Entity.
// Expected: V-000b returns 1 row (archetypeCount 2) and V-W00-08 returns 1 row (the stray Entity label demands entityType, which a
// locator does not have). Load 00-common-base.cypher first.

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-neg-2026-01-01'})
MERGE (l:SourceLocator:InformationArtifact:Entity {uid: 'hu:locator:w00-two-archetypes'})
ON CREATE SET l.id = 'w00-two-archetypes', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'SECTION', l.section = 'Show notes',
  l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-01-01T00:00:00Z'), l.updatedAt = datetime('2026-01-01T00:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);
