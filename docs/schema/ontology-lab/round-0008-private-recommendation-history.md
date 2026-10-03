# Round 0008: Private User Context and Recommendation History

> **Integration decision (2026-10-03):** `ACCEPTED`. Placement: transactional private context store (PostgreSQL recommended) as system of record, zero private nodes in the shared graph. Observation stays public in protocols; PersonalMeasurement is private. ASSESSES_APPLICABILITY_TO loses UserContext in favour of UseContextProfile. RecommendationSnapshot and RecommendationOption replace the 0.1.0 names. Catalog 0.2.0; see [proposal-index.md](./proposal-index.md).


Status recommended by Lane 5: `ACCEPTED` for the placement decision (private context store as system of record, zero private nodes in the shared graph), the `RecommendationSnapshot` contract, the `Observation` ownership decision, and the `ProtocolEdition` / `ProtocolInUse` split. `OPEN` for the cross-lane items listed under "Residual uncertainty". The coordinator sets the final status.

## Header

- Round ID: 0008
- Date: 2026-10-03
- Builder: Lane 5
- Challenger: Lane 5 internal challenger; review requested from Lane 1 (access tiers), Lane 3 (`Metric`, `LabTest`, `Device`, diagnostics ownership of `Observation`), Lane 6
- Owning modules: `recommendation_decisions` (changed), `private_context` (new), `protocols` (new, public)
- Candidate schema version: 0.2.0
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` 0.1.0 sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status: `ACCEPTED` (set by the integration owner on 2026-10-03; the lane recommendation is preserved below)

## Intent and competency questions

- Decision or workflow being supported: record why BellLabs recommended, rejected, or blocked options for one person, replay that decision later with the person's context and the evidence exactly as they were, and keep everything about the person out of the shared world model.
- In scope: physical placement of private data; owner of each private category; sync and deletion propagation; `RecommendationSnapshot`; `UserContext` and its versions; consent / sharing grants; pending items; purchase lifecycle; public `Protocol` versus private `ProtocolInUse`; protocol version differences, step requirement levels, dependencies, evaluation gaps, review triggers; ownership of live `Observation`.
- Out of scope: ranking algorithms, clinical decision support, account and authentication systems, legal determinations about which regimes (HIPAA, GDPR) apply to BellLabs. Regulations are used as design benchmarks, not legal conclusions.
- Competency question IDs: `CQ-PC-01` to `CQ-PC-08`, `CQ-PR-01` to `CQ-PR-06`, `CQ-RC-01` (extended), `CQ-RC-02`, `CQ-RC-04`, `CQ-RC-05`, `CQ-RC-06`, `CQ-RC-07`.

## Case packet

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| Neo4j Operations Manual, "Property-based access control" (SRC-NEO4J-PBAC) | vendor documentation | page header edition badges; "Each property-based privilege can only be restricted by a single property"; "ensure the property used for the rule cannot be modified"; "A DENY rule fails open when its criteria cannot be evaluated"; "Sharded property databases do not support property-based access control" | observed 2026-10-03 via extraction tool (direct fetch blocked) | what Neo4j RBAC can enforce and in which editions (Enterprise Edition, AuraDB Business Critical, AuraDB Virtual Dedicated Cloud) |
| Neo4j Operations Manual, "Limitations" (security) (SRC-NEO4J-RBAC-LIMITATIONS) | vendor documentation | section "Fail-open DENY behavior"; full-text and vector index results under security rules | observed 2026-10-03 | known leak modes of label and property restrictions |
| Neo4j Operations Manual, "Role-based access control" (SRC-NEO4J-RBAC) | vendor documentation | privilege qualifiers (`READ {property}`, `SET LABEL`) and edition badges | observed 2026-10-03 | RBAC is not in Community Edition |
| HL7 FHIR R5 Consent (SRC-FHIR-R5-CONSENT) | interoperability standard | `Consent.status` (draft, active, inactive, not-done, entered-in-error, unknown); resource definition "permit or deny recipients or roles to perform actions for specific purposes and periods of time" | FHIR v5.0.0; observed 2026-10-03 | shape of a computable grant: decision, actor, action, purpose, period, data |
| HL7 FHIR R5 Provenance (SRC-FHIR-R5-PROVENANCE) | interoperability standard | `occurred[x]`, `recorded`, `policy`, `authorization`, `entity.role` | observed 2026-10-03 | separation of activity time and record time; policy and authorization references |
| HL7 FHIR R5 CarePlan (SRC-FHIR-R5-CAREPLAN) | interoperability standard | `instantiatesCanonical` (PlanDefinition and others), `instantiatesUri`, `replaces`, `status` | observed 2026-10-03 | a person's plan instantiates a versioned public definition; this is the `ProtocolInUse` to `ProtocolEdition` pattern |
| GDPR Art. 17 (SRC-GDPR-ART17) | regulation text | para. 1 grounds; para. 2 "take reasonable steps ... to inform controllers which are processing the personal data"; para. 3 exceptions incl. (c) public health and (d) research per Art. 89(1) | observed 2026-10-03 | erasure must propagate to copies and links; exceptions exist |
| HHS guidance on HIPAA de-identification (SRC-HHS-HIPAA-DEID) | regulator guidance | Safe Harbor: "Elements of dates that are not permitted ... include the day, month, and any other information that is more specific than the year"; identifiers in free text must also be removed; "actual knowledge" provision | observed 2026-10-03 | what de-identified data may contain; dates tied to a person are identifiers |
| protocols.io, Teytelman et al., PLoS Biol 2016, PMID 27547938 (SRC-PROTOCOLS-IO-VERSIONING) | peer-reviewed platform description | "Once published, a protocol cannot be edited or removed, but authors can easily create new versions"; forks link to the original | 2016 | an explicitly versioned public protocol source |
| Bryan Johnson, "Bryan Johnson's Protocol" page (SRC-BLUEPRINT-PROTOCOL-PAGE) | individual's public protocol page | sections "Protocols" (Sleep, Exercise, Nutrition, ..., Female protocol, Pregnancy, Measurement), "Other Advanced Therapies" (incl. "Rx / Prescriptions"), "Routine Measurement" ("Blood draw, every 3 to 6 months"; "Full body MRI annually (if over 40 or a family history of high risk)") | observed 2026-10-03 via extraction tool; no version label or changelog seen in the extracted text (unverified whether the rendered page shows one) | what the page displays at observation time; not prior versions; not efficacy |
| NAD.com news, "Aging Guru Bryan Johnson's Supplement List for 2026" (SRC-NADCOM-JOHNSON-2026) | third-party news report | key points: NMN or NR six days a week rather than seven; rapamycin stopped in 2024; low-dose lithium and NDGA added | observed 2026-10-03 | that a third party reported these changes; not the protocol owner's own changelog |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "Bryan Johnson's Protocol" page | `Protocol` (public, live type) with `ProtocolEdition` per observed content state | `hu:protocol:bryan-johnson-blueprint` (proposed) | URL only | candidate | one URL, content changes in place |
| "rapamycin, which he stopped in 2024" | third-party `Assertion` about a step ending (validTo 2024, precision YEAR, basis STATED_BY_SOURCE of a third party) | n/a | n/a | candidate | not an edition; the page itself is not the source of this change |
| protocols.io "version 2" of a protocol | `ProtocolEdition` with `editionLabel` from the source | per DOI | DOI per version | rule | explicit, immutable versions |
| "if over 40 or a family history of high risk" | `ProtocolStep.requirementLevel = CONDITIONAL` with `Constraint` (`POPULATION`, `CONDITION_PRESENT`) | n/a | n/a | rule | conditional step |
| "Blood draw, every 3 to 6 months" | `MeasurementPlan` (`planTiming: PERIODIC`) | n/a | n/a | rule | measurement plan, not a person's measurement |
| "biomarkers: resting heart rate: elite athlete level" (public figure's own report) | live `Observation` (public, source-attributed) | n/a | n/a | rule | a public statement about a public person; never a `PersonalMeasurement` |
| a user's uploaded lab value | `PersonalMeasurement` (private store) referencing `Metric` by uid | `hu:private-personal-measurement:...` | LOINC via `Metric` | rule | private |

## Cooperative-adversarial dialogue

**Builder:** The shared world model must never contain a person's goals, measurements, decisions, consents, or purchases. I propose the private context store (PCS), a transactional database, as the system of record for every private category, and zero private nodes in the shared Neo4j graph. Private records reference shared things by uid and carry the recorded-time viewpoint of the shared graph they used.

**Challenger:** Neo4j Enterprise has label and property-level privileges. Keep everything in one graph, label private nodes, deny them to public roles, and traversal replay is trivial.

**Builder:** Three documented properties of that mechanism fail our requirement. First, it is an Enterprise / AuraDB Business Critical feature, so the isolation disappears in any Community or development deployment. Second, Neo4j documents that a DENY rule "fails open when its criteria cannot be evaluated": a null or misspelled property in a deny rule exposes the data if a broader grant exists. Third, property-based rules use a single property that must never be modified. Our failure mode is a single mislabeled node becoming reachable from a public traversal. The live schema also gives public paths directly into the types a private measurement would use: `ProtocolResult -[:INCLUDES_OBSERVATION]-> Observation`, `Person -[:RECORDS]-> Observation`, and `Observation` is a member of the `MediaSubject` union that `RelationshipAssertion` and media edges target. Isolation by configuration is one mistake away from a leak; isolation by placement is not.

**Challenger:** Then use a second Neo4j database. You keep graph replay.

**Builder:** The private data is record-shaped: one person's versions, measurements, options, grants. Its hard requirements are row-level isolation, transactional consent checks before every disclosure, temporal exclusion of overlapping context versions, and erasure with backup handling. A transactional store does those natively: PostgreSQL row-level security, and SQL:2011-style `WITHOUT OVERLAPS` temporal keys (round 0007 source). A second graph adds a second graph operation without solving erasure. Graph-shaped explanation can be rendered per request from the snapshot's uids against the shared graph, then discarded.

**Challenger:** A recommendation snapshot stores evidence uids. When the shared assertion is corrected, the uid now points to a superseded assertion. Your replay shows the corrected value.

**Builder:** The snapshot stores `evidenceRecordedAt`. Replay runs the round 0007 as-of query with `R = evidenceRecordedAt`, which returns the superseded assertion as it was held then. Shared records are append-only, so the uid always resolves. The fixture demonstrates this with a correction recorded after the decision.

**Challenger:** The person uploads a new lab value a month later. The decision looks wrong in hindsight. Why not update the snapshot's context so explanations are current?

**Builder:** Because the question "what did we know when we recommended this" is then unanswerable, and the explanation would claim knowledge we did not have. The new measurement creates a new `UserContextVersion`. The old snapshot keeps its `userContextVersionUid`. If the new context would change the decision, the system opens a `PendingItem` of kind `REVIEW_SUGGESTED` and, if the person asks, a new snapshot is made. The old one is never edited.

**Challenger:** Immutability conflicts with the right to erasure.

**Builder:** Immutability forbids edits; it does not forbid deletion of the whole record. Erasure deletes the person's rows (snapshots included), leaves a content-free `ErasureTombstone` for propagation, and triggers regeneration or purge of every derived projection. GDPR Art. 17(2) asks the controller to take reasonable steps to inform others processing copies; for BellLabs that means every downstream projection and any consented contribution.

**Challenger:** The live schema already has `Person -[:RECOMMENDS {strength, confidence}]-> Recommendable`. Is that the recommendation record?

**Builder:** No. It records that a person, as a source, recommends something (a podcast guest recommending a product). That is CQ-RC-05's "a source recommends". A BellLabs recommendation is an occurrence in the private store. A `Product -[:RECOMMENDED_FOR]-> Goal` edge stays forbidden: it has no person, no time, no evidence version, no policy.

**Challenger:** `Observation` already exists. Why add `PersonalMeasurement` instead of labeling private observations?

**Builder:** Explicit ownership decision below: live `Observation` stays a public, protocol-linked, source-attributed type. Private measurements are `PersonalMeasurement` rows in the PCS that reference `Metric`, `LabTest`, `Device`, and `MeasurementMethod` by uid. The rejected alternative (private observations as labeled `Observation` nodes with RBAC) fails on the three reasons above plus the public edges listed.

**Challenger:** The public protocol page changes in place and has no changelog. "What changed between versions" is unanswerable.

**Builder:** It is answerable with qualifications. Every observed content state becomes a `ProtocolEdition` (new edition when `payloadHash` changes) attached by a bitemporal episode. Differences are a derived diff over `stepKey` and step `payloadHash`. Where the owner publishes versions (protocols.io), editions map one to one. Where only a third party reports a change (rapamycin stopped in 2024), that is an `Assertion` about the protocol with its own source and valid time, not an edition. The answer labels each change `SOURCE_VERSIONED`, `SNAPSHOT_DIFF`, or `THIRD_PARTY_REPORTED`, and states that changes between unobserved states are unknown.

## Builder proposal

### 1. Placement: options compared

| Criterion | A. Shared Neo4j with RBAC isolation | B. Separate graph database | C. Transactional private store (PCS) plus uid references | D. Hybrid (C as record, plus persisted private graph projection) |
|---|---|---|---|---|
| Isolation mechanism | labels, property rules, roles (Enterprise only) | database boundary | database boundary plus row-level security | as C, plus a second copy |
| Documented leak modes | DENY fails open on null or misspelled criteria; rule property must be immutable; one mislabeled node is reachable | cross-database query tooling (composite databases) can re-join | application bugs; mitigated by no shared-graph presence | as C plus projection staleness |
| Community / dev deployments | no isolation | isolation holds | isolation holds | isolation holds |
| Temporal exclusion of context versions | service-enforced only | service-enforced only | native (`WITHOUT OVERLAPS` temporal keys) | native in C |
| Consent check before disclosure | service plus RBAC | service | transactional, same store as grants | as C |
| Erasure and backup handling | node deletion inside a shared store; backups mix public and private | per-database | per-user rows; per-user encryption key enables crypto-shredding of backups | must purge projection too |
| Replay of decisions | direct traversal | cross-database join by uid | as-of query on shared graph with stored viewpoint | direct traversal on projection |
| Operational cost | lowest | second graph to run | standard OLTP | highest |

Recommendation: **C, the private context store**, as the single initial placement. The shared Neo4j graph holds no private-personal nodes, properties, or edges. A per-request, in-memory explanation graph may be assembled from PCS rows and shared nodes fetched by uid; it is never persisted (this keeps D available later as an Expansion without changing the record). PostgreSQL is the recommended engine because row-level security and temporal keys are native. The live schema's `mongoResearchRunId` shows MongoDB is used for research runs; that store is not a private-data store and must not receive private records.

### 2. Owner of each private data category

| Category | System of record | Catalog term(s) | Owning module | Shared references (uid only) |
|---|---|---|---|---|
| Goals | PCS | `UserGoal`, `UserGoalVersion` | `private_context` | `FunctionalGoal`, `Outcome`, `Metric`, `Target` |
| Personal context versions | PCS | `UserContext`, `UserContextVersion` (attached by `HAS_CONTEXT_VERSION`, EXCLUSIVE) | `private_context` | `Condition`, `ChemicalSubstance`, `IngredientMaterial` for declared conditions and current intake |
| Measurements and lab reports | PCS (files in encrypted object storage keyed by PCS row) | `PersonalMeasurement`, `PersonalLabReport` | `private_context` | `Metric`, `LabTest`, `Device`, `MeasurementMethod`, `ReferenceRange` |
| Protocol in use | PCS | `ProtocolInUse`, `ProtocolAdoptionVersion` (attached by `HAS_ADOPTION_VERSION`, EXCLUSIVE), `ProtocolDeviation` | `private_context` | `ProtocolEdition`, `ProtocolStep` (`stepKey`) |
| Recommendation snapshots | PCS | `RecommendationRequest`, `RecommendationSnapshot`, `RecommendationOption`, `DecisionCriterionValue`, `UserDecision` | `recommendation_decisions` | every evidence, state, offer, and policy uid |
| Policy and criteria definitions | shared graph (privacy class `internal`) | `PolicyVersion`, `DecisionCriterion` | `recommendation_decisions` | n/a (they contain no personal data) |
| Consent and sharing grants | PCS | `SharingGrant` (attached by `HAS_SHARING_GRANT`, NONEXCLUSIVE), `DisclosureEvent` | `private_context` | none |
| Purchase lifecycle | PCS | `PurchaseEvent` | `private_context` | `Offer`, `ProductVariant`, `PackageConfiguration`, `ProductLot` |
| Pending items | PCS | `PendingItem` | `private_context` | any shared uid the item waits on (for example an expected `Publication`) |
| Person-specific applicability | PCS | `PersonalApplicabilityAssessment` | `private_context` | shared `EvidenceApplicability` uid |
| Erasure tombstones | PCS | `ErasureTombstone` | `private_context` | none |

Change to the catalog this forces: `ASSESSES_APPLICABILITY_TO` loses `UserContext` from its range (`# CHANGE`). A shared `EvidenceApplicability` pointing at a `UserContext` is a public node linked to a private one. Shared applicability targets a non-personal `UseContextProfile` (population, dose, duration descriptor); the person-specific match is a private `PersonalApplicabilityAssessment`.

### 3. Sync and deletion

Direction shared to private (the only routine direction):

1. PCS stores shared uids, `evidenceRecordedAt` (system-time viewpoint), `evidenceValidAt` (domain-time viewpoint), state `payloadHash` values used, and `catalogVersion`.
2. Shared records are append-only (round 0007), so a stored uid always resolves. Identity merges in the shared graph leave a redirect owned by `identity_resolution` (requested of that module; not defined here).
3. When the shared graph supersedes an assertion, adjudication, or source referenced by any snapshot, a change feed keyed by uid lets the PCS open `PendingItem {pendingKind: 'EVIDENCE_REVIEW'}` for affected snapshots (CQ-RC-07). Snapshots are not edited.

Direction private to shared (exceptional, consent-gated):

1. Only through a publication pipeline that requires an active `SharingGrant` with `permittedActions` containing `CONTRIBUTE_DEIDENTIFIED`.
2. Output is de-identified to at least the Safe Harbor benchmark: no direct identifiers, no dates more specific than the year for events tied to the person, no free-text identifiers. Output enters the shared graph as a source-attributed record (for example an `ExperienceReport` or an aggregate), never as a `PersonalMeasurement`.
3. The shared record carries `contributionToken` = HMAC(grant uid, PCS secret). The shared graph cannot recover the person; the PCS can find and withdraw the contribution on revocation or erasure.

Deletion and retention:

| Event | PCS action | Derived projections | Shared graph |
|---|---|---|---|
| Grant revoked | new grant episode with `validTo` = revocation time, recorded now (never backdated); disclosures already made stay logged | caches built under the grant purged | contributions under the grant withdrawn by `contributionToken` unless a documented Art. 17(3) exception applies |
| Erasure request | delete all rows for the person including snapshots; keep `ErasureTombstone {subjectKeyHash, erasedAt, scope, propagationStatus}`; destroy the per-user data key so backups become unreadable | every consumer subscribes to the tombstone feed and regenerates or purges; completion recorded in `propagationStatus` | as for revocation |
| Retention expiry (per category, policy-versioned) | delete or aggregate | regenerate | none |

"New measurements do not rewrite earlier decisions" and "erasure deletes earlier decisions" are compatible: the first forbids edits, the second removes the whole record with a tombstone.

### 4. `RecommendationSnapshot` (decision occurrence)

Archetype `Occurrence`; privacy class `private-personal`; insert-only.

| Field | Meaning |
|---|---|
| `uid` | `hu:private-recommendation-snapshot:<opaque>` |
| `decidedAt` | when the decision was computed |
| `recordedAt` | when the snapshot was committed (service time) |
| `requestUid` | the `RecommendationRequest` (what was asked, by whom, for which goal) |
| `userContextVersionUid` | the exact `UserContextVersion` used |
| `evidenceRecordedAt`, `evidenceValidAt` | the shared-graph viewpoint (round 0007 as-of parameters `R` and `V`) |
| `policyVersionUid`, `algorithmVersion` | the ranking and safety policy version (shared, internal) and the code or model build that applied it |
| `catalogVersion` | catalog semantic version in force |
| `intendedUse` | `INFORMATIONAL_COMPARISON`, `PURCHASE_DECISION_SUPPORT`, `PROTOCOL_ADJUSTMENT_REVIEW`, `DISCUSS_WITH_CLINICIAN` |
| `decisionOutcome` | `RECOMMENDED_ONE`, `RECOMMENDED_SEVERAL`, `RECOMMENDED_NONE`, `BLOCKED_BY_CONSTRAINT`, `INSUFFICIENT_EVIDENCE` |
| `rationaleSummary` | human-readable explanation generated at decision time; explanation only, never filtered on |
| `decisionConfidence`, `decisionConfidenceMethod` | the decision dimension of the confidence vector, with method version |
| `missingFactKeys` | controlled keys of facts whose absence could change the ranking (CQ-RC-03) |
| `snapshotHash` | sha256 of the canonicalized snapshot and its options, written at commit |

`RecommendationOption` (one per option considered; insert-only in the same transaction):

| Field | Meaning |
|---|---|
| `subjectUid`, `subjectType` | the shared thing considered (`ProductVariant`, `ProtocolEdition`, `Offer`, or any `Recommendable` member) |
| `disposition` | `SELECTED` (recommended by policy), `ALTERNATIVE`, `REJECTED`, `BLOCKED` |
| `rank` | position among non-blocked options; null for blocked |
| `rejectionReason` | `INSUFFICIENT_APPLICABILITY`, `SAFETY_CONSTRAINT`, `USER_PREFERENCE`, `PRICE`, `AVAILABILITY`, `DOMINATED_BY_SELECTED` (required when `REJECTED`) |
| `blockingConstraintUids` | the constraints that blocked eligibility (required when `BLOCKED`; CQ-RC-06: a block, not a score) |
| `evidenceAssertionUids`, `adjudicationUids`, `applicabilityUids`, `stateUids`, `offerObservationUids` | the evidence versions used |
| criterion values | `DecisionCriterionValue` rows: `criterionUid`, value, method version |

`UserDecision` (separate occurrence): `decisionKind` `CHOSE`, `DECLINED`, `DEFERRED`; `optionUid`; `decidedAt`. "BellLabs selected" and "the person chose" stay distinct (CQ-RC-05).

Replay rule: given a snapshot, (1) load the `UserContextVersion` by uid; (2) for each evidence uid, run the round 0007 as-of query with `R = evidenceRecordedAt`, `V = evidenceValidAt`; (3) the replay must reproduce `stateUids` and adjudication verdicts; (4) a comparison run at `R = now` lists what changed since.

Mapping to the existing candidate module (`# CHANGE` in `modules.yaml` and starter-property-model.md): `RecommendationDecision` becomes `RecommendationSnapshot`; `RecommendationCandidate` becomes `RecommendationOption`; `DecisionContext` is replaced by `userContextVersionUid` plus the two viewpoint fields; `DecisionExplanation` is folded into `rationaleSummary` and `DecisionCriterionValue`; `PolicyVersion` and `DecisionCriterion` stay (shared, internal).

### 5. `UserContext`, versions, grants, pending items, purchases

- `UserContext` (`Entity`, private): one per person; `uid` `hu:private-user-context:<opaque>`; no name, email, or account id (the account system maps accounts to it; out of scope). Other lanes reference it by uid only.
- `UserContextVersion` (`VersionedState`, private, immutable): `goalVersionUids`, `measurementUids`, `declaredConditionUids`, `declaredIntakeUids`, `preferenceKeys`, `payloadHash`. Attached by `HAS_CONTEXT_VERSION` with the round 0007 bitemporal profile, `EXCLUSIVE` per `UserContext`. A new measurement creates a new version; the prior version's episode is bounded by a new episode, exactly like a fact ending.
- `SharingGrant` (`VersionedState`, private): `granteeKind` (`NAMED_PERSON`, `CLINICIAN`, `COACH`, `BELLLABS_RESEARCH`, `DEIDENTIFIED_CONTRIBUTION`), `granteeRef` (opaque PCS id), `dataCategories`, `recordUids` (optional narrowing), `purpose`, `permittedActions` (`VIEW`, `EXPORT`, `CONTRIBUTE_DEIDENTIFIED`), `decision` (`PERMIT`, `DENY`). How long: the `HAS_SHARING_GRANT` episode's `validFrom` / `validTo`. Revocation: new episode bounding `validTo` at revocation, recorded at revocation, never earlier than the revocation's `recordedFrom`. Follows FHIR R5 Consent (decision, actor, action, purpose, period, data). Every disclosure is a `DisclosureEvent {grantUid, occurredAt, dataCategories}`; a disclosure outside an active grant interval is a violation (fixture F-V10; service-enforced in the PCS).
- `PendingItem` (`Occurrence`, private): `pendingKind` (`AWAITING_LAB_RESULT`, `AWAITING_DELIVERY`, `AWAITING_PROTOCOL_PERIOD_END`, `AWAITING_EVIDENCE_UPDATE`, `AWAITING_CLINICIAN_INPUT`, `AWAITING_RESTOCK`, `REVIEW_TRIGGERED`, `REVIEW_SUGGESTED`, `EVIDENCE_REVIEW`), `blocksUid`, `openedAt`, `expectedBy` (planned time; nullable), `resolvedAt`, `resolvedByUid`. Answers "what are they waiting on".
- `PurchaseEvent` (`Occurrence`, private): `eventKind` (`INTENDED`, `ORDERED`, `DELIVERED`, `STARTED_USE`, `PAUSED_USE`, `STOPPED_USE`, `RETURNED`), `occurredAt`, `offerUid`, `productVariantUid`, `lotUid` (when known from the package).

### 6. Public protocols and `ProtocolInUse`

Live `Protocol` is a public protocol shape with one mutable node (`versionLabel`, `lastUpdatedAt`, `publicUrl`) and steps attached directly. Proposal for a new `protocols` module (public):

- `Protocol` (`Entity`): enduring identity of a public protocol. `versionLabel` and `lastUpdatedAt` on the live node become projections of the current edition.
- `ProtocolEdition` (`VersionedState`, new): immutable structured content of one observed or published state of the protocol; `editionLabel` (the source's own version label; null when the source shows none), `payloadHash`. Attached by `HAS_PROTOCOL_EDITION` (bitemporal profile, `EXCLUSIVE` per `Protocol`), authorized by an assertion supported by the snapshot locator. A new edition exists when `payloadHash` changes, whether or not the source labels a version. Named `ProtocolEdition` because catalog `ProtocolVersion` (studies module) is a study protocol document version (`InformationArtifact`); the archetypes differ, so the names differ. Lane 2 is asked to confirm `ProtocolVersion` stays study-scoped.
- `ProtocolStep` (live, refined): steps are payload of an edition (`HAS_STEP` from `ProtocolEdition`); an unchanged step may be shared by consecutive editions. New: `stepKey` (stable within the protocol lineage), `requirementLevel` (`ESSENTIAL`, `RECOMMENDED`, `OPTIONAL`, `CONDITIONAL`, `NOT_STATED`; refines `isOptional`), `requirementBasis` (`STATED_BY_SOURCE`, `EDITORIAL_INFERENCE`, `NOT_STATED`), `notReportedFields` (fields the source explicitly leaves unstated, distinct from null meaning not extracted), `payloadHash`.
- Conditional steps: `ProtocolStep -[:HAS_CONSTRAINT {constraintRole}]-> Constraint` with `constraintRole` `APPLIES_WHEN`, `CONTRAINDICATED_WHEN`, `REQUIRES_BEFORE`; `Constraint.constraintKind` refines the free-text `constraintType` (`POPULATION`, `CONDITION_PRESENT`, `CONDITION_ABSENT`, `MEASUREMENT_THRESHOLD`, `PHASE`, `TIME_WINDOW`, `CO_INTERVENTION`).
- Dependencies: live `DEPENDS_ON` gains `dependencyKind` (`REQUIRES_PRIOR_COMPLETION`, `REQUIRES_RESULT_OF`, `CONCURRENT_WITH`, `MUTUALLY_EXCLUSIVE_WITH`).
- `MeasurementPlan` (live, refined): `planTiming` (`BASELINE`, `DURING`, `FOLLOW_UP`, `PERIODIC`), `requiredForEvaluation` (boolean), `maxBaselineAgeDays`.
- `ProtocolAdjustmentRule` (live, refined as review trigger): `triggerKind` (`THRESHOLD_CROSSED`, `TREND`, `ADVERSE_EVENT_REPORTED`, `SCHEDULED_REVIEW`), `comparator` (`GT`, `GTE`, `LT`, `LTE`, `OUTSIDE_REFERENCE_RANGE`), `thresholdValue`, `thresholdUnitCode` (UCUM), `triggerAction` (`REVIEW`, `PAUSE_STEP`, `STOP_PROTOCOL`, `ADJUST_DOSE`, `CONTACT_CLINICIAN`), `ruleBasis` (`STATED_BY_SOURCE`, `BELLLABS_SAFETY_POLICY`). Policy-based rules are scoped to a `PolicyVersion`.
- `ProtocolResult` (live): kept as a public, source-attributed report (for example a protocol owner posting results); private outcomes never become `ProtocolResult` except through the consented de-identified contribution pipeline.

Private side:

- `ProtocolInUse` (`Entity`, private): a person's adoption of a public protocol. `ProtocolAdoptionVersion` (`VersionedState`, private, immutable): `adoptedEditionUid` (exactly one), deviations as `ProtocolDeviation` rows (`stepKey`, `deviationKind` `OMITTED`, `MODIFIED_DOSE`, `MODIFIED_TIMING`, `ADDED_STEP`, `SUBSTITUTED_PRODUCT`, personal values, `substituteSubjectUid`). Attached by `HAS_ADOPTION_VERSION` (bitemporal, `EXCLUSIVE`). Started/stopped is the episode's valid interval. Mirrors FHIR CarePlan `instantiatesCanonical` a versioned `PlanDefinition`.

How each protocol question is answered:

| Question | Answer path | Status |
|---|---|---|
| What changed between versions (CQ-PR-01) | diff of `HAS_STEP` sets of two editions by `stepKey` and `payloadHash` (added, removed, modified, unchanged), plus third-party change assertions; each change labeled `SOURCE_VERSIONED`, `SNAPSHOT_DIFF`, or `THIRD_PARTY_REPORTED` | answerable with qualifications: changes between unobserved states are unknown |
| Which steps are essential, conditional, dependent (CQ-PR-02) | `requirementLevel`, `requirementBasis`, `HAS_CONSTRAINT {constraintRole: APPLIES_WHEN}`, `DEPENDS_ON {dependencyKind}` | answerable for source-stated levels; BellLabs judgment of mechanistic essentiality is an Expansion assessment |
| What is missing before a person can evaluate the protocol (CQ-PR-03) | shared part: steps with `notReportedFields`, goals without a `MeasurementPlan`, steps without a `CONTRAINDICATED_WHEN` or stop rule; private part (PCS): baseline `MeasurementPlan` metrics with no `PersonalMeasurement` within `maxBaselineAgeDays`, constraints whose facts the `UserContextVersion` does not declare | answerable with qualifications |
| Which observations should trigger review (CQ-PR-04) | `ProtocolAdjustmentRule` of the adopted edition; PCS evaluates each new `PersonalMeasurement` and opens `PendingItem {pendingKind: 'REVIEW_TRIGGERED'}` | answerable; never rewrites earlier snapshots |

Query for CQ-PR-01 (shared graph):

```cypher
// CQ-PR-01: step-level differences between two editions of one protocol
// status: statically-checked
MATCH (old:ProtocolEdition {uid: $oldEditionUid}), (new:ProtocolEdition {uid: $newEditionUid})
OPTIONAL MATCH (old)-[:HAS_STEP]->(os:ProtocolStep)
WITH old, new, collect(os) AS oldSteps
OPTIONAL MATCH (new)-[:HAS_STEP]->(ns:ProtocolStep)
WITH oldSteps, collect(ns) AS newSteps
WITH oldSteps, newSteps,
     [s IN oldSteps | s.stepKey] AS oldKeys,
     [s IN newSteps | s.stepKey] AS newKeys
RETURN [s IN newSteps WHERE NOT s.stepKey IN oldKeys | s.stepKey] AS addedSteps,
       [s IN oldSteps WHERE NOT s.stepKey IN newKeys | s.stepKey] AS removedSteps,
       [n IN newSteps WHERE any(o IN oldSteps WHERE o.stepKey = n.stepKey AND o.payloadHash <> n.payloadHash) | n.stepKey] AS modifiedSteps,
       [n IN newSteps WHERE any(o IN oldSteps WHERE o.stepKey = n.stepKey AND o.payloadHash = n.payloadHash) | n.stepKey] AS unchangedSteps;
```

### 7. Ownership of live `Observation`

Decision: **keep** `Observation` as a public, protocol-linked, source-attributed type in the `protocols` module (observations reported in public protocol results, by public persons about themselves in published material, or at population level). Private measurements are `PersonalMeasurement` rows in the PCS that reference `Metric`, `LabTest`, `Device`, `MeasurementMethod`, and `ReferenceRange` by uid, with `valueNumber`, `unitCode` (UCUM), `resultQualifier` (`NUMERIC`, `BELOW_DETECTION`, `ABOVE_QUANTIFICATION`, `NOT_MEASURED`, `INVALID_SPECIMEN`), `effectiveAt`, `recordedAt`, `provenanceKind` (`LAB_REPORT_UPLOAD`, `DEVICE_IMPORT`, `MANUAL_ENTRY`), and `reportedReferenceRangeText` when the report prints one.

Rejected alternative: private observations as `Observation` nodes with a privacy label and RBAC. Rejected because (1) the live type sits one hop from public types (`ProtocolResult.INCLUDES_OBSERVATION`, `Person.RECORDS`, `MediaSubject` union); (2) Neo4j DENY rules fail open on unevaluable criteria and require Enterprise; (3) erasure and retention for personal data differ from public records. Also rejected: moving `Observation` wholly to the private store, which would orphan public protocol results.

Cross-lane note: `modules.yaml` lists `Observation` under the future `diagnostics` module. Lane 5 proposes `protocols` owns the public `Observation` and `private_context` owns `PersonalMeasurement`; `diagnostics` (Lane 3) keeps `LabTest`, `Metric`, `ReferenceRange`, `PanelDefinition`. The coordinator arbitrates.

### 8. `Recommendable` union and `RecommendationMetadata`

- `Recommendable` (line 1070): keep as the range of source-attributed `RECOMMENDS`. It is not the range of BellLabs recommendations, which are `RecommendationOption.subjectUid` values in the PCS.
- `RecommendationMetadata`: `refine`. New writes require `assertionUid` (the source assertion that the person recommends the thing) and the temporal profile; `strength` and `confidence` are not written for new records because they have no method or source.
- New forbidden implications: `RECOMMENDS` (by a source) does not imply a BellLabs recommendation; `SELECTED` in a snapshot does not imply `UserDecision CHOSE`; consent to share with a named grantee does not imply consent to publish; adopting a protocol edition does not imply following every step.

### 9. Privacy class convention

Every catalog node type and property gets `privacyClass`: `public` (shared graph, public API), `internal` (shared graph, excluded from public API projections: `PolicyVersion`, adjudication working notes, agent run ids), `private-personal` (PCS only). A node type is `private-personal` if any required property is. The projection contract must drop `internal` from public projections; Neo4j RBAC is defense in depth where the edition allows it, never the primary control.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| O-01 | Operational | DENY rule on `privacyClass` fails open when the property is null on one node | high | create a private node without `privacyClass` in a test DB; public role reads it | placement C; no private nodes in shared graph |
| O-02 | Epistemic | snapshot replay after a correction shows the corrected value | high | fixture correction recorded after decision; replay at `evidenceRecordedAt` | stored viewpoint plus as-of query |
| O-03 | Temporal | a new measurement is merged into the old context version | high | fixture F-V1: context version or measurement recorded after the snapshot | new `UserContextVersion`; old immutable |
| O-04 | Ontological | `EvidenceApplicability -[:ASSESSES_APPLICABILITY_TO]-> UserContext` links public to private | high | V-524 and fixture F-V8 | range change; `PersonalApplicabilityAssessment` in PCS |
| O-05 | Linguistic | "recommended" collapses source, BellLabs, and user | high | CQ-RC-05 minimal pair | `RECOMMENDS` (source), `SELECTED` (policy), `UserDecision CHOSE` (person) |
| O-06 | Operational | erasure versus immutable snapshots | medium | erasure drill on fixture person | whole-record deletion, tombstone, key destruction |
| O-07 | Provenance | a protocol page changes silently; diffs invented between unobserved states | medium | Blueprint page has no observed changelog | edition per observed `payloadHash`; unobserved gaps unknown |
| O-08 | Epistemic | third-party report of a protocol change treated as an edition | medium | NAD.com report of rapamycin stop | assertion with third-party source |
| O-09 | Operational | de-identified contribution re-identifiable by exact dates | high | contribution with day-precision measurement dates | year-only dates; Safe Harbor benchmark |
| O-10 | Ontological | private observation reused as `Observation` | high | V-524 and fixture F-V8 | `PersonalMeasurement` |

## Linguistic analysis

- Source wording: "Blood draw, every 3 to 6 months"; "Full body MRI annually (if over 40 or a family history of high risk)"; "My morning routine is always evolving as we update protocols"; "stopped in 2024".
- Normalized proposition: periodic measurement plan with a range interval; conditional step with population and condition constraints; statement that the content changes without versioning; third-party end of a step with YEAR precision.
- Negation: "do not eat after 5 pm" is an `AVOID` step, not the absence of a step.
- Modality/hedging: "what I'm experimenting with right now" lowers `requirementLevel` to `NOT_STATED` unless the text states essentiality.
- Quantification: "3 to 6 months" stored as min and max cadence, not a midpoint.
- Scope ambiguity: "Rx / Prescriptions" lists items the author takes; not steps addressed to readers unless the text says so (`requirementBasis: EDITORIAL_INFERENCE` if classified).
- Presuppositions not licensed as facts: a public figure's biomarker statements do not establish protocol efficacy; adoption does not establish adherence.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | step and constraint extraction from protocol pages | not defined | Blueprint and protocols.io sources | needed |
| Resolution | step substances to `IngredientMaterial` / `ChemicalSubstance` | identity_resolution | n/a | n/a |
| Source reliability | protocol owner's page: authoritative for what it displays only | n/a | registry entries | n/a |
| Evidence strength | unchanged | n/a | n/a | n/a |
| Applicability | `PersonalApplicabilityAssessment` in PCS | method version required | fixture | needed |
| Adjudication | shared, time-stamped (round 0007) | KCR-0007-2 | fixture | n/a |
| Decision | `decisionConfidence` with `decisionConfidenceMethod` on the snapshot | policy-bound | fixture | needed |

## Schema projection

- Projection request ID: not generated.
- Selected modules: `kernel`, `provenance`, `temporal`, `recommendation_decisions`, `protocols`, `private_context` (PCS schema, not projected to Neo4j).
- Closure additions: enums for disposition, rejection reason, intended use, decision outcome, pending kind, grant fields, requirement level, constraint kind, dependency kind, trigger fields, deviation kind, measurement result qualifier.
- Explicit exclusions: any `private-personal` element from every shared-graph projection.
- Budget result / projection digest: not computed.

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/recommendation-snapshot.cypher` | validation queries return zero rows | not executed | statically checked only |
| Negative fixture | snapshot mutation, leak, valid-time edit checks | rows when the forbidden change is introduced | not executed | statically checked only |
| Minimal pair | source-recommends vs BellLabs-selected vs user-chose | three distinct records | encoded in fixture | statically checked only |
| Temporal correction | correction after decision; replay | old belief returned | not executed | statically checked only |
| Identity collision | `Observation` vs `PersonalMeasurement` labels | V-524 and fixture F-V8 zero rows | not executed | statically checked only |
| Extraction evaluation | protocol step extraction | not available | not run | no |
| Retrieval evaluation | CQ-PR-01 diff, replay | defined | not run | no |
| Migration compatibility | additive GraphQL delta | additive only | reviewed | yes (static) |

## Decision

- Outcome (recommended): ACCEPT placement C and the record contracts above.
- Accepted semantic rule: the shared graph contains no private-personal data; private records reference shared uids and a recorded-time viewpoint; recommendation snapshots and context versions are insert-only and replayable; erasure removes whole records with a tombstone and propagates to projections and contributions; public protocols are versioned as editions and a person's use is a private adoption with deviations; `Observation` stays public and private measurements are `PersonalMeasurement`.
- Rejected alternatives: shared Neo4j with RBAC isolation (A); separate graph database as system of record (B); persisted private graph projection now (D, deferred as Expansion); `Product -[:RECOMMENDED_FOR]-> Goal`; reusing `Observation` for private measurements; editing snapshots when new measurements arrive; `EvidenceApplicability` targeting `UserContext`.
- Residual uncertainty: which regulatory regimes apply to BellLabs (legal input needed); k-anonymity threshold for aggregate contributions; whether the deployed Neo4j edition supports RBAC (affects defense in depth only); Lane 3 agreement on `Observation` ownership; Lane 2 agreement on `ProtocolVersion` naming; identity-merge redirect contract in `identity_resolution`.
- Required catalog/schema changes: lane fragment `catalog-patch.yaml` (`private_context`, `protocols`, changed `recommendation_decisions`, `privacyClass`, `ASSESSES_APPLICABILITY_TO` range).
- Required ingestion changes: protocol edition detection by `payloadHash`; change feed from shared graph to PCS keyed by uid.
- Required retrieval/API/MCP changes: public API and MCP tools never query the PCS; private tools run in the PCS service with the person's authorization and fetch shared nodes by uid with an explicit viewpoint.
- Changelog and migration references: 0.2.0. No live data migration: the live graph has no private records (mission brief: "There is no private user graph").
