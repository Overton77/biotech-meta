# Open Schema Questions

These are research tasks, not placeholders to be silently guessed during ingestion. Updated 2026-10-03 for catalog 0.2.0. Items closed by a round say what closed them and stay listed for one release so the decision is traceable. Lane question ids (OQ-L2-xx, OQ-L3-xx, OQ-4.x, L5-OQ-xx, Lane 1 B.x) refer to the `open-questions.md` fragments reproduced in the round files.

## Priority 0: identity and assertion kernel

1. **What exact change creates a new Product Variant rather than a new Formulation Version or Package Configuration?** OPEN. Round 0001 holds Candidate B (contextual) provisionally. Round 0002's fixture supplies one of the required cases (a trial that names a brand without a recoverable historical label). Still needed: the six other fixtures listed in round 0001.
2. **Should every accepted semantic relationship exist only as an Assertion, or may selected asserted edges be canonical relationship records?** CLOSED for 0.2.0 (rounds 0007, 0009). An asserted edge is a regenerable projection of exactly one Assertion and carries `relationshipUid`, `assertionUid`, `recordedFrom`, `recordedTo` and the assertion's valid bounds (`asserted_edge` profile); authority stays with the Assertion. Which predicates become typed Neo4j relationships (item 3) is decided per module in `catalog/schema.yaml`; predicates listed only under `assertedPredicates` stay `Assertion.predicate` values.
3. **Which predicates are stable enough to become typed Neo4j relationships?** PARTLY CLOSED. Typed in 0.2.0: formulation, label, study, applicability, diagnostics, regulatory, commerce, protocol and provenance relationships named in the catalog. Still predicate-only: organization roles (except the commerce and financial-interest families), mechanism predicates, and the regulatory characterization predicates. Evidence that would close it: retrieval telemetry showing which predicate-only assertions are traversed often enough to justify a projection.
4. **How are retracted, corrected, and superseded source snapshots represented without changing historical adjudications?** CLOSED (rounds 0006, 0007). Snapshots and adjudications are immutable. A publisher revision is a `SourceRevisionEvent` (ERRATUM, RETRACTION, EXPRESSION_OF_CONCERN, CORRECTED_AND_REPUBLISHED, NEW_VERSION, SILENT_CONTENT_CHANGE, WITHDRAWAL, REINSTATEMENT) linked to the source, the prior and resulting snapshots and the notice. A content correction is a new Assertion that `SUPERSEDES` the old one with `SOURCE_CORRECTION`; the old assertion keeps its valid time and gets `recordedTo`. A retraction adds a superseding SUPPORT Adjudication; the assertions still record what the paper said. Tested on PMID 9500320 and its retraction notice PMID 20137807, and on the Lifespan #4 publisher correction.
5. **What minimum fields make an evidence locator reproducible across mutable webpages?** CLOSED (round 0006). A locator hangs from exactly one `SourceSnapshot` with `contentHash`, `contentHashBasis`, `retrievedAt` and a `storageUri` or `archiveUri`; it carries `selectorKind`, `normalizationVersion`, and for text-bearing kinds `exact` plus `quoteHash` (prefix and suffix when available); TEXT_POSITION adds offsets bound to a `DocumentTextVersion`; MEDIA_TIME adds start and end seconds on the captured rendition plus the spoken quote; PDF_PAGE adds `page`; IMAGE_REGION points at a `MediaAnnotation`. Re-found spans on later snapshots are new locators linked by `REANCHORS`. Still needed: a live re-capture of one commercial page over time to pick the selector kind that survives layout change (OQ-4.10, Lane 1 B.3).

## Priority 0: new in 0.2.0

6. **Single asserter per Assertion.** Round 0006 narrows the 0.1.0 wording "an Assertion can be supported by multiple sources": one Assertion has at most one asserter; corroboration is several Assertions `INSTANCE_OF` one `Claim`. Evidence that would close the residual doubt: a count of current Elysium-style assertions whose locators span more than one Source (OQ-4.2).
7. **Per-adjudication status transitions.** 0.2.0 requires a CAPTURE_FIDELITY Adjudication behind every ACCEPTED, REJECTED or DISPUTED status. Open: write amplification on the live pipeline. Evidence: a pilot count of transitions per 10k assertions (L5-OQ-02).
8. **uid redirect contract for merged identities.** Private records hold shared uids with a recorded-time viewpoint and must keep resolving after a merge (L5-OQ-07). Owner: identity_resolution.
9. **Year-precision bounds in queries.** "Was he on the board at date D in 2017?" must answer "possibly" when the source says "2011 to 2017". The storage rule (first instant of the precision period, per-bound precision) is accepted; the query variant and a fixture with a real month- or year-precision source are not written (OQ-4.1, Lane 1 B.6).
10. **Continuity behind an open-ended state.** A state observed at two instants is assumed to have held between them; a discontinued-then-relaunched product would be misread. Evidence: one real interrupted state; if found, require two bracketing observations (Lane 1 B.7, L5-OQ-14).

## Priority 1: ingredient identity and equivalence

1. When are two Ingredient Materials identical, analytically equivalent, formulation equivalent, or merely substance-related? OPEN. Round 0002 supplies the ordered `materialIdentityLevel` scale used by applicability; the equivalence rule itself is not decided. Evidence: the ChromaDex versus Elysium supplier record for the 2016 Basis trial (OQ-L2-01) and a certificate-of-analysis pair for one branded material under two specifications.
2. Does a supplier or specification change always create a new Branded Ingredient Material, a new Specification Version, or only a new material lot? OPEN.
3. **How should salt mass, active-moiety mass, nutrient-equivalent amount, and label-declared amount coexist?** CLOSED for US Supplement Facts labels (round 0005; 21 CFR 101.36(b)(2)(ii) and (b)(3)(ii)). `amountReferent` on `QuantityDeclaration` and `IngredientComponent`; `massBasis` on `InterventionComponent` and `IngredientComponent`; active-moiety and nutrient-equivalent amounts are CALCULATED assertions with `derivationRule` and `DERIVED_FROM_ASSERTION` inputs, never declarations. Open elsewhere: non-US label rules; the molecular-weight source policy (PubChem was unreachable in the authoring session, OQ-L3-11); whether the NR doses in PMID 29184669 and PMID 31278280 are salt or cation mass (OQ-L2-02).
4. How are botanical extract ratios, native ratios, solvents, carriers, standardization ranges, and marker measurements normalized? OPEN.
5. How should nonviable microorganisms, spores, consortia, and strain-specific counts be represented? OPEN.
6. How should proprietary blends with undisclosed nested quantities be reasoned over without inventing amounts? OPEN. `amountReferent: PROPRIETARY_BLEND_TOTAL` records the declared total; nested amounts stay unknown.

## Priority 1: evidence applicability

1. **Which applicability dimensions are categorical, continuous, or explanation-only?** CLOSED (round 0002). Categorical: MATERIAL_IDENTITY (ordered level), ACTIVE_COMPOSITION, DOSAGE_FORM, ROUTE, POPULATION, COMPARATOR, OUTCOME_RELEVANCE, STUDY_DESIGN_AND_QUALITY. Continuous with a basis-matched ratio: DOSE, SCHEDULE, DURATION, EXPOSURE. Explanation-only, never scored: BACKGROUND_CONTEXT, RECENCY_AND_CORRECTIONS. UNKNOWN and NOT_ASSESSED stay distinct.
2. How is applicability method versioned and calibrated against expert review? OPEN, DEFERRED in round 0002. Ratio bands and composite scoring need an expert-review set over at least the Basis, NIAGEN and Mitopure cases (OQ-L2-04).
3. How do investigational batches bridge to commercial lots when only partial analytical evidence exists? OPEN. `USES_INTERVENTION_MATERIAL` may target a `ProductLot`; the bridging assessment is not designed.
4. How should null primary results and favorable secondary or subgroup results affect claim-level synthesis? PARTLY CLOSED (round 0002): `analysisKind`, `comparisonKind`, `statisticalConclusion`, `INCLUDES_RESULT.inputRole` and INV-206 fix the representation; weighting inside a synthesis method stays method-versioned, not schema.
5. **What is the ontology for biomarker, surrogate endpoint, intermediate clinical endpoint, and patient-important outcome?** CLOSED (rounds 0002, 0004). Measurement side: Biomarker, Metric, AssayVersion, AlgorithmVersion. Inference side: `OutcomeDefinition.measureKind`, per-source priority assertions, `EndpointClassification` with BEST category, surrogate validation level and context of use; "patient-important" is derived from the classification.
6. Should `SafetySignal` become an `EvidenceAssessment` over `AdverseEventResult`s? NEW (OQ-L2-10). Owner: safety_and_constraints when it opens.
7. When does a source-asserted ordered mechanism chain need a `MechanismChain` node? NEW, DEFERRED (round 0003 alternative E; OQ-L2-08).

## Priority 1: diagnostics (new in 0.2.0)

1. How much assay detail (instrument, software version, kit, interval derivation) do consumer and clinical labs publish? If mostly NOT_REPORTED, CQ-DX-03 answers default to "not comparable". Evidence: 20 lab reports and 5 consumer-test vendor reports coded against the AssayVersion fields (OQ-L3-01).
2. Is a vendor's implementation of a published clock a distinct AlgorithmVersion even when the vendor names the publication? Evidence: vendor technical documentation and a reproducibility comparison on shared samples (OQ-L3-02).
3. Which reliability source licenses a within-version score difference as a change? Evidence: test-retest studies per AssayVersion or AlgorithmVersion (OQ-L3-03; PMID 36277076 covers research arrays, not vendor pipelines).
4. Should `RegulatoryPathway` become versioned rather than carry effective bounds? The LDT rule changed twice in 17 months (OQ-L3-07).
5. Should inspections (Form 483, NAI/VAI/OAI, warning letters) be modeled now? CQ-MF-06 cannot reach "evidence of CGMP compliance" without them (OQ-L3-06).

## Priority 2: quality and commerce

1. What evidence is sufficient to classify an artifact as a Certificate of Analysis rather than a Test Summary? OPEN.
2. How are specification targets, release limits, shelf-life limits, and measured uncertainty modeled? OPEN.
3. What creates product identity continuity across a retailer substitute, changed packaging, or marketplace listing merge? NARROWED (round 0005): a listing is never identity; a merged marketplace page is one `MerchantListing` with several `Offer`s; the variant rule stays with round 0001.
4. How are price, availability, shipping, tax, affiliate compensation, and subscription cancellation terms snapshotted? PARTLY CLOSED (round 0005): `priceKind`, offer-scoped seller and fulfiller roles, `AffiliateLink`; shipping, tax and cancellation stay text until a question needs a filter.
5. How should recalled, expired, counterfeit-suspected, and gray-market inventory be represented? OPEN.

## Priority 2: claims, provenance and ecosystem (new in 0.2.0)

1. `PolicyVersion` permission vocabulary for provenance state 5 (use kinds, scope, expiry); W3C ODRL not yet reviewed (OQ-4.3).
2. Does an editorial guest statement count as an endorsement under 16 CFR 255.0 when the guest has a material connection? Legal question, outside the graph (OQ-4.4).
3. Relevance through substance classes ("NAD boosters" to NMN) needs a class-membership assertion from the substances module (OQ-4.5).
4. Conflicting role kinds across sources (self-disclosure versus third-party profile) need an adjudication method for role conflicts (OQ-4.6).
5. Turn-spanning assertions (host proposes, guest assents) need an extraction guideline and an inter-annotator sample (OQ-4.9).
6. Should the live `ClaimOccurrence` GraphQL type declare `@node(labels: ["ClaimOccurrence", "Assertion"])`? Needs a library round-trip test (OQ-4.8).
7. Independence counting across retellings and shared datasets (CQ-AX-05) needs a manual sample of 20 claims (Lane 1 B.11).

## Priority 2: private context and protocols (new in 0.2.0)

1. Which regulatory regimes apply to BellLabs private data and what retention periods apply per category? Legal review (L5-OQ-08).
2. Which PostgreSQL release will host the private context store, and does it support `WITHOUT OVERLAPS` temporal keys? Otherwise exclusivity is service-enforced (L5-OQ-09).
3. k-anonymity or minimum-cell threshold for aggregates contributed from the private store to the shared graph (L5-OQ-15).
4. How is `stepKey` assigned across editions of a protocol page that changes in place? Needs an extraction pilot on dated captures (L5-OQ-10, L5-OQ-16).
5. Cutover date for requiring `assertionUid` on live `RECOMMENDS` edges (L5-OQ-12).
6. Operator tier policy: counts and uids of private records only, or break-glass access? Product and policy decision (Lane 1 B.13).
7. Scope and retention of ad hoc answer logs (round 0009 AnswerRecord covers published answers only) (Lane 1 B.10).

## Live-stack facts to verify before implementation

These could be read only from documentation in the authoring session, never from the deployed system.

1. Which `@neo4j/graphql` version is deployed, and whether it accepts `extend type` on `@node` and `@relationshipProperties` types and additional labels via `@node(labels:)`.
2. Whether stored nodes carry a Neo4j label `Entity` or other base-archetype labels. If not, V-000a and V-000b are vacuous for live nodes. Evidence: `CALL db.labels()`.
3. Whether the manual fulltext indexes use stored property names for aliased fields (`Document.title`, `url`) and whether a unique constraint exists on `id` per live label. Evidence: `SHOW INDEXES`, `SHOW CONSTRAINTS`; V-120 is written to answer the index question.
4. Which Neo4j edition is deployed; property existence and type constraints (C-1xx to C-5xx marked Enterprise) and RBAC defence in depth depend on it.
5. The stored property set of the live `LISTS_PRODUCT` relationship, which declares `TemporalMetadata` on the Listing side and `RoleMetadata` on the Product side (OQ-L3-09).
6. Whether Cypher accepts a parameter as a path-quantifier bound; the query shapes compile a literal (Lane 1 B.9).
7. The fixtures and V-0xx to V-5xx were executed on an embedded Neo4j 5.26 Community instance (2026-10-03, zero failing rows). Still to run: the Enterprise-only constraints, and the whole suite against a copy of the deployed database, where the V-000a/b vacuity question and the live label set are decided.

## Status after the final schema proposal run 2026-10-04 (Fable 5.1)

Live-stack facts above, as verified on the pinned research stack (not the deployment): (1) `@neo4j/graphql` 7.6.3 accepts additional labels via `@node(labels:)`; the proposal uses no `extend type`; `@unique` does not exist, uniqueness is created by the operations file. (2) The proposal makes archetype labels mandatory and the operations file back-fills them (section 6b), so V-000a/b are no longer vacuous once it has run. (3) Fulltext indexes are created with stored property names (section 4). (4) Edition: Community rejects existence/type constraints; they ship as an unverified Enterprise companion. (6) Query shapes compile literal quantifier bounds (unchanged). (7) The 0.2.0 fixtures were replayed (45 ok / 12 informational), then the translated set and 24 packets' fixtures ran on Neo4j 5.26.31 Community embedded with APOC Core; see the run's `reports/07-validation-report.md`. Still unverified: the deployed version and edition, (5) the live `LISTS_PRODUCT` property set.

Closed by the run (with the ruling): CL-001..CL-018 of the run's conflict ledger (`reports/02-ownership-and-seams.md`); single asserter per Assertion stays (V-410 extended to every Assertion by V-F5); `privacyClass` null is not public (F-W5-11); `RECOMMENDS` derived only (CL-016).

New or sharpened questions:

1. **Public-tier surface.** The operator SDL exposes every type; the PUBLIC_ANSWER tier needs a derived sub-schema (W23) that must build against the final file (`AssertionSubjectTarget` lists `Activity`, which the public subset excludes). Owner: W23 / access. Evidence: Challenger CH-P-01/02.
2. **Resolver URIs as canonicalUri.** Seven inherited fixture sources use `https://doi.org/...` as `canonicalUri`; CL-003 requires the post-redirect page. Needs network resolution at ingestion. Owner: W19/W00.
3. **Cross-store copy detection.** An Observation copied from a private PersonalMeasurement is only detectable with the private store online (CH-P-08, CH-R-06); the shared-graph guard is the writer credential. Owner: W23.
4. **Enterprise verification.** The companion file (1,378 statements) is unverified; a deployment edition decision is needed (handoff user item).
5. **Vector dimensions and embedding source** for the three provider-less `@vector` indexes (D-014; user item).
6. **EU/UK `AUTHORIZATION` status kind**, crawler-terms capture policy, k-anonymity threshold, PostgreSQL 18 `WITHOUT OVERLAPS` for the private store: unchanged user items from the handoff.
7. **Verdict-versus-inputs checks** for EvidenceSynthesis (CH-S-07) and cadence anchors stated only in prose (CH-R-04) have no structural validator; both are review-queue queries.

## Agent evaluation questions

1. Which graph shapes consistently produce incorrect retrieval or evidence inheritance?
2. Which concepts are repeatedly confused by extraction agents? Round 0003 predicts measured versus hypothesized mechanism steps; round 0006 predicts practice reports versus recommendations.
3. Which validation failures predict harmful recommendation errors?
4. Which modeled distinctions are never used and create unnecessary resolution cost? Candidates to watch: `Mention`, `AnswerRecord`, `UseContextProfile`.
5. Which new domain cases cannot be expressed without lossy blobs or overloaded labels? The eight query shapes in `ontology-lab/query-shapes.md` are expressible without blobs; the first case that is not should open a round.
