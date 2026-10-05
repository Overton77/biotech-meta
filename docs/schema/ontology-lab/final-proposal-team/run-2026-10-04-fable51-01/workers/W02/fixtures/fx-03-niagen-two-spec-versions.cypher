// W02 Substances and materials fixture (fx-03-niagen-two-spec-versions) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case: one BrandedIngredientMaterial (NIAGEN) and two ChromaDex specification versions for nicotinamide riboside chloride.
// v2015: GRN 635 GRAS determination for 'Niagen (Nicotinamide Riboside Chloride)' dated 2015-12-21, Table 2 (M-05):
// purity 95-102 wt% by HPLC; water <= 1%; acetone ~3000 ppm; methanol ~740 ppm (search extract of the FDA PDF).
// v2019: EFSA Journal 2019;17(8):5775 Table 2, 'specifications of the NF as proposed by the applicant' (ChromaDex) (M-06):
// NR chloride >= 90 wt%; water <= 2.0%; acetone <= 5,000 mg/kg; methanol <= 1,000 mg/kg; acetonitrile <= 50 mg/kg.
// Identity rule (W02 D-06): a specification change is a new SpecificationVersion of the same ManufacturingSpecification,
// never a new BrandedIngredientMaterial. Criteria are W12 SpecificationCriterion records and are not modelled here.
// Late arrival: the v2019 attachment is recorded later (REC_LATE) with its past validFrom (PUBLICATION_PROXY).
// The EFSA opinion names the applicant and the substance, not the NIAGEN brand: the v2019 GOVERNED_BY_SPECIFICATION
// assertion is a BellLabs inference (PROPOSED), not a source statement. ManufacturingSpecification/SpecificationVersion
// are W11 types (consumer-side shape; tokens pending W11).

MERGE (n:Source:Entity {uid: 'hu:source:fda-grn-000635-pdf'})
ON CREATE SET n += {canonicalUri: 'https://www.fda.gov/files/food/published/GRAS-Notice-000635--Nicotinamide-riboside-chloride.pdf', title: 'GRAS Notice 635: Nicotinamide riboside chloride (Spherix GRAS determination for Niagen, 2015-12-21)', sourceKind: 'REGULATORY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:fda-grn-000635-search-extract-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.fda.gov/files/food/published/GRAS-Notice-000635--Nicotinamide-riboside-chloride.pdf', retrievedAt: datetime('2026-10-04T01:08:00Z'), observedAt: datetime('2026-10-04T01:08:00Z'), publishedAt: datetime('2016-03-29T00:00:00Z'), contentHash: 'sha256:7cf01ea5f676d28f2f76cb9564e90f0b0556e8cb9decfc0c9189ff40857c5d44', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:fda-grn-000635-pdf'}), (sn:SourceSnapshot {uid: 'hu:snapshot:fda-grn-000635-search-extract-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:grn635-table2-niagen-specifications'})
ON CREATE SET n += {uri: 'https://www.fda.gov/files/food/published/GRAS-Notice-000635--Nicotinamide-riboside-chloride.pdf', selectorKind: 'SECTION', section: 'Table 2. Specifications and Batch Analyses for Commercial Batches of Niagen', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:fda-grn-000635-search-extract-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:grn635-table2-niagen-specifications'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:efsa-2019-5775'})
ON CREATE SET n += {canonicalUri: 'https://efsa.onlinelibrary.wiley.com/doi/full/10.2903/j.efsa.2019.5775', title: 'EFSA NDA Panel 2019. Safety of nicotinamide riboside chloride as a novel food (EFSA Journal 17(8):5775)', sourceKind: 'PEER_REVIEWED_PUBLICATION', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:efsa-2019-5775-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://efsa.onlinelibrary.wiley.com/doi/full/10.2903/j.efsa.2019.5775', retrievedAt: datetime('2026-10-04T01:10:00Z'), observedAt: datetime('2026-10-04T01:10:00Z'), publishedAt: datetime('2019-08-07T00:00:00Z'), contentHash: 'sha256:45f9d78a6c5b79a81bb1eeeb80052cced9722985f7d0adc18078bbab34c65501', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:efsa-2019-5775'}), (sn:SourceSnapshot {uid: 'hu:snapshot:efsa-2019-5775-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:efsa-2019-5775-table2'})
ON CREATE SET n += {uri: 'https://efsa.onlinelibrary.wiley.com/doi/full/10.2903/j.efsa.2019.5775', selectorKind: 'TEXT_QUOTE', exact: 'The specifications of the NF as proposed by the applicant are indicated in Table 2.', quoteHash: 'sha256:844008013365c5341621b557fca49d546bb87558f23d246a22dd6a42f607d318', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:efsa-2019-5775-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:efsa-2019-5775-table2'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:BrandedIngredientMaterial:IngredientMaterial:Entity {uid: 'hu:material:chromadex-niagen'})
ON CREATE SET n += {name: 'NIAGEN', brandName: 'NIAGEN', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'BrandedIngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ManufacturingSpecification:Entity {uid: 'hu:specification:chromadex-nrc-niagen'})
ON CREATE SET n += {name: 'ChromaDex nicotinamide riboside chloride (NIAGEN) specification', specificationKind: 'INGREDIENT_MATERIAL_SPECIFICATION', entityType: 'ManufacturingSpecification', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SpecificationVersion:VersionedState {uid: 'hu:spec-version:chromadex-niagen-grn635-2015-12-21'})
ON CREATE SET n += {versionName: 'Niagen specification in GRN 635 GRAS determination dated 2015-12-21 (Table 2)', stateType: 'SpecificationVersion', payloadHash: 'sha256:15972cfa07e1473240688e281872fb5363ead7e40f5f3f3e00db45754e51dd91', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SpecificationVersion:VersionedState {uid: 'hu:spec-version:chromadex-nrc-efsa-2019'})
ON CREATE SET n += {versionName: 'NR chloride specification proposed by the applicant, EFSA Journal 2019;17(8):5775 Table 2', stateType: 'SpecificationVersion', payloadHash: 'sha256:c2fcf54b3036e2852cb54b861e3c533a8d44324fadc4f899f781e054c6c5f14b', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (v:SpecificationVersion {uid: 'hu:spec-version:chromadex-niagen-grn635-2015-12-21'}), (s:ManufacturingSpecification {uid: 'hu:specification:chromadex-nrc-niagen'})
MERGE (v)-[r:VERSION_OF_SPECIFICATION]->(s)
SET r.orderIndex = coalesce(r.orderIndex, 1);

MATCH (v:SpecificationVersion {uid: 'hu:spec-version:chromadex-nrc-efsa-2019'}), (s:ManufacturingSpecification {uid: 'hu:specification:chromadex-nrc-niagen'})
MERGE (v)-[r:VERSION_OF_SPECIFICATION]->(s)
SET r.orderIndex = coalesce(r.orderIndex, 2);

MATCH (s:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (o:SpecificationVersion {uid: 'hu:spec-version:chromadex-niagen-grn635-2015-12-21'}),
      (l0:SourceLocator {uid: 'hu:locator:grn635-table2-niagen-specifications'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-niagen-governed-by-grn635-spec-2015'})
ON CREATE SET a += {predicate: 'GOVERNED_BY_SPECIFICATION', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:8a3cd58bb9b0a115f33af3940b03ba367bd3fd89d608b7de782ab27f79ec5d44', polarity: 'POSITIVE', validFromBasis: 'PUBLICATION_PROXY', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', validFrom: datetime('2015-12-21T00:00:00Z'), validFromPrecision: 'DAY'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}), (y:SpecificationVersion {uid: 'hu:spec-version:chromadex-niagen-grn635-2015-12-21'})
MERGE (x)-[r:GOVERNED_BY_SPECIFICATION]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-niagen-governed-by-grn635-spec-2015'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-niagen-governed-by-grn635-spec-2015'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'PUBLICATION_PROXY'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.validFrom = coalesce(r.validFrom, datetime('2015-12-21T00:00:00Z')), r.validFromPrecision = coalesce(r.validFromPrecision, 'DAY');

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w02-quantity-calculator'})
ON CREATE SET n += {name: 'BellLabs quantity calculator (W02 fixture)', agentKind: 'COMPUTATIONAL_MODEL', version: 'w02-active-moiety-mass-v1', entityType: 'Agent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (o:SpecificationVersion {uid: 'hu:spec-version:chromadex-nrc-efsa-2019'}),
      (l0:SourceLocator {uid: 'hu:locator:efsa-2019-5775-table2'}),
      (ag {uid: 'hu:agent:belllabs-w02-quantity-calculator'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-niagen-governed-by-efsa-2019-spec-inferred'})
ON CREATE SET a += {predicate: 'GOVERNED_BY_SPECIFICATION', status: 'PROPOSED', recordedAt: datetime('2026-10-04T03:00:00Z'), contentHash: 'sha256:2d7de59a3302b154b7be4f4c82b1be541ed81100868e278742465a2cef9bb8d4', polarity: 'POSITIVE', validFromBasis: 'PUBLICATION_PROXY', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', extractionMethod: 'INFERENCE', assertionBasis: 'UNSTATED', validFrom: datetime('2019-08-07T00:00:00Z'), validFromPrecision: 'DAY'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0)
MERGE (a)-[:ASSERTED_BY]->(ag);

MATCH (x:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}), (y:SpecificationVersion {uid: 'hu:spec-version:chromadex-nrc-efsa-2019'})
MERGE (x)-[r:GOVERNED_BY_SPECIFICATION]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-niagen-governed-by-efsa-2019-spec-inferred'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-niagen-governed-by-efsa-2019-spec-inferred'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T03:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'PUBLICATION_PROXY'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.validFrom = coalesce(r.validFrom, datetime('2019-08-07T00:00:00Z')), r.validFromPrecision = coalesce(r.validFromPrecision, 'DAY');

// Intentionally absent: a second NIAGEN material node per specification version (V-W02-05 detects that duplicate).
