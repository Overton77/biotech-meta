# W01 decision and seam ledger

Status vocabulary: **accepted-for-proposal** (W01 stands behind it inside its ownership; Fable may still overrule), **unresolved** (needs another owner or a ruling). Seam requests are in `seam-requests.yaml` (W01-SR-01..22). Source ids S1..S11 refer to `03-source-manifest.md`; fixture ids to `06-fixtures-and-queries.md`.

## 1. Decisions

| Id | Decision | Alternatives considered | Evidence (source + failing case) | Status |
|---|---|---|---|---|
| D-W01-01 | `ConsumerBrand` is a separate Entity, never an Organization; person-to-company FINANCIAL_INTEREST edges never target it. | (a) brand as Organization specialization; (b) brand merged into the owning LegalEntity | S2/S3/S4: TRU NIAGEN mark registered to ChromaDex, Inc. while the parent speaks of "ChromaDex's consumer products, sold as the brand Tru Niagen"; the FY2025 10-K (S2) says ChromaDex Corporation acquired Healthspan Research LLC, "a consumer product company offering Tru Niagen® branded products", in 2017 and that it was dissolved on 2021-01-15 after contributing its assets to ChromaDex, Inc.: the brand outlives and crosses legal entities. Failing case: 0.2.0 example's BOARD_MEMBER_OF → brand escapes V-434 (combined load: V-W01-01 1 row). | accepted-for-proposal |
| D-W01-02 | Legal name and ticker are `OrganizationSnapshot` state on one `LegalEntity`; near-homonyms stay distinct. | (a) new LegalEntity per legal name; (b) legal name as identity key | S1/S2/S3: "Niagen Bioscience, Inc. (formerly ChromaDex Corporation)"; "Effective March 19, 2025 …"; "ChromaDex Corp. (NASDAQ:CDXC)"; ChromaDex, Inc. is a wholly owned subsidiary. Q-W01-04/05. | accepted-for-proposal |
| D-W01-03 | Control (`PARENT_OF`), equity (`HOLDS_EQUITY_IN`) and investment (`INVESTED_IN`) are distinct predicates; candidate forbidden implication [HOLDS_EQUITY_IN, PARENT_OF]. | live `CONTROLS` with `stakePercent`; one `HAS_FINANCIAL_RELATIONSHIP {kind}` (rejected in round 0006) | S1: Pioneer Step 6,917,783 shares + director-nomination right, no control statement; S2: "wholly owned subsidiaries". Negative N3 (PARENT_OF from equity) caught by V-112 only with the candidate pair. | accepted-for-proposal (catalog pair: unresolved, W01-SR-10) |
| D-W01-04 | `ENDORSES_PRODUCT` only from an explicit endorsement assertion; advisory/board/financial ties never create it. | inference from advisory listing + testimonial | Catalog FI; SRC-FTC-16CFR255-0/5; N1 trips V-007, V-112, V-422, V-W01-02. Positive minimal pair: synthetic explicit endorsement projects one edge (Q-W01-02). | accepted-for-proposal |
| D-W01-05 | Normalization rules R-ROLE-1 (officer titles → EMPLOYED_BY), R-ROLE-2 (board titles → BOARD_MEMBER_OF; "Executive Chairman" → AFFILIATED_WITH with title), R-ROLE-3 (unclear → AFFILIATED_WITH verbatim), R-ROLE-4 (project only ACCEPTED, predicate = edge type). | separate OFFICER_OF; map every executive title to EMPLOYED_BY | S1: Fried director 2015 and CEO June 2018; Rubin director only; Jaksch "transitioned from Executive Chairman to Chairman of the Board in July 2022" (employment not stated); Yu "the director nominated by Pioneer Step". | accepted-for-proposal |
| D-W01-06 | Precision-aware validity: bounds stored as the first instant of their period; "2011-2017" ⇒ validTo 2017-01-01 YEAR; answers inside an uncertainty period are "possibly". | round-0006 "widest interval" reading (validTo 2018-01-01) | Contract A6; round 0007 §9; S1 table "Director Since 2017" vs bio "since August 2017"; Q-W01-01 P01/P03/P05/P07. QS-2 ignores precision (W01-SR-04). | accepted-for-proposal (QS change: unresolved) |
| D-W01-07 | Correction of the year bound is an `EXTRACTION_FIX` supersession: old assertion SUPERSEDED with `recordedTo`, old edge closed, new assertion and edge. | edit validTo in place | INV-501; w01-01; P06 vs P07 differ by recorded time only. | accepted-for-proposal |
| D-W01-08 | `Facility` absorbs `PhysicalLocation` (CL-015 / T-004 proposed ruling: **merge**). Site roles (headquarters) live on `OPERATES_FACILITY.facilityRole`. REMOTE/VIRTUAL are not facilities. | keep `PhysicalLocation` as a seam beside `Facility`; Facility = laboratory | S6 (101.5(e): label may print principal place of business instead of the plant); S7 (CLIA per laboratory location; mobile/campus exceptions); INV-304 establishment registration is a Facility status. Q-W01-07; N7 trips V-W01-04. | accepted-for-proposal; CL-015 ruling for Fable |
| D-W01-09 | `OrganizationSnapshot` attaches by `HAS_STATE`; payload frozen; role flags retired. | keep live HAS_SNAPSHOT | Catalog HAS_SNAPSHOT = Source→SourceSnapshot; CL-014 principle; round 0007 §12. V-W01-08. | accepted-for-proposal; collision ruling unresolved (W01-SR-03) |
| D-W01-10 | Person: public actors only; birth/death fields retired; social URLs → `Identifier`; `LINKS_TO` → `ResolutionHypothesis`. | keep personal fields as PUBLIC | contract A9; S9 (dates finer than year identifying); no CQ uses them. | accepted-for-proposal (W23 confirmation requested) |
| D-W01-11 | `CohortParticipant` = `PseudonymousActor` specialization with issuer-scoped token Identifier; no Person link; explicit privacyClass. | (a) retire the type to the private store; (b) keep as live with HAS_PARTICIPANT_TOKEN | Contract A9, CL-018; identity_resolution forbidden implication on shared scheme/value across issuers; w01-06 Q-W01-09 (two P03s); w01-91 trips V-W01-05, V-113. | unresolved until W23 rules CL-018 (W01-SR-11) |
| D-W01-12 | Live role edges migrate only through PROPOSED assertions (reviewer MIGRATION); nothing is projected until a capture review. | copy live edges as asserted edges with a synthetic assertion | INV-101/103; live edges have no locator; V-W01-07. | accepted-for-proposal |
| D-W01-13 | `SUBSIDIARY_OF` canonicalized to `PARENT_OF`; assertion-only predicates listed in 04 §3. | two stored edge types | duplicate edges for one fact | unresolved (catalog change, W01-SR-10) |
| D-W01-14 | Inverse fields use one relationship type with `direction: IN` (no inverse edge types); holder ranges use union `RoleHolderTarget`. | inverse stored types (live EMPLOYS/HAS_BOARD_MEMBER) | @neo4j/graphql 7.6.3 build OK with union + properties + IN direction (08 report). | accepted-for-proposal |
| D-W01-15 | Fields for other owners' relationships on W01 types are reserved slots, not written by W01. | write them with guessed property types | contract C (import, never redefine); W01-SR-20 | accepted-for-proposal |

## 2. Kernel-change requests (to W00; primary source + failing case)

| Id | Request | Primary source | Failing case | Workaround in W01 fixtures |
|---|---|---|---|---|
| W01-SR-07 | Source-stated witness instant (`statedAsOf`) for point-in-time statements | S1 beneficial ownership footnote (13D/A filed 2024-08-20) | HOLDS_EQUITY_IN can only answer POSSIBLE_START_UNKNOWN for 2024-09-01 | bounds null/UNKNOWN; date kept in `roleTitleVerbatim` |
| W01-SR-22 | Quantity qualifying an object assertion (stake share count) | S1 ("6,917,783 shares") | V-003 row when written as `valueString` beside an object | verbatim text only |
| W01-SR-02 | `ActorIdentity.name` nullable | contract D-013 | 7.6.3 build fails with `name: String!` on the interface | stub with nullable name |
| W01-SR-04, -08 | Precision-aware QS-2 classes; witness = publishedAt | round 0007 §9; S1 | Rubin 2017-05-15 answered "yes"; 2025 proxy treated as evidence for 2026 | Q-W01-01 ladder |

## 3. Conflict-ledger items touched

| Ledger | W01 position |
|---|---|
| CL-013 (registry text) / T-004 / CL-015 | PhysicalLocation **merges** into Facility (D-W01-08). Proposed status: RULED on Fable's acceptance. |
| CL-016 | Agree: `RECOMMENDS` is W21's projection; W01 reserves `Person.recommends` slot only. |
| CL-018 | W01 proposal D-W01-11; open until W23. |
| CL-014 (principle) | Extended to HAS_SNAPSHOT (W01-SR-03). |
| CL-012 | No W01 position. |

## 4. Not settled by W01 (no fabricated consensus)

- Whether the catalog keeps `SUBSIDIARY_OF` as a separate stored type (W01 says no).
- Whether `CohortParticipant` stays in the shared graph at all (W23).
- Study-role predicate writer (W09).
- Seller display accounts (W15).
- Whether OrganizationType gains CORPORATE_GROUP (Fable).
