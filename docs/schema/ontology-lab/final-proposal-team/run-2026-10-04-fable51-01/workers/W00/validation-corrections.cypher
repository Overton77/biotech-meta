// =====================================================================================================
// W00 validation corrections (reconciliation pass, run-2026-10-04-fable51-01).
// Each block: "<new id> -- replaces <frozen id>; ruling W00-R-nn", the requester's failing case, the ORIGINAL frozen text from
// docs/schema/neo4j/validation.cypher kept as comments (never executed), and the REVISED query. Zero rows = valid unless marked
// (informational). Every statement is self-contained. Parameters come from fixtures/validation-params-w00.json (Fable's
// validation/validation-params.json plus the deltas listed in 10-kernel-operations-delta.md section 3).
// Executed on embedded Neo4j 5.26.31 Community + APOC 5.26.31 against W00 fixtures 00-13 and the targeted worker fixtures;
// row counts (original vs revised) are in fixtures/results/validation-corrections-runs.md.
// Validators adopted by reference and NOT copied here (owner keeps the text, Fable assigns final ids): V-314..V-318 (W07),
// W20-V02..W20-V10 (W20), V-W21-01..V-W21-12 except -06/-12 (W21), V-601..V-615 (W22), V-W23-* (W23; -09/-10 absorbed by V-521r).
// =====================================================================================================

// ===================================================================================================
// V-003r -- replaces V-003; ruling W00-R-02
// INV-003 literal-xor-object stays for every predicateClass except QUANTITY, which may carry one object plus one numeric
// literal (valueNumber + unitCode). Failing cases: W02 fx-91 (two literal-only CALCULATED amounts, refersTo null), W04 w04-03
// (component -> NR cation 263.42 mg fails V-003), W07-SR-13 (CHANGED_BETWEEN with delta).
// ORIGINAL (kept for comparison; not executed):
// | // V-003: assertions must have exactly one object OR one typed literal.
// | MATCH (a:Assertion)
// | OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
// | WITH a, count(o) AS objects,
// |      size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
// | WHERE objects + literals <> 1
// | RETURN a.uid AS assertionUid, objects, literals;
// REVISED:
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, count(o) AS objects,
     size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
WITH a, objects, literals, coalesce(a.predicateClass, '') = $quantityPredicateClass AS isQuantity
WHERE (NOT isQuantity AND objects + literals <> 1)
   OR (isQuantity AND (objects > 1 OR literals > 1 OR objects + literals = 0
        OR (objects = 1 AND literals = 1 AND (a.valueNumber IS NULL OR a.unitCode IS NULL))))
RETURN 'V-003r' AS check, a.uid AS assertionUid, a.predicateClass AS predicateClass, objects, literals;

// ===================================================================================================
// V-006r -- replaces V-006; ruling W00-R-33
// QUANTITATIVELY_CONTAINS quantity shape agrees with its comparator (ranges and one-sided limits). Failing case W02 fx-91:
// Ph. Eur. Ginkgo BETWEEN edges -> frozen V-006 2 rows on complete statements.
// Revised text source: W02/operations.cypher V-W02-10 (W02-SR-02)
// ORIGINAL (kept for comparison; not executed):
// | // V-006: quantitative containment requires quantity, unit, and basis.
// | MATCH ()-[r:QUANTITATIVELY_CONTAINS]->()
// | WHERE r.quantity IS NULL OR r.unitCode IS NULL OR r.basis IS NULL
// | RETURN r;
// REVISED:
MATCH (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
WHERE r.unitCode IS NULL OR r.basis IS NULL OR r.contentStatementKind IS NULL OR r.comparator IS NULL
   OR (r.comparator IN ['EQ', 'APPROX', 'GE', 'GT', 'LE', 'LT'] AND r.quantity IS NULL)
   OR (r.comparator = 'BETWEEN' AND (r.quantityLow IS NULL OR r.quantityHigh IS NULL OR r.quantityLow >= r.quantityHigh OR r.quantity IS NOT NULL))
RETURN 'V-006r' AS check, x.uid AS material, y.uid AS target, r.comparator AS comparator, r.quantity AS quantity, r.basis AS basis;

// ===================================================================================================
// V-101r -- replaces V-101; ruling W00-R-41
// Unchanged text; the W00 copy (validation-w00.cypher) had an inlined list. Runs with validation-params-w00.json $assertedTypes,
// which adds the W01 organization edges (W01-SR-06), W15 commerce edges (W15-SR-11b), W21 edges (W21-SR-16), HAS_PATHWAY_VERSION
// and drops IDENTIFIED_BY (relabelled HAS_IDENTIFIER, W00-R-20). Failing case W15 N9 / W01 N4, N8.
// ORIGINAL (kept for comparison; not executed):
// | // =====================================================================================
// | // Lane 1, round 0009: query-shape invariants (V-1xx)
// | // Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// | // Every query below is statically checked (syntax and per-statement variable binding) unless marked
// | // illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// | // =====================================================================================
// | 
// | // Lane 1 validation queries V-101..V-121 (access, query shapes, temporal and search-surface invariants).
// | // Zero rows = valid unless marked informational. Every statement is self-contained: it binds its own
// | // variables and shares nothing across ';'. None of these was executed; no Neo4j was available.
// | // Status tags:
// | //   statically-checked = parsed with the Neo4j Cypher language-support linter (syntax and schema-free
// | //                        semantics) and read against catalog labels, relationship types and properties.
// | //   illustrative       = depends on a parameter list or a catalog decision that is not yet merged.
// | // Parameters ($...) are supplied by the validation runner from the merged catalog.
// | 
// | // V-101: every asserted edge carries its authorizing assertion and a recorded-time start.
// | // status: statically-checked
// | // params: $assertedTypes list<string> generated from catalog relationships with class: asserted
// | MATCH ()-[r]->()
// | WHERE type(r) IN $assertedTypes
// |   AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL)
// | RETURN type(r) AS relType, elementId(r) AS edgeId, r.recordedFrom AS recordedFrom, r.assertionUid AS assertionUid;
// REVISED:
MATCH ()-[r]->()
WHERE type(r) IN $assertedTypes
  AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL)
RETURN 'V-101r' AS check, type(r) AS relType, elementId(r) AS edgeId, r.recordedFrom AS recordedFrom, r.assertionUid AS assertionUid;

// ===================================================================================================
// V-108r (informational) -- replaces V-108; ruling W00-R-39
// Informational: POSSIBLE overlaps go to the review queue (V-509r); DEFINITE overlaps are V-508r errors. Partition key is the
// edge property with the target node as fallback: coalesce(r.jurisdiction, t.jurisdiction). Failing case W04 w04-04 (Basis variant,
// two OBSERVATION_ONLY formulation versions; frozen V-108 reports a violation for an honest unknown transition date).
// ORIGINAL (kept for comparison; not executed):
// | // V-108: exclusive predicates: no two possibly-overlapping believed attachments from one subject
// | // to different objects within one scope. Unknown bounds are treated as possible overlap.
// | // status: illustrative (depends on predicate exclusivity metadata, catalog conventions.predicateExclusivity)
// | // params: $exclusiveTypes list<string>
// | MATCH (x)-[r1]->(y1), (x)-[r2]->(y2)
// | WHERE type(r1) = type(r2)
// |   AND type(r1) IN $exclusiveTypes
// |   AND elementId(r1) < elementId(r2)
// |   AND y1 <> y2
// |   AND coalesce(y1.jurisdiction, '') = coalesce(y2.jurisdiction, '')
// |   AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
// |   AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
// |   AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
// |   AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
// | RETURN type(r1) AS relType, x.uid AS subjectUid, y1.uid AS objectUid1, y2.uid AS objectUid2,
// |        elementId(r1) AS edge1, elementId(r2) AS edge2;
// REVISED:
MATCH (x)-[r1]->(y1), (x)-[r2]->(y2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND y1 <> y2
  AND coalesce(r1.jurisdiction, y1.jurisdiction, '') = coalesce(r2.jurisdiction, y2.jurisdiction, '')
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
  AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
RETURN 'V-108r' AS check, type(r1) AS relType, x.uid AS subjectUid, y1.uid AS objectUid1, y2.uid AS objectUid2, 'REVIEW_QUEUE' AS action;

// ===================================================================================================
// V-508r -- replaces V-508; ruling W00-R-39
// DEFINITE overlap of exclusive attachments, over every $exclusiveTypes type (adds STRAIN_OF, HAS_PATHWAY_VERSION) with the
// edge-first partition key. Path-partitioned types (HAS_CAPABILITY_STATE, GOVERNED_BY_SPECIFICATION) are audited by V-W11-02/07.
// ORIGINAL (kept for comparison; not executed):
// | // V-508: DEFINITE overlap of mutually exclusive attachments in both valid and recorded time.
// | // Bounds are shrunk by their precision before comparison; null bounds never produce a definite overlap.
// | // status: statically-checked
// | MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
// |       (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
// | WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
// |   AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
// |   AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
// |   AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
// |   AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
// | WITH s, r1, r2, t1, t2,
// |      r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
// |                     WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
// |      r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
// |                     WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
// | WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
// | RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;
// REVISED:
MATCH (s)-[r1]->(t1), (s)-[r2]->(t2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(r1.jurisdiction, t1.jurisdiction, '-') = coalesce(r2.jurisdiction, t2.jurisdiction, '-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
     r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
     r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN 'V-508r' AS check, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// ===================================================================================================
// V-509r (informational) -- replaces V-509; ruling W00-R-39
// POSSIBLE overlap (review queue) over $exclusiveTypes with the edge-first partition key.
// ORIGINAL (kept for comparison; not executed):
// | // V-509 (informational, review queue): POSSIBLE overlap of exclusive attachments caused by a null or imprecise bound,
// | // among currently recorded episodes.
// | // status: statically-checked
// | MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
// |       (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
// | WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
// |   AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
// |   AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
// |   AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
// |   AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
// |   AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
// |        OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
// | RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;
// REVISED:
MATCH (s)-[r1]->(t1), (s)-[r2]->(t2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(r1.jurisdiction, t1.jurisdiction, '-') = coalesce(r2.jurisdiction, t2.jurisdiction, '-')
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
  AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
  AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
       OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
RETURN 'V-509r' AS check, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;

// ===================================================================================================
// V-112r -- replaces V-112; ruling W00-R-23
// (1) the hypothesis citation is read from derivedFromAssessmentUids (W00-SR-06: no relationship-property type has hypothesisUid);
// (2) $ruleOnlyDerivedTypes adds RESOLVES_TO_CHUNK, HAS_CHUNK, CHUNK_IN_SEGMENT, ABOUT, MENTIONS_ENTITY (W20-SR-01), HAS_CURRENT_PROTOCOL_STEP
// (W16-SR-06) and COMPARED_TO (W07-SR-10); (3) a rule-only COMPARED_TO is legal only between results of the same assay or algorithm
// version (RULE_ONLY_ACROSS_VERSIONS). Failing cases: W20 fixture 01 (offset-overlap-v1 edges), W07 positive fixture (2 rows).
// ORIGINAL (kept for comparison; not executed):
// | // V-112: derived and forbidden-implication edges cite live, matching assertions (QS-4a, zero rows = valid).
// | // status: statically-checked
// | // params: $derivedTypes, $implicationPairs, $ruleOnlyDerivedTypes (catalog relationships with ruleOnly: true)
// | MATCH (x)-[r]->(y)
// | WHERE type(r) IN $derivedTypes OR type(r) IN [p IN $implicationPairs | p[1]]
// | WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
// | OPTIONAL MATCH (cited:Assertion {uid: citedUid})
// | WITH x, y, r, citedUid, cited,
// |      [v IN [
// |         CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
// |         CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
// |         CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
// |         CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) = 0
// |                   AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AND r.hypothesisUid IS NULL
// |                   AND NOT type(r) IN $ruleOnlyDerivedTypes THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
// |         CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
// |              THEN 'LICENSING_ASSESSMENT_MISSING' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
// |                MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
// |                  AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = inp.predicate)
// |              } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
// |                size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
// |              THEN 'DERIVATION_INPUT_MISSING' END
// |      ] WHERE v IS NOT NULL] AS violations
// | WHERE size(violations) > 0
// | RETURN type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;
// REVISED:
MATCH (x)-[r]->(y)
WHERE type(r) IN $derivedTypes OR type(r) IN [p IN $implicationPairs | p[1]]
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, citedUid, cited,
     size(coalesce(r.derivedFromAssertionUids, [])) = 0 AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AS noInputs,
     [v IN [
        CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
        CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
             THEN 'LICENSING_ASSESSMENT_MISSING' END,
        CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
               MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
                 AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = inp.predicate)
             } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
               size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
             THEN 'DERIVATION_INPUT_MISSING' END
     ] WHERE v IS NOT NULL] AS firstViolations
WITH x, y, r, noInputs, firstViolations + [v IN [
        CASE WHEN r.derivationRule IS NOT NULL AND noInputs AND NOT type(r) IN $ruleOnlyDerivedTypes THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
        CASE WHEN type(r) = 'COMPARED_TO' AND r.derivationRule IS NOT NULL AND noInputs AND (
               EXISTS { MATCH (x)-[:PRODUCED_BY_ASSAY_VERSION]->(av1), (y)-[:PRODUCED_BY_ASSAY_VERSION]->(av2) WHERE av1 <> av2 }
            OR EXISTS { MATCH (x)-[:COMPUTED_BY_ALGORITHM_VERSION]->(gv1), (y)-[:COMPUTED_BY_ALGORITHM_VERSION]->(gv2) WHERE gv1 <> gv2 })
             THEN 'RULE_ONLY_ACROSS_VERSIONS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-112r' AS check, type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;

// ===================================================================================================
// V-W00-02r -- replaces V-W00-02 (W00 packet); ruling W00-R-41
// Citation-field discipline (D-011) read from $assertedTypes / $derivedTypes instead of an inlined list (W15-SR-11b: N9 caught by the
// catalog V-101 but not by the W00 list). A legacy RECOMMENDS edge with assertionUid reports here as a migration item (W00-R-25).
// ORIGINAL (kept for comparison; not executed):
// | // V-W00-02 (D-011, CL-009): asserted edges carry assertionUid, derived edges projectionOfAssertionUid, never both;
// | // an asserted type never carries projectionOfAssertionUid; a derived type never carries assertionUid.
// | MATCH ()-[r]->()
// | WHERE (r.assertionUid IS NOT NULL AND r.projectionOfAssertionUid IS NOT NULL)
// |    OR (type(r) IN ['HAS_FORMULATION_VERSION','HAS_STATE','HAS_IDENTIFIER','BOARD_MEMBER_OF','ADVISES_ORGANIZATION','SELLER_OF_RECORD_FOR','HOSTS_LISTING','LISTS_OFFER','ENDORSES_PRODUCT','IDENTIFIED_BY'] AND r.projectionOfAssertionUid IS NOT NULL)
// |    OR (type(r) IN ['SELLS_PRODUCT','CONTAINS','INSTANCE_OF'] AND r.assertionUid IS NOT NULL)
// | RETURN 'V-W00-02' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge;
// REVISED:
MATCH ()-[r]->()
WHERE (r.assertionUid IS NOT NULL AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN $assertedTypes AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN $derivedTypes AND r.assertionUid IS NOT NULL)
RETURN 'V-W00-02r' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge,
       CASE WHEN type(r) IN $derivedTypes THEN 'ASSERTION_UID_ON_DERIVED_EDGE' ELSE 'PROJECTION_UID_ON_ASSERTED_EDGE' END AS violation;

// ===================================================================================================
// V-211r -- replaces V-211; ruling W00-R-34
// Count DISTINCT owning registrations (W09-CR-03): the round-0007 re-bounding shape (closed e1 + e1b) gives owners = 2 under V-211.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-211: every RegistrationVersion belongs to exactly one TrialRegistration and has observedAt.
// | // status: statically-checked
// | MATCH (rv:RegistrationVersion)
// | OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
// | WITH rv, count(r) AS owners
// | WHERE owners <> 1 OR rv.observedAt IS NULL
// | RETURN rv.uid AS registrationVersion, owners;
// REVISED:
MATCH (rv:RegistrationVersion)
OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
WITH rv, count(DISTINCT r) AS owners
WHERE owners <> 1 OR rv.observedAt IS NULL
RETURN 'V-211r' AS check, rv.uid AS registrationVersion, owners;

// ===================================================================================================
// V-215r -- replaces V-215; ruling W00-R-34
// INV-206 in full (W09-CR-04): any non-SUPPORTIVE, non-HYPOTHESIS_GENERATING role after a null primary. Failing case W09 fx 90 N08.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-215 (INV-206): no secondary/subgroup/post hoc/within-arm result enters as CONFIRMATORY when the same
// | // study's primary prespecified result is NOT_SIGNIFICANT.
// | // status: statically-checked
// | MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
// | WHERE r.analysisKind <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind = 'WITHIN_ARM_CHANGE'
// | MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
// | RETURN syn.uid AS synthesis, r.uid AS nonPrimaryConfirmatory, p.uid AS nullPrimary;
// REVISED:
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE (r.analysisKind IN ['SECONDARY_PRESPECIFIED', 'SUBGROUP_PRESPECIFIED', 'SUBGROUP_POST_HOC', 'EXPLORATORY'] OR r.comparisonKind = 'WITHIN_ARM_CHANGE')
  AND NOT inc.inputRole IN ['SUPPORTIVE', 'HYPOTHESIS_GENERATING']
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
RETURN 'V-215r' AS check, syn.uid AS synthesis, r.uid AS nonPrimaryInput, inc.inputRole AS role, p.uid AS nullPrimary;

// ===================================================================================================
// V-217r -- replaces V-217; ruling W00-R-34
// Hard part of INV-207 only (W09-CR-01): a missing collection method. Faithful NOT_DESCRIBED zeros move to V-217i.
// Failing case: S-07 Basis and S-19 ENERGIZE captures, frozen V-217 5 rows.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-217 (INV-207): adverse-event results state a collection method; zeros need one.
// | // status: statically-checked
// | MATCH (ae:AdverseEventResult)
// | WHERE ae.collectionMethod IS NULL OR (ae.participantsAffected = 0 AND ae.collectionMethod = 'NOT_DESCRIBED')
// | RETURN ae.uid AS aeResult, ae.participantsAffected AS affected, ae.collectionMethod AS method;
// REVISED:
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod IS NULL
RETURN 'V-217r' AS check, ae.uid AS aeResultWithoutCollectionMethod, ae.eventCount AS eventCount, ae.participantsAffected AS affected;

// ===================================================================================================
// V-217i (informational) -- replaces V-217 (zero branch); ruling W00-R-34
// Informational companion of V-217r: zeros whose collection method the source does not describe.
// Revised text source: W09/fixtures/80-queries.cypher
// REVISED:
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod = 'NOT_DESCRIBED' AND (ae.participantsAffected = 0 OR ae.eventCount = 0)
RETURN 'V-217i' AS check, ae.uid AS zeroWithUndescribedCollection, ae.collectionMethodText AS sourceWording;

// ===================================================================================================
// V-221r -- replaces V-221; ruling W00-R-34
// Null armType checked; sham/no-intervention exempt; bases only for REPORTED amounts; device components NOT_APPLICABLE;
// definition-only interventions complete (W09-CR-02). Failing case W09 fixture 04: 4 false positives, 4 silently skipped arms.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-221 (R1): non-placebo study interventions have components with quantity, unit, quantityBasis, and massBasis
// | // (massBasis may be UNSPECIFIED; quantity may be absent only with quantityStatus NOT_REPORTED).
// | // status: statically-checked
// | MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
// | WHERE arm.armType <> 'PLACEBO_COMPARATOR'
// | OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
// | WITH si, ic
// | WHERE ic IS NULL
// |    OR ic.massBasis IS NULL OR ic.quantityBasis IS NULL
// |    OR (ic.quantity IS NULL AND coalesce(ic.quantityStatus, '') <> 'NOT_REPORTED')
// |    OR (ic.quantity IS NOT NULL AND ic.unitCode IS NULL)
// | RETURN si.uid AS intervention, ic.uid AS incompleteComponent;
// REVISED:
MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
WHERE NOT coalesce(arm.armType, 'UNKNOWN') IN ['PLACEBO_COMPARATOR', 'SHAM_COMPARATOR', 'NO_INTERVENTION']
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
WITH si, ic, EXISTS { MATCH (si)-[:FOLLOWS_INTERVENTION_DEFINITION]->() } AS hasDefinition
WITH si, ic, hasDefinition,
     CASE WHEN ic IS NULL THEN null ELSE EXISTS { MATCH (ic)-[:USES_INTERVENTION_DEVICE]->(:Device) } END AS isDevice
WHERE (ic IS NULL AND NOT hasDefinition)
   OR (ic IS NOT NULL AND isDevice AND coalesce(ic.quantityStatus, '') <> 'NOT_APPLICABLE')
   OR (ic IS NOT NULL AND NOT isDevice AND ic.quantityStatus IS NULL AND ic.quantity IS NULL)
   OR (ic IS NOT NULL AND NOT isDevice AND coalesce(ic.quantityStatus, 'REPORTED') = 'REPORTED'
       AND (ic.quantity IS NULL OR ic.unitCode IS NULL OR ic.quantityBasis IS NULL OR ic.massBasis IS NULL))
RETURN 'V-221r' AS check, si.uid AS intervention, ic.uid AS incompleteComponent;

// ===================================================================================================
// V-231r -- replaces V-231; ruling W00-R-49
// INV-210 binds mechanism-class assertions ("Every mechanism-class Assertion ..."); V-231 tests every assertion with a basisKind, so a
// non-mechanism DIRECT_MEASUREMENT (an adverse-event count, a lab value) without a MechanismEvidenceContext is reported although
// INV-210 does not apply to it (W17-SR-09). A null predicateClass is read as MECHANISM (conservative).
// ORIGINAL (kept for comparison; not executed):
// | // V-231 (INV-210): DIRECT_MEASUREMENT has exactly one context with setting and species (except cell-free / in silico);
// | // non-measured assertions have no context.
// | // status: statically-checked
// | MATCH (a:Assertion)
// | WHERE a.basisKind IS NOT NULL
// | OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
// | WITH a, collect(c) AS ctxs
// | WHERE (a.basisKind = 'DIRECT_MEASUREMENT' AND size(ctxs) <> 1)
// |    OR (a.basisKind <> 'DIRECT_MEASUREMENT' AND size(ctxs) > 0)
// |    OR (size(ctxs) = 1 AND (ctxs[0].setting IS NULL
// |         OR (NOT ctxs[0].setting IN ['IN_VITRO_CELL_FREE', 'IN_SILICO'] AND NOT EXISTS { MATCH (ctx:MechanismEvidenceContext {uid: ctxs[0].uid})-[:IN_SPECIES]->(:Species) })))
// | RETURN a.uid AS assertion, a.basisKind AS basisKind, size(ctxs) AS contexts;
// REVISED:
MATCH (a:Assertion)
WHERE a.basisKind IS NOT NULL AND coalesce(a.predicateClass, 'MECHANISM') = 'MECHANISM'
OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
WITH a, collect(c) AS ctxs
WHERE (a.basisKind = 'DIRECT_MEASUREMENT' AND size(ctxs) <> 1)
   OR (a.basisKind <> 'DIRECT_MEASUREMENT' AND size(ctxs) > 0)
   OR (size(ctxs) = 1 AND (ctxs[0].setting IS NULL
        OR (NOT ctxs[0].setting IN ['IN_VITRO_CELL_FREE', 'IN_SILICO'] AND NOT EXISTS { MATCH (ctx:MechanismEvidenceContext {uid: ctxs[0].uid})-[:IN_SPECIES]->(:Species) })))
RETURN 'V-231r' AS check, a.uid AS assertion, a.basisKind AS basisKind, a.predicateClass AS predicateClass, size(ctxs) AS contexts;

// ===================================================================================================
// V-233r -- replaces V-233; ruling W00-R-26
// Mechanism projections may cite inputs in rule mode mx-proj/v1 + derivedFromAssertionUids (W03-SR-01); V-112 stays the citation
// check. Failing case W03 positive fixture: six valid rule-mode edges, verbatim V-233 4 rows.
// Revised text source: W03/fixtures/w03-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-233 (INV-211, FI-304): mechanism projections only from ACCEPTED DIRECT_MEASUREMENT assertions.
// | // ACCEPTED here is capture fidelity (the measurement was accurately recorded), not a truth verdict; truth gating
// | // of projections is a SUPPORT adjudication question handled by the recommendation layer.
// | // status: statically-checked
// | MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME]->(y)
// | OPTIONAL MATCH (a:Assertion {uid: r.projectionOfAssertionUid})
// | WITH x, r, y, a
// | WHERE a IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT' OR a.status <> 'ACCEPTED'
// | RETURN x.uid AS fromUid, type(r) AS rel, y.uid AS toUid, a.basisKind AS projectedBasis;
// REVISED:
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME|ACTS_IN]->(y)
WITH x, r, y,
     CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN cited
WITH x, r, y, cited, collect(a) AS found
WITH x, r, y, cited, found,
     [v IN [
       CASE WHEN size(cited) = 0 THEN 'NO_CITATION' END,
       CASE WHEN size(found) < size(cited) THEN 'CITED_ASSERTION_MISSING' END,
       CASE WHEN r.projectionOfAssertionUid IS NULL AND coalesce(r.derivationRule, '') <> 'mx-proj/v1' THEN 'UNKNOWN_DERIVATION_RULE' END,
       CASE WHEN any(a IN found WHERE a.basisKind IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT') THEN 'NON_MEASURED_INPUT' END,
       CASE WHEN any(a IN found WHERE a.status <> 'ACCEPTED' OR a.recordedTo IS NOT NULL) THEN 'NON_CURRENT_OR_UNACCEPTED_INPUT' END,
       CASE WHEN any(a IN found WHERE coalesce(a.polarity, 'UNKNOWN') <> 'POSITIVE') THEN 'NON_POSITIVE_INPUT' END,
       CASE WHEN any(a IN found WHERE COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } <> 1) THEN 'INPUT_WITHOUT_SINGLE_CONTEXT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-233r' AS check, type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, violations;

// ===================================================================================================
// V-234r -- replaces V-234; ruling W00-R-26
// As V-233r for the species clause (W03-SR-01). Verbatim V-234 2 rows on the W03 positive fixture.
// Revised text source: W03/fixtures/w03-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-234 (INV-211, FI-302): APPLIES_TO_SPECIES targets a species of the projected assertion's context.
// | // status: statically-checked
// | MATCH (m:Mechanism)-[r:APPLIES_TO_SPECIES]->(sp:Species)
// | WHERE NOT EXISTS {
// |   MATCH (a:Assertion {uid: r.projectionOfAssertionUid})-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
// | }
// | RETURN m.uid AS mechanism, sp.uid AS speciesWithoutMeasuredContext;
// REVISED:
MATCH (m)-[r:APPLIES_TO_SPECIES]->(sp:Species)
WITH m, r, sp,
     CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
WHERE NOT EXISTS {
  MATCH (a:Assertion)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
  WHERE a.uid IN cited AND a.polarity = 'POSITIVE'
}
RETURN 'V-234r' AS check, m.uid AS subjectUid, sp.uid AS speciesWithoutPositiveMeasuredContext, cited;

// ===================================================================================================
// V-235r -- replaces V-235; ruling W00-R-15
// Join a Source to its work by RENDITION_OF, not by "https://doi.org/" + doi (W19-SR-10: doi.org is a resolver, never a canonicalUri),
// and also read a RETRACTION SourceRevisionEvent on the Source not followed by a REINSTATEMENT. Failing case W19 fixture 90 N2.
// ORIGINAL (kept for comparison; not executed):
// | // V-235 (M6): ACCEPTED assertions whose every supporting locator belongs to a source whose publication is retracted.
// | // Publication-to-Source alignment is Lane 4's (round 0006); this query joins on DOI URI.
// | // status: illustrative
// | MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
// | WITH a, collect(DISTINCT src) AS sources
// | WHERE all(s0 IN sources WHERE EXISTS {
// |   MATCH (notice:Publication)-[:RETRACTS]->(pub:Publication)
// |   WHERE s0.canonicalUri = 'https://doi.org/' + pub.doi
// | })
// | RETURN a.uid AS acceptedAssertionOnlyOnRetractedSources;
// REVISED:
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH a, collect(DISTINCT src) AS sources
WHERE all(s0 IN sources WHERE
        EXISTS { MATCH (s0)-[:RENDITION_OF]->(pub:Publication)<-[:RETRACTS]-(:Publication) }
     OR EXISTS { MATCH (s0)<-[:REVISES_SOURCE]-(ev:SourceRevisionEvent {revisionKind: 'RETRACTION'})
                 WHERE NOT EXISTS { MATCH (s0)<-[:REVISES_SOURCE]-(re:SourceRevisionEvent {revisionKind: 'REINSTATEMENT'}) WHERE re.recordedAt > ev.recordedAt } })
RETURN 'V-235r' AS check, a.uid AS acceptedAssertionOnlyOnRetractedSources;

// ===================================================================================================
// V-302r -- replaces V-302; ruling W00-R-35
// Only a well-formed current ComparabilityAssessment licenses a cross-assay pair (W07-SR-11: N10 masks N1 under V-302).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-302: measured results compared across different assay versions need a COMPARABLE or COMPARABLE_WITH_CONVERSION assessment.
// | // status: statically-checked
// | MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
// | WHERE elementId(r1) < elementId(r2)
// | MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
// |       (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
// | WHERE a1 <> a2
// |   AND NOT EXISTS {
// |     MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
// |     MATCH (ca)-[:COMPARES]->(a2)
// |     WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
// |   }
// | RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;
// REVISED:
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
RETURN 'V-302r' AS check, r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// ===================================================================================================
// V-303r -- replaces V-303; ruling W00-R-35
// A MEASURED result may be pending through an UNRESOLVED PRODUCED_BY_ASSAY_VERSION assertion (W07-SR-09, Everlywell S7).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-303: result kind must match its producing record. Measured results need an assay version;
// | // calculated and inferred results need an algorithm version, unless the link is still an UNRESOLVED
// | // assertion under review (competing proposals), which is the only allowed pending state.
// | // status: statically-checked
// | MATCH (r:DiagnosticResult)
// | WHERE r.resultKind IS NULL
// |    OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion))
// |    OR (r.resultKind IN ['CALCULATED', 'INFERRED']
// |        AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
// |        AND NOT EXISTS {
// |          MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
// |          WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
// |        })
// | RETURN r.uid AS resultUid, r.resultKind AS resultKind;
// REVISED:
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
RETURN 'V-303r' AS check, r.uid AS resultUid, r.resultKind AS resultKind;

// ===================================================================================================
// V-304r -- replaces V-304; ruling W00-R-35
// Same well-formed licence rule as V-302r for algorithm versions (W07-SR-11).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-304: inferred or calculated results compared across different algorithm versions need an assessment.
// | // status: statically-checked
// | MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
// | WHERE elementId(r1) < elementId(r2)
// | MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
// |       (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
// | WHERE v1 <> v2
// |   AND NOT EXISTS {
// |     MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
// |     MATCH (ca)-[:COMPARES]->(v2)
// |     WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
// |   }
// | RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;
// REVISED:
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
RETURN 'V-304r' AS check, r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

// ===================================================================================================
// V-305c -- replaces (new; INV-302 exactly one, complements V-305b); ruling W00-R-35
// No reference interval version bound to two assay versions (W07-SR-11 N4).
// Revised text source: W07/fixtures/w07-validation.cypher
// REVISED:
MATCH (ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WITH ri, collect(DISTINCT a.uid) AS assays
WHERE size(assays) > 1
RETURN 'V-305c' AS check, ri.uid AS intervalUid, assays;

// ===================================================================================================
// V-313r -- replaces V-313; ruling W00-R-06
// Stored privacy classes are the GraphQL enum names PUBLIC/INTERNAL (W07-SR-15: V-313 flags all 15 W07 positive results).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-313: every DiagnosticResult declares a privacy class (placement is Lane 5's decision).
// | // status: statically-checked
// | MATCH (r:DiagnosticResult)
// | WHERE r.privacyClass IS NULL
// |    OR NOT r.privacyClass IN ['public', 'internal', 'private-personal', 'synthetic']
// | RETURN r.uid AS resultUid;
// REVISED:
MATCH (r:DiagnosticResult)
WHERE r.privacyClass IS NULL OR NOT r.privacyClass IN ['PUBLIC', 'INTERNAL'] OR r.uid STARTS WITH 'hu:private-'
RETURN 'V-313r' AS check, r.uid AS resultUid, r.privacyClass AS privacyClass;

// ===================================================================================================
// V-322r -- replaces V-322; ruling W00-R-36
// A current APPROVAL status backed by an approving response (W13-SR-15, N-07).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-322: live projection Product.status = 'APPROVED' requires an APPROVAL status of that product.
// | // status: statically-checked
// | MATCH (p:Product)
// | WHERE p.status = 'APPROVED'
// |   AND NOT EXISTS {
// |     MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(p)
// |     WHERE s.statusKind = 'APPROVAL'
// |   }
// | RETURN coalesce(p.uid, p.id) AS productWithUnbackedApproval;
// REVISED:
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus {statusKind: 'APPROVAL'})-[e:STATUS_OF]->(p)
    WHERE e.recordedTo IS NULL
      AND EXISTS { (s)-[:RESULTS_FROM_RESPONSE]->(r:RegulatoryResponse) WHERE r.responseKind IN ['APPROVED', 'PMA_APPROVED'] }
  }
RETURN 'V-322r' AS check, p.uid AS productWithUnbackedApproval;

// ===================================================================================================
// V-324r -- replaces V-324; ruling W00-R-36
// Allowlist of authority-bearing source kinds instead of a marketing denylist (W11-SR-11).
// Revised text source: W11/fixtures/w11-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-324: an OPERATING capability state needs a non-marketing source or a SUPPORTED adjudication.
// | // status: statically-checked
// | MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
// | WHERE c.stage = 'OPERATING'
// | OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
// | OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
// | WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
// | WHERE a IS NULL
// |    OR (all(k IN kinds WHERE k IN ['MARKETING_PAGE', 'THIRD_PARTY_DIRECTORY', 'PRESS_RELEASE'])
// |        AND NOT EXISTS {
// |          MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
// |          WHERE j.verdict = 'SUPPORTED'
// |        })
// | RETURN holder.uid AS holderUid, c.uid AS capabilityUid, kinds AS supportingSourceKinds;
// REVISED:
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE c.stage = 'OPERATING'
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
WHERE a IS NULL
   OR (NOT any(k IN kinds WHERE k IN ['SECURITIES_FILING', 'REGULATORY_RECORD', 'AUDIT_REPORT', 'CERTIFICATION_LISTING', 'LEGAL_RECORD'])
       AND NOT EXISTS {
         MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
         WHERE j.verdict = 'SUPPORTED' AND j.recordedTo IS NULL
       })
RETURN 'V-324r' AS check, holder.uid AS holderUid, h.relationshipUid AS episode, c.uid AS capabilityUid, kinds AS supportingSourceKinds;

// ===================================================================================================
// V-333r -- replaces V-333; ruling W00-R-36
// Count DISTINCT subjects; at most one current STATUS_OF episode (W13-SR-15, LDT ED v2).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-333: regulatory statuses carry a known status kind, a jurisdiction, and exactly one subject.
// | // status: statically-checked
// | MATCH (s:RegulatoryStatus)
// | OPTIONAL MATCH (s)-[:STATUS_OF]->(x)
// | WITH s, count(x) AS subjects
// | WHERE subjects <> 1
// |    OR s.jurisdiction IS NULL
// |    OR s.statusKind IS NULL
// |    OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
// |                            'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
// | RETURN s.uid AS statusUid, s.statusKind AS statusKind, subjects;
// REVISED:
MATCH (s:RegulatoryStatus)
OPTIONAL MATCH (s)-[e:STATUS_OF]->(x)
WITH s, count(DISTINCT x) AS subjects, count(CASE WHEN e.recordedTo IS NULL THEN 1 END) AS currentEpisodes
WHERE subjects <> 1 OR currentEpisodes > 1
   OR s.jurisdiction IS NULL OR s.statusKind IS NULL
   OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
                           'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
RETURN 'V-333r' AS check, s.uid AS statusUid, s.statusKind AS statusKind, subjects, currentEpisodes;

// ===================================================================================================
// V-334r -- replaces V-334; ruling W00-R-36
// Compare the current STATUS_OF episode with the current HAS_PATHWAY_VERSION episode of its legal-basis version (W13-SR-15).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-334: a status cannot outlive the legal basis it depends on (for example the 2024 LDT rule, vacated 2025-03-31).
// | // status: statically-checked
// | MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
// | WHERE pw.effectiveTo IS NOT NULL
// |   AND (s.effectiveTo IS NULL OR s.effectiveTo > pw.effectiveTo)
// | RETURN s.uid AS statusUid, pw.uid AS pathwayUid, pw.effectiveTo AS basisEnded;
// REVISED:
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)<-[pv:HAS_PATHWAY_VERSION]-(:RegulatoryPathway)
WHERE pv.recordedTo IS NULL
MATCH (s)-[e:STATUS_OF]->()
WHERE e.recordedTo IS NULL
WITH s, v, pv, e
WHERE (pv.validTo IS NOT NULL AND (e.validTo IS NULL OR e.validTo > pv.validTo))
   OR (pv.validFrom IS NOT NULL AND e.validFrom IS NOT NULL AND e.validFrom < pv.validFrom)
RETURN 'V-334r' AS check, s.uid AS statusUid, v.uid AS versionUid, e.validFrom AS statusFrom, e.validTo AS statusTo,
       pv.validFrom AS basisFrom, pv.validTo AS basisTo;

// ===================================================================================================
// V-407r -- replaces V-407; ruling W00-R-40
// W20-V01 adopted (W20-SR-18): every start label and SUPPORTED_BY_CHUNK; fixture 02: V-407 1 of 4 defects, W20-V01 all 4.
// Revised text source: W20/operations.cypher W20-V01
// ORIGINAL (kept for comparison; not executed):
// | // V-407: an Assertion may point SUPPORTED_BY at a Chunk only as a derived
// | // shortcut naming the locator it projects, and that locator must also be linked.
// | // status: statically-checked
// | MATCH (a:Assertion)-[r:SUPPORTED_BY]->(c:Chunk)
// | WHERE r.locatorUid IS NULL
// |    OR NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator) WHERE l.uid = r.locatorUid }
// | RETURN a.uid AS assertionUid, c.uid AS chunkWithoutLocator;
// REVISED:
MATCH (x)-[r:SUPPORTED_BY|SUPPORTED_BY_CHUNK]->(c:Chunk)
OPTIONAL MATCH (l:SourceLocator {uid: r.locatorUid})
WITH x, r, c, l,
     [v IN [
        CASE WHEN type(r) = 'SUPPORTED_BY' THEN 'LEGACY_SUPPORTED_BY_TO_CHUNK' END,
        CASE WHEN r.locatorUid IS NULL THEN 'NO_LOCATOR_UID' END,
        CASE WHEN r.locatorUid IS NOT NULL AND l IS NULL THEN 'LOCATOR_MISSING' END,
        CASE WHEN r.derivationRule IS NULL THEN 'NO_DERIVATION_RULE' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (l)-[rr:RESOLVES_TO_CHUNK]->(c) WHERE rr.segmentationHash = r.segmentationHash }
             THEN 'LOCATOR_DOES_NOT_RESOLVE_TO_CHUNK' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (sa:Assertion)-[:SUPPORTED_BY]->(l) WHERE sa.uid IN coalesce(r.derivedFromAssertionUids, []) }
             THEN 'NO_INPUT_ASSERTION_SUPPORTED_BY_LOCATOR' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-407r' AS check, type(r) AS relType, x.uid AS startUid, labels(x)[0] AS startLabel, c.uid AS chunkUid, violations
ORDER BY startUid, chunkUid;

// ===================================================================================================
// V-409r -- replaces V-409; ruling W00-R-31
// Order REANCHORS by the content clock coalesce(observedAt, retrievedAt) (W19-SR-09, W04-SR-02): archive captures fetched late.
// Revised text source: W00 fixtures/validation-w00.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-409: REANCHORS links locators on two snapshots of the same Source, newer to older.
// | // status: statically-checked
// | MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
// | MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
// | WHERE x.anchorMatch IS NULL
// |    OR sNew = sOld
// |    OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
// |    OR sNew.retrievedAt <= sOld.retrievedAt
// | RETURN newL.uid AS newLocator, oldL.uid AS oldLocator;
// REVISED:
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR coalesce(sNew.observedAt, sNew.retrievedAt) <= coalesce(sOld.observedAt, sOld.retrievedAt)
RETURN 'V-409r' AS check, newL.uid AS newLocator, oldL.uid AS oldLocator;

// ===================================================================================================
// V-416r -- replaces V-416; ruling W00-R-40
// QUALIFIED_BY without a container requires a shared SourceSnapshot (W21-SR-23 / W08-SR-10 device qualifiers).
// Revised text source: W21/fixtures/w21-validation.cypher V-W21-12
// ORIGINAL (kept for comparison; not executed):
// | // V-416: QUALIFIED_BY names its kind and stays inside one container.
// | // status: statically-checked
// | MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
// | WHERE q.qualificationKind IS NULL
// |    OR NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) }
// | RETURN a.uid AS qualifiedUid, b.uid AS qualifierUid;
// REVISED:
MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
WHERE q.qualificationKind IS NULL
   OR ((EXISTS { (a)-[:OCCURS_IN]->() } OR EXISTS { (b)-[:OCCURS_IN]->() })
       AND NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) })
   OR (NOT EXISTS { (a)-[:OCCURS_IN]->() } AND NOT EXISTS { (b)-[:OCCURS_IN]->() }
       AND NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(b) })
RETURN 'V-416r' AS check, a.uid AS qualifiedUid, b.uid AS qualifierUid;

// ===================================================================================================
// V-423r -- replaces V-423; ruling W00-R-25
// Derived RECOMMENDS: derivationRule + exactly one derivedFromAssertionUids whose assertion has speechAct RECOMMENDS, is asserted by
// the start node and names the end node (W21-SR-07; D-011 forbids assertionUid on derived edges; legacy assertionUid accepted only
// as a migration fallback and reported by V-W00-02r). Failing case W21 fx07: verbatim V-423 1 row on a correct edge.
// Revised text source: W21/fixtures/w21-validation.cypher V-W21-06
// ORIGINAL (kept for comparison; not executed):
// | // V-423: live Person-[:RECOMMENDS]-> is a projection of an assertion whose own
// | // speech act is RECOMMENDS (a practice report or a third party's attribution does not count).
// | // status: statically-checked
// | MATCH (p:Person)-[rec:RECOMMENDS]->(x)
// | WHERE rec.assertionUid IS NULL
// |    OR NOT EXISTS {
// |      MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
// |      WHERE a.uid = rec.assertionUid AND a.speechAct = 'RECOMMENDS'
// |    }
// | RETURN p.uid AS recommenderUid, x.uid AS recommendedUid;
// REVISED:
MATCH (p)-[rec:RECOMMENDS]->(x)
WITH p, x, rec, coalesce(rec.derivedFromAssertionUids, CASE WHEN rec.assertionUid IS NULL THEN [] ELSE [rec.assertionUid] END) AS cited
WHERE size(cited) <> 1
   OR (rec.assertionUid IS NULL AND rec.derivationRule IS NULL)
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = cited[0] AND a.speechAct = 'RECOMMENDS' AND NOT a.status IN ['REJECTED', 'SUPERSEDED']
       AND (EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR EXISTS { (a)-[:HAS_OBJECT]->(x) })
   }
RETURN 'V-423r' AS check, p.uid AS recommenderUid, x.uid AS recommendedUid, cited;

// ===================================================================================================
// V-432r -- replaces V-432; ruling W00-R-32
// COMPARES_IDENTITIES (not COMPARES, which is W07 ComparabilityAssessment) plus the SAME_IDENTITY_MERGED redirect fields
// (W23-SR-07, W00-SR-12, W00-R-11). Failing case W23 fixture 04 and W00 fixture 08: comparedCount 0 on well-formed assessments.
// ORIGINAL (kept for comparison; not executed):
// | // ---------------------------------------------------------------------
// | // E. Ecosystem identity (CQ-EC-02)
// | // ---------------------------------------------------------------------
// | 
// | // V-432: an EquivalenceAssessment compares exactly two distinct nodes and never
// | // coexists with a merged node carrying both compared kinds.
// | // status: statically-checked
// | MATCH (e:EquivalenceAssessment)
// | OPTIONAL MATCH (e)-[:COMPARES]->(n)
// | WITH e, collect(DISTINCT n) AS ns
// | WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
// | RETURN e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount;
// REVISED:
MATCH (e:EquivalenceAssessment)
OPTIONAL MATCH (e)-[:COMPARES_IDENTITIES]->(n)
WITH e, collect(DISTINCT n) AS ns
WITH e, ns, [n IN ns | n.uid] AS uids
WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
   OR (e.equivalenceKind = 'SAME_IDENTITY_MERGED'
       AND (e.survivingUid IS NULL OR e.retiredUid IS NULL OR e.survivingUid = e.retiredUid
            OR NOT e.survivingUid IN uids OR NOT e.retiredUid IN uids))
   OR (e.equivalenceKind <> 'SAME_IDENTITY_MERGED' AND (e.survivingUid IS NOT NULL OR e.retiredUid IS NOT NULL))
RETURN 'V-432r' AS check, e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount, e.equivalenceKind AS equivalenceKind;

// ===================================================================================================
// V-503r -- replaces V-503; ruling W00-R-37
// Bound/precision/basis agreement on assertions AND on every bitemporal edge ($episodeTypes or any edge with assertionUid),
// including HAS_CERTIFICATION_SCOPE (W12-SR-09, negative N11: OBSERVATION_ONLY end caught only by V-W12-10); statedAsOf needs its
// precision (W00-R-13). INFERRED needs a derivationRule on the assertion (edges inherit it through V-505r).
// ORIGINAL (kept for comparison; not executed):
// | // V-503: bound, precision, and basis agree. OBSERVATION_ONLY or UNKNOWN basis forces a null bound; a non-null bound
// | // needs a precision; INFERRED needs a derivation rule.
// | // status: statically-checked
// | // 0.2.0 integration: a basis is required when its bound is non-null; a null bound with a null basis reads as UNKNOWN.
// | MATCH (a:Assertion)
// | WHERE (a.validFrom IS NOT NULL AND a.validFromBasis IS NULL)
// |    OR (a.validTo IS NOT NULL AND a.validToBasis IS NULL)
// |    OR (a.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validFrom IS NOT NULL)
// |    OR (a.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validTo IS NOT NULL)
// |    OR (a.validFrom IS NOT NULL AND a.validFromPrecision IS NULL)
// |    OR (a.validTo IS NOT NULL AND a.validToPrecision IS NULL)
// |    OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
// | RETURN a.uid AS assertionWithInconsistentTimeQualifiers;
// REVISED:
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND a.validFromBasis IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToBasis IS NULL)
   OR (a.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validFrom IS NOT NULL)
   OR (a.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validTo IS NOT NULL)
   OR (a.validFrom IS NOT NULL AND a.validFromPrecision IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToPrecision IS NULL)
   OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
   OR (a.statedAsOf IS NOT NULL AND a.statedAsOfPrecision IS NULL)
RETURN 'V-503r' AS check, 'ASSERTION' AS kind, a.uid AS item
UNION
MATCH ()-[h]->()
WHERE type(h) IN $episodeTypes OR h.assertionUid IS NOT NULL
WITH h
WHERE h.validFromBasis IS NULL OR h.validToBasis IS NULL
   OR (h.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND h.validFrom IS NOT NULL)
   OR (h.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND h.validTo IS NOT NULL)
   OR (h.validFrom IS NOT NULL AND h.validFromPrecision IS NULL)
   OR (h.validTo IS NOT NULL AND h.validToPrecision IS NULL)
RETURN 'V-503r' AS check, 'EDGE:' + type(h) AS kind, coalesce(h.relationshipUid, elementId(h)) AS item;

// ===================================================================================================
// V-505r -- replaces V-505 (and V-W00-11); ruling W00-R-37 / W00-R-03
// Projection fidelity on EVERY edge that names an authorizing assertion (asserted_edge and bitemporal_attachment, all episode types;
// W12-SR-09) - V-W00-11 generalized - plus qualifier fidelity (W09-SR-12): an edge property outside the profile fields that the
// assertion also stores must be equal on both (QUALIFIER_DIFFERS:<key>).
// ORIGINAL (kept for comparison; not executed):
// | // V-505: projection fidelity. Episode valid time equals its authorizing assertion's valid time. A correction that
// | // edited valid time in place on either side shows up here.
// | // status: statically-checked
// | MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
// | WHERE h.assertionUid IS NOT NULL
// | MATCH (a:Assertion {uid: h.assertionUid})
// | WHERE coalesce(toString(h.validFrom), '-') <> coalesce(toString(a.validFrom), '-')
// |    OR coalesce(toString(h.validTo), '-') <> coalesce(toString(a.validTo), '-')
// |    OR coalesce(h.validFromPrecision, '-') <> coalesce(a.validFromPrecision, '-')
// |    OR coalesce(h.validToPrecision, '-') <> coalesce(a.validToPrecision, '-')
// |    OR coalesce(toString(h.recordedTo), '-') <> coalesce(toString(a.recordedTo), '-')
// | RETURN h.relationshipUid AS episode, a.uid AS assertionUid;
// REVISED:
MATCH (x)-[r]->(y)
WHERE r.assertionUid IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, y, r, a,
  ['relationshipUid','assertionUid','validFrom','validTo','validFromPrecision','validToPrecision','validFromBasis','validToBasis',
   'recordedFrom','recordedTo','mongoResearchRunId','privacyClass','createdAt','updatedAt','notes','derivedAt'] AS profile
WITH x, y, r, a,
  [v IN [
    CASE WHEN a IS NULL THEN 'ASSERTION_MISSING' END,
    CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } THEN 'SUBJECT_IS_NOT_EDGE_START' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) } THEN 'OBJECT_IS_NOT_EDGE_END' END,
    CASE WHEN a IS NOT NULL AND (coalesce(toString(r.validFrom),'-') <> coalesce(toString(a.validFrom),'-')
           OR coalesce(toString(r.validTo),'-') <> coalesce(toString(a.validTo),'-')
           OR coalesce(r.validFromPrecision,'-') <> coalesce(a.validFromPrecision,'-')
           OR coalesce(r.validToPrecision,'-') <> coalesce(a.validToPrecision,'-')
           OR coalesce(r.validFromBasis,'UNKNOWN') <> coalesce(a.validFromBasis,'UNKNOWN')
           OR coalesce(r.validToBasis,'UNKNOWN') <> coalesce(a.validToBasis,'UNKNOWN')) THEN 'VALID_TIME_DIFFERS' END,
    CASE WHEN a IS NOT NULL AND r.recordedFrom < a.recordedAt THEN 'RECORDED_BEFORE_ASSERTION' END,
    CASE WHEN a IS NOT NULL AND coalesce(toString(r.recordedTo),'-') <> coalesce(toString(a.recordedTo),'-') THEN 'RECORDED_TO_DIFFERS' END
  ] WHERE v IS NOT NULL]
  + CASE WHEN a IS NULL THEN [] ELSE [k IN keys(r) WHERE NOT k IN profile AND a[k] IS NOT NULL AND a[k] <> r[k] | 'QUALIFIER_DIFFERS:' + k] END AS violations
WHERE size(violations) > 0
RETURN 'V-505r' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, violations;

// ===================================================================================================
// V-505i (informational) -- replaces (new; W09-SR-12 migration audit); ruling W00-R-03
// Informational: an asserted edge carries a qualifier property that its authorizing assertion does not store (the edge would lose it on
// regeneration). Rows are migration items, not violations.
// REVISED:
MATCH ()-[r]->()
WHERE r.assertionUid IS NOT NULL
MATCH (a:Assertion {uid: r.assertionUid})
WITH r, a, [k IN keys(r) WHERE NOT k IN ['relationshipUid','assertionUid','validFrom','validTo','validFromPrecision','validToPrecision',
   'validFromBasis','validToBasis','recordedFrom','recordedTo','mongoResearchRunId','privacyClass','createdAt','updatedAt','notes','derivedAt']
   AND a[k] IS NULL] AS edgeOnly
WHERE size(edgeOnly) > 0
RETURN 'V-505i' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, edgeOnly;

// ===================================================================================================
// V-512r -- replaces V-512; ruling W00-R-31
// REVISION_ORDER on the content clock (W19-SR-09).
// Revised text source: W00 fixtures/validation-w00.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-512: source revision events are well formed: exactly one revised source; prior and resulting snapshots belong
// | // to that source; the resulting snapshot was retrieved after the prior one.
// | // status: statically-checked
// | MATCH (ev:SourceRevisionEvent)
// | OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
// | WITH ev, collect(src) AS sources
// | WHERE size(sources) <> 1
// | RETURN 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
// | UNION
// | MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
// | WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
// | RETURN 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
// | UNION
// | MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
// | WHERE res.retrievedAt <= prior.retrievedAt
// | RETURN 'REVISION_ORDER' AS violation, ev.uid AS item;
// REVISED:
MATCH (ev:SourceRevisionEvent)
OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
WITH ev, collect(src) AS sources
WHERE size(sources) <> 1
RETURN 'V-512r' AS check, 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
UNION
MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
RETURN 'V-512r' AS check, 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
UNION
MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
WHERE coalesce(res.observedAt, res.retrievedAt) <= coalesce(prior.observedAt, prior.retrievedAt)
RETURN 'V-512r' AS check, 'REVISION_ORDER' AS violation, ev.uid AS item;

// ===================================================================================================
// V-521r -- replaces V-521; ruling W00-R-06
// Privacy class branch: any stored value other than PUBLIC/INTERNAL is a violation (catches PRIVATE_PERSONAL; W23-SR-08 fixture 10 2e),
// and private uids inside LIST properties of relationships (V-W23-10). Absorbs V-W23-09 and V-W23-10.
// ORIGINAL (kept for comparison; not executed):
// | // V-521: no private uid values or private-personal class on shared nodes or relationships.
// | // status: statically-checked
// | MATCH (n)
// | WHERE NOT n:PrivateRecord AND (n.privacyClass = 'private-personal'
// |    OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
// |    OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
// | RETURN 'NODE' AS kind, n.uid AS item
// | UNION
// | MATCH (x)-[r]->(y)
// | WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
// |   AND (r.privacyClass = 'private-personal'
// |        OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-'))
// | RETURN 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item;
// REVISED:
MATCH (n)
WHERE NOT n:PrivateRecord AND ((n.privacyClass IS NOT NULL AND NOT n.privacyClass IN ['PUBLIC', 'INTERNAL'])
   OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
   OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
RETURN 'V-521r' AS check, 'NODE' AS kind, n.uid AS item, n.privacyClass AS privacyClass
UNION
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
  AND ((r.privacyClass IS NOT NULL AND NOT r.privacyClass IN ['PUBLIC', 'INTERNAL'])
       OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-')
       OR any(k IN keys(r) WHERE r[k] IS :: LIST<STRING> AND any(v IN r[k] WHERE v STARTS WITH 'hu:private-')))
RETURN 'V-521r' AS check, 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item, r.privacyClass AS privacyClass;

// ===================================================================================================
// V-525r -- replaces V-525; ruling W00-R-38
// Restated on HAS_PROTOCOL_STEP (D-004 implementation; catalog V-525 matches HAS_STEP and sees nothing) (W16-SR-14).
// Revised text source: W16/fixtures/00-w16-validators.cypher V-525p
// ORIGINAL (kept for comparison; not executed):
// | // V-525: protocol editions: stepKey unique within an edition; CONDITIONAL steps name an APPLIES_WHEN constraint.
// | // status: statically-checked
// | MATCH (e:ProtocolEdition)-[:HAS_STEP]->(s:ProtocolStep)
// | WITH e, s.stepKey AS stepKey, count(*) AS n
// | WHERE stepKey IS NULL OR n > 1
// | RETURN 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item
// | UNION
// | MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
// | WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
// | RETURN 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item;
// REVISED:
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WITH e, s.stepKey AS stepKey, count(*) AS n
WHERE stepKey IS NULL OR n > 1
RETURN 'V-525r' AS check, 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item, stepKey AS detail
UNION
MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
RETURN 'V-525r' AS check, 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item, s.stepKey AS detail;

// ===================================================================================================
// V-526r (informational) -- replaces V-526; ruling W00-R-38
// Restated on HAS_PROTOCOL_STEP (W16-SR-14).
// Revised text source: W16/fixtures/00-w16-validators.cypher V-526p
// ORIGINAL (kept for comparison; not executed):
// | // V-526: protocol steps are immutable payload: a step shared by two editions keeps one payloadHash by construction;
// | // two different step nodes with the same stepKey and payloadHash inside one protocol lineage are duplicates (informational).
// | // status: statically-checked
// | MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s1:ProtocolStep),
// |       (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s2:ProtocolStep)
// | WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
// | RETURN DISTINCT p.uid AS protocolUid, s1.stepKey AS duplicatedStep;
// REVISED:
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s1:ProtocolStep),
      (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s2:ProtocolStep)
WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
RETURN DISTINCT 'V-526r' AS check, 'DUPLICATE_STEP_PAYLOAD' AS violation, p.uid AS item, s1.stepKey AS detail;

// ===================================================================================================
// V-W00-13 -- replaces (new); ruling W00-R-11
// Merge redirect hygiene: a SAME_IDENTITY_MERGED retired node is kept with maturity DEPRECATED, never a private uid, and redirects do
// not form a two-step cycle. Fixture 13 exercises it.
// REVISED:
MATCH (e:EquivalenceAssessment {equivalenceKind: 'SAME_IDENTITY_MERGED'})
OPTIONAL MATCH (old {uid: e.retiredUid})
OPTIONAL MATCH (back:EquivalenceAssessment {equivalenceKind: 'SAME_IDENTITY_MERGED', retiredUid: e.survivingUid, survivingUid: e.retiredUid})
WITH e, old, back
WHERE old IS NULL OR coalesce(old.maturity, '') <> 'DEPRECATED'
   OR e.survivingUid STARTS WITH 'hu:private-' OR e.retiredUid STARTS WITH 'hu:private-'
   OR back IS NOT NULL
RETURN 'V-W00-13' AS check, e.uid AS redirect, e.retiredUid AS retiredUid, old.maturity AS retiredMaturity, back.uid AS cycleWith;

// ===================================================================================================
// V-W00-15 -- replaces (new); ruling W00-R-16 / -17 / -19 / -20
// One relationship type, one meaning (CL-014): HAS_SNAPSHOT only Source -> SourceSnapshot (state caches use HAS_STATE); EVALUATES only
// Adjudication -> Assertion (legacy study edge is LEGACY_EVALUATES); MENTIONS only SourceLocator -> Mention (retrieval uses
// MENTIONS_ENTITY); IDENTIFIED_BY is relabelled HAS_IDENTIFIER; OCCURS_IN_SEGMENT is the W21 structural ClaimOccurrence ->
// EpisodeSegment edge and a chunk overlap is CHUNK_IN_SEGMENT (W00-R-23). Rows are migration items until the relabel runs.
// REVISED:
MATCH (x)-[r:HAS_SNAPSHOT|EVALUATES|MENTIONS|IDENTIFIED_BY|OCCURS_IN_SEGMENT]->(y)
WITH x, r, y, CASE type(r)
    WHEN 'HAS_SNAPSHOT' THEN CASE WHEN x:Source AND y:SourceSnapshot THEN null ELSE 'USE_HAS_STATE' END
    WHEN 'EVALUATES' THEN CASE WHEN x:Adjudication AND y:Assertion THEN null ELSE 'USE_LEGACY_EVALUATES' END
    WHEN 'MENTIONS' THEN CASE WHEN x:SourceLocator AND y:Mention THEN null ELSE 'USE_MENTIONS_ENTITY' END
    WHEN 'OCCURS_IN_SEGMENT' THEN CASE WHEN x:Chunk THEN 'USE_CHUNK_IN_SEGMENT' ELSE null END
    ELSE 'USE_HAS_IDENTIFIER' END AS fix
WHERE fix IS NOT NULL
RETURN 'V-W00-15' AS check, type(r) AS relType, labels(x)[0] AS fromLabel, labels(y)[0] AS toLabel, count(*) AS edges, fix;

// ===================================================================================================
// V-W00-16 -- replaces (new; INV-106 token half); ruling W00-R-01
// The uid token is the registered token of one of the node's labels (uid-token-registry.yaml, passed as $uidTypeTokens).
// Violations: TOKEN_NOT_REGISTERED_FOR_LABEL, LABEL_HAS_NO_TOKEN. FIXTURE_ALIAS_TOKEN rows (0.2.0 lower-case alias tokens, rule T4) are
// migration items, not violations.
// REVISED:
MATCH (n)
WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND NOT n.uid STARTS WITH 'hu:private-'
WITH n, split(n.uid, ':')[1] AS token,
     [l IN labels(n) WHERE $uidTypeTokens[l] IS NOT NULL | $uidTypeTokens[l]] AS registered,
     coalesce(head([l IN labels(n) WHERE NOT l IN ['Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment']]), labels(n)[0]) AS primaryLabel
WHERE size(registered) = 0 OR NOT token IN registered
RETURN 'V-W00-16' AS check, primaryLabel, token, registered, count(*) AS nodes,
       CASE WHEN token IN $uidAliasTokens THEN 'FIXTURE_ALIAS_TOKEN'
            WHEN size(registered) = 0 THEN 'LABEL_HAS_NO_TOKEN' ELSE 'TOKEN_NOT_REGISTERED_FOR_LABEL' END AS violation;

// ===================================================================================================
// V-W00-17 -- replaces (new); ruling W00-R-08
// sourceKind OTHER requires sourceKindNote (W19-SR-01); revision states are never kinds.
// REVISED:
MATCH (s:Source)
WHERE s.sourceKind = 'OTHER' AND (s.sourceKindNote IS NULL OR trim(s.sourceKindNote) = '')
RETURN 'V-W00-17' AS check, s.uid AS sourceWithoutKindNote;

// ===================================================================================================
// V-W00-19 -- replaces (new; W19 Q-02 promoted); ruling W00-R-15
// A Source canonicalUri is a retrieval endpoint, never an identifier resolver (W19-SR-10, fixture 90 N2).
// REVISED:
MATCH (s:Source)
WHERE s.canonicalUri =~ '(?i)https?://(dx\\.)?doi\\.org/.*' OR s.canonicalUri =~ '(?i)https?://identifiers\\.org/.*'
   OR s.canonicalUri =~ '(?i)https?://(www\\.)?ncbi\\.nlm\\.nih\\.gov/pubmed/\\?term=.*'
RETURN 'V-W00-19' AS check, s.uid AS sourceWithResolverUri, s.canonicalUri AS canonicalUri;
