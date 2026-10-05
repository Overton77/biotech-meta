# W23 01 Domain recommendation: access, answers, policy and the private-store boundary

Worker W23 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 digest `8fb50ff0…84f0`. Coordinator and synthesizer: Fable 5.1. This packet is a recommendation, not the final schema.

## 1. Boundary in one paragraph

W23 owns what leaves the shared graph and under which rules, and the edge of the graph where private data stops. Inside the shared graph it owns three INTERNAL record types: `AnswerRecord` (a published answer and the viewpoint that reproduces it), `PolicyVersion` (an immutable version of a BellLabs policy: use/rights authorization, recommendation ranking, safety review, retention) and `DecisionCriterion` (a method-versioned criterion a ranking policy evaluates). It owns the access vocabulary (`AccessTier`, `TraceDepth`, `PrivateContextMode`), the citation edges `CITES_ASSERTION` and `CITES_ASSESSMENT`, and the projection closure rules that decide which types, fields and instances each tier may read. Outside the shared graph it owns only a **document**: the external private-context-store interface (`private-store-interface.md`), which defines how private records refer to shared uids at a recorded-time viewpoint, how a decision is replayed, how a merged uid is resolved, and how erasure and consent work. No private-personal type, field, enum value, relationship or uid prefix is defined in SDL (contract A9, D-012).

## 2. Subdomains and canonical modules

| Subdomain | Canonical module (catalog) | What W23 delivers | Not W23's |
|---|---|---|---|
| Published answers and their replay | `access_and_answers` (candidate, K-7) | `AnswerRecord`, `CITES_ASSERTION`, `CITES_ASSESSMENT`, V-121 successor rules | the query shapes themselves (`query-shapes.md`), the answer prose (outside the graph) |
| Access tiers and projection closure | `access_and_answers` + `modules.yaml closurePolicies.access` + `projection-contract.yaml` (K-3) | enums `AccessTier`, `TraceDepth`, `PrivateContextMode`; the tier closure table (04 model cards, section 6) | the projection compiler implementation |
| Shared, internal policy layer | `recommendation_decisions` (shared-graph part, privacyClass internal) | `PolicyVersion`, `DecisionCriterion`, candidate `PolicyKind`, candidate `DECLARES_CRITERION` | `AUTHORIZED_BY` and `UseKind` (W00, provenance), media rights records (W22) |
| Private-store boundary | `private_context`, `recommendation_decisions` (private part); placement `private_context_store` | `private-store-interface.md` (no SDL); leak validators V-W23-04/09/10; the CL-018 public-person-only rule | public `Observation`/`ProtocolResult` (W16), `CohortParticipant` (W01), `ExperienceReport` disposition (W21), `DiagnosticResult` interface (W07), `UseContextProfile` (W10) |

## 3. Identity versus state versus artifact versus occurrence

| Element | Archetype | Why that archetype (and not another) |
|---|---|---|
| `AnswerRecord` | Occurrence | a publication happened once at a time and is never edited; its identity is the event, not the text (prose is outside the graph) |
| `PolicyVersion` | VersionedState | an immutable payload identified by `payloadHash`; a changed policy is a new version; there is no separate enduring `Policy` Entity (section 6) |
| `DecisionCriterion` | Entity | a stable named criterion that many private criterion values refer to by uid; its method version is part of identity, so it is immutable once created |
| Private records (UserContext, PersonalMeasurement, RecommendationSnapshot, SharingGrant, …) | catalog archetypes, **outside** the shared graph | defined as store contracts in `private-store-interface.md`; they never become graph nodes |

## 4. Disposition of every live and catalog element in scope

| Element (origin) | Disposition | Final element | Note |
|---|---|---|---|
| `AnswerRecord` (catalog access_and_answers; proposed-delta lines 67–85) | **keep + refine** | `AnswerRecord` | `accessTier`/`traceDepth` become enums; adds `privateContext`, archetype fields, `privacyClass`; node INTERNAL with a public reproducibility allow-list (D-W23-02); insert-only (`@mutation(operations: [CREATE])`) |
| `CITES_ASSERTION`, `CITES_ASSESSMENT` (catalog) | **keep** | same, structural, `StructuralEdgeProperties.orderIndex` = zero-based cited-sentence ordinal | assertion target is the concrete generic `Assertion` type (D-W23-11) |
| `PolicyVersion` (catalog recommendation_decisions, internal) | **keep + refine** | `PolicyVersion` | adds `policyKey`, `versionLabel`, `policyKind` (candidate enum), `permittedUseKinds` (candidate payload), `requiredFactKeys` |
| `DecisionCriterion` (catalog, internal) | **keep + refine** | `DecisionCriterion` | adds `criterionKey`, `valueUnitCode`; identity = key + method version |
| `AccessTier`, `TraceDepth`, `privateContext` (projection-contract K-3) | **keep** (formalize) | enums `AccessTier`, `TraceDepth`, `PrivateContextMode` | registry assigns them to W23; contract B5 lists AccessTier/TraceDepth as kernel enums (W00 confirmed in its fragment they are W23's) |
| `conventions.privacyClass` `[public, internal, private-personal]` | **refine** (projection of the frozen contract) | `PrivacyClass {PUBLIC INTERNAL}` (W00) | `private-personal` exists only as a private-store marker, never as a shared value; stored casing ruling D-W23-06 |
| `conventions.privateUidFormat` `hu:private-<type>:<opaque>` | **keep** | private-store uid format; leak checks test the prefix | never stored in the shared graph (INV-506) |
| `conventions.privateRecordMarker` (`:PrivateRecord` fixture label) | **keep** as fixture device only | — | W23 fixtures deliberately omit it in the leak probe to simulate production leaks |
| Private catalog nodes: `UserContext`, `UserContextVersion`, `UserGoal`, `UserGoalVersion`, `PersonalMeasurement`, `PersonalLabReport`, `ProtocolInUse`, `ProtocolAdoptionVersion`, `ProtocolDeviation`, `SharingGrant`, `DisclosureEvent`, `PendingItem`, `PurchaseEvent`, `PersonalApplicabilityAssessment`, `ErasureTombstone`, `RecommendationRequest`, `RecommendationSnapshot`, `RecommendationOption`, `DecisionCriterionValue`, `UserDecision` | **move** to external contract (no SDL) | `private-store-interface.md` sections 3–8 | each references shared uids plus a recorded-time viewpoint |
| Private catalog relationships (`HAS_OPTION`, `FOR_REQUEST`, `USED_CONTEXT_VERSION`, `HAS_CRITERION_VALUE`, `RESPONDS_TO`, `HAS_CONTEXT_VERSION`, `HAS_GOAL`, `HAS_GOAL_VERSION`, `HAS_PROTOCOL_IN_USE`, `HAS_ADOPTION_VERSION`, `HAS_DEVIATION`, `HAS_SHARING_GRANT`) | **move** | private-store foreign keys | none crosses the boundary |
| Live `Person.recordsObservations` (`RECORDS`) | **keep, restricted** (owner W16) | asserted `RECORDS` | W23 rule: public persons and source-attributed self-reports only (V-W23-05) |
| Live `Person.postsResults` (`POSTS_RESULT`) | **keep, restricted** (owner W16) | asserted `POSTS_RESULT` | same rule |
| Live `Person.hasParticipantTokens` (`HAS_PARTICIPANT_TOKEN`) | **retire** (owner W01 agrees) | none | re-identification link; live edges deleted, never exported (D-W23-14) |
| Live `CohortParticipant.participantToken` | **keep, restricted** (owner W01) | same + issuer-scoped `Identifier` | the token a public source printed; never a BellLabs/PCS id or linkage hash (V-W23-06) |
| Live `ExperienceReport.reportedBy` (`REPORTS`) | **retire/move** (owner W21: ClaimOccurrence with PERSONAL_EXPERIENCE) | none in final SDL | legacy edges are audited by V-W23-05 until migrated |
| Live `mongoResearchRunId` (every type) | **keep** with tier rule | same | INTERNAL field: OPERATOR_AUDIT and AGENT_PROJECTION only |
| Live `RecommendationMetadata`, `Recommendable`, `Person.recommends` | not W23 (W21, CL-016) | — | source stance, never a BellLabs recommendation (V-523) |
| Live `Dataset.accessLevel`, `DocumentType.POLICY`, `EventCategory.POLICY_EVENT` | not W23 | — | name collisions only: a document of type POLICY (an agency policy) is not a BellLabs `PolicyVersion`; dataset access level is not an `AccessTier` |

## 5. Alternatives considered

1. **Private data in the shared Neo4j graph, isolated by RBAC** (round 0008 option A). Rejected again at this run's pins with primary documentation (03 S-1, S-2, S-3): property-based access control is Enterprise Edition / AuraDB Business Critical / AuraDB Virtual Dedicated Cloud only and was **introduced in 5.24**; Neo4j documents that "a DENY rule fails open when its criteria cannot be evaluated"; privileges naming a label or property that does not yet exist are not applied until it exists; full-text index results under security rules are filtered conservatively. The test target is Community 5.26.31, where none of this exists. RBAC stays defence in depth for Enterprise deployments, written as GRANT allow-lists, never DENY.
2. **A second graph database for private data** (option B). Rejected (round 0008); nothing new.
3. **Persisted private graph projection** (option D). Deferred; a per-request in-memory explanation graph is allowed and never persisted.
4. **AnswerRecord as a PUBLIC node** (property card P-11) versus **INTERNAL** (catalog module). Chosen: INTERNAL node, public reproducibility allow-list (D-W23-02), because run lineage, composition activity and policy links must not leave the operator tier while the reproducibility parameters must reach researchers (CQ-AX-03, tier R).
5. **A `Policy` Entity with `HAS_STATE` to versions.** Rejected as unnecessary: no CQ asks for policy identity beyond its versions; `policyKey` groups versions and V-W23-08 checks non-overlap of stated effect.
6. **Interface-typed citation target (`AssertionArchetype`).** Rejected by execution: under `@neo4j/graphql` 7.6.3 a `ClaimOccurrence` (labels `ClaimOccurrence`, `Assertion`) is returned twice, once as the generic `Assertion` type, through any interface or union whose member label sets nest (checks/label-overlap-probe-result.json). W00 reached the same rule independently (its D-W00-05).
7. **Deny-list instance filter** (`privacyClass <> 'INTERNAL'`, null defaulted to public). Rejected by execution (fixture 13, Q-FO-1 leaks an unclassified PolicyVersion and an unclassified lineage record); the rule is an allow-list on `privacyClass = 'PUBLIC'`.

## 6. Smallest recommended model

- Three INTERNAL node types, three access enums (plus one candidate enum `PolicyKind`), two catalog citation edges, one candidate structural edge (`DECLARES_CRITERION`). No relationship-property type of W23's own (reuses W00's `StructuralEdgeProperties`, `AuthorizationProperties`).
- One projection closure table (04, section 6) with two rules that do most of the work: (a) type/field allow-lists per tier, (b) instance admission only on `privacyClass = 'PUBLIC'` for PUBLIC_ANSWER (null and unknown values fail closed).
- One external document for the private store, with replay and redirect semantics and an illustrative DDL that pins the temporal-key capability to PostgreSQL 18 (`WITHOUT OVERLAPS`) and gives the version-independent `EXCLUDE USING gist` form.
- Ten proposed validators (V-W23-01 … V-W23-10) that close four detection gaps found by execution: an index created before any private node exists (V-115 cannot see it), an upper-case private class with no private uid (V-521 misses it), a private uid inside a list-valued relationship property (V-521 misses it), and a user's private value copied into a public Observation with no private marker at all (no existing V-query sees it; V-W23-05 does).
