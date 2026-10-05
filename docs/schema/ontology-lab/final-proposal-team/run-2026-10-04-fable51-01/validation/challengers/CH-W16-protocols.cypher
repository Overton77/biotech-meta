// CH-W16-protocols.cypher -- Wave 5 Challenger W16 (protocols), run-2026-10-04-fable51-01. Opus 5.5 Challenger, 2026-10-04.
// Concrete counterexamples against the ASSEMBLED artifacts (final_biotech_schema_operations.cypher constraints + the W16 fixtures as base graphs).
// Findings, observed results and proposed fixes: CH-W16-protocols.md (same directory).
//
// How these were executed (embedded Neo4j 5.26.31 Community + APOC, final operations file applied, run harness run-cypher.mjs):
//   1. MATCH (n) DETACH DELETE n; then load the named base fixture (paths relative to the run directory).
//   2. Run the validator bundle (W16 00-w16-validators.cypher + docs/schema/neo4j/validation.cypher + W00 validation-corrections.cypher
//      + W07 w07-validation.cypher + W23 validation-w23.cypher, params validation-params.json merged with qs-params.json).
//   3. Run the MUTATION block of one section, re-run the bundle, diff the per-validator row counts.
//   4. Run the UNDO block; the bundle returned to the pre-mutation counts for every section (verified).
// Sections marked 'KEEP' reuse the base of the previous section after its undo. Every statement binds its own nodes by uid;
// CH uids contain 'ch-r'. Probe queries (RETURN ...) inside a mutation block show what a reader would get.

// ==============================================================================================================
// CH-R-01: Adoption read as adherence (synonym edges, aggregate properties)
// Base: workers/W16/fixtures/06-optional-step-no-nonadherence.cypher
// ==============================================================================================================
// ---- MUTATION (r02) ----
// CH-R-01 base: a public person's published adoption statement (legitimate on its own: an Assertion about that person).
MERGE (a:Assertion {uid: 'hu:assertion:ch-r02-host-adopted-e1'}) SET a += {predicate: 'ADOPTED_PROTOCOL_EDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', speechAct: 'REPORTS_PRACTICE', assertionBasis: 'PERSONAL_EXPERIENCE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r02-a'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r02-host-adopted-e1'}), (p:Person {uid: 'hu:person:synthetic-podcast-host'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}), (l:SourceLocator {uid: 'hu:locator:synthetic-sleep-podcast-12-q'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(e) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:ASSERTED_BY]->(p);
// CH-R-01a (control, expected CAUGHT by V-112): adherence derived from adoption under the catalog's own conclusion name.
MATCH (p:Person {uid: 'hu:person:synthetic-podcast-host'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})
MERGE (p)-[r:FOLLOWS_ALL_STEPS]->(e) SET r += {derivationRule: 'ch-adoption-implies-adherence', derivedFromAssertionUids: ['hu:assertion:ch-r02-host-adopted-e1'], derivedAt: datetime('2026-10-04T12:00:00Z')};
// CH-R-01b: the same derivation under synonyms that a "who follows protocol X" query reads as adherence.
MATCH (p:Person {uid: 'hu:person:synthetic-podcast-host'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})
MERGE (p)-[r:ADHERENT_TO]->(e) SET r += {derivationRule: 'ch-adoption-implies-adherence', derivedFromAssertionUids: ['hu:assertion:ch-r02-host-adopted-e1'], derivedAt: datetime('2026-10-04T12:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r02-host-adopts-protocol'}) SET a += {predicate: 'ADOPTS', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', speechAct: 'REPORTS_PRACTICE', assertionBasis: 'PERSONAL_EXPERIENCE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r02-b'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r02-host-adopts-protocol'}), (p:Person {uid: 'hu:person:synthetic-podcast-host'}), (x:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'}), (l:SourceLocator {uid: 'hu:locator:synthetic-sleep-podcast-12-q'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(x) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (p)-[r:ADOPTS]->(x) SET r += {relationshipUid: 'hu:rel:ch-r02-adopts', assertionUid: a.uid, recordedFrom: a.recordedAt, validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'};
// CH-R-01c: aggregate adherence computed from adoption counts, written onto the public edition.
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}) SET e.adherenceRate = 0.92, e.adopterCount = 1200, e.fullAdherenceShare = 0.92;
// CH-R-01 probe: the misreading query ("people who follow every step of e1") now returns the host from adoption alone.
MATCH (p:Person)-[r:ADHERENT_TO|ADOPTS|FOLLOWS_ALL_STEPS]->(x) RETURN p.uid AS person, type(r) AS readAsAdherence, x.uid AS target;
// ---- UNDO (r02) ----
// CH-R-01 undo
MATCH (:Person {uid: 'hu:person:synthetic-podcast-host'})-[r:FOLLOWS_ALL_STEPS|ADHERENT_TO|ADOPTS]->() DELETE r;
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}) REMOVE e.adherenceRate, e.adopterCount, e.fullAdherenceShare;
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:ch-r02-host-adopted-e1', 'hu:assertion:ch-r02-host-adopts-protocol'] DETACH DELETE a;

// ==============================================================================================================
// CH-R-02: Dependency loop read as repetition (null/unknown kind; concurrent + ordered)
// Base: workers/W16/fixtures/03-repeated-step-plus-prerequisite.cypher
// ==============================================================================================================
// ---- MUTATION (r03) ----
// CH-R-02a (control, expected CAUGHT by V-528p): "repeat the titration checks after starting" written as a 2-cycle of ordering kinds.
MATCH (a:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-start-lithium-v1'}), (b:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-plasma-lithium-titration-checks-v1'})
MERGE (a)-[d:DEPENDS_ON {notes: 'ch-r03a'}]->(b) SET d.dependencyKind = 'REQUIRES_RESULT_OF';
// ---- UNDO (r03) ----
// CH-R-02a undo
MATCH ()-[d:DEPENDS_ON {notes: 'ch-r03a'}]->() DELETE d;
// ---- MUTATION (r03b) ----
// CH-R-02b: the same loop with the back edge's kind missing (GraphQL says dependencyKind!, Community enforces nothing) or outside the enum.
MATCH (a:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-start-lithium-v1'}), (b:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-plasma-lithium-titration-checks-v1'})
MERGE (a)-[d:DEPENDS_ON {notes: 'ch-r03b-null-kind'}]->(b);
MATCH (a:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-plasma-lithium-year1-v1'}), (b:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-start-lithium-v1'})
MERGE (b)-[d:DEPENDS_ON {notes: 'ch-r03b-repeat-kind'}]->(a) SET d.dependencyKind = 'REPEATS_AFTER';
// CH-R-02c: a pair that is both CONCURRENT_WITH and ordered (titration checks happen "with" and "after" starting lithium).
MATCH (a:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-plasma-lithium-titration-checks-v1'}), (b:ProtocolStep {uid: 'hu:protocol-step:nice-cg185-start-lithium-v1'})
MERGE (a)-[d:DEPENDS_ON {notes: 'ch-r03c'}]->(b) SET d.dependencyKind = 'CONCURRENT_WITH';
// CH-R-02 probe: a repetition query that reads any DEPENDS_ON loop through a step as "this step repeats".
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:nice-cg185-lithium-2025-09-02'})-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
MATCH p = (s)-[:DEPENDS_ON*1..6]->(s)
RETURN DISTINCT s.stepKey AS readAsRepeatedStep, [r IN relationships(p) | coalesce(r.dependencyKind, 'NULL')] AS loopKinds;
// ---- UNDO (r03b) ----
// CH-R-02b/c undo
MATCH ()-[d:DEPENDS_ON]->() WHERE d.notes IN ['ch-r03b-null-kind', 'ch-r03b-repeat-kind', 'ch-r03c'] DELETE d;

// ==============================================================================================================
// CH-R-03 / CH-R-04: Cadence: midpoint collapse that V-529b cannot see (03) and anchor/day-conversion disagreement (04)
// Base: workers/W16/fixtures/10-cadence-range-3-to-6-months.cypher
// ==============================================================================================================
// ---- MUTATION (r04) ----
// CH-R-03a: "every three to six months" (words) collapsed to the midpoint 4..4 (V-529b's regex needs digits).
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r04a'}) SET s += {id: 'ch-r04a', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'routine-blood-draw-a', payloadHash: 'sha256:04a', stepKind: 'SAMPLE', requirementLevel: 'NOT_STATED', requirementBasis: 'NOT_STATED', cadenceUnit: 'MONTH', cadenceIntervalMin: 4, cadenceIntervalMax: 4, scheduleText: 'Blood draw every three to six months', createdAt: datetime('2026-10-04T12:00:00Z')};
// CH-R-03b: digits, but the verbatim range sits in frequencyText and the stored range is narrowed to the middle (4..5), not collapsed.
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r04b'}) SET s += {id: 'ch-r04b', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'routine-blood-draw-b', payloadHash: 'sha256:04b', stepKind: 'SAMPLE', requirementLevel: 'NOT_STATED', requirementBasis: 'NOT_STATED', cadenceUnit: 'MONTH', cadenceIntervalMin: 4, cadenceIntervalMax: 5, frequencyText: 'every 3-6 months', createdAt: datetime('2026-10-04T12:00:00Z')};
// CH-R-03c: plan text abbreviated ("mo") and collapsed to the mean-month midpoint 136 days.
MERGE (m:MeasurementPlan:Entity {uid: 'hu:measurement-plan:ch-r04c'}) SET m += {id: 'ch-r04c', entityType: 'MeasurementPlan', privacyClass: 'PUBLIC', planTiming: 'PERIODIC', cadenceMinDays: 136, cadenceMaxDays: 136, scheduleText: 'Blood draw q3-6 mo', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-neg-range'}), (a:ProtocolStep {uid: 'hu:protocol-step:ch-r04a'}), (b:ProtocolStep {uid: 'hu:protocol-step:ch-r04b'}), (m:MeasurementPlan {uid: 'hu:measurement-plan:ch-r04c'})
MERGE (e)-[r1:HAS_PROTOCOL_STEP]->(a) SET r1.orderIndex = 2 MERGE (e)-[r2:HAS_PROTOCOL_STEP]->(b) SET r2.orderIndex = 3 MERGE (e)-[:HAS_MEASUREMENT_PLAN]->(m);
// CH-R-04 (no mutation; anchor probe): the stored plan (90..183 days, W16 model card "ceil(30.4375 x months)") vs the final SDL text
// ("30 days lower and 31 upper" = 90..186) vs the stated anchor read in calendar months from the last draw (+3 / +6 months).
MATCH (m:MeasurementPlan {uid: 'hu:measurement-plan:blueprint-routine-blood-draw'})
WITH m, date('2026-01-31') AS lastDraw
RETURN lastDraw,
       lastDraw + duration({months: 3}) AS calendarOpens, lastDraw + duration({months: 6}) AS calendarCloses,
       lastDraw + duration({days: m.cadenceMinDays}) AS storedOpens, lastDraw + duration({days: m.cadenceMaxDays}) AS storedCloses,
       lastDraw + duration({days: 6 * 31}) AS sdlRuleCloses,
       lastDraw + duration({days: (m.cadenceMinDays + m.cadenceMaxDays) / 2}) AS midpointDue,
       CASE WHEN date('2026-08-01') <= lastDraw + duration({days: m.cadenceMaxDays}) THEN 'WITHIN_WINDOW' ELSE 'OVERDUE' END AS storedStatusOn20260801,
       CASE WHEN date('2026-08-01') <= lastDraw + duration({months: 6}) THEN 'WITHIN_WINDOW' ELSE 'OVERDUE' END AS calendarStatusOn20260801;
// ---- UNDO (r04) ----
// CH-R-03/04 undo
MATCH (n) WHERE n.uid IN ['hu:protocol-step:ch-r04a', 'hu:protocol-step:ch-r04b', 'hu:measurement-plan:ch-r04c'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-05: Third-party report minted as an edition of the original Protocol
// Base: workers/W16/fixtures/02-source-change-same-identity.cypher
// ==============================================================================================================
// ---- MUTATION (r05) ----
// CH-R-05: NAD.com's retelling ("NMN or NR 500 mg (6x/week)"; rapamycin "stopped in 2024") minted as an edition of the ORIGINAL
// Blueprint Protocol, labelled SNAPSHOT_DIFF, its HAS_PROTOCOL_EDITION Assertion asserted by NAD.com and supported only by NAD.com's locator.
MERGE (e:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:ch-r05-nadcom-version'}) SET e += {id: 'ch-r05-nadcom-version', stateType: 'ProtocolEdition', privacyClass: 'PUBLIC', editionLabel: null, changeProvenance: 'SNAPSHOT_DIFF', payloadHash: 'sha256:0000000000000000000000000000000000000000000000000000000000000105', payloadCanonicalizationVersion: 'W16-CANON-1', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r05-nmn-six-days'}) SET s += {id: 'ch-r05-nmn-six-days', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'nad-precursor', payloadHash: 'sha256:05', stepKind: 'INGEST', requirementLevel: 'NOT_STATED', requirementBasis: 'NOT_STATED', occurrencesPerPeriodMin: 6, occurrencesPerPeriodMax: 6, occurrencePeriodUnit: 'WEEK', scheduleText: 'NMN or NR 500 mg (6x/week)', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r05-nadcom-version'}), (s:ProtocolStep {uid: 'hu:protocol-step:ch-r05-nmn-six-days'}) MERGE (e)-[r:HAS_PROTOCOL_STEP]->(s) SET r.orderIndex = 1;
MERGE (a:Assertion {uid: 'hu:assertion:ch-r05-nadcom-has-edition'}) SET a += {predicate: 'HAS_PROTOCOL_EDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', validFrom: datetime('2026-03-24T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'PUBLICATION_PROXY', validToBasis: 'UNKNOWN', speechAct: 'STATES', assertionBasis: 'THIRD_PARTY_ANECDOTE', contentHash: 'sha256:ch-r05'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r05-nadcom-has-edition'}), (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r05-nadcom-version'}), (l:SourceLocator {uid: 'hu:locator:nadcom-johnson-2026-key-points'}), (o:Organization {uid: 'hu:org:nad-com'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(e) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:ASSERTED_BY]->(o);
MATCH (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r05-nadcom-version'}), (x:Assertion {uid: 'hu:assertion:ch-r05-nadcom-has-edition'})
MERGE (p)-[r:HAS_PROTOCOL_EDITION {relationshipUid: 'hu:rel:ch-r05-nadcom-edition'}]->(e)
SET r.assertionUid = x.uid, r.validFrom = x.validFrom, r.validFromPrecision = x.validFromPrecision, r.validFromBasis = x.validFromBasis, r.validTo = null, r.validToBasis = 'UNKNOWN', r.recordedFrom = x.recordedAt;
// CH-R-05 probe: the edition history of the Blueprint Protocol now lists a NAD.com edition, indistinguishable by provenance label.
MATCH (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'})-[h:HAS_PROTOCOL_EDITION]->(e)
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})-[:ASSERTED_BY]->(who)
RETURN e.uid AS edition, e.changeProvenance AS provenance, who.uid AS asserter ORDER BY edition;
// ---- UNDO (r05) ----
// CH-R-05 undo
MATCH (n) WHERE n.uid IN ['hu:protocol-edition:ch-r05-nadcom-version', 'hu:protocol-step:ch-r05-nmn-six-days', 'hu:assertion:ch-r05-nadcom-has-edition'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-10: Cosmetic re-capture minted as new editions (same base as CH-R-05; run after its undo)
// Base: KEEP (base 02)
// ==============================================================================================================
// ---- MUTATION (r10) ----
// CH-R-10a: a cosmetic re-capture (page template/widget churn only) minted as a NEW edition: same payloadHash, same step nodes,
// same order as hu:protocol-edition:blueprint-observed-2026-10-04, attached by its own asserted episode.
MATCH (old:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-observed-2026-10-04'})
MERGE (e:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:ch-r10-cosmetic-2026-10-05'})
SET e += {id: 'ch-r10-cosmetic-2026-10-05', stateType: 'ProtocolEdition', privacyClass: 'PUBLIC', editionLabel: null, changeProvenance: 'SNAPSHOT_DIFF', payloadHash: old.payloadHash, payloadCanonicalizationVersion: old.payloadCanonicalizationVersion, createdAt: datetime('2026-10-05T00:00:00Z')};
MATCH (old:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-observed-2026-10-04'})-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep), (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r10-cosmetic-2026-10-05'})
MERGE (e)-[r:HAS_PROTOCOL_STEP]->(s) SET r.orderIndex = o.orderIndex;
// CH-R-10b: the same cosmetic capture with a payloadHash that changed only because display text entered the hash (identical step set and order).
MATCH (old:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-observed-2026-10-04'})
MERGE (e:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:ch-r10-cosmetic-b'})
SET e += {id: 'ch-r10-cosmetic-b', stateType: 'ProtocolEdition', privacyClass: 'PUBLIC', editionLabel: null, changeProvenance: 'SNAPSHOT_DIFF', payloadHash: 'sha256:0000000000000000000000000000000000000000000000000000000000000110', payloadCanonicalizationVersion: 'W16-CANON-1', createdAt: datetime('2026-10-05T00:00:00Z')};
MATCH (old:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-observed-2026-10-04'})-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep), (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r10-cosmetic-b'})
MERGE (e)-[r:HAS_PROTOCOL_STEP]->(s) SET r.orderIndex = o.orderIndex;
UNWIND [['hu:protocol-edition:ch-r10-cosmetic-2026-10-05', 'hu:assertion:ch-r10-a', 'hu:rel:ch-r10-a'], ['hu:protocol-edition:ch-r10-cosmetic-b', 'hu:assertion:ch-r10-b', 'hu:rel:ch-r10-b']] AS row
MATCH (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'}), (e:ProtocolEdition {uid: row[0]}), (l:SourceLocator {uid: 'hu:locator:blueprint-protocol-2026-10-04-rx'})
MERGE (a:Assertion {uid: row[1]}) SET a += {predicate: 'HAS_PROTOCOL_EDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-05T00:00:00Z'), privacyClass: 'PUBLIC', validFromBasis: 'OBSERVATION_ONLY', validToBasis: 'UNKNOWN', speechAct: 'STATES', assertionBasis: 'UNSTATED', contentHash: 'sha256:' + row[1]}
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(e) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[h:HAS_PROTOCOL_EDITION {relationshipUid: row[2]}]->(e) SET h.assertionUid = a.uid, h.validFromBasis = 'OBSERVATION_ONLY', h.validToBasis = 'UNKNOWN', h.recordedFrom = a.recordedAt;
// ---- UNDO (r10) ----
// CH-R-10 undo
MATCH (n) WHERE n.uid IN ['hu:protocol-edition:ch-r10-cosmetic-2026-10-05', 'hu:protocol-edition:ch-r10-cosmetic-b', 'hu:assertion:ch-r10-a', 'hu:assertion:ch-r10-b'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-14: Protocol.currentSteps from two open editions (same base)
// Base: KEEP (base 02)
// ==============================================================================================================
// ---- MUTATION (r13) ----
// CH-R-14: materialize Protocol.currentSteps (HAS_CURRENT_PROTOCOL_STEP) exactly as rule protocol-current-steps-v1 is worded in the final SDL:
// "steps of the edition whose HAS_PROTOCOL_EDITION episode has recordedTo null and contains now". Fixture 02's two SNAPSHOT_DIFF episodes are both open.
MATCH (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'})-[h:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE h.recordedTo IS NULL AND (h.validFrom IS NULL OR h.validFrom <= datetime()) AND (h.validTo IS NULL OR h.validTo > datetime())
MERGE (p)-[c:HAS_CURRENT_PROTOCOL_STEP]->(s) SET c.derivationRule = 'protocol-current-steps-v1', c.derivedAt = datetime('2026-10-04T12:00:00Z');
// CH-R-14 probe: what Protocol.currentSteps returns: two "current" tadalafil/acarbose/creatine doses for one stepKey.
MATCH (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'})-[:HAS_CURRENT_PROTOCOL_STEP]->(s:ProtocolStep)-[u:USES]->(x)
WITH s.stepKey AS stepKey, collect(DISTINCT toString(u.quantity) + ' ' + coalesce(u.unitCode, '') + ' ' + coalesce(u.quantityBasis, '')) AS currentDoses
WHERE size(currentDoses) > 1 RETURN stepKey, currentDoses ORDER BY stepKey;
// ---- UNDO (r13) ----
// CH-R-14 undo
MATCH (:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'})-[c:HAS_CURRENT_PROTOCOL_STEP]->() DELETE c;

// ==============================================================================================================
// CH-R-15: ProtocolVersion attached or collapsed as a ProtocolEdition (same base)
// Base: KEEP (base 02)
// ==============================================================================================================
// ---- MUTATION (r14) ----
// CH-R-15a (CL-007): a study protocol document (ProtocolVersion, InformationArtifact, W09) attached to a public Protocol as if it were an edition.
MERGE (v:ProtocolVersion:InformationArtifact {uid: 'hu:protocol-version:ch-r14-study-protocol-v3'}) SET v += {id: 'ch-r14-study-protocol-v3', artifactType: 'ProtocolVersion', privacyClass: 'PUBLIC', name: 'Study protocol v3.0 (CH fixture)', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r14-has-edition'}) SET a += {predicate: 'HAS_PROTOCOL_EDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', speechAct: 'STATES', assertionBasis: 'UNSTATED', contentHash: 'sha256:ch-r14'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r14-has-edition'}), (p:Protocol {uid: 'hu:protocol:blueprint-bryan-johnson'}), (v:ProtocolVersion {uid: 'hu:protocol-version:ch-r14-study-protocol-v3'}), (l:SourceLocator {uid: 'hu:locator:blueprint-protocol-2026-10-04-rx'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(v) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[h:HAS_PROTOCOL_EDITION {relationshipUid: 'hu:rel:ch-r14'}]->(v) SET h.assertionUid = a.uid, h.recordedFrom = a.recordedAt, h.validFromBasis = 'UNKNOWN', h.validToBasis = 'UNKNOWN';
// CH-R-15b: one node double-labelled ProtocolEdition + ProtocolVersion with a single archetype label (V-000b counts archetypes, not domain labels).
MERGE (n:ProtocolEdition:ProtocolVersion:VersionedState {uid: 'hu:protocol-edition:ch-r14-collapsed'}) SET n += {id: 'ch-r14-collapsed', stateType: 'ProtocolEdition', artifactType: 'ProtocolVersion', privacyClass: 'PUBLIC', changeProvenance: 'SOURCE_VERSIONED', editionLabel: 'v3.0', payloadHash: 'sha256:0000000000000000000000000000000000000000000000000000000000000114', createdAt: datetime('2026-10-04T12:00:00Z')};
// ---- UNDO (r14) ----
// CH-R-15 undo
MATCH (n) WHERE n.uid IN ['hu:protocol-version:ch-r14-study-protocol-v3', 'hu:assertion:ch-r14-has-edition', 'hu:protocol-edition:ch-r14-collapsed'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-06: Private execution written as a public Observation / ProtocolResult
// Base: workers/W16/fixtures/08-device-assay-formulation-version-change.cypher
// ==============================================================================================================
// ---- MUTATION (r06) ----
// CH-R-06a: a BellLabs member's own executed measurement (their uploaded lab PDF, week 4 of the protocol) written as a PUBLIC Observation,
// recorded by a Person node minted for the member, "source-attributed" to a snapshot of the member's app page. No hu:private- uid, no private label.
MERGE (p:Person:Entity {uid: 'hu:person:ch-r06-member-0001'}) SET p += {id: 'ch-r06-member-0001', entityType: 'Person', privacyClass: 'PUBLIC', name: 'Member 0001', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (src:Source:Entity {uid: 'hu:source:ch-r06-member-upload'}) SET src += {id: 'ch-r06-member-upload', entityType: 'Source', privacyClass: 'PUBLIC', canonicalUri: 'https://app.bellabs.example/u/0001/labs/2026-09-30.pdf', sourceKind: 'SELF_DISCLOSURE_PAGE', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:ch-r06-member-upload'}) SET sn += {id: 'ch-r06-member-upload', artifactType: 'SourceSnapshot', privacyClass: 'PUBLIC', retrievedAt: datetime('2026-10-04T12:00:00Z'), observedAt: datetime('2026-10-04T12:00:00Z'), contentHash: 'synthetic:ch-r06', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:ch-r06-member-upload-p1'}) SET l += {id: 'ch-r06-member-upload-p1', artifactType: 'SourceLocator', privacyClass: 'PUBLIC', selectorKind: 'WHOLE_SNAPSHOT', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (src:Source {uid: 'hu:source:ch-r06-member-upload'}), (sn:SourceSnapshot {uid: 'hu:snapshot:ch-r06-member-upload'}), (l:SourceLocator {uid: 'hu:locator:ch-r06-member-upload-p1'}) MERGE (src)-[:HAS_SNAPSHOT]->(sn) MERGE (sn)-[:HAS_LOCATOR]->(l);
MERGE (o:Observation:InformationArtifact {uid: 'hu:observation:ch-r06-member-0001-hscrp-week4'}) SET o += {id: 'ch-r06-member-0001-hscrp-week4', artifactType: 'Observation', privacyClass: 'PUBLIC', resultKind: 'MEASURED', valueNumber: 2.9, unitCode: 'mg/L', valueStatus: 'REPORTED', observedAt: datetime('2026-09-30T08:00:00Z'), observedPopulation: 'protocol participant, self-reported', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r06-member-records'}) SET a += {predicate: 'RECORDS', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', speechAct: 'REPORTS_PRACTICE', assertionBasis: 'PERSONAL_EXPERIENCE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r06'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r06-member-records'}), (p:Person {uid: 'hu:person:ch-r06-member-0001'}), (o:Observation {uid: 'hu:observation:ch-r06-member-0001-hscrp-week4'}), (l:SourceLocator {uid: 'hu:locator:ch-r06-member-upload-p1'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(o) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (p)-[r:RECORDS {relationshipUid: 'hu:rel:ch-r06-records'}]->(o) SET r.assertionUid = a.uid, r.recordedFrom = a.recordedAt, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';
MATCH (o:Observation {uid: 'hu:observation:ch-r06-member-0001-hscrp-week4'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:blueprint-observed-2026-10-04'}), (av:AssayVersion {uid: 'hu:assay-version:synthetic-hscrp-lab-a-2025'})
MERGE (o)-[:ABOUT_PROTOCOL]->(e) MERGE (o)-[:PRODUCED_BY_ASSAY_VERSION]->(av);
// CH-R-06b: the member's executed steps written as a public ProtocolResult (execution log = "result of following the protocol").
MERGE (pr:ProtocolResult:InformationArtifact {uid: 'hu:protocol-result:ch-r06-member-0001-week4'}) SET pr += {id: 'ch-r06-member-0001-week4', artifactType: 'ProtocolResult', privacyClass: 'PUBLIC', resultSummary: 'Completed 26 of 28 days; skipped tadalafil twice; HBOT sessions 1-12 done at 9am', observedAt: datetime('2026-09-30T00:00:00Z'), createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r06-member-posts-result'}) SET a += {predicate: 'POSTS_RESULT', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', speechAct: 'REPORTS_PRACTICE', assertionBasis: 'PERSONAL_EXPERIENCE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r06b'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r06-member-posts-result'}), (p:Person {uid: 'hu:person:ch-r06-member-0001'}), (pr:ProtocolResult {uid: 'hu:protocol-result:ch-r06-member-0001-week4'}), (l:SourceLocator {uid: 'hu:locator:ch-r06-member-upload-p1'}), (o:Observation {uid: 'hu:observation:ch-r06-member-0001-hscrp-week4'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(pr) MERGE (a)-[:SUPPORTED_BY]->(l) MERGE (a)-[:ASSERTED_BY]->(p)
MERGE (p)-[r:POSTS_RESULT {relationshipUid: 'hu:rel:ch-r06-posts'}]->(pr) SET r.assertionUid = a.uid, r.recordedFrom = a.recordedAt, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN'
MERGE (pr)-[:INCLUDES_OBSERVATION]->(o);
// ---- UNDO (r06) ----
// CH-R-06 undo
MATCH (n) WHERE n.uid IN ['hu:person:ch-r06-member-0001', 'hu:source:ch-r06-member-upload', 'hu:snapshot:ch-r06-member-upload', 'hu:locator:ch-r06-member-upload-p1',
  'hu:observation:ch-r06-member-0001-hscrp-week4', 'hu:assertion:ch-r06-member-records', 'hu:protocol-result:ch-r06-member-0001-week4', 'hu:assertion:ch-r06-member-posts-result'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-07: observedPopulation naming a private individual; private-store keys on Observation (same base)
// Base: KEEP (base 08)
// ==============================================================================================================
// ---- MUTATION (r07) ----
// CH-R-07a: observedPopulation of a public Observation names a private individual (INV-506: private-personal property in the shared graph).
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}) SET o.observedPopulation = 'BellLabs member Jane Q. Doe (DOB 1983-04-02, Austin TX), week 4 of the protocol';
// CH-R-07b (held/not-held boundary): private-store linkage on a public Observation. hu:private- value (expected CAUGHT by V-521/V-521r)
// versus an opaque store key and a private-only property name (personalValueNumber) that V-534p checks only on Protocol/Edition/Step.
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2024'}) SET o.sourceMeasurementUid = 'hu:private-personal-measurement:synthetic-0001-hscrp';
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}) SET o.pcsMeasurementRef = 'pm_7f3a9c21e0', o.personalValueNumber = 2.9, o.userContextVersionRef = 'ucv_0001_v3';
// ---- UNDO (r07) ----
// CH-R-07 / CH-R-07b undo
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}) SET o.observedPopulation = 'protocol author, self-reported (SYNTHETIC values)' REMOVE o.pcsMeasurementRef, o.personalValueNumber, o.userContextVersionRef;
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2024'}) REMOVE o.sourceMeasurementUid;

// ==============================================================================================================
// CH-R-08: ABOUT_CONDITION derived from a threshold (same base)
// Base: KEEP (base 08)
// ==============================================================================================================
// ---- MUTATION (r08) ----
MERGE (c:Condition:Entity {uid: 'hu:condition:ch-r08-systemic-inflammation'}) SET c += {id: 'ch-r08-systemic-inflammation', entityType: 'Condition', privacyClass: 'PUBLIC', name: 'Systemic inflammation (CH fixture)', createdAt: datetime('2026-10-04T12:00:00Z')};
// CH-R-08a (control, expected CAUGHT by V-536p): ABOUT_CONDITION written by a threshold rule, no assertion.
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}), (c:Condition {uid: 'hu:condition:ch-r08-systemic-inflammation'})
MERGE (o)-[r:ABOUT_CONDITION {relationshipUid: 'hu:rel:ch-r08a'}]->(c) SET r.derivationRule = 'hscrp-gt-3-implies-inflammation', r.recordedFrom = datetime('2026-10-04T12:00:00Z');
// CH-R-08b: the same threshold derivation laundered through a CALCULATED Assertion whose predicate is ABOUT_CONDITION and whose only
// input is an OUTSIDE_REFERENCE_RANGE_TRIGGER assertion (catalog forbidden implication [OUTSIDE_REFERENCE_RANGE_TRIGGER, CONDITION_PRESENT]).
MERGE (t:Assertion {uid: 'hu:assertion:ch-r08-trigger'}) SET t += {predicate: 'OUTSIDE_REFERENCE_RANGE_TRIGGER', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', basisKind: 'CALCULATED', derivationRule: 'value-vs-interval', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r08t'};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r08-about-condition'}) SET a += {predicate: 'ABOUT_CONDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', basisKind: 'CALCULATED', derivationRule: 'hscrp-gt-3-implies-inflammation', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r08a'};
MATCH (t:Assertion {uid: 'hu:assertion:ch-r08-trigger'}), (a:Assertion {uid: 'hu:assertion:ch-r08-about-condition'}), (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}), (c:Condition {uid: 'hu:condition:ch-r08-systemic-inflammation'})
MERGE (t)-[:HAS_SUBJECT]->(o) MERGE (a)-[:HAS_SUBJECT]->(o) MERGE (a)-[:HAS_OBJECT]->(c) MERGE (a)-[:DERIVED_FROM_ASSERTION]->(t);
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2024'}), (c:Condition {uid: 'hu:condition:ch-r08-systemic-inflammation'}), (a:Assertion {uid: 'hu:assertion:ch-r08-about-condition'})
MERGE (o)-[r:ABOUT_CONDITION {relationshipUid: 'hu:rel:ch-r08b'}]->(c) SET r.assertionUid = a.uid, r.recordedFrom = a.recordedAt, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';
// CH-R-08c: note that CH-R-08b's edge starts at the 2024 Observation while the cited Assertion's subject is the 2025 Observation (subject mismatch).
// ---- UNDO (r08) ----
// CH-R-08 undo
MATCH (n) WHERE n.uid IN ['hu:condition:ch-r08-systemic-inflammation', 'hu:assertion:ch-r08-trigger', 'hu:assertion:ch-r08-about-condition'] DETACH DELETE n;
// ---- MUTATION (r08d) ----
// CH-R-08d: the laundering case isolated: subject/object match the edge, the CALCULATED ABOUT_CONDITION Assertion is source-supported and
// derived only from an OUTSIDE_REFERENCE_RANGE_TRIGGER Assertion (which itself carries a typed literal), so only the forbidden premise remains.
MERGE (c:Condition:Entity {uid: 'hu:condition:ch-r08-systemic-inflammation'}) SET c += {id: 'ch-r08-systemic-inflammation', entityType: 'Condition', privacyClass: 'PUBLIC', name: 'Systemic inflammation (CH fixture)', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (t:Assertion {uid: 'hu:assertion:ch-r08-trigger'}) SET t += {predicate: 'OUTSIDE_REFERENCE_RANGE_TRIGGER', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', basisKind: 'CALCULATED', derivationRule: 'value-vs-interval', valueBoolean: true, validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r08t'};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r08-about-condition'}) SET a += {predicate: 'ABOUT_CONDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', basisKind: 'CALCULATED', derivationRule: 'hscrp-gt-3-implies-inflammation', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r08a'};
MATCH (t:Assertion {uid: 'hu:assertion:ch-r08-trigger'}), (a:Assertion {uid: 'hu:assertion:ch-r08-about-condition'}), (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}), (c:Condition {uid: 'hu:condition:ch-r08-systemic-inflammation'}),
      (x:Assertion {uid: 'hu:assertion:synthetic-bj-records-hscrp-2025'})-[:SUPPORTED_BY]->(l:SourceLocator)
MERGE (t)-[:HAS_SUBJECT]->(o) MERGE (a)-[:HAS_SUBJECT]->(o) MERGE (a)-[:HAS_OBJECT]->(c) MERGE (a)-[:DERIVED_FROM_ASSERTION]->(t) MERGE (t)-[:SUPPORTED_BY]->(l) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (o)-[r:ABOUT_CONDITION {relationshipUid: 'hu:rel:ch-r08d'}]->(c) SET r.assertionUid = a.uid, r.recordedFrom = a.recordedAt, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN';
// ---- UNDO (r08d) ----
// CH-R-08d undo
MATCH (n) WHERE n.uid IN ['hu:condition:ch-r08-systemic-inflammation', 'hu:assertion:ch-r08-trigger', 'hu:assertion:ch-r08-about-condition'] DETACH DELETE n;

// ==============================================================================================================
// CH-R-12: COMPARED_TO across AssayVersions without a licensing assessment (same base)
// Base: KEEP (base 08)
// ==============================================================================================================
// ---- MUTATION (r12) ----
// CH-R-12a: COMPARED_TO between two public Observations produced by DIFFERENT AssayVersions with no ComparabilityAssessment
// (W07 INV-301 / V-302r). The final SDL makes Observation the DiagnosticResult implementer, but its stored labels are ["Observation","InformationArtifact"].
MATCH (a:Observation {uid: 'hu:observation:synthetic-hscrp-2024'}), (b:Observation {uid: 'hu:observation:synthetic-hscrp-2025'})
MERGE (a)-[r:COMPARED_TO]->(b) SET r.derivationRule = 'W07-same-metric-trend', r.derivedAt = datetime('2026-10-04T12:00:00Z');
// CH-R-12b: an Observation INDICATES_CONDITION without an assertion (V-309 is written on :DiagnosticResult as well).
MERGE (c:Condition:Entity {uid: 'hu:condition:ch-r12-systemic-inflammation'}) SET c += {id: 'ch-r12-systemic-inflammation', entityType: 'Condition', privacyClass: 'PUBLIC', name: 'Systemic inflammation (CH fixture)', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}), (c:Condition {uid: 'hu:condition:ch-r12-systemic-inflammation'}) MERGE (o)-[:INDICATES_CONDITION]->(c);
// ---- MUTATION (r12c) ----
// CH-R-12c (control): the same graph with the DiagnosticResult label the SDL interface implies; V-302/V-302r/V-309 then fire.
MATCH (o:Observation) WHERE o.uid IN ['hu:observation:synthetic-hscrp-2024', 'hu:observation:synthetic-hscrp-2025'] SET o:DiagnosticResult;
// ---- UNDO (r12c) ----
// CH-R-12c undo
MATCH (o:Observation:DiagnosticResult) REMOVE o:DiagnosticResult;
// ---- UNDO (r12: run after the r12c control) ----
// CH-R-12 undo
MATCH (:Observation)-[r:COMPARED_TO]->(:Observation) WHERE r.derivationRule = 'W07-same-metric-trend' DELETE r;
MATCH (c:Condition {uid: 'hu:condition:ch-r12-systemic-inflammation'}) DETACH DELETE c;
// ---- MUTATION (r12d) ----
// CH-R-12d: the cross-assay COMPARED_TO "licensed" by an assessment that says NOT_COMPARABLE. V-112r checks only that the cited assessment exists;
// V-302r (which checks verdict, currency and arity) never sees Observations because they do not carry the DiagnosticResult label.
MERGE (ca:ComparabilityAssessment:EvidenceAssessment {uid: 'hu:assessment:ch-r12d-hscrp-2024-vs-2025'}) SET ca += {id: 'ch-r12d-hscrp-2024-vs-2025', assessmentType: 'ComparabilityAssessment', methodVersion: 'CH-1', status: 'ACCEPTED', verdict: 'NOT_COMPARABLE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (ca:ComparabilityAssessment {uid: 'hu:assessment:ch-r12d-hscrp-2024-vs-2025'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-hscrp-lab-a-2024'}), (a2:AssayVersion {uid: 'hu:assay-version:synthetic-hscrp-lab-a-2025'}) MERGE (ca)-[:COMPARES]->(a1) MERGE (ca)-[:COMPARES]->(a2);
MATCH (a:Observation {uid: 'hu:observation:synthetic-hscrp-2024'}), (b:Observation {uid: 'hu:observation:synthetic-hscrp-2025'})
MERGE (a)-[r:COMPARED_TO]->(b) SET r.derivationRule = 'W07-same-metric-trend', r.derivedFromAssessmentUids = ['hu:assessment:ch-r12d-hscrp-2024-vs-2025'], r.derivedAt = datetime('2026-10-04T12:00:00Z');
// ---- UNDO (r12d) ----
// CH-R-12d undo
MATCH (ca:ComparabilityAssessment {uid: 'hu:assessment:ch-r12d-hscrp-2024-vs-2025'}) DETACH DELETE ca;
MATCH (:Observation)-[r:COMPARED_TO]->(:Observation) WHERE r.derivationRule = 'W07-same-metric-trend' DELETE r;

// ==============================================================================================================
// CH-R-16: W16 asserted edges missing from $assertedTypes (same base; run V-101 with and without the four types added)
// Base: KEEP (base 08)
// ==============================================================================================================
// ---- MUTATION (r15) ----
// CH-R-16: asserted W16 edges with no authorizing assertion: ABOUT_CONDITION, RECORDS, CLAIMS_OUTCOME written bare.
MERGE (c:Condition:Entity {uid: 'hu:condition:ch-r15'}) SET c += {id: 'ch-r15', entityType: 'Condition', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (o:Observation {uid: 'hu:observation:synthetic-hscrp-2025'}), (c:Condition {uid: 'hu:condition:ch-r15'}) MERGE (o)-[:ABOUT_CONDITION {relationshipUid: 'hu:rel:ch-r15-about'}]->(c);
// ---- UNDO (r15) ----
// CH-R-16 undo
MATCH (c:Condition {uid: 'hu:condition:ch-r15'}) DETACH DELETE c;

// ==============================================================================================================
// CH-R-09: Optional step counted as non-adherence; step without requirementLevel
// Base: workers/W16/fixtures/06-optional-step-no-nonadherence.cypher
// ==============================================================================================================
// ---- MUTATION (r09) ----
// CH-R-09a: the host's public statement "I skip the screen-free hour" (an OPTIONAL step) turned into a BellLabs non-adherence verdict:
// a CALCULATED Assertion asserted by a BellLabs agent plus its derived projection edge onto the public edition.
MERGE (ag:Agent:Entity {uid: 'hu:agent:ch-r09-bellabs-adherence-scorer'}) SET ag += {id: 'ch-r09-bellabs-adherence-scorer', entityType: 'Agent', privacyClass: 'INTERNAL', agentKind: 'SOFTWARE', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (a:Assertion {uid: 'hu:assertion:ch-r09-host-nonadherent'}) SET a += {predicate: 'NON_ADHERENT_TO_PROTOCOL_EDITION', status: 'ACCEPTED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T12:00:00Z'), privacyClass: 'PUBLIC', basisKind: 'CALCULATED', derivationRule: 'any-step-skipped-implies-nonadherence', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', contentHash: 'sha256:ch-r09'};
MATCH (a:Assertion {uid: 'hu:assertion:ch-r09-host-nonadherent'}), (p:Person {uid: 'hu:person:synthetic-podcast-host'}), (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}),
      (src:Assertion {uid: 'hu:assertion:synthetic-host-skips-screen-free-hour'}), (ag:Agent {uid: 'hu:agent:ch-r09-bellabs-adherence-scorer'})
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(e) MERGE (a)-[:DERIVED_FROM_ASSERTION]->(src) MERGE (a)-[:ASSERTED_BY]->(ag)
WITH a, p, e, src
MATCH (l:SourceLocator {uid: 'hu:locator:synthetic-sleep-podcast-12-q'}) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (p)-[r:DEVIATED_FROM]->(e) SET r.projectionOfAssertionUid = a.uid, r.derivationRule = a.derivationRule, r.derivedFromAssertionUids = [src.uid];
// CH-R-09b: a step with no requirementLevel/requirementBasis (GraphQL non-null; Community enforces nothing): readers default it to required.
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r09b-no-level'}) SET s += {id: 'ch-r09b-no-level', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'herbal-tea', payloadHash: 'sha256:09b', stepKind: 'INGEST', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}), (s:ProtocolStep {uid: 'hu:protocol-step:ch-r09b-no-level'}) MERGE (e)-[r:HAS_PROTOCOL_STEP]->(s) SET r.orderIndex = 3;
// CH-R-09 probe: a "non-adherent people" query.
MATCH (p:Person)-[r:DEVIATED_FROM]->(e:ProtocolEdition) RETURN p.uid AS readAsNonAdherent, e.uid AS edition, r.derivedFromAssertionUids AS from;
// ---- UNDO (r09) ----
// CH-R-09 undo
MATCH (n) WHERE n.uid IN ['hu:agent:ch-r09-bellabs-adherence-scorer', 'hu:assertion:ch-r09-host-nonadherent', 'hu:protocol-step:ch-r09b-no-level'] DETACH DELETE n;
MATCH (:Person {uid: 'hu:person:synthetic-podcast-host'})-[r:DEVIATED_FROM]->() DELETE r;

// ==============================================================================================================
// CH-R-11: HAS_PROTOCOL_STEP without orderIndex / duplicate orderIndex (same base)
// Base: KEEP (base 06)
// ==============================================================================================================
// ---- MUTATION (r11) ----
// CH-R-11a: HAS_PROTOCOL_STEP without orderIndex (D-004: structural edge with orderIndex; StepOrderProperties.orderIndex is nullable).
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r11-dim-lights'}) SET s += {id: 'ch-r11-dim-lights', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'dim-lights', payloadHash: 'sha256:11a', stepKind: 'OTHER', requirementLevel: 'RECOMMENDED', requirementBasis: 'STATED_BY_SOURCE', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}), (s:ProtocolStep {uid: 'hu:protocol-step:ch-r11-dim-lights'}) MERGE (e)-[:HAS_PROTOCOL_STEP]->(s);
// CH-R-11b: duplicate orderIndex inside one edition (fixed-bedtime moved to position 1, same as screen-free-hour; no CONCURRENT_WITH stated).
MATCH (:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})-[r:HAS_PROTOCOL_STEP]->(:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-fixed-bedtime-v1'}) SET r.orderIndex = 1;
// CH-R-11 probe: Q-W16-01-style ordered listing is now ambiguous (two steps at 1, one at null sorted last).
MATCH (:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})-[o:HAS_PROTOCOL_STEP]->(s) RETURN o.orderIndex AS orderIndex, s.stepKey AS stepKey ORDER BY o.orderIndex;
// ---- UNDO (r11) ----
// CH-R-11 undo
MATCH (s:ProtocolStep {uid: 'hu:protocol-step:ch-r11-dim-lights'}) DETACH DELETE s;
MATCH (:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'})-[r:HAS_PROTOCOL_STEP]->(:ProtocolStep {uid: 'hu:protocol-step:synthetic-wind-down-fixed-bedtime-v1'}) SET r.orderIndex = 2;

// ==============================================================================================================
// CH-R-13: D-004 drift: HAS_STEP on editions, migration writes Protocol-HAS_PROTOCOL_STEP, compiled V-525/V-526 on HAS_STEP (same base)
// Base: KEEP (base 06)
// ==============================================================================================================
// ---- MUTATION (r01) ----
// CH-R-13a: an edition whose steps hang off HAS_STEP (the 0.2.0 / translated-fixture spelling) instead of HAS_PROTOCOL_STEP (D-004),
// carrying a duplicated stepKey, a CONDITIONAL step without APPLIES_WHEN, and a 2-cycle of ordering dependencies.
MERGE (e:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:ch-r01-hasstep'}) SET e += {id: 'ch-r01-hasstep', stateType: 'ProtocolEdition', privacyClass: 'PUBLIC', editionLabel: 'CH-R-13', changeProvenance: 'SOURCE_VERSIONED', payloadHash: 'sha256:0000000000000000000000000000000000000000000000000000000000000101', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r01-a'}) SET s += {id: 'ch-r01-a', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'fixed-bedtime', payloadHash: 'sha256:01a', requirementLevel: 'CONDITIONAL', requirementBasis: 'STATED_BY_SOURCE', stepKind: 'SLEEP', createdAt: datetime('2026-10-04T12:00:00Z')};
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r01-b'}) SET s += {id: 'ch-r01-b', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'fixed-bedtime', payloadHash: 'sha256:01b', requirementLevel: 'ESSENTIAL', requirementBasis: 'STATED_BY_SOURCE', stepKind: 'SLEEP', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r01-hasstep'}), (a:ProtocolStep {uid: 'hu:protocol-step:ch-r01-a'}), (b:ProtocolStep {uid: 'hu:protocol-step:ch-r01-b'})
MERGE (e)-[r1:HAS_STEP]->(a) SET r1.orderIndex = 1 MERGE (e)-[r2:HAS_STEP]->(b) SET r2.orderIndex = 2;
MATCH (a:ProtocolStep {uid: 'hu:protocol-step:ch-r01-a'}), (b:ProtocolStep {uid: 'hu:protocol-step:ch-r01-b'})
MERGE (a)-[d1:DEPENDS_ON]->(b) SET d1.dependencyKind = 'REQUIRES_PRIOR_COMPLETION' MERGE (b)-[d2:DEPENDS_ON]->(a) SET d2.dependencyKind = 'REQUIRES_PRIOR_COMPLETION';
// CH-R-13b: a live-shaped Protocol -[:HAS_STEP]-> step, then the operations-file migration statement verbatim (section 6a).
MATCH (p:Protocol {uid: 'hu:protocol:synthetic-evening-wind-down'}), (s:ProtocolStep {uid: 'hu:protocol-step:ch-r01-b'}) MERGE (p)-[r:HAS_STEP]->(s) SET r.orderIndex = 7;
MATCH (a:Protocol)-[r:HAS_STEP]->(b:ProtocolStep) WHERE NOT EXISTS { (a)-[:HAS_PROTOCOL_STEP]->(b) }
CREATE (a)-[n:HAS_PROTOCOL_STEP]->(b) SET n = properties(r), n.orderIndex = coalesce(r.orderIndex, r.position, r.order) DELETE r;
// CH-R-13 probe: what the final GraphQL ProtocolEdition.steps (HAS_PROTOCOL_STEP) returns for the attacked edition, and edge census.
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:ch-r01-hasstep'}) RETURN e.uid AS edition, COUNT { (e)-[:HAS_PROTOCOL_STEP]->() } AS graphqlSteps, COUNT { (e)-[:HAS_STEP]->() } AS hiddenHasStep;
MATCH (a)-[r:HAS_PROTOCOL_STEP]->(b) WHERE NOT a:ProtocolEdition RETURN labels(a) AS wrongDomain, a.uid AS fromUid, b.uid AS toUid;
// ---- UNDO (r01) ----
// CH-R-13 undo
MATCH (n) WHERE n.uid IN ['hu:protocol-edition:ch-r01-hasstep', 'hu:protocol-step:ch-r01-a', 'hu:protocol-step:ch-r01-b'] DETACH DELETE n;
// ---- MUTATION (r01c) ----
// CH-R-13c: the same duplicated stepKey written correctly on HAS_PROTOCOL_STEP: the compiled validation.cypher V-525/V-526 (still on HAS_STEP) are blind.
MERGE (s:ProtocolStep:Entity {uid: 'hu:protocol-step:ch-r01c-dup'}) SET s += {id: 'ch-r01c-dup', entityType: 'ProtocolStep', privacyClass: 'PUBLIC', stepKey: 'fixed-bedtime', payloadHash: 'sha256:f420b40399c8c2559cb8b5db1473a80981feea83ad88d9fb30c3c54e745b6653', requirementLevel: 'ESSENTIAL', requirementBasis: 'STATED_BY_SOURCE', stepKind: 'SLEEP', createdAt: datetime('2026-10-04T12:00:00Z')};
MATCH (e:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-evening-wind-down-e1'}), (s:ProtocolStep {uid: 'hu:protocol-step:ch-r01c-dup'}) MERGE (e)-[r:HAS_PROTOCOL_STEP]->(s) SET r.orderIndex = 3;
// ---- UNDO (r01c) ----
// CH-R-13c undo
MATCH (n:ProtocolStep {uid: 'hu:protocol-step:ch-r01c-dup'}) DETACH DELETE n;

