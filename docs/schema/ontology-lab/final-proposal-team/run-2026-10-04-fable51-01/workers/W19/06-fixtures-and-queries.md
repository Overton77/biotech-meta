# W19 fixtures and queries

All statements below were **run** on 2026-10-04 on Neo4j **5.26.31 Community** (embedded `org.neo4j.test:neo4j-harness`, one fresh in-process instance per scenario, W19-only directories `scratchpad/W19/run1…run4`, stopped after use) with the run harness `validation/harness/run-cypher.mjs` (one transaction per statement, no variable crosses `;`). Enterprise behaviour is not tested. Every node carries its primary label and its archetype label; uids use registered tokens; real snapshots hash stored excerpts (`STORED_EXCERPT_TEXT`), synthetic ones use `SYNTHETIC_FIXTURE`.

## 1. Files

| File | Statements | Result | Content |
|---|---|---|---|
| `fixtures/01-cl003-work-rendition-identity.cypher` | 37 | 37 ok | Publication PMID 29184669 + 4 renditions; correction PMID 30155270 + 1 rendition; Episode 52 + 4 renditions; synthetic talk (video rendition) and slide deck (own container), two occurrences with different asserters |
| `fixtures/02-primary-vs-retelling.cypher` | 30 | 30 ok | real transcript and caption snapshots of episode 52; two occurrences each located on two renditions (one with a hedge disagreement); synthetic retelling (BELLLABS_MATCH + hypothesis) and retelling-of-retelling (EXPLICIT_CITATION); live `isPrimarySource = true` on the retelling outlet |
| `fixtures/03-partial-capture-not-found.cypher` | 21 | 21 ok | publisher HTML, PMC, PubMed (real partial + synthetic complete) snapshots; paper occurrence with container = Publication and locators on two renditions; EdenRoc interest + ConflictRelevanceAssessment `NOT_FOUND_IN_PARTIAL_CAPTURE`; truncated RSS feed capture |
| `fixtures/04-source-revision-reanchor.cypher` | 10 | 10 ok | synthetic 2018 archive snapshot (observed 2018-01-15, retrieved 2026-10-04T03:00Z), old locator, new locator `REANCHORS {EXACT}`, two ERRATUM `SourceRevisionEvent`s (HTML with prior/resulting snapshots; PDF without), notice snapshot, asserted `CORRECTS` |
| `fixtures/05-coverage-discovery-authority.cypher` | 30 | 30 ok | two `SourceCoverageRequirement`s; six real `SourceDiscoveryRecord`s (FOUND ×2, BLOCKED ×3, PARTIAL ×1); registry snapshot and two registry assertions (one ACCEPTED with CAPTURE_FIDELITY adjudication); synthetic 10-K capability assertion; five `SourceAuthorityAssessment`s |
| `fixtures/80-queries.cypher` | 25 | 25 ok | Q-01 … Q-18 (read-only) |
| `fixtures/90-negative-mutations.cypher` | 14 | 14 ok | N1 … N11 combined (scenario B) |
| `fixtures/91-negative-isolated-n1a.cypher` | 2 | 2 ok | N1a alone (scenario C) |
| `fixtures/92-negative-isolated-n7.cypher` | 2 | 2 ok | N7 alone (scenario D) |
| `fixtures/excerpts/*.txt` | 8 files | — | stored excerpts whose NFC-WS1 SHA-256 values are the snapshot `contentHash` values |

Scenarios: **A** = 01–05 then 80 and the full `docs/schema/neo4j/validation.cypher` (174 statements); **B** = A + 90; **C** = 01–05 + 91; **D** = 01–05 + 92. Every write statement changed the graph (checked from the per-statement counters; no MATCH-miss no-ops).

## 2. Query expectations (scenario A, run; all matched)

| Query | CQ | Expected = actual |
|---|---|---|
| Q-01 | CL-003, CQ-EV-05 | 4 rows: nature HTML (PEER_REVIEWED_PUBLICATION, FULL), nature PDF (FULL), PMC5701244 (FULL), PubMed 29184669 (BIBLIOGRAPHIC_RECORD, PARTIAL) |
| Q-01b | CL-003 | 2 rows: episode 52 with 4 renditions [PODCAST_DIRECTORY_RECORD, AUDIO_FEED_ITEM, VIDEO_RENDITION, PODCAST_TRANSCRIPT_PAGE]; synthetic talk with 1 (VIDEO_RENDITION); the deck is not listed |
| Q-02 | rule R2 | 0 rows |
| Q-03 | rule R3 | 0 rows |
| Q-04 | rule R4 | 0 rows |
| Q-05 | CQ-PV-05 | 3 rows: HL52 occurrence PRIMARY (0 hops); digest RETELLING (1 hop, root = HL52 occurrence, `ignoredLiveDocumentFlag: true`); aggregator RETELLING (2 hops, same root) |
| Q-06 | CQ-AX-05 | claim "1 g NMN daily slows aging": 2 assertions, 1 independent primary line; the other two claims 1/1 |
| Q-07 | CQ-PV-04 | 2 rows: `knows-by-measuring` (captions "I think I know" vs transcript "I know"); `nmn-1g-daily` ("my 82-year-old" vs "My 82 -year-old") |
| Q-08a | QS-7 / not-found | `NOT_FOUND_IN_PARTIAL_CAPTURE` (PubMed only; the synthetic complete capture does not help because the rendition is PARTIAL) |
| Q-08b | QS-7 / not-found | `FOUND` (all renditions) |
| Q-08c | QS-7 / not-found | `NOT_FOUND_IN_PARTIAL_CAPTURE` (feed truncated) |
| Q-09 (= V-426) | forbidden implication | 0 rows |
| Q-10 | CQ-EV-05 | 4 rows: HTML ERRATUM 2018-08-20 DAY, announced by PMID 30155270, prior = synthetic 2018 snapshot, resulting = 2026-10-04 snapshot, `publicationLevelCorrects: true`; PDF ERRATUM with null snapshots, `true`; PMC and PubMed rows with no event (`false`: no revision established) |
| Q-11 | CQ-PV-02 | 1 row: old locator on the 2018 snapshot only (`snapshotsHoldingOldLocator: 1`), same quote, `EXACT` |
| Q-12a (= V-409 as written) | seam SR-09 | **1 row** (expected under the current rule: the archive snapshot was retrieved after the live one) |
| Q-12b (proposed V-409′) | seam SR-09 | 0 rows |
| Q-13a | CQ-PV-C02 | 3 rows at R = 2026-10-05: publication.revision-status / PMID 29184669 FRESH (last observed 2026-10-04T02:00Z), NOT_REQUIRED; PMID 30155270 FRESH, NOT_REQUIRED; trial-registration / NCT02678611 FRESH, history **BLOCKED** |
| Q-13b | CQ-PV-C02 | 3 rows at R = 2027-03-01: all STALE |
| Q-14a | truth separation | 0 rows |
| Q-14b | truth separation | status ACCEPTED, adjudications [CAPTURE_FIDELITY], verdicts [SUPPORTED] |
| Q-14c | no global score | 0 rows |
| Q-15 | CQ-PV-C01 | 5 rows: enrollment AUTHORITATIVE_SOURCE_PRESENT; RESULTS_PUBLISHED **NO_AUTHORITATIVE_SOURCE**; CORRECTS AUTHORITATIVE; synthetic 10-K HAS_CAPABILITY_STATE **NO_AUTHORITATIVE_SOURCE**; PROVIDES_INVESTIGATIONAL_PRODUCT AUTHORITATIVE (two PEER_REVIEWED_PUBLICATION renditions) |
| Q-16 | CQ-AX-07 (Essential) | 0 rows |
| Q-17 | CQ-ST-08 | 2 rows (REGISTERED_ENROLLMENT_COUNT 120; RESULTS_PUBLISHED false), observed 2026-10-04T00:58:05Z, PARTIAL_EXCERPT, `cannotEstablish` = registry notAuthorityFor tags, `historyRetrieval: [BLOCKED]` |
| Q-18 | CQ-PV-01 (Essential) | 1 row: said by Sinclair; 2 supporting spans on 2 renditions (both PARTIAL_EXCERPT); NONE_ASSESSED; generated by w19-curation; NO_POLICY_RECORD |

Full validation suite on scenario A: 174 statements, 0 errors. Rows only from informational checks (V-118 backfill counts, V-401b count row with value 0, V-514b assertions without contentHash = 12, V-522 nodes without privacyClass, capped at 100) and from **V-409 (1) and V-512 REVISION_ORDER (1)**: both are the late-archive ordering defect that seam W19-SR-09 asks W00 to fix; Q-12b shows the corrected rule returns 0.

## 3. Negative mutations (scenarios B, C, D, run)

| Mutation | Collapse reintroduced | Expected detection | Actual |
|---|---|---|---|
| N1a (scenario C) | deck claim moved into the talk's container | V-411 | V-411: 1 row (`synthetic-slides-nmn-250-raises-nad`, foreign deck locator) |
| N1b (scenario B, with N1) | deck declared `RENDITION_OF` the talk | V-411 goes silent; Q-04 | V-411: 0 rows; Q-04: 1 row (the laundering is the finding) |
| N2 | DOI resolver as Source identity | Q-02 | 1 row |
| N3 | PMC Source `RENDITION_OF` the nature HTML Source | Q-03 | 1 row (also silences V-411 for N7 in scenario B) |
| N4 | `NOT_DISCLOSED` from a partial capture | V-426 / Q-09 | 1 row each |
| N5 | old locator moved onto the new snapshot | V-402; Q-11 | V-402: 1 row (2 snapshots); Q-11 `snapshotsHoldingOldLocator: 2` |
| N6 | REANCHORS across two Sources | V-409 / Q-12b | V-409 rows 1 → 4; Q-12b 0 → 3 |
| N7 (scenario D) | paper occurrence with a Document container | V-411 | V-411: 1 row (PMC locator foreign) — failing case for SR-06 |
| N8 | discovery record wired to an assertion | Q-14a | 1 row (`INVALIDATES`) |
| N9 | coverage written into status without adjudication | V-110 | 1 row |
| N10 | global `reliabilityScore` on a Source | Q-14c | 1 row |
| N11 | retelling merged into the original (second asserter) | V-410; Q-18 | V-410: 1 row (asserters 2); Q-18 2 rows |

## 4. Mandatory cases in the brief

| Case | Where |
|---|---|
| primary vs retelling with INSTANCE_OF and RETELLS | fixture 02; Q-05, Q-06; N11 |
| PARTIAL_EXCERPT capture whose "not found" reads NOT_FOUND_IN_PARTIAL_CAPTURE | fixture 03; Q-08a/c, Q-09; N4 |
| Source whose snapshot changed (SourceRevisionEvent), old locator untouched, REANCHORS locator | fixture 04; Q-10, Q-11, Q-12; N5, N6 |
| coverage/freshness candidate kept separate from truth | fixture 05; Q-13a/b, Q-14a/b/c; N8, N9, N10 |
| temporal correction / late arrival | fixture 04 (archive observed 2018, retrieved 2026; erratum recorded 2026 with 2018 occurredAt) |
| identity collision | N2, N3 (DOI-as-Source; Source-as-work) |
| missing facts | Q-08 (not captured vs not found), Q-13 (NOT_ATTEMPTED), Q-17 (`cannotEstablish`) |
| access leakage | W19 records are INTERNAL (`privacyClass`), no private data; projection exclusion is W23's (SR-14); V-113…V-116 ran with 0 rows |

## 5. Reproduce

```
cd <harness dir with node_modules>   # validation/harness + npm i @neo4j/graphql@7.6.3 graphql@16 neo4j-driver@6
java -cp "classes:lib/*" EmbeddedNeo4j <fresh dir>          # writes <fresh dir>/bolt.uri
for f in 01 02 03 04 05; do node run-cypher.mjs <dir>/bolt.uri workers/W19/fixtures/$f-*.cypher; done
node run-cypher.mjs <dir>/bolt.uri docs/schema/neo4j/validation.cypher --params validation-params.json
node run-cypher.mjs <dir>/bolt.uri workers/W19/fixtures/80-queries.cypher --json out.json
# negative: fresh instance, 01-05, then 90 (or 91 / 92 alone), then validation + 80
```
