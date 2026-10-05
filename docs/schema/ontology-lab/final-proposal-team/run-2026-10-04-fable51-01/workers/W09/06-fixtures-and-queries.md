# W09 fixtures and queries

## How the files were run

**Status: run.** All fixtures and queries were executed on 2026-10-04 on an embedded **Neo4j 5.26.31 Community** instance:
- Harness: `org.neo4j.test:neo4j-harness`.
- The run harness `validation/harness/run-cypher.mjs` splits files on `;` and runs each statement in its own transaction. No variable crosses a statement.
- The instance was a W09 scratch instance (heap capped at 384 MB after an out-of-memory loss caused by about 22 concurrent instances from other workers).

**Run order:** load `01`–`07` → run `80-queries.cypher` (positive) → run the inherited `neo4j/validation.cypher` with the run's `validation-params.json` → load `90-negative-cases.cypher` → rerun both query files.

**Raw results:** `fixtures/run-results-2026-10-04.json` (rows and samples per query).

**Counts:**
- Positives: 253 nodes, 451 relationships.
- All fixture and query statements: 0 errors.
- Inherited suite: 174 statements, 0 errors.

**GraphQL read check (also run).** The SDL fragment, plus a stub of other owners' types, was built with `@neo4j/graphql` 7.6.3 and queried against the loaded data. It read Study → registration → versions, arms → interventions → components → materials (with `asReportedName`), outcome definitions → results with `armRole`, AE rows, and `CORRECTS` with `sourceRevisionEventUid`. There were no errors once DateTime fields were left out. Selecting a DateTime field fails without APOC (W09-SR-17).

## Fixture conventions

- Every node carries its primary label and its archetype label (AdverseEventResult additionally `StudyResult`).
- Every node has `uid` and an `id` equal to the opaque segment, `createdAt`, the archetype's required fields and `privacyClass: 'PUBLIC'`.
- Asserted edges carry `relationshipUid`, `assertionUid`, `recordedFrom`, `validFromBasis` and `validToBasis`. The authorizing Assertion is `HAS_SUBJECT`/`HAS_OBJECT` linked and `SUPPORTED_BY` a locator.
- Snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'`.
- TEXT_QUOTE locators carry `normalizationVersion: 'NFC-WS1'` and a real sha256 `quoteHash` over the quoted text.
- Each file ends with a CAPTURE_FIDELITY policy Adjudication for the ACCEPTED assertions it created (INV-103). Synthetic or unsupported assertions stay PROPOSED.
- Recorded times are 2026-10-04 (the commit time of this run); valid times are the source's.
- Unregistered uid tokens used: `study-population`, `device`, `procedure` (W09-SR-04). The `outcome` token is used for OutcomeDefinitions.

## 1. Fixture files

| File | Cases (minimal pairs in bold) | Real / synthetic |
|---|---|---|
| `01-registry-versions.cypher` | **Registered-not-completed vs results-posted**: NCT04985630 RECRUITING with a displayed primary completion date already past, vs NCT00938340 COMPLETED with `resultsPosted: true`; NCT02678611 COMPLETED with results not posted. **EXCLUSIVE episodes**: a synthetic registration whose v1 episode is closed in recorded time and re-attached with a stated `validTo`, and v2 attached from 2026-08-15. Derived Study cache with `projectionOfRegistrationVersionUid`. | Real (S-01, S-11, S-16) + SYNTHETIC (Y-01) |
| `02-null-primary-favorable-secondary.cypher` | ATLAS primary NOT_SIGNIFICANT. **Secondary between-arm SIGNIFICANT_FAVORABLE vs the same sentence's within-arm "+12%"**. Placebo within-arm SIGNIFICANT_UNFAVORABLE. `multiplicityAdjusted: false`. Author claim RESULT_CLINICALLY_MEANINGFUL as an Assertion. **Synthetic favorable post hoc subgroup entered only as HYPOTHESIS_GENERATING** (W10 `INCLUDES_RESULT {inputRole}`). Per-source priority declarations; derived priority. | Real (S-08..S-10) + SYNTHETIC subgroup (Y-04) |
| `03-shared-dataset-vs-replication.cypher` | **Shared dataset**: Berryman 2013 (PRIMARY_REPORT) and Zhang 2011 (SECONDARY_ANALYSIS, published first) both analyse the NCT00938340 dataset. **vs dataset-independent lines**: ATLAS and ENERGIZE, with a shared sponsor (derived SPONSORED_BY). DOI/PMID Identifier records. | Real (S-13, S-14, S-18, S-19) |
| `04-cross-domain-interventions.cypher` | **Food**: four walnut materials as served (85 / 5.6 / 34 / 51 g, SINGLE_DOSE, MATERIAL_AS_IS); enrolled 20 vs analyzed 15. **Device**: MedX 1116 real vs **sham** (same Device, arm type SHAM_COMPARATOR) through USES_INTERVENTION_DEVICE; the sponsor's "FDA-approved as a nonsignificant risk" kept as a PROPOSED characterization. **Procedure**: synthetic sauna via FOLLOWS_INTERVENTION_DEFINITION. **Food in a not-completed study**: pomegranate juice with the amount NOT_REPORTED. | Real (S-11, S-13, S-15, S-16) + SYNTHETIC procedure (Y-02) |
| `05-adverse-events-zero.cypher` | **Reported zero vs not reported**: Basis SAE 0/40, 0/38, 0/40 (NOT_DESCRIBED, "self-reported AEs") and any-AE counts 13/18, 15/25, 17/23. ENERGIZE SAE zeros (MedDRA-coded, NOT_DESCRIBED). **Synthetic SYSTEMATIC zero**. NCT00938340 and ATLAS have no AE rows (not reported/not captured, never zero). | Real (S-07, S-19) + SYNTHETIC (Y-03) |
| `06-publication-correction.cypher` | PMID 30155270 (AUTHOR_CORRECTION) `CORRECTS` PMID 29184669 naming the **ERRATUM SourceRevisionEvent** (revises the PMC rendition; ANNOUNCED_IN the notice snapshot; no prior snapshot). **Added content** (Elysium provided NRPT; nothing superseded) vs **changed content** (reference 20: SUPERSEDES {SOURCE_CORRECTION}; old assertion kept). REPORTS_ON, PRODUCED_DATASET, ANALYZES_DATASET (ON_REQUEST). NAD+ priority: registry SECONDARY vs paper PRIMARY. | Real (S-04..S-07) + INHERITED Discussion quote (I-01) |
| `07-historical-label-gap.cypher` | CQ-ID-02: conduct window 2016-01..2016-07 (MONTH) vs the Basis formulation observed 2026-07-10 with an UNKNOWN start → OVERLAP_START_UNKNOWN. **vs** a synthetic formulation stated from 2015-06 → COVERS_INTERVAL_IF_STILL_TRUE. "Commercially known as Basis" is a literal assertion; no study-side edge to a product. NRPT components with massBasis UNSPECIFIED. | Real (S-01, S-04) + INHERITED (I-01, I-03) + SYNTHETIC (Y-05) |
| `90-negative-cases.cypher` | 23 negative statements N01–N23, one collapse each (section 4). | built on the positives |
| `80-queries.cypher` | Inherited V-2xx (verbatim), proposed V-211r/V-215r/V-217r/V-217i/V-221r, V-W09-01..11, QS-W09-01..12. | — |

## 2. Expected and observed rows (positives = files 01–07; "+neg" = after 90)

| Query | Positives | +neg | Expected meaning |
|---|---|---|---|
| V-201 (INV-201) | 0 | 2 | N01 Study EVALUATES Product; N02 StudyArm RECEIVES ProductVariant |
| V-202 | 0 | 1 | N03 |
| V-210 (INV-208) | 0 | 1 | N05 |
| V-211 (frozen) | **1** | 2 | positive row = synthetic DEMO-001 v1 with two episodes → false positive (W09-CR-03); N06 |
| V-211r (proposed) | 0 | 1 | N06 only |
| V-212 (informational) | 1 | 1 | NCT02678611: `resultsPosted=false` while PMID 29184669 reports results; answers must not say "unpublished" |
| V-213 (INV-209) | 0 | 1 | N12 |
| V-215 (frozen) | 0 | 1 | N07 only (misses N08, N09) |
| V-215r (proposed) | 0 | 3 | N07, N08, N09 |
| V-216 | 0 | 3 | N09; N10 twice (both walnut results are within-arm) |
| V-217 (frozen) | **5** | 6 | positives: Basis ×3 and ENERGIZE ×2 honest NOT_DESCRIBED zeros → false positives (W09-CR-01); N11 |
| V-217r (proposed) | 0 | 1 | N11 (silence stored as zero without method) |
| V-217i (proposed, informational) | 5 | 5 | the five honest zeros; answers say "zero reported; collection method not described" |
| V-218 | 0 | 1 | N10 (walnut publications share Study and Dataset) |
| V-221 (frozen) | **4** | 5 | positives: NCT02582593 real and sham, pomegranate juice, synthetic sauna → false positives (W09-CR-02); N23 |
| V-221r (proposed) | 0 | 1 | N23 only |
| V-223 (informational) | 1 | 1 | Blood NAD+ ["SECONDARY","PRIMARY"] |
| V-W09-01 | 0 | 1 | N13 |
| V-W09-02 | 0 | 1 | N14 |
| V-W09-03 | 0 | 1 | N04 |
| V-W09-04 | 0 | 1 | N15 |
| V-W09-05 | 0 | 1 | N16 |
| V-W09-06 | 0 | 1 | N17 |
| V-W09-07 | 0 | 1 | N18 |
| V-W09-08 | 0 | 1 | N19 |
| V-W09-09 (warning) | 4 | 4 | publications whose Identifier records were not written in these fixtures (ATLAS, ENERGIZE, Basis, correction); fixture 03 shows the full pattern |
| V-W09-10 | 0 | 1 | N20 |
| V-W09-11 | 0 | 1 | N21 |
| QS-W09-01 (CQ-ST-08, R = 2026-10-04, V = 2026-06-01) | 1 | 1 | DEMO-001 v1: RECRUITING, enrollment 60 ESTIMATED, `resultsPosted` false, UNKNOWN_START. With V = 2026-09-01 the answer is v2 (COMPLETED, results posted). |
| QS-W09-02 (CQ-ST-01) | 2 | 2 | real: TRANSCRANIAL, DEVICE_SESSION, "six sessions over a 2-week period", P2W, NOT_APPLICABLE, target Device "MedX 1116 Rehab Console". Sham: same Device, `asReportedName` "Sham MedX 1116 Rehab Console". |
| QS-W09-03 (CQ-ST-05) | 3 | 5 | null primary → hamstring BETWEEN_ARM SIGNIFICANT_FAVORABLE (SUPPORTIVE in two syntheses); synthetic subgroup HYPOTHESIS_GENERATING; +neg adds the CONFIRMATORY and INDEPENDENT_REPLICATION misuses |
| QS-W09-04 (CQ-ST-04) | 6 | 6 | Blood NAD+: paper PRIMARY, registry SECONDARY, derived SECONDARY. ATLAS power output: registry and paper PRIMARY. Strength and 6MWT: SECONDARY. |
| QS-W09-05 (CQ-ST-06) | 8 | 11 | Basis 6 AE rows, ENERGIZE 2 rows, NCT00938340, NCT02582593 and ATLAS: NO_AE_RECORD_CAPTURED |
| QS-W09-06 (CQ-EV-05) | 1 | 2 | 30155270 AUTHOR_CORRECTION, CORRECTS, ERRATUM, announced 2018-08-20, learned 2026-10-04, reference-20 assertion SUPERSEDED (SOURCE_CORRECTION) |
| QS-W09-07 (CQ-ST-07) | 1 | 2 | 21871057 + 23616506 share [Study, Dataset] |
| QS-W09-08 (CQ-AX-05) | 1 | 1 | 2 independent lines (ATLAS, ENERGIZE); shared sponsors ["Amazentis SA"] |
| QS-W09-09 (CQ-ID-02) | 2 | 2 | Basis: OVERLAP_START_UNKNOWN (fromBasis OBSERVATION_ONLY). Synthetic: COVERS_INTERVAL_IF_STILL_TRUE |
| QS-W09-10 (CQ-ID-01) | 1 | 1 | reported commercial name "Basis", quote "a repeat dose of NRPT (commercially known as Basis)", `hasDirectCommercialEdge = false` |
| QS-W09-12 (CQ-EV-03) | 1 | 1 | INTERVENTIONAL_RANDOMIZED: 3 studies with captured efficacy results |

## 3. Inherited 0.2.0 suite on the W09 fixtures (non-zero rows only)

| Check | Positives | +neg | Reading |
|---|---|---|---|
| V-118 | 10 | 10 | informational uid backfill counts (0 missing) |
| V-211 | 1 | 2 | W09-CR-03 |
| V-212 | 1 | 1 | informational, expected |
| V-217 | 5 | 6 | W09-CR-01 |
| V-221 | 4 | 5 | W09-CR-02 |
| V-223 | 1 | 1 | informational, expected |
| V-401b | 1 | 1 | informational: 19 ACCEPTED assertions rest on coarse registry locators (WHOLE_SNAPSHOT/SECTION), as expected for registry fields |
| V-514b | 1 | 1 | informational: 0 assertions without contentHash |
| V-002, V-003, V-012, V-101, V-108, V-201, V-202, V-210, V-213, V-215, V-216, V-218, V-506, V-507b, V-509 | 0 | ≥1 | triggered only by negatives (e.g. V-108/V-509 by the shared version in N06; V-506/V-507b by N17) |

Earlier runs caught and fixed three fixture defects; these are what the final files reflect:
- V-003: analysisRole stored as a literal on an assertion that also has an object (W09-SR-12); and STUDY_CONDUCTED_DURING without a literal.
- V-512: the revision event pointed at the doi Source while its resulting snapshot belonged to the PMC Source.
- V-110, V-335 and V-401: missing adjudication, an unadjudicated regulatory characterization, and missing quote hashes.

## 4. Negative cases → violation ids

| N | Collapse | Validator(s) |
|---|---|---|
| N01 | legacy `Study -EVALUATES-> Product` | V-201 (FI USES_INTERVENTION_MATERIAL → EVALUATES_PRODUCT) |
| N02 | `StudyArm -RECEIVES-> ProductVariant` | V-201 |
| N03 | component → ProductVariant without `asReportedName` | V-202 |
| N04 | component with two targets | V-W09-03 |
| N05 | registry status and pmid on Study | V-210 |
| N06 | version without `observedAt`, two owners | V-211, V-211r, V-108, V-509 |
| N07 | secondary-after-null-primary as CONFIRMATORY | V-215, V-215r |
| N08 | the same as INDEPENDENT_REPLICATION | V-215r only |
| N09 | within-arm "+12%" as INDEPENDENT_REPLICATION | V-216, V-215r (FI WITHIN_ARM_CHANGE_SIGNIFICANT → BETWEEN_ARM_EFFECT) |
| N10 | shared-dataset results as INDEPENDENT_REPLICATION | V-218 |
| N11 | AE silence stored as zero without method | V-217, V-217r (INV-207) |
| N12 | `isClinicallyMeaningful` on a result | V-213 (FI STATISTICALLY_SIGNIFICANT → CLINICALLY_MEANINGFUL) |
| N13 | derived significance contradicts the conclusion | V-W09-01 (guards FI NOT_STATISTICALLY_SIGNIFICANT → NO_EFFECT at the record level; the interpretation guard is W10's) |
| N14 | foreign registry cache on Study | V-W09-02 |
| N15 | CORRECTS without an event | V-W09-04 |
| N16 | "results unpublished" from `resultsPosted=false` | V-W09-05 (FI REGISTRY_RESULTS_NOT_POSTED → RESULTS_UNPUBLISHED) |
| N17 | erratum recorded as VALIDITY_BOUNDED | V-W09-06, V-506, V-507b (W00 FI CORRECTS_SOURCE → FACT_CEASED) |
| N18 | stored priority taken from the paper | V-W09-07 |
| N19 | AE row on two INTERVENTION arms | V-W09-08 |
| N20 | bare asserted REPORTS_ON | V-W09-10, V-101 |
| N21 | OPERATED_BY from a collaborator listing, with `assertionUid` | V-W09-11 (FI SPONSORS_STUDY → EXECUTES_STUDY family; D-011) |
| N22 | Study collapsed with Publication | V-012 |
| N23 | supplement component with an amount but no mass basis | V-221, V-221r (true positive) |

**Catalog forbidden implications covered by other owners' validators:**

| Forbidden implication | Validator | Owner |
|---|---|---|
| SURROGATE_IN_CONTEXT → SURROGATE_IN_OTHER_CONTEXT | V-214 | W10 |
| SHARED_INGREDIENT_NAME → EVIDENCE_APPLIES | V-208 | W10 |

W09 supplies their inputs (`OutcomeDefinition`, `InterventionComponent` materials); QS-W09-10 shows the absence of any direct product edge.

## 5. Essential CQs covered by at least one run query

| Query | CQs |
|---|---|
| QS-W09-02 | CQ-ST-01 |
| QS-W09-03 | CQ-ST-05 |
| QS-W09-10 | CQ-ID-01 |
| QS-W09-09 | CQ-ID-02 |
| QS-W09-01 | CQ-ST-08 |
| QS-W09-04 | CQ-ST-04 |
| QS-W09-05 | CQ-ST-06 |
| QS-W09-06 | CQ-EV-05 |
| QS-W09-07, QS-W09-08 | CQ-ST-07, CQ-AX-05 |
| QS-W09-12 | CQ-EV-03 |

CQ-ST-02, -03, -09 and -10 and CQ-EV-04 are joint with W10 or inherited; W09 provides the inputs, checked by V-W09-* and the GraphQL read.

## 6. Not covered

- **Access leakage:** W09 has no private data; no private fixture is relevant (contract A9).
- **Identity collision:** the trial NR material vs NR-E (two ResolutionHypotheses) remains in the inherited `examples/study-vs-product-mismatch.cypher`; W09 reuses its uid `hu:material:nct02678611-nr-as-supplied`.
- **Late arrival:** fixture 01 statement 6 records the synthetic v2 learned later, with v1 re-bounded and nothing backdated. Fixture 06 records a 2018 correction learned in 2026: valid time 2018 with PUBLICATION_PROXY basis, recorded time 2026.
