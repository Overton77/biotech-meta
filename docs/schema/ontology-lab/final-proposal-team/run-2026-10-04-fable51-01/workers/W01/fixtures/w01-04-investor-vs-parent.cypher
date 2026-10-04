// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-04-investor-vs-parent: investor/equity holder versus controlling parent minimal pair (CQ-EC-01,
// CQ-EC-C02). Pioneer Step holds Niagen common stock and has a director-nomination right; it is NOT Niagen's parent.
// Niagen is the parent of ChromaDex, Inc. (w01-03). Affiliate-of between two Horizons companies stays AFFILIATED_WITH,
// never PARENT_OF. Load after w01-01 and w01-03.


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:niagen-bioscience-inc'})
SET n += {id: 'niagen-bioscience-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Niagen Bioscience'};
MERGE (n:Person:Entity {uid: 'hu:person:wendy-yu'})
SET n += {id: 'wendy-yu', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Wendy Yu'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:pioneer-step-holdings-limited'})
SET n += {id: 'pioneer-step-holdings-limited', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Pioneer Step Holdings Limited', legalName: 'Pioneer Step Holdings Limited'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:horizons-digital-group-limited'})
SET n += {id: 'horizons-digital-group-limited', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Horizons Digital Group Limited', legalName: 'Horizons Digital Group Limited'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:horizons-ventures-limited'})
SET n += {id: 'horizons-ventures-limited', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Horizons Ventures Limited', legalName: 'Horizons Ventures Limited', organizationType: 'VENTURE_CAPITAL_FIRM'};

// Equity stake as of a stated date (13D/A of 2024-08-20 relayed by the proxy): the source gives a point-in-time holding, which the kernel
// cannot store as a witness instant (W01-SR-07); both bounds stay null/UNKNOWN. No stakePercent is written (not stated in the excerpt).
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity'})
SET a += {id: 'nage-proxy-2025-pioneer-step-equity', predicate: 'HOLDS_EQUITY_IN', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares (Schedule 13D/A filed 2024-08-20)', contentHash: 'sha256:d1af39ac8bec59ba124b107000d7fe80e3c9dff35b2057f07c3c07168e2e071a'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity'}), (s {uid: 'hu:org:pioneer-step-holdings-limited'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-pioneer-step-beneficial-ownership'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-pioneer-step-equity-capture'})
SET n += {id: 'nage-proxy-2025-pioneer-step-equity-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-pioneer-step-equity-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:pioneer-step-holdings-limited'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:HOLDS_EQUITY_IN {relationshipUid: 'hu:rel:w01-pioneer-step-equity-nage'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-pioneer-step-equity-nage', assertionUid: 'hu:assertion:nage-proxy-2025-pioneer-step-equity', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), stakeClassVerbatim: '6,917,783 shares of common stock; sole voting and dispositive power', roleTitleVerbatim: 'beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares (Schedule 13D/A filed 2024-08-20)'};

// Nomination right: the director is the investor's nominee. That is a tie (AFFILIATED_WITH), not control and not employment.
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step'})
SET a += {id: 'nage-proxy-2025-yu-nominee-of-pioneer-step', predicate: 'AFFILIATED_WITH', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'the director nominated by Pioneer Step Holdings Limited', statedTense: 'PRESENT', contentHash: 'sha256:e9ab8108fd8613bf9e9eb5f1c7d7095599c84252f5265b8da520466a9d795849'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step'}), (s {uid: 'hu:person:wendy-yu'}), (o {uid: 'hu:org:pioneer-step-holdings-limited'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-nominated-by-pioneer-step'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-yu-nominee-of-pioneer-step-capture'})
SET n += {id: 'nage-proxy-2025-yu-nominee-of-pioneer-step-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-yu-nominee-of-pioneer-step-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Person {uid: 'hu:person:wendy-yu'}), (y:Organization {uid: 'hu:org:pioneer-step-holdings-limited'})
MERGE (x)-[r:AFFILIATED_WITH {relationshipUid: 'hu:rel:w01-yu-nominee-pioneer-step'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-yu-nominee-pioneer-step', assertionUid: 'hu:assertion:nage-proxy-2025-yu-nominee-of-pioneer-step', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'the director nominated by Pioneer Step Holdings Limited'};
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital'})
SET a += {id: 'nage-proxy-2025-yu-cdo-horizons-digital', predicate: 'EMPLOYED_BY', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2012-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Chief Digital Officer', statedTense: 'PRESENT', contentHash: 'sha256:3dcae7c7aa5ce86e09491f12cb7902de3607e15679a7c68c4ac08c5a9f492d36'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital'}), (s {uid: 'hu:person:wendy-yu'}), (o {uid: 'hu:org:horizons-digital-group-limited'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-horizons-cdo'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-yu-cdo-horizons-digital-capture'})
SET n += {id: 'nage-proxy-2025-yu-cdo-horizons-digital-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-yu-cdo-horizons-digital-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Person {uid: 'hu:person:wendy-yu'}), (y:Organization {uid: 'hu:org:horizons-digital-group-limited'})
MERGE (x)-[r:EMPLOYED_BY {relationshipUid: 'hu:rel:w01-yu-cdo-horizons-digital'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-yu-cdo-horizons-digital', assertionUid: 'hu:assertion:nage-proxy-2025-yu-cdo-horizons-digital', validFrom: datetime('2012-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), seniorityLevel: 'C_SUITE', roleTitleVerbatim: 'Chief Digital Officer'};
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures'})
SET a += {id: 'nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures', predicate: 'AFFILIATED_WITH', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'affiliate of Horizons Ventures Limited', contentHash: 'sha256:1400775699027a843285629bfc24318910463d9580647c5e4f9999cf1f984acc'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures'}), (s {uid: 'hu:org:horizons-digital-group-limited'}), (o {uid: 'hu:org:horizons-ventures-limited'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-horizons-cdo'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures-capture'})
SET n += {id: 'nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:Organization {uid: 'hu:org:horizons-digital-group-limited'}), (y:Organization {uid: 'hu:org:horizons-ventures-limited'})
MERGE (x)-[r:AFFILIATED_WITH {relationshipUid: 'hu:rel:w01-horizons-digital-affiliate-horizons-ventures'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-horizons-digital-affiliate-horizons-ventures', assertionUid: 'hu:assertion:nage-proxy-2025-horizons-digital-affiliate-of-horizons-ventures', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'affiliate of Horizons Ventures Limited'};
