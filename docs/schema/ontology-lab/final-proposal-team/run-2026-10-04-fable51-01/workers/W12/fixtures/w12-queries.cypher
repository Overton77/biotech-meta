// W12 competency-question queries (run with --params fixtures/w12-query-params.json after w12-00..w12-90).
// Run run-2026-10-04-fable51-01, worker W12 (Opus 5.5). Expected rows are in 06-fixtures-and-queries.md.
// status: executed on embedded Neo4j 5.26.31 Community, 2026-10-04.

// Q-PF-03a (CQ-PF-03, Essential): what each certification listing covers, by covered kind, current recorded episode only.
MATCH (prog:CertificationProgram)-[:PROGRAM_HAS_LISTING]->(l:CertificationListing)-[h:HAS_CERTIFICATION_SCOPE]->(s:CertificationScope)
WHERE h.recordedTo IS NULL
OPTIONAL MATCH (s)-[:COVERS]->(x)
WITH prog, l, s, x, [lab IN labels(x) WHERE lab IN ['ProductLot', 'Product', 'ProductVariant', 'Facility', 'TradeItemIdentifier', 'TestingLaboratory']][0] AS coveredKind
RETURN prog.name AS program, prog.certifiedObjectKind AS certifies, coalesce(l.listingId, l.uid) AS listing, s.facilityQualifierText AS facilityQualifier,
       coveredKind, collect(coalesce(x.lotCode, x.name)) AS covered, s.coveredIdentifierValues AS printedValues
ORDER BY program, listing;

// Q-PF-03b (CQ-PF-03): for each item, which certification attaches at its own level and which test documents name it.
UNWIND $items AS itemUid
MATCH (x {uid: itemUid})
OPTIONAL MATCH (x)-[:CERTIFIED_UNDER]->(l:CertificationListing)<-[:PROGRAM_HAS_LISTING]-(p:CertificationProgram)
WITH x, itemUid, collect(DISTINCT p.name + ' #' + coalesce(l.listingId, 'synthetic')) AS certifiedUnder
OPTIONAL MATCH (s:CertificationScope)-[:COVERS]->(x)
OPTIONAL MATCH (s)<-[:HAS_CERTIFICATION_SCOPE]-(:CertificationListing)<-[:PROGRAM_HAS_LISTING]-(pc:CertificationProgram)
WITH x, itemUid, certifiedUnder, collect(DISTINCT pc.standard) AS directlyCoveredBy
OPTIONAL MATCH (x)<-[:SUMMARIZES_TESTING|CERTIFIES_RESULTS_FOR]-(doc)
RETURN itemUid, [lab IN labels(x) WHERE NOT lab IN ['Entity']][0] AS kind, certifiedUnder, directlyCoveredBy,
       collect(DISTINCT [lab IN labels(doc) WHERE lab IN ['CertificateOfAnalysis', 'LotTestSummary']][0] + ' ' + coalesce(doc.certificateNumber, doc.title, '')) AS testDocuments
ORDER BY itemUid;

// Q-MF-06 (CQ-MF-06, Foundational): quality signals for a facility and for an organization, kept apart.
MATCH (f:Facility {uid: $facilityUid})
OPTIONAL MATCH (f)<-[:COVERS]-(:CertificationScope)<-[:HAS_CERTIFICATION_SCOPE]-(:CertificationListing)<-[:PROGRAM_HAS_LISTING]-(p:CertificationProgram)
OPTIONAL MATCH (rs:RegulatoryStatus)-[:STATUS_OF]->(f)
WITH f, collect(DISTINCT p.standard) AS gmpCertifications, collect(DISTINCT rs.statusKind) AS registrations
OPTIONAL MATCH (org:Organization {uid: $organizationUid})<-[:HAS_SUBJECT]-(a:Assertion {predicate: 'CLAIMS_CGMP_COMPLIANCE'})
RETURN f.name AS facility, gmpCertifications, registrations, collect(a.valueString) AS organizationCgmpClaims, 'NOT_CAPTURED (inspections are expansion)' AS inspections,
       EXISTS { MATCH (f)<-[:COVERS]-(:CertificationScope)<-[:HAS_CERTIFICATION_SCOPE]-(:CertificationListing)<-[:CERTIFIED_UNDER]-() } AS facilityCertificationProjectedToItems;

// Q-AX-19-early (CQ-AX-19, Expansion): for the lot I hold (uid passed in from the private store; nothing private is
// written), measured values with uncertainty and laboratory context versus the label declaration, as known at
// $recordedAsOfEarly. Results are "known" once their supporting snapshot was retrieved and "current" unless a source
// revision event recorded by then replaced that snapshot.
MATCH (lot:ProductLot {uid: $lotUid})-[:LOT_OF]->(v:ProductVariant)
MATCH (lot)<-[:SAMPLE_FROM]-(:TestSample)<-[:TESTED_SAMPLE]-(x:TestExecution)-[:PRODUCED_RESULT]->(m:MeasuredResult)
WHERE m.analyte =~ $analyteRegex
MATCH (m)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WITH lot, v, x, m, collect(sn) AS snaps, datetime($recordedAsOfEarly) AS asOf
WHERE any(sn IN snaps WHERE sn.retrievedAt <= asOf)
WITH lot, v, x, m, asOf,
     all(sn IN snaps WHERE EXISTS { MATCH (ev:SourceRevisionEvent)-[:PRIOR_SNAPSHOT]->(sn) WHERE ev.recordedAt <= asOf }) AS replaced
WHERE NOT replaced
OPTIONAL MATCH (x)-[:PERFORMED_BY_LAB]->(lab:TestingLaboratory)
OPTIONAL MATCH (lab)-[:AFFILIATED_WITH]->(aff:Organization)
OPTIONAL MATCH (lab)<-[:COVERS]-(:CertificationScope)<-[:HAS_CERTIFICATION_SCOPE]-(acc:CertificationListing)<-[:PROGRAM_HAS_LISTING]-(:CertificationProgram {certifiedObjectKind: 'LABORATORY'})
OPTIONAL MATCH (v)<-[:LABEL_FOR]-(:LabelSnapshot)-[:HAS_DECLARATION]->(:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(q:QuantityDeclaration)
WITH lot, x, m, lab, collect(DISTINCT aff.name) AS labAffiliations, count(DISTINCT acc) > 0 AS labAccreditationListed, q,
     (q IS NOT NULL AND m.quantityBasis = q.basis AND m.amountReferent = q.amountReferent AND m.massBasis IN ['SALT_FORM', 'MATERIAL_AS_IS']) AS comparable
RETURN lot.lotCode AS lot, m.value AS measured, m.uncertainty AS expandedU, m.coverageFactor AS k, m.unitCode AS unit, x.testPurpose AS purpose,
       coalesce(lab.name, 'NOT_STATED') AS laboratory, labAffiliations, labAccreditationListed, q.value AS declared, q.unitCode AS declaredUnit, comparable,
       CASE WHEN NOT comparable THEN 'NOT_COMPARABLE'
            WHEN m.uncertainty IS NULL THEN CASE WHEN m.value >= q.value THEN 'AT_OR_ABOVE_DECLARED_NO_UNCERTAINTY' ELSE 'BELOW_DECLARED_NO_UNCERTAINTY' END
            WHEN m.value - m.uncertainty > q.value THEN 'ABOVE_DECLARED'
            WHEN m.value + m.uncertainty < q.value THEN 'BELOW_DECLARED'
            ELSE 'WITHIN_UNCERTAINTY_OF_DECLARED' END AS position
ORDER BY measured;

// Q-AX-19-late: the same question as known at $recordedAsOfLate (after the rev 01 correction was recorded).
MATCH (lot:ProductLot {uid: $lotUid})-[:LOT_OF]->(v:ProductVariant)
MATCH (lot)<-[:SAMPLE_FROM]-(:TestSample)<-[:TESTED_SAMPLE]-(x:TestExecution)-[:PRODUCED_RESULT]->(m:MeasuredResult)
WHERE m.analyte =~ $analyteRegex
MATCH (m)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WITH lot, v, x, m, collect(sn) AS snaps, datetime($recordedAsOfLate) AS asOf
WHERE any(sn IN snaps WHERE sn.retrievedAt <= asOf)
WITH lot, v, x, m, asOf,
     all(sn IN snaps WHERE EXISTS { MATCH (ev:SourceRevisionEvent)-[:PRIOR_SNAPSHOT]->(sn) WHERE ev.recordedAt <= asOf }) AS replaced
WHERE NOT replaced
OPTIONAL MATCH (v)<-[:LABEL_FOR]-(:LabelSnapshot)-[:HAS_DECLARATION]->(:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(q:QuantityDeclaration)
WITH lot, m, q, (q IS NOT NULL AND m.quantityBasis = q.basis AND m.amountReferent = q.amountReferent AND m.massBasis IN ['SALT_FORM', 'MATERIAL_AS_IS']) AS comparable
RETURN lot.lotCode AS lot, m.value AS measured, m.uncertainty AS expandedU, q.value AS declared, comparable,
       CASE WHEN NOT comparable THEN 'NOT_COMPARABLE'
            WHEN m.value - m.uncertainty > q.value THEN 'ABOVE_DECLARED'
            WHEN m.value + m.uncertainty < q.value THEN 'BELOW_DECLARED'
            ELSE 'WITHIN_UNCERTAINTY_OF_DECLARED' END AS position;

// Q-AX-19-unattributed: results for the same variant whose sample lot is unknown. They are reported beside, never as,
// results for the lot in hand.
MATCH (lot:ProductLot {uid: $lotUid})-[:LOT_OF]->(v:ProductVariant)
MATCH (v)<-[:INVENTORY_INSTANCE_OF]-(u:IndividualUnit)<-[:SAMPLE_FROM]-(:TestSample)<-[:TESTED_SAMPLE]-(x:TestExecution)-[:PRODUCED_RESULT]->(m:MeasuredResult)
WHERE NOT EXISTS { MATCH (u)-[:UNIT_FROM_LOT]->(:ProductLot) }
OPTIONAL MATCH (m)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
RETURN m.analyte AS analyte, m.value AS measured, m.unitCode AS unit, m.massBasis AS massBasis, m.amountReferent AS amountReferent,
       x.testPurpose AS purpose, x.performerStatementVerbatim AS performer, collect(DISTINCT src.title) AS sources, 'LOT_UNKNOWN_NOT_ATTRIBUTED' AS attribution;

// Q-QA-C01 (candidate): is each test document a COA or a lot test summary, and which COA elements does it carry?
MATCH (d) WHERE d:CertificateOfAnalysis OR d:LotTestSummary
OPTIONAL MATCH (d)-[:CERTIFIES_RESULTS_FOR|SUMMARIZES_TESTING]->(lot:ProductLot)
OPTIONAL MATCH (d)-[:COA_ISSUED_BY]->(iss)
OPTIONAL MATCH (d)-[:CERTIFIES_RESULTS_FOR|SUMMARIZES_TESTING]->(x:TestExecution)
WITH d, collect(DISTINCT lot.lotCode) AS lots, collect(DISTINCT iss.name) AS issuers, collect(DISTINCT x) AS execs
RETURN [lab IN labels(d) WHERE lab IN ['CertificateOfAnalysis', 'LotTestSummary']][0] AS kind, coalesce(d.certificateNumber, d.title) AS document, lots, issuers,
       size(execs) AS executions,
       size([x IN execs WHERE EXISTS { MATCH (x)-[:USED_METHOD]->(:TestMethod) }]) AS withMethod,
       size([x IN execs WHERE EXISTS { MATCH (x)-[:PERFORMED_BY_LAB]->(:TestingLaboratory) }]) AS withNamedLab,
       size([x IN execs WHERE EXISTS { MATCH (x)-[:PRODUCED_RESULT]->(:MeasuredResult) }]) AS withValue,
       COUNT { MATCH (d)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(:PassFailInterpretation {verdictBasis: 'SOURCE_STATED', resultValueReported: 'NOT_REPORTED'}) } AS passWithoutValue,
       d.signatureEvidence AS signature, d.reportDate AS reportDate
ORDER BY kind, document;

// Q-QA-C02 (candidate; CQ-AX-04 quality part): the state of one analyte across lots: measured, not detected, qualitatively
// absent, reported only as a pass, or not measured in any captured record.
UNWIND $lots AS lotUid
MATCH (lot:ProductLot {uid: lotUid})
OPTIONAL MATCH (lot)<-[:SAMPLE_FROM]-(:TestSample)<-[:TESTED_SAMPLE]-(:TestExecution)-[:PRODUCED_RESULT]->(m:MeasuredResult {analyte: $analyte})
WITH lot, collect(DISTINCT m) AS ms
OPTIONAL MATCH (lot)<-[:SAMPLE_FROM]-(:TestSample)<-[:TESTED_SAMPLE]-(:TestExecution)<-[:INTERPRETS_TESTING_OF]-(p:PassFailInterpretation {resultValueReported: 'NOT_REPORTED'})-[:APPLIES_CRITERION]->(:SpecificationCriterion {analyte: $analyte})
WITH lot, ms, collect(DISTINCT p) AS ps
OPTIONAL MATCH (lot)<-[:INTERPRETS_TESTING_OF]-(:PassFailInterpretation)-[:APPLIES_CRITERION]->(cg:SpecificationCriterion)
WHERE cg.analyte <> $analyte AND cg.analyte =~ '(?i).*organism.*'
WITH lot, ms, ps, collect(DISTINCT cg.analyte) AS groupCriteriaOnly
RETURN lot.lotCode AS lot,
       CASE WHEN size(ms) > 0 THEN [m IN ms | m.qualifier + coalesce(' LOD ' + toString(m.limitOfDetection) + ' ' + m.unitCode, '') + coalesce(' in ' + toString(m.sampleQuantity) + ' ' + m.sampleQuantityUnitCode, '')]
            WHEN size(ps) > 0 THEN ['NOT_REPORTED (source-stated ' + ps[0].verdict + ')']
            ELSE ['NOT_MEASURED_IN_CAPTURED_RECORDS'] END AS state,
       groupCriteriaOnly
ORDER BY lot;

// Q-QA-C03 (candidate): evaluated verdicts with the criterion's purpose and basis, the decision rule, and supersession.
MATCH (p:PassFailInterpretation {verdictBasis: 'EVALUATED_FROM_RESULT'})-[:APPLIES_CRITERION]->(c:SpecificationCriterion),
      (p)-[:INTERPRETS_RESULT]->(m:MeasuredResult)<-[:PRODUCED_RESULT]-(x:TestExecution)
OPTIONAL MATCH (newer:PassFailInterpretation)-[s:SUPERSEDES]->(p)
RETURN m.value AS value, m.uncertainty AS U, c.criterionText AS criterion, c.criterionPurpose AS purpose, c.criterionBasis AS basis, x.testPurpose AS testPurpose,
       p.decisionRule AS decisionRule, p.verdict AS verdict, p.status AS status, s.supersessionKind AS supersededBy
ORDER BY criterion, decisionRule, status;

// Q-QA-C04 (candidate): which lots a listing covered as recorded at two instants (late arrival of P120-01).
UNWIND [$recordedAsOfEarly, $recordedAsOfLate] AS asOfText
WITH datetime(asOfText) AS asOf
MATCH (l:CertificationListing {uid: $listingUid})-[h:HAS_CERTIFICATION_SCOPE]->(s:CertificationScope)-[c:COVERS]->(lot:ProductLot)
WHERE h.recordedFrom <= asOf AND (h.recordedTo IS NULL OR h.recordedTo > asOf)
  AND c.recordedFrom <= asOf AND (c.recordedTo IS NULL OR c.recordedTo > asOf)
WITH asOf, lot.lotCode AS code ORDER BY code
RETURN toString(asOf) AS recordedAsOf, collect(code) AS coveredLots;
