# W18 04 Model cards

Conventions: privacy class PUBLIC unless stated; "kind" = asserted / observed / calculated / inferred / operational; every node carries its primary label and its archetype label; `id` = opaque segment of `uid`. Relationship class and cardinality are enforced by `operations.cypher` part C and the writing service, never by SDL. Maturity proposed for the 0.3 catalog.

## 1. Nodes

### Event — `["Event","Occurrence"]`, uid token `event` (requested W18-SR-01), PROVISIONAL

- **Meaning.** A dated public occurrence reported by sources (filing, data readout = public disclosure of results, publication, approval, launch, recall, financing, conference session, share-price move). Not the regulatory/publication record that documents it, not a source, not evidence for its subjects.
- **Identity.** One occurrence = one node, however many sources report it; resolution of duplicates by `EquivalenceAssessment` (W00). Display name never identity. For sessions: (conference edition, presenting party, start instant). For regulatory events: (subject, jurisdiction, record) — `DOCUMENTED_BY_RECORD` makes the record the tie-breaker.
- **Properties.**

| Property | Type | Kind | Temporal / value-state semantics |
|---|---|---|---|
| `occurrenceType` | String! | operational | always `Event` |
| `startedAt`, `endedAt` | DateTime | asserted (materialized) | valid time, half-open; first instant of the precision period; null = unknown, never "ongoing"; equals `validFrom/validTo` of `timeAssertionUid` (W18-V04) |
| `startedAtPrecision`, `endedAtPrecision` | TimePrecision | asserted | required when the bound is non-null (W18-V07) |
| `startedAtBasis`, `endedAtBasis` | ValidTimeBasis | asserted | STATED_BY_SOURCE / PUBLICATION_PROXY / INFERRED / UNKNOWN |
| `timeAssertionUid` | String | operational | the `EVENT_OCCURRED` (or, while PLANNED, `EVENT_SCHEDULED`) assertion materialized; selection rule `event-time-materialization-v1`: most precise non-rejected EVENT_OCCURRED; ties → the asserter whose authority scope covers the event kind (regulator for regulatory acts, W19 AuthorityScope) |
| `announcedAt`, `announcedAtPrecision` | DateTime, TimePrecision | calculated | rule `announced-at-v1`: earliest `SourceSnapshot.publishedAt` behind an EVENT_OCCURRED or EVENT_SCHEDULED assertion whose asserter is a participant (`INVOLVES`) of the event; null when no first-party announcement is captured (third-party report dates are not announcements) |
| `announcementAssertionUid` | String | operational | tells advance (EVENT_SCHEDULED) from after-the-fact (EVENT_OCCURRED) announcement |
| `effectiveFrom`, `effectiveFromPrecision`, `effectiveFromBasis` | DateTime, TimePrecision, ValidTimeBasis | asserted (materialized) | start of the legal/regulatory/contractual effect; only from an `EVENT_EFFECTIVE` assertion; `PUBLICATION_PROXY` forbidden (W18-V04) |
| `effectiveAssertionUid` | String | operational | |
| `localTimeZone` | String (IANA) | observed | zone in which a local time was stated; instants stored in UTC |
| `jurisdiction` | String | asserted | required for REGULATORY_EVENT (W18-V07) |
| `eventCategory` | EventCategory | inferred (classification) | facet |
| `eventType` | String (controlled) | inferred | FILING, APPROVAL, CONDITIONAL_APPROVAL, LAUNCH, TOPLINE_READOUT, PUBLICATION, PRESENTATION, SHARE_PRICE_MOVE, RECALL_INITIATED, RECALL_CLASSIFIED, POSTPONEMENT, CANCELLATION, OTHER |
| `eventStatus` | EventStatus | calculated | projection over EVENT_* assertions as recorded; never truth (W18-V13) |
| `summaryText`, `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` | | operational | retrieval only (INV-107) |

- **Edges (out).** `INVOLVES` → EventParticipantTarget (asserted, `EventRoleEdgeProperties`, many); `EVENT_ABOUT` → EventSubjectTarget (asserted, one_or_more); `DOCUMENTED_BY_RECORD` → EventRecordTarget (asserted, zero_or_one per record kind); `REPORTED_IN` → Source (derived, `DerivedSupportProperties`, locatorUid required); `SUPPORTED_BY_CHUNK` → Chunk (derived, W20 type); `CAUSED_BY` → Event (asserted, `CausalEdgeProperties`); `FOLLOWED_BY` → Event (derived).
- **Edges (in).** `HAS_EVENT` from Conference (structural, zero_or_one); `HOSTS_EVENT` from Organization|Community (asserted); `SPEAKS_AT` from Person (asserted); `RECORDING_OF` from Episode (asserted); `PRESENTED_AT` from Document (asserted); `ARC_INCLUDES_EVENT` from NarrativeArc (structural); `ASSESSES_EVENT` from EventImpactAssessment (structural); `HAS_SUBJECT` from Assertion (W00).
- **Assertion predicates (register in catalog `events_and_narrative.assertedPredicates`).** `EVENT_OCCURRED` (subject Event; validFrom/validTo = happened; `statedTense` PAST/PRESENT), `EVENT_SCHEDULED` (subject Event; validFrom = planned start; `statedTense` FUTURE — value requested from W00), `EVENT_CANCELLED`, `EVENT_EFFECTIVE` (validFrom = effect start), plus the asserted relationship names below. All `predicateClass: OTHER` except regulatory record links (`REGULATORY`).
- **Forbidden.** Stored `eventPhase`, `impactLevel`, `sourceUrl`, `happenedAt`, `happenedAtEnd`, `effectiveAt` (W18-V10).
- **Sources.** live 2120–2148; alignment 0006 rows; fixtures 01–03.

### Conference — `["Conference","Entity"]`, uid token `conference`, PROVISIONAL

- **Meaning.** One organizer-announced edition of a meeting. Not the series, not a session, not a recording, not its host.
- **Identity.** (seriesName as printed, editionLabel, startDate) as a resolution key, never the uid. Two editions of "The Liver Meeting" are two nodes.
- **Properties.** `entityType` (`Conference`); `conferenceType` (controlled: SCIENTIFIC_CONGRESS, INVESTOR_CONFERENCE, TRADE_SHOW, PATIENT_MEETING, REGULATORY_MEETING, WEBINAR_PROGRAM, OTHER); `seriesName` (presentation); `editionLabel`; `startDate`, `endDate` (`Date`, organizer-stated local calendar dates, inclusive as printed — not valid-time bounds; a change of dates is a POSTPONEMENT Event EVENT_ABOUT the Conference); `timeZone` (IANA); `location` (presentation; Facility deferred CL-015); `attendanceMode` (IN_PERSON, VIRTUAL, HYBRID, UNKNOWN); `websiteUrl` (presentation; the page is a Source).
- **Edges.** in `HOSTS_EVENT` (asserted), in `EXHIBITS_AT` (asserted, EventRoleEdgeProperties), in `ATTENDS` (asserted, public persons only), in `SPONSORS_CONTENT` (W21 type, asserted, FINANCIAL_INTEREST), in `EVENT_ABOUT` (inverse); out `HAS_EVENT` (structural, orderIndex).
- **Rule.** A conference name never creates a host edge (JPM 2026: 0 HOSTS_EVENT edges; Q-MISSING). Sponsorship of a program at the conference (AASLD PALD travel award) targets the Conference edition with `roleTitleVerbatim` until a program-level target exists (W18-SR-08).
- **Sources.** live 2104–2118; fixture 03 (JPM 2026, TLM 2026).

### Community — `["Community","Entity"]`, uid token `community`, CANDIDATE

- **Meaning.** A self-identified group without legal identity (patient forum, interest group). Not an Organization, not a Channel, not a membership roster.
- **Properties.** `entityType`, `communityType` (PATIENT_COMMUNITY, ONLINE_FORUM, SCIENTIFIC_INTEREST_GROUP, PROFESSIONAL_NETWORK, OTHER).
- **Edges.** out `HOSTS_EVENT` → Event | Conference (asserted); in `INVOLVES`.
- **Privacy.** Membership of persons is never stored (contract A9). A community's public name is PUBLIC.
- **Maturity note.** Kept as the live seam; promoted only with a CQ beyond hosting (none found).

### NarrativeArc — `["NarrativeArc","EvidenceAssessment"]`, uid token `narrative-arc`, CANDIDATE

- **Meaning.** A curated, method-versioned interpretation selecting and ordering events into a story. Not a source; not a warrant (excluded from provenance state 3); no truth, no score; order is narrative, never causal. A third party's published narrative is source content (W21), not an arc.
- **Decision (W18-D04): EvidenceAssessment, not InformationArtifact.** It needs `methodVersion`, `status`, `recordedAt/recordedTo`, immutability with SUPERSEDES, an assessor via `WAS_GENERATED_BY` Activity — the EvidenceAssessment contract exactly. As an InformationArtifact it would lack the lifecycle and look citable. The risk of being read as a warrant is closed by rule: `assessmentType = 'NARRATIVE_ARC'` is excluded from state 3, and W18-V03 rejects any SUPPORTED_BY / CONTRADICTED_BY / CONSIDERS_ASSESSMENT / EVALUATES / DERIVED_FROM_ASSERTION into an arc, any `derivedFromAssessmentUids` naming it, and any non-null `overallScore`/`confidence`/`verdict`.
- **Properties.** `assessmentType!` (`NARRATIVE_ARC`), `methodVersion!`, `status!` (AssessmentStatus), `recordedAt!`, `recordedTo`, `summary`, `overallScore` (must be null), `confidence` (must be null), `eventsRecordedAsOf!` (viewpoint used to select events), `arcType` (COMPANY_MILESTONE_PATH, THERAPEUTIC_AREA_HISTORY, REGULATORY_SAGA, CONTROVERSY, MARKET_NARRATIVE, OTHER), `themeSummary`, `impactDomain` (presentation), `periodStart/periodEnd` + precision (calculated at creation), search fields.
- **Edges.** out `ARC_INCLUDES_EVENT` → Event (structural, one_or_more, `orderIndex`, `notes` = inclusion rationale); out `ARC_ABOUT` → EventSubjectTarget (structural); out `SUPERSEDES` → NarrativeArc (W00, `SupersessionProperties`); out `WAS_GENERATED_BY` → Activity (W00).
- **Sources.** live 2150–2178; alignment 0006 ("an arc is an interpretation; it is never a source and carries no truth"); fixture 04.

### EventImpactAssessment — `["EventImpactAssessment","EvidenceAssessment"]`, uid token `event-impact`, CANDIDATE

- **Meaning.** Method-versioned judgment of one event's significance in one domain, optionally for one subject. Replaces live `Event.impactLevel` (decision W18-D05). Not a causal claim, not a truth verdict.
- **Properties.** `assessmentType!` (`EVENT_IMPACT`), `methodVersion!`, `status!`, `recordedAt!`, `recordedTo`, `summary`, `overallScore` (optional numeric companion defined by the method), `impactLevel!` (ImpactLevel), `impactDomain!` (MARKET, CLINICAL_PRACTICE, REGULATORY, SCIENTIFIC, COMMERCIAL, PATIENT_ACCESS, OTHER).
- **Edges.** out `ASSESSES_EVENT` → Event (structural, exactly_one); out `IMPACT_ON` → EventSubjectTarget (structural, zero_or_one); out `SUPPORTED_BY` → SourceLocator (W00); out `SUPERSEDES`; out `WAS_GENERATED_BY`.
- **Rule.** An event without an assessment is NOT_ASSESSED; `UNKNOWN` is an assessed outcome.

## 2. Relationship types

| Type | Domain → range | Class | Cardinality | Properties | Notes |
|---|---|---|---|---|---|
| `HOSTS_EVENT` | Organization \| Community → Event \| Conference | asserted | many | `AssertedEdgeProperties` | never inferred from a name; never implies endorsement ([HOSTS_EVENT, ENDORSES_PRODUCT]) |
| `HAS_EVENT` | Conference → Event | structural | event: zero_or_one conference | `StructuralEdgeProperties.orderIndex` | conference program only (W18-V02) |
| `INVOLVES` | Event → EventParticipantTarget | asserted | many | `EventRoleEdgeProperties` (participantRole!) | live name kept (W05 renamed its Exposure use to HAS_EXPOSURE_AGENT) |
| `EVENT_ABOUT` | Event → EventSubjectTarget | asserted | one_or_more | `AssertedEdgeProperties` | renamed from live ABOUT |
| `ARC_ABOUT` | NarrativeArc → EventSubjectTarget | structural | one_or_more | none | |
| `ARC_INCLUDES_EVENT` | NarrativeArc → Event | structural | one_or_more | `StructuralEdgeProperties` | renamed from live HAS_EVENT on arcs |
| `DOCUMENTED_BY_RECORD` | Event → EventRecordTarget | asserted | zero_or_one per record kind | `AssertedEdgeProperties` | assertion usually CALCULATED by a resolution agent with `DERIVED_FROM_ASSERTION` input (fixture 01) |
| `REPORTED_IN` | Event → Source | derived | many | `DerivedSupportProperties` (W20): `derivationRule` `reported-in-via-locator-v1`, `derivedFromAssertionUids`, `locatorUid` | regenerated from event assertions' SUPPORTED_BY |
| `CAUSED_BY` | Event (effect) → Event (cause) | asserted | many | `CausalEdgeProperties` | POSITIVE CAUSED_BY assertion with basisKind; forbidden premises FOLLOWED_BY, ARC_INCLUDES_EVENT, APPROVAL_BASED_ON |
| `FOLLOWED_BY` | Event → Event | derived | many | `DerivedEdgeProperties`: rule `valid-time-order-v1` + two time assertion uids, or `projectionOfAssertionUid` of a source-stated order | never implies CAUSED_BY; overlapping precision periods give no edge (W18-V08) |
| `EXHIBITS_AT` | Organization → Conference | asserted | many | `EventRoleEdgeProperties` | not FINANCIAL_INTEREST (catalog list); never endorsement |
| `SPEAKS_AT` | Person → Event | asserted | many | `EventRoleEdgeProperties` | public persons only; speaker title never becomes EMPLOYED_BY |
| `ATTENDS` | Person → Conference | asserted | many | `EventRoleEdgeProperties` | public persons, public source only (W18-V11) |
| `RECORDING_OF` | Episode → Event | asserted | many | `RecordingEdgeProperties` (recordingCoverage!) | the recording work; renditions and availability via W21/W00 |
| `PRESENTED_AT` | Document → Event | asserted | many | `AssertedEdgeProperties` | deck/poster; never RENDITION_OF the recording (W18-V06) |
| `ASSESSES_EVENT` | EventImpactAssessment → Event | structural | exactly_one | none | |
| `IMPACT_ON` | EventImpactAssessment → EventSubjectTarget | structural | zero_or_one | none | |
| `SPONSORS_CONTENT` (W21 type) | Organization \| ConsumerBrand → SponsorableTarget | asserted | many | `AssertedEdgeProperties` | W18 writes the Conference-side fields only |

## 3. Relationship-property types

| Type | Specializes | Added fields | Used by |
|---|---|---|---|
| `EventRoleEdgeProperties` | `AssertedEdgeProperties` (all fields) | `participantRole: String!` (PRESENTER, SPEAKER, MODERATOR, PANELIST, HOST, ORGANIZER, EXHIBITOR, ATTENDEE, APPLICANT, DECISION_MAKER, MARKETING_AUTHORIZATION_HOLDER, ANNOUNCER, ACQUIRER, TARGET, LICENSOR, LICENSEE, COUNTERPARTY, OTHER), `roleTitleVerbatim: String` | INVOLVES, SPEAKS_AT, ATTENDS, EXHIBITS_AT |
| `CausalEdgeProperties` | `AssertedEdgeProperties` | `basisKind: BasisKind!`, `assertionBasis: AssertionBasis`, `speechAct: SpeechAct` (copies of the authorizing assertion; W18-V01 checks equality) | CAUSED_BY |
| `RecordingEdgeProperties` | `AssertedEdgeProperties` | `recordingCoverage: String!` (FULL, PARTIAL, EXCERPT, UNKNOWN) | RECORDING_OF |

## 4. Enums and unions

| Name | Values / members | Owner | Notes |
|---|---|---|---|
| `EventCategory` | 26 live values | W18 | unchanged |
| `ImpactLevel` | LOW, MODERATE, HIGH, CRITICAL, UNKNOWN | W18 | only on EventImpactAssessment |
| `EventStatus` | PLANNED, ANNOUNCED (legacy), IN_PROGRESS, COMPLETED, CANCELLED, DELAYED, UNKNOWN | W18 | projection; never truth |
| `EventPhase` | — | W18 | **retired** (computed at query time) |
| `EventParticipantTarget` | Organization, Person, Community | W18 | |
| `EventSubjectTarget` | Organization, Person, Product, ChemicalSubstance, Study, Condition, TechnologyPlatform, Protocol, Treatment, Procedure, SafetySignal, AdverseEffect, Lifestyle, Conference, Publication | W18 | SafetySignal/AdverseEffect depend on W17 delivering them (build used stubs) |
| `SponsorableTarget` | Conference, Channel, Episode, Series, Document | W18 (edge W21) | catalog round 0006 range |
| `EventRecordTarget` | RegulatoryResponse, RegulatorySubmission, DrugApproval, Publication, RegistrationVersion | W18 (new) | |

## 5. Candidates kept out of the fragment

| Candidate | Why not now | Promotion trigger |
|---|---|---|
| `ConferenceSeries` + `EDITION_OF` | no CQ needs cross-edition identity; `seriesName` suffices for display | a CQ like "Madrigal presentations at The Liver Meeting 2022–2026" with two editions whose names differ |
| Program-level sponsorship target (award, symposium, session) | one case (AASLD PALD award); Conference target with `roleTitleVerbatim` works | second case where sponsor of a sub-program differs from sponsor of the meeting |
| `Presentation`/`Talk` work type | Event + Episode + Document cover recorded, unrecorded and removed-recording sessions | a talk published in two different recorded works where the occurrence link is insufficient |
| Community membership | private behaviour data (A9) | never in the shared graph |
| Recall clock trio (initiated / classified / terminated) | no recall researched in this packet | W13/W12 recall fixture; eventType values RECALL_INITIATED/RECALL_CLASSIFIED reserved |
