// W07 validation set (run-2026-10-04-fable51-01). Zero rows = valid unless marked informational.
// V-301a..V-313 are the catalog 0.2.0 queries copied verbatim from ../../../../../../neo4j/validation.cypher except
// V-313, whose value list is superseded by V-313r (contract B5: PrivacyClass {PUBLIC INTERNAL}; "synthetic" is fixture
// provenance). Proposed (W07, not yet in the catalog): V-302r, V-304r, V-303r, V-305c, V-313r, V-314, V-315, V-316, V-317, V-318.
// Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md for expected and observed rows).

// V-301a: an AssayVersion with more than one method or instrument is a collapsed identity.
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:USES_METHOD]->(mm:MeasurementMethod)
OPTIONAL MATCH (a)-[:RUNS_ON_INSTRUMENT]->(t:ToolOrInstrument)
WITH a, count(DISTINCT mm) AS methods, count(DISTINCT t) AS instruments
WHERE methods > 1 OR instruments > 1
RETURN a.uid AS assayVersionUid, methods, instruments;

// V-301b: an AssayVersion is operated by exactly one laboratory.
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:ASSAY_OPERATED_BY]->(o:Organization)
WITH a, count(DISTINCT o) AS operators
WHERE operators <> 1
RETURN a.uid AS assayVersionUid, operators;

// V-302: measured results compared across different assay versions need a COMPARABLE or COMPARABLE_WITH_CONVERSION assessment.
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
      (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
WHERE a1 <> a2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
    MATCH (ca)-[:COMPARES]->(a2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// V-302r (proposed, W07-SR-11): as V-302, but only a well-formed, current assessment licenses the pair (exactly two
// COMPARES targets, status not SUPERSEDED/WITHDRAWN, recordedTo null). Under V-302 a malformed three-way assessment
// (N10) masks an unlicensed trend (N1).
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
      (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
WHERE a1 <> a2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
    MATCH (ca)-[:COMPARES]->(a2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
      AND NOT ca.status IN ['SUPERSEDED', 'WITHDRAWN'] AND ca.recordedTo IS NULL
      AND COUNT { (ca)-[:COMPARES]->() } = 2
  }
RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// V-303: result kind must match its producing record (catalog text; MEASURED has no pending state).
MATCH (r:DiagnosticResult)
WHERE r.resultKind IS NULL
   OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion))
   OR (r.resultKind IN ['CALCULATED', 'INFERRED']
       AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
       })
RETURN r.uid AS resultUid, r.resultKind AS resultKind;

// V-303r (proposed, W07-SR-09): as V-303, plus a MEASURED result may be pending through an UNRESOLVED
// PRODUCED_BY_ASSAY_VERSION assertion (performing laboratory not named, e.g. Everlywell "Each lab we work with").
MATCH (r:DiagnosticResult)
WHERE r.resultKind IS NULL
   OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'PRODUCED_BY_ASSAY_VERSION' AND x.status = 'UNRESOLVED'
       })
   OR (r.resultKind IN ['CALCULATED', 'INFERRED']
       AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
       })
RETURN r.uid AS resultUid, r.resultKind AS resultKind;

// V-304: inferred or calculated results compared across different algorithm versions need an assessment.
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
      (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
WHERE v1 <> v2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
    MATCH (ca)-[:COMPARES]->(v2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

// V-304r (proposed, W07-SR-11): V-304 with the same well-formed-assessment rule as V-302r.
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
      (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
WHERE v1 <> v2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
    MATCH (ca)-[:COMPARES]->(v2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
      AND NOT ca.status IN ['SUPERSEDED', 'WITHDRAWN'] AND ca.recordedTo IS NULL
      AND COUNT { (ca)-[:COMPARES]->() } = 2
  }
RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

// V-305b: every reference interval version belongs to an assay version.
MATCH (ri:ReferenceIntervalVersion)
WHERE NOT (ri)-[:FOR_ASSAY_VERSION]->(:AssayVersion)
RETURN ri.uid AS intervalWithoutAssayVersion;

// V-305c (proposed, INV-302 "exactly one"): no reference interval version is bound to more than one assay version.
MATCH (ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WITH ri, collect(DISTINCT a.uid) AS assays
WHERE size(assays) > 1
RETURN ri.uid AS intervalUid, assays;

// V-306: a result is interpreted with an interval of its own assay version.
MATCH (r:DiagnosticResult)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WHERE NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
RETURN r.uid AS resultUid, ri.uid AS intervalUid, a.uid AS intervalAssayVersion;

// V-307: no "same test" identity merge without an accepted resolution projection.
MATCH (t1:LabTest)-[s:SAME_TEST_AS]-(t2:LabTest)
WHERE elementId(t1) < elementId(t2)
  AND s.projectionOfAssertionUid IS NULL
RETURN t1.uid AS labTest1, t2.uid AS labTest2;

// V-308: every algorithm version states its version basis.
MATCH (v:AlgorithmVersion)
WHERE v.versionBasis IS NULL
   OR NOT v.versionBasis IN ['VENDOR_VERSION_STRING', 'PUBLICATION_VERSION', 'SERVICE_ENDPOINT_UNVERSIONED', 'UNKNOWN']
RETURN v.uid AS algorithmVersionUid, v.versionBasis AS versionBasis;

// V-312: results from an unversioned service endpoint never enter a comparison.
MATCH (r:DiagnosticResult)-[:COMPARED_TO]-(:DiagnosticResult)
MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
WHERE v.versionBasis = 'SERVICE_ENDPOINT_UNVERSIONED'
RETURN DISTINCT r.uid AS resultUid, v.uid AS algorithmVersionUid;

// V-305a: live HAS_REFERENCE_RANGE edges from Biomarker or Metric are projections only (migration check).
MATCH (x)-[h:HAS_REFERENCE_RANGE]->(rr:ReferenceRange)
WHERE (x:Biomarker OR x:Metric)
  AND h.projectionOfAssertionUid IS NULL AND h.derivationRule IS NULL
RETURN coalesce(x.uid, x.id) AS ownerId, coalesce(rr.uid, rr.id) AS referenceRangeId;

// V-309: a result does not indicate a condition without an assertion (outside a reference interval is not a condition).
MATCH (r:DiagnosticResult)-[e:INDICATES_CONDITION]->(c)
WHERE e.assertionUid IS NULL
RETURN r.uid AS resultUid, c.uid AS conditionUid;

// V-310a: materialized LOINC codes are well formed (digits, hyphen, check digit).
MATCH (m:Metric)
WHERE m.loincCode IS NOT NULL AND NOT m.loincCode =~ '^[0-9]{1,7}-[0-9]$'
RETURN m.uid AS metricUid, m.loincCode AS loincCode;

// V-310b: one Metric per LOINC code (also enforced by constraint metric_loinc_code).
MATCH (m:Metric)
WHERE m.loincCode IS NOT NULL
WITH m.loincCode AS code, collect(m.uid) AS uids
WHERE size(uids) > 1
RETURN code, uids;

// V-311: a ComparabilityAssessment compares exactly two versions of the same kind.
MATCH (ca:ComparabilityAssessment)
OPTIONAL MATCH (ca)-[:COMPARES]->(x)
WITH ca, collect(x) AS xs
WHERE size(xs) <> 2
   OR NOT (all(n IN xs WHERE n:AssayVersion)
           OR all(n IN xs WHERE n:AlgorithmVersion)
           OR all(n IN xs WHERE n:ReferenceIntervalVersion))
RETURN ca.uid AS assessmentUid, size(xs) AS subjects;

// V-313r (proposed; supersedes the V-313 value list): every DiagnosticResult in the shared graph is PUBLIC or INTERNAL
// and never carries a private uid (INV-506, D-012).
MATCH (r:DiagnosticResult)
WHERE r.privacyClass IS NULL OR NOT r.privacyClass IN ['PUBLIC', 'INTERNAL'] OR r.uid STARTS WITH 'hu:private-'
RETURN r.uid AS resultUid, r.privacyClass AS privacyClass;

// V-314 (proposed; forbidden [WITHIN_VERSION_SCORE_DIFFERENCE, MEASURED_BIOLOGICAL_CHANGE] and [INFERRED_RESULT,
// MEASURED_RESULT]): a change between two results is never DIRECT_MEASUREMENT unless both results are MEASURED, and a
// change between two results of one AlgorithmVersion needs an assessment with a replicateNoiseBasis before it is
// presented as more than what a source said (status ACCEPTED requires that licence).
MATCH (x:Assertion {predicate: 'CHANGED_BETWEEN'})-[:HAS_SUBJECT]->(r1:DiagnosticResult)
MATCH (x)-[:HAS_OBJECT]->(r2:DiagnosticResult)
WHERE (x.basisKind = 'DIRECT_MEASUREMENT' AND (r1.resultKind <> 'MEASURED' OR r2.resultKind <> 'MEASURED'))
   OR (x.basisKind = 'DIRECT_MEASUREMENT' AND EXISTS {
         MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)<-[:COMPUTED_BY_ALGORITHM_VERSION]-(r2)
         WHERE NOT EXISTS { MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v) WHERE ca.replicateNoiseBasis IS NOT NULL }
       })
RETURN x.uid AS assertionUid, r1.uid AS laterResult, r2.uid AS earlierResult, x.basisKind AS basisKind;

// V-315 (proposed; forbidden [SIMILAR_TEST_NAME, SAME_METRIC]): tests linked as the same test measure the same metrics.
MATCH (t1:LabTest)-[:SAME_TEST_AS]-(t2:LabTest)
WHERE elementId(t1) < elementId(t2)
  AND EXISTS { MATCH (t1)-[:MEASURES_METRIC]->(m1:Metric) WHERE NOT (t2)-[:MEASURES_METRIC]->(m1) }
RETURN t1.uid AS labTest1, t2.uid AS labTest2;

// V-316 (proposed; forbidden [INFERRED_RESULT, MEASURED_RESULT]): a MEASURED result is never computed by an algorithm
// version (an inferred score relabelled MEASURED keeps its COMPUTED_BY edge and is caught here).
MATCH (r:DiagnosticResult {resultKind: 'MEASURED'})-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
RETURN r.uid AS resultUid, v.uid AS algorithmVersionUid;

// V-317 (proposed; property card AlgorithmVersion.retrievedAt): an unversioned service endpoint is pinned by retrievedAt.
MATCH (v:AlgorithmVersion {versionBasis: 'SERVICE_ENDPOINT_UNVERSIONED'})
WHERE v.retrievedAt IS NULL
RETURN v.uid AS algorithmVersionUid;

// V-318 (proposed; one-sided intervals): a bound value and its status agree (null bound with REPORTED, or a value with
// NOT_APPLICABLE, is a capture error; a null bound with null status reads as unknown).
MATCH (ri:ReferenceIntervalVersion)
WHERE (ri.lowerBound IS NULL AND ri.lowerBoundStatus = 'REPORTED')
   OR (ri.upperBound IS NULL AND ri.upperBoundStatus = 'REPORTED')
   OR (ri.lowerBound IS NOT NULL AND ri.lowerBoundStatus IN ['NOT_APPLICABLE', 'NOT_REPORTED'])
   OR (ri.upperBound IS NOT NULL AND ri.upperBoundStatus IN ['NOT_APPLICABLE', 'NOT_REPORTED'])
RETURN ri.uid AS intervalUid;

// Informational (review queue, not a violation): pending result-to-version links.
MATCH (x:Assertion)-[:HAS_SUBJECT]->(r:DiagnosticResult)
WHERE x.predicate IN ['COMPUTED_BY_ALGORITHM_VERSION', 'PRODUCED_BY_ASSAY_VERSION'] AND x.status = 'UNRESOLVED'
OPTIONAL MATCH (x)-[:HAS_OBJECT]->(v)
RETURN r.uid AS resultUid, x.predicate AS predicate, collect(coalesce(v.uid, x.valueString)) AS candidates
ORDER BY resultUid;
