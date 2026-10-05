// W02 Substances and materials fixture (fx-04-botanical-ginkgo-preparation) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case: EU herbal monograph on Ginkgo biloba L., folium (EMA/HMPC/321097/2012, 2015) (M-10): well-established use herbal
// preparation 'Dry extract (DER 35-67:1), extraction solvent: acetone 60% m/m'; footnote 3: 'The herbal preparation should
// be in accordance with the Ph. Eur. monograph Ginkgo dry extract, refined and quantified'. The standardization ranges
// (flavone glycosides 22.0-27.0%; terpene lactones 5.0-7.0% per Ph. Eur. 7.5 cited in the EMA assessment report vs 5.4-6.6%
// per Ph. Eur. 10.0 cited in PMC9593214; USP 5.4-12.0%) are range statements that the frozen V-006 cannot hold: they are
// in fx-91 as the failing case for W02-SR-02. This file holds the preparation identity only.

MERGE (n:Source:Entity {uid: 'hu:source:ema-hmpc-ginkgo-folium-monograph'})
ON CREATE SET n += {canonicalUri: 'https://www.ema.europa.eu/en/documents/herbal-monograph/final-european-union-herbal-monograph-ginkgo-biloba-l-folium_en.pdf', title: 'European Union herbal monograph on Ginkgo biloba L., folium (EMA/HMPC/321097/2012)', sourceKind: 'REGULATORY_GUIDANCE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ema-ginkgo-monograph-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.ema.europa.eu/en/documents/herbal-monograph/final-european-union-herbal-monograph-ginkgo-biloba-l-folium_en.pdf', retrievedAt: datetime('2026-10-04T01:15:00Z'), observedAt: datetime('2026-10-04T01:15:00Z'), publishedAt: datetime('2015-01-28T00:00:00Z'), contentHash: 'sha256:79d67e3530558b8c5a3db8c8563aa33e25df637c4d9e7627ed1b552a7860120b', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:ema-hmpc-ginkgo-folium-monograph'}), (sn:SourceSnapshot {uid: 'hu:snapshot:ema-ginkgo-monograph-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:ema-ginkgo-monograph-section2'})
ON CREATE SET n += {uri: 'https://www.ema.europa.eu/en/documents/herbal-monograph/final-european-union-herbal-monograph-ginkgo-biloba-l-folium_en.pdf', selectorKind: 'SECTION', section: '2. Qualitative and quantitative composition, well-established use: Dry extract (DER 35-67:1), extraction solvent: acetone 60% m/m; footnote 3', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:ema-ginkgo-monograph-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:ema-ginkgo-monograph-section2'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:BotanicalTaxon:Entity {uid: 'hu:botanical-taxon:ginkgo-biloba'})
ON CREATE SET n += {name: 'Ginkgo biloba L.', scientificName: 'Ginkgo biloba L.', taxonRank: 'SPECIES', maturity: 'PROVISIONAL', entityType: 'BotanicalTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BotanicalPreparation:IngredientMaterial:Entity {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'})
ON CREATE SET n += {name: 'Ginkgo leaf dry extract, refined and quantified (EU monograph well-established use)', materialKind: 'BOTANICAL_PREPARATION', plantPart: 'leaf', preparationType: 'DRY_EXTRACT', extractRatio: 'DER 35-67:1', extractRatioLow: 35.0, extractRatioHigh: 67.0, solvent: 'acetone 60% m/m', maturity: 'PROVISIONAL', entityType: 'BotanicalPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}),
      (o:BotanicalTaxon {uid: 'hu:botanical-taxon:ginkgo-biloba'}),
      (l0:SourceLocator {uid: 'hu:locator:ema-ginkgo-monograph-section2'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-ginkgo-weu-extract-from-ginkgo-biloba'})
ON CREATE SET a += {predicate: 'DERIVED_FROM_TAXON', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:559f22d8ece93d906e6be8e7a1b0b9d77c93ce63a92deda6ec18031dbac3787e', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}), (y:BotanicalTaxon {uid: 'hu:botanical-taxon:ginkgo-biloba'})
MERGE (x)-[r:DERIVED_FROM_TAXON]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-ginkgo-weu-extract-from-ginkgo-biloba'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-ginkgo-weu-extract-from-ginkgo-biloba'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MERGE (n:Constituent:Entity {uid: 'hu:constituent:ginkgo-flavone-glycosides'})
ON CREATE SET n += {name: 'Ginkgo flavonoids calculated as flavone glycosides', constituentKind: 'ANALYTICAL_MEASURAND', maturity: 'PROVISIONAL', entityType: 'Constituent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Constituent:Entity {uid: 'hu:constituent:ginkgo-terpene-lactones'})
ON CREATE SET n += {name: 'Terpene lactones (ginkgolides A, B, C and bilobalide)', constituentKind: 'CHEMICAL_CLASS', maturity: 'PROVISIONAL', entityType: 'Constituent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};
