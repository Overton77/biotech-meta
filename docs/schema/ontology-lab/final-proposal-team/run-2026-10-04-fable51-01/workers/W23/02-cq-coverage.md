# W23 02 CQ coverage matrix

Priority and answerability are copied from `competency-questions.md` (sections 2, 6, 7). "Fixture/query" names the W23 fixture statement that answers or tests the question (06-fixtures-and-queries.md); "run" means executed on embedded Neo4j 5.26.31 Community on 2026-10-04 with the stated result. Private-store questions are answered by the private-store contract; only their shared half runs in the graph.

## 1. Existing questions

| CQ (priority, ans.) | Example answer (from fixtures) | Distinction | Evidence requirement | Proposed node / property / edge / edge property | Query shape and W23 query | Prevented failure |
|---|---|---|---|---|---|---|
| CQ-AX-01 (Essential, A) | "Sentence 0 → A1 (TEXT_QUOTE 'Magnesium (as magnesium glycinate) 200 mg', snapshot 2026-03-02, hash sha256:fe44…; CAPTURE_FIDELITY SUPPORTED reviewed 2026-03-02); gaps []" | supported vs unsupported vs inferred; capture fidelity vs truth | citations per sentence; locators retrieved by R; adjudications reviewed by R | `AnswerRecord` -`CITES_ASSERTION {orderIndex}`-> `Assertion`; -`CITES_ASSESSMENT`-> assessment; `traceDepth` | QS-1a; Q-AR-4 (run: 1 row, gaps []) | fluent untraceable sentences |
| CQ-AX-02 (Essential, Q) | public answer computed with `privateContext: EXCLUDED`; AnswerRecord carries EXCLUDED | evidence scope vs personal situation | the request's privateContext | `AnswerRecord.privateContext` (always EXCLUDED, V-W23-01a) | QS-5 + V-W23-01a (run: owner-private record reported) | public evidence turned into personal advice; asker context stored in the shared graph |
| CQ-AX-03 (Foundational, Q) | "AR-1: recordedAsOf 2026-04-10T09:00Z, validAt 2026-04-10, schema 8fb50ff0…, QS-2a; replay returns A1/fv-a1, reproduced true; at R=now returns A2/fv-a1c" | published answer vs ad hoc answer; viewpoint R vs V | stored viewpoint, digest, shape id/version; immutable history | `AnswerRecord.recordedAsOf, validAt, intervalStart, intervalEnd, schemaDigest, queryShapeId, queryShapeVersion, accessTier, privateContext, traceDepth, publishedAt`; insert-only | QS-2a; Q-AR-1 and Q-AR-2 (run); V-121, V-W23-01a/b, V-W23-02 | an answer whose viewpoint was never stored; an answer log of askers |
| CQ-AX-11 (Expansion, Q) | "AR-1 depends on A1, superseded by A2 (SOURCE_CORRECTION) on 2026-06-15, after AR-1's viewpoint" | correction vs validity bound; before vs after viewpoint | reverse citation edges; SUPERSEDES.recordedAt | `CITES_ASSERTION` (reverse lookup) | Q-AR-3, Q-AR-3b (run: 1 row) | corrections whose reach cannot be assessed |
| CQ-AX-12 (Essential, A) | "0 shared→private edges, 0 private nodes, 0 indexes over private labels or properties" | property hiding vs path existence; node leak vs index leak vs value leak | graph and index metadata | private-uid prefix; `privacyClass`; V-113…V-116, V-520…V-524, **V-W23-04, V-W23-09, V-W23-10** | QS-6a/6b; Q-L-1…Q-L-4 (run); S3/S3a validator rows | co-interest inference through a private bridge; private text in a shared index; private uid hidden in a list |
| CQ-AX-13 (Essential, Q) | "PUBLIC_ANSWER from A1 reaches 15 nodes, no PolicyVersion, no Activity, no AnswerRecord; OPERATOR_AUDIT reaches the use policy" | schema slice vs data slice; type allow-list vs instance allow-list | tier closure table; `privacyClass` on every instance | closure rules (04 §6); `AccessTier`, `PrivateContextMode`, `TraceDepth` | QS-5b; Q-PP-1/2/3 (run) | an agent or public caller receiving internal or private records |
| CQ-AX-21 (Expansion, Q) | "private store sends AssayVersion uids only" | uid-only reference vs value transfer | uid-only request | `PrivateContextMode.REFERENCED_BY_UID_ONLY`; replay-params.json carries no private uid | Q-DR-1…5 (run with params) | private values sent to the shared side |
| CQ-AX-22 (Expansion, Q) | "adopted edition hu:protocol-edition:… equals the edition the published result used" (computed in the private store) | public edition vs private adoption | adoptedEditionUid in PCS | PCS `ProtocolAdoptionVersion.adoptedEditionUid` (private-store-interface §6) | PCS-side comparison against shared `ProtocolEdition` uid | shared graph learning a person's deviations |
| CQ-AX-28 (Research frontier, X) | "not answerable: no consented cohort data, no re-identification method" | — | — | none (stays out of the graph) | — | aggregation over private histories |
| CQ-RC-01 (Essential, Q) | "SleepWell SELECTED rank 1; CalmRoot REJECTED (INSUFFICIENT_APPLICABILITY); NightCue REJECTED (USER_PREFERENCE)" | selected / alternative / rejected / blocked | option rows | PCS `RecommendationOption`; shared `PolicyVersion`, `DecisionCriterion` | PCS read; Q-DR-5 for policy identity | only the winner recorded |
| CQ-RC-02 (Foundational, Q) | "policy sleep-support-ranking v3 (sha256:0c84…), criteria WEAKEST_APPLICABILITY_DIMENSION@applicability-0.3, SAFETY_BLOCK@safety-block-0.1; evidence A1, cf-a1 at R 2026-04-10T09:00Z" | policy vs algorithm build; evidence version vs current | snapshot fields; policy version and criteria | `PolicyVersion` (+`DECLARES_CRITERION`), `DecisionCriterion` | Q-DR-4, Q-DR-5 (run) | explanations citing current evidence or an unnamed policy |
| CQ-RC-03 (Essential, Q) | "missing facts BASELINE_SERUM_MAGNESIUM, CURRENT_INTAKE_DECLARED are among the policy's required facts" | named missing vs disputed vs unknown unknowns | policy-declared required facts | `PolicyVersion.requiredFactKeys`; PCS `missingFactKeys` (subset test in the PCS) | Q-DR-5 (run) + PCS subset test | false confidence; missing facts not tied to any policy |
| CQ-RC-04 (Foundational, Q) | "replay at R=2026-04-10T09:00Z returns fv-a1 (200 mg) authorized by A1; reproduced true" | viewpoint R and V stored | append-only shared history; stored viewpoint | PCS `evidenceRecordedAt`, `evidenceValidAt`; shared episodes | QS-2b; Q-DR-1 (run) | replay drifting with later corrections |
| CQ-RC-05 (Essential, A) | "host RECOMMENDS NightCue (source); policy SELECTED SleepWell; person CHOSE SleepWell" | source recommendation, policy selection, user decision, assessment | four record kinds | PCS `RecommendationOption.disposition`, `UserDecision`; shared `RECOMMENDS {assertionUid}` (W21) | V-523; PCS records | a host's recommendation presented as BellLabs' |
| CQ-RC-06 (Foundational, Q) | "Option D BLOCKED by hu:constraint:…; rank null" | block vs penalty | constraints and policy | PCS `disposition BLOCKED`, `blockingConstraintUids`; `DecisionCriterion` kind SAFETY_BLOCK | PCS check (DDL CHECK) | a contraindicated option ranked low but shown |
| CQ-RC-07 (Foundational, Q) | "A1 superseded by A2 (SOURCE_CORRECTION, 2026-06-15) after the decision viewpoint → EVIDENCE_REVIEW" | correction vs bounded validity vs new context | SUPERSEDES.recordedAt vs evidenceRecordedAt | change feed by uid; PCS `PendingItem` | Q-DR-2, Q-DR-3 (run) | silently editing or never revisiting old decisions |
| CQ-PC-01 (Essential, A) | "on 2026-04-10 the goal was shorter sleep onset (priority 1)" | public goal concept vs private goal version | PCS goal versions | PCS `UserGoalVersion.functionalGoalUid` | PCS as-of | today's goals explaining old decisions |
| CQ-PC-02 (Essential, A) | "decision used context v1; v2 (2026-05-22) added a serum magnesium result" | context version vs measurement; insert-only | PCS episodes | PCS `UserContextVersion`, `has_context_version` | PCS as-of; EXCLUDE constraint | new measurements rewriting a decision |
| CQ-PC-03 (Foundational, A) | "evidence review open since 2026-06-15" | planned vs actual | PCS events | PCS `PendingItem` | PCS | forgotten follow-ups |
| CQ-PC-04 (Essential, A) | "coach may VIEW snapshots 2026-04-12 to 2026-07-12; one disclosure 2026-04-20" | view vs export vs contribute; revocation never backdated | grants and disclosures | PCS `SharingGrant`, `DisclosureEvent` (INV-509) | PCS transactional check | disclosure without a grant |
| CQ-PC-05 (Foundational, Q) | "erased 2026-09-01; 4 projections purged; 1 contribution withdrawn" | delete vs tombstone | propagation acks | PCS `ErasureTombstone`; contribution token; `PolicyVersion` of kind DATA_RETENTION for retention | PCS | orphan copies after erasure |
| CQ-PC-06 (Expansion, Q) | "results comparable only if same AssayVersion or a COMPARABLE assessment" | — | W07 comparability | PCS `PersonalMeasurement.assayVersionUid` against shared ComparabilityAssessment | PCS + shared uid lookup | trend across non-comparable assays |
| CQ-PC-07 (Expansion, Q) | "ORDERED 2026-04-10, DELIVERED 2026-04-14" | lifecycle kinds | PCS events | PCS `PurchaseEvent` | PCS | — |
| CQ-PC-08 (Essential, A) | "zero private nodes, zero private uid values, zero private indexes in the shared graph" | placement vs access control | validation runs | INV-506; V-520…V-524; V-W23-04, -09, -10, -05 | S1 (zero rows), S3/S3a/S4 (rows reported) | leaks through traversal, search indexes, mislabeled nodes, copied values |
| CQ-PR-05 (Foundational, A) | "edition 2 since 2026-04-15 with modified bedtime timing" | public edition vs private adoption | PCS adoption episodes | PCS `ProtocolInUse`, `ProtocolAdoptionVersion`, `ProtocolDeviation` | PCS as-of | public protocol node gaining personal edges |

## 2. Candidate questions (not existing ids)

| Id (candidate) | Question | Rationale and failing case | Elements | Query |
|---|---|---|---|---|
| CQ-AX-C01 | For a published or composed answer, which downstream use of which record was authorized, by which policy version, and was that version in effect and of the right kind when the use happened? | V-429 only checks that some PolicyVersion with some useKind exists; fixture 13 N1 (quote under a ranking policy) and N2 (after expiry) pass V-429 (run). Needed for provenance state 5 and for W22 rights (a rights record is never permission). | `PolicyVersion.policyKind`, `permittedUseKinds`, `effectiveFrom/To`; `AUTHORIZED_BY {useKind}` (W00) | V-W23-07 (run: 3 rows on fixture 13) |
| CQ-AX-C02 | Can any shared index, property value or edge expose private data even when no private node exists? | V-115/V-116 are node-based: an index over a private label/property created before any private node exists is invisible to them (S3a run: V-115 0 rows, V-W23-04 1 row); V-521 misses upper-case class-only leaks and list-valued relationship properties (S3 run). | registry of private-store labels and private-only property names (private-store-interface §9) | V-W23-04, V-W23-09, V-W23-10 |

## 3. Every SDL element mapped

| SDL element | CQ / invariant / failure |
|---|---|
| `AnswerRecord` (type) | CQ-AX-03, CQ-AX-01, CQ-AX-11; K-7 |
| `.uid`, `.id`, `.name`, `.description`, `.createdAt`, `.updatedAt`, `.maturity`, `.schemaVersion` | contract B2 skeleton; INV-001, INV-106 |
| `.mongoResearchRunId` | contract B2; CQ-AX-09 (operator tier only) |
| `.privacyClass` | INV-506 closure; V-W23-01a |
| `.occurrenceType`, `.startedAt`, `.endedAt` | baseArchetypes.Occurrence |
| `.recordedAsOf`, `.validAt`, `.intervalStart`, `.intervalEnd` | CQ-AX-03, QS-2 parameters; V-121, V-W23-02 |
| `.schemaDigest`, `.queryShapeId`, `.queryShapeVersion` | CQ-AX-03; V-121 |
| `.accessTier`, `.privateContext`, `.traceDepth` | K-3; CQ-AX-02, CQ-AX-13; V-W23-01a |
| `.publishedAt` | CQ-AX-03; V-W23-02 |
| `.citesAssertions` (`CITES_ASSERTION`) | CQ-AX-01, CQ-AX-11; V-W23-02, V-W23-03 |
| `.citesAssessments` (`CITES_ASSESSMENT`) | CQ-AX-01 (traceDepth ADJUDICATION); V-W23-02 |
| `.generatedBy` (`WAS_GENERATED_BY`) | provenance states 4–5; CQ-AX-C01; V-W23-03b |
| `PolicyVersion` (type) | CQ-RC-02, CQ-RC-04, CQ-AX-C01, CQ-PC-05 |
| `.stateType`, `.payloadHash`, `.effectiveFrom`, `.effectiveTo` | baseArchetypes.VersionedState; expiry (CQ-AX-C01); V-W23-07/08 |
| `.policyKey`, `.versionLabel` | CQ-RC-02 (name the version); V-W23-08; constraint policy_version_key_label |
| `.policyKind` (candidate enum `PolicyKind`) | CQ-AX-C01 failing case (fixture 13 N1) |
| `.permittedUseKinds` (candidate payload) | CQ-AX-C01; V-W23-07 |
| `.requiredFactKeys` | CQ-RC-03 |
| `.declaresCriteria` (`DECLARES_CRITERION`, candidate) | CQ-RC-02; V-W23-08 |
| `.authorizedActivities` (`AUTHORIZED_BY` in) | provenance state 5; V-429, V-W23-07 |
| `DecisionCriterion` (type), `.entityType`, `.criterionKey`, `.criterionKind`, `.methodVersion`, `.valueUnitCode`, `.declaredByPolicyVersions` | CQ-RC-01, CQ-RC-02, CQ-RC-06; INV-407 (every value names its method) |
| `AccessTier`, `TraceDepth`, `PrivateContextMode` | K-3; projection-contract invariant 1 |
| `PolicyKind` | CQ-AX-C01 (candidate; W23-SR-05) |
