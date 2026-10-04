// QS-1..QS-8 blocks extracted verbatim from docs/schema/ontology-lab/query-shapes.md for EXPLAIN runs (Wave 6).
// Each block is one statement; comments inside blocks are the original headers.

// QS-1a  Answer trace: assertion -> source locator -> adjudication
// status: statically-checked
// params: $assertionUids list<string>  assertions cited by the answer
//         $recordedAsOf  datetime      R, the recorded-time viewpoint of the answer
MATCH (a:Assertion)
WHERE a.uid IN $assertionUids
  AND a.recordedAt <= $recordedAsOf
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
  OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
  RETURN s.uid AS subjectUid, labels(s) AS subjectLabels, o.uid AS objectUid, labels(o) AS objectLabels
}
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(loc:SourceLocator)
  OPTIONAL MATCH (snap:SourceSnapshot)-[:HAS_LOCATOR]->(loc)
  OPTIONAL MATCH (src:Source)-[:HAS_SNAPSHOT]->(snap)
  RETURN collect(DISTINCT CASE WHEN loc IS NULL THEN NULL ELSE {
    locatorUid: loc.uid, uri: loc.uri, selector: loc.selector, page: loc.page,
    section: loc.section, quoteHash: loc.quoteHash,
    snapshotUid: snap.uid, observedAt: snap.observedAt, retrievedAt: snap.retrievedAt,
    contentHash: snap.contentHash, sourceUid: src.uid, canonicalUri: src.canonicalUri,
    sourceKind: src.sourceKind } END) AS supports
}
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:CONTRADICTED_BY]->(cloc:SourceLocator)
  RETURN collect(DISTINCT cloc.uid) AS contradictingLocatorUids
}
CALL {
  WITH a
  OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
  WHERE j.reviewedAt <= $recordedAsOf
  WITH j ORDER BY j.reviewedAt DESC
  RETURN collect(CASE WHEN j IS NULL THEN NULL ELSE {
    adjudicationUid: j.uid, verdict: j.verdict, reviewedAt: j.reviewedAt,
    reviewerType: j.reviewerType, rationale: j.rationale } END) AS adjudicationsAsOfR
}
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:ASSERTED_BY]->(by)
  RETURN collect(DISTINCT {uid: by.uid, name: by.name, labels: labels(by)}) AS assertedBy
}
RETURN a.uid AS assertionUid,
       a.predicate AS predicate,
       a.polarity AS polarity,
       subjectUid, subjectLabels, objectUid, objectLabels,
       a.valueString AS valueString, a.valueNumber AS valueNumber,
       a.valueBoolean AS valueBoolean, a.unitCode AS unitCode,
       a.validFrom AS validFrom, a.validTo AS validTo, a.validFromBasis AS validFromBasis, a.validToBasis AS validToBasis,
       a.recordedAt AS recordedAt,
       a.status AS currentStatus,            // a cache of the latest state, NOT as-of R
       assertedBy, supports, contradictingLocatorUids,
       adjudicationsAsOfR,
       adjudicationsAsOfR[0] AS latestAdjudicationAsOfR,
       [gap IN [
         CASE WHEN size(supports) = 0 THEN 'NO_LOCATOR' END,
         CASE WHEN size([x IN supports WHERE x.snapshotUid IS NULL]) > 0 THEN 'LOCATOR_WITHOUT_SNAPSHOT' END,
         CASE WHEN size([x IN supports WHERE x.contentHash IS NULL OR x.retrievedAt IS NULL]) > 0 THEN 'SNAPSHOT_NOT_REPRODUCIBLE' END,
         CASE WHEN size(adjudicationsAsOfR) = 0 THEN 'NO_ADJUDICATION_AS_OF_R' END,
         CASE WHEN size(contradictingLocatorUids) > 0 AND size(adjudicationsAsOfR) = 0 THEN 'CONTRADICTION_UNADJUDICATED' END
       ] WHERE gap IS NOT NULL] AS traceGaps;

// QS-1b  Trace over the LIVE evidence pipeline (Claim / ClaimOccurrence / Chunk / Document)
// status: statically-checked
// Uses stored property names, not GraphQL field names: Document.id is stored as documentId,
// Document.name as title, Chunk.id as chunkId, Chunk.chunkIndex as index,
// DocumentTextVersion.id as documentTextVersionId.
// params: $claimId string  (live Claim.id)
MATCH (c:Claim {id: $claimId})
OPTIONAL MATCH (occ:ClaimOccurrence)-[:INSTANCE_OF]->(c)
OPTIONAL MATCH (occ)-[:UTTERED_BY]->(speaker)
OPTIONAL MATCH (occ)-[:OCCURS_IN]->(container)
OPTIONAL MATCH (occ)-[sup:SUPPORTED_BY]->(chunk:Chunk)
OPTIONAL MATCH (chunk)-[:FROM_TEXT_VERSION]->(tv:DocumentTextVersion)
OPTIONAL MATCH (doc:Document)-[:HAS_TEXT_VERSION]->(tv)
RETURN c.id AS claimId, c.claimText AS claimText, c.claimType AS claimType,
       occ.id AS occurrenceId, occ.utteranceText AS utteranceText,
       speaker.id AS speakerId, labels(speaker) AS speakerLabels,
       labels(container) AS containerLabels, container.id AS containerId,
       chunk.chunkId AS chunkId, chunk.index AS chunkIndex,
       sup.quoteSpan AS quoteSpan, sup.extractionMethod AS extractionMethod,
       sup.extractorVersion AS extractorVersion, sup.extractedAt AS extractedAt,
       tv.documentTextVersionId AS textVersionId, tv.textVersionHash AS textVersionHash,
       doc.documentId AS documentId, doc.title AS documentTitle, doc.url AS documentUrl,
       doc.publishedAt AS publishedAt,
       // the live pipeline has no adjudication surface; the gap is reported, not hidden
       'NO_ADJUDICATION_SURFACE' AS adjudicationState,
       c.evidenceStrength AS liveEvidenceStrengthAttribute;

// QS-2a  Assertion-level bitemporal as-of:
//        "what was recorded as believed on R about what was true on V"
// status: statically-checked
// params: $subjectUid string, $predicates list<string>,
//         $recordedAsOf datetime (R), $validAt datetime (V),
//         $excludeVerdicts list<string>  e.g. ['CONTRADICTED']
// Belief at R = recorded by R, not superseded by an assertion recorded by R,
// and not contradicted by an adjudication reviewed by R.
// The supersession test is isolated in the NOT EXISTS block (Lane 5 round 0007 may change its encoding).
MATCH (a:Assertion)-[:HAS_SUBJECT]->(s {uid: $subjectUid})
WHERE a.predicate IN $predicates
  AND a.recordedAt <= $recordedAsOf
  AND NOT EXISTS {
    MATCH (b:Assertion)-[:SUPERSEDES]->(a)
    WHERE b.recordedAt <= $recordedAsOf
  }
CALL {
  WITH a
  OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a)
  WHERE j.reviewedAt <= $recordedAsOf
  WITH j ORDER BY j.reviewedAt DESC LIMIT 1
  RETURN j.verdict AS latestVerdict, j.uid AS adjudicationUid
}
WITH a, s, latestVerdict, adjudicationUid
WHERE latestVerdict IS NULL OR NOT latestVerdict IN $excludeVerdicts
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
  WHERE snap.retrievedAt <= $recordedAsOf
  RETURN max(snap.observedAt) AS lastObservedAt
}
WITH a, s, latestVerdict, adjudicationUid, lastObservedAt,
     CASE
       WHEN a.validFrom IS NOT NULL AND a.validFrom > $validAt THEN 'EXCLUDED'
       WHEN a.validTo IS NOT NULL AND a.validTo <= $validAt THEN 'EXCLUDED'
       WHEN a.validFrom IS NULL AND a.validTo IS NULL THEN 'UNKNOWN_BOTH_BOUNDS'
       WHEN a.validFrom IS NULL THEN 'UNKNOWN_START'
       WHEN a.validTo IS NOT NULL THEN 'KNOWN_WITHIN'
       WHEN lastObservedAt IS NOT NULL AND lastObservedAt >= $validAt THEN 'OPEN_END_SUPPORTED'
       ELSE 'OPEN_END_STALE'
     END AS validityClass
WHERE validityClass <> 'EXCLUDED'
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
RETURN a.uid AS assertionUid, a.predicate AS predicate, a.polarity AS polarity,
       o.uid AS objectUid, a.valueString AS valueString, a.valueNumber AS valueNumber,
       a.unitCode AS unitCode,
       validityClass,
       a.validFrom AS validFrom, a.validTo AS validTo, a.validFromBasis AS validFromBasis, a.validToBasis AS validToBasis,
       lastObservedAt,
       a.recordedAt AS recordedAt,
       latestVerdict, adjudicationUid
ORDER BY a.predicate, a.recordedAt;

// QS-2b  Edge-level bitemporal as-of for an asserted relationship
//        (shown for HAS_FORMULATION_VERSION; substitute any asserted type in $relTypes via one query per type)
// status: statically-checked
// params: $variantUid string, $recordedAsOf datetime (R), $validAt datetime (V),
//         $includeLegacy boolean  (live edges that never had recordedFrom; see live-schema-decisions.md)
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE (r.recordedFrom IS NOT NULL AND r.recordedFrom <= $recordedAsOf
       AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo))
   OR (r.recordedFrom IS NULL AND $includeLegacy)
OPTIONAL MATCH (a:Assertion {uid: coalesce(r.assertionUid, r.projectionOfAssertionUid)})
CALL {
  WITH a
  OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
  WHERE snap.retrievedAt <= $recordedAsOf
  RETURN max(snap.observedAt) AS lastObservedAt
}
WITH v, r, f, a, lastObservedAt,
     CASE
       WHEN r.validFrom IS NOT NULL AND r.validFrom > $validAt THEN 'EXCLUDED'
       WHEN r.validTo IS NOT NULL AND r.validTo <= $validAt THEN 'EXCLUDED'
       WHEN r.validFrom IS NULL AND r.validTo IS NULL THEN 'UNKNOWN_BOTH_BOUNDS'
       WHEN r.validFrom IS NULL THEN 'UNKNOWN_START'
       WHEN r.validTo IS NOT NULL THEN 'KNOWN_WITHIN'
       WHEN lastObservedAt IS NOT NULL AND lastObservedAt >= $validAt THEN 'OPEN_END_SUPPORTED'
       ELSE 'OPEN_END_STALE'
     END AS validityClass
WHERE validityClass <> 'EXCLUDED'
RETURN f.uid AS formulationUid,
       validityClass,
       r.validFrom AS validFrom, r.validTo AS validTo, r.validFromBasis AS validFromBasis, r.validToBasis AS validToBasis,
       r.recordedFrom AS recordedFrom, r.recordedTo AS recordedTo,
       CASE WHEN r.recordedFrom IS NULL THEN 'LEGACY_UNDATED' ELSE 'RECORDED' END AS recordedClass,
       lastObservedAt,
       a.uid AS authorizingAssertionUid
ORDER BY r.recordedFrom DESC, f.uid;

// QS-2b-interval  Same view for a valid-time INTERVAL [$intervalStart, $intervalEnd)
//                 (CQ-ID-02: which formulation applied while a study intervention was administered)
// status: statically-checked
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE r.recordedFrom IS NOT NULL AND r.recordedFrom <= $recordedAsOf
  AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo)
WITH f, r,
     CASE
       WHEN r.validTo IS NOT NULL AND r.validTo <= $intervalStart THEN 'EXCLUDED'
       WHEN r.validFrom IS NOT NULL AND r.validFrom >= $intervalEnd THEN 'EXCLUDED'
       WHEN r.validFrom IS NULL THEN 'OVERLAP_START_UNKNOWN'
       WHEN r.validFrom <= $intervalStart AND r.validTo IS NULL THEN 'COVERS_INTERVAL_IF_STILL_TRUE'
       WHEN r.validFrom <= $intervalStart AND r.validTo >= $intervalEnd THEN 'COVERS_INTERVAL'
       ELSE 'PARTIAL_OVERLAP'
     END AS overlapClass
WHERE overlapClass <> 'EXCLUDED'
RETURN f.uid AS formulationUid, overlapClass, r.validFrom AS validFrom, r.validTo AS validTo,
       r.validFromBasis AS validFromBasis, r.validToBasis AS validToBasis, r.recordedFrom AS recordedFrom
ORDER BY r.validFrom;

// QS-2c  What did the system learn between two recorded dates about a variant's formulations?
//        (late facts and corrections appear as BELIEF_ADDED / BELIEF_CLOSED; valid-time is never rewritten)
// status: statically-checked
// params: $variantUid, $recordedFrom R1, $recordedTo R2
MATCH (v:ProductVariant {uid: $variantUid})-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WITH f, r,
     (r.recordedFrom > $recordedFrom AND r.recordedFrom <= $recordedTo) AS addedInWindow,
     (r.recordedTo IS NOT NULL AND r.recordedTo > $recordedFrom AND r.recordedTo <= $recordedTo) AS closedInWindow
WHERE addedInWindow OR closedInWindow
RETURN f.uid AS formulationUid, r.validFrom AS validFrom, r.validTo AS validTo,
       r.recordedFrom AS recordedFrom, r.recordedTo AS recordedTo,
       addedInWindow, closedInWindow
ORDER BY coalesce(r.recordedTo, r.recordedFrom);

// QS-3a  Evidence applicability: surface the weakest dimension and the unresolved ones
//        (never a single score; a score, if present, is returned separately with its method version)
// status: statically-checked, executed (2026-10-03, embedded Neo4j 5.26, fixture study-vs-product-mismatch:
//         on hu:applicability:nct02678611-1x-to-basis-current it returns 13 dimension nodes with their verdicts,
//         weakest first; the flat identityMatch/doseMatch fields are not read because the catalog marks them derived)
// params: $applicabilityUid string
// Dimension verdicts (catalog applicabilityVerdict): MATCH | PARTIAL | MISMATCH | UNKNOWN | NOT_ASSESSED | NOT_SCORED.
// A required dimension with no node is reported as MISSING_DIMENSION, which is different from UNKNOWN (assessed, facts
// insufficient) and from NOT_ASSESSED (a node that records that nobody assessed it).
MATCH (ea:EvidenceApplicability {uid: $applicabilityUid})
OPTIONAL MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(evTarget)
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(target)
OPTIONAL MATCH (ea)-[:BASED_ON_EVIDENCE]->(evidence)
WITH ea, evTarget, collect(DISTINCT target.uid) AS targetUids, collect(DISTINCT evidence.uid) AS evidenceUids,
     CASE WHEN evTarget:Assertion
          THEN ['MATERIAL_IDENTITY', 'EXPOSURE', 'ROUTE', 'DURATION', 'POPULATION', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
          ELSE ['MATERIAL_IDENTITY', 'ACTIVE_COMPOSITION', 'DOSE', 'DOSAGE_FORM', 'ROUTE', 'SCHEDULE', 'DURATION', 'POPULATION', 'COMPARATOR', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
     END AS required
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, evTarget, targetUids, evidenceUids, required, collect(d) AS dims
UNWIND required + [x IN [d IN dims | d.dimension] WHERE NOT x IN required] AS dimName
WITH ea, evTarget, targetUids, evidenceUids, dimName, head([d IN dims WHERE d.dimension = dimName]) AS d
WITH ea, evTarget, targetUids, evidenceUids, dimName, d,
     CASE WHEN d IS NULL THEN 'MISSING_DIMENSION' ELSE coalesce(d.verdict, 'NOT_ASSESSED') END AS state
WITH ea, evTarget, targetUids, evidenceUids, dimName, d, state,
     CASE state
       WHEN 'MISMATCH' THEN 0
       WHEN 'MISSING_DIMENSION' THEN 1
       WHEN 'UNKNOWN' THEN 1
       WHEN 'NOT_ASSESSED' THEN 1
       WHEN 'PARTIAL' THEN 2
       WHEN 'MATCH' THEN 3
       ELSE 4           // NOT_SCORED (explanation-only) and NOT_APPLICABLE never rank as weakest
     END AS strength
ORDER BY strength ASC, dimName ASC
WITH ea, evTarget, targetUids, evidenceUids,
     collect({dimension: dimName, state: state, strength: strength, dimensionClass: d.dimensionClass,
              identityLevel: d.identityLevel, ratio: d.ratio, missingFacts: coalesce(d.missingFacts, []), rationale: d.rationale}) AS ranked
RETURN ea.uid AS applicabilityUid,
       ea.methodVersion AS methodVersion,
       ea.status AS assessmentStatus,
       evTarget.uid AS evidenceTargetUid, targetUids, evidenceUids,
       [x IN ranked WHERE x.strength = ranked[0].strength] AS weakestDimensions,
       [x IN ranked WHERE x.state IN ['UNKNOWN', 'NOT_ASSESSED', 'MISSING_DIMENSION']] AS unresolvedDimensions,
       ranked AS allDimensionsWeakestFirst,
       ea.overallScore AS derivedScoreIfAny;

// QS-3b  Missing-fact probes behind an UNKNOWN identity, dose, or formulation dimension
// status: statically-checked
// params: $applicabilityUid, $recordedAsOf (R), $validAt (V)
MATCH (ea:EvidenceApplicability {uid: $applicabilityUid})
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(v:ProductVariant)
OPTIONAL MATCH (v)-[hf:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE hf.recordedFrom <= $recordedAsOf AND (hf.recordedTo IS NULL OR $recordedAsOf < hf.recordedTo)
  AND (hf.validFrom IS NULL OR hf.validFrom <= $validAt)
  AND (hf.validTo IS NULL OR $validAt < hf.validTo)
OPTIONAL MATCH (ea)-[:BASED_ON_EVIDENCE]->(st:Study)-[:HAS_ARM]->(:StudyArm)-[:ASSIGNS_INTERVENTION]->(:StudyIntervention)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
OPTIONAL MATCH (ic)-[:USES_INTERVENTION_MATERIAL]->(m)
WITH ea, v, st,
     count(DISTINCT f) AS candidateFormulations,
     count(DISTINCT ic) AS components,
     count(DISTINCT CASE WHEN m IS NULL AND ic IS NOT NULL THEN ic END) AS unresolvedComponents
RETURN ea.uid AS applicabilityUid,
       [x IN [
          CASE WHEN v IS NULL THEN 'TARGET_IS_NOT_A_RESOLVED_VARIANT' END,
          CASE WHEN v IS NOT NULL AND candidateFormulations = 0 THEN 'NO_FORMULATION_RECORDED_FOR_TARGET_AT_V_AS_OF_R' END,
          CASE WHEN v IS NOT NULL AND candidateFormulations > 1 THEN 'SEVERAL_FORMULATIONS_POSSIBLE_AT_V' END,
          CASE WHEN st IS NULL THEN 'NO_STUDY_EVIDENCE_LINKED' END,
          CASE WHEN st IS NOT NULL AND components = 0 THEN 'NO_INTERVENTION_COMPONENT_RECORDED' END,
          CASE WHEN unresolvedComponents > 0 THEN 'INTERVENTION_MATERIAL_UNRESOLVED' END
       ] WHERE x IS NOT NULL] AS missingFacts;

// QS-4a  Forbidden-implication and derived-edge audit (zero rows = valid)
// status: statically-checked
// params: $derivedTypes list<string>         relationship types the catalog marks class: derived, e.g. ['CONTAINS']
//         $implicationPairs list<list<string>>  catalog forbiddenImplications as [premise, conclusion],
//                                               e.g. [['ADVISES_ORGANIZATION','ENDORSES_PRODUCT'],['LISTS_OFFER','SELLS_PRODUCT']]
// Citation is projectionOfAssertionUid (derived edge projecting one assertion) or assertionUid (asserted edge),
// or derivationRule plus derivedFromAssertionUids (multi-hop derived edge such as CONTAINS).
// Scans every relationship of the listed types; run per type in production for index-friendly plans.
MATCH (x)-[r]->(y)
WHERE type(r) IN $derivedTypes
   OR type(r) IN [p IN $implicationPairs | p[1]]
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
OPTIONAL MATCH (src:Assertion)
WHERE src.uid IN coalesce(r.derivedFromAssertionUids, [])
WITH x, y, r, citedUid, cited, count(DISTINCT src) AS sourcesFound,
     size(coalesce(r.derivedFromAssertionUids, [])) AS sourcesDeclared
WITH x, y, r, cited,
     [v IN [
        CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND NOT EXISTS { (cited)-[:HAS_SUBJECT]->(x) } THEN 'CITED_SUBJECT_IS_NOT_EDGE_START' END,
        CASE WHEN cited IS NOT NULL AND NOT EXISTS { (cited)-[:HAS_OBJECT]->(y) } THEN 'CITED_OBJECT_IS_NOT_EDGE_END' END,
        CASE WHEN cited IS NOT NULL AND cited.status IN ['REJECTED', 'SUPERSEDED'] AND r.recordedTo IS NULL THEN 'CITED_ASSERTION_NOT_LIVE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
        CASE WHEN r.derivationRule IS NOT NULL AND sourcesDeclared = 0 THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
        CASE WHEN sourcesDeclared > sourcesFound THEN 'DERIVED_FROM_ASSERTION_MISSING' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, elementId(r) AS edgeId, violations;

// QS-4b  Write-time precondition for a proposed derived or projected edge (agent typed intent)
// status: statically-checked
// params: $edgeType, $subjectUid, $objectUid, $citedAssertionUid, $recordedAsOf, $allowedStatuses (e.g. ['ACCEPTED'])
// Returns writeAllowed = true only when exactly one live, matching assertion backs the edge.
OPTIONAL MATCH (a:Assertion {uid: $citedAssertionUid})
WHERE a.predicate = $edgeType
  AND a.recordedAt <= $recordedAsOf
  AND a.status IN $allowedStatuses
  AND EXISTS { (a)-[:HAS_SUBJECT]->({uid: $subjectUid}) }
  AND EXISTS { (a)-[:HAS_OBJECT]->({uid: $objectUid}) }
  AND NOT EXISTS { MATCH (b:Assertion)-[:SUPERSEDES]->(a) WHERE b.recordedAt <= $recordedAsOf }
RETURN a IS NOT NULL AS writeAllowed,
       CASE WHEN a IS NULL THEN 'NO_LIVE_MATCHING_ASSERTION' END AS refusalReason;

// QS-5b  Data query a compiler emits from a purpose-bound projection request (see QS-5a)
// status: statically-checked
// Compiler substitutions: the quantifier bound {1,3} is a literal copied from budgets.maxTraversalDepth.
// params: $rootUid, $allowedLabels list<string>, $allowedRelTypes list<string>,
//         $recordedAsOf (temporalView.recordedAt), $validAt (temporalView.validAt), $maxRelationships
MATCH (root {uid: $rootUid})
WHERE NOT (root.uid STARTS WITH 'hu:private-' OR root.privacyClass = 'private-personal' OR root:PrivateRecord)
  AND any(l IN labels(root) WHERE l IN $allowedLabels)
MATCH p = (root)((a)-[r]->(b)
               WHERE NOT (b.uid STARTS WITH 'hu:private-' OR b.privacyClass = 'private-personal' OR b:PrivateRecord)
                 AND type(r) IN $allowedRelTypes
                 AND any(l IN labels(b) WHERE l IN $allowedLabels)
                 AND (r.recordedFrom IS NULL
                      OR (r.recordedFrom <= $recordedAsOf AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo)))
                 AND (r.validFrom IS NULL OR r.validFrom <= $validAt)
                 AND (r.validTo IS NULL OR $validAt < r.validTo)){1,3}(leaf)
RETURN [n IN nodes(p) | n.uid] AS nodeUids,
       [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT $maxRelationships;

// QS-6a  Shared-graph traversal that cannot enter private user context
// status: statically-checked
// A private node is recognised by uid prefix, privacy class, or the fixture-only PrivateRecord label (see property-cards.md in this directory).
// The test sits on every hop, in both directions: an incoming private node
// (UserContext -[:ABOUT]-> Product) would otherwise act as a bridge between two shared nodes.
// params: $uid string, $privateRelTypes list<string> (defence in depth), $maxHops is a compiler-substituted literal (2 here)
MATCH (s {uid: $uid})
WHERE NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
MATCH p = (s)(()-[r]-(n) WHERE NOT (n.uid STARTS WITH 'hu:private-' OR n.privacyClass = 'private-personal' OR n:PrivateRecord)){1,2}
WHERE none(rel IN relationships(p) WHERE type(rel) IN $privateRelTypes)
RETURN DISTINCT [x IN nodes(p) | x.uid] AS nodeUids, [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT 500;

// QS-6b-1  Leak detector: a shared node must never point at a private node (zero rows = valid)
// status: statically-checked
MATCH (s)-[r]->(p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
RETURN labels(s) AS sharedLabels, s.uid AS sharedUid, type(r) AS relType, p.uid AS privateUid;

// QS-6b-2  Private-to-shared references are allowed only as governed reference types (zero rows = valid)
// status: statically-checked
// params: $allowedReferenceTypes list<string> (Lane 5 owns the list, e.g. REFERENCES_PRODUCT_VARIANT)
MATCH (p)-[r]->(s)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
  AND NOT type(r) IN $allowedReferenceTypes
RETURN p.uid AS privateUid, type(r) AS relType, s.uid AS sharedUid;

// QS-6b-3  A private node must not carry a label that a shared fulltext or vector index covers (zero rows = valid)
// status: statically-checked
// params: $sharedIndexedLabels list<string>  (derive from SHOW INDEXES, see V-110)
MATCH (p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND any(l IN labels(p) WHERE l IN $sharedIndexedLabels)
RETURN p.uid AS privateUid, labels(p) AS labels;

// QS-7  Unknown versus absent: three-valued answer to "does subject S have object O under predicate P?"
// status: statically-checked
// params: $subjectUid, $predicate, $objectUid, $recordedAsOf (R), $validAt (V)
// An empty result set means NOT_RECORDED, never ASSERTED_ABSENT. Absence needs its own negative assertion.
MATCH (s {uid: $subjectUid})
OPTIONAL MATCH (a:Assertion {predicate: $predicate})-[:HAS_SUBJECT]->(s)
WHERE a.recordedAt <= $recordedAsOf
  AND (a.validFrom IS NULL OR a.validFrom <= $validAt)
  AND (a.validTo IS NULL OR $validAt < a.validTo)
  AND EXISTS { (a)-[:HAS_OBJECT]->({uid: $objectUid}) }
  AND NOT EXISTS { MATCH (b:Assertion)-[:SUPERSEDES]->(a) WHERE b.recordedAt <= $recordedAsOf }
WITH s, collect(a) AS matches
OPTIONAL MATCH (ls:LabelSnapshot)-[:LABEL_FOR]->(s)
WHERE ls.observedAt <= $validAt
WITH matches, count(ls) AS coveringLabelSnapshots
RETURN CASE
         WHEN any(m IN matches WHERE m.polarity = 'POSITIVE') AND any(m IN matches WHERE m.polarity = 'NEGATIVE') THEN 'CONFLICTING'
         WHEN any(m IN matches WHERE m.polarity = 'POSITIVE') THEN 'ASSERTED_PRESENT'
         WHEN any(m IN matches WHERE m.polarity = 'NEGATIVE') THEN 'ASSERTED_ABSENT'
         WHEN size(matches) > 0 THEN 'ASSERTED_UNKNOWN'
         WHEN coveringLabelSnapshots > 0 THEN 'NOT_DECLARED_IN_COVERING_SOURCE'
         ELSE 'NOT_RECORDED'
       END AS state,
       [m IN matches | m.uid] AS assertionUids,
       coveringLabelSnapshots;

// QS-8  Free text to candidate identities (live search surface); a hit is a candidate, never an identity
// status: statically-checked
// The fulltext index must exist (the Neo4j GraphQL library does not create it); name from the live @fulltext directive.
// params: $indexName (e.g. 'ProductSearch'), $phrase, $limit
CALL db.index.fulltext.queryNodes($indexName, $phrase) YIELD node, score
WITH node, score
ORDER BY score DESC
LIMIT $limit
OPTIONAL MATCH (h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(node)
RETURN node.uid AS catalogUid,
       coalesce(node.id, node.documentId, node.chunkId, node.documentTextVersionId, node.segmentationId) AS liveId,
       labels(node) AS labels,
       node.name AS name,
       score AS indexScore,                      // lexical score of this index only; not a resolutionConfidence
       collect(DISTINCT {hypothesisUid: h.uid, status: h.resolutionStatus, score: h.score}) AS openHypotheses
ORDER BY indexScore DESC;
