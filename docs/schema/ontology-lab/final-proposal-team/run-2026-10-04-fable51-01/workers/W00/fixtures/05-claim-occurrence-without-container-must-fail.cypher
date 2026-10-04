// W00 fixture 05 — NEGATIVE: a ClaimOccurrence-shaped assertion (labels ClaimOccurrence, Assertion) with its one asserter but
// NO container (OCCURS_IN). INV-402 / V-410: a ClaimOccurrence has exactly one container and one asserter.
// Expected: V-410 returns exactly 1 row (hu:claim-occurrence:w00-no-container, containers 0, asserters 1).
// Positive control: the same shape with OCCURS_IN an Episode returns no row. Load 00-common-base.cypher first.

MERGE (e:Episode:Entity {uid: 'hu:episode:w00-synthetic-episode-1'})
ON CREATE SET e.id = 'w00-synthetic-episode-1', e.entityType = 'Episode', e.name = 'Synthetic episode 1', e.privacyClass = 'PUBLIC',
  e.createdAt = datetime('2026-01-01T00:00:00Z'), e.updatedAt = datetime('2026-01-01T00:00:00Z');

MATCH (src:Source {uid: 'hu:source:w00-neg-page'}), (e:Episode {uid: 'hu:episode:w00-synthetic-episode-1'})
MERGE (src)-[:RENDITION_OF]->(e);

UNWIND [
  {uid: 'hu:claim-occurrence:w00-no-container', id: 'w00-no-container', container: false},
  {uid: 'hu:claim-occurrence:w00-with-container', id: 'w00-with-container', container: true}
] AS row
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p:Person {uid: 'hu:person:w00-cohost-1'}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'}),
      (act:Activity {uid: 'hu:activity:w00-neg-extraction'}), (e:Episode {uid: 'hu:episode:w00-synthetic-episode-1'})
MERGE (a:ClaimOccurrence:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
  a.speechAct = 'REPORTS_PRACTICE', a.assertionBasis = 'PERSONAL_EXPERIENCE', a.valueNumber = 1.0, a.unitCode = 'g', a.massBasis = 'UNSPECIFIED',
  a.utteranceText = l.exact, a.recordedAt = datetime('2026-01-01T01:00:00Z'), a.privacyClass = 'PUBLIC',
  a.createdAt = datetime('2026-01-01T01:00:00Z'), a.updatedAt = datetime('2026-01-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
FOREACH (_ IN CASE WHEN row.container THEN [1] ELSE [] END | MERGE (a)-[:OCCURS_IN]->(e));
