# W01 Actors and institutional ecosystem: domain recommendation

Worker W01 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical module: `organizations` (catalog 0.2.0, digest `8fb50ff0…84f0`). Seams: `private_context` (W23) for `CohortParticipant` and personal fields, `temporal`/`provenance` (W00) for the asserted-edge profile, `HAS_STATE` and identifiers.

## 1. Boundary and subdomains

The domain answers one question family: **who is which actor, and which time-bounded, source-backed ties connect actors to each other and to products, sites and money** (CQ-EC-01..04, CQ-CL-05, CQ-AX-18, CQ-MF-01). It has four subdomains.

| Subdomain | Elements (W01 sole writer) | What it is not |
|---|---|---|
| Actor identity | `Organization`, `LegalEntity`, `ConsumerBrand`, `Person`, `PseudonymousActor`, `AnonymousActor`, `CohortParticipant` | not a software `Agent` (W00); not a seller display account (W15); not a trademark (W14) |
| Site identity | `Facility` (absorbs live `PhysicalLocation`) | not a laboratory organization (`TestingLaboratory`, W12); not a market or jurisdiction (W15); not a label's place of business |
| Organization state | `OrganizationSnapshot` (VersionedState) attached by `HAS_STATE` | not identity; not evidence; not role facts |
| Ties | role and ownership edge types (asserted, `asserted_edge` profile): `BOARD_MEMBER_OF`, `EMPLOYED_BY`, `ADVISES_ORGANIZATION`, `FOUNDED_ORGANIZATION`, `INVESTED_IN`, `HOLDS_EQUITY_IN`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM`, `AFFILIATED_WITH`, `PARENT_OF`, `OWNS_BRAND`, `OPERATES_FACILITY`, `MARKETS_PRODUCT`, `MANUFACTURES_PRODUCT`, `DISTRIBUTES_PRODUCT`, `CONTRACT_MANUFACTURES_FOR`, `SUPPLIES_INGREDIENT_MATERIAL`, `ENDORSES_PRODUCT`; property types `RoleEdgeProperties`, `OwnershipEdgeProperties`, `FacilityEdgeProperties`; the FINANCIAL_INTEREST family | not relevance (W21 `ConflictRelevanceAssessment`), not disclosure (an occurrence fact, W21), not truth (INV-405) |

Explicit seams kept outside W01: assay details (W07), capability states and processes (W11), lab tests, labs and certifications (W12), regulatory statuses of facilities (W13), patents and trademarks (W14), commerce roles (W15), content sponsorship, channels and claim conflict relevance (W21), study roles (W09, see W01-SR-17), private context (W23).

## 2. Archetype classification

| Element | Archetype | Identity / state / artifact / occurrence |
|---|---|---|
| Organization, LegalEntity, ConsumerBrand, Facility, Person, PseudonymousActor, AnonymousActor, CohortParticipant | Entity | identity |
| OrganizationSnapshot | VersionedState | state (payload frozen; episodes on `HAS_STATE`) |
| role and ownership edges | asserted relationships (projection of exactly one `Assertion`) | claims about ties, time-bounded |
| a role statement in a filing, page or episode | Assertion (W00 kernel) | what a source said |

## 3. Decisions (summary; evidence and alternatives in `05-decision-seam-ledger.md`)

1. **Brand is not a legal entity and not an organization.** `ConsumerBrand` carries no `Organization` label; `OWNS_BRAND` is asserted; person-to-company FINANCIAL_INTEREST edges never target a brand (V-433, new V-W01-01, V-W01-03). Real case: the TRU NIAGEN mark is registered to ChromaDex, Inc. (a wholly owned subsidiary) while the parent calls Tru Niagen the brand of "ChromaDex's consumer products"; neither statement says who owns the brand.
2. **Legal name is state, the registered entity is identity.** ChromaDex Corporation renamed itself Niagen Bioscience, Inc. effective 2025-03-19 and moved from ticker CDXC to NAGE (FY2025 10-K; press release); one `LegalEntity` node, two `OrganizationSnapshot` states, CIK 1386570 as `Identifier`. The near-homonym ChromaDex, Inc. is a different node linked by `PARENT_OF`.
3. **Control, equity and investment are three predicates.** `PARENT_OF` (control), `HOLDS_EQUITY_IN` (any stake), `INVESTED_IN` (having invested). Real case (2025 proxy): Pioneer Step Holdings holds 6,917,783 shares and nominates a director; it is not a parent. Candidate forbidden implication `[HOLDS_EQUITY_IN, PARENT_OF]`.
4. **Advising is not endorsing; board is not employment.** `ADVISES_ORGANIZATION` never yields `ENDORSES_PRODUCT` (V-007, V-112, V-422); `ENDORSES_PRODUCT` projects only an explicit `ENDORSES_PRODUCT` assertion. Candidate `[BOARD_MEMBER_OF, EMPLOYED_BY]` (proxy: Rubin is a director only; Fried is director and CEO).
5. **Role normalization rules.** R-ROLE-1: executive-officer titles (CEO, President, CFO, COO, CTO, CMO, CSO, "Chief … Officer") normalize to `EMPLOYED_BY` with `corporateRoleType`/`roleTitleVerbatim`. R-ROLE-2: board titles (Director, Chair, "Executive Chairman") normalize to `BOARD_MEMBER_OF` only; an executive qualifier on a board title is kept as `AFFILIATED_WITH` with the verbatim title because employment is not stated. R-ROLE-3: an untyped or unclear role ("scientific lead guy", "board observer", "nominated by") is `AFFILIATED_WITH` with the verbatim title; never guessed into a FINANCIAL_INTEREST member. R-ROLE-4: role edges are projected only from ACCEPTED assertions whose predicate equals the edge type (V-W01-02, V-W01-07).
6. **Time.** Every tie uses the frozen `asserted_edge` fields; a YEAR bound is stored as the first instant of the year, and "2011–2017" means validTo 2017-01-01 YEAR (ended at some instant in 2017). As-of answers are precision-aware: a date inside an uncertain period is **possibly** (Q-W01-01; W01-SR-04). The 0.2.0 example stored validTo 2018-01-01 for the same text; W01 records the correction as an `EXTRACTION_FIX` supersession (W01-SR-05).
7. **Facility absorbs PhysicalLocation (CL-015 / T-004: merge).** A Facility is an identified physical site; operators change (`OPERATES_FACILITY`, asserted, time-bounded); the role a site plays for an operator (headquarters) is an edge qualifier (`facilityRole`), not a site property. REMOTE/VIRTUAL are not facilities. A label's address (21 CFR 101.5(e)) is never assumed to be the manufacturing site. Laboratories: CLIA certifies each laboratory location (42 CFR 493.35(a)) with mobile and campus exceptions, so a laboratory unit (`TestingLaboratory`, W12) and its sites (`Facility`) stay distinct (W01-SR-18).
8. **OrganizationSnapshot attaches by `HAS_STATE`, not `HAS_SNAPSHOT`.** `HAS_SNAPSHOT` is the provenance Source→SourceSnapshot edge; one type, one meaning (W01-SR-03). Role-implying flags (`isManufacturer`, `isInvestor`, `isProviderOrganization`, `isResearchOrganization`) are retired (INV-009).
9. **People are public actors only.** Birth date and place and death date are retired (no CQ; personal data). Social URLs become `Identifier`s; `LINKS_TO` becomes a `ResolutionHypothesis`.
10. **CohortParticipant is a pseudonymous actor issued by a public source.** Labels `CohortParticipant, PseudonymousActor, Entity`; identity is an issuer-scoped `Identifier` (scheme PARTICIPANT_TOKEN); no relationship of any kind to a `Person` (live `HAS_PARTICIPANT_TOKEN` retired as re-identification); explicit `privacyClass` (W01-SR-11, CL-018).
11. **Organizations keep few node fields.** Identity and classification (`name`, `displayName`, `organizationType`, `jurisdiction`), plus `legalName`/`canonicalTicker` as current display projections required by the retained `OrganizationName` fulltext index (D-015). All other time-varying live fields move to `OrganizationSnapshot`.
12. **Live edges are re-expressed, not copied.** Live role edges carry no assertion; migration creates PROPOSED assertions (reviewer MIGRATION) and projects nothing until a capture review accepts them.

## 4. Disposition of every live and catalog element in scope

Full field-level map: `migration-map.yaml` (171 entries). Type-level summary:

| Element | Origin | Disposition | Final |
|---|---|---|---|
| `Organization` | live + catalog | keep, refine (state fields moved, role flags retired) | `Organization` `["Organization","Entity"]` |
| `LegalEntity` | catalog | keep (first projection) | `["LegalEntity","Organization","Entity"]`, token `org` |
| `ConsumerBrand` | catalog | keep (first projection) | `["ConsumerBrand","Entity"]` |
| `Facility` | catalog | keep; absorbs `PhysicalLocation` | `["Facility","Entity"]` |
| `PhysicalLocation` | live, unowned | **merge** into `Facility` (CL-015) | relabel |
| `OrganizationSnapshot` | live seam | keep, refine (VersionedState, `HAS_STATE`) | `["OrganizationSnapshot","VersionedState"]` |
| `Person` | live + catalog | keep, refine (personal fields retired) | `["Person","Entity"]` |
| `PseudonymousActor`, `AnonymousActor` | live + catalog | keep | `[...,"Entity"]` |
| `CohortParticipant` | live seam | keep, restrict; specialize `PseudonymousActor` | `["CohortParticipant","PseudonymousActor","Entity"]` |
| `RoleMetadata`, `OwnershipMetadata`, `TemporalMetadata` (on `HAS_CEO`, `HAS_LOCATION`) | live | rename to `RoleEdgeProperties`, `OwnershipEdgeProperties`, `FacilityEdgeProperties` (embed frozen `AssertedEdgeProperties`) | |
| `RoleType`, `CorporateRoleType`, `SeniorityLevel`, `OrganizationType`, `FundingStage`, `EmployeeCountBand`, `LocationType` | live | keep (RoleType + HOST, CO_HOST, GUEST per catalog) | |
| `CompensationKind` | catalog comment | keep (new enum carrying the catalog values) | |
| `RoleHolderTarget` | new | union Person \| Organization for inverse role fields | |

Live role edges on `Organization` and `Person`:

| Live edge | Disposition | Final |
|---|---|---|
| `HOLDS_ROLE_AT` | **split** by roleType (R-ROLE-1..3) | typed edges; type retired |
| `AFFILIATED_WITH` | keep (asserted; not FINANCIAL_INTEREST) | `AFFILIATED_WITH` + `RoleEdgeProperties` |
| `ADVISES` | rename | `ADVISES_ORGANIZATION` |
| `EMPLOYS` | rename, reverse | `EMPLOYED_BY` |
| `HAS_BOARD_MEMBER` | rename, reverse (observer → `AFFILIATED_WITH`) | `BOARD_MEMBER_OF` |
| `FOUNDED_BY` | rename, reverse | `FOUNDED_ORGANIZATION` |
| `HAS_CEO` | merge | `EMPLOYED_BY {corporateRoleType: CEO}` |
| `CONTROLS` | **split** by stated control | `PARENT_OF` or `HOLDS_EQUITY_IN` |
| `MANUFACTURES` | rename | `MANUFACTURES_PRODUCT` |
| `CONTRACTS_MANUFACTURING` | **split** by target | `CONTRACT_MANUFACTURES_FOR` / `MANUFACTURES_PRODUCT` / W11 review |
| `HAS_LOCATION` | rename | `OPERATES_FACILITY` + `facilityRole` |
| `OFFERS`, `LISTS` | hand to W15 | (W01 advises MARKETS_PRODUCT for brand owners) |
| `SPONSORS` | hand to W21/W18 | `SPONSORS_CONTENT` / conference sponsorship |
| `EXHIBITS_AT`, `SPEAKS_AT`, `ATTENDS` | hand to W18 | field slots |
| `OPERATES_CHANNEL`, `SERVES_ON_CHANNEL`, `APPEARS_IN`, `RECOMMENDS`, `AUTHORS`, `REPORTS`, `ON_PLATFORM` | hand to W21 | field slots |
| `RECORDS`, `POSTS_RESULT` | hand to W16 | field slots (public persons only) |
| `DEVELOPS_PLATFORM`, `USES_PLATFORM`, `USES` | hand to W08 | field slots |
| `PERFORMS_PROCESS`, `HOSTS_PROCESS` | hand to W11 | field slots |
| `OFFERS_PROCEDURE`, `DEVELOPS_TREATMENT`, `OFFERS_TREATMENT` | hand to W06 | |
| `WORKS_ON_CONDITION` | retire (W01-SR-12) | literal `DEVELOPS_PRODUCT_CLASS` or W06 |
| `LINKS_TO` | retire | `ResolutionHypothesis` |
| `HAS_PARTICIPANT_TOKEN` | retire (privacy) | none |
| `HOSTS_PRODUCT` | retire (W01-SR-14) | routed review |
| `HAS_SNAPSHOT` (org) | rename | `HAS_STATE` |

Catalog `organizations.assertedPredicates` not projected as edges by W01 (assertion-only in 0.3): `SUBSIDIARY_OF` (canonicalized to `PARENT_OF`), `OWNS_PRODUCT`, `LABELS_PRODUCT`, `OWNS_SPECIFICATION`, `OPERATES_LABORATORY`, `OPERATES_CERTIFICATION_PROGRAM`, `DEVELOPS_PRODUCT_CLASS`, `CLAIMS_CGMP_COMPLIANCE`, `CHARACTERIZES_REGULATORY_*` (W13 consumer). Projected by other owners: `SPONSORS_CONTENT`, `RECOMMENDS` (W21); `AFFILIATE_FOR_OFFER`, `LISTS_OFFER`, `FULFILLS_OFFER`, `HOSTS_LISTING`, `SELLER_OF_RECORD_FOR`, `SELLS_PRODUCT` (W15); `OWNS_TRADEMARK`, `ASSIGNED_PATENT`, `LICENSES_PATENT` (W14); study roles (W09, proposed).

## 5. Alternatives considered (rejected)

| Alternative | Why rejected | Evidence |
|---|---|---|
| One generic `HAS_ROLE {roleType}` edge (live `HOLDS_ROLE_AT`) | collapses investor/equity/control and makes forbidden implications unenforceable by type | round 0006 D6; V-112 needs distinct types; negative N2/N3 |
| `ConsumerBrand` as an Organization specialization | a brand cannot hold a board seat or equity; V-434 and V-W01-01 would be blind | negative N4; TRU NIAGEN mark/brand/group case |
| Keep `PhysicalLocation` beside `Facility` | two identities for one site; establishment registration (INV-304) would split | CL-015; 21 CFR 101.5(e); 42 CFR 493.35 |
| `Facility` = laboratory | mobile labs have no fixed site; campus labs share one certificate | 42 CFR 493.35(b) |
| Keep all live Organization state fields on the identity node | one correction rewrites identity; no history (round 0007 §12) | ChromaDex → Niagen rename, CDXC → NAGE |
| Separate `PARENT_OF` and `SUBSIDIARY_OF` edge types | two edges for one fact; queries must union | catalog lists both as predicates only |
| Separate officer predicate (`OFFICER_OF`) | no CQ needs it beyond `EMPLOYED_BY` + `corporateRoleType` | proxy cases fit R-ROLE-1/2 |
| `CohortParticipant` linked to `Person` as a hypothesis | re-identification inside the shared graph | contract A9; V-W01-05 |

## 6. Smallest recommended model

Eight node types (seven identities, one state), eighteen projected edge types, three relationship-property types (each embedding the frozen asserted-edge fields), eight enums (one new carrying catalog values), one union. No new kernel field is required for the fragment; two kernel requests (W01-SR-07 witness date, W01-SR-22 n-ary qualifier) are recorded with workarounds already used in the fixtures.
