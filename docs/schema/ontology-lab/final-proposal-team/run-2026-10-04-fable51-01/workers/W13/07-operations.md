# W13 operations recommendation

**Target:** Neo4j 5.26 Community, tested on embedded 5.26.31; `@neo4j/graphql` 7.6.3. Enterprise behaviour is unverified. The statements are in `operations.cypher` and were **run** in this session (`fixtures/run-results/final-ops.json`).

## 1. Uniqueness and indexes (stored property names)

| Statement group | Community 5.26.31 result |
|---|---|
| `uid` UNIQUE on RegulatoryAgency, RegulatoryPathway, RegulatoryPathwayVersion, RegulatoryStep, RegulatorySubmission, RegulatoryResponse, RegulatoryStatus, RegulatoryInspection | 8 ok |
| `id` UNIQUE on the same 8 labels | 8 ok |
| **Relationship** property uniqueness on `relationshipUid` for STATUS_OF, HAS_PATHWAY_VERSION, SUBMISSION_ABOUT, SUBMITTED_BY, INSPECTED_FACILITY | 5 ok (relationship uniqueness constraints are accepted on Community 5.26.31) |
| Range indexes: RegulatoryStatus(statusKind, jurisdiction), RegulatoryResponse(responseKind), RegulatorySubmission(identifier) and (submissionKind, jurisdiction), RegulatoryPathway(pathwayKind, jurisdiction), STATUS_OF(assertionUid), STATUS_OF(recordedTo, validTo), HAS_PATHWAY_VERSION(recordedTo, validTo), RegulatoryInspection(startedAt) | 9 ok |
| Enterprise companion: existence constraints on statusKind, jurisdiction, responseKind, STATUS_OF.assertionUid and recordedFrom; type constraint statusKind :: STRING | 6 rejected on Community, as expected. Run only on Enterprise. |

**Idempotence.** A second run of the file reported 30 ok and 6 errors again, so `IF NOT EXISTS` makes the statements idempotent. The constraints were created after the fixtures were loaded and accepted the existing data. The validation suite re-ran clean afterwards.

**Specialization labels.** `RegulatoryStatus.uid` uniqueness also covers `OrphanDesignation` and `DrugApproval`, because those nodes carry the `RegulatoryStatus` label. `RegulatoryAgency` nodes are additionally covered by W01's `Organization.uid` constraint. The two must agree: same uid space, token `org`.

**Fulltext and vector indexes.** None are proposed. Lookup by number goes through `RegulatorySubmission.identifier` (range index) and `Identifier` (W00). The live `ProductSearch` fulltext index keeps `primaryRegulatoryIdentifier` and `regulatoryAuthorizationId` as lookup hints only (D-015, W04). No retrieval justification exists for embeddings of regulatory records.

## 2. Retrieval patterns

The queries are in `fixtures/w13-cq-queries.cypher`.

| Pattern | Shape | Index used |
|---|---|---|
| Standing of a subject at (R, V) | subject by uid → incoming `STATUS_OF` filtered by recordedFrom/recordedTo and validFrom/validTo → status → response → submission | uid unique index; STATUS_OF(recordedTo, validTo) |
| "Is X approved?" | the above with `statusKind = 'APPROVAL'` and an approving response | RegulatoryStatus(statusKind, jurisdiction): PROFILE showed a count of 1 |
| Legal basis at (R, V) | pathway uid → `HAS_PATHWAY_VERSION` episodes | HAS_PATHWAY_VERSION(recordedTo, validTo) |
| Characterization audit | `Assertion{predicate}` → `HAS_SUBJECT` → RegulatoryResponse; current adjudication = no incoming SUPERSEDES | kernel Assertion(predicate) index (W00) |
| Jurisdiction partition | status by (statusKind, jurisdiction) | composite range index |

## 3. Application validation (service-enforced; Neo4j cannot enforce these)

1. **Closed enums.** The GraphQL enums cover writes through the API. Cypher writes are checked after the fact by V-W13-02 and V-W13-03 (response kind within the pathway's list).
2. **Cardinalities:**
   - `STATUS_OF`: exactly one distinct subject and at most one current episode (V-333r);
   - `UNDER_PATHWAY`, `UNDER_LEGAL_BASIS`, `ISSUED_BY`: exactly one;
   - `RESULTS_FROM_RESPONSE`: required for APPROVAL (V-336);
   - `UNDER_LEGAL_BASIS_VERSION`: zero or one, and it must belong to the record's pathway (V-W13-05).

   All are enforced in the write transaction. The validators detect violations afterwards.
3. **Asserted-edge profile.** `STATUS_OF`, `SUBMITTED_BY`, `SUBMISSION_ABOUT`, `SUPERSEDES_SUBMISSION` and `INSPECTED_FACILITY` are written in the **same transaction** as their Assertion. The valid bounds and bases are copied from the assertion (V-W13-07). `recordedFrom` is assigned by the service at commit (INV-502).
4. **Episode closing.** A vacatur or repeal is written in one transaction:
   - write `recordedTo` (once, from null) on the open `HAS_PATHWAY_VERSION` episode;
   - create the bounded episode;
   - create the superseding Assertion with `SUPERSEDES {VALIDITY_BOUNDED}`;
   - close and re-open the dependent `STATUS_OF` episodes, found through `UNDER_LEGAL_BASIS_VERSION` (V-334r).

   This needs serializable handling per pathway. Take a write lock on the pathway node first (`SET pw._lock = pw._lock`) so concurrent ingestion of two notices cannot create overlapping episodes (V-W13-06).
5. **Approval writes.** Writing `statusKind: APPROVAL`, or the live projection `Product.status = 'APPROVED'`, requires the approving response in the same transaction (V-336, V-322r). Approval is never defaulted from a company source.
6. **Derived projections are regenerated by a job, never written by clients:**
   - legacy `HAS_REGULATORY_STATUS` / `FOLLOWS_PATHWAY` (rules W13-DR-01/02, `@settable(false)` in SDL);
   - the pathway's `legalBasisCitation` / `effectiveFrom` / `effectiveTo`.

   Each run deletes and rewrites the edges per product. Idempotence key: (product uid, target uid, rule).
7. **Forbidden implications.** Agent writes of the conclusion predicates must be refused by QS-4b-style preconditions. V-W13-12 audits after the fact. The conclusion predicates are FDA_APPROVED, IS_APPROVED, CGMP_COMPLIANT, PMA_APPROVAL, FDA_GRAS_DETERMINATION, AUTHORIZATION and FDA_CLEARED.

## 4. Capability and edition conditions

- **APOC is required for the GraphQL layer.** `@neo4j/graphql` 7.6.3 renders DateTime fields with `apoc.date.convertFormat`. Without APOC every GraphQL read of a DateTime fails (run: W13-SR-16). APOC core is available for Community. The harness should add the `apoc` core jar.
- **Enterprise-only items.** Existence and type constraints on Community remain service-enforced. Everything else in `operations.cypher` runs on Community.
- **Version caveat.** The `COUNT { }` subqueries and `elementId()` used in the validators need Neo4j ≥ 5.x. They ran on 5.26.31.

## 5. Lifecycle, idempotence and ingestion overhead

- **Idempotent keys:**

  | Record | Key |
  |---|---|
  | submission | agency `Identifier` (scheme + value) |
  | response | submission uid + issuedAt + responseKind |
  | status | subject uid + statusKind + jurisdiction + legal-basis version |
  | pathway version | pathway uid + legalBasisCitation |
  | inspection | agency + facility + startedAt |

  Re-ingesting the same letter is a no-op (MERGE on uid derived from the key). The opaque segment is still a ULID in production.
- **Agency database refreshes.** The 510(k), De Novo, Drugs@FDA, OOPD and GRAS inventory pages all show "Page Last Updated". Each refresh is a new SourceSnapshot. A changed field produces a SourceRevisionEvent and a superseding assertion, never an in-place overwrite.
- **Overhead per regulatory record.** One submission, one response, one status, plus about three Assertions (SUBMITTED_BY, SUBMISSION_ABOUT, STATUS_OF) and their locators. That is about 10 nodes and 20 relationships. The positive fixture (7 subjects, 2 pathways with versions, characterization) is 383 statements.
- **Migration.** Live `RegulatoryStatus` nodes are relabeled (`VersionedState`), and their `applicationNumber` and `decisionDate` are split into new Submission and Response nodes. `statusKind` is set by mapping plus review and never defaulted (see `migration-map.yaml`). Unmapped nodes stay maturity CANDIDATE and are excluded from approval answers. During the transition, run catalog V-322/V-333/V-334 next to V-322r/V-333r/V-334r as migration checks.
