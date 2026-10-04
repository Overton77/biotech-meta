# W12 operations recommendation

Target declared by the run: Neo4j **5.26.31 Community** (tested), `@neo4j/graphql` 7.6.3, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22. Enterprise behaviour is unverified. No runtime implementation is delivered; `operations.cypher` is the recommended W12 slice of Fable's operations file.

## 1. Constraints and indexes (stored property names)

`operations.cypher` (28 statements) was applied to the embedded 5.26.31 Community instance **twice**: 28/28 ok both times (idempotent `IF NOT EXISTS`), 17 W12 constraints and 28 W12 indexes ONLINE (constraint-backed indexes included).

| Need | Statement(s) | Why |
|---|---|---|
| uid uniqueness per W12 label | `w12_<label>_uid` ×13 (`REQUIRE n.uid IS UNIQUE`) | identity (INV-001); MERGE by uid in ingestion; V-000a remains the cross-label check |
| live `id` uniqueness | `w12_productlot_id`, `w12_measuredresult_id`, `w12_certificateofanalysis_id`, `w12_certificationlisting_id` | GraphQL `@id` lookups; INV-106 seam |
| lot lookup | `w12_productlot_lotcode` (range, **not unique**) | the same lot code recurs across brands and variants; uniqueness of (issuer, variant, lotCode) is service-enforced |
| analyte lookups | `w12_measuredresult_analyte`, `w12_measuredresult_analyteuid`, `w12_specificationcriterion_analyte` | CQ-AX-19, CQ-QA-C02 |
| document lookups | `w12_certificateofanalysis_number`, `w12_certificationlisting_listingid` | CQ-QA-C01, CQ-PF-03 |
| verdict filters | `w12_passfail_basis_verdict` (composite), `w12_testexecution_purpose` | CQ-QA-C02, CQ-QA-C03 |
| edge lookups | `w12_covers_assertionuid`, `w12_has_certification_scope_reluid`, `w12_lot_of_assertionuid` (relationship property indexes) | CERTIFIED_UNDER derivation joins COVERS by assertion uid; episode closure by relationshipUid |

Not created: no fulltext or vector index. No W12 retrieval question needs semantic search; analytes and lot codes are exact lookups (D-014: `@vector` only with a retrieval justification). If a COA text search is later wanted, it belongs to W20 chunks over the COA's `DocumentTextVersion`, never to `MeasuredResult`.

**Enterprise companion (not run; Community rejects these):** property existence for `ProductLot.lotCode`, `MeasuredResult.qualifier`, `MeasuredResult.analyte`, `SpecificationCriterion.comparator/criterionText/criterionPurpose/criterionBasis`, `PassFailInterpretation.verdict/verdictBasis`, `CertificateOfAnalysis.signatureEvidence`, `CertificationScope.scopeText`, `CertificationListing.status`, `CertificationProgram.certifiedObjectKind`; property type `MeasuredResult.value :: FLOAT`, `uncertainty :: FLOAT`, `ProductLot.expiryDate :: ZONED DATETIME`. On Community these are application validation plus V-W12-04/V-124 audits. Keep them in a separate file; never mix them into the baseline script.

## 2. Application validation (write service, transactional)

Each rule runs inside the write transaction and rejects the write; the V-queries are the after-the-fact audit, not the enforcement.

| Rule | Preventive check at write | Audit |
|---|---|---|
| closed enums (13 W12 enums + W00 enums used) | reject unknown values (SDL only constrains API writes, not Cypher ingestion) | V-W12-04 (qualifier), V-W12-05 |
| value/qualifier coherence; uncertainty > 0 with value and unit | reject | V-W12-04, V-124 |
| a MeasuredResult needs exactly one producer and ≥1 locator in the same transaction | create result, PRODUCED_RESULT and SUPPORTED_BY atomically | V-W12-03 |
| no value from a summary or a pass verdict | an extractor emitting a MeasuredResult must cite a locator whose text contains the value; SOURCE_STATED + NOT_REPORTED never links a result | V-W12-05, V-W12-12 |
| COA classification | the document classifier assigns CertificateOfAnalysis only when V-W12-01 elements are present after the batch; otherwise LotTestSummary | V-W12-01, V-W12-02 |
| SAMPLE_FROM exactly one target; TESTED_SAMPLE exactly one | reject second edge | V-W12-08 |
| interpretation target = tested lot/execution | reject | V-W12-09 |
| comparable inputs for EVALUATED verdicts; stability vs release | the evaluator returns NOT_EVALUABLE instead of a verdict | V-W12-11 |
| programme kind vs COVERS target | reject | V-W12-06 |
| CERTIFIED_UNDER written only by the projection job (`w12-certified-under/v1`) | API field is `@settable(false)`; Cypher writers other than the job are refused by service role | V-332, V-W12-07, V-112 |
| HAS_CERTIFICATION_SCOPE episodes immutable except one write of `recordedTo`; `validTo` only with STATED_BY_SOURCE | reject | V-W12-10 (+ requested V-503 extension, W12-SR-09) |
| PERFORMED_BY_LAB inferred from document structure → PROPOSED | extractor sets status and `extractionMethod` | V-110 (only ACCEPTED needs capture-fidelity) |
| `createdAt` and `updatedAt` on every Cypher-ingested node | the GraphQL types declare them `DateTime!`; nodes without them break API reads | (no V-query; recommend one in Fable's suite) |

Concurrency: MERGE on `uid` under the uniqueness constraints makes concurrent ingestion of the same lot or listing idempotent. Derived CERTIFIED_UNDER regeneration takes a per-listing lock (write a lock property on the CertificationListing in the same transaction) so a scope-episode closure and a derivation run cannot interleave; regeneration deletes and re-creates only edges whose `derivationRule` starts with `w12-certified-under/`.

## 3. Retrieval patterns

- **CQ-PF-03:** start at the item (index on `uid`), traverse `CERTIFIED_UNDER` (derived, current) and, for explanation, `COVERS` back to the scope and listing; never infer from a product name. Q-PF-03a/b.
- **CQ-AX-19:** lot uid comes from the private store as a parameter (no private node or edge in the shared graph; N14 shows the leak is detected by V-113/V-114). Results are filtered by "known as of" (supporting snapshot retrieved ≤ T) and "not replaced by a SourceRevisionEvent recorded ≤ T"; comparison with the W04 QuantityDeclaration only when quantity basis, amount referent and mass basis agree. Lot-unknown results are listed separately.
- **CQ-QA-C04:** bitemporal filter on `HAS_CERTIFICATION_SCOPE.recordedFrom/recordedTo` and `COVERS.recordedFrom/recordedTo` (index on relationshipUid / assertionUid).
- Typical depth: ≤ 5 hops; all W12 queries ran in milliseconds on the fixture graph (263 nodes; 791 in the combined run).

## 4. Capability and edition conditions

| Capability | Community 5.26 | Enterprise | Fallback |
|---|---|---|---|
| uniqueness constraints, range indexes, relationship property indexes | yes (tested) | yes | — |
| property existence / type constraints | **no** | yes (untested here) | write-service validation + V-W12-04, V-124 |
| relationship cardinality / endpoint constraints | no (neither edition as such) | no | write service + V-W12-03/05/08 |
| `@neo4j/graphql` DateTime output | requires **APOC** (`apoc.date.convertFormat`), observed failure without it | same | install APOC core (deployment prerequisite; W12-SR-11) |
| API create of W12 nodes | `@id` autogenerates `id` ≠ opaque(uid) | same | service mints uid from the generated id, or kernel types are read-only in the API (W12-SR-11) |

## 5. Idempotence, lifecycle, migration, ingestion overhead

- **Idempotence:** every fixture statement is a MERGE on `uid` (re-running a file is a no-op except for `SET` of identical values); `operations.cypher` is `IF NOT EXISTS`.
- **Lifecycle:** MeasuredResult, LotTestSummary, CertificateOfAnalysis, PassFailInterpretation are immutable (corrections = new artifact on the revised snapshot + SUPERSEDES between interpretations); SpecificationCriterion, CertificationListing, CertificationScope are replaced by new states; HAS_CERTIFICATION_SCOPE episodes are closed by one `recordedTo` write. ProductLot, TestSample, TestMethod, TestingLaboratory, CertificationProgram are stable identities (merges through W00 EquivalenceAssessment and redirect, never by lot-code similarity).
- **Migration:** no live quality data exists; live seams (`qualitySystemKind`, `GMP_FACILITY`, `traceabilityCode`) migrate as in `migration-map.yaml`, owned by W11/W01/W02.
- **Ingestion overhead:** each asserted edge costs one Assertion node with four kernel edges (subject, object, asserter, locator). A real 11-row COA modeled fully is about 11 executions, 11 criteria, ≤ 11 results or interpretations and ~35 asserted edges (≈ 35 assertions). Fixture 10 models 4 of the 11 rows (136 statements including the summary and a synthetic COA). The cost is accepted because each of those edges (method, lab, criterion, certified lot) is independently disputable; Fable may decide to reclassify `USED_METHOD`, `EVALUATED_AGAINST` and `CERTIFIES_RESULTS_FOR` as structural when the COA artifact itself is the only source (not recommended now: subcontracted rows show they can conflict across sources).
- Load time on the embedded instance: ~95 s for the 428 positive statements (one transaction per statement over Bolt); bulk ingestion should batch by document with UNWIND.
