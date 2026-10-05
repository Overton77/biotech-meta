// W12 Quality testing and certification: operations recommendation (baseline, Neo4j 5.26 Community-safe).
// Run run-2026-10-04-fable51-01, worker W12 (Opus 5.5). Recommendation for Fable's merged operations file; not a deployment.
// Every statement is idempotent (IF NOT EXISTS) and uses STORED property names. Executed on embedded Neo4j 5.26.31
// Community on 2026-10-04 (see 07-operations.md for the run record). Enterprise-only property existence / type
// constraints are listed in 07-operations.md as a companion, never mixed into this file.
// Statement order: uniqueness constraints first (they create their backing range indexes), then lookup indexes.

// --- identity: one node per uid per W12 label (V-000a remains the cross-label check) ---
CREATE CONSTRAINT w12_productlot_uid IF NOT EXISTS FOR (n:ProductLot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_testsample_uid IF NOT EXISTS FOR (n:TestSample) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_testexecution_uid IF NOT EXISTS FOR (n:TestExecution) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_testmethod_uid IF NOT EXISTS FOR (n:TestMethod) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_testinglaboratory_uid IF NOT EXISTS FOR (n:TestingLaboratory) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_measuredresult_uid IF NOT EXISTS FOR (n:MeasuredResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_specificationcriterion_uid IF NOT EXISTS FOR (n:SpecificationCriterion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_passfailinterpretation_uid IF NOT EXISTS FOR (n:PassFailInterpretation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_lottestsummary_uid IF NOT EXISTS FOR (n:LotTestSummary) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_certificateofanalysis_uid IF NOT EXISTS FOR (n:CertificateOfAnalysis) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_certificationprogram_uid IF NOT EXISTS FOR (n:CertificationProgram) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_certificationlisting_uid IF NOT EXISTS FOR (n:CertificationListing) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w12_certificationscope_uid IF NOT EXISTS FOR (n:CertificationScope) REQUIRE n.uid IS UNIQUE;

// --- live projection id (the GraphQL @id field is stored as `id`; uniqueness per label) ---
CREATE CONSTRAINT w12_productlot_id IF NOT EXISTS FOR (n:ProductLot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w12_measuredresult_id IF NOT EXISTS FOR (n:MeasuredResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w12_certificateofanalysis_id IF NOT EXISTS FOR (n:CertificateOfAnalysis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w12_certificationlisting_id IF NOT EXISTS FOR (n:CertificationListing) REQUIRE n.id IS UNIQUE;

// --- lookup indexes for the CQ query shapes (lot code is NOT unique: the same code recurs across brands) ---
CREATE INDEX w12_productlot_lotcode IF NOT EXISTS FOR (n:ProductLot) ON (n.lotCode);
CREATE INDEX w12_measuredresult_analyte IF NOT EXISTS FOR (n:MeasuredResult) ON (n.analyte);
CREATE INDEX w12_measuredresult_analyteuid IF NOT EXISTS FOR (n:MeasuredResult) ON (n.analyteUid);
CREATE INDEX w12_specificationcriterion_analyte IF NOT EXISTS FOR (n:SpecificationCriterion) ON (n.analyte);
CREATE INDEX w12_certificationlisting_listingid IF NOT EXISTS FOR (n:CertificationListing) ON (n.listingId);
CREATE INDEX w12_certificateofanalysis_number IF NOT EXISTS FOR (n:CertificateOfAnalysis) ON (n.certificateNumber);
CREATE INDEX w12_passfail_basis_verdict IF NOT EXISTS FOR (n:PassFailInterpretation) ON (n.verdictBasis, n.verdict);
CREATE INDEX w12_testexecution_purpose IF NOT EXISTS FOR (n:TestExecution) ON (n.testPurpose);

// --- relationship-property lookups used by asserted / episode filters ---
CREATE INDEX w12_covers_assertionuid IF NOT EXISTS FOR ()-[r:COVERS]-() ON (r.assertionUid);
CREATE INDEX w12_has_certification_scope_reluid IF NOT EXISTS FOR ()-[r:HAS_CERTIFICATION_SCOPE]-() ON (r.relationshipUid);
CREATE INDEX w12_lot_of_assertionuid IF NOT EXISTS FOR ()-[r:LOT_OF]-() ON (r.assertionUid);
