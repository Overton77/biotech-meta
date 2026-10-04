// =====================================================================
// W19 queries over fixtures 01-05 (read-only). Expected rows are in ../06-fixtures-and-queries.md.
// Each statement is self-contained (no variable crosses ';').
// =====================================================================

// Q-01 (CL-003, CQ-EV-05): the renditions of a work. Publication PMID 29184669.
MATCH (w:Publication {uid: 'hu:publication:pmid-29184669'})<-[:RENDITION_OF]-(s:Source)
RETURN s.uid AS sourceUid, s.sourceKind AS sourceKind, s.renditionCoverage AS renditionCoverage, s.canonicalUri AS canonicalUri
ORDER BY sourceUid;

// Q-01b (CL-003): the renditions of the Episode, and the talk/deck pair.
MATCH (w:Episode)<-[:RENDITION_OF]-(s:Source)
RETURN w.uid AS workUid, collect(s.sourceKind) AS renditionKinds, count(s) AS renditions
ORDER BY workUid;

// Q-02 (identity rule R2): a Source canonicalUri is a retrieval endpoint, never an identifier resolver.
MATCH (s:Source)
WHERE s.canonicalUri =~ '(?i)https?://(dx\\.)?doi\\.org/.*' OR s.canonicalUri =~ '(?i)https?://identifiers\\.org/.*'
   OR s.canonicalUri =~ '(?i)https?://(www\\.)?ncbi\\.nlm\\.nih\\.gov/pubmed/\\?term=.*'
RETURN s.uid AS sourceWithResolverUri, s.canonicalUri AS canonicalUri;

// Q-03 (identity rule R3): a Source is a rendition of at most one work, and the target is a work, never a Source.
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, collect(w) AS works
WHERE size(works) > 1 OR any(w IN works WHERE w:Source OR NOT (w:Episode OR w:Publication))
RETURN s.uid AS badRendition, [w IN works | labels(w)] AS targetLabels;

// Q-04 (identity rule R4): a slide deck is not a rendition of a talk (presentation documents are their own containers).
MATCH (s:Source {sourceKind: 'PRESENTATION_SLIDES'})-[:RENDITION_OF]->(e:Episode)
RETURN s.uid AS slidesAsRenditionOfTalk, e.uid AS talkUid;

// Q-05 (CQ-PV-05): primary versus retelling, per assertion, from the RETELLS chain (never from a Document flag).
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim)
WHERE c.uid IN ['hu:claim:sinclair-reports-taking-1g-nmn-daily', 'hu:claim:1g-nmn-daily-slows-aging']
OPTIONAL MATCH path = (a)-[:RETELLS*1..10]->(root:Assertion)
WHERE NOT (root)-[:RETELLS]->()
OPTIONAL MATCH (a)-[:OCCURS_IN]->(container)
WITH c, a, container, root, path
RETURN c.uid AS claimUid, a.uid AS assertionUid,
       CASE WHEN root IS NULL THEN 'PRIMARY' ELSE 'RETELLING' END AS role,
       CASE WHEN path IS NULL THEN 0 ELSE length(path) END AS hopsToPrimary,
       coalesce(root.uid, a.uid) AS primaryAssertionUid,
       container.uid AS containerUid, container.isPrimarySource AS ignoredLiveDocumentFlag
ORDER BY claimUid, hopsToPrimary;

// Q-06 (CQ-AX-05): independent lines per claim = distinct primary roots, not assertion count.
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim)
OPTIONAL MATCH (a)-[:RETELLS*1..10]->(root:Assertion)
WHERE NOT (root)-[:RETELLS]->()
WITH c, a, coalesce(root, a) AS primary
RETURN c.uid AS claimUid, count(DISTINCT a) AS assertions, count(DISTINCT primary) AS independentPrimaryLines,
       collect(DISTINCT primary.uid) AS primaryUids
ORDER BY claimUid;

// Q-07 (CQ-PV-04, CQ-PV-02): one occurrence, located on two renditions of its container, with different quote text.
MATCH (a:ClaimOccurrence)-[:OCCURS_IN]->(w)
MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)-[:RENDITION_OF]->(w)
WITH a, collect(DISTINCT src.uid) AS renditionUids, collect(DISTINCT l.quoteHash) AS quoteHashes, collect(DISTINCT l.exact) AS quotes
WHERE size(renditionUids) > 1 AND size(quoteHashes) > 1
RETURN a.uid AS occurrenceWithRenditionTextDisagreement, renditionUids, quotes
ORDER BY occurrenceWithRenditionTextDisagreement;

// Q-08a (not-found reading rule): is a PROVIDES_INVESTIGATIONAL_PRODUCT statement found, searching the PubMed record only?
WITH ['hu:source:pubmed-29184669'] AS scope, 'PROVIDES_INVESTIGATIONAL_PRODUCT' AS pred
MATCH (src:Source) WHERE src.uid IN scope
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
OPTIONAL MATCH (snap)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion {predicate: pred})
WITH src, collect(DISTINCT snap) AS snaps, collect(DISTINCT a) AS hits
WITH collect({src: src, snaps: snaps, hits: hits}) AS rows
RETURN CASE
  WHEN any(r IN rows WHERE size(r.hits) > 0) THEN 'FOUND'
  WHEN all(r IN rows WHERE size(r.snaps) = 0) THEN 'NOT_CAPTURED'
  WHEN all(r IN rows WHERE r.src.renditionCoverage = 'FULL' AND any(s IN r.snaps WHERE s.captureCompleteness = 'COMPLETE'))
       THEN 'NOT_FOUND_IN_COMPLETE_CAPTURE'
  ELSE 'NOT_FOUND_IN_PARTIAL_CAPTURE' END AS finding;

// Q-08b (not-found reading rule): the same question over every rendition of the work.
WITH 'PROVIDES_INVESTIGATIONAL_PRODUCT' AS pred
MATCH (:Publication {uid: 'hu:publication:pmid-29184669'})<-[:RENDITION_OF]-(src:Source)
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
OPTIONAL MATCH (snap)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion {predicate: pred})
WITH src, collect(DISTINCT snap) AS snaps, collect(DISTINCT a) AS hits
WITH collect({src: src, snaps: snaps, hits: hits}) AS rows
RETURN CASE
  WHEN any(r IN rows WHERE size(r.hits) > 0) THEN 'FOUND'
  WHEN all(r IN rows WHERE size(r.snaps) = 0) THEN 'NOT_CAPTURED'
  WHEN all(r IN rows WHERE r.src.renditionCoverage = 'FULL' AND any(s IN r.snaps WHERE s.captureCompleteness = 'COMPLETE'))
       THEN 'NOT_FOUND_IN_COMPLETE_CAPTURE'
  ELSE 'NOT_FOUND_IN_PARTIAL_CAPTURE' END AS finding;

// Q-08c (not-found reading rule): is the episode-52 item present in the RSS feed capture?
WITH ['hu:source:megaphone-hubermanlab-feed'] AS scope, 'FEED_LISTS_EPISODE' AS pred
MATCH (src:Source) WHERE src.uid IN scope
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
OPTIONAL MATCH (snap)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion {predicate: pred})
WITH src, collect(DISTINCT snap) AS snaps, collect(DISTINCT a) AS hits
WITH collect({src: src, snaps: snaps, hits: hits}) AS rows
RETURN CASE
  WHEN any(r IN rows WHERE size(r.hits) > 0) THEN 'FOUND'
  WHEN all(r IN rows WHERE size(r.snaps) = 0) THEN 'NOT_CAPTURED'
  WHEN all(r IN rows WHERE r.src.renditionCoverage = 'FULL' AND any(s IN r.snaps WHERE s.captureCompleteness = 'COMPLETE'))
       THEN 'NOT_FOUND_IN_COMPLETE_CAPTURE'
  ELSE 'NOT_FOUND_IN_PARTIAL_CAPTURE' END AS finding;

// Q-09 (= V-426, copied verbatim in logic): NOT_DISCLOSED never concluded from a partial capture of the container.
MATCH (c:ConflictRelevanceAssessment {disclosureFinding: 'NOT_DISCLOSED'})-[:FOR_OCCURRENCE]->(o:Assertion)-[:OCCURS_IN]->(container)
WHERE EXISTS {
  MATCH (container)<-[:RENDITION_OF*0..1]-(:Source)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)
  WHERE s.captureCompleteness IS NULL OR s.captureCompleteness <> 'COMPLETE'
}
RETURN c.uid AS undisclosedFromPartialCapture;

// Q-10 (CQ-EV-05 extended): revisions of a publication across its renditions, and the publication-level view.
MATCH (p:Publication {uid: 'hu:publication:pmid-29184669'})<-[:RENDITION_OF]-(src:Source)
OPTIONAL MATCH (e:SourceRevisionEvent)-[:REVISES_SOURCE]->(src)
OPTIONAL MATCH (e)-[:ANNOUNCED_IN]->(n:SourceSnapshot)<-[:HAS_SNAPSHOT]-(ns:Source)-[:RENDITION_OF]->(notice:Publication)
OPTIONAL MATCH (e)-[:PRIOR_SNAPSHOT]->(prior:SourceSnapshot)
OPTIONAL MATCH (e)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
RETURN src.uid AS renditionUid, e.revisionKind AS revisionKind, e.occurredAt AS occurredAt, e.occurredAtPrecision AS precision,
       notice.uid AS announcedByPublication, prior.uid AS priorSnapshot, res.uid AS resultingSnapshot,
       EXISTS { MATCH (notice)-[:CORRECTS]->(p) } AS publicationLevelCorrects
ORDER BY renditionUid;

// Q-11 (CQ-PV-02): the old locator stays on its old snapshot with its original quote; the new locator REANCHORS it.
MATCH (newL:SourceLocator)-[r:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL)
MATCH (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
OPTIONAL MATCH (anySnap:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
RETURN oldL.uid AS oldLocator, sOld.uid AS oldSnapshot, count(DISTINCT anySnap) AS snapshotsHoldingOldLocator,
       oldL.exact = newL.exact AS sameQuote, r.anchorMatch AS anchorMatch, newL.uid AS newLocator, sNew.uid AS newSnapshot,
       sOld.observedAt AS oldObservedAt, sOld.retrievedAt AS oldRetrievedAt, sNew.retrievedAt AS newRetrievedAt;

// Q-12a (= V-409 as written): REANCHORS ordering by retrievedAt. Expected to report the late archive retrieval.
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL
   OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR sNew.retrievedAt <= sOld.retrievedAt
RETURN newL.uid AS newLocator, oldL.uid AS oldLocator;

// Q-12b (proposed V-409', seam W19-SR-09): order by observedAt (content time), not retrievedAt (fetch time).
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL
   OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR coalesce(sNew.observedAt, sNew.retrievedAt) <= coalesce(sOld.observedAt, sOld.retrievedAt)
RETURN newL.uid AS newLocator, oldL.uid AS oldLocator;

// Q-13a (CQ-PV-C02): coverage and freshness as of R = 2026-10-05. Operational status only; never a truth value.
WITH datetime('2026-10-05T00:00:00Z') AS R
MATCH (q:SourceCoverageRequirement)
WHERE q.recordedAt <= R AND (q.recordedTo IS NULL OR q.recordedTo > R)
MATCH (subj) WHERE subj.uid IS NOT NULL AND q.subjectLabel IN labels(subj)
OPTIONAL MATCH (d:SourceDiscoveryRecord)-[:FOR_COVERAGE_REQUIREMENT]->(q) WHERE d.subjectUid = subj.uid AND d.startedAt <= R
WITH q, subj, R, collect(DISTINCT d) AS ds
OPTIONAL MATCH (src:Source)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
WHERE src.sourceKind IN q.requiredSourceKinds AND snap.retrievedAt <= R
  AND ( (src)-[:RENDITION_OF]->(subj)
        OR EXISTS { MATCH (src)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(:Assertion)-[:HAS_SUBJECT]->(subj) }
        OR any(x IN ds WHERE (x)-[:DISCOVERED_SOURCE]->(src)) )
WITH q, subj, R, ds, max(snap.observedAt) AS lastObserved
RETURN q.requirementKey AS requirement, subj.uid AS subjectUid, lastObserved,
  CASE WHEN lastObserved IS NULL AND any(x IN ds WHERE x.discoveryOutcome = 'BLOCKED') THEN 'BLOCKED'
       WHEN lastObserved IS NULL AND size(ds) = 0 THEN 'NOT_ATTEMPTED'
       WHEN lastObserved IS NULL THEN 'NOT_FOUND'
       WHEN duration.inDays(lastObserved, R).days > q.maxSnapshotAgeDays THEN 'STALE'
       ELSE 'FRESH' END AS snapshotCoverage,
  CASE WHEN NOT q.revisionHistoryRequired THEN 'NOT_REQUIRED'
       WHEN any(x IN ds WHERE x.discoveryTarget = 'RECORD_HISTORY' AND x.discoveryOutcome = 'FOUND') THEN 'RETRIEVED'
       WHEN any(x IN ds WHERE x.discoveryTarget = 'RECORD_HISTORY' AND x.discoveryOutcome = 'BLOCKED') THEN 'BLOCKED'
       ELSE 'NOT_ATTEMPTED' END AS historyCoverage
ORDER BY requirement, subjectUid;

// Q-13b (CQ-PV-C02): the same at R = 2027-03-01 (no new captures): everything is STALE; nothing about truth changes.
WITH datetime('2027-03-01T00:00:00Z') AS R
MATCH (q:SourceCoverageRequirement)
WHERE q.recordedAt <= R AND (q.recordedTo IS NULL OR q.recordedTo > R)
MATCH (subj) WHERE subj.uid IS NOT NULL AND q.subjectLabel IN labels(subj)
OPTIONAL MATCH (d:SourceDiscoveryRecord)-[:FOR_COVERAGE_REQUIREMENT]->(q) WHERE d.subjectUid = subj.uid AND d.startedAt <= R
WITH q, subj, R, collect(DISTINCT d) AS ds
OPTIONAL MATCH (src:Source)-[:HAS_SNAPSHOT]->(snap:SourceSnapshot)
WHERE src.sourceKind IN q.requiredSourceKinds AND snap.retrievedAt <= R
  AND ( (src)-[:RENDITION_OF]->(subj)
        OR EXISTS { MATCH (src)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(:Assertion)-[:HAS_SUBJECT]->(subj) }
        OR any(x IN ds WHERE (x)-[:DISCOVERED_SOURCE]->(src)) )
WITH q, subj, R, ds, max(snap.observedAt) AS lastObserved
RETURN q.requirementKey AS requirement, subj.uid AS subjectUid, lastObserved,
  CASE WHEN lastObserved IS NULL AND any(x IN ds WHERE x.discoveryOutcome = 'BLOCKED') THEN 'BLOCKED'
       WHEN lastObserved IS NULL AND size(ds) = 0 THEN 'NOT_ATTEMPTED'
       WHEN lastObserved IS NULL THEN 'NOT_FOUND'
       WHEN duration.inDays(lastObserved, R).days > q.maxSnapshotAgeDays THEN 'STALE'
       ELSE 'FRESH' END AS snapshotCoverage
ORDER BY requirement, subjectUid;

// Q-14a (truth separation guard): operational and authority records never point at assertions, adjudications,
// claims or other assessments, so they cannot become premises of truth or status.
MATCH (x)-[r]->(y)
WHERE (x:SourceCoverageRequirement OR x:SourceDiscoveryRecord OR x:SourceAuthorityAssessment)
  AND (y:Assertion OR y:Adjudication OR y:Claim OR (y:EvidenceAssessment AND NOT y:SourceAuthorityAssessment))
RETURN x.uid AS operationalRecord, type(r) AS relType, y.uid AS truthBearingTarget;

// Q-14b (truth separation): the ACCEPTED registry assertion keeps its capture status whatever the coverage status.
MATCH (a:Assertion {uid: 'hu:assertion:w19-ctgov-nct02678611-enrollment-120'})
OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
RETURN a.status AS status, collect(j.adjudicationKind) AS adjudicationKinds, collect(j.verdict) AS verdicts;

// Q-14c (no global truth score): no Source or authority assessment carries a source-wide truth or reliability number.
MATCH (n)
WHERE (n:Source OR n:SourceAuthorityAssessment)
  AND (any(k IN keys(n) WHERE k IN ['reliabilityScore', 'truthScore', 'trustScore', 'credibilityScore', 'sourceReliability', 'confidence'])
       OR n.overallScore IS NOT NULL)
RETURN n.uid AS nodeWithGlobalScore, [k IN keys(n) WHERE k IN ['reliabilityScore', 'truthScore', 'trustScore', 'credibilityScore', 'sourceReliability', 'confidence', 'overallScore']] AS keys;

// Q-15 (CQ-PV-C01): is each supporting source assessed as authoritative for the claim scope its predicate needs?
// The predicate -> required scope table is a proposed catalog convention (W19-SR-04); here it is a literal map.
WITH {HAS_CAPABILITY_STATE: ['REGULATORY_ACTION', 'CERTIFICATION_STATUS'],
      RESULTS_PUBLISHED: ['BIBLIOGRAPHIC_STATUS', 'STUDY_REPORT'],
      REGISTERED_ENROLLMENT_COUNT: ['TRIAL_REGISTRATION'],
      PROVIDES_INVESTIGATIONAL_PRODUCT: ['STUDY_REPORT', 'TRIAL_REGISTRATION', 'SELF_DECLARATION'],
      CORRECTS: ['BIBLIOGRAPHIC_STATUS']} AS req
MATCH (a:Assertion) WHERE a.predicate IN keys(req)
MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (x:SourceAuthorityAssessment)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
WHERE x.recordedTo IS NULL AND x.status <> 'WITHDRAWN'
WITH a, req[a.predicate] AS needed, src, collect(x) AS xs
WITH a, needed, collect({source: src.uid, sourceKind: src.sourceKind, assessed: size(xs) > 0,
                         authoritative: any(x IN xs WHERE any(s IN x.authorityScopes WHERE s IN needed))}) AS perSource
RETURN a.uid AS assertionUid, a.predicate AS predicate, a.status AS captureStatus, needed AS requiredScopes,
       CASE WHEN any(p IN perSource WHERE p.authoritative) THEN 'AUTHORITATIVE_SOURCE_PRESENT'
            WHEN all(p IN perSource WHERE NOT p.assessed) THEN 'NOT_ASSESSED'
            ELSE 'NO_AUTHORITATIVE_SOURCE' END AS authorityFinding,
       [p IN perSource | p.sourceKind] AS sourceKinds
ORDER BY assertionUid;

// Q-16 (CQ-AX-07, Essential): accepted assertions lacking a locator, a reproducible snapshot, or a capture adjudication.
MATCH (a:Assertion {status: 'ACCEPTED'})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
OPTIONAL MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l)
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a)
WITH a, count(DISTINCT l) AS locators, count(DISTINCT CASE WHEN s.contentHash IS NOT NULL AND s.retrievedAt IS NOT NULL THEN s END) AS reproducibleSnapshots,
     count(DISTINCT j) AS adjudications
WHERE locators = 0 OR reproducibleSnapshots = 0 OR adjudications = 0
RETURN a.uid AS weaklyBackedAcceptedAssertion, locators, reproducibleSnapshots, adjudications;

// Q-17 (CQ-ST-08): what the registry establishes as observed, what it cannot, and whether history was retrieved.
MATCH (t:TrialRegistration {uid: 'hu:trial-registration:nct02678611'})<-[:HAS_SUBJECT]-(a:Assertion)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (x:SourceAuthorityAssessment)-[:ASSESSES_SOURCE_AUTHORITY]->(src)
OPTIONAL MATCH (h:SourceDiscoveryRecord {discoveryTarget: 'RECORD_HISTORY'}) WHERE h.subjectUid = t.uid
RETURN a.predicate AS registryFact, coalesce(a.valueNumber, a.valueBoolean, a.valueString) AS value, snap.observedAt AS observedAt,
       snap.captureCompleteness AS capture, x.notAuthorityForTags AS cannotEstablish, collect(DISTINCT h.discoveryOutcome) AS historyRetrieval
ORDER BY registryFact;

// Q-18 (CQ-PV-01, Essential): the five provenance states for the original occurrence; absent states are named.
MATCH (a:Assertion {uid: 'hu:claim-occurrence:w19-hl52-sinclair-nmn-1g-daily'})
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (j)-[:EVALUATES|ASSESSES_CLAIM_EVIDENCE]->(a)
OPTIONAL MATCH (a)-[:WAS_GENERATED_BY]->(act:Activity)
OPTIONAL MATCH (use:Activity)-[:USED]->(a)
OPTIONAL MATCH (use)-[u:AUTHORIZED_BY]->(pv:PolicyVersion)
RETURN who.uid AS state1_saidBy,
       collect(DISTINCT {locator: l.uid, snapshot: s.uid, source: src.uid, capture: s.captureCompleteness}) AS state2_supportingSpans,
       CASE WHEN count(j) = 0 THEN 'NONE_ASSESSED' ELSE 'ASSESSED' END AS state3_broaderConclusion,
       collect(DISTINCT act.uid) AS state4_generatedBy,
       CASE WHEN count(pv) = 0 THEN 'NO_POLICY_RECORD' ELSE 'AUTHORIZED' END AS state5_policy;
