// =====================================================================================================
// W21 candidate validation queries (proposed for docs/schema/neo4j/validation.cypher through seam W21-SR-16).
// Convention as in the baseline suite: zero rows means valid. Ids V-W21-nn are worker-local candidates; Fable
// assigns final V-4xx numbers. Each statement binds its own variables. Tested on Neo4j 5.26.31 Community.
// =====================================================================================================

// V-W21-01: media time is rendition-bound. A MEDIA_TIME locator (or any locator carrying media seconds) must hang
// from a snapshot of a playable rendition (VIDEO_RENDITION, AUDIO_FEED_ITEM, PODCAST_DIRECTORY_RECORD) and name
// its mediaTimeBasis. A transcript page or a document never acquires invented media offsets.
MATCH (src:Source)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)
WHERE (l.selectorKind = 'MEDIA_TIME' OR l.mediaStartSeconds IS NOT NULL OR l.mediaEndSeconds IS NOT NULL)
  AND (l.selectorKind <> 'MEDIA_TIME'
       OR NOT coalesce(src.sourceKind, '') IN ['VIDEO_RENDITION', 'AUDIO_FEED_ITEM', 'PODCAST_DIRECTORY_RECORD']
       OR l.mediaTimeBasis IS NULL
       OR l.mediaEndSeconds < l.mediaStartSeconds)
RETURN l.uid AS locatorUid, src.uid AS sourceUid, src.sourceKind AS sourceKind, l.selectorKind AS selectorKind;

// V-W21-02: sponsor-read agreement. An occurrence marked segmentKind SPONSOR_READ lies in a SPONSOR_READ segment of
// its own Episode, and when that segment is rendition-specific the occurrence cites a locator on that rendition.
// Conversely an occurrence inside a SPONSOR_READ segment carries segmentKind SPONSOR_READ.
MATCH (a:ClaimOccurrence)
OPTIONAL MATCH (a)-[:OCCURS_IN_SEGMENT]->(g:EpisodeSegment)
WITH a, [x IN collect(g) WHERE x.segmentType = 'SPONSOR_READ'] AS sponsorSegs
WHERE (a.segmentKind = 'SPONSOR_READ' AND size(sponsorSegs) = 0)
   OR (coalesce(a.segmentKind, '') <> 'SPONSOR_READ' AND size(sponsorSegs) > 0)
   OR any(g IN sponsorSegs WHERE NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(:Episode)-[:HAS_SEGMENT]->(g) })
   OR any(g IN sponsorSegs WHERE EXISTS { MATCH (g)-[:IN_RENDITION]->(:Source) }
          AND NOT EXISTS { MATCH (g)-[:IN_RENDITION]->(:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(a) })
RETURN a.uid AS sponsorReadDisagreement, a.segmentKind AS segmentKind, size(sponsorSegs) AS sponsorSegments;

// V-W21-03: a slide deck (or poster) is its own container, never a rendition of the talk it accompanies; otherwise
// V-411 would let a spoken occurrence cite slide text the speaker never said. Stored property for documentType is `type`.
MATCH (d:Document)-[:RENDITION_OF]->(e:Episode)
WHERE d.type IN ['INVESTOR_PRESENTATION', 'CONFERENCE_PRESENTATION', 'CONFERENCE_POSTER']
RETURN d.uid AS slideDeckAsRendition, e.uid AS episodeUid;

// V-W21-04: ClaimOccurrence asserter range (Person, Organization, PseudonymousActor, AnonymousActor; never an
// Agent) and ATTRIBUTES_TO never names the occurrence's own asserter.
MATCH (a:ClaimOccurrence)-[:ASSERTED_BY]->(x)
WHERE NOT (x:Person OR x:Organization OR x:PseudonymousActor OR x:AnonymousActor)
   OR EXISTS { MATCH (a)-[:ATTRIBUTES_TO]->(x) }
RETURN a.uid AS occurrenceUid, labels(x) AS asserterLabels;

// V-W21-05: an EpisodeSegment belongs to exactly one Episode; its delimiting locators lie on renditions of that
// Episode and, when IN_RENDITION is set, on that rendition only; at most one IN_RENDITION.
MATCH (g:EpisodeSegment)
OPTIONAL MATCH (e:Episode)-[:HAS_SEGMENT]->(g)
WITH g, collect(DISTINCT e) AS eps
OPTIONAL MATCH (g)-[:IN_RENDITION]->(r:Source)
WITH g, eps, collect(DISTINCT r) AS rs
WHERE size(eps) <> 1 OR size(rs) > 1
   OR EXISTS { MATCH (g)-[:DELIMITED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
               WHERE NOT EXISTS { MATCH (src)-[:RENDITION_OF]->(ep:Episode) WHERE ep IN eps }
                  OR (size(rs) = 1 AND src <> rs[0]) }
RETURN g.uid AS malformedSegment, size(eps) AS episodes, size(rs) AS renditions;

// V-W21-06 (amends V-423 for the derived RECOMMENDS projection, CL-016, D-011): a RECOMMENDS edge derives from
// exactly one live assertion whose own speechAct is RECOMMENDS, asserted by the edge's start node, whose subject
// or object is the edge's end node. A practice report, a retelling's reportedSpeechAct, or a sponsor read never
// qualifies. Accepts the legacy assertionUid only as a migration fallback.
MATCH (p)-[rec:RECOMMENDS]->(x)
WITH p, x, rec, coalesce(rec.derivedFromAssertionUids, CASE WHEN rec.assertionUid IS NULL THEN [] ELSE [rec.assertionUid] END) AS cited
WHERE size(cited) <> 1
   OR (rec.assertionUid IS NULL AND rec.derivationRule IS NULL)
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = cited[0] AND a.speechAct = 'RECOMMENDS' AND NOT a.status IN ['REJECTED', 'SUPERSEDED']
       AND (EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR EXISTS { (a)-[:HAS_OBJECT]->(x) })
   }
RETURN p.uid AS recommenderUid, x.uid AS recommendedUid, cited;

// V-W21-07: SPONSORS_CONTENT endpoints are Organization|ConsumerBrand -> Episode|Series|Channel|Document|Conference
// (catalog organizations.assertedPredicates); a sponsor never sponsors a Person, a Product or a Source rendition.
MATCH (s)-[r:SPONSORS_CONTENT]->(o)
WHERE NOT (s:Organization OR s:ConsumerBrand)
   OR NOT (o:Episode OR o:Series OR o:Channel OR o:Document OR o:Conference)
   OR (o:Source AND NOT o:Document)
RETURN s.uid AS sponsorUid, labels(o) AS sponsoredLabels, o.uid AS sponsoredUid;

// V-W21-08: a transcript correction keeps the prior citation. When an occurrence in an Episode is superseded with
// SOURCE_CORRECTION, the old occurrence keeps its locator(s), and the successor cites a newer locator that
// REANCHORS (directly or through a chain) a locator of the old occurrence.
MATCH (n:ClaimOccurrence)-[s:SUPERSEDES {supersessionKind: 'SOURCE_CORRECTION'}]->(o:ClaimOccurrence)-[:OCCURS_IN]->(:Episode)
WHERE NOT EXISTS { MATCH (o)-[:SUPPORTED_BY]->(:SourceLocator) }
   OR NOT EXISTS { MATCH (n)-[:SUPPORTED_BY]->(:SourceLocator)-[:REANCHORS*1..5]->(:SourceLocator)<-[:SUPPORTED_BY]-(o) }
RETURN n.uid AS correctedOccurrence, o.uid AS priorOccurrenceWithoutPreservedCitation;

// V-W21-09: DISCLOSED_IN_CONTAINER needs a disclosure span: the assessment is SUPPORTED_BY a locator in the
// occurrence's container or one of its renditions.
MATCH (c:ConflictRelevanceAssessment {disclosureFinding: 'DISCLOSED_IN_CONTAINER'})-[:FOR_OCCURRENCE]->(o:Assertion)-[:OCCURS_IN]->(k)
WHERE NOT EXISTS {
  MATCH (c)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
  WHERE src = k OR (src)-[:RENDITION_OF]->(k)
}
RETURN c.uid AS disclosedInContainerWithoutSpan;

// V-W21-10 (informational, attribution drift): a retelling that does not ATTRIBUTES_TO the original's asserter.
// Rows are review items, not hard failures (the assessment's attributionChanged records the judgment).
MATCH (r:Assertion)-[:RETELLS]->(o:Assertion)-[:ASSERTED_BY]->(x)
WHERE NOT EXISTS { MATCH (r)-[:ATTRIBUTES_TO]->(x) }
RETURN r.uid AS retellingWithoutAttributionToOriginalAsserter, x.uid AS originalAsserter;

// V-W21-11: an INSTANCE_OF edge never comes from a QUESTIONS speech act (a question is not an assertion of the
// proposition) unless it is a retelling's reported act.
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim)
WHERE a.speechAct = 'QUESTIONS'
RETURN a.uid AS questionCountedAsInstance, c.uid AS claimUid;

// V-W21-12 (amends V-416 for qualifiers on assertions without a container, W08-SR-10): QUALIFIED_BY names its kind;
// when either side has a container both share it; when neither has one, both are supported by locators on the same
// SourceSnapshot (the qualifier is printed in the same captured record).
MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
WHERE q.qualificationKind IS NULL
   OR ((EXISTS { (a)-[:OCCURS_IN]->() } OR EXISTS { (b)-[:OCCURS_IN]->() })
       AND NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) })
   OR (NOT EXISTS { (a)-[:OCCURS_IN]->() } AND NOT EXISTS { (b)-[:OCCURS_IN]->() }
       AND NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(b) })
RETURN a.uid AS qualifiedUid, b.uid AS qualifierUid;
