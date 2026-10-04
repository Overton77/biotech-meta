# W19 decision and seam ledger

Status words: **proposed** (this packet recommends; Fable/W00 rule), **unresolved** (needs another owner's evidence), **rejected** (alternative not recommended). Nothing here is accepted until Fable rules; no consensus is claimed. Seam requests are in `seam-requests.yaml` (W19-SR-01 … SR-16).

## 1. Conflict records this packet answers

### CL-003 Source vs Document vs Publication vs Episode — proposed ruling

- **Rule.** R1 work vs endpoint; R2 canonicalUri never an identifier resolver; R3 RENDITION_OF test with `renditionCoverage`; R4 presentation document is not a rendition of the talk; R5 one revision event per affected rendition, publication-level `CORRECTS` separately (`01-domain-recommendation.md` §2).
- **Evidence.** PubMed records 29184669 / 30155270 and PMC5701244 (N-01…N-04); nature.com in-place correction notice (N-05); episode 52 transcript page vs YouTube captions (N-12, N-13); RSS feed with dynamic-ad marker (N-14); registry URL analysis (15 doi.org, 4 PubMed-as-article).
- **Fixtures.** 01 (positive), 90 N1b/N2/N3, 91, 92 (negative). Queries Q-01…Q-04, Q-07, Q-08, Q-10.
- **Responses requested.** W20 (Document always a Source; DocumentType genre vs SourceKind; captions as text versions, W19-SR-12), W21 (OCCURS_IN Publication, W19-SR-06; deck–talk link, W19-SR-07; multi-author asserter, W19-SR-08), W09 (Publication identifiers and erratum as Publication, W19-SR-11), W00 (rule adoption, renditionCoverage, canonicalUri, V-235, W19-SR-02/10).
- **Migration.** `Document.sourceForEpisodes` → `RENDITION_OF`; `Document.sourceUrl` canonicalization; doi.org registry URLs become Identifiers.
- **Status.** proposed.

### CL-012 Source Intelligence research vs provenance canonical ownership — proposed ruling

- W00 keeps `Source`, `SourceSnapshot`, `SourceLocator`, `SourceRevisionEvent`, `Activity`, `RENDITION_OF`, `SourceKind`, `CaptureCompleteness` and all their fields. W19 writes no alternative snapshot or locator.
- W19 is sole writer of `AuthorityScope`, `DiscoveryOutcome`, `SourceAuthorityAssessment`, `SourceCoverageRequirement`, `SourceDiscoveryRecord` and four structural edges, all candidate. Changes W19 needs on W00 types are seam requests (SR-01…05, 09, 10, 13, 15).
- `SourceDiscoveryRecord` carries the `Activity` label (specialization, like `Document` under `Source`); W00 must accept the label sharing (SR-03). If W00 refuses, fallback: discovery outcome fields move to a W00 Activity subtype, W19 drops the type.
- **Status.** proposed.

## 2. Decisions

| Id | Decision | Evidence | Alternatives (why not) | Status |
|---|---|---|---|---|
| W19-D01 | No source-wide reliability or truth score on any type; authority is a claim-scoped, method-versioned assessment | registry policy; handoff §2; contract A4; Q-14c | `Source.reliabilityScore` (global), `Source.authorityScopes` property (no method/time) | proposed |
| W19-D02 | AuthorityScope = 12 values covering all 127 registry entries; verbatim tags kept | `registry-authority-mapping.yaml` (240 distinct tags) | free-text tags only (not filterable); ~25 finer scopes (duplicate the tags) | proposed |
| W19-D03 | `SourceAuthorityAssessment` as EvidenceAssessment, one Source each, never a verdict | Q-15 failing cases (synthetic 10-K OPERATING; registry RESULTS_PUBLISHED) | extend V-324 by sourceKind (a 10-K is non-marketing yet not authoritative for operations) | proposed (candidate type) |
| W19-D04 | Coverage/freshness as an INTERNAL requirement + computed status; never stored on subjects or assertions | Q-13a/b; Q-14a/b | `Source.lastCheckedAt` flags (one clock, no requirement, no history); writing STALE into `Assertion.status` (N9 → V-110) | proposed (candidate type) |
| W19-D05 | Discovery outcomes as an Activity specialization with `DiscoveryOutcome`; BLOCKED includes 200-with-error-page | N-07, N-08, N-14, N-15 | new CaptureCompleteness values (no snapshot to carry them); manifests only (not queryable) | proposed (candidate type) |
| W19-D06 | `subjectUid` property, not an edge, from discovery records | Q-14a guard | edge to subject (mixes operational logs into knowledge traversals) | proposed |
| W19-D07 | PubMed record = PARTIAL rendition of the Publication, not a non-rendition record | N-04 (abstract present, Methods absent) | non-rendition (abstract extraction needs fake containers) | proposed |
| W19-D08 | Captions are a text version of the video rendition; publisher transcript page is a separate rendition Source | N-12 vs N-13 (hedge "I think I know") | one "transcript" per Episode (loses which text was quoted) | proposed (W20 confirms) |
| W19-D09 | Deck ≠ rendition of talk (R4) | N1a/N1b runs | treat as one work (V-411 laundering) | proposed (W21 confirms) |
| W19-D10 | `CaptureCompleteness` unchanged | — | add BLOCKED/SEARCH_EXTRACT | proposed |
| W19-D11 | V-409 and V-512 should order by observedAt | fixture 04 rows under current rule | keep retrievedAt (rejects honest late archive captures) | proposed (W00 rules) |
| W19-D12 | canonicalUri rule and V-235 rewrite | N-15; 15 doi.org registry URLs | DOI URL as Source identity | proposed |

## 3. Kernel-change requests

None to archetypes, Assertion authority, time or privacy. Enum and convention additions only, each with a primary source and failing fixture: SourceKind (+8, SR-01), RenditionCoverage + `Source.renditionCoverage` (SR-02), ActivityKind.DISCOVERY (SR-03), predicateAuthorityScopes (SR-04), uid tokens (SR-05), validator ordering (SR-09), canonicalUri rule (SR-10), QS-7 covering condition (SR-13), cached-capture observedAt rule (SR-15).

## 4. Unresolved items and closure criteria

| Item | Owner | Closure criterion |
|---|---|---|
| Asserter of multi-author publication statements | W21 + W01 | a written rule and a fixture with two authors disagreeing |
| Deck–talk link predicate name; Presentation work type | W21 | a real deck/talk pair with different claims captured |
| Whether PMC author manuscripts need a version marker distinct from the version of record | W09 + W00 | one PMC record whose text differs from the publisher version (not found this session) |
| ClinicalTrials.gov record history retrieval method | W09 | an authorized fetch path (egress currently blocks clinicaltrials.gov directly; history tab returns an error page via Firecrawl) |
| Caption authorship (uploaded vs auto-generated) | W20/W21 | a platform field or uploader statement; not available in the extract |
| `discoveryTarget` as a controlled enum | W19 | after a second operational use beyond RECORD_HISTORY and ITEM_IN_FEED |
| PubMed CommentsCorrections ("Erratum in") field capture | W00 ingestion | an E-utilities fetch (blocked this session) |

## 5. Objections anticipated (for Wave 5 challengers)

- *"Coverage records are operational noise in a knowledge graph."* They are INTERNAL, have no edges into the knowledge graph except to `Source`, and answer CQ-ST-08's "what can't the registry tell me" with evidence instead of prose. If rejected, CQ-PV-C02/C03 become unanswerable and fixture 05's BLOCKED history becomes invisible.
- *"AuthorityScope is a truth score by another name."* It has no number, no publisher scope, no effect on status or verdicts (Q-14a/b), and a missing assessment reads NOT_ASSESSED.
- *"Twelve scopes are arbitrary."* Every entry maps (127/127); each split is tied to a named CQ distinction (`01` §4).
