// W02 Substances and materials fixture (fx-01-nr-salt-vs-moiety) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case: one substance family, two ChemicalSubstance identities. GSRS registers nicotinamide riboside chloride
// (UNII 8XM2XT8VWI, moiety type Salt or Solvate) and nicotinamide riboside (UNII 0I8H2M0L7N, moiety type Active Moiety)
// as two records joined by PARENT->SALT/SOLVATE and ACTIVE MOIETY (M-01, M-02). PubChem: CID 90480033 C11H15ClN2O5
// 290.70; CID 439924 C11H15N2O5+ 255.25 (M-03, M-04). Neither node is merged into the other; the salt -> moiety link is
// HAS_ACTIVE_MOIETY, and the per-serving NR cation mass is a CALCULATED assertion, never a label declaration (INV-307).
// CQs: CQ-ID-04, CQ-PF-01, CQ-ID-06, CQ-ST-02.

MERGE (n:Source:Entity {uid: 'hu:source:gsrs-substance-2dbc6656'})
ON CREATE SET n += {canonicalUri: 'https://gsrs.ncats.nih.gov/api/v1/substances(2dbc6656-1822-4fe7-828a-74edb0b32990)', title: 'GSRS substance record NICOTINAMIDE RIBOSIDE CHLORIDE (UNII 8XM2XT8VWI), version 18', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:gsrs-2dbc6656-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://gsrs.ncats.nih.gov/api/v1/substances(2dbc6656-1822-4fe7-828a-74edb0b32990)', retrievedAt: datetime('2026-10-04T00:55:00Z'), observedAt: datetime('2026-10-04T00:55:00Z'), contentHash: 'sha256:769edda2bafbbfbc64c4acd6ff9a62bad9a0a03b62021f35c09b7d3c544edd69', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:gsrs-substance-2dbc6656'}), (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-2dbc6656-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:gsrs-2dbc6656-codes'})
ON CREATE SET n += {uri: 'https://gsrs.ncats.nih.gov/api/v1/substances(2dbc6656-1822-4fe7-828a-74edb0b32990)', selectorKind: 'SECTION', section: 'codes', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-2dbc6656-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-codes'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:gsrs-2dbc6656-relationships'})
ON CREATE SET n += {uri: 'https://gsrs.ncats.nih.gov/api/v1/substances(2dbc6656-1822-4fe7-828a-74edb0b32990)', selectorKind: 'SECTION', section: 'relationships (PARENT->SALT/SOLVATE; ACTIVE MOIETY -> 0I8H2M0L7N)', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-2dbc6656-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-relationships'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:gsrs-substance-28396807'})
ON CREATE SET n += {canonicalUri: 'https://gsrs.ncats.nih.gov/api/v1/substances(28396807-ae13-49f8-a22f-77db56866985)', title: 'GSRS substance record NICOTINAMIDE RIBOSIDE (UNII 0I8H2M0L7N), version 24', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:gsrs-28396807-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://gsrs.ncats.nih.gov/api/v1/substances(28396807-ae13-49f8-a22f-77db56866985)', retrievedAt: datetime('2026-10-04T00:56:00Z'), observedAt: datetime('2026-10-04T00:56:00Z'), contentHash: 'sha256:e23bacd9877607689487e2c5b0f3ca369dca12a9ab344fb246e500cecf902bd6', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:gsrs-substance-28396807'}), (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-28396807-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:gsrs-28396807-codes'})
ON CREATE SET n += {uri: 'https://gsrs.ncats.nih.gov/api/v1/substances(28396807-ae13-49f8-a22f-77db56866985)', selectorKind: 'SECTION', section: 'codes', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-28396807-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:gsrs-28396807-codes'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:gsrs-28396807-relationships'})
ON CREATE SET n += {uri: 'https://gsrs.ncats.nih.gov/api/v1/substances(28396807-ae13-49f8-a22f-77db56866985)', selectorKind: 'SECTION', section: 'relationships (ACTIVE MOIETY -> self; SALT/SOLVATE->PARENT -> 8XM2XT8VWI)', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:gsrs-28396807-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:gsrs-28396807-relationships'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:pubchem-cid-90480033-properties'})
ON CREATE SET n += {canonicalUri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/90480033/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', title: 'PubChem PUG REST property table CID 90480033', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubchem-cid-90480033-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/90480033/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', retrievedAt: datetime('2026-10-04T00:52:00Z'), observedAt: datetime('2026-10-04T00:52:00Z'), contentHash: 'sha256:5458c73f97cee162fdd1d67068cb4a67050e68713ec54d3e174b59d816c6f842', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:pubchem-cid-90480033-properties'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pubchem-cid-90480033-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pubchem-cid-90480033-mw'})
ON CREATE SET n += {uri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/90480033/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', selectorKind: 'TEXT_QUOTE', exact: '"MolecularWeight": "290.70"', quoteHash: 'sha256:8f09f2b876fd6448bf5fb1dfb8d60dcd6e0d55b6981334d964730cdd12df2364', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:pubchem-cid-90480033-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pubchem-cid-90480033-mw'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:pubchem-cid-439924-properties'})
ON CREATE SET n += {canonicalUri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/439924/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', title: 'PubChem PUG REST property table CID 439924', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubchem-cid-439924-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/439924/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', retrievedAt: datetime('2026-10-04T00:52:00Z'), observedAt: datetime('2026-10-04T00:52:00Z'), contentHash: 'sha256:9aaa890eb0c49a3df94b1b0672d4d1e848b300ec9f2a016e3429e3eb5dcefb8d', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:pubchem-cid-439924-properties'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pubchem-cid-439924-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pubchem-cid-439924-mw'})
ON CREATE SET n += {uri: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/439924/property/MolecularFormula,MolecularWeight,InChIKey,IUPACName,Charge/JSON', selectorKind: 'TEXT_QUOTE', exact: '"MolecularWeight": "255.25"', quoteHash: 'sha256:eda48def90fd200bdbc402adc43281a2c84b2734a8891400883ea6edd0598906', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:pubchem-cid-439924-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pubchem-cid-439924-mw'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:truniagen-300mg-product-page'})
ON CREATE SET n += {canonicalUri: 'https://www.truniagen.com/products/tru-niagen-300mg', title: 'Tru Niagen 300mg product page', sourceKind: 'MANUFACTURER_LABEL_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:truniagen-300mg-2026-10-03'})
ON CREATE SET n += {canonicalUri: 'https://www.truniagen.com/products/tru-niagen-300mg', retrievedAt: datetime('2026-10-03T00:00:00Z'), observedAt: datetime('2026-10-03T00:00:00Z'), contentHash: 'sha256:6d8498357f2d846db6aa1fd3ee2dd621f3fa022cf312af89cedb59a3a1895315', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:truniagen-300mg-product-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-2026-10-03'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-supplement-facts'})
ON CREATE SET n += {uri: 'https://www.truniagen.com/products/tru-niagen-300mg', selectorKind: 'SECTION', section: 'Supplement Facts', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:truniagen-300mg-supplement-facts'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:doi-10.1038-s41598-019-46120-z'})
ON CREATE SET n += {canonicalUri: 'https://doi.org/10.1038/s41598-019-46120-z', title: 'Conze et al. 2019 Sci Rep 9:9772 (PMID 31278280)', sourceKind: 'PEER_REVIEWED_PUBLICATION', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmid31278280-2026-10-03'})
ON CREATE SET n += {canonicalUri: 'https://doi.org/10.1038/s41598-019-46120-z', retrievedAt: datetime('2026-10-03T00:00:00Z'), observedAt: datetime('2026-10-03T00:00:00Z'), contentHash: 'sha256:3bcf00a939cdbf3b4a02ba9a0a3f1d818fd43bb52dacd2a155d44eb435e9f850', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:doi-10.1038-s41598-019-46120-z'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pmid31278280-2026-10-03'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmid31278280-abstract'})
ON CREATE SET n += {uri: 'https://doi.org/10.1038/s41598-019-46120-z', selectorKind: 'SECTION', section: 'Abstract', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:pmid31278280-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:Source:Entity {uid: 'hu:source:doi-10.1038-s41514-017-0016-9'})
ON CREATE SET n += {canonicalUri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', sourceKind: 'PEER_REVIEWED_PUBLICATION', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc5701244-2026-10-03'})
ON CREATE SET n += {canonicalUri: 'https://doi.org/10.1038/s41514-017-0016-9', retrievedAt: datetime('2026-10-03T00:00:00Z'), observedAt: datetime('2026-10-03T00:00:00Z'), contentHash: 'sha256:6bf163bdf9fded476f4aa86f6c7418256b9662491b1c2ce90ac0ae65016be790', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:doi-10.1038-s41514-017-0016-9'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pmc5701244-2026-10-03'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmid29184669-methods-intervention-w02'})
ON CREATE SET n += {uri: 'https://doi.org/10.1038/s41514-017-0016-9', selectorKind: 'SECTION', section: 'Methods: Intervention (125 mg NR + 25 mg PT per capsule)', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:pmc5701244-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:pmid29184669-methods-intervention-w02'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide-riboside-chloride'})
ON CREATE SET n += {name: 'Nicotinamide riboside chloride', preferredName: 'Nicotinamide riboside chloride', molecularFormula: 'C11H15ClN2O5', pubchemCid: '90480033', inchikey: 'YABIFCKURFRPPO-IVOJBTPCSA-N', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide-riboside'})
ON CREATE SET n += {name: 'Nicotinamide riboside', preferredName: 'Nicotinamide riboside', molecularFormula: 'C11H15N2O5+', pubchemCid: '439924', inchikey: 'JLEBZPBDRKPWTD-TURQNECASA-O', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// Identifiers (CQ-ID-04): each is an Identifier record with scheme and issuer; GSRS also lists GRN 635 as a code on the salt
// record, which is a regulatory submission number (W13), not a substance identifier, so it is not attached here.

MERGE (n:Identifier:Entity {uid: 'hu:identifier:unii-8XM2XT8VWI'})
ON CREATE SET n += {scheme: 'UNII', value: '8XM2XT8VWI', issuer: 'FDA GSRS', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (o:Identifier {uid: 'hu:identifier:unii-8XM2XT8VWI'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-unii-8XM2XT8VWI-identifies-nicotinamide-riboside-chloride'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:8d15a296ac9a9af73e8a40fd142f8bfd4d84c2d617f176350af48d7078632166', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}), (y:Identifier {uid: 'hu:identifier:unii-8XM2XT8VWI'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-unii-8XM2XT8VWI-identifies-nicotinamide-riboside-chloride'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-unii-8XM2XT8VWI-identifies-nicotinamide-riboside-chloride'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, true);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:cas-23111-00-4'})
ON CREATE SET n += {scheme: 'CAS', value: '23111-00-4', issuer: 'CAS (as recorded in FDA GSRS)', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (o:Identifier {uid: 'hu:identifier:cas-23111-00-4'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-cas-23111-00-4-identifies-nicotinamide-riboside-chloride'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:f3f9fd775b6f702d0405cad59e5e46d308211b47ebad33d98295d530349f1602', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}), (y:Identifier {uid: 'hu:identifier:cas-23111-00-4'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-cas-23111-00-4-identifies-nicotinamide-riboside-chloride'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-cas-23111-00-4-identifies-nicotinamide-riboside-chloride'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:pubchem-cid-90480033'})
ON CREATE SET n += {scheme: 'PUBCHEM_CID', value: '90480033', issuer: 'NCBI PubChem', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (o:Identifier {uid: 'hu:identifier:pubchem-cid-90480033'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-pubchem-cid-90480033-identifies-nicotinamide-riboside-chloride'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4de01db7ca0f646ab5d627860297733493032cec19bec47a417aa7a251ce90ef', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}), (y:Identifier {uid: 'hu:identifier:pubchem-cid-90480033'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-pubchem-cid-90480033-identifies-nicotinamide-riboside-chloride'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-pubchem-cid-90480033-identifies-nicotinamide-riboside-chloride'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:unii-0I8H2M0L7N'})
ON CREATE SET n += {scheme: 'UNII', value: '0I8H2M0L7N', issuer: 'FDA GSRS', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (o:Identifier {uid: 'hu:identifier:unii-0I8H2M0L7N'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-28396807-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-unii-0I8H2M0L7N-identifies-nicotinamide-riboside'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:355f6a98fc2b4c490a3d5112ce0db4a3999920ca5224e6058175f65060ebb20d', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (y:Identifier {uid: 'hu:identifier:unii-0I8H2M0L7N'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-unii-0I8H2M0L7N-identifies-nicotinamide-riboside'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-unii-0I8H2M0L7N-identifies-nicotinamide-riboside'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, true);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:cas-1341-23-7'})
ON CREATE SET n += {scheme: 'CAS', value: '1341-23-7', issuer: 'CAS (as recorded in FDA GSRS)', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (o:Identifier {uid: 'hu:identifier:cas-1341-23-7'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-28396807-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-cas-1341-23-7-identifies-nicotinamide-riboside'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:44b670a5eea05c59ea6f9d8f54d51643e0c858b4f4e07c4f28f3ec25506725ac', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (y:Identifier {uid: 'hu:identifier:cas-1341-23-7'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-cas-1341-23-7-identifies-nicotinamide-riboside'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-cas-1341-23-7-identifies-nicotinamide-riboside'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:pubchem-cid-439924'})
ON CREATE SET n += {scheme: 'PUBCHEM_CID', value: '439924', issuer: 'NCBI PubChem', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (o:Identifier {uid: 'hu:identifier:pubchem-cid-439924'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-28396807-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-pubchem-cid-439924-identifies-nicotinamide-riboside'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:32acbfb382ec82b9723dd5109540be89f11f356ff327142a189c7c840d2dbde3', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (y:Identifier {uid: 'hu:identifier:pubchem-cid-439924'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-pubchem-cid-439924-identifies-nicotinamide-riboside'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-pubchem-cid-439924-identifies-nicotinamide-riboside'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

MERGE (n:Identifier:Entity {uid: 'hu:identifier:chebi-15927'})
ON CREATE SET n += {scheme: 'CHEBI', value: 'CHEBI:15927', issuer: 'EMBL-EBI ChEBI (as recorded in FDA GSRS)', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (o:Identifier {uid: 'hu:identifier:chebi-15927'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-28396807-codes'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-chebi-15927-identifies-nicotinamide-riboside'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4addec9de04b271cca2a4d2b1049f3db165f5b2d4103dabf3f5d5d58fa900212', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (y:Identifier {uid: 'hu:identifier:chebi-15927'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-chebi-15927-identifies-nicotinamide-riboside'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-chebi-15927-identifies-nicotinamide-riboside'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, false);

// Active moiety (catalog HAS_ACTIVE_MOIETY). The moiety record points at itself in GSRS; the self-edge distinguishes
// 'is its own active moiety' from 'active moiety unknown' (no edge).

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-2dbc6656-relationships'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-nrc-has-active-moiety-nr'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:0cf74f74e85b30e9201fd4008aa164957d32d0aa46867239c5b6c8074a2ac784', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-nrc-has-active-moiety-nr'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-nrc-has-active-moiety-nr'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:gsrs-28396807-relationships'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-nr-has-active-moiety-nr-self'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:fe83e6546bd82793f948df922b8ac63a46e5c120295ed1b4d883777414ec62e0', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-nr-has-active-moiety-nr-self'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-nr-has-active-moiety-nr-self'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Molecular weights are literal assertions (candidate predicate HAS_MOLECULAR_WEIGHT, seam W02-SR-04); live
// Compound.molecularWeight migrates here. GSRS gives 290.7006 / 255.2476 (second source, not asserted here).

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (l0:SourceLocator {uid: 'hu:locator:pubchem-cid-90480033-mw'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-nrc-molecular-weight-pubchem'})
ON CREATE SET a += {predicate: 'HAS_MOLECULAR_WEIGHT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:dea82dc0a2870353e3171c4adeba47b8b473fbbef318079d58f61418b9d47d4e', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 290.7, unitCode: 'g/mol'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:pubchem-cid-439924-mw'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-nr-molecular-weight-pubchem'})
ON CREATE SET a += {predicate: 'HAS_MOLECULAR_WEIGHT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:a6eff765576517237b42c0252a2f2ceba497eebd9bfea32bb157cc40ca0317c1', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 255.25, unitCode: 'g/mol'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:SUPPORTED_BY]->(l0);

// Chemical form: NIAGEN is described as a crystal form of NR chloride (Conze abstract, M-17 inherited). The form
// belongs to the salt substance, not to NR and not to the branded material.

MERGE (n:ChemicalForm:Entity {uid: 'hu:chemical-form:nr-chloride-crystal-niagen'})
ON CREATE SET n += {name: 'Nicotinamide riboside chloride, crystal form (as described for NIAGEN)', formKind: 'CRYSTAL_FORM', maturity: 'PROVISIONAL', entityType: 'ChemicalForm', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalForm {uid: 'hu:chemical-form:nr-chloride-crystal-niagen'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (l0:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-niagen-crystal-form-of-nrc'})
ON CREATE SET a += {predicate: 'FORM_OF_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:cd5f0bb6a34ddf15b67e4613fd47a49198c9f1ba44584685c689403af1eac208', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalForm {uid: 'hu:chemical-form:nr-chloride-crystal-niagen'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (x)-[r:FORM_OF_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-niagen-crystal-form-of-nrc'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-niagen-crystal-form-of-nrc'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Materials. NIAGEN (branded, realizes the salt exactly); the 2016 trial NR (source names only 'NR': moiety-level
// statement, salt unresolved); a SYNTHETIC amorphous NR chloride from another supplier (same salt, different form).

MERGE (n:BrandedIngredientMaterial:IngredientMaterial:Entity {uid: 'hu:material:chromadex-niagen'})
ON CREATE SET n += {name: 'NIAGEN', brandName: 'NIAGEN', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'BrandedIngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:nct02678611-nr-as-supplied'})
ON CREATE SET n += {name: 'NR as administered in NCT02678611 (supplier unresolved)', materialKind: 'UNRESOLVED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (l0:SourceLocator {uid: 'hu:locator:truniagen-300mg-supplement-facts'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-niagen-realizes-nrc'})
ON CREATE SET a += {predicate: 'REALIZES_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:05f66b84713f6cd60a9b40b771538cfc92cf2ef28e4014c06917be7e5c52526a', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (x)-[r:REALIZES_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-niagen-realizes-nrc'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-niagen-realizes-nrc'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (o:ChemicalForm {uid: 'hu:chemical-form:nr-chloride-crystal-niagen'}),
      (l0:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-niagen-has-crystal-form'})
ON CREATE SET a += {predicate: 'HAS_CHEMICAL_FORM', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:ace5a1c69780ff74d371ebc9747e7509407be7de39ae4b3f72e52ccd434b5ab3', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}), (y:ChemicalForm {uid: 'hu:chemical-form:nr-chloride-crystal-niagen'})
MERGE (x)-[r:HAS_CHEMICAL_FORM]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-niagen-has-crystal-form'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-niagen-has-crystal-form'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:pmid29184669-methods-intervention-w02'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-trial-nr-realizes-nr-moiety-level'})
ON CREATE SET a += {predicate: 'REALIZES_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:fe2484344b2f926aff950d1ac9d02aed8673975f22d22d31b1df41c7fb538e0f', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:REALIZES_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-trial-nr-realizes-nr-moiety-level'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-trial-nr-realizes-nr-moiety-level'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MERGE (n:Source:Entity {uid: 'hu:source:synthetic-w02-supplier-x-coa'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', title: 'SYNTHETIC supplier X technical sheet (fixture only)', sourceKind: 'MARKETING_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), contentHash: 'sha256:812cec4cb030c8505c3b0fbd9e7ff9ffa45d61ff66165d8b2247718d363d54e9', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:synthetic-w02-supplier-x-coa'}), (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
ON CREATE SET n += {uri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', selectorKind: 'WHOLE_SNAPSHOT', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:ChemicalForm:Entity {uid: 'hu:form:synthetic-nrc-amorphous'})
ON CREATE SET n += {name: 'Nicotinamide riboside chloride, amorphous (SYNTHETIC)', formKind: 'AMORPHOUS_FORM', maturity: 'CANDIDATE', entityType: 'ChemicalForm', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'})
ON CREATE SET n += {name: 'Supplier X NR chloride, amorphous (SYNTHETIC)', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'CANDIDATE', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalForm {uid: 'hu:form:synthetic-nrc-amorphous'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-synthetic-amorphous-form-of-nrc'})
ON CREATE SET a += {predicate: 'FORM_OF_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:e8918fef666310f21d74c948b3aa4a6f4598aa4e394bf736c7af8fdc97e86767', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalForm {uid: 'hu:form:synthetic-nrc-amorphous'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (x)-[r:FORM_OF_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-synthetic-amorphous-form-of-nrc'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-synthetic-amorphous-form-of-nrc'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-synthetic-supplier-x-realizes-nrc'})
ON CREATE SET a += {predicate: 'REALIZES_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:cce1dca9b4400eb83ab5f6db9c251d0ffe6a22a6b9ee7db582e8084383d5ad23', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (x)-[r:REALIZES_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-synthetic-supplier-x-realizes-nrc'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-synthetic-supplier-x-realizes-nrc'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'}),
      (o:ChemicalForm {uid: 'hu:form:synthetic-nrc-amorphous'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-synthetic-supplier-x-has-amorphous-form'})
ON CREATE SET a += {predicate: 'HAS_CHEMICAL_FORM', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:a1b83d47865976ea991711885867fceb51c55ee6eb6cd9b9e412a0bf953dca2e', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'}), (y:ChemicalForm {uid: 'hu:form:synthetic-nrc-amorphous'})
MERGE (x)-[r:HAS_CHEMICAL_FORM]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-synthetic-supplier-x-has-amorphous-form'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-synthetic-supplier-x-has-amorphous-form'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// Label component (W04 type, consumer-side shape; same uid as study-vs-product-mismatch.cypher). 300 mg is the salt
// as listed (LISTED_INGREDIENT_AS_LISTED, 21 CFR 101.36(b)(3)(ii)); massBasis SALT_FORM.

MERGE (n:IngredientComponent:VersionedState {uid: 'hu:component:tru-niagen-300mg-niagen'})
ON CREATE SET n += {role: 'DIETARY_INGREDIENT', labelOrder: 1, quantity: 300.0, unitCode: 'mg', quantityBasis: 'PER_SERVING', massBasis: 'SALT_FORM', amountReferent: 'LISTED_INGREDIENT_AS_LISTED', declaredAs: 'NIAGEN (nicotinamide riboside chloride)', stateType: 'IngredientComponent', payloadHash: 'sha256:15df6a526bc46d338e5ab8ff7979b9be603742991e10b8fd0907610e231f65b1', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'}),
      (o:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (l0:SourceLocator {uid: 'hu:locator:truniagen-300mg-supplement-facts'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-truniagen-300-component-uses-niagen'})
ON CREATE SET a += {predicate: 'USES_MATERIAL', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:5f38613ca17b3885f72e6edaeec00b26a898dd3ad893171a524c51ae33e9a5f4', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'}), (y:IngredientMaterial {uid: 'hu:material:chromadex-niagen'})
MERGE (x)-[r:USES_MATERIAL]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-truniagen-300-component-uses-niagen'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-truniagen-300-component-uses-niagen'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w02-quantity-calculator'})
ON CREATE SET n += {name: 'BellLabs quantity calculator (W02 fixture)', agentKind: 'COMPUTATIONAL_MODEL', version: 'w02-active-moiety-mass-v1', entityType: 'Agent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// CALCULATED active-moiety amount (KCR-L3-001 pattern; round 0005 E): 300 mg x 255.25 / 290.70 = 263.4 mg NR cation per
// serving. It is an Assertion with basisKind CALCULATED, a derivationRule and DERIVED_FROM_ASSERTION inputs; it has no
// locator of its own and never attaches to a LabelDeclaration or QuantityDeclaration (V-330). Under the frozen kernel
// (INV-003 object XOR literal) it is literal-only; the moiety it refers to is fixed by its HAS_ACTIVE_MOIETY input.
// The object-plus-quantity form is requested in W02-SR-01 (failing case in fx-91).

MATCH (s:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'}),
      (ag {uid: 'hu:agent:belllabs-w02-quantity-calculator'}),
      (in0:Assertion {uid: 'hu:assertion:w02-truniagen-300-component-uses-niagen'}),
      (in1:Assertion {uid: 'hu:assertion:w02-niagen-realizes-nrc'}),
      (in2:Assertion {uid: 'hu:assertion:w02-nrc-has-active-moiety-nr'}),
      (in3:Assertion {uid: 'hu:assertion:w02-nrc-molecular-weight-pubchem'}),
      (in4:Assertion {uid: 'hu:assertion:w02-nr-molecular-weight-pubchem'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-calc-truniagen-300-nr-cation-mass'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4c0b6cb1444cc0108dd4ae90005f303942fd87f8b585fc0d8571eecddf129d4b', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 263.4, unitCode: 'mg', quantityBasis: 'PER_SERVING', basisKind: 'CALCULATED', derivationRule: 'w02-active-moiety-mass-v1: m(moiety) = m(declared, SALT_FORM) x MW(moiety) / MW(salt) x moietyCount(1); result massBasis ACTIVE_MOIETY', assertionBasis: 'UNSTATED', extractionMethod: 'CALCULATION'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in0)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in1)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in2)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in3)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in4);
