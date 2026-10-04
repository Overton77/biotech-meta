// =====================================================================================================
// W18 operations (recommendation): events_and_narrative. Neo4j 5.26 Community unless marked [ENTERPRISE].
// Part A: uniqueness constraints (Community-supported). Part B: indexes (range, fulltext on stored names).
// Part C: W18 validators W18-V01..W18-V13 (zero rows = valid). Statements are independent; no variable crosses ';'.
// Every statement is idempotent (IF NOT EXISTS). Run order: A, B, then load data, then C.
// =====================================================================================================

// ---------------- Part A: uniqueness ----------------
CREATE CONSTRAINT w18_event_uid IF NOT EXISTS FOR (n:Event) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w18_event_id IF NOT EXISTS FOR (n:Event) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w18_conference_uid IF NOT EXISTS FOR (n:Conference) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w18_conference_id IF NOT EXISTS FOR (n:Conference) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w18_community_uid IF NOT EXISTS FOR (n:Community) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w18_community_id IF NOT EXISTS FOR (n:Community) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w18_narrative_arc_uid IF NOT EXISTS FOR (n:NarrativeArc) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w18_narrative_arc_id IF NOT EXISTS FOR (n:NarrativeArc) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w18_event_impact_uid IF NOT EXISTS FOR (n:EventImpactAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w18_event_impact_id IF NOT EXISTS FOR (n:EventImpactAssessment) REQUIRE n.id IS UNIQUE;
// relationshipUid uniqueness on the asserted edge types W18 owns (relationship property uniqueness, Neo4j >= 5.7)
CREATE CONSTRAINT w18_caused_by_reluid IF NOT EXISTS FOR ()-[r:CAUSED_BY]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_involves_reluid IF NOT EXISTS FOR ()-[r:INVOLVES]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_event_about_reluid IF NOT EXISTS FOR ()-[r:EVENT_ABOUT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_hosts_event_reluid IF NOT EXISTS FOR ()-[r:HOSTS_EVENT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_speaks_at_reluid IF NOT EXISTS FOR ()-[r:SPEAKS_AT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_attends_reluid IF NOT EXISTS FOR ()-[r:ATTENDS]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_exhibits_at_reluid IF NOT EXISTS FOR ()-[r:EXHIBITS_AT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_recording_of_reluid IF NOT EXISTS FOR ()-[r:RECORDING_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_presented_at_reluid IF NOT EXISTS FOR ()-[r:PRESENTED_AT]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w18_documented_by_record_reluid IF NOT EXISTS FOR ()-[r:DOCUMENTED_BY_RECORD]-() REQUIRE r.relationshipUid IS UNIQUE;
// [ENTERPRISE] existence/type constraints (rejected on Community; listed for the deployed edition):
// CREATE CONSTRAINT w18_event_occtype IF NOT EXISTS FOR (n:Event) REQUIRE n.occurrenceType IS NOT NULL;
// CREATE CONSTRAINT w18_arc_method IF NOT EXISTS FOR (n:NarrativeArc) REQUIRE n.methodVersion IS NOT NULL;
// CREATE CONSTRAINT w18_impact_method IF NOT EXISTS FOR (n:EventImpactAssessment) REQUIRE n.methodVersion IS NOT NULL;
// CREATE CONSTRAINT w18_caused_by_basis IF NOT EXISTS FOR ()-[r:CAUSED_BY]-() REQUIRE r.basisKind IS NOT NULL;
// CREATE CONSTRAINT w18_caused_by_assertion IF NOT EXISTS FOR ()-[r:CAUSED_BY]-() REQUIRE r.assertionUid IS NOT NULL;

// ---------------- Part B: indexes ----------------
CREATE INDEX w18_event_started IF NOT EXISTS FOR (n:Event) ON (n.startedAt);
CREATE INDEX w18_event_announced IF NOT EXISTS FOR (n:Event) ON (n.announcedAt);
CREATE INDEX w18_event_effective IF NOT EXISTS FOR (n:Event) ON (n.effectiveFrom);
CREATE INDEX w18_event_category IF NOT EXISTS FOR (n:Event) ON (n.eventCategory, n.eventType);
CREATE INDEX w18_conference_start IF NOT EXISTS FOR (n:Conference) ON (n.startDate);
CREATE INDEX w18_arc_recorded IF NOT EXISTS FOR (n:NarrativeArc) ON (n.recordedAt);
CREATE INDEX w18_caused_by_assertion IF NOT EXISTS FOR ()-[r:CAUSED_BY]-() ON (r.assertionUid);
CREATE INDEX w18_assertion_predicate_recorded IF NOT EXISTS FOR (a:Assertion) ON (a.predicate, a.recordedAt);
// Fulltext on STORED property names (D-015); names and fields equal the @fulltext directives in the fragment.
CREATE FULLTEXT INDEX EventSearch IF NOT EXISTS FOR (n:Event) ON EACH [n.name, n.description, n.summaryText];
CREATE FULLTEXT INDEX NarrativeArcSearch IF NOT EXISTS FOR (n:NarrativeArc) ON EACH [n.name, n.description, n.themeSummary, n.searchText];

// ---------------- Part C: validators (zero rows = valid) ----------------

// W18-V01: a CAUSED_BY edge is the projection of exactly one CAUSED_BY assertion that names its epistemic basis.
// Bare temporal order (a derivation rule), a cited assertion of another predicate, or a missing basisKind fail.
MATCH (eff)-[r:CAUSED_BY]->(cause)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH eff, cause, r, a,
     [v IN [
       CASE WHEN r.assertionUid IS NULL THEN 'NO_ASSERTION_UID' END,
       CASE WHEN r.derivationRule IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL THEN 'DERIVED_PROPERTIES_ON_ASSERTED_EDGE' END,
       CASE WHEN r.assertionUid IS NOT NULL AND a IS NULL THEN 'CITED_ASSERTION_MISSING' END,
       CASE WHEN a IS NOT NULL AND a.predicate <> 'CAUSED_BY' THEN 'CITED_PREDICATE_NOT_CAUSED_BY' END,
       CASE WHEN a IS NOT NULL AND a.predicate = 'CAUSED_BY' AND a.basisKind IS NULL THEN 'ASSERTION_WITHOUT_BASIS_KIND' END,
       CASE WHEN r.basisKind IS NULL THEN 'EDGE_WITHOUT_BASIS_KIND' END,
       CASE WHEN a IS NOT NULL AND r.basisKind IS NOT NULL AND a.basisKind IS NOT NULL AND a.basisKind <> r.basisKind THEN 'EDGE_BASIS_DIFFERS' END,
       CASE WHEN a IS NOT NULL AND coalesce(a.polarity, 'POSITIVE') <> 'POSITIVE' THEN 'NON_POSITIVE_ASSERTION_PROJECTED' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(eff) } THEN 'SUBJECT_IS_NOT_EFFECT' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(cause) } THEN 'OBJECT_IS_NOT_CAUSE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN eff.uid AS effectUid, cause.uid AS causeUid, r.relationshipUid AS relUid, violations;

// W18-V02: CAUSED_BY and FOLLOWED_BY have Event endpoints only; HAS_EVENT starts at a Conference;
// ARC_INCLUDES_EVENT starts at a NarrativeArc (one relationship type, one meaning).
MATCH (x)-[r:CAUSED_BY|FOLLOWED_BY|HAS_EVENT|ARC_INCLUDES_EVENT|RECORDING_OF|PRESENTED_AT|SPEAKS_AT]->(y)
WITH x, r, y,
     CASE type(r)
       WHEN 'CAUSED_BY' THEN x:Event AND y:Event
       WHEN 'FOLLOWED_BY' THEN x:Event AND y:Event
       WHEN 'HAS_EVENT' THEN x:Conference AND y:Event
       WHEN 'ARC_INCLUDES_EVENT' THEN x:NarrativeArc AND y:Event
       WHEN 'RECORDING_OF' THEN x:Episode AND y:Event
       WHEN 'PRESENTED_AT' THEN x:Document AND y:Event
       WHEN 'SPEAKS_AT' THEN x:Person AND y:Event
     END AS ok
WHERE NOT ok
RETURN type(r) AS relType, x.uid AS fromUid, labels(x) AS fromLabels, y.uid AS toUid, labels(y) AS toLabels;

// W18-V03: a NarrativeArc is never a source, a warrant or a derivation input, and carries no score.
CALL {
  MATCH (arc:NarrativeArc)<-[r:SUPPORTED_BY|CONTRADICTED_BY|CONSIDERS_ASSESSMENT|DERIVED_FROM_ASSERTION|EVALUATES]-(x)
  RETURN arc.uid AS arcUid, type(r) + ' FROM ' + coalesce(x.uid, '?') AS violation
  UNION
  MATCH ()-[r]->() WHERE type(r) <> 'ARC_INCLUDES_EVENT' AND r.derivedFromAssessmentUids IS NOT NULL
  UNWIND r.derivedFromAssessmentUids AS u
  MATCH (arc:NarrativeArc {uid: u})
  RETURN arc.uid AS arcUid, 'DERIVATION_INPUT_OF ' + type(r) AS violation
  UNION
  MATCH (arc:NarrativeArc) WHERE arc.overallScore IS NOT NULL OR arc.confidence IS NOT NULL OR arc.verdict IS NOT NULL
  RETURN arc.uid AS arcUid, 'ARC_CARRIES_SCORE_OR_VERDICT' AS violation
  UNION
  MATCH (arc:NarrativeArc) WHERE arc.methodVersion IS NULL OR arc.eventsRecordedAsOf IS NULL OR coalesce(arc.assessmentType, '') <> 'NARRATIVE_ARC'
  RETURN arc.uid AS arcUid, 'ARC_WITHOUT_METHOD_VIEWPOINT_OR_TYPE' AS violation
}
RETURN arcUid, collect(violation) AS violations;

// W18-V04: materialized event clocks are licensed by the assertion they name; effectiveFrom never proxies announcedAt.
MATCH (e:Event)
OPTIONAL MATCH (ta:Assertion {uid: e.timeAssertionUid})
OPTIONAL MATCH (ea:Assertion {uid: e.effectiveAssertionUid})
WITH e, ta, ea,
     [v IN [
       CASE WHEN e.startedAt IS NOT NULL AND ta IS NULL THEN 'START_WITHOUT_TIME_ASSERTION' END,
       CASE WHEN ta IS NOT NULL AND NOT ta.predicate IN ['EVENT_OCCURRED', 'EVENT_SCHEDULED'] THEN 'TIME_ASSERTION_WRONG_PREDICATE' END,
       CASE WHEN ta IS NOT NULL AND NOT EXISTS { MATCH (ta)-[:HAS_SUBJECT]->(e) } THEN 'TIME_ASSERTION_ABOUT_ANOTHER_EVENT' END,
       CASE WHEN ta IS NOT NULL AND e.startedAt IS NOT NULL AND (ta.validFrom IS NULL OR ta.validFrom <> e.startedAt) THEN 'START_NOT_LICENSED' END,
       CASE WHEN e.effectiveFrom IS NOT NULL AND (ea IS NULL OR ea.predicate <> 'EVENT_EFFECTIVE' OR ea.validFrom <> e.effectiveFrom) THEN 'EFFECTIVE_NOT_LICENSED' END,
       CASE WHEN e.effectiveFromBasis = 'PUBLICATION_PROXY' THEN 'EFFECTIVE_FROM_PUBLICATION_PROXY' END,
       CASE WHEN e.announcedAt IS NOT NULL AND e.announcementAssertionUid IS NULL THEN 'ANNOUNCED_WITHOUT_ASSERTION' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN e.uid AS eventUid, violations;

// W18-V05: no endorsement edge may be derived from, or cite, sponsorship, hosting, exhibiting, speaking or attending.
MATCH (p)-[e:ENDORSES_PRODUCT]->(x)
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN coalesce(e.derivedFromAssertionUids, []) + [coalesce(e.assertionUid, e.projectionOfAssertionUid)]
WITH p, e, x, collect(a.predicate) AS premises
WHERE e.derivationRule IS NOT NULL
   OR any(q IN premises WHERE q IN ['SPONSORS_CONTENT', 'HOSTS_EVENT', 'EXHIBITS_AT', 'SPEAKS_AT', 'ATTENDS', 'INVOLVES', 'PRESENTED_AT'])
RETURN p.uid AS endorserUid, x.uid AS endorsedUid, e.derivationRule AS rule, premises;

// W18-V06: a document PRESENTED_AT an event is never a rendition of a recording of that event (CL-003 R4).
MATCH (d:Document)-[:PRESENTED_AT]->(ev:Event)<-[:RECORDING_OF]-(ep:Episode)
WHERE (d)-[:RENDITION_OF]->(ep)
RETURN d.uid AS documentUid, ep.uid AS episodeUid, ev.uid AS eventUid;

// W18-V07: every non-null event time carries its precision (and basis for valid time); no sentinel dates.
MATCH (e:Event)
WITH e, [v IN [
  CASE WHEN e.startedAt IS NOT NULL AND (e.startedAtPrecision IS NULL OR e.startedAtBasis IS NULL) THEN 'STARTED_AT_WITHOUT_PRECISION_OR_BASIS' END,
  CASE WHEN e.endedAt IS NOT NULL AND (e.endedAtPrecision IS NULL OR e.endedAtBasis IS NULL) THEN 'ENDED_AT_WITHOUT_PRECISION_OR_BASIS' END,
  CASE WHEN e.announcedAt IS NOT NULL AND e.announcedAtPrecision IS NULL THEN 'ANNOUNCED_AT_WITHOUT_PRECISION' END,
  CASE WHEN e.effectiveFrom IS NOT NULL AND (e.effectiveFromPrecision IS NULL OR e.effectiveFromBasis IS NULL) THEN 'EFFECTIVE_WITHOUT_PRECISION_OR_BASIS' END,
  CASE WHEN e.startedAt IS NOT NULL AND e.endedAt IS NOT NULL AND e.endedAt <= e.startedAt THEN 'EMPTY_INTERVAL' END,
  CASE WHEN (e.endedAt IS NOT NULL AND e.endedAt.year >= 9000) OR (e.startedAt IS NOT NULL AND e.startedAt.year <= 1) THEN 'SENTINEL_DATE' END,
  CASE WHEN e.eventCategory = 'REGULATORY_EVENT' AND e.jurisdiction IS NULL THEN 'REGULATORY_EVENT_WITHOUT_JURISDICTION' END
] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN e.uid AS eventUid, violations;

// W18-V08: a rule-derived FOLLOWED_BY holds only when the earlier event's latest possible end (at its precision) is
// no later than the later event's earliest start. Overlapping precision periods give no order.
MATCH (a:Event)-[r:FOLLOWED_BY]->(b:Event)
WHERE r.derivationRule = 'valid-time-order-v1'
WITH a, b, r,
     CASE coalesce(a.endedAtPrecision, a.startedAtPrecision)
       WHEN 'DAY' THEN coalesce(a.endedAt, a.startedAt) + duration('P1D')
       WHEN 'MONTH' THEN coalesce(a.endedAt, a.startedAt) + duration('P1M')
       WHEN 'QUARTER' THEN coalesce(a.endedAt, a.startedAt) + duration('P3M')
       WHEN 'YEAR' THEN coalesce(a.endedAt, a.startedAt) + duration('P1Y')
       WHEN 'DECADE' THEN coalesce(a.endedAt, a.startedAt) + duration('P10Y')
       ELSE coalesce(a.endedAt, a.startedAt) END AS aLatestEnd
WHERE a.startedAt IS NULL OR b.startedAt IS NULL OR aLatestEnd > b.startedAt
   OR size(coalesce(r.derivedFromAssertionUids, [])) <> 2
RETURN a.uid AS earlierUid, b.uid AS laterUid, aLatestEnd, b.startedAt AS laterStart;

// W18-V09: role and participation edges W18 owns are projections of assertions (V-101 analogue for the new types).
MATCH (x)-[r:INVOLVES|EVENT_ABOUT|HOSTS_EVENT|SPEAKS_AT|ATTENDS|EXHIBITS_AT|RECORDING_OF|PRESENTED_AT|DOCUMENTED_BY_RECORD]->(y)
WHERE r.assertionUid IS NULL OR r.recordedFrom IS NULL OR r.relationshipUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid}) WHERE a.predicate = type(r) }
   OR (type(r) IN ['INVOLVES', 'SPEAKS_AT', 'ATTENDS', 'EXHIBITS_AT'] AND r.participantRole IS NULL)
   OR (type(r) = 'RECORDING_OF' AND r.recordingCoverage IS NULL)
RETURN type(r) AS relType, x.uid AS fromUid, y.uid AS toUid, r.assertionUid AS assertionUid;

// W18-V10: retired live fields must not be written (EventPhase is computed at query time; impact is an assessment;
// a source URL is not a locator).
MATCH (e:Event)
WHERE e.eventPhase IS NOT NULL OR e.impactLevel IS NOT NULL OR e.sourceUrl IS NOT NULL
   OR e.happenedAt IS NOT NULL OR e.happenedAtEnd IS NOT NULL OR e.effectiveAt IS NOT NULL
RETURN e.uid AS eventUid, e.eventPhase AS eventPhase, e.impactLevel AS impactLevel, e.sourceUrl AS sourceUrl;

// W18-V11: participation edges of persons (SPEAKS_AT, ATTENDS, INVOLVES) never touch a private record.
MATCH (p)-[r:SPEAKS_AT|ATTENDS|INVOLVES]-(x)
WHERE (p:Person OR p:PrivateRecord) AND (p:PrivateRecord OR p.uid STARTS WITH 'hu:private-' OR coalesce(p.privacyClass, 'PUBLIC') <> 'PUBLIC')
RETURN p.uid AS personUid, type(r) AS relType, x.uid AS otherUid;

// W18-V12: an impact assessment names its method, level, domain and exactly one event.
MATCH (ia:EventImpactAssessment)
WITH ia, COUNT { (ia)-[:ASSESSES_EVENT]->(:Event) } AS nEvents
WHERE ia.methodVersion IS NULL OR ia.impactLevel IS NULL OR ia.impactDomain IS NULL OR nEvents <> 1
RETURN ia.uid AS assessmentUid, ia.methodVersion AS methodVersion, nEvents;

// W18-V13: COMPLETED / IN_PROGRESS needs an EVENT_OCCURRED assertion; a scheduled date that has passed never
// makes an event happen.
MATCH (e:Event)
WHERE e.eventStatus IN ['COMPLETED', 'IN_PROGRESS']
  AND NOT EXISTS { MATCH (a:Assertion {predicate: 'EVENT_OCCURRED'})-[:HAS_SUBJECT]->(e) WHERE coalesce(a.status, '') <> 'REJECTED' }
RETURN e.uid AS eventUid, e.eventStatus AS eventStatus;
