// Queries over fixture 09. Expected: 06-fixtures-and-queries.md §3.9.

// Q09-a CQ-PV-01: the five provenance states of one assertion, each from its own record.
MATCH (a:Assertion {uid: 'hu:assertion:w00-9500320-reports-parental-association'})
CALL { WITH a OPTIONAL MATCH (a)-[:ASSERTED_BY]->(by) RETURN collect(by.uid) AS asserters }
CALL { WITH a OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
       RETURN collect({locator: l.uid, quoteHash: l.quoteHash, snapshot: s.uid, retrievedAt: toString(s.retrievedAt), source: src.canonicalUri}) AS supports }
CALL { WITH a OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a) WHERE NOT ()-[:SUPERSEDES]->(j)
       RETURN collect({adjudication: j.uid, verdict: j.verdict}) AS currentSupportAssessments }
CALL { WITH a OPTIONAL MATCH (act:Activity)-[:USED]->(a) OPTIONAL MATCH (act)-[:WAS_ASSOCIATED_WITH]->(g:Agent)
       RETURN collect({activity: act.uid, kind: act.activityKind, agent: g.uid}) AS usedBy }
CALL { WITH a OPTIONAL MATCH (act:Activity)-[:USED]->(a) OPTIONAL MATCH (act)-[u:AUTHORIZED_BY]->(pv:PolicyVersion)
       RETURN collect({policy: pv.uid, useKind: u.useKind}) AS allowedBy }
RETURN 'Q09-a' AS q, a.status AS state1_captureStatus, asserters AS state1_asserters, supports AS state2_supports,
       currentSupportAssessments AS state3_broaderConclusion, usedBy AS state4_agentUsed, allowedBy AS state5_policyAllows;

// Q09-b CQ-TM-06 (Q-505): impact of the retraction: assertions resting on the prior snapshot and their adjudication history.
MATCH (ev:SourceRevisionEvent {uid: 'hu:source-revision:w00-pmid-9500320-retraction'})-[:PRIOR_SNAPSHOT]->(sn:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
OPTIONAL MATCH (adj:Adjudication)-[:EVALUATES]->(a)
WITH ev, a, adj ORDER BY adj.recordedAt
RETURN 'Q09-b' AS q, ev.revisionKind AS revisionKind, toString(ev.occurredAt) AS issuedAt, toString(ev.recordedAt) AS learnedAt,
       a.uid AS affectedAssertion, a.status AS captureStatusUnchanged,
       collect({adj: adj.id, kind: adj.adjudicationKind, verdict: adj.verdict, recordedAt: toString(adj.recordedAt),
                supersededBy: [(n:Adjudication)-[:SUPERSEDES]->(adj) | n.id]}) AS adjudications;

// Q09-c CQ-EV-02 / CQ-TM-01: latest SUPPORT verdict as of two recorded dates; status is NOT the verdict.
UNWIND [datetime('2026-01-01T00:00:00Z'), datetime('2026-10-05T00:00:00Z')] AS R
MATCH (a:Assertion {uid: 'hu:assertion:w00-9500320-reports-parental-association'})
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
WHERE j.recordedAt <= R
WITH R, a, j ORDER BY j.recordedAt DESC
WITH R, a, collect(j)[0] AS latest
RETURN 'Q09-c' AS q, toString(R) AS recordedAsOf, a.status AS captureStatus, latest.verdict AS supportVerdictAsOfR, 'Adjudication' AS verdictRecordKind;

// Q09-d CL-003: works and renditions — the article and the notice are distinct works, each with its own PubMed-record Source.
MATCH (src:Source)-[:RENDITION_OF]->(p:Publication)
RETURN 'Q09-d' AS q, p.uid AS work, src.canonicalUri AS renditionEndpoint, src.sourceKind AS sourceKind ORDER BY work;
