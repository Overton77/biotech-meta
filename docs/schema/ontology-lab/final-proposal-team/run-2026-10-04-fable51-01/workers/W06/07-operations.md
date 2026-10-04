# W06 operations recommendation

The target is Neo4j 5.26 (tested on 5.26.31 Community, embedded) and `@neo4j/graphql` 7.6.3. There is no `@unique` directive, so uniqueness comes only from Cypher constraints. `operations.cypher` holds the executable statements, and all 16 ran on Community on 2026-10-04 (results in `fixtures/results/operations.json`).

## 1. Uniqueness and indexes (stored property names)

| Statement | Purpose | Edition | Verified |
|---|---|---|---|
| `Treatment.uid`, `Treatment.id`, `Procedure.uid`, `Procedure.id` UNIQUE | Canonical identity and live projection id (INV-001, INV-106) | Community | 4 UNIQUENESS constraints ONLINE |
| `relationshipUid` UNIQUE on `TARGETS_CONDITION`, `USES_COMPONENT`, `DEVELOPS_TREATMENT`, `OFFERS_TREATMENT`, `OFFERS_PROCEDURE` (and W09's `FOLLOWS_INTERVENTION_DEFINITION`, recommended to W09) | One edge per recorded-time episode (`asserted_edge` profile). Makes retries idempotent. | Community (relationship property uniqueness, 5.7+) | 6 RELATIONSHIP_UNIQUENESS constraints ONLINE in the final rerun (5 W06 types plus W09's `FOLLOWS_INTERVENTION_DEFINITION`; `fixtures/results/constraints-summary.txt`). In the earlier run, a duplicate `CREATE` with an existing `relationshipUid` was rejected ("Relationship(54) already exists with type `USES_COMPONENT` and property `relationshipUid` …"). |
| Range index on `USES_COMPONENT.assertionUid` and `TARGETS_CONDITION.assertionUid` | Assertion-to-edge joins (QS-4a, V-W06-08, supersession closing `recordedTo`) | Community | ONLINE |
| Range index on `USES_COMPONENT.componentRole` | CQ-AX-23 / V-W06-01 path filter `{componentRole: 'ADMINISTERED_PRODUCT'}` | Community | ONLINE |
| Fulltext `TreatmentSearch` (name, description, searchText, treatmentClass, orphanDrugDesignation); `ProcedureSearch` (name, description, searchText, procedureType, setting) | Live index and query names retained (D-015) | Community | ONLINE. `db.index.fulltext.queryNodes('TreatmentSearch','beta-thalassemia')` returned exa-cel (score 0.81), found through the designation display text. This is the documented "a hit is a candidate, not an answer" case. |
| Vector `TreatmentSearchEmbedding` on `Treatment.searchEmbedding` (example: 1536 dims, cosine) | Retrieval justification: free text to candidate treatment concepts (QS-8), for messy names such as "exa-cel", "CTX001" and "CRISPR sickle cell therapy". The embedding is regenerable (INV-107) and never evidence. Fable records the real dimension at merge (D-014). `@vector` is written without `provider:`. | Community 5.26 | ONLINE |
| Existence and type constraints (`entityType`, `componentRole`, `assertionUid` NOT NULL; `modalities :: LIST<STRING NOT NULL>`) | Required-field enforcement | **Enterprise only** | Commented out in `operations.cypher`. The trial statement on Community failed with "Property existence constraint requires Neo4j Enterprise Edition". On Community these rules are enforced by V-W06-08 and the ingestion service. |

No vector index is proposed for `Procedure`; there was none live, and no retrieval case needs one.

## 2. Application validation (service-enforced on Community)

1. **Asserted-edge write precondition.** Run QS-4b before writing any W06 asserted edge. It requires a live assertion with the same predicate, subject and object. The edge copies the assertion's valid bounds, precisions and bases (INV-503), and `recordedFrom` is the commit time (INV-502).
2. **Required qualifiers.** `componentRole` is required on `USES_COMPONENT`. `intentKind` and `intentBasis` are required on `TARGETS_CONDITION`. Unmapped legacy values become NOT_STATED, never a guess.
3. **Read-only projections.** `developmentStage`, `developmentStageAssertionUid`, `orphanDrugDesignation`, `orphanDesignationStatusUids` and `modality` are written only by the projection job, which needs Cypher; GraphQL exposes them as `@settable(false)`.
   - The `developmentStage` projection may write approval wording only when V-W06-01 would pass for that treatment.
   - `orphanDrugDesignation` is regenerated from W13 states. Legacy text stays until backed (V-W06-02 reports it).
4. **Modality list rules.** COMBINATION requires at least two components (V-W06-05). `modality` equals the single element or null.
5. **Concept-component provenance.** A preparatory, collection or co-intervention component sourced only from a trial registration is held for review (V-W06-06 warning).
6. **Identity.** Never merge `Procedure` or `Treatment` nodes on a shared Identifier (V-W06-07). Merges go through an `EquivalenceAssessment` that rests on more than a code, and the old uid stays resolvable.
7. **Privacy.** Refuse `hu:private-*` uids or any privacyClass other than PUBLIC or INTERNAL on W06 types (V-W06-08b). No person's procedure course or treatment history is ever written.
8. **Evidence boundary.** Never derive Study-side → Product edges through the concept (V-W06-04, baseline V-201).

## 3. Transactions and concurrency

- An asserted edge and its Assertion are created in **one transaction**, so the edge never exists without its citation. Supersession writes the new assertion, the `SUPERSEDES` record and the old edge's `recordedTo` together.
- Concurrent writers of the same episode collide on `relationshipUid` uniqueness. Retries with the same `relationshipUid` are idempotent under MERGE.
- Projection jobs (`developmentStage`, `orphanDrugDesignation`, `modality`) run after the W13 and W06 commits. They are idempotent recomputations that read assertions as of a recorded time, so readers can tolerate lag. The projection never feeds back into an assertion.

## 4. Lifecycle, migration and compatibility

- **Additive for the live API.** Kept field names: `modality` (now read-only), `developmentStage` and `orphanDrugDesignation` (read-only), `targetsConditions`, `usesComponents`, `developedBy`, `offeredBy`, `listedIn`, and the fulltext query names `searchTreatments` and `searchProcedures`.
- **Breaking for clients.**
  - `Treatment.evaluatedInStudies` is removed; read `Study.evaluates` (legacy) or the `FOLLOWS_INTERVENTION_DEFINITION` path.
  - Writes to `modality`, `developmentStage` and `orphanDrugDesignation` are refused through GraphQL.
  - The edge property types change from `TreatmentComponentMetadata`/`TreatmentTargetMetadata`/`RoleMetadata` to the new types; `confidence` and `notes` are dropped.
  - The union is renamed `TreatmentComponent` → `TreatmentComponentTarget`.
- **Migration steps** (`migration-map.yaml`):
  1. Backfill `uid` (`hu:treatment:<id>`, `hu:procedure:<id>`).
  2. For every live W06 edge, create one Assertion with predicate = edge type, basis UNKNOWN and a MIGRATION adjudication, then set `assertionUid`, `relationshipUid` and `recordedFrom` (V-105 / V-503 rules: UNKNOWN basis with null bounds).
  3. Map the free-text role and indication type to the enums, falling back to NOT_STATED.
  4. Set `modalities = [modality]`.
  5. Leave `developmentStage` and `orphanDrugDesignation` text in place with null source uids, so V-W06-02 lists them for backing.
- **Ingestion overhead.** Each W06 fact costs about four writes: one Assertion, one edge, one SUPPORTED_BY and a later adjudication. This is in line with other asserted domains. Display projections cost one recomputation per W13 status change of a linked product.

## 5. Capability conditions

- Relationship uniqueness constraints and vector indexes are verified on 5.26 Community. On a pre-5.7 deployment, relationship uniqueness would fall back to service checks plus V-W06-08.
- Fulltext and vector indexes do not cover private data (INV-105).
- Enterprise is unverified (not available in this run). The commented existence and type constraints are expected to work there but were not executed.
