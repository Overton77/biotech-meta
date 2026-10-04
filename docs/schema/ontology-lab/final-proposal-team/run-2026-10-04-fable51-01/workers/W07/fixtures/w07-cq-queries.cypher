// W07 competency-question queries over fixtures 00-04 (run-2026-10-04-fable51-01). Parameters are inlined as literals
// (the harness runs each statement standalone). Expected rows: 06-fixtures-and-queries.md.

// QS-DX-01 (CQ-DX-01, Essential): what does Labcorp 001453 measure, by which assay version, method, instrument and
// specimen types, as currently recorded? Unknown method/instrument come back null, never guessed.
MATCH (t:LabTest {uid: 'hu:lab-test:labcorp-001453'})-[mm:MEASURES_METRIC]->(m:Metric)
MATCH (t)-[e:PERFORMED_WITH_ASSAY_VERSION]->(a:AssayVersion)
WHERE e.recordedTo IS NULL
OPTIONAL MATCH (a)-[:USES_METHOD]->(meth:MeasurementMethod)
OPTIONAL MATCH (a)-[:RUNS_ON_INSTRUMENT]->(inst:ToolOrInstrument)
OPTIONAL MATCH (a)-[:ACCEPTS_SPECIMEN_TYPE]->(sp:Specimen)
RETURN m.loincCode AS loinc, m.propertyKind AS property, m.systemKind AS system, m.scaleKind AS scale, a.uid AS assayVersion,
       a.assayKitIdentifier AS kit, meth.methodPrinciple AS method, inst.name AS instrument, a.softwareVersionStatus AS softwareStatus,
       collect(DISTINCT sp.specimenTypeCode) AS specimenTypes;

// QS-DX-01b (CQ-DX-01, temporal correction): Lab A assay versions as believed now versus as recorded on 2025-08-01.
MATCH (t:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'})-[e:PERFORMED_WITH_ASSAY_VERSION]->(a:AssayVersion)
WITH a, e,
     (e.recordedFrom <= datetime('2025-08-01T00:00:00Z') AND (e.recordedTo IS NULL OR e.recordedTo > datetime('2025-08-01T00:00:00Z'))) AS believedOn20250801,
     (e.recordedTo IS NULL) AS believedNow
RETURN a.uid AS assayVersion, e.validFrom AS validFrom, e.validTo AS validTo, believedOn20250801, believedNow
ORDER BY assayVersion, validTo;

// QS-DX-02 (CQ-DX-02, Essential): is each result measured, calculated or inferred, and by which version?
MATCH (r:DiagnosticResult)
WHERE r.uid STARTS WITH 'hu:result:synthetic-' AND NOT r.uid CONTAINS 'neg-'
OPTIONAL MATCH (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a:AssayVersion)
OPTIONAL MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
RETURN r.uid AS result, r.resultKind AS kind, a.uid AS assayVersion, v.uid AS algorithmVersion, v.versionBasis AS versionBasis
ORDER BY result;

// QS-DX-03 (CQ-DX-03, Essential): which pairs of HbA1c results may share an axis, and with which rule? Pairs without a
// shared version or a licensing assessment are separate series.
MATCH (r1:DiagnosticResult)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion)-[:ASSAY_FOR_METRIC]->(:Metric)-[:QUANTIFIES]->(:Biomarker {uid: 'hu:biomarker:hba1c'})
MATCH (r2:DiagnosticResult)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)-[:ASSAY_FOR_METRIC]->(:Metric)-[:QUANTIFIES]->(:Biomarker {uid: 'hu:biomarker:hba1c'})
WHERE r1.uid < r2.uid AND NOT r1.uid CONTAINS 'neg-' AND NOT r2.uid CONTAINS 'neg-'
OPTIONAL MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
WHERE (ca)-[:COMPARES]->(a2) AND a1 <> a2 AND ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
WITH r1, r2, a1, a2, ca
RETURN r1.uid AS result1, r2.uid AS result2,
       CASE WHEN a1 = a2 THEN 'SAME_ASSAY_VERSION' WHEN ca IS NOT NULL THEN ca.verdict ELSE 'SEPARATE_SERIES' END AS axis,
       ca.unitConversionRule AS conversionRule
ORDER BY axis, result1, result2;

// QS-DX-04 (CQ-DX-04, Essential): which algorithm version produced each score, and on what version basis? Unresolved
// links list their competing candidates.
MATCH (r:DiagnosticResult)
WHERE r.resultKind IN ['INFERRED', 'CALCULATED'] AND NOT r.uid CONTAINS 'neg-'
OPTIONAL MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)-[:VERSION_OF_ALGORITHM]->(al:Algorithm)
OPTIONAL MATCH (x:Assertion {predicate: 'COMPUTED_BY_ALGORITHM_VERSION', status: 'UNRESOLVED'})-[:HAS_SUBJECT]->(r)
OPTIONAL MATCH (x)-[:HAS_OBJECT]->(cand:AlgorithmVersion)
RETURN r.uid AS result, al.name AS family, v.versionLabel AS versionLabel, v.versionBasis AS versionBasis, collect(DISTINCT cand.uid) AS unresolvedCandidates
ORDER BY result;

// QS-DX-05 (CQ-DX-05, Foundational): is the within-version GrimAge2 difference licensed as a change? (No assessment with
// a replicateNoiseBasis exists, so the answer is "not established"; the vendor statement is returned as a statement.)
MATCH (x:Assertion {predicate: 'CHANGED_BETWEEN'})-[:HAS_SUBJECT]->(r1:DiagnosticResult)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
MATCH (x)-[:HAS_OBJECT]->(r2:DiagnosticResult)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v)
WHERE NOT x.uid CONTAINS 'neg-'
OPTIONAL MATCH (x)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v) WHERE ca.replicateNoiseBasis IS NOT NULL
RETURN x.uid AS statement, who.name AS assertedBy, x.basisKind AS basis, v.uid AS algorithmVersion,
       CASE WHEN ca IS NULL THEN 'NOT_ESTABLISHED' ELSE 'LICENSED_BY_' + ca.uid END AS changeStatus;

// QS-DX-06 (CQ-DX-06, Foundational): which intervals were printed with each Lab A result (kept after the lab's
// 2026-01-01 interval change), and what is the lab's current interval for the same assay version?
MATCH (r:DiagnosticResult)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri:ReferenceIntervalVersion)
WHERE r.uid STARTS WITH 'hu:result:synthetic-lab-a-'
MATCH (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a:AssayVersion)
OPTIONAL MATCH (cur:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a)
WHERE cur.intervalKind = 'REFERENCE_INTERVAL' AND cur.effectiveTo IS NULL
RETURN r.uid AS result, ri.uid AS printedInterval, ri.intervalText AS printedText, ri.derivationKind AS derivation, cur.uid AS currentIntervalForAssay
ORDER BY result;

// QS-DX-06b (CQ-DX-06): kind of every bound printed with the Mayo and Labcorp results (reference interval versus decision
// limit versus guideline target; one-sided bounds are NOT_APPLICABLE, not unknown).
MATCH (r:DiagnosticResult)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri:ReferenceIntervalVersion)
WHERE r.uid IN ['hu:result:synthetic-mayo-hba1c-2025-03-14', 'hu:result:synthetic-labcorp-hba1c-2025-04-02']
RETURN r.uid AS result, ri.intervalKind AS kind, ri.lowerBound AS lo, ri.lowerBoundStatus AS loStatus, ri.upperBound AS hi, ri.upperBoundStatus AS hiStatus, ri.intervalText AS printed
ORDER BY result, kind, printed;

// QS-DX-07 (CQ-DX-07, Foundational): what the model service can and cannot establish.
MATCH (v:AlgorithmVersion)-[:VERSION_OF_ALGORITHM]->(al:Algorithm {uid: 'hu:algorithm:owkin-he-cell-detection'})
MATCH (v)-[:OUTPUTS_METRIC]->(m:Metric)
WHERE NOT v.uid CONTAINS 'neg-'
RETURN v.uid AS pin, v.versionBasis AS basis, v.retrievedAt AS retrievedAt, v.versionLabel AS versionLabel, m.name AS feature, m.unitStatus AS unitStatus, m.canonicalUnitCode AS unit
ORDER BY pin;

// QS-AX-21 (CQ-AX-21, Expansion): given only two assay-version uids from the private store, may their values share an
// axis? The query reads no result node.
WITH ['hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24', 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'] AS pair1,
     ['hu:assay-version:mayo-hba1c-biorad-d100', 'hu:assay-version:labcorp-001453-tina-quant'] AS pair2
UNWIND [pair1, pair2] AS pair
MATCH (a1:AssayVersion {uid: pair[0]}), (a2:AssayVersion {uid: pair[1]})
OPTIONAL MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
WHERE (ca)-[:COMPARES]->(a2)
RETURN pair[0] AS assay1, pair[1] AS assay2, coalesce(ca.verdict, 'NO_ASSESSMENT_SEPARATE_SERIES') AS verdict, ca.unitConversionRule AS rule;

// QS-MX-02 (CQ-MX-02 seam): compartment of the measurand for a LOINC-coded metric (Biomarker matrix vs LOINC system).
MATCH (m:Metric {loincCode: '4548-4'})-[:QUANTIFIES]->(b:Biomarker)
OPTIONAL MATCH (b)-[:MEASURED_IN_MATRIX]->(c:AnatomicalContext)
RETURN m.loincCode AS loinc, m.systemKind AS loincSystem, b.name AS biomarker, c.name AS matrix;
