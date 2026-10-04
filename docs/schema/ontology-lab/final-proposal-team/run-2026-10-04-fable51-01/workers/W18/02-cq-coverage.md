# W18 02 CQ coverage

Priority and answerability come from `competency-questions.md` (A answerable, Q with qualifications). Query ids refer to `fixtures/w18-80-queries.cypher`, validators `W18-Vnn` to `operations.cypher` part C, baseline `V-nnn` to `docs/schema/neo4j/validation.cypher`. All listed queries were **run** on Neo4j 5.26.31 Community (embedded) on 2026-10-04; results in `06-fixtures-and-queries.md`.

## 1. Existing CQs

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Proposed element(s) | Query | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-TM-03 (Foundational, A) distinguish publication, observation, retrieval, study, effective and ingestion time | "EU conditional authorisation: happened 2025-08-18 (DAY, EMA), announced 2025-08-19 (Madrigal release), effective 2025-08-18 (EMA), recorded 2026-10-04T06:00Z, source retrieved 2026-10-04T01:30Z" | valid (`startedAt`) vs publication (`announcedAt`) vs effect (`effectiveFrom`) vs recorded (`Assertion.recordedAt`) vs retrieval (`SourceSnapshot.retrievedAt`) | one assertion per clock, each with locator; snapshot times | `Event.startedAt/…Precision/…Basis/timeAssertionUid`, `announcedAt/…Precision/announcementAssertionUid`, `effectiveFrom/…/effectiveAssertionUid`; predicates `EVENT_OCCURRED`, `EVENT_SCHEDULED`, `EVENT_EFFECTIVE` | Q-EN-C02, Q-PV-01-event; W18-V04, W18-V07 | live `happenedAt/announcedAt/effectiveAt` with no basis, precision or source; effective date copied from the announcement (N9) |
| CQ-EC-01 (Foundational, Q) neighbourhood of X valid at V as recorded at R | "Madrigal: presented at JPM 2026 (session 2026-01-12T21:30Z); supports AASLD TLM 2026 travel award (SPONSORS_CONTENT, financial-interest member); AASLD hosts TLM 2026; no endorsement edge." | participation (event role) vs organizational role vs financial interest vs endorsement | asserted edges with assertionUid | `INVOLVES`, `SPEAKS_AT`, `ATTENDS`, `EXHIBITS_AT`, `HOSTS_EVENT` with `EventRoleEdgeProperties`; `SPONSORS_CONTENT` (W21) to `Conference` | Q-EN-C04a, Q-EN-C04b | neighbourhood inflated by name ("J.P. Morgan" in a conference name is not a host edge; Q-MISSING) and by sponsorship read as endorsement (N5) |
| CQ-PV-01 (Essential now, Q) five provenance states for an assertion in an answer | "EU authorisation date said by EMA (state 1), span 'valid throughout the EU on 18 August 2025' in snapshot 2026-10-04 PARTIAL_EXCERPT (state 2), no warranting assessment (state 3; arcs excluded), no using activity recorded (state 4), policy not modelled here (state 5)." | arc is never state 2 or 3 | locator chain; assessment typing | `NarrativeArc` as EvidenceAssessment excluded from state 3; W18-V03 | Q-PV-01-event, Q-EN-C05 | a curated arc shown as a source or warrant (N6, N7) |
| CQ-EV-01 (Essential now) which source supports this fact | "E2 reported in Drugs@FDA NDA 217785 (locator SECTION) and Madrigal release 2024-03-14 (TEXT_QUOTE)" | REPORTED_IN shortcut vs locator support | locator behind an event assertion | `REPORTED_IN` derived with `DerivedSupportProperties.locatorUid`; range `Source` | fixture 01 rows; V-112 | an event "reported in" a document with no span (live ExtractionMetadata) |
| CQ-CL-01 (Essential now) who said it, in which container | "Merck JPM 2026 session: Robert Davis (PRESENTER, 'Chairman of the Board, President, Chief Executive Officer'), Christopher Schott (MODERATOR, 'Analyst'), asserted from the transcript; Madrigal session: speaker not stated." | presenting company vs speaker vs host; role at event vs employment | transcript or agenda locator | `SPEAKS_AT`, `INVOLVES {participantRole: PRESENTER}`, `roleTitleVerbatim` | Q-EN-C04a, Q-MISSING | inventing a speaker from the presenting company; turning a speaker title into EMPLOYED_BY |
| CQ-ST-09 (Essential now, A) findings in a period that changed a synthesis | Not answered by events. W18 contributes only: "the MAESTRO-NASH readout (2022-12-19) and NEJM publication (2024-02-08) are events DOCUMENTED_BY_RECORD the Publication"; the synthesis change and its trigger remain W10's `EvidenceSynthesis -TRIGGERED_BY->` | a timeline event vs an evidence trigger | publication record | `DOCUMENTED_BY_RECORD` → `Publication` | Q-EN-C02 (record column) | reading a timeline (or an arc) as the reason a synthesis changed (forbidden [ARC_INCLUDES_EVENT, CAUSED_BY]) |

## 2. Candidate CQs (W18, candidate)

| Id | Question | Rationale and failing case | Elements | Query |
|---|---|---|---|---|
| CQ-EN-C01 (proposed Foundational, A) | Which dated milestones (filing, readout, publication, approval, launch, recall) form X's timeline, with each clock and its asserter, valid at V, **as recorded at R**? | fixture 01: at R1 = 04:30Z the EU authorisation is "2025-08 MONTH by Madrigal" with no effective date; at R2 = 09:00Z it is "2025-08-18 DAY by EMA" and effective 2025-08-18. A stored date field cannot answer R1. | `Event` clocks, `EVENT_*` assertions, `EVENT_ABOUT`, `FOLLOWED_BY` | Q-EN-C01a, Q-EN-C01b |
| CQ-EN-C02 (proposed Essential for regulatory answers, A) | For a milestone, when did it happen, when was it announced and by whom (in advance or after), when did it take effect, and which authoritative record documents it? | fixture 01: US launch announced 2024-03-14 (plan), happened 2024-04 (MONTH), first reported done 2024-05-07; EU authorisation announced 2025-08-19, effective 2025-08-18; FDA approval documented by the W13 RegulatoryResponse (issued 2024-03-14). Company dates alone would give "approved 2025-08-19". | `announcedAt`, `effectiveFrom`, `DOCUMENTED_BY_RECORD`, `EventRecordTarget` | Q-EN-C02 |
| CQ-EN-C03 (proposed Foundational, Q) | Which events are claimed to cause which, by whom, on what basis and speech act, was support ever assessed, and which effects have competing causal claims? Which ordered pairs have no causal claim? | fixture 02: one article claims readout → MDGL rise (STATES), readout → VKTX rise (STATES), Viking trial → MDGL rise (SPECULATES); support NOT_ASSESSED. N1/N2/N4: order, a source-stated "after", and "based on" fail as causal premises. | `CAUSED_BY` + `CausalEdgeProperties`, `FOLLOWED_BY` derived | Q-EN-C03a, Q-EN-C03b; W18-V01, V-112 |
| CQ-EN-C04 (proposed Foundational, Q) | Which sessions of a conference edition did X present at, with which speakers (role at the event), recordings (and their availability) and decks; who hosted, sponsored and exhibited — without endorsement inference? | fixture 03: Merck JPM 2026 recording "not available any more" while transcript and deck exist; Madrigal session has recording and deck but no stated speaker; TLM 2026 host AASLD, sponsor Madrigal, 0 endorsement edges. | `Conference`, `HAS_EVENT`, `SPEAKS_AT`, `RECORDING_OF`, `PRESENTED_AT`, `HOSTS_EVENT`, `EXHIBITS_AT`, `SPONSORS_CONTENT`, `SponsorableTarget` | Q-EN-C04a, Q-EN-C04b; W18-V05, W18-V06 |
| CQ-EN-C05 (proposed Foundational, A) | Which narrative arc (method, viewpoint) was current as recorded at R, which events does it cite, and is any arc used as support, warrant or derivation input? | fixture 04: at 05:00Z arc v1 (4 events, viewpoint 04:30Z); at 09:00Z arc v2 (6 events) supersedes it. N6/N7: arc as support, warrant, derivation input, or carrying a score. | `NarrativeArc`, `ARC_INCLUDES_EVENT`, `ARC_ABOUT`, `SUPERSEDES`, `WAS_GENERATED_BY` | Q-EN-C05; W18-V03 |
| CQ-EN-C06 (proposed Expansion, Q) | How significant was event E for subject S in domain D, by which method and assessor, as recorded at R? | fixture 02: readout HIGH (MARKET) for Madrigal, MODERATE for Viking, method `event-impact-market-v0` (synthetic judgments); live single `impactLevel` cannot hold both. N13: no method. | `EventImpactAssessment`, `ASSESSES_EVENT`, `IMPACT_ON`, `ImpactLevel` | Q-EN-C06; W18-V12 |

## 3. Element-to-requirement map (every SDL element)

| SDL element | CQ / invariant / ingestion failure |
|---|---|
| `EventCategory` (26 live values) | CQ-EN-C01 facet; live compatibility |
| `ImpactLevel` | CQ-EN-C06 (value of the assessment only) |
| `EventStatus` | CQ-EN-C01 lifecycle; W18-V13 (planned ≠ occurred) |
| `EventParticipantTarget` | CQ-EC-01, CQ-CL-01 (INVOLVES range) |
| `EventSubjectTarget` | CQ-EN-C01 (EVENT_ABOUT), CQ-EN-C05 (ARC_ABOUT), CQ-EN-C06 (IMPACT_ON) |
| `SponsorableTarget` | CQ-EN-C04, catalog SPONSORS_CONTENT range; forbidden [SPONSORS_CONTENT, ENDORSES_PRODUCT] |
| `EventRecordTarget` | CQ-EN-C02 |
| `EventRoleEdgeProperties` | CQ-EC-01, CQ-CL-01; W18-V09 (participantRole required) |
| `CausalEdgeProperties` | CQ-EN-C03; W18-V01 |
| `RecordingEdgeProperties` | CQ-EN-C04 (coverage) |
| `Community` (all fields, `hostsEvents`, `hostsConferences`, `involvedInEvents`) | CQ-EN-C04 (host); contract A9 (no membership) |
| `Conference` kernel fields, `conferenceType`, `seriesName`, `editionLabel`, `startDate`, `endDate`, `timeZone`, `location`, `attendanceMode`, `websiteUrl` | CQ-EN-C04; live compatibility (location, websiteUrl presentation) |
| `Conference.hostedByOrganizations/Communities`, `hasEvents`, `exhibitors`, `attendees`, `sponsoringOrganizations/Brands`, `subjectOfEvents` | CQ-EN-C04, CQ-EC-01 |
| `Event` kernel fields, `occurrenceType`, `startedAt`, `endedAt`, precision/basis fields, `timeAssertionUid` | CQ-TM-03, CQ-EN-C01; W18-V04, W18-V07 |
| `Event.announcedAt/…Precision/announcementAssertionUid` | CQ-TM-03, CQ-EN-C02 |
| `Event.effectiveFrom/…Precision/…Basis/effectiveAssertionUid` | CQ-TM-03, CQ-EN-C02; W18-V04 |
| `Event.localTimeZone` | CQ-EN-C04 (session stated as "1:30pm PST" and "4:30 PM EST"; both 21:30Z) |
| `Event.jurisdiction` | contract A11; W18-V07 |
| `Event.eventCategory`, `eventType`, `eventStatus`, `summaryText`, search fields | CQ-EN-C01 facets; QS-8 retrieval (EventSearch fulltext) |
| `Event.conference` | CQ-EN-C04 |
| `Event.hostedByOrganizations/Communities`, `involves`, `about`, `documentedBy` | CQ-EC-01, CQ-EN-C01, CQ-EN-C02 |
| `Event.reportedIn`, `supportedByChunks` | CQ-EV-01 (derived, read-only) |
| `Event.causedBy`, `causes` | CQ-EN-C03 |
| `Event.followedBy`, `precededBy` | CQ-EN-C01, CQ-EN-C03 minimal pair; W18-V08 |
| `Event.speakers`, `recordings`, `presentedDocuments` | CQ-EN-C04, CQ-CL-01; W18-V06 |
| `Event.includedInArcs`, `impactAssessments` | CQ-EN-C05, CQ-EN-C06 (read-only inverse views) |
| `NarrativeArc` all fields and edges | CQ-EN-C05, CQ-PV-01; W18-V03 |
| `EventImpactAssessment` all fields and edges | CQ-EN-C06; W18-V12 |

## 4. Forbidden implications in this module (each has a negative fixture or validator)

| Premise → conclusion | Negative | Check |
|---|---|---|
| FOLLOWED_BY → CAUSED_BY | N2 (source-stated "after" cited as cause), N1 (temporal-order rule) | V-112 `FORBIDDEN_IMPLICATION_USED_AS_PREMISE` / `DERIVATION_WITHOUT_SOURCE_ASSERTIONS`; W18-V01 |
| ARC_INCLUDES_EVENT → CAUSED_BY (and arc → support) | N6 | W18-V03 |
| APPROVAL_BASED_ON (regulatory basis) → CAUSED_BY | N4 | V-112, W18-V01 |
| EVENT_SCHEDULED → EVENT_OCCURRED | N16 | W18-V13 |
| announcement → effect (announcedAt → effectiveFrom) | N9 | W18-V04 |
| SPONSORS_CONTENT / HOSTS_EVENT / EXHIBITS_AT / SPEAKS_AT → ENDORSES_PRODUCT | N5 | V-422, V-112 (`FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS`), W18-V05 |
| SPONSORS_CONTENT → HOSTS_EVENT | none needed in fixtures (Madrigal is not a host in Q-EN-C04b) | pair registered in params |
| PRESENTED_AT (deck) → RENDITION_OF (recording) | N15 | W18-V06 (W21 V-W21-03) |
| name contains organization → HOSTS_EVENT | Q-MISSING (JPM host 0 edges) | none; never inferred |
