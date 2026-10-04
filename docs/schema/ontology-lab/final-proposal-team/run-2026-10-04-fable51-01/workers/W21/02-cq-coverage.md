# W21 CQ coverage matrix

Priority and answerability are copied from `competency-questions.md`; nothing is re-ranked. "Query" names the executed fixture query (`fixtures/*.queries.cypher`) or validation id. All fixture queries were RUN on Neo4j 5.26.31 Community on 2026-10-04 (results in `06-fixtures-and-queries.md`).

## 1. Existing competency questions

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Node / property / edge / edge property | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-CL-01 (Essential, A) | "Sinclair (GUEST) said 'My 82 -year-old father, we take a gram of NMN every day.' in episode 52: publisher page TEXT_QUOTE (no offsets; under human review); YouTube MEDIA_TIME 3765-3773 s with wording 'my 82-year-old father'; Apple record: not located." | speaker vs asserter vs host; work vs rendition; captured version | rendition snapshot hash, quote anchor, speaker label, container publication time | `ClaimOccurrence` + `ASSERTED_BY` + `OCCURS_IN` Episode + `SUPPORTED_BY` locators on renditions; `APPEARS_IN {AppearanceProperties.roleType}` | Q01-2, Q01-6; QS-1a | host's sponsor read attributed to the guest; citing a changed page with no version |
| CQ-CL-02 (Essential, Q) | "Practice report (PERSONAL_EXPERIENCE, REPORTS_PRACTICE); the digest's 'recommends' is the digest author's STATES with reportedSpeechAct RECOMMENDS." | basis vs topic; practice vs recommendation; own act vs reported act | span plus adjacent turns | kernel `assertionBasis`, `speechAct`, `reportedSpeechAct`; `Claim.claimType` | Q03-1, Q03-2, Q04-5 | RECOMMENDS projected from a practice report (V-423 / V-W21-06) |
| CQ-CL-03 (Essential, Q) | "Two qualifiers: INDIVIDUAL_VARIATION ('I'm not the same as everybody else...') and HEDGE ('what I do may not perfectly, or work at all for others')." | same-sentence vs later-turn qualifier; kinds | the qualifier's own span | `QUALIFIED_BY {QualificationProperties.qualificationKind, orderIndex}` between occurrences in one container | Q04-2; V-416 | a qualified statement presented as unqualified |
| CQ-CL-04 (Essential, Q) | "Digest: lost INDIVIDUAL_VARIATION and HEDGE, REPORTS_PRACTICE -> RECOMMENDS, scope broadened 'to slow aging'. NMN.com: speech act preserved; qualifier loss NOT assessed (partial capture)." | retelling vs original; loss is a comparison | both spans; qualifier spans | `RETELLS {RetellingProperties}`, `ATTRIBUTES_TO`, `RetellingFidelityAssessment` + `ASSESSES_RETELLING`, `AGAINST_ORIGINAL`, `IDENTIFIES_LOST_QUALIFICATION` | Q04-3; V-412..V-415 | loss stored on an assertion (V-414); null read as "faithful" |
| CQ-CL-05 (Essential, Q) | "Host's blood-work statement: DIRECT, SPONSOR_OF_CONTAINER, disclosed in container (the read itself). Guest's self-measurement: INDIRECT; ties assessed SPONSORS_CONTENT and on-air BOARD_MEMBER_OF." | sponsorship vs personal interest; relevance vs truth; disclosed vs not found | role assertions with bounds, disclosure span, capture completeness | `ConflictRelevanceAssessment` (`relevanceLevel`, `relevanceBasis`, `temporalOverlap`, `disclosureFinding`) + `FOR_OCCURRENCE`, `ASSESSES_INTEREST`, `SUPPORTED_BY` disclosure span; `SPONSORS_CONTENT` asserted edge | Q03-3; V-424..V-427, V-W21-09 | verdict from a tie (V-424); NOT_DISCLOSED from partial capture (V-426); disclosure claimed without span (V-W21-09) |
| CQ-CL-06 (Foundational, Q) | "'Sinclair takes ~1 g NMN/day': 2 instances, 1 independent first-hand (retellings never add). 'Compound Y +12%': 2 occurrences, 1 distinct asserter (slide and speech by the same speaker)." | proposition vs occurrence; retelling vs independent | INSTANCE_OF resolutions; RETELLS chains | `Claim`, `INSTANCE_OF {InstanceOfProperties}`, `RETELLS`, one `ASSERTED_BY` | Q04-1, Q05-2, Q06-3 | echo inflation |
| CQ-CL-07 (Expansion, Q) | handle-only speaker on a platform | identity vs hypothesis | handle, platform | `PseudonymousActor` (W01) `ON_PLATFORM` Platform; `Episode.pseudonymousParticipants`; `ClaimSpeakerTarget` includes PseudonymousActor/AnonymousActor | not fixtured (Expansion) | merging a handle into a Person by name |
| CQ-CL-08 (Essential, A) | "YouTube rendition: sponsor chapter at 210 s (ROKA, InsideTracker, Magic Spoon), host read at 287 s. Feed audio as presented by Apple, observed 2026-10-04: sponsor chapter at 225 s (AG1, LMNT, Waking Up), asserted by Scicomm Media, valid from unknown (OBSERVATION_ONLY)." | sponsor read vs editorial; rendition-specific timing; host vs guest | rendition cue/chapter, show notes | `EpisodeSegment {segmentType: SPONSOR_READ}` + `IN_RENDITION` + `DELIMITED_BY`; `ClaimOccurrence.segmentKind`; `SPONSORS_CONTENT` | Q01-1, Q01-3; V-W21-02, V-W21-05 | ENDORSES_PRODUCT from a sponsor read (V-422); a feed ad claimed for the video |
| CQ-CL-09 (Expansion, Q) | experience report = ClaimOccurrence with PERSONAL_EXPERIENCE | report vs outcome evidence | span | `ClaimOccurrence` (ExperienceReport folded) | fx03 H1/G1 are of this shape | double records; private cohort reports in the shared graph |
| CQ-PV-01 (Essential, Q) | "Said: yes (capture-fidelity policy adjudication). Span: locator/snapshot hash. Broader conclusion: none. Activity: W21 extraction + TRANSCRIPTION activities. Policy: not exercised in W21 fixtures (inherited fixture covers state 5)." | five states | as round 0006 | ClaimOccurrence, locators, assessments, Activity lineage | Q01-4, Q02-5 | state 1 shown as state 3 |
| CQ-PV-02 (Foundational, A) | "Prior citation hash sha256:9cadaee8... unchanged; re-found in the reviewed capture with FUZZY match." | snapshot vs source; text version vs snapshot; rendition timelines | stored capture, quote, normalization | W00 locator fields; `REANCHORS`; W21 `DELIMITED_BY`, `IN_RENDITION` | Q02-1, Q02-2; V-W21-01, V-W21-08 | invented offsets; mutated citations |
| CQ-PV-04 (Essential, Q) | "Guest's self-measurement sentence differs by rendition: publisher 'or I know if', YouTube captions 'or I think I know if' (a hedge present in one rendition only); neither audio-verified." | what was said vs captured text | both rendition texts | locators per rendition with distinct `quoteHash`; `DocumentTextVersion` + TRANSCRIPTION Activity | Q03-4 | silently quoting one rendition's wording as the utterance |
| CQ-PV-05 (Foundational, Q) | "Episode 52 occurrence PRIMARY; digest and NMN.com RETELLING (BELLLABS_MATCH)." | primary vs aggregator, per assertion | RETELLS chain | absence/presence of outgoing `RETELLS` (replaces `Document.isPrimarySource`) | Q04-4 | document-level primary flag |
| CQ-EC-03 (Essential, Q) | relevance path from speaker to sponsor | direct vs indirect | role and sponsorship assertions | `ConflictRelevanceAssessment.relevanceBasis`; SPONSORS_CONTENT; W01 roles | Q03-3 | relevance through unasserted hops |
| CQ-CM-04 (Expansion, Q) | media recommendation with affiliate link | recommendation vs affiliate | RECOMMENDS speech act; AFFILIATE_FOR_OFFER (W15) | derived `RECOMMENDS` (fx07) joined to W15 `AFFILIATE_FOR_OFFER` | not fixtured (W15 owns offers) | affiliate link read as recommendation |
| CQ-AX-05 (Foundational, Q) | "Independent lines: 1; retellings: 1." | retelling vs replication | RETELLS, asserter, dataset (W09) | as CQ-CL-06 | Q04-1, Q06-3 | "five agree" when one |
| CQ-AX-18 (Foundational, Q) | "InsideTracker sponsorship valid from 2021-12-27 (PUBLICATION_PROXY) overlaps the statement; AG1 sponsorship of the feed audio known only as of 2026-10-04." | role valid time vs statement date | `Episode.publishedAt`, edge bounds | `Episode.publishedAt` + `publishedAtPrecision`; asserted edge bounds | Q01-3 | today's tie used for a past statement |
| CQ-RC-05 (Essential, A) | "Nobody recommends NMN by their own act in the corpus; the digest reports a recommendation." | own vs reported recommendation | speech acts | `speechAct`, `reportedSpeechAct`, derived `RECOMMENDS` | Q04-5, Q07-1; V-W21-06 | a source recommendation fabricated from a retelling |

## 2. Candidate CQs (new; candidate status, not existing ids)

| Id | Question | Rationale and failing case | Elements it justifies |
|---|---|---|---|
| CQ-CL-C01 (candidate, Foundational) | Which sponsors and ad segments did each rendition of a work carry, at what stated time, as observed when? | Dynamic ad insertion: the same episode's YouTube rendition and feed audio carried different sponsors at different chapter times on 2026-10-04 (fx01). Without rendition binding, AG1 is claimed for the video. | `IN_RENDITION`, `DELIMITED_BY`, `DISTRIBUTES_RENDITION`, `EpisodeSegment.delimitationBasis` |
| CQ-CL-C02 (candidate, Foundational) | Was a talk statement shown on a slide, said aloud, or both, and by whom? | Merck JPM 2026: the deck (Merck) and the speech (CEO) state the same forecast with different wording; a deck treated as a rendition would let the speech cite the slide (fx06 N06-b). | `OccurrenceContainerTarget` includes `Document`; V-W21-03; `episodeType` CONFERENCE_TALK |
| CQ-CL-C03 (candidate, Essential) | Do the captured texts of one utterance differ between renditions, and which rendition does an answer quote? | Publisher text "or I know if" versus YouTube captions "or I think I know if" (fx03 Q03-4): a hedge present in one rendition only. | per-rendition locators; Q03-4 query; capture-fidelity review routing (W00 `Adjudication`) |
| CQ-CL-C04 (candidate, Expansion) | Which works are re-edits or excerpts of which, so a re-released utterance is not counted as a new act of asserting? | "Essentials" re-edit (2025-10-30) of episode 52 material; NMN.com cites an Essentials video. | none in SDL yet (candidate `EXCERPTS_FROM`, W21-SR-19) |

## 3. Every SDL element to its CQ / invariant / failure

| SDL element | Mapped to |
|---|---|
| `Platform` (+ `platformType`, `url`, `hostsChannels`, `pseudonymousAccounts`) | CQ-CL-01, CQ-CL-C01, CQ-CL-07 |
| `Channel` (+ `platform`, `operators`, `hosts`, `hasSeries`, `hasEpisodes`, `distributesRenditions`, sponsoring fields) | CQ-CL-01, CQ-CL-05, CQ-CL-C01 |
| `Series` (+ fields) | CQ-CL-01, CQ-CL-C04 (identity collision, fx01 Q01-5) |
| `Episode` (+ all fields) | CQ-CL-01, CQ-CL-05, CQ-CL-08, CQ-AX-18, D-005; `mentions` legacy read-only (migration) |
| `EpisodeSegment` (+ `segmentType`, `chapterTitleVerbatim`, `delimitationBasis`, `inRendition`, `delimitedBy`, `claimOccurrences`) | CQ-CL-08, CQ-CL-C01 |
| `Claim` (+ fields, `occurrences`, `relationshipAssertions`, `evidenceAssessments`) | CQ-CL-06, CQ-AX-05, CQ-EV-03, V-417, V-418 |
| `ClaimOccurrence` (+ kernel fields, `utteranceText`, `roleTitleVerbatim`, `statedTense`, `segmentKind`, all relationship fields) | CQ-CL-01..06, CQ-CL-08, INV-402, V-410, V-411 |
| `RelationshipAssertion` (+ fields) | CQ-EV-02, V-419, V-420 |
| `ClaimEvidenceAssessment` | CQ-EV-03, CQ-AX-24, V-418 |
| `RetellingFidelityAssessment` | CQ-CL-04, V-414, V-415 |
| `ConflictRelevanceAssessment` | CQ-CL-05, CQ-EC-03, V-424..V-427, V-W21-09 |
| `ClaimType` | CQ-CL-02 (topic axis) |
| `ClaimSpeakerTarget` | INV-402 (exactly one asserter), V-W21-04 |
| `OccurrenceContainerTarget` | INV-402, V-411, W21-D05 |
| `EpisodeMentionableTarget` | migration (legacy read-only retrieval) |
| `QualificationProperties` | CQ-CL-03, V-416 |
| `RetellingProperties` | CQ-CL-04, V-413 |
| `AppearanceProperties` | CQ-CL-01, asserted_edge profile (INV-101) |
| `InstanceOfProperties` | CQ-CL-06, V-417 |
| `IN_RENDITION`, `DELIMITED_BY`, `DISTRIBUTES_RENDITION` (new relationship types) | CQ-CL-C01, CQ-CL-08, V-W21-05 |
| `SPONSORS_CONTENT` fields | CQ-CL-05, CQ-CL-08, FINANCIAL_INTEREST, V-421, V-W21-07 |

Elements without a mapping were kept out of the fragment: `Presentation`/`Talk` (rejected), `EXCERPTS_FROM` and `RECORDS_EVENT` (candidates), `RecommendableTarget` (owner seam), enum candidates for `platformType`/`channelType`/`seriesType`/`segmentType`/`episodeType` (strings kept).
