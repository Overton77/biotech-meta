// W02 Substances and materials fixture (fx-90-negative-violations) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).
// NEGATIVE FIXTURE: load alone or after the positive fixtures; every block below is EXPECTED to produce the
// violation row named in its comment. Never load into a production database.

MERGE (n:Source:Entity {uid: 'hu:source:synthetic-w02-negatives'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:negatives', title: 'SYNTHETIC negative cases (fixture only)', sourceKind: 'MARKETING_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w02-negatives-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:negatives', retrievedAt: datetime('2026-10-04T01:30:00Z'), observedAt: datetime('2026-10-04T01:30:00Z'), contentHash: 'sha256:a807d4a4f7db4e4c389c0582ea5f2c98936731aaffc3ecb51af26d1b4a23016b', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:synthetic-w02-negatives'}), (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-negatives-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w02-negatives'})
ON CREATE SET n += {uri: 'urn:synthetic:w02:negatives', selectorKind: 'WHOLE_SNAPSHOT', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-negatives-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

// N1 -> V-W02-01 and QS-4a: QUANTITATIVELY_CONTAINS lycopene projected from a PROVIDES_CONSTITUENT assertion (forbidden
// implication [PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]).

MERGE (n:BotanicalPreparation:IngredientMaterial:Entity {uid: 'hu:material:neg-tomato-extract'})
ON CREATE SET n += {name: 'NEG tomato extract', materialKind: 'BOTANICAL_PREPARATION', maturity: 'CANDIDATE', entityType: 'BotanicalPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:lycopene'})
ON CREATE SET n += {name: 'Lycopene', preferredName: 'Lycopene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:neg-tomato-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:lycopene'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-tomato-provides-lycopene'})
ON CREATE SET a += {predicate: 'PROVIDES_CONSTITUENT', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:898a667fcf250c4dfc60dae89d03708968f9f1202e38bc353f56ce572b5fa0c6', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:neg-tomato-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:lycopene'})
MERGE (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-tomato-qc-lycopene-from-provides'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-tomato-provides-lycopene'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.quantity = coalesce(r.quantity, 5.0), r.unitCode = coalesce(r.unitCode, '%'), r.basis = coalesce(r.basis, 'MASS_FRACTION_W_W'), r.comparator = coalesce(r.comparator, 'EQ'), r.contentStatementKind = coalesce(r.contentStatementKind, 'TYPICAL_COMPOSITION_REPORTED');

// N2 -> V-006 (baseline) and V-W02-10: QUANTITATIVELY_CONTAINS without basis.

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:neg-marker'})
ON CREATE SET n += {name: 'NEG marker', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:neg-tomato-extract'}),
      (o:ChemicalSubstance {uid: 'hu:substance:neg-marker'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-qc-no-basis'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:f8e169aa4c7f8a10da8d2c6d3ae29292b6985a80e058ed5443c87d9ba9d1426f', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:neg-tomato-extract'}), (y:ChemicalSubstance {uid: 'hu:substance:neg-marker'})
MERGE (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-qc-no-basis'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-qc-no-basis'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.quantity = coalesce(r.quantity, 2.0), r.unitCode = coalesce(r.unitCode, '%'), r.comparator = coalesce(r.comparator, 'EQ'), r.contentStatementKind = coalesce(r.contentStatementKind, 'STANDARDIZATION_CLAIM');

// N3 -> V-W02-03: a non-CANDIDATE ChemicalSubstance named NRPT with no structure anchor (combination as substance).

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:neg-nrpt'})
ON CREATE SET n += {name: 'NRPT', preferredName: 'NRPT', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// N4 -> V-W02-04: a ChemicalSubstance with two distinct active moieties (combination masquerading as a salt).

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:neg-nr-pt-combo'})
ON CREATE SET n += {name: 'NEG NR + PT combination', molecularFormula: 'UNKNOWN', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide-riboside'})
ON CREATE SET n += {name: 'Nicotinamide riboside', preferredName: 'Nicotinamide riboside', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:pterostilbene'})
ON CREATE SET n += {name: 'Pterostilbene', preferredName: 'Pterostilbene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:neg-nr-pt-combo'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-combo-moiety-nr'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4a051eaff3e14209c020e522b008ca1e2d93d67af10f8e617944d39ce28f8c86', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:neg-nr-pt-combo'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-combo-moiety-nr'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-combo-moiety-nr'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:ChemicalSubstance {uid: 'hu:substance:neg-nr-pt-combo'}),
      (o:ChemicalSubstance {uid: 'hu:substance:pterostilbene'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-combo-moiety-pt'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:fd4cc7432a61a608723132162cecbc37980189c3a7a30cfcf9395bf556e39ea3', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:neg-nr-pt-combo'}), (y:ChemicalSubstance {uid: 'hu:substance:pterostilbene'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-combo-moiety-pt'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-combo-moiety-pt'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// N5 -> V-222 (baseline): ChemicalForm with two substances.

MERGE (n:ChemicalForm:Entity {uid: 'hu:form:neg-two-substances'})
ON CREATE SET n += {name: 'NEG form of two substances', formKind: 'CRYSTAL_FORM', maturity: 'CANDIDATE', entityType: 'ChemicalForm', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalForm {uid: 'hu:form:neg-two-substances'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-form-of-nr'})
ON CREATE SET a += {predicate: 'FORM_OF_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:98c1bd1825c604fec905c74bfdb8ece310f8ff3df4f569d4be062b10111f0086', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalForm {uid: 'hu:form:neg-two-substances'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:FORM_OF_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-form-of-nr'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-form-of-nr'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:ChemicalForm {uid: 'hu:form:neg-two-substances'}),
      (o:ChemicalSubstance {uid: 'hu:substance:pterostilbene'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-form-of-pt'})
ON CREATE SET a += {predicate: 'FORM_OF_SUBSTANCE', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:552d97489a8a7845a3c623063d3bc6d54cc2ad08678a2197265368669f2c97dd', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalForm {uid: 'hu:form:neg-two-substances'}), (y:ChemicalSubstance {uid: 'hu:substance:pterostilbene'})
MERGE (x)-[r:FORM_OF_SUBSTANCE]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-form-of-pt'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-form-of-pt'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// N6 -> V-222b (baseline): one node that is both ChemicalSubstance and IngredientMaterial; N7 -> V-222b: a material with dosageForm.

MERGE (n:ChemicalSubstance:IngredientMaterial:Entity {uid: 'hu:material:neg-collapsed-substance-material'})
ON CREATE SET n += {entityType: 'IngredientMaterial', name: 'NEG collapsed', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:neg-material-with-dosage-form'})
ON CREATE SET n += {name: 'NEG Tru Niagen 300 mg capsule as material', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', dosageForm: 'CAPSULE', maturity: 'CANDIDATE', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// N8 -> V-W02-06: MolecularEntity carrying a chemical key (NAD+ minted twice).

MERGE (n:MolecularEntity:Entity {uid: 'hu:molecular-entity:neg-nad-plus'})
ON CREATE SET n += {name: 'NAD+', entityKind: 'METABOLITE', inchikey: 'BAWFJGJZGIEFAR-NNYOXOHSSA-O', maturity: 'CANDIDATE', entityType: 'MolecularEntity', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// N9 -> V-W02-02: specialization label disagrees with materialKind.

MERGE (n:MicrobialPreparation:IngredientMaterial:Entity {uid: 'hu:material:neg-kind-mismatch'})
ON CREATE SET n += {name: 'NEG microbial prep labelled botanical', materialKind: 'BOTANICAL_PREPARATION', maturity: 'CANDIDATE', entityType: 'MicrobialPreparation', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// N10 -> V-W02-05: NIAGEN re-minted for a new specification version (duplicate branded identity).

MERGE (n:BrandedIngredientMaterial:IngredientMaterial:Entity {uid: 'hu:material:chromadex-niagen'})
ON CREATE SET n += {name: 'NIAGEN', brandName: 'NIAGEN', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'BrandedIngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BrandedIngredientMaterial:IngredientMaterial:Entity {uid: 'hu:material:neg-niagen-2019-spec'})
ON CREATE SET n += {name: 'NIAGEN (2019 spec)', brandName: 'Niagen', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'PROVISIONAL', entityType: 'BrandedIngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// N11 -> V-W02-07: an active-moiety chain (moiety of a moiety).

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:neg-chain-a'})
ON CREATE SET n += {name: 'NEG chain A', molecularFormula: 'X', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:neg-chain-b'})
ON CREATE SET n += {name: 'NEG chain B', molecularFormula: 'Y', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:neg-chain-a'}),
      (o:ChemicalSubstance {uid: 'hu:substance:neg-chain-b'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-chain-a-b'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4d9f112221fe4a9cca7e362186cf4e62db0eaa883275c43b12ccf9d02fd6e741', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:neg-chain-a'}), (y:ChemicalSubstance {uid: 'hu:substance:neg-chain-b'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-chain-a-b'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-chain-a-b'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:ChemicalSubstance {uid: 'hu:substance:neg-chain-b'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-chain-b-nr'})
ON CREATE SET a += {predicate: 'HAS_ACTIVE_MOIETY', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:a342c6e9c16253961482463261f3077e1c0e79b9c6968243a67df540b725ca23', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:neg-chain-b'}), (y:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'})
MERGE (x)-[r:HAS_ACTIVE_MOIETY]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-chain-b-nr'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-chain-b-nr'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// N12 -> V-W02-08: a CALCULATED quantity assertion without derivationRule or inputs.

MATCH (s:ChemicalSubstance {uid: 'hu:substance:neg-chain-a'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-calculated-without-lineage'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:c509df392a6f07f1f8cdc388ecd379530417009b0eafccc7586b0e988bbd1a2f', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 1.0, unitCode: 'mg', basisKind: 'CALCULATED'}
MERGE (a)-[:HAS_SUBJECT]->(s);

// N13 -> V-W02-09: two current projected STRAIN_OF edges from one strain.

MERGE (n:MicrobialStrain:Entity {uid: 'hu:microbial-strain:neg-two-species'})
ON CREATE SET n += {name: 'NEG strain', strainDesignation: 'X1', maturity: 'CANDIDATE', entityType: 'MicrobialStrain', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:MicrobialTaxon:Entity {uid: 'hu:microbial-taxon:neg-a'})
ON CREATE SET n += {name: 'NEG taxon A', maturity: 'CANDIDATE', entityType: 'MicrobialTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:MicrobialTaxon:Entity {uid: 'hu:microbial-taxon:neg-b'})
ON CREATE SET n += {name: 'NEG taxon B', maturity: 'CANDIDATE', entityType: 'MicrobialTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:neg-two-species'}),
      (o:MicrobialTaxon {uid: 'hu:microbial-taxon:neg-a'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-strain-of-a'})
ON CREATE SET a += {predicate: 'STRAIN_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:b73ee715d943ee9c319823c69579833110d7d0d88d9aaf786cf608846716ed4f', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:neg-two-species'}), (y:MicrobialTaxon {uid: 'hu:microbial-taxon:neg-a'})
MERGE (x)-[r:STRAIN_OF]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-strain-of-a'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-strain-of-a'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:MicrobialStrain {uid: 'hu:microbial-strain:neg-two-species'}),
      (o:MicrobialTaxon {uid: 'hu:microbial-taxon:neg-b'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-strain-of-b'})
ON CREATE SET a += {predicate: 'STRAIN_OF', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:d9ee12726ea54c088a248cc046e259ec3a8a37cc6d58eb3a497f3c53f60521f7', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:MicrobialStrain {uid: 'hu:microbial-strain:neg-two-species'}), (y:MicrobialTaxon {uid: 'hu:microbial-taxon:neg-b'})
MERGE (x)-[r:STRAIN_OF]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-strain-of-b'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-strain-of-b'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

// N14 -> V-W02-11: DERIVED_FROM_TAXON from a non-botanical material (domain violation).

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:neg-generic-material'})
ON CREATE SET n += {name: 'NEG generic material', materialKind: 'OTHER_MATERIAL', maturity: 'CANDIDATE', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:BotanicalTaxon:Entity {uid: 'hu:botanical-taxon:neg-taxon'})
ON CREATE SET n += {name: 'NEG taxon', maturity: 'CANDIDATE', entityType: 'BotanicalTaxon', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientMaterial {uid: 'hu:material:neg-generic-material'}),
      (o:BotanicalTaxon {uid: 'hu:botanical-taxon:neg-taxon'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-negatives'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-generic-from-taxon'})
ON CREATE SET a += {predicate: 'DERIVED_FROM_TAXON', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:cc94c8c45daacbf8c145bc40b5b8fdd7e136c6bb8df80163c6cc32297dba51ea', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientMaterial {uid: 'hu:material:neg-generic-material'}), (y:BotanicalTaxon {uid: 'hu:botanical-taxon:neg-taxon'})
MERGE (x)-[r:DERIVED_FROM_TAXON]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:neg-generic-from-taxon'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:neg-generic-from-taxon'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');
