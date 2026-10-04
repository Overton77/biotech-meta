# W18 06 Fixtures and queries

## Execution environment and order (all **run**, 2026-10-04 ≈01:45–02:00 UTC)

- Neo4j **5.26.31 Community**, in-process (`org.neo4j.test:neo4j-harness:5.26.31`, OpenJDK 21) on W18's own instances (Fable's untouched); the final pass used **APOC Core 5.26.31** on the classpath (the jars W00 fetched) because `@neo4j/graphql` 7.6.3 emits `apoc.date.convertFormat` for every `DateTime` field it returns (a GraphQL read without APOC failed: `Unknown function 'apoc.date.convertFormat'`). Statements run with the run harness `run-cypher.mjs` (one transaction per statement, no variable crosses `;`), sample size raised to 50 rows.
- Order: `operations.cypher` (43/43 ok: 20 constraints incl. 10 relationship-uniqueness, 10 indexes incl. 2 fulltext, 13 validators on the empty graph) → fixtures 01 (220/220) → 02 (75/75) → 03 (168/168) → 04 (22/22) → validators (W18-V01…V13 and 11 baseline validators: **all zero rows**) → `w18-80-queries.cypher` (11/11) → GraphQL round trip (6/6 OK) → `w18-90-negatives.cypher` (39/39) → validators (expected rows below). Graph size: 168 nodes / 315 relationships after 01–04; 180 / 341 after 90.
- Baseline validators run (copied verbatim from `docs/schema/neo4j/validation.cypher`): V-000a, V-000b, V-002, V-101, V-105, V-106, V-110, V-112, V-117, V-421, V-422, with `fixtures/w18-validation-params.json` = run params + W18 asserted/derived types + W18 forbidden pairs.
- Generator: `fixtures/gen_w18.py` (+ `w18lib.py`) writes every fixture; quote hashes are real NFC-WS1 sha256 over the quoted text; snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'` (sha256 over the snapshot uid). Every node carries its primary label and archetype label; uids use the requested tokens `event`, `conference`, `community`, `narrative-arc`, `event-impact` (W18-SR-01) and registered tokens otherwise. Captures that were search extracts are stored as `PARTIAL_EXCERPT` (the catalog has no SEARCH_EXTRACT value).
- Recorded-time choreography: company/filing/registry assertions recorded 03:00Z, retelling 04:00Z, capture review 04:10Z, conference material 05:00Z, EMA 06:00Z (late arrival); viewpoints R1 = 04:30Z, R2 = 09:00Z; arcs v1 recorded 04:45Z (viewpoint 04:30Z), v2 07:00Z (viewpoint 06:30Z).

## Fixture 01 `w18-01-rezdiffra-milestone-clocks.cypher` — real company milestones vs regulator records

Sources W18-S01…S09. Events: E1 MAESTRO-NASH topline disclosed (2022-12-19T12:00Z INSTANT), E6 NEJM publication (2024-02-08 DAY, DOCUMENTED_BY_RECORD Publication PMID 38324483), E2 FDA accelerated approval (US; happened/effective 2024-03-14 from Drugs@FDA; announced 2024-03-14 by Madrigal; DOCUMENTED_BY_RECORD W13 RegulatoryResponse), E3 US launch (EVENT_SCHEDULED April 2024 MONTH stated 2024-03-14; EVENT_OCCURRED April 2024 MONTH from the 8-K of 2024-05-07), E4 EU conditional authorisation (Madrigal "in August 2025" MONTH recorded 03:00Z; EMA "18 August 2025" DAY + EVENT_EFFECTIVE recorded 06:00Z), E5 Germany launch (September 2025 MONTH, announced 2025-11-04). EVENT_ABOUT, INVOLVES (roles APPLICANT, DECISION_MAKER, MARKETING_AUTHORIZATION_HOLDER, ANNOUNCER) are projections of one assertion each; FOLLOWED_BY derived by `valid-time-order-v1`; REPORTED_IN derived with `locatorUid`.

## Fixture 02 `w18-02-readout-causal-retelling.cypher` — a readout retold with causal claims

Source W18-S10 (asserter MarketBeat, decision W18-D15). Events E7 MDGL rise (2022-12 MONTH, basis INFERRED), E8 VKTX jump (2022-12-19 DAY), E9 Viking "successful NASH trial" (time unknown, null, basis UNKNOWN, status UNKNOWN). Assertions C1 (E7 CAUSED_BY E1, STATES, INFERRED_FROM_MEASUREMENT), C2 (E8 CAUSED_BY E1, STATES), C3 (E7 CAUSED_BY E9, SPECULATES, HYPOTHESIS), O1 (E1 FOLLOWED_BY E8, source-stated "after") — all capture-ACCEPTED by one CAPTURE_FIDELITY adjudication; no SUPPORT adjudication. Two synthetic EventImpactAssessments (method `event-impact-market-v0`): E1 HIGH for Madrigal, MODERATE for Viking.

## Fixture 03 `w18-03-conference-sessions-sponsorship.cypher` — conference, sessions, recordings, decks, sponsorship

Sources W18-S11…S19 and synthetic S23. JPM 2026 edition (dates 2026-01-12..15 as `Date`, from third-party listings; **no HOSTS_EVENT** — not asserted by any captured source); sessions E10 Madrigal (2026-01-12T21:30Z; PR said "1:30pm PST", IR page "4:30 PM EST"; announced 2025-12-15 in advance; speaker not stated) and E11 Merck (2026-01-13T00:30Z from "January 12, 2026 4:30 pm PST"); RECORDING_OF from two Episodes; PRESENTED_AT from two deck Documents; Merck transcript and webcast Sources RENDITION_OF the Merck Episode, the webcast capture reads "The recording of this session is not available any more."; SPEAKS_AT Davis (PRESENTER) and Schott (MODERATOR) from the transcript. TLM 2026: HOSTS_EVENT AASLD (asserted by AASLD), SPONSORS_CONTENT Madrigal (asserted by AASLD, `roleTitleVerbatim: 'made possible through the support of'`); AASLD resmetirom guidance present as a separate Publication with no edge to anything here. Synthetic exhibitor (EXHIBITS_AT), public attendee (ATTENDS), community-hosted planned webinar.

## Fixture 04 `w18-04-narrative-arc.cypher` — interpretation that cites events and is never a source

Arc v1 (4 events; viewpoint 04:30Z, before EMA arrived), arc v2 (6 events; SUPERSEDES v1 `RE_REVIEW`; v1 `recordedTo` 07:00Z, status SUPERSEDED). Both `methodVersion: arc-curation-v0.1`, `WAS_GENERATED_BY` a CURATION Activity associated with a curator Agent, `ARC_ABOUT` Rezdiffra, no score, nothing points at them.

## Queries (`fixtures/w18-80-queries.cypher`, all **run**; full rows)

| Query (CQ) | Expected = observed |
|---|---|
| Q-EN-C01a timeline as recorded at **R1** (CQ-EN-C01, CQ-TM-03) | 6 rows. Readout `2022-12-19 INSTANT by Madrigal`, announced 2022-12-19; NEJM `2024-02-08 DAY by NLM`, announced null (NLM not a participant); FDA approval occurred by FDA and Madrigal 2024-03-14 DAY, effective 2024-03-14, announced 2024-03-14; US launch occurred 2024-04 MONTH, scheduled 2024-04 MONTH, announced 2024-03-14; **EU authorisation occurred `2025-08-01 MONTH by Madrigal` only, effective [] , announced 2025-08-19**; Germany launch 2025-09 MONTH, announced 2025-11-04. |
| Q-EN-C01b timeline as recorded at **R2** | 6 rows; EU authorisation now `[2025-08-01 MONTH by Madrigal, 2025-08-18 DAY by EMA]`, effective `2025-08-18 DAY`, materialized start `2025-08-18 DAY`, announced 2025-08-19, effective 2025-08-18. Other rows unchanged. |
| Q-EN-C02 announced vs effective vs record (CQ-EN-C02) | 4 rows: FDA approval happened 2024-03-14 DAY / announced 2024-03-14 (EVENT_OCCURRED) / effective 2024-03-14 / record `hu:reg-response:us-fda-nda-217785-orig-1-approval` issued 2024-03-14; US launch happened 2024-04 MONTH / **announced 2024-03-14 (EVENT_SCHEDULED)** / **first reported as happened 2024-05-07** / effective null; EU happened 2025-08-18 / **announced 2025-08-19** / **effective 2025-08-18** / record null (W18-SR-09); Germany 2025-09 MONTH / announced 2025-11-04. Each row also returns `timeRecordedAt` and `timeSourceRetrievedAt` (2026-10-04T01:30Z). |
| Q-EN-C03a causal claims (CQ-EN-C03) | 3 rows: MDGL rise ← readout (MarketBeat, INFERRED_FROM_MEASUREMENT, STATES, capture SUPPORTED, support NOT_ASSESSED, 2 causes claimed for this effect); MDGL rise ← Viking trial (HYPOTHESIS, SPECULATES, 2 causes); VKTX jump ← readout (STATES, 1 cause). |
| Q-EN-C03b order without cause (minimal pair) | 6 rows; readout → VKTX jump `source-stated order` with `hasCausalClaim: true` (a separate CAUSED_BY assertion exists); 5 rule-derived pairs (readout → NEJM → FDA approval → US launch → EU authorisation → Germany launch) all `hasCausalClaim: false`. No FOLLOWED_BY between the readout (DAY) and the MDGL rise (MONTH): the rule cannot order them. |
| Q-EN-C04a sessions (CQ-EN-C04, CQ-CL-01) | 2 rows: Madrigal session 2026-01-12T21:30Z, presenters [Madrigal], **speakers []**, recording `madrigal-jpm-2026-webcast coverage=UNKNOWN`, deck "Madrigal … presentation (1.2 MB)", hosts []; Merck session 2026-01-13T00:30Z, speakers [Christopher Schott (MODERATOR: Analyst), Robert Davis (PRESENTER: Chairman of the Board, President, Chief Executive Officer)], recording `merck-jpm-2026-webcast coverage=UNKNOWN [capture: recording unavailable]`, deck `MRK-2026-JP-Morgan-Presentation.pdf`, hosts []. |
| Q-EN-C04b sponsorship vs endorsement | 1 row: TLM 2026 hosts [AASLD], sponsors [Madrigal [made possible through the support of]], exhibitors [Synthetic Diagnostics Exhibitor Inc.], **hostEndorsementEdges 0**, separate guidance publication present true. |
| Q-EN-C05 arc as recorded at R (CQ-EN-C05) | 2 rows: at 05:00Z arc v1, viewpoint 04:30Z, 4 events in order; at 09:00Z arc v2, viewpoint 06:30Z, 6 events; both `usedAsSupportOrWarrant 0`, `score null`. |
| Q-EN-C06 impact judgments | 2 rows: Madrigal MARKET HIGH, Viking MARKET MODERATE, method `event-impact-market-v0`, PROPOSED, evidence quote "Overall, MDGL leaped up by about 268.07% while VKTX jumped 74%."; `legacyEventField` null. |
| Q-PV-01-event (CQ-PV-01) | 4 rows for the EU authorisation: two Madrigal EVENT_OCCURRED spans (recorded 03:00Z), EMA EVENT_OCCURRED and EVENT_EFFECTIVE span "…valid throughout the EU on 18 August 2025." (recorded 06:00Z), capture PARTIAL_EXCERPT, retrieved 01:30Z, `warrant` null (arcs excluded), `usedBy` null. |
| Q-MISSING | 3 rows: JPM 2026 `hostEdges 0`; Madrigal session `speakerEdges 0`; Viking trial `startedAt null`, basis UNKNOWN, status UNKNOWN. |

## GraphQL round trip (`fixtures/w18-gql-roundtrip.mjs`, **run**)

Schema = all worker fragments present at 01:56Z merged by the run harness + `fixtures/w18-build-stubs.graphql` (13 object stubs and 2 enum stubs for types not yet delivered by W17/W10/W21 etc.; duplicate `ResultQualifier` from W12 dropped; W16 `Observation implements DiagnosticResult` removed in the test copy because it fails independently of W18). `Neo4jGraphQL` build: OK (32 s, 38,911 generated types; root fields `events`, `conferences`, `communities`, `narrativeArcs`, `eventImpactAssessments`, `searchEvents`, `searchNarrativeArcs` present). Six queries against the loaded fixtures, all OK: event with `causedByConnection` edge properties (`assertionUid`, `basisKind`, `speechAct`, `recordedFrom`); EU authorisation with three clocks, `aboutConnection` and `involvesConnection` (`participantRole`); conferences with `startDate: "2026-01-12"` (Date round trip), sessions, `speakersConnection`, `recordingsConnection.recordingCoverage`, `presentedDocuments`, `hostedByOrganizations`, `sponsoringOrganizationsConnection`, `exhibitors`; arcs with `includesEventsConnection.orderIndex` and `supersedes`; impact assessments with `impactOn` union; `searchEvents(phrase: "Rezdiffra")` returns 4 events. **Not run against Fable's merged schema** (Fable action: rerun the same script).

## Fixture 90 `w18-90-negatives.cypher` (load after 01–04)

| Case | Defect | Expected checks | Observed (run) |
|---|---|---|---|
| N1 | Germany launch CAUSED_BY EU authorisation from bare temporal order (`derivationRule: temporal-order-v1`, no assertion) | W18-V01, V-112, V-101 | W18-V01 `NO_ASSERTION_UID`, `DERIVED_PROPERTIES_ON_ASSERTED_EDGE`; V-112 `DERIVATION_WITHOUT_SOURCE_ASSERTIONS`; V-101 row (assertionUid null) |
| N2 | VKTX jump CAUSED_BY readout citing the source-stated FOLLOWED_BY assertion ("after") | W18-V01, V-112 | W18-V01 `CITED_PREDICATE_NOT_CAUSED_BY`, `SUBJECT_IS_NOT_EFFECT`, `OBJECT_IS_NOT_CAUSE`; V-112 `CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE`, `FORBIDDEN_IMPLICATION_USED_AS_PREMISE` |
| N3 | CAUSED_BY citing a CAUSED_BY assertion with no basisKind | W18-V01 only (V-112 passes) | W18-V01 `ASSERTION_WITHOUT_BASIS_KIND`, `EDGE_WITHOUT_BASIS_KIND`; V-112 no row — shows why W18-V01 is needed |
| N4 | approval CAUSED_BY readout citing "Accelerated approval was based on Phase 3 data" (APPROVAL_BASED_ON) | W18-V01, V-112 | W18-V01 `CITED_PREDICATE_NOT_CAUSED_BY`, `OBJECT_IS_NOT_CAUSE`; V-112 `CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE`, `FORBIDDEN_IMPLICATION_USED_AS_PREMISE` |
| N5 | ENDORSES_PRODUCT AASLD → Rezdiffra derived from the sponsorship and hosting assertions | V-422, V-112, W18-V05, V-101 | V-422 row; V-112 `FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS`; W18-V05 premises [HOSTS_EVENT, SPONSORS_CONTENT]; V-101 row |
| N6 | arc used as support (Assertion SUPPORTED_BY arc), as warrant (Adjudication CONSIDERS_ASSESSMENT arc), as derivation input (REPORTED_IN `derivedFromAssessmentUids` [arc]) | W18-V03 | one row for arc v2 with all three violations; baseline validators: no row |
| N7 | arc with `overallScore 0.8` | W18-V03 | `ARC_CARRIES_SCORE_OR_VERDICT` |
| N8 | Event with `startedAt` but no precision, basis or time assertion; also stored `eventPhase`, `impactLevel` (N12) | W18-V07, W18-V04, W18-V10, W18-V13 | V07 `STARTED_AT_WITHOUT_PRECISION_OR_BASIS`; V04 `START_WITHOUT_TIME_ASSERTION`; V10 row (POST_EVENT, HIGH); V13 row |
| N9 | effectiveFrom copied from announcedAt (`PUBLICATION_PROXY`), no assertions | W18-V04 | `EFFECTIVE_NOT_LICENSED`, `EFFECTIVE_FROM_PUBLICATION_PROXY`, `ANNOUNCED_WITHOUT_ASSERTION`; V13 row |
| N10 | FOLLOWED_BY readout (DAY 2022-12-19) → MDGL rise (MONTH 2022-12) by `valid-time-order-v1` | W18-V08 | 1 row (earlier latest end 2022-12-19T12:00Z > later start 2022-12-01) |
| N11 | ATTENDS from a private person record (`:PrivateRecord`, `hu:private-person:`), assertion missing | W18-V11, W18-V09 | V11 row; V09 row (assertion missing) |
| N13 | EventImpactAssessment without methodVersion | W18-V12 | 1 row |
| N14 | arc using the conference `HAS_EVENT` type | W18-V02 | 1 row |
| N15 | deck Document RENDITION_OF the Madrigal recording Episode (deck also PRESENTED_AT the session the Episode records) | W18-V06 (W21 V-W21-03 not run here) | 1 row |
| N16 | Event status COMPLETED with only an EVENT_SCHEDULED assertion | W18-V13 | 1 row (plus N8, N9, N17 which also lack EVENT_OCCURRED: 4 rows total) |
| N17 | materialized `startedAt` 2025-08-19 naming the EMA assertion of another event (validFrom 2025-08-18) | W18-V04 | `TIME_ASSERTION_ABOUT_ANOTHER_EVENT`, `START_NOT_LICENSED` |

Totals after fixture 90: W18-V01 4 rows, V02 1, V03 2, V04 3, V05 1, V06 1, V07 1, V08 1, V09 1, V10 1, V11 1, V12 1, V13 4; V-101 2, V-112 4, V-422 1; V-000a/b, V-002, V-105, V-106, V-110, V-117, V-421 zero.

## Mandatory W18 cases → fixture

| Mandatory case | Where |
|---|---|
| event announced vs effective vs recorded dates | fixture 01, Q-EN-C01a/b, Q-EN-C02 (EU: announced 08-19, effective 08-18, recorded 06:00Z after R1) |
| causal CAUSED_BY must cite an assertion with basisKind; bare temporal order fails | fixture 02 positives; N1, N2, N3, N4 |
| NarrativeArc cites events but is not a source for any claim | fixture 04, Q-EN-C05; N6, N7, N14 |
| sponsorship of a conference vs endorsement (forbidden implication) | fixture 03, Q-EN-C04b; N5 |
| temporal correction / late arrival | EMA assertion recorded after R1 (Q-EN-C01a vs b); arc v1 → v2 SUPERSEDES |
| identity collision | N17 (time materialized from another event's assertion); N14 (one relationship type, two meanings) |
| missing facts | Q-MISSING (no host from a name; no speaker; unknown time); NLM not a participant → announcedAt null |
| access leakage | N11 |
