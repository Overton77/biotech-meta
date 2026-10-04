// =====================================================================================================================
// W06 proposed validators V-W06-01 .. V-W06-08b (zero rows = valid, except V-W06-02 and V-W06-07i which are
// informational reports). Static Cypher for Neo4j 5.26; no APOC. Expected rows over fixtures 00-05+98+99 are listed in
// 06-fixtures-and-queries.md. Each statement is independent.
// =====================================================================================================================

// V-W06-01: developmentStage display reads as approval but no ACCEPTED APPROVAL is reachable (V-322 pattern lifted to
// the treatment concept). Path: Treatment -USES_COMPONENT{ADMINISTERED_PRODUCT}-> Product <-STATUS_OF|APPROVAL_FOR- RegulatoryStatus.
MATCH (t:Treatment)
WHERE t.developmentStage IS NOT NULL
  AND toLower(t.developmentStage) =~ '.*(approv|licen[cs]|authori[sz]|marketed).*'
OPTIONAL MATCH (t)-[u:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(:Product)<-[r:STATUS_OF|APPROVAL_FOR]-(s:RegulatoryStatus {statusKind: 'APPROVAL'})
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH t, collect(DISTINCT s.uid) AS approvals, collect(DISTINCT a.status) AS approvalAssertionStatuses
OPTIONAL MATCH (t)-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(:Product)<-[:DESIGNATION_FOR|STATUS_OF]-(d:RegulatoryStatus {statusKind: 'DESIGNATION'})
WITH t, approvals, approvalAssertionStatuses, count(DISTINCT d) AS designations
WHERE NOT 'ACCEPTED' IN approvalAssertionStatuses
RETURN 'V-W06-01' AS check, t.uid AS treatmentUid, t.developmentStage AS stageText,
       CASE WHEN size(approvals) > 0 THEN 'APPROVAL_ONLY_FROM_UNACCEPTED_CAPTURE'
            WHEN designations > 0 THEN 'DESIGNATION_ONLY'
            ELSE 'NO_APPROVAL_STATUS' END AS reason
ORDER BY treatmentUid;

// V-W06-02 (informational): display projections without a named source (migrated legacy text).
MATCH (t:Treatment)
WHERE (t.developmentStage IS NOT NULL AND t.developmentStageAssertionUid IS NULL)
   OR (t.orphanDrugDesignation IS NOT NULL AND size(coalesce(t.orphanDesignationStatusUids, [])) = 0)
RETURN 'V-W06-02' AS check, t.uid AS treatmentUid,
       [f IN [CASE WHEN t.developmentStage IS NOT NULL AND t.developmentStageAssertionUid IS NULL THEN 'developmentStage' END,
              CASE WHEN t.orphanDrugDesignation IS NOT NULL AND size(coalesce(t.orphanDesignationStatusUids, [])) = 0 THEN 'orphanDrugDesignation' END]
        WHERE f IS NOT NULL] AS unbackedDisplayFields
ORDER BY treatmentUid;

// V-W06-03: orphan designation text read as approval: designation text present, stage text reads approved, and only
// DESIGNATION states (no APPROVAL state of any capture status) are reachable.
MATCH (t:Treatment)
WHERE t.orphanDrugDesignation IS NOT NULL AND t.developmentStage IS NOT NULL
  AND toLower(t.developmentStage) =~ '.*(approv|licen[cs]|authori[sz]|marketed).*'
  AND NOT EXISTS { (t)-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(:Product)<-[:STATUS_OF|APPROVAL_FOR]-(:RegulatoryStatus {statusKind: 'APPROVAL'}) }
RETURN 'V-W06-03' AS check, t.uid AS treatmentUid, t.orphanDrugDesignation AS designationText, t.developmentStage AS stageText;

// V-W06-04: INV-201 through the concept: any edge from a study-side record to a commercial identity, or any edge whose
// derivation cites FOLLOWS_INTERVENTION_DEFINITION / USES_COMPONENT assertions and ends at a Product.
MATCH (x)-[r]->(p)
WHERE (x:Study OR x:StudyArm OR x:StudyIntervention OR x:StudyResult OR x:Publication)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion)
OPTIONAL MATCH (cited:Assertion) WHERE cited.uid IN coalesce(r.derivedFromAssertionUids, [])
WITH x, r, p, collect(cited.predicate) AS citedPredicates
RETURN 'V-W06-04' AS check, x.uid AS fromUid, type(r) AS edgeType, p.uid AS productUid, citedPredicates,
       any(c IN citedPredicates WHERE c IN ['FOLLOWS_INTERVENTION_DEFINITION', 'USES_COMPONENT']) AS viaTreatmentConcept;

// V-W06-05: COMBINATION requires at least two USES_COMPONENT edges.
MATCH (t:Treatment)
WHERE 'COMBINATION' IN coalesce(t.modalities, [])
WITH t, COUNT { (t)-[:USES_COMPONENT]->() } AS components
WHERE components < 2
RETURN 'V-W06-05' AS check, t.uid AS treatmentUid, components;

// V-W06-06 (warning): a preparatory/collection/co-intervention component whose authorizing assertion rests only on
// trial-registration locators (a study-specific regimen promoted to the concept).
MATCH (t:Treatment)-[r:USES_COMPONENT]->(c)
WHERE r.componentRole IN ['PREPARATORY_PROCEDURE', 'STARTING_MATERIAL_COLLECTION', 'CO_INTERVENTION']
MATCH (a:Assertion {uid: r.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH t, r, c, collect(DISTINCT src.canonicalUri) AS sources
WHERE all(u IN sources WHERE u CONTAINS 'clinicaltrials.gov')
RETURN 'V-W06-06' AS check, t.uid AS treatmentUid, r.componentRole AS role, c.uid AS componentUid, sources;

// V-W06-07: procedure or treatment identities equated on a shared classification code alone.
MATCH (e:EquivalenceAssessment)-[:COMPARES_IDENTITIES]->(a), (e)-[:COMPARES_IDENTITIES]->(b)
WHERE (a:Procedure OR a:Treatment) AND a.uid < b.uid
  AND e.equivalenceKind = 'SAME_WORK_DIFFERENT_NAME' AND e.basis = 'SHARED_CLASSIFICATION_CODE'
RETURN 'V-W06-07' AS check, e.uid AS assessmentUid, a.uid AS leftUid, b.uid AS rightUid;

// V-W06-07i (informational): classification codes shared by more than one Procedure (never an identity signal).
MATCH (p:Procedure)-[:HAS_IDENTIFIER]->(i:Identifier)
WITH i, collect(p.uid) AS procedures
WHERE size(procedures) > 1
RETURN 'V-W06-07i' AS check, i.scheme AS scheme, i.value AS code, procedures
ORDER BY code;

// V-W06-08: W06 asserted edges must cite a live assertion of the same predicate, subject and object (INV-101, QS-4a core).
MATCH (x)-[r:TARGETS_CONDITION|USES_COMPONENT|DEVELOPS_TREATMENT|OFFERS_TREATMENT|OFFERS_PROCEDURE|FOLLOWS_INTERVENTION_DEFINITION]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, r, y, a,
     [v IN [
        CASE WHEN r.assertionUid IS NULL THEN 'NO_ASSERTION_UID' END,
        CASE WHEN r.recordedFrom IS NULL THEN 'NO_RECORDED_FROM' END,
        CASE WHEN r.validFromBasis IS NULL OR r.validToBasis IS NULL THEN 'NO_VALID_TIME_BASIS' END,
        CASE WHEN r.assertionUid IS NOT NULL AND a IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN a IS NOT NULL AND NOT EXISTS { (a)-[:HAS_SUBJECT]->(x) } THEN 'CITED_SUBJECT_IS_NOT_EDGE_START' END,
        CASE WHEN a IS NOT NULL AND NOT EXISTS { (a)-[:HAS_OBJECT]->(y) } THEN 'CITED_OBJECT_IS_NOT_EDGE_END' END,
        CASE WHEN type(r) = 'USES_COMPONENT' AND r.componentRole IS NULL THEN 'NO_COMPONENT_ROLE' END,
        CASE WHEN type(r) = 'TARGETS_CONDITION' AND (r.intentKind IS NULL OR r.intentBasis IS NULL) THEN 'NO_INTENT_QUALIFIERS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-W06-08' AS check, type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, r.relationshipUid AS relationshipUid, violations
ORDER BY relationshipUid;

// V-W06-08b: no private-personal content on W06 shared types (INV-506; companion of V-113..V-116).
MATCH (n)
WHERE (n:Treatment OR n:Procedure)
  AND (n.uid STARTS WITH 'hu:private-' OR NOT coalesce(n.privacyClass, 'PUBLIC') IN ['PUBLIC', 'INTERNAL'])
RETURN 'V-W06-08b' AS check, n.uid AS uid, n.privacyClass AS privacyClass;

// QS-4a instantiated with W06 forbidden-implication pairs (zero rows = valid).
WITH [['HOSTS_LISTING', 'OFFERS_PROCEDURE'], ['LISTS_PROCEDURE', 'OFFERS_PROCEDURE'], ['LISTS_PROCEDURE', 'OFFERS_TREATMENT'],
      ['SPONSORS_STUDY', 'DEVELOPS_TREATMENT'], ['MANUFACTURES_PRODUCT', 'DEVELOPS_TREATMENT'], ['SUBMITTED_BY', 'DEVELOPS_TREATMENT'],
      ['OFFERS_PROCEDURE', 'PERFORMS_PROCEDURE'], ['OFFERS_TREATMENT', 'RECOMMENDS']] AS implicationPairs
MATCH (x)-[r]->(y)
WHERE type(r) IN [p IN implicationPairs | p[1]]
WITH x, y, r, implicationPairs, r.assertionUid AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, cited, citedUid,
     [v IN [
        CASE WHEN citedUid IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'QS-4a/W06' AS check, type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;
