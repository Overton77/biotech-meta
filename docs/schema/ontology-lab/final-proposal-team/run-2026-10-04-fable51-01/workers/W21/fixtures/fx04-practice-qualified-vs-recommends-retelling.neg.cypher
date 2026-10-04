// fx04 NEGATIVE injections.
// N04-a: a RECOMMENDS projection derived from the retelling (asserted by the digest author, own act STATES)
// -> V-W21-06 row (and baseline V-423 row, which also lacks the derived-edge form).
MATCH (sp:Person {uid: 'hu:person:david-a-sinclair'}), (n:ChemicalSubstance {uid: 'hu:substance:nicotinamide-mononucleotide'})
MERGE (sp)-[r:RECOMMENDS {derivationRule: 'speech-act-recommends-projection-v1'}]->(n)
SET r.derivedFromAssertionUids = ['hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'], r.derivedAt = datetime('2026-10-04T02:00:00Z');

// N04-b: qualification loss written onto the retelling itself -> V-414 row.
MATCH (r:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-digest-says-sinclair-recommends-nmn'})
SET r.qualificationLost = true;

// N04-c: the retelling merged into the original (second asserter on A1) -> V-410 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'}), (au:Person {uid: 'hu:person:synthetic-digest-author'})
MERGE (a)-[:ASSERTED_BY]->(au);
