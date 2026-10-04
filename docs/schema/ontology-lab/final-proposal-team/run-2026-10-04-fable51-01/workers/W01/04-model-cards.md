# W01 model cards

Conventions: privacy class PUBLIC unless stated; "kind" = asserted / observed / calculated / inferred / operational; maturity per catalog (`PROVISIONAL` for catalog elements first projected here, `CANDIDATE` for new). Kernel fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`, archetype field) follow contract B2 and are not repeated per card.

## 1. Node cards

### Organization
- **Meaning**: enduring identity of an organized body (company, corporate group, division, university, institute, fund, clinic operator, agency). Specialized by `LegalEntity` (W01), `RegulatoryAgency` (W13), `TestingLaboratory` (W12).
- **Not**: a brand, a site, a trademark, a seller display account, a source.
- **Archetype / labels / token**: Entity; `["Organization","Entity"]`; `org`.
- **Properties**: `entityType: String!` (operational, "Organization"); `displayName: String` (observed, display); `legalName: String` (derived display projection of the current `OrganizationSnapshot`; non-null only with `LegalEntity`, V-W01-11); `canonicalTicker: String` (derived display projection; authoritative `Identifier` scheme TICKER); `currentAsOf: DateTime` (operational: materialization instant); `organizationType: OrganizationType` (asserted classification; never a role, INV-009); `jurisdiction: String` (observed; ISO 3166 or registry code); SearchIndexable fields + `searchEmbedding` (derived, INV-107).
- **Edges**: see section 3 (holder side and counterpart side), `HAS_STATE` → OrganizationSnapshot, `HAS_IDENTIFIER` → Identifier.
- **Identity keys**: `uid`; external identity only through `Identifier` (SEC CIK, LEI, company registry number, DUNS) within scheme and issuer. Aliases: names and former names are `OrganizationSnapshot.legalName`/`displayName` values; merges publish a redirect through `EquivalenceAssessment` (W00).
- **Temporal**: node fields immutable except display projections refreshed with `currentAsOf`.
- **Sources**: S1, S2, S3 (`03-source-manifest.md`). **Maturity**: PROVISIONAL.

### LegalEntity
- **Meaning**: an organization registered as one legal person in a jurisdiction's registry. Rename keeps identity (S2: ChromaDex Corporation → Niagen Bioscience, Inc., effective 2025-03-19).
- **Not**: a brand (V-433); a group of companies; a d/b/a name.
- **Labels / token**: `["LegalEntity","Organization","Entity"]`; `org`.
- **Properties**: Organization's node properties minus search fields, plus `registrationId: String` (display mirror of the primary formation-registry Identifier), `incorporatedOn: Date`, `dissolvedOn: Date` (observed, registry-stated dates; null = unknown, never "still active").
- **Edges**: `HAS_STATE`, `HAS_IDENTIFIER`, `PARENT_OF` (both directions), `OWNS_BRAND`, `OPERATES_FACILITY`. Role traversal uses the `Organization` GraphQL type (same nodes).
- **Identity keys**: `uid`; formation-registry `Identifier` (scheme, issuer, value); never legal name. **Maturity**: PROVISIONAL.

### ConsumerBrand
- **Meaning**: name under which products or services are presented to consumers.
- **Not**: a legal entity, an organization, a trademark registration (W14), a product.
- **Labels / token**: `["ConsumerBrand","Entity"]`; `brand`.
- **Properties**: kernel only (`name` presentation).
- **Edges**: `OWNS_BRAND` (in), `HAS_IDENTIFIER`; slots for `SPONSORS_CONTENT` (W21) and `MARKETED_UNDER_MARK` context (W14).
- **Rules**: never target of person-to-company FINANCIAL_INTEREST edges (V-W01-01); never labelled Organization/LegalEntity (V-433, V-W01-03). **Maturity**: PROVISIONAL.

### Facility
- **Meaning**: identified physical site (plant, lab site, clinic, office, warehouse, campus). Absorbs live `PhysicalLocation`.
- **Not**: its operator; a laboratory organization; a label's place of business; a market region; REMOTE/VIRTUAL.
- **Labels / token**: `["Facility","Entity"]`; `facility`.
- **Properties**: `facilityKind: LocationType` (asserted; not REMOTE/VIRTUAL); `addressText`, `city`, `region`, `country` (ISO 3166-1 alpha-2), `postalCode` (observed); `latitude`, `longitude` (observed, WGS84 decimal degrees).
- **Edges**: `OPERATES_FACILITY` (in), `HAS_IDENTIFIER` (FEI, DUNS, site-scoped CLIA numbers); slots `STATUS_OF` (W13), `HAS_CAPABILITY_STATE`, `HOSTS_PROCESS` (W11), `COVERS` (W12).
- **Identity keys**: `uid`; site identifiers; address is evidence for matching, never identity alone. **Maturity**: PROVISIONAL.

### OrganizationSnapshot
- **Meaning**: one frozen, source-attributed profile state of an organization (legal name, ticker, stage, size, sector, summaries).
- **Not**: identity; evidence (support goes through `assertionUids`).
- **Archetype / labels / token**: VersionedState; `["OrganizationSnapshot","VersionedState"]`; `org-snapshot` (requested, W01-SR-01).
- **Properties**: `stateType: String!` (operational; live `snapshotType`), `payloadHash: String!` (calculated, `sha256:`), `effectiveFrom`/`effectiveTo` (observed, source-stated payload bounds), TemporalSnapshot cache `validFrom`/`validTo`/`recordedFrom`/`recordedTo` (operational, first episode only), `assertionUids: [String!]` (operational), payload (observed, frozen): `legalName`, `displayName`, `canonicalTicker` (new), `organizationType`, `active`, `foundedYear`, `fundingStage`, `totalFundingUsd` (USD), `employeeCountMin/Max/Estimate` (Int, persons), `employeeCountBand`, `employeeCountRaw`, `revenueModel`, `valueChainStages`, `sector`, `websiteUrl`, `headquarters`, `headquartersSummary`, `operatingSummary`, `marketCapUsd` (USD), `pipelineSummary`, `competitivePositionSummary`, `isPublicCompany`; search fields.
- **Edges**: `HAS_STATE` (in, StateEpisodeProperties; bitemporal_attachment; NONEXCLUSIVE by default, several partial-state kinds may overlap).
- **Temporal**: payload immutable; corrections and endings are new episodes (TM-R2, TM-R3). **Maturity**: PROVISIONAL.

### Person
- **Meaning**: natural person acting publicly in sourced material.
- **Not**: a BellLabs user; a software Agent; a handle.
- **Labels / token**: `["Person","Entity"]`; `person`.
- **Properties**: `title`, `bio` (display only), `orcid` (display mirror of ORCID Identifier); search fields.
- **Edges**: holder side of all person roles (section 3), `ENDORSES_PRODUCT`, `HAS_IDENTIFIER`; slots for W21/W18/W16/W20/W15/W09 edges.
- **Privacy**: PUBLIC; no birth/death data. **Maturity**: PROVISIONAL.

### PseudonymousActor / AnonymousActor
- **Meaning**: an asserter known only by a platform handle / known only by a class.
- **Labels / token**: `["PseudonymousActor","Entity"]` `pseudonymous-actor`; `["AnonymousActor","Entity"]` `anonymous-actor`.
- **Properties**: `handle` (display mirror of the platform-scoped Identifier); `anonymityClass` (free text).
- **Edges**: `HAS_IDENTIFIER`; slots `ON_PLATFORM`, `AUTHORS` (W21). Link to a Person: `ResolutionHypothesis` only. **Maturity**: PROVISIONAL.

### CohortParticipant
- **Meaning**: participant known only by a token printed by a public source; specialization of PseudonymousActor.
- **Labels / token**: `["CohortParticipant","PseudonymousActor","Entity"]`; `cohort-participant` (requested).
- **Properties**: `participantToken` (display mirror); `privacyClass` mandatory (V-W01-05).
- **Edges**: `HAS_IDENTIFIER` → `Identifier {scheme: PARTICIPANT_TOKEN, issuer: <study/dataset uid>}` (one_or_more); slot `REPORTS` (W21). No relationship to Person.
- **Maturity**: CANDIDATE (privacy seam open until W23 rules CL-018).

## 2. Relationship-property type cards

| Type | Fields (beyond the frozen `AssertedEdgeProperties` fields: relationshipUid!, assertionUid!, validFrom, validTo, validFromPrecision, validToPrecision, validFromBasis!, validToBasis!, recordedFrom!, recordedTo, mongoResearchRunId) | Kind | Rules |
|---|---|---|---|
| `RoleEdgeProperties` | `roleType: RoleType`, `roleTitleVerbatim: String`, `corporateRoleType: CorporateRoleType`, `seniorityLevel: SeniorityLevel`, `compensationKind: CompensationKind` | asserted (copied from the Assertion) + normalized qualifiers (inferred by extraction rule R-ROLE-1..3) | immutable after commit except one write of `recordedTo`; `compensationKind` only on RECEIVES_COMPENSATION_FROM (V-W01-10); BOARD_OBSERVER never on BOARD_MEMBER_OF (V-W01-12) |
| `OwnershipEdgeProperties` | `stakePercent: Float` (percent 0–100, only when stated), `stakeClassVerbatim: String`, `roleTitleVerbatim: String` | asserted | a computed percentage is a CALCULATED assertion, never written silently here |
| `FacilityEdgeProperties` | `facilityRole: LocationType`, `roleTitleVerbatim: String` | asserted | headquarters is a role of a site for an operator |

All three: one edge per recorded-time episode; valid bounds/precisions/bases equal the authorizing Assertion's (V-505 analogue V-W01-02); projected only from ACCEPTED assertions (V-W01-07).

## 3. Relationship cards (all `class: asserted`, profile `asserted_edge`, cardinality many, temporalCardinality NONEXCLUSIVE unless stated)

| Type | Domain → Range | Props | FINANCIAL_INTEREST | Forbidden implications (as premise) | Notes |
|---|---|---|---|---|---|
| `BOARD_MEMBER_OF` | Person → Organization | Role | yes | [BOARD_MEMBER_OF, EMPLOYED_BY] (candidate) | replaces HAS_BOARD_MEMBER (reversed); observers excluded |
| `EMPLOYED_BY` | Person → Organization | Role | yes | — | replaces EMPLOYS, HAS_CEO; officer titles via R-ROLE-1 |
| `ADVISES_ORGANIZATION` | Person\|Organization → Organization | Role | yes | [ADVISES_ORGANIZATION, ENDORSES_PRODUCT] | catalog exclusivity NONEXCLUSIVE |
| `FOUNDED_ORGANIZATION` | Person\|Organization → Organization | Role | yes | — | replaces FOUNDED_BY |
| `INVESTED_IN` | Person\|Organization → Organization | Ownership | yes | [INVESTED_IN, HOLDS_EQUITY_IN] | |
| `HOLDS_EQUITY_IN` | Person\|Organization → Organization | Ownership | yes | [HOLDS_EQUITY_IN, PARENT_OF] (candidate) | group codes never pushed down (V-434) |
| `HAS_IP_INTEREST_IN` | Person\|Organization → Organization | Role | yes | — | patent-level edges are W14's |
| `RECEIVES_COMPENSATION_FROM` | Person\|Organization → Organization | Role (+compensationKind) | yes | — | brand-only statements stay assertion-only |
| `AFFILIATED_WITH` | Person\|Organization → Organization | Role | no | [AUTHOR_AFFILIATED_WITH, FUNDS_STUDY] | unnormalized ties, group membership, nominee-of |
| `PARENT_OF` | Organization → Organization | Ownership | no | — | control; SUBSIDIARY_OF canonicalized; acyclic (V-W01-06) |
| `OWNS_BRAND` | Organization → ConsumerBrand | AssertedEdgeProperties | no | — | juxtaposition stays PROPOSED |
| `OPERATES_FACILITY` | Organization → Facility | Facility | no | — | replaces HAS_LOCATION |
| `MARKETS_PRODUCT` | Organization → Product | Role | no | — | catalog NONEXCLUSIVE |
| `MANUFACTURES_PRODUCT` | Organization → Product | Role | no | conclusion of [DISTRIBUTES_PRODUCT, MANUFACTURES_PRODUCT], [SUPPLIES_INGREDIENT_MATERIAL, MANUFACTURES_PRODUCT] | replaces MANUFACTURES |
| `DISTRIBUTES_PRODUCT` | Organization → Product | Role | no | [DISTRIBUTES_PRODUCT, MANUFACTURES_PRODUCT] | "Distributed by" (21 CFR 101.5(c)) |
| `CONTRACT_MANUFACTURES_FOR` | Organization → Organization | Role | no | — | manufacturer → client |
| `SUPPLIES_INGREDIENT_MATERIAL` | Organization → IngredientMaterial | Role | no | [SUPPLIES_INGREDIENT_MATERIAL, MANUFACTURES_PRODUCT]; conclusion of [PROVIDES_INVESTIGATIONAL_PRODUCT, SUPPLIES_INGREDIENT_MATERIAL] | V-220 |
| `ENDORSES_PRODUCT` | Person\|Organization → Product | AssertedEdgeProperties | no | conclusion of advisory/sponsorship/FINANCIAL_INTEREST pairs | only from an explicit ENDORSES_PRODUCT assertion (V-007, V-422) |

FINANCIAL_INTEREST family (catalog, unchanged): `SPONSORS_CONTENT` (W21 writer), `AFFILIATE_FOR_OFFER` (W15 writer), `INVESTED_IN`, `HOLDS_EQUITY_IN`, `BOARD_MEMBER_OF`, `ADVISES_ORGANIZATION`, `EMPLOYED_BY`, `FOUNDED_ORGANIZATION`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM`. Rule: every member is asserted and time-bounded; membership never changes a truth verdict (INV-405, V-424). The family is expressed in Cypher as a type list (operations file) because GraphQL has no predicate families.

Assertion-only predicates (registered, not projected in 0.3): `SUBSIDIARY_OF` (→ PARENT_OF), `OWNS_PRODUCT`, `LABELS_PRODUCT`, `OWNS_SPECIFICATION`, `OPERATES_LABORATORY`, `OPERATES_CERTIFICATION_PROGRAM`, `DEVELOPS_PRODUCT_CLASS` (literal), `CLAIMS_CGMP_COMPLIANCE` (literal claim).

## 4. Enum cards (W01 owner; values frozen)

| Enum | Values | Used by | Notes |
|---|---|---|---|
| `OrganizationType` | 38 live values | Organization, LegalEntity, OrganizationSnapshot | classification only; CORPORATE_GROUP requested (W01-SR-09) |
| `FundingStage` | 18 live values | OrganizationSnapshot | state |
| `EmployeeCountBand` | 10 live values | OrganizationSnapshot | state |
| `LocationType` | 22 live values | Facility.facilityKind, FacilityEdgeProperties.facilityRole | REMOTE/VIRTUAL never on Facility |
| `RoleType` | 29 live + HOST, CO_HOST, GUEST | RoleEdgeProperties; W21 APPEARS_IN | refinement, never the predicate |
| `CorporateRoleType` | 23 live values | RoleEdgeProperties | governance titles |
| `SeniorityLevel` | 10 live values | RoleEdgeProperties | |
| `CompensationKind` | PAYMENT, FREE_PRODUCT, COMMISSION, OTHER | RoleEdgeProperties | catalog qualifier values |

Union `RoleHolderTarget = Person | Organization` (W01): inverse role fields on Organization.

## 5. Derived inputs and rules

| Rule | Inputs | Output |
|---|---|---|
| R-ROLE-1..4 (normalization and projection) | Assertion `predicate`, `roleTitleVerbatim`, status | projected edge type and qualifiers |
| Precision-aware validity ladder (Q-W01-01) | edge bounds, precisions, witness = coalesce(snapshot.publishedAt, snapshot.observedAt) | KNOWN / POSSIBLE_* / KNOWN_NOT_VALID |
| Current display projections | latest currently recorded `HAS_STATE` episode valid now | `Organization.legalName`, `.canonicalTicker`, `.currentAsOf` |
