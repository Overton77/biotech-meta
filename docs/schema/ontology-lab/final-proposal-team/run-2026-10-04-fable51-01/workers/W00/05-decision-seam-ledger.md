# W00 decision and seam ledger

Worker W00 (Opus 5.5), run `run-2026-10-04-fable51-01`. Status words: **ruled-by-W00** (the registry names W00 as resolver; Fable may overturn), **proposed** (W00 recommends; Fable decides), **forwarded** (needs a contract or frozen-enum change; Fable decides), **open**. The frozen contract stands everywhere below; every departure is a request in `seam-requests.yaml` with a primary source and a failing case. No consensus with other workers is claimed beyond what their packets state.

Evidence keys: S-xx = `03-source-manifest.md`; F-xx = `fixtures/NN-*.cypher`; T-x / P-x = executed GraphQL tests and probes in `06-fixtures-and-queries.md` §4.

## 1. Conflict-ledger records W00 rules or confirms

### CL-003 Source vs Document vs Publication vs Episode — ruled-by-W00 (adopts W19's R1–R5 with two clarifications)

W19's proposal (`workers/W19/01-domain-recommendation.md` §2, R1–R5, real minimal pairs PMID 29184669/30155270 and Huberman Lab #52) was present when W00 finished and is adopted:

| Rule | Ruling |
|---|---|
| R1 work vs endpoint | `Publication` (W09) is the scholarly work, `Episode` (W21) the audio/video work; `Source` (W00) is one retrieval endpoint with one normalized `canonicalUri` and its own snapshots; `Document` is a Source specialization with labels `["Document","Source","Entity"]` that adds document metadata and **never adds identity**. Identifiers (DOI, PMID, PMCID, NCT, video ids) are `Identifier` nodes of the work or record (HAS_IDENTIFIER), never Sources. |
| R2 canonicalUri | The post-redirect content endpoint, never an identifier resolver. `https://doi.org/<doi>` is the display form of the work's DOI (Crossref display guideline, S-06), so it lives on the `Identifier`, not on a Source. Migration: `examples/diagnostic-comparison.cypher` Sources with doi.org URIs become Identifiers plus captured landing/PDF Sources; V-235's string join is replaced by `RENDITION_OF` (W19-SR-10 accepted). |
| R3 RENDITION_OF | A Source is RENDITION_OF at most one work iff it carries some of the work's own content; records only *about* a work reach it through Assertions. How much it carries is `Source.renditionCoverage` (FULL/PARTIAL/UNKNOWN), added to the W00 fragment as a CANDIDATE field (W19-SR-02, failing case W19 fixture 03 Q-08a: a COMPLETE capture of a PARTIAL PubMed rendition must read NOT_FOUND_IN_PARTIAL_CAPTURE). |
| R4 presentation | A slide deck is its own Document/container, never a rendition of the talk (W21 owns the link predicate, W19-SR-07). |
| R5 errata | A notice is its own Publication with its own Sources; each rendition whose bytes changed gets its own SourceRevisionEvent (`REVISES_SOURCE` exactly one Source). F09 realizes the PubMed retraction case (PMID 9500320 / 20137807, NEW_RETRIEVAL S-04). |
| Clarification A | Source and Document are read by one another's types: a Document node must dual-write `id` (= `documentId`), `entityType` and `canonicalUri` (W00-SR-03, failing test T4d). |
| Clarification B | A union lists Source and never Document (parent-only rule, D-W00-05). |

Responses still owed: W20 (dual-write, DocumentType vs SourceKind), W21 (OCCURS_IN Publication), W09 (Publication identifiers). W19 may append minimal pairs; the rule text above is final for W00.

### CL-009 assertionUid vs projectionOfAssertionUid — confirmed (D-011)

Asserted edges and bitemporal attachment episodes carry `assertionUid` only; derived edges carry `projectionOfAssertionUid` (or a rule with inputs) only; never both. Property card T-14 ("assertionUid / projectionOfAssertionUid (episodes)") is superseded: episodes use `assertionUid`. QS-2b's `coalesce(r.assertionUid, r.projectionOfAssertionUid)` is kept as a read-side tolerance for legacy edges only. Enforcement: **V-W00-02** (new; zero rows on every positive fixture) and **V-W00-11** (generalized asserted-edge fidelity: predicate equals edge type, subject/object equal endpoints, valid time and recordedTo equal the assertion's; F07 shows the failure).

### CL-011 IMAGE_REGION locator vs MediaAnnotation — ruled-by-W00 (D-010 realized)

- An `IMAGE_REGION` SourceLocator keeps `mediaAnnotationUid` **and** has exactly one structural `LOCATES_REGION` edge to the `MediaAnnotation` (W22's type and relationship name) whose uid equals `mediaAnnotationUid`; no other selector kind carries `LOCATES_REGION`. Check: **V-W00-03** (F10: one row for the region locator without the edge). V-401 is tightened to require the edge for IMAGE_REGION.
- The locator still hangs from exactly one SourceSnapshot (the captured image rendition); the annotation never replaces the locator or the snapshot, and a crop derived from a label photo keeps its provenance through the locator's snapshot (W22 owns the asset-to-snapshot path and the crop fixture).
- `normalizationVersion` for IMAGE_REGION names the region-coordinate convention; the registry needs a value (W00-SR-10, candidate `IMG-REL-XYWH-1`).
- W00 writes `SourceLocator.regionAnnotation`; W22 writes the inverse field on MediaAnnotation and registers a `media-annotation` uid token (W00-SR-09).

### CL-012 Source Intelligence vs provenance ownership — ruled-by-W00

W19's candidates are assessments, requirements or occurrences, never a second Source:
- `SourceAuthorityAssessment` = EvidenceAssessment (claim-scoped, method-versioned; no global reliability score; never sets `Assertion.status` or a verdict).
- `SourceCoverageRequirement` = INTERNAL InformationArtifact referencing a Source; computed freshness/coverage is never stored on subjects, assertions or Source.
- `SourceDiscoveryRecord` = an Activity specialization `["SourceDiscoveryRecord","Activity","Occurrence"]`; W00 accepts the label sharing under the parent-only rule (the W00 `Activity` type reads it; unions list `Activity` only). `ActivityKind.DISCOVERY` is a frozen-enum value request, **forwarded** to Fable with W00 support (W19-SR-03).
- None of them carries `canonicalUri` as identity, a snapshot, a locator or a truth/reliability score; none joins W00's unions until admitted. `SourceKind` additions (W19-SR-01) are **forwarded** with W00 support for `BIBLIOGRAPHIC_RECORD` and `TRIAL_REGISTRY_RECORD` (F09 needs the former and files a PubMed record as PEER_REVIEWED_PUBLICATION under the frozen enum).

## 2. Responses to W19 seam requests addressed to W00

| W19 request | W00 response | Where |
|---|---|---|
| SR-01 SourceKind +8 | forwarded (frozen enum); support BIBLIOGRAPHIC_RECORD, TRIAL_REGISTRY_RECORD, OTHER+note | W00-SR-16 |
| SR-02 renditionCoverage | accepted as CANDIDATE field + enum in W00 fragment | `sdl-fragment.graphql` Source |
| SR-03 DISCOVERY / label sharing | label sharing accepted; enum value forwarded | CL-012 |
| SR-04 AuthorityScope | W19-owned candidate; no kernel effect | — |
| SR-05 tokens | register when types admitted | W00-SR-09 |
| SR-09 content-clock ordering | accepted; V-409 and V-512 compare `coalesce(observedAt, retrievedAt)` | `fixtures/validation-w00.cypher` |
| SR-10 canonicalUri rule, V-235 | accepted | CL-003 R2 |
| SR-13 QS-7 covering condition | accepted (needs renditionCoverage) | `07-operations.md` §4 |
| SR-15 cached capture observedAt | accepted as ingestion rule | `07-operations.md` §6 |

## 3. W00 decisions

| Id | Decision | Evidence | Alternatives (why not) | Status |
|---|---|---|---|---|
| D-W00-01 | `ActorIdentity` gains `uid` and relaxes `name` to nullable (same reason as D-013); backward compatible for implementers | contract B3, D-013; live lines 22–27 | keep live text (Cypher-ingested AnonymousActor without name unreadable) | proposed |
| D-W00-02 | API-level immutability: `recordedAt` and `createdAt` are `@timestamp(CREATE)` + `@settable(none)`; content fields `@settable(onCreate: true, onUpdate: false)`; `recordedTo` settable only on update; `@mutation` omits DELETE for Assertion/assessments and allows only CREATE for SourceSnapshot, SourceLocator, SourceRevisionEvent, Mention | INV-501, INV-502, INV-504; S-01 (@timestamp is API-only); generated inputs inspected (T5) | rely on service only (the generated API would let any client edit valid time or backdate recordedAt) | proposed |
| D-W00-03 | `SourceLocator.selectorKind` nullable: null = migrated 0.1.0 untyped selector, not reproducible (V-401 rejects); deprecated `selector` kept read-only | catalog migration text ("selectorKind UNKNOWN until re-anchored") vs 7-value enum; F10 | WHOLE_SNAPSHOT (over-credits reproducibility); add UNKNOWN (frozen enum change) | proposed |
| D-W00-04 | `SourceSnapshot.retrievedAt` non-null (recorded-time lower bound, V-504); `observedAt` nullable per interface but required by ingestion | property cards T-19, T-20 | both nullable (late-fact rule unenforceable) | proposed |
| D-W00-05 | Parent-only union rule: a union never lists a type and its label-superset specialization | executed probe P-1 (duplicate rows) | list leaves only (parent-only nodes become unreachable) | proposed (W00-SR-11) |
| D-W00-06 | `AssertionSubjectTarget` = registry types of the four catalog archetypes, minus specializations, Chunk/Segmentation, W23 internal types, CohortParticipant, the DiagnosticResult interface and candidates | catalog HAS_SUBJECT range; contract A9 (INTERNAL types excluded from public projections) | include Assertion/assessment types (outside catalog range); `Entity` interface target (all ~200 implementers incl. assessments, same planning cost) | proposed; Fable prunes |
| D-W00-07 | Reuse `AssertionSubjectTarget` for HAS_IDENTIFIER (inverse), PROPOSES_MATCH, COMPARES_IDENTITIES; a separate `Assertion` field for PROPOSES_MATCH → Assertion; an interface target (`EvidenceAssessmentArchetype`) for CONSIDERS_ASSESSMENT | registry allows three unions only; build succeeded | new unions per range (registry change) | proposed |
| D-W00-08 | HAS_STATE uses `StateEpisodeProperties` (contract B4); `assertionUid` is required in the shared graph by V-101 although nullable in SDL | catalog temporal.HAS_STATE class asserted; profile bitemporal_attachment | AssertedEdgeProperties (contract names StateEpisodeProperties) | proposed |
| D-W00-09 | Precision-aware validity classes (QS-W00-P: KNOWN_NOT_VALID, POSSIBLE_START_UNCERTAIN, KNOWN_WITHIN, POSSIBLE_END_UNCERTAIN, OPEN_END_SUPPORTED/STALE) for CQ-TM-01/04 | F03: precision-blind QS-2a says KNOWN_WITHIN at 2011-06-15 and EXCLUDED at 2017-06-01 for a 2011–2017 YEAR role; QS-W00-P says POSSIBLE for both | keep QS-2a classes (overstates and understates) | proposed (query shape, not schema) |
| D-W00-10 | A stated inclusive end year Y ("2011-2017") is stored as `validTo` = Y-01-01 precision YEAR; V ≥ (Y+1)-01-01 is KNOWN_NOT_VALID | round 0007 §9 first-instant rule; round 0006 fixture used 2018-01-01 pending this rule | 2018-01-01 YEAR (means "ended in 2018") | proposed; migration row |
| D-W00-11 | Identifier key (scheme, issuer, value), unique by constraint; assignment validity lives on HAS_IDENTIFIER (IdentifierLinkProperties); scheme-level validity on the node gains per-bound precision/basis | F08 (duplicate refused; naive (scheme,value) join finds the forbidden pair) | (scheme, value) key (merges issuers); validity on the node only (cannot express reassignment) | proposed |
| D-W00-12 | Direct-Cypher ingestion contract: write `id` (opaque UUID/ULID) and `uid` = `hu:<token>:<id>`; `createdAt`/`updatedAt`/`recordedAt`/`recordedFrom` = `datetime.transaction()`; archetype discriminator fields; contract enum spellings | S-01 (@id/@timestamp only at API), S-08 (datetime.transaction), T4 failures | rely on GraphQL autogeneration (not database-wide) | proposed |
| D-W00-13 | Atomic write guard: lock subject, `MERGE … ON CREATE`, in-transaction audit, rollback on any row | F11 executed: G1 commit, G2–G6 rollback, nothing of them persisted | post-commit validation only (exclusive overlaps race) | proposed |
| D-W00-14 | V-409/V-512 order snapshots by the content clock `coalesce(observedAt, retrievedAt)` | W19-SR-09 fixture 04; round 0007 TM-R6 | retrievedAt (rejects honest late archive captures) | ruled-by-W00 |
| D-W00-15 | Generic Assertion carries `massBasis`, `amountReferent` (A11), `roleTitleVerbatim`, `roleCodeVerbatim`, `statedTense`, `segmentKind` beyond the interface | catalog Assertion.optional; property cards §C | interface change (contract change; requested W00-SR-01) | proposed |
| D-W00-16 | Stored `privacyClass` uses `PUBLIC`/`INTERNAL`; catalog lowercase values migrate; leak checks test any spelling of private-personal | T4a (enum serialization error on 'public') | `@alias`-style enum mapping (not supported by the library) | proposed |
| D-W00-17 | APOC Core 5.26.x is a runtime prerequisite; cold planning of a query that touches two 147-member union fields took 10.5 s (warm 0.16 s) on 5.26.31 with a 1.5 GB heap; an unbounded heap run was killed under host memory pressure | T1 executed; S-09 | smaller unions per relationship (registry change) | proposed (W00-SR-14) |
| D-W00-18 | Fields for other owners' relationship types on W00 types: `Assertion.observedInContext` (W03), `Assertion.instanceOf` (W21, DerivedEdgeProperties; hypothesis uid in `derivedFromAssessmentUids`), `SourceLocator.resolvesToChunks` (W20), `SourceLocator.regionAnnotation` (W22) | no `extend` allowed; owners cannot add fields to W00 types | omit (generic Assertion could not reach context/claim) | proposed (W00-SR-15) |
| D-W00-19 | ResolutionHypothesis keeps `resolutionStatus` as controlled String (outcome) beside `status` (record workflow) | repository fixtures use REJECTED/UNRESOLVED | map to AssessmentStatus (loses outcome) | proposed (enum requested W00-SR-04) |

## 4. Kernel-change requests (summary; full text in `seam-requests.yaml`)

| Id | Change | Failing case |
|---|---|---|
| W00-SR-01 | massBasis/amountReferent on AssertionArchetype | 'UNSPECIFIED' stored as quantityBasis (T4a) |
| W00-SR-02 | uid assignment cannot be API-side with `@id` | T5a + V-117 row |
| W00-SR-04 | ResolutionStatus enum | fixture status 'REJECTED' unreadable |
| W00-SR-05 | merge-redirect record has no EquivalenceKind | duplicate Organization cannot be redirected |
| W00-SR-09/10 | tokens `mention`, `media-annotation`; IMAGE_REGION normalization id | F08, F10 invent values |

Validator fixes (no contract change): W00-SR-06 (V-112 hypothesisUid), W00-SR-12 (V-432 COMPARES). Relationship-name seams: W00-SR-07 (IDENTIFIED_BY ⊂ HAS_IDENTIFIER), W00-SR-08 (live HAS_SNAPSHOT state caches → HAS_STATE). Two further same-name/different-class pairs are recorded, not requested: `MENTIONS` (SourceLocator → Mention, structural, W00) vs `MENTIONS` (Chunk/Episode → entity, derived, W20/W21), and `EVALUATES` (Adjudication → Assertion) vs legacy read-only `Study.evaluates` (W09). Validation distinguishes them by endpoint labels; Fable may rename the derived/legacy ones.

## 5. Open items and closure criteria

| Item | Owner | Closure |
|---|---|---|
| Merge-redirect contract | Fable | a ruling on W00-SR-05 and one executed merge fixture |
| API create path for kernel records | Fable / deployment | a ruling on W00-SR-02 (service-only creates or client-supplied id) |
| Enterprise constraint behaviour | Fable | an Enterprise 5.26 run of `operations-enterprise.cypher` (not available in this run) |
| Union planning cost at scale | Fable | plan-cache warm-up policy or narrower unions after pruning; re-time T1 on the merged schema |
| W22 asset-to-snapshot path for region crops | W22 | W22 SDL + crop fixture; then extend V-W00-03 to check the path |
| Contradicting time encodings in repository fixtures (2018-01-01 YEAR) | W01/W21 | migration-map rows applied |
