// W00 fixture 04 — NEGATIVE: one Assertion with two asserters (INV-003, KCR-4.3). Load 00-common-base.cypher first.
// Two co-hosts say one sentence in unison. Writing ONE assertion ASSERTED_BY both counts one locator for two speakers
// and, when either retells it, turns an echo into corroboration. Expected: V-W00-01 returns 1 row (asserters = 2).
// Positive control in the same file: the corroboration form, two Assertions with one asserter each, INSTANCE_OF one Claim.

MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p1:Person {uid: 'hu:person:w00-cohost-1'}), (p2:Person {uid: 'hu:person:w00-cohost-2'}),
      (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'}), (act:Activity {uid: 'hu:activity:w00-neg-extraction'})
MERGE (a:Assertion {uid: 'hu:assertion:w00-two-asserters-merged'})
ON CREATE SET a.id = 'w00-two-asserters-merged', a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
  a.speechAct = 'REPORTS_PRACTICE', a.assertionBasis = 'PERSONAL_EXPERIENCE', a.valueNumber = 1.0, a.unitCode = 'g', a.massBasis = 'UNSPECIFIED',
  a.recordedAt = datetime('2026-01-01T01:00:00Z'), a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-01-01T01:00:00Z'), a.updatedAt = datetime('2026-01-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:ASSERTED_BY]->(p1)
MERGE (a)-[:ASSERTED_BY]->(p2)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

MERGE (c:Claim:Entity {uid: 'hu:claim:w00-takes-1g-nmn-daily'})
ON CREATE SET c.id = 'w00-takes-1g-nmn-daily', c.entityType = 'Claim', c.name = 'Speaker takes 1 g NMN daily', c.privacyClass = 'PUBLIC',
  c.createdAt = datetime('2026-01-01T01:00:00Z'), c.updatedAt = datetime('2026-01-01T01:00:00Z');

UNWIND [
  {uid: 'hu:assertion:w00-cohost-1-intake', id: 'w00-cohost-1-intake', p: 'hu:person:w00-cohost-1'},
  {uid: 'hu:assertion:w00-cohost-2-intake', id: 'w00-cohost-2-intake', p: 'hu:person:w00-cohost-2'}
] AS row
MATCH (subj:ChemicalSubstance {uid: 'hu:substance:w00-nmn'}), (p:Person {uid: row.p}), (l:SourceLocator {uid: 'hu:locator:w00-neg-quote'}),
      (act:Activity {uid: 'hu:activity:w00-neg-extraction'}), (c:Claim {uid: 'hu:claim:w00-takes-1g-nmn-daily'})
MERGE (a:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = 'SELF_REPORTED_DAILY_INTAKE', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
  a.speechAct = 'REPORTS_PRACTICE', a.assertionBasis = 'PERSONAL_EXPERIENCE', a.valueNumber = 1.0, a.unitCode = 'g', a.massBasis = 'UNSPECIFIED',
  a.recordedAt = datetime('2026-01-01T01:00:00Z'), a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-01-01T01:00:00Z'), a.updatedAt = datetime('2026-01-01T01:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(subj)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[i:INSTANCE_OF]->(c)
ON CREATE SET i.derivationRule = 'claim-match-manual/v1', i.derivedAt = datetime('2026-01-01T01:00:00Z');
