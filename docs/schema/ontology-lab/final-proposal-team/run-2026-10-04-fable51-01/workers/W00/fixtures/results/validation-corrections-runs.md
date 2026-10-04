# Validation corrections: executed row counts

Engine: embedded Neo4j 5.26.31 Community + APOC 5.26.31 (scratch harness `w00-vc-runs.mjs`). For each fixture set the database is emptied,
the listed fixture files are loaded statement by statement, then the frozen originals run with the catalog 0.2.0 parameters (`validation/validation-params.json` as committed in b3636fb) and the
revised validators of `validation-corrections.cypher` run with `fixtures/validation-params-w00.json`. Cells read `original -> revised`;
`- -> n` marks a validator with no frozen original. Only validators with a non-zero count in either column are shown; every other
validator returned 0 rows on that set. No validator raised an error on any set. Raw JSON (all rows sampled): `validation-corrections-runs.json`.

| Set | Fixture files | Load (ok/err) | Non-zero validators |
|---|---|---|---|
| W00-F01 | 01-correction-vs-validity-bounded.cypher | 18/0 | all zero |
| W00-F02 | 02-late-arriving-fact.cypher | 11/0 | all zero |
| W00-F03 | 03-year-precision.cypher | 10/0 | all zero |
| W00-F04 | 00-common-base.cypher, 04-two-asserters-must-fail.cypher | 9/0 | all zero |
| W00-F05 | 00-common-base.cypher, 05-claim-occurrence-without-container-must-fail.cypher | 9/0 | all zero |
| W00-F06 | 00-common-base.cypher, 06-two-archetype-labels-must-fail.cypher | 7/0 | all zero |
| W00-F07 | 00-common-base.cypher, 07-derived-edge-forbidden-premise-must-fail.cypher | 14/0 | V-112r 3->3; V-505r 0->1 |
| W00-F08 | 08-identifier-across-issuers.cypher | 8/1 | V-432r 1->0; V-505i -->2 |
| W00-F09 | 09-retraction-and-provenance-states.cypher | 15/0 | V-235r 0->1 |
| W00-F10 | 00-common-base.cypher, 10-locator-kinds.cypher | 14/0 | all zero |
| W00-F12 | 00-common-base.cypher, 12-legacy-shapes-graphql-readability.cypher | 10/0 | V-521r 0->3 |
| W00-F13 | 00-common-base.cypher, 13-reconciliation-rulings.cypher | 30/0 | V-003r 2->1; V-101r 1->0; V-432r 2->1; V-503r 0->1; V-505r 0->1; V-521r 0->1; V-W00-13 -->1; V-W00-15 -->3; V-W00-16 -->1; V-W00-17 -->1; V-W00-19 -->1 |
| W02-pos+91 | fx-01-nr-salt-vs-moiety.cypher, fx-02-mosaic-provides-not-contains.cypher, fx-03-niagen-two-spec-versions.cypher, fx-04-botanical-ginkgo-... | 277/0 | V-003r 1->0; V-006r 2->0; V-505i -->16; V-W00-16 -->3; V-W00-19 -->2 |
| W02-all+90 | fx-01-nr-salt-vs-moiety.cypher, fx-02-mosaic-provides-not-contains.cypher, fx-03-niagen-two-spec-versions.cypher, fx-04-botanical-ginkgo-... | 303/0 | V-006r 1->1; V-108r 0->1; V-509r 0->1; V-112r 1->1; V-505r 0->1; V-505i -->16; V-W00-16 -->3; V-W00-19 -->2 |
| W03-pos | w03-positive.cypher, w03-projection-job.cypher | 302/0 | V-233r 4->0; V-234r 2->0; V-505i -->10; V-W00-16 -->2; V-W00-19 -->5 |
| W03-pos+neg | w03-positive.cypher, w03-projection-job.cypher, w03-negative.cypher | 322/0 | V-003r 1->1; V-112r 2->2; V-233r 8->3; V-234r 3->1; V-505i -->10; V-W00-16 -->3; V-W00-19 -->5 |
| W04-pos | w04-01-correction-vs-fact-ending.cypher, w04-02-package-vs-formulation-change.cypher, w04-03-declared-calculated-measured.cypher, w04-04-... | 117/0 | V-108r 1->1; V-509r 1->1; V-409r 3->0; V-505i -->4; V-W00-15 -->1; V-W00-16 -->2 |
| W04-04-alone | w04-04-basis-history-and-trial.cypher | 33/0 | V-108r 1->1; V-509r 1->1; V-409r 3->0; V-W00-16 -->1 |
| W07-pos | w07-00-sources.cypher, w07-01-measurands-tests-assays.cypher, w07-02-reference-intervals.cypher, w07-03-algorithms.cypher, w07-04-results... | 39/0 | V-112r 2->0; V-303r 1->0; V-313r 15->0; V-505i -->8; V-W00-16 -->1; V-W00-19 -->4 |
| W07-pos+90 | w07-00-sources.cypher, w07-01-measurands-tests-assays.cypher, w07-02-reference-intervals.cypher, w07-03-algorithms.cypher, w07-04-results... | 53/0 | V-112r 6->4; V-231r 1->0; V-302r 1->1; V-303r 2->1; V-304r 2->2; V-305c -->1; V-313r 19->1; V-505i -->8; V-W00-16 -->1; V-W00-19 -->4 |
| W07-pos+91 | w07-00-sources.cypher, w07-01-measurands-tests-assays.cypher, w07-02-reference-intervals.cypher, w07-03-algorithms.cypher, w07-04-results... | 40/0 | V-112r 2->0; V-303r 1->0; V-313r 15->0; V-505i -->8; V-W00-16 -->1; V-W00-19 -->4 |
| W09-pos | 01-registry-versions.cypher, 02-null-primary-favorable-secondary.cypher, 03-shared-dataset-vs-replication.cypher, 04-cross-domain-interve... | 70/0 | V-211r 1->0; V-217r 5->0; V-217i -->5; V-221r 4->0; V-505i -->19; V-W00-16 -->1; V-W00-19 -->2 |
| W09-pos+90 | 01-registry-versions.cypher, 02-null-primary-favorable-secondary.cypher, 03-shared-dataset-vs-replication.cypher, 04-cross-domain-interve... | 93/0 | V-003r 1->1; V-101r 1->1; V-108r 2->2; V-509r 2->2; V-211r 2->1; V-215r 1->3; V-217r 6->1; V-217i -->5; V-221r 5->1; V-503r 0->1; V-505r 0->5; V-505i -->19; V-W00-15 -->1; V-W00-16 -->1; V-W00-19 -->2 |
| W11-pos | 01-capability-promotion-filing-operating.cypher, 02-capacity-basis-nameplate-vs-utilized.cypher, 03-specification-versions-and-process-in... | 62/0 | V-505i -->9; V-W00-16 -->1; V-W00-19 -->1 |
| W11-pos+05 | 01-capability-promotion-filing-operating.cypher, 02-capacity-basis-nameplate-vs-utilized.cypher, 03-specification-versions-and-process-in... | 74/0 | V-505i -->9; V-W00-16 -->1; V-W00-19 -->1 |
| W12-pos | w12-00-base.cypher, w12-10-coa-vs-summary.cypher, w12-20-lot-measured-vs-label.cypher, w12-30-certification-scope.cypher, w12-40-missingn... | 428/0 | V-W00-16 -->1 |
| W12-pos+neg | w12-00-base.cypher, w12-10-coa-vs-summary.cypher, w12-20-lot-measured-vs-label.cypher, w12-30-certification-scope.cypher, w12-40-missingn... | 448/0 | V-112r 1->1; V-503r 0->1; V-505r 0->1; V-W00-16 -->1 |
| W13-pos | w13-regulatory-kinds.cypher, w13-jurisdiction-and-pending-values.cypher, w13-inspection.cypher | 519/1 | V-333r 1->0; V-505i -->2; V-W00-16 -->1 |
| W13-pos+neg | w13-regulatory-kinds.cypher, w13-jurisdiction-and-pending-values.cypher, w13-inspection.cypher, w13-negative.cypher | 608/1 | V-108r 0->1; V-509r 0->1; V-322r 0->1; V-333r 2->1; V-334r 0->2; V-505r 0->1; V-505i -->2; V-W00-16 -->1 |
| W15-pos | w15-00-common.cypher, w15-01-amazon-host-seller-fulfiller.cypher, w15-02-listing-merge-four-offers.cypher, w15-03-dtc-subscription-and-bu... | 839/0 | V-505i -->6; V-W00-15 -->1 |
| W15-pos+07 | w15-00-common.cypher, w15-01-amazon-host-seller-fulfiller.cypher, w15-02-listing-merge-four-offers.cypher, w15-03-dtc-subscription-and-bu... | 843/0 | V-101r 2->3; V-112r 3->4; V-505i -->6; V-W00-15 -->1 |
| W16-01 | 01-edition-diff-by-stepkey.cypher | 51/0 | V-503r 1->1 |
| W16-04 | 04-conditional-branch-missing-condition.cypher | 71/0 | V-525r 1->1 |
| W16-12 | 12-mutually-exclusive-steps.cypher | 25/0 | all zero |
| W19-pos | 01-cl003-work-rendition-identity.cypher, 02-primary-vs-retelling.cypher, 03-partial-capture-not-found.cypher, 04-source-revision-reanchor... | 128/0 | V-409r 1->0; V-512r 1->0; V-W00-16 -->1 |
| W19-pos+90 | 01-cl003-work-rendition-identity.cypher, 02-primary-vs-retelling.cypher, 03-partial-capture-not-found.cypher, 04-source-revision-reanchor... | 142/0 | V-409r 4->3; V-512r 1->0; V-W00-16 -->1; V-W00-19 -->1 |
| W20-01+04 | w20-01-resegmentation-vs-correction.cypher, w20-04-text-version-pairs.cypher | 96/0 | V-112r 4->0 |
| W20-01+02 | w20-01-resegmentation-vs-correction.cypher, w20-02-negative-chunk-support.cypher | 71/0 | V-112r 5->1; V-407r 1->4; V-W00-16 -->1 |
| W21-pos | fx01-dynamic-ads-renditions.cypher, fx02a-transcript-correction-cosmetic.cypher, fx02b-transcript-correction-substantive.cypher, fx03-spo... | 238/0 | V-423r 1->0; V-521r 0->6 |
| W21-pos+fx04neg | fx01-dynamic-ads-renditions.cypher, fx02a-transcript-correction-cosmetic.cypher, fx02b-transcript-correction-substantive.cypher, fx03-spo... | 241/0 | V-423r 2->1; V-521r 0->6 |
| W23-00+04 | 00-shared-base.cypher, 04-uid-redirect.cypher | 28/0 | V-432r 1->1 |
| W23-00+10 | 00-shared-base.cypher, 10-leak-probe-qs6.cypher | 37/0 | V-505r 0->1; V-521r 7->9 |
| W10-pos | w10-01-applicability-basis-13dim.cypher, w10-02-dose-ratio-minimal-pair.cypher, w10-03-surrogate-context.cypher, w10-04-null-primary-synt... | 68/0 | V-W00-16 -->1; V-W00-19 -->6 |
| W10-pos+90 | w10-01-applicability-basis-13dim.cypher, w10-02-dose-ratio-minimal-pair.cypher, w10-03-surrogate-context.cypher, w10-04-null-primary-synt... | 112/0 | V-003r 1->1; V-215r 1->1; V-231r 1->1; V-521r 2->2; V-504a -->1; V-W00-15 -->1; V-W00-16 -->2; V-W00-19 -->6 |
| W17-pos | 00-w17-base.cypher, 01-ae-zero-vs-not-reported.cypher, 02-safety-signal-assessments.cypher, 03-constraints-block-vs-lower.cypher, 04-inte... | 397/0 | V-217r 1->0; V-217i -->1 |
| W17-pos+90 | 00-w17-base.cypher, 01-ae-zero-vs-not-reported.cypher, 02-safety-signal-assessments.cypher, 03-constraints-block-vs-lower.cypher, 04-inte... | 434/0 | V-217r 3->1; V-217i -->2; V-503r 0->1; V-505r 0->1; V-505i -->1; V-521r 1->1 |
| W18-pos | w18-01-rezdiffra-milestone-clocks.cypher, w18-02-readout-causal-retelling.cypher, w18-03-conference-sessions-sponsorship.cypher, w18-04-n... | 485/0 | V-003r 18->18; V-503r 1->1; V-505i -->15 |
| W18-pos+90 | w18-01-rezdiffra-milestone-clocks.cypher, w18-02-readout-causal-retelling.cypher, w18-03-conference-sessions-sponsorship.cypher, w18-04-n... | 524/0 | V-003r 20->20; V-101r 0->1; V-112r 1->1; V-503r 1->1; V-505r 0->3; V-505i -->16 |

## Reading the counts against the requesters' failing cases

Each requester's failing case is reproduced by the frozen original and resolved by the revision, while the negatives stay caught:

| Validator | Positive (false positives removed) | Negative still caught |
|---|---|---|
| V-003r | W02 fx-91 1 -> 0; W00 F13 P2 accepted | W00 F13 N2 (1); W03, W09, W10 negatives unchanged |
| V-006r | W02 fx-91 2 -> 0 | W02 fx-90 N2 1 -> 1 |
| V-112r | W07 same-version COMPARED_TO 2 -> 0; W20 offset-overlap RESOLVES_TO_CHUNK 4 -> 0 | W00 F07 3 -> 3; W15 N10 3 -> 4 (AFFILIATE_FOR_OFFER premise now caught); W20 N-case 1 |
| V-211r, V-217r (+V-217i), V-221r | W09 positives 1/5/4 -> 0 (V-217i lists the 5 faithful zeros) | W09 fx-90 1/1/1 |
| V-215r | - | W09 fx-90 1 -> 3 (N08 INDEPENDENT_REPLICATION now caught) |
| V-231r | W07 fx-90 non-mechanism DIRECT_MEASUREMENT 1 -> 0 | W10 negative 1 -> 1 |
| V-233r, V-234r | W03 positive 4 -> 0, 2 -> 0 | W03 negatives 3 and 1 |
| V-235r | - | W00 F09 retracted-only assertion 0 -> 1 (RENDITION_OF join; frozen DOI join missed it) |
| V-302r..V-305c, V-303r, V-313r | W07 positive V-303 1 -> 0, V-313 15 -> 0 | W07 fx-90: V-302r 1, V-304r 2, V-305c 1, V-313r 1 |
| V-322r, V-333r, V-334r | W13 positive V-333 1 -> 0 | W13 negatives V-322r 0 -> 1, V-334r 0 -> 2, V-333r 1 |
| V-407r (W20-V01) | - | W20 fixture 02: 1 -> 4 (all four chunk-support defects) |
| V-409r, V-512r | W04 w04-04 3 -> 0; W19 fixture 04 1 -> 0 and 1 -> 0 | W19 fx-90 3 |
| V-423r (V-W21-06) | W21 fx07 1 -> 0 | W21 fx04 neg 1 |
| V-432r | W00 F08 1 -> 0; W00 F13 valid redirect not reported | W00 F13 N1; W23 fixture 04 1 (it writes survivingUid with SAME_WORK_DIFFERENT_NAME: W23 must switch to SAME_IDENTITY_MERGED, W00-R-11 fallback) |
| V-504a | - | W10 fx-90 1 (assessment recorded before the snapshot it cites) |
| V-503r | - | W12 N11 0 -> 1 (OBSERVATION_ONLY end on HAS_CERTIFICATION_SCOPE); W00 F13 N3; W17 negative 1 |
| V-505r | - | W02, W09 (5), W12, W13, W17, W18 (3), W23 negatives; W00 F13 N5 QUALIFIER_DIFFERS:isPrimary |
| V-521r | - | W23 fixture 10: 7 -> 9 (PRIVATE_PERSONAL and list-valued private uids); W00 F12 legacy lower case 3; W21 positives 6 (W21 stores `internal`: migration D5) |
| V-108r / V-509r | informational review rows on W04 w04-04 (1), W09, W13, W02 negatives | - |
| V-525r | - | W16 fixture 04 1 |

Findings for other owners surfaced by the new checks (not validator defects):

- V-W00-19: Sources whose canonicalUri is a doi.org resolver in W02 (2), W03 (5), W07 (4), W09 (2), W10 (6), W11 (1) fixtures (W00-R-15).
- V-W00-16 TOKEN_NOT_REGISTERED_FOR_LABEL: W11 `specification-criterion` (8 nodes), W12/W02 `spec-version`, W13 `mixture`; FIXTURE_ALIAS_TOKEN
  rows (`study-arm`, `study-intervention`, `result`, `outcome`, `policy`) are 0.2.0 aliases to migrate (10-kernel-operations-delta.md section 2).
- V-W00-15: IDENTIFIED_BY edges in W04 (4 edges) and W15 fixtures, W09/W10 legacy Study EVALUATES edges (migrations D4, D2); W00 F13 N4 all three shapes.
- V-003 (frozen and r): 18 W18 assertions carry neither object nor literal (scheduled/occurred event statements) - a W18 defect, unchanged by W00-R-02.
