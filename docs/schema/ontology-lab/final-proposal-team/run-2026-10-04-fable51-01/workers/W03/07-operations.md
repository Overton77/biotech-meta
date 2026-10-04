# W03 operations recommendation

Target: Neo4j 5.26.31 Community (tested), `@neo4j/graphql` 7.6.3 (no `@unique`). The Community statements below are in `operations.cypher` and were **run** on a fresh instance twice (12/12 ok both times: idempotent) followed by violating writes: duplicate taxon id, duplicate (REACTOME, R-HSA-196807), duplicate MONDO id, duplicate HGNC id and an Organ plus a plain AnatomicalContext with the same UBERON id were each rejected; two Conditions without `mondoId` and the same `externalId` under another `sourceDatabase` were accepted (as intended). Enterprise-only statements are marked and were not tested. No runtime implementation is proposed here; Fable writes the operations file.

## 1. Constraints and indexes (stored property names)

| Statement (Cypher 5) | Edition | Purpose |
|---|---|---|
| uid uniqueness is covered by the archetype constraints (`Entity`, `Occurrence`, … `uid` IS UNIQUE) in `neo4j/constraints.cypher` | Community | INV-001; requires archetype labels on every W03 node (D-001) |
| `CREATE CONSTRAINT species_ncbi_taxonomy_id IF NOT EXISTS FOR (s:Species) REQUIRE s.ncbiTaxonomyId IS UNIQUE` | Community | V-W03-12 preventive half (presence still audit-only on Community) |
| `CREATE CONSTRAINT pathway_external_id IF NOT EXISTS FOR (p:Pathway) REQUIRE (p.sourceDatabase, p.externalId) IS UNIQUE` | Community (composite uniqueness) | one node per authority stable id |
| `CREATE CONSTRAINT condition_mondo_id IF NOT EXISTS FOR (c:Condition) REQUIRE c.mondoId IS UNIQUE` | Community | materialized key; nulls allowed (uniqueness ignores missing values) |
| `CREATE CONSTRAINT molecular_entity_hgnc_id IF NOT EXISTS FOR (m:MolecularEntity) REQUIRE m.hgncId IS UNIQUE` | Community | |
| `CREATE CONSTRAINT anatomical_context_uberon_id IF NOT EXISTS FOR (a:AnatomicalContext) REQUIRE a.uberonId IS UNIQUE` | Community | covers Organ (shared label); V-W03-06 |
| `CREATE INDEX mechanism_context_setting IF NOT EXISTS FOR (c:MechanismEvidenceContext) ON (c.setting)` | Community | CQ-MX-02/03 filters |
| `CREATE INDEX assertion_basis_kind IF NOT EXISTS FOR (a:Assertion) ON (a.predicateClass, a.basisKind, a.status)` | Community | projection job and V-230..V-233r scans (W00 owns Assertion; request) |
| `CREATE INDEX biomarker_matrix_lookup …` | — | not needed: traversal from Biomarker |
| `CREATE CONSTRAINT mechanism_context_setting_exists … REQUIRE c.setting IS NOT NULL` | **Enterprise only** (already annotated in validation.cypher) | V-231 preventive; on Community the application must reject |
| `… FOR (c:MechanismEvidenceContext) REQUIRE c.exposureAmount IS :: FLOAT` | **Enterprise only** | V-232 type half |
| Fulltext `MechanismSearch` on (`name`, `description`, `searchText`) and `ConditionSearch` on (`name`, `description`, `searchText`, `mondoId`, `icd11Code`, `orphaCode`, `omimId`) | Community | live index and query names retained (D-015); stored names equal GraphQL names (no aliases in W03) |
| Relationship property index `CREATE INDEX derived_rule IF NOT EXISTS FOR ()-[r:AFFECTS_MECHANISM]-() ON (r.derivationRule)` (one per rule-mode type) | Community | step 0 deletion and V-233r scans; optional |

Vector: `Mechanism.searchEmbedding` and `Condition.searchEmbedding` exist in live without `@vector`; W03 states no retrieval justification beyond fulltext, so no vector index is requested (D-014).

## 2. Application validation (transactional, preventive)

Community cannot express these; the ingestion service must check inside the writing transaction and the audit queries detect drift:

1. Mechanism-class assertion write: `basisKind` required; DIRECT_MEASUREMENT ⇒ exactly one `OBSERVED_IN_CONTEXT` in the same transaction; other bases ⇒ none; INFERRED_FROM_MEASUREMENT ⇒ at least one `DERIVED_FROM_ASSERTION` to a DIRECT_MEASUREMENT assertion (V-230, V-231, V-W03-04).
2. Context write: setting in enum; species unless cell-free/in silico; amount ⇒ unit + basis; unknown ⇒ null + `exposureStatus`, never 0; `IN_STUDY_ARM` ⇒ no exposure fields; `hedValue` ⇒ `hedMethod`; controlled strings (V-231, V-232, V-236, V-238, V-W03-11).
3. Level-change assertion: context compartment equals measurand matrix (V-239) — checked at commit, not by projection.
4. Derived edges: written only by the projection job principal; GraphQL mutation inputs exclude them (`@settable(onCreate:false,onUpdate:false)`, verified in the generated schema); direct Cypher writers must be denied by role (Enterprise RBAC) or audited by V-112/V-233r/V-234r/V-W03-01/V-W03-03 on Community.
5. Identifier writes: no versioned Reactome id as `externalId`; no ICD code as a Condition property (V-W03-08, V-W03-09); a code whose fiscal-year validity ends gets `validTo` on the HAS_IDENTIFIER episode through a new recorded episode, never by editing the old one.
6. Organ creation: always with `AnatomicalContext` label and `contextKind ORGAN`; uberonId uniqueness constraint above.

## 3. Projection job (`mx-proj/v1`) concurrency and lifecycle

- Trigger: any commit that creates, supersedes or re-adjudicates a mechanism-class assertion, or edits a context's species/compartment (a context is immutable, so this means a new context). Scope regeneration to the affected (subject, object) and (mechanism, species/site) groups.
- Transaction: delete-and-rebuild of one group in one write transaction; take an exclusive lock on the group's anchor node (`SET m._projLock = randomUUID()` then remove, or `CALL apoc.lock.nodes` where APOC is available) so two concurrent regenerations cannot interleave; idempotent (run twice: 6 deleted, 6 recreated, identical counts).
- Recorded time: derived edges carry `derivedAt`; they are not history. Point-in-time questions ("which shortcuts existed on date D?") are answered from assertions (recordedAt/recordedTo), never from derived edges.
- Supersession: when an input assertion is superseded (`recordedTo` set), the next run drops it from `derivedFromAssertionUids`; if no input remains, the edge disappears.
- Ingestion overhead: one extra MATCH per mechanism assertion commit; the full rebuild over the fixture (14 assertions) ran in < 1.2 s per step on the embedded instance.

## 4. Migration and compatibility

- Relabel: add `Entity`/`Occurrence` archetype labels; add `AnatomicalContext` to every `Organ` node with `contextKind = 'ORGAN'`; populate `uid = 'hu:<token>:' + id`.
- Normalize `Pathway.externalId` (strip `.N` into `pathwayRevision`), `AnatomicalContext.contextKind` (free text → enum, unmapped → null + MIGRATION adjudication), `MechanismLinkMetadata.regulatorySign` (→ enum, unmapped → UNKNOWN).
- Legacy derived edges (`AFFECTS_MECHANISM`, `MODULATES`, `APPLIES_TO_SPECIES`, `INFLUENCES_OUTCOME`, `ACTS_IN`, `ACTS_IN_CONTEXT`, risk and association edges) cannot be regenerated from assertions that do not exist yet. Procedure: copy each into a candidate Assertion (status EXTRACTED, `basisKind` from `causalStatus` when stated else null → flagged by V-230), keep the old edge read-only labelled `LEGACY_UNDATED` in query shapes (QS-2b) until review, then delete and run the projection job.
- `Association` nodes: split by origin (migration-map.yaml); keep uid redirects.
- API: derived fields become read-only; `Pathway.hasMechanisms`, `Organ.hasMechanisms`, `Organ.measuredByMetrics`, `Pathway.actsInOrgans`, `Condition.appliesToSpecies`, `*.supportedBy` disappear from W03 types (breaking; listed in migration map). Inverse fields of other owners' edges on `Condition` depend on Fable's merge (W03-SR-12).

## 5. Capability matrix (W03 rules)

| Rule | Community 5.26 | Enterprise 5.26 (untested) | Fallback |
|---|---|---|---|
| uid uniqueness | constraint | constraint | — |
| key uniqueness (taxon, pathway, MONDO, HGNC, UBERON) | constraint | constraint | — |
| required properties (setting, basisKind) | no | existence constraints | service check + V-231/V-230 |
| property types | no | type constraints | service check |
| cardinality (one context, one species) | no | no | service check + V-231 |
| derived-edge write protection | API only (@settable) | RBAC deny on relationship types | V-112, V-233r, V-234r audits |
| enum membership in Cypher writes | no | no | service check; GraphQL enforces for API writes |
