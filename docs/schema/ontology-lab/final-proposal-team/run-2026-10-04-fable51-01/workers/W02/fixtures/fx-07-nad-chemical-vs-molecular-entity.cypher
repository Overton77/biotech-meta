// W02 Substances and materials fixture (fx-07-nad-chemical-vs-molecular-entity) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case (CL-002): NAD+ is one chemical entity whatever its role (ChEBI CHEBI:15846 'NAD+', roles cofactor, coenzyme,
// mouse metabolite, E. coli metabolite; formula C21H28N7O14P2, charge +1, InChIKey BAWFJGJZGIEFAR-NNYOXOHSSA-O, M-18).
// Roles are not types: it is a ChemicalSubstance (W02) whether measured as a biomarker analyte (W07), supplemented as an
// ingredient, or named as the object of a mechanism assertion (W03). CD38, the enzyme, is a gene product and stays a
// MolecularEntity (W03). UniProt was unavailable (503) in this run; the accession P28907 is carried as unverified.

MERGE (n:Source:Entity {uid: 'hu:source:chebi-15846'})
ON CREATE SET n += {canonicalUri: 'https://www.ebi.ac.uk/chebi/CHEBI:15846', title: 'ChEBI CHEBI:15846 NAD(+)', sourceKind: 'TERMINOLOGY_RECORD', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:chebi-15846-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://www.ebi.ac.uk/chebi/CHEBI:15846', retrievedAt: datetime('2026-10-04T01:25:00Z'), observedAt: datetime('2026-10-04T01:25:00Z'), contentHash: 'sha256:5683182d8ce003b98d7b3779b89f12d44ed05868ba4453e7e34b42a19a322849', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:chebi-15846'}), (sn:SourceSnapshot {uid: 'hu:snapshot:chebi-15846-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:chebi-15846-identity'})
ON CREATE SET n += {uri: 'https://www.ebi.ac.uk/chebi/CHEBI:15846', selectorKind: 'SECTION', section: 'ChEBI ID, Formula, Net Charge, InChIKey, Biological Roles', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:chebi-15846-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:chebi-15846-identity'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nad-plus'})
ON CREATE SET n += {name: 'NAD+', preferredName: 'NAD+', molecularFormula: 'C21H28N7O14P2', inchikey: 'BAWFJGJZGIEFAR-NNYOXOHSSA-O', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Identifier:Entity {uid: 'hu:identifier:chebi-15846'})
ON CREATE SET n += {scheme: 'CHEBI', value: 'CHEBI:15846', issuer: 'EMBL-EBI ChEBI', entityType: 'Identifier', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:ChemicalSubstance {uid: 'hu:substance:nad-plus'}),
      (o:Identifier {uid: 'hu:identifier:chebi-15846'}),
      (l0:SourceLocator {uid: 'hu:locator:chebi-15846-identity'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-chebi-15846-identifies-nad-plus'})
ON CREATE SET a += {predicate: 'HAS_IDENTIFIER', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:3b3cef55253cdbcb9c3f2feb42e5d9d07d5b0366e4f7f7b98e4fe0fe6addbdc8', polarity: 'POSITIVE', predicateClass: 'IDENTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:ChemicalSubstance {uid: 'hu:substance:nad-plus'}), (y:Identifier {uid: 'hu:identifier:chebi-15846'})
MERGE (x)-[r:HAS_IDENTIFIER]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-chebi-15846-identifies-nad-plus'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-chebi-15846-identifies-nad-plus'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.isPrimary = coalesce(r.isPrimary, true);

MERGE (n:MolecularEntity:Entity {uid: 'hu:molecular-entity:cd38-human'})
ON CREATE SET n += {name: 'CD38 (human)', entityKind: 'PROTEIN', geneSymbol: 'CD38', uniprotId: 'P28907', maturity: 'CANDIDATE', entityType: 'MolecularEntity', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// Intentionally absent: a MolecularEntity 'NAD+' (V-W02-06 detects one carrying a chemical key).
