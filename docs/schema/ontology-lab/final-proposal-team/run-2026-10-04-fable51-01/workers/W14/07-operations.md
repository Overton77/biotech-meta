# W14 operations

Target: Neo4j 5.26 Community (tested on 5.26.31) and `@neo4j/graphql` 7.6.3. Enterprise behaviour is unverified. `operations.cypher` contains baseline statements only. On a fresh 5.26.31 Community instance all **29/29** succeeded, and all three fixture files then loaded under the constraints. A duplicate `Trademark.officeKey` 'US:85932490' was rejected by `w14_trademark_office_key`, and the fulltext query `PatentClaimText` for "nicotinamide" returned claims 1 and 2 of US 8,197,807 (claim 3 does not contain the word). Details are in `fixtures/w14-run-log.txt`.

## 1. Uniqueness and indexes (stored property names; W14 types have no aliases)

| Need | Statement (operations.cypher) | Edition |
|---|---|---|
| uid unique per W14 label (7) | `w14_*_uid` | Community |
| live `id` unique per label (7) | `w14_*_id` | Community |
| One application, grant or mark per office number | `w14_patent_application_office_key`, `w14_granted_patent_office_key`, `w14_trademark_office_key` | Community |
| One family per (definition, public id) | composite `w14_patent_family_key`. Rows with a null `familyIdentifier` are not constrained, which is the intended behaviour for SOURCE_DISPLAYED and CURATED families | Community |
| Claim natural key (parent officeKey, claimNumber) | **application validation** (it spans an edge). Reported by V-W14-06 together with a parent-uniqueness check | n/a |
| As-of retrieval | range indexes on jurisdiction and date, `claimTextHash`, `markText`+`jurisdiction`, `statusKind`+`jurisdiction`; relationship indexes on `relationshipUid` (MERGE key of asserted episodes) and `IP_STATUS_OF(validFrom, validTo)` | Community |
| Claim-text search | `FULLTEXT PatentClaimText ON claimText` (= SDL `@fulltext`, query `searchPatentClaims`) | Community |
| `Identifier (scheme, issuer, value)` uniqueness | W00's operations file (not repeated) | Community |
| Existence / type constraints (`officeKey`, `familyDefinition`, `statusKind`, `claimTextHash`, `payloadHash` NOT NULL; `exclusive` BOOLEAN; `claimNumber` INTEGER) | **not issued**: Enterprise-only. The ingestion service enforces them in the write transaction, and V-W14-09/-10 audit them | Enterprise only |

No vector index is proposed. Claim text is retrieved by fulltext plus a curator `PATENT_CLAIMS` assertion; semantic similarity is not a coverage signal (D-014).

## 2. Retrieval patterns

1. **As-of status** (CQ-IP-C01, C04): `(IpRightStatus)-[r:IP_STATUS_OF]->(right)` with `r.recordedTo IS NULL` (current belief), or `r.recordedFrom <= $R < coalesce(r.recordedTo, +∞)` (historical belief), and `r.validFrom <= $D < r.validTo`, where a null `validTo` means unknown and is shown as such. Enforceability = in force ∧ ¬terminal ∧ ¬claim-invalid at D. Rows are returned with flags, never filtered silently (Q-01).
2. **License coverage** (C02): `LICENSE_COVERS` target = grant, or a claim of the grant, or a family **only when the edge targets the family**. Every edge is checked against its assertion (`EXISTS {(:Assertion {uid: cov.assertionUid, predicate:'LICENSE_COVERS'})}`).
3. **Parties**: `LICENSES_PATENT` and `GRANTS_PATENT_LICENSE` with valid and recorded filters. The assignee is never used as the licensor.
4. **Mark chain** (C04): BrandedIngredientMaterial → `MARKETED_UNDER_MARK` → Trademark ← `OWNS_TRADEMARK`, plus status. Supplier and marketer roles come from their own W01 predicates.
5. **Family view** (C05): one PatentFamily per definition. Cross-definition comparison goes through `EquivalenceAssessment` (W00).

## 3. Application validation and transactions (preventive, not only audit)

| Rule | Enforcement in the write transaction | Audit |
|---|---|---|
| Asserted edge written together with its Assertion (same tx). Predicate, subject and object equal the edge; bounds, precisions and bases copied | ingestion service | V-W14-03, kernel V-101/V-106/V-505 |
| Endpoint types | ingestion service + SDL ranges | V-W14-04 |
| `LICENSE_COVERS` never generated from family membership or `coverageRuleText` | the projection job only projects LICENSE_COVERS assertions | V-W14-05 |
| Claim has exactly one parent; claim text hashed with NFC-WS1 at capture | capture activity | V-W14-06 |
| `CLAIM_*` statuses only on PatentClaim; no claim status derived from a patent-level status | ingestion service | V-W14-07 |
| Office identifiers scoped to the right's jurisdiction; a related property gets its own Trademark/right | resolution activity | V-W14-08, kernel identity checks |
| No `status` property on IP nodes | schema (no field in SDL) + service | V-W14-09 |
| officeKey normalization `<JUR>:<A-Z0-9>` computed by the service, never client-supplied | service | V-W14-10 + uniqueness constraint |
| No study role, efficacy or supply role derived from IP assertions | derivation rules are registered; their inputs are checked against forbidden pairs before commit | V-W14-01, -02, -12; kernel V-112 |
| Supersession only between Assertions; VALIDITY_BOUNDED keeps object and start | service | kernel V-507, V-507b |
| A definite in-force/terminal overlap is rejected; a possible overlap (unknown bounds) is queued for review | service (TM-R5 style) | V-W14-14 |

**Concurrency.** Episodes are MERGEd on `relationshipUid` (an indexed property). Two writers asserting the same status for one right in parallel produce two episodes with different `relationshipUid` and two Assertions. Each is legitimate (two asserters), and the later reviewer adjudicates. Closing an episode (`recordedTo` from null) must happen in a transaction that rechecks `recordedTo IS NULL` (an optimistic check). Ingestion that writes a node with an office key relies on the uniqueness constraint for collision safety: a failed MERGE because of a constraint violation is a resolution case, not a retry.

## 4. Idempotence, lifecycle, migration, overhead

- **Idempotence:** every node is MERGEd on `uid`, and every asserted edge on `relationshipUid`. Fixture files are therefore designed to rerun without duplicates. A rerun was **not separately measured**; the only reload observed was onto a fresh database under the uniqueness constraints.
- **Lifecycle:** InformationArtifacts are immutable. A re-capture with different text is a new artifact (for example a certificate of correction) or a new snapshot with REANCHORS. A status change is a new episode. A license amendment is a new PatentLicense whose old assertions are bounded by VALIDITY_BOUNDED.
- **Migration / compatibility:** no live data exists. The catalog `status` property on three types is removed before first write. GraphQL exposes the new types only (see migration-map.yaml).
- **Ingestion overhead:** per granted patent with *k* claims and *s* statuses: 1 + k artifact nodes, s state nodes, s + 2 (identifiers and grant link) assertions with their projected edges, plus provenance (snapshot and locators shared per page). The core fixture: 153 nodes in total in the database after all three files, including provenance and kernel nodes.
- **Edition notes:** Community has a single database, so no `CREATE DATABASE` isolation is available; test isolation is a fresh in-process instance. Relationship property-existence constraints (`recordedFrom` NOT NULL on asserted edges) are Enterprise-only and are service-enforced.
