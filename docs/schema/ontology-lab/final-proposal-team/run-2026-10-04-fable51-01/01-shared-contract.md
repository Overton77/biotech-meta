# 01 Frozen shared contract

Frozen by Fable 5.1 with the W00 role at Wave 0 (2026-10-04). Every worker imports this contract. A worker may propose a change only through a conflict record in `03-conflict-ledger.md` with a primary source plus a concrete failing case; until Fable rules, the frozen text stands. Where this document is silent, `docs/schema/catalog/schema.yaml` 0.2.0 (digest `8fb50ff0…84f0`) and `docs/schema/architecture.md` govern, in that order.

## A. Semantic kernel (unchanged from catalog 0.2.0)

1. **Six archetypes, exactly one per node**: Entity, VersionedState, Occurrence, InformationArtifact, Assertion, EvidenceAssessment. Required archetype properties are those of `baseArchetypes` in the catalog. Multiple domain labels never add a second archetype.
2. **Identity**: `uid` is the canonical identity, format `hu:<type-token>:<opaque-stable-id>`; the type token comes from `conventions.uidTypeTokens` (new tokens are proposed through the ledger, never invented in a fragment). The live `id` equals the opaque segment of `uid` and is stored beside it (per-type stored id property for `Document`, `DocumentTextVersion`, `Segmentation`, `Chunk`). Display names and market URLs are never identity. Identifiers are `Identifier` records (scheme, issuer, value, validity); a shared scheme/value across issuers does not establish identity. Merges publish a redirect through an `EquivalenceAssessment` and keep the old uid resolvable.
3. **Assertion authority**: an Assertion has exactly one subject and either one object or one typed literal; at most one asserter (`ASSERTED_BY`); a `ClaimOccurrence` has exactly one asserter and exactly one container (`OCCURS_IN`). Corroboration is several Assertions `INSTANCE_OF` one `Claim`. `Claim` carries no truth value and no evidence strength. `Assertion.predicate` is a controlled string registered in the catalog (relationship names and `assertedPredicates`); new predicates are candidates until registered. `basisKind`, `assertionBasis`, `speechAct`, `polarity` and `predicateClass` are kernel fields.
4. **Status is capture fidelity, never truth.** `Assertion.status` is a projection of CAPTURE_FIDELITY adjudications and `SUPERSEDES` records. Truth and support live on SUPPORT adjudications (`verdict`) and EvidenceAssessments. Extraction, resolution, source reliability, evidence strength, applicability and decision confidence stay separate, each with a method and version (`methodVersion`, `WAS_GENERATED_BY` Activity). A bare `confidence` is deprecated on every new element.
5. **Three relationship classes.** Every relationship type is `structural`, `asserted` or `derived` (catalog meaning). Asserted edges are projections of exactly one Assertion and carry the `asserted_edge` profile. Derived edges carry `projectionOfAssertionUid`, or `derivationRule` plus `derivedFromAssertionUids`/`derivedFromAssessmentUids`, or `derivationRule` alone only where the catalog says `ruleOnly: true`. The cited predicate is never the premise of a forbidden implication for the edge type. A derived edge is never the only history.
6. **Time.** Half-open intervals; `validFrom`/`validTo` with per-bound `validFromPrecision`/`validToPrecision` (INSTANT…DECADE, stored as the first instant of the period) and `validFromBasis`/`validToBasis`; `recordedFrom`/`recordedTo` on states and asserted edges, `recordedAt`/`recordedTo` on assertions and assessments; `observedAt`, `retrievedAt`, `publishedAt`, `effectiveFrom`/`effectiveTo` are distinct clocks. Null bound = unknown, never "ongoing"; no sentinel dates. Recorded time is service-assigned at commit and never backdated; valid time is immutable; a correction is `SUPERSEDES {SOURCE_CORRECTION}`, a fact ending `SUPERSEDES {VALIDITY_BOUNDED}`; late facts keep their past `validFrom` with `SourceSnapshot.observedAt` for the archive capture. `predicateExclusivity` declarations (TM-R5) are unchanged.
7. **Missingness.** unknown, unmeasured, notReported, belowDetection, absent and false are distinct. Reuse the catalog's enums (`reportedStatus`, `resultQualifier` semantics, `statisticalConclusion`, `applicabilityVerdict` UNKNOWN vs NOT_ASSESSED vs NOT_SCORED, `disclosureFinding`, `aeCollectionMethod`). No new universal enum may collapse them.
8. **Provenance.** `Source` (one `canonicalUri`) → `SourceSnapshot` (immutable; `contentHash`, `contentHashBasis`, `captureCompleteness`, `retrievedAt`, `observedAt`, `publishedAt`) → `SourceLocator` (typed `selectorKind` with the required fields per kind; `REANCHORS` on a newer snapshot never mutates the old locator). `Activity`/`Agent` PROV-O lineage; the five provenance states (someone said it; a source supports it; evidence warrants a broader conclusion; an agent used the source; a policy allows a downstream use via `AUTHORIZED_BY {useKind}` → `PolicyVersion`). A `Chunk` is never a locator. `MediaAnnotation` may back an IMAGE_REGION locator through `mediaAnnotationUid`.
9. **Privacy.** The shared graph contains zero private-personal nodes, properties, relationships or `hu:private-` uids. The final GraphQL schema contains no private-personal type and no `PRIVATE_PERSONAL` enum value. Private records are external store contracts referencing shared uids plus a recorded-time viewpoint. `PolicyVersion` and `DecisionCriterion` are INTERNAL and live in the shared graph, excluded from public projections. Public `Observation` (protocols) is never the private measurement store.
10. **Forbidden implications and validators** in the catalog (`forbiddenImplications`, INV-001…INV-509, V-0xx…V-5xx) are preserved verbatim unless a ledger ruling changes them with a failing case. In particular: advising, sponsorship or any FINANCIAL_INTEREST never implies endorsement; supplying an investigational product is not ingredient supply; registration, clearance, designation or GRAS "no questions" are not approval; hosting, listing or fulfilment is not selling; a practice report is not a recommendation; "no adverse events reported" is not "no events"; a shared substance is not current-product evidence; a mention is not an endorsement; a retelling is not the same assertion; a chunk match is not source support.
11. **Jurisdiction, dose/quantity/mass/serving basis, formulation versions, population/context of use and measured versus inferred mechanisms** are mandatory qualifiers that survive extraction and queries (`quantityBasis`, `massBasis`, `amountReferent`, `MechanismEvidenceContext`, `UseContextProfile`).

## B. GraphQL projection conventions (frozen for the final proposal)

Target library: `@neo4j/graphql` **7.6.3**, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22. Test database: Neo4j **5.26.31 Community** (embedded); Enterprise behaviour unverified. Established at run start (see `00-baseline.md`): there is **no `@unique` directive** in 7.6.3; `@vector` with a `provider` needs a runtime feature configuration; `extend type` is not used because the final file is standalone.

B1. **One standalone file.** Every type is written in full. No `extend type`, no `extend enum`. No `@cypher`, `@customResolver`, `@populatedBy`, `@jwt*`, `@subscription` in fragments. Allowed field directives: `@id`, `@alias`, `@timestamp`, `@relationship`, `@settable`, `@selectable`, `@default`, `@coalesce`. Allowed type directives: `@node(labels: [...])`, `@relationshipProperties`, `@fulltext`, `@plural`, `@query`, `@mutation`. `@vector` is added only by Fable at merge for types with a stated retrieval justification and is written **without** `provider:` so no embedding service is presumed.

B2. **Every node type** follows this skeleton (field order free, names fixed):

```graphql
"""
<One paragraph: what the identity, state, occurrence, artifact, assertion or assessment is; what it is NOT;
competency questions served (CQ ids); canonical catalog module; archetype.>
"""
type <TypeName> implements Entity & <ArchetypeInterface> [& SearchIndexable]
  @node(labels: ["<TypeName>", "<ParentLabel>"?, "<ArchetypeLabel>"]) {
  id: ID! @id                      # live projection identity; equals the opaque segment of uid
  uid: String!                     # hu:<token>:<opaque>; uniqueness is created by the operations file, not by a directive
  name: String                     # presentation only; never identity (nullable: kernel records may construct it)
  description: String
  mongoResearchRunId: String       # operational lineage; maps to Activity.externalRunId; internal tier
  createdAt: DateTime! @timestamp(operations: [CREATE])
  updatedAt: DateTime! @timestamp(operations: [CREATE, UPDATE])
  privacyClass: PrivacyClass       # PUBLIC (default) or INTERNAL; no private-personal value exists
  maturity: NodeMaturity
  schemaVersion: String
  # archetype fields required by the interface (below), then domain fields, then relationship fields
}
```

- `@node(labels:)` lists the primary label first, any specialization parent labels next (for example `["TestingLaboratory", "Organization", "Entity"]`, `["ClaimOccurrence", "Assertion"]`, `["Document", "Source", "Entity"]`, `["AdverseEventResult", "StudyResult", "InformationArtifact"]`), and the archetype label last. **Archetype labels are stored on every node** (decision D-001). The live GraphQL interface `Entity` (B3) is a GraphQL interface, not the archetype label; the two share a name and are documented as such.
- `id` keeps the live stored-property aliases: `Document` (`documentId`, `title`, `type`, `url`), `DocumentTextVersion` (`documentTextVersionId`), `Segmentation` (`segmentationId`, `strategy`), `Chunk` (`chunkId`, `chunkKey`, `index`). No other aliases are introduced without a ledger entry.
- Relationship fields are lists `[T!]!` (7.x requires `@node` targets and non-null list elements). Cardinality (exactly_one, zero_or_one, one_or_more, many) and relationship class (structural | asserted | derived) are written in the field's description string in the form `"""class: asserted; cardinality: zero_or_one; catalog: HAS_FORMULATION_VERSION"""` and enforced by the operations/validation layer, never assumed from SDL.
- Legacy edges kept read-only carry `@settable(onCreate: false, onUpdate: false)` (for example `Study.evaluates` under INV-201).
- Field types: `DateTime` for instants, `Date` only for source-stated dates without time, `Float` for quantities with a sibling `unitCode: String` (UCUM), `Int` for counts, `[String!]` for lists, enums for closed vocabularies. Use `BigInt` nowhere.

B3. **Shared GraphQL interfaces** (owned by W00; workers implement, never redefine):

```graphql
interface Entity { id: ID!  uid: String!  name: String  description: String  mongoResearchRunId: String }
interface SearchIndexable { searchText: String  searchFields: [String!]  embeddingModel: String  embeddingDimensions: Int }
interface EntityArchetype { entityType: String! }
interface VersionedStateArchetype { stateType: String!  payloadHash: String!  effectiveFrom: DateTime  effectiveTo: DateTime }
interface OccurrenceArchetype { occurrenceType: String!  startedAt: DateTime  endedAt: DateTime }
interface InformationArtifactArchetype { artifactType: String!  publishedAt: DateTime  observedAt: DateTime  contentHash: String }
interface AssertionArchetype { predicate: String!  status: AssertionStatus!  recordedAt: DateTime!  recordedTo: DateTime  contentHash: String  polarity: Polarity  basisKind: BasisKind  predicateClass: PredicateClass  assertionBasis: AssertionBasis  speechAct: SpeechAct  reportedSpeechAct: SpeechAct  valueString: String  valueNumber: Float  valueBoolean: Boolean  unitCode: String  quantityBasis: QuantityBasis  validFrom: DateTime  validTo: DateTime  validFromPrecision: TimePrecision  validToPrecision: TimePrecision  validFromBasis: ValidTimeBasis  validToBasis: ValidTimeBasis  jurisdiction: String  derivationRule: String  extractionMethod: String  extractionConfidence: Float  agentRunUid: String  confidence: Float }
interface EvidenceAssessmentArchetype { assessmentType: String!  methodVersion: String!  status: AssessmentStatus!  recordedAt: DateTime!  recordedTo: DateTime  summary: String  overallScore: Float  confidence: Float }
```

The live `TemporalSnapshot` and `ActorIdentity` interfaces are kept by W00 for compatibility (`ActorIdentity` on Person, PseudonymousActor, AnonymousActor; `TemporalSnapshot` on the three live snapshot types as a cache of their first episode).

B4. **Shared relationship-property types** (owned by W00; reuse by name; a domain type may add qualifiers only by defining a new `@relationshipProperties` type that contains every field of the frozen type it specializes and says so in its description):

```graphql
"""asserted_edge profile (catalog temporalProfiles.asserted_edge). One edge per recorded-time episode."""
type AssertedEdgeProperties @relationshipProperties {
  relationshipUid: String!  assertionUid: String!
  validFrom: DateTime  validTo: DateTime  validFromPrecision: TimePrecision  validToPrecision: TimePrecision
  validFromBasis: ValidTimeBasis!  validToBasis: ValidTimeBasis!
  recordedFrom: DateTime!  recordedTo: DateTime  mongoResearchRunId: String
}
"""bitemporal_attachment profile for structural state attachments (HAS_STATE, HAS_REGISTRATION_VERSION ...)."""
type StateEpisodeProperties @relationshipProperties {
  relationshipUid: String!  assertionUid: String
  validFrom: DateTime  validTo: DateTime  validFromPrecision: TimePrecision  validToPrecision: TimePrecision
  validFromBasis: ValidTimeBasis!  validToBasis: ValidTimeBasis!
  recordedFrom: DateTime!  recordedTo: DateTime  mongoResearchRunId: String
}
"""derived edge: regenerable shortcut; never the only history."""
type DerivedEdgeProperties @relationshipProperties {
  projectionOfAssertionUid: String  derivationRule: String
  derivedFromAssertionUids: [String!]  derivedFromAssessmentUids: [String!]
  derivedAt: DateTime  mongoResearchRunId: String
}
"""structural edge with optional ordering."""
type StructuralEdgeProperties @relationshipProperties { orderIndex: Int  notes: String  mongoResearchRunId: String }
type SupersessionProperties @relationshipProperties { supersessionKind: SupersessionKind!  recordedAt: DateTime!  sourceRevisionEventUid: String }
type AuthorizationProperties @relationshipProperties { useKind: UseKind! }
type ReanchorProperties @relationshipProperties { anchorMatch: AnchorMatch!  activityUid: String }
type IdentifierLinkProperties @relationshipProperties { relationshipUid: String!  assertionUid: String!  validFrom: DateTime  validTo: DateTime  validFromPrecision: TimePrecision  validToPrecision: TimePrecision  validFromBasis: ValidTimeBasis!  validToBasis: ValidTimeBasis!  recordedFrom: DateTime!  recordedTo: DateTime  isPrimary: Boolean  mongoResearchRunId: String }
```

Live property types (`TemporalMetadata`, `RoleMetadata`, `OwnershipMetadata`, `DoseMetadata`, `ExtractionMetadata`, `OrderingMetadata`, `MeasurementMetadata`, `AssociationMetadata`, `MechanismLinkMetadata`, `MediaLinkMetadata`, …) are **not** carried as-is; the owning worker defines a successor type that embeds the frozen class fields (for example `RoleEdgeProperties` = `AssertedEdgeProperties` fields + `roleType`, `roleTitleVerbatim`, `corporateRoleType`, `seniorityLevel`) and records the old → new mapping in `migration-map.yaml`.

B5. **Enums**: SCREAMING_SNAKE_CASE values; one owner per enum (registry); kernel enums are W00's and frozen at the catalog `conventions` values: `PrivacyClass {PUBLIC INTERNAL}`, `NodeMaturity`, `AssertionStatus`, `AssessmentStatus {PROPOSED ACCEPTED SUPERSEDED WITHDRAWN}`, `AdjudicationKind`, `AdjudicationVerdict`, `ReviewerType`, `BasisKind` (five values including CALCULATED), `PredicateClass {MECHANISM ROLE COMMERCIAL REGULATORY QUANTITY IDENTITY CLAIM OTHER}` (candidate; owner W00), `AssertionBasis`, `SpeechAct`, `Polarity`, `TimePrecision`, `ValidTimeBasis`, `SupersessionKind`, `SourceRevisionKind`, `SelectorKind` (seven values incl. SECTION, WHOLE_SNAPSHOT), `ContentHashBasis` (four incl. SYNTHETIC_FIXTURE), `CaptureCompleteness`, `SourceKind`, `ActivityKind`, `AgentKind`, `UseKind`, `EquivalenceKind`, `QualificationKind`, `RetellingMode`, `RetellingLinkBasis`, `RelevanceLevel`, `RelevanceBasis`, `DisclosureFinding`, `TemporalOverlap`, `AnchorMatch`, `QuantityBasis`, `MassBasis`, `AmountReferent`, `ReportedStatus`, `AccessTier`, `TraceDepth`. Domain enums are owned by the domain worker and frozen at the catalog values; a new value is a ledger request.

B6. **Unions** name endpoint ranges `<Role>Target` (for example `AssertionSubjectTarget`, `MediaSubjectTarget`, `ApplicabilityUseTarget`) and are defined once by the owner named in the registry; members must be `@node` types that exist in the final schema. Interfaces are preferred over unions where the members share fields.

B7. **Naming rulings frozen for the final file** (each is a recorded decision; see `03-conflict-ledger.md` for the seam records they close):

| Id | Ruling |
|---|---|
| D-001 | Archetype labels are stored on every node via `@node(labels:)`; the catalog archetype constraints apply to all nodes. |
| D-002 | `ChemicalSubstance` replaces live `Compound`; live `CompoundForm` splits into `ChemicalForm`, `IngredientMaterial` and dosage form on `ProductVariant`/`StudyIntervention`; `CONTAINS_COMPOUND_FORM` and `CONTAINS` are derived. |
| D-003 | The GraphQL type for the catalog node `StudyIntervention` is named `StudyIntervention` (label `StudyIntervention`, archetype VersionedState). The live union of that name is renamed `LegacyEvaluatedIntervention` and is reachable only through the read-only `Study.evaluates` field. The 0.2.0 projection name `ArmIntervention` is not used; it existed only because an additive delta could not redeclare the union (migration table records the alias). |
| D-004 | `HAS_PROTOCOL_STEP` (ProtocolEdition → ProtocolStep, structural, `orderIndex`) is the protocol step edge; `HAS_STEP` remains only for ManufacturingProcess → ManufacturingStep. The live `Protocol.hasSteps` is replaced by a derived read-only projection `Protocol.currentSteps` documented as derived from the current edition. |
| D-005 | `Source` is the retrieval-endpoint Entity; `Document` is its specialization (`["Document","Source","Entity"]`); `Publication` is the work-level scholarly InformationArtifact; `Episode` is the work Entity; renditions are Sources `RENDITION_OF` an Episode or Publication. |
| D-006 | `Claim` is the proposition Entity; `ClaimOccurrence` is `["ClaimOccurrence","Assertion"]`; `RelationshipAssertion` is `["RelationshipAssertion","Assertion"]`; a generic `Assertion` type (`["Assertion"]`) carries literal and structured assertions written by ingestion. `UTTERED_BY` is replaced by `ASSERTED_BY`; `INSTANCE_OF` is derived. |
| D-007 | Catalog names win for merged live types: `MerchantListing` (live `Listing`), `StudyPopulation` (live `Population`), `OutcomeDefinition` (live `OutcomeMeasure`), `StudyResult` (live `OutcomeResult`); live `StudyOutcome` and `ListingSnapshot` are retired into assertions, `SourceSnapshot`, `Offer` and `PriceObservation`. Legacy labels appear only in the migration table (relabel statements). |
| D-008 | `IngredientMaterial` is the canonical material identity; the live `Material` label survives only as a `ProcessMaterial` specialization for non-ingredient process inputs if W11 produces a failing case, otherwise it is retired (ledger CL-005). |
| D-009 | One `SpecificationVersion` type (module products_and_formulations, SDL written by W11); quality (W12) and products (W04) reference it. |
| D-010 | An IMAGE_REGION `SourceLocator` references its `MediaAnnotation` by `mediaAnnotationUid` and a structural `LOCATES_REGION` edge; the annotation never replaces the locator or the snapshot. |
| D-011 | Asserted edges carry `assertionUid`; derived edges carry `projectionOfAssertionUid` (never both). |
| D-012 | No private-personal type, enum value, uid prefix or relationship appears in the final schema; `PolicyVersion` and `DecisionCriterion` are INTERNAL shared-graph types. |
| D-013 | `Entity.name` becomes nullable (`String`) in the final schema so that Cypher-ingested kernel records are readable; a compatibility note goes in the migration table. |
| D-014 | `@vector` declarations are retained only where a retrieval justification is written and never carry `provider:`; embeddings are computed outside the API; dimensions are recorded per index in the operations file. |
| D-015 | `@fulltext` index names and query names from the live schema are retained; the operations file creates them with **stored** property names (`title`, `url` for Document; `chunkKey`, `index` for Chunk). |
| D-016 | Node `payloadHash` on VersionedState and `contentHash` on InformationArtifact/Assertion are written as `sha256:<hex>`; synthetic fixtures use `contentHashBasis: SYNTHETIC_FIXTURE`. |

## C. Output-affecting rules for every worker

- Import, never redefine: a fragment contains only the types, enums, unions and relationship-property types the registry assigns to that worker. Referencing another owner's type by name is the only permitted dependency. If a needed field on another owner's type is missing, file a seam request (`seam-requests.yaml`); do not add the field.
- Every proposed element maps to a CQ id, an invariant, an ingestion failure or a named interoperability requirement; elements without a mapping stay candidates (`maturity: CANDIDATE` in the model card, excluded from the SDL fragment unless a fixture needs them).
- Candidate CQs are labelled `CQ-<AREA>-C<nn>` and marked candidate; they never masquerade as existing CQ ids.
- Fixtures write only shared-graph content; private-store records appear only as documented external contracts or as `:PrivateRecord`-labelled nodes in a leak-check fixture that is expected to fail V-113…V-116/V-520/V-521.
- No live database, no deployment, no paid service, no credentials. Blocked retrieval is recorded as blocked.
