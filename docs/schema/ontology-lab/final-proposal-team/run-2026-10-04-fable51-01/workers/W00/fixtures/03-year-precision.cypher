// W00 fixture 03 — year-precision bounds queried inside the year (CQ-TM-01 "possibly", CQ-TM-04).
// Source: INHERITED_REPO_CITATION of round 0006 SRC-SINCLAIR-AFFILIATIONS (https://sinclair.hms.harvard.edu/david-sinclairs-affiliations,
// observed 2026-10-03 via Tavily extract, PARTIAL_EXCERPT). Quote as recorded in round 0006:
//   "InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)"; legend "B=Board of Directors; A=Advisor/Consultant".
// W00 did NOT re-fetch the page; the snapshot hash is therefore SYNTHETIC_FIXTURE (sha256 over the snapshot uid).
// Encoding under the frozen rule (a bound is the first UTC instant of its precision period):
//   board 2011-2017 -> validFrom 2011-01-01 YEAR STATED, validTo 2017-01-01 YEAR STATED (ended at an instant in 2017,
//   end bound inside [2017-01-01, 2018-01-01]); advisor 2011-present -> validFrom 2011-01-01 YEAR STATED, validTo null UNKNOWN
//   ("present" on a page observed 2026-10-03 says nothing about after that date).
// The page's group-versus-member scope and the brand/legal-entity split stay as round 0006 left them (W01 owns roles).

MERGE (n:Person:Entity {uid: 'hu:person:w00-david-a-sinclair'})
ON CREATE SET n.id = 'w00-david-a-sinclair', n.entityType = 'Person', n.name = 'David A. Sinclair', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-10-03T12:00:00Z'), n.updatedAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Organization:Entity {uid: 'hu:org:w00-segterra'})
ON CREATE SET n.id = 'w00-segterra', n.entityType = 'Organization', n.name = 'Segterra (InsideTracker)', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-10-03T12:00:00Z'), n.updatedAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Activity:Occurrence {uid: 'hu:activity:w00-sinclair-extraction'})
ON CREATE SET n.id = 'w00-sinclair-extraction', n.occurrenceType = 'Activity', n.activityKind = 'EXTRACTION', n.methodVersion = 'w00-manual-curation-v1',
  n.privacyClass = 'INTERNAL', n.createdAt = datetime('2026-10-03T12:00:00Z'), n.updatedAt = datetime('2026-10-03T12:00:00Z');

MERGE (n:Source:Entity {uid: 'hu:source:w00-sinclair-lab-affiliations'})
ON CREATE SET n.id = 'w00-sinclair-lab-affiliations', n.entityType = 'Source', n.canonicalUri = 'https://sinclair.hms.harvard.edu/david-sinclairs-affiliations',
  n.title = 'David A. Sinclair’s Affiliations | The Sinclair Lab', n.sourceKind = 'SELF_DISCLOSURE_PAGE', n.privacyClass = 'PUBLIC',
  n.createdAt = datetime('2026-10-03T12:00:00Z'), n.updatedAt = datetime('2026-10-03T12:00:00Z');

MATCH (src:Source {uid: 'hu:source:w00-sinclair-lab-affiliations'})
MERGE (s:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:w00-sinclair-affiliations-2026-10-03'})
ON CREATE SET s.id = 'w00-sinclair-affiliations-2026-10-03', s.artifactType = 'SourceSnapshot', s.canonicalUri = src.canonicalUri,
  s.retrievedAt = datetime('2026-10-03T00:00:00Z'), s.observedAt = datetime('2026-10-03T00:00:00Z'),
  s.contentHash = 'sha256:263ffdf9b792867a5c0d79701755656ee5a857258c9a7130d0837a2c76f3beb0', s.contentHashBasis = 'SYNTHETIC_FIXTURE',
  s.captureCompleteness = 'PARTIAL_EXCERPT', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-03T12:00:00Z'), s.updatedAt = datetime('2026-10-03T12:00:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(s);

MATCH (s:SourceSnapshot {uid: 'hu:snapshot:w00-sinclair-affiliations-2026-10-03'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:w00-sinclair-insidetracker-row'})
ON CREATE SET l.id = 'w00-sinclair-insidetracker-row', l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
  l.exact = 'InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)',
  l.quoteHash = 'sha256:1994dc81bbae7b429ed8275104570117247c25516901dff418f3deb679102ecd', l.normalizationVersion = 'NFC-WS1',
  l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-03T12:00:00Z'), l.updatedAt = datetime('2026-10-03T12:00:00Z')
MERGE (s)-[:HAS_LOCATOR]->(l);

UNWIND [
  {uid: 'hu:assertion:w00-sinclair-board-segterra', id: 'w00-sinclair-board-segterra', pred: 'BOARD_MEMBER_OF', code: 'B',
   vt: datetime('2017-01-01T00:00:00Z'), vtp: 'YEAR', vtb: 'STATED_BY_SOURCE'},
  {uid: 'hu:assertion:w00-sinclair-advises-segterra', id: 'w00-sinclair-advises-segterra', pred: 'ADVISES_ORGANIZATION', code: 'A',
   vt: null, vtp: null, vtb: 'UNKNOWN'}
] AS row
MATCH (p:Person {uid: 'hu:person:w00-david-a-sinclair'}), (o:Organization {uid: 'hu:org:w00-segterra'}),
      (l:SourceLocator {uid: 'hu:locator:w00-sinclair-insidetracker-row'}), (act:Activity {uid: 'hu:activity:w00-sinclair-extraction'})
MERGE (a:Assertion {uid: row.uid})
ON CREATE SET a.id = row.id, a.predicate = row.pred, a.predicateClass = 'ROLE', a.polarity = 'POSITIVE', a.status = 'ACCEPTED',
  a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED', a.roleCodeVerbatim = row.code,
  a.validFrom = datetime('2011-01-01T00:00:00Z'), a.validFromPrecision = 'YEAR', a.validFromBasis = 'STATED_BY_SOURCE',
  a.validTo = row.vt, a.validToPrecision = row.vtp, a.validToBasis = row.vtb,
  a.recordedAt = datetime('2026-10-03T12:00:00Z'), a.contentHash = 'sha256:synthetic-content-' + row.id, a.extractionConfidence = 0.95,
  a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-03T12:00:00Z'), a.updatedAt = datetime('2026-10-03T12:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:WAS_GENERATED_BY]->(act);

UNWIND ['hu:assertion:w00-sinclair-board-segterra', 'hu:assertion:w00-sinclair-advises-segterra'] AS au
MATCH (a:Assertion {uid: au}), (l:SourceLocator {uid: 'hu:locator:w00-sinclair-insidetracker-row'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:' + a.id + '-cf'})
ON CREATE SET j.id = a.id + '-cf', j.assessmentType = 'Adjudication', j.methodVersion = 'w00-manual-capture-review-v1', j.status = 'ACCEPTED',
  j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'HUMAN', j.reviewedAt = datetime('2026-10-03T12:30:00Z'),
  j.recordedAt = datetime('2026-10-03T12:30:00Z'), j.privacyClass = 'INTERNAL', j.createdAt = datetime('2026-10-03T12:30:00Z'), j.updatedAt = datetime('2026-10-03T12:30:00Z')
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// Asserted edges (AssertedEdgeProperties; W01 owns the role relationship types and RoleEdgeProperties).
MATCH (p:Person {uid: 'hu:person:w00-david-a-sinclair'}), (o:Organization {uid: 'hu:org:w00-segterra'}), (a:Assertion {uid: 'hu:assertion:w00-sinclair-board-segterra'})
MERGE (p)-[r:BOARD_MEMBER_OF {relationshipUid: 'hu:rel:w00-sinclair-board-segterra'}]->(o)
ON CREATE SET r.assertionUid = a.uid, r.validFrom = a.validFrom, r.validFromPrecision = a.validFromPrecision, r.validFromBasis = a.validFromBasis,
  r.validTo = a.validTo, r.validToPrecision = a.validToPrecision, r.validToBasis = a.validToBasis, r.recordedFrom = a.recordedAt;

MATCH (p:Person {uid: 'hu:person:w00-david-a-sinclair'}), (o:Organization {uid: 'hu:org:w00-segterra'}), (a:Assertion {uid: 'hu:assertion:w00-sinclair-advises-segterra'})
MERGE (p)-[r:ADVISES_ORGANIZATION {relationshipUid: 'hu:rel:w00-sinclair-advises-segterra'}]->(o)
ON CREATE SET r.assertionUid = a.uid, r.validFrom = a.validFrom, r.validFromPrecision = a.validFromPrecision, r.validFromBasis = a.validFromBasis,
  r.validToBasis = a.validToBasis, r.recordedFrom = a.recordedAt;
