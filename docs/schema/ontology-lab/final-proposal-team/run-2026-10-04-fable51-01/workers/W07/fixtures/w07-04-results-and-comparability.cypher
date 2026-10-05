// W07 fixture 04: DiagnosticResult implementers (W16 Observation) and comparability (run-2026-10-04-fable51-01).
// All result values and dates are SYNTHETIC; results are public, source-attributed fixture Observations carrying the
// labels Observation:DiagnosticResult:InformationArtifact (W07-SR-02) with privacyClass PUBLIC (synthetic is fixture
// provenance, not a privacy class). No private record exists in this file (INV-506).
// Cases: licensed cross-lab comparison (Lab A Tosoh vs Lab B IFCC, NGSP master equation); same-assay comparison within
// Lab A; interval kept as printed at report time after the lab changed its interval (2025-09-10 keeps a2 although a3
// is current); within-version GrimAge2 score difference recorded as a vendor statement, never a measured change;
// vendor "GrimAge" label unresolved; Everlywell result whose performing lab is not named (pending assay version).

// status: run
UNWIND [
  {k: 'mayo-hba1c-2025-03-14', rk: 'MEASURED', v: 5.4, u: '%', obs: '2025-03-14T08:00:00Z', rep: '2025-03-15T00:00:00Z'},
  {k: 'labcorp-hba1c-2025-04-02', rk: 'MEASURED', v: 5.6, u: '%', obs: '2025-04-02T08:00:00Z', rep: '2025-04-02T00:00:00Z'},
  {k: 'lab-a-hba1c-2025-01-10', rk: 'MEASURED', v: 5.4, u: '%', obs: '2025-01-10T08:00:00Z', rep: '2025-01-11T00:00:00Z'},
  {k: 'lab-a-hba1c-2025-09-10', rk: 'MEASURED', v: 5.7, u: '%', obs: '2025-09-10T08:00:00Z', rep: '2025-09-11T00:00:00Z'},
  {k: 'lab-a-hba1c-2026-02-10', rk: 'MEASURED', v: 5.7, u: '%', obs: '2026-02-10T08:00:00Z', rep: '2026-02-11T00:00:00Z'},
  {k: 'lab-b-hba1c-2025-01-20', rk: 'MEASURED', v: 36.0, u: 'mmol/mol', obs: '2025-01-20T08:00:00Z', rep: '2025-01-21T00:00:00Z'},
  {k: 'lab-c-hba1c-2025-05-01', rk: 'MEASURED', v: 38.0, u: 'mmol/mol', obs: '2025-05-01T08:00:00Z', rep: '2025-05-02T00:00:00Z'},
  {k: 'everlywell-hba1c-2025-06-01', rk: 'MEASURED', v: 5.5, u: '%', obs: null, rep: '2025-06-09T00:00:00Z'},
  {k: 'grimage-v1-2024-03-01', rk: 'INFERRED', v: 52.0, u: 'a', obs: '2024-03-01T00:00:00Z', rep: '2024-03-20T00:00:00Z'},
  {k: 'grimage2-2025-03-01', rk: 'INFERRED', v: 49.0, u: 'a', obs: '2025-03-01T00:00:00Z', rep: '2025-03-20T00:00:00Z'},
  {k: 'grimage2-2025-09-01', rk: 'INFERRED', v: 45.0, u: 'a', obs: '2025-09-01T00:00:00Z', rep: '2025-09-20T00:00:00Z'},
  {k: 'vendor-grimage-unresolved-2025-11-01', rk: 'INFERRED', v: 50.5, u: 'a', obs: '2025-11-01T00:00:00Z', rep: '2025-11-20T00:00:00Z'},
  {k: 'trudx-dunedinpace-2025-08-01', rk: 'INFERRED', v: 0.92, u: null, obs: '2025-08-01T00:00:00Z', rep: '2025-08-25T00:00:00Z'},
  {k: 'owkin-density-slide-s1-2026-10-03', rk: 'INFERRED', v: 277.0, u: null, obs: null, rep: '2026-10-03T00:00:00Z'},
  {k: 'owkin-density-slide-s1-2026-10-04', rk: 'INFERRED', v: 281.5, u: null, obs: null, rep: '2026-10-04T01:04:00Z'}
] AS row
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:result:synthetic-' + row.k})
SET r.id = 'synthetic-' + row.k, r.artifactType = 'DIAGNOSTIC_RESULT', r.resultKind = row.rk, r.valueNumber = row.v, r.unitCode = row.u,
    r.valueStatus = 'NUMERIC', r.observedAt = CASE WHEN row.obs IS NULL THEN null ELSE datetime(row.obs) END, r.reportedAt = datetime(row.rep),
    r.privacyClass = 'PUBLIC', r.contentHash = 'synthetic:hu:result:synthetic-' + row.k, r.createdAt = datetime('2026-10-04T01:10:00Z');

// Structural result edges: assay version and every interval printed on the report.
// status: run
UNWIND [
  {r: 'mayo-hba1c-2025-03-14', av: 'mayo-hba1c-biorad-d100', ris: ['mayo-hba1c-ri', 'mayo-hba1c-prediabetes', 'mayo-hba1c-diabetes']},
  {r: 'labcorp-hba1c-2025-04-02', av: 'labcorp-001453-tina-quant', ris: ['labcorp-001453-ri', 'labcorp-001453-diabetes-menu', 'labcorp-001453-glycemic-target']},
  {r: 'lab-a-hba1c-2025-01-10', av: 'synthetic-lab-a-hba1c-tosoh-g8-5-24', ris: ['synthetic-lab-a-hba1c-a1-adult']},
  {r: 'lab-a-hba1c-2025-09-10', av: 'synthetic-lab-a-hba1c-cobas-c513', ris: ['synthetic-lab-a-hba1c-a2-adult']},
  {r: 'lab-a-hba1c-2026-02-10', av: 'synthetic-lab-a-hba1c-cobas-c513', ris: ['synthetic-lab-a-hba1c-a3-adult']},
  {r: 'lab-b-hba1c-2025-01-20', av: 'synthetic-lab-b-hba1c-cobas-c513-ifcc', ris: ['synthetic-lab-b-hba1c-b1-adult']},
  {r: 'lab-c-hba1c-2025-05-01', av: 'synthetic-lab-c-hba1c-ifcc', ris: ['synthetic-lab-c-hba1c-c1']},
  {r: 'grimage-v1-2024-03-01', av: 'synthetic-lab-m-epic', ris: []},
  {r: 'grimage2-2025-03-01', av: 'synthetic-lab-m-epic', ris: []},
  {r: 'grimage2-2025-09-01', av: 'synthetic-lab-m-epic', ris: []},
  {r: 'trudx-dunedinpace-2025-08-01', av: 'trudiagnostic-msa', ris: []}
] AS row
MATCH (r:DiagnosticResult {uid: 'hu:result:synthetic-' + row.r}), (av:AssayVersion {uid: 'hu:assay-version:' + row.av})
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(av)
WITH r, row
UNWIND (CASE WHEN size(row.ris) = 0 THEN [null] ELSE row.ris END) AS rk
OPTIONAL MATCH (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:' + rk})
FOREACH (x IN CASE WHEN ri IS NULL THEN [] ELSE [ri] END | MERGE (r)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(x));

// status: run
UNWIND [
  {r: 'grimage-v1-2024-03-01', v: 'grimage-v1-lu-2019'},
  {r: 'grimage2-2025-03-01', v: 'grimage2-lu-2022'},
  {r: 'grimage2-2025-09-01', v: 'grimage2-lu-2022'},
  {r: 'trudx-dunedinpace-2025-08-01', v: 'trudiagnostic-dunedinpace-msa'},
  {r: 'owkin-density-slide-s1-2026-10-03', v: 'owkin-he-cell-detection-endpoint-2026-10-03'},
  {r: 'owkin-density-slide-s1-2026-10-04', v: 'owkin-he-cell-detection-endpoint-2026-10-04'}
] AS row
MATCH (r:DiagnosticResult {uid: 'hu:result:synthetic-' + row.r}), (v:AlgorithmVersion {uid: 'hu:algorithm-version:' + row.v})
MERGE (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v);

// Everlywell: performing laboratory not named ("Each lab we work with"), so no AssayVersion can be built (it needs
// exactly one operator). The pending link is an UNRESOLVED assertion with a literal. Current V-303 reports this row;
// the proposed V-303r accepts it as the only pending state for MEASURED results (W07-SR-09).
// status: run
MATCH (r:DiagnosticResult {uid: 'hu:result:synthetic-everlywell-hba1c-2025-06-01'}), (l:SourceLocator {uid: 'hu:locator:everlywell-hba1c-labs'})
MERGE (x:Assertion {uid: 'hu:assertion:everlywell-result-produced-by-unnamed-lab'})
SET x.id = 'everlywell-result-produced-by-unnamed-lab', x.predicate = 'PRODUCED_BY_ASSAY_VERSION', x.status = 'UNRESOLVED',
    x.valueString = 'performing laboratory not named by the vendor', x.recordedAt = datetime('2026-10-04T01:10:00Z'),
    x.contentHash = 'synthetic:' + x.uid, x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(r)
MERGE (x)-[:SUPPORTED_BY]->(l);

// Vendor "GrimAge" label without a version: two UNRESOLVED result-to-version assertions with competing hypotheses.
// status: run
MATCH (r:DiagnosticResult {uid: 'hu:result:synthetic-vendor-grimage-unresolved-2025-11-01'}), (v1:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'}), (v2:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'})
MERGE (x1:Assertion {uid: 'hu:assertion:vendor-grimage-result-computed-by-v1'})
SET x1.id = 'vendor-grimage-result-computed-by-v1', x1.predicate = 'COMPUTED_BY_ALGORITHM_VERSION', x1.status = 'UNRESOLVED', x1.recordedAt = datetime('2026-10-04T01:10:00Z'), x1.contentHash = 'synthetic:' + x1.uid, x1.privacyClass = 'PUBLIC'
MERGE (x1)-[:HAS_SUBJECT]->(r)
MERGE (x1)-[:HAS_OBJECT]->(v1)
MERGE (x2:Assertion {uid: 'hu:assertion:vendor-grimage-result-computed-by-v2'})
SET x2.id = 'vendor-grimage-result-computed-by-v2', x2.predicate = 'COMPUTED_BY_ALGORITHM_VERSION', x2.status = 'UNRESOLVED', x2.recordedAt = datetime('2026-10-04T01:10:00Z'), x2.contentHash = 'synthetic:' + x2.uid, x2.privacyClass = 'PUBLIC'
MERGE (x2)-[:HAS_SUBJECT]->(r)
MERGE (x2)-[:HAS_OBJECT]->(v2)
MERGE (h1:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:vendor-grimage-is-v1'})
SET h1.id = 'vendor-grimage-is-v1', h1.assessmentType = 'RESOLUTION', h1.methodVersion = 'w07-manual-v0', h1.status = 'PROPOSED', h1.recordedAt = datetime('2026-10-04T01:10:00Z'), h1.resolutionType = 'ALGORITHM_VERSION_OF_RESULT', h1.rationale = 'Vendor label says GrimAge without version.', h1.privacyClass = 'PUBLIC', h1.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (h2:ResolutionHypothesis:EvidenceAssessment {uid: 'hu:resolution:vendor-grimage-is-v2'})
SET h2.id = 'vendor-grimage-is-v2', h2.assessmentType = 'RESOLUTION', h2.methodVersion = 'w07-manual-v0', h2.status = 'PROPOSED', h2.recordedAt = datetime('2026-10-04T01:10:00Z'), h2.resolutionType = 'ALGORITHM_VERSION_OF_RESULT', h2.rationale = 'Vendor label says GrimAge without version.', h2.privacyClass = 'PUBLIC', h2.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (h1)-[:PROPOSES_MATCH]->(v1)
MERGE (h2)-[:PROPOSES_MATCH]->(v2)
MERGE (h1)-[:COMPETES_WITH]->(h2);

// Comparability assessments: one licensing (NGSP master equation), one explicitly NOT_COMPARABLE (GrimAge v1 vs v2).
// status: run
MATCH (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (b1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (l:SourceLocator {uid: 'hu:locator:ngsp-master-equation-table-2'})
MERGE (ca:ComparabilityAssessment:EvidenceAssessment {uid: 'hu:comparability:lab-a-a1-vs-lab-b-b1-hba1c'})
SET ca.id = 'lab-a-a1-vs-lab-b-b1-hba1c', ca.assessmentType = 'COMPARABILITY', ca.methodVersion = 'w07-comparability-v0', ca.status = 'PROPOSED',
    ca.recordedAt = datetime('2026-10-04T01:10:00Z'), ca.verdict = 'COMPARABLE_WITH_CONVERSION', ca.measurandMatch = 'SAME_BIOMARKER_DIFFERENT_METRIC',
    ca.unitConversionRule = 'NGSP(%) = 0.09148 * IFCC(mmol/mol) + 2.152 (NGSP Table 2)', ca.traceabilityMatch = 'NGSP_AND_IFCC_LINKED_BY_MASTER_EQUATION',
    ca.interferenceProfileMatch = 'UNKNOWN', ca.referenceIntervalMatch = 'NOT_COMPARED', ca.replicateNoiseBasis = null,
    ca.rationale = 'Synthetic labs; both claim traceability. Hb-variant interference not assessed.', ca.privacyClass = 'PUBLIC', ca.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ca)-[:COMPARES]->(a1)
MERGE (ca)-[:COMPARES]->(b1)
MERGE (ca)-[:SUPPORTED_BY]->(l);

// status: run
MATCH (v1:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'}), (v2:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'}), (l:SourceLocator {uid: 'hu:locator:pmid-36516495-abstract'})
MERGE (ca:ComparabilityAssessment:EvidenceAssessment {uid: 'hu:comparability:grimage-v1-vs-grimage2'})
SET ca.id = 'grimage-v1-vs-grimage2', ca.assessmentType = 'COMPARABILITY', ca.methodVersion = 'w07-comparability-v0', ca.status = 'PROPOSED',
    ca.recordedAt = datetime('2026-10-04T01:10:00Z'), ca.verdict = 'NOT_COMPARABLE', ca.measurandMatch = 'DIFFERENT',
    ca.rationale = 'GrimAge2 adds logCRP and logA1C surrogates and a 40-92 training range; no published conversion.', ca.privacyClass = 'PUBLIC',
    ca.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ca)-[:COMPARES]->(v1)
MERGE (ca)-[:COMPARES]->(v2)
MERGE (ca)-[:SUPPORTED_BY]->(l);

// Derived COMPARED_TO edges written by the projection rule (DerivedEdgeProperties).
// status: run
UNWIND [
  {r1: 'lab-a-hba1c-2025-01-10', r2: 'lab-b-hba1c-2025-01-20', rule: 'INV-301 assessment-licensed (COMPARABLE_WITH_CONVERSION)', as: ['hu:comparability:lab-a-a1-vs-lab-b-b1-hba1c']},
  {r1: 'lab-a-hba1c-2025-09-10', r2: 'lab-a-hba1c-2026-02-10', rule: 'INV-301 same AssayVersion', as: []},
  {r1: 'grimage2-2025-03-01', r2: 'grimage2-2025-09-01', rule: 'INV-301 same AlgorithmVersion (axis only; not a change)', as: []}
] AS row
MATCH (r1:DiagnosticResult {uid: 'hu:result:synthetic-' + row.r1}), (r2:DiagnosticResult {uid: 'hu:result:synthetic-' + row.r2})
MERGE (r1)-[c:COMPARED_TO]->(r2)
SET c.derivationRule = row.rule, c.derivedFromAssessmentUids = row.as, c.derivedAt = datetime('2026-10-04T01:10:00Z');

// Within-version difference: the vendor's statement "decreased by 4.0 years" is recorded as what the vendor said
// (candidate predicate CHANGED_BETWEEN, subject later result, object earlier result, no literal: INV-003; the stated
// magnitude equals the arithmetic difference; basisKind INFERRED_FROM_MEASUREMENT, PROPOSED). It is never a measured change:
// no ComparabilityAssessment with a replicateNoiseBasis exists for GrimAge2 (OQ-L3-03), V-314 forbids DIRECT_MEASUREMENT.
// status: run
MATCH (r2:DiagnosticResult {uid: 'hu:result:synthetic-grimage2-2025-09-01'}), (r1:DiagnosticResult {uid: 'hu:result:synthetic-grimage2-2025-03-01'}), (lab:Organization {uid: 'hu:org:synthetic-lab-m'}), (l:SourceLocator {uid: 'hu:locator:synthetic-reports-body'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-m-says-grimage2-decreased-4-years'})
SET x.id = 'lab-m-says-grimage2-decreased-4-years', x.predicate = 'CHANGED_BETWEEN', x.status = 'PROPOSED', x.polarity = 'POSITIVE',
    x.basisKind = 'INFERRED_FROM_MEASUREMENT', x.predicateClass = 'QUANTITY', x.speechAct = 'STATES',
    x.recordedAt = datetime('2026-10-04T01:10:00Z'), x.contentHash = 'synthetic:' + x.uid, x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(r2)
MERGE (x)-[:HAS_OBJECT]->(r1)
MERGE (x)-[:ASSERTED_BY]->(lab)
MERGE (x)-[:SUPPORTED_BY]->(l);

// Capture-fidelity policy adjudication for the ACCEPTED assertions this packet created (INV-103 / V-110); says nothing
// about truth.
// status: run
MATCH (a:Assertion)
WHERE a.uid STARTS WITH 'hu:assertion:' AND a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w07-capture-fidelity-policy-2026-10-04'})
ON CREATE SET j.id = 'w07-capture-fidelity-policy-2026-10-04', j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w07-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.rationale = 'Fixture capture policy: recorded propositions match the cited sections as read on 2026-10-04.',
    j.reviewedAt = datetime('2026-10-04T01:10:00Z'), j.recordedAt = datetime('2026-10-04T01:10:00Z'), j.createdAt = datetime('2026-10-04T01:10:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
