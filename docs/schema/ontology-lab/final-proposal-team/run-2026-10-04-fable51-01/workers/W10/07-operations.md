# W10 07 Operations

Companion file: `operations.cypher` (Part A constraints and indexes, Part B candidate validators W10-V01…W10-V16b). All statements **run** on Neo4j 5.26.31 Community (31/31 ok); Enterprise-only lines are commented and were not applied.

## Uniqueness and indexes (stored property names)

| Name | Definition | Why | Edition |
|---|---|---|---|
| `w10_*_uid` (7) | `FOR (n:<W10 label>) REQUIRE n.uid IS UNIQUE` | label-scoped lookup index for `MATCH (x:EvidenceApplicability {uid: $uid})`; archetype-level uniqueness (`evidence_assessment_uid`, `entity_uid`) already exists in the baseline | Community |
| `applicability_dimension_kind` | `(d:ApplicabilityDimension) ON (d.dimension, d.verdict)` | QS-3a, CQ-EV-04 filters (same as baseline; IF NOT EXISTS) | Community |
| `synthesis_recorded_at` | `(s:EvidenceSynthesis) ON (s.recordedAt)` | CQ-ST-09 system clock, as-of replay | Community |
| `w10_triggered_by_published_at` | `()-[t:TRIGGERED_BY]-() ON (t.evidencePublishedAt)` | CQ-ST-09 domain clock | Community |
| `w10_includes_result_role` | `()-[i:INCLUDES_RESULT]-() ON (i.inputRole)` | CQ-ST-05, V-215, W10-V11 | Community |
| `w10_endpoint_classification_class` | `(e:EndpointClassification) ON (e.endpointClass, e.surrogateValidationLevel)` | CQ-ST-03 | Community |
| `w10_applicability_method` | `(e:EvidenceApplicability) ON (e.methodVersion, e.status)` | method re-runs, migration batches, W10-V05 | Community |
| existence/type (methodVersion, recordedAt, verdict, ratio FLOAT, inputRole, criterionCode) | commented in Part A | Enterprise only; on Community the service and W10-V* enforce them | Enterprise (unverified) |

No full-text or vector index: W10 nodes are judgements, not retrieval text; answers reach them by traversal from the evidence or the use target.

## Retrieval patterns

- Applicability for a target: `(:FormulationVersion|ProductVariant|Product {uid})<-[:ASSESSES_APPLICABILITY_TO]-(ea)` filtered to the current version `NOT EXISTS { (:EvidenceApplicability)-[:SUPERSEDES]->(ea) }` (or as-of R: `ea.recordedAt <= R AND (ea.recordedTo IS NULL OR R < ea.recordedTo)`), then QS-3a. Never average; return the weakest and unresolved dimensions.
- Synthesis for a claim as of R: `(v:EvidenceSynthesis)-[:ASSESSES_CLAIM]->(c {uid})` with the same as-of filter (Q11, Q12).
- Change history: `TRIGGERED_BY` filtered by `evidencePublishedAt` (domain) or the version's `recordedAt` (system) — two different answers (Q09, Q10).
- Endpoint roles: from `OutcomeDefinition` via `CLASSIFIES_OUTCOME`; contexts for an analyte via `CLASSIFIES_BIOMARKER` (Q05).

## Application validation, transactions, concurrency

1. **One transaction per assessment act**: an `EvidenceApplicability`, all its dimension nodes, `HAS_DIMENSION`, `HAS_EVIDENCE_TARGET`, `ASSESSES_APPLICABILITY_TO`, `FOR_USE_CONTEXT`, `BASED_ON_EVIDENCE`, dimension provenance edges, the `SUPERSEDES` edge to the predecessor and the predecessor's single `recordedTo` write commit together. A partial write would leave a MISSING_DIMENSION (V-204) visible.
2. **Service-assigned `recordedAt`** (all W10 types share the transaction instant; dimensions equal the parent). The service rejects a commit whose `recordedAt` precedes any cited snapshot's `retrievedAt` (W10-V16b).
3. **Supersession race**: two reviewers re-assessing the same predecessor concurrently must not both supersede it. Take a write lock on the predecessor (`SET older._lock = null` or `CALL apoc.lock.nodes([older])`) inside the transaction and refuse if `older.recordedTo IS NOT NULL` (single-write rule). On Community there is no property-existence constraint; the guard is application logic plus W10-V07.
4. **Ratio computation is a service function**, not client input: `ratio = targetValue / evidenceValue` only when `evidenceQuantityBasis = targetQuantityBasis`, both mass bases equal and neither UNSPECIFIED (when the dimension carries mass bases), and one `unitCode`; otherwise null (V-206, W10-V03). A per-serving target becomes PER_DAY only by multiplying by the linked `UseContextProfile.servingsPerDay`.
5. **Calibration gate**: the service keeps the method registry; `$calibratedRatioMethods` and `$calibratedCompositeMethods` are empty in this run, so a continuous MATCH needs ratio 1.0 and `overallScore` stays null (W10-V04, W10-V05).
6. **Flat projections** (`identityMatch` …) are written by the same transaction from the dimension nodes (rule `flat_projection` in `fixtures/gen_w10.py`); clients cannot set them (`@settable(false,false)`).
7. **Privacy**: requests whose use target is not a member of `ApplicabilityUseTarget`, or whose uid starts `hu:private-`, are rejected before commit; `UseContextProfile` writes are checked against the key allow-list (`fixtures/w10-params.json`).
8. **GraphQL surface**: `@mutation(operations: [CREATE, UPDATE])` (no delete); judgement fields create-only; inverse relationship fields not settable. Verified (M1–M3 rejected).

## Idempotence, lifecycle, migration, compatibility

- Fixtures MERGE by uid with `ON CREATE SET`; re-running a fixture changes nothing. Re-assessment never MERGEs onto an existing assessment uid.
- Lifecycle: PROPOSED → ACCEPTED → SUPERSEDED (status) or WITHDRAWN; `recordedTo` set once on supersession.
- Migration (see `migration-map.yaml`): live `EvidenceStrength` values → `EvidenceStrengthAssessment {LEGACY_UNSPECIFIED, PROPOSED}` with the edge copy keeping `assessmentUid`; `isClinicallyMeaningful` → author Assertion (W09/W21) + no BellLabs verdict until assessed; any `ASSESSES_APPLICABILITY_TO → UserContext` → deleted from the shared graph after copying to `PersonalApplicabilityAssessment` in the private store (W23); delta `SynthesisInputMetadata.inputRole`/`EvidenceChangeMetadata.effectOnVerdict` Strings → enums (values unchanged); inherited dimension uids with token `applicability` → re-minted `applicability-dimension` uids with a redirect (W00 EquivalenceAssessment) if the 0.2.0 fixture data was ever loaded beyond fixtures.
- Compatibility: `Entity.name` nullable (D-013); W10 types add no `@vector`/`@fulltext`.

## Ingestion overhead

An applicability assessment is 1 + 11 (or 7 for mechanism targets) + 0–2 explanation nodes and roughly 30–40 edges (fixture 01: 13 dimension nodes, 22 dimension SUPPORTED_BY, 2 CONSIDERS, 3 CONSIDERS_ASSESSMENT, measured on the loaded graph). Re-assessment copies all dimensions (immutability), so the write volume is linear in the number of re-reviews; reads use the current-version filter. Syntheses are small (inputs + triggers). The cost is accepted (round 0002 C2-02: a flat property cannot cite or list missing facts).

## Runtime facts found

- `@neo4j/graphql` 7.6.3 needs APOC Core for DateTime projection (`apoc.date.convertFormat`); without it any query selecting a DateTime field fails (consistent with W00 D-W00-17).
- An interface-typed relationship target (`EvidenceAssessmentArchetype`) cannot select `uid` without `... on Entity` (W10-SR-07).
- A union-typed relationship field (`ApplicabilityUseTarget`, `EvidenceTargetTarget`, `SynthesisInputTarget`) with relationship properties (`INCLUDES_RESULT`) builds and resolves under 7.6.3.
