# W00 SDL fragment changelog (reconciliation pass, 2026-10-04)

Every edit to `sdl-fragment.graphql` made in the Wave 4 reconciliation pass, with its ruling id (`09-kernel-reconciliation.md`,
`seam-rulings.yaml`). The frozen contract text is unchanged; items marked **B3/B5** are contract changes Fable carries.
The pre-pass fragment had 1643 lines and 71 definitions; the reconciled fragment has 1765 lines and 71 definitions
(10 interfaces, 21 object types, 37 enums, 3 unions).

## Build evidence

- Standalone with generated stubs for 159 foreign types (`w00-stubs.mjs`), @neo4j/graphql 7.6.3, graphql 16.14.2:
  `Neo4jGraphQL build: OK in 4453ms; vectorProviderConfigured=false; generated types=10497; queries=355; mutations=493; printed SDL chars=6182129` (pre-pass: 10,131 types).
- Full merge of every worker fragment on disk at 02:02Z (`merge-fragments.mjs` + Fable `prune-unions.mjs`): prune report lists **no**
  W00 union member any more (it listed 7 before this pass). graphql-js validation of the merge shows 4 interface errors caused by
  this pass: ContraindicationAssertion and InteractionAssertion (W17) lack `massBasis`/`amountReferent`; plus Fable's known
  Observation/DiagnosticResult alignment (MR-03). With the two nullable fields added to the two W17 types and the Observation
  alignment simulated, `new Neo4jGraphQL(...).getSchema()` on the merged file returns **BUILD OK** (33.6 s).

## Edits

| # | Location | Edit | Ruling |
|---|---|---|---|
| 1 | file banner | reconciliation note; field-level privacy table (INTERNAL fields) | W00-R-27 |
| 2 | interface AssertionArchetype | + `uid: String!`, `id: ID!` (**B3**) | W00-R-05 |
| 3 | interface AssertionArchetype | + `massBasis: MassBasis`, `amountReferent: AmountReferent` (**B3**) | W00-R-12 |
| 4 | interface EvidenceAssessmentArchetype | + `uid: String!`, `id: ID!` (**B3**) | W00-R-05 |
| 5 | enum SourceKind | + TRIAL_REGISTRY_RECORD, BIBLIOGRAPHIC_RECORD, NEWS_ARTICLE, LEGISLATION_OR_REGULATION, PRESENTATION_SLIDES, PERSONAL_WEBPAGE, TECHNICAL_DOCUMENTATION, LABORATORY_REPORT, REINSTATEMENT_NOTICE, PODCAST_FEED, EVENT_TRANSCRIPT, MEDIA_FILE, MEDIA_REPOSITORY_RECORD, DATA_REPOSITORY_RECORD, OTHER; CANDIDATE BLOG_OR_REVIEW_PAGE, STOREFRONT_STRUCTURED_DATA (**B5**) | W00-R-08 |
| 6 | enum ActivityKind | + CALCULATION, DISCOVERY, MEDIA_GENERATION, MEDIA_TRANSFORMATION, MEDIA_ASSESSMENT, CURATION (**B5**) | W00-R-09 |
| 7 | enum UseKind | + DISPLAY_MEDIA (**B5**) | W00-R-10 |
| 8 | enum EquivalenceKind | + SAME_IDENTITY_MERGED; description now says only this value publishes a redirect (**B5**) | W00-R-11 |
| 9 | enum RelevanceBasis | + SAME_SERVICE_CATEGORY (**B5**) | W00-R-10 |
| 10 | type Source | `name: String @alias(property: "title")`; separate `title` field removed (one stored property, one field, as Document.name) | W00-R-14 |
| 11 | type Source | + `sourceKindNote: String` (required when sourceKind OTHER, V-W00-17) | W00-R-08 |
| 12 | type Source | canonicalUri description: post-redirect endpoint, never a resolver | W00-R-15 |
| 13 | type Source.snapshots | doc: HAS_SNAPSHOT is Source -> SourceSnapshot only; state caches use HAS_STATE | W00-R-16 |
| 14 | type Assertion | + `statedAsOf: DateTime`, `statedAsOfPrecision: TimePrecision` (immutable) | W00-R-13 |
| 15 | type Assertion.statedTense | doc: FUTURE value for scheduled events | W00-R-13 |
| 16 | type Assertion | + `qualifiedBy` / `qualifies` (QUALIFIED_BY, QualificationProperties owned by W21) | W00-R-40 |
| 17 | type Assertion.evaluatedBy | doc: EVALUATES is Adjudication -> Assertion only; legacy study edge is LEGACY_EVALUATES | W00-R-17 |
| 18 | type Assertion.derivedFromAssertions | doc widened to INFERRED_FROM_MEASUREMENT premises; observedInContext confirmed | W00-R-30 |
| 19 | type Adjudication.considersAssessments | doc: domain any EvidenceAssessment; NarrativeArc never a target | W00-R-50 |
| 20 | type Activity | + usedMediaAssets, usedMediaVariants, usedMediaAnnotations (USED) | W00-R-18 |
| 21 | type Activity | + generatedSegmentations, generatedAnswerRecords, generatedMediaAssets, generatedMediaVariants, generatedMediaAnnotations, generatedPriceObservations, generatedOffers, generatedAffiliateLinks (WAS_GENERATED_BY inverse) | W00-R-18 |
| 22 | type SourceLocator.mentions, Mention.locatedAt | doc: kernel MENTIONS only; retrieval uses MENTIONS_ENTITY | W00-R-19 |
| 23 | type TradeItemIdentifier | doc: attached by HAS_IDENTIFIER; IDENTIFIED_BY relabelled at migration | W00-R-20 |
| 24 | type EquivalenceAssessment | + `survivingUid`, `retiredUid`; description of the redirect record | W00-R-11 |
| 25 | union AssertionSubjectTarget | - Association, FoodProduct, ExperienceReport, MediaSource (MR-02); - Organ, LabelSnapshot, FoodItem (MR-01); - SafetySignal, NarrativeArc (EvidenceAssessment archetype); + FirmwareVersion, IpRightStatus, MediaRightsRecord, RegulatoryPathwayVersion, RegulatoryInspection, UseConstraint | W00-R-21 |
| 26 | union SupportedRecordTarget | + SafetySignal, NarrativeArc, EventImpactAssessment, MediaSuitabilityAssessment, SourceAuthorityAssessment, StudyResult, RegistrationVersion, ProtocolVersion, MeasuredResult, LotTestSummary, CertificateOfAnalysis, PriceObservation, AffiliateLink | W00-R-22 |
| 27 | union descriptions | exclusion list rewritten (MR-01 specializations, retired types) | W00-R-21 |

Not changed (already in the fragment before this pass, confirmed by rulings): `Source.renditionCoverage` and enum
RenditionCoverage (W00-R-15, W19-SR-02), `Assertion.observedInContext` (W00-R-30, W03-SR-02), nullable `ActorIdentity.name`
(W01-SR-02), `Assertion.massBasis/amountReferent` on the generic type, `SourceLocator.regionAnnotation` (LOCATES_REGION).

Related packet edits outside the fragment: `fixtures/10-locator-kinds.cypher` normalizationVersion IMG-REL-XYWH-1 -> IMG-PX1
(W00-R-24); new `fixtures/13-reconciliation-rulings.cypher` and `fixtures/13-queries.cypher`.
