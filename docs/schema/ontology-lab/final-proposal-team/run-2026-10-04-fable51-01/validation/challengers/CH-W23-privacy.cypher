// CH-W23-privacy.cypher -- Wave 5 Challenger W23 (privacy/access), run-2026-10-04-fable51-01, 2026-10-04.
// Target: embedded Neo4j 5.26.31 Community + APOC core, loaded with docs/schema/neo4j/final_biotech_schema_operations.cypher,
// validation/fixtures-final/* (+ backfill) and workers/W23/fixtures/00-shared-base.cypher + 04-uid-redirect.cypher.
// Run with the run harness: node run-cypher.mjs <bolt.uri> CH-W23-privacy.cypher   (statements split on ';' at line end;
// no variable crosses a statement). Disposable database only. Every node created here has a uid containing ':chp-';
// the UNDO block at the end removes all of them and restores the two fixture values the section-7 replay upper-cases.
// Order: (A) attack mutations CH-P-01..CH-P-13, CH-P-07c; then run docs/schema/neo4j/validation.cypher (validation-params.json)
// and workers/W23/fixtures/validation-w23.cypher to record catches; (B) CH-P-12 replay of operations section 7 then re-run
// V-113..V-116, V-521, V-W23-09; (C) query-shape probes CH-P-15a..d (literal parameters); (D) GraphQL operations are in the
// JSON block of CH-W23-privacy.md (CH-P-14 mutation creates one more ':chp-' node); (E) UNDO.
// Observed results for every statement are in CH-W23-privacy.md.

// ===================================== (A) attack mutations =====================================
// CH-P-01: PUBLIC Assertion whose subject (AssertionSubjectTarget union member Activity) is an INTERNAL Activity
MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar1'}), (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
MERGE (a:Assertion {uid: 'hu:assertion:chp-01-about-internal-activity'})
SET a.id = 'chp-01-about-internal-activity', a.predicate = 'USED', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-04-12T09:10:00Z'),
    a.contentHash = 'sha256:c1', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-04-12T09:10:00Z'), a.updatedAt = datetime('2026-04-12T09:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(act)
MERGE (a)-[:HAS_OBJECT]->(l)
MERGE (a)-[:SUPPORTED_BY]->(l);

// CH-P-01b: the existing PUBLIC assertion A2 is WAS_GENERATED_BY an INTERNAL extraction Activity AUTHORIZED_BY the INTERNAL ranking policy
MATCH (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'}), (pv:PolicyVersion {uid: 'hu:policy-version:w23-sleep-support-ranking-v3'})
MERGE (act:Activity:Occurrence {uid: 'hu:activity:chp-01b-extract'})
SET act.id = 'chp-01b-extract', act.occurrenceType = 'ACTIVITY', act.activityKind = 'EXTRACTION', act.startedAt = datetime('2026-06-15T08:05:00Z'),
    act.externalRunSystem = 'mongo-research', act.externalRunId = 'run-chp-01b', act.mongoResearchRunId = 'run-chp-01b', act.privacyClass = 'INTERNAL',
    act.createdAt = datetime('2026-06-15T08:06:00Z'), act.updatedAt = datetime('2026-06-15T08:06:00Z')
MERGE (a)-[:WAS_GENERATED_BY]->(act)
MERGE (act)-[ab:AUTHORIZED_BY]->(pv)
SET ab.useKind = 'USE_AS_RECOMMENDATION_EVIDENCE';

// CH-P-02: INTERNAL and unclassified instances of PUBLIC types (interface queries entities / actorIdentities / searchIndexables)
MERGE (p:Person:Entity {uid: 'hu:person:chp-02-internal-curator'})
SET p.id = 'chp-02-internal-curator', p.entityType = 'PERSON', p.name = 'Internal curator roster entry (synthetic)', p.privacyClass = 'INTERNAL',
    p.bio = 'BellLabs internal reviewer roster: on-call night shift curator', p.searchText = 'internal reviewer roster night shift curator', p.searchFields = ['name', 'bio'],
    p.createdAt = datetime('2026-05-01T00:00:00Z'), p.updatedAt = datetime('2026-05-01T00:00:00Z');

MERGE (p:Person:Entity {uid: 'hu:person:chp-02-unclassified'})
SET p.id = 'chp-02-unclassified', p.entityType = 'PERSON', p.name = 'Unclassified person record (synthetic)',
    p.bio = 'night shift worker, imported without a privacy class', p.searchText = 'night shift worker', p.searchFields = ['bio'],
    p.createdAt = datetime('2026-05-01T00:00:00Z'), p.updatedAt = datetime('2026-05-01T00:00:00Z');

// CH-P-03: fulltext index ProductSearch over searchText that was derived from a private-only property (goalStatement)
MERGE (p:Product:Entity {uid: 'hu:product:chp-03-goal-derived-search'})
SET p.id = 'chp-03-goal-derived-search', p.entityType = 'PRODUCT', p.name = 'NightRest Magnesium (synthetic)', p.privacyClass = 'PUBLIC',
    p.searchText = 'cannot sleep after night shifts while pregnant, serum magnesium 2.1 mg/dL', p.searchFields = ['goalStatement', 'personalValueNumber'],
    p.createdAt = datetime('2026-05-22T12:30:00Z'), p.updatedAt = datetime('2026-05-22T12:30:00Z');

// CH-P-04: stored vector-index candidate property on an INTERNAL Person, embedding computed from private fields
MATCH (p:Person {uid: 'hu:person:chp-02-internal-curator'})
SET p.searchEmbedding = [0.12, -0.03, 0.44], p.embeddingModel = 'synthetic-embed-3', p.embeddingDimensions = 3,
    p.searchFields = ['goalStatement', 'declaredConditionUids'];

// CH-P-05: AnswerRecord embeds a private uid mid-string and the asker's question in allow-listed free-text keys
MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar2'}), (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:chp-05-asker-in-description'})
SET r.id = 'chp-05-asker-in-description', r.occurrenceType = 'ANSWER_PUBLICATION', r.startedAt = act.startedAt, r.endedAt = act.endedAt,
    r.recordedAsOf = datetime('2026-06-20T09:30:00Z'), r.validAt = datetime('2026-06-20T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a', r.queryShapeVersion = '0.2.0',
    r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'LOCATOR', r.publishedAt = datetime('2026-06-20T10:06:00Z'),
    r.name = 'Q: how much magnesium can I take for sleep while pregnant after night shifts?',
    r.description = 'answered for owner=hu:private-user-context:synthetic-0001 (session 7f3a)',
    r.privacyClass = 'INTERNAL', r.createdAt = datetime('2026-06-20T10:06:00Z'), r.updatedAt = datetime('2026-06-20T10:06:00Z')
MERGE (r)-[c:CITES_ASSERTION]->(a)
SET c.orderIndex = 0
MERGE (r)-[:WAS_GENERATED_BY]->(act);

// CH-P-06: PUBLIC_ANSWER AnswerRecord cites an INTERNAL assertion and an INTERNAL adjudication (cited uids are on the public allow-list)
MATCH (v:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'}), (pv:PolicyVersion {uid: 'hu:policy-version:w23-sleep-support-ranking-v3'}),
      (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
MERGE (a:Assertion {uid: 'hu:assertion:chp-06-internal-ranking-note'})
SET a.id = 'chp-06-internal-ranking-note', a.predicate = 'RANKING_NOTE', a.status = 'ACCEPTED', a.polarity = 'NEGATIVE',
    a.description = 'demoted under sleep-support-ranking v3: SAFETY_BLOCK for pregnancy', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-06-01T00:00:00Z'), a.contentHash = 'sha256:c6', a.privacyClass = 'INTERNAL',
    a.createdAt = datetime('2026-06-01T00:00:00Z'), a.updatedAt = datetime('2026-06-01T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(pv)
MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar2'}), (a:Assertion {uid: 'hu:assertion:chp-06-internal-ranking-note'}),
      (j:Adjudication {uid: 'hu:adjudication:synthetic-a1-accept'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:chp-06-cites-internal'})
SET r.id = 'chp-06-cites-internal', r.occurrenceType = 'ANSWER_PUBLICATION', r.startedAt = act.startedAt, r.endedAt = act.endedAt,
    r.recordedAsOf = datetime('2026-06-20T09:30:00Z'), r.validAt = datetime('2026-06-20T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a', r.queryShapeVersion = '0.2.0',
    r.accessTier = 'PUBLIC_ANSWER', r.privateContext = 'EXCLUDED', r.traceDepth = 'ADJUDICATION', r.publishedAt = datetime('2026-06-20T10:07:00Z'),
    r.privacyClass = 'INTERNAL', r.createdAt = datetime('2026-06-20T10:07:00Z'), r.updatedAt = datetime('2026-06-20T10:07:00Z')
MERGE (r)-[c1:CITES_ASSERTION]->(a)
SET c1.orderIndex = 0
MERGE (r)-[c2:CITES_ASSESSMENT]->(j)
SET c2.orderIndex = 0
MERGE (r)-[:WAS_GENERATED_BY]->(act);

// CH-P-07: private uid tokens in list properties (relationship list, case/whitespace variant, private-store token without the private- prefix, JSON-in-string)
MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:chp-07-a'})
SET o.id = 'chp-07-a', o.artifactType = 'OBSERVATION', o.resultKind = 'MEASURED', o.valueNumber = 2.0, o.unitCode = 'mg/dL', o.privacyClass = 'PUBLIC',
    o.relatedRecordUids = ['hu:personal-measurement:synthetic-0001-m1'],
    o.sourceNote = '{"importedFrom":"hu:private-personal-measurement:synthetic-0001-m1"}',
    o.createdAt = datetime('2026-06-01T00:00:00Z'), o.updatedAt = datetime('2026-06-01T00:00:00Z');

MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:chp-07-b'})
SET o.id = 'chp-07-b', o.artifactType = 'OBSERVATION', o.resultKind = 'MEASURED', o.valueNumber = 1.9, o.unitCode = 'mg/dL', o.privacyClass = 'PUBLIC',
    o.createdAt = datetime('2026-06-01T00:00:00Z'), o.updatedAt = datetime('2026-06-01T00:00:00Z');

MATCH (a:Observation {uid: 'hu:observation:chp-07-a'}), (b:Observation {uid: 'hu:observation:chp-07-b'})
MERGE (a)-[r1:COMPARED_TO {relationshipUid: 'hu:rel:chp-07-list-private'}]->(b)
SET r1.derivationRule = 'same-assay-version', r1.derivedFromAssertionUids = ['hu:private-personal-measurement:synthetic-0001-m1'], r1.derivedAt = datetime('2026-06-02T00:00:00Z')
MERGE (b)-[r2:COMPARED_TO {relationshipUid: 'hu:rel:chp-07-list-private-upper'}]->(a)
SET r2.derivationRule = 'same-assay-version', r2.derivedFromAssessmentUids = [' HU:PRIVATE-PERSONAL-MEASUREMENT:synthetic-0001-m1'], r2.derivedAt = datetime('2026-06-02T00:00:00Z');

// CH-P-08: Observation copied from the private PersonalMeasurement (2.1 mg/dL at 2026-05-20T08:00Z) attached to an attributed public ProtocolResult
MERGE (pp:Person:Entity {uid: 'hu:person:chp-08-public-author'})
SET pp.id = 'chp-08-public-author', pp.entityType = 'PERSON', pp.name = 'Protocol author (synthetic public figure)', pp.privacyClass = 'PUBLIC',
    pp.createdAt = datetime('2026-05-01T00:00:00Z'), pp.updatedAt = datetime('2026-05-01T00:00:00Z');

MATCH (pp:Person {uid: 'hu:person:chp-08-public-author'}), (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-03-02'})
MERGE (res:ProtocolResult:InformationArtifact {uid: 'hu:protocol-result:chp-08-community-results'})
SET res.id = 'chp-08-community-results', res.artifactType = 'PROTOCOL_RESULT', res.privacyClass = 'PUBLIC', res.name = 'Community sleep protocol results (synthetic)',
    res.createdAt = datetime('2026-05-25T00:00:00Z'), res.updatedAt = datetime('2026-05-25T00:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:chp-08-posts-result'})
SET a.id = 'chp-08-posts-result', a.predicate = 'POSTS_RESULT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-05-25T00:00:00Z'), a.contentHash = 'sha256:c8', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(pp)
MERGE (a)-[:HAS_OBJECT]->(res)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (pp)-[e:POSTS_RESULT {relationshipUid: 'hu:rel:chp-08-posts-result'}]->(res)
SET e.assertionUid = a.uid, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = a.recordedAt;

MATCH (res:ProtocolResult {uid: 'hu:protocol-result:chp-08-community-results'})
MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:chp-08-copied-serum-mg'})
SET o.id = 'chp-08-copied-serum-mg', o.artifactType = 'OBSERVATION', o.resultKind = 'MEASURED', o.valueNumber = 2.1, o.unitCode = 'mg/dL',
    o.observedAt = datetime('2026-05-20T08:00:00Z'), o.observedPopulation = 'community member, self-reported', o.privacyClass = 'PUBLIC',
    o.createdAt = datetime('2026-05-25T00:00:00Z'), o.updatedAt = datetime('2026-05-25T00:00:00Z')
MERGE (res)-[:INCLUDES_OBSERVATION]->(o);

MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:chp-08-orphan-copy'})
SET o.id = 'chp-08-orphan-copy', o.artifactType = 'OBSERVATION', o.resultKind = 'MEASURED', o.valueNumber = 2.1, o.unitCode = 'mg/dL',
    o.observedAt = datetime('2026-05-20T08:00:00Z'), o.privacyClass = 'PUBLIC',
    o.createdAt = datetime('2026-05-25T00:00:00Z'), o.updatedAt = datetime('2026-05-25T00:00:00Z');

// CH-P-09: RECORDS edge, fully assertion-backed, from a NON-PUBLIC Person (INTERNAL) to a PUBLIC Observation
MATCH (p:Person {uid: 'hu:person:chp-02-internal-curator'}), (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-06-15'})
MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:chp-09-recorded-by-internal'})
SET o.id = 'chp-09-recorded-by-internal', o.artifactType = 'OBSERVATION', o.resultKind = 'MEASURED', o.valueNumber = 2.3, o.unitCode = 'mg/dL',
    o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-06-16T00:00:00Z'), o.updatedAt = datetime('2026-06-16T00:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:chp-09-records'})
SET a.id = 'chp-09-records', a.predicate = 'RECORDS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-06-16T00:00:00Z'), a.contentHash = 'sha256:c9', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(p)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[e:RECORDS {relationshipUid: 'hu:rel:chp-09-records'}]->(o)
SET e.assertionUid = a.uid, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = a.recordedAt;

// CH-P-10: PUBLIC Person with no public-source assertion, identifier, mention or locator (a BellLabs user minted as a Person)
MERGE (p:Person:Entity {uid: 'hu:person:chp-10-no-source'})
SET p.id = 'chp-10-no-source', p.entityType = 'PERSON', p.name = 'Dana Example', p.privacyClass = 'PUBLIC',
    p.bio = 'BellLabs member since 2025; tracks serum magnesium; night shift nurse', p.searchText = 'Dana Example night shift nurse serum magnesium', p.searchFields = ['name', 'bio'],
    p.createdAt = datetime('2026-05-22T12:00:00Z'), p.updatedAt = datetime('2026-05-22T12:00:00Z');

// CH-P-11: CohortParticipant whose token identifies a person, with a source-attributed PARTICIPANT_TOKEN identifier (passes V-W23-06)
MATCH (l:SourceLocator {uid: 'hu:locator:w23-sleepwell-facts-2026-06-15'})
MERGE (cp:CohortParticipant:PseudonymousActor:Entity {uid: 'hu:participant:chp-11-identifying-token'})
SET cp.id = 'chp-11-identifying-token', cp.entityType = 'COHORT_PARTICIPANT', cp.name = 'Dana E. (34F, Boise ID, night-shift RN)',
    cp.participantToken = 'dana.example@mail.invalid', cp.privacyClass = 'PUBLIC',
    cp.createdAt = datetime('2026-06-16T00:00:00Z'), cp.updatedAt = datetime('2026-06-16T00:00:00Z')
MERGE (i:Identifier:Entity {uid: 'hu:identifier:chp-11-token'})
SET i.id = 'chp-11-token', i.entityType = 'IDENTIFIER', i.scheme = 'PARTICIPANT_TOKEN', i.value = 'dana.example@mail.invalid', i.privacyClass = 'PUBLIC',
    i.createdAt = datetime('2026-06-16T00:00:00Z'), i.updatedAt = datetime('2026-06-16T00:00:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:chp-11-has-identifier'})
SET a.id = 'chp-11-has-identifier', a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-06-16T00:00:00Z'), a.contentHash = 'sha256:c11', a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(cp)
MERGE (a)-[:HAS_OBJECT]->(i)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (cp)-[e:HAS_IDENTIFIER {relationshipUid: 'hu:rel:chp-11-has-identifier'}]->(i)
SET e.assertionUid = a.uid, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.recordedFrom = a.recordedAt;

// CH-P-12: leaked class-only private node (no hu:private- uid), lower-case class; laundered by operations section 7 (run separately)
MERGE (p:Product:Entity {uid: 'hu:product:chp-12-class-only-leak'})
SET p.id = 'chp-12-class-only-leak', p.entityType = 'PRODUCT', p.name = 'Owner shopping-list entry (synthetic leak)', p.privacyClass = 'private-personal',
    p.searchText = 'owner shopping list magnesium', p.searchFields = ['name'],
    p.createdAt = datetime('2026-05-22T12:00:00Z'), p.updatedAt = datetime('2026-05-22T12:00:00Z');

// CH-P-13: AnswerRecord CITES_ASSESSMENT pointing at the PolicyVersion body (wrong endpoint) and accessTier OWNER_PRIVATE stored PUBLIC
MATCH (act:Activity {uid: 'hu:activity:w23-compose-ar2'}), (pv:PolicyVersion {uid: 'hu:policy-version:w23-sleep-support-ranking-v3'}),
      (a:Assertion {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MERGE (r:AnswerRecord:Occurrence {uid: 'hu:answer-record:chp-13-policy-cited'})
SET r.id = 'chp-13-policy-cited', r.occurrenceType = 'ANSWER_PUBLICATION', r.startedAt = act.startedAt, r.endedAt = act.endedAt,
    r.recordedAsOf = datetime('2026-06-20T09:30:00Z'), r.validAt = datetime('2026-06-20T00:00:00Z'),
    r.schemaDigest = 'sha256:8fb50ff06f80621d460813118f739d7c4d3902a0ea631c16952e11d3815f84f0', r.queryShapeId = 'QS-2a',
    r.accessTier = 'OWNER_PRIVATE', r.privateContext = 'INCLUDED_FOR_OWNER', r.traceDepth = 'ADJUDICATION', r.publishedAt = datetime('2026-06-20T10:08:00Z'),
    r.privacyClass = 'PUBLIC', r.createdAt = datetime('2026-06-20T10:08:00Z'), r.updatedAt = datetime('2026-06-20T10:08:00Z')
MERGE (r)-[c1:CITES_ASSERTION]->(a)
SET c1.orderIndex = 0
MERGE (r)-[c2:CITES_ASSESSMENT]->(pv)
SET c2.orderIndex = 1
MERGE (r)-[:WAS_GENERATED_BY]->(act);

// kernel hygiene for the attack assertions (so that only privacy rules are under test): one CAPTURE_FIDELITY adjudication each
UNWIND ['hu:assertion:chp-01-about-internal-activity', 'hu:assertion:chp-06-internal-ranking-note', 'hu:assertion:chp-08-posts-result',
        'hu:assertion:chp-09-records', 'hu:assertion:chp-11-has-identifier'] AS au
MATCH (a:Assertion {uid: au})-[:SUPPORTED_BY]->(l:SourceLocator)
MERGE (j:Adjudication:EvidenceAssessment {uid: replace(au, 'hu:assertion:', 'hu:adjudication:') + '-cf'})
SET j.id = split(j.uid, ':')[2], j.assessmentType = 'ADJUDICATION', j.methodVersion = 'label-capture-policy-1', j.status = 'ACCEPTED',
    j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.reviewedAt = a.recordedAt, j.recordedAt = a.recordedAt,
    j.privacyClass = 'PUBLIC', j.createdAt = a.recordedAt, j.updatedAt = a.recordedAt
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l);

// CH-P-07c: wrapped private uid inside a LIST property of a STRUCTURAL relationship (outside V-112's derived-edge scope)
MATCH (res:ProtocolResult {uid: 'hu:protocol-result:chp-08-community-results'}), (o:Observation {uid: 'hu:observation:chp-07-b'})
MERGE (res)-[e:INCLUDES_OBSERVATION {relationshipUid: 'hu:rel:chp-07c-structural-list'}]->(o)
SET e.contributionRefs = ['urn:hu:private-personal-measurement:synthetic-0001-m1', 'pcs-user-7f3a'], e.orderIndex = 1;

// ===================================== (B) CH-P-12 laundering replay =====================================
// CH-P-12: final_biotech_schema_operations.cypher section 7, first statement, verbatim. Upper-cases 'private-personal' to
// 'PRIVATE-PERSONAL', which V-113/V-114/V-115/V-116/V-521 and QS-5b/QS-6a/QS-6b no longer recognise.
MATCH (n) WHERE n.privacyClass IS NOT NULL AND n.privacyClass <> toUpper(n.privacyClass) SET n.privacyClass = toUpper(n.privacyClass);

// CH-P-12 check (expected after the replay: 1 row from the V-W23-09 form, 0 rows from the V-521 form)
MATCH (n {uid: 'hu:product:chp-12-class-only-leak'})
RETURN n.privacyClass AS storedClass, n.privacyClass = 'private-personal' AS v521ClassBranchMatches,
       NOT n.privacyClass IN ['PUBLIC', 'INTERNAL'] AS vW23_09Matches;

// ===================================== (C) shipped query shapes as probes =====================================
// CH-P-15a QS-8 (shipped search shape, no instance filter) on PersonSearch
CALL db.index.fulltext.queryNodes('PersonSearch', 'night shift') YIELD node, score
WITH node, score ORDER BY score DESC LIMIT 10
OPTIONAL MATCH (h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(node)
RETURN node.uid AS catalogUid, node.privacyClass AS privacyClass, labels(node) AS labels, node.name AS name, score AS indexScore,
       collect(DISTINCT {hypothesisUid: h.uid}) AS openHypotheses ORDER BY indexScore DESC;

// CH-P-15b QS-5b (shipped compiled data query, deny-list instance test) rooted at an INTERNAL assertion
MATCH (root {uid: 'hu:assertion:chp-06-internal-ranking-note'})
WHERE NOT (root.uid STARTS WITH 'hu:private-' OR root.privacyClass = 'private-personal' OR root:PrivateRecord)
  AND any(l IN labels(root) WHERE l IN ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion', 'Adjudication'])
MATCH p = (root)((a)-[r]->(b)
               WHERE NOT (b.uid STARTS WITH 'hu:private-' OR b.privacyClass = 'private-personal' OR b:PrivateRecord)
                 AND type(r) IN ['HAS_SUBJECT', 'HAS_OBJECT', 'SUPPORTED_BY', 'HAS_VARIANT', 'HAS_FORMULATION_VERSION', 'HAS_LOCATOR', 'HAS_SNAPSHOT']
                 AND any(l IN labels(b) WHERE l IN ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion', 'Adjudication'])
                 AND (r.recordedFrom IS NULL
                      OR (r.recordedFrom <= datetime(datetime('2026-10-04T00:00:00Z')) AND (r.recordedTo IS NULL OR datetime(datetime('2026-10-04T00:00:00Z')) < r.recordedTo)))
                 AND (r.validFrom IS NULL OR r.validFrom <= datetime(datetime('2026-10-04T00:00:00Z')))
                 AND (r.validTo IS NULL OR datetime(datetime('2026-10-04T00:00:00Z')) < r.validTo)){1,3}(leaf)
RETURN [n IN nodes(p) | n.uid + '|' + coalesce(n.privacyClass, 'null')] AS nodeUids, [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT 50;

// CH-P-15c QS-5b rooted at the laundered class-only leak (privacyClass 'PRIVATE-PERSONAL' after operations section 7)
MATCH (root {uid: 'hu:product:chp-12-class-only-leak'})
WHERE NOT (root.uid STARTS WITH 'hu:private-' OR root.privacyClass = 'private-personal' OR root:PrivateRecord)
  AND any(l IN labels(root) WHERE l IN ['Product', 'ProductVariant', 'FormulationVersion', 'Source', 'SourceSnapshot', 'SourceLocator', 'Assertion', 'Adjudication'])
RETURN root.uid AS admittedRoot, root.privacyClass AS privacyClass;

// CH-P-15d QS-6a (shipped shared-graph traversal) from the PUBLIC SleepWell variant: what INTERNAL nodes does it admit
MATCH (s {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})
WHERE NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
MATCH p = (s)(()-[r]-(n) WHERE NOT (n.uid STARTS WITH 'hu:private-' OR n.privacyClass = 'private-personal' OR n:PrivateRecord)){1,2}
UNWIND nodes(p) AS x
WITH DISTINCT x WHERE coalesce(x.privacyClass, 'null') <> 'PUBLIC'
RETURN x.uid AS nonPublicAdmitted, x.privacyClass AS privacyClass, labels(x) AS labels;

// CH-P-03/04 probe: raw fulltext queries on the shipped indexes (no instance filter exists at index level)
CALL db.index.fulltext.queryNodes('ProductSearch', 'pregnant') YIELD node, score
RETURN node.uid AS uid, node.privacyClass AS privacyClass, node.searchFields AS searchFields, score;

// ===================================== (E) UNDO =====================================
// UNDO (all CH-P mutations): every node created by this file has a uid containing ':chp-'; edges created on pre-existing nodes are removed explicitly.
MATCH (n) WHERE n.uid CONTAINS ':chp-' DETACH DELETE n;
MATCH ()-[r]->() WHERE r.relationshipUid CONTAINS ':chp-' DELETE r;
// CH-P-12 / ops section 7 replay: restore the fixture values the normalization statement upper-cased
MATCH (n) WHERE n.privacyClass = 'PRIVATE-PERSONAL' AND n:PrivateRecord SET n.privacyClass = 'private-personal';
MATCH (n) WHERE n.privacyClass = 'SYNTHETIC' SET n.privacyClass = 'synthetic';
// GraphQL-created AnswerRecord from CH-P-14 (uid contains :chp-) is covered by the first statement
MATCH (n) WHERE n.uid CONTAINS ':chp-' RETURN count(n) AS remainingChpNodes;
