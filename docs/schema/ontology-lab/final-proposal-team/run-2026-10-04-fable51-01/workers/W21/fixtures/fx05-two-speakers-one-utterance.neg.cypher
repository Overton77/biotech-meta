// fx05 NEGATIVE injections.
// N05-a: the exchange recorded as ONE occurrence with two asserters -> V-410 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-guest-assents-gram-resveratrol'}), (host:Person {uid: 'hu:person:andrew-d-huberman'})
MERGE (a)-[:ASSERTED_BY]->(host);
// N05-b: the host's question counted as an instance of the guest's practice claim -> V-W21-11 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-asks-gram-resveratrol'}), (c:Claim {uid: 'hu:claim:sinclair-reports-taking-1g-resveratrol-daily'})
MERGE (a)-[i:INSTANCE_OF]->(c) SET i.derivationRule = 'neg';
// N05-c: the question attributed to its own asserter -> V-W21-04 row.
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-host-asks-gram-resveratrol'}), (host:Person {uid: 'hu:person:andrew-d-huberman'})
MERGE (a)-[:ATTRIBUTES_TO]->(host);
