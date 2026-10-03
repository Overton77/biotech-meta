# Proposal Index: BellLabs Schema 0.2.0

Status: provisional, integrated 2026-10-03 by the integration owner
Scope: `docs/schema/` (catalog 0.2.0, ontology lab rounds 0002 to 0009, Neo4j projection, fixtures, source registry)
Live schema under audit: `../current_biotech_schema.graphql` (read-only, unchanged)

This is the short integration note the mission asks for. It links the rounds, lists the keep / refine / merge / split / seam / defer decisions against the live schema, states the private-data placement, and answers the "done" questions for an implementer. The per-type table is `live-schema-alignment.md`; the semantic contract is `../catalog/schema.yaml`.

## 1. Rounds and decisions

| Round | Title | Lane | Decision | What changed in the catalog |
|---|---|---|---|---|
| 0001 | Product continuity and evidence transfer | (0.1.0) | OPEN | Candidate B stays provisional; round 0002's fixture supplies the "trial names a brand without a recoverable label" case. Not reopened. |
| [0002](./round-0002-study-intervention-versus-commercial-product.md) | Study intervention versus commercial product | 2 | ACCEPTED (calibration DEFERRED) | Evidence binds to products only through `EvidenceApplicability`; `ApplicabilityDimension` (categorical, continuous, explanation-only); `EndpointClassification`; `AdverseEventResult`; result analysis kinds; versioned `EvidenceSynthesis`; registry fields on `RegistrationVersion`; `Compound` merges into `ChemicalSubstance`. |
| [0003](./round-0003-mechanism-measured-versus-inferred.md) | Mechanism measured versus inferred | 2 | ACCEPTED | `Assertion.basisKind`; `MechanismEvidenceContext`; compartment-specific measurands; EXPOSURE dimension; live mechanism edges become derived projections. |
| [0004](./round-0004-diagnostic-comparability.md) | Diagnostic comparability | 3 | ACCEPTED | `diagnostics` promoted to candidate: `AssayVersion`, `AlgorithmVersion`, `ReferenceIntervalVersion`, `ComparabilityAssessment`, `DiagnosticResult` contract. |
| [0005](./round-0005-filing-versus-capability.md) | Filing versus capability | 3 | ACCEPTED | Regulatory split (submission, response, status with closed `statusKind`); `ManufacturingCapability`; commerce roles split and `SELLS_PRODUCT` derived; `amountReferent`; CALCULATED assertions. |
| [0006](./round-0006-claim-and-document-provenance.md) | Claim and document provenance | 4 | REVISED (accepted with reconciliation) | Live pipeline aligned with `Source -> SourceSnapshot -> SourceLocator`; typed selectors; `(:Assertion:ClaimOccurrence)`; `Claim` as proposition identity; `RETELLS` and `RetellingFidelityAssessment`; FINANCIAL_INTEREST family and `ConflictRelevanceAssessment`; `Activity`; five provenance states. |
| [0007](./round-0007-bitemporal-corrections-and-late-facts.md) | Bitemporal corrections and late facts | 5 | ACCEPTED | Immutable valid time; `SUPERSEDES {supersessionKind}`; per-bound precision and basis; `SourceRevisionEvent`; `recordedTo` and `contentHash` on Assertion; `recordedAt` on assessments; exclusive-overlap rule. |
| [0008](./round-0008-private-recommendation-history.md) | Private recommendation history | 5 | ACCEPTED | Private context store as system of record; `RecommendationSnapshot`, `RecommendationOption`, `UserDecision`; `UserContextVersion`, `PersonalMeasurement`, `SharingGrant`, `PendingItem`; `ProtocolEdition` and `ProtocolInUse`; `Observation` ownership; `UseContextProfile`. |
| [0009](./round-0009-question-catalog-and-access-tiers.md) | Question catalog and access tiers | 1 | ACCEPTED (K-5 revised, K-7 candidate) | Priority classes and traces; eight query shapes; asserted-edge temporal properties; derived-edge derivation rules; projection access tier; `Identifier`; `AnswerRecord` (candidate). |

Kernel-change requests and the ruling on each are listed in `../catalog/schema.yaml` under `kernelChangeDecisions`. Three reconciliations were needed across lanes: per-bound `validFromBasis` / `validToBasis` (round 0007) supersede the single `validTimeBasis` (round 0009); asserted edges carry `assertionUid` and derived edges `projectionOfAssertionUid`; and `Assertion.status` is capture fidelity (round 0006) projected from `Adjudication.adjudicationKind = CAPTURE_FIDELITY` records (round 0007), while SUPPORT adjudications carry truth verdicts.

## 2. Live schema: keep, refine, merge, split, seam, defer

Summary by live-schema section (line numbers refer to `../current_biotech_schema.graphql`). The full row-level table with reasons and competency questions is `live-schema-alignment.md`; the parsable additive projection is `../neo4j/proposed-delta.graphql`.

| Live section | Decision | Catalog counterpart and rule |
|---|---|---|
| Interfaces `Entity`, `SearchIndexable`, `TemporalSnapshot`, `ActorIdentity` (1–27) | seam | Live interfaces keep their meaning; `uid` is stored beside `id` and `id` equals the opaque segment of `uid`. `searchText` and embeddings are derived projections, never evidence (INV-107). `mongoResearchRunId` maps to `Activity.externalRunId`. |
| Shared enums `EvidenceStrength`, `AssociationPolarity`, `RoleType`, corporate roles (29–113) | refine | `EvidenceStrength` values on nodes and edges become extraction-time hints; the assessment is `EvidenceStrengthAssessment` or `ClaimEvidenceAssessment`. `RoleType` gains HOST, CO_HOST, GUEST. |
| Relationship property types (114–394) | refine | `TemporalMetadata`, `RoleMetadata` and others gain the `asserted_edge` fields (`relationshipUid`, `assertionUid`, `recordedFrom`, `recordedTo`, per-bound precision and basis). Generic `confidence` on edges is advisory-deprecated. `ExtractionMetadata` splits by lifecycle: `quoteSpan` to the locator, extractor version to `Activity`, salience and aboutness stay on retrieval edges. |
| Organizations, snapshots, locations (396–651) | keep + refine | Roles stay as edges under the asserted profile; `OrganizationSnapshot` is one node per recorded-time episode with a frozen payload. FINANCIAL_INTEREST family added. |
| `Compound`, `CompoundForm` (653–686) | merge + split | `Compound` merges into `ChemicalSubstance` (catalog name wins). `CompoundForm` splits into `ChemicalForm`, `IngredientMaterial`, and dosage form on the variant or intervention. `CONTAINS_COMPOUND_FORM` with `DoseMetadata` is a derived projection. |
| Commerce and interventions (688–1068) | refine + split | `Product` keeps identity; mutable facts move to states; `formulationSummary` is a display string, never composition (INV-005). `Listing`/`ListingSnapshot` map to `MerchantListing`/`Offer`/`PriceObservation`; `LISTS_PRODUCT` (inconsistent property types on its two sides) is replaced by `LISTING_FOR`. `SafetySignal`, `AdverseEffect`, `Procedure`, `Treatment`, food and exposure types stay seams until their modules open. |
| People and actors (1070–1145) | keep | `Person`, `PseudonymousActor`, `AnonymousActor` enter the catalog as asserters; `CohortParticipant` stays a seam. |
| Biology (1147–1375) | keep + refine | `Biomarker`, `Metric`, `ReferenceRange`, `Mechanism`, `Pathway`, `Species`, `AnatomicalContext`, `Condition`, `Outcome` kept. `ReferenceRange` is demoted to a projection of `ReferenceIntervalVersion`. Mechanism edges become derived projections of measured assertions. |
| Technology, diagnostics, devices, manufacturing, regulatory (1377–1595) | refine + split | `LabTest`, `MeasurementMethod`, `PanelDefinition` kept and versioned through `AssayVersion`. `RegulatoryStatus` splits into submission, response and status (live name kept for the status). `ManufacturingProcess` merges with the catalog type of the same name. `Device`, `Sensor`, `Modality`, `TechnologyPlatform` stay seams (consumer_devices is future). |
| Studies (1597–1755) | refine + split | `Study` keeps identity only; registry fields move to `RegistrationVersion`; `hasResults` becomes `resultsPosted`; `evidenceLevel` becomes an assessment. `StudyArm`, `OutcomeMeasure`, `OutcomeResult`, `Population`, `Dataset` map to the catalog study types. The live union `StudyIntervention` is projected as `ArmIntervention` to avoid the name clash with the catalog node. `Study -EVALUATES-> Product` is read-only legacy (INV-201). |
| Protocols (1756–2040) | refine | `Protocol` keeps identity; `ProtocolEdition` carries each published or observed state; steps gain `stepKey`, `requirementLevel`, dependencies, constraint roles; adjustment rules gain trigger fields. `Observation` stays public and protocol-linked (ownership decided in round 0008). |
| Events and narrative (2042–2179) | seam | Kept unchanged; `SPONSORS_CONTENT` may target `Conference`. No round opened narrative semantics. |
| Unions and media enums (2181–2379) | seam | `MediaSubject`-style list-valued subject/object on `RelationshipAssertion` is retired; other unions unchanged. |
| Media (2381–2569) | seam | Kept unchanged; `MediaAnnotation` may act as an IMAGE_REGION locator; `MediaSource` maps onto a locator. |
| Evidence pipeline (2571–2882) | keep + refine + merge | `Document` is a `Source` (one canonical URI). `DocumentTextVersion` kept, bound to one `SourceSnapshot`. `Segmentation` and `Chunk` kept as derived retrieval units; a `Chunk` is never a locator; `SUPPORTED_BY -> Chunk` must carry `locatorUid`. `Claim` kept as proposition identity (loses `evidenceStrength`). `ClaimOccurrence` becomes `(:Assertion:ClaimOccurrence)`; `UTTERED_BY` maps to `ASSERTED_BY`; `INSTANCE_OF` is derived. `RelationshipAssertion` kept for structured non-utterance assertions, losing list-valued endpoints, `confidence` and `SUPPORTED_BY_CLAIM`. `Association`, `ExperienceReport`, `Episode`, `Platform`, `Channel`, `Series` kept. |

Which name wins where two must merge: `ChemicalSubstance` over `Compound`; `Assertion` as the contract name over `ClaimOccurrence` (which stays as the specific label); `Source` over `Document` as the retrieval-endpoint identity (Document stays as the specific label); `RegulatoryStatus` (live) over a new status name; `ManufacturingProcess` (shared name) with `processKind` taking the live `processClass`; `ArmIntervention` (new GraphQL name) for the live union so the catalog node `StudyIntervention` keeps its name.

## 3. Private-data placement

Decision (round 0008): a **separate transactional private context store** (PostgreSQL recommended) is the system of record for all private-personal data; the shared Neo4j graph holds **zero** private-personal nodes, properties, relationships or private uid values (INV-506). Private records reference shared things by uid plus the recorded-time viewpoint used; no relationship crosses the boundary. `PolicyVersion` and `DecisionCriterion` are internal and live in the shared graph.

| Category | Owner | Sync and deletion |
|---|---|---|
| Goals and personal context versions | private store | insert-only versions; erasure deletes whole records and leaves a content-free tombstone |
| Measurements and lab reports | private store | reference `Metric`, `LabTest`, `AssayVersion`, `AlgorithmVersion`, `Device` by uid |
| Protocol in use and deviations | private store | reference `ProtocolEdition` by uid |
| Recommendation snapshots and user decisions | private store | insert-only; carry the evidence viewpoint (`evidenceRecordedAt`) so replay reads the shared graph as of the decision |
| Consent and sharing grants, disclosure events | private store | grant revocation is never backdated; disclosures must fall inside a PERMIT episode |
| Purchase lifecycle | private store | references `Offer`, `ProductVariant`, `PackageConfiguration`, `ProductLot` by uid |
| Policy versions and decision criteria | shared graph (internal) | excluded from public projections |

Rejected alternatives and why: shared Neo4j with RBAC isolation (Enterprise-only; a DENY rule fails open on null or misspelled criteria; path existence between two shared products through a private node leaks co-interest even with properties hidden); a separate graph database (adds a second graph without removing the leak path through projections); hybrid with a graph projection of private records (the projection itself is a private copy that must be governed). A uid merge in the shared graph publishes a redirect; private records are not rewritten. Consented de-identified contributions carry an HMAC withdrawal token; the k-anonymity threshold for aggregates is open.

## 4. How a representative source is ingested without dropping qualifications

Round 0006's real case: Huberman Lab episode 52 with David Sinclair (published 2021-12-27).

1. Capture: `Source` for the transcript page and for the video rendition, each with a `SourceSnapshot` (`contentHash`, `contentHashBasis` STORED_EXCERPT_TEXT because direct fetch was blocked, `captureCompleteness` PARTIAL_EXCERPT, `retrievedAt`). Both renditions link `RENDITION_OF` the `Episode`.
2. Locate: a `SourceLocator` for the span "we take a gram of NMN every day" (TEXT_QUOTE with `exact`, `quoteHash`, `normalizationVersion` NFC-WS1) and a MEDIA_TIME locator for the sponsor read at 4:47 on the video timeline (dynamic ad insertion means the audio feed differs).
3. Assert: a `(:Assertion:ClaimOccurrence)` with predicate `SELF_REPORTED_DAILY_INTAKE`, `assertionBasis` PERSONAL_EXPERIENCE, `speechAct` REPORTS_PRACTICE, `ASSERTED_BY` the guest, `OCCURS_IN` the episode, `SUPPORTED_BY` the locator. The qualifier two turns later ("I'm not the same as everybody else") is its own occurrence linked by `QUALIFIED_BY {qualificationKind: INDIVIDUAL_VARIATION}`.
4. Financial tie: `BOARD_MEMBER_OF` and `INVESTED_IN` assertions from the self-disclosure page, each time-bounded with year precision; a `ConflictRelevanceAssessment` records relevance and where it was disclosed. No `ENDORSES_PRODUCT` edge is created.
5. Retelling: a later outlet's "Sinclair recommends a gram of NMN" is a distinct Assertion linked by `RETELLS {retellingMode: PARAPHRASE}`; the `RetellingFidelityAssessment` flags the lost qualification and the changed speech act (REPORTS_PRACTICE to RECOMMENDS). Neither assertion is edited.
6. Status: the occurrence is ACCEPTED as an accurate record; no SUPPORT adjudication claims the practice is advisable.

The same path for a label (Elysium fixture), a trial (round 0002 fixture), a filing (round 0005 fixture) and a lab result (round 0004 fixture) is in `../examples/`.

## 5. How an answer traces to a source locator and an adjudication

Query shape QS-1 in `query-shapes.md`: answer -> cited `Assertion` -> `SUPPORTED_BY` -> `SourceLocator` -> `HAS_LOCATOR` <- `SourceSnapshot` (hash, retrievedAt) <- `Source`; and `Adjudication {adjudicationKind, verdict, reviewedAt}` -> `EVALUATES` -> the same assertion, read as of the answer's recorded viewpoint. A published answer is an `AnswerRecord` (candidate) that cites the assertions and assessments it used with `recordedAsOf` and `validAt`. Every cited assertion must separate the five provenance states (section 2 of `architecture.md`, section 12).

## 6. How a correction and a late-arriving fact are stored

- Correction: new Assertion `SUPERSEDES {supersessionKind: SOURCE_CORRECTION}` the old one; old assertion keeps its valid time and gets `recordedTo`; a `SourceRevisionEvent` links the notice, the prior and the resulting snapshot; historical adjudications still point at the snapshot they examined. Minimal pair 8 ("corrected in June" versus "ceased in June") produces `SOURCE_CORRECTION` versus `VALIDITY_BOUNDED`.
- Late fact: past `validFrom` with its precision and basis; `recordedFrom` is the commit time; the archive capture date goes in `SourceSnapshot.observedAt`. A replay at an earlier recorded time does not see it (CQ-TM-02).
- Retraction: a `SourceRevisionEvent {RETRACTION}` and a new SUPPORT Adjudication; the assertions stay ACCEPTED as records of what the paper said (tested on PMID 9500320 and PMID 20137807).

## 7. Priority questions: answerable, qualified, or outside the graph

`competency-questions.md` classifies 127 questions. Of the Essential-now questions, the proposed model answers directly (A) the identity, provenance-trace, time, access and claim-attribution questions; it answers with qualifications (Q) the applicability, study-versus-product, diagnostic-comparability and recommendation questions, because material identity, mass basis, assay detail and calibration are often UNKNOWN or NOT_REPORTED in real sources, and the model surfaces that as `missingFacts` rather than guessing. Questions that need information outside the graph (X) are marked: whether a guest statement is a legal endorsement, retention regimes for private data, the k-anonymity threshold, and the deployed Neo4j and GraphQL library facts.

## 8. What is still open and what would close it

`../OPEN-QUESTIONS.md` is the backlog. The highest-value closers are: an expert-review calibration set for applicability ratio bands (round 0002, deferred); the 2016 Basis trial supplier record (ChromaDex versus Elysium) to settle one real MATERIAL_IDENTITY case; a sample of lab reports coded against `AssayVersion` fields; dated re-captures of one commercial page and one protocol page; and the live-stack verification list (library version, stored labels, index property names, Neo4j edition, `LISTS_PRODUCT` property set).

## 9. Verification status

Every Cypher statement in `../examples/*.cypher`, `../neo4j/validation.cypher`, `../neo4j/constraints.cypher` and `query-shapes.md` passed a syntax check with the Neo4j Cypher language-support parser and a per-statement variable-binding check. `../neo4j/proposed-delta.graphql` parses with graphql-js and extends the live schema (directives stripped) without name or field collisions; two duplicate enum definitions and four duplicate `uid` field additions across lanes were removed at integration. All YAML files parse. **Nothing was executed against a Neo4j instance**; every query is marked statically-checked or illustrative, and the fixtures' expected zero-row results are predictions, not observations. Research tool limits recorded by the lanes: direct fetches of loinc.org, PubChem, ClinicalTrials.gov's version API, web.archive.org and several publisher pages were blocked by the egress proxy, so those sources were read through search-tool extracts and are marked as such in the source registry; the Exa and bigdata connectors failed to connect.

## 10. File inventory for 0.2.0

- Catalog: `../catalog/schema.yaml` (0.2.0, with `kernelChangeDecisions` and `migration`).
- Ontology lab: `competency-questions.md`, `query-shapes.md`, `modules.yaml`, `projection-contract.yaml`, `live-schema-alignment.md`, rounds `round-0002` to `round-0009`, this index.
- Neo4j: `../neo4j/constraints.cypher`, `../neo4j/validation.cypher` (V-0xx to V-5xx), `../neo4j/proposed-delta.graphql`.
- Fixtures: `../examples/elysium-basis.cypher` (fixed), `study-vs-product-mismatch.cypher`, `diagnostic-comparison.cypher`, `filing-vs-capability.cypher`, `claim-retelling-provenance.cypher`, `recommendation-snapshot.cypher`.
- Sources: `../sources/source-registry.yaml` (0.2.0, 127 entries).
- Companions: `../architecture.md`, `../CHANGELOG.md`, `../OPEN-QUESTIONS.md`, `../README.md`.
