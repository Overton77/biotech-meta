# W19 model cards

Owned elements (sole file writer W19, all `maturity: CANDIDATE`): enums `AuthorityScope`, `DiscoveryOutcome`; nodes `SourceAuthorityAssessment`, `SourceCoverageRequirement`, `SourceDiscoveryRecord`; relationships `ASSESSES_SOURCE_AUTHORITY`, `ASSESSED_ON_SNAPSHOT`, `FOR_COVERAGE_REQUIREMENT`, `DISCOVERED_SOURCE`. No relationship-property type is needed (all four edges are structural without properties). Section 4 holds cards for changes proposed to other owners (not in the fragment). Privacy class: every W19 node is INTERNAL (shared graph, excluded from public projections; W23 seam W19-SR-14). Kinds: asserted / observed / calculated / inferred / operational.

## 1. Enums

### AuthorityScope (owner W19, candidate)

- Meaning: kind of proposition a source is primary or highly relevant for. A scope licenses "this source is a proper place to read claims of this kind"; it never makes a claim true.
- Values and definitions: see `sdl-fragment.graphql` (12 values). Counts over the registry: REFERENCE_DEFINITION 34, STUDY_REPORT 22, REGULATORY_FRAMEWORK 21, SELF_DECLARATION 15, SECONDARY_REPORT 12, BIBLIOGRAPHIC_STATUS 10, REGULATORY_ACTION 7, CERTIFICATION_STATUS 4, TRIAL_REGISTRATION 4, SPEECH_RENDITION 4, COMMERCE_DISPLAY 3, LABEL_DECLARATION 3.
- Missingness: a Source with no current assessment is NOT_ASSESSED for every scope (Q-15 reports it), never "not authoritative".
- Mapping rule: `registry-authority-mapping.yaml` (deterministic table + 11 overrides). Counterexample of misuse: putting a SEC filing under REGULATORY_ACTION because the SEC is a regulator; the filing is the company's self-declaration.
- Source: registry policy "Authority is claim-specific, not organization-global".

### DiscoveryOutcome (owner W19, candidate)

- Meaning: result of one discovery attempt. FOUND, NOT_FOUND, BLOCKED, PARTIAL, ERROR. NOT_ATTEMPTED is the absence of a record and is computed, never stored.
- Rules: an HTTP 200 whose body is an error or denial page is BLOCKED (real: ClinicalTrials.gov history tab, 2026-10-04); NOT_FOUND requires a covering index or endpoint that ran to completion; PARTIAL when the tool truncates or reranks (real: RSS feed "too long to process in full"); ERROR is technical and retryable.
- Distinct from `CaptureCompleteness` (W00), which describes a snapshot that exists.

## 2. Nodes

### SourceAuthorityAssessment

| Item | Value |
|---|---|
| Meaning | Method-versioned judgment of which AuthorityScope values one Source is authoritative for, with verbatim registry tags. Not a reliability score, not a truth value, not a publisher property. |
| Archetype / labels | EvidenceAssessment; `["SourceAuthorityAssessment","EvidenceAssessment"]` |
| uid token | proposed `source-authority` (W19-SR-05); fixtures use registered `assessment` |
| Identity | uid; natural key for dedup: (assessed Source uid, methodVersion, recordedAt) |
| Required properties | `assessmentType` (String, = 'SourceAuthorityAssessment'), `methodVersion` (String, e.g. w19-authority-scope-v0.1), `status` (AssessmentStatus), `recordedAt` (DateTime, service-assigned), `authorityScopes` ([AuthorityScope!]!, may be empty), `assessedAt` (DateTime) |
| Optional | `recordedTo` (set once when superseded), `authorityForTags`, `notAuthorityForTags` ([String], verbatim, kind: asserted-by-registry/curated), `registryEntryId`, `rationale`, `summary` |
| Never written | `overallScore`, `confidence` (interface fields; Q-14c) |
| Edges | `ASSESSES_SOURCE_AUTHORITY` → `Source` (structural, exactly_one); `ASSESSED_ON_SNAPSHOT` → `SourceSnapshot` (structural, many); `WAS_GENERATED_BY` → `Activity` (W00, zero_or_one); `ASSESSED_BY` → Agent/Person (W00); `SUPERSEDES {SupersessionProperties}` → `SourceAuthorityAssessment` (W00, same label) |
| Temporal | immutable; current = `recordedTo IS NULL AND status <> WITHDRAWN` |
| Derived use | Q-15 joins predicate → required scopes (proposed catalog convention, W19-SR-04) |
| Kind | inferred (BellLabs judgment) |
| Privacy | INTERNAL |
| CQ / failure | CQ-PV-C01; filing-sourced OPERATING state; registry-sourced "unpublished" |
| Invariant (candidate INV-W19-1) | an authority assessment never sets `Assertion.status`, never creates or changes an Adjudication verdict, and has no edge to an Assertion, Adjudication, Claim or other assessment (Q-14a) |

### SourceCoverageRequirement

| Item | Value |
|---|---|
| Meaning | INTERNAL operational specification of which source kinds/scopes must be captured for subjects of a label, maximum age of the newest capture, and whether record history is required. Coverage status is computed per subject and viewpoint (Q-13). |
| Archetype / labels | InformationArtifact; `["SourceCoverageRequirement","InformationArtifact"]` |
| uid token | proposed `coverage-requirement`; fixtures use registered `policy` |
| Identity | uid; `requirementKey` + `versionLabel` unique (application-enforced) |
| Required | `artifactType`, `requirementKey`, `versionLabel`, `subjectLabel` (catalog primary label), `requiredSourceKinds` ([SourceKind!]!), `requireCompleteCapture` (Boolean), `revisionHistoryRequired` (Boolean), `recordedAt` |
| Optional | `predicateScope`, `requiredAuthorityScopes`, `maxSnapshotAgeDays` (Int, days; null = no bound), `rationale`, `recordedTo`, `publishedAt` (when the requirement was issued) |
| Edges | inverse `FOR_COVERAGE_REQUIREMENT` from `SourceDiscoveryRecord` |
| Temporal | immutable; a new version is a new node with the same `requirementKey`; old `recordedTo` set once; Q-13 selects the version current at R |
| Kind | operational |
| Privacy | INTERNAL |
| Missingness | no requirement for a label = coverage not specified (Q-13 returns no row), never "covered" |
| CQ / failure | CQ-PV-C02, CQ-AX-06, CQ-ST-08 |

### SourceDiscoveryRecord

| Item | Value |
|---|---|
| Meaning | One bounded attempt to find or fetch a source for a subject; outcome and evidence. A specialization of PROV Activity. |
| Archetype / labels | Occurrence; `["SourceDiscoveryRecord","Activity","Occurrence"]` (one archetype; `Activity` is a domain parent label like `Source` under `Document`) |
| uid token | proposed `source-discovery`; fixtures use registered `activity` |
| Required | `occurrenceType`, `activityKind` (= DISCOVERY, W19-SR-03), `discoveryOutcome`, `startedAt` |
| Optional | `endedAt`, `methodVersion`, `externalRunSystem`, `externalRunId`, `discoveryTarget` (CURRENT_RECORD, RECORD_HISTORY, FULL_TEXT, ITEM_IN_FEED, RENDITION; controlled string, candidate enum later), `attemptedUri`, `queryText`, `responseStatusCode`, `blockEvidence` (verbatim), `resultCount`, `subjectUid`, `subjectLabel` |
| Edges | `FOR_COVERAGE_REQUIREMENT` → `SourceCoverageRequirement` (zero_or_one); `DISCOVERED_SOURCE` → `Source` (many); W00 `WAS_ASSOCIATED_WITH` → Agent; a captured `SourceSnapshot` `WAS_GENERATED_BY` the record |
| Not edges | no edge to the subject or to any Assertion; `subjectUid` is a property by design (Q-14a) |
| Temporal | immutable occurrence; `startedAt` is when the attempt ran (operational time), not valid time |
| Kind | operational / observed |
| Privacy | INTERNAL |
| CQ / failure | CQ-PV-C03; blocked history read as "no versions"; truncated feed read as "item absent" |

## 3. Relationships (owned, candidate)

| Type | From → To | Class | Cardinality | Properties | Rule |
|---|---|---|---|---|---|
| `ASSESSES_SOURCE_AUTHORITY` | SourceAuthorityAssessment → Source | structural | exactly_one per assessment | none | the Source, not the publisher, is assessed |
| `ASSESSED_ON_SNAPSHOT` | SourceAuthorityAssessment → SourceSnapshot | structural | many | none | snapshots belong to the assessed Source (application check) |
| `FOR_COVERAGE_REQUIREMENT` | SourceDiscoveryRecord → SourceCoverageRequirement | structural | zero_or_one | none | requirement version current at `startedAt` |
| `DISCOVERED_SOURCE` | SourceDiscoveryRecord → Source | structural | many | none | only for FOUND or PARTIAL outcomes |

## 4. Proposed changes to other owners (seam cards; not in the fragment)

### Source.renditionCoverage and enum RenditionCoverage (owner W00; W19-SR-02)

- Meaning: how much of the work's content this endpoint carries: FULL, PARTIAL, UNKNOWN. Null on Sources that are not renditions.
- Example: PubMed record of PMID 29184669 = PARTIAL (abstract); PMC5701244 = FULL; Apple Podcasts record = PARTIAL.
- Counterexample: using `captureCompleteness` for this; a COMPLETE capture of the PubMed record is still a partial capture of the article.
- Reading rule (Q-08): FOUND if any rendition snapshot supports the predicate; NOT_CAPTURED if no snapshot; NOT_FOUND_IN_COMPLETE_CAPTURE only when every searched Source is FULL and has a COMPLETE snapshot; otherwise NOT_FOUND_IN_PARTIAL_CAPTURE. Only NOT_FOUND_IN_COMPLETE_CAPTURE may feed a reviewed NOT_DISCLOSED or a negative-polarity assertion.
- Kind: observed (curated per Source). Temporal: may change if the host changes coverage (new value = Source property history via snapshot; low churn).

### SourceKind additions (owner W00; W19-SR-01)

| Value | Definition | Registry entries needing it | Failing case without it |
|---|---|---|---|
| TRIAL_REGISTRY_RECORD | a study record in a trial registry (ClinicalTrials.gov, EU CTR, ISRCTN) | 4 | registry mapped to REGULATORY_RECORD, so registry status passes as an agency action (CQ-MF-02/03, INV-010) |
| BIBLIOGRAPHIC_RECORD | a bibliographic database record about a work (PubMed, Crossref) | 7 (incl. 4 PubMed URLs filed as `peer_reviewed_publication`) | NLM-added publication types read as the authors' statements; abstract-only record treated as full text |
| NEWS_ARTICLE | journalism or trade-press article | 3 | trade press filed as NEWSLETTER or ORGANIZATION_WEBPAGE; retellings undetectable by kind |
| LEGISLATION_OR_REGULATION | binding legal text (statute, CFR section, final rule) | 8 | binding rule and non-binding guidance indistinguishable (V-334 legal-basis cases) |
| PRESENTATION_SLIDES | a slide deck or poster document | 0 (CL-003 pair) | deck filed as ORGANIZATION_WEBPAGE; R4 untestable |
| PERSONAL_WEBPAGE | a page published by an individual | 1 (public protocol page) | ORGANIZATION_WEBPAGE implies an organizational publisher |
| TECHNICAL_DOCUMENTATION | vendor or service technical documentation (IFU, API docs) | 15 | no kind for assay IFUs and service docs (CQ-DX) |
| OTHER (+ `sourceKindNote`) | escape value for a closed enum | 8 (textbooks, wikis, feeds) | a closed enum without an escape forces mis-classification |

Rule: revision states ("retracted", "corrected") are never kinds (registry `peer_reviewed_publication_retracted` → PEER_REVIEWED_PUBLICATION + SourceRevisionEvent).

### canonicalUri rule (owner W00; W19-SR-10)

Post-redirect retrieval endpoint; scheme https; host lowercased; tracking parameters removed; never an identifier resolver (doi.org, identifiers.org, n2t.net); per kind: PubMed `https://pubmed.ncbi.nlm.nih.gov/<pmid>/`, PMC `https://pmc.ncbi.nlm.nih.gov/articles/<PMCID>/`, YouTube `https://www.youtube.com/watch?v=<id>`, RSS item `<feed URL>#<guid>` (guid percent-encoded), ClinicalTrials.gov `https://clinicaltrials.gov/study/<NCT>`. Uniqueness on the stored property (W00 operations).

### predicateAuthorityScopes convention (owner W00 catalog; W19-SR-04)

A catalog map from predicate (or predicate family) to the AuthorityScope values whose sources can establish it. Initial rows (used by Q-15): HAS_CAPABILITY_STATE → [REGULATORY_ACTION, CERTIFICATION_STATUS]; RESULTS_PUBLISHED → [BIBLIOGRAPHIC_STATUS, STUDY_REPORT]; REGISTERED_ENROLLMENT_COUNT → [TRIAL_REGISTRATION]; PROVIDES_INVESTIGATIONAL_PRODUCT → [STUDY_REPORT, TRIAL_REGISTRATION, SELF_DECLARATION]; CORRECTS → [BIBLIOGRAPHIC_STATUS]. A missing row = NOT_ASSESSED, never "any source".

## 5. Derived rules (no stored property)

| Rule | Inputs | Output | Query |
|---|---|---|---|
| Primary vs retelling | `RETELLS*` chain | PRIMARY (no outgoing RETELLS) / RETELLING with hops and root | Q-05 |
| Independent lines | roots of `RETELLS*` per Claim | count of distinct roots (lower bound; shared datasets and sponsors are separate, CQ-AX-05) | Q-06 |
| Coverage status | requirement current at R, subject, snapshots retrieved by R, discovery records by R | FRESH / STALE / NOT_FOUND / BLOCKED / NOT_ATTEMPTED; history RETRIEVED / BLOCKED / NOT_ATTEMPTED / NOT_REQUIRED | Q-13 |
| Not-found reading | rendition coverage, capture completeness, supporting assertions | FOUND / NOT_CAPTURED / NOT_FOUND_IN_COMPLETE_CAPTURE / NOT_FOUND_IN_PARTIAL_CAPTURE | Q-08 |
| Authority finding | predicate scopes, current assessments of supporting Sources | AUTHORITATIVE_SOURCE_PRESENT / NO_AUTHORITATIVE_SOURCE / NOT_ASSESSED | Q-15 |

None of these outputs is written back to an Assertion, Claim, Source or Adjudication.
