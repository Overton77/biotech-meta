// =====================================================================================================================
// W05 fixture 05: one practice concept (Lifestyle "sauna bathing"), two occurrences in one SYNTHETIC episode:
//  O1 guest: "I use the sauna four times a week, about 20 minutes at 80 degrees."  speechAct REPORTS_PRACTICE,
//     assertionBasis PERSONAL_EXPERIENCE, predicate SELF_REPORTED_PRACTICE (candidate; mirrors registered
//     SELF_REPORTED_DAILY_INTAKE).
//  O2 host:  "Everyone should get into a sauna at least four times a week."  speechAct RECOMMENDS, predicate
//     RECOMMENDS (registered relationship name; subject host, object practice, as in recommendation-snapshot.cypher).
//  Only O2 projects a derived Person-[:RECOMMENDS]->Lifestyle edge (W21-owned; V-423 property assertionUid, CL-016).
//  O1 projects nothing about recommendation (forbidden implication REPORTS_PRACTICE -> RECOMMENDS).
//  A separate Exposure characterizes the practice as an exposure (EXTERNAL_PHYSICAL, BEHAVIORAL_PRACTICE) from the
//  guest's report; it is a reusable characterization, NOT the guest's personal exposure history.
// All people, the episode and quotes are SYNTHETIC. Every statement binds its own nodes by uid.
// =====================================================================================================================

MERGE (l:Lifestyle:Entity {uid: 'hu:lifestyle:sauna-bathing'})
SET l.id = 'sauna-bathing', l.entityType = 'Lifestyle', l.name = 'Sauna bathing', l.lifestyleDomain = 'thermal', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC';

MERGE (p:Person:Entity {uid: 'hu:person:synthetic-guest-w05'})
SET p.entityType = 'Person', p.name = 'Synthetic Guest (W05 fixture)', p.createdAt = datetime('2026-10-04T02:00:00Z'), p.privacyClass = 'PUBLIC';

MERGE (p:Person:Entity {uid: 'hu:person:synthetic-host-w05'})
SET p.entityType = 'Person', p.name = 'Synthetic Host (W05 fixture)', p.createdAt = datetime('2026-10-04T02:00:00Z'), p.privacyClass = 'PUBLIC';

MERGE (e:Episode:Entity {uid: 'hu:episode:synthetic-w05-sauna-episode'})
SET e.entityType = 'Episode', e.title = 'Synthetic episode on heat practices', e.publishedAt = datetime('2026-09-01T00:00:00Z'), e.createdAt = datetime('2026-10-04T02:00:00Z'), e.privacyClass = 'PUBLIC';

MERGE (s:Source:Entity {uid: 'hu:source:synthetic-w05-sauna-transcript'})
SET s.entityType = 'Source', s.canonicalUri = 'https://podcast.example.invalid/heat/transcript', s.sourceKind = 'PODCAST_TRANSCRIPT_PAGE', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:synthetic-w05-sauna-transcript'}), (ep:Episode {uid: 'hu:episode:synthetic-w05-sauna-episode'})
MERGE (s)-[:RENDITION_OF]->(ep)
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w05-sauna-transcript-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T02:00:00Z'), sn.observedAt = datetime('2026-10-04T02:00:00Z'),
    sn.contentHash = 'synthetic:hu:snapshot:synthetic-w05-sauna-transcript-2026-10-04', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE',
    sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w05-sauna-transcript-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w05-guest-practice'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'I use the sauna four times a week, about 20 minutes at 80 degrees.', l.quoteHash = 'sha256:46481897702769321b7d205af83cf9aaa8332c2a07e5df8358f79e0fe08c28a7', l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w05-sauna-transcript-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w05-host-recommendation'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'TEXT_QUOTE',
    l.exact = 'Everyone should get into a sauna at least four times a week.', l.quoteHash = 'sha256:6e999d644c67426a2eef0297e13f7a741fc4a1455a9b3c3ed84ab10c8434ff43', l.normalizationVersion = 'NFC-WS1', l.fixtureProvenance = 'SYNTHETIC', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

// O1: practice report.
MATCH (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'}), (p:Person {uid: 'hu:person:synthetic-guest-w05'}), (e:Episode {uid: 'hu:episode:synthetic-w05-sauna-episode'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-w05-guest-practice'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-w05-guest-reports-sauna'})
SET a.predicate = 'SELF_REPORTED_PRACTICE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'PERSONAL_EXPERIENCE', a.speechAct = 'REPORTS_PRACTICE',
    a.valueString = '4 per week; about 20 min; 80 degrees', a.utteranceText = l.exact, a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC',
    a.contentHash = 'synthetic:hu:claim-occurrence:synthetic-w05-guest-reports-sauna'
MERGE (a)-[:HAS_SUBJECT]->(lf) MERGE (a)-[:ASSERTED_BY]->(p) MERGE (a)-[:OCCURS_IN]->(e) MERGE (a)-[:SUPPORTED_BY]->(l);

// O2: recommendation (shape of the baseline recommendation-snapshot fixture: predicate RECOMMENDS, subject the
// recommender, object the recommended practice, so V-112 sees the cited predicate equal to the projected edge type).
// No literal: an assertion has one object OR one literal (V-003); the frequency stays in utteranceText.
MATCH (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'}), (p:Person {uid: 'hu:person:synthetic-host-w05'}), (e:Episode {uid: 'hu:episode:synthetic-w05-sauna-episode'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-w05-host-recommendation'})
MERGE (a:Assertion:ClaimOccurrence {uid: 'hu:claim-occurrence:synthetic-w05-host-recommends-sauna'})
SET a.predicate = 'RECOMMENDS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.assertionBasis = 'EXPERT_OPINION', a.speechAct = 'RECOMMENDS',
    a.utteranceText = l.exact, a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC',
    a.contentHash = 'synthetic:hu:claim-occurrence:synthetic-w05-host-recommends-sauna'
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(lf) MERGE (a)-[:ASSERTED_BY]->(p) MERGE (a)-[:OCCURS_IN]->(e) MERGE (a)-[:SUPPORTED_BY]->(l);

// Projection of O2 only (W21-owned RECOMMENDS; V-423 and CL-016 read assertionUid).
MATCH (p:Person {uid: 'hu:person:synthetic-host-w05'}), (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'})
MERGE (p)-[r:RECOMMENDS]->(lf)
SET r.assertionUid = 'hu:claim-occurrence:synthetic-w05-host-recommends-sauna', r.relationshipUid = 'hu:rel:synthetic-host-recommends-sauna',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

// Characterized exposure of the practice as reported (reusable characterization; not the guest's history).
MATCH (lf:Lifestyle {uid: 'hu:lifestyle:sauna-bathing'})
MERGE (x:Exposure:Entity {uid: 'hu:exposure:sauna-80c-20min-4-per-week'})
SET x.id = 'sauna-80c-20min-4-per-week', x.entityType = 'Exposure', x.name = 'Sauna bathing, about 80 degrees, about 20 minutes, 4 sessions per week', x.setting = 'BEHAVIORAL_PRACTICE',
    x.route = 'EXTERNAL_PHYSICAL', x.mediumText = 'hot air (sauna)', x.durationCategory = 'NOT_STATED', x.durationIso = 'PT20M',
    x.durationText = 'about 20 minutes per session', x.frequencyText = 'four times a week', x.intensityValue = NULL, x.intensityUnitCode = NULL,
    x.intensityBasis = NULL, x.intensityText = 'about 80 degrees (unit not stated; no ExposureBasis value fits an ambient physical level, W05-SR-07)',
    x.characterizationHash = 'sha256:synthetic-exposure-tuple-sauna', x.createdAt = datetime('2026-10-04T02:00:00Z'), x.privacyClass = 'PUBLIC'
MERGE (x)-[r:HAS_EXPOSURE_AGENT]->(lf)
SET r.orderIndex = 0;
