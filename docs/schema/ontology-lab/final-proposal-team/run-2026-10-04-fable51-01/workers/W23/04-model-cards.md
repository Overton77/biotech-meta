# W23 04 Model cards

Conventions: types and nullability as in `sdl-fragment.graphql`; "kind" is asserted / observed / calculated / inferred / operational; privacy classes are the final vocabulary `PUBLIC`, `INTERNAL` (stored as those enum names, D-W23-06). Every card's maturity is the proposed maturity for the final schema.

## 1. Node cards

### 1.1 `AnswerRecord`

| Field | Value |
|---|---|
| Meaning | A published answer, recorded once with the viewpoint, schema digest and query shape that produced it, and the uids it cited. Not the answer prose (outside the graph); not an asker log. |
| Archetype, labels, uid token | Occurrence; `["AnswerRecord", "Occurrence"]`; `hu:answer-record:<opaque>` (registered token `AnswerRecord: answer-record`) |
| Module, maturity | access_and_answers; CANDIDATE → PROVISIONAL proposed (K-7 failing case reproduced in fixture 01: Q-AR-3 shows which answer used the later-corrected A1) |
| Privacy | node INTERNAL (V-W23-01a); PUBLIC_ANSWER sees only the reproducibility allow-list (section 6) |
| Identity keys | `uid` (Occurrence uid constraint), `id` = opaque segment (constraint `answer_record_id`); no natural key (two publications of the same text are two occurrences) |
| Lifecycle | insert-only: `@mutation(operations: [CREATE])`; `uid` `@settable(onUpdate: false)`; citations created in the same transaction |

| Property | Type / null | Meaning and value-state semantics | Temporal behaviour | Kind |
|---|---|---|---|---|
| `recordedAsOf` | DateTime! | R passed to the shape; must be ≤ `createdAt` and ≤ `publishedAt` | recorded-time viewpoint, immutable | operational |
| `validAt` | DateTime | V; null = no valid-time filter (never "now"); mutually exclusive with the interval | valid-time viewpoint | operational |
| `intervalStart`, `intervalEnd` | DateTime | half-open valid interval for interval shapes; start < end | valid-time viewpoint | operational |
| `schemaDigest` | String! | `sha256:<hex>` of the admitted canonical schema | fixed | operational |
| `queryShapeId`, `queryShapeVersion` | String!, String | shape id (`QS-2a`) and its version under change control | fixed | operational |
| `accessTier` | AccessTier! | PUBLIC_ANSWER, OPERATOR_AUDIT or AGENT_PROJECTION; never OWNER_PRIVATE | fixed | operational |
| `privateContext` | PrivateContextMode! | always EXCLUDED on a shared record; stored so replay re-issues the identical K-3 request | fixed | operational |
| `traceDepth` | TraceDepth | NONE, LOCATOR, ADJUDICATION; null read as LOCATOR (projection-contract default) | fixed | operational |
| `publishedAt` | DateTime | when published; null = recorded but not yet published | fixed | operational |
| `occurrenceType` | String! | constant `ANSWER_PUBLICATION` | — | operational |
| `startedAt`, `endedAt` | DateTime | composition interval (copied from the composing Activity) | — | operational |
| `mongoResearchRunId` | String | composing run id; INTERNAL field | — | operational |
| Forbidden properties | — | `userUid`, `ownerUid`, `questionText` (V-121) and **any key outside the allow-list** (V-W23-01b: e.g. `askerSessionId`) | — | — |

| Edge | Domain → range | Class, cardinality | Edge properties | Rule |
|---|---|---|---|---|
| `CITES_ASSERTION` | AnswerRecord → `Assertion` (concrete generic type; covers ClaimOccurrence and RelationshipAssertion by label) | structural; many (≥1 unless traceDepth NONE) | `StructuralEdgeProperties.orderIndex` = zero-based cited-sentence ordinal | cited `recordedAt ≤ recordedAsOf`; not superseded at R (V-W23-02); endpoint `:Assertion` (V-W23-03) |
| `CITES_ASSESSMENT` | AnswerRecord → `EvidenceAssessmentArchetype` | structural; many | same | cited `recordedAt ≤ recordedAsOf` (V-W23-02); endpoint `:EvidenceAssessment` |
| `WAS_GENERATED_BY` | AnswerRecord → `Activity` (W00) | structural; zero_or_one (exactly one once W23-SR-02 is ruled) | none | Activity kind ANSWER_COMPOSITION; its `AUTHORIZED_BY {useKind}` carries provenance state 5 |

### 1.2 `PolicyVersion`

| Field | Value |
|---|---|
| Meaning | One immutable version of a BellLabs policy document. Kinds: use/rights authorization (state 5), recommendation ranking and safety, safety review rules, data retention. Not a legal determination, not a person's decision, not a source licence (W22 `MediaRightsRecord` states what a source says about rights; a PolicyVersion states what BellLabs permits itself). |
| Archetype, labels, uid token | VersionedState; `["PolicyVersion", "VersionedState"]`; `hu:policy-version:<opaque>` (alias key `policy-version` exists; primary-label registration requested W23-SR-01) |
| Module, maturity | recommendation_decisions (shared_graph, internal); PROVISIONAL |
| Privacy | INTERNAL (V-W23-08) |
| Identity keys | `uid`; natural key (`policyKey`, `versionLabel`) unique (constraint `policy_version_key_label`); `payloadHash` identifies content |
| Lifecycle | insert-only; a change is a new version; versions of one key never possibly overlap in stated effect (V-W23-08) |

| Property | Type / null | Meaning | Kind |
|---|---|---|---|
| `stateType` | String! | `POLICY_VERSION` | operational |
| `payloadHash` | String! | `sha256:<hex>` over the canonical policy document | calculated |
| `effectiveFrom` | DateTime | stated start; **null fails closed** for authorization (V-W23-07) | asserted (by BellLabs) |
| `effectiveTo` | DateTime | stated expiry; null = not stated (possible overlap for V-W23-08), never "perpetual" | asserted |
| `policyKey` | String! | family key (`answer-use-authorization`) | operational |
| `versionLabel` | String! | `v1`, `v3` | asserted |
| `policyKind` | PolicyKind! (candidate) | what the version governs | asserted |
| `permittedUseKinds` | [UseKind!] (candidate) | USE_AUTHORIZATION: uses permitted; null/empty permits nothing | asserted |
| `requiredFactKeys` | [String!] | RECOMMENDATION_RANKING: fact keys the policy requires (CQ-RC-03) | asserted |

| Edge | Domain → range | Class, cardinality | Edge properties |
|---|---|---|---|
| `DECLARES_CRITERION` (candidate) | PolicyVersion (RECOMMENDATION_RANKING) → DecisionCriterion | structural; many | `StructuralEdgeProperties.orderIndex` (zero-based evaluation order) |
| `AUTHORIZED_BY` (W00, seen from the policy) | Activity → PolicyVersion | structural; many | `AuthorizationProperties.useKind` |
| (referenced by uid, not edges) | private `RecommendationSnapshot.policyVersionUid`; W16 `ProtocolAdjustmentRule.policyVersionUid` | — | — |

### 1.3 `DecisionCriterion`

| Field | Value |
|---|---|
| Meaning | A named, method-versioned criterion a ranking policy evaluates per option. Values for a person are private (`DecisionCriterionValue` in the PCS). |
| Archetype, labels, uid token | Entity; `["DecisionCriterion", "Entity"]`; `hu:decision-criterion:<opaque>` (new token requested W23-SR-01) |
| Module, maturity, privacy | recommendation_decisions (shared_graph, internal); PROVISIONAL; INTERNAL |
| Identity keys | `uid`; (`criterionKey`, `methodVersion`) unique (constraint `decision_criterion_key_method`) |
| Lifecycle | insert-only (`@mutation(operations: [CREATE])`): a new method version is a new criterion so that private values keep one meaning |
| Properties | `entityType` (`DECISION_CRITERION`), `criterionKey` String!, `criterionKind` String! (controlled candidate values APPLICABILITY, SAFETY_BLOCK, EVIDENCE_ASSESSMENT, PRICE, AVAILABILITY, STATED_PREFERENCE), `methodVersion` String! (INV-407), `valueUnitCode` String (UCUM; null when not a quantity) |

## 2. Enum cards (owner W23)

| Enum | Values | Meaning, use | Source |
|---|---|---|---|
| `AccessTier` | PUBLIC_ANSWER, OPERATOR_AUDIT, AGENT_PROJECTION, OWNER_PRIVATE | audience of a projection request; `AnswerRecord.accessTier` (never OWNER_PRIVATE) | projection-contract K-3; competency-questions §1.3 |
| `TraceDepth` | NONE, LOCATOR, ADJUDICATION | how far the trace reaches | K-3 |
| `PrivateContextMode` | EXCLUDED, REFERENCED_BY_UID_ONLY, INCLUDED_FOR_OWNER | K-3 `privateContext`; non-owner tiers require EXCLUDED; REFERENCED_BY_UID_ONLY means only shared uids travel from the PCS to the shared graph | K-3; QS-5a |
| `PolicyKind` (CANDIDATE) | USE_AUTHORIZATION, RECOMMENDATION_RANKING, SAFETY_REVIEW, DATA_RETENTION | what a policy version governs | failing case fixture 13 N1 |

## 3. Relationship-property types

None owned. W23 reuses W00's `StructuralEdgeProperties` (CITES_*, DECLARES_CRITERION) and `AuthorizationProperties` (AUTHORIZED_BY).

## 4. Candidate and rejected elements (not in the fragment unless stated)

| Element | Status | Why |
|---|---|---|
| `Policy` Entity + `HAS_STATE` to versions | REJECTED (smallest model) | no CQ needs policy identity beyond versions; `policyKey` suffices |
| `PolicyVersion.scopeSourceKinds: [SourceKind!]` | CANDIDATE, not in SDL | rights scope by source kind; no failing case yet; legal policy input needed |
| `PolicyVersion.attributionRequired`, quote-length limits | CANDIDATE, not in SDL | no failing case; would duplicate W22 rights fields without a policy corpus |
| criterion role on `DECLARES_CRITERION` (BLOCKING / SCORING / EXPLANATORY) | CANDIDATE | CQ-RC-06 is answered by the private option record (`disposition BLOCKED`, `blockingConstraintUids`); a policy-level role needs a policy corpus |
| `DecisionCriterionKind` enum | CANDIDATE | values unknown until policies exist (D-W23-09) |
| UseKind value for displaying or reproducing media in an answer | REQUEST to W00/W22 (W23-SR-15) | current UseKind (QUOTE, SUMMARIZE, USE_AS_RECOMMENDATION_EVIDENCE, SHARE_EXTERNALLY) has no display/reproduce use for an image |
| PrivateScope marker label (round 0009 K-5) | REJECTED (catalog K-5 revised) | placement plus uid prefix |

## 5. Derived inputs and rules

- PUBLIC reproducibility view of an AnswerRecord = allow-listed fields + cited uids with ordinals (Q-AR-5); regenerable, never stored separately.
- Replay of an AnswerRecord = QS-2a at (`recordedAsOf`, `validAt`) per cited assertion's subject and predicate; "reproduced" iff the same assertion uid is believed at R (Q-AR-1).
- Policy in force for a use = the PolicyVersion named by the Activity's `AUTHORIZED_BY`, admissible iff kind USE_AUTHORIZATION, useKind permitted, `effectiveFrom ≤ startedAt < effectiveTo`, recorded before the use (V-W23-07).

## 6. Projection closure for the final schema

Two rules apply to every tier other than OWNER_PRIVATE, in this order: (1) **type/field allow-list** per tier (table below); (2) **instance allow-list**: a node is admitted to PUBLIC_ANSWER only if `privacyClass = 'PUBLIC'` and its uid does not start with `hu:private-`; OPERATOR_AUDIT and AGENT_PROJECTION admit `PUBLIC` and `INTERNAL`; **null or any other value is never admitted** (fails closed; V-522 reports nulls, V-W23-09 other values). A relationship is admitted only when both endpoints are admitted and its type is in the tier's list. Private-personal modules (`private_context`, the private part of `recommendation_decisions`) are excluded from every shared projection (projection-contract invariant 1; `closurePolicies.access`). Enforcement: compiled queries (QS-5b with the allow-lists substituted) or a generated tier sub-schema (checks/public-subset.mjs builds under 7.6.3 with no INTERNAL type, no mutation, no `privacyClass` or `mongoResearchRunId`); a single raw GraphQL endpoint over the shared database is **not** a PUBLIC_ANSWER surface because SDL cannot filter instances without `@authorization`, which fragments may not use.

| Element | PUBLIC_ANSWER | OPERATOR_AUDIT | AGENT_PROJECTION | OWNER_PRIVATE (shared half, via PCS service) |
|---|---|---|---|---|
| Private-store records and fields (all of private-store-interface.md) | never | counts and private uids only, through the PCS audit API, never written to the shared graph (break-glass undecided: OPEN-QUESTIONS P2 item 6) | never (REFERENCED_BY_UID_ONLY passes shared uids only) | the owner's own records, in the PCS |
| `AnswerRecord` | reproducibility allow-list: `uid, recordedAsOf, validAt, intervalStart, intervalEnd, schemaDigest, queryShapeId, queryShapeVersion, accessTier, traceDepth, publishedAt` + cited uids/ordinals | all fields + lineage | allow-list + create (answer-publication intents) | allow-list |
| `PolicyVersion` | excluded | all | identity and use fields of USE_AUTHORIZATION versions (`uid, policyKey, versionLabel, policyKind, permittedUseKinds, effectiveFrom, effectiveTo`) so an answer-composing agent can cite one | identity fields of the version its own snapshot names (`uid, policyKey, versionLabel, payloadHash, effectiveFrom, effectiveTo`, declared criteria keys, `requiredFactKeys`) |
| `DecisionCriterion` | excluded | all | excluded | `criterionKey`, `methodVersion`, `valueUnitCode` of criteria its snapshot used |
| `Activity` (W00; INTERNAL instances) | excluded | all | the agent's own run (`externalRunId` = its run) | excluded |
| `Agent` (W00) | identity (`uid, name, agentKind`) when it is an asserter; `model, promptVersion, toolVersion` excluded (W23-SR-10) | all | all | identity |
| `Adjudication` (W00) | `adjudicationKind, verdict, reviewedAt, recordedAt, reviewerType, rationale`; reviewer identity edges and `humanReviewPending` excluded (W23-SR-10) | all | all | as PUBLIC_ANSWER |
| `ResolutionHypothesis` (W00) | excluded (open hypotheses are not answers; CQ-AX-15) | all | all (CQ-AX-14) | excluded |
| Assertions by status | as-of-R status ACCEPTED (SUPERSEDED/REJECTED only in explicit history answers, with status returned) | all | all | as PUBLIC_ANSWER |
| `privacyClass` field | filter key only, stripped from output | returned | returned, read-only | stripped |
| `mongoResearchRunId`, `agentRunUid` | excluded | returned | returned and settable on own writes (CQ-AX-15) | excluded |
| `searchText`, `searchFields`, `searchEmbedding`, `embeddingModel`, `embeddingDimensions` | never returned as evidence (INV-107); search used through QS-8 only | returned | returned | excluded |
| `extractionConfidence`, `extractionMethod` | excluded (confidence vector is shown through adjudications and assessments with method versions) | returned | returned | excluded |
| Mutations | none | none (audit) | create/update within the projection slice only (CQ-AX-16 guard) | none on the shared graph |

## 7. `privacyClass` and `mongoResearchRunId` per tier (summary)

- `privacyClass` is a governance field on every node: written by the ingestion service (never defaulted from null to PUBLIC), stored as `PUBLIC` or `INTERNAL`, used as the instance allow-list key, returned only to OPERATOR_AUDIT and AGENT_PROJECTION. W23 types are always INTERNAL.
- `mongoResearchRunId` is operational lineage (maps to `Activity.externalRunId`, V-430): INTERNAL field, never in PUBLIC_ANSWER or OWNER_PRIVATE output.
