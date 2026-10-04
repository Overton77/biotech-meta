// fx01 queries (run after fx01-dynamic-ads-renditions.cypher). Expected rows are documented in ../06-fixtures-and-queries.md.

// Q01-1 (CQ-CL-08, pair 29): sponsor segments of one episode, by rendition, with their stated start and sponsors.
MATCH (e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})-[:HAS_SEGMENT]->(g:EpisodeSegment {segmentType: 'SPONSOR_READ'})
OPTIONAL MATCH (g)-[:IN_RENDITION]->(src:Source)
OPTIONAL MATCH (g)-[:DELIMITED_BY]->(l:SourceLocator)
OPTIONAL MATCH (o:ClaimOccurrence {predicate: 'SPONSORS_CONTENT'})-[:OCCURS_IN_SEGMENT]->(g)
OPTIONAL MATCH (o)-[:HAS_SUBJECT]->(b)
OPTIONAL MATCH (o)-[:ASSERTED_BY]->(who)
WITH src, l, g, b, o, who ORDER BY b.name
RETURN src.sourceKind AS rendition, l.mediaStartSeconds AS statedStartSeconds, l.mediaTimeBasis AS timeBasis,
       g.chapterTitleVerbatim AS chapter, collect(DISTINCT b.name) AS sponsorsModeled, collect(DISTINCT who.name) AS assertedBy,
       collect(DISTINCT o.validFromBasis) AS validFromBases
ORDER BY statedStartSeconds;

// Q01-2 (CQ-CL-01, CQ-PV-02): where the NMN statement is located in each rendition of its container.
// No offsets are invented for the transcript page or for the directory record (audio not captured).
MATCH (a:ClaimOccurrence {uid: 'hu:claim-occurrence:w21-hl52-sinclair-nmn-1g-daily'})-[:OCCURS_IN]->(e:Episode)<-[:RENDITION_OF]-(src:Source)
OPTIONAL MATCH (src)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)<-[:SUPPORTED_BY]-(a)
RETURN src.sourceKind AS rendition, l.selectorKind AS selectorKind, l.mediaStartSeconds AS mediaStartSeconds,
       l.mediaTimeBasis AS timeBasis, l.exact AS exactInThisRendition
ORDER BY rendition;

// Q01-3 (CQ-CL-05, CQ-AX-18): sponsorship ties of the episode as projected edges with their time basis.
MATCH (b:ConsumerBrand)-[r:SPONSORS_CONTENT]->(e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MATCH (a:Assertion {uid: r.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
RETURN b.name AS sponsor, r.validFrom AS validFrom, r.validFromBasis AS validFromBasis, src.sourceKind AS evidencedInRendition
ORDER BY sponsor;

// Q01-4 (CQ-PV-03): caption/transcript text versions per rendition and the transcription activity behind them.
MATCH (src:Source)-[:RENDITION_OF]->(:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
MATCH (src)-[:HAS_TEXT_VERSION]->(tv:DocumentTextVersion)-[:WAS_GENERATED_BY]->(act:Activity)
OPTIONAL MATCH (act)-[:WAS_ASSOCIATED_WITH]->(ag:Agent)
RETURN src.sourceKind AS rendition, tv.versionLabel AS textVersion, act.activityKind AS activityKind, act.methodVersion AS method, ag.name AS agent
ORDER BY rendition;

// Q01-5 (identity collision): same title stem and guest, two works; no rendition crosses between them.
MATCH (e:Episode) WHERE e.title CONTAINS 'The Biology of Slowing & Reversing Aging'
OPTIONAL MATCH (s:Series)-[:HAS_EPISODE]->(e)
OPTIONAL MATCH (src:Source)-[:RENDITION_OF]->(e)
RETURN e.uid AS episode, e.publishedAt AS publishedAt, collect(DISTINCT s.name) AS series, count(DISTINCT src) AS renditions
ORDER BY publishedAt;

// Q01-6 (mandatory case: author vs host vs guest vs speaker vs asserter): per person, appearance role, the speaker
// label the source printed, and what they asserted in this episode.
MATCH (p:Person)-[ap:APPEARS_IN]->(e:Episode {uid: 'hu:episode:huberman-lab-52-sinclair'})
OPTIONAL MATCH (a:ClaimOccurrence)-[:ASSERTED_BY]->(p)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN p.name AS person, ap.roleType AS appearanceRole, collect(DISTINCT l.speakerLabelInSource) AS speakerLabels,
       collect(DISTINCT a.predicate + '/' + coalesce(a.segmentKind, 'EDITORIAL')) AS asserted
ORDER BY person;

// Q01-7 (CQ-CL-08, forbidden implication [SPONSORS_CONTENT, ENDORSES_PRODUCT]): no endorsement or recommendation
// edge exists for any sponsor or guest. Expected: 0.
MATCH ()-[x:ENDORSES_PRODUCT|RECOMMENDS]->() RETURN count(x) AS endorsementOrRecommendationEdges;
