# W21 decision and seam ledger

Status values: ACCEPTED-FOR-PROPOSAL (W21 recommends; Fable rules), UNRESOLVED (needs another owner), KERNEL-REQUEST (to W00). No consensus is claimed from other workers; none of them had published W21-relevant packets when this ledger was written (only `workers/W02/` existed at start).

## Decisions

| Id | Decision | Evidence (locator / fixture) | Alternatives and why rejected | Status |
|---|---|---|---|---|
| W21-D01 | Episode is the work; page, video, directory record, transcript PDF and webcast are `Source` renditions; one act of saying = one ClaimOccurrence with locators in several renditions | SRC-W21-01/02: same NMN sentence, different wording per rendition; fx01 Q01-2 (3 renditions: TEXT_QUOTE, MEDIA_TIME 3765 s, none) | one occurrence per rendition (doubles counts; V-410 cannot see the duplication) | ACCEPTED-FOR-PROPOSAL |
| W21-D02 | Rendition-specific segments: `EpisodeSegment` + `IN_RENDITION` + `DELIMITED_BY` | SRC-W21-02 "[3:30] ROKA, InsideTracker, Magic Spoon" vs SRC-W21-03 "00:03:45 Sponsors: AG1, LMNT & Waking Up" (both observed 2026-10-04); fx01 Q01-1; V-W21-05 | timing on segment properties or on OCCURS_IN_SEGMENT (not snapshot-bound); one segment per work (claims AG1 for the video) | ACCEPTED-FOR-PROPOSAL (new relationship types need registry admission W21-SR-03/04) |
| W21-D03 | Directory record = rendition; feed document = Source but not a rendition; dynamic sponsorships valid-from OBSERVATION_ONLY | SRC-W21-03, SRC-W21-04 (feed lists two works); fx01 Q01-3 | feed as rendition (one feed renders hundreds of works); back-projecting AG1 to 2021 (no evidence) | ACCEPTED-FOR-PROPOSAL |
| W21-D04 | ExperienceReport folded into ClaimOccurrence (PERSONAL_EXPERIENCE) | live lines 2802-2817: no asserter cardinality, no container, no locator; catalog alignment row | keep as separate type (duplicate record of one act of saying) | ACCEPTED-FOR-PROPOSAL |
| W21-D05 | `OCCURS_IN` range adds `Publication` | failing case: the same author sentence in the HTML and PDF renditions of one article; with Document-only containers two occurrences arise and CQ-CL-06 counts two | keep Episode/Document only (double counting); make Publication a Document (violates D-005) | ACCEPTED-FOR-PROPOSAL; catalog range change via ledger (W21-SR-06); W09 informed |
| W21-D06 | No Presentation/Talk node: recorded talk = Episode (CONFERENCE_TALK); deck = Document container, never a rendition | SRC-W21-06..09 (Merck JPM 2026): deck slide 11 asserted by Merck; CEO's spoken "$70 billion" asserted by Robert Davis; recording withdrawn; fx06 Q06-1..4; V-W21-03; neg N06-a/b | new `Presentation` type (no failing case: every fx06 query answered); deck as rendition (spoken occurrence could cite slide text, fx06 N06-b caught by V-411 only when the deck is not a rendition) | ACCEPTED-FOR-PROPOSAL; Event link UNRESOLVED (W21-SR-20) |
| W21-D07 | RECOMMENDS is derived (CL-016) with `DerivedEdgeProperties`; V-423 amended to V-W21-06 | fx07: correct derived edge -> V-423 1 row, V-W21-06 0 rows; fx04 N04-a: edge derived from a retelling -> V-W21-06 1 row; D-011 forbids `assertionUid` on derived edges | asserted-class with `AssertedEdgeProperties` (passes verbatim V-423 but QS-4a flags CITED_PREDICATE_DIFFERS because the licensing occurrence's predicate is e.g. RECOMMENDS_DAILY_INTAKE, not RECOMMENDS) | KERNEL-REQUEST (validator text change) W21-SR-07 |
| W21-D08 | Sponsor read vs independent practice report is separated by segment + ConflictRelevanceAssessment, not by speech act | SRC-W21-02 [5:04] host "I've long been a believer in getting regular blood work done..." inside the InsideTracker read; SRC-W21-01 guest "I've been measuring myself..."; fx03 Q03-1..3; V-W21-02 | a SPONSOR_READ speech act value (mixes axes: a read can contain a practice report, a statement, a recommendation) | ACCEPTED-FOR-PROPOSAL |
| W21-D09 | ClaimOccurrence asserter range excludes Agent; ATTRIBUTES_TO never equals the asserter | V-W21-04; fx05 N05-c | allow Agent (a model output presented as source content) | ACCEPTED-FOR-PROPOSAL |
| W21-D10 | Two speakers in one cue/exchange = two occurrences; a confirmation question is QUESTIONS and never INSTANCE_OF the asserted claim | SRC-W21-01/02 cue [1:02:53]; fx05 Q05-1/2; V-410, V-W21-11 | one occurrence spanning both turns with two asserters (V-410) | ACCEPTED-FOR-PROPOSAL (CL-004 fixture delivered) |
| W21-D11 | Transcript corrections: new snapshot + new text version (TRANSCRIPTION Activity) + new locator REANCHORS old; supersede the occurrence only on substantive mis-transcription | SRC-W21-01 notice "under human review"; quote hash reproduced 2026-10-04; fx02a/b Q02-1..5; V-404, V-409, V-W21-08 | edit locator in place (N02-a: V-404 and V-504 rows) | ACCEPTED-FOR-PROPOSAL |
| W21-D12 | A re-edited release ("Essentials") is a separate Episode; whether its utterances are the same act of asserting is open | SRC-W21-04 (2025-10-30 Essentials item), SRC-W21-05 cites an Essentials video; fx01 Q01-5 | treat as rendition (wrong: different edit, different sponsors, different date) | UNRESOLVED (W21-SR-19, candidate CQ-CL-C04) |
| W21-D13 | Caption discrepancies between renditions are capture-fidelity review items, not truth signals | SRC-W21-01 "or I know if" vs SRC-W21-02 "or I think I know if"; fx03 Q03-4 | silently quoting one rendition | ACCEPTED-FOR-PROPOSAL; routing to W00 CAPTURE_FIDELITY adjudication (W21-SR-21) |
| W21-D14 | MEDIA_TIME only on playable renditions with a stated `mediaTimeBasis`; no invented offsets on transcript pages or documents | fx01 N01-a, fx06 N06-c -> V-W21-01 rows | rely on V-401 (checks presence, not placement) | KERNEL-REQUEST W21-SR-16 (validator) |
| W21-D15 | Inherited fixture `examples/claim-retelling-provenance.cypher` fails two new W21 checks: A6 has `segmentKind` SPONSOR_READ but no SPONSOR_READ segment (V-W21-02), and two ConflictRelevanceAssessments claim DISCLOSED_IN_CONTAINER without a disclosure span (V-W21-09) | executed 2026-10-04 on Neo4j 5.26.31 | relax the validators | ACCEPTED-FOR-PROPOSAL; fixture upgrade requested (W21-SR-17) |

## Conflict noted with the frozen texts (no unilateral change)

- **CL-016 wording vs D-011.** CL-016 says "derived projection with `assertionUid`"; D-011 says derived edges carry `projectionOfAssertionUid`/`derivationRule`+`derivedFromAssertionUids`, never `assertionUid`. V-423 checks `rec.assertionUid`. W21 follows D-011 (contract B7) and asks Fable to amend V-423 (W21-SR-07). Failing case: fx07 (1 row from V-423 on a correct edge).
- **`SPONSORS_CONTENT` missing from `assertedTypes`** in the coordinator's validation parameter file (`validation-params.json`, 68 asserted types). W21 added SPONSORS_CONTENT, OPERATES_CHANNEL, SERVES_ON_CHANNEL locally (`w21-params.json` in scratch) and recommends the same for the shared run (W21-SR-16).

## Seam requests

See `seam-requests.yaml` (W21-SR-01 … W21-SR-25) for target owner, request, CQ, failing case and proposed ruling. Closure criteria per request are in its `proposedRuling`.

## Alignment after reading published peer packets (2026-10-04, same run)

Before finishing, W21 read the fragments and seam requests that other workers had published in this run and aligned where a peer had already decided, without editing any other directory:

| Peer item | W21 response | Change made |
|---|---|---|
| W00 generic `Assertion` conventions (`@mutation` without DELETE, `@settable` immutability, `massBasis`/`amountReferent`, `roleCodeVerbatim`) and W00 seam asking W21 to mirror A11 qualifiers | accepted | ClaimOccurrence and RelationshipAssertion mirror them; all W21 node types omit DELETE; stub build shows no `delete*` mutations for W21 types |
| W00 D-W00-18 (INSTANCE_OF uses `DerivedEdgeProperties`, hypothesis uid in `derivedFromAssessmentUids`) | accepted | `InstanceOfProperties` withdrawn; W21-SR-12 now asks only for the V-417 wording |
| W00 R4 / W19-SR-07 (deck never a rendition; link predicate; Presentation type?) | accepted R4; link = asserted `ACCOMPANIES_TALK`; no Presentation type | SDL field `Episode.accompanyingDocuments`; fx06 Q06-5; W21-SR-22 |
| W19-SR-06 / W00 awaiting W21 on OCCURS_IN Publication | agreed (same as W21-D05) | W21-SR-06 |
| W19-SR-08 multi-author asserter rule | proposed AnonymousActor AUTHOR_GROUP per Publication | W21-SR-24 (UNRESOLVED; W01/W09) |
| W01-SR-21 (SPONSORS_CONTENT may use W01 RoleEdgeProperties with compensationKind; AFFILIATED_WITH only as a hop) | SPONSORS_CONTENT keeps the frozen `AssertedEdgeProperties`: payment terms of a sponsorship are not observed in narrative sources, and compensation is the separate FINANCIAL_INTEREST member RECEIVES_COMPENSATION_FROM; AFFILIATED_WITH as a hop only: agreed | none |
| W01-SR-05 (correct the inherited fixture's year-precision validTo) | agreed; W21 fixtures do not carry the affiliations-page roles | folded into W21-SR-17 scope |
| W02-SR-22 (Material -> IngredientMaterial; Compound -> ChemicalSubstance/IngredientMaterial) | accepted | EpisodeMentionableTarget; RecommendableTarget proposal |
| W03-SR-13 (retire AssociationPolarity; use W00 Polarity) | accepted | `Claim.claimPolarity: Polarity`; W21-SR-11 resolved; migration row |
| W04-SR-10 (add ProductVariant where dose/composition matters) | accepted for RecommendableTarget | W21-SR-18 |
| W05-SR-11 (SELF_REPORTED_PRACTICE; RECOMMENDS range; property name on RECOMMENDS) | (a) accepted, W05 subject form adopted as preferred; (b) accepted; (c) answered by W21-D07 / W21-SR-07 (DerivedEdgeProperties; V-423 amended) | W21-SR-15, W21-SR-18 |
| W06-SR-14 (no timeless recommendation; benefit wording is a ClaimOccurrence) | agreed; RECOMMENDS is only a derived projection of a source's own RECOMMENDS speech act (V-W21-06), never a BellLabs recommendation (INV-508 unaffected) | none |
| W08-SR-10 (QUALIFIED_BY on generic assertions) | accepted with a validator amendment | `RelationshipAssertion.qualifiedBy`; V-W21-12; W21-SR-23 (W00 field) |
| W14-SR-06 (NAMED_INVENTOR for CQ-CL-05) | not needed for CQ-CL-05: relevance uses HAS_IP_INTEREST_IN (FINANCIAL_INTEREST); a named inventor without an IP interest is not a financial tie; defer agreed | none |
| W20-SR-14 (Claim.supportedByChunks read-only; ClaimOccurrence chunk shortcut) | accepted | `Claim.supportedByChunks` |
| W20-SR-15 (remove Episode.hasTranscriptVersions) | accepted (already retired) | none |
| W22-SR-11 (renditions and MediaAssets share bytes only via contentHash and DERIVED_FROM_SOURCE; frames are MediaAssets, never locators; covers depict Series/Channel and imply no sponsorship) | confirmed | none |
| W23-SR-13 (shared record shape for a consented de-identified contribution) | a ClaimOccurrence with assertionBasis PERSONAL_EXPERIENCE, ASSERTED_BY an AnonymousActor (anonymityClass CONSENTED_CONTRIBUTION), OCCURS_IN a contribution Document; any contribution token belongs on that Source/Document (W00/W20), never on the occurrence; no CohortParticipant node | none in W21 SDL; sourceKind value is W00's |

Full-merge check (all published fragments, `merge-fragments.mjs`, 2026-10-04T01:49Z): 471 definitions, 0 duplicates; W21 contributes no duplicate definition and, after the W03 alignment, references no undefined name (`SafetySignal` resolved once W17 published). Remaining undefined names in the merge are other packets' (`Association`, `FoodProduct`, `MediaSource`) plus `ExperienceReport`, which W00 and W22 still list although W21 retires it (W21-SR-25). A full `Neo4jGraphQL` build of the merged file currently fails on other packets' references (`Association`), not on W21 definitions; W21's fragment builds alone with stubs.
