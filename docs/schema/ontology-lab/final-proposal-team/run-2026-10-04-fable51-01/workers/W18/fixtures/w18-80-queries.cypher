// W18 queries (run after fixtures 01..04; expected rows in 06-fixtures-and-queries.md). Each statement is standalone.

// Q-EN-C01a (CQ-EN-C01, CQ-TM-03): Rezdiffra/resmetirom milestone timeline AS RECORDED AT R1 = 2026-10-04T04:30Z
// (before the EMA record was ingested). Occurrence claims visible at R1, the scheduled claims, the effective claims,
// and the announcement time computed from first-party snapshots (asserter is a participant of the event; advance
// scheduling statements count as announcements, rule announced-at-v1).
WITH datetime('2026-10-04T04:30:00Z') AS R
MATCH (e:Event)-[ab:EVENT_ABOUT]->(s)
WHERE s.uid IN ['hu:product:rezdiffra', 'hu:substance:resmetirom', 'hu:study:maestro-nash'] AND ab.recordedFrom <= R AND (ab.recordedTo IS NULL OR ab.recordedTo > R)
WITH DISTINCT e, R
OPTIONAL MATCH (o:Assertion {predicate: 'EVENT_OCCURRED'})-[:HAS_SUBJECT]->(e) WHERE o.recordedAt <= R AND (o.recordedTo IS NULL OR o.recordedTo > R)
OPTIONAL MATCH (o)-[:ASSERTED_BY]->(oa)
WITH e, R, collect(CASE WHEN o IS NULL THEN null ELSE toString(date(o.validFrom)) + ' ' + o.validFromPrecision + ' by ' + coalesce(oa.name, '?') END) AS occurred
OPTIONAL MATCH (sc:Assertion {predicate: 'EVENT_SCHEDULED'})-[:HAS_SUBJECT]->(e) WHERE sc.recordedAt <= R
WITH e, R, occurred, collect(CASE WHEN sc IS NULL THEN null ELSE toString(date(sc.validFrom)) + ' ' + sc.validFromPrecision END) AS scheduled
OPTIONAL MATCH (ef:Assertion {predicate: 'EVENT_EFFECTIVE'})-[:HAS_SUBJECT]->(e) WHERE ef.recordedAt <= R
WITH e, R, occurred, scheduled, collect(CASE WHEN ef IS NULL THEN null ELSE toString(date(ef.validFrom)) + ' ' + ef.validFromPrecision END) AS effective
OPTIONAL MATCH (fa:Assertion)-[:HAS_SUBJECT]->(e), (fa)-[:ASSERTED_BY]->(party)<-[:INVOLVES]-(e), (fa)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE fa.predicate IN ['EVENT_OCCURRED', 'EVENT_SCHEDULED'] AND fa.recordedAt <= R AND sn.publishedAt IS NOT NULL
WITH e, occurred, scheduled, effective, min(sn.publishedAt) AS announcedAtComputed
RETURN e.name AS event, e.eventCategory AS category, occurred, scheduled, effective, toString(date(announcedAtComputed)) AS announcedAt
ORDER BY coalesce(occurred[0], scheduled[0]);

// Q-EN-C01b (CQ-EN-C01): the same timeline AS RECORDED AT R2 = 2026-10-04T09:00Z (after the EMA record arrived).
WITH datetime('2026-10-04T09:00:00Z') AS R
MATCH (e:Event)-[ab:EVENT_ABOUT]->(s)
WHERE s.uid IN ['hu:product:rezdiffra', 'hu:substance:resmetirom', 'hu:study:maestro-nash'] AND ab.recordedFrom <= R AND (ab.recordedTo IS NULL OR ab.recordedTo > R)
WITH DISTINCT e, R
OPTIONAL MATCH (o:Assertion {predicate: 'EVENT_OCCURRED'})-[:HAS_SUBJECT]->(e) WHERE o.recordedAt <= R AND (o.recordedTo IS NULL OR o.recordedTo > R)
OPTIONAL MATCH (o)-[:ASSERTED_BY]->(oa)
WITH e, R, collect(CASE WHEN o IS NULL THEN null ELSE toString(date(o.validFrom)) + ' ' + o.validFromPrecision + ' by ' + coalesce(oa.name, '?') END) AS occurred
OPTIONAL MATCH (ef:Assertion {predicate: 'EVENT_EFFECTIVE'})-[:HAS_SUBJECT]->(e) WHERE ef.recordedAt <= R
WITH e, occurred, collect(CASE WHEN ef IS NULL THEN null ELSE toString(date(ef.validFrom)) + ' ' + ef.validFromPrecision END) AS effective
RETURN e.name AS event, occurred, effective, toString(date(e.startedAt)) + ' ' + e.startedAtPrecision AS materializedStart,
       toString(date(e.announcedAt)) AS materializedAnnounced, toString(date(e.effectiveFrom)) AS materializedEffective
ORDER BY e.startedAt;

// Q-EN-C02 (CQ-EN-C02, CQ-TM-03): for each regulatory/launch milestone, happened vs announced vs effective vs the
// authoritative record, with the recorded and retrieval clocks of the licensing assertion.
MATCH (e:Event) WHERE e.eventType IN ['APPROVAL', 'CONDITIONAL_APPROVAL', 'LAUNCH']
OPTIONAL MATCH (e)-[:DOCUMENTED_BY_RECORD]->(rec)
OPTIONAL MATCH (ta:Assertion {uid: e.timeAssertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
OPTIONAL MATCH (an:Assertion {uid: e.announcementAssertionUid})
OPTIONAL MATCH (oc:Assertion {predicate: 'EVENT_OCCURRED'})-[:HAS_SUBJECT]->(e)
OPTIONAL MATCH (oc)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(osn:SourceSnapshot) WHERE osn.publishedAt IS NOT NULL
WITH e, rec, ta, sn, an, min(osn.publishedAt) AS firstReportedAt
RETURN e.name AS event, e.jurisdiction AS jurisdiction,
       toString(date(e.startedAt)) + ' ' + e.startedAtPrecision AS happened,
       toString(date(e.announcedAt)) + ' (' + an.predicate + ')' AS announced, toString(date(firstReportedAt)) AS firstReportedAsHappened,
       toString(date(e.effectiveFrom)) AS effective,
       rec.uid AS record, toString(date(rec.issuedAt)) AS recordIssuedAt,
       toString(ta.recordedAt) AS timeRecordedAt, toString(sn.retrievedAt) AS timeSourceRetrievedAt
ORDER BY e.startedAt;

// Q-EN-C03a (CQ-EN-C03): which events are claimed to cause which, by whom, on what basis, how captured, whether support was
// ever assessed, and which effects have competing causal claims.
MATCH (eff:Event)-[c:CAUSED_BY]->(cause:Event)
MATCH (a:Assertion {uid: c.assertionUid})-[:SUPPORTED_BY]->(l:SourceLocator)
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (cf:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a)
OPTIONAL MATCH (sp:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
WITH eff, cause, c, a, l, who, cf, sp, COUNT { (eff)-[:CAUSED_BY]->(:Event) } AS causesClaimedForEffect
RETURN eff.name AS effect, cause.name AS cause, who.name AS asserter, c.basisKind AS basisKind, c.speechAct AS speechAct,
       l.exact AS quote, a.status AS captureStatus, cf.verdict AS captureVerdict, coalesce(sp.verdict, 'NOT_ASSESSED') AS supportVerdict,
       causesClaimedForEffect
ORDER BY effect, cause;

// Q-EN-C03b (CQ-EN-C03 minimal pair): ordered pairs with no causal claim. Order is reported, never promoted to cause.
MATCH (a:Event)-[f:FOLLOWED_BY]->(b:Event)
RETURN a.name AS earlier, b.name AS later, coalesce(f.derivationRule, 'source-stated order: ' + f.projectionOfAssertionUid) AS orderBasis,
       EXISTS { (b)-[:CAUSED_BY]->(a) } AS hasCausalClaim
ORDER BY a.startedAt, b.startedAt;

// Q-EN-C04a (CQ-EN-C04, CQ-CL-01): sessions of a conference edition with presenting company, speakers (role at the event),
// recordings (and whether any captured rendition says the recording is unavailable) and presented decks.
MATCH (conf:Conference {uid: 'hu:conference:jpm-healthcare-2026'})-[:HAS_EVENT]->(s:Event)
OPTIONAL MATCH (s)-[pi:INVOLVES {participantRole: 'PRESENTER'}]->(org)
OPTIONAL MATCH (p:Person)-[sa:SPEAKS_AT]->(s)
WITH conf, s, collect(DISTINCT org.name) AS presenters, collect(DISTINCT p.name + ' (' + sa.participantRole + ': ' + coalesce(sa.roleTitleVerbatim, '') + ')') AS speakers
OPTIONAL MATCH (ep:Episode)-[ro:RECORDING_OF]->(s)
OPTIONAL MATCH (ep)<-[:RENDITION_OF]-(:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(gone:SourceLocator) WHERE gone.exact CONTAINS 'not available'
WITH conf, s, presenters, speakers, collect(DISTINCT ep.uid + ' coverage=' + ro.recordingCoverage + CASE WHEN gone IS NULL THEN '' ELSE ' [capture: recording unavailable]' END) AS recordings
OPTIONAL MATCH (d:Document)-[:PRESENTED_AT]->(s)
OPTIONAL MATCH (conf)<-[:HOSTS_EVENT]-(host)
RETURN conf.name AS conference, s.name AS session, toString(s.startedAt) AS startedAtUtc, presenters, speakers, recordings,
       collect(DISTINCT d.title) AS decks, collect(DISTINCT host.name) AS hosts
ORDER BY startedAtUtc;

// Q-EN-C04b (CQ-EN-C04, sponsorship vs endorsement): who hosts, sponsors and exhibits at a conference; endorsement edges
// that exist for the sponsor's products (must come only from ENDORSES_PRODUCT assertions; none here).
MATCH (conf:Conference {uid: 'hu:conference:aasld-tlm-2026'})
OPTIONAL MATCH (h)-[:HOSTS_EVENT]->(conf)
OPTIONAL MATCH (sp)-[s:SPONSORS_CONTENT]->(conf)
OPTIONAL MATCH (ex)-[:EXHIBITS_AT]->(conf)
WITH conf, collect(DISTINCT h.name) AS hosts, collect(DISTINCT sp.name + ' [' + coalesce(s.roleTitleVerbatim, '') + ']') AS sponsors, collect(DISTINCT ex.name) AS exhibitors
OPTIONAL MATCH (hh)-[:HOSTS_EVENT]->(conf) OPTIONAL MATCH (hh)-[en:ENDORSES_PRODUCT]->(prod)
RETURN conf.name AS conference, hosts, sponsors, exhibitors, count(en) AS hostEndorsementEdges,
       EXISTS { MATCH (:Publication {uid: 'hu:publication:pmid-39422487'}) } AS separateGuidancePublicationPresent;

// Q-EN-C05 (CQ-EN-C05, CQ-PV-01): which narrative arc version was current AS RECORDED AT R, which events it cites, and
// that nothing uses an arc as support, warrant or derivation input.
UNWIND [datetime('2026-10-04T05:00:00Z'), datetime('2026-10-04T09:00:00Z')] AS R
MATCH (arc:NarrativeArc)-[:ARC_ABOUT]->(:Product {uid: 'hu:product:rezdiffra'})
WHERE arc.recordedAt <= R AND (arc.recordedTo IS NULL OR arc.recordedTo > R)
MATCH (arc)-[i:ARC_INCLUDES_EVENT]->(e:Event)
WITH R, arc, e ORDER BY i.orderIndex
WITH R, arc, collect(e.name) AS events
RETURN toString(R) AS asRecordedAt, arc.uid AS arc, arc.methodVersion AS method, toString(arc.eventsRecordedAsOf) AS eventsRecordedAsOf, events,
       COUNT { (arc)<-[:SUPPORTED_BY|CONSIDERS_ASSESSMENT]-() } AS usedAsSupportOrWarrant, arc.overallScore AS score;

// Q-EN-C06 (CQ-EN-C06): impact judgments of one event, by subject, with method and evidence locator; no event-level impact field.
MATCH (ia:EventImpactAssessment)-[:ASSESSES_EVENT]->(e:Event {uid: 'hu:event:maestro-nash-topline-2022-12-19'})
OPTIONAL MATCH (ia)-[:IMPACT_ON]->(subj)
OPTIONAL MATCH (ia)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN e.name AS event, subj.name AS impactOn, ia.impactDomain AS domain, ia.impactLevel AS level, ia.methodVersion AS method,
       ia.status AS status, l.exact AS evidenceQuote, e.impactLevel AS legacyEventField
ORDER BY impactOn;

// Q-PV-01-event (CQ-PV-01): the five provenance states for the EU authorisation time: who said it, which captured span,
// which assessment warrants a broader conclusion (none; arcs excluded), which activity used it, which policy (not modelled here).
MATCH (e:Event {uid: 'hu:event:rezdiffra-eu-conditional-authorisation'})<-[:HAS_SUBJECT]-(a:Assertion)
WHERE a.predicate IN ['EVENT_OCCURRED', 'EVENT_EFFECTIVE']
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(who)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (warrant:EvidenceAssessment)-[:EVALUATES|SUPPORTED_BY]->(a) WHERE NOT warrant:NarrativeArc
OPTIONAL MATCH (act:Activity)-[:USED]->(a)
RETURN a.predicate AS predicate, who.name AS saidBy, l.exact AS span, src.canonicalUri AS source, sn.captureCompleteness AS capture,
       toString(sn.retrievedAt) AS retrievedAt, toString(a.recordedAt) AS recordedAt, warrant.uid AS warrant, act.uid AS usedBy
ORDER BY a.recordedAt, predicate;

// Q-MISSING (missing facts stay unknown): conference host not asserted although the name contains a bank; a session
// without a stated speaker; an event with unknown time.
MATCH (x) WHERE x.uid IN ['hu:conference:jpm-healthcare-2026', 'hu:event:madrigal-jpm-2026-presentation', 'hu:event:viking-nash-trial-result-unspecified']
RETURN x.uid AS uid,
       CASE WHEN x:Conference THEN COUNT { (x)<-[:HOSTS_EVENT]-() } END AS hostEdges,
       CASE WHEN x:Event THEN COUNT { (x)<-[:SPEAKS_AT]-() } END AS speakerEdges,
       CASE WHEN x:Event THEN x.startedAt END AS startedAt, x.startedAtBasis AS startBasis, x.eventStatus AS status
ORDER BY uid;
