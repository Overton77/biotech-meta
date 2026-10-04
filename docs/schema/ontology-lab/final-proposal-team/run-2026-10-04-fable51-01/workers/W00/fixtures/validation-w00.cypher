// W00 kernel validation suite (zero rows = valid unless the header says informational).
// Copies of catalog validators V-000a..V-512 restricted to the kernel, with the catalog parameter lists
// INLINED for the fixtures (assertedTypes, derivedTypes, implicationPairs, ruleOnlyDerivedTypes), plus new
// W00 checks V-W00-01..V-W00-12. Each statement binds its own variables. Run after each fixture on a fresh graph.
// Inline lists used by the fixtures:
//   assertedTypes  = HAS_FORMULATION_VERSION, HAS_STATE, HAS_IDENTIFIER, BOARD_MEMBER_OF, ADVISES_ORGANIZATION,
//                    SELLER_OF_RECORD_FOR, HOSTS_LISTING, LISTS_OFFER, ENDORSES_PRODUCT, IDENTIFIED_BY
//   derivedTypes   = SELLS_PRODUCT, CONTAINS, INSTANCE_OF
//   implicationPairs (catalog forbiddenImplications whose conclusion is an edge type):
//     [ADVISES_ORGANIZATION, ENDORSES_PRODUCT], [SPONSORS_CONTENT, ENDORSES_PRODUCT], [LISTS_OFFER, SELLS_PRODUCT],
//     [HOSTS_LISTING, SELLS_PRODUCT], [FULFILLS_OFFER, SELLS_PRODUCT], [AFFILIATE_FOR_OFFER, SELLS_PRODUCT]
//   ruleOnlyDerivedTypes = INSTANCE_OF

// V-000a: uid is globally unique across base archetypes.
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n.uid AS uid, collect(n) AS nodes
WHERE uid IS NULL OR size(nodes) <> 1
RETURN 'V-000a' AS check, uid, size(nodes) AS nodeCount;

// V-000b: every semantic node has exactly one base archetype (INV-001, D-001).
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n, size([label IN labels(n) WHERE label IN ['Entity','VersionedState','Occurrence','InformationArtifact','Assertion','EvidenceAssessment']]) AS archetypeCount
WHERE archetypeCount <> 1
RETURN 'V-000b' AS check, n.uid AS uid, labels(n) AS labels, archetypeCount;

// V-002: assertions require exactly one subject.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
WITH a, count(s) AS subjects
WHERE subjects <> 1
RETURN 'V-002' AS check, a.uid AS assertionUid, subjects;

// V-003: exactly one object OR one typed literal (INV-003 literal-xor-object).
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, count(o) AS objects, size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
WHERE objects + literals <> 1
RETURN 'V-003' AS check, a.uid AS assertionUid, objects, literals;

// V-W00-01: at most one asserter per Assertion (INV-003, KCR-4.3). No catalog V-id covered generic Assertions.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(x)
WITH a, count(DISTINCT x) AS asserters
WHERE asserters > 1
RETURN 'V-W00-01' AS check, a.uid AS assertionUid, asserters;

// V-410: a ClaimOccurrence has exactly one container and exactly one asserter.
MATCH (a:ClaimOccurrence)
OPTIONAL MATCH (a)-[:OCCURS_IN]->(c)
WITH a, count(DISTINCT c) AS containers
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(s)
WITH a, containers, count(DISTINCT s) AS asserters
WHERE containers <> 1 OR asserters <> 1
RETURN 'V-410' AS check, a.uid AS occurrenceUid, containers, asserters;

// V-101: every asserted edge carries its authorizing assertion and a recorded-time start.
MATCH ()-[r]->()
WHERE type(r) IN ['HAS_FORMULATION_VERSION','HAS_STATE','HAS_IDENTIFIER','BOARD_MEMBER_OF','ADVISES_ORGANIZATION','SELLER_OF_RECORD_FOR','HOSTS_LISTING','LISTS_OFFER','ENDORSES_PRODUCT','IDENTIFIED_BY']
  AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL OR r.relationshipUid IS NULL)
RETURN 'V-101' AS check, type(r) AS relType, r.relationshipUid AS episode;

// V-105 / V-503: bound, precision and basis agree on assertions (per-bound; INFERRED needs derivationRule).
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND (a.validFromBasis IS NULL OR a.validFromPrecision IS NULL OR NOT a.validFromBasis IN ['STATED_BY_SOURCE','PUBLICATION_PROXY','INFERRED']))
   OR (a.validTo IS NOT NULL AND (a.validToBasis IS NULL OR a.validToPrecision IS NULL OR NOT a.validToBasis IN ['STATED_BY_SOURCE','PUBLICATION_PROXY','INFERRED']))
   OR (a.validFromBasis IN ['OBSERVATION_ONLY','UNKNOWN'] AND a.validFrom IS NOT NULL)
   OR (a.validToBasis IN ['OBSERVATION_ONLY','UNKNOWN'] AND a.validTo IS NOT NULL)
   OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
   OR a.validTimeBasis IS NOT NULL
RETURN 'V-105/V-503' AS check, a.uid AS assertionUid;

// V-102/V-103/V-104: non-empty ordered intervals and no sentinel dates (assertions and edges).
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND a.validTo IS NOT NULL AND a.validFrom >= a.validTo)
   OR (a.validTo IS NOT NULL AND a.validTo.year >= 9000) OR (a.validFrom IS NOT NULL AND a.validFrom.year <= 1)
   OR (a.recordedTo IS NOT NULL AND a.recordedTo < a.recordedAt)
RETURN 'V-103' AS check, a.uid AS item
UNION
MATCH ()-[r]->()
WHERE (r.validFrom IS NOT NULL AND r.validTo IS NOT NULL AND r.validFrom >= r.validTo)
   OR (r.recordedFrom IS NOT NULL AND r.recordedTo IS NOT NULL AND r.recordedFrom >= r.recordedTo)
   OR (r.validTo IS NOT NULL AND r.validTo.year >= 9000)
RETURN 'V-102' AS check, coalesce(r.relationshipUid, elementId(r)) AS item;

// V-504: no backdating (episode before its assertion; assertion before its snapshot was retrieved).
MATCH ()-[h]->()
WHERE h.assertionUid IS NOT NULL
MATCH (a:Assertion {uid: h.assertionUid})
WHERE h.recordedFrom < a.recordedAt
RETURN 'V-504' AS check, 'EPISODE_BEFORE_ASSERTION' AS violation, h.relationshipUid AS item
UNION
MATCH (a:Assertion)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE a.recordedAt < sn.retrievedAt
RETURN 'V-504' AS check, 'ASSERTION_BEFORE_RETRIEVAL' AS violation, a.uid AS item;

// V-W00-11 (generalizes V-505 to every asserted edge; catalog asserted_edge rules): the edge is a faithful
// projection of the Assertion it names.
MATCH (x)-[r]->(y)
WHERE r.assertionUid IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
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
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-W00-11' AS check, type(r) AS relType, r.relationshipUid AS episode, violations;

// V-W00-02 (D-011, CL-009): asserted edges carry assertionUid, derived edges projectionOfAssertionUid, never both;
// an asserted type never carries projectionOfAssertionUid; a derived type never carries assertionUid.
MATCH ()-[r]->()
WHERE (r.assertionUid IS NOT NULL AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN ['HAS_FORMULATION_VERSION','HAS_STATE','HAS_IDENTIFIER','BOARD_MEMBER_OF','ADVISES_ORGANIZATION','SELLER_OF_RECORD_FOR','HOSTS_LISTING','LISTS_OFFER','ENDORSES_PRODUCT','IDENTIFIED_BY'] AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN ['SELLS_PRODUCT','CONTAINS','INSTANCE_OF'] AND r.assertionUid IS NOT NULL)
RETURN 'V-W00-02' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge;

// V-506: supersession closes the older assertion exactly at the newer one's recordedAt; status projection agrees.
MATCH (newer:Assertion)-[s:SUPERSEDES]->(older:Assertion)
WHERE older.recordedTo IS NULL OR older.recordedTo <> s.recordedAt OR newer.recordedAt <> s.recordedAt
RETURN 'V-506' AS check, 'CLOSURE_MISMATCH' AS violation, older.uid AS item
UNION
MATCH (a:Assertion)
WHERE (a.recordedTo IS NOT NULL AND NOT a.status IN ['SUPERSEDED','REJECTED'])
   OR (a.status = 'SUPERSEDED' AND NOT ()-[:SUPERSEDES]->(a))
RETURN 'V-506' AS check, 'STATUS_PROJECTION_MISMATCH' AS violation, a.uid AS item;

// V-507: SUPERSEDES links like to like, newer to older, no cycles.
MATCH (x)-[s:SUPERSEDES]->(y)
WHERE NOT ((x:Assertion AND y:Assertion) OR (x:Adjudication AND y:Adjudication) OR (x:EvidenceAssessment AND y:EvidenceAssessment))
   OR x.recordedAt < y.recordedAt OR s.supersessionKind IS NULL OR s.recordedAt IS NULL
RETURN 'V-507' AS check, 'BAD_SUPERSESSION' AS violation, x.uid AS item
UNION
MATCH p = (x)-[:SUPERSEDES*1..20]->(x)
RETURN 'V-507' AS check, 'SUPERSESSION_CYCLE' AS violation, x.uid AS item;

// V-507b: VALIDITY_BOUNDED keeps object and start and only closes an open end.
MATCH (newer:Assertion)-[:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED'}]->(older:Assertion)
OPTIONAL MATCH (newer)-[:HAS_OBJECT]->(newObj)
OPTIONAL MATCH (older)-[:HAS_OBJECT]->(oldObj)
WITH newer, older, newObj, oldObj
WHERE coalesce(newObj.uid,'-') <> coalesce(oldObj.uid,'-')
   OR coalesce(toString(newer.valueNumber),'-') <> coalesce(toString(older.valueNumber),'-')
   OR coalesce(newer.valueString,'-') <> coalesce(older.valueString,'-')
   OR coalesce(toString(newer.validFrom),'-') <> coalesce(toString(older.validFrom),'-')
   OR older.validTo IS NOT NULL OR newer.validTo IS NULL
RETURN 'V-507b' AS check, newer.uid AS boundingAssertion, older.uid AS boundedAssertion;

// V-508: DEFINITE overlap of exclusive attachments in valid AND recorded time (precision-shrunk; nulls never definite).
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction,'-') = coalesce(t2.jurisdiction,'-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
  r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                 WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
  r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                 WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN 'V-508' AS check, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// V-509 (informational, review queue): POSSIBLE overlap among currently recorded exclusive episodes.
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction,'-') = coalesce(t2.jurisdiction,'-')
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
  AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
RETURN 'V-509 (informational)' AS check, s.uid AS subjectUid, t1.uid AS state1, t2.uid AS state2;

// V-109: a SUPERSEDED assertion has an incoming SUPERSEDES recorded no earlier than it.
MATCH (a:Assertion {status: 'SUPERSEDED'})
OPTIONAL MATCH (b:Assertion)-[:SUPERSEDES]->(a)
WITH a, collect(b) AS supersessors
WHERE size(supersessors) = 0 OR any(b IN supersessors WHERE b.recordedAt < a.recordedAt)
RETURN 'V-109' AS check, a.uid AS assertionUid;

// V-110 (recordedAt form): ACCEPTED/REJECTED/DISPUTED status is backed by a CAPTURE_FIDELITY Adjudication
// recorded no earlier than the assertion.
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED','REJECTED','DISPUTED']
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a)
WITH a, collect(j) AS js
WHERE size(js) = 0 OR any(j IN js WHERE j.recordedAt IS NULL OR j.recordedAt < a.recordedAt)
RETURN 'V-110' AS check, a.uid AS assertionUid, a.status AS status, size(js) AS captureFidelityAdjudications;

// V-123 (INV-406): status never mirrors a truth verdict.
MATCH (a:Assertion)
WHERE a.status IN ['REJECTED','DISPUTED']
  AND EXISTS { MATCH (:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a) }
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
RETURN 'V-123' AS check, a.uid AS assertionUid;

// V-111: locators behind ACCEPTED assertions resolve to a reproducible snapshot.
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(loc:SourceLocator)
OPTIONAL MATCH (snap:SourceSnapshot)-[:HAS_LOCATOR]->(loc)
WITH a, loc, collect(snap) AS snaps
WHERE size(snaps) = 0 OR any(s IN snaps WHERE s.contentHash IS NULL OR s.retrievedAt IS NULL)
RETURN 'V-111' AS check, a.uid AS assertionUid, loc.uid AS locatorUid;

// V-401: an ACCEPTED assertion has at least one reproducible locator (selector fields complete for its kind).
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT EXISTS {
  MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
  WHERE s.contentHash IS NOT NULL AND s.retrievedAt IS NOT NULL
    AND (l.normalizationVersion IS NOT NULL OR l.selectorKind IN ['SECTION','WHOLE_SNAPSHOT'])
    AND ((l.selectorKind = 'TEXT_QUOTE' AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'MEDIA_TIME' AND l.mediaStartSeconds IS NOT NULL AND l.mediaEndSeconds IS NOT NULL AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'TEXT_POSITION' AND l.startOffset IS NOT NULL AND l.endOffset IS NOT NULL AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL
          AND EXISTS { MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(:DocumentTextVersion) })
      OR (l.selectorKind = 'PDF_PAGE' AND l.page IS NOT NULL AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'IMAGE_REGION' AND l.mediaAnnotationUid IS NOT NULL
          AND EXISTS { MATCH (l)-[:LOCATES_REGION]->(m:MediaAnnotation) WHERE m.uid = l.mediaAnnotationUid })
      OR (l.selectorKind = 'SECTION' AND l.section IS NOT NULL)
      OR (l.selectorKind = 'WHOLE_SNAPSHOT'))
}
RETURN 'V-401' AS check, a.uid AS assertionWithoutReproducibleLocator;

// V-402: every SourceLocator hangs from exactly one SourceSnapshot.
MATCH (l:SourceLocator)
OPTIONAL MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l)
WITH l, count(s) AS snapshots
WHERE snapshots <> 1
RETURN 'V-402' AS check, l.uid AS locatorUid, snapshots;

// V-403: offsets need the text version they count in.
MATCH (l:SourceLocator)
WHERE (l.startOffset IS NOT NULL OR l.endOffset IS NOT NULL)
  AND NOT EXISTS { MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(:DocumentTextVersion) }
RETURN 'V-403' AS check, l.uid AS offsetLocatorWithoutTextVersion;

// V-W00-03 (CL-011 / D-010): an IMAGE_REGION locator has mediaAnnotationUid AND exactly one LOCATES_REGION edge to the
// MediaAnnotation with that uid; no other selector kind carries LOCATES_REGION.
MATCH (l:SourceLocator)
OPTIONAL MATCH (l)-[:LOCATES_REGION]->(m)
WITH l, collect(m) AS ms
WHERE (l.selectorKind = 'IMAGE_REGION' AND (l.mediaAnnotationUid IS NULL OR size(ms) <> 1 OR ms[0].uid <> l.mediaAnnotationUid OR NOT ms[0]:MediaAnnotation))
   OR (coalesce(l.selectorKind, '-') <> 'IMAGE_REGION' AND size(ms) > 0)
RETURN 'V-W00-03' AS check, l.uid AS locatorUid, l.selectorKind AS selectorKind, size(ms) AS regionEdges;

// V-409: REANCHORS links locators on two snapshots of the same Source, newer to older.
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR sNew.retrievedAt <= sOld.retrievedAt
RETURN 'V-409' AS check, newL.uid AS newLocator, oldL.uid AS oldLocator;

// V-511: adjudications have recordedAt and cite only snapshots retrieved before they were recorded.
MATCH (adj:Adjudication)
WHERE adj.recordedAt IS NULL
RETURN 'V-511' AS check, 'ADJUDICATION_WITHOUT_RECORDED_AT' AS violation, adj.uid AS item
UNION
MATCH (adj:Adjudication)-[:SUPPORTED_BY|CONTRADICTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE sn.retrievedAt > adj.recordedAt
RETURN 'V-511' AS check, 'ADJUDICATION_CITES_LATER_SNAPSHOT' AS violation, adj.uid AS item;

// V-512: source revision events are well formed.
MATCH (ev:SourceRevisionEvent)
OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
WITH ev, collect(src) AS sources
WHERE size(sources) <> 1
RETURN 'V-512' AS check, 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
UNION
MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
RETURN 'V-512' AS check, 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
UNION
MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
WHERE res.retrievedAt <= prior.retrievedAt
RETURN 'V-512' AS check, 'REVISION_ORDER' AS violation, ev.uid AS item;

// V-112: derived and forbidden-implication edges cite live, matching assertions (catalog V-112 with params inlined;
// the hypothesisUid clause reads derivedFromAssessmentUids, see W00-SR-06).
MATCH (x)-[r]->(y)
WHERE type(r) IN ['SELLS_PRODUCT','CONTAINS','INSTANCE_OF'] OR type(r) IN ['ENDORSES_PRODUCT','SELLS_PRODUCT']
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid,
     [['ADVISES_ORGANIZATION','ENDORSES_PRODUCT'],['SPONSORS_CONTENT','ENDORSES_PRODUCT'],['LISTS_OFFER','SELLS_PRODUCT'],
      ['HOSTS_LISTING','SELLS_PRODUCT'],['FULFILLS_OFFER','SELLS_PRODUCT'],['AFFILIATE_FOR_OFFER','SELLS_PRODUCT']] AS pairs
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, citedUid, cited, pairs,
  [v IN [
    CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
    CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
    CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
    CASE WHEN cited IS NOT NULL AND any(p IN pairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
    CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) = 0
              AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AND NOT type(r) IN ['INSTANCE_OF'] THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
    CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
         THEN 'LICENSING_ASSESSMENT_MISSING' END,
    CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
           MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
             AND any(p IN pairs WHERE p[1] = type(r) AND p[0] = inp.predicate) } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
    CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
           size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }]) THEN 'DERIVATION_INPUT_MISSING' END
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-112' AS check, type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;

// V-117: uid format and uid-to-live-id seam (uid ends with ':' + id).
MATCH (n)
WHERE n.uid IS NOT NULL
WITH n, coalesce(n.id, n.documentId, n.documentTextVersionId, n.segmentationId, n.chunkId) AS liveId
WHERE NOT n.uid =~ 'hu:[a-z][a-z0-9-]*:[A-Za-z0-9][A-Za-z0-9._~-]*'
   OR (liveId IS NOT NULL AND NOT n.uid ENDS WITH (':' + liveId))
RETURN 'V-117' AS check, n.uid AS uid, liveId;

// V-W00-04 (informational): identifier values shared across issuers within a scheme. Rows are review items, never
// merges ([SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY]); an Identifier without issuer is a violation.
MATCH (i:Identifier)
WHERE i.issuer IS NULL OR i.scheme IS NULL OR i.value IS NULL
RETURN 'V-W00-04' AS check, 'IDENTIFIER_WITHOUT_SCHEME_ISSUER_VALUE' AS violation, i.uid AS item
UNION
MATCH (i1:Identifier), (i2:Identifier)
WHERE i1.scheme = i2.scheme AND i1.value = i2.value AND i1.issuer < i2.issuer
RETURN 'V-W00-04 (informational)' AS check, 'SAME_SCHEME_VALUE_DIFFERENT_ISSUER' AS violation, i1.uid + ' | ' + i2.uid AS item;

// V-W00-05 (corrects V-432, which names COMPARES instead of the catalog COMPARES_IDENTITIES): an EquivalenceAssessment
// compares exactly two distinct nodes, names its kind and method.
MATCH (e:EquivalenceAssessment)
OPTIONAL MATCH (e)-[:COMPARES_IDENTITIES]->(n)
WITH e, collect(DISTINCT n) AS ns
WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
RETURN 'V-W00-05' AS check, e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount;

// V-W00-06 (INV-504 immutability proxy): immutable record types are never updated after creation; assertions and
// assessments only for the one recordedTo write (or the status projection).
MATCH (n)
WHERE (n:SourceSnapshot OR n:SourceLocator OR n:SourceRevisionEvent OR n:Mention)
  AND n.updatedAt IS NOT NULL AND n.createdAt IS NOT NULL AND n.updatedAt > n.createdAt
RETURN 'V-W00-06' AS check, labels(n) AS labels, n.uid AS item
UNION
MATCH (n)
WHERE (n:Assertion OR n:EvidenceAssessment) AND n.updatedAt IS NOT NULL AND n.createdAt IS NOT NULL AND n.updatedAt > n.createdAt
  AND n.recordedTo IS NULL AND NOT n.status IN ['SUPERSEDED','REJECTED','DISPUTED','UNRESOLVED','WITHDRAWN']
RETURN 'V-W00-06' AS check, labels(n) AS labels, n.uid AS item;

// V-W00-07 (catalog baseArchetypes.Assertion rule): CALCULATED needs derivationRule and at least one
// DERIVED_FROM_ASSERTION input; MECHANISM needs basisKind.
MATCH (a:Assertion)
WHERE (a.basisKind = 'CALCULATED' AND (a.derivationRule IS NULL OR NOT EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION]->(:Assertion) }))
   OR (a.predicateClass = 'MECHANISM' AND a.basisKind IS NULL)
RETURN 'V-W00-07' AS check, a.uid AS assertionUid;

// V-W00-08 (GraphQL readability of Cypher-ingested kernel records): non-null GraphQL fields must exist in storage.
MATCH (n)
WHERE (n:Source OR n:SourceSnapshot OR n:SourceLocator OR n:SourceRevisionEvent OR n:Assertion OR n:Adjudication
       OR n:ResolutionHypothesis OR n:EquivalenceAssessment OR n:Agent OR n:Activity OR n:Identifier OR n:Mention)
WITH n, [k IN ['id','uid','createdAt','updatedAt'] WHERE n[k] IS NULL] +
     CASE WHEN n:Entity AND n.entityType IS NULL THEN ['entityType'] ELSE [] END +
     CASE WHEN n:InformationArtifact AND n.artifactType IS NULL THEN ['artifactType'] ELSE [] END +
     CASE WHEN n:Occurrence AND n.occurrenceType IS NULL THEN ['occurrenceType'] ELSE [] END +
     CASE WHEN n:EvidenceAssessment AND (n.assessmentType IS NULL OR n.methodVersion IS NULL OR n.status IS NULL OR n.recordedAt IS NULL)
          THEN ['assessmentType|methodVersion|status|recordedAt'] ELSE [] END +
     CASE WHEN n:Assertion AND (n.predicate IS NULL OR n.status IS NULL OR n.recordedAt IS NULL) THEN ['predicate|status|recordedAt'] ELSE [] END +
     CASE WHEN n:SourceSnapshot AND n.retrievedAt IS NULL THEN ['retrievedAt'] ELSE [] END +
     CASE WHEN n:Source AND n.canonicalUri IS NULL THEN ['canonicalUri'] ELSE [] END AS missing
WHERE size(missing) > 0
RETURN 'V-W00-08' AS check, labels(n) AS labels, n.uid AS item, missing;

// V-W00-09 (enum spelling; GraphQL enums reject other spellings at read time): stored enum values are the
// contract's SCREAMING_SNAKE values.
MATCH (n)
WHERE (n.privacyClass IS NOT NULL AND NOT n.privacyClass IN ['PUBLIC','INTERNAL'])
   OR (n:Assertion AND NOT n.status IN ['EXTRACTED','PROPOSED','ACCEPTED','REJECTED','DISPUTED','SUPERSEDED','UNRESOLVED'])
   OR (n:EvidenceAssessment AND NOT n.status IN ['PROPOSED','ACCEPTED','SUPERSEDED','WITHDRAWN'])
   OR (n:Assertion AND n.quantityBasis IS NOT NULL AND NOT n.quantityBasis IN ['PER_DAY','PER_DOSE','PER_SERVING','PER_KG_BODY_WEIGHT_PER_DAY','SINGLE_DOSE'])
RETURN 'V-W00-09' AS check, labels(n) AS labels, n.uid AS item, n.privacyClass AS privacyClass, n.status AS status, n.quantityBasis AS quantityBasis;

// V-W00-10 (V-429, provenance state 5): an answer-composition activity that used a locator or assertion names the
// policy version that authorized the use.
MATCH (act:Activity {activityKind: 'ANSWER_COMPOSITION'})-[:USED]->(x)
WHERE (x:SourceLocator OR x:Assertion)
  AND NOT EXISTS { MATCH (act)-[u:AUTHORIZED_BY]->(:PolicyVersion) WHERE u.useKind IS NOT NULL }
RETURN 'V-W00-10' AS check, act.uid AS unauthorizedUse, x.uid AS usedUid;

// V-W00-12 (V-428): an extraction confidence names the Activity that produced it.
MATCH (a:Assertion)
WHERE a.extractionConfidence IS NOT NULL AND NOT EXISTS { MATCH (a)-[:WAS_GENERATED_BY]->(:Activity) }
RETURN 'V-W00-12' AS check, a.uid AS confidenceWithoutActivity;
