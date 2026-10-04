# 09 Kernel reconciliation (W00, Wave 4)

Run `run-2026-10-04-fable51-01`, worker W00. This pass rules on every seam request addressed to W00 (alone or "W00 with ..."), updates the W00 packet, and leaves the frozen contract text unchanged: accepted contract changes are listed in section 4 for Fable to carry into the decision report. Machine-readable twin: `seam-rulings.yaml` (one entry per request, same ruling ids).

## 1. Scope and method

- Requests ruled: **148** = 132 W00-targeted entries of the consolidated inventory (337 total), 1 ledger-only entry found in W09 (W09-CR-01..04 counted with the inventory), 7 W15 requests published after the inventory was built, and 8 W00-SR items Fable named in the brief (W00-SR-01, -02, -05, -07, -10, -11, -12, -14).
- Rulings: ACCEPTED 135, ACCEPTED_AS_CANDIDATE 11, REJECTED 2, DEFERRED 0 (whole requests). Parts of accepted requests that lacked their own failing case are deferred inside the entry (CHARACTERIZES_EXPOSURE_IN_POPULATION, FORECASTS_COMMERCIAL_OPPORTUNITY, REPORTS_LIFESPAN_EFFECT, DERIVE_MEDIA, USED -> MediaRightsRecord).
- Re-scan: W10, W15, W17, W18 had no seam file at 01:50Z; W15 published one during the pass (7 W00-targeted requests, ruled here); W10, W17, W18 still had none at the final re-scan (section 6). W21 had published its packet; its 12 requests are ruled.
- Evidence: every ruling cites the requester's source or failing case. Validator rulings were executed (section 5). The SDL fragment was rebuilt with stubs and inside the full merge (section 5).

## 2. Theme rulings

### W00-R-01 uid tokens

One token per primary label, collected in uid-token-registry.yaml (177 labels: 47 catalog 0.2.0 label keys kept unchanged, 130 added or confirmed). Refinement specializations (a node may gain the label later) use the parent token (T2: LegalEntity, RegulatoryAgency, TestingLaboratory -> org; IngredientMaterial subtypes and FoodItem -> material; Organ -> anatomical-context; LabelSnapshot -> snapshot; DrugApproval, OrphanDesignation -> regulatory-status). Creation-time kinds may carry their own token (T3: Document, ClaimOccurrence, AdverseEventResult, CohortParticipant, SourceDiscoveryRecord, TradeItemIdentifier). Collisions: platform = W21 Platform, TechnologyPlatform = technology-platform (W08 yields, as W08 proposed); outcome = W03 Outcome, OutcomeDefinition = outcome-definition; SpecificationCriterion = spec-criterion (owner W12 over W11 suggestion; W11 fallback: migrate). experience-report rejected (type retired). 16 merged-fragment labels still have no token (owners W10, W17, W18, W21 assessments, W08 ToolOrInstrument); V-W00-16 reports them as LABEL_HAS_NO_TOKEN.

Artifacts: uid-token-registry.yaml; V-W00-16; fixtures/validation-params-w00.json uidTypeTokens.

### W00-R-02 QUANTITY assertions: object plus quantity

For predicateClass QUANTITY only, an Assertion may carry one HAS_OBJECT plus one numeric literal (valueNumber + unitCode, with quantityBasis, massBasis, amountReferent); objects + literals >= 1 and valueString/valueBoolean never ride with an object. Every other class keeps INV-003 literal-xor-object. Failing cases: W02 fx-91 (two literal-only CALCULATED amounts, refersTo null), W04 w04-03 (component -> NR cation 263.42 mg fails V-003), W07-SR-13 (CHANGED_BETWEEN delta). W01-SR-22 (stake) is COMMERCIAL and keeps its workaround; the QUANTITY route is its future path. W04 literal-only fallback stays valid.

Artifacts: V-003r; fixture 13 P2/N2; predicate-registry.yaml.

### W00-R-03 Qualifiers of asserted edges

An asserted edge qualifier (W09 analysisRole, asReportedName, armRole; IdentifierLinkProperties.isPrimary) is stored on the authorizing Assertion under the edge property name, typed by the owner, copied to the edge and covered by contentHash. Generic key/value string lists on Assertion (W09 option a) are rejected: untyped and outside the owners' enums. Failing case W09 fixtures/03 (analysisRole in valueString -> V-003 rows).

Artifacts: V-505r QUALIFIER_DIFFERS:<key>; V-505i (informational); fixture 13 P5/N5.

### W00-R-04 uid for API creates

Contract B2 keeps id: ID! @id. Every create of a uid-identified record goes through the ingestion service, which mints the opaque id, writes uid = hu:<token>: + id and MERGEs on uid inside the write-guarded transaction (07-operations.md G0-G6). GraphQL create mutations for these types are not exposed by the deployed API (application-enforced); updates stay limited by @settable. Alternative (b), a client-supplied id without @id, is recorded and not adopted because it changes the frozen B2 skeleton for every type. Failing cases: W00 T5a, W12 round trip (random id, V-117 row).

Artifacts: 10-kernel-operations-delta.md section 5.

### W00-R-05 uid/id on the archetype interfaces

uid: String! and id: ID! added to AssertionArchetype and EvidenceAssessmentArchetype. Failing case W23 checks/roundtrip-variant-a-contract-B3.json ("uid is not defined by type EvidenceAssessmentArchetypeWhere"). Every implementer already has both through Entity, so the merged schema builds. The other four archetype interfaces are unchanged (no failing case).

Artifacts: sdl-fragment.graphql.

### W00-R-06 privacyClass stored casing

Stored values are the GraphQL enum names PUBLIC and INTERNAL; any other stored value (public, internal, private-personal, PRIVATE_PERSONAL, synthetic) is a violation; private data never enters the shared graph (D-012). Lower-case values are migrated (public -> PUBLIC, internal -> INTERNAL; synthetic -> INTERNAL (fixture data is never public); private-personal -> removed from the shared graph). Requests W16-SR-04, W23-SR-08, W07-SR-15.

Artifacts: V-313r, V-521r (absorbs V-W23-09, V-W23-10); 10-kernel-operations-delta.md section 2.

### W00-R-07 Predicate registrations, exclusivity, forbidden implications

Collected in predicate-registry.yaml with predicateClass and owner module: REGISTERED when a failing case exists, CANDIDATE otherwise usable, DEFERRED without failing case or owner. predicateExclusivity gains STRAIN_OF, HAS_PATHWAY_VERSION (EXCLUSIVE per subject) and HAS_CAPABILITY_STATE, GOVERNED_BY_SPECIFICATION (EXCLUSIVE with partitionByPath, enforced by the ingestion service and audited by W11 validators); IP_STATUS_OF stays NONEXCLUSIVE. Twenty implication pairs added (W12, W13, W14, W15, W22, W09).

Artifacts: predicate-registry.yaml; validation-params-w00.json.

### W00-R-08 SourceKind values

Kernel enum. Added: TRIAL_REGISTRY_RECORD, BIBLIOGRAPHIC_RECORD, NEWS_ARTICLE, LEGISLATION_OR_REGULATION, PRESENTATION_SLIDES, PERSONAL_WEBPAGE, TECHNICAL_DOCUMENTATION, LABORATORY_REPORT, REINSTATEMENT_NOTICE, PODCAST_FEED, EVENT_TRANSCRIPT, MEDIA_FILE, MEDIA_REPOSITORY_RECORD, DATA_REPOSITORY_RECORD, OTHER (with Source.sourceKindNote, V-W00-17), and CANDIDATE BLOG_OR_REVIEW_PAGE, STOREFRONT_STRUCTURED_DATA. Conflict W09 BIBLIOGRAPHIC_DATABASE_RECORD vs W19 BIBLIOGRAPHIC_RECORD: W19 wins (registry owner; one value for every bibliographic database); W09 fallback: use BIBLIOGRAPHIC_RECORD. Revision states are never kinds; notices are documents, so REINSTATEMENT_NOTICE joins the existing notice kinds.

Artifacts: sdl-fragment.graphql (Fable carries into B5).

### W00-R-09 ActivityKind values

Kernel enum. Added CALCULATION (W02-SR-04), DISCOVERY (W19-SR-03), MEDIA_GENERATION, MEDIA_TRANSFORMATION, MEDIA_ASSESSMENT (W22-SR-04). Each has a failing case.

Artifacts: sdl-fragment.graphql.

### W00-R-10 UseKind and RelevanceBasis values

UseKind DISPLAY_MEDIA (W22-SR-02 and W23-SR-15 ask for the same use; W22 name wins because it covers pages and exports, not only answers; W23 fallback: none, PolicyVersion.permittedUseKinds follows UseKind). QUOTE_IN_ANSWER never covers images. DERIVE_MEDIA DEFERRED to W23 (no failing case). RelevanceBasis SAME_SERVICE_CATEGORY (W21-SR-14, fx03).

Artifacts: sdl-fragment.graphql.

### W00-R-11 Identity-merge redirect

Contract A2 redirect = an EquivalenceAssessment with equivalenceKind SAME_IDENTITY_MERGED plus survivingUid and retiredUid (both its two COMPARES_IDENTITIES targets). The retired node stays (maturity DEPRECATED); a held uid resolves through the latest ACCEPTED redirect recorded at or before the viewpoint; private records are never rewritten; re-stated assertions use SUPERSEDES {DUPLICATE_MERGE}. Conflict: W00-SR-05 proposed redirectToUid on the retired node; W23-SR-06 proposed fields on the record. W23 shape wins (immutable, carries recordedAt); W00 names the kind (W23 fallback: equivalenceKind replaces its redirectKind field).

Artifacts: sdl-fragment.graphql; V-432r; V-W00-13; fixture 13 Q13-a.

### W00-R-12 massBasis and amountReferent on AssertionArchetype

Added to the interface (contract A11 makes them mandatory qualifiers). Merged-build check: ClaimOccurrence and RelationshipAssertion (W21) already carry them; ContraindicationAssertion and InteractionAssertion (W17) must add two nullable fields; with that addition the merged schema builds (Neo4jGraphQL 7.6.3 BUILD OK).

Artifacts: sdl-fragment.graphql; 10-kernel-operations-delta.md section 6.

### W00-R-13 Point-in-time statements and the as-of ladder

Assertion.statedAsOf + statedAsOfPrecision record a source-stated witness instant ("as of April 25, 2025"); bounds stay null with UNKNOWN basis. QS-W00-P gains KNOWN_AT_WITNESS (V inside the witness precision period). Open-end witness = coalesce(publishedAt, observedAt) for PRESENT or null statedTense (W01-SR-08). The precision-aware ladder replaces raw-bound QS-2a/2b (W01-SR-04). Not copied onto edges (B4 frozen; readers join by assertionUid).

Artifacts: sdl-fragment.graphql; V-503r; fixture 13 Q13-b.

### W00-R-14 Source and Document stored names

Source.name reads the stored title (@alias(property: "title")) and the separate Source.title field is removed, so a :Document:Source node shows one title through both types (W20-SR-08 failing case N13/N14). Document writes canonicalUri equal to url (W20-V05) and dual-writes id = documentId (W00-SR-03). Contract B2 alias list gains Source.name -> title (Fable).

Artifacts: sdl-fragment.graphql.

### W00-R-15 renditionCoverage and canonicalUri

Already adopted in the first pass and confirmed: Source.renditionCoverage (CANDIDATE), canonicalUri = post-redirect retrieval endpoint, never a resolver; V-235 joins by RENDITION_OF; QS-7 requires a COMPLETE capture of a FULL rendition.

Artifacts: V-235r; V-W00-19.

### W00-R-16 HAS_SNAPSHOT vs HAS_STATE

HAS_SNAPSHOT means Source -> SourceSnapshot only. Entity state caches (Organization -> OrganizationSnapshot, Product -> ProductSnapshot, MerchantListing -> ListingSnapshot) use HAS_STATE with StateEpisodeProperties; the stored relabel runs at migration; GraphQL field names stay. W04 preferred keeping a read-only legacy name; overruled because a label-free capture traversal cannot be guarded.

Artifacts: V-W00-15; 10-kernel-operations-delta.md.

### W00-R-17 EVALUATES vs LEGACY_EVALUATES

EVALUATES means Adjudication -> Assertion only. The legacy Study -> intervention edge is stored as LEGACY_EVALUATES (W09-SR-13), read through Study.evaluates.

Artifacts: V-W00-15; 10-kernel-operations-delta.md.

### W00-R-18 PROV relationship ranges

WAS_GENERATED_BY domain adds Segmentation, AnswerRecord, MediaAsset, MediaVariant, MediaAnnotation, PriceObservation, Offer, AffiliateLink (MediaSuitabilityAssessment is already an EvidenceAssessment); USED range adds MediaAsset, MediaVariant, MediaAnnotation. USED -> MediaRightsRecord DEFERRED (conditional request, no failing case).

Artifacts: sdl-fragment.graphql Activity fields.

### W00-R-19 MENTIONS split

Kernel MENTIONS stays SourceLocator -> Mention (structural). Entity-level retrieval links from Chunk, Episode, ProtocolResult and ProductLabelRegion are MENTIONS_ENTITY (derived, ruleOnly, RetrievalEdgeProperties, W20 sole writer). W20 preferred one name split by start label; the rename wins because label-free counts and traversals cannot be guarded (W21-SR-10). W20/W21/W16 fallback: keep their GraphQL field names (mentions) with the new type.

Artifacts: V-W00-15; predicate-registry.yaml.

### W00-R-20 IDENTIFIED_BY vs HAS_IDENTIFIER

One meaning, one type: IDENTIFIED_BY is relabelled HAS_IDENTIFIER (IdentifierLinkProperties, asserted) at migration; W04 and W15 keep tradeItemIdentifiers fields (target TradeItemIdentifier) with type HAS_IDENTIFIER; IDENTIFIED_BY leaves $assertedTypes.

Artifacts: V-W00-15; validation-params-w00.json.

### W00-R-21 AssertionSubjectTarget membership

MR-01 and MR-02 applied: dropped Association, FoodProduct, ExperienceReport, MediaSource (retired), Organ, LabelSnapshot, FoodItem (specializations), SafetySignal and NarrativeArc (now EvidenceAssessment archetype, moved to SupportedRecordTarget). Added FirmwareVersion (W08), IpRightStatus (W14), MediaRightsRecord (W22), RegulatoryPathwayVersion and RegulatoryInspection (W13), UseConstraint (completeness). prune-unions over the merged fragments now reports no W00 change.

Artifacts: sdl-fragment.graphql.

### W00-R-22 SupportedRecordTarget and SUPPORTED_BY domain

Adds captured-record types that report what a source said: StudyResult, RegistrationVersion, ProtocolVersion (W09-SR-03), MeasuredResult, LotTestSummary, CertificateOfAnalysis (W12-SR-02), PriceObservation, AffiliateLink (W15-SR-09), and every EvidenceAssessment-archetype type of the merge (SafetySignal, NarrativeArc, EventImpactAssessment, MediaSuitabilityAssessment, SourceAuthorityAssessment). Assertion covers ClaimOccurrence, RelationshipAssertion, ContraindicationAssertion, InteractionAssertion (MR-01).

Artifacts: sdl-fragment.graphql.

### W00-R-23 ruleOnly derived types and V-112

ruleOnly: RESOLVES_TO_CHUNK, HAS_CHUNK, OCCURS_IN_SEGMENT, ABOUT, MENTIONS_ENTITY (W20-SR-01), HAS_CURRENT_PROTOCOL_STEP (W16-SR-06), COMPARED_TO for the same-version clause only (W07-SR-10). SUPPORTED_BY_CHUNK and SUPPORTED_BY_DOCUMENT need inputs. V-112r reads the hypothesis citation from derivedFromAssessmentUids and flags RULE_ONLY_ACROSS_VERSIONS.

Artifacts: V-112r; validation-params-w00.json.

### W00-R-24 Normalization versions and offsets

IMG-PX1 (W22-SR-05) registered for IMAGE_REGION; W00-SR-10 IMG-REL-XYWH-1 withdrawn (W22 owns the geometry; locators are bound to one raster). LIG-HY1 registered as matching-only (CANDIDATE; never for quoteHash; NFKC rejected). Offsets count code points of DocumentTextVersion.text as stored (W20-SR-19).

Artifacts: fixture 10.

### W00-R-25 Derived RECOMMENDS

RECOMMENDS is derived in rule mode: derivationRule + exactly one derivedFromAssertionUids whose assertion has speechAct RECOMMENDS, is asserted by the start node and names the end node; never assertionUid or projectionOfAssertionUid (answers the W05 ledger question). A legacy assertionUid is accepted by V-423r only as a migration fallback and reported by V-W00-02r.

Artifacts: V-423r; V-W00-02r.

### W00-R-26 Mechanism projections in rule mode

Mechanism projections cite inputs through derivationRule mx-proj/v1 + derivedFromAssertionUids (or a 1:1 projectionOfAssertionUid); V-233r/V-234r replace V-233/V-234 (W03-SR-01).

Artifacts: V-233r, V-234r.

### W00-R-27 Field-level privacy on kernel types

Adopted as W23-SR-10 lists; recorded in the fragment banner; W23 owns the closure table.

Artifacts: sdl-fragment.graphql banner.

### W00-R-28 Runtime prerequisite APOC

APOC Core 5.26.31 (with apoc-common) is a runtime prerequisite of @neo4j/graphql 7.6.3 for DateTime reads (W00-SR-14, W12-SR-11, W13-SR-16, W15-SR-16).

Artifacts: 10-kernel-operations-delta.md section 4.

### W00-R-29 Provenance reading rules without schema change

No automatic SUPPORTED_BY join through REANCHORS (W20-SR-06); quoteHash range index and computed cross-rendition join (W20-SR-07); DELIMITED_BY is a W21 structural relationship (W21-SR-03); RENDITION_TEXT_DISAGREES trace gap (W21-SR-21).

Artifacts: 10-kernel-operations-delta.md.

### W00-R-30 observedInContext

Assertion.observedInContext confirmed; DERIVED_FROM_ASSERTION also carries premises of INFERRED_FROM_MEASUREMENT assertions (W03-SR-02).

Artifacts: sdl-fragment.graphql.

### W00-R-31 Content clock for REANCHORS and revisions

V-409r and V-512r order by coalesce(observedAt, retrievedAt); a cache hit records observedAt = cache time (W19-SR-15).

Artifacts: V-409r, V-512r.

### W00-R-32 V-432 relationship name

V-432r matches COMPARES_IDENTITIES and checks the redirect fields.

Artifacts: V-432r.

### W00-R-33 V-006 ranges

V-006r = V-W02-10.

Artifacts: V-006r.

### W00-R-34 W09 validator corrections

V-211r, V-215r, V-217r + V-217i, V-221r adopted.

Artifacts: validation-corrections.cypher.

### W00-R-35 W07 validator corrections

V-302r, V-303r, V-304r, V-305c adopted; V-314..V-318 by reference.

Artifacts: validation-corrections.cypher.

### W00-R-36 W13 and W11 validator corrections

V-322r, V-333r, V-334r (W13-SR-15) and V-324r (W11-SR-11) adopted.

Artifacts: validation-corrections.cypher.

### W00-R-37 Episode coverage of V-503/V-505

V-503r and V-505r cover assertions and every edge naming an authorizing assertion or listed in $episodeTypes (W12-SR-09); V-505r generalizes V-W00-11.

Artifacts: validation-corrections.cypher.

### W00-R-38 Protocol step validators

V-525r/V-526r restated on HAS_PROTOCOL_STEP (W16-SR-14).

Artifacts: validation-corrections.cypher.

### W00-R-39 Exclusive-attachment validators

V-108r informational (review queue), V-508r/V-509r over $exclusiveTypes with partition coalesce(r.jurisdiction, t.jurisdiction) (W04-SR-03).

Artifacts: validation-corrections.cypher.

### W00-R-40 Validator adoptions from W20, W21, W22

W20-V01 replaces V-407; V-W21-12 replaces V-416 (Assertion.qualifiedBy added); W20-V02..V10, V-W21-*, V-601..V-615 adopted by reference.

Artifacts: validation-corrections.cypher; sdl-fragment.graphql.

### W00-R-41 Validation parameters

V-101 and V-W00-02 read $assertedTypes/$derivedTypes; validation-params-w00.json adds the W01, W08, W13, W15, W21 types and drops IDENTIFIED_BY.

Artifacts: fixtures/validation-params-w00.json.

### W00-R-42 Jurisdiction code convention

ISO 3166-1 alpha-2; ISO 3166-2 subdivisions; reserved EU; GB-GBN as a registered code pending verification against ISO 3166-2:GB (not fetched in this pass); "UK" forbidden. CANDIDATE until verified.

Artifacts: 10-kernel-operations-delta.md section 5.

### W00-R-43 Content-derived opaque segments

DocumentTextVersion, Segmentation and Chunk may use a hex sha256 of their identity tuple as the opaque uid segment (W20-SR-09).

Artifacts: 10-kernel-operations-delta.md section 5.

### W00-R-44 Domain enums: kernel conflict check only

ResultQualifier, ReferenceIntervalDerivation (W07), PathwayKind, RegulatoryResponseKind (W13), OfferKind, ObservedAvailability, CommerceMatch enums (W15), SexScope, ExposureRoute, ExposureStatus, MolecularEntityKind (W03), AuthorityScope (W19), DocumentType TRANSCRIPT (W20/W21), IpRightStatus (W14): none collides with a kernel enum name or value meaning.

Artifacts: none.

### W00-R-45 Routed or declined

Examples repairs (W02-SR-17, W04-SR-12, W20-SR-23, W21-SR-17) belong to Fable; @declareRelationship on interface fields is a contract B1 change for Fable (W07-SR-01); route vocabulary is W09 domain business (W16-SR-09 REJECTED as a kernel request).

Artifacts: none.

### W00-R-46 W19 authority scope

AuthorityScope and predicateAuthorityScopes admitted as CANDIDATE; V-324r is the hard rule until rows exist.

Artifacts: none.

### W00-R-47 W15 catalog ranges

Kernel check only; no kernel relationship touched.

Artifacts: none.

### W00-R-48 W09 relationship-property types

PublicationRevisionProperties must contain every AssertedEdgeProperties field; LegacyInterventionArmProperties is legacy read-only.

Artifacts: none.

## 3. Conflicts ruled (winner, loser, loser fallback)

| Conflict | Winner | Loser fallback | Ruling |
|---|---|---|---|
| `platform` token: W21 Platform vs W08 TechnologyPlatform | W21 Platform keeps `platform` | W08 uses `technology-platform` (its own proposal) | W00-R-01 |
| `outcome` token: W03 Outcome vs W09 OutcomeDefinition | W03 Outcome | OutcomeDefinition `outcome-definition`; old uids redirected | W00-R-01 |
| SpecificationCriterion token: W11 `specification-criterion` vs W12 `spec-criterion` | W12 (owner) | W11 migrates any hu:specification-criterion: uid | W00-R-01 |
| Bibliographic SourceKind: W09 BIBLIOGRAPHIC_DATABASE_RECORD vs W19 BIBLIOGRAPHIC_RECORD | W19 | W09 writes BIBLIOGRAPHIC_RECORD | W00-R-08 |
| Media use kind: W22 DISPLAY_MEDIA vs W23 DISPLAY_MEDIA_IN_ANSWER | W22 | W23 PolicyVersion.permittedUseKinds uses DISPLAY_MEDIA | W00-R-10 |
| Merge redirect: W00-SR-05 redirectToUid on the retired node vs W23-SR-06 survivingUid/retiredUid on the record | W23 field shape, W00 kind name SAME_IDENTITY_MERGED | W23 replaces redirectKind with equivalenceKind | W00-R-11 |
| MENTIONS: W20 keep name split by start label vs W21 rename | W21 (rename to MENTIONS_ENTITY) | W20, W21, W16 keep their `mentions` field names with the new type | W00-R-19 |
| HAS_SNAPSHOT: W04 keep legacy read-only vs W01/W20/W00 relabel | relabel to HAS_STATE | W04 keeps field names; V-W00-15 audits leftovers | W00-R-16 |
| Image normalization: W00-SR-10 relative fractions vs W22-SR-05 pixels (IMG-PX1) | W22 | fractions computed at read time; W00 fixture 10 switched | W00-R-24 |
| W09-SR-12 qualifiers: key/value lists on Assertion vs edge carrier | typed properties stored on both sides | none needed | W00-R-03 |
| W15-SR-09(b): string sourceLocatorUid vs SUPPORTED_BY edge | SUPPORTED_BY edge | sourceLocatorUid may stay as a denormalized cache (V-W15-08) | W00-R-22 |
| W16-SR-02: STEP_OCCURRENCES_PER_WEEK vs STEP_SCHEDULE_REPORTED | generic STEP_SCHEDULE_REPORTED (UCUM rate unit) | none | W00-R-07 |
| W04-SR-04: literal ACTIVE_MOIETY_AMOUNT vs QUANTITY object form | QUANTITY object form preferred | literal-only form still valid under V-003r | W00-R-02 |

## 4. Changes Fable carries (frozen contract and catalog text untouched here)

- Contract B1: `@declareRelationship` allowed on interface fields (W07-SR-01; already required by MR-03).
- Contract B2: alias list gains `Source.name -> title` (W00-R-14); `id: ID! @id` unchanged, creates through the ingestion service (W00-R-04).
- Contract B3: `uid: String!`, `id: ID!` on AssertionArchetype and EvidenceAssessmentArchetype (W00-R-05); `massBasis`, `amountReferent` on AssertionArchetype (W00-R-12; W17 adds two nullable fields).
- Contract B5: SourceKind +17 values (2 CANDIDATE), ActivityKind +5, UseKind +1, EquivalenceKind +1, RelevanceBasis +1 (W00-R-08..-11).
- Contract A2 / catalog identity_resolution: redirect = EquivalenceAssessment SAME_IDENTITY_MERGED with survivingUid/retiredUid (W00-R-11).
- INV-003: QUANTITY-class exception (W00-R-02); Assertion.statedAsOf/statedAsOfPrecision (W00-R-13).
- Catalog conventions: uidTypeTokens (uid-token-registry.yaml), predicateExclusivity and implication pairs (predicate-registry.yaml), normalizationVersions IMG-PX1 and LIG-HY1 (CANDIDATE), jurisdictionCode (CANDIDATE), liveIdProjection allows content-derived digests for DocumentTextVersion/Segmentation/Chunk.
- Catalog relationships: HAS_SNAPSHOT narrowed, HAS_STATE for state caches, LEGACY_EVALUATES, MENTIONS_ENTITY, IDENTIFIED_BY retired, ruleOnly flags, WAS_GENERATED_BY / USED / SUPPORTED_BY range extensions.
- validation.cypher: the 42 blocks of validation-corrections.cypher (replacements keep the frozen id with suffix r; new ids V-W00-13/15/16/17/19 need final numbers).

## 5. Evidence produced in this pass

- `sdl-fragment.graphql`: parses; builds with stubs under @neo4j/graphql 7.6.3 (see fragment-changelog.md for the numbers). Merged with every worker fragment on disk, union pruning reports no W00 member to drop; the merged schema builds once W17 adds massBasis/amountReferent to its two assertion types and Fable's MR-03 Observation alignment is applied.
- `validation-corrections.cypher`: run on embedded Neo4j 5.26.31 + APOC against W00 fixtures 01-13 and 30 worker fixture sets; original vs revised row counts in `fixtures/results/validation-corrections-runs.md`.
- New fixture `fixtures/13-reconciliation-rulings.cypher` + `13-queries.cypher` exercise W00-R-02, -03, -08, -11, -13, -16, -17, -19, -20, -01 and -06.

## 6. Re-scan log

RESCAN_PLACEHOLDER

## 7. Per-request rulings

| Request | Requester | Ruling | Ruling id | Change |
|---|---|---|---|---|
| W00-SR-01 | W00 | ACCEPTED | W00-R-12 | massBasis and amountReferent added to AssertionArchetype. Merged-build check: ContraindicationAssertion and InteractionAssertion (W17) must add the two nullable fields; with them the merged schema builds (10-kernel-operations-d... |
| W00-SR-02 | W00 | ACCEPTED | W00-R-04 | As W12-SR-11: creates through the ingestion service; option (b) (client-supplied id) is the recorded alternative, not adopted. |
| W00-SR-05 | W00 | ACCEPTED | W00-R-11 | As W23-SR-06; redirectToUid on the retired node withdrawn. |
| W00-SR-07 | W00 | ACCEPTED | W00-R-20 | IDENTIFIED_BY relabelled HAS_IDENTIFIER (IdentifierLinkProperties) at migration; W04/W15 keep tradeItemIdentifiers fields with type HAS_IDENTIFIER; removed from $assertedTypes; V-W00-15 USE_HAS_IDENTIFIER. |
| W00-SR-10 | W00 | REJECTED | W00-R-24 | IMG-REL-XYWH-1 withdrawn; fixture 10 uses IMG-PX1. |
| W00-SR-11 | W00 | ACCEPTED | W00-R-21 | Applied (prune-unions report: no W00 union member left to prune). |
| W00-SR-12 | W00 | ACCEPTED | W00-R-32 | V-432r. |
| W00-SR-14 | W00 | ACCEPTED | W00-R-28 | APOC core recorded as runtime prerequisite. |
| W01-SR-01 | W01 | ACCEPTED | W00-R-01 | uid-token-registry.yaml: OrganizationSnapshot org-snapshot, CohortParticipant cohort-participant; LegalEntity keeps org, Facility keeps facility. |
| W01-SR-02 | W01 | ACCEPTED | W00-R-12 | None in this pass (ActorIdentity.name is nullable). |
| W01-SR-03 | W01 | ACCEPTED | W00-R-16 | Entity state caches use HAS_STATE (StateEpisodeProperties); HAS_SNAPSHOT is Source -> SourceSnapshot only (fragment doc on Source.snapshots); V-W00-15 reports USE_HAS_STATE; migration relabel in 10-kernel-operations-delta.md. |
| W01-SR-04 | W01 | ACCEPTED | W00-R-13 | QS-2a/2b use the precision-aware class ladder (KNOWN_NOT_VALID, POSSIBLE_END_PRECISION, POSSIBLE_START_UNKNOWN, POSSIBLE_START_PRECISION, KNOWN, KNOWN_OPEN_END_WITNESSED, POSSIBLE_OPEN_END_STALE) plus KNOWN_AT_WITNESS from W00-... |
| W01-SR-06 | W01 | ACCEPTED | W00-R-41 | validation-params-w00.json $assertedTypes adds BOARD_MEMBER_OF, EMPLOYED_BY, ADVISES_ORGANIZATION, INVESTED_IN, HOLDS_EQUITY_IN, PARENT_OF, OWNS_BRAND, OPERATES_FACILITY, MARKETS_PRODUCT, MANUFACTURES_PRODUCT, DISTRIBUTES_PRODU... |
| W01-SR-07 | W01 | ACCEPTED | W00-R-13 | Assertion.statedAsOf: DateTime + statedAsOfPrecision: TimePrecision (generic Assertion only; immutable); V-503r requires the precision; the as-of ladder adds KNOWN_AT_WITNESS (fixture 13 Q13-b). Not copied to edges (B4 frozen):... |
| W01-SR-08 | W01 | ACCEPTED | W00-R-13 | Open-end witness = coalesce(snapshot.publishedAt, snapshot.observedAt) for statedTense PRESENT or null; live pages without publishedAt keep observedAt (QS-W00-P text). |
| W01-SR-22 | W01 | ACCEPTED | W00-R-02 | Keep the verbatim workaround for 0.3; when a CQ needs arithmetic, use a separate QUANTITY-class assertion (object = issuer, valueNumber = shares) that W00-R-02 now permits. |
| W02-SR-01 | W02 | ACCEPTED | W00-R-02 | INV-003 amended for predicateClass QUANTITY only: one HAS_OBJECT plus at most one numeric literal (valueNumber + unitCode, with quantityBasis/massBasis/amountReferent); every other class keeps literal-xor-object. V-003 replaced... |
| W02-SR-02 | W02 | ACCEPTED | W00-R-33 | V-006 replaced by V-006r (= V-W02-10). |
| W02-SR-03 | W02 | ACCEPTED | W00-R-01 | Rule T2 (refinement specializations use the parent token): BrandedIngredientMaterial, BotanicalPreparation, MicrobialPreparation, MaterialMixture -> material; botanical-taxon, microbial-taxon, microbial-strain, constituent, nut... |
| W02-SR-04 | W02 | ACCEPTED | W00-R-07 / W00-R-09 | predicate-registry.yaml: HAS_MOLECULAR_WEIGHT (QUANTITY literal) REGISTERED, QUANTITATIVELY_CONTAINS CALCULATED with IngredientComponent subject confirmed; ActivityKind CALCULATION added to the fragment. |
| W02-SR-05 | W02 | ACCEPTED | W00-R-07 | predicateExclusivity STRAIN_OF {EXCLUSIVE, subject}; STRAIN_OF added to $exclusiveTypes (V-108r/V-508r/V-509r). |
| W02-SR-17 | W02 | ACCEPTED | W00-R-45 | Routed to Fable: replace recordedAt = datetime() with literal values. No W00 change. |
| W02-SR-24 | W02 | ACCEPTED | W00-R-21 | AssertionSubjectTarget lists ChemicalSubstance, ChemicalForm, IngredientMaterial, BotanicalTaxon, MicrobialTaxon, MicrobialStrain, Constituent, Nutrient (specializations read through IngredientMaterial, MR-01). |
| W03-SR-01 | W03 | ACCEPTED | W00-R-26 | V-233/V-234 replaced by V-233r/V-234r; derivation rule mx-proj/v1 registered; V-112r unchanged in substance. |
| W03-SR-02 | W03 | ACCEPTED | W00-R-30 | Assertion.observedInContext confirmed; DERIVED_FROM_ASSERTION doc widened to "inputs of a CALCULATED assertion or premises of an INFERRED_FROM_MEASUREMENT assertion". |
| W03-SR-04 | W03 | ACCEPTED | W00-R-01 | Tokens pathway, condition, risk-factor; Organ -> anatomical-context (rule T2). |
| W03-SR-12 | W03 | ACCEPTED | W00-R-07 | predicate-registry.yaml: INCREASES_RISK_FOR, MEDIATES_RISK_THROUGH, ASSOCIATED_WITH_CONDITION, ASSOCIATED_WITH_OUTCOME REGISTERED; ACTS_IN added to $derivedTypes and V-233r. Domain enums (c) confirmed no kernel conflict (W00-R-... |
| W04-SR-01 | W04 | ACCEPTED | W00-R-01 | Tokens package-configuration, serving-definition, quantity-declaration, product-snapshot; LabelSnapshot -> snapshot (rule T2). |
| W04-SR-02 | W04 | ACCEPTED | W00-R-31 | V-409 replaced by V-409r (content clock coalesce(observedAt, retrievedAt)); same for V-512r. |
| W04-SR-03 | W04 | ACCEPTED | W00-R-39 | V-108r is informational (review queue); V-508r/V-509r partition by coalesce(r.jurisdiction, t.jurisdiction) over $exclusiveTypes. |
| W04-SR-04 | W04 | ACCEPTED | W00-R-02 / W00-R-07 | ACTIVE_MOIETY_AMOUNT and NUTRIENT_EQUIVALENT_AMOUNT REGISTERED as QUANTITY (object = moiety + valueNumber/unitCode, CALCULATED with inputs). W04 literal-only form remains valid under V-003r (objects 0, literal 1) as its fallback. |
| W04-SR-06 | W04 | ACCEPTED | W00-R-16 | Product -> ProductSnapshot moves to HAS_STATE at migration; W04 fragment fields keep their names (Product.snapshots / ProductSnapshot.product) with type HAS_STATE. Loser fallback: none required (mechanical relabel); V-W00-15 au... |
| W04-SR-12 | W04 | ACCEPTED | W00-R-45 | Routed to Fable; no W00 change. |
| W05-SR-01 | W05 | ACCEPTED | W00-R-01 | Tokens exposure, lifestyle; FoodItem -> material; specialization-token rule stated as T2/T3 in uid-token-registry.yaml. |
| W05-SR-09 | W05 | ACCEPTED | W00-R-21 | MR-01 applied to W00 unions: Organ, LabelSnapshot, FoodItem dropped from AssertionSubjectTarget (prune-unions report). |
| W05-SR-13 | W05 | ACCEPTED | W00-R-21 | Exposure and Lifestyle are AssertionSubjectTarget members (already present); CHARACTERIZES_EXPOSURE_IN_POPULATION DEFERRED to W10 in predicate-registry.yaml. |
| W06-SR-02 | W06 | ACCEPTED | W00-R-01 | Tokens treatment, procedure (W09-SR-04 asks the same procedure token). |
| W06-SR-12 | W06 | ACCEPTED | W00-R-07 | TARGETS_CONDITION, USES_COMPONENT REGISTERED; DECLARES_DEVELOPMENT_STAGE, HAS_TREATMENT_MODALITY, REPORTS_PROCEDURE_VOLUME CANDIDATE; FI-W06-01..15 kernel check: no conflict; SourceKind NEWS_ARTICLE added (W00-R-08). |
| W07-SR-01 | W07 | ACCEPTED | W00-R-45 | Contract B1 change for Fable: @declareRelationship allowed on interface fields (no arguments). No W00 fragment change. |
| W07-SR-03 | W07 | ACCEPTED | W00-R-44 | Confirmed no kernel conflict; NOT_REPORTED value is W07 ledger business. |
| W07-SR-06 | W07 | ACCEPTED | W00-R-44 | Confirmed no kernel conflict. |
| W07-SR-09 | W07 | ACCEPTED | W00-R-35 | V-303 replaced by V-303r. |
| W07-SR-10 | W07 | ACCEPTED | W00-R-23 | COMPARED_TO in $ruleOnlyDerivedTypes; V-112r adds RULE_ONLY_ACROSS_VERSIONS so rule-only applies to the INV-301 same-version clause only. |
| W07-SR-11 | W07 | ACCEPTED | W00-R-35 | V-302r, V-304r, V-305c in validation-corrections.cypher; V-314..V-318 adopted by reference (W07 keeps the text). |
| W07-SR-12 | W07 | ACCEPTED | W00-R-01 | Tokens panel-definition, reference-range plus Biomarker biomarker, Metric metric, LabTest lab-test, MeasurementMethod method, Specimen specimen-type, ReferenceSystem reference-system, Algorithm algorithm, ReferenceIntervalVersi... |
| W07-SR-13 | W07 | ACCEPTED_AS_CANDIDATE | W00-R-02 / W00-R-07 | CHANGED_BETWEEN CANDIDATE (QUANTITY; object = earlier result; optional valueNumber + unitCode delta). |
| W07-SR-15 | W07 | ACCEPTED | W00-R-06 | V-313 replaced by V-313r. |
| W08-SR-06 | W08 | ACCEPTED | W00-R-01 / W00-R-07 / W00-R-21 | Tokens device, technology-platform (platform stays W21 Platform), sensor, modality, firmware-version; FirmwareVersion added to AssertionSubjectTarget; the 14 predicates CANDIDATE and the 8 relationship types added to $assertedT... |
| W09-CR-01 | W09 | ACCEPTED | W00-R-34 | V-217 replaced by V-217r + V-217i (informational). |
| W09-CR-02 | W09 | ACCEPTED | W00-R-34 | V-221 replaced by V-221r. |
| W09-CR-03 | W09 | ACCEPTED | W00-R-34 | V-211 replaced by V-211r. |
| W09-CR-04 | W09 | ACCEPTED | W00-R-34 | V-215 replaced by V-215r. |
| W09-SR-02 | W09 | ACCEPTED | W00-R-48 | Accepted as W09 relationship-property types (Fable registry); kernel condition stated. |
| W09-SR-03 | W09 | ACCEPTED | W00-R-22 | SUPPORTED_BY domain and SupportedRecordTarget add StudyResult (covers AdverseEventResult), RegistrationVersion, ProtocolVersion. |
| W09-SR-04 | W09 | ACCEPTED | W00-R-01 | Tokens protocol-version, study-population, outcome-definition, adverse-event-result, device, procedure; fixture uids hu:outcome:<id> of OutcomeDefinitions migrate with SAME_IDENTITY_MERGED redirects. |
| W09-SR-12 | W09 | ACCEPTED | W00-R-03 | Rule: an asserted edge qualifier is stored on the authorizing Assertion under the edge property name (typed by the owner), copied to the edge, and covered by contentHash; V-505r reports QUALIFIER_DIFFERS:<key>, V-505i lists edg... |
| W09-SR-13 | W09 | ACCEPTED | W00-R-17 | Stored legacy type renamed LEGACY_EVALUATES at migration; Study.evaluates keeps its GraphQL name with type LEGACY_EVALUATES; EVALUATES is Adjudication -> Assertion only (fragment doc); V-W00-15 reports USE_LEGACY_EVALUATES. |
| W09-SR-14 | W09 | ACCEPTED | W00-R-08 | TRIAL_REGISTRY_RECORD and BIBLIOGRAPHIC_RECORD added (W19 spelling wins: one value covers PubMed, Crossref, OpenAlex records). W09 fallback: use BIBLIOGRAPHIC_RECORD wherever BIBLIOGRAPHIC_DATABASE_RECORD was planned. |
| W09-SR-16 | W09 | ACCEPTED_AS_CANDIDATE | W00-R-07 | CITES_AS_REFERENCE, EVALUATES_RISK_FACTOR CANDIDATE; [REGISTRY_RESULTS_NOT_POSTED, RESULTS_UNPUBLISHED] added to implicationPairs. |
| W11-SR-04 | W11 | ACCEPTED | W00-R-07 | predicateExclusivity HAS_CAPABILITY_STATE and GOVERNED_BY_SPECIFICATION with partitionByPath; enforced in the ingestion write transaction, audited by V-W11-02/07; excluded from the generic $exclusiveTypes checks. |
| W11-SR-08 | W11 | ACCEPTED | W00-R-01 | Tokens specification, specification-version, process, process-step, capability; SpecificationCriterion -> spec-criterion (owner wins; W11 fallback: migrate any hu:specification-criterion: uid). |
| W11-SR-09 | W11 | ACCEPTED_AS_CANDIDATE | W00-R-07 | CLAIMS_THIRD_PARTY_CERTIFICATION and SPECIFICATION_EFFECTIVE_FROM CANDIDATE (literal; never project to COVERS/CERTIFIED_UNDER or to a bound). |
| W11-SR-11 | W11 | ACCEPTED | W00-R-36 | V-324 replaced by V-324r (allowlist); SourceKind guidance: an 8-K press-release exhibit is PRESS_RELEASE. |
| W12-SR-01 | W12 | ACCEPTED | W00-R-01 | Tokens lot, test-sample, test-execution, test-method, measured-result, spec-criterion, pass-fail, lot-test-summary, coa, cert-program, cert-listing, cert-scope; TestingLaboratory -> org (T2). |
| W12-SR-02 | W12 | ACCEPTED | W00-R-22 | SupportedRecordTarget adds MeasuredResult, LotTestSummary, CertificateOfAnalysis (structural SUPPORTED_BY). |
| W12-SR-03 | W12 | ACCEPTED | W00-R-08 | SourceKind LABORATORY_REPORT added. |
| W12-SR-04 | W12 | ACCEPTED | W00-R-07 | CONFORMS_TO_SPECIFICATION REGISTERED (CLAIM, assertion-only). |
| W12-SR-07 | W12 | ACCEPTED | W00-R-07 | Six quality forbidden-implication pairs registered and added to implicationPairs. |
| W12-SR-09 | W12 | ACCEPTED | W00-R-37 | V-503r and V-505r cover every episode edge ($episodeTypes or any edge with assertionUid). |
| W12-SR-11 | W12 | ACCEPTED | W00-R-04 / W00-R-28 | Kernel and domain creates go through the ingestion service, which mints uid = hu:<token>: + id; GraphQL create mutations for uid-identified types are not exposed at deployment (application-enforced; the fragment keeps @mutation... |
| W13-SR-01 | W13 | ACCEPTED_AS_CANDIDATE | W00-R-42 | conventions.jurisdictionCode: ISO 3166-1 alpha-2; ISO 3166-2 subdivisions; reserved EU; GB-GBN registered as a BellLabs code pending verification (if absent from ISO 3166-2:GB it stays a documented local composite); "UK" forbid... |
| W13-SR-02 | W13 | ACCEPTED | W00-R-01 | RegulatoryAgency -> org; OrphanDesignation, DrugApproval -> regulatory-status (T2); RegulatoryPathway reg-pathway, RegulatorySubmission reg-submission, RegulatoryResponse reg-response; reg-status stays a fixture alias. |
| W13-SR-03 | W13 | ACCEPTED | W00-R-44 | Confirmed no kernel conflict; V-336 change is W13 validator business. |
| W13-SR-04 | W13 | ACCEPTED | W00-R-01 | reg-pathway-version, reg-step registered; regulatory-inspection ACCEPTED_AS_CANDIDATE; MaterialMixture uses material (not mixture). |
| W13-SR-05 | W13 | ACCEPTED | W00-R-07 / W00-R-21 | HAS_PATHWAY_VERSION {EXCLUSIVE, subject}, bitemporal_attachment profile; added to $exclusiveTypes, $assertedTypes and $episodeTypes; RegulatoryPathwayVersion added to AssertionSubjectTarget. |
| W13-SR-06 | W13 | ACCEPTED | W00-R-44 | Confirmed no kernel conflict. |
| W13-SR-07 | W13 | ACCEPTED_AS_CANDIDATE | W00-R-07 / W00-R-21 | INSPECTION_PERIOD, INSPECTION_FOUND_VIOLATION, INSPECTION_CLASSIFIED_AS CANDIDATE; two candidate FI pairs added; RegulatoryInspection added to AssertionSubjectTarget; relationship rows are W13 registry business. |
| W13-SR-15 | W13 | ACCEPTED | W00-R-36 | V-322r, V-333r, V-334r replace the originals; originals stay one release as migration checks (W13 proposal). |
| W13-SR-16 | W13 | ACCEPTED | W00-R-28 | APOC core 5.26.31 recorded as a runtime prerequisite (10-kernel-operations-delta.md section 4). |
| W14-SR-01 | W14 | ACCEPTED | W00-R-01 / W00-R-21 | Tokens patent-family, patent-application, granted-patent, patent-claim, patent-license, trademark; ip-status ACCEPTED_AS_CANDIDATE; IpRightStatus added to AssertionSubjectTarget. |
| W14-SR-02 | W14 | ACCEPTED_AS_CANDIDATE | W00-R-44 | Kernel check passed; admission is Fable registry business; union membership added (W00-R-21). |
| W14-SR-04 | W14 | ACCEPTED | W00-R-07 | PATENT_CLAIMS REGISTERED (assertion-only); six pairs added to implicationPairs so V-112r covers them. |
| W14-SR-08 | W14 | ACCEPTED | W00-R-07 | PredicateClass assignments confirmed; no new PredicateClass value. |
| W15-SR-07 | W15 | ACCEPTED | W00-R-47 | Confirmed no kernel conflict; catalog range extensions are W15/Fable business. |
| W15-SR-08 | W15 | ACCEPTED | W00-R-01 | Tokens listing, offer, price-obs, subscription-plan, bundle, bundle-component, inventory-item, individual-unit, affiliate-link, commerce-match. |
| W15-SR-09 | W15 | ACCEPTED | W00-R-18 / W00-R-22 | (a) WAS_GENERATED_BY domain adds PriceObservation, Offer, AffiliateLink (Activity inverse fields in the fragment); (b) SupportedRecordTarget adds PriceObservation and AffiliateLink; sourceLocatorUid may stay as a denormalized c... |
| W15-SR-10 | W15 | ACCEPTED | W00-R-44 | Confirmed; CommerceMatch enums decided by Fable at merge. |
| W15-SR-11 | W15 | ACCEPTED | W00-R-07 / W00-R-41 | (a) LISTING_TITLE_AMOUNT REGISTERED; (b) V-101r/V-W00-02r read $assertedTypes (W15 types added); (c) two AFFILIATE_FOR_OFFER pairs added to implicationPairs. |
| W15-SR-15 | W15 | ACCEPTED_AS_CANDIDATE | W00-R-08 | SourceKind BLOG_OR_REVIEW_PAGE and STOREFRONT_STRUCTURED_DATA added as CANDIDATE values; W19 may rename before 0.3. |
| W15-SR-16 | W15 | ACCEPTED | W00-R-28 | As W13-SR-16. |
| W16-SR-01 | W16 | ACCEPTED | W00-R-01 | Tokens measurement-plan, target, observation, protocol-result; ProtocolAdjustmentRule -> protocol-rule; condition (W03) and device (W08) registered by their owners. |
| W16-SR-02 | W16 | ACCEPTED | W00-R-07 / W00-R-21 | Seven predicates REGISTERED plus STEP_SCHEDULE_REPORTED (QUANTITY); Protocol, ProtocolEdition, ProtocolStep, Observation already in AssertionSubjectTarget. |
| W16-SR-04 | W16 | ACCEPTED | W00-R-06 | Stored privacyClass values are PUBLIC/INTERNAL; lower-case values migrate (10-kernel-operations-delta.md); V-313r, V-521r. |
| W16-SR-06 | W16 | ACCEPTED | W00-R-23 | HAS_CURRENT_PROTOCOL_STEP ruleOnly (rule protocol-current-steps-v1) in $ruleOnlyDerivedTypes and $derivedTypes; V-542p stays W16-owned. |
| W16-SR-09 | W16 | REJECTED | W00-R-45 | No kernel change. W16 fallback: W09 owns one shared route enum (or EDQM Standard Terms code string) and W16 switches to it; Fable rules ownership. |
| W16-SR-18 | W16 | ACCEPTED | W00-R-19 | ProtocolResult.mentions uses MENTIONS_ENTITY with RetrievalEdgeProperties (derived). W16 fallback for a curated link: an asserted Assertion, never a structural MENTIONS. |
| W19-SR-01 | W19 | ACCEPTED | W00-R-08 | Eight values added (TRIAL_REGISTRY_RECORD, BIBLIOGRAPHIC_RECORD, NEWS_ARTICLE, LEGISLATION_OR_REGULATION, PRESENTATION_SLIDES, PERSONAL_WEBPAGE, TECHNICAL_DOCUMENTATION, OTHER) plus Source.sourceKindNote; V-W00-17. |
| W19-SR-02 | W19 | ACCEPTED | W00-R-15 | Source.renditionCoverage (CANDIDATE enum RenditionCoverage) kept; FI [NOT_FOUND_IN_PARTIAL_CAPTURE, NOT_DISCLOSED] extended to complete captures of PARTIAL renditions. |
| W19-SR-03 | W19 | ACCEPTED | W00-R-09 | ActivityKind DISCOVERY added; SourceDiscoveryRecord shares the Activity label (read through Activity, MR-01); discovery-only fields stay on the specialization. |
| W19-SR-04 | W19 | ACCEPTED_AS_CANDIDATE | W00-R-46 | AuthorityScope (W19 enum) and conventions.predicateAuthorityScopes admitted as CANDIDATE; a predicate without a row reads NOT_ASSESSED; V-324r stays the hard check until rows exist. |
| W19-SR-05 | W19 | ACCEPTED_AS_CANDIDATE | W00-R-01 | source-authority, coverage-requirement, source-discovery ACCEPTED_AS_CANDIDATE with the candidate types. |
| W19-SR-09 | W19 | ACCEPTED | W00-R-31 | V-409r, V-512r (content clock). |
| W19-SR-10 | W19 | ACCEPTED | W00-R-15 | canonicalUri rule adopted (post-redirect endpoint, never a resolver); V-235r joins by RENDITION_OF; V-W00-19 promotes Q-02. |
| W19-SR-13 | W19 | ACCEPTED | W00-R-15 | QS-7 NOT_DECLARED_IN_COVERING_SOURCE requires a COMPLETE capture of a FULL rendition, else NOT_FOUND_IN_PARTIAL_CAPTURE. |
| W19-SR-15 | W19 | ACCEPTED | W00-R-31 | Ingestion rule: observedAt = the service cache time, retrievedAt = request time; the CAPTURE Activity methodVersion records cache state. No schema change. |
| W20-SR-01 | W20 | ACCEPTED | W00-R-23 | RESOLVES_TO_CHUNK, HAS_CHUNK, OCCURS_IN_SEGMENT, ABOUT, MENTIONS_ENTITY are ruleOnly; SUPPORTED_BY_CHUNK and SUPPORTED_BY_DOCUMENT are not. |
| W20-SR-02 | W20 | ACCEPTED | W00-R-01 | Token segmentation. |
| W20-SR-04 | W20 | ACCEPTED_AS_CANDIDATE | W00-R-19 | RetrievalEdgeProperties admitted as CANDIDATE (W20 sole writer; W21, W16, W22 reuse); maturity CANDIDATE until a retrieval evaluation exists. |
| W20-SR-05 | W20 | ACCEPTED | W00-R-18 | WAS_GENERATED_BY domain adds Segmentation; Activity.generatedSegmentations inverse field. |
| W20-SR-06 | W20 | ACCEPTED | W00-R-29 | No automatic join: a CAPTURE_FIDELITY review may add SUPPORTED_BY to the re-anchored locator (content unchanged); shortcuts regenerate from it. |
| W20-SR-07 | W20 | ACCEPTED | W00-R-29 | Range index on SourceLocator.quoteHash (10-kernel-operations-delta.md); cross-rendition agreement is a computed quoteHash join (candidate CQ-PV-C03); no stored edge. |
| W20-SR-08 | W20 | ACCEPTED | W00-R-14 | Source.name is @alias(property: "title") and the separate Source.title field is removed (one stored property, one field, as Document.name); canonicalUri required for new writes (Document writes url and canonicalUri equal; W20-V... |
| W20-SR-09 | W20 | ACCEPTED | W00-R-43 | Opaque segment may be a hex sha256 of the identity tuple for DocumentTextVersion, Segmentation, Chunk only (still opaque, never a name); liveIdProjection note amended. |
| W20-SR-10 | W20 | ACCEPTED | W00-R-08 | SourceKind REINSTATEMENT_NOTICE added (pairs with SourceRevisionKind REINSTATEMENT). |
| W20-SR-11 | W20 | ACCEPTED | W00-R-16 | As W01-SR-03. |
| W20-SR-13 | W20 | ACCEPTED | W00-R-19 | Kernel MENTIONS = SourceLocator -> Mention; entity-level retrieval edges are MENTIONS_ENTITY (derived, ruleOnly, RetrievalEdgeProperties). W20 fallback: Chunk.mentions keeps its GraphQL name with type MENTIONS_ENTITY; V-W00-15 ... |
| W20-SR-18 | W20 | ACCEPTED | W00-R-40 | V-407 replaced by W20-V01 (V-407r); W20-V02..V10 adopted by reference as W20 validators. |
| W20-SR-19 | W20 | ACCEPTED | W00-R-24 | Offsets count code points of DocumentTextVersion.text as stored; SourceLocator.normalizationVersion governs the quote hash only; writers convert UTF-16 offsets. |
| W20-SR-20 | W20 | ACCEPTED_AS_CANDIDATE | W00-R-24 | LIG-HY1 registered as a matching-only normalization (never for quoteHash); NFKC rejected; NFC-WS1 stays the only hash normalization. |
| W20-SR-23 | W20 | ACCEPTED | W00-R-45 | Routed to Fable (examples owner); W00 agrees with documentId, type, url and entityType Document. |
| W21-SR-01 | W21 | ACCEPTED | W00-R-01 | Platform: platform. |
| W21-SR-03 | W21 | ACCEPTED | W00-R-29 | DELIMITED_BY accepted as a W21-owned structural relationship (V-W21-05). |
| W21-SR-07 | W21 | ACCEPTED | W00-R-25 | V-423 replaced by V-W21-06 (V-423r); RECOMMENDS added to $derivedTypes; W05 ledger question answered: rule mode, never assertionUid or projectionOfAssertionUid. |
| W21-SR-10 | W21 | ACCEPTED | W00-R-19 | As W20-SR-13: MENTIONS_ENTITY for retrieval; Episode.mentions keeps its field name with type MENTIONS_ENTITY. |
| W21-SR-13 | W21 | ACCEPTED | W00-R-08 | SourceKind PODCAST_FEED, EVENT_TRANSCRIPT, PRESENTATION_SLIDES, NEWS_ARTICLE added; DocumentType TRANSCRIPT is W20 business (no kernel conflict). |
| W21-SR-14 | W21 | ACCEPTED | W00-R-10 | RelevanceBasis SAME_SERVICE_CATEGORY added. |
| W21-SR-15 | W21 | ACCEPTED | W00-R-07 | SELF_REPORTED_PRACTICE, OPERATES_CHANNEL, ACCOMPANIES_TALK REGISTERED; FORECASTS_COMMERCIAL_OPPORTUNITY and REPORTS_LIFESPAN_EFFECT DEFERRED. |
| W21-SR-16 | W21 | ACCEPTED | W00-R-40 / W00-R-41 | V-W21-06 -> V-423r, V-W21-12 -> V-416r; others adopted by reference; SPONSORS_CONTENT, OPERATES_CHANNEL, SERVES_ON_CHANNEL, ACCOMPANIES_TALK in $assertedTypes; RECOMMENDS in $derivedTypes. |
| W21-SR-17 | W21 | ACCEPTED | W00-R-45 | Routed to Fable (examples); W00 agrees with the target shape. |
| W21-SR-21 | W21 | ACCEPTED | W00-R-29 | QS-1a trace gap code RENDITION_TEXT_DISAGREES; cross-rendition discrepancies route to CAPTURE_FIDELITY adjudication (PARTIALLY_SUPPORTED). No schema change. |
| W21-SR-23 | W21 | ACCEPTED | W00-R-40 | Assertion.qualifiedBy / qualifies fields (QUALIFIED_BY, QualificationProperties owned by W21) added to the W00 fragment; V-416 replaced by V-W21-12 (V-416r). |
| W21-SR-25 | W21 | ACCEPTED | W00-R-21 | ExperienceReport dropped from AssertionSubjectTarget; no token. |
| W22-SR-01 | W22 | ACCEPTED | W00-R-01 | media-asset, media-variant, media-annotation, graph-view, figure-panel, label-region, media-assessment, media-rights; Pathway pathway (W03 agrees). |
| W22-SR-02 | W22 | ACCEPTED | W00-R-10 | UseKind DISPLAY_MEDIA added (covers answers, pages and exports); DERIVE_MEDIA DEFERRED to W23 (no failing case yet). W23 fallback: DISPLAY_MEDIA_IN_ANSWER is not added; PolicyVersion.permittedUseKinds uses DISPLAY_MEDIA. |
| W22-SR-03 | W22 | ACCEPTED | W00-R-18 | WAS_GENERATED_BY domain adds MediaAsset, MediaVariant, MediaAnnotation (MediaSuitabilityAssessment already an EvidenceAssessment); USED range adds MediaAsset, MediaVariant, MediaAnnotation; Activity forward and inverse fields a... |
| W22-SR-04 | W22 | ACCEPTED | W00-R-09 | ActivityKind MEDIA_GENERATION, MEDIA_TRANSFORMATION, MEDIA_ASSESSMENT added. |
| W22-SR-05 | W22 | ACCEPTED | W00-R-24 | IMG-PX1 registered in conventions.normalizationVersions; IMAGE_REGION locators must use a registered image normalization; W00 fixture 10 switched to IMG-PX1. W00 fallback: relative coordinates are computed at read time for cros... |
| W22-SR-06 | W22 | ACCEPTED | W00-R-08 | SourceKind MEDIA_FILE, MEDIA_REPOSITORY_RECORD, DATA_REPOSITORY_RECORD added. |
| W22-SR-08 | W22 | ACCEPTED | W00-R-07 / W00-R-40 | V-601..V-615 adopted by reference (statically checked; V-608b, V-610 informational); six media FI pairs added to implicationPairs. |
| W22-SR-13 | W22 | ACCEPTED | W00-R-21 | MediaSource dropped; MediaRightsRecord added to AssertionSubjectTarget; LOCATES_REGION / MediaAnnotation.locatedBy pairing confirmed. |
| W23-SR-01 | W23 | ACCEPTED | W00-R-01 | PolicyVersion policy-version, DecisionCriterion decision-criterion, AnswerRecord answer-record (catalog) keyed by label; experience-report rejected (type retired). |
| W23-SR-02 | W23 | ACCEPTED | W00-R-18 | WAS_GENERATED_BY domain adds AnswerRecord; Activity.generatedAnswerRecords; V-W23-03b may become a failing validator (W23). |
| W23-SR-03 | W23 | ACCEPTED | W00-R-05 | uid: String! and id: ID! added to AssertionArchetype and EvidenceAssessmentArchetype (every implementer already has them through Entity; merged build checked). |
| W23-SR-06 | W23 | ACCEPTED | W00-R-11 | EquivalenceKind SAME_IDENTITY_MERGED; EquivalenceAssessment.survivingUid/retiredUid; retired node kept with maturity DEPRECATED; V-432r and V-W00-13; fixture 13 Q13-a. W23 fallback: replace redirectKind DUPLICATE_MERGE with equ... |
| W23-SR-07 | W23 | ACCEPTED | W00-R-32 | V-432 replaced by V-432r (COMPARES_IDENTITIES + redirect fields). |
| W23-SR-08 | W23 | ACCEPTED | W00-R-06 | Stored values PUBLIC/INTERNAL; any other value is a violation (V-521r absorbs V-W23-09 and V-W23-10); V-313r; QS-5b/QS-6 private tests read hu:private- and any non-final class; lower-case migration. |
| W23-SR-10 | W23 | ACCEPTED | W00-R-27 | Field privacy classes adopted (fragment banner): Activity INTERNAL; Agent model/promptVersion/toolVersion INTERNAL; Adjudication humanReviewPending and reviewer edges INTERNAL; ResolutionHypothesis INTERNAL; mongoResearchRunId,... |
| W23-SR-15 | W23 | ACCEPTED | W00-R-10 / W00-R-18 | UseKind DISPLAY_MEDIA (W22 name); QUOTE_IN_ANSWER never covers images; USED range adds MediaAsset (W22-SR-03); USED -> MediaRightsRecord DEFERRED until a composing Activity must cite a rights record. |

Full rationale (source or failing case) and the exact change for each request: `seam-rulings.yaml`.
