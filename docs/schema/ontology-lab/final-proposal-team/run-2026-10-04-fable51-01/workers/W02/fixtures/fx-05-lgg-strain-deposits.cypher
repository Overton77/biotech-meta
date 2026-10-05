// W02 Substances and materials fixture (fx-05-lgg-strain-deposits) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case: Lacticaseibacillus rhamnosus GG. BacDive 147820 (M-13): 'Lactobacillus rhamnosus (CCUG 34291, ATCC 53103,
// LMG 18243)', NCBI tax IDs 568703 and 47715, synonym Lacticaseibacillus rhamnosus. ATCC BAA-3227 (M-14, search
// extract): 'ATCC accessioned progeny of Lactobacillus rhamnosus strain GG cited in US Pat. No. 4,839,281 as 53103'.
// Wikipedia (M-16, search extract): the patent 'refers to a strain of L. acidophilus GG with ATCC accession number 53103;
// later reclassified as a strain of L. rhamnosus'. NCT00934453 (M-15, search extract): 'Biological: Lactobacillus
// rhamnosus GG ATCC 53103', '1x10^10 LGG per capsule' (count unit and viability not stated -> viabilityState null).
// Identity: one MicrobialStrain with several deposit Identifiers; the species name change (Lactobacillus ->
// Lacticaseibacillus) changes presentation only (taxonomyId 47715 is stable); the patent-era L. acidophilus assignment is a
// separate STRAIN_OF assertion that is recorded but not projected.

MERGE (n:Source:Entity {uid: 'hu:source:bacdive-147820'})
ON CREATE SET n += {canonicalUri: 'https://bacdive.dsmz.de/strain/147820', title: 'BacDive 147820 Lactobacillus rhamnosus CCUG 34291, ATCC 53103, LMG 18243', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:bacdive-147820-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://bacdive.dsmz.de/strain/147820', retrievedAt: datetime('2026-10-04T01:20:00Z'), observedAt: datetime('2026-10-04T01:20:00Z'), contentHash: 'sha256:2ae0917d0354678dd068975098f71796cc0e17c9f7a892c0c2965443e8aa9d9c', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:bacdive-147820'}), (sn:SourceSnapshot {uid: 'hu:snapshot:bacdive-147820-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bacdive-147820-header'})
ON CREATE SET n += {uri: 'https://bacdive.dsmz.de/strain/147820', selectorKind: 'TEXT_QUOTE', exact: 'Lactobacillus rhamnosus (CCUG 34291, ATCC 53103, LMG 18243)', quoteHash: 'sha256:1fa5722c206941fa9f588ae7de6d104c7806e3709d4bde53af417c2d9fc0b49a', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:bacdive-147820-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:bacdive-147820-header'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:bacdive-147820-taxids'})
ON CREATE SET n += {uri: 'https://bacdive.dsmz.de/strain/147820', selectorKind: 'SECTION', section: 'NCBI tax ID(s) 568703 47715; Synonyms: Lacticaseibacillus rhamnosus', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:bacdive-147820-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:bacdive-147820-taxids'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:atcc-baa-3227'})
ON CREATE SET n += {canonicalUri: 'https://www.atcc.org/products/baa-3227', title: 'ATCC BAA-3227 Lacticaseibacillus rhamnosus (Hansen) Zheng et al.', sourceKind: 'THIRD_PARTY_DIRECTORY', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:atcc-baa-3227-search-extract-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.atcc.org/products/baa-3227', retrievedAt: datetime('2026-10-04T01:21:00Z'), observedAt: datetime('2026-10-04T01:21:00Z'), contentHash: 'sha256:de98c8e98c8c8aaab7f4bfc39300ea208840cd1daf03385eec385a0db6730e7b', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:atcc-baa-3227'}), (sn:SourceSnapshot {uid: 'hu:snapshot:atcc-baa-3227-search-extract-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:atcc-baa-3227-history'})
ON CREATE SET n += {uri: 'https://www.atcc.org/products/baa-3227', selectorKind: 'TEXT_QUOTE', exact: 'ATCC accessioned progeny of Lactobacillus rhamnosus strain GG cited in US Pat. No. 4,839,281 as 53103.', quoteHash: 'sha256:6e13a2d3cca09fc85d677aaa4422bbd697e3aaf9b85b231849c9f76d8de9d41b', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:atcc-baa-3227-search-extract-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:atcc-baa-3227-history'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:wikipedia-lacticaseibacillus-rhamnosus'})
ON CREATE SET n += {canonicalUri: 'https://en.wikipedia.org/wiki/Lacticaseibacillus_rhamnosus', title: 'Wikipedia: Lacticaseibacillus rhamnosus', sourceKind: 'THIRD_PARTY_PROFILE_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:wikipedia-l-rhamnosus-search-extract-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://en.wikipedia.org/wiki/Lacticaseibacillus_rhamnosus', retrievedAt: datetime('2026-10-04T01:21:30Z'), observedAt: datetime('2026-10-04T01:21:30Z'), contentHash: 'sha256:f7490c6595240ff4146556461e7d75b5ede42a1a395086603cef42c28231769d', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:wikipedia-lacticaseibacillus-rhamnosus'}), (sn:SourceSnapshot {uid: 'hu:snapshot:wikipedia-l-rhamnosus-search-extract-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:wikipedia-l-rhamnosus-patent'})
ON CREATE SET n += {uri: 'https://en.wikipedia.org/wiki/Lacticaseibacillus_rhamnosus', selectorKind: 'TEXT_QUOTE', exact: 'The patent refers to a strain of "L. acidophilus GG" with American Type Culture Collection (ATCC) accession number 53103; later reclassified as a strain of L. rhamnosus.', quoteHash: 'sha256:ae65203b2e2c800f1ae0b2dae6f2d1a82eded1ebb7e86f44015bfc7dfbb938e0', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:wikipedia-l-rhamnosus-search-extract-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:wikipedia-l-rhamnosus-patent'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:ctgov-nct00934453'})
ON CREATE SET n += {canonicalUri: 'https://clinicaltrials.gov/study/NCT00934453', title: 'ClinicalTrials.gov NCT00934453 Safety of Lactobacillus Rhamnosus GG ATCC 53103 (LGG) in Healthy Volunteers', sourceKind: 'REGULATORY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ctgov-nct00934453-search-extract-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://clinicaltrials.gov/study/NCT00934453', retrievedAt: datetime('2026-10-04T01:22:00Z'), observedAt: datetime('2026-10-04T01:22:00Z'), contentHash: 'sha256:e068cb1b275e1cc0cc5a6cf8b48633cc4b91cad5f95d9e97d0623ed42f3e6d66', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:ctgov-nct00934453'}), (sn:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct00934453-search-extract-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:ctgov-nct00934453-intervention'})
ON CREATE SET n += {uri: 'https://clinicaltrials.gov/study/NCT00934453', selectorKind: 'TEXT_QUOTE', exact: 'Biological: Lactobacillus rhamnosus GG ATCC 53103', quoteHash: 'sha256:0a17374c332cac293e801d113fbcc8f6bd6cce39568f5b3588b26a1a8a1a3f87', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:ctgov-nct00934453-search-extract-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:ctgov-nct00934453-intervention'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:MicrobialTaxon:Entity {uid: 'hu:microbial-taxon:lacticaseibacillus-rhamnosus'})
ON CREATE SET n += {name: 'Lacticaseibacillus rhamnosus', scientificName: 'Lacticaseibacillus rhamnosus', taxonomyId: '47715', maturity: 'PROVISIONAL', entityType: 'MicrobialTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:MicrobialTaxon:Entity {uid: 'hu:microbial-taxon:lactobacillus-acidophilus'})
ON CREATE SET n += {name: 'Lactobacillus acidophilus', scientificName: 'Lactobacillus acidophilus', maturity: 'CANDIDATE', entityType: 'MicrobialTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:MicrobialStrain:Entity {uid: 'hu:microbial-strain:lgg-atcc-53103'})
ON CREATE SET n += {name: 'Lacticaseibacillus rhamnosus GG', strainDesignation: 'GG', depositIdentifier: 'ATCC 53103', maturity: 'PROVISIONAL', entityType: 'MicrobialStrain', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Identifier:Entity {uid: 'hu:identifier:atcc-53103'})
ON CREATE SET n += {scheme: 'CULTURE_COLLECTION_ACCESSION', value: 'ATCC 53103', issuer: 'ATCC', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:Identifier {uid: 'hu:identifier:atcc-53103'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-header'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-atcc-53103-identifies-lgg'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4704d4a43b4fd3d0a609cab1a5058542f0bcb7bcf069a723bdba3f2a489c71f0', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:Identifier {uid: 'hu:identifier:atcc-53103'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-atcc-53103-identifies-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-atcc-53103-identifies-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, true);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:ccug-34291'})
ON CREATE SET n += {scheme: 'CULTURE_COLLECTION_ACCESSION', value: 'CCUG 34291', issuer: 'CCUG', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:Identifier {uid: 'hu:identifier:ccug-34291'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-header'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-ccug-34291-identifies-lgg'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e0d9144cb73b50c42a8b2bae4c1a50dbe1c1f211508bb4ae2c16ecd72796199c', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:Identifier {uid: 'hu:identifier:ccug-34291'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-ccug-34291-identifies-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-ccug-34291-identifies-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:lmg-18243'})
ON CREATE SET n += {scheme: 'CULTURE_COLLECTION_ACCESSION', value: 'LMG 18243', issuer: 'BCCM/LMG', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:Identifier {uid: 'hu:identifier:lmg-18243'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-header'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-lmg-18243-identifies-lgg'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:a88e5fdb8de45c895dbaa64a5122e467e9cb074f6351d3fdedb86c5a00dd60e0', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:Identifier {uid: 'hu:identifier:lmg-18243'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-lmg-18243-identifies-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-lmg-18243-identifies-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:ncbi-taxonomy-568703'})
ON CREATE SET n += {scheme: 'NCBI_TAXONOMY', value: '568703', issuer: 'NCBI Taxonomy (as recorded in BacDive)', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:Identifier {uid: 'hu:identifier:ncbi-taxonomy-568703'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-taxids'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-ncbi-taxonomy-568703-identifies-lgg'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:7d87acff56419ab3800b7a80b26094f3d2f7856c91a997ed2932a8eaffa3480a', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:Identifier {uid: 'hu:identifier:ncbi-taxonomy-568703'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-ncbi-taxonomy-568703-identifies-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-ncbi-taxonomy-568703-identifies-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:atcc-baa-3227'})
ON CREATE SET n += {scheme: 'CULTURE_COLLECTION_ACCESSION', value: 'ATCC BAA-3227', issuer: 'ATCC', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:Identifier {uid: 'hu:identifier:atcc-baa-3227'}),
      (l0:SourceLocator {uid: 'hu:locator:atcc-baa-3227-history'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-atcc-baa-3227-identifies-lgg'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:db3357e01bc788082e27a64e1c8811d4026af4ec210fa08ed693caccf90e45c8', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:Identifier {uid: 'hu:identifier:atcc-baa-3227'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-atcc-baa-3227-identifies-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-atcc-baa-3227-identifies-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:ncbi-taxonomy-47715'})
ON CREATE SET n += {scheme: 'NCBI_TAXONOMY', value: '47715', issuer: 'NCBI Taxonomy (as recorded in BacDive)', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialTaxon {uid: 'hu:microbial-taxon:lacticaseibacillus-rhamnosus'}),
      (o:Identifier {uid: 'hu:identifier:ncbi-taxonomy-47715'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-taxids'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-ncbi-taxonomy-47715-identifies-l-rhamnosus'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:51c564735c24f06a7f5fd828a5fd321c9f4760883263d7cc4b40d4647043219e', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialTaxon {uid: 'hu:microbial-taxon:lacticaseibacillus-rhamnosus'}), (y:Identifier {uid: 'hu:identifier:ncbi-taxonomy-47715'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-ncbi-taxonomy-47715-identifies-l-rhamnosus'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-ncbi-taxonomy-47715-identifies-l-rhamnosus'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, true);

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:MicrobialTaxon {uid: 'hu:microbial-taxon:lacticaseibacillus-rhamnosus'}),
      (l0:SourceLocator {uid: 'hu:locator:bacdive-147820-header'}),
      (l1:SourceLocator {uid: 'hu:locator:atcc-baa-3227-history'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-lgg-strain-of-l-rhamnosus'})
ON CREATE SET a += {predicate: 'STRAIN_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:7493bcd36af78a5f025cf7cd6f42943975eadcff2b93ac347f031b1bc86a7f6d', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:SUPPORTED_BY]->(l1);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}), (y:MicrobialTaxon {uid: 'hu:microbial-taxon:lacticaseibacillus-rhamnosus'})
MERGE (x)-[r:STRAIN_OF]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-lgg-strain-of-l-rhamnosus'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-lgg-strain-of-l-rhamnosus'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Patent-era classification: recorded as what the source reports, not projected (one current STRAIN_OF per strain,
// W02-SR-05). A SUPPORT adjudication would mark it CONTRADICTED; it is never deleted.

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (o:MicrobialTaxon {uid: 'hu:microbial-taxon:lactobacillus-acidophilus'}),
      (l0:SourceLocator {uid: 'hu:locator:wikipedia-l-rhamnosus-patent'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-lgg-strain-of-l-acidophilus-patent-era'})
ON CREATE SET a += {predicate: 'STRAIN_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:a553440267b76b3ba0c2785d4432f6a3450b1d0718201ce0e59724810e58bb6c', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MERGE (n:MicrobialPreparation:IngredientMaterial:Entity {uid: 'hu:material:nct00934453-lgg-as-administered'})
ON CREATE SET n += {name: 'LGG capsule material as administered in NCT00934453', materialKind: 'MICROBIAL_PREPARATION', maturity: 'PROVISIONAL', entityType: 'MicrobialPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialPreparation {uid: 'hu:material:nct00934453-lgg-as-administered'}),
      (o:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'}),
      (l0:SourceLocator {uid: 'hu:locator:ctgov-nct00934453-intervention'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-nct00934453-material-has-lgg'})
ON CREATE SET a += {predicate: 'HAS_STRAIN', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:3164e14cd4a871e0bae93a58015ec0215bc1a52379b6533a9343291bb0d1171e', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialPreparation {uid: 'hu:material:nct00934453-lgg-as-administered'}), (y:MicrobialStrain {uid: 'hu:microbial-strain:lgg-atcc-53103'})
MERGE (x)-[r:HAS_STRAIN]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-nct00934453-material-has-lgg'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-nct00934453-material-has-lgg'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');
