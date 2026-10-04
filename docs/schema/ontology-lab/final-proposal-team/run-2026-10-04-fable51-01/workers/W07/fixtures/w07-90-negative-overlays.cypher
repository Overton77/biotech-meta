// W07 negative overlays (run-2026-10-04-fable51-01). Load AFTER fixtures 00-04 have passed w07-validation.cypher.
// Each block introduces exactly one collapse; expected violation ids and rows are listed per block and in
// 06-fixtures-and-queries.md. All values synthetic; nodes created here use uids containing 'neg-'.

// N1 (V-302; forbidden [SHARES_LOINC_CODE, SAME_ASSAY_VERSION]): same LOINC 4548-4, different AssayVersion (Mayo D-100
// HPLC vs Labcorp Tina Quant), trended without a ComparabilityAssessment. Expected V-302: 1 row.
// status: run
MATCH (r1:DiagnosticResult {uid: 'hu:result:synthetic-mayo-hba1c-2025-03-14'}), (r2:DiagnosticResult {uid: 'hu:result:synthetic-labcorp-hba1c-2025-04-02'})
MERGE (r1)-[c:COMPARED_TO]->(r2)
SET c.derivationRule = 'naive: same LOINC code', c.derivedAt = datetime('2026-10-04T01:20:00Z');

// N2 (V-304; forbidden [SAME_ALGORITHM_FAMILY, SAME_ALGORITHM_VERSION]): GrimAge v1 vs GrimAge2 trended; the only
// assessment says NOT_COMPARABLE. Expected V-304: 1 row.
// status: run
MATCH (r1:DiagnosticResult {uid: 'hu:result:synthetic-grimage-v1-2024-03-01'}), (r2:DiagnosticResult {uid: 'hu:result:synthetic-grimage2-2025-03-01'})
MERGE (r1)-[c:COMPARED_TO]->(r2)
SET c.derivationRule = 'naive: same algorithm family', c.derivedAt = datetime('2026-10-04T01:20:00Z');

// N3 (V-312 and V-304): same family, two SERVICE_ENDPOINT_UNVERSIONED pins trended. Expected V-312: 2 rows; V-304: 1 row.
// status: run
MATCH (r1:DiagnosticResult {uid: 'hu:result:synthetic-owkin-density-slide-s1-2026-10-03'}), (r2:DiagnosticResult {uid: 'hu:result:synthetic-owkin-density-slide-s1-2026-10-04'})
MERGE (r1)-[c:COMPARED_TO]->(r2)
SET c.derivationRule = 'naive: same feature name', c.derivedAt = datetime('2026-10-04T01:20:00Z');

// N4 (INV-302; V-305c, V-306): one ReferenceIntervalVersion bound to two AssayVersions (Mayo and Labcorp) and used to
// interpret a Labcorp-produced result. Expected V-305c: 1 row; V-306: 1 row (the Mayo binding). Current V-302 does
// NOT detect it (V-302 tests INV-301 comparisons; see 05-decision-seam-ledger.md D-W07-09).
// status: run
MATCH (a1:AssayVersion {uid: 'hu:assay-version:mayo-hba1c-biorad-d100'}), (a2:AssayVersion {uid: 'hu:assay-version:labcorp-001453-tina-quant'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
MERGE (ri:ReferenceIntervalVersion:VersionedState {uid: 'hu:ri-version:neg-hba1c-shared-by-two-assays'})
SET ri.id = 'neg-hba1c-shared-by-two-assays', ri.lowerBound = 4.0, ri.upperBound = 5.6, ri.lowerBoundStatus = 'REPORTED', ri.upperBoundStatus = 'REPORTED',
    ri.unitCode = '%', ri.intervalKind = 'REFERENCE_INTERVAL', ri.derivationKind = 'NOT_REPORTED', ri.stateType = 'REFERENCE_INTERVAL_VERSION',
    ri.payloadHash = 'synthetic:hu:ri-version:neg-hba1c-shared-by-two-assays', ri.privacyClass = 'PUBLIC', ri.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (ri)-[:FOR_ASSAY_VERSION]->(a1)
MERGE (ri)-[:FOR_ASSAY_VERSION]->(a2)
MERGE (ri)-[:FOR_METRIC]->(m);

// status: run
MATCH (av:AssayVersion {uid: 'hu:assay-version:labcorp-001453-tina-quant'}), (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:neg-hba1c-shared-by-two-assays'})
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:result:synthetic-neg-labcorp-hba1c-shared-interval'})
SET r.id = 'synthetic-neg-labcorp-hba1c-shared-interval', r.artifactType = 'DIAGNOSTIC_RESULT', r.resultKind = 'MEASURED', r.valueNumber = 5.8, r.unitCode = '%',
    r.valueStatus = 'NUMERIC', r.observedAt = datetime('2025-05-05T08:00:00Z'), r.reportedAt = datetime('2025-05-06T00:00:00Z'), r.privacyClass = 'PUBLIC',
    r.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(av)
MERGE (r)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri);

// N5 (INV-303; V-303 and V-303r): a DiagnosticResult implementer (Observation) with resultKind MEASURED, no AssayVersion
// and no pending assertion. Expected V-303: 2 rows (this one + the Everlywell pending result); V-303r: 1 row (this one).
// status: run
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:result:synthetic-neg-hba1c-no-assay-version'})
SET r.id = 'synthetic-neg-hba1c-no-assay-version', r.artifactType = 'DIAGNOSTIC_RESULT', r.resultKind = 'MEASURED', r.valueNumber = 6.1, r.unitCode = '%',
    r.valueStatus = 'NUMERIC', r.observedAt = datetime('2025-07-07T08:00:00Z'), r.reportedAt = datetime('2025-07-08T00:00:00Z'), r.privacyClass = 'PUBLIC',
    r.createdAt = datetime('2026-10-04T01:20:00Z');

// N6 (V-314; forbidden [WITHIN_VERSION_SCORE_DIFFERENCE, MEASURED_BIOLOGICAL_CHANGE]): the within-version GrimAge2
// difference written as a DIRECT_MEASUREMENT change. Expected V-314: 1 row.
// status: run
MATCH (r2:DiagnosticResult {uid: 'hu:result:synthetic-grimage2-2025-09-01'}), (r1:DiagnosticResult {uid: 'hu:result:synthetic-grimage2-2025-03-01'})
MERGE (x:Assertion {uid: 'hu:assertion:neg-grimage2-measured-change'})
SET x.id = 'neg-grimage2-measured-change', x.predicate = 'CHANGED_BETWEEN', x.status = 'PROPOSED', x.polarity = 'POSITIVE', x.basisKind = 'DIRECT_MEASUREMENT',
    x.predicateClass = 'QUANTITY', x.recordedAt = datetime('2026-10-04T01:20:00Z'), x.contentHash = 'synthetic:' + x.uid
MERGE (x)-[:HAS_SUBJECT]->(r2)
MERGE (x)-[:HAS_OBJECT]->(r1);

// N7 (V-307, V-315; forbidden [SIMILAR_TEST_NAME, SAME_METRIC]): Labcorp "Hemoglobin A1c" (4548-4) merged with synthetic
// Lab C "Hemoglobin A1c" (59261-8) by name. Expected V-307: 1 row; V-315: 1 row.
// status: run
MATCH (t1:LabTest {uid: 'hu:lab-test:labcorp-001453'}), (t2:LabTest {uid: 'hu:lab-test:synthetic-lab-c-hba1c'})
MERGE (t1)-[s:SAME_TEST_AS]->(t2)
SET s.derivationRule = 'naive: identical test name';

// N8 (V-316; forbidden [INFERRED_RESULT, MEASURED_RESULT]): a GrimAge2 score relabelled MEASURED. Expected V-316: 1 row.
// status: run
MATCH (av:AssayVersion {uid: 'hu:assay-version:synthetic-lab-m-epic'}), (v:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'})
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:result:synthetic-neg-grimage2-as-measured'})
SET r.id = 'synthetic-neg-grimage2-as-measured', r.artifactType = 'DIAGNOSTIC_RESULT', r.resultKind = 'MEASURED', r.valueNumber = 47.0, r.unitCode = 'a',
    r.valueStatus = 'NUMERIC', r.observedAt = datetime('2025-10-01T00:00:00Z'), r.privacyClass = 'PUBLIC', r.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(av)
MERGE (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v);

// N9 (V-301b): one AssayVersion operated by two labs (Lab A's cobas assay also attached to Lab B). Expected V-301b: 1 row.
// status: run
MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (lab:Organization {uid: 'hu:org:synthetic-lab-b'})
MERGE (a)-[:ASSAY_OPERATED_BY]->(lab);

// N10 (V-311): an assessment comparing three versions. Expected V-311: 1 row.
// status: run
MATCH (a1:AssayVersion {uid: 'hu:assay-version:mayo-hba1c-biorad-d100'}), (a2:AssayVersion {uid: 'hu:assay-version:labcorp-001453-tina-quant'}), (a3:AssayVersion {uid: 'hu:assay-version:quest-496-tinia'})
MERGE (ca:ComparabilityAssessment:EvidenceAssessment {uid: 'hu:comparability:neg-three-us-labs'})
SET ca.id = 'neg-three-us-labs', ca.assessmentType = 'COMPARABILITY', ca.methodVersion = 'w07-comparability-v0', ca.status = 'PROPOSED',
    ca.recordedAt = datetime('2026-10-04T01:20:00Z'), ca.verdict = 'COMPARABLE', ca.privacyClass = 'PUBLIC', ca.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (ca)-[:COMPARES]->(a1)
MERGE (ca)-[:COMPARES]->(a2)
MERGE (ca)-[:COMPARES]->(a3);

// N11 (V-310a): malformed LOINC code. Expected V-310a: 1 row.
// status: run
MERGE (m:Metric:Entity {uid: 'hu:metric:neg-malformed-loinc'})
SET m.id = 'neg-malformed-loinc', m.name = 'HbA1c (bad code)', m.loincCode = '4548-04', m.unitStatus = 'REPORTED', m.entityType = 'METRIC',
    m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T01:20:00Z');

// N12 (V-313r; INV-506 leak check, CQ-DX-08): a private personal measurement placed in the shared graph. Labelled
// :PrivateRecord (fixture device) so W23's V-113..V-116 / V-520 / V-521 can also be exercised. Expected V-313r: 1 row.
// status: run
MATCH (av:AssayVersion {uid: 'hu:assay-version:quest-496-tinia'})
MERGE (r:PrivateRecord:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:private-result:neg-person-hba1c'})
SET r.id = 'neg-person-hba1c', r.artifactType = 'DIAGNOSTIC_RESULT', r.resultKind = 'MEASURED', r.valueNumber = 6.8, r.unitCode = '%',
    r.privacyClass = 'PRIVATE_PERSONAL', r.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(av);

// N13 (V-317): an unversioned endpoint without a retrieval pin. Expected V-317: 1 row.
// status: run
MATCH (al:Algorithm {uid: 'hu:algorithm:owkin-he-cell-detection'})
MERGE (v:AlgorithmVersion:VersionedState {uid: 'hu:algorithm-version:neg-owkin-unpinned'})
SET v.id = 'neg-owkin-unpinned', v.versionBasis = 'SERVICE_ENDPOINT_UNVERSIONED', v.outputKind = 'FEATURE_MEASURE', v.stateType = 'ALGORITHM_VERSION',
    v.payloadHash = 'synthetic:hu:algorithm-version:neg-owkin-unpinned', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (v)-[:VERSION_OF_ALGORITHM]->(al);

// N14 (V-318): Quest's one-sided "<5.7 %" captured with a null lower bound marked REPORTED (reads as a missing value
// rather than "no lower limit"). Expected V-318: 1 row.
// status: run
MATCH (av:AssayVersion {uid: 'hu:assay-version:quest-496-tinia'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
MERGE (ri:ReferenceIntervalVersion:VersionedState {uid: 'hu:ri-version:neg-quest-one-sided-miscaptured'})
SET ri.id = 'neg-quest-one-sided-miscaptured', ri.lowerBound = null, ri.upperBound = 5.7, ri.lowerBoundStatus = 'REPORTED', ri.upperBoundStatus = 'REPORTED',
    ri.unitCode = '%', ri.intervalText = '<5.7 %', ri.intervalKind = 'REFERENCE_INTERVAL', ri.derivationKind = 'NOT_REPORTED', ri.stateType = 'REFERENCE_INTERVAL_VERSION',
    ri.payloadHash = 'synthetic:hu:ri-version:neg-quest-one-sided-miscaptured', ri.privacyClass = 'PUBLIC', ri.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (ri)-[:FOR_ASSAY_VERSION]->(av)
MERGE (ri)-[:FOR_METRIC]->(m);
