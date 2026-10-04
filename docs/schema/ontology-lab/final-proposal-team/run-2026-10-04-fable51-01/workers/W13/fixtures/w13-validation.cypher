// W13 validation suite: catalog regulatory validators (verbatim where unchanged, "r" suffix where W13 proposes a
// revision) plus proposed V-W13-01..12. Every query returns zero rows on a valid committed graph. Read-only.
// Run status per query is recorded in 06-fixtures-and-queries.md (embedded Neo4j 5.26.31 Community, this session).

// V-320a (catalog, verbatim): an approval status may not result from a notification, notice, registration, clearance, De Novo, or designation response.
MATCH (s:RegulatoryStatus)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)
WHERE s.statusKind = 'APPROVAL'
  AND resp.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'NDI_INCOMPLETE', 'NDI_OBJECTION', 'NDI_OTHER_REGULATORY_ISSUE',
                            'GRAS_NO_QUESTIONS', 'GRAS_NO_BASIS', 'GRAS_CEASED_AT_NOTIFIER_REQUEST',
                            'REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED', 'SUBSTANTIALLY_EQUIVALENT', 'DE_NOVO_GRANTED',
                            'ORPHAN_DESIGNATION_GRANTED']
RETURN 'V-320a' AS check, s.uid AS statusUid, resp.uid AS responseUid, resp.responseKind AS responseKind;

// V-320b (catalog, verbatim): an approval status may not sit under a non-approval legal basis.
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE s.statusKind = 'APPROVAL'
  AND pw.pathwayKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE', 'FOOD_FACILITY_REGISTRATION', 'DEVICE_ESTABLISHMENT_REGISTRATION',
                         'PREMARKET_NOTIFICATION_510K', 'DE_NOVO', 'ORPHAN_DESIGNATION', 'COMPOUNDING_503B_BULKS_POLICY', 'LDT_POLICY']
RETURN 'V-320b' AS check, s.uid AS statusUid, pw.pathwayKind AS pathwayKind;

// V-321 (catalog, verbatim): regulatory record kinds never share one node.
MATCH (n)
WHERE (n:RegulatorySubmission AND n:RegulatoryResponse)
   OR (n:RegulatoryStatus AND (n:RegulatorySubmission OR n:RegulatoryResponse))
   OR (n:OrphanDesignation AND n:DrugApproval)
   OR (n:DrugApproval AND n.statusKind IS NOT NULL AND n.statusKind <> 'APPROVAL')
   OR (n:OrphanDesignation AND n.statusKind IS NOT NULL AND n.statusKind <> 'DESIGNATION')
RETURN 'V-321' AS check, n.uid AS collapsedRegulatoryNode, labels(n) AS labels;

// V-322 (catalog, verbatim): live projection Product.status = 'APPROVED' requires an APPROVAL status of that product.
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(p)
    WHERE s.statusKind = 'APPROVAL'
  }
RETURN 'V-322' AS check, coalesce(p.uid, p.id) AS productWithUnbackedApproval;

// V-322r (proposed revision, W13-D12): Product.status = 'APPROVED' requires a current APPROVAL status of that product that
// itself results from an approving response; V-322 as written is satisfied by an unbacked APPROVAL status (fixture N-07).
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus {statusKind: 'APPROVAL'})-[e:STATUS_OF]->(p)
    WHERE e.recordedTo IS NULL
      AND EXISTS { (s)-[:RESULTS_FROM_RESPONSE]->(r:RegulatoryResponse) WHERE r.responseKind IN ['APPROVED', 'PMA_APPROVED'] }
  }
RETURN 'V-322r' AS check, p.uid AS productWithUnbackedApproval;

// V-323 (catalog, verbatim): establishment or facility registration is a status of a Facility only.
MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(x)
WHERE s.statusKind = 'ESTABLISHMENT_REGISTRATION' AND NOT x:Facility
RETURN 'V-323' AS check, s.uid AS statusUid, labels(x) AS attachedTo, x.uid AS attachedUid;

// V-333 (catalog, verbatim): regulatory statuses carry a known status kind, a jurisdiction, and exactly one subject.
// W13-D11: counts STATUS_OF edges, so it fires on a status with two recorded-time episodes; see V-333r.
MATCH (s:RegulatoryStatus)
OPTIONAL MATCH (s)-[:STATUS_OF]->(x)
WITH s, count(x) AS subjects
WHERE subjects <> 1
   OR s.jurisdiction IS NULL
   OR s.statusKind IS NULL
   OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
                           'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
RETURN 'V-333' AS check, s.uid AS statusUid, s.statusKind AS statusKind, subjects;

// V-333r (proposed revision): exactly one distinct subject over all STATUS_OF episodes; at most one current episode.
MATCH (s:RegulatoryStatus)
OPTIONAL MATCH (s)-[e:STATUS_OF]->(x)
WITH s, count(DISTINCT x) AS subjects, count(CASE WHEN e.recordedTo IS NULL THEN 1 END) AS currentEpisodes
WHERE subjects <> 1 OR currentEpisodes > 1
   OR s.jurisdiction IS NULL OR s.statusKind IS NULL
   OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
                           'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
RETURN 'V-333r' AS check, s.uid AS statusUid, s.statusKind AS statusKind, subjects, currentEpisodes;

// V-334 (catalog, verbatim): a status cannot outlive the legal basis it depends on.
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE pw.effectiveTo IS NOT NULL
  AND (s.effectiveTo IS NULL OR s.effectiveTo > pw.effectiveTo)
RETURN 'V-334' AS check, s.uid AS statusUid, pw.uid AS pathwayUid, pw.effectiveTo AS basisEnded;

// V-334r (proposed revision): the current STATUS_OF episode of a status under a legal-basis version neither starts before
// nor ends after the current HAS_PATHWAY_VERSION episode of that version (null validTo on the status = may outlive).
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)<-[pv:HAS_PATHWAY_VERSION]-(:RegulatoryPathway)
WHERE pv.recordedTo IS NULL
MATCH (s)-[e:STATUS_OF]->()
WHERE e.recordedTo IS NULL
WITH s, v, pv, e
WHERE (pv.validTo IS NOT NULL AND (e.validTo IS NULL OR e.validTo > pv.validTo))
   OR (pv.validFrom IS NOT NULL AND e.validFrom IS NOT NULL AND e.validFrom < pv.validFrom)
RETURN 'V-334r' AS check, s.uid AS statusUid, v.uid AS versionUid, e.validFrom AS statusFrom, e.validTo AS statusTo,
       pv.validFrom AS basisFrom, pv.validTo AS basisTo;

// V-335 (catalog, verbatim): an accepted company characterization of an agency action requires a BellLabs adjudication.
MATCH (a:Assertion)
WHERE a.predicate IN ['CHARACTERIZES_REGULATORY_RESPONSE', 'CHARACTERIZES_REGULATORY_STATUS']
  AND a.status = 'ACCEPTED'
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a) }
RETURN 'V-335' AS check, a.uid AS unadjudicatedCharacterization;

// V-336 (catalog, verbatim; INV-304): an APPROVAL status results from an approving agency response.
MATCH (s:RegulatoryStatus {statusKind: 'APPROVAL'})
WHERE NOT EXISTS {
  MATCH (s)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)
  WHERE resp.responseKind IN ['APPROVED', 'PMA_APPROVED']
}
RETURN 'V-336' AS check, s.uid AS approvalStatusWithoutApprovingResponse;

// V-331 (catalog, verbatim; informational): NDI and GRAS responses keep the agency's conditions of use.
MATCH (sub:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
WHERE sub.submissionKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE']
  AND r.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'GRAS_NO_QUESTIONS']
  AND r.conditionsOfUseText IS NULL
RETURN 'V-331' AS check, sub.uid AS submissionUid, r.uid AS responseUid;

// V-W13-01: STATUS_OF / SUBMISSION_ABOUT targets are RegulatorySubjectTarget members; ESTABLISHMENT_REGISTRATION <-> Facility
// in both directions; OrphanDesignation / DrugApproval subjects are material, mixture, intervention or product.
MATCH (s)-[e:STATUS_OF|SUBMISSION_ABOUT]->(x)
WITH s, e, x,
     any(l IN labels(x) WHERE l IN ['Product', 'ProductVariant', 'IngredientMaterial', 'AlgorithmVersion', 'AssayVersion',
                                    'Facility', 'MaterialMixture', 'StudyIntervention']) AS inUnion
WHERE NOT inUnion
   OR (type(e) = 'STATUS_OF' AND x:Facility AND s.statusKind <> 'ESTABLISHMENT_REGISTRATION')
   OR (type(e) = 'STATUS_OF' AND (s:OrphanDesignation OR s:DrugApproval)
       AND NOT any(l IN labels(x) WHERE l IN ['IngredientMaterial', 'MaterialMixture', 'StudyIntervention', 'Product']))
   OR (type(e) = 'STATUS_OF' AND x:StudyIntervention AND NOT (s:OrphanDesignation OR s:DrugApproval))
RETURN 'V-W13-01' AS check, s.uid AS fromUid, type(e) AS edge, labels(x) AS target, x.uid AS targetUid;

// V-W13-02: closed enum values (service-enforced in GraphQL; this detects Cypher writes).
MATCH (n)
WHERE (n:RegulatoryStatus AND NOT n.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION',
        'ESTABLISHMENT_REGISTRATION', 'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED'])
   OR (n:RegulatoryResponse AND NOT n.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'NDI_INCOMPLETE', 'NDI_OBJECTION',
        'NDI_OTHER_REGULATORY_ISSUE', 'GRAS_NO_QUESTIONS', 'GRAS_NO_BASIS', 'GRAS_CEASED_AT_NOTIFIER_REQUEST',
        'SUBSTANTIALLY_EQUIVALENT', 'NOT_SUBSTANTIALLY_EQUIVALENT', 'DE_NOVO_GRANTED', 'DE_NOVO_DECLINED', 'PMA_APPROVED',
        'PMA_DENIED', 'PMA_APPROVABLE', 'PMA_NOT_APPROVABLE', 'APPROVED', 'COMPLETE_RESPONSE', 'ORPHAN_DESIGNATION_GRANTED',
        'ORPHAN_DESIGNATION_DENIED', 'ORPHAN_DESIGNATION_REVOKED', 'REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED'])
   OR ((n:RegulatoryPathway AND NOT n.pathwayKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE', 'PREMARKET_NOTIFICATION_510K', 'DE_NOVO',
        'PMA', 'NDA', 'BLA', 'ORPHAN_DESIGNATION', 'FOOD_FACILITY_REGISTRATION', 'DEVICE_ESTABLISHMENT_REGISTRATION',
        'COMPOUNDING_503B_BULKS_POLICY', 'LDT_POLICY'])
       OR (n:RegulatorySubmission AND NOT n.submissionKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE', 'PREMARKET_NOTIFICATION_510K',
        'DE_NOVO', 'PMA', 'NDA', 'BLA', 'ORPHAN_DESIGNATION', 'FOOD_FACILITY_REGISTRATION', 'DEVICE_ESTABLISHMENT_REGISTRATION',
        'COMPOUNDING_503B_BULKS_POLICY', 'LDT_POLICY']))
RETURN 'V-W13-02' AS check, n.uid AS nodeUid, [l IN labels(n) WHERE l STARTS WITH 'Regulatory'][0] AS label,
       coalesce(n.statusKind, n.responseKind, n.pathwayKind, n.submissionKind) AS value;

// V-W13-03: the response kind belongs to the closed list of its submission's pathway kind.
MATCH (sub:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
WITH sub, r, {
  NDI_NOTIFICATION: ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'NDI_INCOMPLETE', 'NDI_OBJECTION', 'NDI_OTHER_REGULATORY_ISSUE'],
  GRAS_NOTICE: ['GRAS_NO_QUESTIONS', 'GRAS_NO_BASIS', 'GRAS_CEASED_AT_NOTIFIER_REQUEST'],
  PREMARKET_NOTIFICATION_510K: ['SUBSTANTIALLY_EQUIVALENT', 'NOT_SUBSTANTIALLY_EQUIVALENT'],
  DE_NOVO: ['DE_NOVO_GRANTED', 'DE_NOVO_DECLINED'],
  PMA: ['PMA_APPROVED', 'PMA_DENIED', 'PMA_APPROVABLE', 'PMA_NOT_APPROVABLE'],
  NDA: ['APPROVED', 'COMPLETE_RESPONSE'], BLA: ['APPROVED', 'COMPLETE_RESPONSE'],
  ORPHAN_DESIGNATION: ['ORPHAN_DESIGNATION_GRANTED', 'ORPHAN_DESIGNATION_DENIED', 'ORPHAN_DESIGNATION_REVOKED'],
  FOOD_FACILITY_REGISTRATION: ['REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED'],
  DEVICE_ESTABLISHMENT_REGISTRATION: ['REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED']
} AS allowed
WHERE NOT r.responseKind IN coalesce(allowed[sub.submissionKind], [])
RETURN 'V-W13-03' AS check, sub.uid AS submissionUid, sub.submissionKind AS kind, r.uid AS responseUid, r.responseKind AS responseKind;

// V-W13-04: exactly one UNDER_PATHWAY per submission, and submissionKind equals that pathway's pathwayKind; jurisdictions agree.
MATCH (sub:RegulatorySubmission)
OPTIONAL MATCH (sub)-[:UNDER_PATHWAY]->(pw:RegulatoryPathway)
WITH sub, collect(pw) AS pws
WHERE size(pws) <> 1 OR pws[0].pathwayKind <> sub.submissionKind OR pws[0].jurisdiction <> sub.jurisdiction
RETURN 'V-W13-04' AS check, sub.uid AS submissionUid, sub.submissionKind AS kind, [p IN pws | p.pathwayKind] AS pathwayKinds;

// V-W13-05: a legal-basis version used by a status or submission belongs to that record's pathway.
MATCH (x)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)
OPTIONAL MATCH (x)-[:UNDER_LEGAL_BASIS|UNDER_PATHWAY]->(pw:RegulatoryPathway)
WITH x, v, collect(pw) AS pws
WHERE NOT any(pw IN pws WHERE EXISTS { (pw)-[:HAS_PATHWAY_VERSION]->(v) })
RETURN 'V-W13-05' AS check, x.uid AS recordUid, v.uid AS versionUid, [p IN pws | p.uid] AS pathways;

// V-W13-06: HAS_PATHWAY_VERSION is EXCLUSIVE per pathway: no two current episodes to different versions overlap in valid
// time, and one version has at most one current episode (null bounds are unknown and treated as possibly overlapping).
MATCH (pw:RegulatoryPathway)-[a:HAS_PATHWAY_VERSION]->(v1:RegulatoryPathwayVersion),
      (pw)-[b:HAS_PATHWAY_VERSION]->(v2:RegulatoryPathwayVersion)
WHERE a.recordedTo IS NULL AND b.recordedTo IS NULL AND elementId(a) < elementId(b)
  AND (v1 = v2
       OR NOT ((a.validTo IS NOT NULL AND b.validFrom IS NOT NULL AND a.validTo <= b.validFrom)
               OR (b.validTo IS NOT NULL AND a.validFrom IS NOT NULL AND b.validTo <= a.validFrom)))
RETURN 'V-W13-06' AS check, pw.uid AS pathwayUid, v1.uid AS version1, v2.uid AS version2;

// V-W13-07: asserted regulatory edges carry the asserted_edge profile and cite an assertion with the same predicate, subject and object.
MATCH (x)-[e:STATUS_OF|SUBMITTED_BY|SUBMISSION_ABOUT|SUPERSEDES_SUBMISSION|INSPECTED_FACILITY]->(y)
OPTIONAL MATCH (a:Assertion {uid: e.assertionUid})
WITH x, e, y, a
WHERE e.assertionUid IS NULL OR e.relationshipUid IS NULL OR e.recordedFrom IS NULL
   OR e.validFromBasis IS NULL OR e.validToBasis IS NULL
   OR a IS NULL OR a.predicate <> type(e)
   OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(y) }
   OR coalesce(a.validFrom, datetime('0001-01-01T00:00:00Z')) <> coalesce(e.validFrom, datetime('0001-01-01T00:00:00Z'))
   OR coalesce(a.validTo, datetime('0001-01-01T00:00:00Z')) <> coalesce(e.validTo, datetime('0001-01-01T00:00:00Z'))
RETURN 'V-W13-07' AS check, type(e) AS edge, x.uid AS fromUid, y.uid AS toUid, e.assertionUid AS cited;

// V-W13-08: legacy derived HAS_REGULATORY_STATUS / FOLLOWS_PATHWAY carry a rule and only matching input assertions.
MATCH (p:Product)-[d:HAS_REGULATORY_STATUS|FOLLOWS_PATHWAY]->(t)
WITH p, d, t, coalesce(d.derivedFromAssertionUids, []) AS inputs
WHERE d.derivationRule IS NULL OR size(inputs) = 0 OR d.projectionOfAssertionUid IS NOT NULL
   OR (type(d) = 'HAS_REGULATORY_STATUS' AND (
         t.statusKind = 'ESTABLISHMENT_REGISTRATION'
         OR NOT all(u IN inputs WHERE EXISTS {
              MATCH (a:Assertion {uid: u, predicate: 'STATUS_OF'})-[:HAS_SUBJECT]->(t) WHERE EXISTS { (a)-[:HAS_OBJECT]->(p) } })))
   OR (type(d) = 'FOLLOWS_PATHWAY' AND NOT all(u IN inputs WHERE EXISTS {
              MATCH (a:Assertion {uid: u, predicate: 'SUBMISSION_ABOUT'})-[:HAS_SUBJECT]->(:RegulatorySubmission)-[:UNDER_PATHWAY]->(t)
              WHERE EXISTS { (a)-[:HAS_OBJECT]->(p) } }))
RETURN 'V-W13-08' AS check, type(d) AS edge, p.uid AS productUid, t.uid AS targetUid, inputs;

// V-W13-09: every response has exactly one submission and one issuer; every status has exactly one issuer and one legal basis.
MATCH (n)
WHERE n:RegulatoryResponse OR n:RegulatoryStatus
WITH n,
     COUNT { (n)-[:ISSUED_BY]->(:RegulatoryAgency) } AS issuers,
     COUNT { (:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(n) } AS submissions,
     COUNT { (n)-[:UNDER_LEGAL_BASIS]->(:RegulatoryPathway) } AS bases
WHERE issuers <> 1
   OR (n:RegulatoryResponse AND submissions <> 1)
   OR (n:RegulatoryStatus AND bases <> 1)
RETURN 'V-W13-09' AS check, n.uid AS nodeUid, [l IN labels(n) WHERE l STARTS WITH 'Regulatory'][0] AS label, issuers, submissions, bases;

// V-W13-10: jurisdiction partition: a status's jurisdiction equals its legal-basis pathway's; a response's equals its submission's.
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE s.jurisdiction <> pw.jurisdiction
RETURN 'V-W13-10' AS check, s.uid AS recordUid, s.jurisdiction AS recordJurisdiction, pw.jurisdiction AS expected
UNION ALL
MATCH (sub:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
WHERE r.jurisdiction <> sub.jurisdiction
RETURN 'V-W13-10' AS check, r.uid AS recordUid, r.jurisdiction AS recordJurisdiction, sub.jurisdiction AS expected;

// V-W13-11 (candidate): an inspection has exactly one inspected Facility and one conducting agency; it never yields a status.
MATCH (i:RegulatoryInspection)
WITH i,
     COUNT { (i)-[:INSPECTED_FACILITY]->(:Facility) } AS facilities,
     COUNT { (i)-[:INSPECTED_FACILITY]->() } AS targets,
     COUNT { (i)-[:CONDUCTED_BY]->(:RegulatoryAgency) } AS agencies,
     COUNT { (:RegulatoryStatus)-[:RESULTS_FROM_RESPONSE]->(i) } AS statuses
WHERE facilities <> 1 OR targets <> 1 OR agencies <> 1 OR statuses > 0
   OR (i.startedAt IS NOT NULL AND i.endedAt IS NOT NULL AND i.endedAt < i.startedAt)
RETURN 'V-W13-11' AS check, i.uid AS inspectionUid, facilities, agencies;

// V-W13-12: forbidden regulatory implications used as derivation premises (12 catalog pairs, premise read from the input
// assertion's predicate, or the statusKind / responseKind of its subject).
MATCH (c:Assertion)-[:DERIVED_FROM_ASSERTION]->(i:Assertion)
OPTIONAL MATCH (i)-[:HAS_SUBJECT]->(subj)
WITH c, i, [i.predicate, subj.statusKind, subj.responseKind] AS premises
WITH c, i, premises, [
  ['DESIGNATION', 'IS_APPROVED'], ['DESIGNATION', 'FDA_APPROVED'], ['ORPHAN_DESIGNATION_GRANTED', 'IS_APPROVED'],
  ['NOTIFICATION_ON_FILE', 'FDA_APPROVED'], ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'FDA_APPROVED'],
  ['ESTABLISHMENT_REGISTRATION', 'FDA_APPROVED'], ['ESTABLISHMENT_REGISTRATION', 'CGMP_COMPLIANT'],
  ['DEVICE_LISTED', 'FDA_CLEARED'], ['CLEARANCE', 'FDA_APPROVED'], ['SUBSTANTIALLY_EQUIVALENT', 'FDA_APPROVED'],
  ['DE_NOVO_AUTHORIZATION', 'PMA_APPROVAL'], ['DE_NOVO_GRANTED', 'PMA_APPROVAL'],
  ['GRAS_NO_QUESTIONS', 'FDA_APPROVED'], ['GRAS_NO_QUESTIONS', 'FDA_GRAS_DETERMINATION'], ['NOTIFICATION_ON_FILE', 'FDA_GRAS_DETERMINATION'],
  ['ENFORCEMENT_DISCRETION', 'AUTHORIZATION'], ['CLAIMS_CGMP_COMPLIANCE', 'CGMP_COMPLIANT']] AS pairs
WHERE any(p IN pairs WHERE p[1] = c.predicate AND p[0] IN premises)
RETURN 'V-W13-12' AS check, c.uid AS conclusionUid, c.predicate AS conclusion, i.uid AS premiseUid, premises;
