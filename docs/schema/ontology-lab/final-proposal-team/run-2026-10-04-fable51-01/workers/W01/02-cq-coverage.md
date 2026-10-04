# W01 CQ coverage matrix

Priority and answerability are copied from `competency-questions.md` (A answerable, Q with qualifications, X needs outside data). "Query" names the executed query in `fixtures/w01-queries.cypher` (results in `06-fixtures-and-queries.md`).

## 1. Existing CQs

| CQ (priority, ans.) | Example answer (from W01 fixtures) | Distinction | Evidence requirement | Proposed node / property / edge / edge property | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-CL-05 (Essential, Q) time-and-tie part | "On 2021-12-27 Sinclair advised and had invested in Segterra (A, I 2011–present as observed); his board seat had ended (2011–2017)." | valid at statement time vs now; investor vs equity; group vs member | role assertions with per-bound precision and basis; snapshot publishedAt/observedAt | `ADVISES_ORGANIZATION`, `INVESTED_IN`, `BOARD_MEMBER_OF` + `RoleEdgeProperties`/`OwnershipEdgeProperties` (assertionUid, validFrom/To, precisions, bases, recordedFrom/To, roleTitleVerbatim) | Q-W01-01 (P05–P08), Q-W01-08 | using today's roles for a past statement (V-427); open-ended board edge answering "yes" |
| CQ-AX-18 (Foundational, Q) | "Steven Rubin, 2017-05-15: possibly a director (Director Since 2017, year precision)." "Yu: possibly by the table, no by the bio ('since August 2017')." | year vs month precision; known vs possible | `validFromPrecision`, `validToPrecision`, witness = publishedAt | same + precision-aware ladder | Q-W01-01 (P01–P04, P09–P11) | answering "yes" inside an uncertain year (W01-SR-04); inferring endorsement from advising |
| CQ-EC-01 (Foundational, Q) | "As of 2021-12-27 (recorded 2026-10-04): Sinclair → Segterra ADVISES (A), INVESTED_IN (I); board ended 2017." | asserted role vs name co-occurrence; valid vs recorded time | role assertions with bounds | all W01 role edges, `PARENT_OF`, `AFFILIATED_WITH` | Q-W01-08 | neighbourhood inflated by names or expired roles |
| CQ-EC-02 (Foundational, Q) | "Tru Niagen is a brand (no Organization label); ownership asserted only as PROPOSED by two parties; ChromaDex Corporation is the former legal name of Niagen Bioscience, Inc.; ChromaDex, Inc. is its subsidiary, a different entity." | brand vs legal entity; same name vs same identity; rename vs new entity | brand page/label/mark record; filing name-change text; registry identifier | `ConsumerBrand`, `LegalEntity`, `OWNS_BRAND`, `OrganizationSnapshot.legalName`, `HAS_STATE`, `HAS_IDENTIFIER` (CIK) | Q-W01-03, Q-W01-05 | merged brand/legal entity (V-433, V-W01-03); identity by similar name |
| CQ-EC-03 (Essential, Q) | "Path Sinclair → EdenRoc (equity, group-level) → MetroBiotech (AFFILIATED_WITH) → 'NAD boosters': indirect, incomplete." | direct vs indirect; asserted hop vs inferred class | role assertions; group membership assertions | `HOLDS_EQUITY_IN`, `AFFILIATED_WITH` (org→org), group `Organization` (CORPORATE_GROUP requested) | not re-run by W01 (0.2.0 example covers it; W21 owns relevance) | pushing a group role to a member company (V-434) |
| CQ-EC-04 (Expansion, Q) | "An author affiliated with Elysium Health Inc. is not a study funder." | affiliation vs funding | per-publication affiliation assertion | `AFFILIATED_WITH` (Person→Organization) with locator in the publication; study-role edges written by W09 (W01-SR-17) | not run (no study fixture in W01) | `[AUTHOR_AFFILIATED_WITH, FUNDS_STUDY]` |
| CQ-MF-01 (Essential, A) | "SleepWell capsules: manufactured by Synthetic Contract Manufacturing Inc. at its Ogden plant (since 2024-03); Synthetic Brand Owner LLC distributes ('Distributed by') and owns the brand; the label address is its office." | manufacture vs contract-manufacture vs distribute vs brand-own; label address vs plant | label statement (21 CFR 101.5(c),(e)); manufacturer statement | `MANUFACTURES_PRODUCT`, `DISTRIBUTES_PRODUCT`, `CONTRACT_MANUFACTURES_FOR`, `OWNS_BRAND`, `OPERATES_FACILITY {facilityRole}`, `Facility` | Q-W01-07 | "brand X manufactures" from a label or marketing (V-112 DISTRIBUTES→MANUFACTURES) |
| CQ-TM-04 (Foundational, A) | "Jaksch was Executive Chairman until July 2022 (month precision): on 2022-07-15 possibly; start unknown." | null vs stated bound; precision per bound | bases and precisions | `validFromBasis`/`validToBasis`/precisions on W01 edges | Q-W01-01 P09, P10 | fabricated certainty about dates |
| CQ-TM-07 (Essential, A) | "The 2018 end bound was an extraction error (EXTRACTION_FIX), not a fact ending." | correction vs ending | `SUPERSEDES {supersessionKind}` | legacy edge closed (`recordedTo`), new edge | Q-W01-01 P06 vs P07 | treating a fix as a world change |
| CQ-CL-07 (Expansion, Q) | "Participant P03 of dataset A and P03 of dataset B are two participants; no person is linked." | identifier scheme/value vs issuer | issuer-scoped token | `CohortParticipant`, `PseudonymousActor`, `Identifier(scheme PARTICIPANT_TOKEN, issuer)` | Q-W01-09 | identity by shared token value |
| CQ-CL-09 (Expansion, Q) | as above; experience reports authored by the participant (W21 `REPORTS`) | public token vs private user | public source of the token | `CohortParticipant` (restricted) | Q-W01-09 | private user data in the shared graph |
| CQ-PC-08 (Essential, A) | "No relationship joins a Person to a participant token; private records are unreachable." | shared vs private | uid prefix, privacyClass | `CohortParticipant.privacyClass` mandatory; no `HAS_PARTICIPANT_TOKEN` | V-W01-05, V-113 on w01-91 | re-identification and leak |
| CQ-AX-14 (Foundational) | live `searchOrganizationsByName`, `searchPeople`, `searchOrganizationSnapshots` keep working | stored vs GraphQL names | — | `@fulltext` indexes retained on `Organization`, `Person`, `OrganizationSnapshot` | build check (08 report) | broken generated queries |

## 2. Candidate CQs (W01)

| Id | Question | Priority proposed | Rationale and failing case | Model | Query |
|---|---|---|---|---|---|
| CQ-EC-C01 (candidate) | What were the legal name and listing ticker of registered entity X on date V, as recorded at R? | Foundational | ChromaDex Corporation → Niagen Bioscience, Inc. effective 2025-03-19 and CDXC → NAGE; a 2024 filing by "ChromaDex Corporation" must resolve to the same entity, while "ChromaDex, Inc." must not | `OrganizationSnapshot.legalName`, `.canonicalTicker`, `HAS_STATE` episodes, `Identifier` | Q-W01-04 |
| CQ-EC-C02 (candidate) | Who controls organization X, and which parties merely hold equity or invested in it, as of V? | Foundational | Pioneer Step holds stock and nominates a director but is not a parent; Niagen wholly owns ChromaDex, Inc. | `PARENT_OF`, `HOLDS_EQUITY_IN`, `INVESTED_IN`, `OwnershipEdgeProperties` | Q-W01-06 |

## 3. SDL element trace (every fragment element)

| SDL element | CQ / invariant / interoperability requirement |
|---|---|
| `Organization` (+ fields `displayName`, `organizationType`, `jurisdiction`) | CQ-EC-01, CQ-EC-02, CQ-MF-01; INV-009 |
| `Organization.legalName`, `.canonicalTicker`, `.currentAsOf` | CQ-EC-C01; D-015 (`OrganizationName` fulltext index fields) |
| `Organization.searchText/searchFields/embeddingModel/embeddingDimensions/searchEmbedding` | CQ-AX-14; INV-107 |
| `LegalEntity` (+ `registrationId`, `incorporatedOn`, `dissolvedOn`) | CQ-EC-02, CQ-EC-C01; identity rule A2 |
| `ConsumerBrand` | CQ-EC-02, CQ-CL-05 (brand sponsor reads) |
| `Facility` (+ address fields, `facilityKind`) | CQ-MF-01, CQ-MF-04, CQ-AX-23; INV-304 |
| `OrganizationSnapshot` (payload, `payloadHash`, `assertionUids`, `stateType`, effective bounds, TemporalSnapshot cache) | CQ-EC-C01, CQ-TM-01, CQ-TM-07; live API compatibility (round 0007 §12) |
| `Person` (+ `title`, `bio`, `orcid`) | CQ-CL-01, CQ-CL-05, CQ-EC-01; D-015 (`PersonSearch` fields) |
| `PseudonymousActor`, `AnonymousActor` | CQ-CL-07; KCR-4.3 (`ASSERTED_BY` range) |
| `CohortParticipant` | CQ-CL-09, CQ-PC-08, CQ-CL-07 |
| `RoleEdgeProperties` | CQ-CL-05, CQ-AX-18, CQ-EC-01, CQ-MF-01; INV-101..103, INV-501, INV-503 |
| `OwnershipEdgeProperties` | CQ-EC-C02, CQ-CL-05 |
| `FacilityEdgeProperties` | CQ-MF-01 |
| `RoleHolderTarget` | CQ-EC-01 (inverse traversal) |
| `BOARD_MEMBER_OF`, `EMPLOYED_BY`, `ADVISES_ORGANIZATION`, `FOUNDED_ORGANIZATION`, `INVESTED_IN`, `HOLDS_EQUITY_IN`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM` | CQ-CL-05, CQ-EC-01, CQ-EC-03, CQ-AX-18 (FINANCIAL_INTEREST family) |
| `AFFILIATED_WITH` | CQ-EC-01, CQ-EC-03, CQ-EC-04 |
| `PARENT_OF` | CQ-EC-C02, CQ-EC-01 |
| `OWNS_BRAND` | CQ-EC-02, CQ-MF-01 |
| `OPERATES_FACILITY` | CQ-MF-01, CQ-MF-04 |
| `MARKETS_PRODUCT`, `MANUFACTURES_PRODUCT`, `DISTRIBUTES_PRODUCT`, `CONTRACT_MANUFACTURES_FOR`, `SUPPLIES_INGREDIENT_MATERIAL` | CQ-MF-01; INV-009; V-220 |
| `ENDORSES_PRODUCT` | CQ-RC-05, CQ-AX-18 (negative: advising is not endorsing); V-007, V-422 |
| enums `OrganizationType`, `FundingStage`, `EmployeeCountBand`, `LocationType`, `RoleType`, `CorporateRoleType`, `SeniorityLevel`, `CompensationKind` | as the fields that use them; live API compatibility |

`MARKETS_PRODUCT` and `SUPPLIES_INGREDIENT_MATERIAL` are not exercised by a W01 fixture (the 0.2.0 `filing-vs-capability.cypher` exercises `SUPPLIES_INGREDIENT_MATERIAL`; `MARKETS_PRODUCT` is declared NONEXCLUSIVE in the catalog). `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM` and `FOUNDED_ORGANIZATION` are exercised only by the 0.2.0 example and by V-421; they stay in the fragment as catalog FINANCIAL_INTEREST members.
