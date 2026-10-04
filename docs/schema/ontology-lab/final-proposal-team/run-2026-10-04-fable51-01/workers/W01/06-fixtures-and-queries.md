# W01 fixtures and queries

All files are in `fixtures/`. **Execution status: run** on an embedded Neo4j 5.26.31 Community instance started by W01 from the run harness (`validation/harness`, `EmbeddedNeo4j.java`, `run-cypher.mjs`), 2026-10-04. Per-statement counts are in `fixtures/execution-summary.json`. Every statement binds its own nodes by uid; every node carries its primary label and its archetype label; snapshots of real pages hash the stored excerpt text (`STORED_EXCERPT_TEXT`), synthetic ones use `SYNTHETIC_FIXTURE`.

## 1. Files

| File | Content | Statements | Result |
|---|---|---|---|
| `w01-01-role-time-precision.cypher` | 2025 proxy roles (Yu, Rubin, Fried, Jaksch; YEAR and MONTH precision), Sinclair board 2011–2017 with `EXTRACTION_FIX` correction of the end bound | 91 | 91 OK |
| `w01-02-advises-not-endorses.cypher` | Sinclair ADVISES_ORGANIZATION and INVESTED_IN Segterra with no ENDORSES_PRODUCT; OWNS_BRAND PROPOSED (not projected); synthetic explicit endorsement (positive of the pair) | 40 | 40 OK |
| `w01-03-brand-vs-legal-entity.cypher` | Tru Niagen brand vs Niagen Bioscience, Inc. (legal-name/ticker states, CIK) vs ChromaDex, Inc. (subsidiary, mark registrant); PARENT_OF | 50 | 50 OK |
| `w01-04-investor-vs-parent.cypher` | Pioneer Step HOLDS_EQUITY_IN Niagen (no control); Yu nominee AFFILIATED_WITH Pioneer Step; Yu EMPLOYED_BY Horizons Digital; affiliate-of stays AFFILIATED_WITH | 26 | 26 OK |
| `w01-05-facility-label-roles.cypher` (SYNTHETIC) | label "Distributed by" vs manufacturer; label place of business vs plant; OWNS_BRAND projected; CMO OPERATES_FACILITY | 49 | 49 OK |
| `w01-06-cohort-participant-identity.cypher` (SYNTHETIC) | two datasets, token P03 each, two participants | 25 | 25 OK |
| `w01-90-negative-forbidden-implications.cypher` | N1–N9 violations (load on top of 01–06 in a scratch DB) | 10 | 10 OK (violations expected) |
| `w01-91-negative-privacy-leak.cypher` | L1–L3 privacy leaks (expected to fail) | 5 | 5 OK (violations expected) |
| `w01-queries.cypher` | Q-W01-01..09 and V-W01-01..12 | 21 | 21 OK |

Load order: 01, 02, 03, 04, 05, 06 (02–04 reuse identities of 01/03 by MERGE on uid). Total after 01–06: 134 nodes, 251 relationships. Combined with the six 0.2.0 example fixtures (loaded first): every statement OK; the W01 Sinclair source reuses the example's Source uid `hu:source:sinclair-lab-affiliations` (the `canonicalUri` uniqueness constraint rejected a second Source for the same URL in a first attempt, which is the identity rule working).

## 2. Mandatory cases (brief)

| Case | Where | Expected and observed |
|---|---|---|
| Role valid at year precision, queried at a date inside that year → "possibly" | w01-01; Q-W01-01 P01 (Rubin, "Director Since 2017", V = 2017-05-15) | `POSSIBLE_START_PRECISION`, answer **possibly** (observed). Also P05 (Sinclair "B (2011-2017)", V = 2017-06-15): `POSSIBLE_END_PRECISION`, possibly. |
| ADVISES_ORGANIZATION with no ENDORSES_PRODUCT | w01-02; Q-W01-02 | Sinclair: advisoryEdges 1, endorsed [] (observed). Synthetic endorser: endorsed [plan], premise ENDORSES_PRODUCT. Negative N1 trips V-007, V-112, V-422, V-W01-02. |
| Brand vs legal entity minimal pair | w01-03, w01-05; Q-W01-03 | Tru Niagen and InsideTracker: isBrand true, isOrganization false, projectedOwners [], OWNS_BRAND assertions PROPOSED; SleepWell (synthetic): projected owner = Synthetic Brand Owner LLC (ACCEPTED). Niagen and ChromaDex, Inc.: LegalEntity, not brand. Negative N5 trips V-433 and V-W01-03. |
| Investor vs controlling parent minimal pair | w01-03, w01-04; Q-W01-06 | Niagen: controllingParents [], subsidiaries [ChromaDex, Inc.], equityHolders [Pioneer Step (6,917,783 shares …)], investors [] (observed). Negative N3 trips V-W01-02 and, with the candidate pair, V-112. |
| Temporal correction / late fix | w01-01; P06 vs P07 | as recorded now: KNOWN_NOT_VALID (no) on 2018-06-01; as recorded 2026-10-03T13:00Z (before the fix): POSSIBLE_END_PRECISION (possibly). |
| Identity collision | w01-03 (ChromaDex Corporation vs ChromaDex, Inc.), w01-06 (P03 × 2) | Q-W01-05: two uids, linked by PARENT_OF; Q-W01-09: two participants, personLinks 0. |
| Missing facts | w01-04 (equity bounds unknown), w01-01 (Jaksch start unknown) | P09: POSSIBLE_START_UNKNOWN; Q-W01-04 START_UNKNOWN for the former name. |
| Access leakage | w01-91 | V-W01-05 2 rows, V-113 1 row, V-522 1 row (observed). |

## 3. Query results on positive fixtures (01–06)

### Q-W01-01 (CQ-AX-18, CQ-CL-05 time, CQ-TM-04), R = 2026-10-04T02:00Z unless stated — 22 rows observed

| Probe | Role (as printed) | Class | Answer |
|---|---|---|---|
| P01 Rubin, 2017-05-15 | BOARD_MEMBER_OF ("Director Since 2017") | POSSIBLE_START_PRECISION | possibly |
| P02 Rubin, 2018-02-01 | BOARD_MEMBER_OF | KNOWN_OPEN_END_WITNESSED | yes |
| P03 Yu, 2017-05-15 | BOARD_MEMBER_OF ("Director Since 2017") | POSSIBLE_START_PRECISION | possibly |
| P03 Yu, 2017-05-15 | BOARD_MEMBER_OF ("…since August 2017") | KNOWN_NOT_VALID | no |
| P04 Yu, 2017-10-01 | BOARD_MEMBER_OF ("Director Since 2017") | POSSIBLE_START_PRECISION | possibly |
| P04 Yu, 2017-10-01 | BOARD_MEMBER_OF ("…since August 2017") | KNOWN_OPEN_END_WITNESSED | yes |
| P05 Sinclair–Segterra, 2017-06-15 | ADVISES_ORGANIZATION (A) / BOARD_MEMBER_OF (B) / INVESTED_IN (I) | KNOWN_OPEN_END_WITNESSED / POSSIBLE_END_PRECISION / KNOWN_OPEN_END_WITNESSED | yes / possibly / yes |
| P06 Sinclair–Segterra, 2018-06-01 | A / B / I | witnessed / KNOWN_NOT_VALID / witnessed | yes / no / yes |
| P07 same, R = 2026-10-03T13:00Z | B (legacy reading, validTo 2018 YEAR) | POSSIBLE_END_PRECISION | possibly |
| P08 Sinclair–Segterra, 2021-12-27 (episode 52) | A / B / I | witnessed / KNOWN_NOT_VALID / witnessed | yes / no / yes |
| P09 Jaksch, 2020-01-01 | AFFILIATED_WITH ("Executive Chairman") / BOARD_MEMBER_OF (2000) | POSSIBLE_START_UNKNOWN / witnessed | possibly / yes |
| P10 Jaksch, 2022-07-15 | AFFILIATED_WITH ("Executive Chairman") / BOARD_MEMBER_OF | POSSIBLE_END_PRECISION / witnessed | possibly / yes |
| P11 Fried, 2018-03-01 | BOARD_MEMBER_OF (2015) / EMPLOYED_BY (CEO, June 2018) | witnessed / KNOWN_NOT_VALID | yes / no |

Reading for consumers (CQ-AX-18): "On 2021-12-27 Sinclair was an advisor to and investor in Segterra (self-disclosed, from 2011, still listed when observed 2026-10-04); his board seat had ended in 2017. None of this means he endorses any InsideTracker product." P07 shows why the correction matters: the legacy reading answered "possibly" for mid-2018.

### Other queries

| Query | CQ | Observed rows |
|---|---|---|
| Q-W01-02 | forbidden implication | 2: Sinclair (advisoryEdges 1, endorsed []), synthetic endorser (advisoryEdges 0, endorsed [plan], premise ENDORSES_PRODUCT) |
| Q-W01-03 | CQ-EC-02 | 6 (see section 2) |
| Q-W01-04 | CQ-EC-C01 | 2024-06-01: ChromaDex Corporation / CDXC (START_UNKNOWN); 2025-03-19: Niagen Bioscience, Inc. / NAGE; 2025-06-01: Niagen Bioscience, Inc. / NAGE |
| Q-W01-05 | CQ-EC-02 | chromadex-inc [ChromaDex, Inc.] no subsidiaries; niagen-bioscience-inc [Niagen Bioscience, Inc., ChromaDex Corporation] subsidiaries [chromadex-inc] (the current name appears twice: node projection and state; harmless) |
| Q-W01-06 | CQ-EC-C02 | 1 (see section 2) |
| Q-W01-07 | CQ-MF-01 | manufacturers [synthetic CMO], manufacturingSites [Ogden plant], distributors [synthetic brand owner] "Distributed by", distributorSites [brand-owner office] |
| Q-W01-08 | CQ-EC-01 | ADVISES_ORGANIZATION Segterra (A, 2011 YEAR), INVESTED_IN Segterra (I, 2011 YEAR); board excluded (ended) |
| Q-W01-09 | CQ-CL-07 | dataset A → participant A-P03, dataset B → participant B-P03; personLinks 0 each |
| V-W01-01..12 | validation | 0 rows each |

## 4. Validation suite results

0.2.0 suite (`docs/schema/neo4j/validation.cypher`, 174 statements, all executed) on W01 fixtures 01–06 alone, with the run's `validation-params.json` and with W01-augmented params (W01 asserted types added to `$assertedTypes`; candidate pairs [HOLDS_EQUITY_IN, PARENT_OF], [BOARD_MEMBER_OF, EMPLOYED_BY] added): only informational rows — V-118 (6, uid backfill counts), V-401b (1 row: 4 accepted assertions rest only on SECTION locators = proxy table rows), V-514b (1 row: count 0, every W01 assertion carries `contentHash`). A first run returned **V-003 1 row** (equity assertion with object + `valueString`); fixed and recorded as W01-SR-22.

After loading the negatives (01–06 + 90 + 91):

| Violation | Expected checks | Observed (baseline params) | Observed (W01 params) |
|---|---|---|---|
| N1 ENDORSES_PRODUCT citing ADVISES assertion | V-007, V-112, V-422, V-W01-02 | V-007 1, V-112 (ENDORSES row: CITED_PREDICATE_DIFFERS…, FORBIDDEN_IMPLICATION_USED_AS_PREMISE), V-422 1, V-W01-02 | same |
| N2 HOLDS_EQUITY_IN citing INVESTED_IN | V-112, V-W01-02 | V-112 row, V-W01-02 | same |
| N3 PARENT_OF citing HOLDS_EQUITY_IN | V-W01-02; V-112 with candidate pair | V-W01-02 only (**gap in 0.2.0**) | V-112 row added (5 rows total) |
| N4 BOARD_MEMBER_OF → ConsumerBrand | V-W01-01, V-W01-02 | V-W01-01 1, V-W01-02 (OBJECT_IS_NOT_EDGE_END); **V-434 and V-421 silent (gap)** | same |
| N5 ConsumerBrand:LegalEntity node | V-433, V-W01-03 | both 1 | same |
| N6 MANUFACTURES_PRODUCT citing DISTRIBUTES | V-112, V-W01-02 | both | same |
| N7 Facility VIRTUAL + Organization label | V-W01-04 | 1 | same |
| N8 OWNS_BRAND projected from PROPOSED assertion | V-W01-07 | 1 (**no 0.2.0 check sees it**) | same |
| N9 equity pushed to a group member company | V-434, V-112, V-W01-02 | V-434 1, V-112 row, V-W01-02 | same |
| L1 Person HAS_PARTICIPANT_TOKEN CohortParticipant | V-W01-05 | 1 | same |
| L2 CohortParticipant without privacyClass | V-W01-05, V-522 | 1, 1 | same |
| L3 shared participant → :PrivateRecord | V-113 | 1 | same |

V-112 rows: 4 with baseline params (N1, N2, N6, N9), 5 with W01 params (+N3).

## 5. Tags

- Executed (run): all fixture files, Q-W01-01..09, V-W01-01..12, full 0.2.0 validation suite (three loads).
- Parser-only: none beyond the above. EXPLAIN-only: none.
- Not run: CQ-EC-03 money-path traversal and CQ-EC-04 author affiliation (no W01 fixture; covered by the 0.2.0 `claim-retelling-provenance.cypher` and by W09/W21 respectively).
- GraphQL: `sdl-fragment.graphql` built with `@neo4j/graphql` 7.6.3 together with kernel stubs (no queries executed through GraphQL).
