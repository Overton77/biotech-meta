# W18 05 Decision and seam ledger

Status words: **proposed** (this packet recommends; Fable/W00 rule), **unresolved** (needs another owner's evidence), **rejected** (alternative not recommended). Nothing here is accepted until Fable rules; no consensus is claimed. Seam requests: `seam-requests.yaml` (W18-SR-01 … SR-12).

## 1. Decisions

| Id | Decision | Evidence | Alternatives (why not) | Status |
|---|---|---|---|---|
| W18-D01 | Event is an Occurrence whose clocks are materializations of assertions: valid (`startedAt/endedAt`, from EVENT_OCCURRED), publication (`announcedAt`, from the first-party snapshot), effect (`effectiveFrom`, from EVENT_EFFECTIVE); recorded time lives on assertions | W18-S02/S05/S06 (EU: announced 2025-08-19, effective 2025-08-18), S02/S04 (launch planned 03-14, happened April, reported 05-07); Q-EN-C01a vs C01b | authoritative date properties on Event (cannot answer "as recorded at R"; a late EMA fact overwrites the company's) | proposed |
| W18-D02 | `announcedAt` = earliest first-party publication of the occurrence, advance (EVENT_SCHEDULED) or after (EVENT_OCCURRED); `announcementAssertionUid` tells which; third-party reports are not announcements | S11 (session pre-announced), S02 (launch pre-announced), S05 | announcement = first after-the-fact report only (breaks sessions); latest report (meaningless) | proposed |
| W18-D03 | `CAUSED_BY` is asserted only: projection of one POSITIVE CAUSED_BY assertion with `basisKind`; temporal order, arc membership and regulatory "based on" are never premises | S10 (three causal claims incl. a reversal; one "after" sentence); S02 ("based on Phase 3 data"); N1–N4 | derived causality from order/co-mention (forbidden); keeping RoleMetadata (no basis) | proposed |
| W18-D04 | NarrativeArc is an **EvidenceAssessment** (not InformationArtifact): method-versioned, immutable, SUPERSEDES-revised, reproducible by `eventsRecordedAsOf`; excluded from state 3; never cited; no score | alignment 0006 ("never a source, carries no truth"); fixture 04 (v1 → v2 after the EMA late arrival); N6/N7 | InformationArtifact (citable-looking, no lifecycle); live Entity with mutable members (no reproducibility) | proposed |
| W18-D05 | Impact is method-versioned: `EventImpactAssessment` (CANDIDATE) replaces `Event.impactLevel` | fixture 02: HIGH for Madrigal, MODERATE for Viking from one readout | keep property (no assessor, method, subject); drop impact entirely (loses live data; migration needs a target) | proposed |
| W18-D06 | `EventPhase` retired (computed) | stored phase is stale by construction; N12 | keep read-only (still misleading) | proposed |
| W18-D07 | Conference = organizer-announced edition (Entity), dates as `Date` local calendar dates, series name presentation only; changes of dates/format are Events about the Conference | S13/S19 (edition dates), JPM 2026 vs 2025 editions | Conference as Occurrence (cannot be sponsored before it happens; cancelled editions); `ConferenceSeries` now (no CQ) | proposed |
| W18-D08 | Conference ↔ recording: no direct edge. Session = Event `HAS_EVENT` from the Conference; recording = W21 Episode `RECORDING_OF` the Event; deck = Document `PRESENTED_AT` the Event | S12 (Madrigal webcast + deck), S14–S16 (Merck webcast removed, transcript + deck); CL-003 R4 | Conference → Episode (loses which session; fails for multi-session days); deck → Episode `ACCOMPANIES_PRESENTATION` (fails for unrecorded sessions and reused decks) | proposed (W21/W19 respond, SR-06) |
| W18-D09 | Rename to keep one type, one meaning: `ABOUT` → `EVENT_ABOUT` (asserted) and `ARC_ABOUT` (structural); arc `HAS_EVENT` → `ARC_INCLUDES_EVENT` | W20 ABOUT is derived retrieval aboutness; N14 | share W20 `ABOUT` (class and properties differ); keep arc HAS_EVENT (program traversals return arc members) | proposed |
| W18-D10 | `INVOLVES` range narrowed to actors (Organization, Person, Community); things move to `EVENT_ABOUT` | live union mixes Product/Study with persons | keep mixed range (a product "participating" in its approval) | proposed |
| W18-D11 | `DOCUMENTED_BY_RECORD` links an event to its authoritative W13/W09 record; the event never copies the record's fields | W18-S03 (Drugs@FDA) vs S02 (release); Q-EN-C02 | match by subject + date at query time (fragile: two approvals one day); merge Event into RegulatoryResponse (artifact ≠ occurrence) | proposed |
| W18-D12 | Sponsorship of a conference (SPONSORS_CONTENT, W21 type) is recorded on the Conference side by W18; it never implies endorsement by the sponsor, the host, or of any product; hosting, exhibiting, speaking and attending likewise | S18 (AASLD award supported by Madrigal), S20 (separate AASLD guidance); N5 | infer host endorsement from sponsor relationship (forbidden); omit sponsorship (loses CQ-EC-03 relevance input) | proposed |
| W18-D13 | A data readout event is the public disclosure (happened = announced by definition); the database lock and registry completion are different occurrences/records | S01 (07:00 ET release), S09 (primary completion 2028-01, no posted results) | readout date = registry primary completion (wrong by five years here) | proposed |
| W18-D14 | Community kept as CANDIDATE Entity with hosting only; no membership in the shared graph | contract A9; no researched case | membership edges (private behaviour data) | proposed |
| W18-D15 | Asserter of statements in a syndicated article = the publisher of record (MarketBeat) until W21/W01 rule on bylines | S10 (byline at the end of the extract; "originally appeared on MarketBeat") | the byline person (attribution not established for every paragraph) | proposed (W19-SR-08 dependent) |

## 2. Conflict records this packet touches

| Ledger id | W18 position |
|---|---|
| CL-003 (Source/Document/Publication/Episode) | supports R4 with real cases (Madrigal and Merck JPM 2026): the deck is PRESENTED_AT the occurrence, the recording is RECORDING_OF the occurrence; neither is a rendition of the other (W18-V06). |
| CL-014 precedent (one relationship type, one meaning) | applied to ABOUT and HAS_EVENT (W18-D09). |
| CL-015 (PhysicalLocation vs Facility) | Conference.location stays a presentation string until W01 rules. |
| CL-016 (RECOMMENDS) | unaffected; the AASLD guidance's recommendations, if captured, are ordinary assertions, never derived from sponsorship. |

## 3. Kernel-change requests

None to archetypes, assertion authority, time semantics or privacy. Vocabulary additions only: `statedTense` FUTURE and `ActivityKind.CURATION` (W18-SR-04); uid tokens (SR-01); NARRATIVE_ARC exclusion from state 3 (SR-10, a rule, not a schema change).

## 4. Unresolved items and closure criteria

| Item | Owner | Closure criterion |
|---|---|---|
| EU authorisation record shape (EC decision / Union Register) for DOCUMENTED_BY_RECORD | W13 | a W13 record type for an EC decision with its decision date |
| Program-level sponsorship target | W21 | a second case where a sub-program sponsor differs from the meeting's sponsors |
| Byline vs publisher asserter for syndicated articles | W21 + W01 (W19-SR-08) | written rule and a fixture with a named byline |
| Recall clocks (initiated / classified / terminated) | W13/W12 with W18 | a real FDA enforcement-report record; eventType values reserved |
| JPM 2026 host and official dates | W18 (later capture) | the organizer's page captured (only third-party listings were retrieved) |
| SafetySignal/AdverseEffect union members | W17 | W17 fragment delivered |
| Whether a source-stated FOLLOWED_BY should also be an asserted type | W00 | if a CQ needs to distinguish "a source says B followed A" from computed order beyond `projectionOfAssertionUid` |

## 5. Objections anticipated (for Wave 5 challengers)

- *"Assertions for every event date are heavy."* A milestone timeline is precisely where sources disagree in precision and arrive late (EU authorisation: MONTH from the company, DAY from EMA two recorded hours later). The materialized properties keep reads cheap; the assertions are the history.
- *"An arc as an EvidenceAssessment will leak into evidence answers."* State 3 exclusion by `assessmentType` and W18-V03 make the leak detectable at write and audit time; as an InformationArtifact it would be worse (citable by construction).
- *"CAUSED_BY between market moves and readouts is not biomedical."* The live schema has it, users ask it, and the retelling case shows the risk: one article asserts both directions. Keeping it asserted with basis and speech act is the safe form.
- *"Drop Community."* It is live and harmless as a host; promoting or retiring it needs a case either way.
