# W01 operations

No runtime implementation is proposed; `operations.cypher` is the statement list Fable can merge into `final_biotech_schema_operations.cypher`.

## 1. Uniqueness and indexes (stored property names)

| Need | Statement (operations.cypher) | Edition | Executed |
|---|---|---|---|
| uid and live id unique per primary label: Organization (covers LegalEntity, RegulatoryAgency, TestingLaboratory), ConsumerBrand, Facility, OrganizationSnapshot, Person, PseudonymousActor (covers CohortParticipant), AnonymousActor | 14 `REQUIRE n.<prop> IS UNIQUE` | Community | yes; `w01_organization_uid` was skipped by `IF NOT EXISTS` because `constraints.cypher` already defines `live_organization_uid` (same schema) |
| relationshipUid unique per W01 asserted edge type (18 types) | `FOR ()-[r:T]-() REQUIRE r.relationshipUid IS UNIQUE` | Community (Neo4j ≥ 5.7) | yes, 18/18 |
| as-of filters | composite range indexes `(recordedFrom, validFrom)` on BOARD_MEMBER_OF, EMPLOYED_BY, ADVISES_ORGANIZATION, HOLDS_EQUITY_IN | Community | yes |
| assertion lookup from edge | range index on `assertionUid` for AFFILIATED_WITH, PARENT_OF (extend to all types if V-W01-02 is slow) | Community | yes |
| classification filters | `Organization.organizationType`, `Facility.facilityKind` | Community | yes |
| live fulltext (D-015) | `OrganizationName` (Organization: name, searchText, legalName, displayName, canonicalTicker), `PersonSearch` (Person: name, description, bio, title, searchText), `OrganizationSnapshotSearch` (OrganizationSnapshot: name, description, sector, searchText) | Community | yes, ONLINE; probe `queryNodes('OrganizationName','ChromaDex')` returned only `hu:org:chromadex-inc` |
| existence / type constraints (assertionUid, recordedFrom, privacyClass on CohortParticipant, entityType) | commented block | **Enterprise only** (unverified; Community rejects, 00-baseline) | no |

Result on embedded Neo4j 5.26.31 Community: constraints.cypher (45/57 as baseline) + operations.cypher **43/43 OK**, then fixtures 01–06 and all queries OK with every constraint and index in place (31 W01 constraints, 39 range + 3 fulltext indexes ONLINE).

Search finding (ingestion rule, no schema change): the fulltext probe shows that a former legal name lives only on `OrganizationSnapshot` and `OrganizationSnapshotSearch` does not index `legalName`, so "ChromaDex" finds the subsidiary but not the renamed parent. Rule: `Organization.searchText` is derived from every `legalName`/`displayName` of its currently recorded states (searchFields names them; INV-107), so former names stay findable without becoming identity. A search hit is a candidate only (QS-8).

## 2. Retrieval patterns

- Role as-of (CQ-AX-18, CQ-CL-05): Q-W01-01 ladder; filter `recordedFrom <= R < recordedTo`, then classify V with precision lengths (P1Y, P3M, P1M, P1D, P10Y) and witness = coalesce(snapshot.publishedAt, snapshot.observedAt).
- Neighbourhood (CQ-EC-01): one or two hops over the FINANCIAL_INTEREST list + `AFFILIATED_WITH` + `PARENT_OF`, never over names; the FINANCIAL_INTEREST list is a parameter generated from the catalog family.
- Legal name as of (CQ-EC-C01): `(:LegalEntity)-[h:HAS_STATE]->(:OrganizationSnapshot)` with the episode filter (Q-W01-04).
- Who makes what (CQ-MF-01): role edges to Product plus `OPERATES_FACILITY {facilityRole: MANUFACTURING_SITE}` (Q-W01-07); never from `organizationType` or label addresses.
- GraphQL: role traversal through `Organization`/`Person` fields; edge properties via connections (`boardMemberOfConnection { edges { properties { validFrom validFromPrecision } } }`); LegalEntity-specific fields through the `LegalEntity` type.

## 3. Application validation (service-enforced; Neo4j cannot express)

1. Projection rule R-ROLE-4: write an asserted edge only after the assertion is ACCEPTED; copy bounds, precisions, bases and `roleTitleVerbatim`; `recordedFrom` = commit time ≥ assertion `recordedAt` (V-504 analogue); reject if predicate ≠ edge type (V-W01-02) or premise is a forbidden implication (V-112 with W01 pairs).
2. Range checks: person-to-company role targets carry the Organization label and not ConsumerBrand (V-W01-01); `PARENT_OF` acyclic (V-W01-06); Facility kind not REMOTE/VIRTUAL (V-W01-04).
3. Normalization R-ROLE-1..3 runs in extraction; the normalized edge type is a resolution step recorded on the extraction Activity (`methodVersion`), and the verbatim title is always kept.
4. CohortParticipant: refuse creation without `privacyClass` and without a public-source locator; refuse any relationship to Person (V-W01-05).
5. OrganizationSnapshot: compute `payloadHash` over the canonical payload; never update payload; one `HAS_STATE` episode per recorded-time episode; display projections on Organization refreshed in the same transaction with `currentAsOf`.

## 4. Transactions, concurrency, idempotence

- Writes are `MERGE` on `uid` for nodes and on `relationshipUid` for edges (unique constraints above make retries idempotent).
- Superseding an assertion (correction) is one transaction: set old `recordedTo` and status, create `SUPERSEDES`, close old edge `recordedTo`, create new assertion and edge (w01-01 pattern). Concurrent corrections of the same assertion are serialized by taking a write lock on the old assertion node first (`SET a._lock = true REMOVE a._lock` idiom or `CALL apoc.lock` if APOC is installed; not assumed).
- `Organization` display projections are last-writer-wins and carry `currentAsOf`; they are never read as history.

## 5. Migration (live → final)

Order: (1) backfill `uid` (`hu:org:`, `hu:person:`, `hu:facility:`, `hu:org-snapshot:` + live `id`) and archetype labels; (2) relabel `PhysicalLocation` → `Facility` (skip REMOTE/VIRTUAL; list them); (3) rename `snapshotType` → `stateType`, compute `payloadHash`, create one `HAS_STATE` episode per live snapshot node from its node-level time fields (bases UNKNOWN where null) and delete the `HAS_SNAPSHOT` edge; (4) for every live role edge (HOLDS_ROLE_AT, ADVISES, EMPLOYS, HAS_BOARD_MEMBER, FOUNDED_BY, HAS_CEO, CONTROLS, MANUFACTURES, CONTRACTS_MANUFACTURING, HAS_LOCATION, AFFILIATED_WITH) create an `Assertion` with the mapped predicate (migration-map), status PROPOSED, `extractionMethod: 'migration'`, valid bounds: precision cannot be recovered from a live DateTime (2017-01-01T00:00Z may mean the year 2017), so the bound is written null with basis UNKNOWN and the live value is kept in the assertion `description` for review; a MIGRATION adjudication is NOT a capture review, so nothing is projected; (5) delete live role edges after export; (6) move Organization state fields into a migration `OrganizationSnapshot` per organization (`stateType: 'LEGACY_PROFILE'`, episode bases UNKNOWN); (7) drop role-flag properties (V-W01-09 must return 0); (8) export and delete `HAS_PARTICIPANT_TOKEN` edges and CohortParticipant nodes not backed by a public source (W23 contract).

Compatibility: GraphQL fields `Organization.snapshots`, `.locations`, `.employs`, `.hasBoardMembers`, `.foundedBy`, `.hasCeos`, `.controls`, `.manufactures`, `.contractsManufacturing`, `Person.holdsRoleAt`, `.advises`, `.linksTo`, `.hasParticipantTokens`, `PhysicalLocation` queries, and personal Person fields disappear; replacements are listed in `migration-map.yaml`. `name` becomes nullable (D-013).

## 6. Ingestion overhead

Per role fact: 1 Assertion + 1 CAPTURE_FIDELITY Adjudication + ≥1 SourceLocator + 1 projected edge (4–5 writes versus 1 live edge). A proxy statement yields ~5–15 role facts; acceptable. The FINANCIAL_INTEREST type list and W01 implication pairs must be added to `validation-params.json` (W01-SR-06).
