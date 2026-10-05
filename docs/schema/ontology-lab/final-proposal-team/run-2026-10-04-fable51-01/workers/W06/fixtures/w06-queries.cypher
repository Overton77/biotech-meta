// =====================================================================================================================
// W06 competency-question queries (one per covered Essential CQ and per candidate CQ). Read-only. Expected rows are in
// 06-fixtures-and-queries.md. Each statement is independent.
// =====================================================================================================================

// Q-01 (three identities, no collapse): one drug name, three distinct uids and labels.
MATCH (n)
WHERE (n:Treatment OR n:StudyIntervention OR n:Product)
  AND any(s IN ['exa-cel', 'exagamglogene', 'casgevy'] WHERE toLower(coalesce(n.name, '')) CONTAINS s)
RETURN [l IN labels(n) WHERE l IN ['Treatment', 'StudyIntervention', 'Product']][0] AS identityKind, n.uid AS uid, n.name AS name
ORDER BY identityKind;

// Q-02 (CQ-ST-01 via CQ-IV-C01): which study interventions instantiate treatment T, and what exactly was administered.
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'})<-[:FOLLOWS_INTERVENTION_DEFINITION]-(si:StudyIntervention)<-[:ASSIGNS_INTERVENTION]-(arm:StudyArm)<-[:HAS_ARM]-(s:Study)
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
RETURN s.uid AS study, arm.name AS arm, si.name AS administered, si.registryInterventionType AS registryType, si.schedule AS schedule,
       CASE WHEN ic IS NULL THEN 'NO_COMPONENT_RECORDED'
            WHEN ic.quantity IS NULL THEN coalesce(ic.doseReportedStatus, 'UNKNOWN')
            ELSE toString(ic.quantity) + ' ' + ic.unitCode END AS dose;

// Q-03 (CQ-MF-02 / CQ-AX-23): is the treatment approved, as of valid time V, for which product and indication? Designations
// are listed separately and never counted as approval. Only ACCEPTED status assertions answer.
UNWIND [datetime('2025-06-01T00:00:00Z'), datetime('2026-08-01T00:00:00Z')] AS validAt
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'})-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(p:Product)
OPTIONAL MATCH (p)<-[r:STATUS_OF|APPROVAL_FOR|DESIGNATION_FOR]-(s:RegulatoryStatus)
WHERE (r.validFrom IS NULL OR r.validFrom <= validAt) AND (r.validTo IS NULL OR validAt < r.validTo)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH validAt, p, s, a
WHERE s IS NULL OR a.status = 'ACCEPTED'
RETURN validAt, p.name AS product,
       [x IN collect(CASE WHEN s.statusKind = 'APPROVAL' THEN s.jurisdiction + ': ' + s.indication END) WHERE x IS NOT NULL] AS approvalsInForce,
       [x IN collect(CASE WHEN s.statusKind = 'DESIGNATION' THEN s.jurisdiction + ' designation: ' + s.indication END) WHERE x IS NOT NULL] AS designationsNotApproval
ORDER BY validAt;

// Q-04 (CQ-IV-C02): procedure definition versus who offers it, where it is listed and priced, which protocol steps employ
// it, which study interventions instantiate it, which treatment concepts use it -- each kept in its own column.
MATCH (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'})
RETURN p.name AS procedureDefinition,
       [(o:Organization)-[r:OFFERS_PROCEDURE]->(p) WHERE EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) WHERE a.status = 'ACCEPTED' AND a.predicate = 'OFFERS_PROCEDURE' } | o.name] AS offeredBy,
       [(a:Assertion {predicate: 'OFFERS_PROCEDURE', status: 'EXTRACTED'})-[:HAS_OBJECT]->(p) | [(a)-[:HAS_SUBJECT]->(o) | o.name][0] + ' (unverified capture)'] AS candidateOfferers,
       [(ml:MerchantListing)-[:LISTS_PROCEDURE]->(p) | ml.canonicalUrl] AS listings,
       [(ml:MerchantListing)-[:LISTS_PROCEDURE]->(p) | [(ml)-[:HAS_OFFER]->(of)-[:HAS_PRICE_OBSERVATION]->(po) | po.amount + ' ' + po.currency + ' @ ' + toString(po.observedAt)]] AS priceObservations,
       [(st:ProtocolStep)-[:EMPLOYS]->(p) | st.uid] AS employedByProtocolSteps,
       [(si:StudyIntervention)-[:FOLLOWS_INTERVENTION_DEFINITION]->(p) | si.uid + ' [' + si.registryInterventionType + ']'] AS instantiatedByStudyInterventions,
       [(t:Treatment)-[u:USES_COMPONENT]->(p) | t.uid + ' as ' + u.componentRole] AS componentOfTreatments;

// Q-05 (CQ-IV-C04, QS-7 shape): who develops treatment T? Unknown stays unknown; other roles are reported as other roles.
MATCH (t:Treatment {uid: 'hu:treatment:exagamglogene-autotemcel'})
OPTIONAL MATCH (a:Assertion {predicate: 'DEVELOPS_TREATMENT'})-[:HAS_OBJECT]->(t)
WITH t, collect(a) AS dev
OPTIONAL MATCH (t)-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(p:Product)<-[:HAS_OBJECT]-(m:Assertion {predicate: 'MANUFACTURES_PRODUCT'})-[:HAS_SUBJECT]->(mo:Organization)
OPTIONAL MATCH (t)<-[:FOLLOWS_INTERVENTION_DEFINITION]-(:StudyIntervention)<-[:ASSIGNS_INTERVENTION]-(:StudyArm)<-[:HAS_ARM]-(s:Study)<-[:HAS_OBJECT]-(sp:Assertion {predicate: 'SPONSORS_STUDY'})-[:HAS_SUBJECT]->(so:Organization)
RETURN CASE WHEN size(dev) = 0 THEN 'NOT_RECORDED' ELSE 'ASSERTED_PRESENT' END AS developerState,
       collect(DISTINCT mo.name + ' manufactures ' + p.name) AS otherRolesManufacturer,
       collect(DISTINCT so.name + ' sponsors ' + s.uid) AS otherRolesSponsor;

// Q-06 (CQ-IV-C03): which treatment concepts are gene therapies, and how did registries type their administered
// interventions? (Registry type is reported, never mapped onto modality.)
MATCH (t:Treatment)
WHERE 'GENE_THERAPY' IN coalesce(t.modalities, [])
OPTIONAL MATCH (t)<-[:FOLLOWS_INTERVENTION_DEFINITION]-(si:StudyIntervention)
RETURN t.uid AS treatmentUid, t.modalities AS modalities, t.modality AS legacyModality, collect(si.registryInterventionType) AS registryInterventionTypes
ORDER BY treatmentUid;

// Q-07 (CQ-IV-C05): which procedure definitions share a classification code, and what distinguishes them?
MATCH (i:Identifier {scheme: 'ICD-10-PCS'})<-[:HAS_IDENTIFIER]-(p:Procedure)
WITH i, collect(p.name) AS definitions
WHERE size(definitions) > 1
RETURN i.value AS code, definitions, 'shared code is a performance classification, not identity' AS note
ORDER BY code;

// Q-08 (CQ-EV-04 guard): from an administered intervention, the concept leads to a product for navigation only; evidence
// applicability to that product is read solely from EvidenceApplicability (none exists here -> NOT_ASSESSED).
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct03745287-exa-cel'})-[:FOLLOWS_INTERVENTION_DEFINITION]->(t:Treatment)-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(p:Product)
OPTIONAL MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(si)
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(p)
RETURN si.uid AS evidenceTarget, t.uid AS viaConcept, p.name AS navigatedProduct,
       CASE WHEN ea IS NULL THEN 'NOT_ASSESSED' ELSE 'SEE_ASSESSMENT ' + ea.uid END AS applicability;

// Q-09 (CQ-AX-23 negative, designation text): is "edaravone for ALS" approved? Answer per product with capture status.
MATCH (t:Treatment {uid: 'hu:treatment:edaravone-als'})-[:USES_COMPONENT {componentRole: 'ADMINISTERED_PRODUCT'}]->(p:Product)
OPTIONAL MATCH (p)<-[r:STATUS_OF|DESIGNATION_FOR|APPROVAL_FOR]-(s:RegulatoryStatus)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
RETURN t.orphanDrugDesignation AS legacyDesignationText, t.developmentStage AS legacyStageText, p.name AS product,
       collect(coalesce(s.statusKind, 'UNSPECIFIED_END(' + coalesce(s.scopeText, '') + ')') + ' [' + coalesce(a.status, 'NO_ASSERTION') + ']') AS states
ORDER BY product;
