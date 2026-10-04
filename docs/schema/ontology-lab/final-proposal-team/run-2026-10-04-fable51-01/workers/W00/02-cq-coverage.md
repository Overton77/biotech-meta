# W00 CQ coverage matrix

Priority and answerability are copied from `competency-questions.md` (A = answerable with the model and a shape; Q = answerable with qualifications). "Shape" names the query in `query-shapes.md` or the executed W00 query in `fixtures/` (06 §3). Every SDL element of `sdl-fragment.graphql` is mapped in §2.

## 1. Matrix

| CQ (priority, ans.) | Example answer (from W00 fixtures) | Distinction | Evidence requirement | W00 model element | Shape | Failure prevented |
|---|---|---|---|---|---|---|
| CQ-EV-01 (Essential, A) | "Sinclair Lab page states 'InsideTracker (Segterra) … B (2011-2017)'; TEXT_QUOTE, quoteHash sha256:1994dc81…, snapshot 2026-10-03 PARTIAL_EXCERPT" (Q03-b) | sentence vs proposition; span vs paraphrase | snapshot with contentHash + basis + retrievedAt; typed locator | Assertion, SUPPORTED_BY, SourceLocator (typed selectors, quoteHash, normalizationVersion), SourceSnapshot, Source | QS-1a; Q03-b; T1 | paraphrase without span; irreproducible locator |
| CQ-EV-02 (Essential, A) | "RETRACTS_SOURCE is a source assertion by The Lancet; INSUFFICIENT is a BellLabs SUPPORT adjudication (2026-10-04); SELLS_PRODUCT e1 is derived by rule sells-product/v1 from w00-sor" (T2, Q09-c, F07) | Assertion vs Adjudication vs derived edge | record kind; derivation rule and inputs | archetype interfaces; Adjudication; DerivedEdgeProperties; `__typename` on SupportedRecordTarget | QS-1a, QS-4a (V-112) | derived shortcut presented as a source's statement |
| CQ-EV-05 (Foundational, Q) | "PMID 9500320 retracted (notice 2010-02-06, learned 2026-10-04); the record of what it reported stays ACCEPTED; SUPPORT 2009 PARTIALLY_SUPPORTED superseded by 2026 INSUFFICIENT" (Q09-b) | correction vs retraction vs fact end | notice snapshot + locator | SourceRevisionEvent (REVISES_SOURCE, PRIOR/RESULTING_SNAPSHOT, ANNOUNCED_IN), SUPERSEDES {SOURCE_REVISION, SOURCE_CORRECTION}, Adjudication | QS-2a/2c; Q01-f; Q09-b | deleting or editing assertions of retracted sources |
| CQ-TM-01 (Essential, A) | "At R=2026-05-01 variant A had FV1 200 mg; at R=2026-07-01 FV1c 120 mg for the same V" (Q01-a/b); "board member at 2011-06-15: POSSIBLE" (Q03-a) | valid vs recorded; known vs possible | service-assigned recorded times; per-bound precision | Assertion.recordedAt/recordedTo, valid bounds + precision + basis; StateEpisodeProperties; AssertedEdgeProperties | QS-2a/2b; QS-W00-P (candidate, Q03-a) | current belief presented as historical; YEAR bound read as exact |
| CQ-TM-02 (Essential, A) | "2019 formulation invisible at R=2026-04-10, visible now; validFrom 2019 YEAR; recordedAt 2026" (Q02-a/b) | late arrival vs world change | archive observedAt vs retrievedAt | SourceSnapshot.observedAt/retrievedAt; recordedAt via datetime.transaction() | QS-2c; Q02-a…c | backdating recordedFrom |
| CQ-TM-03 (Foundational, A) | "notice published 2010-02-06; record observed/retrieved 2026-10-04; revision recorded 2026-10-04T01:05" (Q09-b, Q02-b) | publication/observation/retrieval/valid/effective/recorded | per-clock fields | SourceSnapshot.publishedAt/observedAt/retrievedAt; SourceRevisionEvent.occurredAt/recordedAt; VersionedStateArchetype.effectiveFrom/To | Q02-b | one date for several clocks |
| CQ-TM-04 (Foundational, A) | "advisor role: validTo unknown, OPEN_END_SUPPORTED by the 2026-10-03 observation" (Q03-a) | unknown vs open vs stale | null bounds, basis, last observation | ValidTimeBasis (UNKNOWN, OBSERVATION_ONLY), TimePrecision | QS-2a classes; QS-W00-P; V-105/V-503 | null replaced by now or sentinel |
| CQ-TM-05 (Foundational, Q) | "a second US formulation overlapping 2026-06-01..2027-01-01 refused (EXCLUSIVE_DEFINITE_OVERLAP)" (F11 G4) | exclusive vs non-exclusive; definite vs possible | partition keys, bounds, precision | predicateExclusivity; write guard; StateEpisodeProperties | V-508/V-509; F11 audit | two current exclusive states |
| CQ-TM-06 (Foundational, A) | "ERRATUM of label A: a1 relied on the prior snapshot; superseded by a2 (SOURCE_CORRECTION)" (Q01-f); retraction case (Q09-b) | assertion content vs adjudication | revision events, snapshots | SourceRevisionEvent; PRIOR_SNAPSHOT; SUPERSEDES.sourceRevisionEventUid | Q-505 (Q01-f, Q09-b) | silent impact of a revision |
| CQ-TM-07 (Essential, A) | "Product A: CORRECTED_RECORD_NEVER_HELD; Product B: FACT_ENDED_STATE_KEPT_FOR_BOUNDED_INTERVAL" (Q01-d) | SOURCE_CORRECTION vs VALIDITY_BOUNDED | stated error vs effective date | SupersessionKind; episodes' current attachment | Q01-d | correction treated as fact end and the reverse |
| CQ-PV-01 (Essential, Q) | five states of the 1998 report (Q09-a) | the five provenance states | assertion, locator, assessment, activity, policy records | ASSERTED_BY, SUPPORTED_BY, Adjudication(SUPPORT), Activity USED/WAS_ASSOCIATED_WITH, AUTHORIZED_BY {useKind} | Q09-a; T2b | said-it shown as evidence; use without permission (V-W00-10) |
| CQ-PV-02 (Foundational, A) | "quote re-found in the 2026-02-01 capture, EXACT" (F10) | snapshot vs source; content clock | typed locator; REANCHORS | REANCHORS {anchorMatch}, ReanchorProperties; V-409 (content clock) | V-401, V-409 | unrecoverable citations |
| CQ-PV-03 (Foundational, A) | "extracted by w00-manual-curation-v1 activity, agent MANUAL_AGENT" (T1 generatedBy) | agent vs activity; last writer vs generator | activity records | Activity (methodVersion, externalRunSystem/Id), Agent; WAS_GENERATED_BY | V-430; T1 | lost creating run |
| CQ-PV-04 (Essential, Q) | "'a gram' has massBasis UNSPECIFIED; quantityBasis 'UNSPECIFIED' in legacy data is unreadable (T4a)" | per-day basis vs mass basis vs referent | basis fields | Assertion.quantityBasis, massBasis, amountReferent (W00-SR-01) | F04/F05/F12 | 1000-fold basis errors hidden |
| CQ-PV-06 (Foundational, X) | "SUMMARIZE_IN_ANSWER allowed by policy v0 for activity answer-composition-1" (T2b) | use vs permission | policy version | AUTHORIZED_BY + AuthorizationProperties.useKind (PolicyVersion W23) | V-429/V-W00-10 | quoting without permission record |
| CQ-ID-04 (Foundational, Q) | "'NR-100' issued by Supplier A and by Supplier B: two identifiers, two materials, NOT_EQUIVALENT" (Q08) | identifier vs name; issuer scope; assignment validity | authority snapshot behind HAS_IDENTIFIER assertion | Identifier (scheme, issuer, value), HAS_IDENTIFIER + IdentifierLinkProperties, EquivalenceAssessment | QS-8 + QS-1a; Q08-a/b | merge on shared value across issuers |
| CQ-AX-07 (Essential, A) | "w00-rests-on-legacy-locators is ACCEPTED on non-reproducible locators" (F10) | no locator / no snapshot / no adjudication | graph itself | V-110, V-111, V-401 | QS-1a gaps | accepted state resting on nothing |
| CQ-AX-08 (Foundational, A) | "SELLS_PRODUCT e2 derived from a HOSTS_LISTING assertion" (F07) | projection vs derivation; forbidden premise | edge citations | DerivedEdgeProperties; V-112, V-W00-02, V-W00-11 | QS-4a | shortcut as only record or forbidden implication |
| CQ-AX-09 (Foundational, Q) | "assertion a1 generated by EXTRACTION activity (method w00-manual-curation-v1), status backed by POLICY adjudication 2026-03-02T10:20" (T1) | lineage vs provenance | activity, reviewerType | Activity, Agent, Adjudication.reviewerType, mongoResearchRunId as operational pointer | QS-1a | run id read as provenance |
| CQ-AX-14 (Essential, A) | Q08-c: two UNRESOLVED hypotheses for "NR-100", lexical score only | lexical hit vs resolved identity | hypotheses | Mention, MENTIONS, ResolutionHypothesis (PROPOSES_MATCH, RESOLVES_MENTION, COMPETES_WITH), fulltext `mention_surface_form` | QS-8 | search hit treated as identity |
| CQ-AX-15 (Foundational, A) | "w00-guard-g1 is EXTRACTED; T5a API-created assertion EXTRACTED" | candidate vs committed | status, activity | AssertionStatus; ResolutionHypothesis.status vs resolutionStatus | QS-1a with allowed statuses | unreviewed extraction in public answers |
| CQ-AX-16 (Foundational, A) | "write refused: ASSERTER_COUNT / LITERAL_XOR_OBJECT / BACKDATED_RECORDED_AT / IMMUTABLE_CONTENT_CONFLICT" (F11) | pre-commit guard | proposed bundle | write-guard audit (07 §4); QS-4b | F11 | bad writes committed |
| **CQ-AX-C01 (candidate)** | "3 shared records cannot be read by the published API: missing id/updatedAt, AssessmentStatus 'FINAL', lowercase privacyClass" (F12, T4) | storage spelling vs API contract | stored properties | V-W00-08, V-W00-09 | — | the API failing on Cypher-ingested records (rationale: direct Cypher ingestion is the main write path; T4 shows four failure modes) |

## 2. SDL element → CQ / invariant / ingestion failure

| Element | Mapped to |
|---|---|
| `Entity`, `uid`, `id` | INV-106, CQ-AX-09, CQ-ID-04; V-117 |
| `SearchIndexable` | INV-107, CQ-AX-14 |
| `TemporalSnapshot` | CQ-TM-01 (live caches; seam W00-SR-08) |
| `ActorIdentity` | CQ-EV-02, CQ-PV-01 (asserter identity) |
| six `*Archetype` interfaces | INV-001, D-001, CQ-EV-02 |
| `AssertedEdgeProperties` | INV-101, INV-503, CQ-TM-01; V-W00-11 |
| `StateEpisodeProperties` | TM-R1…R5, CQ-TM-01/05/07; F01 |
| `DerivedEdgeProperties` | INV-004, CQ-AX-08; F07 |
| `StructuralEdgeProperties` | relationshipClasses.structural (ordering of captured records; no W00 field uses it yet — kept for domain owners per contract B4) |
| `SupersessionProperties` | CQ-TM-07, CQ-EV-05; F01, F09 |
| `AuthorizationProperties` | CQ-PV-06, V-429; F09 |
| `ReanchorProperties` | CQ-PV-02, V-409; F10 |
| `IdentifierLinkProperties` | CQ-ID-04; F08 |
| enums PrivacyClass, NodeMaturity | INV-506, contract A9; V-W00-09 |
| AssertionStatus, AssessmentStatus, AdjudicationKind, AdjudicationVerdict, ReviewerType | INV-103, INV-406, CQ-EV-02, CQ-TM-01 |
| BasisKind, PredicateClass (candidate) | INV-210, KCR-3a; V-W00-07 |
| AssertionBasis, SpeechAct, Polarity | CQ-EV-01, QS-7, forbidden [REPORTS_PRACTICE, RECOMMENDS] |
| TimePrecision, ValidTimeBasis, SupersessionKind, SourceRevisionKind | CQ-TM-01…07 |
| SelectorKind, ContentHashBasis, CaptureCompleteness, AnchorMatch | CQ-PV-02, CQ-EV-01, V-401 |
| SourceKind | CQ-PV-05 (W19), CL-003 |
| ActivityKind, AgentKind, UseKind | CQ-PV-03, CQ-PV-06 |
| EquivalenceKind | CQ-ID-04, CQ-EC-02 |
| QualificationKind, RetellingMode, RetellingLinkBasis, RelevanceLevel, RelevanceBasis, DisclosureFinding, TemporalOverlap | kernel enums used by W21 assessments (CQ-CL-04/05, CQ-PV-05); W00 defines, W21 uses |
| QuantityBasis, MassBasis, AmountReferent, ReportedStatus | contract A7, A11, INV-007, CQ-PV-04 |
| RenditionCoverage (candidate) | W19 candidate CQ-PV-C02; failing case W19 fixture 03 Q-08a |
| Source | CQ-EV-01, CQ-PV-02, CL-003 |
| SourceSnapshot | CQ-EV-01, CQ-TM-02/03, CQ-AX-07 |
| SourceLocator | CQ-EV-01, CQ-PV-02, CL-011 |
| SourceRevisionEvent | CQ-EV-05, CQ-TM-06 |
| Assertion | CQ-EV-01/02/05, CQ-TM-01/02/07, CQ-PV-01/04 |
| Adjudication | CQ-EV-02, CQ-TM-01, INV-103 |
| ResolutionHypothesis | CQ-AX-14/15, CQ-ID-04 |
| EquivalenceAssessment | CQ-ID-04 |
| Agent, Activity | CQ-PV-01/03/06, CQ-AX-09 |
| Identifier, TradeItemIdentifier | CQ-ID-04 |
| Mention | CQ-AX-14 |
| AssertionSubjectTarget, AsserterTarget, SupportedRecordTarget | INV-003, KCR-4.3, CQ-EV-01/02 |
| `@settable`/`@mutation`/`@timestamp` directives | INV-501, INV-502, INV-504; T5 |
| `SourceLocator.selector` (deprecated, read-only) | catalog migration 0.1.0 → 0.2.0 (ingestion failure: untyped selectors) |
