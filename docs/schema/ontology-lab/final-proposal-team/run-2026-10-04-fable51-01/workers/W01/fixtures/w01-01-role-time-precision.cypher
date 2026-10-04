// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-01-role-time-precision: time-bounded board and officer roles at YEAR and MONTH precision (CQ-AX-18,
// CQ-CL-05 time part, CQ-TM-04), plus a temporal correction (EXTRACTION_FIX) of a year-precision end bound.
// Sources: Niagen Bioscience 2025 DEF 14A (NEW_RETRIEVAL, Tavily extract, PARTIAL_EXCERPT); Sinclair affiliations page
// (INHERITED SRC-SINCLAIR-AFFILIATIONS, re-extracted 2026-10-04).


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};

// Identities
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:niagen-bioscience-inc'})
SET n += {id: 'niagen-bioscience-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Niagen Bioscience', legalName: 'Niagen Bioscience, Inc.', jurisdiction: 'US-DE', organizationType: 'COMPANY'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:segterra'})
SET n += {id: 'segterra', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Segterra'};
MERGE (n:Person:Entity {uid: 'hu:person:wendy-yu'})
SET n += {id: 'wendy-yu', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Wendy Yu'};
MERGE (n:Person:Entity {uid: 'hu:person:robert-fried'})
SET n += {id: 'robert-fried', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Robert Fried'};
MERGE (n:Person:Entity {uid: 'hu:person:frank-jaksch-jr'})
SET n += {id: 'frank-jaksch-jr', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Frank Jaksch, Jr.'};
MERGE (n:Person:Entity {uid: 'hu:person:steven-rubin'})
SET n += {id: 'steven-rubin', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'Steven Rubin'};
MERGE (n:Person:Entity {uid: 'hu:person:david-a-sinclair'})
SET n += {id: 'david-a-sinclair', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Person', name: 'David A. Sinclair'};

// Sources, snapshots, locators
MERGE (n:Source:Entity {uid: 'hu:source:sec-nage-def14a-2025'})
SET n += {id: 'sec-nage-def14a-2025', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000162828025020690/cdxc-20250429.htm', sourceKind: 'SECURITIES_FILING', title: 'Niagen Bioscience, Inc. definitive proxy statement, 2025 annual meeting'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'})
SET n += {id: 'sec-nage-def14a-2025-tavily-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:56:00Z'), observedAt: datetime('2026-10-04T00:56:00Z'), publishedAt: datetime('2025-04-29T00:00:00Z'), publishedAtPrecision: 'DAY', captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:a273fd0d090038ef8f5de55276dd858d8b6203ec4f7549a56ecf394d59d10f34'};
MATCH (s:Source {uid: 'hu:source:sec-nage-def14a-2025'}), (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-yu-since-august-2017'})
SET n += {id: 'nage-proxy-2025-yu-since-august-2017', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'has been a director of the Company since August 2017', quoteHash: 'sha256:c91529ce6597e1e4eb6b116bdacf890a1dd4cb595f1a224fd2f993ace6f3f2c2', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-since-august-2017'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-fried-ceo-june-2018'})
SET n += {id: 'nage-proxy-2025-fried-ceo-june-2018', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Mr. Robert Fried, who became our Chief Executive Officer in June 2018', quoteHash: 'sha256:4065b38d0c8c171a57653a136c0c32365c62680d107d27ed42774dd2a06d02ae', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-fried-ceo-june-2018'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-jaksch-transition-july-2022'})
SET n += {id: 'nage-proxy-2025-jaksch-transition-july-2022', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Mr. Frank Jaksch, Jr., who transitioned from Executive Chairman to Chairman of the Board in July 2022', quoteHash: 'sha256:077917bf4566aa568808241d54a56eee8e2557d3b8caf88dd62b97eb90863106', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-jaksch-transition-july-2022'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-yu-nominated-by-pioneer-step'})
SET n += {id: 'nage-proxy-2025-yu-nominated-by-pioneer-step', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Ms. Yu serves as the director nominated by Pioneer Step Holdings Limited pursuant to rights granted to Pioneer Step Holdings Limited pursuant to that certain Securities Purchase Agreement, dated April 26, 2017', quoteHash: 'sha256:f1aeb85e716b462dcc0d9cda9c0646ea094906152f305362a4ba5d978ba91000', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-nominated-by-pioneer-step'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-yu-horizons-cdo'})
SET n += {id: 'nage-proxy-2025-yu-horizons-cdo', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Since 2012, Ms. Yu has served as the Chief Digital Officer of Horizons Digital Group Limited (affiliate of Horizons Ventures Limited, a Hong Kong based investment firm)', quoteHash: 'sha256:458b2da670f4ec19fa7365907ea531d328a59e67505f25d3dbcd067c013c7b8a', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-horizons-cdo'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-pioneer-step-beneficial-ownership'})
SET n += {id: 'nage-proxy-2025-pioneer-step-beneficial-ownership', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Pioneer Step Holdings Limited (“Pioneer Step”) beneficially owned and had sole voting and dispositive power with respect to 6,917,783 shares', quoteHash: 'sha256:f4634363db8e592ddf4f58beb4fd49243749a7bd87e84d26c3ad113516f9c536', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-pioneer-step-beneficial-ownership'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-formerly-chromadex-delaware'})
SET n += {id: 'nage-proxy-2025-formerly-chromadex-delaware', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Niagen Bioscience, Inc. (formerly ChromaDex Corporation), a Delaware corporation', quoteHash: 'sha256:71bdd5c2d1425b2f6bda72ee71802bcc34b7a4089cd44474d9914ceb160318db', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-formerly-chromadex-delaware'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-nominee-table-wendy-yu'})
SET n += {id: 'nage-proxy-2025-nominee-table-wendy-yu', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'SECTION', section: 'Proposal 1 director nominee table (columns Nominee | Age | Director Since), row for Wendy Yu'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-wendy-yu'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-nominee-table-robert-fried'})
SET n += {id: 'nage-proxy-2025-nominee-table-robert-fried', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'SECTION', section: 'Proposal 1 director nominee table (columns Nominee | Age | Director Since), row for Robert Fried'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-robert-fried'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-nominee-table-frank-jaksch-jr'})
SET n += {id: 'nage-proxy-2025-nominee-table-frank-jaksch-jr', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'SECTION', section: 'Proposal 1 director nominee table (columns Nominee | Age | Director Since), row for Frank Jaksch Jr'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-frank-jaksch-jr'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-proxy-2025-nominee-table-steven-rubin'})
SET n += {id: 'nage-proxy-2025-nominee-table-steven-rubin', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'SECTION', section: 'Proposal 1 director nominee table (columns Nominee | Age | Director Since), row for Steven Rubin'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-def14a-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-steven-rubin'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:Source:Entity {uid: 'hu:source:sinclair-lab-affiliations'})
SET n += {id: 'sinclair-lab-affiliations', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations', sourceKind: 'SELF_DISCLOSURE_PAGE', title: 'David A. Sinclair\'s Affiliations (The Sinclair Lab)'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'})
SET n += {id: 'w01-sinclair-affiliations-2026-10-03-replica', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-03T11:00:00Z'), observedAt: datetime('2026-10-03T11:00:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:3c83cc11e3b775b5e923f377634cfb41f319b868973792d7feee4f13d7a8aec7'};
MATCH (s:Source {uid: 'hu:source:sinclair-lab-affiliations'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'})
SET n += {id: 'w01-sinclair-affiliations-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:58:00Z'), observedAt: datetime('2026-10-04T00:58:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:3c83cc11e3b775b5e923f377634cfb41f319b868973792d7feee4f13d7a8aec7'};
MATCH (s:Source {uid: 'hu:source:sinclair-lab-affiliations'}), (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
SET n += {id: 'sinclair-affiliations-2026-10-03-insidetracker-line', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)', quoteHash: 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-03-replica'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'})
SET n += {id: 'sinclair-affiliations-2026-10-04-insidetracker-line', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)', quoteHash: 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
SET n += {id: 'sinclair-affiliations-2026-10-04-legend', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'F=Founder; I=Investor; E=Equity; A=Advisor/Consultant; B=Board of Directors; IP=Inventor on licensed patents; L=Funding for laboratory', quoteHash: 'sha256:e95a85b7bed49bb35677e657d428478a4a694f4153ac6285d8d497e7c759609d', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:w01-sinclair-affiliations-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MATCH (n:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), (o:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
MERGE (n)-[r:REANCHORS]->(o)
SET r.anchorMatch = 'EXACT', r.activityUid = 'hu:activity:w01-curation-2026-10-04';

// Role assertions asserted by the issuer in its proxy statement (asserter = the LegalEntity that filed)
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-2017'})
SET a += {id: 'nage-proxy-2025-yu-director-since-2017', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2017-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Director Since 2017', contentHash: 'sha256:74178c689fba27fd74514872dc47c924fc91c2e648a55c5f161f8803846b7272'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-2017'}), (s {uid: 'hu:person:wendy-yu'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-wendy-yu'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-yu-director-since-2017-capture'})
SET n += {id: 'nage-proxy-2025-yu-director-since-2017-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-yu-director-since-2017-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-2017'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-aug-2017'})
SET a += {id: 'nage-proxy-2025-yu-director-since-aug-2017', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2017-08-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'has been a director of the Company since August 2017', statedTense: 'PRESENT', contentHash: 'sha256:ec1198151a09b9d954d57169baed5454f341bd87485411ce18b14c818ba4742b'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-aug-2017'}), (s {uid: 'hu:person:wendy-yu'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-yu-since-august-2017'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-yu-director-since-aug-2017-capture'})
SET n += {id: 'nage-proxy-2025-yu-director-since-aug-2017-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-yu-director-since-aug-2017-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-yu-director-since-aug-2017'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-rubin-director-since-2017'})
SET a += {id: 'nage-proxy-2025-rubin-director-since-2017', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2017-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Director Since 2017', contentHash: 'sha256:18dfbc960e546eca559418f82f886a4fc8c657ab17606baeb6f194bff3fb4eac'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-rubin-director-since-2017'}), (s {uid: 'hu:person:steven-rubin'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-steven-rubin'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-rubin-director-since-2017-capture'})
SET n += {id: 'nage-proxy-2025-rubin-director-since-2017-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-rubin-director-since-2017-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-rubin-director-since-2017'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-director-since-2015'})
SET a += {id: 'nage-proxy-2025-fried-director-since-2015', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2015-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Director Since 2015', contentHash: 'sha256:82639559474f3f040f6bd0a69e88b416c42675a371d69dc9f4bd8057c86a1157'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-director-since-2015'}), (s {uid: 'hu:person:robert-fried'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-robert-fried'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-fried-director-since-2015-capture'})
SET n += {id: 'nage-proxy-2025-fried-director-since-2015-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-fried-director-since-2015-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-director-since-2015'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018'})
SET a += {id: 'nage-proxy-2025-fried-ceo-since-june-2018', predicate: 'EMPLOYED_BY', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2018-06-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Chief Executive Officer', contentHash: 'sha256:7db18c5af839c434131d71b2240bfbebdd85a8b932b46d643882b1a73e5686ad'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018'}), (s {uid: 'hu:person:robert-fried'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-fried-ceo-june-2018'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-fried-ceo-since-june-2018-capture'})
SET n += {id: 'nage-proxy-2025-fried-ceo-since-june-2018-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-fried-ceo-since-june-2018-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-director-since-2000'})
SET a += {id: 'nage-proxy-2025-jaksch-director-since-2000', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2000-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Director Since 2000', contentHash: 'sha256:de84ce3dd8b34421cff9a0ac0a6dbc7b9baaff944e9f43b7aa89184f9cd01849'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-director-since-2000'}), (s {uid: 'hu:person:frank-jaksch-jr'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-nominee-table-frank-jaksch-jr'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-jaksch-director-since-2000-capture'})
SET n += {id: 'nage-proxy-2025-jaksch-director-since-2000-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-jaksch-director-since-2000-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-director-since-2000'})
MERGE (j)-[:EVALUATES]->(a);

// Executive Chairman: an executive qualifier on a board title; employment is not stated, so AFFILIATED_WITH keeps the title (normalization rule R-ROLE-2)
MERGE (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022'})
SET a += {id: 'nage-proxy-2025-jaksch-executive-chairman-until-july-2022', predicate: 'AFFILIATED_WITH', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validTo: datetime('2022-07-01T00:00:00Z'), validToPrecision: 'MONTH', validToBasis: 'STATED_BY_SOURCE', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'Executive Chairman', contentHash: 'sha256:311b65b137374477cf41fbbd57ed20f4ae518576fc7fc5cf9a9e253f78b26707'};
MATCH (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022'}), (s {uid: 'hu:person:frank-jaksch-jr'}), (o {uid: 'hu:org:niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-proxy-2025-jaksch-transition-july-2022'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nage-proxy-2025-jaksch-executive-chairman-until-july-2022-capture'})
SET n += {id: 'nage-proxy-2025-jaksch-executive-chairman-until-july-2022-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:nage-proxy-2025-jaksch-executive-chairman-until-july-2022-capture'}), (a:Assertion {uid: 'hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022'})
MERGE (j)-[:EVALUATES]->(a);

// Projected role edges (one per ACCEPTED assertion; bounds copied from the assertion)
MATCH (x:Person {uid: 'hu:person:wendy-yu'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-yu-board-nage-year'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-yu-board-nage-year', assertionUid: 'hu:assertion:nage-proxy-2025-yu-director-since-2017', validFrom: datetime('2017-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', corporateRoleType: 'DIRECTOR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'Director Since 2017'};
MATCH (x:Person {uid: 'hu:person:wendy-yu'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-yu-board-nage-month'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-yu-board-nage-month', assertionUid: 'hu:assertion:nage-proxy-2025-yu-director-since-aug-2017', validFrom: datetime('2017-08-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', corporateRoleType: 'DIRECTOR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'has been a director of the Company since August 2017'};
MATCH (x:Person {uid: 'hu:person:steven-rubin'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-rubin-board-nage-year'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-rubin-board-nage-year', assertionUid: 'hu:assertion:nage-proxy-2025-rubin-director-since-2017', validFrom: datetime('2017-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', corporateRoleType: 'DIRECTOR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'Director Since 2017'};
MATCH (x:Person {uid: 'hu:person:robert-fried'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-fried-board-nage-year'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-fried-board-nage-year', assertionUid: 'hu:assertion:nage-proxy-2025-fried-director-since-2015', validFrom: datetime('2015-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', corporateRoleType: 'DIRECTOR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'Director Since 2015'};
MATCH (x:Person {uid: 'hu:person:robert-fried'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:EMPLOYED_BY {relationshipUid: 'hu:rel:w01-fried-ceo-nage'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-fried-ceo-nage', assertionUid: 'hu:assertion:nage-proxy-2025-fried-ceo-since-june-2018', validFrom: datetime('2018-06-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'CEO', corporateRoleType: 'CEO', seniorityLevel: 'C_SUITE', roleTitleVerbatim: 'Chief Executive Officer'};
MATCH (x:Person {uid: 'hu:person:frank-jaksch-jr'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-jaksch-board-nage-year'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-jaksch-board-nage-year', assertionUid: 'hu:assertion:nage-proxy-2025-jaksch-director-since-2000', validFrom: datetime('2000-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', corporateRoleType: 'DIRECTOR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'Director Since 2000'};
MATCH (x:Person {uid: 'hu:person:frank-jaksch-jr'}), (y:Organization {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (x)-[r:AFFILIATED_WITH {relationshipUid: 'hu:rel:w01-jaksch-exec-chair-nage'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-jaksch-exec-chair-nage', assertionUid: 'hu:assertion:nage-proxy-2025-jaksch-executive-chairman-until-july-2022', validTo: datetime('2022-07-01T00:00:00Z'), validToPrecision: 'MONTH', validFromBasis: 'UNKNOWN', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'CHAIRPERSON', corporateRoleType: 'CHAIR', seniorityLevel: 'BOARD', roleTitleVerbatim: 'Executive Chairman'};

// Temporal correction (late fix of an extraction error): the 0.2.0 reading stored "B (2011-2017)" with validTo 2018-01-01 YEAR,
// which under the round 0007 rule means "ended during 2018". The W01 re-extraction stores validTo 2017-01-01 YEAR
// ("ended at some instant in 2017") and supersedes the old assertion with EXTRACTION_FIX; the old edge is closed in recorded time.
MERGE (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading'})
SET a += {id: 'w01-sinclair-board-segterra-legacy-reading', predicate: 'BOARD_MEMBER_OF', status: 'SUPERSEDED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'PERSONAL_EXPERIENCE', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2018-01-01T00:00:00Z'), validToPrecision: 'YEAR', validToBasis: 'STATED_BY_SOURCE', recordedAt: datetime('2026-10-03T12:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), recordedTo: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'B', contentHash: 'sha256:203d52ac025d32bde7ae63840b3b3cbb4e8122a8ff9a44cffd2571bcf20b75ff'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading'}), (s {uid: 'hu:person:david-a-sinclair'}), (o {uid: 'hu:org:segterra'}), (w {uid: 'hu:person:david-a-sinclair'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-03-insidetracker-line'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-sinclair-board-segterra-legacy-reading-capture'})
SET n += {id: 'w01-sinclair-board-segterra-legacy-reading-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-sinclair-board-segterra-legacy-reading-capture'}), (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017'})
SET a += {id: 'w01-sinclair-board-segterra-2011-2017', predicate: 'BOARD_MEMBER_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'PERSONAL_EXPERIENCE', validFrom: datetime('2011-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2017-01-01T00:00:00Z'), validToPrecision: 'YEAR', validToBasis: 'STATED_BY_SOURCE', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'B', contentHash: 'sha256:701bee74986c1e949a044914e8d7faeb25da2d69ad092eec0deb699a16b054b0'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017'}), (s {uid: 'hu:person:david-a-sinclair'}), (o {uid: 'hu:org:segterra'}), (w {uid: 'hu:person:david-a-sinclair'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-insidetracker-line'}), (l1:SourceLocator {uid: 'hu:locator:sinclair-affiliations-2026-10-04-legend'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:SUPPORTED_BY]->(l1);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-sinclair-board-segterra-2011-2017-capture'})
SET n += {id: 'w01-sinclair-board-segterra-2011-2017-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-sinclair-board-segterra-2011-2017-capture'}), (a:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (n:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017'}), (o:Assertion {uid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading'})
MERGE (n)-[s:SUPERSEDES]->(o)
SET s.supersessionKind = 'EXTRACTION_FIX', s.recordedAt = datetime('2026-10-04T01:00:00Z');
MATCH (x:Person {uid: 'hu:person:david-a-sinclair'}), (y:Organization {uid: 'hu:org:segterra'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-sinclair-board-segterra-legacy'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-sinclair-board-segterra-legacy', assertionUid: 'hu:assertion:w01-sinclair-board-segterra-legacy-reading', validFrom: datetime('2011-01-01T00:00:00Z'), validTo: datetime('2018-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validToPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-03T12:00:00Z'), recordedTo: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', seniorityLevel: 'BOARD', roleTitleVerbatim: 'B'};
MATCH (x:Person {uid: 'hu:person:david-a-sinclair'}), (y:Organization {uid: 'hu:org:segterra'})
MERGE (x)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w01-sinclair-board-segterra-2011-2017'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-sinclair-board-segterra-2011-2017', assertionUid: 'hu:assertion:w01-sinclair-board-segterra-2011-2017', validFrom: datetime('2011-01-01T00:00:00Z'), validTo: datetime('2017-01-01T00:00:00Z'), validFromPrecision: 'YEAR', validToPrecision: 'YEAR', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:00:00Z'), roleType: 'BOARD_MEMBER', seniorityLevel: 'BOARD', roleTitleVerbatim: 'B'};
