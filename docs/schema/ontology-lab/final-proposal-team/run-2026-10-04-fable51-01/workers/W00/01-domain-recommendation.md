# W00 domain recommendation — kernel, identity, time and evidence provenance

Worker W00 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 (`8fb50ff0…84f0`), live schema `86b5e0b5…f112`. W00 realizes the frozen contract sections A, B3, B4, B5 and B7 as SDL; it does not change the contract. Every departure found is a request in `seam-requests.yaml`.

## 1. Boundary and subdomains

| Subdomain | Canonical module | What it answers | Owned elements (SDL in `sdl-fragment.graphql`) |
|---|---|---|---|
| K1 Kernel contracts | kernel (`baseArchetypes`, `conventions`) | what kind of record anything is; uid/id; privacy class; maturity | interfaces `Entity`, `SearchIndexable`, `TemporalSnapshot`, `ActorIdentity`, six `*Archetype` interfaces; enums `PrivacyClass`, `NodeMaturity` |
| K2 Assertion authority | kernel / provenance | who said what, where, with which basis; capture fidelity vs truth | `Assertion` (generic), `Adjudication`, enums `AssertionStatus`, `AssessmentStatus`, `AdjudicationKind`, `AdjudicationVerdict`, `ReviewerType`, `BasisKind`, `PredicateClass` (candidate), `AssertionBasis`, `SpeechAct`, `Polarity`, `QuantityBasis`, `MassBasis`, `AmountReferent`, `ReportedStatus`, retelling/relevance/disclosure enums |
| K3 Source capture | provenance | which endpoint, which capture, which span; reproducibility | `Source`, `SourceSnapshot`, `SourceLocator`, `SourceRevisionEvent`; enums `SourceKind`, `SelectorKind`, `ContentHashBasis`, `CaptureCompleteness`, `SourceRevisionKind`, `AnchorMatch`, candidate `RenditionCoverage` |
| K4 Lineage and use | provenance (PROV-O) | which agent/activity produced or used a record; which policy allowed the use | `Agent`, `Activity`; enums `ActivityKind`, `AgentKind`, `UseKind`; `AuthorizationProperties` |
| K5 Time | temporal | valid vs recorded time, precision, basis, supersession, exclusivity | enums `TimePrecision`, `ValidTimeBasis`, `SupersessionKind`; property types `AssertedEdgeProperties`, `StateEpisodeProperties`, `SupersessionProperties` |
| K6 Edge classes | kernel | structural vs asserted vs derived | `StructuralEdgeProperties`, `DerivedEdgeProperties` (+ the two temporal types) |
| K7 Identity resolution | identity_resolution | which identifiers support a match; candidates vs identities | `Identifier`, `TradeItemIdentifier`, `Mention`, `ResolutionHypothesis`, `EquivalenceAssessment`, `IdentifierLinkProperties`, `ReanchorProperties`, enum `EquivalenceKind` |
| K8 Endpoint unions | kernel | the ranges of HAS_SUBJECT/HAS_OBJECT, ASSERTED_BY, SUPPORTED_BY | `AssertionSubjectTarget`, `AsserterTarget`, `SupportedRecordTarget` |

Out of scope (referenced by name only): `Document`, `DocumentTextVersion`, `Segmentation`, `Chunk` (W20); `Claim`, `ClaimOccurrence`, `RelationshipAssertion`, `Episode` (W21); `Publication` (W09); `MechanismEvidenceContext` (W03); `MediaAnnotation` (W22); `PolicyVersion`, `AccessTier`, `TraceDepth` (W23); every domain type in the unions.

## 2. Identity vs state vs artifact vs occurrence (W00 types)

| Type | Archetype label | Why that archetype, and what it is not |
|---|---|---|
| Source | Entity | persists while captures change; not the work (Publication/Episode) and not a capture |
| SourceSnapshot | InformationArtifact | a record of bytes at a time; immutable; not a state of the Source (no valid time) |
| SourceLocator | InformationArtifact | a selection inside one snapshot; not a Chunk (regenerable) and not a MediaAnnotation |
| SourceRevisionEvent | Occurrence | the publisher did something at a time; not a snapshot and not an assertion edit |
| Assertion | Assertion | an attributable proposition; status = capture fidelity |
| Adjudication, ResolutionHypothesis, EquivalenceAssessment | EvidenceAssessment | BellLabs evaluations with a method; immutable; superseded, never edited |
| Agent | Entity | an identity (tool, model, curator); runs are not Agent properties |
| Activity | Occurrence | a run that used and generated records |
| Identifier, TradeItemIdentifier | Entity | the identifier string within scheme+issuer; the assignment to a record is an asserted episode |
| Mention | InformationArtifact | an extracted surface form; not an identity, not evidence |

## 3. Disposition of every element in scope

Legend: keep, refine, merge, split, seam, derive, retire, defer, candidate. Full old→new rows in `migration-map.yaml`.

### 3.1 Live elements (current_biotech_schema.graphql)

| Live element | Disposition | Note |
|---|---|---|
| `interface Entity {id, name!, description, mongoResearchRunId}` (l.1) | refine | adds `uid: String!`; `name` nullable (D-013); still a GraphQL interface, not the archetype label |
| `interface SearchIndexable` (l.8) | keep | unchanged; INV-107 description |
| `interface TemporalSnapshot` (l.15) | keep (seam) | cache of the first HAS_STATE episode of OrganizationSnapshot/ProductSnapshot; live ListingSnapshot retired (D-007) |
| `interface ActorIdentity` (l.22) | refine | adds `uid`, `name` nullable (D-W00-01) |
| `type TemporalMetadata` (l.114) | split → `AssertedEdgeProperties` / domain successors | `confidence`, `notes` not carried (INV-407); per-bound precision/basis, `relationshipUid`, `assertionUid` added |
| `type ExtractionMetadata` (l.189) | split | `quoteSpan` → SourceLocator.exact/quoteHash; method/version/time → Activity; `supportType` → SUPPORTED_BY vs CONTRADICTED_BY; salience/aboutness stay on W20/W21 derived retrieval edges; run id → Activity.externalRunId (round 0006 D9) |
| field `mongoResearchRunId` (115 occurrences) | keep (operational) | last-writer pointer; lineage is WAS_GENERATED_BY Activity (V-430) |
| `RoleMetadata`, `OwnershipMetadata`, `RecommendationMetadata`, other `*Metadata` | seam | successor types owned by W01/W21/W23/…; each must embed the frozen B4 fields |
| relationship `SUPPORTED_BY` → `Chunk` / `ProvenanceSource` | split | kernel SUPPORTED_BY targets SourceLocator only (structural); Chunk shortcuts are derived (`SUPPORTED_BY_CHUNK`, W20, `locatorUid`); `ProvenanceSource` (Chunk|Document|Organization|Study, ProtocolResult l.2038) is retired in favour of assertions supported by locators (W16 seam) |
| relationship `UTTERED_BY` (l.2798) | merge → `ASSERTED_BY` | kernel relationship; W21 writes ClaimOccurrence's field; range `AsserterTarget` |
| union `ClaimSpeaker` (l.2187) | merge → `AsserterTarget` | adds Organization, Agent |
| union `ClaimSubject` / `EvidenceSubject` (l.2181, 2183) | split | assertion subjects → `AssertionSubjectTarget`; ABOUT/MENTIONS retrieval edges stay W20/W21 |
| live `HAS_SNAPSHOT` (Organization/Product/Listing → *Snapshot) | seam (W00-SR-08) | semantically HAS_STATE; HAS_SNAPSHOT reserved for Source → SourceSnapshot |

### 3.2 Catalog elements (provenance, temporal, identity_resolution, kernel conventions)

| Catalog element | Disposition | Note |
|---|---|---|
| Source | keep + refine | SDL; `renditionCoverage` candidate (W19-SR-02); CL-003 rule |
| SourceSnapshot | keep | `retrievedAt` non-null; `contentHashBasis`/`captureCompleteness` nullable in SDL, required for new captures |
| SourceLocator | keep + refine | typed selectors; `selectorKind` nullable only for migrated untyped selectors; `LOCATES_REGION` field (CL-011) |
| DocumentTextVersion | seam | W20 writes (canonical module provenance; T-003) |
| SourceRevisionEvent | keep | `recordedAt` API-assigned |
| Adjudication | keep | both clocks; immutability via @settable |
| ResolutionHypothesis | keep + refine | `resolutionStatus` outcome string (W00-SR-04) |
| Agent, Activity | keep | PROV-O |
| Identifier, TradeItemIdentifier | keep + refine | per-bound precision/basis on scheme-level validity; triple key |
| Mention | keep | uid token requested (W00-SR-09) |
| EquivalenceAssessment | keep | never merges; redirect gap W00-SR-05 |
| HAS_SNAPSHOT, HAS_LOCATOR, HAS_TEXT_VERSION, TEXT_OF_SNAPSHOT, LOCATOR_IN_TEXT_VERSION, REANCHORS, RENDITION_OF, HAS_SUBJECT, HAS_OBJECT, SUPPORTED_BY, CONTRADICTED_BY, ASSERTED_BY, EVALUATES, CONSIDERS_ASSESSMENT, SUPERSEDES, DERIVED_FROM_ASSERTION, REVISES_SOURCE, PRIOR_SNAPSHOT, RESULTING_SNAPSHOT, ANNOUNCED_IN, PROPOSES_MATCH, COMPETES_WITH, WAS_GENERATED_BY, USED, WAS_ASSOCIATED_WITH, ACTED_ON_BEHALF_OF, AUTHORIZED_BY, ASSESSED_BY, MENTIONS, RESOLVES_MENTION, COMPARES_IDENTITIES | keep | all projected as fields on W00 types (inverse fields on other owners' types are theirs) |
| HAS_STATE | keep (contract only) | `StateEpisodeProperties`; no generic field (no W00 VersionedState type); W01/W04 use it for the live snapshot caches |
| HAS_IDENTIFIER | keep | asserted; `IdentifierLinkProperties`; merge target of IDENTIFIED_BY (W00-SR-07) |
| assertedPredicates CORRECTS_SOURCE, RETRACTS_SOURCE, EXPRESSES_CONCERN_ABOUT, REINSTATES_SOURCE | keep | F09 uses RETRACTS_SOURCE |
| provenanceStates (five) | keep | Q09-a returns each state from its own record |
| forbiddenImplications (provenance, identity) | keep | F08 (shared identifier), F09 (ACCEPTED ≠ true), V-W00-04 |
| temporal rules TM-R1…R6 | keep | F01 (R1–R3), F02 (R4, R6), F11 G4 (R5), V-5xx |
| conventions enums (B5 list) | keep | SDL values = catalog values, SCREAMING_SNAKE; PrivacyClass drops private-personal (D-012) |
| conventions.uidTypeTokens | refine | tokens requested: mention, media-annotation (W00-SR-09) |
| conventions.normalizationVersions | refine | IMAGE_REGION convention requested (W00-SR-10) |
| conventions.predicateExclusivity | keep | enforced by write guard (F11 G4) and V-508/509 |
| relationshipClasses / temporalProfiles | keep | B4 types; V-W00-02, V-W00-11 |
| INV-001…INV-007, INV-101…INV-107, INV-401…INV-407, INV-501…INV-506 | keep | validators in `fixtures/validation-w00.cypher` |
| migration (0.1.0 → 0.2.0) | refine | untyped selector = null selectorKind; status MIGRATION adjudications |

## 4. Alternatives considered

| Question | Alternatives | Chosen | Why |
|---|---|---|---|
| Range of HAS_SUBJECT | `Entity` interface target; one union per archetype; a single big union | single union (contract B6) with parent-only and archetype exclusions | interface target would include assessments and assertions and costs the same planning; per-archetype unions need four fields per edge |
| API immutability | service-only; `@settable`/`@mutation` | both | the generated API otherwise exposes updates of valid time and backdating (T5b shows the field is absent) |
| Legacy untyped selectors | WHOLE_SNAPSHOT; new UNKNOWN value; null | null | honest (not reproducible) within the frozen enum |
| Year-precision as-of | precision-blind QS-2a; precision-aware classes | precision-aware (QS-W00-P) | F03 shows QS-2a overstating at 2011-06-15 and understating at 2017-06-01 |
| Identifier key | (scheme,value); (scheme,issuer,value) | (scheme,issuer,value) | forbidden implication; F08 |
| Enforcement of exactly-one rules | post-commit validation only; in-transaction audit with rollback | both | F11: race-free with a subject lock; validators remain the audit |

## 5. Smallest recommended model

Thirteen node types (Source, SourceSnapshot, SourceLocator, SourceRevisionEvent, Assertion, Adjudication, ResolutionHypothesis, EquivalenceAssessment, Agent, Activity, Identifier, TradeItemIdentifier, Mention), ten interfaces, eight relationship-property types, 38 enums (37 frozen kernel enums + candidate `RenditionCoverage`), three unions. Nothing beyond the contract and the catalog is added except: `ActorIdentity.uid`, Identifier per-bound precision/basis, the generic Assertion's A11 and verbatim fields, `Source.renditionCoverage` (candidate), the read-only legacy `SourceLocator.selector`, and four fields that carry other owners' relationship types on W00 types (D-W00-18). The SDL builds under `@neo4j/graphql` 7.6.3 and reads every Cypher fixture in this packet (06 §4).
