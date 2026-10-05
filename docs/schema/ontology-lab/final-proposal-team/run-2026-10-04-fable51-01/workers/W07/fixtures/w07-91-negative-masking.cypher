// W07 negative overlay 91 (run-2026-10-04-fable51-01): loaded AFTER w07-90. Demonstrates that the catalog V-302 accepts a
// malformed (three-way) assessment as a licence; V-302r does not (W07-SR-11).

// N10 (V-311): an assessment comparing three versions (deliberately over the N1 pair). Expected V-311: 1 row.
// status: run
MATCH (a1:AssayVersion {uid: 'hu:assay-version:mayo-hba1c-biorad-d100'}), (a2:AssayVersion {uid: 'hu:assay-version:labcorp-001453-tina-quant'}), (a3:AssayVersion {uid: 'hu:assay-version:quest-496-tinia'})
MERGE (ca:ComparabilityAssessment:EvidenceAssessment {uid: 'hu:comparability:neg-three-us-labs'})
SET ca.id = 'neg-three-us-labs', ca.assessmentType = 'COMPARABILITY', ca.methodVersion = 'w07-comparability-v0', ca.status = 'PROPOSED',
    ca.recordedAt = datetime('2026-10-04T01:20:00Z'), ca.verdict = 'COMPARABLE', ca.privacyClass = 'PUBLIC', ca.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (ca)-[:COMPARES]->(a1)
MERGE (ca)-[:COMPARES]->(a2)
MERGE (ca)-[:COMPARES]->(a3);
