// Kernel queries for the three competency questions no domain packet claimed (coverage report 01, Fable Wave 5).
// Parameters: $personUid, $sourceUid. All read-only; EXPLAIN-checked at Wave 6 against the final operations.
// Statement separators are ';' on their own line; no variable is shared across statements.

// CQ-AX-10 (Expansion, Q): stale adjudication queue.
// An Adjudication is stale when a newer snapshot of a source it cites changed the located span's content
// (locator quoteHash absent from the newer snapshot's locators) or carries a different contentHash. A newer
// snapshot whose locators still match the cited quoteHash does NOT re-open review (the CQ's qualification).
MATCH (adj:Adjudication)-[:SUPPORTED_BY]->(loc:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
MATCH (src)-[:HAS_SNAPSHOT]->(newer:SourceSnapshot)
WHERE newer.retrievedAt > snap.retrievedAt
  AND newer.retrievedAt > coalesce(adj.reviewedAt, adj.recordedAt)
  AND newer.contentHash <> snap.contentHash
  AND NOT EXISTS {
    MATCH (newer)-[:HAS_LOCATOR]->(l2:SourceLocator)
    WHERE l2.quoteHash IS NOT NULL AND l2.quoteHash = loc.quoteHash
  }
RETURN adj.uid AS adjudicationUid, adj.status AS status, adj.reviewedAt AS reviewedAt,
       src.uid AS sourceUid, snap.retrievedAt AS citedSnapshotAt, newer.retrievedAt AS newerSnapshotAt,
       loc.uid AS citedLocatorUid
ORDER BY newerSnapshotAt DESC;

// CQ-AX-26 (Foundational, A): what a named speaker actually said, in context (pointer to CQ-CL-01/02).
// Every ClaimOccurrence ASSERTED_BY the person, with its speech act, container, segment, located span and whether it
// retells someone else's statement (a sponsor read or a quoted study is a RETELLS occurrence, never the speaker's view).
MATCH (p:Person {uid: $personUid})<-[:ASSERTED_BY]-(occ:ClaimOccurrence)
OPTIONAL MATCH (occ)-[:OCCURS_IN]->(container)
OPTIONAL MATCH (occ)-[:OCCURS_IN_SEGMENT]->(seg:EpisodeSegment)
OPTIONAL MATCH (occ)-[:SUPPORTED_BY]->(loc:SourceLocator)<-[:HAS_LOCATOR]-(snap:SourceSnapshot)
OPTIONAL MATCH (occ)-[:RETELLS]->(orig:Assertion)-[:ASSERTED_BY]->(origSpeaker)
OPTIONAL MATCH (occ)-[:HAS_SUBJECT]->(subj)
RETURN occ.uid AS occurrenceUid, occ.speechAct AS speechAct, occ.polarity AS polarity, occ.statementText AS statement,
       labels(container)[0] AS containerKind, container.uid AS containerUid, seg.uid AS segmentUid,
       loc.exact AS quotedSpan, loc.mediaStartSeconds AS startSeconds, loc.quoteHash AS quoteHash, snap.retrievedAt AS snapshotAt,
       orig.uid AS retoldAssertionUid, origSpeaker.uid AS retoldSpeakerUid,
       collect(DISTINCT subj.uid) AS subjectUids
ORDER BY containerUid, startSeconds;

// CQ-AX-27 (Expansion, Q): which papers did this person write (same person, not same name).
// Authorship reaches a Publication through a Document rendition's byline (AUTHORED_BY), joined on the Person node
// or on an ORCID Identifier the Person HAS_IDENTIFIER; name-only matches are returned separately as candidate
// Mentions awaiting a ResolutionHypothesis (status shown), never merged into the answer.
MATCH (p:Person {uid: $personUid})
OPTIONAL MATCH (p)-[:HAS_IDENTIFIER]->(orcid:Identifier {scheme: "ORCID"})
WITH p, collect(DISTINCT orcid.value) AS orcids
CALL {
  WITH p, orcids
  MATCH (doc:Document)-[:AUTHORED_BY]->(author)
  WHERE author = p OR EXISTS { MATCH (author)-[:HAS_IDENTIFIER]->(i:Identifier {scheme: "ORCID"}) WHERE i.value IN orcids }
  OPTIONAL MATCH (doc)<-[:HAS_LOCATOR|HAS_SNAPSHOT*0..2]-(:Source)-[:RENDITION_OF]->(pub:Publication)
  RETURN "RESOLVED" AS tier, doc.uid AS documentUid, pub.uid AS publicationUid, null AS hypothesisStatus
  UNION
  WITH p
  MATCH (m:Mention)<-[:RESOLVES_MENTION]-(h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(p)
  OPTIONAL MATCH (m)<-[:HAS_MENTION|MENTIONS*1..2]-(doc:Document)
  RETURN "HYPOTHESIS" AS tier, doc.uid AS documentUid, null AS publicationUid, h.status AS hypothesisStatus
}
RETURN tier, documentUid, publicationUid, hypothesisStatus
ORDER BY tier, documentUid;
