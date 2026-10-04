// W23 fixture 13: use-authorization negatives and the fail-open filter minimal pair (load 00-shared-base.cypher first).
// Expected detector rows: 06-fixtures-and-queries.md (V-429, V-W23-07, V-W23-08, V-522; Q-FO-1..3).

// N1: quoting under a RANKING policy (V-429 passes: some PolicyVersion with some useKind exists).
// N2: quoting after the use policy expired (2027-01-01). N3: SHARE_EXTERNALLY, which v1 does not permit.
UNWIND [
  {uid: 'hu:activity:w23-bad-ranking-policy-use', id: 'w23-bad-ranking-policy-use', st: datetime('2026-05-01T09:00:00Z'),
   pv: 'hu:policy-version:w23-sleep-support-ranking-v3', use: 'QUOTE_IN_ANSWER'},
  {uid: 'hu:activity:w23-bad-expired-policy-use', id: 'w23-bad-expired-policy-use', st: datetime('2027-02-01T09:00:00Z'),
   pv: 'hu:policy-version:w23-use-quote-summarize-v1', use: 'QUOTE_IN_ANSWER'},
  {uid: 'hu:activity:w23-bad-unpermitted-use', id: 'w23-bad-unpermitted-use', st: datetime('2026-05-01T09:00:00Z'),
   pv: 'hu:policy-version:w23-use-quote-summarize-v1', use: 'SHARE_EXTERNALLY'}
] AS row
MATCH (pv:PolicyVersion {uid: row.pv}), (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (act:Activity:Occurrence {uid: row.uid})
SET act.id = row.id, act.occurrenceType = 'ACTIVITY', act.activityKind = 'ANSWER_COMPOSITION', act.startedAt = row.st,
    act.methodVersion = 'answer-composer-0.1', act.privacyClass = 'INTERNAL', act.createdAt = row.st
MERGE (act)-[:USED]->(a)
MERGE (act)-[u:AUTHORIZED_BY]->(pv)
SET u.useKind = row.use;

// N4: an answer composition that used an assertion with no authorization at all (V-429).
MATCH (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (act:Activity:Occurrence {uid: 'hu:activity:w23-bad-unauthorized-use'})
SET act.id = 'w23-bad-unauthorized-use', act.occurrenceType = 'ACTIVITY', act.activityKind = 'ANSWER_COMPOSITION',
    act.startedAt = datetime('2026-05-01T09:00:00Z'), act.privacyClass = 'INTERNAL', act.createdAt = datetime('2026-05-01T09:00:00Z')
MERGE (act)-[:USED]->(a);

// N5: a second version of the same use policy whose stated effect overlaps v1 (open end).
MERGE (pv:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-use-quote-summarize-v2-overlap'})
SET pv.id = 'w23-use-quote-summarize-v2-overlap', pv.stateType = 'POLICY_VERSION', pv.policyKey = 'answer-use-authorization', pv.versionLabel = 'v2',
    pv.policyKind = 'USE_AUTHORIZATION', pv.permittedUseKinds = ['QUOTE_IN_ANSWER'], pv.effectiveFrom = datetime('2026-06-01T00:00:00Z'),
    pv.payloadHash = 'sha256:599d90ace82e280ab0d25ff3b57400f72fd2e989aafeeaafb8c16d554a05561a', pv.privacyClass = 'INTERNAL',
    pv.createdAt = datetime('2026-05-20T00:00:00Z');

// N6 (fail-open minimal pair): an unclassified draft policy and an unclassified lineage record (privacyClass never set by an old
// pipeline), reachable from the PUBLIC assertion A2 through USED and AUTHORIZED_BY.
MATCH (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (pv:PolicyVersion:VersionedState {uid: 'hu:policy-version:w23-unclassified-draft'})
SET pv.id = 'w23-unclassified-draft', pv.stateType = 'POLICY_VERSION', pv.policyKey = 'draft-use-policy', pv.versionLabel = 'draft-0',
    pv.policyKind = 'USE_AUTHORIZATION', pv.permittedUseKinds = ['SHARE_EXTERNALLY'], pv.effectiveFrom = datetime('2026-01-01T00:00:00Z'),
    pv.payloadHash = 'sha256:711c7e5ff7719b37528ab856aae6ba2ed947154b8143745f59ca4a1cd18aa2c1', pv.createdAt = datetime('2025-12-01T00:00:00Z')
MERGE (act:Activity:Occurrence {uid: 'hu:activity:w23-unclassified-legacy-run'})
SET act.id = 'w23-unclassified-legacy-run', act.occurrenceType = 'ACTIVITY', act.activityKind = 'ANSWER_COMPOSITION',
    act.startedAt = datetime('2026-06-21T09:00:00Z'), act.externalRunSystem = 'mongo-research', act.externalRunId = 'run-legacy-0099',
    act.createdAt = datetime('2026-06-21T09:00:00Z')
MERGE (act)-[:USED]->(a)
MERGE (act)-[u:AUTHORIZED_BY]->(pv)
SET u.useKind = 'SHARE_EXTERNALLY';
