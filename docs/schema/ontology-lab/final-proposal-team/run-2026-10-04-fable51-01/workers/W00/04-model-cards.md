# W00 model cards

Conventions for all cards: privacy class PUBLIC unless stated (INTERNAL marks operator-tier content); "kind" = asserted | observed | calculated | inferred | operational; temporal behaviour "immutable" means never changed after commit except where a single `recordedTo` write is stated. Every node type also carries the B2 skeleton fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId` [INTERNAL, operational], `createdAt`, `updatedAt` [operational], `privacyClass`, `maturity`, `schemaVersion`), not repeated below. Maturity: ACCEPTED where the catalog module is accepted (provenance), PROVISIONAL for temporal/identity_resolution, CANDIDATE where stated.

## 1. Interfaces

| Interface | Meaning | Fields | Implemented by |
|---|---|---|---|
| Entity | GraphQL identity contract (not the archetype label) | id!, uid!, name, description, mongoResearchRunId | every node type |
| SearchIndexable | derived retrieval text/embedding metadata, never evidence | searchText, searchFields, embeddingModel, embeddingDimensions | domain types with search surfaces |
| TemporalSnapshot | live state-cache times (first episode cache) | validFrom, validTo, recordedFrom, recordedTo | OrganizationSnapshot (W01), ProductSnapshot (W04) |
| ActorIdentity | asserting actor identity | id!, uid!, name, description, mongoResearchRunId | Person, PseudonymousActor, AnonymousActor (W01) |
| EntityArchetype / VersionedStateArchetype / OccurrenceArchetype / InformationArtifactArchetype / AssertionArchetype / EvidenceAssessmentArchetype | archetype contracts (contract B3) | as B3 | one per node type, matching its archetype label |

## 2. Node cards

### Source (Entity; uid token `source`; labels Source, Entity)
Meaning: one retrieval endpoint (normalized `canonicalUri`). Not the work (Publication/Episode), not a capture. Identity keys: `uid`; `canonicalUri` (unique). Aliases: Document specialization (labels Document, Source, Entity; `documentId` = `id`).

| Property | Type / null | Kind | Notes |
|---|---|---|---|
| entityType | String! | operational | 'Source' or specialization name |
| canonicalUri | String! | observed | post-redirect endpoint; never an identifier resolver (CL-003 R2) |
| title | String | observed | as displayed |
| sourceKind | SourceKind | inferred | classification only |
| publisherUid | String | asserted | uid reference; no edge in 0.2.0 |
| renditionCoverage | RenditionCoverage (CANDIDATE) | inferred | FULL/PARTIAL/UNKNOWN; null when not a rendition |

Edges: snapshots (HAS_SNAPSHOT out), textVersions (HAS_TEXT_VERSION out), renditionOfEpisode / renditionOfPublication (RENDITION_OF out, ≤1 work), revisionEvents (REVISES_SOURCE in), identifiers (HAS_IDENTIFIER out, IdentifierLinkProperties). Mutations: create, update (no delete).

### SourceSnapshot (InformationArtifact; `snapshot`)
Meaning: immutable capture. Not a text version, not a locator. Identity: uid; dedup aid `contentHash`.

| Property | Type / null | Kind | Temporal |
|---|---|---|---|
| artifactType | String! | operational | |
| retrievedAt | DateTime! | operational | fetch time; lower bound for recordedAt (V-504) |
| observedAt | DateTime | observed | displayed time (archive capture time) |
| publishedAt, publishedAtPrecision | DateTime, TimePrecision | observed | issuer time |
| contentHash | String | calculated | `sha256:<hex>`; required when cited (V-111) |
| contentHashBasis | ContentHashBasis | operational | required for new captures |
| captureCompleteness | CaptureCompleteness | observed | PARTIAL_EXCERPT never supports NOT_DISCLOSED |
| canonicalUri, storageUri (INTERNAL), archiveUri, publisherRevisionNotice, mimeType, language | String | observed/operational | |

Edges: source (HAS_SNAPSHOT in, exactly one), locators (HAS_LOCATOR out), textVersions (TEXT_OF_SNAPSHOT in), generatedBy (WAS_GENERATED_BY out), usedBy (USED in), revisedFromInEvents / resultOfRevisionEvents / announcesRevisionEvents (PRIOR_SNAPSHOT / RESULTING_SNAPSHOT / ANNOUNCED_IN in). Mutations: create only.

### SourceLocator (InformationArtifact; `locator`)
Meaning: reproducible selection inside one snapshot (KCR-4.1). Not a Chunk, not a MediaAnnotation.

| Property | Type / null | Required when |
|---|---|---|
| selectorKind | SelectorKind (null only for migrated untyped selectors) | always for new writes |
| exact, prefix, suffix | String | exact: TEXT_QUOTE, TEXT_POSITION, MEDIA_TIME, PDF_PAGE |
| quoteHash | String (calculated, sha256 over NFC-WS1(exact)) | text-bearing kinds |
| normalizationVersion | String (catalog registry id) | all but SECTION/WHOLE_SNAPSHOT |
| startOffset, endOffset | Int | TEXT_POSITION (+ LOCATOR_IN_TEXT_VERSION) |
| mediaStartSeconds, mediaEndSeconds, mediaTimeBasis | Float, Float, String | MEDIA_TIME (rendition timeline) |
| page | Int | PDF_PAGE |
| section | String | SECTION |
| mediaAnnotationUid | String | IMAGE_REGION (+ LOCATES_REGION edge) |
| speakerLabelInSource | String (observed) | — |
| uri | String | — |
| selector | String, read-only, DEPRECATED | migrated 0.1.0 data |

Edges: snapshot (HAS_LOCATOR in, exactly one), textVersion (LOCATOR_IN_TEXT_VERSION out, ≤1), regionAnnotation (LOCATES_REGION out → MediaAnnotation, exactly one iff IMAGE_REGION), reanchors / reanchoredBy (REANCHORS, ReanchorProperties), mentions (MENTIONS out → Mention), resolvesToChunks (RESOLVES_TO_CHUNK out → Chunk, derived, W20 properties), supports / contradicts (SUPPORTED_BY / CONTRADICTED_BY in, SupportedRecordTarget), generatedBy, usedBy. Mutations: create only.

### SourceRevisionEvent (Occurrence; `source-revision`)
Properties: occurrenceType!, revisionKind: SourceRevisionKind!, occurredAt (issuer time) + occurredAtPrecision, recordedAt! (API @timestamp; service clock), startedAt/endedAt (unused). Edges: revisesSource (exactly one Source), priorSnapshot, resultingSnapshot, announcedIn (each ≤1). Rules: V-512 (one source; snapshots belong to it; content-clock order). Mutations: create only.

### Assertion (Assertion; `assertion`; labels Assertion)
Meaning: attributable proposition; generic type that also reads ClaimOccurrence and RelationshipAssertion through kernel fields. Identity: uid; content identity `contentHash`.

| Group | Properties | Kind / temporal |
|---|---|---|
| proposition | predicate! (controlled), polarity, predicateClass (candidate enum), basisKind, assertionBasis, speechAct, reportedSpeechAct, jurisdiction | asserted/inferred; immutable |
| literal | valueString, valueNumber, valueBoolean, unitCode (UCUM), quantityBasis, massBasis, amountReferent | asserted; immutable; xor HAS_OBJECT |
| valid time | validFrom, validTo, validFromPrecision, validToPrecision, validFromBasis, validToBasis, derivationRule | asserted/inferred; immutable |
| recorded time | recordedAt! (service), recordedTo (once) | operational |
| status | status: AssertionStatus! | operational projection of CAPTURE_FIDELITY adjudications + SUPERSEDES |
| extraction | extractionMethod (legacy), extractionConfidence (INTERNAL; needs WAS_GENERATED_BY), agentRunUid (DEPRECATED), confidence (DEPRECATED) | calculated/operational |
| verbatim | roleTitleVerbatim, roleCodeVerbatim, statedTense, segmentKind | observed |
| integrity | contentHash | calculated |

Edges: subject (HAS_SUBJECT, exactly one, AssertionSubjectTarget), object (HAS_OBJECT, ≤1), assertedBy (ASSERTED_BY, ≤1; =1 for ClaimOccurrence), supportedBy / contradictedBy (→ SourceLocator), supersedes / supersededBy (SUPERSEDES, SupersessionProperties), derivedFromAssertions / inputToAssertions (DERIVED_FROM_ASSERTION), generatedBy (WAS_GENERATED_BY), usedBy (USED in), evaluatedBy (EVALUATES in), proposedInHypotheses (PROPOSES_MATCH in), observedInContext (OBSERVED_IN_CONTEXT → MechanismEvidenceContext, W03 relationship, ≤1), instanceOf (INSTANCE_OF → Claim, derived ruleOnly, W21 relationship). Mutations: create, update (status, recordedTo, presentation fields only); no delete.

### Adjudication (EvidenceAssessment; `adjudication`)
Properties: assessmentType!, methodVersion!, status: AssessmentStatus!, recordedAt! (service), recordedTo, summary, overallScore, confidence (DEPRECATED), adjudicationKind: AdjudicationKind!, verdict: AdjudicationVerdict!, rationale (INTERNAL), reviewerType: ReviewerType!, reviewedAt, humanReviewPending. Edges: evaluates (EVALUATES → Assertion, ≥1), considersAssessments (CONSIDERS_ASSESSMENT → EvidenceAssessmentArchetype interface), supportedBy / contradictedBy (→ SourceLocator retrieved before recordedAt, V-511), supersedes / supersededBy (SUPERSEDES {RE_REVIEW | SOURCE_REVISION}), generatedBy, assessedByAgent / assessedByPerson (ASSESSED_BY). Rule: only CAPTURE_FIDELITY feeds Assertion.status (V-110, V-123). Privacy: INTERNAL rationale; verdict PUBLIC.

### ResolutionHypothesis (EvidenceAssessment; `resolution`)
Properties: archetype fields + resolutionType! (controlled string), score (method score), rationale, resolutionStatus (outcome: PROPOSED/ACCEPTED/REJECTED/UNRESOLVED; enum requested W00-SR-04). Edges: proposesMatch (PROPOSES_MATCH → AssertionSubjectTarget), proposesMatchAssertion (PROPOSES_MATCH → Assertion), competesWith (COMPETES_WITH), resolvesMention (RESOLVES_MENTION → Mention), supportedBy, supersedes, generatedBy, assessedBy*. Never identity by itself ([SIMILAR_NAME, SAME_IDENTITY]).

### EquivalenceAssessment (EvidenceAssessment; uid token `assessment`)
Properties: archetype fields + equivalenceKind: EquivalenceKind!, rationale. Edges: comparesIdentities (COMPARES_IDENTITIES, exactly two distinct; V-W00-05), supportedBy, supersedes, generatedBy, assessedBy*. Never merges; merge-redirect gap W00-SR-05.

### Agent (Entity; `agent`)
Properties: entityType!, agentKind: AgentKind!, model, promptVersion, toolVersion. Edges: actedOnBehalfOf (ACTED_ON_BEHALF_OF → Organization), activities (WAS_ASSOCIATED_WITH in), assertions (ASSERTED_BY in). Runs are Activities (V-431). Privacy INTERNAL in fixtures.

### Activity (Occurrence; `activity`)
Properties: occurrenceType!, activityKind: ActivityKind!, startedAt, endedAt, methodVersion, externalRunSystem, externalRunId ((system, id) unique). Edges: associatedWithAgents / associatedWithPersons (WAS_ASSOCIATED_WITH), usedSnapshots / usedLocators / usedAssertions / usedTextVersions (USED), authorizedBy (AUTHORIZED_BY → PolicyVersion, AuthorizationProperties), generatedAssertions / generatedSnapshots / generatedLocators / generatedTextVersions / generatedAdjudications (WAS_GENERATED_BY in). Privacy INTERNAL.

### Identifier (Entity; `identifier`) and TradeItemIdentifier (Entity; `trade-id`; labels TradeItemIdentifier, Identifier, Entity)
Properties: entityType!, scheme!, issuer!, value! (immutable; key (scheme, issuer, value)), jurisdiction, validFrom/validTo + precisions + bases (scheme-level validity of the identifier itself), normalizationRule. Edge: identifies (HAS_IDENTIFIER in, IdentifierLinkProperties; assignment validity lives on the edge). Forbidden: [SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY].

### Mention (InformationArtifact; token `mention` requested)
Properties: artifactType!, surfaceForm!, mentionKind (controlled string), publishedAt/observedAt/contentHash (archetype; unused). Edges: locatedAt (MENTIONS in, exactly one locator), resolutionHypotheses (RESOLVES_MENTION in). Immutable; never identity or evidence.

## 3. Relationship cards (W00-owned relationship types)

| Type | Domain → range | Card. | Class | Properties | Notes |
|---|---|---|---|---|---|
| HAS_SNAPSHOT | Source → SourceSnapshot | many / exactly one source | structural | — | live state-cache use → HAS_STATE (W00-SR-08) |
| HAS_LOCATOR | SourceSnapshot → SourceLocator | exactly one snapshot per locator | structural | — | V-402 |
| HAS_TEXT_VERSION | Source → DocumentTextVersion | many | structural | — | W20 type |
| TEXT_OF_SNAPSHOT | DocumentTextVersion → SourceSnapshot | exactly one | structural | — | field on W20 type; inverse on SourceSnapshot |
| LOCATOR_IN_TEXT_VERSION | SourceLocator → DocumentTextVersion | ≤1 | structural | — | V-403/V-404 |
| REANCHORS | SourceLocator → SourceLocator | many | structural | ReanchorProperties | same Source; newer content → older (V-409) |
| RENDITION_OF | Source → Episode \| Publication | ≤1 work | structural | — | CL-003 R3 |
| HAS_SUBJECT | Assertion → AssertionSubjectTarget | exactly one | structural | — | V-002 |
| HAS_OBJECT | Assertion → AssertionSubjectTarget | ≤1, xor literal | structural | — | V-003 |
| SUPPORTED_BY | Assertion \| Adjudication \| EvidenceAssessment → SourceLocator | many | structural | — | Chunk variant is SUPPORTED_BY_CHUNK (W20, derived) |
| CONTRADICTED_BY | Assertion \| Adjudication → SourceLocator | many | structural | — | |
| ASSERTED_BY | Assertion → AsserterTarget | ≤1 (=1 ClaimOccurrence) | structural | — | V-W00-01, V-410 |
| EVALUATES | Adjudication → Assertion | ≥1 | structural | — | legacy Study.evaluates is a different (W09, read-only) use |
| CONSIDERS_ASSESSMENT | Adjudication → EvidenceAssessment | many | structural | — | interface target |
| SUPERSEDES | Assertion → Assertion; Adjudication → Adjudication; EA → same EA type | many | structural | SupersessionProperties | newer → older; V-506, V-507 |
| DERIVED_FROM_ASSERTION | Assertion → Assertion | ≥1 for CALCULATED | structural | — | V-W00-07 |
| REVISES_SOURCE | SourceRevisionEvent → Source | exactly one | structural | — | |
| PRIOR_SNAPSHOT, RESULTING_SNAPSHOT, ANNOUNCED_IN | SourceRevisionEvent → SourceSnapshot | ≤1 each | structural | — | |
| PROPOSES_MATCH | ResolutionHypothesis → AssertionSubjectTarget \| Assertion | ≥1 | structural | — | |
| COMPETES_WITH | ResolutionHypothesis → ResolutionHypothesis | many | structural | — | |
| WAS_GENERATED_BY | Assertion \| SourceSnapshot \| DocumentTextVersion \| SourceLocator \| EvidenceAssessment → Activity | ≤1 | structural | — | prov:wasGeneratedBy |
| USED | Activity → SourceSnapshot \| SourceLocator \| Assertion \| DocumentTextVersion | many | structural | — | prov:used |
| WAS_ASSOCIATED_WITH | Activity → Agent \| Person | many | structural | — | prov:wasAssociatedWith |
| ACTED_ON_BEHALF_OF | Agent → Organization | ≤1 | structural | — | |
| AUTHORIZED_BY | Activity → PolicyVersion | many | structural | AuthorizationProperties (useKind!) | state 5; INTERNAL |
| ASSESSED_BY | EvidenceAssessment → Agent \| Person | ≤1 | structural | — | |
| HAS_STATE | Entity → VersionedState | many episodes | asserted (profile bitemporal_attachment) | StateEpisodeProperties | NONEXCLUSIVE; no W00 field (no W00 VersionedState) |
| HAS_IDENTIFIER | Entity \| VersionedState \| InformationArtifact → Identifier | many episodes | asserted | IdentifierLinkProperties | merge target of IDENTIFIED_BY |
| MENTIONS (locator) | SourceLocator → Mention | many | structural | — | distinct from W20/W21 derived MENTIONS |
| RESOLVES_MENTION | ResolutionHypothesis → Mention | ≤1 | structural | — | |
| COMPARES_IDENTITIES | EquivalenceAssessment → Entity \| VersionedState | exactly two distinct | structural | — | |
| LOCATES_REGION (W22 type; W00 field) | SourceLocator → MediaAnnotation | exactly one iff IMAGE_REGION | structural | — | CL-011 |

## 4. Relationship-property type cards (contract B4)

| Type | Fields (required!) | Used by | Rules |
|---|---|---|---|
| AssertedEdgeProperties | relationshipUid!, assertionUid!, validFrom, validTo, validFromPrecision, validToPrecision, validFromBasis!, validToBasis!, recordedFrom!, recordedTo, mongoResearchRunId | every asserted edge (domain specializations embed all fields) | V-101, V-W00-11, V-W00-02; immutable except recordedTo once |
| StateEpisodeProperties | relationshipUid!, assertionUid, … same time fields | HAS_STATE and domain attachments | exclusivity V-508/509; assertionUid required in shared graph |
| DerivedEdgeProperties | projectionOfAssertionUid, derivationRule, derivedFromAssertionUids, derivedFromAssessmentUids, derivedAt, mongoResearchRunId | derived edges incl. INSTANCE_OF | exactly one citation form; V-112 |
| StructuralEdgeProperties | orderIndex, notes, mongoResearchRunId | ordered structural edges (domain owners) | — |
| SupersessionProperties | supersessionKind!, recordedAt!, sourceRevisionEventUid | SUPERSEDES | recordedAt = newer.recordedAt = older.recordedTo |
| AuthorizationProperties | useKind! | AUTHORIZED_BY | INTERNAL |
| ReanchorProperties | anchorMatch!, activityUid | REANCHORS | — |
| IdentifierLinkProperties | AssertedEdgeProperties fields + isPrimary | HAS_IDENTIFIER | assignment validity |

## 5. Enum cards (owner W00 unless stated; values = catalog conventions)

| Enum | Values | Source | Notes |
|---|---|---|---|
| PrivacyClass | PUBLIC, INTERNAL | contract D-012 | no private-personal value; stored spelling SCREAMING |
| NodeMaturity | CANDIDATE, PROVISIONAL, ACCEPTED, DEPRECATED | conventions.nodeMaturity | |
| AssertionStatus | EXTRACTED, PROPOSED, ACCEPTED, REJECTED, DISPUTED, SUPERSEDED, UNRESOLVED | conventions.assertionStatus | capture fidelity |
| AssessmentStatus | PROPOSED, ACCEPTED, SUPERSEDED, WITHDRAWN | contract B5 | record workflow; 'FINAL' migrates to ACCEPTED |
| AdjudicationKind | CAPTURE_FIDELITY, SUPPORT | conventions | |
| AdjudicationVerdict | SUPPORTED, PARTIALLY_SUPPORTED, CONTRADICTED, INSUFFICIENT, NOT_APPLICABLE | conventions | |
| ReviewerType | HUMAN, AGENT, POLICY, MIGRATION | conventions | |
| BasisKind | DIRECT_MEASUREMENT, INFERRED_FROM_MEASUREMENT, CITED_FROM_PRIOR_WORK, HYPOTHESIS, CALCULATED | conventions | |
| PredicateClass (CANDIDATE) | MECHANISM, ROLE, COMMERCIAL, REGULATORY, QUANTITY, IDENTITY, CLAIM, OTHER | contract B5 | |
| AssertionBasis | PERSONAL_EXPERIENCE, THIRD_PARTY_ANECDOTE, MANUFACTURER_CLAIM, STUDY_RESULT, MECHANISM_REASONING, EXPERT_OPINION, UNSTATED | conventions | |
| SpeechAct | STATES, REPORTS_PRACTICE, RECOMMENDS, CAUTIONS, SPECULATES, QUESTIONS, DENIES | conventions | |
| Polarity | POSITIVE, NEGATIVE, MIXED, UNKNOWN | conventions | |
| TimePrecision | INSTANT, DAY, MONTH, QUARTER, YEAR, DECADE | conventions | first instant of period |
| ValidTimeBasis | STATED_BY_SOURCE, PUBLICATION_PROXY, OBSERVATION_ONLY, INFERRED, UNKNOWN | conventions | |
| SupersessionKind | SOURCE_CORRECTION, VALIDITY_BOUNDED, EXTRACTION_FIX, RESOLUTION_FIX, DUPLICATE_MERGE, RE_REVIEW, SOURCE_REVISION | conventions | |
| SourceRevisionKind | ERRATUM, RETRACTION, EXPRESSION_OF_CONCERN, CORRECTED_AND_REPUBLISHED, NEW_VERSION, SILENT_CONTENT_CHANGE, WITHDRAWAL, REINSTATEMENT | conventions | |
| SelectorKind | TEXT_QUOTE, TEXT_POSITION, MEDIA_TIME, PDF_PAGE, IMAGE_REGION, SECTION, WHOLE_SNAPSHOT | conventions | |
| ContentHashBasis | RAW_BYTES, NORMALIZED_TEXT, STORED_EXCERPT_TEXT, SYNTHETIC_FIXTURE | conventions | |
| CaptureCompleteness | COMPLETE, PARTIAL_EXCERPT, UNKNOWN | conventions | |
| SourceKind | 27 catalog values | conventions.sourceKind | +8 requested by W19 (forwarded) |
| ActivityKind | CAPTURE, TRANSCRIPTION, TEXT_EXTRACTION, SEGMENTATION, EXTRACTION, RESOLUTION, REANCHORING, ADJUDICATION, ANSWER_COMPOSITION | conventions | DISCOVERY requested (W19) |
| AgentKind | MANUAL_AGENT, AUTOMATED_AGENT, TEXT_MINING_AGENT, DATA_ANALYSIS_PIPELINE, COMPUTATIONAL_MODEL, MANUAL_VALIDATION_OF_AUTOMATED_AGENT | conventions | |
| UseKind | QUOTE_IN_ANSWER, SUMMARIZE_IN_ANSWER, USE_AS_RECOMMENDATION_EVIDENCE, SHARE_EXTERNALLY | conventions | |
| EquivalenceKind | SAME_WORK_DIFFERENT_NAME, OVERLAPPING_SCOPE, RELATED_NOT_EQUIVALENT, NOT_EQUIVALENT | conventions | merge-redirect value requested (W00-SR-05) |
| QualificationKind, RetellingMode, RetellingLinkBasis, RelevanceLevel, RelevanceBasis, DisclosureFinding, TemporalOverlap | catalog values | conventions | used by W21 types |
| AnchorMatch | EXACT, FUZZY | property card REANCHORS | |
| QuantityBasis | PER_DAY, PER_DOSE, PER_SERVING, PER_KG_BODY_WEIGHT_PER_DAY, SINGLE_DOSE | conventions | |
| MassBasis | SALT_FORM, ACTIVE_MOIETY, MATERIAL_AS_IS, UNSPECIFIED | conventions | |
| AmountReferent | NUTRIENT_AS_NUTRIENT, LISTED_INGREDIENT_AS_LISTED, PROPRIETARY_BLEND_TOTAL, EXTRACT_TOTAL, MARKER_CONSTITUENT, NOT_STATED | conventions | |
| ReportedStatus | REPORTED, NOT_REPORTED, NOT_APPLICABLE | conventions | |
| RenditionCoverage (CANDIDATE) | FULL, PARTIAL, UNKNOWN | W19-SR-02 | |

AccessTier and TraceDepth are W23's (contract B5) and absent here.

## 6. Union cards

| Union | Members | Rule |
|---|---|---|
| AssertionSubjectTarget | 147 registry types of the Entity/VersionedState/Occurrence/InformationArtifact archetypes (list and exclusions in the SDL description) | CANDIDATE membership; parent-only; Fable prunes |
| AsserterTarget | Person, Organization, Agent, PseudonymousActor, AnonymousActor | catalog ASSERTED_BY range |
| SupportedRecordTarget | Assertion, Adjudication, ResolutionHypothesis, EquivalenceAssessment, EvidenceApplicability, ApplicabilityDimension, EndpointClassification, ResultInterpretation, EvidenceSynthesis, EvidenceStrengthAssessment, ClaimEvidenceAssessment, RetellingFidelityAssessment, ConflictRelevanceAssessment, ComparabilityAssessment, PassFailInterpretation, CommerceMatch | catalog SUPPORTED_BY domain |

## 7. Source references

Catalog 0.2.0 `conventions`, `baseArchetypes`, modules provenance/temporal/identity_resolution; contract A, B3–B7; rounds 0006 (KCR-4.1…4.6), 0007 (KCR-0007-1…3, TM-R1…R6), 0009 (K-1…K-7); property cards P-1…P-14, T-01…T-24, round 0006 §A–F; S-01…S-13 in `03-source-manifest.md`.
