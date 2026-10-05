// fx06 queries.

// Q06-1 (mandatory pair): every occurrence of each claim with its container kind, asserter, and locator type.
MATCH (c:Claim)<-[:INSTANCE_OF]-(a:ClaimOccurrence)-[:OCCURS_IN]->(k)
MATCH (a)-[:ASSERTED_BY]->(who)
MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
RETURN c.uid AS claim, [x IN labels(k) WHERE x IN ['Episode', 'Document']][0] AS container, who.name AS asserter,
       l.selectorKind AS selectorKind, l.page AS page, l.mediaStartSeconds AS mediaStartSeconds, src.type AS documentType, src.sourceKind AS sourceKind
ORDER BY claim, container;

// Q06-2 (CQ-PV-02): renditions of the real talk and their availability; a withdrawn rendition yields no media locator.
MATCH (src:Source)-[:RENDITION_OF]->(e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'})
OPTIONAL MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src)
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
RETURN src.canonicalUri AS rendition, src.sourceKind AS sourceKind, collect(DISTINCT ev.revisionKind) AS revisions,
       count(DISTINCT l) AS locators, count(DISTINCT CASE WHEN l.selectorKind = 'MEDIA_TIME' THEN l END) AS mediaTimeLocators
ORDER BY rendition;

// Q06-3 (CQ-CL-06, CQ-AX-05): independence of the slide and the speech for each claim: distinct asserters and the
// organization side. (The CEO's employment is not asserted in this fixture; the answer says so.)
MATCH (c:Claim)<-[:INSTANCE_OF]-(a:ClaimOccurrence)-[:ASSERTED_BY]->(who)
RETURN c.uid AS claim, count(a) AS occurrences, count(DISTINCT who) AS distinctAsserters, collect(DISTINCT labels(who)[1]) AS asserterKinds
ORDER BY claim;

// Q06-4 (author vs speaker vs moderator vs asserter): container authors and talk appearance roles.
MATCH (e:Episode {uid: 'hu:episode:merck-jpm-hc-2026-company-presentation'})
OPTIONAL MATCH (p:Person)-[ap:APPEARS_IN]->(e)
RETURN p.name AS person, ap.roleType AS appearanceRole, ap.roleTitleVerbatim AS titleAsPrinted
ORDER BY person;

// Q06-5 (CQ-CL-C02): from the spoken statement, find the accompanying deck and the slide that states the same claim.
MATCH (spoken:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-merck-talk-davis-70-billion'})-[:OCCURS_IN]->(talk:Episode)
MATCH (deck:Document)-[acc:ACCOMPANIES_TALK]->(talk)
MATCH (spoken)-[:INSTANCE_OF]->(c:Claim)<-[:INSTANCE_OF]-(slide:ClaimOccurrence)-[:OCCURS_IN]->(deck)
MATCH (slide)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN deck.uid AS deck, acc.assertionUid AS accompanimentAssertedBy, l.selectorKind AS slideSelector, l.page AS page, l.exact AS slideText;
