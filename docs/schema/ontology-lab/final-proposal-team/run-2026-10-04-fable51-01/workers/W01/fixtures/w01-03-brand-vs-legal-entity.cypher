// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Generated 2026-10-04 by the W01 fixture generator (scratchpad).
// Rules: statements separated by ';'; every statement binds its own nodes by uid (no variable crosses ';');
// nodes carry the primary label and the archetype label; uids use registered tokens (org, person, brand, facility,
// source, snapshot, locator, assertion, adjudication, activity, rel, identifier, product) plus the tokens requested in
// W01-SR-01 (org-snapshot, cohort-participant). Snapshots of real pages hash the stored excerpt text
// (contentHashBasis STORED_EXCERPT_TEXT: NFC-WS1 over the TEXT_QUOTE exact strings of the snapshot joined by one space);
// synthetic sources use SYNTHETIC_FIXTURE. Status ACCEPTED means capture fidelity only (a CAPTURE_FIDELITY
// adjudication is attached), never truth. Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md).
// FIXTURE w01-03-brand-vs-legal-entity: brand versus legal entity minimal pair and the similar-name pair
// (ChromaDex Corporation = former legal name of Niagen Bioscience, Inc. versus ChromaDex, Inc., its wholly owned
// subsidiary and the registrant of the TRU NIAGEN mark). Legal name and ticker are OrganizationSnapshot state
// attached by HAS_STATE episodes (CQ-EC-02, CQ-EC-C01). Sources: Niagen FY2025 10-K (INHERITED SRC-SEC-NAGE-10K-FY2025,
// new excerpt via search extract), name-change press release (NEW, search extract), Trademarkia record of USPTO data
// (NEW, third-party aggregator; USPTO TSDR itself BLOCKED/JS-only). Load after w01-01.


// Shared lineage record for W01 manual curation
MERGE (n:Activity:Occurrence {uid: 'hu:activity:w01-curation-2026-10-04'})
SET n += {id: 'w01-curation-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', occurrenceType: 'Activity', activityKind: 'EXTRACTION', methodVersion: 'w01-manual-curation-v0', startedAt: datetime('2026-10-04T00:52:00Z'), endedAt: datetime('2026-10-04T01:00:00Z')};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:niagen-bioscience-inc'})
SET n += {id: 'niagen-bioscience-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'Niagen Bioscience', legalName: 'Niagen Bioscience, Inc.', canonicalTicker: 'NAGE', currentAsOf: datetime('2026-10-04T01:00:00Z'), jurisdiction: 'US-DE', organizationType: 'COMPANY'};
MERGE (n:LegalEntity:Organization:Entity {uid: 'hu:org:chromadex-inc'})
SET n += {id: 'chromadex-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'LegalEntity', name: 'ChromaDex, Inc.', legalName: 'ChromaDex, Inc.', organizationType: 'COMPANY'};
MERGE (n:ConsumerBrand:Entity {uid: 'hu:brand:tru-niagen'})
SET n += {id: 'tru-niagen', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'ConsumerBrand', name: 'Tru Niagen'};
MERGE (n:Source:Entity {uid: 'hu:source:sec-nage-10k-fy2025'})
SET n += {id: 'sec-nage-10k-fy2025', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm', sourceKind: 'SECURITIES_FILING', title: 'Niagen Bioscience, Inc. Form 10-K for fiscal year 2025'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04'})
SET n += {id: 'sec-nage-10k-fy2025-tavily-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:57:00Z'), observedAt: datetime('2026-10-04T00:57:00Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:6d5e38157c15eb9735febe2515a99bcc0f5073d5ff20f2318551dc86227a7d54'};
MATCH (s:Source {uid: 'hu:source:sec-nage-10k-fy2025'}), (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-10k-fy2025-name-change'})
SET n += {id: 'nage-10k-fy2025-name-change', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Effective March 19, 2025, the Company changed its name to “Niagen Bioscience, Inc.”. In connection with the Company’s new name, the Company changed the ticker symbol for the Company’s common stock on Nasdaq, to “NAGE”.', quoteHash: 'sha256:70549c76a223f92a2ac6466a6951038adc3ec9c33906e600fd7881462efff686', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-name-change'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries'})
SET n += {id: 'nage-10k-fy2025-wholly-owned-subsidiaries', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Niagen Bioscience, Inc. (formerly ChromaDex Corporation) and its wholly owned subsidiaries, ChromaDex, Inc., ChromaDex International, Inc., ChromaDex Analytics, Inc., ChromaDex Asia Limited, Asia Pacific Scientific, Inc., ChromaDex Asia Pacific Ventures Limited, ChromaDex Europa B.V., and ChromaDex Trading (Shanghai) Co., Ltd.', quoteHash: 'sha256:38dda0467e4bba921cde8f1cef2379f45f78a9149c0233511c0197b2e29c04f9', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:Source:Entity {uid: 'hu:source:nage-pr-name-change-2025'})
SET n += {id: 'nage-pr-name-change-2025', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://investors.niagenbioscience.com/news/news-details/2025/ChromaDex-Corp--Announces-Name-Change-to-Niagen-Bioscience-Inc--and-New-Ticker-Symbol-NAGE-Effective-March-19-2025/default.aspx', sourceKind: 'PRESS_RELEASE', title: 'ChromaDex Corp. Announces Name Change to Niagen Bioscience, Inc. and New Ticker Symbol "NAGE" Effective March 19, 2025'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04'})
SET n += {id: 'nage-pr-name-change-2025-tavily-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:57:30Z'), observedAt: datetime('2026-10-04T00:57:30Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:3a4ba411c4048efb0f5fb83103872cc14643de44309c598db3bd6660d75ec50c'};
MATCH (s:Source {uid: 'hu:source:nage-pr-name-change-2025'}), (sn:SourceSnapshot {uid: 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-pr-2025-old-ticker'})
SET n += {id: 'nage-pr-2025-old-ticker', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'ChromaDex Corp. (NASDAQ:CDXC)', quoteHash: 'sha256:964004c8541274e2abfc638db74c6873e492afb98d18845d3bf3a888db5520c1', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-pr-2025-old-ticker'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:nage-pr-2025-sold-as-brand'})
SET n += {id: 'nage-pr-2025-sold-as-brand', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'Niagen® is the active ingredient in ChromaDex’s consumer products, sold as the brand Tru Niagen®', quoteHash: 'sha256:d4b5dbd191e150b701304d54230e8cf0806b57062bd25e3f13444cbc3eb85fda', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:nage-pr-name-change-2025-tavily-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:nage-pr-2025-sold-as-brand'})
MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (n:Source:Entity {uid: 'hu:source:trademarkia-tru-niagen-87497901'})
SET n += {id: 'trademarkia-tru-niagen-87497901', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Source', canonicalUri: 'https://www.trademarkia.com/tru-niagen-87497901', sourceKind: 'THIRD_PARTY_DIRECTORY', title: 'TRU NIAGEN Trademark (Trademarkia rendering of USPTO serial 87497901)'};
MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:trademarkia-tru-niagen-2026-10-04'})
SET n += {id: 'trademarkia-tru-niagen-2026-10-04', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceSnapshot', retrievedAt: datetime('2026-10-04T00:58:30Z'), observedAt: datetime('2026-10-04T00:58:30Z'), captureCompleteness: 'PARTIAL_EXCERPT', contentHashBasis: 'STORED_EXCERPT_TEXT', contentHash: 'sha256:361631b0b1a5b8826733100517daa6e283e014c4ca9961e4f9d1c7704e1f9440'};
MATCH (s:Source {uid: 'hu:source:trademarkia-tru-niagen-87497901'}), (sn:SourceSnapshot {uid: 'hu:snapshot:trademarkia-tru-niagen-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);
MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:trademarkia-tru-niagen-owner'})
SET n += {id: 'trademarkia-tru-niagen-owner', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', exact: 'TRU NIAGEN is a registered trademark (Registration #5370103) owned by ChromaDex Inc., a Irvine based entity located in CA.', quoteHash: 'sha256:361631b0b1a5b8826733100517daa6e283e014c4ca9961e4f9d1c7704e1f9440', normalizationVersion: 'NFC-WS1'};
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:trademarkia-tru-niagen-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:trademarkia-tru-niagen-owner'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

// Legal-name and ticker state: two OrganizationSnapshot payloads attached to the SAME LegalEntity (identity survives the rename)
MERGE (n:OrganizationSnapshot:VersionedState {uid: 'hu:org-snapshot:niagen-legal-name-chromadex-corporation'})
SET n += {id: 'niagen-legal-name-chromadex-corporation', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', stateType: 'LEGAL_NAME_AND_TICKER', name: 'ChromaDex Corporation (legal name state)', legalName: 'ChromaDex Corporation', canonicalTicker: 'CDXC', payloadHash: 'sha256:a555576e039a1e781a40b8d7da144b4b95503f107406a8721516917f90d7ba30', effectiveTo: datetime('2025-03-19T00:00:00Z'), validTo: datetime('2025-03-19T00:00:00Z'), recordedFrom: datetime('2026-10-04T01:00:00Z'), assertionUids: ['hu:assertion:w01-nage-state-chromadex-corporation']};
MERGE (n:OrganizationSnapshot:VersionedState {uid: 'hu:org-snapshot:niagen-legal-name-niagen-bioscience-inc'})
SET n += {id: 'niagen-legal-name-niagen-bioscience-inc', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', stateType: 'LEGAL_NAME_AND_TICKER', name: 'Niagen Bioscience, Inc. (legal name state)', legalName: 'Niagen Bioscience, Inc.', canonicalTicker: 'NAGE', payloadHash: 'sha256:56d939d9fdd6bbbaf906de3751681ad582c696f9de4e38b5f313a1027597e644', effectiveFrom: datetime('2025-03-19T00:00:00Z'), validFrom: datetime('2025-03-19T00:00:00Z'), recordedFrom: datetime('2026-10-04T01:00:00Z'), assertionUids: ['hu:assertion:w01-nage-state-niagen-bioscience-inc']};
MERGE (a:Assertion {uid: 'hu:assertion:w01-nage-state-chromadex-corporation'})
SET a += {id: 'w01-nage-state-chromadex-corporation', predicate: 'HAS_STATE', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'IDENTITY', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validTo: datetime('2025-03-19T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), contentHash: 'sha256:af5a4906a54562fdb5682341394fe7d99d26a2218c9ae2e42c42c6346c2b2abc'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-nage-state-chromadex-corporation'}), (s {uid: 'hu:org:niagen-bioscience-inc'}), (o {uid: 'hu:org-snapshot:niagen-legal-name-chromadex-corporation'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-name-change'}), (l1:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries'}), (l2:SourceLocator {uid: 'hu:locator:nage-pr-2025-old-ticker'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-nage-state-chromadex-corporation-capture'})
SET n += {id: 'w01-nage-state-chromadex-corporation-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-nage-state-chromadex-corporation-capture'}), (a:Assertion {uid: 'hu:assertion:w01-nage-state-chromadex-corporation'})
MERGE (j)-[:EVALUATES]->(a);
MERGE (a:Assertion {uid: 'hu:assertion:w01-nage-state-niagen-bioscience-inc'})
SET a += {id: 'w01-nage-state-niagen-bioscience-inc', predicate: 'HAS_STATE', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'IDENTITY', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFrom: datetime('2025-03-19T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), contentHash: 'sha256:4d9a628d19bf66cd7df83613fe51e496fbdc3d6368a891154dec04e8a1572f3d'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-nage-state-niagen-bioscience-inc'}), (s {uid: 'hu:org:niagen-bioscience-inc'}), (o {uid: 'hu:org-snapshot:niagen-legal-name-niagen-bioscience-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-name-change'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-nage-state-niagen-bioscience-inc-capture'})
SET n += {id: 'w01-nage-state-niagen-bioscience-inc-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-nage-state-niagen-bioscience-inc-capture'}), (a:Assertion {uid: 'hu:assertion:w01-nage-state-niagen-bioscience-inc'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'}), (y:OrganizationSnapshot {uid: 'hu:org-snapshot:niagen-legal-name-chromadex-corporation'})
MERGE (x)-[r:HAS_STATE {relationshipUid: 'hu:rel:w01-nage-state-chromadex-corporation'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-nage-state-chromadex-corporation', assertionUid: 'hu:assertion:w01-nage-state-chromadex-corporation', validTo: datetime('2025-03-19T00:00:00Z'), validToPrecision: 'DAY', validFromBasis: 'UNKNOWN', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:00:00Z')};
MATCH (x:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'}), (y:OrganizationSnapshot {uid: 'hu:org-snapshot:niagen-legal-name-niagen-bioscience-inc'})
MERGE (x)-[r:HAS_STATE {relationshipUid: 'hu:rel:w01-nage-state-niagen-bioscience-inc'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-nage-state-niagen-bioscience-inc', assertionUid: 'hu:assertion:w01-nage-state-niagen-bioscience-inc', validFrom: datetime('2025-03-19T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z')};

// Identifier: SEC CIK 1386570 (from the EDGAR archive path of both filings) identifies the registrant across the rename
MERGE (n:Identifier:Entity {uid: 'hu:identifier:sec-cik-1386570'})
SET n += {id: 'sec-cik-1386570', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'PUBLIC', entityType: 'Identifier', scheme: 'SEC_CIK', issuer: 'US-SEC', value: '1386570'};
MERGE (a:Assertion {uid: 'hu:assertion:w01-nage-has-cik-1386570'})
SET a += {id: 'w01-nage-has-cik-1386570', predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'IDENTITY', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), contentHash: 'sha256:ac671ae50670f28b8bd91fba86b4f2faea25cf4d693705ba2007ab39830332e5'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-nage-has-cik-1386570'}), (s {uid: 'hu:org:niagen-bioscience-inc'}), (o {uid: 'hu:identifier:sec-cik-1386570'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-name-change'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-nage-has-cik-1386570-capture'})
SET n += {id: 'w01-nage-has-cik-1386570-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-nage-has-cik-1386570-capture'}), (a:Assertion {uid: 'hu:assertion:w01-nage-has-cik-1386570'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'}), (y:Identifier {uid: 'hu:identifier:sec-cik-1386570'})
MERGE (x)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w01-nage-has-cik'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-nage-has-cik', assertionUid: 'hu:assertion:w01-nage-has-cik-1386570', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), isPrimary: true};

// Control: the parent states ChromaDex, Inc. is a wholly owned subsidiary -> PARENT_OF (stakePercent left null: "wholly owned" kept verbatim)
MERGE (a:Assertion {uid: 'hu:assertion:w01-nage-parent-of-chromadex-inc'})
SET a += {id: 'w01-nage-parent-of-chromadex-inc', predicate: 'PARENT_OF', status: 'ACCEPTED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'its wholly owned subsidiaries, ChromaDex, Inc.', contentHash: 'sha256:87f424205386cdc38237a32d282654a8e39240a05ba30b29dcc56a068d3894cc'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-nage-parent-of-chromadex-inc'}), (s {uid: 'hu:org:niagen-bioscience-inc'}), (o {uid: 'hu:org:chromadex-inc'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-10k-fy2025-wholly-owned-subsidiaries'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (n:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w01-nage-parent-of-chromadex-inc-capture'})
SET n += {id: 'w01-nage-parent-of-chromadex-inc-capture', createdAt: datetime('2026-10-04T01:00:00Z'), updatedAt: datetime('2026-10-04T01:00:00Z'), privacyClass: 'INTERNAL', assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', methodVersion: 'w01-capture-review-v0', status: 'ACCEPTED', reviewedAt: datetime('2026-10-04T01:05:00Z'), recordedAt: datetime('2026-10-04T01:05:00Z'), rationale: 'Assertion matches the cited span (capture fidelity only; not a truth verdict).'};
MATCH (j:Adjudication {uid: 'hu:adjudication:w01-nage-parent-of-chromadex-inc-capture'}), (a:Assertion {uid: 'hu:assertion:w01-nage-parent-of-chromadex-inc'})
MERGE (j)-[:EVALUATES]->(a);
MATCH (x:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'}), (y:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (x)-[r:PARENT_OF {relationshipUid: 'hu:rel:w01-nage-parent-of-chromadex-inc'}]->(y)
SET r += {relationshipUid: 'hu:rel:w01-nage-parent-of-chromadex-inc', assertionUid: 'hu:assertion:w01-nage-parent-of-chromadex-inc', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:00:00Z'), stakeClassVerbatim: 'wholly owned subsidiary', roleTitleVerbatim: 'its wholly owned subsidiaries, ChromaDex, Inc.'};

// Brand: the parent calls Tru Niagen the brand of "ChromaDex's consumer products" (group-level wording); the mark registrant is the
// subsidiary. Neither statement says who owns the brand, so both OWNS_BRAND readings stay PROPOSED (no projected edge):
// [GROUP_LEVEL_ROLE, MEMBER_COMPANY_ROLE] and INV-009.
MERGE (a:Assertion {uid: 'hu:assertion:w01-nage-owns-tru-niagen-brand-proposed'})
SET a += {id: 'w01-nage-owns-tru-niagen-brand-proposed', predicate: 'OWNS_BRAND', status: 'PROPOSED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'ChromaDex’s consumer products, sold as the brand Tru Niagen®', contentHash: 'sha256:40c04492a8f63d6d0c2884cfa9d456ab96f34e3f366347f97c79fa5f888a5c91'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-nage-owns-tru-niagen-brand-proposed'}), (s {uid: 'hu:org:niagen-bioscience-inc'}), (o {uid: 'hu:brand:tru-niagen'}), (w {uid: 'hu:org:niagen-bioscience-inc'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:nage-pr-2025-sold-as-brand'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(w)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
MERGE (a:Assertion {uid: 'hu:assertion:w01-chromadex-inc-owns-tru-niagen-brand-proposed'})
SET a += {id: 'w01-chromadex-inc-owns-tru-niagen-brand-proposed', predicate: 'OWNS_BRAND', status: 'PROPOSED', polarity: 'POSITIVE', predicateClass: 'ROLE', speechAct: 'STATES', assertionBasis: 'UNSTATED', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedAt: datetime('2026-10-04T01:00:00Z'), extractionMethod: 'manual', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T01:00:00Z'), roleTitleVerbatim: 'registered trademark (Registration #5370103) owned by ChromaDex Inc.', contentHash: 'sha256:3d7b2cffb72d9e01cdc1bb725236ae7a9ca544a32b77dbfc17e7df1df0d17f5a'};
MATCH (a:Assertion {uid: 'hu:assertion:w01-chromadex-inc-owns-tru-niagen-brand-proposed'}), (s {uid: 'hu:org:chromadex-inc'}), (o {uid: 'hu:brand:tru-niagen'}), (act:Activity {uid: 'hu:activity:w01-curation-2026-10-04'}), (l0:SourceLocator {uid: 'hu:locator:trademarkia-tru-niagen-owner'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (a)-[:SUPPORTED_BY]->(l0);
