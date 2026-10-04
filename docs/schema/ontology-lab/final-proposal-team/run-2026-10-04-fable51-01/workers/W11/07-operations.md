# W11 Operations recommendation

Target: Neo4j **5.26.31 Community** (tested), `@neo4j/graphql` **7.6.3**, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22. Enterprise statements are listed separately and were **not** run. No application runtime is implemented here.

## 1. Constraints and indexes (stored property names)

Community-runnable (uniqueness and range/fulltext indexes):

```cypher
CREATE CONSTRAINT w11_mfg_spec_uid IF NOT EXISTS FOR (n:ManufacturingSpecification) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w11_spec_version_uid IF NOT EXISTS FOR (n:SpecificationVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w11_mfg_process_uid IF NOT EXISTS FOR (n:ManufacturingProcess) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w11_mfg_step_uid IF NOT EXISTS FOR (n:ManufacturingStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT w11_capability_uid IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.uid IS UNIQUE;
-- live API identity (id = opaque segment of uid); stored property name `id` for all W11 types
CREATE CONSTRAINT w11_mfg_process_id IF NOT EXISTS FOR (n:ManufacturingProcess) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w11_mfg_step_id IF NOT EXISTS FOR (n:ManufacturingStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w11_mfg_spec_id IF NOT EXISTS FOR (n:ManufacturingSpecification) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w11_spec_version_id IF NOT EXISTS FOR (n:SpecificationVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT w11_capability_id IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.id IS UNIQUE;
-- relationship uniqueness for asserted episodes (Neo4j 5.7+ relationship uniqueness constraints are Community-capable)
CREATE CONSTRAINT w11_has_capability_state_rel_uid IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_governed_by_spec_rel_uid IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_produced_by_process_rel_uid IF NOT EXISTS FOR ()-[r:PRODUCED_BY_PROCESS]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_inputs_rel_uid IF NOT EXISTS FOR ()-[r:INPUTS]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_outputs_rel_uid IF NOT EXISTS FOR ()-[r:OUTPUTS]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_performs_process_rel_uid IF NOT EXISTS FOR ()-[r:PERFORMS_PROCESS]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE CONSTRAINT w11_hosts_process_rel_uid IF NOT EXISTS FOR ()-[r:HOSTS_PROCESS]-() REQUIRE r.relationshipUid IS UNIQUE;
-- retrieval
CREATE INDEX w11_spec_version_payload IF NOT EXISTS FOR (n:SpecificationVersion) ON (n.payloadHash);
CREATE INDEX w11_capability_stage IF NOT EXISTS FOR (n:ManufacturingCapability) ON (n.stage);
CREATE INDEX w11_capability_payload IF NOT EXISTS FOR (n:ManufacturingCapability) ON (n.payloadHash);
CREATE INDEX w11_process_kind IF NOT EXISTS FOR (n:ManufacturingProcess) ON (n.processKind);
CREATE INDEX w11_has_capability_state_assertion IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() ON (r.assertionUid);
CREATE INDEX w11_has_capability_state_recorded IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() ON (r.recordedTo);
CREATE INDEX w11_governed_by_spec_assertion IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() ON (r.assertionUid);
```

The kernel-wide `Entity.uid` / `VersionedState.uid` uniqueness (W00) already covers cross-label uid uniqueness (V-000a); the per-label constraints above make the primary-label MERGE keys index-backed. These statements were **not** executed by W11 (Fable runs the merged operations file); their syntax follows the baseline `constraints.cypher` forms that applied on 5.26.31 (relationship uniqueness is new to this list and must be checked by Fable on the target).

Enterprise-only (not runnable on the test target; application enforcement replaces them):

```cypher
CREATE CONSTRAINT w11_capability_stage_exists IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.stage IS NOT NULL;
CREATE CONSTRAINT w11_capability_payload_exists IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.payloadHash IS NOT NULL;
CREATE CONSTRAINT w11_spec_version_payload_exists IF NOT EXISTS FOR (n:SpecificationVersion) REQUIRE n.payloadHash IS NOT NULL;
CREATE CONSTRAINT w11_capability_value_type IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.capacityValue IS :: FLOAT;
CREATE CONSTRAINT w11_hcs_assertion_exists IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() REQUIRE r.assertionUid IS NOT NULL;
CREATE CONSTRAINT w11_hcs_recorded_exists IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() REQUIRE r.recordedFrom IS NOT NULL;
```

No fulltext or vector index is requested: no W11 CQ is a text-retrieval question (names are presentation; specifications and processes are reached from materials and organizations). D-014: no `@vector`.

## 2. Retrieval patterns

| Pattern | Path | Index used |
|---|---|---|
| Current capability of a holder (CQ-MF-04) | `(holder {uid})-[h:HAS_CAPABILITY_STATE]->(c)` with `h.recordedTo IS NULL` and valid-time filter | uid constraint, `recordedTo` rel index |
| As-recorded view (bitemporal) | same with `recordedFrom <= $t < recordedTo` | uid |
| Disclosure vs promotion (CQ-MF-05) | `(a:Assertion)-[:ASSERTED_BY]->(org)`, `(a)-[:SUPPORTED_BY]->()<-[:HAS_LOCATOR]-()<-[:HAS_SNAPSHOT]-(s:Source)` | W00 indexes |
| Governing spec of a material | `(m {uid})-[g:GOVERNED_BY_SPECIFICATION]->(v)-[:VERSION_OF_SPECIFICATION]->(s)` | uid |
| Version de-duplication at ingest | `MATCH (v:SpecificationVersion {payloadHash:$h})-[:VERSION_OF_SPECIFICATION]->(:ManufacturingSpecification {uid:$s})` | payloadHash index |
| Process inputs by step | `(p {uid})-[:HAS_STEP]->(st)-[:INPUTS|OUTPUTS]->(x)` ordered by `orderIndex` | uid |

## 3. Application validation and transactions (service-enforced; SDL and Community constraints do not enforce these)

Write units (each one transaction, in this order):

1. **Capability episode:** create or reuse the `ManufacturingCapability` by (`payloadHash`) -> create `CAPABILITY_FOR_PROCESS/MATERIAL` -> create the `Assertion` (subject holder, object state, `ASSERTED_BY`, `SUPPORTED_BY` locator) -> evaluate INV-305 (V-324r logic) **before** creating `HAS_CAPABILITY_STATE`; reject OPERATING without allowlisted source or SUPPORTED adjudication -> check exclusivity (V-W11-02 logic, definite overlap) inside the same transaction -> create the edge copying valid bounds from the assertion (V-W11-01). Concurrency: take a write lock on the holder node (`SET holder._lock = 1 REMOVE holder._lock` or `CALL db.lock`-equivalent via MERGE on a per-line lock node) so two concurrent episodes for one line cannot both pass the overlap check.
2. **Correction / bound:** new Assertion + `SUPERSEDES {supersessionKind}`; write `recordedTo` once on the old assertion and old edge; create the new edge; INFERRED bounds require `derivationRule` (V-503).
3. **Specification version:** compute criterion payload hashes -> `criteriaDigest` -> `payloadHash`; MERGE the version by (specification uid, payloadHash); create version and all captured criteria (W12) in one transaction; never add a criterion to an existing version (V-W11-09 audits).
4. **GOVERNED_BY_SPECIFICATION:** Assertion first, then edge; exclusivity per (material, specification) checked under a lock on the material.
5. **Process I/O:** Assertion per edge; target resolution must yield `IngredientMaterial` or `ChemicalSubstance` (V-W11-12); never write `CONTAINS`/`QUANTITATIVELY_CONTAINS` from an input.
6. **cGMP claims:** write only the literal Assertion; no edge may cite it (V-W11-06 is the audit; the writer refuses any projection whose cited predicate is `CLAIMS_CGMP_COMPLIANCE`).

Closed vocabularies enforced by the service (Community cannot): `CapabilityStage`, `CapacityBasis`, `ProcessKind` (GraphQL enforces them on API writes only; direct Cypher ingestion must validate), and the controlled strings `specificationKind`, `stepKind`, `ioRole`, `ioQuantityBasis`, `limitStage` (W12).

## 4. Idempotence, lifecycle, migration

- Idempotent keys: nodes by `uid`; asserted edges by `relationshipUid`; versions and capability states by `payloadHash` (+ specification uid); fixtures use `MERGE` on these keys and re-run without duplicates (fixture 01-04 were loaded twice across runs 1-3 without duplicate rows in V-000a).
- Immutability: SpecificationVersion, ManufacturingCapability and criterion payloads never change after commit; only `recordedTo` on edges/assertions is written once.
- Migration order (live -> final; details in `migration-map.yaml`): (1) backfill `uid` on live ManufacturingProcess/Step; (2) resolve each live `Material` to IngredientMaterial or ChemicalSubstance (review queue for unresolved); (3) convert INPUTS/HAS_INPUT/OUTPUTS/HAS_OUTPUT/PRODUCES to asserted edges with PROPOSED migration assertions (`extractionMethod: MIGRATION`, Activity with methodVersion); (4) move `qualitySystemKind` and `productionScale` strings to PROPOSED assertions/states, never attached without a locator; (5) delete live `Material` label (V-W11-12 must return zero), `PRODUCES`, `HAS_INPUT`, `HAS_OUTPUT`, `SUPPORTED_BY`->Chunk on W11 types.
- Compatibility: GraphQL field names change (`hasSteps` -> `steps`, `inputsMaterials` -> `inputMaterials`/`inputSubstances`, `producesMaterials` -> `producedMaterials`, `hasInputMaterials` -> `inputMaterials`); Fable may keep the old names with `@alias`-free duplicate read-only fields for one release if clients need them (not proposed by W11).

## 5. Ingestion overhead

- Each capability episode = 1 state (often reused), 1 assertion, 1-2 locators, 1 edge, plus a SUPPORT adjudication only for promoted or disputed claims.
- Each specification version = 1 version + n criteria (W12) + 1 governing assertion/edge per material; the digest computation is local.
- Each process = 1 process + k steps + one assertion per I/O edge (the GRN 635 route: 2 steps, 9 I/O edges, 9 assertions). Batch by source: one Activity per dossier.

## 6. How the fixtures were run (reproducible)

```bash
# harness: validation/harness (EmbeddedNeo4j.java, run-cypher.mjs); scratch runner: scratchpad/w11/runner.mjs
java -cp "classes:lib/*" EmbeddedNeo4j <dir>          # Neo4j 5.26.31 community, bolt only
node runner.mjs <bolt> run2.json                      # inherited fixture + W11 01-04, baseline suite, W11 suite, negatives N1-N10, CQ queries
NOINHERIT=1 NONEG=1 ONLY=<fixture> node runner.mjs <bolt> iso.json   # each fixture alone
node build-schema.mjs combined.graphql generated.graphql            # stubs + sdl-fragment.graphql under @neo4j/graphql 7.6.3
```
