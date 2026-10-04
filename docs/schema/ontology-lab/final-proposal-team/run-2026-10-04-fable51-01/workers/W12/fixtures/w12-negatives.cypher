// W12 negative fixture: each block writes one forbidden shape on top of w12-00..w12-90 and names the validator(s) that
// must return rows. Load only into a disposable database; never into the positive baseline.
// Run run-2026-10-04-fable51-01, worker W12 (Opus 5.5). Every statement binds its own nodes by uid.
// status: executed on embedded Neo4j 5.26.31 Community; observed rows recorded in 06-fixtures-and-queries.md.

// N01 -> V-009: a certification listing with no scope certifies nothing.
MERGE (l:CertificationListing:VersionedState {uid: 'hu:cert-listing:w12-neg-no-scope'})
SET l.id = 'w12-neg-no-scope', l.stateType = 'CERTIFICATION_LISTING', l.payloadHash = 'sha256:3f0c0d7a3e6b0a1f2c9b8e7d6c5b4a3928170615f4e3d2c1b0a9f8e7d6c5b4a3', l.status = 'LISTED',
    l.listingId = 'NEG-0001', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T04:00:00Z'), l.updatedAt = datetime('2026-10-04T04:00:00Z');

MATCH (p:CertificationProgram {uid: 'hu:cert-program:nsf-certified-for-sport'}), (l:CertificationListing {uid: 'hu:cert-listing:w12-neg-no-scope'})
MERGE (p)-[:PROGRAM_HAS_LISTING]->(l);

// N02 -> V-332, V-W12-07 (FACILITY_PROGRAMME_PROJECTED_TO_ITEM, NO_DIRECT_COVERS_INPUT): facility GMP certification
// projected to a lot ("made in an NSF GMP-certified facility" read as "this lot is certified").
MATCH (x:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'}), (l:CertificationListing {uid: 'hu:cert-listing:synthetic-nsf-455-2-synthetic-plant'})
MERGE (x)-[r:CERTIFIED_UNDER]->(l)
SET r.derivationRule = 'w12-certified-under/v1:DIRECT_SCOPE_COVERAGE', r.derivedFromAssertionUids = ['hu:assertion:w12-covers-455-2-synthetic-plant'], r.derivedAt = datetime('2026-10-04T04:00:00Z');

// N03 -> V-332, V-W12-07 (UNKNOWN_DERIVATION_RULE, NO_DIRECT_COVERS_INPUT), V-112 (DERIVATION_WITHOUT_SOURCE_ASSERTIONS):
// lot-level NSF coverage inherited by the product name ("Basis is NSF Certified for Sport").
MATCH (x:Product {uid: 'hu:product:elysium-basis'}), (l:CertificationListing {uid: 'hu:cert-listing:nsfsport-1786167'})
MERGE (x)-[r:CERTIFIED_UNDER]->(l)
SET r.derivationRule = 'naive:trade-name-match', r.derivedAt = datetime('2026-10-04T04:00:00Z');

// N04 -> V-W12-06: a FACILITY programme scope covering a lot.
MATCH (s:CertificationScope {uid: 'hu:cert-scope:synthetic-nsf-455-2-synthetic-plant'}), (x:ProductLot {uid: 'hu:lot:elysium-basis-70579'}),
      (who:Organization {uid: 'hu:org:nsf-international'}), (loc:SourceLocator {uid: 'hu:locator:synthetic-nsf-455-2-scope'})
MERGE (a:Assertion {uid: 'hu:assertion:w12-neg-455-2-covers-lot'})
SET a.predicate = 'COVERS', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-04T04:00:00Z'), a.polarity = 'POSITIVE', a.privacyClass = 'PUBLIC',
    a.contentHash = 'sha256:9e1d2c3b4a5f60718293a4b5c6d7e8f90112233445566778899aabbccddeeff0', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(x)
MERGE (a)-[:ASSERTED_BY]->(who)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (s)-[r:COVERS {relationshipUid: 'hu:rel:w12-neg-455-2-covers-lot'}]->(x)
SET r.assertionUid = 'hu:assertion:w12-neg-455-2-covers-lot', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// N05 -> V-W12-12, V-W12-03: a value invented from "Conforms to internal specs" (250 mg copied from the specification).
MATCH (loc:SourceLocator {uid: 'hu:locator:elysium-basis-lot-p098-01-nr'})
MERGE (m:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-invented-from-summary'})
SET m.id = 'w12-neg-invented-from-summary', m.artifactType = 'MEASURED_RESULT', m.analyte = 'Nicotinamide Riboside Chloride', m.value = 250.0, m.unitCode = 'mg',
    m.qualifier = 'NUMERIC', m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T04:00:00Z'), m.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (m)-[:SUPPORTED_BY]->(loc);

// N06 -> V-W12-01 (ISSUER_COUNT_0, NO_CERTIFIED_EXECUTION, NO_REPORT_NUMBER_OR_DATE): the lot page promoted to a "COA".
MATCH (lot:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'}), (who:Organization {uid: 'hu:org:elysium-health-inc'}), (loc:SourceLocator {uid: 'hu:locator:elysium-basis-lot-p098-01-header'})
MERGE (c:CertificateOfAnalysis:InformationArtifact {uid: 'hu:coa:w12-neg-lot-page-as-coa'})
SET c.id = 'w12-neg-lot-page-as-coa', c.artifactType = 'CERTIFICATE_OF_ANALYSIS', c.documentTitleVerbatim = 'Label Claims & Testing', c.signatureEvidence = 'NONE_IN_COMPLETE_CAPTURE',
    c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T04:00:00Z'), c.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:w12-neg-lot-page-certifies'})
SET a.predicate = 'CERTIFIES_RESULTS_FOR', a.status = 'EXTRACTED', a.recordedAt = datetime('2026-10-04T04:00:00Z'), a.polarity = 'POSITIVE', a.privacyClass = 'PUBLIC',
    a.contentHash = 'sha256:1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f809', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN'
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:HAS_OBJECT]->(lot)
MERGE (a)-[:ASSERTED_BY]->(who)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (c)-[r:CERTIFIES_RESULTS_FOR {relationshipUid: 'hu:rel:w12-neg-lot-page-certifies'}]->(lot)
SET r.assertionUid = 'hu:assertion:w12-neg-lot-page-certifies', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// N07 -> V-W12-02: one node carrying both document kinds.
MERGE (n:LotTestSummary:CertificateOfAnalysis:InformationArtifact {uid: 'hu:lot-test-summary:w12-neg-collapsed'})
SET n.id = 'w12-neg-collapsed', n.artifactType = 'LOT_TEST_SUMMARY', n.signatureEvidence = 'NOT_CAPTURED', n.privacyClass = 'PUBLIC',
    n.createdAt = datetime('2026-10-04T04:00:00Z'), n.updatedAt = datetime('2026-10-04T04:00:00Z');

// N08 -> V-W12-04 (NUMERIC_WITHOUT_VALUE) and V-W12-04 (VALUE_WITH_NON_NUMERIC_QUALIFIER: "ND" stored as 0).
MATCH (x:TestExecution {uid: 'hu:test-execution:synthetic-lab-z-70579-ecoli'}), (loc:SourceLocator {uid: 'hu:locator:synthetic-lab-z-70579-ecoli'})
MERGE (m:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-nd-as-zero'})
SET m.id = 'w12-neg-nd-as-zero', m.artifactType = 'MEASURED_RESULT', m.analyte = 'E. coli', m.value = 0.0, m.unitCode = '[CFU]/g', m.qualifier = 'BELOW_DETECTION',
    m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T04:00:00Z'), m.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (x)-[:PRODUCED_RESULT]->(m)
MERGE (m)-[:SUPPORTED_BY]->(loc)
MERGE (q:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-quantified-null'})
SET q.id = 'w12-neg-quantified-null', q.artifactType = 'MEASURED_RESULT', q.analyte = 'E. coli', q.unitCode = '[CFU]/g', q.qualifier = 'NUMERIC',
    q.privacyClass = 'PUBLIC', q.createdAt = datetime('2026-10-04T04:00:00Z'), q.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (x)-[:PRODUCED_RESULT]->(q)
MERGE (q)-[:SUPPORTED_BY]->(loc);

// N09 -> V-W12-05 (EVALUATED_WITHOUT_EXACTLY_ONE_RESULT, EVALUATED_WITHOUT_DECISION_RULE): an "evaluated" verdict with no value.
MATCH (c:SpecificationCriterion {uid: 'hu:spec-criterion:basis-internal-heavy-metals-nmt-0-5'}), (lot:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'})
MERGE (p:PassFailInterpretation:EvidenceAssessment {uid: 'hu:pass-fail:w12-neg-evaluated-without-result'})
SET p.id = 'w12-neg-evaluated-without-result', p.assessmentType = 'PASS_FAIL_INTERPRETATION', p.methodVersion = 'w12-pass-fail-evaluator/1', p.status = 'ACCEPTED',
    p.recordedAt = datetime('2026-10-04T04:00:00Z'), p.verdict = 'CONFORMS', p.verdictBasis = 'EVALUATED_FROM_RESULT', p.privacyClass = 'PUBLIC',
    p.createdAt = datetime('2026-10-04T04:00:00Z'), p.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (p)-[:APPLIES_CRITERION]->(c)
MERGE (p)-[:INTERPRETS_TESTING_OF]->(lot);

// N10 -> V-W12-11: an 18-month stability result judged against the RELEASE-only limit.
MATCH (m:MeasuredResult {uid: 'hu:measured-result:synthetic-lab-z-70064-m18-potency'}), (c:SpecificationCriterion {uid: 'hu:spec-criterion:synthetic-basis-nrcl-release-nlt-275'}),
      (x:TestExecution {uid: 'hu:test-execution:synthetic-lab-z-70064-m18-potency'})
MERGE (p:PassFailInterpretation:EvidenceAssessment {uid: 'hu:pass-fail:w12-neg-stability-vs-release'})
SET p.id = 'w12-neg-stability-vs-release', p.assessmentType = 'PASS_FAIL_INTERPRETATION', p.methodVersion = 'w12-pass-fail-evaluator/1', p.status = 'ACCEPTED',
    p.recordedAt = datetime('2026-10-04T04:00:00Z'), p.verdict = 'DOES_NOT_CONFORM', p.verdictBasis = 'EVALUATED_FROM_RESULT', p.decisionRule = 'SIMPLE_ACCEPTANCE',
    p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T04:00:00Z'), p.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (p)-[:INTERPRETS_RESULT]->(m)
MERGE (p)-[:APPLIES_CRITERION]->(c)
MERGE (p)-[:INTERPRETS_TESTING_OF]->(x);

// N11 -> V-W12-10 and V-503: a listing scope "ended" because a later capture no longer showed it (observation-only end).
MATCH (l:CertificationListing {uid: 'hu:cert-listing:nsfsport-1463170'})-[h:HAS_CERTIFICATION_SCOPE {relationshipUid: 'hu:rel:w12-has-scope-1463170-v1'}]->(:CertificationScope)
SET h.validTo = datetime('2026-10-04T00:00:00Z'), h.validToPrecision = 'DAY', h.validToBasis = 'OBSERVATION_ONLY';

// N12 -> V-011, V-W12-02: a label declaration stored as a measured result.
MERGE (n:LabelDeclaration:MeasuredResult:InformationArtifact {uid: 'hu:label-declaration:w12-neg-declared-as-measured'})
SET n.artifactType = 'LABEL_DECLARATION', n.verbatimText = 'Nicotinamide Riboside Chloride 250 mg', n.analyte = 'NR', n.value = 250.0, n.unitCode = 'mg', n.qualifier = 'NUMERIC',
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T04:00:00Z'), n.updatedAt = datetime('2026-10-04T04:00:00Z');

// N13 -> V-008 and V-W12-01: a certificate that reports on nothing.
MERGE (c:CertificateOfAnalysis:InformationArtifact {uid: 'hu:coa:w12-neg-orphan'})
SET c.id = 'w12-neg-orphan', c.artifactType = 'CERTIFICATE_OF_ANALYSIS', c.certificateNumber = 'NEG-ORPHAN-00', c.signatureEvidence = 'NOT_CAPTURED', c.privacyClass = 'PUBLIC',
    c.createdAt = datetime('2026-10-04T04:00:00Z'), c.updatedAt = datetime('2026-10-04T04:00:00Z');

// N14 -> V-113 and V-114: "the lot I bought" written into the shared graph as a relationship in both directions.
MATCH (lot:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'})
MERGE (p:PrivateRecord {uid: 'hu:private-purchase:w12-neg-person-bought-lot'})
SET p.privacyClass = 'private-personal', p.createdAt = datetime('2026-10-04T04:00:00Z')
MERGE (p)-[:RECEIVED_LOT]->(lot)
MERGE (lot)-[:PURCHASED_BY]->(p);

// N15 -> V-124 and V-W12-04 (QUALIFIER_MISSING): a result with neither value nor qualifier.
MATCH (x:TestExecution {uid: 'hu:test-execution:synthetic-lab-z-70579-ecoli'}), (loc:SourceLocator {uid: 'hu:locator:synthetic-lab-z-70579-ecoli'})
MERGE (m:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-no-qualifier'})
SET m.id = 'w12-neg-no-qualifier', m.artifactType = 'MEASURED_RESULT', m.analyte = 'E. coli', m.privacyClass = 'PUBLIC',
    m.createdAt = datetime('2026-10-04T04:00:00Z'), m.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (x)-[:PRODUCED_RESULT]->(m)
MERGE (m)-[:SUPPORTED_BY]->(loc);

// N16 -> V-W12-09: the lot-unknown survey result judged as a result for lot P098-01.
MATCH (m:MeasuredResult {uid: 'hu:measured-result:niagen-survey-elysium-basis-nr'}), (c:SpecificationCriterion {uid: 'hu:spec-criterion:synthetic-lz-basis-nrcl-nlt-250-per-serving'}),
      (lot:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'})
MERGE (p:PassFailInterpretation:EvidenceAssessment {uid: 'hu:pass-fail:w12-neg-survey-attributed-to-lot'})
SET p.id = 'w12-neg-survey-attributed-to-lot', p.assessmentType = 'PASS_FAIL_INTERPRETATION', p.methodVersion = 'w12-pass-fail-evaluator/1', p.status = 'ACCEPTED',
    p.recordedAt = datetime('2026-10-04T04:00:00Z'), p.verdict = 'CONFORMS', p.verdictBasis = 'EVALUATED_FROM_RESULT', p.decisionRule = 'SIMPLE_ACCEPTANCE',
    p.privacyClass = 'PUBLIC', p.createdAt = datetime('2026-10-04T04:00:00Z'), p.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (p)-[:INTERPRETS_RESULT]->(m)
MERGE (p)-[:APPLIES_CRITERION]->(c)
MERGE (p)-[:INTERPRETS_TESTING_OF]->(lot);

// N17 -> V-W12-08: a guessed lot added beside the unit actually tested.
MATCH (s:TestSample {uid: 'hu:test-sample:niagen-survey-elysium-basis'}), (lot:ProductLot {uid: 'hu:lot:elysium-basis-p098-01'})
MERGE (s)-[r:SAMPLE_FROM {relationshipUid: 'hu:rel:w12-neg-guessed-lot'}]->(lot)
SET r.assertionUid = 'hu:assertion:w12-sample-from-survey-unit', r.recordedFrom = datetime('2026-10-04T04:00:00Z'), r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';

// N18 -> V-W12-05 (NOT_REPORTED_VERDICT_LINKED_TO_A_VALUE): the lead "Pass" linked to an invented lead value.
MATCH (p:PassFailInterpretation {uid: 'hu:pass-fail:truniagen-t25189001-lead-source'}), (x:TestExecution {uid: 'hu:test-execution:truniagen-t25189001-lead'}),
      (loc:SourceLocator {uid: 'hu:locator:truniagen-coa-t25189001-lead'})
MERGE (m:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-lead-from-pass'})
SET m.id = 'w12-neg-lead-from-pass', m.artifactType = 'MEASURED_RESULT', m.analyte = 'Lead', m.value = 0.5, m.unitCode = '[ppm]', m.qualifier = 'NUMERIC',
    m.privacyClass = 'PUBLIC', m.createdAt = datetime('2026-10-04T04:00:00Z'), m.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (x)-[:PRODUCED_RESULT]->(m)
MERGE (m)-[:SUPPORTED_BY]->(loc)
MERGE (p)-[:INTERPRETS_RESULT]->(m);

// N19 -> V-W12-04 (NOT_MEASURED_WRITTEN_AS_A_RESULT): "not measured" written as a result record for lot 70918.
MATCH (x:TestExecution {uid: 'hu:test-execution:synthetic-lab-z-70579-ecoli'}), (loc:SourceLocator {uid: 'hu:locator:synthetic-lab-z-70579-ecoli'})
MERGE (m:MeasuredResult:InformationArtifact {uid: 'hu:measured-result:w12-neg-not-measured-record'})
SET m.id = 'w12-neg-not-measured-record', m.artifactType = 'MEASURED_RESULT', m.analyte = 'E. coli', m.qualifier = 'NOT_MEASURED', m.privacyClass = 'PUBLIC',
    m.createdAt = datetime('2026-10-04T04:00:00Z'), m.updatedAt = datetime('2026-10-04T04:00:00Z')
MERGE (x)-[:PRODUCED_RESULT]->(m)
MERGE (m)-[:SUPPORTED_BY]->(loc);
