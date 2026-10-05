// =====================================================================================================================
// W03 competency-question queries over w03-positive.cypher + w03-projection-job.cypher (no negative file loaded).
// status: run (embedded Neo4j 5.26.31 Community, 2026-10-04); expected rows in 06-fixtures-and-queries.md.
// =====================================================================================================================

// CQ-MX-01 (Essential): for one proposition (NR INDUCES_PROCESS NAD+ biosynthetic flux), which steps were measured,
// inferred, cited or hypothesized, by which source, with which polarity.
MATCH (a:Assertion)-[:HAS_SUBJECT]->(:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (a)-[:HAS_OBJECT]->(m:Mechanism {uid: 'hu:mechanism:nad-plus-biosynthetic-flux'})
WHERE a.predicate = 'INDUCES_PROCESS' AND a.recordedTo IS NULL
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c)-[:MEASURED_IN]->(site)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp)
OPTIONAL MATCH (a)-[:DERIVED_FROM_ASSERTION]->(premise)
RETURN a.basisKind AS basis, a.polarity AS polarity, sp.scientificName AS species, site.name AS compartment,
       collect(DISTINCT src.canonicalUri) AS sources, collect(DISTINCT premise.uid) AS premises
ORDER BY basis, polarity;

// CQ-MX-02 (Essential): for each measured step, species/model, compartment, setting, tested material and exposure
// (amount, unit, basis, route, duration), or the study arm when exposure lives on the arm; HED shown as derived.
MATCH (a:Assertion {basisKind: 'DIRECT_MEASUREMENT'})-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
WHERE a.recordedTo IS NULL
MATCH (a)-[:HAS_OBJECT]->(o)
OPTIONAL MATCH (c)-[:IN_SPECIES]->(sp:Species)
OPTIONAL MATCH (c)-[:MEASURED_IN]->(site:AnatomicalContext)
OPTIONAL MATCH (c)-[:EXPOSED_TO]->(mat)
OPTIONAL MATCH (c)-[:IN_STUDY_ARM]->(arm:StudyArm)
RETURN o.name AS stepObject, a.predicate AS predicate, a.polarity AS polarity, c.setting AS setting, sp.scientificName AS species,
       c.modelDescriptor AS model, site.name AS compartment, mat.name AS testedMaterial, arm.name AS studyArm,
       c.exposureAmount AS amount, c.exposureUnit AS unit, c.exposureBasis AS basis, c.route AS route,
       c.exposureDurationIso AS duration, c.exposureStatus AS exposureStatus, c.hedValue AS derivedHed, c.hedMethod AS hedMethod
ORDER BY stepObject, species;

// CQ-MX-03 (Foundational): has a step measured in one species or compartment been measured in humans, with what
// direction (including null)? Mouse-positive / human-null on mitochondrial oxidative function.
MATCH (a:Assertion)-[:HAS_OBJECT]->(m:Mechanism {uid: 'hu:mechanism:mitochondrial-oxidative-function'})
WHERE a.basisKind = 'DIRECT_MEASUREMENT' AND a.recordedTo IS NULL
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c)-[:IN_SPECIES]->(sp:Species)
OPTIONAL MATCH (c)-[:MEASURED_IN]->(site)
OPTIONAL MATCH (m)-[proj:APPLIES_TO_SPECIES]->(sp)
RETURN sp.scientificName AS species, a.polarity AS measuredDirection, site.name AS compartment,
       proj IS NOT NULL AS shortcutEdgeExists
ORDER BY species;

// CQ-MX-03 compartment variant (candidate CQ-MX-C04, needs W07 HAS_ANALYTE): where else has the same analyte been
// measured after NR, in which species and compartment? Shows blood vs liver vs heart vs muscle as distinct measurands.
MATCH (a:Assertion)-[:HAS_OBJECT]->(b:Biomarker)-[:HAS_ANALYTE]->(an:ChemicalSubstance),
      (b)-[:MEASURED_IN_MATRIX]->(mx:AnatomicalContext)
WHERE a.basisKind = 'DIRECT_MEASUREMENT' AND a.recordedTo IS NULL AND an.uid IN ['hu:substance:nadide', 'hu:substance:naad']
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c)-[:IN_SPECIES]->(sp)
RETURN an.name AS analyte, mx.name AS matrix, sp.scientificName AS species, a.polarity AS direction, b.uid AS measurand
ORDER BY analyte, species, matrix;

// CQ-MX-04 (Essential, input side): exposure under which each POSITIVE measured mechanism step was seen, with basis, so
// that W10's EXPOSURE dimension can compute a ratio only on matched bases (INV-203). Here every positive mechanism step is
// murine and per-kg or unextracted: no human exposure result exists for any material, so EXPOSURE stays UNKNOWN.
MATCH (a:Assertion)-[:HAS_OBJECT]->(m:Mechanism)
WHERE a.basisKind = 'DIRECT_MEASUREMENT' AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c)-[:IN_SPECIES]->(sp)
OPTIONAL MATCH (c)-[:EXPOSED_TO]->(mat)
RETURN m.name AS mechanism, sp.scientificName AS species, mat.uid AS testedMaterial, c.exposureAmount AS amount,
       c.exposureUnit AS unit, c.exposureBasis AS basis, c.exposureStatus AS exposureStatus,
       sp.ncbiTaxonomyId = '9606' AS humanExposureEvidence;

// CQ-MX-05 (Foundational): which mechanism shortcut edges rest on what; list each derived edge with its inputs' bases.
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME|ACTS_IN]->(y)
UNWIND coalesce(r.derivedFromAssertionUids, [r.projectionOfAssertionUid]) AS u
MATCH (a:Assertion {uid: u})
RETURN type(r) AS edge, x.uid AS fromUid, y.uid AS toUid, r.speciesUids AS species, collect(a.basisKind) AS inputBases,
       collect(a.polarity) AS inputPolarities
ORDER BY edge, fromUid, toUid;

// CQ-ST-03 (Essential, W03 referent side): the biological referents an endpoint classification would point at:
// measurand, its compartment, the analyte, and any curated readout-of mechanism. Classification itself is W10's.
MATCH (b:Biomarker)-[:MEASURED_IN_MATRIX]->(mx)
OPTIONAL MATCH (b)-[:HAS_ANALYTE]->(an)
OPTIONAL MATCH (b)-[:REFLECTS_MECHANISM]->(mech)
RETURN b.name AS measurand, mx.name AS matrix, mx.contextKind AS matrixKind, an.name AS analyte, mech.name AS curatedReadoutOf
ORDER BY measurand;

// CQ-MX-C01 (candidate): is the reference record for a step's molecular actor or pathway defined for the measured
// species, or inferred by orthology?
MATCH (p:Pathway)
OPTIONAL MATCH (sp:Species {ncbiTaxonomyId: p.speciesTaxonId})
RETURN p.externalId AS pathway, sp.scientificName AS definedFor, p.orthologyInferred AS orthologyInferred, p.pathwayRevision AS revision
ORDER BY pathway;

// CQ-MX-C02 (candidate): which revision of the pathway record was a curated link read from, and is it the current one?
MATCH (x)-[r:INVOLVES_PATHWAY|PARTICIPATES_IN]->(p:Pathway)
OPTIONAL MATCH (p)-[:HAS_IDENTIFIER]->(i:Identifier)
RETURN x.name AS curatedFrom, p.externalId AS pathway, r.referenceRevision AS linkRevision, r.referenceRelease AS release,
       p.pathwayRevision AS observedRevision, collect(i.scheme + ' ' + i.value) AS identifiers;

// CQ-MX-C03 (candidate): which ICD-10-CM code mapped a condition concept on a given date (2022-06-01 and 2026-10-04)?
UNWIND [datetime('2022-06-01T00:00:00Z'), datetime('2026-10-04T00:00:00Z')] AS asOf
MATCH (c:Condition {uid: 'hu:condition:insulin-resistance'})-[h:HAS_IDENTIFIER]->(i:Identifier {scheme: 'ICD10CM'})
WHERE (h.validFrom IS NULL OR h.validFrom <= asOf) AND (h.validTo IS NULL OR asOf < h.validTo) AND h.recordedTo IS NULL
RETURN toString(date(asOf)) AS asOf, i.value AS icd10cm, h.validFromBasis AS fromBasis, h.validToBasis AS toBasis
ORDER BY asOf;

// CQ-MX-C03 (missing-identifier variant): conditions with no MONDO concept recorded, and what does identify them.
MATCH (c:Condition)
WHERE c.mondoId IS NULL
OPTIONAL MATCH (c)-[:HAS_IDENTIFIER]->(i:Identifier)
RETURN c.name AS condition, collect(i.scheme + ' ' + i.value) AS identifiers, 'no MONDO concept recorded (not: not a disease)' AS mondoState
ORDER BY condition;
