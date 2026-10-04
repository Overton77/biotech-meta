// =====================================================================================================================
// W03 negative fixture: deliberate collapses. Load AFTER w03-positive.cypher and w03-projection-job.cypher on a
// disposable database, then run w03-validation.cypher and neo4j/validation.cypher. Each block names the validator that
// must return the row. Every statement binds its own nodes by uid. Do not run against a shared database.
// status: run (embedded Neo4j 5.26.31 Community, 2026-10-04); expected rows in 06-fixtures-and-queries.md.
// =====================================================================================================================

// N1 (mandatory case): a derived edge missing its assertion citation.
// Expected: V-112 NO_CITATION; V-233 row (a IS NULL); V-233r NO_CITATION.
MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (m:Mechanism {uid: 'hu:mechanism:mitochondrial-oxidative-function'})
CREATE (x)-[r:AFFECTS_MECHANISM]->(m)
SET r.effectSummary = 'NR improves mitochondria', r.derivedAt = datetime('2026-10-04T04:00:00Z'), r.negativeCase = 'N1';

// N2: a mechanism projection from a HYPOTHESIS assertion (FI HYPOTHESIZED_STEP -> MEASURED_STEP).
// Expected: V-233 row (basisKind HYPOTHESIS); V-233r NON_MEASURED_INPUT, INPUT_WITHOUT_SINGLE_CONTEXT; V-W03-02 no change.
MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (m:Mechanism {uid: 'hu:mechanism:nad-plus-biosynthetic-flux'})
CREATE (x)-[r:AFFECTS_MECHANISM]->(m)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = ['hu:assertion:basis-paper-nr-provides-nad-synthesis-hypothesis'],
    r.projectedPredicate = 'INDUCES_PROCESS', r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime('2026-10-04T04:00:00Z'), r.negativeCase = 'N2';

// N3: mouse-positive/human-null transferred: APPLIES_TO_SPECIES Mechanism -> Homo sapiens citing the human NULL
// measurement (FI MEASURED_IN_SPECIES -> APPLIES_IN_OTHER_SPECIES).
// Expected: V-233r NON_POSITIVE_INPUT; V-234r row (no POSITIVE cited context in Homo sapiens). Verbatim V-234 does NOT
// catch it when projectionOfAssertionUid is absent (it reports every rule-mode edge instead; see W03-SR-01).
MATCH (m:Mechanism {uid: 'hu:mechanism:mitochondrial-oxidative-function'}), (sp:Species {uid: 'hu:species:homo-sapiens'})
CREATE (m)-[r:APPLIES_TO_SPECIES]->(sp)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = ['hu:assertion:elhassan-nr-mito-function-no-change-muscle'],
    r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime('2026-10-04T04:00:00Z'), r.negativeCase = 'N3';

// N4: proxy marker used as flux (FI PROXY_MARKER_CHANGED -> PROCESS_FLUX_CHANGED): AFFECTS_MECHANISM to NAD+ flux
// citing the NAAD-in-heart level change, licensed only by the curated NAAD -REFLECTS_MECHANISM-> flux readout link.
// Expected: V-W03-03 row; V-W03-01 row (cited assertion object is not the edge target).
MATCH (x:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}), (m:Mechanism {uid: 'hu:mechanism:nad-plus-biosynthetic-flux'})
CREATE (x)-[r:AFFECTS_MECHANISM]->(m)
SET r.derivationRule = 'mx-proj/v1', r.derivedFromAssertionUids = ['hu:assertion:trammell-nr-increases-naad-heart'],
    r.projectedPredicate = 'INCREASES_LEVEL_OF', r.projectedPolarity = 'POSITIVE', r.derivedAt = datetime('2026-10-04T04:00:00Z'), r.negativeCase = 'N4';

// N5: compartment collapse (FI CHANGES_LEVEL_IN_COMPARTMENT -> CHANGES_LEVEL_IN_OTHER_COMPARTMENT): the whole-blood
// NAD+ measurand attached to a muscle context.
// Expected: V-239 row.
MERGE (a:Assertion {uid: 'hu:assertion:negative-n5-blood-measurand-in-muscle-context'})
SET a.id = 'negative-n5-blood-measurand-in-muscle-context', a.predicate = 'INCREASES_LEVEL_OF', a.predicateClass = 'MECHANISM',
    a.basisKind = 'DIRECT_MEASUREMENT', a.polarity = 'POSITIVE', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T04:00:00Z'),
    a.negativeCase = 'N5';
MATCH (a:Assertion {uid: 'hu:assertion:negative-n5-blood-measurand-in-muscle-context'}), (s:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (b:Biomarker {uid: 'hu:biomarker:nad-plus-whole-blood'}), (c:MechanismEvidenceContext {uid: 'hu:mech-context:elhassan-2019-nr-1g-21d-muscle'})
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(b)
MERGE (a)-[:OBSERVED_IN_CONTEXT]->(c);

// N6: human-equivalent dose asserted without a method (INV-213).
// Expected: V-236 row.
MERGE (c:MechanismEvidenceContext:Occurrence {uid: 'hu:mech-context:negative-n6-hed-without-method'})
SET c.id = 'negative-n6-hed-without-method', c.occurrenceType = 'MechanismEvidenceContext', c.setting = 'IN_VIVO_MAMMAL',
    c.exposureAmount = 185.0, c.exposureUnit = 'mg/kg', c.exposureBasis = 'SINGLE_DOSE', c.hedValue = 15.0,
    c.createdAt = datetime('2026-10-04T04:00:00Z'), c.negativeCase = 'N6';

// N7: unknown exposure recorded as zero (INV-007).
// Expected: V-232 row.
MERGE (c:MechanismEvidenceContext:Occurrence {uid: 'hu:mech-context:negative-n7-zero-for-unknown'})
SET c.id = 'negative-n7-zero-for-unknown', c.occurrenceType = 'MechanismEvidenceContext', c.setting = 'IN_VIVO_MAMMAL',
    c.exposureAmount = 0.0, c.exposureUnit = 'mg/kg', c.exposureBasis = 'SINGLE_DOSE',
    c.createdAt = datetime('2026-10-04T04:00:00Z'), c.negativeCase = 'N7';

// N8: identity collision (CL-002): NAD+ created a second time as a MolecularEntity "metabolite".
// Expected: V-W03-05 row (entityKind METABOLITE and name equal to ChemicalSubstance 'NAD+ (Nadide)').
MERGE (me:MolecularEntity:Entity {uid: 'hu:molecular-entity:negative-n8-nad-plus'})
SET me.id = 'negative-n8-nad-plus', me.name = 'NAD+ (Nadide)', me.entityKind = 'METABOLITE', me.entityType = 'MolecularEntity',
    me.createdAt = datetime('2026-10-04T04:00:00Z'), me.negativeCase = 'N8';

// N9: identity collision (one organ, two identities): liver created again as a plain AnatomicalContext with the same
// UBERON id as the Organ node (uberonId set on both for the test).
// Expected: V-W03-06 rows (two nodes share an uberonId).
MATCH (o:Organ {uid: 'hu:anatomical-context:liver'})
SET o.uberonId = 'UBERON:0002107';
MERGE (n:AnatomicalContext:Entity {uid: 'hu:anatomical-context:negative-n9-liver-duplicate'})
SET n.id = 'negative-n9-liver-duplicate', n.name = 'liver', n.contextKind = 'TISSUE', n.uberonId = 'UBERON:0002107', n.entityType = 'AnatomicalContext',
    n.createdAt = datetime('2026-10-04T04:00:00Z'), n.negativeCase = 'N9';

// N10: classification code materialized as identity on the condition node.
// Expected: V-W03-08 row.
MATCH (c:Condition {uid: 'hu:condition:insulin-resistance'})
SET c.icd10Code = 'E88.81';

// N11: versioned authority id used as identity.
// Expected: V-W03-09 row.
MERGE (p:Pathway:Entity {uid: 'hu:pathway:negative-n11-versioned-id'})
SET p.id = 'negative-n11-versioned-id', p.name = 'Nicotinate metabolism (versioned id)', p.externalId = 'R-HSA-196807.8', p.sourceDatabase = 'REACTOME',
    p.entityType = 'Pathway', p.createdAt = datetime('2026-10-04T04:00:00Z'), p.negativeCase = 'N11';

// N12: the "old" encoding of a mechanism projection, citing the measured assertion through projectionOfAssertionUid.
// Expected: V-112 CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE (INDUCES_PROCESS vs AFFECTS_MECHANISM), while V-233 and V-233r
// pass for this edge. Together with the clean rule-mode edges failing verbatim V-233/V-234, this is the failing case
// for seam W03-SR-01: no single citation encoding satisfies V-112 and verbatim V-233/V-234.
MATCH (x:IngredientMaterial {uid: 'hu:material:liu-2018-labeled-nr'}), (m:Mechanism {uid: 'hu:mechanism:nad-plus-biosynthetic-flux'})
CREATE (x)-[r:AFFECTS_MECHANISM]->(m)
SET r.projectionOfAssertionUid = 'hu:assertion:liu-oral-nr-nad-synthesis-liver', r.derivedAt = datetime('2026-10-04T04:00:00Z'), r.negativeCase = 'N12';

// N13: ingredient mechanism transferred to a formulation without human exposure evidence (FI
// INGREDIENT_MECHANISM_EFFECT -> FORMULATION_DELIVERS_EXPOSURE). W10 types appear with minimum fields.
// Expected: V-237 row (EXPOSURE verdict MATCH and no BASED_ON_EVIDENCE StudyResult).
MERGE (ea:EvidenceApplicability:EvidenceAssessment {uid: 'hu:applicability:negative-n13-liver-flux-to-product'})
SET ea.id = 'negative-n13-liver-flux-to-product', ea.assessmentType = 'EvidenceApplicability', ea.methodVersion = 'applicability-v0.1',
    ea.status = 'PROPOSED', ea.recordedAt = datetime('2026-10-04T04:00:00Z'), ea.createdAt = datetime('2026-10-04T04:00:00Z'), ea.negativeCase = 'N13';
MERGE (d:ApplicabilityDimension:EvidenceAssessment {uid: 'hu:applicability:negative-n13-liver-flux-to-product-exposure'})
SET d.id = 'negative-n13-liver-flux-to-product-exposure', d.assessmentType = 'ApplicabilityDimension', d.methodVersion = 'applicability-v0.1',
    d.status = 'PROPOSED', d.dimension = 'EXPOSURE', d.dimensionClass = 'CONTINUOUS', d.verdict = 'MATCH',
    d.recordedAt = datetime('2026-10-04T04:00:00Z'), d.createdAt = datetime('2026-10-04T04:00:00Z'), d.negativeCase = 'N13';
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:negative-n13-liver-flux-to-product'}),
      (d:ApplicabilityDimension {uid: 'hu:applicability:negative-n13-liver-flux-to-product-exposure'}),
      (a:Assertion {uid: 'hu:assertion:liu-oral-nr-nad-synthesis-liver'})
MERGE (ea)-[:HAS_EVIDENCE_TARGET]->(a)
MERGE (ea)-[:HAS_DIMENSION]->(d);

// N14: inference with no measured premise.
// Expected: V-W03-04 row.
MERGE (a:Assertion {uid: 'hu:assertion:negative-n14-inferred-without-premise'})
SET a.id = 'negative-n14-inferred-without-premise', a.predicate = 'INCREASES_ACTIVITY_OF', a.predicateClass = 'MECHANISM',
    a.basisKind = 'INFERRED_FROM_MEASUREMENT', a.polarity = 'POSITIVE', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T04:00:00Z'),
    a.negativeCase = 'N14';

// N15: curation staleness (temporal case, informational): a curated link recorded from a SYNTHETIC earlier capture of
// the Reactome record at revision 7 (the record's DOI 10.3180/R-HSA-196807.7 shows a revision 7 existed; its capture
// date is not known, so the snapshot is synthetic).
// Expected: V-W03-10 informational row; no failure.
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:reactome-r-hsa-196807-synthetic-rev7'})
SET s.id = 'reactome-r-hsa-196807-synthetic-rev7', s.artifactType = 'SourceSnapshot', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
    s.contentHash = 'sha256:0000000000000000000000000000000000000000000000000000000000000007', s.captureCompleteness = 'UNKNOWN',
    s.retrievedAt = datetime('2021-09-16T00:00:00Z'), s.observedAt = datetime('2021-09-16T00:00:00Z'), s.fixtureProvenance = 'SYNTHETIC',
    s.createdAt = datetime('2026-10-04T04:00:00Z');
MATCH (me:MolecularEntity {uid: 'hu:molecular-entity:sirtuin-deacetylase-family'}), (p:Pathway {uid: 'hu:pathway:reactome-r-hsa-196807'})
MERGE (me)-[r:PARTICIPATES_IN]->(p)
SET r.referenceSnapshotUid = 'hu:snapshot:reactome-r-hsa-196807-synthetic-rev7', r.referenceRecordId = 'R-HSA-196807', r.referenceRevision = '7',
    r.notes = 'SYNTHETIC: illustrates a link curated from an older revision; not a claim that sirtuins are events of this pathway';
