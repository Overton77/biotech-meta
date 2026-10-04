# W21 fixtures and queries

## 1. Execution scope

All fixtures were **RUN** on 2026-10-04 on an isolated in-process Neo4j **5.26.31 Community** (the run harness `EmbeddedNeo4j`, own data directory, JVM heap 512 MB), driven by the run's `validation/harness/run-cypher.mjs` (one transaction per statement; variables never cross `;`). For each fixture, in a wiped database: (1) baseline `docs/schema/neo4j/constraints.cypher` (57 statements: 45 applied, 12 Enterprise-only rejected, as in `00-baseline.md`); (2) the fixture; (3) the full baseline `docs/schema/neo4j/validation.cypher` (174 statements) with the coordinator's parameters plus SPONSORS_CONTENT/OPERATES_CHANNEL/SERVES_ON_CHANNEL in `assertedTypes` and RECOMMENDS in `derivedTypes`; (4) `fixtures/w21-validation.cypher` (12 candidate validators); (5) the fixture's `*.queries.cypher`; (6) where present, the `*.neg.cypher` injections followed by both validation suites again. `operations.cypher` was also run on Community (section 4 of `07-operations.md`) and fx01 + fx04 were loaded together under it without uniqueness conflicts.

Files: positive fixture `fixtures/<name>.cypher`; queries `fixtures/<name>.queries.cypher`; defect injections `fixtures/<name>.neg.cypher`; validators `fixtures/w21-validation.cypher`. Every node carries its primary label plus its archetype label; every statement binds its nodes by uid; snapshots are STORED_EXCERPT_TEXT (real, hashed excerpts in `excerpts/`) or SYNTHETIC_FIXTURE.

Informational baseline rows that appear for every fixture and are not failures: V-118 (uid backfill counts), V-401b (count 0), V-514b (assertions without `contentHash`; fixtures do not compute assertion payload hashes), V-522 (nodes without `privacyClass`), and, after `operations.cypher` had been applied to the instance, V-120 listing `ClaimSearch` on `[name, description, searchText]` ONLINE, which is exactly the expected definition. All positive fixtures were re-run against the final 12-validator file after the W00/W03/W08/W19/W20 alignment: 0 failing rows in every positive fixture except the intended V-423 row of fx07.

## 2. Fixtures, expected and observed results

### fx01 `fx01-dynamic-ads-renditions.cypher` (63 statements, 63 ok) — mandatory pair: same episode, differently timed podcast/video ads; transcript locator without invented video offsets; caption text version + transcription Activity; platform/channel/series; re-edit identity collision

Baseline validation: 0 failing rows. W21 validators: 0 rows.

| Query | Purpose (CQ) | Expected = observed |
|---|---|---|
| Q01-1 | sponsor segments by rendition (CQ-CL-08, CQ-CL-C01) | 2 rows: `VIDEO_RENDITION, 210.0 s, PUBLISHER_CHAPTER, "ROKA, InsideTracker, Magic Spoon", [InsideTracker], asserted by Andrew D. Huberman, validFromBasis PUBLICATION_PROXY`; `PODCAST_DIRECTORY_RECORD, 225.0 s, PUBLISHER_CHAPTER, "Sponsors: AG1, LMNT & Waking Up", [AG1, LMNT, Waking Up], asserted by Scicomm Media, OBSERVATION_ONLY` |
| Q01-2 | locators of the NMN statement per rendition (CQ-CL-01, CQ-PV-02) | 3 rows: `PODCAST_DIRECTORY_RECORD: null` (not captured, nothing invented); `PODCAST_TRANSCRIPT_PAGE: TEXT_QUOTE, mediaStartSeconds null, "My 82 -year-old father, ..."`; `VIDEO_RENDITION: MEDIA_TIME 3765.0, RENDITION_TRANSCRIPT_CUE, "Well, I'm always happy ..., my 82-year-old father, ..."` |
| Q01-3 | sponsorship edges with time basis (CQ-CL-05, CQ-AX-18) | 4 rows: AG1, LMNT, Waking Up `validFrom null, OBSERVATION_ONLY, PODCAST_DIRECTORY_RECORD`; InsideTracker `2021-12-27, PUBLICATION_PROXY, VIDEO_RENDITION` |
| Q01-4 | text versions and transcription activities (CQ-PV-03) | 2 rows: transcript page `TRANSCRIPTION, publisher transcript "under human review"`; YouTube `TRANSCRIPTION, unknown (platform caption track)`, agent "auto-generated or uploaded: not established" |
| Q01-5 | identity collision (re-edit) | 2 rows: episode 52 (2021-12-27, Huberman Lab, 3 renditions); Essentials (2025-10-30, Huberman Lab Essentials, 0 renditions) |
| Q01-6 | author vs host vs guest vs speaker vs asserter | Huberman: HOST, speaker labels [] (YouTube cues carry none), asserted SPONSORS_CONTENT/SPONSOR_READ; Sinclair: GUEST, label "David Sinclair", asserted SELF_REPORTED_DAILY_INTAKE/EDITORIAL |
| Q01-7 | [SPONSORS_CONTENT, ENDORSES_PRODUCT] | 0 ENDORSES_PRODUCT/RECOMMENDS edges |

Negative injections (`fx01-dynamic-ads-renditions.neg.cypher`), observed rows: N01-a invented offsets on the transcript-page locator -> **V-W21-01** 1 row; N01-b feed segment delimited by a YouTube locator -> **V-W21-05** 1 row; N01-c sponsorship pointed at a rendition Source -> **V-W21-07** 1 row; N01-d endorsement from the sponsor read -> **V-422** 1, **V-112** 1 (`CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE`, `FORBIDDEN_IMPLICATION_USED_AS_PREMISE`), **V-007** 1.

### fx02a `fx02a-transcript-correction-cosmetic.cypher` (20 ok) and fx02b `fx02b-transcript-correction-substantive.cypher` (23 ok) — mandatory pair: transcript correction preserving the prior citation

Baseline validation: 0 failing rows for both. W21 validators: 0 rows for both.

| Query | fx02a (typography fix) | fx02b (mis-transcription fix) |
|---|---|---|
| Q02-1 prior citation | `"My 82 -year-old father, ...", quoteHash sha256:96fe6eb5…, snapshot hubermanlab-52-page-2026-10-03, hash sha256:9cadaee8…, citedBy [...nmn-1g-daily [ACCEPTED]]` | same locator, same hashes; citedBy `[...nmn-1g-daily [SUPERSEDED]]` |
| Q02-2 re-anchoring | `"My 82-year-old father, ...", FUZZY, 2026-11-15, SYNTHETIC_FIXTURE` | `"My 82-year-old father, we take half a gram ...", FUZZY, 2026-11-15` |
| Q02-3 as recorded at R | R=2026-10-10 -> 1.0 g; R=2026-11-20 -> 1.0 g (same occurrence) | R=2026-10-10 -> 1.0 g (original); R=2026-11-20 -> 0.5 g (successor) |
| Q02-4 text versions | 2 rows, both TRANSCRIPTION (publisher "under human review"; publisher human review, synthetic) | same |
| Q02-5 trace of the original | `ACCEPTED`, locator L1, hash 9cadaee8…, no supersession | `SUPERSEDED`, locator L1, hash 9cadaee8…, `SOURCE_CORRECTION`, successor 0.5 g |

Negative injections: fx02a N02-a old locator re-hung on the new snapshot -> **V-404** 1 row and **V-504** 1 row (`ASSERTION_BEFORE_RETRIEVAL`); N02-b REANCHORS written old->new -> **V-409** 2 rows. fx02b N02-c successor no longer re-anchors the prior citation -> **V-W21-08** 1 row. (Deleting the SUPERSEDES edge instead was tried: caught by baseline **V-109** and **V-506**.)

### fx03 `fx03-sponsor-read-vs-practice-report.cypher` (30 ok) — mandatory pair: sponsor read vs independent practice report; caption discrepancy

Baseline validation: 0 failing rows. W21 validators: 0 rows.

| Query | Expected = observed |
|---|---|
| Q03-1 practice reports | Huberman "regular blood work" `SPONSOR_READ` / segment SPONSOR_READ; Sinclair "self-measurement of 45 different things" `EDITORIAL` / segment CHAPTER |
| Q03-2 independent practice reports only | 1 row: the guest's `w21-hl52-guest-measures-45-things` |
| Q03-3 conflict relevance | guest statement: INDIRECT, SPONSOR_OF_CONTAINER, DISCLOSED_IN_CONTAINER, ties [SPONSORS_CONTENT, BOARD_MEMBER_OF]; host statement: DIRECT, SPONSOR_OF_CONTAINER, DISCLOSED_IN_CONTAINER, ties [SPONSORS_CONTENT] |
| Q03-4 caption discrepancy (CQ-PV-04, CQ-CL-C03) | 1 row: the guest's occurrence with two renderings: page "...or I know if something's..."; YouTube "...or I think I know if something's..." |
| Q03-5 forbidden implications | 0 ENDORSES_PRODUCT/RECOMMENDS edges, 0 SUPPORT verdicts |

Negative injections: N03-a CONTRADICTED verdict resting only on the sponsorship -> **V-424** 1; N03-b endorsement from the board role -> **V-422** 1, **V-112** 1, **V-007** 1; N03-c NOT_DISCLOSED from a partial capture -> **V-426** 1; N03-d DISCLOSED_IN_CONTAINER without a span -> **V-W21-09** 1; N03-e sponsor-read occurrence stripped of `segmentKind` -> **V-W21-02** 1.

### fx04 `fx04-practice-qualified-vs-recommends-retelling.cypher` (29 ok) — mandatory pair: practice report with qualification vs retelling that says "recommends"; independent-support count unchanged

Baseline validation: 0 failing rows. W21 validators: 0 rows.

| Query | Expected = observed |
|---|---|
| Q04-1 independence | "Sinclair reports taking about 1 g of NMN per day": allInstances 2, independentFirstHand **1**, retellings 1, distinct first-hand asserters 1. "Taking 1 g of NMN daily slows aging": allInstances 1, independentFirstHand **0**, retellings 1 |
| Q04-2 qualifiers | INDIVIDUAL_VARIATION ("I'm not the same as everybody else ..."), HEDGE ("what I do may not perfectly, or work at all for others") |
| Q04-3 fidelity | digest: lost [INDIVIDUAL_VARIATION, HEDGE], REPORTS_PRACTICE -> RECOMMENDS, scopeBroadened true, "to slow aging", 2 lost-qualifier spans; NMN.com: qualificationLost **null** (not assessed, partial capture), REPORTS_PRACTICE -> REPORTS_PRACTICE |
| Q04-4 primary vs retelling | episode 52 occurrence PRIMARY; digest and NMN.com RETELLING (BELLLABS_MATCH; NMN.com edge also carries the citing locator) |
| Q04-5 own vs reported recommendation | 1 row: digest occurrence, own act STATES, reported act RECOMMENDS, asserter the digest author, credited Sinclair |
| Q04-6 | 0 RECOMMENDS edges |

Negative injections: N04-a RECOMMENDS derived from the retelling -> **V-W21-06** 1 and **V-423** 1; N04-b `qualificationLost` on the retelling -> **V-414** 1; N04-c retelling merged (second asserter on the original) -> **V-410** 1 (asserters 2). Informational **V-W21-10** returned 2 rows after N04-c only (the merged original now has the digest author as an asserter, which the retellings do not credit) and 0 rows on the positive fixture.

### fx05 `fx05-two-speakers-one-utterance.cypher` (23 ok) — mandatory pair: two speakers in one utterance split into two occurrences (CL-004)

Baseline validation: 0 failing rows. W21 validators: 0 rows.

| Query | Expected = observed |
|---|---|
| Q05-1 | 2 rows, asserters = 1 each: guest assent `REPORTS_PRACTICE`, labels ["(no label: caption cue)", "Andrew Huberman; David Sinclair"]; host question `QUESTIONS`, labels ["(no label: caption cue)", "Andrew Huberman"] |
| Q05-2 | firstHandReports 1, by ["David A. Sinclair"] |

Negative injections: N05-a one occurrence with two asserters -> **V-410** 1 (containers 1, asserters 2); N05-b the host's question counted as an instance -> **V-W21-11** 1; N05-c question attributed to its own asserter -> **V-W21-04** 1.

### fx06 `fx06-presentation-slide-vs-talk.cypher` (41 ok) — mandatory pair: presentation slide locator (PDF_PAGE) vs the talk's MEDIA_TIME locator

Baseline validation: 0 failing rows. W21 validators: 0 rows.

| Query | Expected = observed |
|---|---|
| Q06-1 | Merck claim: Document (INVESTOR_PRESENTATION) asserted by Merck & Co., Inc., `PDF_PAGE` page 11; Episode asserted by Robert Davis, `TEXT_QUOTE` (transcript PDF), no media seconds. Synthetic claim: Document (CONFERENCE_PRESENTATION) `PDF_PAGE` page 7; Episode `MEDIA_TIME` 1834.0 s; both by the synthetic speaker |
| Q06-2 | webcast rendition: revisions [WITHDRAWAL], 0 locators, 0 MEDIA_TIME; transcript PDF rendition: 3 locators, 0 MEDIA_TIME |
| Q06-3 | Merck claim: 2 occurrences, 2 distinct asserters (Person, Organization; the CEO's employment is not asserted here, so their dependence is a W01 role question); synthetic claim: 2 occurrences, 1 distinct asserter |
| Q06-4 | Christopher Schott MODERATOR ("Analyst"); Dean Li SPEAKER; Robert Davis SPEAKER |
| Q06-5 (CQ-CL-C02) | 1 row: from the CEO's spoken statement to deck `merck-jpm-2026-presentation-pdf` via `ACCOMPANIES_TALK` (asserted by Merck's event page) and its slide occurrence: PDF_PAGE page 11 "Commercial opportunity from new growth drivers is more than double consensus 2028 total KEYTRUDA sales" |

Negative injections: N06-a deck as rendition -> **V-W21-03** 1; N06-b spoken occurrence citing the slide -> **V-411** 1; N06-c invented media offset on the transcript PDF -> **V-W21-01** 1; N06-d qualifier taken from another container -> **V-416** 1 and **V-W21-12** 1.

### fx07 `fx07-recommends-derived-projection.cypher` (9 ok, SYNTHETIC) — derived RECOMMENDS (CL-016)

| Check | Expected = observed |
|---|---|
| Q07-1 | 1 row: Synthetic Podcast Guest -> Compound X, rule `speech-act-recommends-projection-v1`, licensing speech act RECOMMENDS, conditions "every morning, if over fifty" |
| V-W21-06 | 0 rows |
| baseline V-423 (verbatim) | **1 row** — the failing case for W21-SR-07 (V-423 reads `rec.assertionUid`, which D-011 forbids on derived edges) |

### Inherited fixture check

`docs/schema/examples/claim-retelling-provenance.cypher` (79 statements, all ok) under `w21-validation.cypher`: V-W21-02 1 row (A6 sponsor read has no SPONSOR_READ segment), V-W21-09 2 rows (DISCLOSED_IN_CONTAINER without a disclosure span); all other W21 validators 0. Upgrade requested (W21-SR-17).

## 3. Validator coverage (each candidate has a negative it catches)

| Validator | Caught by | Forbidden implication / invariant |
|---|---|---|
| V-W21-01 rendition-bound media time | N01-a, N06-c | INV-401/402 reproducibility; round 0006 O-4 |
| V-W21-02 sponsor-read agreement | N03-e (and inherited fixture) | CQ-CL-08 |
| V-W21-03 deck not a rendition | N06-a | W21-D06 |
| V-W21-04 asserter range; attribution not self | N05-c | KCR-4.3 |
| V-W21-05 segment-rendition agreement | N01-b | W21-D02 |
| V-W21-06 derived RECOMMENDS | N04-a | [REPORTS_PRACTICE, RECOMMENDS], [RECOMMENDS, BELLLABS_RECOMMENDS] |
| V-W21-07 SPONSORS_CONTENT endpoints | N01-c | [SPONSORS_CONTENT, ENDORSES_PRODUCT] (endpoint discipline) |
| V-W21-08 correction keeps prior citation | N02-c | INV-504, TM-R2 |
| V-W21-09 disclosure needs a span | N03-d (and inherited fixture) | [NOT_FOUND_IN_PARTIAL_CAPTURE, NOT_DISCLOSED] companion |
| V-W21-10 attribution drift (informational) | fx04 N04-c side effect | [RETELLS, SAME_ASSERTION] |
| V-W21-11 question is not an instance | N05-b | CQ-CL-06 counting |
| V-W21-12 qualifier container-or-snapshot rule (amends V-416) | N06-d | CQ-CL-03; W08-SR-10 |

Module forbidden implications and where they are exercised: [REPORTS_PRACTICE, RECOMMENDS] fx04 N04-a (V-W21-06, V-423); [MENTIONS_PRODUCT, ENDORSES_PRODUCT] fx01 Q01-7 and N01-d, fx03 N03-b (V-422, V-112); [RETELLS, SAME_ASSERTION] fx04 N04-c (V-410), V-412; [HAS_FINANCIAL_INTEREST, ADJUDICATED_CONTRADICTED] fx03 N03-a (V-424); [NO_FINANCIAL_INTEREST_FOUND, ADJUDICATED_SUPPORTED] V-424 (same query, SUPPORTED branch; not separately injected); [ROLE_OPEN_AT_OBSERVATION, ROLE_CONTINUES_AFTER_OBSERVATION] fx01 Q01-3 (OBSERVATION_ONLY bases) and baseline V-427 / QS-2 (W01); [CHUNK_MATCH, SOURCE_SUPPORT] V-406/V-407 (W20; no chunks in W21 fixtures).

## 4. Not covered here

Access leakage: no private data is involved in W21 fixtures (ExperienceReport's `CohortParticipant` reports are routed to W23 by the migration map). GraphQL-level queries were not run against the generated API; the fragment was built with stubs only (see `08-completion-report.md`). Enterprise-only constraints were not exercised (no Enterprise instance).
