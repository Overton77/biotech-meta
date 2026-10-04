# W21 Narrative media, speakers and claims: domain recommendation

Worker W21 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical catalog module: `claims_and_documents` (catalog 0.2.0, digest `8fb50ff0…84f0`). This is a research and modeling packet, not the final schema. All fixtures named here were executed on Neo4j 5.26.31 Community (embedded); see `06-fixtures-and-queries.md`.

## 1. Boundary and subdomains

W21 owns the representation of human-made narrative content as a source of attributable statements: who published which work where, who appeared in it in which role, who said what at which captured span, how a statement was qualified, retold, sponsored or financially entangled. It does not own truth, evidence strength, source capture, text lineage, actors or media bytes.

| Subdomain | W21 elements | Boundary with |
|---|---|---|
| Distribution identities | `Platform`, `Channel`, `Series`; `HOSTS_CHANNEL`, `HAS_SERIES`, `HAS_EPISODE`, `DISTRIBUTES_RENDITION` (new), `OPERATES_CHANNEL`, `SERVES_ON_CHANNEL`, `ON_PLATFORM` | W01 owns the operating `Organization` and the people; W19 owns `sourceKind` vocabulary |
| Works and their parts | `Episode` (work Entity), `EpisodeSegment` (InformationArtifact); `HAS_SEGMENT`, `IN_RENDITION` (new), `DELIMITED_BY` (new), `APPEARS_IN` | W00 owns `Source`, `SourceSnapshot`, `SourceLocator`, `RENDITION_OF`, `SourceRevisionEvent`; W20 owns `Document`, `DocumentTextVersion`, `AUTHORED_BY`; W18 owns `Conference`, `Event`; W09 owns `Publication` |
| Propositions and source-attributed assertions | `Claim`, `ClaimOccurrence` (`["ClaimOccurrence","Assertion"]`), `RelationshipAssertion` (`["RelationshipAssertion","Assertion"]`), `ClaimType`; `OCCURS_IN`, `OCCURS_IN_SEGMENT` (use), `QUALIFIED_BY`, `RETELLS`, `ATTRIBUTES_TO`, `INSTANCE_OF` | W00 owns the Assertion kernel (fields, `ASSERTED_BY`, `HAS_SUBJECT`, `HAS_OBJECT`, `SUPPORTED_BY`, `SUPERSEDES`), the generic `Assertion` type and `Adjudication` |
| Appraisal of statements | `ClaimEvidenceAssessment`, `RetellingFidelityAssessment`, `ConflictRelevanceAssessment` and their structural edges | W10 owns assessment method contracts and `EvidenceSynthesis`; W01 owns the FINANCIAL_INTEREST role assertions being assessed |
| Content-level commercial ties | `SPONSORS_CONTENT` (FINANCIAL_INTEREST member, asserted), `RECOMMENDS` (derived projection of a RECOMMENDS speech act, CL-016) | W01 writes the Organization/ConsumerBrand/Person side fields; W15 owns `AFFILIATE_FOR_OFFER` (CQ-CM-04) |

Not W21: thumbnails, video bytes, frame annotations (W22); chunking (W20); private listening history or personal adoption of a reported practice (W23, outside the shared graph).

## 2. Identity, state, artifact, occurrence

| Thing in the world | Archetype | W21 type | Why not another archetype |
|---|---|---|---|
| YouTube, Megaphone, Apple Podcasts | Entity | `Platform` | persists, has no versions that matter to a CQ |
| A YouTube channel account, an RSS feed | Entity | `Channel` | persists across episodes; operator is an asserted role, not a property |
| "Huberman Lab", "Huberman Lab Essentials" | Entity | `Series` | a show persists across channels and platforms |
| Episode 52, a recorded conference talk | Entity | `Episode` | the work; renditions (page, video, feed item, directory record, transcript PDF) are `Source`s `RENDITION_OF` it (D-005) |
| A sponsor block, a chapter, prepared remarks | InformationArtifact | `EpisodeSegment` | a record about a work's structure; its timing is a locator, so it is not an Occurrence |
| "Sinclair said he takes 1 g NMN/day in episode 52" | Assertion | `ClaimOccurrence` | one asserter, one container, one act of asserting |
| "A registry field says the trial enrolled 100" | Assertion | `RelationshipAssertion` | no speaker and no utterance |
| "Sinclair takes about 1 g NMN/day" (whoever says it) | Entity | `Claim` | proposition identity, no truth value |
| Retelling fidelity, conflict relevance, claim evidence grade | EvidenceAssessment | the three assessments | BellLabs judgments with method versions; immutable, superseded |
| A recording being taken down | Occurrence | `SourceRevisionEvent` (W00) | used, not owned |
| A conference session happening | Occurrence | `Event` (W18) | used only through a candidate link (seam W21-SR-20) |

## 3. Disposition of every live and catalog element in scope

Live line numbers refer to `current_biotech_schema.graphql`. "Catalog" refers to `claims_and_documents` in catalog 0.2.0. Full field-level mapping is in `migration-map.yaml`.

| Element | Origin | Disposition | Reason (failing case or CQ) |
|---|---|---|---|
| `Platform` (2850) | live + cat | keep; refine (archetype fields, uid; `hostsChannels` structural) | CQ-CL-01, CQ-CL-08; uid token `platform` requested (W21-SR-01) |
| `Platform.platformType`, `.url` | live | keep (controlled string; display url) | enum candidate W21-SR-02 |
| `Channel` (2861) | live + cat | keep; refine | operator and host become asserted edges; `DISTRIBUTES_RENDITION` added (fx01: YouTube channel vs RSS feed carry different sponsor sets) |
| `Channel.hasSeries`, `.hasEpisodes` | live | keep (structural, `StructuralEdgeProperties` replaces `OrderingMetadata`) | |
| `Series` (2874) | live + cat | keep; refine | `INCLUDES_EPISODE` merged into catalog `HAS_EPISODE` (one meaning, one name) |
| `Episode` (2818) | live + cat | keep; refine (work Entity) | D-005; fx01 shows the same work in three renditions with different text and timelines |
| `Episode.publishedAt`, `durationSeconds`, `title`, `summaryText`, `episodeType` | live | keep; add `publishedAtPrecision`, `episodeNumber`, `seasonNumber` (from `OrderingMetadata`) | duration is the publisher's nominal value; rendition durations differ (dynamic ads) |
| `Episode.personsInEpisode` (`APPEARS_IN`, RoleMetadata) | live | keep; refine to `AppearanceProperties` (asserted) | CQ-CL-01 host vs guest; roleType HOST/CO_HOST/GUEST/MODERATOR requested (W21-SR-09) |
| `Episode.hasSegments` | live | keep (`HAS_SEGMENT`, structural) | |
| `Episode.onPlatforms` (`ON_PLATFORM`) | live | retire (derivable: Episode <- RENDITION_OF - Source <- DISTRIBUTES_RENDITION - Channel <- HOSTS_CHANNEL - Platform) | an episode-level platform edge cannot say which rendition carried which ads |
| `Episode.sponsorsProducts` (`SPONSORS_PRODUCT`) | live | retire; migrate to `SPONSORS_CONTENT` assertions (brand/org -> Episode) | an episode does not sponsor a product; the catalog predicate is SPONSORS_CONTENT (round 0006) |
| `Episode.mentions` (`MENTIONS`, `EpisodeMentionable`) | live | keep read-only legacy (derived retrieval) | name collides with catalog `MENTIONS` (SourceLocator -> Mention); seam W21-SR-10 |
| `Episode.hasTranscriptVersions` (`HAS_TRANSCRIPT`) | live | retire (W20 disposes the type) | a transcript is a text version of a rendition snapshot (`TEXT_OF_SNAPSHOT`); fx01/fx02 |
| `EpisodeSegment` (2840) | live + cat | keep; refine (InformationArtifact; `segmentType`; `chapterTitleVerbatim`, `delimitationBasis`, `IN_RENDITION`, `DELIMITED_BY` added) | CQ-CL-08 and pair 29: YouTube sponsor chapter at 3:30 (ROKA, InsideTracker, Magic Spoon) versus Apple/feed chapter at 3:45 (AG1, LMNT, Waking Up), observed 2026-10-04 |
| `Claim` (2762) | live + cat | keep; refine | D-006 |
| `Claim.claimText`, `claimType`, `claimPolarity`, `isQuantitative`, `isCausal`, `isMechanistic` | live | keep | proposition features (round 0006 D2) |
| `Claim.evidenceStrength` | live | move to `ClaimEvidenceAssessment` | V-418 |
| `Claim.isClinical`, `isPreclinical` | live | retire from Claim (evidence setting belongs to W03 `MechanismEvidenceContext` / W09 study design) | they describe evidence, not the proposition |
| `Claim.about` (`ABOUT`, ClaimSubject) | live | retire (derivable from instance assertions' subjects/objects) | a Claim has no source; aboutness from extraction belongs on locator-level retrieval (W20) |
| `Claim.supportedBy` (`SUPPORTED_BY` -> Chunk) | live | retire | a Claim has no source support; support flows through occurrences (V-407) |
| `Claim.occurrences` (`INSTANCE_OF`) | live | keep; derived ruleOnly with W00 `DerivedEdgeProperties` (`derivationRule` always set; an accepted ResolutionHypothesis uid goes in `derivedFromAssessmentUids`, W00 D-W00-18) | V-417 needs `derivationRule` or `hypothesisUid` |
| `ClaimOccurrence` (2787) | live + cat | keep; refine to `["ClaimOccurrence","Assertion"]` implementing `AssertionArchetype` | D-006, CL-004; fx05 two-speaker split |
| `ClaimOccurrence.utteranceText` | live | keep as display copy; locator authoritative | |
| `ClaimOccurrence.occursIn` (`OccurrenceContainer`) | live | keep; exactly one; range adds `Publication` | W21-D05 failing case |
| `ClaimOccurrence.utteredBy` (`UTTERED_BY`) | live | replace by `ASSERTED_BY` (D-006) | |
| `ClaimOccurrence.occursInSegments` | live | keep (`OCCURS_IN_SEGMENT`, no properties) | timing moves to locators |
| `ClaimOccurrence.instanceOf`, `.supportedBy` (Chunk) | live | `INSTANCE_OF` kept (derived); Chunk support kept only as W20 `SUPPORTED_BY_CHUNK` with `locatorUid` | V-407 |
| `RelationshipAssertion` (2571) | live + cat | keep; refine to `["RelationshipAssertion","Assertion"]` | round 0006 D3 |
| `RelationshipAssertion.subject`/`object` lists (`SUBJECT`/`OBJECT`, MediaSubject) | live | split to `HAS_SUBJECT`/`HAS_OBJECT` (one each) | V-420 |
| `RelationshipAssertion.confidence`, `supportedByClaims` | live | retire (`extractionConfidence` + Activity; `INSTANCE_OF`) | INV-407 |
| `RelationshipAssertion.relationshipType`, `predicateText`, `subjectLabel`, `objectLabel`, `visualizedBy` | live | keep (relationshipType deprecated verbatim) | |
| `ExperienceReport` (2802) | live | **seam -> fold into `ClaimOccurrence`** with `assertionBasis` PERSONAL_EXPERIENCE; type retired | an ExperienceReport has no asserter cardinality, no container and no locator, so it cannot answer CQ-CL-01/02 and double-records occurrences; `REPORTS` from `CohortParticipant` is private-context data (W23) |
| `AUTHORS`, `REPORTS`, `EXTRACTED_FROM`, `EXTRACTED_FROM_SEGMENT` | live | retire (-> `ASSERTED_BY`; private store; `OCCURS_IN` + `SUPPORTED_BY`; `OCCURS_IN_SEGMENT`) | |
| `ClaimEvidenceAssessment` | cat | keep (new type) | V-418; CQ-EV-03 |
| `RetellingFidelityAssessment` | cat | keep | V-414, V-415; fx04 |
| `ConflictRelevanceAssessment` | cat | keep | V-424..V-427; fx03 |
| `ClaimType` enum (2643) | live | keep, values unchanged | |
| `ClaimSpeaker` union (2187) | live | rename `ClaimSpeakerTarget`; add `Organization` | slide deck and show notes are asserted by organizations (fx06, fx01) |
| `ExperienceAuthor` union | live | retire (merged into `ClaimSpeakerTarget`) | |
| `OccurrenceContainer` union | live | rename `OccurrenceContainerTarget`; add `Publication` | W21-D05 |
| `ExtractionSource` union | live | retire (Chunk is not a source; `SUPPORTED_BY` locator) | |
| `EpisodeMentionable` union | live | rename `EpisodeMentionableTarget`; `Material` -> `IngredientMaterial` (D-008); legacy read-only | |
| `Recommendable` union (1070) | live | seam: no registry owner; proposed `RecommendableTarget` (W21-SR-18) | `Compound` no longer exists (D-002) |
| `RecommendationMetadata` (151) | live | retire; `RECOMMENDS` uses `DerivedEdgeProperties` | CL-016, D-011; fx07 |
| `OrderingMetadata` (176) on narrative edges | live | split: orderIndex -> `StructuralEdgeProperties`; season/episode numbers -> `Episode`; startTime/endTime -> `SourceLocator` media seconds on a rendition; `rhetoricalRole` -> `EpisodeSegment.segmentType` | a time string without a rendition is not reproducible |
| `RoleMetadata` on `APPEARS_IN`, `SERVES_ON_CHANNEL`, `OPERATES_CHANNEL`, `HOSTS_CHANNEL`, `ON_PLATFORM`, `OCCURS_IN`, `INSTANCE_OF` | live | split per class: asserted -> `AppearanceProperties`/`AssertedEdgeProperties`; structural -> `StructuralEdgeProperties` or none; derived -> `DerivedEdgeProperties` | contract B4 |
| `Organization.sponsors` (`SPONSORS`, Sponsorable) | live (W01 side) | migrate to `SPONSORS_CONTENT` | bare `SPONSORS` collides with `SPONSORS_STUDY` |
| `Person.recommends` (`RECOMMENDS`) | live (W01 side) | derived projection (CL-016) with `DerivedEdgeProperties` | V-423 amendment needed (W21-SR-07; fx07) |
| `SPONSORS_CONTENT` | cat predicate | asserted edge Organization/ConsumerBrand -> Episode/Series/Channel/Document/Conference | V-W21-07 |

## 4. Decisions (summary; evidence and alternatives in `05-decision-seam-ledger.md`)

- **W21-D01 Work versus rendition.** Episode is the work; every playable or readable presentation of it is a `Source` `RENDITION_OF` it. One act of saying is one `ClaimOccurrence` supported by locators in several renditions whose wording may differ (fx01: "My 82 -year-old father" on the publisher page, "my 82-year-old father" in YouTube captions).
- **W21-D02 Rendition-bound segments.** `EpisodeSegment` gains `IN_RENDITION` (zero_or_one) and `DELIMITED_BY` (locators). Real case: on 2026-10-04 the YouTube rendition lists "00:03:30 ROKA, InsideTracker, Magic Spoon" while Apple Podcasts (feed audio) lists "00:03:45 Sponsors: AG1, LMNT & Waking Up". Without `IN_RENDITION` an AG1 segment would be claimed for the YouTube video too.
- **W21-D03 Directory record and feed.** A podcast directory record (Apple Podcasts) presents the feed item with a player and is a rendition; the RSS feed document (many items) is a `Source` but not a rendition of any one episode. Dynamically inserted sponsorships are `SPONSORS_CONTENT` assertions with `validFromBasis` OBSERVATION_ONLY, never back-projected to the 2021 publication date.
- **W21-D04 ExperienceReport folded** into `ClaimOccurrence` (assertionBasis PERSONAL_EXPERIENCE).
- **W21-D05 OCCURS_IN range adds Publication.** Failing case: an author's sentence appears in the HTML and the PDF rendition of one article; with `Document` as the only scholarly container, two occurrences (two containers) are created and independence counting doubles.
- **W21-D06 No Presentation/Talk node.** A recorded talk is an `Episode` (`episodeType` CONFERENCE_TALK) whose renditions are the webcast and the transcript; the slide deck is a `Document` container of its own (`documentType` INVESTOR_PRESENTATION / CONFERENCE_PRESENTATION), never a rendition (V-W21-03). Real case (fx06): Merck at the 44th J.P. Morgan Healthcare Conference; slide 11 ("more than double consensus 2028 total KEYTRUDA sales") is asserted by Merck in the deck; the CEO's spoken "$70 billion" is asserted by Robert Davis in the talk; the webcast was withdrawn ("The recording of this session is not available any more."), so the spoken statement is located only in the transcript PDF and no media offset is invented. Both fit existing shapes; no CQ failed that a new node would fix. The only unmet need is linking the talk work to the conference session (`Event`, W18): candidate seam W21-SR-20.
- **W21-D07 RECOMMENDS is a derived projection** (CL-016) with `DerivedEdgeProperties` (`derivationRule` + one `derivedFromAssertionUids`), licensed only by an assertion whose own `speechAct` is RECOMMENDS by the edge's start node. The verbatim V-423 reads `rec.assertionUid` and therefore fails a correct derived edge (fx07, 1 row); W21 proposes V-W21-06 as the amendment (W21-SR-07).
- **W21-D08 Speech act alone does not separate a sponsor read from an independent practice report** (fx03: the host's "I've long been a believer in getting regular blood work done" inside the InsideTracker read and the guest's "I've been measuring myself ... 45 different things" are both REPORTS_PRACTICE / PERSONAL_EXPERIENCE). The separation is the segment (`segmentKind`/`EpisodeSegment.segmentType`) plus a `ConflictRelevanceAssessment`; V-W21-02 keeps them in agreement.
- **W21-D09 Asserter range for ClaimOccurrence** is `Person | Organization | PseudonymousActor | AnonymousActor` (no `Agent`); `ATTRIBUTES_TO` never names the occurrence's own asserter (V-W21-04).
- **W21-D10 Two speakers, two occurrences** (fx05): a host's confirmation question (`speechAct` QUESTIONS, `ATTRIBUTES_TO` guest) is not an instance of the guest's practice claim (V-W21-11); the guest's "Right." is his own REPORTS_PRACTICE with a locator spanning both turns.
- **W21-D11 Transcript corrections** (fx02a/fx02b): a new snapshot, a new text version (TRANSCRIPTION activity) and a new locator that `REANCHORS` the old one; the old locator and its snapshot hash never change. Only a substantive mis-transcription supersedes the occurrence (`SOURCE_CORRECTION`); V-W21-08 checks that the successor still re-anchors the prior citation.
- **W21-D12 Re-edits are distinct works.** "Essentials: The Biology of Slowing & Reversing Aging" (feed item 2025-10-30) is a separate `Episode` in the `Huberman Lab Essentials` series, not a rendition of episode 52. Whether a re-released utterance is the same act of asserting is unresolved; candidate CQ-CL-C04 and a candidate `EXCERPTS_FROM` relationship are recorded but excluded from the SDL (no fixture needs them yet).

## 5. Alternatives considered and rejected

| Alternative | Rejected because |
|---|---|
| `Presentation`/`Talk` node type | fx06 is fully answerable with Episode + Document + Event seam; a new type would duplicate `Episode` identity for recorded talks and `Document` identity for decks |
| Slide deck as a rendition of the talk | lets a spoken occurrence cite slide text the speaker never said (fx06 neg N06-a/N06-b) |
| Segment timing as properties (`startSeconds`) on `EpisodeSegment` or on `OCCURS_IN_SEGMENT` | not tied to a rendition snapshot; dynamic ads make offsets non-portable (round 0006 O-4) |
| `EpisodeSegment` as Occurrence | the segment is a record about structure, not an event; its "happening" is a playback |
| `SPONSORS_CONTENT` to a rendition `Source` | catalog range is the content (Episode/Series/Channel/Document/Conference); rendition scope is carried by the supporting locator and by the segment's `IN_RENDITION` (V-W21-07) |
| Keep `ExperienceReport` as its own node | duplicates ClaimOccurrence without the assertion contract |
| One occurrence with two asserters for an exchange | V-410; echo counting |
| RECOMMENDS as asserted-class with `AssertedEdgeProperties` | passes verbatim V-423 but the cited assertion's predicate (for example RECOMMENDS_DAILY_INTAKE) differs from the edge type, so QS-4a flags CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE; the edge is a rule over speech act, asserter and object, which is the definition of a derived edge |

## 6. Smallest recommended model

Ten node types (`Platform`, `Channel`, `Series`, `Episode`, `EpisodeSegment`, `Claim`, `ClaimOccurrence`, `RelationshipAssertion`, three assessments), one enum (`ClaimType`), three unions, three relationship-property types (`QualificationProperties`, `RetellingProperties`, `AppearanceProperties`), the registry's narrative relationships, and three new structural relationships (`IN_RENDITION`, `DELIMITED_BY`, `DISTRIBUTES_RENDITION`). `ExperienceReport` and six live relationship types are retired. No new archetype, no kernel field change, no Presentation node. Eleven candidate validation queries (V-W21-01..11) are proposed for the shared suite.
