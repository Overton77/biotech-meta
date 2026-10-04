# W23 External private-store interface (no SDL)

Worker W23, run `run-2026-10-04-fable51-01`. Catalog 0.2.0 (`8fb50ff0…84f0`), modules `private_context` and the private part of `recommendation_decisions`; round 0008 (placement C, ACCEPTED); architecture §13. This document is the **contract** for records that live only in the private context store (PCS). None of them is a GraphQL type, a Neo4j label in the shared graph, an enum value of the final schema, or a shared index entry (contract A9, D-012, INV-105, INV-506). An illustrative DDL that makes the contract concrete is `checks/pcs-ddl-sketch.sql` (parser-checked only; not a runtime implementation).

## 1. Placement and capability pins

| Decision | Statement | Evidence |
|---|---|---|
| System of record | A transactional store (PostgreSQL recommended) holds every private-personal record; the shared Neo4j graph holds zero of them. | round 0008 §1 option C; architecture §13 |
| Temporal keys | `PRIMARY KEY (…, period WITHOUT OVERLAPS)` / `UNIQUE (… WITHOUT OVERLAPS)` exist **from PostgreSQL 18** (release 2025-09-25; current minor 18.6 on 2026-10-04). PostgreSQL 17 does not have them. The documented equivalent `EXCLUDE USING gist (key WITH =, period WITH &&)` works on earlier versions with `btree_gist` for scalar columns. A **bitemporal** exclusion (no overlap in both valid and recorded time) is a two-period `EXCLUDE` constraint on any supported version; `WITHOUT OVERLAPS` covers one period and suits a current-belief table. | 03 S-4, S-5, S-6, S-7; X-5 (PG 18.4 grammar accepts, PG 17.7 grammar rejects only the WITHOUT OVERLAPS table) |
| Row isolation | Row-level security, `ENABLE` + `FORCE`, one owner policy per table; with RLS enabled and no policy, PostgreSQL is default-deny. Superusers and BYPASSRLS roles bypass it: the PCS application role has neither. | 03 S-8 |
| Neo4j RBAC | Not the primary control: Enterprise / AuraDB Business Critical / Virtual Dedicated Cloud only; property-based rules introduced in 5.24; DENY fails open on null or misspelled criteria; privileges on not-yet-existing labels/properties are not applied; full-text results are filtered conservatively. Where an Enterprise deployment adds defence in depth, it is written as GRANT allow-lists on `privacyClass = 'PUBLIC'`, never as DENY. | 03 S-1, S-2, S-3 |

## 2. Boundary rules common to every private record

1. **Uid**: `hu:private-<token>:<opaque>` (`conventions.privateUidFormat`); opaque = UUID/ULID, unrelated to any name or account id. The account system maps accounts to `UserContext` outside this contract.
2. **Shared references** are uid columns typed `shared_uid` (format `hu:<token>:<opaque>`, never `hu:private-`), never foreign keys, views, FDW links or replicated rows. Each record that used shared data stores the **recorded-time viewpoint** (`sharedRecordedAt` or `evidenceRecordedAt`) and, where valid time matters, `evidenceValidAt`, plus the `schemaDigest` it was computed against.
3. **Direction of flow**: shared → private is routine (read by uid at a viewpoint). Private → shared happens only through the consented de-identified contribution pipeline (§8.3). A request from the PCS service to the shared graph carries **only shared uids and viewpoint timestamps** (`PrivateContextMode.REFERENCED_BY_UID_ONLY`); private uids, values and fact keys never leave the PCS (fixture 03 `replay-params.json`).
4. **Insert-only**: snapshots, options, criterion values, decisions, context versions, goal versions, adoption versions, measurements, disclosures and tombstones are never updated (INV-507). A change is a new record or a new episode; deletion happens only by erasure (§8.4).
5. **Recorded time** is assigned by the PCS at commit (`transaction_timestamp()`), never backdated; valid time is immutable; null bounds mean unknown (catalog temporal rules apply unchanged).
6. **Tier**: OWNER_PRIVATE is served by the PCS service only, to the owner (and to grantees inside a PERMIT grant episode, §8.1). Operators see counts and private uids through a PCS audit API; nothing private is written to the shared graph or to its indexes.

## 3. Context, goals, measurements

| Record (archetype) | uid token | Fields (type, null) | Shared uid references (expected shared type) | Rules |
|---|---|---|---|---|
| `UserContext` (Entity) | `private-user-context` | `uid`, `createdAt` | none | no name, email, account id |
| `UserContextVersion` (VersionedState) | `private-user-context-version` | `goalVersionUids` (private), `measurementUids` (private), `declaredConditionUids`, `declaredIntakeUids`, `preferenceKeys` (controlled keys), `payloadHash` (sha256), `recordedAt` | `declaredConditionUids` → `Condition`; `declaredIntakeUids` → `ChemicalSubstance` / `IngredientMaterial` / `ProductVariant` | attached by `has_context_version` episodes (bitemporal, EXCLUSIVE per UserContext: two-period EXCLUDE); a new measurement creates a new version and bounds the previous episode exactly like a fact ending |
| `UserGoal` (Entity) / `UserGoalVersion` (VersionedState) | `private-user-goal`, `private-user-goal-version` | `functionalGoalUid`, `outcomeUid`, `metricUid`, `targetValue`, `targetUnitCode` (UCUM), `priority`, `goalStatement` (free text; never indexed by a shared index), `payloadHash` | `FunctionalGoal`, `Outcome`, `Metric`, `Target` | goal versions EXCLUSIVE per goal |
| `PersonalMeasurement` (InformationArtifact) — implements the **DiagnosticResult contract** (W07) by uid columns | `private-personal-measurement` | see mapping below | `Metric`, `LabTest`, `AssayVersion`, `AlgorithmVersion`, `Device`, `MeasurementMethod`, `ReferenceIntervalVersion` | never an `Observation`, never co-labelled, never copied into one (V-524, V-W23-05); forbidden implications [PERSONAL_MEASUREMENT, OBSERVATION], [PERSONAL_MEASUREMENT_OUTSIDE_REFERENCE_RANGE, CONDITION_PRESENT] |
| `PersonalLabReport` (InformationArtifact) | `private-personal-lab-report` | `reportDate`, `issuingLabName` (as printed), `fileObjectRef` (encrypted object storage key), `contentHash`, `recordedAt` | optional `testingLaboratoryUid` → `TestingLaboratory` only when resolved | file bytes outside the database, keyed by the row; erasure destroys the per-user key |

DiagnosticResult contract mapping (W07 interface → PCS column):

| W07 `DiagnosticResult` field | PCS `PersonalMeasurement` column | Note |
|---|---|---|
| `uid`, `id` | `uid` (`hu:private-personal-measurement:…`) | private uid; never in the shared graph |
| `artifactType` | constant `PERSONAL_MEASUREMENT` | |
| `resultKind: DiagnosticResultKind` | `resultKind` ∈ MEASURED, CALCULATED, INFERRED | CALCULATED/INFERRED require `algorithmVersionUid` (INV-303; DDL CHECK) |
| `valueNumber`, `valueString`, `unitCode` | same (UCUM, as reported, never converted in place) | |
| `valueStatus: ResultQualifier` | `resultQualifier` ∈ NUMERIC, BELOW_DETECTION, ABOVE_QUANTIFICATION, NOT_MEASURED, INVALID_SPECIMEN | identical values to W07's enum; `valueNumber` present iff NUMERIC |
| `observedAt` | `effectiveAt` (specimen collection) | null when unknown; ingestion time never substitutes |
| `reportedAt` | `reportedAt` (lab report date) | |
| `producedByAssayVersion` | `assayVersionUid` | relationship becomes a uid column |
| `computedByAlgorithmVersion` | `algorithmVersionUid` | |
| `interpretedWithReferenceIntervalVersion` | `referenceIntervalVersionUids` + `reportedReferenceRangeText` | the interval printed at report time (INV-302) |
| `privacyClass` | not stored as a shared value | private by placement; no PRIVATE_PERSONAL enum value exists (D-012) |
| (catalog extras) | `metricUid`, `labTestUid`, `deviceUid`, `methodUid`, `provenanceKind`, `labReportUid`, `sharedViewpointRecordedAt`, `recordedAt` | comparability (CQ-PC-06) uses shared ComparabilityAssessments looked up by the version uids (CQ-AX-21) |

## 4. Protocols in use (CQ-PR-05, CQ-AX-22)

| Record | uid token | Fields | Shared references | Rules |
|---|---|---|---|---|
| `ProtocolInUse` (Entity) | `private-protocol-in-use` | `uid`, `userContextUid` | none | one per adopted protocol lineage |
| `ProtocolAdoptionVersion` (VersionedState) | `private-protocol-adoption-version` | `adoptedEditionUid`, `payloadHash`, `sharedRecordedAt` | `ProtocolEdition` (W16) | episodes EXCLUSIVE per ProtocolInUse; started/stopped = valid interval; [ADOPTED_PROTOCOL_EDITION, FOLLOWS_ALL_STEPS] forbidden |
| `ProtocolDeviation` (VersionedState) | `private-protocol-deviation` | `stepKey`, `deviationKind` (OMITTED, MODIFIED_DOSE, MODIFIED_TIMING, ADDED_STEP, SUBSTITUTED_PRODUCT), `personalValueNumber`, `personalUnitCode`, `substituteSubjectUid` | `ProtocolStep.stepKey` of the adopted edition; `substituteSubjectUid` → `ProductVariant` / `IngredientMaterial` | review triggers from the edition's `ProtocolAdjustmentRule` are evaluated in the PCS and open `PendingItem {REVIEW_TRIGGERED}`; a public trigger never recommends a private dose change |

## 5. Recommendation decisions and replay (CQ-RC-01…07)

| Record | uid token | Fields | Shared references | Rules |
|---|---|---|---|---|
| `RecommendationRequest` (Occurrence) | `private-recommendation-request` | `requestedAt`, `goalVersionUids`, `intendedUse` | via goal versions | |
| `RecommendationSnapshot` (Occurrence) | `private-recommendation-snapshot` | `decidedAt`, `recordedAt`, `requestUid`, `userContextVersionUid`, **`evidenceRecordedAt` (R)**, **`evidenceValidAt` (V)**, **`schemaDigest`**, `policyVersionUid`, `algorithmVersion`, `catalogVersion`, `intendedUse`, `decisionOutcome`, `rationaleSummary`, `decisionConfidence` + `decisionConfidenceMethod`, `missingFactKeys`, `snapshotHash` | `policyVersionUid` → `PolicyVersion` (kind RECOMMENDATION_RANKING) | insert-only; `evidenceRecordedAt ≤ recordedAt`; `missingFactKeys ⊆ PolicyVersion.requiredFactKeys` (checked in the PCS after fetching the policy's identity fields, Q-DR-5) |
| `RecommendationOption` (InformationArtifact) | `private-recommendation-option` | `subjectUid`, `subjectType`, `disposition` (SELECTED, ALTERNATIVE, REJECTED, BLOCKED), `rank`, `rejectionReason`, `blockingConstraintUids`, `evidenceAssertionUids`, `adjudicationUids`, `applicabilityUids`, `stateUids`, `offerObservationUids` | every list → shared records of the named kind | REJECTED needs a reason; BLOCKED needs constraints and null rank (CQ-RC-06); [SELECTED_IN_SNAPSHOT, USER_CHOSE] forbidden |
| `DecisionCriterionValue` (InformationArtifact) | `private-decision-criterion-value` | `criterionUid`, `valueNumber`, `valueString`, `methodVersion` | `DecisionCriterion` | `methodVersion` equals the criterion's (identity includes it) |
| `UserDecision` (Occurrence) | `private-user-decision` | `decisionKind` (CHOSE, DECLINED, DEFERRED), `optionUid`, `decidedAt` | none | the person's choice, separate from SELECTED |

**Decision replay semantics** (the contract; the shared half is executed in fixture 03):

1. Load the snapshot, its options and the `UserContextVersion` by uid inside the PCS (owner tier).
2. Send to the shared graph only `{evidenceRecordedAt, evidenceValidAt, options[].subjectUid/stateUids/evidenceAssertionUids/adjudicationUids, policyVersionUid}` (shared uids and instants).
3. Shared graph runs the as-of shapes with R = `evidenceRecordedAt`, V = `evidenceValidAt`: edge-level QS-2b for states (Q-DR-1), adjudications reviewed by R (Q-DR-4). **Replay is reproducible iff every `stateUid` is returned and every adjudication verdict matches.** Executed: fv-a1 (200 mg) returned and `reproduced: true` although A1 was corrected on 2026-06-15.
4. Optional comparison run at R = now (Q-DR-2): returns fv-a1c (120 mg), `matchesSnapshot: false`; the snapshot is **never edited**.
5. Corrections after the viewpoint (Q-DR-3) open `PendingItem {pendingKind: EVIDENCE_REVIEW}` in the PCS. "Would the decision differ now" requires re-running the policy (counterfactual; CQ-RC-07 qualification).
6. Policy identity for the owner's explanation (Q-DR-5) returns policy key, version label, payload hash, declared criteria and required fact keys; the policy text itself stays INTERNAL.
7. If a referenced shared uid was merged after the viewpoint, resolve it as in §6 at R first (what was held then) and at now second (what it is called now).

## 6. Uid redirect after a shared merge

- Shared records are append-only: a merged (retired) uid **keeps its node** and stays resolvable; private records holding it are **not rewritten**.
- Resolution is a function of (uid, R): follow accepted redirect records recorded at or before R from the retired uid to the surviving uid (at most 5 hops; cycles are invalid). At the decision viewpoint the PCS sees the uid it held (Q-RD-1: `resolvedUid` = the duplicate, no redirect); at now it sees the survivor (Q-RD-2: redirect `hu:assessment:w23-merge-capsule-dup`, recorded 2026-05-01).
- Required of W00 (W23-SR-06): a directed redirect record. The kernel's `EquivalenceAssessment` is symmetric (`COMPARES_IDENTITIES`, exactly two) and has no "surviving uid" nor a duplicate-record `equivalenceKind`; fixture 04 uses the requested shape `redirectKind: 'DUPLICATE_MERGE'`, `survivingUid`, `retiredUid`. Also V-432 matches `COMPARES` where the catalog edge is `COMPARES_IDENTITIES` (one V-432 row on fixture 04; W23-SR-07).
- The change feed (§7) publishes merges keyed by the retired uid so the PCS can annotate, never rewrite.

## 7. Change feed from the shared graph

Keyed by shared uid: supersession of an assertion or adjudication (with `SUPERSEDES.recordedAt` and kind), new SourceRevisionEvent on a cited source, identity merge (retired → surviving uid), PolicyVersion succession (new version of a `policyKey`). The PCS matches events against uids held by snapshots and opens `PendingItem` records (EVIDENCE_REVIEW, REVIEW_SUGGESTED). The feed carries no private data and is consumed only by the PCS.

## 8. Consent, disclosure, contribution, erasure

### 8.1 SharingGrant and DisclosureEvent (CQ-PC-04, INV-509)

`SharingGrant` (VersionedState, `private-sharing-grant`): `granteeKind` (NAMED_PERSON, CLINICIAN, COACH, BELLLABS_RESEARCH, DEIDENTIFIED_CONTRIBUTION), `granteeRef` (opaque PCS id), `dataCategories`, `recordUids` (optional narrowing), `purpose`, `permittedActions` (VIEW, EXPORT, CONTRIBUTE_DEIDENTIFIED), `decision` (PERMIT, DENY), `payloadHash`; validity = the `has_sharing_grant` episode (NONEXCLUSIVE). Revocation = a new episode bounding `validTo` at the revocation instant, recorded then, never earlier. `DisclosureEvent` (Occurrence, `private-disclosure`): `grantUid`, `occurredAt`, `dataCategories`; the PCS checks in the **same transaction** that a currently recorded PERMIT episode covers the instant and the categories (FHIR R5 Consent shape, SRC-FHIR-R5-CONSENT). [SHARED_WITH_GRANTEE, PUBLISHED] is forbidden.

### 8.2 PendingItem, PurchaseEvent, PersonalApplicabilityAssessment

`PendingItem` (Occurrence): `pendingKind`, `blocksUid` (private or shared), `openedAt`, `expectedBy` (planned), `resolvedAt`, `resolvedByUid`. `PurchaseEvent` (Occurrence): `eventKind` (INTENDED … RETURNED), `occurredAt`, `offerUid` → `Offer`, `productVariantUid` → `ProductVariant`, `packageConfigurationUid` → `PackageConfiguration`, `lotUid` → `ProductLot` (only when the person records it). `PersonalApplicabilityAssessment` (EvidenceAssessment): `sharedApplicabilityUid` → `EvidenceApplicability` (whose use target is a non-personal `UseContextProfile`, never a UserContext; V-524), `userContextVersionUid`, per-dimension matches, `methodVersion`.

### 8.3 Consented de-identified contribution (the only private → shared path)

Requires a PERMIT grant with `CONTRIBUTE_DEIDENTIFIED`. Output meets at least the Safe Harbor benchmark (SRC-HHS-HIPAA-DEID): no direct identifiers, no person-linked date finer than the year, no free-text identifiers. It enters the shared graph as a **source-attributed public record about an anonymous asserter** (W21's ClaimOccurrence with `assertionBasis` PERSONAL_EXPERIENCE asserted by an `AnonymousActor`, or an aggregate), carries `contributionToken` = HMAC(grant uid, PCS secret) for withdrawal, and **never** becomes a `PersonalMeasurement`, an `Observation` linked to a `Person` (`RECORDS`), a `ProtocolResult` posted by a `Person`, or a `CohortParticipant` with a persistent token (V-W23-05/06). Aggregates are released only above a minimum-cell threshold that is still open (OPEN-QUESTIONS P2 item 3). The record shape (Source kind for a contribution, home of `contributionToken`) is an open seam with W21/W00 (W23-SR-13).

### 8.4 Erasure and retention (CQ-PC-05)

Erasure deletes all rows of the person in one transaction (snapshots included: immutability forbids edits, not deletion), writes a content-free `ErasureTombstone` (`subjectKeyHash`, `erasedAt`, `scope`, `propagationStatus`), destroys the per-user data key (backups become unreadable), and publishes the tombstone to every consumer (derived projections regenerate or purge; contributions withdrawn by `contributionToken` unless a documented Art. 17(3) exception applies; SRC-GDPR-ART17, not a legal conclusion). Retention expiry follows a `PolicyVersion` of kind `DATA_RETENTION` (periods are a legal input: OPEN-QUESTIONS P2 item 1).

## 9. Name registry (used by V-520 and V-W23-04)

Private-store labels (must never appear in the shared graph or in a shared index): `UserContext, UserContextVersion, UserGoal, UserGoalVersion, PersonalMeasurement, PersonalLabReport, ProtocolInUse, ProtocolAdoptionVersion, ProtocolDeviation, SharingGrant, DisclosureEvent, PendingItem, PurchaseEvent, PersonalApplicabilityAssessment, ErasureTombstone, RecommendationRequest, RecommendationSnapshot, RecommendationOption, DecisionCriterionValue, UserDecision` (+ fixture-only `PrivateRecord`).

Private-only property names (checked against the live schema and the shared catalog modules on 2026-10-04: none is used by a shared type; `targetValue`, `disposition`, `algorithmVersion`, `catalogVersion`, `stepKey` and other generic names are deliberately **not** listed because shared types use or may use them): `goalVersionUids, measurementUids, declaredConditionUids, declaredIntakeUids, preferenceKeys, goalStatement, personalValueNumber, personalUnitCode, granteeKind, granteeRef, dataCategories, permittedActions, grantUid, subjectKeyHash, userContextVersionUid, evidenceRecordedAt, evidenceValidAt, decisionOutcome, rationaleSummary, decisionConfidence, decisionConfidenceMethod, missingFactKeys, snapshotHash, rejectionReason, blockingConstraintUids, adoptedEditionUid, deviationKind, provenanceKind, reportedReferenceRangeText, labReportUid, issuingLabName, fileObjectRef, optionUid, pendingKind, blocksUid, resolvedByUid, sharedApplicabilityUid, erasedAt, propagationStatus, requestUid, substituteSubjectUid, criterionUid, offerObservationUids`.

## 10. Rights and use policy semantics (coordinated with W22, W00)

- Three distinct things: (a) **what a source states about rights** — W22 `MediaRightsRecord` (licence, holder, attribution, restrictions; null when silent); (b) **what BellLabs permits itself** — a `PolicyVersion` of kind `USE_AUTHORIZATION` with `permittedUseKinds` and a stated effective period (expiry = `effectiveTo`); (c) **what was actually done** — an `Activity` (ANSWER_COMPOSITION, …) that `USED` the records and is `AUTHORIZED_BY {useKind}` one PolicyVersion.
- Unknown rights are not permission: no rights record, NO_STATEMENT_FOUND or AMBIGUOUS never permits; a policy with null `effectiveFrom`, a different kind, a use kind it does not list, or recorded after the use does not authorize (V-W23-07, fixture 13).
- Payload vocabulary is a **BellLabs candidate** (`permittedUseKinds`, effective period; further candidates in 04 §4). **W3C ODRL was not reviewed in this run**; no ODRL alignment is claimed; reviewing it is an open item before the vocabulary is promoted.
- W22's media display/reproduction use has no `UseKind` value today (W23-SR-15).

## 11. Open items

Legal regimes and retention periods (P2-1); PostgreSQL release choice — the contract works on any supported version with `EXCLUDE`, and on 18+ additionally with `WITHOUT OVERLAPS` (P2-2); minimum-cell threshold (P2-3); operator break-glass (P2-6); ad hoc answer logs: if kept, they are private behaviour records in the PCS with their own retention, never `AnswerRecord`s (P2-7); redirect record shape (W23-SR-06); contribution record shape (W23-SR-13).
