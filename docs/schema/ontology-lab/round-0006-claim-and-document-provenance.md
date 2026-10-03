# Ontology Lab Round Record: Round 0006, Claim and Document Provenance

> **Integration decision (2026-10-03):** `REVISED`. Rules accepted; KCR-4.1 to KCR-4.5 accepted; KCR-4.6 accepted with the reconciliation that Adjudication carries adjudicationKind CAPTURE_FIDELITY or SUPPORT so that Assertion.status projects only capture fidelity (round 0007) and never truth (this round). uid token for runs is `activity`. Catalog 0.2.0; see [proposal-index.md](./proposal-index.md).


## Header

- Round ID: 0006
- Date: 2026-10-03
- Builder: Lane 4 (documents, claims, speakers, attribution, provenance)
- Challenger: Lane 4 adversarial pass; open to Lane 6 review
- Owning module: `claims_and_documents` (new, proposed); kernel-change requests against `provenance`
- Candidate schema version: 0.2.0 (proposed)
- Source schema digest: not computed in this environment; live schema read from `current_biotech_schema.graphql` lines 1 to 394, 396 to 651, 1070 to 1145, 2042 to 2882
- Decision status (recommendation): `REVISED`. The rule set below is recommended for acceptance; KCR-4.1 to KCR-4.6 need coordinator decisions. The coordinator sets the final status.

## Intent and competency questions

- Decision or workflow being supported: answer "what did a named speaker claim, where exactly, on what basis, with what qualifications, with which relevant financial ties, and how did later retellings change it", with each answered assertion traced through the five provenance states.
- In scope: alignment of the live evidence pipeline (`Document`, `DocumentTextVersion`, `Segmentation`, `Chunk`, `Claim`, `ClaimOccurrence`, `RelationshipAssertion`, `ExperienceReport`, `Episode`, `EpisodeSegment`, `Channel`, `Series`, `Platform`) with the catalog kernel (`Source`, `SourceSnapshot`, `SourceLocator`, `Assertion`, `Adjudication`, `ResolutionHypothesis`); reproducible locators for mutable pages and media; speaker attribution and claim basis; retelling drift; financial relationships as time-bounded asserted roles; PROV-O alignment; lineage of `mongoResearchRunId` and `ExtractionMetadata`; ecosystem neighbourhoods.
- Out of scope: bitemporal correction mechanics (Lane 5, round 0007; this round only names notice predicates); study evidence synthesis criteria (Lane 2); private recommendation records and `PolicyVersion` contents (Lane 5); patent paths (Lane 3).
- Competency question IDs: CQ-CL-01 to CQ-CL-09, CQ-PV-01 to CQ-PV-06, CQ-EC-01 to CQ-EC-04; reused CQ-EV-01, CQ-EV-02, CQ-EV-03, CQ-EV-05, CQ-RC-05. Lane 1's CQ-AX-18 and CQ-AX-26 are access-tier expressions of CQ-CL-05 and CQ-CL-01/02 (see `competency-questions.md` fragment).

## Case packet

All sources were read on 2026-10-03 through the Tavily extract API (direct fetch to these hosts is blocked by the egress proxy). Captures are partial excerpts; that fact is itself modeled (`captureCompleteness`).

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| SRC-HUBERMANLAB-52-TRANSCRIPT | publisher transcript page | TextQuote "My 82 -year-old father, we take a gram of NMN every day."; "Now another important point, which is I'm not the same as everybody else. I have different microbiome, age, sex."; "I was one of the first people in InsideTracker as a board member and I'm still their scientific lead guy."; "InsideTracker is one of them and you just do it a couple of times a year at a minimum." | observed 2026-10-03; page states "This transcript is currently under human review and may contain errors." | what the publisher's text says was said; not truth; not exact audio while under review |
| SRC-YOUTUBE-HL52 | video rendition | transcript cue [4:47] "Today's episode is also brought to us by InsideTracker."; description chapter "00:03:30 ROKA, InsideTracker, Magic Spoon" | observed 2026-10-03 | host sponsor read in this rendition only |
| SRC-APPLE-PODCASTS-HL52 | directory record | "Publiée 27 décembre 2021 à 09:00 UTC", "Épisode 52", "Chaîne Scicomm Media", host and guest roles, "megaphone.fm/adchoices" | observed 2026-10-03 | publication time; roles as listed; presence of dynamic ad insertion |
| SRC-SINCLAIR-AFFILIATIONS | self-disclosure page | legend "F=Founder; I=Investor; E=Equity; A=Advisor/Consultant; B=Board of Directors; IP=Inventor on licensed patents"; "InsideTracker (Segterra), Cambridge, MA B (2011-2017) I,A,IP (2011-present)"; "EdenRoc Sciences companies F,I,E,A,B, IP"; "MetroBiotech International, an EdenRoc Sciences company, NAD boosters (2015-present)"; "Elysium Health New York, NY (2018) IP" | observed 2026-10-03 | self-declared roles and year bounds as displayed on that date |
| SRC-CATALIO-SINCLAIR | third-party profile | "Scientific Advisory Board: ... Elysium Health, InsideTracker" | search snippet 2026-10-03 | what that profile displays |
| SRC-INSIDETRACKER-TEAM | company page | lists "David Sinclair, PhD" under Scientific Advisory Board with a testimonial | search snippet 2026-10-03 | company-declared listing |
| SRC-YOUTUBE-LIFESPAN-4 | video rendition with correction | description: "Correction and clarification: At time point 1:07:37, Dr. Sinclair says he takes 1 gram of Spermidine, but the active ingredient in the capsules is 1-2 milligrams."; cue [1:08:12] spermidine "about a gram"; cue [1:08:28] "Now, you're not most people." | observed 2026-10-03 | the publisher's correction; the statement as spoken |
| SRC-NMNCOM-SINCLAIR-2026 | secondary retelling | "As core supplements, Dr. Sinclair takes 1 gram of nicotinamide mononucleotide (NMN)..." | observed 2026-10-03 (partial) | what the article states; it cites no span in the extract |
| SRC-PUBMED-NICE-TRIAL-2024 / -CORRECTION-2024 | publication and erratum | PMID 38871717 (DOI 10.1038/s41467-024-49092-5); PMID 39134546 "Publisher Correction" (DOI 10.1038/s41467-024-51289-7) | 2024-06-13; 2024-08-12 | reported result; existence of a correction notice |
| SRC-PUBMED-ALS-NR-PT-2023 | publication and corrigendum | PMID 38241160 (DOI 10.1016/j.neurot.2023.10.011), author R. W. Dellinger affiliation "Elysium Health Inc."; corrigendum PMID 42697153 (DOI 10.1016/j.neurot.2026.e01070) | 2023-12-19; 2026-09-04 | printed affiliations; mouse-model results |
| SRC-W3C-PROV-O, SRC-W3C-WEB-ANNOTATION-MODEL, SRC-NANOPUB-GUIDELINES, SRC-BIOLINK-KL-AT | standards and models | PROV-O wasDerivedFrom subproperties; Web Annotation section 4.2.5 (positions: start inclusive, end exclusive; "very brittle with regards to changes to the resource"; a State is RECOMMENDED) | current versions | vocabulary and selector semantics only |
| SRC-FTC-16CFR255-0, -255-1, -255-5 | regulation guide | 255.0(b) endorsement definition; 255.1(a) "may not convey any express or implied representation that would be deceptive if made directly by the advertiser"; 255.5(a) material connections and "does not require the complete details" | 88 FR 48102, 2023-07-26 | what a disclosure duty is; not truth of any claim |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "Dr. David Sinclair" (episode), "David A. Sinclair" (affiliations page) | Person | `hu:person:david-a-sinclair` | none ingested (ORCID would be an `Identifier`) | accepted for fixture; production needs an Identifier or a ResolutionHypothesis | same named host page and affiliations page; names alone do not establish identity |
| "InsideTracker" | ConsumerBrand | `hu:brand:insidetracker` | none | accepted | brand named in sponsor read, editorial mention, and disclosure |
| "Segterra" | LegalEntity | `hu:org:segterra` | none | accepted as distinct | appears only as "(Segterra)"; `OWNS_BRAND` kept `PROPOSED` |
| "EdenRoc Sciences companies" | Organization (group) | `hu:org:edenroc-sciences` | none | accepted | role codes printed once for the group |
| "MetroBiotech International ... NAD boosters" | Organization | `hu:org:metrobiotech-international` | none | accepted | "an EdenRoc Sciences company" is an affiliation, not a legal subsidiary assertion |
| "NMN" | ChemicalSubstance | `hu:substance:nicotinamide-mononucleotide` | not ingested (PubChem/UNII are Lane 2/3 identifiers) | accepted for fixture | |
| "scientific lead guy" | role title | none | none | UNRESOLVED role kind | verbatim title kept; not normalized to ADVISES or EMPLOYED_BY |
| "a gram" (spermidine, Lifespan #4) | quantity with unstated basis | literal | none | basis UNSPECIFIED | publisher says active ingredient is 1 to 2 mg |

## Builder proposal

- Proposed terms: `ClaimOccurrence` and `RelationshipAssertion` as labeled specializations of `Assertion`; `Claim` as proposition identity; `DocumentTextVersion` between `SourceSnapshot` and `SourceLocator`; `Episode` as a work with renditions; `Activity`; `ClaimEvidenceAssessment`, `RetellingFidelityAssessment`, `ConflictRelevanceAssessment`, `EquivalenceAssessment`; properties `assertionBasis`, `speechAct`, `reportedSpeechAct`, typed locator selector fields, `captureCompleteness`, `contentHashBasis`, `normalizationVersion`.
- Proposed properties and owners: see `property-cards.md` (Lane 4 fragment).
- Proposed relationships, domain/range, and relationship class: see `catalog-patch.yaml`. New structural: `OCCURS_IN`, `RENDITION_OF`, `TEXT_OF_SNAPSHOT`, `LOCATOR_IN_TEXT_VERSION`, `REANCHORS`, `QUALIFIED_BY`, `RETELLS`, `ATTRIBUTES_TO`, `WAS_GENERATED_BY`, `USED`, `WAS_ASSOCIATED_WITH`, `AUTHORIZED_BY`, assessment edges. New derived: `RESOLVES_TO_CHUNK`, `INSTANCE_OF`. New asserted predicates: `SPONSORS_CONTENT`, `INVESTED_IN`, `HOLDS_EQUITY_IN`, `BOARD_MEMBER_OF`, `FOUNDED_ORGANIZATION`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM`, notice predicates.
- Identity rule: one `Assertion` per (asserter, container, act of asserting). A proposition repeated by another asserter is another Assertion; the shared proposition is a `Claim`.
- State/version rule: a page capture is a `SourceSnapshot`; each text rendering of a capture is a `DocumentTextVersion`; segmentation output (`Chunk`) is regenerable.
- Valid-time rule: role assertions carry the source's bounds with `validTimePrecision` and `validTimeBasis`; a sponsorship read's valid time is the content's publication (basis `PUBLICATION_PROXY`).
- Recorded-time rule: `Assertion.recordedAt`; asserted edges carry `recordedFrom`/`recordedTo`.
- Unknown-time rule: null bounds stay null; "present" on a page observed at T is `validTo = null`, and says nothing about after T.
- Provenance rule: every answered assertion resolves through the five states in section "Five provenance states".
- Projection consequence: additive GraphQL delta in `live-schema-decisions.md`; no live field renamed.

## The nine decisions, with dialogue

### D1. Document pipeline versus Source chain (closes OPEN-QUESTIONS P0-5)

**Builder:** Map live `Document` to catalog `Source` (a rendition endpoint with one `canonicalUri`), `DocumentTextVersion` to a text rendering of one `SourceSnapshot`, and let the `SourceLocator` point into a text version. `Segmentation` and `Chunk` stay as retrieval machinery.

**Challenger:** Why not let `Chunk` be the locator? It already has text, an index, and `SUPPORTED_BY` edges from `Claim` and `ClaimOccurrence`.

**Builder:** Failing case: segmentation v1 (chunkSize 512, overlap 64) puts the NMN sentence in chunk 17; re-segmenting with 1024/128 produces a chunk 17 with different text. If the chunk were the locator, every assertion supported by "chunk 17" now points at different words, and nothing records the change. A locator must survive re-chunking. So the locator is its own node; the chunk is reached by a derived `RESOLVES_TO_CHUNK` edge that names `segmentationHash` and a derivation rule, and is regenerated when segmentation changes. The live `SUPPORTED_BY` edge to `Chunk` stays as a derived shortcut that must carry `locatorUid` (V-407).

**Challenger:** Why is `DocumentTextVersion` not just the snapshot?

**Builder:** Failing case: one PDF capture parsed by two extractors yields two texts whose character offsets differ. A `TEXT_POSITION` locator with offsets 1200 to 1260 is meaningful only for the text version it was counted in. Web Annotation says position selectors are "very brittle with regards to changes to the resource" and recommends a State; our State is the snapshot plus the text version. So: snapshot = capture (bytes or stored text, `retrievedAt`, `contentHash`), text version = derived rendering, exactly one `TEXT_OF_SNAPSHOT` (V-405), offsets require `LOCATOR_IN_TEXT_VERSION` (V-403, V-404).

**Challenger:** The page under review will change. Show me a mutable-page failure.

**Builder:** The Huberman Lab transcript page states it is under human review. The stored text has "My 82 -year-old father" with a stray space. A reviewed version that writes "82-year-old" breaks exact matching. Minimum reproducible locator, therefore:

1. bound to exactly one `SourceSnapshot` that has `contentHash`, `contentHashBasis` and `retrievedAt` (a hash without its input named is not reproducible; our capture hashes stored excerpt text, not bytes);
2. `selectorKind`;
3. for any text-bearing kind: `exact`, `quoteHash`, `normalizationVersion` (NFC-WS1 is defined in the catalog patch), and `prefix`/`suffix` when available (Web Annotation TextQuoteSelector);
4. `TEXT_POSITION` adds `startOffset`/`endOffset` and the text version;
5. `MEDIA_TIME` adds `mediaStartSeconds`/`mediaEndSeconds` on the rendition's own timeline, plus the spoken quote as anchor;
6. `PDF_PAGE` adds `page`; `IMAGE_REGION` points at a `MediaAnnotation`.

When a later snapshot of the same Source is captured, re-anchoring creates a new locator on the new snapshot and `REANCHORS` (with `anchorMatch` EXACT or FUZZY) to the old one. Failure to re-anchor leaves no new locator; it does not delete the old one, and it does not mean the passage was removed (that would be a correction assertion).

**Challenger:** Media time offsets are portable across platforms, so a timestamp is enough.

**Builder:** No. Apple Podcasts shows a "megaphone.fm/adchoices" notice for episode 52, so the audio feed uses dynamic ad insertion; offsets in the audio rendition are not offsets in the YouTube rendition. The Lifespan #4 correction locates its target by "time point 1:07:37" only; the YouTube transcript has a spermidine "about a gram" cue at [1:08:12] (our extract has gaps, so another mention near 1:07:37 may exist). A time-only locator cannot tell which utterance it targets. Hence `MEDIA_TIME` requires the rendition snapshot and a quote anchor (V-401).

Decision D1: `Document` kept (maps to `Source`), `DocumentTextVersion` kept (new required edge `TEXT_OF_SNAPSHOT`), `Segmentation` kept as operational, `Chunk` kept as derived retrieval unit and never a locator, `SourceLocator` gains typed fields (KCR-4.1). `MediaAnnotation` can implement an `IMAGE_REGION` locator because, unlike a chunk, it is an intentional, stable selection. `MediaSource` is a seam: its page, figure label and timestamp fields project to a `SourceLocator`.

### D2. Claim and ClaimOccurrence versus Assertion and Adjudication

**Builder:** `ClaimOccurrence` is a source-attributed `Assertion` instance: it carries both labels, `(:Assertion:ClaimOccurrence)`. `Claim` is the proposition identity that assertions instantiate (`INSTANCE_OF`, derived from a resolution rule or an accepted `ResolutionHypothesis`). `Claim.evidenceStrength` moves to `ClaimEvidenceAssessment`. Where the names must merge, the kernel name `Assertion` is the contract name and `ClaimOccurrence` survives as the specialization label; `UTTERED_BY` is the live name for kernel `ASSERTED_BY`.

**Challenger:** Two speakers say "NMN raises NAD". One Assertion with two `ASSERTED_BY` edges is simpler.

**Builder:** Failing case: a newsletter repeats the episode's claim. If both become one Assertion with two asserters and two locators, a query counting supporting locators returns 2 and presents an echo as corroboration. Separate Assertions sharing one `Claim` keep the count honest (CQ-CL-06, Lane 1 CQ-AX-05). Rule: `ASSERTED_BY` at most one per Assertion, exactly one for `ClaimOccurrence` (KCR-4.3, V-410). This narrows architecture section 2's "supported by multiple sources": a single Assertion may hold several locators only within renditions of its own container; cross-source support is expressed by several Assertions on one Claim, or by an Adjudication citing several locators.

**Challenger:** What does `status: ACCEPTED` on the NMN occurrence mean? A reader will take it as "true".

**Builder:** It must mean "accepted as an accurate record of what Sinclair said in this episode". Failing case: a transcription error ("a gram" for "half a gram") is a capture-fidelity problem; a false proposition accurately transcribed is a truth problem. They need different review records. `Assertion.status` is capture and attribution fidelity; `Adjudication.verdict` is truth or support (KCR-4.6, INV-406).

**Builder:** Corrections of speech (aligns with Lane 5 round 0007 `SUPERSEDES {supersessionKind}`). Two different things can be corrected, and they need different deltas. (a) The transcript was wrong (the reviewed page now reads "half a gram"): the capture was wrong, so the old occurrence is superseded with `SOURCE_CORRECTION` and a new occurrence from the reviewed snapshot replaces it. (b) The speaker said it and the publisher corrects the content (Lifespan #4: "Dr. Sinclair says he takes 1 gram of Spermidine, but the active ingredient in the capsules is 1-2 milligrams"): the occurrence stays a true record of what was said and is not superseded; the notice is a new Assertion asserted by the publisher (`quantityBasis` ACTIVE_INGREDIENT), linked by `CORRECTS_SOURCE` from the notice and instantiating the same Claim. Applying (a) to case (b) would erase the fact that the statement was made; applying (b) to case (a) would keep a mis-transcription as speech.

**Challenger:** Polarity: the live `Claim.claimPolarity` and the starter-model `Assertion.polarity` collide.

**Builder:** Minimal pair: "NR raises NAD" affirmed versus "NR does not raise NAD" is one Claim with two Assertions of opposite `polarity`; "NR lowers NAD" is a different Claim (`claimPolarity` NEGATIVE, direction inside the proposition). Different graph deltas, so both fields stay with those two meanings. `isClinical` and `isPreclinical` describe evidence setting, not the proposition; deferred to Lane 2 round 0003.

### D3. RelationshipAssertion

**Builder:** Keep `RelationshipAssertion` as the live label for structured, non-utterance source assertions (table cell, registry field, figure) under the full Assertion contract: one subject, one object, controlled predicate, `SUPPORTED_BY` a locator. Retire its overlaps: the `MediaSubject` list range (`subject`, `object` are lists), the single `confidence` float, and `SUPPORTED_BY_CLAIM`.

**Challenger:** Why not merge it into `ClaimOccurrence` entirely?

**Builder:** Failing case: a ClinicalTrials.gov results table row has no speaker and no utterance; forcing it into `ClaimOccurrence` would require a fake speaker. Conversely, failing case for keeping both forms of one utterance: an extractor writes the NMN sentence as a `ClaimOccurrence` and also as a `RelationshipAssertion (NMN)-[INCREASES]->(NAD)` from the same span; counting supports yields two. So a structured form derived from an utterance is written as subject/predicate/object on the `ClaimOccurrence` itself, not as a second node (V-419). Live instances with several subjects or objects split into one Assertion per proposition (V-420). Live instances that synthesize across many claims (no single span) are not assertions at all; they are BellLabs conclusions and migrate to `ClaimEvidenceAssessment` on the corresponding `Claim`. This answers starter-property-model item 5: keep as a general construct, retire the media-specific and synthesis overlap.

### D4. Speaker attribution and claim basis

**Builder:** Attribution is `ASSERTED_BY` plus `OCCURS_IN` plus a locator; appearance role is `APPEARS_IN.roleType` with new values HOST, CO_HOST, GUEST. The seed question's "claim kind" is `assertionBasis` on the occurrence (PERSONAL_EXPERIENCE, THIRD_PARTY_ANECDOTE, MANUFACTURER_CLAIM, STUDY_RESULT, MECHANISM_REASONING, EXPERT_OPINION, UNSTATED), plus `speechAct` (STATES, REPORTS_PRACTICE, RECOMMENDS, CAUTIONS, SPECULATES, QUESTIONS, DENIES). Live `ClaimType` stays on `Claim` and answers "what the proposition is about".

**Challenger:** `ClaimType` already has MECHANISTIC_CLAIM and COMMERCIAL_CLAIM. You are inventing a parallel vocabulary.

**Builder:** Minimal pair: "NMN raises NAD+" (a mechanistic proposition, ClaimType MECHANISTIC_CLAIM) versus "NMN should help you age better because it raises NAD" (an efficacy proposition, ClaimType EFFICACY_CLAIM, basis MECHANISM_REASONING). Second pair: a founder says "our product improves sleep" versus a host says "the company says it improves sleep": both EFFICACY_CLAIM; basis UNSTATED with an asserter who holds a role, versus MANUFACTURER_CLAIM relayed by a host. One field cannot carry both axes without losing one. The asserter's affiliation is never encoded in the basis; it is computed from time-bounded role assertions.

**Challenger:** Real case: in episode 52 the host says "So it's a gram of resveratrol and a gram of NMN" and the guest says "Right." Who asserted the resveratrol amount?

**Builder:** The guest, by assent; the locator spans both turns and `speakerLabelInSource` records the turn labels. The fixture records only the guest's own NMN sentence. This case is listed as an extraction-guideline item, not a schema change.

Real populatability test (episode 52): span, speaker label, container, rendition, claim basis and speech act were all populated from public text. The episode's publication time came from a third source (Apple Podcasts). What could not be populated: raw-byte content hashes (captures are partial excerpts), the order of the disclosure and the mention within the episode (chapter list suggests both lie after 01:12:04, not verified), and media offsets for the transcript-page spans (the page has none).

### D5. Retelling drift

**Builder:** A retelling is a distinct Assertion (own asserter, own container, own locator) linked `RETELLS` to the original, with `retellingMode` (VERBATIM_QUOTE, PARAPHRASE, SUMMARY, TRANSLATION) and `linkBasis` (EXPLICIT_CITATION with `citationLocatorUid`, or BELLLABS_MATCH with `hypothesisUid`). `ATTRIBUTES_TO` records whom the retelling credits. Qualifications are separate occurrences linked by `QUALIFIED_BY {qualificationKind}`. Loss is recorded on a `RetellingFidelityAssessment` (flags and `lostQualificationKinds`, `speechActFrom`/`To`, `scopeBroadened`, `correctionIgnored`) with `IDENTIFIES_LOST_QUALIFICATION` pointing at the dropped qualifier.

**Challenger:** Put `qualificationLost: true` on the retelling. One fewer node.

**Builder:** Failing case: the same retelling is compared with two candidate originals (episode 52 and Lifespan #4 both contain the 1 g statement; Lifespan #4 has its own qualifier "Now, you're not most people."). Loss is a property of a comparison, not of the retelling; a flag on the retelling cannot say which original lost what. V-414 rejects the flag on assertions.

**Challenger:** Why is the qualification a separate occurrence rather than a property of the NMN assertion?

**Builder:** In episode 52 the qualifier "I'm not the same as everybody else. I have different microbiome, age, sex." comes two turns after the dosage sentence, with its own span. A property on the NMN assertion would lose its locator, so a reviewer could not check it.

**Challenger:** The real retelling on NMN.com says "Dr. Sinclair takes 1 gram of ... NMN". Use it in the fixture.

**Builder:** It cites no span in the extracted text, and the full article was not read, so neither its source episode nor its omission of a qualifier is verified. The fixture uses a SYNTHETIC retelling ("Harvard geneticist David Sinclair recommends taking a gram of NMN every morning to slow aging.", fictional outlet on an `.invalid` domain). The real article shows why `BELLLABS_MATCH` must exist: real retellings often cite nothing.

FTC 16 CFR 255.0 Example 1 supports the distinction from another direction: an excerpt that "does not fairly reflect its substance" distorts the endorser's opinion. A retelling that changes substance is a different statement and must not inherit the original's attribution as if verbatim.

### D6. Financial relationships

**Builder:** Financial relationships are typed, time-bounded asserted predicates in one family `FINANCIAL_INTEREST`: `SPONSORS_CONTENT`, `AFFILIATE_FOR_OFFER`, `INVESTED_IN`, `HOLDS_EQUITY_IN`, `BOARD_MEMBER_OF`, `ADVISES_ORGANIZATION`, `EMPLOYED_BY`, `FOUNDED_ORGANIZATION`, `HAS_IP_INTEREST_IN`, `RECEIVES_COMPENSATION_FROM`. Relevance to a specific occurrence is a `ConflictRelevanceAssessment` (`relevanceLevel`, `relevanceBasis`, `temporalOverlap`, `disclosureFinding`). Disclosure is a fact about content (an occurrence in which the relationship is stated), not a property of the relationship.

**Challenger:** One generic `HAS_FINANCIAL_RELATIONSHIP {kind}` is enough.

**Builder:** The self-disclosure page codes Investor (I) and Equity (E) separately and gives InsideTracker "I" but not "E"; a generic kind invites collapsing them, and queries need exact filters. Typed predicates with a family name give both. Failing case for collapse: projecting "investor" to equity overstates the tie.

**Challenger:** "B (2011-2017) I,A,IP (2011-present)". Store one role edge with validFrom 2011.

**Builder:** Four assertions with different bounds: board 2011 to 2017 (closed), investor, advisor and IP interest from 2011 with null end as of observation 2026-10-03. Year precision: the fixture stores the widest half-open interval consistent with the source (validFrom 2011-01-01, validTo 2018-01-01, `validTimePrecision` YEAR), pending Lane 5's precision rule. Failing case: answering "was he a board member when episode 52 aired (2021-12-27)?" with "yes" from an open-ended edge.

**Challenger:** Three sources disagree on the role. The guest says "board member" and "still their scientific lead guy"; the self-disclosure page says B 2011 to 2017 and I, A, IP; InsideTracker's team page lists him under the Scientific Advisory Board. And for Elysium Health, the self-disclosure page says "(2018) IP" while Catalio's profile lists "Scientific Advisory Board: ... Elysium Health".

**Builder:** Each source is its own Assertion with `roleTitleVerbatim` or `roleCodeVerbatim`. "Scientific lead guy" stays `AFFILIATED_WITH` with the verbatim title; it is not normalized to ADVISES or EMPLOYED_BY by guesswork. The Elysium conflict is preserved as two assertions and is a reviewer item.

**Challenger:** "EdenRoc Sciences companies F,I,E,A,B, IP", followed by "MetroBiotech International, an EdenRoc Sciences company, NAD boosters (2015-present)". So Sinclair holds equity in MetroBiotech, and MetroBiotech makes NAD boosters, so his NMN statement is conflicted.

**Builder:** The codes are printed once for the group. Whether each code applies to each member company is a scope ambiguity. The equity assertion targets the group, the membership is a separate `AFFILIATED_WITH` assertion, and the relevance assessment is INDIRECT with basis SAME_SUBSTANCE_CLASS_VIA_GROUP and `scopeAmbiguity` recorded. V-434 rejects a person-to-member-company equity edge without an assertion naming that company.

**Challenger:** Which relationship is relevant to which statement in episode 52?

**Builder:** Fixture answer: the guest's InsideTracker roles and the host's InsideTracker sponsor read are DIRECT for the guest's editorial mention "InsideTracker is one of them" (same organization; disclosed in the container: the guest said "I was one of the first people in InsideTracker as a board member and I'm still their scientific lead guy"). The InsideTracker sponsorship is NOT_RELEVANT to the NMN statement (no path). The EdenRoc/MetroBiotech ties are INDIRECT for the NMN statement, `disclosureFinding` NOT_FOUND_IN_PARTIAL_CAPTURE, never NOT_DISCLOSED from a partial capture (V-426).

**Forbidden implications (source: FTC 16 CFR 255.1(a) and 255.5(a)).** 255.1(a) says an endorsement "may not convey any express or implied representation that would be deceptive if made directly by the advertiser", so substantiation is independent of disclosure. 255.5(a) says a disclosure "does not require the complete details of the connection". Therefore: a disclosed sponsorship does not make a claim false; an undisclosed or unfound one does not make it true; a coarse disclosure is a valid assertion with a verbatim role. Failing case: an agent writes `Adjudication {verdict: CONTRADICTED}` on the NMN occurrence citing only the sponsor-read locator (V-424). Also: `SPONSORS_CONTENT` does not imply `ENDORSES_PRODUCT` by the guest; mentioning a product or reporting one's own practice does not imply endorsement or recommendation (V-422, V-423).

### D7. Five provenance states and PROV-O

| State | Graph form | Record that answers it | PROV-O alignment |
|---|---|---|---|
| 1. Someone said it | `(:Assertion)-[:ASSERTED_BY]->(Person/Org/Agent/Pseudonymous/Anonymous)`, `OCCURS_IN` container, `status` = capture fidelity | Assertion (ClaimOccurrence) | Assertion is `prov:Entity`; `ASSERTED_BY` = `prov:wasAttributedTo` |
| 2. A source supports that it was said | `SUPPORTED_BY` -> `SourceLocator` <- `HAS_LOCATOR` `SourceSnapshot` <- `HAS_SNAPSHOT` `Source` (`RENDITION_OF` work) | SourceLocator with typed selector | Snapshot `prov:specializationOf` Source; Assertion `prov:wasDerivedFrom` snapshot (`prov:wasQuotedFrom` when verbatim); later snapshots `prov:wasRevisionOf` earlier; locator aligns to `oa:SpecificResource` with selector and TimeState |
| 3. Evidence warrants a broader conclusion | `ClaimEvidenceAssessment` on `Claim`; `EvidenceApplicability`; `Adjudication` `EVALUATES` Assertion | EvidenceAssessment with `methodVersion` | assessment `prov:Entity` `prov:wasGeneratedBy` an ADJUDICATION Activity whose method is a `prov:Plan` |
| 4. An agent used the source | `(Activity)-[:USED]->(SourceSnapshot/SourceLocator/Assertion)`, `WAS_ASSOCIATED_WITH` Agent, outputs `WAS_GENERATED_BY` Activity | Activity usage record | `prov:used`, `prov:wasGeneratedBy`, `prov:wasAssociatedWith`, `prov:actedOnBehalfOf` |
| 5. A policy allows a downstream use | `(Activity)-[:AUTHORIZED_BY {useKind}]->(PolicyVersion)` | PolicyVersion (Lane 5) | `prov:Plan` via qualified association; PROV-O has no permission vocabulary, so the permission semantics are BellLabs-defined (ODRL not researched in this round) |

Failing case for collapsing states 1 and 3: the NMN occurrence is ACCEPTED (state 1 true) while no assessment says NMN at 1 g/day does anything (state 3 absent). An answer that cites the occurrence as "supported" conflates them. Failing case for 4 versus 5: an answer-composition activity quotes a transcript page whose terms forbid reuse; the use record exists, the permission does not (V-429). Nanopublication guidelines give the same separation (assertion graph, provenance graph "MUST contain a link to the assertion graph", publication info); Biolink's `primary_knowledge_source` versus `aggregator_knowledge_source` maps to "has no outgoing RETELLS" versus "is a retelling source".

### D8. Ecosystem neighbourhoods (CQ-EC)

**Builder:** A neighbourhood is a time-filtered traversal over accepted asserted role predicates (FINANCIAL_INTEREST members, `SPONSORS_STUDY`, `FUNDS_STUDY`, `SUPPLIES_INGREDIENT_MATERIAL`, `ASSIGNED_PATENT`, `AFFILIATED_WITH`, `OWNS_BRAND`), never over name similarity. "Similar work under different names" is an `EquivalenceAssessment` (`SAME_WORK_DIFFERENT_NAME`, `OVERLAPPING_SCOPE`, `RELATED_NOT_EQUIVALENT`, `NOT_EQUIVALENT`) comparing exactly two distinct nodes; identity claims remain `ResolutionHypothesis`.

**Challenger:** "InsideTracker (Segterra)" is plainly the same company. Merge.

**Builder:** A consumer brand and a legal entity are different kinds; the parenthetical supports at most a `PROPOSED` `OWNS_BRAND`. V-433 rejects a node carrying both labels. Second failing case (PubMed): the ALS mouse study PMID 38241160 lists an author affiliated with "Elysium Health Inc."; a neighbourhood built from affiliations would add Elysium as a study sponsor. Author affiliation is not `FUNDS_STUDY` or `SPONSORS_STUDY`; those need their own assertions (forbidden implication `[AUTHOR_AFFILIATED_WITH, FUNDS_STUDY]`).

### D9. `mongoResearchRunId` and `ExtractionMetadata`

**Builder:** `mongoResearchRunId` is a single-valued "last writer" pointer. It stays as an operational projection; authoritative lineage is `WAS_GENERATED_BY` an `Activity {externalRunSystem: 'mongo-research', externalRunId}`. Failing case: a node created by run r1 and edited by run r2 shows only r2; a correction of r1's extraction cannot find its outputs. `ExtractionMetadata` splits by lifecycle:

| Field | Goes to | Confidence-vector dimension |
|---|---|---|
| `quoteSpan` | `SourceLocator.exact` (+ `quoteHash`, `normalizationVersion`) | none; it is evidence content |
| `extractionMethod`, `extractorVersion`, `extractedAt` | `Activity.methodVersion`, `Agent.toolVersion`, `Activity.endedAt` | lineage for `extractionConfidence` |
| `supportType` | relationship type (`SUPPORTED_BY` versus `CONTRADICTED_BY`) | none |
| `salience`, `aboutness` | kept on derived `MENTIONS`/`ABOUT` retrieval edges | none; retrieval ranking features, never confidence |
| `mongoResearchRunId` | `Activity.externalRunId` | lineage |
| (missing) extraction confidence | `Assertion.extractionConfidence` with required `WAS_GENERATED_BY` (V-428) | extraction |

`RoleMetadata.confidence` and `RelationshipAssertion.confidence` are deprecated for the same reason: a number without a method is not one of the seven dimensions.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| O-1 | Operational | Re-segmentation changes chunk text under an existing `SUPPORTED_BY` | High | V-406, V-407, V-408 | Chunk is derived; locator independent |
| O-2 | Operational | Two extractors, one capture, different offsets | High | V-403, V-404 | `DocumentTextVersion` with `TEXT_OF_SNAPSHOT` |
| O-3 | Temporal | Transcript page under review changes "82 -year-old" | Medium | re-anchor with FUZZY match; `REANCHORS` | typed TextQuote fields plus snapshot binding |
| O-4 | Operational | Audio offsets shift with dynamic ad insertion | High | V-401 MEDIA_TIME requires quote anchor and rendition snapshot | accepted |
| O-5 | Epistemic | Echo counted as corroboration | High | V-410, V-411 | one asserter per Assertion; Claim gathers |
| O-6 | Epistemic | ACCEPTED read as true | High | review of answer templates; INV-406 | KCR-4.6 |
| O-7 | Linguistic | Practice report retold as recommendation | High | V-423; fidelity assessment `speechActChanged` | accepted |
| O-8 | Linguistic | Group-level role codes pushed to member company | Medium | V-434 | accepted |
| O-9 | Epistemic | Sponsorship used as falsity, or no conflict as truth | High | V-424 | INV-405 |
| O-10 | Epistemic | "Not disclosed" concluded from a partial capture | Medium | V-426 | `disclosureFinding` states |
| O-11 | Ontological | Brand and legal entity merged | Medium | V-433 | `OWNS_BRAND` PROPOSED |
| O-12 | Ontological | n-ary utterance ("we take a gram of NMN every day") versus INV-003 (one subject, one object or literal) | Medium | fixture A1 | subject = substance, literal = amount, asserter = reporter, predicate `SELF_REPORTED_DAILY_INTAKE`; the unnamed father is not modeled (private individual) |
| O-13 | Temporal | Correction notice read as fact ending, or a content correction applied as a transcript correction (Lifespan #4) | High | minimal pair: transcript revised versus publisher corrects content | transcript error: `SUPERSEDES {SOURCE_CORRECTION}` (Lane 5); content correction: new publisher Assertion, original occurrence kept |
| O-14 | Linguistic | Host phrasing assented by guest ("Right.") | Low | extraction guideline | locator spans both turns |

## Linguistic analysis

- Source wording: "Well, I'm always happy to tell you what I do and what my father does. My 82 -year-old father, we take a gram of NMN every day." ... "Now another important point, which is I'm not the same as everybody else. I have different microbiome, age, sex."
- Normalized proposition: the speaker reports that he (and his father) take about 1 g of NMN per day.
- Negation: none.
- Modality/hedging: none in the sentence; the hedge is a separate utterance (INDIVIDUAL_VARIATION).
- Quantification: "a gram" with no stated basis (salt, free base, product mass); `quantityBasis` UNSPECIFIED.
- Scope ambiguity: "we" includes an unnamed private individual; not modeled.
- Presuppositions not licensed as facts: that NMN at this amount has any effect; that the speaker recommends it; that the amount refers to the active substance.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | 0.95 on the two fixture utterances | lane4-manual-curation-v0.1 | verbatim excerpt, partial capture | none |
| Resolution | person and brand accepted for fixture; Segterra brand ownership PROPOSED | manual | names across three sources | none |
| Source reliability | not assessed | none | publisher transcript under review | none |
| Evidence strength | not assessed (no ClaimEvidenceAssessment written) | none | none | none |
| Applicability | not applicable (no use target) | none | none | none |
| Adjudication | none written; intentionally absent | none | none | none |
| Decision | not applicable | none | none | none |

## Schema projection

- Projection request ID: none issued (no projection service in this environment).
- Selected modules: kernel, provenance, identity_resolution, organizations, claims_and_documents.
- Closure additions: `Activity`, `Agent`, `PolicyVersion` (reference only), `ResolutionHypothesis`.
- Explicit exclusions: Lane 5 private context; Lane 2 study internals.
- Budget result: not run.
- Projection ID/digest: not computed.

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/claim-retelling-provenance.cypher` sections 1 to 8 | loads | statically checked (Neo4j Cypher language-support parser: 77 statements, 0 syntax errors; per-statement binding check: 0 unbound write variables); not executed | static only |
| Negative fixture | fixture section 10 queries F-401 to F-412 | zero rows on fixture; rows when defect reintroduced | read against the fixture by hand; not executed | static only |
| Minimal pair | practice report versus recommendation; group versus member role; investor versus equity; sponsorship relevant versus not relevant | different deltas | encoded in fixture | yes (static) |
| Temporal correction | Lifespan #4 correction | new assertion, original kept | described; fixture deferred to Lane 5 round 0007 | deferred |
| Identity collision | InsideTracker / Segterra | two nodes | encoded; F-410 | yes (static) |
| Extraction evaluation | none | | not run | no |
| Retrieval evaluation | none | | not run | no |
| Migration compatibility | additive GraphQL delta parsed with graphql-js 17 against the live schema (no type or field collisions) | additive | 45 definitions, 0 problems | yes (parse only) |

## Kernel-change requests

| ID | Change | Failing case that forces it |
|---|---|---|
| KCR-4.1 | `SourceLocator.selector` (untyped) replaced by typed fields and `requiredBySelectorKind` | P0-5: mutable transcript page; ad-inserted audio offsets |
| KCR-4.2 | `Assertion` optional `assertionBasis`, `speechAct`, `reportedSpeechAct`, `quantityBasis`, `extractionConfidence`; deprecate `confidence` | practice report versus recommendation; a confidence without a method |
| KCR-4.3 | `ASSERTED_BY` range adds `PseudonymousActor`, `AnonymousActor`; at most one asserter per Assertion | echo counted as corroboration; handle-only speakers |
| KCR-4.4 | `Activity` node and `USED`, `WAS_GENERATED_BY`, `WAS_ASSOCIATED_WITH`, `AUTHORIZED_BY`; `Agent.runUid` moves to `Activity` | single-valued `mongoResearchRunId` loses r1 after r2 edits |
| KCR-4.5 | `SUPPORTED_BY` from an Assertion to a `Chunk` is a derived variant that must name `locatorUid` | re-segmentation |
| KCR-4.6 | `assertionStatus` meaning stated as capture fidelity, never truth | ACCEPTED read as true |

## Decision

- Outcome: recommended `REVISED` (accept the rules; coordinator to rule on KCR-4.1 to KCR-4.6).
- Accepted semantic rule:
  1. `Document` = Source rendition; `DocumentTextVersion` derives from exactly one snapshot; `SourceLocator` points into a snapshot and, for offsets, a text version; `Chunk` is derived and never a locator.
  2. `ClaimOccurrence` and `RelationshipAssertion` are Assertions; `Claim` is proposition identity; evidence strength is an assessment; status is capture fidelity.
  3. One asserter and one container per occurrence; corroboration is counted across Assertions on one Claim.
  4. Claim basis and speech act are occurrence properties; `ClaimType` stays on `Claim`.
  5. Retellings are distinct Assertions linked by `RETELLS`; qualification loss lives on `RetellingFidelityAssessment`.
  6. Financial relationships are typed, time-bounded asserted predicates; relevance and disclosure are assessments; neither sets a truth verdict.
  7. Every answered assertion carries the five provenance states with the PROV-O alignment above.
  8. Neighbourhoods traverse asserted roles only; similar-work links are `EquivalenceAssessment`.
  9. `mongoResearchRunId` is a projection of `Activity.externalRunId`.
- Rejected alternatives: Chunk as locator; one Assertion per proposition across asserters; generic `HAS_FINANCIAL_RELATIONSHIP {kind}`; qualification-loss flag on the retelling; merging `RelationshipAssertion` into `ClaimOccurrence` wholesale; using `ClaimType` for claim basis.
- Residual uncertainty: year-precision interval encoding (Lane 5); `PolicyVersion` permission vocabulary (ODRL not researched); uid token for runs (`activity` versus Lane 1 `agent-run`); whether `@node(labels: [...])` should add `Assertion` to the live `ClaimOccurrence` GraphQL type (coordinator); FTC applicability to editorial guest statements is a legal question outside the graph.
- Required catalog/schema changes: `catalog-patch.yaml` (Lane 4 fragment); additive GraphQL delta in `live-schema-decisions.md`.
- Required ingestion changes: write `SourceSnapshot` with `contentHashBasis` and `captureCompleteness`; write locators with NFC-WS1 `quoteHash`; write one Assertion per asserter; write `Activity` per run; stop writing `Claim.evidenceStrength`.
- Required retrieval/API/MCP changes: answers show `assertionBasis`, `speechAct`, qualifiers, relevant financial ties with `disclosureFinding`, and the five states; never show `status: ACCEPTED` as "verified".
- Changelog and migration references: migration notes in `live-schema-decisions.md`; validation V-401 to V-434 in the Lane 4 `validation.cypher` fragment.
