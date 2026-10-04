// W12 proposed validation queries V-W12-01 .. V-W12-13 (quality module). Zero rows = valid unless "(informational)".
// Run run-2026-10-04-fable51-01, worker W12 (Opus 5.5). Complements catalog V-008, V-009, V-011, V-124, V-332.
// status: executed on embedded Neo4j 5.26.31 Community against fixtures w12-00..w12-90 (zero rows except V-W12-13: 1
// informational row) and again after w12-negatives.cypher (expected rows listed per query in 06-fixtures-and-queries.md).

// V-W12-01: a CertificateOfAnalysis meets the classification minimum (proposed closure of OPEN-QUESTIONS P2 quality 1):
// exactly one issuer, a lot named directly or through certified executions, at least one certified execution, every
// certified execution has a method and an outcome (MeasuredResult or PassFailInterpretation) judged against a criterion,
// a report number or date, and a recorded signature evidence state.
MATCH (c:CertificateOfAnalysis)
OPTIONAL MATCH (c)-[:COA_ISSUED_BY]->(iss)
WITH c, count(iss) AS issuers
OPTIONAL MATCH (c)-[:CERTIFIES_RESULTS_FOR]->(x:TestExecution)
WITH c, issuers, collect(x) AS execs
WITH c, issuers, execs,
     (EXISTS { MATCH (c)-[:CERTIFIES_RESULTS_FOR]->(:ProductLot) }
      OR any(x IN execs WHERE EXISTS { MATCH (x)-[:TESTED_SAMPLE]->(:TestSample)-[:SAMPLE_FROM]->(:ProductLot) })) AS namesLot,
     [x IN execs WHERE NOT EXISTS { MATCH (x)-[:USED_METHOD]->(:TestMethod) }] AS noMethod,
     [x IN execs WHERE NOT EXISTS { MATCH (x)-[:PRODUCED_RESULT]->(:MeasuredResult)-[:EVALUATED_AGAINST]->(:SpecificationCriterion) }
                   AND NOT EXISTS { MATCH (:SpecificationCriterion)<-[:APPLIES_CRITERION]-(:PassFailInterpretation)-[:INTERPRETS_TESTING_OF]->(x) }] AS noJudgedOutcome
WITH c, [v IN [
  CASE WHEN issuers <> 1 THEN 'ISSUER_COUNT_' + toString(issuers) END,
  CASE WHEN NOT namesLot THEN 'NO_LOT' END,
  CASE WHEN size(execs) = 0 THEN 'NO_CERTIFIED_EXECUTION' END,
  CASE WHEN size(noMethod) > 0 THEN 'EXECUTION_WITHOUT_METHOD' END,
  CASE WHEN size(noJudgedOutcome) > 0 THEN 'EXECUTION_WITHOUT_JUDGED_OUTCOME' END,
  CASE WHEN c.certificateNumber IS NULL AND c.reportDate IS NULL THEN 'NO_REPORT_NUMBER_OR_DATE' END,
  CASE WHEN c.signatureEvidence IS NULL THEN 'SIGNATURE_EVIDENCE_MISSING' END
] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN c.uid AS certificate, violations;

// V-W12-02: quality identities never collapse onto one node (INV-006, INV-010).
MATCH (n)
WHERE (n:CertificateOfAnalysis AND n:LotTestSummary)
   OR (n:MeasuredResult AND (n:PassFailInterpretation OR n:SpecificationCriterion OR n:QuantityDeclaration OR n:LabelDeclaration))
   OR (n:ProductLot AND (n:ProductVariant OR n:PackageConfiguration OR n:IndividualUnit OR n:InventoryItem))
   OR (n:CertificationListing AND (n:CertificationScope OR n:RegulatoryStatus))
   OR (n:TestingLaboratory AND n:Facility)
RETURN n.uid AS collapsedQualityIdentity, labels(n) AS labels;

// V-W12-03: every MeasuredResult has exactly one producing TestExecution and at least one supporting locator
// (no unprovenanced value).
MATCH (m:MeasuredResult)
OPTIONAL MATCH (x:TestExecution)-[:PRODUCED_RESULT]->(m)
WITH m, count(x) AS producers, EXISTS { MATCH (m)-[:SUPPORTED_BY]->(:SourceLocator) } AS hasLocator
WHERE producers <> 1 OR NOT hasLocator
RETURN m.uid AS result, producers, hasLocator;

// V-W12-04: value and qualifier agree (INV-007). QUANTIFIED <=> value present; a non-value state never carries a number
// (an "ND" stored as 0 is the classic collapse); uncertainty needs a value and a unit and is positive; a qualitative
// outcome states its sample quantity.
MATCH (m:MeasuredResult)
WITH m, [v IN [
  CASE WHEN m.qualifier IS NULL THEN 'QUALIFIER_MISSING' END,
  CASE WHEN m.qualifier IS NOT NULL AND NOT m.qualifier IN ['QUANTIFIED', 'NOT_DETECTED', 'DETECTED_NOT_QUANTIFIED', 'BELOW_REPORTING_LIMIT',
                                                             'ABOVE_QUANTITATION_RANGE', 'QUALITATIVE_ABSENT', 'QUALITATIVE_PRESENT'] THEN 'UNKNOWN_QUALIFIER' END,
  CASE WHEN m.qualifier = 'QUANTIFIED' AND m.value IS NULL THEN 'QUANTIFIED_WITHOUT_VALUE' END,
  CASE WHEN m.qualifier <> 'QUANTIFIED' AND m.value IS NOT NULL THEN 'VALUE_WITH_NON_QUANTIFIED_QUALIFIER' END,
  CASE WHEN m.value IS NOT NULL AND m.unitCode IS NULL THEN 'VALUE_WITHOUT_UNIT' END,
  CASE WHEN m.uncertainty IS NOT NULL AND (m.value IS NULL OR m.unitCode IS NULL) THEN 'UNCERTAINTY_WITHOUT_VALUE_OR_UNIT' END,
  CASE WHEN m.uncertainty IS NOT NULL AND m.uncertainty <= 0 THEN 'NON_POSITIVE_UNCERTAINTY' END,
  CASE WHEN m.qualifier IN ['QUALITATIVE_ABSENT', 'QUALITATIVE_PRESENT'] AND m.sampleQuantity IS NULL THEN 'QUALITATIVE_WITHOUT_SAMPLE_QUANTITY' END
] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN m.uid AS result, violations;

// V-W12-05: PassFailInterpretation shape. Exactly one criterion and one testing target; EVALUATED_FROM_RESULT has exactly
// one result and a decision rule; SOURCE_STATED cites its capturing CONFORMS_TO_SPECIFICATION assertion and a locator,
// and a NOT_REPORTED verdict links no MeasuredResult (a pass never becomes a value).
MATCH (p:PassFailInterpretation)
OPTIONAL MATCH (p)-[:APPLIES_CRITERION]->(c:SpecificationCriterion)
WITH p, count(c) AS criteria
OPTIONAL MATCH (p)-[:INTERPRETS_TESTING_OF]->(t)
WITH p, criteria, count(t) AS targets
OPTIONAL MATCH (p)-[:INTERPRETS_RESULT]->(m:MeasuredResult)
WITH p, criteria, targets, count(m) AS results
OPTIONAL MATCH (a:Assertion {uid: p.basisAssertionUid})
WITH p, [v IN [
  CASE WHEN criteria <> 1 THEN 'CRITERION_COUNT_' + toString(criteria) END,
  CASE WHEN targets <> 1 THEN 'TARGET_COUNT_' + toString(targets) END,
  CASE WHEN p.verdictBasis = 'EVALUATED_FROM_RESULT' AND results <> 1 THEN 'EVALUATED_WITHOUT_EXACTLY_ONE_RESULT' END,
  CASE WHEN p.verdictBasis = 'EVALUATED_FROM_RESULT' AND p.decisionRule IS NULL THEN 'EVALUATED_WITHOUT_DECISION_RULE' END,
  CASE WHEN p.verdictBasis = 'SOURCE_STATED' AND (a IS NULL OR a.predicate <> 'CONFORMS_TO_SPECIFICATION') THEN 'SOURCE_STATED_WITHOUT_CAPTURING_ASSERTION' END,
  CASE WHEN p.verdictBasis = 'SOURCE_STATED' AND NOT EXISTS { MATCH (p)-[:SUPPORTED_BY]->(:SourceLocator) } THEN 'SOURCE_STATED_WITHOUT_LOCATOR' END,
  CASE WHEN p.verdictBasis = 'SOURCE_STATED' AND p.resultValueReported = 'NOT_REPORTED' AND results > 0 THEN 'NOT_REPORTED_VERDICT_LINKED_TO_A_VALUE' END,
  CASE WHEN p.verdictBasis IS NULL OR p.verdict IS NULL THEN 'VERDICT_OR_BASIS_MISSING' END
] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN p.uid AS interpretation, violations;

// V-W12-06: a programme's scopes cover only the kind of object it certifies. A FACILITY programme (NSF/ANSI 455-2 GMP)
// covers only Facility; a LOT programme only ProductLot or TradeItemIdentifier; facility GMP never covers a product.
MATCH (prog:CertificationProgram)-[:PROGRAM_HAS_LISTING]->(l:CertificationListing)-[:HAS_CERTIFICATION_SCOPE]->(s:CertificationScope)-[:COVERS]->(x)
WITH prog, l, s, x,
     CASE prog.certifiedObjectKind
       WHEN 'FACILITY' THEN x:Facility
       WHEN 'LABORATORY' THEN x:TestingLaboratory
       WHEN 'LOT' THEN (x:ProductLot OR x:TradeItemIdentifier)
       WHEN 'PRODUCT' THEN (x:Product OR x:ProductVariant OR x:ProductLot OR x:TradeItemIdentifier)
       WHEN 'INGREDIENT_MATERIAL' THEN x:IngredientMaterial
       ELSE false END AS fits
WHERE NOT fits
RETURN prog.uid AS program, prog.certifiedObjectKind AS certifies, l.uid AS listing, x.uid AS coveredItem, labels(x) AS coveredLabels;

// V-W12-07: CERTIFIED_UNDER is derived only by rule w12-certified-under/v1 from a COVERS assertion whose subject is a
// scope of that listing and whose object is the item itself (strengthens V-332 and V-112); never from a FACILITY programme.
MATCH (x)-[r:CERTIFIED_UNDER]->(l:CertificationListing)
WITH x, r, l, [u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS {
        MATCH (a:Assertion {uid: u, predicate: 'COVERS'})-[:HAS_OBJECT]->(x)
        MATCH (a)-[:HAS_SUBJECT]->(:CertificationScope)<-[:HAS_CERTIFICATION_SCOPE]-(l) }] AS validInputs
WITH x, r, l, validInputs, [v IN [
  CASE WHEN r.derivationRule IS NULL OR NOT r.derivationRule STARTS WITH 'w12-certified-under/' THEN 'UNKNOWN_DERIVATION_RULE' END,
  CASE WHEN size(validInputs) = 0 THEN 'NO_DIRECT_COVERS_INPUT' END,
  CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN 'PROJECTION_CITATION_ON_MULTI_HOP_EDGE' END,
  CASE WHEN EXISTS { MATCH (l)<-[:PROGRAM_HAS_LISTING]-(:CertificationProgram {certifiedObjectKind: 'FACILITY'}) } THEN 'FACILITY_PROGRAMME_PROJECTED_TO_ITEM' END
] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN x.uid AS item, l.uid AS listing, violations;

// V-W12-08: a TestSample comes from exactly one lot, unit or material; a TestExecution tests exactly one sample.
// A guessed lot added beside the unit actually tested is a violation, not an enrichment.
MATCH (s:TestSample)
OPTIONAL MATCH (s)-[:SAMPLE_FROM]->(t)
WITH s, count(t) AS n
WHERE n <> 1
RETURN 'SAMPLE_SOURCE_COUNT' AS violation, s.uid AS item, n AS count
UNION
MATCH (x:TestExecution)
OPTIONAL MATCH (x)-[:TESTED_SAMPLE]->(s:TestSample)
WITH x, count(s) AS n
WHERE n <> 1
RETURN 'EXECUTION_SAMPLE_COUNT' AS violation, x.uid AS item, n AS count;

// V-W12-09: what is judged is what was tested. An interpretation's target equals the execution that produced its result,
// or the lot that execution's sample came from; a COA certifies executions only on samples of the lots it names.
MATCH (p:PassFailInterpretation)-[:INTERPRETS_RESULT]->(:MeasuredResult)<-[:PRODUCED_RESULT]-(x:TestExecution)
MATCH (p)-[:INTERPRETS_TESTING_OF]->(t)
WHERE (t:TestExecution AND t <> x)
   OR (t:ProductLot AND NOT EXISTS { MATCH (x)-[:TESTED_SAMPLE]->(:TestSample)-[:SAMPLE_FROM]->(t) })
RETURN 'INTERPRETATION_TARGET_NOT_TESTED' AS violation, p.uid AS item, t.uid AS target
UNION
MATCH (c:CertificateOfAnalysis)-[:CERTIFIES_RESULTS_FOR]->(x:TestExecution)-[:TESTED_SAMPLE]->(:TestSample)-[:SAMPLE_FROM]->(src)
MATCH (c)-[:CERTIFIES_RESULTS_FOR]->(lot:ProductLot)
WHERE src <> lot
RETURN 'COA_EXECUTION_ON_OTHER_LOT' AS violation, c.uid AS item, x.uid AS target;

// V-W12-10: scope attachments are well-formed bitemporal episodes, and a valid-time end comes only from the certifier
// (a listing missing from a later capture is not withdrawn).
MATCH (:CertificationListing)-[h:HAS_CERTIFICATION_SCOPE]->(s:CertificationScope)
WHERE h.relationshipUid IS NULL OR h.recordedFrom IS NULL OR h.validFromBasis IS NULL OR h.validToBasis IS NULL
   OR (h.validTo IS NOT NULL AND h.validToBasis <> 'STATED_BY_SOURCE')
RETURN s.uid AS scope, h.relationshipUid AS episode, h.validTo AS validTo, h.validToBasis AS validToBasis;

// V-W12-11: comparable inputs only. An evaluated verdict other than NOT_EVALUABLE needs a result and criterion with the same
// unit, quantity basis and mass basis, and a stability (shelf-life) result is never judged against a release-only criterion.
MATCH (p:PassFailInterpretation {verdictBasis: 'EVALUATED_FROM_RESULT'})-[:APPLIES_CRITERION]->(c:SpecificationCriterion),
      (p)-[:INTERPRETS_RESULT]->(m:MeasuredResult)<-[:PRODUCED_RESULT]-(x:TestExecution)
WHERE p.verdict <> 'NOT_EVALUABLE'
  AND ( (x.testPurpose = 'STABILITY' AND c.criterionPurpose = 'RELEASE')
     OR coalesce(m.unitCode, '-') <> coalesce(c.unitCode, '-')
     OR coalesce(m.quantityBasis, '-') <> coalesce(c.quantityBasis, '-')
     OR (m.massBasis IS NOT NULL AND c.massBasis IS NOT NULL AND m.massBasis <> c.massBasis)
     OR m.massBasis = 'UNSPECIFIED' )
RETURN p.uid AS interpretation, x.testPurpose AS testPurpose, c.criterionPurpose AS criterionPurpose,
       m.unitCode AS resultUnit, c.unitCode AS criterionUnit, m.quantityBasis AS resultBasis, c.quantityBasis AS criterionBasis;

// V-W12-12: no value from a summary. A MeasuredResult whose every supporting locator lies on a snapshot that backs a
// LotTestSummary (and no CertificateOfAnalysis) was invented from a pass statement ("Conforms to internal specs").
MATCH (m:MeasuredResult)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WITH m, collect(DISTINCT sn) AS snaps
WHERE all(sn IN snaps WHERE EXISTS { MATCH (:LotTestSummary)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn) }
                        AND NOT EXISTS { MATCH (:CertificateOfAnalysis)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn) })
RETURN m.uid AS valueFromSummary;

// V-W12-13 (informational): identifier values printed in a scope that no COVERS edge resolves (for example NSF's
// "R1110-01" versus Elysium's "R110-01"). They are covered by nothing until a resolution is accepted.
MATCH (s:CertificationScope)
UNWIND coalesce(s.coveredIdentifierValues, []) AS printed
WITH s, printed
WHERE NOT EXISTS { MATCH (s)-[:COVERS]->(l:ProductLot) WHERE l.lotCode = printed }
  AND NOT EXISTS { MATCH (s)-[:COVERS]->(t:TradeItemIdentifier) WHERE t.value = printed }
RETURN s.uid AS scope, printed AS unresolvedPrintedValue;
