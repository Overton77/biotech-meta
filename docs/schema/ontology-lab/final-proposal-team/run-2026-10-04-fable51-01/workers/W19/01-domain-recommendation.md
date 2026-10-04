# W19 Source Intelligence: domain recommendation

Worker W19 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 (`8fb50ff0…84f0`), live schema `86b5e0b5…f112`, source registry `f4b9e226…739fcc`. Research ownership only: canonical `Source`, `SourceSnapshot`, `SourceLocator`, `SourceRevisionEvent` and `Activity` stay with W00 (provenance module); `Document` SDL stays with W20; `Publication` with W09; `Episode` with W21.

## 1. Boundary

Source Intelligence answers four operational questions about where evidence comes from. It does not answer whether anything is true.

| Subdomain | Question | Records (owner) |
|---|---|---|
| Source identity | Which retrieval endpoint is this, and which work does it render? | `Source`, `Document` (W00, W20); `RENDITION_OF` (W00); `Publication` (W09), `Episode` (W21) |
| Source classification | What kind of endpoint is it, and which kinds of claims is it primary for? | `Source.sourceKind` (W00 enum); `AuthorityScope` enum and `SourceAuthorityAssessment` (W19 candidates) |
| Primary versus retelling | Is this assertion the original statement or a retelling of one? | derived from `RETELLS` chains (W21); no Source-level flag |
| Discovery, coverage, freshness | Which sources were required, which were sought, what came back (found, not found, blocked, partial), and how old is the newest capture? | `SourceCoverageRequirement`, `SourceDiscoveryRecord` (W19 candidates); `SourceSnapshot.captureCompleteness`, `observedAt`, `retrievedAt` (W00) |

Evidence Provenance (W00) records what was actually captured and asserted. Source Intelligence records what *should* be captured, what was *sought*, and for which *claim scopes* a source is authoritative. The two meet only at `Source` and `SourceSnapshot`. No W19 record points at an `Assertion`, `Adjudication`, `Claim` or other assessment (guard Q-14a), so no operational or authority record can become a premise of truth, status or a SUPPORT verdict.

## 2. CL-003 identity rule (proposed)

Contract D-005 fixed the labels. This packet supplies the rule that decides, for any URL, which node it is, with real minimal pairs (fixture 01).

**R1. Work versus endpoint.** A work is what a citation names independent of where it is read: a scholarly `Publication` (W09) or a published audio/video `Episode` (W21). A `Source` is one retrieval endpoint: one `canonicalUri`, one host, its own snapshots. `Document` is a `Source` specialization (`["Document","Source","Entity"]`) for text/document endpoints. Identifiers (DOI, PMID, PMCID, NCT, YouTube video id) identify works or records through `Identifier` nodes; they are never a `Source`.

**R2. canonicalUri is the retrieval endpoint, never an identifier resolver.** `https://doi.org/10.1038/s41514-017-0016-9` is the DOI of the work; the Sources are the pages and files it resolves to. Fixture N2 / Q-02. Real evidence: 15 of the 127 registry entries (`registry-authority-mapping.yaml`, `urlRole: WORK_IDENTIFIER_NOT_ENDPOINT`) use a doi.org URL, and V-235 joins `canonicalUri = 'https://doi.org/' + doi`; that join silently misses the PMC and PubMed renditions and cannot be snapshotted (doi.org only redirects; it was also egress-blocked in this session).

**R3. RENDITION_OF test.** A Source is `RENDITION_OF` a work iff it carries some of the work's own content (text, abstract, audio, video, transcript) such that a passage or utterance of the work can be located in it. At most one work per Source; the target is always a work, never another Source (Q-03; N3 shows that a Source-to-Source rendition edge launders V-411). How much of the work it carries is `renditionCoverage` (FULL, PARTIAL, UNKNOWN; seam W19-SR-02). Records only *about* a work (registry entries listing it, retellings, news, directories without content) are not renditions; they reach the work through Assertions whose subject is the work.

**R4. A presentation document is not a rendition of the talk.** A slide deck PDF is its own `Document` and its own claim container; the recorded talk is an `Episode` whose video Sources are its renditions. A deck claim is asserted by whoever authored the deck (often the company); a spoken claim by the speaker. If the deck were a rendition of the talk, V-411 would accept a deck locator as support for a spoken claim (N1b silences V-411; Q-04 catches it). The link between deck and talk is an assertion (the conference page says "slides for this talk"), seam W19-SR-07.

**R5. One erratum, many revisions.** A correction notice is its own `Publication` (W09 `publicationKind` AUTHOR_CORRECTION) with its own renditions; it `CORRECTS` the article (asserted). Each rendition whose bytes changed gets its own `SourceRevisionEvent` (`REVISES_SOURCE` is exactly_one). Real: Nature states the correction "has now been corrected in the PDF and HTML versions of the Article", so the HTML and PDF Sources each get an ERRATUM event announced in the notice; the PubMed record of 29184669 still shows publication type "Journal Article" only, so it gets none (whether its links changed cannot be established).

### Minimal pairs (all in fixture 01; expected rows in `06-fixtures-and-queries.md`)

| Case | Work | Sources (`sourceKind`, `renditionCoverage`) | Not a Source |
|---|---|---|---|
| Article PMID 29184669 | `Publication` hu:publication:pmid-29184669 | nature.com HTML (PEER_REVIEWED_PUBLICATION, FULL); nature.com PDF (PEER_REVIEWED_PUBLICATION, FULL); PMC5701244 (PEER_REVIEWED_PUBLICATION, FULL); PubMed record (BIBLIOGRAPHIC_RECORD, PARTIAL: abstract) | DOI 10.1038/s41514-017-0016-9, PMID, PMCID: `Identifier`s of the work |
| Author Correction PMID 30155270 | second `Publication` | PubMed record (BIBLIOGRAPHIC_RECORD, FULL for a one-line notice) | DOI 10.1038/s41514-018-0027-1 |
| Huberman Lab #52 | `Episode` | transcript page (PODCAST_TRANSCRIPT_PAGE, FULL); YouTube video (VIDEO_RENDITION, FULL; its caption track is a text version of the video snapshot, W20); RSS item (AUDIO_FEED_ITEM, FULL; dynamic ad insertion means two fetches can return different bytes: two snapshots, one Source); Apple Podcasts record (PODCAST_DIRECTORY_RECORD, PARTIAL) | the RSS feed document itself is a separate Source (not a rendition) |
| Talk and deck (synthetic) | talk `Episode` | talk video (VIDEO_RENDITION) | deck PDF is a `Document` with its own container; not `RENDITION_OF` the talk |

### Why one Publication, several Sources (real record differences found this session)

- The PubMed record carries only the abstract plus NLM metadata; the sentence "The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health (New York, NY)." appears in the publisher HTML and in the PMC full text, not in the PubMed record. Searching the PubMed record alone must read NOT_FOUND_IN_PARTIAL_CAPTURE even if the record capture is COMPLETE (Q-08a), because the rendition is PARTIAL. Searching all renditions reads FOUND (Q-08b). A Source-level `renditionCoverage` is the only place this fact can live: `captureCompleteness` describes how much of the *endpoint* was captured, not how much of the *work* the endpoint carries.
- The PMC full text served through the PubMed connector dropped the ClinicalTrials.gov identifier ("(clinical trials.gov identifier)") and every superscript ("NADlevels"), while the PubMed HTML capture reads "NAD+ levels". Same work, different text renderings: quote anchors are per rendition and per text version (W20), never per work.
- An occurrence asserted in the paper must have the **Publication** as container, or a locator in PMC is foreign to a container that is the nature.com Document (V-411 fires in isolated negative N7). Seam W19-SR-06 asks W21 to add `Publication` to the `OCCURS_IN` range.

### Why the transcript page and the captions are two renditions, not one text

Real capture 2026-10-04 of the same utterance of episode 52:

- publisher transcript: "And so I know if something's, or I know if something's making me better or worse based on measuring 45 different things."
- YouTube captions at [1:03:08]: "And so I've been measuring myself and so I know if something's, or I think I know if something's making me better or worse ..."

The captions carry a hedge ("I think I know") that the publisher transcript lacks; the transcript carries speaker labels and no timecodes; the captions carry timecodes and no speaker labels. Neither establishes the audio. One `ClaimOccurrence` (container: the Episode) is supported by a TEXT_QUOTE locator on the transcript snapshot and a MEDIA_TIME locator on the video snapshot; Q-07 reports occurrences whose rendition quotes disagree for review (CQ-PV-04). Cross-rendition alignment is **not** `REANCHORS` (V-409 restricts it to one Source; N6).

## 3. Disposition of every element in scope

Legend: keep, refine, merge, split, seam (request to the owner), derive, retire, defer. Identity (I), state (S), artifact (A), occurrence (O).

### Catalog provenance and conventions (W00 owns; W19 disposition is a recommendation)

| Element | Kind | W19 disposition | Note |
|---|---|---|---|
| `Source` (Entity) | I | keep; seam W19-SR-02 (`renditionCoverage`), W19-SR-10 (canonicalUri rule) | no reliability, truth or "primary" property, ever |
| `Source.canonicalUri` | I key | refine (rule R2, W19-SR-10) | uniqueness on stored property per kind-specific canonicalization |
| `Source.title` | A | keep | presentation only |
| `Source.sourceKind` | classification | keep; extend (W19-SR-01) | endpoint kind; never a revision state ("retracted" is a `SourceRevisionEvent`) |
| `Source.publisherUid` | I ref | keep | publisher is an `Organization`/`Person`; live `Document.publisher` string stays as verbatim |
| `SourceSnapshot` and its fields (`contentHash`, `contentHashBasis`, `captureCompleteness`, `retrievedAt`, `observedAt`, `publishedAt`, `storageUri`, `archiveUri`, `publisherRevisionNotice`, `mimeType`, `language`) | A | keep | rule added: when a capture service returns a cached copy, `observedAt` is the service's cache time (real: Firecrawl `cachedAt 2026-10-03T06:00:23Z` for a 2026-10-04 request), W19-SR-15 |
| `SourceLocator` and typed selector fields | A | keep (no alternative locator) | per rendition and per text version |
| `SourceRevisionEvent` (+ `REVISES_SOURCE`, `PRIOR_SNAPSHOT`, `RESULTING_SNAPSHOT`, `ANNOUNCED_IN`) | O | keep; one event per affected Source (R5) | `RESULTING_SNAPSHOT` is the first snapshot observed after the change, not necessarily the instant state |
| `RENDITION_OF` | structural | keep; refine by test R3 and Q-03 | target is a work; at most one per Source |
| `HAS_SNAPSHOT`, `HAS_LOCATOR`, `REANCHORS` | structural | keep; V-409/V-512 ordering refined (W19-SR-09) | an archive capture retrieved after a live capture is older by `observedAt`; the current validators report it (fixture 04) |
| `provenanceStates` (five) | rule | keep | Q-18 returns each state and names absent ones |
| forbidden `[NOT_FOUND_IN_PARTIAL_CAPTURE, NOT_DISCLOSED]` | rule | keep; generalize to partial renditions (Q-08, W19-SR-13) | |
| forbidden `[ASSERTION_STATUS_ACCEPTED, PROPOSITION_TRUE]`, `[CORRECTS_SOURCE, FACT_CEASED]` | rule | keep | Q-14b: ACCEPTED status unaffected by coverage |
| `conventions.sourceKind` (27 values) | enum | keep all; add 8 (W19-SR-01) | 46 of 127 registry entries have no catalog value today |
| `conventions.contentHashBasis` | enum | keep | STORED_EXCERPT_TEXT used for all real captures here |
| `conventions.captureCompleteness` (COMPLETE, PARTIAL_EXCERPT, UNKNOWN) | enum | keep unchanged | BLOCKED and SEARCH_EXTRACT are not completeness values: a blocked fetch has no snapshot (→ `DiscoveryOutcome`), a search extract is a PARTIAL_EXCERPT whose method lives on the CAPTURE `Activity` |
| `conventions.selectorKind` | enum | keep | |
| `ActivityKind` | enum | extend with DISCOVERY (W19-SR-03) | |

### Live and claims_and_documents elements

| Element | Owner | W19 disposition | Note |
|---|---|---|---|
| `Document` (live) | W20 | keep as `["Document","Source","Entity"]` | a Document is always a Source; one canonicalUri |
| `Document.sourceUrl` (`url`) | W20 | seam → `Source.canonicalUri` (rule R2) | doi.org values become `Identifier`s on the work |
| `Document.isPrimarySource` | W20 | retire (derive per assertion from `RETELLS`) | Q-05 ignores the flag (fixture 02 sets it true on a retelling outlet) |
| `Document.isRegulatorySource` | W20 | derive from `sourceKind` (REGULATORY_RECORD, REGULATORY_GUIDANCE, LEGISLATION_OR_REGULATION) | |
| `Document.isPeerReviewed`, `isFinancialDisclosure` | W20 | keep | venue/genre facts; retraction never changes them |
| `Document.documentType` / `DocumentType` | W20 | keep as work/genre; map to `sourceKind` (migration-map) | `SCIENTIFIC_ARTICLE` is a genre, `PEER_REVIEWED_PUBLICATION` an endpoint kind |
| `Document.publisher`, `publicationVenue` | W20/W09 | seam: publisher → `publisherUid`; venue → `Publication` | |
| `Document.publishedAt` | W20 | split: work time on `Publication`/`Episode`; issue time of a version on `SourceSnapshot.publishedAt` | |
| `Document.fileFormat`, `languageCode` | W20 | move to `SourceSnapshot.mimeType`, `language` | per capture |
| `Document.sourceForEpisodes` (`SOURCE_OF`) | W20/W21 | rename → `RENDITION_OF` (direction Source → Episode) | as alignment table says |
| `Publication` | W09 | keep (work) | DOI, PMID, PMCID as `Identifier`s (W19-SR-11) |
| `Episode` | W21 | keep (work) | |
| `OCCURS_IN` | W21 | refine: range adds `Publication` (W19-SR-06) | |
| source registry `kind`, `authorityFor`, `notAuthorityFor` | repo data | map to `sourceKind` + `SourceAuthorityAssessment` (`registry-authority-mapping.yaml`) | verbatim tags kept |

### W19 candidates (this packet's only SDL)

| Element | Archetype | Disposition | Admission evidence |
|---|---|---|---|
| `AuthorityScope` (12 values) | enum | new candidate | grounded in all 127 registry entries (every entry maps; counts below) |
| `DiscoveryOutcome` (5 values) | enum | new candidate | real FOUND, BLOCKED (two kinds), PARTIAL outcomes this session |
| `SourceAuthorityAssessment` | EvidenceAssessment | new candidate | CQ-PV-C01; Q-15 failing cases |
| `SourceCoverageRequirement` | InformationArtifact | new candidate (INTERNAL) | CQ-PV-C02; Q-13 |
| `SourceDiscoveryRecord` | Occurrence (Activity specialization) | new candidate (INTERNAL) | CQ-PV-C03; Q-13, Q-17 |
| `ASSESSES_SOURCE_AUTHORITY`, `ASSESSED_ON_SNAPSHOT`, `FOR_COVERAGE_REQUIREMENT`, `DISCOVERED_SOURCE` | structural | new candidate | used by the above |

## 4. AuthorityScope: the smallest set grounded in the registry

The registry policy is "Authority is claim-specific, not organization-global". Its 127 entries carry 240 distinct `authorityFor` tags (242 uses): nearly every tag is unique, so the tags cannot be filtered or joined to predicates. Twelve scopes cover every entry (rule table plus 11 grounded per-entry overrides; 12 entries need two scopes):

| Scope | Entries | Typical registry kinds |
|---|---|---|
| REFERENCE_DEFINITION | 34 | terminology_record, standard_specification, interoperability_standard, product_documentation |
| STUDY_REPORT | 22 | peer_reviewed_publication, preprint, published_correction |
| REGULATORY_FRAMEWORK | 21 | regulatory_guidance, regulation, final_rule, regulation_guide |
| SELF_DECLARATION | 15 | official_organization_page, marketing_page, securities_filing, self_disclosure_page |
| SECONDARY_REPORT | 12 | trade_press, third_party_profile_page, secondary_retelling_article |
| BIBLIOGRAPHIC_STATUS | 10 | bibliographic_database_record, correction_notice, retraction_notice_record |
| REGULATORY_ACTION | 7 | regulatory_record, warning_letter, legal_record |
| CERTIFICATION_STATUS | 4 | certification_listing, certifier_explainer |
| TRIAL_REGISTRATION | 4 | trial_registry_record |
| SPEECH_RENDITION | 4 | publisher_transcript_page, video_rendition, podcast_directory_record |
| COMMERCE_DISPLAY | 3 | marketplace_listing, marketplace_brand_page |
| LABEL_DECLARATION | 3 | official_label_page, official_product_and_label_page |

Why not fewer: each split is a distinction a CQ needs. LABEL_DECLARATION vs SELF_DECLARATION (INV-006, CQ-PF: a label declaration is not a marketing claim and not measured composition); TRIAL_REGISTRATION vs STUDY_REPORT (CQ-ST-08: registry and paper disagree on sites, 1 vs 3); REGULATORY_ACTION vs REGULATORY_FRAMEWORK (CQ-MF-02/03: a guidance page cannot establish a product's status); SPEECH_RENDITION vs SECONDARY_REPORT (CQ-PV-05: original versus retelling); BIBLIOGRAPHIC_STATUS (CQ-EV-05: correction status from the record, not from the article). Why not more: anything finer is the verbatim tag, which is kept.

Reliability is not a scope. A `SourceAuthorityAssessment` is method-versioned, claim-scoped and never scores the publisher; `overallScore` and `confidence` stay null (Q-14c).

## 5. Alternatives considered

| Alternative | Rejected because |
|---|---|
| `Source.reliabilityScore` or a publisher truth score | contract and both reviews forbid it; the registry's own policy is claim-specific; a 10-K is authoritative for what the company says about supply dependence, not for facility operations |
| `Source.authorityScopes` as a plain property | authority is a BellLabs judgment that changes (NGSP listing "as of page update"); a property has no method, version or recorded time |
| `Document.isPrimarySource` | primary is per assertion (CQ-PV-05); the same newsletter can quote one speaker and originate another claim |
| One Source per work (DOI as canonicalUri) | loses rendition text differences (PMC drops superscripts and the NCT id; captions add a hedge), breaks snapshots (doi.org redirects), breaks V-411 for paper claims |
| PubMed record as "not a rendition" | abstract-based extraction is the most common path and would need fake containers; coverage PARTIAL captures the limitation exactly |
| Slide deck as rendition of the talk | lets V-411 accept deck locators for spoken claims; different asserters |
| `CaptureCompleteness += BLOCKED, SEARCH_EXTRACT` | a blocked fetch has no snapshot to carry the value; a search extract is a partial excerpt whose method belongs to the capture Activity |
| Discovery as a plain `Activity` with extra kernel properties | adds discovery-only fields to every Activity; a labelled specialization keeps Activity lean and still reuses `WAS_ASSOCIATED_WITH` and `WAS_GENERATED_BY` |
| Edges from discovery records to subjects | would mix operational logs into knowledge traversals; `subjectUid` keeps them separate (Q-14a) |

## 6. Smallest recommended model

1. No new node in the kernel. The CL-003 rule (R1–R5) plus `Source.renditionCoverage` (W00) and the `SourceKind` additions (W00) answer CQ-PV-05, CQ-EV-05 and the identity minimal pairs with existing types.
2. One enum (`AuthorityScope`) plus one assessment type (`SourceAuthorityAssessment`) answer authority-by-claim-type (CQ-PV-C01).
3. Two INTERNAL operational types (`SourceCoverageRequirement`, `SourceDiscoveryRecord`) plus `DiscoveryOutcome` answer coverage, freshness and blocked-versus-absent (CQ-PV-C02, CQ-PV-C03). If Fable rejects them, the fallback is: freshness from `SourceSnapshot.observedAt` alone (QS-2 `OPEN_END_STALE`), and BLOCKED retrievals recorded only in worker manifests, which leaves CQ-ST-08's "history not retrieved" unanswerable from the graph.
