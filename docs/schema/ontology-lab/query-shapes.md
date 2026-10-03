# Canonical Query Shapes

Status: provisional (accepted into catalog 0.2.0 by the integration owner on 2026-10-03; every query is statically checked or illustrative, none executed)
Target: Neo4j 5 property graph, catalog `0.2.0` labels and relationship types (`../catalog/schema.yaml`)

These are the Cypher shapes every answer must be expressible in. They are the formal side of the competency questions: Grüninger and Fox treat competency questions as tests of a model's commitments, not as sources of commitments, and ask that informal questions be restated in the model's own terms ([SRC-GRUNINGER-FOX-1995]). A question marked Essential or Foundational in `competency-questions.md` is only accepted if it binds to one of these shapes (the binding table is at the end).

## How to read the status tags

- `// status: statically-checked` means the statement was parsed with the official Neo4j Cypher language-support linter (`@neo4j-cypher/language-support` 2.0.0-next.6, `lintCypherQuery`, no schema supplied) with zero errors, and the author read it against catalog labels, relationship types and property names, and against the rule that each statement binds all of its own variables. The linter checks syntax and schema-free semantics. It does not check that a label exists, that a property is populated, or that a plan is efficient.
- `// status: illustrative` means the shape depends on a parameter list or catalog decision that has not been merged.
- No query here was executed. There was no Neo4j instance. The one worked example below was derived by hand.

## Conventions shared by all shapes

| Name | Meaning |
|---|---|
| `$recordedAsOf` (R) | Recorded-time viewpoint: what the system believed on R. |
| `$validAt` (V) | Valid-time viewpoint: what was true in the modeled world at V. For an interval, `$intervalStart` and `$intervalEnd`, half-open. |
| `recordedAt` | Single instant on an `Assertion`: when BellLabs committed it. |
| `recordedFrom`, `recordedTo` | System-time episode on a state attachment or asserted edge. `recordedTo` null means currently believed. |
| `validFrom`, `validTo` | Domain time on assertions, states and asserted edges. Null means unknown, and an open end is also null, so the shapes never read a null end as "still true" (see below). |
| `PrivateScope` | Marker label on every node of the private user partition (requested of Lane 5). |

Bounds are half-open: an interval contains V when `validFrom <= V < validTo`. A null `validFrom` is unknown, not "since the beginning".

### Validity classes returned by the as-of shapes

Dropping a row because a bound is null would turn unknown into false, and keeping it silently would turn unknown into true. The shapes keep the row and name the case.

| Class | Condition | Reading |
|---|---|---|
| `EXCLUDED` | A known bound excludes V. | Removed from the result. |
| `KNOWN_WITHIN` | Both bounds known and contain V. | Valid at V as recorded. |
| `UNKNOWN_START` | `validFrom` null, `validTo` known and after V. | Possibly valid at V. |
| `UNKNOWN_BOTH_BOUNDS` | Both null. | Valid time not established. |
| `OPEN_END_SUPPORTED` | `validTo` null, and a snapshot supporting the assertion, retrieved by R, was observed at or after V. | Last confirmed at or after V. |
| `OPEN_END_STALE` | `validTo` null and no such snapshot. | Open end is unverified. Report "last confirmed on `lastObservedAt`", not "current". |

The `OPEN_END_*` split exists because a source observed on 2026-07-10 shows a fact at that date. It does not show that the fact began then, and it does not show that the fact still holds later. A snapshot's `observedAt` is a confirmation instant (pair 6 in `competency-questions.md`). Its `retrievedAt` is a recorded-time instant, which is why R filters on it.

The distinction between the two clocks follows the temporal-database literature: valid time is when a fact holds in the world, transaction (system) time is when the database held it, and a bitemporal slice constrains both ([SRC-SNODGRASS-TDB-BOOK], [SRC-XTDB-TIME]). SQL:2011 names them application time and system time ([SRC-POSTGRES-SQL2011-WIKI]).

---

## QS-1 Assertion to source locator to adjudication trace

Serves: CQ-EV-01, CQ-EV-02, CQ-ID-03, CQ-ID-04, CQ-EV-03, CQ-EV-05, CQ-AX-01, CQ-AX-07, CQ-AX-09, CQ-AX-26.

Every sentence in an answer cites assertion uids. QS-1a returns for each one: the proposition, who asserted it, the exact locator and the snapshot it lives in, the adjudications reviewed by R, and a list of named trace gaps. It reports gaps instead of hiding them.

`status` on the assertion is a cache of the latest state, so the shape returns it as `currentStatus` and derives the as-of state from adjudications reviewed by R.

```cypher
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
       a.validFrom AS validFrom, a.validTo AS validTo, a.validTimeBasis AS validTimeBasis,
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
```

### QS-1b over the live evidence pipeline

The live schema has no adjudication surface, so the trace ends with an explicit `NO_ADJUDICATION_SURFACE`. The locator-equivalent is the `Chunk` plus the `quoteSpan` on the `SUPPORTED_BY` relationship plus `textVersionHash` of the `DocumentTextVersion`. Note the stored names: GraphQL `Document.id` is the stored property `documentId` (the schema uses `@alias`), `Document.name` is `title`, `Chunk.id` is `chunkId`, `Chunk.chunkIndex` is `index`. A Cypher query written against GraphQL field names silently returns nulls ([SRC-NEO4J-GQL-DBMAPPING]). The live `Claim.evidenceStrength` is returned as an attribute label only, because it is an assessment stored as a node attribute (CQ-AX-24).

```cypher
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
```

Failing cases this shape prevents: a paraphrase returned without a span; a `DISPUTED` assertion presented without its contradicting locator; an `ACCEPTED` status with no adjudication behind it; a locator whose snapshot has no content hash and so cannot be reproduced.

---

## QS-2 Bitemporal as-of retrieval

Serves: CQ-TM-01 to CQ-TM-05, CQ-ID-02, CQ-ID-05, CQ-EV-05, CQ-RC-04, CQ-AX-03, CQ-AX-06.

"What was recorded as believed on R about what was true on V." The shape is a bitemporal time slice: one condition on the recorded interval and one on the valid interval ([SRC-SNODGRASS-TDB-BOOK] figure 10.18; XTDB's `FOR VALID_TIME AS OF` plus `FOR SYSTEM_TIME AS OF`, [SRC-XTDB-TIME]).

Three modeling facts the shape depends on, each forced by a source:

1. Valid time must be stored explicitly. Datomic's `as-of` filters on transaction time only, and a retroactive fact has to carry its own domain-time attribute ([SRC-DATOMIC-FILTERS]). The catalog's `validFrom` and `validTo` are that attribute.
2. A correction closes the old recorded episode and opens a new one. It does not rewrite valid time on the old row. XTDB's bitemporal resolution shows the same row-splitting: the old row's system-time is closed and a new row carries the corrected valid time ([SRC-XTDB-BITEMP-INDEX]). In the catalog this is `recordedTo` on the old edge and a new edge with a new `recordedFrom`.
3. `Assertion.status` is a mutable cache. As-of reads must come from `recordedAt`, a recorded `SUPERSEDES` relationship, and `Adjudication.reviewedAt`, because an overwritten `status` cannot answer "was it accepted on R".

### QS-2a Assertion-level

The supersession test is isolated in one `NOT EXISTS` block. Lane 5 round 0007 owns how supersession is encoded; if it chooses a different encoding, only this block changes.

```cypher
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
       a.validFrom AS validFrom, a.validTo AS validTo, a.validTimeBasis AS validTimeBasis,
       lastObservedAt,
       a.recordedAt AS recordedAt,
       latestVerdict, adjudicationUid
ORDER BY a.predicate, a.recordedAt;
```

### QS-2b Edge-level, point in time

Edges that were created through the live GraphQL layer before this proposal have no `recordedFrom`. They cannot answer an R-view. They are returned only when `$includeLegacy` is true and are labeled `LEGACY_UNDATED`, so they are never mistaken for facts the system recorded.

```cypher
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
       r.validFrom AS validFrom, r.validTo AS validTo, r.validTimeBasis AS validTimeBasis,
       r.recordedFrom AS recordedFrom, r.recordedTo AS recordedTo,
       CASE WHEN r.recordedFrom IS NULL THEN 'LEGACY_UNDATED' ELSE 'RECORDED' END AS recordedClass,
       lastObservedAt,
       a.uid AS authorizingAssertionUid
ORDER BY r.recordedFrom DESC, f.uid;
```

### QS-2b-interval Edge-level, valid-time interval

CQ-ID-02 asks which formulation applied during an administration window. A long window can overlap several versions, so the shape returns all of them with an overlap class.

```cypher
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
       r.validTimeBasis AS validTimeBasis, r.recordedFrom AS recordedFrom
ORDER BY r.validFrom;
```

### QS-2c What changed in belief between two recorded dates

```cypher
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
```

### Worked example (hand-derived, not executed)

Fixture. The variant has one formulation attached with a start of 2025-06-01 (recorded 2026-01-10). On 2026-06-20 a corrected label shows the start was 2025-09-01. The old edge's recorded episode closes and a new edge opens. On 2026-07-02 a late historical source adds an earlier formulation F0 valid 2024-01-01 to 2025-09-01.

```cypher
// QS-2 worked example fixture (synthetic; ids are illustrative, production uids are opaque)
// status: statically-checked
CREATE (v:Entity:ProductVariant {uid: 'hu:product-variant:demo-v1', name: 'Demo variant', createdAt: datetime('2026-01-10T00:00:00Z')})
CREATE (f0:VersionedState:FormulationVersion {uid: 'hu:formulation:demo-f0', versionName: 'Demo F0', createdAt: datetime('2026-07-02T00:00:00Z')})
CREATE (f1:VersionedState:FormulationVersion {uid: 'hu:formulation:demo-f1', versionName: 'Demo F1', createdAt: datetime('2026-01-10T00:00:00Z')})
CREATE (aOld:Assertion {uid: 'hu:assertion:demo-f1-attach-v1', predicate: 'HAS_FORMULATION_VERSION', status: 'SUPERSEDED', polarity: 'POSITIVE', recordedAt: datetime('2026-01-10T00:00:00Z'), validFrom: datetime('2025-06-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED'})
CREATE (aNew:Assertion {uid: 'hu:assertion:demo-f1-attach-v2', predicate: 'HAS_FORMULATION_VERSION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-06-20T00:00:00Z'), validFrom: datetime('2025-09-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED'})
CREATE (aF0:Assertion {uid: 'hu:assertion:demo-f0-attach', predicate: 'HAS_FORMULATION_VERSION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-07-02T00:00:00Z'), validFrom: datetime('2024-01-01T00:00:00Z'), validTo: datetime('2025-09-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED'})
CREATE (aNew)-[:SUPERSEDES]->(aOld)
CREATE (l1:InformationArtifact:SourceLocator {uid: 'hu:locator:demo-1', uri: 'https://example.org/label', section: 'Supplement Facts'})
CREATE (l2:InformationArtifact:SourceLocator {uid: 'hu:locator:demo-2', uri: 'https://example.org/label', section: 'Supplement Facts'})
CREATE (s1:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:demo-1', observedAt: datetime('2026-01-09T00:00:00Z'), retrievedAt: datetime('2026-01-10T00:00:00Z'), contentHash: 'sha256:demo1'})
CREATE (s2:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:demo-2', observedAt: datetime('2026-06-18T00:00:00Z'), retrievedAt: datetime('2026-06-20T00:00:00Z'), contentHash: 'sha256:demo2'})
CREATE (s1)-[:HAS_LOCATOR]->(l1)
CREATE (s2)-[:HAS_LOCATOR]->(l2)
CREATE (aOld)-[:SUPPORTED_BY]->(l1)
CREATE (aNew)-[:SUPPORTED_BY]->(l2)
CREATE (v)-[:HAS_FORMULATION_VERSION {assertionUid: 'hu:assertion:demo-f1-attach-v1', validFrom: datetime('2025-06-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED', recordedFrom: datetime('2026-01-10T00:00:00Z'), recordedTo: datetime('2026-06-20T00:00:00Z')}]->(f1)
CREATE (v)-[:HAS_FORMULATION_VERSION {assertionUid: 'hu:assertion:demo-f1-attach-v2', validFrom: datetime('2025-09-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED', recordedFrom: datetime('2026-06-20T00:00:00Z')}]->(f1)
CREATE (v)-[:HAS_FORMULATION_VERSION {assertionUid: 'hu:assertion:demo-f0-attach', validFrom: datetime('2024-01-01T00:00:00Z'), validTo: datetime('2025-09-01T00:00:00Z'), validTimeBasis: 'SOURCE_STATED', recordedFrom: datetime('2026-07-02T00:00:00Z')}]->(f0);
```

Expected results of QS-2b, derived by reading the fixture:

| R (recorded as of) | V (valid at) | Visible edges at R | Result | Why |
|---|---|---|---|---|
| 2026-03-01 | 2025-07-01 | e1 | F1, `OPEN_END_SUPPORTED`, validFrom 2025-06-01 | e1 is recorded and open; its snapshot (retrieved 2026-01-10, observed 2026-01-09) is at or after V. |
| 2026-08-01 | 2025-07-01 | e2, e3 | F0, `KNOWN_WITHIN` | e1 closed at 2026-06-20. e2 starts 2025-09-01, after V, so it is excluded. e3 covers V. |
| 2026-08-01 | 2026-01-01 | e2, e3 | F1, `OPEN_END_SUPPORTED`, validFrom 2025-09-01 | e3 ended 2025-09-01. e2's snapshot was observed 2026-06-18, after V. |
| 2026-03-01 | 2024-06-01 | e1 | no rows | The system knew nothing about V then. The empty result means not recorded, not "no formulation". Use QS-7 to say which. |
| 2026-08-01 | 2026-09-15 | e2, e3 | F1, `OPEN_END_STALE`, lastObservedAt 2026-06-18 | The open end is unverified. The answer is "last confirmed 2026-06-18". |

The first two rows are the same question asked on two recorded dates. They give different answers about the same valid time, which is CQ-TM-01. The late source in row 2 added past valid time without pretending the system knew it on 2026-03-01, which is CQ-TM-02.

---

## QS-3 Evidence applicability with the weakest dimension and missing facts

Serves: CQ-EV-04, CQ-RC-03, CQ-RC-02, CQ-ID-01, CQ-AX-02.

The shape never averages. It orders dimensions weakest first, and it reports separately which dimensions are unresolved. `NOT_ASSESSED` (null) is kept distinct from `UNKNOWN` (assessed, with facts missing). Ranking `MISMATCH` below `UNKNOWN` is a presentation choice: a known mismatch is a reason not to transfer evidence, an unknown is a reason to find out. The dimension list and value enum belong to Lane 2 (round 0002); the shape takes them as parameters and defaults unrecognized values to unresolved, so a new enum value cannot read as a match.

```cypher
// QS-3a  Evidence applicability: surface the weakest dimension and the unresolved ones
//        (never a single score; a score, if present, is returned separately with its method version)
// status: statically-checked
// params: $applicabilityUid string
//         $dimensions list<string>  e.g. ['identityMatch','doseMatch','routeMatch','scheduleMatch',
//                                         'durationMatch','populationMatch','outcomeMatch']
// Dimension values assumed (Lane 2 round 0002 owns the enum): MATCH | PARTIAL | MISMATCH | UNKNOWN.
// A null dimension means NOT_ASSESSED, which is different from UNKNOWN (assessed, facts insufficient).
MATCH (ea:EvidenceApplicability {uid: $applicabilityUid})
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(target)
OPTIONAL MATCH (ea)-[:BASED_ON_EVIDENCE]->(evidence)
WITH ea, collect(DISTINCT target.uid) AS targetUids, collect(DISTINCT evidence.uid) AS evidenceUids
UNWIND $dimensions AS dim
WITH ea, targetUids, evidenceUids, dim, ea[dim] AS dimValue
WITH ea, targetUids, evidenceUids, dim,
     CASE WHEN dimValue IS NULL THEN 'NOT_ASSESSED' ELSE dimValue END AS dimState,
     CASE
       WHEN dimValue = 'MISMATCH' THEN 0
       WHEN dimValue IS NULL OR dimValue = 'UNKNOWN' THEN 1
       WHEN dimValue = 'PARTIAL' THEN 2
       WHEN dimValue = 'MATCH' THEN 3
       ELSE 1
     END AS strength
ORDER BY strength ASC, dim ASC
WITH ea, targetUids, evidenceUids,
     collect({dimension: dim, state: dimState, strength: strength}) AS ranked
RETURN ea.uid AS applicabilityUid,
       ea.methodVersion AS methodVersion,
       ea.status AS assessmentStatus,
       targetUids, evidenceUids,
       [d IN ranked WHERE d.strength = ranked[0].strength] AS weakestDimensions,
       [d IN ranked WHERE d.state IN ['UNKNOWN', 'NOT_ASSESSED']] AS unresolvedDimensions,
       ranked AS allDimensionsWeakestFirst,
       ea.overallScore AS derivedScoreIfAny;
```

QS-3b lists the missing facts behind an unresolved dimension, as codes a person or agent can act on.

```cypher
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
```

---

## QS-4 Forbidden-implication and derived-edge guard

Serves: CQ-EV-02, CQ-AX-08, CQ-AX-16, CQ-AX-23, CQ-AX-25, CQ-RC-05.

A derived edge must cite its source, and an edge whose type is the conclusion of a forbidden implication must not be backed by the premise. The catalog already requires `projectionOfAssertionUid` or `derivationRule` (INV-004). Two failing cases show that is not sufficient:

- `Product -[:CONTAINS]-> IngredientMaterial` is derived through three hops (variant to formulation to component to material). One `projectionOfAssertionUid` cannot cite that chain, so a multi-hop derived edge needs `derivationRule` plus `derivedFromAssertionUids`. This is kernel-change request K-2.
- An `ENDORSES_PRODUCT` edge can carry a `projectionOfAssertionUid` that points at an `ADVISES_ORGANIZATION` assertion. The citation exists, so `V-007` passes, and the forbidden implication is still reintroduced. The guard compares the cited predicate with the edge type.

```cypher
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
```

QS-4b is the write-time precondition an agent's typed intent must pass before a derived or projected edge is written. It returns a refusal reason, not an exception.

```cypher
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
```

---

## QS-5 Purpose-bound projection request

Serves: CQ-AX-13, CQ-AX-16, CQ-AX-02, and every Essential question that an agent answers.

`ontology-lab/projection-contract.yaml` defines a request that selects a schema slice and binds it to intent, competency questions, modules, a temporal viewpoint, budgets and a source schema digest. Its result is a schema slice, not data. Two things follow from the contract and one from this lane:

1. The request's `temporalView.validAt`, `temporalView.recordedAt`, `intervalStart` and `intervalEnd` are exactly the `$validAt`, `$recordedAsOf`, `$intervalStart`, `$intervalEnd` of QS-2. The compiler passes them through; an agent never writes the temporal predicates.
2. `budgets.maxTraversalDepth` becomes a literal quantifier bound in compiled Cypher. The author did not verify whether Cypher accepts a parameter as a path-quantifier bound, so the compiler is specified to substitute a literal. `maxNodes` and `maxRelationships` are enforced by the service. A `LIMIT` on returned paths is a backstop, not an exact budget.
3. The contract has no field for audience or private context. This lane proposes three optional additive fields (K-3): `accessTier`, `privateContext`, `traceDepth`. When `accessTier` is not `OWNER_PRIVATE`, `requestedModules` must not include a private-owned module and `privateContext` must be `EXCLUDED`. That check is service-enforced.

### QS-5a Request (document shape, not Cypher)

```yaml
# status: illustrative  (request document; fields marked proposed are not yet in projection-contract.yaml)
requestId: req-ax-trail-0001
intent: >-
  Explain to a consumer whether evidence about a studied intervention transfers to the
  current label of a named product variant, with the weakest applicability dimension
  and the missing facts stated.
competencyQuestionIds: [CQ-ID-01, CQ-EV-04, CQ-RC-03, CQ-AX-01, CQ-AX-02]
requestedModules: [kernel, provenance, temporal, identity_resolution, products_and_formulations, studies_and_evidence]
requestedElements: [EvidenceApplicability, FormulationVersion, StudyIntervention]
excludedElements: [UserContext, RecommendationDecision, PrivateScope]
temporalView:
  validAt: "2026-07-10T00:00:00Z"
  recordedAt: "2026-10-03T00:00:00Z"
  intervalStart: null
  intervalEnd: null
  unknownTimePolicy: preserve_unknown
budgets: {maxNodes: 200, maxRelationships: 400, maxTraversalDepth: 3}
sourceSchemaDigest: "sha256:4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f"  # catalog/schema.yaml as read on 2026-10-03; changes when the coordinator merges
# proposed additive fields (K-3)
accessTier: PUBLIC_ANSWER        # PUBLIC_ANSWER | OPERATOR_AUDIT | AGENT_PROJECTION | OWNER_PRIVATE (Lane 5)
privateContext: EXCLUDED         # EXCLUDED | REFERENCED_BY_UID_ONLY | INCLUDED_FOR_OWNER
traceDepth: ADJUDICATION         # NONE | LOCATOR | ADJUDICATION
```

### QS-5b Data query emitted from the request

The module list becomes `$allowedLabels` and `$allowedRelTypes` through the catalog. The label expression `!PrivateScope` on every hop and the temporal predicates are applied by the compiler, never written by the agent.

```cypher
// QS-5b  Data query a compiler emits from a purpose-bound projection request (see QS-5a)
// status: statically-checked
// Compiler substitutions: the quantifier bound {1,3} is a literal copied from budgets.maxTraversalDepth.
// params: $rootUid, $allowedLabels list<string>, $allowedRelTypes list<string>,
//         $recordedAsOf (temporalView.recordedAt), $validAt (temporalView.validAt), $maxRelationships
MATCH (root {uid: $rootUid})
WHERE NOT root:PrivateScope
  AND any(l IN labels(root) WHERE l IN $allowedLabels)
MATCH p = (root)((a)-[r]->(b:!PrivateScope)
               WHERE type(r) IN $allowedRelTypes
                 AND any(l IN labels(b) WHERE l IN $allowedLabels)
                 AND (r.recordedFrom IS NULL
                      OR (r.recordedFrom <= $recordedAsOf AND (r.recordedTo IS NULL OR $recordedAsOf < r.recordedTo)))
                 AND (r.validFrom IS NULL OR r.validFrom <= $validAt)
                 AND (r.validTo IS NULL OR $validAt < r.validTo)){1,3}(leaf)
RETURN [n IN nodes(p) | n.uid] AS nodeUids,
       [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT $maxRelationships;
```

---

## QS-6 Public and private boundary

Serves: CQ-AX-02, CQ-AX-12, CQ-AX-13, CQ-AX-21, CQ-RC-05.

The rule: a shared-graph query must not traverse into private user context, and must not infer it from a path. Private records reference shared uids, so the dangerous direction is incoming. `UserContext -[:REFERENCES_PRODUCT_VARIANT]-> ProductVariant` is an incoming edge for the shared node. An undirected or incoming expansion from variant A through that private node reaches variant B, and the existence of the path says that one person is interested in both. Hiding the private node's properties does not hide the path.

If Lane 5 places private context in a separate database or graph, QS-6a is satisfied by connection routing and the label test remains as defence in depth. If it shares the database, the label test is the only guard. Placement is Lane 5's decision; the shapes work for either.

```cypher
// QS-6a  Shared-graph traversal that cannot enter private user context
// status: statically-checked
// PrivateScope is the marker label every private-partition node carries (requested of Lane 5, see property-cards.md).
// The label test sits on every hop, in both directions: an incoming private node
// (UserContext -[:ABOUT]-> Product) would otherwise act as a bridge between two shared nodes.
// params: $uid string, $privateRelTypes list<string> (defence in depth), $maxHops is a compiler-substituted literal (2 here)
MATCH (s {uid: $uid})
WHERE NOT s:PrivateScope
MATCH p = (s)(()-[r]-(n:!PrivateScope)){1,2}
WHERE none(rel IN relationships(p) WHERE type(rel) IN $privateRelTypes)
RETURN DISTINCT [x IN nodes(p) | x.uid] AS nodeUids, [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT 500;
```

Detectors for the invariants the traversal depends on (zero rows = valid):

```cypher
// QS-6b-1  Leak detector: a shared node must never point at a private node (zero rows = valid)
// status: statically-checked
MATCH (s)-[r]->(p:PrivateScope)
WHERE NOT s:PrivateScope
RETURN labels(s) AS sharedLabels, s.uid AS sharedUid, type(r) AS relType, p.uid AS privateUid;

// QS-6b-2  Private-to-shared references are allowed only as governed reference types (zero rows = valid)
// status: statically-checked
// params: $allowedReferenceTypes list<string> (Lane 5 owns the list, e.g. REFERENCES_PRODUCT_VARIANT)
MATCH (p:PrivateScope)-[r]->(s)
WHERE NOT s:PrivateScope AND NOT type(r) IN $allowedReferenceTypes
RETURN p.uid AS privateUid, type(r) AS relType, s.uid AS sharedUid;

// QS-6b-3  A private node must not carry a label that a shared fulltext or vector index covers (zero rows = valid)
// status: statically-checked
// params: $sharedIndexedLabels list<string>  (derive from SHOW INDEXES, see V-110)
MATCH (p:PrivateScope)
WHERE any(l IN labels(p) WHERE l IN $sharedIndexedLabels)
RETURN p.uid AS privateUid, labels(p) AS labels;
```

A fourth leak route is the search surface: a private node covered by a shared fulltext or vector index would surface in shared search results (V-115). Embeddings and `searchText` are derived text, and derived text can leak whatever it was derived from (V-116).

---

## QS-7 Unknown versus absent

Serves: CQ-AX-04, CQ-TM-04, INV-007.

A missing edge is not evidence of absence. This shape returns one of `ASSERTED_PRESENT`, `ASSERTED_ABSENT` (a negative-polarity assertion exists), `ASSERTED_UNKNOWN`, `CONFLICTING`, `NOT_DECLARED_IN_COVERING_SOURCE` (a label snapshot covers the subject and does not declare the object, which is still not a measured absence) and `NOT_RECORDED`. `Assertion.polarity` is in `starter-property-model.md` but not in `catalog/schema.yaml`; this shape needs it (property card P-7).

```cypher
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
```

---

## QS-8 Free text to candidate identities

Serves: CQ-AX-14, CQ-ID-04.

Names never establish identity. A fulltext or vector hit is a candidate. The shape returns the hit with the open `ResolutionHypothesis` records that propose it, and a lexical score labeled as such. The live `@fulltext` directive does not create the index: the Neo4j GraphQL library documents that the index must be created manually ([SRC-NEO4J-GQL-INDEXES]), and V-120 checks that the index exists on the stored property names. Scores differ between indexes and are never stored as `resolutionConfidence`.

```cypher
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
```

---

## Binding of Essential and Foundational questions to shapes

| Question | Shape and parameters |
|---|---|
| CQ-ID-01 | QS-2b (`HAS_FORMULATION_VERSION`) + QS-3a (`identityMatch`) + QS-1a on `USES_INTERVENTION_MATERIAL`, with `PROPOSES_MATCH` hypotheses |
| CQ-ID-02 | QS-2b-interval with the study's administration interval |
| CQ-ID-03 | QS-1a with `$predicates` = `DECLARATION_IDENTIFIES_MATERIAL`, `REALIZES_SUBSTANCE`, `PROVIDES_CONSTITUENT`, `QUANTITATIVELY_CONTAINS`; the result keeps the predicate so the four are never merged |
| CQ-ID-04 | QS-8, then QS-1a on the `Identifier` assertion; authority version is the `SourceSnapshot` of the authority record |
| CQ-ID-05 | QS-2b at two V values plus a component diff (derived, not stored) |
| CQ-EV-01, CQ-EV-02 | QS-1a; QS-4a for derived edges |
| CQ-EV-03 | QS-1a over assertions with `SUPPORTED_BY` and `CONTRADICTED_BY`, grouped by `Study.studyKind`; independence caveat is CQ-AX-05 |
| CQ-EV-04, CQ-RC-03 | QS-3a and QS-3b |
| CQ-EV-05 | QS-2a at R before and after the correction; QS-2c |
| CQ-TM-01, CQ-TM-02 | QS-2a, QS-2b, QS-2c |
| CQ-TM-03, CQ-TM-04 | QS-2a result columns and classes; V-104, V-105, V-107 |
| CQ-TM-05 | V-108 (service-enforced exclusivity) |
| CQ-RC-01, CQ-RC-02, CQ-RC-05 | QS-1a over the decision's explanation, QS-3a, QS-2b for price and availability observations, with the stance kind returned |
| CQ-RC-04 | QS-2 with the decision's stored R and V |
| CQ-RC-06 | QS-1a over constraint assertions; the safety module is candidate, so this binding is illustrative |
| CQ-AX-01 to CQ-AX-03 | QS-1a, QS-3a, QS-6a, QS-5 |
| CQ-AX-04 | QS-7 |
| CQ-AX-07 to CQ-AX-09 | QS-1a gaps, V-109 to V-111, QS-4a |
| CQ-AX-12, CQ-AX-13 | QS-6, QS-5 |
| CQ-AX-14 | QS-8 |
| CQ-AX-16 | QS-4b |

## Assumptions this document depends on

- Lane 5 round 0007 encodes supersession (QS-2a, QS-4b, QS-7 use `(:Assertion)-[:SUPERSEDES]->(:Assertion)`).
- Lane 5 round 0008 owns `PrivateScope` and the governed reference types.
- Lane 2 round 0002 owns the `EvidenceApplicability` dimension values.
- `Identifier` and `HAS_IDENTIFIER` are decided by the coordinator and are not yet in `catalog/schema.yaml`.
- Neo4j quantified path patterns (5.9 and later) and label expressions (`!Label`) are used. The author read them in the Neo4j Cypher manual ([SRC-NEO4J-CYPHER-QPP]) and did not run them.
