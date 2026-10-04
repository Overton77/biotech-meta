// W02 Substances and materials fixture (fx-02-mosaic-provides-not-contains) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case: Elysium Mosaic Supplement Facts (M-08): 'Phytonutrient Carotenoid Complex [Tomato [fruit] extract (providing
// lycopene, phytoene, phytofluene, and tocopherols), Rosemary [leaf] extract (providing carnosic acid)] 395 mg' and
// 'Vitamin A (from Beta-Carotene) 70.8 mcg RAE (8% DV)'. Science page (M-09): 'four plant-derived carotenoids from
// tomato extract - lycopene, phytoene, phytofluene, and beta-carotene - with carnosic acid ... from rosemary extract'.
// 'providing' is PROVIDES_CONSTITUENT; no source states a lycopene amount, so no QUANTITATIVELY_CONTAINS exists and the
// lycopene amount answer is NOT_STATED (CQ-ID-03; forbidden implication [PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]).
// The label and the science page disagree (tocopherols vs beta-carotene as the fourth tomato item); both are kept as
// separate assertions from separate sources.

MERGE (n:Source:Entity {uid: 'hu:source:elysium-mosaic-supplement-facts'})
ON CREATE SET n += {canonicalUri: 'https://www.elysiumhealth.com/pages/mosaic-supplement-facts', title: 'Mosaic: Ingredients, Side Effects & Supplement Facts', sourceKind: 'MANUFACTURER_LABEL_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-mosaic-supplement-facts-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.elysiumhealth.com/pages/mosaic-supplement-facts', retrievedAt: datetime('2026-10-04T01:05:00Z'), observedAt: datetime('2026-10-04T01:05:00Z'), contentHash: 'sha256:2a5d179afb291fe7d3f8d92dbb64e2da34bf52bec113e68de796a16fe61e81b8', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:elysium-mosaic-supplement-facts'}), (sn:SourceSnapshot {uid: 'hu:snapshot:elysium-mosaic-supplement-facts-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:mosaic-sf-pc-complex'})
ON CREATE SET n += {uri: 'https://www.elysiumhealth.com/pages/mosaic-supplement-facts', selectorKind: 'TEXT_QUOTE', exact: 'Phytonutrient Carotenoid Complex [Tomato [fruit] extract (providing lycopene, phytoene, phytofluene, and tocopherols), Rosemary [leaf] extract (providing carnosic acid)] 395 mg', quoteHash: 'sha256:180d57fff05927095b546929daa56bf1f15471857ea2fd501dce56a41d39f12b', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:elysium-mosaic-supplement-facts-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:mosaic-sf-vitamin-a'})
ON CREATE SET n += {uri: 'https://www.elysiumhealth.com/pages/mosaic-supplement-facts', selectorKind: 'TEXT_QUOTE', exact: 'Vitamin A (from Beta-Carotene) 70.8 mcg RAE (8% DV)', quoteHash: 'sha256:e0063858f564f1bfc62f82c2991cc9d8d90b1c7140bad76e8af6f5145f446235', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:elysium-mosaic-supplement-facts-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:mosaic-sf-vitamin-a'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:elysium-mosaic-science'})
ON CREATE SET n += {canonicalUri: 'https://www.elysiumhealth.com/pages/science-behind-mosaic', title: 'The Science Behind Mosaic', sourceKind: 'MARKETING_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-mosaic-science-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.elysiumhealth.com/pages/science-behind-mosaic', retrievedAt: datetime('2026-10-04T01:04:00Z'), observedAt: datetime('2026-10-04T01:04:00Z'), contentHash: 'sha256:3e5eef827807ae2e5f4298339b183aecd18e2588f00aaba2d9e1f4650e9e85b1', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:elysium-mosaic-science'}), (sn:SourceSnapshot {uid: 'hu:snapshot:elysium-mosaic-science-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:mosaic-science-pc-complex'})
ON CREATE SET n += {uri: 'https://www.elysiumhealth.com/pages/science-behind-mosaic', selectorKind: 'TEXT_QUOTE', exact: 'combines four plant-derived carotenoids from tomato extract—lycopene, phytoene, phytofluene, and beta-carotene—with carnosic acid, a major antioxidant from rosemary extract', quoteHash: 'sha256:01ea7b96f6663f2b5dc9102daba735cd821403a1bd70b17df81a433b2fba563a', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:elysium-mosaic-science-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:mosaic-science-pc-complex'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:MaterialMixture:IngredientMaterial:Entity {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'})
ON CREATE SET n += {name: 'Phytonutrient Carotenoid Complex (Elysium Mosaic)', materialKind: 'MATERIAL_MIXTURE', mixtureKind: 'NAMED_COMPLEX', maturity: 'PROVISIONAL', entityType: 'MaterialMixture', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BotanicalPreparation:IngredientMaterial:Entity {uid: 'hu:material:mosaic-tomato-fruit-extract'})
ON CREATE SET n += {name: 'Tomato [fruit] extract (Mosaic PC Complex)', materialKind: 'BOTANICAL_PREPARATION', plantPart: 'fruit', maturity: 'PROVISIONAL', entityType: 'BotanicalPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BotanicalPreparation:IngredientMaterial:Entity {uid: 'hu:material:mosaic-rosemary-leaf-extract'})
ON CREATE SET n += {name: 'Rosemary [leaf] extract (Mosaic PC Complex)', materialKind: 'BOTANICAL_PREPARATION', plantPart: 'leaf', maturity: 'PROVISIONAL', entityType: 'BotanicalPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// Taxa resolved from common names only (label gives 'Tomato', 'Rosemary'); taxonomyId left null (not looked up = unknown).

MERGE (n:BotanicalTaxon:Entity {uid: 'hu:botanical-taxon:solanum-lycopersicum'})
ON CREATE SET n += {name: 'Solanum lycopersicum', scientificName: 'Solanum lycopersicum', taxonRank: 'SPECIES', maturity: 'PROVISIONAL', entityType: 'BotanicalTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BotanicalTaxon:Entity {uid: 'hu:botanical-taxon:rosemary'})
ON CREATE SET n += {name: 'Rosemary (Salvia rosmarinus / Rosmarinus officinalis)', scientificName: 'Salvia rosmarinus', taxonRank: 'SPECIES', maturity: 'CANDIDATE', entityType: 'BotanicalTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}),
      (o:IngredientMaterial {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-pc-complex-has-tomato-extract'})
ON CREATE SET a += {predicate: 'HAS_MIXTURE_COMPONENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e0c6f7dcbf579afcff6df2d6db2b3748cd34db14424756e34ba821f7e8b853eb', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}), (y:IngredientMaterial {uid: 'hu:material:mosaic-tomato-fruit-extract'})
MERGE (x)-[r:HAS_MIXTURE_COMPONENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-pc-complex-has-tomato-extract'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-pc-complex-has-tomato-extract'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}),
      (o:IngredientMaterial {uid: 'hu:material:mosaic-rosemary-leaf-extract'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-pc-complex-has-rosemary-extract'})
ON CREATE SET a += {predicate: 'HAS_MIXTURE_COMPONENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:461b923ff6c72daea66691270f055dd82137f981ba93faac20a95a99bbf1c4b3', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}), (y:IngredientMaterial {uid: 'hu:material:mosaic-rosemary-leaf-extract'})
MERGE (x)-[r:HAS_MIXTURE_COMPONENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-pc-complex-has-rosemary-extract'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-pc-complex-has-rosemary-extract'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:BotanicalTaxon {uid: 'hu:botanical-taxon:solanum-lycopersicum'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-tomato-extract-from-solanum-lycopersicum'})
ON CREATE SET a += {predicate: 'DERIVED_FROM_TAXON', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:36bf053b5aaed39b3705a44dcdcfd092fe593a24dff95daff7b1f3919bceb8d8', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', extractionMethod: 'COMMON_NAME_RESOLUTION'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:BotanicalTaxon {uid: 'hu:botanical-taxon:solanum-lycopersicum'})
MERGE (x)-[r:DERIVED_FROM_TAXON]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-tomato-extract-from-solanum-lycopersicum'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-tomato-extract-from-solanum-lycopersicum'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-rosemary-leaf-extract'}),
      (o:BotanicalTaxon {uid: 'hu:botanical-taxon:rosemary'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-rosemary-extract-from-rosemary-taxon'})
ON CREATE SET a += {predicate: 'DERIVED_FROM_TAXON', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:8f3018d11b0e6a4566395acaf95cc4529b691289d8966e656a23467c938309cb', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', extractionMethod: 'COMMON_NAME_RESOLUTION'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-rosemary-leaf-extract'}), (y:BotanicalTaxon {uid: 'hu:botanical-taxon:rosemary'})
MERGE (x)-[r:DERIVED_FROM_TAXON]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-rosemary-extract-from-rosemary-taxon'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-rosemary-extract-from-rosemary-taxon'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Constituents: defined compounds are ChemicalSubstance (CANDIDATE: no identifiers looked up in this run); classes are Constituent.

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:lycopene'})
ON CREATE SET n += {name: 'Lycopene', preferredName: 'Lycopene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:phytoene'})
ON CREATE SET n += {name: 'Phytoene', preferredName: 'Phytoene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:phytofluene'})
ON CREATE SET n += {name: 'Phytofluene', preferredName: 'Phytofluene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:carnosic-acid'})
ON CREATE SET n += {name: 'Carnosic acid', preferredName: 'Carnosic acid', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:beta-carotene'})
ON CREATE SET n += {name: 'beta-Carotene', preferredName: 'beta-Carotene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Constituent:Entity {uid: 'hu:constituent:tocopherols'})
ON CREATE SET n += {name: 'Tocopherols', constituentKind: 'CHEMICAL_CLASS', maturity: 'PROVISIONAL', entityType: 'Constituent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Constituent:Entity {uid: 'hu:constituent:carotenoids'})
ON CREATE SET n += {name: 'Carotenoids', constituentKind: 'CHEMICAL_CLASS', maturity: 'PROVISIONAL', entityType: 'Constituent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Nutrient:Entity {uid: 'hu:nutrient:vitamin-a'})
ON CREATE SET n += {name: 'Vitamin A', nutrientKind: 'VITAMIN', maturity: 'PROVISIONAL', entityType: 'Nutrient', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:lycopene'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-label-tomato-extract-provides-lycopene'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:79b77e362b5b6fa35356888415224e113e29551f9d93d373ac19a7dc11cc1051', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:lycopene'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-label-tomato-extract-provides-lycopene'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-label-tomato-extract-provides-lycopene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:phytoene'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-label-tomato-extract-provides-phytoene'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:36793cb1ac3a00078e49220375f79b34b23ff56d39e852cbf9e641a3029a5f71', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:phytoene'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-label-tomato-extract-provides-phytoene'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-label-tomato-extract-provides-phytoene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:phytofluene'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-label-tomato-extract-provides-phytofluene'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:0a7ce49e6facd7697cf5231422ca3546351c9a2f3ff117c26ef933c2b884e28c', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:phytofluene'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-label-tomato-extract-provides-phytofluene'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-label-tomato-extract-provides-phytofluene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:Constituent {uid: 'hu:constituent:tocopherols'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-label-tomato-extract-provides-tocopherols'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:9e14b2373382822943f5978548b886ef0e4d0d649355d62460afafda0cb6d76a', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:Constituent {uid: 'hu:constituent:tocopherols'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-label-tomato-extract-provides-tocopherols'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-label-tomato-extract-provides-tocopherols'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-rosemary-leaf-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:carnosic-acid'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-label-rosemary-extract-provides-carnosic-acid'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:07fe383b04cb4808fdb2ef43789b1e0e4896d996c2e724b25c380c35c93421dc', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-rosemary-leaf-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:carnosic-acid'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-label-rosemary-extract-provides-carnosic-acid'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-label-rosemary-extract-provides-carnosic-acid'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:beta-carotene'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-science-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-science-tomato-extract-provides-beta-carotene'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:968896d778635193cdf706371a4f2c25af161d5ca3fa138cc4a3a1e51bc34f34', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:mosaic-tomato-fruit-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:beta-carotene'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-science-tomato-extract-provides-beta-carotene'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-science-tomato-extract-provides-beta-carotene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}),
      (o:Constituent {uid: 'hu:constituent:carotenoids'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-science-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-science-pc-complex-provides-carotenoids'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:56d1f056ab303743bef688d9901c6071c4b25f90daae279847507822b63d19b6', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MaterialMixture {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}), (y:Constituent {uid: 'hu:constituent:carotenoids'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-science-pc-complex-provides-carotenoids'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-science-pc-complex-provides-carotenoids'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Vitamin A line: the amount is the nutrient (NUTRIENT_AS_NUTRIENT); the source material is a beta-carotene material of
// unresolved origin that PROVIDES_CONSTITUENT the nutrient. Components are W04 types (consumer-side shape).

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:mosaic-beta-carotene-source'})
ON CREATE SET n += {name: 'Beta-carotene source material in Mosaic (origin unresolved)', materialKind: 'UNRESOLVED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'}),
      (o:ChemicalSubstance {uid: 'hu:substance:beta-carotene'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-vitamin-a'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-mosaic-bc-source-realizes-beta-carotene'})
ON CREATE SET a += {predicate: 'REALIZES_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:87af0dfb9a2d8c80821bd342ddfcce0b0c5e1767ab5b270e131864810494d94f', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'}), (y:ChemicalSubstance {uid: 'hu:substance:beta-carotene'})
MERGE (x)-[r:REALIZES_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-mosaic-bc-source-realizes-beta-carotene'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-mosaic-bc-source-realizes-beta-carotene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'}),
      (o:Nutrient {uid: 'hu:nutrient:vitamin-a'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-vitamin-a'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-mosaic-bc-source-provides-vitamin-a'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:dd6cbbe3a977479e53f44185e502e58506ac3a67396c7a11e670ab04fa81da7a', polarity: 'POSITIVE', predicateClass: 'CLAIM', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'}), (y:Nutrient {uid: 'hu:nutrient:vitamin-a'})
MERGE (x)-[r:PROVIDES_CONSTITUENT]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-mosaic-bc-source-provides-vitamin-a'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-mosaic-bc-source-provides-vitamin-a'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MERGE (n:IngredientComponent:VersionedState {uid: 'hu:component:mosaic-us-pc-complex'})
ON CREATE SET n += {role: 'DIETARY_INGREDIENT', labelOrder: 2, quantity: 395.0, unitCode: 'mg', quantityBasis: 'PER_SERVING', massBasis: 'MATERIAL_AS_IS', amountReferent: 'PROPRIETARY_BLEND_TOTAL', declaredAs: 'Phytonutrient Carotenoid Complex [...] 395 mg', stateType: 'IngredientComponent', payloadHash: 'sha256:461f4be798bf72ed5e63124a824dd5f3443b8867a30f43f2fac06a66666a377c', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:IngredientComponent:VersionedState {uid: 'hu:component:mosaic-us-vitamin-a'})
ON CREATE SET n += {role: 'DIETARY_INGREDIENT', labelOrder: 1, quantity: 70.8, unitCode: 'ug{RAE}', quantityBasis: 'PER_SERVING', massBasis: 'UNSPECIFIED', amountReferent: 'NUTRIENT_AS_NUTRIENT', declaredAs: 'Vitamin A (from Beta-Carotene)', stateType: 'IngredientComponent', payloadHash: 'sha256:89cf85e3fc128125585b10ca8337b698e2f4e70df1f0382d8889d9dd6f15e56d', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientComponent {uid: 'hu:component:mosaic-us-pc-complex'}),
      (o:IngredientMaterial {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-pc-complex'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-mosaic-pc-component-uses-complex'})
ON CREATE SET a += {predicate: 'USES_MATERIAL', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e3714274405a9955c622c9f08e89cc865b016bfe3dc351b0f0c1c98c16446924', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientComponent {uid: 'hu:component:mosaic-us-pc-complex'}), (y:IngredientMaterial {uid: 'hu:material:elysium-phytonutrient-carotenoid-complex'})
MERGE (x)-[r:USES_MATERIAL]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-mosaic-pc-component-uses-complex'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-mosaic-pc-component-uses-complex'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientComponent {uid: 'hu:component:mosaic-us-vitamin-a'}),
      (o:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'}),
      (l0:SourceLocator {uid: 'hu:locator:mosaic-sf-vitamin-a'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-mosaic-vitamin-a-component-uses-bc-source'})
ON CREATE SET a += {predicate: 'USES_MATERIAL', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4625a37bdacd59edfeba3f2655af406a5b66a626907e2b65347b71da8ae84e48', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientComponent {uid: 'hu:component:mosaic-us-vitamin-a'}), (y:IngredientMaterial {uid: 'hu:material:mosaic-beta-carotene-source'})
MERGE (x)-[r:USES_MATERIAL]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-mosaic-vitamin-a-component-uses-bc-source'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-mosaic-vitamin-a-component-uses-bc-source'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Intentionally absent: any QUANTITATIVELY_CONTAINS from these materials. The 395 mg is the blend total; nested amounts
// are unknown (OPEN-QUESTIONS P1-6) and are never divided out.
