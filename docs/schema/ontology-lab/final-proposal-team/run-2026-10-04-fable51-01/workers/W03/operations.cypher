// W03 operations (recommendation for Fable's operations file). Community-runnable statements only; Enterprise-only
// existence/type constraints are listed in 07-operations.md and are not here. Idempotent (IF NOT EXISTS).
// status: run (embedded Neo4j 5.26.31 Community, 2026-10-04) including violating cases in w03-ops-test (scratch).
CREATE CONSTRAINT species_ncbi_taxonomy_id IF NOT EXISTS FOR (s:Species) REQUIRE s.ncbiTaxonomyId IS UNIQUE;
CREATE CONSTRAINT pathway_external_id IF NOT EXISTS FOR (p:Pathway) REQUIRE (p.sourceDatabase, p.externalId) IS UNIQUE;
CREATE CONSTRAINT condition_mondo_id IF NOT EXISTS FOR (c:Condition) REQUIRE c.mondoId IS UNIQUE;
CREATE CONSTRAINT molecular_entity_hgnc_id IF NOT EXISTS FOR (m:MolecularEntity) REQUIRE m.hgncId IS UNIQUE;
CREATE CONSTRAINT anatomical_context_uberon_id IF NOT EXISTS FOR (a:AnatomicalContext) REQUIRE a.uberonId IS UNIQUE;
CREATE INDEX mechanism_context_setting IF NOT EXISTS FOR (c:MechanismEvidenceContext) ON (c.setting);
CREATE INDEX assertion_mechanism_gate IF NOT EXISTS FOR (a:Assertion) ON (a.predicateClass, a.basisKind, a.status);
CREATE INDEX affects_mechanism_rule IF NOT EXISTS FOR ()-[r:AFFECTS_MECHANISM]-() ON (r.derivationRule);
CREATE INDEX modulates_rule IF NOT EXISTS FOR ()-[r:MODULATES]-() ON (r.derivationRule);
CREATE INDEX applies_to_species_rule IF NOT EXISTS FOR ()-[r:APPLIES_TO_SPECIES]-() ON (r.derivationRule);
CREATE INDEX influences_outcome_rule IF NOT EXISTS FOR ()-[r:INFLUENCES_OUTCOME]-() ON (r.derivationRule);
CREATE INDEX acts_in_rule IF NOT EXISTS FOR ()-[r:ACTS_IN]-() ON (r.derivationRule);
