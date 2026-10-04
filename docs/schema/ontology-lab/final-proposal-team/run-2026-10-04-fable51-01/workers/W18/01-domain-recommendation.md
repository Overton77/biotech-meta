# W18 01 Domain recommendation: communities, events and narrative arcs

Worker W18 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 (`8fb50ff0…84f0`), live schema `86b5e0b5…f112` (lines 498, 569–570, 1103–1104, 2042–2179). Canonical module: `events_and_narrative` (catalog maturity `future`; owns `Community`, `Conference`, `Event`, `NarrativeArc` as seams; "SPONSORS_CONTENT may target Conference"). Dependencies: kernel, provenance, organizations (W01), claims_and_documents (W20, W21); readers of regulatory (W13) and study/publication (W09) records.

## 1. Boundary in one paragraph

W18 owns **dated public occurrences** (`Event`), the **organized meetings** where many of them happen (`Conference`), the small set of **self-identified groups** that host them (`Community`), and **curated interpretations** that string events into a story (`NarrativeArc`), plus the participation edges people and companies have with those occurrences. It does not own what the occurrences are about (products W04, studies and publications W09, regulatory records W13), the people and companies (W01), the recordings and decks (W21 `Episode`, W20 `Document`), or what anyone *says* about events (W21 claims, W00 assertions). The rule that shapes everything else: **an event's times, participants, subjects and causes are each the projection of an Assertion; order is computed and never causal; an arc interprets events and is never cited.**

## 2. Subdomains and the identity / state / artifact / occurrence split

| Subdomain | Element | Archetype | Identity basis | What it is not |
|---|---|---|---|---|
| Occurrence | `Event` `["Event","Occurrence"]` | Occurrence | `uid`; one occurrence, many reports | not the regulatory or publication record (`DOCUMENTED_BY_RECORD` → W13/W09), not a source, not evidence |
| Meeting edition | `Conference` `["Conference","Entity"]` | Entity | organizer-named edition (`44th Annual …`, `TLM 2026`) | not the recurring series (presentation `seriesName`), not a session (`Event`), not the host |
| Group | `Community` `["Community","Entity"]` | Entity | self-identified group without legal identity | not an `Organization` (AASLD is W01), not a membership roster (private) |
| Interpretation | `NarrativeArc` `["NarrativeArc","EvidenceAssessment"]` | EvidenceAssessment | method-versioned curated selection at a recorded viewpoint | not a source, not a warrant, no truth, no score; not a W21 Series/Channel |
| Impact judgment | `EventImpactAssessment` `["EventImpactAssessment","EvidenceAssessment"]` (CANDIDATE) | EvidenceAssessment | one event, one domain, optional subject, one method | not a property of the event; not a causal claim |
| Clocks | `Event.startedAt/endedAt` (valid), `announcedAt` (publication), `effectiveFrom` (effect); `Assertion.recordedAt` (recorded); `SourceSnapshot.retrievedAt/observedAt` | — | each materialized from a named assertion | no single `date` field |

No VersionedState is introduced: lifecycle (`eventStatus`) and clocks are projections of immutable assertions; a late or corrected fact is a new assertion and the projection is recomputed (fixture 01: EU authorisation MONTH from the company, DAY from EMA two recorded hours later).

## 3. Disposition of every live and catalog element in scope

Vocabulary: keep, refine, merge, split, seam, derive, retire, defer, add. Field-level list: `migration-map.yaml`.

| Element (live line / catalog) | Disposition | Final form | Reason / failing case |
|---|---|---|---|
| `Event` (2120) | keep; refine | Occurrence `["Event","Occurrence"]`, `occurrenceType: 'Event'`, kernel fields | alignment round 0006: Event is an Occurrence |
| `Event.happenedAt` / `happenedAtEnd` | rename | `startedAt` / `endedAt` + per-bound `…Precision`, `…Basis`, `timeAssertionUid` | archetype interface fields; fixture 01 E3 "In April 2024" is MONTH precision, not 2024-04-01 |
| `Event.announcedAt` | keep; refine | `announcedAt` + `announcedAtPrecision` + `announcementAssertionUid` (rule announced-at-v1: earliest first-party publication, advance or after) | Q-EN-C02: launch announced 2024-03-14 (planned), happened 2024-04, first reported done 2024-05-07 |
| `Event.effectiveAt` | rename | `effectiveFrom` + precision + basis + `effectiveAssertionUid` (only from an `EVENT_EFFECTIVE` assertion) | contract A6 clock name; N9: effective date copied from announcement is caught (W18-V04) |
| `Event.eventCategory` / `EventCategory` | keep | unchanged 26 values; finer `eventType` controlled string added | DATA_READOUT vs PUBLICATION vs APPROVAL vs LAUNCH needed in one category set |
| `Event.eventStatus` / `EventStatus` | keep; refine semantics | materialized from assertions; `ANNOUNCED` legacy | N16: a passed planned date never makes COMPLETED (W18-V13) |
| `Event.eventPhase` / `EventPhase` | retire | computed at query time from clocks and valid-at | a stored phase is wrong the day after it is written (N12, W18-V10) |
| `Event.impactLevel` / `ImpactLevel` | split | enum kept as value of `EventImpactAssessment`; event field retired | fixture 02: one readout, HIGH for Madrigal and MODERATE for Viking under one method; a single field cannot hold both |
| `Event.sourceUrl` | retire (seam) | `Source` + snapshot + locator behind the event's assertions | a URL is not a locator (alignment 0006) |
| `Event.summaryText`, search fields, `searchEmbedding` | keep | unchanged; `@vector` re-added by Fable (D-014) | retrieval |
| `Event.involves` (`INVOLVES`, RoleMetadata) | refine | asserted, `EventRoleEdgeProperties` (`participantRole!`), range `EventParticipantTarget` | participants are actors; things move to subjects |
| `Event.about` (`ABOUT`, ExtractionMetadata) | rename | asserted `EVENT_ABOUT`, range `EventSubjectTarget` | W20 `ABOUT` is derived retrieval aboutness with ranking features; one type, one meaning |
| `Event.reportedIn` (`REPORTED_IN` → Document) | derive | `DerivedSupportProperties` (W20) with `locatorUid`; range widened to `Source` | EMA EPAR and Drugs@FDA are Sources, not Documents |
| `Event.supportedBy` (`SUPPORTED_BY` → Chunk) | rename (W20 ruling) | derived `SUPPORTED_BY_CHUNK` read-only | chunk is never a locator (INV-404) |
| `Event.causedBy` (`CAUSED_BY`, RoleMetadata) | refine | asserted, `CausalEdgeProperties` (`basisKind!`, `assertionBasis`, `speechAct`) | N1–N4: order, "based on" and basis-less claims all fail |
| `Event.followedBy` (`FOLLOWED_BY`, OrderingMetadata) | derive | `DerivedEdgeProperties`: rule `valid-time-order-v1` or projection of a source-stated order | N10: DAY 2022-12-19 vs MONTH 2022-12 has no order (W18-V08) |
| union `EventParticipant` (2042) | rename; narrow | `EventParticipantTarget = Organization \| Person \| Community` | Product/Study/Compound do not participate |
| union `EventSubject` (2044) | rename; refine | `EventSubjectTarget` (Compound → ChemicalSubstance per D-002; + Conference, Publication) | a conference can be the subject of a postponement |
| `Conference` (2104) | keep; refine | Entity edition; `startDate`/`endDate` retyped `Date`; + `seriesName`, `editionLabel`, `timeZone`, `attendanceMode` | organizer dates are local calendar dates; session instants live on `Event` in UTC |
| `Conference.location` | keep (presentation) | venue `Facility` deferred (CL-015) | |
| `Conference.websiteUrl` | keep (presentation) | the page is a `Source` | |
| `Conference.hasEvents` (`HAS_EVENT`, OrderingMetadata) | keep; refine | structural, `StructuralEdgeProperties.orderIndex`; only Conference → Event | N14: an arc using HAS_EVENT is caught (W18-V02) |
| `Community` (2093) | keep (CANDIDATE) | Entity; `communityType`; `HOSTS_EVENT` | no failing case requires more; membership is private |
| `Community.hostsEvents` (`HOSTS_EVENT`, RoleMetadata) | refine | asserted, `AssertedEdgeProperties`; domain Organization \| Community; range Event \| Conference | fixture 03: AASLD hosts TLM 2026 (assertion by AASLD); JPM host not asserted, not inferred from the name |
| `NarrativeArc` (2150) | refine; re-archetype | EvidenceAssessment (decision W18-D04) | an arc is a dated judgment that can be superseded and must be reproducible |
| `NarrativeArc.hasEvents` (`HAS_EVENT`) | rename | structural `ARC_INCLUDES_EVENT` (`orderIndex`, `notes` rationale) | live type collision with the conference program edge |
| `NarrativeArc.about` (`ABOUT`) | rename | structural `ARC_ABOUT` | part of the arc's shape, not an assertion |
| `NarrativeArc.reportedIn`, `supportedBy` | retire | none (arcs cite events; events are reported) | an arc is never a source nor supported (W18-V03) |
| `NarrativeArc.startedAt/endedAt` | rename | `periodStart/periodEnd` + precision (computed at creation) | an arc is not an occurrence |
| `NarrativeArc.arcStatus` | retire | `status: AssessmentStatus` + SUPERSEDES | "ongoing" is not a stored truth |
| `NarrativeArc.arcType`, `themeSummary`, `impactDomain` | keep | immutable after create | |
| live union `Sponsorable` (498) | rename; widen | `SponsorableTarget = Conference \| Channel \| Episode \| Series \| Document` | catalog SPONSORS_CONTENT range (round 0006) |
| `Organization.sponsors` (`SPONSORS`, 569) | move | W21 `SPONSORS_CONTENT` (asserted, FINANCIAL_INTEREST) | bare SPONSORS collides with SPONSORS_STUDY (W01) |
| `Organization.exhibitsAt` (`EXHIBITS_AT`, 570) | keep; refine | asserted, `EventRoleEdgeProperties`; Organization → Conference | |
| `Person.speaksAt` (`SPEAKS_AT`, 1103) | keep; refine | asserted, `EventRoleEdgeProperties`; Person → Event | fixture 03: Merck transcript names Davis (PRESENTER) and Schott (MODERATOR) |
| `Person.attends` (`ATTENDS`, 1104) | keep; refine | asserted; public persons only (W18-V11) | attendance of a private person is behaviour data |
| catalog `SPONSORS_CONTENT` → Conference | seam (W21 edge) | W18 writes `Conference.sponsoringOrganizations/Brands` IN fields | |
| (new) `DOCUMENTED_BY_RECORD`, `RECORDING_OF`, `PRESENTED_AT`, `ASSESSES_EVENT`, `IMPACT_ON`, `EventRecordTarget`, `EventRoleEdgeProperties`, `CausalEdgeProperties`, `RecordingEdgeProperties`, `EventImpactAssessment` | add (registry admission requested) | see model cards | each has a fixture and a CQ |

## 4. Real cases that settled the model

1. **Company milestone timeline vs regulatory record (Rezdiffra).** Madrigal's releases and filings give: topline readout disclosed 2022-12-19 07:00 ET; FDA accelerated approval "today" 2024-03-14; US availability "expected … in April" (stated 2024-03-14) and "In April 2024, product shipped" (8-K 2024-05-07); EC conditional authorisation "today announced" 2025-08-19 and "in August 2025"; Germany launch "in September" (Q3 release 2025-11-04). The regulator records give Drugs@FDA "Original Approvals: 03/14/2024" (W13, inherited) and EMA "conditional marketing authorisation valid throughout the EU on 18 August 2025". So **announced 2025-08-19 ≠ effective 2025-08-18**, and **announced (plan) 2024-03-14 ≠ happened 2024-04 ≠ first reported done 2024-05-07**. ClinicalTrials.gov NCT03900429 shows primary completion 2028-01 and no posted results: a readout is a disclosure occurrence, not the registry's completion milestone.
2. **Conference with a talk recording (JPM 2026).** Madrigal's IR page lists the session with "Listen to webcast 19.8 MB" and "Presentation 1.2 MB"; Merck's event page lists webcast, transcript and presentation links, and the webcast page now says "The recording of this session is not available any more" (W21 excerpts). Decision: the session is an `Event` (HAS_EVENT from the `Conference`); the recording is a W21 `Episode` linked `RECORDING_OF` the Event; the deck is a `Document` `PRESENTED_AT` the Event. **No direct Conference ↔ Episode edge**: the path goes through the session, and a deck links to the occurrence, not to the recording (CL-003 R4; W18-V06 catches a deck declared a rendition of the recording).
3. **Data readout whose retelling asserts causation.** An Entrepreneur.com article (originally MarketBeat) says Madrigal's results "sent their stock soaring", that Viking's stock "soared for a somewhat unique reason: the success of a peer", and later that "Viking's successful NASH trial led to Madrigal share value also taking a big step forward" — reversing the direction. It also says Viking's stock jumped "after" Madrigal released results (order only). Decision: three `CAUSED_BY` assertions (two STATES/INFERRED_FROM_MEASUREMENT, one SPECULATES/HYPOTHESIS) with capture accepted and support `NOT_ASSESSED`; the "after" sentence is a source-stated `FOLLOWED_BY` only. Madrigal's "Accelerated approval was based on Phase 3 data" is a regulatory-basis statement for W13, not an event-to-event cause (N4).
4. **Sponsorship vs endorsement (AASLD TLM 2026).** AASLD announces a travel award for The Liver Meeting 2026 "made possible through the support of Madrigal Pharmaceuticals"; AASLD separately published resmetirom practice guidance (Hepatology 2025;81:312, PMID 39422487). The graph holds `HOSTS_EVENT(AASLD → TLM 2026)` and `SPONSORS_CONTENT(Madrigal → TLM 2026)`; no endorsement edge exists or may be derived (N5 is caught by V-422, V-112, W18-V05). The guidance is a separate Publication whose own content (not captured here) would carry any recommendation.

## 5. Alternatives considered

| Question | Alternative | Rejected because |
|---|---|---|
| Where do event times live? | authoritative properties on `Event` | two asserters disagree in precision (Madrigal MONTH vs EMA DAY); a late fact must not overwrite history; "as recorded at R" needs assertion recorded time (Q-EN-C01a vs C01b) |
| `announcedAt` = first report of completion only | separate field per meaning | sessions are announced in advance (JPM PR 2025-12-15); the announcement assertion uid tells advance vs after; first-reported-done is derivable (Q-EN-C02 column) |
| Conference as Occurrence | conference = the holding | an edition is announced, sponsored and exhibited at before it happens and may never happen; postponement is an Event about the Conference |
| Conference series as a type | `ConferenceSeries` + `EDITION_OF` | no CQ needs cross-edition identity yet; `seriesName` is presentation; kept CANDIDATE |
| `Presentation`/`Talk` work type (W21 candidate) | separate work node for each talk | the session occurrence (Event) + recording work (Episode) + deck (Document) cover all four researched shapes; a session never recorded has no work to invent |
| Deck ↔ talk direct edge (W19-SR-07 `ACCOMPANIES_PRESENTATION`) | Document → Episode | fails for an unrecorded session and for a deck reused at two sessions; `PRESENTED_AT` targets the occurrence |
| NarrativeArc as InformationArtifact | artifact with contentHash/publishedAt | artifacts are what citations point at; no methodVersion/status/recordedAt lifecycle; "as recorded at R, which arc did we publish?" unanswerable |
| NarrativeArc as live Entity (current) | identity with mutable members | members change silently; no reproducibility |
| ImpactLevel as Event property | keep live field | no assessor, method, subject or time; conflicting judgments collapse |
| `CAUSED_BY` as derived | derivation from order + co-mention | that is exactly the forbidden implication [FOLLOWED_BY, CAUSED_BY] |
| Share W20 `ABOUT` | one `ABOUT` type for documents, chunks, events, arcs | W20's ABOUT is derived with retrieval scores; event aboutness is asserted; arc aboutness structural |
| Keep `HAS_EVENT` for arcs | same type for program membership and interpretive selection | label-less traversals from a Conference would return arc members (N14) |

## 6. Smallest recommended model

Four live node types kept (Event PROVISIONAL; Conference PROVISIONAL; Community CANDIDATE; NarrativeArc CANDIDATE re-archetyped), one candidate node type (`EventImpactAssessment`), three enums (live values; `EventPhase` retired), four unions (three renamed live, one new), three relationship-property types, and relationship types: structural `HAS_EVENT`, `ARC_INCLUDES_EVENT`, `ARC_ABOUT`, `ASSESSES_EVENT`, `IMPACT_ON`; asserted `HOSTS_EVENT`, `INVOLVES`, `EVENT_ABOUT`, `CAUSED_BY`, `EXHIBITS_AT`, `SPEAKS_AT`, `ATTENDS`, `DOCUMENTED_BY_RECORD`, `RECORDING_OF`, `PRESENTED_AT`; derived `REPORTED_IN`, `FOLLOWED_BY` (plus W20's `SUPPORTED_BY_CHUNK` field). Event assertion predicates to register: `EVENT_OCCURRED`, `EVENT_SCHEDULED`, `EVENT_CANCELLED`, `EVENT_EFFECTIVE` and the asserted relationship names above. No kernel change; two kernel vocabulary additions requested (`statedTense` FUTURE, `ActivityKind.CURATION`).

## 7. Rules for writers (application-enforced; validators in `operations.cypher`)

1. An Event node is created with `occurrenceType`, name and category only; every time, participant, subject, record link and cause arrives as an Assertion and its projection (W18-V04, W18-V09).
2. `effectiveFrom` is written only from an `EVENT_EFFECTIVE` assertion; never from `announcedAt` (W18-V04 `EFFECTIVE_FROM_PUBLICATION_PROXY`).
3. A `CAUSED_BY` edge requires a POSITIVE `CAUSED_BY` assertion with `basisKind`, subject = effect, object = cause (W18-V01; V-112 for forbidden premises).
4. `FOLLOWED_BY` is computed (`valid-time-order-v1`: earlier event's latest end at its precision ≤ later event's earliest start) or projected from a source-stated order; never written by hand and never read as cause (W18-V08).
5. A NarrativeArc is created once with its members, method, viewpoint and generating Activity; a revision is a new arc that SUPERSEDES; nothing may point SUPPORTED_BY, CONSIDERS_ASSESSMENT or `derivedFromAssessmentUids` at it (W18-V03).
6. Endorsement is never derived from SPONSORS_CONTENT, HOSTS_EVENT, EXHIBITS_AT, SPEAKS_AT, ATTENDS or INVOLVES (W18-V05, V-422).
7. SPEAKS_AT / ATTENDS / INVOLVES only touch public persons (W18-V11); communities carry no membership.
8. Regulatory events carry `jurisdiction` (W18-V07, contract A11).
