# W21 model cards

Conventions: every node type carries the B2 skeleton fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) and its archetype interface fields; those are not repeated per card. Kinds: asserted (A), observed (O), calculated (C), inferred (I), operational (Op). Privacy class is PUBLIC unless stated. Maturity: PROVISIONAL unless stated. "Null" always means unknown/not stated, never false or absent.

## A. Node types

### Platform
- Meaning: a distribution or directory service (YouTube, Megaphone, Apple Podcasts, Substack). Not a company, not a publisher, never a seller or endorser.
- Archetype Entity; labels `["Platform","Entity"]`; uid token `platform` (REQUESTED, W21-SR-01); id = opaque uid segment.
- Properties: `platformType` String (controlled: VIDEO_HOST, AUDIO_FEED_HOST, PODCAST_DIRECTORY, NEWSLETTER_HOST, WEBCAST_HOST, OTHER; O; immutable); `url` String (display, O; never identity).
- Edges: `HOSTS_CHANNEL` -> Channel (structural, many; each Channel exactly one Platform); `ON_PLATFORM` <- PseudonymousActor (structural; handle exists on platform).
- Identity: `Identifier` records for platform ids if needed; names are not identity. Source: SRC-W21-02/03/04.

### Channel
- Meaning: a publisher-operated distribution account on exactly one Platform (YouTube channel, RSS feed, newsletter publication). Not the show, not the operator.
- Archetype Entity; labels `["Channel","Entity"]`; uid token `channel`.
- Properties: `channelType` String (VIDEO_CHANNEL, PODCAST_FEED, NEWSLETTER, WEBCAST_SERIES_ACCOUNT, OTHER; O).
- Edges: `HOSTS_CHANNEL` <- Platform (structural, exactly_one); `OPERATES_CHANNEL` <- Organization (asserted, `AssertedEdgeProperties`); `SERVES_ON_CHANNEL` <- Person (asserted, `AppearanceProperties`, roleType HOST/CO_HOST); `HAS_SERIES` -> Series (structural); `HAS_EPISODE` -> Episode (structural); `DISTRIBUTES_RENDITION` -> Source (structural, new; each rendition zero_or_one channel); `SPONSORS_CONTENT` <- Organization/ConsumerBrand (asserted, FINANCIAL_INTEREST).
- Source: SRC-W21-04 (feed author "Scicomm Media").

### Series
- Meaning: a named series of works persisting across channels and platforms ("Huberman Lab", "Huberman Lab Essentials"). Not a Channel, NarrativeArc or Conference.
- Archetype Entity; labels `["Series","Entity"]`; uid token `series`.
- Properties: `seriesType` String (PODCAST_SERIES, SUB_SERIES, LECTURE_SERIES, VIDEO_SERIES, NEWSLETTER_SERIES, OTHER).
- Edges: `HAS_SERIES` <- Channel; `HAS_EPISODE` -> Episode (structural; live `INCLUDES_EPISODE` merged); `SPONSORS_CONTENT` <- Organization/ConsumerBrand.

### Episode
- Meaning: a published audio/video work, including recorded talks, lectures, panels. Renditions are `Source`s `RENDITION_OF` it. Re-edits are separate Episodes.
- Archetype Entity; labels `["Episode","Entity"]`; uid token `episode`; implements `SearchIndexable`; `@fulltext EpisodeSearch` on stored `name`, `title`, `summaryText` (D-015).
- Properties: `episodeType` String (FULL, TRAILER, BONUS, EXCERPT, RE_EDIT, CONFERENCE_TALK, LECTURE, WEBINAR, PANEL; O from RSS itunes:episodeType where available); `title` String (O); `episodeNumber` Int (O, publisher number, not identity); `seasonNumber` Int (O); `publishedAt` DateTime (O; first publication of the work per feed/directory; null when only the live session time is known, as for fx06); `publishedAtPrecision` TimePrecision; `durationSeconds` Int (O, nominal); `summaryText` String; `searchEmbedding` [Float] (C, derived retrieval, INV-107).
- Temporal: `publishedAt` is the PUBLICATION_PROXY anchor for in-container statements; immutable unless a SOURCE_CORRECTION.
- Edges: `RENDITION_OF` <- Source; `HAS_SEGMENT` -> EpisodeSegment; `HAS_EPISODE` <- Channel/Series; `APPEARS_IN` <- Person/PseudonymousActor (asserted, `AppearanceProperties`); `SPONSORS_CONTENT` <- Organization/ConsumerBrand; `OCCURS_IN` <- ClaimOccurrence; legacy `MENTIONS` -> EpisodeMentionableTarget (read-only).
- Sources: SRC-W21-01..04, 06..09.

### EpisodeSegment
- Meaning: a delimited part of an Episode (sponsor read, dynamic ad, chapter, introduction, prepared remarks, Q&A, disclaimer) as published or identified. Not a time range and not an event.
- Archetype InformationArtifact; labels `["EpisodeSegment","InformationArtifact"]`; uid token `episode-segment`.
- Properties: `segmentType` String (SPONSOR_READ, DYNAMIC_AD, EDITORIAL, CHAPTER, INTRODUCTION, PREPARED_REMARKS, Q_AND_A, DISCLAIMER, OTHER; I/O; enum candidate W21-SR-02); `chapterTitleVerbatim` String (O); `delimitationBasis` String (PUBLISHER_CHAPTER, RENDITION_TRANSCRIPT_CUE, MANUAL, NOT_DELIMITED; Op); archetype `observedAt` = when the segment was seen in its rendition.
- Edges: `HAS_SEGMENT` <- Episode (exactly_one); `IN_RENDITION` -> Source (structural, zero_or_one; new); `DELIMITED_BY` -> SourceLocator (structural, at most one per rendition; new); `OCCURS_IN_SEGMENT` <- ClaimOccurrence.
- Rules: V-W21-02 (sponsor-read agreement), V-W21-05 (locators on the segment's rendition).

### Claim
- Meaning: proposition identity; no source, asserter, truth or evidence strength.
- Archetype Entity; labels `["Claim","Entity"]`; uid token `claim`; `@fulltext ClaimSearch`.
- Properties: `claimText` String (I, BellLabs normalized wording); `claimType` ClaimType (I); `claimPolarity` AssociationPolarity (I; direction inside the proposition); `isQuantitative`, `isCausal`, `isMechanistic` Boolean (I); `searchEmbedding` (C).
- Edges: `INSTANCE_OF` <- ClaimOccurrence/RelationshipAssertion (derived ruleOnly, W00 `DerivedEdgeProperties`; hypothesis uid in `derivedFromAssessmentUids`); `ASSESSES_CLAIM_EVIDENCE` <- ClaimEvidenceAssessment.
- Removed: `evidenceStrength` (V-418), `isClinical`, `isPreclinical`, `about`, `supportedBy`.

### ClaimOccurrence
- Meaning: one asserter's act of asserting in one container, supported by locators in that container's renditions.
- Archetype Assertion; labels `["ClaimOccurrence","Assertion"]`; uid token `claim-occurrence`; implements `AssertionArchetype` (all kernel fields; W00 owns their meaning).
- W21 properties: `utteranceText` String (display copy, O); `roleTitleVerbatim` String (O); `statedTense` String (PAST, PRESENT, FUTURE; O); `segmentKind` String (denormalized SPONSOR_READ etc.; I; must agree with segment).
- Immutability: `@mutation(operations: [CREATE, UPDATE])` (no delete) and `@settable(onCreate: true, onUpdate: false)` on every kernel and W21 payload field and on HAS_SUBJECT/HAS_OBJECT/ASSERTED_BY/OCCURS_IN, mirroring W00's generic `Assertion`; `recordedTo` writable once on update; `massBasis`, `amountReferent`, `roleCodeVerbatim` mirror W00 (W00 seam request on A11).
- Edges: `HAS_SUBJECT` (exactly_one), `HAS_OBJECT` (zero_or_one, xor literal), `ASSERTED_BY` -> ClaimSpeakerTarget (exactly_one), `OCCURS_IN` -> OccurrenceContainerTarget (exactly_one), `OCCURS_IN_SEGMENT` -> EpisodeSegment, `SUPPORTED_BY` -> SourceLocator, `SUPPORTED_BY_CHUNK` -> Chunk (derived, W20 `DerivedSupportProperties`), `WAS_GENERATED_BY` -> Activity, `INSTANCE_OF` -> Claim, `QUALIFIED_BY` <-> ClaimOccurrence (`QualificationProperties`), `RETELLS` -> Assertion (`RetellingProperties`), `ATTRIBUTES_TO` -> ClaimSpeakerTarget, `SUPERSEDES` <-> ClaimOccurrence (`SupersessionProperties`).
- Rules: INV-402, V-410, V-411, V-412, V-416, V-417, V-W21-02/04/08/11. Status is capture fidelity only.

### RelationshipAssertion
- Meaning: a structured relational assertion from a non-utterance span. Labels `["RelationshipAssertion","Assertion"]`; uid token `assertion`.
- Properties: kernel fields (same immutability as ClaimOccurrence); `roleTitleVerbatim`, `roleCodeVerbatim` String (O; structured role sources such as a disclosure page); `predicateText` String (O, verbatim); `relationshipType` String (deprecated verbatim); `subjectLabel`, `objectLabel` String (O, surface forms).
- Edges: `HAS_SUBJECT` (exactly_one), `HAS_OBJECT` (zero_or_one), `ASSERTED_BY` -> AsserterTarget (at_most_one), `SUPPORTED_BY`, `WAS_GENERATED_BY`, `INSTANCE_OF`, `SUPERSEDES`, `VISUALIZES` <- MediaAsset (W22 `MediaLinkProperties`).
- Rules: V-419, V-420.

### ClaimEvidenceAssessment
- Meaning: BellLabs' method-versioned grade of the evidence for one Claim. Labels `["ClaimEvidenceAssessment","EvidenceAssessment"]`; uid token `assessment`.
- Properties: archetype fields (`assessmentType`, `methodVersion`!, `status`!, `recordedAt`!, …); `evidenceStrength` EvidenceStrength (I; null = not graded); `criteriaVersion` String (Op); `assessedAt` DateTime.
- Edges: `ASSESSES_CLAIM_EVIDENCE` -> Claim (exactly_one); `CLAIM_EVIDENCE_BASED_ON` -> Assertion/Study/StudyResult/Publication (four typed fields, one relationship type); `ASSESSED_BY` -> Agent/Person; `SUPERSEDES`.
- Privacy: PUBLIC result; reviewer identity INTERNAL tier (access projection, W23).

### RetellingFidelityAssessment
- Labels `["RetellingFidelityAssessment","EvidenceAssessment"]`; uid token `assessment`.
- Properties: `qualificationLost` Boolean; `lostQualificationKinds` [QualificationKind]; `speechActChanged` Boolean; `speechActFrom`, `speechActTo` SpeechAct; `assertionBasisChanged`, `scopeBroadened` Boolean; `addedPurposeText` String; `quantityChanged`, `attributionChanged`, `correctionIgnored` Boolean; `assessedAt`. All I. Null = not assessed (fx04 NMN.com case).
- Edges: `ASSESSES_RETELLING` -> Assertion (exactly_one), `AGAINST_ORIGINAL` -> Assertion (exactly_one), `IDENTIFIES_LOST_QUALIFICATION` -> Assertion (many), `ASSESSED_BY`, `SUPERSEDES`.

### ConflictRelevanceAssessment
- Labels `["ConflictRelevanceAssessment","EvidenceAssessment"]`; uid token `assessment`.
- Properties: `relevanceLevel` RelevanceLevel; `relevanceBasis` RelevanceBasis; `temporalOverlap` TemporalOverlap; `disclosureFinding` DisclosureFinding; `scopeAmbiguity` String; `assessedAt`. All I.
- Edges: `FOR_OCCURRENCE` -> Assertion (exactly_one); `ASSESSES_INTEREST` -> Assertion (one_or_more, FINANCIAL_INTEREST predicates); `SUPPORTED_BY` -> SourceLocator (disclosure span; required when DISCLOSED_IN_CONTAINER, V-W21-09); `ASSESSED_BY`; `SUPERSEDES`.

### ExperienceReport (RETIRED)
- Folded into `ClaimOccurrence` with `assertionBasis` PERSONAL_EXPERIENCE. Live `reportText` -> `utteranceText` + locator; `about` -> `HAS_SUBJECT`/`HAS_OBJECT` (one per proposition); `authors` -> `ASSERTED_BY`; `reportedBy` (CohortParticipant) -> private store (W23); `extractedFrom`/`extractedFromSegments` -> `OCCURS_IN` + `SUPPORTED_BY` / `OCCURS_IN_SEGMENT`. Maturity DEPRECATED.

### Presentation / Talk (CANDIDATE, rejected for this release)
- Evaluated against CQ-CL-C02 with the Merck JPM 2026 case (fx06). Episode (recorded talk) + Document (deck) + V-W21-03 answer every query; no failing case requires a new identity. Re-open only if a talk with no recording and no deck needs its own container (then the container is W18's `Event`, not a new type).

## B. Relationship types owned by W21

| Type | Domain -> range | Class | Cardinality | Properties | Notes |
|---|---|---|---|---|---|
| OCCURS_IN | ClaimOccurrence -> Episode / Document / Publication | structural | exactly_one per occurrence | none | Publication added (W21-D05) |
| OCCURS_IN_SEGMENT (use; name shared with W20 chunk edge) | ClaimOccurrence -> EpisodeSegment | structural | many | none | |
| APPEARS_IN | Person / PseudonymousActor -> Episode | asserted | many | AppearanceProperties | roleType from W01 RoleType (+HOST, CO_HOST, GUEST, MODERATOR) |
| SERVES_ON_CHANNEL | Person -> Channel | asserted | many | AppearanceProperties | channel-level host role |
| OPERATES_CHANNEL | Organization -> Channel | asserted | many | AssertedEdgeProperties | predicate registration W21-SR-15 |
| HOSTS_CHANNEL | Platform -> Channel | structural | exactly_one per channel | StructuralEdgeProperties | |
| ON_PLATFORM | PseudonymousActor -> Platform | structural | many | StructuralEdgeProperties | Episode -> Platform retired |
| HAS_SERIES | Channel -> Series | structural | many | StructuralEdgeProperties | |
| HAS_EPISODE | Channel / Series -> Episode | structural | many | StructuralEdgeProperties | INCLUDES_EPISODE merged |
| INCLUDES_EPISODE | — | retired | — | — | merged into HAS_EPISODE |
| HAS_SEGMENT | Episode -> EpisodeSegment | structural | exactly_one episode per segment | StructuralEdgeProperties | |
| IN_RENDITION (new) | EpisodeSegment -> Source | structural | zero_or_one | none | W21-SR-04 |
| DELIMITED_BY (new) | EpisodeSegment -> SourceLocator | structural | at most one per rendition | none | W21-SR-03 |
| DISTRIBUTES_RENDITION (new) | Channel -> Source | structural | zero_or_one channel per rendition | StructuralEdgeProperties | W21-SR-05 |
| QUALIFIED_BY | Assertion -> Assertion (SDL: ClaimOccurrence) | structural | many; same container | QualificationProperties | V-416 |
| RETELLS | Assertion -> Assertion | structural | many; acyclic | RetellingProperties | V-412, V-413 |
| ATTRIBUTES_TO | Assertion -> Person / Organization / PseudonymousActor / AnonymousActor | structural | zero_or_one | none | never the asserter (V-W21-04) |
| INSTANCE_OF | Assertion -> Claim | derived (ruleOnly) | zero_or_one | DerivedEdgeProperties (W00) | V-417; hypothesis-backed edges set `derivationRule` and put the hypothesis uid in `derivedFromAssessmentUids` (W00 D-W00-18) |
| ASSESSES_CLAIM_EVIDENCE | ClaimEvidenceAssessment -> Claim | structural | exactly_one | none | |
| CLAIM_EVIDENCE_BASED_ON | ClaimEvidenceAssessment -> Assertion / Study / StudyResult / Publication | structural | many | none | |
| ASSESSES_RETELLING / AGAINST_ORIGINAL | RetellingFidelityAssessment -> Assertion | structural | exactly_one each | none | V-415 |
| IDENTIFIES_LOST_QUALIFICATION | RetellingFidelityAssessment -> Assertion | structural | many | none | |
| FOR_OCCURRENCE | ConflictRelevanceAssessment -> Assertion | structural | exactly_one | none | V-425 |
| ASSESSES_INTEREST | ConflictRelevanceAssessment -> Assertion | structural | one_or_more | none | V-425 |
| SPONSORS_CONTENT | Organization / ConsumerBrand -> Episode / Series / Channel / Document / Conference | asserted (FINANCIAL_INTEREST) | many | AssertedEdgeProperties | V-421, V-W21-07; never ENDORSES_PRODUCT |
| RECOMMENDS | Person -> RecommendableTarget (W21-SR-18) | derived | many | DerivedEdgeProperties (derivationRule + one derivedFromAssertionUids) | CL-016; V-W21-06 replaces V-423 (W21-SR-07) |
| SPONSORS_PRODUCT, AUTHORS, REPORTS, EXTRACTED_FROM, EXTRACTED_FROM_SEGMENT, UTTERED_BY | — | retired | — | — | see migration-map.yaml |

## C. Relationship-property types

| Type | Specializes (embeds every field) | Added fields | Used by |
|---|---|---|---|
| QualificationProperties | StructuralEdgeProperties | `relationshipUid` String!, `qualificationKind` QualificationKind! | QUALIFIED_BY |
| RetellingProperties | StructuralEdgeProperties | `relationshipUid` String!, `retellingMode` RetellingMode!, `linkBasis` RetellingLinkBasis!, `hypothesisUid`, `citationLocatorUid` | RETELLS |
| AppearanceProperties | AssertedEdgeProperties | `roleType` RoleType!, `roleTitleVerbatim` | APPEARS_IN, SERVES_ON_CHANNEL |

## D. Enum and unions

- `ClaimType` (owner W21): live values unchanged (MECHANISTIC_CLAIM … UNKNOWN). Topic of the proposition; not the basis or the speech act.
- `ClaimSpeakerTarget` = Person | Organization | PseudonymousActor | AnonymousActor (replaces live ClaimSpeaker and ExperienceAuthor).
- `OccurrenceContainerTarget` = Episode | Document | Publication.
- `EpisodeMentionableTarget` = Event | TechnologyPlatform | ToolOrInstrument | ManufacturingProcess | ManufacturingStep | IngredientMaterial | Treatment | Procedure | SafetySignal (legacy read-only).
- Candidates not in SDL: `RecommendableTarget` (owner seam W21-SR-18: Protocol | ChemicalSubstance | IngredientMaterial | FoodItem | FoodProduct | Organization | ConsumerBrand | Product | Treatment | Lifestyle | Procedure); string-vocabulary enums `PlatformType`, `ChannelType`, `SeriesType`, `EpisodeType`, `EpisodeSegmentType` (W21-SR-02).

## E. Asserted predicates used or requested by W21

Registered and used: SELF_REPORTED_DAILY_INTAKE, RECOMMENDS_DAILY_INTAKE, STATES_INDIVIDUAL_DIFFERENCE, SPONSORS_CONTENT, BOARD_MEMBER_OF, APPEARS_IN. Requested (status PROPOSED in fixtures until registered, W21-SR-15): SELF_REPORTED_PRACTICE (literal practice description), OPERATES_CHANNEL, FORECASTS_COMMERCIAL_OPPORTUNITY, REPORTS_LIFESPAN_EFFECT (the last two are illustrative; W03/W09/W15 may own better names).
