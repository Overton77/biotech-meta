// W02 Substances and materials fixture (fx-06-nrpt-not-a-substance) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).

// Case (CL-001, D-002): live Compound mixes substances with combinations. A legacy Compound named 'NRPT' denotes the
// NR + pterostilbene combination administered in NCT02678611 ('NRPT ... commercially known as Basis', PMID 29184669; GSRS
// search for 'NRPT' returns 0 records, M-20). Migration writes NO ChemicalSubstance for it; a ResolutionHypothesis proposes
// the study interventions as what the name denotes. A second legacy Compound ('Nicotinamide Riboside', casNumber
// 23111-00-4) shows identifier-first resolution: the CAS number is the chloride's, so it resolves to the salt substance
// by Identifier, not to NR by name (identity collision).

MERGE (c:Compound {id: 'legacy-compound-nrpt'})
ON CREATE SET c.name = 'NRPT', c.compoundClass = 'NAD+ precursor combination', c.createdAt = datetime('2026-01-15T00:00:00Z');

MERGE (c:Compound {id: 'legacy-compound-nr-ambiguous'})
ON CREATE SET c.name = 'Nicotinamide Riboside', c.casNumber = '23111-00-4', c.createdAt = datetime('2026-01-15T00:00:00Z');

MERGE (n:StudyIntervention:VersionedState {uid: 'hu:study-intervention:nct02678611-nrpt-1x'})
ON CREATE SET n += {name: 'NRPT 1X: 2 NRPT capsules + 2 placebo capsules daily', stateType: 'StudyIntervention', payloadHash: 'sha256:3c9875c7199ee724916f171a4507707a9b7750236309d9f8426cede9b27bef9d', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:StudyIntervention:VersionedState {uid: 'hu:study-intervention:nct02678611-nrpt-2x'})
ON CREATE SET n += {name: 'NRPT 2X: 4 NRPT capsules daily', stateType: 'StudyIntervention', payloadHash: 'sha256:927fc622c7471543ceec1836a8799f649ed631059a10723730c9119fe278fb6a', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:pterostilbene'})
ON CREATE SET n += {name: 'Pterostilbene', preferredName: 'Pterostilbene', maturity: 'CANDIDATE', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide-riboside-chloride'})
ON CREATE SET n += {name: 'Nicotinamide riboside chloride', preferredName: 'Nicotinamide riboside chloride', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (c:Compound {id: 'legacy-compound-nrpt'}),
      (i1:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-1x'}),
      (i2:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-2x'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:w02-legacy-compound-nrpt-denotes-combination'})
ON CREATE SET h += {assessmentType: 'ResolutionHypothesis', resolutionType: 'LEGACY_TYPE_DISPOSITION', resolutionStatus: 'PROPOSED',
  rationale: 'Legacy Compound NRPT names a two-active combination (NR + pterostilbene) administered as capsules; it is not one defined chemical structure. Disposition: no ChemicalSubstance; the name resolves to study interventions (and, through W04, to a product name).',
  methodVersion: 'w02-legacy-compound-disposition-v1', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'}
MERGE (h)-[:PROPOSES_MATCH]->(i1)
MERGE (h)-[:PROPOSES_MATCH]->(i2)
MERGE (h)-[:PROPOSES_MATCH]->(c);

MATCH (c:Compound {id: 'legacy-compound-nr-ambiguous'}),
      (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (h:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:w02-legacy-compound-nr-ambiguous-by-cas'})
ON CREATE SET h += {assessmentType: 'ResolutionHypothesis', resolutionType: 'LEGACY_TYPE_DISPOSITION', resolutionStatus: 'PROPOSED',
  rationale: 'Name says nicotinamide riboside; casNumber 23111-00-4 is the chloride salt (GSRS 8XM2XT8VWI). Identifier wins over name; candidate is the salt substance; a reviewer must confirm before relabel and redirect.',
  methodVersion: 'w02-legacy-compound-disposition-v1', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'}
MERGE (h)-[:PROPOSES_MATCH]->(c)
MERGE (h)-[:PROPOSES_MATCH]->(s);
