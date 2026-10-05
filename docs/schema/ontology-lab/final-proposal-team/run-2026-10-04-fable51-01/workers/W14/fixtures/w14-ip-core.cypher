// W14 fixture 1/4: core real records (NEW_RETRIEVAL 2026-10-04). Nicotinamide riboside patent family displayed for
// US 8,197,807 B2 (Google Patents), the Dartmouth -> ChromaDex, Inc. exclusive license of 2014-05-16 (SEC exhibit via Justia
// mirror), the 2012 agreement with terms not captured, the Federal Circuit 2023 affirmance holding claims 1-3 patent-ineligible,
// and the USPTO TSDR record for NIAGEN (serial 85932490, reg. 4606519). Run with run-cypher.mjs: every statement binds its own
// nodes by uid; nodes carry primary + archetype labels. Proposed uid tokens (W14-SR-01): patent-family, patent-application,
// granted-patent, patent-claim, patent-license, trademark, ip-status. Snapshot hashes: the Google Patents snapshot hashes the
// stored Firecrawl markdown (STORED_EXCERPT_TEXT); all other snapshots use SYNTHETIC_FIXTURE (sha256 of the snapshot uid)
// because their bytes were not stored; locator quoteHash values are real sha256 over NFC-WS1-normalized excerpts.

MERGE (n:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
SET n:Occurrence, n += {occurrenceType: 'Activity', activityKind: 'EXTRACTION', startedAt: datetime('2026-10-04T00:57:00Z'), endedAt: datetime('2026-10-04T01:30:00Z'), methodVersion: 'w14-manual-curation/v1', externalRunSystem: 'claude-code', externalRunId: 'run-2026-10-04-fable51-01/W14', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Agent {uid: 'hu:agent:w14-opus-5-5'})
SET n:Entity, n += {entityType: 'Agent', name: 'W14 worker (Opus 5.5)', agentKind: 'MANUAL_VALIDATION_OF_AUTOMATED_AGENT', model: 'claude-opus-5-5', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Activity {uid: 'hu:activity:w14-curation-2026-10-04'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:WAS_ASSOCIATED_WITH]->(b);
MERGE (n:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'})
SET n:EvidenceAssessment, n += {assessmentType: 'Adjudication', adjudicationKind: 'CAPTURE_FIDELITY', verdict: 'SUPPORTED', reviewerType: 'AGENT', reviewedAt: datetime('2026-10-04T02:00:00Z'), recordedAt: datetime('2026-10-04T02:00:00Z'), methodVersion: 'w14-capture-check/v1', status: 'ACCEPTED', createdAt: datetime('2026-10-04T02:00:00Z'), rationale: 'Each evaluated assertion was compared with the stored excerpt of its locator.', privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Trustees of Dartmouth College', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:chromadex-inc'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'ChromaDex, Inc.', createdAt: datetime('2026-10-04T01:30:00Z'), legalName: 'ChromaDex Inc.', jurisdiction: 'US-CA', description: 'Wholly owned subsidiary named in the Niagen Bioscience FY2025 10-K; TSDR owner of NIAGEN (CALIFORNIA corporation).', privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Niagen Bioscience, Inc.', createdAt: datetime('2026-10-04T01:30:00Z'), legalName: 'Niagen Bioscience, Inc.', description: 'SEC registrant CIK 1386570, formerly ChromaDex Corporation (renamed 2025); parent of ChromaDex, Inc.', privacyClass: 'PUBLIC'};
MERGE (n:LegalEntity {uid: 'hu:org:google-llc'})
SET n:Organization:Entity, n += {entityType: 'Organization', name: 'Google LLC (Google Patents)', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Organization {uid: 'hu:org:uspto'})
SET n:Entity, n += {entityType: 'Organization', name: 'United States Patent and Trademark Office', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Organization {uid: 'hu:org:us-court-of-appeals-federal-circuit'})
SET n:Entity, n += {entityType: 'Organization', name: 'United States Court of Appeals for the Federal Circuit', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
SET n:IngredientMaterial:Entity, n += {entityType: 'IngredientMaterial', name: 'Niagen', brandName: 'Niagen', materialKind: 'BRANDED_INGREDIENT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
SET n:Entity, n += {entityType: 'ChemicalSubstance', name: 'nicotinamide riboside', preferredName: 'nicotinamide riboside', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Source {uid: 'hu:source:google-patents-us8197807b2-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://patents.google.com/patent/US8197807B2/en', title: 'US8197807B2 - Nicotinamide riboside kinase compositions and methods for using the same - Google Patents', sourceKind: 'THIRD_PARTY_DIRECTORY', name: 'Google LLC', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://patents.google.com/patent/US8197807B2/en', retrievedAt: datetime('2026-10-04T00:57:09Z'), observedAt: datetime('2026-10-04T00:57:09Z'), contentHash: 'sha256:fb6766d4786a83b77711494effcf7cf053291e2dbd86f8b152f2877395b2e22d', contentHashBasis: 'STORED_EXCERPT_TEXT', captureCompleteness: 'COMPLETE', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:google-patents-us8197807b2-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:justia-contract-406825-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://contracts.justia.com/companies/chromadex-corp-3165/contract/406825/', title: 'Exclusive Patent License Agreement between Trustees of Dartmouth College and ChromaDex, Inc. (Justia mirror of an SEC exhibit)', sourceKind: 'SECURITIES_FILING', name: 'Justia (mirror); filer ChromaDex Corp.', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://contracts.justia.com/companies/chromadex-corp-3165/contract/406825/', retrievedAt: datetime('2026-10-04T00:57:36Z'), observedAt: datetime('2026-10-04T00:57:36Z'), contentHash: 'sha256:5c31fe6530001369f60433af0547d6588cd01de702680db3d29e4050c8f63c10', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:justia-contract-406825-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://content.edgar-online.com/ExternalLink/EDGAR/0001654954-16-003772.html?hash=dbaa120c152cc5c8548a8e5422aa36ce915f7175ceeb2d60a2895c3a1be4fda1&dest=EX10-6_HTM', title: 'ChromaDex Corp. Form 10-Q received 2016-11-10, Exhibit 10.6 (EDGAR Online mirror)', sourceKind: 'SECURITIES_FILING', name: 'EDGAR Online (mirror); filer ChromaDex Corp.', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://content.edgar-online.com/ExternalLink/EDGAR/0001654954-16-003772.html?hash=dbaa120c152cc5c8548a8e5422aa36ce915f7175ceeb2d60a2895c3a1be4fda1&dest=EX10-6_HTM', retrievedAt: datetime('2026-10-04T00:57:43Z'), observedAt: datetime('2026-10-04T00:57:43Z'), publishedAt: datetime('2016-11-10T00:00:00Z'), contentHash: 'sha256:a86c209131c4f2dd4582457ea94578fa01f0c295959ed8c4c46c4dc50bca257f', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:sec-cdxc-10k-fy2023-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000162828024009380/cdxc-20231231.htm', title: 'ChromaDex Corporation Form 10-K for fiscal year 2023', sourceKind: 'SECURITIES_FILING', name: 'ChromaDex Corporation (SEC EDGAR CIK 1386570)', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:sec-cdxc-10k-fy2023-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000162828024009380/cdxc-20231231.htm', retrievedAt: datetime('2026-10-04T00:58:03Z'), observedAt: datetime('2026-10-04T00:58:03Z'), contentHash: 'sha256:4470163d890005e7d397261debc1ee3f30ed07490cf4758909bb61f96fdb1c4a', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:sec-cdxc-10k-fy2023-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:sec-cdxc-10k-fy2023-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-cdxc-10k-fy2023-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:cafc-22-1116-opinion-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://www.cafc.uscourts.gov/opinions-orders/22-1116.OPINION.2-13-2023_2079642.pdf', title: 'ChromaDex, Inc. v. Elysium Health, Inc., No. 2022-1116 (Fed. Cir. Feb. 13, 2023), opinion', sourceKind: 'LEGAL_RECORD', name: 'United States Court of Appeals for the Federal Circuit', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:cafc-22-1116-opinion-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://www.cafc.uscourts.gov/opinions-orders/22-1116.OPINION.2-13-2023_2079642.pdf', retrievedAt: datetime('2026-10-04T00:58:20Z'), observedAt: datetime('2026-10-04T00:58:20Z'), publishedAt: datetime('2023-02-13T00:00:00Z'), contentHash: 'sha256:6cc1d8046b63bdcfce7bffe0d78cd6ded52839dbc48417e15530675fb0039f6c', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:cafc-22-1116-opinion-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:cafc-22-1116-opinion-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:cafc-22-1116-opinion-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:uspto-tsdr-sn85932490-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://tsdr.uspto.gov/statusview/sn85932490', title: 'TSDR status: NIAGEN, serial 85932490', sourceKind: 'REGULATORY_RECORD', name: 'United States Patent and Trademark Office', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://tsdr.uspto.gov/statusview/sn85932490', retrievedAt: datetime('2026-10-04T00:58:37Z'), observedAt: datetime('2026-10-04T00:58:38Z'), contentHash: 'sha256:05bc68179968d54de75ea2a524af87b971fad72a29b43ff405987de4cdac5ce8', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:sec-nage-10k-fy2025-r9-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/R9.htm', title: 'Niagen Bioscience, Inc. 10-K FY2025, XBRL R9 Nature of Business', sourceKind: 'SECURITIES_FILING', name: 'Niagen Bioscience, Inc. (SEC EDGAR CIK 1386570)', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://www.sec.gov/Archives/edgar/data/1386570/000138657026000013/R9.htm', retrievedAt: datetime('2026-10-04T00:58:54Z'), observedAt: datetime('2026-10-04T00:58:54Z'), contentHash: 'sha256:53d5f8a6075735ad5a36282d7536608f0a432d527afe2514bc144ea08499a78f', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:sec-nage-10k-fy2025-r9-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:Source {uid: 'hu:source:globenewswire-2018-01-22-ptab-2026-10-04'})
SET n:Entity, n += {entityType: 'Source', canonicalUri: 'https://www.globenewswire.com/news-release/2018/01/22/1298324/0/en/elysium-health-inc-challenge-of-chromadex-licensed-patent-denied-by-patent-trial-and-appeal-board-ptab.html', title: 'Elysium Health, Inc. Challenge of ChromaDex Licensed Patent Denied by PTAB (press release, search extract only)', sourceKind: 'PRESS_RELEASE', name: 'ChromaDex Corp. via GlobeNewswire', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:SourceSnapshot {uid: 'hu:snapshot:globenewswire-2018-01-22-ptab-2026-10-04'})
SET n:InformationArtifact, n += {artifactType: 'SourceSnapshot', canonicalUri: 'https://www.globenewswire.com/news-release/2018/01/22/1298324/0/en/elysium-health-inc-challenge-of-chromadex-licensed-patent-denied-by-patent-trial-and-appeal-board-ptab.html', retrievedAt: datetime('2026-10-04T00:57:30Z'), observedAt: datetime('2026-10-04T00:57:30Z'), publishedAt: datetime('2018-01-22T00:00:00Z'), contentHash: 'sha256:e1582fa11d569c5e18870a540a4e9ea82bc3169dd7a3632b36bab4f155b0daca', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'UNKNOWN', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Source {uid: 'hu:source:globenewswire-2018-01-22-ptab-2026-10-04'}), (b:SourceSnapshot {uid: 'hu:snapshot:globenewswire-2018-01-22-ptab-2026-10-04'})
MERGE (a)-[r:HAS_SNAPSHOT]->(b);
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:globenewswire-2018-01-22-ptab-2026-10-04'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-worldwide-applications'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'SECTION', createdAt: datetime('2026-10-04T01:30:00Z'), section: 'Worldwide applications list (2005 CA, AU, JP, EP, WO; 2006 US x2; 2012 US)', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-worldwide-applications'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-ep05722944'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'EP Application number: EP05722944A Filing date: 2005-02-09 Legal status: Withdrawn', quoteHash: 'sha256:b7502caa1e3b0d40d199e74219a36a39cb946b90026d50524d75c9a1c8cb69c8', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-ep05722944'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-us11912400'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'US Application number: US11/912,400 Filing date: 2006-04-20 Legal status: Active', quoteHash: 'sha256:25ad253ee9e9712b12b521a8957f85dacd56c7a22b278cfe39881d2312711e01', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-us11912400'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: '2012-06-12 Application granted 2012-06-12 Publication of US8197807B2 Status Active 2026-11-19 Adjusted expiration', quoteHash: 'sha256:168c5c9d331de4f488cf03e9e4d79fa4133b97695220d16e37461ae2546390fe', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-assignee'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Inventor Charles M. Brenner Current Assignee The listed assignees may be inaccurate. Google has not performed a legal analysis and makes no representation or warranty as to the accuracy of the list. Dartmouth College', quoteHash: 'sha256:48d91bcd8226dcc8a7931dd359b0eee52ef84338fae162b2368f44356eff0bb8', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-assignee'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:gp-us8197807-claim-1'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: '1. A composition comprising isolated nicotinamide riboside in combination with one or more of tryptophan, nicotinic acid, or nicotinamide, wherein said combination is in admixture with a carrier comprising a sugar, starch, cellulose, powdered tragacanth, malt, gelatin, talc, cocoa butter, suppository wax, oil, glycol, polyol, ester, agar, buffering agent, alginic acid, isotonic saline, Ringer\'s solution, ethyl alcohol, polyester, polycarbonate, or polyanhydride, wherein said composition is formulated for oral administration and increases NAD+ biosynthesis upon oral administration.', quoteHash: 'sha256:9f0e12c82ef94e7603ef59ee1acd3786815bbace22c88ea0c5b6e95a4e0c4be4', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:google-patents-us8197807b2-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-claim-1'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:justia-406825-effective'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'This agreement, effective May 16, 2014, is between the Trustees of Dartmouth College and ChromaDex, Inc.', quoteHash: 'sha256:ccfd84d556402fb0bb6c7debe9569984946527c2ab5107aeb8f71171bb30eec9', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-effective'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:justia-406825-patent-rights'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: '"Dartmouth Patent Rights" shall mean United States Patent Nos. 8,197,807, 8,114,626 and 8,383,086, Australian Patent No. 2006238858, Canadian Patent Application Serial No. 2,609,633 filed October 4, 2006, and any Foreign Patents issuing therefrom, and any reissues, reexaminations or extensions thereof.', quoteHash: 'sha256:435b57abf3ad024dd5d9ea76bf84ec93d45e2e7800e1d2e4900a54df4435dc56', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-patent-rights'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:justia-406825-grant'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Dartmouth hereby grants to Company and its Subsidiaries an exclusive, royalty-bearing license under Dartmouth Patent Rights to make, have made, use, and/or sell Licensed Products in the Field in the Territory', quoteHash: 'sha256:a40dbc683c813e52ac48beca7b252cd24e40ef09be76d7d945155b3de5ac6c76', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:justia-contract-406825-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-grant'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-rights'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: '13/260,392, filed September 26, 2011, and United States Patent No.', quoteHash: 'sha256:13479df919175994b48e910fd668247534a25fa2d3c96cc63e57c158fbae872b', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-rights'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-grant'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Dartmouth hereby grants to Company and its Subsidiaries an , royalty-bearing license under Dartmouth Patent Rights to make, have made, use, and/or sell Licensed Products in the Field in the Territory', quoteHash: 'sha256:5d214a60dbe7b5c9c1765d91e4e1c4b86aa7122d4d4f281d7cd28be0b9f2cf6d', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:edgar-online-0001654954-16-003772-ex10-6-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-grant'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:cdxc-10k-fy2023-dartmouth'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'U.S. Patent Nos. 8,197,807 (\'807 Patent) and 8,383,086 (\'086 Patent) that comprise compositions containing isolated nicotinamide riboside held by Dartmouth and licensed exclusively to ChromaDex', quoteHash: 'sha256:d806344b916182c34266be5680aaa3153ca26ec60863bab5feb9822a0d05e738', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-cdxc-10k-fy2023-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:cdxc-10k-fy2023-dartmouth'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:cafc-22-1116-holding'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'District Court for the District of Delaware granting Elysium Health, Inc.\'s ("Elysium") motion for summary judgment that the asserted claims of U.S. Patent No. 8,197,807 ("the \'807 patent") are directed to unpatentable subject matter under 35 U.S.C. § 101. We affirm. The asserted claims are claims 1-3 of the \'807 patent.', quoteHash: 'sha256:46f4a10db7ba8f6a4111f55191180913effd6e89e6b1fbad6e8f1fdbc5c3ab5b', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:cafc-22-1116-opinion-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:cafc-22-1116-holding'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:tsdr-85932490-header'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Mark: NIAGEN US Serial Number: 85932490 Application Filing Date: May 15, 2013 US Registration Number: 4606519 Registration Date: Sep. 16, 2014 Register: Principal', quoteHash: 'sha256:0e040fbeda129b0af2aeda8e8edb111c8174c3ce6c2bd1ef4f278975be50d952', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-header'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:tsdr-85932490-status'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'LIVE/REGISTRATION/Issued and Active The trademark application has been registered with the Office. Status: The registration has been renewed. Status Date: Jul. 24, 2025', quoteHash: 'sha256:e3168d08f312ff23332e2085f7c120e8778e24f5b787d6f014e31842b94d350e', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-status'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:tsdr-85932490-goods'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'For: Phytochemicals for use in the manufacturing of dietary supplements, nutritional products [, pharmaceuticals and cosmetics ] International Class(es): 001 For: Dietary and nutritional supplements International Class(es): 005', quoteHash: 'sha256:c2f1e74e648c9cc6894013623f57215131828dfbf6e7173bd1d1baa96708c6d9', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-goods'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:tsdr-85932490-owner'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Current Owner(s) Information Owner Name: ChromaDex Inc. Legal Entity Type: CORPORATION State or Country Where Organized: CALIFORNIA', quoteHash: 'sha256:80c0432255be3b89ac2f6c86737f3d53b7931ee93c3c09b5533aba3e25627a2e', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-owner'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:tsdr-85932490-related-ir'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'International Registration Number: 1336169 International Application(s) /Registration(s) Based on this Property: A0063731/1336169', quoteHash: 'sha256:478054ea4601cae34759aa5112c8bc8f8cbb812958dc5d687a512e34188a34b6', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:uspto-tsdr-sn85932490-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-related-ir'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:nage-r9-niagen'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Niagen Bioscience is the innovator behind the NAD+ precursor nicotinamide riboside chloride ("NRC" or "NRCL," commonly referred to as "NR"), commercialized as the flagship ingredient Niagen®, available in both food and pharmaceutical grades.', quoteHash: 'sha256:ce0f8e3d5102b0632d28be2ab35e017af978f4bd5f9310a9b7c6fabc28c29bd6', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-niagen'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:nage-r9-supply'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'supplies these ingredients as raw materials to the manufacturers of consumer products and U.S. FDA-registered 503B outsourcing facilities, respectively.', quoteHash: 'sha256:85a9f4c85f946ddee2d010d237bfbef92d842ced68d9ae8a1b89afba9550ae82', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-supply'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:nage-r9-subsidiaries'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Niagen Bioscience, Inc. (formerly ChromaDex Corporation) and its wholly owned subsidiaries, ChromaDex, Inc., ChromaDex International, Inc.', quoteHash: 'sha256:f46ba6bd89732ae0db5e32f70c895637deef34196a2ad0aae35d07c939c8687c', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:sec-nage-10k-fy2025-r9-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-subsidiaries'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:SourceLocator {uid: 'hu:locator:globenewswire-2018-01-22-807'})
SET n:InformationArtifact, n += {artifactType: 'SourceLocator', selectorKind: 'TEXT_QUOTE', createdAt: datetime('2026-10-04T01:30:00Z'), exact: 'Patent No. 8,197,807 ("the \'807 patent"), covering compositions comprising nicotinamide riboside, which ChromaDex currently licenses from the Trustees of Dartmouth College.', quoteHash: 'sha256:4c9b1867d28a18586288cef9de06fcb938f97dd4a9ff3373f61b98fa7a820c28', normalizationVersion: 'NFC-WS1', privacyClass: 'PUBLIC'};
MATCH (a:SourceSnapshot {uid: 'hu:snapshot:globenewswire-2018-01-22-ptab-2026-10-04'}), (b:SourceLocator {uid: 'hu:locator:globenewswire-2018-01-22-807'})
MERGE (a)-[r:HAS_LOCATOR]->(b);
MERGE (n:PatentFamily {uid: 'hu:patent-family:gp-us8197807-worldwide'})
SET n:Entity, n += {entityType: 'PatentFamily', familyDefinition: 'SOURCE_DISPLAYED', title: 'Nicotinamide riboside kinase compositions and methods for using the same', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Worldwide-applications list displayed by Google Patents for US8197807B2 on 2026-10-04 (8 entries; 2 instantiated here).', privacyClass: 'PUBLIC'};
MERGE (n:PatentApplication {uid: 'hu:patent-application:us-11912400'})
SET n:InformationArtifact, n += {artifactType: 'PatentApplication', applicationNumber: '11/912,400', jurisdiction: 'US', officeKey: 'US:11912400', filingDate: date('2006-04-20'), applicationKind: 'NATIONAL', publishedAt: datetime('2008-08-28T00:00:00Z'), observedAt: datetime('2026-10-04T00:57:09Z'), title: 'Nicotinamide riboside kinase compositions and methods for using the same', applicantNamesVerbatim: ['Dartmouth College'], inventorNamesVerbatim: ['Charles M. Brenner'], createdAt: datetime('2026-10-04T01:30:00Z'), description: 'National stage of PCT/US2006/015495 per the description; applicant name as displayed by Google Patents.', privacyClass: 'PUBLIC'};
MERGE (n:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
SET n:InformationArtifact, n += {artifactType: 'PatentApplication', applicationNumber: 'EP05722944', jurisdiction: 'EP', officeKey: 'EP:05722944', filingDate: date('2005-02-09'), applicationKind: 'REGIONAL', observedAt: datetime('2026-10-04T00:57:09Z'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
SET n:InformationArtifact, n += {artifactType: 'GrantedPatent', patentNumber: '8,197,807', kindCode: 'B2', jurisdiction: 'US', officeKey: 'US:8197807', grantDate: date('2012-06-12'), publishedAt: datetime('2012-06-12T00:00:00Z'), observedAt: datetime('2026-10-04T00:57:09Z'), title: 'Nicotinamide riboside kinase compositions and methods for using the same', inventorNamesVerbatim: ['Charles M. Brenner'], createdAt: datetime('2026-10-04T01:30:00Z'), description: 'assigneeNamesVerbatim null: the grant face page was not captured.', privacyClass: 'PUBLIC'};
MERGE (n:GrantedPatent {uid: 'hu:granted-patent:us-8383086'})
SET n:InformationArtifact, n += {artifactType: 'GrantedPatent', patentNumber: '8,383,086', jurisdiction: 'US', officeKey: 'US:8383086', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Named in the 2014 license and the FY2023 10-K; its application and family membership were not captured (unknown, not absent).', privacyClass: 'PUBLIC'};
MERGE (n:PatentApplication {uid: 'hu:patent-application:us-13260392'})
SET n:InformationArtifact, n += {artifactType: 'PatentApplication', applicationNumber: '13/260,392', jurisdiction: 'US', officeKey: 'US:13260392', filingDate: date('2011-09-26'), applicationKind: 'NATIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:PatentFamily {uid: 'hu:patent-family:gp-us8197807-worldwide'}), (b:PatentApplication {uid: 'hu:patent-application:us-11912400'})
MERGE (a)-[r:FAMILY_HAS_APPLICATION]->(b)
SET r += {orderIndex: 1, notes: 'displayed 2006 US entry'};
MATCH (a:PatentFamily {uid: 'hu:patent-family:gp-us8197807-worldwide'}), (b:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
MERGE (a)-[r:FAMILY_HAS_APPLICATION]->(b)
SET r += {orderIndex: 2, notes: 'displayed 2005 EP entry (from PCT/US2005/004337 branch)'};
MERGE (n:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
SET n:InformationArtifact, n += {artifactType: 'PatentClaim', claimNumber: 1, claimKind: 'INDEPENDENT', dependsOnClaimNumbers: [], claimText: 'A composition comprising isolated nicotinamide riboside in combination with one or more of tryptophan, nicotinic acid, or nicotinamide, wherein said combination is in admixture with a carrier comprising a sugar, starch, cellulose, powdered tragacanth, malt, gelatin, talc, cocoa butter, suppository wax, oil, glycol, polyol, ester, agar, buffering agent, alginic acid, isotonic saline, Ringer\'s solution, ethyl alcohol, polyester, polycarbonate, or polyanhydride, wherein said composition is formulated for oral administration and increases NAD+ biosynthesis upon oral administration.', claimTextHash: 'sha256:81e2351c3a6b6b8393a78b7f322196a3101b4fe110917e9a5becbd0f0b2ea5fe', claimTextNormalization: 'NFC-WS1', contentHash: 'sha256:81e2351c3a6b6b8393a78b7f322196a3101b4fe110917e9a5becbd0f0b2ea5fe', publishedAt: datetime('2012-06-12T00:00:00Z'), observedAt: datetime('2026-10-04T00:57:09Z'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:HAS_PATENT_CLAIM]->(b)
SET r += {orderIndex: 1};
MERGE (n:PatentClaim {uid: 'hu:patent-claim:us-8197807-c2'})
SET n:InformationArtifact, n += {artifactType: 'PatentClaim', claimNumber: 2, claimKind: 'DEPENDENT', dependsOnClaimNumbers: [1], claimText: 'The composition of claim 1, wherein the nicotinamide riboside is isolated from a natural or synthetic source.', claimTextHash: 'sha256:894792f2fff66232675ed275cf946192c8ed92f1e7559dd1cb2259b75c27d21e', claimTextNormalization: 'NFC-WS1', contentHash: 'sha256:894792f2fff66232675ed275cf946192c8ed92f1e7559dd1cb2259b75c27d21e', publishedAt: datetime('2012-06-12T00:00:00Z'), observedAt: datetime('2026-10-04T00:57:09Z'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c2'})
MERGE (a)-[r:HAS_PATENT_CLAIM]->(b)
SET r += {orderIndex: 2};
MERGE (n:PatentClaim {uid: 'hu:patent-claim:us-8197807-c3'})
SET n:InformationArtifact, n += {artifactType: 'PatentClaim', claimNumber: 3, claimKind: 'DEPENDENT', dependsOnClaimNumbers: [1], claimText: 'The composition of claim 1, wherein the formulation comprises a tablet, troche, capsule, elixir, suspension, syrup, wafer, chewing gum, or food.', claimTextHash: 'sha256:40dc15ab629fc6f663c0ac9bc1fc1a2fe663f30029c5f34d80b9eaac1d10cac2', claimTextNormalization: 'NFC-WS1', contentHash: 'sha256:40dc15ab629fc6f663c0ac9bc1fc1a2fe663f30029c5f34d80b9eaac1d10cac2', publishedAt: datetime('2012-06-12T00:00:00Z'), observedAt: datetime('2026-10-04T00:57:09Z'), createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c3'})
MERGE (a)-[r:HAS_PATENT_CLAIM]->(b)
SET r += {orderIndex: 3};
// APPLICATION_GRANTED_AS asserted by the aggregator display (Google), not by the USPTO record (not captured).
MERGE (n:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'})
SET n += {predicate: 'APPLICATION_GRANTED_AS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:f6aaeb0745a8d34ad9d30ad4e45d69afdcae5d066d76cd8c8260b5b2156935c2', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-06-12T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'}), (b:PatentApplication {uid: 'hu:patent-application:us-11912400'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentApplication {uid: 'hu:patent-application:us-11912400'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:APPLICATION_GRANTED_AS {relationshipUid: 'hu:rel:w14-app-us11912400-granted-as-us8197807'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-app-us11912400-granted-as-us8197807', validFrom: datetime('2012-06-12T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
SET n:Entity, n += {entityType: 'Trademark', markText: 'NIAGEN', jurisdiction: 'US', applicationSerialNumber: '85932490', registrationNumber: '4606519', officeKey: 'US:85932490', markDrawingKind: 'STANDARD_CHARACTER', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Trademark {uid: 'hu:trademark:wo-ir1336169-niagen'})
SET n:Entity, n += {entityType: 'Trademark', markText: 'NIAGEN', jurisdiction: 'WO', registrationNumber: '1336169', officeKey: 'WO:1336169', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Madrid international registration listed on the US TSDR record as based on the US property; its own WIPO record was not retrieved (owner, status and designations unknown).', privacyClass: 'PUBLIC'};
MERGE (n:Identifier {uid: 'hu:identifier:uspto-patent-app-11912400'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'US_PATENT_APPLICATION_NUMBER', issuer: 'USPTO', value: '11912400', jurisdiction: 'US', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:f3ca206e30f7a5ae49b6de391f98008c1d5799147ce360efa2a3893598fdc875', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'}), (b:PatentApplication {uid: 'hu:patent-application:us-11912400'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-app-11912400'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-us11912400'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-app-11912400'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentApplication {uid: 'hu:patent-application:us-11912400'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-app-11912400'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-uspto-patent-app-11912400'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-uspto-patent-app-11912400', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:epo-app-05722944'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'EP_APPLICATION_NUMBER', issuer: 'EPO', value: '05722944', jurisdiction: 'EP', normalizationRule: 'ep-strip-prefix-kind-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:6197101fe91f4f4f6458eb7b85a8a42ad34d9874ba7b2313daa455bf09b18da2', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'EP', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'}), (b:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'}), (b:Identifier {uid: 'hu:identifier:epo-app-05722944'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-ep05722944'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-epo-app-05722944'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentApplication {uid: 'hu:patent-application:ep-05722944'}), (b:Identifier {uid: 'hu:identifier:epo-app-05722944'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-epo-app-05722944'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-epo-app-05722944', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:uspto-patent-8197807'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'US_PATENT_NUMBER', issuer: 'USPTO', value: '8197807', jurisdiction: 'US', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:b04c79d8aa68dd4f59240e00d1d4030c7e988cdd1fded597de1d295e2f7bc779', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-8197807'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:GrantedPatent {uid: 'hu:granted-patent:us-8197807'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-8197807'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-uspto-patent-8197807'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-uspto-patent-8197807', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:uspto-patent-pub-us20080206221a1'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'US_PATENT_PUBLICATION_NUMBER', issuer: 'USPTO', value: 'US20080206221A1', jurisdiction: 'US', normalizationRule: 'uppercase-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:fbbc8186362a066deb68cd9cbba4dd52e880ca794bb857a91651cfbdc6000e1c', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'}), (b:PatentApplication {uid: 'hu:patent-application:us-11912400'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-pub-us20080206221a1'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentApplication {uid: 'hu:patent-application:us-11912400'}), (b:Identifier {uid: 'hu:identifier:uspto-patent-pub-us20080206221a1'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-uspto-patent-pub-us20080206221a1'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-uspto-patent-pub-us20080206221a1', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:uspto-tm-serial-85932490'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'USPTO_TM_SERIAL', issuer: 'USPTO', value: '85932490', jurisdiction: 'US', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:ff10a38b68229e18cff1d2a58d6004c673da7cbfaca6111459cb0f8f903918c5', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'}), (b:Identifier {uid: 'hu:identifier:uspto-tm-serial-85932490'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-header'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-serial-85932490'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'}), (b:Identifier {uid: 'hu:identifier:uspto-tm-serial-85932490'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-uspto-tm-serial-85932490'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-uspto-tm-serial-85932490', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:uspto-tm-reg-4606519'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'USPTO_TM_REGISTRATION', issuer: 'USPTO', value: '4606519', jurisdiction: 'US', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:7ff1bef199a98fc8a117e0f1326e197c4902a0f2e15f487f238c215752a98f7b', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'}), (b:Identifier {uid: 'hu:identifier:uspto-tm-reg-4606519'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-header'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-uspto-tm-reg-4606519'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'}), (b:Identifier {uid: 'hu:identifier:uspto-tm-reg-4606519'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-uspto-tm-reg-4606519'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-uspto-tm-reg-4606519', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Identifier {uid: 'hu:identifier:wipo-madrid-ir-1336169'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'WIPO_MADRID_IR', issuer: 'WIPO', value: '1336169', jurisdiction: 'WO', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'})
SET n += {predicate: 'HAS_IDENTIFIER', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:c9ddc8539505bb4c27adf97eb8a67e1ef25c7e5f1b9cc9497da160c3c55ca991', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'WO', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'}), (b:Trademark {uid: 'hu:trademark:wo-ir1336169-niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'}), (b:Identifier {uid: 'hu:identifier:wipo-madrid-ir-1336169'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-related-ir'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:Trademark {uid: 'hu:trademark:wo-ir1336169-niagen'}), (b:Identifier {uid: 'hu:identifier:wipo-madrid-ir-1336169'})
MERGE (a)-[r:HAS_IDENTIFIER {relationshipUid: 'hu:rel:w14-id-wipo-madrid-ir-1336169'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-id-wipo-madrid-ir-1336169', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// Identity-collision guard: the same digits under another issuer are a different Identifier and never establish identity.
MERGE (n:Identifier {uid: 'hu:identifier:jpo-patent-8197807-synthetic'})
SET n:Entity, n += {entityType: 'Identifier', scheme: 'JP_PATENT_NUMBER', issuer: 'JPO', value: '8197807', jurisdiction: 'JP', normalizationRule: 'digits-only-v1', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
// F-STATUS-01: aggregator "Active" (patent level) and court "held invalid" (claim level) coexist; neither implies the other.
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-8197807-in-force-gp'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:b03e334e967c5322591a8a6c2b6c8540a9c82578372e96156cddd90fdc6c68c5', statusKind: 'GRANTED_IN_FORCE', jurisdiction: 'US', effectiveFrom: datetime('2012-06-12T00:00:00Z'), effectiveTo: datetime('2026-11-19T00:00:00Z'), statusTextVerbatim: 'Status Active; Adjusted expiration 2026-11-19', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:63db8daf789c868307aded4d17575eb9be5781da1f18b4573a534fdf130157c3', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-06-12T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validTo: datetime('2026-11-19T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'}), (b:IpRightStatus {uid: 'hu:ip-status:us-8197807-in-force-gp'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-events'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-8197807-in-force-gp'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-us8197807-in-force-gp'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-us8197807-in-force-gp', validFrom: datetime('2012-06-12T00:00:00Z'), validTo: datetime('2026-11-19T00:00:00Z'), validFromPrecision: 'DAY', validToPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-8197807-expired-calc'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:456480240eea59a0ca7132a7f14d617c85b1896e9c701fd199874e4439fe0ab2', statusKind: 'EXPIRED', jurisdiction: 'US', effectiveFrom: datetime('2026-11-19T00:00:00Z'), scopeText: 'Projected from the displayed adjusted expiration; not an office record.', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'})
SET n += {predicate: 'IP_STATUS_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:9dd21644c6561861a9e979db06dee44042b7176f6d5cfb92c4bbf7b412f8e416', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2026-11-19T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'INFERRED', validToBasis: 'UNKNOWN', jurisdiction: 'US', basisKind: 'CALCULATED', derivationRule: 'ip-term-end/v1: EXPIRED begins at the stated end of the in-force episode', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:IpRightStatus {uid: 'hu:ip-status:us-8197807-expired-calc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-8197807-expired-calc'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-us8197807-expired-calc'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-us8197807-expired-calc', validFrom: datetime('2026-11-19T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'INFERRED', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-expired-calc'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-in-force-gp'})
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(b);
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-8197807-c1-held-invalid-cafc'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:547c51bf1a512fdd109323561960cb8f0b944447885d8b04e694e48320f2f1a8', statusKind: 'CLAIM_HELD_INVALID', jurisdiction: 'US', effectiveFrom: datetime('2023-02-13T00:00:00Z'), statusTextVerbatim: 'directed to unpatentable subject matter under 35 U.S.C. § 101 ... We affirm.', scopeText: 'claim 1 of US 8,197,807', legalBasisCitation: '35 U.S.C. § 101', proceedingReference: 'Fed. Cir. No. 2022-1116 (affirming D. Del. summary judgment; district-court date not captured)', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:cfd36035028e8b566a327340fe85fad6112bac12e31bb134c06ec214c3a07a0a', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'}), (b:IpRightStatus {uid: 'hu:ip-status:us-8197807-c1-held-invalid-cafc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'}), (b:Organization {uid: 'hu:org:us-court-of-appeals-federal-circuit'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'}), (b:SourceLocator {uid: 'hu:locator:cafc-22-1116-holding'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-c1-held-invalid'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-8197807-c1-held-invalid-cafc'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-us8197807-c1-held-invalid'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-us8197807-c1-held-invalid', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-8197807-c2-held-invalid-cafc'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:095acc4891fee50b4c9d30e1aa147de1eb6fe0057f9a5eb6e34d821640ae6b89', statusKind: 'CLAIM_HELD_INVALID', jurisdiction: 'US', effectiveFrom: datetime('2023-02-13T00:00:00Z'), statusTextVerbatim: 'directed to unpatentable subject matter under 35 U.S.C. § 101 ... We affirm.', scopeText: 'claim 2 of US 8,197,807', legalBasisCitation: '35 U.S.C. § 101', proceedingReference: 'Fed. Cir. No. 2022-1116 (affirming D. Del. summary judgment; district-court date not captured)', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:c0a35f87ff69d03f8c54591ba01b0b160a2731746dabc1cf4f5d64f305ff0057', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'}), (b:IpRightStatus {uid: 'hu:ip-status:us-8197807-c2-held-invalid-cafc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c2'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'}), (b:Organization {uid: 'hu:org:us-court-of-appeals-federal-circuit'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'}), (b:SourceLocator {uid: 'hu:locator:cafc-22-1116-holding'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-c2-held-invalid'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-8197807-c2-held-invalid-cafc'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c2'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-us8197807-c2-held-invalid'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-us8197807-c2-held-invalid', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-8197807-c3-held-invalid-cafc'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:71f2da536f64c5fc8bc7fa707f095c13cc4ba445c8f64a98a382052ee1e8c8c2', statusKind: 'CLAIM_HELD_INVALID', jurisdiction: 'US', effectiveFrom: datetime('2023-02-13T00:00:00Z'), statusTextVerbatim: 'directed to unpatentable subject matter under 35 U.S.C. § 101 ... We affirm.', scopeText: 'claim 3 of US 8,197,807', legalBasisCitation: '35 U.S.C. § 101', proceedingReference: 'Fed. Cir. No. 2022-1116 (affirming D. Del. summary judgment; district-court date not captured)', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:48e584cecefb6b27a7b6f3b7d85a6dd574cab07e22045976064c114b2108d0ae', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'}), (b:IpRightStatus {uid: 'hu:ip-status:us-8197807-c3-held-invalid-cafc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c3'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'}), (b:Organization {uid: 'hu:org:us-court-of-appeals-federal-circuit'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'}), (b:SourceLocator {uid: 'hu:locator:cafc-22-1116-holding'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-us8197807-c3-held-invalid'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-8197807-c3-held-invalid-cafc'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c3'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-us8197807-c3-held-invalid'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-us8197807-c3-held-invalid', validFrom: datetime('2023-02-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:ep-05722944-withdrawn-gp'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:f6f61a5492bf996cbe4efda833ec3e7d00d301252b6bf18cf14f7e086b0ec215', statusKind: 'WITHDRAWN', jurisdiction: 'EP', statusTextVerbatim: 'Legal status: Withdrawn', privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:eebe22f2fb8d98de3d8b37c171e2a8c1f306ecdaf82dccdcbd658668c44c91cb', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'OBSERVATION_ONLY', validToBasis: 'UNKNOWN', jurisdiction: 'EP', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'}), (b:IpRightStatus {uid: 'hu:ip-status:ep-05722944-withdrawn-gp'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'}), (b:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'}), (b:LegalEntity {uid: 'hu:org:google-llc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-ep05722944'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-ep05722944-withdrawn'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:ep-05722944-withdrawn-gp'}), (b:PatentApplication {uid: 'hu:patent-application:ep-05722944'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-ep05722944-withdrawn'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-ep05722944-withdrawn', validFromBasis: 'OBSERVATION_ONLY', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// Late arrival (TM-R6): renewal of 2025-07-24 first recorded 2026-10-04; observedAt is the TSDR generation instant.
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-registered'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:391aa8168d09ab065f73ce7601ed8cd5c9398995c72f81295e45a352d06ffa45', statusKind: 'REGISTERED', jurisdiction: 'US', effectiveFrom: datetime('2014-09-16T00:00:00Z'), statusTextVerbatim: 'REGISTERED-PRINCIPAL REGISTER', scopeText: 'Class 001: Phytochemicals for use in the manufacturing of dietary supplements, nutritional products [, pharmaceuticals and cosmetics ]; Class 005: Dietary and nutritional supplements (amendment date of the bracketed deletion not captured)', niceClasses: [1, 5], privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:0b7ecdaebdab5fa91c7a92357681297899f3f28ad1365861a1e83a6e7ff9a431', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2014-09-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'}), (b:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-registered'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-header'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-registered'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-registered'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-tm-niagen-registered'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-tm-niagen-registered', validFrom: datetime('2014-09-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-renewed-2025'})
SET n:VersionedState, n += {stateType: 'IpRightStatus', payloadHash: 'sha256:57c430c60bd170144b011f50f8998caca3945716e1d390b352dc2f84cb020eb7', statusKind: 'RENEWED', jurisdiction: 'US', effectiveFrom: datetime('2025-07-24T00:00:00Z'), statusTextVerbatim: 'LIVE/REGISTRATION/Issued and Active; The registration has been renewed.', scopeText: 'REGISTERED AND RENEWED (FIRST RENEWAL - 10 YRS); SEC. 8 (10-YR) ACCEPTED/SEC. 9 GRANTED', niceClasses: [1, 5], privacyClass: 'PUBLIC', maturity: 'CANDIDATE', createdAt: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'})
SET n += {predicate: 'IP_STATUS_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:3ebf38f86f28e2a4359a31dc8315a343b11192b656ce0252c1a15abfec740de9', polarity: 'POSITIVE', predicateClass: 'REGULATORY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2025-07-24T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'}), (b:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-renewed-2025'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-status'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-status-tm-niagen-renewed-2025'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:IpRightStatus {uid: 'hu:ip-status:us-sn85932490-renewed-2025'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:IP_STATUS_OF {relationshipUid: 'hu:rel:w14-status-tm-niagen-renewed-2025'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-status-tm-niagen-renewed-2025', validFrom: datetime('2025-07-24T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'})
SET n += {predicate: 'OWNS_TRADEMARK', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:525464f89cfb38f968a3a9ee98967395bd22ac9f8cb8f1405dc2ecabb128df46', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'OBSERVATION_ONLY', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'}), (b:Organization {uid: 'hu:org:uspto'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'}), (b:SourceLocator {uid: 'hu:locator:tsdr-85932490-owner'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:chromadex-inc'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:OWNS_TRADEMARK {relationshipUid: 'hu:rel:w14-owns-tm-niagen-chromadex-inc'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-owns-tm-niagen-chromadex-inc', validFromBasis: 'OBSERVATION_ONLY', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'})
SET n += {predicate: 'ASSIGNED_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:afd0585dbe1c4e5d4823f87c5e347d02ae238e9e7f05fbab70f25f388fb1ae8a', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'}), (b:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'}), (b:SourceLocator {uid: 'hu:locator:cdxc-10k-fy2023-dartmouth'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:ASSIGNED_PATENT {relationshipUid: 'hu:rel:w14-assigned-us8197807-dartmouth-10k'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-assigned-us8197807-dartmouth-10k', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'})
SET n += {predicate: 'ASSIGNED_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:cc52c613bc6645ea289c901ccf153144411f2b1f5a52220623185b1456ca8460', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'}), (b:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8383086'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'}), (b:SourceLocator {uid: 'hu:locator:cdxc-10k-fy2023-dartmouth'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8383086'})
MERGE (a)-[r:ASSIGNED_PATENT {relationshipUid: 'hu:rel:w14-assigned-us8383086-dartmouth-10k'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-assigned-us8383086-dartmouth-10k', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
SET n:VersionedState, n += {stateType: 'PatentLicense', payloadHash: 'sha256:781dd98665645f8fb657134ac8ceda4d32105b327e97a2fa9aa2d5adcb4e1af2', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), agreementTitle: 'Exclusive Patent License Agreement', effectiveFrom: datetime('2014-05-16T00:00:00Z'), exclusive: true, exclusivityReportedStatus: 'REPORTED', fieldOfUse: 'human and animal therapeutics', fieldOfUseReportedStatus: 'REPORTED', territory: 'worldwide', territoryJurisdictions: ['WORLDWIDE'], territoryReportedStatus: 'REPORTED', sublicensable: true, coverageRuleText: '"Dartmouth Patent Rights" shall mean United States Patent Nos. 8,197,807, 8,114,626 and 8,383,086, Australian Patent No. 2006238858, Canadian Patent Application Serial No. 2,609,633 filed October 4, 2006, and any Foreign Patents issuing therefrom, and any reissues, reexaminations or extensions thereof.', termText: 'shall remain in full force during the life of the last to expire patents under Dartmouth Patent Rights contemplated by this agreement in the last to expire territory.'};
MERGE (n:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
SET n:VersionedState, n += {stateType: 'PatentLicense', payloadHash: 'sha256:e54edc232c54cc03cb76d1773d5c0a02648e7e499768c10b4d3f7fa62eb3a383', privacyClass: 'PUBLIC', maturity: 'PROVISIONAL', createdAt: datetime('2026-10-04T01:30:00Z'), agreementTitle: 'ChromaDex, Inc. - Dartmouth Exclusive License Agreement (title as indexed)', effectiveFrom: datetime('2012-07-13T00:00:00Z'), termText: 'shall remain in full force during the life of the last to expire patents under Dartmouth Patent Rights contemplated by this agreement in the last to expire territory.', description: 'Grant clause, Field and Territory definitions came back empty in the captured mirror (PARTIAL_EXCERPT): redaction vs extraction loss cannot be distinguished, so terms and their reportedStatus stay null (unknown).'};
MERGE (n:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'})
SET n += {predicate: 'LICENSES_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:d2f94dfe883c1b1782c6418589c246a7aee7ef32c1beb1b38fd69ed418ae7703', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-effective'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-licensee-l2014-chromadex-inc'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:chromadex-inc'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:LICENSES_PATENT {relationshipUid: 'hu:rel:w14-licensee-l2014-chromadex-inc'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-licensee-l2014-chromadex-inc', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'})
SET n += {predicate: 'GRANTS_PATENT_LICENSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:7227199415749d1e5431e3052cccb6535464e46c4e7f146e994b413472b766ce', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'}), (b:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-effective'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-licensor-l2014-dartmouth'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:GRANTS_PATENT_LICENSE {relationshipUid: 'hu:rel:w14-licensor-l2014-dartmouth'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-licensor-l2014-dartmouth', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'})
SET n += {predicate: 'LICENSE_COVERS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:d3fcedc88b817db4dc64b373d841aa5db982e0facb13c279916ba2d8018be7fc', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-patent-rights'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8197807'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-covers-l2014-us8197807'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-covers-l2014-us8197807', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'})
SET n += {predicate: 'LICENSE_COVERS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:4dcc64fb8d19452e729eb8e03f88ce29b12e3dd9da630f1d89093973def48e0a', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8383086'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'}), (b:SourceLocator {uid: 'hu:locator:justia-406825-patent-rights'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-covers-l2014-us8383086'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2014-05-16'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8383086'})
MERGE (a)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-covers-l2014-us8383086'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-covers-l2014-us8383086', validFrom: datetime('2014-05-16T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'})
SET n += {predicate: 'LICENSES_PATENT', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:a89e01c00c18aeed47a81ec58f2dbc1826fecdfab044261bf98c0831050317eb', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'}), (b:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-grant'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-licensee-l2012-chromadex-inc'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:chromadex-inc'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
MERGE (a)-[r:LICENSES_PATENT {relationshipUid: 'hu:rel:w14-licensee-l2012-chromadex-inc'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-licensee-l2012-chromadex-inc', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'})
SET n += {predicate: 'GRANTS_PATENT_LICENSE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:d5c63291949a1da45be5901cf4b22d13a188e2bfb6e76ae6f2e8ca11a8ef7766', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'}), (b:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'}), (b:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-grant'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-licensor-l2012-dartmouth'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:trustees-of-dartmouth-college'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
MERGE (a)-[r:GRANTS_PATENT_LICENSE {relationshipUid: 'hu:rel:w14-licensor-l2012-dartmouth'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-licensor-l2012-dartmouth', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'})
SET n += {predicate: 'LICENSE_COVERS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:9970c62e5a3ae60f37ed6a903abeafea1b6c0fa2d5359a05bb34012701cd9d20', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'}), (b:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'}), (b:PatentApplication {uid: 'hu:patent-application:us-13260392'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'}), (b:SourceLocator {uid: 'hu:locator:edgar-online-ex10-6-rights'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-covers-l2012-us13260392'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:PatentLicense {uid: 'hu:patent-license:dartmouth-chromadex-inc-2012-07-13'}), (b:PatentApplication {uid: 'hu:patent-application:us-13260392'})
MERGE (a)-[r:LICENSE_COVERS {relationshipUid: 'hu:rel:w14-covers-l2012-us13260392'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-covers-l2012-us13260392', validFrom: datetime('2012-07-13T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
// Mark owner (ChromaDex, Inc., TSDR) differs from the asserter/marketer of the branded material (Niagen Bioscience, Inc. group, 10-K).
MERGE (n:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'})
SET n += {predicate: 'MARKETED_UNDER_MARK', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:c4d472428c68a859d20c2830f0b2243b2f5eb0539f8b348d3b9b0d94a34dfa30', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', jurisdiction: 'US', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Mark resolution to the US registration is by markText + jurisdiction (ResolutionHypothesis in production).', privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'}), (b:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-niagen'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-niagen-marketed-under-mark'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:BrandedIngredientMaterial {uid: 'hu:material:niagen'}), (b:Trademark {uid: 'hu:trademark:us-sn85932490-niagen'})
MERGE (a)-[r:MARKETED_UNDER_MARK {relationshipUid: 'hu:rel:w14-niagen-marketed-under-mark'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-niagen-marketed-under-mark', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'})
SET n += {predicate: 'SUPPLIES_INGREDIENT_MATERIAL', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:ae4c69487496505f318721e8f70b6a92d4d6a5bf907a3755d5775885bdc85c8b', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Group-level subject: the filing\'s \'Company\' is the parent with its subsidiaries collectively.', privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'}), (b:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-supply'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-nage-supplies-niagen'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'}), (b:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
MERGE (a)-[r:SUPPLIES_INGREDIENT_MATERIAL {relationshipUid: 'hu:rel:w14-nage-supplies-niagen'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-nage-supplies-niagen', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'})
SET n += {predicate: 'REALIZES_SUBSTANCE', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:1c649b0356656fc767ef6212e0f6b17ee06b158d6c7db8e3ade67bb78d332d2e', polarity: 'POSITIVE', predicateClass: 'IDENTITY', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'}), (b:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-niagen'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-niagen-realizes-nr'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:BrandedIngredientMaterial {uid: 'hu:material:niagen'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:REALIZES_SUBSTANCE {relationshipUid: 'hu:rel:w14-niagen-realizes-nr'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-niagen-realizes-nr', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'})
SET n += {predicate: 'SUBSIDIARY_OF', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:46718c553ece85080bba8add75bff39baa9dd442ab503050fa658ee956e60c29', polarity: 'POSITIVE', predicateClass: 'COMMERCIAL', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'}), (b:LegalEntity {uid: 'hu:org:chromadex-inc'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'}), (b:SourceLocator {uid: 'hu:locator:nage-r9-subsidiaries'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage'})
MERGE (a)-[r:EVALUATES]->(b);
MATCH (a:LegalEntity {uid: 'hu:org:chromadex-inc'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:SUBSIDIARY_OF {relationshipUid: 'hu:rel:w14-chromadex-inc-subsidiary-of-nage'}]->(b)
SET r += {assertionUid: 'hu:assertion:w14-chromadex-inc-subsidiary-of-nage', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T01:30:00Z')};
MERGE (n:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'})
SET n += {predicate: 'PATENT_CLAIMS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:e85c9092ea53b87af8d18e356e25004ac727c1bfd6a7bf4f5836d765e13e535a', polarity: 'POSITIVE', predicateClass: 'OTHER', assertionBasis: 'MANUFACTURER_CLAIM', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Licensee\'s press-release characterization (\'covering compositions comprising nicotinamide riboside\').', privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'}), (b:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'}), (b:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'}), (b:SourceLocator {uid: 'hu:locator:globenewswire-2018-01-22-807'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-nr-pr2018'})
MERGE (a)-[r:EVALUATES]->(b);
MERGE (n:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'})
SET n += {predicate: 'PATENT_CLAIMS', status: 'ACCEPTED', recordedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:8ce6d15f95d00e2c618943c78ba37d707aba31f2d0cd0ea66fc458df5545b3fb', polarity: 'POSITIVE', predicateClass: 'OTHER', assertionBasis: 'UNSTATED', speechAct: 'STATES', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', extractionMethod: 'manual', createdAt: datetime('2026-10-04T01:30:00Z'), description: 'Curator reading: claim 1 recites isolated nicotinamide riboside in an oral composition. Recitation, not infringement and not efficacy.', privacyClass: 'PUBLIC'};
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'}), (b:PatentClaim {uid: 'hu:patent-claim:us-8197807-c1'})
MERGE (a)-[r:HAS_SUBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'}), (b:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (a)-[r:HAS_OBJECT]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'}), (b:Agent {uid: 'hu:agent:w14-opus-5-5'})
MERGE (a)-[r:ASSERTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'}), (b:SourceLocator {uid: 'hu:locator:gp-us8197807-claim-1'})
MERGE (a)-[r:SUPPORTED_BY]->(b);
MATCH (a:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'}), (b:Activity {uid: 'hu:activity:w14-curation-2026-10-04'})
MERGE (a)-[r:WAS_GENERATED_BY]->(b);
MATCH (a:Adjudication {uid: 'hu:adjudication:w14-capture-fidelity-2026-10-04'}), (b:Assertion {uid: 'hu:assertion:w14-patent-claims-us8197807-c1-nr-curator'})
MERGE (a)-[r:EVALUATES]->(b);
