// W13 competency-question queries (read-only). Parameters are inlined as literals so the file runs without a params
// file; production versions take the commented $parameters. Expected rows are documented in 06-fixtures-and-queries.md.

// Q-MF-02a (CQ-MF-02, CQ-AX-23): what regulatory standing does subject X have, by jurisdiction, as known at recorded time R
// and valid at time V; which submission and response produced it; is it approval. Run for each subject of fixture 1.
// params: $subjectUid, $recordedAsOf, $validAt
UNWIND ['hu:product:rezdiffra', 'hu:product:dexcom-stelo', 'hu:product:paige-prostate', 'hu:mixture:nr-and-pterostilbene-oopd-628218',
        'hu:material:niagen-nrc', 'hu:assay-version:synthetic-ldt-nad-panel-v1', 'hu:facility:synthetic-supplement-plant',
        'hu:product:tru-niagen-300-capsules'] AS subjectUid
MATCH (x {uid: subjectUid})
OPTIONAL MATCH (s:RegulatoryStatus)-[e:STATUS_OF]->(x)
WHERE e.recordedFrom <= datetime('2026-10-04T03:00:00Z') AND (e.recordedTo IS NULL OR e.recordedTo > datetime('2026-10-04T03:00:00Z'))
  AND (e.validFrom IS NULL OR e.validFrom <= datetime('2026-10-04T00:00:00Z'))
  AND (e.validTo IS NULL OR datetime('2026-10-04T00:00:00Z') < e.validTo)
OPTIONAL MATCH (s)-[:RESULTS_FROM_RESPONSE]->(r:RegulatoryResponse)<-[:SUBMISSION_HAS_RESPONSE]-(sub:RegulatorySubmission)
WITH subjectUid, collect(CASE WHEN s IS NULL THEN null ELSE {
       jurisdiction: s.jurisdiction, statusKind: s.statusKind, isApproval: s.statusKind = 'APPROVAL',
       submission: sub.identifier, response: r.responseKind, issuedAt: toString(date(r.issuedAt)), scope: s.scopeText} END) AS standings
RETURN subjectUid,
       CASE WHEN size(standings) = 0 THEN 'NOT_RECORDED' ELSE 'RECORDED' END AS state,
       standings
ORDER BY subjectUid;

// Q-MF-03 (CQ-MF-03): company characterization versus the agency record, with the current SUPPORT adjudication.
MATCH (a:Assertion)-[:HAS_SUBJECT]->(r:RegulatoryResponse)
WHERE a.predicate = 'CHARACTERIZES_REGULATORY_RESPONSE'
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
WHERE NOT EXISTS { (:Adjudication)-[:SUPERSEDES]->(j) }
RETURN a.uid AS characterization, who.name AS asserter, a.valueString AS companyWording,
       r.responseKind AS agencyResponseKind, toString(date(r.issuedAt)) AS agencyDate, r.conditionsOfUseText AS agencyConditions,
       r.agencyDisclaimerText AS agencyDisclaimer, j.verdict AS verdict, j.uid AS adjudicationUid
ORDER BY characterization;

// Q-PF-04 (CQ-PF-04): what conditions of use does the agency response state (verbatim), versus the submitter's proposal.
MATCH (sub:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
WHERE r.conditionsOfUseText IS NOT NULL
RETURN sub.identifier AS submission, r.responseKind AS responseKind, r.jurisdiction AS jurisdiction,
       r.conditionsOfUseText AS agencyConditions, sub.conditionsOfUseText AS submittedConditions
ORDER BY submission;

// Q-TM-03 (CQ-TM-03): the clocks of one regulatory record kept apart (GRN 000635).
MATCH (sub:RegulatorySubmission {uid: 'hu:reg-submission:us-fda-grn-000635'})-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
MATCH (s:RegulatoryStatus)-[:RESULTS_FROM_RESPONSE]->(r)
MATCH (s)-[e:STATUS_OF]->()
OPTIONAL MATCH (sub)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)
RETURN toString(date(sub.submittedAt)) AS noticeDated, toString(date(sub.receivedAt)) AS received,
       toString(date(sub.filingDate)) AS filed, toString(date(r.issuedAt)) AS responseIssued,
       toString(date(e.validFrom)) AS statusValidFrom, toString(e.recordedFrom) AS recorded, v.legalBasisCitation AS legalBasisAtFiling;

// Q-MF-C02 (CQ-MF-C02 candidate): which legal basis governed pathway P at valid time V, as known at recorded time R.
// Two runs: R = 2025-02-01 (before the vacatur was ingested) and R = 2026-10-04, both for V = 2025-06-01.
UNWIND [datetime('2025-02-01T00:00:00Z'), datetime('2026-10-04T03:00:00Z')] AS asOf
MATCH (pw:RegulatoryPathway {uid: 'hu:reg-pathway:us-fda-ldt-oversight'})-[e:HAS_PATHWAY_VERSION]->(v:RegulatoryPathwayVersion)
WHERE e.recordedFrom <= asOf AND (e.recordedTo IS NULL OR e.recordedTo > asOf)
  AND (e.validFrom IS NULL OR e.validFrom <= datetime('2025-06-01T00:00:00Z'))
  AND (e.validTo IS NULL OR datetime('2025-06-01T00:00:00Z') < e.validTo)
RETURN toString(asOf) AS knownAsOf, v.versionLabel AS regime, v.legalBasisCitation AS basis,
       toString(e.validFrom) AS from, toString(e.validTo) AS to, toString(v.codifiedTextTo) AS codifiedTextTo
ORDER BY knownAsOf;

// Q-MF-C02b: statuses whose legal basis was later bounded (vacatur), with their bounded episodes.
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)<-[pv:HAS_PATHWAY_VERSION]-()
WHERE pv.recordedTo IS NULL AND pv.validTo IS NOT NULL
MATCH (s)-[e:STATUS_OF]->(x)
RETURN s.uid AS statusUid, s.statusKind AS kind, v.versionLabel AS regime, toString(pv.validTo) AS basisEnded,
       toString(e.validTo) AS statusEpisodeEnds, toString(e.recordedFrom) AS episodeRecorded, toString(e.recordedTo) AS episodeClosed
ORDER BY statusUid, episodeRecorded;

// Q-MF-C03 (CQ-MF-C03 candidate): jurisdiction-partitioned standings of one material; a missing jurisdiction is unknown.
UNWIND ['US', 'EU', 'GB-GBN', 'GB-NIR'] AS j
OPTIONAL MATCH (s:RegulatoryStatus {jurisdiction: j})-[e:STATUS_OF]->(:IngredientMaterial {uid: 'hu:material:niagen-nrc'})
WHERE e.recordedTo IS NULL
RETURN j AS jurisdiction, collect(s.statusKind) AS statusKinds, collect(s.scopeText) AS scopes,
       CASE WHEN count(s) = 0 THEN 'NOT_RECORDED' ELSE 'RECORDED' END AS state
ORDER BY jurisdiction;

// Q-MF-06 / Q-MF-C01 (CQ-MF-06, CQ-MF-C01 candidate): what quality-relevant regulatory signals exist for a facility,
// kept separate: registration status, company cGMP claim, inspection (period, 483, findings, classification).
UNWIND ['hu:facility:synthetic-supplement-plant', 'hu:facility:nutratech-phoenix-ny', 'hu:facility:anti-lage-riverside-ca'] AS fu
MATCH (f:Facility {uid: fu})
OPTIONAL MATCH (reg:RegulatoryStatus {statusKind: 'ESTABLISHMENT_REGISTRATION'})-[re:STATUS_OF]->(f) WHERE re.recordedTo IS NULL
OPTIONAL MATCH (claim:Assertion {predicate: 'CLAIMS_CGMP_COMPLIANCE'})-[:HAS_SUBJECT]->(f)
OPTIONAL MATCH (i:RegulatoryInspection)-[:INSPECTED_FACILITY]->(f)
OPTIONAL MATCH (p:Assertion {predicate: 'INSPECTION_PERIOD'})-[:HAS_SUBJECT]->(i)
OPTIONAL MATCH (v:Assertion {predicate: 'INSPECTION_FOUND_VIOLATION'})-[:HAS_SUBJECT]->(i)
OPTIONAL MATCH (c:Assertion {predicate: 'INSPECTION_CLASSIFIED_AS'})-[:HAS_SUBJECT]->(i)
WITH f, reg, claim, i, collect(DISTINCT p.valueString) AS periods, collect(DISTINCT v.valueString) AS findings, collect(DISTINCT c.valueString) AS classes
RETURN f.uid AS facility,
       CASE WHEN reg IS NULL THEN 'NOT_RECORDED' ELSE reg.statusKind END AS registration,
       CASE WHEN claim IS NULL THEN 'none captured' ELSE claim.valueString + ' (company claim, ' + claim.status + ')' END AS cgmpClaim,
       i.uid AS inspection, toString(date(i.startedAt)) AS inspectedFrom,
       CASE WHEN i IS NULL THEN null WHEN size(periods) > 1 THEN 'CONFLICTING: ' + reduce(t = '', x IN periods | t + x + ' | ') ELSE toString(date(i.endedAt)) END AS inspectedTo,
       i.form483Issued AS form483, findings,
       CASE WHEN i IS NULL THEN null WHEN size(classes) = 0 THEN 'NOT_CAPTURED' ELSE reduce(t = '', x IN classes | t + x + ' ') END AS classification,
       'never CGMP_COMPLIANT by projection' AS rule
ORDER BY facility;

// Q-AX-23-guard (CQ-AX-23): "is X FDA approved?" answers yes only from APPROVAL statuses with an approving response.
UNWIND ['hu:product:rezdiffra', 'hu:product:dexcom-stelo', 'hu:product:paige-prostate', 'hu:material:niagen-nrc',
        'hu:product:tru-niagen-300-capsules'] AS subjectUid
MATCH (x {uid: subjectUid})
OPTIONAL MATCH (s:RegulatoryStatus {jurisdiction: 'US', statusKind: 'APPROVAL'})-[e:STATUS_OF]->(x)
WHERE e.recordedTo IS NULL AND EXISTS { (s)-[:RESULTS_FROM_RESPONSE]->(r:RegulatoryResponse) WHERE r.responseKind IN ['APPROVED', 'PMA_APPROVED'] }
OPTIONAL MATCH (o:RegulatoryStatus {jurisdiction: 'US'})-[oe:STATUS_OF]->(x)
WHERE oe.recordedTo IS NULL AND o.statusKind <> 'APPROVAL'
RETURN subjectUid, count(DISTINCT s) > 0 AS fdaApproved, collect(DISTINCT o.statusKind) AS otherStandingsNotApproval
ORDER BY subjectUid;
